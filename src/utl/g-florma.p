block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-florma.p $
$Archive: utl/g-florma.p $

Формирование внешних приходов из внешних расходов

Автор: Чернова Светлана Александровна
Дата создания: 03/30/10
Author: Svetlana Chernova
Creation date: 03/30/10

*/
define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-florma.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/g-florma.p $":U .
define variable vss-description as character no-undo init "Формирование внешних приходов из внешних расходов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i new }

run rep/d-report.w
  ( input parParentProc ,
    input 'utl/r-florma.p',
    input "Генерация ПН по РН",
    input 2 ,
    input "":U,
    input "*",
    input "" ,
    input "",
    input "all,{&customer-yes}",
    yes ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "Ошибка вызова"
      view-as alert-box error
    .