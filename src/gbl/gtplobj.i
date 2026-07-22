/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Поиск главного типа прайс листа по объекту

Автор: Чернова Светлана Александровна
Дата создания: 05/12/06
Author: Svetlana Chernova
Creation date: 05/12/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name gtplobj
{&run_proc_library2}
  (input  {1} /* p-handle     */
  ,input  {2} /* p-obj-type   */
  ,input  {3} /* p-obj-code   */
  ,input  {4} /* p-only-gbg   */
  ,output {5} /* p-plt-id     */
  ,output {6} /* p-plt-db-num */
  ) {7} .
/* $Workfile$ e n d */