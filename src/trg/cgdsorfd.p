block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории справочной части gds-obj

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/10/10
Author: Bakhtadze Natalya
Creation date: 02/10/10

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-gds-obj-ref.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории справочной части gds-obj".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                           , ub.c-gds-obj-ref.gds-code
                           , ub.c-gds-obj-ref.gds-code
                           , ub.c-gds-obj-ref.gds-code
                           , ub.c-gds-obj-ref.corr-user-db-num
                           , ub.c-gds-obj-ref.chip-num
                           ) " }
{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ТОВАРА НА ОБЪЕКТЕ"
  view-as alert-box error .
  undo main-block, return error .


end. /*doe*/
