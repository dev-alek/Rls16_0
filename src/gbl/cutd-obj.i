/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определяет по объекту дату и тип обрезани_

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/
/*
Возможные типы:
  1 - БД никогда не обрезалась ( при этом p-cut-date = ? )
  2 - БД обрезалась "полностью"
  3 - Обрезались документы по запрашиваемому объекту, но БД не была выгружена
  4 - БД была выгружена после обрезания документов по запрашиваемому объекту
*/

&scop proc-name cutd-obj
{&run_proc_library}
  (input  {1} /* p-obj-type     */
  ,input  {2} /* p-obj-code     */
  ,output {3} /* p-status       */
  ,output {4} /* p-cut-date     */
  ,output {5} /* p-cut-fin-date */
  ) {6} .
/* $Workfile$ */