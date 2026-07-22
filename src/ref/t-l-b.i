/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный буфер для справочника клиентов

Автор: Чернова Светлана Александровна
Дата создания: 10/01/07
Author: Svetlana Chernova
Creation date: 10/01/07

*/

 define {1} temp-table temp-list-buyer no-undo ~
field obj-type as character ~
field obj-code as integer   ~
index pi is primary unique  ~
obj-type ~
obj-code.

 /* $Workfile$ e n d */