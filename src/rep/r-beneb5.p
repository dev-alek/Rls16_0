block-level on error undo, throw.
/*

$Revision: 36329aee1ee7, 3459, rls $
$Author: VSpiridonov $
$Date: 2023/10/16 15:13:33 $
$Workfile: r-beneb5.p $
$Archive: rep/r-beneb5.p $

Печать отчета о выручке BreakByGoods

Автор: Молотков Сергей Михайлович
Дата создания: 05/09/17
Author: Molotkov Sergey
Creation date: 05/09/17

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter cas-num as integer no-undo .
define input parameter HowBreak        as logical     no-undo.

define variable vss-revision    as character no-undo init "$Revision: 36329aee1ee7, 3459, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:33 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-beneb5.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-beneb5.p $":U .
define variable vss-description as character no-undo init "Печать отчета о выручке".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ rep/rep-bt.i }
{ gbl/waitfram.i }


{ rep/r-benef5.i base }
