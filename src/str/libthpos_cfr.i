/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись ФР

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/21/08
Author: Bakhtadze Natalya
Creation date: 08/21/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_cfr
{&run_proc_libthpos}
  (input  {1} /* p-doc-code  */
  ,input  {2} /* p- trans-type */
  ,input  {3} /* p-charkey_one*/
  ,input  {4} /* p-deckey_one*/
  ,input  {5} /* p-key#_one*/
  ) {6} .


/* $Workfile$ e n d */