block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ini-cost.p $
$Archive: utl/ini-cost.p $

Инициализация алгоритма расчета учетных цен в goods

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/13/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-cost.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-cost.p $":U .
define variable vss-description as character no-undo init "Инициализация алгоритма расчета учетных цен в goods ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

define variable ind     as integer  no-undo.

define variable v-today as date     no-undo.
define variable v-time  as integer  no-undo.

def frame b
  ind label "Обработано товаров"
  with side-labels view-as dialog-box title "Инициализация товаров ".

define variable lok as logical no-undo .
assign
  lok = false
.
message
  "Инициирование товаров:" skip
  "Установка метода расчета учетных цен" {&fifo} "для всех товаров." skip (2)
  "Продолжать ?" view-as alert-box question buttons OK-Cancel update lok .
if not lok then do:
  return.
end.

view frame b.

assign
  ind = 0
.
for each ub.goods
:
  if ub.goods.cost-calc <> {&fifo} then do:
    output to ini-cost.fix append .
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    export
      string(v-today, '99/99/9999') string(v-time, "hh:mm")
      ub.goods.artic ub.goods.prod-type ub.goods.prod-code ub.goods.cost-calc
      .
    output close .

    assign
      ind = ind + 1
      ub.goods.cost-calc = {&fifo}
    .
  end.
  disp ind with frame b.
  process events.
end.

message
  "Инициализация закончена успешно." skip
  "Измененные товары записаны в файл ini-cost.fix." skip
  view-as alert-box information .