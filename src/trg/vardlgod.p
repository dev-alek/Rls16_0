block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление в таблице ВАРИАНТЫ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/06/04
Author: Bakhtadze Natalya
Creation date: 04/06/04

*/

TRIGGER PROCEDURE FOR DELETE OF ub.varianty-delivery-gds-obj.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление в таблице ВАРИАНТЫ ДОСТАВКИ ДЛЯ ТОВАРА НА ОБЪЕКТЕ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                                       , ub.varianty-delivery-gds-obj.gds-code
                                       , ub.varianty-delivery-gds-obj.obj-type
                                       , ub.varianty-delivery-gds-obj.obj-code
                                       , ub.varianty-delivery-gds-obj.deliv-type-code
                                       , ub.varianty-delivery-gds-obj.deliv-subj-code
                                        ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

define variable v-host-code like ub.sysconf.host-code .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

define buffer buf_c-varianty-delivery-gds-obj for ub.c-varianty-delivery-gds-obj.
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
               buf_clients.obj-type = ub.varianty-delivery-gds-obj.obj-type
           AND buf_clients.obj-code = ub.varianty-delivery-gds-obj.obj-code.
    if buf_clients.db-num <> g#db-num then do:
      message
      "Нельзя удалять запись о ВАРИАНТЕ ДОСТАВКИ ТОВАРА ДЛЯ ТОВАРА НА ОБЪЕКТЕ для объекта другой БД" skip
      view-as alert-box .
      undo main-block, return error.
    end.
    end.
  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    {&table_varianty-delivery-gds-obj}
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
    create buf_c-varianty-delivery-gds-obj.
    buffer-copy ub.varianty-delivery-gds-obj to buf_c-varianty-delivery-gds-obj
    assign
    buf_c-varianty-delivery-gds-obj.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-varianty-delivery-gds-obj.corr-time          = v-time
    buf_c-varianty-delivery-gds-obj.corr-user-db-num   = g#db-num
    buf_c-varianty-delivery-gds-obj.corr-user-name     = g#userid
    buf_c-varianty-delivery-gds-obj.corr-date          = v-date
  /*  buf_c-varianty-delivery-gds-obj.is-del             = yes*/
    .
    { gbl/hostcode.i ub.varianty-delivery-gds-obj.obj-type ub.varianty-delivery-gds-obj.obj-code v-host-code }
    create buf_c-gds-hist.
    buffer-copy buf_c-varianty-delivery-gds-obj to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = integer({&hn-delete})
    buf_c-gds-hist.subject = {&table_varianty-delivery-gds-obj}
    buf_c-gds-hist.host-code = v-host-code
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
    .
  end.
  /* посылаем команду на удаление */
  if not g#news then do:
    run nws/cmd-del.p
      ( input {&table_varianty-delivery-gds-obj}
      ,input (buffer ub.varianty-delivery-gds-obj:handle)
      ,input "":U
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_varianty-delivery-gds-obj}
        , input ( buffer ub.varianty-delivery-gds-obj:handle )
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