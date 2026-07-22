block-level on error undo, throw.
/*

$Revision: dcb9ba8c712c, 1662, rls $
$Author: SSlivenko $
$Date: Fri Nov 23 14:36:18 2018 +0300 $
$Workfile: unload-m2.p $
$Archive: adm/unload-m2.p $

Начальный этап выгрузки УБД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

define input parameter p-rec-list as longchar no-undo .

define variable vss-revision    as character no-undo init "$Revision: dcb9ba8c712c, 1662, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Fri Nov 23 14:36:18 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: unload-m2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/unload-m2.p $":U .
define variable vss-description as character no-undo init "Начальный этап выгрузки УБД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ adm/unloaddb.i }
{ adm/db-key.i   }
{ gbl/db-attr.i  }

do
on error  undo, return error
on stop   undo, return error
on endkey undo, return error
:
  define buffer buf-new_db for ub.db .
  
  define buffer buf_user-login      for ub.user-login .
  define buffer buf_sys-ctrl for ub.sys-ctrl .

  define temp-table t_db no-undo like ub.db .

  define temp-table unld_db no-undo like ub.db 
    field unload-hist as logical
    field dst-path  as character 
  .

  define variable v-db-num      like ub.db.db-num     no-undo .
  define variable v-db-key      like ub.db.db-key     no-undo .
  define variable v-db-key-enc  like ub.db.db-key-enc no-undo .
  define variable v-answer      as   logical          no-undo .
  define variable v-type-unload as   character        no-undo .
  define variable v-recid       as   recid            no-undo .
  define variable v-err         as   character        no-undo .
  define variable v-unload-history as logical no-undo .
  define variable v-dbs         as   integer          no-undo .
  define variable v-list        as   character        no-undo .
  define variable v-dst-path    as   character        no-undo .
  define variable v-create-adm  as logical      no-undo.
  define variable v-log  as logical   no-undo .

do v-dbs = 1 to num-entries (p-rec-list):
  v-list = entry(v-dbs, p-rec-list) no-error .

  run adm/unloaddc.p no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Не удалось отключить БД" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    return error .
  end.

  find first buf-new_db share-lock
    where recid(buf-new_db) = integer(v-list)
  .
  
  if buf-new_db.db-num = 0 then next .

  run adm/lock-db.p
    ( input buf-new_db.db-num
     ,input "unload_db":U
     ,buffer buf-new_db
    ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при блокировке БД" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    return error .
  end.

  assign
    v-db-num     = buf-new_db.db-num
    v-db-key     = "":U
    v-db-key-enc = "":U
    v-recid      = recid( buf-new_db )
  .
  create t_db .
  buffer-copy buf-new_db to t_db .

  do transaction
  on error  undo, return error
  on stop   undo, return error
  on endkey undo, return error
  :
    run adm/dbi-unld.w
      ( input "unld"
       ,input-output v-recid
       ,output v-unload-history
       ,output v-dst-path
      ).
    
    if v-recid = ? then do:
      buffer-copy t_db to buf-new_db .
      return error.
    end.
    /* перечитаем для верности */
    find first buf-new_db
      where buf-new_db.db-num = v-db-num
    .
    create unld_db .
    buffer-copy buf-new_db to unld_db 
    assign
      unld_db.unload-hist = v-unload-history 
      unld_db.dst-path = v-dst-path 
    .
    assign
      v-db-key     = buf-new_db.db-key
      v-db-key-enc = buf-new_db.db-key-enc
    .
    run db-attr-write ( input buf-new_db.db-num
                       ,input {&attr-last-unload-db-key}
                       ,input v-db-key
                      ) no-error.

    /* блокируем СПН для УБД */
    run nws/nws-stop.p
      ( input  "stop":U
       ,input  v-db-num
       ,output v-answer
      ) no-error .
    if error-status :error
      or v-answer = false
    then do:
      buffer-copy t_db to buf-new_db .
      run del-db-key ( input v-db-key ).
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Не удалось заблокировать СПН для БД &1", v-db-num ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
      return error.
    end.
  end.
