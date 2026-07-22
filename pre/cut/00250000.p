block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00250000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00250000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 230.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-c-place-io      for src.c-place-io    .
define buffer old-c-point-io      for src.c-point-io    .
define buffer old-place-io        for src.place-io      .
define buffer old-place-io-attr   for src.place-io-attr .
define buffer old-point-io        for src.point-io      .
define buffer old-point-io-attr   for src.point-io-attr .
define buffer old-point-place-rel for src.point-place-rel  .
define buffer old-c-point-place-rel for src.c-point-place-rel  .
define buffer old-point-point-rel   for src.point-point-rel      .
define buffer old-c-point-point-rel   for src.c-point-point-rel      .
define buffer new-c-place-io     for dst.c-place-io     .
define buffer new-c-point-io     for dst.c-point-io     .
define buffer new-place-io       for dst.place-io       .
define buffer new-place-io-attr  for dst.place-io-attr  .
define buffer new-point-io       for dst.point-io       .
define buffer new-point-io-attr  for dst.point-io-attr  .
define buffer new-point-place-rel for dst.point-place-rel  .
define buffer new-c-point-place-rel for dst.c-point-place-rel  .
define buffer new-point-point-rel   for dst.point-point-rel       .
define buffer new-c-point-point-rel   for dst.c-point-point-rel       .
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
on WRITE of dst.c-place-io     override do: end.
on WRITE of dst.c-point-io     override do: end.
on WRITE of dst.place-io       override do: end.
on WRITE of dst.place-io-attr  override do: end.
on WRITE of dst.point-io       override do: end.
on WRITE of dst.point-io-attr  override do: end.
on WRITE of dst.point-place-rel override do: end.
on WRITE of dst.c-point-place-rel override do: end.
on WRITE of dst.point-point-rel    override do: end.
on WRITE of dst.c-point-point-rel  override do: end.
for each old-place-io  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-place-io.
   buffer-copy old-place-io to new-place-io.
end.
for each old-place-io-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-place-io-attr.
   buffer-copy old-place-io-attr to new-place-io-attr.
end.
for each old-point-io  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-point-io.
   buffer-copy old-point-io to new-point-io.
end.
for each old-point-io-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-point-io-attr.
   buffer-copy old-point-io-attr to new-point-io-attr.
end.
for each old-point-place-rel  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-point-place-rel.
   buffer-copy old-point-place-rel to new-point-place-rel.
end.
for each old-point-point-rel  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-point-point-rel.
   buffer-copy old-point-point-rel to new-point-point-rel.
end.
  if varstay-history = yes then do:
for each old-c-place-io  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-place-io.
   buffer-copy old-c-place-io to new-c-place-io.
end.
for each old-c-point-io  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-point-io.
   buffer-copy old-c-point-io to new-c-point-io.
end.
for each old-c-point-place-rel  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-point-place-rel.
   buffer-copy old-c-point-place-rel to new-c-point-place-rel.
end.
for each old-c-point-point-rel  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-point-point-rel.
   buffer-copy old-c-point-point-rel to new-c-point-point-rel.
end.
  end.
output stream str-gen close.
return "Произведен экспорт таблиц: ~
  c-place-io ~
  c-point-io ~
  place-io ~
  place-io-attr ~
  point-io ~
  point-io-attr ~
  point-place-rel ~
  c-point-place-rel ~
  ".
end.
