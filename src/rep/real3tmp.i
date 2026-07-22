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
FIELD src-code like ub.chk-gds.src-code
field sum as decimal
field sum-change as decimal
field qnty like ub.chk-gds.doc-qnty
field qnty2 like ub.chk-gds.doc-qnty /* топливо в кг */
field price-base as decimal
field rec-type as integer /*топливо  = 1 нетопливо = 0*/
field gds-type as integer /*топливо  = 1 товары = 2 услуги = 3*/
field line-num as integer
field pump as integer
field nozzle-code as integer
field jj_ as integer
field jjp_ as integer
field jjo_ as integer
&if "{1}" = "repzak" &then
index pi iS unique primary
doc-code
rec-type
src-code
&else
index pi iS unique primary
doc-code
rec-type
b-code
&if "{1}" = "bonus" &then
price-base
&endif
&if "{2}" = "pump" &then
pump
&endif
&if "{2}" = "pump-nozzle" &then
pump
nozzle-code
&endif
&endif
index ijj is unique
jj_
index ijjp
jjp_
index ijjo
jjo_
.


define temp-table temp-chk-pay no-undo like ub.chk-pay
field pet-good as integer /*2 топливо не нал 1 нал 0 остальное*/
field obj-name like ub.cash-pay.obj-name
field is-cash  like ub.cash-pay.is-cash
field register like ub.cash-pay.register
index pi is primary unique line-num
index isort
pet-good  descending
line-num
.



/* $Workfile$ e n d */