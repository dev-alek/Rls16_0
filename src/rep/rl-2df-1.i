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

ЮКОС лист 2

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE treal-2 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD qnty2 as decimal
FIELD netto as decimal  /*это всегда base*/
FIELD brutto as decimal  /*это всегда base*/
FIELD discount-sum as decimal
FIELD chk-qnty as int
FIELD out-name as character format "X(18)"
FIELD is-pay as logical
FIELD ii as integer
/*FIELD jj as integer*/
FIELD discnt-type   as integer
INDEX pi IS
  primary
      gds-code
      cpay-code
      curr-code
      is-pay DESCENDING
INDEX vi
/* IS UNIQUE */
      gds-code
      cpay-code  
      discnt-type
      ii
.

/* $Workfile$ e n d */