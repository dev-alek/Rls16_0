/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение типа продажной цены

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$".
&scop proc-name curr-r-b
{&run_proc_library}
  (output {1} /* p-r-b-abbr */
  ) {2} .
/* $Workfile$ e n d */