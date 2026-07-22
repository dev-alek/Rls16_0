block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на создание rep

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/13/06
Author: Dmitry Ukhanov
Creation date: 04/13/06

*/

TRIGGER PROCEDURE FOR CREATE OF ub.rep.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на создание rep".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

ASSIGN
  ub.Rep.rep-num = NEXT-VALUE(Next-Rep-Num, {&db-name_schema})
.