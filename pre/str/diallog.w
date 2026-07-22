define input parameter p-mainmenu-handle        as widget-handle    no-undo.
define input parameter p-parent-handle          as widget-handle    no-undo.
define input parameter p-procedure-name         as character        no-undo.
define input parameter p-procedure-parameter    as character        no-undo.
define input parameter p-auto-go                as logical          no-undo .
define input parameter p-stop-button-label      as character        no-undo.
define input parameter p-title                  as character        no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог вывода лога и счетчика".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    DEF STREAM stm-log.
    PROCEDURE writelog:
    DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
    DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
    DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.
    if p-file-name <> ""
    then do:
    OUTPUT STREAM stm-log TO VALUE(p-file-name) APPEND.
        PUT STREAM stm-log UNFORMATTED chr(10).
        PUT STREAM stm-log UNFORMATTED (IF (p-log-level = 0 OR p-log-string = "&DLine"
                                        OR p-log-string = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        PUT STREAM stm-log UNFORMATTED
                (IF p-log-string = "&Line" THEN FILL("-", 80)
                ELSE IF p-log-string = "&DLine" THEN FILL("=", 80)
                ELSE fill(" ", p-log-level * 2) + p-log-string).
    OUTPUT STREAM stm-log CLOSE.
    end.
    END PROCEDURE.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    DEF STREAM stm-log.
    PROCEDURE writelog-extended:
    DEFine INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
    DEFine INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
    define input parameter p-userid    as character no-undo .
    DEFine INPUT PARAMETER p-log-string AS CHARACTER  NO-UNDO.
    define input parameter p-time-to-wait-seconds as integer no-undo .
    define variable v-log-string as character no-undo .
    if p-file-name <> ""
    then do:
    assign
    v-log-string = (chr(13) + chr(10)) +
                   (IF (p-log-level = 0
                        OR p-log-string = "&DLine"
                        OR p-log-string = "&Line")
                    then '':U
                    else (p-userid + chr(32) + cur-time-string-sec() + chr(32))).
    CASE v-log-string:
      when "&Line" THEN do:
        v-log-string = v-log-string + FILL("-", 80).
      end.
      when "&DLine" THEN do:
        v-log-string = v-log-string + FILL("=", 80).
      end.
      otherwise do:
        v-log-string = v-log-string +  fill(chr(32), p-log-level * 2) +
                       replace(p-log-string, chr(10), (chr(13) + chr(10))).
      end.
    END CASE.
    run gbl/fileapnd.p (
                     input p-file-name
                    ,input v-log-string
                    ,input p-time-to-wait-seconds) no-error .
    if error-status:error then return error return-value .
    end.
    END PROCEDURE.
define variable v-loc-counter           as integer      no-undo .
define variable v-diallog-stop-pressed  as logical      no-undo.
define variable v-diallog-prog-running  as logical      no-undo.
define variable v-view-log as logical no-undo.
define variable v-return-value as character no-undo .
define variable v-error as logical no-undo .
define variable error-message-option as integer no-undo .
define variable auto-go-option as integer no-undo .
define variable return-value-option as integer no-undo .
define variable create-window-option as integer no-undo .
define variable is-internal-option as logical no-undo .
define variable v-comp-name as character no-undo .
define variable v-default-name-flag as integer no-undo .
define variable mprocevent as logical no-undo init yes.
define stream instream.
define temp-table temp-file-name no-undo
field file-name_       as character
field path-file-name_  as character
field blocked as logical
index pi is unique primary
file-name_.
DEFINE VARiable w-diallog AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE ed-log AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 96 BY 19.37 NO-UNDO.
DEFINE VARIABLE fi-log AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 96 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     b-help AT ROW 1.17 COL 88.1
     fi-log AT ROW 2.47 COL 2.1 NO-LABEL
     ed-log AT ROW 3.83 COL 2.1 NO-LABEL
     SPACE(0.77) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Запуск программы".
if not session:batch-mode then
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ed-log:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    if v-diallog-prog-running = yes
    then do:
        assign
            v-diallog-stop-pressed = yes
        .
    end.
    else do:
        assign
            v-diallog-stop-pressed = no
        .
    end.
END.
assign
v-diallog-prog-running = yes
v-diallog-stop-pressed = no
error-message-option = if num-entries(p-procedure-name, chr(4)) > 1
                        then integer(entry(2, p-procedure-name, chr(4)))
                        else 0
auto-go-option       =  if num-entries(p-procedure-name, chr(4)) > 2
                        then integer(entry(3, p-procedure-name, chr(4)))
                        else 0
return-value-option  =  if num-entries(p-procedure-name, chr(4)) > 3
                        then integer(entry(4, p-procedure-name, chr(4)))
                        else 0
create-window-option =  if num-entries(p-procedure-name, chr(4)) > 4
                        then integer(entry(5, p-procedure-name, chr(4)))
                        else 0
is-internal-option   =  if num-entries(p-procedure-name, chr(4)) > 5
                        then logical(entry(6, p-procedure-name, chr(4)))
                        else no
.
if create-window-option = 1 then do:
  PAUSE 0 BEFORE-HIDE.
end.
else do:
  IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
  THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   define variable mSilent as logical no-undo.
  define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame Dialog-Frame:handle.
  mFrameView = not session:batch-mode or mFramHandle:visible.
  publish "IsAsyncProc" (output mSilent).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameoxmError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameoxmError").
      log-manager:write-message("mSilent=" + string(mSilent), "frameoxmError").
      log-manager:write-message("create-window-option=" + string(create-window-option), "frameoxmError").
  end.
   if mSilent ne true
   then do:
     IF create-window-option = 1 THEN DO:
       CREATE WIDGET-POOL.
       RUN create-window IN THIS-PROCEDURE.
     END.
     else do:
       if mFrameView then
         RUN enable_UI.
     end.
  end.
  if mFrameView then
  assign
  frame Dialog-Frame:title = p-title
  b-exit :sensitive   = no
  .
  if p-stop-button-label <> ?
  and p-stop-button-label <> ""
  then do:
        assign
            b-exit :label       = p-stop-button-label
            b-exit :sensitive   = yes
        .
  end.
  if is-internal-option then do:
    define variable v-ii as integer no-undo .
    define variable v-entry as character no-undo .
    do v-ii = 1 to num-entries( entry(1, p-procedure-name, chr(4))):
      v-entry = entry(v-ii, entry(1, p-procedure-name, chr(4))).
      run value ( v-entry) in p-parent-handle (
              input p-mainmenu-handle
            , input p-parent-handle
            , input this-procedure
            , input p-procedure-parameter
        ) no-error.
    end.
  end.
  else do:
  run value ( entry(1, p-procedure-name, chr(4)) ) (
          input p-mainmenu-handle
        , input p-parent-handle
        , input this-procedure
        , input p-procedure-parameter
    ) no-error.
  end.
  if error-status :error
  then do:
    assign
    v-error = error-status:error .
    if error-message-option = 0 then do:
      message
      vss-workfile vss-revision vss-description
        skip "Ошибка при выполнении процедуры " entry(1, p-procedure-name, chr(4))
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        skip return-value
     view-as alert-box error.
     undo, return error .
   end.
 end.
 assign
 v-return-value  = return-value .
 if not p-auto-go
 and auto-go-option = 2
 and return-value = "return"
 then do:
   p-auto-go = yes.
 end.
 if mFrameView and (not p-auto-go
 or (auto-go-option = 1
        and
        (v-error or return-value = "error":U)
       ))
 then do:
    assign
    b-exit :sensitive       = yes
    b-exit :label           = "В&ыход"
    v-diallog-prog-running  = no
    .
    WAIT-FOR GO OF FRAME Dialog-Frame.
  end.
  else if     p-auto-go eq ?
          and v-view-log
          and mFrameView
  then do:
     assign
        b-exit :sensitive       = yes
        b-exit :label           = "В&ыход"
        v-diallog-prog-running  = no
     .
     WAIT-FOR GO OF FRAME Dialog-Frame.
  end.
  if return-value = "error":U then do:
    if     create-window-option = 1
       and mSilent ne true
    THEN DO:
      RUN delete-window IN THIS-PROCEDURE.
    END.
    if valid-handle(p-parent-handle)
    and  lookup( "set-error":U, p-parent-handle :internal-entries ) > 0 then do:
       run set-error in p-parent-handle ( input yes).
    end.
    return "error":U.
  end.
  if v-error and return-value-option = 1 then do:
    if     create-window-option = 1
       and mSilent ne true
    THEN DO:
      RUN delete-window IN THIS-PROCEDURE.
    END.
    if valid-handle(p-parent-handle)
    and lookup( "set-error":U, p-parent-handle :internal-entries ) > 0 then do:
      run set-error in p-parent-handle ( input yes).
    end.
    if valid-handle(p-parent-handle)
    and lookup( "set-error-message":U, p-parent-handle :internal-entries ) > 0 then do:
      run set-error-message in p-parent-handle ( input v-return-value).
    end.
     return error v-return-value.
  end.
  if return-value-option = 1 then do:
    if     create-window-option = 1
       and mSilent ne true
    THEN DO:
      RUN delete-window IN THIS-PROCEDURE.
    END.
    return return-value .
  end.
END.
for each temp-file-name:
  delete temp-file-name.
end.
if     create-window-option = 1
   and mSilent ne true
THEN DO:
  RUN delete-window IN THIS-PROCEDURE.
END.
else do:
  RUN disable_UI.
end.
PROCEDURE copyto-log-and-file :
define input parameter p-source-file as character no-undo.
define input parameter p-tab-position   as integer   no-undo.
define input parameter p-file-name      as character no-undo .
define input parameter p-log-level      as integer   no-undo .
define variable v-str as character no-undo .
if search(p-source-file) = ? then do:
return.
end.
input stream instream from value(p-source-file) .
repeat:
  import stream instream unformatted v-str.
  run write-log-and-file in this-procedure ( input p-tab-position
                                            ,input p-file-name
                                            ,input p-log-level
                                            ,input v-str) no-error.
end.
input stream instream close.
END PROCEDURE.
PROCEDURE create-window :
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
CREATE WINDOW w-diallog
ASSIGN
HIDDEN         = YES
TITLE          = ""
COLUMN         = 1
ROW            = 5.79
HEIGHT         = 22.75
WIDTH          = 99.38
MAX-HEIGHT     = 22.75
MAX-WIDTH      = 99.38
MAX-HEIGHT     = 12.95
MAX-WIDTH      = 78.88
VIRTUAL-HEIGHT = 22.75
VIRTUAL-WIDTH  = 99.38
RESIZE         = no
SCROLL-BARS    = no
STATUS-AREA    = no
BGCOLOR        = ?
FGCOLOR        = ?
MESSAGE-AREA   = no
THREE-D        = yes
SENSITIVE      = yes
RESIZE         = yes
KEEP-FRAME-Z-ORDER = yes
.
ELSE w-diallog = CURRENT-WINDOW.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-diallog)
THEN w-diallog:HIDDEN = no.
ASSIGN
CURRENT-WINDOW                = w-diallog
THIS-PROCEDURE:CURRENT-WINDOW = w-diallog
.
VIEW w-diallog.
view frame Dialog-Frame .
DISPLAY
fi-log
ed-log
WITH FRAME Dialog-Frame in window w-diallog.
ENABLE
b-exit
b-help
ed-log
WITH FRAME Dialog-Frame in window w-diallog.
END PROCEDURE.
PROCEDURE delete-window :
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-diallog)
THEN DELETE WIDGET w-diallog.
END PROCEDURE.
PROCEDURE disable_UI :
  if mFrameView then
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-log ed-log
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help ed-log
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE get-counter-value :
do
on error undo, return error
:
define output parameter p-counter     as integer    no-undo.
    assign
    p-counter  = v-loc-counter
    .
