block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00210000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00210000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 210.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-upgrade       for src.upgrade.
define buffer new-upgrade       for dst.upgrade.
define buffer old-condition-keeping             for src.condition-keeping          .
define buffer new-condition-keeping             for dst.condition-keeping          .
define buffer old-c-condition-keeping           for src.c-condition-keeping        .
define buffer new-c-condition-keeping           for dst.c-condition-keeping        .
define buffer old-condition-keeping-attr        for src.condition-keeping-attr          .
define buffer new-condition-keeping-attr        for dst.condition-keeping-attr          .
define buffer old-c-condition-keeping-attr      for src.c-condition-keeping-attr        .
define buffer new-c-condition-keeping-attr      for dst.c-condition-keeping-attr        .
define buffer old-deliv-type-cond-keep          for src.deliv-type-cond-keep       .
define buffer new-deliv-type-cond-keep          for dst.deliv-type-cond-keep       .
define buffer old-c-deliv-type-cond-keep        for src.c-deliv-type-cond-keep     .
define buffer new-c-deliv-type-cond-keep        for dst.c-deliv-type-cond-keep     .
define buffer old-deliv-type-cond-keep-attr     for src.deliv-type-cond-keep-attr       .
define buffer new-deliv-type-cond-keep-attr     for dst.deliv-type-cond-keep-attr       .
define buffer old-c-deliv-type-cond-keep-attr   for src.c-deliv-type-cond-keep-attr     .
define buffer new-c-deliv-type-cond-keep-attr   for dst.c-deliv-type-cond-keep-attr     .
define buffer old-delivery-subject              for src.delivery-subject           .
define buffer new-delivery-subject              for dst.delivery-subject           .
define buffer old-c-delivery-subject            for src.c-delivery-subject         .
define buffer new-c-delivery-subject            for dst.c-delivery-subject         .
define buffer old-delivery-subject-attr         for src.delivery-subject-attr      .
define buffer new-delivery-subject-attr         for dst.delivery-subject-attr    .
define buffer old-c-delivery-subject-attr       for src.c-delivery-subject-attr    .
define buffer new-c-delivery-subject-attr       for dst.c-delivery-subject-attr    .
define buffer old-delivery-type                 for src.delivery-type              .
define buffer new-delivery-type                 for dst.delivery-type              .
define buffer old-c-delivery-type               for src.c-delivery-type            .
define buffer new-c-delivery-type               for dst.c-delivery-type            .
define buffer old-delivery-type-attr            for src.delivery-type-attr              .
define buffer new-delivery-type-attr            for dst.delivery-type-attr              .
define buffer old-c-delivery-type-attr          for src.c-delivery-type-attr            .
define buffer new-c-delivery-type-attr          for dst.c-delivery-type-attr            .
define buffer old-delivery-type-subject         for src.delivery-type-subject      .
define buffer new-delivery-type-subject         for dst.delivery-type-subject      .
define buffer old-c-delivery-type-subject       for src.c-delivery-type-subject    .
define buffer new-c-delivery-type-subject       for dst.c-delivery-type-subject    .
define buffer old-delivery-type-subject-attr    for src.delivery-type-subject-attr      .
define buffer new-delivery-type-subject-attr    for dst.delivery-type-subject-attr      .
define buffer old-c-delivery-type-subject-attr  for src.c-delivery-type-subject-attr    .
define buffer new-c-delivery-type-subject-attr  for dst.c-delivery-type-subject-attr    .
define buffer old-group-period-validity         for src.group-period-validity      .
define buffer new-group-period-validity         for dst.group-period-validity      .
define buffer old-c-group-period-validity       for src.c-group-period-validity    .
define buffer new-c-group-period-validity       for dst.c-group-period-validity    .
define buffer old-group-period-validity-attr    for src.group-period-validity-attr      .
define buffer new-group-period-validity-attr    for dst.group-period-validity-attr      .
define buffer old-c-group-period-validity-attr  for src.c-group-period-validity-attr    .
define buffer new-c-group-period-validity-attr  for dst.c-group-period-validity-attr    .
define buffer old-var-deliv-gr-per-val          for src.var-deliv-gr-per-val       .
define buffer new-var-deliv-gr-per-val          for dst.var-deliv-gr-per-val       .
define buffer old-c-var-deliv-gr-per-val        for src.c-var-deliv-gr-per-val     .
define buffer new-c-var-deliv-gr-per-val        for dst.c-var-deliv-gr-per-val     .
define buffer old-var-deliv-gr-per-val-attr     for src.var-deliv-gr-per-val-attr  .
define buffer new-var-deliv-gr-per-val-attr     for dst.var-deliv-gr-per-val-attr  .
define buffer old-variant-delivery              for src.variant-delivery           .
define buffer new-variant-delivery              for dst.variant-delivery           .
define buffer old-c-variant-delivery            for src.c-variant-delivery         .
define buffer new-c-variant-delivery            for dst.c-variant-delivery         .
define buffer old-variant-delivery-attr         for src.variant-delivery-attr      .
define buffer new-variant-delivery-attr         for dst.variant-delivery-attr      .
on WRITE of dst.condition-keeping               override do: end.
on WRITE of dst.c-condition-keeping             override do: end.
on WRITE of dst.condition-keeping-attr          override do: end.
on WRITE of dst.c-condition-keeping-attr        override do: end.
on WRITE of dst.deliv-type-cond-keep            override do: end.
on WRITE of dst.c-deliv-type-cond-keep          override do: end.
on WRITE of dst.deliv-type-cond-keep-attr       override do: end.
on WRITE of dst.c-deliv-type-cond-keep-attr     override do: end.
on WRITE of dst.delivery-subject                override do: end.
on WRITE of dst.c-delivery-subject              override do: end.
on WRITE of dst.delivery-subject-attr           override do: end.
on WRITE of dst.c-delivery-subject-attr         override do: end.
on WRITE of dst.delivery-type                   override do: end.
on WRITE of dst.c-delivery-type                 override do: end.
on WRITE of dst.delivery-type-attr              override do: end.
on WRITE of dst.c-delivery-type-attr            override do: end.
on WRITE of dst.delivery-type-subject           override do: end.
on WRITE of dst.c-delivery-type-subject         override do: end.
on WRITE of dst.delivery-type-subject-attr      override do: end.
on WRITE of dst.c-delivery-type-subject-attr    override do: end.
on WRITE of dst.group-period-validity           override do: end.
on WRITE of dst.c-group-period-validity         override do: end.
on WRITE of dst.group-period-validity-attr      override do: end.
on WRITE of dst.c-group-period-validity-attr    override do: end.
on WRITE of dst.var-deliv-gr-per-val            override do: end.
on WRITE of dst.c-var-deliv-gr-per-val          override do: end.
on WRITE of dst.var-deliv-gr-per-val-attr       override do: end.
on WRITE of dst.variant-delivery                override do: end.
on WRITE of dst.c-variant-delivery              override do: end.
on WRITE of dst.variant-delivery-attr           override do: end.
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
for each old-condition-keeping  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-condition-keeping.
   buffer-copy old-condition-keeping to new-condition-keeping.
