block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-zapas.p $
$Archive: rep/g-zapas.p $

Состояние запаса

Автор: Чернова Светлана Александровна
Дата создания: 09/09/05
Author: Svetlana Chernova
Creation date: 09/09/05

Created: 20/10/00

*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-zapas.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-zapas.p $":U .
define variable vss-description as character no-undo init "Состояние запаса".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

run rep/d-report.w
  ( input parParentProc ,
    input 'rep/e-zapas.w',
    input "Состояние запаса",
    input 1 ,
    input "{&g-all},{&g-grp},{&g-prod},{&g-choice},{&g-one},{&g-grp-prod}":U,
    input "*",
    input "{&p-cost},{&p-crsa}" ,
    input "{&v-RUBL},{&v-base}",
    input "all,{&Excel-yes},{&Arc-stk-yes},{&format-folder},X-SET_PAY_TYPE=2",
    no ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "Ошибка вызова"
      view-as alert-box error
    .