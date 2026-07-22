DEFINE BUFFER find_fin-schet FOR ub.fin-schet.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_currency FOR ub.currency.
DEFINE BUFFER X_fin-bank FOR ub.fin-bank.
DEFINE BUFFER X_fin-schet FOR ub.fin-schet.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter bttns  as char   no-undo .
define input parameter p-mode  as char   no-undo .
define input parameter p-cli-type like ub.clients.obj-type no-undo.
define input parameter p-cli-code like ub.clients.obj-code no-undo.
define input parameter p-curr-code like ub.currency.curr-code no-undo.
define input parameter p-host-code like ub.fin-schet.host-code no-undo .
define input parameter p-code-bank like ub.fin-schet.code-bank no-undo.
define input-output parameter p-status_ like ub.fin-bank.status_ no-undo .
define input-output param p-rid-list    as  char no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список банковских счетов":U.
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
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
define variable filter-point as character no-undo init "finschts" .
define variable filter-point0 as character no-undo init "finschts" .
define variable filter-label as character no-undo init "Список банковских счетов" .
define variable filter-label0 as character no-undo init "Список банковских счетов" .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
define variable vipiska-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define buffer X_curr_sysconf for ub.sysconf.
define buffer X_clients-host for ub.clients.
define buffer pos_fin-schet for ub.fin-schet.
FUNCTION get-bank-short-name RETURNS CHARACTER
  ( BUFFER loc-fin-schet FOR ub.fin-schet )  FORWARD.
FUNCTION get-cli-name RETURNS CHARACTER
 ( BUFFER loc-fin-schet FOR ub.fin-schet )  FORWARD.
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-fin-schet FOR ub.fin-schet )  FORWARD.
DEFINE MENU MENU-B-print
       MENU-ITEM m_one          LABEL "Один"
       MENU-ITEM m_list         LABEL "Список"        .
DEFINE MENU MENU-B-vipiska
       MENU-ITEM m_statement    LABEL "Документы выписки"
       MENU-ITEM m_report       LABEL "Отчет в виде выписки".
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-bank
     LABEL "&Банк"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-copy
     LABEL "&Копия"
     SIZE 10 BY 1 TOOLTIP "Скопировать в другие фирмы".
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-vipiska
     LABEL "В&ыписка"
     SIZE 10 BY 1.
DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sch-c-schet AS CHARACTER FORMAT "X(20)":U
     LABEL "Корр.счету"
     VIEW-AS FILL-IN
     SIZE 22 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-cli-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "коду держателя"
     VIEW-AS FILL-IN
     SIZE 11 BY .92 NO-UNDO.
DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "коду"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-r-schet AS CHARACTER FORMAT "X(20)":U
     LABEL "Расч.счету"
     VIEW-AS FILL-IN
     SIZE 22 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE RS-cli-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 1", "2"
     SIZE 19.38 BY 1.04 NO-UNDO.
DEFINE VARIABLE RS-status_ AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 33.5 BY 1 NO-UNDO.
DEFINE QUERY br-schet FOR
      X_fin-schet SCROLLING.
DEFINE BROWSE br-schet
  QUERY br-schet DISPLAY
      mark-string(recid(X_fin-schet), v-rid-list) FORMAT "X(1)":U
      X_fin-schet.host-code COLUMN-LABEL "Код!фирмы" FORMAT ">>>>>99999":U
      X_fin-schet.code-schet COLUMN-LABEL "Код счета" FORMAT "9999999":U
      X_fin-schet.code-bank COLUMN-LABEL "Код!банка" FORMAT "9999999":U
      get-bank-short-name(buffer X_fin-schet) COLUMN-LABEL "Название банка" FORMAT "X(20)":U
      X_fin-schet.status_ FORMAT "X(8)":U
      X_fin-schet.cli-type + string(X_fin-schet.cli-code) COLUMN-LABEL "Держатель!счета" FORMAT "X(12)":U
      get-cli-name(buffer X_fin-schet) COLUMN-LABEL "Название держателя счета" FORMAT "X(20)":U
      X_fin-schet.r-schet FORMAT "X(20)":U
      X_fin-schet.c-schet FORMAT "X(20)":U
      get-currency(buffer X_fin-schet) COLUMN-LABEL "Вал" FORMAT "X(3)":U
  ENABLE
      X_fin-schet.status_
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 13.33.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 31
     b-lkp AT ROW 1 COL 41
     B-chg AT ROW 1 COL 51
     B-del AT ROW 1 COL 61
     B-vipiska AT ROW 1 COL 71
     B-print AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-bank AT ROW 2 COL 51
     B-copy AT ROW 2 COL 61
     RS-status_ AT ROW 3 COL 1.5 NO-LABEL
     br-schet AT ROW 4.25 COL 1.38
     ED-notes AT ROW 17.71 COL 1 NO-LABEL
     sch-code AT ROW 19.79 COL 16.38 COLON-ALIGNED
     sch-c-schet AT ROW 19.79 COL 36.75 COLON-ALIGNED
     sch-r-schet AT ROW 19.79 COL 71.25 COLON-ALIGNED
     RS-cli-type AT ROW 20.88 COL 30.5 NO-LABEL
     B-cli AT ROW 20.96 COL 50.75
     sch-cli-code AT ROW 21 COL 16.38 COLON-ALIGNED
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.25 BY 1 AT ROW 19.79 COL 1.5
          FGCOLOR 4
     SPACE(88.49) SKIP(1.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список банковских счетов"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.
ASSIGN
       B-vipiska:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-vipiska:HANDLE.
ASSIGN
       br-schet:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-bank-accounts_add-def':U
    ,input  'firm':U
    ,input  p-curr-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
if not loc#log then return no-apply.
run ref/finschti.w
              (
                 input parParentProc
                ,input p-curr-host-code
                ,input 'ДОБАВЛЕНИЕ':U
                ,input p-curr-host-code
                ,input 0
                ,input (if p-mode = "bank":U
                        then p-code-bank
                        else 0)
                ,input (if p-mode = 'орг':U
                        or p-mode = "cmp-host":U
                        then p-cli-type
                        else "":U)
                ,input (if p-mode = 'орг':U
                        or p-mode = "cmp-host":U
                        then p-cli-code
                        else 0)
                ,input (if p-mode = "currency":U
                        then p-curr-code
                        else 0)
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input yes, input no, input no).
  reposition br-schet to recid loc-doc-rec no-error.
  if error-status:error then do:                           find first pos_fin-schet no-lock where                                   recid(pos_fin-schet) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи БАНКОВСКИЙ СЧЕТ" skip                            string(if avail pos_fin-schet                                     then  substitute("Код фирмы: &1, вн. код счета &2"                                                     , pos_fin-schet.host-code                                                      , pos_fin-schet.code-schet)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
end.
apply "entry" to br-schet in frame Dialog-Frame.
apply "value-changed" to br-schet in frame Dialog-Frame.
END.
ON CHOOSE OF B-bank IN FRAME Dialog-Frame
DO:
define variable loc-doc-rec as recid no-undo .
if not available X_fin-schet then return no-apply.
run ref/finbanki.w
              (
                 input parParentProc
                ,input p-curr-host-code
                ,input 'ПРОСМОТР':U
                ,input X_fin-schet.host-code
                ,input X_fin-schet.code-bank
                ,input-output loc-doc-rec
                            )
.
apply "entry" to br-schet in frame Dialog-Frame.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_fin-schet then return no-apply.
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-bank-accounts_add-def':U
    ,input  'firm':U
    ,input  p-curr-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
if not loc#log then return no-apply.
assign
loc-doc-rec = recid(X_fin-schet).
run ref/finschti.w
              (
                 input parParentProc
                ,input p-curr-host-code
                ,input 'ИЗМЕНЕНИЕ':U
                ,input X_fin-schet.host-code
                ,input X_fin-schet.code-schet
                ,input X_fin-schet.code-bank
                ,input X_fin-schet.cli-type
                ,input X_fin-schet.cli-code
                ,input X_fin-schet.curr-code
                ,input-output loc-doc-rec
                            )  no-error
.
if loc-doc-rec <> ? then do:
  reposition br-schet to recid loc-doc-rec no-error.
  if error-status:error then do:                           find first pos_fin-schet no-lock where                                   recid(pos_fin-schet) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи БАНКОВСКИЙ СЧЕТ" skip                            string(if avail pos_fin-schet                                     then  substitute("Код фирмы: &1, вн. код счета &2"                                                     , pos_fin-schet.host-code                                                      , pos_fin-schet.code-schet)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
end.
apply "entry" to br-schet in frame Dialog-Frame.
apply "value-changed" to br-schet in frame Dialog-Frame.
END.
ON CHOOSE OF B-cli IN FRAME Dialog-Frame
DO:
define variable ref-list as character no-undo.
define variable ref-rec as recid no-undo.
define buffer buf_clients for ub.clients.
  run ref/cli-all.w (
                   input parParentProc
                  ,input "b-sel"
                  ,input RS-cli-type
                  ,input ?
                  ,input ?
                  ,input ?
                  ,input ?
                  ,input "without-obj":U
                  ,output ref-list) .
    if ref-list = "" then   do:
      apply "entry" to b-cli in frame Dialog-Frame.
      return no-apply.
     end.
    ref-rec = integer( ref-list ).
    FIND FIRST buf_clients WHERE recid (buf_clients) = ref-rec NO-LOCK .
    if NOT (buf_clients.obj-type = 'орг':U
            or
            buf_clients.obj-type = 'чел':U ) then do:
      message
      "Выберите контрагента типа" 'орг':U "или" 'чел':U
      view-as alert-box error .
      return no-apply.
    end.
    assign
    RS-cli-type =  buf_clients.obj-type
    sch-cli-code = buf_clients.obj-code
    .
    display
    RS-cli-type
    sch-cli-code
    with frame Dialog-Frame.
apply "return":u to sch-cli-code in frame Dialog-Frame .
END.
ON CHOOSE OF B-copy IN FRAME Dialog-Frame
DO:
  run proc-copy in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if NOT available X_fin-schet then do:
    message
    "Неправильно выбран банк."
    view-as alert-box ERROR.
    return no-apply.
  end.
  loc-doc-rec = recid (X_fin-schet).
  .
  run ref/fincscts.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input "":U
                ,input "one":U
                ,input X_fin-schet.host-code
                ,input X_fin-schet.cli-type
                ,input X_fin-schet.cli-code
                ,input X_fin-schet.curr-code
                ,input X_fin-schet.code-bank
                ,input X_fin-schet.code-schet
                ,input-output v-rid-list
                              )
  .
  reposition br-schet to recid loc-doc-rec no-error.
  apply "entry" to br-schet in frame Dialog-Frame.
  apply "value-changed" to br-schet in frame Dialog-Frame.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
define variable loc-doc-rec as recid no-undo .
  if NOT available X_fin-schet then do:
    message
    "Неправильно выбран банк."
    view-as alert-box ERROR.
    return no-apply.
  end.
  loc-doc-rec = recid (X_fin-schet).
  .
  run ref/finschti.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input 'ПРОСМОТР':U
                ,input X_fin-schet.host-code
                ,input X_fin-schet.code-schet
                ,input X_fin-schet.code-bank
                ,input X_fin-schet.cli-type
                ,input X_fin-schet.cli-code
                ,input X_fin-schet.curr-code
                ,input-output loc-doc-rec
                              )
  .
  reposition br-schet to recid loc-doc-rec no-error.
  apply "entry" to br-schet in frame Dialog-Frame.
  apply "value-changed" to br-schet in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
  if available X_fin-schet then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid14 as character no-undo .
