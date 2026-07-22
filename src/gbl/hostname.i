/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение кода фирмы и имени фирмы для объекта или самой фирмы

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name hostname
{&run_proc_library}
  (input  {1} /* p-obj-type  */
  ,input  {2} /* p-obj-code  */
  ,output {3} /* p-host-code */
  ,output {4} /* p-host-name */
  ) {5} .
/* $Workfile$ e n d */