/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Установка процедуры для логгировани

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/31/08
Author: Bakhtadze Natalya
Creation date: 07/31/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_set-log
{&run_proc_libthpos}
  (input  {1} /* p-log-handle  */
  ) {2} .


/* $Workfile$ e n d */