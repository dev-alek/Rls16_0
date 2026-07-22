block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи свойств шаблона правил скидок и расписаний

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/29/07
Author: Bakhtadze Natalya
Creation date: 05/29/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.drt-prop.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи свойств шаблона правил скидок и расписаний".
{ cmp/vssrevis.i "substitute('&1|&2'
                         , ub.drt-prop.templ-rl-root
                         , ub.drt-prop.node-code
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

  if not g#news
  and g#db-num > 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять запись свойств ПРАВИЛ СКИДОК И РАСПИСАНИЙ в УБД"
    view-as alert-box error .
    undo main-block, return error .
  end.
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
      if substring(v-p, length(v-p) - length("disrul0.p") + 1) = "disrul0.p":U
      or substring(v-p, length(v-p) - length("disrul0.p") + 1) = "disrul0.r":U
      or substring(v-p, length(v-p) - length("distrul0.p") + 1) = "distrul0.p":U
      or substring(v-p, length(v-p) - length("distrul0.p") + 1) = "distrul0.r":U
      or substring(v-p, length(v-p) - length("fixdr.p") + 1) = "fixdr.p":U
      or substring(v-p, length(v-p) - length("fixdr.p") + 1) = "fixdr.r":U
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
        "Физическое удаление записи конфигурации скидок в системе запрещено" skip
        view-as alert-box error .
      undo main-block, return error.
    end.
  end.

  run nws/cmd-del.p
    ( input {&table_drt-prop}
     ,input (buffer ub.drt-prop:handle)
     ,input '':U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_drt-prop}
        , input ( buffer ub.drt-prop:handle )
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