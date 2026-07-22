block-level on error undo, throw.
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
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
if lookup(p-source-type, ('заказ':U + chr(4) +
                          'платеж':U + chr(4) +
                          '':U + chr(4) +
                          'касс':U + chr(4) +
                          'накл':U + chr(4) +
                          'платеж':U + chr(4) +
                          'inkas':U + chr(4) +
                          'trn-doc':U + chr(4) +
                          ('trn-doc':U + chr(44) + 'import':U) + chr(4) +
                          ('inkas':U + chr(44) + 'import':U)
                          ), chr(4) ) = 0
then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-source-type - " p-source-type
  view-as alert-box error .
  return error '':u.
end.
case p-source-type:
  when 'inkas':U
  then do:
    p-source-type = 'касс':U.
  end.
  when 'trn-doc':U then do:
    p-source-type = 'накл':U.
  end.
  when ('inkas':U + chr(44) + 'import':U) then do:
    p-source-type = 'касс':U + chr(44) + 'import':U.
  end.
  when ('trn-doc':U + chr(44) + 'import':U) then do:
    p-source-type = 'накл':U + chr(44) + 'import':U.
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
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    if p-source-type = 'платеж':U then do:
      if entry(1, p-pmnt-code, "_") = '':U then do:
        v-pmnt-code = string(next-value(s-pmnt-code, ub)).
      end.
      else do:
        v-pmnt-code = entry(1, p-pmnt-code, "_").
      end.
    end.
    else do:
      v-pmnt-code = string(next-value(s-pmnt-code, ub)).
    end.
    if p-source-type = 'платеж':U then do:
      v-pmnt-code = substitute("&1_&2", v-pmnt-code, entry(2, p-pmnt-code, "_")).
    end.
    if can-find(first ub.payment where ub.payment.pmnt-code = v-pmnt-code) then do:
      assign
      v-mess = substitute("Не удается создать запись платежа с кодом &1&2"  +
                          "Платеж с таким кодом уже есть в БД"
                        , v-pmnt-code
                        , chr(10)
                        ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    END.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_payment exclusive-lock where
             buf_payment.pmnt-code = p-pmnt-code.
    v-pmnt-code = buf_payment.pmnt-code.
    if buf_payment.status_ = 'факт':U
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
  or (buf_clients.obj-type = 'скл':U
      OR
      buf_clients.obj-type = 'маг':U
      )
  or (buf_clients.obj-type = 'орг':U
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
  if lookup(p-source-type, ('касс':U + chr(4) +
                           'заказ':U + chr(4) +
                           'накл':U + chr(4) +
                           'касс':U + chr(4) +
                           'платеж':U + chr(4) +
                           'касс':U + chr(44) + 'import':U + chr(4) +
                           'накл':U + chr(44) + 'import':U + chr(4) +
                           '':U)
                         , chr(4)
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
    when 'заказ':U then do:
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
                    ,chr(10)
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
                    ,chr(10)
                    ,p-host-code
                    ,buf_ord-doc.host-code
                    ).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'source-ref':U).
      end.
      if NOT (buf_ord-doc.status_ = 'факт':U
              and buf_ord-doc.flag_ = yes) then do:
        assign
        v-mess =  substitute("Нельзя создать платеж&1" +
                      "для заказа в статусе &2"
                      , chr(10)
                      ,(buf_ord-doc.status_ + string(buf_ord-doc.flag_, "+/-"))
                      ).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'source-ref':U).
      end.
      assign
      for-sign = (if (buf_ord-doc.doc-type = 'при':U)
                  then 1
                  else -1).
    end.
    when 'касс':U
    or
    when ('касс':U + chr(44) + 'import':U)
    or
    when 'накл':U
    or
    when ('накл':U + chr(44) + 'import':U)
    or
    when '':U
    or
    when 'платеж':U
    then do:
      case p-source-type:
        when '':U
        or
        when 'платеж':U
        then do:
          if p-source-type = '':U then do:
            for-sign = 1.
          end.
          if p-source-type = 'платеж':U then do:
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
                          ,chr(10)
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
                          ,chr(10)
                          ,p-host-code
                          ,buf_dis-card.emitent-host-code
                          ).
              run err-mess in this-procedure ( input-output v-mess).
              return error (if p-silent = yes then v-mess else 'd-card':U).
            end.
            if buf_dis-card.status_ = 'блок':U
            OR buf_dis-card.status_ = 'удал':U then do:
              assign
              v-mess =  substitute("Нельзя создать платеж&1" +
                            "для карты в статусе &2"
                            ,chr(10)
                            ,buf_dis-card.status_).
              run err-mess in this-procedure ( input-output v-mess).
              return error (if p-silent = yes then v-mess else 'd-card':U).
            end.
          end.
        end.
        when 'касс':U
        or
        when ('касс':U  + chr(44) + 'import':U)
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
        when 'накл':U
        or
        when ('накл':U  + chr(44) + 'import':U)
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
  IF p-tot-cli = ? then do:
    assign
    v-mess = substitute("Сумма платежа неопределена"
                      ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'tot-cli':U).
  end.
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
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
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
  buf_payment.closid = (if p-status_ = 'факт':U then p-closid else '':U)
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
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Платеж: &1 плательщик &2&3&4&5"
                         , v-pmnt-code
                         , p-payer-type
                         , p-payer-code
                         , chr(10)
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
