block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/22/05
Author: Bakhtadze Natalya
Creation date: 04/22/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-scales.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории ВЕСОВ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4', ub.c-scales.db-num
                                         , ub.c-scales.scales-num
                                         , ub.c-scales.corr-user-db-num
                                         , ub.c-scales.chip-num) " }
{ cmp/trg-def.i }


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:



  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ВЕСОВ"
  view-as alert-box error .
  undo main-block, return error .

end.