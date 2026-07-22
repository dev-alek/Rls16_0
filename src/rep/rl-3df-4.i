/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы -вид расхода (вид кассового платежа или инвент или проливы и.д.)  - строка чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

Отчет с разброской по платежам

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE treal-3 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal /*это всегда base*/
FIELD out-name as character format "X(20)"
FIELD is-pay as logical /*для repzak это означает наличне или нет*/
FIELD ii as integer
FIELD netto-rubl as decimal
FIELD rv    as integer /*1 - расход - 1 возврат*/
FIELD VAT-pc like ub.doc-line.vat-pc
FIELD netto-inkas as decimal /*это всегда base*/ /*здесь лежит сумма по текущей продаже*/
FIELD netto-rubl-inkas as decimal                /*здесь лежит сумма по текущей продаже*/
FIELD inkas-code like ub.chk-doc.out-code
INDEX pi IS UNIQUE PRIMARY
        gds-code
        cpay-code
        curr-code
        rv
        is-pay DESCENDING
INDEX vi
IS UNIQUE
      gds-code
      ii
INDEX ivat vat-pc
.

/* $Workfile$ e n d */