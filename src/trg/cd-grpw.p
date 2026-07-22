block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись группы на кассе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/18/07
Author: Bakhtadze Natalya
Creation date: 01/18/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.cd-grp OLD old_cd-grp .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись группы на кассе".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                                    ,ub.cd-grp.obj-type
                                    ,ub.cd-grp.obj-code
                                    ,ub.cd-grp.pos-type
                                    ,ub.cd-grp.grp-type
                                    ,ub.cd-grp.grp-code
                                          ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-db-num as integer no-undo .
define variable v-changes as character no-undo .

define buffer buf_c-cash-desk for ub.c-cash-desk.
define buffer buf_c-cd-grp for ub.c-cd-grp.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    { gbl/objdbnum.i ub.cd-grp.obj-type ub.cd-grp.obj-code v-db-num }
    if v-db-num <> g#db-num then do:
      message
      "Нельзя изменять запись об клиенте на кассе," skip
      "принадлежащей другой БД"
      view-as alert-box .
      undo, return error.
    end.
  end.
  buffer-compare old_cd-grp to ub.cd-grp
  case-sensitive
  save result in v-changes.
  if trim(replace(replace(v-changes, 'to-del', ''), 'to-send', '':U), {&comma-char}) = '':U then return.
  run str/callnews.p (  input {&table_cd-grp}
                      ,input (buffer ub.cd-grp:handle)
                    ) no-error .
  if error-status:error then undo, return error return-value  .


  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-cd-grp.
    assign
    buf_c-cd-grp.obj-type           = ub.cd-grp.obj-type
    buf_c-cd-grp.obj-code           = ub.cd-grp.obj-code
    buf_c-cd-grp.pos-type           = ub.cd-grp.pos-type
    buf_c-cd-grp.grp-type           = ub.cd-grp.grp-type
    buf_c-cd-grp.grp-code           = ub.cd-grp.grp-code
    buf_c-cd-grp.chip-num           = next-value (s-cash-desk-chip, {&db-name_schema})
    buf_c-cd-grp.corr-time          = v-time
    buf_c-cd-grp.corr-user-db-num   = g#db-num
    buf_c-cd-grp.corr-user-name     = g#userid
    buf_c-cd-grp.corr-date          = v-date
    .
    /*create buf_c-cash-desk.
    buffer-copy buf_c-cd-grp
    using
    obj-code
    pos-type
    corr-user-db-num
    corr-time
    corr-user-name
    corr-date
    chip-num
    to  buf_c-cash-desk
    assign
    buf_c-cash-desk.db-num               = g#db-num
    buf_c-cash-desk.action               = integer(if new(ub.cd-grp)
                                                  then  {&hn-create}
                                                  else {&hn-update})
    buf_c-cash-desk.subject               = {&table_cd-grp}
    buf_c-cash-desk.cash-num              = 0
    .*/

  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_cd-grp}
        , input ( buffer ub.cd-grp:handle )
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