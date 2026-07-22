block-level on error undo, throw.

/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fprngrp1.p $
$Archive: ref/fprngrp1.p $

Сохранение изменений связки принтер кухни-группа товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/26/03
Author: Bakhtadze Natalya
Creation date: 08/26/03

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter p-db-num like ub.fbr-prn.db-num no-undo .
define input parameter p-prn-num like ub.fbr-prn.prn-num no-undo .
define input parameter p-obj-type like ub.fbr-prn-grp.obj-type no-undo .
define input parameter p-obj-code like ub.fbr-prn-grp.obj-code no-undo .
define input parameter p-node-code like ub.fbr-prn-grp.node-code no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fprngrp1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/fprngrp1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений связки принтер кухни-группа товаров".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }

define variable var-entry as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .

define buffer buf_fbr-prn-grp for ub.fbr-prn-grp .
define buffer buf_clients for ub.clients.

if par-mode <> {&add-def} AND par-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр par-mode - " par-mode
  view-as alert-box error .
  return error '':u.
end.
{ gbl/curdbnum.i v-db-num }
if p-db-num <> v-db-num then do:
  assign
  var-entry = "db-num":U
  .
  message
  vss-workfile vss-revision vss-description skip
  "Нельзя вводить группы для принтера в чужой БД"
  view-as alert-box error .
  return error var-entry.
end.


if p-node-code = 0 then do:
  assign
  var-entry = "node-code":U
  .
  message
  "Укажите группу товара"
  view-as alert-box error .
  return error var-entry.
end.

if p-prn-num = 0 then do:
  assign
  var-entry = "prn-num":U
  .
  message
  "Укажите номер принтера"
  view-as alert-box error .
  return error var-entry.
end.

find first buf_clients no-lock where
          buf_clients.obj-type = p-obj-type
     AND  buf_clients.obj-code = p-obj-code no-error .

if p-obj-type = "":u
or p-obj-code = 0
or not available buf_clients
then do:
  assign
  var-entry = "obj-code":U
  .
  message
  "Укажите объект"
  view-as alert-box error .
  return error var-entry.
end.

if buf_clients.db-num <> v-db-num then do:
  assign
  var-entry = "obj-code":U
  .
  message
  "Укажите объект текущей БД"
  view-as alert-box error .
  return error var-entry.

end.

if LOOKUP(p-obj-type, ({&shop} + {&comma-char} + {&stock})) = 0 then do:
  assign
  var-entry = "obj-type":U
  .
  message
  "Объект может быть только " {&shop} "или" {&stock}
  view-as alert-box error .
  return error var-entry.
end.

_main:
do
on error undo _main, return error
:
  CASE par-mode:
    when {&add-def} then do:
      find first buf_fbr-prn-grp no-lock where
                 buf_fbr-prn-grp.node-code = p-node-code
             AND buf_fbr-prn-grp.obj-type = p-obj-type
             AND buf_fbr-prn-grp.obj-code = p-obj-code no-error .
      if available buf_fbr-prn-grp then do:
        assign
        var-entry = "p-node-code"
        .
        message
        "Для группы товаров" p-node-code skip
        "уже определен принтер на объекте" p-obj-type p-obj-code
        view-as alert-box error .
        return error var-entry.
      end.
      create ub.fbr-prn-grp.
    end.
    when {&update} then do:
      find first ub.fbr-prn-grp exclusive-lock where
                recid(ub.fbr-prn-grp) = par-rid no-error .
      if not available ub.fbr-prn-grp
      then do:
        assign
        var-entry = "node-code":U
        .
        message
        "Не определен кухни для группы" p-node-code skip
        "на объекте" p-obj-type p-obj-code
        view-as alert-box error .
        return error var-entry.
      end.
      IF ub.fbr-prn-grp.obj-type <> p-obj-type
      OR ub.fbr-prn-grp.obj-code <> p-obj-code
      OR ub.fbr-prn-grp.node-code <> p-node-code
      OR ub.fbr-prn-grp.db-num <> p-db-num
      OR ub.fbr-prn-grp.prn-num <> p-prn-num

      then do:
        assign
        var-entry = "":U
        .
        message
        "Для записи группы товара на принтере кухни нельзя изменять поля первичного ключа"  skip
        view-as alert-box error .
        return error var-entry.
      end.
    end.
  END CASE.
  assign
  ub.fbr-prn-grp.node-code = p-node-code
  ub.fbr-prn-grp.prn-num = p-prn-num
  ub.fbr-prn-grp.db-num = p-db-num
  ub.fbr-prn-grp.obj-type = p-obj-type
  ub.fbr-prn-grp.obj-code = p-obj-code
  par-rid = recid(ub.fbr-prn-grp)
  .
end. /*doe*/