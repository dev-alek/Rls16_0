block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление конфигурации скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/07/07
Author: Bakhtadze Natalya
Creation date: 01/07/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.dis-cfg-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление профайла правил".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.dis-cfg-rule.table-name
                         , ub.dis-cfg-rule.pos-type
                         , ub.dis-cfg-rule.templ-rl-root
                         , ub.dis-cfg-rule.time-templ-rl-root
                         , ub.dis-cfg-rule.self-nonunique
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
DEFINE VARIABLE v-date as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-dis-cfg-rule for ub.c-dis-cfg-rule.

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
      if index(v-p, "discfgr3.") > 0
      or index(v-p, "fixdr.") > 0
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
    ( input {&table_dis-cfg-rule}
    ,input (buffer ub.dis-cfg-rule:handle)
    ,input '':U
    ) no-error .
  if error-status :error then do:
    undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

  run cur-time in this-procedure ( output v-date, output v-time).
  create buf_c-dis-cfg-rule.
  buffer-copy ub.dis-cfg-rule to buf_c-dis-cfg-rule
  assign
  buf_c-dis-cfg-rule.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
  buf_c-dis-cfg-rule.corr-time          = v-time
  buf_c-dis-cfg-rule.corr-user-db-num   = g#db-num
  buf_c-dis-cfg-rule.corr-user-name     = (if g#news
                                  then {&nts-user}
                                  else g#userid)
  buf_c-dis-cfg-rule.corr-date          = v-date
  buf_c-dis-cfg-rule.action = integer({&hn-delete})
  .

end.