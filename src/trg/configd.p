block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление конфигурации

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/18/00
Author: Dmitry Ukhanov
Creation date: 11/18/00

*/

TRIGGER PROCEDURE FOR DELETE OF ub.config.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление конфигурации".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo main-block, return error substitute("&1. endkey")
on stop   undo main-block, return error substitute("&1. stop")
:
  define variable v-date        as date      no-undo .
  define variable v-time        as integer   no-undo .
  define variable v-num-entries as integer   no-undo .
  define variable v-msg         as logical   no-undo .
  define variable v-message     as character no-undo .
  define variable v-send-db     as character no-undo .

  define buffer buf_c-config for ub.c-config .
  define buffer buf_sys-ctrl for ub.sys-ctrl .

  find first buf_sys-ctrl no-lock .

  if g#news = false
  then do:
    assign
      v-msg = true
    .
  end.

  if ub.config.stts <> -1
  then do:
    if lookup( ub.config.conf-type, {&cnf-type-list-mandatory} ) > 0
    then do:
      /* обязательный параметр или конфигурация */
      assign
        v-message = substitute( "Обязательный параметр или параметр конфигурации не может быть удален !" )
      .
      if v-msg = true then do:
        message
          v-message
          view-as alert-box error.
      end.
      return error v-message .
    end.
  end.

  if  ub.config.db-num = g#db-num
  and lookup(ub.config.conf-type, {&cnf-type-list-protect}) > 0
  then do:
    /* конфигурация изменилась */
    /* помечаем текущее меню, как требующее перезагрузки */
    run gbl/menu-clr.p
      (input {&menu-code-main} /* p-menu-code */
      ) .

    /* помечаем права, как требующие перезагрузки */
    run gbl/actn-clr.p
      (input {&action-head-code-main} /* p-action-head-code */
      ) .
  end.

  /* пишем историю */
  run cur-time in this-procedure
    ( output v-date
     ,output v-time
    ).
  create buf_c-config.
  buffer-copy ub.config to buf_c-config
    assign
      buf_c-config.stts             = 0
      buf_c-config.chip-num         = next-value (s-cfg-chip, {&db-name_schema})
      buf_c-config.corr-time        = v-time
      buf_c-config.corr-date        = v-date
      buf_c-config.corr-user-db-num = buf_sys-ctrl.db-num
      buf_c-config.corr-user-name   = g#userid
      buf_c-config.action           = integer({&hn-delete})
  .

  assign
    v-send-db = ""
  .

  if buf_sys-ctrl.db-num = 0
  then do:
    if ub.config.db-num > 0
    then do:
      assign
        v-send-db = string( ub.config.db-num )
      .
    end.
  end.
  else do:
    if g#news = false
    then do:
      assign
        v-send-db = "0":U
      .
    end.
  end.
  if v-send-db <> "":U
  then do:
    run nws/cmd-del.p
      ( input "config":U
      ,input (buffer ub.config:handle)
      ,input v-send-db
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при отправке в новости команды на удаление параметра конфигурации. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) )
      .
      if v-msg = true
      then do:
        message
          v-message
          view-as alert-box error.
      end.
      return error v-message .
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_config}
        , input ( buffer ub.config:handle )
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