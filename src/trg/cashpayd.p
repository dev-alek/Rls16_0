block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи тип платежа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.cash-pay .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи тип платежа".
{ cmp/vssrevis.i "substitute('&1|&2'
                        , ub.cash-pay.cdpay-code
                        , ub.cash-pay.curr-code) " }
{ cmp/trg-def.i  }

define variable v-mess as character no-undo .

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    run trg/userlog.p (
        input {&nwsdochs_action_create}
        , input {&table_cash-pay}
        , input ( buffer ub.cash-pay :handle )
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
    if g#esys then 
    do:
        v-mess = "Физическое удаление типа платежа в системе запрещено" .
        return error.
    end.
    else 
    do: 
        message
            vss-workfile vss-revision vss-description skip
            "Физическое удаление типа платежа в системе запрещено" skip
            view-as alert-box error .
        undo main-block, return error.
    end.
end.