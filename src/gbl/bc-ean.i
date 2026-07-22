/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить промышленный штрих-код по умолчанию

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name bc-ean
{&run_proc_library}
  (input  {1} /* p-bc-frmt  */
  ,input  {2} /* p-bc-pfx   */
  ,input  {3} /* p-b-code   */
  ,output {4} /* p-ean-code */
  ) {5} .
/* $Workfile$ */