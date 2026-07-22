block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

триггер на удаление pump

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

TRIGGER PROCEDURE FOR DELETE OF ub.pump.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление ТРК".
{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.pump.obj-type,ub.pump.obj-code,ub.pump.pump-code)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-pump for ub.c-pump.
define buffer buf_c-pmp-hist for ub.c-pmp-hist.

find first ub.pl-pump no-lock where
           ub.pl-pump.pump-code = ub.pump.pump-code and
           ub.pl-pump.obj-type  = ub.pump.obj-type  and
           ub.pl-pump.obj-code  = ub.pump.obj-code  no-error.
if available ub.pl-pump then do:
    message "Данная ТРК привязана к складскому месту (контейнеру)!" skip
            "Удаление невозможно!"
    view-as alert-box error.
    return error.
end.

_main:
do transaction on error undo _main, return error return-value
               on stop  undo _main, return error return-value :
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-pump.
    buffer-copy ub.pump to buf_c-pump.
    assign
    buf_c-pump.corr-date        = v-today
    buf_c-pump.corr-time        = v-time
    buf_c-pump.corr-user-name   = g#userid
    buf_c-pump.corr-user-db-num = g#db-num
    buf_c-pump.chip-num         = next-value( s-pmp-chip, {&db-name_schema} )
    .
    create buf_c-pmp-hist.
    buffer-copy buf_c-pump to buf_c-pmp-hist
    assign
    buf_c-pmp-hist.action =  integer({&hn-delete})
    buf_c-pmp-hist.subject = {&table_pump}
    buf_c-pmp-hist.is-news = g#news
    buf_c-pmp-hist.gds-code = ?
    .

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_pump}
        , input ( buffer ub.pump:handle )
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
end. /*transaction*/