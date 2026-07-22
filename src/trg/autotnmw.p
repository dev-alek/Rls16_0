block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись меток цистерны

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Перваков Михаил Сергеевич
Дата создания1: 04/11/06

*/

trigger procedure for write of ub.auto-tank-meas old buffer old-auto-tank-meas .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись меток автоцистерны".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-date as date      no-undo .
define variable v-time as integer   no-undo .

main-block:
do
on error undo main-block, return error
:
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ).

  run str/callnews.p
    (input {&table_auto-tank-meas}
    ,input (buffer ub.auto-tank-meas:handle)
    ).
  if not g#news
  then do:
    if new (ub.auto-tank)
    then do:
      create ub.c-auto-tank .
      assign
        ub.c-auto-tank.auto-num         = ub.auto-tank-meas.auto-num
        ub.c-auto-tank.meas-label       = ub.auto-tank-meas.meas-label
        ub.c-auto-tank.action           = integer({&hn-create})
        ub.c-auto-tank.is-add           = true
        ub.c-auto-tank.is-del           = false
        ub.c-auto-tank.chip-num         = next-value (s-ref-corr-chip, {&db-name_schema})
        ub.c-auto-tank.corr-date        = v-date
        ub.c-auto-tank.corr-time        = v-time
        ub.c-auto-tank.corr-user-db-num = g#db-num
        ub.c-auto-tank.corr-user-name   = g#userid
        ub.c-auto-tank.subject          = {&table_auto-tank-meas}
      .
    end.
    else do:
      create ub.c-auto-tank .
      buffer-copy old-auto-tank-meas to ub.c-auto-tank
      assign
        ub.c-auto-tank.auto-num         = ub.auto-tank-meas.auto-num
        ub.c-auto-tank.meas-label       = ub.auto-tank-meas.meas-label
        ub.c-auto-tank.action           = integer({&hn-update})
        ub.c-auto-tank.is-add           = false
        ub.c-auto-tank.is-del           = false
        ub.c-auto-tank.chip-num         = next-value (s-ref-corr-chip, {&db-name_schema})
        ub.c-auto-tank.corr-date        = v-date
        ub.c-auto-tank.corr-time        = v-time
        ub.c-auto-tank.corr-user-db-num = g#db-num
        ub.c-auto-tank.corr-user-name   = g#userid
        ub.c-auto-tank.subject          = {&table_auto-tank-meas}
      .
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_auto-tank-meas}
        , input ( buffer ub.auto-tank-meas:handle )
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