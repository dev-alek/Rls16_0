/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает имя таблицы по пользовательскому имени таблицы

Автор: Перваков Михаил Сергеевич
Дата создания: 05/27/03
Author: Mikhail Pervakov
Creation date: 05/27/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name tblusrnm
{&run_proc_library}
  (input  {1} /* p-user-name  */
  ,output {2} /* p-table-name */
  ) {3} .
/* $Workfile$ e n d */