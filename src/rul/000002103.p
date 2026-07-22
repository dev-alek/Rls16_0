
/*------------------------------------------------------------------------
    File        : 000002103.p
    Purpose     : Экспорт смен

    Syntax      :

    Description : Экспорт shifts 1C ERP RN

    Author(s)   : SMMolotkov
    Created     : Wed Nov 15 15:29:31 MSK 2017
    Notes       : выгружает смену открытую, смену закрытую,
                  вместе с закрытой сменой выгружает все чеки продажи по закрытым продажам смены. 
  ----------------------------------------------------------------------*/
/*
---------------------------&start-codex_id=18;ruleset_id=2;-------------------------------
Операции над списком смен
Маршрутизация во ВС
---------------------------&end-codex_id=18;ruleset_id=2;-------------------------------
*/

/*---------------------------&start-using-class&-------------------------------*/
using Ibs.Th.Rul.Route-data_.
using ibs.th.bge.1crn.export.expsubject from propath.
using ibs.th.bge.1crn.subjects.check from propath.
using ibs.th.bge.1crn.subjects.shift from propath.
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

define variable vss-revision    as character no-undo init "$Revision: 39d83991554b, 1501, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Aug 30 10:41:48 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 000002103.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rul/000002103.p $":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 2".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/gate-clb.i }
{ rul/ruleset_.i }

define variable v-last-error-message as character no-undo .
{ rul/seterror.i }

/*переменные контекста*/
define variable v-view-log           as logical        no-undo .
define variable log-file-name        as character      no-undo init "process-edoc.txt".
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-newbh     as handle no-undo .
define variable v-oldbh     as handle no-undo .
define variable v-esys-id-list         as character no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code        as integer no-undo .
define variable v-changes-list as character no-undo .

define variable v-es  as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv  as character no-undo .
define variable num-rec    as integer no-undo . /* "Обработано документов списка экспорта:" - не используется */ 
define variable num-rec-ok as integer no-undo . /*                         "из них удачно:" - считается, не выводится */
define variable file-name as char.

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)

if g#news then return.  

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
if error-status:error then undo, return error return-value .

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
/*  { str/cdviewlg.i  "'!!!При маршрутизации произошли ошибки!!!'"   log-file-name not-delete }*/
  if v-es then do:
      &scop my-message substitute( "&1. &2&3&4", vss-workfile, v-rv, ~{&new-line~}, v-esm)
      {&display-message}.
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :
define variable expObj  as class expsubject no-undo .
define variable subObj  as class shift no-undo .
define variable subObj2 as class check no-undo .
define variable v-doc-rowid      as rowid  no-undo .
define variable v-sht-status     as character no-undo .
define variable v-fld-sht-status as handle no-undo .
define variable v-custom-pack-name as character no-undo .
define variable v-dump-ord-int64   as int64 no-undo .
define buffer buf_shift-obj   for ub.shift-obj .
define buffer buf_chk-doc   for ub.chk-doc.


