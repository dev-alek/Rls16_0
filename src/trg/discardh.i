/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека работы с историей ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/26/04
Author: Bakhtadze Natalya
Creation date: 01/26/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(discardh_i) = 0 &then

&glob discardh_i

&if "{1}" = "trig" &then

procedure discardh_write-dis-card-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card for ub.c-dis-card.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-card.
    buffer-copy {2} to buf_c-dis-card
    assign
    buf_c-dis-card.d-card            = {3}.d-card
    buf_c-dis-card.card-num          = {3}.card-num
    buf_c-dis-card.chip-num           = next-value (s-dc-chip, {&db-name_schema})
    buf_c-dis-card.corr-time          = v-time
    buf_c-dis-card.corr-user-db-num   = g#db-num
    buf_c-dis-card.corr-user-name     = (if g#news
                                         then {&nts-user}
                                         else (if g#esys
                                               then {&esys-user}
                                               else g#userid
                                              )
                                         )
    buf_c-dis-card.corr-date          = v-date
    .
    create buf_c-dc-hist.
    buffer-copy buf_c-dis-card to buf_c-dc-hist
    assign
&if "{4}" = "delete" &then
    buf_c-dc-hist.action = integer({&hn-delete})
&else
    buf_c-dc-hist.action =  (if p-new-record
                              then integer({&hn-create})
                              else integer({&hn-update}))
