block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Feb 17 18:03:53 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00196000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00196000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 196.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-c-doc-attr          for src.c-doc-attr.
define buffer new-c-doc-attr          for dst.c-doc-attr.
define buffer new-c-trn-doc            for dst.c-trn-doc  .
define buffer new-c-rvs-doc            for dst.c-rvs-doc  .
define buffer new-c-price-doc          for dst.c-price-doc.
define buffer new-c-fbr-doc            for dst.c-fbr-doc  .
define buffer new-c-wth-doc            for dst.c-wth-doc  .
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
  if not varstay-history  then return .
  on WRITE of dst.c-doc-attr      override do: end.
  for each new-c-trn-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-c-trn-doc.doc-code, new-c-trn-doc.chip-num) .
  end.
  for each new-c-rvs-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-c-rvs-doc.rvs-code, new-c-rvs-doc.chip-num) .
  end.
  for each new-c-price-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-c-price-doc.doc-num, new-c-price-doc.chip-num) .
  end.
  for each new-c-fbr-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-c-fbr-doc.doc-code, new-c-fbr-doc.chip-num) .
  end.
  for each new-c-wth-doc no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      run proc-1(new-c-wth-doc.doc-code, new-c-wth-doc.chip-num) .
  end.
output stream str-gen close.
  return "Произведен экспорт таблиц: doc-attr.".
end.
procedure proc-1 :
  do
  on error undo, return error return-value
  :
  define input parameter p-doc as character no-undo .
  define input parameter p-chip-num as integer no-undo.
  for each old-c-doc-attr where old-c-doc-attr.doc-code = p-doc      and
                                old-c-doc-attr.chip-num = p-chip-num no-lock  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
      create new-c-doc-attr.
      BUFFER-COPY old-c-doc-attr to new-c-doc-attr.
  end.
  end.
end procedure.
