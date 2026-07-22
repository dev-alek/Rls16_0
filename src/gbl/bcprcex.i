/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение цены бар-кода с налогами

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 08/11/03

v-obj-type    объект
v-obj-code

v-b-code      бар-код признака

v-root-b-code необязательный параметр
              0 или бар-код корневого признака товара
              можно указать для ускорения работы метода

v-fact-order  = 0 - получить текущую цену признака
              > 0 - получить цену признака на определенный момент

Возвращаемые параметры:
v-doc-num     номер документа переоценки
              ? если отсутствует переоценка, закрытая до статуса {&act-overvalue}
v-price-sale  текущая цена признака
              ? если отсутствует переоценка, закрытая до статуса {&act-overvalue}
v-road-tax    дорожный налог (? если v-price-sale = ?)
v-excise      акциз          (? если v-price-sale = ?)
v-VAT-pc      процент НДС
v-SLC-pc      процент НП

В случае, если возвращается ошибка, то это свидетельствует
о серьезных проблемах с базой данных или с параметрами вызова.
Следует останавливать работу программы.

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name bcprcex
{&run_proc_library}
  (input  {1}  /* v-obj-type    */
  ,input  {2}  /* v-obj-code    */
  ,input  {3}  /* v-b-code      */
  ,input  {4}  /* v-root-b-code */
  ,input  {5}  /* v-fact-order  */
  ,output {6}  /* v-doc-num     */
  ,output {7}  /* v-price-sale  */
  ,output {8}  /* v-road-tax    */
  ,output {9}  /* v-excise      */
  ,output {10} /* v-VAT-pc      */
  ,output {11} /* v-SLT-pc      */
  ) {12} .
/* $Workfile$ e n d */