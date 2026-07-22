define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Пользователь системы".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
define temp-table UserDbAdm
field db-num as integer
field db-adm as logical
field db-usr as logical
field db-block as logical
index pi is unique db-num
index adm db-adm db-usr
.
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
procedure sys-time_get-sys :
  define output parameter p-year         as integer   no-undo .
  define output parameter p-month        as integer   no-undo .
  define output parameter p-day          as integer   no-undo .
  define output parameter p-hour         as integer   no-undo .
  define output parameter p-minute       as integer   no-undo .
  define output parameter p-second       as integer   no-undo .
  define output parameter p-milliseconds as integer   no-undo .
  define variable v-system-time-structure as memptr    no-undo.
  do
  on error undo, return error return-value
  :
    assign
      set-size(v-system-time-structure) = 16
    .
    run GetSystemTime
      (input  get-pointer-value(v-system-time-structure)
      ) .
    assign
      p-year         = get-short(v-system-time-structure,  1)
      p-month        = get-short(v-system-time-structure,  3)
      p-day          = get-short(v-system-time-structure,  7)
      p-hour         = get-short(v-system-time-structure,  9)
      p-minute       = get-short(v-system-time-structure, 11)
      p-second       = get-short(v-system-time-structure, 13)
      p-milliseconds = get-short(v-system-time-structure, 15)
    .
    assign
      set-size(v-system-time-structure) = 0
    .
  end.
end procedure.
procedure sys-time_get-comp-user-name :
  define output parameter p-computer-name as character no-undo .
  define output parameter p-user-name     as character no-undo .
  define output parameter p-process-pid   as integer   no-undo .
  define variable v-return-value  as integer   no-undo .
  define variable v-buffer-length as integer   no-undo .
  define variable v-buffer-memptr as memptr    no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-buffer-length = 1024
      set-size(v-buffer-memptr) = v-buffer-length + 4
    .
    assign
      put-long(v-buffer-memptr, 1) = v-buffer-length
    .
    run GetComputerNameA
      (input  get-pointer-value(v-buffer-memptr) + 4
      ,input  get-pointer-value(v-buffer-memptr)
      ,output v-return-value
      ) .
    if v-return-value <> 0
    then do:
      assign
        p-computer-name = get-string(v-buffer-memptr, 5)
      .
    end.
    assign
      put-long(v-buffer-memptr, 1) = v-buffer-length
    .
    run GetUserNameA
      (input  get-pointer-value(v-buffer-memptr) + 4
      ,input  get-pointer-value(v-buffer-memptr)
      ,output v-return-value
      ) .
    if v-return-value <> 0
    then do:
      assign
        p-user-name = get-string(v-buffer-memptr, 5)
      .
    end.
    run GetCurrentProcessId
      (output p-process-pid
      ) .
    assign
      set-size(v-buffer-memptr) = 0
    .
  end.
