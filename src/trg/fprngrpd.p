block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление fbr-prn-grp

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/21/03
Author: Bakhtadze Natalya
Creation date: 08/21/03

*/

TRIGGER PROCEDURE FOR DELETE OF ub.fbr-prn-grp.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление fbr-prn-grp".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         ,ub.fbr-prn-grp.db-num
                         ,ub.fbr-prn-grp.prn-num
                         ,ub.fbr-prn-grp.obj-type
                         ,ub.fbr-prn-grp.obj-code
                         ,ub.fbr-prn-grp.node-code
                         )"}

{ cmp/trg-def.i  }

{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-fbr-prn for ub.c-fbr-prn.
define buffer buf_c-fbr-prn-grp for ub.c-fbr-prn-grp.


define buffer buf_clients for ub.clients.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    find first buf_clients no-lock where
               buf_clients.obj-type = ub.fbr-prn-grp.obj-type
           AND buf_clients.obj-code = ub.fbr-prn-grp.obj-code.
    if buf_clients.db-num <> g#db-num then do:
      message
      "Нельзя удалять запись о группе товаров на принтере," skip
      "принадлежащем другой БД"
      view-as alert-box .
      undo main-block, return error.
    end.
  end.
  /* посылаем команду на удаление свзяки групп-принтер кухни */
  if not g#news then do:
    run nws/cmd-del.p
      ( input {&table_fbr-prn-grp}
      ,input (buffer ub.fbr-prn-grp:handle)
      ,input "":U
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fbr-prn-grp.
    buffer-copy ub.fbr-prn-grp
    to
    buf_c-fbr-prn-grp
    assign
    buf_c-fbr-prn-grp.corr-user-db-num   = g#db-num
    buf_c-fbr-prn-grp.chip-num           = next-value (s-scales-chip, {&db-name_schema})
    .
    create buf_c-fbr-prn.
    buffer-copy
    buf_c-fbr-prn-grp
    to buf_c-fbr-prn
    assign
    buf_c-fbr-prn.corr-time          = v-time
    buf_c-fbr-prn.corr-user-name     = g#userid
    buf_c-fbr-prn.corr-date          = v-date
    buf_c-fbr-prn.subject            = {&table_fbr-prn-grp}
    buf_c-fbr-prn.action             = integer({&hn-delete})
    .
  end.


  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_fbr-prn-grp}
        , input ( buffer ub.fbr-prn-grp:handle )
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