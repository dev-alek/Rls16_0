/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Корректировка спецификации по ПН и удалении на факт

Автор: Чернова Светлана Александровна
Дата создания: 02/28/07
Author: Svetlana Chernova
Creation date: 02/28/07


*/
&scop proc-name lib-trn4_corrsprc
{&run_proc_lib-trn4}
  (input  {1}       /* p-action   "+" или "-"  при удалении док-та */
  ,input  {2}       /* p-doc-code      */
  ,output {3}       /* p-message       */
  ) {4} .
/* $Workfile$ e n d */