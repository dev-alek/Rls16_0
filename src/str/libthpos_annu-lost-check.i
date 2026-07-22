/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отложить чек

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/24/08
Author: Bakhtadze Natalya
Creation date: 10/24/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_annu-lost-check
{&run_proc_libthpos}
  (input  {1} /* p-doc-code  */
  ) {2} .


/* $Workfile$ e n d */