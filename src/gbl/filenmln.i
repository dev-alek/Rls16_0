/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверить, что в файле имеет определенное количество строк

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name filenmln
{&run_proc_library}
  (input  {1} /* p-file-name  */
  ,input  {2} /* p-line-count */
  ,output {3} /* p-line-exist */
  ) {4} .
/* $Workfile$ */