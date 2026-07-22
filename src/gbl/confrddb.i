/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Чтение параметров конфигурации для заданной БД


Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

/*
Возвращаемые значения:
  p-value: значение параметра
  p-type:  тип параметра
    {&type-char}
    {&type-log}
    {&type-dec}
    {&type-int}
    {&type-date}

Сначала ищется запись config с указанным параметрами,
если запись не найдена, то производится поиск записи config
только по параметру p-code (общесистемной настройки).

Для config, привязанных к объекту,
производится поиск настройки по объекту,
Если отсутствует настройка по объекту, то производится поиск настройки по фирме
Если отсутствует настройка по объекту, то производится поиск глобальной настройки
*/
&scop proc-name confrddb
{&run_proc_library}
  (input  {1}  /* p-code  */
  ,input  {2}  /* db-num  */
  ,input  {3}  /* h-code  */
  ,input  {4}  /* o-type  */
  ,input  {5}  /* o-code  */
  ,input  {6}  /* msg-on  */
  ,output {7}  /* p-value */
  ,output {8}  /* p-type  */
  ) {9} .
/* $Workfile$ e n d */