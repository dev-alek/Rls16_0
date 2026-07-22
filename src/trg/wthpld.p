block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление wth-place

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/30/06
Author: Bakhtadze Natalya
Creation date: 03/30/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.wth-place.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление wth-place".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/wth-plh.i trig ub.wth-place ub.wth-place }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-wth-place for ub.c-wth-place.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    run nws/cmd-del.p
      ( input {&table_wth-place}
      ,input (buffer ub.wth-place:handle)
      ,input "":U
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
  if not g#news then do:
    run wth-placeh_write-wth-place-trigger in this-procedure  (
                                        input new(ub.wth-place)
                                        ,input integer({&hn-delete})
                                      ) no-error .

    if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры wth-placeh_write-wth-place-trigger" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      undo main-block,  return error return-value .
    end.
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_wth-place}
        , input ( buffer ub.wth-place:handle )
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