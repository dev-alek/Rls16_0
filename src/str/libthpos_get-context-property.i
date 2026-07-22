/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Считывание свойств контекста в АРМ кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/19/08
Author: Bakhtadze Natalya
Creation date: 08/19/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_get-context-property
{&run_proc_libthpos}
  (input  {1} /*p-context-mode может быть {&context} или {&chk-context}*/
  ,input  {2} /*p-property*/
  ,output {3} /* p-character */
  ,output {4} /* p-date  */
  ,output {5} /* p-decimal */
  ,output {6} /* p-integer */
  ,output {7} /* p-logical */
  ,output {8} /* p-handle */
  ,output {9} /* p-data-type */
  ,output {10} /* p-setted */
  ) {11} .


/* $Workfile$ e n d */