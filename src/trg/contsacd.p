block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы contract-attr

Автор: Кочетков Михаил Юрьевич
Дата создания: 01/11/07
Author: Michael Kochetkov
Creation date: 01/11/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-contract-specif-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление таблицы contract-attr".


{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


end. /* main-block */