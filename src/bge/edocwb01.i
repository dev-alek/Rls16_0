/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Схема для базовой выгрузки накладных

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/15/09
Author: Bakhtadze Natalya
Creation date: 12/15/09

*/

define temp-table operation no-undo
field referenceNo as character
field isDel as logical
field codeOperation as character
field host as integer
field store as character
field factOrder as decimal
field sysDateXml as date
field sysTime as character
field dateDelXml as date
field dateDocXml as date
field dateFactXml as date
field timeFact as character
field valutCode  as integer
field valutCodeOKV as integer
field exchCode as integer
field exchRate as decimal
field exchScale as integer
field firm as character
field extNumber as character
field OutNumber as character
field outDateXml as date
field paymentCode as integer
field InterFirmDocChild as character
field InterFirmDocParent as character
field InterFirmObjType as character
field InterFirmObjCode as integer
field authority as character
field suppInDocDateXml as date
field suppInDocNo as character
field contractSuppCode as character
field contractSuppNo as character
field contractSuppDateXml as date
field contractDateXml as date
field contractNo as character
field sfNo as character
field sfDateXml as date
field doverNo as character
field doverDateXml as date
field reasonCode as integer
field outCode as character
field comment as character
field ordDocCode as character
field ordOutDocCode as character
field shiftDateXml as date
field shiftNum as integer
field shiftName as character
field dCard as character
field techfuel as logical
field office as logical
field docQnty as decimal column-label "Кол-во по док-ту"
field factQnty as decimal column-label "Кол-во факт."
field cliQnty as decimal column-label "Кол-во в ед пост - соттвет doc-qnty."
field totalSum as decimal column-label "Сумма по док-ту"
field totalDsc as decimal column-label "Скидка по док-ту"
field totalFact as decimal column-label 'Сумма факт'
field totalDscFact as decimal column-label 'Скидка факт'
field totalPayFact as decimal column-label "К оплате факт"
field baserate as decimal column-label "Курс баз.вал"
field vatType as character
index pi is unique primary
referenceNo
.

define temp-table dtl no-undo
field referenceNo as character
field good as integer
field prtCode as integer
field dtlName as character
field qnty as decimal
field sumr as decimal
field VATr as decimal
/*field SLTr as decimal*/
field roadTaxr as decimal
field sumb as decimal
field VATb as decimal
/*field SLTb as decimal*/
field roadTaxb as decimal
index pi is unique primary
referenceNo
good
prtcode
.


define temp-table beforeSum no-undo
field referenceNo as character
field qnty as decimal
index pi is unique primary
referenceNo
.

define temp-table afterSum no-undo
field referenceNo as character
field qnty as decimal
index pi is unique primary
referenceNo
.

define temp-table beforeSumLine no-undo
field referenceNo as character
field good as integer
field qnty as decimal
field petrolweight as decimal
index pi is unique primary
referenceNo
.

define temp-table afterSumLine no-undo
field referenceNo as character
field good as integer
field qnty as decimal
field petrolweight as decimal
index pi is unique primary
referenceNo
.



define temp-table saleSumBeforeSum
field referenceNo as character
field sumr as decimal
field VATr as decimal
/*field SLTr as decimal*/
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
/*field SLTb as decimal*/
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
.


define temp-table saleSumAfterSum
field referenceNo as character
field sumr as decimal
field VATr as decimal
/*field SLTr as decimal*/
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
/*field SLTb as decimal*/
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
.


define temp-table costSumBeforeSum
field referenceNo as character
field sumr as decimal
field VATr as decimal
/*field SLTr as decimal*/
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
/*field SLTb as decimal*/
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
.


define temp-table costSumAfterSum
field referenceNo as character
field sumr as decimal
field VATr as decimal
/*field SLTr as decimal*/
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
/*field SLTb as decimal*/
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
.

define temp-table saleSumBeforeSumLine
field referenceNo as character
field good as integer
field sumr as decimal
field VATr as decimal
/*field SLTr as decimal*/
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
/*field SLTb as decimal*/
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
good
.


define temp-table saleSumAfterSumLine
field referenceNo as character
field good as integer
field sumr as decimal
field VATr as decimal
/*field SLTr as decimal*/
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
/*field SLTb as decimal*/
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
good
.


