/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборот финансов с разбивкой по основаниям

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/05
Author: Alexey Demin
Creation date: 09/14/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  find first buf_currency no-lock where buf_currency.curr-code = buf_fin-schet.curr-code .
  find first buf_fin-bank no-lock where buf_fin-bank.host-code = buf_fin-schet.host-code and buf_fin-bank.code-bank = buf_fin-schet.code-bank .

  create temp-schet .
  assign
    temp-schet.r-schet = buf_fin-schet.r-schet
    temp-schet.code    = buf_fin-schet.code-schet
    temp-schet.curr    = buf_fin-schet.curr-code
    temp-schet.s-curr  = buf_currency.curr-abbr
    temp-schet.bank    = buf_fin-bank.short-name
    jj = jj + 1
  .

  assign Counter1 = Counter1 + 1.
  { rep/repfrm.i disp Counter1 }
  /* считаем остаток на начало */
  /* приходы */
  run CalcOst (input {&income-cashless}, input buf_fin-schet.curr-code, input v-fact-order-start, output sum1) .
  assign temp-schet.sum1 = sum1 .  /* в валюте счета */
  run CalcOst (input {&income-cashless}, input 0, input v-fact-order-start, output sum1) .
  assign  ost-beg-rubl = ost-beg-rubl + sum1 .  /* в  р у б л я х */
  run CalcOst (input {&income-cashless}, input v-curr-r-b, input v-fact-order-start, output sum1) .
  assign  ost-beg-base = ost-beg-base + sum1 .  /* в Б вал  */
  /* расходы */
  run CalcOst (input {&expense-cashless}, input buf_fin-schet.curr-code, input v-fact-order-start, output sum1) .
  assign temp-schet.sum1 = temp-schet.sum1 - sum1 .  /* в валюте счета */
  run CalcOst (input {&expense-cashless}, input 0, input v-fact-order-start, output sum1) .
  assign  ost-beg-rubl = ost-beg-rubl - sum1 .  /* в  р у б л я х */
  run CalcOst (input {&expense-cashless}, input v-curr-r-b, input v-fact-order-start, output sum1) .
  assign  ost-beg-base = ost-beg-base - sum1 .  /* в Б вал  */

  /* считаем остаток на конец */
  /* приходы */
  run CalcOst (input {&income-cashless}, input buf_fin-schet.curr-code, input v-fact-order-end, output sum1) .
  assign temp-schet.sum2 = sum1 .  /* в валюте счета */
  run CalcOst (input {&income-cashless}, input 0, input v-fact-order-end, output sum1) .
  assign  ost-end-rubl = ost-end-rubl + sum1 .  /* в  р у б л я х */
  run CalcOst (input {&income-cashless}, input v-curr-r-b, input v-fact-order-end, output sum1) .
  assign  ost-end-base = ost-end-base + sum1 .  /* в Б вал  */
  /* расходы */
  run CalcOst (input {&expense-cashless}, input buf_fin-schet.curr-code, input v-fact-order-end, output sum1) .
  assign temp-schet.sum2 = temp-schet.sum2 - sum1 .  /* в валюте счета */
  run CalcOst (input {&expense-cashless}, input 0, input v-fact-order-end, output sum1) .
  assign  ost-end-rubl = ost-end-rubl - sum1 .  /* в  р у б л я х */
  run CalcOst (input {&expense-cashless}, input v-curr-r-b, input v-fact-order-end, output sum1) .
  assign  ost-end-base = ost-end-base - sum1 .  /* в Б вал  */

/* $Workfile$ e n d */