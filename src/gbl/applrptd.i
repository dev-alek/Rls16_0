/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Применимы профайлы для расчета скидок по накладным

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/13/07
Author: Bakhtadze Natalya
Creation date: 12/13/07

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name apply-rptrndoc
{&run_proc_library}
  ( buffer  {1} /* parameter buffer buf_trn-doc  */
   ,output  {2} /* p-applicable  */
  ) {3} .
/* $Workfile$ e n d */