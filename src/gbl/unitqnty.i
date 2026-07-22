/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Контроль допустимых количеств для данной единицы измерения (товара)

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name unitqnty
{&run_proc_library}
  (input {1} /* p-unit-name       */
  ,input {2} /* p-artic           */
  ,input {3} /* p-prod-type       */
  ,input {4} /* p-prod-code       */
  ,input {5} /* p-unit-description*/
  ,input {6} /* p-qnty            */
  ) {7} .
/* $Workfile$ e n d */