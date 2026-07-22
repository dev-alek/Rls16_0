block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cndkeep1.p $
$Archive: ref/cndkeep1.p $

Сохранение изменений в карточке условий хранени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/15/04
Author: Bakhtadze Natalya
Creation date: 03/15/04

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-cond-keep-code like ub.condition-keeping.cond-keep-code no-undo .
define input parameter p-cond-keep-name like ub.condition-keeping.cond-keep-name no-undo .
define input parameter p-des like ub.condition-keeping.des no-undo .
define input parameter p-h-mode-from like ub.condition-keeping.h-mode-from no-undo .
define input parameter p-h-mode-to like ub.condition-keeping.h-mode-to no-undo .
define input parameter p-t-mode-from like ub.condition-keeping.t-mode-from no-undo .
define input parameter p-t-mode-to like ub.condition-keeping.t-mode-to no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cndkeep1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cndkeep1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке условий хранения".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-db-num like ub.db.db-num no-undo .

define stream LogStream.

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
  run err-mess (substitute("Нельзя изменять запись УСЛОВИЙ ХРАНЕНИЯ в УБД: Номер текущей БД &1"
                , v-db-num) ).
  undo, return error "":U.
end.

if p-cond-keep-name = "":U then do:
  run err-mess ("Название УСЛОВИЙ ХРАНЕНИЯ не может быть пустым").
  return error "cond-keep-name":U.
end.

_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.condition-keeping.
    assign
    ub.condition-keeping.cond-keep-code = next-value(delivery, {&db-name_schema})
    p-doc-rec = recid(ub.condition-keeping)
    .
  end.
  else do:
    FIND FIRST ub.condition-keeping where
              recid(ub.condition-keeping) = p-doc-rec No-ERROR.
    if not available ub.condition-keeping then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись УСЛОВИЙ ХРАНЕНИЯ - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.condition-keeping.cond-keep-code <> p-cond-keep-code
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
  ub.condition-keeping.cond-keep-name     = p-cond-keep-name
  ub.condition-keeping.des                 = p-des
  ub.condition-keeping.sts                 =  (if p-mode = {&add-def}
                             then 0
                             else ub.condition-keeping.sts)
  ub.condition-keeping.t-mode-from         = p-t-mode-from
  ub.condition-keeping.t-mode-to         = p-t-mode-to
  ub.condition-keeping.h-mode-from         = p-h-mode-from
  ub.condition-keeping.h-mode-to         = p-h-mode-to
  .
  release ub.condition-keeping no-error.
  if error-status:error then do:
     run err-mess(substitute("Ошибка при сохранении записи УСЛОВИЙ ХРАНЕНИЯ с кодом &1: &2: &3"
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