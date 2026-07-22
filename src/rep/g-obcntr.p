block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-obcntr.p $
$Archive: rep/g-obcntr.p $

Оборотная ведомость по покупателям

Автор: Комаров Иван Сергеевич
Дата создания: 11/26/09
Author: Ivan Komarov
Creation date: 11/26/09

*/
define input  parameter parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-obcntr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-obcntr.p $":U .
define variable vss-description as character no-undo init "Оборотная ведомость по поставшикам ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW}
run rep/d-report.w (
input parParentProc ,
input                   "rep/e-obcntr.w","Оборотная ведомость по покупателям",
input                        2,
input                        "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod},{&g-spis}",
input                        "*":U,
input                        "{&p-cost},{&p-sale}",
input                        "{&v-RUBL},{&v-base}",
input                        "all,{&Excel-yes},{&customer-yes},{&Arc-OT-yes}",
input                        no).