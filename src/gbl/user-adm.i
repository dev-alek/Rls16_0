/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверить, что пользователь является администратором

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 07/25/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name user-adm
{&run_proc_library2}
  (input  {1} /* p-db-num     */
  ,input  {2} /* p-user-id    */
  ,output {3} /* p-user-admin */
  ) {4} .
/* $Workfile$ e n d */