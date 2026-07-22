/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Расчет заказа

Автор: Чернова Светлана Александровна
Дата создания: 09/21/05
Author: Svetlana Chernova
Creation date: 09/20/01

Дата создания: 08/20/01
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&IF "{1}" = "def" &then
&glob ILOG  if is-log = true then
{ gbl/thbjattr.i }
define variable l-Ostatok-today  as decimal   no-undo .
define variable l-negative-rest  as logical   no-undo .
define variable l-qnty-day       as integer   no-undo .
define variable l-pay-day        as integer   no-undo .
define variable l-Temp-rash      as decimal   no-undo .
define variable l-null-day       as integer   no-undo init 0 .
define variable l-min-zap        as decimal   no-undo .
define variable l-order          as decimal   no-undo .
define variable l-a              as decimal   no-undo .
define variable l-b              as decimal   no-undo .
define variable l-negative-sale  as logical   no-undo .
define variable l-goods-way      as decimal   no-undo .
define variable l-min-order      as decimal   no-undo .
define variable l-tog-min-order  as logical   no-undo .
define variable loc-unit-base    as character no-undo .
define variable l-min-ost        as logical   no-undo .
define variable l-tog-deadline   as logical   no-undo .
define variable l-deadline       as integer   no-undo .
define variable l-type-MR        as character no-undo .
define variable par-ord-min-ost  as logical   no-undo .
define variable v-media-qnty     as decimal   no-undo .
define variable l-corr-coeff     as decimal   no-undo .

define stream stream_order .
define variable is-log             as logical   no-undo .
define variable p-val              as character no-undo .
define variable p-type             as character no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-stroka-protocol  as character no-undo .
define variable v-protocol-date    as date      no-undo .
define variable v-protocol-time    as integer   no-undo .

run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input {&attr-ord-global}
  ,input {&attr-ord-global_ord-log}
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output is-log
  ,output p-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  if error-status :error then is-log = false .
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input {&attr-ord-global}
  ,input {&attr-ord-global_ord-min-ost-day}
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output par-ord-min-ost
  ,output p-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  if error-status :error then par-ord-min-ost = false .


procedure recalc-cli-qnty :
  do
  on error undo, return error return-value
  :

define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-round-m       as character no-undo .
define input  parameter p-round-base    as decimal   no-undo .
define input  parameter p-unit-cli      as character no-undo .
define input  parameter p-cli-base-rate as decimal   no-undo .
define input  parameter p-price-cli     as decimal   no-undo .
define input  parameter p-price-rubl    as decimal   no-undo .
define input  parameter p-price-base    as decimal   no-undo .

define input-output parameter p-cli-qnty as decimal   no-undo .
define input-output parameter p-qnty     as decimal   no-undo .
define input-output parameter p-sum-cli  as decimal   no-undo .
define input-output parameter p-sum-rubl as decimal   no-undo .
define input-output parameter p-sum-base as decimal   no-undo .

define buffer buf_goods for ub.goods  .
define buffer buf_units for ub.units  .
define variable v-cli-qnty as decimal   no-undo .

find first buf_goods no-lock where
           buf_goods.gds-code = p-gds-code no-error .

v-cli-qnty = p-cli-qnty .
if can-find (
first buf_units where
      buf_units.unit-name = p-unit-cli and
      lookup ({&pieces}, buf_units.type) > 0 ) and
  truncate ( p-cli-qnty, 0 ) <> p-cli-qnty then do:
  assign
    v-cli-qnty = trunc( p-cli-qnty, 0 ) .
