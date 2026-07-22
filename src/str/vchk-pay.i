/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы применяемой при генерации payment из продаж (новостей)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE vchk-pay NO-UNDO
FIELD d-card like ub.chk-doc.d-card
FIELD PAY-code like ub.chk-pay.pay-code
FIELD curr-code like ub.chk-pay.curr-code
FIELD doc-date like ub.chk-pay.chk-date
FIELD cre-pay as logical
FIELD exch-rate as decimal
FIELD base-rate as decimal
FIELD tot-sum like ub.chk-pay.tot-sum
FIELD tot-base like ub.chk-pay.tot-base
FIELD tot-rubl like ub.chk-pay.tot-rubl
FIELD pmnt-code like ub.payment.pmnt-code
/*&if "{2}" = "obj" &then*/
field obj-type            like ub.clients.obj-type
field obj-code            like ub.clients.obj-code
/*&endif*/
INDEX PI IS PRIMARY UNIQUE
d-card pay-code curr-code doc-date cre-pay exch-rate base-rate
/*&if "{2}" = "obj" &then*/
index iobj obj-type obj-code
/*&endif*/
.



/* $Workfile$ e n d */