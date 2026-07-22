/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с историей итогов ДК по объектам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/29/04
Author: Bakhtadze Natalya
Creation date: 01/29/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(dis-objh_i) = 0 &then

&glob dis-objh_i

{ gbl/key-rec.i }

&if "{1}" = "trig" &then
procedure dis-objh_write-dis-obj-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-uniq-key-rec as character no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-obj for ub.c-dis-obj.


  do
  on error undo, return error return-value
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-obj.
    buffer-copy {2} to buf_c-dis-obj
    assign
    buf_c-dis-obj.d-card            = {3}.d-card
    buf_c-dis-obj.dt-code            = {3}.dt-code
    buf_c-dis-obj.main-card         = {3}.main-card
    buf_c-dis-obj.first-main-card   = {3}.first-main-card
    buf_c-dis-obj.first-card        = {3}.first-card
    buf_c-dis-obj.card-num          = {3}.card-num
    buf_c-dis-obj.obj-type          = {3}.obj-type
    buf_c-dis-obj.obj-code          = {3}.obj-code
    buf_c-dis-obj.chip-num           = next-value (s-dc-chip, {&db-name_schema})
    buf_c-dis-obj.corr-time          = v-time
    buf_c-dis-obj.corr-user-db-num   = g#db-num
    buf_c-dis-obj.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                              then {&esys-user}
                                              else g#userid)
                                       )
    buf_c-dis-obj.corr-date          = v-date
    .
    run gen-key-rec in this-procedure (
                                        input {&table_dis-obj}
                                       ,input buffer {3}:handle
                                       ,output v-uniq-key-rec).
    create buf_c-dc-hist.
    buffer-copy buf_c-dis-obj to buf_c-dc-hist
    assign
    buf_c-dc-hist.action =  (if p-new-record
                              then integer({&hn-create})
                              else integer({&hn-update}))
    buf_c-dc-hist.uniq-key-rec = v-uniq-key-rec
    buf_c-dc-hist.subject = {&table_dis-obj}
    buf_c-dc-hist.is-news = g#news
    buf_c-dc-hist.source-type = p-source-type
    buf_c-dc-hist.source-ref = p-source-ref
    .
    run dis-objh_send-nws in this-procedure (
                                              buffer buf_c-dis-obj
                                             ,buffer buf_c-dc-hist
                                              ).

  end.

end procedure. /* write-dis-obj-hist */
&endif

&if "{1}" = "" &then
procedure dis-objh_write-dis-obj-proc  :
define parameter buffer buf_dis-obj for ub.dis-obj .
define input parameter p-is-new      as logical no-undo .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-uniq-key-rec as character no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-obj for ub.c-dis-obj.


  do
  on error undo, return error return-value
  :
    if not available buf_dis-obj then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определена запись ИТОГОВ ДК ПО ОБЪЕКТУ" skip
        view-as alert-box error .
      undo, return error .
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-obj.
    buffer-copy buf_dis-obj to buf_c-dis-obj
    assign
    buf_c-dis-obj.d-card             = buf_dis-obj.d-card
    buf_c-dis-obj.dt-code             = buf_dis-obj.dt-code
    buf_c-dis-obj.main-card          = buf_dis-obj.main-card
    buf_c-dis-obj.first-main-card    = buf_dis-obj.first-main-card
    buf_c-dis-obj.first-card         = buf_dis-obj.first-card
    buf_c-dis-obj.card-num           = buf_dis-obj.card-num
    buf_c-dis-obj.obj-type           = buf_dis-obj.obj-type
    buf_c-dis-obj.obj-code           = buf_dis-obj.obj-code
    buf_c-dis-obj.chip-num           = next-value (s-dc-chip, {&db-name_schema})
    buf_c-dis-obj.corr-time          = v-time
    buf_c-dis-obj.corr-user-db-num   = g#db-num
    buf_c-dis-obj.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                              then {&esys-user}
                                              else g#userid)
                                       )
    buf_c-dis-obj.corr-date          = v-date
    .
    run gen-key-rec in this-procedure (
                                        input {&table_dis-obj}
                                       ,input buffer buf_Dis-obj:handle
                                       ,output v-uniq-key-rec).

    create buf_c-dc-hist.
    buffer-copy buf_c-dis-obj to buf_c-dc-hist
    assign
    buf_c-dc-hist.action =  if p-is-new then integer({&hn-create}) else integer({&hn-update})
    buf_c-dc-hist.subject = {&table_dis-obj}
    buf_c-dc-hist.is-news = g#news
    buf_c-dc-hist.source-type = p-source-type
    buf_c-dc-hist.source-ref = p-source-ref
    buf_c-dc-hist.uniq-key-rec = v-uniq-key-rec
    .
    run dis-objh_send-nws in this-procedure (
                                              buffer buf_c-dis-obj
                                             ,buffer buf_c-dc-hist
                                              ).
  end.

end procedure. /* write-dis-obj-hist */
&endif

