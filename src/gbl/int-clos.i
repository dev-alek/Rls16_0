/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закрытие накладной

Автор: Чернова Светлана Александровна
Дата создания: 11/07/06
Author: Svetlana Chernova
Creation date: 11/07/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name lib-trn4_int-clos
{&run_proc_lib-trn4}
  (input  {1}       /* parparentproc */
  ,input  {2}       /* p-doc-code    */
  ,output table {3} /* gds-list      */
  ) {4} .
/* $Workfile$ e n d */