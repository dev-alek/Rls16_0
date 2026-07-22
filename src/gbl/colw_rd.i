/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Считывание ширины колонок из базы данных

Автор: Перваков Михаил Сергеевич
Дата создания: 09/07/06
Author: Mikhail Pervakov
Creation date: 09/07/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(include_colwidth) = 0 &then
  &message need include gbl/colwidth.i
&endif
run colwidth-read in this-procedure
  (input  {1} /* p-db-num        */
  ,input  {2} /* p-user-id       */
  ,input  {3} /* p-program-name  */
  ,output {4} /* p-data-exist    */
  ) {5} .
/* $Workfile$ e n d */