end.

   case p-round-m :
          when {&ord-round-qnty-card} then do:
           if buf_goods.qnty-cart  <> 0 then do:
                if ( p-qnty  > 0 and p-qnty <  buf_goods.qnty-cart ) then p-qnty = buf_goods.qnty-cart .
                assign
                  p-qnty     = round ( p-qnty / buf_goods.qnty-cart, 0 ) *  buf_goods.qnty-cart
                  .
                  if ( p-qnty > 0 and p-qnty <  buf_goods.qnty-cart ) then p-qnty = buf_goods.qnty-cart .
                assign
                  p-cli-qnty = p-qnty / p-cli-base-rate
                  p-sum-cli  = p-price-cli  * p-cli-qnty
                  p-sum-rubl = p-price-rubl * p-qnty
                  p-sum-base = p-price-base * p-qnty
                .
             end.
             else do:
                assign
                  p-qnty     = v-cli-qnty   * p-cli-base-rate
                  p-sum-cli  = p-price-cli  * v-cli-qnty
                  p-sum-rubl = p-price-rubl * p-qnty
                  p-sum-base = p-price-base * p-qnty
                .
             end.
          end.

          when {&ord-round-integer} then do:
              if can-find(first buf_units where
                      buf_units.unit-name = p-unit-cli and
                      lookup ({&pieces}, buf_units.type) > 0 ) and
                      trunc ( p-cli-qnty, 0 ) <> p-cli-qnty then do:
                      assign
                        p-cli-qnty = trunc( p-cli-qnty, 0 ) + 1
                        p-qnty     = p-cli-qnty   * p-cli-base-rate
                        p-sum-cli  = p-price-cli  * p-cli-qnty
                        p-sum-rubl = p-price-rubl * p-qnty
                        p-sum-base = p-price-base * p-qnty
                      .
              end.
              else do:
                      assign
                        p-cli-qnty = round( p-cli-qnty, 0 )
                        p-qnty     = p-cli-qnty   * p-cli-base-rate
                        p-sum-cli  = p-price-cli  * p-cli-qnty
                        p-sum-rubl = p-price-rubl * p-qnty
                        p-sum-base = p-price-base * p-qnty
                      .
              end.
          end.

          when {&ord-round-select} then do:
            if p-round-base <> 0 then do:
              assign
                p-cli-qnty = round ( p-cli-qnty / p-round-base , 0 ) * p-round-base
              .
            end.
            assign
                p-qnty     = p-cli-qnty   * p-cli-base-rate
                p-sum-cli  = p-price-cli  * p-cli-qnty
                p-sum-rubl = p-price-rubl * p-qnty
                p-sum-base = p-price-base * p-qnty
              .
          end.

          when {&ord-round-off} or when ""  then do:
            assign
                p-cli-qnty = v-cli-qnty
                p-qnty     = p-cli-qnty   * p-cli-base-rate
                p-sum-cli  = p-price-cli  * p-cli-qnty
                p-sum-rubl = p-price-rubl * p-qnty
                p-sum-base = p-price-base * p-qnty
              .
          end.
   end case.

{&ILOG}  Output stream stream_order to value ("order_raschet.txt") APPEND .
{&ILOG}  put stream stream_order unformatted
        " После округления кол-во в баз.ед. изм. : " p-qnty  skip

        " Метод округления :  " p-round-m
          ( if p-round-m = {&ord-round-select}
              then  string(p-round-base)
              else  "" )
          ( if p-round-m = {&ord-round-qnty-card}
              then  string(buf_goods.qnty-cart)
              else  "" ) skip

        "__________________________________________________"     skip  .

{&ILOG}  OUTPUT  STREAM  stream_order CLOSE.

v-stroka-protocol = v-stroka-protocol + {&delim-par} +
                  "18.Метод округления : " +  p-round-m +
                    ( if p-round-m = {&ord-round-select}
                        then  string(p-round-base)
                        else  " " )  +
                    ( if p-round-m = {&ord-round-qnty-card}
                        then  string(buf_goods.qnty-cart)
                        else  "" ) + {&delim-par} +
                  "19.После округления кол-во в баз.ед. изм. : " + string( p-qnty)
                    .
  end.

end procedure. /* recalc-cli-qnty */

procedure create-protocol :
define input  parameter p-ord-doc  as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-date     as date     no-undo .
define input  parameter p-time     as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-str      as character no-undo .

