block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00176000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00176000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 104.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-alc-sale-lic           for src.alc-sale-lic          .
define buffer old-alc-sale-lic-attr      for src.alc-sale-lic-attr     .
define buffer old-alc-sale-lic-type      for src.alc-sale-lic-type     .
define buffer old-alc-sale-lic-type-attr for src.alc-sale-lic-type-attr.
define buffer old-alc-supp-lic           for src.alc-supp-lic          .
define buffer old-alc-supp-lic-attr      for src.alc-supp-lic-attr     .
define buffer old-alc-supp-lic-type      for src.alc-supp-lic-type     .
define buffer old-alc-supp-lic-type-attr for src.alc-supp-lic-type-attr.
define buffer old-alc-type               for src.alc-type              .
define buffer old-alc-type-attr          for src.alc-type-attr         .
define buffer old-alc-type-gds           for src.alc-type-gds          .
define buffer old-alc-type-gds-attr      for src.alc-type-gds-attr     .
define buffer old-c-alc-sale-lic         for src.c-alc-sale-lic        .
define buffer old-c-alc-sale-lic-attr    for src.c-alc-sale-lic-attr   .
define buffer old-c-alc-sale-lic-type    for src.c-alc-sale-lic-type   .
define buffer old-c-alc-supp-lic         for src.c-alc-supp-lic        .
define buffer old-c-alc-supp-lic-attr    for src.c-alc-supp-lic-attr   .
define buffer old-c-alc-supp-lic-type    for src.c-alc-supp-lic-type   .
define buffer old-c-alc-type             for src.c-alc-type            .
define buffer old-c-alc-type-attr        for src.c-alc-type-attr       .
define buffer old-c-alc-type-gds         for src.c-alc-type-gds        .
define buffer old-c-ex-mark              for src.c-ex-mark             .
define buffer old-ex-mark                for src.ex-mark               .
define buffer old-ex-mark-attr           for src.ex-mark-attr          .
define buffer old-egais-clients          for src.egais-clients.
define buffer new-egais-clients          for dst.egais-clients.
define buffer old-c-egais-clients        for src.c-egais-clients.
define buffer new-c-egais-clients        for dst.c-egais-clients.
define buffer new-alc-sale-lic           for dst.alc-sale-lic          .
define buffer new-alc-sale-lic-attr      for dst.alc-sale-lic-attr     .
define buffer new-alc-sale-lic-type      for dst.alc-sale-lic-type     .
define buffer new-alc-sale-lic-type-attr for dst.alc-sale-lic-type-attr.
define buffer new-alc-supp-lic           for dst.alc-supp-lic          .
define buffer new-alc-supp-lic-attr      for dst.alc-supp-lic-attr     .
define buffer new-alc-supp-lic-type      for dst.alc-supp-lic-type     .
define buffer new-alc-supp-lic-type-attr for dst.alc-supp-lic-type-attr.
define buffer new-alc-type               for dst.alc-type              .
define buffer new-alc-type-attr          for dst.alc-type-attr         .
define buffer new-alc-type-gds           for dst.alc-type-gds          .
define buffer new-alc-type-gds-attr      for dst.alc-type-gds-attr     .
define buffer new-c-alc-sale-lic         for dst.c-alc-sale-lic        .
define buffer new-c-alc-sale-lic-attr    for dst.c-alc-sale-lic-attr   .
define buffer new-c-alc-sale-lic-type    for dst.c-alc-sale-lic-type   .
define buffer new-c-alc-supp-lic         for dst.c-alc-supp-lic        .
define buffer new-c-alc-supp-lic-attr    for dst.c-alc-supp-lic-attr   .
define buffer new-c-alc-supp-lic-type    for dst.c-alc-supp-lic-type   .
define buffer new-c-alc-type             for dst.c-alc-type            .
define buffer new-c-alc-type-attr        for dst.c-alc-type-attr       .
define buffer new-c-alc-type-gds         for dst.c-alc-type-gds        .
define buffer new-c-ex-mark              for dst.c-ex-mark             .
define buffer new-ex-mark                for dst.ex-mark               .
define buffer new-ex-mark-attr           for dst.ex-mark-attr          .
define buffer old-egais-gds          for src.egais-gds.
define buffer new-egais-gds          for dst.egais-gds.
define buffer old-c-egais-gds        for src.c-egais-gds.
define buffer new-c-egais-gds        for dst.c-egais-gds.
define buffer new-goods                  for dst.goods .
do
on error undo, return error SUBSTITUTE ( "&1 &2 &3"
                                       , return-value
                                       , error-status:get-message(1)
                                       , error-status:get-message(2)
                                       ) :
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
on WRITE of dst.alc-sale-lic                           override do: end.
on WRITE of dst.alc-sale-lic-attr                      override do: end.
on WRITE of dst.alc-sale-lic-type                      override do: end.
on WRITE of dst.alc-sale-lic-type-attr                 override do: end.
on WRITE of dst.alc-supp-lic                           override do: end.
on WRITE of dst.alc-supp-lic-attr                      override do: end.
on WRITE of dst.alc-supp-lic-type                      override do: end.
on WRITE of dst.alc-supp-lic-type-attr                 override do: end.
on WRITE of dst.alc-type                               override do: end.
on WRITE of dst.alc-type-attr                          override do: end.
on WRITE of dst.alc-type-gds                           override do: end.
on WRITE of dst.alc-type-gds-attr                      override do: end.
on WRITE of dst.c-alc-sale-lic                         override do: end.
on WRITE of dst.c-alc-sale-lic-attr                    override do: end.
on WRITE of dst.c-alc-sale-lic-type                    override do: end.
on WRITE of dst.c-alc-supp-lic                         override do: end.
on WRITE of dst.c-alc-supp-lic-attr                    override do: end.
on WRITE of dst.c-alc-supp-lic-type                    override do: end.
on WRITE of dst.c-alc-type                             override do: end.
on WRITE of dst.c-alc-type-attr                        override do: end.
on WRITE of dst.c-alc-type-gds                         override do: end.
on WRITE of dst.c-ex-mark                              override do: end.
on WRITE of dst.ex-mark                                override do: end.
on WRITE of dst.ex-mark-attr                           override do: end.
on WRITE of dst.egais-clients                          override do: end.
on WRITE of dst.c-egais-clients                        override do: end.
on WRITE of dst.egais-gds                              override do: end.
on WRITE of dst.c-egais-gds                            override do: end.
for each old-alc-sale-lic  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-alc-sale-lic.
   buffer-copy old-alc-sale-lic to new-alc-sale-lic.
