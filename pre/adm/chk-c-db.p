block-level on error undo, throw.
define input parameter p-action      as   character    no-undo .
define input parameter p-db-num      like ub.db.db-num no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: chk-c-db.p $":U .
def var vss-archive     as character no-undo init "$Archive: adm/chk-c-db.p $":U .
def var vss-description as character no-undo init "Проверка корректности копии БД и ее подготовка".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
do
on error  undo, return error substitute("&1. error &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
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
  if db-copy.sys-ctrl.status_ = 'copy-DB':U
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
                                  ,chr(10)
                                  ,db-copy.db-rec-attr.attr-code
                                  ,db-copy.db-rec-attr.uniq-key-rec
                                  ,p-db-num
                                ).
      end.
    end.
  end.
  if p-action = "prep":U then do:
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
    on error  undo, return error substitute("&1. error &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on endkey undo, return error substitute("&1. endkey")
    on stop   undo, return error substitute("&1. stop")
    :
      find first db-orig.sys-ctrl exclusive-lock .
      find first db-copy.sys-ctrl exclusive-lock .
      assign
        db-orig.sys-ctrl.CopyDate    = v-copy-date
        db-orig.sys-ctrl.CopyTimeInt = v-copy-time
        db-orig.sys-ctrl.CopyTime    = string( v-copy-time, "HH:MM:SS" )
        db-copy.sys-ctrl.status_     = 'copy-DB':U
        db-copy.sys-ctrl.CopyDate    = db-orig.sys-ctrl.CopyDate
        db-copy.sys-ctrl.CopyTimeInt = db-orig.sys-ctrl.CopyTimeInt
        db-copy.sys-ctrl.CopyTime    = db-orig.sys-ctrl.CopyTime
      .
      for each db-copy.db no-lock
      on error undo, return error
      :
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf2_db    for db-copy.db .
define buffer buf2_route for db-copy.route .
define variable v-msg#2    as character no-undo .
define variable v-lock#2   as logical   no-undo .
define variable v-ok#2     as logical   no-undo .
find first buf2_db no-lock
  where buf2_db.db-num = db-copy.db.db-num
  no-error
.
if not available buf2_db then do:
  message
    vss-include-info2 skip
    vss-workfile vss-revision vss-description skip
    substitute( "Попытка создать маршрутизацию на несуществующую БД &1", db-copy.db.db-num ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .
end.
if "db-copy":U <> "ub":U
   or ( trim( buf2_db.db-key ) <> "":U
        and buf2_db.db-key <> ?
      )
then do:
    disable triggers for load of db-copy.route .
  create buf2_route .
  assign
    buf2_route.last-pack    = -1
    buf2_route.name-rec     = 'begins_unload_from_copy':U
    buf2_route.db-num       = db-copy.db.db-num
    buf2_route.uniq-key-rec = '':U
    buf2_route.num-dump     = 0
    buf2_route.tbl-ord      = dynamic-next-value( "s-news-ord":U, "db-copy":U )
    .
    assign
      buf2_route.dump-ord = dynamic-next-value( "s-news-dord":U, "db-copy":U )
    .
    assign
      buf2_route.CreDate      = db-copy.sys-ctrl.CopyDate
    .
    assign
      buf2_route.CreTimeInt   = db-copy.sys-ctrl.CopyTimeInt
      buf2_route.CreTime      = string(db-copy.sys-ctrl.CopyTimeInt,"HH:MM:SS":U)
    .
    assign
      buf2_route.CreUserName  = 'prep_copy':U
    .
end.
else do:
define variable vss-include-info3 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_lock-route in g#lib-nws
  ( input  'check'
  , input  db-copy.db.db-num
  , input  0
  , input  ''
  , output v-msg#2
  , output v-lock#2
  , output v-ok#2
  ) no-error .
  if error-status :error
    or v-lock#2 = true
    or v-ok#2   = false
  then do:
    return error substitute( "&1. Маршрутизация записи &2.&3Ключ записи: &4&3&3"
                             ,vss-include-info2
                             ,'begins_unload_from_copy':U
                             ,chr(10)
                             ,'':U
                           )
                + substitute( "&1&2&2&3&2&2&4"
                              ,v-msg#2
                              ,chr(10)
                              ,return-value
                              ,error-status :get-message( error-status :num-messages )
                            ) .
  end.
end.
      end.
    end.
  end.
  if p-db-num <> ? then do:
    do transaction
    on error  undo, return error substitute("&1. error &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
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
    end.
  end.
  hide frame inf.
end.
