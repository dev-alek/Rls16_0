/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 20 набор правил 4

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/05/09
Author: Dmitry Ukhanov
Creation date: 02/05/09

---------------------------&start-codex_id=18;ruleset_id=4;-----------------
Импорт ед. изм.

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
{ gbl/gate-clb.i }
{ trg/factord.i  }


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
define variable v-unit-name like ub.units.unit-name no-undo .
define variable v-long-name like ub.units.long-name no-undo .
define variable v-unit-type like ub.units.type      no-undo .
define variable v-line-num  as   integer            no-undo .
define variable v-present   as   logical            no-undo .


define buffer buf_ext-system for ub.ext-system.


_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

/*надо найти настройки маршрутизации и записи истории для данного типа ДК для всех объектов*/

/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/

run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
&scop my-message substitute(".............Импорт данных по единицам измерения из ВС")
  {&display-message}.
&scop my-message substitute("Импорт данных по единицам измерения из файла &1", file-name)
  {&display-message}.

    find first buf_ext-system no-lock where
              buf_ext-system.esys-id = p-esys-id
          and buf_ext-system.db-num = 0 no-error.
    if not available buf_ext-system
    or not (buf_ext-system.esys-type  = integer({&openxml-type-oracle-retail})) then do:
    &scop my-message  substitute("Не найдена ВС &1 или она не имеет типа ORACLE RETAIL", p-esys-id)
       {&display-message}.
       undo _main, return error ''.
    end.
  do v-ii = 1 to num-entries(v-ds-read-order):
    find first buf_temp-xml-tables where
              buf_temp-xml-tables.tbl-name = entry(v-ii, v-ds-read-order)
        and  buf_temp-xml-tables.gate-handle_ = v_dataseth.
        /*for each buf_temp-xmp-tables */
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
  glog = v_qh:query-prepare( substitute( "for each &1 by &1.line-num", buf_temp-xml-tables.tbl-name)) no-error .
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
    if buf_temp-xml-tables.is-parent
    then do:
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
          &scop my-message substitute("&1&2&3", error-status:get-message(1), {&new-line}, return-value)
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
          IF  ImpData1:current-tbl-name( ) = {&table_units}  THEN do:
            trans_save:
            do transaction
            on error  undo trans_save, retry trans_save
            on stop   undo trans_save, retry trans_save
            on endkey undo trans_save, retry trans_save
            :
              assign
                v-line-num  = ImpData1:route-data_get-field-integer  ( input {&table_units}, input "line-num":U )
                v-unit-name = ImpData1:route-data_get-field-character( input {&table_units}, input "unit-name":U)
                v-long-name = ImpData1:route-data_get-field-character( input {&table_units}, input "long-name":U)
                v-unit-type = ImpData1:route-data_get-field-character( input {&table_units}, input "type":U)
              .

              run get-xcnf_check-imp-rec in p-cont-handle
                ( input "create"
                , input p-esys-id
                , input 0
                , input g#db-num
                , input v-pck-num
                , input substitute( "&1,&2", v-line-num, v-unit-name )
                , output v-present
                ) no-error.
              if error-status:error then do:
                if return-value <> '' then do:
                  &scop my-message substitute("Ошибка идентификации принимаемых данных по единице измерения из ВС:&1&2", {&new-line}, return-value )
                  {&display-message}.
                end.
                run set-err-type in p-cont-handle
                  ( input v-err-type
                  ) no-error.

                undo _main, return error ''.
              end.
              if v-present = true then do:
                leave trans_save .
              end.
              run proc-save-units in this-procedure
                ( input v-unit-name
                , input v-long-name
                , input v-unit-type
                , input 0 /* units.OKEI */
                ) no-error .
              /*пищем процедуру сохранения в err-type должен храниться тип ошибки*/

              if error-status:error then do:
                if return-value <> '' then do:
                  &scop my-message substitute("Ошибка при сохранении данных по единице измерения при приеме данных из ВС:&1&2", {&new-line}, return-value )
                  {&display-message}.
                end.
                run set-err-type in p-cont-handle
                  ( input v-err-type
                  ) no-error.

                run delete-procedure in this-procedure .
                undo _main, return error ''.
              end.
              else do:
                assign
                  num-rec-ok2 = num-rec-ok2 + 1
                .
              end.
            end.
          end. /*IF  ImpData1:current-tbl-name( ) = "units"  THEN do:*/

      /* ------------------------- &end-rule -------------------------------------*/
      end.
    end.
    v-retry-action = 0 .
    _release:
    do on error undo, retry:
      if  retry then do:
        v-retry-action = v-retry-action + 1.
        &scop my-message substitute("&1&2&3", error-status:get-message(1), {&new-line}, v-last-error-message )
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
      /*
      process events.
      run get-stop-state in p-log-handle ( output v-stop) no-error .
      if v-stop then do:
        &scop my-message substitute("Процесс импорта прерван пользователем")
          {&display-message}.
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


  &scop my-message substitute("Прочитано записей: &1, из них удачно обработано: &2", num-rec, num-rec-ok2)
    {&display-message}.

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

procedure proc-save-units :

  define input  parameter p-unit-name like ub.units.unit-name no-undo .
  define input  parameter p-long-name like ub.units.long-name no-undo .
  define input  parameter p-unit-type like ub.units.type      no-undo .
  define input  parameter p-OKEI      like ub.units.OKEI      no-undo .

  do
  on error  undo, return error substitute( "&1 (proc-save-units). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo, return error substitute( "&1 (proc-save-units). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (proc-save-units). endkey", vss-workfile )
  :
    define buffer buf_units for ub.units .

    define variable v-rid  as recid     no-undo .
    define variable v-mode as character no-undo .

    find first buf_units exclusive-lock
      where buf_units.unit-name = p-unit-name
      no-error .
    if available buf_units then do:
      assign
        v-mode = {&update}
        v-rid  = recid( buf_units )
      .
    end.
    else do:
      assign
        v-mode = {&add-def}
        v-rid  = ?
      .
    end.

    run ref/units01.p
      ( input-output v-rid
      , input v-mode
      , input p-OKEI
      , input p-long-name
      , input p-unit-type
      , input p-unit-name
      ) no-error.
    if error-status:error then do:
      undo, return error substitute( "&1 (proc-save-units). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)) .
    end.

  end.

end procedure. /* proc-save-units */