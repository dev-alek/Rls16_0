/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматизированное формирование списка товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/05
Author: Bakhtadze Natalya
Creation date: 10/31/05

Author: Исаков Андрей Валерьевич
Created: 6.6.95
no_app_help.i

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .

{ str/any-list.i gds-list }