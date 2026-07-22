block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chk-c-db.p $
$Archive: adm/chk-c-db.p $

проверка корректности копии БД и ее подготовка

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/02
Author: Dmitry Ukhanov
Creation date: 03/22/02

*/

define input parameter p-action      as   character    no-undo .
define input parameter p-db-num      like ub.db.db-num no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: chk-c-db.p $":U .
def var vss-archive     as character no-undo init "$Archive: adm/chk-c-db.p $":U .
def var vss-description as character no-undo init "Проверка корректности копии БД и ее подготовка".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i  }

do
on error  undo, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo, return error substitute("&1. endkey")
on stop   undo, return error substitute("&1. stop")
:
  define variable v-compare-log as logical no-undo .

  define variable v-copy-date as date      no-undo .
  define variable v-copy-time as integer   no-undo .

  define variable v-action    as character no-undo .
  define variable v-ind       as integer   no-undo .

  define variable v-compare   as logical   no-undo .

  define frame inf
    v-action label "Проверка соответствия" format "X(50)":U SKIP
    v-ind    label "Просмотрено записей" AT 3
    with view-as dialog-box SIDE-LABELS three-d title "Проверка корректности копии БД" SIZE 80 BY 3.5 .

  if transaction then do:
    message
      vss-workfile vss-revision vss-description skip
      "Вызов данной процедуры в транзакции недопустим" skip
      view-as alert-box error .
  end.

  if not connected( "db-copy":U ) then do:
    return error substitute( "&1. Копия БД не подключена!", vss-workfile ).
  end.

  view frame inf.

  /* проверка корректности копии */

  assign
    v-action = "даты последней архивации, номеров и ключей БД"
    v-ind    = 0
  .
  do with frame inf
  :
    assign
      v-action :screen-value   = string( v-action, v-action :format)
      v-ind :screen-value      = string( v-ind, v-ind :format)
    .
  end.

  find first db-orig.sys-ctrl share-lock .
  find first db-copy.sys-ctrl share-lock .

  if db-orig.sys-ctrl.db-num <> db-copy.sys-ctrl.db-num then do:
    return error substitute( "&1. Копия ГБД не корректна! Отличаются номера БД.", vss-workfile ).
  end.
  if db-orig.sys-ctrl.cut-date <> db-copy.sys-ctrl.cut-date then do:
    return error substitute( "&1. Копия ГБД не корректна! Отличается дата последней архивации.", vss-workfile ).
  end.
  find first db-orig.db share-lock
    where db-orig.db.db-num = db-orig.sys-ctrl.db-num
  .
  find first db-copy.db share-lock
    where db-copy.db.db-num = db-orig.db.db-num
    no-error
  .
  if not available db-copy.db
    or db-copy.db.db-key <> db-orig.db.db-key
  then do:
    return error substitute( "&1. Копия ГБД не корректна! Отличаются ключи ГБД.", vss-workfile ).
  end.

  assign
    v-action = "даты и времени создания копии БД"
    v-ind    = 0
  .
  do with frame inf
  :
    assign
      v-action :screen-value   = string( v-action, v-action :format)
      v-ind :screen-value      = string( v-ind, v-ind :format)
    .
  end.
  if db-copy.sys-ctrl.status_ = {&sttsDB-copy}
    and ( db-orig.sys-ctrl.CopyDate <> db-copy.sys-ctrl.CopyDate
          or db-orig.sys-ctrl.CopyTimeInt <> db-copy.sys-ctrl.CopyTimeInt
        )
  then do:
    return error substitute( "&1. Копия ГБД не корректна! Отличаются дата и(или) время копирования.", vss-workfile ).
  end.

  assign
    v-action = "пакетов в исходной БД пакетам в копии БД"
    v-ind    = 0
  .
  for each db-orig.pck-sent share-lock
    where db-orig.pck-sent.rcvd = true
  on error undo, return error
  :
    if p-db-num <> ?
      and db-orig.pck-sent.db-num <> p-db-num
    then do:
      next.
    end.
    assign
      v-ind = v-ind + 1
    .
    do with frame inf
    :
      assign
        v-action :screen-value   = string( v-action, v-action :format)
        v-ind :screen-value      = string( v-ind, v-ind :format)
      .
    end.
    find first db-copy.pck-sent share-lock
      where db-copy.pck-sent.db-num   = db-orig.pck-sent.db-num
        and db-copy.pck-sent.pack-num = db-orig.pck-sent.pack-num
      no-error .
    if not available db-copy.pck-sent
      or db-orig.pck-sent.CRC-pack <> db-copy.pck-sent.CRC-pack
    then do:
      return error substitute( "&1. Копия ГБД не корректна! Найдены отличия в пакетах новостей. Пакет &2", vss-workfile, db-orig.pck-sent.pack-num ).
    end.
  end.
  assign
    v-action = "пакетов копии БД пакетам в исходной БД"
    v-ind    = 0
  .
  for each db-copy.pck-sent share-lock
  on error undo, return error
  :
    if p-db-num <> ?
      and db-copy.pck-sent.db-num <> p-db-num
    then do:
      next.
    end.
    assign
      v-ind = v-ind + 1
    .
    do with frame inf
    :
      assign
        v-action :screen-value   = string( v-action, v-action :format)
        v-ind :screen-value      = string( v-ind, v-ind :format)
      .
    end.
    find first db-orig.pck-sent share-lock
      where db-orig.pck-sent.db-num   = db-copy.pck-sent.db-num
        and db-orig.pck-sent.pack-num = db-copy.pck-sent.pack-num
      no-error .
    if not available db-orig.pck-sent
      or db-orig.pck-sent.CRC-pack <> db-copy.pck-sent.CRC-pack
    then do:
      return error substitute( "&1. Копия ГБД не корректна! Найдены отличия в пакетах новостей. Пакет &2", vss-workfile, db-copy.pck-sent.pack-num ).
    end.
  end.

  assign
    v-action = "объектов в исходной БД объектам в копии БД"
    v-ind    = 0
  .
  for each db-orig.db share-lock
  on error undo, return error
  :
    if p-db-num <> ?
      and db-orig.db.db-num <> p-db-num
    then do:
      next.
    end.
    for each db-orig.clients share-lock
      where db-orig.clients.db-num = db-orig.db.db-num
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      do with frame inf
      :
        assign
          v-action :screen-value   = string( v-action, v-action :format)
          v-ind :screen-value      = string( v-ind, v-ind :format)
        .
      end.
      find first db-copy.clients share-lock
        where db-copy.clients.obj-type = db-orig.clients.obj-type
          and db-copy.clients.obj-code = db-orig.clients.obj-code
        no-error .
      if not available db-copy.clients
        or db-orig.clients.db-num <> db-copy.clients.db-num
      then do:
        return error substitute( "&1. Копия ГБД не корректна! Клиенты привязаны к разным БД (клиент в исходной &2 &3).", vss-workfile, db-orig.clients.obj-type, db-orig.clients.obj-code ).
      end.
    end.
  end.

  assign
    v-action = "объектов в копии БД объектам в исходной БД"
    v-ind    = 0
  .
  for each db-copy.db share-lock
  on error undo, return error
  :
    if p-db-num <> ?
      and db-copy.db.db-num <> p-db-num
    then do:
      next.
    end.
    for each db-copy.clients share-lock
      where db-copy.clients.db-num = db-copy.db.db-num
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      do with frame inf
      :
        assign
          v-action :screen-value   = string( v-action, v-action :format)
          v-ind :screen-value      = string( v-ind, v-ind :format)
        .
      end.
      find first db-orig.clients share-lock
        where db-orig.clients.obj-type = db-copy.clients.obj-type
          and db-orig.clients.obj-code = db-copy.clients.obj-code
        no-error .
      if not available db-orig.clients
        or db-copy.clients.db-num <> db-orig.clients.db-num
      then do:
        return error substitute( "&1. Копия ГБД не корректна! Клиенты привязаны к разным БД (клиент в копии &2 &3).", vss-workfile, db-copy.clients.obj-type, db-copy.clients.obj-code ).
      end.
    end.
  end.

  assign
    v-action = "информации в копии о текущем состоянии БД"
    v-ind    = 0
  .
  for each db-copy.db-status share-lock
    where db-copy.db-status.db-num > 0
  on error undo, return error
  :
    if p-db-num <> ?
      and db-copy.db-status.db-num <> p-db-num
    then do:
      next.
    end.
    assign
      v-ind = v-ind + 1
    .
    do with frame inf
    :
      assign
        v-action :screen-value   = string( v-action, v-action :format)
        v-ind :screen-value      = string( v-ind, v-ind :format)
      .
    end.
    find first db-orig.db-status share-lock
      where db-orig.db-status.db-num = db-copy.db-status.db-num
      no-error .
    if not available db-orig.db-status then do:
      return error substitute( "&1. Копия ГБД не корректна! В исходной БД отсутствует в информации о текущем состоянии БД &2", vss-workfile, db-copy.db-status.db-num ).
    end.
    else do:
      buffer-compare db-copy.db-status to db-orig.db-status save result in v-compare no-error.
      if not v-compare then do:
        return error substitute( "&1. Копия ГБД не корректна! Найдены отличия в информации о текущем состоянии БД &2"
                                  ,vss-workfile
                                  ,db-copy.db-status.db-num
                                ).
      end.
    end.
  end.

  assign
    v-action = "информации в исходной БД о текущем состоянии БД"
    v-ind    = 0
  .
  for each db-orig.db-status share-lock
    where db-orig.db-status.db-num > 0
  on error undo, return error
  :
    if p-db-num <> ?
      and db-orig.db-status.db-num <> p-db-num
    then do:
      next.
    end.
    assign
      v-ind = v-ind + 1
    .
    do with frame inf
    :
      assign
        v-action :screen-value   = string( v-action, v-action :format)
        v-ind :screen-value      = string( v-ind, v-ind :format)
      .
    end.
    find first db-copy.db-status share-lock
      where db-copy.db-status.db-num = db-orig.db-status.db-num
      no-error .
    if not available db-copy.db-status then do:
      return error substitute( "&1. Копия ГБД не корректна! В копии отсутствует в информации о текущем состоянии БД &2", vss-workfile, db-orig.db-status.db-num ).
    end.
    else do:
      buffer-compare db-orig.db-status to db-copy.db-status save result in v-compare no-error.
      if not v-compare then do:
        return error substitute( "&1. Копия ГБД не корректна! Найдены отличия в информации о текущем состоянии БД &2"
                                  ,vss-workfile
                                  ,db-orig.db-status.db-num
                                ).
      end.
    end.
  end.

  assign
    v-action = "диапазонов кодов исходной БД диапазонам в копии БД"
    v-ind    = 0
  .
  for each db-orig.code-range share-lock
  on error undo, return error
  :
    if p-db-num <> ?
      and db-orig.code-range.db-num <> p-db-num
    then do:
      next.
    end.
    assign
      v-ind = v-ind + 1
    .
    do with frame inf
    :
      assign
        v-action :screen-value   = string( v-action, v-action :format)
        v-ind :screen-value      = string( v-ind, v-ind :format)
      .
    end.
    find first db-copy.code-range share-lock
      where db-copy.code-range.range-type = db-orig.code-range.range-type
        and db-copy.code-range.first-code = db-orig.code-range.first-code
      no-error
    .
    if not available db-copy.code-range then do:
      return error substitute( "&1. Копия ГБД не корректна! Найдены отличия в диапазонах кодов. Диапазон &2 &3", vss-workfile, db-orig.code-range.range-type, db-orig.code-range.first-code ).
    end.
  end.
  assign
    v-action = "диапазонов кодов копии БД диапазонам в исходной БД"
    v-ind    = 0
  .
  for each db-copy.code-range share-lock
  on error undo, return error
  :
    if p-db-num <> ?
      and db-copy.code-range.db-num <> p-db-num
    then do:
      next.
    end.
    assign
      v-ind = v-ind + 1
    .
    do with frame inf
    :
      assign
        v-action :screen-value   = string( v-action, v-action :format)
        v-ind :screen-value      = string( v-ind, v-ind :format)
      .
    end.
    find first db-orig.code-range share-lock
      where db-orig.code-range.range-type = db-copy.code-range.range-type
        and db-orig.code-range.first-code = db-copy.code-range.first-code
      no-error
    .
    if not available db-orig.code-range then do:
      return error substitute( "&1. Копия ГБД не корректна! Найдены отличия в диапазонах кодов. Диапазон &2 &3", vss-workfile, db-copy.code-range.range-type, db-copy.code-range.first-code ).
    end.
  end.

  assign
    v-action = "распределенных команд СПН в копии БД командам в исходной БД"
    v-ind    = 0
  .
  for each db-copy.db-rec-attr share-lock
  on error undo, return error
  :
    if p-db-num <> ?
      and db-copy.db-rec-attr.db-num <> p-db-num
    then do:
      next.
    end.
    assign
      v-ind = v-ind + 1
    .
    do with frame inf
    :
      assign
        v-action :screen-value   = string( v-action, v-action :format)
        v-ind :screen-value      = string( v-ind, v-ind :format)
      .
    end.
    find first db-orig.db-rec-attr share-lock
      where db-orig.db-rec-attr.db-num       = db-copy.db-rec-attr.db-num
        and db-orig.db-rec-attr.uniq-key-rec = db-copy.db-rec-attr.uniq-key-rec
        and db-orig.db-rec-attr.attr-code    = db-copy.db-rec-attr.attr-code
      no-error
    .
    if not available db-orig.db-rec-attr then do:
      return error substitute( "&1. Копия ГБД не корректна! В исходной БД отсутствует распределенная команда &2 над записью &3 для БД &4"
                                ,vss-workfile
                                ,db-copy.db-rec-attr.attr-code
                                ,db-copy.db-rec-attr.uniq-key-rec
                                ,p-db-num
                              ).
    end.
    else do:
      buffer-compare db-copy.db-rec-attr
        except attr-value-logical attr-type
        to db-orig.db-rec-attr save result in v-compare no-error.

      if not v-compare then do:
        return error substitute( "&1. Копия ГБД не корректна! Найдены отличия в распределенных командах.&2Команда &3 над записью &4 для БД &5"
                                  ,vss-workfile
                                  ,{&new-line}
                                  ,db-copy.db-rec-attr.attr-code
                                  ,db-copy.db-rec-attr.uniq-key-rec
                                  ,p-db-num
                                ).
      end.
    end.
  end.

  if p-action = "prep":U then do:
    /* подготовка копии */
    assign
      v-action = "распределенных команд СПН в исходной БД командам в копии БД"
      v-ind = 0
    .
    for each db-orig.db-rec-attr share-lock
    on error undo, return error
    :
      if p-db-num <> ?
        and db-orig.db-rec-attr.db-num <> p-db-num
      then do:
        next.
      end.
      assign
        v-ind = v-ind + 1
      .
      do with frame inf
      :
        assign
          v-action :screen-value   = string( v-action, v-action :format)
          v-ind :screen-value      = string( v-ind, v-ind :format)
        .
      end.
      find first db-copy.db-rec-attr share-lock
        where db-copy.db-rec-attr.db-num       = db-orig.db-rec-attr.db-num
          and db-copy.db-rec-attr.uniq-key-rec = db-orig.db-rec-attr.uniq-key-rec
          and db-copy.db-rec-attr.attr-code    = db-orig.db-rec-attr.attr-code
        no-error
      .
      if not available db-copy.db-rec-attr then do:
        return error substitute( "&1. Копия ГБД не корректна! В копии отсутствует распределенная команда &2 над записью &3 для БД &4"
                                  ,vss-workfile
                                  ,db-orig.db-rec-attr.attr-code
                                  ,db-orig.db-rec-attr.uniq-key-rec
                                  ,p-db-num
                                ).
      end.
    end.

    run cur-time( output v-copy-date
                 ,output v-copy-time
                ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении текущей даты", vss-workfile ).
    end.

    do transaction
    on error  undo, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on endkey undo, return error substitute("&1. endkey")
    on stop   undo, return error substitute("&1. stop")
    :
      find first db-orig.sys-ctrl exclusive-lock .
      find first db-copy.sys-ctrl exclusive-lock .

      assign
        db-orig.sys-ctrl.CopyDate    = v-copy-date
        db-orig.sys-ctrl.CopyTimeInt = v-copy-time
        db-orig.sys-ctrl.CopyTime    = string( v-copy-time, "HH:MM:SS" )
        db-copy.sys-ctrl.status_     = {&sttsDB-copy}
        db-copy.sys-ctrl.CopyDate    = db-orig.sys-ctrl.CopyDate
        db-copy.sys-ctrl.CopyTimeInt = db-orig.sys-ctrl.CopyTimeInt
        db-copy.sys-ctrl.CopyTime    = db-orig.sys-ctrl.CopyTime
      .
      for each db-copy.db no-lock
      on error undo, return error
      :
        { nws/cr-rt.i
          &cr-rt-log-db-name=db-copy
          &name-rec="'begins_unload_from_copy'":U
          &db-num=db-copy.db.db-num
          &uniq-key-rec="''":U
          &num-dump=0
          &CreDate=db-copy.sys-ctrl.CopyDate
          &CreTimeInt=db-copy.sys-ctrl.CopyTimeInt
          &CreUserName="'prep_copy'":U
        }
      end.

    end.  /* transaction */
  end.

  if p-db-num <> ? then do:
    do transaction
    on error  undo, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on endkey undo, return error substitute("&1. endkey")
    on stop   undo, return error substitute("&1. stop")
    :

      find first db-orig.db exclusive-lock
        where db-orig.db.db-num = p-db-num
      .
      find first db-copy.db exclusive-lock
        where db-copy.db.db-num = p-db-num
      .

      if trim( db-orig.db.db-key ) = "":U
        or db-orig.db.db-key = ?
      then do:
        disable triggers for load of db-orig.db .
        disable triggers for load of db-copy.db .
        assign
          db-orig.db.db-key = "unload-db":U
          db-copy.db.db-key = "unload-db":U
        .
      end.
    end.  /* transaction */
  end.

  hide frame inf.

end.

/* $Workfile: chk-c-db.p $ end */