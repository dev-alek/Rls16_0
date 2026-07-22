/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Копирование опций истории и маршрутизации для сущности целиком

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/06
Author: Bakhtadze Natalya
Creation date: 10/31/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name lib-nws_get-hn-option-record
{&run_proc_lib-nws}
  (input  {1} /* p-db-num   */
  ,input  {2} /* p-buffer-handle  */
  ) {3} .

/* $Workfile$ e n d */