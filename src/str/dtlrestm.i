/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отметки оператора о возможности увода в отриц остатки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/21/06
Author: Bakhtadze Natalya
Creation date: 04/21/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table dtl-rests-mark no-undo
field artic like ub.gds-dtl.artic
field prod-type like ub.gds-dtl.prod-type
field prod-code like ub.gds-dtl.prod-code
index   pi  is primary
artic
prod-type
prod-code
.

/* $Workfile$ e n d */