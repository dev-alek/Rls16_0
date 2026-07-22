/*

$Revision: 18f7b619da54, 1481, rls $
$Author: DARuban $
$Date: Thu Aug 30 10:41:44 2018 +0300 $
$Workfile: enum-sched-status.cls $
$Archive: ibs/th/ref/promo/enum-sched-status.cls $

статусы расписаний промо-акций

Автор: Молотков Сергей
Дата создания: 12/07/18
Author: Molotkov Sergey
Creation date: 12/07/18

*/
block-level on error undo, throw.
enum ibs.th.ref.promo.enum-sched-status:
  define enum
    ensetting   = 0 /* выполняется настройка */
    enactive    = 1 /* активна */
  .
end enum .
