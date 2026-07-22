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

ЮКОС лист 4

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE {2} no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal  /*это всегда base*/
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
/*счетчик внутри товара*/
&if not "{3}" = "bge" &then
FIELD discnt-type   as integer
FIELD brutto as decimal 
FIELD discount-sum as decimal
FIELD chk-qnty as int
&endif
FIELD ii as integer
&if "{3}" = "bge" &then
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
&endif
INDEX pi IS UNIQUE PRIMARY
      gds-code
&if "{3}" = "bge" &then
      pay-desk
&endif
      cpay-code
&if not "{3}" = "bge" &then
	  discnt-type	
&endif
      curr-code
&if "{3}" = "bge" &then
      prefix
&endif
      is-pay DESCENDING
INDEX vi
&if not "{3}" = "bge" &then
/*IS UNIQUE*/
&endif
      gds-code
      ii
.

/* $Workfile$ e n d */