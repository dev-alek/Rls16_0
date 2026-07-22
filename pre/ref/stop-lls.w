DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_dis-card FOR ub.dis-card.
DEFINE BUFFER X_stop-list-line FOR ub.stop-list-line.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
define input parameter p-stop-list-code as character no-undo .
define input parameter p-d-card as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Один стоплист по ДК".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info10 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info10, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info10, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info10, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info10 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info10, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info10 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info10, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info10, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info10, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info10, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info10, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info10 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info10 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info10, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info10, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info10 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info10 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info10, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info10, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
FUNCTION calldscr returns character ( input p-call-id as character):
define variable v-descr as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo.
define variable v-prop-label as character no-undo .
define variable v-node-label as character no-undo .
define variable v-dt-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-label as character no-undo .
define variable v-node-code as integer no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-map for ub.prop-map.
run gen-key-fv in this-procedure ( input p-call-id
                                  ,output v-field-list
                                  ,output v-value-list) no-error .
if error-status:error then return p-call-id.
CASE entry(1, p-call-id, chr(3)):
  when 'dis-card-type':U then do:
    v-descr = substitute("Тип ДК: эмитент &1 тип: &2"
                         ,integer(entry(lookup("emitent-host-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ,entry(lookup("type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card':U then do:
    v-descr = substitute("ДК: № &1"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card-property':U then do:
    v-dt-code = integer(entry(lookup("dt-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-node-code = integer(entry(lookup("node-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-host-code = integer(entry(lookup("host-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-obj-type = entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3)) .
    v-obj-code = integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    find first buf_prop-ref no-lock where
              buf_prop-ref.dt-code = v-dt-code no-error .
    if available buf_prop-ref then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error .
      v-prop-label = buf_prop-head.prop-label.
      find first buf_prop-map no-lock where
                buf_prop-map.dtm-code = buf_prop-ref.dtm-code
            and buf_prop-map.node-code = v-node-code no-error .
      if available buf_prop-map then do:
        v-label = buf_prop-map.node-label.
      end.
    end.
    v-descr = substitute("ДК: № &1 &2:&3 &4"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ,v-prop-label
                         ,v-label
                         ,get-region(v-host-code, v-obj-type, v-obj-code)
                         ).
  end.
  when 'clients':U then do:
    v-descr = substitute("&1&2"
                         ,entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ,integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ).
  end.
  when 'ext-system':U then do:
    v-descr = substitute("Внешняя система &1"
                         ,integer(entry(lookup("esys-id", v-field-list, chr(3)), v-value-list, chr(3)))
                         ).
  end.
  WHEN 'thbj-attr':U then do:
    if entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum':U
    or entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum_obj':U
    then do:
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'goods':U then do:
        v-descr = "Операции с товарами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'clients':U then do:
        v-descr = "Операции с клиентами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'gds-grp':U then do:
        v-descr = "Операции с группами товаров".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'cli-grp':U then do:
        v-descr = "Операции с группами клиентов".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th':U then do:
        v-descr = "Операции с чеками на POS IBS-TH".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th-mob':U then do:
        v-descr = "Операции с чеками на POS IBS-TH-MOB".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'edoc':U then do:
        v-descr = "Операции в системе электронного документооборота".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'thref':U then do:
        v-descr = "Операции со справочниками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'pdf':U then do:
        v-descr = "Операции с ДНЦ и переоценками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rep':U then do:
        v-descr = "Отчеты".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'ord':U then do:
        v-descr = "Операции с заказами".
      end.
    end.
  end.
  when 'cash-desk':U then do:
    v-descr = substitute("БД &1 Маг &2 Касса № &4 &3"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("cash-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("pos-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'ext-file':U then do:
    v-descr = substitute("БД &1 Файл № &3 (из БД &2)"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("from-db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("file-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
end case.
return v-descr.
end function.
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  NEW SHARED  temp-table dc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def NEW SHARED temp-table cli-list no-undo like ub.clients
  field to-del as logical
  index obj  is primary unique obj-type obj-code
  index cli-name      obj-name
  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  NEW SHARED  temp-table cli-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable filter-label as character no-undo .
define variable filter-label0 as character no-undo init "Стоплист" .
define variable filter-point as character no-undo .
define variable filter-point0 as character no-undo init "stop-lls" .
DEFINE VARIABLE sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define buffer buf_stop-list for ub.stop-list.
DEFINE BUFFER buf_dis-card FOR ub.dis-card.
define buffer buf_clients for ub.clients.
DEFINE VARIABLE v-doc-date AS DATE NO-UNDO.
DEFINE VARIABLE v-sl-status AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-card-resource-id AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-client-resource-id AS CHARACTER NO-UNDO.
DEFINE variable add-option AS CHARACTER NO-UNDO.
DEFINE variable chg-option AS CHARACTER NO-UNDO.
DEFINE variable del-option AS CHARACTER NO-UNDO.
FUNCTION get-sl-doc-date RETURNS DATE
  ( INPUT p-stop-list-code AS CHARACTER )  FORWARD.
FUNCTION get-sl-status RETURNS CHARACTER
  ( INPUT p-stop-list-code AS CHARACTER )  FORWARD.
DEFINE MENU MENU-b-add
       MENU-ITEM m_list-add     LABEL "Стоп-карта по списку"
       MENU-ITEM m_one-add      LABEL "Стоп-карта по одной"
       MENU-ITEM m_list-add-client LABEL "Стоп-клиент по списку"
       MENU-ITEM m_one-add-client LABEL "Стоп-клиент по одному".
DEFINE MENU MENU-b-chg
       MENU-ITEM m_selected-chg LABEL "Отмеченные"
       MENU-ITEM m_one-chg      LABEL "Один"          .
DEFINE MENU MENU-b-del
       MENU-ITEM m_selected-del LABEL "Отмеченные"
       MENU-ITEM m_one-del      LABEL "Одна карта"
       MENU-ITEM m_client-del   LABEL "ВСЕ карты клиента".
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-cli
     LABEL "Клиент"
     SIZE 10 BY 1.
DEFINE BUTTON B-cli-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "ДК"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE VARIABLE fi-search AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sch-cli-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Код клиента"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE sch-d-card AS CHARACTER FORMAT "X(19)":U
     LABEL "№ ДК"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE RS-cli-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 1", "2"
     SIZE 14.13 BY 1 NO-UNDO.
DEFINE QUERY br-stop-list-line FOR
                X_stop-list-line,
                X_DIS-CARD,
                X_clients SCROLLING.
DEFINE BROWSE br-stop-list-line
  QUERY br-stop-list-line NO-LOCK DISPLAY
      mark-string(recid(X_stop-list-line), v-rid-list) COLUMN-LABEL "*" FORMAT "X(2)"
X_stop-list-line.line-num COLUMN-LABEL "№№" FORMAT ">>>>>>>>9"
X_stop-list-line.charkey_one COLUMN-LABEL "№ ДК" FORMAT "X(19)"
(X_clients.obj-type + string(X_clients.obj-code)) COLUMN-LABEL "Клиент" FORMAT "X(12)"
X_clients.obj-name COLUMN-LABEL "Наимен.Держателя карты" FORMAT "X(105)" WIDTH 40
entry (lookup (string(X_stop-list-line.key#_one), '1,2,3,4':U) + 1, ',':U + 'стоп-карта,стоп-клиент,стоп-карта;стоп-клиент,удал-карта':U) COLUMN-LABEL "Флаг" FORMAT "X(20)"
calldscr(X_stop-list-line.resource_id) COLUMN-LABEL "Заблокированный!ресурс" FORMAT "X(19)"
X_stop-list-line.stop-list-code COLUMN-LABEL "№ стоплиста" FORMAT "X(9)"
get-sl-doc-date(X_stop-list-line.stop-list-code) @ v-doc-date COLUMN-LABEL "Дата" FORMAT "99/99/9999"
get-sl-status(X_stop-list-line.stop-list-code) @ v-sl-status COLUMN-LABEL "Статус" FORMAT "X(8)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.88 BY 18 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     b-add AT ROW 1 COL 31 WIDGET-ID 2
     b-chg AT ROW 1 COL 41 WIDGET-ID 4
     b-del AT ROW 1 COL 51 WIDGET-ID 6
     b-lkp AT ROW 1 COL 71
     b-cli AT ROW 1 COL 81
     b-print AT ROW 1 COL 89
     b-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     sch-d-card AT ROW 2.08 COL 16 COLON-ALIGNED
     sch-cli-code AT ROW 3 COL 48.5 COLON-ALIGNED
     RS-cli-type AT ROW 3.08 COL 18 NO-LABEL
     B-cli-2 AT ROW 3.08 COL 33
     br-stop-list-line AT ROW 4 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     fi-search AT ROW 2.33 COL 1.5 NO-LABEL WIDGET-ID 8
     SPACE(88.40) SKIP(19.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Стоплист"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE.
ASSIGN
       b-chg:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-chg:HANDLE.
ASSIGN
       b-del:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-del:HANDLE.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
     IF add-option = '':U THEN DO:
     run gbl/pop-up.p ( input self:handle, input no) no-error.
    if error-status:error or add-option = "":U then return no-apply.
  END.
  RUN proc-b-add IN THIS-PROCEDURE ( add-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      add-option = "":U.
      RETURN NO-APPLY.
  END.
  add-option = "":U.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  IF chg-option = '':U THEN DO:
     run gbl/pop-up.p ( input self:handle, input no) no-error.
    if error-status:error or chg-option = "":U then return no-apply.
  END.
  RUN proc-b-chg IN THIS-PROCEDURE ( chg-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      chg-option = "":U.
      RETURN NO-APPLY.
  END.
  chg-option = "":U.
END.
ON CHOOSE OF b-cli IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_stop-list-line THEN RETURN NO-APPLY.
  run ref/showcli.p ( INPUT parparentproc
                 ,INPUT X_dis-card.cli-type
                 ,INPUT X_dis-card.cli-code) NO-ERROR.
END.
ON CHOOSE OF B-cli-2 IN FRAME Dialog-Frame
DO:
define variable ref-list as character no-undo.
define variable ref-rec as recid no-undo.
define buffer buf_clients for ub.clients.
  run ref/cli-all.w ( input parParentProc
                  ,input "b-sel"
                  ,input RS-cli-type
                  ,input ?
                  ,input ?
                  ,input ?
                  ,input ?
                  ,input "":U
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
  apply "return" to sch-cli-code.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  IF del-option = '':U THEN DO:
    run gbl/pop-up.p ( input self:handle, input no) no-error.
    if error-status:error or del-option = "":U then return no-apply.
  END.
  RUN proc-b-del IN THIS-PROCEDURE ( del-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      del-option = "":U.
      RETURN NO-APPLY.
  END.
  del-option = "":U.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-ri AS RECID NO-UNDO.
DEFINE BUFFER buf_dis-card FOR ub.dis-card.
 IF NOT AVAILABLE X_stop-list-line THEN RETURN NO-APPLY.
 FIND FIRST buf_dis-card NO-LOCK WHERE
            buf_dis-card.d-card = X_stop-list-line.charkey_one NO-ERROR.
IF NOT AVAILABLE buf_dis-card THEN DO:
   MESSAGE
   substitute("Не найдена карта &1", X_stop-list-line.charkey_one)
   VIEW-AS ALERT-BOX ERROR.
   RETURN NO-APPLY.
END.
v-ri = recid( buf_dis-card ) .
run ref/dcardi.w (
                      input parparentproc
                    , input 'ПРОСМОТР':U
                    , input buf_dis-card.emitent-host-code
                    , input v-cntxt-host-code-obj
                    , INPUT v-cntxt-obj-type
                    , input v-cntxt-obj-code
                    , input ?
                    , input-output v-ri ) no-error.
apply "entry" to br-stop-list-line.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo .
  if available X_stop-list-line then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid20 as character no-undo .
define variable v-num-entry20 as integer   no-undo .
assign
  v-str-recid20 = trim( string( recid( X_stop-list-line ) , "->>>>>>>>>>>9":U ) )
  v-num-entry20 = lookup( v-str-recid20 , v-rid-list )
.
if v-num-entry20 > 0 then do:
  assign
    entry( v-num-entry20, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid20
  .
end.
    loc#log = br-stop-list-line:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-stop-list-line:select-next-row ().
        apply "VALUE-CHANGED" to br-stop-list-line in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-stop-list-line in frame Dialog-Frame.
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
  run proc-b-print IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
    if ( available X_stop-list-line ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_stop-list-line ) ) .
  end.
END.
ON CHOOSE OF MENU-ITEM m_client-del
DO:
  if not available X_stop-list-line  then undo, return no-apply.
  ASSIGN
  del-OPTION = "client":U.
  RUN proc-b-del IN THIS-PROCEDURE  ( del-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    del-option = '':U.
    RETURN NO-APPLY.
  END.
  del-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_list-add
DO:
  ASSIGN
  ADD-OPTION = "list":U.
  RUN proc-b-add IN THIS-PROCEDURE  ( add-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    add-option = '':U.
    RETURN NO-APPLY.
  END.
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_list-add-client
DO:
    ASSIGN
    ADD-OPTION = "list-client":U.
    RUN proc-b-add IN THIS-PROCEDURE  ( add-option) NO-ERROR.
    IF error-status:ERROR THEN DO:
      add-option = '':U.
      RETURN NO-APPLY.
    END.
    add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_one-add
DO:
  ASSIGN
  ADD-OPTION = "one":U.
  RUN proc-b-add IN THIS-PROCEDURE  ( add-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    add-option = '':U.
    RETURN NO-APPLY.
  END.
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_one-add-client
DO:
  ASSIGN
  ADD-OPTION = "one-client":U.
  RUN proc-b-add IN THIS-PROCEDURE  ( add-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    add-option = '':U.
    RETURN NO-APPLY.
  END.
  add-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_one-chg
DO:
  if not available X_stop-list-line  then undo, return no-apply .
  ASSIGN
  chg-OPTION = "one":U.
  RUN proc-b-chg IN THIS-PROCEDURE  ( chg-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    chg-option = '':U.
    RETURN NO-APPLY.
  END.
  chg-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_one-del
DO:
  if not available X_stop-list-line  then undo, return no-apply.
  ASSIGN
  del-OPTION = "one":U.
  RUN proc-b-del IN THIS-PROCEDURE  ( del-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    del-option = '':U.
    RETURN NO-APPLY.
  END.
  del-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_selected-chg
DO:
 if v-rid-list = '':U then do:
    message
    "Ничего не отмечено"
    view-as alert-box error .
    undo, return no-apply.
  end.
  ASSIGN
  chg-OPTION = "selected":U.
  RUN proc-b-chg IN THIS-PROCEDURE  ( chg-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    chg-option = '':U.
    RETURN NO-APPLY.
  END.
  chg-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_selected-del
DO:
   ASSIGN
  del-OPTION = "selected":U.
  RUN proc-b-del IN THIS-PROCEDURE  ( del-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    del-option = '':U.
    RETURN NO-APPLY.
  END.
  del-option = '':U.
END.
ON VALUE-CHANGED OF RS-cli-type IN FRAME Dialog-Frame
DO:
  assign
  RS-cli-type.
END.
ON RETURN OF sch-cli-code IN FRAME Dialog-Frame
DO:
  run Openbr in this-procedure ( input YES, INPUT NO, input '':U, rs-cli-type, INPUT FRAME Dialog-Frame sch-cli-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-d-card IN FRAME Dialog-Frame
DO:
    run proc-find-d-card in this-procedure ( input yes, input frame Dialog-Frame sch-D-CARD) no-error.
   if error-status:error then return no-apply.
END.
ON RETURN OF sch-d-card IN FRAME Dialog-Frame
DO:
    run proc-find-d-card in this-procedure ( input NO, input frame Dialog-Frame sch-d-card) no-error.
   if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-stop-list-line :handle
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-stop-list-line :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   if available X_stop-list-line then v-doc-rec = recid(X_stop-list-line).     RUn OpenBr in this-procedure ( input yes, input no, input '':U, input rs-cli-type, input frame Dialog-Frame sch-cli-code).     reposition br-stop-list-line to recid v-doc-rec no-error.
    apply "VALUE-CHANGED" to br-stop-list-line.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 if not (p-mode = 'ИЗМЕНЕНИЕ':U
       or p-mode = 'ПРОСМОТР':U) then do:
    message
    substitute("Неверное значение параметра p-mode=&1 ", p-mode)
    view-as alert-box error.
    undo main-block, return error .
  end.
  ASSIGN
  v-rid-list = p-rid-list.
 case p-mode:
    when  'ПРОСМОТР':U then do:
      if p-stop-list-code <> "":U
      then do:
        find first buf_stop-list no-lock where
                  buf_stop-list.stop-list-code = p-stop-list-code
            AND buf_stop-list.classif-type = 'dis-card':U  no-error.
        if not available buf_stop-list then do:
          message
          substitute("Не найден стоплист ДК &1", p-stop-list-code)
          view-as alert-box error .
          undo, return error .
        end.
      end.
      if p-d-card <> '':U then do:
        find first buf_Dis-card no-lock where
                  buf_Dis-card.d-card = p-d-card no-error.
        if not available buf_Dis-card then do:
          message
          substitute("Не найдена ДК &1", p-d-card)
          view-as alert-box error .
          undo, return error .
        end.
        find first buf_clients no-lock where
                  buf_clients.obj-type = buf_Dis-card.cli-type
              and buf_clients.obj-code = buf_Dis-card.cli-code no-error.
        if not available buf_Dis-card then do:
          message
          substitute("Не найден держатель карты ДК &1 &2&3"
                      , p-d-card
                      , buf_Dis-card.cli-type
                      , buf_Dis-card.cli-code
                      )
          view-as alert-box error .
          undo, return error .
        end.
        RUN gen-key-rec IN THIS-PROCEDURE ( INPUT 'dis-card':U
                                           ,INPUT BUFFER buf_dis-card:HANDLE
                                           ,OUTPUT v-card-resource-id).
        RUN gen-key-rec IN THIS-PROCEDURE ( INPUT 'clients':U
                                           ,INPUT BUFFER buf_clients:HANDLE
                                           ,OUTPUT v-client-resource-id).
      end.
    end.
    when 'ИЗМЕНЕНИЕ':U then do:
      if p-d-card <> '':U then do:
        message
        substitute("Неверное значение параметре p-d-card=&1&2Данный параметр при редактировании задан быть не может"
                    , p-d-card
                    , chr(10))
        view-as alert-box error .
        undo main-block, return error .
      end.
      do transaction:
      find first buf_stop-list exclusive-lock where
                buf_stop-list.stop-list-code = p-stop-list-code
          AND buf_stop-list.classif-type = 'dis-card':U  no-error.
      end.
      if not available buf_stop-list then do:
        message
        substitute("Не найден стоплист &1", p-stop-list-code)
        view-as alert-box error .
        undo main-block, return error .
      end.
      if buf_stop-list.status_ = 'факт':U then do:
        message
        substitute("Стоплист &1 находится в статусе &2&3Изменение невозможно"
                    , p-stop-list-code
                    , buf_stop-list.status_
                    , chr(10)
                    )
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.
  end case.
  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
  IF v-rid-list <> '':U THEN DO:
    REPOSITION br-stop-list-line to RECID INTEGER(entry(1, v-rid-list)) NO-ERROR.
    APPLY "entry" to br-stop-list-line.
    APPLY "value-changed" TO br-stop-list-line.
  END.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY sch-d-card sch-cli-code RS-cli-type mark-num fi-search
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-add b-chg b-del b-lkp b-cli b-print b-sch B-Help
         sch-d-card sch-cli-code RS-cli-type B-cli-2 br-stop-list-line mark-num
         fi-search
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-stop-list-line FOR EACH X_stop-list-line NO-LOCK WHERE         X_stop-list-line.classif-type = 'dis-card':U      AND X_stop-list-line.stop-list-code = p-stop-list-code ,            FIRST X_DIS-CARD NO-LOCK WHERE          X_dis-card.d-card = X_stop-list-line.charkey_one,            first  X_clients NO-LOCK WHERE          X_clients.obj-type  = X_dis-card.cli-type     AND  X_clients.obj-code  = X_dis-card.cli-code     INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE variable v-h AS HANDLE NO-UNDO.
ASSIGN
RS-cli-type:radio-buttons IN FRAME Dialog-Frame = 'орг':U + chr(44) + 'орг':U + chr(44) + 'чел':U + chr(44) + 'чел':U
X_clients.obj-name:RESIZABLE IN BROWSE br-stop-list-line = YES
RS-cli-type = 'орг':U
b-add:MENU-MOUSE in FRAME Dialog-Frame = 1
b-chg:MENU-MOUSE in FRAME Dialog-Frame = 1
b-del:MENU-MOUSE in FRAME Dialog-Frame = 1
v-h = br-stop-list-line:FIRST-COLUMN IN FRAME Dialog-Frame
.
DO while valid-handle(v-h) :
  if (v-h:LABEL = "Клиент" and p-d-card <> '')
  OR (v-h:LABEL = "Заблокированный!ресурс" and p-d-card <> '')
  then do:
    v-h:visible = no.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
ASSIGN
v-doc-date:VISIBLE IN BROWSE br-stop-list-line = (p-d-card <> '')
v-sl-status:VISIBLE IN BROWSE br-stop-list-line = (p-d-card <> '')
X_stop-list-line.charkey_one:VISIBLE IN BROWSE br-stop-list-line = (p-d-card = '')
X_clients.obj-name:VISIBLE IN BROWSE br-stop-list-line = (p-d-card = '')
.
display
rs-cli-type
with frame Dialog-Frame .
ENABLE
b-quit
B-mark  when lookup("b-mark", bttns) > 0 OR P-MODE <> 'ПРОСМОТР':U
B-sel when lookup("b-sel", bttns) > 0
b-add WHEN p-mode <> 'ПРОСМОТР':U and not transaction
b-CHG WHEN p-mode <> 'ПРОСМОТР':U and not transaction
b-DEL WHEN p-mode <> 'ПРОСМОТР':U and not transaction
b-sch  when p-d-card = '':U
b-cli
b-print
b-lkp
B-Help
RS-cli-type when p-d-card = '':U
sch-cli-code when p-d-card = '':U
sch-d-card when p-d-card = '':U
B-CLI-2 when p-d-card = '':U
BR-stop-list-line
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
if p-d-card <> '':U then do:
  hide
  RS-cli-type
  sch-cli-code
  sch-d-card
  B-CLI-2
  rs-cli-type
  fi-search
  in frame Dialog-Frame .
end.
run openbr in this-procedure ( input yes, input no, input '':U, input rs-cli-type, input frame Dialog-Frame sch-cli-code).
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
DEFINE INPUT PARAMETER p-cli-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-cli-code AS integer NO-UNDO.
OPEN QUERY br-stop-list-line FOR EACH X_stop-list-line NO-LOCK WHERE         X_stop-list-line.classif-type = 'dis-card':U      AND X_stop-list-line.stop-list-code = p-stop-list-code ,            FIRST X_DIS-CARD NO-LOCK WHERE          X_dis-card.d-card = X_stop-list-line.charkey_one,            first  X_clients NO-LOCK WHERE          X_clients.obj-type  = X_dis-card.cli-type     AND  X_clients.obj-code  = X_dis-card.cli-code     INDEXED-REPOSITION.
APPLY "entry" to br-stop-list-line in frame Dialog-Frame .
APPLY "value-changed" TO br-stop-list-line.
define variable l-query-was-opened as logical no-undo .
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
if p-d-card = '':u then do:
  IF p-cli-code = 0 THEN DO:
    if p-open-query then do:
      ASSIGN
      FRAME Dialog-Frame:TITLE = substitute("ДИСКОНТНЫЕ КАРТЫ СТОПЛИСТА &1"
                                            , p-stop-list-code
                                            ).
    end.
    assign
    filter-label = substitute("&1: ДК одного СТОПЛИСТА", filter-label0)
    filter-point = filter-point0
    .
      if sort-column-name = '':u then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-34  as logical   no-undo .
define variable  l-filter-open-34    as logical   .
define variable  flt-rec-34       as recid     no-undo .
define variable  filter-name-34      as character no-undo .
define variable  where-phrase-34     as character no-undo .
define variable  sort-phrase-34      as character no-undo .
define variable  where-phrase-rus-34 as character no-undo .
define variable  sort-phrase-rus-34  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-34
  ,output filter-name-34
  ,output where-phrase-34
  ,output sort-phrase-34
  ,output where-phrase-rus-34
  ,output sort-phrase-rus-34
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-34
      ) no-error .
  assign
    l-filter-open-34 = false
  .
  if flt-rec-34 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-34 as character no-undo .
    define variable  parameter-3-34 as character no-undo .
    define variable  parameter-4-34 as character no-undo .
    define variable  parameter-5-34 as character no-undo .
    define variable  parameter-6-34 as character no-undo .
    define variable  parameter-7-34 as character no-undo .
      assign
      parameter-3-34 =
                              "FOR EACH X_stop-list-line"
      parameter-4-34 =
        (
          if (" X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.stop-list-code =  p-stop-list-code " + " " + where-phrase-34) <> ""
          then  substitute('X_stop-list-line.classif-type = &1&2&1                            and X_stop-list-line.stop-list-code =  &1&3&1 ', chr(34), 'dis-card':U, p-stop-list-code) + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + ", FIRST X_dis-card NO-LOCK WHERE                                           X_dis-card.d-card = X_stop-list-line.charkey_one                                 , FIRST X_clients NO-LOCK WHERE                                                       X_clients.obj-type = X_dis-card.cli-type                                    and X_clients.obj-code = X_dis-card.cli-code")
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_stop-list-line.charkey_one "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-34
        )
      parameter-7-34 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-34 =
          (" X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.stop-list-code =  p-stop-list-code " + " " + where-phrase-34 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-stop-list-line:handle
                          ,input parameter-3-34
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ,input parameter-6-34
                          ,input parameter-7-34
                          )
      .
      assign
        l-filter-open-34 = true
      .
    end.
    if l-filter-open-34 = false then do:
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
  if l-filter-open-34 = false then do:
    OPEN QUERY br-stop-list-line FOR EACH X_stop-list-line
      where  X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.stop-list-code =  p-stop-list-code
    , FIRST X_dis-card NO-LOCK WHERE                                           X_dis-card.d-card = X_stop-list-line.charkey_one                                 , FIRST X_clients NO-LOCK WHERE                                                       X_clients.obj-type = X_dis-card.cli-type                                    and X_clients.obj-code = X_dis-card.cli-code
       by X_stop-list-line.charkey_one
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_stop-list-line )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-stop-list-line:handle:get-buffer-handle(1) = (buffer X_stop-list-line:handle) then do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-4-34 =
        "where ":u +  substitute('X_stop-list-line.classif-type = &1&2&1                            and X_stop-list-line.stop-list-code =  &1&3&1 ', chr(34), 'dis-card':U, p-stop-list-code) + " ":u + where-phrase-34 + " ":u + p-find-condition + " " + ""
      parameter-5-34 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-stop-list-line:handle
                          ,input rowid(X_stop-list-line)
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input (buffer X_stop-list-line:handle)
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-3-34 =  "FOR EACH X_stop-list-line"
      parameter-4-34 =
        (
          if (" X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.stop-list-code =  p-stop-list-code " + " " + where-phrase-34) <> ""
          then  substitute('X_stop-list-line.classif-type = &1&2&1                            and X_stop-list-line.stop-list-code =  &1&3&1 ', chr(34), 'dis-card':U, p-stop-list-code) + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + ", FIRST X_dis-card NO-LOCK WHERE                                           X_dis-card.d-card = X_stop-list-line.charkey_one                                 , FIRST X_clients NO-LOCK WHERE                                                       X_clients.obj-type = X_dis-card.cli-type                                    and X_clients.obj-code = X_dis-card.cli-code" + " " + p-find-condition)
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_stop-list-line.charkey_one "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-34
        )
      parameter-7-34 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-stop-list-line:handle
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input parameter-3-34
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ,input parameter-6-34
                          ,input parameter-7-34
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
      end.
  END.
  ELSE DO:
    if p-open-query then do:
      ASSIGN
      FRAME Dialog-Frame:TITLE = substitute("ДИСКОНТНЫЕ КАРТЫ СТОПЛИСТА &1 &2"
                                           , p-stop-list-code
                                           , buf_stop-list.stop-list-code
                                           ).
    end.
    assign
      filter-label = substitute("&1: ДК одного СТОПЛИСТА", filter-label0)
      filter-point = filter-point0
      .
      if sort-column-name = '':u then do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-36  as logical   no-undo .
define variable  l-filter-open-36    as logical   .
define variable  flt-rec-36       as recid     no-undo .
define variable  filter-name-36      as character no-undo .
define variable  where-phrase-36     as character no-undo .
define variable  sort-phrase-36      as character no-undo .
define variable  where-phrase-rus-36 as character no-undo .
define variable  sort-phrase-rus-36  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-36
  ,output filter-name-36
  ,output where-phrase-36
  ,output sort-phrase-36
  ,output where-phrase-rus-36
  ,output sort-phrase-rus-36
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-36
      ) no-error .
  assign
    l-filter-open-36 = false
  .
  if flt-rec-36 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-36 as character no-undo .
    define variable  parameter-3-36 as character no-undo .
    define variable  parameter-4-36 as character no-undo .
    define variable  parameter-5-36 as character no-undo .
    define variable  parameter-6-36 as character no-undo .
    define variable  parameter-7-36 as character no-undo .
      assign
      parameter-3-36 =
                              "FOR EACH X_stop-list-line"
      parameter-4-36 =
        (
          if (" X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.stop-list-code = p-stop-list-code                             " + " " + where-phrase-36) <> ""
          then  substitute('X_stop-list-line.classif-type = &1&2&1                            and X_stop-list-line.stop-list-code = &1&3&1 ', chr(34), 'dis-card':U, p-stop-list-code)
                             + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + substitute(', FIRST X_dis-card NO-LOCK WHERE                                           X_dis-card.d-card = X_stop-list-line.charkey_one                                      AND X_dis-card.cli-type = &1&2&1                                      AND X_dis-card.cli-code = &3                                 , FIRST X_clients NO-LOCK WHERE                                        X_clients.obj-type = X_dis-card.cli-type                                    and X_clients.obj-code = X_dis-card.cli-code', chr(34), p-cli-type, p-cli-code))
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_stop-list-line.charkey_one "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-36
        )
      parameter-7-36 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-36 =
          (" X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.stop-list-code = p-stop-list-code                             " + " " + where-phrase-36 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-stop-list-line:handle
                          ,input parameter-3-36
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ,input parameter-6-36
                          ,input parameter-7-36
                          )
      .
      assign
        l-filter-open-36 = true
      .
    end.
    if l-filter-open-36 = false then do:
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
  if l-filter-open-36 = false then do:
    OPEN QUERY br-stop-list-line FOR EACH X_stop-list-line
      where  X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.stop-list-code = p-stop-list-code
    , FIRST X_dis-card NO-LOCK WHERE                                           X_dis-card.d-card = X_stop-list-line.charkey_one                                      AND X_dis-card.cli-type = p-cli-type                                      AND X_dis-card.cli-code = p-cli-code                                 , FIRST X_clients NO-LOCK WHERE                                        X_clients.obj-type = X_dis-card.cli-type                                    and X_clients.obj-code = X_dis-card.cli-code
       by X_stop-list-line.charkey_one
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_stop-list-line )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-stop-list-line:handle:get-buffer-handle(1) = (buffer X_stop-list-line:handle) then do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-4-36 =
        "where ":u +  substitute('X_stop-list-line.classif-type = &1&2&1                            and X_stop-list-line.stop-list-code = &1&3&1 ', chr(34), 'dis-card':U, p-stop-list-code)
                             + " ":u + where-phrase-36 + " ":u + p-find-condition + " " + ""
      parameter-5-36 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-stop-list-line:handle
                          ,input rowid(X_stop-list-line)
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input (buffer X_stop-list-line:handle)
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-3-36 =  "FOR EACH X_stop-list-line"
      parameter-4-36 =
        (
          if (" X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.stop-list-code = p-stop-list-code                             " + " " + where-phrase-36) <> ""
          then  substitute('X_stop-list-line.classif-type = &1&2&1                            and X_stop-list-line.stop-list-code = &1&3&1 ', chr(34), 'dis-card':U, p-stop-list-code)
                             + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + substitute(', FIRST X_dis-card NO-LOCK WHERE                                           X_dis-card.d-card = X_stop-list-line.charkey_one                                      AND X_dis-card.cli-type = &1&2&1                                      AND X_dis-card.cli-code = &3                                 , FIRST X_clients NO-LOCK WHERE                                        X_clients.obj-type = X_dis-card.cli-type                                    and X_clients.obj-code = X_dis-card.cli-code', chr(34), p-cli-type, p-cli-code) + " " + p-find-condition)
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_stop-list-line.charkey_one "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-36
        )
      parameter-7-36 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-stop-list-line:handle
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input parameter-3-36
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ,input parameter-6-36
                          ,input parameter-7-36
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
      end.
    END.
END.
ELSE DO:
  IF p-cli-code = 0 THEN DO:
    if p-open-query then do:
      ASSIGN
      FRAME Dialog-Frame:TITLE = substitute("СТОПЛИСТЫ ДИСКОНТНОЙ КАРТЫ &1"
                                                , p-d-card
                                                ).
    end.
    assign
    filter-label = substitute("&1: СТОПЛИСТЫ одной ДК", filter-label0)
    filter-point = filter-point0 + chr(44) + "one"
    .
      if sort-column-name = '':u then do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-38  as logical   no-undo .
define variable  l-filter-open-38    as logical   .
define variable  flt-rec-38       as recid     no-undo .
define variable  filter-name-38      as character no-undo .
define variable  where-phrase-38     as character no-undo .
define variable  sort-phrase-38      as character no-undo .
define variable  where-phrase-rus-38 as character no-undo .
define variable  sort-phrase-rus-38  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-38
  ,output filter-name-38
  ,output where-phrase-38
  ,output sort-phrase-38
  ,output where-phrase-rus-38
  ,output sort-phrase-rus-38
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-38
      ) no-error .
  assign
    l-filter-open-38 = false
  .
  if flt-rec-38 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-38 as character no-undo .
    define variable  parameter-3-38 as character no-undo .
    define variable  parameter-4-38 as character no-undo .
    define variable  parameter-5-38 as character no-undo .
    define variable  parameter-6-38 as character no-undo .
    define variable  parameter-7-38 as character no-undo .
      assign
      parameter-3-38 =
                              "FOR EACH X_stop-list-line"
      parameter-4-38 =
        (
          if (" X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.charkeY_one = p-d-card " + " " + where-phrase-38) <> ""
          then  substitute('X_stop-list-line.classif-type = &1&2&1                            and X_stop-list-line.charkeY_one = &1&3&1 ', chr(34), 'dis-card':U, p-d-card) + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + substitute(', FIRST X_dis-card NO-LOCK WHERE                                           X_dis-card.d-card = X_stop-list-line.charkey_one                                      AND X_dis-card.cli-type = &1&2&1                                      AND X_dis-card.cli-code = &3                                 , FIRST X_clients NO-LOCK WHERE                                        X_clients.obj-type = X_dis-card.cli-type                                    and X_clients.obj-code = X_dis-card.cli-code', chr(34), p-cli-type, p-cli-code))
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_stop-list-line.charkey_one "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-38
        )
      parameter-7-38 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-38 =
          (" X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.charkeY_one = p-d-card " + " " + where-phrase-38 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-stop-list-line:handle
                          ,input parameter-3-38
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ,input parameter-6-38
                          ,input parameter-7-38
                          )
      .
      assign
        l-filter-open-38 = true
      .
    end.
    if l-filter-open-38 = false then do:
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
  if l-filter-open-38 = false then do:
    OPEN QUERY br-stop-list-line FOR EACH X_stop-list-line
      where  X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.charkeY_one = p-d-card
    , FIRST X_dis-card NO-LOCK WHERE                                           X_dis-card.d-card = X_stop-list-line.charkey_one                                 , FIRST X_clients NO-LOCK WHERE                                                       X_clients.obj-type = X_dis-card.cli-type                                    and X_clients.obj-code = X_dis-card.cli-code
       by X_stop-list-line.charkey_one
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_stop-list-line )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-stop-list-line:handle:get-buffer-handle(1) = (buffer X_stop-list-line:handle) then do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-4-38 =
        "where ":u +  substitute('X_stop-list-line.classif-type = &1&2&1                            and X_stop-list-line.charkeY_one = &1&3&1 ', chr(34), 'dis-card':U, p-d-card) + " ":u + where-phrase-38 + " ":u + p-find-condition + " " + ""
      parameter-5-38 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-stop-list-line:handle
                          ,input rowid(X_stop-list-line)
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input (buffer X_stop-list-line:handle)
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-3-38 =  "FOR EACH X_stop-list-line"
      parameter-4-38 =
        (
          if (" X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.charkeY_one = p-d-card " + " " + where-phrase-38) <> ""
          then  substitute('X_stop-list-line.classif-type = &1&2&1                            and X_stop-list-line.charkeY_one = &1&3&1 ', chr(34), 'dis-card':U, p-d-card) + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + substitute(', FIRST X_dis-card NO-LOCK WHERE                                           X_dis-card.d-card = X_stop-list-line.charkey_one                                      AND X_dis-card.cli-type = &1&2&1                                      AND X_dis-card.cli-code = &3                                 , FIRST X_clients NO-LOCK WHERE                                        X_clients.obj-type = X_dis-card.cli-type                                    and X_clients.obj-code = X_dis-card.cli-code', chr(34), p-cli-type, p-cli-code) + " " + p-find-condition)
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_stop-list-line.charkey_one "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-38
        )
      parameter-7-38 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-stop-list-line:handle
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input parameter-3-38
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ,input parameter-6-38
                          ,input parameter-7-38
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
      end.
  END.
  ELSE DO:
    if p-open-query then do:
    ASSIGN
    FRAME Dialog-Frame:TITLE = substitute("ДИСКОНТНЫЕ КАРТЫ СТОПЛИСТА &1 &2"
                                           , p-stop-list-code
                                           , buf_stop-list.stop-list-code
                                           ).
    end.
    assign
      filter-label = substitute("&1: СТОПЛИСТЫ одной ДК", filter-label0)
      filter-point = filter-point0 + chr(44) + "one"
      .
      if sort-column-name = '':u then do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-40  as logical   no-undo .
define variable  l-filter-open-40    as logical   .
define variable  flt-rec-40       as recid     no-undo .
define variable  filter-name-40      as character no-undo .
define variable  where-phrase-40     as character no-undo .
define variable  sort-phrase-40      as character no-undo .
define variable  where-phrase-rus-40 as character no-undo .
define variable  sort-phrase-rus-40  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-40
  ,output filter-name-40
  ,output where-phrase-40
  ,output sort-phrase-40
  ,output where-phrase-rus-40
  ,output sort-phrase-rus-40
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-40
      ) no-error .
  assign
    l-filter-open-40 = false
  .
  if flt-rec-40 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-40 as character no-undo .
    define variable  parameter-3-40 as character no-undo .
    define variable  parameter-4-40 as character no-undo .
    define variable  parameter-5-40 as character no-undo .
    define variable  parameter-6-40 as character no-undo .
    define variable  parameter-7-40 as character no-undo .
      assign
      parameter-3-40 =
                              "FOR EACH X_stop-list-line"
      parameter-4-40 =
        (
          if (" X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.stop-list-code = p-stop-list-code                             " + " " + where-phrase-40) <> ""
          then  substitute('X_stop-list-line.classif-type = &1&2&1                            and X_stop-list-line.stop-list-code = &1&3&1 ', chr(34), 'dis-card':U, p-stop-list-code)
                             + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + substitute(', FIRST X_dis-card NO-LOCK WHERE                                           X_dis-card.d-card = X_stop-list-line.charkey_one                                      AND X_dis-card.cli-type = &1&2&1                                      AND X_dis-card.cli-code = &3                                 , FIRST X_clients NO-LOCK WHERE                                        X_clients.obj-type = X_dis-card.cli-type                                    and X_clients.obj-code = X_dis-card.cli-code', chr(34), p-cli-type, p-cli-code))
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_stop-list-line.charkey_one "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-40
        )
      parameter-7-40 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-40 =
          (" X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.stop-list-code = p-stop-list-code                             " + " " + where-phrase-40 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-stop-list-line:handle
                          ,input parameter-3-40
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ,input parameter-6-40
                          ,input parameter-7-40
                          )
      .
      assign
        l-filter-open-40 = true
      .
    end.
    if l-filter-open-40 = false then do:
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
  if l-filter-open-40 = false then do:
    OPEN QUERY br-stop-list-line FOR EACH X_stop-list-line
      where  X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.stop-list-code = p-stop-list-code
    , FIRST X_dis-card NO-LOCK WHERE                                           X_dis-card.d-card = X_stop-list-line.charkey_one                                      AND X_dis-card.cli-type = p-cli-type                                      AND X_dis-card.cli-code = p-cli-code                                 , FIRST X_clients NO-LOCK WHERE                                        X_clients.obj-type = X_dis-card.cli-type                                    and X_clients.obj-code = X_dis-card.cli-code
       by X_stop-list-line.charkey_one
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_stop-list-line )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-stop-list-line:handle:get-buffer-handle(1) = (buffer X_stop-list-line:handle) then do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-4-40 =
        "where ":u +  substitute('X_stop-list-line.classif-type = &1&2&1                            and X_stop-list-line.stop-list-code = &1&3&1 ', chr(34), 'dis-card':U, p-stop-list-code)
                             + " ":u + where-phrase-40 + " ":u + p-find-condition + " " + ""
      parameter-5-40 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-stop-list-line:handle
                          ,input rowid(X_stop-list-line)
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input (buffer X_stop-list-line:handle)
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-3-40 =  "FOR EACH X_stop-list-line"
      parameter-4-40 =
        (
          if (" X_stop-list-line.classif-type = 'dis-card':U                            and X_stop-list-line.stop-list-code = p-stop-list-code                             " + " " + where-phrase-40) <> ""
          then  substitute('X_stop-list-line.classif-type = &1&2&1                            and X_stop-list-line.stop-list-code = &1&3&1 ', chr(34), 'dis-card':U, p-stop-list-code)
                             + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + substitute(', FIRST X_dis-card NO-LOCK WHERE                                           X_dis-card.d-card = X_stop-list-line.charkey_one                                      AND X_dis-card.cli-type = &1&2&1                                      AND X_dis-card.cli-code = &3                                 , FIRST X_clients NO-LOCK WHERE                                        X_clients.obj-type = X_dis-card.cli-type                                    and X_clients.obj-code = X_dis-card.cli-code', chr(34), p-cli-type, p-cli-code) + " " + p-find-condition)
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_stop-list-line.charkey_one "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-40
        )
      parameter-7-40 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-stop-list-line:handle
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input parameter-3-40
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ,input parameter-6-40
                          ,input parameter-7-40
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
      end.
  END.
END.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-stop-list-line to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-stop-list-line:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-stop-list-line in frame Dialog-Frame.
APPLY "ENTRY" TO br-stop-list-line.
END PROCEDURE.
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-add-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
define variable v-ok as integer no-undo .
define variable v-ok-old as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-num as integer no-undo .
define variable v-recid as recid no-undo .
define variable v-loc-rid-list as character no-undo .
define variable v-status-codes as character no-undo .
define variable v-sel-status-code as integer no-undo .
define variable v-status-codes-full as character no-undo .
define variable v-key-rec as character no-undo .
define variable choice as integer no-undo .
define buffer buf_Dis-card for ub.dis-card.
define buffer buf_clients for ub.clients.
define buffer exist_stop-list-line for Ub.stop-list-line.
case p-add-option:
  when "list" then do:
    v-sel-status-code = integer('1':U).
    for each dc-list:
      delete dc-list.
    end.
    run str/dc-list.w (
               input parparentproc
              ,input v-cntxt-host-code-obj
              ,input v-cntxt-obj-type
              ,input v-cntxt-obj-code) no-error.
    v-num = 0.
    for each dc-list no-lock:
      if dc-list.mask-card then next.
      v-num = v-num + 1.
      run ref/stop-ll1.p (
                        input 'ДОБАВЛЕНИЕ':U
                      ,input no
                      ,input-output v-recid
                      ,input p-stop-list-code
                      ,input dc-list.d-card
                      ,input v-sel-status-code
                      ) no-error.
      if not error-status:error then do:
        v-ok = v-ok + 1.
      end.
    end.
  end.
  when "list-client" then do:
    v-sel-status-code = integer('2':U).
    for each cli-list:
      delete cli-list.
    end.
    run str/cli-list.w (
               input parparentproc
              ,input v-cntxt-host-code-obj
              ,input v-cntxt-obj-type
              ,input v-cntxt-obj-code) no-error.
    v-num = 0.
    for each cli-list no-lock,
        each buf_dis-card no-lock where
            buf_Dis-card.cli-type = cli-list.obj-type
        and  buf_Dis-card.cli-code = cli-list.obj-code  :
      if buf_Dis-card.mask-card then next.
      v-num = v-num + 1.
      RUN gen-key-rec IN THIS-PROCEDURE ( INPUT 'dis-card':U
                                          ,INPUT BUFFER buf_Dis-card:HANDLE
                                          ,OUTPUT v-key-rec).
      find first exist_stop-list-line no-lock where
                exist_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
            AND exist_stop-list-line.classif-type = 'dis-card':U
            and exist_stop-list-line.resource_id = v-key-rec no-error.
      if available exist_stop-list-line
      and exist_stop-list-line.key#_one = INTEGER('1':U) then do:
        v-recid = recid(exist_stop-list-line).
        run ref/stop-ll1.p (
                          input 'ИЗМЕНЕНИЕ':U
                        ,input no
                        ,input-output v-recid
                        ,input p-stop-list-code
                        ,input buf_Dis-card.d-card
                        ,input integer('3':U)
                        ) no-error.
        if not error-status:error then do:
          v-ok-old = v-ok-old + 1.
        end.
      end.
      else do:
        run ref/stop-ll1.p (
                          input 'ДОБАВЛЕНИЕ':U
                        ,input no
                        ,input-output v-recid
                        ,input p-stop-list-code
                        ,input buf_Dis-card.d-card
                        ,input v-sel-status-code
                        ) no-error.
        if not error-status:error then do:
          v-ok = v-ok + 1.
        end.
      end.
    end.
  end.
  when "one" then do:
    v-sel-status-code = integer('1':U).
    run ref/discards.w ( INPUT parparentproc
                    ,input "b-sel,b-mark":U
                    ,input 'все':U
                    ,INPUT v-cntxt-host-code-obj
                    ,INPUT v-cntxt-obj-type
                    ,INPUT v-cntxt-obj-code
                    ,INPUT '':U
                    ,input ?
                    ,output v-loc-rid-list ) no-error .
    if v-loc-rid-list <> '':U then do:
      do v-ii =  1 to num-entries(v-loc-rid-list) :
        v-num = v-num + 1.
        find first buf_dis-card no-lock where
                  recid(buf_dis-card) = integer(entry(v-ii, v-loc-rid-list)) no-error.
        if available buf_dis-card
        and buf_Dis-card.mask-card = no
        then do:
          run ref/stop-ll1.p (
                          input 'ДОБАВЛЕНИЕ':U
                          ,input no
                          ,input-output v-recid
                          ,input p-stop-list-code
                          ,input buf_Dis-card.d-card
                          ,input v-sel-status-code
                          ) no-error.
          if error-status:error then do:
          end.
          else do:
            v-ok = v-ok + 1.
          end.
        end.
      end.
    end.
    else do:
      undo, return error .
    end.
  end.
  when "one-client" then do:
    v-sel-status-code = integer('2':U).
    run ref/cli-all.w ( input parparentproc
                  ,input "b-sel"
                  ,input 'орг':U
                  ,input 'все':U
                  ,input 'текущие':U
                  ,input ?
                  ,input ",,,,,,NO,,"
                  ,input ""
                  ,output v-loc-rid-list ) NO-ERROR.
    IF v-loc-rid-list = '':U THEN undo, return error .
      do v-ii =  1 to num-entries(v-loc-rid-list) :
        find first buf_clients no-lock where
                  recid(buf_clients) = integer(entry(v-ii, v-loc-rid-list)) no-error.
        if available buf_clients then do:
          for each buf_dis-card no-lock where
                  buf_Dis-card.cli-type = buf_clients.obj-type
              and buf_Dis-card.cli-code = buf_clients.obj-code:
            if buf_Dis-card.mask-card then next.
            v-num = v-num + 1.
            RUN gen-key-rec IN THIS-PROCEDURE ( INPUT 'dis-card':U
                                                ,INPUT BUFFER buf_Dis-card:HANDLE
                                                ,OUTPUT v-key-rec).
            find first exist_stop-list-line no-lock where
                      exist_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
                  AND exist_stop-list-line.classif-type = 'dis-card':U
                  and exist_stop-list-line.resource_id = v-key-rec no-error.
            if available exist_stop-list-line
            and exist_stop-list-line.key#_one = INTEGER('1':U) then do:
          v-recid = recid(exist_stop-list-line).
          run ref/stop-ll1.p (
                            input 'ИЗМЕНЕНИЕ':U
                          ,input no
                          ,input-output v-recid
                          ,input p-stop-list-code
                          ,input buf_Dis-card.d-card
                          ,input integer('3':U)
                          ) no-error.
          if not error-status:error then do:
            v-ok-old = v-ok-old + 1.
          end.
        end.
        else do:
          run ref/stop-ll1.p (
                            input 'ДОБАВЛЕНИЕ':U
                            ,input no
                            ,input-output v-recid
                            ,input p-stop-list-code
                            ,input buf_Dis-card.d-card
                            ,input v-sel-status-code
                            ) no-error.
          if error-status:error then do:
          end.
          else do:
            v-ok = v-ok + 1.
          end.
        end.
        end.
      end.
    end.
  end.
end case.
run openbr in this-procedure ( input yes, input no, input '':U, input rs-cli-type, input frame Dialog-Frame sch-cli-code).
if v-ii > 0 and v-ok <> v-num then do:
  message
  substitute("Из выбранных Вами &1 карт в стоп-лист удалось добавить &2", v-num, v-ok) skip(0)
  string(if v-ok-old > 0
   then substitute("&1 карт поменяли статус на &2"
                   ,v-ok-old
                  , 'стоп-карта;стоп-клиент':U)
   else '')
  view-as alert-box warning.
end.
END PROCEDURE.
PROCEDURE proc-b-chg :
DEFINE INPUT PARAMETER p-chg-option AS CHARACTER NO-UNDO.
define variable v-status-codes as character no-undo .
define variable v-sel-status-code as integer no-undo .
define variable v-status-codes-full as character no-undo .
define variable choice as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-ok as integer no-undo .
define variable v-num as integer no-undo .
define variable v-recid as recid no-undo .
DEFINE BUFFER buf_stop-list-line FOR ub.stop-list-line.
if p-chg-option = "one" then do:
  if X_stop-list-line.key#_one = INTEGER('2':U)
  then do:
    v-status-codes = '3':U .
  end.
  else do:
    v-status-codes = '2':U  .
  end.
end.
else do:
  v-status-codes = '2':U + chr(44) + '3':U .
end.
do v-ii = 1 to num-entries(v-status-codes):
    v-status-codes-full = v-status-codes-full  +
                        (if v-ii = 1
                        then '':U
                        else '|') + entry (lookup (entry(v-ii, v-status-codes), '1,2,3,4':U) + 1, ',':U + 'стоп-карта,стоп-клиент,стоп-карта;стоп-клиент,удал-карта':U).
end.
run gbl/d-askw.w ( input "Статус строки стоп-листа"
            ,input  "Подвердите НОВЫЙ статус"
            ,input "|"
            ,input v-status-codes-full + "|" + "Отмена"
            ,input fill("|", num-entries(v-status-codes) )
            ,input 1
            ,input num-entries(v-status-codes) + 1
            ,output choice).
if choice = num-entries(v-status-codes) + 1 then do:
  undo, return error .
end.
v-sel-status-code = integer(entry(choice, v-status-codes)).
case p-chg-option:
  when "one" then do:
    if not (X_stop-list-line.key#_one = INTEGER('2':U)
    or   X_stop-list-line.key#_one = INTEGER('3':U))
    then do:
      message
      substitute("Изменить статус строки стоп-листа можно только&1для строк со статусом <&2> или <&3> и&1только на статус <&3> или <&2> соответственно"
                 ,chr(10)
                 ,'стоп-клиент':U
                 ,'стоп-карта;стоп-клиент':U
                 )
      view-as alert-box error .
      undo, return error .
    end.
    v-recid = recid(X_stop-list-line).
    run ref/stop-ll1.p (
                      input 'ИЗМЕНЕНИЕ':U
                    ,input no
                    ,input-output v-recid
                    ,input p-stop-list-code
                    ,input X_stop-list-line.charkey_one
                    ,input v-sel-status-code
                    ) no-error.
    if error-status:error then do:
    end.
    else do:
      v-ok = v-ok + 1.
    end.
  end.
  when "selected" then do:
    v-num = num-entries(v-rid-list).
    _v-ii:
    do v-ii = 1 to v-num:
      v-recid = integer(entry(v-ii, v-rid-list)).
      find first buf_stop-list-line no-lock where
                recid(buf_stop-list-line) = v-recid.
      if not (buf_stop-list-line.key#_one = integer('2':U)
              or
              buf_stop-list-line.key#_one = integer('3':U)
              )
      then do:
        message
        substitute("Изменить статус строки стоп-листа можно только&1для строк со статусом <&2> и только на статус <&3>"
                  ,chr(10)
                  ,(if v-sel-status-code = integer('2':U)
                    then 'стоп-карта;стоп-клиент':U
                    else 'стоп-клиент':U)
                  ,entry (lookup (string(v-sel-status-code), '1,2,3,4':U) + 1, ',':U + 'стоп-карта,стоп-клиент,стоп-карта;стоп-клиент,удал-карта':U)
                  )
        view-as alert-box error .
        next _v-ii.
      end.
      run ref/stop-ll1.p (
                        input 'ИЗМЕНЕНИЕ':U
                      ,input no
                      ,input-output v-recid
                      ,input p-stop-list-code
                      ,input buf_stop-list-line.charkey_one
                      ,input v-sel-status-code
                      ) no-error.
      if error-status:error then do:
      end.
      else do:
        v-ok = v-ok + 1.
      end.
    end.
  end.
end case.
run openbr in this-procedure ( input yes, input no, input '':U, input rs-cli-type, input frame Dialog-Frame sch-cli-code).
if p-chg-option <> "one" and v-ok <> v-num then do:
  message
  substitute("Из выбранных Вами &1 карт удалось изменить &2", v-num, v-ok)
  view-as alert-box warning.
end.
END PROCEDURE.
PROCEDURE proc-b-del :
DEFINE INPUT PARAMETER p-del-option AS CHARACTER NO-UNDO.
define variable glog as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-ok as integer no-undo .
define variable v-num as integer no-undo .
define variable v-num2 as integer no-undo .
define variable v-recid as recid no-undo .
define variable v-key-rec as character no-undo .
define variable v-stop-list-code as character no-undo .
define variable v-index as integer no-undo .
define buffer buf_stop-list-line for ub.stop-list-line.
define buffer buf_dis-card for ub.dis-card.
case p-del-option:
  when "one" then do:
    if X_stop-list-line.key#_one = INTEGER('2':U)
    or X_stop-list-line.key#_one = INTEGER('3':U) then do:
      message
      substitute("Карты со статусом &2 и &3 не могут быть удалены из стоплиста по отдельности&1" +
                "для удаления таких карт из стоплиста выбирайте опцию ВСЕ ПО КЛИЕНТУ"
                ,chr(10)
                ,'стоп-клиент':U
                ,'стоп-карта;стоп-клиент':U
                )
      view-as alert-box ERROR.
      undo, return error .
    end.
    else do:
      message
      "Вы действительно хотите удалить из стоплиста эту карту?"
      view-as alert-box question button yes-no update glog.
      if not glog then undo, return error .
                     v-recid = recid(X_stop-list-line).
      run ref/stop-ll3.p (
                      input no
                      ,input v-recid
                      ) no-error.
      if error-status:error then do:
      end.
      else do:
        assign
        v-index = lookup(v-rid-list, string(v-recid)).
        if v-index > 0 then do:
          entry(v-index, v-rid-list) = ''.
          v-rid-list = trim(replace(v-rid-list, chr(44) + chr(44), chr(44)), chr(44)).
        end.
      end.
    end.
  end.
  when "client" then do:
   v-stop-list-code = X_stop-list-line.stop-list-code.
    message
    "Вы действительно хотите удалить из стоплиста ВСЕ карты этого клиента?"
    view-as alert-box question button yes-no update glog.
    for each buf_Dis-card no-lock where
            buf_Dis-card.cli-type = X_clients.obj-type
        and buf_Dis-card.cli-code = X_clients.obj-code:
      run gen-key-rec in this-procedure ( input 'clients':U
                                         ,input buffer X_clients:handle
                                         ,output v-key-rec).
     run waitfram-show in this-procedure ( input "Ждите..." ).
      for each buf_stop-list-line no-lock where
             buf_stop-list-line.stop-list-code = v-stop-list-code
         AND buf_stop-list-line.classif-type = 'dis-card':U
         and buf_stop-list-line.resource_id = v-key-rec
      on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo , return error substitute( "&1. stop", vss-workfile )
      on endkey undo , return error substitute( "&1. endkey", vss-workfile )
      :
        v-recid = recid(buf_stop-list-line).
        v-num = v-num + 1.
        run ref/stop-ll3.p (
                        input no
                        ,input v-recid
                        ) no-error.
        if not error-status:error then do:
          v-ok = v-ok + 1.
          assign
          v-index = lookup(v-rid-list, string(v-recid)).
          if v-index > 0 then do:
            entry(v-index, v-rid-list) = ''.
            v-rid-list = trim(replace(v-rid-list, chr(44) + chr(44), chr(44)), chr(44)).
          end.
        end.
      end.
      run waitfram-hide in this-procedure .
    end.
  end.
  when "selected" then do:
    if v-rid-list = '':U then do:
      message
      "Ничего не отмечено"
       view-as alert-box error.
       undo, return error .
    end.
    message
    substitute("Вы действительно хотите удалить из стоплиста отмеченные карты&1"  +
               "(карты в статусе &2 и &3 удалены не будут&1" +
               "для их удаления выбирайте опцию ВСЕ ПО КЛИЕНТУ)"
               ,chr(10)
               ,'стоп-клиент':U
               ,'стоп-карта;стоп-клиент':U
               )
    view-as alert-box question button yes-no update glog.
    if not glog then undo, return error .
    v-num = num-entries(v-rid-list).
    v-num2 = num-entries(v-rid-list).
    do v-ii = 1 to v-num2:
      v-recid = integer(entry(v-ii, v-rid-list)).
      find first buf_stop-list-line no-lock where
                recid(buf_stop-list-line) = v-recid.
      run ref/stop-ll3.p (
                       input no
                      ,input v-recid
                      ) no-error.
      if error-status:error then do:
      end.
      else do:
        v-ok = v-ok + 1.
        entry(v-ii, v-rid-list) = '':U.
        v-rid-list = trim(replace(v-rid-list, chr(44) + chr(44), chr(44)), chr(44)).
        v-num2 = v-num2 - 1.
        v-ii = v-ii - 1.
      end.
    end.
  end.
end case.
run openbr in this-procedure ( input yes, input no, input '':U, input rs-cli-type, input frame Dialog-Frame sch-cli-code).
if p-del-option <> "one" and v-ok <> v-num then do:
  message
  substitute("Из выбранных Вами &1 карт удалось удалить &2", v-num, v-ok)
  view-as alert-box warning.
end.
END PROCEDURE.
PROCEDURE proc-b-print :
define variable v-cli-type-code as character no-undo .
define variable line as character no-undo .
define variable startrecid as recid no-undo .
define variable v-stat-flag as character no-undo .
DEFINE VARIABLE v-for-sl-doc-date AS date NO-UNDO.
DEFINE VARIABLE v-for-sl-status AS CHARACTER NO-UNDO.
DEFINE FRAME List
X_stop-list-line.stop-list-code COLUMN-LABEL "№ стоплиста" FORMAT "X(9)"
X_stop-list-line.charkey_one COLUMN-LABEL "№ ДК" FORMAT "X(19)"
v-cli-type-code COLUMN-LABEL "Держатель" FORMAT "X(12)"
X_clients.obj-name COLUMN-LABEL "Наимен.Держателя карты" FORMAT "X(105)"
v-stat-flag COLUMN-LABEL "Флаг" FORMAT "X(20)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>>>9") ) AT 56 format "X(15)" SKIP
Line format "X(198)" AT 1
with width  232 down use-text stream-io no-box .
DEFINE FRAME List2
X_stop-list-line.stop-list-code COLUMN-LABEL "№ стоплиста" FORMAT "X(9)"
v-for-sl-doc-date COLUMN-LABEL "Дата" FORMAT "99/99/9999"
v-for-sl-status COLUMN-LABEL "Статус" FORMAT "X(8)"
v-stat-flag COLUMN-LABEL "Флаг" FORMAT "X(22)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>>>9") ) AT 56 format "X(15)" SKIP
Line format "X(198)" AT 1
with width  232 down use-text stream-io no-box .
StartRecid = recid( X_stop-list-line ) .
DO WHILE available X_stop-list-line :
  GET prev br-stop-list-line NO-LOCK .
END.
GET next br-stop-list-line NO-LOCK .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
FORM HEADER
Line format "X(225)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME CliBottomFrame width 232 PAGE-BOTTOM NO-LABELS no-box.
VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream space(20)
frame Dialog-Frame:title format "X(100)" SKIP(2) .
IF p-d-card = '':U  THEN DO:
  FORM with frame List .
  DO WHILE available X_stop-list-line :
    display stream PrnLibstream
    X_stop-list-line.stop-list-code
    X_stop-list-line.charkey_one
    (X_dis-card.cli-type + string(X_dis-card.cli-code)) @ v-cli-type-code
    X_clients.obj-name
    entry (lookup (STRING( X_stop-list-line.key#_one), '1,2,3,4':U) + 1, ',':U + 'стоп-карта,стоп-клиент,стоп-карта;стоп-клиент,удал-карта':U) @ v-stat-flag
    with frame List .
    DOWN stream PrnLibStream
    1 with frame List.
      GET next br-stop-list-line.
    END.
  END.
  ELSE DO:
    FORM with frame List2 .
    DO WHILE available X_stop-list-line :
    display stream PrnLibstream
    X_stop-list-line.stop-list-code
    get-sl-doc-date(X_stop-list-line.stop-list-code) @ v-for-sl-doc-date
    get-sl-status(X_stop-list-line.stop-list-code) @ v-for-sl-status
    entry (lookup (STRING( X_stop-list-line.key#_one), '1,2,3,4':U) + 1, ',':U + 'стоп-карта,стоп-клиент,стоп-карта;стоп-клиент,удал-карта':U) @ v-stat-flag
    with frame List2 .
    DOWN stream PrnLibStream
    1 with frame List2.
      GET next br-stop-list-line.
    END.
  END.
PUT stream PrnLibStream Line format "X(136)" SKIP.
HIDE stream PrnLibStream FRAME CliBottomFrame .
output stream PrnLibStream close .
run prn-lib-prn-file in this-procedure (
                                           input parparentproc
                                          ,input 8
                                          ).
reposition br-stop-list-line to recid StartRecid .
END PROCEDURE.
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo.
assign
v-ri = (if avail X_stop-list-line then recid(X_stop-list-line) else ?)
.
assign
tbl = 'stop-list-line'
join-tbl = 'X_stop-list-line'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('key#_one', 'Флаг стоплиста', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_one', 'ДК', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
DO on stop undo, leave:
    run gbl/filter.w ( INPUT parparentproc
                 ,INPUT (filter-point + chr(4) + filter-label)
                 ,INPUT tbl
                 ,INPUT join-tbl
                 ,INPUT fld
                 ,INput lab
                 ,INPUT spr
                 ,INPUT  dim).
    RUN OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U, input rs-cli-type, input frame Dialog-Frame sch-cli-code).
    if v-ri <> ? then do:
      reposition br-stop-list-line to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-stop-list-line in frame Dialog-Frame .
END .
END PROCEDURE.
PROCEDURE proc-find-d-card :
define input parameter p-next as logical no-undo.
define input parameter p-d-card as character no-undo.
display
0 @ sch-cli-code
with frame Dialog-Frame.
assign
p-d-card = replace(p-d-card, chr(39), chr(39) + chr(39))
p-d-card = chr(34) + p-d-card + chr(34).
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_stop-list-line.charkey_one begins &1 "
      , p-d-card)
    ,INPUT '':U
    ,INPUT 0
    ).
apply "entry":u to sch-d-card in frame Dialog-Frame .
END PROCEDURE.
FUNCTION get-sl-doc-date RETURNS DATE
  ( INPUT p-stop-list-code AS CHARACTER ) :
DEFINE BUFFER buf_stop-list FOR ub.stop-list.
FIND FIRST buf_stop-list NO-LOCK WHERE
            buf_stop-list.stop-list-code = p-stop-list-code
       AND buf_stop-list.classif-type = 'dis-card':U
        NO-ERROR.
IF AVAILABLE buf_stop-list THEN  RETURN buf_stop-list.doc-date.
  RETURN ?.
END FUNCTION.
FUNCTION get-sl-status RETURNS CHARACTER
  ( INPUT p-stop-list-code AS CHARACTER ) :
DEFINE BUFFER buf_stop-list FOR ub.stop-list.
FIND FIRST buf_stop-list NO-LOCK WHERE
            buf_stop-list.stop-list-code = p-stop-list-code
       AND buf_stop-list.classif-type = 'dis-card':U
        NO-ERROR.
IF AVAILABLE buf_stop-list THEN  RETURN buf_stop-list.status_.
  RETURN chr(63).
END FUNCTION.
