/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/11/08
Author: Bakhtadze Natalya
Creation date: 12/11/08

*/


define {1} temp-table temp-clients no-undo like ub.clients
field base-code as integer
field new-issue-code as integer
field deleted-sysconf as logical
.
define {1} temp-table temp-sysconf no-undo like ub.sysconf.


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".