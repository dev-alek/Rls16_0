/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ручная скидка на итог в АРМ кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/19/08
Author: Bakhtadze Natalya
Creation date: 08/19/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_set-subtotal-manual-discnt
{&run_proc_libthpos}
  (input  {1} /* p-doc-code*/
  ,input  {2} /*p-value-type*/
  ,input  {3} /*p-discnt-value*/
  ,output {4} /* p-setted  */
  ,output {5} /* p-next  */
  ,input-output {6} /* p-st-r-b  */
  ,input-output {7} /* p-st-rubl  */
  ,input-output {8} /* p-st-base  */
  ,input-output {9} /* p-tot-doc брутто*/
  ,input-output {10} /* p-discnt  - товарная скидка + скидка на итог*/
  ) {11} .


/* $Workfile$ e n d */