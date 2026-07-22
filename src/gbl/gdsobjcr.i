/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание товара на объекте

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name gdsobjcr
{&run_proc_library}
  (input  {1} /* p-obj-type   */
  ,input  {2} /* p-obj-code   */
  ,input  {3} /* p-artic      */
  ,input  {4} /* p-prod-type  */
  ,input  {5} /* p-prod-code  */
  ,buffer {6} /* buf_gds-obj  */
  ) {7} .
/* $Workfile$ e n d */