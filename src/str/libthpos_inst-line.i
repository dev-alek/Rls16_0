/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание строки чека МЦ в АРМ кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/08
Author: Bakhtadze Natalya
Creation date: 07/16/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_inst-line
{&run_proc_libthpos}
  (input  {1} /* p-doc-code  */
  ,input  {2} /* p-line-num  */
  ,input  {3} /* p-mode */
  ,input-output  {4} /* p-cdpay-code */
  ,input-output  {5} /* p-curr-code */
  ,input  {6} /*p-par-code*/
  ,input  {7} /*p-src-qnty*/
  ,output {8} /*p-frpay-code*/
  ,input  {9} /* p-pass-pay */
  ,input  {10} /* p-pay-card */
  ,input-output  {11} /* p-tot-sum */
  ,input-output  {12} /* p-tot-rubl */
  ,input-output  {13} /* p-tot-base */
  ,output {14} /*p-get-qnty-method*/
  ,output {15} /*p-setted*/
  ) {16} .

/* $Workfile$ e n d */