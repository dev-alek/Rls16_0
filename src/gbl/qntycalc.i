/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересчет количеств от одной единицы измерения к другой

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/
&scop proc-name qntycalc
{&run_proc_library}
  (input  {1} /* p-calc-method   */
  ,input  {2} /* p-cli-base-rate */
  ,input  {3} /* p-cli-qnty      */
  ,input  {4} /* p-doc-qnty      */
  ,output {5} /* p-new-cli-qnty  */
  ,output {6} /* p-new-doc-qnty  */
  ) {7} .
/* $Workfile$ e n d */