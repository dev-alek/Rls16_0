/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка валидности тип чека тип товара коливечство

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/17/08
Author: Bakhtadze Natalya
Creation date: 07/17/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libchkvl_fbr-valid
{&run_proc_libchkvl}
  (input  {1} /* p-chk-type */
  ,input  {2} /* p-line-num */
  ,input  {3} /* p-obj-type */
  ,input  {4} /* p-obj-code */
  ,input  {5} /*p-is-catering*/
  ,input  {6} /*p-pos-type*/
  ,input  {7} /*p-src-code*/
  ,input  {8} /*p-gds-code*/
  ,input  {9} /*p-src-price*/
  ,input  {10} /*p-src-discnt*/
  ,input  {11} /*p-write-off-code*/
  ,input-output  {12} /* p-depart-type*/
  ,input-output  {13} /* p-depart-code*/
  ,output {14} /*p-is-null-price*/
  ,output {15} /* p-valid */
  ,output {16} /* p-message */
  ,output {17} /*p-chr-err*/
  ) {18} .


/* $Workfile$ e n d */