/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает первичный приход партии

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 05/21/03

*/
&scop proc-name proridoc
{&run_proc_library}
  (input  {1} /* p-in-code        */
  ,input  {2} /* p-gds-code       */
  ,input  {3} /* p-part-code      */
  ,output {4} /* p-orig-in-code   */
  ,output {5} /* p-orig-gds-code  */
  ,output {6} /* p-orig-part-code */
  ) {7} .
/* $Workfile$ */