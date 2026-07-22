/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание свойств контекста в АРМ кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/19/08
Author: Bakhtadze Natalya
Creation date: 08/19/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_set-context-property
{&run_proc_libthpos}
  (input  {1} /*p-context-mode может быть {&context} или {&chk-context}*/
  ,input  {2} /*p-property*/
  ,input  {3} /* p-character */
  ,input  {4} /* p-date  */
  ,input  {5} /* p-decimal */
  ,input  {6} /* p-integer */
  ,input  {7} /* p-logical */
  ,input  {8} /* p-handle */
  ,output {9} /* p-setted */
  ) {10} .


/* $Workfile$ e n d */