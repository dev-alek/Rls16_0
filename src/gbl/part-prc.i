/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка того, что партию можно резервировать в данном документе

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/
&scop proc-name part-prc
{&run_proc_library}
  (buffer {1}  /* buf_parts               */
  ,buffer {2}  /* buf_trn-doc             */
  ,input  {3}  /* p-reserv-single-part    */
  ,input  {4}  /* p-single-part-in-code   */
  ,input  {5}  /* p-single-part-part-code */
  ,input  {6}  /* p-pl-code               */
  ,input  {7}  /* p-goods-twounit         */
  ,input  {8}  /* p-purch-code-list       */
  ,input  {9}  /* p-rsrv-qnty             */
  ,input  {10} /* p-check-negmanuf        */
  ,output {11} /* p-reason                */
  ,output {12} /* p-process-part          */
  ) {13} .
/* $Workfile$ e n d */