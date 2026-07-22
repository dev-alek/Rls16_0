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

&scop proc-name libchkvl_prt-valid
{&run_proc_libchkvl}
  (input  {1} /* p-chk-type */
  ,input  {2} /* p-line-num */
  ,input  {3} /*p-doc-prt*/
  ,input  {4} /*p-src-code*/
  ,input  {5} /* p-empty-scale*/
  ,input  {6} /* p-root-node-code*/
  ,input  {7} /* p-node-code*/
  ,output {8} /* p-valid */
  ,output {9} /* p-message */
  ,output {10} /*p-chr-err*/
  ) {11} .


/* $Workfile$ e n d */