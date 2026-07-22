

/*------------------------------------------------------------------------
    File        : 000002116.p
    Purpose     : 

    Syntax      :

    Description : Экспорт ORDER contur.EDI

    Author(s)   : SSlivenko
    Created     : Tue Jul 07 19:29:31 MSK 2015
    Notes       :
  ----------------------------------------------------------------------*/
/*
---------------------------&start-codex_id=18;ruleset_id=2;-------------------------------
Операции над списком заказов
Маршрутизация во ВС
---------------------------&end-codex_id=18;ruleset_id=2;-------------------------------

*/


/*---------------------------&start-using-class&-------------------------------*/
using Ibs.Th.Rul.Route-data_.
using ibs.th.bge.1crn.export.expsubject from propath.
using ibs.th.bge.1crn.subjects.iexpsubject from propath.
using ibs.th.bge.1crn.subjects.fbr-gd-doc from propath.
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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 2".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ gbl/gate-clb.i }
{ rul/rum-fn.i }
{ rul/context_f.i get-thobj-es }
{ gbl/key-rec.i }
{ bge/esysattr.i }
{ bge/tmpcxmlh.i }
{ rul/ruleset_.i }
{ cus/str-edi.i }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable v-newbh as handle no-undo .
define variable v-oldbh as handle no-undo .
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-changes-list as character no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-last-error-message as character no-undo .

/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable v-gate-rec as character no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-esys-id-list as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-action as character no-undo .

{ str/dia2auto.i }
{ rul/seterror.i }


&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)

if g#news 
then do :
  return.  
end.


/*---------------------------&start-rule-call-param&-------------------------------*/

  define variable p-xsd-file as character no-undo.

/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/

 { rul/context_f.i  begin-esys-command }
 { rul/context_f.i  send-esys-command-ext }
 { rul/context_f.i  set-custom-esys-pck-name }
 { rul/context_f.i  delete-command }



/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.

/* ------------------------- &start-def-vars& -----------------------------------*/

define variable ExpData1 as class Route-data_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle)
ExpData1 = new Route-data_{&constructor_1} .

define variable v-DATA as memptr no-undo.

/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
    
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  if v-es then do:
      &scop my-message substitute( "&1. &2&3&4", vss-workfile, v-rv, ~{&new-line~}, v-esm)
      {&display-message}.
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :

_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:

  define variable v-ii as integer no-undo .
  define variable v-uniq-key-rec as character no-undo .
  define variable v-cli-uniq-key-rec as character no-undo .
  define variable v-err as logical no-undo .
  define variable v-custom-pack-name as character no-undo .
  define variable v-success as logical   no-undo .
  define variable v-datetimechar as character no-undo .
  define variable v-dump-ord-int64 as int64 no-undo .


  define variable v-flag              as logical    no-undo .
  define variable v-doc-code          as character  no-undo .
  define variable v-dklink-doc-type   as integer    no-undo .
  define variable v-agentid           as integer    no-undo .
  define variable v-doc-status        as character  no-undo .
  define variable v-doc-status-old    as character  no-undo .
  define variable v-ext-doc-type          as character  no-undo .
  define variable v-trn-doc-obj-type  as character  no-undo .
  define variable v-trn-doc-obj-code  as integer    no-undo .
  define variable v-obj-db-num        as integer    no-undo .
  define variable v-obj-uniq-key-rec  as character  no-undo .
  define variable v-b-code            as integer    no-undo .
  define variable v-main-b-code       as integer    no-undo .
  define variable v-gds-name-full     as character  no-undo .
  define variable v-node-name         as character  no-undo .
  define variable v-agnt-id           as integer    no-undo .
  define variable v-obj-type          as character  no-undo .
  define variable v-obj-code          as integer    no-undo .
  define variable v-tot-rubl          as decimal    no-undo .
  define variable v-ext-num           as character  no-undo .
  define variable v-table-name        as character  no-undo .
  define variable v-cli-type          as character  no-undo .
  define variable v-cli-code          as integer    no-undo .
  define variable v-cli-id            as integer    no-undo .
  define variable v-obj-id            as integer    no-undo .
  define variable v-from-store-id     as integer    no-undo .
  define variable v-to-store-id       as integer    no-undo .
  define variable v-p-date            as datetime-tz  no-undo .
  define variable v-ext-artic         as character  no-undo .
  
  define buffer buf_clients for ub.clients.
  define buffer buf_ext-classif for ub.ext-classif.
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_gds-dtl for ub.gds-dtl.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_gds-prt for ub.gds-prt.
  define buffer buf_goods for ub.goods.
  define buffer buf_ext-artic for ub.ext-artic.

  define buffer buf_ext-system for ub.ext-system.  

  define variable expObj as class expsubject no-undo .
  define variable subDocObj as class iexpsubject no-undo .
  
