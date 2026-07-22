block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись тары

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/09
Author: Bakhtadze Natalya
Creation date: 09/29/09

*/

TRIGGER PROCEDURE FOR WRITE OF ub.tare old oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись тары".
{ cmp/vssrevis.i "substitute('&1', ub.tare.tare-code) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-tare for ub.c-tare.



main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#db-num > 0
  and not g#news
  then do:
    undo main-block, return error substitute("Запрещено создавать/изменять записи ТАРЫ в УБД").
  end.

  run str/callnews.p
    (input "tare"
    ,input (buffer ub.tare:handle)
    ) no-error .
  if error-status:error then do:
    undo main-block, return error return-value.
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-tare.
    buffer-copy oldb to buf_c-tare
    assign
    buf_c-tare.tare-code          = ub.tare.tare-code
    buf_c-tare.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-tare.corr-time          = v-time
    buf_c-tare.corr-user-db-num   = g#db-num
    buf_c-tare.corr-user-name     = g#userid
    buf_c-tare.corr-date          = v-date
    .
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_tare}
        , input ( buffer ub.tare:handle )
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