block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mig_0041.p $
$Archive: utl/mig_0041.p $

Модификация таблиц  раздела ДК

Автор: Чернова Светлана Александровна
Дата создания: 12/08/08
Author: Svetlana Chernova
Creation date: 12/08/08

*/

using Ibs.Th.Gbl.ProgressBar.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0041.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0041.p $":U .
define variable vss-description as character no-undo init "Модификация таблиц раздела Клиенты".

{ cmp/vssrevis.i    }
{ utl/mig_0001.i    }
{ rep/prg-bar.i def }
{ rep/prg-bar.i run }


define variable v-progress-bar as class ProgressBar no-undo .
run prg-bar_init-cb-handle in this-procedure ( this-procedure ) .
define variable v-tot-rec as int64 no-undo .


run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("ДК") ).

{ utl/mig_0040.i "shared" }

define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_c-dis-obj for ub.c-dis-obj.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_c-dis-host for ub.c-dis-host.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_shop for ub.shop.
on write of ub.dis-host override do: end.
on delete of ub.dis-card override do: end.
on delete of ub.dis-host override do: end.
on delete of ub.dis-obj override do: end.
on delete of ub.dis-card-property override do: end.
on delete of ub.c-dis-host override do: end.
on delete of ub.c-dis-obj override do: end.
on delete of ub.c-dis-card-property override do: end.
on delete of ub.dis-card-type override do: end.
on delete of ub.dis-card-type-attr override do: end.
on delete of ub.dis-dct-rule override do: end.
on delete of ub.c-dis-dct-rule override do: end.
on delete of ub.dis-card-mask override do: end.
on delete of ub.c-dis-card-type override do: end.
on delete of ub.c-dis-card-type-attr override do: end.
on delete of ub.c-dis-card-mask override do: end.
on write of ub.trn-doc override do: end.
on delete of ub.hist-nws-option override do: end.
on delete of ub.c-hist-nws-option override do: end.
on delete of ub.rp-by-call override do: end.
on delete of ub.c-rp-by-call override do: end.
on delete of ub.rule-by-call override do: end.
on delete of ub.c-rule-by-call override do: end.
on delete of ub.rule-call-param override do: end.
on delete of ub.c-rule-call-param override do: end.
on delete of ub.prop-ref-call override do: end.


  do
  on error undo, return error return-value
  :
  v-tot-rec = 0 .
  for each buf_dis-card no-lock where
    v-tot-rec = v-tot-rec + 1.
  end.

  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Обработка таблицы ДК...":U).
  run prg-bar_show in this-procedure .

  for each buf_dis-card no-lock:
    run prg-bar_increment in this-procedure .
    find first buf_dis-host no-lock where
              buf_dis-host.d-card = buf_dis-card.d-card
          and buf_dis-host.host-code = 0
          and buf_dis-host.dt-code = 0
          no-error .
    if not available buf_dis-host then do:
      run create-dis-host-0 in this-procedure ( input buf_dis-card.d-card, input buf_dis-card.card-num) no-error .
      if error-status :error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("err ДК&2 - &1 &3", error-status :get-message(1) , buf_Dis-card.d-card, return-value  )).
              run prg-bar_delete-progress-bar in this-procedure .
          return .
      end.
    end.
  end.

  v-tot-rec = 0 .
  for each ub.sysconf no-lock :
    v-tot-rec = v-tot-rec + 1.
  end.
  for each  ub.staff no-lock :
    v-tot-rec = v-tot-rec + 1.
  end.

  run prg-bar_delete-progress-bar in this-procedure .

  v-tot-rec = 0 .
  for each temp-clients where
           temp-clients.obj-type = {&shop}
       and temp-clients.obj-type = {&stock}
          :
    v-tot-rec = v-tot-rec + 1.
  end.
  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Определение базовых валют удаляемых объектов и фирм...":U).
  run prg-bar_show in this-procedure .

  /*найдем баз вал и new-issue-code*/
  for each temp-clients where
          temp-clients.obj-type = {&shop}:

    run prg-bar_increment in this-procedure .

    find first buf_sysconf no-lock where
              buf_sysconf.host-code = temp-clients.host-code no-error.
    if not available buf_sysconf then do:
      find first temp-sysconf no-lock where
                temp-sysconf.host-code = temp-clients.host-code.
      assign
      temp-clients.base-code = temp-sysconf.base-code.
    end.
    else do:
      assign
      temp-clients.base-code = buf_sysconf.base-code.
    end.
    for each buf_shop no-lock,
           first buf_sysconf no-lock where
               buf_sysconf.host-code = buf_shop.host-code
           and buf_sysconf.base-code = temp-clients.base-code :
      leave.
    end.
    if not available buf_shop then do:
      find first buf_shop.
    end.
    assign
    temp-clients.new-issue-code = buf_shop.obj-code.
  end.

  /*найдем баз вал и new-issue-code*/
  for each temp-clients where
          temp-clients.obj-type = {&stock}:
    run prg-bar_increment in this-procedure .
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = temp-clients.host-code no-error.
    if not available buf_sysconf then do:
      find first temp-sysconf no-lock where
                temp-sysconf.host-code = temp-clients.host-code.
      assign
      temp-clients.base-code = temp-sysconf.base-code.
    end.
    else do:
      assign
      temp-clients.base-code = buf_sysconf.base-code.
    end.
  end.

  run prg-bar_delete-progress-bar in this-procedure .

  v-tot-rec = 0 .
  for each temp-sysconf   :
    v-tot-rec = v-tot-rec + 1.
  end.

  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Обработка НЕглобальных ДК (по удаляемым фирмам)...":U).
  run prg-bar_show in this-procedure .


  for each temp-sysconf no-lock  :
    for each temp-clients where
            temp-clients.host-code = temp-sysconf.host-code:
      assign
      temp-clients.deleted-sysconf = yes.
    end.

    /*удаление фирменных карт*/
    run delete-sysconf-dc in this-procedure ( input temp-sysconf.host-code) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("delete-sysconf-dc - host-code = &1 &2"
                            , temp-sysconf.host-code
                            , error-status :get-message(1) )).
      return .
    end.

    find first buf_sysconf no-lock where buf_sysconf.base-code = temp-sysconf.base-code no-error.
    if not available buf_sysconf then do:
      find first buf_sysconf no-lock.
    end.
    for each buf_dis-host share-lock where
            buf_dis-host.host-code = temp-sysconf.host-code,
        first buf_dis-card no-lock where
              buf_Dis-card.d-card = buf_dis-host.d-card:
      if buf_dis-host.dt-code = 0 then do:
        run create-dh-sum-record in this-procedure (
                                                    input buf_sysconf.host-code
                                                  ,input temp-sysconf.base-code
                                                  ,input buf_sysconf.base-code
                                                  ,buffer buf_Dis-host
                                                  ,buffer buf_dis-card) no-error.
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("create-dh-sum-record err - d-card=&1 host-code = &2 &3"
                                , buf_dis-card.d-card
                                , temp-sysconf.host-code
                                , error-status :get-message(1) )).
          return .
        end.
      end.
      delete buf_Dis-host.
      for each buf_c-dis-host share-lock where
            buf_c-dis-host.d-card = buf_Dis-host.d-card
        and buf_c-dis-host.host-code = temp-sysconf.host-code
        and buf_c-dis-host.dt-code = buf_Dis-host.dt-code
        :
        delete buf_c-dis-host.
      end.
    end.
    delete temp-sysconf.
    run prg-bar_increment in this-procedure .
  end. /*  for each temp-sysconf no-lock  :*/

  run prg-bar_delete-progress-bar in this-procedure .

  v-tot-rec = 0 .
  for each temp-clients   :
    v-tot-rec = v-tot-rec + 1.
  end.

  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Обработка ДК (по удаляемым объектам)...":U).
  run prg-bar_show in this-procedure .


  for each temp-clients:
    find first buf_sysconf no-lock where buf_sysconf.base-code = temp-clients.base-code no-error.
    if not available buf_sysconf then do:
      find first buf_sysconf no-lock.
    end.

    for each buf_dis-obj share-lock where
            buf_dis-obj.obj-type = temp-clients.obj-type
        and buf_dis-obj.obj-code = temp-clients.obj-code,
        first buf_dis-card no-lock where
              buf_Dis-card.d-card = buf_dis-obj.d-card  :
      if not temp-clients.deleted-sysconf then do:
        if buf_dis-obj.dt-code = 0 then do:
          run create-do-sum-record in this-procedure (
                                                      input buf_sysconf.host-code
                                                    ,input temp-clients.base-code
                                                    ,input buf_sysconf.base-code
                                                    ,buffer buf_Dis-obj
                                                    ,buffer buf_dis-card) no-error.
          if error-status:error then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute("create-do-sum-record err - d-card=&1 &2&3 &4"
                                  , buf_dis-card.d-card
                                  , temp-clients.obj-type
                                  , temp-clients.obj-code
                                  , error-status :get-message(1) )).
            return .
          end.
        end.
      end.
      for each buf_c-dis-obj share-lock where
            buf_c-dis-obj.d-card = buf_Dis-obj.d-card
        and buf_c-dis-obj.obj-type = temp-clients.obj-type
        and buf_c-dis-obj.obj-code = temp-clients.obj-code:
        delete buf_c-dis-obj.
      end.
      delete buf_Dis-obj.
    end.
    if temp-clients.obj-type = {&shop} then do:
      run rename-issue-code in this-procedure ( input temp-clients.obj-code) no-error .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("rename-issue-code err - d-card=&1 &2", buf_dis-card.d-card, error-status :get-message(1) )).
        return .
      end.
    end.
    run prg-bar_increment in this-procedure .
  end. /*for each temp-clients*/

  run prg-bar_delete-progress-bar in this-procedure .

  v-tot-rec = 0 .
  for each buf_sysconf   :
    v-tot-rec = v-tot-rec + 1.
  end.

  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Обработка ДК - создание записей платежей...":U).
  run prg-bar_show in this-procedure .


  for each buf_sysconf no-lock
  :

    for each buf_dis-host no-lock where
            buf_dis-host.host-code = buf_sysconf.host-code,
        first buf_dis-card no-lock where
              buf_Dis-card.d-card = buf_dis-host.d-card
    :
      if buf_dis-host.dt-code = 0 then do:
        run create-dh-sum-record in this-procedure (
                                                    input buf_sysconf.host-code
                                                  ,input buf_sysconf.base-code
                                                  ,input buf_sysconf.base-code
                                                  ,buffer buf_Dis-host
                                                  ,buffer buf_dis-card) no-error.
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("create-dh-sum-record err - d-card=&1 host-code=&2 &3"
                                , buf_dis-card.d-card
                                , buf_sysconf.host-code
                                , error-status :get-message(1) )).
          return .
        end.
      end.
    end.
    run prg-bar_increment in this-procedure .
  end. /*for each buf_sysconf no-lock*/
  run prg-bar_delete-progress-bar in this-procedure .

