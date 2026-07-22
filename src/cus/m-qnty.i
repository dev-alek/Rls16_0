/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет заказа по максимальной продаже

Автор: Чернова Светлана Александровна
Дата создания: 08/21/07
Author: Svetlana Chernova
Creation date: 08/21/07

*/

&scoped-define vssseq {&sequence}
define variable  vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable l-gar-zapas      as logical no-undo .
define variable l-tog-min-order  as logical no-undo .
define variable l-min-order      as decimal no-undo .
define variable loc-unit-base  as character no-undo .
define variable v-sigma    as decimal no-undo .
define variable loc-max    as decimal no-undo .
define variable loc-max-old as decimal no-undo .
define variable loc-q      as integer no-undo .
define variable p-serv     as decimal   no-undo .  /* уровень присутствия */
define variable p-x        as decimal   no-undo . /* гарантийный запас    */
define variable l-min-ost         as logical   no-undo .
define output parameter par-loc-max as decimal no-undo .

{&ILOG} Output stream stream_order to value ("order_raschet.txt") APPEND .

Assign
  l-Ostatok-today =  {2}
  l-negative-rest =  {3}
  l-qnty-day      =  {4}
  l-pay-day       =  {5}
  l-Temp-rash     =  if {6} < 0  then 0 else {6}
  l-min-zap       =  {7}
  l-negative-sale =  {9}
  l-goods-way     =  {10}
  p-serv          =  {11}
  l-gar-zapas     =  {12}
  l-tog-min-order =  {13}
  l-min-order     =  {14}
  loc-unit-base   =  {15}
  l-min-ost = {16}
  l-TOG-deadline  =  {17}
  l-deadline      =  {18}

  .
if l-Temp-rash = ? then l-Temp-rash = 0.

   /* Расчет среднеквадратичного отклонеия темпа расхода  */
   assign
    loc-q  = 0
    loc-max-old = 0
    loc-max = 0
   .
  for each temp-gds-qnty where temp-gds-qnty.rash >= 0 :
      if temp-gds-qnty.rash > loc-max   then   loc-max = temp-gds-qnty.rash  .
      assign loc-max-old = temp-gds-qnty.rash  .
   end.

  for each temp-gds-qnty where temp-gds-qnty.rash >= 0 :
      delete temp-gds-qnty.
   end.

   if loc-max < 0     then loc-max = 0 .
   if loc-max-old < 0 then loc-max-old = 0 .

 if par-ord-min-ost = yes then do:
    assign l-min-zap =  loc-max * {7} .
 end.


  par-loc-max = loc-max .
  L-a = l-Ostatok-today - ( loc-max  * l-qnty-day ) .
  if L-a  <= 0 then do:
          if l-negative-sale = true or l-negative-rest = false   then do:
              assign
                  l-order = ( loc-max  * l-pay-day )  +  l-min-zap .
             end.
             else do:
               assign
                  l-order =  ( loc-max  * l-pay-day )  + absolute(l-a)  +  l-min-zap .
              end.
            end.


   Else do :
        assign l-order = ( loc-max  * l-pay-day )  - l-a   +  l-min-zap .
   End.
   if  l-order < 0 then l-order = 0 .

 assign
  v-protocol-date = today
  v-protocol-time = time
 .
 {&ILOG}  put stream stream_order unformatted
">> Расчет заказа по максимальной продаже "  today " " string(time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "отриц.продажа     :" l-negative-sale skip
   "дней до доставки  :" l-qnty-day      skip
   "дней в продаже    :" l-pay-day       skip
   "MAX продажа       :" loc-max         skip
   "MIN остаток       :" l-min-zap       skip
   "рассчитано заказа :" l-order         skip
   "_________________ "                  skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline skip
   .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + "Расчет до максимальной продажи" + {&delim-par} +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + {&delim-par} +
   "02.Отриц.остатки     :" + string(l-negative-rest) + {&delim-par} +
   "03.отриц.продажа     :" + string(l-negative-sale) + {&delim-par} +
   "04.дней до доставки  :" + string(l-qnty-day     ) + {&delim-par} +
   "05.дней в продаже    :" + string(l-pay-day      ) + {&delim-par} +
   "06.MAX продажа       :" + string(loc-max        ) + {&delim-par} +
   "07.MIN остаток       :" + string(l-min-zap      ) + {&delim-par} +
   "08.рассчитано заказа :" + string(l-order        ) + {&delim-par} +
   "09.MIN заказ         :" + string(l-min-order    ) + {&delim-par} +
   "10.товар в пути      :" + string(l-goods-way    ) + {&delim-par} +
   "11.срок хранения     :" + string(l-deadline     ) + {&delim-par} .

{19} = l-order . /* Промежуточный расчет */

/* если есть проверка на мин ост */
  if l-min-ost = true then do:
     if l-Ostatok-today > l-min-zap then
       assign
        l-order = 0
        {8} = 0
        .
     assign v-stroka-protocol = v-stroka-protocol + "12.1>>После проверки на MIN остаток:" + string(l-order) + {&delim-par}.
  end.

/* товар в пути */
  if (l-order - l-goods-way) < 0 then
     {8} = 0 .
  else
     {8} = l-order - l-goods-way .

  assign v-stroka-protocol = v-stroka-protocol + "12.2>>После учета товара в пути:" + string({8}) + {&delim-par}  .

if can-find(first ub.units where ub.units.unit-name = loc-unit-base
  and lookup({&pieces}, ub.units.type) > 0)
  and trunc( {8}, 0 ) <> {8} then do:
      {8} = trunc( {8}, 0 )  + 1 .
      v-stroka-protocol = v-stroka-protocol + "12.3>>После округления до штук + 1:" + string({8}) + {&delim-par}  .
  end.
/* проверка на срок хранения */
 if  l-deadline > 0 and l-tog-deadline = true  then do:
     {8} = min({8}, l-Temp-rash * l-deadline ) .
     assign v-stroka-protocol = v-stroka-protocol + "12.4>>После проверки на срок хронения:" + string({8}) + {&delim-par}  .
 end .
 /* если есть проверка на мин заказ */
 if l-tog-min-order then do:
    if ({8} - l-min-order) < 0 and l-min-order > 0 then
        {8} = 0 .
    assign v-stroka-protocol = v-stroka-protocol + "12.5>>После проверки на MIN заказ:" + string({8}) + {&delim-par}  .
 end .

if {8} = ? then {8} = 0 .
{&ILOG}  put STREAM  stream_order unformatted "Итого(БЕЗ ОКР) "  {8} skip
 "__________________________________________________"     skip
 .
{&ILOG}  OUTPUT  STREAM  stream_order CLOSE.
assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string({8}) .

/* $Workfile$ e n d */