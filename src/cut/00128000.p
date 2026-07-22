block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00128000.p $
$Archive: cut/00128000.p $

Файл пирога обрезания. Относится к категории 128.

Автор: Чернова Светлана Александровна
Дата создания: 05/25/09
Author: Svetlana Chernova
Creation date: 05/25/09

Обработка таблиц:
tmp-sale
tmp-sale-gds
tmp-sale-dtl

tmp-sale-attr
tmp-sale-gds-attr
tmp-sale-dtl-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00128000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00128000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 128.".
{ cmp/str-glbl.i }

define buffer old-tmp-sale      for src.tmp-sale.
define buffer new-tmp-sale      for dst.tmp-sale.
define buffer old-tmp-sale-gds  for src.tmp-sale-gds.
define buffer new-tmp-sale-gds  for dst.tmp-sale-gds.
define buffer old-tmp-sale-dtl  for src.tmp-sale-dtl.
define buffer new-tmp-sale-dtl  for dst.tmp-sale-dtl.

define buffer old-tmp-sale-attr      for src.tmp-sale-attr.
define buffer new-tmp-sale-attr      for dst.tmp-sale-attr.
define buffer old-tmp-sale-gds-attr  for src.tmp-sale-gds-attr.
define buffer new-tmp-sale-gds-attr  for dst.tmp-sale-gds-attr.
define buffer old-tmp-sale-dtl-attr  for src.tmp-sale-dtl-attr.
define buffer new-tmp-sale-dtl-attr  for dst.tmp-sale-dtl-attr.

define buffer new-goods         for dst.goods.


do
on error undo, return error
:

{ utl/00000001.i }
on WRITE of dst.tmp-sale             override do: end.
on WRITE of dst.tmp-sale-gds         override do: end.
on WRITE of dst.tmp-sale-dtl         override do: end.
on WRITE of dst.tmp-sale-attr        override do: end.
on WRITE of dst.tmp-sale-gds-attr    override do: end.
on WRITE of dst.tmp-sale-dtl-attr    override do: end.


{ utl/00000002.i tmp-sale      }
{ utl/00000002.i tmp-sale-attr }

{ utl/00000002.i tmp-sale-gds  " no-lock , first new-goods where ~
  new-goods.artic = old-tmp-sale-gds.artic and ~
  new-goods.prod-type = old-tmp-sale-gds.prod-type and ~
  new-goods.prod-code = old-tmp-sale-gds.prod-code "   }

{ utl/00000002.i tmp-sale-gds-attr  " no-lock , first new-goods  where ~
  new-goods.artic = old-tmp-sale-gds-attr.artic and ~
  new-goods.prod-type = old-tmp-sale-gds-attr.prod-type and ~
  new-goods.prod-code = old-tmp-sale-gds-attr.prod-code "   }


{ utl/00000002.i tmp-sale-dtl  " no-lock , first new-goods  where ~
  new-goods.artic = old-tmp-sale-dtl.artic and ~
  new-goods.prod-type = old-tmp-sale-dtl.prod-type and ~
  new-goods.prod-code = old-tmp-sale-dtl.prod-code "   }

{ utl/00000002.i tmp-sale-dtl-attr  " no-lock , first new-goods where ~
  new-goods.artic = old-tmp-sale-dtl-attr.artic and ~
  new-goods.prod-type = old-tmp-sale-dtl-attr.prod-type and ~
  new-goods.prod-code = old-tmp-sale-dtl-attr.prod-code   " }

  output stream str-gen close.
  return "Произведен экспорт таблиц: tmp-sale tmp-sale-gds tmp-sale-dtl .".
end.