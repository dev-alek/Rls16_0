/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Добавить один объект в список

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
&if     "{1}" <> "class"
&then
run userobjs_append in this-procedure
  (input  {1} /* p-obj-type      */
  ,input  {2} /* p-obj-code      */
  ) {3} .
&else
   userobjs_append 
  (input  {2} /* p-obj-type      */
  ,input  {3} /* p-obj-code      */
  ) {4} .
&endif
/* $Workfile$ e n d */