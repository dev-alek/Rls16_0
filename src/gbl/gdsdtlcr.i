/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание корневого gds-dtl в накладной на основании строки накладной

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name gdsdtlcr
{&run_proc_library}
  (input  {1} /* p-obj-type   */
  ,buffer {2} /* p-obj-code   */
  ,buffer {3} /* p-artic      */
  ) {4} .
/* $Workfile$ e n d */