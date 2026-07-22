/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать товаров на весах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ str/get-pr.i calc buf_scales-gds.obj-type buf_scales-gds.obj-code buf_bar-code.gds-code buf_bar-code.node-code "Return error."}
assign
obj-attr = buf_scales-gds.obj-type + " " + string( buf_scales-gds.obj-code )
price = ( if  gp-price-sale = ?
          then "НЕТ ЦЕНЫ"
          else string( gp-price-sale, "->>>,>>>,>>9.99" ) )
.

&scop sc-gds-type string(buf_scales-gds.plu-type)

DISPLAY stream PrnLibStream
sym1 buf_scales-gds.PLU-code
{&sc-gds-type-name} @ v-type
buf_goods.artic
(if available buf_prod-bc{2}
then buf_prod-bc{2}.b-str
else (if  available buf_prod-bc
      then buf_prod-bc.b-str
      else {&question-mark} ))  @ bar_code
caps( buf_goods.gds-name ) @ buf_goods.gds-name
price
sym5 obj-attr
sym6 with frame {1} .
DOWN stream PrnLibStream 1 with frame {1} .
ACCUMULATE buf_goods.artic( count ).
if ( accum count buf_goods.artic ) modulo 20 = 0 then
run waitfram-show in this-procedure ("Обработано строк списка : " + string ((accum count buf_goods.artic))).


/* $Workfile$ e n d */