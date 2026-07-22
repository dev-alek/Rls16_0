DEFINE BUFFER find_c-gds-hist FOR c-gds-hist.
DEFINE BUFFER X_c-gds-hist FOR c-gds-hist.
DEFINE BUFFER X_clients FOR clients.
DEFINE BUFFER X_curr-sysconf FOR sysconf.
DEFINE BUFFER X_db FOR db.
DEFINE BUFFER X_goods FOR goods.
DEFINE BUFFER X_sysconf FOR sysconf.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter bttns  as char   no-undo .
define input parameter p-mode  as char   no-undo .
define input parameter p-gds-code     like ub.c-gds-hist.gds-code no-undo .
define input parameter p-host-code like ub.c-gds-hist.host-code no-undo.
define input parameter p-obj-type like ub.c-gds-hist.obj-type no-undo.
define input parameter p-obj-code like ub.c-gds-hist.obj-code no-undo.
define input parameter p-corr-user-db-num  like ub.c-gds-hist.corr-user-db-num no-undo .
define input parameter p-corr-user-name  like ub.c-gds-hist.corr-user-name no-undo .
define input parameter p-subject  like ub.c-gds-hist.subject no-undo .
define input parameter p-db-num  like ub.c-gds-hist.corr-user-db-num no-undo .
define input-output param p-rid-list    as  char no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список полной истории товара":U.
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-rid-list as character no-undo .
define variable filter-point as character no-undo init "cgdshist" .
define variable filter-point0 as character no-undo init "cgdshist" .
define variable filter-label0 as character no-undo init "Список полной истории товара" .
define variable filter-label as character no-undo init "Список полной истории товара" .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-find as logical no-undo.
define variable v-gds-name like ub.goods.gds-name no-undo.
define variable v-artic like ub.goods.artic no-undo.
define variable v-prod-type like ub.goods.prod-type no-undo.
define variable v-prod-code like ub.goods.prod-code no-undo.
define variable v-start-date-chr as character no-undo .
define variable v-end-date-chr as character no-undo .
define variable v-subject-chr as character no-undo .
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define buffer X_curr_sysconf for ub.sysconf.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
    .
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
  .
  do v-ind = 1 to h-main-buf:num-fields
  on error undo, return error
  :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
    .
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
    .
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
    assign
      h-for-comp = h-new-buf
    .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
    .
    if ( trim( p-field-list ) <> "":U
         and lookup( v-field-name, p-field-list ) > 0
       )
       or trim( p-field-list ) = "":U
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
      if v-old-value <> v-new-value
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
                    ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
                    ,entry( v-ind, p-label-form, chr(8) )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
FUNCTION get-action RETURNS CHARACTER
  ( p-action as integer )  FORWARD.
FUNCTION get-good RETURNS CHARACTER
  ( p-gds-code as integer, output p-artic as character, output p-prod-type as character, output p-prod-code as integer )  FORWARD.
FUNCTION get-source-type RETURNS CHARACTER
  ( p-source-type as character )  FORWARD.
FUNCTION get-subject RETURNS CHARACTER
  ( p-subject as character )  FORWARD.
DEFINE BUTTON B-gds-obj
     LABEL "&Остатки"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lookup
     LABEL "&Товар"
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
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sch-corr-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате изменения"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE sch-corr-user-name AS CHARACTER FORMAT "X(9)":U
     LABEL "пользователю"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-db-num AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "БД"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-gds-code AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "коду товара"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE v-corr-user-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "по БД"
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
DEFINE QUERY BR-gds-hist FOR
      X_c-gds-hist SCROLLING.
