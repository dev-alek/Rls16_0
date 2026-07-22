define input parameter parparentproc as widget-handle no-undo .
define input parameter p-list-mode as character no-undo .
define input parameter p-gds-rec   as recid no-undo .
define input parameter p-rep-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Показ товаров по контрагентам " .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
DEFINE BUFFER buf-cli for ub.clients.
DEFINE BUFFER buf-goods for ub.goods.
DEFINE new shared BUFFER sb-cli-gds FOR ub.cli-gds.
define buffer buf-ext-artic for ub.ext-artic.
DEFINE VAR last-curr-code like ub.currency.curr-abbr no-undo.
DEFINE VAR cli-name like ub.clients.obj-name no-undo.
DEFINE VAR gds-name like ub.goods.gds-name no-undo.
DEFINE VAR unit-base like ub.goods.unit-base no-undo.
define variable sym1   as char format "X(1)" init ":".
define variable sym10 as char format "X(1)" init ":".
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable producer as char.
define variable accum-count as integer.
define variable accum-in-qnty as decimal.
define variable accum-out-qnty as decimal.
define variable accum-ret-qnty  as decimal.
define variable accum-in-base  as decimal.
define variable accum-in-rubl  as decimal.
define variable accum-out-sum  as decimal.
define variable accum-ret-sum  as decimal.
define variable accum-out-discnt  as decimal.
define variable accum-ret-discnt  as decimal.
define variable accum-supp-qnty  as decimal.
define variable accum-supp-base  as decimal.
define variable accum-supp-rubl  as decimal.
define variable filter-point as character no-undo init "cli-gdss" .
define variable filter-point0 as character no-undo init "cli-gdss" .
define variable filter-label as character no-undo init "Товары_контрагентов" .
define variable filter-label0 as character no-undo init "Товары_контрагентов" .
define variable sort-column-name as character no-undo .
define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .
DEFINE FRAME CLi-Gds-List
sym1 COLUMn-LABEL ""
sb-cli-gds.artic COLUMN-LABEL "Артикул!произ-ля!(сортируется)"
gds-name FORMAT "X(20)"
unit-base
producer FORMAT "x(9)"
ub.clients.obj-name
cli-name COLUMN-LABEL "Контрагент" FORMAT "X(20)"
sb-cli-gds.cli-art COLUMN-LABEL "Артикул!контрагента"
sb-cli-gds.unit-cli COLUMN-LABEL "Ед.изм.!контр-!агента"
sb-cli-gds.in-qnty COLUMN-LABEL "Кол-во/приход"
sb-cli-gds.out-qnty COLUMN-LABEL "Кол-во/расход"
sb-cli-gds.ret-qnty COLUMN-LABEL "Кол-во/возврат"
sb-cli-gds.in-base COLUMN-LABEL  "Учетн.цены!баз.вал./!приход"
sb-cli-gds.in-rubl COLUMN-LABEL  "Учетн.цены!руб./!приход"
sb-cli-gds.out-sum COLUMN-LABEL  "Продаж.цены!вал.продаж/!расход"
sb-cli-gds.ret-sum COLUMN-LABEL  "Продаж.цены!вал.продаж/!возврат"
sb-cli-gds.out-discnt COLUMN-LABEL "Скидки!вал.продаж/!расход"
sb-cli-gds.ret-discnt COLUMN-LABEL "Скидки!вал.продаж/!возврат"
sb-cli-gds.in-code COLUmn-LABEL "Последн. ПН"
last-curr-code COLUmn-LABEL "Валюта!посл.ПН"
sb-cli-gds.price-cli COLUmn-LABEL "Последн.цена!контр-агента"
sb-cli-gds.supp-qnty COLUMN-LABEL "Кол-во/остатки"
sb-cli-gds.supp-base COLUMN-LABEL "Учетн.цены!баз.вал./!остатки"
sb-cli-gds.supp-rubl COLUMN-LABEL "Учетн.цены!руб./!остатки"
sym10 COLUMn-LABEL ""
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER AT 125 FORMAT ">>9" SKIP
Line format "X(177)" AT 1
with width 232 down stream-io use-text    .
FUNCTION get-ext-artic RETURNS CHARACTER
    (buffer loc-cli-gds for sb-cli-gds) FORWARD.
FUNCTION get-cli-name RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds )  FORWARD.
FUNCTION get-gds-name RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds )  FORWARD.
FUNCTION Get-last-curr-code RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds )  FORWARD.
FUNCTION get-unit-base RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds )  FORWARD.
DEFINE BUTTON B-cliartic
     LABEL "&Внешний артикул"
     SIZE 17.13 BY 1.13.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON b-good
     LABEL "&Товар"
     SIZE 10 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 2.75 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 2.38 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON b-producer
     LABEL "Произв-ль"
     SIZE 10 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3.13 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON b-supplier
     LABEL "&Контрагент"
     SIZE 12.13 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON b-totals
     LABEL "&Итоги"
     SIZE 10 BY 1.13
     BGCOLOR 8 .
DEFINE VARIABLE F-IN-QNTY AS DECIMAL FORMAT "->>,>>>,>>9.999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-IN-SUM-BASE AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-IN-SUM-RUBL AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-LEFT-QNTY AS DECIMAL FORMAT "->>,>>>,>>9.999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-LEFT-SUM-BASE AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-LEFT-SUM-RUBL AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-OUT-DISCNT-BASE AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-OUT-QNTY AS DECIMAL FORMAT "->>,>>>,>>9.999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-OUT-SUM-BASE AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-RET-DISCNT-BASE AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-RET-QNTY AS DECIMAL FORMAT "->>,>>>,>>9.999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-RET-SUM-BASE AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 16.25 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE PROD-NAME AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
      VIEW-AS TEXT
     SIZE 64 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-in
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.5 BY 5.
DEFINE RECTANGLE RECT-left
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.5 BY 5.
DEFINE RECTANGLE RECT-out
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.5 BY 5.
DEFINE RECTANGLE RECT-ret
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.5 BY 5.
DEFINE new shared QUERY BR-DOCS FOR
      sb-cli-gds SCROLLING.
