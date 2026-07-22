block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: payment1.p $
$Archive: ref/payment1.p $

Создание ручного платежа - payment

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/03/07
Author: Bakhtadze Natalya
Creation date: 08/03/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-pmnt-code as character  no-undo .
define input parameter        p-cli-type as character no-undo .
define input parameter        p-cli-code as integer no-undo .
define input parameter        p-payer-type as character no-undo .
define input parameter        p-payer-code as integer no-undo .
define input parameter        p-host-code as integer no-undo .
define input parameter        p-tot-cli as decimal no-undo .
define input parameter        p-tot-base as decimal no-undo .
define input parameter        p-tot-rubl as decimal no-undo .
define input parameter        p-exch-date as date no-undo .
define input parameter        p-exch-code as integer no-undo .
define input parameter        p-exch-rate as decimal no-undo .
define input parameter        p-exch-scale as integer no-undo .
define input parameter        p-base-rate as decimal no-undo .
define input parameter        p-base-scale as integer no-undo .
define input parameter        p-due-date as date no-undo .
define input parameter        p-fact-date as date no-undo .
define input parameter        p-source-type as character no-undo .
define input parameter        p-source-ref as character no-undo .
define input parameter        p-d-card as character no-undo .
define input parameter        p-pay-code as integer no-undo .
define input parameter        p-status_ as character no-undo .
define input parameter        p-PS as character no-undo .
define input parameter        p-creid as character no-undo .
define input parameter        p-closid as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: payment1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/payment1.p $":U .
define variable vss-description as character no-undo init "Создание ручного платежа - payment".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-mess as character no-undo .
define variable v-pmnt-code as character no-undo .
define variable for-sign as integer no-undo .
define variable icount as integer no-undo .
define variable ctemp as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .

define buffer buf_obj-clients for ub.clients.
define buffer buf_payment for ub.payment.
define buffer buf_payment-attr for ub.payment-attr.
define buffer payer for ub.clients.
define buffer buf_clients for ub.clients.
define buffer buf_pay-type for ub.pay-type.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_currency for ub.currency.
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_dis-card for ub.dis-card.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
if lookup(p-source-type, ({&pmnt-ord-doc} + {&delim-par} +
                          {&pmnt-fin-doc} + {&delim-par} +
                          '':U + {&delim-par} +
                          {&pmnt-cash-desk} + {&delim-par} +
                          {&pmnt-trn-doc} + {&delim-par} +
                          {&pmnt-fin-doc} + {&delim-par} +
                          {&table_inkas} + {&delim-par} +
                          {&table_trn-doc} + {&delim-par} +
                          ({&table_trn-doc} + {&comma-char} + {&hn-source-import}) + {&delim-par} +
                          ({&table_inkas} + {&comma-char} + {&hn-source-import})
                          ), {&delim-par} ) = 0
then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-source-type - " p-source-type
  view-as alert-box error .
  return error '':u.
end.
case p-source-type:
  when {&table_inkas}
  then do:
    p-source-type = {&pmnt-cash-desk}.
  end.
  when {&table_trn-doc} then do:
    p-source-type = {&pmnt-trn-doc}.
  end.
  when ({&table_inkas} + {&comma-char} + {&hn-source-import}) then do:
    p-source-type = {&pmnt-cash-desk} + {&comma-char} + {&hn-source-import}.
  end.
  when ({&table_trn-doc} + {&comma-char} + {&hn-source-import}) then do:
    p-source-type = {&pmnt-trn-doc} + {&comma-char} + {&hn-source-import}.
  end.
end case.


if g#db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено вызывать процедуру в УБД"
  view-as alert-box error .
  return error '':u.
end.

