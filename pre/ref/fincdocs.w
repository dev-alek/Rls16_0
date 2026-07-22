DEFINE BUFFER find_c-fin-doc FOR ub.c-fin-doc.
DEFINE BUFFER X_c-fin-doc FOR ub.c-fin-doc.
DEFINE BUFFER X_clients-host FOR ub.clients.
DEFINE BUFFER X_fin-doc FOR ub.fin-doc.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter bttns  as char   no-undo .
define input parameter p-mode  as char   no-undo .
define input parameter p-host-code like ub.c-fin-doc.host-code no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-fin-doc-code like ub.c-fin-doc.fin-doc-code no-undo .
define input-output param p-rid-list    as  char no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список истории платежей":U.
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
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure movewidg_up-down :
define input parameter p-fh as widget-handle no-undo .
define input parameter p-widget-name as character no-undo .
define input parameter p-move-rows as decimal no-undo .
define variable v-ii as integer no-undo .
define variable v-h as handle no-undo .
define variable v-gh as handle no-undo .
define variable v-lh as handle no-undo .
define variable v-widget-handles as character no-undo .
define variable v-widget-labels as character no-undo .
assign
v-gh = p-fh:first-child
v-widget-handles = fill( chr(44), num-entries(p-widget-name) - 1)
v-widget-labels = fill( chr(44), num-entries(p-widget-name) - 1)
.
do while valid-handle(v-gh):
  v-h = v-gh:first-child.
  do while valid-handle(v-h):
    if lookup(v-h:name, p-widget-name) > 0 then do:
      assign
      entry(lookup(v-h:name, p-widget-name), v-widget-handles) = string(v-h)
      .
      if lookup(v-h:type, "COMBO-BOX,EDITOR,FILL-IN,RADIO-SET,SELECTION-LIST,SLIDER,TEXT") > 0
      and  valid-handle(v-h:side-label-handle) then do:
        assign
        entry(lookup(v-h:name, p-widget-name), v-widget-labels) = string(v-h:side-label-handle)
        .
      end.
    end.
    v-h = v-h:next-sibling.
  end.
  v-gh = v-gh:next-sibling.
end.
do v-ii = 1 to num-entries(p-widget-name):
  assign
  v-h = widget-handle(entry(v-ii, v-widget-handles))
  v-lh = (if entry(v-ii, v-widget-labels) <> ''
          then widget-handle(entry(v-ii, v-widget-labels))
          else ?)
  .
  if valid-handle(v-h) then do:
    assign
    v-h:row = v-h:row + p-move-rows
    .
  end.
  if valid-handle(v-lh) then do:
    assign
    v-lh:row = v-lh:row + p-move-rows
    .
  end.
end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable filter-point as character no-undo init "fincdocs" .
define variable filter-point0 as character no-undo init "fincdocs" .
define variable filter-label as character no-undo init "Список истории платажей" .
define variable filter-label0 as character no-undo init "Список истории платежей" .
define variable v-rid-list as character no-undo .
define variable sort-column-name as character no-undo .
define variable client-option as character no-undo.
define variable schet-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-doc-rec as recid no-undo .
define variable is-cash-mode as logical no-undo init ?.
DEFINE VARIABLE v-fin-doc-shift-name-num AS CHARACTER NO-UNDO.
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
DEFINE BUFFER X_cli-fin-schet FOR ub.fin-schet.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_obj FOR ub.clients.
DEFINE BUFFER X_contract FOR ub.contract.
DEFINE BUFFER X_currency FOR ub.currency.
DEFINE BUFFER X_fin-schet FOR ub.fin-schet.
define buffer X_curr_sysconf for ub.sysconf.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp-changes no-undo
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
FUNCTION get-contract RETURNS CHARACTER
  ( BUFFER loc-c-fin-doc FOR ub.c-fin-doc )  FORWARD.
FUNCTION get-cashbookname RETURNS CHARACTER
  ( input icashbookid as int64 )  FORWARD.
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-c-fin-doc FOR ub.c-fin-doc )  FORWARD.
FUNCTION get-shift RETURNS DATE
  ( BUFFER buf_c-fin-doc FOR ub.c-fin-doc, OUTPUT p-shift-name-num AS CHARACTER )  FORWARD.
DEFINE MENU MENU-B-client
       MENU-ITEM receiver       LABEL "Получатель"
       MENU-ITEM payer          LABEL "Плательщик"    .
DEFINE MENU MENU-B-schet
       MENU-ITEM receiver-schet LABEL "Получатель"
       MENU-ITEM payer-schet    LABEL "Плательщик"    .
DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-client
     LABEL "&Контраг."
     SIZE 10 BY 1.
DEFINE BUTTON B-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lookup
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
DEFINE BUTTON B-schet
     LABEL "&Счета"
     SIZE 10 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-poisk AS CHARACTER FORMAT "X(256)":U INITIAL "ПОИСК ПО:"
      VIEW-AS TEXT
     SIZE 9.6 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sch-BIK AS CHARACTER FORMAT "X(9)":U
     LABEL "БИК"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-c-schet AS CHARACTER FORMAT "X(9)":U
     LABEL "Корр.счет"
     VIEW-AS FILL-IN
     SIZE 22 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-cli-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "код"
     VIEW-AS FILL-IN
     SIZE 11 BY .93 NO-UNDO.
DEFINE VARIABLE sch-curr-code AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "коду вал"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE sch-doc-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате док-та"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE sch-fact-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате факт."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE sch-name AS CHARACTER FORMAT "X(35)":U
     LABEL "нач.назв."
     VIEW-AS FILL-IN
     SIZE 31 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-pay-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате плат."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE sch-prn-doc-code AS CHARACTER FORMAT "X(16)":U
     LABEL "номеру"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-r-schet AS CHARACTER FORMAT "X(35)":U
     LABEL "Расч.счет"
     VIEW-AS FILL-IN
     SIZE 22 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE RS-cli-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 1", "2"
     SIZE 14.1 BY 1.03 NO-UNDO.
DEFINE VARIABLE RS-receiver-payer AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 1", "2"
     SIZE 26.8 BY 1 NO-UNDO.
DEFINE QUERY br-c-fin-doc FOR
      X_c-fin-doc SCROLLING.
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
DEFINE BROWSE br-c-fin-doc
  QUERY br-c-fin-doc DISPLAY
      mark-string(recid(X_c-fin-doc), v-rid-list) FORMAT "X(1)":U
      X_c-fin-doc.host-code COLUMN-LABEL "Код!фирмы" FORMAT "999999999":U
      X_c-fin-doc.prn-doc-code FORMAT "X(16)":U
      X_c-fin-doc.doc-date FORMAT "99/99/9999":U
      get-shift(BUFFER X_c-fin-doc, OUTPUT v-fin-doc-shift-name-num) COLUMN-LABEL "Дата!смены"
      v-fin-doc-shift-name-num COLUMN-LABEL "Смена" format "X(6)"
      usrfulnf(X_c-fin-doc.user-name-doc) COLUMN-LABEL "Создал" FORMAT "X(8)":U
      X_c-fin-doc.fin-doc-type FORMAT "X(8)":U
      X_c-fin-doc.status_ FORMAT "X(8)":U
      X_c-fin-doc.sum-doc FORMAT ">,>>>,>>>,>>>,>>9.99":U
      get-currency(buffer X_c-fin-doc) COLUMN-LABEL "Вал" FORMAT "X(3)":U
      usrfulnf(X_c-fin-doc.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(8)":U
      X_c-fin-doc.corr-date FORMAT "99/99/9999":U
      string(X_c-fin-doc.corr-time, "hh:mm") COLUMN-LABEL "Время коррекц"
      X_c-fin-doc.fin-ext-doc-type COLUMN-LABEL "Расш.тип" FORMAT "X(8)":U
      X_c-fin-doc.perm-date FORMAT "99/99/9999":U
      usrfulnf(X_c-fin-doc.user-name-perm) COLUMN-LABEL "Закрыл!на разр" FORMAT "X(8)":U
      X_c-fin-doc.pay-date COLUMN-LABEL "Дата платежа!(пост.в банк)" FORMAT "99/99/9999":U
      usrfulnf(X_c-fin-doc.user-name-pl) COLUMN-LABEL "Закрыл!на опл" FORMAT "X(8)":U
      X_c-fin-doc.fact-date FORMAT "99/99/9999":U
      usrfulnf(X_c-fin-doc.user-name-fact) COLUMN-LABEL "Закрыл!на факт" FORMAT "X(8)":U
      if X_c-fin-doc.obj-code <> 0 then (X_c-fin-doc.obj-type + string(X_c-fin-doc.obj-code)) else "":U COLUMN-LABEL "Объект" FORMAT "X(8)":U
      X_c-fin-doc.receiver-type + string(X_c-fin-doc.receiver-code) COLUMN-LABEL "Получатель" FORMAT "X(12)":U
      X_c-fin-doc.payer-type + string(X_c-fin-doc.payer-code) COLUMN-LABEL "Плательщик" FORMAT "X(12)":U
      get-contract(buffer X_c-fin-doc) COLUMN-LABEL "Договор" FORMAT "X(16)":U
      X_c-fin-doc.fin-doc-code COLUMN-LABEL "Вн.N" FORMAT "999999999":U
      get-CashbookName(X_c-fin-doc.cashbookid) COLUMN-LABEL "Кассовая книга" FORMAT "x(30)":U
  ENABLE
      X_c-fin-doc.prn-doc-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 7.37.
DEFINE BROWSE BR-changes
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 41
     B-client AT ROW 1 COL 51
     B-schet AT ROW 1 COL 61
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     br-c-fin-doc AT ROW 2 COL 1.4
     ED-notes AT ROW 9.5 COL 1 NO-LABEL
     sch-prn-doc-code AT ROW 11.57 COL 88.6 COLON-ALIGNED
     sch-curr-code AT ROW 12.57 COL 9 COLON-ALIGNED
     B-curr AT ROW 12.57 COL 15.5
     sch-doc-date AT ROW 12.57 COL 38.1 COLON-ALIGNED
     sch-fact-date AT ROW 12.57 COL 62 COLON-ALIGNED
     sch-pay-date AT ROW 12.57 COL 86 COLON-ALIGNED
     sch-c-schet AT ROW 13.77 COL 40.9 COLON-ALIGNED
     RS-receiver-payer AT ROW 13.8 COL 1.6 NO-LABEL
     sch-r-schet AT ROW 13.8 COL 75.3 COLON-ALIGNED
     sch-BIK AT ROW 14.93 COL 7.5 COLON-ALIGNED
     sch-cli-code AT ROW 14.93 COL 26 COLON-ALIGNED
     RS-cli-type AT ROW 14.93 COL 39.6 NO-LABEL
     sch-name AT ROW 14.93 COL 66.3 COLON-ALIGNED
     B-cli AT ROW 14.97 COL 54.5
     BR-changes AT ROW 16.03 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     f-poisk AT ROW 11.77 COL 70.9 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     SPACE(16.80) SKIP(9.60)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список истории платежей"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-client:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-client:HANDLE.
ASSIGN
       B-schet:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-schet:HANDLE.
ASSIGN
       br-c-fin-doc:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.
ON ENDKEY OF FRAME Dialog-Frame
DO:
    run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input v-rid-list) no-error.
  if error-status:error then return no-apply.
