block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: orcmtrn.p $
$Archive: cus/orcmtrn.p $

Создание накладной по заказу ОРЦ  ( для РТ )

Автор: Чернова Светлана Александровна
Дата создания: 05/29/09
Author: Svetlana Chernova
Creation date: 05/29/09

*/
define input parameter parparentproc as handle    no-undo .
define input parameter p-doc-code    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: orcmtrn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/orcmtrn.p $":U .
define variable vss-description as character no-undo init "Создание накладной по заказу ОРЦ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }


define buffer buf-OR_ord-doc for ub.ord-doc  .
find first buf-OR_ord-doc exclusive-lock where
           buf-OR_ord-doc.doc-code = p-doc-code no-error .

if not available buf-OR_ord-doc then do:
   return error return-value .
end.

define variable v-ok  as logical   no-undo .
define buffer buf_clients for ub.clients.
define buffer obj_clients for ub.clients.
if buf-OR_ord-doc.status_ <> {&ord-req} then  do:
   return error "Создание накладной возможно статусе " + {&ord-req} .
end.

define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .
define variable v-host-code as integer   no-undo .

find first buf_clients no-lock where
           buf_clients.obj-code = buf-OR_ord-doc.cli-code and
           buf_clients.obj-type = buf-OR_ord-doc.cli-type
           no-error .
find first obj_clients no-lock where
           obj_clients.obj-code = buf-OR_ord-doc.obj-code and
           obj_clients.obj-type = buf-OR_ord-doc.obj-type
           no-error .

 v-obj-type  = buf-OR_ord-doc.cli-type .
 v-obj-code  = buf-OR_ord-doc.cli-code .
 v-host-code = buf_clients.host-code .


{ gbl/getcntxt.i get }

if obj_clients.host-code <> buf_clients.host-code then do:
    run cus/crhldr.p
      ( input parparentproc
      , input buf-OR_ord-doc.doc-code
      ) no-error .
      if error-status :error then return error substitute("Ошибка при создании МФ накладной &1" , return-value , error-status :get-message(1) ) .
end.
else do:
    run cus/crrasper.p
      ( input parparentproc
      , input buf-OR_ord-doc.doc-code
      ) no-error .
      if error-status :error then return error substitute("Ошибка при создании внутренней накладной &1" , return-value , error-status :get-message(1) ) .
end.