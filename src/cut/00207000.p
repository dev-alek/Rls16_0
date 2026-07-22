block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00207000.p $
$Archive: cut/00207000.p $

Файл пирога обрезания. Относится к категории 181.


menu-group
menu-group-attr
menu-head
menu-head-attr
menu-item
menu-item-attr
menu-item-group
menu-item-group-attr


Автор: Белоусов Илья Александрович
Дата создания: 06/18/09
Author: Ilia Belousov
Creation date: 06/18/09

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00207000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00207000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 104.".
{ cmp/str-glbl.i }

define buffer old-menu-group           for src.menu-group          .
define buffer old-menu-group-attr      for src.menu-group-attr     .
define buffer old-menu-head            for src.menu-head           .
define buffer old-menu-head-attr       for src.menu-head-attr      .
define buffer old-menu-item            for src.menu-item           .
define buffer old-menu-item-attr       for src.menu-item-attr      .
define buffer old-menu-item-group      for src.menu-item-group     .
define buffer old-menu-item-group-attr for src.menu-item-group-attr.
/*define buffer old- for src..*/

define buffer new-menu-group           for dst.menu-group          .
define buffer new-menu-group-attr      for dst.menu-group-attr     .
define buffer new-menu-head            for dst.menu-head           .
define buffer new-menu-head-attr       for dst.menu-head-attr      .
define buffer new-menu-item            for dst.menu-item           .
define buffer new-menu-item-attr       for dst.menu-item-attr      .
define buffer new-menu-item-group      for dst.menu-item-group     .
define buffer new-menu-item-group-attr for dst.menu-item-group-attr.
/*define buffer new- for dst..*/




do
on error undo, return error SUBSTITUTE ( "&1 &2 &3"
                                       , return-value
                                       , error-status:get-message(1)
                                       , error-status:get-message(2)
                                       ) :
{ utl/00000001.i }

on WRITE of dst.menu-group                           override do: end.
on WRITE of dst.menu-group-attr                      override do: end.
on WRITE of dst.menu-head                            override do: end.
on WRITE of dst.menu-head-attr                       override do: end.
on WRITE of dst.menu-item                            override do: end.
on WRITE of dst.menu-item-attr                       override do: end.
on WRITE of dst.menu-item-group                      override do: end.
on WRITE of dst.menu-item-group-attr                 override do: end.
/*on WRITE of dst.                 override do: end.*/


{ utl/00000002.i menu-group           }
{ utl/00000002.i menu-group-attr      }
{ utl/00000002.i menu-head            }
{ utl/00000002.i menu-head-attr       }
{ utl/00000002.i menu-item            }
{ utl/00000002.i menu-item-attr       }
{ utl/00000002.i menu-item-group      }
{ utl/00000002.i menu-item-group-attr }
/*{ utl/00000002.i  }*/

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