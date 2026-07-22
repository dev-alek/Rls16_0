/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определяет тип партии - порожденная да/нет, старый возврат да/нет

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 07/09/03

*/
&scop proc-name partparm
{&run_proc_library}
  (input  {1} /* p-parts-recid */
  ,output {2} /* p-create-part */
  ,output {3} /* p-old-return  */
  ,output {4} /* p-create-obj  */
  ) {5} .
/* $Workfile$ e n d */