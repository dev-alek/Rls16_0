/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать ПОЛНОГО СОДЕРЖАНИЯ чека в XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/27/08
Author: Bakhtadze Natalya
Creation date: 07/27/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_print-dataset
{&run_proc_libthpos}
  (input  {1} /* p-forced  */
  ) {2} .


/* $Workfile$ e n d */