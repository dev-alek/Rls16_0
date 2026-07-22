/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по топливным платежам = кусок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

IF FIRST-OF(chk-doc.doc-code)   then do:
  assign
  sum-list = ""
  pay-code-list = ""
  curr-code-list = ""
  b-code-list = ""
  b-name-list = ""
  b-sum-list = ""
  b-qnty-list = ""
  b-price-list = ""
  b-pricen-list = ""
  is-real-top-list = ""
  exch-list = ""
  atr64-list = ""
  .
  assign
  nottopgood = no
  nottopsum = 0
  nottoppaysum = 0
  .
  FOR EACH ub.chk-pay No-LOCK WHERE
            ub.chk-pay.doc-code = ub.chk-doc.doc-code and ub.chk-pay.tot-rubl > 0 ,    /*  такое же кривое как отчет отсечение сдачи    ... ужас, а не отчет..*/
      FIRST ub.cash-pay No-LOCK WHERE
            ub.cash-pay.cdpay-code = ub.chk-pay.pay-code
  BY ub.cash-pay.cdpay-code
  BY ub.cash-pay.curr-code:
    if ub.cash-pay.atr64 = yes or ub.cash-pay.is-cash = yes then do:
      assign
      sum-list = string(sign * (if v-curr-r-b = {&r-b-base}
                                then ub.chk-pay.tot-base
                                else ub.chk-pay.tot-rubl)) + {&comma-char} + sum-list
      pay-code-list = string(ub.chk-pay.pay-code) + {&comma-char} + pay-code-list
      curr-code-list = string(ub.chk-pay.curr-code) + {&comma-char} + curr-code-list
      atr64-list = (if ub.cash-pay.is-cash
                          then "0"
                          else  "1"
                          ) + {&comma-char} + atr64-list
      exch-list = string(ub.chk-pay.tot-rubl / ub.chk-pay.tot-base) + {&comma-char} + exch-list
      .
    end.
    else do:
      assign
      nottoppaysum = nottoppaysum + sign * (if v-curr-r-b = {&r-b-base}
                                            then ub.chk-pay.tot-base
                                            else ub.chk-pay.tot-rubl)
      nottoppaysum-rubl = nottoppaysum-rubl + sign * ub.chk-pay.tot-rubl
      nottoppaysum-base = nottoppaysum-base + sign * ub.chk-pay.tot-base
      nottoppayexch = nottoppaysum-rubl / nottoppaysum-base
      .
    end.
  END.  /*FOR EACH chk-pay*/
end. /*IF FIRST-OF(chk-doc.doc-code*/
IF NUm-ENTRIES(sum-list) <> NUm-ENTRIES(pay-code-list) then NEXT {1}.
/*не учитываем списание по расходу*/
if chk-gds.write-off-code <> ?
and chk-gds.write-off-code > 0  then NEXT {1}.

if first-of(chk-gds.b-code)  then do:
  nottopgood = no.
  FIND FIRST ub.bar-code NO-LOCK WHERE
             ub.bar-code.b-code = ub.chk-gds.b-code No-ERROR.
  IF NOT AVAIL ub.bar-code then do:
    nottopgood = yes.
  end.
  else do:
    FIND FIRST ub.goods No-LOCK WHERE
                ub.goods.gds-code = ub.bar-code.gds-code NO-ERROR.
    FIND FIRST ub.units No-LOCK WHERE
                ub.units.unit-name = ub.goods.unit-base No-ERROR.
    if lookup({&petrolium}, ub.units.type) = 0 then do:
      assign
      is-real-top = no
      .
      run gdsoattr-value  in this-procedure (
                                              input  {&attr-petrol-purse-o}
                                             ,input  ub.goods.gds-code
                                             ,input  ub.chk-doc.obj-type
                                             ,input  ub.chk-doc.obj-code
                                             ,output attr-value
                                             ,output attr-type
                                            ) no-error .
       if error-status:error
       or attr-value = "no" then do:
        assign
        nottopgood = yes
        .
      end.
    end.
    else do:
      assign
      is-real-top = yes
      .
    end.
  end.
  if not nottopgood then do:
    assign
    b-qnty = 0
    b-sum = 0
    .
  end.
