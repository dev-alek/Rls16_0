/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица работы с персоналом

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/29/06
Author: Bakhtadze Natalya
Creation date: 06/29/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table stf-list no-undo like ub.staff
field to-del     as logical
.

/* $Workfile$ */