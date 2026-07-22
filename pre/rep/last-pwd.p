block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: b30922a289ff, 3175, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:24 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: last-pwd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/last-pwd.p $":U .
define variable vss-description as character no-undo init "Процедура для записи истории по БД добавляемые в группу".
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
DEFINE VARIABLE v-TabUserAdm as handle no-undo.
DEFINE stream OutStr-html.
DEFINE INPUT  PARAMETER  v-report-name-html-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE us_id     AS CHARACTER LABEL "id" FORMAT "x(256)" no-undo.
DEFINE VARIABLE us_name   AS CHARACTER LABEL "us_NAME" FORMAT "x(256)" no-undo.
DEFINE VARIABLE us_login  AS CHARACTER LABEL "us_NAME" FORMAT "x(256)" no-undo.
DEFINE VARIABLE adm_id    AS CHARACTER LABEL "id" FORMAT "x(256)" no-undo.
DEFINE VARIABLE adm_name  AS CHARACTER LABEL "us_NAME" FORMAT "x(256)" no-undo.
DEFINE VARIABLE adm_login AS CHARACTER LABEL "us_NAME" FORMAT "x(256)" no-undo.
DEFINE VARIABLE us_phone  AS CHARACTER FORMAT "x(32)" no-undo.
DEFINE VARIABLE us_mobile AS CHARACTER FORMAT "x(32)" no-undo.
DEFINE VARIABLE us_email  AS CHARACTER FORMAT "x(32)"no-undo.
DEFINE VARIABLE us_dep    AS CHARACTER FORMAT "x(32)" no-undo.
DEFINE VARIABLE us_dbnum  AS CHARACTER no-undo.
DEFINE VARIABLE us_adm    AS CHARACTER no-undo.
DEFINE VARIABLE vdate     AS CHARACTER no-undo.
DEFINE VARIABLE vtime     AS INT       no-undo.
define buffer buf_user-login   for ub.user-login .
define buffer buf_user-account for ub.user-account .
output stream OutStr-html to value(v-report-name-html-list) convert target 'UTF-8' .
put stream OutStr-html unformatted
"<!DOCTYPE HTML>" skip
' <html>' skip
'  <head>' skip
'   <meta charset="utf-8">' skip
'    <style type="text/css">' skip
'      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black;' + chr(125) skip
'   </style>' skip
'  </head>' skip
   '<body>' skip
   '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
   '<thead>' skip
   ' <tr class="set_columns">' skip
   ' <td style="width:50px"></td>' skip
   ' <td style="width:200px"></td>' skip
   ' <td style="width:120px"></td>' skip
   ' <td style="width:70px"></td>' skip
   ' <td style="width:150px"></td>' skip
   ' <td style="width:150px"></td>' skip
   ' <td style="width:150px"></td>' skip
   ' <td style="width:150px"></td>' skip
   ' <td style="width:150px"></td>' skip
   '</tr>' skip
   '<tr><!-- шапка таблицы -->' skip
   '<td colspan="8" style="text-align: right;"></td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="11" style="font-weight: bold; text-align: center;">Отчет о смене пароля пользователем</td>' skip
   '</tr>' skip
   '</thead>' skip
   '<tr>' skip
   '<td text_wrap="true" colspan=3 style="width: 250px; text-align: center; border: 1px solid black;">Для кого поменяли пароль:</td>' skip
   '<td text_wrap="true" colspan=3 style="width: 250px; text-align: center; border: 1px solid black;">Кто поменял пароль:</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 120px; text-align: center; border: 1px solid black;">Дата и время смены пароля</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 70px; text-align: center; border: 1px solid black;">Телефон</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 150px; text-align: center; border: 1px solid black;">Мобильный телефон</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 150px; text-align: center; border: 1px solid black;">e-mail</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 150px; text-align: center; border: 1px solid black;">Отдел</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 150px; text-align: center; border: 1px solid black;">№ БД</td>' skip
   '<td text_wrap="true" rowspan=2 style="width: 150px; text-align: center; border: 1px solid black;">Адм.БД</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td text_wrap="true" style="width: 50px; text-align: center;">User ID </td>' skip
   '<td text_wrap="true" style="width: 100px; text-align: center;">Пользователь</td>' skip
   '<td text_wrap="true" style="width: 100px; text-align: center;">Логин</td>' skip
   '<td text_wrap="true" style="width: 50px; text-align: center;">User ID </td>' skip
   '<td text_wrap="true" style="width: 100px; text-align: center;">Пользователь</td>' skip
   '<td text_wrap="true" style="width: 100px; text-align: center;">Логин</td>' skip
   '</tr>' skip
   '<tbody>'
   .
