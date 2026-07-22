block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы истории атрибутов внешних артикулов

Автор: Хныкин Павел Андреевич
Дата создания: 02/15/06
Author: Pavel Khnykin
Creation date: 02/15/06

*/

trigger procedure for delete of ub.c-ext-artic-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                        , c-ext-artic-attr.cli-type
                        , c-ext-artic-attr.cli-code
                        , c-ext-artic-attr.gds-code
                        , c-ext-artic-attr.attr-code
                        , c-ext-artic-attr.chip-num
                        ) "
}
{ cmp/trg-def.i  }

main-block:
do on error  undo main-block , return error return-value
   on endkey undo main-block , return error return-value
   on stop   undo main-block , return error return-value
   :
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять запись ИСТОРИИ АТРИБУТА ВНЕШНЕГО АРТИКУЛА"
    view-as alert-box error .
    undo main-block, return error .
end.