block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удалений атрибутов серий МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/10/07
Author: Polina Gridchina
Creation date: 04/10/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.wth-ser-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-wth-ser-attr for ub.c-wth-ser-attr.
/*define buffer buf_c-wth-hist for ub.c-wth-hist.*/


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  run nws/cmd-del.p
    ( input "wth-ser-attr":U
     ,input (buffer ub.wth-ser-attr:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-wth-ser-attr.
    buffer-copy wth-ser-attr to buf_c-wth-ser-attr
    assign
    buf_c-wth-ser-attr.attr-code           = ub.wth-ser-attr.attr-code
    buf_c-wth-ser-attr.ser-code           = ub.wth-ser-attr.ser-code
    buf_c-wth-ser-attr.db-num           = ub.wth-ser-attr.db-num
    buf_c-wth-ser-attr.chip-num           = next-value (s-wth-chip, {&db-name_schema})
    buf_c-wth-ser-attr.corr-time          = v-time
    buf_c-wth-ser-attr.corr-user-db-num   = g#db-num
    buf_c-wth-ser-attr.corr-user-name     = g#userid
    buf_c-wth-ser-attr.corr-date          = v-date
    .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_wth-ser-attr}
        , input ( buffer ub.wth-ser-attr:handle )
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