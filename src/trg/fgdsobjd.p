block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление fbr-gds-obj

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/21/03
Author: Bakhtadze Natalya
Creation date: 08/21/03

*/

TRIGGER PROCEDURE FOR DELETE OF ub.fbr-gds-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление fbr-gds-obj".
{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.fbr-gds-obj.obj-type,ub.fbr-gds-obj.obj-code,ub.fbr-gds-obj.gds-code)" }
{ cmp/trg-def.i  }

{ gbl/cur-time.i }
{ nws/lib-nws.i }

define variable v-host-code like ub.sysconf.host-code .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-db-list as character no-undo .
define variable v-obj-db-num like ub.db.db-num no-undo .

define buffer buf_c-fbr-gds-obj for ub.c-fbr-gds-obj.
define buffer buf_c-gds-hist for ub.c-gds-hist.


define buffer buf_clients for ub.clients.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not g#news then do:
    find first buf_clients no-lock where
               buf_clients.obj-type = ub.fbr-gds-obj.obj-type
           AND buf_clients.obj-code = ub.fbr-gds-obj.obj-code.
    if buf_clients.db-num <> g#db-num then do:
      message
      "Нельзя удалять запись о атрибуте товара (РЕСТОРАН) на объекте," skip
      "принадлежащем другой БД"
      view-as alert-box .
      undo main-block, return error.
    end.
  end.
  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    {&table_fbr-gds-obj}
    0
    '':U
    0
    '':U
    '':U
    '':U
    0
    0
    0
    {&nws-to-hist}
    v-send
    no-error
    }
  end.
  if not g#news
  or v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fbr-gds-obj.
    buffer-copy ub.fbr-gds-obj to buf_c-fbr-gds-obj
    assign
    buf_c-fbr-gds-obj.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-fbr-gds-obj.corr-time          = v-time
    buf_c-fbr-gds-obj.corr-user-db-num   = g#db-num
    buf_c-fbr-gds-obj.corr-user-name     = g#userid
    buf_c-fbr-gds-obj.corr-date          = v-date
    buf_c-fbr-gds-obj.is-del             = yes
    .
    { gbl/hostcode.i ub.fbr-gds-obj.obj-type ub.fbr-gds-obj.obj-code v-host-code }
    create buf_c-gds-hist.
    buffer-copy buf_c-fbr-gds-obj to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = integer({&hn-delete})
    buf_c-gds-hist.subject = {&table_fbr-gds-obj}
    buf_c-gds-hist.host-code = v-host-code
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
    .
  end.
  if g#db-num <> 0 and not g#news then do:
    { gbl/objdbnum.i  ub.fbr-gds-obj.obj-type ub.fbr-gds-obj.obj-code v-obj-db-num }
    assign
    v-db-list = string(v-obj-db-num)
    .
  end.
  else do:
    assign
    v-db-list = string(0)
    .
  end.
  /* посылаем команду на удаление атрибута товара-общепит */
  run nws/cmd-del.p
    ( input {&table_fbr-gds-obj}
     ,input (buffer ub.fbr-gds-obj:handle)
     ,input v-db-list
    ) no-error .
  if error-status :error then do:
    undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_fbr-gds-obj}
        , input ( buffer ub.fbr-gds-obj:handle )
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