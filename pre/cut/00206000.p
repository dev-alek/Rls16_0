block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00206000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00206000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 104.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-action-group                for src.action-group               .
define buffer old-action-group-attr           for src.action-group-attr          .
define buffer old-action-head                 for src.action-head                .
define buffer old-action-head-attr            for src.action-head-attr           .
define buffer old-action-item                 for src.action-item                .
define buffer old-action-item-attr            for src.action-item-attr           .
define buffer old-action-post                 for src.action-post                .
define buffer old-action-post-attr            for src.action-post-attr           .
define buffer old-action-post-host            for src.action-post-host           .
define buffer old-action-post-host-attr       for src.action-post-host-attr      .
define buffer old-action-post-menu-group      for src.action-post-menu-group     .
define buffer old-action-post-menu-group-attr for src.action-post-menu-group-attr.
define buffer old-action-post-obj             for src.action-post-obj            .
define buffer old-action-post-obj-attr        for src.action-post-obj-attr       .
define buffer old-action-post-role            for src.action-post-role           .
define buffer old-action-post-role-attr       for src.action-post-role-attr      .
define buffer old-action-post-user-login      for src.action-post-user-login     .
define buffer old-action-post-user-login-attr for src.action-post-user-login-attr.
define buffer old-action-role                 for src.action-role                .
define buffer old-action-role-attr            for src.action-role-attr           .
define buffer old-action-role-item            for src.action-role-item           .
define buffer old-action-role-item-attr       for src.action-role-item-attr      .
define buffer old-action-role-item-gds        for src.action-role-item-gds       .
define buffer old-action-role-item-gds-grp    for src.action-role-item-gds-grp   .
define buffer new-action-group                for dst.action-group               .
define buffer new-action-group-attr           for dst.action-group-attr          .
define buffer new-action-head                 for dst.action-head                .
define buffer new-action-head-attr            for dst.action-head-attr           .
define buffer new-action-item                 for dst.action-item                .
define buffer new-action-item-attr            for dst.action-item-attr           .
define buffer new-action-post                 for dst.action-post                .
define buffer new-action-post-attr            for dst.action-post-attr           .
define buffer new-action-post-host            for dst.action-post-host           .
define buffer new-action-post-host-attr       for dst.action-post-host-attr      .
define buffer new-action-post-menu-group      for dst.action-post-menu-group     .
define buffer new-action-post-menu-group-attr for dst.action-post-menu-group-attr.
define buffer new-action-post-obj             for dst.action-post-obj            .
define buffer new-action-post-obj-attr        for dst.action-post-obj-attr       .
define buffer new-action-post-role            for dst.action-post-role           .
define buffer new-action-post-role-attr       for dst.action-post-role-attr      .
define buffer new-action-post-user-login      for dst.action-post-user-login     .
define buffer new-action-post-user-login-attr for dst.action-post-user-login-attr.
define buffer new-action-role                 for dst.action-role                .
define buffer new-action-role-attr            for dst.action-role-attr           .
define buffer new-action-role-item            for dst.action-role-item           .
define buffer new-action-role-item-attr       for dst.action-role-item-attr      .
define buffer new-action-role-item-gds        for dst.action-role-item-gds       .
define buffer new-action-role-item-gds-grp    for dst.action-role-item-gds-grp   .
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
on WRITE of dst.action-group                 override do: end.
on WRITE of dst.action-group-attr            override do: end.
on WRITE of dst.action-head                  override do: end.
on WRITE of dst.action-head-attr             override do: end.
on WRITE of dst.action-item                  override do: end.
on WRITE of dst.action-item-attr             override do: end.
on WRITE of dst.action-post                  override do: end.
on WRITE of dst.action-post-attr             override do: end.
on WRITE of dst.action-post-host             override do: end.
on WRITE of dst.action-post-host-attr        override do: end.
on WRITE of dst.action-post-menu-group       override do: end.
on WRITE of dst.action-post-menu-group-attr  override do: end.
on WRITE of dst.action-post-obj              override do: end.
on WRITE of dst.action-post-obj-attr         override do: end.
on WRITE of dst.action-post-role             override do: end.
on WRITE of dst.action-post-role-attr        override do: end.
on WRITE of dst.action-post-user-login       override do: end.
on WRITE of dst.action-post-user-login-attr  override do: end.
on WRITE of dst.action-role                  override do: end.
on WRITE of dst.action-role-attr             override do: end.
on WRITE of dst.action-role-item             override do: end.
on WRITE of dst.action-role-item-attr        override do: end.
on WRITE of dst.action-role-item-gds         override do: end.
on WRITE of dst.action-role-item-gds-grp     override do: end.
for each old-action-group  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-group.
   buffer-copy old-action-group to new-action-group.
