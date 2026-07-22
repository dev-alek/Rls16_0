/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор одного объекта

Автор: Перваков Михаил Сергеевич
Дата создания: 04/25/06
Author: Mikhail Pervakov
Creation date: 04/25/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(include_userobjs) = 0 &then
  &message need include gbl/userobjs.i
&endif
run userobjs_select-one in this-procedure
  (input  {1} /* parparentproc     */
  ,input  {2} /* p-db-num          */
  ,input  {3} /* p-user-id         */
  ,input  {4} /* p-host-code-obj   */
  ,input  {5} /* p-obj-type        */
  ,input  {6} /* p-obj-code        */
  ,output {7} /* p-user-select     */
  ,output {8} /* p-select-obj-type */
  ,output {9} /* p-select-obj-code */
  ) {10} .

/* $Workfile$ e n d */