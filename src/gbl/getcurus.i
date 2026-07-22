/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определить текущую базу данных и пользовател

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 07/25/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name getcurus
{&run_proc_library2}
  (output {1} /* p-db-num     */
  ,output {2} /* p-user-id    */
  ) {3} .
/* $Workfile$ e n d */