/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Найти любой объект, доступный пользователю

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 07/25/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name usobjany
{&run_proc_library2}
  (input  {1} /* p-db-num           */
  ,input  {2} /* p-action-head-code */
  ,input  {3} /* p-user-id          */
  ,output {4} /* p-obj-type         */
  ,output {5} /* p-obj-code         */
  ,output {6} /* p-obj-available        */
  ) {7} .
/* $Workfile$ e n d */