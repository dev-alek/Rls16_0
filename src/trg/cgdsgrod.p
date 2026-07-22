block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории групп товаров на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 23/08/04
Author: Bakhtadze Natalya
Creation date: 23/08/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-gds-grp-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории групп товаров на объекте".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                        ,  ub.c-gds-grp-obj.node-code
                        ,  ub.c-gds-grp-obj.host-code
                        ,  ub.c-gds-grp-obj.obj-type
                        ,  ub.c-gds-grp-obj.obj-code
                        , ub.c-gds-grp-obj.corr-user-db-num
                        , ub.c-gds-grp-obj.chip-num
                        ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ГРУПП ТОВАРОВ НА ОБЪЕКЕЕ"
  view-as alert-box error .
  undo main-block, return error .

end.

