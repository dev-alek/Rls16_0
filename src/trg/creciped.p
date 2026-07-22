block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление коррекции рецепта

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-recipe.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление коррекции рецепта".
{ cmp/vssrevis.i "substitute( '&1|&2', ub.c-recipe.recipe-code, ub.c-recipe.chip-num ) " }
{ cmp/trg-def.i  }

main-block:
do
on error undo main-block, return error
:
    message
        vss-workfile vss-revision vss-description
        skip "Нельзя удалять запись истории рецепта."
    view-as alert-box error .
    undo main-block, return error .
end.