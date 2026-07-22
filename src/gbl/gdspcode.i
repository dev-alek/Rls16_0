/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение основного бар-кода партии

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

v-gds-code  код товара
v-node-code бар-код терминального или корневого признака
v-in-code код ПН

В случае, если бар-код не найден - на экран не выводится никаких сообщений,
возвращается ошибка и строка, описывающая ошибку

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name gdspcode
{&run_proc_library}
  (input  {1} /* v-gds-code   */
  ,input  {2} /* v-node-code  */
  ,input  {3} /* v-in-code  */
  ,input  {4} /* v-part-code  */
  ,output {5} /* v-b-code     */
  ) {6} .
/* $Workfile$ e n d */