end. /*if first-of(chk-gds.b-code)*/
if nottopgood then do:
  assign
  nottopsum = nottopsum + sign * ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt + ub.chk-gds.price-service)
  .
end.
else do:
  assign
  b-qnty = b-qnty + sign * ub.chk-gds.doc-qnty
  b-sum = b-sum  + sign * ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt + ub.chk-gds.price-service)
  b-pricen = (if b-qnty <> 0 then b-sum / b-qnty else 0)
  .
end.
IF LASt-of(chk-gds.b-code) then do:
  if nottopgood then do:
  end.
  else do:
    assign
    b-name-list = string(ub.goods.gds-name) + {&comma-char} + b-name-list
    b-code-list = string(ub.bar-code.b-code) + {&comma-char} + b-code-list
    b-qnty-list = string(b-qnty) + {&comma-char} + b-qnty-list
    b-sum-list = string(b-sum) + {&comma-char} + b-sum-list
    b-price-list = string(ub.chk-gds.price-base) + {&comma-char} + b-price-list
    b-pricen-list = string(b-pricen) + {&comma-char} + b-pricen-list
    is-real-top-list = (if is-real-top
                       then "1":U
                       else "0":U) + {&comma-char} + is-real-top-list
    .
  end.
END. /*IF LASt-of(chk-gds.b-code) */

