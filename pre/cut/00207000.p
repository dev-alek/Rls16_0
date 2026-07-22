block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00207000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00207000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 104.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-menu-group           for src.menu-group          .
define buffer old-menu-group-attr      for src.menu-group-attr     .
define buffer old-menu-head            for src.menu-head           .
define buffer old-menu-head-attr       for src.menu-head-attr      .
define buffer old-menu-item            for src.menu-item           .
define buffer old-menu-item-attr       for src.menu-item-attr      .
define buffer old-menu-item-group      for src.menu-item-group     .
define buffer old-menu-item-group-attr for src.menu-item-group-attr.
define buffer new-menu-group           for dst.menu-group          .
define buffer new-menu-group-attr      for dst.menu-group-attr     .
define buffer new-menu-head            for dst.menu-head           .
define buffer new-menu-head-attr       for dst.menu-head-attr      .
define buffer new-menu-item            for dst.menu-item           .
define buffer new-menu-item-attr       for dst.menu-item-attr      .
define buffer new-menu-item-group      for dst.menu-item-group     .
define buffer new-menu-item-group-attr for dst.menu-item-group-attr.
do
on error undo, return error SUBSTITUTE ( "&1 &2 &3"
                                       , return-value
                                       , error-status:get-message(1)
                                       , error-status:get-message(2)
                                       ) :
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
on WRITE of dst.menu-group                           override do: end.
on WRITE of dst.menu-group-attr                      override do: end.
on WRITE of dst.menu-head                            override do: end.
on WRITE of dst.menu-head-attr                       override do: end.
on WRITE of dst.menu-item                            override do: end.
on WRITE of dst.menu-item-attr                       override do: end.
on WRITE of dst.menu-item-group                      override do: end.
on WRITE of dst.menu-item-group-attr                 override do: end.
for each old-menu-group  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-menu-group.
   buffer-copy old-menu-group to new-menu-group.
end.
for each old-menu-group-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-menu-group-attr.
   buffer-copy old-menu-group-attr to new-menu-group-attr.
end.
for each old-menu-head  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-menu-head.
   buffer-copy old-menu-head to new-menu-head.
end.
for each old-menu-head-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-menu-head-attr.
   buffer-copy old-menu-head-attr to new-menu-head-attr.
end.
for each old-menu-item  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-menu-item.
   buffer-copy old-menu-item to new-menu-item.
end.
for each old-menu-item-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-menu-item-attr.
   buffer-copy old-menu-item-attr to new-menu-item-attr.
end.
for each old-menu-item-group  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-menu-item-group.
   buffer-copy old-menu-item-group to new-menu-item-group.
end.
for each old-menu-item-group-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-menu-item-group-attr.
   buffer-copy old-menu-item-group-attr to new-menu-item-group-attr.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: ~
menu-group ~
menu-group-attr ~
menu-head ~
menu-head-attr ~
menu-item ~
menu-item-attr ~
menu-item-group ~
menu-item-group-attr ~
".
end.
