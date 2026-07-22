block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fprngds1.p $
$Archive: ref/fprngds1.p $

Сохранение изменений связки принтер кухни-товар

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/27/03
Author: Bakhtadze Natalya
Creation date: 08/27/03

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
define input parameter p-obj-type like ub.fbr-prn-gds.obj-type no-undo .
define input parameter p-obj-code like ub.fbr-prn-gds.obj-code no-undo .
define input parameter p-gds-code like ub.fbr-prn-gds.gds-code no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fprngds1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/fprngds1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений связки принтер кухни-товар".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }

define variable var-entry as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .

define buffer buf_fbr-prn-gds for ub.fbr-prn-gds .
define buffer buf_clients for ub.clients.

if par-mode <> {&add-def} AND par-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр par-mode - " par-mode
  view-as alert-box error .
  return error '':u.
end.

if p-gds-code = 0
or not can-find(first ub.goods no-lock where
                      ub.goods.gds-code = p-gds-code)
then do:
  assign
  var-entry = "gds-code":U
  .
  message
  vss-workfile vss-revision vss-description skip
  "Укажите товар"
  view-as alert-box error .
  return error var-entry.
end.

if p-prn-num = 0 then do:
  assign
  var-entry = "prn-num":U
  .
  message
  vss-workfile vss-revision vss-description skip
  "Укажите номер принтера"
  view-as alert-box error .
  return error var-entry.
end.
{ gbl/curdbnum.i v-db-num }
if p-db-num <> v-db-num then do:
  assign
  var-entry = "db-num":U
  .
  message
  vss-workfile vss-revision vss-description skip
  "Нельзя вводить товары для принтера в чужой БД"
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
  vss-workfile vss-revision vss-description skip
  "Укажите объект"
  view-as alert-box error .
  return error var-entry.
end.

if buf_clients.db-num <> v-db-num then do:
  assign
  var-entry = "obj-code":U
  .
  message
  vss-workfile vss-revision vss-description skip
  "Укажите объект текущей БД"
  view-as alert-box error .
  return error var-entry.

end.

if LOOKUP(p-obj-type, ({&shop} + {&comma-char} + {&stock})) = 0 then do:
  assign
  var-entry = "obj-type":U
  .
  message
  vss-workfile vss-revision vss-description skip
  "Объект может быть только " {&shop} "или" {&store}
  view-as alert-box error .
  return error var-entry.
end.

_main:
do
on error undo _main, return error
:
  CASE par-mode:
    when {&add-def} then do:
      find first buf_fbr-prn-gds no-lock where
                 buf_fbr-prn-gds.gds-code = p-gds-code
             AND buf_fbr-prn-gds.obj-type = p-obj-type
             AND buf_fbr-prn-gds.obj-code = p-obj-code no-error .
      if available buf_fbr-prn-gds then do:
        assign
        var-entry = "p-gds-code"
        .
        message
        "Невозможно привязать товар к принтеру кухни" skip
        "Для товара" p-gds-code skip
        "уже определен принтер на объекте" p-obj-type p-obj-code
        view-as alert-box error .
        return error var-entry.
      end.
      create ub.fbr-prn-gds.
    end.
    when {&update} then do:
      find first ub.fbr-prn-gds exclusive-lock where
                recid(ub.fbr-prn-gds) = par-rid no-error .
      if not available ub.fbr-prn-gds
      then do:
        assign
        var-entry = "gds-code":U
        .
        message
        "Не определен принтер кухни для товара" p-gds-code skip
        "на объекте" p-obj-type p-obj-code
        view-as alert-box error .
        return error var-entry.
      end.
      IF ub.fbr-prn-gds.obj-type <> p-obj-type
      OR ub.fbr-prn-gds.obj-code <> p-obj-code
      OR ub.fbr-prn-gds.gds-code <> p-gds-code
      OR ub.fbr-prn-gds.db-num <> p-db-num
      OR ub.fbr-prn-gds.prn-num <> p-prn-num
      then do:
        assign
        var-entry = "":U
        .
        message
        "Для записи товара на принтере кухни нельзя изменять поля первичного ключа"  skip
        view-as alert-box error .
        return error var-entry.
      end.
    end.
  END CASE.
  assign
  ub.fbr-prn-gds.db-num = p-db-num
  ub.fbr-prn-gds.prn-num = p-prn-num
  ub.fbr-prn-gds.obj-type = p-obj-type
  ub.fbr-prn-gds.obj-code = p-obj-code
  ub.fbr-prn-gds.gds-code = p-gds-code
  par-rid = recid(ub.fbr-prn-gds)
  .
end. /*doe*/