FOR EACH user-account no-lock where user-account.status_ <> 1:
   FOR EACH user-login WHERE user-login.user-id = user-account.user-id NO-LOCK:
      vdate  = ''.
      vtime  = 0.
      us_id = "".
      us_name = "".
      us_login = "" .
      adm_id = "".
      adm_name = "".
      adm_login = "" .
      us_phone = "".
      us_mobile = "".
      us_email = "".
      us_dep  = "".
      us_dbnum = "".
      if user-account.status_ = 0 AND user-login.status_ = 0
         then
      do:
         us_id = user-account.user-id.
         us_name = user-account.first-name + " " + user-account.last-name.
         us_login = user-login.user-login .
         us_phone = user-account.phone-number.
         us_mobile = user-account.mobile-phone-number.
         us_email = user-account.e-mail.
         us_dep  = user-account.department.
         us_dbnum = STRING(user-login.db-num).
         if user-login.user-administrator = yes then us_adm = 'админ.бд.'.
         else if user-login.user-administrator <> yes  then us_adm = ' '.
         run cur-time-mjd-to-date (user-login.user-password-set-mjd, output vdate, output vtime).
         if date(vdate) < 01/01/1900 then do:
            vdate = "" .
            vtime = 0 .
         end.
         find first user-login-attr no-lock where user-login-attr.attr-code = "ChangPwdUserId" and user-login-attr.user-id = user-login.user-id and
         user-login-attr.db-num = user-login.db-num no-error .
            if available (user-login-attr) then do:
            adm_id = user-login-attr.attr-value .
            FOR first buf_user-login WHERE buf_user-login.user-id = user-login-attr.attr-value NO-LOCK,
               first buf_user-account no-lock where buf_user-account.user-id = buf_user-login.user-id:
               adm_login = buf_user-login.user-login .
               adm_name = buf_user-account.first-name + " " + buf_user-account.last-name.
            end.
         end.
         else do:
            if vdate <> "" then do:
            adm_id = us_id .
            adm_login = us_login .
            adm_name = us_name .
            end.
         end.
         put stream OutStr-html unformatted
            '<tr>' skip
            '<td text_wrap="true" style="width: 50px;">' us_id '</td>' skip
            '<td text_wrap="true" style="width: 100px;">' us_name '</td>' skip
            '<td text_wrap="true" style="width: 100px;">' us_login '</td>' skip
            '<td text_wrap="true" style="width: 50px;">' adm_id '</td>' skip
            '<td text_wrap="true" style="width: 100px;">' adm_name '</td>' skip
            '<td text_wrap="true" style="width: 100px;">' adm_login '</td>' skip
            '<td text_wrap="true" style="width: 120px;">' vdate ' ' if vtime = 0 then "" else STRING(vtime, "HH:MM")  '</td>' skip
            '<td text_wrap="true" style="width: 70px;">' us_phone '</td>' skip
            '<td text_wrap="true" style="width: 150px;">' us_mobile '</td>' skip
            '<td text_wrap="true" style="width: 150px;">' us_email '</td>' skip
            '<td text_wrap="true" style="width: 150px;">' us_dep '</td>' skip
            '<td text_wrap="true" style="width: 150px;">' us_dbnum  '</td>' skip
            '<td text_wrap="true" style="width: 150px;">' us_adm  '</td>' skip
            '</tr>' skip
            .
      END.
    END.
END.
put stream OutStr-html unformatted
'<tbody>' skip
'</table>'
.
output stream OutStr-html close.
