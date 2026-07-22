block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись профайла правил

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/07/07
Author: Bakhtadze Natalya
Creation date: 01/07/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.rule-profile OLD old_rule-profile.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись профайла правил".
{ cmp/vssrevis.i "substitute('&1'
                         , ub.rule-profile.profile_id
                                                  ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-rule-profile for ub.c-rule-profile.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-rule-profile.
    buffer-copy old_rule-profile to buf_c-rule-profile
    assign
    buf_c-rule-profile.profile_id         = ub.rule-profile.profile_id
    buf_c-rule-profile.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-rule-profile.corr-time          = v-time
    buf_c-rule-profile.corr-user-db-num   = g#db-num
    buf_c-rule-profile.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else g#userid)
    buf_c-rule-profile.corr-date          = v-date
    buf_c-rule-profile.action = integer(if new(ub.rule-profile) then {&hn-create} else {&hn-update})
    buf_c-rule-profile.subject = {&table_rule-profile}

    .
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_rule-profile}
      ,input (buffer ub.rule-profile:handle)
      ).
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_rule-profile}
        , input ( buffer ub.rule-profile:handle )
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