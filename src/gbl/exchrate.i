/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение текущего курса заданной валюты и ее сокр названия на определенную дату

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/13/03
Author: Bakhtadze Natalya
Creation date: 11/13/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name exchrate
{&run_proc_library}
  (input  {1} /* p-curr-code  */
  ,input  {2} /* p-curr-date  */
  ,output {3} /* p-exch-rate  */
  ,output {4} /* p-exch-scale */
  ,output {5} /* p-curr-abbr  */
  ) {6} .
/* $Workfile$ e n d */