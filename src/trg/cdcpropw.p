block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории свойства ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/15/06
Author: Bakhtadze Natalya
Creation date: 08/15/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-dis-card-property.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории свойства ДК".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                         , ub.c-dis-card-property.d-card
                         , ub.c-dis-card-property.dt-code
                         , ub.c-dis-card-property.node-code
                         , ub.c-dis-card-property.host-code
                         , ub.c-dis-card-property.obj-type
                         , ub.c-dis-card-property.obj-code
                         , ub.c-dis-card-property.corr-user-db-num
                         , ub.c-dis-card-property.chip-num
                         ) " }
{ cmp/trg-def.i  }

do
on error undo, return error
:
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-dis-card-property}
        , input ( buffer ub.c-dis-card-property:handle )
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