end.
for each old-alc-sale-lic-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-alc-sale-lic-attr.
   buffer-copy old-alc-sale-lic-attr to new-alc-sale-lic-attr.
end.
for each old-alc-sale-lic-type  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-alc-sale-lic-type.
   buffer-copy old-alc-sale-lic-type to new-alc-sale-lic-type.
end.
for each old-alc-sale-lic-type-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-alc-sale-lic-type-attr.
   buffer-copy old-alc-sale-lic-type-attr to new-alc-sale-lic-type-attr.
end.
for each old-alc-supp-lic  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-alc-supp-lic.
   buffer-copy old-alc-supp-lic to new-alc-supp-lic.
end.
for each old-alc-supp-lic-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-alc-supp-lic-attr.
   buffer-copy old-alc-supp-lic-attr to new-alc-supp-lic-attr.
end.
for each old-alc-supp-lic-type  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-alc-supp-lic-type.
   buffer-copy old-alc-supp-lic-type to new-alc-supp-lic-type.
end.
for each old-alc-supp-lic-type-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-alc-supp-lic-type-attr.
   buffer-copy old-alc-supp-lic-type-attr to new-alc-supp-lic-type-attr.
end.
for each old-alc-type  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-alc-type.
   buffer-copy old-alc-type to new-alc-type.
end.
for each old-alc-type-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-alc-type-attr.
   buffer-copy old-alc-type-attr to new-alc-type-attr.
end.
for each old-alc-type-gds
    no-lock
    :
   FIND first new-goods
        where new-goods.gds-code = old-alc-type-gds.gds-code
        no-lock
        no-error
        .
   IF AVAILABLE new-goods
   THEN DO:
      create new-alc-type-gds.
      BUFFER-COPY old-alc-type-gds to new-alc-type-gds.
   END.
