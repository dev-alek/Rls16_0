block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись шапки истории смен

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/09/05
Author: Bakhtadze Natalya
Creation date: 08/09/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-sht-hist.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись шапки истории смен".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                            , ub.c-sht-hist.obj-type
                            , ub.c-sht-hist.obj-code
                            , ub.c-sht-hist.shift-date
                            , ub.c-sht-hist.shift-num
                            , ub.c-sht-hist.corr-user-db-num
                            , ub.c-sht-hist.chip-num
                            , ub.c-sht-hist.subject
                            ) " }
{ cmp/trg-def.i  }
/*маршрутизируется только кустами shift-obj и c-shift-obj*/


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
        , input {&table_c-sht-hist}
        , input ( buffer ub.c-sht-hist:handle )
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