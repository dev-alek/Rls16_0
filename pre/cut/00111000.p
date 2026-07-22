block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00111000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00111000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 111.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-ext-system for src.ext-system.
define buffer new-ext-system for dst.ext-system.
define buffer old-c-ext-system for src.c-ext-system.
define buffer new-c-ext-system for dst.c-ext-system.
define buffer old-ext-system-attr for src.ext-system-attr.
define buffer new-ext-system-attr for dst.ext-system-attr.
define buffer old-esys-all-attr for src.esys-all-attr.
define buffer new-esys-all-attr for dst.esys-all-attr.
define buffer old-esys-pck-keys for src.esys-pck-keys.
define buffer new-esys-pck-keys for dst.esys-pck-keys.
define buffer old-esys-pck-rcvd for src.esys-pck-rcvd.
define buffer new-esys-pck-rcvd for dst.esys-pck-rcvd.
define buffer old-esys-pck-sent for src.esys-pck-sent.
define buffer new-esys-pck-sent for dst.esys-pck-sent.
define buffer old-esys-route for src.esys-route.
define buffer new-esys-route for dst.esys-route.
define buffer old-esys-route-dump for src.esys-route-dump.
define buffer new-esys-route-dump for dst.esys-route-dump.
define buffer old-c-esys-datatype-exp      for src.c-esys-datatype-exp     .
define buffer old-c-esys-datatype-imp      for src.c-esys-datatype-imp     .
define buffer old-datatype-exp             for src.datatype-exp            .
define buffer old-datatype-exp-attr        for src.datatype-exp-attr       .
define buffer old-datatype-imp             for src.datatype-imp            .
define buffer old-datatype-imp-attr        for src.datatype-imp-attr       .
define buffer old-datatype-table           for src.datatype-table          .
define buffer old-datatype-table-exp       for src.datatype-table-exp      .
define buffer old-datatype-table-field     for src.datatype-table-field    .
define buffer old-datatype-table-field-exp for src.datatype-table-field-exp.
define buffer old-datatype-table-field-imp for src.datatype-table-field-imp.
define buffer old-datatype-table-imp       for src.datatype-table-imp      .
define buffer old-esys-datatype-exp        for src.esys-datatype-exp       .
define buffer old-esys-datatype-imp        for src.esys-datatype-imp       .
define buffer new-c-esys-datatype-exp      for dst.c-esys-datatype-exp     .
define buffer new-c-esys-datatype-imp      for dst.c-esys-datatype-imp     .
define buffer new-datatype-exp             for dst.datatype-exp            .
define buffer new-datatype-exp-attr        for dst.datatype-exp-attr       .
define buffer new-datatype-imp             for dst.datatype-imp            .
define buffer new-datatype-imp-attr        for dst.datatype-imp-attr       .
define buffer new-datatype-table           for dst.datatype-table          .
define buffer new-datatype-table-exp       for dst.datatype-table-exp      .
define buffer new-datatype-table-field     for dst.datatype-table-field    .
define buffer new-datatype-table-field-exp for dst.datatype-table-field-exp.
define buffer new-datatype-table-field-imp for dst.datatype-table-field-imp.
define buffer new-datatype-table-imp       for dst.datatype-table-imp      .
define buffer new-esys-datatype-exp        for dst.esys-datatype-exp       .
define buffer new-esys-datatype-imp        for dst.esys-datatype-imp       .
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
on WRITE of dst.ext-system override do: end.
on WRITE of dst.c-ext-system override do: end.
on WRITE of dst.ext-system-attr override do: end.
on WRITE of dst.esys-all-attr override do: end.
on WRITE of dst.esys-pck-keys override do: end.
on WRITE of dst.esys-pck-rcvd override do: end.
on WRITE of dst.esys-pck-sent override do: end.
on WRITE of dst.esys-route override do: end.
on WRITE of dst.esys-route-dump override do: end.
on WRITE of dst.c-esys-datatype-exp      override do: end.
on WRITE of dst.c-esys-datatype-imp      override do: end.
on WRITE of dst.datatype-exp             override do: end.
on WRITE of dst.datatype-exp-attr        override do: end.
on WRITE of dst.datatype-imp             override do: end.
on WRITE of dst.datatype-imp-attr        override do: end.
on WRITE of dst.datatype-table           override do: end.
on WRITE of dst.datatype-table-exp       override do: end.
on WRITE of dst.datatype-table-field     override do: end.
on WRITE of dst.datatype-table-field-exp override do: end.
on WRITE of dst.datatype-table-field-imp override do: end.
on WRITE of dst.datatype-table-imp       override do: end.
on WRITE of dst.esys-datatype-exp        override do: end.
on WRITE of dst.esys-datatype-imp        override do: end.
for each old-ext-system  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ext-system.
   buffer-copy old-ext-system to new-ext-system.
