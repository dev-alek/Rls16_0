/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание чека МЦ в АРМ кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/08
Author: Bakhtadze Natalya
Creation date: 07/16/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_create-chk-title
{&run_proc_libthpos}
  (input  {1} /* p-db-num  */
  ,input  {2} /* p-obj-code  */
  ,input  {3} /* p-pos-type */
  ,input  {4} /* p-cash-num */
  ,input  {5} /* p-chk-type */
  ,input  {6} /* p-cashier */
  ,input  {7} /* p-cashier-psn-code */
  ,output {8} /*p-doc-code*/
  ,output {9} /*p-exch-rate*/
  ,output {10} /*p-exch-scales*/
  ,output {11} /*p-cash-rate*/
  ,output {12} /*p-cash-scales*/
  ) {13} .


/* $Workfile$ e n d */