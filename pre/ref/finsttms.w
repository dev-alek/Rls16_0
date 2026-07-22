DEFINE BUFFER find_fin-statement FOR ub.fin-statement.
DEFINE BUFFER X_clients-host FOR ub.clients.
DEFINE NEW SHARED BUFFER X_fin-statement FOR ub.fin-statement.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter bttns  as char   no-undo .
define input parameter p-mode  as char   no-undo .
define input parameter p-host-code          like ub.fin-statement.host-code no-undo .
define input parameter p-status_            like ub.fin-statement.status_ no-undo.
define input parameter p-fins-doc-type      like ub.fin-statement.fins-doc-type no-undo.
define input parameter p-fins-ext-doc-type  like ub.fin-statement.fins-ext-doc-type no-undo.
define input parameter p-start-date         like ub.fin-statement.doc-date no-undo .
define input parameter p-end-date           like ub.fin-statement.doc-date no-undo .
define input parameter p-code-bank          like ub.fin-statement.code-bank no-undo.
define input parameter p-code-schet         like ub.fin-statement.code-schet no-undo.
define input parameter p-curr-code          like ub.fin-statement.curr-code no-undo.
define input-output param p-rid-list    as  char no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список банковских выписок":U.
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
FUNCTION uf-convert-mode returns character(
                                        input p-mode as character):
CASE p-mode:
when 'все':U
or
when "currency":U
or
when "code-schet":U
or
when "code-bank":U
then do:
return p-mode.
end.
when "type":U
or
when "type-date":U
then do:
return (p-mode + chr(4) + p-fins-doc-type).
end.
when "ext-type":U
or
when "ext-type-date":U
then do:
return (p-mode + chr(4) + p-fins-ext-doc-type).
end.
when "type-stat":U
or
when "type-stat-date":U
then do:
  return (p-mode + chr(4) + p-fins-doc-type + p-status_).
end.
when "ext-type-stat":U
or
when "ext-type-stat-start":U
or
when "ext-type-stat-end":U
or
when "ext-type-stat-date":U
then do:
return (p-mode + chr(4) + p-fins-ext-doc-type + p-status_).
end.
when 'фирма':U then do:
return (p-mode + chr(4) + string(p-host-code)).
end.
END CASE.
END FUNCTION.
define variable filter-label as character no-undo init "Список выписок" .
define variable filter-label0 as character no-undo init "Список выписок" .
define variable filter-point as character no-undo init "finsttms" .
define variable filter-point0 as character no-undo init "finsttms" .
define variable sort-column-name as character no-undo .
define variable print-option as character no-undo.
define variable add-option as character no-undo.
define variable client-option as character no-undo.
define variable schet-option as character no-undo.
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
define variable v-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-for-title as character no-undo.
define variable is-type-mode as logical no-undo .
define variable is-fact-mode as logical no-undo .
define variable is-stat-mode as logical no-undo init ?.
define variable is-fin as logical   no-undo .
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
DEFINE BUFFER X_fin-schet FOR ub.fin-schet.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_currency FOR ub.currency.
DEFINE BUFFER X_fin-bank FOR ub.fin-bank.
define buffer X_curr_sysconf for ub.sysconf.
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-fin-statement FOR ub.fin-statement )  FORWARD.
DEFINE MENU MENU-B-add
       MENU-ITEM standard-sttm  LABEL "стандартная"   .
DEFINE MENU MENU-B-print
       MENU-ITEM m_one          LABEL "Один"
       MENU-ITEM m_one-graphics LABEL "Один-графика"
       MENU-ITEM m_list         LABEL "Список"        .
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-attr
     LABEL "&Аттриб."
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-close
     LABEL "&Закрыть"
     SIZE 10 BY 1.
DEFINE BUTTON B-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exp
     LABEL "&Экспорт"
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
DEFINE BUTTON B-open
     LABEL "&Открыть"
     SIZE 10 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-reject
     LABEL "&-Отказ"
     SIZE 10 BY 1.
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON B-schet
     LABEL "&Счет"
     SIZE 10 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sch-bank-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дате банка."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE sch-BIK AS CHARACTER FORMAT "X(9)":U
     LABEL "БИК"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
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
DEFINE VARIABLE sch-prn-doc-code AS CHARACTER FORMAT "X(22)":U
     LABEL "номеру"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-r-schet AS CHARACTER FORMAT "X(35)":U
     LABEL "Расч.счет"
     VIEW-AS FILL-IN
     SIZE 22 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE T-batch AS LOGICAL INITIAL no
     LABEL "Пктн.рж"
     VIEW-AS TOGGLE-BOX
     SIZE 10.5 BY 1 TOOLTIP "Пакетная обработка выбранных выписок" NO-UNDO.
DEFINE NEW SHARED QUERY br-fin-statement FOR
      X_fin-statement SCROLLING.
DEFINE BROWSE br-fin-statement
  QUERY br-fin-statement DISPLAY
      mark-string(recid(X_fin-statement), v-rid-list) FORMAT "X(1)":U
WIDTH 2
X_fin-statement.host-code COLUMN-LABEL "Код!фирмы" FORMAT "99999":U
X_fin-statement.prn-doc-code FORMAT "X(22)":U
X_fin-statement.fins-ext-doc-type COLUMN-LABEL "Расш.тип" FORMAT "X(8)":U
X_fin-statement.code-schet COLUMN-LABEL "Вн.№счета"
X_fin-statement.start-date FORMAT "99/99/9999":U COLUMN-LABEL "С"
X_fin-statement.end-date FORMAT "99/99/9999":U COLUMN-LABEL "По"
X_fin-statement.status_ FORMAT "X(8)":U
X_fin-statement.bank-date COLUMN-LABEL "Дата банка!(пост.из банка)" FORMAT "99/99/9999":U
X_fin-statement.fact-date FORMAT "99/99/9999":U
X_fin-statement.sum-doc FORMAT "->,>>>,>>>,>>>,>>9.99":U
X_fin-statement.cli-name COLUMN-LABEL "Название держателя счета" FORMAT "X(255)":U WIDTH 20
get-currency(buffer X_fin-statement) COLUMN-LABEL "Вал" FORMAT "X(3)":U
X_fin-statement.sttm-code COLUMN-LABEL "Вн.N" FORMAT "999999999":U
X_fin-statement.cl-bank COLUMN-LABEL "Кл-банк" FORMAT "X(8)"
ENABLE
X_fin-statement.prn-doc-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 14.37.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 41
     b-lkp AT ROW 1 COL 51
     B-chg AT ROW 1 COL 61
     B-del AT ROW 1 COL 71
     B-print AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     T-batch AT ROW 2 COL 1
     B-close AT ROW 2 COL 21
     B-open AT ROW 2 COL 31
     B-reject AT ROW 2 COL 41
     B-schet AT ROW 2 COL 51
     B-attr AT ROW 2 COL 61
     B-exp AT ROW 2 COL 71
     br-fin-statement AT ROW 3.03 COL 1.4
     ED-notes AT ROW 17.5 COL 1 NO-LABEL
     sch-prn-doc-code AT ROW 19.57 COL 16 COLON-ALIGNED
     sch-doc-date AT ROW 19.57 COL 38.1 COLON-ALIGNED
     sch-fact-date AT ROW 19.57 COL 62 COLON-ALIGNED
     sch-bank-date AT ROW 19.57 COL 86 COLON-ALIGNED
     sch-r-schet AT ROW 20.8 COL 75.3 COLON-ALIGNED
     sch-curr-code AT ROW 20.93 COL 9 COLON-ALIGNED
     B-curr AT ROW 20.93 COL 15.5
     sch-BIK AT ROW 20.93 COL 27.5 COLON-ALIGNED
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 8.4 BY 1 AT ROW 19.57 COL 1
     SPACE(89.90) SKIP(1.46)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список выписок"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.
ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.
ASSIGN
       br-fin-statement:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.
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
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  if add-option = '':U then do:
    run gbl/pop-up.p ( input self:handle
                      ,input no) no-error.
  end.
  if add-option = '':U then return no-apply.
  run proc-b-add in this-procedure ( input add-option) no-error.
  if error-status:error then do:
    add-option = (if is-type-mode then p-fins-doc-type else  '':U).
    return no-apply.
  end.
  APPLY "ENTRY" to br-fin-statement.
END.
ON CHOOSE OF B-attr IN FRAME Dialog-Frame
DO:
define variable loc-doc-rec as recid no-undo .
  if  available X_fin-statement then do:
    run ref/fd-atti.w (  input parparentproc
                        ,input 'ПРОСМОТР':U
                        ,input X_fin-statement.host-code
                        ,input X_fin-statement.sttm-code
                      ) NO-ERROR.
    apply "entry" to br-fin-statement in frame Dialog-Frame.
  end.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
if not available X_fin-statement then return no-apply.
run proc-b-chg-lookup in this-procedure ( input 'ИЗМЕНЕНИЕ':U) no-error.
if error-status:error then do:
  return no-apply.
end.
END.
ON CHOOSE OF B-close IN FRAME Dialog-Frame
DO:
  if not available X_fin-statement then return no-apply.
  run proc-close-open in this-procedure ( input '<закрытие документа>':U
                                        , input t-batch) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-curr IN FRAME Dialog-Frame
DO:
define variable rr as recid no-undo.
define buffer buf_currency for ub.currency.
    rr = ? .
    run ref/currency.w (
                        input parparentproc
                       ,input "b-sel"
                       ,input-output rr ).
    if rr <> ? then do:
      FIND FIRST buf_currency WHERE
            recid( buf_currency ) = rr NO-LOCK .
      DISPLAY
      buf_currency.curr-code @ sch-curr-code
      with frame Dialog-Frame .
    end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  run proc-b-del in this-procedure ( input t-batch) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-exp IN FRAME Dialog-Frame
