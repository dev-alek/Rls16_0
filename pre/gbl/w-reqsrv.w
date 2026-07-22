CREATE WIDGET-POOL.
define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define input  parameter p-auto-start    as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно запуска сервера обработки запросов".
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
define variable v-rtusrnum as integer   no-undo .
define variable v-rtexpdt  as date      no-undo .
define stream sinp .
define stream sout .
define variable v-server-running     as logical   no-undo .
define variable v-rt-reply-handle    as handle    no-undo .
define variable v-stop-server        as logical   no-undo .
define variable v-full-dir-name      as character no-undo .
define variable v-directory-in       as character no-undo .
define variable v-directory-out      as character no-undo .
define variable v-description-number as integer   no-undo .
define variable v-cntxt-db-num        as integer   no-undo .
define variable v-cntxt-user-id       as character no-undo .
define variable v-cntxt-level         as character no-undo .
define variable v-cntxt-host-code-obj as integer   no-undo .
define variable v-cntxt-obj-type      as character no-undo .
define variable v-cntxt-obj-code      as integer   no-undo .
define variable v-cntxt-db-num-obj    as integer   no-undo .
define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-cntxt-report-num    as integer   no-undo .
define buffer buf_sys-ctrl   for ub.sys-ctrl .
define buffer buf_user-login for ub.user-login .
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1.
DEFINE BUTTON b-sel-dir
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-start DEFAULT
     LABEL "Ста&рт"
     SIZE 10 BY 1.
DEFINE BUTTON b-stop
     LABEL "Сто&п"
     SIZE 10 BY 1.
DEFINE VARIABLE fi-description-01 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 85.5 BY .67 NO-UNDO.
DEFINE VARIABLE fi-description-02 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 85.5 BY .67 NO-UNDO.
DEFINE VARIABLE fi-description-03 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 85.5 BY .67 NO-UNDO.
DEFINE VARIABLE fi-description-04 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 85.5 BY .67 NO-UNDO.
DEFINE VARIABLE fi-directory AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория обмена запросами"
     VIEW-AS FILL-IN
     SIZE 56 BY 1 NO-UNDO.
DEFINE VARIABLE fi-message-01 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.
DEFINE VARIABLE fi-message-02 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.
DEFINE VARIABLE fi-message-03 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.
DEFINE VARIABLE fi-message-04 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.
DEFINE VARIABLE fi-message-05 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.
DEFINE VARIABLE fi-message-06 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.
DEFINE VARIABLE fi-message-07 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.
DEFINE VARIABLE fi-message-08 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.
DEFINE VARIABLE fi-message-09 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.
DEFINE VARIABLE fi-message-10 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.
DEFINE VARIABLE fi-message-11 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.
DEFINE VARIABLE fi-message-12 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.
DEFINE FRAME DEFAULT-FRAME
     b-exit AT ROW 1 COL 1
     b-start AT ROW 1 COL 11
     b-stop AT ROW 1 COL 21
     fi-directory AT ROW 2 COL 30 COLON-ALIGNED
     b-sel-dir AT ROW 2 COL 88
     fi-description-01 AT ROW 3.5 COL 2 NO-LABEL
     fi-description-02 AT ROW 4.5 COL 2 NO-LABEL
     fi-description-03 AT ROW 5.5 COL 2 NO-LABEL
     fi-description-04 AT ROW 6.5 COL 2 NO-LABEL
     fi-message-01 AT ROW 9.5 COL 2 NO-LABEL
     fi-message-02 AT ROW 10.5 COL 2 NO-LABEL
     fi-message-03 AT ROW 11.5 COL 2 NO-LABEL
     fi-message-04 AT ROW 12.5 COL 2 NO-LABEL
     fi-message-05 AT ROW 13.5 COL 2 NO-LABEL
     fi-message-06 AT ROW 14.5 COL 2 NO-LABEL
     fi-message-07 AT ROW 15.5 COL 2 NO-LABEL
     fi-message-08 AT ROW 16.5 COL 2 NO-LABEL
     fi-message-09 AT ROW 17.5 COL 2 NO-LABEL
     fi-message-10 AT ROW 18.5 COL 2 NO-LABEL
     fi-message-11 AT ROW 19.5 COL 2 NO-LABEL
     fi-message-12 AT ROW 20.5 COL 2 NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 97.13 BY 20.21
         DEFAULT-BUTTON b-start.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Сервер обработки запросов"
         HEIGHT             = 20.21
         WIDTH              = 97.13
         MAX-HEIGHT         = 20.21
         MAX-WIDTH          = 97.13
         VIRTUAL-HEIGHT     = 20.21
         VIRTUAL-WIDTH      = 97.13
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
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.
ON END-ERROR OF C-Win
OR ENDKEY OF C-Win ANYWHERE DO:
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF C-Win
DO:
  if v-server-running <> true
  then do:
    apply "close":u to this-procedure.
  end.
  return no-apply.
