block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление в таблице истории групп сроков годности

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/10/04
Author: Bakhtadze Natalya
Creation date: 03/10/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-group-period-validity.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление в таблице историии групп сроков годности".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-group-period-validity.gr-per-val-code
                         , c-group-period-validity.corr-user-db-num
                         , ub.c-group-period-validity.chip-num
                         ) " }

main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ГРУПП СРОКОВ ГОДНОСТИ"
  view-as alert-box error .
  undo main-block, return error .


end.