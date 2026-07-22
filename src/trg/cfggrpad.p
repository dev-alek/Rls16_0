block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории атрибутов групп блюд

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/08/05
Author: Bakhtadze Natalya
Creation date: 08/08/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-fbr-gds-grp-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории атрибутов групп блюд".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                           , ub.c-fbr-gds-grp-attr.obj-type
                           , ub.c-fbr-gds-grp-attr.obj-code
                           , ub.c-fbr-gds-grp-attr.node-code
                           , ub.c-fbr-gds-grp-attr.attr-code
                           , ub.c-fbr-gds-grp-attr.corr-user-db-num
                           , ub.c-fbr-gds-grp-attr.chip-num
                           ) " }

main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ АТРИБУТОВ ГРУПП БЛЮД"
  view-as alert-box error .
  undo main-block, return error .

end.
