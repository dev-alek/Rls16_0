block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись опции истории и маршрутизации

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/29/06
Author: Bakhtadze Natalya
Creation date: 10/29/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.hist-nws-option OLD old_hist-nws-option.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись опции истории и маршрутизации".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable glog as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-error-add as logical no-undo .
define buffer buf0_hist-nws-option for ub.hist-nws-option.
define buffer buf_c-hist-nws-option for ub.c-hist-nws-option.
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer buf_c-Dis-card-type for ub.c-dis-card-type.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#db-num > 0
  and new(ub.hist-nws-option)
  and not g#news then do:
    /*нельзя добавлять новые записи в УБД потому что у нас пвседо первичный ключ - если добавить одновременно в УБД
    и ГБД окажется две записи на одну сущность
    в УБД можно только редактировать
    */
    if ub.hist-nws-option.db-num <> g#db-num then do:
      message
      vss-workfile vss-revision vss-description skip
      "В УБД нельзя добавлять новые записи в Таблицу НАСТРОЕК записи истории и маршрутизации для чужих БД"
      view-as alert-box error .
      undo main-block, return error .
    end.
    find first buf0_hist-nws-option no-lock where
              buf0_hist-nws-option.db-num = 0
         and  buf0_hist-nws-option.hn-id = ub.hist-nws-option.hn-id no-error.
    if not available buf0_hist-nws-option then do:
      v-error-add = yes.
    end.
    else do:
      buffer-compare
      buf0_hist-nws-option
      except
      db-num
      get-hist-from-nws
      hist-from-prim
      hist-to-nws
      nws-to-cd
      nws-to-hist
      smart-nws
      to ub.hist-nws-option
      case-sensitive
      save result in glog.
      if not glog then do:
        v-error-add = yes.
      end.
    end.
    if v-error-add then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("В УБД можно добавлять новые записи в Таблицу НАСТРОЕК записи истории и маршрутизации,&1" +
                 "ТОЛЬКО для текущей БД и если они отличаются от записей в ГБД ТОЛЬКО номером БД"
                 , {&new-line})
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.
  buffer-compare
  ub.hist-nws-option to old_hist-nws-option
  case-sensitive
  save result in glog.

  if not g#news
  or (g#db-num > 0 and ub.hist-nws-option.db-num = g#db-num) then do:
    if not (glog and not new(ub.hist-nws-option))
    and ub.hist-nws-option.subject-group <> {&table_c-dc-hist}
    then do:
/*      run str/callnews.p                                                  */
/*        (input {&table_hist-nws-option}                                   */
/*        ,input (buffer ub.hist-nws-option:handle)                         */
/*        ) no-error .                                                      */
/*      if error-status :error then do:                                     */
/*        message                                                           */
/*          vss-workfile vss-revision vss-description skip                  */
/*          "Невозможно маршрутизировать запись для отправки в новости" skip*/
/*          error-status :get-message(1) skip                               */
/*          return-value skip                                               */
/*          view-as alert-box error .                                       */
/*        undo main-block,  return error .                                  */
/*      end.                                                                */
    end.
  end.
  define variable v-cmp as logical no-undo .
  if not new(ub.hist-nws-option) then do:
    buffer-compare ub.hist-nws-option
    to old_hist-nws-option
    case-sensitive
    save result in v-cmp.
  end.
  else do:
    v-cmp = no.
  end.
  if not v-cmp then do:
    if ub.hist-nws-option.subject-group <> {&table_c-dc-hist}
    or ub.hist-nws-option.db-num = 0 then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      create buf_c-hist-nws-option.
      buffer-copy old_hist-nws-option
      except hn-id
      to buf_c-hist-nws-option
      assign
      buf_c-hist-nws-option.hn-id = ub.hist-nws-option.hn-id
      buf_c-hist-nws-option.db-num = ub.hist-nws-option.db-num
      buf_c-hist-nws-option.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
      buf_c-hist-nws-option.corr-time          = v-time
      buf_c-hist-nws-option.corr-user-db-num   = g#db-num
      buf_c-hist-nws-option.corr-user-name     = g#userid
      buf_c-hist-nws-option.corr-date          = v-today
      .
      if buf_c-hist-nws-option.subject-group = {&table_c-dc-hist} then do:
        create buf_c-dis-card-type.
        assign
        buf_c-dis-card-type.type = buf_c-hist-nws-option.charkey_one
        buf_c-dis-card-type.emitent-host-code = buf_c-hist-nws-option.host-code
        buf_c-dis-card-type.subject = {&table_hist-nws-option}
        buf_c-dis-card-type.corr-user-db-num = buf_c-hist-nws-option.corr-user-db-num
        buf_c-dis-card-type.chip-num = next-value (s-dc-chip, {&db-name_schema})
        buf_c-dis-card-type.corr-time          = buf_c-hist-nws-option.corr-time
        buf_c-dis-card-type.corr-user-db-num   = buf_c-hist-nws-option.corr-user-db-num
        buf_c-dis-card-type.corr-user-name     = buf_c-hist-nws-option.corr-user-name
        buf_c-dis-card-type.corr-date          = buf_c-hist-nws-option.corr-date
        buf_c-dis-card-type.action             = (if new ub.hist-nws-option then integer({&hn-create}) else integer({&hn-update}))
        .
        create buf_c-table-bind.
        assign
        buf_c-table-bind.chip-num-rec   = buf_c-dis-card-type.chip-num
        buf_c-table-bind.chip-num-src   = buf_c-hist-nws-option.chip-num
        buf_c-table-bind.corr-user-db-num     = buf_c-hist-nws-option.corr-user-db-num
        buf_c-table-bind.tbl-name-rec   = {&table_c-dis-card-type}
        buf_c-table-bind.tbl-name-src   = {&table_c-hist-nws-option}
        buf_c-table-bind.is-news         = g#news
        buf_c-table-bind.corr-user-name  = g#userid
        .
      end.
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_hist-nws-option}
        , input ( buffer ub.hist-nws-option:handle )
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