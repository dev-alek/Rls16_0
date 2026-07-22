/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием куста из импорта OpenXml

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/16/08
Author: Bakhtadze Natalya
Creation date: 02/16/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure impxcbsh :
define input  parameter p-esys-id as integer   no-undo .
define input  parameter p-pck-num as integer   no-undo .
define input  parameter p-uniq-gate-rec as character no-undo .
define input  parameter p-dataseth as handle no-undo .
define parameter buffer buf_temp-xml-tables for temp-xml-tables.
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer   no-undo .
define variable v-esys-rec-ord as integer   no-undo .
define variable glog as logical   no-undo .
define variable v_qh as handle no-undo .
define variable v-dmp-ord-int64 as int64 no-undo .
define buffer buf_esys-route for ub.esys-route.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  /* инициализируем библиотеку формирования команды */
  run nws/cmd-bush.p persistent set v-esys-cmd-proc-handle no-error .
  if error-status :error  then do:
    delete procedure v-esys-cmd-proc-handle no-error .
    undo main-block, return error  substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                        "&5&4&6"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,{&new-line}
                                        ,error-status:get-message(1)
                                        ,return-value ).
  end. /*if error-status :error  then do:*/
  /* начало формирования команды */
  run begin-create-command in v-esys-cmd-proc-handle
    (input {&cmd-esys-general} /* p-command-name */
    ,input string(- p-esys-id)             /* ИМЕННО С МИНУСОМ - ПОТОМУ ЧТО ИМПОРТ p-esys-id-list      */
    ,output v-esys-cmd-code        /* p-command-code */
    ) no-error.
  if error-status :error  then do:
    delete procedure v-esys-cmd-proc-handle no-error .
    undo main-block, return error  substitute("Ошибка при создании команды &1&2&3&1&4"
                                                     , {&cmd-esys-general}
                                                     , error-status:get-message(1)
                                                     , return-value
                                                     ).
  end. /*if error-status :error  then do:*/
  for each buf_temp-xml-tables where
          buf_temp-xml-tables.gate-handle_ = p-dataseth
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if buf_temp-xml-tables.tbl-name = "ThHeader" then next.
    if buf_temp-xml-tables.tbl-name = "header_" then next.
    /*надо создать query*/
    create query v_qh.
    glog = v_qh:set-buffers( buf_temp-xml-tables.tbl-handle_) no-error.
    if error-status:error
    or
    not glog then do:
      undo main-block, return error substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                                              , buf_temp-xml-tables.tbl-name
                                                              , {&new-line}
                                                              , error-status:get-message(1)
                                                              , return-value).

    end.
    glog = v_qh:query-prepare( substitute( "for each &1 ", buf_temp-xml-tables.tbl-name)) no-error .
    if error-status:error
    or
    not glog then do:
      undo main-block, return error substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                                            , buf_temp-xml-tables.tbl-name
                                                            , {&new-line}
                                                            , error-status:get-message(1)
                                                            , return-value).
    end.
    glog = v_qh:query-open no-error .
    if error-status:error
    or
    not glog then do:
      undo main-block, return error substitute("Ошибка при попытке получить записи &1&2&3&2&4"
                                                            , buf_temp-xml-tables.tbl-name
                                                            , {&new-line}
                                                            , error-status:get-message(1)
                                                            , return-value).
    end.
    _record:
    do while true
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

      v_qh:get-next().
      IF v_qh:query-off-end then leave _record.

      run add-dump in v-esys-cmd-proc-handle
        (input v-esys-cmd-code
        ,input buf_temp-xml-tables.tbl-name
        ,input '+update'
        ,input buf_temp-xml-tables.tbl-handle_
        ,input p-uniq-gate-rec
        ,output v-esys-rec-ord
        ) no-error .
      if error-status:error then do:
        if valid-handle(v-esys-cmd-proc-handle) then do:
          delete procedure v-esys-cmd-proc-handle .
        end.

        undo main-block, return error substitute("Ошибка при добавлении записи &2 в команду с кодом &3&1&4&1&5"
                                            ,{&new-line}
                                            ,buf_temp-xml-tables.tbl-name
                                            ,v-esys-cmd-code
                                            ,error-status:get-message(1)
                                            ,return-value
                                            ) .
      end. /*if error-status :error*/
    end. /*_record*/
    v_qh:query-close().
    if valid-handle(v_qh) then do:
      delete object v_qh.
      v_qh = ?.
    end.
  end. /*for each buf_temp-xml-tables where*/
  run send-command-esys in v-esys-cmd-proc-handle
    (input v-esys-cmd-code /* p-command-code */
    ,input string(- p-esys-id)             /* p-esys-id-list      */
    ,input g#userid        /* p-user-id */
    ,output v-dmp-ord-int64
    ) no-error.
  if error-status :error then do:
    delete procedure v-esys-cmd-proc-handle no-error.
    undo main-block, return error substitute("Ошибка отсылке во внешнюю систему &1 команды с кодом &2&3&4&3&5"
                                                     , p-esys-id
                                                     , v-esys-cmd-code
                                                     , {&new-line}
                                                     , error-status:get-message(1)
                                                     , return-value
                                                     ).

  end. /*if error-status :error*/
  delete procedure v-esys-cmd-proc-handle no-error.
  for each buf_esys-route exclusive-lock where
          buf_esys-route.esys-id = - p-esys-id
      and buf_esys-route.esr-dump-ord = v-dmp-ord-int64
      and buf_esys-route.db-num = g#db-num
       and buf_esys-route.esr-cr-db-num = g#db-num
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
    buf_esys-route.esr-last-pack = p-pck-num
    .

  end. /*for each buf_esys-route exclusive-lock where*/
end. /*doe*/
end procedure. /* impxcbsh */


/* $Workfile$ e n d */