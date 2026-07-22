CREATE WIDGET-POOL.
define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define input  parameter p-port          as integer   no-undo .
define input  parameter p-pos-num       as integer   no-undo .
define input  parameter p-auto-start    as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно запуска сервера".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define stream slog.
define temp-table tt-cli-socket no-undo
  field sock-handle     as handle
  field remote-host     as character
  field remote-port     as integer
  field conn-time       as integer
  field last-conn-time  as integer
index pi is primary unique
  sock-handle
.
define temp-table tt-log no-undo
  field id            as integer
  field log-date      as date
  field log-time      as integer
  field log-text      as character
  field remote-host   as character
  field remote-port   as integer
index pi is primary unique
  id
.
define variable v-server-socket     as handle    no-undo .
define variable v-server-running    as logical   no-undo .
define variable v-retval            as logical   no-undo .
define variable v-log-id            as integer   no-undo .
define variable v-mt-route-handle   as handle    no-undo .
define variable v-mt-route-loaded   as logical   no-undo .
define variable v-cfg-max-user-num      as integer   no-undo .
define variable v-cfg-timeout           as integer   no-undo .
define buffer buf_sys-ctrl   for ub.sys-ctrl .
define buffer buf_user-login for ub.user-login .
define buffer buf_cash-desk  for ub.cash-desk.
procedure crc32 external "crc32.dll" CDECL :
    define input    parameter p-crc    as long.
    define input    parameter p-array  as memptr.
    define input    parameter p-len    as long.
    define return   parameter p-crc32  as unsigned-long.
end.
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помощь"
     SIZE 10 BY 1.
DEFINE BUTTON b-prop
     LABEL "&Настройки"
     SIZE 10 BY 1.
DEFINE BUTTON b-start
     LABEL "&Старт"
     SIZE 10 BY 1.
DEFINE BUTTON b-stop
     LABEL "&Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE fi-last-conn-time AS CHARACTER FORMAT "X(256)":U
     LABEL "Последнее соединение"
      VIEW-AS TEXT
     SIZE 58 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-port AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Порт"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE fi-pos-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Номер кассы"
      VIEW-AS TEXT
     SIZE 20 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-pos-type AS CHARACTER FORMAT "X(256)":U INITIAL "0"
     LABEL "Тип кассы"
      VIEW-AS TEXT
     SIZE 20 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-users AS CHARACTER FORMAT "X(256)":U
     LABEL "Пользователи"
      VIEW-AS TEXT
     SIZE 64.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE r-semaphore
     EDGE-PIXELS 1 GRAPHIC-EDGE
     SIZE 80 BY 1
     BGCOLOR 12 .
DEFINE QUERY br-log FOR
      tt-log SCROLLING.
DEFINE BROWSE br-log
  QUERY br-log DISPLAY
      tt-log.id FORMAT ">>>>>9" LABEL "#"
    tt-log.log-text FORMAT "X(200)" LABEL "Сообщение"
    WITH NO-ROW-MARKERS SIZE 80 BY 10 FIT-LAST-COLUMN.
DEFINE FRAME DEFAULT-FRAME
     b-exit AT ROW 1 COL 1 WIDGET-ID 4
     b-start AT ROW 1 COL 11 WIDGET-ID 6
     b-stop AT ROW 1 COL 21 WIDGET-ID 10
     b-prop AT ROW 1 COL 31 WIDGET-ID 28
     b-help AT ROW 1 COL 71 WIDGET-ID 14
     fi-port AT ROW 4.83 COL 9 WIDGET-ID 8
     br-log AT ROW 7 COL 1 WIDGET-ID 200
     fi-pos-num AT ROW 2 COL 13 COLON-ALIGNED WIDGET-ID 16
     fi-pos-type AT ROW 2.71 COL 13 COLON-ALIGNED WIDGET-ID 18
     fi-users AT ROW 3.42 COL 13 COLON-ALIGNED WIDGET-ID 24
     fi-last-conn-time AT ROW 4.13 COL 21 COLON-ALIGNED WIDGET-ID 26
     r-semaphore AT ROW 5.92 COL 1 WIDGET-ID 12
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 80 BY 16 WIDGET-ID 100.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "МТ-Сервер"
         HEIGHT             = 16
         WIDTH              = 80
         MAX-HEIGHT         = 16
         MAX-WIDTH          = 80
         VIRTUAL-HEIGHT     = 16
         VIRTUAL-WIDTH      = 80
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE C-Win = CURRENT-WINDOW.
ASSIGN
       fi-last-conn-time:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.
