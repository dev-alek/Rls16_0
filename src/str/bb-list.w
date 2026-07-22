/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автоматизированное формирование списка РАЗНООБРАЗНЕЙШИХ КОДОВ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/09/05
Author: Bakhtadze Natalya
Creation date: 02/09/05

no_app_help.i
*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-caller as character no-undo .

{ cmp/trg-def.i }
{ str/anyblist.i bb-list }

/* $Workfile$ e n d */