DEFINE BROWSE BR-changes
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.25.
DEFINE BROWSE BR-gds-hist
  QUERY BR-gds-hist NO-LOCK DISPLAY
      mark-string(recid(X_c-gds-hist), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
  X_c-gds-hist.gds-code FORMAT "9999999999":U
  X_c-gds-hist.corr-date FORMAT "99/99/9999":U
  string(X_c-gds-hist.corr-time, "HH:MM:SS":U) COLUMN-LABEL "Время изм." FORMAT "X(8)":U
  usrfulnf(X_c-gds-hist.corr-user-name) column-label 'Изменил' FORMAT "X(8)":U
  get-action(X_c-gds-hist.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
  X_c-gds-hist.corr-user-db-num FORMAT ">>>>9":U
  X_c-gds-hist.is-news FORMAT "+/":U
  get-source-type(X_c-gds-hist.source-type) COLUMN-LABEL "Источн.!измен."
  X_c-gds-hist.source-ref FORMAT "X(14)":U
  if v-find then get-good(X_c-gds-hist.gds-code, output v-artic, output v-prod-type, output v-prod-code) else "":U COLUMN-LABEL "Назв. товара" FORMAT "X(25)":U
  v-artic COLUMN-LABEL "Артикул" FORMAT "X(14)":U
  v-prod-type + string(v-prod-code) COLUMN-LABEL "Пр-ль" FORMAT "X(12)":U
  get-subject(X_c-gds-hist.subject) COLUMN-LABEL "Предмет изменений" FORMAT "X(55)":U width 15
  X_c-gds-hist.host-code COLUMN-LABEL "Фирма" FORMAT "999999999":U
  X_c-gds-hist.obj-type + string(X_c-gds-hist.obj-code) COLUMN-LABEL "Объект" FORMAT "X(8)":U
ENABLE
  X_c-gds-hist.is-news
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.46.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     v-corr-user-db-num AT ROW 1 COL 37 COLON-ALIGNED
     B-gds-obj AT ROW 1 COL 55
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-lookup AT ROW 1.04 COL 45
     BR-gds-hist AT ROW 2 COL 1
     sch-db-num AT ROW 13.63 COL 60.13 COLON-ALIGNED
     sch-corr-date AT ROW 13.63 COL 85.75 COLON-ALIGNED
     sch-gds-code AT ROW 13.67 COL 44.75 COLON-ALIGNED
     sch-corr-user-name AT ROW 13.71 COL 22.5 COLON-ALIGNED
     BR-changes AT ROW 14.79 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.38 BY 1 AT ROW 13.63 COL 1.38
          FGCOLOR 4
     SPACE(89.48) SKIP(7.44)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Полная история по товару"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BR-gds-hist:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-gds-obj IN FRAME Dialog-Frame
DO:
  if avail X_c-gds-hist or p-gds-code <> ? then
  do:
  run ref/cgdsobj.w
    (
     input parparentproc
    ,input p-curr-obj-type
    ,input p-curr-obj-code
    ,input if p-gds-code <> ? then p-gds-code else X_c-gds-hist.gds-code
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.
  end.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
run str/showgds.p (input parparentproc
              ,input ?
              ,input X_c-gds-hist.gds-code
              ,input 'ПРОСМОТР':U) no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
  if available X_c-gds-hist then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid14 as character no-undo .
define variable v-num-entry14 as integer   no-undo .
assign
  v-str-recid14 = trim( string( recid( X_c-gds-hist ) , "->>>>>>>>>>>9":U ) )
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
    loc#log = br-gds-hist:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-gds-hist:select-next-row ().
        apply "VALUE-CHANGED" to br-gds-hist in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-gds-hist in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
    run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
    run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if ( available X_c-gds-hist ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_c-gds-hist ) ) .
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF BR-gds-hist IN FRAME Dialog-Frame
DO:
     run proc-br-gds-hist in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF BR-gds-hist IN FRAME Dialog-Frame
DO:
    run proc-br-gds-hist in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF BR-gds-hist IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.
ON CTRL-J OF sch-corr-date IN FRAME Dialog-Frame
DO:
   run proc-find-corr-date in this-procedure(yes, input frame Dialog-Frame sch-corr-date) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-corr-date IN FRAME Dialog-Frame
DO:
  run proc-find-corr-date in this-procedure(no, input frame Dialog-Frame sch-corr-date) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-corr-user-name IN FRAME Dialog-Frame
DO:
  run proc-find-user in this-procedure(yes, input frame Dialog-Frame sch-corr-user-name) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-corr-user-name IN FRAME Dialog-Frame
DO:
  run proc-find-user in this-procedure(no, input frame Dialog-Frame sch-corr-user-name) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-db-num IN FRAME Dialog-Frame
DO:
  run proc-find-db-num in this-procedure(yes, input frame Dialog-Frame sch-db-num) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-db-num IN FRAME Dialog-Frame
DO:
  run proc-find-db-num in this-procedure(no, input frame Dialog-Frame sch-db-num) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-gds-code IN FRAME Dialog-Frame
DO:
  run proc-find-gds-code in this-procedure(yes, input frame Dialog-Frame sch-gds-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-gds-code IN FRAME Dialog-Frame
DO:
  run proc-find-gds-code in this-procedure(no, input frame Dialog-Frame sch-gds-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF v-corr-user-db-num IN FRAME Dialog-Frame
DO:
  assign
  v-corr-user-db-num
  .
  RUn OpenBR(yes, no, '':U, v-corr-user-db-num).
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
        v-diasize-browse-handle     = browse br-gds-hist :handle
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-doc-rec = recid(X_c-gds-hist).  Run OpenBR in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).  REPOSITION br-gds-hist to recid v-doc-rec No-ERROR.               apply 'value-changed' to br-gds-hist.
    apply "VALUE-CHANGED" to BR-changes.
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-corr-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of sch-corr-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of sch-corr-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of sch-corr-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of sch-corr-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of sch-corr-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date21
    MENU-ITEM m-ed-date21-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date21-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date21-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date21-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-corr-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-corr-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date21 :HANDLE
      sch-corr-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle21 as handle no-undo .
  assign
    v-label-handle21 = sch-corr-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle21)
  then do:
    if v-label-handle21 :tooltip = ""
    or v-label-handle21 :tooltip = ?
    then do:
      assign
        v-label-handle21 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date21-1 in menu m-ed-date21 DO:
    apply "ctrl-b":U to sch-corr-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-2 in menu m-ed-date21 DO:
    apply "ctrl-d":U to sch-corr-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-3 in menu m-ed-date21 DO:
    apply "ctrl-e":U to sch-corr-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-4 in menu m-ed-date21 DO:
    apply "ctrl-f":U to sch-corr-date in frame Dialog-Frame .
  END.
def var sort-labelbr-gds-hist   as character no-undo .
def var sort-clmnbr-gds-hist    as handle    no-undo .
def var cur-clmnbr-gds-hist     as handle    no-undo .
def var cur-clmn-locbr-gds-hist as integer   no-undo .
def var re-querybr-gds-hist     as logical   initial no no-undo .
on start-search, ctrl-o of br-gds-hist in frame Dialog-Frame do:
   run sort-brbr-gds-hist
     (input (if available X_c-gds-hist
             then recid(X_c-gds-hist)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-gds-hist :
  define input parameter p-recid as recid no-undo .
  if re-querybr-gds-hist = no then do:
    assign
       cur-clmnbr-gds-hist = br-gds-hist:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-gds-hist <> ? then sort-clmnbr-gds-hist:column-fgcolor = 0.
    if cur-clmnbr-gds-hist = sort-clmnbr-gds-hist then do:
      assign
         sort-labelbr-gds-hist = ""
         sort-clmnbr-gds-hist = ?
      .
     end.
     else do:
       assign
         sort-labelbr-gds-hist = cur-clmnbr-gds-hist:label
         sort-clmnbr-gds-hist  = cur-clmnbr-gds-hist
         sort-clmnbr-gds-hist:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-gds-hist = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-gds-hist:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-gds-hist then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-gds-hist = cur-clmn-locbr-gds-hist + 1
    .
  end.
  case sort-labelbr-gds-hist:
        when X_c-gds-hist.gds-code:label in browse br-gds-hist then DO:    assign       sort-column-name = "X_c-gds-hist.gds-code"     .     run OpenBr in this-procedure ( input yes, input no, input no, input v-corr-user-db-num).   . END.
        when 'Изменил'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1usrfulnf&1, X_c-gds-hist.corr-user-name)', chr(34))     .     run OpenBr in this-procedure ( input yes, input no, input no, input v-corr-user-db-num).   . END.
        when X_c-gds-hist.corr-date:label in browse br-gds-hist then DO:    assign       sort-column-name = "X_c-gds-hist.corr-date"     .     run OpenBr in this-procedure ( input yes, input no, input no, input v-corr-user-db-num).   . END.
        when X_c-gds-hist.corr-user-db-num:label in browse br-gds-hist then DO:    assign       sort-column-name = "X_c-gds-hist.corr-user-db-num"     .     run OpenBr in this-procedure ( input yes, input no, input no, input v-corr-user-db-num).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input no, input v-corr-user-db-num).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-gds-hist') then do:
          run mv-brw-defaultbr-gds-hist.
        end.
      if sort-labelbr-gds-hist <> "" then do:
        assign
          cur-clmnbr-gds-hist:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-gds-hist = ?
      .
    end.
  end case.
    if cur-clmn-locbr-gds-hist <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-gds-hist') then do:
        run ch-clmnbr-gds-hist in this-procedure (cur-clmn-locbr-gds-hist).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-gds-hist to recid p-recid no-error.
    apply "value-changed" to br-gds-hist in frame Dialog-Frame.
  end.
  apply "entry" to br-gds-hist in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-gds-hist:
if cur-clmnbr-gds-hist = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input no, input v-corr-user-db-num).
end.
else do:
   assign re-querybr-gds-hist = yes.
   run sort-brbr-gds-hist
     (input (if available X_c-gds-hist
             then recid(X_c-gds-hist)
             else ?
            )
     ).
   assign re-querybr-gds-hist = no.
end.
end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-changes :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   if p-mode <> 'все':U
 and p-mode <> 'фирма':U
 and p-mode <> "one":U
 and p-mode <> 'объект':U
 and p-mode <> "subject":U
 then dO:
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
  p-curr-host-code
  view-as alert-box ERROR.
  return.
end.
 if p-mode = 'фирма':U then do:
  find first X_clients no-lock where
                X_clients.obj-type = 'орг':U
            and X_clients.obj-code = p-host-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-host-code"
        p-curr-host-code
        view-as alert-box ERROR.
        return.
    end.
    find first X_sysconf no-lock where
                    X_sysconf.host-code = p-host-code no-error.
    if not available X_sysconf then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-host-code"
      p-host-code
      view-as alert-box ERROR.
      return.
    end.
  end.
 if p-mode = 'объект':U then do:
  find first X_clients no-lock where
                X_clients.obj-type = p-obj-type
            and X_clients.obj-code = p-obj-code no-error.
    if not available X_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-obj-type/p-obj-code"
        p-obj-type p-obj-code
        view-as alert-box ERROR.
        return.
    end.
 end.
 if p-mode = "one":U then do:
  find first X_goods no-lock where
                X_goods.gds-code = p-gds-code no-error.
    if not available X_goods then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-gds-code" p-gds-code
        view-as alert-box ERROR.
        return.
    end.
  end.
 if p-mode = "db-num":U then do:
  find first X_db no-lock where
                X_db.db-num = p-corr-user-db-num no-error.
    if not available X_db then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-corr-user-db-num" p-corr-user-db-num
        view-as alert-box ERROR.
        return.
    end.
  end.
  v-rid-list = p-rid-list.
  if v-rid-list <> "" then do:
      FIND FIRST find_c-gds-hist No-LOCK where
                 recid(find_c-gds-hist) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_c-gds-hist then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
  if p-mode <> 'все':U then do:
    assign
    v-find = yes.
  end.
  else do:
    assign
    v-find = yes
    v-gds-name = get-good(p-gds-code, output v-artic, output v-prod-type, output v-prod-code)
    .
  end.
  RUN MyEnable.
  RUn OpenBR(yes, no, '':U, v-corr-user-db-num).
  HIDE mark-num in frame Dialog-Frame .
  if v-rid-list <> "":U then
  REPOSITION br-gds-hist to recid integer(entry(1, v-rid-list)) No-ERROR.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-gds-hist as INT EXTENT 16 no-undo.
DEF VAR varmvibr-gds-hist       as INT no-undo.
DEF VAR varmvjbr-gds-hist       as INT no-undo.
DEF VAR varmvkbr-gds-hist       as INT no-undo.
DEF VAR varmvlbr-gds-hist       as INT no-undo.
DEF VAR move-elementbr-gds-hist as INT no-undo.
def var jjbr-gds-hist           as int no-undo.
do varmvibr-gds-hist = 1 to EXTENT(cur-clmn-numbr-gds-hist):
  ASSIGN cur-clmn-numbr-gds-hist[varmvibr-gds-hist] = varmvibr-gds-hist.
END.
RUN start-mv-clmnbr-gds-hist.
PROCEDURE start-mv-clmnbr-gds-hist:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  p-mode = 'все':U  THEN DO:
   DO jjbr-gds-hist = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16') TO 1 BY -1:
     RUN re-move-clmnbr-gds-hist ( cur-clmn-numbr-gds-hist[INTEGER(ENTRY (jjbr-gds-hist, '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16'))] , 1).
   END.
       END.
       IF  p-mode <> 'все':U  THEN DO:
   DO jjbr-gds-hist = NUM-ENTRIES('1,3,4,5,6,7,8,9,10,14,15,16,2,11,12,13') TO 1 BY -1:
     RUN re-move-clmnbr-gds-hist ( cur-clmn-numbr-gds-hist[INTEGER(ENTRY (jjbr-gds-hist, '1,3,4,5,6,7,8,9,10,14,15,16,2,11,12,13'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-gds-hist do:
  RUN re-move-clmnbr-gds-hist ( 1, 16).
END.
ON ctrl-cursor-left OF BROWSE br-gds-hist do:
  RUN re-move-clmnbr-gds-hist (16, 1).
END.
PROCEDURE re-move-clmnbr-gds-hist:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-gds-hist = 1 TO EXTENT(cur-clmn-numbr-gds-hist):
    if cur-clmn-numbr-gds-hist[varmvibr-gds-hist] = source-column THEN cur-clmn-numbr-gds-hist[varmvibr-gds-hist] = -1.
  END.
  if br-gds-hist:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-gds-hist = source-column - 1 to target-column BY -1:
    DO varmvibr-gds-hist = 1 TO EXTENT(cur-clmn-numbr-gds-hist):
        if cur-clmn-numbr-gds-hist[varmvibr-gds-hist] = varmvjbr-gds-hist THEN DO:
          cur-clmn-numbr-gds-hist[varmvibr-gds-hist] = cur-clmn-numbr-gds-hist[varmvibr-gds-hist] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-gds-hist = source-column + 1 to target-column:
    DO varmvibr-gds-hist = 1 TO EXTENT(cur-clmn-numbr-gds-hist):
      if cur-clmn-numbr-gds-hist[varmvibr-gds-hist] = varmvjbr-gds-hist THEN DO:
        cur-clmn-numbr-gds-hist[varmvibr-gds-hist] = cur-clmn-numbr-gds-hist[varmvibr-gds-hist] - 1.
      END.
    END.
  END.
  DO varmvibr-gds-hist = 1 TO EXTENT(cur-clmn-numbr-gds-hist):
    if cur-clmn-numbr-gds-hist[varmvibr-gds-hist] = -1 THEN cur-clmn-numbr-gds-hist[varmvibr-gds-hist] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-gds-hist:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-gds-hist = 1 TO EXTENT(cur-clmn-numbr-gds-hist):
    if cur-clmn-numbr-gds-hist[varmvibr-gds-hist] = cur-clmn-loc THEN move-elementbr-gds-hist = varmvibr-gds-hist.
  END.
  RUN re-move-clmnbr-gds-hist (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-gds-hist:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-gds-hist = 1 to EXTENT(cur-clmn-numbr-gds-hist):
    RUN re-move-clmnbr-gds-hist (cur-clmn-numbr-gds-hist[varmvlbr-gds-hist], varmvlbr-gds-hist).
  END.
  RUN start-mv-clmnbr-gds-hist.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-changes :handle
    ) .
  run diasize_init in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-corr-user-db-num sch-db-num sch-corr-date sch-gds-code
          sch-corr-user-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel v-corr-user-db-num B-gds-obj B-print B-sch B-Help
         B-lookup BR-gds-hist sch-db-num sch-corr-date sch-gds-code
         sch-corr-user-name BR-changes mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-h as handle no-undo .
assign
br-gds-hist:num-locked-columns in frame Dialog-Frame = 1
X_c-gds-hist.is-news:read-only in browse br-gds-hist = yes
v-corr-user-db-num = v-db-num
br-changes:title = "":U
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
v-h = br-gds-hist:FIRST-COLUMN IN FRAME Dialog-Frame
.
DO while valid-handle(v-h) :
  if v-h:LABEL = "Предмет изменений" then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
VIEW frame Dialog-Frame .
DISPLAY
v-db-num @ v-corr-user-db-num
sch-db-num
sch-corr-date
sch-gds-code
sch-corr-user-name
mark-num
WITH FRAME Dialog-Frame.
ENABLE
v-corr-user-db-num
b-quit
B-mark when lookup("b-mark":U, bttns) > 0
b-sel when lookup("b-sel":U, bttns) > 0
B-lookup
B-sch
B-gds-obj
B-Print
B-Help
BR-gds-hist
sch-corr-date
sch-gds-code when p-mode = 'все':U
sch-db-num   when p-mode = 'все':U
sch-corr-user-name
BR-changes mark-num
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
HIDE sch-corr-user-name
IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input  parameter p-db-num like ub.c-gds-hist.corr-user-db-num no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список полной истории товара" + chr(32).
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
define variable l-open-query as logical   no-undo .
CASE p-db-num :
  when ? then do:
    CASE p-mode :
      WHEN 'все':U        THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = filter-label0
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
if p-open-query then do:
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
                              "FOR EACH X_c-gds-hist"
      parameter-4-26 =
        (
          if (" TRUE " + " " + where-phrase-26) <> ""
          then " TRUE " + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + "")
      parameter-6-26 = if sort-phrase-26 = ''
                           then
        (
        " " + " use-index idate  " +
          " " + sort-column-phrase +
        " " + " BY X_c-gds-hist.corr-date DESC BY X_c-gds-hist.corr-time DESC "
        )
                           else
        (
        " " + " use-index idate  " +
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
          (" TRUE " + " " + where-phrase-26 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds-hist:handle
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
    OPEN QUERY br-gds-hist FOR EACH X_c-gds-hist
      where  TRUE
       use-index idate
       BY X_c-gds-hist.corr-date DESC BY X_c-gds-hist.corr-time DESC
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-gds-hist )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds-hist:handle:get-buffer-handle(1) = (buffer X_c-gds-hist:handle) then do:
      assign
      parameter-2-26 = (if p-find-next then "true":u else "false":u )
      parameter-4-26 =
        "where ":u + " TRUE " + " ":u + where-phrase-26 + " ":u + p-find-condition + " " + ""
      parameter-5-26 = " use-index idate  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input rowid(X_c-gds-hist)
                          ,input logical(parameter-2-26)
                          ,input no-lock
                          ,input (buffer X_c-gds-hist:handle)
                          ,input parameter-4-26
                          ,input parameter-5-26
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-26 = (if p-find-next then "true":u else "false":u )
      parameter-3-26 =  "FOR EACH X_c-gds-hist"
      parameter-4-26 =
        (
          if (" TRUE " + " " + where-phrase-26) <> ""
          then " TRUE " + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-26 = if sort-phrase-26 = ''
                           then
        (
        " " + " use-index idate  " +
          " " + sort-column-phrase +
        " " + " BY X_c-gds-hist.corr-date DESC BY X_c-gds-hist.corr-time DESC "
        )
                           else
        (
        " " + " use-index idate  " +
          " " + sort-column-phrase +
        " " + sort-phrase-26
        )
      parameter-7-26 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input logical(parameter-2-26)
                          ,input no-lock
                          ,input parameter-3-26
                          ,input parameter-4-26
                          ,input parameter-5-26
                          ,input parameter-6-26
                          ,input parameter-7-26
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
      WHEN 'фирма':U THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Фирма", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame Dialog-Frame:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5 Фирма: (&6) &7",
                                                            p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, p-host-code, X_clients.obj-name).
        end.
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
if p-open-query then do:
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
                              "FOR EACH X_c-gds-hist"
      parameter-4-28 =
        (
          if ("           X_c-gds-hist.gds-code  = p-gds-code  and  (X_c-gds-hist.host-code  = p-host-code  or X_c-gds-hist.host-code = 0)                         " + " " + where-phrase-28) <> ""
          then  substitute(' X_c-gds-hist.gds-code  = &1  and  (X_c-gds-hist.host-code  = &2  or X_c-gds-hist.host-code = 0)'                              ,p-gds-code                               ,p-host-code)  + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + "")
      parameter-6-28 = if sort-phrase-28 = ''
                           then
        (
        " " + " use-index idate  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index idate  " +
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
          ("           X_c-gds-hist.gds-code  = p-gds-code  and  (X_c-gds-hist.host-code  = p-host-code  or X_c-gds-hist.host-code = 0)                         " + " " + where-phrase-28 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds-hist:handle
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
    OPEN QUERY br-gds-hist FOR EACH X_c-gds-hist
      where            X_c-gds-hist.gds-code  = p-gds-code  and  (X_c-gds-hist.host-code  = p-host-code  or X_c-gds-hist.host-code = 0)
       use-index idate
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-gds-hist )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds-hist:handle:get-buffer-handle(1) = (buffer X_c-gds-hist:handle) then do:
      assign
      parameter-2-28 = (if p-find-next then "true":u else "false":u )
      parameter-4-28 =
        "where ":u +  substitute(' X_c-gds-hist.gds-code  = &1  and  (X_c-gds-hist.host-code  = &2  or X_c-gds-hist.host-code = 0)'                              ,p-gds-code                               ,p-host-code)  + " ":u + where-phrase-28 + " ":u + p-find-condition + " " + ""
      parameter-5-28 = " use-index idate  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input rowid(X_c-gds-hist)
                          ,input logical(parameter-2-28)
                          ,input no-lock
                          ,input (buffer X_c-gds-hist:handle)
                          ,input parameter-4-28
                          ,input parameter-5-28
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-28 = (if p-find-next then "true":u else "false":u )
      parameter-3-28 =  "FOR EACH X_c-gds-hist"
      parameter-4-28 =
        (
          if ("           X_c-gds-hist.gds-code  = p-gds-code  and  (X_c-gds-hist.host-code  = p-host-code  or X_c-gds-hist.host-code = 0)                         " + " " + where-phrase-28) <> ""
          then  substitute(' X_c-gds-hist.gds-code  = &1  and  (X_c-gds-hist.host-code  = &2  or X_c-gds-hist.host-code = 0)'                              ,p-gds-code                               ,p-host-code)  + " " + where-phrase-28
          else "true"
        )
      parameter-5-28 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-28 = if sort-phrase-28 = ''
                           then
        (
        " " + " use-index idate  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index idate  " +
          " " + sort-column-phrase +
        " " + sort-phrase-28
        )
      parameter-7-28 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input logical(parameter-2-28)
                          ,input no-lock
                          ,input parameter-3-28
                          ,input parameter-4-28
                          ,input parameter-5-28
                          ,input parameter-6-28
                          ,input parameter-7-28
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
      WHEN 'объект':U THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Объект", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame Dialog-Frame:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5 Объект: &6&7",
                                                            p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, p-obj-type, p-obj-code).
        end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-30  as logical   no-undo .
define variable  l-filter-open-30    as logical   .
define variable  flt-rec-30       as recid     no-undo .
define variable  filter-name-30      as character no-undo .
define variable  where-phrase-30     as character no-undo .
define variable  sort-phrase-30      as character no-undo .
define variable  where-phrase-rus-30 as character no-undo .
define variable  sort-phrase-rus-30  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-30
  ,output filter-name-30
  ,output where-phrase-30
  ,output sort-phrase-30
  ,output where-phrase-rus-30
  ,output sort-phrase-rus-30
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-30
      ) no-error .
  assign
    l-filter-open-30 = false
  .
  if flt-rec-30 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-30 as character no-undo .
    define variable  parameter-3-30 as character no-undo .
    define variable  parameter-4-30 as character no-undo .
    define variable  parameter-5-30 as character no-undo .
    define variable  parameter-6-30 as character no-undo .
    define variable  parameter-7-30 as character no-undo .
      assign
      parameter-3-30 =
                              "FOR EACH X_c-gds-hist"
      parameter-4-30 =
        (
          if ("           X_c-gds-hist.gds-code  = p-gds-code and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = p-obj-type and X_c-gds-hist.obj-code = p-obj-code))                           " + " " + where-phrase-30) <> ""
          then  substitute(' X_c-gds-hist.gds-code  = &1 and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = &2&3&2 and X_c-gds-hist.obj-code = &4))'                            ,p-gds-code                          ,chr(34)                          ,p-obj-type                          ,p-obj-code)  + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + "")
      parameter-6-30 = if sort-phrase-30 = ''
                           then
        (
        " " + " use-index idate " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index idate " +
          " " + sort-column-phrase +
        " " + sort-phrase-30
        )
      parameter-7-30 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-30 =
          ("           X_c-gds-hist.gds-code  = p-gds-code and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = p-obj-type and X_c-gds-hist.obj-code = p-obj-code))                           " + " " + where-phrase-30 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input parameter-3-30
                          ,input parameter-4-30
                          ,input parameter-5-30
                          ,input parameter-6-30
                          ,input parameter-7-30
                          )
      .
      assign
        l-filter-open-30 = true
      .
    end.
    if l-filter-open-30 = false then do:
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
  if l-filter-open-30 = false then do:
    OPEN QUERY br-gds-hist FOR EACH X_c-gds-hist
      where            X_c-gds-hist.gds-code  = p-gds-code and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = p-obj-type and X_c-gds-hist.obj-code = p-obj-code))
       use-index idate
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-gds-hist )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds-hist:handle:get-buffer-handle(1) = (buffer X_c-gds-hist:handle) then do:
      assign
      parameter-2-30 = (if p-find-next then "true":u else "false":u )
      parameter-4-30 =
        "where ":u +  substitute(' X_c-gds-hist.gds-code  = &1 and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = &2&3&2 and X_c-gds-hist.obj-code = &4))'                            ,p-gds-code                          ,chr(34)                          ,p-obj-type                          ,p-obj-code)  + " ":u + where-phrase-30 + " ":u + p-find-condition + " " + ""
      parameter-5-30 = " use-index idate "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input rowid(X_c-gds-hist)
                          ,input logical(parameter-2-30)
                          ,input no-lock
                          ,input (buffer X_c-gds-hist:handle)
                          ,input parameter-4-30
                          ,input parameter-5-30
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-30 = (if p-find-next then "true":u else "false":u )
      parameter-3-30 =  "FOR EACH X_c-gds-hist"
      parameter-4-30 =
        (
          if ("           X_c-gds-hist.gds-code  = p-gds-code and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = p-obj-type and X_c-gds-hist.obj-code = p-obj-code))                           " + " " + where-phrase-30) <> ""
          then  substitute(' X_c-gds-hist.gds-code  = &1 and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = &2&3&2 and X_c-gds-hist.obj-code = &4))'                            ,p-gds-code                          ,chr(34)                          ,p-obj-type                          ,p-obj-code)  + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-30 = if sort-phrase-30 = ''
                           then
        (
        " " + " use-index idate " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index idate " +
          " " + sort-column-phrase +
        " " + sort-phrase-30
        )
      parameter-7-30 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input logical(parameter-2-30)
                          ,input no-lock
                          ,input parameter-3-30
                          ,input parameter-4-30
                          ,input parameter-5-30
                          ,input parameter-6-30
                          ,input parameter-7-30
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
      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Один товар", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5",
                                                                                  p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code ).
        end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-32  as logical   no-undo .
define variable  l-filter-open-32    as logical   .
define variable  flt-rec-32       as recid     no-undo .
define variable  filter-name-32      as character no-undo .
define variable  where-phrase-32     as character no-undo .
define variable  sort-phrase-32      as character no-undo .
define variable  where-phrase-rus-32 as character no-undo .
define variable  sort-phrase-rus-32  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-32
  ,output filter-name-32
  ,output where-phrase-32
  ,output sort-phrase-32
  ,output where-phrase-rus-32
  ,output sort-phrase-rus-32
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-32
      ) no-error .
  assign
    l-filter-open-32 = false
  .
  if flt-rec-32 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-32 as character no-undo .
    define variable  parameter-3-32 as character no-undo .
    define variable  parameter-4-32 as character no-undo .
    define variable  parameter-5-32 as character no-undo .
    define variable  parameter-6-32 as character no-undo .
    define variable  parameter-7-32 as character no-undo .
      assign
      parameter-3-32 =
                              "FOR EACH X_c-gds-hist"
      parameter-4-32 =
        (
          if ("           X_c-gds-hist.gds-code  = p-gds-code                           " + " " + where-phrase-32) <> ""
          then  substitute(' X_c-gds-hist.gds-code  = &1', p-gds-code)  + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + "")
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + " use-index idate " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index idate " +
          " " + sort-column-phrase +
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-32 =
          ("           X_c-gds-hist.gds-code  = p-gds-code                           " + " " + where-phrase-32 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input parameter-3-32
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ,input parameter-6-32
                          ,input parameter-7-32
                          )
      .
      assign
        l-filter-open-32 = true
      .
    end.
    if l-filter-open-32 = false then do:
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
  if l-filter-open-32 = false then do:
    OPEN QUERY br-gds-hist FOR EACH X_c-gds-hist
      where            X_c-gds-hist.gds-code  = p-gds-code
       use-index idate
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-gds-hist )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds-hist:handle:get-buffer-handle(1) = (buffer X_c-gds-hist:handle) then do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-4-32 =
        "where ":u +  substitute(' X_c-gds-hist.gds-code  = &1', p-gds-code)  + " ":u + where-phrase-32 + " ":u + p-find-condition + " " + ""
      parameter-5-32 = " use-index idate "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input rowid(X_c-gds-hist)
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input (buffer X_c-gds-hist:handle)
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-3-32 =  "FOR EACH X_c-gds-hist"
      parameter-4-32 =
        (
          if ("           X_c-gds-hist.gds-code  = p-gds-code                           " + " " + where-phrase-32) <> ""
          then  substitute(' X_c-gds-hist.gds-code  = &1', p-gds-code)  + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + " use-index idate " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index idate " +
          " " + sort-column-phrase +
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input parameter-3-32
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ,input parameter-6-32
                          ,input parameter-7-32
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
      WHEN "subject":u THEN DO:
          assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Предмет изменений", filter-label0)
        v-subject-chr = entry (lookup (p-subject, 'goods,goods-attr,gds-host-attr,gds-obj-attr,fbr-gds-obj,s-coeff,bar-code,bar-code-attr,bar-code-obj-attr,prod-bc,varianty-delivery-gds-obj,gds-season,tax-rate-gds,assortment-matrix-goods,gds-obj-prop,pl-gds,pl-gds-pump,sert-join,pl-gds-attr,dis-gds-rule,ext-artic,ext-classif,recipe,recipe-gds,gds-obj,gds-obj-prop-attr':U), 'Товар,Атр-т товара,Атр-т тов. на фирме,Атр-т тов. на объекте,Атрибут РЕСТОРАНа,Сезонный коэфф,Бар-код,Атрибуты бар-кодов,Атрибуты бар-кода на объекте,ДопБК,Варианты доставки,Сезон товара,Ставки налогов,Содержимое ассортиментных матр,Индикаторы,Товар на складском месте,Товар на ТРК,Сертификат на товар,АттрТовара на скл.месте,Скидка Товара на объ.,Внешний артикул товара,Внешний классификатор,Рецепт,Товар рецепта,Товар на объекте,Атр-т тов. для заказов':U)
        .
        if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5, Предмет изменения &6",
                                                                                  p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, v-subject-chr ).
        end.
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
                              "FOR EACH X_c-gds-hist"
      parameter-4-34 =
        (
          if ("           X_c-gds-hist.gds-code  = p-gds-code  and X_c-gds-hist.subject = p-subject                         " + " " + where-phrase-34) <> ""
          then  substitute(' X_c-gds-hist.gds-code  = &1  and X_c-gds-hist.subject = &2&3&2 ', p-gds-code, chr(34), p-subject)  + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + "")
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + " use-index idate " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index idate " +
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
          ("           X_c-gds-hist.gds-code  = p-gds-code  and X_c-gds-hist.subject = p-subject                         " + " " + where-phrase-34 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds-hist:handle
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
    OPEN QUERY br-gds-hist FOR EACH X_c-gds-hist
      where            X_c-gds-hist.gds-code  = p-gds-code  and X_c-gds-hist.subject = p-subject
       use-index idate
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-gds-hist )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds-hist:handle:get-buffer-handle(1) = (buffer X_c-gds-hist:handle) then do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-4-34 =
        "where ":u +  substitute(' X_c-gds-hist.gds-code  = &1  and X_c-gds-hist.subject = &2&3&2 ', p-gds-code, chr(34), p-subject)  + " ":u + where-phrase-34 + " ":u + p-find-condition + " " + ""
      parameter-5-34 = " use-index idate "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input rowid(X_c-gds-hist)
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input (buffer X_c-gds-hist:handle)
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
      parameter-3-34 =  "FOR EACH X_c-gds-hist"
      parameter-4-34 =
        (
          if ("           X_c-gds-hist.gds-code  = p-gds-code  and X_c-gds-hist.subject = p-subject                         " + " " + where-phrase-34) <> ""
          then  substitute(' X_c-gds-hist.gds-code  = &1  and X_c-gds-hist.subject = &2&3&2 ', p-gds-code, chr(34), p-subject)  + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + " use-index idate " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index idate " +
          " " + sort-column-phrase +
        " " + sort-phrase-34
        )
      parameter-7-34 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
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
      END.
    END CASE.
  end.
  otherwise do:
    CASE p-mode :
      WHEN 'все':U        THEN DO:
      assign
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1", filter-label0)
      .
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
                              "FOR EACH X_c-gds-hist"
      parameter-4-36 =
        (
          if (" TRUE " + " " + where-phrase-36) <> ""
          then " TRUE " + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + "")
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + "  use-index ishow " +
          " " + sort-column-phrase +
        " " + " BY X_c-gds-hist.corr-date DESC BY X_c-gds-hist.corr-time DESC "
        )
                           else
        (
        " " + "  use-index ishow " +
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
          (" TRUE " + " " + where-phrase-36 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds-hist:handle
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
    OPEN QUERY br-gds-hist FOR EACH X_c-gds-hist
      where  TRUE
        use-index ishow
       BY X_c-gds-hist.corr-date DESC BY X_c-gds-hist.corr-time DESC
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-gds-hist )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds-hist:handle:get-buffer-handle(1) = (buffer X_c-gds-hist:handle) then do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-4-36 =
        "where ":u + " TRUE " + " ":u + where-phrase-36 + " ":u + p-find-condition + " " + ""
      parameter-5-36 = "  use-index ishow "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input rowid(X_c-gds-hist)
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input (buffer X_c-gds-hist:handle)
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
      parameter-3-36 =  "FOR EACH X_c-gds-hist"
      parameter-4-36 =
        (
          if (" TRUE " + " " + where-phrase-36) <> ""
          then " TRUE " + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + "  use-index ishow " +
          " " + sort-column-phrase +
        " " + " BY X_c-gds-hist.corr-date DESC BY X_c-gds-hist.corr-time DESC "
        )
                           else
        (
        " " + "  use-index ishow " +
          " " + sort-column-phrase +
        " " + sort-phrase-36
        )
      parameter-7-36 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
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
      END.
      WHEN 'фирма':U THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Фирма", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame Dialog-Frame:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5 Фирма: (&6) &7 БД: &8",
                                                            p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, p-host-code, X_clients.obj-name, p-db-num).
        end.
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
                              "FOR EACH X_c-gds-hist"
      parameter-4-38 =
        (
          if ("           X_c-gds-hist.corr-user-db-num = p-db-num ANd X_c-gds-hist.gds-code  = p-gds-code  and  (X_c-gds-hist.host-code  = p-host-code  or X_c-gds-hist.host-code = 0)                         " + " " + where-phrase-38) <> ""
          then  substitute(' X_c-gds-hist.corr-user-db-num = &1 ANd X_c-gds-hist.gds-code  = &2  and  (X_c-gds-hist.host-code  = &3  or X_c-gds-hist.host-code = 0)'                            ,p-db-num                            ,p-gds-code                             ,p-host-code)   + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + "")
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index ishow " +
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
          ("           X_c-gds-hist.corr-user-db-num = p-db-num ANd X_c-gds-hist.gds-code  = p-gds-code  and  (X_c-gds-hist.host-code  = p-host-code  or X_c-gds-hist.host-code = 0)                         " + " " + where-phrase-38 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds-hist:handle
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
    OPEN QUERY br-gds-hist FOR EACH X_c-gds-hist
      where            X_c-gds-hist.corr-user-db-num = p-db-num ANd X_c-gds-hist.gds-code  = p-gds-code  and  (X_c-gds-hist.host-code  = p-host-code  or X_c-gds-hist.host-code = 0)
       use-index ishow
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-gds-hist )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds-hist:handle:get-buffer-handle(1) = (buffer X_c-gds-hist:handle) then do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-4-38 =
        "where ":u +  substitute(' X_c-gds-hist.corr-user-db-num = &1 ANd X_c-gds-hist.gds-code  = &2  and  (X_c-gds-hist.host-code  = &3  or X_c-gds-hist.host-code = 0)'                            ,p-db-num                            ,p-gds-code                             ,p-host-code)   + " ":u + where-phrase-38 + " ":u + p-find-condition + " " + ""
      parameter-5-38 = " use-index ishow "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input rowid(X_c-gds-hist)
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input (buffer X_c-gds-hist:handle)
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
      parameter-3-38 =  "FOR EACH X_c-gds-hist"
      parameter-4-38 =
        (
          if ("           X_c-gds-hist.corr-user-db-num = p-db-num ANd X_c-gds-hist.gds-code  = p-gds-code  and  (X_c-gds-hist.host-code  = p-host-code  or X_c-gds-hist.host-code = 0)                         " + " " + where-phrase-38) <> ""
          then  substitute(' X_c-gds-hist.corr-user-db-num = &1 ANd X_c-gds-hist.gds-code  = &2  and  (X_c-gds-hist.host-code  = &3  or X_c-gds-hist.host-code = 0)'                            ,p-db-num                            ,p-gds-code                             ,p-host-code)   + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + sort-phrase-38
        )
      parameter-7-38 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
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
      END.
      WHEN 'объект':U THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Объект", filter-label0)
        .
        if p-open-query then do:
          ASSIGN
          frame Dialog-Frame:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5 Объект: &6&7 БД: &8",
                                                            p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, p-obj-type, p-obj-code, p-db-num).
        end.
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
                              "FOR EACH X_c-gds-hist"
      parameter-4-40 =
        (
          if ("           X_c-gds-hist.corr-user-db-num = p-db-num ANd X_c-gds-hist.gds-code  = p-gds-code and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = p-obj-type and X_c-gds-hist.obj-code = p-obj-code))                           " + " " + where-phrase-40) <> ""
          then  substitute(' X_c-gds-hist.corr-user-db-num = &1 ANd X_c-gds-hist.gds-code  = &2 and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = &3&4&3 and X_c-gds-hist.obj-code = &5)) '                           ,p-db-num                          ,p-gds-code                          ,chr(34)                          ,p-obj-type                          ,p-obj-code  )   + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "")
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index ishow " +
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
          ("           X_c-gds-hist.corr-user-db-num = p-db-num ANd X_c-gds-hist.gds-code  = p-gds-code and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = p-obj-type and X_c-gds-hist.obj-code = p-obj-code))                           " + " " + where-phrase-40 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds-hist:handle
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
    OPEN QUERY br-gds-hist FOR EACH X_c-gds-hist
      where            X_c-gds-hist.corr-user-db-num = p-db-num ANd X_c-gds-hist.gds-code  = p-gds-code and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = p-obj-type and X_c-gds-hist.obj-code = p-obj-code))
       use-index ishow
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-gds-hist )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds-hist:handle:get-buffer-handle(1) = (buffer X_c-gds-hist:handle) then do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-4-40 =
        "where ":u +  substitute(' X_c-gds-hist.corr-user-db-num = &1 ANd X_c-gds-hist.gds-code  = &2 and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = &3&4&3 and X_c-gds-hist.obj-code = &5)) '                           ,p-db-num                          ,p-gds-code                          ,chr(34)                          ,p-obj-type                          ,p-obj-code  )   + " ":u + where-phrase-40 + " ":u + p-find-condition + " " + ""
      parameter-5-40 = " use-index ishow "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input rowid(X_c-gds-hist)
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input (buffer X_c-gds-hist:handle)
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
      parameter-3-40 =  "FOR EACH X_c-gds-hist"
      parameter-4-40 =
        (
          if ("           X_c-gds-hist.corr-user-db-num = p-db-num ANd X_c-gds-hist.gds-code  = p-gds-code and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = p-obj-type and X_c-gds-hist.obj-code = p-obj-code))                           " + " " + where-phrase-40) <> ""
          then  substitute(' X_c-gds-hist.corr-user-db-num = &1 ANd X_c-gds-hist.gds-code  = &2 and ( X_c-gds-hist.host-code = 0 or (X_c-gds-hist.obj-type = &3&4&3 and X_c-gds-hist.obj-code = &5)) '                           ,p-db-num                          ,p-gds-code                          ,chr(34)                          ,p-obj-type                          ,p-obj-code  )   + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + sort-phrase-40
        )
      parameter-7-40 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
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
      END.
      WHEN "one":u THEN DO:
        assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Один товар", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5 БД: &6",
                                                                                  p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, p-db-num ).
        end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-42  as logical   no-undo .
