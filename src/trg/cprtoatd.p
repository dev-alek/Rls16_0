block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории атрибутов партий на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/10/10
Author: Bakhtadze Natalya
Creation date: 02/10/10

*/


TRIGGER PROCEDURE FOR DELETE OF ub.c-parts-obj-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории атрибутов партий на объекте".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9'
                           , ub.c-parts-obj-attr.obj-type + string(ub.c-parts-obj-attr.obj-code)
                           , ub.c-parts-obj-attr.gds-code
                           , ub.c-parts-obj-attr.prt-code
                           , ub.c-parts-obj-attr.in-code
                           , ub.c-parts-obj-attr.out-code
                           , ub.c-parts-obj-attr.part-code
                           , ub.c-parts-obj-attr.attr-code
                           , ub.c-parts-obj-attr.corr-user-db-num
                           , ub.c-parts-obj-attr.chip-num
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
  "Нельзя удалять запись ИСТОРИИ АТРИБУТА ПАРТИИ"
  view-as alert-box error .
  undo main-block, return error .



end. /*doe*/
