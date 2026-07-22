block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00216000.p $
$Archive: cut/00216000.p $

Файл пирога обрезания. Относится к категории 216.

Автор: Чернова Светлана Александровна
Дата создания: 05/22/09
Author: Svetlana Chernova
Creation date: 05/22/09

Обработка таблиц:

assortment-matrix
assortment-matrix-attr
c-assortment-matrix
assortment-matrix-goods
assortment-matrix-goods-attr
c-assortment-matrix-goods
gds-obj-prop
gds-obj-prop-attr
c-gds-obj-prop

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00216000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00216000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 8.".
{ cmp/str-glbl.i }

define buffer old-assortment-matrix             for src.assortment-matrix.
define buffer new-assortment-matrix             for dst.assortment-matrix.
define buffer old-c-assortment-matrix           for src.c-assortment-matrix.
define buffer new-c-assortment-matrix           for dst.c-assortment-matrix.
define buffer old-assortment-matrix-goods       for src.assortment-matrix-goods.
define buffer new-assortment-matrix-goods       for dst.assortment-matrix-goods.
define buffer old-c-assortment-matrix-goods     for src.c-assortment-matrix-goods.
define buffer new-c-assortment-matrix-goods     for dst.c-assortment-matrix-goods.
define buffer old-assortment-matrix-attr        for src.assortment-matrix-attr.
define buffer new-assortment-matrix-attr        for dst.assortment-matrix-attr.
define buffer old-assortment-matrix-goods-attr  for src.assortment-matrix-goods-attr.
define buffer new-assortment-matrix-goods-attr  for dst.assortment-matrix-goods-attr.
define buffer new-gds-obj-prop                  for dst.gds-obj-prop.
define buffer new-gds-obj-prop-attr             for dst.gds-obj-prop-attr.
define buffer new-c-gds-obj-prop                for dst.c-gds-obj-prop.
define buffer old-gds-obj-prop                  for src.gds-obj-prop.
define buffer old-gds-obj-prop-attr             for src.gds-obj-prop-attr.
define buffer old-c-gds-obj-prop                for src.c-gds-obj-prop.

define buffer new-goods           for dst.goods.


do
on error undo, return error
:
  { utl/00000001.i }
  on WRITE of dst.assortment-matrix            override do: end.
  on WRITE of dst.assortment-matrix-attr       override do: end.
  on WRITE of dst.assortment-matrix-goods      override do: end.
  on WRITE of dst.assortment-matrix-goods-attr override do: end.
  on WRITE of dst.c-assortment-matrix          override do: end.
  on WRITE of dst.c-assortment-matrix-goods    override do: end.
  on WRITE of dst.gds-obj-prop                 override do: end.
  on WRITE of dst.gds-obj-prop-attr            override do: end.
  on WRITE of dst.c-gds-obj-prop               override do: end.



  { utl/00000002.i assortment-matrix      }
  { utl/00000002.i assortment-matrix-attr }
  { utl/00000002.i assortment-matrix-goods      " no-lock , first new-goods where new-goods.gds-code = old-assortment-matrix-goods.gds-code "    }
  { utl/00000002.i assortment-matrix-goods-attr " no-lock , first new-goods where new-goods.gds-code = old-assortment-matrix-goods-attr.gds-code " }
  { utl/00000002.i gds-obj-prop       " no-lock , first new-goods where new-goods.gds-code = old-gds-obj-prop.gds-code "    }
  { utl/00000002.i gds-obj-prop-attr  " no-lock , first new-goods where new-goods.gds-code = old-gds-obj-prop-attr.gds-code " }


  /* Перенос если нужно истории */
  if varstay-history = true then do:
      { utl/00000002.i c-assortment-matrix        }
      { utl/00000002.i c-assortment-matrix-goods  " no-lock , first new-goods where new-goods.gds-code = old-c-assortment-matrix-goods.gds-code "}
      { utl/00000002.i c-gds-obj-prop " no-lock , first new-goods where new-goods.gds-code = old-c-gds-obj-prop.gds-code "}
  end.
output stream str-gen close.
  return "Произведен экспорт таблиц: assortment-matrix assortment-matrix-goods c-assortment-matrix c-assortment-matrix-goods assortment-matrix-attr assortment-matrix-goods-attr
          gds-obj-prop gds-obj-prop-attr c-gds-obj-prop . " .
end.