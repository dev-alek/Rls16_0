block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись статьи словаря МАШИНЫ ПРАВИЛ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/14/06
Author: Bakhtadze Natalya
Creation date: 09/14/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.ruledict old old-ruledict.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись статьи словаря МАШИНЫ ПРАВИЛ".
{ cmp/vssrevis.i "substitute('&1'
                         , ub.ruledict.entry-id
                         ) " }

{ cmp/trg-def.i }
{ gbl/key-rec.i }
{ gbl/cur-time.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-ruledict for ub.c-ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:
    if ub.ruledict.uniq-key-rec = '':u then do:
      run gen-key-rec in this-procedure ( input {&table_ruledict}
                                         ,input (buffer ub.ruledict:handle)
                                         ,output ub.ruledict.uniq-key-rec).
    end.
  end.

  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-ruledict.
    buffer-copy old-ruledict to buf_c-ruledict
    assign
    buf_c-ruledict.entry-id           = ub.ruledict.entry-id
    buf_c-ruledict.action             = integer(if new(ub.ruledict) then {&hn-create} else {&hn-update})
    buf_C-ruledict.subject            = {&table_ruledict}
    buf_c-ruledict.entry-id            = ub.ruledict.entry-id
    buf_c-ruledict.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-ruledict.corr-time          = v-time
    buf_c-ruledict.corr-user-db-num   = g#db-num
    buf_c-ruledict.corr-user-name     = (if g#news
                                          then {&nts-user}
                                          else g#userid)
    buf_c-ruledict.corr-date          = v-date
    .
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_ruledict}
      ,input (buffer ub.ruledict:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_ruledict}
        , input ( buffer ub.ruledict:handle )
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