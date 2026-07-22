/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить/задать атрибут МЦ на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name wthobjat
{&run_proc_library}
  (input  {1} /* p-obj-type         */
  ,input  {2} /* p-obj-code         */
  ,input  {3} /* p-wth-code         */
  ,input  {4} /* p-action           */
  ,output {5} /* p-return-attribute */
  ) {6} .
/* $Workfile$ */