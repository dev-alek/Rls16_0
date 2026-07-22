block-level on error undo, throw.
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись таблицы связи МЦ с товарами

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/05/07
Author: Polina Gridchina
Creation date: 04/05/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.wth-gds old oldwth-gds.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись таблицы связи МЦ с товарами".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-wth-hist for ub.c-wth-hist.
define buffer buf_c-table-bind  for ub.c-table-bind.
define buffer buf_c-wth-gds for ub.c-wth-gds.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /*Передача в новости. В т.ч. в ветку wth-hist и gds-hist */
  run str/callnews.p
    ( input "wth-gds"
     ,input (buffer ub.wth-gds:handle)
    ) .
  if not g#news then do:

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-wth-gds.
    buffer-copy oldwth-gds to buf_c-wth-gds
    assign
    buf_c-wth-gds.wth-code           = if new ub.wth-gds then ub.wth-gds.wth-code else oldwth-gds.wth-code
    buf_c-wth-gds.gds-code           = if new ub.wth-gds then ub.wth-gds.gds-code else oldwth-gds.gds-code
    buf_c-wth-gds.chip-num           = next-value (s-wth-chip, {&db-name_schema})
    buf_c-wth-gds.corr-time          = v-time
    buf_c-wth-gds.corr-user-db-num   = g#db-num
    buf_c-wth-gds.corr-user-name     = g#userid
    buf_c-wth-gds.corr-date          = v-date
    .
    create buf_c-wth-hist.
    buffer-copy buf_c-wth-gds to buf_c-wth-hist
    assign
    buf_c-wth-hist.wth-code          = buf_c-wth-gds.wth-code
    buf_c-wth-hist.action = (if new(wth-gds)
                              then integer({&hn-create})
                              else integer ({&hn-update})
                            )
    buf_c-wth-hist.subject = {&table_wth-gds}
    buf_c-wth-hist.is-news = g#news
    buf_c-wth-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-wth-hist.source-ref = if g#news then string(g#news-source-db) else "":U
    .

    create buf_c-gds-hist.
    buffer-copy buf_c-wth-gds
    except chip-num
    to buf_c-gds-hist
    assign
    buf_c-gds-hist.action = (if new wth-gds then integer({&hn-create}) else integer({&hn-update}))
    buf_c-gds-hist.subject = {&table_wth-gds}
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.chip-num =   next-value (s-gds-chip, {&db-name_schema})
    buf_c-gds-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
    .
    create buf_c-table-bind.
    assign
    buf_c-table-bind.chip-num-rec   = buf_c-gds-hist.chip-num
    buf_c-table-bind.chip-num-src   = buf_c-wth-hist.chip-num
    buf_c-table-bind.corr-user-db-num     = buf_c-wth-gds.corr-user-db-num
    buf_c-table-bind.tbl-name-rec   = {&table_c-gds-hist}
    buf_c-table-bind.tbl-name-src   = {&table_c-wth-hist}
    buf_c-table-bind.is-news         = g#news
    buf_c-table-bind.corr-user-name  = g#userid
    buf_c-table-bind.subject         = {&table_wth-gds}
    .

  end.
end.