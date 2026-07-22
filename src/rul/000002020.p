/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18 набор правил 20 (ИМПОРТ заказов)

Автор: Чернова Светлана Александровна
Дата создания: 02/13/09
Author: Svetlana Chernova
Creation date: 02/13/09


---------------------------&start-codex_id=18;ruleset_id=16;-----------------
Импорт данных по Заказам

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
{ utl/tt401.i    }

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


function 00180020_get-error-message returns character :
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
&scop my-message substitute(".............Импорт данных по Заказам из ВС")
  {&display-message}.
  &scop my-message substitute("Импорт данных по заказам из файла &1", file-name)
  {&display-message}.

    find first buf_ext-system no-lock where
              buf_ext-system.esys-id = v-esys-id
          and buf_ext-system.db-num = 0 no-error.
    if not available buf_ext-system
    or not (buf_ext-system.esys-type  = integer({&openxml-type-oracle-retail})) then do:
    &scop my-message  substitute("Не найдена ВС &1 или она не имеет типа ORACLE RETAIL", v-esys-id)
       {&display-message}.
       undo _main, return error ''.
    end.

  do v-ii = 1 to num-entries(v-ds-read-order):
  find first buf_temp-xml-tables where
            buf_temp-xml-tables.tbl-name = entry(v-ii, v-ds-read-order)
       and  buf_temp-xml-tables.gate-handle_ = v_dataseth.
  /*надо создать динамический query*/
  create query v_qh.
  glog = v_qh:set-buffers( buf_temp-xml-tables.tbl-handle_) no-error.
  if error-status:error
  or
  not glog then do:
        &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4" ~
                                                                , buf_temp-xml-tables.tbl-name ~
                                                                , ~{&new-line~} ~
                                                                , error-status:get-message(1) ~
                                                                , return-value)
        {&display-message}.
   undo _main, return error ''.
  end.

  glog = v_qh:query-prepare( substitute( "for each &1 ", buf_temp-xml-tables.tbl-name)) no-error .
  if error-status:error
  or
  not glog then do:
        &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4" ~
                                                                , buf_temp-xml-tables.tbl-name ~
                                                                , ~{&new-line~} ~
                                                                , error-status:get-message(1) ~
                                                                , return-value)
        {&display-message}.
        if valid-handle(v_qh) then do:
          delete object v_qh no-error.
        end.
   undo _main, return error ''.
  end.
  glog = v_qh:query-open no-error .
  if error-status:error
  or
  not glog then do:
        &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4" ~
                                                                , buf_temp-xml-tables.tbl-name ~
                                                                , ~{&new-line~} ~
                                                                , error-status:get-message(1) ~
                                                                , return-value)
        {&display-message}.
        if valid-handle(v_qh) then do:
          delete object v_qh no-error.
        end.
    undo _main, return error ''.
  end.
  _stroka:
  REPEAT:
        if buf_temp-xml-tables.is-parent then do:
    num-rec = num-rec + 1.
        end.
    v-retry-action = 0 .
    _release:
    do on error undo, retry:
      if  retry then do:
        v-retry-action = v-retry-action + 1.
            &scop my-message   substitute("Ошибка при импорте записи &5 &1&2&3&2&4" ~
                                                                    , buf_temp-xml-tables.tbl-name ~
                                                                    , num-rec ~
                                                                    , ~{&new-line~} ~
                                                                    , error-status:get-message(1) ~
                                                                    , return-value)
            {&display-message}.
            if valid-handle(v_qh) then do:
              delete object v_qh no-error.
            end.
        undo _main, return error ''.
      end.
      /* ------------------------- &count-retry-action-start& -----------------------------------*/
      /* ------------------------- &start-release-obj& -----------------------------------*/
