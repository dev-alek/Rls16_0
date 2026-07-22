block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории итогов ДК по фирме

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/27/04
Author: Bakhtadze Natalya
Creation date: 01/27/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-dis-host.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории итогов ДК по фирме".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                          , ub.c-dis-host.d-card
                          , ub.c-dis-host.dt-code
                          , ub.c-dis-host.host-code
                          , ub.c-dis-host.corr-user-db-num
                          , ub.c-dis-host.chip-num
                          ) " }
{ cmp/trg-def.i }

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
        , input {&table_c-dis-host}
        , input ( buffer ub.c-dis-host:handle )
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