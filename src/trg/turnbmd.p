block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление Обороты по покупателю итоговые

Автор: Чернова Светлана Александровна
Дата создания: 12/01/05
Author: Svetlana Chernova
Creation date: 12/01/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.turnover-buyer-main.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обороты по покупателю итоговые".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
for each ub.turnover-buyer exclusive-lock where
    ub.turnover-buyer.cli-code = ub.turnover-buyer-main.cli-code and
    ub.turnover-buyer.cli-type = ub.turnover-buyer-main.cli-type and
    ub.turnover-buyer.obj-type = ub.turnover-buyer-main.obj-type and
    ub.turnover-buyer.obj-code = ub.turnover-buyer-main.obj-code :
    delete ub.turnover-buyer .
end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_turnover-buyer-main}
        , input ( buffer ub.turnover-buyer-main:handle )
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