define variable v-num-entry14 as integer   no-undo .
assign
  v-str-recid14 = trim( string( recid( X_fin-schet ) , "->>>>>>>>>>>9":U ) )
  v-num-entry14 = lookup( v-str-recid14 , v-rid-list )
.
if v-num-entry14 > 0 then do:
  assign
    entry( v-num-entry14, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid14
  .
end.
    loc#log = br-schet:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-schet:select-next-row ().
        apply "VALUE-CHANGED" to br-schet in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-schet in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  if not avail X_fin-schet then return no-apply.
  if print-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if print-option = '':U then return no-apply.
  run proc-b-print in this-procedure ( input print-option) no-error.
  if error-status:error then do:
    print-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-schet.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
      run gbl/markqwa.p (
                 input b-mark:sensitive
               , input v-rid-list) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if ( available X_fin-schet ) then dO:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then  v-rid-list = string( recid( X_fin-schet ) ) .
  end.
END.
ON CHOOSE OF B-vipiska IN FRAME Dialog-Frame
DO:
  if not avail X_fin-schet then return no-apply.
 if vipiska-option = '':U then do:
        run gbl/pop-up.p ( INPUT self:handle, INPUT no) no-error.
  end.
  if vipiska-option = '':U then return no-apply.
  RUN proc-b-vipiska IN THIS-PROCEDURE ( INPUT vipiska-option ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      vipiska-option = '':U.
      RETURN NO-APPLY.
  END.
  vipiska-option = '':U.
  APPLY "ENTRY" to br-schet.
END.
ON RETURN OF br-schet IN FRAME Dialog-Frame
DO:
   run proc-br-schet in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF br-schet IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE dops as character no-undo .
  dops = if available X_fin-schet then X_fin-schet.ps else '':U.
  ED-notes:screen-value = dops.
  if not available X_fin-schet
  or not (X_fin-schet.cli-type = 'орг':U
         and
         X_fin-schet.cli-code = X_fin-schet.host-code) then do:
    assign
    menu-item m_statement:sensitive in menu menu-b-vipiska  = no.
  end.
  else do:
    assign
    menu-item m_statement:sensitive in menu menu-b-vipiska  = yes.
  end.
END.
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
  define buffer ps_fin-schet for ub.fin-schet.
  if not available X_fin-schet then return no-apply.
   DO on stop undo, return no-apply:
      FIND PS_fin-schet where
           recid (ps_fin-schet) = recid(X_fin-schet) exclusive.
      if ps_fin-schet.PS <> input frame Dialog-Frame ed-notes then
      assign
      ps_fin-schet.PS = input frame Dialog-Frame ed-notes
      .
   END.
END.
ON CHOOSE OF MENU-ITEM m_list
DO:
   assign
  print-option = 'LIST':U.
  APPLY "CHOOSE" to b-print  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_one
DO:
   assign
  print-option = 'ONE':U.
  APPLY "CHOOSE" to b-print  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_report
DO:
   assign
  vipiska-option = 'report':U.
  APPLY "CHOOSE" to b-vipiska  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_statement
DO:
   assign
  vipiska-option = 'statement':U.
  APPLY "CHOOSE" to b-vipiska  in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF RS-cli-type IN FRAME Dialog-Frame
DO:
  assign
  RS-cli-type.
  run proc-find-cli-code in this-procedure ( input yes, input frame Dialog-Frame sch-cli-code) no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF RS-status_ IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-status_
  p-status_ = rs-status_
  .
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input NO) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON CTRL-J OF sch-c-schet IN FRAME Dialog-Frame
DO:
  run proc-find-c-schet in this-procedure ( input yes, input frame Dialog-Frame sch-c-schet) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-c-schet IN FRAME Dialog-Frame
DO:
  run proc-find-c-schet in this-procedure ( input no, input frame Dialog-Frame sch-c-schet) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-cli-code IN FRAME Dialog-Frame
DO:
  run proc-find-cli-code in this-procedure ( input yes, input frame Dialog-Frame sch-cli-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-cli-code IN FRAME Dialog-Frame
DO:
  run proc-find-cli-code in this-procedure ( input yes, input frame Dialog-Frame sch-cli-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure ( input yes, input frame Dialog-Frame sch-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure ( input no, input frame Dialog-Frame sch-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-r-schet IN FRAME Dialog-Frame
DO:
  run proc-find-r-schet in this-procedure ( input yes, input frame Dialog-Frame sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-r-schet IN FRAME Dialog-Frame
DO:
  run proc-find-r-schet in this-procedure ( input no, input frame Dialog-Frame sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-schet :handle
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
def var sort-labelbr-schet   as character no-undo .
def var sort-clmnbr-schet    as handle    no-undo .
def var cur-clmnbr-schet     as handle    no-undo .
def var cur-clmn-locbr-schet as integer   no-undo .
def var re-querybr-schet     as logical   initial no no-undo .
on start-search, ctrl-o of br-schet in frame Dialog-Frame do:
   run sort-brbr-schet
     (input (if available X_fin-schet
             then recid(X_fin-schet)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-schet :
  define input parameter p-recid as recid no-undo .
  if re-querybr-schet = no then do:
    assign
       cur-clmnbr-schet = br-schet:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-schet <> ? then sort-clmnbr-schet:column-fgcolor = 0.
    if cur-clmnbr-schet = sort-clmnbr-schet then do:
      assign
         sort-labelbr-schet = ""
         sort-clmnbr-schet = ?
      .
     end.
     else do:
       assign
         sort-labelbr-schet = cur-clmnbr-schet:label
         sort-clmnbr-schet  = cur-clmnbr-schet
         sort-clmnbr-schet:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-schet = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-schet:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-schet then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-schet = cur-clmn-locbr-schet + 1
    .
  end.
  case sort-labelbr-schet:
        when X_fin-schet.code-schet:label in browse br-schet then DO:    assign       sort-column-name = "X_fin-schet.code-schet"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when X_fin-schet.code-bank:label in browse br-schet then DO:    assign       sort-column-name = "X_fin-schet.code-bank"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when X_fin-schet.r-schet:label in browse br-schet then DO:    assign       sort-column-name = "X_fin-schet.r-schet"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input no).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-schet') then do:
          run mv-brw-defaultbr-schet.
        end.
      if sort-labelbr-schet <> "" then do:
        assign
          cur-clmnbr-schet:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-schet = ?
      .
    end.
  end case.
    if cur-clmn-locbr-schet <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-schet') then do:
        run ch-clmnbr-schet in this-procedure (cur-clmn-locbr-schet).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-schet to recid p-recid no-error.
    apply "value-changed" to br-schet in frame Dialog-Frame.
  end.
  apply "entry" to br-schet in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-schet:
if cur-clmnbr-schet = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input no).
end.
else do:
   assign re-querybr-schet = yes.
   run sort-brbr-schet
     (input (if available X_fin-schet
             then recid(X_fin-schet)
             else ?
            )
     ).
   assign re-querybr-schet = no.
end.
end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-schet :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  v-doc-rec = recid(X_fin-schet). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-schet to recid v-doc-rec no-error. v-doc-rec = ?.
    apply "VALUE-CHANGED" to br-schet.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 if LOOKUP(p-mode, ('все':U + chr(44) +
                    'фирма':U + chr(44) +
                    'орг':U  + chr(44) +
                    "currency":U + chr(44) + "bank":U) + chr(44) +
                    "cmp-host":U + chr(44) + "company-host":U) = 0 then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
find first X_curr_sysconf no-lock where
                X_curr_sysconf.host-code = p-curr-host-code no-error.
if not available X_curr_sysconf then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра вызова p-curr-host-code"
  p-mode p-curr-host-code
  view-as alert-box ERROR.
  return.
end.
 if p-mode = 'фирма':U or p-mode = "cmp-host":U or p-mode = "company-host":U then do:
  find first X_sysconf no-lock where
                  X_sysconf.host-code = p-curr-host-code no-error.
  find first X_clients-host no-lock where
                X_clients-host.obj-type = 'орг':U
            and X_clients-host.obj-code = p-curr-host-code no-error.
    if not available X_clients-host then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-host-code"
        p-host-code
        view-as alert-box ERROR.
        return.
    end.
  end.
 if p-mode = 'орг':U or p-mode = "cmp-host":U then do:
  find first X_clients no-lock where
                X_clients.obj-type = p-cli-type
            and X_clients.obj-code = p-cli-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-cli-type и/или p-cli-code" p-cli-type p-cli-code
        view-as alert-box ERROR.
        return.
    end.
  end.
 if p-mode = "bank":U then do:
  find first X_fin-bank no-lock where
                X_fin-bank.host-code = p-host-code
            and X_fin-bank.code-bank = p-code-bank no-error.
    if not available X_fin-bank then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-host-code и/или p-code-bank" p-host-code p-code-bank
        view-as alert-box ERROR.
        return.
    end.
  end.
 if p-mode = "currency":U then do:
  find first X_currency no-lock where
                X_currency.curr-code = p-curr-code no-error.
    if not available X_currency then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-curr-code" p-curr-code
        view-as alert-box ERROR.
        return.
    end.
  end.
  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_fin-schet No-LOCK where
                 recid(find_fin-schet) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_fin-schet then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
  RUN MyEnable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame Dialog-Frame .
  if v-rid-list <> "":U then
  REPOSITION br-schet to recid integer(entry(1, v-rid-list)) No-ERROR.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-schet as INT EXTENT 11 no-undo.
DEF VAR varmvibr-schet       as INT no-undo.
DEF VAR varmvjbr-schet       as INT no-undo.
DEF VAR varmvkbr-schet       as INT no-undo.
DEF VAR varmvlbr-schet       as INT no-undo.
DEF VAR move-elementbr-schet as INT no-undo.
def var jjbr-schet           as int no-undo.
do varmvibr-schet = 1 to EXTENT(cur-clmn-numbr-schet):
  ASSIGN cur-clmn-numbr-schet[varmvibr-schet] = varmvibr-schet.
END.
RUN start-mv-clmnbr-schet.
PROCEDURE start-mv-clmnbr-schet:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  p-mode = 'все':U  THEN DO:
   DO jjbr-schet = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10,11') TO 1 BY -1:
     RUN re-move-clmnbr-schet ( cur-clmn-numbr-schet[INTEGER(ENTRY (jjbr-schet, '1,2,3,4,5,6,7,8,9,10,11'))] , 1).
   END.
       END.
       IF  p-mode = 'фирма':U  THEN DO:
   DO jjbr-schet = NUM-ENTRIES('1,3,4,5,6,7,8,9,10,11,2') TO 1 BY -1:
     RUN re-move-clmnbr-schet ( cur-clmn-numbr-schet[INTEGER(ENTRY (jjbr-schet, '1,3,4,5,6,7,8,9,10,11,2'))] , 1).
   END.
       END.
       IF  p-mode = 'орг':U  THEN DO:
   DO jjbr-schet = NUM-ENTRIES('1,2,3,4,5,6,8,9,10,11,7') TO 1 BY -1:
     RUN re-move-clmnbr-schet ( cur-clmn-numbr-schet[INTEGER(ENTRY (jjbr-schet, '1,2,3,4,5,6,8,9,10,11,7'))] , 1).
   END.
       END.
       IF  p-mode = 'currency':U  THEN DO:
   DO jjbr-schet = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10,11') TO 1 BY -1:
     RUN re-move-clmnbr-schet ( cur-clmn-numbr-schet[INTEGER(ENTRY (jjbr-schet, '1,2,3,4,5,6,7,8,9,10,11'))] , 1).
   END.
       END.
       IF  p-mode = 'bank':U  THEN DO:
   DO jjbr-schet = NUM-ENTRIES('1,2,3,5,6,7,8,9,10,11,4') TO 1 BY -1:
     RUN re-move-clmnbr-schet ( cur-clmn-numbr-schet[INTEGER(ENTRY (jjbr-schet, '1,2,3,5,6,7,8,9,10,11,4'))] , 1).
   END.
       END.
       IF  p-mode = 'cmp-host':U  or p-mode = 'company-host':U  THEN DO:
   DO jjbr-schet = NUM-ENTRIES('1,3,4,5,6,8,9,10,11,7,2') TO 1 BY -1:
     RUN re-move-clmnbr-schet ( cur-clmn-numbr-schet[INTEGER(ENTRY (jjbr-schet, '1,3,4,5,6,8,9,10,11,7,2'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-schet do:
  RUN re-move-clmnbr-schet ( 1, 11).
END.
ON ctrl-cursor-left OF BROWSE br-schet do:
  RUN re-move-clmnbr-schet (11, 1).
END.
PROCEDURE re-move-clmnbr-schet:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-schet = 1 TO EXTENT(cur-clmn-numbr-schet):
    if cur-clmn-numbr-schet[varmvibr-schet] = source-column THEN cur-clmn-numbr-schet[varmvibr-schet] = -1.
  END.
  if br-schet:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-schet = source-column - 1 to target-column BY -1:
    DO varmvibr-schet = 1 TO EXTENT(cur-clmn-numbr-schet):
        if cur-clmn-numbr-schet[varmvibr-schet] = varmvjbr-schet THEN DO:
          cur-clmn-numbr-schet[varmvibr-schet] = cur-clmn-numbr-schet[varmvibr-schet] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-schet = source-column + 1 to target-column:
    DO varmvibr-schet = 1 TO EXTENT(cur-clmn-numbr-schet):
      if cur-clmn-numbr-schet[varmvibr-schet] = varmvjbr-schet THEN DO:
        cur-clmn-numbr-schet[varmvibr-schet] = cur-clmn-numbr-schet[varmvibr-schet] - 1.
      END.
    END.
  END.
  DO varmvibr-schet = 1 TO EXTENT(cur-clmn-numbr-schet):
    if cur-clmn-numbr-schet[varmvibr-schet] = -1 THEN cur-clmn-numbr-schet[varmvibr-schet] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-schet:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-schet = 1 TO EXTENT(cur-clmn-numbr-schet):
    if cur-clmn-numbr-schet[varmvibr-schet] = cur-clmn-loc THEN move-elementbr-schet = varmvibr-schet.
  END.
  RUN re-move-clmnbr-schet (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-schet:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-schet = 1 to EXTENT(cur-clmn-numbr-schet):
    RUN re-move-clmnbr-schet (cur-clmn-numbr-schet[varmvlbr-schet], varmvlbr-schet).
  END.
  RUN start-mv-clmnbr-schet.
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
  DISPLAY RS-status_ ED-notes sch-code sch-c-schet sch-r-schet RS-cli-type
          sch-cli-code mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-add b-lkp B-chg B-del B-vipiska B-print B-hist
         B-sch B-Help B-bank B-copy RS-status_ br-schet ED-notes sch-code
         sch-c-schet sch-r-schet RS-cli-type B-cli sch-cli-code mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
assign
b-print:MENU-MOUSE in frame Dialog-Frame = 1
br-schet:num-locked-columns = 1
X_fin-schet.status_:read-only in browse br-schet = yes
RS-cli-type:radio-buttons = 'орг':U + chr(44) + 'орг':U + chr(44) + 'чел':U + chr(44) + 'чел':U
rs-status_:RADIO-BUTTONS IN FRAME Dialog-Frame
                      = "Текущие&+" + chr(44) +  'тек':U + chr(44) +
                      "Все&!" + chr(44) + 'все':U + chr(44) +
                      "Удаленные&-" + chr(44) + 'удал':U
rs-status_ = p-status_
b-vipiska:menu-mouse = 1
.
DISPLAY
ED-notes
sch-code
sch-c-schet
sch-r-schet
sch-cli-code
mark-num
RS-cli-type
RS-status_
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark when lookup("b-mark":U, bttns) > 0
B-add when ((p-mode = 'фирма':U or p-mode = "cmp-host":U or p-mode = "company-host":U)
            AND X_sysconf.firm-db-num = v-db-num
            AND lookup("b-add":U, bttns) > 0 and not transaction
            )
b-sel when lookup("b-sel":U, bttns) > 0
B-copy when ((p-mode = 'фирма':U or p-mode = "cmp-host":U or p-mode = "company-host":U)
            AND X_sysconf.firm-db-num = v-db-num
            AND lookup("b-copy":U, bttns) > 0 and not transaction
            )
b-lkp
B-chg when ((p-mode = 'фирма':U or p-mode = "cmp-host":U or p-mode = "company-host":U)
            AND X_sysconf.firm-db-num = v-db-num
            AND lookup("b-add":U, bttns) > 0  and not transaction
            )
B-del when ((p-mode = 'фирма':U or p-mode = "cmp-host":U or p-mode = "company-host":U)
            AND X_sysconf.firm-db-num = v-db-num
            AND lookup("b-add":U, bttns) > 0  and not transaction
            )
B-sch
b-cli
B-print
b-vipiska
b-bank
B-Help
b-hist
br-schet
ED-notes
sch-code
sch-cli-code
sch-c-schet
sch-r-schet
RS-cli-type
mark-num
RS-status_
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
APPLY "VALUE-changed" to RS-cli-type.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список банковских счетов" + chr(32).
run waitfram-show in this-procedure ( input "Ждите...").
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
define variable l-open-query as logical   no-undo .
  CASE p-mode :
    WHEN 'все':U        THEN DO:
      ASSIGN
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1", filter-label0)
      .
      if p-open-query then do:
        assign
        frame Dialog-Frame:TITLE = title0 + chr(32)  + (if p-status_ = 'все':U then "":U else p-status_)
          .
      end.
      IF p-status_ = 'все':U THEN DO:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-33  as logical   no-undo .
define variable  l-filter-open-33    as logical   .
define variable  flt-rec-33       as recid     no-undo .
define variable  filter-name-33      as character no-undo .
define variable  where-phrase-33     as character no-undo .
define variable  sort-phrase-33      as character no-undo .
define variable  where-phrase-rus-33 as character no-undo .
define variable  sort-phrase-rus-33  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-33
  ,output filter-name-33
  ,output where-phrase-33
  ,output sort-phrase-33
  ,output where-phrase-rus-33
  ,output sort-phrase-rus-33
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-33
      ) no-error .
  assign
    l-filter-open-33 = false
  .
  if flt-rec-33 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-33 as character no-undo .
    define variable  parameter-3-33 as character no-undo .
    define variable  parameter-4-33 as character no-undo .
    define variable  parameter-5-33 as character no-undo .
    define variable  parameter-6-33 as character no-undo .
    define variable  parameter-7-33 as character no-undo .
      assign
      parameter-3-33 =
                              "FOR EACH X_fin-schet"
      parameter-4-33 =
        (
          if (" TRUE " + " " + where-phrase-33) <> ""
          then " TRUE " + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "")
      parameter-6-33 = if sort-phrase-33 = ''
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
        " " + sort-phrase-33
        )
      parameter-7-33 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-33 =
          (" TRUE " + " " + where-phrase-33 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
                          )
      .
      assign
        l-filter-open-33 = true
      .
    end.
    if l-filter-open-33 = false then do:
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
  if l-filter-open-33 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where  TRUE
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-4-33 =
        "where ":u + " TRUE " + " ":u + where-phrase-33 + " ":u + p-find-condition + " " + ""
      parameter-5-33 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-3-33 =  "FOR EACH X_fin-schet"
      parameter-4-33 =
        (
          if (" TRUE " + " " + where-phrase-33) <> ""
          then " TRUE " + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-33 = if sort-phrase-33 = ''
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
        " " + sort-phrase-33
        )
      parameter-7-33 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      END.
      ELSE DO:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-35  as logical   no-undo .
define variable  l-filter-open-35    as logical   .
define variable  flt-rec-35       as recid     no-undo .
define variable  filter-name-35      as character no-undo .
define variable  where-phrase-35     as character no-undo .
define variable  sort-phrase-35      as character no-undo .
define variable  where-phrase-rus-35 as character no-undo .
define variable  sort-phrase-rus-35  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-35
  ,output filter-name-35
  ,output where-phrase-35
  ,output sort-phrase-35
  ,output where-phrase-rus-35
  ,output sort-phrase-rus-35
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-35
      ) no-error .
  assign
    l-filter-open-35 = false
  .
  if flt-rec-35 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-35 as character no-undo .
    define variable  parameter-3-35 as character no-undo .
    define variable  parameter-4-35 as character no-undo .
    define variable  parameter-5-35 as character no-undo .
    define variable  parameter-6-35 as character no-undo .
    define variable  parameter-7-35 as character no-undo .
      assign
      parameter-3-35 =
                              "FOR EACH X_fin-schet"
      parameter-4-35 =
        (
          if (" X_fin-schet.status_ = p-status_ " + " " + where-phrase-35) <> ""
          then  substitute('X_fin-schet.status_ = &1&2&1', chr(34), p-status_)  + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "")
      parameter-6-35 = if sort-phrase-35 = ''
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
        " " + sort-phrase-35
        )
      parameter-7-35 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-35 =
          (" X_fin-schet.status_ = p-status_ " + " " + where-phrase-35 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
                          )
      .
      assign
        l-filter-open-35 = true
      .
    end.
    if l-filter-open-35 = false then do:
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
  if l-filter-open-35 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where  X_fin-schet.status_ = p-status_
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-4-35 =
        "where ":u +  substitute('X_fin-schet.status_ = &1&2&1', chr(34), p-status_)  + " ":u + where-phrase-35 + " ":u + p-find-condition + " " + ""
      parameter-5-35 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-3-35 =  "FOR EACH X_fin-schet"
      parameter-4-35 =
        (
          if (" X_fin-schet.status_ = p-status_ " + " " + where-phrase-35) <> ""
          then  substitute('X_fin-schet.status_ = &1&2&1', chr(34), p-status_)  + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-35 = if sort-phrase-35 = ''
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
        " " + sort-phrase-35
        )
      parameter-7-35 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      END.
    END.
    WHEN 'фирма':U THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Одна фирма", filter-label0)
      .
      if p-open-query then do:
       assign
       frame Dialog-Frame:TITLE = title0 +
                                   substitute(" Фирма: (&1) &2",
                                   p-host-code, X_clients-host.obj-name) +
                                   chr(32)  + (if p-status_ = 'все':U then "":U else p-status_)
       .
      end.
        IF p-status_ = 'все':U  THEN DO:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-37  as logical   no-undo .
define variable  l-filter-open-37    as logical   .
define variable  flt-rec-37       as recid     no-undo .
define variable  filter-name-37      as character no-undo .
define variable  where-phrase-37     as character no-undo .
define variable  sort-phrase-37      as character no-undo .
define variable  where-phrase-rus-37 as character no-undo .
define variable  sort-phrase-rus-37  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-37
  ,output filter-name-37
  ,output where-phrase-37
  ,output sort-phrase-37
  ,output where-phrase-rus-37
  ,output sort-phrase-rus-37
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-37
      ) no-error .
  assign
    l-filter-open-37 = false
  .
  if flt-rec-37 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-37 as character no-undo .
    define variable  parameter-3-37 as character no-undo .
    define variable  parameter-4-37 as character no-undo .
    define variable  parameter-5-37 as character no-undo .
    define variable  parameter-6-37 as character no-undo .
    define variable  parameter-7-37 as character no-undo .
      assign
      parameter-3-37 =
                              "FOR EACH X_fin-schet"
      parameter-4-37 =
        (
          if ("                 X_fin-schet.host-code  = p-host-code                                " + " " + where-phrase-37) <> ""
          then  substitute(' X_fin-schet.host-code  = &1', p-host-code) + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + "")
      parameter-6-37 = if sort-phrase-37 = ''
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
        " " + sort-phrase-37
        )
      parameter-7-37 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-37 =
          ("                 X_fin-schet.host-code  = p-host-code                                " + " " + where-phrase-37 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
                          )
      .
      assign
        l-filter-open-37 = true
      .
    end.
    if l-filter-open-37 = false then do:
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
  if l-filter-open-37 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where                  X_fin-schet.host-code  = p-host-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-4-37 =
        "where ":u +  substitute(' X_fin-schet.host-code  = &1', p-host-code) + " ":u + where-phrase-37 + " ":u + p-find-condition + " " + ""
      parameter-5-37 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-3-37 =  "FOR EACH X_fin-schet"
      parameter-4-37 =
        (
          if ("                 X_fin-schet.host-code  = p-host-code                                " + " " + where-phrase-37) <> ""
          then  substitute(' X_fin-schet.host-code  = &1', p-host-code) + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-37 = if sort-phrase-37 = ''
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
        " " + sort-phrase-37
        )
      parameter-7-37 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        END.
        ELSE DO:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-39  as logical   no-undo .
define variable  l-filter-open-39    as logical   .
define variable  flt-rec-39       as recid     no-undo .
define variable  filter-name-39      as character no-undo .
define variable  where-phrase-39     as character no-undo .
define variable  sort-phrase-39      as character no-undo .
define variable  where-phrase-rus-39 as character no-undo .
define variable  sort-phrase-rus-39  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-39
  ,output filter-name-39
  ,output where-phrase-39
  ,output sort-phrase-39
  ,output where-phrase-rus-39
  ,output sort-phrase-rus-39
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-39
      ) no-error .
  assign
    l-filter-open-39 = false
  .
  if flt-rec-39 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-39 as character no-undo .
    define variable  parameter-3-39 as character no-undo .
    define variable  parameter-4-39 as character no-undo .
    define variable  parameter-5-39 as character no-undo .
    define variable  parameter-6-39 as character no-undo .
    define variable  parameter-7-39 as character no-undo .
      assign
      parameter-3-39 =
                              "FOR EACH X_fin-schet"
      parameter-4-39 =
        (
          if ("                 X_fin-schet.host-code  = p-host-code                   AND X_fin-schet.status_ = p-status_ " + " " + where-phrase-39) <> ""
          then  substitute(' X_fin-schet.host-code  = &1                   AND X_fin-schet.status_ = &2&3&2', p-host-code, chr(34), p-status_) + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + "")
      parameter-6-39 = if sort-phrase-39 = ''
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
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-39 =
          ("                 X_fin-schet.host-code  = p-host-code                   AND X_fin-schet.status_ = p-status_ " + " " + where-phrase-39 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
                          )
      .
      assign
        l-filter-open-39 = true
      .
    end.
    if l-filter-open-39 = false then do:
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
  if l-filter-open-39 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where                  X_fin-schet.host-code  = p-host-code                   AND X_fin-schet.status_ = p-status_
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-4-39 =
        "where ":u +  substitute(' X_fin-schet.host-code  = &1                   AND X_fin-schet.status_ = &2&3&2', p-host-code, chr(34), p-status_) + " ":u + where-phrase-39 + " ":u + p-find-condition + " " + ""
      parameter-5-39 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-3-39 =  "FOR EACH X_fin-schet"
      parameter-4-39 =
        (
          if ("                 X_fin-schet.host-code  = p-host-code                   AND X_fin-schet.status_ = p-status_ " + " " + where-phrase-39) <> ""
          then  substitute(' X_fin-schet.host-code  = &1                   AND X_fin-schet.status_ = &2&3&2', p-host-code, chr(34), p-status_) + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-39 = if sort-phrase-39 = ''
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
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        END.
    END.
    WHEN 'орг':U THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Контрагент", filter-label0)
      .
      if p-open-query then do:
       assign
       frame Dialog-Frame:TITLE = title0 +
                                  substitute(" Контрагент: (&1&2) &3",
                                   X_clients.obj-type , X_clients.obj-code, X_clients.obj-name) +
                                   chr(32)  + (if p-status_ = 'все':U then "":U else p-status_)
       .
      end.
      IF p-status_ = 'все':U THEN DO:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-41  as logical   no-undo .
define variable  l-filter-open-41    as logical   .
define variable  flt-rec-41       as recid     no-undo .
define variable  filter-name-41      as character no-undo .
define variable  where-phrase-41     as character no-undo .
define variable  sort-phrase-41      as character no-undo .
define variable  where-phrase-rus-41 as character no-undo .
define variable  sort-phrase-rus-41  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-41
  ,output filter-name-41
  ,output where-phrase-41
  ,output sort-phrase-41
  ,output where-phrase-rus-41
  ,output sort-phrase-rus-41
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-41
      ) no-error .
  assign
    l-filter-open-41 = false
  .
  if flt-rec-41 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-41 as character no-undo .
    define variable  parameter-3-41 as character no-undo .
    define variable  parameter-4-41 as character no-undo .
    define variable  parameter-5-41 as character no-undo .
    define variable  parameter-6-41 as character no-undo .
    define variable  parameter-7-41 as character no-undo .
      assign
      parameter-3-41 =
                              "FOR EACH X_fin-schet"
      parameter-4-41 =
        (
          if ("                 X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                                 " + " " + where-phrase-41) <> ""
          then  substitute('X_fin-schet.cli-type  = &1&2&1 AND X_fin-schet.cli-code  = &3 '                              , chr(34), p-cli-type, p-cli-code) + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + "")
      parameter-6-41 = if sort-phrase-41 = ''
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
        " " + sort-phrase-41
        )
      parameter-7-41 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-41 =
          ("                 X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                                 " + " " + where-phrase-41 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
                          )
      .
      assign
        l-filter-open-41 = true
      .
    end.
    if l-filter-open-41 = false then do:
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
  if l-filter-open-41 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where                  X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-4-41 =
        "where ":u +  substitute('X_fin-schet.cli-type  = &1&2&1 AND X_fin-schet.cli-code  = &3 '                              , chr(34), p-cli-type, p-cli-code) + " ":u + where-phrase-41 + " ":u + p-find-condition + " " + ""
      parameter-5-41 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-3-41 =  "FOR EACH X_fin-schet"
      parameter-4-41 =
        (
          if ("                 X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                                 " + " " + where-phrase-41) <> ""
          then  substitute('X_fin-schet.cli-type  = &1&2&1 AND X_fin-schet.cli-code  = &3 '                              , chr(34), p-cli-type, p-cli-code) + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-41 = if sort-phrase-41 = ''
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
        " " + sort-phrase-41
        )
      parameter-7-41 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        END.
        ELSE DO:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-43  as logical   no-undo .
define variable  l-filter-open-43    as logical   .
define variable  flt-rec-43       as recid     no-undo .
define variable  filter-name-43      as character no-undo .
define variable  where-phrase-43     as character no-undo .
define variable  sort-phrase-43      as character no-undo .
define variable  where-phrase-rus-43 as character no-undo .
define variable  sort-phrase-rus-43  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-43
  ,output filter-name-43
  ,output where-phrase-43
  ,output sort-phrase-43
  ,output where-phrase-rus-43
  ,output sort-phrase-rus-43
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-43
      ) no-error .
  assign
    l-filter-open-43 = false
  .
  if flt-rec-43 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-43 as character no-undo .
    define variable  parameter-3-43 as character no-undo .
    define variable  parameter-4-43 as character no-undo .
    define variable  parameter-5-43 as character no-undo .
    define variable  parameter-6-43 as character no-undo .
    define variable  parameter-7-43 as character no-undo .
      assign
      parameter-3-43 =
                              "FOR EACH X_fin-schet"
      parameter-4-43 =
        (
          if ("                 X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                     AND X_fin-schet.status_ = p-status_  " + " " + where-phrase-43) <> ""
          then  substitute('X_fin-schet.cli-type  = &1&2&1 AND X_fin-schet.cli-code  = &3                 AND X_fin-schet.status_ = &1&4&1 ', chr(34), p-cli-type, p-cli-code, p-status_ ) + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + "")
      parameter-6-43 = if sort-phrase-43 = ''
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
        " " + sort-phrase-43
        )
      parameter-7-43 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-43 =
          ("                 X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                     AND X_fin-schet.status_ = p-status_  " + " " + where-phrase-43 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-43
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ,input parameter-6-43
                          ,input parameter-7-43
                          )
      .
      assign
        l-filter-open-43 = true
      .
    end.
    if l-filter-open-43 = false then do:
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
  if l-filter-open-43 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where                  X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                     AND X_fin-schet.status_ = p-status_
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-43 = (if p-find-next then "true":u else "false":u )
      parameter-4-43 =
        "where ":u +  substitute('X_fin-schet.cli-type  = &1&2&1 AND X_fin-schet.cli-code  = &3                 AND X_fin-schet.status_ = &1&4&1 ', chr(34), p-cli-type, p-cli-code, p-status_ ) + " ":u + where-phrase-43 + " ":u + p-find-condition + " " + ""
      parameter-5-43 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-43)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-43 = (if p-find-next then "true":u else "false":u )
      parameter-3-43 =  "FOR EACH X_fin-schet"
      parameter-4-43 =
        (
          if ("                 X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                     AND X_fin-schet.status_ = p-status_  " + " " + where-phrase-43) <> ""
          then  substitute('X_fin-schet.cli-type  = &1&2&1 AND X_fin-schet.cli-code  = &3                 AND X_fin-schet.status_ = &1&4&1 ', chr(34), p-cli-type, p-cli-code, p-status_ ) + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-43 = if sort-phrase-43 = ''
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
        " " + sort-phrase-43
        )
      parameter-7-43 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-43)
                          ,input no-lock
                          ,input parameter-3-43
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ,input parameter-6-43
                          ,input parameter-7-43
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        END.
    END.
    WHEN "cmp-host":U THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 одна фирма, один контрагент", filter-label0)
      .
      if p-open-query then do:
       ASSIGN
       frame Dialog-Frame:TITLE = title0 +
                                   substitute(" Фирма: (&1) &2 Контрагент (&3&4) &5",
                                   p-host-code, X_clients-host.obj-name,
                                   X_clients.obj-type, X_clients.obj-code, X_clients.obj-name) +
                                   chr(32)  + (if p-status_ = 'все':U then "":U else p-status_)
        .
      end.
        IF p-status_ = 'все':U THEN DO:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-45  as logical   no-undo .
