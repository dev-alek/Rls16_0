define temp-table temp_filter-fields no-undo
    field user-id               as character
    field fld-record-visible    as logical
    field flt-record-visible    as logical
    field flt-record-order      as int64
    index pi is primary unique
        user-id
.
define temp-table temp_user-login-obj no-undo
    field db-num    as integer
    field user-id   as character
    field obj-type  as character
    field obj-code  as integer
    field host-code as integer
    field obj-name  as character
    index pi is primary unique
        db-num
        user-id
        obj-type
        obj-code
.
define input parameter parparentproc  as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: 4ff7b201ba9b, 3436, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:32 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: users.w $":U .
define variable vss-archive     as character no-undo init "$Archive: str/users.w $":U .
define variable vss-description as character no-undo init "Список пользователей системы".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.
procedure uf-name :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .
  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .
  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'cli-all-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'oldscode':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника неиспользуемых весовых кодов"     p-tooltip = "Настройки справочника неиспользуемых весовых кодов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-ref-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(8)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = yes      p-label = "Параметры вызова справочника товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fbr-gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп блюд"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп блюд"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findoci-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findocs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника платежей"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-obi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'seqeallo':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Порядок колонок в АВТО-ЗАКАЗЕ"     p-tooltip = "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'skm-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова выгрузки файла данных по продажам по СКМ"     p-tooltip = "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'imp-goods':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Импорт в карточке товара"     p-tooltip = "Заполнение по умолчанию параметров импорта товаров из карточки товара"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'discards-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник ДК"     p-tooltip = "Справочник дисконтных карт"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'finsttms-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника банковских выписок"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника банковских выписок"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список фин.обязательств"     p-tooltip = "Список фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'mpl-gds-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список цен по товару"     p-tooltip = "Список цен по товару"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'tpl-mode-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список мод"     p-tooltip = "Список мод"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-sost-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Состояние заказа"     p-tooltip = "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'planplat-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Планирование платежей"     p-tooltip = "Планирование платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа"     p-tooltip = "Форма ввода заказа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОП"     p-tooltip = "Форма ввода заказа ОП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pФП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ФП"     p-tooltip = "Форма ввода заказа ФП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОФ':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОФ"     p-tooltip = "Форма ввода заказа ОФ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'list-abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список заголовков ABC-анализа"     p-tooltip = "Список заголовков ABC-анализа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "ABC-анализ"     p-tooltip = "ABC-анализ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-rc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Заказ О-РЦ"     p-tooltip = "Заказ О-РЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cfin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список удаленных фин.обязательств"     p-tooltip = "Список удаленных фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'color-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = yes      p-use-type-price = no      p-use-type-val = no      p-label = "Раскрасить экран"     p-tooltip = "Изменение цветовой палитры брауза"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bon1-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-tooltip = "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-shift':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Сменный отчет"     p-tooltip = "Сменный отчет"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsreffi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник товаров - доп поля"     p-tooltip = "Справочник товаров - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsfrmfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Карточка товара - доп поля"     p-tooltip = "Карточка товара - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-g':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrst':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = YES      p-use-type-val =       p-label = "Остатки МЦ"     p-tooltip = "Остатки МЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthcom':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = no      p-use-type-val =       p-label = "Сводный отчет о реализованных талонах"     p-tooltip = "Сводный отчет о реализованных талонах"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'bge-active-vbrr':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper-new':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов(расширенный)"     p-tooltip = "Параметры для выгрузки документов(расширенный)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/i-egais.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Интерфейс импорта классификатора ЕГАИС"     p-tooltip = "Интерфейс импорта классификатора ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'alc-rees':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр документов ЕГАИС"     p-tooltip = "Реестр документов ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-optprc.w':U then do:     assign     p-use-List_ = no      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оптовый прайс-лист"     p-tooltip = "Оптовый прайс-лист"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/iecliart.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Процедуры импорта экспорта артикулов поставщиков"     p-tooltip = "Процедуры импорта экспорта артикулов поставщиков"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthps-zone':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthparts-obj':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '&bef-wthsref-stts}':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrd':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthob':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-type':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-stts':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = yes      p-use-type-price = yes      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-sup':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-wth':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-ptlbal':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ctrasm':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Контроль ассортиментной матрицы"     p-tooltip = "Контроль ассортиментной матрицы"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-eslg-e':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'prphoto':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(2256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(2256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Прайс-лист с фото товаров"     p-tooltip = "Прайс-лист с фото товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkgdsfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Товарная строка чека - доп поля"     p-tooltip = "Товарная строка чека - доп поля "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkdocfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Чек - доп поля"     p-tooltip = "Чек - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'barcodfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Бар-код - доп поля"     p-tooltip = "Бар-код - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'UPD':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника Электронного документоборота"     p-tooltip = "Настройки справочника Электронного документоборота"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'LK_RECEIPT':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-tooltip = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end.
