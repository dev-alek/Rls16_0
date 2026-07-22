block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение истории при изменении place

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

define parameter buffer oldb for ub.place.
define parameter buffer newb for ub.place.


define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Заполнение истории при изменении place":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , newb.obj-type
                         , newb.obj-code
                         , newb.pl-code
                         ) " }


{ cmp/trg-def.i  }
{ gbl/cur-time.i }
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-place for ub.c-place.
define buffer buf_c-plc-hist for ub.c-plc-hist.


/* ************  Н О В А Я   И С Т О Р И Я  ************ */

Main-Block:
do transaction on error   undo Main-Block, return error return-value
               on end-key undo Main-Block, return error return-value
               on stop    undo Main-Block, return error return-value :
  if g#news <> yes then do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-place.
    buffer-copy oldb except
    pl-code
    obj-type
    obj-code
    to buf_c-place
    .
    assign
    buf_c-place.obj-type           = newb.obj-type
    buf_c-place.obj-code           = newb.obj-code
    buf_c-place.pl-code            = newb.pl-code
    buf_c-place.chip-num           = next-value (s-plc-chip, {&db-name_schema})
    buf_c-place.corr-time          = v-time
    buf_c-place.corr-user-db-num   = g#db-num
    buf_c-place.corr-user-name     = g#userid
    buf_c-place.corr-date          = v-today
    .
    create buf_c-plc-hist.
    buffer-copy buf_c-place to buf_c-plc-hist
    assign
    buf_c-plc-hist.action             = integer( if new( newb )
                                              then {&hn-create}
                                              else {&hn-update})
    buf_c-plc-hist.subject = {&table_place}
    buf_c-plc-hist.is-news = g#news
    buf_c-plc-hist.gds-code = ?
    .
  end.
end. /* Main-Block */