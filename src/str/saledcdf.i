/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица с данными по продажам по ДК по одной продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/15/04
Author: Bakhtadze Natalya
Creation date: 12/15/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "" &then
&scop temp-d-card temp-d-card
&else
&scop temp-d-card {2}
&endif


define {1} temp-table {&temp-d-card} no-undo
field card-num as integer
field d-card as character
field dt-code as integer
field first-card as character
field first-main-card as character
field gds-dis-base as decimal
field gds-dis-rubl as decimal
field gds-tot-b0   as decimal
field gds-tot-base as decimal
field gds-tot-r0   as decimal
field gds-tot-rubl as decimal
field host-code as integer
field main-card as character
field num-chk as integer
field obj-code as integer
field obj-type as character
field pay-tot-base as decimal
field pay-tot-rubl as decimal
field sum-dis-base as decimal
field sum-dis-rubl as decimal
field sum-tot-base as decimal
field sum-tot-rubl as decimal
field sum-tot-r-b         as decimal
field gds-tot-r-b         as decimal
field gds-dis-r-b         as decimal
field cli-type            as character
field cli-code            as integer
field emitent-host-code   as integer
field type                as character
field exp-imp             as logical
field sale-doc            as character
field sale-type           as character
field doc-date            as date
field base-code           as integer
field smart-nws-log       as logical init ?
field action              as integer /*1 - закрытие -1 - удаление*/
index pi is unique primary
d-card
obj-type obj-code
index iobj obj-type obj-code
index itype type emitent-host-code
.


/* $Workfile$ e n d */