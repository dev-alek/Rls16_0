/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека работы с историей БАР-КОДА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/26/04
Author: Bakhtadze Natalya
Creation date: 01/26/04

ВНИМАНИЕ! при вызове с параметров p-action = {&hn-delete} надо отключать trigger на wrtie c-bar-code!!!

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ nws/lib-nws.i }

&if "{1}" = "trig" &then

procedure bar-codh_write-bar-code-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-bar-code for ub.c-bar-code.

  do
  on error undo, return error
  :
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      {&table_bar-code}
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
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-bar-code.
    buffer-copy {2} to buf_c-bar-code
    assign
    buf_c-bar-code.gds-code           = (if p-new-record then {3}.gds-code else {2}.gds-code)
    buf_c-bar-code.b-code             = (if p-new-record then {3}.b-code else {2}.b-code)
    buf_c-bar-code.chip-num           = next-value (s-gds-chip, {&db-name_schema})
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
    buffer-copy buf_c-bar-code to buf_c-gds-hist
    assign
    buf_c-gds-hist.gds-code           = buf_c-bar-code.gds-code
    buf_c-gds-hist.action = (if p-new-record
                              then integer({&hn-create})
                              else (if {3}.gds-code = {2}.gds-code
                                    and {3}.b-code  = {2}.b-code
                                    then p-action
                                    else integer({&hn-rename}))
                            )
    buf_c-gds-hist.b-code             = (if buf_c-gds-hist.action = integer({&hn-rename})
                                        and {2}.b-code  <>  {3}.b-code
                                        then {2}.b-code
                                        else {3}.b-code)
    buf_c-gds-hist.subject = {&table_bar-code}
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
    if p-action = integer({&hn-delete}) then do:
      if
      not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */
      OR (g#news
          and not ( g#db-num > 0 )
          and buf_c-bar-code.corr-user-name <> {&nts-user}
          ) /*транзит из УБД1 через ГБД в УБД2*/
          /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
      or (g#news
          and ( g#db-num > 0 )
          and buf_c-bar-code.corr-user-name = {&nts-user}
          )   /*из УБД - записи рожденные СПН*/
      then
      run str/callnews.p
        (input {&table_c-bar-code}
        ,input (buffer buf_c-bar-code:handle)
        ).
    end.
  end.

end procedure. /* write-bar-code-hist */


&endif

procedure bar-codh_write-bar-code-proc  :
define parameter buffer buf_bar-code for ub.bar-code .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-bar-code for ub.c-bar-code.

  do
  on error undo, return error
  :

    if not available buf_bar-code then do:
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
      {&table_bar-code}
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
    create buf_c-bar-code.
    if p-action = integer({&hn-create}) then do:
      assign
      buf_c-bar-code.b-code             = buf_bar-code.b-code
      buf_c-bar-code.gds-code           = buf_bar-code.gds-code
      buf_c-bar-code.chip-num           = next-value (s-gds-chip, {&db-name_schema})
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
    end.
    else do:
      buffer-copy buf_bar-code to buf_c-bar-code
      assign
      buf_c-bar-code.gds-code           = buf_bar-code.gds-code
      buf_c-bar-code.chip-num           = next-value (s-gds-chip, {&db-name_schema})
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
    end.
    create buf_c-gds-hist.
    buffer-copy buf_c-bar-code to buf_c-gds-hist
    assign
    buf_c-gds-hist.gds-code           = buf_c-bar-code.gds-code
    buf_c-gds-hist.action = integer(p-action)
    buf_c-gds-hist.subject = {&table_bar-code}
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = (if g#news then {&hn-source-db}
                                  else (if g#esys
                                        then {&hn-source-esys}
                                        else "":U
                                        )
                                 )
    buf_c-gds-hist.source-ref = (if g#news
                                 then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U
                                        )
                                 )
    .


  end.

end procedure. /* write-bar-code-hist */


/* $Workfile$ e n d */