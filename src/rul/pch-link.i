/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица, описывающая звенья цепи процесса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/24/08
Author: Bakhtadze Natalya
Creation date: 02/24/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table temp-pchain-link-rule no-undo
field pchain-type as character
field pchain-id as character
field start-from as integer /*0 -DB0 1 -RDB*/
field link-id as integer
field codex_id as integer
field ruleset_id as integer
field run-DB0 as integer
field run-RDB as integer
field order_id as integer
field rule_id as integer
field profile_id as integer
field once-more as integer
field can-calc as logical
field can-run as logical
field link-btwn-profiles as integer /* при выполнении запускаются правила всех привязанных профайлов или избранное */
index pi is unique primary
pchain-type
pchain-id
start-from
link-id
order_id
.



/* $Workfile$ e n d */