ON END-ERROR OF C-Win
OR ENDKEY OF C-Win ANYWHERE DO:
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF C-Win
DO:
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.
ON WINDOW-MAXIMIZED OF C-Win
DO:
  RETURN NO-APPLY.
END.
ON WINDOW-RESIZED OF C-Win
DO:
  RETURN NO-APPLY.
END.
ON CHOOSE OF b-exit IN FRAME DEFAULT-FRAME
DO:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-b-exit in this-procedure .
END.
ON CHOOSE OF b-help IN FRAME DEFAULT-FRAME
DO:
END.
ON CHOOSE OF b-prop IN FRAME DEFAULT-FRAME
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-b-prop in this-procedure.
END.
ON CHOOSE OF b-start IN FRAME DEFAULT-FRAME
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-b-start in this-procedure.
END.
ON CHOOSE OF b-stop IN FRAME DEFAULT-FRAME
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
  run proc-b-stop in this-procedure.
END.
ON LEAVE OF fi-port IN FRAME DEFAULT-FRAME
DO:
    assign
        fi-port
    .
    run proc-check-port in this-procedure.
END.
ASSIGN CURRENT-WINDOW                = C-Win
       THIS-PROCEDURE:CURRENT-WINDOW = C-Win.
ON CLOSE OF THIS-PROCEDURE
   RUN my-disable.
