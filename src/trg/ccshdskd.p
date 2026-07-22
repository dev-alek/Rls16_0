block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/20/03
Author: Bakhtadze Natalya
Creation date: 10/20/03

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-cash-desk.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории КАССЫ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5', ub.c-cash-desk.db-num, ub.c-cash-desk.obj-code, ub.c-cash-desk.pos-type, ub.c-cash-desk.cash-num, ub.c-cash-desk.chip-num) " }
{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ КАССЫ"
  view-as alert-box error .
  undo main-block, return error .

end.