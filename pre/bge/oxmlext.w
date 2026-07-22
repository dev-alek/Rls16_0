define input parameter parparentproc    as widget-handle  no-undo.
define input parameter bttns                as character      no-undo.
define input parameter p-list-mode          as character      no-undo.
define input parameter p-db-num-imp         as integer        no-undo.
define input parameter p-db-num-exp         as integer        no-undo.
define input parameter p-status             as character      no-undo.
define input parameter p-esys-type          as integer        no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список внешних подсистем OpenXML".
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
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure oxmlext-create :
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-current-db-num     as integer          no-undo.
define output parameter p-esys-id           as integer          no-undo.
    define variable v-today     as date         no-undo.
    define variable v-time      as integer      no-undo.
    define variable v-userid    as character    no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    run oxmlext-esys-id in this-procedure (
        output p-esys-id
    ).
    run get-userid in p-mainmenu-handle (
        output v-userid
    ).
    create buf_ext-system.
    assign
        buf_ext-system.esys-id                          = p-esys-id
        buf_ext-system.db-num                           = p-current-db-num
        buf_ext-system.esys-date-change                 = v-today
        buf_ext-system.esys-chk-ingr-imp                = no
        buf_ext-system.esys-chk-seq-imp                 = no
        buf_ext-system.esys-date-change-attr            = v-today
        buf_ext-system.esys-date-change-exp             = v-today
        buf_ext-system.esys-date-change-imp             = v-today
        buf_ext-system.esys-db-num-exp                  = p-current-db-num
        buf_ext-system.esys-db-num-imp                  = p-current-db-num
        buf_ext-system.esys-des                         = ""
        buf_ext-system.esys-file-chk-ing-imp            = "":U
        buf_ext-system.esys-have-export                 = no
        buf_ext-system.esys-have-import                 = no
        buf_ext-system.esys-have-proc-chk-ing-imp       = no
        buf_ext-system.esys-last-pack                   = 0
        buf_ext-system.esys-name                        = "<Новая внешняя система>"
        buf_ext-system.esys-num-days-keep-exp           = 0
        buf_ext-system.esys-num-days-keep-imp           = 0
        buf_ext-system.esys-proc-chk-ing-imp            = "":U
        buf_ext-system.esys-send-news-exp               = no
        buf_ext-system.esys-send-news-imp               = no
        buf_ext-system.esys-status                      = integer( '-1':U )
        buf_ext-system.esys-work-update                 = no
        buf_ext-system.esys-creid                       = v-userid
        buf_ext-system.esys-sys-date                    = v-today
        buf_ext-system.esys-sys-time-int                = v-time
        buf_ext-system.esys-sys-time                    = string( v-time, "HH:MM:SS" )
        buf_ext-system.esys-user-name                   = v-userid
        buf_ext-system.esys-user-db-num                 = p-current-db-num
    .
end.
end procedure.
procedure oxmlext-start-subsystem :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    if buf_ext-system.esys-status = 20
    then do:
        assign
            buf_ext-system.esys-status = 21
        .
    end.
    else do:
        assign
            buf_ext-system.esys-status = 1
        .
    end.
end.
end procedure.
procedure oxmlext-stop-subsystem :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    if buf_ext-system.esys-status = 21
    then do:
        assign
            buf_ext-system.esys-status = 20
        .
    end.
    else do:
        assign
            buf_ext-system.esys-status = 0
        .
    end.
end.
end procedure.
procedure oxmlext-stop-import :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
do
on error undo, return error
:
end.
end procedure.
procedure oxmlext-stop-export :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
do
on error undo, return error
:
end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
    define temp-table temp_select no-undo
        field sel-key   as integer
        field esys-id   as integer
        field db-num    as integer
        field selected  as logical
        index pi is primary unique
            sel-key
    .
    define variable v-oxmlext-selected-mark     as logical      no-undo.
    define variable v-oxmlext-status            as character    no-undo.
    define variable v-oxmlext-date              as character    no-undo.
define variable v-doc-rec as recid no-undo .
define variable v-last-list-mode            as character no-undo .
define variable v-last-esys-type            as integer   no-undo .
define variable func as character no-undo .
define buffer buf_init_ext-system for ext-system.
FUNCTION get-selected-mark returns logical
  ( p-esys-id as integer, p-db-num as integer )  FORWARD.
DEFINE MENU MENU-B-func
       MENU-ITEM m_exp-kontur  LABEL "Экспорт информации о структуре"     .
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-func
     LABEL "&Функции"
     SIZE 10 BY 1.
DEFINE BUTTON b-sel
     LABEL "*"
     SIZE 3 BY 1.
