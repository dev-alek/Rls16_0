/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Номер текущей базы данных

Автор: Перваков Михаил Сергеевич
Дата создания: 05/21/03
Author: Mikhail Pervakov
Creation date: 05/21/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name curdbnum
{&run_proc_library}
  (output {1} /* p-db-num */
  ) {2} .
/* $Workfile$ */