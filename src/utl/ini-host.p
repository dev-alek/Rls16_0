block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ini-host.p $
$Archive: utl/ini-host.p $

Инициализация фирмы в trn-doc, price-doc, gds-obj и prt-obj

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/

{ cmp/str-glbl.i }

define variable i as int no-undo init 0.
define variable j as int no-undo init 0.
define variable jk as int no-undo init 0.
define variable jl as int no-undo init 0.
define variable jm as int no-undo init 0.
define variable glog as logical no-undo .
def frame a
 i label "Накладных"
 j label "Переоценок"
 jk label "Продаж"
 jl label "Товаров по объекту"
 jm label "Признаков по объекту"
 with title "Фирма в накладных, переоценках, продажах, товарах, признаках по объектам.".
view frame a.

glog = no.
message
"Инициализация фирмы в накладных, переоценках, продажах, а также в товарах и признаках по объектам.   Вы уверены ?"
view-as alert-box question buttons OK-Cancel update glog.
if not glog then return.

on write of ub.trn-doc override do: end.
for each ub.trn-doc :
  i = i + 1.
  disp i jk with frame a view-as dialog-box.
  if ub.trn-doc.obj-type = {&stock} then do:
    find ub.store where ub.store.obj-code = ub.trn-doc.obj-code no-lock.
    ub.trn-doc.host-code = ub.store.host-code.
  end.
  else do:
    find ub.shop where ub.shop.obj-code = ub.trn-doc.obj-code no-lock.
    ub.trn-doc.host-code = ub.shop.host-code.
  end.
  if ub.trn-doc.discnt-type = {&cash-desk} then do:
    jk = jk + 1.
    find ub.inkas where ub.inkas.inkas-code = ub.trn-doc.doc-code no-error.
    if available ub.inkas then ub.inkas.host-code = ub.trn-doc.host-code.
  end.
  process events.
end.
on write of ub.trn-doc revert.

on write of ub.price-doc override do: end.
for each ub.price-doc :
  j = j + 1.
  disp j with frame a view-as dialog-box.
  if ub.price-doc.obj-type = {&stock} then do:
    find ub.store where ub.store.obj-code = ub.price-doc.obj-code no-lock.
    ub.price-doc.host-code = ub.store.host-code.
  end.
  else do:
    find ub.shop where ub.shop.obj-code = ub.price-doc.obj-code no-lock.
    ub.price-doc.host-code = ub.shop.host-code.
  end.
  process events.
end.
on write of ub.price-doc revert.

for each ub.gds-obj :
  jl = jl + 1.
  disp jl with frame a view-as dialog-box.
  if ub.gds-obj.obj-type = {&stock} then do:
    find ub.store where ub.store.obj-code = ub.gds-obj.obj-code no-lock.
    ub.gds-obj.host-code = ub.store.host-code.
  end.
  else do:
    find ub.shop where ub.shop.obj-code = ub.gds-obj.obj-code no-lock.
    ub.gds-obj.host-code = ub.shop.host-code.
  end.
  process events.
end.

for each ub.prt-obj :
  jm = jm + 1.
  disp jm with frame a view-as dialog-box.
  if ub.prt-obj.obj-type = {&stock} then do:
    find ub.store where ub.store.obj-code = ub.prt-obj.obj-code no-lock.
    ub.prt-obj.host-code = ub.store.host-code.
  end.
  else do:
    find ub.shop where ub.shop.obj-code = ub.prt-obj.obj-code no-lock.
    ub.prt-obj.host-code = ub.shop.host-code.
  end.
  process events.
end.

message "Инициализация закончена успешно.".