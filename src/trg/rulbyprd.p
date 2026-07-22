block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление связки ПРАВИЛО-ПРОФАЙЛ ПРАВИЛ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/07/07
Author: Bakhtadze Natalya
Creation date: 01/07/07

*/


TRIGGER PROCEDURE FOR DELETE OF ub.rule-by-profile.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление связки ПРАВИЛО-ПРОФАЙЛ ПРАВИЛ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.rule-by-profile.profile_id
                         , ub.rule-by-profile.codex_id
                         , ub.rule-by-profile.ruleset_id
                         , ub.rule-by-profile.rp_order_id
                         , ub.rule-by-profile.rule_id
                         ) " }

{ cmp/trg-def.i }

define variable v-start-level as integer no-undo .
define variable level as integer no-undo .
define variable v-p as character no-undo .
define variable v-confirmed as logical no-undo .


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:
    /*проверим от куда вызвали*/
    assign
    v-start-level = 2
    .
    assign
      level = v-start-level
    .
    _repeat:
    repeat while program-name( level ) <> ? :
      v-p = program-name( level ).
      if index(v-p, "rule-by-profile3.") > 0
      or index(v-p, "rule4.") > 0
      or index(v-p, "fixrum.") > 0
      then do:
        v-confirmed = yes.
        leave _repeat.
      end.
      assign
        level = level + 1
      .
    end.
    if not v-confirmed then do:
      message
        vss-workfile vss-revision vss-description skip
        "Физическое удаление связки ПРАВИЛО-ПРОФАЙЛ ПРАВИЛ в системе запрещено" skip
        view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run nws/cmd-del.p
      ( input {&table_rule-by-profile}
      ,input (buffer ub.rule-by-profile:handle)
      ,input "":U
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_rule-by-profile}
        , input ( buffer ub.rule-by-profile:handle )
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