DEFINE BROWSE BR-DOCS
  QUERY BR-DOCS NO-LOCK DISPLAY
      sb-cli-gds.artic COLUMN-LABEL "Артикул!произ-ля!(сортируется)"
      get-gds-name (buffer sb-cli-gds) FORMAT "X(20)" COLUMN-LABEL "Название"
      get-unit-base (buffer sb-cli-gds) COLUMN-LABEL "Изм" FORMAT "X(3)"
      get-cli-name (buffer sb-cli-gds) COLUMN-LABEL "Контрагент" FORMAT "X(20)"
      get-ext-artic (buffer sb-cli-gds) FORMAT "X(20)" COLUMN-LABEL "Артикул!контрагента!"
      sb-cli-gds.unit-cli COLUMN-LABEL "Изм.!контр!аг-та"
      sb-cli-gds.in-qnty COLUMN-LABEL "Кол-во/приход!(сортируется)"
      sb-cli-gds.out-qnty COLUMN-LABEL "Кол-во/расход!(сортируется)"
      sb-cli-gds.ret-qnty COLUMN-LABEL "Кол-во/возврат!(сортируется)"
      sb-cli-gds.in-base COLUMN-LABEL  "Учетн.цены!баз.вал./!приход"
      sb-cli-gds.in-rubl COLUMN-LABEL  "Учетн.цены!руб./!приход"
      sb-cli-gds.out-sum COLUMN-LABEL  "Продаж.цены!вал.продаж/!расход"
      sb-cli-gds.ret-sum COLUMN-LABEL  "Продаж.цены!вал.продаж/!возврат"
      sb-cli-gds.out-discnt COLUMN-LABEL "Скидки!вал.продаж/!расход"
      sb-cli-gds.ret-discnt COLUMN-LABEL "Скидки!вал.продаж/!возврат"
      sb-cli-gds.in-code COLUmn-LABEL "Последн. ПН"
      get-last-curr-code (buffer sb-cli-gds) COLUmn-LABEL "Валюта!посл.ПН"
      sb-cli-gds.price-cli COLUmn-LABEL "Последн.цена!контр-агента"
      sb-cli-gds.supp-qnty COLUMN-LABEL "Кол-во/остатки!(сортируется)"
      sb-cli-gds.supp-base COLUMN-LABEL "Учетн.цены!баз.вал./!остатки"
      sb-cli-gds.supp-rubl COLUMN-LABEL "Учетн.цены!руб./!остатки"
    WITH NO-ASSIGN NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13.75.
DEFINE FRAME Dialog-Frame
     B-Help AT ROW 1.21 COL 97
     B-exit AT ROW 1.25 COL 1.38
     b-good AT ROW 1.25 COL 11.38
     b-producer AT ROW 1.25 COL 21.38
     b-supplier AT ROW 1.25 COL 31.38
     b-totals AT ROW 1.25 COL 43.5
     B-cliartic AT ROW 1.25 COL 53.5
     b-sch AT ROW 1.25 COL 91.5
     b-print AT ROW 1.25 COL 94.5
     BR-DOCS AT ROW 3.67 COL 1.38
     F-IN-QNTY AT ROW 18.5 COL 6.38 COLON-ALIGNED NO-LABEL
     F-OUT-QNTY AT ROW 18.5 COL 31.75 COLON-ALIGNED NO-LABEL
     F-RET-QNTY AT ROW 18.5 COL 55.75 COLON-ALIGNED NO-LABEL
     F-LEFT-QNTY AT ROW 18.5 COL 80.13 COLON-ALIGNED NO-LABEL
     F-IN-SUM-BASE AT ROW 19.63 COL 6.38 COLON-ALIGNED NO-LABEL
     F-OUT-SUM-BASE AT ROW 19.63 COL 31.63 COLON-ALIGNED NO-LABEL
     F-RET-SUM-BASE AT ROW 19.63 COL 55.75 COLON-ALIGNED NO-LABEL
     F-LEFT-SUM-BASE AT ROW 19.63 COL 80.13 COLON-ALIGNED NO-LABEL
     F-IN-SUM-RUBL AT ROW 20.79 COL 6.25 COLON-ALIGNED NO-LABEL
     F-LEFT-SUM-RUBL AT ROW 20.79 COL 80.13 COLON-ALIGNED NO-LABEL
     F-OUT-DISCNT-BASE AT ROW 21.63 COL 31.75 COLON-ALIGNED NO-LABEL
     F-RET-DISCNT-BASE AT ROW 21.63 COL 56 COLON-ALIGNED NO-LABEL
     PROD-NAME AT ROW 2.79 COL 2.13
     "Приход (учет.цены)" VIEW-AS TEXT
          SIZE 19.88 BY .71 AT ROW 17.63 COL 4.25
          FGCOLOR 4
     "Скидки" VIEW-AS TEXT
          SIZE 5.5 BY .71 AT ROW 21.79 COL 51.88
          FGCOLOR 4 FONT 4
     "Скидки" VIEW-AS TEXT
          SIZE 5.5 BY .71 AT ROW 21.79 COL 28
          FGCOLOR 4 FONT 4
     "." VIEW-AS TEXT
          SIZE 5.5 BY .71 AT ROW 20.96 COL 76.13
          FGCOLOR 4 FONT 4
     "." VIEW-AS TEXT
          SIZE 5.5 BY .71 AT ROW 20.96 COL 2.38
          FGCOLOR 4 FONT 4
     "Баз.вал." VIEW-AS TEXT
          SIZE 5.75 BY .71 AT ROW 19.83 COL 76.13
          FGCOLOR 4 FONT 4
     "Сумма" VIEW-AS TEXT
          SIZE 5.75 BY .71 AT ROW 19.83 COL 51.63
          FGCOLOR 4 FONT 4
     "Сумма" VIEW-AS TEXT
          SIZE 5.75 BY .71 AT ROW 19.83 COL 27.63
          FGCOLOR 4 FONT 4
     "Баз.вал." VIEW-AS TEXT
          SIZE 5.75 BY .71 AT ROW 19.83 COL 2.38
          FGCOLOR 4 FONT 4
     "Кол-во" VIEW-AS TEXT
          SIZE 5.38 BY .71 AT ROW 18.67 COL 76.13
          FGCOLOR 4 FONT 4
     "Кол-во" VIEW-AS TEXT
          SIZE 5.38 BY .71 AT ROW 18.67 COL 52
          FGCOLOR 4 FONT 4
     "Кол-во" VIEW-AS TEXT
          SIZE 5.38 BY .71 AT ROW 18.67 COL 27.63
          FGCOLOR 4 FONT 4
     "Кол-во" VIEW-AS TEXT
          SIZE 5.38 BY .71 AT ROW 18.67 COL 2.38
          FGCOLOR 4 FONT 4
     "Остатки (учет.цены)" VIEW-AS TEXT
          SIZE 19.75 BY .71 AT ROW 17.63 COL 77.5
          FGCOLOR 4
     "Возвр. (вал. продаж)" VIEW-AS TEXT
          SIZE 19.88 BY .71 AT ROW 17.63 COL 53
          FGCOLOR 4
     "Расх. (вал. продаж)" VIEW-AS TEXT
          SIZE 20.13 BY .71 AT ROW 17.63 COL 28.25
          FGCOLOR 4
     RECT-in AT ROW 17.79 COL 1.63
     RECT-out AT ROW 17.79 COL 27
     RECT-ret AT ROW 17.79 COL 51.25
     RECT-left AT ROW 17.79 COL 75.5
     SPACE(0.75) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары контрагентов по фирме".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-cliartic IN FRAME Dialog-Frame