define buffer buf_ord-line-attr for ub.ord-line-attr  .
  do
  on error undo, return error return-value
  :

  if p-gds-code = ? or p-gds-code = 0 then return.
  if p-ord-doc = ? or p-ord-doc = ""   then return.
  if p-obj-type = ?  then return.
  if p-obj-code = ?  then return.
  if p-date = ?  then return.

    find first buf_ord-line-attr exclusive-lock where
              buf_ord-line-attr.doc-code = p-ord-doc  and
              buf_ord-line-attr.gds-code = p-gds-code and
              buf_ord-line-attr.attr-code =  "protocol"           + {&delim-par} +
                                              p-obj-type          + {&delim-par} +
                                              string(p-obj-code)  + {&delim-par} +
                                              string(p-date, "99-99-9999" )  + {&delim-par} +
                                              string(p-time,"hh:mm:ss"  )
                                              no-error .
    if not available buf_ord-line-attr then do:
       create buf_ord-line-attr no-error .
    end.
    if available buf_ord-line-attr then do:
    assign
      buf_ord-line-attr.doc-code  = p-ord-doc
      buf_ord-line-attr.gds-code  = p-gds-code
      buf_ord-line-attr.attr-code =  "protocol"           + {&delim-par} +
                                      p-obj-type          + {&delim-par} +
                                      string(p-obj-code)  + {&delim-par} +
                                      string(p-date, "99-99-9999" )  + {&delim-par} +
                                      string(p-time, "hh:mm:ss"  )
      buf_ord-line-attr.attr-value  = p-str
      no-error
    .
    end.
  end.

end procedure. /* create-obj-temp */

procedure create-obj-temp :
define input  parameter p-ord-doc as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-qnty as decimal   no-undo .
define buffer buf_ord-line-attr for ub.ord-line-attr  .
  do
  on error undo, return error return-value
  :


  if p-gds-code = ? or p-gds-code = 0 then return.
  if p-ord-doc = ? or p-ord-doc = "" then return.
  if p-obj-type = ?  then return.
  if p-obj-code = ?  then return.
    find first buf_ord-line-attr exclusive-lock where
              buf_ord-line-attr.doc-code = p-ord-doc  and
              buf_ord-line-attr.gds-code = p-gds-code and
              buf_ord-line-attr.attr-code =  "objqnty"   + {&delim-par} +
                                              p-obj-type + {&delim-par} +
                                              string(p-obj-code)  no-error .
    if not available buf_ord-line-attr then do:
       create buf_ord-line-attr no-error .
    end.
    assign
      buf_ord-line-attr.doc-code  = p-ord-doc
      buf_ord-line-attr.gds-code  = p-gds-code
      buf_ord-line-attr.attr-code = "objqnty"  + {&delim-par} +
                                    p-obj-type + {&delim-par} +
                                    string(p-obj-code)
      buf_ord-line-attr.attr-value = string( p-qnty )
      no-error
    .

  end.

end procedure. /* create-obj-temp */

procedure create-min-stock-gds-way :
define input  parameter p-ord-doc   as character no-undo .
define input  parameter p-gds-code  as integer   no-undo .
define input  parameter p-min-stock as decimal   no-undo .
define input  parameter p-gds-way   as decimal   no-undo .

