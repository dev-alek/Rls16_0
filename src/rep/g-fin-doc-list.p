block-level on error undo, throw.
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Список кассовых документов

Автор: Рукавишников Вадим
Дата создания: 27/01/21
Author: Rukavishnikov Vadim
Creation date: 27/01/21

*/

define input  parameter parParentProc  as widget-handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: 6b96c295e5e2, 2873, rls $":U .
define variable vss-author      as character no-undo init "$Author: VRukavishnikov $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-fin-doc-list.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/g-fin-doc-list.p $":U .
define variable vss-description as character no-undo init "Список кассовых документов".
{cmp/vssrevis.i}
{cmp/str-glbl.i}
{cmp/r-page1.i new}

run rep/d-report.w
  ( input parParentProc,
    input "rep/e-fin-doc-list.w",
    input "Список кассовых документов",
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
