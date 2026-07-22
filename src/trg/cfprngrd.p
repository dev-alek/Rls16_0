block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории групп товаров для принтеров кухни

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/11/05
Author: Bakhtadze Natalya
Creation date: 08/11/05

*/


TRIGGER PROCEDURE FOR DELETE OF ub.c-fbr-prn-grp.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории групп товаров для принтеров кухни".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                           , ub.c-fbr-prn-grp.db-num
                           , ub.c-fbr-prn-grp.prn-num
                           , ub.c-fbr-prn-grp.obj-type
                           , ub.c-fbr-prn-grp.obj-code
                           , ub.c-fbr-prn-grp.node-code
                           , ub.c-fbr-prn-grp.corr-user-db-num
                           , ub.c-fbr-prn-grp.chip-num
                           ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись истории групп товаров на принтерах кухни"
  view-as alert-box error .
  undo main-block, return error .

end.