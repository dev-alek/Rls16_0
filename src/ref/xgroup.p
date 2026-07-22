block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 7 нояб. 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 7 нояб. 2020 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "Браузер групп объектов".
{ cmp/vssrevis.i }
session:debug-alert = yes.
define variable mBrow as class ibs.th.ref.xproc.xgroupobj no-undo.

mBrow = new ibs.th.ref.xproc.xgroupobj().
mBrow:ShowModalDialog().
delete object mBrow.