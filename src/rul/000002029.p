
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18, набор 2,14,100,115

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/26/08
Author: Bakhtadze Natalya
Creation date: 05/26/08

---------------------------&start-codex_id=18;ruleset_id=2;-------------------------------
---------------------------&start-codex_id=18;ruleset_id=14;-------------------------------
---------------------------&start-codex_id=18;ruleset_id=100;-------------------------------
---------------------------&start-codex_id=18;ruleset_id=115;-------------------------------
События с накладными

---------------------------&end-codex_id=18;ruleset_id=2;-------------------------------
---------------------------&end-codex_id=18;ruleset_id=14;-------------------------------
---------------------------&end-codex_id=18;ruleset_id=100;-------------------------------
---------------------------&end-codex_id=18;ruleset_id=115;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 1,14,100,115".
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
on stop undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)

:

define variable v-doc-code as character no-undo .
define variable v-trn-doc-obj-type as character no-undo .
define variable v-trn-doc-obj-code as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define variable v-doc-list-doc-type as character no-undo .

define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_c-trn-doc for ub.c-trn-doc.
define buffer buf_ord-doc for ub.ord-doc.
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
  v-esys-id-list = ''.
  v-trn-doc-obj-type = ''.
  v-trn-doc-obj-code = 0.
  if available buf_trn-doc then release buf_trn-doc.
  if available buf_c-trn-doc then release buf_c-trn-doc.
  if available buf_ord-doc then release buf_ord-doc.
  case p-ruleset-id:
    when {&edoc-proc_18_batchwork-routing_order_2}
    or when {&edoc-proc_18_batchwork-routing_trn-doc_14}
    then do:
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
        if p-ruleset-id = {&edoc-proc_18_batchwork-routing_order_2}
        and v-doc-list-doc-type <> {&o-p} then do:
          next _stroka.
        end.
        if p-ruleset-id = {&edoc-proc_18_batchwork-routing_trn-doc_14}
        and not
         (lookup(v-doc-list-doc-type,  {&trn-type }) > 0
          or
             (v-doc-list-doc-type begins "-"
             and
             lookup(entry(2, "-", v-doc-list-doc-type),  {&trn-type }) > 0
             )
        )
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
    when {&edoc-proc_18_event_order_100}
    or
    when {&edoc-proc_18_event_trn-doc_115}
    then do:
      if v-has-newbh then do:
        v-trn-doc-obj-type = v-newbh::obj-type.
        v-trn-doc-obj-code = v-newbh::obj-code.
        v-doc-code = v-newbh:buffer-field("doc-code"):buffer-value.
      end.
      else do:
        v-trn-doc-obj-type = v-oldbh::obj-type.
        v-trn-doc-obj-code = v-oldbh::obj-code.
        v-doc-code = v-oldbh:buffer-field("doc-code"):buffer-value.
      end.
    end. /*when 110 then do:*/
  end case. /*case p-ruleset-id:*/

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
    when {&edoc-proc_18_event_order_100}
    or when {&edoc-proc_18_event_trn-doc_115} then do:
      if v-esys-id-list = '' then leave _stroka. /*нет внешней системы куда отправлять*/
    end.
    when {&edoc-proc_18_batchwork-routing_order_2}
    or when {&edoc-proc_18_batchwork-routing_trn-doc_14} then do:
      if v-esys-id-list = '' then next _stroka. /*нет внешней системы куда отправлять*/
    end.
  end case. /*case p-ruleset-id:*/
  if p-save >= 0 then do:
    case p-ruleset-id:
      when {&edoc-proc_18_event_trn-doc_115} then do:
        find first buf_trn-doc exclusive-lock where
                  buf_trn-doc.doc-code = v-doc-code
                no-error.
      end.
      when {&edoc-proc_18_batchwork-routing_trn-doc_14} then do:
        if v-doc-list-doc-type begins "-" then do:
          find first buf_c-trn-doc exclusive-lock where
                    buf_c-trn-doc.doc-code = v-doc-code
                and buf_c-trn-doc.is-del = yes
                  no-error.
          v-action = {&gen-line-delete}.
        end.
        else do:
          find first buf_trn-doc exclusive-lock where
                    buf_trn-doc.doc-code = v-doc-code
                  no-error.
           v-action = {&gen-line-update}.
        end.
      end.
      when {&edoc-proc_18_event_order_100}
      or
      when {&edoc-proc_18_batchwork-routing_order_2}
      then do:
        find first buf_ord-doc exclusive-lock where
                  buf_ord-doc.doc-code = v-doc-code
                no-error.
      end.
    end case. /*case p-ruleset-id:*/
  end.
  else do:
    case p-ruleset-id:
      when {&edoc-proc_18_event_trn-doc_115} then do:
        find first buf_trn-doc no-lock where
                  buf_trn-doc.doc-code = v-doc-code
                no-error.
      end.
      when {&edoc-proc_18_batchwork-routing_trn-doc_14} then do:
        if v-doc-list-doc-type begins "-" then do:
          find first buf_c-trn-doc no-lock where
                    buf_c-trn-doc.doc-code = v-doc-code
                and buf_c-trn-doc.is-del = yes
                  no-error.
          v-action = {&gen-line-delete}.
        end.
        else do:
          find first buf_trn-doc no-lock where
                    buf_trn-doc.doc-code = v-doc-code
                  no-error.
           v-action = {&gen-line-update}.
        end.
      end.
      when {&edoc-proc_18_event_order_100}
      or when {&edoc-proc_18_batchwork-routing_order_2}
      then do:
        find first buf_ord-doc no-lock where
                  buf_ord-doc.doc-code = v-doc-code
                no-error.
      end.
    end case. /*case p-ruleset-id:*/
  end.
  case p-ruleset-id:
    when {&edoc-proc_18_batchwork-routing_order_2} then do:
      if not (buf_ord-doc.status_ = {&fact}) then next _stroka.
    end.
    when {&edoc-proc_18_batchwork-routing_trn-doc_14} then do:
      if v-doc-list-doc-type begins "-" then do:
        if not (buf_c-trn-doc.status_ = {&fact}
        and buf_c-trn-doc.flag_ = yes) then next _stroka.
      end.
      else do:
        if not (buf_trn-doc.status_ = {&fact}
        and buf_trn-doc.flag_ = yes) then next _stroka.
      end.
    end.
  end case.
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


  case p-ruleset-id:
    when {&edoc-proc_18_event_trn-doc_115}
    or when {&edoc-proc_18_batchwork-routing_trn-doc_14}
    then do:
      run edocstrn_export in this-procedure ( buffer buf_trn-doc
                                             ,buffer buf_c-trn-doc
                                            ) no-error.

    end.
    when {&edoc-proc_18_event_order_100}
    or
    when {&edoc-proc_18_batchwork-routing_order_2}
    then do:
      run edocsord_export in this-procedure ( buffer buf_ord-doc
                                            ) no-error.
    end.
  end case. /*case p-ruleset-id*/
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
  if p-ruleset-id = {&edoc-proc_18_event_order_100}
  or p-ruleset-id = {&edoc-proc_18_event_trn-doc_115} then do:
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
end.
if p-ruleset-id = 10
or p-ruleset-id = {&edoc-proc_18_batchwork-routing_trn-doc_14} then do:
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
on stop undo, return error
:
  case p-ruleset-id:
    when {&edoc-proc_18_batchwork-routing_order_2}
    or when {&edoc-proc_18_batchwork-routing_trn-doc_14}
    then do:
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
    when {&edoc-proc_18_event_order_100}
    or when {&edoc-proc_18_event_trn-doc_115} then do:
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
      case p-ruleset-id:
        when {&edoc-proc_18_event_trn-doc_115} then do:
          if v-has-newbh
          and v-newbh:table <> {&table_trn-doc} then do:
            undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_trn-doc}).
          end.
          run statq_has-waiting-stat in this-procedure (
                                                          input v-oldbh
                                                        ,input v-newbh
                                                        ,input v-changes-list
                                                        ,input {&fact}
                                                        ,input yes  /*p-waiting-flag_*/
                                                        ,input 0 /*p-stati*/
                                                        ,output v-is-waiting-status
                                                        ,output v-direction
                                                        ) no-error.
        end.
        when {&edoc-proc_18_event_order_100} then do:
          if v-has-newbh
          and v-newbh:table <> {&table_ord-doc} then do:
            undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_ord-doc}).
          end.
          if v-has-newbh
          and v-newbh::doc-type <> {&o-p} then return "return".
          if not v-has-newbh
          and v-has-oldbh
          and v-oldbh::doc-type <> {&o-p} then return "return".
          run statq_has-waiting-stat in this-procedure (
                                                          input v-oldbh
                                                        ,input v-newbh
                                                        ,input v-changes-list
                                                        ,input {&ord-rcv}
                                                        ,input yes  /*p-waiting-flag_*/
                                                        ,input 0 /*p-stati*/
                                                        ,output v-is-waiting-status
                                                        ,output v-direction
                                                        ) no-error.

        end.
      end case.
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


      /*---------------------------&end-process-rule-call-param&-------------------------------*/
    end. /*when {&edoc-proc_18_event_order_100}*/
    otherwise do:
      undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
    end.
  end case. /*  case p-ruleset-id:*/
end. /*doe*/

end procedure. /* load-ruleset-context */

{ bge/edocwb01.i }


