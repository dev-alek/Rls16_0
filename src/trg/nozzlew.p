block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись ПИСТОЛЕТА ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/15/07
Author: Dmitry Ukhanov
Creation date: 08/15/07

Автор: Суслов Алексей Юрьевич
Дата создания: 04/04/06
Author: Alexey Suslov
Creation date: 04/04/06


*/

TRIGGER PROCEDURE FOR WRITE OF ub.nozzle NEW BUFFER new_nozzle OLD old_nozzle.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись пистолета ТРК".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , new_nozzle.obj-type
                         , new_nozzle.obj-code
                         , new_nozzle.nozzle-code
                         ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-today as date no-undo .
define variable v-time as integer no-undo .

define buffer buf_c-nozzle for ub.c-nozzle.
define buffer buf_c-nzl-hist for ub.c-nzl-hist.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  run str/callnews.p
    ( input {&table_nozzle}
     ,input (buffer new_nozzle:handle)
    ) .

  if not g#news then do:
    run cur-time in this-procedure
      ( output v-today
       ,output v-time
      ).
    create buf_c-nozzle.
    buffer-copy old_nozzle
    except
    obj-type
    obj-code
    nozzle-code
    to buf_c-nozzle.
    assign
    buf_c-nozzle.obj-type           = new_nozzle.obj-type
    buf_c-nozzle.obj-code           = new_nozzle.obj-code
    buf_c-nozzle.nozzle-code        = new_nozzle.nozzle-code
    buf_c-nozzle.chip-num           = next-value (s-nzl-chip, {&db-name_schema})
    buf_c-nozzle.corr-time          = v-time
    buf_c-nozzle.corr-user-db-num   = g#db-num
    buf_c-nozzle.corr-user-name     = g#userid
    buf_c-nozzle.corr-date          = v-today
    .
    create buf_c-nzl-hist.
    buffer-copy buf_c-nozzle to buf_c-nzl-hist
    assign
    buf_c-nzl-hist.action  = integer( if new( new_nozzle ) then {&hn-create} else {&hn-update} )
    buf_c-nzl-hist.subject = {&table_nozzle}
    buf_c-nzl-hist.is-news = g#news
    .
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p
      ( input {&nwsdochs_action_update}
       ,input {&table_nozzle}
       ,input ( buffer new_nozzle:handle )
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