end.

procedure create-do-sum-record :
define input parameter p-host-code as integer no-undo . /*код фирмы которая не удаляется - первая попавшаяся*/
define input parameter p-old-base-code as integer no-undo .
define input parameter p-base-code as integer no-undo . /*код валюты фирмы, которой принадлежит удаляемый объект*/
define parameter buffer buf_dis-obj for ub.dis-obj.
define parameter buffer buf_dis-card for ub.dis-card.

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-source-ref as character no-undo .
define variable v-exch-rate as decimal no-undo .
define variable v-exch-scale as integer no-undo .
define variable v-curr-abbr as character no-undo .
define buffer buf_payment for ub.payment.


do
on error undo, return error return-value
:
    run cur-time in this-procedure ( output v-today, output v-time).
    v-source-ref = substitute('&1&2-&3'
                            , buf_dis-obj.obj-type
                            , buf_dis-obj.obj-code
                            , string(v-today, '99/99/9999')
                            ).
    find first buf_payment where
            buf_payment.host-code = p-host-code
        and buf_payment.d-card = buf_dis-obj.d-card
        and buf_payment.source-type = ''
        and buf_payment.source-ref = v-source-ref
        and buf_payment.status_ = {&fact}
        and buf_payment.fact-date = v-today
        no-error.
    if not available buf_payment then do:
      create buf_payment.
      assign
      buf_payment.host-code = p-host-code
      buf_payment.d-card = buf_dis-obj.d-card
      buf_payment.source-type = ''
      buf_payment.source-ref = v-source-ref
      buf_payment.fact-date = v-today
      buf_payment.base-scale = 1
      buf_payment.cli-code = buf_Dis-card.cli-code
      buf_payment.cli-type = buf_Dis-card.cli-type
      buf_payment.closid = userid("ub")
      buf_payment.creid = userid("ub")
      buf_payment.due-date = v-today
      buf_payment.exch-code = p-old-base-code
      buf_payment.exch-date = v-today
      buf_payment.exch-scale = 1
      buf_payment.pay-code = 1
      buf_payment.payer-type = buf_Dis-card.cli-type
      buf_payment.payer-code = buf_Dis-card.cli-code
      buf_payment.pmnt-code = string(next-value(s-pmnt-code, {&db-name_schema}))
      buf_payment.ps = ''
      buf_payment.status_ =  {&fact}
      .
    end.
    { gbl/exchrate.i p-old-base-code v-today v-exch-rate v-exch-scale v-curr-abbr }
    assign
    buf_payment.tot-base = buf_payment.tot-base + (if buf_dis-card.credit-card
                                                  then buf_dis-obj.pay-tot-base
                                                  else (buf_dis-obj.gds-tot-base - buf_dis-obj.gds-dis-base)
                                                  )
    buf_payment.tot-rubl = buf_payment.tot-rubl + (if buf_dis-card.credit-card
                                                  then buf_dis-obj.pay-tot-rubl
                                                  else (buf_dis-obj.gds-tot-rubl - buf_dis-obj.gds-dis-rubl)
                                                  )
    buf_payment.tot-cli  = (if p-old-base-code = 0 then buf_payment.tot-rubl else buf_payment.tot-base)
    buf_payment.tot-base = (if p-old-base-code = p-base-code then buf_payment.tot-base else buf_payment.tot-rubl / v-exch-rate * v-exch-scale)
    buf_payment.base-rate = (if p-old-base-code = 0 then 1 else buf_payment.tot-rubl / buf_payment.tot-base)
    buf_payment.exch-rate = (if p-old-base-code = 0 then 1 else buf_payment.tot-rubl / buf_payment.tot-base)
    .
