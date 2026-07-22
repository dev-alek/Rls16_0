block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление товара на кассе

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/18/07
Author: Bakhtadze Natalya
Creation date: 01/18/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.cd-plu  .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление товара на кассе".
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

define buffer buf_c-cash-desk for ub.c-cash-desk.
define buffer buf_c-cd-plu for ub.c-cd-plu.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not g#news then do:
    { gbl/objdbnum.i ub.cd-plu.obj-type ub.cd-plu.obj-code v-db-num }
    if v-db-num <> g#db-num then do:
      message
      "Нельзя удалять запись товара на кассе," skip
      "принадлежащий другой БД"
      view-as alert-box .
      undo main-block, return error.
    end.
  end.

  /* посылаем команду на удаление товара на кассе */
  if not g#news then do:
    run nws/cmd-del.p
      ( input {&table_cd-plu}
      ,input (buffer ub.cd-plu:handle)
      ,input "":U
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-cd-plu.
    buffer-copy ub.cd-plu to buf_c-cd-plu
    assign
    buf_c-cd-plu.chip-num           = next-value (s-cash-desk-chip, {&db-name_schema})
    buf_c-cd-plu.corr-time          = v-time
    buf_c-cd-plu.corr-user-db-num   = g#db-num
    buf_c-cd-plu.corr-user-name     = g#userid
    buf_c-cd-plu.corr-date          = v-date
    buf_c-cd-plu.is-del             = yes
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
    to  buf_c-cash-desk
    assign
    buf_c-cash-desk.db-num               = g#db-num
    buf_c-cash-desk.action               = integer({&hn-delete})
    buf_c-cash-desk.subject              = {&table_cd-plu}
    buf_c-cash-desk.cash-num              = 0
    .*/
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_cd-plu}
        , input ( buffer ub.cd-plu:handle )
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