define buffer buf_ord-line-attr for ub.ord-line-attr  .
  do
  on error undo, return error return-value
  :

  if p-gds-code = ? or p-gds-code = 0 then return.
  if p-ord-doc  = ? or p-ord-doc = "" then return.


    find first buf_ord-line-attr exclusive-lock where
              buf_ord-line-attr.doc-code = p-ord-doc  and
              buf_ord-line-attr.gds-code = p-gds-code and
              buf_ord-line-attr.attr-code = {&ordlineattr-min-stock}
                                             no-error .
    if not available buf_ord-line-attr then do:
       create buf_ord-line-attr no-error .
    end.
    if available buf_ord-line-attr then do:
    assign
      buf_ord-line-attr.doc-code  = p-ord-doc
      buf_ord-line-attr.gds-code  = p-gds-code
      buf_ord-line-attr.attr-code = {&ordlineattr-min-stock}
      buf_ord-line-attr.attr-value = string (p-min-stock)
      no-error
    .
    end.
    
    find first buf_ord-line-attr exclusive-lock where
              buf_ord-line-attr.doc-code = p-ord-doc  and
              buf_ord-line-attr.gds-code = p-gds-code and
              buf_ord-line-attr.attr-code = {&ordlineattr-gds-way}
                                             no-error .
    if not available buf_ord-line-attr then do:
       create buf_ord-line-attr no-error .
    end.
    if available buf_ord-line-attr then do:
    assign
      buf_ord-line-attr.doc-code  = p-ord-doc
      buf_ord-line-attr.gds-code  = p-gds-code
      buf_ord-line-attr.attr-code = {&ordlineattr-gds-way}
      buf_ord-line-attr.attr-value = string (p-gds-way)
      no-error
    .
    end.
    
  end.

end procedure. /* create-min-stock-gds-way */

&ELSE

{&ILOG} Output stream stream_order to value ("order_raschet.txt") APPEND .
Assign
  l-Ostatok-today =  {2}
  l-negative-rest =  {3}
  l-qnty-day      =  {4}
  l-pay-day       =  {5}
  l-Temp-rash     = if {6} < 0  then 0 else {6}
  l-min-zap       =  {7}
  l-negative-sale =  {9}
  l-goods-way     =  {10}
  l-tog-min-order =  {11}
  l-min-order     =  {12}
  loc-unit-base   =  {13}
  l-min-ost       =  {14}
  l-TOG-deadline  =  {15}
  l-deadline      =  {16}
  l-type-MR       =  {17}
  l-corr-coeff    =  {19}
  .
if l-Temp-rash = ? then l-Temp-rash = 0.
  if par-ord-min-ost = yes then do:
    assign l-min-zap = l-Temp-rash * l-corr-coeff * {7} .
  end.

  assign L-a = l-Ostatok-today - (l-Temp-rash * l-corr-coeff * l-qnty-day) .
  if L-a  <= 0 then do:
    if l-negative-rest = true then do:
      if l-negative-sale then do:
        Assign
          l-a = 0
          l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff)
        .
      end.
      else do:
        assign l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff).
      end.
    end.
    else do:
      Assign
        l-a = 0
        l-order = ABSOLUTE(l-a) + l-min-zap + (l-pay-day * l-Temp-rash * l-corr-coeff)
      .
    end.
  end.


  Else do :
    assign l-b = l-Ostatok-today - (l-Temp-rash * l-corr-coeff * (l-qnty-day + l-pay-day ) ) .
          if l-b >= l-min-zap then l-order = 0.
                              else DO:
                              If l-b < 0 Then l-order = absolute(l-b) + l-min-zap.
                                         Else l-order = l-min-zap - absolute(l-b).
                              End.
   End.

 assign
  v-protocol-date = today
  v-protocol-time = time
 .
{&ILOG}  put stream stream_order unformatted
">> Базовый способ расчета заказа "  v-protocol-date " " string(v-protocol-time,"hh:mm:ss") skip
   tmp#zakaz.gds-code " " tmp#zakaz.gds-name skip
   "Остаток на сегодня:" l-Ostatok-today skip
   "Отриц.остатки     :" l-negative-rest skip
   "дней до доставки  :" l-qnty-day      skip
   "дней в продаже    :" l-pay-day       skip
   "Темп продаж       :" l-Temp-rash     skip
   "Коррект.коэфф.    :" l-corr-coeff    skip
   "Дней без продажи  :" l-null-day      skip
   "MIN остаток       :" l-min-zap       skip
   "отриц.продажа     :" l-negative-sale skip
   "рассчитано заказа :" l-order         skip
   "_________________  "                 skip
   "min заказ         :" l-min-order     skip
   "товар в пути      :" l-goods-way     skip
   "срок хранения     :" l-deadline      skip
   .

