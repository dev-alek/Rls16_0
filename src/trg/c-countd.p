block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи истории страны

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/04/05
Author: Bakhtadze Natalya
Creation date: 08/04/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-country.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи истории страны".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                           , ub.c-country.num-code
                           , ub.c-country.corr-user-db-num
                           , ub.c-country.chip-num
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
  "Нельзя удалять запись истории страны"
  view-as alert-box error .
  undo main-block, return error .

end.