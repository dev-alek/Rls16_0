block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ini-unit.p $
$Archive: utl/ini-unit.p $

Изменение базовой ед. изм. по списку товаров

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-unit.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-unit.p $":U .
define variable vss-description as character no-undo init "Изменение базовой ед. изм. по списку товаров".
{ cmp/trg-def.i }
{ cmp/vssrevis.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/operlist.i }
{ gbl/getcntxt.i def }
define variable new-unit as char no-undo.
define variable old-type as char no-undo. /* тип единиц измерения в позиционном виде */
define variable new-type as char no-undo. /* тип единиц измерения в позиционном виде */
define variable glog as logical no-undo .

def buffer old-units for ub.units.
define buffer buf_bar-code for ub.bar-code.
def frame a
new-unit label "Новая единица" format "x(3)"
with side-labels view-as dialog-box.

define variable v-ind as integer no-undo.
define variable num-rec as integer no-undo.
def frame b
v-ind label "Обработано товаров"
ub.goods.gds-name label "Название"
with side-labels view-as dialog-box.


{ gbl/getcntxt.i get }
run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code) .



/*ВНИМАНИЕ!!!!*/
/*По ВОПРОСАМ РАБОТЫ ДАННОЙ УТИЛИТЫ КО МНЕ НЕ ОБРАЩАТЬСЯ!!!!*/
/*NVB*/

/*по поручению Первакова*/
find first ub.db No-LOCK WHERE
           ub.db.db-num <> 0 no-error .
if available ub.db then do:
  message "Утилита может быть запущена только в системе без УБД.".
  return.
end.

glog = yes.
message "Изменить базовую единицу измерения по всем товарам списка ?  Вы уверены ?"
                view-as alert-box question buttons OK-Cancel update glog.
if not glog then return.

update new-unit with frame a.

find ub.units where ub.units.unit-name = new-unit no-lock no-error.
if not available ub.units then do:
  message "Нет такой единицы !".
  return.
end.
find ub.gds-prt where ub.gds-prt.node-name = {&empty-scale} no-lock.

view frame b.
v-ind = 0.

ON WRITE OF ub.bar-code OVERRIDE DO:
END.
ON WRITE OF ub.goods OVERRIDE DO:
END.

_gds-list:
for each gds-list:
  num-rec = num-rec + 1.
  find ub.goods where
       ub.goods.artic = gds-list.artic
   and ub.goods.prod-type = gds-list.prod-type
   and ub.goods.prod-code = gds-list.prod-code.
  disp ub.goods.gds-name with frame b.
  /* поскольку все равно в других БД проверить не можем, разрешаем везде
  if can-find (first doc-line where doc-line.artic         = ub.goods.artic and
                                                   doc-line.prod-type = ub.goods.prod-type and
                                                   doc-line.prod-code = ub.goods.prod-code no-lock) then next.
  if can-find (first price-list where price-list.artic         = ub.goods.artic and
                                                   price-list.prod-type = ub.goods.prod-type and
                                                   price-list.prod-code = ub.goods.prod-code no-lock) then next.
  */
  run check-unit-chg No-ERROR.
  if error-status:error then NEXT _gds-list.
  for each ub.bar-code where
           ub.bar-code.gds-code = ub.goods.gds-code AND
           ub.bar-code.unit-cli = ub.goods.unit-base:
    find first buf_bar-code No-LOCK WHERE
               buf_bar-code.gds-code = ub.goods.gds-code AND
               buf_bar-code.node-code = ub.bar-code.node-code AND
               buf_bar-code.part-code = ub.bar-code.part-code AND
               buf_bar-code.in-code = ub.bar-code.in-code AND
               buf_bar-code.unit-cli = ub.units.unit-name no-error .
    if available buf_bar-code then do:
      message
      "Не смогу изменить единицу измерения на" ub.units.unit-name skip
      "уже имеются бар-коды с такой единицей измерения" skip
      "товар" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
      "бар-код" buf_bar-code.b-code skip
      view-as alert-box error .
      NEXT _gds-list.

    end.
  end.





  chg-unit:
  do on stop undo chg-unit, return on error undo chg-unit, return:
    if LOOKUP({&serial}, units.type) > 0 or
       LOOKUP({&bottle}, units.type) > 0 then do:
      if ub.goods.prt-root <> ub.gds-prt.upper-code then next.
      ub.goods.unit-cli = units.unit-name.
      ub.goods.cli-base-rate = 1.
    end.
    for each ub.bar-code
      where ub.bar-code.gds-code = ub.goods.gds-code
        and ub.bar-code.unit-cli = ub.goods.unit-base
         on stop undo chg-unit, return on error undo chg-unit, return:
      ub.bar-code.unit-cli = ub.units.unit-name.
      if ub.bar-code.unit-cli = ub.goods.unit-base then do:
        assign
          ub.bar-code.cli-base-rate = 1
        .
      end.
    end.
    ub.goods.unit-base = ub.units.unit-name.
    disp v-ind with frame b.
    v-ind = v-ind + 1.
    process events.
  end.
end.

ON WRITE OF ub.bar-code REVERT.
ON WRITE OF ub.goods REVERT.

if v-ind < num-rec then
message "Из выбранных " num-rec "товаров удалось отредактировать " v-ind.
else
message "Изменение проведено успешно.".

PROCEDURE check-unit-chg:
main-block:
do
on error undo main-block, return error
:
  FIND FIRST old-units No-LOCK WHERE old-units.unit-name = ub.goods.unit-base No-ERROR.
  /*сначала проверим может тип единицы измерения не изменился*/
  if diff-list(old-units.type , ub.units.type, {&comma-char}) = "" then return.
  /* нужно проверять возможные переходы графа типов единиц измерения */
  { trg/unit-chk.i ub.units old-units }

END.


END PROCEDURE.