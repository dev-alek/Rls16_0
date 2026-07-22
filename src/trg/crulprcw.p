block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории звена процесса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/04/08
Author: Bakhtadze Natalya
Creation date: 07/04/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-rule-process.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории звена процесса".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                         , ub.c-rule-process.pchain-type
                         , ub.c-rule-process.pchain-id
                         , ub.c-rule-process.start-from
                         , ub.c-rule-process.link-id
                         , ub.c-rule-process.corr-user-db-num
                         , ub.c-rule-process.chip-num
                                                  ) " }

{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#oxml = yes then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-rule-process}
        , input ( buffer ub.c-rule-process:handle )
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
