block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись свода правил

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/16/06
Author: Bakhtadze Natalya
Creation date: 08/16/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.ruleset OLD old_ruleset.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись свода правил".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.ruleset.codex_id
                         , ub.ruleset.ruleset_id
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-ruleset for ub.c-ruleset.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-ruleset.
    buffer-copy old_ruleset to buf_c-ruleset
    assign
    buf_c-ruleset.ruleset_id         = ub.ruleset.ruleset_id
    buf_c-ruleset.codex_id           = ub.ruleset.codex_id
    buf_c-ruleset.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-ruleset.corr-time          = v-time
    buf_c-ruleset.corr-user-db-num   = g#db-num
    buf_c-ruleset.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else g#userid)
    buf_c-ruleset.corr-date          = v-date
    .
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_ruleset}
      ,input (buffer ub.ruleset:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_ruleset}
        , input ( buffer ub.ruleset:handle )
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
end. /*doe*/