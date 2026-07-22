/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/31/08
Author: Bakhtadze Natalya
Creation date: 01/31/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure fillxpck :
define parameter buffer buf_esys-route for ub.esys-route.
define output parameter p-dataseth as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define output parameter p-num-rec as integer no-undo .

define variable bh_route-dump as handle no-undo .
define variable tt-name as character no-undo .
define variable v-ok as logical no-undo .
define variable v-route-order-field as character no-undo .
define variable v-dump-order-field as character no-undo .

define variable v-esys-id as integer no-undo .
define variable v-db-num as integer no-undo .
define variable v-cr-db-num as integer no-undo .
define variable v-esr-dump-ord as int64 no-undo .
define variable v-esr-tbl-ord as int64 no-undo .
define variable v-pack-num as integer no-undo .


define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_temp-xml-tables for temp-xml-tables.

  main-block:
  do
  on error undo, return error
  :
    define variable v-longchar as longchar no-undo .
    v-longchar = ?.
    run get-gate-by-rec in this-procedure ( input buf_esys-route.uniq-gate-rec
                                            ,output p-dataseth
                                            ,input-output p-xmlh
                                            ,input-output v-longchar
                                            ) no-error.
    if error-status:error then do:
        undo main-block, return error substitute("Ошибка при создании структуры маршрутизируемых данных согласно гейту:&1&2"
                            , buf_esys-route.uniq-gate-rec
                            , {&new-line}
                            , error-status:get-message(1) ).
    end.
    run all-gates-empty in this-procedure no-error.
    assign
    v-esys-id = buf_esys-route.esys-id
    v-db-num = buf_esys-route.db-num
    v-cr-db-num = buf_esys-route.esr-cr-db-num
    v-esr-dump-ord = buf_esys-route.esr-dump-ord
    v-esr-tbl-ord = buf_esys-route.esr-tbl-ord
    v-pack-num = buf_esys-route.esr-last-pack
    .

    _fill:
    do while true:
      assign
      v-route-order-field = ''
      v-dump-order-field = ''
      .
    for each buf_esys-route-dump where
          buf_esys-route-dump.esrd-dump-ord   = v-esr-dump-ord
    by buf_esys-route-dump.esrd-rec-ord
    by buf_esys-route-dump.esrd-cr-db-num
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      bh_route-dump = (buffer buf_esys-route-dump:handle).
      if buf_esys-route-dump.uniq-gate-rec <> '':u then do:
        find first buf_temp-xml-tables where
                  buf_temp-xml-tables.tbl-name = buf_esys-route-dump.esrd-dump-name
              and buf_temp-xml-tables.uniq-gate-rec = buf_esys-route-dump.uniq-gate-rec no-error.
        if not available buf_temp-xml-tables then do:
          run gate-clear in this-procedure ( input p-dataseth, input p-xmlh).
          undo main-block, return error substitute( "&1. Не найдена таблица &2 в гейте &3 (1).&4&5"
                                    , vss-workfile
                                    , buf_esys-route-dump.esrd-dump-name
                                    , buf_esys-route-dump.uniq-gate-rec
                                    , {&new-line}
                                    , error-status:get-message(1) ).
        end.
        if buf_temp-xml-tables.is-parent
        and not (buf_esys-route-dump.esrd-action begins "_hidden="
                  or buf_esys-route-dump.esrd-action begins "_route-order="
                  or buf_esys-route-dump.esrd-action begins "_dump-order="
                  )
        then do:
          p-num-rec = p-num-rec + 1.
        end.
      end. /*          if buf_esys-route-dump.uniq-gate-rec <> '':u then do:*/
      else do: /*like ub*/
        find first buf_temp-xml-tables where
                  buf_temp-xml-tables.tbl-name = buf_esys-route-dump.esrd-dump-name
              and buf_temp-xml-tables.uniq-gate-rec = '':U no-error.
        if not available buf_temp-xml-tables then do:
              /*сюда попадем только если импортируеме СОБСТВЕННЫЕ ТАБЛИЦЫ IBS TH - не temp-table*/
          create buf_temp-xml-tables.
          assign
          buf_temp-xml-tables.tbl-name = buf_esys-route-dump.esrd-dump-name
          buf_temp-xml-tables.tbl-handle_ = ?
          buf_temp-xml-tables.table-handle_ = ?
          buf_temp-xml-tables.gate-handle_ = ?
          buf_temp-xml-tables.uniq-gate-rec = ''
          buf_temp-xml-tables.gate-name = ''
          .
          create temp-table buf_temp-xml-tables.table-handle_.
          assign
          buf_temp-xml-tables.table-handle_:undo      = false
          tt-name       = "tt_":U + buf_esys-route-dump.esrd-dump-name
          .
          assign
          v-ok = buf_temp-xml-tables.table-handle_:create-like( "ub.":U + buf_esys-route-dump.esrd-dump-name ) no-error
          .
          if v-ok <> true
            or error-status :error
          then do:
            run gate-clear in this-procedure ( input p-dataseth, input p-xmlh).
            undo main-block, return error substitute( "&1. Ошибка при создании временной таблицы &2 (1).&3&4", vss-workfile, tt-name, {&new-line}, error-status:get-message(1) ).
          end.

          assign
            v-ok = buf_temp-xml-tables.table-handle_:temp-table-prepare( tt-name ) no-error
          .
          if v-ok <> true
            or error-status :error
          then do:
            run gate-clear in this-procedure ( input p-dataseth, input p-xmlh).
            undo main-block, return error substitute( "&1. Ошибка при создании временной таблицы &2 (2).&3&4", vss-workfile, tt-name, {&new-line}, error-status:get-message(1) ).
          end.
        end.
        assign
        buf_temp-xml-tables.tbl-handle_ = buf_temp-xml-tables.table-handle_:default-buffer-handle
        p-num-rec = p-num-rec + 1
        .
      end. /*like ub*/
      if buf_esys-route-dump.esrd-action begins "_hidden="
      or buf_esys-route-dump.esrd-action begins "_route-order="
      or buf_esys-route-dump.esrd-action begins "_dump-order="
      then do:
      if buf_esys-route-dump.esrd-action begins "_hidden=" then do:
        assign
        buf_temp-xml-tables.tbl-handle_:buffer-field(entry(2, buf_esys-route-dump.esrd-action, "=")):xml-node-type = "hidden" no-error.
        if error-status:error then do:
          run gate-clear in this-procedure ( input p-dataseth, input p-xmlh).
          undo main-block, return error substitute( "&1. Измение типа узла на HIdden не прошел для таблицы &2.&3&4"
                                                  ,vss-workfile
                                                  ,buf_esys-route-dump.esrd-dump-name
                                                  ,{&new-line}
                                                  ,error-status:get-message(1) ).
        end.
      end.
        if buf_esys-route-dump.esrd-action begins "_route-order="  then do:
          v-route-order-field = entry(2, buf_esys-route-dump.esrd-action, "=").
        end.
        if buf_esys-route-dump.esrd-action begins "_dump-order="  then do:
          v-dump-order-field = entry(2, buf_esys-route-dump.esrd-action, "=").
        end.
      end.
      else do:
      assign
        v-ok = buf_temp-xml-tables.tbl-handle_:buffer-create no-error
      .
      if v-ok <> true
        or error-status :error
      then do:
        run gate-clear in this-procedure ( input p-dataseth, input p-xmlh).
        undo main-block, return error substitute( "&1. Ошибка при создании записи в буфере временной таблицы &2 .&3&4", vss-workfile, tt-name, {&new-line}, error-status:get-message(1) ).
      end.
      assign
        v-ok = buf_temp-xml-tables.tbl-handle_:raw-transfer ( false, bh_route-dump:buffer-field("esrd-value-rec") ) no-error
      .
      if v-ok <> true
        or error-status :error
      then do:
        run gate-clear in this-procedure ( input p-dataseth, input p-xmlh).
          undo main-block, return error substitute( "&1. RAW-TRANSFER не прошел для таблицы &2.&3&4", vss-workfile, buf_temp-xml-tables.tbl-name, {&new-line}, error-status:get-message(1) ).
      end.
        if v-route-order-field <> '' then do:
          assign
          buf_temp-xml-tables.tbl-handle_:buffer-field(v-route-order-field):buffer-value = string(buf_esys-route.esr-tbl-ord, "9999999999999999999") + "-" +
                                                                                           string(buf_esys-route-dump.esrd-rec-ord, "9999999999")
          .
        end.
        if v-dump-order-field <> '' then do:
          assign
          buf_temp-xml-tables.tbl-handle_:buffer-field(v-dump-order-field):buffer-value = string(buf_esys-route-dump.esrd-dump-ord, "9999999999999999999") + "-" +
                                                                                          string(buf_esys-route-dump.esrd-rec-ord, "9999999999")

          .
        end.
      end.
    end. /*for each buf_esys-route-dump where*/
      if buf_esys-route.esr-action = {&nwsdochs_action_command-pbush} then do:
        find first  buf_esys-route exclusive-lock where
                  buf_esys-route.esys-id = v-esys-id
              and buf_esys-route.db-num = v-db-num
              and buf_esys-route.esr-cr-db-num = v-cr-db-num
              and buf_esys-route.esr-last-pack = v-pack-num
              and buf_esys-route.esr-tbl-ord > v-esr-tbl-ord no-error.
        if not available buf_esys-route then leave _fill.
        v-esr-tbl-ord = buf_esys-route.esr-tbl-ord.
        v-esr-dump-ord = buf_esys-route.esr-dump-ord.
      end.
      else do:
        leave _fill.
      end.
    end. /*_fill*/
  end.

end procedure. /* fill-xpck */

procedure fillxpck_empty :
define output parameter p-dataseth as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define output parameter p-num-rec as integer no-undo .


do
on error undo, return error
:
  create dataset p-dataseth .
  assign
  p-dataseth:name = "empty"
  .
end.

end procedure.  /* fill-empty */

/* $Workfile$ e n d */