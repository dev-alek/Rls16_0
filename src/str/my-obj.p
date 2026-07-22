block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: my-obj.p $
$Archive: str/my-obj.p $

Свой объект

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/
{ cmp/str-glbl.i }
define input parameter  parobj-type like ub.clients.obj-type no-undo.
define input parameter  parobj-code like ub.clients.obj-code no-undo.
define input parameter  pardb-num   like ub.db.db-num        no-undo.
define output parameter parmy-obj   as   logical             no-undo.
define variable vardb-num like ub.clients.db-num no-undo.
define variable varactive as   logical           no-undo.
define buffer bf_store   for ub.store.
define buffer bf_clients for ub.clients.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock.
assign
  vardb-num = bf_clients.db-num.

case parobj-type :
  when {&shop} then do:
    assign varactive = yes.
  end.
  when {&stock} then do:
    find first bf_store where bf_store.obj-code = parobj-code no-lock no-error.
    if not available bf_store then do:
      return error substitute ("Ошибка при поиске склада с номером &1.", parobj-code).
    end.
    assign varactive = bf_store.active.
  end.
  otherwise do:
    return error substitute ("Неверный тип объекта &1.", parobj-type).
  end.
end case.

if vardb-num = pardb-num then do:
  assign
    parmy-obj = varactive
  .
end.
else do:
  assign
    parmy-obj = not varactive
  .
end.