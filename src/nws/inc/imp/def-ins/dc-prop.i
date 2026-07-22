/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема свойств ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/16/07
Author: Bakhtadze Natalya
Creation date: 08/16/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-nws-to-cd as integer no-undo .
define buffer buf_dis-card for ub.dis-card.

/* $Workfile$ e n d */