end procedure.
procedure sys-time_get-http :
  define output parameter p-http-time as character no-undo .
  define variable v-year         as integer   no-undo .
  define variable v-month        as integer   no-undo .
  define variable v-day-of-week  as integer   no-undo .
  define variable v-day          as integer   no-undo .
  define variable v-hour         as integer   no-undo .
  define variable v-minute       as integer   no-undo .
  define variable v-second       as integer   no-undo .
  define variable v-milliseconds as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run sys-time_get-sys in this-procedure
      (output v-year
      ,output v-month
      ,output v-day
      ,output v-hour
      ,output v-minute
      ,output v-second
      ,output v-milliseconds
      ) .
    assign
      v-day-of-week = weekday(date(v-month, v-day, v-year))
      p-http-time = entry(v-day-of-week, 'Sun,Mon,Tue,Wed,Thu,Fri,Sat')
                  + ', ':u
                  + string(v-day, '99':u)
                  + ' ':u
                  + entry(v-month, 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec':u)
                  + ' ':u
                  + string(v-year, '9999':u)
                  + ' ':u
                  + string(v-hour, '99':u)
                  + ':':u
                  + string(v-minute, '99':u)
                  + ':':u
                  + string(v-second, '99':u)
                  + ' ':u
                  + 'GMT':u
    .
  end.
end procedure.
procedure sys-time_set-sys :
  define input  parameter p-year         as integer   no-undo .
  define input  parameter p-month        as integer   no-undo .
  define input  parameter p-day          as integer   no-undo .
  define input  parameter p-hour         as integer   no-undo .
  define input  parameter p-minute       as integer   no-undo .
  define input  parameter p-second       as integer   no-undo .
  define input  parameter p-milliseconds as integer   no-undo .
  define variable v-system-time-structure as memptr    no-undo.
  define variable v-return-value as integer   no-undo .
  define variable v-day-of-week  as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-day-of-week = weekday(date(p-month, p-day, p-year))
    .
    assign
      set-size(v-system-time-structure) = 16
    .
    assign
      put-short(v-system-time-structure,  1) = p-year
      put-short(v-system-time-structure,  3) = p-month
      put-short(v-system-time-structure,  5) = v-day-of-week
      put-short(v-system-time-structure,  7) = p-day
      put-short(v-system-time-structure,  9) = p-hour
      put-short(v-system-time-structure, 11) = p-minute
      put-short(v-system-time-structure, 13) = p-second
      put-short(v-system-time-structure, 15) = p-milliseconds
    .
    run SetSystemTime
      (input  get-pointer-value(v-system-time-structure)
      ,output v-return-value
      ) .
    assign
      set-size(v-system-time-structure) = 0
    .
    if v-return-value = 0
    then do:
      undo, return error "sys-time_set-sys: Ошибка при установке даты" .
    end.
  end.
end procedure.
procedure sys-time_sys-to-mjd :
  define input  parameter p-year         as integer   no-undo .
  define input  parameter p-month        as integer   no-undo .
  define input  parameter p-day          as integer   no-undo .
  define input  parameter p-hour         as integer   no-undo .
  define input  parameter p-minute       as integer   no-undo .
  define input  parameter p-second       as integer   no-undo .
  define input  parameter p-milliseconds as integer   no-undo .
  define output parameter p-mjd          as decimal   no-undo .
  define variable v-year-correction as decimal   no-undo .
  define variable v-shift-year as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-year-correction = truncate((decimal(p-month) - 14.0) / 12, 0)
      v-shift-year      = decimal(p-year) + v-year-correction
      p-mjd = truncate( (1461.0 * (v-shift-year + 4800.0 ) ) / 4, 0)
            + truncate( (367.0 * (decimal(p-month) - 2.0 - v-year-correction * 12) ) / 12, 0)
            - truncate( (3 * truncate((v-shift-year + 4900 ) / 100,0) ) / 4, 0)
            + decimal(p-day) - 2432076.0
            + p-hour / 24.0
            + p-minute / 1440.0
            + p-second / 86400.0
            + p-milliseconds / 86400000.0
    .
  end.
end procedure.
procedure sys-time_sys-to-loc :
  define input  parameter p-sys-year         as integer   no-undo .
  define input  parameter p-sys-month        as integer   no-undo .
  define input  parameter p-sys-day          as integer   no-undo .
  define input  parameter p-sys-hour         as integer   no-undo .
  define input  parameter p-sys-minute       as integer   no-undo .
  define input  parameter p-sys-second       as integer   no-undo .
  define input  parameter p-sys-milliseconds as integer   no-undo .
  define output parameter p-loc-year         as integer   no-undo .
  define output parameter p-loc-month        as integer   no-undo .
  define output parameter p-loc-day          as integer   no-undo .
  define output parameter p-loc-hour         as integer   no-undo .
  define output parameter p-loc-minute       as integer   no-undo .
  define output parameter p-loc-second       as integer   no-undo .
  define output parameter p-loc-milliseconds as integer   no-undo .
  define variable v-system-time-structure as memptr    no-undo.
  define variable v-return-value          as integer   no-undo .
  define variable v-sys-day-of-week       as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-sys-day-of-week = weekday(date(p-sys-month, p-sys-day, p-sys-year))
    .
    assign
      set-size(v-system-time-structure) = 32
    .
    assign
      put-short(v-system-time-structure,  1) = p-sys-year
      put-short(v-system-time-structure,  3) = p-sys-month
      put-short(v-system-time-structure,  5) = v-sys-day-of-week
      put-short(v-system-time-structure,  7) = p-sys-day
      put-short(v-system-time-structure,  9) = p-sys-hour
      put-short(v-system-time-structure, 11) = p-sys-minute
      put-short(v-system-time-structure, 13) = p-sys-second
      put-short(v-system-time-structure, 15) = p-sys-milliseconds
    .
    run SystemTimeToTzSpecificLocalTime
      (input  0
      ,input  get-pointer-value(v-system-time-structure)
      ,input  get-pointer-value(v-system-time-structure) + 16
      ,output v-return-value
      ) .
    assign
      p-loc-year         = get-short(v-system-time-structure,  1 + 16)
      p-loc-month        = get-short(v-system-time-structure,  3 + 16)
      p-loc-day          = get-short(v-system-time-structure,  7 + 16)
      p-loc-hour         = get-short(v-system-time-structure,  9 + 16)
      p-loc-minute       = get-short(v-system-time-structure, 11 + 16)
      p-loc-second       = get-short(v-system-time-structure, 13 + 16)
      p-loc-milliseconds = get-short(v-system-time-structure, 15 + 16)
    .
    assign
      set-size(v-system-time-structure) = 0
    .
    if v-return-value = 0
    then do:
      undo, return error "sys-time_set-sys: Ошибка при установке даты" .
    end.
  end.
end procedure.
procedure sys-time_mjd-to-sys :
  define input  parameter p-mjd          as decimal   no-undo .
  define output parameter p-year         as integer   no-undo .
  define output parameter p-month        as integer   no-undo .
  define output parameter p-day          as integer   no-undo .
  define output parameter p-hour         as integer   no-undo .
  define output parameter p-minute       as integer   no-undo .
  define output parameter p-second       as integer   no-undo .
  define output parameter p-milliseconds as integer   no-undo .
  define variable v-year-correction as decimal   no-undo .
  define variable v-shift-year      as decimal   no-undo .
  define variable v-conv-date     as date      no-undo .
  define variable v-int-part      as integer   no-undo .
  define variable v-fraction-part as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-int-part      = integer(truncate(p-mjd, 0))
      v-fraction-part = p-mjd - v-int-part
      v-conv-date     = date(11, 17, 1858) + v-int-part
      p-year          = year(v-conv-date)
      p-month         = month(v-conv-date)
      p-day           = day(v-conv-date)
      v-fraction-part = v-fraction-part * 24.0
      p-hour          = integer(truncate(v-fraction-part, 0))
      v-fraction-part = (v-fraction-part - p-hour) * 60.0
      p-minute        = integer(truncate(v-fraction-part, 0))
      v-fraction-part = (v-fraction-part - p-minute) * 60.0
      p-second        = integer(truncate(v-fraction-part, 0))
      v-fraction-part = (v-fraction-part - p-second) * 1000.0
      p-milliseconds  = integer(v-fraction-part)
    .
  end.
end procedure.
procedure sys-time_mjd-to-loc :
  define input  parameter p-mjd              as decimal   no-undo .
  define output parameter p-loc-year         as integer   no-undo .
  define output parameter p-loc-month        as integer   no-undo .
  define output parameter p-loc-day          as integer   no-undo .
  define output parameter p-loc-hour         as integer   no-undo .
  define output parameter p-loc-minute       as integer   no-undo .
  define output parameter p-loc-second       as integer   no-undo .
  define output parameter p-loc-milliseconds as integer   no-undo .
  define variable v-sys-year         as integer   no-undo .
  define variable v-sys-month        as integer   no-undo .
  define variable v-sys-day          as integer   no-undo .
  define variable v-sys-hour         as integer   no-undo .
  define variable v-sys-minute       as integer   no-undo .
  define variable v-sys-second       as integer   no-undo .
  define variable v-sys-milliseconds as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run sys-time_mjd-to-sys
      (input  p-mjd
      ,output v-sys-year
      ,output v-sys-month
      ,output v-sys-day
      ,output v-sys-hour
      ,output v-sys-minute
      ,output v-sys-second
      ,output v-sys-milliseconds
      ) .
    run sys-time_sys-to-loc
      (input  v-sys-year
      ,input  v-sys-month
      ,input  v-sys-day
      ,input  v-sys-hour
      ,input  v-sys-minute
      ,input  v-sys-second
      ,input  v-sys-milliseconds
      ,output p-loc-year
      ,output p-loc-month
      ,output p-loc-day
      ,output p-loc-hour
      ,output p-loc-minute
      ,output p-loc-second
      ,output p-loc-milliseconds
      ) .
  end.
end procedure.
function sys-time_get-mjd-func returns decimal
:
  define variable v-year         as integer   no-undo .
  define variable v-month        as integer   no-undo .
  define variable v-day          as integer   no-undo .
  define variable v-hour         as integer   no-undo .
  define variable v-minute       as integer   no-undo .
  define variable v-second       as integer   no-undo .
  define variable v-milliseconds as integer   no-undo .
  define variable v-mjd          as decimal   no-undo .
  run sys-time_get-sys in this-procedure
    (output v-year
    ,output v-month
    ,output v-day
    ,output v-hour
    ,output v-minute
    ,output v-second
    ,output v-milliseconds
    ) .
  run sys-time_sys-to-mjd in this-procedure
    (input  v-year
    ,input  v-month
    ,input  v-day
    ,input  v-hour
    ,input  v-minute
    ,input  v-second
    ,input  v-milliseconds
    ,output v-mjd
    ) .
  return v-mjd .
end function .
function sys-time_get-sys-str-func returns character
:
  define variable v-utc-time as character no-undo .
  define variable v-year         as integer   no-undo .
  define variable v-month        as integer   no-undo .
  define variable v-day          as integer   no-undo .
  define variable v-hour         as integer   no-undo .
  define variable v-minute       as integer   no-undo .
  define variable v-second       as integer   no-undo .
  define variable v-milliseconds as integer   no-undo .
  run sys-time_get-sys in this-procedure
    (output v-year
    ,output v-month
    ,output v-day
    ,output v-hour
    ,output v-minute
    ,output v-second
    ,output v-milliseconds
    ) .
  assign
    v-utc-time  = 'UTC ':u
                + string(v-year,         '9999':u)
                + '/':u
                + string(v-month,        '99':u)
                + '/':u
                + string(v-day,          '99':u)
                + ' ':u
                + string(v-hour,         '99':u)
                + ':':u
                + string(v-minute,       '99':u)
                + ':':u
                + string(v-second,       '99':u)
                + ' ':u
                + string(v-milliseconds, '999':u)
  .
  return v-utc-time.
end function .
function sys-time_mjd-to-loc-str-func returns character
  (v-sys-mjd as decimal)
:
  define variable v-loc-str          as character no-undo .
  define variable v-loc-year         as integer   no-undo .
  define variable v-loc-month        as integer   no-undo .
  define variable v-loc-day          as integer   no-undo .
  define variable v-loc-hour         as integer   no-undo .
  define variable v-loc-minute       as integer   no-undo .
  define variable v-loc-second       as integer   no-undo .
  define variable v-loc-milliseconds as integer   no-undo .
  run sys-time_mjd-to-loc in this-procedure
    (input  v-sys-mjd
    ,output v-loc-year
    ,output v-loc-month
    ,output v-loc-day
    ,output v-loc-hour
    ,output v-loc-minute
    ,output v-loc-second
    ,output v-loc-milliseconds
    ) .
  assign
    v-loc-str = substitute('&1/&2/&3 &4:&5'
                          ,string(v-loc-day,    '99':U)
                          ,string(v-loc-month,  '99':U)
                          ,string(v-loc-year,   '9999':U)
                          ,string(v-loc-hour,   '99':U)
                          ,string(v-loc-minute, '99':U)
                          )
  .
  return v-loc-str .
end function .
PROCEDURE GetSystemTime EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpSystemTime AS LONG .
END PROCEDURE.
PROCEDURE SetSystemTime EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpSystemTime AS LONG .
  DEFINE RETURN PARAMETER ReturnValue  AS LONG .
END PROCEDURE.
PROCEDURE GetTimeZoneInformation EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpTimeZoneInformation AS LONG .
  DEFINE RETURN PARAMETER ReturnValue           AS LONG .
END PROCEDURE.
PROCEDURE SystemTimeToTzSpecificLocalTime EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpTimeZone      AS LONG .
  DEFINE INPUT  PARAMETER lpUniversalTime AS LONG .
  DEFINE INPUT  PARAMETER lpLocalTime     AS LONG .
  DEFINE RETURN PARAMETER ReturnValue     AS LONG .
END PROCEDURE.
PROCEDURE GetUserNameA EXTERNAL "advapi32.dll"
:
  DEFINE INPUT  PARAMETER lpBuffer    AS LONG .
  DEFINE INPUT  PARAMETER lpnSize     AS LONG .
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.
PROCEDURE GetComputerNameA EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpBuffer    AS LONG .
  DEFINE INPUT  PARAMETER lpnSize     AS LONG .
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.
PROCEDURE GetCurrentProcessId EXTERNAL "kernel32.dll"
:
  DEFINE RETURN PARAMETER RetVal          AS LONG.
END PROCEDURE.
function get-user-login returns character
  ( p-user-id as character ) :
  define variable v-user-login as character no-undo .
  run procedure-get-user-login in this-procedure (
      input p-user-id
    , output v-user-login
  ) .
  return v-user-login .
end function.
procedure procedure-get-user-login :
define input  parameter p-user-id    as character no-undo .
define output parameter p-user-login as character no-undo .
    define buffer buf_user-login for ub.user-login .
do
for buf_user-login
on error undo, return error return-value
:
    assign
        p-user-login = "":U
    .
    for each buf_user-login no-lock
       where buf_user-login.user-id = p-user-id
    by buf_user-login.db-num
    :
        assign
            p-user-login = substitute( "&1&2&3"
                                , p-user-login
                                , ( if p-user-login = "":U then "":U else ",":U )
                                , buf_user-login.db-num )
        .
    end.
end.
end procedure.
procedure SetAttrUserId:
   define input  parameter iDb-num      as integer   no-undo.
   define input  parameter iUserId      as character no-undo.
   define input  parameter iAttrCode    as character no-undo.
   define input  parameter iAttrValue   as character no-undo.
   define buffer user-login-attr  for ub.user-login-attr .
   find first user-login-attr where user-login-attr.db-num    eq idb-num
                                and user-login-attr.user-id   eq iuserid
                                and user-login-attr.attr-code eq iAttrCode
   exclusive-lock no-error.
   if     not available user-login-attr
      and iAttrValue ne ?
   then do:
      create user-login-attr.
      assign
         user-login-attr.db-num     = idb-num
         user-login-attr.user-id    = iuserid
         user-login-attr.attr-code  = iAttrCode
      .
   end.
   if iAttrValue eq ?
   then do:
      if available ub.user-login-attr
      then
         delete ub.user-login-attr.
   end.
   else
      user-login-attr.attr-value = iAttrValue.
end procedure.
function GetAttrUserId returns character (
   input iDb-num      as integer  ,
   input iUserId      as character,
   input iAttrCode    as character):
   define buffer user-login-attr  for ub.user-login-attr .
   find first user-login-attr where user-login-attr.db-num    eq idb-num
                                and user-login-attr.user-id   eq iuserid
                                and user-login-attr.attr-code eq iAttrCode
   no-lock no-error.
   return if not available ub.user-login-attr then ? else ub.user-login-attr.attr-value.
end function.
procedure getAccountSetting :
   define input  parameter i-user-id  as character no-undo.
   define output parameter o-adm-Ubd  as logical no-undo init ?.
   define output parameter v-adm-GBD  as logical no-undo.
   define output parameter o-superAdm as logical no-undo.
   define input-output parameter table for UserDbAdm .
   define variable v-adm-Ubd-int as integer no-undo.
   define buffer user-login for ub.user-login.
   define buffer db         for ub.db.
   define buffer user-account-attr for ub.user-account-attr.
   find first user-login where user-login.db-num  eq 0
                           and user-login.user-id eq i-user-id
   no-lock no-error.
   if available user-login
   then
      v-adm-gbd = user-login.user-administrator.
   else
      v-adm-gbd = ?.
   for each userDbAdm:
      delete userDbAdm.
   end.
   block-db:
   for each db where db.db-num ne 0 no-lock:
      if G#db-num ne 0
         and G#db-num ne db.db-num
      then
         next block-db.
      create UserDbAdm.
      UserDbAdm.db-num = ub.db.db-num.
      find first user-login where user-login.db-num  eq db.db-num
                              and user-login.user-id eq i-user-id
      no-lock no-error.
      if not available user-login
      then
         v-adm-Ubd-int = 2.
      else if user-login.status_ eq 1
      then do:
         v-adm-Ubd-int = 2.
          UserDbAdm.db-block = yes.
          UserDbAdm.db-usr   = yes.
      end.
      else if user-login.user-administrator
      then do:
         UserDbAdm.db-adm = yes.
         UserDbAdm.db-usr = yes.
         if v-adm-Ubd-int eq 0
         then
            v-adm-Ubd-int = 1.
         else if v-adm-Ubd-int eq 3
         then do:
            v-adm-Ubd-int = 2.
         end.
      end.
      else do:
         if available ub.user-login
         then
            UserDbAdm.db-usr = yes.
         if v-adm-Ubd-int eq 0
         then
            v-adm-Ubd-int = 3.
         else if v-adm-Ubd-int eq 1
         then do:
            v-adm-Ubd-int = 2.
         end.
      end.
   end.
   if  v-adm-Ubd-int eq 1
   then
      o-adm-Ubd = true.
   else if v-adm-Ubd-int eq 3
   then
      o-adm-Ubd = false.
   find first user-account-attr where user-account-attr.user-id  eq i-user-id
                                  and user-account-attr.attr-code  eq "superADm"
   no-lock no-error.
   o-superAdm =  available user-account-attr and logical (user-account-attr.attr-value ) no-error.
end.
function check_alphanumeric returns character (
input ipwd as character ,
input itype as character ):
   define variable vCharEng as character no-undo
   init "abcdefghijklmnopqrstuvwxyz".
   define variable vCharRus as character no-undo
   init "йцукенгшщзхъфывапролджэячсмитьбюёЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЯЧСМИТЬБЮЁЭ".
   define variable vi as integer no-undo.
   define variable vdigitFl as logical no-undo.
   define variable vCharEngFl as logical no-undo.
   define variable vCharRusFl as logical no-undo.
   define variable vCharSpeFl as logical no-undo.
   define variable vTextNew as character no-undo.
   define variable vTextOld as character no-undo.
   vTextNew = ipwd.
   vTextOld = vTextNew.
   do vi = 0 to 9:
      vTextNew = replace(vTextNew,string (vi),"").
   end.
   if length(vTextOld) ne length(vTextNew)
   then
      vdigitFL = yes.
   vTextOld = vTextNew.
   do vi = 1 to length(vCharEng):
      vTextNew = replace(vtextNew,substring(vCharEng,vi,1),"").
   end.
   if length(vTextOld) ne length(vTextNew)
   then
      vCharEngFl = yes.
   vTextOld = vTextNew.
   do vi = 1 to length(vCharRus):
      vTextNew = replace(vtextNew,substring(vCharRus,vi,1),"").
   end.
   if length(vTextOld) ne length(vTextNew)
   then
      vCharEngFl = yes.
   if length(vTextNew) > 0
   then
      vCharSpeFl = yes.
   define variable vReturn as character no-undo.
   assign
      vReturn = vReturn + ", " + "не содержит цифр"           when lookup ("digit",   itype) > 0 and not vdigitFl
      vReturn = vReturn + ", " + "не содержит латинских букв" when lookup ("CharEng", itype) > 0 and not vCharEngFl
      vReturn = vReturn + ", " + "не содержит русских букв"   when lookup ("CharRus", itype) > 0 and not vCharRusFl
      vReturn = vReturn + ", " + "не содержит спец символов"  when lookup ("CharSpe", itype) > 0 and not vCharSpeFl
      vReturn = vReturn + ", " + "не содержит символов"       when lookup ("Char",    itype) > 0 and not (vCharEngFl or vCharRusFl or vCharSpeFl)
   .
   vReturn = substring (vReturn,3) no-error.
   return vReturn.
end.
procedure SaveLastPWD:
   define input  parameter iDb-num as integer   no-undo.
   define input  parameter iUserId as character no-undo.
   define input  parameter IPWD    as character no-undo.
   define buffer user-login-attr  for ub.user-login-attr .
   find first user-login-attr where user-login-attr.db-num    eq idb-num
                                and user-login-attr.user-id   eq iuserid
                                and user-login-attr.attr-code eq "LastPWD"
   exclusive-lock no-error.
   if not available user-login-attr
   then do:
      create user-login-attr.
      assign
         user-login-attr.db-num     = idb-num
         user-login-attr.user-id    = iuserid
         user-login-attr.attr-code  = "LastPWD"
         user-login-attr.attr-value = ipwd
      .
   end.
   else do:
      user-login-attr.attr-value = user-login.user-password-encoded + chr(5) + user-login-attr.attr-value .
      if num-entries (user-login-attr.attr-value , chr(5)) > 50
      then
         user-login-attr.attr-value = substring (user-login-attr.attr-value,1,r-index(user-login-attr.attr-value, chr(5)) - 1).
   end.
end procedure.
function  CheckLastPWD returns character  (
   input  iDb-num    as integer  ,
   input  iUserId    as character,
   input  IPWD       as character,
   input  Iadm       as logical ) :
   define buffer user-login       for ub.user-login .
   define buffer user-login-attr  for ub.user-login-attr .
   define variable vError as character  no-undo.
   define variable v-obyznumbukv as logical no-undo .
   define variable v-minparol as integer no-undo .
   define variable v-tth as handle no-undo .
   define variable VadmSuff as character no-undo.
   define variable v-param-type as character no-undo .
   define variable v-value-character as character no-undo .
   define variable v-value-date as date no-undo .
   define variable v-value-decimal as decimal no-undo .
   define variable v-value-integer as integer no-undo .
   define variable v-value-logical as logical no-undo .
   find first user-login where user-login.db-num    eq idb-num
                           and user-login.user-id   eq iUserId
   no-lock no-error.
   if Iadm
   then
      VadmSuff = 'Adm':U.
   run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'staff':U
        ,input  'minparol':U + VadmSuff
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-minparol
        ,output v-value-logical
        ,output v-param-type
        ,input-output table-handle v-tth
        )  .
    if v-minparol <> 0  then do:
       if length(ipwd) < v-minparol
        then do:
           vError = substitute ("Длина поля должна быть не менее &1" , v-minparol).
        end.
    end.
    run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'staff':U
        ,input  'obyznumbukv':U + VadmSuff
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-obyznumbukv
        ,output v-param-type
        ,input-output table-handle v-tth
        )  .
   if v-obyznumbukv = true
   then do:
      if check_alphanumeric(ipwd,"Digit,Char") ne ""
      then do:
         vError = vError + (if vError eq "" then "" else ", " )
                + "В пароле должны содержаться буквы и цифры".
      end.
   end.
   define variable v-encode-value as character no-undo.
   define variable v-Lastpaswd    as integer no-undo.
   run adm/pswd-enc.p
      (input  encode(ipwd)
      ,output v-encode-value
      ).
   v-encode-value = encode(v-encode-value).
   run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'staff':U
        ,input  'LastPaswd':U + VadmSuff
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-Lastpaswd
        ,output v-value-logical
        ,output v-param-type
        ,input-output table-handle v-tth
        )  .
   if v-Lastpaswd ne 0
   then do:
      define variable vLastPwd as character no-undo.
      vLastPwd = GetAttrUserId(iDb-num, iUserId, "LastPWD").
      if vLastPwd ne ?
      then do:
         define variable Vi as integer no-undo.
         vi = lookup (v-encode-value,vLastPwd,chr(5)).
         if     vi ne 0
            and vi le v-Lastpaswd
         then
            vError = vError + (if vError eq "" then "" else ", " )
                   + substitute ("пароль не должен совпадать с последими &1 паролями",v-Lastpaswd).
      end.
   end.
   delete object v-tth.
   return vError.
