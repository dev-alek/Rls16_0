block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись атрибутов типов данных для импорта.

Автор: Белоусов Илья Александрович
Дата создания: 02/21/07
Author: Ilia Belousov
Creation date: 02/21/07

Input:

Output:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.datatype-imp-attr .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись атрибутов типов данных для импорта.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo main-block, return error substitute("&1. endkey")
on stop   undo main-block, return error substitute("&1. stop")
:

end.