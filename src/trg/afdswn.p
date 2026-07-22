block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись arh-fin-doc-schet-nal

Автор: Суслов Алексей Юрьевич
Дата создания: 04/04/06
Author: Alexey Suslov
Creation date: 04/04/06


*/

TRIGGER PROCEDURE FOR WRITE OF ub.arh-fin-doc-schet-nal OLD old-arh-fin-doc-schet-nal.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись arh-fin-doc-schet-nal".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error undo main-block, return error return-value
:
  run str/callnews.p
    (input "arh-fin-doc-schet-nal":u
    ,input (buffer ub.arh-fin-doc-schet-nal:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_arh-fin-doc-schet-nal}
        , input ( buffer ub.arh-fin-doc-schet-nal:handle )
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