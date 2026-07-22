/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение Типы ПЛ будут только главные (yes)  иначе - всякие

Автор: Чернова Светлана Александровна
Дата создания: 03/15/07
Author: Svetlana Chernova
Creation date: 03/15/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name glstmain
{&run_proc_library}
  (output {1} /* p-only-main */
  ) {2} .
/* $Workfile$ e n d */