block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории АТРИБУТА ТОВВАРА РЕСТОРАН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-fbr-gds-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории АТРИБУТА ТОВАРА РЕСТОРАН".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                        , ub.c-fbr-gds-obj.obj-type
                        , ub.c-fbr-gds-obj.obj-code
                        , ub.c-fbr-gds-obj.gds-code
                        , ub.c-fbr-gds-obj.corr-user-db-num
                        , ub.c-fbr-gds-obj.chip-num
                        ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ АТРИБУТА ТОВАРА РЕСТОРАН"
  view-as alert-box error .
  undo main-block, return error .

end.