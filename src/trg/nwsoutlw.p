block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись для разметки пакета СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/05/06
Author: Bakhtadze Natalya
Creation date: 11/05/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.nws-outline.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись для разметки пакета СПН".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  return error substitute( "&1. ФИЗИЧЕСКАЯ ЗАПИСЬ В ТАБЛИЦУ nws-outline ЗАПРЕЩЕНА", vss-workfile).
end.

