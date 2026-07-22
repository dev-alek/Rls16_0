/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определяет каким образом обрабатывать партии документа

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 07/09/03

*/
&scop proc-name partcond
{&run_proc_library}
  (input  {1}  /* p-ext-doc-type    */
  ,input  {2}  /* p-is-hold         */
  ,input  {3}  /* p-parts-fact-qnty */
  ,input  {4}  /* p-create-part     */
  ,input  {5}  /* p-old-return      */
  ,output {6}  /* p-rsrv-code       */
  ,output {7}  /* p-unrv-code       */
  ,output {8}  /* p-need-rsrv       */
  ,output {9}  /* p-need-unrv       */
  ,output {10} /* p-rsrv-sign       */
  ,output {11} /* p-unrv-sign       */
  ) {12} .
/* $Workfile$ e n d */