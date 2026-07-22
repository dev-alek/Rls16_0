block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Feb 17 18:03:53 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00045000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00045000.p $":U.
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 45.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-c-price-doc   for src.c-price-doc.
define buffer new-c-price-doc   for dst.c-price-doc.
define buffer old-c-price-list  for src.c-price-list.
define buffer new-c-price-list  for dst.c-price-list.
define buffer old-c-price-list-attr  for src.c-price-list-attr.
define buffer new-c-price-list-attr  for dst.c-price-list-attr.
define buffer new-shop        for dst.shop.
define buffer new-store       for dst.store.
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
define  shared temp-table tt-objs no-undo
  field obj-type as character
  field obj-code as integer
  index pi is unique primary obj-type obj-code
  .
if not varstay-history then return .
define buffer buf_clients for src.clients .
on WRITE of dst.c-price-doc  override do: end.
on WRITE of dst.c-price-list override do: end.
on WRITE of dst.c-price-list-attr override do: end.
if vardate-actual-docs <> ? then do:
    for each buf_clients no-lock  where
             buf_clients.db-num <> ?
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
      if vartype-cut = 1 then do:
          find first tt-objs where tt-objs.obj-type = buf_clients.obj-type and
                                   tt-objs.obj-code = buf_clients.obj-code no-error.
      end.
      if vartype-cut = 0      or
          (vartype-cut = 1 and available tt-objs) then do:
                     if buf_clients.obj-type  = 'маг':U OR buf_clients.obj-type  = 'скл':U then DO:
                            for each old-c-price-doc where
                                      old-c-price-doc.obj-type   = buf_clients.obj-TYPE  and
                                      old-c-price-doc.obj-code   = buf_clients.obj-code  and
                                      old-c-price-doc.status_    = 'акт':U      and
                                      old-c-price-doc.fact-date >= vardate-actual-docs no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                                RUN proc-copy no-error .
                                IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
                            end.
                     end.
      end.
      else do:
                    if buf_clients.obj-type  = 'маг':U OR buf_clients.obj-type  = 'скл':U then DO:
                            for each old-c-price-doc where
                                      old-c-price-doc.obj-type   = buf_clients.obj-TYPE  and
                                      old-c-price-doc.obj-code   = buf_clients.obj-code  and
                                      old-c-price-doc.status_    = 'акт':U
                                      no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                                RUN proc-copy no-error .
                                IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
                            end.
                     end.
      end.
  END.
output stream str-gen close.
END.
return "Произведен экспорт таблиц: c-price-doc c-price-list ( только переоценки )".
end.
procedure proc-copy :
  do
  on error undo, return error return-value
  :
  for each old-c-price-list where old-c-price-list.doc-num  = old-c-price-doc.doc-num  and
                                  old-c-price-list.chip-num = old-c-price-doc.chip-num no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      create new-c-price-list.
      buffer-copy old-c-price-list to new-c-price-list.
  end.
  for each old-c-price-list-attr where old-c-price-list-attr.doc-num  = old-c-price-doc.doc-num  and
                                        old-c-price-list-attr.chip-num = old-c-price-doc.chip-num no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      create new-c-price-list-attr.
      buffer-copy old-c-price-list-attr to new-c-price-list-attr.
  end.
  create new-c-price-doc.
  buffer-copy old-c-price-doc to new-c-price-doc.
  end.
end procedure.
