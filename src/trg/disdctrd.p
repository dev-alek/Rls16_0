block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удалении скидок по типам ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/25/06
Author: Bakhtadze Natalya
Creation date: 12/25/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.dis-dct-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удалении скидок по типам ДК".
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


  run cur-time in this-procedure ( output v-date, output v-time).
  create buf_c-dis-dct-rule.
  buffer-copy ub.dis-dct-rule to buf_c-dis-dct-rule
  assign
  buf_c-dis-dct-rule.chip-num           = next-value (s-dc-chip, {&db-name_schema})
  buf_c-dis-dct-rule.corr-time          = v-time
  buf_c-dis-dct-rule.corr-user-db-num   = g#db-num
  buf_c-dis-dct-rule.corr-user-name     = g#userid
  buf_c-dis-dct-rule.corr-date          = v-date
  .

  create buf_c-dis-card-type.
  buffer-copy buf_c-dis-dct-rule to buf_c-dis-card-type
  assign
  buf_c-dis-card-type.action = integer({&hn-delete})
  buf_c-dis-card-type.subject = {&table_dis-dct-rule}
  .

  /*
  все идет через cmd-bush.p
  run nws/cmd-del.p
    ( input {&table_dis-dct-rule}
     ,input (buffer ub.dis-dct-rule:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
  */

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_dis-dct-rule}
        , input ( buffer ub.dis-dct-rule:handle )
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