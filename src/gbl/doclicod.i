/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает код товара для строки документа

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/21/03

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name doclicod
{&run_proc_library}
  (input  {1} /* p-doc-line-recid */
  ,output {2} /* p-gds-code       */
  ) {3} .
/* $Workfile$ */