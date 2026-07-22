block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление code-range

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/97
Author: Dmitry Ukhanov
Creation date: 03/22/97

*/

TRIGGER PROCEDURE FOR DELETE OF ub.code-range.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление code-range".
{ cmp/vssrevis.i }

do
on error undo, return error
:
    message
    vss-workfile vss-revision vss-description skip
    "Удаление записей диапазонов бар-кодов невозможно" skip
    view-as alert-box .
    undo, return error .
end.