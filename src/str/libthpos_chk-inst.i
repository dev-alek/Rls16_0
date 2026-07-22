/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/19/08
Author: Bakhtadze Natalya
Creation date: 08/19/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table {1} no-undo like ub.chk-inst
field tot-base as decimal
field tot-rubl as decimal
field tot-r-b as decimal
field r-sum as decimal
field b-exch-date as date
field b-exch-time as integer
field b-exch-rate as decimal
help {&dr-flddf_pline_exch-rate}
field b-exch-scale as integer
help {&dr-flddf_pline_exch-scale}
field b-calc-rate as decimal
field is-cash as logical
field frpay-code as integer
field inversed as logical


field recalc-line-num as integer
help {&dr-flddf_pline_recalc-line-num}
index ln is unique primary
doc-code
line-num
index ipay
pay-code curr-code

.

define temp-table {2} no-undo like ub.chk-par
field tot-base as decimal
field tot-rubl as decimal
.

/* $Workfile$ e n d */