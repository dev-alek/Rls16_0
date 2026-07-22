block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-obr-k.p $
$Archive: rep/g-obr-k.p $

Оборотная ведомость (детализированная)

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-obr-k.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-obr-k.p $":U .
define variable vss-description as character no-undo init "Оборотная ведомость (детализированная)".
{ cmp/vssrevis.i }

define input  parameter parParentProc  as widget-handle no-undo.
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w (
input parParentProc ,
input                   'rep/e-obort1.w',"Оборотная ведомость (детализированная)",
input                        4,
input                        "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":U,
input                        "*":U,
input                        "",
input                        "{&v-RUBL},{&v-base}",
input                        "all,{&Arc-ot-yes}",
input                        no).