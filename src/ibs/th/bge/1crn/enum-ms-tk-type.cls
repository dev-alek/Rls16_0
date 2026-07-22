/*

$Revision: e117265a4790, 1154, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:55 2017 +0300 $
$Workfile: enum-ms-tk-type.cls $
$Archive: ibs/th/bge/1crn/enum-ms-tk-type.cls $

номера температурных коэффициентов линейного расширения материала средства измерения уровня, согласно протоколу взаимодействия с 1С

Автор: Молотков Сергей
Дата создания: 04/12/17
Author: Molotkov Sergey
Creation date: 04/12/17

*/
block-level on error undo, throw.
enum ibs.th.bge.1crn.enum-ms-tk-type:
  define enum
    ensteel  = 1 /* сталь */
    enalumin = 2 /* алюминий */
  .
end enum .