end function.
procedure availOneAdm:
   define input-output parameter table for UserDbAdm.
   define output parameter oAdm as logical no-undo.
   find first UserDbAdm where UserDbAdm.db-adm no-lock no-error.
   oadm = available UserDbAdm.
end.
procedure update-user-login:
   define input  parameter i-db-num     as integer          no-undo.
   define input  parameter i-user-id    as character        no-undo.
   define input  parameter i-user-login as character no-undo.
   define input  parameter i-max-discnt as decimal no-undo.
   define input  parameter i-quest-print as logical no-undo.
   define input  parameter i-encoded-pass as character no-undo.
   define input  parameter i-nextcon as logical no-undo.
   define input  parameter i-user-administrator as logical no-undo.
   define input  parameter i-Manual     as logical no-undo.
   define input  parameter i-adm-gbd as logical no-undo.
   define input  parameter i-adm-ubd as logical no-undo.
   define input-output parameter table for UserDbAdm.
   define buffer buf_user-login        for user-login.
   do
for buf_user-login
on error undo, return error
:
        if     i-Manual
           and G#db-num eq 0
        then do:
           if     i-adm-gbd ne ?
           then do:
              do transaction
              on error undo, return error return-value
              :
                  find first buf_user-login where buf_user-login.db-num             eq 0
                                              and buf_user-login.user-login         eq i-user-login
                                              and buf_user-login.status_            eq 0
                                              and buf_user-login.user-id            ne i-user-id
                  no-lock no-error.
                  if available buf_user-login
                  then
                     undo, return error "Уже есть такой логин в ГБД".
                  find first buf_user-login where buf_user-login.db-num             = 0
                                              and buf_user-login.user-id            = i-user-id
                  exclusive-lock no-error.
                  if not available buf_user-login
                  then do:
                     create buf_user-login .
                     assign
                         buf_user-login.db-num             = 0
                         buf_user-login.user-id            = i-user-id
                         buf_user-login.status_            = 0
                     .
                  end.
                  assign
                      buf_user-login.user-login         = i-user-login
                      buf_user-login.user-administrator = i-adm-gbd
                      buf_user-login.max-discnt         = i-max-discnt
                      buf_user-login.quest-print        = i-quest-print
                      buf_user-login.user-password-encoded = i-encoded-pass
                  .
                  if i-nextcon ne ?
                  then do:
                     run SetAttrUserId(buf_user-login.db-num, buf_user-login.user-id, "ChangPwdNextConect", string(i-nextcon )).
                  end.
                  run addobj(buf_user-login.db-num,buf_user-login.user-id) no-error.
                  if error-status:error
                  then
                     return error return-value.
              end.
           end.
           else do transaction on error undo, return error return-value:
               find first buf_user-login where buf_user-login.db-num             = 0
                                           and buf_user-login.user-id            = i-user-id
               exclusive-lock no-error.
               if available buf_user-login
               then
                  delete buf_user-login.
           end.
           if     i-adm-ubd ne ?
           then do:
              do transaction
              on error undo, return error return-value
              :
                  define variable vDbError as character no-undo.
                  block-db:
                  for each db where db.db-num ne 0
                  no-lock:
                     find first buf_user-login where buf_user-login.db-num             eq db.db-num
                                                 and buf_user-login.user-login         eq i-user-login
                                                 and buf_user-login.status_            eq 0
                                                 and buf_user-login.user-id            ne i-user-id
                     no-lock no-error.
                     if available buf_user-login
                     then do:
                        vDbError = vDbError + "," + String(db.db-num) no-error.
                        next block-db.
                     end.
                     find first buf_user-login where buf_user-login.db-num             = db.db-num
                                                 and buf_user-login.user-id            = i-user-id
                     exclusive-lock no-error.
                     if not available buf_user-login
                     then do:
                        create buf_user-login .
                        assign
                            buf_user-login.db-num             = db.db-num
                            buf_user-login.user-id            = i-user-id
                            buf_user-login.status_            = 0
                            buf_user-login.user-password-encoded = i-encoded-pass
                        .
                     end.
                     assign
                         buf_user-login.status_            = 0 when i-db-num ne G#db-num
                         buf_user-login.user-login         = i-user-login
                         buf_user-login.user-administrator = i-adm-ubd
                         buf_user-login.max-discnt         = i-max-discnt
                         buf_user-login.quest-print        = i-quest-print
                     .
                     if i-nextcon ne ?
                     then do:
                        run SetAttrUserId(buf_user-login.db-num, buf_user-login.user-id, "ChangPwdNextConect", string(i-nextcon )).
                     end.
                     run addobj(buf_user-login.db-num,buf_user-login.user-id)no-error.
                     if error-status:error
                     then
                        return error return-value.
                 end.
                 if vDbError ne ""
                 then
                    undo, return error substitute ("Уже есть такой логин в УБД &1",substring (vDbError,2,4000)).
              end.
           end.
           else do:
              do transaction
              on error undo, return error return-value
              :
                  block-UserDb:
                  for each UserDbAdm where UserDbAdm.db-num ne 0
                  no-lock:
                     find first buf_user-login where buf_user-login.db-num             eq UserDbAdm.db-num
                                                 and buf_user-login.user-login         eq i-user-login
                                                 and buf_user-login.status_            eq 0
                                                 and buf_user-login.user-id            ne i-user-id
                     no-lock no-error.
                     if available buf_user-login and UserDbAdm.db-usr
                     then do:
                        vDbError = vDbError + "," + String(db.db-num) no-error.
                        next block-UserDb.
                     end.
                     find first buf_user-login where buf_user-login.db-num             = UserDbAdm.db-num
                                                 and buf_user-login.user-id            = i-user-id
                     exclusive-lock no-error.
                     if UserDbAdm.db-usr
                     then do:
                        if not available buf_user-login
                        then do:
                           create buf_user-login .
                           assign
                               buf_user-login.db-num             = UserDbAdm.db-num
                               buf_user-login.user-id            = i-user-id
                               buf_user-login.status_            = if UserDbAdm.db-block then 1 else 0
                               buf_user-login.user-password-encoded = i-encoded-pass
                           .
                        end.
                        assign
                            buf_user-login.status_            = if UserDbAdm.db-block then 1 else 0 when i-db-num ne G#db-num or G#db-num = 0
                            buf_user-login.user-login         = i-user-login
                            buf_user-login.user-administrator = UserDbAdm.db-adm
                            buf_user-login.max-discnt         = i-max-discnt
                            buf_user-login.quest-print        = i-quest-print
                        .
                        if i-nextcon ne ?
                        then do:
                           run SetAttrUserId(buf_user-login.db-num, buf_user-login.user-id, "ChangPwdNextConect", string(i-nextcon )).
                        end.
                        if UserDbAdm.db-adm
                        then do:
                           run addobj(buf_user-login.db-num,buf_user-login.user-id)no-error.
                           if error-status:error
                           then
                              undo, return error return-value.
                        end.
                    end.
                    else do:
                       if available buf_user-login
                       then do:
                          define variable vok as logical no-undo.
                          run procedure-user-login-delete-question (UserDbAdm.db-num,i-user-id, no, output vok).
                          if not vok
                          then
                             undo, return error return-value.
                       end.
                    end.
                 end.
                  if vDbError ne ""
                  then
                    undo, return error substitute ("Уже есть такой логин в УБД &1",substring (vDbError,2,4000)).
              end.
           end.
        end.
        else do transaction
        on error undo, return error return-value
        :
           find first buf_user-login where buf_user-login.db-num             = i-db-num
                                       and buf_user-login.user-id            = i-user-id
           exclusive-lock no-error.
           if not available buf_user-login
           then do:
              create buf_user-login .
              assign
                 buf_user-login.db-num             = i-db-num
                 buf_user-login.user-id            = i-user-id
                 buf_user-login.status_            = 0
              .
           end.
           assign
                buf_user-login.user-login         = i-user-login
                buf_user-login.user-administrator = i-user-administrator
                buf_user-login.max-discnt         = i-max-discnt
                buf_user-login.quest-print        = i-quest-print
                buf_user-login.user-password-encoded = i-encoded-pass
            .
            if i-user-administrator
            then
               run addobj(buf_user-login.db-num,buf_user-login.user-id).
            if i-nextcon ne ?
            then do:
               run SetAttrUserId(buf_user-login.db-num, buf_user-login.user-id, "ChangPwdNextConect", string(i-nextcon )).
            end.
        end.
    end.
