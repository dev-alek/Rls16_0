/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Особождение памяти от COM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if valid-handle({1}) then
RELEASE OBJECT {1} no-error.

/* $Workfile$ e n d */