/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает код товара для партии

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 05/21/03

*/
&scop proc-name pargocod
{&run_proc_library}
  (input  {1} /* p-parts-recid */
  ,output {2} /* p-gds-code    */
  ) {3} .
/* $Workfile$ */