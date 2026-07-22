block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории итогов ДК по объекту

Автор: Бахтадзе Наталья Викторовна
Дата создания: 21/01/04
Author: Bakhtadze Natalya
Creation date: 21/01/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-dis-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории итогов ДК по объекту" .
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                         ,  ub.c-dis-obj.d-card
                         ,  ub.c-dis-obj.dt-code
                         , ub.c-dis-obj.obj-type
                         , ub.c-dis-obj.obj-code
                         , ub.c-dis-obj.corr-user-db-num
                         , ub.c-dis-obj.chip-num
                         ) " }
{ cmp/trg-def.i }


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if ub.c-dis-obj.card-num >= 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Удаление записи ИСТОРИИ итогов ДК по объекту возможно только для НЕИСПОЛЬЗОВАННЫХ карт"
    view-as alert-box error .
    undo main-block, return error .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_c-dis-obj}
        , input ( buffer ub.c-dis-obj:handle )
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