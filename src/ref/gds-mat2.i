/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение статуса строки(товара) ассортиментной матрицы

Автор: Чернова Светлана Александровна
Дата создания: 01/22/09
Author: Svetlana Chernova
Creation date: 01/22/09

*/
&scop proc-name main_gds-mat2
{&run_proc_lib-Matrix}
 (input {1}        /* handle   */
 ,input {2}        /* p-recid  */
 ,input-output {3} /* p-asmg-status     */
 ,input {4}        /* p-mess   задавать вопросы    */
  ) {5} .
/* $Workfile$ e n d */