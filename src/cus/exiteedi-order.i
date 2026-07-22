/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура сообщения ORDER для Exite-EDI

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/26/10
Author: Bakhtadze Natalya
Creation date: 07/26/10

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop n13 "9999999999999"
&scop n14 "99999999999999"
/*
&scop xml-node-type-hidden xml-node-type "hidden"
*/

define temp-table ORDER{1} no-undo
field DOCUMENTNAME as character
field NUMBER  as character
field DATE as date
field DELIVERYDATE as date
field DELIVERYTIME as character
field CAMPAIGNNUMBER as character
field CURRENCY as character
field INFO as character
index pi is unique primary NUMBER
.

&if "{2}" = " " &then
define temp-table  HEAD{1} no-undo
field NUMBER  as character {&xml-node-type-hidden}
field SUPPLIER as character format {&n13}
field BUYER as character format {&n13}
field DELIVERYPLACE as character format {&n13}
field INVOICEPARTNER as character format {&n13}
field SENDER as character format {&n13}
field RECIPIENT as character format {&n13}
field EDIINTERCHANGEID as character format {&n14}
index pi is unique primary  number
.

define temp-table POSITION{1} no-undo
field NUMBER  as character {&xml-node-type-hidden}
field POSITIONNUMBER as integer
field PRODUCT as character
field PRODUCTIDSUPPLIER as character format "X(16)"
field PRODUCTIDBUYER as character format "X(16)"
field ORDEREDQUANTITY as decimal
field QUANTITYOFCUINTU  as decimal
field ORDERUNIT as character format "X(3)"
field ORDERPRICE as decimal
field VAT as decimal
index pi is unique primary  number positionnumber
.



define temp-table CHARACTERISTIC{1} no-undo
field NUMBER  as character {&xml-node-type-hidden}
field POSITIONNUMBER as integer {&xml-node-type-hidden}
field CHARACTERISTICNUMBER as integer {&xml-node-type-hidden}
field DESCRIPTION as character format "X(70)"
index pi is unique primary  number positionnumber CHARACTERISTICNUMBER
.


define dataset ORDER_{1}
for
ORDER{1}, HEAD{1}, POSITION{1}, CHARACTERISTIC{1}
data-relation r1 for ORDER{1}, HEAD{1} relation-fields ( NUMBER, NUMBER) nested
data-relation r2 for HEAD{1}, POSITION{1} relation-fields ( NUMBER, NUMBER) nested
data-relation r3 for POSITION{1}, CHARACTERISTIC{1}  relation-fields ( NUMBER, NUMBER, POSITIONNUMBER, POSITIONNUMBER ) nested
.
&endif


/* $Workfile$ e n d */