block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 14 нояб. 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 14 нояб. 2020 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

define variable mtrg as class ibs.th.ref.xproc.attr_trg no-undo.
define input  parameter iBuffHand as handle no-undo.

mtrg = new ibs.th.ref.xproc.attr_trg().
mtrg:mbuffPar = iBuffHand.
mtrg:brwattr().
delete object mTrg.