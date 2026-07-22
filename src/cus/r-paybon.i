/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Рзамазывание бонусов по платежам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/06
Author: Bakhtadze Natalya
Creation date: 09/29/06

*/

                                                                                                                        &scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if first-of(buf_CHK-pay.DOC-CODE) THEN Do:
  assign
  kk = 0 /*текущая позиция в полученном списке товаров*/
  jj = 1 /*всего записей temp-chk-gds*/
  jjp = 0 /*записей топлива*/
  jjo = 0 /*записей нетоплива*/
  pay-sum = buf_chk-doc.netto /*сумма неразбросанного*/
  dop-sumg = 0
  .
  for each buf_treal-3:
    delete buf_treal-3.
  end.

  for each temp-chk-gds:
    delete temp-chk-gds.
  end.
  for each temp-chk-pay:
    delete temp-chk-pay.
  end.

  FOR EACH buf_chk-gds No-LOCK WHERE
           buf_chk-gds.doc-code = buf_chk-pay.doc-code
  BY buf_chk-gds.line-num:
  /*не учитваем списание по расходу*/
  if buf_chk-gds.write-off-code <> ?
  and buf_chk-gds.write-off-code > 0 then NEXT.
    find first temp-chk-gds where
              temp-chk-gds.b-code = buf_chk-gds.b-code
          AND  temp-chk-gds.doc-code = buf_chk-gds.doc-code
          and temp-chk-gds.price-base = buf_chk-gds.price-base no-error.
    IF AVAILABLE TEMP-CHK-GDS THEN DO:
      assign
      temp-chk-gds.qnty = temp-chk-gds.qnty  + buf_chk-gds.DOC-qnty
      temp-chk-gds.sum  = temp-chk-gds.sum  + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt + buf_chk-gds.price-service)
      temp-chk-gds.sum-change = temp-chk-gds.sum
      .
    end. /*отмена*/
    else do:
      find first temp-chk-gds where temp-chk-gds.jj_ = jj use-index ijj no-error.
      if not available temp-chk-gds then do:
        create temp-chk-gds.
        assign
        temp-chk-gds.jj_ = jj
        temp-chk-gds.qnty = 0
        temp-chk-gds.sum = 0
        temp-chk-gds.sum-change = temp-chk-gds.sum
        jj = jj + 1
        .
      end.
      else do:
        assign
        jj = jj + 1
        temp-chk-gds.qnty = 0
        temp-chk-gds.sum = 0
        temp-chk-gds.sum-change = temp-chk-gds.sum
        .
      end.
      ASSIGN
      temp-chk-gds.doc-code = buf_chk-gds.doc-code
      temp-chk-gds.b-code = buf_chk-gds.b-code
      temp-chk-gds.price-base = buf_chk-gds.price-base
      temp-chk-gds.qnty = temp-chk-gds.qnty  + buf_chk-gds.DOC-qnty
      temp-chk-gds.sum  = temp-chk-gds.sum  + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt + buf_chk-gds.price-service)
      temp-chk-gds.sum-change = temp-chk-gds.sum
      temp-chk-gds.gds-type =  (if buf_chk-gds.pump > 0
                                then 1
                                else 2)
      jjo = jjo + (if buf_chk-gds.pump > 0
                   then 0
                   else 1)
      jjp = jjp + (if buf_chk-gds.pump > 0
                   then 1
                   else 0)
      temp-chk-gds.jjp_  = (if buf_chk-gds.pump > 0
                           then jjp
                           else 0)
      temp-chk-gds.jjo_  = (if buf_chk-gds.pump > 0
                            then 0
                            else jjo)
      .
    end. /*неотмена*/
  END. /* FOR EACH buf_chk-gds No-LOCK WHERE */
  /*  if not available temp-chk-gds then NEXT _chk-doc.*/
end. /*if first-of buf_CHK-pay.DOC-CODE*/

FIND FIRST buf_cash-pay No-LOCK WHERE
          buf_cash-pay.cdpay-code = buf_chk-pay.pay-code AND
          buf_cash-pay.curr-code = buf_chk-pay.curr-code No-ERROR.


if available buf_cash-pay then do:
  find first temp-chk-pay use-index pi where
          temp-chk-pay.line-num = buf_chk-pay.line-num no-error.
  if not available temp-chk-pay then do:
    create temp-chk-pay.
  end.
  buffer-copy buf_chk-pay to temp-chk-pay
  assign
  temp-chk-pay.pet-good = integer(buf_cash-pay.atr64) * 2 + integer( buf_cash-pay.is-cash)
  temp-chk-pay.obj-name = buf_cash-pay.obj-name
  temp-chk-pay.is-cash  = buf_cash-pay.is-cash
  .
end.

