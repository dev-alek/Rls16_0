block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись скидок до типу ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/25/06
Author: Bakhtadze Natalya
Creation date: 12/25/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.dis-dct-rule OLD old_dis-dct-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись скидок до типу ДК".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                              ,ub.dis-dct-rule.emitent-host-code
                              ,ub.dis-dct-rule.type
                             , ub.dis-dct-rule.host-code
                              ,ub.dis-dct-rule.obj-type
                              ,ub.dis-dct-rule.obj-code
                              ,ub.dis-dct-rule.pos-type
                              ,ub.dis-dct-rule.discnt-role
                              ,ub.dis-dct-rule.nonunique
                              )" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-dis-card-type for ub.c-dis-card-type.
define buffer buf_c-dis-dct-rule for ub.c-dis-dct-rule.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  and ( g#db-num > 0 )
  and (ub.dis-dct-rule.obj-code = 0
  or ub.dis-dct-rule.host-code = 0)
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя изменять запись глобальных СКИДОК НА ТИПЫ ДК или СКИДОК НА ТИПЫ ДК по фирме в УБД" skip
    view-as alert-box error .
    undo main-block, return error .
  end.
  if not g#news
  and ( g#db-num > 0 )
  and ub.dis-dct-rule.obj-code > 0 then do:
    define variable v-objdb-num as integer no-undo .
    { gbl/objdbnum.i ub.dis-dct-rule.obj-type ub.dis-dct-rule.obj-code v-objdb-num }
    if v-objdb-num <> g#db-num then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя изменять запись СКИДОК НА ТИПЫ ДИСКОНТНЫХ КАРТ в чужой УБД" skip
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.
  run cur-time in this-procedure ( output v-date, output v-time).
  create buf_c-dis-dct-rule.
  buffer-copy old_dis-dct-rule to buf_c-dis-dct-rule
  assign
  buf_c-dis-dct-rule.emitent-host-code    = ub.dis-dct-rule.emitent-host-code
  buf_c-dis-dct-rule.pos-type             = ub.dis-dct-rule.pos-type
  buf_c-dis-dct-rule.discnt-role          = ub.dis-dct-rule.discnt-role
  buf_c-dis-dct-rule.type                 = ub.dis-dct-rule.type
  buf_c-dis-dct-rule.host-code            = ub.dis-dct-rule.host-code
  buf_c-dis-dct-rule.obj-type             = ub.dis-dct-rule.obj-type
  buf_c-dis-dct-rule.obj-code             = ub.dis-dct-rule.obj-code
  buf_c-dis-dct-rule.nonunique            = ub.dis-dct-rule.nonunique
  buf_c-dis-dct-rule.chip-num           = next-value (s-dc-chip, {&db-name_schema})
  buf_c-dis-dct-rule.corr-time          = v-time
  buf_c-dis-dct-rule.corr-user-db-num   = g#db-num
  buf_c-dis-dct-rule.corr-user-name     = g#userid
  buf_c-dis-dct-rule.corr-date          = v-date
  .

  create buf_c-dis-card-type.
  buffer-copy buf_c-dis-dct-rule to buf_c-dis-card-type
  assign
  buf_c-dis-card-type.action = (if new ub.dis-dct-rule then integer({&hn-create}) else integer({&hn-update}))
  buf_c-dis-card-type.subject = {&table_dis-dct-rule}
  .
  /*

  все идет через cmd-bush.p.
  run str/callnews.p
    (input {&table_dis-dct-rule}
    ,input (buffer ub.dis-dct-rule:handle)
    ).
  */
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_dis-dct-rule}
        , input ( buffer ub.dis-dct-rule:handle )
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