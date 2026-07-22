block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-bonus.p $
$Archive: rep/g-bonus.p $

Отчет по бонусам

Автор: Шальнев Иван Сергеевич
Дата создания: 23/07/10
Author: Shalnev ivan
Creation date: 23/07/10

*/
define input  parameter parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-bonus.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-bonus.p $":U .
define variable vss-description as character no-undo init "Отчет по бонусам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW}
run rep/d-report.w (
input parParentProc ,
input                   "rep/e-bonus.w","Отчет по бонусам",
input                   2,
input                   "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":U,
input                   "*":U,
input                   "",
input                   "",
input                   "all,{&Arc-supp-yes},{&Arc-ot-yes},{&Excel-yes},{&format-folder}",
input                   no).