end .


find first buf_sys-ctrl no-lock .

message
  "Мультивыгрузка УБД." skip
  "Все данные, не пришедшие в ГБД будут потеряны." skip
  "Продолжить?" skip
  view-as alert-box question buttons yes-no update v-log .
if not v-log then do:
  return "not-create":U .
end.

for each unld_db by unld_db.db-num :
  
  find first buf-new_db
    where buf-new_db.db-num = unld_db.db-num 
  .
  
  v-create-adm = false .
  
  FIND FIRST buf_user-login
       WHERE buf_user-login.db-num     = unld_db.db-num
         AND buf_user-login.user-login = "адм"
         and buf_user-login.status_    = {&uls-normal}
       no-lock
       no-error
       .
  IF NOT AVAILABLE buf_user-login
  THEN DO:
     ASSIGN
        v-create-adm = TRUE
     .
  end.
  
  create alias src for database ub no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании вымышленного имени src" ) skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    return error.
  end.
  
  connect value(unld_db.dst-path) -ld dst -U sysadm -P sysadm no-error.
  if not connected ("dst") then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Не могу соединиться с проинициированой целевой базой!" ) skip
      substitute( "БД &1. Целевая база данных &2. Пропускаем...", string(unld_db.db-num) ,unld_db.dst-path ) skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
/*    return error.*/
    next.
  end.

  run adm/init-db.p
    ( input unld_db.db-num
     ,input "dst":U
     ,input buf_sys-ctrl.language
     ,input buf_sys-ctrl.r-b
     ,input buf_sys-ctrl.sys-key
     ,input no
     ,input v-create-adm
     ,input 0
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при инициализации целевой УБД &1!", string(unld_db.db-num) ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    run adm/unloaddc.p no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Не удалось отключить БД" ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
    end.
    next .
  end.

  run adm/rest-rdb.p
    ( input unld_db.db-num
     ,input unld_db.db-key
     ,input unld_db.db-key-enc
     ,input ({&unload-online} + {&delim-par} + "yes")
     ,input unld_db.unload-hist
    ) no-error .
  if error-status :error
    or return-value = "not-create":U
  then do:
    assign
      v-err = error-status :get-message( error-status :num-messages ) + {&new-line} + return-value
    .
    do transaction
    on error undo, return error
    :
      run adm/lock-db.p
        ( input unld_db.db-num
        ,input "unload_db":U
        ,buffer buf-new_db
        ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка при разблокировке БД &1", string(unld_db.db-num) ) skip
          return-value skip
          error-status :get-message ( error-status :num-messages )
          view-as alert-box error
        .
        next .
      end.
      if return-value = "not-create":U then do:
        message
          "Отказ от выгрузки УБД" skip
          "База данных" unld_db.db-num skip
          view-as alert-box information
        .
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при выгрузке таблиц БД" skip
          "База данных" unld_db.db-num skip
          v-err skip
          view-as alert-box error
        .
      end.
    end.
    run adm/unloaddc.p no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Не удалось отключить БД" ) skip
        return-value skip
        error-status :get-message ( error-status :num-messages )
        view-as alert-box error
      .
    end.
    next.
  end.

  run adm/unloaddc.p no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Не удалось отключить БД" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    next .
  end.

  find first buf-new_db
    where buf-new_db.db-num = unld_db.db-num
  .

  if unld_db.db-key <> "":U
    and buf-new_db.db-key = unld_db.db-key
  then do:
    run str/callnews.p ( input {&table_db}
                   ,input (buffer buf-new_db:handle )
                  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при отправке новостей о выгруженной БД" skip
        "База данных" buf-new_db.db-num skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error
      .
      next.
    end.
  end.
end.

message
    "Перекачка успешно завершена."
    view-as alert-box information .

end.

/* $Workfile: unload-m2.p $ end */