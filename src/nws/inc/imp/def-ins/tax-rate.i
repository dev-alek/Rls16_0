/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях ставок налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_tax for ub.tax.
define buffer buf_clients for ub.clients.
define buffer buf_shop    for ub.shop.

/* $Workfile$ e n d */