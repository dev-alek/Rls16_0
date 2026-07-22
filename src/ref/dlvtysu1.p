block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dlvtysu1.p $
$Archive: ref/dlvtysu1.p $

Сохранение изменений в карточке типа доставки от субъекта

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/19/04
Author: Bakhtadze Natalya
Creation date: 03/19/04

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-deliv-type-code like ub.delivery-type-subject.deliv-type-code no-undo .
define input parameter p-deliv-subj-code like ub.delivery-type-subject.deliv-subj-code no-undo .
define input parameter p-des like ub.delivery-type-subject.des no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dlvtysu1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dlvtysu1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке типа доставки от субъекта".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }

define variable v-db-num like ub.db.db-num no-undo .

define buffer buf_delivery-type  for ub.delivery-type.
define buffer buf_delivery-type-subject  for ub.delivery-type-subject.
define buffer buf_delivery-subject  for ub.delivery-subject.

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
  run err-mess (substitute("Нельзя изменять запись ТИП ДОСТАВКИ ОТ СУБЪЕКТА в УБД: Номер текущей БД &1"
                , v-db-num) ).
  undo, return error "":U.
end.

/*проверим реляционность*/
find first buf_delivery-type no-lock where
            buf_delivery-type.deliv-type-code = p-deliv-type-code  no-error .
if not available buf_delivery-type then do:
  run err-mess (substitute("Неправильная ссылка на ТИП ДОСТАВКИ, код типа доставки: &1"
                , p-deliv-type-code) ).
  undo, return error "deliv-type-code":U.
end.
find first buf_delivery-subject no-lock where
            buf_delivery-subject.deliv-subj-code = p-deliv-subj-code  no-error .
if not available buf_delivery-subject then do:
  run err-mess (substitute("Неправильная ссылка на СУБЪЕКТ ДОСТАВКИ, код субъекта доставки: &1"
                , p-deliv-subj-code) ).
  undo, return error "deliv-subj-code":U.
end.

if p-mode = {&add-def} then do:
  find first buf_delivery-type-subject no-lock where
            buf_delivery-type-subject.deliv-type-code = p-deliv-type-code
        AND buf_delivery-type-subject.deliv-subj-code = p-deliv-subj-code
              no-error .
  if available buf_delivery-type-subject then do:
    run err-mess (substitute("Уже есть запись ТИПА ДОСТАВКИ ОТ СУБЪЕКТА, у которой код типа доставки: &1 и код субъекта доставки: &2"
                  , p-deliv-type-code
                  , p-deliv-subj-code) ).
    undo, return error "deliv-type-code":U.
  end.
end.



_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.delivery-type-subject.
    assign
    ub.delivery-type-subject.deliv-type-code = p-deliv-type-code
    ub.delivery-type-subject.deliv-subj-code = p-deliv-subj-code
    p-doc-rec = recid(ub.delivery-type-subject)
    .
  end.
  else do:
    FIND FIRST ub.delivery-type-subject where
              recid(ub.delivery-type-subject) = p-doc-rec No-ERROR.
    if not available ub.delivery-type-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ТИП ДОСТАВКИ ОТ СУБЪЕКТА - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.delivery-type-subject.deliv-type-code <> p-deliv-type-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код типа доставки" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
    if ub.delivery-type-subject.deliv-subj-code <> p-deliv-subj-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код субъекта доставки" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  assign
  ub.delivery-type-subject.des                 = p-des
  ub.delivery-type-subject.sts                 =  (if p-mode = {&add-def}
                             then 0
                             else ub.delivery-type-subject.sts)
  .
  release ub.delivery-type-subject no-error.
  if error-status:error then do:
     run err-mess(substitute("Ошибка при сохранении записи ТИП ДОСТАВКИ ОТ СУБЪЕКТА: тип доставки &1, код субъекта &2 : &3: &4"
                             , p-deliv-type-code
                             , p-deliv-subj-code
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