end.
END PROCEDURE.
PROCEDURE get-stop-state :
do
on error undo, return error
:
define output parameter p-stop-state    as logical      no-undo.
    if v-diallog-prog-running
    then do:
        assign
            p-stop-state = v-diallog-stop-pressed
        .
    end.
    else do:
        assign
            p-stop-state = no
        .
    end.
    assign
        v-diallog-stop-pressed = no
    .
end.
END PROCEDURE.
PROCEDURE get-title :
do
on error undo, return error
:
define output parameter p-title     as character    no-undo.
    assign
    p-title = frame Dialog-Frame:title
    .
end.
END PROCEDURE.
PROCEDURE get-view-log :
do
on error undo, return error
:
define output parameter p-view-log     as logical    no-undo.
    assign
    p-view-log = v-view-log
    .
end.
END PROCEDURE.
PROCEDURE hide-counter :
do
on error undo, return error
:
    if mFrameView then
    assign
        fi-log :visible in frame Dialog-Frame = false
    .
    process events.
end.
END PROCEDURE.
PROCEDURE set-counter-value :
do
on error undo, return error
:
define input parameter p-counter     as integer    no-undo.
    assign
    v-loc-counter = p-counter
    .
end.
END PROCEDURE.
PROCEDURE set-title :
do
on error undo, return error
:
define input parameter p-title     as character    no-undo.
    assign
    frame Dialog-Frame:title = p-title
    .
