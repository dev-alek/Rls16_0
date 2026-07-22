block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00221000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00221000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 8.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-price-all                  for src.price-all                  .
define buffer new-price-all                  for dst.price-all                  .
define buffer old-price-all-attr             for src.price-all-attr             .
define buffer new-price-all-attr             for dst.price-all-attr             .
define buffer old-price-doc-forming          for src.price-doc-forming          .
define buffer old-price-doc-forming-attr     for src.price-doc-forming-attr     .
define buffer old-price-doc-forming-gds      for src.price-doc-forming-gds      .
define buffer old-price-doc-forming-gdsattr  for src.price-doc-forming-gdsattr  .
define buffer old-price-doc-forming-gds-qnty for src.price-doc-forming-gds-qnty .
define buffer old-price-doc-forming-gds-sum  for src.price-doc-forming-gds-sum  .
define buffer old-price-doc-forming-gds-tnv  for src.price-doc-forming-gds-tnv  .
define buffer new-price-doc-forming          for dst.price-doc-forming          .
define buffer new-price-doc-forming-attr     for dst.price-doc-forming-attr     .
define buffer new-price-doc-forming-gds      for dst.price-doc-forming-gds      .
define buffer new-price-doc-forming-gdsattr  for dst.price-doc-forming-gdsattr  .
define buffer new-price-doc-forming-gds-qnty for dst.price-doc-forming-gds-qnty .
define buffer new-price-doc-forming-gds-sum  for dst.price-doc-forming-gds-sum  .
define buffer new-price-doc-forming-gds-tnv  for dst.price-doc-forming-gds-tnv  .
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
  on WRITE of dst.price-all                   override do: end.
  on WRITE of dst.price-all-attr              override do: end.
  on WRITE of dst.price-doc-forming           override do: end.
  on WRITE of dst.price-doc-forming-attr      override do: end.
  on WRITE of dst.price-doc-forming-gds       override do: end.
  on WRITE of dst.price-doc-forming-gdsattr   override do: end.
  on WRITE of dst.price-doc-forming-gds-qnty  override do: end.
  on WRITE of dst.price-doc-forming-gds-sum   override do: end.
  on WRITE of dst.price-doc-forming-gds-tnv   override do: end.
define buffer new-price-doc for dst.price-doc  .
define buffer bufold_price-doc-forming for src.price-doc-forming  .
    if vardate-actual-docs <> ? then do:
        for each bufold_price-doc-forming  no-lock where
                bufold_price-doc-forming.sys-date >= vardate-actual-docs
                on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          run move-doc (
              bufold_price-doc-forming.plt-id  ,
              bufold_price-doc-forming.plt-db-num ,
              bufold_price-doc-forming.pdf-id  ,
              bufold_price-doc-forming.pdf-db
              ) no-error .
              IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
        end.
        for each new-price-doc no-lock
              on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
          run move-doc (
              new-price-doc.plt-id  ,
              new-price-doc.plt-db-num ,
              new-price-doc.pdf-id  ,
              new-price-doc.pdf-db
              ) no-error .
              IF error-status :error THEN return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)).
        end.
    end.
output stream str-gen close.
  return "Произведен экспорт таблиц: ~
  price-all ~
  price-all-attr ~
  price-doc-forming ~
  price-doc-forming-attr~
  price-doc-forming-gds ~
  price-doc-forming-gdsattr~
  price-doc-forming-gds-qnty ~
  price-doc-forming-gds-sum ~
  price-doc-forming-gds-tnv "  + chr(10) +
  "Игнорированы таблицы ~
c-price-doc-forming ~
c-price-doc-forming-attr ~
c-price-doc-forming-gds ~
c-price-doc-forming-gdsattr ~
c-price-doc-forming-gds-qnty ~
c-price-doc-forming-gds-sum  ~
c-price-doc-forming-gds-tnv  "
  .
end.
procedure move-doc :
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
  do
  on error undo, return error return-value
