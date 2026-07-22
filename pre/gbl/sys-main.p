block-level on error undo, throw.
define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 56df01381172, 3646, test $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2024/01/25 16:33:00 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sys-main.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/sys-main.p $":U .
define variable vss-description as character no-undo init "Головной модуль системы".
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
define new  shared variable g#auto as logical no-undo.
define new  shared variable g#news as logical no-undo.
define new  shared variable g#oxml as logical no-undo.
define new  shared variable g#esys as logical no-undo.
define new  shared variable g#news-source-db as integer no-undo.
define new  shared variable g#esys-source-esys as integer no-undo.
define new  shared variable g#db-num as integer   no-undo .
define new  shared variable g#userid as character no-undo .
define new  shared variable g#passwd as character no-undo .
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
procedure cmptime :
do
on error undo, return error
:
define output parameter p-difference as decimal      no-undo.
define variable v-srv-time      as decimal           no-undo.
define variable v-cli-time      as decimal           no-undo.
assign
    session :time-source = "ub":U
    v-srv-time = integer(today) + ( time / 86400 )
.
assign
    session :time-source = "LOCAL":U
    v-cli-time = integer(today) + ( time / 86400 )
.
assign
    p-difference = ( v-srv-time - v-cli-time ) * 1440
.
end.
end procedure.
procedure cmptime-time-diff :
do
on error undo, return error
:
define input parameter p-date1          as date         no-undo.
define input parameter p-time1          as integer      no-undo.
define input parameter p-date2          as date         no-undo.
define input parameter p-time2          as integer      no-undo.
define output parameter p-difference    as decimal      no-undo.
    assign
        p-difference = ( integer( p-date2 ) - integer( p-date1 ) + ( ( p-time2 - p-time1 ) / 86400 ) ) * 1440
    .
end.
end procedure.
procedure cmptime-string-to-hms :
do
on error undo, return error
:
define input parameter p-time-string as character    no-undo.
define input parameter p-format      as character    no-undo.
define output parameter p-hour as integer      no-undo.
define output parameter p-min  as integer      no-undo.
define output parameter p-sec  as integer      no-undo.
if p-format <> "hh:mm" and p-format <> "hh:mm:ss"
then do:
    message
      "cmptime.i: Ошибка преобразования строки даты"
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
assign
    p-hour      = integer ( entry( 1, p-time-string, ":" ) )
    p-min       = integer ( entry( 2, p-time-string, ":" ) )
    p-sec       = ( if p-format = "hh:mm:ss"
                    then integer ( entry( 3, p-time-string, ":" ) )
                    else 0
                  )
.
end.
end procedure.
procedure cmptime-hms-to-integer :
do
on error undo, return error
:
define input parameter p-hour   as integer      no-undo.
define input parameter p-min    as integer      no-undo.
define input parameter p-sec    as integer      no-undo.
define output parameter p-time  as integer      no-undo.
    assign
        p-time = p-hour * 3600 + ( p-min * 60 ) + p-sec
    .
end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-ro_get-read-only :
  define output parameter p-ro-set as logical   no-undo .
  do
  on error  undo, return error substitute( "&1(get-ro_get-read-only). &2&3&4", vss-include-info3, return-value, error-status :get-message( 1 ) )
  on stop   undo, return error substitute( "&1(get-ro_get-read-only). stop", vss-include-info3 )
  on endkey undo, return error substitute( "&1(get-ro_get-read-only). endkey", vss-include-info3 )
  :
    if lookup( 'READ-ONLY':U, DBRESTRICTIONS('ub':U) ) > 0
    then do:
      assign
        p-ro-set = true
      .
    end.
    else do:
      assign
        p-ro-set = false
      .
    end.
  end.