END.
ON CHOOSE OF b-exit IN FRAME DEFAULT-FRAME
DO:
  if v-server-running <> true
  then do:
    apply 'close':u to this-procedure .
  end.
END.
ON CHOOSE OF b-sel-dir IN FRAME DEFAULT-FRAME
DO:
  define variable v-dir-name  as character no-undo .
  define variable v-dir-type  as character no-undo .
  define variable v-can-write as logical   no-undo .
  run gbl/dir-sel.p
    (output v-dir-name
    ,output v-dir-type
    ,output v-can-write
    ) .
  if v-dir-name <> ""
  then do:
    assign
      fi-directory :screen-value = v-dir-name
    .
  end.
END.
ON CHOOSE OF b-start IN FRAME DEFAULT-FRAME
DO:
  if v-server-running <> true
  then do:
    if fi-directory :screen-value = ""
    then do:
      message
        "Задайте директорию обмена запросами" skip
        view-as alert-box information .
      apply 'entry':u to fi-directory .
      return no-apply .
    end.
    assign
      file-info :file-name = fi-directory :screen-value
    .
    assign
      v-full-dir-name = file-info :full-pathname
    .
    if v-full-dir-name = ?
    or v-full-dir-name = ""
    then do:
      message
        "Ошибка задания директории" skip
        "" fi-directory :screen-value skip
        view-as alert-box error .
      apply 'entry':u to fi-directory .
      return no-apply .
    end.
    assign
      v-directory-in  = v-full-dir-name + '/' + 'in':u
      v-directory-out = v-full-dir-name + '/' + 'out':u
    .
    run gbl/dir-cre.p
      (input  v-directory-in
      ) .
    run gbl/dir-cre.p
      (input  v-directory-out
      ) .
    assign
      v-server-running = true
      v-stop-server    = false
    .
    assign
      b-exit  :sensitive      = false
      b-start :sensitive      = false
      b-stop  :sensitive      = true
      b-sel-dir :sensitive    = false
      fi-directory :read-only = true
    .
    assign
      fi-description-01 :screen-value = "Сервер запускается"
    .
    run gbl/req-serv.p
      (input this-procedure :handle
      ,input v-directory-in
      ,input v-directory-out
      ) no-error .
    if error-status :error
    then do:
      message
        "Ошибка при запуске программы req-serv.p" skip
        error-status :get-message(1) skip
        return-value
        view-as alert-box error .
    end.
    if valid-handle(v-rt-reply-handle) = true
    then do:
      delete procedure v-rt-reply-handle .
    end.
    assign
      fi-description-01 :screen-value = ""
    .
    assign
      b-exit  :sensitive      = true
      b-start :sensitive      = true
      b-stop  :sensitive      = false
      b-sel-dir :sensitive    = true
      fi-directory :read-only = false
    .
    assign
      v-server-running = false
    .
  end.
END.
ON CHOOSE OF b-stop IN FRAME DEFAULT-FRAME
DO:
  define variable v-ok as logical   no-undo .
  if v-server-running = true
  then do:
    if v-stop-server = false
    then do:
      message
        "Остановить сервер обработки запросов" skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok = true
      then do:
        assign
          v-stop-server = true
        .
      end.
    end.
  end.
END.
ASSIGN CURRENT-WINDOW                = C-Win
       THIS-PROCEDURE:CURRENT-WINDOW = C-Win.
ON CLOSE OF THIS-PROCEDURE
   RUN disable_UI.