end.
END PROCEDURE.
PROCEDURE set-view-log :
do
on error undo, return error
:
define input parameter p-view-log     as logical    no-undo.
    assign
    v-view-log = p-view-log
    .
end.
END PROCEDURE.
PROCEDURE show-counter :
do
on error undo, return error
:
    if mFrameView then
    assign
        fi-log :visible in frame Dialog-Frame = true
    .
    process events.
end.
END PROCEDURE.
PROCEDURE write-counter :
do
on error undo, return error
:
define input parameter p-counter-string     as character    no-undo.
    if mFrameView then
    assign
        fi-log :screen-value in frame Dialog-Frame = p-counter-string
    .
    process events.
end.
END PROCEDURE.
PROCEDURE write-log :
do
on error undo, return error
:
define input parameter p-tab-position   as integer      no-undo.
define input parameter p-log-string     as character    no-undo.
    ed-log :move-to-eof() in frame Dialog-Frame .
    ed-log :insert-string ( ( if p-tab-position = 0
                                or p-log-string = "&DLine"
                                or p-log-string = "&Line"
                                then ""
                                else cur-time-string-sec() + " "
                          ) ) in frame Dialog-Frame.
    ed-log :insert-string ( ( if p-log-string = "&Line"
                                then fill( "-", 80 )
                                else if p-log-string = "&DLine" then fill("=", 80)
                                else fill( " ", p-tab-position) + p-log-string
                          ) ) in frame Dialog-Frame.
    ed-log :insert-string ( chr(10) ) in frame Dialog-Frame.
    if mprocevent
    then
       process events.
