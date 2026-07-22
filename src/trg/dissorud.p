block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление привязки правила скидки к ресурсу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/25/07
Author: Bakhtadze Natalya
Creation date: 05/25/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.dis-some-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление привязки правила скидки к ресурсу".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                        ,  ub.dis-some-rule.classif-type
                        ,  ub.dis-some-rule.resource#_id
                        ,  ub.dis-some-rule.host-code
                        ,  ub.dis-some-rule.obj-type
                        ,  ub.dis-some-rule.obj-code
                        ,  ub.dis-some-rule.pos-type
                        ,  ub.dis-some-rule.discnt-role
                        ,  ub.dis-some-rule.nonunique
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
define buffer buf_c-dis-some-rule for ub.c-dis-some-rule.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  and g#db-num > 0
  and (
      ub.dis-some-rule.obj-type  = '':U
      or
      ub.dis-some-rule.obj-code = 0
      or
      ub.dis-some-rule.host-code  = 0
      ) then do:
    message
    vss-workfile vss-revision vss-description skip
    substitute("Фирма &1 &2&3 место использования &4 тип скидки &5&6" +
               "Нельзя удалять запись СКИДОК в УБД"
               ,ub.dis-some-rule.host-code
               ,ub.dis-some-rule.obj-type
               ,ub.dis-some-rule.obj-code
               ,ub.dis-some-rule.pos-type
               ,ub.dis-some-rule.discnt-role
               , {&new-line}
               )
    view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.dis-some-rule.obj-type = {&shop}
  or ub.dis-some-rule.obj-type = {&stock} then do:
    { gbl/objdbnum.i ub.dis-some-rule.obj-type ub.dis-some-rule.obj-code v-obj-db-num }
    if v-obj-db-num <> g#db-num
    and g#db-num <> 0 then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("Фирма &1 &2&3 место использ. &4 тип скидки &5&6" +
                "Нельзя удалять запись СКИДОК в чужой БД"
               ,ub.dis-some-rule.host-code
               ,ub.dis-some-rule.obj-type
               ,ub.dis-some-rule.obj-code
               ,ub.dis-some-rule.pos-type
               ,ub.dis-some-rule.discnt-role
               , {&new-line}
               )
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.
  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    {&table_dis-some-rule}
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
    create buf_c-dis-some-rule.
    buffer-copy ub.dis-some-rule
    to buf_c-dis-some-rule
    assign
    buf_c-dis-some-rule.chip-num           = next-value (s-cli-chip, {&db-name_schema})
    buf_c-dis-some-rule.corr-time          = v-time
    buf_c-dis-some-rule.corr-user-db-num   = g#db-num
    buf_c-dis-some-rule.corr-user-name     = (if g#news
                                              then {&nts-user}
                                              else (if g#esys
                                                    then {&esys-user}
                                                    else g#userid)
                                              )
    buf_c-dis-some-rule.corr-date          = v-date
    .
    CASE buf_c-dis-some-rule.classif-type:
    END CASE.
  end. /*if not g#news*/
  run nws/cmd-del.p
    ( input {&table_dis-some-rule}
      ,input (buffer ub.dis-some-rule:handle)
      ,input "":U
    ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_dis-some-rule}
        , input ( buffer ub.dis-some-rule:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.