define variable  l-filter-open-42    as logical   .
define variable  flt-rec-42       as recid     no-undo .
define variable  filter-name-42      as character no-undo .
define variable  where-phrase-42     as character no-undo .
define variable  sort-phrase-42      as character no-undo .
define variable  where-phrase-rus-42 as character no-undo .
define variable  sort-phrase-rus-42  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-42
  ,output filter-name-42
  ,output where-phrase-42
  ,output sort-phrase-42
  ,output where-phrase-rus-42
  ,output sort-phrase-rus-42
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-42
      ) no-error .
  assign
    l-filter-open-42 = false
  .
  if flt-rec-42 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-42 as character no-undo .
    define variable  parameter-3-42 as character no-undo .
    define variable  parameter-4-42 as character no-undo .
    define variable  parameter-5-42 as character no-undo .
    define variable  parameter-6-42 as character no-undo .
    define variable  parameter-7-42 as character no-undo .
      assign
      parameter-3-42 =
                              "FOR EACH X_c-gds-hist"
      parameter-4-42 =
        (
          if ("           X_c-gds-hist.corr-user-db-num = p-db-num ANd   X_c-gds-hist.gds-code  = p-gds-code                           " + " " + where-phrase-42) <> ""
          then  substitute('  X_c-gds-hist.corr-user-db-num = &1 ANd   X_c-gds-hist.gds-code  = &2', p-db-num, p-gds-code )  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "")
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + sort-phrase-42
        )
      parameter-7-42 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-42 =
          ("           X_c-gds-hist.corr-user-db-num = p-db-num ANd   X_c-gds-hist.gds-code  = p-gds-code                           " + " " + where-phrase-42 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input parameter-3-42
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ,input parameter-6-42
                          ,input parameter-7-42
                          )
      .
      assign
        l-filter-open-42 = true
      .
    end.
    if l-filter-open-42 = false then do:
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
  if l-filter-open-42 = false then do:
    OPEN QUERY br-gds-hist FOR EACH X_c-gds-hist
      where            X_c-gds-hist.corr-user-db-num = p-db-num ANd   X_c-gds-hist.gds-code  = p-gds-code
       use-index ishow
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-gds-hist )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds-hist:handle:get-buffer-handle(1) = (buffer X_c-gds-hist:handle) then do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-4-42 =
        "where ":u +  substitute('  X_c-gds-hist.corr-user-db-num = &1 ANd   X_c-gds-hist.gds-code  = &2', p-db-num, p-gds-code )  + " ":u + where-phrase-42 + " ":u + p-find-condition + " " + ""
      parameter-5-42 = " use-index ishow "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input rowid(X_c-gds-hist)
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input (buffer X_c-gds-hist:handle)
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-3-42 =  "FOR EACH X_c-gds-hist"
      parameter-4-42 =
        (
          if ("           X_c-gds-hist.corr-user-db-num = p-db-num ANd   X_c-gds-hist.gds-code  = p-gds-code                           " + " " + where-phrase-42) <> ""
          then  substitute('  X_c-gds-hist.corr-user-db-num = &1 ANd   X_c-gds-hist.gds-code  = &2', p-db-num, p-gds-code )  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + sort-phrase-42
        )
      parameter-7-42 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input parameter-3-42
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ,input parameter-6-42
                          ,input parameter-7-42
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
      WHEN "subject":u THEN DO:
          assign
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Предмет изменений", filter-label0)
        v-subject-chr = entry (lookup (p-subject, 'goods,goods-attr,gds-host-attr,gds-obj-attr,fbr-gds-obj,s-coeff,bar-code,bar-code-attr,bar-code-obj-attr,prod-bc,varianty-delivery-gds-obj,gds-season,tax-rate-gds,assortment-matrix-goods,gds-obj-prop,pl-gds,pl-gds-pump,sert-join,pl-gds-attr,dis-gds-rule,ext-artic,ext-classif,recipe,recipe-gds,gds-obj,gds-obj-prop-attr':U), 'Товар,Атр-т товара,Атр-т тов. на фирме,Атр-т тов. на объекте,Атрибут РЕСТОРАНа,Сезонный коэфф,Бар-код,Атрибуты бар-кодов,Атрибуты бар-кода на объекте,ДопБК,Варианты доставки,Сезон товара,Ставки налогов,Содержимое ассортиментных матр,Индикаторы,Товар на складском месте,Товар на ТРК,Сертификат на товар,АттрТовара на скл.месте,Скидка Товара на объ.,Внешний артикул товара,Внешний классификатор,Рецепт,Товар рецепта,Товар на объекте,Атр-т тов. для заказов':U)
        .
        if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE = title0 + substitute(" Товар с кодом &1: &2 &3 &4&5, Предмет изменения &6 БД: &7",
                                                                                  p-gds-code, v-gds-name, v-artic, v-prod-type, v-prod-code, v-subject-chr, p-db-num ).
        end.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-44  as logical   no-undo .
