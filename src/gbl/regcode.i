/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение кода региона для БД

Автор: Белова Марина Михайловна
Дата создания: 04/06/26
Author: Marina Belova
Creation date: 04/06/26

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name regcode
{&run_proc_library}
  (input  {1} /* p-obj-type  */
  ,input  {2} /* p-obj-code  */
  ,output {3} /* p-reg-code */
  ) {4} .
/* $Workfile$ e n d */