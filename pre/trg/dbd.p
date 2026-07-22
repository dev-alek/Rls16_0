block-level on error undo, throw.
trigger procedure for delete of ub.db .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи базы данных".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_db                for ub.db .
  define buffer buf_c-db              for ub.c-db .
  define buffer buf_sys-ctrl          for ub.sys-ctrl .
  define buffer buf-shop_clients      for ub.clients .
  define buffer buf-store_clients     for ub.clients .
  define buffer buf_cash-desk         for ub.cash-desk .
  define buffer buf_code-range        for ub.code-range .
  define buffer buf_schedule          for ub.schedule .
  define buffer buf_schedule-attr     for ub.schedule-attr .
  define buffer buf_prod-bc-db        for ub.prod-bc-db .
  define buffer buf_ext-file          for ub.ext-file .
  define buffer buf_ext-file-line     for ub.ext-file-line .
  define buffer buf_ext-file-par      for ub.ext-file-par .
  define buffer buf_db-rec-attr       for ub.db-rec-attr .
  define buffer buf_nws-doc-hist      for ub.nws-doc-hist .
  define buffer buf_pck-sent          for ub.pck-sent .
  define buffer buf_pck-rcvd          for ub.pck-rcvd .
  define buffer buf_route             for ub.route .
  define buffer buf_db-status         for ub.db-status .
  define buffer buf_upgrade           for ub.upgrade .
  define buffer buf_db-attr           for ub.db-attr .
  define buffer buf_hist-nws-option   for ub.hist-nws-option.
  define buffer buf_c-hist-nws-option for ub.c-hist-nws-option.
  define variable v-date    as date      no-undo .
  define variable v-time    as integer   no-undo .
  define variable v-db-num  as integer   no-undo .
  define variable v-msg     as logical   no-undo .
  define variable v-message as character no-undo .
  define variable v-db-list as character no-undo .
  define temp-table tt_range-stts no-undo
    field range-type like ub.code-range.range-type
    field first-code like ub.code-range.first-code
    field stts       like ub.code-range.stts
  .
  define variable v-action  as character no-undo .
  define variable v-counter as integer   no-undo .
  define variable v-mod     as integer   no-undo .
  define frame inf
    v-action  label "Таблица" format "X(50)" skip
    v-counter label "Записей" format ">>>>>>>>>9"
    with view-as dialog-box side-labels 1 columns three-d title "Удаление БД".
  find first buf_sys-ctrl no-lock .
  assign
    v-db-num = ub.db.db-num
  .
  if g#news = false then do:
    assign
      v-msg = true
    .
    if buf_sys-ctrl.db-num <> 0 then do:
      assign
        v-message = "Удаление БД может проводиться только в ГБД!!!"
      .
      if v-msg = true then do:
        message
          v-message
          view-as alert-box error.
      end.
      return error v-message .
    end.
  end.
  if v-db-num = 0 then do:
    assign
      v-message = "Нельзя удалить ГБД !!!"
    .
    if v-msg = true then do:
      message
        v-message
        view-as alert-box error.
    end.
    return error v-message .
  end.
  find first buf-shop_clients no-lock
    where buf-shop_clients.db-num   = v-db-num
      and buf-shop_clients.obj-type = 'маг':U
    no-error
  .
  find first buf-store_clients no-lock
    where buf-store_clients.db-num   = v-db-num
      and buf-store_clients.obj-type = 'скл':U
    no-error
  .
  if available buf-shop_clients
    or available buf-store_clients
  then do:
    assign
      v-message = substitute( "Есть объекты привязаные к БД &1. &2Нельзя удалить БД.", v-db-num, chr(10) )
    .
    if v-msg = true then do:
      message
        v-message
        view-as alert-box error .
    end.
    return error v-message .
  end.
  find first buf_cash-desk no-lock
    where buf_cash-desk.db-num = v-db-num
    no-error .
  if available buf_cash-desk then do:
    assign
      v-message = substitute( "Есть кассы привязаные к БД &1. &2Нельзя удалить БД.", v-db-num, chr(10) )
    .
    if v-msg = true then do:
      message
        v-message
        view-as alert-box error .
    end.
    return error v-message .
  end.
  view frame inf .
  assign
    v-counter = 0
    v-action  = "Создание записи истории"
    v-mod     = 5
  .
  run cur-time in this-procedure
    ( output v-date
    , output v-time
    ).
  create buf_c-db.
  buffer-copy ub.db to buf_c-db .
  assign
    buf_c-db.action           = integer('99':U)
    buf_c-db.chip-num         = dynamic-next-value ( "s-db-chip", "ub")
    buf_c-db.corr-time        = v-time
    buf_c-db.corr-date        = v-date
    buf_c-db.corr-user-db-num = buf_sys-ctrl.db-num
    buf_c-db.corr-user-name   = (if g#news = true then "СПН" else g#userid )
  .
  if trim( buf_c-db.corr-user-name ) = "":U then do:
    assign
      buf_c-db.corr-user-name = userid( "ub":U )
    .
  end.
  assign
    v-counter = 0
    v-action  = "Перепривязка диапазонов кодов"
    v-mod     = 5
  .
  for each tt_range-stts
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    delete tt_range-stts .
  end.
  for each buf_code-range exclusive-lock
    where buf_code-range.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    create tt_range-stts.
    assign
      tt_range-stts.range-type = buf_code-range.range-type
      tt_range-stts.first-code = buf_code-range.first-code
      tt_range-stts.stts       = buf_code-range.stts
      buf_code-range.stts      = "X->0":U
      buf_code-range.db-num    = 0
    .
  end.
  for each tt_range-stts
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    find first buf_code-range exclusive-lock
      where buf_code-range.range-type = tt_range-stts.range-type
        and buf_code-range.first-code = tt_range-stts.first-code
    .
    if tt_range-stts.stts = "a":U then do:
      assign
        tt_range-stts.stts = "u":U
      .
    end.
    assign
      buf_code-range.stts = tt_range-stts.stts
    .
  end.
  for each tt_range-stts
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    delete tt_range-stts .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление строк расписания"
    v-mod     = 1
  .
  for each buf_schedule exclusive-lock
    where buf_schedule.cre-db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_schedule .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление строк атрибутов расписания"
    v-mod     = 1
  .
  for each buf_schedule-attr exclusive-lock
    where buf_schedule-attr.cre-db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_schedule-attr .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление бар-кодов по базе данных"
    v-mod     = 5
  .
  for each buf_prod-bc-db exclusive-lock
    where buf_prod-bc-db.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_prod-bc-db .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление информации из внешних файлов"
    v-mod     = 5
  .
  for each buf_ext-file exclusive-lock
    where buf_ext-file.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    for each buf_ext-file-line exclusive-lock
      where buf_ext-file-line.db-num = buf_ext-file.db-num
        and buf_ext-file-line.from-db-num = buf_ext-file.from-db-num
        and buf_ext-file-line.file-num = buf_ext-file.file-num
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      delete buf_Ext-file-line.
    end.
    for each buf_ext-file-par exclusive-lock
      where buf_ext-file-par.db-num = buf_ext-file.db-num
        and buf_ext-file-par.from-db-num = buf_ext-file.from-db-num
        and buf_ext-file-par.file-num = buf_ext-file.file-num
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      delete buf_Ext-file-par.
    end.
    delete buf_ext-file .
  end.
  for each buf_ext-file exclusive-lock
    where buf_ext-file.from-db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    for each buf_ext-file-line exclusive-lock
      where buf_ext-file-line.db-num = buf_ext-file.db-num
        and buf_ext-file-line.from-db-num = buf_ext-file.from-db-num
        and buf_ext-file-line.file-num = buf_ext-file.file-num
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      delete buf_Ext-file-line.
    end.
    for each buf_ext-file-par exclusive-lock
      where buf_ext-file-par.db-num = buf_ext-file.db-num
        and buf_ext-file-par.from-db-num = buf_ext-file.from-db-num
        and buf_ext-file-par.file-num = buf_ext-file.file-num
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      delete buf_Ext-file-par.
    end.
    delete buf_ext-file .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление строк информации из внешних файлов"
    v-mod     = 5
  .
  for each buf_ext-file-line exclusive-lock
    where buf_ext-file-line.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_ext-file-line .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление настроек записей истории и маршрутизации"
    v-mod     = 5
  .
  on delete of ub.hist-nws-option override do: end.
  for each buf_hist-nws-option exclusive-lock
    where buf_hist-nws-option.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_hist-nws-option .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление истории изменения настроек записей истории и маршрутизации"
    v-mod     = 5
  .
  on delete of ub.c-hist-nws-option override do: end.
  for each buf_c-hist-nws-option exclusive-lock
    where buf_c-hist-nws-option.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_c-hist-nws-option .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление записей в таблице для распределения блокировки"
    v-mod     = 5
  .
  for each buf_db-rec-attr exclusive-lock
    where buf_db-rec-attr.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_db-rec-attr .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление истории по документам, пришедшим по новостям"
    v-mod     = 5
  .
  for each buf_nws-doc-hist exclusive-lock
    where buf_nws-doc-hist.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_nws-doc-hist .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление записей состояния БД"
    v-mod     = 1
  .
  for each buf_db-status exclusive-lock
    where buf_db-status.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_db-status .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление записей upgrade"
    v-mod     = 5
  .
  for each buf_upgrade exclusive-lock
    where buf_upgrade.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_upgrade .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление атрибутов БД"
    v-mod     = 5
  .
  for each buf_db-attr exclusive-lock
    where buf_db-attr.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_db-attr .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление подтверждений отправленных пакетов"
    v-mod     = 5
  .
  for each buf_pck-sent exclusive-lock
    where buf_pck-sent.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_pck-sent .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление подтверждений полученных пакетов"
    v-mod     = 5
  .
  for each buf_pck-rcvd exclusive-lock
    where buf_pck-rcvd.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_pck-rcvd .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление маршрутизации СПН по БД"
    v-mod     = 5
  .
  for each buf_route exclusive-lock
    where buf_route.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
    delete buf_route.
  end.
  assign
    v-counter = 0
    v-action  = "Отправка в СПН информации об удалении БД"
    v-mod     = 1
  .
  assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
  run nws/cmd-del.p
    ( input 'db':U
     ,input (buffer ub.db:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    assign
      v-message = substitute( "&1. Ошибка при отправке в новости команды на удаление записи БД. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( error-status :num-messages ) )
    .
    if v-msg = true then do:
      message
        v-message
        view-as alert-box error.
    end.
    return error v-message .
  end.
  assign
    v-counter = 0
    v-action  = "Отправка в систему OpenXML информации об удалении БД"
    v-mod     = 1
  .
  assign v-counter = v-counter + 1 .    if ( v-counter MODULO v-mod ) = 0 then do:       do with frame inf       :         assign           v-action :screen-value  = string( v-action, v-action :format)           v-counter :screen-value = string( v-counter, v-counter :format)         .       end.     end.
  if g#oxml = yes then do:
    run str/calloxml.p (
          input 'delete':U
        , input 'db':U
        , input ( buffer ub.db:handle )
    ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4", chr(10), vss-workfile, return-value, error-status :get-message ( 1 ) ).
    end.
  end.
  hide frame inf .
end.
