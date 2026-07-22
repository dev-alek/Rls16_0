block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mig_0001.p $
$Archive: utl/mig_0001.p $

Модификация таблиц  раздела Пользователи

Автор: Чернова Светлана Александровна
Дата создания: 12/08/08
Author: Svetlana Chernova
Creation date: 12/08/08

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0001.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0001.p $":U .
define variable vss-description as character no-undo init "Модификация таблиц раздела Пользователи".
{ cmp/vssrevis.i }
{ utl/mig_0001.i }

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute ( "Пользователи" )
    ).

on write   of ub.user-login                   override do: end .
on delete  of ub.user-login                   override do: end .
on delete  of ub.user-login-action-item       override do: end .
on delete  of ub.user-login-action-item-attr  override do: end .
on delete  of ub.user-login-action-role       override do: end .
on delete  of ub.user-login-action-role-attr  override do: end .
on delete  of ub.user-login-attr              override do: end .
on delete  of ub.user-menu-group              override do: end .
on delete  of ub.user-menu-group-attr         override do: end .
on delete  of ub.action-role                  override do: end .
on delete  of ub.action-role-attr             override do: end .
on delete  of ub.action-role-item             override do: end .
on delete  of ub.action-role-item-attr        override do: end .

on write   of ub.user-login-action-item       override do: end .
on write   of ub.user-login-action-item-attr  override do: end .
on write   of ub.user-login-action-role       override do: end .
on write   of ub.user-login-action-role-attr  override do: end .
on write   of ub.user-login-attr              override do: end .
on write   of ub.user-menu-group              override do: end .
on write   of ub.user-menu-group-attr         override do: end .
on write   of ub.action-role                  override do: end .
on write   of ub.action-role-attr             override do: end .
on write   of ub.action-role-item             override do: end .
on write   of ub.action-role-item-attr        override do: end .
on write   of ub.user-host                    override do: end .
on write   of ub.user-host-attr               override do: end .
on write   of ub.user-obj                     override do: end .
on write   of ub.user-obj-attr                override do: end .

  do
  on error undo, return error return-value
  :
    for each ub.user-login exclusive-lock   :
         ub.user-login.db-num = 0.
    end.
     /*----------*/
    for each ub.user-login-action-item exclusive-lock   where
             ub.user-login-action-item.db-num <>  p-db-num
    :
             delete ub.user-login-action-item.
    end.

    for each ub.user-login-action-item-attr exclusive-lock   where
             ub.user-login-action-item-attr.db-num <> p-db-num
    :
              delete ub.user-login-action-item-attr.
    end.

    for each ub.user-login-action-role exclusive-lock   where
             ub.user-login-action-role.db-num <> p-db-num
    :
              delete ub.user-login-action-role.
    end.

    for each ub.user-login-action-role-attr exclusive-lock   where
             ub.user-login-action-role-attr.db-num <> p-db-num
    :
              delete ub.user-login-action-role-attr.
    end.

    for each ub.user-login-attr exclusive-lock  where
             ub.user-login-attr.db-num <> p-db-num
      :
             delete ub.user-login-attr .
    end.
    for each ub.user-menu-group exclusive-lock  where
             ub.user-menu-group.db-num <> p-db-num
    :
        delete ub.user-menu-group.
    end.

    for each ub.user-menu-group-attr exclusive-lock  where
             ub.user-menu-group-attr.db-num <> p-db-num
      :
        delete ub.user-menu-group-attr.
    end.

    for each ub.action-role           exclusive-lock  where
             ub.action-role.db-num <> p-db-num           :
             delete ub.action-role.
    end.
    for each ub.action-role-attr      exclusive-lock  where
             ub.action-role-attr.db-num <> p-db-num      :
             delete ub.action-role-attr.
    end.
    for each ub.action-role-item      exclusive-lock  where
             ub.action-role-item.db-num <> p-db-num      :
             delete ub.action-role-item.
    end.
    for each ub.action-role-item-attr exclusive-lock  where
             ub.action-role-item-attr.db-num <> p-db-num :
             delete ub.action-role-item-attr.
    end.

    /*----------*/
    for each ub.user-login-action-item exclusive-lock   where
             ub.user-login-action-item.db-num =  p-db-num
    :
              ub.user-login-action-item.db-num = 0.
    end.
    for each ub.user-login-action-item-attr exclusive-lock   where
             ub.user-login-action-item-attr.db-num = p-db-num
    :
              ub.user-login-action-item-attr.db-num = 0.
    end.
    for each ub.user-login-action-role exclusive-lock   where
             ub.user-login-action-role.db-num = p-db-num
    :
              ub.user-login-action-role.db-num = 0.
    end.
    for each ub.user-login-action-role-attr exclusive-lock   where
             ub.user-login-action-role-attr.db-num = p-db-num
    :
              ub.user-login-action-role-attr.db-num = 0 .
    end.

    for each ub.user-login-attr exclusive-lock  where
             ub.user-login-attr.db-num = p-db-num
      :
             ub.user-login-attr.db-num = 0 .
    end.
    for each ub.user-menu-group exclusive-lock  where
             ub.user-menu-group.db-num = p-db-num
    :
        ub.user-menu-group.db-num = 0.
    end.

    for each ub.user-menu-group-attr exclusive-lock  where
             ub.user-menu-group-attr.db-num = p-db-num
      :
        ub.user-menu-group-attr.db-num = 0.
    end.

    for each ub.action-role           exclusive-lock  where
             ub.action-role.db-num = p-db-num           :
             ub.action-role.db-num            = 0 .
    end.
    for each ub.action-role-attr      exclusive-lock  where
             ub.action-role-attr.db-num = p-db-num      :
             ub.action-role-attr.db-num       = 0 .
    end.
    for each ub.action-role-item      exclusive-lock  where
             ub.action-role-item.db-num = p-db-num      :
             ub.action-role-item.db-num       = 0 .
    end.
    for each ub.action-role-item-attr exclusive-lock  where
             ub.action-role-item-attr.db-num = p-db-num :
             ub.action-role-item-attr.db-num = 0 .
    end.

    for each ub.user-host exclusive-lock  where
             ub.user-host.db-num = p-db-num :
             ub.user-host.db-num = 0 .
    end.
    for each ub.user-host-attr exclusive-lock  where
             ub.user-host-attr.db-num = p-db-num :
             ub.user-host-attr.db-num = 0 .
    end.

    for each ub.user-obj exclusive-lock  where
             ub.user-obj.db-num = p-db-num :
             ub.user-obj.db-num = 0 .
    end.

    for each ub.user-obj-attr exclusive-lock  where
             ub.user-obj-attr.db-num = p-db-num :
             ub.user-obj-attr.db-num = 0 .
    end.


end.




