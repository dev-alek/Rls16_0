/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/06/08
Author: Bakhtadze Natalya
Creation date: 08/06/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table {1} no-undo like ub.chk-pay  before-table {2}
/*скидко облагаемый кусок*/
field for-discnt-doc as decimal
field for-discnt-r-b as decimal
field for-discnt-rubl as decimal
field for-discnt-base as decimal
field brutto-doc as decimal
field brutto-rubl as decimal
field brutto-base as decimal
field brutto-r-b as decimal
field r-sum as decimal
field discnt-r-b as decimal
field discnt-sum as decimal
field discnt-rubl as decimal
field discnt-base as decimal
field b-exch-date as date
field b-exch-time as integer
field b-exch-rate as decimal
help {&dr-flddf_pline_exch-rate}
field b-exch-scale as integer
help {&dr-flddf_pline_exch-scale}
field b-calc-rate as decimal
field is-cash as logical
field has-overpay as integer
field atr1 as logical
field has-return as integer
field can-mix as integer
field frpay-code as integer
field inversed as logical
field is-credit-card as logical
field is-debet-card as logical
field atr128 as logical
field atr16 as logical
field atr32 as logical
field recalc-line-num as integer
field par-rate as decimal
field get-qnty-method as character
field byval as logical
help {&dr-flddf_pline_recalc-line-num}
index ln is unique primary
doc-code
line-num
index ipay
pay-code curr-code

.

/* $Workfile$ e n d */