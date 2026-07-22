/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение цены по ДНЦ по бар-коду на момент факт-ордер

Автор: Чернова Светлана Александровна
Дата создания: 03/28/06
Author: Svetlana Chernova
Creation date: 03/28/06

*/

/*
v-gop-id      группа объектов
v-gop-db-num

v-b-code      бар-код признака

v-root-b-code необязательный параметр
              0 или бар-код корневого признака товара
              можно указать для ускорения работы метода

v-fact-order  = 0 - получить текущую цену признака
              > 0 - получить цену признака на определенный момент

Возвращаемые параметры:
v-recid           recid документа ДНЦ
                  ? если отсутствует ДНЦ, закрыт до статуса {&fact}
v-price-sale-doc  текущая цена признака
                  ? если отсутствует ДНЦ, закрыт до статуса {&fact}
v-road-tax-doc      дорожный налог (? если v-price-sale = ?)
v-excise-doc        акциз          (? если v-price-sale = ?)

В случае, если возвращается ошибка, то это свидетельствует
о серьезных проблемах с базой данных или с параметрами вызова.
Следует останавливать работу программы.

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name bc-mpl
{&run_proc_library2}
  (input  {1} /* v-gop-id      */
  ,input  {2} /* v-gop-db-num  */
  ,input  {3} /* v-b-code      */
  ,input  {4} /* v-root-b-code */
  ,input  {5} /* v-fact-order  */
  ,output {6} /* v-recid       */
  ,output {7} /* v-price-sale-doc  */
  ,output {8} /* v-road-tax-doc    */
  ,output {9} /* v-excise-doc      */
  ) {10} .