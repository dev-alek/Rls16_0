block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление свода правил

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/16/06
Author: Bakhtadze Natalya
Creation date: 08/16/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.ruleset.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление свода правил".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.ruleset.codex_id
                         , ub.ruleset.ruleset_id
                         ) " }

{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:



  if not (g#db-num = 0
          or g#news) then do:
    message
      vss-workfile vss-revision vss-description skip
      "Физическое удаление свода или кодекса правила в системе запрещено" skip
      view-as alert-box error .
    undo main-block, return error.
  end.

  run nws/cmd-del.p
    ( input {&table_ruleset}
     ,input (buffer ub.ruleset:handle)
     ,input '':U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_ruleset}
        , input ( buffer ub.ruleset:handle )
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