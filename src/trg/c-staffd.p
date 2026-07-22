block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории персонала

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/23/06
Author: Bakhtadze Natalya
Creation date: 05/23/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-staff.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории персонала".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                         ,  ub.c-staff.role
                         ,  ub.c-staff.role-level
                         ,  ub.c-staff.work-place
                         ,  ub.c-staff.staff-code
                         ,  ub.c-staff.date-start
                         ,  ub.c-staff.corr-user-db-num
                         ,  ub.c-staff.chip-num
                         ) " }
{ cmp/trg-def.i }




main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ПЕРСОНАЛА"
  view-as alert-box error .
  undo main-block, return error .

end.

