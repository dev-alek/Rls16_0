block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление sert

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.sert .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление sert".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                             , ub.sert.cli-type
                             , ub.sert.cli-code
                             , ub.sert.sert-code
                             ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-sert for ub.c-sert.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  run nws/cmd-del.p
    ( input "sert":U
     ,input (buffer ub.sert:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
  if not g#news then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-sert.
    buffer-copy ub.sert
    to buf_c-sert
    assign
    buf_c-sert.chip-num           = next-value (s-sert-chip, {&db-name_schema})
    buf_c-sert.corr-time          = v-time
    buf_c-sert.corr-user-db-num   = g#db-num
    buf_c-sert.corr-user-name     = g#userid
    buf_c-sert.corr-date          = v-today
    buf_c-sert.subject            = {&table_sert}
    buf_c-sert.action             =  integer({&hn-delete})
    buf_c-sert.is-news            = g#news
    .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_sert}
        , input ( buffer ub.sert:handle )
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