DO:
    define variable rid as recid no-undo.
    find first buf-goods no-lock
        where buf-goods.prod-code = sb-cli-gds.prod-code
        and buf-goods.prod-type = sb-cli-gds.prod-type
        and buf-goods.artic = sb-cli-gds.artic
        no-error.
    if not avail buf-goods then return.
    find first buf-ext-artic no-lock
        where buf-ext-artic.cli-type = sb-cli-gds.cli-type
        and buf-ext-artic.cli-code   = sb-cli-gds.cli-code
        and buf-ext-artic.gds-code = buf-goods.gds-code
        no-error.
    if avail buf-ext-artic then
        do:
            rid = recid(buf-ext-artic).
            run ref/ea-form.w(
                input parparentproc ,
                input 'ИЗМЕНЕНИЕ':U ,
                input buf-goods.gds-code,
                input-output rid,
                input recid(buf-cli)
            ).
        end.
    else
        do:
            rid = 0.
            run ref/ea-form.w(
                input parparentproc,
                input 'ДОБАВЛЕНИЕ':U,
                input buf-goods.gds-code,
                input-output rid,
                input recid(buf-cli)
            ).
        end.
    br-docs:REFRESH().
END.
ON CHOOSE OF b-good IN FRAME Dialog-Frame
DO:
    IF not avail sb-cli-gds then return no-apply.
    FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = sb-cli-gds.prod-type AND
                                                                    ub.goods.prod-code = sb-cli-gds.prod-code AND
                                                                    ub.goods.artic = sb-cli-gds.artic
     NO-ERROR.
    if not available ub.goods then return no-apply.
    run str/showgds.p ( input parparentproc
                       ,input ?
                       ,input ub.goods.gds-code
                       ,input 'ПРОСМОТР':U).
    apply "entry" to br-docs in frame Dialog-Frame.
    return no-apply.
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define variable v-doc-rec  as recid no-undo .
      if p-list-mode = 'все':U and index(frame Dialog-Frame:title,"ФИЛЬТР" ) = 0 then do:
           message "Вы хотите напечатать весь список товаров контрагентов" skip
           "при невключенном фильтре!" skip
           "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
           WARNING buttons YES-NO update glog.
           if NOT glog then return no-apply.
      end.
      v-doc-rec = recid( sb-cli-gds ).
      DO WHILE available sb-cli-gds :
            GET prev br-docs.
      END.
      if p-list-mode = 'все':U then
      run Print-TotalProc("P").
      else
      run Print-List-Mode.
      reposition br-docs to recid v-doc-rec no-error.
      apply "entry" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF b-producer IN FRAME Dialog-Frame
