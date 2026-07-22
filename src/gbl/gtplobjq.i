/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сколько главных типов прайс листа по объекту

Автор: Чернова Светлана Александровна
Дата создания: 05/12/06
Author: Svetlana Chernova
Creation date: 05/12/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name gtplobjq
{&run_proc_library2}
  (input  {1} /* p-obj-type   */
  ,input  {2} /* p-obj-code   */
  ,output {3} /* p-plt-id     */
  ,output {4} /* p-plt-db-num */
  ,output {5} /* p-col */
  ) {6} .

/* $Workfile$ e n d */