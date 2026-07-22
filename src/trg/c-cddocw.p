block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории документа на кассе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/07
Author: Bakhtadze Natalya
Creation date: 01/22/07

*/


TRIGGER PROCEDURE FOR WRITE OF ub.c-cd-doc.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории документа на кассе".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                                    ,ub.c-cd-doc.obj-type
                                    ,ub.c-cd-doc.obj-code
                                    ,ub.c-cd-doc.pos-type
                                    ,ub.c-cd-doc.doc-type
                                    ,ub.c-cd-doc.doc-code
                                    ,ub.c-cd-doc.corr-user-db-num
                                    ,ub.c-cd-doc.chip-num
                                          ) " }
{ cmp/trg-def.i  }

do
on error undo, return error
:
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-cd-doc}
        , input ( buffer ub.c-cd-doc:handle )
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