/* ------------------------- &end-hn-option& -----------------------------------*/

  if v-has-newbh then do:
    v-trn-doc-obj-type = v-newbh::obj-type.
    v-trn-doc-obj-code = v-newbh::obj-code.
    v-doc-code = v-newbh:buffer-field("doc-code"):buffer-value.
    v-ext-doc-type = v-newbh:buffer-field("doc-type"):buffer-value.

    v-p-date = v-newbh:buffer-field("doc-date"):buffer-value.
  end.
  else do:
    v-trn-doc-obj-type = v-oldbh::obj-type.
    v-trn-doc-obj-code = v-oldbh::obj-code.
    v-doc-code = v-oldbh:buffer-field("doc-code"):buffer-value.
    v-ext-doc-type = v-oldbh:buffer-field("doc-type"):buffer-value.
  end.
  if v-has-newbh
  then do:
    v-doc-status = v-newbh:buffer-field("status_"):buffer-value.
  end.
  v-doc-status-old = v-oldbh:buffer-field("status_"):buffer-value.
  if not (v-doc-status-old = {&fact} and not v-has-newbh) and (v-doc-status = v-doc-status-old or not v-doc-status = {&fact})
    then return.

  IF  context_begin-esys-command( input string(v-esys-id-list), input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  subDocObj = new fbr-gd-doc ().
  cast (subDocObj, fbr-gd-doc):BufTableHndlNew = v-newbh.
  cast (subDocObj, fbr-gd-doc):BufTableHndlOld = v-oldbh.
  expObj = new expsubject ().
  expObj:GetContent(subDocObj) no-error.
  if error-status:error
  then
     undo _main, return error if expObj:Msg <> "" then expObj:Msg else return-value  .
        
IF ExpData1:esys-add-dump-data ( INPUT expObj:Data, 
                                 INPUT v-esys-cmd-proc-handle, 
                                 INPUT v-esys-cmd-code, 
                                 '+update' + {&delim-par} + expObj:InitSecTag + 
                                  (if expObj:sendTableName <> "" 
                                   then substitute("&1&2&3&4",{&delim-par},
                                                   expObj:sendTableName,
                                                   if expObj:sendOldRowid <> ? then substitute("&1&2",{&delim-key},expObj:sendOldRowid) else "",
                                                   if expObj:sendNewRowid <> ? then substitute("&1&2",{&delim-key},expObj:sendNewRowid) else "") 
                                   else "")) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  IF  context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  v-dump-ord-int64 = context_send-esys-command( input v-esys-id-list
                              , input v-esys-cmd-proc-handle
                              , input v-esys-cmd-code
                              , input g#userid).
  if v-dump-ord-int64 = 0 THEN do:
    undo _main, return error v-last-error-message .
  end.
  
  &scop my-message substitute( "Успешно. " + subDocObj:Msg)
  {&display-message}.

      /* ------------------------- &end-rule& -------------------------------------*/

      /* ------------------------- &start-release-obj& -----------------------------------*/


      /* ------------------------- &end-release-obj& -------------------------------------*/

  num-rec-ok = num-rec-ok + 1.
/*      run write-counter in p-log-handle ( input substitute("Обработано документов списка экспорта: &1, из них удачно: &2", num-rec, num-rec-ok)).*/
/*      run get-stop-state in p-log-handle ( output v-stop) no-error .*/
/*      if v-stop then do:                                            */
/*        &scop my-message substitute("Процесс прерван пользователем")*/
/*        {&display-message}.                                         */
/*        leave _stroka.                                              */
/*      end. /*if v-stop*/*/
/*    end. /*else if retry*/*/
  &scop release_1 clear-data ( )
  ExpData1:Route-data_{&release_1} .

/*  &scop my-message substitute("Обработано заказов списка экспорта: &1, из них удачно: &2", num-rec, num-rec-ok)*/
/*  {&display-message}.*/
  
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer    no-undo .

define variable v-flag              as logical    no-undo .
define variable v-ii                as integer    no-undo .
define variable v-changes-list2     as character  no-undo .
define variable v-obj-db-num        as integer    no-undo .
define variable v-is-waiting-status as logical    no-undo .
define variable v-direction         as character  no-undo .
define variable v-direction-2       as character  no-undo .
define variable v-waiting-status    as character  no-undo .
define variable v-ext-doc-type      as character  no-undo .

define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ext-system for ub.ext-system.
define buffer buf_clients for ub.clients.

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

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
    when {&edoc-proc_18_event_fbr-doc_155} then do:
      if v-has-newbh
      and v-newbh:table <> {&table_fbr-doc} then do:
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_trn-doc}).
      end.
      if v-has-oldbh
      and v-oldbh:table <> {&table_fbr-doc} and v-oldbh:TABLE <> "tt-fbr" then do:
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_trn-doc}).
      end.
    end.
    otherwise do:
      undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
    end.
  end case.