define variable  l-filter-open-44    as logical   .
define variable  flt-rec-44       as recid     no-undo .
define variable  filter-name-44      as character no-undo .
define variable  where-phrase-44     as character no-undo .
define variable  sort-phrase-44      as character no-undo .
define variable  where-phrase-rus-44 as character no-undo .
define variable  sort-phrase-rus-44  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-44
  ,output filter-name-44
  ,output where-phrase-44
  ,output sort-phrase-44
  ,output where-phrase-rus-44
  ,output sort-phrase-rus-44
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-44
      ) no-error .
  assign
    l-filter-open-44 = false
  .
  if flt-rec-44 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-44 as character no-undo .
    define variable  parameter-3-44 as character no-undo .
    define variable  parameter-4-44 as character no-undo .
    define variable  parameter-5-44 as character no-undo .
    define variable  parameter-6-44 as character no-undo .
    define variable  parameter-7-44 as character no-undo .
      assign
      parameter-3-44 =
                              "FOR EACH X_c-gds-hist"
      parameter-4-44 =
        (
          if ("           X_c-gds-hist.corr-user-db-num = p-db-num ANd   X_c-gds-hist.gds-code  = p-gds-code  and X_c-gds-hist.subject = p-subject                         " + " " + where-phrase-44) <> ""
          then  substitute(' X_c-gds-hist.corr-user-db-num = &1 ANd   X_c-gds-hist.gds-code  =   and X_c-gds-hist.subject = &3&4&3'                            ,p-db-num                            ,p-gds-code                            ,chr(34)                            ,p-subject)    + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "")
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-44 =
          ("           X_c-gds-hist.corr-user-db-num = p-db-num ANd   X_c-gds-hist.gds-code  = p-gds-code  and X_c-gds-hist.subject = p-subject                         " + " " + where-phrase-44 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input parameter-3-44
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ,input parameter-6-44
                          ,input parameter-7-44
                          )
      .
      assign
        l-filter-open-44 = true
      .
    end.
    if l-filter-open-44 = false then do:
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
  if l-filter-open-44 = false then do:
    OPEN QUERY br-gds-hist FOR EACH X_c-gds-hist
      where            X_c-gds-hist.corr-user-db-num = p-db-num ANd   X_c-gds-hist.gds-code  = p-gds-code  and X_c-gds-hist.subject = p-subject
       use-index ishow
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-gds-hist )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-gds-hist:handle:get-buffer-handle(1) = (buffer X_c-gds-hist:handle) then do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-4-44 =
        "where ":u +  substitute(' X_c-gds-hist.corr-user-db-num = &1 ANd   X_c-gds-hist.gds-code  =   and X_c-gds-hist.subject = &3&4&3'                            ,p-db-num                            ,p-gds-code                            ,chr(34)                            ,p-subject)    + " ":u + where-phrase-44 + " ":u + p-find-condition + " " + ""
      parameter-5-44 = " use-index ishow "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input rowid(X_c-gds-hist)
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input (buffer X_c-gds-hist:handle)
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-3-44 =  "FOR EACH X_c-gds-hist"
      parameter-4-44 =
        (
          if ("           X_c-gds-hist.corr-user-db-num = p-db-num ANd   X_c-gds-hist.gds-code  = p-gds-code  and X_c-gds-hist.subject = p-subject                         " + " " + where-phrase-44) <> ""
          then  substitute(' X_c-gds-hist.corr-user-db-num = &1 ANd   X_c-gds-hist.gds-code  =   and X_c-gds-hist.subject = &3&4&3'                            ,p-db-num                            ,p-gds-code                            ,chr(34)                            ,p-subject)    + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " use-index ishow " +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-gds-hist:handle
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input parameter-3-44
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ,input parameter-6-44
                          ,input parameter-7-44
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
    END CASE.
  end.
END CASE.
if not p-open-query  and v-doc-rec <> ? then
REPOSITION br-gds-hist to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-gds-hist:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-gds-hist in frame Dialog-Frame.
APPLY "ENTRY" TO br-gds-hist.
END PROCEDURE.
PROCEDURE proc-b-print :
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable accum-count as integer.
define variable v-doc-rec as recid no-undo.
define variable v-prod as character no-undo .
define variable v-subject-chr as character no-undo .
define variable v-upd-time as character no-undo .
define variable v-obj as character no-undo .
define variable v-action-chr as character no-undo .
define variable v-source-type as character no-undo .
DEFINE FRAME HistoryList
X_c-gds-hist.gds-code
v-action-chr FORMAT "X(10)"
v-gds-name COLUMN-LABEL "Назв. товара" FORMAT "X(20)"
v-artic COLUMN-LABEL "Артикул" FORMAT "X(14)"
v-prod COLUMN-LABEL "Пр-ль" FORMAT "X(12)"
v-subject-chr COLUMN-LABEL "Предмет изменений" FORMAT "X(20)"
X_c-gds-hist.is-news COLUMn-LABEL "СПН" FORMAT "+/ "
v-source-type COLUMn-LABEL "Источн.!измен"
X_c-gds-hist.source-ref COLUMn-LABEL "№"
X_c-gds-hist.corr-date
v-upd-time COLUMN-LABEL "Время изм." FORMAT "X(8)"
X_c-gds-hist.corr-user-name
X_c-gds-hist.corr-user-db-num
X_c-gds-hist.host-code COLUMN-LABEL "Фирма"
v-obj COLUMN-LABEL "Объект" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(192)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 192).
date_string = cur-time-print() .
assign
v-doc-rec = recid( X_c-gds-hist ).
DO WHILE available X_c-gds-hist :
      GET prev br-gds-hist.
