/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение первичного бар-кода партии

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

buf_parts   буфер партии
v-b-code    бар-код

В случае, если бар-код не найден - на экран не выводится никаких сообщений,
возвращается ошибка и строка, описывающая ошибку

*/
&scop proc-name partbcod
{&run_proc_library}
  (buffer {1} /* buf_parts */
  ,output {2} /* v-b-code  */
  ) {3} .
/* $Workfile$ e n d */