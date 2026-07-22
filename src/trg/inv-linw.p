block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись итогов по топливным товарам

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/20/06
Author: Dmitry Ukhanov
Creation date: 10/20/06

create: Булгаков Андрей Николаевич
Дата создания: 10/04/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.inv-line NEW BUFFER newb OLD BUFFER oldb.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись итогов по топливным товарам":U.

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/checkart.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_inv-line}
        , input ( buffer ub.inv-line:handle )
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