procedure edocstrn_export :
define parameter buffer buf_trn-doc for ub.trn-doc.
define parameter buffer buf_c-trn-doc for ub.c-trn-doc.
define buffer buf_doc-line for ub.doc-line.
define variable v-bh as handle no-undo .
define variable v-bh-line as handle no-undo .
define variable v-err-mess as character no-undo .
define variable glog as logical no-undo .
define variable v-attr-type as character no-undo .
define variable v-is-out as integer no-undo .
define variable v-inkas-pay-desk-type  as character no-undo .
define variable v-scale-is-empty as logical no-undo .
define variable v-is-petrol                 as logical      no-undo.
define variable v-is-pieces                 as logical      no-undo.
define variable v-petrol-weight             as decimal      no-undo.
define variable v-petrol-density            as decimal      no-undo.
define variable v-weight-not-specified      as logical      no-undo.
define variable v-date-valid as logical no-undo .
define variable v-error-message as character no-undo .
define variable v-linedoc-hidden as logical no-undo .
define variable v-dtl-hidden as logical no-undo .
define variable v-part-hidden as logical no-undo .
define variable v-date-char as character no-undo .
define variable v-prodPricewithvat as character no-undo .
define variable v-prodvat as decimal   no-undo .


define buffer buf_operation for operation.
define buffer buf_part for part.
define buffer buf_currency for ub.currency.
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units.
define buffer buf_ord-chain   for ub.ord-chain.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_contract for ub.contract.
define buffer buf_inkas for ub.inkas.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_parts         for ub.parts.
define buffer buf_parts-attr    for ub.parts-attr.