end procedure.
procedure uf-get :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .
    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
       (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.
end procedure.
procedure uf-set :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
      (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function get-work-status returns character
  ( p-user-id as character ) :
    define variable v-work-status as character no-undo .
    run procedure-get-work-status in this-procedure (
        input p-user-id
      , output v-work-status
    ) .
    return v-work-status .
end function.
procedure procedure-get-work-status :
define input  parameter p-user-id     as character no-undo .
define output parameter p-work-status as character no-undo .
    define buffer buf_user-login for ub.user-login .
do
for buf_user-login
on error undo, return error return-value
:
    if p-user-id = v-cntxt-userid
    then do:
        assign
            p-work-status = "*":U
        .
    end.
    else do:
        find first buf_user-login exclusive-lock
             where buf_user-login.db-num    = v-cntxt-db-num
               and buf_user-login.user-id   = p-user-id
        no-error no-wait .
        if not available buf_user-login
        then do:
            if locked buf_user-login
            then do:
            assign
                p-work-status = "+":U
            .
            end.
            else do:
            assign
                p-work-status = "":U
            .
            end.
        end.
        else do:
            assign
                p-work-status = "":U
            .
        end.
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  i-type
  ,input  i-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure can-edit-login :
  define input  parameter p-db-num   as integer   no-undo .
  define output parameter p-can-edit as logical   no-undo .
  define buffer buf_db for ub.db .
  do
  on error undo, return error return-value
  :
    find first buf_db no-lock
         where buf_db.db-num = p-db-num
    no-error.
    if not available buf_db
    then do:
      message
        vss-workfile vss-revision vss-description
        skip "Внутренняя ошибка"
        skip "Неизвестный номер БД" p-db-num
        skip view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-can-edit = ( p-db-num = v-cntxt-db-num
                    or
                    buf_db.db-key = '':U
                    or v-cntxt-db-num = 0
                   )
    .
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
      if vChange
      then do trans:
         run can-edit-login in this-procedure
              (input  p-db-num
              ,output v-can-edit
              ) .
            if v-can-edit <> true
            then do:
              message
                "Нельзя редактировать логин пользователя для базы" p-db-num skip
                view-as alert-box error .
              undo, return error return-value .
            end.
         if get-work-status( p-user-id ) = '+':u
         then do:
            message
                "Нельзя редактировать пароль работающего пользователя" skip
               view-as alert-box error .
                 undo, return error "Нельзя редактировать пароль работающего пользователя" .
         end.
      end.
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
        if  buf_user-login.user-id = v-cntxt-userid
        and buf_user-login.db-num  = v-cntxt-db-num
        then do:
          message
            "Нельзя удалять текущий логин" skip
            "БД"  buf_user-login.db-num skip
            "Идентификатор" buf_user-login.user-id skip
            view-as alert-box error .
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
define variable v-users-name-filter     as character    no-undo.
define variable v-users-login-filter    as character    no-undo.
define variable v-filter-yes            as logical      no-undo.
define variable v-user-login            as logical      no-undo.
define variable v-users-user-login      as logical      no-undo.
define variable v-users-work-status     as character    no-undo.
define variable v-users-last-cb-db      as integer      no-undo.
define variable v-ok                    as logical      no-undo.
define variable v-users-set-rowid       as logical      no-undo.
define variable v-users-current-rowid   as rowid        no-undo.
define variable v-users-current-focus   as integer      no-undo.
define variable v-only-lookup           as logical      no-undo.
define variable v-rowid-login           as rowid        no-undo.
define variable mSuperAdm               as logical no-undo.
define buffer buf_init_user-account      for user-account.
define buffer buf_init_user-login        for user-login.
define stream out-stream.
define stream OutStr-html.
define variable p-report-id               as integer              no-undo .
define variable v-report-name-html        as CHARACTER            no-undo .
define variable v-report-name-html-list   as CHARACTER            no-undo .
  define temp-table tt-user-login no-undo
    field users-id   like ub.user-login.user-id
    field nik        like ub.user-account.nik
    field db-num     like ub.user-login.db-num
    field user-login like ub.user-login.user-login
    field last-login-mjd like ub.user-login.last-login-mjd
    field last-name  as character
  .
define buffer buf_global-state      for ub.global-state .
define buffer buf_global-state-attr for ub.global-state-attr .
define variable v-action-gbl    as logical      no-undo .
FUNCTION get-person-name RETURNS CHARACTER
  ( p-psn-code as integer )  FORWARD.
DEFINE MENU POPUP-MENU-b-print
       MENU-ITEM m_b-print-prava LABEL "Список прав пользователей"
       MENU-ITEM m_b-print-user LABEL "Пользователь"
       MENU-ITEM m_b-print-list LABEL "Список пользователей"
       MENU-ITEM last-pwd LABEL "Отчет о смене паролей "
       MENU-ITEM adm-bd LABEL "Пользователи с правами администраторов БД"
.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-add-2
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg-2
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-copy
     LABEL "&Копировать"
     SIZE 10.5 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-del-2
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-dup
     LABEL "&Копия"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "В&ыход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-filter
     LABEL "Ф&Поиск"
     SIZE 10 BY 1 TOOLTIP "Поиск с фильтрацией по фамилии, имени пользователя, псевдониму и логину".
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-hist-user
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-print
     LABEL "Печать"
     SIZE 3 BY 1.
DEFINE BUTTON b-userhist
     LABEL "&История"
     SIZE 10 BY 1.
DEFINE BUTTON bt-firm
     LABEL "Фирмы"
     SIZE 10 BY 1.
DEFINE BUTTON bt-menu
     LABEL "Меню"
     SIZE 10 BY 1.
DEFINE BUTTON bt-object
     LABEL "Объекты"
     SIZE 10 BY 1.
DEFINE BUTTON bt-password
     LABEL "&Пароль"
     SIZE 10 BY 1.
DEFINE BUTTON bt-role
     LABEL "Права"
     SIZE 10 BY 1.
DEFINE VARIABLE cb-db AS INTEGER FORMAT "->>>>9":U INITIAL -1
     LABEL "БД"
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEM-PAIRS "0",1
     DROP-DOWN-LIST
     SIZE 20 BY 1 TOOLTIP "База данных, в которой у пользователя есть логин" NO-UNDO.
DEFINE VARIABLE ed-login-object AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-VERTICAL
     SIZE 50 BY 12.25
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE ed-user-info AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 56.5 BY 3.5
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-filter-comment AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE rs-scope AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Тек", 1,
"Все", 2,
"Удал", 3
     SIZE 18 BY .75
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tb-filter AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.63 BY .79 NO-UNDO.
DEFINE QUERY br-login FOR
      buf_init_user-login SCROLLING.
DEFINE QUERY br-user FOR
      buf_init_user-account,
      temp_filter-fields SCROLLING.
DEFINE BROWSE br-login
  QUERY br-login NO-LOCK DISPLAY
      buf_init_user-login.db-num FORMAT ">>>>9":U column-label " БД"
      buf_init_user-login.user-login COLUMN-LABEL " Логин" FORMAT "X(12)":U
            WIDTH 19.5
      buf_init_user-login.max-discnt FORMAT ">>9.99":U WIDTH 20.75 column-label "Макс.скидка"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50 BY 6.75 FIT-LAST-COLUMN.
DEFINE BROWSE br-user
  QUERY br-user NO-LOCK DISPLAY
      buf_init_user-account.nik COLUMN-LABEL " Псевдоним"  FORMAT "X(10)":U
      buf_init_user-account.last-name COLUMN-LABEL " Фамилия"  FORMAT "X(24)":U
      buf_init_user-account.first-name COLUMN-LABEL " Имя" FORMAT "X(12)":U
      get-user-login( buf_init_user-account.user-id ) @ v-users-user-login COLUMN-LABEL " БД" FORMAT "X(9)":U
      buf_init_user-account.user-id COLUMN-LABEL " ID"  FORMAT "X(8)":U
      get-person-name( buf_init_user-account.psn-code ) COLUMN-LABEL " Физ. лицо"  FORMAT "X(40)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 56.5 BY 16.75 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1.5
     cb-db AT ROW 1 COL 13.88 COLON-ALIGNED WIDGET-ID 40
     b-filter AT ROW 1 COL 54.63 WIDGET-ID 26
     fi-filter-comment AT ROW 1 COL 63.13 COLON-ALIGNED NO-LABEL WIDGET-ID 20 NO-TAB-STOP
     tb-filter AT ROW 1 COL 96.38 WIDGET-ID 60
     b-hist AT ROW 1 COL 98.88 WIDGET-ID 64
     b-print AT ROW 1 COL 101.75 WIDGET-ID 62
     b-help AT ROW 1 COL 104.75
     rs-scope AT ROW 1.25 COL 36.5 NO-LABEL WIDGET-ID 42
     b-add AT ROW 2.25 COL 1.5 WIDGET-ID 2
     b-chg AT ROW 2.25 COL 11.5 WIDGET-ID 4
     b-dup AT ROW 2.25 COL 21.5 WIDGET-ID 58
     b-del AT ROW 2.25 COL 31.5 WIDGET-ID 6
     b-userhist AT ROW 2.25 COL 41.5 WIDGET-ID 62
     b-hist-user AT ROW 2.25 COL 51.5 WIDGET-ID 64
     b-add-2 AT ROW 2.25 COL 58.5 WIDGET-ID 28
     b-copy AT ROW 2.25 COL 68.38 WIDGET-ID 66
     b-chg-2 AT ROW 2.25 COL 78.75 WIDGET-ID 30
     b-del-2 AT ROW 2.25 COL 88.63 WIDGET-ID 32
     bt-password AT ROW 2.25 COL 98.5 WIDGET-ID 56
     br-user AT ROW 3.25 COL 1.5 WIDGET-ID 200
     br-login AT ROW 3.25 COL 58.5 WIDGET-ID 300
     bt-object AT ROW 10 COL 58.5 WIDGET-ID 48
     bt-firm AT ROW 10 COL 68.5 WIDGET-ID 52
     bt-role AT ROW 10 COL 78.5 WIDGET-ID 50
     bt-menu AT ROW 10 COL 88.5 WIDGET-ID 54
     ed-login-object AT ROW 11.25 COL 58.5 NO-LABEL WIDGET-ID 36
     ed-user-info AT ROW 20 COL 1.5 NO-LABEL WIDGET-ID 34
     SPACE(50.99) SKIP(0.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Пользователи"
         DEFAULT-BUTTON b-exit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-print:HANDLE.
ASSIGN b-print :MENU-MOUSE = 1.
ASSIGN
       ed-login-object:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       ed-user-info:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-filter-comment:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
    define variable v-user-id                   as character    no-undo.
    define variable v-last-name                 as character    no-undo.
    define variable v-first-name                as character    no-undo.
    define variable v-second-name               as character    no-undo.
    define variable v-nik                       as character    no-undo.
    define variable v-phone-number              as character    no-undo.
    define variable v-mobile-phone-number       as character    no-undo.
    define variable v-company                   as character    no-undo.
    define variable v-department                as character    no-undo.
    define variable v-position                  as character    no-undo.
    define variable v-room                      as character    no-undo.
    define variable v-e-mail                    as character    no-undo.
    define variable v-internal-phone-number     as character    no-undo.
    define variable v-PS                        as character    no-undo.
    define variable v-accepted                  as logical      no-undo.
    define variable v-created                   as logical      no-undo.
    define variable v-psn-code                  as integer      no-undo.
    define variable v-adm-Ubd                   as logical      no-undo.
    define variable v-adm-gbd                   as logical      no-undo.
    define variable v-superAdm                  as logical      no-undo.
    define variable v-TabUserAdm                as handle       no-undo.
    define buffer buf_user-account      for user-account.
    define buffer buf_user-login        for user-login.
    run getAccountSetting (input  ?,
                              output v-adm-Ubd,
                              output v-adm-gbd,
                              output v-superAdm,
                              input-output table-handle v-TabUserAdm).
    run str/user.w (
          input parparentproc
        , input this-procedure
        , input 'ДОБАВЛЕНИЕ':U
        , input "< Новый >"
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input "":U
        , input ?
        , input ?
        , input no
        , input ?
        , input-output table-handle v-TabUserAdm
        , output v-last-name
        , output v-first-name
        , output v-second-name
        , output v-nik
        , output v-phone-number
        , output v-mobile-phone-number
        , output v-company
        , output v-department
        , output v-position
        , output v-room
        , output v-e-mail
        , output v-internal-phone-number
        , output v-PS
        , output v-psn-code
        , output v-adm-gbd
        , output v-superAdm
        , output v-adm-Ubd
        , output v-accepted
    ) no-error.
    if error-status :error
    then do:
        message
                    vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка редактирования пользователя."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                    trim( error-status :get-message( 2 ) )
                    trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return no-apply.
    end.
    if v-accepted = yes
    then do:
        run str/usracc01.p (
              input 'ДОБАВЛЕНИЕ':U
            , input v-cntxt-db-num
            , input "":U
            , input v-last-name
            , input v-first-name
            , input v-second-name
            , input v-nik
            , input v-phone-number
            , input v-mobile-phone-number
            , input v-company
            , input v-department
            , input v-position
            , input v-room
            , input v-e-mail
            , input v-internal-phone-number
            , input v-PS
            , input v-psn-code
            , input v-superAdm
            , output v-user-id
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка изменения данных пользователя."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
        define variable v-yesno    as logical      no-undo.
        if mSuperadm
        then
           v-yesno = yes.
        else do:
           message
                    "Создать логин для нового пользователя?"
           view-as alert-box question
           buttons yes-no
           title "Создание логина"
           update v-yesno .
        end.
        if v-yesno = yes
        then do:
            run procedure-user-login-create in this-procedure (
                  input "'ДОБАВЛЕНИЕ':U"
                , input if mSuperadm then ? else v-cntxt-db-num
                , input v-user-id
                , input v-adm-gbd
                , input v-adm-Ubd
                , input v-TabUserAdm
                , output v-created
            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка создания логина пользователя."
                    skip return-value
                    skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
                view-as alert-box error.
                undo, return no-apply.
            end.
        end.
        else do:
            if v-cntxt-db-num = 0
            then do:
                assign
                    cb-db = -1
                .
                display
                    cb-db
                with frame Dialog-Frame.
            end.
        end.
        run assign-field-filter-mark in this-procedure (
              input v-users-name-filter
            , input v-users-login-filter
        ).
        run open-query in this-procedure ( input this-procedure ).
        find first buf_user-account no-lock
             where buf_user-account.user-id = v-user-id
        .
        run manage-fields in this-procedure.
        if v-created = yes
        then do:
            find first buf_user-login no-lock
                 where buf_user-login.user-id  = v-user-id
            no-error.
            if available buf_user-login
            then
               reposition br-login to rowid rowid( buf_user-login ) no-error.
        end.
        apply "entry":U to br-user.
    end.
END.
ON CHOOSE OF b-add-2 IN FRAME Dialog-Frame
DO:
    define variable v-created               as logical      no-undo.
    if available buf_init_user-account
    then do:
        run procedure-user-login-create in this-procedure (
              input "add"
            , input v-cntxt-db-num
            , input buf_init_user-account.user-id
            , input ?
            , input ?
            , input ?
            , output v-created
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка создания логина пользователя."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
        if v-created = yes
        then do:
            run open-query-login in this-procedure.
            run manage-fields-login in this-procedure .
        end.
    end.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
    define variable v-user-id                   as character    no-undo.
    define variable v-last-name                 as character    no-undo.
    define variable v-first-name                as character    no-undo.
    define variable v-second-name               as character    no-undo.
    define variable v-nik                       as character    no-undo.
    define variable v-phone-number              as character    no-undo.
    define variable v-mobile-phone-number       as character    no-undo.
    define variable v-company                   as character    no-undo.
    define variable v-department                as character    no-undo.
    define variable v-position                  as character    no-undo.
    define variable v-room                      as character    no-undo.
    define variable v-e-mail                    as character    no-undo.
    define variable v-internal-phone-number     as character    no-undo.
    define variable v-PS                        as character    no-undo.
    define variable v-adm-Ubd                   as logical      no-undo init ?.
    define variable v-adm-gbd                   as logical      no-undo init ?.
    define variable v-superAdm                  as logical      no-undo.
    define variable v-TabUserAdm                as handle       no-undo.
    define variable v-accepted                  as logical      no-undo.
    define variable v-psn-code                  as integer    no-undo.
    define buffer buf_user-account-attr for ub.user-account-attr .
    if available buf_init_user-account
    then do:
       run getAccountSetting (input  buf_init_user-account.user-id,
                              output v-adm-Ubd,
                              output v-adm-gbd,
                              output v-superAdm,
                              input-output table-handle v-TabUserAdm).
       run str/user.w (
              input parparentproc
            , input this-procedure
            , input 'ИЗМЕНЕНИЕ':U
            , input buf_init_user-account.user-id
            , input buf_init_user-account.last-name
            , input buf_init_user-account.first-name
            , input buf_init_user-account.second-name
            , input buf_init_user-account.nik
            , input buf_init_user-account.phone-number
            , input buf_init_user-account.mobile-phone-number
            , input buf_init_user-account.company
            , input buf_init_user-account.department
            , input buf_init_user-account.position
            , input buf_init_user-account.room
            , input buf_init_user-account.e-mail
            , input buf_init_user-account.internal-phone-number
            , input buf_init_user-account.PS
            , INPUT buf_init_user-account.psn-code
            , input v-adm-gbd
            , input v-superAdm
            , input v-adm-Ubd
            , input-output table-handle v-TabUserAdm
            , output v-last-name
            , output v-first-name
            , output v-second-name
            , output v-nik
            , output v-phone-number
            , output v-mobile-phone-number
            , output v-company
            , output v-department
            , output v-position
            , output v-room
            , output v-e-mail
            , output v-internal-phone-number
            , output v-PS
            , output v-psn-code
            , output v-adm-gbd
            , output v-superAdm
            , output v-adm-Ubd
            , output v-accepted
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка редактирования пользователя."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
        if v-accepted = yes
        then do:
            run str/usracc01.p (
                  input 'ИЗМЕНЕНИЕ':U
                , input v-cntxt-db-num
                , input buf_init_user-account.user-id
                , input v-last-name
                , input v-first-name
                , input v-second-name
                , input v-nik
                , input v-phone-number
                , input v-mobile-phone-number
                , input v-company
                , input v-department
                , input v-position
                , input v-room
                , input v-e-mail
                , input v-internal-phone-number
                , input v-PS
                , input v-psn-code
                , input v-superAdm
                , output v-user-id
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка изменения данных пользователя."
                    skip return-value
                    skip trim( error-status :get-message( 1 ) )
                         trim( error-status :get-message( 2 ) )
                         trim( error-status :get-message( 3 ) )
                view-as alert-box error.
                undo, return no-apply.
            end.
            define variable v-created as logical no-undo.
            run procedure-user-login-create in this-procedure (
                  input 'ИЗМЕНЕНИЕ':U
                , input v-cntxt-db-num
                , input buf_init_user-account.user-id
                , input v-adm-gbd
                , input v-adm-Ubd
                , input v-TabUserAdm
                , output v-created
            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка создания логина пользователя."
                    skip return-value
                    skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
                view-as alert-box error.
                undo, return no-apply.
            end.
            run assign-field-filter-mark in this-procedure (
                  input v-users-name-filter
                , input v-users-login-filter
            ).
            run manage-fields in this-procedure .
            br-user :refresh().
        end.
    end.
END.
ON CHOOSE OF b-chg-2 IN FRAME Dialog-Frame
DO:
    if available buf_init_user-login
    then do:
        run procedure-user-login-edit in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры редактирования логина пользователя" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo, return no-apply .
        end.
        br-login :refresh().
        run manage-fields-login in this-procedure .
    end.
END.
ON CHOOSE OF b-copy IN FRAME Dialog-Frame
DO:
    if available buf_init_user-login
    then do:
        run procedure-user-login-copy in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры копирования логина пользователя" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo, return no-apply .
        end.
        br-login :refresh().
        run manage-fields-login in this-procedure .
    end.
    run open-query-login in this-procedure.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
    if available buf_init_user-account
    then do:
        if buf_init_user-account.user-id = v-cntxt-userid
        then do:
            message
                     "Невозможно удалить текущего пользователя"
                skip "Идентификатор пользователя" buf_init_user-account.user-id
                view-as alert-box error .
            undo, return no-apply.
        end.
        if  buf_init_user-account.status_ eq 0
        then do:
           define variable v-ok as logical   no-undo .
           message
                    "После удаления пользователь"
               skip "не сможет работать в системе"
               skip (1)
               skip "Псевдоним:" buf_init_user-account.nik skip
               skip "Имя:      " buf_init_user-account.last-name buf_init_user-account.first-name buf_init_user-account.second-name
               skip (1)
               skip "Удалить пользователя?"
           view-as alert-box question
           buttons yes-no
           title substitute( "Удаление пользователя '&1'", buf_init_user-account.nik )
           update v-ok.
           if v-ok = yes
           then do:
               run str/usracc03.p (
                     input buf_init_user-account.user-id
                   , input v-cntxt-db-num
               ) no-error .
               if error-status :error
               then do:
                   message
                           vss-workfile vss-revision vss-description
                       skip(1)
                       skip "Ошибка удаления пользователя."
                       skip return-value
                       skip trim( error-status :get-message( 1 ) )
                           trim( error-status :get-message( 2 ) )
                           trim( error-status :get-message( 3 ) )
                   view-as alert-box error.
                   undo, return no-apply.
               end.
               run open-query in this-procedure ( input this-procedure ).
               run manage-fields in this-procedure .
           end.
        end.
        else do:
           run str/usracc02.p (
                     input buf_init_user-account.user-id
            ) no-error .
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка удаления пользователя."
                    skip return-value
                    skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
                view-as alert-box error.
                undo, return no-apply.
            end.
            run open-query in this-procedure ( input this-procedure ).
            run manage-fields in this-procedure .
        end.
    end.
END.
ON CHOOSE OF b-del-2 IN FRAME Dialog-Frame
DO:
    define variable v-deleted    as logical      no-undo.
    if available buf_init_user-login
    then do:
        if  buf_init_user-login.status_ eq 0
        then do:
        run procedure-user-login-delete in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
            , output v-deleted
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка при вызове процедуры удаления логина пользователя"
                skip error-status :get-message(1)
                skip return-value
            view-as alert-box error .
            undo, return no-apply .
        end.
        end.
        else do transaction
           on error undo, return:
           define buffer buf_user-login for ub.user-login .
           find first buf_user-login exclusive-lock
                where buf_user-login.db-num  = buf_init_user-login.db-num
                  and buf_user-login.user-id = buf_init_user-login.user-id
           no-error .
           buf_user-login.status_ = 0.
           v-deleted = yes.
        end.
        if v-deleted = yes
        then do:
            run open-query-login in this-procedure.
            run manage-fields-login in this-procedure .
        end.
    end.
END.
ON CHOOSE OF b-dup IN FRAME Dialog-Frame
DO:
    define variable v-ok        as logical   no-undo .
    define variable v-rowid     as rowid        no-undo.
    define variable v-success   as logical      no-undo.
    if available buf_init_user-account
    then do:
        run duplicate-user in this-procedure (
              input buf_init_user-account.user-id
            , input v-cntxt-db-num
            , output v-rowid
            , output v-success
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка копирования пользователя."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
        if v-success = yes
        then do:
            run assign-field-filter-mark in this-procedure (
                  input v-users-name-filter
                , input v-users-login-filter
            ).
            run open-query in this-procedure ( input this-procedure ).
            run manage-fields in this-procedure .
            apply "entry":U to br-user.
        end.
    end.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
run save-position in this-procedure .
END.
ON CHOOSE OF b-filter IN FRAME Dialog-Frame
DO:
    define variable v-accepted      as logical      no-undo.
    run str/usersf.w (
          input parparentproc
        , input v-users-name-filter
        , input v-users-login-filter
        , output v-users-name-filter
        , output v-users-login-filter
        , output fi-filter-comment
        , output v-accepted
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка изменения фильтра."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                 trim( error-status :get-message( 2 ) )
                 trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return no-apply.
    end.
    if v-accepted = yes
    then do:
        if fi-filter-comment = "":U
        then do:
            assign
                tb-filter = no
            .
            disable
                tb-filter
            with frame Dialog-Frame .
        end.
        else do:
            if available buf_init_user-account
            then do:
                assign
                    v-users-current-rowid = rowid( buf_init_user-account )
                    v-users-current-focus = br-user :focused-row in frame Dialog-Frame
                .
            end.
            assign
                tb-filter = yes
            .
            run assign-filter-mark in this-procedure (
                  input v-users-name-filter
                , input v-users-login-filter
            ).
            enable
                tb-filter
            with frame Dialog-Frame .
        end.
        display
            fi-filter-comment
            tb-filter
        with frame Dialog-Frame.
        run open-query in this-procedure ( input this-procedure ).
        run manage-fields in this-procedure .
        run open-query-login in this-procedure.
        run manage-fields-login in this-procedure .
    end.
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
DO:
  if available buf_init_user-account
    then do:
run str\usrlg.w (
                input parparentproc,
                input buf_init_user-account.user-id) no-error.
    end.
END.
ON CHOOSE OF b-hist-user IN FRAME Dialog-Frame
DO:
  if available buf_init_user-account
    then do:
run str\cusrhist.w (
                input parparentproc,
                input buf_init_user-account.user-id) no-error.
    end.
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
      run gbl/pop-up.p (self:handle, no) no-error.
END.
ON MOUSE-SELECT-CLICK OF b-print IN FRAME Dialog-Frame
DO:
   APPLY "CHOOSE" TO b-print IN FRAME Dialog-Frame.
END.
ON CHOOSE OF b-userhist IN FRAME Dialog-Frame
DO:
    if available buf_init_user-account
    then do:
        run str/usrlg.w (
              input parparentproc
            , input buf_init_user-account.user-id
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка просмотра истории действий пользователя."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
    end.
END.
ON VALUE-CHANGED OF br-login IN FRAME Dialog-Frame
DO:
    RUN manage-fields-login IN THIS-PROCEDURE.
END.
ON MOUSE-SELECT-DBLCLICK OF br-user IN FRAME Dialog-Frame
DO:
    define variable v-void-char     as character    no-undo.
    define variable v-void-int      as integer    no-undo.
    define variable v-void-log      as logical      no-undo.
    define variable v-adm-Ubd                   as integer      no-undo.
    define variable v-adm-gbd                   as logical      no-undo.
    define variable v-superAdm                  as logical      no-undo.
    define variable v-TabUserAdm                as handle       no-undo.
    define buffer buf_user-account-attr for ub.user-account-attr .
    if available buf_init_user-account
    then do:
        run getAccountSetting (input  buf_init_user-account.user-id,
                              output v-adm-Ubd,
                              output v-adm-gbd,
                              output v-superAdm,
                              input-output table-handle v-TabUserAdm).
        run str/user.w (
              input parparentproc
            , input this-procedure
            , input 'ПРОСМОТР':U
            , input buf_init_user-account.user-id
            , input buf_init_user-account.last-name
            , input buf_init_user-account.first-name
            , input buf_init_user-account.second-name
            , input buf_init_user-account.nik
            , input buf_init_user-account.phone-number
            , input buf_init_user-account.mobile-phone-number
            , input buf_init_user-account.company
            , input buf_init_user-account.department
            , input buf_init_user-account.position
            , input buf_init_user-account.room
            , input buf_init_user-account.e-mail
            , input buf_init_user-account.internal-phone-number
            , input buf_init_user-account.PS
            , input buf_init_user-account.psn-code
            , input v-adm-gbd
            , input v-superAdm
            , input v-adm-Ubd
            , input-output table-handle v-TabUserAdm
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-char
            , output v-void-int
            , output v-void-log
            , output v-void-log
            , output v-void-log
            , output v-void-log
        ).
    end.
END.
ON ROW-DISPLAY OF br-login IN FRAME Dialog-Frame
DO:
   if avail buf_init_user-login  then do:
     if
    buf_init_user-login.status_ ne 0
   then assign
      buf_init_user-login.db-num     :fgcolor in browse br-login = gray_color
      buf_init_user-login.user-login :fgcolor in browse br-login = gray_color
      buf_init_user-login.max-discnt :fgcolor in browse br-login = gray_color
   .
   else assign
      buf_init_user-login.db-num     :fgcolor in browse br-login = black_color
      buf_init_user-login.user-login :fgcolor in browse br-login = black_color
      buf_init_user-login.max-discnt :fgcolor in browse br-login = black_color
   .
end.
end.
ON ROW-DISPLAY OF br-user IN FRAME Dialog-Frame
DO:
    define variable v-work-status as character no-undo .
    if available buf_init_user-account
    then do:
        if buf_init_user-account.status_ = 1
        then do:
            assign
                buf_init_user-account.nik        :bgcolor in browse br-user = gray_color
                buf_init_user-account.last-name  :bgcolor in browse br-user = gray_color
                buf_init_user-account.first-name :bgcolor in browse br-user = gray_color
                v-users-user-login      :bgcolor in browse br-user = gray_color
                buf_init_user-account.user-id    :bgcolor in browse br-user = gray_color
            .
        end.
        else do:
            assign
                buf_init_user-account.nik        :bgcolor in browse br-user = WHITE_COLOR
                buf_init_user-account.last-name  :bgcolor in browse br-user = WHITE_COLOR
                buf_init_user-account.first-name :bgcolor in browse br-user = WHITE_COLOR
                v-users-user-login      :bgcolor in browse br-user = WHITE_COLOR
                buf_init_user-account.user-id    :bgcolor in browse br-user = WHITE_COLOR
            .
        end.
        run procedure-get-work-status in this-procedure (
              input buf_init_user-account.user-id
            , output v-work-status
        ).
        case v-work-status
        :
            when "+":U
            then do:
                assign
                    buf_init_user-account.nik        :fgcolor in browse br-user = CYAN_COLOR
                    buf_init_user-account.last-name  :fgcolor in browse br-user = CYAN_COLOR
                    buf_init_user-account.first-name :fgcolor in browse br-user = CYAN_COLOR
                    v-users-user-login      :fgcolor in browse br-user = CYAN_COLOR
                    buf_init_user-account.user-id    :fgcolor in browse br-user = CYAN_COLOR
                .
            end.
            when "*":U
            then do:
                assign
                    buf_init_user-account.nik        :fgcolor in browse br-user = BLUE_COLOR
                    buf_init_user-account.last-name  :fgcolor in browse br-user = BLUE_COLOR
                    buf_init_user-account.first-name :fgcolor in browse br-user = BLUE_COLOR
                    v-users-user-login      :fgcolor in browse br-user = BLUE_COLOR
                    buf_init_user-account.user-id    :fgcolor in browse br-user = BLUE_COLOR
                .
            end.
            otherwise do:
            end.
        end case.
    end.
END.
ON VALUE-CHANGED OF br-user IN FRAME Dialog-Frame
DO:
    RUN manage-fields IN THIS-PROCEDURE.
END.
ON CHOOSE OF bt-firm IN FRAME Dialog-Frame
DO:
    if available buf_init_user-login
    then do:
        run procedure-user-login-user-host in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове списка фирм, доступных пользователю" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo, return no-apply .
        end.
        run manage-fields-login in this-procedure .
    end.
END.
ON CHOOSE OF bt-menu IN FRAME Dialog-Frame
DO:
    if available buf_init_user-login
    then do:
        run procedure-user-login-menu-group in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
        ) no-error .
        if error-status :error
        then do:
           message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове списка меню, доступных пользователю" skip
              error-status :get-message(1) skip
              return-value skip
           view-as alert-box error .
           undo, return no-apply .
        end.
    end.
END.
ON CHOOSE OF bt-object IN FRAME Dialog-Frame
DO:
    if available buf_init_user-login
    then do:
        run procedure-user-login-user-obj in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове списка объектов, доступных пользователю" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo, return no-apply .
        end.
        run manage-fields-login in this-procedure .
    end.
END.
ON CHOOSE OF bt-password IN FRAME Dialog-Frame
DO:
    if available buf_init_user-login
    then do:
        run procedure-user-login-change-password in this-procedure (
              input buf_init_user-login.db-num
            , input buf_init_user-login.user-id
            , input yes
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры смены пароля" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo, return no-apply .
        end.
    end.
END.
ON CHOOSE OF bt-role IN FRAME Dialog-Frame
DO:
    if available buf_init_user-login
    then do:
       run procedure-user-login-action-role in this-procedure (
           input buf_init_user-login.db-num
         , input buf_init_user-login.user-id
       ) no-error .
       if error-status :error
       then do:
          message
             vss-workfile vss-revision vss-description skip
             "Ошибка при вызове списка прав пользователя" skip
             error-status :get-message(1) skip
             return-value skip
          view-as alert-box error .
          undo, return no-apply .
       end.
    end.
END.
ON VALUE-CHANGED OF cb-db IN FRAME Dialog-Frame
DO:
    define variable v-user-account-rowid    as rowid        no-undo.
    if available buf_init_user-account
    then do:
        assign
            v-user-account-rowid = rowid( buf_init_user-account )
        .
    end.
    assign
        cb-db
    .
    if rs-scope :screen-value = "1"
    then do:
        assign
            v-users-last-cb-db = cb-db
        .
    end.
    run assign-field-filter-mark in this-procedure (
          input v-users-name-filter
        , input v-users-login-filter
    ).
    run open-query in this-procedure ( input this-procedure ).
    run manage-fields in this-procedure.
    if not error-status :error
    then do:
        apply "value-changed":U to br-user.
    end.
END.
ON CHOOSE OF MENU-ITEM m_b-print-list
DO:
  if available (buf_init_user-login) then v-rowid-login = rowid (buf_init_user-login) .
        run get-report-num in parParentProc (
            output p-report-id
        ).
  v-report-name-html-list = session:temp-directory + "rpt" + string(p-report-id) + ".html".
    run PROC-print-list in this-procedure.
END.
ON CHOOSE OF MENU-ITEM last-pwd
DO:
   if available (buf_init_user-login)
   then
      v-rowid-login = rowid (buf_init_user-login) .
   run get-report-num in parParentProc (
            output p-report-id
        ).
   v-report-name-html-list = session:temp-directory + "rpt" + string(p-report-id) + ".html".
   run rep\last-pwd.p(v-report-name-html-list).
   run prn-lib-reportviewer in this-procedure (
             input parParentProc
            ,input v-report-name-html-list
            ,input ""
            ) no-error.
   if error-status:error
   then
      message return-value view-as alert-box.
END.
ON CHOOSE OF MENU-ITEM adm-bd
DO:
  if available (buf_init_user-login) then v-rowid-login = rowid (buf_init_user-login) .
        run get-report-num in parParentProc (
            output p-report-id
        ).
  v-report-name-html-list = session:temp-directory + "rpt" + string(p-report-id) + ".html".
  run rep\adm_bd.p(v-report-name-html-list).
  run prn-lib-reportviewer in this-procedure (
            input parParentProc
            ,input v-report-name-html-list
            ,input ""
            ) no-error.
  if error-status:error
  then
     message return-value view-as alert-box.
END.
ON CHOOSE OF MENU-ITEM m_b-print-prava
DO:
  if available (buf_init_user-login) then v-rowid-login = rowid (buf_init_user-login) .
        run get-report-num in parParentProc (
            output p-report-id
        ).
  v-report-name-html = session:temp-directory + "rpt" + string(p-report-id) + ".html".
    run PROC-print-prava in this-procedure.
        run open-query in this-procedure ( input this-procedure ).
        run manage-fields in this-procedure .
        run open-query-login in this-procedure.
        run manage-fields-login in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m_b-print-user
DO:
  if available buf_init_user-login
    then
  do:
    run adm/usr-prnt.p ( INPUT parparentproc
      , INPUT buf_init_user-login.user-id
      , INPUT buf_init_user-login.db-num
      ) .
  end.
  else do:
    message
         "Пользователь не найден, для которого необходим отчет"
       view-as alert-box information.
       return.
  end.
        run open-query in this-procedure ( input this-procedure ).
        run manage-fields in this-procedure .
        run open-query-login in this-procedure.
        run manage-fields-login in this-procedure .
END.
ON VALUE-CHANGED OF rs-scope IN FRAME Dialog-Frame
DO:
    define variable v-user-account-rowid    as rowid        no-undo.
    if available buf_init_user-account
    then do:
        assign
            v-user-account-rowid = rowid( buf_init_user-account )
        .
    end.
    if rs-scope <> 1
    then do:
        if rs-scope :screen-value = "1"
        and v-cntxt-db-num = 0
        then do:
            assign
                cb-db = v-users-last-cb-db
            .
            display
                cb-db
            with frame Dialog-Frame .
        end.
    end.
    assign
        rs-scope
    .
    if rs-scope <> 1
    and v-cntxt-db-num = 0
    then do:
        assign
            cb-db = -1
        .
        display
            cb-db
        with frame Dialog-Frame .
    end.
    run assign-field-filter-mark in this-procedure (
          input v-users-name-filter
        , input v-users-login-filter
    ).
    run open-query in this-procedure ( input this-procedure ).
    run manage-fields in this-procedure.
    if not error-status :error
    then do:
        apply "value-changed":U to br-user.
    end.
END.
ON VALUE-CHANGED OF tb-filter IN FRAME Dialog-Frame
DO:
    assign
        tb-filter
    .
    run open-query in this-procedure ( input this-procedure ).
    apply "entry":U to br-user.
END.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_users-lookup':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
    IF NOT v-ok then do:
       message
         "У вас нет прав на просмотр информации о пользователях"
       view-as alert-box information.
       return.
    end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-login :handle
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
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run init-fields in this-procedure .
    RUN enable_UI.
    run manage-fields in this-procedure .
    disable
        tb-filter
    with frame Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE assign-field-filter-mark :
define input parameter p-name-filter    as character        no-undo.
define input parameter p-login-filter    as character        no-undo.
    define buffer buf_user-account          for user-account.
    define buffer buf_user-login            for user-login.
    define buffer buf_temp_filter-fields    for temp_filter-fields.
do
for buf_user-account
  , buf_user-login
  , buf_temp_filter-fields
on error undo, return error
:
    for each buf_user-account no-lock
    :
        find first buf_temp_filter-fields
             where buf_temp_filter-fields.user-id = buf_user-account.user-id
        no-error.
        if not available buf_temp_filter-fields
        then do:
            create buf_temp_filter-fields.
            assign
                buf_temp_filter-fields.user-id              = buf_user-account.user-id
            .
        end.
        assign
            buf_temp_filter-fields.fld-record-visible = yes
        .
        if cb-db >= 0
        then do:
            find first buf_user-login no-lock
                 where buf_user-login.user-id = buf_user-account.user-id
                   and buf_user-login.db-num  = cb-db
            no-error.
            if not available buf_user-login
            then do:
                assign
                    buf_temp_filter-fields.fld-record-visible = no
                .
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE duplicate-user :
define input parameter p-user-id    as character        no-undo.
define input parameter p-db-num     as integer          no-undo.
define output parameter p-rowid     as rowid            no-undo.
define output parameter p-success   as logical          no-undo.
    define variable v-new-name      as character    no-undo.
    define variable v-new-nick      as character    no-undo.
    define variable v-new-login     as character    no-undo.
    define variable v-success       as logical      no-undo.
    define variable v-user-rowid    as rowid        no-undo.
    define variable v-next-user-id as character no-undo .
    define variable v-user-menu-group-code    as integer      no-undo.
    define variable v-user-login-role-code    as integer      no-undo.
    define buffer buf_user-account              for user-account .
    define buffer buf_user-login                for user-login .
    define buffer buf_user-obj                  for user-obj .
    define buffer buf_user-host                 for user-host .
    define buffer buf_user-menu-group           for user-menu-group .
    define buffer buf_user-login-action-role    for user-login-action-role .
    define buffer new_user-account              for user-account .
    define buffer new_user-login                for user-login .
    define buffer new_user-obj                  for user-obj .
    define buffer new_user-host                 for user-host .
    define buffer new_user-menu-group           for user-menu-group .
    define buffer new_user-login-action-role    for user-login-action-role .
do
for buf_user-account
  , buf_user-login
  , buf_user-obj
  , buf_user-host
  , buf_user-menu-group
  , buf_user-login-action-role
  , new_user-account
  , new_user-login
  , new_user-obj
  , new_user-host
  , new_user-menu-group
  , new_user-login-action-role
on error undo, return error
:
    find first buf_user-account exclusive-lock
         where buf_user-account.user-id = p-user-id
    no-error.
    if not available buf_user-account
    then do:
        message
            "Запись пользователя редактируется администратором."
            skip (1)
            skip "Повторите операцию через некоторое время."
        view-as alert-box warning.
        undo, return error .
    end.
    assign
        v-user-rowid = rowid( buf_user-account )
    .
    find first buf_user-account share-lock
         where buf_user-account.user-id = p-user-id
    .
    run get-new-name in this-procedure (
          input p-user-id
        , input p-db-num
        , output v-new-name
        , output v-new-nick
        , output v-new-login
        , output v-success
    ) no-error.
    if error-status :error
    then do:
        message
                    vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выбора имени нового"
            skip "пользователя для копирования."
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                    trim( error-status :get-message( 2 ) )
                    trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return error.
    end.
    if v-success = no
    then do:
        message
            "Не удалось создать копию"
            skip "пользователя и логина"
            skip "в текущей базе данных"
        view-as alert-box warning
        title "Копирование пользователя".
        undo, return .
    end.
    message
                "Текущий пользователь и его логин"
        skip "для текущей базы данных"
        skip "с правами в текущей базе данных"
        skip "будут скопированы как:"
        skip (1)
        skip substitute( "Фамилия:      &1", v-new-name  )
        skip substitute( "Псевдоним:    &1", v-new-nick  )
        skip substitute( "Логин (БД&1): &2", v-cntxt-db-num, v-new-login )
        skip (1)
        skip "Копировать пользователя?"
        view-as alert-box question
        buttons yes-no
        title "Копирование пользователя"
        update v-ok.
    if v-ok = yes
    then do:
if session :set-wait-state( "compiler" ) then.
        assign
                v-next-user-id  = substitute( "&1-&2":U
                                        , p-db-num
                                        , next-value( s-user-id ) )
        .
        find first new_user-account exclusive-lock
             where new_user-account.user-id = v-next-user-id
        no-error.
        if available new_user-account
        then do:
                undo, return error substitute( "Ошибка при создании пользователя (buf_init_user-account).&1Попытка создания записи с существующим кодом.&1.Код записи: &2"
                                                    , chr(10)
                                                    , v-next-user-id  ).
        end.
        create new_user-account .
        assign
                new_user-account.user-id   = v-next-user-id
                new_user-account.last-name = v-new-name
                new_user-account.nik       = v-new-nick
        .
        buffer-copy buf_user-account
            except user-id last-name nik
                to new_user-account
                .
        if v-new-login <> "":U
        then do:
            find first buf_user-login no-lock
                 where buf_user-login.user-id = p-user-id
                   and buf_user-login.db-num  = p-db-num
            no-error
            .
            if not available buf_user-login
            then do:
                message
                    "Логин пользователя редактируется администратором."
                    skip (1)
                    skip substitute( "Пользователь: &1", buf_user-account.nik )
                    skip substitute( "БД:           &1", p-db-num             )
                    skip (1)
                    skip "Повторите операцию через некоторое время."
                view-as alert-box warning.
                undo, return error .
            end.
            create new_user-login.
            buffer-copy buf_user-login
                except user-id db-num user-login  user-administrator
                    to new_user-login
            assign
                    new_user-login.user-login       = v-new-login
                    new_user-login.user-id          = v-next-user-id
                    new_user-login.db-num           = p-db-num
            .
            FOR EACH  buf_user-obj no-lock
                where buf_user-obj.db-num  = buf_user-login.db-num
                    and buf_user-obj.user-id = buf_user-login.user-id
            :
                create new_user-obj.
                assign
                    new_user-obj.user-id  = v-next-user-id
                    new_user-obj.db-num   = p-db-num
                    new_user-obj.obj-type = buf_user-obj.obj-type
                    new_user-obj.obj-code = buf_user-obj.obj-code
                .
                buffer-copy buf_user-obj
                except db-num user-id obj-type obj-code
                        to new_user-obj
                        .
            end.
            FOR EACH buf_user-host
               where buf_user-host.db-num  = buf_user-login.db-num
                 and buf_user-host.user-id = buf_user-login.user-id
                no-lock
                :
                    create new_user-host.
                    assign
                        new_user-host.user-id   = v-next-user-id
                        new_user-host.db-num    = p-db-num
                        new_user-host.host-code = buf_user-host.host-code
                    .
                    buffer-copy buf_user-host
                    except db-num user-id host-code
                            to new_user-host
                            .
            end.
            FOR EACH  buf_user-menu-group
                where buf_user-menu-group.db-num  = buf_user-login.db-num
                    and buf_user-menu-group.user-id = buf_user-login.user-id
                no-lock
                :
                    assign
                    v-user-menu-group-code = next-value(s-user-menu-group)
                    .
                    create new_user-menu-group.
                    assign
                        new_user-menu-group.user-id  = v-next-user-id
                        new_user-menu-group.db-num   = p-db-num
                        new_user-menu-group.user-menu-group-code = v-user-menu-group-code
                    .
                    buffer-copy buf_user-menu-group
                        except db-num user-id user-menu-group-code
                            to new_user-menu-group
                            .
            end.
            FOR EACH  buf_user-login-action-role
                where buf_user-login-action-role.db-num  = buf_user-login.db-num
                    and buf_user-login-action-role.user-id = buf_user-login.user-id
                no-lock
                :
                    assign
                    v-user-login-role-code = next-value(s-user-login-action-role)
                    .
                    create new_user-login-action-role.
                    assign
                    new_user-login-action-role.user-id  = v-next-user-id
                    new_user-login-action-role.db-num   = p-db-num
                    new_user-login-action-role.user-login-role-code = v-user-login-role-code
                    .
                    buffer-copy buf_user-login-action-role
                    except db-num user-id user-login-role-code
                            to new_user-login-action-role
                            .
            end.
        end.
if session :set-wait-state( "" ) then.
        assign
            p-rowid     = rowid( new_user-account )
            p-success   = yes
        .
   end.
end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY cb-db fi-filter-comment tb-filter rs-scope ed-login-object
          ed-user-info
      WITH FRAME Dialog-Frame.
  ENABLE b-exit cb-db b-filter fi-filter-comment tb-filter b-hist b-print b-help
         rs-scope b-add b-chg b-dup b-del b-userhist b-hist-user b-add-2
         b-chg-2 b-del-2 bt-password br-user br-login bt-object bt-firm bt-role
         bt-menu ed-login-object ed-user-info
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run open-query-login in this-procedure.    run open-query in this-procedure ( input this-procedure ).
END PROCEDURE.
PROCEDURE get-new-name :
define input parameter p-user-id        as character        no-undo.
define input parameter p-db-num         as integer          no-undo.
define output parameter p-new-name      as character        no-undo.
define output parameter p-new-nick      as character        no-undo.
define output parameter p-new-login     as character        no-undo.
define output parameter p-success       as logical          no-undo.
    define variable v-counter           as integer      no-undo.
    define variable v-ini-login         as character    no-undo.
    define variable v-ini-name          as character    no-undo.
    define variable v-ini-nick          as character    no-undo.
    define buffer buf_user-account      for user-account.
    define buffer buf_nick_user-account for user-account.
    define buffer buf_user-login        for user-login.
do
for buf_user-account
  , buf_nick_user-account
  , buf_user-login
on error undo, return error
:
    find first buf_user-account no-lock
         where buf_user-account.user-id = p-user-id
    .
    assign
        v-ini-name  = buf_user-account.last-name
        v-ini-nick  = buf_user-account.nik
        p-new-name  = substitute( "Копия_&1", buf_user-account.last-name )
        p-new-nick  = substitute( "Копия_&1", buf_user-account.nik       )
    .
    find first buf_user-login no-lock
         where buf_user-login.db-num    = p-db-num
           and buf_user-login.user-id   = buf_user-account.user-id
    no-error.
    if not available buf_user-login
    then do:
        assign
            v-ini-login = "":U
            p-new-login = "":U
        .
    end.
    else do:
        assign
            v-ini-login = buf_user-login.user-login
            p-new-login = substitute( "Копия_&1", buf_user-login.user-login )
        .
    end.
    assign
        v-counter        = 1
    .
    find first buf_user-account no-lock
         where buf_user-account.last-name = p-new-name
    no-error.
    find first buf_nick_user-account no-lock
         where buf_nick_user-account.last-name = p-new-nick
    no-error.
    if p-new-login <> "":U
    then do:
        find first buf_user-login no-lock
             where buf_user-login.user-login  = p-new-login
        no-error.
    end.
    do
    while available buf_user-account
    or available buf_nick_user-account
    or ( p-new-login <> "":U and available buf_user-login )
    :
        assign
            v-counter           = v-counter + 1
            p-new-name     = substitute( "Копия(&1)_&2", v-counter, v-ini-name  )
            p-new-nick     = substitute( "Копия(&1)_&2", v-counter, v-ini-nick  )
            p-new-login    = substitute( "Копия(&1)_&2", v-counter, v-ini-login )
        .
        find first buf_user-account no-lock
             where buf_user-account.last-name = p-new-name
        no-error.
        find first buf_nick_user-account no-lock
             where buf_nick_user-account.last-name = p-new-nick
        no-error.
        if p-new-login <> "":U
        then do:
            find first buf_user-login no-lock
                 where buf_user-login.user-login  = p-new-login
            no-error.
        end.
    end.
    assign
        p-success   = yes
    .
end.
END PROCEDURE.
PROCEDURE assign-filter-mark :
define input parameter p-name-filter    as character        no-undo.
define input parameter p-login-filter    as character        no-undo.
    define buffer buf_user-account          for user-account.
    define buffer buf_user-login            for user-login.
    define buffer buf_temp_filter-fields    for temp_filter-fields.
do
for buf_user-account
  , buf_user-login
  , buf_temp_filter-fields
on error undo, return error
:
    for each buf_user-account no-lock
    :
        find first buf_temp_filter-fields
             where buf_temp_filter-fields.user-id = buf_user-account.user-id
        no-error.
        if not available buf_temp_filter-fields
        then do:
            create buf_temp_filter-fields.
            assign
                buf_temp_filter-fields.user-id              = buf_user-account.user-id
                buf_temp_filter-fields.flt-record-visible   = no
            .
        end.
        if ( p-name-filter = "":U and p-login-filter = "":U )
        or index( buf_user-account.last-name,  p-name-filter ) <> 0
        or index( buf_user-account.first-name, p-name-filter ) <> 0
        then do:
            assign
                buf_temp_filter-fields.flt-record-visible = yes
            .
        end.
        else do:
            assign
                buf_temp_filter-fields.flt-record-visible = no
            .
            search-in-login:
            for each buf_user-login no-lock
               where buf_user-login.user-id = buf_user-account.user-id
            :
                if index( buf_user-login.user-login, p-login-filter ) <> 0
                then do:
                    assign
                        buf_temp_filter-fields.flt-record-visible = yes
                    .
                end.
                leave search-in-login.
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE get-saved-position :
    define variable v-current-rowid-string      as character    no-undo.
    define variable v-current-focus-string      as character    no-undo.
    define variable v-current-db-string         as character    no-undo.
    define variable v-current-status-string     as character    no-undo.
    define variable v-void-logical              as logical      no-undo.
    define variable v-void-character            as character    no-undo.
do
on error undo, return error
:
   run uf-get (
        input 'users-1':U
      , input  v-cntxt-userid
      , output v-current-status-string
      , output v-current-db-string
      , output v-void-logical
      , output v-void-logical
      , output v-void-logical
      , output v-void-logical
   ) .
   run uf-get (
           input 'users-2':U
         , input  v-cntxt-userid
         , output v-current-focus-string
         , output v-current-rowid-string
         , output v-void-logical
         , output v-void-logical
         , output v-void-logical
         , output v-void-logical
   ) .
   assign
      cb-db                   = IF v-current-db-string <> "":U       THEN integer(  v-current-db-string     ) ELSE cb-db
      rs-scope                = IF v-current-status-string <> "":U   THEN integer(  v-current-status-string ) ELSE rs-scope
      v-users-current-rowid   = IF v-current-rowid-string <> "":U    THEN to-rowid( v-current-rowid-string  ) ELSE v-users-current-rowid
      v-users-current-focus   = IF v-current-focus-string <> "":U    THEN integer(  v-current-focus-string  ) ELSE 1
   .
   IF cb-db = ?
   THEN DO:
      ASSIGN
         cb-db = v-cntxt-db-num
      .
   END.
   IF rs-scope = ?
   THEN DO:
      ASSIGN
         rs-scope    = 1
      .
   END.
end.
END PROCEDURE.
PROCEDURE get-user-fields :
define input parameter p-user-id                as character        no-undo.
define output parameter p-last-name             as character        no-undo.
define output parameter p-first-name            as character        no-undo.
define output parameter p-second-name           as character        no-undo.
define output parameter p-nik                   as character        no-undo.
define output parameter p-phone-number          as character        no-undo.
define output parameter p-mobile-phone-number   as character        no-undo.
define output parameter p-company               as character        no-undo.
define output parameter p-department            as character        no-undo.
define output parameter p-room                  as character        no-undo.
define output parameter p-e-mail                as character        no-undo.
define output parameter p-internal-phone-number as character        no-undo.
define output parameter p-PS                    as character        no-undo.
    define buffer buf_user-account      for user-account.
do
for buf_user-account
on error undo, return error
:
    find first buf_user-account no-lock
         where buf_user-account.user-id = p-user-id
    no-error.
    if available buf_user-account
    then do:
        assign
            p-last-name             = buf_user-account.last-name
            p-first-name            = buf_user-account.first-name
            p-second-name           = buf_user-account.second-name
            p-nik                   = buf_user-account.nik
            p-phone-number          = buf_user-account.phone-number
            p-mobile-phone-number   = buf_user-account.mobile-phone-number
            p-company               = buf_user-account.company
            p-department            = buf_user-account.department
            p-room                  = buf_user-account.room
            p-e-mail                = buf_user-account.e-mail
            p-internal-phone-number = buf_user-account.internal-phone-number
            p-PS                    = buf_user-account.PS
        .
    end.
    else do:
        assign
            p-last-name             = "":U
            p-first-name            = "":U
            p-second-name           = "":U
            p-nik                   = "":U
            p-phone-number          = "":U
            p-mobile-phone-number   = "":U
            p-company               = "":U
            p-department            = "":U
            p-room                  = "":U
            p-e-mail                = "":U
            p-internal-phone-number = "":U
            p-PS                    = "":U
        .
    end.
end.
END PROCEDURE.
PROCEDURE init-fields :
    define buffer buf_db                    for db.
    define buffer buf_user-account          for user-account.
    define buffer buf_temp_filter-fields    for temp_filter-fields.
do
with frame Dialog-Frame
on error undo, return error
:
    assign
        cb-db :delimiter        = chr(4)
        rs-scope    = 1
        cb-db :list-item-pairs = substitute( "&2&1&3"
                                    , chr(4)
                                    , "< Все >"
                                    , -1 )
    .
    if v-cntxt-db-num > 0
    then do:
      for each buf_db
          where buf_db.db-num = v-cntxt-db-num
          no-lock
      on error undo, return error
      :
         assign
               cb-db :list-item-pairs = substitute ( "&2&1&4 &3&1&4"
                                                   , chr(4)
                                                   , cb-db :list-item-pairs
                                                   , buf_db.db-name
                                                   , buf_db.db-num
                                                   )
         .
      end.
    end.
    else do:
      for each buf_db no-lock
      on error undo, return error
      :
         assign
               cb-db :list-item-pairs = substitute ( "&2&1&4 &3&1&4"
                                                   , chr(4)
                                                   , cb-db :list-item-pairs
                                                   , buf_db.db-name
                                                   , buf_db.db-num
                                                   )
         .
      end.
    end.
    assign
       cb-db = v-cntxt-db-num
    .
    assign
        v-users-name-filter = "":U
        v-users-login-filter = "":U
        v-users-set-rowid    = yes
    .
    run get-saved-position in this-procedure.
    run assign-field-filter-mark in this-procedure (
          input v-users-name-filter
        , input v-users-login-filter
    ).
    find first user-account-attr where user-account-attr.user-id    eq g#userid
                                   and user-account-attr.attr-code  eq "superadm"
    no-lock no-error.
    if     available user-account-attr
       and logical(user-account-attr.attr-value) eq yes
    then
       mSuperAdm = yes.
end.
END PROCEDURE.
PROCEDURE manage-fields :
define buffer user-login for user-login.
do
with frame Dialog-Frame
on error undo, return error
:
    run open-query-login in this-procedure.
    run manage-fields-login in this-procedure .
    define variable vflag as logical no-undo.
    if   available buf_init_user-account
      and buf_init_user-account.user-id eq g#userid
       or mSuperAdm
    then
       vflag = yes.
    else do:
       find first user-login where user-login.user-id eq buf_init_user-account.user-id
                               and user-login.status_ eq buf_init_user-account.status_
                               and user-login.user-administrator no-lock no-error.
       vflag = not available user-login.
    end.
    b-chg:sensitive = vflag.
    b-dup:sensitive = true.
    b-del:sensitive = vflag.
    assign
        ed-user-info = "":U
    .
    if available buf_init_user-account
    then do:
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , buf_init_user-account.phone-number
                                , ( if buf_init_user-account.phone-number = "":U then "":U else ", " )
                                , buf_init_user-account.mobile-phone-number
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.company
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.department
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.position
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.room
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.e-mail
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.internal-phone-number
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.internal-phone-number
                                ), ", " )
        .
        assign
            ed-user-info = trim( substitute( "&1&2&3"
                                , ed-user-info
                                , ( if ed-user-info  = "":U then "":U else ", " )
                                , buf_init_user-account.PS
                                ), ", " )
        .
        b-del:label = if    not avail buf_init_user-account
                         or buf_init_user-account.status_ eq 0
                      then "Удалить"
                      else "Вост.".
    end.
    display
        ed-user-info
    .
end.
END PROCEDURE.
PROCEDURE manage-fields-login :
    define variable v-host-code    as integer      no-undo.
    define buffer buf_temp_user-login-obj   for temp_user-login-obj.
    define buffer buf_user-obj              for user-obj.
    define buffer buf_user-host             for user-host.
    define buffer buf_clients               for clients.
    define buffer buf_user-login            for user-login.
do
for buf_temp_user-login-obj
  , buf_user-obj
  , buf_user-host
  , buf_clients
  , buf_user-login
with frame Dialog-Frame
on error undo, return error
:
    if cb-db > 0
    and available buf_init_user-account
    then do:
        find first buf_init_user-login no-lock
             where buf_init_user-login.db-num  = cb-db
               and buf_init_user-login.user-id = buf_init_user-account.user-id
        no-error.
        if available buf_init_user-login
        then do:
            reposition br-login to rowid rowid( buf_init_user-login ) no-error.
            apply "value-changed" to br-login.
        end.
    end.
    assign
        ed-login-object = "":U
    .
    b-del-2:label = if    not avail buf_init_user-login
                       or buf_init_user-login.status_ eq 0
                  then "Удалить"
                  else "Вост.".
    empty temp-table buf_temp_user-login-obj.
    if available buf_init_user-login
    then do:
        for each buf_user-obj no-lock
           where buf_user-obj.db-num  = buf_init_user-login.db-num
             and buf_user-obj.user-id = buf_init_user-login.user-id
        :
            find first buf_temp_user-login-obj
                 where buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
                   and buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
                   and buf_temp_user-login-obj.obj-type    = buf_user-obj.obj-type
                   and buf_temp_user-login-obj.obj-code    = buf_user-obj.obj-code
            no-error.
            if not available buf_temp_user-login-obj
            then do:
                find first buf_clients no-lock
                     where buf_clients.obj-type = buf_user-obj.obj-type
                       and buf_clients.obj-code = buf_user-obj.obj-code
                .
                create buf_temp_user-login-obj.
                assign
                    buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
                    buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
                    buf_temp_user-login-obj.obj-type    = buf_clients.obj-type
                    buf_temp_user-login-obj.obj-code    = buf_clients.obj-code
                    buf_temp_user-login-obj.host-code   = buf_clients.host-code
                    buf_temp_user-login-obj.obj-name    = substitute( "  &1", buf_clients.obj-name )
                .
                assign
                    v-host-code = buf_temp_user-login-obj.host-code
                .
                find first buf_temp_user-login-obj
                     where buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
                       and buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
                       and buf_temp_user-login-obj.obj-type    = " ":U
                       and buf_temp_user-login-obj.obj-code    = v-host-code
                no-error.
                if not available buf_temp_user-login-obj
                then do:
                    find first buf_clients no-lock
                         where buf_clients.obj-type = 'орг':U
                           and buf_clients.obj-code = v-host-code
                    .
                    create buf_temp_user-login-obj.
                    assign
                        buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
                        buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
                        buf_temp_user-login-obj.obj-type    = " ":U
                        buf_temp_user-login-obj.obj-code    = buf_clients.obj-code
                        buf_temp_user-login-obj.host-code   = buf_clients.obj-code
                        buf_temp_user-login-obj.obj-name    = substitute( "&1", buf_clients.obj-name )
                    .
                end.
            end.
        end.
        for each buf_user-host no-lock
           where buf_user-host.db-num  = buf_init_user-login.db-num
             and buf_user-host.user-id = buf_init_user-login.user-id
        :
            find first buf_temp_user-login-obj
                 where buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
                   and buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
                   and buf_temp_user-login-obj.obj-type    = " ":U
                   and buf_temp_user-login-obj.obj-code    = buf_user-host.host-code
            no-error.
            if not available buf_temp_user-login-obj
            then do:
                find first buf_clients no-lock
                     where buf_clients.obj-type = 'орг':U
                       and buf_clients.obj-code = buf_user-host.host-code
                .
                create buf_temp_user-login-obj.
                assign
                    buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
                    buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
                    buf_temp_user-login-obj.obj-type    = " ":U
                    buf_temp_user-login-obj.obj-code    = buf_clients.obj-code
                    buf_temp_user-login-obj.host-code   = buf_clients.obj-code
                    buf_temp_user-login-obj.obj-name    = substitute( "&1", buf_clients.obj-name )
                .
            end.
        end.
        for each buf_temp_user-login-obj
           where buf_temp_user-login-obj.db-num      = buf_init_user-login.db-num
             and buf_temp_user-login-obj.user-id     = buf_init_user-login.user-id
        by buf_temp_user-login-obj.host-code
        by buf_temp_user-login-obj.obj-type
        on error undo, return error
        :
            assign
                ed-login-object = substitute( "&1&2&3"
                                        , ed-login-object
                                        , ( if ed-login-object = "":U then "":U else chr(10) )
                                        , buf_temp_user-login-obj.obj-name )
            .
        end.
        define variable v-have-login    as logical      no-undo.
        assign
            v-have-login = no
        .
        if buf_init_user-login.db-num = v-cntxt-db-num
        then do:
            assign
                v-have-login = yes
            .
        end.
        else do:
            search-cur-db-login:
            for each buf_user-login no-lock
               where buf_user-login.user-id = buf_init_user-login.user-id
            on error undo, return error
            :
                if buf_user-login.db-num = v-cntxt-db-num
                then do:
                    assign
                        v-have-login = yes
                    .
                    undo search-cur-db-login, leave search-cur-db-login.
                end.
            end.
        end.
           FIND FIRST buf_global-state
        NO-LOCK
        .
        FIND FIRST buf_global-state-attr
      WHERE buf_global-state-attr.gls-id = buf_global-state.gls-id
         AND buf_global-state-attr.attr-code = "action-gbl"
      NO-LOCK
      NO-error
      .
   IF AVAILABLE buf_global-state-attr
   THEN DO:
     if buf_global-state-attr.attr-value = "yes" then v-action-gbl = yes .
   END.
        if v-have-login = yes and v-cntxt-db-num <> 0
        then do:
            disable
                b-add-2
                b-copy
            .
        end.
        else do:
        if v-action-gbl then do:
            enable
                b-copy
            .
        end.
            enable
                b-add-2
            .
        end.
        if buf_init_user-login.db-num = v-cntxt-db-num or v-cntxt-db-num = 0
        then do:
           define variable vflag as logical no-undo.
           vflag = mSuperAdm or  not buf_init_user-login.user-administrator or buf_init_user-login.user-id eq g#userid.
                b-chg-2:sensitive = vflag.
                b-del-2:sensitive = vflag.
                bt-password:sensitive = vflag.
                bt-object:sensitive = vflag.
                bt-firm:sensitive = vflag.
                bt-role:sensitive = vflag.
                bt-menu:sensitive = vflag.
                if v-cntxt-db-num = 0
                then
                   b-copy:sensitive = vflag.
        end.
        else do:
            disable
                b-copy
                b-chg-2
                b-del-2
                bt-password
                bt-object
                bt-firm
                bt-role
                bt-menu
            .
        end.
    end.
    else do:
        if v-action-gbl then do:
            enable
                b-copy
            .
        end.
        enable
            b-add-2
        .
        disable
            b-copy
            b-chg-2
            b-del-2
            bt-password
            bt-object
            bt-firm
            bt-role
            bt-menu
        .
    end.
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_users-update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  FALSE
    ,output v-ok
    )  .
end.
    if v-ok = FALSE
    then do:
        disable
            b-add
            b-chg
            b-del
            b-add-2
            b-chg-2
            b-del-2
            bt-password
            b-dup
        .
        assign
            v-only-lookup = TRUE
        .
    end.
    display
        ed-login-object
    .
end.
END PROCEDURE.
PROCEDURE open-query :
    define input parameter p-proc-handle    as handle           no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    if v-users-set-rowid = no
    and available buf_init_user-account
    then do:
        assign
            v-users-current-rowid = rowid( buf_init_user-account )
            v-users-current-focus = br-user :focused-row in frame Dialog-Frame
        .
    end.
    else do:
        assign
            v-users-set-rowid = no
        .
    end.
    if fi-filter-comment = "":U
    or tb-filter = no
    then do:
        assign
            fi-filter-comment :bgcolor = GREY_COLOR
        .
    end.
    else do:
        assign
            fi-filter-comment :bgcolor = RED_COLOR
        .
    end.
    case rs-scope
    :
        when 1
        then do:
            OPEN QUERY br-user
                FOR EACH buf_init_user-account no-lock
                   where buf_init_user-account.status_ <> 1
                 , first temp_filter-fields
                   where temp_filter-fields.user-id   = buf_init_user-account.user-id
                     and temp_filter-fields.fld-record-visible = yes
                     and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
                      by buf_init_user-account.last-name
                      by buf_init_user-account.first-name
                      by buf_init_user-account.second-name
            .
        end.
        when 2
        then do:
            OPEN QUERY br-user
                FOR EACH buf_init_user-account no-lock
                 , first temp_filter-fields
                   where temp_filter-fields.user-id   = buf_init_user-account.user-id
                     and temp_filter-fields.fld-record-visible = yes
                     and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
                      by buf_init_user-account.last-name
                      by buf_init_user-account.first-name
                      by buf_init_user-account.second-name
            .
        end.
        when 3
        then do:
            OPEN QUERY br-user
                FOR EACH buf_init_user-account no-lock
                   where buf_init_user-account.status_ = 1
                 , first temp_filter-fields
                   where temp_filter-fields.user-id   = buf_init_user-account.user-id
                     and temp_filter-fields.fld-record-visible = yes
                     and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
                      by buf_init_user-account.last-name
                      by buf_init_user-account.first-name
                      by buf_init_user-account.second-name
            .
        end.
    end case.
    if v-users-current-focus > 0
    then do:
        br-user :set-repositioned-row( v-users-current-focus, "ALWAYS") in frame Dialog-Frame.
    end.
    reposition br-user to rowid v-users-current-rowid no-error.
    if error-status :error
    then do:
        query br-user :handle :get-first( no-lock ).
        reposition br-user to rowid rowid( buf_init_user-account ) no-error.
    end.
    apply "entry" to br-user.
end.
END PROCEDURE.
PROCEDURE open-query-login :
do
on error undo, return error
:
    if available buf_init_user-account
    then do:
        OPEN QUERY br-login
            FOR EACH buf_init_user-login NO-LOCK
               where buf_init_user-login.user-id = buf_init_user-account.user-id
            by buf_init_user-login.db-num
        INDEXED-REPOSITION.
    end.
    else do:
        OPEN QUERY br-login
            FOR EACH buf_init_user-login NO-LOCK
               where buf_init_user-login.user-id = "":U
            by buf_init_user-login.db-num
        INDEXED-REPOSITION.
    end.
end.
END PROCEDURE.
PROCEDURE person-user :
define input parameter  p-rec-user-account as recid            no-undo.
define output parameter p-ok               as logical          no-undo.
do
on error undo, return error
:
   define buffer buf_user-account      for ub.user-account .
   define buffer buf_clients     for ub.clients .
   define variable recid-person as character no-undo.
   FIND FIRST buf_user-account
        WHERE RECID(buf_user-account) = p-rec-user-account
        NO-LOCK
        .
   IF AVAILABLE buf_user-account
   AND buf_user-account.psn-code <> 0
   AND buf_user-account.psn-code <> ?
   THEN DO:
      FIND FIRST buf_clients
           WHERE buf_clients.obj-code = buf_user-account.psn-code
             and buf_clients.obj-type = 'чел':U
           no-lock
           no-error
           .
      IF AVAILABLE buf_clients
      THEN DO:
         ASSIGN
           recid-person = string( recid( buf_clients ) )
         .
      END.
   END.
   run ref/cli-all.w ( input parparentproc
                     , input "b-sel"
                     , input 'чел':U
                     , input 'все':U
                     , input 'текущие':U
                     , input ?
                     , input ",,,,,,NO,,"
                     , input "lock-cli-type":U
                     , output recid-person
                     ) .
   IF recid-person <> "":U
   THEN DO:
      FIND FIRST buf_clients
           WHERE RECID(buf_clients) = INTEGER(ENTRY(1, recid-person))
           no-lock
           no-error
           .
      IF AVAILABLE buf_clients
      AND buf_user-account.psn-code <> buf_clients.obj-code
      THEN DO TRANSACTION:
         FIND CURRENT buf_user-account
              EXCLUSIVE-LOCK
              .
         ASSIGN
            buf_user-account.psn-code = buf_clients.obj-code
            p-ok = yes
         .
         FIND CURRENT buf_user-account
              NO-LOCK
              .
      END.
   END.
   ELSE DO:
      IF buf_user-account.psn-code <> ?
      THEN DO TRANSACTION:
         FIND CURRENT buf_user-account
              EXCLUSIVE-LOCK
              .
         ASSIGN
            buf_user-account.psn-code = ?
            p-ok = yes
         .
         FIND CURRENT buf_user-account
              NO-LOCK
              .
      END.
   END.
   RELEASE buf_user-account.
end.
END PROCEDURE.
PROCEDURE proc-print-list :
  define buffer buf_user-login for ub.user-login .
  define buffer buf_user-account for ub.user-account .
  define VARIABLE v-last-name as character no-undo.
  define VARIABLE v-last-name1 as character no-undo.
  define VARIABLE v-last-name2 as character no-undo.
  define buffer buf_temp_filter-fields    for temp_filter-fields.
do
on error undo, return error
:
  output stream OutStr-html to value(v-report-name-html-list) convert target 'UTF-8' .
  put stream OutStr-html unformatted
    substitute(
    '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 900px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="list-users" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:50px"></td>
                        <td style="width:200px"></td>
                        <td style="width:200px"></td>
                        <td style="width:50px"></td>
                        <td style="width:200px"></td>
                        <td style="width:200px"></td>
                      </tr>
                      <tr>
                        <td colspan="6" style="font-size:16px;font-weight:bold; text-align: center;">Список пользователей</td>
                      </tr>
                    </thead>
                    <tbody> <!-- Здесь начинается таблица отчета -->
                      <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                        <th style="text-align: center;">ID</th>
                        <th style="text-align: center;">ФИО</th>
                        <th style="text-align: center;">Псевдоним</th>
                        <th style="text-align: center;">Номер БД</th>
                        <th style="text-align: center;">Логин</th>
                        <th style="text-align: center;">Дата/время последнего входа</th>
                      </tr>'
    , chr(123), chr(125)
    ).
if cb-db <> -1 then do:
    case rs-scope
        :
        when 1 then do:
            message   temp_filter-fields.user-id view-as alert-box.
            FOR EACH buf_init_user-login where temp_filter-fields.user-id =  buf_init_user-login.user-id
             and buf_init_user-account.status_ <> 1
             NO-LOCK:
              assign
              v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
                create tt-user-login .
                assign
                tt-user-login.db-num         = buf_init_user-login.db-num
                tt-user-login.last-login-mjd = buf_init_user-login.last-login-mjd
                tt-user-login.nik            = buf_init_user-account.nik
                tt-user-login.user-login     = buf_init_user-login.user-login
                tt-user-login.users-id       = buf_init_user-login.user-id
                tt-user-login.last-name      = v-last-name
                .
            END.
        end.
        when 2 then do:
            FOR EACH buf_init_user-account :
                FOR EACH  buf_init_user-login where  buf_init_user-account.user-id = buf_init_user-login.user-id
                   AND buf_init_user-login.db-num = cb-db
                   AND temp_filter-fields.fld-record-visible = yes
                   and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
                      NO-LOCK :
                      assign
                      v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
                      create tt-user-login .
                      assign
                      tt-user-login.db-num         = buf_init_user-login.db-num
                      tt-user-login.last-login-mjd = buf_init_user-login.last-login-mjd
                      tt-user-login.nik            = buf_init_user-account.nik
                      tt-user-login.user-login     = buf_init_user-login.user-login
                      tt-user-login.users-id       = buf_init_user-login.user-id
                      tt-user-login.last-name      = v-last-name
                      .
                    END.
            end.
        end.
        when 3  then do:
            FOR EACH buf_init_user-account WHERE buf_init_user-account.status_ <> 1 no-lock:
                FOR EACH  buf_init_user-login where  buf_init_user-account.user-id = buf_init_user-login.user-id
                AND buf_init_user-login.db-num = cb-db
                AND temp_filter-fields.fld-record-visible = yes
                and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
                    NO-LOCK BY buf_init_user-account.nik :
                assign
                    v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
                    create tt-user-login .
                    assign
                    tt-user-login.db-num         = buf_init_user-login.db-num
                    tt-user-login.last-login-mjd = buf_init_user-login.last-login-mjd
                    tt-user-login.nik            = buf_init_user-account.nik
                    tt-user-login.user-login     = buf_init_user-login.user-login
                    tt-user-login.users-id       = buf_init_user-login.user-id
                    tt-user-login.last-name      = v-last-name
                    .
                    END.
            END.
        end.
    end case.
END.
 if cb-db = -1 then do:
   FOR EACH buf_init_user-account
      no-lock:
      case rs-scope :
        when 1 then do:
            FOR EACH buf_init_user-login where buf_init_user-account.status_ <> 1
            and buf_init_user-account.user-id = buf_init_user-login.user-id
            and temp_filter-fields.user-id   = buf_init_user-account.user-id
            and temp_filter-fields.fld-record-visible = yes
            and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
            no-lock:
            assign
            v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
            create tt-user-login .
            assign
            tt-user-login.db-num         = buf_init_user-login.db-num
            tt-user-login.last-login-mjd = buf_init_user-login.last-login-mjd
            tt-user-login.nik            = buf_init_user-account.nik
            tt-user-login.user-login     = buf_init_user-login.user-login
            tt-user-login.users-id       = buf_init_user-login.user-id
            tt-user-login.last-name      = v-last-name
            .
            end.
        end.
        when 2 then do:
            FOR EACH buf_init_user-login where buf_init_user-account.user-id = buf_init_user-login.user-id
                and temp_filter-fields.fld-record-visible = yes
                and ( temp_filter-fields.flt-record-visible = yes or tb-filter = no )
                NO-LOCK:
                assign
                v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
                create tt-user-login .
                assign
                tt-user-login.db-num         = buf_init_user-login.db-num
                tt-user-login.last-login-mjd = buf_init_user-login.last-login-mjd
                tt-user-login.nik            = buf_init_user-account.nik
                tt-user-login.user-login     = buf_init_user-login.user-login
                tt-user-login.users-id       = buf_init_user-login.user-id
                tt-user-login.last-name      = v-last-name
                .
            end.
        end.
        when 3  then do:
            FOR EACH buf_init_user-login where buf_init_user-account.status_ = 1
              and buf_init_user-account.user-id = buf_init_user-login.user-id
              and temp_filter-fields.user-id   = buf_init_user-account.user-id
              NO-LOCK:
                 assign
                 v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
                 create tt-user-login .
                 assign
                  tt-user-login.db-num         = buf_init_user-login.db-num
                  tt-user-login.last-login-mjd = buf_init_user-login.last-login-mjd
                  tt-user-login.nik            = buf_init_user-account.nik
                  tt-user-login.user-login     = buf_init_user-login.user-login
                  tt-user-login.users-id       = buf_init_user-login.user-id
                  tt-user-login.last-name      = v-last-name
                 .
            end.
        end.
      end case.
    end.
END.
  run prn-lib-reportviewer-report-name in this-procedure (
    input parParentProc
    ,input v-report-name-html-list
    ).
  for each tt-user-login no-lock:
                  put stream OutStr-html unformatted
                  substitute(
                  '<tr>
                            <td>&1</td>
                            <td>&2</td>
                            <td>&3</td>
                            <td>&4</td>
                            <td>&5</td>
                            <td>&6</td>
                   </tr>'
                  ,tt-user-login.users-id
                  ,tt-user-login.last-name
                  ,tt-user-login.nik
                  ,string(tt-user-login.db-num)
                  ,tt-user-login.user-login
                  ,if tt-user-login.last-login-mjd <> 0 then string(sys-time_mjd-to-loc-str-func(tt-user-login.last-login-mjd)) else ""
                  ).
          end.
         output stream OutStr-html close.
END.
EMPTY TEMP-TABLE tt-user-login .
END PROCEDURE.
PROCEDURE proc-print-prava :
  define buffer buf_user-login-action-role for ub.user-login-action-role .
  define buffer buf_action-role-item       for ub.action-role-item .
  define buffer buf_action-item            for ub.action-item .
  define buffer buf_action-role            for ub.action-role .
  define VARIABLE v-first as LOGICAL no-undo .
  define VARIABLE v-ok2 as LOGICAL no-undo .
  define VARIABLE ii      as integer no-undo .
  define VARIABLE jj      as integer no-undo .
  define VARIABLE v-action-role-context as character no-undo .
  define VARIABLE v-last-name as character no-undo.
  define VARIABLE v-last-name1 as character no-undo.
  define VARIABLE v-last-name2 as character no-undo.
do
on error undo, return error
:
  output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' .
  put stream OutStr-html unformatted
    substitute(
    '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 850px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="list_users" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:200px"></td>
                        <td style="width:200px"></td>
                        <td style="width:50px"></td>
                        <td style="width:200px"></td>
                        <td style="width:200px"></td>
                      </tr>
                      <tr>
                        <td colspan="5" style="font-size:16px;font-weight:bold; text-align: center;">Список прав пользователей</td>
                      </tr>
                    </thead>
                    <tbody> <!-- Здесь начинается таблица отчета -->
                      <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                        <th style="text-align: center;">ФИО</th>
                        <th style="text-align: center;">Псевдоним</th>
                        <th style="text-align: center;">БД</th>
                        <th style="text-align: center;">Привязка</th>
                        <th style="text-align: center;">Группа</th>
                      </tr>'
    , chr(123), chr(125)
    ).
  get first br-user.
  do while available buf_init_user-account:
  assign ii = 0
         jj = 0
         v-first = no.
         v-last-name = buf_init_user-account.last-name + ' ' + buf_init_user-account.first-name + ' ' + buf_init_user-account.second-name .
      for each buf_init_user-login where buf_init_user-login.user-id = buf_init_user-account.user-id:
          assign v-first = yes
                 v-ok2 = no.
          FOR EACH buf_user-login-action-role
            WHERE buf_user-login-action-role.action-head-code    = 0
            AND buf_user-login-action-role.user-id             = buf_init_user-login.user-id
            NO-LOCK:
              if not v-action-gbl and buf_user-login-action-role.db-num              <> buf_init_user-login.db-num then next .
              find FIRST buf_action-role
                WHERE buf_action-role.action-head-code    = 0
                AND buf_action-role.action-role-code    = buf_user-login-action-role.action-role-code
                AND (buf_action-role.db-num              = buf_init_user-login.db-num OR buf_action-role.db-num = 0)
                AND (buf_init_user-login.db-num          = cb-db or string(cb-db) = '-1')
                NO-LOCK no-error.
                if AVAILABLE buf_action-role then do:
                assign
                  ii = ii + 1
                  jj = jj + 1
                  v-ok2 = yes .
                  if buf_user-login-action-role.action-role-context = 'global':U then do:
                  assign v-action-role-context = "Без привязки". end.
                  if buf_user-login-action-role.action-role-context = 'firm':U then do:
                  assign v-action-role-context = SUBSTITUTE("Фирма &1", string(buf_user-login-action-role.host-code)). end.
                  if buf_user-login-action-role.action-role-context = 'object':U then do:
                  assign v-action-role-context = SUBSTITUTE("&1 &2", buf_user-login-action-role.obj-type, buf_user-login-action-role.obj-code).
                  end.
                put stream OutStr-html unformatted
                  substitute(
                  '<tr>
                            <td>&1</td>
                            <td>&2</td>
                            <td>&3</td>
                            <td>&4</td>
                            <td>&5</td>
                   </tr>'
                  ,
                  if ii > 1 or jj > 1 then "" else string(v-last-name),
                  if ii > 1 or jj > 1 then "" else string(buf_init_user-account.nik),
                  if ii > 1 or jj > 1 then "" else string(buf_init_user-login.db-num),
                  string(v-action-role-context),
                  string(buf_action-role.action-role-name)
                  ).
                  end.
                  else
                  if (buf_init_user-login.db-num          = cb-db or string(cb-db) = '-1') then do:
                  put stream OutStr-html unformatted
                          substitute(
                          '<tr>
                                    <td>&1</td>
                                    <td>&2</td>
                                    <td>&3</td>
                                    <td></td>
                                    <td></td>
                           </tr>'
                          ,
                          if ii > 1 or jj > 1 then "" else string(v-last-name),
                          if ii > 1 or jj > 1 then "" else string(buf_init_user-account.nik),
                          if ii > 1 or jj > 1 then "" else string(buf_init_user-login.db-num)
                          ).
                  end.
          end.
          if v-ok2 = no and (buf_init_user-login.db-num = cb-db or string(cb-db) = '-1') then
          do:
            put stream OutStr-html unformatted
              substitute(
              '<tr>
                                            <td>&1</td>
                                            <td>&2</td>
                                            <td>&3</td>
                                            <td></td>
                                            <td></td>
                    </tr>'
              ,
              (v-last-name),
              (buf_init_user-account.nik),
              (buf_init_user-login.db-num)
              ).
          end.
      end.
      if v-first = no then do:
      put stream OutStr-html unformatted
        substitute(
        '<tr>
              <td>&1</td>
              <td>&2</td>
              <td></td>
              <td></td>
              <td></td>
        </tr>'
        ,
        (v-last-name),
        (buf_init_user-account.nik)
        ).
      end.
    get next br-user.
  end.
         output stream OutStr-html close.
  run prn-lib-reportviewer-report-name in this-procedure (
    input parParentProc
    ,input v-report-name-html
    ).
end.
END PROCEDURE.
PROCEDURE procedure-get-person-name :
define input  parameter p-psn-code    as integer   no-undo .
define output parameter p-person-name as character no-undo .
define buffer buf_person      for ub.person .
define buffer buf_clients     for ub.clients .
do
on error undo, return error return-value
:
    assign
        p-person-name = "":U
    .
    IF p-psn-code = ?
    THEN DO:
        assign
            p-person-name = "Нет привязки к физическому лицу"
        .
    END.
    ELSE DO:
      FIND FIRST buf_person
           WHERE buf_person.psn-code = p-psn-code
           no-lock
           no-error
           .
      FIND FIRST buf_clients
           WHERE buf_clients.obj-type = 'чел':U
             AND buf_clients.obj-code = p-psn-code
           no-lock
           no-error
           .
      IF AVAILABLE buf_person
      THEN DO:
         assign
               p-person-name = SUBSTITUTE ( "&1 &2&3&4&5"
                                          , buf_clients.obj-name
                                          , IF buf_person.name1 <>"":U THEN SUBSTRING(buf_person.name1, 1, 1) ELSE "":U
                                          , IF buf_person.name1 <>"":U THEN ". " ELSE "":U
                                          , IF buf_person.name2 <>"":U THEN SUBSTRING(buf_person.name2, 1, 1) ELSE "":U
                                          , IF buf_person.name2 <>"":U THEN ". " ELSE "":U
                                          )
         .
      END.
      ELSE DO:
        assign
            p-person-name = SUBSTITUTE("Потеряна привязка к физ. лицу (&1)", p-psn-code)
        .
      END.
    END.
end.
END PROCEDURE.
PROCEDURE procedure-user-login-action-role :
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.
    define variable v-user-adm as logical   no-undo .
do
on error undo, return error
:
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run user-adm in g#library2
  (input  p-db-num
  ,input  p-user-id
  ,output v-user-adm
  )  .
    if v-user-adm
    then do:
         message "Пользователь - администратор. Ему доступны ВСЕ права." skip
                 "Добавление новых никак не скажется на его работе. Продолжить?" skip
                 view-as alert-box
                 buttons yes-no
                 update v-yes as logical
                 .
         if v-yes = yes
         then do:
            run str/useractn.w (
                  input parparentproc
                , input buf_init_user-account.user-id
                , input p-db-num
            ).
         end.
    end.
    else do:
        run str/useractn.w (
              input parparentproc
            , input buf_init_user-account.user-id
            , input p-db-num
        ).
    end.
end.
END PROCEDURE.
PROCEDURE procedure-user-login-copy :
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.
  define variable v-can-edit as logical   no-undo .
  define buffer buf_user-account    for user-account.
  define buffer buf_user-login      for ub.user-login .
do
for buf_user-account
  , buf_user-login
on error undo, return error return-value
:
  find first buf_user-account no-lock
    where buf_user-account.user-id = p-user-id
    no-error.
  if available (buf_user-account) then
  do:
    if buf_user-account.status_ = 1 then
    do:
      message "Пользователь удален. Копирование логина невозможно"
        view-as alert-box.
      return no-apply .
    end.
  end.
    do transaction
    on error undo, return error return-value
    :
        find first buf_user-login exclusive-lock
             where buf_user-login.db-num  = p-db-num
               and buf_user-login.user-id = p-user-id
        no-error no-wait.
        if not available buf_user-login
        then do:
            if locked( buf_user-login )
            then do:
                find first buf_user-login no-lock
                     where buf_user-login.db-num  = p-db-num
                       and buf_user-login.user-id = p-user-id
                .
                find first buf_user-account no-lock
                     where buf_user-account.user-id = p-user-id
                .
                message
                    "Редактирование логина невозможно" skip
                    "Пользователь в данный момент работает в системе" skip
                    "БД" p-db-num skip
                    "Идентификатор" p-user-id skip
                    "Псевдоним"                    buf_user-account.nik skip
                    "Имя пользователя"             buf_user-account.last-name buf_user-account.first-name buf_user-account.second-name skip
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
                message
                    "Редактирование логина невозможно" skip
                    "У пользователя нет логина" skip
                    "БД" p-db-num skip
                    "Идентификатор" buf_init_user-account.user-id skip
                view-as alert-box error .
            end.
            undo, return error return-value .
        end.
    end.
    define variable v-update-data        as logical   no-undo .
    define variable v-user-login         as character no-undo .
    define variable v-user-administrator as logical   no-undo .
    define variable v-max-discnt         as decimal   no-undo .
    define variable v-quest-print        as logical   no-undo .
    define variable v-tmp-dbnum          as integer   no-undo .
    define variable v-list-db            as character no-undo .
    define variable v-success            as logical   no-undo .
    v-tmp-dbnum = buf_user-login.db-num.
    run str/usrloged2.w (
          input parparentproc
        , input 'ИЗМЕНЕНИЕ':U
        , input-output v-tmp-dbnum
        , input buf_user-login.user-id
        , input buf_user-login.user-login
        , input buf_user-login.user-administrator
        , input buf_user-login.max-discnt
        , input buf_user-login.quest-print
        , output v-list-db
        , output v-update-data
        , output v-user-login
        , output v-user-administrator
        , output v-max-discnt
        , output v-quest-print
    ) .
    if v-list-db = "" then
       return.
           run str/copy-login.p (
              input buf_user-login.user-id
            , input v-user-login
            , input p-db-num
            , input v-list-db
            , output v-success
        ) no-error.
        if error-status :error
        then do:
            message
                        vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка копирования логина."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return no-apply.
        end.
end.
END PROCEDURE.
PROCEDURE procedure-user-login-create :
define input  parameter iMode       as character no-undo.
define input  parameter p-db-num     as integer          no-undo.
define input  parameter p-user-id    as character        no-undo.
define input  parameter i-adm-gbd    as logical no-undo.
define input  parameter i-adm-ubd    as logical no-undo.
define input  parameter i-TabUserAdm as handle no-undo.
define output parameter p-created    as logical          no-undo.
    define variable v-update-data           as logical      no-undo .
    define variable v-user-login            as character    no-undo .
    define variable v-user-administrator    as logical      no-undo .
    define variable v-max-discnt            as decimal      no-undo .
    define variable v-quest-print           as logical      no-undo .
    define variable v-encoded-pass          as character    no-undo .
    define variable v-nextcon               as logical      no-undo init ? .
    define buffer buf_user-account      for user-account.
    define buffer buf_user-login        for user-login  .
    if imode eq 'ИЗМЕНЕНИЕ':U
    then do:
       find first buf_user-login where  buf_user-login.user-id            = p-user-id
                                   and  buf_user-login.db-num             = p-db-num
       no-lock no-error.
       if available buf_user-login
       then do:
          assign
             v-user-login         = buf_user-login.user-login
             v-user-administrator = buf_user-login.user-administrator
             v-max-discnt         = buf_user-login.max-discnt
             v-quest-print        = buf_user-login.quest-print
             v-encoded-pass       = buf_user-login.user-password-encoded
          .
          find first user-login-attr where user-login-attr.db-num    = buf_user-login.db-num
                                       and user-login-attr.user-id   = buf_user-login.user-id
                                       and user-login-attr.attr-code = "ChangPwdNextConect"
          no-lock no-error.
          v-nextcon = if available user-login-attr then logical(user-login-attr.attr-value) else ? no-error.
          p-created            = i-adm-gbd ne ? or i-adm-ubd ne ? or i-TabUserAdm ne ?.
       end.
       else do:
          find first buf_user-login where  buf_user-login.user-id            = p-user-id
          no-lock no-error.
          if available buf_user-login
          then do:
             assign
                v-user-login         = buf_user-login.user-login
                v-max-discnt         = buf_user-login.max-discnt
                v-quest-print        = buf_user-login.quest-print
                v-encoded-pass       = buf_user-login.user-password-encoded
             .
             find first user-login-attr where user-login-attr.db-num    = buf_user-login.db-num
                                          and user-login-attr.user-id   = buf_user-login.user-id
                                          and user-login-attr.attr-code = "ChangPwdNextConect"
             no-lock no-error.
             v-nextcon = if available user-login-attr then logical(user-login-attr.attr-value) else ? no-error.
             p-created            = i-adm-gbd ne ? or i-adm-ubd ne ? or i-TabUserAdm ne ?.
         end.
         else do:
            p-db-num = ?.
            run str/usrloged.w (
                   input parparentproc
                 , input 'ИЗМЕНЕНИЕ':U
                 , input-output p-db-num
                 , input p-user-id
                 , input "":U
                 , input false
                 , input 0
                 , input true
                 , output p-created
                 , output v-user-login
                 , output v-user-administrator
                 , output v-max-discnt
                 , output v-quest-print
             ) .
             imode = "'ДОБАВЛЕНИЕ':U".
          end.
       end.
    end.
    else
       run str/usrloged.w (
             input parparentproc
           , input 'ИЗМЕНЕНИЕ':U
           , input-output p-db-num
           , input p-user-id
           , input "":U
           , input false
           , input 0
           , input true
           , output p-created
           , output v-user-login
           , output v-user-administrator
           , output v-max-discnt
           , output v-quest-print
       ) .
    if p-created = yes
    then do:
       if imode ne 'ИЗМЕНЕНИЕ':U
       then do:
          set-correct-password:
          do while yes
          :
             find first buf_user-account no-lock
                  where buf_user-account.user-id = p-user-id
             .
             define variable voneadm as logical no-undo.
             run availOneAdm(input-output table-handle i-TabUserAdm, output voneadm).
             run adm/chg-pswd.w (
                   input parparentproc
                   , input p-db-num
                   , input p-user-id
                   , input v-user-login
                   , input substitute('&1 &2 &3':U,  buf_user-account.last-name
                                                   , buf_user-account.first-name
                                                   , buf_user-account.second-name
                           )
                   , input yes
                   , input yes
                   , input ""
                   , no
                   , i-adm-gbd or i-adm-ubd or voneadm
                   , output v-encoded-pass
                   , output v-nextcon
             ) no-error .
             if error-status :error
             then do:
                message
                   vss-workfile vss-revision vss-description
                       skip(1)
                       skip "Ошибка при назначении пароля"
                       skip return-value
                       skip trim( error-status :get-message( 1 ) )
                           trim( error-status :get-message( 2 ) )
                           trim( error-status :get-message( 3 ) )
                view-as alert-box error.
                undo, return error.
             end.
             if    v-encoded-pass = "":U
                or v-encoded-pass = ?
             then do:
                message
                       "Пароль пользователя не может быть пустым."
                       skip "Введите пароль."
                view-as alert-box warning
                    title "Ввод пароля".
             end.
             else do:
                leave set-correct-password.
             end.
          end.
       end.
       run update-user-login(p-db-num
                            ,p-user-id
                            ,v-user-login
                            ,v-max-discnt
                            ,v-quest-print
                            ,v-encoded-pass
                            ,v-nextcon
                            ,v-user-administrator
                            ,mSuperAdm and imode ne "add"
                            ,i-adm-gbd
                            ,i-adm-ubd
                            ,input-output table-handle i-TabUserAdm) no-error.
       if error-status:error
       then do:
          message return-value
          view-as alert-box.
          return error.
       end.
    end.
END PROCEDURE.
PROCEDURE procedure-user-login-edit :
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.
  define variable v-can-edit as logical   no-undo .
  define buffer buf_user-account    for user-account.
  define buffer buf_user-login      for ub.user-login .
do
for buf_user-account
  , buf_user-login
on error undo, return error return-value
:
    run can-edit-login in this-procedure (
          input p-db-num
        , output v-can-edit
    ) .
    if v-can-edit <> true
    then do:
        message
            "Нельзя редактировать логин пользователя для базы" p-db-num
        view-as alert-box error .
        undo, return error return-value .
    end.
    do :
        find first buf_user-login exclusive-lock
             where buf_user-login.db-num  = p-db-num
               and buf_user-login.user-id = p-user-id
        no-error no-wait.
        if not available buf_user-login
        then do:
            if locked( buf_user-login )
            then do:
                find first buf_user-login no-lock
                     where buf_user-login.db-num  = p-db-num
                       and buf_user-login.user-id = p-user-id
                .
                find first buf_user-account no-lock
                     where buf_user-account.user-id = p-user-id
                .
                message
                    "Редактирование логина невозможно" skip
                    "Пользователь в данный момент работает в системе" skip
                    "БД" p-db-num skip
                    "Идентификатор" p-user-id skip
                    "Псевдоним"                    buf_user-account.nik skip
                    "Имя пользователя"             buf_user-account.last-name buf_user-account.first-name buf_user-account.second-name skip
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
                message
                    "Редактирование логина невозможно" skip
                    "У пользователя нет логина" skip
                    "БД" p-db-num skip
                    "Идентификатор" buf_init_user-account.user-id skip
                view-as alert-box error .
            end.
            undo, return error return-value .
        end.
    end.
    define variable v-update-data        as logical   no-undo .
    define variable v-user-login         as character no-undo .
    define variable v-user-administrator as logical   no-undo .
    define variable v-max-discnt         as decimal   no-undo .
    define variable v-quest-print        as logical   no-undo .
    define variable v-tmp-dbnum          as integer   no-undo .
    v-tmp-dbnum = buf_user-login.db-num.
    run str/usrloged.w (
          input parparentproc
        , input 'ИЗМЕНЕНИЕ':U
        , input-output v-tmp-dbnum
        , input buf_user-login.user-id
        , input buf_user-login.user-login
        , input buf_user-login.user-administrator
        , input buf_user-login.max-discnt
        , input buf_user-login.quest-print
        , output v-update-data
        , output v-user-login
        , output v-user-administrator
        , output v-max-discnt
        , output v-quest-print
     ) .
    if v-tmp-dbnum = ? then
       return.
    assign
        buf_user-login.db-num = v-tmp-dbnum
        p-db-num = buf_user-login.db-num.
    if v-update-data = true
    then do:
            find first buf_user-login exclusive-lock
                 where buf_user-login.db-num  = p-db-num
                   and buf_user-login.user-id = p-user-id
            .
            assign
            buf_user-login.user-login         = v-user-login
            buf_user-login.user-administrator = v-user-administrator
            buf_user-login.max-discnt         = v-max-discnt
            buf_user-login.quest-print        = v-quest-print
            .
        end.
    end.
END PROCEDURE.
PROCEDURE procedure-user-login-menu-group :
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.
    define variable v-can-edit as logical   no-undo .
    define variable v-user-adm as logical   no-undo .
    define buffer buf_user-login    for ub.user-login .
    define buffer buf_user-account  for user-account.
do
for buf_user-login
on error undo, return error
:
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run user-adm in g#library2
  (input  p-db-num
  ,input  p-user-id
  ,output v-user-adm
  )  .
      if v-user-adm = yes
      then do:
         message "Пользователь - администратор. Ему доступны ВСЕ группы меню." skip
                 "Добавление новых никак не скажется на его работе. Продолжить?" skip
                 view-as alert-box
                 buttons yes-no
                 update v-yes as logical
                 .
         if v-yes = no
         then do:
            return.
         end.
      end.
      do transaction
      on error undo, return error return-value
      :
        find first buf_user-login exclusive-lock
             where buf_user-login.db-num  = p-db-num
               and buf_user-login.user-id = p-user-id
        no-error no-wait.
        if not available buf_user-login
        then do:
          if locked( buf_user-login )
          then do:
                find first buf_user-login no-lock
                     where buf_user-login.db-num  = p-db-num
                       and buf_user-login.user-id = p-user-id
                .
                find first buf_user-account no-lock
                     where buf_user-account.user-id = p-user-id
                .
                message
                "Редактирование логина невозможно" skip
                "Пользователь в данный момент работает в системе" skip
                "БД" p-db-num skip
                "Идентификатор"                p-user-id skip
                "Псевдоним"                    buf_user-account.nik skip
                "Имя пользователя"             buf_user-account.last-name buf_user-account.first-name buf_user-account.second-name skip
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
              "Редактирование логина невозможно" skip
              "У пользователя нет логина" skip
              "БД" p-db-num skip
              "Идентификатор" p-user-id skip
              view-as alert-box error .
          end.
          undo, return error return-value .
        end.
      end.
      run str/usrmngr.w (
          input parparentproc
        , input p-db-num
        , input p-user-id
        , input 0
      ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" 'str/usrmngr.w':U skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
end.
END PROCEDURE.
PROCEDURE procedure-user-login-user-host :
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.
  define variable v-current-host-code    as integer      no-undo.
  define variable v-user-select      as logical   no-undo .
  DEFINE VARIABLE v-List-select-host-code AS CHARACTER NO-UNDO INITIAL "".
do
on error undo, return error
:
    run gbl/userhsts.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  v-cntxt-host-code-obj
      ,input  IF v-only-lookup THEN "":U ELSE "b-add"
      ,output v-user-select
      ,output v-current-host-code
      ,OUTPUT v-List-Select-host-code
      ) .
end.
END PROCEDURE.
PROCEDURE procedure-user-login-user-obj :
define input parameter p-db-num         as integer          no-undo.
define input parameter p-user-id        as character        no-undo.
    define variable v-user-select        as logical   no-undo .
    define variable v-select-obj-type    as character no-undo .
    define variable v-select-obj-code    as integer   no-undo .
do
on error undo, return error
:
    run gbl/userobjs.w (
          input parparentproc
        , input this-procedure :handle
        , input p-db-num
        , input p-user-id
        , input v-cntxt-host-code-obj
        , input v-cntxt-obj-type
        , input v-cntxt-obj-code
        , input IF v-only-lookup THEN "":U ELSE "b-add":U
        , output v-user-select
        , output v-select-obj-type
        , output v-select-obj-code
      ).
end.
END PROCEDURE.
PROCEDURE save-position :
    define variable v-current-rowid    as rowid        no-undo.
    define variable v-current-focus    as integer      no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    if available buf_init_user-account
    then do:
        assign
            v-current-rowid = rowid( buf_init_user-account )
            v-current-focus = br-user :focused-row in frame Dialog-Frame
        .
        run uf-set (
              input 'users-1':U
            , input v-cntxt-userid
            , input string( rs-scope )
            , input string( cb-db )
            , input no
            , input no
            , input no
            , input no
        ) .
        run uf-set (
              input 'users-2':U
            , input v-cntxt-userid
            , input string( v-current-focus )
            , input string( v-current-rowid )
            , input no
            , input no
            , input no
            , input no
        ) .
    end.
end.
END PROCEDURE.
FUNCTION get-person-name RETURNS CHARACTER
  ( p-psn-code as integer ) :
  define variable v-person-name as character no-undo .
  run procedure-get-person-name in this-procedure (
      input p-psn-code
    , output v-person-name
  ) .
  return v-person-name .
END FUNCTION.
