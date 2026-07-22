block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: set-mppr.p $
$Archive: str/set-mppr.p $

Вызов процедуры  mpl-autoprice как р

Автор: Чернова Светлана Александровна
Дата создания: 06/26/06
Author: Svetlana Chernova
Creation date: 06/26/06


*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: set-mppr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/set-mppr.p $":U .
define variable vss-description as character no-undo init "Вызов процедуры  mpl-autoprice".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/mpl-auto.i }
define input  parameter p-only-b-code as logical   no-undo .
define input  parameter p-cli-type        as character no-undo .
define input  parameter p-cli-code        as integer   no-undo .
define input  parameter p-main-b-code     as integer   no-undo .
define input  parameter p-b-code          as integer   no-undo .
define input  parameter p-obj-type        as character no-undo .
define input  parameter p-obj-code        as integer   no-undo .
define input  parameter p-doc-qnty        as decimal   no-undo .
define input  parameter p-tot-rubl        as decimal   no-undo .
define input  parameter p-vid-pay         as character no-undo .
define input  parameter p-cash-pay-type   as character no-undo .
define input  parameter p-fact-order      as decimal   no-undo .
define output parameter p-plt-id          as integer   no-undo .
define output parameter p-plt-db-num      as integer   no-undo .
define output parameter p-pdf-id          as integer   no-undo .
define output parameter p-pdf-db-num      as integer   no-undo .
define output parameter p-sale-price-base as decimal   no-undo .
define output parameter p-sale-price-rubl as decimal   no-undo .
define output parameter p-road-tax-base   as decimal   no-undo .
define output parameter p-road-tax-rubl   as decimal   no-undo .
define output parameter p-excise-base     as decimal   no-undo .
define output parameter p-excise-rubl     as decimal   no-undo .


run mpl-autoprice in this-procedure (
   input  p-only-b-code
  ,input  p-cli-type
  ,input  p-cli-code
  ,input  p-main-b-code
  ,input  p-b-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  p-doc-qnty
  ,input  p-tot-rubl
  ,input  p-vid-pay
  ,input  p-cash-pay-type
  ,input  p-fact-order
  ,output p-plt-id
  ,output p-plt-db-num
  ,output p-pdf-id
  ,output p-pdf-db-num
  ,output p-sale-price-base
  ,output p-sale-price-rubl
  ,output p-road-tax-base
  ,output p-road-tax-rubl
  ,output p-excise-base
  ,output p-excise-rubl
  ) no-error .
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Ошибка mpl-autoprice"
    view-as alert-box error
  .