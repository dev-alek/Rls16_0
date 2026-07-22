/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение консигнационного НДС для фирмы

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name hostcvat
{&run_proc_library}
  (input  {1} /* p-host-code  */
  ,output {2} /* p-cons-vat-pc */
  ) {3} .
/* $Workfile$ e n d */