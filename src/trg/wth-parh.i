/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека процедур создания истории МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/13/04
Author: Bakhtadze Natalya
Creation date: 02/13/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "trig" &then

procedure wth-parh_write-wth-par-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-wth-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-wth-hist.source-ref no-undo .
define input parameter p-action     as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-wth-hist for ub.c-wth-hist.
define buffer buf_c-wth-par for ub.c-wth-par.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-wth-par.
    buffer-copy {2} to buf_c-wth-par
    assign
    buf_c-wth-par.wth-code           = (if p-new-record then {3}.wth-code else {2}.wth-code)
    buf_c-wth-par.par-code           = (if p-new-record then {3}.par-code else {2}.par-code)
    buf_c-wth-par.chip-num           = next-value (s-wth-chip, {&db-name_schema})
    buf_c-wth-par.corr-time          = v-time
    buf_c-wth-par.corr-user-db-num   = g#db-num
    buf_c-wth-par.corr-user-name     = (if g#news then {&nts-user} else g#userid)
    buf_c-wth-par.corr-date          = v-date
    .

    create buf_c-wth-hist.
    buffer-copy buf_c-wth-par to buf_c-wth-hist
    assign
    buf_c-wth-hist.wth-code           = buf_c-wth-par.wth-code
    buf_c-wth-hist.par-code           = buf_c-wth-par.par-code
    buf_c-wth-hist.action = (if p-new-record
                              then integer({&hn-create})
                              else p-action
                            )
    buf_c-wth-hist.subject = {&table_wth-par}
    buf_c-wth-hist.is-news = g#news
    buf_c-wth-hist.source-type = p-source-type
    buf_c-wth-hist.source-ref = p-source-ref
    .
  end.

end procedure. /* write-wth-par-hist */


&endif

procedure wth-parh_write-wth-par-proc  :
define parameter buffer buf_wth-par for ub.wth-par .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-wth-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-wth-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-wth-hist for ub.c-wth-hist.
define buffer buf_c-wth-par for ub.c-wth-par.


  do
  on error undo, return error
  :
    if not available buf_wth-par then do:
      undo, return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description  + {&new-line} +
                    "Ошибка задания входных параметров:Не определена МЦ" ).
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-wth-par.
    buffer-copy buf_wth-par to buf_c-wth-par
    assign
    buf_c-wth-par.wth-code             = buf_wth-par.wth-code
    buf_c-wth-par.par-code             = buf_wth-par.par-code
    buf_c-wth-par.chip-num           = next-value (s-wth-chip, {&db-name_schema})
    buf_c-wth-par.corr-time          = v-time
    buf_c-wth-par.corr-user-db-num   = g#db-num
    buf_c-wth-par.corr-user-name     = (if g#news then {&nts-user} else g#userid)
    buf_c-wth-par.corr-date          = v-date
    .
    create buf_c-wth-hist.
    buffer-copy buf_c-wth-par to buf_c-wth-hist
    assign
    buf_c-wth-hist.action =  p-action
    buf_c-wth-hist.subject = {&table_wth-par}
    buf_c-wth-hist.is-news = g#news
    buf_c-wth-hist.source-type = p-source-type
    buf_c-wth-hist.source-ref = p-source-ref
    .

  end.

end procedure. /* write-clients-hist */


/* $Workfile$ e n d */