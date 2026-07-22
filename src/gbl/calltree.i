/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Поиск по стеку нужной процедуры по имени внутренней процедуры, которую мы должны запустить

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/10/09
Author: Bakhtadze Natalya
Creation date: 12/10/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name calltree
{&run_proc_library}
  (input  {1} /* p-proc-name  - какую внут процедуру искать*/
  ,input  {2} /*p-from-handle - откуда искать*/
  ,input  {3} /* p-find-up-to-handle  - до какого-handle искать - если ? то до самого конца*/
  ,output {4} /* p-proc-handle  - если нашли то handle процедуры*/
  ) {5} .


/* $Workfile$ e n d */