/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение корневого признака пустой шкалы

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name emptyscl
{&run_proc_library}
  (output {1} /* p-root-node */
  ) {2} .
/* $Workfile$ e n d*/