end.
for each old-action-group-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-group-attr.
   buffer-copy old-action-group-attr to new-action-group-attr.
end.
for each old-action-head  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-head.
   buffer-copy old-action-head to new-action-head.
end.
for each old-action-head-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-head-attr.
   buffer-copy old-action-head-attr to new-action-head-attr.
end.
for each old-action-item  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-item.
   buffer-copy old-action-item to new-action-item.
end.
for each old-action-item-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-item-attr.
   buffer-copy old-action-item-attr to new-action-item-attr.
end.
for each old-action-post  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-post.
   buffer-copy old-action-post to new-action-post.
end.
for each old-action-post-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-post-attr.
   buffer-copy old-action-post-attr to new-action-post-attr.
end.
for each old-action-post-host  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-post-host.
   buffer-copy old-action-post-host to new-action-post-host.
end.
for each old-action-post-host-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-post-host-attr.
   buffer-copy old-action-post-host-attr to new-action-post-host-attr.
end.
for each old-action-post-menu-group  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-post-menu-group.
   buffer-copy old-action-post-menu-group to new-action-post-menu-group.
end.
for each old-action-post-menu-group-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-post-menu-group-attr.
   buffer-copy old-action-post-menu-group-attr to new-action-post-menu-group-attr.
end.
for each old-action-post-obj  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-post-obj.
   buffer-copy old-action-post-obj to new-action-post-obj.
end.
for each old-action-post-obj-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-post-obj-attr.
   buffer-copy old-action-post-obj-attr to new-action-post-obj-attr.
end.
for each old-action-post-role  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-post-role.
   buffer-copy old-action-post-role to new-action-post-role.
end.
for each old-action-post-role-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-post-role-attr.
   buffer-copy old-action-post-role-attr to new-action-post-role-attr.
end.
for each old-action-post-user-login  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-post-user-login.
   buffer-copy old-action-post-user-login to new-action-post-user-login.
end.
for each old-action-post-user-login-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-post-user-login-attr.
   buffer-copy old-action-post-user-login-attr to new-action-post-user-login-attr.
end.
for each old-action-role  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-role.
   buffer-copy old-action-role to new-action-role.
end.
for each old-action-role-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-role-attr.
   buffer-copy old-action-role-attr to new-action-role-attr.
end.
for each old-action-role-item  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-role-item.
   buffer-copy old-action-role-item to new-action-role-item.
end.
for each old-action-role-item-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-role-item-attr.
   buffer-copy old-action-role-item-attr to new-action-role-item-attr.
end.
for each old-action-role-item-gds  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-role-item-gds.
   buffer-copy old-action-role-item-gds to new-action-role-item-gds.
end.
for each old-action-role-item-gds-grp  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-action-role-item-gds-grp.
   buffer-copy old-action-role-item-gds-grp to new-action-role-item-gds-grp.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: ~
action-group ~
action-group-attr ~
action-head ~
action-head-attr ~
action-item ~
action-item-attr ~
action-post ~
action-post-attr ~
action-post-host ~
action-post-host-attr ~
action-post-menu-group ~
action-post-menu-group-attr ~
action-post-obj ~
action-post-obj-attr ~
action-post-role ~
action-post-role-attr ~
action-post-user-login ~
action-post-user-login-attr ~
action-role ~
action-role-attr ~
action-role-item ~
action-role-item-attr ~
action-role-item-gds ~
action-role-item-gds-grp ~
".
end.