define variable  l-filter-open-45    as logical   .
define variable  flt-rec-45       as recid     no-undo .
define variable  filter-name-45      as character no-undo .
define variable  where-phrase-45     as character no-undo .
define variable  sort-phrase-45      as character no-undo .
define variable  where-phrase-rus-45 as character no-undo .
define variable  sort-phrase-rus-45  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-45
  ,output filter-name-45
  ,output where-phrase-45
  ,output sort-phrase-45
  ,output where-phrase-rus-45
  ,output sort-phrase-rus-45
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-45
      ) no-error .
  assign
    l-filter-open-45 = false
  .
  if flt-rec-45 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-45 as character no-undo .
    define variable  parameter-3-45 as character no-undo .
    define variable  parameter-4-45 as character no-undo .
    define variable  parameter-5-45 as character no-undo .
    define variable  parameter-6-45 as character no-undo .
    define variable  parameter-7-45 as character no-undo .
      assign
      parameter-3-45 =
                              "FOR EACH X_fin-schet"
      parameter-4-45 =
        (
          if ("                 X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                                 " + " " + where-phrase-45) <> ""
          then  substitute(' X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4 '                                  , p-host-code, chr(34), p-cli-type, p-cli-code) + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + "")
      parameter-6-45 = if sort-phrase-45 = ''
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
        " " + sort-phrase-45
        )
      parameter-7-45 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-45 =
          ("                 X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                                 " + " " + where-phrase-45 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-45
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ,input parameter-6-45
                          ,input parameter-7-45
                          )
      .
      assign
        l-filter-open-45 = true
      .
    end.
    if l-filter-open-45 = false then do:
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
  if l-filter-open-45 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where                  X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-45 = (if p-find-next then "true":u else "false":u )
      parameter-4-45 =
        "where ":u +  substitute(' X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4 '                                  , p-host-code, chr(34), p-cli-type, p-cli-code) + " ":u + where-phrase-45 + " ":u + p-find-condition + " " + ""
      parameter-5-45 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-45)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-45 = (if p-find-next then "true":u else "false":u )
      parameter-3-45 =  "FOR EACH X_fin-schet"
      parameter-4-45 =
        (
          if ("                 X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                                 " + " " + where-phrase-45) <> ""
          then  substitute(' X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4 '                                  , p-host-code, chr(34), p-cli-type, p-cli-code) + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-45 = if sort-phrase-45 = ''
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
        " " + sort-phrase-45
        )
      parameter-7-45 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-45)
                          ,input no-lock
                          ,input parameter-3-45
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ,input parameter-6-45
                          ,input parameter-7-45
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        END.
        ELSE DO:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-47  as logical   no-undo .
