block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись итогов по диcконтной карте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/05
Author: Bakhtadze Natalya
Creation date: 12/08/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.dis-obj OLD oldb .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись итогов по диcконтной карте".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,ub.dis-obj.d-card,ub.dis-obj.obj-type,ub.dis-obj.obj-code)" }
{ cmp/trg-def.i  }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status:get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_dis-obj}
        , input ( buffer ub.dis-obj:handle )
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