DO:
    if not available sb-cli-gds then return no-apply.
    run ref/showcli.p
    (input parparentproc
    ,input sb-cli-gds.prod-type
    ,input sb-cli-gds.prod-code
    ).
    apply "entry" to br-docs in frame Dialog-Frame.
    return no-apply.
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
  assign
  tbl = 'cli-gds'
  join-tbl = 'sb-cli-gds'
  fld = '':U
  lab = '':U
  spr = '':U
  dim = '0':U
  .
  run fltfield-add in this-procedure('artic', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-art', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('unit-cli', '', 'unit',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-qnty', 'Кол-во/приход', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-qnty', 'Кол-во/расход', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ret-qnty', 'Кол-во/Возврат', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-base', 'Учетн.цены.(баз.вал.)/приход', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-rubl', 'Учетн.цены.(руб.)/приход', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-sum', 'Продаж.цены/расход', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ret-sum', 'Продаж.цены/возврат', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-discnt', 'Скидки(вал.продаж)/расход', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ret-discnt', 'Скидки(вал.продаж)/возврат', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-code', 'Последн.ПН', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('exch-code', 'Валюта последн.ПН', 'curr',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-cli', 'Последн.цена', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-qnty', 'Кол-во/остатки', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-base', 'Учетн.цены(баз.вал.)/остатки', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-rubl', 'Учетн.цены(руб.)/остатки', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  DO on stop undo, leave:
      run gbl/filter.w ( input parparentproc
                        , input (filter-point + chr(4) + filter-label)
                        , input tbl
                        , input join-tbl
                        , input fld
                        , input lab
                        , input spr
                        , input dim).
      RUN OpenBr in this-procedure .
  END .
END.
ON CHOOSE OF b-supplier IN FRAME Dialog-Frame
DO:
    if not available sb-cli-gds then return no-apply.
    run ref/showcli.p
    (input parparentproc
    ,input sb-cli-gds.cli-type
    ,input sb-cli-gds.cli-code
    ).
    apply "entry" to br-docs in frame Dialog-Frame.
    return no-apply.
END.
ON CHOOSE OF b-totals IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
    if p-list-mode = 'все':U AND index(frame Dialog-Frame:title,"ФИЛЬТР" ) = 0 then do:
        message "Вы хотите рассчитать итоги по всему спискy товаров контрагентов" skip
        "при невключенном фильтре!" skip
        "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
        WARNING buttons YES-NO update glog.
        if NOT glog then return no-apply.
  end.
  v-doc-rec = recid( sb-cli-gds ).
  DO WHILE available sb-cli-gds :
        GET prev br-docs.
  END.
  run Print-TotalProc("C":U).
  reposition br-docs to recid v-doc-rec no-error.
  apply "entry" to br-docs in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF BR-DOCS IN FRAME Dialog-Frame
DO:
DEFINE buffer for-cli for ub.clients.
  FIND FIRST for-cli No-LOCK WHERE for-cli.obj-type = sb-cli-gds.prod-type AND
                                   for-cli.obj-code = sb-cli-gds.prod-code No-ERROR.
    IF AVAIL for-cli then DO:
        DISPLAY for-cli.obj-name @ PROD-NAME WITH FRAME Dialog-Frame.
    end.
    else do:
        DISPLAY "" @ PROD-NAME WITH FRAME Dialog-Frame.
    end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-DOCS :handle
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
def var sort-labelBR-DOCS   as character no-undo .
def var sort-clmnBR-DOCS    as handle    no-undo .
def var cur-clmnBR-DOCS     as handle    no-undo .
def var cur-clmn-locBR-DOCS as integer   no-undo .
def var re-queryBR-DOCS     as logical   initial no no-undo .
on start-search, ctrl-o of BR-DOCS in frame Dialog-Frame do:
   run sort-brBR-DOCS
     (input (if available sb-cli-gds
             then recid(sb-cli-gds)
             else ?
            )
     ).
end.
PROCEDURE sort-brBR-DOCS :
  define input parameter p-recid as recid no-undo .
  if re-queryBR-DOCS = no then do:
    assign
       cur-clmnBR-DOCS = BR-DOCS:current-column in frame Dialog-Frame
    .
    if sort-clmnBR-DOCS <> ? then sort-clmnBR-DOCS:column-fgcolor = 0.
    if cur-clmnBR-DOCS = sort-clmnBR-DOCS then do:
      assign
         sort-labelBR-DOCS = ""
         sort-clmnBR-DOCS = ?
      .
     end.
     else do:
       assign
         sort-labelBR-DOCS = cur-clmnBR-DOCS:label
         sort-clmnBR-DOCS  = cur-clmnBR-DOCS
         sort-clmnBR-DOCS:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBR-DOCS = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BR-DOCS:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBR-DOCS then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBR-DOCS = cur-clmn-locBR-DOCS + 1
    .
  end.
  case sort-labelBR-DOCS:
        when sb-cli-gds.artic:label in browse BR-DOCS then DO:    assign       sort-column-name = "sb-cli-gds.artic"     .     run OpenBr in this-procedure .   . END.
        when sb-cli-gds.in-qnty:label in browse BR-DOCS then DO:    assign       sort-column-name = "sb-cli-gds.in-qnty"     .     run OpenBr in this-procedure .   . END.
        when sb-cli-gds.out-qnty:label in browse BR-DOCS then DO:    assign       sort-column-name = "sb-cli-gds.out-qnty"     .     run OpenBr in this-procedure .   . END.
        when sb-cli-gds.ret-qnty:label in browse BR-DOCS then DO:    assign       sort-column-name = "sb-cli-gds.ret-qnty"     .     run OpenBr in this-procedure .   . END.
        when sb-cli-gds.supp-qnty:label in browse BR-DOCS then DO:    assign       sort-column-name = "sb-cli-gds.supp-qnty"     .     run OpenBr in this-procedure .   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure .
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultBR-DOCS') then do:
          run mv-brw-defaultBR-DOCS.
        end.
      if sort-labelBR-DOCS <> "" then do:
        assign
          cur-clmnBR-DOCS:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBR-DOCS = ?
      .
    end.
  end case.
    if cur-clmn-locBR-DOCS <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnBR-DOCS') then do:
        run ch-clmnBR-DOCS in this-procedure (cur-clmn-locBR-DOCS).
      end.
    end.
  if p-recid <> ? then do:
    reposition BR-DOCS to recid p-recid no-error.
    apply "value-changed" to BR-DOCS in frame Dialog-Frame.
  end.
  apply "entry" to BR-DOCS in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBR-DOCS:
if cur-clmnBR-DOCS = ? then do:
   run OpenBr in this-procedure .
end.
else do:
   assign re-queryBR-DOCS = yes.
   run sort-brBR-DOCS
     (input (if available sb-cli-gds
             then recid(sb-cli-gds)
             else ?
            )
     ).
   assign re-queryBR-DOCS = no.
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input 'орг':U
  ,input v-host-code
  ,input 'report-firm':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.
  frame Dialog-Frame:TITLE = frame Dialog-Frame:TITLE + " " + v-host-name.
  RUN enable_UI.
  RUN OpenBr in this-procedure .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-docs as INT EXTENT 21 no-undo.
DEF VAR varmvibr-docs       as INT no-undo.
DEF VAR varmvjbr-docs       as INT no-undo.
DEF VAR varmvkbr-docs       as INT no-undo.
DEF VAR varmvlbr-docs       as INT no-undo.
DEF VAR move-elementbr-docs as INT no-undo.
def var jjbr-docs           as int no-undo.
do varmvibr-docs = 1 to EXTENT(cur-clmn-numbr-docs):
  ASSIGN cur-clmn-numbr-docs[varmvibr-docs] = varmvibr-docs.
END.
RUN start-mv-clmnbr-docs.
PROCEDURE start-mv-clmnbr-docs:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  p-list-mode = 'Контрагент,Обороты':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,7,8,9,10,11,12,13,14,15,5,6,16,17,18,19,20,21,4') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,7,8,9,10,11,12,13,14,15,5,6,16,17,18,19,20,21,4'))] ,  + 1).
   END.
       END.
       IF  p-list-mode = 'Контрагент,Остатки':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,19,20,21,5,6,7,8,9,10,11,12,13,14,15,16,17,18,4') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,19,20,21,5,6,7,8,9,10,11,12,13,14,15,16,17,18,4'))] ,  + 1).
   END.
       END.
       IF  p-list-mode = 'Производитель,Обороты':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,4,7,8,9,10,11,12,13,14,15,5,6,16,17,18,19,20,21') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,4,7,8,9,10,11,12,13,14,15,5,6,16,17,18,19,20,21'))] ,  + 1).
   END.
       END.
       IF  p-list-mode = 'Производитель,Остатки':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,4,19,20,21,5,6,7,8,9,10,11,12,13,14,15,16,17,18') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,4,19,20,21,5,6,7,8,9,10,11,12,13,14,15,16,17,18'))] ,  + 1).
   END.
       END.
       IF  p-list-mode = 'Товар,Обороты':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('4,7,8,9,10,11,12,13,14,15,5,6,16,17,18,19,20,21,1,2,3') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '4,7,8,9,10,11,12,13,14,15,5,6,16,17,18,19,20,21,1,2,3'))] ,  + 1).
   END.
       END.
       IF  p-list-mode = 'Товар,Остатки':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('4,19,20,21,5,6,7,8,9,10,11,12,13,14,15,16,17,18,1,2,3') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '4,19,20,21,5,6,7,8,9,10,11,12,13,14,15,16,17,18,1,2,3'))] ,  + 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (  + 1, 21).
