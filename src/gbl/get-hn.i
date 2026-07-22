/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение значения опции истории и маршрутизации

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/06
Author: Bakhtadze Natalya
Creation date: 10/31/06

p-db-num  Номер БД, для которой определяем значение
p-table-name - сущность, для которой определяем значение  -надо указывать САМУ ТАБЛИЦУ а не историю!
p-option-name - опция - может быть
hn - отсыласть историю в другие БД - в ГБД ВСЕГДА ОТСЫЛАЕМ!!!
nh - писать историю при приеме СПН
hp - пока не обрабатываем

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name lib-nws_get-hn-option
{&run_proc_lib-nws}
  (input  {1} /* p-db-num   */
  ,input  {2} /* p-table-name  */
  ,input  {3} /* p-host-code  */
  ,input  {4} /* p-obj-type  */
  ,input  {5} /* p-obj-code  */
  ,input  {6} /* p-charkey_one  */
  ,input  {7} /* p-charkey_two  */
  ,input  {8} /* p-charkey_three  */
  ,input  {9} /* p-key#_one  */
  ,input  {10} /* p-key#_two  */
  ,input  {11} /* p-key_#three  */
  ,input  {12} /* p-option-name  */
  ,output {13} /* p-option-value    */
  ) {14} .

/* $Workfile$ e n d */