DO:
  RUN proc-b-exp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if available X_fin-statement then do:
      loc-doc-rec = recid (X_fin-statement).
    .
    run ref/fincstts.w
                  (
                   input parParentProc
                  ,input p-curr-host-code
                  ,input "":U
                  ,input "one":U
                  ,input X_fin-statement.host-code
                  ,input X_fin-statement.sttm-code
                  ,input X_fin-statement.code-schet
                  ,input-output v-rid-list
                                )
    .
    reposition br-fin-statement to recid loc-doc-rec no-error.
    apply "entry" to br-fin-statement in frame Dialog-Frame.
    apply "value-changed" to br-fin-statement in frame Dialog-Frame.
  end.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
if not available X_fin-statement then return no-apply.
run proc-b-chg-lookup in this-procedure ( input 'ПРОСМОТР':U) no-error.
if error-status:error then do:
  return no-apply.
end.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
  if available X_fin-statement then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid11 as character no-undo .
define variable v-num-entry11 as integer   no-undo .
assign
  v-str-recid11 = trim( string( recid( X_fin-statement ) , "->>>>>>>>>>>9":U ) )
  v-num-entry11 = lookup( v-str-recid11 , v-rid-list )
.
if v-num-entry11 > 0 then do:
  assign
    entry( v-num-entry11, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid11
  .
end.
    loc#log = br-fin-statement:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-fin-statement:select-next-row ().
        apply "VALUE-CHANGED" to br-fin-statement in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-fin-statement in frame Dialog-Frame.
END.
ON CHOOSE OF B-open IN FRAME Dialog-Frame
DO:
  if not available X_fin-statement then return no-apply.
  run proc-close-open in this-procedure ( '<открытие документа>':U, input t-batch ) no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  if not avail X_fin-statement then return no-apply.
  if print-option = '':U then do:
     run gbl/pop-up.p ( input self:handle
                       ,input no) no-error.
  end.
  if print-option = '':U then return no-apply.
  run proc-b-print in this-procedure ( input print-option) no-error.
  if error-status:error then do:
    print-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-fin-statement.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
    assign
    v-uf-List_ = string(recid(X_fin-statement))
    .
    run uf-set in this-procedure (
       input  ('finsttms-p':U + chr(4) + uf-convert-mode(p-mode))
      ,input  g#userid
      ,input v-uf-List_
      ,input v-uf-Naim
      ,input v-uf-print-graft
      ,input v-uf-sort-gr
      ,input v-uf-type-price
      ,input v-uf-type-val
  )  no-error .
END.
ON CHOOSE OF B-reject IN FRAME Dialog-Frame
DO:
  if not available X_fin-statement then return no-apply.
  run proc-close-open in this-procedure ( input '<отказ от документа>':U
                                        , input t-batch) no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-schet IN FRAME Dialog-Frame
DO:
define variable loc-doc-rec as recid no-undo.
if not available X_fin-statement then return no-apply.
run ref/finschti.w
              (
                 input parParentProc
                ,input p-curr-host-code
                ,input 'ПРОСМОТР':U
                ,input X_fin-statement.host-code
                ,input X_fin-statement.code-schet
                ,input X_fin-statement.code-bank
                ,input 'орг':U
                ,input X_fin-statement.host-code
                ,input X_fin-statement.curr-code
                ,input-output loc-doc-rec
                            )
.
 schet-option = '':U.
 APPLY "ENTRY" to br-fin-statement.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if ( available X_fin-statement ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_fin-statement ) ) .
  end.
END.
ON RETURN OF br-fin-statement IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-fin-statement IN FRAME Dialog-Frame
DO:
  run proc-br-fin-statement no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF br-fin-statement IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE dops as character no-undo .
  dops = if available X_fin-statement then X_fin-statement.ps else '':U.
  ED-notes:screen-value = dops.
END.
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
  define buffer ps_fin-statement for ub.fin-statement.
  if not available X_fin-statement then return no-apply.
   DO on stop undo, return no-apply:
      FIND PS_fin-statement where
           recid (ps_fin-statement) = recid(X_fin-statement) exclusive.
      if ps_fin-statement.PS <> input frame Dialog-Frame ed-notes then
      assign
      ps_fin-statement.PS = input frame Dialog-Frame ed-notes
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
ON CHOOSE OF MENU-ITEM m_one-graphics
DO:
   assign
  print-option = 'ONE-GRAPHICS':U.
  APPLY "CHOOSE" to b-print  in frame Dialog-Frame.
