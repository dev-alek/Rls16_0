/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание карты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/08
Author: Bakhtadze Natalya
Creation date: 07/16/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&scop proc-name libthpos_set-card
{&run_proc_libthpos}
  (input  {1} /* p-doc-code  */
  ,input  {2} /* p-src-d-card  */
  ,output {3} /* p-d-card */
  ,output {4} /* p-cli-type */
  ,output {5} /* p-cli-code */
  ,output {6} /* p-obj-name */
  ) {7} .

/* $Workfile$ e n d */