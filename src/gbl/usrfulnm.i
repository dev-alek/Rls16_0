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

Внимание! Процедура возвращает ПСЕВДОНИМ.

Для получения строки имя-фамилия-отчество пользуйтесь процедурой usrfuln2 !


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name usrfulnm
{&run_proc_library}
  (input  {1} /* p-user-id      */
  ,output {2} /* p-nik          */
  ) {3} .
/* $Workfile$ */