end.
  if varstay-history then do:
for each old-c-condition-keeping  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-condition-keeping.
   buffer-copy old-c-condition-keeping to new-c-condition-keeping.
end.
  end.
for each old-condition-keeping-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-condition-keeping-attr.
   buffer-copy old-condition-keeping-attr to new-condition-keeping-attr.
end.
  if varstay-history then do:
for each old-c-condition-keeping-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-condition-keeping-attr.
   buffer-copy old-c-condition-keeping-attr to new-c-condition-keeping-attr.
end.
  end.
for each old-deliv-type-cond-keep  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-deliv-type-cond-keep.
   buffer-copy old-deliv-type-cond-keep to new-deliv-type-cond-keep.
end.
  if varstay-history then do:
for each old-c-deliv-type-cond-keep  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-deliv-type-cond-keep.
   buffer-copy old-c-deliv-type-cond-keep to new-c-deliv-type-cond-keep.
end.
  end.
for each old-deliv-type-cond-keep-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-deliv-type-cond-keep-attr.
   buffer-copy old-deliv-type-cond-keep-attr to new-deliv-type-cond-keep-attr.
end.
  if varstay-history then do:
for each old-c-deliv-type-cond-keep-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-deliv-type-cond-keep-attr.
   buffer-copy old-c-deliv-type-cond-keep-attr to new-c-deliv-type-cond-keep-attr.
end.
  end.
for each old-delivery-subject  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-delivery-subject.
   buffer-copy old-delivery-subject to new-delivery-subject.
end.
  if varstay-history then do:
for each old-c-delivery-subject  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-delivery-subject.
   buffer-copy old-c-delivery-subject to new-c-delivery-subject.
