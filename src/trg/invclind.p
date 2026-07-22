block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории по строке итогов (весовой учет топлива)

Автор: Булгаков Андрей Николаевич
Дата создания: 10/04/05
Author: Andrew Bulgakoff
Creation date: 10/04/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-inv-line.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление истории по строке итогов (весовой учет топлива)":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

Main-Block:
do transaction on error   undo Main-Block, return error
               on end-key undo Main-Block, return error
               on stop    undo Main-Block, return error :

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_c-inv-line}
        , input ( buffer ub.c-inv-line:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end. /* Main-Block */
