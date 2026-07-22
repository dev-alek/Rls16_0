/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функции работы с историей и маршрутизацией через классы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/25/07
Author: Bakhtadze Natalya
Creation date: 02/25/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table temp-hist-nws-option no-undo
like ub.hist-nws-option
.


/* $Workfile$ e n d */