define variable  l-filter-open-47    as logical   .
define variable  flt-rec-47       as recid     no-undo .
define variable  filter-name-47      as character no-undo .
define variable  where-phrase-47     as character no-undo .
define variable  sort-phrase-47      as character no-undo .
define variable  where-phrase-rus-47 as character no-undo .
define variable  sort-phrase-rus-47  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-47
  ,output filter-name-47
  ,output where-phrase-47
  ,output sort-phrase-47
  ,output where-phrase-rus-47
  ,output sort-phrase-rus-47
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-47
      ) no-error .
  assign
    l-filter-open-47 = false
  .
  if flt-rec-47 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-47 as character no-undo .
    define variable  parameter-3-47 as character no-undo .
    define variable  parameter-4-47 as character no-undo .
    define variable  parameter-5-47 as character no-undo .
    define variable  parameter-6-47 as character no-undo .
    define variable  parameter-7-47 as character no-undo .
      assign
      parameter-3-47 =
                              "FOR EACH X_fin-schet"
      parameter-4-47 =
        (
          if ("                 X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                     AND X_fin-schet.status_ = p-status_ " + " " + where-phrase-47) <> ""
          then  substitute('X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4                 AND X_fin-schet.status_ = &1&4&1' , p-host-code, chr(34), p-cli-type, p-cli-code, p-status_) + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + "")
      parameter-6-47 = if sort-phrase-47 = ''
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
        " " + sort-phrase-47
        )
      parameter-7-47 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-47 =
          ("                 X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                     AND X_fin-schet.status_ = p-status_ " + " " + where-phrase-47 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-47
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ,input parameter-6-47
                          ,input parameter-7-47
                          )
      .
      assign
        l-filter-open-47 = true
      .
    end.
    if l-filter-open-47 = false then do:
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
  if l-filter-open-47 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where                  X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                     AND X_fin-schet.status_ = p-status_
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-4-47 =
        "where ":u +  substitute('X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4                 AND X_fin-schet.status_ = &1&4&1' , p-host-code, chr(34), p-cli-type, p-cli-code, p-status_) + " ":u + where-phrase-47 + " ":u + p-find-condition + " " + ""
      parameter-5-47 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-3-47 =  "FOR EACH X_fin-schet"
      parameter-4-47 =
        (
          if ("                 X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = p-cli-type AND X_fin-schet.cli-code  = p-cli-code                     AND X_fin-schet.status_ = p-status_ " + " " + where-phrase-47) <> ""
          then  substitute('X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4                 AND X_fin-schet.status_ = &1&4&1' , p-host-code, chr(34), p-cli-type, p-cli-code, p-status_) + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-47 = if sort-phrase-47 = ''
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
        " " + sort-phrase-47
        )
      parameter-7-47 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input parameter-3-47
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ,input parameter-6-47
                          ,input parameter-7-47
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        END.
    END.
    WHEN "company-host":U THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Собственные счета фирмы", filter-label0)
      .
      if p-open-query then do:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                   substitute(" Фирма: (&1) &2 Собственные счета",
                                   p-host-code, X_clients-host.obj-name
                                   ) +
                                   chr(32)  + (if p-status_ = 'все':U then "":U else p-status_)
       .
      end.
      IF p-status_ = 'все':U  THEN DO:
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-49  as logical   no-undo .
define variable  l-filter-open-49    as logical   .
define variable  flt-rec-49       as recid     no-undo .
define variable  filter-name-49      as character no-undo .
define variable  where-phrase-49     as character no-undo .
define variable  sort-phrase-49      as character no-undo .
define variable  where-phrase-rus-49 as character no-undo .
define variable  sort-phrase-rus-49  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-49
  ,output filter-name-49
  ,output where-phrase-49
  ,output sort-phrase-49
  ,output where-phrase-rus-49
  ,output sort-phrase-rus-49
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-49
      ) no-error .
  assign
    l-filter-open-49 = false
  .
  if flt-rec-49 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-49 as character no-undo .
    define variable  parameter-3-49 as character no-undo .
    define variable  parameter-4-49 as character no-undo .
    define variable  parameter-5-49 as character no-undo .
    define variable  parameter-6-49 as character no-undo .
    define variable  parameter-7-49 as character no-undo .
      assign
      parameter-3-49 =
                              "FOR EACH X_fin-schet"
      parameter-4-49 =
        (
          if ("                 X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = 'орг':U AND X_fin-schet.cli-code  = p-host-code                                 " + " " + where-phrase-49) <> ""
          then  substitute('X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4 '                                , p-host-code, chr(34), 'орг':U, p-host-code) + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + "")
      parameter-6-49 = if sort-phrase-49 = ''
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
        " " + sort-phrase-49
        )
      parameter-7-49 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-49 =
          ("                 X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = 'орг':U AND X_fin-schet.cli-code  = p-host-code                                 " + " " + where-phrase-49 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-49
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ,input parameter-6-49
                          ,input parameter-7-49
                          )
      .
      assign
        l-filter-open-49 = true
      .
    end.
    if l-filter-open-49 = false then do:
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
  if l-filter-open-49 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where                  X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = 'орг':U AND X_fin-schet.cli-code  = p-host-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-49 = (if p-find-next then "true":u else "false":u )
      parameter-4-49 =
        "where ":u +  substitute('X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4 '                                , p-host-code, chr(34), 'орг':U, p-host-code) + " ":u + where-phrase-49 + " ":u + p-find-condition + " " + ""
      parameter-5-49 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-49)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-49 = (if p-find-next then "true":u else "false":u )
      parameter-3-49 =  "FOR EACH X_fin-schet"
      parameter-4-49 =
        (
          if ("                 X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = 'орг':U AND X_fin-schet.cli-code  = p-host-code                                 " + " " + where-phrase-49) <> ""
          then  substitute('X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4 '                                , p-host-code, chr(34), 'орг':U, p-host-code) + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-49 = if sort-phrase-49 = ''
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
        " " + sort-phrase-49
        )
      parameter-7-49 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-49)
                          ,input no-lock
                          ,input parameter-3-49
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ,input parameter-6-49
                          ,input parameter-7-49
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        END.
        ELSE DO:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-51  as logical   no-undo .
