/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить атрибут ЗНАЧЕНИЯ дополнительного бар-кода

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/06/03
Author: Bakhtadze Natalya
Creation date: 10/06/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name prodbctv
{&run_proc_library}
  (input {1} /* p-b-str        */
  ,input  {2} /* p-unit-cli         */
  ,input  {3} /* p-unit-base        */
  ,input  {4} /* p-action           */
  ,output {5} /* p-return-attribute */
  ) {6} .
/* $Workfile$ */