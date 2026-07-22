/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы для отчета о выручке с выбором интервалов времени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


DEFINE {1} TEMP-TABLE times NO-UNDO
FIELD time1 as integer
FIELD time2 as integer
FIELD times as char
INDEX pi IS PRIMARY UNIQUE time1 time2
INDEX ps times.