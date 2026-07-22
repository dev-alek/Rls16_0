/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание строки номинала в АРМ кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/21/08
Author: Bakhtadze Natalya
Creation date: 08/21/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_par-line
{&run_proc_libthpos}
  (input  {1} /* p-doc-code  */
  ,input  {2} /* p-line-num  */
  ,input  {3} /* p-ppline-num  */
  ,input  {4} /* p-mode */
  ,input  {5} /* p-cdpay-code */
  ,input  {6} /* p-curr-code */
  ,input  {7} /*p-par-val*/
  ,input  {8} /*p-doc-qnty*/
  ,input  {9} /* p-pass-pay */
  ,output  {10} /* p-tot-sum */
  ,output  {11} /* p-tot-rubl */
  ,output  {12} /* p-tot-base */
  ,output {13} /*p-setted*/
  ) {14} .


/* $Workfile$ e n d */