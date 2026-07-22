/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет заказа вероятностный метод

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Дата создания: 08/20/01
*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{&ILOG} Output stream stream_order to value ("order_raschet.txt") APPEND .
define variable loc-unit-base    as character no-undo .
define variable l-gar-zapas      as logical no-undo .
define variable l-tog-min-order  as logical no-undo .
define variable l-min-order      as decimal no-undo .
define variable l-min-ost         as logical   no-undo .

define variable  v-sigma          as decimal no-undo .
define variable  loc-rkv as decimal no-undo .
define variable  loc-q as integer no-undo .
define variable  p-serv     as decimal   no-undo .  /* уровень присутствия */
define variable  p-x     as decimal   no-undo . /* гарантийный запас    */
define variable v-norm-obr as decimal   no-undo .

Assign
  l-Ostatok-today =  {2}
  l-negative-rest =  {3}
  l-qnty-day      =  {4}
  l-pay-day       =  {5}
  l-Temp-rash     = if {6} < 0  then 0 else {6}
  l-min-zap       =  {7}
  l-negative-sale =  {9}
  l-goods-way     =  {10}
  p-serv          =  {11}
  l-gar-zapas     =  {12}
  l-tog-min-order =  {13}
  l-min-order     =  {14}
  loc-unit-base   =  {15}
  l-min-ost       =  {16}
  l-TOG-deadline  =  {17}
  l-deadline      =  {18}
  l-corr-coeff    =  {20}
  .

if l-Temp-rash = ? then l-Temp-rash = 0.
 if par-ord-min-ost = yes then do:
    assign l-min-zap =  l-Temp-rash * l-corr-coeff * {7} .
 end.

   /* Расчет среднеквадратичного отклонеия темпа расхода  */
   loc-rkv  = 0 .
   loc-q  = 0 .
   for each temp-gds-qnty :
       loc-rkv = loc-rkv + exp((temp-gds-qnty.rash  - l-Temp-rash * l-corr-coeff) , 2 ) .
       loc-q = loc-q  + temp-gds-qnty.qnty-day.
   end.

   /* если были нули по продажам , а остаток не 0 , надо добрать до all-day */
   define variable ll-i as integer no-undo .
   if  all-day - loc-q > 0 then do:
      do ll-i = 1 to  (all-day - loc-q) :
         loc-rkv = loc-rkv + exp(( 0  - l-Temp-rash * l-corr-coeff) , 2 ) .
      end.
   end.

   assign v-sigma =   sqrt( loc-rkv / ( all-day  - 1)) .
   if v-sigma = ? then v-sigma = 0 .
   if p-serv = ? or p-serv = 0 or p-serv = 1
   then p-serv = .5 .

   if l-Temp-rash = ? then l-Temp-rash = 0.

   run normobr in this-procedure
   ( input   p-serv    ,
     input   l-Temp-rash * l-corr-coeff  ,
     input   v-sigma ,
     output  p-x     )
     .
     assign v-norm-obr = p-x .
  /* гарантийный запас */
  if  p-x  - l-Temp-rash * l-corr-coeff < 0
      then p-x =  0 .
      else p-x = (p-x  - l-Temp-rash * l-corr-coeff ) * ( l-pay-day + l-qnty-day ) .

  assign L-a = l-Ostatok-today - ( l-Temp-rash * l-corr-coeff * l-qnty-day ) .
  if L-a  <= 0 then do:
          if l-negative-sale = true or l-negative-rest = false  then do:
              assign
             l-order = p-x + ( l-temp-rash * l-corr-coeff * l-pay-day )  +  l-min-zap .
             end.
             else do:
               assign
            l-order = p-x + ( l-temp-rash * l-corr-coeff  * l-pay-day )  + absolute(l-a)  +  l-min-zap .
              end.
            end.
   Else do :
      assign l-order = p-x + ( l-Temp-rash * l-corr-coeff * l-pay-day )  - l-a   +  l-min-zap .
   End.
   if  l-order < 0 then l-order = 0 .
   /* остаток > гар.запаса */
 assign
  v-protocol-date = today
  v-protocol-time = time
 .

