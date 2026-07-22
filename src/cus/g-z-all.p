block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-z-all.p $
$Archive: cus/g-z-all.p $

Состояние запаса по объектам (с учетом признаков)

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

*/
define input  parameter parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-z-all.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/g-z-all.p $":U .
define variable vss-description as character no-undo init "Состояние запаса по объектам (с учетом признаков)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w ( input parParentProc ,
input 'cus/e-z-all.w',
input "Состояние запаса по объектам (с учетом признаков)",
input 0,
input "{&g-all},{&g-choice},{&g-one}":U,
input "{&o-currency},{&o-choice}":U,
input "",
input "{&v-RUBL},{&v-base}",
input "all,{&Arc-stk-yes},{&Excel-yes},{&format-folder},{&send-check}",
input no).