/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список товаров с возможностью задавать количество

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

Исаков Андрей Валерьевич
Created: 8.7.99

 no_app_help.i
*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .

{ str/any-list.i scn-list }