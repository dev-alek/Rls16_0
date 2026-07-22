/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

кусок реестра

Автор: Чернова Светлана Александровна
Дата создания: 03/21/06
Author: Svetlana Chernova
Creation date: 03/21/06

*/
for each tmp#tax{1} : delete tmp#tax{1}. end.
for each acc#tax{1} :
  create tmp#tax{1}.
  assign tmp#tax{1}.type   = acc#tax{1}.type
        tmp#tax{1}.pc      = acc#tax{1}.pc
        tmp#tax{1}.sum     = acc#tax{1}.sum.
end.
{2} = acc-{2}.