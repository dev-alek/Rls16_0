block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-ordrcv.p $
$Archive: rep/g-ordrcv.p $

График поставок (вызов)

Автор: Комаров Иван Сергеевич
Дата создания: 10/07/10
Author: Ivan Komarov
Creation date: 10/07/10

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-ordrcv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-ordrcv.p $":U .
define variable vss-description as character no-undo init "График поставок".
{ cmp/vssrevis.i }

define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w (
                input parParentProc ,
                input 'rep/e-ordrcv.w',"График поставок",
                input 1,
                input "",
                input "{&o-currency},{&o-choice}",
                input "",
                input "",
                input "all,{&Excel-yes}",
                input no).