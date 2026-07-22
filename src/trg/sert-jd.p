block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись привязки сертификата к бар-коду

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.sert-join .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись привязки сертификата к бар-коду".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                             , ub.sert-join.cli-type
                             , ub.sert-join.cli-code
                             , ub.sert-join.sert-code
                             , ub.sert-join.b-code
                             ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define buffer buf_c-sert for ub.c-sert.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_c-table-bind for ub.c-table-bind.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_bar-code where
          buf_bar-code.b-code = ub.sert-join.b-code no-lock no-error .
  if not available buf_bar-code then do:
    undo main-block, return error substitute( "&1. Не найден бар-код при удалении сертификата на товар. &2&3"
                                               , {&new-line}
                                               , vss-workfile
                                                ).
  end.

  run nws/cmd-del.p
    ( input {&table_sert-join}
     ,input (buffer ub.sert-join:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
  if not g#news then do:
    run cur-time in this-procedure(output v-today, output v-time).

    create buf_c-sert.
    buffer-copy ub.sert-join
    to buf_c-sert
    assign
    buf_c-sert.chip-num           = next-value (s-sert-chip, {&db-name_schema})
    buf_c-sert.corr-time          = v-time
    buf_c-sert.corr-user-db-num   = g#db-num
    buf_c-sert.corr-user-name     = g#userid
    buf_c-sert.corr-date          = v-today
    buf_c-sert.subject            = {&table_sert-join}
    buf_c-sert.action             = integer({&hn-delete})
    buf_c-sert.is-news            = g#news
    .
    create buf_c-gds-hist.
    assign
    buf_c-gds-hist.gds-code        =  buf_bar-code.gds-code
    buf_c-gds-hist.b-code          =  buf_c-sert.b-code
    buf_c-gds-hist.subject         = {&table_sert-join}
    buf_c-gds-hist.action          =   integer({&hn-delete})
    buf_c-gds-hist.is-news            = g#news
    buf_c-gds-hist.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-gds-hist.corr-time          = v-time
    buf_c-gds-hist.corr-user-db-num   = g#db-num
    buf_c-gds-hist.corr-user-name     = g#userid
    buf_c-gds-hist.corr-date          = v-today
    .
    create buf_c-table-bind.
    assign
    buf_c-table-bind.chip-num-rec   = buf_c-gds-hist.chip-num
    buf_c-table-bind.chip-num-src   = buf_c-sert.chip-num
    buf_c-table-bind.corr-user-db-num   = buf_c-sert.corr-user-db-num
    buf_c-table-bind.tbl-name-rec   = {&table_c-gds-hist}
    buf_c-table-bind.tbl-name-src   = {&table_c-sert}
    buf_c-table-bind.is-news         = g#news
    buf_c-table-bind.corr-user-name  = g#userid
    buf_c-table-bind.subject         = {&table_sert-join}
    .
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_sert-join}
        , input ( buffer ub.sert-join:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.
