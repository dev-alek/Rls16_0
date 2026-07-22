block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории атрибута ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-pump-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории атрибута ТРК".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                        , ub.c-pump-attr.obj-type
                        , ub.c-pump-attr.obj-code
                        , ub.c-pump-attr.pump-code
                        , ub.c-pump-attr.attr-code
                        , ub.c-pump-attr.corr-user-db-num
                        , ub.c-pump-attr.chip-num
                        ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ АТРИБУТА ТРК"
  view-as alert-box error .
  undo main-block, return error .

end.
