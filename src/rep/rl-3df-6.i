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

Отчет для ПОДОСИНОК

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
FIELD rest-qnty as decimal
FIELD src-code like ub.chk-gds.src-code
FIELD is-out   as logical
INDEX pi IS UNIQUE PRIMARY
     is-out
     gds-code
     is-pay DESCENDING
     src-code
INDEX vi
IS UNIQUE
      gds-code
      ii

.

/* $Workfile$ e n d */