END.
run prn-lib-open-stream  in this-procedure (
                                             input parparentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame Dialog-Frame:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(177)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME HistoryList  .
run waitfram-show in this-procedure ("Ждите...").
  GET next br-gds-hist.
    DO WHILE available X_c-gds-hist :
      Display STREAM PrnLibStream
      X_c-gds-hist.gds-code
      get-action(X_c-gds-hist.action) @ v-action-chr
      (if v-find then get-good(X_c-gds-hist.gds-code, output v-artic, output v-prod-type, output v-prod-code) else "":U )
      @ v-gds-name
      v-artic
      (v-prod-type + string(v-prod-code)) @ v-prod
      get-subject(X_c-gds-hist.subject) @ v-subject-chr
      X_c-gds-hist.is-news
      get-source-type(X_c-gds-hist.source-type) @ v-source-type
      X_c-gds-hist.source-ref
      X_c-gds-hist.corr-date
      string(X_c-gds-hist.corr-time, "HH:MM:SS":U) @ v-upd-time
      usrfulnf(X_c-gds-hist.corr-user-name)
      X_c-gds-hist.corr-user-db-num
      X_c-gds-hist.host-code
      X_c-gds-hist.obj-type + string(X_c-gds-hist.obj-code) @ v-obj
      with FRAME HistoryList .
  DOWN STREAM PrnLibStream 1 with FRAME HistoryList  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-gds-hist.
END.
UNDERLINE  STREAM PrnLibStream
X_c-gds-hist.gds-code
v-action-chr
v-gds-name
v-artic
v-prod
v-subject-chr
X_c-gds-hist.is-news
v-source-type
X_c-gds-hist.source-ref
X_c-gds-hist.corr-date
v-upd-time
X_c-gds-hist.corr-user-name
X_c-gds-hist.corr-user-db-num
X_c-gds-hist.host-code
v-obj
with FRAME HistoryList .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ X_c-gds-hist.gds-code
string(accum-count)  @ v-action-chr
with frame HistoryList.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure.
run prn-lib-prn-file in this-procedure (
                                          input parparentproc
                                          ,input 8
                                          ).
reposition br-gds-hist to recid v-doc-rec no-error.
apply "entry" to br-gds-hist in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'c-gds-hist'
  join-tbl = 'X_c-gds-hist'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('gds-code', 'Код товара', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('subject', 'Предмет изменения', 'gds-hist-subject',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('source-type', 'Источник_измен-я', 'hist-source-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('source-ref', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('b-code', 'Бар-код', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('b-str', 'ДопБК', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    ,INPUT (filter-point + chr(4) +
                              filter-label0 + chr(4) +
                              string(yes))
                    ,INPUT tbl
                    ,INPUT join-tbl
                    ,INPUT fld
                    ,INPUT lab
                    ,INPUT spr
                    ,INPUT dim ).
  run OpenBr in this-procedure ( input yes, input no, input '':U, input v-corr-user-db-num).
END.
END PROCEDURE.
PROCEDURE proc-br-gds-hist :
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if b-sel:sensitive in frame Dialog-Frame then dO:
    if b-mark:sensitive then do:
        apply "choose" to b-mark in frame Dialog-Frame.
    end.
    else do:
        apply "choose" to b-sel in frame Dialog-Frame.
    end.
end.
else do:
    if b-lookup:sensitive then
    apply "choose" to b-lookup in frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE proc-find-corr-date :
define input parameter p-next as logical no-undo.
define input parameter p-date like ub.fin-doc.doc-date no-undo.
define variable v-date-chr as character no-undo.
if p-date = ? then return .
display
0 @ sch-gds-code
0 @ sch-db-num
"":U @ sch-corr-user-name
with frame Dialog-Frame.
assign
v-date-chr = string(day(p-date)) + chr(47) +
                 string(month(p-date)) + chr(47) +
                 string(year(p-date)).
       run OpenBr in this-procedure
        (input false
        ,input true
        ,input substitute("and X_c-gds-hist.corr-date = &1 "
          , v-date-chr)
        ,input v-corr-user-db-num
        ).
      apply "entry":u to sch-corr-date in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-find-db-num :
define input parameter p-next as logical no-undo.
define input parameter p-db-num like ub.c-gds-hist.corr-user-db-num no-undo.
define variable v-db-num as character no-undo.
assign
sch-corr-date = ?
.
display
"":U @ sch-corr-user-name
0 @ sch-gds-code
sch-corr-date
with frame Dialog-Frame.
assign
v-db-num = string(p-db-num).
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-gds-hist.corr-user-db-num = &1 "
      , v-db-num)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-db-num in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-gds-code :
define input parameter p-next as logical no-undo.
define input parameter p-gds-code like ub.c-gds-hist.gds-code no-undo.
define variable v-gds-code as character no-undo.
assign
sch-corr-date = ?.
display
"":U @ sch-corr-user-name
0 @ sch-db-num
sch-corr-date
with frame Dialog-Frame.
assign
v-gds-code = string(p-gds-code).
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-gds-hist.gds-code = &1 "
      , v-gds-code)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-gds-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-user :
