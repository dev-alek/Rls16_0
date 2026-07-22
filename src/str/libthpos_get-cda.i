/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение параметра

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/08
Author: Bakhtadze Natalya
Creation date: 07/16/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&scop proc-name libthpos_get-cda
{&run_proc_libthpos}
  (input  {1} /* p-db-num  */
  ,input  {2} /* p-obj-code  */
  ,input  {3} /* p-pos-type */
  ,input  {4} /* p-cash-num */
  ,input  {5} /* p-upper-attr-code */
  ,input  {6} /* p-attr-code */
  ,output {7} /*p-attr-value-character*/
  ,output {8} /*p-attr-value-date*/
  ,output {9} /*p-attr-value-decimal*/
  ,output {10} /*p-attr-value-integer*/
  ,output {11} /*p-attr-value-logical*/
  ,output {12} /*p-attr-value-type*/
  ) {13} .

/* $Workfile$ e n d */
