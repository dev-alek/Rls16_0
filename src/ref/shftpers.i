/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы для персонала смены

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table shft-pers no-undo
FIELD FIO as CHARACTER format "X(40)"
FIELD staff-role AS LOGICAL format "+/ "
FIELD psn-code like ub.person.psn-code
FIELD cashier  as integer
FIELD next-shift as logical /*no текущая yes принимающая*/
field psn-num like ub.shift-staff.psn-num
index staff-role is primary next-shift
                            staff-role DESCENDING
index pc is unique next-shift psn-code psn-num
.


/* $Workfile$ e n d */