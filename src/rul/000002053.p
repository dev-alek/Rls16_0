/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18, набор 125

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/128/09
Author: Bakhtadze Natalya
Creation date: 10/128/09

---------------------------&start-codex_id=18;ruleset_id=125;-------------------------------

---------------------------&end-codex_id=18;ruleset_id=125;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 26".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ rul/ruleset_.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/gate-clb.i }
{ gbl/key-rec.i }
{ bge/tmpcxmlh.i }
{ gbl/lib-gate.i }
{ ref/extclass.i }
{ str/statq.i }
{ rul/thdl-prc.i }

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
define variable v-esys-id-list-start as character no-undo .
define variable v-esys-id-list as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-action as character no-undo .

{ str/dia2auto.i }
{ rul/seterror.i }

&scop display-message ~
          if valid-handle(p-log-handle) then ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)




/*---------------------------&start-rule-call-param&-------------------------------*/

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
  if v-es then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :
define variable v-err               as logical no-undo .
define variable v-status_           as character no-undo .
define variable v-flag              as logical no-undo .
define variable v-doc-code          as character no-undo .
define variable v-dklink-doc-type   as integer no-undo .
define variable v-agentid           as integer no-undo .
define variable v-ext-doc-type      as character no-undo .
define variable v-ord-doc-obj-type  as character no-undo .
define variable v-ord-doc-obj-code  as integer no-undo .
define variable v-obj-db-num        as integer no-undo .
define variable v-obj-uniq-key-rec  as character no-undo .
define variable v-b-code            as integer no-undo .
define variable v-main-b-code       as integer no-undo .
define variable v-gds-name-full     as character no-undo .
define variable v-node-name         as character no-undo .
define variable v-obj-type          as character no-undo .
define variable v-obj-code          as integer no-undo .
define variable v-cli-type          as character no-undo .
define variable v-cli-code          as integer no-undo .
define variable v-from-store-id     as integer   no-undo .
define variable v-to-store-id       as integer   no-undo .
define variable v-ext-num           as character no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_ord-line for ub.ord-line.
define buffer buf_ord-dtl for ub.ord-dtl.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_goods for ub.goods.



_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
on stop undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:


