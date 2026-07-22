/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Способ резервирования документа в зависимости от типа и статуса

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 05/21/03

*/
&scop proc-name rsrvtype
{&run_proc_library}
  (input  {1} /* p-doc-code  */
  ,output {2} /* p-rsrv-type */
  ) {3} .
/* $Workfile$ */