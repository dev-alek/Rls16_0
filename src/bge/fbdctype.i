/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Массив для работы с типами документов для системы КЛИЕНТ-БАНК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/22/04
Author: Bakhtadze Natalya
Creation date: 04/22/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define fdoctype-bank-extent 3
&global-define fdoctype-bank-types-amount 1

define variable v-fdoctype-bank-type-list as character extent {&fdoctype-bank-extent} init
[

    "расходное платежное поручение"        ,     {&FDEDT_Expense_Cashless} ,   "ei"

] no-undo.

/* $Workfile$ e n d */