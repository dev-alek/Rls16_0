/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Степень автоматизации

Автор: Рукавишников Вадим
Дата создания: 16/02/21
Author: Rukavsihnikov Vadim
Creation date: 16/02/21

*/
block-level on error undo, throw.
enum ibs.th.bge.1crn.enum-deg-auto:
  define enum
    enautoms          = 0 /* Автоматизированное СИ */
    ennonautomatedms  = 1 /* Неавтоматизированное СИ */
    enmssys           = 2 /* Измерительная система */
  .
end enum .
