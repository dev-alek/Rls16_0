block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории атрибута ДопБК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/14/07
Author: Bakhtadze Natalya
Creation date: 03/14/07

*/

TRIGGER PROCEDURE FOR write OF ub.c-prod-bc-attr .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории атрибута ДопБК".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5':u~
                              ,ub.c-prod-bc-attr.b-code~
                              ,ub.c-prod-bc-attr.b-str~
                              ,ub.c-prod-bc-attr.attr-code~
                              ,ub.c-prod-bc-attr.corr-user-db-num~
                              ,ub.c-prod-bc-attr.chip-num~
                              )" }
{ cmp/trg-def.i }

do
on error undo, return error
:
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-prod-bc-attr}
        , input ( buffer ub.c-prod-bc-attr:handle )
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