END.
ON ctrl-cursor-left OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (21,  + 1).
END.
PROCEDURE re-move-clmnbr-docs:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = source-column THEN cur-clmn-numbr-docs[varmvibr-docs] = -1.
  END.
  if br-docs:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-docs = source-column - 1 to target-column BY -1:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
        if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
          cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-docs = source-column + 1 to target-column:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
      if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
        cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] - 1.
      END.
    END.
  END.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = -1 THEN cur-clmn-numbr-docs[varmvibr-docs] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-docs:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <=  + 1 then do:
    return .
  end.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-loc THEN move-elementbr-docs = varmvibr-docs.
  END.
  RUN re-move-clmnbr-docs (cur-clmn-loc,  + 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-docs =  + 1 to EXTENT(cur-clmn-numbr-docs):
    RUN re-move-clmnbr-docs (cur-clmn-numbr-docs[varmvlbr-docs], varmvlbr-docs).
  END.
  RUN start-mv-clmnbr-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY F-IN-QNTY F-OUT-QNTY F-RET-QNTY F-LEFT-QNTY F-IN-SUM-BASE
          F-OUT-SUM-BASE F-RET-SUM-BASE F-LEFT-SUM-BASE F-IN-SUM-RUBL
          F-LEFT-SUM-RUBL F-OUT-DISCNT-BASE F-RET-DISCNT-BASE PROD-NAME
      WITH FRAME Dialog-Frame.
  ENABLE RECT-in RECT-out RECT-ret RECT-left B-Help B-exit b-good
         b-producer b-supplier b-totals B-cliartic b-sch b-print BR-DOCS
         PROD-NAME
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
CASE p-list-mode:
    when 'все':U then do:
        ASSIGN frame Dialog-Frame:TITLE = "ТОВАРЫ КОНТРАГЕНТОВ ПО ФИРМЕ " + v-host-name
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1", filter-label0)
        .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-22  as logical   no-undo .
define variable  l-filter-open-22    as logical   .
define variable  flt-rec-22       as recid     no-undo .
define variable  filter-name-22      as character no-undo .
define variable  where-phrase-22     as character no-undo .
define variable  sort-phrase-22      as character no-undo .
define variable  where-phrase-rus-22 as character no-undo .
define variable  sort-phrase-rus-22  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-22
  ,output filter-name-22
  ,output where-phrase-22
  ,output sort-phrase-22
  ,output where-phrase-rus-22
  ,output sort-phrase-rus-22
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-22
      ) no-error .
  assign
    l-filter-open-22 = false
  .
  if flt-rec-22 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-22 as character no-undo .
    define variable  parameter-3-22 as character no-undo .
    define variable  parameter-4-22 as character no-undo .
    define variable  parameter-5-22 as character no-undo .
    define variable  parameter-6-22 as character no-undo .
    define variable  parameter-7-22 as character no-undo .
      assign
      parameter-3-22 =
                              "FOR EACH sb-cli-gds"
      parameter-4-22 =
        (
          if ("sb-cli-gds.host-code = v-host-code" + " " + where-phrase-22) <> ""
          then  substitute( 'sb-cli-gds.host-code = &1', v-host-code) + " " + where-phrase-22
          else "true"
        )
      parameter-5-22 = (" " + "" + " " + "")
      parameter-6-22 = if sort-phrase-22 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-22
        )
      parameter-7-22 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-22 =
          ("sb-cli-gds.host-code = v-host-code" + " " + where-phrase-22 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-22
                          ,input parameter-4-22
                          ,input parameter-5-22
                          ,input parameter-6-22
                          ,input parameter-7-22
                          )
      .
      assign
        l-filter-open-22 = true
      .
    end.
    if l-filter-open-22 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-22 = false then do:
    OPEN QUERY br-docs FOR EACH sb-cli-gds
      where sb-cli-gds.host-code = v-host-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
    end.
    when 'Контрагент,Обороты':U or when 'Контрагент,Остатки':U then do:
        find first buf-cli WHERE recid(buf-cli) = p-rep-rec No-LOCK No-ERROR.
        ASSIGN frame Dialog-Frame:TITLE =
        (IF can-do(p-list-mode, 'Обороты':U) then
        "ОБОРОТЫ КОНТРАГЕНТА "
        else
        "ОСТАТКИ КОНТРАГЕНТА ")
         + string(buf-cli.obj-name, "X(20)") + " ПО ФИРМЕ " + v-host-name
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 &2"
                                 , filter-label0
                                 ,
                                  (IF can-do(p-list-mode, 'Обороты':U) then
                                  "ОБОРОТЫ КОНТРАГЕНТА "
                                  else
                                  "ОСТАТКИ КОНТРАГЕНТА ")
                                 )
        .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-24  as logical   no-undo .
define variable  l-filter-open-24    as logical   .
define variable  flt-rec-24       as recid     no-undo .
define variable  filter-name-24      as character no-undo .
define variable  where-phrase-24     as character no-undo .
define variable  sort-phrase-24      as character no-undo .
define variable  where-phrase-rus-24 as character no-undo .
define variable  sort-phrase-rus-24  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-24
  ,output filter-name-24
  ,output where-phrase-24
  ,output sort-phrase-24
  ,output where-phrase-rus-24
  ,output sort-phrase-rus-24
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-24
      ) no-error .
  assign
    l-filter-open-24 = false
  .
  if flt-rec-24 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-24 as character no-undo .
    define variable  parameter-3-24 as character no-undo .
    define variable  parameter-4-24 as character no-undo .
    define variable  parameter-5-24 as character no-undo .
    define variable  parameter-6-24 as character no-undo .
    define variable  parameter-7-24 as character no-undo .
      assign
      parameter-3-24 =
                              "FOR EACH sb-cli-gds"
      parameter-4-24 =
        (
          if ("sb-cli-gds.host-code = v-host-code              AND sb-cli-gds.cli-type = buf-cli.obj-type              AND sb-cli-gds.cli-code = buf-cli.obj-code" + " " + where-phrase-24) <> ""
          then  substitute('sb-cli-gds.host-code = &1              AND sb-cli-gds.cli-type = &2&3&2              AND sb-cli-gds.cli-code = &4', v-host-code, chr(34), buf-cli.obj-type, buf-cli.obj-code) + " " + where-phrase-24
          else "true"
        )
      parameter-5-24 = (" " + "" + " " + "")
      parameter-6-24 = if sort-phrase-24 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-24
        )
      parameter-7-24 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-24 =
          ("sb-cli-gds.host-code = v-host-code              AND sb-cli-gds.cli-type = buf-cli.obj-type              AND sb-cli-gds.cli-code = buf-cli.obj-code" + " " + where-phrase-24 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-24
                          ,input parameter-4-24
                          ,input parameter-5-24
                          ,input parameter-6-24
                          ,input parameter-7-24
                          )
      .
      assign
        l-filter-open-24 = true
      .
    end.
    if l-filter-open-24 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-24 = false then do:
    OPEN QUERY br-docs FOR EACH sb-cli-gds
      where sb-cli-gds.host-code = v-host-code              AND sb-cli-gds.cli-type = buf-cli.obj-type              AND sb-cli-gds.cli-code = buf-cli.obj-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
    end.
    when 'Производитель,Обороты':U or when 'Производитель,Остатки':U then do:
        find first buf-cli WHERE recid(buf-cli) = p-rep-rec No-LOCK No-ERROR.
        ASSIGN frame Dialog-Frame:TITLE =
       (IF can-do(p-list-mode, 'Обороты':U) then
        "ОБОРОТЫ ТОВАРОВ ПРОИЗВОДИТЕЛЯ "
        else
        "ОСТАТКИ ТОВАРОВ ПРОИЗВОДИТЕЛЯ ")
        + string(buf-cli.obj-name, "X(20)") + " ВСЕХ КОНТРАГЕНТОВ ПО ФИРМЕ " + v-host-name
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 &2"
                                 , filter-label0
                                 ,
                                  (IF can-do(p-list-mode, 'Обороты':U) then
                                    "ОБОРОТЫ ТОВАРОВ ПРОИЗВОДИТЕЛЯ "
                                    else
                                    "ОСТАТКИ ТОВАРОВ ПРОИЗВОДИТЕЛЯ "))
        .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-26  as logical   no-undo .
