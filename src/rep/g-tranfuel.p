block-level on error undo, throw.
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Отчет по длительности транзакций

Автор: Рукавишников Вадим
Дата создания: 24/05/21
Author: Rukavishnikov Vadim
Creation date: 24/05/21

*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$ $":U .
define variable vss-author      as character no-undo init "$ $":U .
define variable vss-date        as character no-undo init "$ $":U .
define variable vss-workfile    as character no-undo init "$ $":U .
define variable vss-archive     as character no-undo init "$ $":U .
define variable vss-description as character no-undo init "Отчет по длительности транзакций".
{cmp/vssrevis.i}
{cmp/str-glbl.i}
{cmp/r-page1.i new}

run rep/d-report.w
  ( input parParentProc,
    input "rep/e-tranfuel.w",
    input "Отчет по длительности транзакций",
    input 4,
    input "",
    input "{&o-firm},{&o-currency},{&o-choice}",
    input "",
    input "",
    input "all,{&Excel-yes}",
    no ) no-error .
    if error-status:error then
    message
      vss-workfile vss-revision vss-description skip
      error-status:get-message(1) skip
      return-value skip
      "Ошибка вызова"
      view-as alert-box error
    .
