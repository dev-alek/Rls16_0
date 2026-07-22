block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись скидки на группу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/18/07
Author: Bakhtadze Natalya
Creation date: 05/18/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.dis-grp-rule old old_dis-grp-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись скидки на группу".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&7|&8'
                        ,  ub.dis-grp-rule.classif-type
                        ,  ub.dis-grp-rule.node-code
                        ,  ub.dis-grp-rule.host-code
                        ,  ub.dis-grp-rule.obj-type
                        ,  ub.dis-grp-rule.obj-code
                        ,  ub.dis-grp-rule.pos-type
                        ,  ub.dis-grp-rule.templ-rl-root
                        ,  ub.dis-grp-rule.nonunique
                        ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define buffer buf_c-dis-grp-rule for ub.c-dis-grp-rule.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-sum-grp for ub.c-sum-grp.
define buffer buf_c-sum-grp-obj for ub.c-sum-grp-obj.
define buffer buf_c-cli-grp for ub.c-cli-grp.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news
  and g#db-num > 0
  and (
      ub.dis-grp-rule.obj-type  = '':U
      or
      ub.dis-grp-rule.obj-code = 0
      or
      ub.dis-grp-rule.host-code  = 0
      ) then do:
    message
    vss-workfile vss-revision vss-description skip
    substitute("Фирма &1 &2&3 POS &4 код шаблона &5&6" +
               "Нельзя изменять запись СКИДОК ПО ГРУППАМ в УБД"
               ,ub.dis-grp-rule.host-code
               ,ub.dis-grp-rule.obj-type
               ,ub.dis-grp-rule.obj-code
               ,ub.dis-grp-rule.pos-type
               ,ub.dis-grp-rule.templ-rl-root
               ,{&new-line}
               )
    view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.dis-grp-rule.obj-type = {&shop}
  or ub.dis-grp-rule.obj-type = {&stock} then do:
    { gbl/objdbnum.i ub.dis-grp-rule.obj-type ub.dis-grp-rule.obj-code v-obj-db-num }
    if v-obj-db-num <> g#db-num
    and g#db-num <> 0 then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("Фирма &1 &2&3 POS &4 код шаблона &5&6" +
                "Нельзя изменять запись СКИДОК ПО ГРУППАМ в чужой БД"
               ,ub.dis-grp-rule.host-code
               ,ub.dis-grp-rule.obj-type
               ,ub.dis-grp-rule.obj-code
               ,ub.dis-grp-rule.pos-type
               ,ub.dis-grp-rule.templ-rl-root
               ,{&new-line}
               )
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.
  run str/callnews.p
    ( input {&table_dis-grp-rule}
      ,input (buffer ub.dis-grp-rule:handle)
    ) .

  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    {&table_dis-grp-rule}
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
    create buf_c-dis-grp-rule.
    buffer-copy old_dis-grp-rule
    except
    pos-type
    templ-rl-root
    host-code
    obj-type
    obj-code
    nonunique
    to buf_c-dis-grp-rule
    assign
    buf_c-dis-grp-rule.obj-type           = ub.dis-grp-rule.obj-type
    buf_c-dis-grp-rule.obj-code           = ub.dis-grp-rule.obj-code
    buf_c-dis-grp-rule.host-code           = ub.dis-grp-rule.host-code
    buf_c-dis-grp-rule.pos-type           = ub.dis-grp-rule.pos-type
    buf_c-dis-grp-rule.templ-rl-root      = ub.dis-grp-rule.templ-rl-root
    buf_c-dis-grp-rule.node-code          = ub.dis-grp-rule.node-code
    buf_c-dis-grp-rule.nonunique          = ub.dis-grp-rule.nonunique
    buf_c-dis-grp-rule.classif-type       = ub.dis-grp-rule.classif-type
    buf_c-dis-grp-rule.discnt-role        = ub.dis-grp-rule.discnt-role
    buf_c-dis-grp-rule.corr-time          = v-time
    buf_c-dis-grp-rule.corr-user-db-num   = g#db-num
    buf_c-dis-grp-rule.corr-user-name     = (if g#news
                                             then {&nts-user}
                                             else (if g#esys
                                                   then {&esys-user}
                                                   else g#userid)
                                             )
    buf_c-dis-grp-rule.corr-date          = v-date
    .
    CASE buf_c-dis-grp-rule.classif-type:
      when {&table_cli-grp} then do:
        assign
        buf_c-dis-grp-rule.chip-num           = next-value (s-cli-grp-chip, {&db-name_schema})
        .
        create buf_c-cli-grp.
        buffer-copy buf_c-dis-grp-rule
        except obj-type obj-code
        to buf_c-cli-grp
        assign
        buf_c-cli-grp.action = (if new (ub.dis-grp-rule )
                                then integer({&hn-create})
                                else integer({&hn-update}))
        buf_c-cli-grp.subject = {&table_dis-grp-rule}
        buf_c-cli-grp.source-type = (if g#news
                                     then {&hn-source-db}
                                     else (if g#esys
                                           then {&hn-source-esys}
                                           else "":U)
                                    )
        buf_c-cli-grp.source-ref = (if g#news
                                     then string(g#news-source-db)
                                     else (if g#esys
                                           then string(g#esys-source-esys)
                                           else "":U)
                                     )
        .
      end.
      when {&table_gds-grp} then do:
        assign
        buf_c-dis-grp-rule.chip-num           = next-value (s-gds-grp-chip, {&db-name_schema})
        .
        create buf_c-gds-grp-hist.
        buffer-copy buf_c-dis-grp-rule
        except obj-type obj-code
        to buf_c-gds-grp-hist
        assign
        buf_c-gds-grp-hist.action = (if new (ub.dis-grp-rule )
                                then integer({&hn-create})
                                else integer({&hn-update}))
        buf_c-gds-grp-hist.subject = {&table_dis-grp-rule}
        buf_c-gds-grp-hist.obj-type = ub.dis-grp-rule.obj-type
        buf_c-gds-grp-hist.obj-code = ub.dis-grp-rule.obj-code
        buf_c-gds-grp-hist.host-code = ub.dis-grp-rule.host-code
        buf_c-gds-grp-hist.is-news = g#news
        buf_c-gds-grp-hist.source-type = (if g#news
                                     then {&hn-source-db}
                                     else (if g#esys
                                           then {&hn-source-esys}
                                           else "":U)
                                    )
        buf_c-gds-grp-hist.source-ref = (if g#news
                                     then string(g#news-source-db)
                                     else (if g#esys
                                           then string(g#esys-source-esys)
                                           else "":U)
                                     )
        .
      end.
      when {&table_sum-grp} then do:
        assign
        buf_c-dis-grp-rule.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
        .
        create buf_c-sum-grp.
        buffer-copy buf_c-dis-grp-rule
        except obj-type obj-code
        to buf_c-sum-grp
        assign
        buf_c-sum-grp.grp-code    = ub.dis-grp-rule.node-code
        buf_c-sum-grp.action = (if new (ub.dis-grp-rule )
                                then integer({&hn-create})
                                else integer({&hn-update}))
        buf_c-sum-grp.subject = {&table_sum-grp}
        .
      end.
      when {&table_sum-grp-obj} then do:
        assign
        buf_c-dis-grp-rule.chip-num           = next-value (s-ref-obj-corr-chip, {&db-name_schema})
        .
        create buf_c-sum-grp-obj.
        buffer-copy buf_c-dis-grp-rule
        except obj-type obj-code
        to buf_c-sum-grp-obj
        assign
        buf_c-sum-grp-obj.grp-code    = ub.dis-grp-rule.node-code
        buf_c-sum-grp-obj.obj-type = ub.dis-grp-rule.obj-type
        buf_c-sum-grp-obj.obj-code = ub.dis-grp-rule.obj-code
        buf_c-sum-grp-obj.action = (if new (ub.dis-grp-rule )
                                then integer({&hn-create})
                                else integer({&hn-update}))
        buf_c-sum-grp-obj.subject = {&table_dis-grp-rule}
        .
      end.


    end case.
  end. /*if not g#news*/
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_dis-grp-rule}
        , input ( buffer ub.dis-grp-rule:handle )
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