END.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON CHOOSE OF B-cli IN FRAME Dialog-Frame
DO:
define variable ref-list as character no-undo.
define variable ref-rec as recid no-undo.
define buffer buf_clients for ub.clients.
  run ref/cli-all.w ( parParentProc
                  , "b-sel"
                  , RS-cli-type
                  , ?
                  , ?
                  , ?
                  , ?
                  , "without-obj":U
                  , output ref-list) .
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
END.
ON CHOOSE OF B-client IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo.
if not available X_c-fin-doc then return no-apply.
if client-option = '':U then do:
        run gbl/pop-up.p (self:handle, no) no-error.
end.
if client-option = '':U then return no-apply.
  run ref/showcli.p (input parParentProc
               ,(if client-option = "receiver" then X_c-fin-doc.receiver-type else X_c-fin-doc.payer-type)
               , (if client-option = "receiver" then X_c-fin-doc.receiver-code else X_c-fin-doc.payer-code)
                                ) no-error.
 client-option = '':U.
 APPLY "ENTRY" to br-c-fin-doc.
END.
ON CHOOSE OF B-curr IN FRAME Dialog-Frame
DO:
define variable rr as recid no-undo.
define buffer buf_currency for ub.currency.
    rr = ? .
    run ref/currency.w (parparentproc, "b-sel", input-output rr ).
    if rr <> ? then do:
        FIND FIRST buf_currency WHERE
             recid( buf_currency ) = rr NO-LOCK .
        DISPLAY
        buf_currency.curr-code @ sch-curr-code
        with frame Dialog-Frame .
    end.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
if not available X_c-fin-doc then return no-apply.
run proc-b-lookup in this-procedure no-error.
if error-status:error then do:
  return no-apply.
end.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
  if available X_c-fin-doc then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid16 as character no-undo .
