/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение признака документа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name wthdat
{&run_proc_library}
  (input  {1} /* p-wth-doc-doc-type    */
  ,input  {2} /* p-trn-doc-internal    */
  ,input  {3} /* p-trn-doc-status_     */
  ,input  {4} /* p-action              */
  ,output {5} /* p-return-attribute    */
  ) {6} .
/* $Workfile$ e n d */