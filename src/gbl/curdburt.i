/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает текущий номер базы данных, пользователя, дату, время и количество секунд

Автор: Перваков Михаил Сергеевич
Дата создания: 05/21/03
Author: Mikhail Pervakov
Creation date: 05/21/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name curdburt
{&run_proc_library}
  (output {1} /* p-db-num       */
  ,output {2} /* p-user-name    */
  ,output {3} /* p-sys-date     */
  ,output {4} /* p-sys-time     */
  ,output {5} /* p-sys-time-int */
  ) {6} .
/* $Workfile$ */