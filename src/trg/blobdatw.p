block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись BLOB-DATA

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/07
Author: Bakhtadze Natalya
Creation date: 12/28/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.blob-data.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись BLOB-DATA".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /*отследим возможные типы ub.blob-data.resource-type*/
  if lookup(ub.blob-data.resource-type, {&blob-res-codes}) = 0 then do:
    message
    substitute("Неизвестный resource-type = &1 для blob-data", ub.blob-data.resource-type)
    view-as alert-box error .
    undo main-block, return error .
  end.


  if not g#news then do:
    { gbl/curdburt.i
      ub.blob-data.user-db-num
      ub.blob-data.user-name
      ub.blob-data.sys-date
      ub.blob-data.sys-time
      ub.blob-data.sys-time-int
    }
    run str/callnews.p
      (input {&table_blob-data}
      ,input (buffer ub.blob-data:handle)
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
end.