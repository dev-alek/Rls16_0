block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-dcyc.p $
$Archive: cus/ord-dcyc.p $

снять пометку  повторяющихся заказов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Дата создания: 08/21/01
*/
define input parameter p-r as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-dcyc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-dcyc.p $":U .
define variable vss-description as character no-undo init " снять пометку  повторяющихся заказов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_ord-doc for ub.ord-doc .
find first buf_ord-doc where recid(buf_ord-doc) = p-r no-lock no-error .

if not avail buf_ord-doc then return.

if buf_ord-doc.order-type = 1  or
   buf_ord-doc.order-type = 4
then do:
   message "Снимаем отметку о цикличном заказе № " buf_ord-doc.doc-code "? Вы уверены ?" view-as alert-box question
   buttons yes-no update g#log as logical.
   if g#log = true then do:
      find current buf_ord-doc  exclusive-lock  no-error .
           buf_ord-doc.order-type = 0.
      end.
   end.

else do:
   message "Заказе № " buf_ord-doc.doc-code " не повторяющийся" view-as alert-box .
    end.
