/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица для хранения разбивки НДС-тип кассового платежа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/05/04
Author: Bakhtadze Natalya
Creation date: 08/05/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table {2} no-undo
FIELD vat-pc like ub.doc-line.vat-pc
FIELD inkas-code like ub.inkas.inkas-code
FIELD doc-date    like ub.inkas.doc-date
FIELD netto as decimal /*это всегда base*/
FIELD netto-rubl as decimal
FIELD fact-order like ub.trn-doc.fact-order
FIELD grp-code as character
FIELD rv as integer /*1 продажа - 1 возврат*/
index pi is unique primary
inkas-code grp-code rv vat-pc
index ifactorder fact-order
index igrp grp-code
.

define {1} temp-table tt-cash-group no-undo
FIELD obj-name like ub.cash-pay.obj-name
FIELD grp-code as character
index pi is UNIQUE primary
grp-code
.

define {1} temp-table tt-cash-pay no-undo
FIELD cdpay-code like ub.cash-pay.cdpay-code
FIELD curr-code like ub.cash-pay.curr-code
FIELD grp-code as character
FIELD obj-name like ub.cash-pay.obj-name
index pi is unique primary
cdpay-code curr-code
index igrp grp-code
.

/* $Workfile$ e n d */