block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление атрибута товара на складском месте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.pl-gds-attr.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление атрибута товара на складском месте".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.pl-gds-attr.obj-type
                         , ub.pl-gds-attr.obj-code
                         , ub.pl-gds-attr.pl-code
                         , ub.pl-gds-attr.gds-code
                         , ub.pl-gds-attr.attr-code
                         ) " }


{ cmp/trg-def.i  }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_place   for ub.place.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-pl-gds-attr  for ub.c-pl-gds-attr.
define buffer buf_c-plc-hist  for ub.c-plc-hist.
define buffer buf_c-table-bind for ub.c-table-bind.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    run nws/cmd-del.p (
                        input {&table_pl-gds-attr}
                      , input ( buffer ub.pl-gds-attr :handle )
                      , input "":U ).
  end.
  if not g#news then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-pl-gds-attr.
    buffer-copy ub.pl-gds-attr to buf_c-pl-gds-attr.
    assign
    buf_c-pl-gds-attr.chip-num           = next-value (s-plc-chip, {&db-name_schema})
    buf_c-pl-gds-attr.corr-time          = v-time
    buf_c-pl-gds-attr.corr-user-db-num   = g#db-num
    buf_c-pl-gds-attr.corr-user-name     = g#userid
    buf_c-pl-gds-attr.corr-date          = v-today
    .
    create buf_c-plc-hist.
    buffer-copy buf_c-pl-gds-attr to buf_c-plc-hist
    assign
    buf_c-plc-hist.action =  integer({&hn-delete})
    buf_c-plc-hist.subject = {&table_pl-gds-attr}
    buf_c-plc-hist.is-news = g#news
    .
    /*создаем куст для c-gds-hist*/
    { gbl/hostcode.i ub.pl-gds-attr.obj-type ub.pl-gds-attr.obj-code v-host-code }

    create buf_c-gds-hist.
    buffer-copy buf_c-pl-gds-attr
    except chip-num
    to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = integer({&hn-delete})
    buf_c-gds-hist.subject = {&table_pl-gds-attr}
    buf_c-gds-hist.host-code = v-host-code
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.chip-num = next-value (s-gds-chip, {&db-name_schema})
    buf_c-gds-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
    .
    create buf_c-table-bind.
    assign
    buf_c-table-bind.chip-num-rec   = buf_c-gds-hist.chip-num
    buf_c-table-bind.chip-num-src   = buf_c-pl-gds-attr.chip-num
    buf_c-table-bind.corr-user-db-num     = buf_c-pl-gds-attr.corr-user-db-num
    buf_c-table-bind.tbl-name-rec   = {&table_c-gds-hist}
    buf_c-table-bind.tbl-name-src   = {&table_c-plc-hist}
    buf_c-table-bind.is-news         = g#news
    buf_c-table-bind.corr-user-name  = g#userid
    buf_c-table-bind.subject         = {&table_pl-gds-attr}
    .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_pl-gds-attr}
        , input ( buffer ub.pl-gds-attr:handle )
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