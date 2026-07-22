block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление связки СКРИПТА ДЛЯ ОБЪЕКТА-НАБОР ПРАВИЛ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/11/06
Author: Bakhtadze Natalya
Creation date: 10/11/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.pscript-ruleset.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление связки СКРИПТА ДЛЯ ОБЪЕКТА-НАБОР ПРАВИЛ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                         , ub.pscript-ruleset.codex_id
                         , ub.pscript-ruleset.ruleset_id
                         , ub.pscript-ruleset.dtm-code
                         , ub.pscript-ruleset.language
                         , ub.pscript-ruleset.script-name
                         , ub.pscript-ruleset.revis_id
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

DEFINE VARIABLE v-date as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-prop-head for ub.c-prop-head.
define buffer buf_c-pscript-ruleset for ub.c-pscript-ruleset.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-pscript-ruleset.
    buffer-copy ub.pscript-ruleset to buf_c-pscript-ruleset
    assign
    buf_c-pscript-ruleset.dtm-code           = ub.pscript-ruleset.dtm-code
    buf_c-pscript-ruleset.codex_id           = ub.pscript-ruleset.codex_id
    buf_c-pscript-ruleset.ruleset_id         = ub.pscript-ruleset.ruleset_id
    buf_c-pscript-ruleset.revis_id           = ub.pscript-ruleset.revis_id
    buf_c-pscript-ruleset.script-name        = ub.pscript-ruleset.script-name
    buf_c-pscript-ruleset.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-pscript-ruleset.corr-time          = v-time
    buf_c-pscript-ruleset.corr-user-db-num   = g#db-num
    buf_c-pscript-ruleset.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else g#userid)
    buf_c-pscript-ruleset.corr-date          = v-date
    .
    if ub.pscript-ruleset.dtm-code > 0 then do:
      create buf_c-prop-head.
      buffer-copy buf_c-pscript-ruleset to
      buf_c-prop-head
      assign
      buf_c-prop-head.action             = integer({&hn-delete})
      buf_C-prop-head.subject            = {&table_pscript-ruleset}
      .
    end.
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run nws/cmd-del.p
      ( input {&table_pscript-ruleset}
       ,input (buffer ub.pscript-ruleset:handle)
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
        , input {&table_pscript-ruleset}
        , input ( buffer ub.pscript-ruleset:handle )
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