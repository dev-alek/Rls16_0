/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка Ассортиментной матрицы и ИЖТ товара на объекте

Автор: Чернова Светлана Александровна
Дата создания: 04/16/07
Author: Svetlana Chernova
Creation date: 04/16/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name goassizt
{&run_proc_library2}
  (input  {1} /* p-event-code  */
  ,input  {2} /* p-gds-code    */
  ,input  {3} /* p-obj-type    */
  ,input  {4} /* p-obj-code    */
  ,input  {5} /* p-ask         */
  ,output {6} /* p-Ok          */
  ,output {7} /* p-mess        */
  ) {8}.