END.
ON CTRL-J OF sch-bank-date IN FRAME Dialog-Frame
DO:
  run proc-find-date in this-procedure ( input no
                                       , input frame Dialog-Frame sch-bank-date
                                       , input "bank-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-bank-date IN FRAME Dialog-Frame
DO:
  run proc-find-date in this-procedure ( input yes
                                       , input frame Dialog-Frame sch-bank-date
                                       , input "bank-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-BIK IN FRAME Dialog-Frame
DO:
  run proc-find-bik in this-procedure (  input yes
                                       , input frame Dialog-Frame sch-bik) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-BIK IN FRAME Dialog-Frame
DO:
  run proc-find-bik in this-procedure ( input no
                                      , input frame Dialog-Frame sch-bik) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-curr-code IN FRAME Dialog-Frame
DO:
  run proc-find-curr-code in this-procedure ( input yes
                                            , input frame Dialog-Frame sch-curr-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-curr-code IN FRAME Dialog-Frame
DO:
   run proc-find-curr-code in this-procedure ( input no
                                             , input frame Dialog-Frame sch-curr-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-doc-date IN FRAME Dialog-Frame
DO:
   run proc-find-date in this-procedure ( input yes
                                        , input frame Dialog-Frame sch-doc-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-doc-date IN FRAME Dialog-Frame
DO:
  run proc-find-date in this-procedure ( input no
                                       , input frame Dialog-Frame sch-doc-date
                                       , input "doc-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-fact-date IN FRAME Dialog-Frame
DO:
  run proc-find-date in this-procedure ( input yes
                                       , input frame Dialog-Frame sch-fact-date
                                       , input "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-fact-date IN FRAME Dialog-Frame
DO:
   run proc-find-date in this-procedure ( input no
                                        , input frame Dialog-Frame sch-fact-date
                                        , input "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-prn-doc-code IN FRAME Dialog-Frame
DO:
  run proc-find-prn-doc-code in this-procedure ( input yes
                                               , input frame Dialog-Frame sch-prn-doc-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-prn-doc-code IN FRAME Dialog-Frame
DO:
  run proc-find-prn-doc-code in this-procedure ( input no
                                               , input frame Dialog-Frame sch-prn-doc-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-r-schet IN FRAME Dialog-Frame
DO:
  run proc-find-r-schet in this-procedure ( input yes
                                          , input frame Dialog-Frame sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-r-schet IN FRAME Dialog-Frame
DO:
  run proc-find-r-schet in this-procedure ( input no
                                          , input frame Dialog-Frame sch-r-schet) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM standard-sttm
DO:
    assign
   add-option = 'стд':U.
   APPLY "CHOOSE" to b-add  in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF T-batch IN FRAME Dialog-Frame
DO:
define variable GLOG as logical no-undo .
  assign
  t-batch.
  run proc-buttons in this-procedure ( input t-batch).
  if t-batch = no
  and b-mark:sensitive = no then do:
    assign
    v-rid-list = "":U.
    if avail X_fin-statement then
    GLOG = br-fin-statement:refresh().
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
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
        v-diasize-browse-handle     = browse br-fin-statement :handle
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
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var sort-labelbr-fin-statement   as character no-undo .
def var sort-clmnbr-fin-statement    as handle    no-undo .
def var cur-clmnbr-fin-statement     as handle    no-undo .
def var cur-clmn-locbr-fin-statement as integer   no-undo .
def var re-querybr-fin-statement     as logical   initial no no-undo .
on start-search, ctrl-o of br-fin-statement in frame Dialog-Frame do:
   run sort-brbr-fin-statement
     (input (if available X_fin-statement
             then recid(X_fin-statement)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-fin-statement :
  define input parameter p-recid as recid no-undo .
  if re-querybr-fin-statement = no then do:
    assign
       cur-clmnbr-fin-statement = br-fin-statement:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-fin-statement <> ? then sort-clmnbr-fin-statement:column-fgcolor = 0.
    if cur-clmnbr-fin-statement = sort-clmnbr-fin-statement then do:
      assign
         sort-labelbr-fin-statement = ""
         sort-clmnbr-fin-statement = ?
      .
     end.
     else do:
       assign
         sort-labelbr-fin-statement = cur-clmnbr-fin-statement:label
         sort-clmnbr-fin-statement  = cur-clmnbr-fin-statement
         sort-clmnbr-fin-statement:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-fin-statement = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-fin-statement:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-fin-statement then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-fin-statement = cur-clmn-locbr-fin-statement + 1
    .
  end.
  case sort-labelbr-fin-statement:
        when X_fin-statement.prn-doc-code:label in browse br-fin-statement then DO:   assign     sort-column-name = "X_fin-statement.prn-doc-code"   .   run OpenBr in this-procedure ( input yes, input no, input no).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure (  input yes, input no, input no).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-fin-statement') then do:
          run mv-brw-defaultbr-fin-statement.
        end.
      if sort-labelbr-fin-statement <> "" then do:
        assign
          cur-clmnbr-fin-statement:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-fin-statement = ?
      .
    end.
  end case.
    if cur-clmn-locbr-fin-statement <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-fin-statement') then do:
        run ch-clmnbr-fin-statement in this-procedure (cur-clmn-locbr-fin-statement).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-fin-statement to recid p-recid no-error.
    apply "value-changed" to br-fin-statement in frame Dialog-Frame.
  end.
  apply "entry" to br-fin-statement in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-fin-statement:
if cur-clmnbr-fin-statement = ? then do:
   run OpenBr in this-procedure (  input yes, input no, input no).
end.
else do:
   assign re-querybr-fin-statement = yes.
   run sort-brbr-fin-statement
     (input (if available X_fin-statement
             then recid(X_fin-statement)
             else ?
            )
     ).
   assign re-querybr-fin-statement = no.
end.
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-fin-statement :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  v-doc-rec = recid(X_fin-statement). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-fin-statement to recid v-doc-rec no-error. v-doc-rec = ?.
    apply "VALUE-CHANGED" to br-fin-statement.
end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date27
    MENU-ITEM m-ed-date27-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date27-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date27-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date27-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-doc-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-doc-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date27 :HANDLE
      sch-doc-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle27 as handle no-undo .
  assign
    v-label-handle27 = sch-doc-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle27)
  then do:
    if v-label-handle27 :tooltip = ""
    or v-label-handle27 :tooltip = ?
    then do:
      assign
        v-label-handle27 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date27-1 in menu m-ed-date27 DO:
    apply "ctrl-b":U to sch-doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date27-2 in menu m-ed-date27 DO:
    apply "ctrl-d":U to sch-doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date27-3 in menu m-ed-date27 DO:
    apply "ctrl-e":U to sch-doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date27-4 in menu m-ed-date27 DO:
    apply "ctrl-f":U to sch-doc-date in frame Dialog-Frame .
  END.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-bank-date in frame Dialog-Frame
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
on delete-character of sch-bank-date in frame Dialog-Frame
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
on ctrl-d of sch-bank-date in frame Dialog-Frame
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
on ctrl-b of sch-bank-date in frame Dialog-Frame
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
on ctrl-e of sch-bank-date in frame Dialog-Frame
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
on ctrl-f of sch-bank-date in frame Dialog-Frame
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
  define MENU m-ed-date29
    MENU-ITEM m-ed-date29-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date29-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date29-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date29-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-bank-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-bank-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date29 :HANDLE
      sch-bank-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle29 as handle no-undo .
  assign
    v-label-handle29 = sch-bank-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle29)
  then do:
    if v-label-handle29 :tooltip = ""
    or v-label-handle29 :tooltip = ?
    then do:
      assign
        v-label-handle29 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date29-1 in menu m-ed-date29 DO:
    apply "ctrl-b":U to sch-bank-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date29-2 in menu m-ed-date29 DO:
    apply "ctrl-d":U to sch-bank-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date29-3 in menu m-ed-date29 DO:
    apply "ctrl-e":U to sch-bank-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date29-4 in menu m-ed-date29 DO:
    apply "ctrl-f":U to sch-bank-date in frame Dialog-Frame .
  END.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date31
    MENU-ITEM m-ed-date31-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date31-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date31-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date31-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-fact-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-fact-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date31 :HANDLE
      sch-fact-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle31 as handle no-undo .
  assign
    v-label-handle31 = sch-fact-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle31)
  then do:
    if v-label-handle31 :tooltip = ""
    or v-label-handle31 :tooltip = ?
    then do:
      assign
        v-label-handle31 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date31-1 in menu m-ed-date31 DO:
    apply "ctrl-b":U to sch-fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date31-2 in menu m-ed-date31 DO:
    apply "ctrl-d":U to sch-fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date31-3 in menu m-ed-date31 DO:
    apply "ctrl-e":U to sch-fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date31-4 in menu m-ed-date31 DO:
    apply "ctrl-f":U to sch-fact-date in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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
  v-rid-list = p-rid-list.
  run Mainproc in this-procedure no-error .
  if error-status:error then return error .
  RUN MyEnable in this-procedure .
  RUn OpenBR  in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame Dialog-Frame .
  if v-doc-rec <> ? then
  REPOSITION br-fin-statement to recid v-doc-rec No-ERROR.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-fin-statement as INT EXTENT 16 no-undo.
DEF VAR varmvibr-fin-statement       as INT no-undo.
DEF VAR varmvjbr-fin-statement       as INT no-undo.
DEF VAR varmvkbr-fin-statement       as INT no-undo.
DEF VAR varmvlbr-fin-statement       as INT no-undo.
DEF VAR move-elementbr-fin-statement as INT no-undo.
def var jjbr-fin-statement           as int no-undo.
do varmvibr-fin-statement = 1 to EXTENT(cur-clmn-numbr-fin-statement):
  ASSIGN cur-clmn-numbr-fin-statement[varmvibr-fin-statement] = varmvibr-fin-statement.
END.
RUN start-mv-clmnbr-fin-statement.
PROCEDURE start-mv-clmnbr-fin-statement:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  p-mode = 'все':U  THEN DO:
   DO jjbr-fin-statement = NUM-ENTRIES('1,2,3,5,6,7,8,9,10,11,12,13,14,15,4') TO 1 BY -1:
     RUN re-move-clmnbr-fin-statement ( cur-clmn-numbr-fin-statement[INTEGER(ENTRY (jjbr-fin-statement, '1,2,3,5,6,7,8,9,10,11,12,13,14,15,4'))] , 1).
   END.
       END.
       IF  p-mode = 'фирма':U  THEN DO:
   DO jjbr-fin-statement = NUM-ENTRIES('1,3,5,6,7,8,9,10,11,12,13,2,14,15,4') TO 1 BY -1:
     RUN re-move-clmnbr-fin-statement ( cur-clmn-numbr-fin-statement[INTEGER(ENTRY (jjbr-fin-statement, '1,3,5,6,7,8,9,10,11,12,13,2,14,15,4'))] , 1).
   END.
       END.
       IF  is-type-mode = yes  THEN DO:
   DO jjbr-fin-statement = NUM-ENTRIES('1,3,5,6,7,8,9,10,11,12,13,2,14,15,4') TO 1 BY -1:
     RUN re-move-clmnbr-fin-statement ( cur-clmn-numbr-fin-statement[INTEGER(ENTRY (jjbr-fin-statement, '1,3,5,6,7,8,9,10,11,12,13,2,14,15,4'))] , 1).
   END.
       END.
       IF  p-mode = 'code-schet'  THEN DO:
   DO jjbr-fin-statement = NUM-ENTRIES('1,3,5,6,7,8,9,10,11,12,13,2,14,15,4') TO 1 BY -1:
     RUN re-move-clmnbr-fin-statement ( cur-clmn-numbr-fin-statement[INTEGER(ENTRY (jjbr-fin-statement, '1,3,5,6,7,8,9,10,11,12,13,2,14,15,4'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-fin-statement do:
  RUN re-move-clmnbr-fin-statement ( 1, 16).
END.
ON ctrl-cursor-left OF BROWSE br-fin-statement do:
  RUN re-move-clmnbr-fin-statement (16, 1).
END.
PROCEDURE re-move-clmnbr-fin-statement:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-fin-statement = 1 TO EXTENT(cur-clmn-numbr-fin-statement):
    if cur-clmn-numbr-fin-statement[varmvibr-fin-statement] = source-column THEN cur-clmn-numbr-fin-statement[varmvibr-fin-statement] = -1.
  END.
  if br-fin-statement:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-fin-statement = source-column - 1 to target-column BY -1:
    DO varmvibr-fin-statement = 1 TO EXTENT(cur-clmn-numbr-fin-statement):
        if cur-clmn-numbr-fin-statement[varmvibr-fin-statement] = varmvjbr-fin-statement THEN DO:
          cur-clmn-numbr-fin-statement[varmvibr-fin-statement] = cur-clmn-numbr-fin-statement[varmvibr-fin-statement] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-fin-statement = source-column + 1 to target-column:
    DO varmvibr-fin-statement = 1 TO EXTENT(cur-clmn-numbr-fin-statement):
      if cur-clmn-numbr-fin-statement[varmvibr-fin-statement] = varmvjbr-fin-statement THEN DO:
        cur-clmn-numbr-fin-statement[varmvibr-fin-statement] = cur-clmn-numbr-fin-statement[varmvibr-fin-statement] - 1.
      END.
    END.
  END.
  DO varmvibr-fin-statement = 1 TO EXTENT(cur-clmn-numbr-fin-statement):
    if cur-clmn-numbr-fin-statement[varmvibr-fin-statement] = -1 THEN cur-clmn-numbr-fin-statement[varmvibr-fin-statement] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-fin-statement:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-fin-statement = 1 TO EXTENT(cur-clmn-numbr-fin-statement):
    if cur-clmn-numbr-fin-statement[varmvibr-fin-statement] = cur-clmn-loc THEN move-elementbr-fin-statement = varmvibr-fin-statement.
  END.
  RUN re-move-clmnbr-fin-statement (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-fin-statement:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-fin-statement = 1 to EXTENT(cur-clmn-numbr-fin-statement):
    RUN re-move-clmnbr-fin-statement (cur-clmn-numbr-fin-statement[varmvlbr-fin-statement], varmvlbr-fin-statement).
  END.
  RUN start-mv-clmnbr-fin-statement.
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
  DISPLAY T-batch ED-notes sch-prn-doc-code sch-doc-date sch-fact-date
          sch-bank-date sch-r-schet sch-curr-code sch-BIK mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-add b-lkp B-chg B-del B-print B-hist B-sch
         B-Help T-batch B-close B-open B-reject B-schet B-attr B-exp
         br-fin-statement ED-notes sch-prn-doc-code sch-doc-date sch-fact-date
         sch-bank-date sch-r-schet sch-curr-code B-curr sch-BIK mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MainProc :
  find first X_curr_sysconf no-lock where
                  X_curr_sysconf.host-code = p-curr-host-code no-error.
  if not available X_curr_sysconf then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-host-code"
    p-curr-host-code
    view-as alert-box ERROR.
    return error .
  end.
if LOOKUP(p-mode, ('все':U + chr(4) +
                  'фирма':U + chr(4) +
                "fins-doc-type":U + chr(4) +
                "status_":U + chr(4) +
                "code-bank":U + chr(4) +
                "code-schet":U + chr(4) +
                "currency":U + chr(4) +
                "type":U + chr(4) +
                "type-stat":U + chr(4) +
                "type-stat-date":U + chr(4) +
                "type-date":U + chr(4) +
                "ext-type":U + chr(4) +
                "ext-type-stat":U + chr(4) +
                "ext-type-stat-start":U + chr(4) +
                "ext-type-stat-end":U + chr(4) +
                "ext-type-stat-date":U + chr(4) +
                "ext-type-date":U + chr(4) +
                "trn-doc":U),
                chr(4)) = 0
    then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
end.
run uf-get in this-procedure(
    input  ('finsttms-p':U + chr(4) + uf-convert-mode(p-mode))
    ,input  g#userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if not error-status:error
and num-entries(v-uf-List_, chr(4)) = 2 then do:
  assign
  v-doc-rec = (if v-rid-list = "":U
              then integer(entry(2, v-uf-List_, chr(4)))
              else integer(entry(2, v-uf-List_, v-rid-list)) )
  .
end.
if lOOKUP(p-mode,
                (
                "type":U + chr(4) +
                "type-stat":U + chr(4) +
                "type-stat-date":U + chr(4) +
                "type-date":U), chr(4) ) > 0 then do:
  assign
  is-type-mode = yes
  .
  if LOOKUP(p-fins-doc-type , 'стд':U) = 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-fins-doc-type"
    p-fins-doc-type
    view-as alert-box ERROR.
    return error .
  end.
end.
if lOOKUP(p-mode,
                (
                "type-stat":U + chr(4) +
                "type-stat-date":U + chr(4) +
                "ext-type-stat":U + chr(4) +
                "ext-type-stat-date":U
                ), chr(4) ) > 0 then do:
  assign
  is-stat-mode = yes
  .
  if p-status_ = 'факт':U then do:
    assign
    is-fact-mode = yes
    .
  end.
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
    return error .
end.
if lookup(p-mode,
                ("type-stat":U + chr(4) +
                "type-stat-date":U + chr(4) +
                "ext-type-stat":U + chr(4) +
                "ext-type-stat-start":U + chr(4) +
                "ext-type-stat-end":U + chr(4) +
                "ext-type-stat-date":U + chr(4)), chr(4) ) > 0
AND
lookup(p-status_, 'новый,разрешен,банк,факт,отказ':U) = 0 then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра вызова p-status_"
  p-status_
  view-as alert-box ERROR.
  return error .
end.
if lookup(p-mode,
                ("type":U + chr(4) +
                "type-stat":U + chr(4) +
                "type-stat-date":U + chr(4) +
                "type-date":U + chr(4) +
                "ext-type":U + chr(4) +
                "ext-type-stat":U + chr(4) +
                "ext-type-stat-start":U + chr(4) +
                "ext-type-stat-end":U + chr(4) +
                "ext-type-stat-date":U + chr(4) +
                "ext-type-date":U + chr(4)
                ), chr(4) ) > 0 then do:
  if lookup( p-fins-ext-doc-type , 'стд':U) = 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-fins-ext-doc-type"
    p-fins-ext-doc-type
    view-as alert-box ERROR.
    return error .
  end.
end.
  if LOOKUP(p-mode, (
                'фирма':U + chr(4) +
                "currency":U + chr(4) +
                "type":U + chr(4) +
                "type-stat":U + chr(4) +
                "type-stat-date":U + chr(4) +
                "type-date":U + chr(4) +
                "ext-type":U + chr(4) +
                "ext-type-stat":U + chr(4) +
                "ext-type-stat-start":U + chr(4) +
                "ext-type-stat-end":U + chr(4) +
                "ext-type-stat-date":U + chr(4) +
                "ext-type-date":U + chr(4) +
                "code-schet":U + chr(4) +
                "code-bank":U ),
                chr(4)) > 0 then do:
    find first X_sysconf no-lock where
                    X_sysconf.host-code = p-host-code no-error.
    if not available X_sysconf then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-host-code"
      p-host-code
      view-as alert-box ERROR.
      return error .
    end.
  end.
  if lookup(p-mode
          , "code-schet":U
          , chr(4)) > 0 then do:
    find first X_fin-schet no-lock where
              X_fin-schet.host-code = p-curr-host-code
          AND  X_fin-schet.code-schet = p-code-schet no-error.
    if not available X_fin-schet then do:
      message
      substitute("Не задан счет для просмотра выписок (вн. код счета &1)", p-code-schet)
      view-as alert-box ERROR.
      return error .
    end.
    p-code-bank = X_fin-schet.code-bank.
  end.
  if lookup(p-mode
          , "code-bank":U + chr(4) + "code-schet"
          , chr(4)) > 0 then do:
    find first X_fin-bank no-lock where
              X_fin-bank.host-code = p-curr-host-code
          AND  X_fin-bank.code-bank = p-code-bank  no-error.
    if not available X_fin-bank then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-code-bank"
        p-code-bank
        view-as alert-box ERROR.
        return error .
    end.
  end.
  if lookup(p-mode
          , "currency":U
          , chr(4)) > 0 then do:
    find first X_currency no-lock where
              X_currency.curr-code = p-curr-code no-error.
    if not available X_currency then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-curr-code"
        p-curr-code
        view-as alert-box ERROR.
        return error .
    end.
  end.
  if v-rid-list <> "" then do:
      FIND FIRST find_fin-statement No-LOCK where
                recid(find_fin-statement) = integer(entry(1, v-rid-list)) No-ERROR.
      if not avail find_fin-statement then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова v-rid-list" v-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, v-rid-list)).
    end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
END PROCEDURE.
PROCEDURE MyEnable :
define variable is-finvalue as character no-undo .
define variable is-fintype as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output is-finvalue
  ,output is-fintype
  ) no-error .
is-fin = logical(is-finvalue).
assign
b-print:MENU-MOUSE in frame Dialog-Frame = 1
b-add:MENU-MOUSE in frame Dialog-Frame = 1
b-schet:MENU-MOUSE in frame Dialog-Frame = 1
br-fin-statement:num-locked-columns = 1
X_fin-statement.prn-doc-code:read-only in browse br-fin-statement = yes
B-add:POPUP-MENU = (if is-type-mode then ? else B-add:POPUP-MENU)
add-option = p-fins-doc-type
X_fin-statement.cli-name:RESIZABLE IN BROWSE br-fin-statement = YES
.
if
LOOKUP(p-mode, ("type":U + chr(4) +
              "type-stat":U + chr(4) +
              "type-stat-date":U + chr(4) +
              "type-date":U), chr(4)) > 0 then do:
CASE p-fins-doc-type:
    when '':U then do:
        assign
        menu-item standard-sttm:sensitive in menu menu-b-add = yes
        .
    end.
END CASE.
end.
DISPLAY
ED-notes
sch-prn-doc-code
sch-curr-code
sch-doc-date
sch-fact-date
sch-bank-date
sch-r-schet
sch-BIK
mark-num
WITH FRAME Dialog-Frame.
run proc-buttons in this-procedure ( input no).
ENABLE
b-quit
b-lkp
b-sel when lookup("b-sel":U, bttns) > 0
B-del when (p-curr-host-code = p-host-code  AND available X_sysconf AND X_sysconf.firm-db-num = v-db-num and is-fin)
B-add when (p-curr-host-code = p-host-code  AND available X_sysconf AND X_sysconf.firm-db-num = v-db-num and is-fin)
b-chg when (p-curr-host-code = p-host-code  AND available X_sysconf AND X_sysconf.firm-db-num = v-db-num and is-fin)
B-sch
B-print
b-exp
B-schet
B-Help
b-hist
b-attr
br-fin-statement
b-curr
T-batch when (
            (p-curr-host-code = p-host-code  AND available X_sysconf AND X_sysconf.firm-db-num = v-db-num)
          )
ED-notes
sch-prn-doc-code
sch-curr-code
sch-doc-date
sch-fact-date
sch-bank-date
sch-r-schet
sch-BIK
mark-num
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable title0 as character no-undo.
define variable v-filter-name as character no-undo .
title0 = "Список выписок" + chr(32).
filter-point = filter-point0 + p-mode.
if lookup(p-mode,
(
'все':U               + chr(4) +
'фирма':U           + chr(4) +
"code-schet"         + chr(4) +
"code-bank"          + chr(4) +
"currency":U
), chr(4)) > 0 then do:
  run ref/finscsq1.p ( input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input p-curr-host-code ,  input p-mode ,  input p-host-code ,  input p-status_    ,  input p-fins-doc-type ,  input p-fins-ext-doc-type ,  input p-start-date ,  input p-end-date    ,  input p-code-bank  ,  input p-code-schet  ,  input p-curr-code  ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
end.
if lookup(p-mode,
("type":U               + chr(4) +
"type-stat":U           + chr(4) +
"type-stat-date":U       + chr(4) +
"type-date":U
  ) , chr(4)) > 0 then do:
  run ref/finscsq2.p (  input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input p-curr-host-code ,  input p-mode ,  input p-host-code ,  input p-status_    ,  input p-fins-doc-type ,  input p-fins-ext-doc-type ,  input p-start-date ,  input p-end-date    ,  input p-code-bank  ,  input p-code-schet  ,  input p-curr-code  ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
end.
if lookup(p-mode,
("ext-type":U             + chr(4) +
"ext-type-stat":U        + chr(4) +
"ext-type-stat-date":U   + chr(4) +
"ext-type-date":U        + chr(4) +
"ext-type-stat-start"    + chr(4) +
"ext-type-stat-end"
  ) , chr(4)) > 0 then do:
  run ref/finscsq3.p ( input  p-open-query , input  p-find-next ,  input  p-find-condition ,  INPUT parParentProc ,  input p-curr-host-code ,  input p-mode ,  input p-host-code ,  input p-status_    ,  input p-fins-doc-type ,  input p-fins-ext-doc-type ,  input p-start-date ,  input p-end-date    ,  input p-code-bank  ,  input p-code-schet  ,  input p-curr-code  ,  input-output v-rid-list ,  input filter-point  ,  input filter-point0 ,  input sort-column-name ,  output v-filter-name ,  input-output v-doc-rec ) .
end.
if p-open-query then do:
  CASE p-mode :
    WHEN 'фирма':U THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2", p-host-code, X_clients-host.obj-name).
    END.
    WHEN "currency":U THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3",
                                    p-host-code, X_clients-host.obj-name, X_currency.curr-abbr).
    END.
    WHEN "code-schet":U THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 Банк &3 Р/c Получателя &4"
                                              ,p-host-code
                                              , X_clients-host.obj-name
                                              , X_fin-bank.short-name
                                              , X_fin-schet.r-schet).
    END.
    WHEN "code-bank":U THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 Банк &3"
                                              ,p-host-code
                                              , X_clients-host.obj-name
                                              , X_fin-bank.short-name
                                              ).
    END.
    WHEN 'type' THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3",
                                    p-host-code, X_clients-host.obj-name, entry (lookup (p-fins-doc-type, 'стд':U), 'стандартная выписка':U)).
    END.
    WHEN 'type-stat' THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4",
                                    p-host-code, X_clients-host.obj-name, entry (lookup (p-fins-doc-type, 'стд':U), 'стандартная выписка':U), p-status_).
    END.
    WHEN 'type-stat-date' THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4 &5-&6",
                                    p-host-code, X_clients-host.obj-name, entry (lookup (p-fins-doc-type, 'стд':U), 'стандартная выписка':U), p-status_,
                                    p-start-date, "99/99/9999",
                                    p-end-date, "99/99/9999").
    END.
    WHEN 'type-date' THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &5-&6",
                                    p-host-code, X_clients-host.obj-name, entry (lookup (p-fins-doc-type, 'стд':U), 'стандартная выписка':U),
                                    p-start-date, "99/99/9999",
                                    p-end-date, "99/99/9999").
    END.
    WHEN 'ext-type' THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3",
                                    p-host-code, X_clients-host.obj-name, p-fins-ext-doc-type).
    END.
    WHEN 'ext-type-stat'
    or
    when 'ext-type-stat-start'
    or
    when 'ext-type-stat-end'
    THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4",
                                    p-host-code, X_clients-host.obj-name, p-fins-ext-doc-type, p-status_).
    END.
    WHEN 'ext-type-stat-date' THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &4 &5-&6",
                                    p-host-code, X_clients-host.obj-name, p-fins-ext-doc-type, p-status_,
                                    p-start-date, "99/99/9999",
                                    p-end-date, "99/99/9999").
    END.
    WHEN 'ext-type-date' THEN DO:
        ASSIGN
        frame Dialog-Frame:TITLE = title0 +
                                    substitute(" Фирма: (&1) &2 &3 &5-&6",
                                    p-host-code, X_clients-host.obj-name, p-fins-ext-doc-type,
                                    p-start-date, "99/99/9999",
                                    p-end-date, "99/99/9999").
    END.
  END CASE.
  ASSIGN frame Dialog-Frame:TITLE =
  frame Dialog-Frame:TITLE + chr(32) + v-for-title.
  run set-filter-name in this-procedure ( INPUT v-filter-name) no-error .
end.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-fin-statement to recid v-doc-rec No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-fin-statement in frame Dialog-Frame.
APPLY "ENTRY" TO br-fin-statement.
END PROCEDURE.
PROCEDURE proc-b-add :
define input parameter p-option as character no-undo.
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable v-code-schet like ub.fin-statement.code-schet no-undo.
define variable v-code-bank  like ub.fin-statement.code-bank no-undo.
define variable v-mode as character no-undo.
define variable vlog as logical no-undo .
define variable choice as integer no-undo .
define variable v-rid-list as character no-undo .
define variable loc-line-rec as recid no-undo .
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-statement_add-def':U
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
v-mode = 'ДОБАВЛЕНИЕ':U
.
CASE p-mode :
  WHEN 'фирма':U THEN DO:
    assign
    v-code-schet = 0
    v-code-bank = 0
    .
  END.
  WHEN "currency":U THEN DO:
    assign
    v-code-schet = 0
    v-code-bank = 0
    .
  END.
  WHEN "code-schet":U THEN DO:
    assign
    v-code-schet = p-code-schet
    v-code-bank = p-code-bank
    .
  END.
  WHEN "code-bank":U THEN DO:
    assign
    v-code-schet = 0
    v-code-bank  = p-code-bank
    .
  END.
END CASE.
CASE p-option:
    when ''
    or
    when
    'стд':U
    then do:
            run ref/finstti1.w
                      (
                        input parParentProc
                        ,input p-curr-host-code
                        ,input v-mode
                        ,input p-host-code
                        ,input 0
                        ,input "":U
                        ,input v-code-bank
                        ,input v-code-schet
                        ,input "":U
                        ,input-output loc-doc-rec
                        ,input-output loc-line-rec
                                    ) no-error
        .
    end.
END CASE.
if loc-doc-rec <> ? then do:
    RUn OpenBR in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-statement to recid loc-doc-rec no-error.
end.
apply "entry" to br-fin-statement in frame Dialog-Frame.
apply "value-changed" to br-fin-statement in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-chg-lookup :
define input parameter p-change-mode as character no-undo.
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable loc-line-rec as recid no-undo .
if p-change-mode = 'ИЗМЕНЕНИЕ':U then do:
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-statement_update':U
    ,input  'firm':U
    ,input  X_fin-statement.host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
end.
else do:
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-statement_lookup':U
    ,input  'firm':U
    ,input  X_fin-statement.host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
end.
if not loc#log then return error.
assign
loc-doc-rec = recid(X_fin-statement).
CASE X_fin-statement.fins-ext-doc-type:
  when '':U
  or when 'стд':U
  then do:
    run ref/finstti1.w
                  (
                        input parParentProc
                        ,input p-curr-host-code
                        ,input p-change-mode
                        ,input X_fin-statement.host-code
                        ,input 0
                        ,input "":U
                        ,input X_fin-statement.code-bank
                        ,input X_fin-statement.code-schet
                        ,input "":U
                        ,input-output loc-doc-rec
                        ,input-output loc-line-rec
                   )
    .
  end.
END CASE.
if loc-doc-rec <> ? and p-change-mode = 'ИЗМЕНЕНИЕ':U then do:
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  reposition br-fin-statement to recid loc-doc-rec no-error.
end.
apply "entry" to br-fin-statement in frame Dialog-Frame.
apply "value-changed" to br-fin-statement in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-del :
define input parameter p-is-batch as logical no-undo .
define variable loc#log as logical no-undo.
define variable ii as integer no-undo .
define variable ok-ii as integer no-undo .
define variable v-new-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo.
define buffer buf_fin-statement for ub.fin-statement.
if not available X_fin-statement then return error.
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-statement_deletion':U
    ,input  'firm':U
    ,input  X_fin-statement.host-code
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
CASE p-is-batch:
  when no then do:
      find first buf_fin-statement exclusive-lock where
      recid(buf_fin-statement) = recid(X_fin-statement) NO-ERROR.
      if not avail buf_fin-statement then return no-apply.
      IF buf_fin-statement.status_ <> 'новый':U
      and buf_fin-statement.status_ <> 'факт':U
      THEN DO:
        MESSAGE
        "Выписка закрыта - удалять нельзя!"
        VIEW-AS ALERT-BOX ERROR.
        RETURN error.
      END.
      loc#log = no.
      MESSAGE
      "Вы уверены, что хотите удалить выписку?" skip(0)
      string(if buf_fin-statement.status_ = 'факт':U then "Выписка закрыта до статуса <факт>, удаление повлечет за собой перерасчет архивов" else "")
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE loc#log.
      IF loc#log <> YES THEN DO:
        RETURN error.
      END.
    do
    on error undo, return error
    on stop undo, return error
    :
      if buf_fin-statement.status_ = 'факт':U then do:
        run trg/finsttdl.p (
                        input buf_fin-statement.host-code
                       ,input buf_fin-statement.sttm-code
                       ,input yes
                       ,input no) no-error.
        if error-status:error then do:
          message
          "Ошибка при удалении выписки, закрытой до статуса факт" skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box error .
        end.
      end.
      else do:
        run trg/finsttdl.p (
                        input buf_fin-statement.host-code
                       ,input buf_fin-statement.sttm-code
                       ,input no
                       ,input no) no-error.
      end.
    end.
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-statement to row 1 No-ERROR.
  end.
  when yes then do:
      loc#log = no.
      MESSAGE
      "Вы уверены, что хотите удалить ВСЕ отмеченные ВАМИ выписки?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE loc#log.
      IF loc#log <> YES THEN DO:
        RETURN error.
      END.
    do
    on error undo, return error
    on stop undo, return error
    :
      _do:
      do ii = 1 to num-entries(v-rid-list):
        run waitfram-show in this-procedure ( input substitute("Обрабатывается &1 выписка списка", ii)).
        find first buf_fin-statement where
            recid(buf_fin-statement) = integer(entry(ii, v-rid-list)) exclusive-lock no-error .
        if ii = 1 then do:
          assign
          v-doc-rec = recid(buf_fin-statement)
          .
        end.
        if not avail buf_fin-statement
        or (buf_fin-statement.status_ <> 'новый':U
        and buf_fin-statement.status_ <> "":U)
        then do:
          assign
          v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else chr(44)) + entry(ii, v-rid-list)
          .
          NEXT _do.
        end.
        if buf_fin-statement.status_ = 'факт':U then do:
          run trg/finsttdl.p (
                          input buf_fin-statement.host-code
                        ,input buf_fin-statement.sttm-code
                        ,input yes
                        ,input yes ) no-error.
        end.
        else do:
          run trg/finsttdl.p (
                          input buf_fin-statement.host-code
                        ,input buf_fin-statement.sttm-code
                        ,input no
                        ,input yes ) no-error.
        end.
        if error-status:error then do:
          assign
          v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else chr(44)) + entry(ii, v-rid-list)
          .
          NEXT _do.
        end.
        else do:
          assign
          ok-ii = ok-ii + 1
          .
        end.
      end.
    end.
    run waitfram-hide in this-procedure .
    assign
    v-rid-list = v-new-rid-list
    .
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-statement to recid integer(entry(1, v-rid-list)) No-ERROR.
    message
    substitute("Из &1 выбранных Вами выписок удалось удалить &2", ii - 1, ok-ii)
    view-as alert-box.
  end.
END CASE.
APPLY "Value-CHanged" to br-fin-statement in frame Dialog-Frame.
APPLY "ENTRY" to br-fin-statement in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-exp :
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable v-file-name as character no-undo .
define variable for-dir as character no-undo .
define variable accum-count as integer no-undo .
define variable accum-count-ok as integer no-undo .
define variable loclog as logical no-undo .
define variable ii as integer no-undo .
define variable ii0 as integer no-undo .
define buffer buf_fin-statement for ub.fin-statement.
if not available X_fin-statement then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
define variable v-sys-key   as character         no-undo.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
CASE t-batch:
  when no then do:
    assign
    v-file-name =  ?
    .
    run str/xmlfstt.p ( input X_fin-statement.host-code
                       ,input X_fin-statement.sttm-code
                       ,input-output v-file-name
                       ,input yes
                       ,input yes) no-error .
  end.
  when  yes then do:
    if v-rid-list = "":U then do:
        message
        "Вы не отметили ни одной выписки"
        view-as alert-box error.
        return error.
    end.
    run gbl/d-file.p
      (
       input-output v-file-name
      ,input-output for-dir
      ,input  (" Все файлы XML (*.xml) ")
      ,input  ("*.xml":U)
      ,input  chr(44)
      ,input  (".xml":U)
      ,input  no
      ,input  yes
      ,input  yes
      ,input  "Введите имя файла"
      ,output loclog
      ) .
    if not loclog then do:
      return .
    end.
    run waitfram-show in this-procedure ( input "Ждите...").
    assign
    v-doc-rec = recid(X_fin-statement)
    ii0 = num-entries(v-rid-list)
    .
    _do:
    do ii = 1 to ii0:
      find first buf_fin-statement no-lock where
                recid(buf_fin-statement) = integer(entry(ii, v-rid-list)) no-error .
      if available buf_fin-statement then do:
        assign
        accum-count = accum-count + 1
        .
        run str/xmlfstt.p (
                        input buf_fin-statement.host-code
                      , input buf_fin-statement.sttm-code
                      , input-output v-file-name
                      , input (accum-count-ok = 0)
                      , input ii = ii0
                      ) no-error .
        if not error-status:error then
        assign
        accum-count-ok = accum-count-ok + 1
        .
      end.
    end.
    run waitfram-hide in this-procedure .
  end.
END CASE.
if error-status:error
or (t-batch and accum-count <> accum-count-ok)
then do:
  message
  "Ошибка при выгрузке выписки(-ок) в XML-формате" skip
  string(if t-batch then substitute("Выгружено &1 выписок из &2", accum-count-ok, accum-count) else "":U)
  view-as alert-box .
  if not t-batch then
  return error .
end.
if search ("exmldoc.bat") <> ? then do:
  os-command silent value(search ("exmldoc.bat") + " " + v-file-name + " " + v-sys-key).
end.
else do:
  if search (v-file-name ) <> ? then do:
    message "Выписки(-ы) выгружен(-ы) в файл " v-file-name view-as alert-box.
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
when 'ONE-GRAPHICS':U then do:
  RUN proc-print-one-graphics IN THIS-PROCEDURE.
end.
when 'LIST':U then do:
  run proc-print-list in this-procedure no-error.
end.
end case.
loc-option = ''.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'fin-statement'
  join-tbl = 'X_fin-statement'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure ( 'sttm-code', 'Вн.№ выписки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'prn-doc-code', 'Номер', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-date', 'Дата c', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-date', 'Да по', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'doc-date', 'Дата док-та', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'bank-date', 'Дата платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'fact-date', 'Дата факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'num-docs', 'Кол-во док-тов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'fins-doc-type', 'Тип документа', 'fins-doc-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'fins-ext-doc-type', 'Расширен. тип документа', 'fins-ext-doc-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'status_', '', 'fin-statement-stat',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'curr-code', '', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-sum-doc', 'Вход. ост. в вал. счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-sum-doc', 'Исход. ост. в вал. счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-sum-rubl', 'Вход. ост. в нац. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-sum-rubl', 'Исход. ост. в нац. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-sum-base', 'Вход. ост. в баз. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-sum-base', 'Исход. ост. в баз. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-sum-doc-th', 'Вход. ост. в вал. счета (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-sum-doc-th', 'Исход. ост. в вал. счета (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-sum-rubl-th', 'Вход. ост. в нац. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-sum-rubl-th', 'Исход. ост. в нац. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'start-sum-base-th', 'Вход. ост. в баз. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'end-sum-base-th', 'Исход. ост. в баз. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'in-sum-doc', 'Обор-т вход. платежей в вал. счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'out-sum-doc', 'Обор-т исход. платежей в вал. счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'in-sum-rubl', 'Обор-т вход. платежей в нац. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'out-sum-rubl', 'Обор-т исход. платежей нац. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'in-sum-base', 'Обор-т вход. платежей в баз. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'out-sum-base', 'Обор-т исход. платежей баз. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'in-sum-doc-th', 'Обор-т вход. платежей в вал. счета (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'out-sum-doc-th', 'Обор-т исход. платежей в вал. счета (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'in-sum-rubl-th', 'Обор-т вход. платежей в нац. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'out-sum-rubl-th', 'Обор-т исход. платежей нац. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'in-sum-base-th', 'Обор-т вход. платежей в баз. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'out-sum-base-th', 'Обор-т исход. платежей баз. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'sum-doc', 'Оборот в вал. счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'sum-rubl', 'Оборот ост. в нац. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'sum-base', 'Оборот ост. в баз. вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'sum-doc-th', 'Оборот в вал. счета (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'sum-rubl-th', 'Оборот ост. в нац. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'sum-base-th', 'Оборот ост. в баз. вал. (по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'num-docs', 'Кол-во платежей', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'num-docs-th', 'Кол-во платежей(по данным TH)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'code-schet', 'Код счета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'code-bank', 'Код банка', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'bik', 'БИК банка', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'bank-name', 'Банк', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'r-schet', 'Расч.счет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'c-schet', 'Корр.счет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ( 'PS', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
               , INPUT (filter-point + chr(4) +
                        filter-label + chr(4) +
                        string(yes))
               , INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
PROCEDURE proc-br-fin-statement :
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
    if b-lkp:sensitive then
    apply "choose" to b-lkp in frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE proc-buttons :
define input parameter p-is-batch as logical no-undo.
ENABLE
b-close when (is-fact-mode = no
              AND
              (not p-is-batch
              or
              (
              is-stat-mode = yes
                AND
              is-type-mode = yes
              ))
              AND (p-curr-host-code = p-host-code
                  AND available X_sysconf
                  AND X_sysconf.firm-db-num = v-db-num)
              and is-fin
                  )
b-open when (is-fact-mode = no
            AND
              (not p-is-batch
              or
              (
              is-stat-mode = yes
                AND
              is-type-mode = yes
              ))
            AND (p-curr-host-code = p-host-code
                AND available X_sysconf
                AND X_sysconf.firm-db-num = v-db-num)
            and is-fin
                )
b-reject when (is-fact-mode = no
              AND
              (not p-is-batch
              or
              (
              is-stat-mode = yes
                AND
              is-type-mode = yes
              ))
              AND (p-curr-host-code = p-host-code
                    AND available X_sysconf
                    AND X_sysconf.firm-db-num = v-db-num)
             and is-fin
                    )
with frame Dialog-Frame .
CASE p-is-batch:
    when yes then do:
        ENABLE
        B-mark
        with frame Dialog-Frame.
        disable
        b-add
        b-chg with frame Dialog-Frame.
      assign
      menu-item m_one:label     in menu menu-b-print = "Выбранные"
      menu-item m_one-graphics:label     in menu menu-b-print = "Выбранные-графика"
      menu-item m_one:sensitive in menu menu-b-print = (is-type-mode = yes).
    end.
    when no then do:
        ENABLE
        B-mark when lookup("b-mark":U, bttns) > 0
        B-add when (p-curr-host-code = p-host-code
                    AND available X_sysconf
                    AND X_sysconf.firm-db-num = v-db-num
                    AND not p-is-batch
                    AND not(is-stat-mode = yes and p-status_ <> 'новый':U)
                    and is-fin
                    )
        B-chg when (p-curr-host-code = p-host-code
                    AND available X_sysconf
                    AND X_sysconf.firm-db-num = v-db-num
                    and is-fin
                    )
        with frame Dialog-Frame.
        DISABLE
        b-mark when lookup("b-mark":U, bttns) = 0
        with frame Dialog-Frame.
        assign
        menu-item m_one:label     in menu menu-b-print = "Один"
        menu-item m_one-graphics:label     in menu menu-b-print = "Один-графика"
        menu-item m_one:sensitive in menu menu-b-print = yes.
    end.
END CASE.
END PROCEDURE.
PROCEDURE proc-close-open :
define input parameter p-close-mode as character no-undo .
define input parameter p-is-batch as logical no-undo .
define variable v-status_ as character no-undo .
define variable v-old-status_ as character no-undo .
define variable v-fins-doc-type as character no-undo .
define variable v-ask-date as logical no-undo .
define variable v-ask-message as character no-undo .
define variable v-status-date-chr as character no-undo.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable ok as logical no-undo .
define variable ii as integer no-undo.
define variable ok-ii as integer no-undo.
define variable v-new-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable glog as logical no-undo .
define buffer buf_fin-statement for ub.fin-statement.
if t-batch = no then do:
    if not available X_fin-statement then return error.
    assign
    v-doc-rec = recid(X_fin-statement).
end.
if t-batch = yes then do:
if v-rid-list = "":U then do:
    message
    "Вы не отметили ни одного платежа"
    view-as alert-box error.
    return error.
  end.
end.
do
on error undo, return error
:
  CASE t-batch:
    when no then do:
      find first buf_fin-statement where
                recid(buf_fin-statement) = recid(X_fin-statement) exclusive-lock no-error .
      if not avail buf_fin-statement then return error.
      assign
      v-old-status_ = buf_fin-statement.status_
      .
    end.
    when yes then do:
      _do:
      do ii = 1 to num-entries(v-rid-list):
        find first buf_fin-statement where
            recid(buf_fin-statement) = integer(entry(ii, v-rid-list)) exclusive-lock no-error .
        if ii = 1 then do:
          assign
          v-old-status_ = buf_fin-statement.status_
          V-fins-doc-type = BUF_fin-statement.fins-doc-type
          v-doc-rec = recid(buf_fin-statement)
          .
        end.
        if not avail buf_fin-statement
        or (avail buf_fin-statement and v-old-status_ <> "":U and buf_fin-statement.status_ <> v-old-status_)
        or (avail buf_fin-statement and v-fins-doc-type <> "":U aND buf_fin-statement.fins-doc-type <> v-fins-doc-type)
        then NEXT _do.
        LEAVE _do.
      end.
    end.
  END CASE.
end.
run trg/finsgraf.p (
                 input  buf_fin-statement.host-code
                ,input  buf_fin-statement.sttm-code
                ,input  p-close-mode
                ,input  'cl-bank'
                ,input  v-old-status_
                ,input  ?
                ,output v-status_
                ,output v-ask-date
                ,output v-ask-message
                ) no-error.
if error-status:error then do:
  message
  "Ошибка при проверке возможности" p-close-mode skip
  return-value
  view-as alert-box error.
  return error.
end.
case buf_fin-statement.fins-doc-type
:
  when 'стд':U
  then do:
    if v-status_ = 'факт':U
    then do:
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_standard-sttm_close-fact':U
    ,input  'firm':U
    ,input  buf_fin-statement.host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output OK
    )  .
end.
    end.
    else do:
      case p-close-mode
      :
        when '<закрытие документа>':U
        then do:
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_standard-sttm_close-doc':U
    ,input  'firm':U
    ,input  buf_fin-statement.host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output OK
    )  .
end.
        end.
        when '<открытие документа>':U
        then do:
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_standard-sttm_open-doc':U
    ,input  'firm':U
    ,input  buf_fin-statement.host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output OK
    )  .
end.
        end.
        when '<отказ от документа>':U
        then do:
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_standard-sttm_reject-doc':U
    ,input  'firm':U
    ,input  buf_fin-statement.host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output OK
    )  .
end.
        end.
        otherwise do:
          message
            "Ошибка при проверке возможности" p-close-mode skip
            "Неизвестное значение p-close-mode" skip
            view-as alert-box error.
          return error.
        end.
      end case .
    end.
  end.
  otherwise do:
    message
      "Ошибка при проверке возможности" p-close-mode skip
      "Неизвестный тип банковской выписки" buf_fin-statement.fins-doc-type skip
      view-as alert-box error.
    return error.
  end.
end case .
if not ok then return error.
ok = no.
message
v-ask-message skip(1)
(if t-batch
then
substitute("Все платежи, которые Вы отметили, но которые к настоящему моменту не находятся в статусе <&1>,&2 &3 обработаны не будут "
            , v-old-status_
            , chr(10)
            , (if is-type-mode = no
              then substitute("или не имеют типа <&1>,", v-fins-doc-type)
              else "":U)
            )
  else "":U
)
view-as alert-box QUESTION buttons Yes-NO update ok.
if not ok then return error.
if v-ask-date then do:
  run cur-time in this-procedure ( output v-date, output v-time).
  assign
  v-status-date-chr = string(v-date, "99/99/9999":U)
  .
  run gbl/d-prompt.w (
      'title=':u + "Введите дату смены статуса платежа" + '\':u
    + 'text1=':u + "Дата смены статуса" + '\':u
    + 'format=99/99/9999\'
    + 'type=' + 'T':U + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u
    + 'readonly=no\'
    , input-output v-status-date-chr
    ).
  if return-value = 'false':u then return error.
  assign
  v-date = date(integer(substr(v-status-date-chr, 4, 2)),
                integer(substr(v-status-date-chr, 1, 2)),
                integer(substr(v-status-date-chr, 7, 4))
               )
  no-error .
  if error-status:error then do:
    message
    "Неверная дата для смены статуса"
    view-as alert-box error .
    return error.
  end.
end.
run waitfram-show in this-procedure ( input "Ждите..." ).
CASE t-batch:
  when no then do:
    run trg/finsstat.p (
                     input buf_fin-statement.host-code
                    ,input buf_fin-statement.sttm-code
                    ,input p-close-mode
                    ,input '':U
                    ,input v-status_
                    ,input-output v-date
                    ,input no
                   ) no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      if error-status:get-message(1) <> "":u then
      message
      error-status:get-message(1)  skip
      return-value view-as alert-box .
      return error .
    end.
    run waitfram-hide in this-procedure .
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-statement to recid v-doc-rec No-ERROR.
  end.
  when yes then do:
    _do1:
    do ii = 1 to num-entries(v-rid-list):
      run waitfram-show in this-procedure ( input substitute("Обрабатывается &1 платеж списка", ii)).
      find first buf_fin-statement where
                recid(buf_fin-statement) = integer(entry(ii, v-rid-list)) exclusive-lock no-error .
      if not avail buf_fin-statement
      or (avail buf_fin-statement and buf_fin-statement.status_ <> v-old-status_)
      or (avail buf_fin-statement and buf_fin-statement.fins-doc-type <> v-fins-doc-type)
      then DO:
        assign
        v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else chr(44)) + entry(ii, v-rid-list)
        .
        NEXT _do1.
      END.
      run trg/finsstat.p (
                     input buf_fin-statement.host-code
                    ,input buf_fin-statement.sttm-code
                    ,input p-close-mode
                    ,input '':U
                    ,input v-status_
                    ,input-output v-date
                    ,input no
                    ) no-error .
      if error-status:error then do:
        assign
        v-new-rid-list = v-new-rid-list + (if v-new-rid-list = "":U then "":U else chr(44)) + entry(ii, v-rid-list)
        .
        NEXT _do1 .
      end.
      assign
      ok-ii = ok-ii + 1
      v-new-rid-list = v-new-rid-list
      .
    end.
    run waitfram-hide in this-procedure .
    assign
    v-rid-list = v-new-rid-list
    .
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
    reposition br-fin-statement to recid v-doc-rec No-ERROR.
    message
    substitute("Из &1 выбранных Вами платежей удалось сменить статус на &2 у &3 платежей", ii - 1, v-status_, ok-ii)
    view-as alert-box.
  end.
END CASE.
END PROCEDURE.
PROCEDURE proc-find-bik :
define input parameter p-next as logical no-undo.
define input parameter p-bik like ub.fin-statement.bik no-undo.
assign
sch-doc-date = ?
sch-bank-date = ?
sch-fact-date = ?
.
display
"":U @ sch-prn-doc-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-bank-date
with frame Dialog-Frame.
display
"":U @ sch-r-schet
with frame Dialog-Frame .
assign
p-bik = replace(p-bik, chr(34), "":U)
p-bik = replace(p-bik, chr(39), chr(39) + chr(39))
p-bik = chr(34) + p-bik + chr(34).
run OpenBr in this-procedure
    ( input false
     ,input p-next
     ,input substitute("and X_fin-statement.bik   begins &1 "
                      , p-bik)
    ).
apply "entry":u to sch-bik in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-curr-code :
define input parameter p-next as logical no-undo.
define input parameter p-curr-code like ub.fin-statement.curr-code no-undo.
define variable v-curr-code-chr as character no-undo.
assign
sch-doc-date = ?
sch-bank-date = ?
sch-fact-date = ?
.
display
"":U @ sch-prn-doc-code
"":U @ sch-BIK
sch-doc-date
sch-fact-date
sch-bank-date
"":U @ sch-r-schet
with frame Dialog-Frame.
assign
v-curr-code-chr = string(p-curr-code)
.
run OpenBr in this-procedure
    ( input false
     ,input p-next
     ,input substitute("and X_fin-statement.curr-code = &1 "
                       , v-curr-code-chr)
    ).
apply "entry":u to sch-curr-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-date :
define input parameter p-next as logical no-undo.
define input parameter p-date like ub.fin-statement.doc-date no-undo.
define input parameter p-what-date as character no-undo.
define variable v-date-chr as character no-undo.
if p-date = ? then return .
display
"":U @ sch-BIK
0 @ sch-curr-code
"":U @ sch-prn-doc-code
"":U @ sch-r-schet
with frame Dialog-Frame.
CASE p-what-date:
    when "doc-date":U then do:
      assign
      sch-bank-date = ?
      sch-fact-date = ?
      .
      display
      sch-fact-date
      sch-bank-date
      with frame Dialog-Frame.
    end.
    when "fact-date":U then do:
      assign
      sch-doc-date = ?
      sch-bank-date = ?
      .
      display
      sch-doc-date
      sch-bank-date
      with frame Dialog-Frame.
    end.
    when "bank-date":U then do:
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
        ( input false
         ,input true
         ,input substitute("and X_fin-statement.doc-date = &1 "
                          , v-date-chr)
        ).
      apply "entry":u to sch-doc-date in frame Dialog-Frame.
    end.
    when "fact-date":U then do:
       run OpenBr in this-procedure
        ( input false
         ,input true
         ,input substitute("and X_fin-statement.fact-date = &1 "
                            , v-date-chr)
        ).
      apply "entry":u to sch-fact-date in frame Dialog-Frame.
    end.
        when "bank-date":U then do:
       run OpenBr in this-procedure
        ( input false
         ,input true
         ,input substitute("and X_fin-statement.bank-date = &1 "
                          , v-date-chr)
        ).
      apply "entry":u to sch-bank-date in frame Dialog-Frame.
    end.
END CASE.
END PROCEDURE.
PROCEDURE proc-find-prn-doc-code :
define input parameter p-next as logical no-undo.
define input parameter p-prn-doc-code like ub.fin-statement.prn-doc-code no-undo.
assign
sch-doc-date = ?
sch-bank-date = ?
sch-fact-date = ?
.
display
"":U @ sch-BIK
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-bank-date
"":U @ sch-r-schet
with frame Dialog-Frame.
assign
  p-prn-doc-code = replace(p-prn-doc-code, chr(39), chr(39) + chr(39))
.
run OpenBr in this-procedure
    ( input false
     ,input p-next
     ,input substitute("and X_fin-statement.prn-doc-code = '&1'"
                       ,p-prn-doc-code)
    ).
apply "entry":u to sch-prn-doc-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-r-schet :
define input parameter p-next as logical no-undo.
define input parameter p-r-schet like ub.fin-schet.r-schet no-undo.
assign
sch-doc-date = ?
sch-bank-date = ?
sch-fact-date = ?
.
display
"":U @ sch-prn-doc-code
0 @ sch-curr-code
sch-doc-date
sch-fact-date
sch-bank-date
with frame Dialog-Frame.
display
"":U @ sch-BIK
with frame Dialog-Frame.
assign
p-r-schet = replace(p-r-schet, chr(34), "":U)
p-r-schet = replace(p-r-schet, chr(39), chr(39) + chr(39))
p-r-schet = chr(34) + p-r-schet + chr(34).
run OpenBr in this-procedure
    ( input false
     ,input p-next
     ,input substitute("and X_fin-statement.r-schet   begins &1 "
                        , p-r-schet)
    ).
apply "entry":u to sch-r-schet in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-print-list :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
define variable v-curr-abbr as character no-undo.
DEFINE FRAME fin-statement-list
X_fin-statement.prn-doc-code FORMAT "X(22)"
X_fin-statement.code-schet COLUMN-LABEL "Вн.№счета"
X_fin-statement.start-date FORMAT "99/99/9999":U COLUMN-LABEL "С"
X_fin-statement.end-date FORMAT "99/99/9999":U COLUMN-LABEL "По"
X_fin-statement.doc-date
X_fin-statement.bank-date  COLUMn-LABEL "Дата прин!банком"
X_fin-statement.fact-date COLUMn-LABEL "Дата факт"
X_fin-statement.status_
X_fin-statement.sum-doc
X_fin-statement.cli-name COLUMN-LABEL "Назв.!плательщика" FORMAT "X(16)"
v-curr-abbr  COLUMN-LABEL "Вал" FORMAT "X(3)"
X_fin-statement.sttm-code COLUMN-LABEL "Вн.N" FORMAT "999999999":U
X_fin-statement.cl-bank COLUMN-LABEL "Кл-банк"
X_fin-statement.host-code COLUMN-LABEL "Код!фирмы"
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 198).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame Dialog-Frame:title + chr(32) + "Только отмеченные записи")
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME fin-statement-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_fin-statement).
DO WHILE available X_fin-statement :
  GET prev br-fin-statement.
END.
GET next br-fin-statement.
DO WHILE available X_fin-statement :
  if not t-batch or
  mark-string (recid(X_fin-statement), input v-rid-list) = "*":U then do:
    Display STREAM PrnLibStream
    X_fin-statement.prn-doc-code
    X_fin-statement.code-schet
    X_fin-statement.start-date
    X_fin-statement.end-date
    X_fin-statement.doc-date
    X_fin-statement.bank-date
    X_fin-statement.fact-date
    X_fin-statement.status_
    X_fin-statement.sum-doc
    X_fin-statement.cli-name
    get-currency(buffer X_fin-statement) @ v-curr-abbr
    X_fin-statement.sttm-code
    X_fin-statement.cl-bank
    X_fin-statement.host-code
    with FRAME fin-statement-list .
    DOWN STREAM PrnLibStream 1
    with FRAME fin-statement-list  .
  end.
  assign
  accum-count = accum-count + 1
  .
  GET next br-fin-statement.
END.
UNDERLINE  STREAM PrnLibStream
X_fin-statement.prn-doc-code
X_fin-statement.code-schet
X_fin-statement.start-date
X_fin-statement.end-date
X_fin-statement.doc-date
X_fin-statement.bank-date
X_fin-statement.fact-date
X_fin-statement.status_
X_fin-statement.sum-doc
X_fin-statement.cli-name
v-curr-abbr
X_fin-statement.sttm-code
X_fin-statement.cl-bank
X_fin-statement.host-code
with FRAME fin-statement-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_fin-statement.host-code
accum-count @ X_fin-statement.prn-doc-code
with frame fin-statement-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME fin-statement-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-fin-statement to recid v-doc-rec no-error.
APPLY "entry" to br-fin-statement.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                           input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
PROCEDURE proc-print-one :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer no-undo .
define variable v-format as integer no-undo .
define variable ii as integer no-undo .
if not available X_fin-statement then return error.
define buffer buf_fin-statement  for ub.fin-statement.
CASE t-batch:
  when no then do:
    run rep/finsttmp.p (
                    INPUT parParentProc
                    ,input X_fin-statement.host-code
                    ,input X_fin-statement.sttm-code
                    ,input T-batch
                    ,input no
                    ,input-output v-format
                  ) no-error.
    if error-status:error then do:
      return error.
    end.
  end.
  when  yes then do:
    if v-rid-list = "":U then do:
        message
        "Вы не отметили ни одной выписки"
        view-as alert-box error.
        return error.
    end.
    run waitfram-show in this-procedure ( input "Ждите...").
    v-doc-rec = recid(X_fin-statement).
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input 43
                                                ,input yes
                                                ,input no
                                                ).
    output  STREAM PrnLibStream CLOSE.
    assign
    v-format = ?
    .
    _do:
    do ii = 1 to num-entries(v-rid-list):
      find first buf_fin-statement no-lock where
                recid(buf_fin-statement) = integer(entry(ii, v-rid-list)) no-error .
      if available buf_fin-statement then do:
        run rep/finsttmp.p (
                         INPUT parParentProc
                        ,input buf_fin-statement.host-code
                        ,input buf_fin-statement.sttm-code
                        ,T-batch
                        ,(if T-batch and (ii = num-entries(v-rid-list))
                          then yes
                          else no)
                        ,input-output v-format
                      ) no-error.
        if error-status:error or v-format = ? then do:
          next _do .
        end.
        assign
        accum-count = accum-count + 1
        .
      end.
    end.
    run prn-lib-prn-file in this-procedure (
                                                   input parParentProc
                                                  ,input (if v-format = 0 then 0 else 8)
                                                 ).
    run waitfram-hide in this-procedure .
    APPLY "entry" to br-fin-statement in frame Dialog-Frame .
  end.
END CASE.
END PROCEDURE.
PROCEDURE proc-print-one-graphics :
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable for-dir as character no-undo .
define variable accum-count as integer no-undo .
define variable accum-count-ok as integer no-undo .
define variable loclog as logical no-undo .
define variable ii as integer no-undo .
define variable ii0 as integer no-undo .
define variable v-template-code as character no-undo .
define variable v-copy-nums as integer no-undo .
define variable v-add-info as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define buffer buf_fin-statement for ub.fin-statement.
if not available X_fin-statement then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
run gbl/filename.p (
                input "fxmlstt.bat"
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
if error-status:error  = ? then do:
  message
  substitute("Не найден командный файл для графической печати выписок fxmlstt.bat:&1 &2", chr(10), return-value )
  view-as alert-box error .
  return error .
end.
if t-batch then
ii0 = num-entries(v-rid-list).
else ii0 = 1.
run ref/finstcgp.w (
                input X_fin-statement.fins-doc-type
               ,input X_fin-statement.fins-ext-doc-type
               ,input ii0
               ,output v-template-code
               ,output v-copy-nums
               ,output v-add-info) no-error.
if error-status:error
or v-template-code = "":U
then do:
  undo, return error.
end.
CASE t-batch:
  when no then do:
    assign
    v-file-name = ?
    .
    run str/xmlfstt.p ( input X_fin-statement.host-code
                       ,input X_fin-statement.sttm-code
                       ,input-output v-file-name
                       ,input yes
                       ,input yes) no-error .
    if not error-status:error then do:
      os-command silent value(search ("fxmldoc.bat") + chr(32)
                                     + v-full-path + chr(32)
                                     + v-file-name + chr(32)
                                     + v-template-code + chr(32)
                                     + string(v-copy-nums) + chr(32)
                                     + v-add-info
                                     ).
      if os-error = 0 then
      assign
      accum-count-ok = accum-count-ok + 1
      .
    end.
  end.
  when  yes then do:
    if v-rid-list = "":U then do:
        message
        "Вы не отметили ни одного платежа"
        view-as alert-box error.
        return error.
    end.
    run waitfram-show in this-procedure ( input "Ждите...").
    assign
    v-doc-rec = recid(X_fin-statement)
    .
    _do:
    do ii = 1 to ii0:
      run waitfram-show in this-procedure ( input substitute("Ждите... Обрабатывается &1-й документ, всего &2", accum-count + 1, ii0)).
      find first buf_fin-statement no-lock where
                recid(buf_fin-statement) = integer(entry(ii, v-rid-list)) no-error .
      if available buf_fin-statement then do:
        assign
        accum-count = accum-count + 1
        .
        assign
        v-file-name = ?
        .
        run str/xmlfstt.p (
                        input buf_fin-statement.host-code
                      , input buf_fin-statement.sttm-code
                      , input-output v-file-name
                      , input yes
                      , input yes
                      ) no-error .
        if not error-status:error then do:
          os-command silent value(search ("fxmldoc.bat") + chr(32)
                                        + v-full-path + chr(32)
                                        + v-file-name + chr(32)
                                        + v-template-code + chr(32)
                                        + string(v-copy-nums) + chr(32)
                                        + v-add-info
                                        ).
          if os-error = 0 then
          assign
          accum-count-ok = accum-count-ok + 1
          .
        end.
      end.
    end.
    run waitfram-hide in this-procedure .
  end.
END CASE.
if error-status:error
or (t-batch and accum-count <> accum-count-ok)
then do:
  message
  "Ошибка при печати платежа(-ей) в графике" skip
  string(if t-batch then substitute("Напечатано &1 платежей из &2", accum-count-ok, accum-count) else "":U)
  view-as alert-box .
  if not t-batch then
  return error .
end.
END PROCEDURE.
FUNCTION get-currency RETURNS CHARACTER
  ( BUFFER loc-fin-statement FOR ub.fin-statement ) :
 define buffer buf_currency for ub.currency.
  find first buf_currency no-lock where
                buf_currency.curr-code = loc-fin-statement.curr-code no-error.
    if available buf_currency then return buf_currency.curr-abbr.
  RETURN string(loc-fin-statement.curr-code).
END FUNCTION.
