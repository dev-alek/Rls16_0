block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление в таблице ИСТОРИЯ ВАРИАНТОВ ДОСТАВКИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/04
Author: Bakhtadze Natalya
Creation date: 03/24/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-variant-delivery.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление в таблице ИСТОРИЯ ВАРИАНТОВ ДОСТАВКИ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6', ub.c-variant-delivery.deliv-type-code,
                                              ub.c-variant-delivery.deliv-subj-code,
                                              ub.c-variant-delivery.obj-type,
                                              ub.c-variant-delivery.obj-code,
                                              ub.c-variant-delivery.corr-user-db-num,
                                              ub.c-variant-delivery.chip-num
                                              ) " }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ВАРИАНТОВ ДОСТАВКИ"
  view-as alert-box error .
  undo main-block, return error .


end.


