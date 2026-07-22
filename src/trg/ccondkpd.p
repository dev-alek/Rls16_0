block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление в таблице истории УСЛОВИЙ ХРАНЕНИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/15/04
Author: Bakhtadze Natalya
Creation date: 03/15/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-condition-keeping.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление в таблице истории УСЛОВИЙ ХРАНЕНИЯ".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.c-condition-keeping.cond-keep-code
                         , ub.c-condition-keeping.corr-user-db-num
                         , ub.c-condition-keeping.chip-num
                         ) " }

main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ УСЛОВИЙ ХРАНЕНИЯ"
  view-as alert-box error .
  undo main-block, return error .


end.