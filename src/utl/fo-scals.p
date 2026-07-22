block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fo-scals.p $
$Archive: utl/fo-scals.p $

поиск невесовых доп. БК (EAN13), начинающихся с весовых префиксов, которые,

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

если их разобрать как весовые, дают другие существующие весовые коды

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fo-scals.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fo-scals.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ cmp/library.i }

define variable f-name as char no-undo.
define variable GLOG as logical no-undo .
define buffer   b-prod-bc for ub.prod-bc.


glog = no.
message
"Формирование списка товаров, имеющих доп. БК (EAN13), начинающихся с весовых префиксов и"
"совпадающих с весовыми кодами других товаров. Продолжать ?"
view-as alert-box question buttons OK-Cancel update glog.
if not glog then  return.
system-dialog get-file f-name
  filters "Списки товаров *.gds" "*.gds"
  ask-overwrite
  save-as
  use-filename
  update glog
  default-extension "gds".
if not glog then
  return.
run waitfram-show in this-procedure ("Поиск совпадений доп. БК с вес. префиксом и весовых. ЖДИТЕ...").
output to value (f-name).
{ str/sclspref.i }
for each ub.prod-bc no-lock :
  if not can-do (varscales-pref, substring (prod-bc.b-str, 1, 2)) or
     length (prod-bc.b-str) <> 13 then
    /* начинается не с весового префикса или длина не 13 */
    next.
  /* для распознавания таких кодов bc-rcnz.i использовать нельзя, т.к. он работает правильно,
     найдет полный доп. БК и не будет выделять из него весовой код, в отличие от кассы, которая может */
  /* ищем пересекающийся весовой код */
  find first b-prod-bc no-lock where
             b-prod-bc.b-str = string (int (substr (prod-bc.b-str, 3, 5)), "99999") no-error.
  if not available b-prod-bc then
    next.
  accumulate ub.prod-bc.b-str (count).
  find ub.bar-code no-lock where
       ub.bar-code.b-code = ub.prod-bc.b-code.
  find ub.goods no-lock where
       ub.goods.gds-code = ub.bar-code.gds-code.
  export ub.goods.prod-type ub.goods.prod-code goods.artic ?.
  run waitfram-show in this-procedure ( input substitute("Cовпадение.  Код: &1", b-prod-bc.b-str)).
end.
run waitfram-hide in this-procedure .
output close.
run waitfram-hide in this-procedure .

message
"Всего совпадений:" (accum count ub.prod-bc.b-str) view-as alert-box.