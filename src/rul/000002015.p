/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 20 набор правил 4

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/26/09
Author: Bakhtadze Natalya
Creation date: 01/26/09


---------------------------&start-codex_id=18;ruleset_id=4;-----------------
Импорт данных по валютам и курсам

---------------------------&end-codex_id=18;ruleset_id=4;-----------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 20 набор правил 4".
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
/*{ gbl/gate-clb.i }*/
{ trg/factord.i  }
{ gbl/orapreps.i }
{ gbl/cur-time.i }
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
define variable v_child-qh         as handle    no-undo .
define variable glog as logical no-undo .
define variable v-ds-read-order as character no-undo .
define variable v-esys-id as integer no-undo .
define variable v-pck-num as integer no-undo .
define variable v-extension as character no-undo .
define variable v-err-type as character no-undo .
{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.

define buffer buf_temp-xml-tables for temp-xml-tables.


define variable log-file-name                as character      no-undo .
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .


procedure clear_tt :
  do
  on error  undo, return error substitute( "&1 (clear-tt). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (clear-tt). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (clear-tt). endkey", vss-workfile )
  :
  end.

end procedure. /* clear-tt */

function 00200004_get-error-message returns character :
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
              , input ~{&my-message}~).            ~
          assign v-view-log = yes



/*---------------------------&start-rule-call-param&-------------------------------*/
  define variable p-esys-id  as integer no-undo.
  define variable p-xsd-file as character no-undo.


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/

 { rul/context_f.i  get-thobj-es }











/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run delete-procedure in this-procedure .
end.


&scop sign v-sign *

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error .
if error-status:error
or return-value = "return" then return.

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
define variable v-line-num         as   integer                      no-undo .
/*define variable v-curr-code like ub.currency.curr-code   no-undo .*/
/*define variable v-exch-date like ub.curr-accnt.exch-date no-undo .*/
define variable v-present          as   logical                      no-undo .
/*define variable v-current-tbl-name as   character                    no-undo .*/


define buffer buf_ext-system for ub.ext-system.

if transaction then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute("Вызов процедуры в действующей транзакции недопустим") skip
    view-as alert-box error .
  return error substitute( "&1 (proc-main). Вызов процедуры в действующей транзакции недопустим", vss-workfile ) .

end.

