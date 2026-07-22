/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18, набор 30,130

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/26/08
Author: Bakhtadze Natalya
Creation date: 05/26/08

---------------------------&start-codex_id=18;ruleset_id=30;-------------------------------
---------------------------&start-codex_id=18;ruleset_id=130;-------------------------------
События с документами продажи

---------------------------&end-codex_id=18;ruleset_id=30;-------------------------------
---------------------------&end-codex_id=18;ruleset_id=130;-------------------------------

*/


/*---------------------------&start-using-class&-------------------------------*/
using Ibs.Th.Rul.Route-data_.
block-level on error undo, throw.

/*---------------------------&end-using-class&---------------------------------*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 30,130".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ rul/ruleset_.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/gate-clb.i }
{ rul/context_f.i get-thobj-es }
{ gbl/key-rec.i }
{ bge/tmpcxmlh.i }
{ str/trdcalib.i        }
{ str/in-vatp.i def     }
{ str/out-vatp.i def    }
{ str/lib-trn.i }
{ cmp/library.i }
{ ref/cp-attr.i }
{ rep/cpapcep.i  "NEW SHARED" }
{ rep/cpapcep.i  "proc" }
{ rep/rl-2df-2.i "NEW SHARED" }
{ rep/rl-3df-2.i "NEW SHARED" }
{ rep/rl-4df-2.i "NEW SHARED" }
{ gbl/strtdate.i }
{ str/statq.i }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable v-newbh as handle no-undo .
define variable v-oldbh as handle no-undo .
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-action as character no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable v-gate-rec as character no-undo .
define variable num-rec-pre as integer no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-esys-id-list-start as character no-undo .
define variable v-esys-id-list as character no-undo .
define variable v-doc-list-bh as handle no-undo .
define variable v-doc-list-handle as handle no-undo .
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.



{ str/dia2auto.i }
{ rul/seterror.i }
{ cmp/doc-list.i doc-list def "new shared" }


&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)




/*---------------------------&start-rule-call-param&-------------------------------*/

  define variable p-esys-id-list as integer no-undo .
  define variable p-xsd-file as character no-undo.

/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/

 { rul/context_f.i  begin-esys-command }
 { rul/context_f.i  send-esys-command }
 { rul/context_f.i  delete-command }



/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.
if return-value = "return" then return ''.

/* ------------------------- &start-def-vars& -----------------------------------*/

define variable ExpData1 as class Route-data_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle)
ExpData1 = new Route-data_{&constructor_1} .

/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  { str/cdviewlg.i  "'!!!При маршрутизации произошли ошибки!!!'"   log-file-name not-delete }

  if v-es then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :

_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
on stop undo, return error substitute( "&1&2&3", return-value, {&new-line}, error-status :get-message (1))
:

  define variable v-doc-code as character no-undo .
  define variable v-trn-doc-obj-type as character no-undo .
  define variable v-trn-doc-obj-code as integer no-undo .
  define variable v-obj-db-num as integer no-undo .
  define variable v-obj-uniq-key-rec as character no-undo .
  define variable v-doc-list-doc-type as character no-undo .

  define buffer buf_inkas for ub.inkas.
  define buffer buf_c-inkas for ub.c-inkas.
  define buffer buf_clients for ub.clients.
  define buffer buf_ext-classif for ub.ext-classif.


  /* ------------------------- &end-hn-option& -----------------------------------*/
