/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запрос атрибута товара

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name gdsat
{&run_proc_library}
  (input  {1} /* p-artic            */
  ,input  {2} /* p-prod-type        */
  ,input  {3} /* p-prod-code        */
  ,input  {4} /* p-action           */
  ,output {5} /* p-return-attribute */
  ) {6} .
/* $Workfile$ e n d */