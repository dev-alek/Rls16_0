/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ОТЧЕТ ПО ПОКУПКАМ ПОСТОЯННЫХ КЛИЕНТОВ ( С ДИС.КАРТАМИ) для Lui Vuitton - определени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/23/03
Author: Bakhtadze Natalya
Creation date: 09/23/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table temp-cards no-undo
field d-card like ub.dis-card.d-card
field cli-type like ub.dis-card.cli-type
field cli-code like ub.dis-card.cli-code
field last-date like ub.chk-doc.chk-date
field last-time like ub.chk-doc.chk-time
field last-obj-type like ub.chk-doc.obj-type
field last-obj-code like ub.chk-doc.obj-code
index pi is unique primary
d-card
index iclients
cli-type
cli-code
.

define {1} temp-table temp-gds no-undo
field d-card like ub.dis-card.d-card
field cli-type like ub.dis-card.cli-type
field cli-code like ub.dis-card.cli-code
field gds-code like ub.goods.gds-code
field artic like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field gds-name like ub.goods.gds-name
field src-d-pcnt like ub.chk-doc.src-d-pcnt
field chk-date like ub.chk-doc.chk-date
field obj-code like ub.chk-doc.obj-code
field cashier like ub.chk-doc.cashier
field cashier-psn-code like ub.chk-doc.cashier-psn-code
field sales-man like ub.chk-doc.sales-man
field salesman-psn-code like ub.chk-doc.salesman-psn-code
field d-pcnt as decimal
field doc-qnty like ub.chk-gds.doc-qnty
field price-base like ub.chk-gds.price-base
field discnt like ub.chk-gds.discnt
field cash-rate like ub.chk-doc.cash-rate
field cash-scale like ub.chk-doc.cash-scale
index pi is primary
cli-type
cli-code
d-card
gds-code
.

/* $Workfile$ e n d */

