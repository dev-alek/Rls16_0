block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице групп сроков годности

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/10/04
Author: Bakhtadze Natalya
Creation date: 03/10/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.group-period-validity OLD old_group-period-validity.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице групп сроков годности".
{ cmp/vssrevis.i "substitute('&1', ub.group-period-validity.gr-per-val-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-group-period-validity for ub.c-group-period-validity.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:

    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя изменять запись ГРУПП СРОКОВ ГОДНОСТИ в УБД" skip
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-group-period-validity.
    buffer-copy old_group-period-validity to buf_c-group-period-validity
    assign
    buf_c-group-period-validity.gr-per-val-code    = ub.group-period-validity.gr-per-val-code
    buf_c-group-period-validity.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-group-period-validity.corr-time          = v-time
    buf_c-group-period-validity.corr-user-db-num   = g#db-num
    buf_c-group-period-validity.corr-user-name     = g#userid
    buf_c-group-period-validity.corr-date          = v-date
    .
  end.

  run str/callnews.p
    (input "group-period-validity"
    ,input (buffer ub.group-period-validity:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_group-period-validity}
        , input ( buffer ub.group-period-validity:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.