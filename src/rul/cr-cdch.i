/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/02/06
Author: Bakhtadze Natalya
Creation date: 11/02/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


define temp-table temp-hist-nws-option no-undo
like ub.hist-nws-option
.


/* $Workfile$ e n d */