block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись wealth

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.wealth OLD oldwealth.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись wealth".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/wealthh.i trig oldwealth ub.wealth }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-wealth for ub.c-wealth.
define buffer buf_c-wth-hist for ub.c-wth-hist.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  run str/callnews.p
    ( input "wealth"
     ,input (buffer ub.wealth:handle)
    ) .

  run wealthh_write-wealth-trigger in this-procedure  (
                                      input new(ub.wealth)
                                      ,input (if g#news then {&hn-source-db} else "":U)
                                      ,input (if g#news then string(g#news-source-db) else "":U)
                                      ,input integer(if new(wealth) then {&hn-create} else {&hn-update})
                                    ) no-error .
  if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры wealthh_write-wealth-trigger" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    undo main-block,  return error return-value .
  end.
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_wealth}
        , input ( buffer ub.wealth:handle )
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