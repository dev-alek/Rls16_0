block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись скидок по объектам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/11/06
Author: Bakhtadze Natalya
Creation date: 12/11/06

*/


TRIGGER PROCEDURE FOR WRITE OF ub.dis-thbj-rule old old_dis-thbj-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись скидок по объектам".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                        ,  ub.dis-thbj-rule.host-code
                        ,  ub.dis-thbj-rule.obj-type
                        ,  ub.dis-thbj-rule.obj-code
                        ,  ub.dis-thbj-rule.pos-type
                        ,  ub.dis-thbj-rule.discnt-role
                        ,  ub.dis-thbj-rule.nonunique
                        ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

define variable v-host-code as integer no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define buffer buf_c-dis-thbj-rule for ub.c-dis-thbj-rule.
define buffer buf_c-cli-hist for ub.c-cli-hist.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  and g#db-num > 0
  and (
      ub.dis-thbj-rule.obj-type  = '':U
      or
      ub.dis-thbj-rule.obj-code = 0
      or
      ub.dis-thbj-rule.host-code  = 0
      ) then do:
    message
    vss-workfile vss-revision vss-description skip
    substitute("&1&2 POS &3 тип скидки &4&5" +
               "Нельзя изменять запись СКИДОК ПО ОБЪЕКТАМ/ФИРМАМ в УБД"
               ,ub.dis-thbj-rule.obj-type
               ,ub.dis-thbj-rule.obj-code
               ,ub.dis-thbj-rule.pos-type
               ,ub.dis-thbj-rule.discnt-role)
    view-as alert-box error .
    undo main-block, return error .
  end.
  if not g#news
  and (ub.dis-thbj-rule.obj-type = {&shop}
  or ub.dis-thbj-rule.obj-type = {&stock}) then do:
    { gbl/objdbnum.i ub.dis-thbj-rule.obj-type ub.dis-thbj-rule.obj-code v-obj-db-num }
    if v-obj-db-num <> g#db-num
    and g#db-num <> 0 then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("&1&2 POS &3 тип скидки &4&5" +
                "Нельзя изменять запись СКИДОК ПО ОБЪЕКТАМ/ФИРМАМ в чужой БД"
               ,ub.dis-thbj-rule.obj-type
               ,ub.dis-thbj-rule.obj-code
               ,ub.dis-thbj-rule.pos-type
               ,ub.dis-thbj-rule.discnt-role)
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.
  run str/callnews.p
    ( input {&table_dis-thbj-rule}
      ,input (buffer ub.dis-thbj-rule:handle)
    ) .

  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    {&table_dis-thbj-rule}
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
  end.
  if not g#news
  or v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-thbj-rule.
    buffer-copy old_dis-thbj-rule
    except
    pos-type
    templ-rl-root
    host-code
    obj-type
    obj-code
    nonunique
    to buf_c-dis-thbj-rule
    assign
    buf_c-dis-thbj-rule.pos-type           = ub.dis-thbj-rule.pos-type
    buf_c-dis-thbj-rule.discnt-role        = ub.dis-thbj-rule.discnt-role
    buf_c-dis-thbj-rule.obj-type           = ub.dis-thbj-rule.obj-type
    buf_c-dis-thbj-rule.obj-code           = ub.dis-thbj-rule.obj-code
    buf_c-dis-thbj-rule.host-code          = ub.dis-thbj-rule.host-code
    buf_c-dis-thbj-rule.nonunique          = ub.dis-thbj-rule.nonunique
    buf_c-dis-thbj-rule.chip-num           = next-value (s-cli-chip, {&db-name_schema})
    buf_c-dis-thbj-rule.corr-time          = v-time
    buf_c-dis-thbj-rule.corr-user-db-num   = g#db-num
    buf_c-dis-thbj-rule.corr-user-name     = (if g#news
                                              then {&nts-user}
                                              else (if g#esys
                                                    then {&esys-user}
                                                    else g#userid
                                                    )
                                              )
    buf_c-dis-thbj-rule.corr-date          = v-date
    .
    if not (ub.dis-thbj-rule.obj-type = '':U
           and
           ub.dis-thbj-rule.obj-code = 0
           and
           ub.dis-thbj-rule.host-code = 0) then do:
      if ub.dis-thbj-rule.obj-type = {&shop}
      or ub.dis-thbj-rule.obj-type = {&stock} then do:
        { gbl/hostcode.i ub.dis-thbj-rule.obj-type ub.dis-thbj-rule.obj-code v-host-code }
        assign
        v-obj-type = ub.dis-thbj-rule.obj-type
        v-obj-code = ub.dis-thbj-rule.obj-code
        .
      end.
      if ub.dis-thbj-rule.obj-type = {&cmp} then do:
        assign
        v-obj-type = {&cmp}
        v-obj-code = ub.dis-thbj-rule.host-code
        v-host-code = ub.dis-thbj-rule.obj-code.
      end.
      create buf_c-cli-hist.
      buffer-copy buf_c-dis-thbj-rule
      except obj-type obj-code
      to buf_c-cli-hist
      assign
      buf_c-cli-hist.action = (if new (ub.dis-thbj-rule )
                              then integer({&hn-create})
                              else integer({&hn-update}))
      buf_c-cli-hist.subject = {&table_dis-thbj-rule}
      buf_c-cli-hist.obj-type = v-obj-type
      buf_c-cli-hist.obj-code = v-obj-code
      buf_c-cli-hist.host-code = v-host-code
      buf_c-cli-hist.is-news = g#news
      buf_c-cli-hist.source-type = (if g#news
                                    then {&hn-source-db}
                                    else (if g#esys
                                          then {&hn-source-esys}
                                          else "":U)
                                    )
      buf_c-cli-hist.source-ref = (if g#news
                                  then string(g#news-source-db)
                                  else (if g#esys
                                        then string(g#esys-source-esys)
                                        else "":U)
                                  )
      .
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_dis-thbj-rule}
        , input ( buffer ub.dis-thbj-rule:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.