define variable  l-filter-open-51    as logical   .
define variable  flt-rec-51       as recid     no-undo .
define variable  filter-name-51      as character no-undo .
define variable  where-phrase-51     as character no-undo .
define variable  sort-phrase-51      as character no-undo .
define variable  where-phrase-rus-51 as character no-undo .
define variable  sort-phrase-rus-51  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-51
  ,output filter-name-51
  ,output where-phrase-51
  ,output sort-phrase-51
  ,output where-phrase-rus-51
  ,output sort-phrase-rus-51
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-51
      ) no-error .
  assign
    l-filter-open-51 = false
  .
  if flt-rec-51 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-51 as character no-undo .
    define variable  parameter-3-51 as character no-undo .
    define variable  parameter-4-51 as character no-undo .
    define variable  parameter-5-51 as character no-undo .
    define variable  parameter-6-51 as character no-undo .
    define variable  parameter-7-51 as character no-undo .
      assign
      parameter-3-51 =
                              "FOR EACH X_fin-schet"
      parameter-4-51 =
        (
          if ("                 X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = 'орг':U AND X_fin-schet.cli-code  = p-host-code                     AND X_fin-schet.status_ = p-status_  " + " " + where-phrase-51) <> ""
          then  substitute('X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4                 AND X_fin-schet.status_ = &2&5&2 ', p-host-code, chr(34), 'орг':U, p-host-code, p-status_) + " " + where-phrase-51
          else "true"
        )
      parameter-5-51 = (" " + "" + " " + "")
      parameter-6-51 = if sort-phrase-51 = ''
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
        " " + sort-phrase-51
        )
      parameter-7-51 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-51 =
          ("                 X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = 'орг':U AND X_fin-schet.cli-code  = p-host-code                     AND X_fin-schet.status_ = p-status_  " + " " + where-phrase-51 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-51
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ,input parameter-6-51
                          ,input parameter-7-51
                          )
      .
      assign
        l-filter-open-51 = true
      .
    end.
    if l-filter-open-51 = false then do:
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
  if l-filter-open-51 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where                  X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = 'орг':U AND X_fin-schet.cli-code  = p-host-code                     AND X_fin-schet.status_ = p-status_
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-51 = (if p-find-next then "true":u else "false":u )
      parameter-4-51 =
        "where ":u +  substitute('X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4                 AND X_fin-schet.status_ = &2&5&2 ', p-host-code, chr(34), 'орг':U, p-host-code, p-status_) + " ":u + where-phrase-51 + " ":u + p-find-condition + " " + ""
      parameter-5-51 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-51)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-51 = (if p-find-next then "true":u else "false":u )
      parameter-3-51 =  "FOR EACH X_fin-schet"
      parameter-4-51 =
        (
          if ("                 X_fin-schet.host-code = p-host-code AND X_fin-schet.cli-type  = 'орг':U AND X_fin-schet.cli-code  = p-host-code                     AND X_fin-schet.status_ = p-status_  " + " " + where-phrase-51) <> ""
          then  substitute('X_fin-schet.host-code = &1 AND X_fin-schet.cli-type  = &2&3&2 AND X_fin-schet.cli-code  = &4                 AND X_fin-schet.status_ = &2&5&2 ', p-host-code, chr(34), 'орг':U, p-host-code, p-status_) + " " + where-phrase-51
          else "true"
        )
      parameter-5-51 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-51 = if sort-phrase-51 = ''
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
        " " + sort-phrase-51
        )
      parameter-7-51 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-51)
                          ,input no-lock
                          ,input parameter-3-51
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ,input parameter-6-51
                          ,input parameter-7-51
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        END.
    END.
    WHEN "currency" THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1 Одна валюта", filter-label0)
      .
      if p-open-query then do:
       ASSIGN
       frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Валюта: (&1) &2",
                                    X_currency.curr-code, X_currency.curr-abbr) +
                                    chr(32)  + (if p-status_ = 'все':U then "":U else p-status_)
       .
      end.
      IF p-status_ = 'все':U THEN DO:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-53  as logical   no-undo .