end.
for each old-alc-type-gds-attr
   no-lock
   :
   FIND first new-goods
        where new-goods.gds-code = old-alc-type-gds-attr.gds-code
        no-lock
        no-error
        .
   IF AVAILABLE new-goods
   THEN DO:
      create new-alc-type-gds-attr.
      BUFFER-COPY old-alc-type-gds-attr to new-alc-type-gds-attr.
   END.
end.
if varstay-history then do:
for each old-c-alc-sale-lic  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-alc-sale-lic.
   buffer-copy old-c-alc-sale-lic to new-c-alc-sale-lic.
end.
end.
if varstay-history then do:
for each old-c-alc-sale-lic-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-alc-sale-lic-attr.
   buffer-copy old-c-alc-sale-lic-attr to new-c-alc-sale-lic-attr.
end.
end.
if varstay-history then do:
for each old-c-alc-sale-lic-type  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-alc-sale-lic-type.
   buffer-copy old-c-alc-sale-lic-type to new-c-alc-sale-lic-type.
end.
end.
if varstay-history then do:
for each old-c-alc-supp-lic  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-alc-supp-lic.
   buffer-copy old-c-alc-supp-lic to new-c-alc-supp-lic.
end.
end.
if varstay-history then do:
for each old-c-alc-supp-lic-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-alc-supp-lic-attr.
   buffer-copy old-c-alc-supp-lic-attr to new-c-alc-supp-lic-attr.
end.
end.
if varstay-history then do:
for each old-c-alc-supp-lic-type  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-alc-supp-lic-type.
   buffer-copy old-c-alc-supp-lic-type to new-c-alc-supp-lic-type.
end.
end.
if varstay-history then do:
for each old-c-alc-type  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-alc-type.
   buffer-copy old-c-alc-type to new-c-alc-type.
end.
end.
if varstay-history then do:
for each old-c-alc-type-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-alc-type-attr.
   buffer-copy old-c-alc-type-attr to new-c-alc-type-attr.
end.
end.
if varstay-history then do:
   for each old-c-alc-type-gds
   no-lock
   :
      FIND first new-goods
         where new-goods.gds-code = old-alc-type-gds-attr.gds-code
         no-lock
         no-error
         .
      IF AVAILABLE new-goods
      THEN DO:
         create new-c-alc-type-gds.
         BUFFER-COPY old-c-alc-type-gds to new-c-alc-type-gds.
      end.
   end.
end.
for each old-ex-mark  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ex-mark.
   buffer-copy old-ex-mark to new-ex-mark.
end.
for each old-ex-mark-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-ex-mark-attr.
   buffer-copy old-ex-mark-attr to new-ex-mark-attr.
end.
if varstay-history then do:
for each old-c-ex-mark  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-ex-mark.
   buffer-copy old-c-ex-mark to new-c-ex-mark.
end.
end.
for each old-egais-gds  , first new-goods where new-goods.gds-code = old-egais-gds.gds-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-egais-gds.
   buffer-copy old-egais-gds to new-egais-gds.
end.
if varstay-history then do:
for each old-c-egais-gds  , first new-goods where new-goods.gds-code = old-c-egais-gds.gds-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-egais-gds.
   buffer-copy old-c-egais-gds to new-c-egais-gds.
end.
end.
for each old-egais-clients  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-egais-clients.
   buffer-copy old-egais-clients to new-egais-clients.
end.
if varstay-history then do:
for each old-c-egais-clients  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-egais-clients.
   buffer-copy old-c-egais-clients to new-c-egais-clients.
end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: ~
alc-sale-lic ~
alc-sale-lic-attr ~
alc-sale-lic-type ~
alc-sale-lic-type-attr ~
alc-supp-lic ~
alc-supp-lic-attr ~
alc-supp-lic-type ~
alc-supp-lic-type-attr ~
alc-type ~
alc-type-attr ~
alc-type-gds ~
alc-type-gds-attr ~
c-alc-sale-lic ~
c-alc-sale-lic-attr ~
c-alc-sale-lic-type ~
c-alc-supp-lic ~
c-alc-supp-lic-attr ~
c-alc-supp-lic-type ~
c-alc-type ~
c-alc-type-attr ~
c-alc-type-gds ~
c-ex-mark ~
ex-mark ~
ex-mark-attr ~
egais-gds ~
c-egais-gds ~
egais-clients ~
c-egais-clients ~
.".
end.
