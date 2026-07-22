block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00128000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00128000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 128.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
on WRITE of dst.tmp-sale             override do: end.
on WRITE of dst.tmp-sale-gds         override do: end.
on WRITE of dst.tmp-sale-dtl         override do: end.
on WRITE of dst.tmp-sale-attr        override do: end.
on WRITE of dst.tmp-sale-gds-attr    override do: end.
on WRITE of dst.tmp-sale-dtl-attr    override do: end.
for each old-tmp-sale  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tmp-sale.
   buffer-copy old-tmp-sale to new-tmp-sale.
end.
for each old-tmp-sale-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tmp-sale-attr.
   buffer-copy old-tmp-sale-attr to new-tmp-sale-attr.
end.
for each old-tmp-sale-gds  no-lock , first new-goods where   new-goods.artic = old-tmp-sale-gds.artic and   new-goods.prod-type = old-tmp-sale-gds.prod-type and   new-goods.prod-code = old-tmp-sale-gds.prod-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tmp-sale-gds.
   buffer-copy old-tmp-sale-gds to new-tmp-sale-gds.
end.
for each old-tmp-sale-gds-attr  no-lock , first new-goods  where   new-goods.artic = old-tmp-sale-gds-attr.artic and   new-goods.prod-type = old-tmp-sale-gds-attr.prod-type and   new-goods.prod-code = old-tmp-sale-gds-attr.prod-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tmp-sale-gds-attr.
   buffer-copy old-tmp-sale-gds-attr to new-tmp-sale-gds-attr.
end.
for each old-tmp-sale-dtl  no-lock , first new-goods  where   new-goods.artic = old-tmp-sale-dtl.artic and   new-goods.prod-type = old-tmp-sale-dtl.prod-type and   new-goods.prod-code = old-tmp-sale-dtl.prod-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tmp-sale-dtl.
   buffer-copy old-tmp-sale-dtl to new-tmp-sale-dtl.
end.
for each old-tmp-sale-dtl-attr  no-lock , first new-goods where   new-goods.artic = old-tmp-sale-dtl-attr.artic and   new-goods.prod-type = old-tmp-sale-dtl-attr.prod-type and   new-goods.prod-code = old-tmp-sale-dtl-attr.prod-code    no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tmp-sale-dtl-attr.
   buffer-copy old-tmp-sale-dtl-attr to new-tmp-sale-dtl-attr.
end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: tmp-sale tmp-sale-gds tmp-sale-dtl .".
end.
