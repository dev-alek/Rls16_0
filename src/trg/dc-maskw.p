block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись для таблицы маски дисконтных карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/04
Author: Bakhtadze Natalya
Creation date: 04/05/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.dis-card-mask OLD old_dis-card-mask.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись для таблицы маски дисконтных карт".
{ cmp/vssrevis.i "substitute('&1', ub.dis-card-mask.mask-num) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-dis-card-type for ub.c-dis-card-type.
define buffer buf_c-dis-card-mask for ub.c-dis-card-mask.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news and ( g#db-num > 0 ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя изменять запись МАСКИ ДИСКОНТНЫХ КАРТ в УБД" skip
    view-as alert-box error .
    undo main-block, return error .
  end.

  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-dis-card-mask.
  buffer-copy old_dis-card-mask to buf_c-dis-card-mask
  assign
  buf_c-dis-card-mask.mask-num             = ub.dis-card-mask.mask-num
  buf_c-dis-card-mask.chip-num           = next-value (s-dc-chip, {&db-name_schema})
  buf_c-dis-card-mask.corr-time          = v-time
  buf_c-dis-card-mask.corr-user-db-num   = g#db-num
  buf_c-dis-card-mask.corr-user-name     = g#userid
  buf_c-dis-card-mask.corr-date          = v-date
  buf_c-dis-card-mask.action             = (if new ub.dis-card-mask then integer({&hn-create}) else integer({&hn-update}))
  .

  create buf_c-dis-card-type.
  buffer-copy buf_c-dis-card-mask to buf_c-dis-card-type
  assign
  buf_c-dis-card-type.action = (if new ub.dis-card-mask then integer({&hn-create}) else integer({&hn-update}))
  buf_c-dis-card-type.subject = {&table_dis-card-mask}
  .

  run str/callnews.p
    (input {&table_dis-card-mask}
    ,input (buffer ub.dis-card-mask:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_dis-card-mask}
        , input ( buffer ub.dis-card-mask:handle )
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