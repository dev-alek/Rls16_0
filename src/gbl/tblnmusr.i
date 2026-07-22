/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает пользовательское имя таблицы

Автор: Перваков Михаил Сергеевич
Дата создания: 05/27/03
Author: Mikhail Pervakov
Creation date: 05/27/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name tblnmusr
{&run_proc_library}
  (input  {1} /* p-table-name */
  ,output {2} /* p-user-name  */
  ) {3} .
/* $Workfile$ e n d */