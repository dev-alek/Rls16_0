block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История атрибута складского места

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/15/06
Author: Bakhtadze Natalya
Creation date: 02/15/06

*/

define parameter buffer oldb for ub.place-attr.
define parameter buffer newb for ub.place-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История атрибута складского места".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , newb.obj-type
                         , newb.obj-code
                         , newb.pl-code
                         , newb.attr-code
                         ) " }


{ cmp/trg-def.i  }
{ gbl/cur-time.i }
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-place-attr for ub.c-place-attr.
define buffer buf_c-plc-hist for ub.c-plc-hist.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if g#news <> yes then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-place-attr.
    buffer-copy oldb except
    pl-code
    obj-type
    obj-code
    attr-code
    to buf_c-place-attr
    .
    assign
    buf_c-place-attr.obj-type           = newb.obj-type
    buf_c-place-attr.obj-code           = newb.obj-code
    buf_c-place-attr.pl-code            = newb.pl-code
    buf_c-place-attr.attr-code          = newb.attr-code
    buf_c-place-attr.chip-num           = next-value (s-plc-chip, {&db-name_schema})
    buf_c-place-attr.corr-time          = v-time
    buf_c-place-attr.corr-user-db-num   = g#db-num
    buf_c-place-attr.corr-user-name     = g#userid
    buf_c-place-attr.corr-date          = v-today
    .
    create buf_c-plc-hist.
    buffer-copy buf_c-place-attr to buf_c-plc-hist
    assign
    buf_c-plc-hist.action             = integer( if new( newb )
                                              then {&hn-create}
                                              else {&hn-update})
    buf_c-plc-hist.subject = {&table_place-attr}
    buf_c-plc-hist.is-news = g#news
    buf_c-plc-hist.gds-code = ?
    .
  end.
end. /* Main-Block */