define variable v-num-entry16 as integer   no-undo .
assign
  v-str-recid16 = trim( string( recid( X_c-fin-doc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry16 = lookup( v-str-recid16 , v-rid-list )
.
if v-num-entry16 > 0 then do:
  assign
    entry( v-num-entry16, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid16
  .
end.
    loc#log = br-c-fin-doc:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-c-fin-doc:select-next-row ().
        apply "VALUE-CHANGED" to br-c-fin-doc in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-c-fin-doc in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-c-fin-doc.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-schet IN FRAME Dialog-Frame
DO:
define variable loc-doc-rec as recid no-undo.
if not available X_c-fin-doc then return no-apply.
if schet-option = '':U then do:
  run gbl/pop-up.p (self:handle, no) no-error.
end.
if schet-option = '':U then return no-apply.
if X_c-fin-doc.fin-doc-type = 'пко':U
or X_c-fin-doc.fin-doc-type = 'рко':U
or X_c-fin-doc.fin-doc-type = 'апп':U
or X_c-fin-doc.fin-doc-type = 'апр':U
then do:
  message
  "Нельзя посмотреть счет по платежу" skip
  "платеж имеет тип" entry (lookup (X_c-fin-doc.fin-doc-type, 'пко,рко,ппп,рпп,апп,апр':U) + 1, ',':U + 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,приходный АПЗ,расходный АПЗ':U)
  view-as alert-box.
  return no-apply.
end.
run ref/finschti.w
              (
                 input parParentProc
                ,input p-curr-host-code
                ,input 'ПРОСМОТР':U
                ,input X_c-fin-doc.host-code
                ,input (if schet-option = "payer-schet":U
                        then X_c-fin-doc.payer-code-schet
                        else X_c-fin-doc.receiver-code-schet )
                ,input 0
                ,input (if schet-option = "payer-schet":U
                       then X_c-fin-doc.payer-type
                       else X_c-fin-doc.receiver-type)
                ,input (if schet-option = "payer-schet":U
                       then X_c-fin-doc.payer-code
                       else X_c-fin-doc.receiver-code)
                ,input X_fin-doc.curr-code
                ,input-output loc-doc-rec
                            )
.
 schet-option = '':U.
 APPLY "ENTRY" to br-c-fin-doc.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if ( available X_c-fin-doc ) then do:
    if ( v-rid-list = "" ) or b-mark:sensitive = no then
    v-rid-list = string( recid( X_c-fin-doc ) ) .
  end.
END.
ON RETURN OF br-c-fin-doc IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-c-fin-doc IN FRAME Dialog-Frame
DO:
  run proc-br-c-fin-doc no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF br-c-fin-doc IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE dops as character no-undo .
  dops = if available X_c-fin-doc then X_c-fin-doc.ps else '':U.
  ED-notes:screen-value = dops.
  run proc-view-changes in this-procedure no-error.
END.
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
  define buffer ps_fin-doc for ub.fin-doc.
  if not available X_c-fin-doc then return no-apply.
   DO on stop undo, return no-apply:
      FIND PS_fin-doc where
           recid (ps_fin-doc) = recid(X_c-fin-doc) exclusive.
      if ps_fin-doc.PS <> input frame Dialog-Frame ed-notes then
      assign
      ps_fin-doc.PS = input frame Dialog-Frame ed-notes
      .
   END.
END.
ON CHOOSE OF MENU-ITEM payer
DO:
    assign
  client-option = "payer":U.
  APPLY "CHOOSE" to b-client in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM payer-schet
DO:
    assign
  schet-option = "payer":U.
  APPLY "CHOOSE" to b-schet in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM receiver
DO:
  assign
  client-option = "receiver":U.
  APPLY "CHOOSE" to b-client in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM receiver-schet
DO:
  assign
  schet-option = "receiver":U.
  APPLY "CHOOSE" to b-schet in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF RS-cli-type IN FRAME Dialog-Frame
DO:
  assign
  RS-cli-type.
END.
ON VALUE-CHANGED OF RS-receiver-payer IN FRAME Dialog-Frame
DO:
  assign
  Rs-receiver-payer.
END.
ON CTRL-J OF sch-BIK IN FRAME Dialog-Frame
DO:
  run proc-find-bik in this-procedure(yes, input frame Dialog-Frame sch-bik) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-BIK IN FRAME Dialog-Frame
DO:
  run proc-find-bik in this-procedure(no, input frame Dialog-Frame sch-bik) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-c-schet IN FRAME Dialog-Frame
DO:
  run proc-find-c-schet in this-procedure(yes, input frame Dialog-Frame sch-c-schet) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-c-schet IN FRAME Dialog-Frame
DO:
  run proc-find-c-schet in this-procedure(no, input frame Dialog-Frame sch-c-schet) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-cli-code IN FRAME Dialog-Frame
DO:
  run proc-find-cli-code in this-procedure(yes, input frame Dialog-Frame sch-cli-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-cli-code IN FRAME Dialog-Frame
DO:
  run proc-find-cli-code in this-procedure(yes, input frame Dialog-Frame sch-cli-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-curr-code IN FRAME Dialog-Frame
DO:
  run proc-find-curr-code in this-procedure(yes, input frame Dialog-Frame sch-curr-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-curr-code IN FRAME Dialog-Frame
DO:
   run proc-find-curr-code in this-procedure(no, input frame Dialog-Frame sch-curr-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-doc-date IN FRAME Dialog-Frame
DO:
   run proc-find-date in this-procedure(yes, input frame Dialog-Frame sch-doc-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-doc-date IN FRAME Dialog-Frame
DO:
  run proc-find-date in this-procedure(no, input frame Dialog-Frame sch-doc-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-fact-date IN FRAME Dialog-Frame
DO:
  run proc-find-date in this-procedure(yes, input frame Dialog-Frame sch-fact-date, "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-fact-date IN FRAME Dialog-Frame
DO:
    run proc-find-date in this-procedure(no, input frame Dialog-Frame sch-fact-date, "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-name IN FRAME Dialog-Frame
DO:
  run proc-find-name in this-procedure(yes, input frame Dialog-Frame sch-name) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-name IN FRAME Dialog-Frame
DO:
  run proc-find-name in this-procedure(no, input frame Dialog-Frame sch-name) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-pay-date IN FRAME Dialog-Frame
DO:
    run proc-find-date in this-procedure(yes, input frame Dialog-Frame sch-pay-date, "pay-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-prn-doc-code IN FRAME Dialog-Frame
DO:
  run proc-find-prn-doc-code in this-procedure(yes, input frame Dialog-Frame sch-prn-doc-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-prn-doc-code IN FRAME Dialog-Frame
DO:
  run proc-find-prn-doc-code in this-procedure(no, input frame Dialog-Frame sch-prn-doc-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-r-schet IN FRAME Dialog-Frame
DO:
  run proc-find-r-schet in this-procedure(yes, input frame Dialog-Frame sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-r-schet IN FRAME Dialog-Frame
DO:
  run proc-find-r-schet in this-procedure(no, input frame Dialog-Frame sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-c-fin-doc :handle
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  v-doc-rec = recid(X_c-fin-doc). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-c-fin-doc to recid v-doc-rec no-error. v-doc-rec = ?.
    apply "VALUE-CHANGED" to br-c-fin-doc.
end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var sort-labelbr-c-fin-doc   as character no-undo .
def var sort-clmnbr-c-fin-doc    as handle    no-undo .
def var cur-clmnbr-c-fin-doc     as handle    no-undo .
def var cur-clmn-locbr-c-fin-doc as integer   no-undo .
def var re-querybr-c-fin-doc     as logical   initial no no-undo .
on start-search, ctrl-o of br-c-fin-doc in frame Dialog-Frame do:
   run sort-brbr-c-fin-doc
     (input (if available X_c-fin-doc
             then recid(X_c-fin-doc)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-c-fin-doc :
  define input parameter p-recid as recid no-undo .
  if re-querybr-c-fin-doc = no then do:
    assign
       cur-clmnbr-c-fin-doc = br-c-fin-doc:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-c-fin-doc <> ? then sort-clmnbr-c-fin-doc:column-fgcolor = 0.
    if cur-clmnbr-c-fin-doc = sort-clmnbr-c-fin-doc then do:
      assign
         sort-labelbr-c-fin-doc = ""
         sort-clmnbr-c-fin-doc = ?
      .
     end.
     else do:
       assign
         sort-labelbr-c-fin-doc = cur-clmnbr-c-fin-doc:label
         sort-clmnbr-c-fin-doc  = cur-clmnbr-c-fin-doc
         sort-clmnbr-c-fin-doc:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-c-fin-doc = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-c-fin-doc:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-c-fin-doc then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-c-fin-doc = cur-clmn-locbr-c-fin-doc + 1
    .
  end.
  case sort-labelbr-c-fin-doc:
        when X_c-fin-doc.prn-doc-code:label in browse br-c-fin-doc then DO:    assign       sort-column-name = "X_c-fin-doc.prn-doc-code"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-c-fin-doc') then do:
          run mv-brw-defaultbr-c-fin-doc.
        end.
      if sort-labelbr-c-fin-doc <> "" then do:
        assign
          cur-clmnbr-c-fin-doc:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-c-fin-doc = ?
      .
    end.
  end case.
    if cur-clmn-locbr-c-fin-doc <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-c-fin-doc') then do:
        run ch-clmnbr-c-fin-doc in this-procedure (cur-clmn-locbr-c-fin-doc).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-c-fin-doc to recid p-recid no-error.
    apply "value-changed" to br-c-fin-doc in frame Dialog-Frame.
  end.
  apply "entry" to br-c-fin-doc in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-c-fin-doc:
if cur-clmnbr-c-fin-doc = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input '':U).
end.
else do:
   assign re-querybr-c-fin-doc = yes.
   run sort-brbr-c-fin-doc
     (input (if available X_c-fin-doc
             then recid(X_c-fin-doc)
             else ?
            )
     ).
   assign re-querybr-c-fin-doc = no.
end.
end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-c-fin-doc :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-doc-date in frame Dialog-Frame
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
on delete-character of sch-doc-date in frame Dialog-Frame
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
on ctrl-d of sch-doc-date in frame Dialog-Frame
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
on ctrl-b of sch-doc-date in frame Dialog-Frame
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
on ctrl-e of sch-doc-date in frame Dialog-Frame
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
on ctrl-f of sch-doc-date in frame Dialog-Frame
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
  define MENU m-ed-date24
    MENU-ITEM m-ed-date24-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date24-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date24-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date24-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-doc-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-doc-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date24 :HANDLE
      sch-doc-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle24 as handle no-undo .
  assign
    v-label-handle24 = sch-doc-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle24)
  then do:
    if v-label-handle24 :tooltip = ""
    or v-label-handle24 :tooltip = ?
    then do:
      assign
        v-label-handle24 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date24-1 in menu m-ed-date24 DO:
    apply "ctrl-b":U to sch-doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-2 in menu m-ed-date24 DO:
    apply "ctrl-d":U to sch-doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-3 in menu m-ed-date24 DO:
    apply "ctrl-e":U to sch-doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-4 in menu m-ed-date24 DO:
    apply "ctrl-f":U to sch-doc-date in frame Dialog-Frame .
  END.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-pay-date in frame Dialog-Frame
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
on delete-character of sch-pay-date in frame Dialog-Frame
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
on ctrl-d of sch-pay-date in frame Dialog-Frame
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
on ctrl-b of sch-pay-date in frame Dialog-Frame
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
on ctrl-e of sch-pay-date in frame Dialog-Frame
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
on ctrl-f of sch-pay-date in frame Dialog-Frame
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
  define MENU m-ed-date26
    MENU-ITEM m-ed-date26-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date26-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date26-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date26-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-pay-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-pay-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date26 :HANDLE
      sch-pay-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle26 as handle no-undo .
  assign
    v-label-handle26 = sch-pay-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle26)
  then do:
    if v-label-handle26 :tooltip = ""
    or v-label-handle26 :tooltip = ?
    then do:
      assign
        v-label-handle26 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date26-1 in menu m-ed-date26 DO:
    apply "ctrl-b":U to sch-pay-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-2 in menu m-ed-date26 DO:
    apply "ctrl-d":U to sch-pay-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-3 in menu m-ed-date26 DO:
    apply "ctrl-e":U to sch-pay-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-4 in menu m-ed-date26 DO:
    apply "ctrl-f":U to sch-pay-date in frame Dialog-Frame .
  END.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-fact-date in frame Dialog-Frame
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
on delete-character of sch-fact-date in frame Dialog-Frame
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
on ctrl-d of sch-fact-date in frame Dialog-Frame
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
on ctrl-b of sch-fact-date in frame Dialog-Frame
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
on ctrl-e of sch-fact-date in frame Dialog-Frame
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
on ctrl-f of sch-fact-date in frame Dialog-Frame
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
  define MENU m-ed-date28
    MENU-ITEM m-ed-date28-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date28-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date28-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date28-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-fact-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-fact-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date28 :HANDLE
      sch-fact-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle28 as handle no-undo .
  assign
    v-label-handle28 = sch-fact-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle28)
  then do:
    if v-label-handle28 :tooltip = ""
    or v-label-handle28 :tooltip = ?
    then do:
      assign
        v-label-handle28 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date28-1 in menu m-ed-date28 DO:
    apply "ctrl-b":U to sch-fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date28-2 in menu m-ed-date28 DO:
    apply "ctrl-d":U to sch-fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date28-3 in menu m-ed-date28 DO:
    apply "ctrl-e":U to sch-fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date28-4 in menu m-ed-date28 DO:
    apply "ctrl-f":U to sch-fact-date in frame Dialog-Frame .
  END.
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
 if LOOKUP(p-mode, ('все':U + chr(4) +
                    "One":U + chr(4) +
                    'удаление':U + chr(4) +
                    'объект':U),
          chr(4)) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
find first X_clients-host no-lock where
            X_clients-host.obj-type = 'орг':U
        and X_clients-host.obj-code = p-host-code no-error.
if not available X_clients-host then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-host-code"
    p-host-code
    view-as alert-box ERROR.
    return.
end.
if LOOKUP('все':U, p-mode, chr(4)) > 0
or LOOKUP('объект':U, p-mode, chr(4)) > 0
or LOOKUP('удаленные':U, p-mode, chr(4)) > 0
then do:
  assign is-cash-mode = no.
end.
if lookup('объект':U, p-mode, chr(4) ) > 0 then do:
  find first X_obj no-lock where
          X_obj.obj-type = p-obj-type
      and X_obj.obj-code = p-obj-code no-error.
  if not available x_OBJ then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-obj-type/p-obj-code"
    p-obj-type p-obj-code
    view-as alert-box ERROR.
    return.
  end.
end.
if LOOKUP("one":U, p-mode, chr(4)) > 0 then do:
  find first X_fin-doc no-lock where
              X_fin-doc.host-code = p-host-code
          AND X_fin-doc.fin-doc-code = p-fin-doc-code no-error .
  if not available X_fin-doc then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-host-code и/или p-fin-doc-code"
    p-host-code p-fin-doc-code
    view-as alert-box ERROR.
    return.
  end.
  assign
  is-cash-mode =  (X_fin-doc.fin-doc-type = 'пко':U
                    OR X_fin-doc.fin-doc-type = 'рко':U)
  .
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
v-rid-list = p-rid-list.
if v-rid-list <> "" then do:
    FIND FIRST find_c-fin-doc No-LOCK where
                recid(find_c-fin-doc) = integer(entry(1, v-rid-list)) No-ERROR.
    if not avail find_c-fin-doc then do:
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
  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame Dialog-Frame .
  if v-rid-list <> "":U then
  REPOSITION br-c-fin-doc to recid integer(entry(1, v-rid-list)) No-ERROR.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-c-fin-doc as INT EXTENT 26 no-undo.
DEF VAR varmvibr-c-fin-doc       as INT no-undo.
DEF VAR varmvjbr-c-fin-doc       as INT no-undo.
DEF VAR varmvkbr-c-fin-doc       as INT no-undo.
DEF VAR varmvlbr-c-fin-doc       as INT no-undo.
DEF VAR move-elementbr-c-fin-doc as INT no-undo.
def var jjbr-c-fin-doc           as int no-undo.
do varmvibr-c-fin-doc = 1 to EXTENT(cur-clmn-numbr-c-fin-doc):
  ASSIGN cur-clmn-numbr-c-fin-doc[varmvibr-c-fin-doc] = varmvibr-c-fin-doc.
END.
RUN start-mv-clmnbr-c-fin-doc.
PROCEDURE start-mv-clmnbr-c-fin-doc:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  p-mode = 'все':U  THEN DO:
   DO jjbr-c-fin-doc = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26') TO 1 BY -1:
     RUN re-move-clmnbr-c-fin-doc ( cur-clmn-numbr-c-fin-doc[INTEGER(ENTRY (jjbr-c-fin-doc, '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26'))] , 1).
   END.
       END.
       IF  p-mode = 'one':U  THEN DO:
   DO jjbr-c-fin-doc = NUM-ENTRIES('1,12,13,14,3,4,5,6,7,10,11,15,16,17,18,19,20,21,22,23,24,25,26,2,8,9') TO 1 BY -1:
     RUN re-move-clmnbr-c-fin-doc ( cur-clmn-numbr-c-fin-doc[INTEGER(ENTRY (jjbr-c-fin-doc, '1,12,13,14,3,4,5,6,7,10,11,15,16,17,18,19,20,21,22,23,24,25,26,2,8,9'))] , 1).
   END.
       END.
       IF  p-mode = 'удаление':U or p-mode = 'объект':U  THEN DO:
   DO jjbr-c-fin-doc = NUM-ENTRIES('1,2,3,4,5,6,7,12,13,14,8,9,10,11,15,16,17,18,19,20,21,22,23,24,25,26') TO 1 BY -1:
     RUN re-move-clmnbr-c-fin-doc ( cur-clmn-numbr-c-fin-doc[INTEGER(ENTRY (jjbr-c-fin-doc, '1,2,3,4,5,6,7,12,13,14,8,9,10,11,15,16,17,18,19,20,21,22,23,24,25,26'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-c-fin-doc do:
  RUN re-move-clmnbr-c-fin-doc ( 1, 26).
END.
ON ctrl-cursor-left OF BROWSE br-c-fin-doc do:
  RUN re-move-clmnbr-c-fin-doc (26, 1).
END.
PROCEDURE re-move-clmnbr-c-fin-doc:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-c-fin-doc = 1 TO EXTENT(cur-clmn-numbr-c-fin-doc):
    if cur-clmn-numbr-c-fin-doc[varmvibr-c-fin-doc] = source-column THEN cur-clmn-numbr-c-fin-doc[varmvibr-c-fin-doc] = -1.
  END.
  if br-c-fin-doc:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-c-fin-doc = source-column - 1 to target-column BY -1:
    DO varmvibr-c-fin-doc = 1 TO EXTENT(cur-clmn-numbr-c-fin-doc):
        if cur-clmn-numbr-c-fin-doc[varmvibr-c-fin-doc] = varmvjbr-c-fin-doc THEN DO:
          cur-clmn-numbr-c-fin-doc[varmvibr-c-fin-doc] = cur-clmn-numbr-c-fin-doc[varmvibr-c-fin-doc] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-c-fin-doc = source-column + 1 to target-column:
    DO varmvibr-c-fin-doc = 1 TO EXTENT(cur-clmn-numbr-c-fin-doc):
      if cur-clmn-numbr-c-fin-doc[varmvibr-c-fin-doc] = varmvjbr-c-fin-doc THEN DO:
        cur-clmn-numbr-c-fin-doc[varmvibr-c-fin-doc] = cur-clmn-numbr-c-fin-doc[varmvibr-c-fin-doc] - 1.
      END.
    END.
  END.
  DO varmvibr-c-fin-doc = 1 TO EXTENT(cur-clmn-numbr-c-fin-doc):
    if cur-clmn-numbr-c-fin-doc[varmvibr-c-fin-doc] = -1 THEN cur-clmn-numbr-c-fin-doc[varmvibr-c-fin-doc] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-c-fin-doc:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-c-fin-doc = 1 TO EXTENT(cur-clmn-numbr-c-fin-doc):
    if cur-clmn-numbr-c-fin-doc[varmvibr-c-fin-doc] = cur-clmn-loc THEN move-elementbr-c-fin-doc = varmvibr-c-fin-doc.
  END.
  RUN re-move-clmnbr-c-fin-doc (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-c-fin-doc:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-c-fin-doc = 1 to EXTENT(cur-clmn-numbr-c-fin-doc):
    RUN re-move-clmnbr-c-fin-doc (cur-clmn-numbr-c-fin-doc[varmvlbr-c-fin-doc], varmvlbr-c-fin-doc).
  END.
  RUN start-mv-clmnbr-c-fin-doc.
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
  DISPLAY ED-notes sch-prn-doc-code sch-curr-code sch-doc-date sch-fact-date
          sch-pay-date sch-c-schet RS-receiver-payer sch-r-schet sch-BIK
          sch-cli-code RS-cli-type sch-name mark-num f-poisk
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-lookup B-client B-schet B-print B-sch B-Help
         br-c-fin-doc ED-notes sch-prn-doc-code sch-curr-code B-curr
         sch-doc-date sch-fact-date sch-pay-date sch-c-schet RS-receiver-payer
         sch-r-schet sch-BIK sch-cli-code RS-cli-type sch-name B-cli BR-changes
         mark-num f-poisk
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
assign
  b-print:MENU-MOUSE in frame Dialog-Frame = 1
  b-client:MENU-MOUSE in frame Dialog-Frame = 1
  b-schet:MENU-MOUSE in frame Dialog-Frame = 1
  br-c-fin-doc:num-locked-columns = 1
  X_c-fin-doc.prn-doc-code:read-only in browse br-c-fin-doc = yes
  RS-cli-type:radio-buttons = 'орг':U + chr(44) + 'орг':U + chr(44) + 'чел':U + chr(44) + 'чел':U
  RS-receiver-payer:radio-buttons = "Получатель" + chr(44) + "receiver":U + chr(44) + "Плательщик" + chr(44) + "payer":U
  temp-changes.l_name:resizable in browse br-changes = true
  temp-changes.v_old:resizable in browse br-changes = true
  temp-changes.v_new:resizable in browse br-changes = true
  temp-changes.l_name:width in browse br-changes = 30
  temp-changes.v_old:width in browse br-changes = 40
  temp-changes.v_new:width in browse br-changes = 40
  .
  DISPLAY
  ED-notes
  sch-prn-doc-code
  sch-cli-code
  sch-c-schet when not is-cash-mode
  sch-curr-code
  sch-doc-date
  sch-fact-date
  sch-pay-date
  sch-r-schet when not is-cash-mode
  sch-BIK when not is-cash-mode
  sch-name
  mark-num
  RS-cli-type
  RS-receiver-payer
  WITH FRAME Dialog-Frame.
  ENABLE
  b-quit
  B-lookup
  b-sel when lookup("b-sel":U, bttns) > 0
  B-mark when lookup("b-mark":U, bttns) > 0
  B-sch
  B-print
  B-client
  B-schet
  B-Help
  br-c-fin-doc
  br-changes when p-mode <> 'удаление':U
  b-curr
  b-cli
  ED-notes
  sch-prn-doc-code
  sch-cli-code
  sch-c-schet  when not is-cash-mode
  sch-curr-code
  sch-doc-date
  sch-fact-date
  sch-pay-date
  sch-r-schet  when not is-cash-mode
  sch-BIK when not is-cash-mode
  sch-name
  mark-num
  RS-cli-type
  RS-receiver-payer
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if is-cash-mode then do:
    hide
    sch-bik
    sch-r-schet
    sch-c-schet
    in frame Dialog-Frame .
  end.
  if p-mode = 'удаление':U then do:
     define variable v-height as decimal no-undo .
     assign
     v-height = br-changes:height
     browse br-c-fin-doc:height = browse br-c-fin-doc:height + v-height
     .
     run movewidg_up-down ( input frame Dialog-Frame:handle
                           ,input "b-schet,b-curr,b-client,b-cli,ED-notes,sch-prn-doc-code,sch-cli-code,sch-c-schet,sch-curr-code,sch-doc-date,sch-fact-date,sch-pay-date,sch-r-schet,sch-BIK,sch-name,RS-cli-type,RS-receiver-payer,f-poisk"
                           ,input v-height
                           )
     .
     hide
     br-changes in frame Dialog-Frame .
  end.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable title0 as character no-undo.
define variable v-filter-name as character no-undo .
title0 = "Список истории платежей" + chr(32).
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
define variable l-open-query as logical   no-undo .
filter-point = filter-point0 + p-mode.
CASE p-mode :
  WHEN 'все':U        THEN DO:
    assign
    filter-label = substitute("&1", filter-label0).
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
                              "FOR EACH X_c-fin-doc"
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
                          ,input QUERY br-c-fin-doc:handle
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
    OPEN QUERY br-c-fin-doc FOR EACH X_c-fin-doc
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
    v-doc-rec = recid( X_c-fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-c-fin-doc:handle:get-buffer-handle(1) = (buffer X_c-fin-doc:handle) then do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-4-33 =
        "where ":u + " TRUE " + " ":u + where-phrase-33 + " ":u + p-find-condition + " " + ""
      parameter-5-33 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-c-fin-doc:handle
                          ,input rowid(X_c-fin-doc)
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input (buffer X_c-fin-doc:handle)
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
      parameter-3-33 =  "FOR EACH X_c-fin-doc"
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
                          ,input QUERY br-c-fin-doc:handle
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
  WHEN "one":U        THEN DO:
    if p-open-query then do:
      ASSIGN frame Dialog-Frame:TITLE = title0 + substitute(" Фирма: (&1) &2 Платеж &3 &4",
                                        p-host-code, X_clients-host.obj-name,  X_fin-doc.fin-doc-type, X_fin-doc.prn-doc-code)
      .
    end.
    filter-label = substitute("&1 Одна фирма", filter-label0)
    .
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
                              "FOR EACH X_c-fin-doc"
      parameter-4-35 =
        (
          if (" X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.fin-doc-code  = p-fin-doc-code " + " " + where-phrase-35) <> ""
          then  substitute('X_c-fin-doc.host-code = &1 AND X_c-fin-doc.fin-doc-code  = &2 ', p-host-code, p-fin-doc-code) + " " + where-phrase-35
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
          (" X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.fin-doc-code  = p-fin-doc-code " + " " + where-phrase-35 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-c-fin-doc:handle
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
    OPEN QUERY br-c-fin-doc FOR EACH X_c-fin-doc
      where  X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.fin-doc-code  = p-fin-doc-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-c-fin-doc:handle:get-buffer-handle(1) = (buffer X_c-fin-doc:handle) then do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-4-35 =
        "where ":u +  substitute('X_c-fin-doc.host-code = &1 AND X_c-fin-doc.fin-doc-code  = &2 ', p-host-code, p-fin-doc-code) + " ":u + where-phrase-35 + " ":u + p-find-condition + " " + ""
      parameter-5-35 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-c-fin-doc:handle
                          ,input rowid(X_c-fin-doc)
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input (buffer X_c-fin-doc:handle)
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
      parameter-3-35 =  "FOR EACH X_c-fin-doc"
      parameter-4-35 =
        (
          if (" X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.fin-doc-code  = p-fin-doc-code " + " " + where-phrase-35) <> ""
          then  substitute('X_c-fin-doc.host-code = &1 AND X_c-fin-doc.fin-doc-code  = &2 ', p-host-code, p-fin-doc-code) + " " + where-phrase-35
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
                          ,input QUERY br-c-fin-doc:handle
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
  WHEN 'удаление':U        THEN DO:
    if p-open-query then do:
      ASSIGN frame Dialog-Frame:TITLE = title0 + substitute(" Фирма: (&1) &2 - платежи, удаленные в статусе &3",
                                        p-host-code, X_clients-host.obj-name,  'факт':U).
    end.
    filter-label = substitute("&1 Удаленные в статусе ФАКТ", filter-label0)
                                      .
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
                              "FOR EACH X_c-fin-doc"
      parameter-4-37 =
        (
          if (" X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.is-del = yes " + " " + where-phrase-37) <> ""
          then  substitute('X_c-fin-doc.host-code = &1 AND X_c-fin-doc.is-del = yes ', p-host-code) + " " + where-phrase-37
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
          (" X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.is-del = yes " + " " + where-phrase-37 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-c-fin-doc:handle
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
    OPEN QUERY br-c-fin-doc FOR EACH X_c-fin-doc
      where  X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.is-del = yes
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-c-fin-doc:handle:get-buffer-handle(1) = (buffer X_c-fin-doc:handle) then do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-4-37 =
        "where ":u +  substitute('X_c-fin-doc.host-code = &1 AND X_c-fin-doc.is-del = yes ', p-host-code) + " ":u + where-phrase-37 + " ":u + p-find-condition + " " + ""
      parameter-5-37 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-c-fin-doc:handle
                          ,input rowid(X_c-fin-doc)
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input (buffer X_c-fin-doc:handle)
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
      parameter-3-37 =  "FOR EACH X_c-fin-doc"
      parameter-4-37 =
        (
          if (" X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.is-del = yes " + " " + where-phrase-37) <> ""
          then  substitute('X_c-fin-doc.host-code = &1 AND X_c-fin-doc.is-del = yes ', p-host-code) + " " + where-phrase-37
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
                          ,input QUERY br-c-fin-doc:handle
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
  WHEN 'объект':U        THEN DO:
    if p-open-query then do:
      ASSIGN frame Dialog-Frame:TITLE = title0 + substitute(" Фирма: (&1) &2 &3&4 - платежи, удаленные в статусе &5",
                                        p-host-code, X_clients-host.obj-name,  X_obj.obj-type, x_obj.obj-code, 'факт':U).
    end.
    filter-label = substitute("&1 Удаленные в статусе ФАКТ", filter-label0)
                                      .
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
                              "FOR EACH X_c-fin-doc"
      parameter-4-39 =
        (
          if (" X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.is-del = yes                      and X_c-fin-doc.obj-type = p-obj-type  and X_c-fin-doc.obj-code = p-obj-code " + " " + where-phrase-39) <> ""
          then  substitute('X_c-fin-doc.host-code = &1 AND X_c-fin-doc.is-del = yes                                      and X_c-fin-doc.obj-type = &2&3&2                                      and X_c-fin-doc.obj-code = &4', p-host-code, chr(34), p-obj-type, p-obj-code ) + " " + where-phrase-39
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
          (" X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.is-del = yes                      and X_c-fin-doc.obj-type = p-obj-type  and X_c-fin-doc.obj-code = p-obj-code " + " " + where-phrase-39 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-c-fin-doc:handle
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
    OPEN QUERY br-c-fin-doc FOR EACH X_c-fin-doc
      where  X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.is-del = yes                      and X_c-fin-doc.obj-type = p-obj-type  and X_c-fin-doc.obj-code = p-obj-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_c-fin-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-c-fin-doc:handle:get-buffer-handle(1) = (buffer X_c-fin-doc:handle) then do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-4-39 =
        "where ":u +  substitute('X_c-fin-doc.host-code = &1 AND X_c-fin-doc.is-del = yes                                      and X_c-fin-doc.obj-type = &2&3&2                                      and X_c-fin-doc.obj-code = &4', p-host-code, chr(34), p-obj-type, p-obj-code ) + " ":u + where-phrase-39 + " ":u + p-find-condition + " " + ""
      parameter-5-39 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-c-fin-doc:handle
                          ,input rowid(X_c-fin-doc)
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input (buffer X_c-fin-doc:handle)
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
      parameter-3-39 =  "FOR EACH X_c-fin-doc"
      parameter-4-39 =
        (
          if (" X_c-fin-doc.host-code = p-host-code AND X_c-fin-doc.is-del = yes                      and X_c-fin-doc.obj-type = p-obj-type  and X_c-fin-doc.obj-code = p-obj-code " + " " + where-phrase-39) <> ""
          then  substitute('X_c-fin-doc.host-code = &1 AND X_c-fin-doc.is-del = yes                                      and X_c-fin-doc.obj-type = &2&3&2                                      and X_c-fin-doc.obj-code = &4', p-host-code, chr(34), p-obj-type, p-obj-code ) + " " + where-phrase-39
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
                          ,input QUERY br-c-fin-doc:handle
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
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-c-fin-doc to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-c-fin-doc:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-c-fin-doc in frame Dialog-Frame.
APPLY "ENTRY" TO br-c-fin-doc.
END PROCEDURE.
PROCEDURE proc-b-lookup :
run ref/shwcfind.p (
                    input parParentProc
                   ,input p-curr-host-code
                   ,input X_c-fin-doc.host-code
                   ,input X_c-fin-doc.fin-doc-code
                   ,input X_c-fin-doc.corr-user-db-num
                   ,input X_c-fin-doc.chip-num).
apply "entry" to br-c-fin-doc in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-print :
  run proc-print-list no-error.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'c-fin-doc'
  join-tbl = 'X_c-fin-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('fin-doc-code', 'Вн.№ платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prn-doc-code', 'Номер', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('contract-code', 'Вн.№ договора', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Дата док-та', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-doc', 'Создал', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Дата факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-fact', 'Закрыл на факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('perm-date', 'Дата разр', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-perm', 'Закрыл на разр', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-date', 'Дата платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-pl', 'Закрыл на опл', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fin-doc-type', 'Тип документа', 'fin-doc-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fin-ext-doc-type', 'Расширен. тип документа', 'fin-ext-doc-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', '', 'fin-doc-stat',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', '', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sum-doc', 'Сумма в валюте платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sum-base', 'Сумма в баз.вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sum-rubl', 'Сумма в рублях', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc', 'Внутр. код корреспонд.счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc-value', 'Корреспонд.счет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc1', 'Внутр. код корреспонд.счета2', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cor-acc1-value', 'Корреспонд.счет2', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('an-uchet-code', 'Внутр код анал.учета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('an-uchet-value', 'Код анал.учета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cel-nazn-code', 'Внутр. код целевого назначения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cel-nazn-value', 'Код целевого назначения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('vid-plat', 'Вид платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('stat-pl', 'Статус плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('vid-opl', 'Вид операции', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('nazn-pl', 'Назначение платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('nazn-pl', 'Срок платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ocher-pl', 'Очередность платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-type*receiver-code', 'Получатель', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-name', 'Название получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-bik', 'БИК получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-inn', 'ИНН получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-kpp', 'КПП получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-bank-name', 'Банк получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-bank-city', 'Город банка получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-r-schet', 'Расч.счет получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-c-schet', 'Корр.счет получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-code-schet', 'Код счета получателя', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-type*payer-code', 'Плательщик', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-name', 'Название плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-bik', 'БИК плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-inn', 'ИНН плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-kpp', 'КПП плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-bank-name', 'Банк плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-bank-city', 'Город банка плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-r-schet', 'Расч.счет плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-c-schet', 'Корр.счет плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-code-schet', 'Код счета плательщика', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', 'Дата изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', 'БД изменений', '',
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
PROCEDURE proc-br-c-fin-doc :
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE proc-find-bik :
define input parameter p-next as logical no-undo.
define input parameter p-bik like ub.fin-doc.receiver-bik no-undo.
assign
frame Dialog-Frame Rs-receiver-payer.
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-name
0 @ sch-cli-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
with frame Dialog-Frame.
if not is-cash-mode then
display
"":U @ sch-r-schet
"":U @ sch-c-schet
with frame Dialog-Frame .
assign
p-bik = replace(p-bik, chr(34), "":U)
p-bik = replace(p-bik, chr(39), chr(39) + chr(39))
p-bik = chr(34) + p-bik + chr(34).
if RS-receiver-payer = "receiver":U then do:
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-fin-doc.receiver-bik   begins &1 "
      , p-bik)
    ).
end.
if RS-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-fin-doc.payer-bik   begins &1 "
      , p-bik)
    ).
end.
apply "entry":u to sch-bik in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-c-schet :
define input parameter p-next as logical no-undo.
define input parameter p-c-schet like ub.fin-schet.c-schet no-undo.
assign
frame Dialog-Frame RS-receiver-payer .
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-name
0 @ sch-cli-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
with frame Dialog-Frame.
if not is-cash-mode then
display
"":U @ sch-BIK
"":U @ sch-r-schet
with frame Dialog-Frame.
assign
p-c-schet = replace(p-c-schet, chr(34), "":U)
p-c-schet = replace(p-c-schet, chr(39), chr(39) + chr(39))
p-c-schet = chr(34) + p-c-schet + chr(34).
if rs-receiver-payer = "receiver":U then do:
    run OpenBr in this-procedure
        (input false
        ,input p-next
        ,input substitute("and X_c-fin-doc.receiver-c-schet   begins &1 "
          , p-c-schet)
        ).
end.
if Rs-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-fin-doc.payer-c-schet   begins &1 "
      , p-c-schet)
    ).
end.
apply "entry":u to sch-c-schet in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-cli-code :
define input parameter p-next as logical no-undo.
define input parameter p-cli-code like ub.fin-schet.cli-code no-undo.
define variable v-cli-code as character no-undo.
assign
frame Dialog-Frame RS-cli-type .
assign
frame Dialog-Frame Rs-receiver-payer.
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-name
"":U @ sch-bik
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
"":U @ sch-r-schet
"":U @ sch-c-schet
with frame Dialog-Frame.
assign
v-cli-code = string(p-cli-code)
.
if RS-receiver-payer = "receiver":U then do:
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-fin-doc.receiver-type = '&1' and X_c-fin-doc.receiver-code = &2"
      , RS-cli-type, v-cli-code )
    ).
end.
if RS-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-fin-doc.payer-type = '&1' and X_c-fin-doc.payer-code = &2"
      , RS-cli-type, v-cli-code )
    ).
end.
apply "entry":u to sch-cli-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-curr-code :
define input parameter p-next as logical no-undo.
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo.
define variable v-curr-code-chr as character no-undo.
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-BIK
"":U @ sch-name
0 @ sch-cli-code
"":U @ sch-c-schet
sch-doc-date
sch-fact-date
sch-pay-date
"":U @ sch-r-schet
with frame Dialog-Frame.
assign
v-curr-code-chr = string(p-curr-code)
.
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-fin-doc.curr-code = &1 "
      , v-curr-code-chr)
    ).
apply "entry":u to sch-curr-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-date :
define input parameter p-next as logical no-undo.
define input parameter p-date like ub.fin-doc.doc-date no-undo.
define input parameter p-what-date as character no-undo.
define variable v-date-chr as character no-undo.
if p-date = ? then return .
display
"":U @ sch-BIK
"":U @ sch-name
0 @ sch-cli-code
"":U @ sch-c-schet
0 @ sch-curr-code
"":U @ sch-prn-doc-code
"":U @ sch-r-schet
with frame Dialog-Frame.
CASE p-what-date:
    when "doc-date":U then do:
      assign
      sch-pay-date = ?
      sch-fact-date = ?
      .
      display
      sch-fact-date
      sch-pay-date
      with frame Dialog-Frame.
    end.
    when "fact-date":U then do:
      assign
      sch-doc-date = ?
      sch-pay-date = ?
      .
      display
      sch-doc-date
      sch-pay-date
      with frame Dialog-Frame.
    end.
    when "pay-date":U then do:
      assign
      sch-doc-date = ?
      sch-fact-date = ?
      .
      display
      sch-fact-date
      sch-doc-date
      with frame Dialog-Frame.
    end.
END CASE.
assign
v-date-chr = string(day(p-date)) + chr(47) +
                 string(month(p-date)) + chr(47) +
                 string(year(p-date)).
CASE p-what-date:
    when "doc-date":U then do:
       run OpenBr in this-procedure
        (input false
        ,input true
        ,input substitute("and X_c-fin-doc.doc-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-doc-date in frame Dialog-Frame.
    end.
    when "fact-date":U then do:
       run OpenBr in this-procedure
        (input false
        ,input true
        ,input substitute("and X_c-fin-doc.fact-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-fact-date in frame Dialog-Frame.
    end.
        when "pay-date":U then do:
       run OpenBr in this-procedure
        (input false
        ,input true
        ,input substitute("and X_c-fin-doc.pay-date = &1 "
          , v-date-chr)
        ).
      apply "entry":u to sch-pay-date in frame Dialog-Frame.
    end.
END CASE.
END PROCEDURE.
PROCEDURE proc-find-name :
define input parameter p-next as logical no-undo.
define input parameter p-name as character no-undo.
assign
frame Dialog-Frame Rs-receiver-payer.
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-prn-doc-code
0 @ sch-cli-code
"":U @ sch-bik
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
"":U @ sch-r-schet
"":U @ sch-c-schet
with frame Dialog-Frame.
assign
p-name = replace(p-name, chr(39), chr(39) + chr(39))
p-name = chr(34) + p-name + chr(34).
if RS-receiver-payer = "receiver":U then do:
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-fin-doc.receiver-name   begins &1 "
      , p-name)
    ).
end.
if RS-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-fin-doc.payer-name   begins &1 "
      , p-name)
    ).
end.
apply "entry":u to sch-name in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-prn-doc-code :
define input parameter p-next as logical no-undo.
define input parameter p-prn-doc-code like ub.fin-doc.prn-doc-code no-undo.
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-BIK
"":U @ sch-name
0 @ sch-cli-code
"":U @ sch-c-schet
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
"":U @ sch-r-schet
with frame Dialog-Frame.
assign
  p-prn-doc-code = replace(p-prn-doc-code, chr(39), chr(39) + chr(39))
.
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-fin-doc.prn-doc-code = '&1' "
      , p-prn-doc-code)
    ).
apply "entry":u to sch-prn-doc-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-r-schet :
define input parameter p-next as logical no-undo.
define input parameter p-r-schet like ub.fin-schet.r-schet no-undo.
assign
frame Dialog-Frame RS-receiver-payer .
assign
sch-doc-date = ?
sch-fact-date = ?
sch-pay-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-name
0 @ sch-cli-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-pay-date
with frame Dialog-Frame.
display
"":U @ sch-BIK
"":U @ sch-c-schet
with frame Dialog-Frame.
assign
p-r-schet = replace(p-r-schet, chr(34), "":U)
p-r-schet = replace(p-r-schet, chr(39), chr(39) + chr(39))
p-r-schet = chr(34) + p-r-schet + chr(34).
if rs-receiver-payer = "receiver":U then do:
    run OpenBr in this-procedure
        (input false
        ,input p-next
        ,input substitute("and X_c-fin-doc.receiver-r-schet   begins &1 "
          , p-r-schet)
        ).
end.
if Rs-receiver-payer = "payer":U then do:
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and X_c-fin-doc.payer-r-schet   begins &1 "
      , p-r-schet)
    ).
end.
apply "entry":u to sch-r-schet in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-print-list :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
define variable v-receiver as character no-undo.
define variable v-payer as character no-undo.
define variable v-contract as character no-undo.
define variable v-curr-abbr as character no-undo.
define variable v-obj as character no-undo .
DEFINE VARIABLE v-for-user-name AS CHARACTER NO-UNDO.
run rep/g-fin-doc-list.p (parParentProc) no-error.
END PROCEDURE.
PROCEDURE proc-view-changes :
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-fin-doc then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
define variable v-label-param as character no-undo .
v-label-param =
  "actual-base-rate" + chr(4) + "Текущий курс баз.вал." + chr(4) + "" + chr(8)
 + "actual-base-scale" + chr(4) + "Текущий масштаб курса баз.вал." + chr(4) + "" + chr(8)
 + "actual-exch-rate" + chr(4) + "Текущий курс вал.платежа" + chr(4) + "" + chr(8)
 + "actual-exch-scale" + chr(4) + "Текущий масштаб курса вал.платежа" + chr(4) + "" + chr(8)
 + "an-uchet-code" + chr(4) + "Внутр. код аналит. учета" + chr(4) + "" + chr(8)
 + "base-rate" + chr(4) + "Курс баз.вал. на дату док-та" + chr(4) + "" + chr(8)
 + "base-scale" + chr(4) + "Масшаб курса баз.вал. на дату док-та" + chr(4) + "" + chr(8)
 + "cel-nazn-code" + chr(4) + "Внутр код. целев. назн." + chr(4) + "" + chr(8)
 + "contract-curr" + chr(4) + "Код валюты контракта" + chr(4) + "" + chr(8)
 + "contract-code" + chr(4) + "Вн. № контракта" + chr(4) + "" + chr(8)
 + "contract-rate" + chr(4) + "Курс вал.дог-ра на дату док-та" + chr(4) + "" + chr(8)
 + "contract-scale" + chr(4) + "Масшаб курса вал.дог-ра на дату док-та" + chr(4) + "" + chr(8)
 + "con-stat" + chr(4) + "Статус связи с ФО" + chr(4) + "" + chr(8)
 + "con-sum-base" + chr(4) + "Сумма связанной в ФО части баз вал" + chr(4) + "" + chr(8)
 + "con-sum-rubl" + chr(4) + "Сумма связанной в ФО части нац.вал." + chr(4) + "" + chr(8)
 + "cor-acc" + chr(4) + "Внутр. код корр. счета" + chr(4) + "" + chr(8)
 + "cor-acc1" + chr(4) + "Внутр. код корр. счета2" + chr(4) + "" + chr(8).
v-label-param = v-label-param
 + "curr-code" + chr(4) + "Код валюты" + chr(4) + "" + chr(8)
 + "doc-date" + chr(4) + "Дата док-та" + chr(4) + "" + chr(8)
 + "enclosure" + chr(4) + "Приложение" + chr(4) + "" + chr(8)
 + "exch-rate" + chr(4) + "Курс вал. платежа на дату док-та" + chr(4) + "" + chr(8)
 + "exch-scale" + chr(4) + "Масшаб курса вал. платежа на дату док-та" + chr(4) + "" + chr(8)
 + "f104" + chr(4) + "КБК" + chr(4) + "" + chr(8)
 + "f105" + chr(4) + "ОКАТО" + chr(4) + "" + chr(8)
 + "f106" + chr(4) + "Основание налогового платежа" + chr(4) + "" + chr(8)
 + "f107" + chr(4) + "Налоговый период" + chr(4) + "" + chr(8)
 + "f108" + chr(4) + "Номер налогового документа" + chr(4) + "" + chr(8)
 + "f109" + chr(4) + "Дата налогового документа" + chr(4) + "" + chr(8)
 + "f110" + chr(4) + "Тип налогового платежа" + chr(4) + "" + chr(8)
 + "f22" + chr(4) + "Код" + chr(4) + "" + chr(8)
 + "f23" + chr(4) + "Резервное поле" + chr(4) + "" + chr(8)
 + "fact-date" + chr(4) + "Дата факт" + chr(4) + "" + chr(8)
 + "fin-doc-code" + chr(4) + "Вн. №" + chr(4) + "" + chr(8)
 + "fin-doc-type" + chr(4) + "Тип платежа" + chr(4) + "" + chr(8)
 + "fin-ext-doc-type" + chr(4) + "Расш.тип платежа" + chr(4) + "" + chr(8)
 + "host-code" + chr(4) + "Код фирмы" + chr(4) + "" + chr(8)
 + "in-doc-code" + chr(4) + "Номер" + chr(4) + "" + chr(8)
 + "in-host-code" + chr(4) + "Фирма" + chr(4) + "" + chr(8)
 + "including" + chr(4) + "В том числе" + chr(4) + "" + chr(8)
 + "is-back-date" + chr(4) + "Платеж закрыт <задним числом>" + chr(4) + "" + chr(8)
 + "is-corr" + chr(4) + "Платеж корректировался в стат. <факт>" + chr(4) + "" + chr(8)
 + "is-del" + chr(4) + "Платеж удален в статусе <факт>" + chr(4) + "" + chr(8)
 + "nazn-pl" + chr(4) + "Наз пл" + chr(4) + "" + chr(8)
 + "naznach-plat" + chr(4) + "Назначение платежа" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "ocher-pl" + chr(4) + "Очередность платежа" + chr(4) + "" + chr(8)
 + "out-doc-code" + chr(4) + "Номер" + chr(4) + "" + chr(8)
 + "out-host-code" + chr(4) + "Фирма" + chr(4) + "" + chr(8)
 .
v-label-param = v-label-param
 + "pay-date" + chr(4) + "Дата платежа(поступило в банк)" + chr(4) + "" + chr(8)
 + "payer-bank-name" + chr(4) + "Наим. банка ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "payer-bank-city" + chr(4) + "Город банка ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "payer-bik" + chr(4) + "БИК ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "payer-c-schet" + chr(4) + "Кор.счет ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "payer-code" + chr(4) + "Код ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "payer-code-schet" + chr(4) + "Код счета ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "payer-dop1" + chr(4) + "ПЛАТЕЛЬЩИК допинф1" + chr(4) + "" + chr(8)
 + "payer-dop2" + chr(4) + "ПЛАТЕЛЬЩИК допинф2" + chr(4) + "" + chr(8)
 + "payer-dop3" + chr(4) + "ПЛАТЕЛЬЩИК допинф3" + chr(4) + "" + chr(8)
 + "payer-dop4" + chr(4) + "ПЛАТЕЛЬЩИК допинф4" + chr(4) + "" + chr(8)
 + "payer-inn" + chr(4) + "ИНН ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "payer-kpp" + chr(4) + "КПП ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "payer-name" + chr(4) + "ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "payer-okpo" + chr(4) + "ОКПО ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "payer-passport" + chr(4) + "Паспорт ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "payer-r-schet" + chr(4) + "Рас.счет ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "payer-type" + chr(4) + "Тип ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "perm-date" + chr(4) + "Дата разр" + chr(4) + "" + chr(8)
 + "prn-doc-code" + chr(4) + "Номер платежа" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Доп. инфо" + chr(4) + "" + chr(8)
 .
v-label-param = v-label-param
 + "receiver-bank-name" + chr(4) + "Наим. банка ПОЛУЧАТЕЛЯ" + chr(4) + "" + chr(8)
 + "receiver-bank-city" + chr(4) + "Город банка ПОЛУЧАТЕЛЯ" + chr(4) + "" + chr(8)
 + "receiver-bik" + chr(4) + "БИК ПОЛУЧАТЕЛЯ" + chr(4) + "" + chr(8)
 + "receiver-c-schet" + chr(4) + "Кор.счет ПОЛУЧАТЕЛЯ" + chr(4) + "" + chr(8)
 + "receiver-code" + chr(4) + "Код ПОЛУЧАТЕЛЯ" + chr(4) + "" + chr(8)
 + "receiver-code-schet" + chr(4) + "Код счета ПОЛУЧАТЕЛЯ" + chr(4) + "" + chr(8)
 + "receiver-dop1" + chr(4) + "ПОЛУЧАТЕЛЬ допинф1" + chr(4) + "" + chr(8)
 + "receiver-dop2" + chr(4) + "ПОЛУЧАТЕЛЬ допинф2" + chr(4) + "" + chr(8)
 + "receiver-dop3" + chr(4) + "ПОЛУЧАТЕЛЬ допинф3" + chr(4) + "" + chr(8)
 + "receiver-dop4" + chr(4) + "ПОЛУЧАТЕЛЬ допинф4" + chr(4) + "" + chr(8)
 + "receiver-inn" + chr(4) + "ИНН ПОЛУЧАТЕЛЯ" + chr(4) + "" + chr(8)
 + "receiver-kpp" + chr(4) + "КПП ПОЛУЧАТЕЛЯ" + chr(4) + "" + chr(8)
 + "receiver-name" + chr(4) + "ПОЛУЧАТЕЛЬ" + chr(4) + "" + chr(8)
 + "receiver-okpo" + chr(4) + "ОКПО ПОЛУЧАТЕЛЯ" + chr(4) + "" + chr(8)
 + "receiver-passport" + chr(4) + "Паспорт ПОЛУЧАТЕЛЯ" + chr(4) + "" + chr(8)
 + "receiver-r-schet" + chr(4) + "Рас.счет ПОЛУЧАТЕЛЯ" + chr(4) + "" + chr(8)
 + "receiver-type" + chr(4) + "Тип ПОЛУЧАТЕЛЯ" + chr(4) + "" + chr(8)
 + "receiver-sign1" + chr(4) + "Подпись ПОЛУЧАТЕЛЯ1" + chr(4) + "" + chr(8)
 + "receiver-sign2" + chr(4) + "Подпись ПОЛУЧАТЕЛЯ2" + chr(4) + "" + chr(8)
 + "receiver-sign3" + chr(4) + "Подпись ПОЛУЧАТЕЛЯ3" + chr(4) + "" + chr(8)
 + "receiver-sign4" + chr(4) + "Подпись ПОЛУЧАТЕЛЯ4" + chr(4) + "" + chr(8)
 + "payer-sign1" + chr(4) + "Подпись ПЛАТЕЛЬЩИКА1" + chr(4) + "" + chr(8)
 + "payer-sign2" + chr(4) + "Подпись ПЛАТЕЛЬЩИКА2" + chr(4) + "" + chr(8)
 + "payer-sign3" + chr(4) + "Подпись ПЛАТЕЛЬЩИКА3" + chr(4) + "" + chr(8)
 + "payer-sign4" + chr(4) + "Подпись ПЛАТЕЛЬЩИКА4" + chr(4) + "" + chr(8)
 .
v-label-param = v-label-param
 + "shift-date" + chr(4) + "Дата смены" + chr(4) + "" + chr(8)
 + "shift-name" + chr(4) + "Номер смены" + chr(4) + "" + chr(8)
 + "shift-num" + chr(4) + "Пор. смены" + chr(4) + "" + chr(8)
 + "srok-pl" + chr(4) + "Срок платежа" + chr(4) + "" + chr(8)
 + "stat-pl" + chr(4) + "Налоговый статус ПЛАТЕЛЬЩИКА" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + "" + chr(8)
 + "str-podr-code" + chr(4) + "Код структурного подразд." + chr(4) + "" + chr(8)
 + "str-podr-name" + chr(4) + "Назв.структ.подразд." + chr(4) + "" + chr(8)
 + "str-podr-type" + chr(4) + "Тип структ.подразд." + chr(4) + "" + chr(8)
 + "sum-base" + chr(4) + "Сумма в баз.вал." + chr(4) + "" + chr(8)
 + "sum-contr" + chr(4) + "Сумма в вал. договора" + chr(4) + "" + chr(8)
 + "sum-doc" + chr(4) + "Сумма в вал. платежа" + chr(4) + "" + chr(8)
 + "sum-rubl" + chr(4) + "Сумма в нац.вал." + chr(4) + "" + chr(8)
 + "trn-doc-code" + chr(4) + "Оп.касса" + chr(4) + "" + chr(8)
 + "user-db-num-doc" + chr(4) + "БД составления платежа" + chr(4) + "" + chr(8)
 + "user-db-num-fact" + chr(4) + "БД перевода на <факт>" + chr(4) + "" + chr(8)
 + "user-db-num-perm" + chr(4) + "БД перевода на <разр>" + chr(4) + "" + chr(8)
 + "user-db-num-pl" + chr(4) + "БД перевода в <банк>" + chr(4) + "" + chr(8)
 + "user-name-doc" + chr(4) + "Cоставил" + chr(4) + "" + chr(8)
 + "user-name-fact" + chr(4) + "Закрыл до <факт>" + chr(4) + "" + chr(8)
 + "user-name-perm" + chr(4) + "Разрешил" + chr(4) + "" + chr(8)
 + "user-name-pl" + chr(4) + "Отметка об оплате (принято банком)" + chr(4) + "" + chr(8)
 + "vid-opl" + chr(4) + "Вид оплаты" + chr(4) + "" + chr(8)
 + "vid-plat" + chr(4) + "Вид платежа" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  buffer X_c-fin-doc:handle
                                            ,input  'fin-doc':U
                                            ,input  "actual-base-rate,actual-base-scale,actual-exch-rate,actual-exch-scale,an-uchet-code," + "base-rate,base-scale,cel-nazn-code,contract-curr,contract-code," + "contract-rate,contract-scale,con-stat,con-sum-base,con-sum-rubl," +  "cor-acc,cor-acc1,curr-code,doc-date,enclosure,exch-rate,exch-scale," + "f104,f105,f106,f107,f108,f109,f110," + "f22,f23,fact-date,fin-doc-code,fin-doc-type,fin-ext-doc-type,host-code,in-doc-code,in-host-code,including,is-back-date," + "is-corr,is-del,nazn-pl,naznach-plat,obj-type,obj-code,ocher-pl,out-doc-code,out-host-code," + "pay-date,payer-bank-name,payer-bank-city,payer-bik,payer-c-schet,payer-code," + "payer-code-schet,payer-dop1,payer-dop2,payer-dop3,payer-dop4,payer-inn," + "payer-kpp,payer-name,payer-okpo,payer-passport,payer-r-schet,payer-type,perm-date," + "prn-doc-code,PS,receiver-bank-name,receiver-bank-city,receiver-bik,receiver-c-schet,receiver-code,receiver-code-schet," + "receiver-dop1,receiver-dop2,receiver-dop3,receiver-dop4,receiver-inn,receiver-kpp,receiver-name," + "receiver-okpo,receiver-passport,receiver-r-schet,receiver-type,receiver-sign1,receiver-sign2,receiver-sign3,receiver-sign4," + "payer-sign1,payer-sign2,payer-sign3,payer-sign4,srok-pl,stat-pl,status_," + "shift-date,shift-name,shift-num," + "str-podr-code,str-podr-name,str-podr-type,sum-base,sum-contr,sum-doc,sum-rubl,trn-doc-code," + "user-db-num-doc,user-db-num-fact,user-db-num-perm,user-db-num-pl,user-name-doc,user-name-fact,user-name-perm,user-name-pl," + "vid-opl,vid-plat"
                                            ,input  v-label-param).
Open QUery br-changes for each temp-changes.
END PROCEDURE.
FUNCTION get-contract RETURNS CHARACTER
  ( BUFFER loc-c-fin-doc FOR ub.c-fin-doc ) :
define buffer buf_contract for ub.contract.
  find first buf_contract no-lock where
                buf_contract.host-code = loc-c-fin-doc.host-code
            AND buf_contract.contract-code = loc-c-fin-doc.contract-code no-error.
    if available buf_contract then return buf_contract.contract-prn-code.
  RETURN "".
END FUNCTION.
FUNCTION get-cashbookname RETURNS CHARACTER
  ( input iCashbookID as int64) :
define buffer buf_cashbook for ub.cashbook.
  find first buf_cashbook no-lock where
                buf_cashbook.id = iCashbookID
     no-error.
  if available buf_cashbook
  then return buf_cashbook.CashBookName.
  else return string(iCashbookID).
END FUNCTION.
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-c-fin-doc FOR ub.c-fin-doc ) :
 define buffer buf_currency for ub.currency.
  find first buf_currency no-lock where
                buf_currency.curr-code = loc-c-fin-doc.curr-code no-error.
    if available buf_currency then return buf_currency.curr-abbr.
  RETURN string(loc-c-fin-doc.curr-code).
END FUNCTION.
FUNCTION get-shift RETURNS DATE
  ( BUFFER buf_c-fin-doc FOR ub.c-fin-doc, OUTPUT p-shift-name-num AS CHARACTER ) :
define variable v-fin-doc-shift-name-num as character no-undo.
define variable v-fin-doc-shift-name as character no-undo .
IF buf_c-fin-doc.shift-date = ? THEN DO:
   RETURN ?.
END.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnam in g#lib-trn3
  (
     input buf_c-fin-doc.obj-type
  ,  input buf_c-fin-doc.obj-code
  ,  input buf_c-fin-doc.shift-date
  ,  input buf_c-fin-doc.shift-num
  , output v-fin-doc-shift-name
  , output v-fin-doc-shift-name-num
  )        no-error .
ASSIGN
p-shift-name-num = v-fin-doc-shift-name-num
 .
RETURN buf_c-fin-doc.shift-date.
END FUNCTION.