end procedure.
define variable conf-par               as character no-undo .
define variable par-type               as character no-undo .
define variable v-today                as date      no-undo .
define variable v-time                 as integer   no-undo .
define variable v-diff-time            as decimal   no-undo .
define variable v-max-diff-minute      as integer   no-undo initial 3 .
define variable v-computer-name        as character no-undo .
define variable v-computer-tcp-name    as character no-undo .
define variable v-computer-ip-addr     as character no-undo .
define variable v-computer-login-name  as character no-undo .
define variable v-computer-process-pid as integer   no-undo .
define variable v-connect-usr          as integer   no-undo .
define variable v-connect-device       as character no-undo .
define variable v-userio-id            as integer   no-undo .
define variable v-get-ro_read-only     as logical   no-undo .
define variable v-vid-ok            as logical  no-undo .
define variable v-vid-mes           as character no-undo .
define variable v-vid-param         as longchar no-undo .
define buffer buf_sys-ctrl     for ub.sys-ctrl .
define buffer buf_user-account for ub.user-account .
define buffer buf_user-login   for ub.user-login .
define buffer buf_db           for ub.db .
define variable v-TH-name as character no-undo .
do
on error undo, return error return-value
:
  run sys-time_get-comp-user-name in this-procedure
    (output v-computer-name
    ,output v-computer-login-name
    ,output v-computer-process-pid
    ) .
  run cmptime in this-procedure
    (output v-diff-time
    ).
  if absolute(v-diff-time) > v-max-diff-minute
  then do:
    v-vid-param = "Login=" + p-user-login + chr(4) + "RESULT=110" + chr(4) + "Description=Время на компьютере отличается от времени на сервере" .
    run trg/video-action.p (input 50,
                        input v-vid-param,
                        output v-vid-ok,
                        output v-vid-mes) .
    message
      "Текущее время на Вашем компьютере " skip
      "" (if v-diff-time < 0 then "больше" else "меньше" ) " времени на сервере " skip
      "на " truncate( abs( v-diff-time ), 0 ) "минут(ы)" skip (1)
      substitute("Время на компьютере и время на сервере не должны различаться более чем на &1 минуты."
                ,v-max-diff-minute
                ) skip (1)
      substitute("Вход в систему с компьютера &1 невозможен", v-computer-name) skip
      view-as alert-box error .
    return .
  end.
  assign
    v-get-ro_read-only = false
  .
  run get-ro_get-read-only in this-procedure
    ( output v-get-ro_read-only
    ) .
  do transaction
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock .
    if v-get-ro_read-only = false then do:
      find buf_user-login exclusive-lock
        where buf_user-login.db-num     = buf_sys-ctrl.db-num
          and buf_user-login.status_    = 0
          and buf_user-login.user-login = p-user-login
        no-error no-wait .
    end.
    else do:
      find buf_user-login no-lock
        where buf_user-login.db-num     = buf_sys-ctrl.db-num
          and buf_user-login.status_    = 0
          and buf_user-login.user-login = p-user-login
        no-error .
    end.
    if not available buf_user-login
    then do:
      if locked buf_user-login
        and v-get-ro_read-only = false
      then do:
        find buf_user-login no-lock
          where buf_user-login.db-num     = buf_sys-ctrl.db-num
            and buf_user-login.status_    = 0
            and buf_user-login.user-login = p-user-login
          no-error .
        if available buf_user-login
        then do:
          define variable v-user-name as character no-undo .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  buf_user-login.user-id
  ,output v-user-name
  )  .
          v-vid-param = "Login=" + p-user-login + chr(4) + "THname=" + v-user-name + chr(4) + "RESULT=111" + chr(4) + "Description=Такой пользователь уже работает в системе." .
          run trg/video-action.p (input 50,
                                input v-vid-param,
                                output v-vid-ok,
                                output v-vid-mes) .
          message
            substitute("Пользователь &1 уже работает в системе", p-user-login) skip
            "Идентификатор пользователя"   buf_user-login.user-id skip
            "Имя пользователя"             v-user-name skip
            "Компьютер"                    buf_user-login.last-login-computer-name skip
            "Пользователь компьютера"      buf_user-login.last-login-computer-user skip
            "TCP имя компьютера"           buf_user-login.last-login-computer-tcp-name skip
            "IP адрес компьютера"          buf_user-login.last-login-computer-ip-addr skip
            "Идентификатор процесса"       buf_user-login.last-login-process-id skip
            "Номер подключения к БД"       buf_user-login.last-login-connection-id skip
            "Дата и время входа в систему" sys-time_mjd-to-loc-str-func(buf_user-login.last-login-mjd) skip
            view-as alert-box error .
        end.
        else do:
          v-vid-param = "Login=" + p-user-login + chr(4) + "RESULT=112" + chr(4) + "Description=Такой пользователь уже работает в системе." .
          run trg/video-action.p (input 50,
                                input v-vid-param,
                                output v-vid-ok,
                                output v-vid-mes) .
          message
            substitute("Пользователь &1 уже работает в системе", p-user-login) skip
            view-as alert-box error .
        end.
      end.
      else do:
        v-vid-param = "Login=" + p-user-login + chr(4) + "RESULT=113" + chr(4) + "Description=Не найден такой пользователь." .
        run trg/video-action.p (input 50,
                                input v-vid-param,
                                output v-vid-ok,
                                output v-vid-mes) .
        message
          substitute("Не найден пользователь &1", p-user-login) skip
          "Невозможно продолжить работу системы" skip
          view-as alert-box error .
      end.
      return.
    end.
    define variable v-last-login-mjd as decimal   no-undo .
    assign
      v-last-login-mjd = sys-time_get-mjd-func()
    .
    run gbl/getconn.p
      (output v-connect-usr
      ,output v-connect-device
      ,output v-userio-id
      ) .
    run gbl/tcp-info.p
      (output v-computer-tcp-name
      ,output v-computer-ip-addr
      ) .
    if v-get-ro_read-only = false then do:
      assign
        buf_user-login.last-login-computer-name     = v-computer-name
        buf_user-login.last-login-computer-user     = v-computer-login-name
        buf_user-login.last-login-computer-tcp-name = v-computer-tcp-name
        buf_user-login.last-login-computer-ip-addr  = v-computer-ip-addr
        buf_user-login.last-login-process-id        = v-computer-process-pid
        buf_user-login.last-login-connection-id     = v-connect-usr
        buf_user-login.last-login-mjd               = v-last-login-mjd
      .
    end.
    run gbl/set-gbl.p
    (input false
    ,input buf_user-login.user-id
    ,input p-user-password
    ) no-error .
    if error-status :error
    then do:
       v-vid-param = "Login=" + p-user-login + chr(4) + "RESULT=114" + chr(4) + "Description=Ошибка при установке глобальных переменных." .
       run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
       message
      vss-workfile vss-revision vss-description skip
      "Ошибка при установке глобальных переменных" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
       return .
     end.
  end.
  do transaction:
    find first buf_db exclusive-lock where buf_db.db-num = buf_sys-ctrl.db-num and buf_db.reserve2-char = "deferred-callnews" no-error.
    if available (buf_db)
    then do:
      buf_db.reserve2-char = "".
      release buf_db.
    end.
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'lcns-lim':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  yes
  ,output conf-par
  ,output par-type
  ) no-error .
  if error-status :error
  then do:
    return.
  end.
  if par-type <> 'T':U
  then do:
    message
      "Неправильный тип параметра lcns-lim (должно быть date)."
      view-as alert-box error.
    return.
  end.
  if date (conf-par) <> ?
  then do:
    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ).
    define variable v-license-left-day as integer   no-undo .
    assign
      v-license-left-day = date (conf-par) - v-today
    .
    if v-license-left-day <= 15
    then do:
      message
        "Срок действия лицензии истекает" date (conf-par) skip
        substitute("Осталось &1 дней", v-license-left-day) skip
        view-as alert-box error.
    end.
    if v-license-left-day < 0
    then do:
      v-vid-param = "Login=" + p-user-login + chr(4) + "RESULT=115" + chr(4) + "Description=Срок действия лицензии закончился." .
      run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
      message
        "Срок действия лицензии закончился" date (conf-par) skip
        "Вход в систему невозможен" skip
        view-as alert-box error.
      return .
    end.
  end.
  if v-get-ro_read-only = false then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'usr-num':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  yes
  ,output conf-par
  ,output par-type
  ) no-error .
    if error-status :error
    then do:
      return.
    end.
    if par-type <> 'I':U
    then do:
      message
        "Неправильный тип параметра usr-num (должно быть integer)."
        view-as alert-box error .
      return.
    end.
    define variable v-license-usr-num as integer   no-undo .
    define variable v-work-usr-num    as integer   no-undo .
    assign
      v-license-usr-num = integer (conf-par)
    .
    run adm/isanybdy.p
      (input  false
      ,input  0
      ,input  '':U
      ,output v-work-usr-num
      ).
    if v-license-usr-num = ?
    then do:
      v-vid-param = "Login=" + p-user-login + chr(4) + "RESULT=116" + chr(4) + "Description=Не задано количество пользователей системы." .
      run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
      message
        "Доступ запрещен: не задано количество пользователей системы" conf-par skip
        view-as alert-box error.
      return.
    end.
    if v-work-usr-num >= v-license-usr-num
    then do:
      v-vid-param = "Login=" + p-user-login + chr(4) + "RESULT=117" + chr(4) + "Description=Превышено число пользователей системы." .
      run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
      message
        "Доступ запрещен: превышено число пользователей" conf-par skip
        view-as alert-box error.
      return .
    end.
    if current-value (s-bcgb-code, ub) < 100000
    then do:
      assign
        current-value (s-bcgb-code, ub) = 100000
      .
    end.
    if current-value (s-sclc-code, ub) < 100
    then do:
      assign
        current-value (s-sclc-code, ub) = 100
      .
    end.
    if current-value (s-scgb-code, ub) < 100
    then do:
      assign
        current-value (s-scgb-code, ub) = 100
      .
    end.
    if current-value (s-news-ord, ub) < 0
    then do:
      assign
        current-value (s-news-ord, ub) = 0
      .
    end.
  end.
  run gbl/update.p no-error .
  if error-status :error then do:
    v-vid-param = "Login=" + p-user-login + chr(4) + "RESULT=118" + chr(4) + "Description=Ошибка при проверке соответствия r-cod-ов внутренним структурам данных." .
    run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке соответствия r-cod-ов внутренним структурам данных" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return .
  end.
  if v-get-ro_read-only = false then do:
    run adm/infdbnws.p no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при анализе/записи информации о БД" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return .
    end.
  end.
  run ibs/th/adm/upd/sendschedule.p no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при отправке начальных расписаний автозаданий в 1С" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return .
  end.
  if available buf_user-login
  then do :
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  buf_user-login.user-id
  ,output v-TH-name
  )  .
  end.
  v-vid-param = "Login=" + p-user-login + chr(4) +
                (if v-TH-name <> "" then ("THname=" + v-TH-name + chr(4)) else "") +
                "RESULT=0" + chr(4) +
                "Description=" .
  run trg/video-action.p (input 50,
                            input v-vid-param,
                            output v-vid-ok,
                            output v-vid-mes) .
  run gbl/mainmenu.w
    (input v-computer-process-pid
    ,input buf_user-login.user-id
    ,input p-user-password
    ) no-error .
  if error-status :error
  then do:
    message
      "Ошибка вызова основного окна системы" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error.
  end.
end.
