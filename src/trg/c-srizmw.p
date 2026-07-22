/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории средства измерения

Автор: Молотков Сергей Михайлович
Дата создания: 30/11/17
Author: Molotkov Sergey
Creation date: 30/11/17

*/
block-level on error undo, throw.

TRIGGER PROCEDURE FOR WRITE OF ub.c-sr-izmerenia
  NEW BUFFER new-c-sr-izmerenia
  OLD BUFFER old-c-sr-izmerenia
.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории средства измерения".
{ cmp/vssrevis.i "substitute('&1', new-c-sr-izmerenia.node-code)" }

{ cmp/trg-def.i }

  if g#oxml then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-sr-izmerenia}
        , input (buffer new-c-sr-izmerenia:handle)
    ) no-error.
    if error-status :error then do:
      undo, throw new Progress.Lang.AppError(
    substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 )
              )
      ) .
    end.
  end.
