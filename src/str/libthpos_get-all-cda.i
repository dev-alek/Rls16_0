/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение всех параметров в виде DS

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/08
Author: Bakhtadze Natalya
Creation date: 07/16/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&scop proc-name libthpos_get-all-cda
{&run_proc_libthpos}
  (input  {1} /* p-db-num  */
  ,input  {2} /* p-obj-code  */
  ,input  {3} /* p-pos-type */
  ,input  {4} /* p-cash-num */
  ,output dataset {5} /*p-ds-params*/
  ) {6} .

/* $Workfile$ e n d */