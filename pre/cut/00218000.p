block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00218000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00218000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 999.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
output stream str-gen close.
return "Игнорированы таблицы: abc-analysis abc-analysis-attr abc-analysi-cli abc-analysis-cli-attr abc-analysis-doc abc-analysis-doc-attr abc-analysis-gds-obj abc-analysis-gds-obj-attr " +
" abc-analysis-goods abc-analysis-goods-attr abc-analysis-grp abc-analysis-grp-attr abc-analysis-obj abc-analysis-obj-attr abc-analysis-period abc-analysis-period-attr " +
" abc-analysis-prod abc-analysis-prod-attr abcxyz-analysis abcxyz-analysis-attr abcxyz-analysis-goods abcxyz-analysis-goods-attr " +
" doc-abc-def doc-abc-def-attr doc-abc-def-doc doc-abc-def-doc-attr doc-abc-def-obj doc-abc-def-obj-attr " +
" doc-xyz-def doc-xyz-def-attr doc-xyz-def-doc doc-xyz-def-doc-attr doc-xyz-def-obj doc-xyz-def-obj-attr " +
" xyz-analysis xyz-analysis-attr xyz-analysis-doc xyz-analysis-doc-attr xyz-analysis-gds-obj xyz-analysis-gds-obj-attr xyz-analysis-goods xyz-analysis-goods-attr " +
" xyz-analysis-obj xyz-analysis-obj-attr xyz-analysis-period xyz-analysis-period-attr " +
" xyz-analysis-cli xyz-analysis-cli-attr xyz-analysis-grp xyz-analysis-grp-attr xyz-analysis-prod xyz-analysis-prod-attr "
.
end.
