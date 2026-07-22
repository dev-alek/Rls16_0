/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временных таблиц по связке  вид прихода - товар

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

ЮКОС лист 3

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*какие группы в итоге получились*/
DEFINE {1} TEMP-TABLE t-3 no-undo
FIELD grp-code-sheet like ub.goods.grp-code
FIELD grp-name like ub.gds-grp.node-name format "X(32)"
FIELD serv-name as char
FIELD qnty1-before as decimal FORMAT "->>>>9.99"
FIELD netto-before as decimal FORMAT "->>>>9.99"
FIELD qnty1-after as decimal FORMAT "->>>>9.99"
FIELD netto-after as decimal FORMAT "->>>>9.99"
FIELD lines as integer
INDEX pi IS UNIQUE primary
grp-code-sheet
INDEX gname
grp-name
INDEX sname
serv-name
.

/*приходы*/
DEFINE {1} TEMP-TABLE tincome-3 no-undo
FIELD grp-code-sheet as integer
FIELD doc-code  like ub.trn-doc.doc-code
FIELD supp-name like ub.clients.obj-name FORMAT "X(20)"
FIELD supp-type like ub.clients.obj-type
FIELD supp-code like ub.clients.obj-code FORMAT ">>>>>>>>9"
FIELD qnty1-in as decimal FORMAT "->>>>9.99"
FIELD netto-in as decimal FORMAT "->>>>>>>9.99"
FIELD is-fact as logical
FIELD ii as integer
INDEX pi IS UNIQUE PRIMARY
      grp-code-sheet
      doc-code
INDEX vi IS UNIQUE
      grp-code-sheet
      ii
.

/* $Workfile$ e n d */