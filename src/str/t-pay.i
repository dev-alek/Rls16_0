/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы для платежей используемой при закачке чеков в БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/07
Author: Bakhtadze Natalya
Creation date: 10/31/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

define variable crp as integer no-undo.

&if "{2}" = "chk" &then

/*закачка чеков в БД*/

DEFINE {3} TEMP-TABLE t-pay No-UNDO
FIELD pay-code like UB.chk-pay.pay-code
FIELD curr-code like ub.chk-pay.curr-code
field tot-base as decimal
field tot-rubl as decimal
FIELD num-lines as integer
FIELD was-return as logical
FIELD crf as integer
FIELD pay-card as character
field drc as recid
FIELD is-cash like ub.cash-pay.is-cash
field byval as character
index pi is PRIMARY pay-code curr-code
index crfi crf.

&endif

&endif

/* $Workfile$ e n d */