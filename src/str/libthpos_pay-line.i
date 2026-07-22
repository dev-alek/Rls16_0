/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание чека в АРМ кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/08
Author: Bakhtadze Natalya
Creation date: 07/16/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_pay-line
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
  ,output {15} /*p-2-cdpay-code*/
  ,output {16} /*p-2-curr-code*/
  ,output {17} /*p-2-frpay-code*/
  ,output {18} /*p-2-tot-sum*/
  ,output {19} /*p-2-tot-rubl*/
  ,output {20} /*p-2-tot-base*/
  ,output {21} /*p-src-discnt-sum*/
  ,output {22} /*p-src-discnt-rubl*/
  ,output {23} /*p-for-discnt-doc*/
  ,output {24} /*p-for-discnt-rubl*/
  ,output {25} /*p-for-discnt-r-b*/
  ,output {26} /*p-setted*/
  ) {27} .

/* $Workfile$ e n d */