define input parameter p-next as logical no-undo.
define input parameter p-user like ub.c-gds-hist.corr-user-name no-undo.
assign
sch-corr-date = ?.
display
0 @ sch-db-num
sch-corr-date
0 @ sch-gds-code
with frame Dialog-Frame.
p-user = chr(34) + p-user + chr(34).
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-gds-hist.corr-user-name = &1 "
      , p-user)
    ,input v-corr-user-db-num
    ).
apply "entry":u to sch-corr-user-name in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-view-changes :
define variable v-description as character no-undo .
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-gds-hist then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
run ref/cgdshisv.p (
                   input X_c-gds-hist.gds-code
                  ,input X_c-gds-hist.chip-num
                  ,input X_c-gds-hist.corr-user-db-num
                  ,input X_c-gds-hist.host-code
                  ,input X_c-gds-hist.obj-type
                  ,input X_c-gds-hist.obj-code
                  ,input X_c-gds-hist.subject
                  ,input X_c-gds-hist.action
                  ,input no
                  ,input "":U
                  ,output v-description
               ) no-error .
Open QUery br-changes for each temp-changes.
assign
br-changes:title in frame Dialog-Frame = v-description
.
END PROCEDURE.
FUNCTION get-action RETURNS CHARACTER
  ( p-action as integer ) :
  define variable dops as character no-undo.
