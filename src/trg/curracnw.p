block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись curr-accnt

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/13/06
Author: Bakhtadze Natalya
Creation date: 04/13/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.curr-accnt OLD old_curr-accnt.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись curr-accnt".
{ cmp/vssrevis.i "substitute('&1|&2', ub.curr-accnt.curr-code, ub.curr-accnt.exch-date) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-curr-accnt for ub.c-curr-accnt.


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
      "Нельзя изменять запись КУРС ВАЛЮТЫ ММВБ в УБД" skip
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.

  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-curr-accnt.
  if new( ub.curr-accnt ) then do:
    assign
      buf_c-curr-accnt.curr-code = ub.curr-accnt.curr-code
      buf_c-curr-accnt.exch-date = ub.curr-accnt.exch-date
      buf_c-curr-accnt.exch-rate = 0
    .
  end.
  else do:
    buffer-copy old_curr-accnt to buf_c-curr-accnt .
  end.

  assign
  buf_c-curr-accnt.chip-num           = next-value (s-curr-chip, {&db-name_schema})
  buf_c-curr-accnt.corr-time          = v-time
  buf_c-curr-accnt.corr-user-db-num   = g#db-num
  buf_c-curr-accnt.corr-user-name     = (if g#news = true then substitute( "СПН в БД &1", g#db-num ) else g#userid )
  buf_c-curr-accnt.corr-date          = v-date
  .

  run str/callnews.p
    ( input {&table_curr-accnt}
     ,input (buffer ub.curr-accnt:handle)
    ) no-error .
  if error-status:error then do:
    undo main-block,  return error return-value .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_curr-accnt}
        , input ( buffer ub.curr-accnt:handle )
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