_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  run write-log in p-log-handle ( input 0, "&DLine").
  &scop my-message substitute(".............Импорт данных по валютам и курсам из ВС")
  {&display-message}.
  run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по валютам и курсам из файла &1", file-name)).

  find first buf_ext-system no-lock where
            buf_ext-system.esys-id = p-esys-id
        and buf_ext-system.db-num = 0 no-error.
  if not available buf_ext-system
  or not (buf_ext-system.esys-type  = integer({&openxml-type-oracle-retail})) then do:
  &scop my-message  substitute("Не найдена ВС &1 или она не имеет типа ORACLE RETAIL", p-esys-id)
      {&display-message}.
      undo _main, return error ''.
  end.
  assign
    num-rec          = 0
    num-rec-ok       = 0
    num-rec-ok2      = 0
  .
  _table:
  for each buf_temp-xml-tables where
          buf_temp-xml-tables.order >= 0
      and buf_temp-xml-tables.is-parent = true
  on error undo _table, retry _table
  :
    if retry then do:
      &scop my-message  substitute("Ошибка при попытке получить записи &1&2&3&2&4" ~
                                                              , buf_temp-xml-tables.tbl-name ~
                                                              , ~{&new-line~} ~
                                                              , error-status:get-message(1) ~
                                                              , return-value)
      {&display-message}.
      run delete-procedure in this-procedure .
      if valid-handle(v_qh) then do:
        delete object v_qh no-error.
      end.
      undo _main, return error ''.
    end.
    /*надо создать динамический query*/
    if buf_temp-xml-tables.tbl-name = "THheader" then next.

  /*надо создать динамический query*/
    create query v_qh.
    glog = v_qh:set-buffers( buf_temp-xml-tables.tbl-handle_) no-error.
    if error-status:error
    or not glog
  then do:
    undo _table, retry _table.
  end.
  glog = v_qh:query-prepare( substitute( "for each &1 by &1.line-num", buf_temp-xml-tables.tbl-name)) no-error .
  if error-status:error
  or not glog
  then do:
    undo _table, retry _table.
  end.
  glog = v_qh:query-open no-error .
  if error-status:error
  or not glog
  then do:
    undo _table, retry _table.
  end.
  _stroka:
  REPEAT:
    assign
      num-rec = num-rec + 1
      v-retry-action = 0
    .

    _release:
    do
    on error undo _release, retry _release
    :
      if  retry then do:
        v-retry-action = v-retry-action + 1.
        &scop my-message   substitute("Ошибка при импорте записи &5 &1&2&3&2&4" ~
                                                                    , buf_temp-xml-tables.tbl-name ~
                                                                    , num-rec ~
                                                                    , ~{&new-line~} ~
                                                                    , error-status:get-message(1) ~
                                                                    , return-value)
        {&display-message}.
        run delete-procedure in this-procedure .

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
    do
    on error undo _rule, retry _rule
    :
        if retry then do:
        &scop my-message substitute("Ошибка разбора/приема данных по валютам и курсам из ВС:&1&2&1&3", {&new-line}, return-value, error-status :get-message( 1 ) )
        {&display-message}.

        run set-err-type in p-cont-handle
          ( input v-err-type
          ) no-error.

        run delete-procedure in this-procedure .

        if valid-handle(v_qh) then do:
          delete object v_qh no-error.
        end.
        if valid-handle(v_child-qh) then do:
          delete object v_child-qh no-error.
        end.

          undo _main, return error ''.
        end.
        else do:
        v_qh:get-next().
        if v_qh:query-off-end then do:
          leave _stroka.
        end.
      /* ------------------------- &start-rule& -----------------------------------*/
        IF ImpData1:current-tbl-name( ) = {&table_currency}  THEN do:
          trans_save_currency:
          do transaction
          on error  undo _rule, retry _rule
          on stop   undo _rule, retry _rule
          on endkey undo _rule, retry _rule
          :
            assign
              v-line-num  = ImpData1:route-data_get-field-integer  ( input {&table_currency}, input "line-num":U )
            .

            run get-xcnf_check-imp-rec in p-cont-handle
              ( input "create"
              , input p-esys-id
              , input 0
              , input g#db-num
              , input v-pck-num
              , input substitute( "&1&2", v-line-num, {&table_currency} )
              , output v-present
              ) no-error.
            if error-status:error then do:
              &scop my-message substitute("Ошибка идентификации принимаемых данных по валютам и курсам из ВС:" )
              {&display-message}.
              undo _rule, retry _rule.
            end.
            if v-present = true then do:
              leave trans_save_currency .
            end.

            run proc-save-currency in this-procedure
              ( input ImpData1:route-data_get-field-integer  ( input {&table_currency}, input "curr-code":U)
              , input ImpData1:route-data_get-field-character( input {&table_currency}, input "curr-abbr":U)
              , input "":U /*part-abbr*/
              , input ImpData1:route-data_get-field-character( input {&table_currency}, input "curr-name":U)
              , input "":U /*curr-name-one*/
              , input "":U /*curr-name-three*/
              , input "":U /*curr-name-five*/
              , input "":U /*curr-eng-name*/
              , input "":U /*curr-eng-name-one*/
              , input "":U /*curr-eng-name-three*/
              , input "":U /*curr-eng-name-five*/
              , input "":U /*part-name*/
              , input "":U /*part-name-one*/
              , input "":U /*part-name-three*/
              , input "":U /*part-name-five*/
              , input ImpData1:route-data_get-field-integer  ( input {&table_currency}, input "okv-code":U)
/*              , input ImpData1:route-data_get-field-character( input {&table_currency}, input "status_":U ) */
              ) no-error .
            if error-status:error then do:
              &scop my-message substitute("Ошибка при сохранении данных по валютам при приеме данных из ВС:" )
              {&display-message}.
              undo _rule, retry _rule.
            end.
            else do:
              assign
                num-rec-ok2 = num-rec-ok2 + 1
              .
            end.
          end. /* trans_save_currency */
        end. /*IF  ImpData1:current-tbl-name( ) = {&table_currency}  THEN do:*/

        IF ImpData1:current-tbl-name( ) = {&table_curr-accnt}  THEN do:
          trans_save_curr-accnt:
          do transaction
          on error  undo _rule, retry _rule
          on stop   undo _rule, retry _rule
          on endkey undo _rule, retry _rule
          :
            assign
              v-line-num   = ImpData1:route-data_get-field-integer  ( input {&table_curr-accnt}, input "line-num":U )
            .

            run get-xcnf_check-imp-rec in p-cont-handle
              ( input "create"
              , input p-esys-id
              , input 0
              , input g#db-num
              , input v-pck-num
              , input substitute( "&1&2", v-line-num, {&table_curr-accnt} )
              , output v-present
              ) no-error.
            if error-status:error then do:
              &scop my-message substitute("Ошибка идентификации принимаемых данных по валютам и курсам из ВС:" )
              {&display-message}.
              undo _rule, retry _rule.
            end.
            if v-present = true then do:
              leave trans_save_curr-accnt .
            end.

            run proc-save-curr-accnt in this-procedure
              ( input ImpData1:route-data_get-field-integer  ( input {&table_curr-accnt}, input "curr-code":U )
              , input ImpData1:route-data_get-field-date     ( input {&table_curr-accnt}, input "exch-date":U )
              , input ImpData1:route-data_get-field-decimal  ( input {&table_curr-accnt}, input "exch-rate":U)
              , input ImpData1:route-data_get-field-integer  ( input {&table_curr-accnt}, input "exch-scale":U)
              , input ImpData1:route-data_get-field-character( input {&table_curr-accnt}, input "status_":U )
              ) no-error .
            if error-status:error then do:
              &scop my-message substitute("Ошибка при сохранении данных по курсам валют при приеме данных из ВС:" )
              {&display-message}.
              undo _rule, retry _rule.
            end.
            else do:
              assign
                num-rec-ok2 = num-rec-ok2 + 1
              .
            end.
          end. /* trans_save_curr-accnt */
        end. /* IF ImpData1:current-tbl-name( ) = {&table_curr-accnt}  THEN do: */

      /* ------------------------- &end-rule -------------------------------------*/
      end.
    end.
    v-retry-action = 0 .
    _release:
    do
    on error undo _release, retry _release
    :
      if  retry then do:
        v-retry-action = v-retry-action + 1.
        &scop my-message   substitute("Ошибка при импорте записи &5 &1&2&3&2&4" ~
                                      , buf_temp-xml-tables.tbl-name ~
                                      , num-rec ~
                                      , ~{&new-line~} ~
                                      , error-status:get-message(1) ~
                                      , return-value)
        {&display-message}.
        run delete-procedure in this-procedure .

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

    if v-retry-action = 0 then do:
      num-rec-ok = num-rec-ok + 1.
    end.
    run write-counter in p-log-handle ( input substitute("Прочитано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
    /*
    process events.
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
        run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input substitute("Процесс импорта прерван пользователем")).
       undo _main, return error .
    end.
    */
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

run write-log-and-file in p-log-handle
  ( input 1
  , input log-file-name
  , input 1
  , input substitute("Прочитано записей: &1, из них удачно обработано: &2", num-rec, num-rec-ok2)
  ).

end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define variable v-itop as integer   no-undo .
define variable v-ichild as integer   no-undo .
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
and buf_rule-call-param.param-name = "p-xsd-file"
 no-error.
if available buf_rule-call-param then do:
assign p-xsd-file = buf_rule-call-param.param-value-character.
end.

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
        v-extension = entry(num-entries(file-name, "."), file-name, ".")
        v-pck-num = integer(entry(3, p-process-file-name, {&delim-par}))
        log-file-name = entry(4, p-process-file-name, {&delim-par})
        no-error
        .
        if error-status:error then do:
          &scop my-message substitute("Ошибки параметров&1&2 ..." ~
                                        , ~{&new-line~} ~
                                        , error-status:get-message(1) )
          {&display-message}.
          undo, return error {&my-message}.
        end.
        find first buf_ext-system no-lock where
                  buf_ext-system.esys-id = v-esys-id
              and buf_ext-system.db-num = 0 no-error .
        if not available buf_ext-system then do:
          &scop my-message substitute("Не найдена ВС &1&2пропускаем ..." ~
                                        , v-esys-id ~
                                        , ~{&new-line~} ~
                                        )
          {&display-message}.
          undo, return error {&my-message}.

        end.
        if v-extension = ''
        or lookup(v-extension, "dat") = 0 then do:
          &scop my-message substitute("Файл &1 имеет недопустимое расширение &3&2пропускаем ..." ~
                                        ,file-name ~
                                        , ~{&new-line~} ~
                                        , v-extension ~
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
        end. /*        do v-itop = 1 to v_dataseth:num-top-buffers:*/
      end.
      otherwise do:
        undo, return error "Неправильный вызов".
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */

procedure delete-procedure :

  do
  on error  undo, return error substitute( "&1 (delete-procedure). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (delete-procedure). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (delete-procedure). endkey", vss-workfile )
  :
      run clear_tt in this-procedure .
      run garbcoll_clear in this-procedure .

  end.

end procedure. /* delete-procedure */

procedure proc-save-currency :

  define input  parameter p-curr-code           like ub.currency.curr-code           no-undo .
  define input  parameter p-curr-abbr           like ub.currency.curr-abbr           no-undo .
  define input  parameter p-part-abbr           like ub.currency.part-abbr           no-undo .
  define input  parameter p-curr-name           like ub.currency.curr-name           no-undo .
  define input  parameter p-curr-name-one       like ub.currency.curr-name-one       no-undo .
  define input  parameter p-curr-name-three     like ub.currency.curr-name-three     no-undo .
  define input  parameter p-curr-name-five      like ub.currency.curr-name-five      no-undo .
  define input  parameter p-curr-eng-name       like ub.currency.curr-eng-name       no-undo .
  define input  parameter p-curr-eng-name-one   like ub.currency.curr-eng-name-one   no-undo .
  define input  parameter p-curr-eng-name-three like ub.currency.curr-eng-name-three no-undo .
  define input  parameter p-curr-eng-name-five  like ub.currency.curr-eng-name-five  no-undo .
  define input  parameter p-part-name           like ub.currency.part-name           no-undo .
  define input  parameter p-part-name-one       like ub.currency.part-name-one       no-undo .
  define input  parameter p-part-name-three     like ub.currency.part-name-three     no-undo .
  define input  parameter p-part-name-five      like ub.currency.part-name-five      no-undo .
  define input  parameter p-okv-code            like ub.currency.okv-code            no-undo .
/*  define input  parameter p-status              as   character                       no-undo .*/

  do
  on error  undo, return error substitute( "&1 (proc-save-currency). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (proc-save-currency). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (proc-save-currency). endkey", vss-workfile )
  :
    define buffer buf_currency for ub.currency .

    define variable v-rid  as recid     no-undo .
    define variable v-stts as character no-undo .

/*    if p-status = {&ora-line-delete} then do:*/
/*      undo, return error substitute( "&1 (proc-save-currency) Удаление валют запрещено.", vss-workfile ) .*/
/*    end.*/

    find first buf_currency exclusive-lock
      where buf_currency.curr-code = p-curr-code
      no-error .
    if available buf_currency then do:
      assign
        v-rid  = recid( buf_currency )
        v-stts = {&ora-line-update}
      .
    end.
    else do:
      assign
        v-rid  = ?
        v-stts = {&ora-line-create}
      .
    end.

    run ref/currenc1.p
      ( input-output v-rid
      , input ( if v-stts = {&ora-line-create} then {&add-def} else {&update} )
      , input true /* p-silent */
      , input p-curr-code
      , input p-curr-abbr
      , input p-part-abbr
      , input p-curr-name
      , input p-curr-name-one
      , input p-curr-name-three
      , input p-curr-name-five
      , input p-curr-eng-name
      , input p-curr-eng-name-one
      , input p-curr-eng-name-three
      , input p-curr-eng-name-five
      , input p-part-name
      , input p-part-name-one
      , input p-part-name-three
      , input p-part-name-five
      , input p-okv-code
      ) no-error .
    if error-status:error then do:
      undo, return error substitute( "&1 (proc-save-currency). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)) .
    end.

  end.

end procedure. /* proc-save-currency */

procedure proc-save-curr-accnt :

  define input  parameter p-curr-code  like ub.curr-accnt.curr-code   no-undo .
  define input  parameter p-exch-date  like ub.curr-accnt.exch-date   no-undo .
  define input  parameter p-exch-rate  like ub.curr-accnt.exch-rate   no-undo .
  define input  parameter p-exch-scale like ub.curr-accnt.exch-scale  no-undo .
  define input  parameter p-status     as   character                 no-undo .

  do transaction
  on error  undo, return error substitute( "&1 (proc-save-curr-accnt). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (proc-save-curr-accnt). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (proc-save-curr-accnt). endkey", vss-workfile )
  :
    define buffer buf_currency   for ub.currency .
    define buffer buf_curr-accnt for ub.curr-accnt .
    define buffer buf_curr-bank  for ub.curr-bank .

    define variable v-rid   as recid     no-undo .
    define variable v-today as date      no-undo .
    define variable v-time  as integer   no-undo .
    define variable v-stts  as character no-undo .

    find first buf_currency exclusive-lock
      where buf_currency.curr-code = p-curr-code
      no-error .
    if not available buf_currency then do:
      undo, return error substitute( "&1 (proc-save-currency) Отсутствует валюта с кодом &2 .", vss-workfile, p-curr-code ) .
    end.

    run cur-time in this-procedure
      ( output v-today
      , output v-time
      ).

    if p-status = {&ora-line-delete}
      and p-exch-date < v-today
    then do:
      undo, return error substitute( "&1 (proc-save-currency) Запрещено удалять курс с датой меньше текущей.&2Запрошено удаление курса валюты &3 на &4"
                                     , vss-workfile
                                     , {&new-line}
                                     , buf_currency.curr-abbr
                                     , p-exch-date
                                    ) .
    end.


    find first buf_curr-accnt exclusive-lock
      where buf_curr-accnt.curr-code = p-curr-code
        and buf_curr-accnt.exch-date = p-exch-date
      no-error .
    if available buf_curr-accnt then do:
      assign
        v-rid  = recid( buf_curr-accnt )
        v-stts = {&update}
      .
    end.
    else do:
      assign
        v-rid  = ?
        v-stts = {&add-def}
      .
    end.

    if p-status = {&ora-line-delete} then do:
      if available buf_curr-accnt then do:
        disable triggers for load of ub.curr-accnt .
        delete buf_curr-accnt .
      end.
      else do:
        undo, return error substitute( "&1 (proc-save-currency) Отсутствует курс ММВБ для валюты &2 на &3.", vss-workfile, buf_currency.curr-abbr, string( p-exch-date, "99/99/9999" ) ) .
      end.
    end.
    else do:
      run ref/curracc1.p
        ( input-output v-rid
        , input v-stts
        , input true /* p-silent */
        , input p-curr-code
        , input p-exch-date
        , input p-exch-rate
        , input p-exch-scale
        ) .
    end.


    find first buf_curr-bank exclusive-lock
      where buf_curr-bank.curr-code = p-curr-code
        and buf_curr-bank.exch-date = p-exch-date
      no-error .
    if available buf_curr-bank then do:
      assign
        v-rid  = recid( buf_curr-bank )
        v-stts = {&update}
      .
    end.
    else do:
      assign
        v-rid  = ?
        v-stts = {&add-def}
      .
    end.

    if p-status = {&ora-line-delete} then do:
      if available buf_curr-bank then do:
        disable triggers for load of ub.curr-bank .
        delete buf_curr-bank .
      end.
      else do:
        undo, return error substitute( "&1 (proc-save-currency) Отсутствует курс ЦБ для валюты &2 на &3.", vss-workfile, buf_currency.curr-abbr, string( p-exch-date, "99/99/9999" ) ) .
      end.
    end.
    else do:
      run ref/currbnk1.p
        ( input-output v-rid
        , input v-stts
        , input true /* p-silent */
        , input p-curr-code
        , input p-exch-date
        , input p-exch-rate
        , input p-exch-scale
        ) .
    end.

  end.

end procedure. /* proc-save-tax-rate */