block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00175000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00175000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 175.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-units      for src.units.
define buffer new-units      for dst.units.
define buffer old-c-units    for src.c-units.
define buffer new-c-units    for dst.c-units.
define buffer old-units-attr for src.units-attr.
define buffer new-units-attr for dst.units-attr.
define buffer old-tare      for src.tare.
define buffer new-tare      for dst.tare.
define buffer old-c-tare    for src.c-tare.
define buffer new-c-tare    for dst.c-tare.
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
on WRITE of dst.units override do: end.
on WRITE of dst.c-units override do: end.
on WRITE of dst.tare override do: end.
on WRITE of dst.c-tare override do: end.
on WRITE of dst.units-attr override do: end.
for each old-units  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-units.
   buffer-copy old-units to new-units.
end.
if varstay-history then do:
for each old-c-units  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-units.
   buffer-copy old-c-units to new-c-units.
end.
end.
for each old-units-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-units-attr.
   buffer-copy old-units-attr to new-units-attr.
end.
for each old-tare  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tare.
   buffer-copy old-tare to new-tare.
end.
if varstay-history then do:
for each old-c-tare  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-tare.
   buffer-copy old-c-tare to new-c-tare.
end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: units c-units units-attr tare c-tare .".
end.
