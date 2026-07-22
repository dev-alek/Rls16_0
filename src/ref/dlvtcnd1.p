block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dlvtcnd1.p $
$Archive: ref/dlvtcnd1.p $

Сохранение изменений в карточке вохможности доставки по условиям хранени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/04
Author: Bakhtadze Natalya
Creation date: 03/22/04

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-deliv-type-code like ub.deliv-type-cond-keep.deliv-type-code no-undo .
define input parameter p-cond-keep-code like ub.deliv-type-cond-keep.cond-keep-code no-undo .
define input parameter p-des like ub.deliv-type-cond-keep.des no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dlvtcnd1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dlvtcnd1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке возможности доставки по условиям хранения".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-db-num like ub.db.db-num no-undo .

define buffer buf_delivery-type  for ub.delivery-type.
define buffer buf_deliv-type-cond-keep  for ub.deliv-type-cond-keep.
define buffer buf_condition-keeping  for ub.condition-keeping.

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
  run err-mess (substitute("Нельзя изменять запись ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ в УБД: Номер текущей БД &1"
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
find first buf_condition-keeping no-lock where
            buf_condition-keeping.cond-keep-code = p-cond-keep-code  no-error .
if not available buf_condition-keeping then do:
  run err-mess (substitute("Неправильная ссылка на УСЛОВИЯ ХРАНЕНИЯ, код условий хранения: &1"
                , p-cond-keep-code) ).
  undo, return error "deliv-subj-code":U.
end.

if p-mode = {&add-def} then do:
  find first buf_deliv-type-cond-keep no-lock where
            buf_deliv-type-cond-keep.deliv-type-code = p-deliv-type-code
        AND buf_deliv-type-cond-keep.cond-keep-code = p-cond-keep-code
              no-error .
  if available buf_deliv-type-cond-keep then do:
    run err-mess (substitute("Уже есть запись ВОЗМОЖНОСТИ  ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ, у которой код типа доставки: &1 и код условий хранения: &2"
                  , p-deliv-type-code
                  , p-cond-keep-code) ).
    undo, return error "deliv-type-code":U.
  end.
end.



_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.deliv-type-cond-keep.
    assign
    ub.deliv-type-cond-keep.deliv-type-code = p-deliv-type-code
    ub.deliv-type-cond-keep.cond-keep-code = p-cond-keep-code
    p-doc-rec = recid(ub.deliv-type-cond-keep)
    .
  end.
  else do:
    FIND FIRST ub.deliv-type-cond-keep where
              recid(ub.deliv-type-cond-keep) = p-doc-rec No-ERROR.
    if not available ub.deliv-type-cond-keep then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.deliv-type-cond-keep.deliv-type-code <> p-deliv-type-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код типа доставки" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
    if ub.deliv-type-cond-keep.cond-keep-code <> p-cond-keep-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код условий хранения" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  assign
  ub.deliv-type-cond-keep.des                 = p-des
  ub.deliv-type-cond-keep.sts                 =  (if p-mode = {&add-def}
                             then 0
                             else ub.deliv-type-cond-keep.sts)
  .
  release ub.deliv-type-cond-keep no-error.
  if error-status:error then do:
     run err-mess(substitute("Ошибка при сохранении записи ВОЗМОЖНОСТЬ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ: тип доставки &1, код условий хранения &2: &3: &4"
                             , p-deliv-type-code
                             , p-cond-keep-code
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