define variable  l-filter-open-26    as logical   .
define variable  flt-rec-26       as recid     no-undo .
define variable  filter-name-26      as character no-undo .
define variable  where-phrase-26     as character no-undo .
define variable  sort-phrase-26      as character no-undo .
define variable  where-phrase-rus-26 as character no-undo .
define variable  sort-phrase-rus-26  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-26
  ,output filter-name-26
  ,output where-phrase-26
  ,output sort-phrase-26
  ,output where-phrase-rus-26
  ,output sort-phrase-rus-26
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-26
      ) no-error .
  assign
    l-filter-open-26 = false
  .
  if flt-rec-26 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-26 as character no-undo .
    define variable  parameter-3-26 as character no-undo .
    define variable  parameter-4-26 as character no-undo .
    define variable  parameter-5-26 as character no-undo .
    define variable  parameter-6-26 as character no-undo .
    define variable  parameter-7-26 as character no-undo .
      assign
      parameter-3-26 =
                              "FOR EACH sb-cli-gds"
      parameter-4-26 =
        (
          if ("sb-cli-gds.host-code = v-host-code              AND sb-cli-gds.prod-type = buf-cli.obj-type              AND sb-cli-gds.prod-code = buf-cli.obj-code" + " " + where-phrase-26) <> ""
          then  substitute( 'sb-cli-gds.host-code = &1              AND sb-cli-gds.prod-type = &2&3&2              AND sb-cli-gds.prod-code = &4', v-host-code, chr(34), buf-cli.obj-type, buf-cli.obj-code) + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + "")
      parameter-6-26 = if sort-phrase-26 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-26
        )
      parameter-7-26 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-26 =
          ("sb-cli-gds.host-code = v-host-code              AND sb-cli-gds.prod-type = buf-cli.obj-type              AND sb-cli-gds.prod-code = buf-cli.obj-code" + " " + where-phrase-26 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-26
                          ,input parameter-4-26
                          ,input parameter-5-26
                          ,input parameter-6-26
                          ,input parameter-7-26
                          )
      .
      assign
        l-filter-open-26 = true
      .
    end.
    if l-filter-open-26 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-26 = false then do:
    OPEN QUERY br-docs FOR EACH sb-cli-gds
      where sb-cli-gds.host-code = v-host-code              AND sb-cli-gds.prod-type = buf-cli.obj-type              AND sb-cli-gds.prod-code = buf-cli.obj-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
    end.
    when 'Товар,Обороты':U or when 'Товар,Остатки':U then do:
        find first buf-goods WHERE recid(buf-goods) = p-gds-rec No-LOCK No-ERROR.
        ASSIGN frame Dialog-Frame:TITLE =
        (IF can-do(p-list-mode, 'Обороты':U) then
        "ОБОРОТЫ ТОВАРА "
        else
        "ОСТАТКИ ТОВАРА ")
        + buf-goods.artic +  " " + string(buf-goods.gds-name , "X(20)") +
        " ПРОИЗВОДИТЕЛЬ: " + buf-goods.prod-type +
        " " + string(buf-goods.prod-code) + " " + " ПО ФИРМЕ " + v-host-name
        c-point = " " + p-list-mode
        filter-point = filter-point0 + p-list-mode
        filter-label = substitute("&1 &2"
                                 , filter-label0
                                 ,
                                  (IF can-do(p-list-mode, 'Обороты':U) then
                                  "ОБОРОТЫ ТОВАРА "
                                  else
                                  "ОСТАТКИ ТОВАРА "))
        .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-28  as logical   no-undo .
define variable  l-filter-open-28    as logical   .
define variable  flt-rec-28       as recid     no-undo .
define variable  filter-name-28      as character no-undo .
define variable  where-phrase-28     as character no-undo .
define variable  sort-phrase-28      as character no-undo .
define variable  where-phrase-rus-28 as character no-undo .
define variable  sort-phrase-rus-28  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-28
  ,output filter-name-28
  ,output where-phrase-28
  ,output sort-phrase-28
  ,output where-phrase-rus-28
  ,output sort-phrase-rus-28
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-28
      ) no-error .
  assign
    l-filter-open-28 = false
  .
  if flt-rec-28 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-28 as character no-undo .
    define variable  parameter-3-28 as character no-undo .
    define variable  parameter-4-28 as character no-undo .
    define variable  parameter-5-28 as character no-undo .
    define variable  parameter-6-28 as character no-undo .
    define variable  parameter-7-28 as character no-undo .
      assign
      parameter-3-28 =
                              "FOR EACH sb-cli-gds"
      parameter-4-28 =
        (
          if ("sb-cli-gds.host-code = v-host-code              AND sb-cli-gds.prod-type = buf-goods.prod-type              AND sb-cli-gds.prod-code = buf-goods.prod-code              AND sb-cli-gds.artic = buf-goods.artic" + " " + where-phrase-28) <> ""
          then   substitute('sb-cli-gds.host-code = &1              AND sb-cli-gds.prod-type = &2&3&2              AND sb-cli-gds.prod-code = &4              AND sb-cli-gds.artic = &2&5&2', v-host-code, chr(34), buf-goods.prod-type, buf-goods.prod-code, buf-goods.artic) + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + "")
      parameter-6-28 = if sort-phrase-28 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-28
        )
      parameter-7-28 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-28 =
          ("sb-cli-gds.host-code = v-host-code              AND sb-cli-gds.prod-type = buf-goods.prod-type              AND sb-cli-gds.prod-code = buf-goods.prod-code              AND sb-cli-gds.artic = buf-goods.artic" + " " + where-phrase-28 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-28
                          ,input parameter-4-28
                          ,input parameter-5-28
                          ,input parameter-6-28
                          ,input parameter-7-28
                          )
      .
      assign
        l-filter-open-28 = true
      .
    end.
    if l-filter-open-28 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-28 = false then do:
    OPEN QUERY br-docs FOR EACH sb-cli-gds
      where sb-cli-gds.host-code = v-host-code              AND sb-cli-gds.prod-type = buf-goods.prod-type              AND sb-cli-gds.prod-code = buf-goods.prod-code              AND sb-cli-gds.artic = buf-goods.artic
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
    end.
