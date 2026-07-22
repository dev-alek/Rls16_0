block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История атрибута товара на складском месте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

define parameter buffer oldb for ub.pl-gds-attr.
define parameter buffer newb for ub.pl-gds-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История атрибута товара на складском месте".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , newb.obj-type
                         , newb.obj-code
                         , newb.pl-code
                         , newb.gds-code
                         , newb.attr-code
                         ) " }


{ cmp/trg-def.i  }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer buf_c-pl-gds-attr for ub.c-pl-gds-attr.
define buffer buf_c-plc-hist for ub.c-plc-hist.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-table-bind for ub.c-table-bind.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if g#news <> yes then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-pl-gds-attr.
    buffer-copy oldb except
    pl-code
    obj-type
    obj-code
    attr-code
    gds-code
    to buf_c-pl-gds-attr
    .
    assign
    buf_c-pl-gds-attr.obj-type           = newb.obj-type
    buf_c-pl-gds-attr.obj-code           = newb.obj-code
    buf_c-pl-gds-attr.pl-code            = newb.pl-code
    buf_c-pl-gds-attr.attr-code          = newb.attr-code
    buf_c-pl-gds-attr.gds-code           = newb.gds-code
    buf_c-pl-gds-attr.chip-num           = next-value (s-plc-chip, {&db-name_schema})
    buf_c-pl-gds-attr.corr-time          = v-time
    buf_c-pl-gds-attr.corr-user-db-num   = g#db-num
    buf_c-pl-gds-attr.corr-user-name     = g#userid
    buf_c-pl-gds-attr.corr-date          = v-today
    .
    create buf_c-plc-hist.
    buffer-copy buf_c-pl-gds-attr to buf_c-plc-hist
    assign
    buf_c-plc-hist.action             = integer( if new( newb )
                                              then {&hn-create}
                                              else {&hn-update})
    buf_c-plc-hist.subject = {&table_pl-gds-attr}
    buf_c-plc-hist.is-news = g#news
    .
    { gbl/hostcode.i newb.obj-type newb.obj-code v-host-code }

    create buf_c-gds-hist.
    buffer-copy buf_c-pl-gds-attr
    except chip-num
    to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = (if new newb then integer({&hn-create}) else integer({&hn-update}))
    buf_c-gds-hist.subject = {&table_pl-gds-attr}
    buf_c-gds-hist.host-code = v-host-code
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.chip-num =   next-value (s-gds-chip, {&db-name_schema})
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
end. /* Main-Block */