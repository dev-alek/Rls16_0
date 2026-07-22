block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись sum-grp-obj

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.sum-grp-obj OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись sum-grp-obj".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                          , ub.sum-grp-obj.obj-type
                          , ub.sum-grp-obj.obj-code
                          , ub.sum-grp-obj.grp-code

                          ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-obj-db-num like ub.db.db-num no-undo .

define buffer buf_c-sum-grp-obj for ub.c-sum-grp-obj.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    { gbl/objdbnum.i ub.sum-grp-obj.obj-type ub.sum-grp-obj.obj-code v-obj-db-num }
    if v-obj-db-num <> g#db-num then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании sum-grp-obj" skip
      "Текущая БД - " g#db-num skip
      "Объект в sum-grp-obj " ub.sum-grp-obj.obj-type ub.sum-grp-obj.obj-code skip
      "Нельзя создавать/изменять sum-grp-obj в чужой БД"
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.


  run str/callnews.p
    (input {&table_sum-grp-obj}
    ,input (buffer ub.sum-grp-obj:handle)
    ).

  if not g#news then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-sum-grp-obj.
    buffer-copy oldb to buf_c-sum-grp-obj
    assign
    buf_c-sum-grp-obj.obj-type           = ub.sum-grp-obj.obj-type
    buf_c-sum-grp-obj.obj-code           = ub.sum-grp-obj.obj-code
    buf_c-sum-grp-obj.grp-code           = ub.sum-grp-obj.grp-code
    buf_c-sum-grp-obj.chip-num           = next-value (s-ref-obj-corr-chip, {&db-name_schema})
    buf_c-sum-grp-obj.corr-time          = v-time
    buf_c-sum-grp-obj.corr-user-db-num   = g#db-num
    buf_c-sum-grp-obj.corr-user-name     = g#userid
    buf_c-sum-grp-obj.corr-date          = v-today
    buf_c-sum-grp-obj.action             = integer(if new(ub.sum-grp-obj)
                                       then {&hn-create}
                                       else {&hn-update})
    buf_c-sum-grp-obj.subject            = {&table_sum-grp-obj}
    .
  end.


  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_sum-grp-obj}
        , input ( buffer ub.sum-grp-obj:handle )
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