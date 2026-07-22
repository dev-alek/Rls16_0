block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление атрибутов партий на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/10/10
Author: Bakhtadze Natalya
Creation date: 02/10/10

*/


TRIGGER PROCEDURE FOR DELETE OF ub.parts-obj-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление атрибутов партий на объекте".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                           , ub.parts-obj-attr.obj-type
                           , ub.parts-obj-attr.obj-code
                           , ub.parts-obj-attr.gds-code
                           , ub.parts-obj-attr.prt-code
                           , ub.parts-obj-attr.in-code
                           , ub.parts-obj-attr.out-code
                           , ub.parts-obj-attr.part-code
                           , ub.parts-obj-attr.attr-code
                           ) " }
{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


end. /*doe*/

