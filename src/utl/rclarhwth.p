block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rclarhwth.p $
$Archive: utl/rclarhwth.p $

Пересчет архивов МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/02/2011
Author: Gridchina Polina
Creation date: 04/02/2011

*/


define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter par-date as date no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rclarhwth.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rclarhwth.p $":U .
define variable vss-description as character no-undo init "Пересчет архивов МЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ str/wth-arh.i }


define variable varhost-code like ub.store.host-code no-undo.
def var i as int.
def buffer buf_wth-doc for ub.wth-doc.
def var fact-order-from like ub.wth-doc.fact-order.
find first ub.clients where ub.clients.obj-type = parobj-type and
                         ub.clients.obj-code = parobj-code no-lock no-error.
if not available ub.clients then do:
   message "Нет такого объекта " ub.clients.obj-type " " ub.clients.obj-code
   view-as alert-box error.
   return error.
end.
if ub.clients.obj-type = {&stock} then do:
   find first ub.store where ub.store.obj-code = ub.clients.obj-code no-lock.
   assign varhost-code = ub.store.host-code.
end.
else do:
   if ub.clients.obj-type = {&shop} then do:
      find first ub.shop where ub.shop.obj-code = ub.clients.obj-code no-lock.
      assign varhost-code = ub.shop.host-code.
   end.
   else do:
        message "Недопустимый тип объекта пересчета " ub.clients.obj-type
        view-as alert-box error.
        return error.
   end.
end.
run waitfram-show in this-procedure ("").
tr:
do transaction on error undo tr, return error:
run waitfram-show in this-procedure ("Очищаем остатки").
/*Архивы по МЦ являются накопительными оборотами по типам документов. Поэтому первую запись по каждому типу оставляем. остальные пересчитываем от нее*/
/*Определяется fact-order начиная с которого будем пересчитывать*/
for each        buf_wth-doc where
buf_wth-doc.obj-type = parobj-type and
buf_wth-doc.obj-code = parobj-code and
buf_wth-doc.fact-date <   par-date by buf_wth-doc.fact-order desc:
    fact-order-from =   buf_wth-doc.fact-order.
    leave.
end.
if fact-order-from = 0 then
for each        buf_wth-doc where
buf_wth-doc.obj-type = parobj-type and
buf_wth-doc.obj-code = parobj-code and
buf_wth-doc.fact-date >=   par-date by buf_wth-doc.fact-order:
    fact-order-from =   buf_wth-doc.fact-order.
    leave.
end.
/*Удаляем архивы */
for each ub.arh-wth-tot where ub.arh-wth-tot.obj-type = parobj-type and
  ub.arh-wth-tot.obj-code = parobj-code and
  ub.arh-wth-tot.fact-order >  fact-order-from:
   delete ub.arh-wth-tot.
end.
for each ub.arh-wth-cli where ub.arh-wth-cli.obj-type = parobj-type and
  ub.arh-wth-cli.obj-code = parobj-code and
  ub.arh-wth-cli.fact-order >  fact-order-from:
   delete ub.arh-wth-cli.
end.
for each ub.arh-wth-cli-doc where ub.arh-wth-cli-doc.obj-type = parobj-type and
  ub.arh-wth-cli-doc.obj-code = parobj-code and
  ub.arh-wth-cli-doc.fact-order >  fact-order-from:
   delete ub.arh-wth-cli-doc.
end.
for each ub.arh-wth-cli-tot where ub.arh-wth-cli-tot.obj-type = parobj-type and
  ub.arh-wth-cli-tot.obj-code = parobj-code and
  ub.arh-wth-cli-tot.fact-order >  fact-order-from:
   delete ub.arh-wth-cli-tot.
end.
for each ub.arh-wth-w-p where ub.arh-wth-w-p.obj-type = parobj-type and
  ub.arh-wth-w-p.obj-code = parobj-code and
  ub.arh-wth-w-p.fact-order >  fact-order-from:
   delete ub.arh-wth-w-p.
end.
for each ub.arh-wth-tot-attr where ub.arh-wth-tot-attr.obj-type = parobj-type and
  ub.arh-wth-tot-attr.obj-code = parobj-code and
  ub.arh-wth-tot-attr.fact-order >  fact-order-from:
   delete ub.arh-wth-tot-attr.
end.
for each ub.arh-wth-cli-attr where ub.arh-wth-cli-attr.obj-type = parobj-type and
  ub.arh-wth-cli-attr.obj-code = parobj-code and
  ub.arh-wth-cli-attr.fact-order >  fact-order-from:
   delete ub.arh-wth-cli-attr.
end.
for each ub.arh-wth-cli-doc-attr where ub.arh-wth-cli-doc-attr.obj-type = parobj-type and
  ub.arh-wth-cli-doc-attr.obj-code = parobj-code and
  ub.arh-wth-cli-doc-attr.fact-order >  fact-order-from:
   delete ub.arh-wth-cli-doc-attr.
end.
for each ub.arh-wth-cli-tot-attr where ub.arh-wth-cli-tot-attr.obj-type = parobj-type and
  ub.arh-wth-cli-tot-attr.obj-code = parobj-code and
  ub.arh-wth-cli-tot-attr.fact-order >  fact-order-from:
   delete ub.arh-wth-cli-tot-attr.
end.
for each ub.arh-wth-w-p-attr where ub.arh-wth-w-p-attr.obj-type = parobj-type and
  ub.arh-wth-w-p-attr.obj-code = parobj-code and
  ub.arh-wth-w-p-attr.fact-order >  fact-order-from:
   delete ub.arh-wth-w-p-attr.
end.
for each ub.wth-doc where ub.wth-doc.host-code = varhost-code and
                       ub.wth-doc.obj-type  = parobj-type  and
                       ub.wth-doc.obj-code  = parobj-code  and
                       ub.wth-doc.status_   = {&fact}  and
                       ub.wth-doc.fact-order > fact-order-from
                       USE-INDEX stat-fact:
    run waitfram-show in this-procedure ("Пересчитываем архивы по документу " + ub.wth-doc.doc-code + " .").

    /* Расчет архивов */
        run wth-arh-calctt-loc(input ub.wth-doc.doc-code
                          ,input yes) no-error.
        if error-status:error then undo tr, return error return-value + error-status:get-message(1).

    run wth-arhdoc-close(input ub.wth-doc.doc-code) no-error.
        if error-status:error then undo tr, return error return-value + error-status:get-message(1).
end.
end.  /*tr*/