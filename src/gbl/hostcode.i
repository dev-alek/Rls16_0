/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение кода фирмы для объекта

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name hostcode
{&run_proc_library}
  (input  {1} /* p-obj-type  */
  ,input  {2} /* p-obj-code  */
  ,output {3} /* p-host-code */
  ) {4} .
/* $Workfile$ e n d */