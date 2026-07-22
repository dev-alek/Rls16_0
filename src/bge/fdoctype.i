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

&global-define fdoctype-extent 18
&global-define fdoctype-types-amount 6

define variable v-fdoctype-type-list as character extent {&fdoctype-extent} init
[
     "приходный кассовый ордер"             ,     {&FDEDT_Income_Cash}      ,   "ic"
  ,  "расходный кассовый ордер"             ,     {&FDEDT_Expense_Cash}     ,   "ec"
  ,  "приходное платежное поручение"        ,     {&FDEDT_Income_Cashless}  ,   "ii"
  ,  "расходное платежное поручение"        ,     {&FDEDT_Expense_Cashless} ,   "ei"
  ,  "приходный АПЗ"                        ,     {&FDEDT_Income_Payoff}    ,   "io"
  ,  "расходный АПЗ"                        ,     {&FDEDT_Expense_Payoff}   ,   "eo"

] no-undo.

/* $Workfile$ e n d */