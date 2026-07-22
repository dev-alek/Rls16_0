/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека работы с историей ДОПБК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/26/04
Author: Bakhtadze Natalya
Creation date: 01/26/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ nws/lib-nws.i }

&if "{1}" = "trig" &then

procedure prod-bch_write-prod-bc-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-action  as integer no-undo .
define input parameter p-gds-code  like ub.goods.gds-code no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-prod-bc for ub.c-prod-bc.
define buffer buf_c-bar-code for ub.c-bar-code.

  do
  on error undo, return error
  :
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      {&table_prod-bc}
      0
      '':U
      0
      '':U
      '':U
      '':U
      0
      0
      0
      {&nws-to-hist}
      v-send
      no-error
      }
      if v-send < 0 then return.
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-prod-bc.
    buffer-copy {2} to buf_c-prod-bc
    assign
    buf_c-prod-bc.b-code             = (if p-new-record then {3}.b-code else {2}.b-code)
    buf_c-prod-bc.b-str              = (if p-new-record then {3}.b-str  else {2}.b-str)
    buf_c-prod-bc.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-prod-bc.corr-time          = v-time
    buf_c-prod-bc.corr-user-db-num   = g#db-num
    buf_c-prod-bc.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                       )
    buf_c-prod-bc.corr-date          = v-date
    .
    create buf_c-bar-code.
    assign
    buf_c-bar-code.b-code             = (if p-new-record then {3}.b-code else {2}.b-code)
    buf_c-bar-code.gds-code           = p-gds-code
    buf_c-bar-code.chip-num           = buf_c-prod-bc.chip-num
    buf_c-bar-code.corr-time          = v-time
    buf_c-bar-code.corr-user-db-num   = g#db-num
    buf_c-bar-code.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                       )

    buf_c-bar-code.corr-date          = v-date
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-prod-bc to buf_c-gds-hist
    assign
    buf_c-gds-hist.gds-code           = p-gds-code
    buf_c-gds-hist.action = (if p-new-record
                              then integer({&hn-create})
                              else p-action
                            )
    buf_c-gds-hist.subject = {&table_prod-bc}
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = (if g#news
                                  then {&hn-source-db}
                                  else (if g#esys
                                        then {&hn-source-esys}
                                        else "":U)
                                  )
    buf_c-gds-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
    .
  end.

end procedure. /* write-prod-bc-hist */


&endif

procedure prod-bch_write-prod-bc-proc  :
define parameter buffer buf_prod-bc for ub.prod-bc .
define input parameter p-action  as integer no-undo .
define input parameter p-gds-code  like ub.goods.gds-code no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-prod-bc for ub.c-prod-bc.
define buffer buf_c-bar-code for ub.c-bar-code.

  do
  on error undo, return error
  :

    if not available buf_prod-bc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определен БАР-КОД" skip
        view-as alert-box error .
      undo, return error .
    end.
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      {&table_prod-bc}
      {&nws-to-hist}
      0
      '':U
      0
      '':U
      '':U
      '':U
      0
      0
      0
      v-send
      no-error
      }
      if v-send < 0 then return.
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-prod-bc.
    buffer-copy buf_prod-bc to buf_c-prod-bc
    assign
    buf_c-prod-bc.b-code            = buf_c-prod-bc.b-code
    buf_c-prod-bc.b-str             = buf_c-prod-bc.b-str
    buf_c-prod-bc.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-prod-bc.corr-time          = v-time
    buf_c-prod-bc.corr-user-db-num   = g#db-num
    buf_c-prod-bc.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                       )

    buf_c-prod-bc.corr-date          = v-date
    .
    create buf_c-bar-code.
    assign
    buf_c-bar-code.b-code             = buf_c-bar-code.b-code
    buf_c-bar-code.gds-code           = p-gds-code
    buf_c-bar-code.chip-num           = buf_c-prod-bc.chip-num
    buf_c-bar-code.corr-time          = v-time
    buf_c-bar-code.corr-user-db-num   = g#db-num
    buf_c-bar-code.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                       )
    buf_c-bar-code.corr-date          = v-date
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-prod-bc to buf_c-gds-hist
    assign
    buf_c-gds-hist.gds-code           = p-gds-code
    buf_c-gds-hist.action = integer(p-action)
    buf_c-gds-hist.subject = {&table_prod-bc}
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = (if g#news
                                  then {&hn-source-db}
                                  else (if g#esys
                                        then {&hn-source-esys}
                                        else "":U)
                                  )
    buf_c-gds-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
    .
  end.

end procedure. /* write-prod-bc-hist */


/* $Workfile$ e n d */