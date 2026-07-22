block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы внешних артикулов

Автор: Хныкин Павел Андреевич
Дата создания: 02/15/06
Author: Pavel Khnykin
Creation date: 02/15/06

*/

trigger procedure for delete of ub.ext-artic.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление таблицы внешних артикулов".
{ cmp/vssrevis.i  }
{ cmp/trg-def.i   }
{ gbl/cur-time.i  }

define buffer buf_c-ext-artic for ub.c-ext-artic.

define variable v-date as date      no-undo .
define variable v-time as integer   no-undo .

main-block:
 do on error  undo main-block , return error return-value
    on endkey undo main-block , return error return-value
    on stop   undo main-block , return error return-value
    :
      message
      vss-workfile vss-revision vss-description skip
      "Физическое удаление внешнего артикула запрещено"
      view-as alert-box error .
      undo main-block, return error .
end.