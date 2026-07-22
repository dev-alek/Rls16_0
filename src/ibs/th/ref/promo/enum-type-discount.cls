block-level on error undo, throw.
/*

$Revision: 34ad735ba6bf, 2144, rls $
$Author: druban $
$Date: Wed Dec 25 15:23:55 2019 +0300 $
$Workfile: enum-type-discount.cls $
$Archive: ibs/th/ref/promo/enum-type-discount.cls $

коды типов промо-акций согласно протоколу взаимодействия с 1С

Автор: Молотков Сергей
Дата создания: 10/07/18
Author: Molotkov Sergey
Creation date: 10/07/18

*/

enum ibs.th.ref.promo.enum-type-discount:
  define enum
    ensolo  = 1 /* врЕменная скидка - предоставляется на отдельный товар */
    encombo = 2 /* промо-набор      - предоставляется на сочетание товаров */
    enVisa = 3
  .
end enum .
