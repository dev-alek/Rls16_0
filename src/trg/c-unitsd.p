block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи истории ед. изм.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/04/05
Author: Bakhtadze Natalya
Creation date: 08/04/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-units.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи истории ед. изм.".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                           , ub.c-units.unit-name
                           , ub.c-units.corr-user-db-num
                           , ub.c-units.chip-num
                           ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись истории ед. изм."
  view-as alert-box error .
  undo main-block, return error .

end.