end procedure.
procedure addobj:
   define input  parameter i-db-num as integer no-undo.
   define input  parameter i-user-id as character no-undo.
   define buffer buf_user-obj     for ub.user-obj.
   define buffer buf_clients      for ub.clients.
   if i-db-num <> 0 then do:
       for each buf_clients
           where buf_clients.db-num = i-db-num
           and ( buf_clients.obj-type = 'маг':U
              or buf_clients.obj-type = 'скл':U
               )
           no-lock:
          if can-find (buf_user-obj where buf_user-obj.obj-type = buf_clients.obj-type
                                  and buf_user-obj.obj-code     = buf_clients.obj-code
                                  and buf_user-obj.user-id      = i-user-id
                                  and buf_user-obj.db-num       = i-db-num
                                no-lock)
                                then next.
          run enbl-obj (i-db-num, i-user-id, buf_clients.obj-type, buf_clients.obj-code).
       end.
    end.
    else do:
       for each buf_clients
           where
               ( buf_clients.obj-type = 'маг':U
              or buf_clients.obj-type = 'скл':U
               )
           no-lock:
          if can-find (buf_user-obj where buf_user-obj.obj-type = buf_clients.obj-type
                                  and buf_user-obj.obj-code     = buf_clients.obj-code
                                  and buf_user-obj.user-id      = i-user-id
                                  and buf_user-obj.db-num       = i-db-num
                                no-lock)
                                then next.
          run enbl-obj (i-db-num, i-user-id, buf_clients.obj-type, buf_clients.obj-code).
       end.
    end.
