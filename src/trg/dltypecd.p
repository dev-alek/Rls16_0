block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление в таблице ИСТОРИЯ ТИПОВ ДОСТАВКИ ОТ СУБЪЕКТА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/17/04
Author: Bakhtadze Natalya
Creation date: 03/17/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-delivery-type-subject.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление в таблице ИСТОРИЯ ТИПОВ ДОСТАВКИ ОТ СУБЪЕКТА".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                          , ub.c-delivery-type-subject.deliv-type-code
                          , ub.c-delivery-type-subject.deliv-subj-code
                          , ub.c-delivery-type-subject.corr-user-db-num
                          , ub.c-delivery-type-subject.chip-num
                          ) " }

main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ТИПА ДОСТАВКИ ОТ СУБЪЕКТОВ"
  view-as alert-box error .
  undo main-block, return error .


end.

