/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматизированное формирование списка клиентов - толкач

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/13/05
Author: Bakhtadze Natalya
Creation date: 09/13/05

 no_app_help.i

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type       like ub.clients.obj-type no-undo .
define input parameter p-obj-code       like ub.clients.obj-code no-undo .

{ cmp/str-glbl.i }
{ cmp/library.i }
{ str/anyclist.i cli-list }

/* $Workfile$ e n d */