PAUSE 0 BEFORE-HIDE.
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame DEFAULT-FRAME anywhere do:
  if b-exit :sensitive then DO: apply "CHOOSE":U to b-exit in frame DEFAULT-FRAME. END.
  return no-apply.
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DEFAULT-FRAME
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
on choose of b-help in frame DEFAULT-FRAME
do:
  apply "help":u to frame DEFAULT-FRAME .
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DEFAULT-FRAME:width - 0.3
                fh            = frame DEFAULT-FRAME:first-child
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame DEFAULT-FRAME :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame DEFAULT-FRAME :height-chars)
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
    if frame DEFAULT-FRAME :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame DEFAULT-FRAME :height-chars)
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
            frame DEFAULT-FRAME :height = v-frame-height
          .
          if frame DEFAULT-FRAME :scrollable = true
          then do:
            assign
              frame DEFAULT-FRAME :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame DEFAULT-FRAME :scrollable = true
          then do:
            assign
              frame DEFAULT-FRAME :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame DEFAULT-FRAME :height = v-frame-height
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
      v-frame-height = frame DEFAULT-FRAME :height
      v-frame-virtual-height = frame DEFAULT-FRAME :virtual-height
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
      v-field-group-handle = frame DEFAULT-FRAME :first-child
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
    do with frame DEFAULT-FRAME
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame DEFAULT-FRAME :scrollable = true
      then do:
        assign
          frame DEFAULT-FRAME :virtual-height = frame DEFAULT-FRAME :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame DEFAULT-FRAME :height = frame DEFAULT-FRAME :height + p-change-value
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
        frame DEFAULT-FRAME :height = frame DEFAULT-FRAME :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame DEFAULT-FRAME :scrollable = true
      then do:
        assign
          frame DEFAULT-FRAME :virtual-height = frame DEFAULT-FRAME :virtual-height + p-change-value
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
          ,input  string(frame DEFAULT-FRAME :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame DEFAULT-FRAME :height)
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
    if frame DEFAULT-FRAME :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame DEFAULT-FRAME :width
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
    if frame DEFAULT-FRAME :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame DEFAULT-FRAME :width
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
            frame DEFAULT-FRAME :width = v-frame-width
          .
          if frame DEFAULT-FRAME :scrollable = true
          then do:
            assign
              frame DEFAULT-FRAME :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame DEFAULT-FRAME :scrollable = true
          then do:
            assign
              frame DEFAULT-FRAME :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame DEFAULT-FRAME :width = v-frame-width
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
      v-frame-width = frame DEFAULT-FRAME :width
      v-frame-virtual-width = frame DEFAULT-FRAME :virtual-width
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
      v-field-group-handle = frame DEFAULT-FRAME :first-child
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
    do with frame DEFAULT-FRAME
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame DEFAULT-FRAME :scrollable = true
      then do:
        assign
          frame DEFAULT-FRAME :virtual-width = frame DEFAULT-FRAME :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame DEFAULT-FRAME :width = v-frame-width + p-change-value
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
        frame DEFAULT-FRAME :width = frame DEFAULT-FRAME :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame DEFAULT-FRAME :scrollable = true
      then do:
        assign
          frame DEFAULT-FRAME :virtual-width = frame DEFAULT-FRAME :virtual-width + p-change-value
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
          ,input  string(frame DEFAULT-FRAME :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame DEFAULT-FRAME :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame DEFAULT-FRAME
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame DEFAULT-FRAME :height - v-diasize-resize-button :height
                  - 1
                  - (frame DEFAULT-FRAME :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame DEFAULT-FRAME :width - v-diasize-resize-button :width
                  - 1
                  - (frame DEFAULT-FRAME :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame DEFAULT-FRAME
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
      v-row-delta = v-new-row - frame DEFAULT-FRAME :height
      v-col-delta = v-new-col - frame DEFAULT-FRAME :width
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
            - frame DEFAULT-FRAME :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame DEFAULT-FRAME :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame DEFAULT-FRAME :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame DEFAULT-FRAME :height-chars
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
      v-diasize-current-frame-width  = frame DEFAULT-FRAME :width
      v-diasize-current-frame-height = frame DEFAULT-FRAME :height
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
    do with frame DEFAULT-FRAME
    :
      assign
        v-diasize-orig-frame-height = frame DEFAULT-FRAME :height
        v-diasize-orig-frame-width  = frame DEFAULT-FRAME :width
        v-diasize-browse-handle     = browse br-log :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame DEFAULT-FRAME :first-child
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
  find first buf_sys-ctrl no-lock .
  find buf_user-login no-lock
    where buf_user-login.db-num     = buf_sys-ctrl.db-num
      and buf_user-login.status_    = 0
      and buf_user-login.user-login = p-user-login
    no-error .
  if not available buf_user-login
  then do:
    message
      "Не найден пользователь" skip
      p-user-login skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  find first buf_cash-desk no-lock
    where buf_cash-desk.db-num    = buf_sys-ctrl.db-num
      and buf_cash-desk.pos-type  = 'IBS-TH-MOB':U
      and buf_cash-desk.cash-num  = p-pos-num
  no-error.
  if not available buf_cash-desk
  then do:
    message
      substitute( "В БД &1 не найдена база типа &2 с кодом &3"
                , buf_sys-ctrl.db-num
                , 'IBS-TH-MOB':U
                , p-pos-num
                )
    view-as alert-box error.
    undo, return error return-value .
  end.
  run gbl/set-gbl.p
    (input true
    ,input buf_user-login.user-id
    ,input p-user-password
    ) .
  define variable v-rtexch-chr               as character no-undo .
  define variable v-rtexch-type              as character no-undo .
  define variable v-rtusrnum-chr             as character no-undo .
  define variable v-rtusrnum-type            as character no-undo .
  define variable v-rtexpdt-chr              as character no-undo .
  define variable v-rtexpdt-type             as character no-undo .
  define variable v-rtusrnum                 as integer   no-undo .
  define variable v-rtexpdt                  as date      no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'rtexch':u
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-rtexch-chr
  ,output v-rtexch-type
  ) no-error .
  if error-status :error
  or v-rtexch-chr <> "yes"
  then do:
    message
      "Отсутствуют права для работы с радиотерминалом" skip
      "Параметр rtexch" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'rtusrnum':u
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-rtusrnum-chr
  ,output v-rtusrnum-type
  ) no-error .
  if error-status :error
  then do:
    message
      "Не задано количество пользователей для работы с радиотерминалом" skip
      "Параметр rtusrnum" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    v-cfg-max-user-num = integer(v-rtusrnum-chr) no-error
  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'rtexpdt':u
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-rtexpdt-chr
  ,output v-rtexpdt-type
  ) no-error .
  if error-status :error
  then do:
    message
      "Не задан срок окончания лицензии для работы с радиотерминалом" skip
      "Параметр rtexpdt" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    v-rtexpdt = date(v-rtexpdt-chr) no-error
  .
  if v-rtexpdt = ?
  then do:
    message
      "Не задан срок окончания лицензии для работы с радиотерминалом" skip
      "Параметр rtexpdt" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    session :time-source = 'ub':U
  .
  if today > v-rtexpdt
  then do:
    message
      "Истек срок действия лицензии для работы с радиотерминалом" skip
      "Сегодня" today skip
      "Срок окончания лицензии" v-rtexpdt skip
      "Параметр rtexpdt" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if v-rtexpdt - today < 15
  then do:
    message
      substitute("ВНИМАНИЕ!!! До окончания лиценизии осталось &1 дней", v-rtexpdt - today)
    view-as alert-box information.
  end.
  define buffer rtexch-lock_batchprocess for ub.batchprocess .
  run gbl/lock-prc.p
    (input 'mtex':U
    ,input p-pos-num
    ,input 0
    ,input 0
    ,input 'IBS-TH-MOB':U
    ,input ""
    ,input ""
    ,input ",,,,,,Обработка запросов радиотерминала"
    ,input true
    ,buffer rtexch-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Сервер обработки запросов радиотерминала уже запущен для кассы &1"
                , p-pos-num
                ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return .
  end.
  RUN my-enable.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.
PROCEDURE check-crc32 :
  define input  parameter p-mem   as memptr   no-undo .
  define input  parameter p-len   as integer  no-undo .
  define output parameter p-crc32 as int64    no-undo .
  define variable v-message as memptr no-undo.
  set-size(v-message) = p-len .
  set-pointer-value(v-message) = get-pointer-value(p-mem).
  run crc32 ( input 0 , input v-message , input p-len , output p-crc32).
  set-size(v-message) = 0 .
END PROCEDURE.
PROCEDURE conproc :
define input param clienthandle as handle.
do
on error undo, return error return-value
:
  define variable v-log as logical   no-undo .
  assign
    v-log = clienthandle :set-read-response-procedure("readproc").
  .
  if v-log <> yes then do:
  end.
  clienthandle :set-socket-option( "SO-LINGER" , "FALSE" ).
  clienthandle :set-socket-option( "TCP-NODELAY" , "TRUE" ).
  find first tt-cli-socket no-lock
    where tt-cli-socket.sock-handle = clienthandle
  no-error .
  if not available tt-cli-socket
  then do:
    create tt-cli-socket.
    assign
      tt-cli-socket.sock-handle = clienthandle
    .
  end.
  assign
    tt-cli-socket.remote-host     = clienthandle :remote-host
    tt-cli-socket.remote-port     = clienthandle :remote-port
    tt-cli-socket.conn-time       = time
    tt-cli-socket.last-conn-time  = tt-cli-socket.conn-time
  .
  run write-log in this-procedure ( substitute( "Установлено соединение. Удаленный хост: &1 , удаленный порт: &2"
                                              , tt-cli-socket.remote-host
                                              , tt-cli-socket.remote-port
                                              )
                                  ) .
end.
END PROCEDURE.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE empty-tt-cli-socket :
do
on error undo, return error return-value
:
  empty temp-table tt-cli-socket .
end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-port fi-pos-num fi-pos-type fi-users fi-last-conn-time
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE b-exit b-start b-help r-semaphore fi-port br-log fi-pos-num
         fi-pos-type fi-users fi-last-conn-time
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  OPEN QUERY br-log FOR EACH tt-log.
  VIEW C-Win.
END PROCEDURE.
PROCEDURE mt-serv_get-pos-num :
  define output parameter p-cash-desk-num as integer   no-undo .
do
on error undo, return error return-value
:
  assign
    p-cash-desk-num = p-pos-num
  .
end.
END PROCEDURE.
PROCEDURE mt-serv_write-error-message :
  define input  parameter p-message     as character no-undo .
  define output parameter p-xml-message as character no-undo .
do
on error undo, return error return-value
:
  assign
    p-xml-message = substitute( '<?xml version="1.0"?><msg><stts>1</stts><errmsg>&1</errmsg></msg>'
                              , p-message
                              )
  .
end.
END PROCEDURE.
PROCEDURE mt-serv_write-last-conn-time :
  define input  parameter p-string as character no-undo .
do
on error undo, return error return-value
:
  assign
    fi-last-conn-time = p-string
  .
  display
    fi-last-conn-time
  with frame DEFAULT-FRAME.
end.
END PROCEDURE.
PROCEDURE mt-serv_write-user-num :
  define input  parameter p-user-num as integer   no-undo .
do
on error undo, return error return-value
:
  run mt-serv_write-user-str in this-procedure ( substitute( "&1 из &2 работает"
                                                           , p-user-num
                                                           , v-cfg-max-user-num
                                                           )
                                               ) .
end.
END PROCEDURE.
PROCEDURE mt-serv_write-user-str :
  define input  parameter p-users as character no-undo .
do
on error undo, return error return-value
:
  assign
    fi-users = p-users
  .
  display
    fi-users
  with frame DEFAULT-FRAME.
end.
END PROCEDURE.
PROCEDURE my-disable :
  run stop-server in this-procedure .
  run disable_UI in this-procedure .
END PROCEDURE.
PROCEDURE my-enable :
  assign
    fi-port            = p-port
    fi-pos-num         = p-pos-num
    fi-pos-type        = 'IBS-TH-MOB':U
    v-cfg-timeout      = 1000
  .
  display
    fi-port
    fi-pos-num
    fi-pos-type
  with frame DEFAULT-FRAME in window C-Win.
  enable
    b-exit
    b-start
    b-help
    b-prop
    fi-port
    fi-last-conn-time
    fi-users
    br-log
  with frame DEFAULT-FRAME in window C-Win.
  view C-Win.
  run mt-serv_write-user-num in this-procedure ( input 0 ) .
END PROCEDURE.
PROCEDURE proc-b-exit :
  define variable v-answer  as logical   no-undo .
  run gbl/q-wait.w ( input substitute( "Вы хотите завершить работу ?" )
                   , input false
                   , input 5
                   , output v-answer
                   ) .
  if v-answer = true
  then do:
    find first tt-log no-error .
    if available tt-log
    then do:
      run gbl/q-wait.w ( input substitute( "Сохранить лог перед выходом ?" )
                       , input true
                       , input 5
                       , output v-answer
                       ) .
      if v-answer = true
      then do:
        run save-log in this-procedure .
      end.
    end.
    empty temp-table tt-cli-socket.
    empty temp-table tt-log.
    apply "close" to this-procedure .
  end.
END PROCEDURE.
PROCEDURE proc-b-prop :
  message "!" view-as alert-box.
END PROCEDURE.
PROCEDURE proc-b-start :
  define variable v-conn-str  as character no-undo .
  define variable v-retval    as logical   no-undo .
  define variable v-port      as integer   no-undo .
  create-block:
  do
  on error undo, return error return-value
  :
    assign
      v-port = fi-port
    .
    assign
      v-conn-str = substitute("-S &1" , v-port)
    .
    create server-socket v-server-socket no-error .
    if error-status :error or not valid-handle (v-server-socket)
    then do:
      message
        "Ошибка при создании серверного сокета!" skip
        error-status :get-message(1) skip
        error-status :get-message(2) skip
        error-status :get-message(3) skip
      view-as alert-box error.
      undo create-block, return error.
    end.
    assign
      v-retval = v-server-socket :enable-connections( v-conn-str )
    .
    if v-retval = no
    then do:
      run write-log in this-procedure ("Ошибка при вызове процедуры enable-connections.").
      undo create-block, return error.
    end.
    assign
      v-retval = v-server-socket :set-connect-procedure( "conproc" )
    .
    if v-retval = no
    then do:
      run write-log in this-procedure ("Ошибка при вызове процедуры set-connect-procedure.").
      undo create-block, return error.
    end.
    run write-log in this-procedure ( substitute(  "Сервер запущен на порте &1." , v-port ) ).
  end.
  assign
    b-start :sensitive in frame DEFAULT-FRAME = no
    fi-port :sensitive in frame DEFAULT-FRAME = no
    b-stop  :sensitive in frame DEFAULT-FRAME = yes
    b-exit  :sensitive in frame DEFAULT-FRAME = no
    r-semaphore :bgcolor = GREEN_COLOR
    v-server-running     = true
  .
  run mt-serv_write-user-num ( input 0 ) .
END PROCEDURE.
PROCEDURE proc-b-stop :
do
on error undo, return error return-value
:
  define variable v-answer as logical   no-undo .
  run gbl/q-wait.w ( input substitute( "Вы хотите остановить сервер ?" )
                   , input false
                   , input 5
                   , output v-answer
                   ) .
  if v-answer = true
  then do:
    run stop-server in this-procedure .
    assign
      b-stop  :sensitive in frame DEFAULT-FRAME = no
      b-start :sensitive in frame DEFAULT-FRAME = yes
      fi-port :sensitive in frame DEFAULT-FRAME = yes
      b-exit  :sensitive in frame DEFAULT-FRAME = yes
      r-semaphore :bgcolor = RED_COLOR
    .
    run mt-serv_write-user-num ( input 0 ) .
  end.
end.
END PROCEDURE.
PROCEDURE proc-check-port :
END PROCEDURE.
PROCEDURE readproc :
define buffer buf_tt-cli-socket for tt-cli-socket.
  define variable v-size          as integer    no-undo .
  define variable v-crc32         as int64      no-undo .
  define variable v-func_num      as integer    no-undo .
  define variable v-req_num       as integer    no-undo .
  define variable v-field_num     as integer    no-undo .
  define variable v-text          as character  no-undo .
  define variable v-checked-crc32 as int64      no-undo .
  define variable v-msg-size      as integer    no-undo .
  define variable v-memptr        as memptr     no-undo .
  define variable v-memptrw       as memptr     no-undo .
  define variable v-memptrs       as memptr     no-undo .
  define variable v-msg-str       as longchar   no-undo .
  define variable v-bytes-readed  as integer    no-undo .
  define variable v-log           as logical    no-undo .
  define variable v-sendmemptr    as memptr     no-undo .
  define variable v-sendstr       as longchar   no-undo .
  define variable v-date          as date       no-undo .
  define variable v-time          as integer    no-undo .
do
on error undo, return error return-value
:
  run cur-time in this-procedure ( output v-date
                                 , output v-time
                                 ) .
    run mt-serv_write-last-conn-time in this-procedure ( input substitute( "&1 &2"
                                                                         , v-date
                                                                         , string(v-time, "hh:mm:ss")
                                                                         )
                                                       ) .
    find first buf_tt-cli-socket no-lock
      where buf_tt-cli-socket.sock-handle = self
    no-error .
    if not available buf_tt-cli-socket
    then do:
      return.
    end.
    if not self:connected() then do:
      run write-log in this-procedure ( substitute( "Удаленный клиент отключился: &1:&2"
                                                  , buf_tt-cli-socket.remote-host
                                                  , buf_tt-cli-socket.remote-port
                                                  )
                                      ) .
      delete buf_tt-cli-socket.
      return.
    end.
    assign
      buf_tt-cli-socket.last-conn-time  = time
      r-semaphore :bgcolor in frame DEFAULT-FRAME = YELLOW_COLOR
    .
    set-size(v-memptr) = 20 .
    self:read(v-memptr,1,20) .
    assign
        v-bytes-readed = self:bytes-read
    .
    if v-bytes-readed < 20
    then do:
        return.
    end.
    assign
      v-size        = get-long(v-memptr,1)
      v-crc32       = get-unsigned-long(v-memptr,5)
      v-func_num    = get-long(v-memptr,9)
      v-req_num     = get-long(v-memptr,13)
      v-field_num   = get-long(v-memptr,17)
      v-msg-size    =  v-size - 20
    .
    put-long(v-memptr,5) = 0 .
    run check-crc32 in this-procedure ( input v-memptr , 20, output v-checked-crc32) .
    set-size(v-memptr) = 0.
    if v-msg-size > 0
    then do:
        set-size(v-memptrs) = v-msg-size .
        self:read(v-memptrs,1,v-msg-size) .
        assign
            v-msg-str = get-string(v-memptrs, 1, v-msg-size)
        .
        set-size(v-memptrs) = 0 .
    end.
    assign
      v-text =   substitute( "CRC32=&1 , CHECKED=&2"
                           , v-crc32
                           , v-checked-crc32
                           )
    .
    run write-log in this-procedure ( substitute( "&1:&2 &3&4&5 byte recieved : &4&6&4&7&4&6"
                                                , self :remote-host
                                                , self :remote-port
                                                , v-text
                                                , chr(10)
                                                , self :bytes-read
                                                , fill('-',120)
                                                , v-msg-str
                                                )
                                    ) .
    if valid-handle(v-mt-route-handle) <> true
    then do:
      run gbl/mt-route.p persistent set v-mt-route-handle no-error .
      if error-status :error
      then do:
        run mt-serv_write-error-message in this-procedure ( input "Ошибка при запуске маршрутизатора сообщений mt-route.p":U
                                                          , output v-sendstr
                                                          ) .
      end.
      run mt-route_init in v-mt-route-handle ( input this-procedure
                                             , input p-pos-num
                                             , input v-cfg-max-user-num
                                             , input v-cfg-timeout
                                             ) no-error .
      if error-status :error
      then do:
        run mt-serv_write-error-message in this-procedure ( input "Ошибка установки номера кассы ":U + string(p-pos-num)
                                                          , output v-sendstr
                                                          ) .
      end.
      assign
        v-mt-route-loaded = true
      .
    end.
    if v-mt-route-loaded = true then do:
      run mt-route_process-request in v-mt-route-handle ( input this-procedure
                                                        , input v-req_num
                                                        , input '<?xml version="1.0"?>' + v-msg-str
                                                        , output v-sendstr
                                                        ) no-error .
      if error-status :error
      then do:
        run mt-serv_write-error-message in this-procedure ( input "Ошибка при обработке запроса ":U + string(v-req_num)
                                                          , output v-sendstr
                                                          ) .
      end.
    end.
    set-size(v-sendmemptr) = 20 + length(v-sendstr) + 1 .
    put-long(v-sendmemptr , 1 )   = 20 + length(v-sendstr) .
    put-long(v-sendmemptr , 5 )   = 0 .
    put-long(v-sendmemptr , 9 )   = 0 .
    put-long(v-sendmemptr , 13 )  = 0 .
    put-long(v-sendmemptr , 17 )  = 0 .
    put-string(v-sendmemptr,21)   = v-sendstr .
    v-log = self:write(v-sendmemptr, 1, 20 + length(v-sendstr) ) no-error .
    if error-status :error
    then do:
      message
        error-status :get-message(1) skip
        error-status :get-message(2) skip
        error-status :get-message(3)
      view-as alert-box error.
    end.
    set-size(v-sendmemptr) = 0 .
    run write-log in this-procedure ( substitute("&1 bytes writen: &2&3&2&4&2&3"
                                                , self:BYTES-WRITTEN
                                                , chr(10)
                                                , fill('-',120)
                                                , v-sendstr
                                                )
                                    ).
    if v-req_num = 13
    then do:
      self:disconnect().
      run write-log in this-procedure ( substitute( "Client disconnected! &1&2&1"
                                                  , chr(10)
                                                  , fill('*',120)
                                                  )
                                      ).
      delete buf_tt-cli-socket.
    end.
    assign
      r-semaphore :bgcolor in frame DEFAULT-FRAME = GREEN_COLOR
    .
end.
END PROCEDURE.
PROCEDURE save-log :
  output stream slog to value("c:\socklog.log":U) append.
  for each tt-log :
    put stream slog unformatted tt-log.id " " tt-log.log-date " " tt-log.log-time " " tt-log.log-text skip fill('#',200) skip.
  end.
  output stream slog close.
END PROCEDURE.
PROCEDURE stop-server :
do
on error undo, return error return-value
:
  for each tt-cli-socket:
    if valid-handle( tt-cli-socket.sock-handle )
    then do:
      tt-cli-socket.sock-handle :disconnect() .
      run write-log in this-procedure ( substitute( "Отключение удаленного пользователя &1:&2"
                                                  , tt-cli-socket.remote-host
                                                  , tt-cli-socket.remote-port
                                                  )
                                      ).
    end.
  end.
  if valid-handle(v-server-socket)
  then do:
    v-server-socket :disable-connections() .
    delete object v-server-socket .
    run write-log in this-procedure ("Сервер остановлен.").
    assign
      v-server-running = false
    .
  end.
  if valid-handle(v-mt-route-handle) = true
  then do:
    delete procedure v-mt-route-handle .
    assign
      v-mt-route-loaded = false
    .
  end.
end.
END PROCEDURE.
PROCEDURE write-log :
define input  parameter p-message as character no-undo .
do
on error undo, return error return-value
:
  define variable v-str as character no-undo .
  assign
    v-str     = string( time , "HH:MM:SS" ) + ">" + trim(p-message)
    v-log-id  = v-log-id + 1
  .
  create tt-log.
  assign
    tt-log.id           = v-log-id
    tt-log.log-date     = today
    tt-log.log-time     = time
    tt-log.log-text     = p-message
  .
  define buffer sch_tt-log for tt-log.
  find last sch_tt-log no-error .
  if available sch_tt-log
  then do:
    open query br-log for each tt-log  indexed-reposition.
    reposition br-log to rowid rowid(sch_tt-log) no-error .
  end.
end.
END PROCEDURE.
