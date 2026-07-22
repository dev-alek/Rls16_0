/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы, в которой будем держать всю нужную информацию по товару для ТСД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/28/05
Author: Bakhtadze Natalya
Creation date: 10/28/05

чтобы можно было больше не обращаясь к базе выводить в файл ТСД
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE cash-gds no-undo
FIELD gds-code          like ub.goods.gds-code
FIELD artic             like ub.goods.artic
FIELD b-code            like ub.bar-code.b-code
FIELD b-str             like ub.prod-bc.b-str
/*какой в итоге будет код!!!!*/
FIELD b-code-tsd        like ub.prod-bc.b-str
FIELD gds-name          like ub.goods.gds-name
FIELD engl-name         like ub.goods.engl-name
/*FIELD chk-name          like ub.goods.chk-name*/
FIELD prod-name         like ub.clients.obj-name
FIELD f-name            like ub.gds-prt.f-name
field node-code         like ub.bar-code.node-code
field part-code         like ub.bar-code.part-code
field in-code           like ub.bar-code.in-code
FIELD unit-base         like ub.goods.unit-base
FIELD unit-cli          like ub.bar-code.unit-cli
FIELD cli-base-rate     like ub.bar-code.cli-base-rate
FIELD price-sale        like ub.price-list.price-sale
FIELD price-date        as date
FIELD price-time        as integer
FIELD unit-type         like ub.units.type
FIELD unit-cli-type     like ub.units.type
FIELD crf               as integer
FIELD new-good          as logical
FIELD is-err            as integer
FIELD rc                as recid
field bc-on-type        as character
/*ресид записи от товаре или элементе спика товаров
для задания связи с таблицей налогво на товар*/
index pi is unique primary crf
index bc b-code
index pbc b-str
index itsd b-code-tsd
 .

/* $Workfile$ e n d */