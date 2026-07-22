block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление в таблице ИСТОРИЯ ВАРИАНТОВ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/06/04
Author: Bakhtadze Natalya
Creation date: 04/06/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-varianty-delivery-gds-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление в таблице ИСТОРИЯ ВАРИАНТОВ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                                       , ub.c-varianty-delivery-gds-obj.gds-code
                                       , ub.c-varianty-delivery-gds-obj.obj-type
                                       , ub.c-varianty-delivery-gds-obj.obj-code
                                       , ub.c-varianty-delivery-gds-obj.deliv-type-code
                                       , ub.c-varianty-delivery-gds-obj.deliv-subj-code
                                       , ub.c-varianty-delivery-gds-obj.corr-user-db-num
                                       , ub.c-varianty-delivery-gds-obj.chip-num
                                        ) " }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ВАРИАНТОВ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ"
  view-as alert-box error .
  undo main-block, return error .


end.