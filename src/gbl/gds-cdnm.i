/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает имя товара по коду

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name gds-cdnm
{&run_proc_library}
  (input  {1} /* p-gds-code */
  ,output {2} /* p-gds-name */
  ) {3} .
/* $Workfile$ e n d */