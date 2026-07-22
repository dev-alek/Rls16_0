/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18, набор 10,110

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/26/08
Author: Bakhtadze Natalya
Creation date: 05/26/08

---------------------------&start-codex_id=18;ruleset_id=10;-------------------------------
---------------------------&start-codex_id=18;ruleset_id=110;-------------------------------
Операции документами назначения цены и переоценками
---------------------------&end-codex_id=18;ruleset_id=10;-------------------------------
---------------------------&end-codex_id=18;ruleset_id=110;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 10,110".
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
{ bge/edocpd01.i }
{ str/statq.i }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-newbh as handle no-undo .
define variable v-oldbh as handle no-undo .
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-action as character no-undo .
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
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable l-res as integer no-undo .
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
:

  define variable v-doc-code as character no-undo .
  define variable v-price-doc-obj-type as character no-undo .
  define variable v-price-doc-obj-code as integer no-undo .
  define variable v-obj-db-num as integer no-undo .
  define variable v-obj-uniq-key-rec as character no-undo .
  define variable v-doc-list-doc-type as character no-undo .
  define buffer buf_price-doc for ub.price-doc.
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
v-price-doc-obj-type = ''.
v-price-doc-obj-code = 0.
case p-ruleset-id:
  when {&edoc-proc_18_batchwork-routing_price-doc_10} then do:
    if v-doc-list-bh:available then do:
      v-doc-list-bh:buffer-delete().
    end.
    run cb_get-next-doc-by-doc-code in v-doc-list-handle ( input v-doc-code
                                                          ,input v-doc-list-doc-type
                                                          ,input v-doc-list-bh
                                                          ).

    if v-doc-list-bh:available then do:
      v-price-doc-obj-type = v-doc-list-bh:buffer-field("obj-type"):buffer-value.
      v-price-doc-obj-code = v-doc-list-bh:buffer-field("obj-code"):buffer-value.
      v-doc-code = v-doc-list-bh:buffer-field("doc-code"):buffer-value. /*это ведь врем табл doc-list а не price-doc */
      v-doc-list-doc-type = v-doc-list-bh:buffer-field("doc-type"):buffer-value.
      if v-doc-list-doc-type <> {&overvalue}
      then do:
        case p-ruleset-id:
          when {&edoc-proc_18_batchwork-routing_price-doc_10} then do:
            next _stroka.
          end.
          when {&edoc-proc_18_event_price-doc_110} then do:
            leave _stroka.
          end.
        end case.
      end.
    END.
    else do:
      v-price-doc-obj-type = ''.
      v-price-doc-obj-code = 0.
      v-doc-code = ''.
      leave _stroka.
    end.
  end.
  when {&edoc-proc_18_event_price-doc_110} then do:
    if v-has-newbh then do:
      v-price-doc-obj-type = v-newbh::obj-type.
      v-price-doc-obj-code = v-newbh::obj-code.
      v-doc-code = v-newbh:buffer-field("doc-num"):buffer-value.
    end.
    else do:
      v-price-doc-obj-type = v-oldbh::obj-type.
      v-price-doc-obj-code = v-oldbh::obj-code.
      v-doc-code = v-oldbh:buffer-field("doc-num"):buffer-value.
    end.
  end. /*when {&edoc-proc_18_event_price-doc_110} then do:*/
