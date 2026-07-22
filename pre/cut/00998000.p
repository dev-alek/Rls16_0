block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: 00998000.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: cut/00998000.p $":U .
define variable vss-description as character no-undo initial "Файл пирога обрезания. Относится к категории 98.":U .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-rep              for src.rep              .
define buffer new-rep              for dst.rep              .
define buffer old-rep-line         for src.rep-line         .
define buffer new-rep-line         for dst.rep-line         .
define buffer old-doc-fact-num        for src.doc-fact-num        .
define buffer new-doc-fact-num        for dst.doc-fact-num        .
define buffer old-doc-fact-num-attr        for src.doc-fact-num-attr        .
define buffer new-doc-fact-num-attr        for dst.doc-fact-num-attr        .
do
on error undo, return error SUBSTITUTE( "&1 &2 &3"
                                      , return-value
                                      , error-status :get-message( 1 )
                                      , error-status :get-message( 2 )
                                      )
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
  on CREATE of dst.rep              override do: end.
  on CREATE of dst.rep-line         override do: end.
  on CREATE of dst.doc-fact-num        override do: end.
  on CREATE of dst.doc-fact-num-attr        override do: end.
  on WRITE  of dst.rep              override do: end.
  on WRITE  of dst.rep-line         override do: end.
  on WRITE of dst.doc-fact-num        override do: end.
  on WRITE of dst.doc-fact-num-attr        override do: end.
for each old-rep  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rep.
   buffer-copy old-rep to new-rep.
end.
for each old-rep-line  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-rep-line.
   buffer-copy old-rep-line to new-rep-line.
end.
for each old-doc-fact-num  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-doc-fact-num.
   buffer-copy old-doc-fact-num to new-doc-fact-num.
end.
for each old-doc-fact-num-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-doc-fact-num-attr.
   buffer-copy old-doc-fact-num-attr to new-doc-fact-num-attr.
end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: rep-line " .
end.
