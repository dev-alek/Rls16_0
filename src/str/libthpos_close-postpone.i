/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Что-то сделать с отложенным чеком

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/21/08
Author: Bakhtadze Natalya
Creation date: 08/21/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libthpos_close-postpone
{&run_proc_libthpos}
  (input  {1} /* p-doc-code  номер прямого чека - может отсутвовать - ЗАРЕЗЕРВИРОВАНО ПОКА ИСПОЛЬЗУЕТСЯ*/
  ,input  {2} /* p-postpone-doc-code  номер отложенного чека*/
  ,input  {3} /*p-close-mode 1 - перевести в оплаченные отложенные 0 - аннулировать */
  ) {4} .


/* $Workfile$ e n d */