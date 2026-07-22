/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории средства измерения

Автор: Молотков Сергей Михайлович
Дата создания: 30/11/17
Author: Molotkov Sergey
Creation date: 30/11/17

*/
block-level on error undo, throw.

TRIGGER PROCEDURE FOR DELETE OF ub.c-sr-izmerenia.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории средства измерения".
{ cmp/vssrevis.i "substitute('&1', ub.c-sr-izmerenia.node-code)" }

  undo, throw new Progress.Lang.AppError(
    substitute(  "&1: Ошибка удаления истории средства измерения [&2]." +
                " Запрещено уделание истории из таблицы c-sr-izmerenia",
                 vss-workfile, ub.c-sr-izmerenia.node-code  )
  ) .
