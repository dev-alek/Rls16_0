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

DEFINE {1} TEMP-TABLE {2} no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD qnty2 as decimal
FIELD netto as decimal  /*это всегда base*/
&if not "{3}" = "bge" &then
FIELD brutto as decimal  /*это всегда base*/
FIELD discount-sum as decimal
FIELD chk-qnty as int  /*это всегда base*/
&endif
FIELD out-name as character format "X(18)"
FIELD is-pay as logical
/*FIELD jj as integer*/
FIELD ii as integer
&if not "{3}" = "bge" &then
field discnt-type as integer
&endif
&if "{3}" = "bge" &then
FIELD pay-desk as integer
&if "{4}" = "pump" &then
FIELD pump as integer
&endif
&if "{4}" = "pump-nozzle" &then
FIELD pump as integer
FIELD nozzle-code as integer
&endif

FIELD prefix as character
FIELD netto-rubl as decimal
&endif
INDEX pi IS
&if "{3}" = "bge" &then
  unique
&endif
  primary
      gds-code
&if "{3}" = "bge" &then
      pay-desk
&endif
&if "{4}" = "pump" &then
      pump
&endif
&if "{4}" = "pump-nozzle" &then
      pump
      nozzle-code
&endif
      cpay-code
      curr-code
&if "{3}" = "bge" &then
      prefix
&endif
      is-pay DESCENDING
INDEX vi
&if not "{3}" = "bge" &then
/* IS UNIQUE */
&endif
      gds-code
&if not "{3}" = "bge" &then
      cpay-code
      discnt-type
&endif
      ii
.

/* $Workfile$ e n d */