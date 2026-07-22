/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменился ли цена бар-кода

Автор: Чернова Светлана Александровна
Дата создания: 03/26/10
Author: Svetlana Chernova
Creation date: 03/26/10

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name ichprise
{&run_proc_library2}
  (input  {1} /* p-b-code  */
  ,input  {2} /* p-doc-num */
  ,output {3} /* p-is-ok   */
  ) {4} .
