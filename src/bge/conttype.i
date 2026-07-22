/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Массив для работы с типами документов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/22/04
Author: Bakhtadze Natalya
Creation date: 04/22/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define conttype-extent 4
&global-define conttype-types-amount 2

define variable v-conttype-type-list as character extent {&conttype-extent} init
[
   "с поставщиками",                  {&income},
   "с покупателями",                  {&expense}
] no-undo.

/* $Workfile$ e n d */