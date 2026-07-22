/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ФИЗИЧЕСКИ удалить чек и очистить контекст - в истории не пишетс

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/31/08
Author: Bakhtadze Natalya
Creation date: 07/31/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*пока можно удалить только отложенные чеки*/

&scop proc-name libthpos_delete-chk-doc
{&run_proc_libthpos}
  (input  {1} /* p-doc-code  */
  ) {2} .


/* $Workfile$ e n d */