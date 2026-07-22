block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории СКИДОК ТОВАРА НА ОБЪЕКТЕ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 21/01/04
Author: Bakhtadze Natalya
Creation date: 21/01/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-dis-gds-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории СКИДОК ТОВАРА НА ОБЪЕКТЕ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                        , ub.c-dis-gds-rule.obj-type
                        , ub.c-dis-gds-rule.obj-code
                        , ub.c-dis-gds-rule.gds-code
                        , ub.c-dis-gds-rule.pos-type
                        , ub.c-dis-gds-rule.discnt-role
                        , ub.c-dis-gds-rule.nonunique
                        , ub.c-dis-gds-rule.corr-user-db-num
                        , ub.c-dis-gds-rule.chip-num
                        ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ СКИДОК ТОВАРА ПО ОБЪЕКТУ"
  view-as alert-box error .
  undo main-block, return error .

end.