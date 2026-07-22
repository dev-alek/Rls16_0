block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице УСЛОВИЯ ХРАНЕНИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/15/04
Author: Bakhtadze Natalya
Creation date: 03/15/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.condition-keeping OLD old_condition-keeping.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице УСЛОВИЯ ХРАНЕНИЯ".
{ cmp/vssrevis.i "substitute('&1', ub.condition-keeping.cond-keep-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-condition-keeping for ub.c-condition-keeping.

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
      "Нельзя изменять запись УСЛОВИЯ ХРАНЕНИЯ в УБД" skip
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-condition-keeping.
    buffer-copy old_condition-keeping to buf_c-condition-keeping
    assign
    buf_c-condition-keeping.cond-keep-code    = ub.condition-keeping.cond-keep-code
    buf_c-condition-keeping.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-condition-keeping.corr-time          = v-time
    buf_c-condition-keeping.corr-user-db-num   = g#db-num
    buf_c-condition-keeping.corr-user-name     = g#userid
    buf_c-condition-keeping.corr-date          = v-date
    .
  end.

  run str/callnews.p
    (input "condition-keeping"
    ,input (buffer ub.condition-keeping:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_condition-keeping}
        , input ( buffer ub.condition-keeping:handle )
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