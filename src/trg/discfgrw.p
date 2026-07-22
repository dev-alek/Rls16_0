block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись конфигурации скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/09/07
Author: Bakhtadze Natalya
Creation date: 01/09/07

*/


TRIGGER PROCEDURE FOR WRITE OF ub.dis-cfg-rule OLD old_dis-cfg-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись конфигурации скидок".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.dis-cfg-rule.table-name
                         , ub.dis-cfg-rule.pos-type
                         , ub.dis-cfg-rule.templ-rl-root
                         , ub.dis-cfg-rule.time-templ-rl-root
                         , ub.dis-cfg-rule.self-nonunique
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-dis-cfg-rule for ub.c-dis-cfg-rule.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-dis-cfg-rule.
    buffer-copy old_dis-cfg-rule to buf_c-dis-cfg-rule
    assign
    buf_c-dis-cfg-rule.table-name         = ub.dis-cfg-rule.table-name
    buf_c-dis-cfg-rule.pos-type           = ub.dis-cfg-rule.pos-type
    buf_c-dis-cfg-rule.templ-rl-root      = ub.dis-cfg-rule.templ-rl-root
    buf_c-dis-cfg-rule.time-templ-rl-root = ub.dis-cfg-rule.time-templ-rl-root
    buf_c-dis-cfg-rule.self-nonunique     = ub.dis-cfg-rule.self-nonunique
    buf_c-dis-cfg-rule.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-dis-cfg-rule.corr-time          = v-time
    buf_c-dis-cfg-rule.corr-user-db-num   = g#db-num
    buf_c-dis-cfg-rule.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else g#userid)
    buf_c-dis-cfg-rule.corr-date          = v-date
    buf_c-dis-cfg-rule.action = integer(if new(ub.dis-cfg-rule) then {&hn-create} else {&hn-update})
    .
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_dis-cfg-rule}
      ,input (buffer ub.dis-cfg-rule:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_dis-cfg-rule}
        , input ( buffer ub.dis-cfg-rule:handle )
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