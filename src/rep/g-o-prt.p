block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-o-prt.p $
$Archive: rep/g-o-prt.p $

Оборотная ведомость по товарам с учетом признаков

Автор: Чернова Светлана Александровна
Дата создания: 09/09/05
Author: Svetlana Chernova
Creation date: 09/09/05

*/
define input  parameter parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-o-prt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-o-prt.p $":U .
define variable vss-description as character no-undo init "Оборотная ведомость по товарам с учетом признаков".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}

run rep/d-report.w (
input parParentProc ,
input 'rep/e-o-prt.w',
input "Оборотная ведомость по товарам с учетом признаков",
input 2,
input "{&g-choice},{&g-one},{&g-grp-prod}":U,
input "*":U,
input "",
input "{&v-RUBL},{&v-base}",
input "all,{&Excel-yes},{&format-folder},{&Arc-ot-yes}",
input no ).