&endif
    buf_c-dc-hist.subject = {&table_dis-card}
    buf_c-dc-hist.host-code = {3}.emitent-host-code
    buf_c-dc-hist.is-news = g#news
    buf_c-dc-hist.source-type = p-source-type
    buf_c-dc-hist.source-ref = p-source-ref
    .

    if not ( g#db-num > 0 )
    or (g#news
        and ( g#db-num > 0 )
        and buf_c-dis-card.corr-user-name = {&nts-user}
        )   /*из УБД - записи рожденные СПН*/
    then do:
      run str/callnews.p
        (input {&table_c-dis-card}
        ,input (buffer buf_c-dis-card:handle)
        ).
    end.
  end.

end procedure. /* write-dis-card-hist */


&endif

&if "{1}" = "" &then

procedure discardh_write-dis-card-proc  :
define parameter buffer buf_dis-card for ub.dis-card .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card for ub.c-dis-card.


  do
  on error undo, return error
  :
    if not available buf_dis-card then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определена ДК" skip
        view-as alert-box error .
      undo, return error .
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-card.
    buffer-copy buf_dis-card to buf_c-dis-card
    assign
    buf_c-dis-card.d-card             = buf_dis-card.d-card
    buf_c-dis-card.card-num           = buf_dis-card.card-num
    buf_c-dis-card.chip-num           = next-value (s-dc-chip, {&db-name_schema})
    buf_c-dis-card.corr-time          = v-time
    buf_c-dis-card.corr-user-db-num   = g#db-num
    buf_c-dis-card.corr-user-name     = (if g#news
                                         then {&nts-user}
                                         else (if g#esys
                                               then {&esys-user}
                                               else g#userid
                                              )
                                         )
    buf_c-dis-card.corr-date          = v-date
    .
    create buf_c-dc-hist.
    buffer-copy buf_c-dis-card to buf_c-dc-hist
    assign
    buf_c-dc-hist.action =  integer({&hn-update})
    buf_c-dc-hist.subject = {&table_dis-card}
    buf_c-dc-hist.host-code =  buf_dis-card.emitent-host-code
    buf_c-dc-hist.is-news = g#news
    buf_c-dc-hist.source-type = p-source-type
    buf_c-dc-hist.source-ref = p-source-ref
    .
    if not ( g#db-num > 0 )
    or (g#news
        and ( g#db-num > 0 )
        and buf_c-dis-card.corr-user-name = {&nts-user}
        )   /*из УБД - записи рожденные СПН*/
    then do:
      run str/callnews.p
        (input {&table_c-dis-card}
        ,input (buffer buf_c-dis-card:handle)
        ).
      run str/callnews.p
        (input {&table_c-dc-hist}
        ,input (buffer buf_c-dc-hist:handle)
        ).

    end.
  end.

end procedure. /* write-dis-card-hist */

&endif

&if "{1}" = "rul" &then

procedure discardh_write-dis-card-rul  :
define parameter buffer buf_dis-card for ub.dis-card .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card for ub.c-dis-card.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.


do
on error undo, return error
:
  if not available buf_dis-card then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = {&table_dis-card}
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = 2   /*p-dtm-code*/
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
          and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = {&table_dis-card}
    buf_temp-hist-nws-option.key#_one = 2
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer({&hn-is-off})
    .
    { gbl/get-hnr.i
      g#db-num
      "buffer buf_temp-hist-nws-option:handle"
      }
  end.
  if not g#news
  and buf_temp-hist-nws-option.hist-from-prim < 0 then do:
    return.
  end.

  if g#news
  and buf_temp-hist-nws-option.nws-to-hist < 0 then do:
    return.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-dis-card.
  buffer-copy buf_dis-card to buf_c-dis-card
  assign
  buf_c-dis-card.d-card             = buf_dis-card.d-card
  buf_c-dis-card.card-num           = buf_dis-card.card-num
  buf_c-dis-card.chip-num           = next-value (s-dc-chip, {&db-name_schema})
  buf_c-dis-card.corr-time          = v-time
  buf_c-dis-card.corr-user-db-num   = g#db-num
  buf_c-dis-card.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                              then {&esys-user}
                                              else g#userid
                                            )
                                        )
  buf_c-dis-card.corr-date          = v-date
  .
  create buf_c-dc-hist.
  buffer-copy buf_c-dis-card to buf_c-dc-hist
  assign
  buf_c-dc-hist.action =  p-action
  buf_c-dc-hist.subject = {&table_dis-card}
  buf_c-dc-hist.host-code =  buf_dis-card.emitent-host-code
  buf_c-dc-hist.is-news = g#news
  buf_c-dc-hist.source-type = p-doc-type
  buf_c-dc-hist.source-ref = (if p-doc-type = '':U
                               then '':U
                               else p-doc-code)
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    &scop table__ {&table_c-dis-card}
    &scop buffer-handle buffer buf_c-dis-card:handle
    &scop rec-ord v-rec-ord2
    &scop action__ '+update'
    &scop gate-rec ''

    {&add-dump-ext}.

    &scop table__ {&table_c-dc-hist}
    &scop buffer-handle buffer buf_c-dc-hist:handle
    &scop rec-ord v-rec-ord3
    &scop action__ '+update'
    &scop gate-rec ''

    {&add-dump-ext}.
    if g#db-num = 0 then do:
      run create-smart-route-link in this-procedure ( input {&table_c-dis-card}
                                                    ,input buffer buf_c-dis-card:handle
                                                    ,input buf_dis-card.d-card
                                                    ,input v-rec-ord2
                                                    ,input no
                                                    ).

      run create-smart-route-link in this-procedure ( input {&table_c-dc-hist}
                                                    ,input buffer buf_c-dc-hist:handle
                                                    ,input buf_dis-card.d-card
                                                    ,input v-rec-ord3
                                                    ,input no
                                                    ).

      run create-smart-route in this-procedure  ( input buf_dis-card.d-card
                                                ,input -1).
    end.
  end.
end.

end procedure. /* discardh_write-dis-card-rul  */

procedure discardh_send-dis-card-rul  :
define parameter buffer buf_dis-card for ub.dis-card .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card for ub.c-dis-card.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.


do
on error undo, return error
:
  if g#db-num > 0 then return.
  if not available buf_dis-card then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  &scop table__ {&table_dis-card}
  &scop buffer-handle buffer buf_dis-card:handle
  &scop rec-ord v-rec-ord1
  &scop action__ '+update'
  &scop gate-rec ''

  {&add-dump-ext}.
  /*
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = {&table_dis-card}
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = 2
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0 no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = {&table_dis-card}
    buf_temp-hist-nws-option.key#_one = 2 /*p-dtm-code*/
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer({&hn-is-off})
    .
    { gbl/get-hnr.i
      g#db-num
      "buffer buf_temp-hist-nws-option:handle"
      }
  end.
  */
  run create-smart-route-link in this-procedure ( input {&table_dis-card}
                                                ,input buffer buf_dis-card:handle
                                                ,input buf_dis-card.d-card
                                                ,input v-rec-ord1
                                                ,input no
                                                ).

  run create-smart-route in this-procedure  ( input buf_dis-card.d-card
                                              ,input -1).
end.

end procedure. /* discardh_send-dis-card-rul  */



&endif

&endif


/* $Workfile$ e n d */