end.
procedure enbl-obj :
   define input  parameter i-db-num  as integer   no-undo.
   define input  parameter i-user-id as character no-undo.
   define input  parameter i-type    as character no-undo.
   define input  parameter i-code    as integer   no-undo.
    define variable v-host-code    as integer      no-undo.
    define variable v-host-name    as character    no-undo.
    define variable v-base-code    as integer      no-undo.
    define buffer buf_user-obj      for ub.user-obj.
    define buffer buf_user-host     for ub.user-host.
    define buffer buf_clients       for ub.clients.
do
for buf_user-obj
  , buf_user-host
  , buf_clients
on error undo, return error
:
    find first buf_user-obj exclusive-lock
         where buf_user-obj.db-num    = i-db-num
           and buf_user-obj.user-id   = i-user-id
           and buf_user-obj.obj-type  = i-type
           and buf_user-obj.obj-code  = i-code
    no-error.
    if not available buf_user-obj
    then do:
        find first buf_clients no-lock
             where buf_clients.obj-type = i-type
               and buf_clients.obj-code = i-code
        .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  i-type
  ,input  i-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
        create buf_user-obj.
        assign
            buf_user-obj.db-num    = i-db-num
            buf_user-obj.user-id   = i-user-id
            buf_user-obj.obj-type  = i-type
            buf_user-obj.obj-code  = i-code
            buf_user-obj.host-code = v-host-code
        .
        find first buf_user-host exclusive-lock
             where buf_user-host.db-num    = i-db-num
               and buf_user-host.user-id   = i-user-id
               and buf_user-host.host-code = v-host-code
        no-error.
        if not available buf_user-host
        then do:
            create buf_user-host.
            assign
                buf_user-host.db-num    = i-db-num
                buf_user-host.user-id   = i-user-id
                buf_user-host.host-code = v-host-code
            .
        end.
   end.
