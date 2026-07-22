/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание чека в АРМ кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/21/08
Author: Bakhtadze Natalya
Creation date: 07/21/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_set-gds-manual-discnt
{&run_proc_libthpos}
  (input  {1} /* p-doc-code*/
  ,input  {2} /*p-line-num*/
  ,input  {3} /*p-value-type*/
  ,input  {4} /*p-discnt-value*/
  ,output {5} /* p-setted  */
  ,output {6} /* p-next  */
  ,input-output {7} /* p-src-discnt-sum  */
  ,input-output {8} /* p-src-sum  */
  ,input-output {9} /* p-src-sum-netto */
  ) {10} .


/* $Workfile$ e n d */