main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
:
  EMPTY TEMP-TABLE operation.
  empty TEMP-TABLE linedoc.
  empty temp-table part.
  if retry then do:
    EMPTY TEMP-TABLE operation.
    empty TEMP-TABLE linedoc.
    empty temp-table part.
    &scop my-message v-err-mess
    {&display-message}.
    return error ''.
  end.
  else do:
    v-bh = buffer buf_trn-doc:handle.
    v-bh-line = buffer buf_doc-line:handle.
    if v-action = {&gen-line-delete}
    and not available buf_c-trn-doc
    then do:
      find first buf_c-trn-doc no-lock where
                buf_c-trn-doc.doc-code = buf_trn-doc.doc-code
            and buf_c-trn-doc.is-del = yes no-error.
    end.
    if available buf_trn-doc then do:
      create buf_operation.
      assign
      buf_operation.referenceNo = buf_trn-doc.doc-code
      buf_operation.isDel = (v-action = {&gen-line-delete})
      buf_operation.dateDelXml = (if v-action = {&gen-line-delete}
                                  then (if available buf_c-trn-doc
                                        then buf_c-trn-doc.corr-date
                                        else ?)
                                  else ?)
      buf_operation.codeOperation = buf_trn-doc.ext-doc-type
      buf_operation.host = buf_trn-doc.host-code
      buf_operation.factOrder = buf_trn-doc.fact-order
      buf_operation.sysDateXML = buf_trn-doc.sys-date
      buf_operation.dateDocXML = buf_trn-doc.doc-date
      buf_operation.dateFactXML = buf_trn-doc.fact-date
      buf_operation.shiftDateXML = buf_trn-doc.shift-date
      buf_operation.shiftNum = buf_trn-doc.shift-num
      buf_operation.shiftName = buf_trn-doc.shift-name
      buf_operation.extNumber = buf_trn-doc.ord-num
      buf_operation.outNumber = buf_trn-doc.ship-num
      buf_operation.outDateXML = buf_trn-doc.ship-date
      buf_operation.paymentCode = buf_trn-doc.pay-code
      buf_operation.InterFirmDocChild = buf_trn-doc.hold-doc-code-child
      buf_operation.InterFirmDocParent = buf_trn-doc.hold-doc-code-parent
      buf_operation.InterFirmObjType = buf_trn-doc.hold-obj-type
      buf_operation.InterFirmObjCode = buf_trn-doc.hold-obj-code
      buf_operation.reasonCode = buf_trn-doc.reason-code
      buf_operation.outCode = buf_trn-doc.out-code
      buf_operation.comment = buf_trn-doc.PS
      buf_operation.store = buf_trn-doc.obj-type + string(buf_trn-doc.obj-code)
      buf_operation.systime = string(buf_trn-doc.sys-time-int, "HH:MM:SS")
      buf_operation.firm = buf_trn-doc.cli-type + string(buf_trn-doc.cli-code)
      buf_operation.outDateXML = buf_trn-doc.ship-date
      buf_operation.exchCode =  buf_trn-doc.exch-code
      buf_operation.exchRate =  buf_trn-doc.exch-rate
      buf_operation.exchscale  = buf_trn-doc.exch-scale
      buf_operation.dCard = buf_trn-doc.d-card
      buf_operation.office = buf_trn-doc.office
      buf_operation.docQnty = buf_trn-doc.doc-qnty
      buf_operation.factQnty = buf_trn-doc.fact-qnty
      buf_operation.totalSum = ( if buf_trn-doc.print-rubl = yes
                                then buf_trn-doc.tot-rubl
                                else buf_trn-doc.tot-doc )
      buf_operation.totalDsc = ( if buf_trn-doc.print-rubl = yes
                                then buf_trn-doc.discnt-rubl
                                else buf_trn-doc.tot-doc - buf_trn-doc.tot-cli )
      buf_operation.totalFact = (if buf_trn-doc.print-rubl
                                then buf_trn-doc.tot-sale
                                else buf_trn-doc.tot-fact)
      buf_operation.totalDscFact = ( if buf_trn-doc.print-rubl = yes
                                      then buf_trn-doc.discnt-rubl
                                      else buf_trn-doc.tot-calc )
      buf_operation.vatType = buf_trn-doc.vat-Type
      .
    end.
    else do:
      create buf_operation.
      assign
      buf_operation.referenceNo = buf_c-trn-doc.doc-code
      buf_operation.isDel = (v-action = {&gen-line-delete})
      buf_operation.dateDelXml = (if v-action = {&gen-line-delete}
                                  then (if available buf_c-trn-doc
                                        then buf_c-trn-doc.corr-date
                                        else ?)
                                  else ?)
      buf_operation.codeOperation = buf_c-trn-doc.ext-doc-type
      buf_operation.host = buf_c-trn-doc.host-code
      buf_operation.factOrder = buf_c-trn-doc.fact-order
      buf_operation.sysDateXML = buf_c-trn-doc.sys-date
      buf_operation.dateDocXML = buf_c-trn-doc.doc-date
      buf_operation.dateFactXML = buf_c-trn-doc.fact-date
      buf_operation.shiftDateXML = buf_c-trn-doc.shift-date
      buf_operation.shiftNum = buf_c-trn-doc.shift-num
      buf_operation.shiftName = buf_c-trn-doc.shift-name
      buf_operation.extNumber = buf_c-trn-doc.ord-num
      buf_operation.outNumber = buf_c-trn-doc.ship-num
      buf_operation.outDateXML = buf_c-trn-doc.ship-date
      buf_operation.paymentCode = buf_c-trn-doc.pay-code
      buf_operation.InterFirmDocChild = buf_c-trn-doc.hold-doc-code-child
      buf_operation.InterFirmDocParent = buf_c-trn-doc.hold-doc-code-parent
      buf_operation.InterFirmObjType = buf_c-trn-doc.hold-obj-type
      buf_operation.InterFirmObjCode = buf_c-trn-doc.hold-obj-code
      buf_operation.reasonCode = buf_c-trn-doc.reason-code
      buf_operation.outCode = buf_c-trn-doc.out-code
      buf_operation.comment = buf_c-trn-doc.PS
      buf_operation.store = buf_c-trn-doc.obj-type + string(buf_c-trn-doc.obj-code)
      buf_operation.systime = string(buf_c-trn-doc.sys-time-int, "HH:MM:SS")
      buf_operation.firm = buf_c-trn-doc.cli-type + string(buf_c-trn-doc.cli-code)
      buf_operation.outDateXML = buf_c-trn-doc.ship-date
      buf_operation.exchCode =  buf_c-trn-doc.exch-code
      buf_operation.exchRate =  buf_c-trn-doc.exch-rate
      buf_operation.exchscale  = buf_c-trn-doc.exch-scale
      buf_operation.dCard = buf_c-trn-doc.d-card
      buf_operation.office = buf_c-trn-doc.office
      buf_operation.docQnty = buf_c-trn-doc.doc-qnty
      buf_operation.factQnty = buf_c-trn-doc.fact-qnty
      buf_operation.totalSum = ( if buf_c-trn-doc.print-rubl = yes
                                then buf_c-trn-doc.tot-rubl
                                else buf_c-trn-doc.tot-doc )
      buf_operation.totalDsc = ( if buf_c-trn-doc.print-rubl = yes
                                then buf_c-trn-doc.discnt-rubl
                                else buf_c-trn-doc.tot-doc - buf_c-trn-doc.tot-cli )
      buf_operation.totalFact = (if buf_c-trn-doc.print-rubl
                                then buf_c-trn-doc.tot-sale
                                else buf_c-trn-doc.tot-fact)
      buf_operation.totalDscFact = ( if buf_c-trn-doc.print-rubl = yes
                                      then buf_c-trn-doc.discnt-rubl
                                      else buf_c-trn-doc.tot-calc )
      buf_operation.vatType = buf_c-trn-doc.vat-Type
      .
    end.
    if v-action = {&gen-line-delete} then do:
      ExpData1:route-data_create-record( INPUT "operation") .
      ExpData1:route-data_copy-record ( input "operation", buffer buf_operation:handle).
      IF ExpData1:esys-add-dump( INPUT "operation", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи operation &1:&2&3"
                                , buf_trn-doc.doc-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo main-block, retry main-block.
      end.
      return.
    end.
    if buf_trn-doc.doc-type = {&inventory} then do:
       buf_operation.totalPayFact = ?.
    end.
    if (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass})
    then do:
      buf_operation.totalPayFact = ?.
    end.
    if buf_trn-doc.doc-type = {&income} and
      buf_trn-doc.internal = no        then do:
      buf_operation.totalPayFact = buf_trn-doc.tot-calc.
    end.
    else do:
      buf_operation.totalPayFact = (if buf_trn-doc.print-rubl
                                    then (buf_trn-doc.tot-sale - buf_trn-doc.discnt-rubl)
                                    else (buf_trn-doc.tot-fact - buf_trn-doc.tot-calc)
                                    ).
    end.
    { gbl/r-b-curr.i buf_trn-doc.host-code buf_operation.valutCode  }
    find first buf_currency no-lock where
              buf_currency.curr-code = buf_operation.valutCode.
    buf_operation.valutCodeOKV = buf_currency.okv-code.

    { str/tdat-val.i
        buf_trn-doc.doc-code
        {&trdcattr-dov}
        buf_operation.authority
        v-attr-type
    }
    v-date-char = ''.
    { str/tdat-val.i
        buf_trn-doc.doc-code
        {&trdcattr-dids}
        v-date-char
        v-attr-type
    }
    v-date-valid = no.
    run strtdate in this-procedure ( input  v-date-char
                                 , output buf_operation.suppInDocDateXml
                                 , output v-date-valid
                                 , output v-error-message
                                 ) no-error.

    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-nids}
      buf_operation.suppInDocNo
     v-attr-type
    }

    if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}
    then  do:
      if buf_trn-doc.contract-code <> 0
      then do:
        assign
        buf_operation.contractSuppCode = string( buf_trn-doc.contract-code )
        .
        find first buf_contract no-lock
              where buf_contract.host-code       = buf_trn-doc.host-code
                and buf_contract.contract-code   = buf_trn-doc.contract-code
        no-error.
        if available buf_contract
        then do:
          assign
          buf_operation.contractSuppNo          =  buf_contract.contract-prn-code
          buf_operation.contractSuppDateXml          = buf_contract.contract-date
          .
        end.
      end.
    end.        /* if p-ext-doc-type = {&TDEDT_Pri_Vnesh} */
    { str/tdat-val.i
        p-doc-code
        {&trdcattr-ddog}
        v-date-char
        v-attr-type
        no-error
    }
    if error-status :error
    then do:
       &scop my-message  substitute( "*** ERR: *** Ошибка чтения атрибута даты договора для приходной накладной N &1 ", buf_trn-doc.doc-code )
       {&display-message}.
    end.
    v-date-valid = no.
    v-date-char = ''.
    run strtdate in this-procedure ( input v-date-char
                                 , output buf_operation.contractDateXml
                                 , output v-date-valid
                                 , output v-error-message
                                 ) no-error.
    { str/tdat-val.i
        p-doc-code
        {&trdcattr-ndog}
        buf_operation.contractNo
        v-attr-type
        no-error
    }
    if error-status :error
    then do:
      &scop my-message   substitute( "*** ERR: *** Ошибка чтения атрибута номера договора для приходной накладной N &1 ", buf_trn-doc.doc-code )
    end.
    { str/tdat-val.i
        p-doc-code
        {&trdcattr-nsf}
        buf_operation.sfNo
        v-attr-type
    }
    v-date-char = ''.
    { str/tdat-val.i
        p-doc-code
        {&trdcattr-dsf}
        v-date-char
        v-attr-type
    }
    v-date-valid = no.
    run strtdate in this-procedure ( input v-date-char
                                 , output buf_operation.sfDateXml
                                 , output v-date-valid
                                 , output v-error-message
                                 ) no-error.


    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-ndov}
      buf_operation.doverNo
      v-attr-type
    no-error }
    v-date-char = ''.
    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-ddov}
      v-date-char
     v-attr-type
    no-error }
    v-date-valid = no.
    run strtdate in this-procedure ( input v-date-char
                                 , output buf_operation.doverDateXml
                                 , output v-date-valid
                                 , output v-error-message
                                 ) no-error.

    find first buf_ord-chain no-lock
      where buf_ord-chain.rel-doc-code =  buf_trn-doc.doc-code
        and buf_ord-chain.rel-doc-type = 'trn':u
    no-error .
    if available buf_ord-chain
    then do:
      find first buf_ord-doc-rcv no-lock
        where buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code
      no-error .
      if available buf_ord-doc-rcv
      then do:
        assign
        buf_operation.ordDocCode = buf_ord-doc-rcv.doc-code
        buf_operation.ordOutDocCode = buf_ord-doc-rcv.cons-code
        .
      end.
    end.
    
    def var v-value as character no-undo.
    def var v-type  as character no-undo.
    def var v-tech-pass as logical no-undo.
    { str/tdat-val.i                                    
      buf_trn-doc.doc-code
      {&trdcattr-techpass}
      v-value 
      v-type 
      no-error
    }
    assign
      v-tech-pass = yes when v-value = "yes".
    
    if buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} and
    (v-tech-pass or can-find(first ub.sale-doc where ub.sale-doc.doc-code = p-doc-code and ub.sale-doc.doc-kind = {&sale-add-tech-refuell}))
    then do:
      buf_operation.techfuel = yes.
    end.
    ExpData1:route-data_create-record( INPUT "operation") .
    ExpData1:route-data_copy-record ( input "operation", buffer buf_operation:handle).
    IF ExpData1:esys-add-dump( INPUT "operation", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи operation &1:&2&3"
                              , buf_trn-doc.doc-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo main-block, retry main-block.
    end.
    /*---END----------- Суммы по видам кассовых платежей ---------------------*/

    if buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Peresort}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts}
    then do:
        run utl/cuaddsum.p (
            input buf_trn-doc.doc-code
        ) no-error.
        if error-status :error
        then do:

          &scop my-message  substitute( "*** WARN: *** Не удалось проверить документ инвентаризации N: &1. &2. &3. &4" ~
                                    , buf_trn-doc.doc-code ~
                                    , return-value ~
                                    , trim(error-status :get-message(1)) ~
                                    , trim(error-status :get-message(2)) ~
                                )

          {&display-message}.
        end.
        define variable v-exists-before as logical no-undo .
        define variable v-exists-after as logical no-undo .
        run export-before-and-after-inv-trn in this-procedure (
              input buf_trn-doc.doc-code
            , output v-exists-before
            , output v-exists-after
        ).
    end.        /* if p-ext-doc-type = {&TDEDT_Inv} */


    for each buf_doc-line no-lock where
            buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error  undo main-block, retry  main-block
    on stop   undo main-block, retry  main-block
    on endkey undo main-block, retry  main-block
    :
      v-scale-is-empty = no.
      find first buf_goods no-lock where
              buf_goods.artic = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code no-error.
      if available buf_goods then do:
        find first buf_units no-lock where
                buf_units.unit-name = buf_goods.unit-base no-error.
        { gbl/gdsat.i
         buf_goods.artic
         buf_goods.prod-type
         buf_goods.prod-code
         'empty-scale=request':u
         v-scale-is-empty
        }
        { str/is-petrl.i
          buf_goods.artic
          buf_goods.prod-type
          buf_goods.prod-code
          v-is-petrol
          v-is-pieces
        }
        if v-is-petrol  = yes
        and v-is-pieces = no
        then do:
          run get-petrol-weight in this-procedure (
                                                    input buf_trn-doc.ext-doc-type
                                                  , input recid( buf_doc-line )
                                                  , input buf_trn-doc.out-code
                                                  , output v-petrol-weight
                                                  , output v-weight-not-specified
                                              ).
          if v-weight-not-specified = no
          then do:
              assign
              v-petrol-density = ( if buf_doc-line.fact-qnty = 0
                                  then 0
                                  else v-petrol-weight / buf_doc-line.fact-qnty )
              .
          end.
          if buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
          or buf_trn-doc.ext-doc-type = {&TDEDT_Peresort}
          or buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}
          or buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts}
          then do:
            define buffer buf_inv-line      for ub.inv-line.
            find first buf_inv-line no-lock
                  where buf_inv-line.doc-code  = buf_doc-line.doc-code
                    and buf_inv-line.artic     = buf_doc-line.artic
                    and buf_inv-line.prod-type = buf_doc-line.prod-type
                    and buf_inv-line.prod-code = buf_doc-line.prod-code
            no-error.
            if available buf_inv-line
            then do:
              linedoc.petrolInvFactStk = buf_inv-line.after-cli-qnty.
            end.
          end.
          define variable v-before-qnty      as decimal      no-undo.
          define variable v-after-qnty       as decimal      no-undo.
          define variable v-diff-qnty        as decimal      no-undo.
          define variable v-abs-diff-qnty    as decimal      no-undo.
          { str/getwtqty.i
            buf_doc-line.doc-code
            buf_doc-line.artic
            buf_doc-line.prod-type
            buf_doc-line.prod-code
              v-before-qnty
              v-after-qnty
              v-diff-qnty
              v-abs-diff-qnty
              no-error
          }
          if error-status :error
          then do:
            &scop my-message  substitute( "*** ERR *** Ошибка вычисления количеств до и после для топлива. Документ &1. Товар &2 &3 &4. &5. &6. &7. &8." ~
                                          , buf_doc-line.doc-code ~
                                          , buf_doc-line.artic   ~
                                          , buf_doc-line.prod-type  ~
                                          , buf_doc-line.prod-code  ~
                                          , return-value ~
                                          , trim(error-status :get-message(1)) ~
                                          , trim(error-status :get-message(2))  ~
                                          , trim(error-status :get-message(3)) ~
            {&display-message}.
          end.
          else do:
            if buf_trn-doc.ext-doc-type <> {&TDEDT_Inv}
            and buf_trn-doc.ext-doc-type <> {&TDEDT_Peresort}
            and buf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Acc_Price}
            and buf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Minus_Parts}
            then do:
              assign
              v-diff-qnty     = ( buf_doc-line.doc-qnty - buf_doc-line.fact-qnty ) * v-diff-qnty / buf_doc-line.fact-qnty
              v-abs-diff-qnty = absolute( v-diff-qnty )
              .
            end.
            assign
            linedoc.petrolBeforeQnty =  v-before-qnty
            linedoc.petrolAfterQnty =  v-after-qnty
            linedoc.petrolDiffQnty  =  v-diff-qnty
            linedoc.petrolAbsDiffQnty = v-abs-diff-qnty
            .
          end.
        end.
      end.
      else do:
        release buf_units no-error.
      end.

      define variable v-parts-cst-code  like parts.cst-code     no-undo.
      define variable v-parts-price-sale as decimal no-undo .
      for each buf_parts no-lock
          where buf_parts.out-code   = buf_trn-doc.doc-code
              and buf_parts.obj-type   = buf_trn-doc.obj-type
              and buf_parts.obj-code   = buf_trn-doc.obj-code
              and buf_parts.prod-type  = buf_doc-line.prod-type
              and buf_parts.prod-code  = buf_doc-line.prod-code
              and buf_parts.artic      = buf_doc-line.artic
              and buf_parts.status_    = true
      on error undo main-block, retry main-block
      on stop undo main-block, retry main-block
      :
        create buf_part.
        assign
        buf_part.referenceNo = buf_trn-doc.doc-code
        buf_part.good = (if available buf_goods then buf_goods.gds-code else 0)
        buf_part.contractSuppCode = ''
        buf_part.contractSuppNo = ''
        buf_part.contractSuppDateXml = ?
        .
        { str/in-vatp.i calc-parts buf_parts. " " loc}
        v-parts-price-sale = ?.
        if buf_doc-line.is-parts = true
        and available buf_goods then do:
          define variable main-b-code as integer no-undo .
          { gbl/gdsbcode.i
            buf_goods.gds-code
            ?
            main-b-code
            no-error
          }
          if not error-status:error then do:
            define variable v-doc-num as character no-undo .
            define variable parts-b-code as integer no-undo .
            define variable for-road as decimal no-undo .
            define variable for-excise as decimal no-undo .
            { gbl/partbcod.i
              buf_parts
              parts-b-code
              no-error
            }
            if not error-status:error then do:
              { gbl/bcodeprc.i
                buf_trn-doc.obj-type
                buf_trn-doc.obj-code
                parts-b-code
                main-b-code
                0
                v-doc-num
                v-parts-price-sale
                for-road
                for-excise
                no-error
              }
            end.
          end.
        end. /*if buf_doc-line.is-parts = yes*/
        ASSIGN
        buf_part.qnty         = buf_parts.fact-qnty
        buf_part.sumr         = price-rubl-with-tax-loc * buf_part.qnty
        buf_part.vatr         = vat-rubl-loc            * buf_part.qnty
        /*buf_part.sltr         = slt-rubl-loc            * buf_part.qnty*/
        buf_part.roadtaxr     = road-tax-rubl-loc       * buf_part.qnty
        buf_part.transportr   = transport-rubl-loc      * buf_part.qnty
        buf_part.otherr       = other-rubl-loc          * buf_part.qnty
        buf_part.exciser      = 0
        buf_part.sumb         = price-base-with-tax-loc * buf_part.qnty
        buf_part.vatb         = vat-base-loc            * buf_part.qnty
        /*buf_part.sltb         = slt-base-loc            * buf_part.qnty*/
        buf_part.roadtaxb     = road-tax-base-loc       * buf_part.qnty
        buf_part.transportb   = transport-base-loc      * buf_part.qnty
        buf_part.otherb       = other-base-loc          * buf_part.qnty
        buf_part.exciseb      = 0
        buf_part.hostCode     = buf_parts.host-code
        buf_part.contractCode = string(buf_parts.contract-code)
        buf_part.priceCli     = buf_parts.price-cli
        buf_part.cliBaseRate  = buf_parts.cli-base-rate
        buf_part.vatType      = buf_parts.vat-type
        buf_part.exchCode     = buf_parts.exch-code
        buf_part.lastDate     = buf_parts.last-date
        buf_part.priceb       = buf_parts.price-base
        buf_part.pricer       = buf_parts.price-rubl
        buf_part.salePrice    = v-parts-price-sale
        buf_part.fib          = buf_parts.whole-send-news
        buf_part.purch-code   = buf_parts.purch-code
        .
        { gbl/partppric.i
          buf_parts
          buf_part.prodPrice
          v-prodPricewithvat
          v-prodvat
          }



        if buf_parts.contract-code <> 0
        then do:
          assign
          buf_part.contractSuppCode = string( buf_parts.contract-code )
          .
          find first buf_contract no-lock
                  where buf_contract.host-code       = buf_trn-doc.host-code
                  and buf_contract.contract-code   = buf_parts.contract-code
          no-error.
          if available buf_contract
          then do:
            assign
            buf_part.contractSuppNo = string( buf_contract.contract-prn-code )
            buf_part.contractSuppDateXML = buf_contract.contract-date
            .
          end.
        end.
        if available buf_goods
        then do:
          find first buf_parts-attr no-lock
                  where buf_parts-attr.in-code   = buf_parts.in-code
                  and buf_parts-attr.gds-code  = buf_goods.gds-code
                  and buf_parts-attr.part-code = buf_parts.part-code
          no-error .
          if available buf_parts-attr
          then do:
            assign
            buf_part.supp         = buf_parts-attr.supp-type + string(buf_parts-attr.supp-code)
            buf_part.doc_ID       = buf_parts-attr.income-in-code
            buf_part.PartCode     = buf_parts-attr.income-part-code
            buf_part.cst          = buf_parts-attr.cst-code
            buf_part.countryCode  = string(buf_parts-attr.country-code)
            buf_part.attrExchRate = buf_parts-attr.exch-rate
            buf_part.attrExchScale = buf_parts-attr.exch-scale
            buf_part.attrUnitCli  = buf_parts-attr.unit-cli
            .
          end.        /* if available buf_parts-attr */
          else do:
            assign
            buf_part.supp         = buf_parts.supp-type + string(buf_parts.supp-code)
            buf_part.doc_ID       = buf_parts.in-code
            buf_part.Partcode     = buf_parts.part-code
            buf_part.cst          = buf_parts.cst-code
            buf_part.countryCode  = ''
            buf_part.attrExchRate = 0.0
            buf_part.attrExchScale = 0
            buf_part.attrUnitCli  = ''
            .
          end.        /* NOT ( if available buf_parts-attr ) */
        end.        /* if available buf_goods */
        else do:
          assign
          buf_part.supp         = buf_parts.supp-type + string(buf_parts.supp-code)
          buf_part.doc_ID       = buf_parts.in-code
          buf_part.PartCode    = buf_parts.part-code
          buf_part.cst          = buf_parts.cst-code
          buf_part.countryCode  = ''
          buf_part.attrExchRate = 0.0
          buf_part.attrExchScale = 0
          buf_part.attrUnitCli  = ''
          .
        end.        /* NOT ( if available buf_goods ) */
        assign
        v-parts-cst-code = v-parts-cst-code
                            + ( if ( buf_part.cst <> ?
                                and trim( buf_part.cst )   <> ""
                                and trim( v-parts-cst-code ) <> "" )
                                then "; "
                                else ""  )
                            + buf_part.cst.
        .
      end. /*      for each buf_parts no-lock*/
      if not available linedoc then do:
        create linedoc.
      end.
      assign
      linedoc.referenceNo = buf_doc-line.doc-code
      linedoc.good  = (if available buf_goods then buf_goods.gds-code else 0)
      linedoc.artic = buf_doc-line.artic
      linedoc.prodType = buf_doc-line.prod-type
      linedoc.prodCode = buf_doc-line.prod-code
      linedoc.type = (if available buf_goods then buf_goods.gds-type else '')
      linedoc.unitType = (if available buf_units then buf_units.type else '')
      linedoc.wait = buf_doc-line.wt-brutto
      linedoc.place = buf_doc-line.num-place
      linedoc.priceCli = buf_doc-line.price-cli
      linedoc.cliBaseRate = buf_doc-line.cli-base-rate
      linedoc.quantity = buf_doc-line.fact-qnty
      linedoc.vatpc = buf_doc-line.vat-pc
      linedoc.petrolweight = v-petrol-weight
      linedoc.petroldensity = v-petrol-density
      linedoc.CSTCode = v-parts-cst-code
      linedoc.cashParts = (buf_doc-line.is-parts = true )
      .
      ExpData1:route-data_create-record( INPUT "linedoc") .
      if v-linedoc-hidden = no then do:
        IF ExpData1:esys-add-dump( INPUT "linedoc", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_hidden=referenceNo') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи по накладной &1:&2&3"
                                  , buf_trn-doc.doc-code
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
        v-linedoc-hidden = yes.
      end.
      ExpData1:route-data_copy-record ( input "linedoc", buffer linedoc:handle).
      IF ExpData1:esys-add-dump( INPUT "linedoc", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи по накладной &1 (товар &2 &3&4):&5&6"
                                , buf_trn-doc.doc-code
                                , buf_doc-line.artic
                                , buf_doc-line.prod-type
                                , buf_doc-line.prod-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo main-block, retry main-block.
      end.
      if v-scale-is-empty = no
      then do:
        for each buf_gds-dtl no-lock
          where buf_gds-dtl.prod-type  = buf_Doc-line.prod-type
            and buf_gds-dtl.prod-code  = buf_doc-line.prod-code
            and buf_gds-dtl.artic      = buf_doc-line.artic
            and buf_gds-dtl.doc-code   = buf_doc-line.doc-code
        :
          find first buf_gds-prt no-lock
              where buf_gds-prt.node-code = buf_gds-dtl.prt-code
          no-error .
          { str/out-vatp.i calc-gds-dtl buf_doc-line. buf_trn-doc. buf_gds-dtl. }
          if not available dtl then do:
            create dtl.
          end.
          assign
          dtl.referenceNo = buf_trn-doc.doc-code
          dtl.good = (if available buf_goods then buf_goods.gds-code else 0)
          dtl.prtCode = (if available buf_gds-prt then buf_gds-prt.node-code else 0)
          dtl.dtlName = (if available buf_gds-prt then buf_gds-prt.f-name else '')
          dtl.qnty = buf_gds-dtl.fact-qnty
          dtl.sumr = price-rubl-with-tax-sale * buf_gds-dtl.fact-qnty
          dtl.VATr = vat-rubl-buyer * buf_gds-dtl.fact-qnty
          /*dtl.SLTr = slt-rubl-sale * buf_gds-dtl.fact-qnty*/
          dtl.roadTaxr = road-tax-rubl-sale  * buf_gds-dtl.fact-qnty
          dtl.sumb = price-base-with-tax-sale * buf_gds-dtl.fact-qnty
          dtl.VATb = vat-base-buyer * buf_gds-dtl.fact-qnty
          /*dtl.SLTb = slt-base-sale * buf_gds-dtl.fact-qnty*/
          dtl.roadTaxb = road-tax-base-sale  * buf_gds-dtl.fact-qnty
          .
          ExpData1:route-data_create-record( INPUT "dtl") .
          if v-dtl-hidden = no then do:
            IF ExpData1:esys-add-dump( INPUT "dtl", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_hidden=referenceNo') = false  THEN do:
              v-err-mess = substitute("Ошибка при маршрутизации записи по накладной &1:&2&3"
                                      , buf_trn-doc.doc-code
                                      , {&new-line}
                                      , v-last-error-message
                                      ).
              undo main-block, retry main-block.
            end.
            v-dtl-hidden = yes.
          end.
          ExpData1:route-data_copy-record ( input "dtl", buffer dtl:handle).
          IF ExpData1:esys-add-dump( INPUT "dtl", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи dtl &1:&2&3"
                                    , buf_trn-doc.doc-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo main-block, retry main-block.
          end.
        end.        /* for each buf_gds-dtl no-lock */
      end. /*if v-scale-is-empty = no*/
      for each buf_part:
        ExpData1:route-data_create-record( INPUT "part") .
        ExpData1:route-data_copy-record ( input "part", buffer buf_part:handle).
        IF ExpData1:esys-add-dump( INPUT "part", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи part &1:&2&3"
                                  , buf_trn-doc.doc-code
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
        delete buf_part.
      end. /*  for each buf_part:*/
    end. /*    for each buf_doc-line no-lock where*/
    if buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Peresort}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts}
    then do:
        run export-before-and-after-inv-line in this-procedure (
                input buf_trn-doc.doc-code
            , input (if available buf_goods then buf_goods.gds-code else 0)
            , input v-exists-before
            , input v-exists-after
            , input ( v-is-petrol = yes and v-is-pieces = no and v-weight-not-specified  = no )
            , input v-petrol-density
        ).
    end.        /* if p-ext-doc-type = {&TDEDT_Inv} */

    if available buf_operation then delete buf_operation.
  end. /*not retry*/
end.

end procedure. /* edocstrn_export */

procedure get-petrol-weight :
do
on error undo, return error
:
define input parameter p-ext-doc-type           as character    no-undo.
define input parameter p-doc-line-recid         as recid        no-undo.
define input parameter p-trn-doc-out-code       as character    no-undo.
define output parameter p-petrol-weight         as decimal      no-undo.
define output parameter p-weight-not-specified  as logical      no-undo.

    define variable v-rvs-code              as character     no-undo.
    define variable v-found-last-rvs-doc    as logical       no-undo.

    define buffer buf_doc-line      for doc-line.
    define buffer buf_rvs-doc       for rvs-doc.
    define buffer buf_rvs-line      for rvs-line.
    define buffer buf_goods         for goods.
    define buffer buf_doc-pl        for doc-pl.

    find first buf_doc-line no-lock
        where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_doc-line.artic
           and buf_goods.prod-type  = buf_doc-line.prod-type
           and buf_goods.prod-code  = buf_doc-line.prod-code
    .
    assign
        p-weight-not-specified = yes
    .
    case p-ext-doc-type:
        when {&TDEDT_Pri_Vnesh}
        then do:
            assign
                p-petrol-weight        = buf_doc-line.fact-qnty * buf_doc-line.fact-density
                p-weight-not-specified = no
            .
        end.        /* when {&TDEDT_Pri_Vnesh} */
        when {&TDEDT_Inv}
        or when {&TDEDT_Peresort}
        or when {&TDEDT_Corr_Acc_Price}
        or when {&TDEDT_Corr_Minus_Parts}
        then do:
            find first buf_rvs-doc no-lock
                 where buf_rvs-doc.rvs-code = p-trn-doc-out-code
                   and buf_rvs-doc.status_  = {&fact}
            no-error.
            if available buf_rvs-doc
            then do:
                assign
                    v-rvs-code           = buf_rvs-doc.rvs-code
                .
                for each buf_doc-pl no-lock
                   where buf_doc-pl.out-code = buf_doc-line.doc-code
                     and buf_doc-pl.gds-code = buf_goods.gds-code
                     and buf_doc-pl.obj-type = buf_doc-line.obj-type
                     and buf_doc-pl.obj-code = buf_doc-line.obj-code
                on error undo, return error
                :
                    for each buf_rvs-line no-lock
                       where buf_rvs-line.gds-code  = buf_doc-pl.gds-code
                         and buf_rvs-line.rvs-code  = v-rvs-code
                         and buf_rvs-line.obj-type  = buf_doc-pl.obj-type
                         and buf_rvs-line.obj-code  = buf_doc-pl.obj-code
                         and buf_rvs-line.pl-code   = buf_doc-pl.pl-code
                    on error undo, return error
                    :
                        assign
                            p-petrol-weight         = p-petrol-weight + buf_doc-pl.fact-qnty * buf_rvs-line.state-density
                            p-weight-not-specified  = no
                        .
                    end.
                end.        /* for each buf_doc-pl */
            end.        /* available buf_rvs-doc */
            else do:
                assign
                    v-found-last-rvs-doc = no
                .
                find-last-rvs:
                for each buf_rvs-doc no-lock
                   where buf_rvs-doc.obj-type = buf_doc-line.obj-type
                     and buf_rvs-doc.obj-code = buf_doc-line.obj-code
                     and buf_rvs-doc.status_  = {&fact}
                use-index shift
                on error undo, return error
                :
                    assign
                        v-rvs-code           = buf_rvs-doc.rvs-code
                    .
                    for each buf_doc-pl no-lock
                       where buf_doc-pl.out-code = buf_doc-line.doc-code
                         and buf_doc-pl.gds-code = buf_goods.gds-code
                         and buf_doc-pl.obj-type = buf_doc-line.obj-type
                         and buf_doc-pl.obj-code = buf_doc-line.obj-code
                    on error undo, return error
                    :
                        for each buf_rvs-line no-lock
                           where buf_rvs-line.gds-code  = buf_doc-pl.gds-code
                             and buf_rvs-line.rvs-code  = v-rvs-code
                             and buf_rvs-line.obj-type  = buf_doc-pl.obj-type
                             and buf_rvs-line.obj-code  = buf_doc-pl.obj-code
                             and buf_rvs-line.pl-code   = buf_doc-pl.pl-code
                        on error undo, return error
                        :
                            assign
                                v-found-last-rvs-doc    = yes
                                p-petrol-weight         = p-petrol-weight + buf_doc-pl.fact-qnty * buf_rvs-line.state-density
                                p-weight-not-specified  = no
                            .
                            leave find-last-rvs.
                        end.
                    end.        /* for each buf_doc-pl */
                end.        /* for each buf_rvs-doc no-lock */
            end.        /* not available buf_rvs-doc */
        end.        /* when {&TDEDT_Inv} */
        otherwise do:
            assign
                p-weight-not-specified = yes
            .
        end.        /* otherwise */
    end case.
end.
end procedure. /* get-petrol-weight */

procedure export-before-and-after-inv-trn :
define input parameter p-doc-code as character no-undo .
define output parameter p-exists-before as logical no-undo .
define output parameter p-exists-after as logical no-undo .

define variable v-attr-value    as character     no-undo.
define variable v-attr-type     as character     no-undo.
define variable v-bh as handle no-undo .
define variable v-err-mess as character no-undo .

define buffer buf_trn-doc-sum       for ub.trn-doc-sum.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    { str/tdat-val.i
        p-doc-code
        {&trdcattr-addsum}
        v-attr-value
        v-attr-type
    }
    if lookup( {&sum-before-doc}, v-attr-value ) <> 0
    then do:
        assign
            p-exists-before = yes
        .
        find first buf_trn-doc-sum no-lock
             where buf_trn-doc-sum.doc-code = p-doc-code
               and buf_trn-doc-sum.sum-type = {&sum-before-doc}
        no-error.
        if available buf_trn-doc-sum
        then do:
          create beforesum.
          assign
          beforesum.referenceNo = buf_trn-doc-sum.doc-code
          beforesum.qnty = buf_trn-doc-sum.fact-qnty
          .
          ExpData1:route-data_create-record( INPUT "beforeSum") .
          ExpData1:route-data_copy-record ( input "beforeSum", buffer beforesum:handle).
          IF ExpData1:esys-add-dump( INPUT "beforeSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи beforeSum &1:&2&3"
                                    , p-doc-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo main-block, return error v-err-mess.
          end.
          create salesumbeforesum.
          buffer-copy beforesum to salesumbeforesum
          assign
          saleSumBeforeSum.sumR = buf_trn-doc-sum.crsa-sum-rubl
          saleSumBeforeSum.vatR = buf_trn-doc-sum.crsa-vat-rubl
          /*saleSumBeforeSum.sltR = buf_trn-doc-sum.crsa-slt-rubl*/
          saleSumBeforeSum.roadTaxR = buf_trn-doc-sum.crsa-road-tax-rubl
          saleSumBeforeSum.transportR = buf_trn-doc-sum.crsa-transport-rubl
          saleSumBeforeSum.otherR = buf_trn-doc-sum.crsa-other-rubl
          saleSumBeforeSum.exciseR = buf_trn-doc-sum.crsa-excise-rubl
          saleSumBeforeSum.sumb = buf_trn-doc-sum.crsa-sum-base
          saleSumBeforeSum.vatb = buf_trn-doc-sum.crsa-vat-base
          /*saleSumBeforeSum.sltb = buf_trn-doc-sum.crsa-slt-base*/
          saleSumBeforeSum.roadTaxb = buf_trn-doc-sum.crsa-road-tax-base
          saleSumBeforeSum.transportb = buf_trn-doc-sum.crsa-transport-base
          saleSumBeforeSum.otherb = buf_trn-doc-sum.crsa-other-base
          saleSumBeforeSum.exciseb = buf_trn-doc-sum.crsa-excise-base
          .
          ExpData1:route-data_create-record( INPUT "saleSumBeforeSum") .
          ExpData1:route-data_copy-record ( input "saleSumBeforeSum", buffer salesumbeforesum:handle).
          IF ExpData1:esys-add-dump( INPUT "saleSumBeforeSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи saleSumBeforeSum &1:&2&3"
                                    , p-doc-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo main-block, return error v-err-mess.
          end.
          create costsumbeforesum.
          buffer-copy beforesum to costsumbeforesum
          assign
          costsumBeforeSum.sumR = buf_trn-doc-sum.crsa-sum-rubl
          costsumBeforeSum.vatR = buf_trn-doc-sum.crsa-vat-rubl
          /*costsumBeforeSum.sltR = buf_trn-doc-sum.crsa-slt-rubl*/
          costsumBeforeSum.roadTaxR = buf_trn-doc-sum.crsa-road-tax-rubl
          costsumBeforeSum.transportR = buf_trn-doc-sum.crsa-transport-rubl
          costsumBeforeSum.otherR = buf_trn-doc-sum.crsa-other-rubl
          costsumBeforeSum.exciseR = buf_trn-doc-sum.crsa-excise-rubl
          costsumBeforeSum.sumb = buf_trn-doc-sum.crsa-sum-base
          costsumBeforeSum.vatb = buf_trn-doc-sum.crsa-vat-base
          /*costsumBeforeSum.sltb = buf_trn-doc-sum.crsa-slt-base*/
          costsumBeforeSum.roadTaxb = buf_trn-doc-sum.crsa-road-tax-base
          costsumBeforeSum.transportb = buf_trn-doc-sum.crsa-transport-base
          costsumBeforeSum.otherb = buf_trn-doc-sum.crsa-other-base
          costsumBeforeSum.exciseb = buf_trn-doc-sum.crsa-excise-base
          .
          ExpData1:route-data_create-record( INPUT "costsumBeforeSum") .
          ExpData1:route-data_copy-record ( input "costsumBeforeSum", buffer costsumbeforesum:handle).
          IF ExpData1:esys-add-dump( INPUT "costsumBeforeSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи costsumBeforeSum &1:&2&3"
                                    , p-doc-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo main-block, return error v-err-mess.
          end.
        end.        /* available buf_trn-doc-sum */
        else do:
          v-err-mess = "*** ERR: *** Не найдена запись trn-doc-sum с sum-type = {&sum-before-doc} для документа " + string( p-doc-code ).
        end.        /* NOT ( available buf_trn-doc-sum ) */
    end.        /* if lookup( {&sum-before-doc}, v-attr-value ) <> 0 */
    if lookup( {&sum-after-doc}, v-attr-value ) <> 0
    then do:
        assign
            p-exists-after  = yes
        .
        find first buf_trn-doc-sum no-lock
             where buf_trn-doc-sum.doc-code = p-doc-code
               and buf_trn-doc-sum.sum-type = {&sum-after-doc}
        no-error.
        if available buf_trn-doc-sum
        then do:
          create aftersum.
          assign
          aftersum.referenceNo = buf_trn-doc-sum.doc-code
          aftersum.qnty = buf_trn-doc-sum.fact-qnty
          .
          ExpData1:route-data_create-record( INPUT "afterSum") .
          ExpData1:route-data_copy-record ( input "afterSum", buffer aftersum:handle).
          IF ExpData1:esys-add-dump( INPUT "afterSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи afterSum &1:&2&3"
                                    , p-doc-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo main-block, return error v-err-mess.
          end.
          create salesumaftersum.
          buffer-copy aftersum to salesumaftersum
          assign
          saleSumafterSum.sumR = buf_trn-doc-sum.crsa-sum-rubl
          saleSumafterSum.vatR = buf_trn-doc-sum.crsa-vat-rubl
          /*saleSumafterSum.sltR = buf_trn-doc-sum.crsa-slt-rubl*/
          saleSumafterSum.roadTaxR = buf_trn-doc-sum.crsa-road-tax-rubl
          saleSumafterSum.transportR = buf_trn-doc-sum.crsa-transport-rubl
          saleSumafterSum.otherR = buf_trn-doc-sum.crsa-other-rubl
          saleSumafterSum.exciseR = buf_trn-doc-sum.crsa-excise-rubl
          saleSumafterSum.sumb = buf_trn-doc-sum.crsa-sum-base
          saleSumafterSum.vatb = buf_trn-doc-sum.crsa-vat-base
          /*saleSumafterSum.sltb = buf_trn-doc-sum.crsa-slt-base*/
          saleSumafterSum.roadTaxb = buf_trn-doc-sum.crsa-road-tax-base
          saleSumafterSum.transportb = buf_trn-doc-sum.crsa-transport-base
          saleSumafterSum.otherb = buf_trn-doc-sum.crsa-other-base
          saleSumafterSum.exciseb = buf_trn-doc-sum.crsa-excise-base
          .
          ExpData1:route-data_create-record( INPUT "saleSumafterSum") .
          ExpData1:route-data_copy-record ( input "saleSumafterSum", buffer salesumaftersum:handle).
          IF ExpData1:esys-add-dump( INPUT "saleSumafterSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи saleSumafterSum &1:&2&3"
                                    , p-doc-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo main-block, return error v-err-mess.
          end.
          create costsumaftersum.
          buffer-copy aftersum to costsumaftersum
          assign
          costsumafterSum.sumR = buf_trn-doc-sum.crsa-sum-rubl
          costsumafterSum.vatR = buf_trn-doc-sum.crsa-vat-rubl
          /*costsumafterSum.sltR = buf_trn-doc-sum.crsa-slt-rubl*/
          costsumafterSum.roadTaxR = buf_trn-doc-sum.crsa-road-tax-rubl
          costsumafterSum.transportR = buf_trn-doc-sum.crsa-transport-rubl
          costsumafterSum.otherR = buf_trn-doc-sum.crsa-other-rubl
          costsumafterSum.exciseR = buf_trn-doc-sum.crsa-excise-rubl
          costsumafterSum.sumb = buf_trn-doc-sum.crsa-sum-base
          costsumafterSum.vatb = buf_trn-doc-sum.crsa-vat-base
          /*costsumafterSum.sltb = buf_trn-doc-sum.crsa-slt-base*/
          costsumafterSum.roadTaxb = buf_trn-doc-sum.crsa-road-tax-base
          costsumafterSum.transportb = buf_trn-doc-sum.crsa-transport-base
          costsumafterSum.otherb = buf_trn-doc-sum.crsa-other-base
          costsumafterSum.exciseb = buf_trn-doc-sum.crsa-excise-base
          .
          ExpData1:route-data_create-record( INPUT "costsumafterSum") .
          ExpData1:route-data_copy-record ( input "costsumafterSum", buffer costsumaftersum:handle).
          IF ExpData1:esys-add-dump( INPUT "costsumafterSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи costsumafterSum &1:&2&3"
                                    , p-doc-code
                                    , {&new-line}
                                    , v-last-error-message
                                    ).
            undo main-block, return error v-err-mess.
          end.
        end.        /* available buf_trn-doc-sum */
        else do:
          v-err-mess = "*** ERR: *** Не найдена запись trn-doc-sum с sum-type = {&sum-after-doc} для документа " + string( p-doc-code ).
          undo main-block, return error v-err-mess.
        end.        /* NOT ( available buf_trn-doc-sum ) */
    end.        /* if lookup( {&sum-after-doc}, v-attr-value ) <> 0 */
  end.

end procedure. /* export-before-and-after-inv-trn */



procedure export-before-and-after-inv-line :
define input parameter p-doc-code           as character    no-undo.
define input parameter p-gds-code           as integer      no-undo.
define input parameter p-exists-before      as logical      no-undo.
define input parameter p-exists-after       as logical      no-undo.
define input parameter p-need-petrol-weight as logical      no-undo.
define input parameter p-petrol-density     as decimal      no-undo.

define variable v-err-mess as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


define buffer buf_doc-line-sum      for ub.doc-line-sum.

empty temp-table beforesumline.
empty temp-table salesumbeforesumline.
empty temp-table costsumbeforesumline.
empty temp-table aftersumline.
empty temp-table salesumaftersumline.
empty temp-table costsumaftersumline.



if p-exists-before = yes
then do:
  find first buf_doc-line-sum no-lock
        where buf_doc-line-sum.doc-code = p-doc-code
          and buf_doc-line-sum.gds-code = p-gds-code
          and buf_doc-line-sum.sum-type = {&sum-before-doc}
  no-error.
  if available buf_doc-line-sum
  then do:
    create beforesumline.
    assign
    beforesumline.referenceNo = buf_doc-line-sum.doc-code
    beforesumline.qnty = buf_doc-line-sum.fact-qnty
    beforesumline.petrolweight = buf_doc-line-sum.fact-qnty * p-petrol-density
    beforesumline.good = p-gds-code
    .
    ExpData1:route-data_create-record( INPUT "beforeSumLine") .
    ExpData1:route-data_copy-record ( input "beforeSumLine", buffer beforesumline:handle).
    IF ExpData1:esys-add-dump( INPUT "beforeSumLine", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи beforeSumLine &1:&2&3"
                              , p-doc-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
    create salesumbeforesumline.
    buffer-copy beforesumline to salesumbeforesumline
    assign
    saleSumBeforeSumLine.sumR = buf_doc-line-sum.crsa-sum-rubl
    saleSumBeforeSumLine.vatR = buf_doc-line-sum.crsa-vat-rubl
    /*saleSumBeforeSumLine.sltR = buf_doc-line-sum.crsa-slt-rubl*/
    saleSumBeforeSumLine.roadTaxR = buf_doc-line-sum.crsa-road-tax-rubl
    saleSumBeforeSumLine.transportR = buf_doc-line-sum.crsa-transport-rubl
    saleSumBeforeSumLine.otherR = buf_doc-line-sum.crsa-other-rubl
    saleSumBeforeSumLine.exciseR = buf_doc-line-sum.crsa-excise-rubl
    saleSumBeforeSumLine.sumb = buf_doc-line-sum.crsa-sum-base
    saleSumBeforeSumLine.vatb = buf_doc-line-sum.crsa-vat-base
    /*saleSumBeforeSumLine.sltb = buf_doc-line-sum.crsa-slt-base*/
    saleSumBeforeSumLine.roadTaxb = buf_doc-line-sum.crsa-road-tax-base
    saleSumBeforeSumLine.transportb = buf_doc-line-sum.crsa-transport-base
    saleSumBeforeSumLine.otherb = buf_doc-line-sum.crsa-other-base
    saleSumBeforeSumLine.exciseb = buf_doc-line-sum.crsa-excise-base
    .
    ExpData1:route-data_create-record( INPUT "saleSumBeforeSumLine") .
    ExpData1:route-data_copy-record ( input "saleSumBeforeSumLine", buffer salesumbeforesumline:handle).
    IF ExpData1:esys-add-dump( INPUT "saleSumBeforeSumLine", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи saleSumBeforeSumLine &1:&2&3"
                              , p-doc-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
    create costsumbeforesumline.
    buffer-copy beforesumline to costsumbeforesumline
    assign
    costsumBeforeSumLine.sumR = buf_doc-line-sum.crsa-sum-rubl
    costsumBeforeSumLine.vatR = buf_doc-line-sum.crsa-vat-rubl
    /*costsumBeforeSumLine.sltR = buf_doc-line-sum.crsa-slt-rubl*/
    costsumBeforeSumLine.roadTaxR = buf_doc-line-sum.crsa-road-tax-rubl
    costsumBeforeSumLine.transportR = buf_doc-line-sum.crsa-transport-rubl
    costsumBeforeSumLine.otherR = buf_doc-line-sum.crsa-other-rubl
    costsumBeforeSumLine.exciseR = buf_doc-line-sum.crsa-excise-rubl
    costsumBeforeSumLine.sumb = buf_doc-line-sum.crsa-sum-base
    costsumBeforeSumLine.vatb = buf_doc-line-sum.crsa-vat-base
    /*costsumBeforeSumLine.sltb = buf_doc-line-sum.crsa-slt-base*/
    costsumBeforeSumLine.roadTaxb = buf_doc-line-sum.crsa-road-tax-base
    costsumBeforeSumLine.transportb = buf_doc-line-sum.crsa-transport-base
    costsumBeforeSumLine.otherb = buf_doc-line-sum.crsa-other-base
    costsumBeforeSumLine.exciseb = buf_doc-line-sum.crsa-excise-base
    .
    ExpData1:route-data_create-record( INPUT "costsumBeforeSumLine") .
    ExpData1:route-data_copy-record ( input "costsumBeforeSumLine", buffer costsumbeforesumline:handle).
    IF ExpData1:esys-add-dump( INPUT "costsumBeforeSumLine", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи costsumBeforeSumLine &1:&2&3"
                              , p-doc-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
  end.        /* available buf_trn-doc-sum */
  else do:
    v-err-mess = "*** ERR: *** Не найдена запись doc-line-sum с sum-type = {&sum-before-doc} для документа " + string( p-doc-code ).
  end.        /* NOT ( available buf_doc-line-sum ) */
end. /*if p-exists-before = yes*/
if p-exists-after = yes
then do:
  find first buf_doc-line-sum no-lock
        where buf_doc-line-sum.doc-code = p-doc-code
          and buf_doc-line-sum.gds-code = p-gds-code
          and buf_doc-line-sum.sum-type = {&sum-after-doc}
  no-error.
  if available buf_doc-line-sum
  then do:
    create aftersumline.
    assign
    aftersumline.referenceNo = buf_doc-line-sum.doc-code
    aftersumline.qnty = buf_doc-line-sum.fact-qnty
    aftersumline.petrolweight = buf_doc-line-sum.fact-qnty * p-petrol-density
    aftersumline.good = p-gds-code
    .
    ExpData1:route-data_create-record( INPUT "afterSumLine") .
    ExpData1:route-data_copy-record ( input "afterSumLine", buffer aftersumline:handle).
    IF ExpData1:esys-add-dump( INPUT "afterSumLine", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи afterSumLine &1:&2&3"
                              , p-doc-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
    create salesumaftersumline.
    buffer-copy aftersumline to salesumaftersumline
    assign
    saleSumafterSumLine.sumR = buf_doc-line-sum.crsa-sum-rubl
    saleSumafterSumLine.vatR = buf_doc-line-sum.crsa-vat-rubl
    /*saleSumafterSumLine.sltR = buf_doc-line-sum.crsa-slt-rubl*/
    saleSumafterSumLine.roadTaxR = buf_doc-line-sum.crsa-road-tax-rubl
    saleSumafterSumLine.transportR = buf_doc-line-sum.crsa-transport-rubl
    saleSumafterSumLine.otherR = buf_doc-line-sum.crsa-other-rubl
    saleSumafterSumLine.exciseR = buf_doc-line-sum.crsa-excise-rubl
    saleSumafterSumLine.sumb = buf_doc-line-sum.crsa-sum-base
    saleSumafterSumLine.vatb = buf_doc-line-sum.crsa-vat-base
    /*saleSumafterSumLine.sltb = buf_doc-line-sum.crsa-slt-base*/
    saleSumafterSumLine.roadTaxb = buf_doc-line-sum.crsa-road-tax-base
    saleSumafterSumLine.transportb = buf_doc-line-sum.crsa-transport-base
    saleSumafterSumLine.otherb = buf_doc-line-sum.crsa-other-base
    saleSumafterSumLine.exciseb = buf_doc-line-sum.crsa-excise-base
    .
    ExpData1:route-data_create-record( INPUT "saleSumafterSumLine") .
    ExpData1:route-data_copy-record ( input "saleSumafterSumLine", buffer salesumaftersumline:handle).
    IF ExpData1:esys-add-dump( INPUT "saleSumafterSumLine", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи saleSumafterSumLine &1:&2&3"
                              , p-doc-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
    create costsumaftersumline.
    buffer-copy aftersumline to costsumaftersumline
    assign
    costsumafterSumLine.sumR = buf_doc-line-sum.crsa-sum-rubl
    costsumafterSumLine.vatR = buf_doc-line-sum.crsa-vat-rubl
    /*costsumafterSumLine.sltR = buf_doc-line-sum.crsa-slt-rubl*/
    costsumafterSumLine.roadTaxR = buf_doc-line-sum.crsa-road-tax-rubl
    costsumafterSumLine.transportR = buf_doc-line-sum.crsa-transport-rubl
    costsumafterSumLine.otherR = buf_doc-line-sum.crsa-other-rubl
    costsumafterSumLine.exciseR = buf_doc-line-sum.crsa-excise-rubl
    costsumafterSumLine.sumb = buf_doc-line-sum.crsa-sum-base
    costsumafterSumLine.vatb = buf_doc-line-sum.crsa-vat-base
    /*costsumafterSumLine.sltb = buf_doc-line-sum.crsa-slt-base*/
    costsumafterSumLine.roadTaxb = buf_doc-line-sum.crsa-road-tax-base
    costsumafterSumLine.transportb = buf_doc-line-sum.crsa-transport-base
    costsumafterSumLine.otherb = buf_doc-line-sum.crsa-other-base
    costsumafterSumLine.exciseb = buf_doc-line-sum.crsa-excise-base
    .
    ExpData1:route-data_create-record( INPUT "costsumafterSumLine") .
    ExpData1:route-data_copy-record ( input "costsumafterSumLine", buffer costsumaftersumline:handle).
    IF ExpData1:esys-add-dump( INPUT "costsumafterSumLine", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи costsumafterSumLine &1:&2&3"
                              , p-doc-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
  end.        /* available buf_trn-doc-sum */
  else do:
    v-err-mess = "*** ERR: *** Не найдена запись doc-line-sum с sum-type = {&sum-after-doc} для документа " + string( p-doc-code ).
  end.        /* NOT ( available buf_doc-line-sum ) */

end.        /* if p-exists-after = yes */
end. /*doe*/
end procedure. /* export-before-and-after-inv-line */


procedure edocsord_export :
define parameter buffer buf_ord-doc for ub.ord-doc.
define buffer buf_ord-line for ub.ord-line.
define variable v-bh as handle no-undo .
define variable v-bh-line as handle no-undo .
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
define variable v-linedoc-hidden as logical no-undo .
define variable v-dtl-hidden as logical no-undo .
define variable v-part-hidden as logical no-undo .
define variable v-date-char as character no-undo .


define buffer buf_operation for operation.
define buffer buf_currency for ub.currency.
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units.
define buffer buf_ord-chain   for ub.ord-chain.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_contract for ub.contract.
define buffer buf_gds-prt for ub.gds-prt.



main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block

:
  EMPTY TEMP-TABLE operation.
  if retry then do:
    EMPTY TEMP-TABLE operation.
    &scop my-message v-err-mess
    {&display-message}.
    return error ''.
  end.
  else do:
    v-bh = buffer buf_ord-doc:handle.
    v-bh-line = buffer buf_ord-line:handle.
    if v-action = {&gen-line-delete} then do:
    end.
    create buf_operation.
    assign
    buf_operation.referenceNo = buf_ord-doc.doc-code
    /*
    buf_operation.isDel = (v-action = {&gen-line-delete})
    buf_operation.dateDelXml = (if v-action = {&gen-line-delete}
                                then (if available buf_c-trn-doc
                                      then buf_c-trn-doc.corr-date
                                      else ?)
                                else ?)
    */
    buf_operation.codeOperation = buf_ord-doc.doc-type
    buf_operation.host = buf_ord-doc.host-code
    buf_operation.factOrder = buf_ord-doc.fact-order
    buf_operation.sysDateXML = buf_ord-doc.sys-date
    buf_operation.dateDocXML = buf_ord-doc.doc-date
    buf_operation.dateFactXML = buf_ord-doc.fact-date
    buf_operation.timeFact = string(buf_ord-doc.fact-time, "HH:MM:SS")
    buf_operation.outDateXML = buf_ord-doc.ship-date
    buf_operation.paymentCode = buf_ord-doc.pay-code
    buf_operation.outCode = buf_ord-doc.out-code
    buf_operation.comment = buf_ord-doc.PS
    buf_operation.store = buf_ord-doc.obj-type + string(buf_ord-doc.obj-code)
    buf_operation.systime = string(buf_ord-doc.sys-time-int, "HH:MM:SS")
    buf_operation.firm = buf_ord-doc.cli-type + string(buf_ord-doc.cli-code)
    buf_operation.outDateXML = buf_ord-doc.ship-date
    buf_operation.exchCode =  buf_ord-doc.exch-code
    buf_operation.exchRate =  buf_ord-doc.exch-rate
    buf_operation.exchscale  = buf_ord-doc.exch-scale
    buf_operation.ordOutDocCode = buf_ord-doc.cons-code
    buf_operation.vatType = buf_ord-doc.vat-Type
    buf_operation.shiftDateXML = buf_ord-doc.shift-date
    buf_operation.shiftNum = buf_ord-doc.shift-num
    buf_operation.shiftName = buf_ord-doc.shift-name
    buf_operation.cliQnty = buf_ord-doc.cli-qnty
    buf_operation.docQnty = buf_ord-doc.qnty
    buf_operation.factQnty = buf_ord-doc.qnty
    .
    { gbl/r-b-curr.i buf_ord-doc.host-code buf_operation.valutCode  }
    find first buf_currency no-lock where
              buf_currency.curr-code = buf_operation.valutCode.
    assign
    buf_operation.valutCodeOKV = buf_currency.okv-code
    buf_operation.totalSum = ( if buf_operation.valutCode = 0
                               then buf_ord-doc.sum-rubl
                               else buf_ord-doc.sum-base )
    buf_operation.totalDsc = buf_operation.totalSum
    buf_operation.totalFact = buf_operation.totalSum
    buf_operation.totalDscFact = buf_operation.totalDsc
    .
    ExpData1:route-data_create-record( INPUT "operation") .
    ExpData1:route-data_copy-record ( input "operation", buffer buf_operation:handle).
    IF ExpData1:esys-add-dump( INPUT "operation", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи operation &1:&2&3"
                              , buf_ord-doc.doc-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo main-block, retry main-block.
    end.
    if v-action = {&gen-line-delete} then do:
      return.
    end.
    for each buf_ord-line no-lock
      where buf_ord-line.doc-code = buf_ord-doc.doc-code
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      if not available linedoc then do:
        create linedoc.
      end.
      assign
      linedoc.referenceNo = buf_ord-line.doc-code
      .

      find first buf_goods no-lock where
              buf_goods.artic = buf_ord-line.artic
          and buf_goods.prod-type = buf_ord-line.prod-type
          and buf_goods.prod-code = buf_ord-line.prod-code no-error.
      if available buf_goods then do:
        find first buf_units no-lock where
                buf_units.unit-name = buf_goods.unit-base no-error.
      end.
      else do:
        release buf_units no-error.
      end.
      assign
      linedoc.good  = (if available buf_goods then buf_goods.gds-code else 0)
      linedoc.artic = buf_ord-line.artic
      linedoc.prodType = buf_ord-line.prod-type
      linedoc.prodCode = buf_ord-line.prod-code
      linedoc.type = (if available buf_goods then buf_goods.gds-type else '')
      linedoc.unitType = (if available buf_units then buf_units.type else '')
      linedoc.priceCli = buf_ord-line.price-cli
      linedoc.cliBaseRate = buf_ord-line.cli-base-rate
      linedoc.quantity = buf_ord-line.qnty
      linedoc.vatpc = buf_ord-line.vat-pc
      .
      ExpData1:route-data_create-record( INPUT "linedoc") .
      if v-linedoc-hidden = no then do:
        IF ExpData1:esys-add-dump( INPUT "linedoc", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_hidden=referenceNo') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи по заказу &1:&2&3"
                                  , buf_ord-doc.doc-code
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
        v-linedoc-hidden = yes.
      end.
      ExpData1:route-data_copy-record ( input "linedoc", buffer linedoc:handle).
      IF ExpData1:esys-add-dump( INPUT "linedoc", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи по заказу &1 (товар &2 &3&4):&5&6"
                                , buf_ord-doc.doc-code
                                , buf_ord-line.artic
                                , buf_ord-line.prod-type
                                , buf_ord-line.prod-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo main-block, retry main-block.
      end.
    end. /* for each buf_ord-line no-lock  */
    if available linedoc then do:
      delete linedoc.
    end.
    if available buf_operation then delete buf_operation.
  end. /*not retry*/
end.

end procedure. /* edocstrn_export */


/*не удалять!!!!*/