/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определяет по БД дату и тип обрезания_

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

&scop proc-name cutd-db
{&run_proc_library}
  (input  {1} /* p-db-num       */
  ,output {2} /* p-status       */
  ,output {3} /* p-cut-date     */
  ,output {4} /* p-cut-fin-date */
  ) {5} .
/* $Workfile$ */