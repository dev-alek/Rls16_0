/*

$Revision: 18f7b619da54, 1481, rls $
$Author: DARuban $
$Date: Thu Aug 30 10:41:44 2018 +0300 $
$Workfile: enum-promo-status.cls $
$Archive: ibs/th/ref/promo/enum-promo-status.cls $

статусы промо-акций

Автор: Молотков Сергей
Дата создания: 11/07/18
Author: Molotkov Sergey
Creation date: 11/07/18

*/
block-level on error undo, throw.
enum ibs.th.ref.promo.enum-promo-status:
  define enum
    ensetting   = 0 /* выполняется настройка */
    enactive    = 1 /* активна */
    encompleted = 2 /* завершена */
  .
end enum .
