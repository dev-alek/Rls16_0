block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00216000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00216000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 8.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define input parameter vartype-cut            as integer   no-undo.
define input parameter varlist-db             as character no-undo.
define input parameter vardate-actual-goods   as date      no-undo.
define input parameter vardate-actual-docs    as date      no-undo.
define input parameter vardate-actual-findoc  as date      no-undo.
define input parameter vardate-output-zone    as date      no-undo.
define input parameter varstay-recipe-goods   as logical   no-undo.
define input parameter varstay-weight-goods   as logical   no-undo.
define input parameter varnot-copy-del-goods  as logical   no-undo.
define input parameter varstay-history        as logical   no-undo.
define input parameter vargen-file            as character no-undo.
define stream str-gen.
output stream str-gen to vargen-file append.
if not connected("src") then do:
   return error "Нет коннекта с базой 'src'.".
end.
if not connected("dst") then do:
   return error "Нет коннекта с базой 'dst'.".
end.
find src.sys-ctrl no-lock.
if not available src.sys-ctrl then do:
   return error "В базе данных src не найдена уникальная запись sys-ctrl.".
end.
if src.sys-ctrl.db-num <> 0 then do:
   return error "Пакет обрезания работает только в главной базе данных. В данной версии удаленные БД создаются выгрузкой из главных.".
end.
if vardate-actual-docs <> ? and
   (vardate-actual-goods   > vardate-actual-docs or
    vardate-actual-goods   = ? )   then do:
      return error SUBSTITUTE("Ошибка при задании дат актуальности." +
                              "Дата актуальности товаров &1."        +
                              "Дата актуальности документов &2."     +
                              "Дата актуальности документов должна быть больше или равна дат актуальностей товаров.",
                              vardate-actual-goods,
                              vardate-actual-docs).
end.
  on WRITE of dst.assortment-matrix            override do: end.
  on WRITE of dst.assortment-matrix-attr       override do: end.
  on WRITE of dst.assortment-matrix-goods      override do: end.
  on WRITE of dst.assortment-matrix-goods-attr override do: end.
  on WRITE of dst.c-assortment-matrix          override do: end.
  on WRITE of dst.c-assortment-matrix-goods    override do: end.
  on WRITE of dst.gds-obj-prop                 override do: end.
  on WRITE of dst.gds-obj-prop-attr            override do: end.
  on WRITE of dst.c-gds-obj-prop               override do: end.
for each old-assortment-matrix  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-assortment-matrix.
   buffer-copy old-assortment-matrix to new-assortment-matrix.
end.
for each old-assortment-matrix-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-assortment-matrix-attr.
   buffer-copy old-assortment-matrix-attr to new-assortment-matrix-attr.
end.
for each old-assortment-matrix-goods  no-lock , first new-goods where new-goods.gds-code = old-assortment-matrix-goods.gds-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-assortment-matrix-goods.
   buffer-copy old-assortment-matrix-goods to new-assortment-matrix-goods.
end.
for each old-assortment-matrix-goods-attr  no-lock , first new-goods where new-goods.gds-code = old-assortment-matrix-goods-attr.gds-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-assortment-matrix-goods-attr.
   buffer-copy old-assortment-matrix-goods-attr to new-assortment-matrix-goods-attr.
end.
for each old-gds-obj-prop  no-lock , first new-goods where new-goods.gds-code = old-gds-obj-prop.gds-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-gds-obj-prop.
   buffer-copy old-gds-obj-prop to new-gds-obj-prop.
end.
for each old-gds-obj-prop-attr  no-lock , first new-goods where new-goods.gds-code = old-gds-obj-prop-attr.gds-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-gds-obj-prop-attr.
   buffer-copy old-gds-obj-prop-attr to new-gds-obj-prop-attr.
end.
  if varstay-history = true then do:
for each old-c-assortment-matrix  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-assortment-matrix.
   buffer-copy old-c-assortment-matrix to new-c-assortment-matrix.
end.
for each old-c-assortment-matrix-goods  no-lock , first new-goods where new-goods.gds-code = old-c-assortment-matrix-goods.gds-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-assortment-matrix-goods.
   buffer-copy old-c-assortment-matrix-goods to new-c-assortment-matrix-goods.
end.
for each old-c-gds-obj-prop  no-lock , first new-goods where new-goods.gds-code = old-c-gds-obj-prop.gds-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-gds-obj-prop.
   buffer-copy old-c-gds-obj-prop to new-c-gds-obj-prop.
end.
  end.
output stream str-gen close.
  return "Произведен экспорт таблиц: assortment-matrix assortment-matrix-goods c-assortment-matrix c-assortment-matrix-goods assortment-matrix-attr assortment-matrix-goods-attr
          gds-obj-prop gds-obj-prop-attr c-gds-obj-prop . " .
end.