end.
end procedure.
procedure procedure-user-login-change-password :
   define input  parameter p-db-num         as integer          no-undo.
   define input  parameter p-user-id        as character        no-undo.
   define input  parameter iChange          as logical          no-undo.
   define variable v-can-edit         as logical   no-undo .
   define variable v-encoded-pass     as character no-undo .
   define variable v-encoded-pass-old as character no-undo .
   define variable v-nextcon          as logical   no-undo .
   define variable VadmSuff           as character no-undo.
   define variable vChange as logical no-undo.
   define variable v-param-type as character no-undo .
   define variable v-value-character as character no-undo .
   define variable v-value-date as date no-undo .
   define variable v-value-decimal as decimal no-undo .
   define variable v-value-integer as integer no-undo .
   define variable v-value-logical as logical no-undo .
   define variable v-tth           as handle  no-undo .
   define buffer buf_lock_user-login for user-login.
   define buffer buf_init_user-account for user-account.
   do:
      find first buf_lock_user-login no-lock
              where buf_lock_user-login.db-num  = p-db-num
                and buf_lock_user-login.user-id = p-user-id
      no-error.
      if not available buf_lock_user-login then do:
         message
            "Нельзя редактировать пароль пока не заведен логин для пользователя" skip
            view-as alert-box error .
            undo, return error "Нельзя редактировать пароль пока не заведен логин для пользователя" .
      end.
      vChange = buf_lock_user-login.user-login eq userid ("ub") or iChange.
      if     available buf_lock_user-login
         and buf_lock_user-login.user-administrator
      then
         VadmSuff = 'Adm':U.
      define variable v-TimeAvail as integer no-undo.
      define variable v-DateChg   as date    no-undo.
      define variable v-Time      as integer no-undo.
      run cur-time-mjd-to-date (buf_lock_user-login.user-password-set-mjd, output v-DateChg, output v-Time).
      run adm/shattri.p (
           input "get":U
           ,input  '':U
           ,input  0
           ,input  'staff':U
           ,input  'TimeBlock':U + VadmSuff
           ,output v-value-character
           ,output v-value-date
           ,output v-value-decimal
           ,output v-TimeAvail
           ,output v-value-logical
           ,output v-param-type
           ,input-output table-handle v-tth
           )  .
      if     not iChange
         and v-TimeAvail ne 0
         and v-DateChg + v-TimeAvail < today
      then do:
         do trans:
            find current buf_lock_user-login exclusive-lock.
            buf_lock_user-login.status_ = 1.
         end.
         return error "Ваша учетная запись заблокирована." .
      end.
      run adm/shattri.p (
           input "get":U
           ,input  '':U
           ,input  0
           ,input  'staff':U
           ,input  'TimeAvail':U + VadmSuff
           ,output v-value-character
           ,output v-value-date
           ,output v-value-decimal
           ,output v-TimeAvail
           ,output v-value-logical
           ,output v-param-type
           ,input-output table-handle v-tth
           )  .
      delete object v-tth.
      define variable vfl as logical no-undo.
      vfl = logical(GetAttrUserId(buf_lock_user-login.db-num, buf_lock_user-login.user-id, "ChangPwdNextConect")) no-error.
      if    vfl eq yes
         or (     v-TimeAvail ne 0
              and v-DateChg + v-TimeAvail < today)
         or iChange
      then do:
          find first buf_init_user-account where buf_init_user-account.user-id = buf_lock_user-login.user-id
          no-lock.
          assign
          v-encoded-pass-old = buf_lock_user-login.user-password-encoded
          v-encoded-pass     = buf_lock_user-login.user-password-encoded.
          do while v-encoded-pass = v-encoded-pass-old or v-encoded-pass eq ?:
             v-encoded-pass = v-encoded-pass-old.
             run adm/chg-pswd.w ( input  this-procedure
                                , input  p-db-num
                                , input  buf_lock_user-login.user-id
                                , input  buf_lock_user-login.user-login
                                , input  substitute('&1 &2 &3':U, buf_init_user-account.last-name
                                                                , buf_init_user-account.first-name
                                                                , buf_init_user-account.second-name
                                       )
                                , input  iChange
                                , input  yes
                                , input  buf_lock_user-login.user-password-encoded
                                , input  yes
                                , input  buf_lock_user-login.user-administrator
                                , output v-encoded-pass
                                , output v-nextcon
                                ) no-error .
            if error-status :error
            then do:
              message
                 vss-workfile vss-revision vss-description skip
                 "Ошибка при вызове процедуры" 'adm/chg-pswd.w':U skip
                 error-status :get-message(1) skip
                 return-value skip
                 view-as alert-box error .
              undo, return error return-value .
             end.
             if    v-encoded-pass = v-encoded-pass-old
             then do:
                 message
                    vss-workfile vss-revision vss-description skip
                    "Старый пароль и новый равны. Смените пароль.":U skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
             end.
             else if v-encoded-pass eq ?
             then do:
                message  "Отказ от смены пароля. Работа дальше не возможна"
                view-as alert-box error.
                return error "Отказ от смены пароля. Работа дальше не возможна".
             end.
          end.
          if v-encoded-pass <> ? then
          do trans:
             find current buf_lock_user-login
                   exclusive-lock
                .
             assign
                buf_lock_user-login.user-password-encoded = v-encoded-pass
             .
             run SetAttrUserId(buf_lock_user-login.db-num, buf_lock_user-login.user-id, "ChangPwdNextConect", if vChange then v-nextcon else ?).
             run SetAttrUserId(buf_lock_user-login.db-num, buf_lock_user-login.user-id, "ChangPwdUserId", string(g#userid)).
             release buf_lock_user-login .
             message
                "Пароль успешно изменен"
                view-as alert-box information
             .
          end.
       end.
   end.
end procedure.
procedure procedure-user-login-delete :
   define input  parameter i-db-num     as integer          no-undo.
   define input  parameter i-user-id    as character        no-undo.
   define output parameter o-deleted   as logical          no-undo.
   run procedure-user-login-delete-question (i-db-num,i-user-id,yes,output o-deleted).
end.
procedure procedure-user-login-delete-question :
define input  parameter i-db-num     as integer          no-undo.
define input  parameter i-user-id    as character        no-undo.
define input  parameter i-question as logical no-undo.
define output parameter o-deleted   as logical          no-undo.
  define variable v-can-edit as logical   no-undo .
    define buffer buf_user-login         for user-login .
    define buffer buf_user-account       for user-account.
    define buffer buf_init_user-account  for user-account.
do
for buf_user-login
  , buf_user-account
on error undo, return error return-value
:
    assign
        o-deleted = no
    .
    find first buf_init_user-account no-lock
         where buf_init_user-account.user-id = i-user-id
        .
    if available buf_init_user-account
    then do:
      do transaction
      on error undo, return error return-value
      :
        run can-edit-login in this-procedure (
              input  i-db-num
            , output v-can-edit
        ).
        if v-can-edit <> true
        then do:
          message
            "Нельзя удалять логин пользователя для базы" i-db-num
          view-as alert-box error .
          undo, return error return-value .
        end.
        find first buf_user-login exclusive-lock
             where buf_user-login.db-num  = i-db-num
               and buf_user-login.user-id = i-user-id
        no-error no-wait.
        if not available buf_user-login
        then do:
          if locked( buf_user-login )
          then do:
            find first buf_user-login no-lock
                 where buf_user-login.db-num  = i-db-num
                   and buf_user-login.user-id = i-user-id
            .
            message
              "Удаление логина невозможно" skip
              "Пользователь в данный момент работает в системе" skip
              "БД" i-db-num skip
              "Идентификатор" i-user-id skip
              "Псевдоним"                    buf_init_user-account.nik skip
              "Имя пользователя"             buf_init_user-account.last-name buf_init_user-account.first-name buf_init_user-account.second-name skip
              "Компьютер"                    buf_user-login.last-login-computer-name skip
              "Пользователь компьютера"      buf_user-login.last-login-computer-user skip
              "TCP имя компьютера"           buf_user-login.last-login-computer-tcp-name skip
              "IP адрес компьютера"          buf_user-login.last-login-computer-ip-addr skip
              "Идентификатор процесса"       buf_user-login.last-login-process-id skip
              "Номер подключения к БД"       buf_user-login.last-login-connection-id skip
              "Дата и время входа в систему" sys-time_mjd-to-loc-str-func( buf_user-login.last-login-mjd ) skip
              view-as alert-box error .
          end.
          else do:
            message
              "У пользователя нет логина" skip
              "БД" i-db-num skip
              "Идентификатор" i-user-id skip
              "Удаление невозможно" skip
              view-as alert-box error .
          end.
          undo, return error return-value .
        end.
        define variable v-ok as logical   no-undo .
        if not i-question
        then
           v-ok = yes.
        else do:
           find first buf_user-account no-lock
                where buf_user-account.user-id = buf_user-login.user-id
           .
           message
             "Удаление логина пользователя"
             skip "Идентификатор" buf_user-account.user-id
             skip "Псевдоним"    buf_user-account.nik
             skip "Пользователь" buf_user-account.last-name buf_user-account.first-name buf_user-account.second-name
             skip "Логин для базы данных" buf_user-login.db-num
             skip "Логин" buf_user-login.user-login
             skip (1)
             "После удаления пользователь не сможет работать в базе данных" buf_user-login.db-num skip
             skip (1)
             "Продолжить?"
           view-as alert-box question
           buttons yes-no
           update v-ok .
        end.
        if v-ok = yes
        then do:
            run str/usrlog03.p (
                  input buf_user-login.db-num
                , input buf_user-login.user-id
            ).
            assign
                o-deleted = yes
            .
        end.
      end.
    end.
  end.
end procedure.
define input parameter parparentproc                as widget-handle    no-undo .
define input parameter p-parent-handle              as handle           no-undo.
define input parameter p-mode                       as character        no-undo.
define input parameter p-in-user-id                 as character        no-undo.
define input parameter p-in-last-name               as character        no-undo.
define input parameter p-in-first-name              as character        no-undo.
define input parameter p-in-second-name             as character        no-undo.
define input parameter p-in-nik                     as character        no-undo.
define input parameter p-in-phone-number            as character        no-undo.
define input parameter p-in-mobile-phone-number     as character        no-undo.
define input parameter p-in-company                 as character        no-undo.
define input parameter p-in-department              as character        no-undo.
define input parameter p-in-position                as character        no-undo.
define input parameter p-in-room                    as character        no-undo.
define input parameter p-in-e-mail                  as character        no-undo.
define input parameter p-in-internal-phone-number   as character        no-undo.
define input parameter p-in-PS                      as character        no-undo.
define input parameter p-in-psn-code                as integer          no-undo.
define input parameter i-adm-gbd                    as logical          no-undo.
define input parameter i-superAdm                   as logical          no-undo.
define input parameter i-adm-Ubd                    as logical          no-undo.
define input-output parameter table for UserDbAdm .
define output parameter p-out-last-name             as character        no-undo.
define output parameter p-out-first-name            as character        no-undo.
define output parameter p-out-second-name           as character        no-undo.
define output parameter p-out-nik                   as character        no-undo.
define output parameter p-out-phone-number          as character        no-undo.
define output parameter p-out-mobile-phone-number   as character        no-undo.
define output parameter p-out-company               as character        no-undo.
define output parameter p-out-department            as character        no-undo.
define output parameter p-out-position              as character        no-undo.
define output parameter p-out-room                  as character        no-undo.
define output parameter p-out-e-mail                as character        no-undo.
define output parameter p-out-internal-phone-number as character        no-undo.
define output parameter p-out-PS                    as character        no-undo.
define output parameter p-out-psn-code              as integer          no-undo.
define output parameter O-adm-gbd                    as logical          no-undo.
define output parameter o-superAdm                   as logical          no-undo.
define output parameter O-adm-Ubd                    as logical          no-undo.
define output parameter p-accepted                  as logical          no-undo.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable v-user-exit-enabled     as logical      no-undo.
define variable v-user-nik-autofill     as logical      no-undo.
define variable mSyperAdm               as logical      no-undo.
define variable mchenglistubd           as logical no-undo.
FUNCTION GetAdm RETURNS CHARACTER
  (  )  FORWARD.
DEFINE BUTTON b-close AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-psn
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button 1"
     SIZE 3 BY 1.
DEFINE BUTTON btnAdm
     LABEL "Админ/Пользователь"
     SIZE 20 BY 1.
DEFINE BUTTON BtnDel
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE VARIABLE ed-PS AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 32.5 BY 2.25 NO-UNDO.
DEFINE VARIABLE fi-company AS CHARACTER FORMAT "X(256)":U
     LABEL "Организация"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE fi-department AS CHARACTER FORMAT "X(256)":U
     LABEL "Отдел"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE fi-e-mail AS CHARACTER FORMAT "X(256)":U
     LABEL "E-Mail"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE fi-first-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Имя"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE fi-internal-phone-number AS CHARACTER FORMAT "X(256)":U
     LABEL "Раб.телефон"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE fi-last-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Фамилия"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.
DEFINE VARIABLE fi-mobile-phone-number AS CHARACTER FORMAT "X(256)":U
     LABEL "Моб.Телефон"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE fi-nik AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE fi-phone-number AS CHARACTER FORMAT "X(256)":U
     LABEL "Телефон"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE fi-position AS CHARACTER FORMAT "X(256)":U
     LABEL "Должность"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE fi-PS-label AS CHARACTER FORMAT "X(256)":U INITIAL "Примечание:"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE fi-PS-label-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Псевдоним:"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE fi-psn-code AS INTEGER FORMAT "->>>>>>>>9":U INITIAL 0
     LABEL "Физ. лицо"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.
DEFINE VARIABLE fi-room AS CHARACTER FORMAT "X(256)":U
     LABEL "Комната"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE fi-second-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Отчество"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE fi-user-id AS CHARACTER FORMAT "X(256)":U
     LABEL "ID"
      VIEW-AS TEXT
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-psn-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE RAD-adm-gbd AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Администратор ГБД", 1,
"Пользователь ГБД", 3,
"Отсутствует ", 2
     SIZE 28.5 BY 3 NO-UNDO.
DEFINE VARIABLE RAD-adm-Ubd AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Администратор всех Убд", 1,
"Пользователь всех УБД", 3,
"Выборочно ", 2
     SIZE 40.5 BY 3 NO-UNDO.
DEFINE VARIABLE TOG-superAdm AS LOGICAL INITIAL no
     LABEL "Супер Администратор"
     VIEW-AS TOGGLE-BOX
     SIZE 22.5 BY .83 NO-UNDO.
DEFINE QUERY BRUserUbd FOR
      UserDbAdm SCROLLING.
DEFINE BROWSE BRUserUbd
  QUERY BRUserUbd NO-LOCK DISPLAY
      UserDbAdm.db-num COLUMN-LABEL "УБД"
      getadm() COLUMN-LABEL "Роль" format "x(15)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 35.5 BY 7.75 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-close AT ROW 1 COL 11
     b-help AT ROW 1 COL 36.5
     fi-last-name AT ROW 3.5 COL 5.63 WIDGET-ID 2
     RAD-adm-gbd AT ROW 3.5 COL 50 NO-LABEL WIDGET-ID 36
     fi-first-name AT ROW 4.75 COL 9.63 WIDGET-ID 4
     fi-second-name AT ROW 6 COL 4.5 WIDGET-ID 6
     TOG-superAdm AT ROW 6.5 COL 50 WIDGET-ID 38
     fi-PS-label-2 AT ROW 7.25 COL 3 NO-LABEL WIDGET-ID 34
     fi-nik AT ROW 7.25 COL 14.5 NO-LABEL WIDGET-ID 32
     RAD-adm-Ubd AT ROW 7.25 COL 50 NO-LABEL WIDGET-ID 42
     fi-phone-number AT ROW 8.5 COL 5.5 WIDGET-ID 8
     fi-mobile-phone-number AT ROW 9.75 COL 1.5 WIDGET-ID 10
     fi-company AT ROW 11 COL 1.63 WIDGET-ID 12
     BRUserUbd AT ROW 11 COL 51 WIDGET-ID 200
     fi-department AT ROW 12.25 COL 7.5 WIDGET-ID 14
     fi-position AT ROW 13.5 COL 3.5 WIDGET-ID 28
     fi-room AT ROW 14.75 COL 5.5 WIDGET-ID 16
     fi-e-mail AT ROW 16 COL 6.5 WIDGET-ID 18
     fi-internal-phone-number AT ROW 17.25 COL 1.5 WIDGET-ID 22
     fi-psn-code AT ROW 18.5 COL 12.5 COLON-ALIGNED WIDGET-ID 36
     b-psn AT ROW 18.5 COL 26.5 WIDGET-ID 38
     v-psn-name AT ROW 18.5 COL 28 COLON-ALIGNED NO-LABEL WIDGET-ID 40
     fi-PS-label AT ROW 19.75 COL 1.5 NO-LABEL WIDGET-ID 26
     ed-PS AT ROW 19.75 COL 14.5 NO-LABEL WIDGET-ID 24
     btnAdm AT ROW 19 COL 51 WIDGET-ID 46
     BtnDel AT ROW 19 COL 71.5 WIDGET-ID 48
     fi-user-id AT ROW 2.5 COL 10.5 WIDGET-ID 30
     SPACE(61.00) SKIP(19.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Пользователь системы"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-close WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       v-psn-name:READ-ONLY IN FRAME Dialog-Frame          = TRUE
       TOG-superAdm:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
    define variable v-have-error     as logical      no-undo.
    define variable v-error-desc     as character    no-undo.
    define variable v-focus-widget   as handle       no-undo.
    run check-user in this-procedure (
          output v-have-error
        , output v-error-desc
        , output v-focus-widget
    ).
    if v-have-error = yes
    then do:
        if valid-handle( v-focus-widget )
        then do:
            apply "entry" to v-focus-widget.
        end.
        message
            "Ошибка ввода параметров пользователя."
            skip (1)
            skip v-error-desc
        view-as alert-box.
        undo, return no-apply.
    end.
    assign
        v-user-exit-enabled = yes
    .
    if v-user-exit-enabled = yes
    then do:
        assign
            fi-last-name
            fi-first-name
            fi-second-name
            fi-phone-number
            fi-mobile-phone-number
            fi-company
            fi-department
            fi-position
            fi-room
            fi-e-mail
            fi-internal-phone-number
            fi-psn-code
            ed-PS
            rad-adm-gbd
            TOG-superAdm
            RAD-adm-Ubd
        .
        assign
            p-out-last-name             = fi-last-name
            p-out-first-name            = fi-first-name
            p-out-second-name           = fi-second-name
            p-out-nik                   = fi-nik
            p-out-phone-number          = fi-phone-number
            p-out-mobile-phone-number   = fi-mobile-phone-number
            p-out-company               = fi-company
            p-out-department            = fi-department
            p-out-position              = fi-position
            p-out-room                  = fi-room
            p-out-e-mail                = fi-e-mail
            p-out-internal-phone-number = fi-internal-phone-number
            p-out-PS                    = ed-PS
            p-out-psn-code              = fi-psn-code
            o-adm-gbd                   = if rad-adm-gbd eq 1
                                          then yes
                                          else if rad-adm-gbd eq 3
                                          then no
                                          else ?
            o-superAdm                  = TOG-superAdm
            o-adm-Ubd                   = if RAD-adm-Ubd eq 1
                                          then yes
                                          else if RAD-adm-Ubd eq 3
                                          then no
                                          else ?
        .
        if o-adm-ubd eq i-adm-ubd
           and not mchenglistubd
        then
           o-adm-ubd = ?.
        if p-out-last-name              <> p-in-last-name
        or p-out-first-name             <> p-in-first-name
        or p-out-second-name            <> p-in-second-name
        or p-out-nik                    <> p-in-nik
        or p-out-phone-number           <> p-in-phone-number
        or p-out-mobile-phone-number    <> p-in-mobile-phone-number
        or p-out-company                <> p-in-company
        or p-out-department             <> p-in-department
        or p-out-position               <> p-in-position
        or p-out-room                   <> p-in-room
        or p-out-e-mail                 <> p-in-e-mail
        or p-out-internal-phone-number  <> p-in-internal-phone-number
        or p-out-PS                     <> p-in-PS
        or p-out-psn-code               <> p-in-psn-code
        or (o-adm-gbd                   <> i-adm-gbd)
        or o-superAdm                   <> i-superAdm
        or (    o-adm-Ubd ne ?
            and o-adm-Ubd               <> i-adm-Ubd)
        or mchenglistubd
        then do:
            assign
                p-accepted = yes
            .
        end.
    end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-close IN FRAME Dialog-Frame
DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    assign
        v-user-exit-enabled     = yes
        p-accepted              = no
    .
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
END.
ON CHOOSE OF btnAdm IN FRAME Dialog-Frame
DO:
   define variable vrowid as rowid no-undo.
   if available UserDbAdm
   then do:
      if UserDbAdm.db-usr
      then
         if UserDbAdm.db-block
         then do:
            UserDbAdm.db-adm = yes.
            UserDbAdm.db-block = no.
          end.
          else if UserDbAdm.db-adm
          then
             UserDbAdm.db-adm = no.
          else
             UserDbAdm.db-block = yes.
      else
         UserDbAdm.db-usr = yes.
      vrowid = rowid(UserDbAdm).
      BRUserUbd:refresh () no-error.
      reposition BRUserUbd to rowid vrowid no-error .
      mchenglistubd = yes.
   end.
END.
ON CHOOSE OF BtnDel IN FRAME Dialog-Frame
DO:
   define variable vrowid as rowid no-undo.
   if available UserDbAdm
   then do:
      assign
         UserDbAdm.db-adm = no
         UserDbAdm.db-usr = no
         UserDbAdm.db-block = no.
         vrowid = rowid(UserDbAdm)
      .
      BRUserUbd:refresh () no-error.
      reposition BRUserUbd to rowid vrowid no-error .
      mchenglistubd = yes.
   end.
END.
ON CHOOSE OF b-psn IN FRAME Dialog-Frame
DO:
   RUN person-user IN THIS-PROCEDURE ( INPUT-OUTPUT fi-psn-code, INPUT-OUTPUT v-psn-name ).
   display
      fi-psn-code
      v-psn-name
   with frame Dialog-Frame.
END.
ON ANY-PRINTABLE OF fi-last-name IN FRAME Dialog-Frame
or DELETE-CHARACTER OF fi-last-name IN FRAME Dialog-Frame
or BACKSPACE OF fi-last-name IN FRAME Dialog-Frame
or ANY-PRINTABLE OF fi-first-name IN FRAME Dialog-Frame
or DELETE-CHARACTER OF fi-first-name IN FRAME Dialog-Frame
or BACKSPACE OF fi-first-name IN FRAME Dialog-Frame
or ANY-PRINTABLE OF fi-second-name IN FRAME Dialog-Frame
or DELETE-CHARACTER OF fi-second-name IN FRAME Dialog-Frame
or BACKSPACE OF fi-second-name IN FRAME Dialog-Frame
DO:
    if v-user-nik-autofill = yes
    then do:
        assign
            fi-last-name
            fi-first-name
            fi-second-name
        .
    end.
END.
ON VALUE-CHANGED OF fi-last-name IN FRAME Dialog-Frame
or VALUE-CHANGED OF fi-first-name   IN FRAME Dialog-Frame
or VALUE-CHANGED OF fi-second-name  IN FRAME Dialog-Frame
DO:
    if v-user-nik-autofill = yes
    then do:
        assign
            fi-last-name
            fi-first-name
            fi-second-name
        .
        assign
            fi-nik = trim( substitute( "&1 &2 &3", fi-last-name, fi-first-name, fi-second-name ) )
        .
        display
            fi-nik
        with frame Dialog-Frame.
    end.
END.
ON LEAVE OF fi-nik IN FRAME Dialog-Frame
DO:
    assign
        fi-last-name
        fi-first-name
        fi-second-name
        fi-nik
    .
    run get-nik-autofill in this-procedure (
          input fi-last-name
        , input fi-first-name
        , input fi-second-name
        , input fi-nik
        , output v-user-nik-autofill
    ).
END.
ON LEAVE OF fi-psn-code IN FRAME Dialog-Frame
DO:
   define buffer buf_clients     for ub.clients .
   assign
      fi-psn-code
   .
   FIND FIRST buf_clients
        WHERE buf_clients.obj-code = fi-psn-code
          and buf_clients.obj-type = 'чел':U
        no-lock
        no-error
        .
   IF AVAILABLE buf_clients
   THEN DO:
      ASSIGN
         v-psn-name = buf_clients.obj-name
      .
   END.
   ELSE DO:
      assign
         fi-psn-code = ?
         v-psn-name  = "":U
      .
   END.
   display
      fi-psn-code
      v-psn-name
   with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF RAD-adm-gbd IN FRAME Dialog-Frame
DO:
   tog-superadm:visible = rad-adm-gbd:screen-value eq "1".
   if not tog-superadm:visible
   then
      tog-superadm:screen-value = "no".
END.
ON VALUE-CHANGED OF RAD-adm-Ubd IN FRAME Dialog-Frame
DO:
   btnAdm:visible   = RAD-adm-Ubd:screen-value eq "2" and mSyperAdm.
   BtnDel:visible   = RAD-adm-Ubd:screen-value eq "2" and mSyperAdm.
   BRUserUbd:visible = RAD-adm-Ubd:screen-value eq "2" or g#db-num ne 0.
END.
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-exit :sensitive then DO: apply "CHOOSE":U to b-exit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-F7 of frame Dialog-Frame anywhere do:
  if b-close :sensitive then DO: apply "CHOOSE":U to b-close in frame Dialog-Frame. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BRUserUbd :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    run init-fields in this-procedure .
    RUN enable_UI.
    find first user-account-attr where user-account-attr.user-id    eq g#userid
                                   and user-account-attr.attr-code  eq "superadm"
    no-lock no-error.
    if     available user-account-attr
       and logical(user-account-attr.attr-value) eq yes
    then
       mSyperAdm = yes.
    apply "VALUE-CHANGED" to rad-adm-gbd.
    apply "VALUE-CHANGED" to rad-adm-ubd.
    TOG-superAdm:sensitive = mSyperAdm.
    RAD-adm-gbd:sensitive = mSyperAdm.
    RAD-adm-Ubd:sensitive = mSyperAdm.
    RAD-adm-gbd:visible = g#db-num eq 0.
    RAD-adm-Ubd:visible = g#db-num eq 0.
    if p-mode = 'ПРОСМОТР':U
    then do:
        disable
            all
        except
            b-help
            b-close
        with frame Dialog-Frame .
        apply "entry":U to b-close.
    end.
    else do:
        apply "entry":U to fi-last-name.
    end.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-user :
    define output parameter p-have-error    as logical          no-undo.
    define output parameter p-error-desc    as character        no-undo.
    define output parameter p-focus-widget  as handle           no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    if fi-nik :screen-value = "":U
    then do:
        assign
            p-have-error = yes
            p-error-desc = substitute( "Не задан псевдоним пользователя.&1&1Для корректного отображения пользователя в системе&1необходимо определить псевдоним.&1&1Определите псевдоним пользователя.", chr(10) )
            p-focus-widget = fi-nik :handle
        .
    end.
    if fi-last-name :screen-value = "":U
    then do:
        if p-have-error = no
        then do:
            assign
                p-focus-widget = fi-last-name :handle
            .
        end.
        assign
            p-have-error = yes
            p-error-desc = substitute( "&2Не задана фамилия пользователя.&1&1Для корректного отображения пользователя в системе&1необходимо ввести фамилию.&1&1Введите фамилию пользователя."
                                , chr(10)
                                , ( if p-error-desc = "":U then "":U else p-error-desc + chr(10) + chr(10) )
                                )
        .
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-last-name fi-first-name fi-second-name fi-PS-label-2 fi-nik
          fi-phone-number fi-mobile-phone-number fi-company fi-department
          fi-position fi-room fi-e-mail fi-internal-phone-number
          fi-PS-label ed-PS fi-user-id
          fi-psn-code v-psn-name
          RAD-adm-gbd TOG-superAdm RAD-adm-Ubd
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-close b-help fi-last-name fi-first-name fi-second-name fi-nik
         fi-phone-number fi-mobile-phone-number fi-company fi-department
         fi-position fi-room fi-e-mail fi-internal-phone-number ed-PS
         fi-psn-code b-psn v-psn-name
         btnAdm BtnDel
         RAD-adm-gbd TOG-superAdm  RAD-adm-Ubd BRUserUbd
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BRUserUbd FOR EACH UserDbAdm NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE get-nik-autofill :
    define input parameter p-last-name      as character        no-undo.
    define input parameter p-first-name     as character        no-undo.
    define input parameter p-second-name    as character        no-undo.
    define input parameter p-nik            as character        no-undo.
    define output parameter p-nik-autofill  as logical          no-undo.
do
on error undo, return error
:
    if p-nik = trim( substitute( "&1 &2 &3", p-last-name, p-first-name, p-second-name ) )
    then do:
        assign
            p-nik-autofill = yes
        .
    end.
    else do:
        assign
            p-nik-autofill = no
        .
    end.
end.
END PROCEDURE.
PROCEDURE init-fields :
do
on error undo, return error
:
    define buffer buf_clients     for ub.clients .
    assign
        v-user-exit-enabled = no
        p-accepted          = no
    .
    IF p-in-psn-code <> 0
    OR p-in-psn-code <> ?
    THEN DO:
      FIND FIRST buf_clients
           WHERE buf_clients.obj-code = p-in-psn-code
             and buf_clients.obj-type = 'чел':U
           no-lock
           no-error
           .
    END.
    assign
        fi-user-id                  = p-in-user-id
        fi-last-name                = p-in-last-name
        fi-first-name               = p-in-first-name
        fi-second-name              = p-in-second-name
        fi-nik                      = p-in-nik
        fi-phone-number             = p-in-phone-number
        fi-mobile-phone-number      = p-in-mobile-phone-number
        fi-company                  = p-in-company
        fi-department               = p-in-department
        fi-position                 = p-in-position
        fi-room                     = p-in-room
        fi-e-mail                   = p-in-e-mail
        fi-internal-phone-number    = p-in-internal-phone-number
        ed-PS                       = p-in-PS
        fi-psn-code                 = p-in-psn-code
        v-psn-name                  = IF AVAILABLE buf_clients THEN buf_clients.obj-name ELSE "Не найден"
        rad-adm-gbd                 = if i-adm-gbd eq yes
                                      then 1
                                      else if i-adm-gbd eq no
                                      then 3
                                      else 2
        tog-superAdm                = i-superAdm
        rad-adm-Ubd                 = if i-adm-Ubd eq yes
                                      then 1
                                      else if i-adm-Ubd eq no
                                      then 3
                                      else 2
    .
    run get-nik-autofill in this-procedure (
          input fi-last-name
        , input fi-first-name
        , input fi-second-name
        , input fi-nik
        , output v-user-nik-autofill
    ).
end.
END PROCEDURE.
PROCEDURE person-user :
define input-output parameter p-code               as integer          no-undo.
define input-output parameter p-name               as character        no-undo.
do
on error undo, return error
:
   define buffer buf_clients     for ub.clients .
   define variable v-recid-person as character no-undo.
   run ref/cli-all.w ( input parparentproc
                     , input "b-sel"
                     , input 'чел':U
                     , input 'все':U
                     , input 'текущие':U
                     , input ?
                     , input ",,,,,,NO,,"
                     , input "lock-cli-type":U
                     , output v-recid-person
                     ) .
   IF v-recid-person <> "":U
   THEN DO:
      FIND FIRST buf_clients
           WHERE RECID(buf_clients) = INTEGER(ENTRY(1, v-recid-person))
           no-lock
           no-error
           .
      IF AVAILABLE buf_clients
      THEN DO:
         ASSIGN
            p-code = buf_clients.obj-code
            p-name = buf_clients.obj-name
         .
      END.
      ELSE DO:
         assign
            p-code = ?
            p-name = "":U
         .
      END.
   END.
end.
END PROCEDURE.
FUNCTION GetAdm RETURNS CHARACTER
  (  ) :
  RETURN if UserDbAdm.db-adm
         then "Администратор"
         else if UserDbAdm.db-block
         then "Заблокирована"
         else if UserDbAdm.db-usr
         then "Пользователь"
         else "Отсутствует"
           .
END FUNCTION.
