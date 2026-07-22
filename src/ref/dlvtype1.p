block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dlvtype1.p $
$Archive: ref/dlvtype1.p $

Сохранение изменений в карточке типа доставки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/16/04
Author: Bakhtadze Natalya
Creation date: 03/16/04

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-deliv-type-code like ub.delivery-type.deliv-type-code no-undo .
define input parameter p-deliv-type-name like ub.delivery-type.deliv-type-name no-undo .
define input parameter p-des like ub.delivery-type.des no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dlvtype1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dlvtype1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке типа доставки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-db-num like ub.db.db-num no-undo .

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.

{ gbl/curdbnum.i v-db-num }

if v-db-num <> 0 then do:
  run err-mess (substitute("Нельзя изменять запись ТИП ДОСТАВКИ в УБД: Номер текущей БД &1"
                , v-db-num) ).
  undo, return error "":U.
end.

if p-deliv-type-name = "":U then do:
  run err-mess ("Название ТИПА ДОСТАВКИ не может быть пустым").
  return error "deliv-type-name":U.
end.

_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.delivery-type.
    assign
    ub.delivery-type.deliv-type-code = next-value(delivery, {&db-name_schema})
    p-doc-rec = recid(ub.delivery-type)
    .
  end.
  else do:
    FIND FIRST ub.delivery-type where
              recid(ub.delivery-type) = p-doc-rec No-ERROR.
    if not available ub.delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ТИП ДОСТАВКИ - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.delivery-type.deliv-type-code <> p-deliv-type-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  assign
  ub.delivery-type.deliv-type-name     = p-deliv-type-name
  ub.delivery-type.des                 = p-des
  ub.delivery-type.sts                 =  (if p-mode = {&add-def}
                             then 0
                             else ub.delivery-type.sts)
  .
  release ub.delivery-type no-error.
  if error-status:error then do:
     run err-mess(substitute("Ошибка при сохранении записи ТИП ДОСТАВКИ с кодом &1: &2: &3"
                             , p-deliv-type-code
                             , ERROR-STATUS:GET-message(1)
                             , return-value
                             )).
    undo, return error "":U.
 end.

end. /*doe*/



PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
      message
      p-mess
      view-as alert-box error .
END PROCEDURE.