/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение price-list, который задает цену бар-кода

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/05/06

v-obj-type    объект
v-obj-code

v-b-code      любой бар-код
              если бар-код на неосновную единицу измерения,
              то возвращается цена за единицу измерения бар-кода

v-root-b-code необязательный параметр
              0 или бар-код корневого признака товара
              можно указать для ускорения работы метода

v-fact-order  = 0 - получить текущую цену признака
              > 0 - получить цену признака на определенный момент

Возвращаемые параметры:
v-price-list-recid   указатель на запись price-list
                     или ?

В случае, если возвращается ошибка, то это свидетельствует
о серьезных проблемах с базой данных или с параметрами вызова.
Следует останавливать работу программы.

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name bcodepls
{&run_proc_library}
  (input  {1} /* v-obj-type         */
  ,input  {2} /* v-obj-code         */
  ,input  {3} /* v-b-code           */
  ,input  {4} /* v-root-b-code      */
  ,input  {5} /* v-fact-order       */
  ,output {6} /* v-price-list-recid */
  ,output {7} /* v-cli-base-rate    */
  ) {8} .
/* $Workfile$ e n d */