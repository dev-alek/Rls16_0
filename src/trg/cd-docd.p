block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление документа на кассе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/07
Author: Bakhtadze Natalya
Creation date: 01/22/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.cd-doc.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление документа на кассе".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                                    ,ub.cd-doc.obj-type
                                    ,ub.cd-doc.obj-code
                                    ,ub.cd-doc.pos-type
                                    ,ub.cd-doc.doc-type
                                    ,ub.cd-doc.doc-code
                                          ) " }
{ cmp/trg-def.i  }

do
on error undo, return error
:
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_cd-doc}
        , input ( buffer ub.cd-doc:handle )
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