block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00995000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00995000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 995.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-some-lk for src.some-lk.
define buffer new-some-lk for dst.some-lk.
define buffer old-some-lk-attr for src.some-lk-attr.
define buffer new-some-lk-attr for dst.some-lk-attr.
define buffer old-who-lk for src.who-lk.
define buffer new-who-lk for dst.who-lk.
define buffer old-who-lk-attr for src.who-lk-attr.
define buffer new-who-lk-attr for dst.who-lk-attr.
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
on WRITE of dst.some-lk override do: end.
on WRITE of dst.some-lk-attr override do: end.
on WRITE of dst.who-lk override do: end.
on WRITE of dst.who-lk-attr override do: end.
for each old-some-lk  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-some-lk.
   buffer-copy old-some-lk to new-some-lk.
end.
for each old-some-lk-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-some-lk-attr.
   buffer-copy old-some-lk-attr to new-some-lk-attr.
end.
for each old-who-lk  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-who-lk.
   buffer-copy old-who-lk to new-who-lk.
end.
for each old-who-lk-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-who-lk-attr.
   buffer-copy old-who-lk-attr to new-who-lk-attr.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: some-lk some-lk-attr who-lk who-lk-attr .".
end.
