/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временные таблицы для отчета по покупкам постоянных клиентов (с дисконтными картами)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/24/07
Author: Bakhtadze Natalya
Creation date: 07/24/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table dcards  no-undo
field d-card        like ub.dis-card.d-card
field chk-date      as date
field chk-time      as integer
field obj-type      like ub.chk-doc.obj-type
field obj-code      like ub.chk-doc.obj-code
field pump          as integer
field b-code        as integer
field gds-code      as integer
field cli-type      like ub.chk-doc.cli-type
field cli-code      like ub.chk-doc.cli-code
field cli-name      like ub.clients.obj-name
field price-real    like ub.chk-gds.price-base
field doc-qnty      like ub.chk-gds.doc-qnty
field sum-netto     as decimal
index pi
IS unique PRIMARY
d-card
chk-date
chk-time
gds-code
pump
obj-type
obj-code
price-real
index icli
cli-type
cli-code
index ipet
gds-code
price-real
.

/* $Workfile$ e n d */