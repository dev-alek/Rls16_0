block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dlvsubj1.p $
$Archive: ref/dlvsubj1.p $

Сохранение изменений в карточке субъекта доставки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/17/04
Author: Bakhtadze Natalya
Creation date: 03/17/04

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-deliv-subj-code like ub.delivery-subject.deliv-subj-code no-undo .
define input parameter p-deliv-subj-name like ub.delivery-subject.deliv-subj-name no-undo .
define input parameter p-reg-code        like ub.delivery-subject.reg-code no-undo .
define input parameter p-des like ub.delivery-subject.des no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dlvsubj1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dlvsubj1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке субъекта доставки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-db-num like ub.db.db-num no-undo .
define buffer buf_regions for ub.regions.

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
  run err-mess (substitute("Нельзя изменять запись СУБЪЕКТ ДОСТАВКИ в УБД: Номер текущей БД &1"
                , v-db-num) ).
  undo, return error "":U.
end.

if p-deliv-subj-name = "":U then do:
  run err-mess in this-procedure ( input "Название СУБЪЕКТА ДОСТАВКИ не может быть пустым").
  return error "deliv-subj-name":U.
end.
if p-reg-code <> 0 then do:
  find first buf_regions no-lock where
            buf_regions.reg-code = p-reg-code no-error.
  if not available buf_regions then do:
    run err-mess in this-procedure (input substitute("Не найден регион с кодом &1", p-reg-code)).
    return error "deliv-subj-name":U.
  end.
end.

_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.delivery-subject.
    assign
    ub.delivery-subject.deliv-subj-code = next-value(delivery, {&db-name_schema})
    p-doc-rec = recid(ub.delivery-subject)
    .
  end.
  else do:
    FIND FIRST ub.delivery-subject where
              recid(ub.delivery-subject) = p-doc-rec No-ERROR.
    if not available ub.delivery-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись СУБЪЕКТ ДОСТАВКИ - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo _main, return error '':u.
    end.
    if ub.delivery-subject.deliv-subj-code <> p-deliv-subj-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код" skip
      view-as alert-box ERROR.
      undo _main, return error '':U.
    end.
  end.
  assign
  ub.delivery-subject.deliv-subj-name     = p-deliv-subj-name
  ub.delivery-subject.des                 = p-des
  ub.delivery-subject.reg-code            = p-reg-code
  ub.delivery-subject.sts                 =  (if p-mode = {&add-def}
                                              then 0
                                              else ub.delivery-subject.sts)
  .
  release ub.delivery-subject no-error.
  if error-status:error then do:
     run err-mess in this-procedure ( input
                                           substitute("Ошибка при сохранении записи СУБЪЕКТ ДОСТАВКИ с кодом &1: &2: &3"
                                                      , p-deliv-subj-code
                                                      , ERROR-STATUS:GET-message(1)
                                                      , return-value
                                                      )
                   ).
    undo _main, return error "":U.
 end.

end. /*doe*/



PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
      message
      p-mess
      view-as alert-box error .
END PROCEDURE.