l-type-MR = entry(2, entry(1,l-type-MR,";"),":") no-error .
if l-type-MR = ? then l-type-MR = "Базовый способ расчета заказа" .
v-stroka-protocol = "" .
v-stroka-protocol =
   "00.Метод расчета заказа:" + l-type-MR /* "Базовый способ расчета заказа" */ + {&delim-par} +
   "01.Остаток на сегодня:" + string(l-Ostatok-today) + {&delim-par} +
   "02.Отриц.остатки     :" + string(l-negative-rest) + {&delim-par} +
   "03.дней до доставки  :" + string(l-qnty-day     ) + {&delim-par} +
   "04.дней в продаже    :" + string(l-pay-day      ) + {&delim-par} +
   "05.Темп продаж       :" + string(l-Temp-rash    ) + {&delim-par} +
   "05.1>>Коррект.коэфф. :" + string(l-corr-coeff   ) + {&delim-par} +
   "06.Дней без продажи  :" + string(l-null-day     ) + {&delim-par} +
   "07.MIN остаток       :" + string(l-min-zap      ) + {&delim-par} +
   "08.отриц.продажа     :" + string(l-negative-sale) + {&delim-par} +
   "09.рассчитано заказа :" + string(l-order        ) + {&delim-par} +
   "10.MIN заказ         :" + string(l-min-order    ) + {&delim-par} +
   "11.товар в пути      :" + string(l-goods-way    ) + {&delim-par} +
   "12.срок хранения     :" + string(l-deadline     ) + {&delim-par} .
  {18} = l-order . /* Промежуточный расчет */

  if (l-order - l-goods-way) < 0 then
     {8} = 0 .
  else
     {8} = l-order - l-goods-way .
 assign v-stroka-protocol = v-stroka-protocol + "13.1>>После учета товара в пути:" + string({8}) + {&delim-par}  .

/* если есть проверка на мин ост */
  if l-min-ost = true then do:
      if l-Ostatok-today > l-min-zap then
          {8} = 0 .
      assign v-stroka-protocol = v-stroka-protocol + "13.2>>После проверки на MIN остаток:" + string({8}) + {&delim-par}  .
  end.

if can-find(first ub.units where ub.units.unit-name = loc-unit-base
    and lookup({&pieces}, ub.units.type) > 0)
    and trunc( {8}, 0 ) <> {8} then do:
        {8} = trunc( {8}, 0 ) + 1 .
        assign v-stroka-protocol = v-stroka-protocol + "13.3>>После округления до штук + 1:" + string({8}) + {&delim-par}  .
    end.

/* проверка на срок хранения */
  if  l-deadline > 0 and l-tog-deadline = true   then do:
     {8} = min({8}, l-Temp-rash * l-deadline ) .
     v-stroka-protocol = v-stroka-protocol + "13.4>>После проверки на срок хронения:" + string({8}) + {&delim-par}  .
 end .

 /* если есть проверка на мин заказ */
 if l-tog-min-order then do:
  if ( {8} - l-min-order) < 0 and l-min-order > 0 then
     {8} = 0 .
     assign v-stroka-protocol = v-stroka-protocol + "13.5>>После проверки на MIN заказ:" + string({8}) + {&delim-par}  .
 end .

if {8} = ? then {8} = 0 .

{&ILOG}  put STREAM  stream_order unformatted "Итого (БЕЗ ОКР)"  {8} skip
 .
{&ILOG}  OUTPUT  STREAM  stream_order CLOSE.
 assign v-stroka-protocol = v-stroka-protocol + "17.Итого рассчитано(БЕЗ ОКР):" + string({8}) .


&Endif
/* $Workfile$ e n d */