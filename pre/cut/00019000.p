block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00019000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00019000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 19.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-tax              for src.tax             .
define buffer new-tax              for dst.tax             .
define buffer old-c-tax            for src.c-tax           .
define buffer new-c-tax            for dst.c-tax           .
define buffer old-tax-attr         for src.tax-attr        .
define buffer new-tax-attr         for dst.tax-attr        .
define buffer old-tax-rate-gds     for src.tax-rate-gds    .
define buffer new-tax-rate-gds     for dst.tax-rate-gds    .
define buffer old-tax-rate-gds-attr for src.tax-rate-gds-attr .
define buffer new-tax-rate-gds-attr for dst.tax-rate-gds-attr .
define buffer old-tax-rate         for src.tax-rate        .
define buffer new-tax-rate         for dst.tax-rate        .
define buffer old-c-tax-rate       for src.c-tax-rate      .
define buffer new-c-tax-rate       for dst.c-tax-rate      .
define buffer old-tax-rate-attr    for src.tax-rate-attr   .
define buffer new-tax-rate-attr    for dst.tax-rate-attr   .
define buffer old-tax-rate-value   for src.tax-rate-value  .
define buffer new-tax-rate-value   for dst.tax-rate-value  .
define buffer old-tax-rate-value-attr   for src.tax-rate-value-attr .
define buffer new-tax-rate-value-attr   for dst.tax-rate-value-attr  .
define buffer old-c-tax-rate-gds-grp for src.c-tax-rate-gds-grp.
define buffer new-c-tax-rate-gds-grp for dst.c-tax-rate-gds-grp.
define buffer old-tax-rate-gds-grp for src.tax-rate-gds-grp.
define buffer new-tax-rate-gds-grp for dst.tax-rate-gds-grp.
define buffer old-tax-rate-gds-grp-attr for src.tax-rate-gds-grp-attr.
define buffer new-tax-rate-gds-grp-attr for dst.tax-rate-gds-grp-attr.
define buffer old-tax-units        for src.tax-units       .
define buffer new-tax-units        for dst.tax-units       .
define buffer old-c-tax-units      for src.c-tax-units       .
define buffer new-c-tax-units      for dst.c-tax-units       .
define buffer old-tax-units-attr   for src.tax-units-attr       .
define buffer new-tax-units-attr   for dst.tax-units-attr       .
define buffer old-c-tax-hist       for src.c-tax-hist       .
define buffer new-c-tax-hist       for dst.c-tax-hist       .
define buffer new-goods            for dst.goods.
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
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
on WRITE of dst.tax                override do: end.
on WRITE of dst.tax-attr           override do: end.
on WRITE of dst.c-tax              override do: end.
on WRITE of dst.tax-rate-gds       override do: end.
on WRITE of dst.tax-rate-gds-attr  override do: end.
on WRITE of dst.tax-rate           override do: end.
on WRITE of dst.c-tax-rate         override do: end.
on WRITE of dst.tax-rate-attr      override do: end.
on WRITE of dst.tax-rate-value     override do: end.
on WRITE of dst.tax-rate-value-attr override do: end.
on WRITE of dst.tax-rate-gds-grp   override do: end.
on WRITE of dst.c-tax-rate-gds-grp override do: end.
on WRITE of dst.tax-rate-gds-grp-attr   override do: end.
on WRITE of dst.tax-units          override do: end.
on WRITE of dst.c-tax-units        override do: end.
on WRITE of dst.tax-units-attr     override do: end.
on WRITE of dst.c-tax-hist         override do: end.
for each old-tax  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tax.
   buffer-copy old-tax to new-tax.
end.
for each old-tax-rate-gds no-lock,
   first new-goods where new-goods.gds-code    = old-tax-rate-gds.gds-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  create new-tax-rate-gds.
  buffer-copy old-tax-rate-gds to new-tax-rate-gds.
end.
for each old-tax-rate-gds-attr no-lock,
   first new-goods where new-goods.gds-code    = old-tax-rate-gds-attr.gds-code no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  create new-tax-rate-gds-attr.
  buffer-copy old-tax-rate-gds-attr to new-tax-rate-gds-attr.
end.
for each old-tax-rate  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tax-rate.
   buffer-copy old-tax-rate to new-tax-rate.
end.
for each old-tax-rate-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tax-rate-attr.
   buffer-copy old-tax-rate-attr to new-tax-rate-attr.
end.
for each old-tax-rate-value  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tax-rate-value.
   buffer-copy old-tax-rate-value to new-tax-rate-value.
end.
for each old-tax-rate-value-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tax-rate-value-attr.
   buffer-copy old-tax-rate-value-attr to new-tax-rate-value-attr.
end.
for each old-tax-rate-gds-grp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tax-rate-gds-grp.
   buffer-copy old-tax-rate-gds-grp to new-tax-rate-gds-grp.
end.
for each old-tax-rate-gds-grp-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tax-rate-gds-grp-attr.
   buffer-copy old-tax-rate-gds-grp-attr to new-tax-rate-gds-grp-attr.
end.
for each old-tax-units  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tax-units.
   buffer-copy old-tax-units to new-tax-units.
end.
for each old-tax-units-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-tax-units-attr.
   buffer-copy old-tax-units-attr to new-tax-units-attr.
end.
if varstay-history then do:
for each old-c-tax  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-tax.
   buffer-copy old-c-tax to new-c-tax.
end.
for each old-c-tax-rate  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-tax-rate.
   buffer-copy old-c-tax-rate to new-c-tax-rate.
end.
for each old-c-tax-rate-gds-grp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-tax-rate-gds-grp.
   buffer-copy old-c-tax-rate-gds-grp to new-c-tax-rate-gds-grp.
end.
for each old-c-tax-units  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-tax-units.
   buffer-copy old-c-tax-units to new-c-tax-units.
end.
for each old-c-tax-hist  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-tax-hist.
   buffer-copy old-c-tax-hist to new-c-tax-hist.
end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: tax c-tax-hist c-tax tax-attr tax-rate-gds tax-rate-gds-attr tax-rate c-tax-rate tax-rate-attr tax-rate-value tax-rate-value-attr ~
tax-rate-gds-grp c-tax-rate-gds-grp tax-rate-gds-grp-attr tax-units c-tax-units tax-units-attr ".
end.
