/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Номер текущей смены

Автор: Перваков Михаил Сергеевич
Дата создания: 11/20/00
Author: Mikhail Pervakov
Creation date: 11/20/00

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name curshift
{&run_proc_library}
  (input  {1} /* p-obj-type   */
  ,input  {2} /* p-obj-code   */
  ,output {3} /* p-shift-date */
  ,output {4} /* p-shift-num  */
  ,output {5} /* p-shift-name */
  ) {6} .
/* $Workfile$ e n d */