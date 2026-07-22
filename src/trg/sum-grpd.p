block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление групп товара на кассах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.sum-grp.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление sum-grp".
{ cmp/vssrevis.i "substitute('&1', ub.sum-grp.grp-code) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define buffer buf_c-sum-grp for ub.c-sum-grp.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not g#news
  and ( g#db-num > 0 ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при удалении sum-grp" skip
    "Текущая БД - " g#db-num skip
    "Нельзя удалять sum-grp в УБД"
    view-as alert-box error .
    undo main-block, return error .
  end.
  for each buf_dis-grp-rule where
          buf_dis-grp-rule.classif-type = {&table_sum-grp}
      and buf_dis-grp-rule.node-code = ub.sum-grp.grp-code
      and buf_dis-grp-rule.host-code = 0
      and buf_dis-grp-rule.obj-type = '':U
      and buf_dis-grp-rule.obj-code = 0
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    delete buf_dis-grp-rule.
  end.
  if not g#news then do:
    run nws/cmd-del.p
      ( input {&table_sum-grp}
      ,input (buffer ub.sum-grp:handle)
      ,input "":U
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-sum-grp.
    buffer-copy ub.sum-grp to buf_c-sum-grp
    assign
    buf_c-sum-grp.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-sum-grp.corr-time          = v-time
    buf_c-sum-grp.corr-user-db-num   = g#db-num
    buf_c-sum-grp.corr-user-name     = g#userid
    buf_c-sum-grp.corr-date          = v-today
    buf_c-sum-grp.action             = integer({&hn-delete})
    buf_c-sum-grp.subject           = {&table_sum-grp}
    .
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_sum-grp}
        , input ( buffer ub.sum-grp:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.