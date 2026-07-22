block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00151000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00151000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 151.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-sum-grp          for src.sum-grp   .
define buffer new-sum-grp          for dst.sum-grp   .
define buffer old-c-sum-grp        for src.c-sum-grp   .
define buffer new-c-sum-grp        for dst.c-sum-grp   .
define buffer old-sum-grp-attr     for src.sum-grp-attr   .
define buffer new-sum-grp-attr     for dst.sum-grp-attr   .
define buffer old-sum-grp-obj      for src.sum-grp-obj .
define buffer new-sum-grp-obj      for dst.sum-grp-obj .
define buffer old-c-sum-grp-obj    for src.c-sum-grp-obj .
define buffer new-c-sum-grp-obj    for dst.c-sum-grp-obj .
define buffer old-sum-grp-obj-attr for src.sum-grp-obj-attr .
define buffer new-sum-grp-obj-attr for dst.sum-grp-obj-attr .
define buffer old-scales           for src.scales    .
define buffer new-scales           for dst.scales    .
define buffer old-c-scales         for src.c-scales    .
define buffer new-c-scales         for dst.c-scales    .
define buffer old-scales-attr      for src.scales-attr    .
define buffer new-scales-attr      for dst.scales-attr    .
define buffer old-c-scales-attr    for src.c-scales-attr    .
define buffer new-c-scales-attr    for dst.c-scales-attr    .
define buffer old-scales-gds       for src.scales-gds.
define buffer new-scales-gds       for dst.scales-gds.
define buffer old-c-scales-gds     for src.c-scales-gds.
define buffer new-c-scales-gds     for dst.c-scales-gds.
define buffer old-scales-gds-attr  for src.scales-gds-attr.
define buffer new-scales-gds-attr  for dst.scales-gds-attr.
define buffer old-scales-grp       for src.scales-grp.
define buffer new-scales-grp       for dst.scales-grp.
define buffer old-c-scales-grp     for src.c-scales-grp.
define buffer new-c-scales-grp     for dst.c-scales-grp.
define buffer old-scales-grp-attr  for src.scales-grp-attr.
define buffer new-scales-grp-attr  for dst.scales-grp-attr.
define buffer new-goods      for dst.goods     .
define buffer new-bar-code   for dst.bar-code  .
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
on WRITE of dst.sum-grp         override do: end.
on WRITE of dst.c-sum-grp       override do: end.
on WRITE of dst.sum-grp-attr    override do: end.
on WRITE of dst.sum-grp-obj     override do: end.
on WRITE of dst.c-sum-grp-obj   override do: end.
on WRITE of dst.sum-grp-obj-attr override do: end.
on WRITE of dst.scales          override do: end.
on WRITE of dst.c-scales        override do: end.
on WRITE of dst.scales-attr     override do: end.
on WRITE of dst.c-scales-attr   override do: end.
on WRITE of dst.scales-gds      override do: end.
on WRITE of dst.c-scales-gds    override do: end.
on WRITE of dst.scales-gds-attr override do: end.
on WRITE of dst.scales-grp      override do: end.
on WRITE of dst.c-scales-grp    override do: end.
for each old-sum-grp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-sum-grp.
   buffer-copy old-sum-grp to new-sum-grp.
end.
if varstay-history then do:
for each old-c-sum-grp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-sum-grp.
   buffer-copy old-c-sum-grp to new-c-sum-grp.
end.
end.
for each old-sum-grp-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-sum-grp-attr.
   buffer-copy old-sum-grp-attr to new-sum-grp-attr.
end.
for each old-sum-grp-obj  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-sum-grp-obj.
   buffer-copy old-sum-grp-obj to new-sum-grp-obj.
end.
if varstay-history then do:
for each old-c-sum-grp-obj  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-sum-grp-obj.
   buffer-copy old-c-sum-grp-obj to new-c-sum-grp-obj.
end.
end.
for each old-sum-grp-obj-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-sum-grp-obj-attr.
   buffer-copy old-sum-grp-obj-attr to new-sum-grp-obj-attr.
end.
for each old-scales  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-scales.
   buffer-copy old-scales to new-scales.
end.
if varstay-history then do:
for each old-c-scales  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-scales.
   buffer-copy old-c-scales to new-c-scales.
end.
end.
for each old-scales-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-scales-attr.
   buffer-copy old-scales-attr to new-scales-attr.
end.
if varstay-history then do:
for each old-c-scales-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-scales-attr.
   buffer-copy old-c-scales-attr to new-c-scales-attr.
end.
end.
for each old-scales-grp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-scales-grp.
   buffer-copy old-scales-grp to new-scales-grp.
end.
if varstay-history then do:
for each old-c-scales-grp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-scales-grp.
   buffer-copy old-c-scales-grp to new-c-scales-grp.
end.
end.
for each old-scales-grp-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-scales-grp-attr.
   buffer-copy old-scales-grp-attr to new-scales-grp-attr.
end.
for each old-scales-gds no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  find first new-bar-code where new-bar-code.b-code = old-scales-gds.b-code no-lock  no-error.
  if available new-bar-code then do:
    create new-scales-gds.
    buffer-copy old-scales-gds to new-scales-gds.
    if varstay-history then do:
      for each old-c-scales-gds no-lock where
              old-c-scales-gds.db-num = old-scales-gds.db-num
          and old-c-scales-gds.scales-num = old-scales-gds.scales-num
          and old-c-scales-gds.plu-code = old-scales-gds.plu-code
              on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-c-scales-gds.
        buffer-copy old-c-scales-gds to new-c-scales-gds.
      end.
    end.
    for each old-scales-gds-attr no-lock where
             old-scales-gds-attr.db-num = old-scales-gds.db-num
         and old-scales-gds-attr.scales-num = old-scales-gds.scales-num
         and old-scales-gds-attr.plu-code = old-scales-gds.plu-code
             on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      create new-scales-gds-attr.
      buffer-copy old-scales-gds-attr to new-scales-gds-attr.
    end.
  end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: ~
sum-grp c-sum-grp sum-grp-attr sum-grp-obj c-sum-grp-obj sum-grp-obj-attr ~
scales c-scales scales-attr c-scales-attr scales-gds c-scales-gds scales-gds-attr scales-grp c-scales-grp scales-grp-attr .".
end.
