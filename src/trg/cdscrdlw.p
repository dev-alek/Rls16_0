block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории ДЛИННОГО НОМЕРА ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/14/06
Author: Bakhtadze Natalya
Creation date: 08/14/06

*/


TRIGGER PROCEDURE FOR WRITE OF ub.c-dis-card-long.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории ДЛИННОГО НОМЕРА ДК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

do
on error undo, return error
:
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-dis-card-long}
        , input ( buffer ub.c-dis-card-long:handle )
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
end.