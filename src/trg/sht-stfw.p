block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись персонала смены

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/09/05
Author: Bakhtadze Natalya
Creation date: 08/09/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.shift-staff old oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись персонала смены".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                            , ub.shift-staff.obj-type
                            , ub.shift-staff.obj-code
                            , ub.shift-staff.shift-date
                            , ub.shift-staff.shift-num
                            , ub.shift-staff.next-shift
                            , ub.shift-staff.psn-num
                            ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define buffer buf_c-shift-staff for ub.c-shift-staff.
define buffer buf_c-sht-hist for ub.c-sht-hist.
/*здесь только создаем историю - маршрутизация пойдет из shift-obj или c-shift-obj - если удалят не закрыв*/


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-shift-staff.
    buffer-copy oldb except
    obj-type
    obj-code
    shift-date
    shift-num
    shift-name
    next-shift
    psn-num
    to buf_c-shift-staff
    .
    assign
    buf_c-shift-staff.obj-type           = ub.shift-staff.obj-type
    buf_c-shift-staff.obj-code           = ub.shift-staff.obj-code
    buf_c-shift-staff.shift-date         = ub.shift-staff.shift-date
    buf_c-shift-staff.shift-num          = ub.shift-staff.shift-num
    buf_c-shift-staff.shift-name         = ub.shift-staff.shift-name
    buf_c-shift-staff.next-shift         = ub.shift-staff.next-shift
    buf_c-shift-staff.psn-num            = ub.shift-staff.psn-num
    buf_c-shift-staff.chip-num           = next-value (s-shift-chip, {&db-name_schema})
    buf_c-shift-staff.corr-time          = v-time
    buf_c-shift-staff.corr-user-db-num   = g#db-num
    buf_c-shift-staff.corr-user-name     = g#userid
    buf_c-shift-staff.corr-date          = v-today
    .
    create buf_c-sht-hist.
    buffer-copy buf_c-shift-staff to buf_c-sht-hist
    assign
    buf_c-sht-hist.action             = integer( if new( ub.shift-staff )
                                              then {&hn-create}
                                              else {&hn-update})

    buf_c-sht-hist.subject = {&table_shift-staff}
    buf_c-sht-hist.is-news = g#news
    .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_shift-staff}
        , input ( buffer ub.shift-staff:handle )
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
end. /*doe*/