{&ILOG}  put stream stream_order unformatted
">> Вероятностный способ расчета заказа "  today " " string(time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "дней до доставки  :" l-qnty-day      skip
   "дней в продаже    :" l-pay-day       skip
   "Темп продаж       :" l-Temp-rash     skip
   "Корр.коеффициент  :" l-corr-coeff    skip
   "Уровень пост прис :" p-serv          skip
   "Среднеквадр откл  :" v-sigma         skip
   "F_нормобр         :" v-norm-obr      skip
   "гар.запас         :" p-x             skip
   "Дней без продажи  :" l-null-day      skip
   "MIN остаток       :" l-min-zap       skip
   "отриц.продажа     :" l-negative-sale skip
   "рассчитано заказа :" l-order         skip
   "_________________ "                  skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline      skip
   .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + "Вероятностный способ расчета заказа" + {&delim-par} +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + {&delim-par} +
   "02.Отриц.остатки     :" + string(l-negative-rest) + {&delim-par} +
   "03.дней до доставки  :" + string(l-qnty-day     ) + {&delim-par} +
   "04.дней в продаже    :" + string(l-pay-day      ) + {&delim-par} +
   "05.Темп продаж       :" + string(l-Temp-rash    ) + {&delim-par} +
   "05.1>>Корр.коэфф.    :" + string(l-corr-coeff   ) + {&delim-par} +
   "06.Уровень постоянного присутствия :" + string(p-serv) + {&delim-par} +
   "07.Среднеквадр откл  :" + string(v-sigma        ) + {&delim-par} +
   "08.F_нормобр         :" + string(v-norm-obr     ) + {&delim-par} +
   "09.Гарантийный запас :" + string(p-x            ) + {&delim-par} +
   "10.Дней без продажи  :" + string(l-null-day     ) + {&delim-par} +
   "11.MIN остаток       :" + string(l-min-zap      ) + {&delim-par} +
   "12.отриц.продажа     :" + string(l-negative-sale) + {&delim-par} +
   "13.рассчитано заказа :" + string(l-order        ) + {&delim-par} +
   "14.MIN заказ         :" + string(l-min-order    ) + {&delim-par} +
   "15.товар в пути      :" + string(l-goods-way    ) + {&delim-par} +
   "16. срок хранения    :" + string(l-deadline     ) + {&delim-par} .
   {19} = l-order . /* Промежуточный расчет */
   if l-gar-zapas = true then do:
       if l-Ostatok-today >  p-x then
           assign
           l-order = 0
           {8} = 0
           .
      assign v-stroka-protocol = v-stroka-protocol + "16.1>>После проверки на гарантийный запас:" + string(l-order) + {&delim-par}  .
   end.

/* если есть проверка на мин ост */

   if l-min-ost = true then do:
       if l-Ostatok-today > l-min-zap then
           assign
           l-order = 0
           {8} = 0
           .
      assign v-stroka-protocol = v-stroka-protocol + "16.2>>После проверки на MIN остаток:" + string(l-order) + {&delim-par}  .
   end.

  if (l-order - l-goods-way) < 0 then
     {8} = 0 .
  else
     {8} = l-order - l-goods-way .
assign v-stroka-protocol = v-stroka-protocol + "16.3>>После учета товара в пути:" + string({8}) + {&delim-par}  .

if can-find(first ub.units where ub.units.unit-name = loc-unit-base
    and lookup({&pieces}, ub.units.type) > 0)
    and trunc( {8}, 0 ) <> {8} then do:
        {8} = trunc( {8}, 0 )  + 1 .
        assign v-stroka-protocol = v-stroka-protocol + "16.4>>После округления до штук + 1:" + string({8}) + {&delim-par}  .
 end.
/* проверка на срок хранения */
 if  l-deadline > 0 and l-tog-deadline = true  then do:
     {8} = min({8}, l-Temp-rash * l-deadline ) .
     v-stroka-protocol = v-stroka-protocol + "16.5>>После проверки на срок хронения:" + string({8}) + {&delim-par}  .
 end .

/* если есть проверка на мин заказ */

 if l-tog-min-order then do:
  if ( {8} - l-min-order) < 0 and l-min-order > 0 then
     {8} = 0 .
     assign v-stroka-protocol = v-stroka-protocol + "16.6>>После проверки на MIN заказ:" + string({8}) + {&delim-par}  .
 end .

 if {8} = ? then {8} = 0 .

{&ILOG}  put STREAM  stream_order unformatted "Итого(БЕЗ ОКР) "  {8} skip
 "__________________________________________________"     skip
 .
{&ILOG}  OUTPUT  STREAM  stream_order CLOSE.
assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string({8}) .

/* $Workfile$ e n d */