&if "{1}" = "rul" &then
procedure dis-objh_write-dis-obj-rul :
define parameter buffer buf_dis-obj for ub.dis-obj .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-obj for ub.c-dis-obj.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.


do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  if not available buf_dis-obj then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = {&table_dis-obj}
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = p-dtm-code
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
    buf_temp-hist-nws-option.table-name = {&table_dis-obj}
    buf_temp-hist-nws-option.key#_one = p-dtm-code
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
  create buf_c-dis-obj.
  buffer-copy buf_dis-obj to buf_c-dis-obj
  assign
  buf_c-dis-obj.d-card             = buf_dis-obj.d-card
  buf_c-dis-obj.obj-type           = buf_dis-obj.obj-type
  buf_c-dis-obj.obj-code           = buf_dis-obj.obj-code
  buf_c-dis-obj.card-num           = buf_dis-obj.card-num
  buf_c-dis-obj.dt-code            = buf_dis-obj.dt-code
  buf_c-dis-obj.main-card          = buf_dis-obj.main-card
  buf_c-dis-obj.first-main-card    = buf_dis-obj.first-main-card
  buf_c-dis-obj.first-card         = buf_dis-obj.first-card
  buf_c-dis-obj.chip-num           = next-value (s-dc-chip, {&db-name_schema})
  buf_c-dis-obj.corr-time          = v-time
  buf_c-dis-obj.corr-user-db-num   = g#db-num
  buf_c-dis-obj.corr-user-name     = (if g#news
                                      then {&nts-user}
                                      else (if g#esys
                                            then {&esys-user}
                                            else g#userid)
                                      )
  buf_c-dis-obj.corr-date          = v-date
  .
  create buf_c-dc-hist.
  buffer-copy buf_c-dis-obj to buf_c-dc-hist
  assign
  buf_c-dc-hist.action = p-action
  buf_c-dc-hist.subject = {&table_dis-obj}
  buf_c-dc-hist.host-code =  buf_dis-obj.host-code
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
    &scop table__ {&table_c-dis-obj}
    &scop buffer-handle buffer buf_c-dis-obj:handle
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
     case  buf_temp-hist-nws-option.smart-nws :
        when integer({&hn-is-on})
        or
        when integer({&hn-is-on-blocked})
        then do:
          run get-db-list-for-d-card  in this-procedure ( input buf_dis-obj.d-card).
          run create-smart-route-link in this-procedure ( input {&table_c-dis-obj}
                                                      ,input buffer buf_c-dis-obj:handle
                                                      ,input buf_dis-obj.d-card
                                                      ,input v-rec-ord2
                                                      ,input yes
                                                      ).
          run create-smart-route-link in this-procedure ( input {&table_c-dc-hist}
                                                      ,input buffer buf_c-dc-hist:handle
                                                      ,input buf_dis-obj.d-card
                                                      ,input v-rec-ord3
                                                      ,input yes
                                                      ).

        end. /*if p-thno:buffer-field("smart-nws"):buffer-value >= 0 then do:*/
        when integer({&hn-is-smart2}) then do:
           /*вообще не передается*/
        end.
        otherwise do:
          run create-smart-route-link in this-procedure ( input {&table_c-dis-obj}
                                                      ,input buffer buf_c-dis-obj:handle
                                                      ,input buf_dis-obj.d-card
                                                      ,input v-rec-ord2
                                                      ,input no
                                                      ).
          run create-smart-route-link in this-procedure ( input {&table_c-dc-hist}
                                                      ,input buffer buf_c-dc-hist:handle
                                                      ,input buf_dis-obj.d-card
                                                      ,input v-rec-ord3
                                                      ,input no
                                                      ).

          run create-smart-route in this-procedure  ( input buf_dis-obj.d-card
                                                  ,input -1).
        end.
      end case.
    end.
  end.
end. /*doe*/
end procedure. /* dis-objh_write-dis-obj-rul  */

procedure dis-objh_send-dis-obj-rul :
define parameter buffer buf_dis-obj for ub.dis-obj .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-obj for ub.c-dis-obj.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.

do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  if not available buf_dis-obj then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена ДК" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = {&table_dis-obj}
        and buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.key#_one = p-dtm-code
        and buf_temp-hist-nws-option.charkey_one = p-type
        and buf_temp-hist-nws-option.host-code = p-emitent-host-code no-error .
  if not available buf_temp-hist-nws-option then do:
    find first last_temp-hist-nws-option where
             last_temp-hist-nws-option.db-num = g#db-num
         and last_temp-hist-nws-option.hn-id < 0  no-error.
    create buf_temp-hist-nws-option.
    assign
    buf_temp-hist-nws-option.db-num = g#db-num
    buf_temp-hist-nws-option.hn-id = (if available last_temp-hist-nws-option
                                then - (abs(last_temp-hist-nws-option.hn-id) + 1)
                                else -1 )
    buf_temp-hist-nws-option.table-name = {&table_dis-obj}
    buf_temp-hist-nws-option.key#_one = p-dtm-code
    buf_temp-hist-nws-option.charkey_one = p-type
    buf_temp-hist-nws-option.host-code = p-emitent-host-code
    buf_temp-hist-nws-option.smart-nws = integer({&hn-is-off})
    .
    { gbl/get-hnr.i
      g#db-num
      "buffer buf_temp-hist-nws-option:handle"
      }
  end.
  &scop table__ {&table_dis-obj}
  &scop buffer-handle buffer buf_dis-obj:handle
  &scop rec-ord v-rec-ord1
  &scop action__ '+update'
  &scop gate-rec ''

  {&add-dump-ext}.

  if g#db-num = 0 then do:
   case buf_temp-hist-nws-option.smart-nws:
      when integer({&hn-is-on})
      or
      when integer({&hn-is-on-blocked}) then do:
        run get-db-list-for-d-card  in this-procedure ( input buf_dis-obj.d-card).
        run create-smart-route-link in this-procedure ( input {&table_dis-obj}
                                                    ,input buffer buf_dis-obj:handle
                                                    ,input buf_dis-obj.d-card
                                                    ,input v-rec-ord1
                                                    ,input yes
                                                    ).
      end. /*if p-thno:buffer-field("smart-nws"):buffer-value >= 0 then do:*/
      when integer({&hn-is-smart2}) then do:
        /*вообще не шлем*/
      end.
      otherwise do:
        run create-smart-route-link in this-procedure ( input {&table_dis-obj}
                                                    ,input buffer buf_dis-obj:handle
                                                    ,input buf_dis-obj.d-card
                                                    ,input v-rec-ord1
                                                    ,input no
                                                    ).
        run create-smart-route in this-procedure  ( input buf_dis-obj.d-card
                                                  ,input -1).
      end.
    end case.
    if g#news then do:
      run create-no-route in this-procedure ( input v-rec-ord1
                                             ,input g#news-source-db).
    end.
  end.
end. /*doe*/
end procedure. /* dis-objh_send-dis-obj-rul */



procedure get-db-list-for-d-card:
define input parameter p-d-card as character no-undo .

define variable v-current-db-processed as logical no-undo .
define buffer buf_clients  for ub.clients.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_temp-smart-route for temp-smart-route.


  do
  on error undo, return error return-value
  :
    for each buf_dis-obj no-lock where
            buf_dis-obj.d-card = p-d-card,
       first buf_clients no-lock where
            buf_clients.obj-type = buf_dis-obj.obj-type
        and buf_clients.obj-code = buf_dis-obj.obj-code
    break by
    buf_clients.db-num:
      if first-of(buf_Clients.db-num) then do:
        find first buf_temp-smart-route no-lock where
              buf_temp-smart-route.key-field = p-d-card
          and buf_temp-smart-route.db-num = buf_clients.db-num
              no-error.
        if available buf_temp-smart-route then return. /*уже отработали один раз по данной карте*/
        create buf_temp-smart-route.
        assign
        buf_temp-smart-route.key-field = p-d-card
        buf_temp-smart-route.db-num = buf_clients.db-num
        .
        if buf_clients.db-num = g#db-num then do:
          v-current-db-processed = yes.
        end.
      end. /*if first-of (buf_clients.db-num) then do:*/
    end. /*for each buf_dis-obj no-lock where*/
    if not v-current-db-processed then do:
      find first buf_temp-smart-route no-lock where
            buf_temp-smart-route.key-field = p-d-card
        and buf_temp-smart-route.db-num = g#db-num  no-error.
      if not available buf_temp-smart-route then do:
        create buf_temp-smart-route.
        assign
        buf_temp-smart-route.key-field = p-d-card
        buf_temp-smart-route.db-num = g#db-num
        .
      end.
    end.
  end.

end procedure. /* get-db-list-for-dis-obj */


&endif

&if "{1}" <> "rul" &then
procedure dis-objh_send-nws :
define parameter buffer buf_c-dis-obj for ub.c-dis-obj.
define parameter buffer buf_c-dc-hist for ub.c-dc-hist.
define variable v-dh-hn as logical no-undo .

main-block:
do
on error undo, return error return-value
:

  if g#news
  and g#db-num > 0
  and buf_c-dis-obj.corr-user-db-num <> g#db-num
  then return.

  if not g#news
  or (g#news
      and ( g#db-num > 0 )
      and buf_c-dis-obj.corr-user-name = {&nts-user}
      )   /*из УБД - записи рожденные СПН*/
  then do:
    run str/callnews.p (
      input {&table_c-dis-obj}
      ,input (buffer buf_c-dis-obj:handle)
      ) no-error .
    if error-status:error then do:
      undo main-block,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) ).
    end.
    run str/callnews.p (
      input {&table_c-dc-hist}
      ,input (buffer buf_c-dc-hist:handle)
      ) no-error .
    if error-status:error then do:
      undo main-block,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) ).
    end.
  end.
end.

end procedure. /* dis-hsth_send-nws */
&endif

&endif

/* $Workfile$ e n d */