block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление ДопРасходов

Автор: Чернова Светлана Александровна
Дата создания: 04/03/07
Author: Svetlana Chernova
Creation date: 04/03/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.add-doc.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление ДопРасходов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

do
on error undo, return error
:

    for each ub.add-trn exclusive-lock where
            ub.add-trn.doc-code =  ub.add-doc.doc-code :
            delete ub.add-trn .
    end.
    for each ub.add-line exclusive-lock where
            ub.add-line.doc-code =  ub.add-doc.doc-code :
            delete ub.add-line .
    end.
    for each ub.add-trn-attr exclusive-lock where
            ub.add-trn-attr.doc-code =  ub.add-doc.doc-code :
            delete ub.add-trn-attr .
    end.

    run nws/cmd-del.p
      ( input {&table_add-doc}
        ,input (buffer ub.add-doc:handle)
        ,input "":U
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_add-doc}
        , input ( buffer ub.add-doc:handle )
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