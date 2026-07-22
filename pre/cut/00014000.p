block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00014000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00014000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 14.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-c-ext-artic         for src.c-ext-artic        .
define buffer old-c-ext-artic-attr    for src.c-ext-artic-attr   .
define buffer old-ext-artic           for src.ext-artic          .
define buffer old-ext-artic-attr      for src.ext-artic-attr     .
define buffer old-ext-artic-db        for src.ext-artic-db       .
define buffer old-ext-artic-db-attr   for src.ext-artic-db-attr  .
define buffer old-ext-artic-host      for src.ext-artic-host     .
define buffer old-ext-artic-host-attr for src.ext-artic-host-attr.
define buffer old-ext-artic-obj       for src.ext-artic-obj      .
define buffer old-ext-artic-obj-attr  for src.ext-artic-obj-attr .
define buffer new-c-ext-artic         for dst.c-ext-artic        .
define buffer new-c-ext-artic-attr    for dst.c-ext-artic-attr   .
define buffer new-ext-artic           for dst.ext-artic          .
define buffer new-ext-artic-attr      for dst.ext-artic-attr     .
define buffer new-ext-artic-db        for dst.ext-artic-db       .
define buffer new-ext-artic-db-attr   for dst.ext-artic-db-attr  .
define buffer new-ext-artic-host      for dst.ext-artic-host     .
define buffer new-ext-artic-host-attr for dst.ext-artic-host-attr.
define buffer new-ext-artic-obj       for dst.ext-artic-obj      .
define buffer new-ext-artic-obj-attr  for dst.ext-artic-obj-attr .
define buffer new-goods               for dst.goods .
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
  on WRITE of dst.c-ext-artic                         override do: end.
  on WRITE of dst.c-ext-artic-attr                    override do: end.
  on WRITE of dst.ext-artic                           override do: end.
  on WRITE of dst.ext-artic-attr                      override do: end.
  on WRITE of dst.ext-artic-db                        override do: end.
  on WRITE of dst.ext-artic-db-attr                   override do: end.
  on WRITE of dst.ext-artic-host                      override do: end.
  on WRITE of dst.ext-artic-host-attr                 override do: end.
  on WRITE of dst.ext-artic-obj                       override do: end.
  on WRITE of dst.ext-artic-obj-attr                  override do: end.
  for each old-ext-artic no-lock
  :
    find first new-goods no-lock
      where new-goods.gds-code = old-ext-artic.gds-code
    no-error .
    if available new-goods
    then do:
      create new-ext-artic.
      buffer-copy old-ext-artic to new-ext-artic.
    end.
  end.
  for each old-ext-artic-attr no-lock
  :
    find first new-goods no-lock
      where new-goods.gds-code = old-ext-artic-attr.gds-code
    no-error .
    if available new-goods
    then do:
      create new-ext-artic-attr.
      buffer-copy old-ext-artic-attr to new-ext-artic-attr.
    end.
  end.
  for each old-ext-artic-db no-lock
  :
    find first new-goods no-lock
      where new-goods.gds-code = old-ext-artic-db.gds-code
    no-error .
    if available new-goods
    then do:
      create new-ext-artic-db.
      buffer-copy old-ext-artic-db to new-ext-artic-db.
    end.
  end.
  for each old-ext-artic-db-attr no-lock
  :
    find first new-goods no-lock
      where new-goods.gds-code = old-ext-artic-db-attr.gds-code
    no-error .
    if available new-goods
    then do:
      create new-ext-artic-db-attr.
      buffer-copy old-ext-artic-db-attr to new-ext-artic-db-attr .
    end.
  end.
  for each old-ext-artic-host no-lock
  :
    find first new-goods no-lock
      where new-goods.gds-code = old-ext-artic-host.gds-code
    no-error .
    if available new-goods
    then do:
      create new-ext-artic-host .
      buffer-copy old-ext-artic-host to new-ext-artic-host .
    end.
  end.
  for each old-ext-artic-host-attr no-lock
  :
    find first new-goods no-lock
      where new-goods.gds-code = old-ext-artic-host-attr.gds-code
    no-error .
    if available new-goods
    then do:
      create new-ext-artic-host-attr .
      buffer-copy old-ext-artic-host-attr to new-ext-artic-host-attr .
    end.
  end.
  for each old-ext-artic-obj no-lock
  :
    find first new-goods no-lock
      where new-goods.gds-code = old-ext-artic-obj.gds-code
    no-error .
    if available new-goods
    then do:
      create new-ext-artic-obj .
      buffer-copy old-ext-artic-obj to new-ext-artic-obj .
    end.
  end.
  for each old-ext-artic-obj-attr no-lock
  :
    find first new-goods no-lock
      where new-goods.gds-code = old-ext-artic-obj-attr.gds-code
    no-error .
    if available new-goods
    then do:
      create new-ext-artic-obj-attr.
      buffer-copy old-ext-artic-obj-attr to new-ext-artic-obj-attr .
    end.
  end.
  if varstay-history
  then do:
    for each old-c-ext-artic no-lock
    :
      find first new-goods no-lock
        where new-goods.gds-code = old-c-ext-artic.gds-code
      no-error .
      if available new-goods
      then do:
        create new-c-ext-artic.
        buffer-copy old-c-ext-artic to new-c-ext-artic.
      end.
    end.
    for each old-c-ext-artic-attr no-lock
    :
      find first new-goods no-lock
        where new-goods.gds-code = old-c-ext-artic-attr.gds-code
      no-error .
      if available new-goods
      then do:
        create new-c-ext-artic-attr.
        buffer-copy old-c-ext-artic-attr to new-c-ext-artic-attr .
      end.
    end.
  end.
output stream str-gen close.
return "Произведен экспорт таблиц: " +
"~
c-ext-artic ~
c-ext-artic-attr ~
ext-artic ~
ext-artic-attr ~
ext-artic-db ~
ext-artic-db-attr ~
ext-artic-host ~
ext-artic-host-attr ~
ext-artic-obj ~
ext-artic-obj-attr ~
.".
end.