assign dops = entry (lookup (trim(string(p-action)), '99,1,2,3,4,9,51,79':U), 'Удаление,Создание,Изменение,Коррекция,Восстановление,Смена_кода,Смена_артик,Выключ.':U) no-error.
RETURN dops.
END FUNCTION.
FUNCTION get-good RETURNS CHARACTER
  ( p-gds-code as integer, output p-artic as character, output p-prod-type as character, output p-prod-code as integer ) :
define buffer buf_goods for ub.goods.
find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error.
if not available buf_goods then do:
    return "!!! Неизвестный товар!!!".
end.
assign
p-artic =  buf_goods.artic
p-prod-type =  buf_goods.prod-type
p-prod-code =  buf_goods.prod-code
.
  RETURN buf_goods.gds-name.
END FUNCTION.
FUNCTION get-source-type RETURNS CHARACTER
  ( p-source-type as character ) :
define variable v-dop as character no-undo .
assign
v-dop =  entry (lookup (p-source-type, ',db,esys,trn-doc,payment,fin-doc,import,recalc,wth-doc,ren-gdsc,upgrade,grp-chg,stop-list,dis-card':U), ',БД,ВС,Документ,Платеж,Фин.док.,Импорт,Пересчет,Документ МЦ,Коллизия,Апгрейд,Изм.группы,Стоплист,ДК':U) no-error
.
  RETURN v-dop .