DEFINE BUTTON b-select
     LABEL "В&ыбор"
     SIZE 10 BY 1.
DEFINE BUTTON bt-export
     LABEL "&Экспорт"
     SIZE 10 BY 1.
DEFINE BUTTON bt-on-off
     LABEL "&Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE filt-combo AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Тип ВС"
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "Item 1",0
     DROP-DOWN-LIST
     SIZE 21 BY 1 NO-UNDO.
DEFINE VARIABLE ed-desc AS CHARACTER
     VIEW-AS EDITOR
     SIZE 98 BY 2.19 NO-UNDO.
DEFINE VARIABLE filt-1 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 19 BY .95 NO-UNDO.
DEFINE VARIABLE filt-radio AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Код", 1,
"Название", 2,
"БД импорта", 3,
"БД экспорта", 4
     SIZE 42 BY .95 NO-UNDO.
DEFINE QUERY br-table FOR
      buf_init_ext-system SCROLLING.
DEFINE BROWSE br-table
  QUERY br-table NO-LOCK DISPLAY
      get-selected-mark ( buf_init_ext-system.esys-id, buf_init_ext-system.db-num ) @ v-oxmlext-selected-mark   format " */  " column-label " * "
      buf_init_ext-system.esys-id
      ( if buf_init_ext-system.esys-status = -1
        then substitute( "новая&1", ( if buf_init_ext-system.esys-type > integer('0':U) then " (сп)" else "" ) )
        else ( if buf_init_ext-system.esys-status = 1
               then substitute( "в работе&1", ( if buf_init_ext-system.esys-type > integer('0':U) then " (сп)" else "" ) )
               else substitute( "останов&1", ( if buf_init_ext-system.esys-type > integer('0':U) then " (сп)" else "" ) ) ) ) @ v-oxmlext-status                                                            FORMAT "X(15)"  column-label " Статус "
      substring( string( buf_init_ext-system.esys-date-change, "99/99/9999" ), 1, 10 ) @ v-oxmlext-date  FORMAT "X(10)"   COLUMN-LABEL "Дата"
      buf_init_ext-system.esys-have-export                                                                      format " +/ -"  column-label "Экс"
      buf_init_ext-system.esys-db-num-exp                                                                       format ">>>>9 " column-label "БДэкс"
      buf_init_ext-system.esys-have-import                                                                      format " +/ -"  column-label "Имп"
      buf_init_ext-system.esys-db-num-imp                                                                       format ">>>>9 " column-label "БДимп"
      buf_init_ext-system.esys-name
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.24.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     b-select AT ROW 1 COL 14
     b-help AT ROW 1 COL 95
     filt-radio AT ROW 2.19 COL 2 NO-LABEL
     filt-1 AT ROW 2.19 COL 43 COLON-ALIGNED NO-LABEL
     filt-combo AT ROW 2.19 COL 75 COLON-ALIGNED
     b-add AT ROW 3.62 COL 1
     b-lkp AT ROW 3.62 COL 11
     b-chg AT ROW 3.62 COL 21
     b-del AT ROW 3.62 COL 31
     b-func AT ROW 3.62 COL 41
     bt-on-off AT ROW 3.62 COL 41
     bt-export AT ROW 3.62 COL 51
     br-table AT ROW 4.81 COL 1
     ed-desc AT ROW 21.19 COL 1 NO-LABEL
     SPACE(0.59) SKIP(0.13)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список внешних подсистем OpenXML".
ASSIGN
       B-func:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-func:HANDLE.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ed-desc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
    define variable v-have-rights    as logical        no-undo.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_openxml-subsystem_add-def':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  yes
    ,output v-have-rights
    )  .
end.
    if v-have-rights = yes
    then do:
      if v-cntxt-db-num = 0 then do:
        if not (p-list-mode = "esys-type"
                or
                p-list-mode = "special")
        then do:
        define variable choice as integer no-undo .
        run gbl/d-askw.w (input "Добавление типа ВНЕШНЕЙ СИСТЕМЫ",
                          input  "Выбор типа ВНЕШНЕЙ СИСТЕМЫ",
                          input "|",
                          input "Внешняя система|Специальная|Отменить",
                          input "||",
                          input 1,
                          input 3,
                          output choice).
        if choice = 3
        then do:
            return no-apply.
        end.
      end.
      else do:
          if p-esys-type = integer('0':U) then choice = 1.
          if p-esys-type > integer('0':U) then choice = 2.
      end.
      end.
      else do:
        message
        "На текущий момент в УБД ВС добавлять запрещено"
        view-as alert-box error .
        return no-apply.
      end.
      run add-doc in this-procedure ( input integer((if choice = 1
                                                     then '0':U
                                                     else '1':U))).
      run openbr in this-procedure .
      apply "value-changed" to br-table.
      apply "entry" to br-table.
  end.
