/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание продавца

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/08
Author: Bakhtadze Natalya
Creation date: 07/16/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&scop proc-name libthpos_set-salesman
{&run_proc_libthpos}
  (input  {1} /* p-doc-code может быть "" */
  ,input  {2} /*p-line-num может быть 0*/
  ,input  {3} /* p-sales-man  */
  ,input  {4} /* p-salesman-psn-code */
  ,output {5} /* p-setted */
  ) {6} .

/* $Workfile$ e n d */