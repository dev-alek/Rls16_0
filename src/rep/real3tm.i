/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы, по связке  b-code (src-code) количество сумма

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/17/05
Author: Bakhtadze Natalya
Creation date: 03/17/05

для отчетов раскидывающих по типу кассового платежа

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp-chk-gds no-undo
field doc-code like ub.chk-doc.doc-code
FIELD b-code like ub.chk-gds.b-code
field discnt as decimal
field line-type  as character
field line-sign as logical
field sum as decimal
field line-num as integer
field num-lines as integer
field doc-qnty as decimal
field sign as integer
field rec-type as integer /*топливо  = 1 нетопливо = 0*/
field gds-type as integer /*топливо  = 1 товары = 2 услуги = 3*/
field density as decimal
field price-base as decimal
field price-service as decimal
field jjp_ as integer
field jjo_ as integer
field jj_ as integer
field flag as logical
field gds-code as integer
index pi iS unique primary
doc-code
rec-type
b-code
line-num
index ijj
jj_
line-num
index ijjp
doc-code
jjp_
line-num
index ijjo
doc-code
jjo_
line-num
index iflag
doc-code
flag
line-num
.


define temp-table temp-chk-pay no-undo
field doc-code like ub.chk-doc.doc-code
field pay-card as character
field pay-code as integer
field curr-code as integer
field sign as integer
field line-num as integer
field pet-good as integer /*2 топливо не нал 1 нал 0 остальное*/
field is-cash  like ub.cash-pay.is-cash
field register like ub.cash-pay.register
field num-lines as integer
field tot-r-b as decimal
field tot-rubl as decimal
field tot-base as decimal
field flag as logical
field rrn as character
index pi is primary unique
doc-code
pay-code
curr-code
line-num
index isort
doc-code
pet-good  descending
line-num
index ipcard
doc-code
pay-code
curr-code
pay-card
rrn
index iflag
doc-code
flag
.
/*
define temp-table temp-chk-gds-pay no-undo
field doc-code like ub.chk-doc.doc-code
field algo-num as character
field eff-doc-qnty as decimal
field line-num as integer
field pay-code as integer
field curr-code as integer
field pline-num as integer
field tot-r-b as decimal
field eff-base-rate as decimal
field tot-rubl as decimal
field tot-base as decimal
index pi is unique primary
line-num
pay-code
curr-code
.
*/

define temp-table temp-chk-dp no-undo
field doc-code like ub.chk-doc.doc-code
FIELD b-code like ub.chk-gds.b-code
field line-sign as logical
field sum as decimal
field qnty as decimal
field all-sum as decimal
field line-num as integer
field sign as integer
field pay-code as integer
index pi pay-code line-num
.
/* $Workfile$ e n d */