end.
END PROCEDURE.
PROCEDURE write-log-and-file-noprocevent :
  define input parameter p-tab-position   as integer   no-undo.
  define input parameter p-file-name      as character no-undo .
  define input parameter p-log-level      as integer   no-undo .
  define input parameter p-log-string     AS CHARacter NO-UNDO.
   mprocevent = no.
   run write-log-and-file( p-tab-position,p-file-name,p-log-level,p-log-string)no-error.
   mprocevent = yes.
END PROCEDURE.
PROCEDURE write-log-and-file :
do
on error undo, return error
:
  define input parameter p-tab-position   as integer   no-undo.
  define input parameter p-file-name      as character no-undo .
  define input parameter p-log-level      as integer   no-undo .
  define input parameter p-log-string     AS CHARacter NO-UNDO.
  define variable v-file-name as character no-undo .
  define variable v-ext       as character no-undo .
  define variable v-ind1 as integer no-undo .
  define variable v-ind2 as integer no-undo .
  define variable v-ind as integer no-undo .
  define variable v-path as character no-undo .
  define variable v-path-file-name as character no-undo .
  define variable v-can-write as logical no-undo .
  define variable v-sys-time-string as character no-undo .
  define variable v-only-dir as logical no-undo .
  define buffer buf_temp-file-name for temp-file-name.
  run write-log in this-procedure(
                                  input  p-tab-position
                                 ,input  p-log-string     ) .
  if g#news then do:
    assign
    v-ext = (if num-entries(p-file-name, '.') = 2
             then entry(2, p-file-name, '.')
             else '':U)
    v-file-name = substitute("&1_from_db_&2.&3"
                             ,entry(1, p-file-name, '.')
                             ,g#news-source-db
                             ,v-ext).
  end.
  else do:
    v-file-name = p-file-name.
  end.
  find first buf_temp-file-name where
            buf_temp-file-name.file-name_ = v-file-name no-error .
  if not available buf_temp-file-name then do:
    if index(v-file-name, chr(47)) > 0
    or index(v-file-name, chr(92)) > 0 then do:
      assign
      v-ind1 = r-index(v-file-name, chr(92))
      v-ind2 = r-index(v-file-name, chr(47))
      v-ind  = max(v-ind1, v-ind2)
      v-path = substring(v-file-name, 1, v-ind - 1)
      .
      FILE-INFO:FILE-NAME = v-path.
      if file-info:FULL-pathname = ? then do:
         if not g#auto then do:                       message substitute("Вывод в файл &1 невозможен&2Нет такого файла"                             ,v-file-name                                                                                                      ,chr(10)) view-as alert-box error.                      end.
      end.
      assign
      v-path-file-name = FILE-INFO:FULL-pathname
      v-can-write = index(FILE-INFO:file-type, 'W') > 0.
      if not v-can-write then do:
         if not g#auto then do:                       message substitute("Вывод в файл &1 невозможен&2Отсутствует право на запись в директорию"                             ,v-path-file-name                                                                                                      ,v-path                                                                                                           ,chr(10)) view-as alert-box error.                      end.
      end.
      if index(FILE-INFO:file-type, 'D') > 0 then do:
        assign
        v-only-dir          = yes
        v-default-name-flag = (if v-default-name-flag = 0 then 1 else v-default-name-flag)
        v-file-name      = entry(1, ENTRY(1, p-procedure-name, chr(4)), '.') + '.log'
        v-path-file-name = v-path-file-name + chr(92) + v-file-name
        .
        v-file-name      = ENTRY(1, p-procedure-name, chr(4)).
        .
      end.
    end.
    else do:
      IF V-FILE-NAME = '':u THEN DO:
        assign
        v-default-name-flag = (if v-default-name-flag = 0 then 1 else v-default-name-flag)
        v-file-name      = entry(1, ENTRY(1, p-procedure-name, chr(4)), '.') + '.log'.
        v-file-name      = entry(num-entries(v-file-name,chr(92)),v-file-name,chr(92)).
        v-file-name      = entry(num-entries(v-file-name,chr(47)),v-file-name,chr(47)).
        .
      END.
      FILE-INFO:FILE-NAME = '.'.
      assign
      v-path = FILE-INFO:FULL-pathname
      v-can-write = index(FILE-INFO:file-type, 'W') > 0.
      if not v-can-write then do:
        if not g#auto then do:                       message substitute("Вывод в файл &1 директории &2 невозможен&3Отсутствует право на запись в директорию"                                    ,v-file-name                                                                                                       ,v-path                                                                                                            ,chr(10)) view-as alert-box error.                      end.
      end.
      assign
      v-path-file-name = v-path + chr(92) + v-file-name.
    end.
    FILE-INFO:FILE-NAME = v-path-file-name.
    assign
    v-can-write = index(FILE-INFO:file-type, 'W') > 0.
    .
    if not v-can-write then do:
      if not g#auto then do:                       message substitute("Вывод в файл &1&3Отсутствует право на запись в файл"                                   ,v-path-file-name                                                                  ,v-path                                                                            ,chr(10)) view-as alert-box error.                      end.
    end.
    assign
    v-path-file-name                   = replace(v-path-file-name, chr(47), chr(92))
    v-file-name                        = entry(num-entries(v-path-file-name, chr(92)), v-path-file-name, chr(92))
    .
    if v-default-name-flag >= 2
    and (p-file-name = '':U or v-only-dir) then do:
      find first buf_temp-file-name where
                buf_temp-file-name.file-name_ = v-file-name no-error .
    end.
    else do:
      find first buf_temp-file-name where
                buf_temp-file-name.file-name_ = v-file-name no-error .
      if not available buf_temp-file-name then do :
        create buf_temp-file-name.
        assign
        buf_temp-file-name.file-name_      = v-file-name
        buf_temp-file-name.path-file-name_ = v-path-file-name
        v-default-name-flag = (if v-default-name-flag = 1 then 2 else v-default-name-flag)
        .
        assign
        v-sys-time-string = sys-time_get-sys-str-func() no-error .
        run gbl/compname.p (output v-comp-name) no-error .
        run writelog-extended in this-procedure(
                                        input buf_temp-file-name.path-file-name_
                                        ,input 3
                                        ,input g#userid
                                        ,input substitute("&1 &2", v-sys-time-string, v-comp-name)
                                        ,input 3
                                      ) no-error .
        if error-status:error then do:
              if not g#auto then do:                       message substitute("Ошибка при выводе в файл:&1&2&1&3", chr(10), error-status:get-message(1), return-value ) view-as alert-box error.                      end.
        end.
      end.
    end.
  end.
  if not buf_temp-file-name.blocked then do:
    run writelog-extended in this-procedure(
                                    input buf_temp-file-name.path-file-name
                                    ,input p-log-level
                                    ,input g#userid
                                    ,input p-log-string
                                    ,input 3
                                  ) no-error .
    if error-status:error then do:
      if not g#auto then do:                       message substitute("Ошибка при выводе в файл:&1&2&1&3", chr(10), error-status:get-message(1), return-value ) view-as alert-box error.                      end.
    end.
  end.
end.
END PROCEDURE.
