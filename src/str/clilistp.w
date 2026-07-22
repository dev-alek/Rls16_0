/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматизированное формирование списка клиентов c управлением извне

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/28/10
Author: Bakhtadze Natalya
Creation date: 01/28/10

no_app_help.i

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter bttns            as character no-undo .
/*опции показа кнопок TODO*/
define input parameter p-title          as character no-undo .
define input parameter p-keep-query     as logical no-undo .


{ str/anyclist.i cli-list managed }