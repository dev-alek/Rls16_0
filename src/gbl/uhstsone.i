/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор одной фирмы

Автор: Перваков Михаил Сергеевич
Дата создания: 04/25/06
Author: Mikhail Pervakov
Creation date: 04/25/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(include_userhsts) = 0 &then
  &message need include gbl/userhsts.i
&endif
run userhsts_select-one in this-procedure
  (input  {1} /* parparentproc      */
  ,input  {2} /* p-db-num           */
  ,input  {3} /* p-user-id          */
  ,input  {4} /* p-curr-host-code   */
  ,output {5} /* p-user-select      */
  ,output {6} /* p-select-host-code */
  ) {7} .

/* $Workfile$ e n d */