end.
  end.
for each old-delivery-subject-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-delivery-subject-attr.
   buffer-copy old-delivery-subject-attr to new-delivery-subject-attr.
end.
  if varstay-history then do:
for each old-c-delivery-subject-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-delivery-subject-attr.
   buffer-copy old-c-delivery-subject-attr to new-c-delivery-subject-attr.
end.
  end.
for each old-delivery-type  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-delivery-type.
   buffer-copy old-delivery-type to new-delivery-type.
end.
  if varstay-history then do:
for each old-c-delivery-type  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-delivery-type.
   buffer-copy old-c-delivery-type to new-c-delivery-type.
end.
  end.
for each old-delivery-type-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-delivery-type-attr.
   buffer-copy old-delivery-type-attr to new-delivery-type-attr.
end.
  if varstay-history then do:
for each old-c-delivery-type-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-delivery-type-attr.
   buffer-copy old-c-delivery-type-attr to new-c-delivery-type-attr.
end.
  end.
for each old-delivery-type-subject  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-delivery-type-subject.
   buffer-copy old-delivery-type-subject to new-delivery-type-subject.
end.
  if varstay-history then do:
for each old-c-delivery-type-subject  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-delivery-type-subject.
   buffer-copy old-c-delivery-type-subject to new-c-delivery-type-subject.
end.
  end.
for each old-delivery-type-subject-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-delivery-type-subject-attr.
   buffer-copy old-delivery-type-subject-attr to new-delivery-type-subject-attr.
end.
  if varstay-history then do:
for each old-c-delivery-type-subject-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-delivery-type-subject-attr.
   buffer-copy old-c-delivery-type-subject-attr to new-c-delivery-type-subject-attr.
end.
  end.
for each old-group-period-validity  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-group-period-validity.
   buffer-copy old-group-period-validity to new-group-period-validity.
end.
  if varstay-history then do:
for each old-c-group-period-validity  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-group-period-validity.
   buffer-copy old-c-group-period-validity to new-c-group-period-validity.
end.
  end.
for each old-group-period-validity-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-group-period-validity-attr.
   buffer-copy old-group-period-validity-attr to new-group-period-validity-attr.
end.
  if varstay-history then do:
for each old-c-group-period-validity-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-group-period-validity-attr.
   buffer-copy old-c-group-period-validity-attr to new-c-group-period-validity-attr.
end.
  end.
for each old-var-deliv-gr-per-val  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-var-deliv-gr-per-val.
   buffer-copy old-var-deliv-gr-per-val to new-var-deliv-gr-per-val.
end.
  if varstay-history then do:
for each old-c-var-deliv-gr-per-val  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-var-deliv-gr-per-val.
   buffer-copy old-c-var-deliv-gr-per-val to new-c-var-deliv-gr-per-val.
end.
  end.
for each old-var-deliv-gr-per-val-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-var-deliv-gr-per-val-attr.
   buffer-copy old-var-deliv-gr-per-val-attr to new-var-deliv-gr-per-val-attr.
end.
for each old-variant-delivery  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-variant-delivery.
   buffer-copy old-variant-delivery to new-variant-delivery.
end.
  if varstay-history then do:
for each old-c-variant-delivery  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-variant-delivery.
   buffer-copy old-c-variant-delivery to new-c-variant-delivery.
end.
  end.
for each old-variant-delivery-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-variant-delivery-attr.
   buffer-copy old-variant-delivery-attr to new-variant-delivery-attr.
end.
output stream str-gen close.
  return "Произведен экспорт таблиц: condition-keeping c-condition-keeping condition-keeping-attr c-condition-keeping-attr " +
"deliv-type-cond-keep c-deliv-type-cond-keep deliv-type-cond-keep-attr c-deliv-type-cond-keep-attr " +
"delivery-subject c-delivery-subject  delivery-subject-attr c-delivery-subject-attr " +
"delivery-type c-delivery-type delivery-type-attr c-delivery-type-attr " +
"delivery-type-subject c-delivery-type-subject delivery-type-subject-attr c-delivery-type-subject-attr " +
"group-period-validity c-group-period-validity group-period-validity-attr c-group-period-validity-attr " +
"var-deliv-gr-per-val c-var-deliv-gr-per-val var-deliv-gr-per-val " +
"variant-delivery c-variant-delivery variant-delivery.".
end.
