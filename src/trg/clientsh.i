/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры записи истории по clients

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/26/04
Author: Bakhtadze Natalya
Creation date: 01/26/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ nws/lib-nws.i }

&if "{1}" = "trig" &then

procedure clientsh_write-clients-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-cli-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-cli-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-clients for ub.c-clients.


  do
  on error undo, return error
  :
    if g#news then do:
      define variable v-send as integer no-undo .
      define variable v-subject as character no-undo .
      case {2}.obj-type:
        when {&cmp} then v-subject =  {&table_firm}.
        when {&prs} then v-subject =  {&table_person}.
        when {&shop} then v-subject =  {&table_shop}.
        when {&stock} then v-subject =  {&table_store}.
      end case.
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      v-subject
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
    create buf_c-clients.
    buffer-copy {2} to buf_c-clients
    assign
    buf_c-clients.obj-code           = {3}.obj-code
    buf_c-clients.obj-type           = {3}.obj-type
    buf_c-clients.chip-num           = next-value (s-cli-chip, {&db-name_schema})
    buf_c-clients.corr-time          = v-time
    buf_c-clients.corr-user-db-num   = g#db-num
    buf_c-clients.corr-user-name     = (if g#news then {&nts-user} else g#userid)
    buf_c-clients.corr-date          = v-date
    .
    create buf_c-cli-hist.
    buffer-copy buf_c-clients to buf_c-cli-hist
    assign
    buf_c-cli-hist.action =  (if p-new-record
                              then integer({&hn-create})
                              else integer({&hn-update}))
    buf_c-cli-hist.subject = {&table_clients}
    buf_c-cli-hist.host-code = (if {3}.obj-type = {&cmp}
                                and
                                can-find(first ub.sysconf no-lock where
                                                  ub.sysconf.host-code = {3}.obj-code)
                                then {3}.obj-code
                                else 0)
    buf_c-cli-hist.is-news = g#news
    buf_c-cli-hist.source-type = p-source-type
    buf_c-cli-hist.source-ref = p-source-ref
    .
    release buf_c-clients no-error .
    if error-status:error then do:
      undo , return error return-value .
    end.

    release buf_c-cli-hist no-error .
    if error-status:error then do:
      undo , return error return-value .
    end.

  end.

end procedure. /* write-clients-hist */

&endif

&if "{1}" = "" &then

procedure clientsh_write-clients-proc  :
define parameter buffer buf_clients for ub.clients .
define input parameter p-source-type like ub.c-cli-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-cli-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-clients for ub.c-clients.


  do
  on error undo, return error
  :
    if not available buf_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определен контрагент" skip
        view-as alert-box error .
      undo, return error .
    end.
    if g#news then do:
      define variable v-send as integer no-undo .
      define variable v-subject as character no-undo .
      case buf_clients.obj-type:
        when {&cmp} then v-subject =  {&table_firm}.
        when {&prs} then v-subject =  {&table_person}.
        when {&shop} then v-subject =  {&table_shop}.
        when {&stock} then v-subject =  {&table_store}.
      end case.
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      v-subject
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
    create buf_c-clients.
    buffer-copy buf_clients to buf_c-clients
    assign
    buf_c-clients.obj-code           = buf_clients.obj-code
    buf_c-clients.obj-type           = buf_clients.obj-type
    buf_c-clients.chip-num           = next-value (s-cli-chip, {&db-name_schema})
    buf_c-clients.corr-time          = v-time
    buf_c-clients.corr-user-db-num   = g#db-num
    buf_c-clients.corr-user-name     = (if g#news
                                        then {&nts-user}
                                        else (if g#esys
                                              then {&esys-user}
                                              else g#userid)
                                        )
    buf_c-clients.corr-date          = v-date
    .
    create buf_c-cli-hist.
    buffer-copy buf_c-clients to buf_c-cli-hist
    assign
    buf_c-cli-hist.action =  integer({&hn-update})
    buf_c-cli-hist.subject = {&table_clients}
    buf_c-cli-hist.host-code = (if buf_clients.obj-type = {&cmp}
                                and
                                can-find(first ub.sysconf no-lock where
                                                  ub.sysconf.host-code = buf_clients.obj-code)
                                then buf_clients.obj-code
                                else 0)
    buf_c-cli-hist.is-news = g#news
    buf_c-cli-hist.source-type = p-source-type
    buf_c-cli-hist.source-ref = p-source-ref
    .

  end.

end procedure. /* write-clients-hist */

&endif

&if "{1}" = "rul" &then

procedure clientsh_write-clients-rul  :
define parameter buffer buf_clients for ub.clients .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-clients for ub.c-clients.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.


do
on error undo, return error
:
  if not available buf_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определен клиент" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = {&table_clients}
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
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
    buf_temp-hist-nws-option.table-name = {&table_clients}
    buf_temp-hist-nws-option.key#_one = 2
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
  create buf_c-clients.
  buffer-copy buf_clients to buf_c-clients
  assign
  buf_c-clients.obj-type           = buf_clients.obj-type
  buf_c-clients.obj-code           = buf_clients.obj-code
  buf_c-clients.chip-num           = next-value (s-cli-chip, {&db-name_schema})
  buf_c-clients.corr-time          = v-time
  buf_c-clients.corr-user-db-num   = g#db-num
  buf_c-clients.corr-user-name     = (if g#news
                                      then {&nts-user}
                                      else (if g#esys
                                           then {&esys-user}
                                           else g#userid)
                                     )
  buf_c-clients.corr-date          = v-date
  .
  create buf_c-cli-hist.
  buffer-copy buf_c-clients to buf_c-cli-hist
  assign
  buf_c-cli-hist.action =  p-action
  buf_c-cli-hist.host-code = 0
  buf_c-cli-hist.subject = {&table_clients}
  buf_c-cli-hist.is-news = g#news
  buf_c-cli-hist.source-type = p-doc-type
  buf_c-cli-hist.source-ref = (if p-doc-type = '':U
                               then '':U
                               else p-doc-code)
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    &scop table__ {&table_c-clients}
    &scop buffer-handle buffer buf_c-clients:handle
    &scop rec-ord v-rec-ord2
    &scop action__ '+update'
    &scop gate-rec '':U

    {&add-dump-ext}.

    &scop table__ {&table_c-cli-hist}
    &scop buffer-handle buffer buf_c-cli-hist:handle
    &scop rec-ord v-rec-ord3
    &scop action__ '+update'
    &scop gate-rec '':U

    {&add-dump-ext}.
    if g#db-num = 0 then do:
      run create-smart-route-link in this-procedure ( input {&table_c-clients}
                                                    ,input buffer buf_c-clients:handle
                                                    ,input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                                    ,input v-rec-ord2
                                                    ,input no
                                                    ).

      run create-smart-route-link in this-procedure ( input {&table_c-cli-hist}
                                                    ,input buffer buf_c-cli-hist:handle
                                                    ,input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                                    ,input v-rec-ord3
                                                    ,input no
                                                    ).

      run create-smart-route in this-procedure  ( input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                                ,input -1).
    end.
  end.
end.

end procedure. /* clientsh_write-clients-rul  */

procedure clientsh_send-clients-rul  :
define parameter buffer buf_clients for ub.clients .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-clients for ub.c-clients.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.


do
on error undo, return error
:
  if not available buf_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определен клиент" skip
      view-as alert-box error .
    undo, return error .
  end.
  &scop table__ {&table_clients}
  &scop buffer-handle buffer buf_clients:handle
  &scop rec-ord v-rec-ord1
  &scop action__ '+update'
  &scop gate-rec '':U

  {&add-dump-ext}.

  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = {&table_clients}
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
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
    buf_temp-hist-nws-option.table-name = {&table_clients}
    buf_temp-hist-nws-option.smart-nws = integer({&hn-is-off})
    .
    { gbl/get-hnr.i
      g#db-num
      "buffer buf_temp-hist-nws-option:handle"
      }
  end.
  run create-smart-route-link in this-procedure ( input {&table_clients}
                                                ,input buffer buf_clients:handle
                                                ,input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                                ,input v-rec-ord1
                                                ,input no
                                                ).

  run create-smart-route in this-procedure  ( input (buf_clients.obj-type + string(buf_Clients.obj-code))
                                              ,input -1).
end.

end procedure. /* clientsh_send-clients-rul  */

procedure clientsh_write-firm-rul  :
define parameter buffer buf_firm for ub.firm .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-firm for ub.c-firm.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.


do
on error undo, return error
:
  if not available buf_firm then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена организация" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = {&table_firm}
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
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
    buf_temp-hist-nws-option.table-name = {&table_firm}
    buf_temp-hist-nws-option.key#_one = 2
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
  create buf_c-firm.
  buffer-copy buf_firm to buf_c-firm
  assign
  buf_c-firm.firm-code          = buf_firm.firm-code
  buf_c-firm.chip-num           = next-value (s-cli-chip, {&db-name_schema})
  buf_c-firm.corr-time          = v-time
  buf_c-firm.corr-user-db-num   = g#db-num
  buf_c-firm.corr-user-name     = (if g#news
                                      then {&nts-user}
                                      else (if g#esys
                                           then {&esys-user}
                                           else g#userid)
                                     )
  buf_c-firm.corr-date          = v-date
  .
  create buf_c-cli-hist.
  buffer-copy buf_c-firm to buf_c-cli-hist
  assign
  buf_c-cli-hist.action =  p-action
  buf_c-cli-hist.host-code = 0
  buf_c-cli-hist.subject = {&table_firm}
  buf_c-cli-hist.is-news = g#news
  buf_c-cli-hist.source-type = {&hn-source-trn-doc}
  buf_c-cli-hist.source-ref = p-doc-code
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    &scop table__ {&table_c-firm}
    &scop buffer-handle buffer buf_c-firm:handle
    &scop rec-ord v-rec-ord2
    &scop action__ '+update'
    &scop gate-rec '':U

    {&add-dump-ext}.

    &scop table__ {&table_c-cli-hist}
    &scop buffer-handle buffer buf_c-cli-hist:handle
    &scop rec-ord v-rec-ord3
    &scop gate-rec '':U

    {&add-dump-ext}.
    if g#db-num = 0 then do:
      run create-smart-route-link in this-procedure ( input {&table_c-firm}
                                                    ,input buffer buf_c-firm:handle
                                                    ,input string(buf_firm.firm-code)
                                                    ,input v-rec-ord2
                                                    ,input no
                                                    ).

      run create-smart-route-link in this-procedure ( input {&table_c-cli-hist}
                                                    ,input buffer buf_c-cli-hist:handle
                                                    ,input ({&cmp} + string(buf_firm.firm-code))
                                                    ,input v-rec-ord3
                                                    ,input no
                                                    ).

      run create-smart-route in this-procedure  ( input ({&cmp} + string(buf_firm.firm-code))
                                                ,input -1).
    end.
  end.
end.

end procedure. /* clientsh_write-firm-rul  */

procedure clientsh_send-firm-rul  :
define parameter buffer buf_firm for ub.firm.
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-firm for ub.c-firm.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.


do
on error undo, return error
:
  if not available buf_firm then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определен клиент" skip
      view-as alert-box error .
    undo, return error .
  end.
  &scop table__ {&table_firm}
  &scop buffer-handle buffer buf_firm:handle
  &scop rec-ord v-rec-ord1
  &scop action__ '+update'
  &scop gate-rec '':U

  {&add-dump-ext}.

  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = {&table_firm}
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
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
    buf_temp-hist-nws-option.table-name = {&table_firm}
    buf_temp-hist-nws-option.smart-nws = integer({&hn-is-off})
    .
    { gbl/get-hnr.i
      g#db-num
      "buffer buf_temp-hist-nws-option:handle"
      }
  end.
  run create-smart-route-link in this-procedure ( input {&table_firm}
                                                ,input buffer buf_firm:handle
                                                ,input ({&cmp} + string(buf_firm.firm-code))
                                                ,input v-rec-ord1
                                                ,input no
                                                ).

  run create-smart-route in this-procedure  ( input ({&cmp} + string(buf_firm.firm-code))
                                              ,input -1).
end.

end procedure. /* clientsh_send-firm-rul  */

procedure clientsh_write-person-rul  :
define parameter buffer buf_person for ub.person .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-person for ub.c-person.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.


do
on error undo, return error
:
  if not available buf_person then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определена организация" skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = {&table_person}
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
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
    buf_temp-hist-nws-option.table-name = {&table_person}
    buf_temp-hist-nws-option.key#_one = 2
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
  create buf_c-person.
  buffer-copy buf_person to buf_c-person
  assign
  buf_c-person.psn-code           = buf_person.psn-code
  buf_c-person.chip-num           = next-value (s-cli-chip, {&db-name_schema})
  buf_c-person.corr-time          = v-time
  buf_c-person.corr-user-db-num   = g#db-num
  buf_c-person.corr-user-name     = (if g#news
                                      then {&nts-user}
                                      else (if g#esys
                                           then {&esys-user}
                                           else g#userid)
                                     )
  buf_c-person.corr-date          = v-date
  .
  create buf_c-cli-hist.
  buffer-copy buf_c-person to buf_c-cli-hist
  assign
  buf_c-cli-hist.action =  p-action
  buf_c-cli-hist.host-code = 0
  buf_c-cli-hist.subject = {&table_person}
  buf_c-cli-hist.is-news = g#news
  buf_c-cli-hist.source-type = {&hn-source-trn-doc}
  buf_c-cli-hist.source-ref = p-doc-code
  .
  if g#db-num > 0
  or (g#db-num = 0
      and buf_temp-hist-nws-option.hist-to-nws >= 0)
  then do:
    &scop table__ {&table_c-person}
    &scop buffer-handle buffer buf_c-person:handle
    &scop rec-ord v-rec-ord2
    &scop action__ '+update'
    &scop gate-rec '':U

    {&add-dump-ext}.

    &scop table__ {&table_c-cli-hist}
    &scop buffer-handle buffer buf_c-cli-hist:handle
    &scop rec-ord v-rec-ord3
    &scop action__ '+update'
    &scop gate-rec '':U

    {&add-dump-ext}.
    if g#db-num = 0 then do:
      run create-smart-route-link in this-procedure ( input {&table_c-person}
                                                    ,input buffer buf_c-person:handle
                                                    ,input string(buf_person.psn-code)
                                                    ,input v-rec-ord2
                                                    ,input no
                                                    ).

      run create-smart-route-link in this-procedure ( input {&table_c-cli-hist}
                                                    ,input buffer buf_c-cli-hist:handle
                                                    ,input ({&cmp} + string(buf_person.psn-code))
                                                    ,input v-rec-ord3
                                                    ,input no
                                                    ).

      run create-smart-route in this-procedure  ( input ({&cmp} + string(buf_person.psn-code))
                                                ,input -1).
    end.
  end.
end.

end procedure. /* clientsh_write-person-rul  */

procedure clientsh_send-person-rul  :
define parameter buffer buf_person for ub.person.
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-rec-ord1 as integer no-undo .
define variable v-rec-ord2 as integer no-undo .
define variable v-rec-ord3 as integer no-undo .
define variable v-rec-hno as integer no-undo .
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-person for ub.c-person.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer last_temp-hist-nws-option for temp-hist-nws-option.


do
on error undo, return error
:
  if not available buf_person then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не определен клиент" skip
      view-as alert-box error .
    undo, return error .
  end.
  &scop table__ {&table_person}
  &scop buffer-handle buffer buf_person:handle
  &scop rec-ord v-rec-ord1
  &scop action__ '+update'
  &scop gate-rec '':U

  {&add-dump-ext}.

  find first buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.table-name = {&table_person}
        and buf_temp-hist-nws-option.db-num = g#db-num no-error .
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
    buf_temp-hist-nws-option.table-name = {&table_person}
    buf_temp-hist-nws-option.smart-nws = integer({&hn-is-off})
    .
    { gbl/get-hnr.i
      g#db-num
      "buffer buf_temp-hist-nws-option:handle"
      }
  end.
  run create-smart-route-link in this-procedure ( input {&table_person}
                                                ,input buffer buf_person:handle
                                                ,input ({&cmp} + string(buf_person.psn-code))
                                                ,input v-rec-ord1
                                                ,input no
                                                ).

  run create-smart-route in this-procedure  ( input ({&cmp} + string(buf_person.psn-code))
                                              ,input -1).
end.

end procedure. /* clientsh_send-person-rul  */

&endif




/* $Workfile$ e n d */