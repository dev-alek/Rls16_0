block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на изменение таблицы contract-attr

Автор: Чернова Светлана Александровна
Дата создани : 01/11/07
Author: Svetlana Chernova
Creation date: 01/11/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.contract-attr .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на изменение таблицы contract-attr".


{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  run str/callnews.p (input "contract-attr", input (buffer ub.contract-attr:handle) ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip   "Ошибка при передаче в новости договора" skip
      error-status :get-message(1) skip    return-value skip     view-as alert-box error .
    undo, return error.
  end.
  

end. /* main-block */