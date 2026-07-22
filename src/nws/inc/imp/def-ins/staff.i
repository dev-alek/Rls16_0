/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием записи staff в СПИ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/04/06
Author: Bakhtadze Natalya
Creation date: 07/04/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-import as logical no-undo init yes.
define buffer buf_staff for ub.staff .

/* $Workfile$ e n d */