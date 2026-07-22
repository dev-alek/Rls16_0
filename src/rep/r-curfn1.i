/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет Текущее состояние финансов

Автор: Демин Алексей Сергеевич
Дата создания: 09/13/05
Author: Alexey Demin
Creation date: 09/13/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  find first buf_currency no-lock where buf_currency.curr-code = buf_fin-schet.curr-code .

  create temp-DiscSales .
  assign
    temp-DiscSales.name = buf_fin-schet.r-schet
    temp-DiscSales.code = buf_fin-schet.code-schet
    temp-DiscSales.curr = buf_currency.curr-abbr
    temp-DiscSales.nal  = no
  .

  /* сначала считаем безнал приходы */
  /* в валюте счета */
  find last buf_arh-fin-doc-schet no-lock
    where buf_arh-fin-doc-schet.host-code        = buf_fin-schet.host-code
      and buf_arh-fin-doc-schet.code-schet       = buf_fin-schet.code-schet
      and buf_arh-fin-doc-schet.cli-code         = buf_fin-schet.host-code
      and buf_arh-fin-doc-schet.cli-type         = {&cmp}
      and buf_arh-fin-doc-schet.fin-ext-doc-type = {&FDEDT_Income_cashless}
      and buf_arh-fin-doc-schet.calc-curr-code   = buf_fin-schet.curr-code
      and buf_arh-fin-doc-schet.sum-type         = ""
      and buf_arh-fin-doc-schet.fact-order      <= v-fact-order
   no-error .
  if available buf_arh-fin-doc-schet then assign  temp-DiscSales.sum-doc = buf_arh-fin-doc-schet.income .

  /* в  р у б л я х  */
  find last buf_arh-fin-doc-schet no-lock
    where buf_arh-fin-doc-schet.host-code        = buf_fin-schet.host-code
      and buf_arh-fin-doc-schet.code-schet       = buf_fin-schet.code-schet
      and buf_arh-fin-doc-schet.cli-code         = buf_fin-schet.host-code
      and buf_arh-fin-doc-schet.cli-type         = {&cmp}
      and buf_arh-fin-doc-schet.fin-ext-doc-type = {&FDEDT_Income_Cashless}
      and buf_arh-fin-doc-schet.calc-curr-code   = 0
      and buf_arh-fin-doc-schet.sum-type         = ""
      and buf_arh-fin-doc-schet.fact-order      <= v-fact-order
   no-error .
  if available buf_arh-fin-doc-schet then assign temp-DiscSales.sum-rubl = buf_arh-fin-doc-schet.income  .

  /* в Б вал  */
  find last buf_arh-fin-doc-schet no-lock
    where buf_arh-fin-doc-schet.host-code        = buf_fin-schet.host-code
      and buf_arh-fin-doc-schet.code-schet       = buf_fin-schet.code-schet
      and buf_arh-fin-doc-schet.cli-code         = buf_fin-schet.host-code
      and buf_arh-fin-doc-schet.cli-type         = {&cmp}
      and buf_arh-fin-doc-schet.fin-ext-doc-type = {&FDEDT_Income_Cashless}
      and buf_arh-fin-doc-schet.calc-curr-code   = v-curr-r-b
      and buf_arh-fin-doc-schet.sum-type         = ""
      and buf_arh-fin-doc-schet.fact-order      <= v-fact-order
   no-error .
  if available buf_arh-fin-doc-schet then assign temp-DiscSales.sum-base = buf_arh-fin-doc-schet.income  .

  /* считаем безнал расходы */
  /* в валюте счета */
  find last buf_arh-fin-doc-schet no-lock
    where buf_arh-fin-doc-schet.host-code        = buf_fin-schet.host-code
      and buf_arh-fin-doc-schet.code-schet       = buf_fin-schet.code-schet
      and buf_arh-fin-doc-schet.cli-code         = buf_fin-schet.host-code
      and buf_arh-fin-doc-schet.cli-type         = {&cmp}
      and buf_arh-fin-doc-schet.fin-ext-doc-type = {&FDEDT_Expense_Cashless}
      and buf_arh-fin-doc-schet.calc-curr-code   = buf_fin-schet.curr-code
      and buf_arh-fin-doc-schet.sum-type         = ""
      and buf_arh-fin-doc-schet.fact-order      <= v-fact-order
   no-error .
  if available buf_arh-fin-doc-schet then assign temp-DiscSales.sum-doc = temp-DiscSales.sum-doc - buf_arh-fin-doc-schet.expense .

  /* в  р у б л я х  */
  find last buf_arh-fin-doc-schet no-lock
    where buf_arh-fin-doc-schet.host-code        = buf_fin-schet.host-code
      and buf_arh-fin-doc-schet.code-schet       = buf_fin-schet.code-schet
      and buf_arh-fin-doc-schet.cli-code         = buf_fin-schet.host-code
      and buf_arh-fin-doc-schet.cli-type         = {&cmp}
      and buf_arh-fin-doc-schet.fin-ext-doc-type = {&FDEDT_Expense_Cashless}
      and buf_arh-fin-doc-schet.calc-curr-code   = 0
      and buf_arh-fin-doc-schet.sum-type         = ""
      and buf_arh-fin-doc-schet.fact-order      <= v-fact-order
   no-error .
  if available buf_arh-fin-doc-schet then assign temp-DiscSales.sum-rubl = temp-DiscSales.sum-rubl - buf_arh-fin-doc-schet.expense  .

  /* в Б вал  */
  find last buf_arh-fin-doc-schet no-lock
    where buf_arh-fin-doc-schet.host-code        = buf_fin-schet.host-code
      and buf_arh-fin-doc-schet.code-schet       = buf_fin-schet.code-schet
      and buf_arh-fin-doc-schet.cli-code         = buf_fin-schet.host-code
      and buf_arh-fin-doc-schet.cli-type         = {&cmp}
      and buf_arh-fin-doc-schet.fin-ext-doc-type = {&FDEDT_Expense_Cashless}
      and buf_arh-fin-doc-schet.calc-curr-code   = v-curr-r-b
      and buf_arh-fin-doc-schet.sum-type         = ""
      and buf_arh-fin-doc-schet.fact-order      <= v-fact-order
   no-error .
  if available buf_arh-fin-doc-schet then assign temp-DiscSales.sum-base = temp-DiscSales.sum-base - buf_arh-fin-doc-schet.expense  .

/* $Workfile$ e n d */