block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: a0259edc0fbd, 1040, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Oct 06 18:30:43 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00181000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00181000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 181.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define buffer old-usr-flt  for ubfltsrc.usr-flt .
define buffer new-usr-flt  for ubfltdst.usr-flt .
define buffer old-usr-flt-attr                     for ubfltsrc.usr-flt-attr .
define buffer new-usr-flt-attr                     for ubfltdst.usr-flt-attr .
define buffer old-menu-user-call                   for ubfltsrc.menu-user-call .
define buffer new-menu-user-call                   for ubfltdst.menu-user-call .
define buffer old-menu-user-call-attr              for ubfltsrc.menu-user-call-attr .
define buffer new-menu-user-call-attr              for ubfltdst.menu-user-call-attr .
define buffer old-user-context-history             for ubfltsrc.user-context-history .
define buffer new-user-context-history             for ubfltdst.user-context-history .
define buffer old-user-context-history-attr        for ubfltsrc.user-context-history-attr .
define buffer new-user-context-history-attr        for ubfltdst.user-context-history-attr .
define buffer old-user-window-attr                 for ubfltsrc.user-window-attr .
define buffer new-user-window-attr                 for ubfltdst.user-window-attr .
define buffer old-db-usr-flt                       for src.db-usr-flt .
define buffer new-db-usr-flt                       for dst.db-usr-flt .
define buffer old-db-usr-flt-attr                  for src.db-usr-flt-attr .
define buffer new-db-usr-flt-attr                  for dst.db-usr-flt-attr .
define buffer old-user-login                       for src.user-login .
define buffer new-user-login                       for dst.user-login .
define buffer old-c-user-login                     for src.c-user-login .
define buffer new-c-user-login                     for dst.c-user-login .
define buffer old-c-user-log                       for src.c-user-log .
define buffer new-c-user-log                       for dst.c-user-log .
define buffer old-c-usr-hist                       for src.c-usr-hist .
define buffer new-c-usr-hist                       for dst.c-usr-hist .
define buffer old-user-login-action-item           for src.user-login-action-item .
define buffer new-user-login-action-item           for dst.user-login-action-item .
define buffer old-user-login-action-item-attr      for src.user-login-action-item-attr .
define buffer new-user-login-action-item-attr      for dst.user-login-action-item-attr .
define buffer old-user-login-action-role           for src.user-login-action-role .
define buffer new-user-login-action-role           for dst.user-login-action-role .
define buffer old-user-login-action-role-attr      for src.user-login-action-role-attr .
define buffer new-user-login-action-role-attr      for dst.user-login-action-role-attr .
define buffer old-user-login-attr                  for src.user-login-attr .
define buffer new-user-login-attr                  for dst.user-login-attr .
define buffer old-user-account                     for src.user-account .
define buffer new-user-account                     for dst.user-account .
define buffer old-c-user-account                   for src.c-user-account .
define buffer new-c-user-account                   for dst.c-user-account .
define buffer old-user-account-attr                for src.user-account-attr .
define buffer new-user-account-attr                for dst.user-account-attr .
define buffer old-user-conn-attr                   for src.user-conn-attr .
define buffer new-user-conn-attr                   for dst.user-conn-attr .
define buffer old-user-host                        for src.user-host .
define buffer new-user-host                        for dst.user-host .
define buffer old-user-host-attr                   for src.user-host-attr   .
define buffer new-user-host-attr                   for dst.user-host-attr   .
define buffer old-user-menu-group                  for src.user-menu-group  .
define buffer new-user-menu-group                  for dst.user-menu-group  .
define buffer old-user-menu-group-attr             for src.user-menu-group-attr.
define buffer new-user-menu-group-attr             for dst.user-menu-group-attr.
define buffer old-user-obj                         for src.user-obj .
define buffer new-user-obj                         for dst.user-obj .
define buffer old-user-obj-attr                    for src.user-obj-attr.
define buffer new-user-obj-attr                    for dst.user-obj-attr.
define buffer old-menu-user                        for src.menu-user.
define buffer new-menu-user                        for dst.menu-user .
define buffer old-menu-user-attr                   for src.menu-user-attr.
define buffer new-menu-user-attr                   for dst.menu-user-attr .
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
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
on write of ubfltdst.usr-flt override do: end.
on write of ubfltdst.usr-flt-attr             override do: end.
on write of ubfltdst.menu-user-call           override do: end.
on write of ubfltdst.menu-user-call-attr      override do: end.
on write of ubfltdst.user-context-history     override do: end.
on write of ubfltdst.user-context-history-attr override do: end.
on write of ubfltdst.user-window-attr         override do: end.
on write of dst.db-usr-flt                    override do: end.
on write of dst.db-usr-flt-attr               override do: end.
on write of dst.user-login                    override do: end.
on write of dst.c-user-login                  override do: end.
on write of dst.c-user-log                    override do: end.
on write of dst.user-login-action-item        override do: end.
on write of dst.user-login-action-item-attr   override do: end.
on write of dst.user-login-action-role        override do: end.
on write of dst.user-login-action-role-attr   override do: end.
on write of dst.user-login-attr               override do: end.
on write of dst.user-account                  override do: end.
on write of dst.c-user-account                override do: end.
on write of dst.user-account-attr             override do: end.
on write of dst.user-conn-attr                override do: end.
on write of dst.user-host                     override do: end.
on write of dst.user-host-attr                override do: end.
on write of dst.user-menu-group               override do: end.
on write of dst.user-menu-group-attr          override do: end.
on write of dst.user-obj                      override do: end.
on write of dst.user-obj-attr                 override do: end.
on write of dst.menu-user                     override do: end.
on write of dst.menu-user-attr                override do: end.
on write of dst.c-usr-hist                    override do: end.
for each old-usr-flt  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-usr-flt.
   buffer-copy old-usr-flt to new-usr-flt.
