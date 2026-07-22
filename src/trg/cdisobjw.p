block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории итогов ДК по объекту

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/27/04
Author: Bakhtadze Natalya
Creation date: 01/27/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-dis-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории итогов ДК по объекту".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                         ,  ub.c-dis-obj.d-card
                         , ub.c-dis-obj.dt-code
                         , ub.c-dis-obj.obj-type
                         , ub.c-dis-obj.obj-code
                         , ub.c-dis-obj.corr-user-db-num
                         , ub.c-dis-obj.chip-num
                         ) " }
{ cmp/trg-def.i }

define buffer buf_dis-obj for ub.dis-obj.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-dis-obj}
        , input ( buffer ub.c-dis-obj:handle )
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