block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-bent33.p $
$Archive: rep/g-bent33.p $

Отчет по скидкам по реализации в магазине

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-bent33.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-bent33.p $":U .
define variable vss-description as character no-undo init "Отчет по скидкам по реализации в магазине".
{ cmp/vssrevis.i }
define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW}

run rep/d-report.w
    (
    input parParentProc ,
    input 'rep/e-bent33.w',
    "Отчет по скидкам по реализации в магазине",
    2,
    "{&g-all},{&g-choice},{&g-one},{&g-grp-prod}":U,
    "*":U,
    "" ,
    "",
    "shop,{&send-check},{&Excel-yes}",no).