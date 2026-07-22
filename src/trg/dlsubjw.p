block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице СУБЪЕКТЫ ДОСТАВКИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/17/04
Author: Bakhtadze Natalya
Creation date: 03/17/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.delivery-subject old old_delivery-subject.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице СУБЪЕКТ ДОСТАВКИ".
{ cmp/vssrevis.i "substitute('&1', ub.delivery-subject.deliv-subj-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-delivery-subject for ub.c-delivery-subject.

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
      "Нельзя изменять запись СУБЪЕКТ ДОСТАВКИ в УБД" skip
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-delivery-subject.
    buffer-copy old_delivery-subject to buf_c-delivery-subject
    assign
    buf_c-delivery-subject.deliv-subj-code    = ub.delivery-subject.deliv-subj-code
    buf_c-delivery-subject.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-delivery-subject.corr-time          = v-time
    buf_c-delivery-subject.corr-user-db-num   = g#db-num
    buf_c-delivery-subject.corr-user-name     = g#userid
    buf_c-delivery-subject.corr-date          = v-date
    .
  end.

  run str/callnews.p
    (input "delivery-subject"
    ,input (buffer ub.delivery-subject:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_delivery-subject}
        , input ( buffer ub.delivery-subject:handle )
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