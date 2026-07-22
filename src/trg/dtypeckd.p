block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление в таблице ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/04
Author: Bakhtadze Natalya
Creation date: 03/22/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.deliv-type-cond-keep.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление в таблице ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ".
{ cmp/vssrevis.i "substitute('&1|&2', ub.deliv-type-cond-keep.deliv-type-code, ub.deliv-type-cond-keep.cond-keep-code) " }

main-block :
do transaction
on error undo main-block, return error
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ"
  view-as alert-box error .
  undo main-block, return error .


end.



