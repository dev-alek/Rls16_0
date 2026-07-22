block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00206000.p $
$Archive: cut/00206000.p $

Файл пирога обрезания. Относится к категории 206.


action-group
action-group-attr
action-head
action-head-attr
action-item
action-item-attr
action-post
action-post-attr
action-post-host
action-post-host-attr
action-post-menu-group
action-post-menu-group-attr
action-post-obj
action-post-obj-attr
action-post-role
action-post-role-attr
action-post-user-login
action-post-user-login-attr
action-role
action-role-attr
action-role-item
action-role-item-attr
action-role-item-gds
action-role-item-gds-grp

Автор: Белоусов Илья Александрович
Дата создания: 06/18/09
Author: Ilia Belousov
Creation date: 06/18/09

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00206000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00206000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 104.".
{ cmp/str-glbl.i }

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

/*define buffer old- for src..*/
/*define buffer new- for dst..*/




do
on error undo, return error SUBSTITUTE ( "&1 &2 &3"
                                       , return-value
                                       , error-status:get-message(1)
                                       , error-status:get-message(2)
                                       ) :
{ utl/00000001.i }

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
/*on WRITE of dst.                 override do: end.*/


{ utl/00000002.i action-group                }
{ utl/00000002.i action-group-attr           }
{ utl/00000002.i action-head                 }
{ utl/00000002.i action-head-attr            }
{ utl/00000002.i action-item                 }
{ utl/00000002.i action-item-attr            }
{ utl/00000002.i action-post                 }
{ utl/00000002.i action-post-attr            }
{ utl/00000002.i action-post-host            }
{ utl/00000002.i action-post-host-attr       }
{ utl/00000002.i action-post-menu-group      }
{ utl/00000002.i action-post-menu-group-attr }
{ utl/00000002.i action-post-obj             }
{ utl/00000002.i action-post-obj-attr        }
{ utl/00000002.i action-post-role            }
{ utl/00000002.i action-post-role-attr       }
{ utl/00000002.i action-post-user-login      }
{ utl/00000002.i action-post-user-login-attr }
{ utl/00000002.i action-role                 }
{ utl/00000002.i action-role-attr            }
{ utl/00000002.i action-role-item            }
{ utl/00000002.i action-role-item-attr       }
{ utl/00000002.i action-role-item-gds        }
{ utl/00000002.i action-role-item-gds-grp    }
/*{ utl/00000002.i  }*/

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


