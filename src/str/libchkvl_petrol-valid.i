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

&scop proc-name libchkvl_petrol-valid
{&run_proc_libchkvl}
  (input  {1} /* p-chk-type */
  ,input  {2} /* p-line-num */
  ,input  {3} /* p-obj-type */
  ,input  {4} /* p-obj-code */
  ,input  {5} /* p-pos-type */
  ,input  {6} /*p-src-code*/
  ,input  {7} /*p-gds-code*/
  ,input  {8} /*p-unit-type*/
  ,input  {9} /*p-pump*/
  ,input  {10} /*p-nozzle-code*/
  ,output {11} /* p-valid */
  ,output {12} /* p-message */
  ,output {13} /*p-chr-err*/
  ) {14} .


/* $Workfile$ e n d */