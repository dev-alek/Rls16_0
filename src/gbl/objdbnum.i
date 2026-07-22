/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить номер базы данных объекта

Автор: Перваков Михаил Сергеевич
Дата создания: 05/21/03
Author: Mikhail Pervakov
Creation date: 05/21/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name objdbnum
{&run_proc_library}
  (input  {1} /* p-obj-type */
  ,input  {2} /* p-obj-code */
  ,output {3} /* p-db-num   */
  ) {4} .
/* $Workfile$ */