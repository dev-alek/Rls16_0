/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание временной таблички в которой живут расширенные типы

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 11/05/02 1:45
требует наличие
gn-extp.i

*/

create tdedt.
assign tdedt.id =  {1}
       tdedt.n  = "{2}"
.
{ rep/gn-ext.i tdedt.id  false  tdedt.name }

/* $Workfile$ E n d */