END.
ON CHOOSE OF MENU-ITEM m_exp-kontur
DO:
  assign
  func = "exp-kontur"
  .
  APPLY "CHOOSE" TO b-func IN FRAME Dialog-Frame.
END.
ON CHOOSE OF b-func IN FRAME Dialog-Frame
DO:
  if not available buf_init_ext-system THEN return no-apply.
  if func = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if func = "":U then do:
      return no-apply.
  end.
  if func = "exp-kontur" then do :
      if buf_init_ext-system.whole-send-news <> integer('9':U) then do :
          message "Данная функция доступна только для ВС с методом доставки " 'Контур.EDI':U view-as alert-box .
      end.
      else do :
          run waitfram-show in this-procedure ( input "Ждите... Идет экспорт информации в систему EDI" ).
          run cus/exp-clients_kontur.p (input parparentproc
                                       ,buffer buf_init_ext-system
                                       ) .
          run waitfram-hide in this-procedure .
          message "Экспорт завершен" view-as alert-box .
      end.
  end.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
define variable v-have-rights    as logical        no-undo.
define variable v-focused-row       as integer  no-undo.
define variable v-repositioned-row  as integer  no-undo.
  assign
  v-focused-row      = br-table :focused-row in frame Dialog-Frame.
  v-repositioned-row = current-result-row( "br-table" )
  .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_openxml-subsystem_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  yes
    ,output v-have-rights
    )  .
end.
  if v-have-rights = no
  then do:
      undo, return no-apply.
  end.
  if v-have-rights = yes
  and available buf_init_ext-system
  then do:
      run change-doc in this-procedure (
            input buf_init_ext-system.esys-id
          , input buf_init_ext-system.db-num
      ) no-error.
      if error-status :error
      then do:
          message
                    vss-workfile vss-revision vss-description
              skip "Ошибка изменения параметров внешней подсистемы."
              skip return-value
              skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return no-apply .
      end.
      apply "entry" to br-table.
      apply "value-changed" to br-table.
  end.
  run openbr in this-procedure .
  apply "value-changed" to br-table.
  apply "entry" to br-table.
  br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dialog-Frame.
  reposition br-table to row v-repositioned-row no-error.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-can-delete        as logical  no-undo.
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_openxml-subsystem_deletion':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  yes
    ,output v-can-delete
    )  .
end.
    if v-can-delete = no
    then do:
        undo, return no-apply.
    end.
    if v-can-delete = yes
    and available buf_init_ext-system
    then do:
        if buf_init_ext-system.esys-status <> 0
        and buf_init_ext-system.esys-type = integer('0':U)
        then do:
            message
                     "Для удаления внешней подсистемы"
                skip "надо сначала её остановить."
            view-as alert-box error.
            undo, return no-apply.
        end.
        assign
            v-focused-row      = br-table :focused-row in frame Dialog-Frame.
            v-repositioned-row = current-result-row( "br-table" )
        .
        run delete-doc in this-procedure (
              input buf_init_ext-system.esys-id
            , input buf_init_ext-system.db-num
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка удаления информации о внешней подсистеме."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply.
        end.
        else do:
        end.
        run openbr in this-procedure .
        apply "value-changed" to br-table.
        apply "entry" to br-table.
        if v-focused-row > 1
        then do:
            br-table :set-repositioned-row( v-focused-row - 1, "ALWAYS" ) in frame Dialog-Frame .
            reposition br-table to row v-repositioned-row.
        end.
    end.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    apply "WINDOW-CLOSE" TO FRAME Dialog-Frame .
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
or mouse-select-dblclick of br-table in frame dialog-frame
DO:
    define variable v-have-rights    as logical        no-undo.
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_openxml-subsystem_lookup':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  yes
    ,output v-have-rights
    )  .
end.
    if v-have-rights = yes
    and available buf_init_ext-system
    then do:
        run view-doc in this-procedure (
              input buf_init_ext-system.esys-id
            , input buf_init_ext-system.db-num
        ).
    end.
