block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление атрибута пистолета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.nozzle-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление атрибута пистолета".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.nozzle-attr.obj-type
                         , ub.nozzle-attr.obj-code
                         , ub.nozzle-attr.nozzle-code
                         , ub.nozzle-attr.attr-code
                         ) " }


{ cmp/trg-def.i  }
{ gbl/cur-time.i }


DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-nozzle-attr for ub.c-nozzle-attr.
define buffer buf_c-nzl-hist for ub.c-nzl-hist.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run nws/cmd-del.p ( input {&table_nozzle-attr}
                    , input ( buffer ub.nozzle-attr :handle )
                    , input "":U ).
  if not g#news then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-nozzle-attr.
    buffer-copy ub.nozzle-attr to buf_c-nozzle-attr.
    assign
    buf_c-nozzle-attr.chip-num           = next-value (s-nzl-chip, {&db-name_schema})
    buf_c-nozzle-attr.corr-time          = v-time
    buf_c-nozzle-attr.corr-user-db-num   = g#db-num
    buf_c-nozzle-attr.corr-user-name     = g#userid
    buf_c-nozzle-attr.corr-date          = v-today
    .
    create buf_c-nzl-hist.
    buffer-copy buf_c-nozzle-attr to buf_c-nzl-hist
    assign
    buf_c-nzl-hist.action =  integer({&hn-delete})
    buf_c-nzl-hist.subject = {&table_nozzle-attr}
    buf_c-nzl-hist.is-news = g#news
    .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_nozzle-attr}
        , input ( buffer ub.nozzle-attr:handle )
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
end. /* Main-Block */