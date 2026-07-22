/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Поиск артикула и кода производителя по коду товара

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name arptpc
{&run_proc_library}
  (input  {1} /* p-gds-code  */
  ,output {2} /* p-artic     */
  ,output {3} /* p-prod-type */
  ,output {4} /* p-prod-code */
  ) {5} .
/* $Workfile$ e n d */