PAUSE 0 BEFORE-HIDE.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
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
    v-rtusrnum = integer(v-rtusrnum-chr) no-error
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
    assign
      v-rtexpdt = date(01/01/5000)
    .
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
  assign
    fi-description-02 :screen-value = substitute("Максимальное количество пользователей &1", v-rtusrnum )
    fi-description-03 :screen-value = substitute("Срок окончания лицензии &1", string(v-rtexpdt, '99/99/9999'))
  .
  if v-rtexpdt - today < 15
  then do:
    assign
      fi-description-04 :screen-value = substitute("ВНИМАНИЕ!!! До окончания лиценизии осталось &1 дней", v-rtexpdt - today)
    .
  end.
  define buffer rtexch-lock_batchprocess for ub.batchprocess .
  run gbl/lock-prc.p
    (input 'rtex':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
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
      "Сервер обработки запросов радиотерминала уже запущен" skip
      "Невозможно запустить второй сервер обработки запросов для той-же базы данных" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return .
  end.
  assign
    v-cntxt-report-num = dynamic-next-value( "next-report":U, "ubflt":U) .
  .
  do with frame DEFAULT-FRAME
  :
    assign
      b-stop  :sensitive = false
    .
    define variable v-exch-dir as character no-undo .
    get-key-value section 'radio-terminal' key 'exch-dir' value v-exch-dir .
    if v-exch-dir = ?
    then do:
      message
        'Отсутствует ключ exch-dir в секции radio-terminal в progress.ini'
        view-as alert-box error .
    end.
    else do:
      assign
        fi-directory :screen-value = v-exch-dir
      .
    end.
    apply 'entry':u to fi-directory .
    assign
      v-description-number = 0
    .
    if p-auto-start = true
    then do:
      apply 'choose':u to b-start .
    end.
  end.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-directory fi-description-01 fi-description-02 fi-description-03
          fi-description-04 fi-message-01 fi-message-02 fi-message-03
          fi-message-04 fi-message-05 fi-message-06 fi-message-07 fi-message-08
          fi-message-09 fi-message-10 fi-message-11 fi-message-12
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE b-exit b-start b-stop fi-directory b-sel-dir fi-description-01
         fi-description-02 fi-description-03 fi-description-04
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  VIEW C-Win.
END PROCEDURE.
PROCEDURE get-utc-time-string :
  define output parameter p-utc-time as character no-undo .
  define variable v-year         as integer   no-undo .
  define variable v-month        as integer   no-undo .
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
      p-utc-time  = 'UTC ':u
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
  end.
END PROCEDURE.
PROCEDURE w-reqsrv_check-stop :
  define output parameter p-stop-server as logical   no-undo .
  do
  on error undo, return error return-value
  :
    process events .
    assign
      p-stop-server = v-stop-server
    .
  end.
END PROCEDURE.
PROCEDURE w-reqsrv_process-request :
  define input  parameter p-file-name as character no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-rt-reply-handle) <> true
    then do:
      run gbl/rt-reply.p persistent set v-rt-reply-handle
        (input v-rtusrnum
        ,input v-rtexpdt
        ).
    end.
    run rt-reply_process-request in v-rt-reply-handle
      (input  this-procedure
      ,input  v-directory-in
      ,input  v-directory-out
      ,input  p-file-name
      ) no-error .
    if error-status :error
    then do:
      define variable v-utc-time as character no-undo .
      run get-utc-time-string in this-procedure
        (output v-utc-time
        ) .
      run w-reqsrv_show-request in this-procedure
        (input substitute('&1 error &2':u
                         ,p-file-name
                         ,return-value
                         )
        ) .
      output stream sout to value(v-full-dir-name + '/':u + 'w-reqsrv.err':u ) append .
      put stream sout unformatted v-utc-time + ' ' + p-file-name .
      put stream sout unformatted "Ошибка при обработке запроса" + chr(10) .
      put stream sout unformatted error-status :get-message(1) + chr(10) .
      put stream sout unformatted return-value + chr(10) .
      define variable v-read-string as character no-undo .
      input stream sinp from value(v-directory-in + '/' + p-file-name) .
      repeat
      :
        assign
          v-read-string = '':u
        .
        import stream sinp unformatted v-read-string .
        put stream sout unformatted v-read-string + chr(10) .
      end.
      input stream sinp close .
      output stream sout close .
      define variable v-temp-file-name  as character no-undo .
      define variable v-error-file-name as character no-undo .
      assign
        v-temp-file-name  = entry(1, p-file-name, '.':u) + '.tmp':u
        v-error-file-name = entry(1, p-file-name, '.':u) + '.err':u
      .
      output stream sout to value(v-directory-out + '/':u + v-temp-file-name) .
      put stream sout "error" .
      output stream sout close .
      os-delete value(v-directory-out + '/':u + v-error-file-name) .
      os-rename value(v-directory-out + '/':u + v-temp-file-name)
                value(v-directory-out + '/':u + v-error-file-name)
                .
    end.
    os-delete value(v-directory-in + '/' + p-file-name) .
    view frame DEFAULT-FRAME
      .
  end.
