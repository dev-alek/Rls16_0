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

&scop proc-name libchkvl_get-cash-shift
{&run_proc_libchkvl}
  (input  {1} /* p-context-bh */
  ,buffer {2} /* buf_shift-cash*/
  ,input  {3} /* p-cash-num */
  ,input  {4} /*p-shift-date*/
  ,input  {5} /*p-shift-name*/
  ,input {6} /*p-z-number*/
  ,input {7} /* p-chk-date */
  ,input {8} /* p-chk-time */
  ,input {9} /*p-shift-open-time*/
    ) {10} .


/* $Workfile$ e n d */