END FUNCTION.
FUNCTION get-subject RETURNS CHARACTER
  ( p-subject as character ) :
define variable v-return as character no-undo .
assign
v-return =  entry (lookup (p-subject, 'goods,goods-attr,gds-host-attr,gds-obj-attr,fbr-gds-obj,s-coeff,bar-code,bar-code-attr,bar-code-obj-attr,prod-bc,varianty-delivery-gds-obj,gds-season,tax-rate-gds,assortment-matrix-goods,gds-obj-prop,pl-gds,pl-gds-pump,sert-join,pl-gds-attr,dis-gds-rule,ext-artic,ext-classif,recipe,recipe-gds,gds-obj,gds-obj-prop-attr':U), 'Товар,Атр-т товара,Атр-т тов. на фирме,Атр-т тов. на объекте,Атрибут РЕСТОРАНа,Сезонный коэфф,Бар-код,Атрибуты бар-кодов,Атрибуты бар-кода на объекте,ДопБК,Варианты доставки,Сезон товара,Ставки налогов,Содержимое ассортиментных матр,Индикаторы,Товар на складском месте,Товар на ТРК,Сертификат на товар,АттрТовара на скл.месте,Скидка Товара на объ.,Внешний артикул товара,Внешний классификатор,Рецепт,Товар рецепта,Товар на объекте,Атр-т тов. для заказов':U) no-error.
if error-status:error then  do:
  message error-status:get-message(1) view-as alert-box .
  RETURN p-subject.
end.
else return v-return.
END FUNCTION.