end.

end procedure. /* create-sum-record */

procedure create-dh-sum-record :
define input parameter p-host-code as integer no-undo . /*код фирмы которая не удаляется - первая попавшаяся*/
define input parameter p-old-base-code as integer no-undo .
define input parameter p-base-code as integer no-undo . /*код валюты фирмы, которая удаляется*/
define parameter buffer buf_dis-host for ub.dis-host.
define parameter buffer buf_dis-card for ub.dis-card.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-source-ref as character no-undo .
define variable v-exch-rate as decimal no-undo .
define variable v-exch-scale as integer no-undo .
define variable v-curr-abbr as character no-undo .

define buffer buf_payment for ub.payment.

do
on error undo, return error return-value
:
    run cur-time in this-procedure ( output v-today, output v-time).
    v-source-ref = substitute('&1&2-&3'
                            , {&cmp}
                            , buf_dis-host.host-code
                            , string(v-today, '99/99/9999')
                            ).
    find first buf_payment where
            buf_payment.host-code = p-host-code
        and buf_payment.d-card = buf_dis-host.d-card
        and buf_payment.source-type = ''
        and buf_payment.source-ref = v-source-ref
        and buf_payment.status_ = {&fact}
        and buf_payment.fact-date = v-today
        no-error.
    if not available buf_payment then do:
      create buf_payment.
      assign
      buf_payment.host-code = p-host-code
      buf_payment.d-card = buf_dis-host.d-card
      buf_payment.source-type = ''
      buf_payment.source-ref = v-source-ref
      buf_payment.fact-date = v-today
      buf_payment.base-scale = 1
      buf_payment.cli-code = buf_Dis-card.cli-code
      buf_payment.cli-type = buf_Dis-card.cli-type
      buf_payment.closid = userid("ub")
      buf_payment.creid = userid("ub")
      buf_payment.due-date = v-today
      buf_payment.exch-code = p-old-base-code
      buf_payment.exch-date = v-today
      buf_payment.exch-scale = 1
      buf_payment.pay-code = 1
      buf_payment.payer-type = buf_Dis-card.cli-type
      buf_payment.payer-code = buf_Dis-card.cli-code
      buf_payment.pmnt-code = string(next-value(s-pmnt-code, {&db-name_schema}))
      buf_payment.ps = ''
      buf_payment.status_ =  {&fact}
      .
    end.
    { gbl/exchrate.i p-old-base-code v-today v-exch-rate v-exch-scale v-curr-abbr }
    assign
    buf_payment.tot-base = buf_payment.tot-base + (if buf_dis-card.credit-card
                                                  then buf_dis-host.pay-tot-base
                                                  else (buf_dis-host.gds-tot-base - buf_dis-host.gds-dis-base)
                                                  )
    buf_payment.tot-rubl = buf_payment.tot-rubl + (if buf_dis-card.credit-card
                                                  then buf_dis-host.pay-tot-rubl
                                                  else (buf_dis-host.gds-tot-rubl - buf_dis-host.gds-dis-rubl)
                                                  )
    buf_payment.tot-cli  = (if p-old-base-code = 0 then buf_payment.tot-rubl else buf_payment.tot-base)
    buf_payment.tot-base = (if p-old-base-code = p-base-code then buf_payment.tot-base else buf_payment.tot-rubl / v-exch-rate * v-exch-scale)
    buf_payment.base-rate = (if p-old-base-code = 0 then 1 else buf_payment.tot-rubl / buf_payment.tot-base)
    buf_payment.exch-rate = (if p-old-base-code = 0 then 1 else buf_payment.tot-rubl / buf_payment.tot-base)
    .
