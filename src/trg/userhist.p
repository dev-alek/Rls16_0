block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура заполнения таблицы истории пользователя.

Автор: Шкляр Елена
Дата создания: 03/27/08
Author: Elena Shklyar
Creation date: 03/27/08

Input:

Output:

*/
define input parameter p-action         as integer        no-undo.
define input parameter p-tbl-name       as character        no-undo.
define input parameter p-sourse-ref     as character        no-undo.
define input parameter p-user-id        as character        no-undo .
&if defined(obuffer)  
&then 
define output parameter o-c-usr-hist as rowid no-undo.
&endif
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура заполнения таблицы истории пользователя.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }

    define variable v-corr-user-db-num      as integer      no-undo.
    define variable v-corr-date             as date         no-undo.
    define variable v-corr-time             as integer      no-undo.
    define variable v-corr-user-name        as character    no-undo.
    define VARIABLE v-chip-num              as integer      no-undo .
    define buffer buf_c-usr-hist            for ub.c-usr-hist .
    
    
    define variable par-type as character no-undo .
    define variable par-is-cctv as character no-undo .
    define variable is-cctv as logical no-undo .

    define variable v-action-type   as character no-undo .
     
  run cur-time in this-procedure(output v-corr-date, output v-corr-time).
            assign
                v-corr-user-db-num = g#db-num
                v-corr-date        = v-corr-date
                v-corr-time        = v-corr-time
                v-corr-user-name   = g#userid .
  
    assign
    v-chip-num = next-value(s-usr-chip)
  .
                
  create buf_c-usr-hist .
  assign
    buf_c-usr-hist.subject = p-tbl-name
    buf_c-usr-hist.action  = p-action
    buf_c-usr-hist.is-news = g#news
    buf_c-usr-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-usr-hist.source-ref  = (if g#news then string(g#news-source-db) else "":U)
    buf_c-usr-hist.user-id = p-user-id
    buf_c-usr-hist.corr-user-db-num = v-corr-user-db-num
    buf_c-usr-hist.corr-date = v-corr-date
    buf_c-usr-hist.corr-time = v-corr-time
    buf_c-usr-hist.corr-user-name = v-corr-user-name
    buf_c-usr-hist.source-ref = p-sourse-ref
    buf_c-usr-hist.chip-num =  v-chip-num
  .
&if defined(obuffer)  
&then 
    o-c-usr-hist= rowid(buf_c-usr-hist).
&endif
