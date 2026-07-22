/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определяет короткое имя документа для показа в интерфейсах

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name docextnm
{&run_proc_library}
  (input  {1} /* p-doc-code */
  ,output {2} /* p-ext-name */
  ) {3} .
/* $Workfile$ e n d */