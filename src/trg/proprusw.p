block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись связки объекта и наборов правил

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/04/06
Author: Bakhtadze Natalya
Creation date: 10/04/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.prop-ruleset OLD old_prop-ruleset.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись связки объекта и наборов правил".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.prop-ruleset.codex_id
                         , ub.prop-ruleset.ruleset_id
                         , ub.prop-ruleset.dtm-code
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

DEFINE VARIABLE v-date as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-prop-head for ub.c-prop-head.
define buffer buf_c-prop-ruleset for ub.c-prop-ruleset.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-prop-ruleset.
    buffer-copy old_prop-ruleset to buf_c-prop-ruleset
    assign
    buf_c-prop-ruleset.dtm-code           = ub.prop-ruleset.dtm-code
    buf_c-prop-ruleset.codex_id           = ub.prop-ruleset.codex_id
    buf_c-prop-ruleset.ruleset_id         = ub.prop-ruleset.ruleset_id
    buf_c-prop-ruleset.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-prop-ruleset.corr-time          = v-time
    buf_c-prop-ruleset.corr-user-db-num   = g#db-num
    buf_c-prop-ruleset.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else g#userid)
    buf_c-prop-ruleset.corr-date          = v-date
    .
    create buf_c-prop-head.
    buffer-copy buf_c-prop-ruleset to
    buf_c-prop-head
    assign
    buf_c-prop-head.action             = integer(if new(ub.prop-ruleset) then {&hn-create} else {&hn-update})
    buf_C-prop-head.subject            = {&table_prop-ruleset}
    .
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_prop-ruleset}
      ,input (buffer ub.prop-ruleset:handle)
      ).
  end.


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_prop-ruleset}
        , input ( buffer ub.prop-ruleset:handle )
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