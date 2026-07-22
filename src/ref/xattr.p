block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 8 нояб. 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 8 нояб. 2020 г.

*/
define input  parameter IGroupObj as character no-undo.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
define variable mtrg as class ibs.th.ref.xproc.xattr_trg no-undo.

mtrg = new ibs.th.ref.xproc.xattr_trg().
mtrg:GroupObjCode = IGroupObj.
mtrg:brwattr().
delete object mTrg.