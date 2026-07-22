block-level on error undo, throw.
/*

$Revision: ce1e41b5e8d1, 1173, rls $
$Author: EShklyar $
$Date: Thu Dec 14 02:20:27 2017 +0300 $
$Workfile: units01.p $
$Archive: ref/units01.p $

Сохранение изменений в карточке единицы измерени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/19/04
Author: Bakhtadze Natalya
Creation date: 01/19/04

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!


*/

define input-output parameter p-rec as recid no-undo.
define input parameter        p-mode             as character no-undo .
define input parameter        p-OKEI           like ub.units.OKEI no-undo .
define input parameter        p-long-name      like ub.units.long-name no-undo .
define input parameter        p-type           like ub.units.type no-undo .
define input parameter        p-unit-name      like ub.units.unit-name  no-undo .

define variable vss-revision    as character no-undo init "$Revision: ce1e41b5e8d1, 1173, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:20:27 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: units01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/units01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке единицы измерени".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/trg-def.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-log         as logical   no-undo .
define buffer buf_units for ub.units.
define variable v-value as character no-undo.
define variable v-ttype as character no-undo.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.

{ gbl/curdbnum.i v-db-num }
run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
if v-value = "no"  then do: 
if v-db-num <> 0
then do:
  run err-mess (substitute("Нельзя изменять запись ЕД.ИЗМ в УБД: Номер текущей БД &1 ", v-db-num ) ).
  undo, return error "":U.
end.
end.
if p-long-name = "":U then do:
  run err-mess ("Укажите полное наименование ед.изм").
  undo, return error "long-name":U.
end.

if p-unit-name = "":U or p-unit-name = ? then do:
  run err-mess ("Укажите аббревиатуру ед.изм").
  undo, return error "unit-name":U.
end.

if
can-find(first buf_units no-lock where
                  buf_units.unit-name = p-unit-name
              AND (p-mode = {&add-def} OR p-rec <> recid(buf_units))
              ) then do:
  run err-mess (substitute("Уже есть такая ЕД.ИЗМ &1", p-unit-name) ).
  return error "unit-name":U.
end.

if LOOKUP(entry(1, p-type),  {&unit-type-tax-list}) = 0 then do:
  run err-mess (substitute("Неверный тип единицы измерения &1: &2", p-unit-name, entry(1, p-type)) ).
  return error "type":U.
end.

if num-entries(p-type) > 1 then do:
  if LOOKUP(entry(2, p-type),  {&pieces} + {&comma-char} + {&divisional} + {&comma-char} + {&twounit} + {&comma-char} + {&altunit}) = 0  then do:
    run err-mess (substitute("Неверный тип2 единицы измерения &1: &2", p-unit-name, entry(2, p-type)) ).
    return error "type":U.
  end.
end.

if p-OKEI <> 0
and
can-find(first buf_units no-lock where
                  buf_units.OKEI = p-OKEI
              AND (p-mode = {&add-def} OR p-rec <> recid(buf_units))
              ) then do:
                if v-value = "no" then do:
    message substitute("Уже есть  ЕД.ИЗМ &1 c таким же кодом ОКЕИ &2", p-unit-name, p-okei) skip "Добавить?" view-as alert-box information buttons YES-NO update v-log.
    if v-log = no then do:
      return error "okei":U.
    end.
    end.
    else do:
      run err-mess (substitute("Уже есть  ЕД.ИЗМ &1 c таким же кодом ОКЕИ &2", p-unit-name, p-okei) ).
    end.  
end.



_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    create ub.units.
    assign
    ub.units.unit-name = p-unit-name
    p-rec = recid(ub.units)
    .
  end.
  else do:
    FIND FIRST ub.units where
              recid(ub.units) = p-rec No-ERROR.
    if not available ub.units then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ед.изм - p-rec" p-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.units.unit-name <> p-unit-name
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся ЕД.ИЗМ. нельзя изменить аббревиатуру" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  assign
  ub.units.unit-name = p-unit-name
  ub.units.long-name  = p-long-name
  ub.units.type       = p-type
  ub.units.OKEI       = p-OKEI
  ub.units.stts    =  (if p-mode = {&add-def}
                             then 0
                             else ub.units.stts)
  .
  release ub.units no-error.
  if error-status:error then do:
     run err-mess(substitute("Ошибка при сохранении записи ЕД.ИЗМ &1: &2: &3", p-unit-name, return-value, ERROR-STATUS:GET-message(1))).
    undo, return error "":U.
 end.

end. /*doe*/



PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  if v-value = "yes" then do:
    p-mess .
  end.
  else do:
      message
      p-mess
      view-as alert-box error .
  end.    

END PROCEDURE.