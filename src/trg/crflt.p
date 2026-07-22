block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на создание фильтра

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/

trigger procedure for create of ubflt.filter.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на создание фильтра".

{ cmp/vssrevis.i "substitute('&1|&2'
                        , ubflt.filter.call-point
                        , ubflt.filter.naim
                        ) "
}