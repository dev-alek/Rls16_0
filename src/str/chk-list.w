/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматизированное формирование списка чеков и чеков МЦ - толкач

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/02/04
Author: Bakhtadze Natalya
Creation date: 03/02/04

no_app_help.i

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
/*текущий код фирмы - в том числе в АРМ финансы*/

{ str/anchlist.i chk-list }

/* $Workfile$ e n d */