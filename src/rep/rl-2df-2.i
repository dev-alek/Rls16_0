/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы связки  вид расхода (вид кассового платежа или инвент или проливы и.д.) - товар)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

Выгрузка в bge топлива

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
FIELD out-name as character format "X(18)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS
  unique
  primary
      gds-code
      pay-desk
      cpay-code
      curr-code
      prefix
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.

/* $Workfile$ e n d */