/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запросить текущую дату на объекте

Автор: Перваков Михаил Сергеевич
Дата создания: 01/25/02
Author: Mikhail Pervakov
Creation date: 01/25/02

Если дата не задана, то возвращается ошибка

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name objdtget
{&run_proc_library}
  (input  {1} /* p-obj-type */
  ,input  {2} /* p-obj-code */
  ,output {3} /* p-sys-date */
  ) {4} .
/* $Workfile$ e n d */