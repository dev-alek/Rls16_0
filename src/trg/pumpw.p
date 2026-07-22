block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись pump

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.pump OLD old_pump.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись ТРК".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.pump.obj-type
                         , ub.pump.obj-code
                         , ub.pump.pump-code
                         ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-today as date no-undo .
define variable v-time as integer no-undo .

define buffer buf_c-pump for ub.c-pump.
define buffer buf_c-pmp-hist for ub.c-pmp-hist.

Main-Block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run str/callnews.p
    ( input "pump"
     ,input (buffer ub.pump:handle)
    ) .
  if not g#news then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-pump.
    buffer-copy old_pump except
    pump-code
    obj-type
    obj-code
    to buf_c-pump
    .
    assign
    buf_c-pump.obj-type           = ub.pump.obj-type
    buf_c-pump.obj-code           = ub.pump.obj-code
    buf_c-pump.pump-code          = ub.pump.pump-code
    buf_c-pump.chip-num           = next-value (s-pmp-chip, {&db-name_schema})
    buf_c-pump.corr-time          = v-time
    buf_c-pump.corr-user-db-num   = g#db-num
    buf_c-pump.corr-user-name     = g#userid
    buf_c-pump.corr-date          = v-today
    .
    create buf_c-pmp-hist.
    buffer-copy buf_c-pump to buf_c-pmp-hist
    assign
    buf_c-pmp-hist.action  = integer( if new( ub.pump )
                                      then {&hn-create}
                                      else {&hn-update})
    buf_c-pmp-hist.subject = {&table_pump}
    buf_c-pmp-hist.is-news = g#news
    buf_c-pmp-hist.gds-code = ?
    .

  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_pump}
        , input ( buffer ub.pump:handle )
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