block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-glprcl.p $
$Archive: rep/g-glprcl.p $

Печать прайс-листа с сортировкой по наименованию

Автор: Демин Алексей Сергеевич
Дата создания: 09/20/05
Author: Alexey Demin
Creation date: 09/20/05

*/

define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w
    (
    input parParentProc ,
    input 'rep/e-glprcl.w',
    "Прайс-лист",
    0,
    "{&g-choice}":U,
    "",
    "" ,
    "",
    "all,{&format-folder}",
    no).