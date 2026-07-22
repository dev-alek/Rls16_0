/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Установить уровень логировни

Автор: Белоусов Илья Александрович
Дата создания: 12/11/08
Author: Ilia Belousov
Creation date: 12/11/08

Input:

Output:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&scop proc-name eventlib-log-level
{&run_proc_eventlib}
  (input  {1} /* p-level   */
  ,output {2} /* p-ok      */
  ) {3} .

/* $Workfile$ e n d */