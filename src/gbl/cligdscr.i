/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание записи товарного архива по поставщикам и покупателям

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name cligdscr
{&run_proc_library}
  (input  {1} /* v-cli-type  */
  ,input  {2} /* v-cli-code  */
  ,input  {3} /* v-host-code */
  ,input  {4} /* v-artic     */
  ,input  {5} /* v-prod-type */
  ,input  {6} /* v-prod-code */
  ,buffer {7} /* buf_cli-gds */
  ) {8} .
/* $Workfile$ */