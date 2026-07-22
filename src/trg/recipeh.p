block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись истории рецепта

Автор: Белоусов Илья Александрович
Дата создания: 03/23/06
Author: Ilia Belousov
Creation date: 03/23/06

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запись истории рецепта".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }


do
on error undo, return error
:
/* TODO */
end.