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

&scop proc-name libthpos_gds-line
{&run_proc_libthpos}
  (input  {1} /* p-doc-code  */
  ,input  {2} /* p-line-num  */
  ,input  {3} /* p-mode */
  ,input  {4} /* p-line-direction */
  ,input  {5} /* p-src-code */
  ,input-output  {6} /* p-src-qnty */
  ,input  {7} /* p-pump */
  ,input  {8} /* p-nozzle-code */
  ,input  {9} /* p-pl-code */
  ,input  {10} /* p-pass-gds */
  ,input  {11} /*p-write-off-code*/
  ,input  {12} /*p-depart-id*/
  ,output {13} /*p-setted*/
  ,output {14} /*p-next*/
  ,output {15} /*p-p-b-code*/
  ,output {16} /*p-gds-code*/
  ,output {17} /*p-chk-name*/
  ,output {18} /*p-second-name*/
  ,input-output {19} /*p-src-price*/
  ,output {20} /*p-src-price-rubl*/
  ,output {21} /*p-src-discnt-sum*/
  ,output {22} /*p-src-discnt-sum-rubl*/
  ,output {23} /*p-src-sum*/
  ,output {24} /*p-src-sum-rubl*/
  ,output {25} /*p-src-sum-netto*/
  ,output {26} /*p-src-sum-netto-rubl*/
  ,output {27} /*p-unit-base*/
  ) {28} .


/* $Workfile$ e n d */