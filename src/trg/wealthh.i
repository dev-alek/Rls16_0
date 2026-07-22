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

procedure wealthh_write-wealth-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-wth-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-wth-hist.source-ref no-undo .
define input parameter p-action     as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-wth-hist for ub.c-wth-hist.
define buffer buf_c-wealth for ub.c-wealth.


  do
  on error undo, return error   return-value
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-wealth.
    buffer-copy {2} to buf_c-wealth
    assign
    buf_c-wealth.wth-code           = (if p-new-record then {3}.wth-code else {2}.wth-code)
    buf_c-wealth.chip-num           = next-value (s-wth-chip, {&db-name_schema})
    buf_c-wealth.corr-time          = v-time
    buf_c-wealth.corr-user-db-num   = g#db-num
    buf_c-wealth.corr-user-name     = (if g#news then {&nts-user} else g#userid)
    buf_c-wealth.corr-date          = v-date
    .

            create buf_c-wth-hist.
    buffer-copy buf_c-wealth to buf_c-wth-hist
    assign
    buf_c-wth-hist.wth-code           = buf_c-wealth.wth-code
    buf_c-wth-hist.action = (if p-new-record
                              then integer({&hn-create})
                              else p-action
                            )
    buf_c-wth-hist.subject = {&table_wealth}
    buf_c-wth-hist.is-news = g#news
    buf_c-wth-hist.source-type = p-source-type
    buf_c-wth-hist.source-ref = p-source-ref
    .

  end.

end procedure. /* write-wealth-hist */


&endif

procedure wealthh_write-wealth-proc  :
define parameter buffer buf_wealth for ub.wealth .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-wth-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-wth-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-wth-hist for ub.c-wth-hist.
define buffer buf_c-wealth for ub.c-wealth.


  do
  on error undo, return error
  :
    if not available buf_wealth then do:
      undo, return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description  + {&new-line} +
                    "Ошибка задания входных параметров:Не определена МЦ" ).
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-wealth.
    buffer-copy buf_wealth to buf_c-wealth
    assign
    buf_c-wealth.wth-code             = buf_wealth.wth-code
    buf_c-wealth.chip-num           = next-value (s-wth-chip, {&db-name_schema})
    buf_c-wealth.corr-time          = v-time
    buf_c-wealth.corr-user-db-num   = g#db-num
    buf_c-wealth.corr-user-name     = (if g#news then {&nts-user} else g#userid)
    buf_c-wealth.corr-date          = v-date
    .
    create buf_c-wth-hist.
    buffer-copy buf_c-wealth to buf_c-wth-hist
    assign
    buf_c-wth-hist.action =  p-action
    buf_c-wth-hist.subject = {&table_wealth}
    buf_c-wth-hist.is-news = g#news
    buf_c-wth-hist.source-type = p-source-type
    buf_c-wth-hist.source-ref = p-source-ref
    .

  end.

end procedure. /* write-clients-hist */


/* $Workfile$ e n d */