/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подсчет подитога по чеку

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/21/08
Author: Bakhtadze Natalya
Creation date: 07/21/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_sub-total
{&run_proc_libthpos}
  (input  {1} /* p-doc-code*/
  ,input  {2} /*p-mode - может быть "no-changes" или ""*/
  ,output {3} /* p-setted  */
  ,input-output {4} /* p-st-r-b  */
  ,input-output {5} /* p-st-rubl  */
  ,input-output {6} /* p-st-base */
  ,input-output {7} /* p-tot-doc */
  ,input-output {8} /* p-st-discnt */
  ,output {9} /*p-netto*/
  ,output {10} /*p-netto-rubl*/
  ,output {11} /*p-netto-base*/
  ,output {12} /*p-all-discnt*/
  ,output {13} /*p-all-discnt-rubl*/
  ,output {14} /*p-all-discnt-base*/
  ) {15} .


/* $Workfile$ e n d */