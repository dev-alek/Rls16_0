/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы связки  вид расхода (вид кассового платежа или инвент или проливы и.д.) - товар)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

ЮКОС лист 3

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE treal-3 no-undo
FIELD grp-code-sheet as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD discnt-type   as integer
FIELD brutto as decimal 
FIELD discount-sum as decimal
FIELD chk-qnty as int
INDEX pi IS UNIQUE PRIMARY
      grp-code-sheet
      cpay-code
      discnt-type
      curr-code
      is-pay DESCENDING
INDEX vi 
      grp-code-sheet
      ii
.

/* $Workfile$ e n d */