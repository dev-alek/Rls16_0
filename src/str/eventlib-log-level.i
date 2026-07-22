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
  ,output {2} /*p-attr-value-type*/
  ) {3} .

/* $Workfile$ e n d */