block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История атрибута ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

define parameter buffer oldb for ub.pump-attr.
define parameter buffer newb for ub.pump-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История атрибута ТРК".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , newb.obj-type
                         , newb.obj-code
                         , newb.pump-code
                         , newb.attr-code
                         ) " }


{ cmp/trg-def.i  }
{ gbl/cur-time.i }
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-pump-attr for ub.c-pump-attr.
define buffer buf_c-pmp-hist for ub.c-pmp-hist.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if g#news <> yes then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-pump-attr.
    buffer-copy oldb except
    pump-code
    obj-type
    obj-code
    attr-code
    to buf_c-pump-attr
    .
    assign
    buf_c-pump-attr.obj-type           = newb.obj-type
    buf_c-pump-attr.obj-code           = newb.obj-code
    buf_c-pump-attr.pump-code            = newb.pump-code
    buf_c-pump-attr.attr-code          = newb.attr-code
    buf_c-pump-attr.chip-num           = next-value (s-pmp-chip, {&db-name_schema})
    buf_c-pump-attr.corr-time          = v-time
    buf_c-pump-attr.corr-user-db-num   = g#db-num
    buf_c-pump-attr.corr-user-name     = g#userid
    buf_c-pump-attr.corr-date          = v-today
    .
    create buf_c-pmp-hist.
    buffer-copy buf_c-pump-attr to buf_c-pmp-hist
    assign
    buf_c-pmp-hist.action             = integer( if new( newb )
                                              then {&hn-create}
                                              else {&hn-update})
    buf_c-pmp-hist.subject = {&table_pump-attr}
    buf_c-pmp-hist.is-news = g#news
    buf_c-pmp-hist.gds-code = ?
    .
  end.
end. /* Main-Block */