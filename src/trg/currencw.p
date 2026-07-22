block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись валюты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.currency OLD old_currency.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись валюты".
{ cmp/vssrevis.i "substitute('&1', ub.currency.curr-code) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-currency for ub.c-currency.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  and g#db-num > 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя изменять запись ВАЛЮТА в УБД" skip
      view-as alert-box error .
    undo main-block, return error "Нельзя изменять запись ВАЛЮТА в УБД".
  end.

  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-currency.
  if new( ub.currency ) then do:
    assign
      buf_c-currency.curr-code = ub.currency.curr-code
    .
  end.
  else do:
    buffer-copy old_currency to buf_c-currency .
  end.
  assign
  buf_c-currency.chip-num           = next-value (s-curr-chip, {&db-name_schema})
  buf_c-currency.corr-time          = v-time
  buf_c-currency.corr-user-db-num   = g#db-num
  buf_c-currency.corr-user-name     = (if g#news = true then "СПН" else g#userid )
  buf_c-currency.corr-date          = v-date
  .


  run str/callnews.p
    (input {&table_currency}
    ,input (buffer ub.currency:handle)
    ) no-error .
  if error-status:error then do:
    undo main-block,  return error return-value .
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_currency}
        , input ( buffer ub.currency:handle )
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