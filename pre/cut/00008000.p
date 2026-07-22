block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00008000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00008000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 8.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-season          for src.season.
define buffer new-season          for dst.season.
define buffer old-c-season        for src.c-season.
define buffer new-c-season        for dst.c-season.
define buffer old-gds-season      for src.gds-season.
define buffer new-gds-season      for dst.gds-season.
define buffer old-c-gds-season    for src.c-gds-season.
define buffer new-c-gds-season    for dst.c-gds-season.
define buffer old-season-attr     for src.season-attr.
define buffer new-season-attr     for dst.season-attr.
define buffer old-gds-season-attr for src.gds-season-attr.
define buffer new-gds-season-attr for dst.gds-season-attr.
define buffer new-goods           for dst.goods.
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
  on WRITE of dst.season        override do: end.
  on WRITE of dst.season-attr   override do: end.
  on WRITE of dst.c-season      override do: end.
  on WRITE of dst.gds-season    override do: end.
  on WRITE of dst.gds-season-attr override do: end.
  on WRITE of dst.c-gds-season  override do: end.
for each old-season  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-season.
   buffer-copy old-season to new-season.
end.
for each old-season-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-season-attr.
   buffer-copy old-season-attr to new-season-attr.
end.
  for each old-gds-season no-lock ,
      first new-goods no-lock where new-goods.gds-code = old-gds-season.gds-code
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
      create new-gds-season.
      BUFFER-COPY old-gds-season to new-gds-season.
  end.
  for each old-gds-season-attr no-lock ,
      first new-goods no-lock where new-goods.gds-code = old-gds-season-attr.gds-code
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
      create new-gds-season-attr.
      BUFFER-COPY old-gds-season-attr to new-gds-season-attr.
  end.
  if varstay-history = true then do:
for each old-c-season  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-season.
   buffer-copy old-c-season to new-c-season.
end.
      for each old-c-gds-season no-lock ,
          first new-goods no-lock where new-goods.gds-code = old-c-gds-season.gds-code
          on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
          :
          create new-c-gds-season.
          BUFFER-COPY old-c-gds-season to new-c-gds-season.
      end.
  end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: season gds-season c-season c-gds-season season-attr gds-season-attr . " .
end.
