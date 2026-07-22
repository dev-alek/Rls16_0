block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись связки ПРАВИЛО-ПРОФАЙЛ ПРАВИЛ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/07/07
Author: Bakhtadze Natalya
Creation date: 01/07/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.rule-by-profile OLD old_rule-by-profile.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись связки ПРАВИЛО-ПРОФАЙЛ ПРАВИЛ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.rule-by-profile.profile_id
                         , ub.rule-by-profile.codex_id
                         , ub.rule-by-profile.ruleset_id
                         , ub.rule-by-profile.rp_order_id
                         , ub.rule-by-profile.rule_id
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-rule-profile for ub.c-rule-profile.
define buffer buf_c-rule-by-profile for ub.c-rule-by-profile.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-rule-by-profile.
    buffer-copy old_rule-by-profile to buf_c-rule-by-profile
    assign
    buf_c-rule-by-profile.profile_id         = ub.rule-by-profile.profile_id
    buf_c-rule-by-profile.codex_id           = ub.rule-by-profile.codex_id
    buf_c-rule-by-profile.ruleset_id         = ub.rule-by-profile.ruleset_id
    buf_c-rule-by-profile.rp_order_id        = ub.rule-by-profile.rp_order_id
    buf_c-rule-by-profile.rule_id            = ub.rule-by-profile.rule_id
    buf_c-rule-by-profile.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-rule-by-profile.corr-time          = v-time
    buf_c-rule-by-profile.corr-user-db-num   = g#db-num
    buf_c-rule-by-profile.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else g#userid)
    buf_c-rule-by-profile.corr-date          = v-date
    .
    create buf_c-rule-profile.
    buffer-copy buf_c-rule-by-profile to buf_c-rule-profile
    assign
    buf_c-rule-profile.action = integer(if new(ub.rule-by-profile) then {&hn-create} else {&hn-update})
    buf_c-rule-profile.subject = {&table_rule-by-profile}
    .
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_rule-by-profile}
      ,input (buffer ub.rule-by-profile:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_rule-by-profile}
        , input ( buffer ub.rule-by-profile:handle )
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