/*  if entry(1, v-direction, {&delim-par} ) = {&close-doc}*/
/*  and v-newbh::status_ = {&fact} then return "return".*/

    if num-entries(v-direction, {&delim-par}) > 1 then do:
    v-direction-2 = entry(2, v-direction, {&delim-par}).
    v-direction = entry(1, v-direction, {&delim-par}).
    /*если закрытие НЕ ТОЧНО НА НУЖНЫЙ СТАТУС!*/
    if v-direction-2 <> "to"
    and v-direction-2 <> "from" then return "return".
    if v-direction = {&open-doc}
    and v-direction-2 = "to" then return "return".
/*    if v-direction = {&close-doc}*/
/*    and v-direction-2 = "from" then return "return".*/
  end.

  if v-direction = {&open-doc}
  or v-direction = {&deletion}
  or (v-direction = {&close-doc} and v-newbh::status_ = {&fact} )
  then do:
    v-action = {&gen-line-delete}.
  end.
  else do:
    v-action = {&gen-line-update}.
  end.

  for each buf_rule-call-param no-lock where
  buf_rule-call-param.codex_id = p-codex-id
  and buf_rule-call-param.ruleset_id = p-ruleset-id
  and buf_rule-call-param.call_id = p-call-id
  and buf_rule-call-param.order_id = p-order-id
  and buf_rule-call-param.rule_id = p-rule-id
  and buf_rule-call-param.param-name = "p-esys-id",
    first buf_ext-system no-lock where
          buf_Ext-system.esys-id = buf_rule-call-param.param-value-integer
      and buf_Ext-system.db-num = 0
      and buf_Ext-system.esys-have-export = yes
      and buf_Ext-system.esys-db-num-exp = g#db-num:
    v-esys-id-list = v-esys-id-list + (if v-esys-id-list = '' then '' else {&delim-nws}) + string(buf_ext-system.esys-id).
  end.
  if v-esys-id-list = '' then return "return".

  /*---------------------------&start-process-rule-call-param&-------------------------------*/
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

end. /*doe*/

end procedure. /* load-ruleset-context */