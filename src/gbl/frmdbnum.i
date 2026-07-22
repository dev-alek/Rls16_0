/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение № БД для фирмы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/03/07
Author: Bakhtadze Natalya
Creation date: 05/03/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name frmdbnum
{&run_proc_library2}
  (input  {1} /* p-host-code  */
  ,output {2} /* p-firm-db-num */
  ) {3} .
/* $Workfile$ e n d */