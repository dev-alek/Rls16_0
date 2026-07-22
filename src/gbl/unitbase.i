/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение базовой единицы измерения товара

Автор: Перваков Михаил Сергеевич
Дата создания: 05/07/01
Author: Mikhail Pervakov
Creation date: 05/07/01

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name unitbase
{&run_proc_library}
  (input  {1} /* p-gds-code  */
  ,output {2} /* p-unit-base */
  ) {3} .
/* $Workfile$ */