block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление nozzle

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/15/07
Author: Dmitry Ukhanov
Creation date: 08/15/07


*/

TRIGGER PROCEDURE FOR DELETE OF ub.nozzle.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление nozzle".

{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.nozzle.obj-type
                         , ub.nozzle.obj-code
                         , ub.nozzle.nozzle-code
                         ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-today as date no-undo .
define variable v-time as integer no-undo .

define buffer buf_c-nozzle for ub.c-nozzle.
define buffer buf_c-nzl-hist for ub.c-nzl-hist.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    run nws/cmd-del.p
      ( input {&table_nozzle}
       ,input ( buffer ub.nozzle :handle )
       ,input "":U
      ).

    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-nozzle.
    buffer-copy ub.nozzle to buf_c-nozzle.
    assign
    buf_c-nozzle.chip-num           = next-value (s-nzl-chip, {&db-name_schema})
    buf_c-nozzle.corr-time          = v-time
    buf_c-nozzle.corr-user-db-num   = g#db-num
    buf_c-nozzle.corr-user-name     = g#userid
    buf_c-nozzle.corr-date          = v-today
    .
    create buf_c-nzl-hist.
    buffer-copy buf_c-nozzle to buf_c-nzl-hist
    assign
    buf_c-nzl-hist.action =  integer({&hn-delete})
    buf_c-nzl-hist.subject = {&table_nozzle}
    buf_c-nzl-hist.is-news = g#news
    .
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p
      ( input {&nwsdochs_action_delete}
       ,input {&table_nozzle}
       ,input ( buffer ub.nozzle:handle )
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
end. /* transaction */