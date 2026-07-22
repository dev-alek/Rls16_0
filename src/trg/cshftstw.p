block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории персонала смены

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/09/05
Author: Bakhtadze Natalya
Creation date: 08/09/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-shift-staff.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории персонала смены".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                            , ub.shift-staff.obj-type
                            , ub.shift-staff.obj-code
                            , ub.shift-staff.shift-date
                            , ub.shift-staff.shift-num
                            , ub.shift-staff.next-shift
                            , ub.shift-staff.psn-num
                            ) " }
{ cmp/trg-def.i  }

/*маршрутизируется в кусте при закрытии смены на факт или в кусте c-sht-hist при удалении смены*/
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
        , input {&table_c-shift-staff}
        , input ( buffer ub.c-shift-staff:handle )
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
    if not g#news then do:
          run trg/userlog.p (
          input {&nwsdochs_action_update}
          , input {&table_c-sht-hist}
          , input ( buffer ub.c-shift-staff :handle )
          , input ?
          , input ""
          ) no-error.
        if error-status :error
          then 
        do:
          undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
            , {&new-line}
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
        end.
    end.
end.