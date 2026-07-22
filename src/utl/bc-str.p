block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bc-str.p $
$Archive: utl/bc-str.p $

Поиск пересечений основных и дополнительных кодов

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/

define input parameter parparentproc as widget-handle no-undo .
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/waitfram.i }

define variable list-main as log no-undo.
define variable glog as logical no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define buffer buf-bar-code for ub.bar-code.

list-main = yes.
message
"Поиск пересечений основных и включенных дополнительных бар-кодов других товаров." skip
"Внимание! Работа утилиты кассы не затрагивает!" skip (2)
"YES - помещать в список товары с доп. БК," skip
"NO - с основными," skip
"Cancel - отказ." skip (2)
"Продолжать ?"
view-as alert-box question buttons YES-NO-Cancel update list-main.
if list-main = ? then
  return.
{ gbl/getcntxt.i get }
glog = ?.
if g#db-num = 0 then
  /* не помню, можно ли удалять / выключать доп. БК в УБД - на всякий случай запрещаем */
  message
    "Удалять найденные доп. БК ?" skip (2)
    "YES - удалять" skip
    "NO - выключать" skip
    "Cancel - ничего не менять, просто формировать список"
    view-as alert-box question buttons YES-NO-Cancel update glog.

run waitfram-show in this-procedure ("Поиск совпадений основных и Доп.БК. ЖДИТЕ...").

lns-cnt = 0.
for each ub.bar-code no-lock :
  find first ub.prod-bc where
             ub.prod-bc.b-str = string (ub.bar-code.b-code) and
             ub.prod-bc.bc-on = yes no-error.
  if available ub.prod-bc then do:
    if list-main then do:
      find buf-bar-code no-lock where
           buf-bar-code.b-code = ub.prod-bc.b-code.
      find ub.goods no-lock where
           ub.goods.gds-code = buf-bar-code.gds-code.
    end.
    else
      find ub.goods no-lock where
           ub.goods.gds-code = ub.bar-code.gds-code.
    { cmp/gds-list.i gds-list assign }
    run waitfram-show in this-procedure ("Найдено совпадений: " + string (lns-cnt)).
    if glog = ? then
      next.
    if glog then
      delete ub.prod-bc.
    else
      ub.prod-bc.bc-on = no.
  end.
end.
run waitfram-hide in this-procedure .

message "Всего совпадений:" (lns-cnt) view-as alert-box.
run str/gds-list.w (parparentproc, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).