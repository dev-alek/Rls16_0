/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Поствалидация чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/27/08
Author: Bakhtadze Natalya
Creation date: 07/27/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_getcheck
{&run_proc_libthpos}
  (input  {1} /* p-doc-code  */
  ,input  {2} /* p-close-check  */
  ) {3} .


/* $Workfile$ e n d */