end case.

  find first buf_clients no-lock where
            buf_clients.obj-type = v-price-doc-obj-type
      and  buf_clients.obj-code = v-price-doc-obj-code.
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
    when {&edoc-proc_18_batchwork-routing_price-doc_10} then do:
      if v-esys-id-list = '' then next _stroka. /*нет внешней системы куда отправлять*/
    end.
    when {&edoc-proc_18_event_price-doc_110} then do:
      if v-esys-id-list = '' then leave _stroka. /*нет внешней системы куда отправлять*/
    end.
  end case.
    /*ДОКУМЕНТЫ ВСЕ РАВНО ШЛЕМ ПО ОДНОМУ В ПАКЕТЕ!!!*/
  IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  IF  context_begin-esys-command( input v-esys-id-list
                                , input-output v-esys-cmd-proc-handle
                                , output v-esys-cmd-code) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.



    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/


    /* ------------------------- &end-release-obj& -------------------------------------*/
  if p-save >= 0 then do:
      find first buf_price-doc exclusive-lock where
                buf_price-doc.doc-num = v-doc-code
              no-error.
  end.
  else do:
      find first buf_price-doc no-lock where
                buf_price-doc.doc-num = v-doc-code
              no-error.

  end.

  run edocsprc_export in this-procedure ( buffer buf_price-doc
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

  &scop release_1 clear-data ( )
  ExpData1:Route-data_{&release_1} .
  if p-ruleset-id = {&edoc-proc_18_event_price-doc_110} then leave _stroka.
end. /*do while*/
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
    when {&edoc-proc_18_batchwork-routing_price-doc_10} then do:
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
    when {&edoc-proc_18_event_price-doc_110} then do:
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
      and v-newbh:table <> {&table_price-doc} then do:
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_price-doc}).
      end.
      run statq_has-waiting-stat in this-procedure (
                                                      input v-oldbh
                                                    ,input v-newbh
                                                    ,input v-changes-list
                                                    ,input {&act-overvalue}
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
      /*---------------------------&end-process-rule-call-param&-------------------------------*/
    end.
    otherwise do:
      undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
    end.
  end case.
end.
end procedure. /* load-ruleset-context */


procedure edocsprc_export :
define parameter buffer buf_price-doc for ub.price-doc.
define buffer buf_price-list for ub.price-list.
define variable v-bh as handle no-undo .
define variable v-bh-line as handle no-undo .
define variable v-err-mess as character no-undo .
define variable glog as logical no-undo .
define variable v-attr-type as character no-undo .
define variable v-hidden-referenceNo as logical no-undo .

define buffer buf_operation for operation.
define buffer buf_linedoc for linedoc.
define buffer buf_currency for ub.currency.
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units.
define buffer buf_bar-code for ub.bar-code.


main-block:
do
on error undo main-block, retry main-block
:
  if retry then do:
    EMPTY TEMP-TABLE operation.
    EMPTY TEMP-TABLE linedoc.
    &scop my-message v-err-mess
    {&display-message}.
    return error ''.
  end.
  else do:
    v-bh = buffer buf_operation:handle.
    v-bh-line = buffer buf_linedoc:handle.
    for each buf_operation:
      delete buf_operation.
    end.
    for each buf_linedoc:
      delete buf_linedoc.
    end.
    create buf_operation.
    assign
    buf_operation.referenceNo = buf_price-doc.doc-num
    buf_operation.host = buf_price-doc.host-code
    buf_operation.codeOperation = {&TDEDT_Overturn}
    buf_operation.store = buf_price-doc.obj-type + string(buf_price-doc.obj-code)
    buf_operation.sysDateXML = buf_price-doc.sys-date
    buf_operation.systime = string(buf_price-doc.sys-time-int, "HH:MM:SS")
    buf_operation.dateDocXML = buf_price-doc.doc-date
    buf_operation.dateFactXML = buf_price-doc.fact-dat
    buf_operation.factTime = string(buf_price-doc.fact-time, "HH:MM:SS")
    buf_operation.factOrder = buf_price-doc.fact-Order
    buf_operation.comment = buf_price-doc.PS
    .
    { gbl/r-b-curr.i buf_price-doc.host-code buf_operation.valutCode  }
    find first buf_currency no-lock where
              buf_currency.curr-code = buf_operation.valutCode.
    buf_operation.valutCodeOKV = buf_currency.okv-code.
    { str/tdat-val.i
    buf_price-doc.doc-num
    {&trdcattr-nids}
    buf_operation.suppInDocNo
    v-attr-type
    }


    ExpData1:route-data_create-record( INPUT "operation") .
    ExpData1:route-data_copy-record ( input "operation", v-bh).
    IF ExpData1:esys-add-dump( INPUT "operation", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи &1:&2&3"
                              , buf_price-doc.doc-num
                              , {&new-line}
                              , v-last-error-message
                              ).
      undo main-block, retry main-block.
    end.
    create buf_linedoc.
    for each buf_price-list no-lock where
            buf_price-list.doc-num = buf_price-doc.doc-num
    on error  undo main-block, retry  main-block
    on stop   undo main-block, retry  main-block
    on endkey undo main-block, retry  main-block
    :
      find first buf_goods no-lock where
              buf_goods.artic = buf_price-list.artic
          and buf_goods.prod-type = buf_price-list.prod-type
          and buf_goods.prod-code = buf_price-list.prod-code no-error.
      if available buf_goods then do:
        find first buf_units no-lock where
                buf_units.unit-name = buf_goods.unit-base no-error.
      end.
      define variable v-price-prev as decimal   no-undo .
      define variable v-void-char as character no-undo .
      define variable v-void-dec as decimal no-undo .
      assign
      v-price-prev = 0.0
      .
      find first buf_bar-code no-lock where
                buf_bar-code.b-code = buf_price-list.b-code.
      { gbl/bcodeprc.i
          buf_price-list.obj-type
          buf_price-list.obj-code
          buf_price-list.b-code
          0
          buf_price-list.fact-order
          v-void-char
          v-price-prev
          v-void-dec
          v-void-dec
      }
      assign
      buf_linedoc.referenceNo = buf_price-list.doc-num
      buf_linedoc.bCode = buf_price-list.b-code
      buf_linedoc.good = (if available buf_goods then buf_goods.gds-code else 0)
      buf_linedoc.artic = buf_price-list.artic
      buf_linedoc.prodType = buf_price-list.prod-Type
      buf_linedoc.prodCode = buf_price-list.prod-Code
      buf_linedoc.type = (if available buf_goods then buf_goods.gds-type else '')
      buf_linedoc.unittype = (if available buf_units then buf_units.type else '')
      buf_linedoc.unitCli = (if available buf_bar-code then buf_bar-code.unit-cli else '')
      buf_linedoc.cliBaseRate = (if available buf_bar-code then buf_bar-code.cli-base-rate else  ?)
      buf_linedoc.doc_id = (if available buf_bar-code then buf_bar-code.in-code else  '')
      buf_linedoc.partCOde = (if available buf_bar-code then buf_bar-code.part-code else  '')
      buf_linedoc.priceSAle = buf_price-list.price-Sale
      buf_linedoc.priceListQnty  = buf_price-list.doc-qnty
      buf_linedoc.pricePrev = v-price-prev
      .
      ExpData1:route-data_create-record( INPUT "linedoc") .
      ExpData1:route-data_copy-record ( input "linedoc", v-bh-line).
      if not v-hidden-referenceNo then do:
        IF ExpData1:esys-add-dump( INPUT "linedoc", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_hidden=referenceNo') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи по переоценке &1:&2&3"
                                  , buf_price-doc.doc-num
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
        v-hidden-referenceNo = yes.
      end.
      IF ExpData1:esys-add-dump( INPUT "linedoc", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи по переоценке &1 (баркод &2):&3&4"
                                , buf_price-doc.doc-num
                                , buf_price-list.b-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo main-block, retry main-block.
      end.
    end. /*    for each buf_price-list no-lock where*/
    delete buf_operation.
    delete buf_linedoc.
  end. /*not retry*/
end.

end procedure. /* edocsprc_export */

/*не удалять!!!!*/