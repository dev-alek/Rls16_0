block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление опции истории и маршрутизации

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/29/06
Author: Bakhtadze Natalya
Creation date: 10/29/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.hist-nws-option.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление опции истории и маршрутизации".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-hist-nws-option for ub.c-hist-nws-option.
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer buf_c-Dis-card-type for ub.c-dis-card-type.



define variable v-message as character no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not (ub.hist-nws-option.subject-group = {&table_c-dc-hist}) then do:
    run nws/cmd-del.p
      ( input {&table_hist-nws-option}
      ,input (buffer ub.hist-nws-option:handle)
      ,input "":U
      ) no-error .
    if error-status :error then do:
      assign
      v-message = substitute( "&1. Ошибка при отправке в новости команды на удаление записи БД. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) )
      .
      message
      v-message
      view-as alert-box error.
      return error v-message .
    end.
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_c-hist-nws-option.
  buffer-copy ub.hist-nws-option
  to buf_c-hist-nws-option
  assign
  buf_c-hist-nws-option.hn-id = ub.hist-nws-option.hn-id
  buf_c-hist-nws-option.db-num = ub.hist-nws-option.db-num
  buf_c-hist-nws-option.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
  buf_c-hist-nws-option.corr-time          = v-time
  buf_c-hist-nws-option.corr-user-db-num   = g#db-num
  buf_c-hist-nws-option.corr-user-name     = g#userid
  buf_c-hist-nws-option.corr-date          = v-today
  .
  if buf_c-hist-nws-option.subject-group = {&table_c-dc-hist} then do:
    create buf_c-dis-card-type.
    assign
    buf_c-dis-card-type.type = buf_c-hist-nws-option.charkey_one
    buf_c-dis-card-type.emitent-host-code = buf_c-hist-nws-option.host-code
    buf_c-dis-card-type.subject = {&table_hist-nws-option}
    buf_c-dis-card-type.corr-user-db-num = buf_c-hist-nws-option.corr-user-db-num
    buf_c-dis-card-type.chip-num = buf_c-hist-nws-option.chip-num
    buf_c-dis-card-type.corr-time          = buf_c-hist-nws-option.corr-time
    buf_c-dis-card-type.corr-user-db-num   = buf_c-hist-nws-option.corr-user-db-num
    buf_c-dis-card-type.corr-user-name     = buf_c-hist-nws-option.corr-user-name
    buf_c-dis-card-type.corr-date          = buf_c-hist-nws-option.corr-date
    buf_c-dis-card-type.action             = integer({&hn-delete})
    .
    create buf_c-table-bind.
    assign
    buf_c-table-bind.chip-num-rec   = buf_c-dis-card-type.chip-num
    buf_c-table-bind.chip-num-src   = buf_c-hist-nws-option.chip-num
    buf_c-table-bind.corr-user-db-num     = buf_c-hist-nws-option.corr-user-db-num
    buf_c-table-bind.tbl-name-rec   = {&table_c-dis-card-type}
    buf_c-table-bind.tbl-name-src   = {&table_c-hist-nws-option}
    buf_c-table-bind.is-news         = g#news
    buf_c-table-bind.corr-user-name  = g#userid
    .
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_hist-nws-option}
        , input ( buffer ub.hist-nws-option:handle )
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