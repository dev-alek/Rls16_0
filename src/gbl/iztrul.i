/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Правило срабатывания ИЖТ по событию

Автор: Чернова Светлана Александровна
Дата создания: 10/20/09
Author: Svetlana Chernova
Creation date: 10/20/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name iztrul
{&run_proc_library2}
  (input  {1} /* p-event-code */
  ,output {2} /* p-izd-new    */
  ,output {3} /* p-izd-com    */
  ,output {4} /* p-izd-del    */
  ,output {5} /* p-izd-spec   */
  ,output {6} /* p-izd-empty  */
  ) {7} .