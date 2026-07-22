block-level on error undo, throw.
/*

$Revision: 24d6fc541c24, 417, rls $
$Author: PGridchina $
$Date: Mon Jan 18 18:07:08 2016 +0400 $
$Workfile: reclcwth.p $
$Archive: utl/reclcwth.p $

Пересчет остатков по объекту и месту хранения мат-ценностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.

define variable vss-revision    as character no-undo init "$Revision: 24d6fc541c24, 417, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 18 18:07:08 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: reclcwth.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/reclcwth.p $":U .
define variable vss-description as character no-undo init "Пересчет остатков по объекту и месту хранения мат-ценностей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }


define variable varhost-code like ub.store.host-code no-undo.

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
/*Очищаем остатки по объекту-субобъекту*/
for each ub.wth-obj where ub.wth-obj.obj-type = parobj-type and
                       ub.wth-obj.obj-code = parobj-code exclusive-lock:
    delete ub.wth-obj.
end.
for each ub.wth-pobj where ub.wth-pobj.obj-type = parobj-type and
                        ub.wth-pobj.obj-code = parobj-code exclusive-lock:
    delete ub.wth-pobj.
end.

for each ub.c-wth-obj where ub.c-wth-obj.obj-type = parobj-type and
                       ub.c-wth-obj.obj-code = parobj-code exclusive-lock:
    delete ub.c-wth-obj.
end.
for each ub.c-wth-pobj where ub.c-wth-pobj.obj-type = parobj-type and
                        ub.c-wth-pobj.obj-code = parobj-code exclusive-lock:
    delete ub.c-wth-pobj.
end.


for each ub.wth-doc where ub.wth-doc.host-code = varhost-code and
                       ub.wth-doc.obj-type  = parobj-type  and
                       ub.wth-doc.obj-code  = parobj-code  and
                       ub.wth-doc.status_   = {&fact}
                       USE-INDEX stat-fact:
    run waitfram-show in this-procedure ("Пересчитываем остатки по документу " + ub.wth-doc.doc-code + " .").
    run str/stkotwth.p (input recid(ub.wth-doc), input yes, input yes, input 0) no-error.
    if error-status:error then undo tr, return error.
    
    
end.
end.
run waitfram-hide in this-procedure .