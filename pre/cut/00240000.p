block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00240000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00240000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 240.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-schet-fact-doc                for src.schet-fact-doc                  .
define buffer old-schet-fact-line               for src.schet-fact-line                 .
define buffer old-schet-fact-doc-attr           for src.schet-fact-doc-attr             .
define buffer old-schet-fact-line-attr          for src.schet-fact-line-attr            .
define buffer old-factur-connect                for src.factur-connect                  .
define buffer old-factur-connect-attr           for src.factur-connect-attr             .
define buffer old-factur-connect-line        for src.factur-connect-line          .
define buffer old-factur-connect-line-attr   for src.factur-connect-line-attr     .
define buffer old-c-schet-fact-doc             for src.c-schet-fact-doc              .
define buffer old-c-schet-fact-line            for src.c-schet-fact-line             .
define buffer new-schet-fact-doc               for dst.schet-fact-doc                .
define buffer new-schet-fact-line              for dst.schet-fact-line               .
define buffer new-schet-fact-doc-attr          for dst.schet-fact-doc-attr              .
define buffer new-schet-fact-line-attr         for dst.schet-fact-line-attr               .
define buffer new-factur-connect               for dst.factur-connect                .
define buffer new-factur-connect-attr          for dst.factur-connect-attr           .
define buffer new-factur-connect-line       for dst.factur-connect-line        .
define buffer new-factur-connect-line-attr  for dst.factur-connect-line-attr   .
define buffer new-c-schet-fact-doc             for dst.c-schet-fact-doc              .
define buffer new-c-schet-fact-line            for dst.c-schet-fact-line             .
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
  on WRITE of dst.schet-fact-doc               override do: end.
  on WRITE of dst.schet-fact-line              override do: end.
  on WRITE of dst.factur-connect               override do: end.
  on WRITE of dst.factur-connect-attr          override do: end.
  on WRITE of dst.factur-connect-line          override do: end.
  on WRITE of dst.factur-connect-line-attr     override do: end.
  on WRITE of dst.c-schet-fact-doc             override do: end.
  on WRITE of dst.c-schet-fact-line            override do: end.
for each old-factur-connect  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-factur-connect.
   buffer-copy old-factur-connect to new-factur-connect.
end.
for each old-factur-connect-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-factur-connect-attr.
   buffer-copy old-factur-connect-attr to new-factur-connect-attr.
end.
for each old-factur-connect-line  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-factur-connect-line.
   buffer-copy old-factur-connect-line to new-factur-connect-line.
end.
for each old-factur-connect-line-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-factur-connect-line-attr.
   buffer-copy old-factur-connect-line-attr to new-factur-connect-line-attr.
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
          for each old-schet-fact-doc where old-schet-fact-doc.obj-type   = buf_clients.obj-type             and
                    old-schet-fact-doc.obj-code   = buf_clients.obj-CODE and
                    old-schet-fact-doc.fact-date >= vardate-actual-docs no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
             RUN proc-copy ( old-schet-fact-doc.doc-code , old-schet-fact-doc.db-num ) no-error .
             IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
          END.
        end.
      end.
      else do:
        if buf_clients.obj-type  = 'маг':U OR buf_clients.obj-type  = 'скл':U then DO:
            for each old-schet-fact-doc where
                     old-schet-fact-doc.obj-type   = buf_clients.obj-type             and
                     old-schet-fact-doc.obj-code   = buf_clients.obj-CODE
                   no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                     RUN proc-copy ( old-schet-fact-doc.doc-code , old-schet-fact-doc.db-num) no-error .
                     IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
            end.
        END.
      END.
   end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: ~
        schet-fact-doc schet-fact-line factur-connect factur-connect-attr factur-connect-line factur-connect-line-attr c-schet-fact-doc c-schet-fact-line ".
end.
procedure proc-copy :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-db-num  as integer   no-undo .
  do
  on error undo, return error return-value
  :
for each old-schet-fact-doc  where old-schet-fact-doc.doc-code       = p-doc-code and old-schet-fact-doc.db-num       = p-db-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-schet-fact-doc.
   buffer-copy old-schet-fact-doc to new-schet-fact-doc.
end.
for each old-schet-fact-doc-attr  where old-schet-fact-doc-attr.doc-code  = p-doc-code and old-schet-fact-doc-attr.db-num  = p-db-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-schet-fact-doc-attr.
   buffer-copy old-schet-fact-doc-attr to new-schet-fact-doc-attr.
end.
for each old-schet-fact-line  where old-schet-fact-line.doc-code      = p-doc-code and old-schet-fact-line.db-num      = p-db-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-schet-fact-line.
   buffer-copy old-schet-fact-line to new-schet-fact-line.
end.
for each old-schet-fact-line-attr  where old-schet-fact-line-attr.doc-code = p-doc-code and old-schet-fact-line-attr.db-num = p-db-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-schet-fact-line-attr.
   buffer-copy old-schet-fact-line-attr to new-schet-fact-line-attr.
end.
for each old-factur-connect  where
         old-factur-connect.factur-doc-code = p-doc-code and
         old-factur-connect.db-num      = p-db-num  no-lock on error undo,
         return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-factur-connect.
   buffer-copy old-factur-connect to new-factur-connect.
      for each old-factur-connect-attr  where
               old-factur-connect-attr.connect-code = old-factur-connect.connect-code and
               old-factur-connect-attr.db-num      =  old-factur-connect.db-num  no-lock on error undo,
              return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-factur-connect-attr.
        buffer-copy old-factur-connect-attr to new-factur-connect-attr.
      end.
      for each old-factur-connect-line  where
               old-factur-connect-line.connect-code = old-factur-connect.connect-code and
               old-factur-connect-line.db-num      =  old-factur-connect.db-num  no-lock on error undo,
              return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-factur-connect-line.
        buffer-copy old-factur-connect-line to new-factur-connect-line.
      end.
      for each old-factur-connect-line-attr  where
               old-factur-connect-line-attr.connect-code = old-factur-connect.connect-code and
               old-factur-connect-line-attr.db-num      =  old-factur-connect.db-num  no-lock on error undo,
              return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-factur-connect-line-attr.
        buffer-copy old-factur-connect-line-attr to new-factur-connect-line-attr.
      end.
end.
  if varstay-history = yes then do:
for each old-c-schet-fact-doc  where old-c-schet-fact-doc.doc-code = p-doc-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-schet-fact-doc.
   buffer-copy old-c-schet-fact-doc to new-c-schet-fact-doc.
end.
for each old-c-schet-fact-line  where old-c-schet-fact-line.doc-code = p-doc-code  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-schet-fact-line.
   buffer-copy old-c-schet-fact-line to new-c-schet-fact-line.
end.
  end.
end.
end procedure.