define variable  l-filter-open-53    as logical   .
define variable  flt-rec-53       as recid     no-undo .
define variable  filter-name-53      as character no-undo .
define variable  where-phrase-53     as character no-undo .
define variable  sort-phrase-53      as character no-undo .
define variable  where-phrase-rus-53 as character no-undo .
define variable  sort-phrase-rus-53  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-53
  ,output filter-name-53
  ,output where-phrase-53
  ,output sort-phrase-53
  ,output where-phrase-rus-53
  ,output sort-phrase-rus-53
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-53
      ) no-error .
  assign
    l-filter-open-53 = false
  .
  if flt-rec-53 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-53 as character no-undo .
    define variable  parameter-3-53 as character no-undo .
    define variable  parameter-4-53 as character no-undo .
    define variable  parameter-5-53 as character no-undo .
    define variable  parameter-6-53 as character no-undo .
    define variable  parameter-7-53 as character no-undo .
      assign
      parameter-3-53 =
                              "FOR EACH X_fin-schet"
      parameter-4-53 =
        (
          if ("               X_fin-schet.host-code  = p-curr-host-code AND X_fin-schet.curr-code  = p-curr-code                               " + " " + where-phrase-53) <> ""
          then  substitute( ' X_fin-schet.host-code  = &1 AND X_fin-schet.curr-code  = &2', p-curr-host-code, p-curr-code) + " " + where-phrase-53
          else "true"
        )
      parameter-5-53 = (" " + "" + " " + "")
      parameter-6-53 = if sort-phrase-53 = ''
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
        " " + sort-phrase-53
        )
      parameter-7-53 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-53 =
          ("               X_fin-schet.host-code  = p-curr-host-code AND X_fin-schet.curr-code  = p-curr-code                               " + " " + where-phrase-53 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-53
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ,input parameter-6-53
                          ,input parameter-7-53
                          )
      .
      assign
        l-filter-open-53 = true
      .
    end.
    if l-filter-open-53 = false then do:
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
  if l-filter-open-53 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where                X_fin-schet.host-code  = p-curr-host-code AND X_fin-schet.curr-code  = p-curr-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-53 = (if p-find-next then "true":u else "false":u )
      parameter-4-53 =
        "where ":u +  substitute( ' X_fin-schet.host-code  = &1 AND X_fin-schet.curr-code  = &2', p-curr-host-code, p-curr-code) + " ":u + where-phrase-53 + " ":u + p-find-condition + " " + ""
      parameter-5-53 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-53)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-53 = (if p-find-next then "true":u else "false":u )
      parameter-3-53 =  "FOR EACH X_fin-schet"
      parameter-4-53 =
        (
          if ("               X_fin-schet.host-code  = p-curr-host-code AND X_fin-schet.curr-code  = p-curr-code                               " + " " + where-phrase-53) <> ""
          then  substitute( ' X_fin-schet.host-code  = &1 AND X_fin-schet.curr-code  = &2', p-curr-host-code, p-curr-code) + " " + where-phrase-53
          else "true"
        )
      parameter-5-53 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-53 = if sort-phrase-53 = ''
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
        " " + sort-phrase-53
        )
      parameter-7-53 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-53)
                          ,input no-lock
                          ,input parameter-3-53
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ,input parameter-6-53
                          ,input parameter-7-53
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      END.
      ELSE DO:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-55  as logical   no-undo .
define variable  l-filter-open-55    as logical   .
define variable  flt-rec-55       as recid     no-undo .
define variable  filter-name-55      as character no-undo .
define variable  where-phrase-55     as character no-undo .
define variable  sort-phrase-55      as character no-undo .
define variable  where-phrase-rus-55 as character no-undo .
define variable  sort-phrase-rus-55  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-55
  ,output filter-name-55
  ,output where-phrase-55
  ,output sort-phrase-55
  ,output where-phrase-rus-55
  ,output sort-phrase-rus-55
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-55
      ) no-error .
  assign
    l-filter-open-55 = false
  .
  if flt-rec-55 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-55 as character no-undo .
    define variable  parameter-3-55 as character no-undo .
    define variable  parameter-4-55 as character no-undo .
    define variable  parameter-5-55 as character no-undo .
    define variable  parameter-6-55 as character no-undo .
    define variable  parameter-7-55 as character no-undo .
      assign
      parameter-3-55 =
                              "FOR EACH X_fin-schet"
      parameter-4-55 =
        (
          if ("               X_fin-schet.host-code  = p-curr-host-code AND X_fin-schet.curr-code  = p-curr-code                   AND X_fin-schet.status_ = p-status_ " + " " + where-phrase-55) <> ""
          then  substitute(' X_fin-schet.host-code  = &1 AND X_fin-schet.curr-code  = &2                  AND X_fin-schet.status_ = &3&4&3 ',  p-curr-host-code, p-curr-code, chr(34), p-status_ ) + " " + where-phrase-55
          else "true"
        )
      parameter-5-55 = (" " + "" + " " + "")
      parameter-6-55 = if sort-phrase-55 = ''
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
        " " + sort-phrase-55
        )
      parameter-7-55 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-55 =
          ("               X_fin-schet.host-code  = p-curr-host-code AND X_fin-schet.curr-code  = p-curr-code                   AND X_fin-schet.status_ = p-status_ " + " " + where-phrase-55 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-55
                          ,input parameter-4-55
                          ,input parameter-5-55
                          ,input parameter-6-55
                          ,input parameter-7-55
                          )
      .
      assign
        l-filter-open-55 = true
      .
    end.
    if l-filter-open-55 = false then do:
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
  if l-filter-open-55 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where                X_fin-schet.host-code  = p-curr-host-code AND X_fin-schet.curr-code  = p-curr-code                   AND X_fin-schet.status_ = p-status_
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-55 = (if p-find-next then "true":u else "false":u )
      parameter-4-55 =
        "where ":u +  substitute(' X_fin-schet.host-code  = &1 AND X_fin-schet.curr-code  = &2                  AND X_fin-schet.status_ = &3&4&3 ',  p-curr-host-code, p-curr-code, chr(34), p-status_ ) + " ":u + where-phrase-55 + " ":u + p-find-condition + " " + ""
      parameter-5-55 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-55)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-55
                          ,input parameter-5-55
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-55 = (if p-find-next then "true":u else "false":u )
      parameter-3-55 =  "FOR EACH X_fin-schet"
      parameter-4-55 =
        (
          if ("               X_fin-schet.host-code  = p-curr-host-code AND X_fin-schet.curr-code  = p-curr-code                   AND X_fin-schet.status_ = p-status_ " + " " + where-phrase-55) <> ""
          then  substitute(' X_fin-schet.host-code  = &1 AND X_fin-schet.curr-code  = &2                  AND X_fin-schet.status_ = &3&4&3 ',  p-curr-host-code, p-curr-code, chr(34), p-status_ ) + " " + where-phrase-55
          else "true"
        )
      parameter-5-55 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-55 = if sort-phrase-55 = ''
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
        " " + sort-phrase-55
        )
      parameter-7-55 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-55)
                          ,input no-lock
                          ,input parameter-3-55
                          ,input parameter-4-55
                          ,input parameter-5-55
                          ,input parameter-6-55
                          ,input parameter-7-55
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      END.
    END.
    WHEN "bank" THEN DO:
      assign
      filter-point = filter-point0 + p-mode.
      filter-label = substitute("&1 Один банк", filter-label0)
      .
      if p-open-query then do:
        assign
        frame Dialog-Frame:TITLE = title0 +
                                  substitute(" Банк: &1", X_fin-bank.short-name) +
                                  chr(32)  + (if p-status_ = 'все':U then "":U else p-status_)
        .
      end.
      IF p-status_ = 'все':U THEN DO:
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-57  as logical   no-undo .
define variable  l-filter-open-57    as logical   .
define variable  flt-rec-57       as recid     no-undo .
define variable  filter-name-57      as character no-undo .
define variable  where-phrase-57     as character no-undo .
define variable  sort-phrase-57      as character no-undo .
define variable  where-phrase-rus-57 as character no-undo .
define variable  sort-phrase-rus-57  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-57
  ,output filter-name-57
  ,output where-phrase-57
  ,output sort-phrase-57
  ,output where-phrase-rus-57
  ,output sort-phrase-rus-57
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-57
      ) no-error .
  assign
    l-filter-open-57 = false
  .
  if flt-rec-57 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-57 as character no-undo .
    define variable  parameter-3-57 as character no-undo .
    define variable  parameter-4-57 as character no-undo .
    define variable  parameter-5-57 as character no-undo .
    define variable  parameter-6-57 as character no-undo .
    define variable  parameter-7-57 as character no-undo .
      assign
      parameter-3-57 =
                              "FOR EACH X_fin-schet"
      parameter-4-57 =
        (
          if ("               X_fin-schet.host-code  = p-host-code AND X_fin-schet.code-bank  = p-code-bank                               " + " " + where-phrase-57) <> ""
          then  substitute('  X_fin-schet.host-code  = &1 AND X_fin-schet.code-bank  = &2 ', p-host-code, p-code-bank )  + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + "")
      parameter-6-57 = if sort-phrase-57 = ''
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
        " " + sort-phrase-57
        )
      parameter-7-57 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-57 =
          ("               X_fin-schet.host-code  = p-host-code AND X_fin-schet.code-bank  = p-code-bank                               " + " " + where-phrase-57 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-57
                          ,input parameter-4-57
                          ,input parameter-5-57
                          ,input parameter-6-57
                          ,input parameter-7-57
                          )
      .
      assign
        l-filter-open-57 = true
      .
    end.
    if l-filter-open-57 = false then do:
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
  if l-filter-open-57 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where                X_fin-schet.host-code  = p-host-code AND X_fin-schet.code-bank  = p-code-bank
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-57 = (if p-find-next then "true":u else "false":u )
      parameter-4-57 =
        "where ":u +  substitute('  X_fin-schet.host-code  = &1 AND X_fin-schet.code-bank  = &2 ', p-host-code, p-code-bank )  + " ":u + where-phrase-57 + " ":u + p-find-condition + " " + ""
      parameter-5-57 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-57)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-57
                          ,input parameter-5-57
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-57 = (if p-find-next then "true":u else "false":u )
      parameter-3-57 =  "FOR EACH X_fin-schet"
      parameter-4-57 =
        (
          if ("               X_fin-schet.host-code  = p-host-code AND X_fin-schet.code-bank  = p-code-bank                               " + " " + where-phrase-57) <> ""
          then  substitute('  X_fin-schet.host-code  = &1 AND X_fin-schet.code-bank  = &2 ', p-host-code, p-code-bank )  + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-57 = if sort-phrase-57 = ''
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
        " " + sort-phrase-57
        )
      parameter-7-57 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-57)
                          ,input no-lock
                          ,input parameter-3-57
                          ,input parameter-4-57
                          ,input parameter-5-57
                          ,input parameter-6-57
                          ,input parameter-7-57
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      END.
      ELSE DO:
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-59  as logical   no-undo .
define variable  l-filter-open-59    as logical   .
define variable  flt-rec-59       as recid     no-undo .
define variable  filter-name-59      as character no-undo .
define variable  where-phrase-59     as character no-undo .
define variable  sort-phrase-59      as character no-undo .
define variable  where-phrase-rus-59 as character no-undo .
define variable  sort-phrase-rus-59  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-59
  ,output filter-name-59
  ,output where-phrase-59
  ,output sort-phrase-59
  ,output where-phrase-rus-59
  ,output sort-phrase-rus-59
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-59
      ) no-error .
  assign
    l-filter-open-59 = false
  .
  if flt-rec-59 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-59 as character no-undo .
    define variable  parameter-3-59 as character no-undo .
    define variable  parameter-4-59 as character no-undo .
    define variable  parameter-5-59 as character no-undo .
    define variable  parameter-6-59 as character no-undo .
    define variable  parameter-7-59 as character no-undo .
      assign
      parameter-3-59 =
                              "FOR EACH X_fin-schet"
      parameter-4-59 =
        (
          if ("               X_fin-schet.host-code  = p-host-code AND X_fin-schet.code-bank  = p-code-bank                   AND X_fin-schet.status_ = p-status_ " + " " + where-phrase-59) <> ""
          then  substitute('X_fin-schet.host-code  = &1 AND X_fin-schet.code-bank  = &2                   AND X_fin-schet.status_ = &3&4&3', p-host-code, p-code-bank, chr(34), p-status_ ) + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + "")
      parameter-6-59 = if sort-phrase-59 = ''
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
        " " + sort-phrase-59
        )
      parameter-7-59 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-59 =
          ("               X_fin-schet.host-code  = p-host-code AND X_fin-schet.code-bank  = p-code-bank                   AND X_fin-schet.status_ = p-status_ " + " " + where-phrase-59 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input parameter-3-59
                          ,input parameter-4-59
                          ,input parameter-5-59
                          ,input parameter-6-59
                          ,input parameter-7-59
                          )
      .
      assign
        l-filter-open-59 = true
      .
    end.
    if l-filter-open-59 = false then do:
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
  if l-filter-open-59 = false then do:
    OPEN QUERY br-schet FOR EACH X_fin-schet
      where                X_fin-schet.host-code  = p-host-code AND X_fin-schet.code-bank  = p-code-bank                   AND X_fin-schet.status_ = p-status_
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_fin-schet )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-schet:handle:get-buffer-handle(1) = (buffer X_fin-schet:handle) then do:
      assign
      parameter-2-59 = (if p-find-next then "true":u else "false":u )
      parameter-4-59 =
        "where ":u +  substitute('X_fin-schet.host-code  = &1 AND X_fin-schet.code-bank  = &2                   AND X_fin-schet.status_ = &3&4&3', p-host-code, p-code-bank, chr(34), p-status_ ) + " ":u + where-phrase-59 + " ":u + p-find-condition + " " + ""
      parameter-5-59 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input rowid(X_fin-schet)
                          ,input logical(parameter-2-59)
                          ,input no-lock
                          ,input (buffer X_fin-schet:handle)
                          ,input parameter-4-59
                          ,input parameter-5-59
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-59 = (if p-find-next then "true":u else "false":u )
      parameter-3-59 =  "FOR EACH X_fin-schet"
      parameter-4-59 =
        (
          if ("               X_fin-schet.host-code  = p-host-code AND X_fin-schet.code-bank  = p-code-bank                   AND X_fin-schet.status_ = p-status_ " + " " + where-phrase-59) <> ""
          then  substitute('X_fin-schet.host-code  = &1 AND X_fin-schet.code-bank  = &2                   AND X_fin-schet.status_ = &3&4&3', p-host-code, p-code-bank, chr(34), p-status_ ) + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-59 = if sort-phrase-59 = ''
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
        " " + sort-phrase-59
        )
      parameter-7-59 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-schet:handle
                          ,input logical(parameter-2-59)
                          ,input no-lock
                          ,input parameter-3-59
                          ,input parameter-4-59
                          ,input parameter-5-59
                          ,input parameter-6-59
                          ,input parameter-7-59
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      END.
    END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-schet to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-schet:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-schet in frame Dialog-Frame.
