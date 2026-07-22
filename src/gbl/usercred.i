/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение идентификатора для проверки прав

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 07/25/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name usercred
{&run_proc_library2}
  (input  {1} /* p-db-num              */
  ,input  {2} /* p-user-id             */
  ,output {3} /* p-check-db-num        */
  ,output {4} /* p-check-user-id       */
  ,output {5} /* p-check-administrator */
  ) {6} .
/* $Workfile$ e n d */