block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись таблицы cbr-bank

Автор: Булгаков Андрей Николаевич
Дата создания: 10/07/05
Author: Andrew Bulgakoff
Creation date: 10/07/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-cbr-bank NEW BUFFER Buf-New OLD BUFFER Buf-Old.

DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision$":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author$":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date$":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile$":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive$":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Триггер на запись таблицы cbr-bank":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

Main-Block:
DO ON ERROR   UNDO Main-Block, LEAVE Main-Block
   ON END-KEY UNDO Main-Block, LEAVE Main-Block :
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-cbr-bank}
        , input ( buffer ub.c-cbr-bank:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
END. /* Main-Block */
