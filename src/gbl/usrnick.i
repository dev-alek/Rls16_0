/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение псевдонима пользовател

Автор: Белоусов Илья Александрович
Дата создания: 11/12/07
Author: Ilia Belousov
Creation date: 11/12/07

Input:

Output:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name usrnick
{&run_proc_library}
  (input  {1} /* p-user-id        */
  ,output {2} /* p-nick */
  ) {3} .
/* $Workfile$ */