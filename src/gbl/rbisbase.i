/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает логическую переменную: валюта продажи - базова

Автор: Перваков Михаил Сергеевич
Дата создания: 06/27/03
Author: Mikhail Pervakov
Creation date: 06/27/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name rbisbase
{&run_proc_library}
  (output {1} /* p-rb-is-base */
  ) {2} .
/* $Workfile$ e n d */