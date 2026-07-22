/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Схема для базовой выгрузки переоценки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/24/09
Author: Bakhtadze Natalya
Creation date: 12/24/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


define temp-table operation no-undo
field referenceNo as character
field codeOperation as character
field host as integer
field store as character
field factOrder as decimal
field sysDateXML as date
field sysTime as character
field dateDocXML as date
field dateFactXML as date
field factTime as character
field valutCode as integer
field valutCodeOKV as integer
field comment as character
field suppInDocNo as character
index pi is unique primary
referenceNo
.


define temp-table linedoc no-undo
field referenceNo as character
field good as integer
field bCode as integer
field artic as character
field prodType as character
field prodCode as integer
field type as character
field unitType as character
field unitCli as character
field cliBaseRate as decimal
field doc_ID as character
field partCode as character
field priceSale as decimal
field priceListQnty as decimal
field pricePrev as decimal
index pi is unique primary
referenceNo
bCode
.


define dataset price-doc-01
for operation, linedoc
data-relation referenceNodoc-num for operation, linedoc relation-fields (referenceNo, referenceNo) nested
.


/* $Workfile$ e n d */