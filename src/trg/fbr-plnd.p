block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи документа план-меню

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

TRIGGER PROCEDURE FOR DELETE OF ub.fbr-pln .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи документа план-меню".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error   undo main-block, return error
on end-key undo main-block, return error
:
    if ub.fbr-pln.status_ = {&fact}
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Нельзя удалять документ план-меню, закрытый до статуса" ub.fbr-pln.status_
            skip "Номер документа: " ub.fbr-pln.doc-code
            skip "Статус документа:" ub.fbr-pln.status_
        view-as alert-box error .
        undo main-block, return error .
    end.
    /* проверяем, что не осталось подчиненных линий */
    find first ub.fbr-pln-line no-lock
         where ub.fbr-pln-line.doc-code = ub.fbr-pln.doc-code
    no-error .
    if available ub.fbr-pln-line
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка при удалении документа производства"
            skip "Найдена строка документа производства"
            skip "Документ"    ub.fbr-pln-line.doc-code
            skip "doc-type"    ub.fbr-pln-line.doc-type
            skip "recipe-code" ub.fbr-pln-line.recipe-code
            skip "artic"       ub.fbr-pln-line.artic
            skip "prod-type"   ub.fbr-pln-line.prod-type
            skip "prod-code"   ub.fbr-pln-line.prod-code
        view-as alert-box error .
        undo main-block, return error .
    end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_fbr-pln}
        , input ( buffer ub.fbr-pln:handle )
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