define temp-table costSumBeforeSumLine
field referenceNo as character
field good as integer
field sumr as decimal
field VATr as decimal
/*field SLTr as decimal*/
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
/*field SLTb as decimal*/
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
good
.


define temp-table costSumAfterSumLine
field referenceNo as character
field good as integer
field sumr as decimal
field VATr as decimal
/*field SLTr as decimal*/
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
/*field SLTb as decimal*/
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
good
.



define temp-table linedoc no-undo
field referenceNo as character
field good as integer
field artic as character
field prodType as character
field prodCode as integer
field type as character
field unitType as character
field wait as decimal
field place as decimal
field priceCli as decimal
field cliBaseRate as decimal
field quantity as decimal
field vatPC as decimal
field petrolWeight as decimal
field petrolDensity as decimal
field petrolInvFactStk as decimal
field petrolBeforeQnty as decimal
field petrolAfterQnty as decimal
field petrolDiffQnty as decimal
field petrolAbsDiffQnty as decimal
field CSTCode as character
field cashParts as logical
index pi is unique primary
referenceNo
good
.


define temp-table part no-undo
field referenceNo as character
field good as integer
field doc_ID as character
field partCode as character
field qnty as decimal
field cst as character
field supp as character
field hostCode as integer
field contractCode as character
field sumr as decimal
field VATr as decimal
/*field SLTr as decimal*/
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
/*field SLTb as decimal*/
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
field contractSuppCode as character
field contractSuppNo as character
field contractSuppDateXml as date
field countryCode as character
field priceCli as decimal
field cliBaseRate as decimal
field vatType as character
field exchCode as integer
field attrExchRate as decimal
field attrExchScale as integer
field attrUnitCli as character
field lastDate as date
field priceb as decimal
field pricer as decimal
field prodPrice as decimal
field fib as integer
field salePrice as decimal
field purch-code as integer
index pi is unique primary
referenceNo
good
doc_ID
partCode
.




define dataset waybill-01
xml-node-name "waybill-01"
for operation, beforeSum, salesumbeforesum, costsumbeforesum,
afterSum, salesumaftersum, costsumaftersum,
linedoc,
beforeSumLine, salesumbeforesumLine, costsumbeforesumLine,
afterSumLine, salesumaftersumLine, costsumaftersumLine,
dtl, part
data-relation operation-beforesum for operation, beforesum relation-fields (referenceNo, referenceNo) nested
data-relation beforesum-salesumbeforesum for beforesum, salesumbeforesum relation-fields (referenceNo, referenceNo) nested
data-relation beforesum-costsumbeforesum for beforesum, costsumbeforesum relation-fields (referenceNo, referenceNo) nested
data-relation operation-aftersum for operation, aftersum relation-fields (referenceNo, referenceNo) nested
data-relation aftersum-salesumaftersum for aftersum, salesumaftersum relation-fields (referenceNo, referenceNo) nested
data-relation aftersum-costsumaftersum for aftersum, costsumaftersum relation-fields (referenceNo, referenceNo) nested
data-relation operation-linedoc for operation, linedoc relation-fields (referenceNo, referenceNo) nested
data-relation linedoc-dtl for linedoc, dtl relation-fields (referenceNo, referenceNo, good, good) nested
data-relation linedoc-part for linedoc, part relation-fields (referenceNo, referenceNo, good, good) nested
data-relation linedoc-beforesumLine for linedoc, beforesumLine relation-fields (referenceNo, referenceNo, good, good) nested
data-relation beforesum-salesumbeforesumLine for beforesumLine, salesumbeforesumLine relation-fields (referenceNo, referenceNo, good, good ) nested
data-relation beforesum-costsumbeforesumLine for beforesumLine, costsumbeforesumLine relation-fields (referenceNo, referenceNo, good, good) nested
data-relation linedoc-aftersumLine for linedoc, aftersumLine relation-fields (referenceNo, referenceNo, good, good) nested
data-relation aftersum-salesumaftersumLine for aftersumLine, salesumaftersumLine relation-fields (referenceNo, referenceNo, good, good) nested
data-relation aftersum-costsumaftersumLine for aftersumLine, costsumaftersumLine relation-fields (referenceNo, referenceNo, good, good) nested
.

/* $Workfile$ e n d */