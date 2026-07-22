/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/28/10
Author: Bakhtadze Natalya
Creation date: 07/28/10

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&scop n13 "9999999999999"
&scop n14 "99999999999999"
&scop xml-node-type-hidden xml-node-type "hidden"

define temp-table RECADV{1} no-undo
field NUMBER  as character
field DATE as date
field RECEPTIONDATE as date
field ORDERNUMBER as character
field ORDERDATE as date
field DESADVNUMBER as character
field DESADVDATE as date
field DELIVERYNOTENUMBER as character
field DELIVERYNOTEDATE as date
field CAMPAIGNNUMBER as character
field SUPPLIERORDERNUMBER as character
field SUPPLIERORDERDATE as date
field INFO as character
index pi is unique primary NUMBER
.


define temp-table  HEAD{1} no-undo
field NUMBER  as character {&xml-node-type-hidden}
field SUPPLIER as character format {&n13}
field BUYER as character format {&n13}
field DELIVERYPLACE as character format {&n13}
field FINALRECIPIENT as character format {&n13}
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
field HIERARCHICALPARENTID as integer
index pi is unique primary  number HIERARCHICALID
.

define temp-table PACKAGE{1} no-undo
field NUMBER  as character {&xml-node-type-hidden}
field HIERARCHICALID as integer
field PACKAGEID as integer
field PACKAGETYPE as character
field DELTAQUANTITYTYPE as character
field DELTAQUANTITY as decimal
field SSCC as character
index pi is unique primary  number HIERARCHICALID PACKAGEID
.


define temp-table POSITION{1} no-undo
field NUMBER  as character {&xml-node-type-hidden}
field HIERARCHICALID as integer {&xml-node-type-hidden}
field POSITIONNUMBER as integer
field PRODUCT as character
field PRODUCTIDSUPPLIER as character format "X(16)"
field PRODUCTIDBUYER as character format "X(16)"
field ACCEPTEDQUANTITY as decimal
/*
field DELTAQUANTITYTYPE as character
field DELTAQUANTITY as decimal
*/
field ACCEPTEDUNIT as character
field DELIVERQUANTITY as decimal
/*
field DELIVERQUANTITYTYPE as character
*/
field DELIVERUNIT as character
field ORDERQUANTITY as decimal
/*
field DELIVERQUANTITY as decimal
field DELIVERQUANTITYTYPE as character
*/
field ORDERUNIT as character
field PRICE as decimal
/*field AMOUNT as decimal*/
index pi is unique primary  number positionnumber
.



define dataset RECADV_{1}
for
RECADV{1}, HEAD{1}, POSITION{1}
data-relation r1 for RECADV{1}, HEAD{1} relation-fields ( NUMBER, NUMBER) nested
data-relation r3 for RECADV{1},  POSITION{1}  relation-fields ( NUMBER, NUMBER ) nested
.




/* $Workfile$ e n d */