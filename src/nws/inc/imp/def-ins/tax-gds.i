/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях налогов на товар

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_goods for ub.goods.

/* $Workfile$ e n d */