END PROCEDURE.
PROCEDURE w-reqsrv_show-description :
  define input  parameter p-description as character no-undo .
  do with frame DEFAULT-FRAME
  :
    assign
      fi-description-01 :screen-value = p-description
    .
  end.
END PROCEDURE.
PROCEDURE w-reqsrv_show-request :
  define input  parameter p-request-data as character no-undo .
  define variable v-ok as logical   no-undo .
  define variable v-utc-time as character no-undo .
  define variable v-message  as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame DEFAULT-FRAME
    :
      run get-utc-time-string in this-procedure
        (output v-utc-time
        ) .
      assign
        v-message = v-utc-time
                  + " "
                  + p-request-data
      .
      assign
        v-description-number = v-description-number + 1
      .
      if v-description-number < 1
      or v-description-number > 12
      then do:
        assign
          v-description-number = 1
        .
      end.
      define variable v-display-handle as widget-handle no-undo .
      define variable v-hide-handle    as widget-handle no-undo .
      case v-description-number
      :
        when 1
        then do:
          assign
            v-display-handle = fi-message-01 :handle
            v-hide-handle    = fi-message-12 :handle
          .
        end.
        when 2
        then do:
          assign
            v-display-handle = fi-message-02 :handle
            v-hide-handle    = fi-message-01 :handle
          .
        end.
        when 3
        then do:
          assign
            v-display-handle = fi-message-03 :handle
            v-hide-handle    = fi-message-02 :handle
          .
        end.
        when 4
        then do:
          assign
            v-display-handle = fi-message-04 :handle
            v-hide-handle    = fi-message-03 :handle
          .
        end.
        when 5
        then do:
          assign
            v-display-handle = fi-message-05 :handle
            v-hide-handle    = fi-message-04 :handle
          .
        end.
        when 6
        then do:
          assign
            v-display-handle = fi-message-06 :handle
            v-hide-handle    = fi-message-05 :handle
          .
        end.
        when 7
        then do:
          assign
            v-display-handle = fi-message-07 :handle
            v-hide-handle    = fi-message-06 :handle
          .
        end.
        when 8
        then do:
          assign
            v-display-handle = fi-message-08 :handle
            v-hide-handle    = fi-message-07 :handle
          .
        end.
        when 9
        then do:
          assign
            v-display-handle = fi-message-09 :handle
            v-hide-handle    = fi-message-08 :handle
          .
        end.
        when 10
        then do:
          assign
            v-display-handle = fi-message-10 :handle
            v-hide-handle    = fi-message-09 :handle
          .
        end.
        when 11
        then do:
          assign
            v-display-handle = fi-message-11 :handle
            v-hide-handle    = fi-message-10 :handle
          .
        end.
        when 12
        then do:
          assign
            v-display-handle = fi-message-12 :handle
            v-hide-handle    = fi-message-11 :handle
          .
        end.
      end case .
      assign
        v-display-handle :screen-value = v-message
        v-display-handle :fgcolor      = WHITE_COLOR
        v-display-handle :bgcolor      = BLUE_COLOR
        v-hide-handle    :fgcolor      = BROWN_COLOR
        v-hide-handle    :bgcolor      = GREY_COLOR
      .
    end.
    process events .
  end.
