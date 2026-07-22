block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00044000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00044000.p $":U.
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 31.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-price-doc   for src.price-doc.
define buffer new-price-doc   for dst.price-doc.
define buffer old-price-list  for src.price-list.
define buffer new-price-list  for dst.price-list.
define buffer old-parts       for src.parts.
define buffer buf_clients     for dst.clients.
define buffer new-parts       for dst.parts.
define buffer new-goods       for dst.goods .
define buffer new-bar-code    for dst.bar-code .
define buffer new-gds-prt     for dst.gds-prt  .
define buffer new-shop        for dst.shop.
define buffer new-store       for dst.store.
define variable p-bar-code     as integer   no-undo .
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
on WRITE of dst.price-doc  override do: end.
on WRITE of dst.price-list override do: end.
on WRITE of dst.parts      override do: end.
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
          for each old-price-doc where old-price-doc.obj-type   = buf_clients.obj-type             and
                    old-price-doc.obj-code   = buf_clients.obj-CODE and
                    old-price-doc.status_    = 'акт':U         and
                    old-price-doc.fact-date >= vardate-actual-docs no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
             RUN proc-copy no-error .
             IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
          END.
        end.
      end.
      else do:
        if buf_clients.obj-type  = 'маг':U OR buf_clients.obj-type  = 'скл':U then DO:
            for each old-price-doc where old-price-doc.obj-type   = buf_clients.obj-type             and
                   old-price-doc.obj-code   = buf_clients.obj-CODE  and
                   old-price-doc.status_    = 'акт':U
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                     RUN proc-copy no-error .
                     IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
            end.
        END.
      END.
   end.
   output stream str-gen close.
end.
return "Произведен экспорт таблиц: price-doc price-list parts ( только переоценки )".
end.
procedure proc-copy :
  do
  on error undo, return error return-value
  :
  for each old-price-list where old-price-list.doc-num = old-price-doc.doc-num no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    create new-price-list.
    buffer-copy old-price-list to new-price-list.
    if old-price-list.main-price = yes then do:
      for each old-parts where  old-parts.out-code  = old-price-doc.doc-num      and
                                old-parts.obj-code  = old-price-doc.obj-code    and
                                old-parts.obj-type  = old-price-doc.obj-type    and
                                old-parts.artic     = old-price-list.artic      and
                                old-parts.prod-code = old-price-list.prod-code  and
                                old-parts.prod-type = old-price-list.prod-type
                                no-lock on error undo,
                                return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
                                :
          create new-parts.
          buffer-copy old-parts to new-parts.
      end.
    end.
  end.
  create new-price-doc.
  buffer-copy old-price-doc to new-price-doc.
  end.
end procedure.
