/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура сообщения DESADV для Exite-EDI

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


define temp-table DESADV{1} no-undo
field NUMBER  as character
field DATE as date
field DELIVERYDATE as date
field EARLIESTDELIVERY as date
field LATESTDELIVERY as date
field DELIVERYTIME as CHARACTER
field ORDERNUMBER as character
field ORDERDATE as date
field DELIVERYNOTENUMBER as character
field DELIVERYNOTEDATE as date
field SUPPLIERORDERNUMBER as character
field SUPPLIERORDERDATE as date
field TRANSPORTATIONTYPES as character
field TRANSPORTATIONMEANS as character
field GROSSWEIGHT as decimal
field GROSSVOLUME as decimal
field CAMPAIGNNUMBER as character
index pi is unique primary NUMBER
.
&if "{2}" = "" &then

define temp-table  HEAD{1} no-undo
field NUMBER  as character {&xml-node-type-hidden}
field SUPPLIER as character format {&n13}
field BUYER as character format {&n13}
field DELIVERYPLACE as character format {&n13}
field FINALRECIPIENT as character format {&n13}
field ORDERPARTNER as character format {&n13}
field LOGISTICPARTNER as character format {&n13}
field SENDER as character format {&n13}
field RECIPIENT as character format {&n13}
field EDIINTERCHANGEID as character format {&n14}
field EDIMESSAGE as character
index pi is unique primary  number
.


define temp-table PACKINGSEQUENCE{1} no-undo
field NUMBER  as character {&xml-node-type-hidden}
field HIERARCHICALID as integer
index pi is unique primary  number HIERARCHICALID
.

define temp-table PACKAGE{1} no-undo
field NUMBER as character
field HIERARCHICALID as integer
field PACKAGEID as integer
field SSCC as character
field PACKAGETYPE as character
field PACKAGECOUNT as integer
field TYPENUMBER as character
field HANDLINGINFO as character
field LENGTH as decimal
field WIDTH as decimal
field HEIGHT as decimal
field GROSSWEIGHT as decimal
index pi is unique primary number hierarchicalid packageid
.


define temp-table POSITION{1} no-undo
field NUMBER  as character {&xml-node-type-hidden}
field HIERARCHICALID as integer {&xml-node-type-hidden}
field POSITIONNUMBER as integer
field PRODUCT as character
field PRODUCTIDSUPPLIER as character format "X(16)"
field PRODUCTIDBUYER as character format "X(16)"
field DELIVEREDQUANTITY as decimal
field DELIVEREDUNIT as character
field ORDEREDQUANTITY as decimal
field ORDERUNIT as character
field PRICEQUANT as decimal
/*field INVOICEDQUANTITY as decimal
field INVOICEUNIT as character
field CONSUMERUNITCOUNT as decimal
field CONSUMERUNITCOUNTUNIT as character
field AMOUNT as decimal
field BATCHNUMBER as integer
field BESTBEFOREDATE as date
field EXPIRYDATE as date
field COUNTRYORIGIN as character
field CUSTOMSTARIFFNUMBER as character
*/
index pi is unique primary  number positionnumber
.

define temp-table POSITION2PACKINGSEQUENCE{1} no-undo
field NUMBER  as character {&xml-node-type-hidden}
field HIERARCHICALID as integer {&xml-node-type-hidden}
field POSITIONNUMBER as integer
field DELIVERQUANTITY as decimal
field INVOICEDQUANTITY as decimal
field BESTBEFOREDATE as date
field EXPIRYDATE as date
field BATCHNUMBER as integer
index pi is unique primary  number positionnumber
.


define dataset DESADV_{1}
for
DESADV{1}, HEAD{1}, POSITION{1}
data-relation r1 for DESADV{1}, HEAD{1} relation-fields ( NUMBER, NUMBER) nested
data-relation r3 for HEAD{1}, POSITION{1}  relation-fields ( NUMBER, positionnumber, number, positionnumber ) nested
.

&endif

/* $Workfile$ e n d */