APPLY "ENTRY" TO br-schet.
END PROCEDURE.
PROCEDURE proc-b-del :
define variable loc#log as logical no-undo.
define variable v-status_ like ub.fin-schet.status_ no-undo .
define variable loc-doc-rec as recid no-undo .
if not available X_fin-schet then return error.
do
on error undo, return error
on stop undo, return error
:
define variable vss-include-info60 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-bank-accounts_deletion':U
    ,input  'firm':U
    ,input  p-curr-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
if not loc#log then return error.
  assign
  v-status_ = "":U
  loc-doc-rec = recid(X_fin-bank)
  .
  run ref/finscht2.p (
                  input recid(X_fin-schet)
                  ,input no
                  ,input ''
                  ,input-output v-status_
                 ) no-error .
  if error-status:error then undo, return error.
   if v-status_ <> p-status_ then do:
    RUn OpenBR in this-procedure ( input yes, input no, input no).
    reposition br-schet to recid loc-doc-rec no-error.
    if error-status:error then do:                           find first pos_fin-schet no-lock where                                   recid(pos_fin-schet) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи БАНКОВСКИЙ СЧЕТ" skip                            string(if avail pos_fin-schet                                     then  substitute("Код фирмы: &1, вн. код счета &2"                                                     , pos_fin-schet.host-code                                                      , pos_fin-schet.code-schet)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
  end.
  else do:
    display
    X_fin-schet.status_
    with browse br-schet.
  end.
end.
END PROCEDURE.
PROCEDURE proc-b-print :
DEFINE INPUT PARAMETER loc-option as character no-undo.
if loc-option = '':U then return error.
CASE loc-option:
when 'ONE':U then do:
  run proc-print-one in this-procedure .
end.
when 'LIST':U then do:
  run proc-print-list no-error.
end.
end case.
loc-option = ''.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'fin-schet'
  join-tbl = 'X_fin-schet'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('host-code', 'Кoд фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('code-schet', 'Код счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('code-bank', 'Код банка', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type*cli-code', 'Держатель счета', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('c-schet', 'Коррсчет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('dop1', 'Доп к назв.держ.счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('dop2', 'Доп к назв.банка', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('r-schet', 'Р/счет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', '', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', 'Примечание', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT (filter-point + chr(4) + filter-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
PROCEDURE proc-b-vipiska :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
CASE p-option :
  WHEN 'report' THEN DO:
    run rep/fextract.p ( input parparentproc
                       , input X_fin-schet.host-code
                       , input X_fin-schet.code-schet) no-error.
  END.
  WHEN 'statement' THEN DO:
   run ref/finsttms.w (
               input parparentproc
              ,input v-cntxt-host-code-obj
              ,input "":U
              ,input 'code-schet':U
              ,input X_fin-schet.host-code
              ,input '':U
              ,input '':U
              ,input '':U
              ,input ?
              ,input ?
              ,input X_fin-schet.code-bank
              ,input X_fin-schet.code-schet
              ,input X_fin-schet.curr-code
              ,input-output v-rid-list).
  END.
END CASE.
END PROCEDURE.
PROCEDURE proc-br-schet :
  if b-sel:sensitive in frame Dialog-Frame then
      if b-mark:sensitive then
          apply "choose" to b-mark in frame Dialog-Frame.
      else
          apply "choose" to b-sel in frame Dialog-Frame.
  else
      if b-lkp:sensitive then
          apply "choose" to b-lkp in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-copy :
define variable p-fin-code as integer no-undo .
define variable p-out-host-code like ub.sysconf.host-code no-undo.
define variable firm-rid-list as char no-undo.
define variable p-ok as logical no-undo .
define variable ii as integer no-undo .
define variable Jj as integer no-undo .
define variable kk as integer no-undo .
define variable p-ret as logical no-undo .
define variable glog as logical no-undo.
define variable v-out-host-code like ub.sysconf.host-code no-undo .
define variable v-recid-schet as recid no-undo.
define variable v-recid-bank as recid no-undo.
define variable v-new-rid-list as character no-undo .
define variable v-final-rid-list as character no-undo .
define variable v-stay-doc-rec as recid no-undo.
define buffer buf_sysconf  for ub.sysconf.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf2_fin-bank for ub.fin-bank.
define buffer buf2_fin-schet for ub.fin-schet.
define variable vss-include-info61 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-bank-accounts_add-copy':U
    ,input  'firm':U
    ,input  p-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if not glog then  return .
if num-entries(v-rid-list) = 0 then do:
  message
  "Не отмечены записи для копирования !!!"
  view-as alert-box error.
  return error.
end.
assign
v-stay-doc-rec = recid(X_fin-schet)
.
run adm/sconfs.w (
              input parparentproc
            , input "b-mark,b-sel":U
            , input no
            , input p-curr-host-code
            , output v-out-host-code
            , input-output firm-rid-list) .
if num-entries(firm-rid-list) = 0 then do:
 message "Не выбрана фирмы для копирования !!!" .
 return error.
end.
message
"Вы отметили " num-entries(firm-rid-list) " фирмы. " skip
"Скопировать выбранные счета в эти фирмы ?"
view-as alert-box question
buttons yes-no
update p-ok.
kk = 0.
if p-ok = false then return.
_ii:
repeat ii = 1 to num-entries(firm-rid-list) :
  find first buf_sysconf no-lock where
            recid(buf_sysconf) = integer(entry(ii, firm-rid-list)) no-error .
  if not available buf_sysconf then next _ii.
  if buf_sysconf.host-code = p-host-code then do:
    message
    "Нельзя скопировать счета в свою собственную фирму" buf_sysconf.host-code
    view-as alert-box error .
    next _ii.
  end.
  if buf_sysconf.firm-db-num <> X_sysconf.firm-db-num then do:
    message
    "Нельзя скопировать счета на фирму" buf_sysconf.host-code  skip
    "Текущая БД " v-db-num "Главная БД данной фирмы" buf_sysconf.firm-db-num
    view-as alert-box error .
    next _ii.
  end.
define variable vss-include-info62 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-bank-accounts_add-copy':U
    ,input  'firm':U
    ,input  buf_sysconf.host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  no
    ,output glog
    )  .
end.
  if not glog then do:
    message
    "Нельзя скопировать счета на фирму" buf_sysconf.host-code  skip
    "У Вас нет прав на добавление банков и банковских счетов в фирме" buf_sysconf.host-code
    view-as alert-box error .
    next _ii.
  end.
  _rr:
  repeat jj = 1 to num-entries(v-rid-list) :
    for each buf_fin-schet where
          recid(buf_fin-schet) =  integer(entry(jj, v-rid-list)):
      if buf_fin-schet.cli-type = 'орг':U
      AND buf_fin-schet.cli-code = buf_sysconf.host-code then do:
        message
        "Нельзя скопировать счета, для которых фирма является держателем счета" buf_sysconf.host-code
        view-as alert-box error .
        assign
        v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else chr(44)) + entry(jj, v-rid-list)
        .
        next _rr.
      end.
      if buf_fin-schet.status_ = 'удал':U then do:
        message
        "Нельзя скопировать счета" buf_fin-schet.code-schet "на фирму" buf_sysconf.host-code  skip
        "Счет имеет статус" 'удал':U "в фирме" p-host-code
        view-as alert-box error .
        assign
        v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else chr(44)) + entry(jj, v-rid-list)
        .
        next _rr.
      end.
      find first buf_fin-bank no-lock where
                buf_fin-bank.host-code = p-host-code
            AND buf_fin-bank.code-bank = buf_fin-schet.code-bank no-error .
      if not available buf_fin-bank then next _rr.
      find first buf2_fin-bank no-lock where
                buf2_fin-bank.host-code = buf_sysconf.host-code
            AND buf2_fin-bank.bik = buf_fin-bank.bik
            AND buf2_fin-bank.cor-acc = buf_fin-bank.cor-acc no-error .
      if not available buf2_fin-bank then do:
        assign
        v-recid-bank = ?.
        run ref/finbank1.p (
        input-output v-recid-bank
        ,input 'ДОБАВЛЕНИЕ':U
        ,input no
        ,input "bik"
        ,input "":U
        ,input buf_sysconf.host-code
        ,input 0
        ,input buf_fin-bank.addres
        ,input buf_fin-bank.bank-city
        ,input buf_fin-bank.addres1
        ,input buf_fin-bank.bank-name
        ,input buf_fin-bank.bik
        ,input buf_fin-bank.cor-acc
        ,input buf_fin-bank.e-mail
        ,input buf_fin-bank.fax
        ,input buf_fin-bank.inn
        ,input buf_fin-bank.kpp
        ,input buf_fin-bank.licenz
        ,input buf_fin-bank.okato
        ,input buf_fin-bank.okonx
        ,input buf_fin-bank.okpo
        ,input buf_fin-bank.otdel
        ,input buf_fin-bank.phone
        ,input (substitute("@Копирование с фирмы &1@ &2", p-host-code, buf_fin-bank.PS))
        ,input buf_fin-bank.rkc
        ,input buf_fin-bank.short-name
        ,input buf_fin-bank.cl-bank
        )
        no-error.
        if error-status:error then do:
          assign
          v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else chr(44)) + entry(jj, v-rid-list)
          .
          next _rr.
        end.
        find first buf2_fin-bank no-lock where
                  recid(buf2_fin-bank) = v-recid-bank no-error.
      end.
      if available buf2_fin-bank then do:
        if buf2_fin-bank.status_ = 'удал':U then do:
          message
          "Нельзя скопировать счета" buf_fin-schet.code-schet "на фирму" buf_sysconf.host-code  skip
          "Банк счета имеет статус" 'удал':U "в фирме" buf_sysconf.host-code
          view-as alert-box error .
          assign
          v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else chr(44)) + entry(jj, v-rid-list)
          .
          next _rr.
        end.
        find first buf2_fin-schet no-lock where
                    buf2_fin-schet.host-code      = buf_sysconf.host-code
                AND buf2_fin-schet.code-bank      = buf2_fin-bank.code-bank
                AND buf2_fin-schet.c-schet      = buf_fin-schet.c-schet
                AND buf2_fin-schet.r-schet      = buf_fin-schet.r-schet no-error.
        if not available buf2_fin-schet then do:
          assign
          v-recid-schet = ?.
          run ref/finscht1.p (
          input-output v-recid-schet
          ,input 'ДОБАВЛЕНИЕ':U
          ,input no
          ,input "r-schet"
          ,input buf_sysconf.host-code
          ,input 0
          ,input buf_fin-schet.c-schet
          ,input buf_fin-schet.cli-type
          ,input buf_fin-schet.cli-code
          ,input buf2_fin-bank.code-bank
          ,input buf_fin-schet.curr-code
          ,input buf_fin-schet.dop1
          ,input buf_fin-schet.dop2
          ,input buf_fin-schet.r-schet
          ,input (substitute("@Копирование с фирмы &1@ &2", p-host-code, buf_fin-schet.PS))
          )
          no-error.
          find first buf2_fin-schet no-lock where
                    recid(buf2_fin-schet) = v-recid-schet no-error .
          if available buf2_fin-schet then do:
            assign
            kk = kk + 1
            .
          end.
          else do:
            assign
            v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else chr(44)) + entry(jj, v-rid-list)
            .
          end.
        end.
      end.
    end.
  end.
  assign
  v-final-rid-list = cross-list(v-rid-list, v-new-rid-list, chr(44))
  .
