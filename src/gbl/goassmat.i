/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка вхождения в Ассортиментную МАТРИЦУ

Автор: Чернова Светлана Александровна
Дата создания: 04/16/07
Author: Svetlana Chernova
Creation date: 04/16/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name goassmat
{&run_proc_library2}
  (input  {1} /* p-gds-code    */
  ,input  {2} /* p-obj-type    */
  ,input  {3} /* p-obj-code    */
  ,input  {4} /* p-ask         */
  ,output {5} /* p-Ok          */
  ,output {6} /* p-mess        */
  ) {7} .