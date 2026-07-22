block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись свойств шаблона правил скидок и расписаний

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/29/07
Author: Bakhtadze Natalya
Creation date: 05/29/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.drt-prop old old_drt-prop.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись свойств шаблона правил скидок и расписаний".
{ cmp/vssrevis.i "substitute('&1|&2'
                         , ub.drt-prop.templ-rl-root
                         , ub.drt-prop.node-code
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-drt-prop for ub.c-drt-prop.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-drt-prop.
    buffer-copy old_drt-prop to buf_c-drt-prop
    assign
    buf_c-drt-prop.templ-rl-root      = ub.drt-prop.templ-rl-root
    buf_c-drt-prop.node-code          = ub.drt-prop.node-code
    buf_c-drt-prop.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-drt-prop.corr-time          = v-time
    buf_c-drt-prop.corr-user-db-num   = g#db-num
    buf_c-drt-prop.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else g#userid)
    buf_c-drt-prop.corr-date          = v-date
    buf_c-drt-prop.action = integer(if new(ub.drt-prop) then {&hn-create} else {&hn-update})
    .
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_drt-prop}
      ,input (buffer ub.drt-prop:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_drt-prop}
        , input ( buffer ub.drt-prop:handle )
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