end.

end procedure. /* create-sum-record */

procedure delete-sysconf-dc :
/*удаление фирменных карт*/
define input parameter p-host-code as integer no-undo .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_c-dis-card-property for ub.c-dis-card-property.
define buffer buf_c-dis-host for ub.c-dis-host.
define buffer buf_c-dis-obj for ub.c-dis-obj.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-type-attr for ub.dis-card-type-attr.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_c-dis-dct-rule for ub.c-dis-dct-rule.
define buffer buf_dis-card-mask for ub.dis-card-mask.
define buffer buf_c-dis-card-type for ub.c-dis-card-type.
define buffer buf_c-dis-card-type-attr for ub.c-dis-card-type-attr.
define buffer buf_c-dis-card-mask for ub.c-dis-card-mask.
define buffer buf_clients for ub.clients.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule.
define buffer buf_hist-nws-option for ub.hist-nws-option.
define buffer buf_c-hist-nws-option for ub.c-hist-nws-option.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_c-rp-by-call for ub.c-rp-by-call.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_c-rule-by-call for ub.c-rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_c-rule-call-param for ub.c-rule-call-param.
define buffer buf_prop-ref-call for ub.prop-ref-call.


do
on error undo, return error
:
  find first buf_dis-card-type no-lock where
            buf_dis-card-type.emitent-host-code = p-host-code no-error.
  if not available buf_dis-card-type then return.

  for each buf_dis-card share-lock where
         buf_Dis-card.emitent-host-code = p-host-code:

    for each buf_Dis-card-property share-lock where
            buf_dis-card-property.d-card = buf_Dis-card.d-card :
      delete buf_dis-card-property.
    end.
    for each buf_c-Dis-card-property share-lock where
            buf_c-dis-card-property.d-card = buf_Dis-card.d-card :
      delete buf_c-dis-card-property.
    end.
    for each buf_Dis-obj share-lock where
            buf_dis-obj.d-card = buf_Dis-card.d-card :
      delete buf_dis-obj.
    end.
    for each buf_c-Dis-obj share-lock where
            buf_c-dis-obj.d-card = buf_Dis-card.d-card :
      delete buf_c-dis-obj.
    end.
    for each buf_Dis-host share-lock where
            buf_dis-host.d-card = buf_Dis-card.d-card :
      delete buf_dis-host.
    end.
    for each buf_c-Dis-host share-lock where
            buf_c-dis-host.d-card = buf_Dis-card.d-card :
      delete buf_c-dis-host.
    end.
    for each buf_dis-dc-rule share-lock where
            buf_dis-dc-rule.d-card = buf_Dis-card.d-card :
      delete buf_dis-dc-rule.
    end.
    for each buf_c-dis-dc-rule share-lock where
            buf_c-dis-dc-rule.d-card = buf_Dis-card.d-card :
      delete buf_c-dis-dc-rule.
    end.
    for each buf_clients no-lock where
           buf_clients.host-code = p-host-code:
       for each buf_trn-doc no-lock where
                buf_trn-doc.obj-type = buf_Clients.obj-type
            and buf_trn-doc.obj-code = buf_Clients.obj-code
            and buf_trn-doc.cli-type = buf_dis-card.cli-type
            and buf_trn-doc.cli-code = buf_dis-card.cli-code:
         if buf_trn-doc.d-card = buf_dis-card.d-card then do:
           buf_trn-doc.d-card = ''.
         end.
       end.
    end.
    delete buf_Dis-card.
  end.
  for each buf_Dis-card-type share-lock where
          buf_Dis-card-type.emitent-host-code = p-host-code:
    for each buf_Dis-card-type-attr share-lock where
            buf_Dis-card-type-attr.emitent-host-code = p-host-code
        and buf_Dis-card-type-attr.type = buf_dis-card-type.type
            :
       delete buf_dis-card-type-attr.
    end.
    for each buf_Dis-card-mask share-lock where
            buf_Dis-card-mask.emitent-host-code = p-host-code
        and buf_Dis-card-mask.type = buf_dis-card-type.type
            :
       delete buf_dis-card-mask.
    end.
    for each buf_Dis-dct-rule share-lock where
            buf_Dis-dct-rule.emitent-host-code = p-host-code
        and buf_Dis-dct-rule.type = buf_dis-card-type.type
            :
       delete buf_dis-dct-rule.
    end.
    for each buf_c-Dis-dct-rule share-lock where
            buf_c-Dis-dct-rule.emitent-host-code = p-host-code
        and buf_c-Dis-dct-rule.type = buf_dis-card-type.type
            :
       delete buf_c-dis-dct-rule.
    end.
    for each buf_hist-nws-option share-lock where
            buf_hist-nws-option.subject-group = {&table_c-dc-hist}
        and buf_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
        and buf_hist-nws-option.charkey_one = buf_dis-card-type.type:
     delete buf_hist-nws-option.
    end.
    for each buf_c-hist-nws-option share-lock where
            buf_c-hist-nws-option.subject-group = {&table_c-dc-hist}
        and buf_c-hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
        and buf_c-hist-nws-option.charkey_one = buf_dis-card-type.type:
     delete buf_c-hist-nws-option.
    end.
    for each  buf_rp-by-call share-lock where
            buf_rp-by-call.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_rp-by-call.
    end.
    for each  buf_c-rp-by-call share-lock where
            buf_c-rp-by-call.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_c-rp-by-call.
    end.
    for each  buf_rule-by-call share-lock where
            buf_rule-by-call.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_rule-by-call.
    end.
    for each  buf_c-rule-by-call share-lock where
            buf_c-rule-by-call.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_c-rule-by-call.
    end.
    for each  buf_rule-call-param share-lock where
            buf_rule-call-param.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_rule-call-param.
    end.
    for each  buf_c-rule-call-param share-lock where
            buf_c-rule-call-param.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_c-rule-call-param.
    end.
    for each  buf_prop-ref-call share-lock where
            buf_prop-ref-call.call_id = buf_dis-card-type.uniq-key-rec:
      delete buf_prop-ref-call.
    end.
    delete buf_dis-card-type.
  end.

