/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека работы с историей БАР-КОДА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/09/09
Author: Bakhtadze Natalya
Creation date: 06/09/09

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ nws/lib-nws.i }

&if "{1}" = "trig" &then

procedure bc-attrh_write-bar-code-obj-attr-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-host-code as integer no-undo .
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-bar-code-obj-attr for ub.c-bar-code-obj-attr.

  do
  on error undo, return error
  :
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      {&table_bar-code-obj-attr}
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
    if {2}.obj-type = {&shop}
    or {2}.obj-type = {&stock} then do:
      { gbl/hostcode.i {2}.obj-type {2}.obj-code v-host-code }
    end.
    create buf_c-bar-code-obj-attr.
    buffer-copy {2} to buf_c-bar-code-obj-attr
    assign
    buf_c-bar-code-obj-attr.gds-code           = (if p-new-record then {3}.gds-code else {2}.gds-code)
    buf_c-bar-code-obj-attr.b-code             = (if p-new-record then {3}.b-code else {2}.b-code)
    buf_c-bar-code-obj-attr.attr-code          = (if p-new-record then {3}.attr-code else {2}.attr-code)
    buf_c-bar-code-obj-attr.obj-type           = (if p-new-record then {3}.obj-type else {2}.obj-type)
    buf_c-bar-code-obj-attr.obj-code           = (if p-new-record then {3}.obj-code else {2}.obj-code)
    buf_c-bar-code-obj-attr.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-bar-code-obj-attr.corr-time          = v-time
    buf_c-bar-code-obj-attr.corr-user-db-num   = g#db-num
    buf_c-bar-code-obj-attr.corr-user-name     = (if g#news
                                         then {&nts-user}
                                         else (if g#esys
                                               then {&esys-user}
                                               else g#userid)
                                        )
    buf_c-bar-code-obj-attr.corr-date          = v-date
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-bar-code-obj-attr to buf_c-gds-hist
    assign
    buf_c-gds-hist.gds-code           = buf_c-bar-code-obj-attr.gds-code
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
    buf_c-gds-hist.subject = {&table_bar-code-obj-attr}
    buf_c-gds-hist.host-code = v-host-code
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
          and buf_c-bar-code-obj-attr.corr-user-name <> {&nts-user}
          ) /*транзит из УБД1 через ГБД в УБД2*/
          /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/
      or (g#news
          and ( g#db-num > 0 )
          and buf_c-bar-code-obj-attr.corr-user-name = {&nts-user}
          )   /*из УБД - записи рожденные СПН*/
      then
      run str/callnews.p
        (input {&table_c-bar-code-obj-attr}
        ,input (buffer buf_c-bar-code-obj-attr:handle)
        ).
    end.
  end.

end procedure. /* write-bar-code-obj-attr-hist */

&endif

/* $Workfile$ e n d */