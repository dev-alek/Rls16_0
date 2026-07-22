/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка на целое количество штучного товара для lib-trn

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/
&scop proc-name lib-trn_chkwhole
{&run_proc_lib-trn}
  ( input {1} /*pardoc-code   */
   ,input {2} /*parartic      */
   ,input {3} /*parprod-type  */
   ,input {4} /*parprod-code  */
   ,input {5} /*parcli-qnty   */
   ,input {6} /*pardoc-qnty   */
   ,input {7} /*parfact-qnty  */
   ,input {8} /*parrecalc     */
  ) {9} .
/* $Workfile$ e n d */