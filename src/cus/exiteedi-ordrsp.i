/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

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

define temp-table ORDRSP{1} no-undo
field NUMBER  as character
field DATE as date
field TIME_ as character /*xml-node-name "TIME"*/
field ORDERNUMBER  as character
field ORDERDATE  as date
field DELIVERYDATE as date
field CURRENCY as character
field ACTION as integer
index pi is unique primary NUMBER
.

&if "{2}" = "" &then

define temp-table  HEAD{1} no-undo
field NUMBER  as character {&xml-node-type-hidden}
field BUYER as character format {&n13}
field SUPPLIER as character format {&n13}
field DELIVERYPLACE as character format {&n13}
field INVOICEPARTNER as character format {&n13}
field SENDER as character format {&n13}
field RECIPIENT as character format {&n13}
field EDIINTERCHANGEID as character format {&n14}
field EDIMESSAGE as character format {&n14}
index pi is unique primary  number
.


define temp-table POSITION{1} no-undo
field NUMBER  as character {&xml-node-type-hidden}
field POSITIONNUMBER as integer
field PRODUCT as character
field PRODUCTIDBUYER as character format "X(16)"
field PRODUCTIDSUPPLIER as character format "X(16)"
field DESCRIPTION as character format "X(70)"
field PRICE as decimal
field VAT as decimal
field PRODUCTTYPE as integer
field ORDEREDQUANTITY as decimal
field ACCEPTEDQUANTITY as decimal
field INFO as character
index pi is unique primary  number positionnumber
.

define dataset ORDRSP_{1}
for
ORDRSP{1}, HEAD{1}, POSITION{1}
data-relation r1 for ORDRSP{1}, HEAD{1} relation-fields ( NUMBER, NUMBER) nested
data-relation r2 for HEAD{1}, POSITION{1} relation-fields ( NUMBER, NUMBER) nested
.

&endif


/* $Workfile$ e n d */