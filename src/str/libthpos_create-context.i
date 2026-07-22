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

&scop proc-name libthpos_create-context
{&run_proc_libthpos}
  (input  {1} /*parparentproc может быть ?*/
  ,input  {2} /*p-log-handle может быть ?*/
  ,input  {3} /* p-db-num  */
  ,input  {4} /* p-obj-code  */
  ,input  {5} /* p-pos-type */
  ,input  {6} /* p-cash-num */
  ,output {7} /* p-serial-code */
  ,output {8} /* p-r-b */
  ,output {9} /* p-base-code */
  ) {10} .


/* $Workfile$ e n d */