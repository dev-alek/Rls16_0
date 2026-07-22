block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись arh-fin-doc-an-nal-obj

Автор: Суслов Алексей Юрьевич
Дата создания: 04/04/06
Author: Alexey Suslov
Creation date: 04/04/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.arh-fin-doc-an-nal-obj .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись arh-fin-doc-an-nal-obj".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

do
on error undo, return error
:
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_arh-fin-doc-an-nal-obj}
        , input ( buffer ub.arh-fin-doc-an-nal-obj:handle )
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