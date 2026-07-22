/*

$Revision: 38e7c64866ed, 3182, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:25 $
$Workfile: enum-promo-goods-type.cls $
$Archive: ibs/th/ref/promo/enum-promo-goods-type.cls $

статусы промо-акций

Автор: Молотков Сергей
Дата создания: 11/07/18
Author: Molotkov Sergey
Creation date: 11/07/18

*/
block-level on error undo, throw.
enum ibs.th.ref.promo.enum-promo-goods-type:
  define enum
    Appl          = 1  /* товары применения*/
    criterion     = 2  /* независимые условия */
    PromoSet      = 3  /* промо-набор */
    PromoSetGoods = 4  /* товары прома-набора */
    Bin           = 5  /* Бины катр */
    BarCode       = 6  /* ШК*/
  .
end enum .

