block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gzobor-s.p $
$Archive: cus/gzobor-s.p $

Оперативная оборотная ведомость - сводна

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

*/
define input  parameter parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gzobor-s.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/gzobor-s.p $":U .
define variable vss-description as character no-undo init "Оперативная оборотная ведомость - сводна ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i NEW}
run rep/d-report.w (
    input parParentProc ,
    input "cus/ezobor-s.w",
    input "Оперативная оборотная ведомость - сводная",
    input 4,
    input "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":U,
    input "*":U,
    input "",
    input "{&v-RUBL},{&v-base}",
    input "all,{&Arc-stk-yes},{&Excel-yes},{&show-sale},{&show-crsa},{&show-cost},{&format-folder}",
    input no).