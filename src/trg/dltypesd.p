block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление в таблице ТИПЫ ДОСТАВКИ ОТ СУБЪЕКТОВ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/16/04
Author: Bakhtadze Natalya
Creation date: 03/16/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.delivery-type-subject.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление в таблице ТИПЫ ДОСТАВКИ ОТ СУБЪЕКТОВ".
{ cmp/vssrevis.i "substitute('&1|&2', ub.delivery-type-subject.deliv-type-code, ub.delivery-type-subject.deliv-subj-code) " }

main-block :
do transaction
on error undo main-block, return error
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ТИП ДОСТАВКИ ОТ СУБЪЕКТОВ"
  view-as alert-box error .
  undo main-block, return error .


end.


