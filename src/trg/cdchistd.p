block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 21/01/04
Author: Bakhtadze Natalya
Creation date: 21/01/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-dc-hist.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление главной записи истории ДК".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                        ,  ub.c-dc-hist.d-card
                        , ub.c-dc-hist.corr-user-db-num
                        , ub.c-dc-hist.chip-num
                        ) " }
{ cmp/trg-def.i }

main-block :
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  /*если card-num < 0 это удаление несипользованных карт two-commit*/
  if ub.c-dc-hist.card-num >= 0 then do:
    if lookup(ub.c-dc-hist.subject, {&dc-hist-subject}) > 0 then do:
      message
      vss-workfile vss-revision vss-description skip
      "Удаление главной записи ИСТОРИИ ДК возможно только для НЕИСПОЛЬЗОВАВШИХСЯ карт"
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_c-dc-hist}
        , input ( buffer ub.c-dc-hist:handle )
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