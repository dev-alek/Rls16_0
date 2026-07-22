block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
  if ub.trn-doc.obj-type = 'скл':U then do:
    find ub.store where ub.store.obj-code = ub.trn-doc.obj-code no-lock.
    ub.trn-doc.host-code = ub.store.host-code.
  end.
  else do:
    find ub.shop where ub.shop.obj-code = ub.trn-doc.obj-code no-lock.
    ub.trn-doc.host-code = ub.shop.host-code.
  end.
  if ub.trn-doc.discnt-type = 'касс':U then do:
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
  if ub.price-doc.obj-type = 'скл':U then do:
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
  if ub.gds-obj.obj-type = 'скл':U then do:
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
  if ub.prt-obj.obj-type = 'скл':U then do:
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
