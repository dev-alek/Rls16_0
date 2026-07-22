/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Тип средства измерения уровня

Автор: Рукавишников Вадим
Дата создания: 16/02/21
Author: Rukavsihnikov Vadim
Creation date: 16/02/21

*/
block-level on error undo, throw.
enum ibs.th.bge.1crn.enum-level-ms-type:
  define enum
    enstatic            = 0 /* Статичная величина */
    enroulette2class    = 1 /* Рулетка 2-го класса точности */
    endensitylevelmeter = 2 /* Плотномер-уровнемер ПЛОТ-3Б-1РУ */
  .
end enum .
