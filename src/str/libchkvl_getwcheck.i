/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка валидности тип чека тип товара коливечство

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/17/08
Author: Bakhtadze Natalya
Creation date: 07/17/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name libchkvl_getwcheck
{&run_proc_libchkvl}
  (input  {1} /* p-context-bh */
  ,input  {2} /* p-wmode  прием чеков {&add-def} или ручное создание/редактирование {&update}**/
  ,input  {3} /* p-edit-mode ручное добавление {&add-def} редактирование {&update}*/
  ,input  {4} /*p-close-check*/
  ,input  {5} /*p-getcash-shift*/
  ,input  {6} /*p-netto*/
  ,input-output {7} /*p-prev-code*/
    ) {8} .

/* $Workfile$ e n d */