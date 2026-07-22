/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение последнего прихода по фирме

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

{5} p-in-code
{6} p-obj-type
{7} p-obj-code

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name lastindc
{&run_proc_library}
  (input  {1} /* p-host-code */
  ,input  {2} /* p-artic     */
  ,input  {3} /* p-prod-type */
  ,input  {4} /* p-prod-code */
  ,output {5} /* p-in-code   */
  ,output {6} /* p-obj-type  */
  ,output {7} /* p-obj-code  */
  ) {8} .
/* $Workfile$ */