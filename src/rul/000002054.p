/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18 набор правил 16 (ИМПОРТ Накладных)

Автор: Хныкин Павел Андреевич
Дата создания: 10/19/09
Author: Pavel Khnykin
Creation date: 10/19/09

---------------------------&start-codex_id=18;ruleset_id=16;-----------------
Импорт данных по документам

---------------------------&end-codex_id=18;ruleset_id=16;-----------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18 набор правил 16".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ rul/ruleset_.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code

{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ rul/library-cls.i "non-class-part" }
{ gbl/key-rec.i }
{ rul/tempcxml.i "shared" }
{ gbl/gate-clb.i }
{ ref/extclass.i }
{ rul/tt2054.i   }
{ rul/thdl-prc.i }

/*переменные контекста*/
/*это у нас объект 0*/

define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-current-doc-date as date no-undo .
define variable v-current-doc-type as character no-undo .
define variable v-current-doc-time as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-date as date no-undo .
/*****************************/
define variable v-sign as integer no-undo .
define variable file-name as char.
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable num-rec-ok2 as integer no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-end-new-line     as logical no-undo .
define variable v-last-error-message as character no-undo .
define variable v-retry-action as integer no-undo .
define variable v_dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .
define variable v_qh as handle no-undo .
define variable glog as logical no-undo .
define variable v-ds-read-order as character no-undo .
define variable v-esys-id as integer no-undo .
define variable v-err-type as character no-undo .

{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.

define buffer buf_temp-xml-tables for temp-xml-tables.


define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .


function 00180016_get-error-message returns character :
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .

DO v-ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
    v-mess = substitute("&1&2ош &3"
                        ,v-mess
                        ,{&new-line}
                        ,ERROR-STATUS:GET-MESSAGE(v-ii)).
END.
end function.


&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)


/*---------------------------&start-rule-call-param&-------------------------------*/
  define variable p-esys-id as integer no-undo .
  define variable p-xsd-file as character no-undo.

/*---------------------------&end-rule-call-param&-------------------------------*/
/* ------------------------- &start-i-script& -----------------------------------*/
/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run delete-procedure in this-procedure .
end.


&scop sign v-sign *

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error .
if error-status:error then undo, return error ''.

/* ------------------------- &start-def-vars& -----------------------------------*/
define variable ImpData1 as class Route-data_ no-undo .
&scop constructor_2 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input v_dataseth, input v-xmlh)
ImpData1 = new Route-data_{&constructor_2} .

/* ------------------------- &end-def-vars& -----------------------------------*/


if not this-procedure:persistent then do:
  run proc-main in this-procedure  no-error .
  if error-status:error then do:
      run delete-procedure in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run delete-procedure in this-procedure .
end.

procedure proc-main :
define variable v-ii as integer   no-undo .
define variable v-current-b-code as integer no-undo .
define variable v_dsheader as handle no-undo .
define variable v_dsline as handle no-undo .
define variable v-field-map as character no-undo .
define variable v-thds as handle no-undo .
define variable v-bh as handle no-undo .
define buffer buf_ext-system for ub.ext-system.

_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

/* ------------------------- &start-hn-option& -----------------------------------*/
/* ------------------------- &end-hn-option -----------------------------------*/


