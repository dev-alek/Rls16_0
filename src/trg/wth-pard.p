block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление wth-par

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.wth-par.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление wth-par".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/wth-parh.i trig ub.wth-par ub.wth-par }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-wth-par for ub.c-wth-par.
define buffer buf_c-wth-hist for ub.c-wth-hist.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  run nws/cmd-del.p
    ( input "wth-par":U
     ,input (buffer ub.wth-par:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
  run wth-parh_write-wth-par-trigger in this-procedure  (
                                      input new(ub.wth-par)
                                      ,input (if g#news then {&hn-source-db} else "":U)
                                      ,input (if g#news then string(g#news-source-db) else "":U)
                                      ,input integer({&hn-delete})
                                    ) no-error .

  if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры wth-parh_write-wth-par-trigger" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    undo main-block,  return error return-value .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_wth-par}
        , input ( buffer ub.wth-par:handle )
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
end.