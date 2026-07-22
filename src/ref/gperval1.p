block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gperval1.p $
$Archive: ref/gperval1.p $

Сохранение изменений в карточке банка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/12/04
Author: Bakhtadze Natalya
Creation date: 03/12/04

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-gr-per-val-code like ub.group-period-validity.gr-per-val-code no-undo .
define input parameter p-gr-per-val-name like ub.group-period-validity.gr-per-val-name no-undo .
define input parameter p-des like ub.group-period-validity.des no-undo .
define input parameter p-gr-per-from like ub.group-period-validity.gr-per-from no-undo .
define input parameter p-gr-per-to   like ub.group-period-validity.gr-per-to no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gperval1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gperval1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке группы сроков годности".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }

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
  run err-mess (substitute("Нельзя изменять запись ГРУППЫ СРОКОВ ГОДНОСТИ в УБД: Номер текущей БД &1"
                , v-db-num) ).
  undo, return error "":U.
end.

if
p-gr-per-from > p-gr-per-to then do:
  run err-mess (substitute("Неверно задан диапазон дней количества срока годности: &1 &2"
               , string(p-gr-per-from)
               , string(p-gr-per-to)) ).
  return error "gr-per-from":U.
end.
if p-gr-per-val-name = "":U then do:
  run err-mess ("Название ГРУППЫ СРОКОВ ГОДНОСТИ не может быть пустым").
  return error "gr-per-val-name":U.
end.

_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.group-period-validity.
    assign
    ub.group-period-validity.gr-per-val-code = next-value(delivery, {&db-name_schema})
    p-doc-rec = recid(ub.group-period-validity)
    .
  end.
  else do:
    FIND FIRST ub.group-period-validity where
              recid(ub.group-period-validity) = p-doc-rec No-ERROR.
    if not available ub.group-period-validity then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ГРУППЫ СРОКОВ ГОДНОСТИ - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.group-period-validity.gr-per-val-code <> p-gr-per-val-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код группы" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  assign
  ub.group-period-validity.gr-per-val-name     = p-gr-per-val-name
  ub.group-period-validity.des                 = p-des
  ub.group-period-validity.gr-per-from         = p-gr-per-from
  ub.group-period-validity.gr-per-to           = p-gr-per-to
  ub.group-period-validity.sts                 =  (if p-mode = {&add-def}
                             then 0
                             else ub.group-period-validity.sts)
  .
  release ub.group-period-validity no-error.
  if error-status:error then do:
     run err-mess(substitute("Ошибка при сохранении записи ГРУППЫ СРОКОВ ГОДНОСТИ с кодом &1: &2: &3"
                             , p-gr-per-val-code
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