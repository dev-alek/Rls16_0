/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка валидности код-списания<->тип чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/17/08
Author: Bakhtadze Natalya
Creation date: 07/17/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libchkvl_chk-gds-wro
{&run_proc_libchkvl}
  (input  {1} /* p-chk-type */
  ,input  {2} /* p-line-num */
  ,input  {3} /* p-src-qnty */
  ,input  {4} /* p-wro-code */
  ,output {5} /* p-valid */
  ,output {6} /* p-message */
  ) {7} .


/* $Workfile$ e n d */