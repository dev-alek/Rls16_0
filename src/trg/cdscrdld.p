block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории ДЛИННОГО НОМЕРА ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/14/06
Author: Bakhtadze Natalya
Creation date: 08/14/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-dis-card-long.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории ДЛИННОГО НОМЕРА ДК".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ДЛИННОГО НОМЕРА ДК"
  view-as alert-box error .
  undo main-block, return error .

end.







