/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение корневого признака товара по коду товара

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name gdsrtnod
{&run_proc_library}
  (input  {1} /* p-gds-code */
  ,output {2} /* p-root-node */
  ) {3} .
/* $Workfile$ e n d*/