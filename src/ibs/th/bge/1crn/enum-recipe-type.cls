/*

$Revision: dbfe23dd76e1, 1141, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:54 2017 +0300 $
$Workfile: enum-recipe-type.cls $
$Archive: ibs/th/bge/1crn/enum-recipe-type.cls $

коды типов рецептов согласно протоколу взаимодействия с 1С

Автор: Молотков Сергей
Дата создания: 13/11/17
Author: Molotkov Sergey
Creation date: 13/11/17

*/
block-level on error undo, throw.
enum ibs.th.bge.1crn.enum-recipe-type:
  define enum
    enmanufacturing =  1 /* производство */
    engathering     =  2 /* комплектация */
    enalternative   =  3 /* альтернатива */
  .
end enum .