END.
ON ROW-DISPLAY OF br-table IN FRAME Dialog-Frame
DO:
    if available buf_init_ext-system
    then do:
       if not ((p-list-mode = "esys-type"
               and buf_init_ext-system.esys-type > integer('0':U)
               )
               or
               p-list-mode = "special")
        then do:
            assign
                v-oxmlext-selected-mark                 :bgcolor in browse br-table = gray_color
                buf_init_ext-system.esys-id             :bgcolor in browse br-table = gray_color
                v-oxmlext-status                        :bgcolor in browse br-table = gray_color
                v-oxmlext-date                          :bgcolor in browse br-table = gray_color
                buf_init_ext-system.esys-have-export    :bgcolor in browse br-table = gray_color
                buf_init_ext-system.esys-db-num-exp     :bgcolor in browse br-table = gray_color
                buf_init_ext-system.esys-have-import    :bgcolor in browse br-table = gray_color
                buf_init_ext-system.esys-db-num-imp     :bgcolor in browse br-table = gray_color
                buf_init_ext-system.esys-name           :bgcolor in browse br-table = gray_color
            .
        end.
    end.
END.
ON VALUE-CHANGED OF br-table IN FRAME Dialog-Frame
DO:
    run manage-ed-desc in this-procedure.
    if available buf_init_ext-system
    then do:
       case buf_init_ext-system.esys-status
        :
            when 0
            then do:
                assign
                    bt-on-off :label = "&Пуск"
                .
            end.
            otherwise do:
                assign
                    bt-on-off :label = "&Стоп"
                .
            end.
        end case.
        if buf_init_ext-system.esys-have-export = yes
        and buf_init_ext-system.esys-type = integer('0':U)  then do:
            enable
                bt-export
            with frame Dialog-Frame.
        end.
        else do:
            disable
                bt-export
            with frame Dialog-Frame.
        end.
    end.
END.
ON CHOOSE OF bt-export IN FRAME Dialog-Frame
DO:
    if available buf_init_ext-system
    then do:
        if buf_init_ext-system.esys-type > integer('0':U)  then do:
        message
        "Нелья экспортировать данные по ВС с типом СПЕЦИАЛЬНАЯ"
        view-as alert-box .
        return no-apply.
      end.
        run start-export in this-procedure (
              input buf_init_ext-system.esys-id
            , input buf_init_ext-system.db-num
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка экспорта по выбранной внешней подсистеме."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.
ON CHOOSE OF bt-on-off IN FRAME Dialog-Frame
DO:
    define variable v-have-rights    as logical        no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_openxml-subsystem_on-off':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  yes
    ,output v-have-rights
    )  .
end.
    if v-have-rights = yes
    and available buf_init_ext-system
    then do:
        assign
            v-focused-row      = br-table :focused-row in frame Dialog-Frame.
            v-repositioned-row = current-result-row( "br-table" )
        .
        run on-off-doc in this-procedure (
              input buf_init_ext-system.esys-id
            , input buf_init_ext-system.db-num
        ).
        run openbr in this-procedure .
        apply "value-changed" to br-table.
        apply "entry" to br-table.
        br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dialog-Frame.
        reposition br-table to row v-repositioned-row no-error.
    end.
END.
ON return OF filt-1 IN FRAME Dialog-Frame
DO:
    if filt-radio = 1 or filt-radio = 3 or filt-radio = 4 then do:
        int(filt-1:screen-value) no-error.
        if error-status:error then do:
            assign filt-1:screen-value = '' .
            return no-apply.
        end.
    end.
    assign filt-1 .
    run openbr in this-procedure .
    apply "value-changed" to br-table.
    apply "entry" to br-table.
END.
ON VALUE-CHANGED OF filt-combo IN FRAME Dialog-Frame
DO:
    if filt-combo = 0 then do:
        assign
        v-last-list-mode = p-list-mode
        v-last-esys-type = p-esys-type
        p-list-mode      = "esys-type"
        .
    end.
    assign filt-combo .
    if filt-combo > 0 then assign p-esys-type = filt-combo .
    else do:
        assign
        p-esys-type = v-last-esys-type
        p-list-mode = v-last-list-mode
        .
    end.
    run openbr in this-procedure .
    apply "value-changed" to br-table.
    apply "entry" to br-table.
END.
ON VALUE-CHANGED OF filt-radio IN FRAME Dialog-Frame
DO:
  assign filt-radio .
  run openbr in this-procedure .
  apply "value-changed" to br-table.
  apply "entry" to br-table.
END.
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-table :handle
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-doc-rec = (if available buf_init_ext-system then recid(buf_init_ext-system) else ? ). run Openbr in this-procedure .                   reposition br-table to recid v-doc-rec no-error. APPLY 'entry' to br-table.
    apply "VALUE-CHANGED" to br-table.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    IF LOOKUP(p-list-mode, 'все':U + chr(44) + "esys-type" + chr(44) + "special") = 0 THEN DO:
       MESSAGE
       SUBSTITUTE("Неверное значение параметра p-list-mode= &1", p-list-mode)
       VIEW-AS ALERT-BOX ERROR.
       UNDO, RETURN ERROR.
    END.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN MyEnable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE add-doc :
