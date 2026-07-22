block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись серий материальных ценностей

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/02/07
Author: Polina Gridchina
Creation date: 04/02/07

*/

   TRIGGER PROCEDURE FOR write OF ub.wth-ser old  oldwth-ser.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись серий мат.ценностей ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-wth-hist for ub.c-wth-hist.
define buffer buf_c-wth-ser for ub.c-wth-ser.
/*define buffer buf_wealth for ub.wealth.*/
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run str/callnews.p
    ( input "wth-ser"
     ,input (buffer ub.wth-ser:handle)
     ) .
  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-wth-ser.
    buffer-copy oldwth-ser to buf_c-wth-ser
    assign
    buf_c-wth-ser.ser-code           = if new ub.wth-ser then ub.wth-ser.ser-code else   oldwth-ser.ser-code
    buf_c-wth-ser.db-num             = if new ub.wth-ser then ub.wth-ser.db-num else oldwth-ser.db-num
    buf_c-wth-ser.wth-code           = if new ub.wth-ser then ub.wth-ser.wth-code else oldwth-ser.wth-code
    buf_c-wth-ser.par-code           = if new ub.wth-ser then ub.wth-ser.par-code else oldwth-ser.par-code
    buf_c-wth-ser.chip-num           = next-value (s-wth-chip, {&db-name_schema})
    buf_c-wth-ser.corr-time          = v-time
    buf_c-wth-ser.corr-user-db-num   = g#db-num
    buf_c-wth-ser.corr-user-name     = g#userid
    buf_c-wth-ser.corr-date          = v-date
    .
    create buf_c-wth-hist.
    buffer-copy buf_c-wth-ser to buf_c-wth-hist
    assign
    buf_c-wth-hist.wth-code          = buf_c-wth-ser.wth-code
    buf_c-wth-hist.action = (if new(wth-ser)
                              then integer({&hn-create})
                              else integer ({&hn-update})
                            )
    buf_c-wth-hist.subject = {&table_wth-ser}
    buf_c-wth-hist.is-news = g#news
    buf_c-wth-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-wth-hist.source-ref = if g#news then string(g#news-source-db) else "":U
    .

  end.

end.