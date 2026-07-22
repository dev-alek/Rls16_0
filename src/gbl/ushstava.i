/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверить, что пользователю доступна фирма

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 10/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name ushstava
{&run_proc_library2}
  (input  {1} /* p-db-num           */
  ,input  {2} /* p-action-head-code */
  ,input  {3} /* p-user-id          */
  ,input  {4} /* p-host-code        */
  ,output {5} /* p-host-available   */
  ) {6} .
/* $Workfile$ e n d */