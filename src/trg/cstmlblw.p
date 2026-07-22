block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись настроек лейблов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/25/07
Author: Bakhtadze Natalya
Creation date: 04/25/07

*/


TRIGGER PROCEDURE FOR WRITE OF ub.custom-labels.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись настроек лейблов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if g#db-num = 0
  and not g#news then do:
    run str/callnews.p
      (input {&table_custom-labels}
      ,input (buffer ub.custom-labels:handle)
      ) no-error .
    if error-status:error then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры callnews.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo main-block,  return error return-value .
    end.
  end.

    if g#oxml = yes
    then do:
  run str/calloxml.p (
        input {&nwsdochs_action_update}
      , input {&table_custom-labels}
      , input ( buffer ub.custom-labels:handle )
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