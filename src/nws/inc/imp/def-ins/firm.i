/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Опеределения для приема фирмы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/30/03
Author: Bakhtadze Natalya
Creation date: 06/30/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-l as logical no-undo .
define buffer buf_dis-card for ub.dis-card .

/* $Workfile$ e n d */