_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:
/* ------------------------- &end-hn-option& -----------------------------------*/
if v-has-newbh and v-newbh:table <> "chk-doc" then do:
  if v-has-newbh then do:
    v-doc-rowid = v-newbh:rowid .
    v-fld-sht-status = v-newbh:BUFFER-FIELD ("status_") .
    if not valid-handle(v-fld-sht-status) and v-newbh:table <> "chk-doc" then undo _main, return error "не найдено поле shift-obj.status_" .
     v-sht-status = v-fld-sht-status:BUFFER-VALUE ( ) . 
  end.
  else do:
    v-doc-rowid = v-oldbh:rowid . 
    /* из триггера на write нам должен приходить и новый, и старый буффер;
       если пришёл только старый буффер - это удаление записи.
       Выгрузка удаления смен не предусмотрена.
    */
    return .
  end.

  /* Смена может иметь четыре статуса:
     ожд sht-expected, тек sht-current, зкр sht-closed, отм sht-canceled
     Экспорт в машину правил только если статус поменялся на тек или на зкр 
  */

  if (v-sht-status = {&sht-closed}) or (v-sht-status = {&sht-current}) then do:
    
  IF not context_begin-esys-command( input string(v-esys-id-list), input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) THEN
    undo _main, return error v-last-error-message .
  
    subObj = new shift ().
    subObj:KeyRowid = v-doc-rowid.
    expObj = new expsubject ().
    expObj:GetContent(subObj) no-error.
    if error-status:error then
    do:
      undo _main, return error expObj:Msg .  
    end.
        
    IF not ExpData1:esys-add-dump-data ( INPUT expObj:Data
                                       , INPUT v-esys-cmd-proc-handle
                                       , INPUT v-esys-cmd-code
                                       , '+update' + {&delim-par} + expObj:InitSecTag +
                                       (if expObj:sendTableName <> "" 
                                          then substitute("&1&2&3&4",{&delim-par},
                                                          expObj:sendTableName,
                                                          if expObj:sendOldRowid <> ? then substitute("&1&2",{&delim-key},expObj:sendOldRowid) else "",
                                                          if expObj:sendNewRowid <> ? then substitute("&1&2",{&delim-key},expObj:sendNewRowid) else "") 
                                        else "")) THEN
      undo _main, return error v-last-error-message .
    
  IF not context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name) THEN
    undo _main, return error v-last-error-message .
    
  v-dump-ord-int64 = context_send-esys-command( input v-esys-id-list
                                  , input v-esys-cmd-proc-handle
                                  , input v-esys-cmd-code
                                  , input g#userid).
  if v-dump-ord-int64 = 0 THEN
    undo _main, return error v-last-error-message .
  end. /* end_of if_status_  */
  &scop release_1 clear-data ( )
  ExpData1:Route-data_{&release_1} .
    

  /* 7/XII-2017 и к закрытию смены добавлена выгрузка чеков по всем продажам закрытой смены */
  if (v-sht-status = {&sht-closed}) then do:
  for first buf_shift-obj no-lock
      where rowid(buf_shift-obj)  = v-doc-rowid
        and buf_shift-obj.status_ = {&sht-closed} :
    subObj2 = new check ().
    IF not context_begin-esys-command( input string(v-esys-id-list)
                                     , input-output v-esys-cmd-proc-handle
                                     , output v-esys-cmd-code) THEN
      undo _main, return error v-last-error-message .
    
    subObj2:BufHandle = buffer buf_shift-obj:HANDLE .
    expObj:GetContent(subObj2) no-error.
    if error-status:error then
    do:
      undo _main, return error expObj:Msg .  
    end.

/* 16/VIII-2018 - вокруг чеков добавлена секция <shift>, отличная от секции, в которой выгружаются смены.
                  Обход таблицы с продажами убран внутрь экспорта чеков.
define buffer buf_inkas       for ub.inkas .
  for each buf_inkas no-lock
     where buf_inkas.host-code  = buf_shift-obj.host-code 
       and buf_inkas.obj-type   = buf_shift-obj.obj-type
       and buf_inkas.obj-code   = buf_shift-obj.obj-code
       and buf_inkas.shift-date = buf_shift-obj.shift-date
       and buf_inkas.shift-num  = buf_shift-obj.shift-num
       and buf_inkas.status_    = {&fact}
    /* and buf_inkas.fact-date  = buf_shift-obj.shift-date - не всегда, и не факт; не проверялось */
  :
    subObj2:BufHandle = buffer buf_inkas:HANDLE .
    expObj:GetContent(subObj2).
  end. /* end_of for_each_inkas */
*/  
    IF not ExpData1:esys-add-dump-data ( INPUT expObj:Data
                                       , INPUT v-esys-cmd-proc-handle
                                       , INPUT v-esys-cmd-code
                                       , '+update' + {&delim-par} + expObj:InitSecTag +
                                         (if expObj:sendTableName <> "" 
                                            then substitute("&1&2&3&4",{&delim-par},
                                                          expObj:sendTableName,
                                                          if expObj:sendOldRowid <> ? then substitute("&1&2",{&delim-key},expObj:sendOldRowid) else "",
                                                          if expObj:sendNewRowid <> ? then substitute("&1&2",{&delim-key},expObj:sendNewRowid) else "") 
                                          else "")) THEN
      undo _main, return error v-last-error-message .
    IF not context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle
                                            , input v-esys-cmd-code
                                            , input v-custom-pack-name) THEN
      undo _main, return error v-last-error-message .
    v-dump-ord-int64 = context_send-esys-command( input v-esys-id-list
                                  , input v-esys-cmd-proc-handle
                                  , input v-esys-cmd-code
                                  , input g#userid).
    if v-dump-ord-int64 = 0 THEN
      undo _main, return error v-last-error-message .
    &scop release_1 clear-data ( )
    ExpData1:Route-data_{&release_1} .
  end.
  end. /* end_of if_status_  */

  &scop my-message substitute( "Успешно. ")
  {&display-message}.
      /* ------------------------- &end-rule& -------------------------------------*/
      /* ------------------------- &start-release-obj& -----------------------------------*/
      /* ------------------------- &end-release-obj& -------------------------------------*/
  num-rec-ok = num-rec-ok + 1.
       
  
end.

if v-has-newbh and v-newbh:table = "chk-doc" then do:  /* выгрузка чеков открытия и закрытия смен */ 
/*  message  v-has-newbh v-newbh:table v-newbh:buffer-field( "obj-code":U  ):buffer-value view-as alert-box. */

    IF not context_begin-esys-command( input string(v-esys-id-list), 
                                       input-output v-esys-cmd-proc-handle, 
                                       output v-esys-cmd-code) THEN
    undo _main, return error v-last-error-message .

     subObj2 = new check ().
     expObj = new expsubject ().
     subObj2:BufHandle = v-newbh:handle.
     expObj:GetContent(subObj2).

    IF not ExpData1:esys-add-dump-data ( INPUT expObj:Data
                                       , INPUT v-esys-cmd-proc-handle
                                       , INPUT v-esys-cmd-code
                                       , '+update' + {&delim-par} + expObj:InitSecTag +
                                         (if expObj:sendTableName <> "" 
                                            then substitute("&1&2&3&4",{&delim-par},
                                                          expObj:sendTableName,
                                                          if expObj:sendOldRowid <> ? then substitute("&1&2",{&delim-key},expObj:sendOldRowid) else "",
                                                          if expObj:sendNewRowid <> ? then substitute("&1&2",{&delim-key},expObj:sendNewRowid) else "") 
                                          else "")) THEN
    undo _main, return error v-last-error-message . 

    v-dump-ord-int64 = context_send-esys-command( input v-esys-id-list
                                  , input v-esys-cmd-proc-handle
                                  , input v-esys-cmd-code
                                  , input g#userid).


    if v-dump-ord-int64 = 0 THEN undo _main, return error v-last-error-message .

    &scop release_1 clear-data ( ) 
    ExpData1:Route-data_{&release_1} .  
    &scop my-message substitute( "Успешно. ")
    {&display-message}.
    num-rec-ok = num-rec-ok + 1.

end. /* v-has-newbh and v-newbh:table = "chk-doc" */

 
end.
/*doe _main*/

end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer    no-undo .
define variable v-direction         as character  no-undo .
define variable v-direction-2       as character  no-undo .
define variable v-is-waiting-status as logical    no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ext-system for ub.ext-system.

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
    when {&edoc-proc_18_event_shift_140} then do:
      if v-has-newbh
      and v-newbh:table <> {&table_shift-obj} AND v-newbh:table <> "chk-doc" then do:
        undo, return error substitute("Передан неверный буфер [&1] вместо буфера для &2", v-newbh:table, {&table_shift-obj}).
      end.
      if v-has-oldbh
      and v-oldbh:table <> {&table_shift-obj} and v-oldbh:table <> "tt-shift" AND  v-oldbh:table <> "chk-doc" then do:
        undo, return error substitute("Передан неверный буфер [&1] вместо буфера для &2", v-oldbh:table, {&table_shift-obj}).
      end.
    end.
    otherwise do:
      undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
    end.
  end case.

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