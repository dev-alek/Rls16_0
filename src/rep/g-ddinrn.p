block-level on error undo, throw.
/*

$Revision: 27300b906b02, 3316, rls $
$Author: ARostovtsev $
$Date: 2023/05/19 13:37:07 $
$Workfile: g-ddinrn.p $
$Archive: rep/g-ddinrn.p $

Движение денежных средств

Автор: Комаров Иван Сергеевич
Дата создания: 06/18/10
Author: Ivan Komarov
Creation date: 06/18/10

*/

define variable vss-revision    as character no-undo init "$Revision: 27300b906b02, 3316, rls $":U .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:07 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-ddinrn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-ddinrn.p $":U .
define variable vss-description as character no-undo init "Движение денежных средств".
{ cmp/vssrevis.i }

define input  parameter parParentProc  as widget-handle no-undo.
define NEW SHARED variable is-rosneft as logical no-undo init YES.

{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/dreport.p (
                input parParentProc ,
                input 'ibs.th.rep.eddinam',"Движение денежных средств",
                input 4,
                input "",
                input "*",
                input "",
                input "",
                input "all,{&Excel-yes}",
                input no).