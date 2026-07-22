block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00230000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00230000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 230.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-add-doc                for src.add-doc                  .
define buffer old-add-line               for src.add-line                 .
define buffer old-add-trn                for src.add-trn                  .
define buffer old-add-trn-attr           for src.add-trn-attr             .
define buffer old-gds-add-charges        for src.gds-add-charges          .
define buffer old-gds-add-charges-attr   for src.gds-add-charges-attr     .
define buffer old-parts-add-attr         for src.parts-add-attr           .
define buffer old-parts-add              for src.parts-add                .
define buffer old-c-parts-add            for src.c-parts-add              .
define buffer old-c-add-doc              for src.c-add-doc                .
define buffer old-c-add-line             for src.c-add-line               .
define buffer new-add-doc               for dst.add-doc                .
define buffer new-add-line              for dst.add-line               .
define buffer new-add-trn               for dst.add-trn                .
define buffer new-add-trn-attr          for dst.add-trn-attr           .
define buffer new-gds-add-charges       for dst.gds-add-charges        .
define buffer new-gds-add-charges-attr  for dst.gds-add-charges-attr   .
define buffer new-parts-add-attr        for dst.parts-add-attr         .
define buffer new-parts-add             for dst.parts-add              .
define buffer new-c-parts-add           for dst.c-parts-add            .
define buffer new-c-add-doc             for dst.c-add-doc              .
define buffer new-c-add-line            for dst.c-add-line             .
define buffer new-goods for dst.goods  .
define buffer buf_clients     for dst.clients.
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
define  shared temp-table tt-objs no-undo
  field obj-type as character
  field obj-code as integer
  index pi is unique primary obj-type obj-code
  .
  on WRITE of dst.add-doc               override do: end.
  on WRITE of dst.add-line              override do: end.
  on WRITE of dst.add-trn               override do: end.
  on WRITE of dst.add-trn-attr          override do: end.
  on WRITE of dst.gds-add-charges       override do: end.
  on WRITE of dst.gds-add-charges-attr  override do: end.
  on WRITE of dst.parts-add-attr        override do: end.
  on WRITE of dst.parts-add             override do: end.
  on WRITE of dst.c-parts-add           override do: end.
  on WRITE of dst.c-add-doc             override do: end.
  on WRITE of dst.c-add-line            override do: end.
for each old-gds-add-charges  no-lock , first new-goods where new-goods.gds-code = old-gds-add-charges.gds-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-gds-add-charges.
   buffer-copy old-gds-add-charges to new-gds-add-charges.
end.
for each old-gds-add-charges-attr  no-lock , first new-goods where new-goods.gds-code = old-gds-add-charges-attr.gds-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-gds-add-charges-attr.
   buffer-copy old-gds-add-charges-attr to new-gds-add-charges-attr.
end.
for each old-parts-add  no-lock , first new-goods where new-goods.gds-code = old-parts-add.gds-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-parts-add.
   buffer-copy old-parts-add to new-parts-add.
end.
for each old-parts-add-attr  no-lock , first new-goods where new-goods.gds-code = old-parts-add-attr.gds-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-parts-add-attr.
   buffer-copy old-parts-add-attr to new-parts-add-attr.
end.
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
          for each old-add-doc where old-add-doc.obj-type   = buf_clients.obj-type             and
                    old-add-doc.obj-code   = buf_clients.obj-CODE and
                    old-add-doc.status_    = 'акт':U         and
                    old-add-doc.fact-date >= vardate-actual-docs no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
             RUN proc-copy ( old-add-doc.doc-code ) no-error .
             IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
          END.
        end.
      end.
      else do:
        if buf_clients.obj-type  = 'маг':U OR buf_clients.obj-type  = 'скл':U then DO:
            for each old-add-doc where
                     old-add-doc.obj-type   = buf_clients.obj-type             and
                     old-add-doc.obj-code   = buf_clients.obj-CODE  and
                     old-add-doc.status_    = 'акт':U
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                     RUN proc-copy ( old-add-doc.doc-code ) no-error .
                     IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
            end.
        END.
      END.
   end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: ~
        add-doc add-line add-trn add-trn-attr gds-add-charges gds-add-charges-attr parts-add-attr parts-add c-parts-add c-add-doc c-add-line ".
end.
procedure proc-copy :
define input  parameter p-doc-code as character no-undo .
  do
  on error undo, return error return-value
  :
for each old-add-doc  where old-add-doc.doc-code = p-doc-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-add-doc.
   buffer-copy old-add-doc to new-add-doc.
end.
for each old-add-line  where old-add-line.doc-code = p-doc-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-add-line.
   buffer-copy old-add-line to new-add-line.
end.
for each old-add-trn  where old-add-trn.doc-code = p-doc-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-add-trn.
   buffer-copy old-add-trn to new-add-trn.
end.
for each old-add-trn-attr  where old-add-trn-attr.doc-code = p-doc-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-add-trn-attr.
   buffer-copy old-add-trn-attr to new-add-trn-attr.
end.
  if varstay-history = yes then do:
for each old-c-add-doc  where old-c-add-doc.doc-code = p-doc-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-add-doc.
   buffer-copy old-c-add-doc to new-c-add-doc.
end.
for each old-c-add-line  where old-c-add-line.doc-code = p-doc-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-add-line.
   buffer-copy old-c-add-line to new-c-add-line.
end.
  end.
end.
end procedure.
