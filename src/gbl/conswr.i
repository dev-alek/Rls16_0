/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вывести сообщение на консоль

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name conswr
{&run_proc_conswrlb}
  (input  {1} /* p-console-message */
  ) {2} .
/* $Workfile$ */