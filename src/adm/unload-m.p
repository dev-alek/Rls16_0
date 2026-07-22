block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: unload-m.p $
$Archive: adm/unload-m.p $

Начальный этап выгрузки УБД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

define input parameter p-db-num like ub.db.db-num no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: unload-m.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/unload-m.p $":U .
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

  define temp-table t_db no-undo like ub.db .

  define variable v-db-num      like ub.db.db-num     no-undo .
  define variable v-db-key      like ub.db.db-key     no-undo .
  define variable v-db-key-enc  like ub.db.db-key-enc no-undo .
  define variable v-answer      as   logical          no-undo .
  define variable v-type-unload as   character        no-undo .
  define variable v-recid       as   recid            no-undo .
  define variable v-err         as   character        no-undo .
  define variable v-unload-history as logical no-undo .

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
    where buf-new_db.db-num = p-db-num
  .

  run adm/lock-db.p
    ( input p-db-num
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
  buffer-copy buf-new_db to t_db .

  do transaction
  on error  undo, return error
  on stop   undo, return error
  on endkey undo, return error
  :
    run adm/dbi.w
      ( input "unld"
       ,input-output v-recid
       ,output v-unload-history
      ).
    if v-recid = ? then do:
      buffer-copy t_db to buf-new_db .
      return error.
    end.
    /* перечитаем для верности */
    find first buf-new_db
      where buf-new_db.db-num = p-db-num
    .
    assign
      v-db-key     = buf-new_db.db-key
      v-db-key-enc = buf-new_db.db-key-enc
    .
    run db-attr-write ( input p-db-num
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

  run adm/add-db.w ( input  v-db-num
               ,output v-type-unload
              ) no-error.
  if error-status:error
    or v-type-unload = ?
  then do:
    do transaction
    on error undo, return error
    :
      buffer-copy t_db to buf-new_db .
      run del-db-key ( input v-db-key ).
    end.
    message
      vss-workfile vss-revision vss-description skip
      substitute( "УБД &1 не создана", v-db-num ) skip
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
    return error.
  end.

  run adm/rest-rdb.p
    ( input v-db-num
     ,input v-db-key
     ,input v-db-key-enc
     ,input v-type-unload
     ,input v-unload-history
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
        ( input p-db-num
        ,input "unload_db":U
        ,buffer buf-new_db
        ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка при разблокировке БД" ) skip
          return-value skip
          error-status :get-message ( error-status :num-messages )
          view-as alert-box error
        .
        return error .
      end.
      if return-value = "not-create":U then do:
        message
          "Отказ от выгрузки УБД" skip
          "База данных" v-db-num skip
          view-as alert-box information
        .
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при выгрузке таблиц БД" skip
          "База данных" v-db-num skip
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
    return error.
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
    return error .
  end.

  find first buf-new_db
    where buf-new_db.db-num = p-db-num
  .

  if v-db-key <> "":U
    and buf-new_db.db-key = v-db-key
  then do:
    run str/callnews.p ( input {&table_db}
                   ,input (buffer buf-new_db:handle )
                  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при отправке новостей о выгруженной БД" skip
        "База данных" v-db-num skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error
      .
      return error.
    end.
  end.

end.

/* $Workfile: unload-m.p $ end */