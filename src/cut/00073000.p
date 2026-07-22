block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00073000.p $
$Archive: cut/00073000.p $

Файл пирога обрезания. Относится к категории 73.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/05/09
Author: Bakhtadze Natalya
Creation date: 08/05/09

Обработка таблиц:
curr-accnt
c-curr-accnt
curr-accnt-attr
curr-bank
c-curr-bank
curr-bank-attr
currency
c-currency
currency-attr
c-currency-attr
curr-shop
curr-shop-attr
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00073000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00073000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 13.".
{ cmp/str-glbl.i }

define buffer old-curr-accnt for src.curr-accnt.
define buffer new-curr-accnt for dst.curr-accnt.
define buffer old-c-curr-accnt for src.c-curr-accnt.
define buffer new-c-curr-accnt for dst.c-curr-accnt.
define buffer old-curr-accnt-attr for src.curr-accnt-attr.
define buffer new-curr-accnt-attr for dst.curr-accnt-attr.
define buffer old-curr-bank  for src.curr-bank.
define buffer new-curr-bank  for dst.curr-bank.
define buffer old-c-curr-bank for src.c-curr-bank.
define buffer new-c-curr-bank for dst.c-curr-bank.
define buffer old-curr-bank-attr for src.curr-bank-attr.
define buffer new-curr-bank-attr for dst.curr-bank-attr.
define buffer old-currency   for src.currency.
define buffer new-currency   for dst.currency.
define buffer old-c-currency for src.c-currency.
define buffer new-c-currency for dst.c-currency.
define buffer old-currency-attr for src.currency-attr.
define buffer new-currency-attr for dst.currency-attr.
define buffer old-c-currency-attr for src.c-currency-attr.
define buffer new-c-currency-attr for dst.c-currency-attr.
define buffer old-curr-shop  for src.curr-shop.
define buffer new-curr-shop  for dst.curr-shop.
define buffer old-curr-shop-attr  for src.curr-shop-attr.
define buffer new-curr-shop-attr  for dst.curr-shop-attr.


do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
on WRITE of dst.curr-accnt override do: end.
on WRITE of dst.c-curr-accnt override do: end.
on WRITE of dst.curr-accnt-attr override do: end.
on WRITE of dst.curr-bank  override do: end.
on WRITE of dst.c-curr-bank override do: end.
on WRITE of dst.curr-bank-attr override do: end.
on WRITE of dst.currency   override do: end.
on WRITE of dst.c-currency override do: end.
on WRITE of dst.currency-attr override do: end.
on WRITE of dst.c-currency-attr override do: end.
on WRITE of dst.curr-shop  override do: end.
on WRITE of dst.curr-shop-attr  override do: end.
{ utl/00000002.i curr-accnt }
if varstay-history then do:
  { utl/00000002.i c-curr-accnt }
end.
{ utl/00000002.i curr-accnt-attr }
{ utl/00000002.i curr-bank  }
if varstay-history then do:
  { utl/00000002.i c-curr-bank }
end.
{ utl/00000002.i curr-bank-attr }
{ utl/00000002.i currency   }
if varstay-history then do:
  { utl/00000002.i c-currency }
end.
{ utl/00000002.i currency-attr }
if varstay-history then do:
  { utl/00000002.i c-currency-attr }
end.
{ utl/00000002.i curr-shop  }
{ utl/00000002.i curr-shop-attr  }
output stream str-gen close.
return "Произведен экспорт таблиц: curr-accnt c-curr-accnt curr-accnt-attr curr-bank c-curr-bank curr-bank-attr ~
currency c-currency currency-attr c-currency-attr curr-shop curr-shop-attr.".
end.