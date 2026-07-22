block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-noost.p $
$Archive: rep/g-noost.p $

Оборотная ведомость (без остатков)

Автор: Чернова Светлана Александровна
Дата создания: 09/09/05
Author: Svetlana Chernova
Creation date: 09/09/05

*/
define input  parameter parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-noost.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-noost.p $":U .
define variable vss-description as character no-undo init "Оборотная ведомость (без остатков)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new}
run rep/d-report.w (
  input parParentProc ,
  input 'rep/e-noost.w',
  input "Оборотная ведомость (без остатков) ",
  input 4,
  input "{&g-all},{&g-choice},{&g-one}":U,
  input "*":U,
  input "",
  input "{&v-RUBL},{&v-base}",
  input "all,{&Arc-ot-yes},{&Excel-yes},{&format-folder}",
  input no ).
