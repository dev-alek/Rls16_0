block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление arh-fin-doc-schet-tax-obj

Автор: Суслов Алексей Юрьевич
Дата создания: 04/04/06
Author: Alexey Suslov
Creation date: 04/04/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.arh-fin-doc-schet-tax-obj .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление arh-fin-doc-schet-tax-obj".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

do
on error undo, return error
:
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_arh-fin-doc-schet-tax-obj}
        , input ( buffer ub.arh-fin-doc-schet-tax-obj:handle )
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