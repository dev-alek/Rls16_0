/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание признака на объекте

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name prtobjcr
{&run_proc_library}
  (input  {1} /* v-obj-type  */
  ,input  {2} /* v-obj-code  */
  ,input  {3} /* v-artic     */
  ,input  {4} /* v-prod-type */
  ,input  {5} /* v-prod-code */
  ,input  {6} /* v-prt-code  */
  ,buffer {7} /* buf_prt-obj */
  ) {8} .
/* $Workfile$ e n d */