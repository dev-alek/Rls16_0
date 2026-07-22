/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение текущего курса на определенную дату

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name baserate
{&run_proc_library}
  (input  {1} /* p-host-code  */
  ,input  {2} /* p-curr-date  */
  ,output {3} /* p-base-rate  */
  ,output {4} /* p-base-scale */
  ) {5} .
/* $Workfile$ e n d */