/* ------------------------- &end-hn-option& -----------------------------------*/
  /* ------------------------- &start-rule& -----------------------------------*/

  if v-has-newbh then do:
    v-ord-doc-obj-type = v-newbh::obj-type.
    v-ord-doc-obj-code = v-newbh::obj-code.
    v-doc-code = v-newbh::doc-code.
    v-cli-type   = v-newbh::cli-type.
    v-cli-code   = v-newbh::cli-code.
  end.
  else do:
    v-ord-doc-obj-type = v-oldbh::obj-type.
    v-ord-doc-obj-code = v-oldbh::obj-code.
    v-doc-code = v-oldbh::doc-code.
    v-cli-type   = v-oldbh::cli-type.
    v-cli-code   = v-oldbh::cli-code.
  end.
  { gbl/objdbnum.i v-ord-doc-obj-type v-ord-doc-obj-code v-obj-db-num }
  if v-obj-db-num <> g#db-num then do:
    return 'return'.
  end.
  find first buf_clients no-lock where
            buf_clients.obj-type = v-ord-doc-obj-type
       and  buf_clients.obj-code = v-ord-doc-obj-code.
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
  if v-esys-id-list = '' then return "return". /*нет внешней системы куда отправлять*/
  if v-action = {&gen-line-update} then do:
    /*здесь получаем значения полей*/
  end.
  IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  IF  context_begin-esys-command( input v-esys-id-list
                                , input-output v-esys-cmd-proc-handle
                                , output v-esys-cmd-code) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.

  ExpData1:route-data_create-record( INPUT "doc_header") .
  IF ExpData1:esys-add-dump( INPUT "doc_header", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
    v-err-mess = substitute("Ошибка при маршрутизации заявки &1:&2&3"
                            , v-doc-code
                            , {&new-line}
                            , v-last-error-message
                            ).
    undo _main, return error v-last-error-message .
  end.


  run thdl-prc_map-obj in this-procedure ( input  v-ord-doc-obj-type
                                         , input  v-ord-doc-obj-code
                                         , output v-to-store-id
                                         )  no-error .
  if error-status :error = yes
  then do:
    assign
      v-last-error-message = substitute( "Ошибка преобразования контрагента: &1 &2. &3 &4"
                                        , v-ord-doc-obj-type
                                        , v-ord-doc-obj-code
                                        , return-value
                                        , error-status :get-message(1)
                                        )
    .
    undo _main, return error v-last-error-message .
  end.

  run thdl-prc_map-obj in this-procedure ( input  v-cli-type
                                         , input  v-cli-code
                                         , output v-from-store-id
                                         )  no-error .
  if error-status :error = yes
  then do:
    assign
      v-last-error-message = substitute( "Ошибка преобразования контрагента: &1 &2. &3 &4"
                                        , v-cli-type
                                        , v-cli-code
                                        , return-value
                                        , error-status :get-message(1)
                                        )
    .
    undo _main, return error v-last-error-message .
  end.

  assign
    v-dklink-doc-type = 1
    v-ext-num = substitute("&1;&2;&3"
                          , v-doc-code
                          , {&table_ord-doc}
                          , v-ext-doc-type
                          )
  .

  ExpData1:route-data_copy-field-integer( INPUT "doc_header", "ID", INPUT  0 ) .
  ExpData1:route-data_copy-field-character( INPUT "doc_header", "Action", INPUT  v-action ) .
  ExpData1:route-data_copy-field-character( INPUT "doc_header", "ExtNum", INPUT  v-ext-num).
  ExpData1:route-data_copy-field-integer( INPUT "doc_header", "Type", INPUT  v-dklink-doc-type).
  ExpData1:route-data_copy-field-integer( INPUT "doc_header", "FromStoreID", INPUT  v-from-store-id).
  ExpData1:route-data_copy-field-integer( INPUT "doc_header", "ToStoreID", INPUT  v-to-store-id).

  IF ExpData1:esys-add-dump( INPUT "doc_header", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
    v-err-mess = substitute("Ошибка при маршрутизации заявки &1:&2&3"
                            , v-doc-code
                            , {&new-line}
                            , v-last-error-message
                            ).
    undo _main, return error v-last-error-message .
  end.
  for each buf_ord-line no-lock where
          buf_ord-line.doc-code = v-doc-code
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :

    find first buf_goods no-lock where
              buf_goods.gds-code = buf_ord-line.gds-code.
    ExpData1:route-data_create-record( INPUT "doc_line") .
    IF ExpData1:esys-add-dump( INPUT "doc_line", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации накладной &1:&2&3"
                              , v-doc-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo _main, return error v-last-error-message .
    end.
    { gbl/gdsbcode.i buf_goods.gds-code ?                     v-main-b-code      }
    ExpData1:route-data_copy-field-integer( INPUT "doc_line", "ID", INPUT  0 ) .
    ExpData1:route-data_copy-field-integer( INPUT "doc_line", "Pos", INPUT  buf_ord-line.line-num ) .
    ExpData1:route-data_copy-field-integer( INPUT "doc_line", "GoodsID", INPUT  buf_goods.gds-code ) .
    ExpData1:route-data_copy-field-integer( INPUT "doc_line", "StoreID", INPUT v-to-store-id ) .
    ExpData1:route-data_copy-field-integer( INPUT "doc_line", "BC", INPUT  v-main-b-code ) .

    ExpData1:route-data_copy-field-character( INPUT "doc_line", "Name", INPUT  buf_goods.gds-name ) .
    ExpData1:route-data_copy-field-character( INPUT "doc_line", "Comment", INPUT  "" /*в ord-dtl.ps нету*/ ) .
    ExpData1:route-data_copy-field-character( INPUT "doc_line", "SN", INPUT  "" /*в ord-dtl сер номеров нету*/ ) .
    ExpData1:route-data_copy-field-decimal( INPUT "doc_line", "PCount", INPUT  buf_ord-line.qnty) .
    ExpData1:route-data_copy-field-decimal( INPUT "doc_line", "FCount", INPUT  0.0 ) .
    ExpData1:route-data_copy-field-decimal( INPUT "doc_line", "PPrice", INPUT  buf_ord-line.price-cli).
    ExpData1:route-data_copy-field-decimal( INPUT "doc_line", "FPrice", INPUT  0.0).
    IF ExpData1:esys-add-dump( INPUT "doc_line", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации накладной &1:&2&3"
                              , v-doc-code
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo _main, return error v-last-error-message .
    end.
  end.


  IF  context_send-esys-command( input v-esys-id-list
                              , input v-esys-cmd-proc-handle
                              , input v-esys-cmd-code
                              , input g#userid) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.

  &scop release_1 clear-data ( )
  ExpData1:Route-data_{&release_1} .

  /* ------------------------- &end-rule& -------------------------------------*/

  /* ------------------------- &start-release-obj& -----------------------------------*/


  /* ------------------------- &end-release-obj& -------------------------------------*/

  ExpData1:route-data_clear-xmlschema ( ).
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable v-flag as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-changes-list2 as character no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-is-waiting-status as logical no-undo .
define variable v-direction as character no-undo .
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
    when {&edoc-proc_18_event_intorder_125} then do:
      if v-has-newbh
      and v-newbh:table <> {&table_ord-doc} then do:
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_ord-doc}).
      end.
    end.
    otherwise do:
      undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
    end.
  end case.
  run statq_has-waiting-stat in this-procedure (
                                                  input v-oldbh
                                                 ,input v-newbh
                                                 ,input v-changes-list
                                                 ,input {&ord-req}
                                                 ,input yes  /*p-waiting-flag_*/
                                                 ,input 0 /*p-stati*/
                                                 ,output v-is-waiting-status
                                                 ,output v-direction
                                                 ) no-error.

  if v-is-waiting-status = no then return "return".
  if entry(1, v-direction, {&delim-par}) = {&open-doc}
  or entry(1, v-direction, {&delim-par}) = {&deletion}
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
  and buf_rule-call-param.param-name = "p-esys-id-list",
    first buf_ext-system no-lock where
          buf_Ext-system.esys-id = buf_rule-call-param.param-value-integer
      and buf_Ext-system.db-num = 0
      and buf_Ext-system.esys-have-export = yes
      and buf_Ext-system.esys-db-num-exp = g#db-num:
    v-esys-id-list-start = v-esys-id-list-start + (if v-esys-id-list-start = '' then '' else {&delim-nws}) + string(buf_ext-system.esys-id).
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