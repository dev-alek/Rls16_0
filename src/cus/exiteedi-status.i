/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура сообщения STATUS для Exite-EDI

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/26/10
Author: Bakhtadze Natalya
Creation date: 07/26/10

*/


&scop n13 "9999999999999"
&scop n14 "99999999999999"
/*
&scop xml-node-type-hidden xml-node-type "hidden"
*/

define temp-table Status_{1}  no-undo  /*xml-node-name "Status"*/
field EXiteICID  as character
field CustomerICID  as character
field From_ as character /*xml-node-name "From"*/
field To_  as character /*xml-node-name "To"*/
field Status_ as integer /*xml-node-name "Status"*/
field DateIn as date
field TimeIn as character
field DateOut as date
field TimeOut as character
field SizeInBytes as integer
field MessageClass as character
index pi is unique primary EXiteICID
.


define dataset Status__{1}
for
Status_{1}
.

/* $Workfile$ e n d */