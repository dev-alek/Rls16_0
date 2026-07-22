block-level on error undo, throw.
/*

$Revision: a0259edc0fbd, 1040, rls $
$Author: ASMorozov $
$Date: Fri Oct 06 18:30:43 2017 +0300 $
$Workfile: 00181000.p $
$Archive: cut/00181000.p $

Файл пирога обрезания. Относится к категории 181.

Автор: Чернова Светлана Александровна
Дата создания: 08/05/09
Author: Svetlana Chernova
Creation date: 08/05/09

Обработка таблиц:

эти живу в flt

usr-flt
usr-flt-attr
menu-user-call
menu-user-call-attr
user-context-history
user-context-history-attr
user-window-attr



user-login
c-user-login
user-login-action-item
user-login-action-item-attr
user-login-action-role
user-login-action-role-attr
user-login-attr
c-user-log
c-usr-hist
user-account
user-account-attr
c-user-account
user-conn-attr
user-host
user-host-attr
user-menu-group
user-menu-group-attr
user-obj
user-obj-attr
menu-user
menu-user-attr
db-usr-flt
db-usr-flt-attr

*/

define variable vss-revision    as character no-undo init "$Revision: a0259edc0fbd, 1040, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Oct 06 18:30:43 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00181000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00181000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 181.".
{ cmp/str-glbl.i }

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
{ utl/00000001.i }

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




{ utl/00000002.i usr-flt  }
{ utl/00000002.i usr-flt-attr  }
{ utl/00000002.i menu-user-call  }
{ utl/00000002.i menu-user-call-attr  }
{ utl/00000002.i user-context-history  }
{ utl/00000002.i user-context-history-attr  }
{ utl/00000002.i user-window-attr  }

{ utl/00000002.i db-usr-flt  }
{ utl/00000002.i db-usr-flt-attr  }
{ utl/00000002.i user-login  }
if varstay-history then do:
  { utl/00000002.i c-user-login  }
  { utl/00000002.i c-user-log  }
  { utl/00000002.i c-usr-hist  }
end.
{ utl/00000002.i user-login-action-item  }
{ utl/00000002.i user-login-action-item-attr  }
{ utl/00000002.i user-login-action-role  }
{ utl/00000002.i user-login-action-role-attr  }
{ utl/00000002.i user-login-attr  }
{ utl/00000002.i user-account  }
if varstay-history then do:
  { utl/00000002.i c-user-account  }
end.
{ utl/00000002.i user-account-attr  }
{ utl/00000002.i user-conn-attr  }

{ utl/00000002.i user-host }
{ utl/00000002.i user-host-attr }
{ utl/00000002.i user-menu-group }
{ utl/00000002.i user-menu-group-attr }
{ utl/00000002.i user-obj }
{ utl/00000002.i user-obj-attr }
{ utl/00000002.i menu-user  }
{ utl/00000002.i menu-user-attr  }

output stream str-gen close.
return "Произведен экспорт таблиц: usr-flt usr-flt-attr menu-user-call menu-user-call-attr user-context-history user-context-history-attr user-window-attr ~
db-usr-flt db-usr-flt-attr ~
user-login c-user-login c-user-log c-usr-hist user-login-action-item user-login-action-item-attr user-login-action-role ~
user-login-action-role-attr user-login-attr user-conn-attr ~
user-host user-host-attr user-menu-group user-menu-group-attr user-obj user-obj-attr ~
menu-user menu-user-attr .".
end.