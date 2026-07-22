block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись параметра словаря правил

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/14/06
Author: Bakhtadze Natalya
Creation date: 09/14/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.ruledict-param OLD old-ruledict-param.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись параметра словаря правил".
{ cmp/vssrevis.i "substitute('&1|&2'
                         , ub.ruledict-param.entry-id
                         , ub.ruledict-param.param-name
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-ruledict for ub.c-ruledict.
define buffer buf_c-ruledict-param for ub.c-ruledict-param.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-ruledict-param.
    buffer-copy old-ruledict-param to buf_c-ruledict-param
    assign
    buf_c-ruledict-param.entry-id            = ub.ruledict-param.entry-id
    buf_c-ruledict-param.param-name         = ub.ruledict-param.param-name
    buf_c-ruledict-param.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-ruledict-param.corr-time          = v-time
    buf_c-ruledict-param.corr-user-db-num   = g#db-num
    buf_c-ruledict-param.corr-user-name     = (if g#news
                                          then {&nts-user}
                                          else g#userid)
    buf_c-ruledict-param.corr-date          = v-date
    .
    create buf_c-ruledict.
    buffer-copy buf_c-ruledict-param
    to buf_c-ruledict
    assign
    buf_c-ruledict.action             = integer(if new(ub.ruledict-param) then {&hn-create} else {&hn-update})
    buf_C-ruledict.subject            = {&table_ruledict-param}
    .
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_ruledict-param}
      ,input (buffer ub.ruledict-param:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_ruledict-param}
        , input ( buffer ub.ruledict-param:handle )
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