end.
for each old-usr-flt-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-usr-flt-attr.
   buffer-copy old-usr-flt-attr to new-usr-flt-attr.
end.
for each old-menu-user-call  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-menu-user-call.
   buffer-copy old-menu-user-call to new-menu-user-call.
end.
for each old-menu-user-call-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-menu-user-call-attr.
   buffer-copy old-menu-user-call-attr to new-menu-user-call-attr.
end.
for each old-user-context-history  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-context-history.
   buffer-copy old-user-context-history to new-user-context-history.
end.
for each old-user-context-history-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-context-history-attr.
   buffer-copy old-user-context-history-attr to new-user-context-history-attr.
end.
for each old-user-window-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-window-attr.
   buffer-copy old-user-window-attr to new-user-window-attr.
end.
for each old-db-usr-flt  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-db-usr-flt.
   buffer-copy old-db-usr-flt to new-db-usr-flt.
end.
for each old-db-usr-flt-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-db-usr-flt-attr.
   buffer-copy old-db-usr-flt-attr to new-db-usr-flt-attr.
end.
for each old-user-login  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-login.
   buffer-copy old-user-login to new-user-login.
end.
if varstay-history then do:
for each old-c-user-login  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-user-login.
   buffer-copy old-c-user-login to new-c-user-login.
end.
for each old-c-user-log  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-user-log.
   buffer-copy old-c-user-log to new-c-user-log.
end.
for each old-c-usr-hist  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-usr-hist.
   buffer-copy old-c-usr-hist to new-c-usr-hist.
end.
end.
for each old-user-login-action-item  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-login-action-item.
   buffer-copy old-user-login-action-item to new-user-login-action-item.
end.
for each old-user-login-action-item-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-login-action-item-attr.
   buffer-copy old-user-login-action-item-attr to new-user-login-action-item-attr.
end.
for each old-user-login-action-role  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-login-action-role.
   buffer-copy old-user-login-action-role to new-user-login-action-role.
end.
for each old-user-login-action-role-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-login-action-role-attr.
   buffer-copy old-user-login-action-role-attr to new-user-login-action-role-attr.
end.
for each old-user-login-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-login-attr.
   buffer-copy old-user-login-attr to new-user-login-attr.
end.
for each old-user-account  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-account.
   buffer-copy old-user-account to new-user-account.
end.
if varstay-history then do:
for each old-c-user-account  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-c-user-account.
   buffer-copy old-c-user-account to new-c-user-account.
end.
end.
for each old-user-account-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-account-attr.
   buffer-copy old-user-account-attr to new-user-account-attr.
end.
for each old-user-conn-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-conn-attr.
   buffer-copy old-user-conn-attr to new-user-conn-attr.
end.
for each old-user-host  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-host.
   buffer-copy old-user-host to new-user-host.
end.
for each old-user-host-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-host-attr.
   buffer-copy old-user-host-attr to new-user-host-attr.
end.
for each old-user-menu-group  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-menu-group.
   buffer-copy old-user-menu-group to new-user-menu-group.
end.
for each old-user-menu-group-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-menu-group-attr.
   buffer-copy old-user-menu-group-attr to new-user-menu-group-attr.
end.
for each old-user-obj  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-obj.
   buffer-copy old-user-obj to new-user-obj.
end.
for each old-user-obj-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-user-obj-attr.
   buffer-copy old-user-obj-attr to new-user-obj-attr.
end.
for each old-menu-user  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-menu-user.
   buffer-copy old-menu-user to new-menu-user.
end.
for each old-menu-user-attr  no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
   create new-menu-user-attr.
   buffer-copy old-menu-user-attr to new-menu-user-attr.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: usr-flt usr-flt-attr menu-user-call menu-user-call-attr user-context-history user-context-history-attr user-window-attr ~
db-usr-flt db-usr-flt-attr ~
user-login c-user-login c-user-log c-usr-hist user-login-action-item user-login-action-item-attr user-login-action-role ~
user-login-action-role-attr user-login-attr user-conn-attr ~
user-host user-host-attr user-menu-group user-menu-group-attr user-obj user-obj-attr ~
menu-user menu-user-attr .".
end.
