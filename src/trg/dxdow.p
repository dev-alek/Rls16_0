block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись XYZ анализа

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.doc-xyz-def-obj  OLD old_doc-xyz-def-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись XYZ анализа ".
{ cmp/vssrevis.i "substitute('&1', ub.doc-xyz-def-obj.doxd-id ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }



main-block :
do transaction
on error undo main-block, return error
:

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_doc-xyz-def-obj}
        , input ( buffer ub.doc-xyz-def-obj:handle )
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