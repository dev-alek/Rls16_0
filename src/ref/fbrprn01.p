block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbrprn01.p $
$Archive: ref/fbrprn01.p $

Сохранение изменений в карточке принтера кухни

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/22/03
Author: Bakhtadze Natalya
Creation date: 08/22/03

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
define input parameter p-prn-type like ub.fbr-prn.prn-type no-undo .
define input parameter p-prn-name like ub.fbr-prn.prn-name no-undo .
define input parameter p-fbr-obj-type like ub.fbr-prn.fbr-obj-type no-undo .
define input parameter p-fbr-obj-code like ub.fbr-prn.fbr-obj-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrprn01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/fbrprn01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке принтера кухни".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

define variable var-entry as character no-undo .

define buffer buf_fbr-prn for ub.fbr-prn .

if par-mode <> {&add-def} AND par-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр par-mode - " par-mode
  view-as alert-box error .
  return error '':u.
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

if p-prn-type = "":u then do:
  assign
  var-entry = "prn-type":U
  .
  message
  "Укажите тип принтера"
  view-as alert-box error .
  return error var-entry.
end.

if p-prn-name = "":u then do:
  assign
  var-entry = "prn-name":U
  .
  message
  "Укажите название принтера"
  view-as alert-box error .
  return error var-entry.
end.

if LOOKUP(p-fbr-obj-type, ({&shop} + {&comma-char} + {&stock})) = 0 then do:
  assign
  var-entry = "obj-type":U
  .
  message
  "Объект, на котором установлен принтер, может быть только " {&shop} "или" {&stock}
  view-as alert-box error .
  return error var-entry.
end.




find first ub.clients no-lock where
           ub.clients.obj-type = p-fbr-obj-type
      AND ub.clients.obj-code = p-fbr-obj-code no-error .
if not available ub.clients then do:
  assign
  var-entry = "fbr-obj-code"
  .
  message
  "Укажите объект, на которой установлен принтер"
  view-as alert-box error .
  return error var-entry.
end.


_main:
do
on error undo _main, return error
:
  CASE par-mode:
    when {&add-def} then do:
      find first buf_fbr-prn no-lock where
                 buf_fbr-prn.db-num = p-db-num
             AND buf_fbr-prn.prn-num = p-prn-num no-error .
      if available buf_fbr-prn then do:
        assign
        var-entry = "p-prn-num"
        .
        message
        "Уже есть принтер кухни с номером" p-prn-num skip
        "в БД" p-db-num
        view-as alert-box error .
        return error var-entry.
      end.
      create ub.fbr-prn.
    end.
    when {&update} then do:
      find first ub.fbr-prn exclusive-lock where
                recid(ub.fbr-prn) = par-rid no-error .
      if not available ub.fbr-prn
      then do:
        assign
        var-entry = "prn-num":U
        .
        message
        "Нет принтера кухни с номером" p-prn-num skip
        "в БД" p-db-num
        view-as alert-box error .
        return error var-entry.
      end.
      IF ub.fbr-prn.db-num <> p-db-num
      OR ub.fbr-prn.prn-num <> p-prn-num
      then do:
        assign
        var-entry = "prn-num":U
        .
        message
        "Нельзя изменить номер принтера"  skip
        "в БД" p-db-num
        view-as alert-box error .
        return error var-entry.
      end.
    end.
  END CASE.
  assign
  ub.fbr-prn.db-num = p-db-num
  ub.fbr-prn.prn-num = p-prn-num
  ub.fbr-prn.prn-name = p-prn-name
  ub.fbr-prn.prn-type = p-prn-type
  ub.fbr-prn.fbr-obj-type = p-fbr-obj-type
  ub.fbr-prn.fbr-obj-code = p-fbr-obj-code
  par-rid = recid(ub.fbr-prn)
  .
end. /*doe*/