end.

end procedure. /* delete-sysconf-dc */

procedure rename-issue-code :
define input parameter p-obj-code as integer no-undo .
define buffer buf_dis-card for ub.dis-card.
on write of ub.dis-card override do: end.

do
on error undo, return error
:
  for each buf_dis-card share-lock:
    if can-find(first temp-clients no-lock where
                    temp-clients.obj-type = {&shop}
                and temp-clients.obj-code = buf_dis-card.issue-code) then do:
      assign
      buf_dis-card.issue-code = temp-clients.new-issue-code.
    end.
  end.
end.

end procedure. /* rename-issue-code */


define temp-table tt-dis-host no-undo like ub.dis-host.

procedure create-dis-host-0 :
define input parameter p-d-card like ub.dis-card.d-card no-undo .
define input parameter p-card-num like ub.dis-card.card-num no-undo .
define buffer buf_dis-host for ub.dis-host.

  do
  on error undo, return error return-value
  :
    if available tt-dis-host then delete tt-dis-host.
    create tt-dis-host.
    assign
    tt-dis-host.d-card = p-d-card
    tt-dis-host.card-num = p-card-num
    tt-dis-host.dt-code = 0
    .
    for each buf_Dis-host no-lock where
          buf_dis-host.d-card = p-d-card
      and buf_dis-host.host-code > 0
      on error undo, return error
      on stop undo, return error :
      assign
      tt-dis-host.gds-dis-base = tt-dis-host.gds-dis-base + buf_dis-host.gds-dis-base
      tt-dis-host.gds-dis-rubl = tt-dis-host.gds-dis-rubl + buf_dis-host.gds-dis-rubl
      tt-dis-host.gds-tot-base = tt-dis-host.gds-tot-base + buf_dis-host.gds-tot-base
      tt-dis-host.gds-tot-rubl = tt-dis-host.gds-tot-rubl + buf_dis-host.gds-tot-rubl
      tt-dis-host.num-chk      = tt-dis-host.num-chk      + buf_dis-host.num-chk
      tt-dis-host.pay-tot-base = tt-dis-host.pay-tot-base + buf_dis-host.pay-tot-base
      tt-dis-host.pay-tot-rubl = tt-dis-host.pay-tot-rubl + buf_dis-host.pay-tot-rubl
      .
    end.
    create buf_Dis-host.
    buffer-copy tt-dis-host to buf_dis-host.
    release buf_dis-host.
    delete tt-dis-host.
  end. /*doe*/

end procedure. /* create-dis-host-0 */