block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории атрибута пистолета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-nozzle-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории атрибута пистолета".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                        , ub.c-nozzle-attr.obj-type
                        , ub.c-nozzle-attr.obj-code
                        , ub.c-nozzle-attr.nozzle-code
                        , ub.c-nozzle-attr.attr-code
                        , ub.c-nozzle-attr.corr-user-db-num
                        , ub.c-nozzle-attr.chip-num
                        ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ АТРИБУТА ПИСТОЛЕТА"
  view-as alert-box error .
  undo main-block, return error .

end.