run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
&scop my-message substitute(".............Импорт данных по Складским документам из ВС")
  {&display-message}.
  &scop my-message substitute("Импорт данных по складским документам из файла &1", file-name)
  {&display-message}.

  _release:
  do on error undo, retry:
    if  retry then do:
      v-retry-action = v-retry-action + 1.
          &scop my-message   substitute("Ошибка при импорте данных &1&2&1&3" ~
                                                                  , ~{&new-line~} ~
                                                                  , error-status:get-message(1) ~
                                                                  , return-value)
          {&display-message}.
      undo _main, return error ''.
    end.
    create data-source v_dsheader.
    create data-source v_dsline.
    for each buf_temp-xml-tables
    on error  undo _main, retry _main
    on stop   undo _main, retry _main
    on endkey undo _main, retry _main
    :
      case buf_temp-xml-tables.tbl-name:
        when "doc_header" then do:
          v_dsheader:add-source-buffer( buf_temp-xml-tables.tbl-handle, "").
        end.
        when "doc_line" then do:
          v_dsline:add-source-buffer( buf_temp-xml-tables.tbl-handle, "").
        end.
      end case.
    end.
    v-thds = dataset thdoc:handle.
    v-field-map = "ID,doc-id" + {&comma-char} +
                  "ExtNum,ext-num" + {&comma-char} +
                  "AgentID,agent-id" + {&comma-char} +
                  "FromStoreID,from-store-id" + {&comma-char} +
                  "ToStoreID,to-store-id" + {&comma-char} +
                  "StartDate,start-date" + {&comma-char} +
                  "FinishDate,finish-date".
    v-bh = v-thds:get-buffer-handle("temp_doc-header").
    v-bh:attach-data-source(v_dsheader, v-field-map).
    v-field-map = "DocID,doc-id" + {&comma-char} +
                  "GoodsID,goods-id" + {&comma-char} +
                  "StoreID,store-id".
    v-bh = v-thds:get-buffer-handle("temp_doc-line").
    v-bh:attach-data-source(v_dsline, v-field-map).
    v-thds:handle:fill().
    v-thds:get-buffer-handle("temp_doc-header"):detach-data-source().
    v-thds:get-buffer-handle("temp_doc-line"):detach-data-source().
    delete object v_dsheader.
    delete object v_dsline.
  end.

  for each temp_doc-header
  :
    assign
      num-rec = num-rec + 1
    .
  end.
  /* здесь сохраняем в БД */
  run proc-save in this-procedure  no-error.
  if error-status:error then do:
    if return-value <> '' then do:
      &scop my-message substitute("Ошибка при сохранении данных по накладным из ВС:&1&2&1&3", {&new-line}, return-value , error-status :get-message(1)  )
      {&display-message}.
    end.
    run set-err-type in p-cont-handle
      ( input v-err-type
      ) no-error.
    run delete-procedure in this-procedure .
    undo _main, return error ''.
  end.

  &scop my-message substitute("Прочитано записей: &1, из них удачно обработано: &2", num-rec, num-rec-ok2)
  {&display-message}.
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define variable v-itop as integer   no-undo .
define variable v-ichild as integer   no-undo .
define variable v-pck-num as integer no-undo .

  do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

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
    case p-ruleset-id:
      when {&edoc-proc_18_xml-esys-import_trn-doc_16} then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-doc-code = p-doc-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = entry(1, p-process-file-name, {&delim-par})
        v_dataseth = handle(entry(2, p-process-file-name, {&delim-par}))
        v-xmlh = buffer buf_temp-xml-tables:handle
        v-esys-id = integer(p-doc-code)
        v-pck-num = integer(entry(3, p-process-file-name, {&delim-par}))
        log-file-name = entry(4, p-process-file-name, {&delim-par})
        no-error
       .
        _top-buffers:
        do v-itop = 1 to v_dataseth:num-top-buffers:
          if v_dataseth:get-top-buffer(v-itop):table = "header_" then do:
            next _top-buffers.
          end.
          assign
          v-ds-read-order = v-ds-read-order +
                            (if v-ds-read-order = '':U then '':U else {&comma-char}) +
                            v_dataseth:get-top-buffer(v-itop):table
                            .
          do v-ichild = 1 to v_dataseth:get-top-buffer(v-itop):num-child-relations:
            assign
            v-ds-read-order = v-ds-read-order + {&comma-char} + v_dataseth:get-top-buffer(v-itop):get-child-relation(v-ichild):child-buffer:name.
          end.
        end.
      end.
      otherwise do:
        undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */


procedure delete-procedure :

  do
  on error undo, return error
  :
      run garbcoll_clear in this-procedure .
      /*  todo
      empty temp-table temp_trn-doc.
      empty temp-table temp_doc-line.
      */
  end.

end procedure. /* delete-procedure */


procedure proc-save :

define variable v-obj-uniq-key-rec as character no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.

define buffer buf_temp_doc-header for temp_doc-header.
define buffer buf_temp_doc-line for temp_doc-line.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

/* отрезать лишние документы ? */
/*   _trn-doc:*/
/*  for each buf_temp-trn-doc:*/
/*    find first buf_ext-classif no-lock where*/
/*      buf_ext-classif.classif-name = {&extclass_clients_esys}*/
/*  and buf_ext-classif.classif-subject = {&table_clients}*/
/*  and buf_ext-classif.db-num = 0*/
/*  and buf_Ext-classif.key#_one = v-esys-id no-error.*/
/*  if not available buf_ext-classif then do:*/
/*    next _trn-doc.*/
/*  end.*/

  run rul/i2054.p ( input parparentproc
                  , input this-procedure
                  , input table temp_doc-header
                  , input table temp_doc-line
                  , output num-rec-ok2
                  ) .
end. /*doe*/



end procedure. /* proc-save */

procedure pcall-log-file :
define input  parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input p-message ) .

  end.

end procedure. /* pcall-log-file */