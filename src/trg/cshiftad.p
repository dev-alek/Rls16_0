block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории  атрибуты смены

Автор: Чернова Светлана Александровна
Дата создания: 08/02/07
Author: Svetlana Chernova
Creation date: 08/02/07

*/
TRIGGER PROCEDURE FOR DELETE OF ub.c-shift-attr.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории  атрибуты смены".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }


main-block :
do transaction
on error undo main-block, return error
:
    if g#oxml = yes
    then do:
        run str/calloxml.p (
              input {&nwsdochs_action_delete}
            , input {&table_c-shift-attr}
            , input ( buffer ub.c-shift-attr:handle )
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
end.