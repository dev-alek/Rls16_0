block-level on error undo, throw.
/*

$Revision: 1e1fd253f7ac, 1111, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: country1.p $
$Archive: ref/country1.p $

Сохранение изменений в карточке страны

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/05
Author: Bakhtadze Natalya
Creation date: 02/15/05

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!
*/

define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-alpha1          like ub.country.alpha1 no-undo .
define input parameter p-alpha2          like ub.country.alpha1 no-undo .
define input parameter p-num-code        like ub.country.num-code no-undo .
define input parameter p-short-name      like ub.country.short-name no-undo .
define input parameter p-long-name       like ub.country.long-name no-undo .

define variable vss-revision    as character no-undo init "$Revision: 1e1fd253f7ac, 1111, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: country1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/country1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке страны".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-msg as character no-undo.
define shared variable g#esys as logical no-undo.


if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  run err-mess (string (vss-workfile + vss-revision + vss-description + {&new-line} +
    "Неверный параметр p-mode" + p-mode) ).
  return error v-msg + '':u.
end.

{ gbl/curdbnum.i v-db-num }

if v-db-num <> 0 then do:
  run err-mess (substitute("Нельзя изменять запись СТРАНЫ в УБД: Номер текущей БД &1"
                , v-db-num) ).
  undo, return error v-msg + "":U.
end.

if p-short-name = "":U
then do:
  run err-mess ("Короткое название СТРАНЫ не может быть пустым").
  undo, return error v-msg + "short-name":U.
end.
if p-long-name = "":U
then do:
  run err-mess ("Длинное название СТРАНЫ не может быть пустым").
  undo, return error v-msg + "short-name":U.
end.

if p-num-code = 0
or p-num-code = ?
then do:
  run err-mess ("Цифровой код СТРАНЫ не может равняться 0").
  undo, return error v-msg + "num-code":U.
end.

if p-alpha1 = "":U
then do:
  run err-mess ("Буквенный код СТРАНЫ не может быть пустым").
  undo, return error v-msg + "alpha1":U.
end.

if p-alpha2 = "":U
then do:
  run err-mess ("Буквенный код СТРАНЫ не может быть пустым").
  undo, return error v-msg + "alpha2":U.

end.

if p-mode = {&add-def} then do:
  if can-find(first ub.country no-lock where ub.country.alpha1 = p-alpha1) then do:
    run err-mess (substitute("Уже есть страна с буквенным кодом -1, равным &1", p-alpha1)).
    undo, return error v-msg + "alpha2":U.
  end.
  if can-find(first ub.country no-lock where ub.country.alpha1 = p-alpha2) then do:
    run err-mess (substitute("Уже есть страна с буквенным кодом - 2, равным &1", p-alpha2)).
    undo, return error v-msg + "alpha2":U.
 end.
  if can-find(first ub.country no-lock where ub.country.num-code = p-num-code) then do:
    run err-mess (substitute("Уже есть страна с цифровым кодом, равным &1", p-num-code)).
    undo, return error v-msg + "num-code":U.
 end.
end.


_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.country.
    assign
    ub.country.alpha1 = p-alpha1
    ub.country.num-code = p-num-code
    p-doc-rec = recid(ub.country)
    .
  end.
  else do:
    FIND FIRST ub.country where
              recid(ub.country) = p-doc-rec No-ERROR.
    if not available ub.country then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись СТРАНЫ - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error v-msg + '':u.
    end.
    if ub.country.alpha1 <> p-alpha1
    or ub.country.num-code <> p-num-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "цифровой код и/или буквенный код - 1" skip
      view-as alert-box ERROR.
      undo, return error v-msg + '':U.
    end.
  end.
  assign
  ub.country.alpha2     = p-alpha2
  ub.country.short-name = p-short-name
  ub.country.long-name  = p-long-name
  .
  release ub.country no-error.
  if error-status:error then do:
     run err-mess(substitute("Ошибка при сохранении записи СТРАНЫ с буквенным кодом &1: &2: &3"
                             , p-alpha1
                             , ERROR-STATUS:GET-message(1)
                             , return-value
                             )).
    undo, return error v-msg + "":U.
 end.

end. /*doe*/



PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  if not g#esys
    then
      message
      p-mess
      view-as alert-box error .
    else v-msg = p-mess.
END PROCEDURE.
