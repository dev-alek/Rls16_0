/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает имя товара по артикулу

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name gds-arnm
{&run_proc_library}
  (input  {1} /* p-artic     */
  ,input  {2} /* p-prod-type */
  ,input  {3} /* p-prod-code */
  ,output {4} /* p-gds-name  */
  ) {5} .
/* $Workfile$ e n d */