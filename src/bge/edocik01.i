/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Схема для базовой выгрузки  продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/26/10
Author: Bakhtadze Natalya
Creation date: 02/26/10

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
field comment as character
field shiftDateXml as date
field shiftNum as integer
field shiftName as character
field techfuel as logical
field factQnty as decimal column-label "Кол-во факт."
field totalSum as decimal column-label "Сумма брутто"
field totalDsc as decimal column-label "Скидка"
field totalFact as decimal column-label 'Сумма нетто'
index pi is unique primary
referenceNo
.

define temp-table saleDoc no-undo
field saleReferenceNo as character
field referenceNo as character
field codeOperation as character
index pi is primary
saleReferenceNo
codeOperation
referenceNo
.




define temp-table cassSum no-undo
field referenceNo as character
field code as integer
field currCode as integer
field sum as decimal
field sumr as decimal
field sumb as decimal
index pi is unique primary
referenceNo
code
.




define temp-table payCode no-undo
field referenceNo as character
field good as integer
field deskcode as integer
field payCode as integer
field quantity as decimal
field sum as decimal
field sumb as decimal
field sumr as decimal
index pi is unique primary
referenceNo
good
deskcode
payCode
.


define temp-table payCard no-undo
field referenceNo as character
field good as integer
field deskcode as integer
field payCode as integer
field num as character
field quantity as decimal
field sumr as decimal
index pi is unique primary
referenceNo
good
deskcode
payCode
num
.

define temp-table check1 no-undo XML-NODE-NAME "check"
field referenceNo as character
field type as character /*office*/
field num as integer /*chk-num*/
field doccode  as character
field desk as integer
field dateXml as date
field chk-time as character xml-node-name "time"
field shiftDateXml as date
field shiftNum as integer
field dCard as character
field dCardCliType as character
field dCardCliCode as integer
field discnt as decimal
field cashier as integer
field cashierPsnCode as integer
field salesMan as integer
field zNumber as integer
field manualMaked as logical
field manualChanged as logical
field subDiscnt as decimal
field totDoc  as decimal
index pi is unique primary
referenceNo
docCode
.

define temp-table checkGds no-undo
field doccode  as character
field gdsCode as integer
field qnty as decimal
field priceBase as decimal
field priceDiscnt as decimal
field lineNum as integer
field pump as integer
field roadTax as decimal
field srcCode as character
field srcQnty as decimal
field srcPrice as decimal
index pi is unique primary
doccode
linenum
.
define temp-table checkPay no-undo
field docCode as character
field payCode as integer
field payCard as character
field currCode as integer
field sumBase as decimal
field sumRubl as decimal
field sumTot as decimal
field lineNum as integer
index pi is unique primary
doccode
linenum
.

define temp-table checkDiscount no-undo
field docCode as character
field recType as integer
field lineNum as integer
field discnt-id as integer
field discntVCode as integer
field objectLineNum as integer
field discntTargetCode as integer
field discntTypeCode as integer
field discntValueAbs as decimal
field discntValuePcnt as decimal
field srcDCard as character
field discntKategory as integer
index pi is unique primary
doccode
recType
linenum
discnt-id
.


define dataset inkas-01
xml-node-name "inkas-01"
for operation, saleDoc, cassSum,
paycode, payCard,
check1, checkGds, checkPay, checkDiscount
data-relation operation-saleDoc for operation, saleDoc relation-fields (referenceNo, saleReferenceNo) nested
data-relation saleDoc-cassSum for saleDoc, cassSum relation-fields (referenceNo, referenceNo) nested
data-relation saleDoc-payCode for saleDoc, payCode relation-fields (referenceNo, referenceNo) nested
data-relation saleDoc-payCard for payCode, payCard relation-fields (referenceNo, referenceNo, good, good, deskcode, deskcode, payCode, paycode) nested
data-relation operation-check1 for operation, check1 relation-fields (referenceNo, referenceNo) nested
data-relation check1-checkGds for check1, checkGds relation-fields (docCode, docCode) nested
data-relation check1-checkPay for check1, checkPay relation-fields (docCode, docCode) nested
data-relation check1-checkDiscount for check1, checkDiscount relation-fields (docCode, docCode) nested
.

/* $Workfile$ e n d */