if last-of(buf_chk-pay.doc-code) then do:
  for each temp-chk-pay where
          temp-chk-pay.doc-code = buf_chk-pay.doc-code
  by temp-chk-pay.pet-good descending
  by temp-chk-pay.line-num:

    assign
    dop-sump = (if v-curr-r-b = 'rubl':U then temp-chk-pay.tot-rubl else temp-chk-pay.tot-base)
    .
    _repeat:
    REPEAT WHILE  abs(dop-sump) > 0 :
      if dop-sumg = 0 then do:
        assign
        kk = kk + 1
        .
        if kk >= jj then LEAVE _repeat.
        if kk <= jjp then
        find first temp-chk-gds where
                  temp-chk-gds.doc-code = buf_chk-doc.doc-code
            AND  temp-chk-gds.jjp_ = kk no-error .
        else
        find first temp-chk-gds where
                  temp-chk-gds.doc-code = buf_chk-doc.doc-code
            AND  temp-chk-gds.jjo_ = kk - jjp no-error .
        if not available temp-chk-gds or temp-chk-gds.sum = 0 then do:
          NEXT _repeat.
        end.
        assign
        dop-sumg = temp-chk-gds.sum
        .
        /*
        if available temp-chk-gds then
        put unformatted "find kk=" kk  " " temp-chk-gds.b-code " " temp-chk-gds.jjp_ " " temp-chk-gds.jjo_ skip.
        else put unformatted "not find kk=" kk skip.
        */
      end. /*if dop-sumg = 0 then do:*/
      /*
      put unformatted "pay-code=" {&temp}chk-pay.pay-code " " temp-chk-gds.b-code skip  "pay-sum=" pay-sum "  dop-sump=" dop-sump " dop-sumg=" dop-sumg
      skip.
      */
      assign
      dop-sumk = min(abs(dop-sumg), abs(dop-sump))  * (if dop-sump > 0 then 1 else -1 ) /*квант*/
      pay-sum = pay-sum - dop-sumk
      dop-sump = dop-sump - dop-sumk
      dop-sumg = dop-sumg - dop-sumk
      .
      /*
      put unformatted "pay-sum=" pay-sum "  dop-sump=" dop-sump " dop-sumg=" dop-sumg " dop-sumk=" dop-sumk skip.
      */
            /*--------------------------------------родим запись таблицы----------------------------------*/
      FIND FIRST buf_bar-code No-LOCK WHERE
               buf_bar-code.b-code =  temp-chk-gds.b-code No-ERROR.
      IF NOT AVAIL buf_bar-code then NEXT _repeat.
      FIND FIRST buf_treal-3 No-LOCK WHERE
                buf_treal-3.gds-code = buf_bar-code.gds-code
            AND buf_treal-3.cpay-code = temp-chk-pay.pay-code
            AND buf_treal-3.curr-code = temp-chk-pay.curr-code
            AND buf_treal-3.d-card = temp-chk-pay.pay-card No-ERROR.
      IF NOT AVAIL  buf_treal-3 then do:
        FIND last b3-treal-3 No-LOCK WHERE
                  b3-treal-3.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
        create buf_treal-3.
        assign
        buf_treal-3.gds-code = buf_bar-code.gds-code
        buf_treal-3.cpay-code = temp-chk-pay.pay-code
        buf_treal-3.curr-code = temp-chk-pay.curr-code
        buf_treal-3.price-base = temp-chk-gds.price-base
        buf_treal-3.rec-type = temp-chk-gds.GDS-type
        buf_treal-3.d-card  = temp-chk-pay.pay-card
        buf_treal-3.line-num = temp-chk-pay.line-num
        buf_treal-3.ii  = (if avail b3-treal-3
                          then b3-treal-3.ii + 1
                          else 1)
        .
      END.
      assign
      buf_treal-3.netto = buf_treal-3.netto + dop-sumk
      buf_treal-3.qnty1 = buf_treal-3.qnty1 + temp-chk-gds.qnty * (dop-sumk / temp-chk-gds.sum)
      .
      /*--------------------записали в нужную таблицу квант товар-оплата--------------------------*/
      /*если покрылась вся сумма перейдем к следующему товару*/
      if dop-sumg <= 0 then do:
        assign
        kk = kk + 1.
        if kk >= jj then LEAVE _repeat.

        if kk <= jjp then do:
          find first temp-chk-gds where
                    temp-chk-gds.doc-code = buf_chk-doc.doc-code
              AND  temp-chk-gds.jjp_ = kk no-error .
        end.
        else do:
          find first temp-chk-gds where
                    temp-chk-gds.doc-code = buf_chk-doc.doc-code
              AND  temp-chk-gds.jjo_ = kk - jjp no-error .
          if not available temp-chk-gds then do:
            /*
            put unformatted "niz not find kk=" kk skip.
            */
            LEAVE _repeat.
          end.
        end.
        dop-sumg = temp-chk-gds.sum.
        /*
        if available temp-chk-gds then
        put unformatted "niz find kk=" kk " "   temp-chk-gds.b-code " " temp-chk-gds.jjp_ " " temp-chk-gds.jjo_ skip.
        */
        dop-sumg = temp-chk-gds.sum.
        /*
        put unformatted "miz dop-sumg=" dop-sumg skip.
        */
      end. /*if dop-sumg <= 0 then do:*/

    END. /*REPEAT - раскидывание одной оплаты*/
  end. /*for each temp-chk-pay where
         temp-chk-pay.doc-code = chk-pay.doc-code*/
end. /*if last-of buf_chk-pay.doc-code*/