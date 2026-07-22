/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Поиск маргаринов на объекте

Автор: Чернова Светлана Александровна
Дата создания: 05/12/06
Author: Svetlana Chernova
Creation date: 05/12/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name gtplpnakl
{&run_proc_library2}
  (input  {1} /* p-handle     */
  ,input  {2} /* p-obj-type   */
  ,input  {3} /* p-obj-code   */
  ,output {4} /* p-nakl-ie    */
  ,output {5} /* p-nakl-iv    */
  ,output {6} /* p-nakl-im    */
  ) {7} .
/* $Workfile$ e n d */