end.
v-rid-list = v-final-rid-list.
run OpenBr in this-procedure ( input yes, input no, input no).
reposition br-schet to recid v-stay-doc-rec no-error.
message
"Скопировано " kk  "записей" view-as alert-box .
END PROCEDURE.
PROCEDURE proc-find-c-schet :
define input parameter p-next as logical no-undo.
define input parameter p-c-schet like ub.fin-schet.c-schet no-undo.
display
"0":U @ sch-code
"0":U @ sch-cli-code
"":U @ sch-r-schet
with frame Dialog-Frame.
assign
p-c-schet = replace(p-c-schet, chr(34), "":U)
p-c-schet = replace(p-c-schet, chr(39), chr(39) + chr(39))
p-c-schet = chr(34) + p-c-schet + chr(34).
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_fin-schet.c-schet   begins &1 "
      , p-c-schet)
    ).
apply "entry":u to sch-c-schet in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-cli-code :
define input parameter p-next as logical no-undo.
define input parameter p-cli-code like ub.fin-schet.cli-code no-undo.
define variable v-cli-code as character no-undo.
assign
frame Dialog-Frame RS-cli-type .
display
"":U @ sch-c-schet
"":U @ sch-r-schet
0 @ sch-code
with frame Dialog-Frame.
assign
v-cli-code = string(p-cli-code).
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_fin-schet.cli-type = '&1' and X_fin-schet.cli-code = &2"
      , RS-cli-type, v-cli-code )
    ).
apply "entry":u to sch-cli-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-code :
define input parameter p-next as logical no-undo.
define input parameter p-code-schet like ub.fin-schet.code-schet no-undo.
define variable v-code-schet as character no-undo.
display
"0":U @ sch-cli-code
"":U @ sch-c-schet
"":U @ sch-r-schet
with frame Dialog-Frame.
assign
v-code-schet = string(p-code-schet).
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_fin-schet.code-schet = &1 "
      , v-code-schet)
    ).
apply "entry":u to sch-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-r-schet :
define input parameter p-next as logical no-undo.
define input parameter p-r-schet as character no-undo.
display
"0":U @ sch-code
"0":U @ sch-cli-code
"":U @ sch-c-schet
with frame Dialog-Frame.
assign
p-r-schet = replace(p-r-schet, chr(34), "":U)
p-r-schet = replace(p-r-schet, chr(39), chr(39) + chr(39))
p-r-schet = chr(34) + p-r-schet + chr(34).
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_fin-schet.r-schet   begins &1 "
      , p-r-schet)
    ).
apply "entry":u to sch-r-schet in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-print-list :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
define variable v-bank-short-name     as character no-undo .
define variable v-cli-name      as character no-undo .
define variable v-curr-abbr     as character no-undo .
DEFINE FRAME fin-schet-list
X_fin-schet.host-code COLUMN-LABEL "Код!фирмы" format "9999999999"
X_fin-schet.code-schet
X_fin-schet.code-bank COLUMN-LABEL "Код банка"  format ">>>>>>9"
v-bank-short-name format "X(40)" COLUMN-LABEL "Банк"
X_fin-schet.cli-type
X_fin-schet.cli-code
v-cli-name  format "X(20)" COLUMn-LABEL "Держатель счета"
v-curr-abbr format "X(3)" COLUMn-LABEL "Вал"
X_fin-schet.status_
X_fin-schet.r-schet
X_fin-schet.c-schet
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 195).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame Dialog-Frame:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME fin-schet-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_fin-schet).
DO WHILE available X_fin-schet :
  GET prev br-schet.
END.
GET next br-schet.
DO WHILE available X_fin-schet :
  Display STREAM PrnLibStream
  X_fin-schet.host-code
  X_fin-schet.code-schet
  X_fin-schet.code-bank
  get-bank-short-name(buffer X_fin-schet) @  v-bank-short-name
  X_fin-schet.cli-type
  X_fin-schet.cli-code
  get-cli-name(buffer X_fin-schet) @ v-cli-name
  get-currency(buffer X_fin-schet)  @ v-curr-abbr
  X_fin-schet.status_
  X_fin-schet.r-schet
  X_fin-schet.c-schet
  with FRAME fin-schet-list .
  DOWN STREAM PrnLibStream 1
  with FRAME fin-schet-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-schet.
END.
UNDERLINE  STREAM PrnLibStream
X_fin-schet.host-code
X_fin-schet.code-schet
X_fin-schet.code-bank
v-bank-short-name
X_fin-schet.cli-type
X_fin-schet.cli-code
v-cli-name
v-curr-abbr
X_fin-schet.status_
X_fin-schet.r-schet
X_fin-schet.c-schet
with FRAME fin-schet-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_fin-schet.host-code
accum-count @ X_fin-schet.code-schet
with frame fin-schet-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME fin-schet-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-schet to recid v-doc-rec no-error.
APPLY "entry" to br-schet.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
PROCEDURE proc-print-one :
if not available X_fin-schet then return error.
run ref/finschtp.p (
                 INPUT parParentProc
                 ,input X_fin-schet.host-code
                 ,input X_fin-schet.code-schet
              ) no-error.
if error-status:error then do:
  return error.
end.
END PROCEDURE.
FUNCTION get-bank-short-name RETURNS CHARACTER
  ( BUFFER loc-fin-schet FOR ub.fin-schet ) :
define buffer buf_fin-bank for ub.fin-bank.
find first buf_fin-bank no-lock where
            buf_fin-bank.code-bank = loc-fin-schet.code-bank
                AND    buf_fin-bank.host-code = loc-fin-schet.host-code  no-error.
if available buf_fin-bank then
RETURN (if buf_fin-bank.short-name <> "":U then buf_fin-bank.short-name else buf_fin-bank.bank-name).
return (string(loc-fin-schet.host-code) + string(loc-fin-schet.code-bank)).
END FUNCTION.
FUNCTION get-cli-name RETURNS CHARACTER
 ( BUFFER loc-fin-schet FOR ub.fin-schet ) :
define buffer buf_clients for ub.clients.
find first buf_clients no-lock where
            buf_clients.obj-type = loc-fin-schet.cli-type
                AND    buf_clients.obj-code = loc-fin-schet.cli-code  no-error.
if available buf_clients then
RETURN (buf_clients.obj-name).
return (loc-fin-schet.cli-type + string(loc-fin-schet.cli-code)).
END FUNCTION.
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-fin-schet FOR ub.fin-schet ) :
define buffer buf_currency for ub.currency.
find first buf_currency no-lock where
            buf_currency.curr-code = loc-fin-schet.curr-code no-error.
if available buf_currency then
  RETURN buf_currency.curr-abbr.
return string(loc-fin-schet.curr-code).
END FUNCTION.
