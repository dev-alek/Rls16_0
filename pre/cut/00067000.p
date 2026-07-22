block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00067000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00067000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 67.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-country for src.country.
define buffer new-country for dst.country.
define buffer old-c-country for src.c-country.
define buffer new-c-country for dst.c-country.
define buffer old-country-attr for src.country-attr.
define buffer new-country-attr for dst.country-attr.
define buffer old-c-country-attr for src.c-country-attr.
define buffer new-c-country-attr for dst.c-country-attr.
define buffer old-c-regions      for src.c-regions   .
define buffer old-regions        for src.regions     .
define buffer old-regions-attr   for src.regions-attr.
define buffer new-c-regions      for dst.c-regions   .
define buffer new-regions        for dst.regions     .
define buffer new-regions-attr   for dst.regions-attr.
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
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
on WRITE of dst.country override do: end.
on WRITE of dst.c-country override do: end.
on WRITE of dst.country-attr override do: end.
on WRITE of dst.c-country-attr override do: end.
on WRITE of dst.c-regions      override do: end.
on WRITE of dst.regions        override do: end.
on WRITE of dst.regions-attr   override do: end.
for each old-country  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-country.
   buffer-copy old-country to new-country.
end.
if varstay-history then do:
for each old-c-country  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-country.
   buffer-copy old-c-country to new-c-country.
end.
end.
for each old-country-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-country-attr.
   buffer-copy old-country-attr to new-country-attr.
end.
if varstay-history then do:
for each old-c-country-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-country-attr.
   buffer-copy old-c-country-attr to new-c-country-attr.
end.
end.
for each old-regions  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-regions.
   buffer-copy old-regions to new-regions.
end.
for each old-regions-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-regions-attr.
   buffer-copy old-regions-attr to new-regions-attr.
end.
if varstay-history then do:
for each old-c-regions  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-regions.
   buffer-copy old-c-regions to new-c-regions.
end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: country c-country country-attr c-country-attr " +
"~
c-regions ~
regions ~
regions-attr ~
.".
end.
