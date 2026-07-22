/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определяет тип документа межфирменный или обычный

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name hold-doc
{&run_proc_library}
  (input  {1} /* p-doc-code */
  ,output {2} /* p-is-hold */
  ) {3} .
/* $Workfile$ e n d */