/*

$Revision: b638ac123670, 1142, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:55 2017 +0300 $
$Workfile: enum-assortment-stg.cls $
$Archive: ibs/th/bge/1crn/enum-assortment-stg.cls $

коды этапов ввозда-вывода в ассортимент согласно протоколу взаимодействия с 1С

Автор: Молотков Сергей
Дата создания: 21/11/17
Author: Molotkov Sergey
Creation date: 21/11/17

*/
block-level on error undo, throw.
enum ibs.th.bge.1crn.enum-assortment-stg:
  define enum
    enactive =  1 /* ввод в ассортимент                           (Разрешены продажи и закупки), ИЖТ основная */
    endelay  =  2 /* ввод в ассортимент с отсрочкой начала продаж (разрешены    только закупки), ИЖТ новый    */
    enchange =  3 /* изменение ассортимента                       (Разрешены закупки и продажи), ИЖТ основная */
    enwithdrawal =  4 /* вывод из ассортимента                    (Разрешены только продажи),    ИЖТ на вывод */
    enarchive    =  5 /* перенос в архив/отказ                    (Запрещены продажи и закупки),              */
  .
end enum .