END PROCEDURE.
PROCEDURE mainmenu_getcntxt :
  define output parameter p-cntxt-db-num        as integer   no-undo .
  define output parameter p-cntxt-user-id       as character no-undo .
  define output parameter p-cntxt-level         as character no-undo .
  define output parameter p-cntxt-host-code-obj as integer   no-undo .
  define output parameter p-cntxt-obj-type      as character no-undo .
  define output parameter p-cntxt-obj-code      as integer   no-undo .
  define output parameter p-cntxt-db-num-obj    as integer   no-undo .
  define output parameter p-cntxt-is-admin      as logical   no-undo .
  do on error undo, return error return-value
  :
    assign
      p-cntxt-db-num         = v-cntxt-db-num
      p-cntxt-user-id        = v-cntxt-user-id
      p-cntxt-level          = v-cntxt-level
      p-cntxt-host-code-obj  = v-cntxt-host-code-obj
      p-cntxt-obj-type       = v-cntxt-obj-type
      p-cntxt-obj-code       = v-cntxt-obj-code
      p-cntxt-db-num-obj     = v-cntxt-db-num-obj
      p-cntxt-is-admin       = v-cntxt-is-admin
    .
  end.
END PROCEDURE.
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
  on error undo, return error
  :
    assign
      p-report-num = v-cntxt-report-num
    .
  end.
END PROCEDURE.
PROCEDURE w-reqsrv_setcntxt :
  define input parameter p-cntxt-db-num        as integer   no-undo .
  define input parameter p-cntxt-user-id       as character no-undo .
  define input parameter p-cntxt-level         as character no-undo .
  define input parameter p-cntxt-host-code-obj as integer   no-undo .
  define input parameter p-cntxt-obj-type      as character no-undo .
  define input parameter p-cntxt-obj-code      as integer   no-undo .
  define input parameter p-cntxt-db-num-obj    as integer   no-undo .
  define input parameter p-cntxt-is-admin      as logical   no-undo .
  do on error undo, return error return-value
  :
    if p-cntxt-level <> 'object':U then do:
      run w-reqsrv_clrcntxt in this-procedure .
      return .
    end.
    assign
      v-cntxt-db-num         = p-cntxt-db-num
      v-cntxt-user-id        = p-cntxt-user-id
      v-cntxt-level          = p-cntxt-level
      v-cntxt-host-code-obj  = p-cntxt-host-code-obj
      v-cntxt-obj-type       = p-cntxt-obj-type
      v-cntxt-obj-code       = p-cntxt-obj-code
      v-cntxt-db-num-obj     = p-cntxt-db-num-obj
      v-cntxt-is-admin       = p-cntxt-is-admin
    .
  end.
END PROCEDURE.
PROCEDURE w-reqsrv_clrcntxt :
  do on error undo, return error return-value
  :
    assign
      v-cntxt-db-num         = buf_sys-ctrl.db-num
      v-cntxt-user-id        = buf_user-login.user-id
      v-cntxt-level          = 'global':U
      v-cntxt-host-code-obj  = 0
      v-cntxt-obj-type       = ''
      v-cntxt-obj-code       = 0
      v-cntxt-db-num-obj     = 0
      v-cntxt-is-admin       = no
    .
  end.
END PROCEDURE.
PROCEDURE get-userid :
  define output parameter p-user-id as character    no-undo .
  do
  on error undo, return error
  :
    assign
      p-user-id = v-cntxt-user-id
    .
  end.
END PROCEDURE.
PROCEDURE w-reqsrv_print-log :
  define input  parameter p-msg as character no-undo .
  define variable v-message   as character no-undo .
  define variable v-utc-time  as character no-undo .
do
on error undo, return error return-value
:
  assign
    v-message = trim(p-msg)
  .
  if v-message <> ? and v-message <> ''
  then do:
    run get-utc-time-string in this-procedure ( output v-utc-time ) .
    output stream sout to value(v-full-dir-name + '/':u + 'w-reqsrv.err':u ) append .
    put stream sout unformatted substitute("&1 &2" , v-utc-time , v-message ) .
    output stream sout close.
  end.
end.
END PROCEDURE.
PROCEDURE get-db-num :
  define output parameter p-cntxt-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-cntxt-db-num = buf_sys-ctrl.db-num
    .
  end.
END PROCEDURE.
PROCEDURE is-radioterminal :
  define output parameter p-ask as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-ask = true
    .
  end.
END PROCEDURE.