_stroka:
do while true
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  /* ------------------------- &start-rule& -----------------------------------*/
  case p-ruleset-id:
    when {&edoc-proc_18_batchwork-routing_inkas_30} then do:
      if v-doc-list-bh:available then do:
        v-doc-list-bh:buffer-delete().
      end.
      run cb_get-next-doc-by-doc-code in v-doc-list-handle ( input v-doc-code
                                                            ,input v-doc-list-doc-type
                                                            ,input v-doc-list-bh
                                                            ).

      if v-doc-list-bh:available then do:
        if num-rec-pre > 0 then do:
          run write-counter in p-log-handle ( input substitute("Просмотрено документов списка &1, обработано  &2, из них удачно: &3", num-rec-pre, num-rec, num-rec-ok)).
        end.
        num-rec-pre = num-rec-pre + 1.
        v-trn-doc-obj-type = v-doc-list-bh:buffer-field("obj-type"):buffer-value.
        v-trn-doc-obj-code = v-doc-list-bh:buffer-field("obj-code"):buffer-value.
        v-doc-code = v-doc-list-bh:buffer-field("doc-code"):buffer-value. /*это ведь врем табл doc-list а не price-doc */
        v-doc-list-doc-type = v-doc-list-bh:buffer-field("doc-type"):buffer-value.
        if not (v-doc-list-doc-type = {&cash-desk}
        or v-doc-list-doc-type  = "-" + {&cash-desk})
        then do:
          next _stroka.
        end.
      END.
      else do:
        v-trn-doc-obj-type = ''.
        v-trn-doc-obj-code = 0.
        v-doc-code = ''.
        leave _stroka.
      end.
    end.
    when {&edoc-proc_18_event_inkas_130} then do:
      if v-has-newbh then do:
        v-trn-doc-obj-type = v-newbh::obj-type.
        v-trn-doc-obj-code = v-newbh::obj-code.
        v-doc-code = v-newbh:buffer-field("inkas-code"):buffer-value.
      end.
      else do:
        v-trn-doc-obj-type = v-oldbh::obj-type.
        v-trn-doc-obj-code = v-oldbh::obj-code.
        v-doc-code = v-oldbh:buffer-field("inkas-code"):buffer-value.
      end.
    end.
  end case.
  find first buf_clients no-lock where
            buf_clients.obj-type = v-trn-doc-obj-type
       and  buf_clients.obj-code = v-trn-doc-obj-code.
  run gen-key-rec in this-procedure ( input {&table_clients}
                                     ,input buffer buf_clients:handle
                                     ,output v-obj-uniq-key-rec).
  v-esys-id-list = ''.
  for each buf_ext-classif no-lock where
      buf_ext-classif.classif-name = {&extclass_clients_esys}
  and buf_ext-classif.classif-subject = {&table_clients}
  and buf_ext-classif.db-num = 0
  and buf_Ext-classif.uniq-key-rec = v-obj-uniq-key-rec :
    if lookup(string(buf_ext-classif.key#_one), v-esys-id-list-start, {&delim-nws}) = 0 then next.
    v-esys-id-list = v-esys-id-list + (if v-esys-id-list = '' then '' else {&delim-nws}) + string(buf_ext-classif.key#_one).
  end.
  case p-ruleset-id:
    when {&edoc-proc_18_batchwork-routing_inkas_30} then do:
      if v-esys-id-list = '' then next _stroka. /*нет внешней системы куда отправлять*/
    end.
    when {&edoc-proc_18_event_inkas_130} then do:
      if v-esys-id-list = '' then leave _stroka. /*нет внешней системы куда отправлять*/
    end.
  end case.

  if v-has-newbh
  or p-ruleset-id = {&edoc-proc_18_batchwork-routing_inkas_30}
  then do:
    if p-save >= 0 then do:
      case p-ruleset-id:
        when {&edoc-proc_18_batchwork-routing_inkas_30} then do:
          if v-doc-list-doc-type = {&cash-desk} then do:
            find first buf_inkas exclusive-lock where
                      buf_inkas.inkas-code = v-doc-code
                    no-error.
            if buf_inkas.status_ <> {&fact} then next _stroka.
            v-action = {&gen-line-update}.
          end.
          if v-doc-list-doc-type = "-" + {&cash-desk} then do:
            find first buf_c-inkas exclusive-lock where
                      buf_c-inkas.inkas-code = v-doc-code
                  and buf_c-inkas.is-del = yes  no-error.
            if buf_c-inkas.status_ <> {&fact} then next _stroka.
            v-action = {&gen-line-delete}.
          end.
        end.
        when {&edoc-proc_18_event_inkas_130} then do:
          find first buf_inkas exclusive-lock where
                    buf_inkas.inkas-code = v-doc-code
                  no-error.
        end.
      end case.
    end.
    else do:
      case p-ruleset-id:
        when {&edoc-proc_18_event_inkas_130} then do:
          find first buf_inkas no-lock where
                    buf_inkas.inkas-code = v-doc-code
                  no-error.
        end.
      end case.
    end.
  end.
  num-rec = num-rec + 1.
  /*ДОКУМЕНТЫ ВСЕ РАВНО ШЛЕМ ПО ОДНОМУ В ПАКЕТЕ!!!*/
  IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  IF  context_begin-esys-command( input v-esys-id-list
                                , input-output v-esys-cmd-proc-handle
                                , output v-esys-cmd-code) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  run edocsinkas_export in this-procedure ( buffer buf_inkas
                                           ,input (if p-ruleset-id = {&edoc-proc_18_event_inkas_130}
                                                   then (if v-has-newbh then v-newbh else v-oldbh)
                                                   else (if v-doc-list-doc-type = {&cash-desk}
                                                         then (buffer buf_Inkas:handle)
                                                         else (buffer buf_c-Inkas:handle)
                                                         )
                                                   )
                                        ) no-error.
  if error-status:error then do:
    undo _main, return error ''.
  end.
  IF  context_send-esys-command( input v-esys-id-list
                              , input v-esys-cmd-proc-handle
                              , input v-esys-cmd-code
                              , input g#userid) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  num-rec-ok = num-rec-ok + 1.
  &scop release_1 clear-data ( )
  ExpData1:Route-data_{&release_1} .

  if p-ruleset-id = {&edoc-proc_18_event_inkas_130} then do:
    leave _stroka.
  end.
  else do:
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
      &scop my-message substitute("Процесс прерван пользователем")
      {&display-message}.
      leave _stroka.
    end.
  end.
  end. /*do while*/
  if p-ruleset-id = {&edoc-proc_18_batchwork-routing_inkas_30}
  then do:
    &scop my-message substitute("Просмотрено документов списка &1, обработано  &2, из них удачно: &3", num-rec-pre, num-rec, num-rec-ok)
    {&display-message}.
  end.
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable v-flag as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-is-waiting-status as logical no-undo .
define variable v-direction as character no-undo .
define variable v-direction-2 as character no-undo .
define variable v-changes-list as character no-undo .
define variable v-h as handle no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_ext-system for ub.ext-system.

do
on error undo, return error
:
case p-ruleset-id:
  when {&edoc-proc_18_batchwork-routing_inkas_30} then do:
    /*найдем процедуру которая управляет списком*/
    { gbl/calltree.i 'cb_get-next-doc-by-doc-code' this-procedure:handle p-cont-handle v-doc-list-handle }

    { gbl/calltree.i 'cb_rcps-run_fill-rcp-from-tt0' this-procedure:handle p-cont-handle v-h }
    run  cb_rcps-run_fill-rcp-from-tt0 in v-h ( input p-call-id
                                              ,input buffer buf_temp-rule-call-param:handle
                                                            ).
    for each buf_temp-rule-call-param no-lock where
    buf_temp-rule-call-param.codex_id = p-codex-id
    and buf_temp-rule-call-param.ruleset_id = p-ruleset-id
    and buf_temp-rule-call-param.call_id = p-call-id
    and buf_temp-rule-call-param.order_id = p-order-id
    and buf_temp-rule-call-param.rule_id = p-rule-id
    and buf_temp-rule-call-param.param-name = "p-esys-id-list",
      first buf_ext-system no-lock where
            buf_Ext-system.esys-id = buf_temp-rule-call-param.param-value-integer
        and buf_Ext-system.db-num = 0
        and buf_Ext-system.esys-have-export = yes
        and buf_Ext-system.esys-db-num-exp = g#db-num:
      v-esys-id-list-start = v-esys-id-list-start + (if v-esys-id-list-start = '' then '' else {&delim-nws}) + string(buf_ext-system.esys-id).
    end.
    if v-esys-id-list-start = '' then return "return".

      /*---------------------------&start-process-rule-call-param&-------------------------------*/
    find first buf_temp-rule-call-param no-lock where
    buf_temp-rule-call-param.codex_id = p-codex-id
    and buf_temp-rule-call-param.ruleset_id = p-ruleset-id
    and buf_temp-rule-call-param.call_id = p-call-id
    and buf_temp-rule-call-param.order_id = p-order-id
    and buf_temp-rule-call-param.rule_id = p-rule-id
    and buf_temp-rule-call-param.param-name = "p-xsd-file"
    no-error.
    if available buf_temp-rule-call-param then do:
      assign p-xsd-file = buf_temp-rule-call-param.param-value-character.
    end.
    v-doc-list-bh = buffer doc-list:handle.
    v-action = {&gen-line-update}.
  end.
  when {&edoc-proc_18_event_inkas_130} then do:
      assign
      v-oldbh = widget-handle (entry(2, p-doc-code, {&delim-par}))
      v-newbh = widget-handle (entry(3, p-doc-code, {&delim-par}))
      v-changes-list = entry(4, p-doc-code, {&delim-par})
      file-name  = p-process-file-name
      v-has-oldbh = valid-handle(v-oldbh) and v-oldbh:available
      v-has-newbh = valid-handle(v-newbh) and v-newbh:available
      .
      if not v-has-newbh
      and not v-has-oldbh then do:
        undo, return error substitute("Не определено ни одного буфера - ни старый, ни новый").
      end.
      if not v-has-oldbh
      and v-changes-list  = '' then do:
        undo, return error substitute("Не определен старый буфер и список изменений").
      end.
      if v-has-newbh
      and v-newbh:table <> {&table_inkas} then do:
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_inkas}).
      end.
      run statq_has-waiting-stat in this-procedure (
                                                      input v-oldbh
                                                    ,input v-newbh
                                                    ,input v-changes-list
                                                    ,input {&fact}
                                                    ,input ?  /*p-waiting-flag_*/
                                                    ,input 0 /*p-stati*/
                                                    ,output v-is-waiting-status
                                                    ,output v-direction
                                                    ) no-error.
      if v-is-waiting-status = no then return "return".
      if num-entries(v-direction, {&delim-par}) > 1 then do:
        v-direction-2 = entry(2, v-direction, {&delim-par}).
        v-direction = entry(1, v-direction, {&delim-par}).
        /*если закрытие НЕ ТОЧНО НА НУЖНЫЙ СТАТУС!*/
        if v-direction-2 <> "to"
        and v-direction-2 <> "from" then return "return".
        if v-direction = {&open-doc}
        and v-direction-2 = "to" then return "return".
        if v-direction = {&close-doc}
        and v-direction-2 = "from" then return "return".
      end.
      if v-direction = {&open-doc}
      or v-direction = {&deletion}
      then do:
        v-action = {&gen-line-delete}.
      end.
      else do:
        v-action = {&gen-line-update}.
      end.


    /*---------------------------&start-process-rule-call-param&-------------------------------*/

    for each buf_rule-call-param no-lock where
    buf_rule-call-param.codex_id = p-codex-id
    and buf_rule-call-param.ruleset_id = p-ruleset-id
    and buf_rule-call-param.call_id = p-call-id
    and buf_rule-call-param.order_id = p-order-id
    and buf_rule-call-param.rule_id = p-rule-id
    and buf_rule-call-param.param-name = "p-esys-id-list",
      first buf_ext-system no-lock where
            buf_Ext-system.esys-id = buf_rule-call-param.param-value-integer
        and buf_Ext-system.db-num = 0
        and buf_Ext-system.esys-have-export = yes
        and buf_Ext-system.esys-db-num-exp = g#db-num:
      v-esys-id-list-start = v-esys-id-list-start + (if v-esys-id-list-start = '' then '' else {&delim-nws}) + string(buf_ext-system.esys-id).
    end.
    if v-esys-id-list-start = '' then return "return".



      find first buf_rule-call-param no-lock where
    buf_rule-call-param.codex_id = p-codex-id
    and buf_rule-call-param.ruleset_id = p-ruleset-id
    and buf_rule-call-param.call_id = p-call-id
    and buf_rule-call-param.order_id = p-order-id
    and buf_rule-call-param.rule_id = p-rule-id
    and buf_rule-call-param.param-name = "p-xsd-file"
    no-error.
    if available buf_rule-call-param then do:
    assign p-xsd-file = buf_rule-call-param.param-value-character.
    end.
  end. /*when {&edoc-proc_18_event_inkas_130}*/
  otherwise do:
    undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
  end.
end case.


/*---------------------------&end-process-rule-call-param&-------------------------------*/
end. /*doe*/

end procedure. /* load-ruleset-context */

{ bge/edocik01.i }

define temp-table temp_inkas-pay no-undo
field pay-code  like inkas-pay.pay-code
field curr-code  like inkas-pay.pay-code
field tot-base  like inkas-pay.tot-base
field tot-rubl  like inkas-pay.tot-rubl
field tot-sum   like inkas-pay.tot-sum
field doc-type as character
index pi is primary unique pay-code curr-code
.
define temp-table temp-inkas no-undo like ub.inkas.

procedure edocsinkas_export :
define parameter buffer buf_inkas for ub.inkas.
define input parameter p-bh as handle no-undo .
define variable v-err-mess as character no-undo .
define variable glog as logical no-undo .
define variable v-attr-type as character no-undo .
define variable v-is-out as integer no-undo .
define variable v-scale-is-empty as logical no-undo .
define variable v-is-petrol                 as logical      no-undo.
define variable v-is-pieces                 as logical      no-undo.
define variable v-petrol-weight             as decimal      no-undo.
define variable v-petrol-density            as decimal      no-undo.
define variable v-weight-not-specified      as logical      no-undo.
define variable v-date-valid as logical no-undo .
define variable v-error-message as character no-undo .
define variable v-date-char as character no-undo .
define variable v-temp-bh as handle no-undo .

define buffer buf_operation for operation.
define buffer buf_casssum for cassSum.
define buffer buf_currency for ub.currency.
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units.
define buffer buf_c-inkas for ub.c-inkas.
define buffer buf_sale-doc for ub.sale-doc.


main-block:
do
on error undo main-block, retry main-block
:
  EMPTY TEMP-TABLE operation.
  empty temp-table cassSum.
  empty temp-table payCode.
  empty temp-table temp_inkas-pay.
  empty temp-table payCard.
  empty temp-table temp-inkas.
  if retry then do:
    EMPTY TEMP-TABLE operation.
    empty temp-table cassSum.
    empty temp-table payCode.
    empty temp-table temp_inkas-pay.
    empty temp-table payCard.
    empty temp-table temp-inkas.
    &scop my-message v-err-mess
    {&display-message}.
    return error ''.
  end.
  else do:
    create temp-inkas.
    v-temp-bh = buffer temp-inkas:handle.
    v-temp-bh:buffer-copy (p-bh).
    if v-action = {&gen-line-delete} then do:
      find first buf_c-inkas no-lock where
                buf_c-inkas.inkas-code = p-bh::inkas-code
            and buf_c-inkas.is-del = yes no-error.
    end.
    create buf_operation.
    assign
    buf_operation.referenceNo = temp-inkas.inkas-code
    buf_operation.isDel = (v-action = {&gen-line-delete})
    buf_operation.dateDelXml = (if v-action = {&gen-line-delete}
                                then (if available buf_c-inkas
                                      then buf_c-inkas.corr-date
                                      else ?)
                                else ?)
    buf_operation.codeOperation = "sale"
    buf_operation.host = temp-inkas.host-code
    buf_operation.factorder = 0
    buf_operation.sysDateXML = temp-inkas.sys-date
    buf_operation.dateDocXML = temp-inkas.doc-date
    buf_operation.dateFactXML = temp-inkas.fact-date
    buf_operation.shiftDateXML = temp-inkas.shift-date
    buf_operation.shiftNum = temp-inkas.shift-num
    buf_operation.shiftName = temp-inkas.shift-name
    buf_operation.comment = temp-inkas.PS
    buf_operation.store = temp-inkas.obj-type + string(temp-inkas.obj-code)
    buf_operation.systime = string(temp-inkas.sys-time, "HH:MM:SS")
    buf_operation.factQnty = temp-inkas.qnty
    buf_operation.totalSum =  temp-inkas.tot-doc
    buf_operation.totalDsc = temp-inkas.discnt
    buf_operation.totalFact = temp-inkas.netto
    .
    if v-action = {&gen-line-delete} then do:
      ExpData1:route-data_create-record( INPUT "operation") .
      ExpData1:route-data_copy-record ( input "operation", buffer buf_operation:handle).
      IF ExpData1:esys-add-dump( INPUT "operation", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи operation &1:&2&3"
                                , temp-inkas.inkas-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo main-block, retry main-block.
      end.
      return.
    end.
    ExpData1:route-data_create-record( INPUT "operation") .
    ExpData1:route-data_copy-record ( input "operation", buffer buf_operation:handle).
    IF ExpData1:esys-add-dump( INPUT "operation", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи operation &1:&2&3"
                              , buf_inkas.inkas-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo main-block, retry main-block.
    end.
    for each buf_sale-doc no-lock where
            buf_sale-doc.inkas-code = buf_inkas.inkas-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      if not available saleDoc then do:
        create saleDoc.
      end.
      assign
      saleDoc.saleReferenceNo = buf_inkas.inkas-code
      saleDoc.referenceNo     = buf_sale-doc.doc-code
      saleDoc.codeOperation   = buf_sale-doc.doc-kind
      .
      ExpData1:route-data_create-record( INPUT "saleDoc") .
      ExpData1:route-data_copy-record ( input "saleDoc", buffer saleDoc:handle).
      IF ExpData1:esys-add-dump( INPUT "saleDoc", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи saleDoc &1:&2&3"
                                , buf_sale-doc.doc-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo main-block, retry main-block.
      end.
      if buf_sale-doc.in-inkas = yes then do:
        empty temp-table treal-2.
        empty temp-table treal-3.
        empty temp-table treal-4.
        empty temp-table temp_inkas-pay.
        run bge/bgepych2.p (
              input buf_inkas.inkas-code
            , input buf_sale-doc.ext-doc-type
            , input yes /*p-pay-desk*/
            , input yes /*p-pay-desk-cards*/
            , input yes /*p-petrol*/
            , input yes /*p-goods*/
            , input yes /*p-services*/
        ).
        if buf_sale-doc.dir <> 0 then do:
          run get-inkas-pay-desk in this-procedure (
                  input buf_inkas.inkas-code
                , input buf_inkas.obj-type
                , input buf_inkas.obj-code
                , input (if buf_sale-doc.dir = 1
                        then {&income}
                        else {&expense}
                        )
            ) no-error .
          if error-status:error
          then do:
            &scop my-message substitute("*** ERR: *** Не удалось рассчитать разбивку по кодам оплат по документу N &1", p-doc-code )
            {&display-message}.
          end.
        end.
        run export-chk-pay-code in this-procedure (
                                                   input buf_Sale-doc.doc-code
                                                  ,input buf_sale-doc.ext-doc-type
                                                  ,input buf_sale-doc.dir
                                              ).
        create buf_cassSum.
        for each temp_inkas-pay
        on error undo, return error
        :
          assign
          buf_cassSum.referenceNo = buf_sale-doc.doc-code
          buf_cassSum.code = temp_inkas-pay.pay-code
          buf_cassSum.currCode = temp_inkas-pay.curr-code
          buf_cassSum.sum = (if temp_inkas-pay.doc-type = {&income} then 1 else -1)  * temp_inkas-pay.tot-sum
          buf_cassSum.sumb = (if temp_inkas-pay.doc-type = {&income} then 1 else -1) * temp_inkas-pay.tot-base
          buf_cassSum.sumr = (if temp_inkas-pay.doc-type = {&income} then 1 else -1) * temp_inkas-pay.tot-rubl
          .
          ExpData1:route-data_create-record( INPUT "cassSum") .
          ExpData1:route-data_copy-record ( input "cassSum", buffer buf_cassSum:handle).
          IF ExpData1:esys-add-dump( INPUT "cassSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи cassSum &1:&2&3"
                                    , buf_sale-doc.doc-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo main-block, retry main-block.
          end.
        end.
        if available buf_cassSum then delete buf_cassSum.
        /*---END----------- Суммы по видам кассовых платежей ---------------------*/
      end. /*if buf_sale-doc.in-inkas = yes then do:*/

    end. /*    for each buf_sale-doc no-lock where*/
    if available saleDoc then delete saleDoc.
    run export-checks in this-procedure (
                                          input buf_inkas.inkas-code
                                        , input buf_inkas.obj-type
                                        , input buf_inkas.obj-code
    ).


    if available buf_operation then delete buf_operation.
  end. /*not retry*/
end.

end procedure. /* edocsinkas_export */

procedure get-inkas-pay-desk :

  do
  on error undo, return error
  :

  define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
  define input parameter p-obj-type   like ub.inkas.obj-type no-undo .
  define input parameter p-obj-code   like ub.inkas.obj-code no-undo .
  define input parameter p-inkas-pay-desk-type like ub.inkas-pay-desk.doc-type no-undo .

    /*проверим есть ли для данного inkas подчиненная таблица inkas-pay-desk*/
    /*если это старая продажа до версии 12.2 - может не быть тогда создадим*/
    /*это возможно в офисе т.к. в Орле все чеки ходят*/
    if can-find( first ub.inkas-pay-desk  NO-LOCK WHERE
                       ub.inkas-pay-desk.inkas-code = p-inkas-code ) then.
    else do:
      run trg/inkpdcr.p (
                     p-inkas-code
                    ,p-obj-type
                    ,p-obj-code
      ) no-error .
      if error-status:error then do:
        return error.
      end.
    end.
    for each temp_inkas-pay
    :
        delete temp_inkas-pay.
    end.
    for each ub.inkas-pay-desk no-lock
       where ub.inkas-pay-desk.inkas-code = p-inkas-code
         and ub.inkas-pay-desk.doc-type = p-inkas-pay-desk-type
    break
    by ub.inkas-pay-desk.pay-code
    by ub.inkas-pay-desk.curr-code
    on error undo, return error
    :
      if first-of( ub.inkas-pay-desk.curr-code )
      then do:
        create temp_inkas-pay.
        assign
        temp_inkas-pay.pay-code  = ub.inkas-pay-desk.pay-code
        temp_inkas-pay.curr-code  = ub.inkas-pay-desk.curr-code
        temp_inkas-pay.tot-base  = 0
        temp_inkas-pay.tot-rubl  = 0
        temp_inkas-pay.tot-sum   = 0
        .
      end.
      assign
      temp_inkas-pay.tot-base  = temp_inkas-pay.tot-base + ub.inkas-pay-desk.tot-base
      temp_inkas-pay.tot-rubl  = temp_inkas-pay.tot-rubl + ub.inkas-pay-desk.tot-rubl
      temp_inkas-pay.tot-sum   = temp_inkas-pay.tot-sum  + ub.inkas-pay-desk.tot-sum
      temp_inkas-pay.doc-type  = p-inkas-pay-desk-type
      .
    end.
  end.

end procedure. /* get-inkas-pay-desk */


procedure export-chk-pay-code :
define input parameter p-doc-code           as character        no-undo.
define input parameter p-ext-doc-type       as character        no-undo .
define input parameter p-is-out             as integer          no-undo .

define variable v-err-mess as character no-undo .
define buffer buf_PayCode for paycode .
define buffer buf_paycard for paycard.
define buffer buf_goods for ub.goods.

main-block:
do
on error  undo main-block, retry main-block
on stop   undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    empty temp-table payCard.
    empty temp-table payCode.
  end.
  else do:
    empty temp-table payCard.
    empty temp-table payCode.
    for each treal-2 where
         treal-2.is-pay = yes,
    first buf_goods no-lock where buf_goods.gds-code = treal-2.gds-code
    break
    by treal-2.pay-desk
    by treal-2.cpay-code
    by treal-2.curr-code
    by treal-2.prefix
    on error undo, return error
    :
        if treal-2.prefix = '':U then do:
            /*суммирующая запись по всем префиксам*/
          create buf_PayCode.
          assign
          buf_PayCode.referenceNo = p-doc-code
          buf_PayCode.good = buf_goods.gds-code
          buf_PayCode.deskcode = treal-2.pay-desk
          buf_PayCode.paycode = treal-2.cpay-code
          buf_PayCode.quantity = p-is-out * treal-2.qnty1
          buf_PayCode.sumr = p-is-out * treal-2.netto
          .
          ExpData1:route-data_create-record( INPUT "payCode") .
          ExpData1:route-data_copy-record ( input "payCode", buffer buf_paycode:handle).
          IF ExpData1:esys-add-dump( INPUT "payCode", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи payCode &1:&2&3"
                                    , p-doc-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo main-block, retry main-block.
          end.
        end.
        if treal-2.prefix <> '':U
        then do:
            /*сюда попадем только если p-pay-desk-cards = yes и уже была запись с prefix = '':U*/
          create buf_payCard.
          assign
          buf_PayCard.good = buf_goods.gds-code
          buf_PayCard.referenceNo = p-doc-code
          buf_PayCard.deskcode = treal-2.pay-desk
          buf_PayCard.paycode = treal-2.cpay-code
          buf_PayCard.num = treal-2.prefix
          buf_PayCard.quantity = p-is-out * treal-2.qnty1
          buf_PayCard.sumr = p-is-out * treal-2.netto
          .
          ExpData1:route-data_create-record( INPUT "payCard") .
          ExpData1:route-data_copy-record ( input "payCard", buffer buf_paycard:handle).
          IF ExpData1:esys-add-dump( INPUT "payCard", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи payCard &1:&2&3"
                                    , p-doc-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo main-block, retry main-block.
          end.
        end.
    end.
    for each treal-3 no-lock  where
        treal-3.is-pay = yes,
    first buf_goods no-lock where buf_goods.gds-code = treal-3.gds-code
    break
    by treal-3.pay-desk
    by treal-3.cpay-code
    by treal-3.curr-code
    by treal-3.prefix
    on error undo, return error
    :
      if treal-3.prefix = '':U then do:
        /*суммирующая запись по всем префиксам*/
        create buf_PayCode.
        assign
        buf_PayCode.referenceNo = p-doc-code
        buf_PayCode.good = buf_goods.gds-code
        buf_PayCode.deskcode = treal-3.pay-desk
        buf_PayCode.paycode = treal-3.cpay-code
        buf_PayCode.quantity = p-is-out * treal-3.qnty1
        buf_PayCode.sumr = p-is-out * treal-3.netto
        .
        ExpData1:route-data_create-record( INPUT "payCode") .
        ExpData1:route-data_copy-record ( input "payCode", buffer buf_paycode:handle).
        IF ExpData1:esys-add-dump( INPUT "payCode", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи payCode2 &1:&2&3"
                                  , p-doc-code
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
      end.
      if treal-3.prefix <> '':U then do:
        /*сюда попадем только если p-pay-desk-cards = yes и уже была запись с prefix = '':U*/
        create buf_payCard.
        assign
        buf_PayCard.referenceNo = p-doc-code
        buf_PayCard.good = buf_goods.gds-code
        buf_PayCard.deskcode = treal-3.pay-desk
        buf_PayCard.paycode = treal-3.cpay-code
        buf_PayCard.num = treal-3.prefix
        buf_PayCard.quantity = p-is-out * treal-3.qnty1
        buf_PayCard.sumr = p-is-out * treal-3.netto
        .
        ExpData1:route-data_create-record( INPUT "payCard") .
        ExpData1:route-data_copy-record ( input "payCard", buffer buf_paycard:handle).
        IF ExpData1:esys-add-dump( INPUT "payCard", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи payCard &1:&2&3"
                                  , p-doc-code
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
      end.
    end.
    for each treal-4 no-lock where
           treal-4.is-pay = yes,
    first buf_goods no-lock where buf_goods.gds-code = treal-4.gds-code
    break
    by treal-4.pay-desk
    by treal-4.cpay-code
    by treal-4.curr-code
    by treal-4.prefix
    on error undo, return error
      :
      if treal-4.prefix = '':U then do:
        /*суммирующая запись по всем префиксам*/
        create buf_PayCode.
        assign
        buf_PayCode.referenceNo = p-doc-code
        buf_PayCode.good = buf_Goods.gds-code
        buf_PayCode.deskcode = treal-4.pay-desk
        buf_PayCode.paycode = treal-4.cpay-code
        buf_PayCode.quantity = p-is-out * treal-4.qnty1
        buf_PayCode.sumr = p-is-out * treal-4.netto
        .
        ExpData1:route-data_create-record( INPUT "payCode") .
        ExpData1:route-data_copy-record ( input "payCode", buffer buf_paycode:handle).
        IF ExpData1:esys-add-dump( INPUT "payCode", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи payCode &1:&2&3"
                                  , p-doc-code
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
      end.
      if treal-4.prefix <> '':U then do:
        create buf_payCard.
        assign
        buf_PayCard.referenceNo = p-doc-code
        buf_PayCard.good = buf_goods.gds-code
        buf_PayCard.deskcode = treal-4.pay-desk
        buf_PayCard.paycode = treal-4.cpay-code
        buf_PayCard.num = treal-4.prefix
        buf_PayCard.quantity = p-is-out * treal-4.qnty1
        buf_PayCard.sumr = p-is-out * treal-4.netto
        .
        ExpData1:route-data_create-record( INPUT "payCard") .
        ExpData1:route-data_copy-record ( input "payCard", buffer buf_paycard:handle).
        IF ExpData1:esys-add-dump( INPUT "payCard", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи payCard &1:&2&3"
                                  , p-doc-code
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
      end.
    end. /*        for each treal-4 no-lock where */

  end. /*not retry*/
end.
end procedure. /* export-chk-pay-code */



procedure export-checks :

define input parameter p-doc-code       as character    no-undo.
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.

define variable v-write-off as logical no-undo .
/*признак чека со списанными товарами*/
define variable v-doc-bh as handle no-undo .
define variable v-gds-bh as handle no-undo .
define variable v-pay-bh as handle no-undo .
define variable v-discnt-bh as handle no-undo .
define variable v-err-mess as character no-undo .


define buffer buf_chk-doc       for ub.chk-doc.
define buffer buf_chk-gds       for ub.chk-gds.
define buffer buf_chk-pay       for ub.chk-pay.
define buffer buf_bar-code      for ub.bar-code.
define buffer buf_goods         for ub.goods.
define buffer buf_c-chk-doc     for ub.c-chk-doc.
define buffer manu_c-chk-doc    for ub.c-chk-doc.
define buffer buf_chk-discnt    for ub.chk-discnt.
define buffer buf_dis-card      for ub.dis-card.


main-block:
do
for buf_chk-doc
  , buf_chk-gds
  , buf_chk-pay
  , buf_bar-code
  , buf_goods
  , buf_c-chk-doc
  , buf_chk-discnt
  , buf_dis-card
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  v-doc-bh = buffer buf_chk-doc:handle.
  v-gds-bh = buffer buf_chk-gds:handle.
  v-pay-bh = buffer buf_chk-pay:handle.
  for each buf_chk-doc no-lock
      where buf_chk-doc.out-code = p-doc-code
  :
    if buf_chk-doc.correct = no then next.
    if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next.

    find first buf_dis-card no-lock
          where buf_dis-card.d-card = buf_chk-doc.d-card
    no-error.
    if not available check1 then do:
      create check1.
    end.
    find first manu_c-chk-doc
          where manu_c-chk-doc.doc-code   = buf_chk-doc.doc-code
            and manu_c-chk-doc.obj-type   = buf_chk-doc.obj-type
            and manu_c-chk-doc.obj-code   = buf_chk-doc.obj-code
            and manu_c-chk-doc.is-add     = yes
    use-index pi /* по doc-code быстрее  */
    no-error.
    find first buf_c-chk-doc
          where buf_c-chk-doc.doc-code   = buf_chk-doc.doc-code
            and buf_c-chk-doc.obj-type   = buf_chk-doc.obj-type
            and buf_c-chk-doc.obj-code   = buf_chk-doc.obj-code
            and buf_c-chk-doc.is-add     = no
            and buf_c-chk-doc.is-del     = no
    use-index pi /* по doc-code быстрее  */
    no-error.
    assign
    v-write-off = no
    .
    if buf_chk-doc.sub-discnt <> 0 then do:
      /*убедимся что это не скидка на итог на списанные блюда*/
      if buf_chk-doc.chk-type = integer({&rcpt-return-write-off}) then do:
        assign
            v-write-off = yes
        .
      end.
      else do:
        /*придется порускать по товарам и посмотреть коды списания*/
        _for:
        for each buf_chk-gds no-lock where
                buf_chk-gds.doc-code = buf_chk-doc.doc-code :
          if buf_Chk-gds.write-off-code <> ?
          and buf_Chk-gds.write-off-code <> 0 then do:
            assign
            v-write-off = yes.
            leave _for.
          end.
        end. /*for each buf_chk-gds no-lock where*/
      end.
    end. /*if buf_chk-doc.sub-discnt <> 0 then do:*/
    /*это сумма списанных товаров как скидку на итог выгрузим 0*/

    assign
    check1.referenceNo  = p-doc-code
    check1.doccode      = buf_chk-doc.doc-code
    check1.type         = buf_chk-doc.office
    check1.num          = buf_chk-doc.chk-num
    check1.desk         = buf_chk-doc.pay-desk
    check1.dateXML      = buf_chk-doc.chk-date
    check1.chk-time     = string(buf_chk-doc.chk-time, "HH:MM:SS")
    check1.shiftDateXML = buf_chk-doc.shift-date
    check1.shiftNum     = buf_chk-doc.shift-num
    check1.dCard        = buf_chk-doc.d-card
    check1.dCardCliType = buf_chk-doc.cli-type
    check1.dCardCliCode = buf_chk-doc.cli-code
    check1.discnt       = buf_chk-doc.discnt
    check1.cashier      = buf_chk-doc.cashier
    check1.cashierPsnCode = buf_chk-doc.cashier-psn-code
    check1.salesman       = buf_chk-doc.sales-man
    check1.zNumber        = buf_chk-doc.z-number
    check1.manualMaked    = (if available manu_c-chk-doc then yes else no)
    check1.manualChanged  = (if available buf_c-chk-doc then yes else no)
    check1.subDiscnt      = (if v-write-off then buf_chk-doc.sub-discnt else 0)
    check1.totdoc         = buf_chk-doc.tot-doc
    .
    ExpData1:route-data_create-record( INPUT "check1") .
    ExpData1:route-data_copy-record ( input "check1", input buffer check1:handle).
    IF ExpData1:esys-add-dump( INPUT "check1", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи check для продажи &1:&2&3"
                              , p-doc-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
    for each buf_chk-gds no-lock
        where buf_chk-gds.doc-code = buf_chk-doc.doc-code
    :
      find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_chk-gds.b-code no-error.
      if not available checkGds then do:
        create checkGds.
      end.
      assign
      checkGds.doccode = buf_chk-doc.doc-code
      checkGds.gdsCode = (if available buf_bar-code then buf_bar-code.gds-code else 0)
      checkGds.qnty    = buf_chk-gds.doc-qnty
      checkGds.priceBase = buf_chk-gds.price-base
      checkGds.priceDiscnt = buf_chk-gds.discnt
      checkGds.lineNum  = buf_chk-gds.line-num
      checkGds.pump  = buf_chk-gds.pump
      checkGds.roadTax  = buf_chk-gds.road-tax
      checkGds.srcCode  = entry(1, buf_chk-gds.src-code, {&delim-par} )
      checkGds.srcQnty  = buf_chk-gds.src-qnty
      checkGds.srcprice = buf_chk-gds.src-price
      .
      ExpData1:route-data_create-record( INPUT "checkGds") .
      ExpData1:route-data_copy-record ( "checkGds", input buffer checkgds:handle).
      IF ExpData1:esys-add-dump( INPUT "checkGds", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи checkGds для продажи &1:&2&3"
                                , p-doc-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo main-block, return error v-err-mess.
      end.
    end.      /* for each buf_chk-gds no-lock */
    for each buf_chk-pay no-lock
        where buf_chk-pay.doc-code = buf_chk-doc.doc-code
    :
      if not available checkPay then do:
        create checkPay.
      end.
      assign
      checkPay.doccode = buf_chk-doc.doc-code
      checkPay.payCode = buf_chk-pay.pay-code
      checkPay.payCard = buf_chk-pay.pay-card
      checkPay.currCode = buf_chk-pay.curr-code
      checkPay.sumBase = buf_chk-pay.tot-base
      checkPay.sumrubl = buf_chk-pay.tot-rubl
      checkPay.sumtot = buf_chk-pay.tot-sum
      checkPay.lineNum = buf_chk-pay.line-num
      .

      ExpData1:route-data_create-record( INPUT "checkPay") .
      ExpData1:route-data_copy-record ( input "checkPay", input buffer checkpay:handle).
      IF ExpData1:esys-add-dump( INPUT "checkPay", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи checkPay для продажи &1:&2&3"
                                , p-doc-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo main-block, return error v-err-mess.
      end.
    end.        /* for each buf_chk-pay no-lock */
    define variable v-ii as integer no-undo .
    do v-ii = 0 to 2 by 2:
      /*если v-ii = 0 то скидки начисленные кассой если 2 то погрешность*/
      for each buf_chk-discnt no-lock
        where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
          and buf_chk-discnt.record-type = v-ii
      :
        if not available checkDiscount then do:
          create checkDiscount.
        end.
        assign
        checkDiscount.doccode = buf_chk-discnt.doc-code
        checkDiscount.linenum = buf_chk-discnt.line-num
        checkDiscount.discntvCode = buf_chk-discnt.value-type
        checkDiscount.objectlinenum = buf_chk-discnt.object-line-num
        checkDiscount.discntTargetCode = buf_chk-discnt.line-type
        checkDiscount.discntTypeCode = buf_chk-discnt.discnt-type
        checkDiscount.discntValueAbs = buf_chk-discnt.discnt-value-abs
        checkDiscount.discntValuePcnt = buf_chk-discnt.discnt-value-pcnt
        checkDiscount.srcDCard = buf_chk-discnt.src-d-card
        checkDiscount.discntKategory = ( if buf_chk-discnt.src-d-card <> ''
                                          and buf_chk-discnt.src-d-card <> ?
                                          and available buf_dis-card
                                          and buf_dis-card.d-card = buf_chk-discnt.src-d-card
                                          and buf_chk-discnt.kateg = ?
                                          then buf_dis-card.category
                                          else buf_chk-discnt.kateg )
        .
        ExpData1:route-data_create-record( INPUT "checkDiscount") .
        ExpData1:route-data_copy-record ( input "checkDiscount", input buffer checkdiscount:handle).
              IF ExpData1:esys-add-dump( INPUT "checkDiscount", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи checDiscount для продажи &1:&2&3"
                                  , p-doc-code
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo main-block, return error v-err-mess.
        end.
      end. /* for each buf_chk-dicsnt no-lock  */
    end.
  end.        /* for each buf_chk-doc no-lock */
end.
end procedure. /* export-checks */





/*не удалять!!!!*/