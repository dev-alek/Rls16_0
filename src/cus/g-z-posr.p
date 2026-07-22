block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-z-posr.p $
$Archive: cus/g-z-posr.p $

Сравнительный отчет по ценам товара на объектах

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-z-posr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-z-posr.p $":U .
define variable vss-description as character no-undo init "Сравнительный отчет по ценам товара на объектах".
{ cmp/vssrevis.i }

define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w (  input parParentProc ,
input                       'cus/e-z-posr.w',
input                       'Сравнительный отчет по ценам товара на объектах',
input                        1,
input                        "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}",
input                        "*",
input                        "",
input                        "",
input                        "all",
input                        no).