end.
if varstay-history then do:
for each old-c-ext-system  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-ext-system.
   buffer-copy old-c-ext-system to new-c-ext-system.
end.
end.
for each old-ext-system-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ext-system-attr.
   buffer-copy old-ext-system-attr to new-ext-system-attr.
end.
for each old-esys-all-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-esys-all-attr.
   buffer-copy old-esys-all-attr to new-esys-all-attr.
end.
for each old-esys-pck-keys  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-esys-pck-keys.
   buffer-copy old-esys-pck-keys to new-esys-pck-keys.
end.
for each old-esys-pck-rcvd  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-esys-pck-rcvd.
   buffer-copy old-esys-pck-rcvd to new-esys-pck-rcvd.
end.
for each old-esys-pck-sent  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-esys-pck-sent.
   buffer-copy old-esys-pck-sent to new-esys-pck-sent.
end.
for each old-esys-route  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-esys-route.
   buffer-copy old-esys-route to new-esys-route.
end.
for each old-esys-route-dump  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-esys-route-dump.
   buffer-copy old-esys-route-dump to new-esys-route-dump.
end.
for each old-datatype-exp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-datatype-exp.
   buffer-copy old-datatype-exp to new-datatype-exp.
end.
for each old-datatype-exp-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-datatype-exp-attr.
   buffer-copy old-datatype-exp-attr to new-datatype-exp-attr.
end.
for each old-datatype-imp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-datatype-imp.
   buffer-copy old-datatype-imp to new-datatype-imp.
end.
for each old-datatype-imp-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-datatype-imp-attr.
   buffer-copy old-datatype-imp-attr to new-datatype-imp-attr.
end.
for each old-datatype-table  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-datatype-table.
   buffer-copy old-datatype-table to new-datatype-table.
end.
for each old-datatype-table-exp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-datatype-table-exp.
   buffer-copy old-datatype-table-exp to new-datatype-table-exp.
end.
for each old-datatype-table-field  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-datatype-table-field.
   buffer-copy old-datatype-table-field to new-datatype-table-field.
end.
for each old-datatype-table-field-exp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-datatype-table-field-exp.
   buffer-copy old-datatype-table-field-exp to new-datatype-table-field-exp.
end.
for each old-datatype-table-field-imp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-datatype-table-field-imp.
   buffer-copy old-datatype-table-field-imp to new-datatype-table-field-imp.
end.
for each old-datatype-table-imp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-datatype-table-imp.
   buffer-copy old-datatype-table-imp to new-datatype-table-imp.
end.
for each old-esys-datatype-exp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-esys-datatype-exp.
   buffer-copy old-esys-datatype-exp to new-esys-datatype-exp.
end.
for each old-esys-datatype-imp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-esys-datatype-imp.
   buffer-copy old-esys-datatype-imp to new-esys-datatype-imp.
end.
if varstay-history then do:
for each old-c-esys-datatype-exp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-esys-datatype-exp.
   buffer-copy old-c-esys-datatype-exp to new-c-esys-datatype-exp.
end.
for each old-c-esys-datatype-imp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-esys-datatype-imp.
   buffer-copy old-c-esys-datatype-imp to new-c-esys-datatype-imp.
end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: ext-system c-ext-system ext-system-attr esys-all-attr" +
"esys-pck-keys esys-pck-rcvd esys-pck-sent esys-route esys-route-dump" +
"~
c-esys-datatype-exp ~
c-esys-datatype-imp ~
datatype-exp ~
datatype-exp-attr ~
datatype-imp ~
datatype-imp-attr ~
datatype-table ~
datatype-table-exp ~
datatype-table-field ~
datatype-table-field-exp ~
datatype-table-field-imp ~
datatype-table-imp ~
esys-datatype-exp ~
esys-datatype-imp ~
.".
end.
