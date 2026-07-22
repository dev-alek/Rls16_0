block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись db-rec-attr

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/05
Author: Dmitry Ukhanov
Creation date: 03/22/05

*/

trigger procedure for write of ub.db-rec-attr old buffer old-db-rec-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись db-rec-attr".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }


do
on error undo, return error return-value
:

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_db-rec-attr}
        , input ( buffer ub.db-rec-attr:handle )
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