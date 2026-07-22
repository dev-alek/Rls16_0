/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подготовка к работе с опциями истории и маршрутизации для {&c-dc-hist}

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/06
Author: Bakhtadze Natalya
Creation date: 10/31/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name lib-nws_clear-fill-option
{&run_proc_lib-nws}
  (input  {1} /* p-fill-option  */
  ) {3} .

/* $Workfile$ e n d */