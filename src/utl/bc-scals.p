block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bc-scals.p $
$Archive: utl/bc-scals.p $

Поиск пересечений весовых кодов без ведущих нулей с другими доп. БК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bc-scals.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/bc-scals.p $":U .
define variable vss-description as character no-undo init "Поиск пересечений весовых кодов без ведущих нулей с другими доп. БК".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ gbl/waitfram.i }

define variable f-name as char no-undo.
define variable glog as logical no-undo .
define buffer b-prod-bc for ub.prod-bc.

glog = no.
message
"Формирование списка товаров, весовые коды которых без ведущих нулей совпадают"
"с дополнительными бар-кодами других товаров. Продолжать ?"
view-as alert-box question buttons OK-Cancel update glog.
if not glog then return.
system-dialog get-file f-name
filters "Списки товаров *.gds" "*.gds"
ask-overwrite
save-as
use-filename
update glog
default-extension "gds".
if not glog then return.

run waitfram-show in this-procedure ("Поиск совпадений усеченных весовых и Доп.БК. ЖДИТЕ...").
output to value (f-name).
for each ub.prod-bc no-lock,
    each ub.bar-code no-lock where
         ub.bar-code.b-code = ub.prod-bc.b-code:
  find ub.units no-lock where
       ub.units.unit-name = ub.bar-code.unit-cli.
  if not LOOKUP ({&weight}, ub.units.type) > 0 then
    /* это не весовой код */
    next.
  /* ищем короткий доп. БК, который равен весовому без ведущих нулей */
  find b-prod-bc no-lock where
       b-prod-bc.b-str = string (int (ub.prod-bc.b-str)) and
       recid (b-prod-bc) <> recid (ub.prod-bc) no-error.
  if not available b-prod-bc then
    /* нет пересечения */
    next.
  accumulate ub.prod-bc.b-str (count).
  find ub.goods no-lock where
       ub.goods.gds-code = ub.bar-code.gds-code.
  export ub.goods.prod-type ub.goods.prod-code ub.goods.artic ?.
  run waitfram-show in this-procedure ("Совпадение. Артикул: " + ub.goods.artic + " Код: " + string (b-prod-bc.b-str)).
end.
output close.
run waitfram-hide in this-procedure .

message
"Всего совпадений:" (accum count ub.prod-bc.b-str) view-as alert-box.