IF LAST-OF(ub.chk-doc.doc-code) THEN DO:

    /*вычтем нетопливную чаcть!*/
  if nottopsum > 0 then do:
    /*найдем сумму оплат нетопливных товаров наличными вычтя из всей
    суммы нетопливных товаров нетопливные платежи */
    assign
    nottopsum = nottopsum - nottoppaysum.
    /*теперь спишем сумму нетопливных товаров по наличным*/
    R{1}:
    REPEAT while nottopsum > 0:
      DO ii = 1 to num-entries(pay-code-list):
        if entry(ii, atr64-list) = "0" then do:
          /*это наличные можно списывать нетопливный товар*/
          assign
          /*сумма очередного наличного платежа*/
          dop-sum = decimal(entry(ii, sum-list))
          dop-sum2 = MIN(dop-sum, nottopsum)
          dop-sum = dop-sum - dop-sum2
          nottopsum = nottopsum - dop-sum2
          .
          if dop-sum = 0 then do:
            assign
            ENTRY(ii, pay-code-list) = ""
            ENTRY(ii, curr-code-list) = ""
            ENTRY(ii, sum-list) = "0"
            ENTRY(ii, atr64-list) = ""
            ENTRY(ii, exch-list) = "0"
            .
            NEXT. /*do ii = 1 to */
          end. /*dop-sum = 0*/
        end. /*if entry(ii, atr64-list) = "0"*/
        else NEXT. /*do ii = 1 to */
      END. /*DO ii = 1 to */
      if ABS(nottopsum) > 0.015 then do:
        create bad-chk.
        assign
        bad-chk.doc-code = ub.chk-doc.doc-code
        bad-chk.delta = nottopsum
        .
        NEXT {1}.
      end.
      LEAVE r{1}.
    END. /*REPEAT*/
  end. /*были нетопливные суммы*/
  /*если что-то осталось еще от нетопливных платежей то*/
  if nottoppaysum > 0 then do:
    assign
    sum-list = string(nottoppaysum) + {&comma-char} + sum-list
    pay-code-list = "0" + {&comma-char} + pay-code-list
    curr-code-list = "0" + {&comma-char} + curr-code-list
    atr64-list = "0" + {&comma-char} + atr64-list
    exch-list = string(nottoppayexch) + {&comma-char} + exch-list
    .

  end.
  DO ii =1 to num-entries(b-code-list):
    assign
    curr-b-code = integer(entry(ii, b-code-list))
    curr-is-real-top = integer(entry(ii, is-real-top-list))
    b-qnty = decimal(entry(ii, b-qnty-list))
    b-sum = decimal(entry(ii, b-sum-list))
    b-name = entry(ii, b-name-list)
    b-price = decimal(entry(ii, b-price-list))
    b-pricen = decimal(entry(ii, b-pricen-list))
    .
    _repeat:
    REPEAT WHILE b-sum > 0:
      /*проверим не пустой ли элмент списка дежит - вычерпанный нетопливом*/
      if entry(1, pay-code-list) = "" then
      assign
      pay-code-list = substr( pay-code-list, 2)
      sum-list = substr(sum-list, 2)
      exch-list = substr(exch-list, 2)
      .
      /*создадим запись о выручке*/
      FIND FIRST benefits WHERE
                benefits.b-code = curr-b-code AND
                  benefits.pay-code = integer(entry(1,pay-code-list)) AND
                  benefits.curr-code = integer(entry(1, curr-code-list))

      No-ERROR.
      IF NOT avail benefits then do:
        create benefits.
        assign
        benefits.b-code = curr-b-code
        benefits.is-real-top = curr-is-real-top
        benefits.pay-code = integer(entry(1,pay-code-list))
        benefits.curr-code = integer(entry(1,curr-code-list))
        benefits.gds-name = b-name.
      end.
      assign
      for-sum = abs(decimal(entry(1,sum-list)))
      dop-sum = (if for-sum > b-sum then b-sum else for-sum)
      benefits.b-code = curr-b-code
      benefits.qnty = benefits.qnty  + sign * dop-sum / b-pricen
      benefits.tot-base = if v-curr-r-b = {&r-b-base}
                           then  (benefits.tot-base + sign * dop-sum)
                           else benefits.tot-base
      benefits.tot-rubl = if v-curr-r-b = {&r-b-base}
                          then benefits.tot-rubl
                          else (benefits.tot-rubl + sign * dop-sum)
      b-sum = b-sum - dop-sum
      for-sum = for-sum - dop-sum
      b-qnty = b-qnty - dop-sum / b-pricen

      benefits.tot-base = if v-curr-r-b = {&r-b-base}
                          then benefits.tot-base
                          else (benefits.tot-rubl + sign * dop-sum / decimal(entry(1,exch-list)))
      benefits.tot-rubl = if v-curr-r-b = {&r-b-base}
                          then (benefits.tot-base + sign * dop-sum * decimal(entry(1,exch-list)))
                          else benefits.tot-rubl
      .

      if b-sum > 0 then do:
        /*платеж не полностью покрыл сумму товара - нужно задействовать следующий*/
        assign
        pay-code-list = substr(pay-code-list,index(pay-code-list, {&comma-char}) + 1)
        curr-code-list = substr(curr-code-list,index(curr-code-list, {&comma-char}) + 1)
        exch-list = substr(exch-list,index(exch-list, {&comma-char}) + 1)
        sum-list = substr(sum-list,index(sum-list, {&comma-char}) + 1).
      end. /*b-sum > 0 */
      else do:
        /*от платежа еще остался кусочек*/
        if for-sum > 0 then
        entry(1, sum-list) = string(for-sum).
        else /*точно уложились*/
        assign
        pay-code-list = substr(pay-code-list,index(pay-code-list, {&comma-char}) + 1)
        curr-code-list = substr(curr-code-list,index(curr-code-list, {&comma-char}) + 1)
        exch-list = substr(exch-list,index(exch-list, {&comma-char}) + 1)
        sum-list = substr(sum-list,index(sum-list, {&comma-char}) + 1).
      end. /* else b-sum > 0*/
      if b-sum <= 0 OR pay-code-list = "" then LEAVE.  /*платеж точно покрыл сумму товара*/
    END. /*REPEAT WHIEL b-sum > 0*/
  END. /*DO ii*/

END. /*IF LAST-of chk-gds.doc-code*/


/* $Workfile$ e n d */