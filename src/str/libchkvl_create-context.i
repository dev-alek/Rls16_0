/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка валидности тип чека тип товара коливечство

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/17/08
Author: Bakhtadze Natalya
Creation date: 07/17/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libchkvl_create-context
{&run_proc_libchkvl}
  (input  {1} /* p-obj-type */
  ,input  {2} /* p-obj-code */
  ,input  {3} /* p-context-bh */
  ) {4} .

/* $Workfile$ e n d */
