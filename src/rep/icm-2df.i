/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы по связке  вид прихода - товар

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

ЮКОС лист 2

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*какие вообще топлива были за смену*/
DEFINE {1} TEMP-TABLE t-2 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD main-code like ub.bar-code.b-code
FIELD artic like ub.goods.artic
FIELD prod-type like ub.goods.prod-type
FIELD prod-code like ub.goods.prod-code
FIELD qnty1-before as decimal FORMAT "->>>>9.99"
FIELD qnty2-before as decimal FORMAT "->>>>9.99"
FIELD qnty1-after as decimal FORMAT "->>>>9.99"
FIELD qnty2-after as decimal FORMAT "->>>>9.99"
FIELD last-price as decimal FORMAT ">>>>9.99"
FIELD gds-name like ub.goods.gds-name FORMAT "X(12)"
FIELD lines as integer
INDEX pi IS UNIQUE primary
gds-code
INDEX art IS UNIQUE
artic
prod-type
prod-code
INDEX pervakov IS UNIQUE
main-code
.

DEFINE {1} TEMP-TABLE tincome-2 no-undo
FIELD gds-code as integer
FIELD supp-name like ub.clients.obj-name FORMAT "X(18)"
FIELD supp-type like ub.clients.obj-type
FIELD supp-code like ub.clients.obj-code FORMAT ">>>>>>>>9"
FIELD doc-code-trn  like ub.trn-doc.doc-code
FIELD doc-code  like ub.trn-doc.doc-code
FIELD qnty1 as decimal FORMAT "->>>>9.99"
FIELD qnty2 as decimal FORMAT "->>>>9.99"
FIELD qnty3 as decimal FORMAT "->>>>9.99"
FIELD density as decimal FORMAT "9.999"
FIELD temperature as decimal FORMAT ">9.99"
FIELD naturalloss as decimal FORMAT ">9.99"
FIELD is-fact as logical
FIELD ii as integer
INDEX pi IS UNIQUE PRIMARY
      gds-code
      doc-code-trn
      doc-code
      supp-code
INDEX vi IS UNIQUE
      gds-code
      ii
.

/* $Workfile$ e n d */