define input parameter p-esys-type as integer no-undo .
    define variable v-esys-id    as integer      no-undo.
    define variable v-success    as logical      no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    do transaction
    on error undo, return error
    :
       case p-esys-type:
         when integer('0':U) then do:
            run oxmlext-create in this-procedure (
                  input parparentproc
                , input v-cntxt-db-num
                , output v-esys-id
            ).
            run bge/oxmlextd.w (
                  input parparentproc
                , input this-procedure
                , input 'ДОБАВЛЕНИЕ':U
                , input v-esys-id
                , input v-cntxt-db-num
                , input v-cntxt-db-num
                , output v-success
            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка создания записи внешней подсистемы."
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
            find first buf_ext-system exclusive-lock
                where buf_ext-system.esys-id = v-esys-id
                  and buf_ext-system.db-num  = v-cntxt-db-num
            no-error.
            if available buf_ext-system
            then do:
                if v-success = no
                then do:
                    delete buf_ext-system.
                end.
                else do:
  find first ub.batchprocess no-lock
    where ub.batchprocess.bp_type   = 'oxmlnew':U
      and ub.batchprocess.bp_status = 'N':U
      and  ub.batchprocess.key#_one  = buf_ext-system.esys-id
      and ub.batchprocess.key#_two = buf_ext-system.db-num
  no-error .
  if not available ub.BatchProcess then do:
    create ub.BatchProcess .
        define variable v-btpr_upd-today-19 as date      no-undo.
    define variable v-btpr_upd-time-19  as integer   no-undo.
    run cur-time in this-procedure ( output v-btpr_upd-today-19
                                   , output v-btpr_upd-time-19
                                   ).
    assign
      ub.BatchProcess.BP_Type       = 'oxmlnew':U
      ub.BatchProcess.BP_Status     = 'N':U
      ub.BatchProcess.BatchProcess# = next-value( s-btpr, ub )
      ub.BatchProcess.User_ID       = v-cntxt-userid
      ub.BatchProcess.BP_SysDate    = v-btpr_upd-today-19
      ub.BatchProcess.BP_SysTime    = string( v-btpr_upd-time-19, 'HH:MM' )
      ub.BatchProcess.BP_SysTimeInt = v-btpr_upd-time-19
    .
    assign
      ub.BatchProcess.Key#_One      = buf_ext-system.esys-id
      ub.BatchProcess.Key#_Two      = buf_ext-system.db-num
    .
  end.
                end.
            end.
            else do:
                if v-success = yes
                then do:
                    message
                            vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка (2) создания записи внешней подсистемы."
                        skip return-value
                        skip trim(error-status :get-message(1))
                            trim(error-status :get-message(2))
                            trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
          end.
          when integer('1':U) then do:
           run bge/oxmlspci.w (
                              input parparentproc
                            , input 'ДОБАВЛЕНИЕ':U
                            , input-output v-esys-id
                            , input 0
                            , output v-success
                            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка создания записи внешней подсистемы."
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
          end.
        end case.
    end.
end.
END PROCEDURE.
PROCEDURE change-doc :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    if available buf_init_ext-system
    then do:
      case buf_init_ext-system.esys-type :
       when integer('0':U) then do:
        run bge/oxmlextd.w (
              input parparentproc
            , input this-procedure
            , input 'ИЗМЕНЕНИЕ':U
            , input p-esys-id
            , input p-db-num
            , input v-cntxt-db-num
            , output v-success
        ) no-error.
       end.
       otherwise do:
        run bge/oxmlspci.w (
              input parparentproc
            , input 'ИЗМЕНЕНИЕ':U
            , input-output p-esys-id
            , input p-db-num
            , output v-success
        ) no-error.
       end.
      end case.
      if error-status :error
      then do:
          message
                  vss-workfile vss-revision vss-description
              skip(1)
              skip "Ошибка изменения записи внешней подсистемы."
              skip return-value
              skip trim(error-status :get-message(1))
                  trim(error-status :get-message(2))
                  trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return error .
      end.
    end.
end.
END PROCEDURE.
PROCEDURE clear-mark :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define buffer buf_temp_select       for temp_select.
do
for buf_temp_select
on error undo, return error
:
    find first buf_temp_select
         where buf_temp_select.esys-id = p-esys-id
           and buf_temp_select.db-num  = p-db-num
    no-error.
    if available buf_temp_select
    then do:
        assign
            buf_temp_select.selected = no
        .
    end.
end.
END PROCEDURE.
PROCEDURE delete-doc :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define variable v-yesno    as logical        no-undo.
    define buffer buf_ext-system       for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    no-error.
    if available buf_ext-system
    then do:
        assign
            v-yesno = no
        .
        message
                 "Удаление подсистемы."
            skip (1)
            skip "Внешняя подсистема:"
            skip "  номер   " buf_ext-system.esys-id
            skip "  БД номер" buf_ext-system.db-num
            skip "  имя     " buf_ext-system.esys-name
            skip (1)
            skip "Удалить внешнюю подсистему?"
        view-as alert-box information
        buttons yes-no
        title "Удаление подсистемы"
        update v-yesno.
        if v-yesno = yes
        then do:
           if buf_ext-system.esys-type > integer('0':U) then do:
             run bge/extsyss3.p ( input no
                                 ,input recid(buf_ext-system)) no-error.
             if error-status :error then do:
               undo, return error ''.
             end.
           end.
           else do:
              define buffer buf_BatchProcess      for ub.BatchProcess.
  find first buf_BatchProcess exclusive-lock
    where buf_BatchProcess.bp_type   = 'oxmlnew':U
      and buf_BatchProcess.bp_status = 'N':U
      and  buf_BatchProcess.key#_one  = buf_ext-system.esys-id
      and buf_BatchProcess.key#_two = buf_ext-system.db-num
  no-error .
              if available buf_BatchProcess
              then do:
                  delete buf_BatchProcess.
              end.
              delete buf_ext-system.
           end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY filt-radio filt-1 filt-combo ed-desc
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help filt-radio filt-1 filt-combo b-add b-lkp b-chg b-del
         bt-on-off bt-export br-table ed-desc
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE get-mark :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
define output parameter p-mark      as logical          no-undo.
    define buffer buf_temp_select       for temp_select.
do
for buf_temp_select
on error undo, return error
:
    find first buf_temp_select
         where buf_temp_select.esys-id = p-esys-id
           and buf_temp_select.db-num  = p-db-num
    no-error.
    if available buf_temp_select
    then do:
        assign
            p-mark = buf_temp_select.selected
        .
    end.
    else do:
        assign
            p-mark = no
        .
    end.
end.
END PROCEDURE.
PROCEDURE manage-ed-desc :
do
with frame Dialog-Frame
on error undo, return error
:
    if available buf_init_ext-system
    then do:
        assign
            ed-desc :screen-value = buf_init_ext-system.esys-des
        .
    end.
end.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS integer NO-UNDO.
DISPLAY ed-desc
WITH FRAME Dialog-Frame.
do v-ii = 1 to num-entries('1,2,3,4,5,6,7,8,9,10,11,12':U):
    assign
  filt-combo:list-item-pairs in frame Dialog-Frame =
  (if v-ii = 1
  then (chr(44) + "0"  + chr(44) +  entry (lookup (string(v-ii), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)  + chr(44) +  entry(v-ii, '1,2,3,4,5,6,7,8,9,10,11,12':U))
  else (filt-combo:list-item-pairs + chr(44) +
         entry (lookup (string(v-ii), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)  + chr(44) +  entry(v-ii, '1,2,3,4,5,6,7,8,9,10,11,12':U))
  )
  .
end.
b-func:MENU-MOUSE IN frame Dialog-Frame = 1 .
ENABLE
b-exit
b-help
b-add WHEN (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0 and not transaction)
b-lkp
b-func
b-chg WHEN (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0 and not transaction)
b-del WHEN (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0 and not transaction)
bt-on-off when (lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0 and not transaction)
bt-export  when  not transaction
br-table
filt-radio
ed-desc
filt-1
filt-combo
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if p-list-mode = "esys-type" then do:
   DISABLE
   filt-combo
   WITH FRAME Dialog-Frame.
   HIDE
   filt-combo
   in FRAME Dialog-Frame.
end.
IF (p-list-mode = "esys-type"
AND p-esys-type > integer('0':U))
or p-list-mode = "special"
THEN DO:
   DISABLE
   bt-on-off
   bt-export
   WITH FRAME Dialog-Frame.
   HIDE
   bt-on-off
   bt-export
   in FRAME Dialog-Frame.
END.
assign filt-radio .
run openbr in this-procedure .
apply "value-changed" to br-table.
apply "entry" to br-table.
END PROCEDURE.
PROCEDURE on-off-doc :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define variable v-yesno    as logical      no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
on error undo, return error
:
    find first buf_ext-system no-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    if buf_ext-system.esys-status = 0
    then do:
        message
                    "Запуск подсистемы."
            skip (1)
            skip "Внешняя подсистема:"
            skip "  номер   " buf_ext-system.esys-id
            skip "  БД номер" buf_ext-system.db-num
            skip "  имя     " buf_ext-system.esys-name
            skip (1)
            skip "Запустить внешнюю подсистему?"
        view-as alert-box information
        buttons yes-no
        title "Запуск подсистемы"
        update v-yesno.
        if v-yesno = yes
        then do:
            run oxmlext-start-subsystem in this-procedure (
                  input p-esys-id
                , input p-db-num
            ).
        end.
    end.
    else do:
        message
                 "Остановка подсистемы."
            skip (1)
            skip "Внешняя подсистема:"
            skip "  номер   " buf_ext-system.esys-id
            skip "  БД номер" buf_ext-system.db-num
            skip "  имя     " buf_ext-system.esys-name
            skip (1)
            skip "Остановить внешнюю подсистему?"
        view-as alert-box information
        buttons yes-no
        title "Остановка подсистемы"
        update v-yesno.
        if v-yesno = yes
        then do:
            run oxmlext-stop-subsystem in this-procedure (
                  input p-esys-id
                , input p-db-num
            ).
        end.
    end.
end.
END PROCEDURE.
PROCEDURE Openbr :
CASE p-list-mode:
  WHEN 'все':U THEN DO:
      if v-cntxt-db-num = 0
      then do:
          open query br-table
          for each buf_init_ext-system no-lock
         where
(if not filt-1 = '' then
     if filt-radio = 1 then buf_init_ext-system.esys-id = int(filt-1)
     else if filt-radio = 2 then buf_init_ext-system.esys-name begins filt-1
     else if filt-radio = 3 then buf_init_ext-system.esys-db-num-imp = int(filt-1)
     else if filt-radio = 4 then buf_init_ext-system.esys-db-num-exp = int(filt-1)
     else true
 else true)
          by buf_init_ext-system.esys-date-change descending
          .
      end.
      else do:
          open query br-table
          for each buf_init_ext-system no-lock
          where (buf_init_ext-system.esys-db-num-imp = v-cntxt-db-num
              or buf_init_ext-system.esys-db-num-exp = v-cntxt-db-num
              or buf_init_ext-system.esys-type = integer('10':U) )
            and
(if not filt-1 = '' then
     if filt-radio = 1 then buf_init_ext-system.esys-id = int(filt-1)
     else if filt-radio = 2 then buf_init_ext-system.esys-name begins filt-1
     else if filt-radio = 3 then buf_init_ext-system.esys-db-num-imp = int(filt-1)
     else if filt-radio = 4 then buf_init_ext-system.esys-db-num-exp = int(filt-1)
     else true
 else true)
          by buf_init_ext-system.esys-date-change descending
          .
      end.
  END.
  WHEN "esys-type" THEN DO:
      if v-cntxt-db-num = 0
      then do:
          open query br-table
          for each buf_init_ext-system no-lock
              WHERE buf_init_ext-system.esys-type = p-esys-type
            and
(if not filt-1 = '' then
     if filt-radio = 1 then buf_init_ext-system.esys-id = int(filt-1)
     else if filt-radio = 2 then buf_init_ext-system.esys-name begins filt-1
     else if filt-radio = 3 then buf_init_ext-system.esys-db-num-imp = int(filt-1)
     else if filt-radio = 4 then buf_init_ext-system.esys-db-num-exp = int(filt-1)
     else true
 else true)
          by buf_init_ext-system.esys-date-change descending
          .
      end.
      else do:
          open query br-table
          for each buf_init_ext-system no-lock
             WHERE buf_init_ext-system.esys-type = p-esys-type
          AND (buf_init_ext-system.esys-db-num-imp = v-cntxt-db-num
                or buf_init_ext-system.esys-db-num-exp = v-cntxt-db-num
                or buf_init_ext-system.esys-type = integer('10':U) )
          and
(if not filt-1 = '' then
     if filt-radio = 1 then buf_init_ext-system.esys-id = int(filt-1)
     else if filt-radio = 2 then buf_init_ext-system.esys-name begins filt-1
     else if filt-radio = 3 then buf_init_ext-system.esys-db-num-imp = int(filt-1)
     else if filt-radio = 4 then buf_init_ext-system.esys-db-num-exp = int(filt-1)
     else true
 else true)
          by buf_init_ext-system.esys-date-change descending
          .
      end.
        assign
    frame Dialog-Frame:title = substitute("Список внешних подсистем с типом &1", entry (lookup (string(p-esys-type), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)).
  END.
  WHEN "special" THEN DO:
    if v-cntxt-db-num = 0
    then do:
          open query br-table
          for each buf_init_ext-system no-lock
              WHERE buf_init_ext-system.esys-type > integer('0':U)
                and
(if not filt-1 = '' then
     if filt-radio = 1 then buf_init_ext-system.esys-id = int(filt-1)
     else if filt-radio = 2 then buf_init_ext-system.esys-name begins filt-1
     else if filt-radio = 3 then buf_init_ext-system.esys-db-num-imp = int(filt-1)
     else if filt-radio = 4 then buf_init_ext-system.esys-db-num-exp = int(filt-1)
     else true
 else true)
          by buf_init_ext-system.esys-date-change descending
          .
    end.
    else do:
        open query br-table
        for each buf_init_ext-system no-lock
          WHERE buf_init_ext-system.esys-type > integer('0':U)
            AND (buf_init_ext-system.esys-db-num-imp = v-cntxt-db-num
              or buf_init_ext-system.esys-db-num-exp = v-cntxt-db-num
              or buf_init_ext-system.esys-type = integer('10':U)
              or buf_init_ext-system.esys-type = integer('11':U)
              or buf_init_ext-system.esys-type = integer('1':U))
            and
(if not filt-1 = '' then
     if filt-radio = 1 then buf_init_ext-system.esys-id = int(filt-1)
     else if filt-radio = 2 then buf_init_ext-system.esys-name begins filt-1
     else if filt-radio = 3 then buf_init_ext-system.esys-db-num-imp = int(filt-1)
     else if filt-radio = 4 then buf_init_ext-system.esys-db-num-exp = int(filt-1)
     else true
 else true)
        by buf_init_ext-system.esys-date-change descending
        .
    end.
    assign
    frame Dialog-Frame:title = substitute("Список СПЕЦИАЛЬНЫХ внешних подсистем").
  END.
END CASE.
 END PROCEDURE.
PROCEDURE reposition-to-recid :
define input parameter p-ext-system-recid  as recid        no-undo.
do
on error undo, return error
:
    if p-ext-system-recid <> ?
    then do:
        reposition br-table to recid p-ext-system-recid no-error .
    end.
    do with frame Dialog-Frame
    :
        apply "entry":u to browse br-table .
    end.
end.
END PROCEDURE.
PROCEDURE set-mark :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define buffer buf_temp_select       for temp_select.
do
for buf_temp_select
on error undo, return error
:
    find first buf_temp_select
         where buf_temp_select.esys-id = p-esys-id
           and buf_temp_select.db-num  = p-db-num
    no-error.
    if available buf_temp_select
    then do:
        assign
            buf_temp_select.selected = yes
        .
    end.
end.
END PROCEDURE.
PROCEDURE start-export :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define variable v-cur-db-num    as integer      no-undo.
do
on error undo, return error
:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-cur-db-num
  )  .
    run str/diallog.w (
          input parparentproc
        , input this-procedure
        , input "bge/oxmlouta.p":U
        , input substitute( "&1,&2,&3", v-cur-db-num, p-esys-id, p-db-num )
        , input no
        , input "&Стоп"
        , input "Начальная выгрузка по внешней системе Open XML"
    ).
end.
END PROCEDURE.
PROCEDURE view-doc :
define input parameter p-esys-id    as character    no-undo.
define input parameter p-db-num     as integer          no-undo.
    define variable v-success    as logical      no-undo.
do
on error undo, return error
:
    if available buf_init_ext-system
    then do:
      case buf_init_ext-system.esys-type :
        when integer('0':U) then do:
          run bge/oxmlextd.w (
                input parparentproc
              , input this-procedure
              , input 'ПРОСМОТР':U
              , input p-esys-id
              , input p-db-num
              , input v-cntxt-db-num
              , output v-success
          ) no-error.
        end.
        otherwise do:
          run bge/oxmlspci.w (
                input parparentproc
              , input 'ПРОСМОТР':U
              , input-output p-esys-id
              , input p-db-num
              , output v-success
          ) no-error.
        end.
      end case.
      if error-status :error
      then do:
          message
                  vss-workfile vss-revision vss-description
              skip(1)
              skip "Ошибка просмотра записи внешней подсистемы."
              skip return-value
              skip trim(error-status :get-message(1))
                  trim(error-status :get-message(2))
                  trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return error .
      end.
    end.
end.
END PROCEDURE.
FUNCTION get-selected-mark returns logical
  ( p-esys-id as integer, p-db-num as integer ) :
    define variable v-mark  as logical    no-undo.
    run get-mark in this-procedure (
          input p-esys-id
        , input p-db-num
        , output v-mark  ).
    return v-mark.
end function.
