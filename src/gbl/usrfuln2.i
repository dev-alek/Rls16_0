/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Имя пользовател

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/21/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name usrfuln2
{&run_proc_library}
  (input  {1} /* p-user-id        */
  ,output {2} /* p-full-user-name */
  ) {3} .
/* $Workfile$ */