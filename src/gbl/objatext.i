/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить дополнительные атрибуты объекта

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name objatext
{&run_proc_library}
  (input  {1} /* p-obj-type */
  ,input  {2} /* p-obj-code */
  ,input  {3} /* p-action   */
  ,output {4} /* p-value    */
  ,output {5} /* p-type     */
  ) {6} .
/* $Workfile$ e n d */