_main:
do for buf_payment
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode = {&add-def} then do:
    if p-source-type = {&pmnt-fin-doc} then do:
      if entry(1, p-pmnt-code, "_") = '':U then do:
        v-pmnt-code = string(next-value(s-pmnt-code, {&db-name_schema})).
      end.
      else do:
        v-pmnt-code = entry(1, p-pmnt-code, "_").
      end.
    end.
    else do:
      v-pmnt-code = string(next-value(s-pmnt-code, {&db-name_schema})).
    end.
    if p-source-type = {&pmnt-fin-doc} then do:
      v-pmnt-code = substitute("&1_&2", v-pmnt-code, entry(2, p-pmnt-code, "_")).
    end.
    if can-find(first ub.payment where ub.payment.pmnt-code = v-pmnt-code) then do:
      assign
      v-mess = substitute("Не удается создать запись платежа с кодом &1&2"  +
                          "Платеж с таким кодом уже есть в БД"
                        , v-pmnt-code
                        , {&new-line}
                        ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    END.
  end. /*if-p-mode = {&add-def}*/
  if p-mode = {&update} then do:
    find first buf_payment exclusive-lock where
             buf_payment.pmnt-code = p-pmnt-code.
    v-pmnt-code = buf_payment.pmnt-code.
    if buf_payment.status_ = {&fact}
    then do:
      assign
      v-mess = substitute("Платеж находится в статусе &1, изменение невозможно"
                         , buf_payment.status_
                         ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'status_':U).
    end.
  end.
  find first buf_clients no-lock where
            buf_clients.obj-type = p-payer-type
         and buf_clients.obj-code = p-payer-code no-error.
  if not available buf_clients
  or (buf_clients.obj-type = {&stock}
      OR
      buf_clients.obj-type = {&shop}
      )
  or (buf_clients.obj-type = {&cmp}
      and
      buf_clients.obj-code = p-host-code)
  then do:
      assign
      v-mess = substitute("Неправильный код или тип клиента: &1&2"
                          , p-payer-type
                          , p-payer-code
                         ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'cli-code':U).
  end.
  find first payer no-lock where
            payer.obj-type = p-payer-type
         and payer.obj-code = p-payer-code no-error.
  if not available payer then do:
      assign
      v-mess = substitute("Неправильный код или тип плательщика: &1&2"
                          , p-payer-type
                          , p-payer-code
                         ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'payer-code':U).
  end.
  if lookup(p-source-type, ({&pmnt-cash-desk} + {&delim-par} +
                           {&pmnt-ord-doc} + {&delim-par} +
                           {&pmnt-trn-doc} + {&delim-par} +
                           {&pmnt-cash-desk} + {&delim-par} +
                           {&pmnt-fin-doc} + {&delim-par} +
                           {&pmnt-cash-desk} + {&comma-char} + {&hn-source-import} + {&delim-par} +
                           {&pmnt-trn-doc} + {&comma-char} + {&hn-source-import} + {&delim-par} +
                           '':U)
                         , {&delim-par}
            ) = 0 then do:
    assign
    v-mess = substitute("Неправильный тип первичного документа =&1"
                        , p-source-type
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'payer-code':U).
  end.
  find first buf_currency no-lock where
            buf_currency.curr-code = p-exch-code no-error.
  if not available buf_currency then do:
    assign
    v-mess = substitute("Неправильная валюта =&1"
                        , p-exch-code
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'exch-code':U).
  end.
  case p-source-type:
    when {&pmnt-ord-doc} then do:
      find first buf_pay-type no-lock where
                buf_pay-type.obj-code = p-pay-code no-error.
      if not available buf_pay-type then do:
        assign
        v-mess = substitute("Неправильный код оплаты =&1"
                            , p-pay-code
                          ).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'pay-code':U).
      end.
      find first buf_ord-doc no-lock where
                buf_ord-doc.doc-code = p-source-ref no-error.
      if not available buf_ord-doc then do:
        assign
        v-mess = substitute("Не найден заказ с N &1: первичный документ для платежа"
                            , p-source-ref ).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'source-ref':U).
      end.
      if buf_ord-doc.cli-type <> buf_clients.obj-type OR
      buf_ord-doc.cli-code <> buf_clients.obj-code then do:
        assign
        v-mess =  substitute("Неверно выбран документ для платежа:&1" +
                    "Плательщик платежа =&2&3, клиент для заказа = &4&5"
                    ,{&new-line}
                    ,buf_clients.obj-type
                    ,buf_clients.obj-code
                    ,buf_ord-doc.cli-type
                    ,buf_ord-doc.cli-code
                    ).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'source-ref':U).

      END.
      if buf_ord-doc.host-code <> p-host-code then do:
        assign
        v-mess =  substitute("Неверно выбран документ для платежа:&1" +
                    "Платеж на фирму &2, а заказ на фирму &3"
                    ,{&new-line}
                    ,p-host-code
                    ,buf_ord-doc.host-code
                    ).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'source-ref':U).
      end.
      if NOT (buf_ord-doc.status_ = {&fact}
              and buf_ord-doc.flag_ = yes) then do:
        assign
        v-mess =  substitute("Нельзя создать платеж&1" +
                      "для заказа в статусе &2"
                      , {&NEW-LINE}
                      ,(buf_ord-doc.status_ + string(buf_ord-doc.flag_, "+/-"))
                      ).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'source-ref':U).
      end.
      assign
      for-sign = (if (buf_ord-doc.doc-type = {&income})
                  then 1
                  else -1).

    end.
    when {&pmnt-cash-desk}
    or
    when ({&pmnt-cash-desk} + {&comma-char} + {&hn-source-import})
    or
    when {&pmnt-trn-doc}
    or
    when ({&pmnt-trn-doc} + {&comma-char} + {&hn-source-import})
    or
    when '':U
    or
    when {&pmnt-fin-doc}
    then do:
      case p-source-type:
        when '':U
        or
        when {&pmnt-fin-doc}
        then do:
          if p-source-type = '':U then do:
            for-sign = 1.
          end.
          if p-source-type = {&pmnt-fin-doc} then do:
            if p-source-ref begins '-':U then do:
              for-sign = -1.
            end.
            else do:
              for-sign = 1.
            end.
          end.
          if p-source-type = '':U then do:
            find first buf_pay-type no-lock where
                      buf_pay-type.obj-code = p-pay-code no-error.
            if not available buf_pay-type then do:
              assign
              v-mess = substitute("Неправильный код оплаты =&1"
                                  , p-pay-code
                                ).
              run err-mess in this-procedure ( input-output v-mess).
              return error (if p-silent = yes then v-mess else 'pay-code':U).
            end.
          end.
          if p-d-card <> '':U then do:
            FIND FIRST buf_dis-card No-LOCK WHERE
                        buf_dis-card.d-card = p-d-card NO-ERROR.
            if not avail buf_dis-card then do:
              assign
              v-mess =  substitute("Не найдена дисконтная карта с номером &1"
                            ,p-d-card).
              run err-mess in this-procedure ( input-output v-mess).
              return error (if p-silent = yes then v-mess else 'd-card':U).
            end.
            if buf_dis-card.cli-type <> buf_clients.obj-type
            OR buf_dis-card.cli-code <> buf_clients.obj-code then do:
              assign
              v-mess =  substitute("Неверно выбрана карта для платежа:&1" +
                          "Плательщик платежа =&2&3, держатель карты = &4&5"
                          ,{&new-line}
                          ,buf_clients.obj-type
                          ,buf_clients.obj-code
                          ,buf_dis-card.cli-type
                          ,buf_dis-card.cli-code
                          ).

              run err-mess in this-procedure ( input-output v-mess).
              return error (if p-silent = yes then v-mess else 'd-card':U).
            END.
            if buf_dis-card.emitent-host-code <> p-host-code
            AND buf_dis-card.emitent-host-code <> 0 then do:
              assign
              v-mess =  substitute("Неверно выбрана карта для платежа:&1" +
                          "Платеж на фирму &2, а карта фирмы &3"
                          ,{&new-line}
                          ,p-host-code
                          ,buf_dis-card.emitent-host-code
                          ).
              run err-mess in this-procedure ( input-output v-mess).
              return error (if p-silent = yes then v-mess else 'd-card':U).
            end.
            if buf_dis-card.status_ = {&blocked-status}
            OR buf_dis-card.status_ = {&deleted-status} then do:
              assign
              v-mess =  substitute("Нельзя создать платеж&1" +
                            "для карты в статусе &2"
                            ,{&NEW-LINE}
                            ,buf_dis-card.status_).
              run err-mess in this-procedure ( input-output v-mess).
              return error (if p-silent = yes then v-mess else 'd-card':U).
            end.
          end.
        end.
        when {&pmnt-cash-desk}
        or
        when ({&pmnt-cash-desk}  + {&comma-char} + {&hn-source-import})
        then do:
          find first buf_cash-pay no-lock where
                    buf_cash-pay.cdpay-code = p-pay-code
                and buf_cash-pay.curr-code = p-exch-code  no-error.
          if not available buf_cash-pay then do:
              assign
              v-mess = substitute("Неправильный код кассового платежа =&1 код валюты=&2"
                                  , p-pay-code
                                  , p-exch-code
                                ).
              run err-mess in this-procedure ( input-output v-mess).
              return error (if p-silent = yes then v-mess else 'pay-code':U).
          end.
          for-sign = (if p-tot-cli >= 0 then 1 else -1).
        end.
        when {&pmnt-trn-doc}
        or
        when ({&pmnt-trn-doc}  + {&comma-char} + {&hn-source-import})
        then do:
          find first buf_pay-type no-lock where
                    buf_pay-type.obj-code = p-pay-code no-error.
          if not available buf_pay-type then do:
            assign
            v-mess = substitute("Неправильный код оплаты =&1"
                                , p-pay-code
                              ).
            run err-mess in this-procedure ( input-output v-mess).
            return error (if p-silent = yes then v-mess else 'pay-code':U).
          end.
          for-sign = (if p-tot-cli >= 0 then 1 else -1).
        end.
      end case.
    end.
  end case.
  /*
  IF p-tot-cli = 0 then do:
    assign
    v-mess = substitute("Нельзя ввести платеж на нулевую сумму"
                      ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'tot-cli':U).
  end.
  */
  IF p-tot-cli = ? then do:
    assign
    v-mess = substitute("Сумма платежа неопределена"
                      ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'tot-cli':U).
  end.
  /*проверка корректности сумм*/
  if (for-sign > 0) NE (p-tot-cli > 0)
  and not p-tot-cli = 0
  then do:
    assign
    v-mess = substitute("Неверная сумма"
                      ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'tot-cli':U).
  end.
  if num-entries( p-PS, chr(10) ) > 1 then do:
    do icount = 1 to num-entries( p-PS, chr(10) ):
      ctemp = entry( icount, p-PS, chr(10) ).
      if index( ctemp, 'obj-type=' ) > 0 and num-entries( ctemp ) = 2 then do:
        assign
          v-obj-type = substring( entry( 1, ctemp ), index( entry( 1, ctemp ), '=' ) + 1 )
          v-obj-code = integer( substring( entry( 2, ctemp ), index( entry( 2, ctemp ), '=' ) + 1 ) )
          no-error .
        p-PS = replace( p-PS, chr(10) + ctemp, '' ).
        find first buf_obj-clients no-lock
          where buf_obj-clients.obj-type = v-obj-type
            and buf_obj-clients.obj-code = v-obj-code
          no-error .
        if not avail buf_obj-clients then do:
          assign
            v-obj-type = '':U
            v-obj-code = 0
          .
        end.
      end.
    end.
  end.

  if p-mode = {&add-def} then do:
    create buf_payment.
    assign
    buf_payment.pmnt-code = v-pmnt-code
    buf_payment.cli-type  = p-cli-type
    buf_payment.cli-code  = p-cli-code
    buf_payment.creid = p-creid
    .
  end.
  assign
  buf_payment.payer-type   = p-payer-type
  buf_payment.payer-code   = p-payer-code
  buf_payment.host-code    = p-host-code
  buf_payment.due-date     = p-due-date
  buf_payment.tot-cli      = p-tot-cli
  buf_payment.status_      = p-status_
  buf_payment.PS           = p-PS
  buf_payment.exch-date    = p-exch-date
  buf_payment.exch-code    = p-exch-code
  buf_payment.exch-rate    = p-exch-rate
  buf_payment.exch-scale   = p-exch-scale
  buf_payment.base-rate    = p-base-rate
  buf_payment.base-scale   = p-base-scale
  buf_payment.tot-base     = p-tot-base
  buf_payment.tot-rubl     = p-tot-rubl
  buf_payment.source-type  = p-source-type
  buf_payment.source-ref   = p-source-ref
  buf_payment.d-card       = p-d-card
  buf_payment.fact-date    = p-fact-date
  buf_payment.pay-code     = p-pay-code
  buf_payment.closid = (if p-status_ = {&fact} then p-closid else '':U)
  p-pmnt-code = buf_payment.pmnt-code
  .
  VALIDATE buf_payment.
  if v-obj-type <> '':U and v-obj-code <> 0 then do:
    find first buf_payment-attr no-lock
      where buf_payment-attr.pmnt-code = buf_payment.pmnt-code
        and buf_payment-attr.attr-code = "obj"
      no-error .
    if not avail buf_payment-attr then do:
      create buf_payment-attr.
      assign
        buf_payment-attr.pmnt-code = buf_payment.pmnt-code
        buf_payment-attr.attr-code = "obj"
        buf_payment-attr.attr-value = v-obj-type + ',' + string( v-obj-code )
      .
    end.
  end.

end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Платеж: &1 плательщик &2&3&4&5"
                         , v-pmnt-code
                         , p-payer-type
                         , p-payer-code
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.