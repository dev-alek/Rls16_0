/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить/задать атрибут товара на объекте  РЕСТОРАН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name fgdsobjt
{&run_proc_library}
  (input  {1} /* p-obj-type         */
  ,input  {2} /* p-obj-code         */
  ,input  {3} /* p-gds-code         */
  ,input  {4} /* p-action           */
  ,output {5} /* p-return-attribute - char*/
  ) {6} .
/* $Workfile$ */