END CASE.
run waitfram-hide in this-procedure .
    display
    ? @ F-IN-QNTY
    ? @ F-IN-SUM-BASE
    ? @ F-IN-SUM-RUBL
    ? @ F-LEFT-QNTY
    ? @ F-LEFT-SUM-BASE
    ? @ F-LEFT-SUM-RUBL
    ? @ F-OUT-DISCNT-BASE
    ? @ F-OUT-QNTY
    ? @ F-OUT-SUM-BASE
    ? @ F-RET-DISCNT-BASE
    ? @ F-RET-QNTY
    ? @ F-RET-SUM-BASE
    with frame Dialog-Frame.
APPLY "VALUE-CHANGED" TO BR-DOCS.
APPLY "ENTRY" TO BR-DOCS.
END PROCEDURE.
PROCEDURE Print-List-Mode :
DEFINE VARIABLE v-without-zero as logical no-undo .
DEFINE VARIABLE choice as integer no-undo .
run gbl/d-askw.w
                     (input "Печать остатков по контрагенту",
                      input "Выберите опцию печати",
                      input "|",
                      input "Печатать нулевые остатки|Не печатать нулевые остатки|Выход",
                      input "||",
                      input 2,
                      input 3,
                      output choice).
if choice = 3 then return.
assign
v-without-zero = (choice = 2)
.
 run ref/cli-gdsp.p (
                input parparentproc,
                input ENTRY(1, p-list-mode),
                input ENTRY(2, p-list-mode),
                input replace(FRAME Dialog-Frame:TITLE, chr(34), chr(39)),
                input v-without-zero,
                output  accum-in-qnty ,
                output  accum-out-qnty ,
                output  accum-ret-qnty  ,
                output  accum-in-base  ,
                output  accum-in-rubl  ,
                output  accum-out-sum  ,
                output  accum-ret-sum  ,
                output  accum-out-discnt  ,
                output  accum-ret-discnt  ,
                output  accum-supp-qnty  ,
                output  accum-supp-base  ,
                output  accum-supp-rubl
                ).
   display
    accum-in-qnty @ F-IN-QNTY
    accum-in-base @ F-IN-SUM-BASE
    accum-in-rubl @ F-IN-SUM-RUBL
    accum-supp-qnty @ F-LEFT-QNTY
    accum-supp-base @ F-LEFT-SUM-BASE
    accum-supp-rubl @ F-LEFT-SUM-RUBL
    accum-out-discnt @ F-OUT-DISCNT-BASE
    accum-out-qnty @ F-OUT-QNTY
    accum-out-sum @ F-OUT-SUM-BASE
    accum-ret-discnt @ F-RET-DISCNT-BASE
    accum-ret-qnty @ F-RET-QNTY
    accum-ret-sum @ F-RET-SUM-BASE
    with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE Print-TotalProc :
Def Input Parameter work-mode as character format "X(1)" no-undo.
define variable v-process as logical no-undo .
define variable reportfilename as character no-undo .
if work-mode = "P" then do:
    Line = fill("-", 177).
    date_string = cur-time-print() .
   run prn-lib-open-exp in this-procedure (
                                            input parParentProc
                                           ,input yes
                                           ,input no
                                           ,output ReportFileName
                                           ,output v-process
                                            ) .
   if not v-process then return.
    PUT  STREAM PrnLibStream UNFORMATTED
    ( frame Dialog-Frame:title )
    format "x(90)" SKIP(0)
    date_string skip(0) .
end.
run waitfram-show in this-procedure ("Ждите...").
if work-mode = "P" then do:
PUT STREAM PrnLibStream UNFORMATTED
"Артикул" p-XL-delim
"Название_товара" p-XL-delim
"Ед.изм." p-XL-delim
"Код производителя" p-XL-delim
"Производитель" p-XL-delim
"Контрагент" p-XL-delim
"Артикул_контрагента" p-XL-delim
"Ед.изм._контрагента" p-XL-delim
"Кол-во/приход" p-XL-delim
"Кол-во/расход" p-XL-delim
"Кол-во/возврат" p-XL-delim
"Учетн.цены(баз.вал.)/приход" p-XL-delim
"Учетн.цены(руб.)/приход" p-XL-delim
"Продаж.цены(вал.продаж)/расход" p-XL-delim
"Продаж.цены(вал.продаж)/возврат" p-XL-delim
"Скидки(вал.продаж)/расход" p-XL-delim
"Скидки(вал.продаж)/возврат" p-XL-delim
"Последняя_ПН" p-XL-delim
"Валюта_посл.ПН" p-XL-delim
"Последн.цена_контрагента" p-XL-delim
"Кол-во/остатки" p-XL-delim
"Учетн.цены(баз.вал.)/остатки" p-XL-delim
"Учетн.цены(руб.)/остатки" p-XL-delim
SKIP.
end.
    assign
    accum-count = 0
    accum-in-qnty = 0
    accum-out-qnty = 0
    accum-ret-qnty = 0
    accum-in-base = 0
    accum-in-rubl = 0
    accum-out-sum = 0
    accum-ret-sum = 0
    accum-out-discnt = 0
    accum-ret-discnt = 0
    accum-supp-qnty = 0
    accum-supp-base = 0
    accum-supp-rubl = 0.
