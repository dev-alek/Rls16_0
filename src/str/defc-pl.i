/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временнаяы таблица по резервуарам и т.д. для отсылки на кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/07/05
Author: Bakhtadze Natalya
Creation date: 12/07/05

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table cash-place no-undo
like ub.place.

/* $Workfile$ e n d */