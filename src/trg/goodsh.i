/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотекка процедур создания истории ТОВАРА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/13/04
Author: Bakhtadze Natalya
Creation date: 02/13/04

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ nws/lib-nws.i }

&if "{1}" = "trig" &then

procedure goodsh_write-goods-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-goods for ub.c-goods.


  do
  on error undo, return error
  :
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      {&table_goods}
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
    create buf_c-goods.
    buffer-copy {2} to buf_c-goods
    assign
    buf_c-goods.gds-code           = (if p-new-record then {3}.gds-code else {2}.gds-code)
    buf_c-goods.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-goods.corr-time          = v-time
    buf_c-goods.corr-user-db-num   = g#db-num
    buf_c-goods.corr-user-name     = (if g#news then {&nts-user}
                                      else (if g#esys
                                            then {&esys-user}
                                            else g#userid)
                                      )
    buf_c-goods.corr-date          = v-date
    .

    create buf_c-gds-hist.
    buffer-copy buf_c-goods to buf_c-gds-hist
    assign
    buf_c-gds-hist.gds-code           = buf_c-goods.gds-code
    buf_c-gds-hist.action = (if p-new-record
                              then integer({&hn-create})
                              else (if {3}.gds-code = {2}.gds-code
                                    then integer({&hn-update})
                                    else integer({&hn-rename}))
                            )
    buf_c-gds-hist.subject = {&table_goods}
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = p-source-type
    buf_c-gds-hist.source-ref = p-source-ref
    .
  end.

end procedure. /* write-goods-hist */


&endif

procedure goodsh_write-goods-proc  :
define parameter buffer buf_goods for ub.goods .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-goods for ub.c-goods.


  do
  on error undo, return error
  :
    if not available buf_goods then do:
      undo, return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description  + {&new-line} +
                    "Ошибка задания входных параметров:Не определен товар" ).
    end.
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      {&table_goods}
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
    create buf_c-goods.
    buffer-copy buf_goods to buf_c-goods
    assign
    buf_c-goods.gds-code             = buf_goods.gds-code
    buf_c-goods.chip-num           = next-value (s-gds-chip, {&db-name_schema})
    buf_c-goods.corr-time          = v-time
    buf_c-goods.corr-user-db-num   = g#db-num
    buf_c-goods.corr-user-name     = (if g#news then {&nts-user}
                                      else (if g#esys
                                            then {&esys-user}
                                            else g#userid)
                                            )
    buf_c-goods.corr-date          = v-date
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-goods to buf_c-gds-hist
    assign
    buf_c-gds-hist.action =  p-action
    buf_c-gds-hist.subject = {&table_goods}
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = p-source-type
    buf_c-gds-hist.source-ref = p-source-ref
    .

  end.

end procedure. /* write-clients-hist */


/* $Workfile$ e n d */