GET next br-docs.
DO WHILE available sb-cli-gds :
    assign
    accum-count = accum-count + 1
    accum-in-qnty = accum-in-qnty + sb-cli-gds.in-qnty
    accum-out-qnty = accum-out-qnty + sb-cli-gds.out-qnty
    accum-ret-qnty = accum-ret-qnty + sb-cli-gds.ret-qnty
    accum-in-base = accum-in-base + sb-cli-gds.in-base
    accum-in-rubl = accum-in-rubl + sb-cli-gds.in-rubl
    accum-out-sum = accum-out-sum + sb-cli-gds.out-sum
    accum-ret-sum = accum-ret-sum + sb-cli-gds.ret-sum
    accum-out-discnt = accum-out-discnt + sb-cli-gds.out-discnt
    accum-ret-discnt = accum-ret-discnt + sb-cli-gds.ret-discnt
    accum-supp-qnty = accum-supp-qnty + sb-cli-gds.supp-qnty
    accum-supp-base = accum-supp-base + sb-cli-gds.supp-base
    accum-supp-rubl = accum-supp-rubl + sb-cli-gds.supp-rubl.
    if work-mode = "P" then do:
        FIND FIRST ub.currency NO-LOCK WHERE ub.currency.curr-code = sb-cli-gds.exch-code
        No-ERROR.
        FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = sb-cli-gds.prod-type AND
                                         ub.clients.obj-code = sb-cli-gds.prod-code
        No-ERROR.
        if avail ub.clients then
        cli-name = ub.clients.obj-name.
        else
        cli-name = "".
        FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = sb-cli-gds.prod-type AND
                                         ub.clients.obj-code = sb-cli-gds.prod-code
        No-ERROR.
        FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = sb-cli-gds.prod-type AND
                                                                    ub.goods.prod-code = sb-cli-gds.prod-code AND
                                                                    ub.goods.artic = sb-cli-gds.artic
        NO-ERROR.
        IF AVAIL ub.goods then
        assign
        gds-name = ub.goods.gds-name
        unit-base = ub.goods.unit-base.
        else
        assign
        gds-name = ""
        unit-base = "".
        PUT STREAM PrnLibStream UNFORMATTED
        sb-cli-gds.artic p-XL-delim
        REPLACE(gds-name, " ", "_") p-XL-delim
        unit-base p-XL-delim
        (clients.obj-type + "_" + string(clients.obj-code)) p-XL-delim
        REPLACE(clients.obj-name, " ", "_") p-XL-delim
        REPLACE(cli-name, " ", "_") p-XL-delim
        sb-cli-gds.cli-art p-XL-delim
        sb-cli-gds.unit-cli p-XL-delim
        sb-cli-gds.in-qnty p-XL-delim
        sb-cli-gds.out-qnty p-XL-delim
        sb-cli-gds.ret-qnty p-XL-delim
        sb-cli-gds.in-base p-XL-delim
        sb-cli-gds.in-rubl p-XL-delim
        sb-cli-gds.out-sum p-XL-delim
        sb-cli-gds.ret-sum p-XL-delim
        sb-cli-gds.out-discnt p-XL-delim
        sb-cli-gds.ret-discnt p-XL-delim
        sb-cli-gds.in-code p-XL-delim
        last-curr-code p-XL-delim
        sb-cli-gds.price-cli p-XL-delim
        sb-cli-gds.supp-qnty p-XL-delim
        sb-cli-gds.supp-base p-XL-delim
        sb-cli-gds.supp-rubl p-XL-delim
        skip.
    end.
    GET next br-docs.
    END.
    IF work-mode = "P" then do:
        PUT STREAM PrnLibStream UNFORMATTED
        "ИТОГО_записей" p-XL-delim
        string(accum-count) p-XL-delim
        p-XL-delim
        p-XL-delim
        p-XL-delim
        p-XL-delim
        p-XL-delim
        p-XL-delim
        accum-in-qnty p-XL-delim
        accum-out-qnty p-XL-delim
        accum-ret-qnty p-XL-delim
        accum-in-base p-XL-delim
        accum-in-rubl p-XL-delim
        accum-out-sum p-XL-delim
        accum-ret-sum p-XL-delim
        accum-out-discnt p-XL-delim
        accum-ret-discnt p-XL-delim
        p-XL-delim
        p-XL-delim
        p-XL-delim
        accum-supp-qnty p-XL-delim
        accum-supp-base p-XL-delim
        accum-supp-rubl p-XL-delim
        SKIP.
       output  STREAM PrnLibStream CLOSE.
        run waitfram-hide in this-procedure .
   end.
   run waitfram-hide in this-procedure .
    display
    accum-in-qnty @ F-IN-QNTY
    accum-in-base @ F-IN-SUM-BASE
    accum-in-rubl @ F-IN-SUM-RUBL
    accum-supp-qnty @ F-LEFT-QNTY
    accum-supp-base @ F-LEFT-SUM-BASE
    accum-supp-rubl @ F-LEFT-SUM-RUBL
    accum-out-discnt @ F-OUT-DISCNT-BASE
    accum-out-qnty @ F-OUT-QNTY
    accum-out-sum @ F-OUT-SUM-BASE
    accum-ret-discnt @ F-RET-DISCNT-BASE
    accum-ret-qnty @ F-RET-QNTY
    accum-ret-sum @ F-RET-SUM-BASE
    with frame Dialog-Frame.
END PROCEDURE.
FUNCTION get-ext-artic RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds ) :
    find first buf-goods no-lock
        where buf-goods.prod-type = loc-cli-gds.prod-type
        and buf-goods.prod-code = loc-cli-gds.prod-code
        and buf-goods.artic = loc-cli-gds.artic
        no-error.
    if not avail buf-goods then return "".
    find first ub.ext-artic no-lock
        where ub.ext-artic.cli-type = loc-cli-gds.cli-type
        and ub.ext-artic.cli-code = loc-cli-gds.cli-code
        and ub.ext-artic.gds-code = buf-goods.gds-code
        no-error.
    if avail ub.ext-artic then
        return ub.ext-artic.ext-artic.
    else
        return "".
END FUNCTION.
FUNCTION get-cli-name RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds ) :
    define variable dop like ub.clients.obj-name.
    FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = loc-cli-gds.cli-type AND
                                     ub.clients.obj-code = loc-cli-gds.cli-code
    No-ERROR.
    IF avail ub.clients then dop = ub.clients.obj-name.
    ELSE dop = "".
  RETURN dop.
END FUNCTION.
FUNCTION get-gds-name RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds ) :
    define variable dop like ub.goods.gds-name.
    FIND FIRST ub.goods NO-LOCK WHERE ub.goods.prod-type = loc-cli-gds.prod-type AND
                                   ub.goods.prod-code = loc-cli-gds.prod-code AND
                                   ub.goods.artic = loc-cli-gds.artic
    No-ERROR.
    IF avail ub.goods then dop = ub.goods.gds-name.
    ELSE dop = "".
  RETURN dop.
END FUNCTION.
FUNCTION Get-last-curr-code RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds ) :
    define variable dop like ub.currency.curr-abbr.
    FIND FIRST ub.currency NO-LOCK WHERE ub.currency.curr-code = loc-cli-gds.exch-code
    No-ERROR.
    IF avail ub.currency then dop = ub.currency.curr-abbr.
    ELSE dop = "".
  RETURN dop.
END FUNCTION.
FUNCTION get-unit-base RETURNS CHARACTER
  (buffer loc-cli-gds for sb-cli-gds ) :
    define variable dop like ub.goods.gds-name.
    FIND FIRST ub.goods NO-LOCK WHERE ub.goods.prod-type = loc-cli-gds.prod-type AND
                                   ub.goods.prod-code = loc-cli-gds.prod-code AND
                                   ub.goods.artic = loc-cli-gds.artic
    No-ERROR.
    IF avail ub.goods then dop = ub.goods.unit-base.
    ELSE dop = "".
  RETURN dop.
END FUNCTION.
