block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись товара на кассе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/18/07
Author: Bakhtadze Natalya
Creation date: 01/18/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.cd-plu OLD old_cd-plu .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись товара на кассе".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                                    ,ub.cd-plu.obj-type
                                    ,ub.cd-plu.obj-code
                                    ,ub.cd-plu.pos-type
                                    ,ub.cd-plu.plu-type
                                    ,ub.cd-plu.plu-code
                                          ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-db-num as integer no-undo .
define variable v-changes as character no-undo .

define buffer buf_c-cash-desk for ub.c-cash-desk.
define buffer buf_c-cd-plu for ub.c-cd-plu.
define buffer buf_cash-desk for ub.cash-desk.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    { gbl/objdbnum.i ub.cd-plu.obj-type ub.cd-plu.obj-code v-db-num }
    if v-db-num <> g#db-num then do:
      message
      "Нельзя изменять запись об клиенте на кассе," skip
      "принадлежащей другой БД"
      view-as alert-box .
      undo, return error.
    end.
  end.
  buffer-compare old_cd-plu to ub.cd-plu
  case-sensitive
  save result in v-changes.
  if trim(replace(replace(v-changes, 'to-del', ''), 'to-send', '':U), {&comma-char}) = '':U then return.
  if ub.cd-plu.gds-code > 0 then do :
    run str/callnews.p (  input {&table_cd-plu}
                        ,input (buffer ub.cd-plu:handle)
                      ) no-error .
    if error-status:error then undo, return error return-value  .
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-cd-plu.
    assign
    buf_c-cd-plu.obj-type           = ub.cd-plu.obj-type
    buf_c-cd-plu.obj-code           = ub.cd-plu.obj-code
    buf_c-cd-plu.pos-type           = ub.cd-plu.pos-type
    buf_c-cd-plu.plu-type           = ub.cd-plu.plu-type
    buf_c-cd-plu.plu-code           = ub.cd-plu.plu-code
    buf_c-cd-plu.chip-num           = next-value (s-cash-desk-chip, {&db-name_schema})
    buf_c-cd-plu.corr-time          = v-time
    buf_c-cd-plu.corr-user-db-num   = g#db-num
    buf_c-cd-plu.corr-user-name     = g#userid
    buf_c-cd-plu.corr-date          = v-date
    .
    /*create buf_c-cash-desk.
    buffer-copy buf_c-cd-plu
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
    buf_c-cash-desk.action               = integer(if new(ub.cd-plu)
                                                  then  {&hn-create}
                                                  else {&hn-update})
    buf_c-cash-desk.subject               = {&table_cd-plu}
    buf_c-cash-desk.cash-num              = 0
    .*/

  end.
  if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_cd-plu}
        , input ( buffer ub.cd-plu:handle )
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