:
  find first  new-price-doc-forming no-lock where
              new-price-doc-forming.plt-id     = p-plt-id and
              new-price-doc-forming.plt-db-num = p-plt-db-num and
              new-price-doc-forming.pdf-id     = p-pdf-id and
              new-price-doc-forming.pdf-db     = p-pdf-db-num      no-error .
  if available new-price-doc-forming then return .
for each old-price-doc-forming   where    old-price-doc-forming.plt-id     = p-plt-id and   old-price-doc-forming.plt-db-num = p-plt-db-num and   old-price-doc-forming.pdf-id     = p-pdf-id and   old-price-doc-forming.pdf-db = p-pdf-db-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-price-doc-forming.
   buffer-copy old-price-doc-forming to new-price-doc-forming.
end.
for each old-price-doc-forming-attr  where    old-price-doc-forming-attr.plt-id     = p-plt-id and   old-price-doc-forming-attr.plt-db-num = p-plt-db-num and   old-price-doc-forming-attr.pdf-id     = p-pdf-id and   old-price-doc-forming-attr.pdf-db = p-pdf-db-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-price-doc-forming-attr.
   buffer-copy old-price-doc-forming-attr to new-price-doc-forming-attr.
end.
for each old-price-doc-forming-gds  where    old-price-doc-forming-gds.plt-id     = p-plt-id and   old-price-doc-forming-gds.plt-db-num = p-plt-db-num and   old-price-doc-forming-gds.pdf-id     = p-pdf-id and   old-price-doc-forming-gds.pdf-db = p-pdf-db-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-price-doc-forming-gds.
   buffer-copy old-price-doc-forming-gds to new-price-doc-forming-gds.
end.
for each old-price-doc-forming-gdsattr  where    old-price-doc-forming-gdsattr.plt-id     = p-plt-id and   old-price-doc-forming-gdsattr.plt-db-num = p-plt-db-num and   old-price-doc-forming-gdsattr.pdf-id     = p-pdf-id and   old-price-doc-forming-gdsattr.pdf-db = p-pdf-db-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-price-doc-forming-gdsattr.
   buffer-copy old-price-doc-forming-gdsattr to new-price-doc-forming-gdsattr.
end.
for each old-price-doc-forming-gds-qnty  where    old-price-doc-forming-gds-qnty.plt-id     = p-plt-id and   old-price-doc-forming-gds-qnty.plt-db-num = p-plt-db-num and   old-price-doc-forming-gds-qnty.pdf-id     = p-pdf-id and   old-price-doc-forming-gds-qnty.pdf-db = p-pdf-db-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-price-doc-forming-gds-qnty.
   buffer-copy old-price-doc-forming-gds-qnty to new-price-doc-forming-gds-qnty.
end.
for each old-price-doc-forming-gds-sum  where    old-price-doc-forming-gds-sum.plt-id     = p-plt-id and   old-price-doc-forming-gds-sum.plt-db-num = p-plt-db-num and   old-price-doc-forming-gds-sum.pdf-id     = p-pdf-id and   old-price-doc-forming-gds-sum.pdf-db = p-pdf-db-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-price-doc-forming-gds-sum.
   buffer-copy old-price-doc-forming-gds-sum to new-price-doc-forming-gds-sum.
end.
for each old-price-doc-forming-gds-tnv  where    old-price-doc-forming-gds-tnv.plt-id     = p-plt-id and   old-price-doc-forming-gds-tnv.plt-db-num = p-plt-db-num and   old-price-doc-forming-gds-tnv.pdf-id     = p-pdf-id and   old-price-doc-forming-gds-tnv.pdf-db = p-pdf-db-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-price-doc-forming-gds-tnv.
   buffer-copy old-price-doc-forming-gds-tnv to new-price-doc-forming-gds-tnv.
end.
for each old-price-all  where    old-price-all.plt-id     = p-plt-id and   old-price-all.plt-db-num = p-plt-db-num and   old-price-all.pdf-id     = p-pdf-id and   old-price-all.pdf-db = p-pdf-db-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-price-all.
   buffer-copy old-price-all to new-price-all.
end.
  end.
end procedure.
