/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы связкb  вид расхода (вид кассового платежа или инвент или проливы и.д.) - товар)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

ЮКОС лист 3

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE {2} no-undo
FIELD gds-code like ub.goods.gds-code
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal /*это всегда base*/
FIELD out-name as character format "X(20)"
FIELD is-pay as logical /*для repzak это означает наличне или нет*/
FIELD ii as integer
&if "{3}" = "bge" &then
FIELD pay-desk as integer
FIELD prefix as character
&endif
FIELD netto-rubl as decimal
&if "{3}" = "rep" &then
FIELD rv    as integer /*1 - расход - 1 возврат*/
FIELD VAT-pc like ub.doc-line.vat-pc
FIELD netto-inkas as decimal /*это всегда base*/ /*здесь лежит сумма по текущей продаже*/
FIELD netto-rubl-inkas as decimal                /*здесь лежит сумма по текущей продаже*/
FIELD inkas-code like ub.chk-doc.out-code
&endif
&if "{3}" = "repzak" &then
FIELD rest-qnty as decimal
FIELD src-code like ub.chk-gds.src-code
FIELD is-out   as logical
&endif
INDEX pi IS UNIQUE PRIMARY
&if "{3}" = "repzak" &then
     is-out
     gds-code
     is-pay DESCENDING
     src-code
&else
        gds-code
  &if "{3}" = "bge" &then
        pay-desk
  &endif
        cpay-code
        curr-code
  &if "{3}" = "bge" &then
        prefix
  &endif
  &if "{3}" = "rep" &then
        rv
  &endif
        is-pay DESCENDING
&endif /*не rezak*/
INDEX vi
&if not "{3}" = "bge" &then
IS UNIQUE
&endif
      gds-code
      ii
&if "{3}" = "rep" &then
INDEX ivat vat-pc
&endif

.

/* $Workfile$ e n d */
