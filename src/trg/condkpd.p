block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление в таблице УСЛОВИЯ ХРАНЕНИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/10/04
Author: Bakhtadze Natalya
Creation date: 03/10/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.condition-keeping.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление в таблице УСЛОВИЯ ХРАНЕНИЯ".
{ cmp/vssrevis.i "substitute('&1', ub.condition-keeping.cond-keep-code) " }

main-block :
do transaction
on error undo main-block, return error
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись УСЛОВИЯ ХРАНЕНИЯ"
  view-as alert-box error .
  undo main-block, return error .


end.
