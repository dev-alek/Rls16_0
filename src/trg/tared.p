block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи единицы тары

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/09
Author: Bakhtadze Natalya
Creation date: 09/29/09

*/

TRIGGER PROCEDURE FOR DELETE OF ub.tare .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи тары".
{ cmp/vssrevis.i "substitute('&1', ub.tare.tare-code) " }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  message
    vss-workfile vss-revision vss-description skip
    "Физическое удаление тары в системе запрещено" skip
    view-as alert-box error .
  undo main-block, return error.

end.