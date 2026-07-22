block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-pboul1.p $
$Archive: rep/g-pboul1.p $

Отчет ПБОЮЛ по учету доходов и расходов в момент совершени

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-pboul1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-pboul1.p $":U .
define variable vss-description as character no-undo init "Отчет ПБОЮЛ по учету доходов и расходов в момент совершени".
{ cmp/vssrevis.i }

define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}

run rep/d-report.w (
input parParentProc ,
input                       'rep/r-pboul1.p',
input                       'Учет доходов и расходов в момент получения',
input                        2,
input                        "",
input                        "{&o-currency}",
input                        "",
input                        "",
input                        "{&Arc-stk-yes}",
input                        yes).