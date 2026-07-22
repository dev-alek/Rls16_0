block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: show-ord.p $
$Archive: cus/show-ord.p $

Просмотр заказов толкач

Автор: Чернова Светлана Александровна
Дата создания: 03/02/05
Author: Svetlana Chernova
Creation date: 03/02/05

*/

define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-recid  as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: show-ord.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/show-ord.p $":U .
define variable vss-description as character no-undo init "Просмотр заказов".


{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define buffer buf_clients for ub.clients.
define new shared buffer shar-buf_ord-doc for ub.ord-doc.
define new shared buffer buf-or_ord-doc for ub.ord-doc.
define new shared buffer buf-oo_ord-doc for ub.ord-doc.
define new shared buffer buf-po_ord-doc for ub.ord-doc.
define new shared variable br-handle as handle no-undo.
define new SHARED VARIABLE next-prev as logical   no-undo .


find first  shar-buf_ord-doc no-lock where recid (shar-buf_ord-doc) = p-recid no-error .
if error-status :error then return .
define variable rr as recid no-undo .
rr = recid (shar-buf_ord-doc) .

case shar-buf_ord-doc.doc-type:
when {&p-o}
then do:
  run cus/ord-pou.w ( input  PARPARENTPROC , input-output rr  , input {&lookup} ) no-error .
end.
when {&o-o}
then do:
  run cus/ord-oou.w (
    input parParentProc ,
    input {&lookup} ,
    input-output rr  ,
    input-output br-handle ,
    input-output next-prev )
    .
end.
when {&o-r}
then do:
  run cus/ord-oru.w (
    input parParentProc ,
    input-output rr ,
    input {&lookup} ,
    input-output br-handle ,
    input-output next-prev )
    .
end.

otherwise do:
  /*define variable br-handle as handle no-undo . */
  define variable bf-handle as handle no-undo .
  /*define variable next-prev as logical   no-undo . */
  run cus/lkp-zakz.w
  ( input PARPARENTPROC ,
    input-output  br-handle,
    input-output  bf-handle,
    input-output next-prev
  ) no-error.
end.
end case.
if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message (1) skip
    return-value
    view-as alert-box error .