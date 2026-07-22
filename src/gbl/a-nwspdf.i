/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

По номеру ДНЦ определяет посылать ли скидки на кассу

Автор: Чернова Светлана Александровна
Дата создания: 03/24/09
Author: Svetlana Chernova
Creation date: 03/24/09


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name a-nwspdf
{&run_proc_library2}
  (input  {1} /* p-plt-id     */
  ,input  {2} /* p-plt-db-num */
  ,input  {3} /* p-pdf-id     */
  ,input  {4} /* p-pdf-db-num */
  ,output {5} /* yes - отправлять на кассу */
  ) {6} .
/* $Workfile$ e n d */