if v-retry-action < 1 then do:
&scop release_2 dump ( )
ImpData1:Route-data_{&release_2} .
end.

      /* ------------------------- &end-release-obj& -------------------------------------*/
      /* ------------------------- &count-retry-action-end& -----------------------------------*/
      end.
    _rule:
      do on error undo _rule, retry _rule:
        if retry then do:
          &scop my-message  substitute("&1&2&3" ~
                                      , error-status:get-message(1) ~
                                      , ~{&new-line~} ~
                                      , return-value)
          {&display-message}.
          if valid-handle(v_qh) then do:
            delete object v_qh no-error.
          end.
          undo _main, return error ''.
        end.
        else do:
        v_qh:get-next().
        IF v_qh:query-off-end then leave _stroka.
      /* ------------------------- &start-rule& -----------------------------------*/
          /* Импорт  данных по ДНЦ из внешней системы
          Импортируемые данные должны удовлетворять схеме exe/if401.xsd */

          IF  ImpData1:current-tbl-name( ) = "ord-doc"  THEN do:
            create temp_ord-doc.
            temp_ord-doc.line-num   = ImpData1:route-data_get-field-integer    ( input "ord-doc", input "line-num")  .
            temp_ord-doc.doc-date   = ImpData1:route-data_get-field-date       ( input "ord-doc", input "doc-date")  .
            temp_ord-doc.doc-code   = ImpData1:route-data_get-field-character  ( input "ord-doc", input "doc-code")  .
            temp_ord-doc.obj-type   = ImpData1:route-data_get-field-character  ( input "ord-doc", input "obj-type")  .
            temp_ord-doc.obj-code   = ImpData1:route-data_get-field-integer    ( input "ord-doc", input "obj-code")  .
            temp_ord-doc.cli-code   = ImpData1:route-data_get-field-integer    ( input "ord-doc", input "cli-code")  .
            temp_ord-doc.exch-code  = ImpData1:route-data_get-field-integer    ( input "ord-doc", input "exch-code" )  .
            temp_ord-doc.exch-rate  = ImpData1:route-data_get-field-decimal    ( input "ord-doc", input "exch-rate" )  .
            temp_ord-doc.exch-scale = ImpData1:route-data_get-field-integer    ( input "ord-doc", input "exch-scale")  .
            temp_ord-doc.ps         = ImpData1:route-data_get-field-character  ( input "ord-doc", input "ps"  )  .
            temp_ord-doc.corr-doc-code = ImpData1:route-data_get-field-character  ( input "ord-doc", input "corr-doc-code"  )  .
            temp_ord-doc.status_       = ImpData1:route-data_get-field-character  ( input "ord-doc", input "status_"  )  .
            temp_ord-doc.ship-date     = ImpData1:route-data_get-field-date     ( input "ord-doc", input "ship-date"  )  .
            release temp_ord-doc .

          end. /*IF  ImpData1:current-tbl-name( ) = "ord-doc"  THEN do:*/

          IF  ImpData1:current-tbl-name( ) = "ord-line"  THEN do:
            create temp_ord-line.
              temp_ord-line.line-num    = ImpData1:route-data_get-field-integer   ( input "ord-line", input "line-num"   )  .
              temp_ord-line.doc-code    = ImpData1:route-data_get-field-character ( input "ord-line", input "doc-code"   )  .
              temp_ord-line.gds-code    = ImpData1:route-data_get-field-integer   ( input "ord-line", input "gds-code"   )  .
              temp_ord-line.price-rubl  = ImpData1:route-data_get-field-decimal   ( input "ord-line", input "price-rubl" )  .
              temp_ord-line.price-cli   = ImpData1:route-data_get-field-decimal   ( input "ord-line", input "price-cli"  )  .
              temp_ord-line.fact-qnty   = ImpData1:route-data_get-field-decimal   ( input "ord-line", input "fact-qnty"  )  .
              temp_ord-line.vat-pc      = ImpData1:route-data_get-field-decimal   ( input "ord-line", input "vat-pc"     )  .
              release temp_ord-line .
          end. /*IF  ImpData1:current-tbl-name( ) = "ord-line"  THEN do:*/
      /* ------------------------- &end-rule -------------------------------------*/
      end.
    end.
    v-retry-action = 0 .
    _release:
    do on error undo, retry:
      if  retry then do:
        v-retry-action = v-retry-action + 1.
        &scop my-message  substitute("&1&2&3" ~
                                    , error-status:get-message(1) ~
                                    , ~{&new-line~} ~
                                    , v-last-error-message )
        {&display-message}.
        undo _main, return error ''.
      end.
      /* ------------------------- &count-retry-action-start& -----------------------------------*/
      /* ------------------------- &start-release-obj& -----------------------------------*/
      if v-retry-action < 1 then do:
        &scop release_2 dump ( )
        ImpData1:Route-data_{&release_2} .
      end.

      /* ------------------------- &end-release-obj& -------------------------------------*/
      /* ------------------------- &count-retry-action-end& -----------------------------------*/
      end.
      if v-retry-action = 0
      and buf_temp-xml-tables.is-parent
      then do:
        num-rec-ok = num-rec-ok + 1.
      end.
      run write-counter in p-log-handle ( input substitute("Прочитано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
    end. /*repeat*/
    if not v-stop
    and buf_temp-xml-tables.is-parent
    then do:
      num-rec = num-rec - 1.
    end.
    v_qh:query-close().
    if valid-handle(v_qh) then do:
      delete object v_qh.
    end.
  end. /*for each buf_temp-xmp-tables*/


  /* здесь сохраняем в БД */
   run utl/ora-i401.p (
      input parparentproc ,
      input this-procedure ,
      input table temp_ord-doc ,
      input table temp_ord-line ,
      output num-rec-ok2
      ) no-error .

  if error-status:error then do:
    if return-value <> '' then do:
      &scop my-message substitute("Ошибка при сохранении данных по заказу из ВС:&1&2&1&3", {&new-line}, return-value , error-status :get-message(1)  )
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
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_ext-system for ub.ext-system.

  do
  on error undo, return error
  :

/*---------------------------&start-process-rule-call-param&-------------------------------*/

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-esys-id"
 no-error.
if available buf_rule-call-param then do:
assign p-esys-id = buf_rule-call-param.param-value-integer.
end.


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
      when 4 then do:
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
      find first buf_ext-system no-lock where
                buf_ext-system.esys-id = v-esys-id
            and buf_ext-system.db-num = 0 no-error .
      if not available buf_ext-system then do:
        &scop my-message substitute("Не найдена ВС &1&2 ..." ~
                                      , v-esys-id ~
                                      , ~{&new-line~} ~
                                      )
        {&display-message}.
        undo, return error {&my-message}.
      end.

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
        undo, return error "Неправильный вызов".
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */


procedure delete-procedure :

  do
  on error undo, return error
  :
      run garbcoll_clear in this-procedure .
      empty temp-table temp_ord-doc.
      empty temp-table temp_ord-line.
  end.

end procedure. /* delete-procedure */


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