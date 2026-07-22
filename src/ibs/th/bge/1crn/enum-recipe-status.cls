/*

$Revision: 8a36389025da, 1175, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:20:27 2017 +0300 $
$Workfile: enum-recipe-status.cls $
$Archive: ibs/th/bge/1crn/enum-recipe-status.cls $

коды статусов рецептов согласно протоколу взаимодействия с 1С

Автор: Молотков Сергей
Дата создания: 06/12/17
Author: Molotkov Sergey
Creation date: 06/12/17

*/
block-level on error undo, throw.
enum ibs.th.bge.1crn.enum-recipe-status:
  define enum
    enopen  =  1 /*  */
    enclose =  2 /* закрыт */
  .
end enum .

