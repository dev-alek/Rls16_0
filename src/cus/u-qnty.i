/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Довести заказ до максимального остатка

Автор: Чернова Светлана Александровна
Дата создания: 08/21/07
Author: Svetlana Chernova
Creation date: 08/21/07

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{&ILOG} Output stream stream_order to value ("order_raschet.txt") APPEND .
define var l-max-zap        as decimal no-undo .
define variable l-min-ost         as logical   no-undo .
Assign
  l-max-zap       =  {1}
  l-Ostatok-today =  {2}
  l-negative-rest =  {3}
  l-min-zap       =  {4}
  l-negative-sale =  {5}
  l-goods-way     =  {6}
  l-tog-min-order =  {7}
  l-min-order     =  {9}
  loc-unit-base   =  {10}
  l-min-ost       =  {11}
  l-TOG-deadline  =  {12}
  l-deadline      =  {13}
  l-Temp-rash     =  {14}
  l-corr-coeff    =  {16}
  .
if l-Temp-rash = ? then l-Temp-rash = 0.
 if par-ord-min-ost = yes then do:
    assign l-min-zap =  l-Temp-rash * l-corr-coeff * {4} .
 end.


  L-a = l-Ostatok-today  .
  if L-a  <= 0 then do:
      if l-negative-rest = true then do:
          if l-negative-sale then do:
            assign
            l-order =  l-max-zap
            .
          end.
          else do:
            assign
              l-order = absolute(l-a) + l-max-zap
            .
          end.
      end.
      else do:
          assign
            l-order = l-max-zap
            .
      end.
   End.
   Else do :
      if ( l-max-zap - l-Ostatok-today ) >= 0 then  l-order = l-max-zap - l-Ostatok-today .
                                              else  l-order = 0 .
   End.

 assign
  v-protocol-date = today
  v-protocol-time = time
 .
 {&ILOG}  put stream stream_order unformatted
">> Довести заказ до максимального остатка "  today " " string(time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "MIN остаток       :" l-min-zap       skip
   "MAX остаток       :" l-max-zap       skip
   "отриц.продажа     :" l-negative-sale skip
   "рассчитано заказа :" l-order         skip
   "_________________ "                  skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline      skip
   .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + "Довести заказ до максимального остатка" + {&delim-par} +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + {&delim-par} +
   "02.Отриц.остатки     :" + string(l-negative-rest) + {&delim-par} +
   "03.MIN остаток       :" + string(l-min-zap      ) + {&delim-par} +
   "04.MAX остаток       :" + string(l-max-zap      ) + {&delim-par} +
   "05.отриц.продажа     :" + string(l-negative-sale) + {&delim-par} +
   "06.рассчитано заказа :" + string(l-order        ) + {&delim-par} +
   "07.min заказ         :" + string(l-min-order    ) + {&delim-par} +
   "08.товар в пути      :" + string(l-goods-way    ) + {&delim-par} +
   "09.срок хранения     :" + string(l-deadline     ) + {&delim-par} .
{15} = l-order . /* Промежуточный расчет */

/* если есть проверка на мин ост */
   if l-min-ost = true then do:
       if l-Ostatok-today > l-min-zap then
           assign
            l-order = 0
            {8} = 0
           .

      assign v-stroka-protocol = v-stroka-protocol + "10.1>>После проверки на MIN остаток:" + string(l-order) + {&delim-par}  .
   end.

  if (l-order - l-goods-way) < 0 then
     {8} = 0 .
  else
     {8} = l-order - l-goods-way .

  assign v-stroka-protocol = v-stroka-protocol + "10.2>>После учета товара в пути:" + string({8}) + {&delim-par}  .

if can-find(first ub.units where ub.units.unit-name = loc-unit-base
    and lookup({&pieces}, ub.units.type) > 0)
    and trunc( {8}, 0 ) <> {8} then do:
        {8} = trunc( {8}, 0 ) + 1 .
        assign v-stroka-protocol = v-stroka-protocol + "10.3>>После округления до штук + 1:" + string({8}) + {&delim-par}  .
    end.

/* проверка на срок хранения */
  if  l-deadline > 0 and l-tog-deadline = true  then do:
     {8} = min({8}, l-Temp-rash * l-deadline ) .
     v-stroka-protocol = v-stroka-protocol + "10.4>>После проверки на срок хронения:" + string({8}) + {&delim-par}  .
 end .

 /* если есть проверка на мин заказ */
 if l-tog-min-order then do:
  if ({8} - l-min-order) < 0 and l-min-order > 0 then
     {8} = 0 .
     assign v-stroka-protocol = v-stroka-protocol + "10.5>>После проверки на MIN заказ:" + string({8}) + {&delim-par}  .
 end .

if {8} = ? then {8} = 0 .

{&ILOG}  put STREAM  stream_order unformatted "Итого(БЕЗ ОКР) "  {8} skip
 "__________________________________________________"     skip
 .
{&ILOG}  OUTPUT  STREAM  stream_order CLOSE.
assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string({8}) .
/* $Workfile$ e n d */