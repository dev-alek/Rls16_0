DEFINE BUFFER buf_clients FOR clients.
DEFINE BUFFER buf_obj FOR clients.
DEFINE BUFFER buf_wth FOR wealth.
DEFINE BUFFER buf_wth-line FOR wth-line.
DEFINE BUFFER current-place FOR wth-place.
DEFINE BUFFER first_wth-line FOR wth-line.
DEFINE BUFFER out-place FOR wth-place.
DEFINE TEMP-TABLE tt-wth-doc NO-UNDO LIKE wth-doc.
DEFINE BUFFER wth-doc FOR wth-doc.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode AS CHARACTER NO-UNDO.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parcli-type like ub.clients.obj-type no-undo.
define input parameter parcli-code like ub.clients.obj-code no-undo.
define input parameter parext-type like ub.wth-doc.ext-doc-type no-undo.
define input parameter par-type like ub.wth-doc.doc-type no-undo.
define input parameter parauto-fill like ub.wth-doc.auto-fill no-undo .
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as CHARACTER no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "перемещение МЦ: добавление, изменение, просмотр":U.
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function chkleave returns logical
(input p-widget-enter as handle
,input p-button-list  as character
).
  if  valid-handle(p-widget-enter)
  and can-query(p-widget-enter, "name":u)
  and lookup(p-widget-enter :name, p-button-list) > 0
  then do:
    return false .
  end.
  return true .
end function.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
function shift-name-no-err return char (
                                        buffer loc-tt-wth-doc for tt-wth-doc
 ).
define variable varshift-name as character no-undo.
define variable varshift-name-num as character no-undo.
  varshift-name = loc-tt-wth-doc.shift-name.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnme in g#lib-trn3 ( input  loc-tt-wth-doc.obj-type,
                       input  loc-tt-wth-doc.obj-code,
                       input  loc-tt-wth-doc.shift-date,
                       input  loc-tt-wth-doc.shift-num,
                       input-output varshift-name,
                       output varshift-name-num
                       ) no-error .
  if error-status:error then do:
    return "":u.
  end.
  return varshift-name-num.
end function.
procedure wthcattr-sprcli :
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-mode  as character no-undo.
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  DEFINE VARIABLE v-value as character no-undo .
  define variable v-cli-type as character no-undo .
  define variable v-cli-code as integer no-undo .
  define buffer buf_clients   for ub.clients.
  define variable v_rid as character no-undo.
  define variable ref-rec as recid no-undo .
  do
  on error undo, return error
  :
      v-value = p-value.
   if p-value <> '':U then do:
    assign
    v-cli-type = substring(p-value, 1, 3)
    v-cli-code = integer(substring(p-value, 4))
    no-error.
    if error-status:error then do:
      assign
      v-cli-type = '':U
      v-cli-code = 0
      .
    end.
   end.
   FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = v-cli-type AND
            buf_clients.obj-code = v-cli-code  NO-ERROR.
   IF available(buf_clients) then do:
    run ref/cli-all.w (
                input parparentproc
               ,input if p-mode = 'ИЗМЕНЕНИЕ':U then "b-sel":U else "":U
               ,input v-cli-type
               ,input 'все':U
               ,input 'все':U
               ,input RECID( buf_clients )
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  ELSE if p-mode = 'ИЗМЕНЕНИЕ':U then DO:
    run ref/cli-all.w (
                 input parparentproc
                ,INPUT "b-sel":U
               ,input  v-cli-type
               ,input 'все':U
               ,input 'текущие':U
               ,input ?
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  else do:
    message
    if p-value = "":U then 'Атрибут не задан!'
    else substitute('Не найден клиент &1',p-value)
    view-as alert-box warning.
  end.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_clients NO-LOCK WHERE
               RECID( buf_clients ) = ref-rec NO-ERROR.
    IF AVAIL buf_clients THEN DO:
      v-value = buf_clients.obj-type + string(buf_clients.obj-code, ">>>>>>>>9").
    end.
  end.
  if v-value <> p-value then do:
    p-value = v-value.
    p-setted = yes.
  end.
  end.
end procedure.
  define new global shared variable g#wthcalib as handle no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-upd-attr no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define temp-table tt-upd-attr-fuel no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info7, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info7, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define temp-table tt-wth-line  no-undo like ub.wth-line .
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
FIELD q-ty-doc     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во по!документу"
FIELD q-ty-fact    AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Количество!факт"
FIELD doc-sum      like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по!документу"
FIELD fact-sum     like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма!факт"
FIELD sum-gds-rubl like ub.wth-line.sum-gds-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (рубл)"
FIELD sum-gds-base like ub.wth-line.sum-gds-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (баз.вал.)"
FIELD price-rubl   like ub.wth-line.price-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(рубл)"
FIELD price-base   like ub.wth-line.price-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(баз.вал.)"
FIELD w-p-code     like ub.wth-dtl.w-p-code
FIELD doc-code     like ub.wth-dtl.doc-code
FIELD gds-code     like ub.wth-gds.gds-code
INDEX tt-pi    IS   PRIMARY UNIQUE par-code  w-p-code doc-code  wth-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        doc-sum  q-ty-doc
 .
define temp-table tt-wth-parts no-undo like ub.wth-parts.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer bf_wth-doc for ub.wth-doc.
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE s-name     AS CHAR NO-UNDO.
DEFINE VARIABLE v_rid      AS CHAR NO-UNDO.
DEFINE VARIABLE l-shift-on AS LOG  NO-UNDO.
DEFINE VARIABLE lock-doc as logical no-undo.
DEFINE VARIABLE locked-out as logical no-undo .
DEFINE VARIABLE locked-current as logical no-undo .
DEFINE VARIABLE locked-inter_ as logical no-undo .
DEFINE VARIABLE locked-cli  as logical no-undo .
DEFINE VARIABLE v-view-fact as logical no-undo .
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-inter AS LOGICAL NO-UNDO .
define variable parext-type-name as character no-undo.
define variable v-ref-rec as recid no-undo .
define buffer auto-wth-doc-lock_batchprocess for ub.batchprocess .
DEFINE BUFFER cli-buf         FOR ub.clients.
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_wth-par   for ub.wth-par.
define buffer bind_wth-doc  for ub.wth-doc.
define buffer bind_inkas    for ub.inkas.
define buffer buf_wth-dtl   for ub.wth-dtl.
FUNCTION get-place-name RETURNS CHARACTER
  (   INPUT p-obj-type AS CHARACTER
     ,INPUT p-obj-code AS INTEGER
     ,INPUT p-w-p-code AS INTEGER )  FORWARD.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-allZone
     LABEL "Вся зона"
     SIZE 10 BY 1.
DEFINE BUTTON B-bar
     LABEL "Сканер"
     SIZE 10 BY 1.
DEFINE BUTTON B-barRange
     LABEL "Скан.расш."
     SIZE 11 BY 1.
DEFINE BUTTON B-bind
     LABEL "Свя&зать"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chk
     LABEL "Че&ки"
     SIZE 10 BY 1.
DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-current
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-deliver
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON B-operator
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-out
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3.13 BY 1.
DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-receiver
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-shcfact
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Сгенерировать номер счет-фактуры".
DEFINE BUTTON r-sht
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .88.
DEFINE VARIABLE deliver-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 21 BY 1 NO-UNDO.
DEFINE VARIABLE f-atrDSF AS DATE FORMAT "99/99/9999":U
     LABEL "Счет-фактура:  Дата"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE f-atrNSF AS CHARACTER FORMAT "X(256)":U
     LABEL "№"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-atrPaydoc AS CHARACTER FORMAT "X(256)":U
     LABEL "К плат.расч. док-ту"
     VIEW-AS FILL-IN
     SIZE 30 BY 1 NO-UNDO.
DEFINE VARIABLE f-atrproxy AS CHARACTER FORMAT "X(256)":U
     LABEL "Доверенность"
     VIEW-AS FILL-IN
     SIZE 30 BY 1 NO-UNDO.
DEFINE VARIABLE f-atrReceiver AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 35 BY 1 NO-UNDO.
DEFINE VARIABLE for-current-w-p-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Место хран."
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE for-current-w-p-name AS CHARACTER FORMAT "X(20)"
      VIEW-AS TEXT
     SIZE 16 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE for-object AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 19 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE for-out-w-p-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Место хран."
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE for-out-w-p-name AS CHARACTER FORMAT "X(20)"
      VIEW-AS TEXT
     SIZE 16.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE operator-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 21 BY 1 NO-UNDO.
DEFINE VARIABLE receiver-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 21 BY 1 NO-UNDO.
DEFINE QUERY BR-lines FOR
      buf_wth-line,
      buf_wth SCROLLING.
DEFINE BROWSE BR-lines
  QUERY BR-lines NO-LOCK DISPLAY
      buf_wth-line.wth-code FORMAT ">>>>>>>>9":U
      buf_wth.wth-name FORMAT "X(40)":U
      get-place-name(buf_wth-line.obj-type, buf_wth-line.obj-code, buf_wth-line.w-p-code) FORMAT "X(20)" COLUMN-LABEL "Название места"
      buf_wth-line.doc-sum FORMAT "->,>>>,>>>,>>9.99":U COLUMN-LABEL 'Кол-во (док.)'
      buf_wth-line.fact-sum FORMAT "->,>>>,>>>,>>9.99":U COLUMN-LABEL 'Кол-во (факт)'
      buf_wth-line.sum-gds-rubl FORMAT "->,>>>,>>>,>>9.99":U COLUMN-LABEL 'Сумма по связ. тов. (рубл.)'
      buf_wth-line.sum-gds-base FORMAT "->,>>>,>>>,>>9.99":U COLUMN-LABEL 'Сумма по связ. тов. (б.в.)'
      buf_wth-line.credate FORMAT "99/99/99":U
      buf_wth-line.creid FORMAT "X(16)":U
      buf_wth-line.price-rubl
      buf_wth-line.price-base
  ENABLE
      buf_wth-line.creid
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.13 BY 7.38.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.5
     b-quit AT ROW 1 COL 11.5
     B-bind AT ROW 1 COL 21.5
     B-prev AT ROW 1 COL 31.5
     B-next AT ROW 1 COL 35.38
     B-Help AT ROW 1 COL 95
     tt-wth-doc.doc-code AT ROW 2.5 COL 6.5 COLON-ALIGNED
          LABEL "Номер"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          FGCOLOR 4
     tt-wth-doc.doc-date AT ROW 2.5 COL 26.5 COLON-ALIGNED
          LABEL "Дата"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-wth-doc.fact-date AT ROW 2.5 COL 44.5 COLON-ALIGNED
          LABEL "Факт"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     tt-wth-doc.shift-date AT ROW 2.5 COL 63.5 COLON-ALIGNED
          LABEL "Смена"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     tt-wth-doc.shift-name AT ROW 2.5 COL 77 COLON-ALIGNED
          LABEL "№" FORMAT "X(5)"
          VIEW-AS FILL-IN
          SIZE 5.5 BY 1
          FGCOLOR 4
     tt-wth-doc.shift-num AT ROW 2.5 COL 87 COLON-ALIGNED
          LABEL "П."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
          FGCOLOR 4
     r-sht AT ROW 2.5 COL 93 WIDGET-ID 24
     tt-wth-doc.obj-type AT ROW 4 COL 13.5 COLON-ALIGNED
          LABEL "Объект"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 6.38 BY 1
     tt-wth-doc.obj-code AT ROW 4 COL 20.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     for-current-w-p-code AT ROW 4 COL 67 COLON-ALIGNED
     B-current AT ROW 4 COL 79.63
     tt-wth-doc.cli-type AT ROW 5.25 COL 13.5 COLON-ALIGNED
          LABEL "Контрагент"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 6.38 BY 1
     tt-wth-doc.cli-code AT ROW 5.25 COL 20.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     B-cli AT ROW 5.25 COL 33
     for-out-w-p-code AT ROW 5.33 COL 67 COLON-ALIGNED
     B-out AT ROW 5.33 COL 79.63
     tt-wth-doc.doc-sum AT ROW 6.75 COL 21.5 COLON-ALIGNED
          LABEL "Кол-во по документу"
          VIEW-AS FILL-IN
          SIZE 17.5 BY 1
          FGCOLOR 4
     tt-wth-doc.fact-sum AT ROW 6.75 COL 67 COLON-ALIGNED
          LABEL "Кол-во факт"
          VIEW-AS FILL-IN
          SIZE 18.38 BY 1
          FGCOLOR 4
     tt-wth-doc.sum-gds-rubl AT ROW 7.75 COL 21.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "Сумма по тов." FORMAT "->,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 17.5 BY 1
          FGCOLOR 4
     tt-wth-doc.sum-gds-base AT ROW 7.75 COL 67 COLON-ALIGNED WIDGET-ID 4
          LABEL "Сумма по тов.(баз.вал)" FORMAT "->>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 18.38 BY 1
          FGCOLOR 4
     tt-wth-doc.operator AT ROW 9.5 COL 10.5 COLON-ALIGNED
          LABEL "Составил"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     B-operator AT ROW 9.5 COL 23
     f-atrDSF AT ROW 9.5 COL 67 COLON-ALIGNED WIDGET-ID 12
     f-atrNSF AT ROW 9.5 COL 82 COLON-ALIGNED WIDGET-ID 10
     B-shcfact AT ROW 9.5 COL 96.5 WIDGET-ID 14
     B-deliver AT ROW 10.5 COL 23
     tt-wth-doc.deliver AT ROW 10.54 COL 10.5 COLON-ALIGNED
          LABEL "Отпустил"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     f-atrPaydoc AT ROW 10.54 COL 67 COLON-ALIGNED WIDGET-ID 18
     tt-wth-doc.receiver AT ROW 11.54 COL 10.5 COLON-ALIGNED
          LABEL "Получил"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     B-receiver AT ROW 11.54 COL 23
     f-atrReceiver AT ROW 11.58 COL 10.5 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     f-atrproxy AT ROW 11.58 COL 67 COLON-ALIGNED WIDGET-ID 22
     BR-lines AT ROW 12.75 COL 1
     B-add AT ROW 20.33 COL 1
     B-lookup AT ROW 20.33 COL 11
     B-chg AT ROW 20.33 COL 21
     B-del AT ROW 20.33 COL 31
     B-chk AT ROW 20.33 COL 41
     B-bar AT ROW 20.33 COL 51 WIDGET-ID 6
     B-barRange AT ROW 20.33 COL 61 WIDGET-ID 16
     B-allZone AT ROW 20.33 COL 72 WIDGET-ID 8
     B-hist AT ROW 20.33 COL 82
     for-object AT ROW 4 COL 34.5 COLON-ALIGNED NO-LABEL
     for-current-w-p-name AT ROW 4 COL 81.5 COLON-ALIGNED NO-LABEL
     tt-wth-doc.cli-name AT ROW 5.25 COL 34.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 19 BY 1
          FGCOLOR 4
     for-out-w-p-name AT ROW 5.25 COL 81 COLON-ALIGNED NO-LABEL
     operator-name AT ROW 9.5 COL 24.5 COLON-ALIGNED NO-LABEL
     deliver-name AT ROW 10.5 COL 24.5 COLON-ALIGNED NO-LABEL
     receiver-name AT ROW 11.58 COL 24.5 COLON-ALIGNED NO-LABEL
     SPACE(52.37) SKIP(9.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ движения материальных ценностей"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-shcfact:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-atrDSF:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-atrNSF:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-atrPaydoc:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-atrproxy:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-atrReceiver:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-wth-doc.fact-sum:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-wth-doc.sum-gds-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-wth-doc.sum-gds-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  p-next-prev = "QUIT".
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
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
  run proc-b-add in this-procedure  no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-allZone IN FRAME Dialog-Frame
DO:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  def var v-zone as char no-undo.
  run proc-save-doc in this-procedure ( input no) No-ERROR.
  if error-status:error
  or return-value = 'error'
  then return 'error'.
  assign
  v-doc-rec = recid(bf_wth-doc)
  .
  case tt-wth-doc.ext-doc-type:
    when 'ee':U or when 'df':U     then v-zone = 'free-zone':U.
    when 'ep':U or when 'dp':U then v-zone = 'put-zone':U.
    when 'dc':U or when 'pz':U or when 'xc':U then v-zone = 'cli-zone':U.
    otherwise do:
      message "Для данного типа документа функция ВСЯ ЗОНА не доступна." view-as alert-box.
      return no-apply.
    end.
  end case.
  define variable v_rid-list AS CHAR NO-UNDO.
  run ref/wth-ref.w (
                 input parparentproc
                ,input "b-sel,b-mark":U
                ,input tt-wth-doc.host-code
                ,input tt-wth-doc.obj-type
                ,input tt-wth-doc.obj-code
                ,input "wth-ser":U
                ,input-OUTPUT v_rid-list ) no-error.
  if error-status:error then do:
    message return-value + error-status:get-message(1) view-as alert-box error title 'Ошибка при запуске справочника МЦ'.
    return.
  end.
  if v_rid-list = "":u then return no-apply.
  run proc-allZone in this-procedure (v_rid-list
                                     ,v-zone)  no-error.
  if error-status:error then do:
    run waitfram-hide in this-procedure .
    message return-value + error-status:get-message(1) view-as alert-box error.
    return no-apply.
  end.
END.
ON CHOOSE OF B-bar IN FRAME Dialog-Frame
DO:
  run proc-save-doc in this-procedure ( input no) No-ERROR.
  if error-status:error
  or return-value = 'error'
  then return no-apply.
  run str/bar-wth.w ( input bf_wth-doc.doc-code
                       ,input for-current-w-p-code
                       ,input for-out-w-p-code ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
  END.
RUN control-doc NO-ERROR.
  OPEN QUERY BR-lines FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK,              EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK.
  apply "entry" to br-lines.
    RETURN NO-APPLY.
END.
ON CHOOSE OF B-barRange IN FRAME Dialog-Frame
DO:
  run proc-save-doc in this-procedure ( input no) No-ERROR.
  if error-status:error
  or return-value = 'error'
  then return no-apply.
  run str/barwthrg.w ( input bf_wth-doc.doc-code
                       ,input for-current-w-p-code
                       ,input for-out-w-p-code ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
  END.
RUN control-doc NO-ERROR.
  OPEN QUERY BR-lines FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK,              EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK.
  apply "entry" to br-lines.
    RETURN NO-APPLY.
END.
ON CHOOSE OF B-bind IN FRAME Dialog-Frame
DO:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable rid#  AS RECID NO-UNDO.
  DEFINE VARIABLE rid-list as character no-undo.
  IF par-mode = 'ПРОСМОТР':U THEN DO:
    RETURN NO-APPLY.
  END.
  FIND FIRST bind_wth-doc NO-LOCK WHERE
                   bind_wth-doc.doc-code = bf_wth-doc.source-ref NO-ERROR.
  IF AVAIL bind_wth-doc THEN DO:
    MESSAGE
      "Документ уже связан с документом" bf_wth-doc.source-ref "!" SKIP( 1 )
      "Вы уверены, что хотите вместо этой связи подставить новую?  "
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
    IF glog <> YES THEN DO:
        RETURN NO-APPLY.
    END.
  END.
  rid-list = '':U.
  run str/wth-docs.w ( input parparentproc
                   ,input 'b-sel':U
                   ,input 'фирма':U
                   ,input parhost-code
                   ,input parobj-type
                   ,input parobj-code
                   ,input  '':U
                   ,input 0
                   ,INPUT '':U
                   ,input '':U
                   ,input '':U
                   ,input-OUTPUT rid-list ).
  rid# = integer(rid-list).
  FIND FIRST bind_wth-doc NO-LOCK WHERE
                   RECID( bind_wth-doc ) = rid# NO-ERROR.
  IF AVAIL bind_wth-doc THEN DO:
    IF rid# = RECID( bf_wth-doc ) OR
      bind_wth-doc.doc-code = bf_wth-doc.doc-code THEN DO:
      MESSAGE "Нельзя связать документ с самим собой!" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
    END.
    ASSIGN
    bf_wth-doc.source-ref = bind_wth-doc.doc-code
    bf_wth-doc.source-type = 'док.МЦ':U
    .
    ASSIGN
    B-Bind :TOOLTIP IN FRAME Dialog-Frame = "Связан с " + bf_wth-doc.source-ref.
  END.
  ELSE DO:
    ASSIGN
    B-Bind :TOOLTIP IN FRAME Dialog-Frame = "":U.
  END.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-line-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
 if not avail buf_wth-line then return no-apply.
  run proc-save-doc in this-procedure ( input no) No-ERROR.
  ASSIGN
  v-line-rec = RECID( buf_wth-line )
  v-doc-rec = recid(bf_wth-doc)
  FOR-CURRENT-W-P-CODE
  FOR-OUT-W-P-CODE
  .
  if error-status:error
  or return-value = 'error'
  then return no-apply.
  run str/wth-inca.w (
                    input parparentproc
                   ,INPUT parhost-code
                   ,INPUT parobj-type
                   ,INPUT parobj-code
                   ,INPUT 'ИЗМЕНЕНИЕ':U
                   ,input v-doc-rec
                   ,input for-current-w-p-code
                   ,input for-out-w-p-code
                   ,INPUT tt-wth-doc.ext-doc-type
                   ,input-output v-LINE-REC ) .
  ASSIGN
  glog = br-lines:REFRESH( ).
RUN control-doc NO-ERROR.
  apply "entry" to br-lines.
END.
ON CHOOSE OF B-chk IN FRAME Dialog-Frame
DO:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  DEFINE VARIABLE loc-ref-list as character no-undo.
  DEFINE VARIABLE var-doc-code like ub.wth-doc.doc-code no-undo .
  if tt-wth-doc.borned then do:
    assign
    var-doc-code = tt-wth-doc.source-ref.
  end.
  else do:
    var-doc-code = tt-wth-doc.doc-code.
  end.
  run str/chk-docs.w (
                  input parparentproc
                 ,input '':U
                 ,input 'out-code':U
                 ,input ?
                 ,input parobj-type
                 ,input parobj-code
                 ,input var-doc-code
                 ,input ''
                 ,input 0
                 ,input ?
                 ,input ?
                 ,input 0
                 ,output loc-ref-list) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-cli IN FRAME Dialog-Frame
DO:
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 define variable v_rid as character no-undo.
 define variable ref-rec as recid no-undo .
   FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = INPUT FRAME Dialog-Frame tt-wth-doc.cli-type AND
            buf_clients.obj-code = INPUT FRAME Dialog-Frame tt-wth-doc.cli-code  NO-ERROR.
   IF available(buf_clients) then do:
    run ref/cli-all.w (
                 input parparentproc
               ,input "b-sel":U
               ,input tt-wth-doc.cli-type
               ,input 'все':U
               ,input 'все':U
               ,input RECID( buf_clients )
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  ELSE DO:
    run ref/cli-all.w (
                 input parparentproc
                ,INPUT "b-sel":U
               ,input  tt-wth-doc.cli-type:screen-value
               ,input 'все':U
               ,input 'текущие':U
               ,input ?
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_clients NO-LOCK WHERE
               RECID( buf_clients ) = ref-rec NO-ERROR.
    IF AVAIL buf_clients THEN DO:
      CASE buf_clients.obj-type:
        when 'маг':U then dO:
          find first ub.shop No-LOCK WHERE
                    ub.shop.obj-code = buf_clients.obj-code No-ERROR.
          if ub.shop.host-code <> tt-wth-doc.host-code then do:
            message "Нельзя выбрать магазин другой фирмы!"
            view-as alert-box error .
            return no-apply.
          end.
        end.
        when 'скл':U then do:
          find first ub.store No-LOCK WHERE
                    ub.store.obj-code = buf_clients.obj-code No-ERROR.
          if ub.store.host-code <> tt-wth-doc.host-code then do:
            message "Нельзя выбрать склад другой фирмы!"
            view-as alert-box error .
            return no-apply.
          end.
        end.
      end CASE.
      ASSIGN
      tt-wth-doc.cli-code = buf_clients.obj-code
      tt-wth-doc.cli-type = buf_clients.obj-type
      tt-wth-doc.cli-name = buf_clients.obj-name
      .
      DISPLAY
      tt-wth-doc.cli-type
      tt-wth-doc.cli-code
      tt-wth-doc.cli-name
      WITH FRAME Dialog-Frame.
    END.
    ELSE DO:
      RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.
  run control-out in this-procedure.
END.
ON CHOOSE OF B-current IN FRAME Dialog-Frame
DO:
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v_rid as character no-undo.
define variable ref-rec as recid no-undo .
v_rid = "":U.
  run ref/wthplref.w (
                   input parparentproc
                  ,INPUT "b-sel":U
                  ,INPUT tt-wth-doc.host-code
                  ,INPUT tt-wth-doc.obj-type
                  ,INPUT tt-wth-doc.obj-code
                  ,input 'объект':U
                  ,input-OUTPUT v_rid ).
    IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST current-place NO-LOCK WHERE
                      RECID( current-place ) = ref-rec NO-ERROR.
    IF AVAIL current-place THEN DO:
      if tt-wth-doc.auto-fill and current-place.cash-desk = 0 then do:
        message
        "Для автоматического документа место хранения должно быть кассой"
        view-as alert-box error.
        return no-apply.
      end.
      DISPLAY
      current-place.w-p-code @ for-current-w-p-code
      current-place.w-p-name @ for-current-w-p-name
       WITH FRAME Dialog-Frame.
    END.
    ELSE DO:
        RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-deliver IN FRAME Dialog-Frame
DO:
RUN local-psn-chk  in this-procedure ( input "deliver", input "button").
   apply "entry" to tt-wth-doc.deliver in FRAME Dialog-Frame.
   return no-apply.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 run proc-save-doc in this-procedure (input (if tt-wth-doc.auto-fill then no else yes)) No-ERROR.
 if error-status:error
 or return-value = 'error'
 then return no-apply.
 p-doc-rec = v-doc-rec.
 APPLY "GO":U TO FRAME Dialog-Frame.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if not avail buf_wth-line then return no-apply.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-line-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
 if not avail buf_wth-line then return no-apply.
  ASSIGN
  v-line-rec = RECID( buf_wth-line )
  v-doc-rec = recid(bf_wth-doc)
  FOR-CURRENT-W-P-CODE
  FOR-OUT-W-P-CODE
  .
  run str/wth-inca.w (  input parparentproc
                   ,INPUT parhost-code
                   ,INPUT parobj-type
                   ,INPUT parobj-code
                   ,INPUT 'ПРОСМОТР':U
                   ,input v-doc-rec
                   ,input for-current-w-p-code
                   ,input for-out-w-p-code
                   ,INPUT tt-wth-doc.ext-doc-type
                   ,input-output v-LINE-REC ) no-error.
  if error-status:error then do:
    message return-value error-status:get-message(1) view-as alert-box.
  end.
  apply "entry" to br-lines.
END.
ON CHOOSE OF B-next IN FRAME Dialog-Frame
DO:
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
     run reposition-wth-doc in this-procedure
  (input 'next':U
  ).
END.
ON CHOOSE OF B-operator IN FRAME Dialog-Frame
DO:
 RUN local-psn-chk in this-procedure ( input "operator", input "button").
   apply "entry" to tt-wth-doc.operator in FRAME Dialog-Frame.
   return no-apply.
END.
ON CHOOSE OF B-out IN FRAME Dialog-Frame
DO:
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable was_found  AS LOG  NO-UNDO.
  define variable ref-rec as recid no-undo .
  IF tt-wth-doc.cli-type = 'маг':U OR
     tt-wth-doc.cli-type = 'скл':U THEN DO:
    IF CAN-FIND( buf_clients NO-LOCK WHERE
         buf_clients.obj-type = INPUT FRAME Dialog-Frame tt-wth-doc.cli-type   AND
         buf_clients.obj-code = INPUT FRAME Dialog-Frame tt-wth-doc.cli-code )
    THEN DO:
      CASE INPUT FRAME Dialog-Frame tt-wth-doc.cli-type :
        WHEN 'маг':U  THEN DO:
          FIND FIRST ub.shop  NO-LOCK WHERE
                            ub.shop.host-code = tt-wth-doc.host-code  AND
                            ub.shop.obj-code  = INPUT FRAME Dialog-Frame tt-wth-doc.cli-code  NO-ERROR.
          ASSIGN was_found = ( AVAIL ub.shop ).
        END.
        WHEN 'скл':U THEN DO:
          FIND FIRST ub.store NO-LOCK WHERE
                            ub.store.host-code = tt-wth-doc.host-code AND
                            ub.store.obj-code = INPUT FRAME Dialog-Frame tt-wth-doc.cli-code NO-ERROR.
          ASSIGN was_found = ( AVAIL ub.store ).
        END.
      END CASE.
    END.
  END.
  FIND FIRST out-place NO-LOCK WHERE
                    out-place.host-code = tt-wth-doc.host-code               AND
                    out-place.obj-type    = tt-wth-doc.cli-type  AND
                    out-place.obj-code    = tt-wth-doc.cli-code  AND
                    out-place.w-p-code    = INPUT FRAME Dialog-Frame for-out-w-p-code NO-ERROR.
  IF AVAIL out-place THEN DO:
    ASSIGN v_rid = string(RECID( out-place ))
    .
  END.
  run ref/wthplref.w (
                   input parparentproc
                  ,INPUT "b-sel":U
                  ,INPUT tt-wth-doc.host-code
                  ,INPUT tt-wth-doc.cli-type
                  ,INPUT tt-wth-doc.cli-code
                  ,input 'объект':U
                  ,input-output v_rid ).
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND out-place NO-LOCK WHERE
            RECID( out-place ) = ref-rec NO-ERROR.
    IF AVAIL out-place THEN DO:
      DISPLAY
      out-place.w-p-code @ for-out-w-p-code
      out-place.w-p-name @ for-out-w-p-name
      WITH FRAME Dialog-Frame.
    END.
    ELSE DO:
        RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-prev IN FRAME Dialog-Frame
DO:
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
     run reposition-wth-doc in this-procedure
  (input 'prev':U
  ).
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    IF par-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    IF CAN-FIND( FIRST ub.wth-line NO-LOCK WHERE
                       ub.wth-line.doc-code = bf_wth-doc.doc-code ) THEN DO:
      MESSAGE
        "Документ не будет сохранен, а вся введенная Вами информация будет потеряна!" SKIP
        "Для того, чтобы сохранить документ, нужно нажать кнопку ~"" +
        B-exit:LABEL IN FRAME Dialog-Frame + "~"." SKIP( 1 )
        "Вы уверены, что хотите выйти БЕЗ СОХРАНЕНИЯ?" SKIP
        "YES[ДА] - Выйти БЕЗ СОХРАНЕНИЯ;" SKIP
        "NO[НЕТ] - Остаться в документе."
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
      TITLE "Выход из документа без сохранения" UPDATE glog.
      IF glog = NO THEN DO:
        RETURN NO-APPLY.
      END.
    END.
    DO TRANSACTION ON ERROR UNDO, LEAVE :
      FIND CURRENT bf_wth-doc EXCLUSIVE-LOCK.
      DELETE bf_wth-doc.
      p-doc-rec = ?.
    END.
  END.
  define variable v-atrValue    as character no-undo .
  define variable v-atrType     as character no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable v-value-logical AS LOGICAL no-undo .
  define variable v-param-type as character no-undo .
  define variable v-stfactpref as character no-undo .
  define variable v-numsfact   as integer no-undo .
  if f-atrNSF <> f-atrNsf:screen-value then do:
  v-atrValue =  f-atrNsf:screen-value.
  run adm/shattri.p (
        input "get":U
        ,input  tt-wth-doc.obj-type
        ,input  tt-wth-doc.obj-code
        ,input  'wthdoc_obj':U
        ,input  '':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF not error-status:error  then do:
      for each thbjattr_thbj-attr no-lock:
        if thbjattr_thbj-attr.prop-code = 'stfactpref':U then v-stfactpref = thbjattr_thbj-attr.property-value-character.
        if thbjattr_thbj-attr.prop-code = 'numsfact':U then v-numsfact = thbjattr_thbj-attr.property-value-integer.
      end.
    end.
    if v-atrValue = v-stfactpref + string(v-numsfact) then do:
      v-numsfact = v-numsfact - 1.
      RUN thbjattr_write IN THIS-PROCEDURE (
            input tt-wth-doc.obj-type
          ,input tt-wth-doc.obj-code
          ,input 'wthdoc_obj':U
          ,input 'numsfact':U
          ,input '':U
          ,input ?
          ,input 0
          ,input v-numsfact
          ,input no
      ) NO-ERROR.
      IF ERROR-STATUS:error THEN do:
        MESSAGE ERROR-STATUS:get-message(1)  SKIP
        RETURN-VALUE
        VIEW-AS ALERT-BOX warning.
      END.
    end.
  end.
   p-next-prev = "QUIT".
END.
ON CHOOSE OF B-receiver IN FRAME Dialog-Frame
DO:
  RUN local-psn-chk in this-procedure ( input "receiver", input "button").
  apply "entry" to tt-wth-doc.receiver in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-shcfact IN FRAME Dialog-Frame
DO:
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-nsf as character no-undo.
define variable v-dsf as date no-undo.
if f-atrNsf:screen-value > '' then do:
  message
  "Номер сч.-фактуры заполнен." skip
  "Сгенерировать новый номер?"
  view-as alert-box question buttons yes-no update choice as log.
  if choice then.
  else return no-apply.
end.
run str/wthsfgen.p (
                   input tt-wth-doc.obj-type
                  ,input tt-wth-doc.obj-code
                  ,output v-nsf ) no-error.
if error-status:error then do:
  MESSAGE ERROR-STATUS:get-message(1)  SKIP
  RETURN-VALUE
  VIEW-AS ALERT-BOX.
  return.
end.
f-atrNSF:screen-value = v-nsf.
v-dsf = date(f-atrdsf:screen-value) no-error.
if v-dsf = ? then f-atrdsf:screen-value = tt-wth-doc.doc-date:screen-value.
END.
ON LEAVE OF tt-wth-doc.cli-code IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame tt-wth-doc.cli-type
                             tt-wth-doc.cli-code.
    FIND FIRST buf_clients NO-LOCK WHERE
                buf_clients.obj-type = INPUT FRAME Dialog-Frame tt-wth-doc.cli-type AND
                buf_clients.obj-code = INPUT FRAME Dialog-Frame tt-wth-doc.cli-code NO-ERROR.
  IF AVAIL buf_clients THEN DO:
    CASE buf_clients.obj-type:
      when 'маг':U then dO:
        find first ub.shop No-LOCK WHERE
                   ub.shop.obj-code = buf_clients.obj-code No-ERROR.
        if ub.shop.host-code <> tt-wth-doc.host-code then do:
          message "Нельзя выбрать магазин другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to tt-wth-doc.cli-code in frame Dialog-Frame.
          return no-apply.
        end.
      end.
      when 'скл':U then do:
        find first ub.store No-LOCK WHERE
                   ub.store.obj-code = buf_clients.obj-code No-ERROR.
        if ub.store.host-code <> tt-wth-doc.host-code then do:
          message "Нельзя выбрать склад другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to tt-wth-doc.cli-code in frame Dialog-Frame.
          return no-apply.
        end.
      end.
      when 'орг':U then do:
            end.
    end CASE.
    DISPLAY
    buf_clients.obj-name @ tt-wth-doc.cli-name WITH FRAME Dialog-Frame.
  END.
  run control-out in this-procedure.
END.
ON VALUE-CHANGED OF tt-wth-doc.cli-type IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame tt-wth-doc.cli-type
                             tt-wth-doc.cli-code.
 run control-out in this-procedure.
 FIND FIRST buf_clients NO-LOCK WHERE
          buf_clients.obj-type = INPUT FRAME Dialog-Frame tt-wth-doc.cli-type AND
          buf_clients.obj-code = INPUT FRAME Dialog-Frame tt-wth-doc.cli-code NO-ERROR.
IF AVAIL buf_clients THEN DO:
    DISPLAY
    buf_clients.obj-name @ tt-wth-doc.cli-name WITH FRAME Dialog-Frame.
END.
ELSE DO:
    DISPLAY
    "":U @ tt-wth-doc.cli-name WITH FRAME Dialog-Frame.
END.
END.
ON LEAVE OF tt-wth-doc.deliver IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-wth-doc.deliver <> tt-wth-doc.deliver then do:
    run local-psn-chk in this-procedure ( input "deliver", input "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.deliver IN FRAME Dialog-Frame
OR return OF tt-wth-doc.deliver IN FRAME Dialog-Frame DO:
  run local-psn-chk in this-procedure ( input "deliver", input "ret-mouse").
  apply "entry" to tt-wth-doc.deliver in frame Dialog-Frame.
  return no-apply.
END.
ON LEAVE OF tt-wth-doc.fact-date IN FRAME Dialog-Frame
DO:
   run chk-upd-date in this-procedure ( input self :name ) no-error.
   if error-status:error then return no-apply.
END.
ON RETURN OF tt-wth-doc.fact-date IN FRAME Dialog-Frame
DO:
    if tt-wth-doc.fact-date:sensitive in frame Dialog-Frame then do:
    apply "entry" to tt-wth-doc.shift-date in frame Dialog-Frame.
  end.
  else do:
    apply "entry" to b-add in frame Dialog-Frame.
  end.
  return no-apply.
END.
ON LEAVE OF for-current-w-p-code IN FRAME Dialog-Frame
DO:
    FIND FIRST current-place NO-LOCK WHERE
            current-place.host-code = tt-wth-doc.host-code AND
            current-place.obj-type = tt-wth-doc.obj-type      AND
            current-place.obj-code = tt-wth-doc.obj-code      AND
            current-place.w-p-code = INPUT FRAME Dialog-Frame for-current-w-p-code NO-ERROR.
  IF AVAIL current-place THEN DO:
    DISPLAY
    current-place.w-p-name @ for-current-w-p-name
    WITH FRAME Dialog-Frame.
  END.
END.
ON LEAVE OF for-out-w-p-code IN FRAME Dialog-Frame
DO:
  if chkleave
    (input last-event :widget-enter
    ,input "b-quit,b-out":u
    )
  then do:
    FIND FIRST out-place NO-LOCK WHERE
            out-place.host-code = tt-wth-doc.host-code AND
            out-place.obj-type = tt-wth-doc.cli-type AND
            out-place.obj-code = tt-wth-doc.cli-code AND
            out-place.w-p-code = INPUT FRAME Dialog-Frame for-out-w-p-code NO-ERROR.
    IF AVAIL out-place THEN DO:
      DISPLAY
      out-place.w-p-name @ for-out-w-p-name
          WITH FRAME Dialog-Frame.
    END.
    else  IF NOT AVAIL out-place AND
      int(for-out-w-p-code:screen-value) <> 0 AND
      int(for-out-w-p-code:screen-value) <> ? AND
      tt-wth-doc.doc-type <> 'возврат':U and
      tt-wth-doc.doc-type <> 'при':U and
      tt-wth-doc.exter_ = no  and
      tt-wth-doc.inter_ = no THEN DO:
      message  substitute( "Не найдено место хранения МЦ &1 в справочнике!"
                        ,for-out-w-p-code:screen-value
                      ).
     return no-apply.
    end.
    else display    "":U @ for-out-w-p-name
          WITH FRAME Dialog-Frame.
  end.
END.
ON VALUE-CHANGED OF tt-wth-doc.obj-type IN FRAME Dialog-Frame
DO:
   FIND FIRST buf_obj NO-LOCK WHERE
          buf_obj.obj-type = INPUT FRAME Dialog-Frame tt-wth-doc.obj-type AND
          buf_obj.obj-code = INPUT FRAME Dialog-Frame tt-wth-doc.obj-code NO-ERROR.
   IF AVAIL buf_obj THEN DO:
    DISPLAY
    buf_obj.obj-name @ for-object WITH FRAME Dialog-Frame.
   END.
   ELSE DO:
        DISPLAY
        "":U @ for-object WITH FRAME Dialog-Frame.
   END.
END.
ON LEAVE OF tt-wth-doc.operator IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-wth-doc.operator <> tt-wth-doc.operator then do:
    run local-psn-chk in this-procedure ( input "operator", input "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.operator IN FRAME Dialog-Frame
OR return OF tt-wth-doc.operator IN FRAME Dialog-Frame DO:
  run local-psn-chk in this-procedure (input "operator", input "ret-mouse").
  apply "entry" to tt-wth-doc.operator in frame Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF r-sht IN FRAME Dialog-Frame
DO:
  run proc-sht no-error.
END.
ON LEAVE OF tt-wth-doc.receiver IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-wth-doc.receiver <> tt-wth-doc.receiver then do:
    run local-psn-chk in this-procedure (input "receiver", input "leave").
    if  input frame Dialog-Frame tt-wth-doc.receiver > 0 then do:
      hide f-AtrReceiver in  frame Dialog-Frame.
    end.
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-wth-doc.receiver IN FRAME Dialog-Frame
OR return OF tt-wth-doc.receiver IN FRAME Dialog-Frame DO:
  run local-psn-chk in this-procedure (input "receiver", input "ret-mouse").
  apply "entry" to tt-wth-doc.receiver in frame Dialog-Frame.
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-lines :handle
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
on "END-ERROR":U, stop of frame Dialog-Frame do:
  apply "choose" to b-quit in frame Dialog-Frame.
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
p-next-prev = '':U.
n-p: do while p-next-prev = '':U :
on leave of tt-wth-doc.shift-date in frame Dialog-Frame do:
  if input frame Dialog-Frame tt-wth-doc.shift-date <> tt-wth-doc.shift-date then do:
    assign
      tt-wth-doc.shift-name = ""
      tt-wth-doc.shift-num  = 0.
    display tt-wth-doc.shift-name tt-wth-doc.shift-num with frame Dialog-Frame.
    apply "entry" to tt-wth-doc.shift-name in frame Dialog-Frame.
    return no-apply.
  end.
end.
on return of tt-wth-doc.shift-date in frame Dialog-Frame do:
  apply "entry" to tt-wth-doc.shift-name in frame Dialog-Frame.
  return no-apply.
end.
on return of tt-wth-doc.shift-name in frame Dialog-Frame do:
  apply "entry" to b-add in frame Dialog-Frame.
  return no-apply.
end.
on return of tt-wth-doc.shift-num in frame Dialog-Frame do:
  apply "entry" to b-add in frame Dialog-Frame.
  return no-apply.
end.
on leave of tt-wth-doc.shift-num  in frame Dialog-Frame do:
  if not available tt-wth-doc then return .
  run proc-shift-num no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
on leave of tt-wth-doc.shift-name in frame Dialog-Frame do:
if not available tt-wth-doc then return .
  run proc-shift-name no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if par-mode <> 'ИЗМЕНЕНИЕ':U and par-mode <> 'ДОБАВЛЕНИЕ':U and par-mode <> 'ПРОСМОТР':U then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова par-mode"
        view-as alert-box ERROR.
        return error.
    end.
    if not par-mode = 'ПРОСМОТР':U then
    p-next-prev = "QUIT".
    find first ub.sysconf No-LOCK WHERE
                     ub.sysconf.host-code = parhost-code No-ERROR.
    if not avail ub.sysconf then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parhost-code"
            view-as alert-box ERROR.
            return error.
    end.
    find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = parobj-type AND
                ub.clients.obj-code = parobj-code No-ERROR.
    if not avail ub.clients then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parobj-type/parobj-code"
            view-as alert-box ERROR.
            return error.
    end.
    if parcli-type <> '':U or parcli-code <> 0 then do:
        find first ub.clients No-LOCK WHERE
                    ub.clients.obj-type = parcli-type AND
                    ub.clients.obj-code = parcli-code No-ERROR.
        if not avail ub.clients then do:
            message vss-workfile vss-revision vss-description skip
                            "Неверный параметр вызова parcli-type/parcli-code"
                view-as alert-box ERROR.
                return error.
        end.
    end.
    if LOOKUP(parext-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u) = 0 then do:
            message vss-workfile vss-revision vss-description skip
                            "Неверный параметр вызова parext-type"
                view-as alert-box ERROR.
                return error.
    end.
    tt-wth-doc.cli-type:list-items = 'орг':U + chr(44) +
                                    'чел':U + chr(44) +
                                    'маг':U + chr(44) +
                                    'скл':U + chr(44).
    tt-wth-doc.obj-type:list-items = 'орг':U + chr(44) +
                                    'чел':U + chr(44) +
                                    'маг':U + chr(44) +
                                    'скл':U + chr(44).
  Run fill-tables no-error.
  if error-status:error then return error.
  if par-mode = 'ИЗМЕНЕНИЕ':U then do:
    if  parobj-type <> tt-wth-doc.obj-type
    or parobj-code <> tt-wth-doc.obj-code then do:
            message vss-workfile vss-revision vss-description skip
               "Документ может быть изменен только на активной стороне!"
                view-as alert-box ERROR.
                return error.
    end.
  end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
end.
RUN disable_UI.
PROCEDURE chk-upd-date :
define input parameter parself-name as character no-undo.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
if input frame Dialog-Frame tt-wth-doc.fact-date  <> tt-wth-doc.fact-date  or
   input frame Dialog-Frame tt-wth-doc.shift-date <> tt-wth-doc.shift-date or
   input frame Dialog-Frame tt-wth-doc.shift-num  <> tt-wth-doc.shift-num then do:
if parself-name = "fact-date" then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
  if input frame Dialog-Frame tt-wth-doc.fact-date > v-today then do:
     message "Фактическая Дата документа не должна быть больше сегодняшней даты на объекте." view-as alert-box error.
     display tt-wth-doc.fact-date with frame Dialog-Frame.
     return error.
  end.
  assign glog = no.
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wth-doc_create-back-shift':U
    ,input  'object':U
    ,input  tt-wth-doc.host-code
    ,input  tt-wth-doc.obj-type
    ,input  tt-wth-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if glog = no then do:
     display tt-wth-doc.fact-date with frame Dialog-Frame.
     return error.
  end.
end.
assign frame Dialog-Frame
  tt-wth-doc.fact-date
  tt-wth-doc.shift-date
  tt-wth-doc.shift-num
  tt-wth-doc.shift-name.
assign tt-wth-doc.fact-time = (24 * 60 * 60).
end.
END PROCEDURE.
PROCEDURE control-doc :
assign
tt-wth-doc.doc-sum = bf_wth-doc.doc-sum
tt-wth-doc.fact-sum = bf_wth-doc.fact-sum
tt-wth-doc.sum-gds-rubl = bf_wth-doc.sum-gds-rubl
tt-wth-doc.sum-gds-base = bf_wth-doc.sum-gds-base
.
DISPLAY
tt-wth-doc.doc-sum
tt-wth-doc.sum-gds-rubl
tt-wth-doc.sum-gds-base
tt-wth-doc.fact-sum when lookup(tt-wth-doc.ext-doc-type, 'de':U) = 0
with frame Dialog-Frame .
run control-line in this-procedure ( output lock-doc).
run lock-proc in this-procedure (input lock-doc).
END PROCEDURE.
PROCEDURE control-line :
DEFINE OUTPUT PARAMETER lock-doc as logical no-undo.
IF CAN-FIND(FIRST ub.wth-line No-LOCK WHERE
                  ub.wth-line.doc-code = tt-wth-doc.doc-code) then do:
 lock-doc = yes.
end.
else do:
 lock-doc = no.
end.
END PROCEDURE.
PROCEDURE control-out :
 IF INPUT FRAME Dialog-Frame tt-wth-doc.cli-type = 'чел':U   OR
    INPUT FRAME Dialog-Frame tt-wth-doc.cli-type = 'орг':U
    or tt-wth-doc.ext-doc-type = 'ps':U  THEN DO:
    DISABLE
    for-out-w-p-code
    B-out
    WITH FRAME Dialog-Frame.
    HIDE
    for-out-w-p-code IN FRAME Dialog-Frame
    for-out-w-p-name IN FRAME Dialog-Frame
    B-out    IN FRAME Dialog-Frame
    .
    locked-out = yes.
  END.
  ELSE IF (INPUT FRAME Dialog-Frame tt-wth-doc.cli-type = 'маг':U  OR
          INPUT FRAME Dialog-Frame tt-wth-doc.cli-type = 'скл':U)
          and not tt-wth-doc.ext-doc-type = 'ps':U THEN DO:
    DISPLAY
    for-out-w-p-code WITH FRAME Dialog-Frame.
    ENABLE
    for-out-w-p-code
    B-out
    WITH FRAME Dialog-Frame.
    locked-out = no.
  END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY for-current-w-p-code for-out-w-p-code f-atrDSF f-atrNSF f-atrPaydoc
          f-atrReceiver f-atrproxy for-object for-current-w-p-name
          for-out-w-p-name operator-name deliver-name receiver-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-doc THEN
    DISPLAY tt-wth-doc.doc-code tt-wth-doc.doc-date tt-wth-doc.fact-date
          tt-wth-doc.shift-date tt-wth-doc.shift-name tt-wth-doc.shift-num
          tt-wth-doc.obj-type tt-wth-doc.obj-code tt-wth-doc.cli-type
          tt-wth-doc.cli-code tt-wth-doc.doc-sum tt-wth-doc.fact-sum
          tt-wth-doc.sum-gds-rubl tt-wth-doc.sum-gds-base tt-wth-doc.operator
          tt-wth-doc.deliver tt-wth-doc.receiver tt-wth-doc.cli-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-bind B-prev B-next B-Help tt-wth-doc.doc-date
         tt-wth-doc.fact-date tt-wth-doc.shift-date tt-wth-doc.shift-name
         tt-wth-doc.shift-num r-sht tt-wth-doc.obj-code for-current-w-p-code
         B-current tt-wth-doc.cli-type tt-wth-doc.cli-code B-cli
         for-out-w-p-code B-out tt-wth-doc.doc-sum tt-wth-doc.operator
         B-operator B-shcfact B-deliver tt-wth-doc.deliver tt-wth-doc.receiver
         B-receiver BR-lines B-add B-lookup B-del B-chk B-bar B-barRange
         B-allZone B-hist for-object for-current-w-p-name tt-wth-doc.cli-name
         for-out-w-p-name operator-name deliver-name receiver-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
for each tt-wth-doc:
    delete tt-wth-doc.
end.
IF par-mode = 'ДОБАВЛЕНИЕ':U then do:
   run gbl/factdate.p (
                     INPUT        parobj-type
                    ,INPUT        parobj-code
                    ,INPUT-OUTPUT f-date
                    ,INPUT-OUTPUT f-time
                    ,INPUT-OUTPUT s-date
                    ,INPUT-OUTPUT s-num
                    ,INPUT-OUTPUT s-name
                    ,INPUT        YES
                      ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      return error.
    END.
    DO TRANSACTION ON ERROR UNDO, RETURN ERROR:
define variable l-in-ov31 as logical no-undo .
define variable v-date31 as date no-undo .
define variable v-time31 as integer no-undo .
run cur-time in this-procedure(output v-date31, output v-time31).
CREATE tt-wth-doc.
ASSIGN
  tt-wth-doc.host-code = parhost-code
  tt-wth-doc.doc-code  = TRIM( STRING( NEXT-VALUE( s-wth-doc, ub), ">>>>>>>>>9":U ) ) + "-" + TRIM( STRING( parobj-code, ">>>>>>>>9":U ) ) +                   SUBSTR( parobj-type, ( IF g#language = "RUS" THEN 1 ELSE 2 ), 1 )
   tt-wth-doc.doc-type  = par-type
  tt-wth-doc.ext-doc-type  = parext-type
  tt-wth-doc.inter_    = if  lookup(tt-wth-doc.ext-doc-type,'ij,pj,fj,jj,oj,ej':U) > 0 then yes else no
  tt-wth-doc.exter_    = if  lookup(tt-wth-doc.ext-doc-type,'ie,ee,we,pc,ps,iy,pz,df,dp,dc,xc':U) > 0 then yes else no
  tt-wth-doc.status_   = 'накл':U
  tt-wth-doc.obj-type  = parobj-type
  tt-wth-doc.obj-code  = parobj-code
  tt-wth-doc.creid     = v-cntxt-userid
  tt-wth-doc.credate   = v-date31
.
if tt-wth-doc.doc-type = 'инв':U or lookup(tt-wth-doc.ext-doc-type, 'we,dc,dp,df':U) > 0
   or tt-wth-doc.doc-type = 'декл':U then do:
  assign
    tt-wth-doc.cli-type  = 'орг':U
    tt-wth-doc.cli-code  = parhost-code
    .
end.
else if tt-wth-doc.ext-doc-type = 'ps':U then do:
  assign
  tt-wth-doc.cli-type  = parobj-type
  tt-wth-doc.cli-code  = parobj-code
  .
end.
else if tt-wth-doc.inter_  = yes
then do:
  assign
  tt-wth-doc.cli-type  = parobj-type
  tt-wth-doc.cli-code  = parobj-code
  .
end.
else if tt-wth-doc.exter_  = yes
then do:
  assign
  tt-wth-doc.cli-type  =  (if parcli-type <> "" then parcli-type else 'орг':U)
  tt-wth-doc.cli-code  =  (if parcli-code <> 0 then parcli-code else 0)
  .
end.
else assign
    tt-wth-doc.cli-type  = parobj-type
    tt-wth-doc.cli-code  = 0
.
      ASSIGN
      tt-wth-doc.shift-date = s-date
      tt-wth-doc.shift-num  = s-num
      tt-wth-doc.shift-name = s-name
      tt-wth-doc.doc-date   = f-date
      tt-wth-doc.fact-date  = if (lookup(tt-wth-doc.ext-doc-type,'ii,fj,jj,pj,oj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,xc':U) > 0 and s-num <> 0) then s-date else f-date
      tt-wth-doc.auto-fill = parauto-fill
      .
define variable l-in-ov32 as logical no-undo .
define variable v-date32 as date no-undo .
define variable v-time32 as integer no-undo .
run cur-time in this-procedure(output v-date32, output v-time32).
CREATE bf_wth-doc.
ASSIGN
  bf_wth-doc.host-code = parhost-code
  bf_wth-doc.doc-code  = tt-wth-doc.doc-code
   bf_wth-doc.doc-type  = par-type
  bf_wth-doc.ext-doc-type  = parext-type
  bf_wth-doc.inter_    = if  lookup(bf_wth-doc.ext-doc-type,'ij,pj,fj,jj,oj,ej':U) > 0 then yes else no
  bf_wth-doc.exter_    = if  lookup(bf_wth-doc.ext-doc-type,'ie,ee,we,pc,ps,iy,pz,df,dp,dc,xc':U) > 0 then yes else no
  bf_wth-doc.status_   = 'накл':U
  bf_wth-doc.obj-type  = parobj-type
  bf_wth-doc.obj-code  = parobj-code
  bf_wth-doc.creid     = v-cntxt-userid
  bf_wth-doc.credate   = v-date32
.
if bf_wth-doc.doc-type = 'инв':U or lookup(bf_wth-doc.ext-doc-type, 'we,dc,dp,df':U) > 0
   or bf_wth-doc.doc-type = 'декл':U then do:
  assign
    bf_wth-doc.cli-type  = 'орг':U
    bf_wth-doc.cli-code  = parhost-code
    .
end.
else if bf_wth-doc.ext-doc-type = 'ps':U then do:
  assign
  bf_wth-doc.cli-type  = parobj-type
  bf_wth-doc.cli-code  = parobj-code
  .
end.
else if bf_wth-doc.inter_  = yes
then do:
  assign
  bf_wth-doc.cli-type  = parobj-type
  bf_wth-doc.cli-code  = parobj-code
  .
end.
else if bf_wth-doc.exter_  = yes
then do:
  assign
  bf_wth-doc.cli-type  =  (if parcli-type <> "" then parcli-type else 'орг':U)
  bf_wth-doc.cli-code  =  (if parcli-code <> 0 then parcli-code else 0)
  .
end.
else assign
    bf_wth-doc.cli-type  = parobj-type
    bf_wth-doc.cli-code  = 0
.
      ASSIGN
      bf_wth-doc.shift-date = s-date
      bf_wth-doc.shift-num  = s-num
      bf_wth-doc.shift-name = s-name
      bf_wth-doc.doc-date   = f-date
      bf_wth-doc.auto-fill = parauto-fill
      v-doc-rec = recid(bf_wth-doc)
      .
      if parauto-fill = yes and lookup(parext-type, 'ie,ii,ij,fj,pj,ip,ff,pc,ps,pz,ci':U) > 0 and
        not (par-mode = 'ПРОСМОТР':U) then do:
        assign
        locked-inter_ = yes
        .
      end.
    END.
end.
else do:
  if par-mode = 'ПРОСМОТР':U then do:
    FIND FIRST bf_wth-doc NO-LOCK WHERE
                recid(bf_wth-doc) = p-doc-rec.
  end.
  ELSE do:
    DO TRANSACTION
      ON ERROR UNDO, RETURN ERROR:
      FIND FIRST bf_wth-doc EXCLUSIVE-LOCK WHERE
                 recid(bf_wth-doc) = p-doc-rec.
    END.
  END.
  IF NOT AVAIL bf_wth-doc then
  return error.
  v-doc-rec = p-doc-rec.
  if bf_wth-doc.status_ = 'факт':U and par-mode <> 'ПРОСМОТР':U then do:
     message "Документ движения МЦ с N" bf_wth-doc.doc-code  "имеет статус" bf_wth-doc.status_ SKIP
                      "Изменения не допускаются"
        view-as alert-box error.
        return error.
    end.
  create tt-wth-doc.
  buffer-copy bf_wth-doc to tt-wth-doc.
    FIND FIRST buf_wth-line No-LOCK where
               BUF_WTH-LINE.DOC-CODE = TT-WTH-DOC.doc-code nO-ERROR.
    if avail buf_wth-line then do:
      for-current-w-p-code =  buf_wth-line.w-p-code.
      for-out-w-p-code =  buf_wth-line.out-code.
    end.
    CASE tt-wth-doc.source-type:
      when 'док.МЦ':U then do:
        FIND FIRST bind_wth-doc NO-LOCK WHERE
                   bind_wth-doc.doc-code = tt-wth-doc.source-ref NO-ERROR.
      end.
      when 'касса':U then do:
        FIND FIRST bind_inkas NO-LOCK WHERE
                   bind_inkas.inkas-code = tt-wth-doc.source-ref NO-ERROR.
      end.
    END CASE.
    IF (tt-wth-doc.source-type = 'док.МЦ':U and AVAIL bind_wth-doc) OR
       (tt-wth-doc.source-type = 'касса':U and AVAIL bind_inkas)
       THEN DO:
      ASSIGN
      B-Bind:TOOLTIP
      IN FRAME Dialog-Frame = "Связан с " + tt-wth-doc.source-type + chr(32) + tt-wth-doc.source-ref.
    END.
    ELSE DO:
      ASSIGN
      B-Bind:TOOLTIP
      IN FRAME Dialog-Frame = "":U.
    END.
end.
if tt-wth-doc.auto-fill = yes and par-mode <> 'ПРОСМОТР':U then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run gbl/lock-prc.p
    (input 'awth':U
    ,input parobj-code
    ,input 0
    ,input 0
    ,input parobj-type
    ,input ""
    ,input ""
    ,input (
             "Код объекта" + ",,," +
             "Тип объекта" +  ",,,Формирование автоматических документов МЦ"
           )
    ,input true
    ,buffer auto-wth-doc-lock_batchprocess
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент уже производится формирование автоматических документов МЦ" skip
      view-as alert-box error .
    undo, return error .
  end.
end.
END PROCEDURE.
PROCEDURE local-psn-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE v-ref-rec AS RECID NO-UNDO.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "operator" and p-action = "ret-mouse" then do:
  define variable v-ref-rec34   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame Dialog-Frame tt-wth-doc.operator <> ""
       and input frame Dialog-Frame tt-wth-doc.operator <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec34 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.operator
            cli-buf.obj-name @ operator-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.operator.
  end.
  else display ? @ tt-wth-doc.operator
               ? @ operator-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.operator cli-buf.obj-name @ operator-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.operator ? @ operator-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "operator" and p-action = "button" then do:
  define variable v-ref-rec35   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec35 = ( if available cli-buf then recid( cli-buf ) else ? ).
  v-ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec35 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.operator
            cli-buf.obj-name @ operator-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.operator.
  end.
  else display ? @ tt-wth-doc.operator
               ? @ operator-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.operator cli-buf.obj-name @ operator-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.operator ? @ operator-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "operator" and p-action = "leave" then do:
  define variable v-ref-rec36   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.operator cli-buf.obj-name @ operator-name with frame Dialog-Frame.
          assign frame Dialog-Frame tt-wth-doc.operator.
  end.
  else display ? @ tt-wth-doc.operator ? @ operator-name with frame Dialog-Frame.
end.
if p-man = "deliver" and p-action = "ret-mouse" then do:
  define variable v-ref-rec37   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame Dialog-Frame tt-wth-doc.deliver <> ""
       and input frame Dialog-Frame tt-wth-doc.deliver <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec37 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.deliver
            cli-buf.obj-name @ deliver-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.deliver.
  end.
  else display ? @ tt-wth-doc.deliver
               ? @ deliver-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.deliver cli-buf.obj-name @ deliver-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.deliver ? @ deliver-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "deliver" and p-action = "button" then do:
  define variable v-ref-rec38   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec38 = ( if available cli-buf then recid( cli-buf ) else ? ).
  v-ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec38 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.deliver
            cli-buf.obj-name @ deliver-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.deliver.
  end.
  else display ? @ tt-wth-doc.deliver
               ? @ deliver-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.deliver cli-buf.obj-name @ deliver-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.deliver ? @ deliver-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "deliver" and p-action = "leave" then do:
  define variable v-ref-rec39   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.deliver cli-buf.obj-name @ deliver-name with frame Dialog-Frame.
          assign frame Dialog-Frame tt-wth-doc.deliver.
  end.
  else display ? @ tt-wth-doc.deliver ? @ deliver-name with frame Dialog-Frame.
end.
if p-man = "receiver" and p-action = "ret-mouse" then do:
  define variable v-ref-rec40   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame Dialog-Frame tt-wth-doc.receiver <> ""
       and input frame Dialog-Frame tt-wth-doc.receiver <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec40 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.receiver
            cli-buf.obj-name @ receiver-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.receiver.
  end.
  else display ? @ tt-wth-doc.receiver
               ? @ receiver-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.receiver cli-buf.obj-name @ receiver-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.receiver ? @ receiver-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "receiver" and p-action = "button" then do:
  define variable v-ref-rec41   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec41 = ( if available cli-buf then recid( cli-buf ) else ? ).
  v-ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec41 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-wth-doc.receiver
            cli-buf.obj-name @ receiver-name with frame Dialog-Frame.
    assign frame Dialog-Frame tt-wth-doc.receiver.
  end.
  else display ? @ tt-wth-doc.receiver
               ? @ receiver-name with frame Dialog-Frame.
  apply "entry" to  b-exit in frame Dialog-Frame.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.receiver cli-buf.obj-name @ receiver-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.receiver ? @ receiver-name with frame Dialog-Frame.
      return no-apply.
end.
if p-man = "receiver" and p-action = "leave" then do:
  define variable v-ref-rec42   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.receiver cli-buf.obj-name @ receiver-name with frame Dialog-Frame.
          assign frame Dialog-Frame tt-wth-doc.receiver.
  end.
  else display ? @ tt-wth-doc.receiver ? @ receiver-name with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE lock-proc :
DEFINE INPUT PARAMETER lock-doc as logical no-undo.
if lock-doc then do:
    DISABLE
    b-cli
    tt-wth-doc.cli-type
    tt-wth-doc.cli-code
    B-current  when for-current-w-p-code > 0
    B-out
    for-current-w-p-code when for-current-w-p-code > 0
    for-out-w-p-code
    with frame Dialog-Frame
    .
    enable
    b-chg when par-mode <> 'ПРОСМОТР':U
    b-del when par-mode <> 'ПРОСМОТР':U and not tt-wth-doc.auto-fill AND not (lookup(tt-wth-doc.ext-doc-type, 'ie,ii,ij,fj,pj,ip,ff,pc,ps,pz,ci':U) > 0 and not tt-wth-doc.exter_)
    b-lookup
    B-current when for-current-w-p-code = 0 and tt-wth-doc.ext-doc-type <> 'dc':U
    for-current-w-p-code when for-current-w-p-code = 0 and tt-wth-doc.ext-doc-type <> 'dc':U
    with frame Dialog-Frame
    .
end.
else do:
    ENABLE
    b-cli when (not tt-wth-doc.inter_ and not locked-cli)
    tt-wth-doc.cli-type when (not tt-wth-doc.inter_  and not locked-cli)
    tt-wth-doc.cli-code when (not tt-wth-doc.inter_  and not locked-cli)
    B-current  when  tt-wth-doc.ext-doc-type <> 'dc':U
    for-current-w-p-code  when  tt-wth-doc.ext-doc-type <> 'dc':U
    with frame Dialog-Frame
    .
    disable
    b-chg
    b-del
    b-lookup
      with frame Dialog-Frame
    .
    run control-out.
end.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-place-name-h AS HANDLE NO-UNDO.
ASSIGN
v-place-name-h = browse br-lines:FIRST-COLUMN
.
DO WHILE VALID-HANDLE(v-place-name-h):
  IF v-place-name-h:label = "Название места" THEN DO:
      LEAVE.
  END.
  v-place-name-h = v-place-name-h:NEXT-COLUMN
  .
END.
IF lookup(tt-wth-doc.ext-doc-type , 'ci,ce':U) = 0 THEN DO:
    ASSIGN
    v-place-name-h:VISIBLE = NO
    .
END.
assign
tt-wth-doc.sum-gds-rubl:label in frame Dialog-Frame = "Сумма по тов.(рубл).".
if lookup(tt-wth-doc.ext-doc-type, 'we,dc,dp,df':U) > 0
or tt-wth-doc.doc-type = 'декл':U
or tt-wth-doc.inter_ = yes
 then
    assign
    locked-cli = yes
    .
else     locked-cli = no.
if (tt-wth-doc.doc-type = 'при':U and tt-wth-doc.inter_ = no and  not tt-wth-doc.exter_ ) then
assign v-view-fact = yes.
else v-view-fact = no.
buf_wth-line.creid:READ-ONLY IN BROWSE BR-lines = YES.
  define variable v-ref-rec43   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-wth-doc.operator with frame Dialog-Frame.
  find cli-buf no-lock where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.operator
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.operator cli-buf.obj-name @ operator-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.operator ? @ operator-name with frame Dialog-Frame.
  define variable v-ref-rec44   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-wth-doc.deliver with frame Dialog-Frame.
  find cli-buf no-lock where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.deliver
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.deliver cli-buf.obj-name @ deliver-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.deliver ? @ deliver-name with frame Dialog-Frame.
  define variable v-ref-rec45   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-wth-doc.receiver with frame Dialog-Frame.
  find cli-buf no-lock where cli-buf.obj-code = input frame Dialog-Frame tt-wth-doc.receiver
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-wth-doc.receiver cli-buf.obj-name @ receiver-name with frame Dialog-Frame.
  end.
  else display ? @ tt-wth-doc.receiver ? @ receiver-name with frame Dialog-Frame.
if tt-wth-doc.ext-doc-type = 'pz':U then do:
  tt-wth-doc.deliver:label = 'Получил'.
  tt-wth-doc.receiver:label = 'Возвратил'.
end.
if tt-wth-doc.ext-doc-type = 'ie':U then do:
  tt-wth-doc.deliver:label = 'Получил'.
  tt-wth-doc.receiver:label = 'Отпустил'.
end.
if tt-wth-doc.doc-type = 'спи':U then do:
  tt-wth-doc.operator:label = 'Председ.'.
  tt-wth-doc.deliver:label = 'Комиссия'.
  tt-wth-doc.receiver:label = 'Комиссия'.
end.
    DISPLAY
    tt-wth-doc.fact-date
    tt-wth-doc.doc-code
    tt-wth-doc.doc-date
    tt-wth-doc.shift-num
    shift-name-no-err(buffer tt-wth-doc) @ tt-wth-doc.shift-name
    tt-wth-doc.shift-date
    tt-wth-doc.obj-code
    tt-wth-doc.obj-type
    tt-wth-doc.cli-code
    tt-wth-doc.cli-type
    tt-wth-doc.fact-sum  when v-view-fact
    tt-wth-doc.doc-sum
    tt-wth-doc.operator
    tt-wth-doc.deliver
    tt-wth-doc.receiver
    tt-wth-doc.sum-gds-rubl when lookup(tt-wth-doc.ext-doc-type,'ij,ei,rj,ej,we,ci,ce,iy,de':u) = 0
    tt-wth-doc.sum-gds-base when lookup(tt-wth-doc.ext-doc-type,'ij,ei,rj,ej,we,ci,ce,iy,de':u) = 0
    for-out-w-p-code
    for-current-w-p-code  when  lookup(tt-wth-doc.ext-doc-type, 'dc':U) = 0
                                and
                                lookup(tt-wth-doc.ext-doc-type, 'ci,ce':U) = 0
  WITH FRAME Dialog-Frame.
  APPLY "VALUE-CHANGED":U TO tt-wth-doc.cli-type IN FRAME Dialog-Frame.
  APPLY "VALUE-CHANGED":U TO tt-wth-doc.obj-type IN FRAME Dialog-Frame.
  IF lookup(tt-wth-doc.ext-doc-type, 'dc':U) = 0
  and lookup(tt-wth-doc.ext-doc-type, 'ci,ce':U) = 0
  then do:
  APPLY "LEAVE":U TO for-current-w-p-code IN FRAME Dialog-Frame.
  END.
  APPLY "LEAVE":U TO for-out-w-p-code IN FRAME Dialog-Frame.
  if lookup(tt-wth-doc.ext-doc-type, "ie,ee,pz,xc") > 0
  OR lookup(tt-wth-doc.ext-doc-type, "ie,ee,pz") > 0 then
  run proc-init-attr no-error.
  IF par-mode = 'ДОБАВЛЕНИЕ':U OR
        par-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
      IF par-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
        ENABLE
        tt-wth-doc.doc-date
        b-quit
        WITH FRAME Dialog-Frame.
      END.
      ELSE DO:
        IF tt-wth-doc.status_ = 'накл':U      THEN DO:
           ENABLE
            tt-wth-doc.doc-date
            b-cli when (NOT tt-wth-doc.inter_ AND Not locked-cli)
                  WITH FRAME Dialog-Frame.
            HIDE
            b-quit
            tt-wth-doc.fact-date IN FRAME Dialog-Frame
            .
        END.
        ELSE IF tt-wth-doc.status_ = 'разрешен':U THEN DO:
          ENABLE
          tt-wth-doc.fact-sum  when v-view-fact
          b-chg when NOT tt-wth-doc.auto-fill
          WITH FRAME Dialog-Frame.
          assign
          locked-out = yes
          locked-current = yes
          .
        END.
      END.
      ENABLE
      b-add  when NOT tt-wth-doc.auto-fill AND not (lookup(tt-wth-doc.ext-doc-type, 'ie,ii,ij,fj,pj,ip,ff,pc,ps,pz,ci':U) > 0 and not tt-wth-doc.exter_)
      b-del  when not tt-wth-doc.auto-fill AND not (lookup(tt-wth-doc.ext-doc-type, 'ie,ii,ij,fj,pj,ip,ff,pc,ps,pz,ci':U) > 0 and not tt-wth-doc.exter_)
      b-bar  when NOT tt-wth-doc.auto-fill AND not (lookup(tt-wth-doc.ext-doc-type, 'ie,ii,ij,fj,pj,ip,ff,pc,ps,pz,ci':U) > 0 and not tt-wth-doc.exter_) and lookup(tt-wth-doc.ext-doc-type,'ij,ei,rj,ej,we,ci,ce,iy,de':u) = 0 and  tt-wth-doc.ext-doc-type <> 'xc':U
      b-barRange  when NOT tt-wth-doc.auto-fill AND not (lookup(tt-wth-doc.ext-doc-type, 'ie,ii,ij,fj,pj,ip,ff,pc,ps,pz,ci':U) > 0 and not tt-wth-doc.exter_) and lookup(tt-wth-doc.ext-doc-type,'ij,ei,rj,ej,we,ci,ce,iy,de':u) = 0 and  tt-wth-doc.ext-doc-type <> 'xc':U
      tt-wth-doc.cli-type when not locked-cli
      tt-wth-doc.cli-code when not locked-cli
      b-cli when not locked-cli
      tt-wth-doc.operator
      tt-wth-doc.deliver
      tt-wth-doc.receiver   when not lookup(tt-wth-doc.ext-doc-type, "ie,ee,pz,xc") > 0
      b-operator
      B-deliver
      B-receiver
      B-exit
      b-quit
      b-lookup
      b-bind when NOT (tt-wth-doc.auto-fill)
      b-allZone when (parext-type = 'ee':U  or  parext-type = 'ep':U or parext-type = 'pz':U or parext-type = 'dp':U or parext-type = 'df':U ) and not tt-wth-doc.auto-fill
            B-shcfact when tt-wth-doc.doc-type = 'рас':U and tt-wth-doc.exter_
      WITH FRAME Dialog-Frame.
      if lookup(tt-wth-doc.ext-doc-type, "ie,ee,pz,xc") > 0 then
        enable f-atrReceiver f-atrproxy
        WITH FRAME Dialog-Frame.
        f-atrReceiver:move-to-top().
      if lookup(tt-wth-doc.ext-doc-type, "ie,ee,pz") > 0 then  do:
        ENABLE  f-atrDSF f-atrNSF f-atrPaydoc
                 b-shcfact
        WITH FRAME Dialog-Frame.
      end.
      HIDE
      b-prev IN FRAME Dialog-Frame
      B-Next IN FRAME Dialog-Frame
      .
          enable tt-wth-doc.fact-date
          with frame Dialog-Frame.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  tt-wth-doc.obj-type
  ,input  tt-wth-doc.obj-code
  ,input  'shift-on=request'
  ,output glog
  ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при запуске процедуры objat" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            return error.
          end.
          if glog then do:
            display tt-wth-doc.shift-date tt-wth-doc.shift-num tt-wth-doc.shift-name r-sht with frame Dialog-Frame.
            if tt-wth-doc.auto-fill = no then
            enable tt-wth-doc.shift-date tt-wth-doc.shift-num tt-wth-doc.shift-name
                   r-sht
            with frame Dialog-Frame.
          end.
    END.
    ELSE IF par-mode = 'ПРОСМОТР':U  THEN DO:
      assign
      b-quit:label = "&Выход"
      b-quit:col = 1
      .
      ENABLE
      B-Prev
      B-Next
      b-quit
      WITH FRAME Dialog-Frame.
      HIDE
      b-exit
      b-current   IN FRAME Dialog-Frame
      B-out   IN FRAME Dialog-Frame
      B-cli   IN FRAME Dialog-Frame
      B-operator IN FRAME Dialog-Frame
      B-Deliver  IN FRAME Dialog-Frame
      B-Receiver IN FRAME Dialog-Frame
      .
      assign
      locked-out = yes
      locked-current = yes
      .
      if lookup(tt-wth-doc.ext-doc-type, "ie,ee,pz,xc") > 0 then
        view f-atrReceiver f-atrproxy
        in FRAME Dialog-Frame.
        f-atrReceiver:move-to-top().
      if lookup(tt-wth-doc.ext-doc-type, "ie,ee,pz") > 0 then  do:
        view  f-atrDSF f-atrNSF f-atrPaydoc
        in FRAME Dialog-Frame.
      end.
    END.
    ENABLE
    b-help
    br-lines
    b-lookup
    b-hist when par-mode <> 'ДОБАВЛЕНИЕ':U
    b-chk when tt-wth-doc.auto-fill  and  (lookup(tt-wth-doc.ext-doc-type,'ii,fj,jj,pj,oj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,xc':U) >  0
                                           or
                                           lookup(tt-wth-doc.ext-doc-type, 'ej,ee,ij,iy,de':U) >  0
                                           )
    WITH FRAME Dialog-Frame.
    if lookup(tt-wth-doc.ext-doc-type,'ij,ei,rj,ej,we,ci,ce,iy,de':u) > 0 then do:
      buf_wth-line.sum-gds-base:visible in browse br-lines = no.
      buf_wth-line.sum-gds-rubl:visible in browse br-lines = no.
    end.
    else do:
       view
      tt-wth-doc.sum-gds-base
      tt-wth-doc.sum-gds-rubl
      in frame  Dialog-Frame.
    end.
    if  v-view-fact  = yes then
    view
    tt-wth-doc.fact-sum
    in frame Dialog-Frame.
    if lookup(tt-wth-doc.ext-doc-type, 'de':U) > 0 then do:
      HIDE
      tt-wth-doc.fact-sum
      IN FRAME Dialog-Frame.
      assign
      buf_wth-line.fact-sum:visible in browse br-lines = no.
    end.
    if lookup(tt-wth-doc.ext-doc-type , 'dc':U) > 0
    or lookup(tt-wth-doc.ext-doc-type , 'ci,ce':U) > 0
    then do:
      hide
      for-current-w-p-code
      for-current-w-p-name
      b-current
      IN FRAME Dialog-Frame.
    end.
    OPEN QUERY BR-lines FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK,              EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK.
    APPLY "ENTRY":U TO br-lines IN FRAME Dialog-Frame.
   run control-line in this-procedure ( output lock-doc).
   run lock-proc in this-procedure ( input lock-doc).
   parext-type-name = ENTRY(LOOKUP(tt-wth-doc.ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u) no-error.
   ASSIGN
    FRAME Dialog-Frame :TITLE = substitute("Документ № &1 движения материальных ценностей - &2"
                                            ,tt-wth-doc.doc-code
                                             , CAPS(parext-type-name) ).
  VIEW FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-allZone :
define input parameter v_rid-list as char no-undo.
define input parameter p-zone as character no-undo.
define variable v-ii    as integer      no-undo.
define variable v-is-parts  as logical      no-undo.
define variable parline-rec as recid no-undo.
define variable v-count    as integer      no-undo.
empty temp-table tt-wth-line.
v-count = 0.
do transaction on error undo, return error return-value
               on quit undo, return
               on stop undo, return :
  do v-ii = 1 to num-entries(v_rid-list, chr(44))
  on error undo, next:
    v-is-parts = no.
    empty temp-table tt-wth-parts.
    empty temp-table tt-par-dtl.
    find first buf_wth no-lock where recid(buf_wth) = int(entry(v-ii,v_rid-list,chr(44))) .
    if can-find(first buf_wth-line where buf_wth-line.wth-code = buf_wth.wth-code
                                     and buf_wth-line.doc-code = tt-wth-doc.doc-code
               )
    then do:
      message substitute('Для МЦ &1 (код &2) уже есть линия в документе.',buf_wth.wth-name,buf_wth.wth-code) view-as alert-box.
      next.
    end.
    run waitfram-show in this-procedure ( input substitute("Создание линии для МЦ &1",buf_wth.wth-name) ).
       for each buf_wth-parts share-lock where
             buf_wth-parts.out-code = p-zone
         and buf_wth-parts.obj-code = tt-wth-doc.obj-code
         and buf_wth-parts.obj-type = tt-wth-doc.obj-type
         and  buf_wth-parts.wth-code = buf_wth.wth-code
         and (if p-zone = 'cli-zone':U then (buf_wth-parts.cli-code = tt-wth-doc.cli-code
                                       and buf_wth-parts.cli-type = tt-wth-doc.cli-type)
              else buf_wth-parts.w-p-code = FOR-CURRENT-W-P-CODE
              )
        use-index  out-code
         :
         v-is-parts = yes.
         create tt-wth-parts.
         buffer-copy buf_wth-parts to tt-wth-parts
         assign tt-wth-parts.out-code = tt-wth-doc.doc-code
                tt-wth-parts.ext-doc-type = tt-wth-doc.ext-doc-type
                tt-wth-parts.shift-date = tt-wth-doc.shift-date
                tt-wth-parts.shift-num = tt-wth-doc.shift-num
                tt-wth-parts.obj-type = tt-wth-doc.obj-type
                tt-wth-parts.obj-code = tt-wth-doc.obj-code
                tt-wth-parts.w-p-code = FOR-CURRENT-W-P-CODE
         .
    end.
    if v-is-parts = no
    then next.
    run trg/wthrspt.p (input table tt-wth-parts
                      ,input no ) no-error.
    if error-status:error then do:
      message return-value + error-status:get-message(1) view-as alert-box error.
      undo, next.
    end.
    for each buf_wth-par no-lock where
             buf_wth-par.wth-code = buf_wth.wth-code
        :
        create tt-par-dtl.
        buffer-copy buf_wth-par using wth-code
                                      par-code
                                      par-rate
                                      par-val
                 to tt-par-dtl.
        assign
               tt-par-dtl.w-p-code = FOR-CURRENT-W-P-CODE
               tt-par-dtl.doc-code = tt-wth-doc.doc-code
        .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
tt-par-dtl.q-ty-doc  = 0
tt-par-dtl.q-ty-fact = 0
tt-par-dtl.doc-sum   = 0
tt-par-dtl.fact-sum  = 0
tt-par-dtl.sum-gds-rubl = 0
tt-par-dtl.sum-gds-base = 0
.
for each buf_wth-parts no-lock where buf_wth-parts.w-p-code = tt-par-dtl.w-p-code
                       and buf_wth-parts.wth-code = tt-par-dtl.wth-code
                       and buf_wth-parts.par-code = tt-par-dtl.par-code
                       and buf_wth-parts.out-code = tt-par-dtl.doc-code
                       and buf_wth-parts.stts = 0 :
   assign
  tt-par-dtl.q-ty-doc     =  tt-par-dtl.q-ty-doc  + buf_wth-parts.qnty-doc
  tt-par-dtl.q-ty-fact    =  tt-par-dtl.q-ty-fact + buf_wth-parts.fact-qnty
  tt-par-dtl.sum-gds-rubl =  tt-par-dtl.sum-gds-rubl + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
  tt-par-dtl.sum-gds-base =  tt-par-dtl.sum-gds-base + buf_wth-parts.price-base * buf_wth-parts.fact-qnty
  no-error
  .
end.
assign
  tt-par-dtl.doc-sum     =  tt-par-dtl.q-ty-doc  * tt-par-dtl.par-rate
  tt-par-dtl.fact-sum    =  tt-par-dtl.q-ty-fact * tt-par-dtl.par-rate
  no-error
  .
    end.
    parline-rec = ?.
    create tt-wth-line.
    assign tt-wth-line.wth-code = buf_wth.wth-code
           tt-wth-line.doc-code = tt-wth-doc.doc-code
           tt-wth-line.w-p-code =   FOR-CURRENT-W-P-CODE
    .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
tt-wth-line.doc-sum   = 0
tt-wth-line.fact-sum  = 0
tt-wth-line.sum-gds-rubl = 0
tt-wth-line.sum-gds-base = 0
tt-wth-line.price-rubl   = 0
tt-wth-line.price-base   = 0.
for each tt-par-dtl no-lock where tt-par-dtl.w-p-code = tt-wth-line.w-p-code
                       and tt-par-dtl.wth-code = tt-wth-line.wth-code
                       and tt-par-dtl.doc-code = tt-wth-line.doc-code
                       :
  assign
  tt-wth-line.doc-sum      =  tt-wth-line.doc-sum  + tt-par-dtl.doc-sum
  tt-wth-line.fact-sum     =  tt-wth-line.fact-sum + tt-par-dtl.fact-sum
  tt-wth-line.sum-gds-rubl =  tt-wth-line.sum-gds-rubl + tt-par-dtl.sum-gds-rubl
  tt-wth-line.sum-gds-base =  tt-wth-line.sum-gds-base + tt-par-dtl.sum-gds-base
  .
end.
assign
  tt-wth-line.price-rubl  =  tt-wth-line.sum-gds-rubl / tt-wth-line.fact-sum
  tt-wth-line.price-base  =  tt-wth-line.sum-gds-base / tt-wth-line.fact-sum
  .
    run str/wth-lnc1.p (
                      input-output parline-rec
                      ,'ДОБАВЛЕНИЕ':U
                      ,input no
                      ,input tt-wth-doc.doc-code
                      ,input tt-wth-line.wth-code
                      ,input FOR-CURRENT-W-P-CODE
                      ,input FOR-OUT-W-P-CODE
                      ,input tt-wth-line.doc-sum
                      ,input tt-wth-line.fact-sum
                      ,input table tt-par-dtl
                      ,input no
                      ,input tt-wth-doc.ext-doc-type
                      ,input tt-wth-line.sum-gds-rubl
                      ,input tt-wth-line.sum-gds-base
                      ) no-error.
    IF ERROR-STATUS:ERROR THEN DO:
      message return-value + error-status:get-message(1) view-as alert-box.
      undo, next.
    end.
    v-count = v-count + 1.
  end.
  assign
  tt-wth-doc.doc-sum = bf_wth-doc.doc-sum
  tt-wth-doc.fact-sum = bf_wth-doc.fact-sum
  tt-wth-doc.sum-gds-rubl = bf_wth-doc.sum-gds-rubl
  tt-wth-doc.sum-gds-base = bf_wth-doc.sum-gds-base
  .
  DISPLAY
  tt-wth-doc.doc-sum
  tt-wth-doc.sum-gds-rubl
  tt-wth-doc.sum-gds-base
  tt-wth-doc.fact-sum when lookup(tt-wth-doc.ext-doc-type, 'de':U) = 0
  with frame Dialog-Frame .
  run control-line in this-procedure ( output lock-doc).
  run lock-proc in this-procedure (input lock-doc).
  OPEN QUERY BR-lines FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK,              EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK.
  reposition br-lines to recid parline-rec no-error.
  run waitfram-hide in this-procedure .
  message substitute('Добавлено &1 линий.',v-count) view-as alert-box.
  apply "entry" to br-lines.
end.
END PROCEDURE.
PROCEDURE proc-b-add :
DEFINE VARIABLE loc-ref-list as character no-undo .
DEFINE VARIABLE valid-chk-type-list as character no-undo .
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE ii-ok as integer no-undo .
define variable v-line-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
define buffer what_chk-doc  for ub.chk-doc .
define buffer buf_chk-doc  for ub.chk-doc .
run proc-save-doc in this-procedure ( input no) No-ERROR.
if error-status:error
or return-value = 'error'
then return 'error'.
assign
v-doc-rec = recid(bf_wth-doc)
v-line-rec = ?
frame Dialog-Frame FOR-CURRENT-W-P-CODE
FOR-OUT-W-P-CODE
.
CASE tt-wth-doc.auto-fill:
  when no then do:
    run str/wth-inca.w ( input parparentproc
                   ,INPUT parhost-code
                   ,INPUT parobj-type
                   ,INPUT parobj-code
                   ,INPUT 'ДОБАВЛЕНИЕ':U
                   ,input v-doc-rec
                   ,input for-current-w-p-code
                   ,input for-out-w-p-code
                   ,INPUT tt-wth-doc.ext-doc-type
                   ,input-output v-LINE-REC ) no-error.
    if error-status:error then do:
      message error-status:get-message(1) return-value view-as alert-box.
      run control-line in this-procedure ( output lock-doc).
      run lock-proc in this-procedure (input lock-doc).
      return 'error'.
    end.
  end.
  when yes then do:
    FIND FIRST what_chk-doc No-LOCK WHERE
               what_chk-doc.out-code = tt-wth-doc.doc-code No-ERROR.
    if available what_chk-doc then do:
      assign
      valid-chk-type-list = string(what_chk-doc.chk-type).
      run str/chk-docs.w (
                     input parparentproc
                    ,input 'b-sel,b-mark':U
                    ,input 'free':U
                    ,input ?
                    ,input parobj-type
                    ,input parobj-code
                    ,input what_chk-doc.chk-type
                    ,input '':U
                    ,input 0
                    ,input ?
                    ,input ?
                    ,input 0
                    ,output loc-ref-list) no-error.
      if error-status:error then return 'error'.
    end.
    else do:
        IF lookup(tt-wth-doc.ext-doc-type, 'ee,ei,ej,jj,oj,ce,ef,ep':U) > 0 then do:
          valid-chk-type-list = '5':U + chr(44) + '2':U.
        end.
        IF lookup(tt-wth-doc.ext-doc-type, 'ie,ii,ij,fj,pj,ip,ff,pc,ps,pz,ci':U) > 0 then do:
          valid-chk-type-list = '3':U.
        end.
            run str/chk-docs.w (
                     input parparentproc
                    ,input 'b-sel,b-mark':U
                    ,input 'free':U
                    ,input ?
                    ,input parobj-type
                    ,input parobj-code
                    ,input 0
                    ,input '':U
                    ,input 0
                    ,input ?
                    ,input ?
                    ,input 0
                    ,output loc-ref-list) no-error.
      if error-status:error then return 'error'.
    end.
    if loc-ref-list = "":U then return.
  _ii:
  DO ii = 1 to num-entries(loc-ref-list):
  find first buf_chk-doc exclusive-lock where
                  recid(buf_chk-doc) = integer(entry(ii, loc-ref-list)) No-ERROR.
      if not avail buf_chk-doc or
        LOOKUP(string(buf_chk-doc.chk-type), valid-chk-type-list) = 0 then NEXT _ii.
      if tt-wth-doc.shift-date = ? then do:
        if buf_chk-doc.shift-date <> tt-wth-doc.doc-date then NEXT _ii.
      end.
      else do:
        if NOT (buf_chk-doc.shift-date = tt-wth-doc.shift-date AND
                buf_chk-doc.shift-num = tt-wth-doc.shift-num) then NEXT _ii.
      end.
      if avail(what_chk-doc) and buf_chk-doc.pay-desk <> what_chk-doc.pay-desk then NEXT _ii.
      run str/inc-wth1.p (
        buffer buf_chk-doc
      ,input 1
      ,input tt-wth-doc.doc-code
      ,input for-current-w-p-code
      ,input for-out-w-p-code
      ,input tt-wth-doc.ext-doc-type
      ,input buf_chk-doc.chk-type
      ,input no
      ) no-error .
      if error-status:error then NEXT _ii.
      ii-ok = ii-ok + 1.
  END.
  if ii - 1 <> ii-ok then do:
    message
    "Из выбранных Вами " (ii - 1 ) "чеков"
    "удалось включить в документ" ii-ok
    view-as alert-box WARNING.
  end.
  end.
END CASE.
RUN control-doc NO-ERROR.
OPEN QUERY BR-lines FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK,              EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK.
reposition br-lines to recid v-line-rec no-error.
apply "entry" to br-lines.
END PROCEDURE.
PROCEDURE proc-b-del :
DEFINE VARIABLE loc-ref-list as character no-undo .
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-ok as integer no-undo.
define variable v-line-rec as recid no-undo .
DEFINE buffer buf_chk-doc for ub.chk-doc .
if not avail buf_wth-line then return no-apply.
  IF tt-wth-doc.status_ <> 'накл':U THEN DO:
    MESSAGE "Документ закрыт - удалять матценности нельзя!"
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
END.
CASE tt-wth-doc.auto-fill:
  when no then do:
    MESSAGE
    "Вы уверены, что хотите удалить строку?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
    IF glog <> YES THEN DO:
      RETURN NO-APPLY.
    END.
    ASSIGN v-line-rec = RECID( buf_wth-line).
    Erase-Block:
    DO ON ERROR UNDO Erase-Block, LEAVE Erase-Block
       ON STOP  UNDO Erase-Block, LEAVE Erase-Block :
      run str/wth-lnc1.p (
                       input-output v-line-rec
                      ,input  'удаление':U
                      ,no
                      ,input buf_wth-line.doc-code
                      ,input buf_wth-line.wth-code
                      ,input buf_wth-line.w-p-code
                      ,input buf_wth-line.out-code
                      ,input 0
                      ,input 0
                      ,input table tt-par-dtl
                      ,input yes
                      ,input tt-wth-doc.ext-doc-type
                      ,input buf_wth-line.sum-gds-rubl
                      ,input buf_wth-line.sum-gds-base
                      ) .
    END.
  end.
  when yes then do:
    run str/chk-docs.w (
                   input parparentproc
                  ,input 'b-sel,b-mark':U
                  ,input 'out-code':U
                  ,input ?
                  ,input parobj-type
                  ,input parobj-code
                  ,input tt-wth-doc.doc-code
                  ,input ''
                  ,input 0
                  ,input ?
                  ,input ?
                  ,input 0
                  ,output loc-ref-list) no-error.
    if error-status:error then return error.
    if loc-ref-list = '':U then return.
     _ii:
  DO ii = 1 to num-entries(loc-ref-list):
  find first buf_chk-doc exclusive-lock where
                  recid(buf_chk-doc) = integer(entry(ii, loc-ref-list)) No-ERROR.
      if not avail buf_chk-doc or
        buf_chk-doc.out-code <> tt-wth-doc.doc-code then NEXT _ii.
      run str/inc-wth1.p (
        buffer buf_chk-doc
      ,input - 1
      ,input tt-wth-doc.doc-code
      ,input 0
      ,input for-out-w-p-code
      ,input tt-wth-doc.ext-doc-type
      ,input buf_chk-doc.chk-type
      ,input no
      ) no-error .
      if error-status:error then NEXT _ii.
      ii-ok = ii-ok + 1.
  END.
  if ii - 1 <> ii-ok then do:
    message
    "Из выбранных Вами " (ii - 1)  "чеков"
    "удалось удалить из документа" ii-ok
    view-as alert-box WARNING.
  end.
  end.
END CASE.
RUN control-doc NO-ERROR.
OPEN QUERY BR-lines FOR EACH buf_wth-line WHERE buf_wth-line.doc-code = tt-wth-doc.doc-code NO-LOCK,              EACH buf_wth WHERE buf_wth.wth-code = buf_wth-line.wth-code NO-LOCK.
END PROCEDURE.
PROCEDURE proc-init-attr :
  define variable v-atrValue    as character no-undo .
  define variable v-atrType     as character no-undo .
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input tt-wth-doc.doc-code ,
                        input 'wthdsf':U ,
                       output v-atrValue ,
                       output v-atrType ) NO-ERROR .
f-atrDSF = date(v-atrValue) NO-ERROR.
v-atrValue = ''.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input tt-wth-doc.doc-code ,
                        input 'wthnsf':U ,
                       output v-atrValue ,
                       output v-atrType ) NO-ERROR .
f-atrNSF = v-atrValue.
v-atrValue = ''.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input tt-wth-doc.doc-code ,
                        input 'wthpaydoc':U ,
                       output v-atrValue ,
                       output v-atrType ) NO-ERROR .
f-atrPaydoc = v-atrValue.
v-atrValue = ''.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input tt-wth-doc.doc-code ,
                        input 'wthproxy':U ,
                       output v-atrValue ,
                       output v-atrType ) NO-ERROR .
f-atrproxy = v-atrValue.
v-atrValue = ''.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input tt-wth-doc.doc-code ,
                        input 'wthreceiver':U ,
                       output v-atrValue ,
                       output v-atrType ) NO-ERROR .
f-atrReceiver = v-atrValue.
DISP f-atrDSF f-atrNSF f-atrPaydoc f-atrReceiver f-atrproxy  f-atrdsf WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-inter__ :
define input parameter loc-inter like ub.wth-doc.inter_ no-undo.
CASE loc-inter :
    when yes then do:
        assign
        tt-wth-doc.cli-type = tt-wth-doc.obj-type
        tt-wth-doc.cli-code = tt-wth-doc.obj-code
        .
        display
        tt-wth-doc.cli-type
        tt-wth-doc.cli-code
        with frame Dialog-Frame.
        disable
        tt-wth-doc.cli-type
        tt-wth-doc.cli-code
        b-cli
        with frame Dialog-Frame.
        assign
        for-out-w-p-code = 0
        .
        enable
        b-out
        for-out-w-p-code
        with frame Dialog-Frame.
        display
        '':U @ for-out-w-p-name
        with frame Dialog-Frame.
        APPLY "VALUE-CHANGED" to tt-wth-doc.cli-type.
                if available out-place then
                display
                out-place.w-p-code @ for-out-w-p-code
                out-place.w-p-name @ for-out-w-p-name
                with frame Dialog-Frame.
    end.
    when no then do:
      release out-place.
      if not locked-cli  then do:
        assign
        tt-wth-doc.cli-type = 'орг':U
        tt-wth-doc.cli-code = 0
        .
        display
        tt-wth-doc.cli-type
        tt-wth-doc.cli-code
        '':U @ tt-wth-doc.cli-name
        with frame Dialog-Frame.
      end.
      ENABLE
      tt-wth-doc.cli-type when (lock-doc = no and locked-cli = no)
      tt-wth-doc.cli-code when (lock-doc = no and locked-cli = no)
      b-cli when (lock-doc = no and locked-cli = no)
      with frame Dialog-Frame.
      assign
      for-out-w-p-code = 0
      for-out-w-p-name = '':U
      .
      hide
      for-out-w-p-code
      b-out
      for-out-w-p-name
      in frame Dialog-Frame.
    end.
end CASE.
END PROCEDURE.
PROCEDURE proc-save-doc :
 define input parameter parlines-exist as logical no-undo .
 define variable v-doc-rec as recid no-undo .
 define variable varcli-name as character no-undo .
 IF par-mode = 'ПРОСМОТР':U THEN DO:
    RETURN NO-APPLY.
 END.
 if tt-wth-doc.ext-doc-type <> 'dc':U and not avail current-place then do:
  message "Не определено место хранения МЦ"
  view-as alert-box error.
  APPLY "ENTRY":U TO for-current-w-p-code IN FRAME Dialog-Frame.
  return error.
 end.
 assign
 frame Dialog-Frame
 tt-wth-doc.doc-date
 tt-wth-doc.cli-type
 tt-wth-doc.cli-code
 tt-wth-doc.operator
 tt-wth-doc.deliver
 tt-wth-doc.receiver
 tt-wth-doc.fact-date
 tt-wth-doc.shift-date
 tt-wth-doc.shift-num
 tt-wth-doc.shift-name
 tt-wth-doc.doc-sum when not tt-wth-doc.auto-fill
 tt-wth-doc.fact-sum when not tt-wth-doc.auto-fill
.
if      tt-wth-doc.cli-type = tt-wth-doc.obj-type
    and tt-wth-doc.cli-code = tt-wth-doc.obj-code
    and for-current-w-p-code:screen-value > '':U
    and for-current-w-p-code:screen-value = for-out-w-p-code:screen-value
then do:
  message "Нельзя перемещать МЦ в место их хранения."
  view-as alert-box error.
  APPLY "ENTRY":U TO for-out-w-p-code IN FRAME Dialog-Frame.
  return error.
end.
run trg/wth-inc2.p (
                 input no
                ,input tt-wth-doc.doc-code
                ,input tt-wth-doc.host-code
                ,input tt-wth-doc.obj-type
                ,input tt-wth-doc.obj-code
                ,input tt-wth-doc.cli-type
                ,input tt-wth-doc.cli-code
                ,input tt-wth-doc.operator
                ,input tt-wth-doc.deliver
                ,input tt-wth-doc.receiver
                ,input tt-wth-doc.doc-type
                ,input tt-wth-doc.auto-fill
                ,input tt-wth-doc.exter_
                ,input tt-wth-doc.inter_
                ,input tt-wth-doc.source-ref
                ,input tt-wth-doc.source-type
                ,input tt-wth-doc.borned
                ,input parlines-exist
                ,input tt-wth-doc.ext-doc-type
                ,output varcli-name) no-error.
if error-status:error then do:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      return 'error'.
    end.
    hh = hh:next-sibling.
  end.
end.
  return error.
end.
 v-doc-rec = recid(bf_wth-doc).
run waitfram-show in this-procedure ( input "Сохранение шапки документа..." ).
 run str/wth-inc1.p (
                  input no
                 ,input-output v-doc-rec
                 ,input        'ИЗМЕНЕНИЕ':U
                 ,input tt-wth-doc.doc-code
                 ,input tt-wth-doc.host-code
                 ,input tt-wth-doc.obj-type
                 ,input tt-wth-doc.obj-code
                 ,input tt-wth-doc.cli-type
                 ,input tt-wth-doc.cli-code
                 ,input tt-wth-doc.doc-date
                 ,input tt-wth-doc.fact-date
                 ,input tt-wth-doc.shift-date
                 ,input tt-wth-doc.shift-num
                 ,input tt-wth-doc.shift-name
                 ,input tt-wth-doc.operator
                 ,input tt-wth-doc.deliver
                 ,input tt-wth-doc.receiver
                 ,input tt-wth-doc.doc-type
                 ,input tt-wth-doc.auto-fill
                 ,input tt-wth-doc.exter_
                 ,input tt-wth-doc.inter_
                 ,input tt-wth-doc.source-ref
                 ,input tt-wth-doc.source-type
                 ,input tt-wth-doc.borned
                 ,input tt-wth-doc.doc-sum
                 ,input tt-wth-doc.fact-sum
                 ,input tt-wth-doc.PS
                 ,input tt-wth-doc.status_
                 ,input parlines-exist
                 ,input tt-wth-doc.ext-doc-type
                 ) no-error .
  IF ERROR-STATUS:ERROR THEN DO:
    return 'error'.
  END.
  if f-atrNSF <> f-atrNsf:screen-value
  then do:
  run proc-wrt-attr ( tt-wth-doc.doc-code
                     , 'wthnsf':U
                     , f-atrNsf:screen-value
                     ) no-error.
  end.
  if   f-atrDSF <> date(f-atrDSF:screen-value)
  then do:
  run proc-wrt-attr ( tt-wth-doc.doc-code
                     , 'wthdsf':U
                     , f-atrDsf:screen-value
                     ) no-error.
  end.
  if f-atrPaydoc <> f-atrPaydoc:screen-value
  then do:
  run proc-wrt-attr ( tt-wth-doc.doc-code
                     , 'wthpaydoc':U
                     , f-atrPaydoc:screen-value
                     ) no-error.
  end.
    if f-atrproxy <> f-atrproxy:screen-value
  then do:
  run proc-wrt-attr ( tt-wth-doc.doc-code
                     , 'wthproxy':U
                     , f-atrproxy:screen-value
                     ) no-error.
  end.
    if f-atrReceiver <> f-atrReceiver:screen-value
  then do:
  run proc-wrt-attr ( tt-wth-doc.doc-code
                     , 'wthreceiver':U
                     , f-atrReceiver:screen-value
                     ) no-error.
  end.
  ASSIGN FRAME Dialog-Frame f-atrDSF f-atrNSF f-atrPaydoc.
  if for-current-w-p-code <> int(for-current-w-p-code:screen-value) and par-mode = 'ИЗМЕНЕНИЕ':U
      and tt-wth-doc.doc-type = 'при':U and not tt-wth-doc.exter_ then do:
    for each buf_wth-line exclusive-lock where
      buf_wth-line.doc-code = tt-wth-doc.doc-code:
      buf_wth-line.w-p-code =  int(for-current-w-p-code:screen-value) .
    end.
    for each buf_wth-dtl exclusive-lock where buf_wth-dtl.doc-code = tt-wth-doc.doc-code :
      buf_wth-dtl.w-p-code =    int(for-current-w-p-code:screen-value).
    end.
    for each buf_wth-parts exclusive-lock where
             buf_wth-parts.out-code =  tt-wth-doc.doc-code:
        buf_wth-parts.w-p-code = int(for-current-w-p-code:screen-value).
    end.
    run fill-tables.
  end.
  ASSIGN
  FOR-CURRENT-W-P-CODE
  FOR-OUT-W-P-CODE
  .
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE proc-shift-name :
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date like ub.shift-obj.shift-date no-undo.
  define variable varshift-num  like ub.shift-obj.shift-num  no-undo.
  if input frame Dialog-Frame tt-wth-doc.shift-name <> tt-wth-doc.shift-name then do:
    if input frame Dialog-Frame tt-wth-doc.shift-date <> ? then do:
      for each  bf_shift-obj where bf_shift-obj.obj-type   = tt-wth-doc.obj-type                             and
                                   bf_shift-obj.obj-code   = tt-wth-doc.obj-code                             and
                                   bf_shift-obj.shift-date = input frame Dialog-Frame tt-wth-doc.shift-date and
                                   bf_shift-obj.shift-name = input frame Dialog-Frame tt-wth-doc.shift-name no-lock on error undo, return error return-value :
        assign
          varfind-shift = varfind-shift + 1
          varshift-date = bf_shift-obj.shift-date
          varshift-num  = bf_shift-obj.shift-num.
      end.
      if varfind-shift = 0 or varfind-shift > 1 then do:
        if varfind-shift = 0 then do:
          message "Не найдена смена: " tt-wth-doc.obj-type " " tt-wth-doc.obj-code
                  " Дата " input frame Dialog-Frame tt-wth-doc.shift-date " Номер смены " input frame Dialog-Frame tt-wth-doc.shift-name " ."
          view-as alert-box error.
        end.
        else do:
          message "Найдено более одной смены с одним номером в сменном дне. Объект: " tt-wth-doc.obj-type " " tt-wth-doc.obj-code
                  " Дата " input frame Dialog-Frame tt-wth-doc.shift-date " Номер смены " input frame Dialog-Frame tt-wth-doc.shift-name " ."
          view-as alert-box error.
        end.
        display tt-wth-doc.shift-name with frame Dialog-Frame.
        run proc-sht no-error.
        if error-status:error then do: return error. end.
      end.
      else do:
        assign frame Dialog-Frame
          tt-wth-doc.shift-name.
        assign
          tt-wth-doc.shift-date = varshift-date
          tt-wth-doc.shift-num  = varshift-num.
        display tt-wth-doc.shift-date tt-wth-doc.shift-num tt-wth-doc.shift-name with frame Dialog-Frame.
        if tt-wth-doc.fact-date = ? then do: assign tt-wth-doc.fact-date = tt-wth-doc.shift-date tt-wth-doc.fact-time = (24 * 60 * 60). display tt-wth-doc.fact-date with frame Dialog-Frame. end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-shift-num :
define buffer bf_shift-obj   for ub.shift-obj.
  if input frame Dialog-Frame tt-wth-doc.shift-num <> tt-wth-doc.shift-num then do:
    if input frame Dialog-Frame tt-wth-doc.shift-date <> ? then do:
      find first bf_shift-obj where bf_shift-obj.obj-type   = tt-wth-doc.obj-type                             and
                                    bf_shift-obj.obj-code   = tt-wth-doc.obj-code                             and
                                    bf_shift-obj.shift-date = input frame Dialog-Frame tt-wth-doc.shift-date and
                                    bf_shift-obj.shift-num  = input frame Dialog-Frame tt-wth-doc.shift-num  no-lock no-error.
      if not available bf_shift-obj then do:
        message "Не найдена смена: " tt-wth-doc.obj-type " " tt-wth-doc.obj-code
                " Дата " input frame Dialog-Frame tt-wth-doc.shift-date " Порядок смены " input frame Dialog-Frame tt-wth-doc.shift-num " ."
        view-as alert-box error.
        display tt-wth-doc.shift-num with frame Dialog-Frame.
        run proc-sht no-error.
        if error-status:error then do:
          return error.
        end.
      end.
      else do:
        assign
          tt-wth-doc.shift-date = bf_shift-obj.shift-date
          tt-wth-doc.shift-num  = bf_shift-obj.shift-num
          tt-wth-doc.shift-name = bf_shift-obj.shift-name.
        display tt-wth-doc.shift-date tt-wth-doc.shift-num tt-wth-doc.shift-name with frame Dialog-Frame.
        if tt-wth-doc.fact-date = ? then do:
          assign
            tt-wth-doc.fact-date = tt-wth-doc.shift-date
            tt-wth-doc.fact-time = (24 * 60 * 60).
          display tt-wth-doc.fact-date with frame Dialog-Frame.
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-sht :
  define buffer   bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, v-cntxt-obj-type, v-cntxt-obj-code, 'b-sel', 'obj', tt-wth-doc.obj-type, tt-wth-doc.obj-code ,'':u, input-output varrid-list) no-error .
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        tt-wth-doc.shift-date = bf_shift-obj.shift-date
        tt-wth-doc.shift-num  = bf_shift-obj.shift-num
        tt-wth-doc.shift-name = bf_shift-obj.shift-name.
      display tt-wth-doc.shift-date tt-wth-doc.shift-num tt-wth-doc.shift-name with frame Dialog-Frame.
        assign
          tt-wth-doc.fact-date = tt-wth-doc.shift-date
          tt-wth-doc.fact-time = (24 * 60 * 60).
        display tt-wth-doc.fact-date with frame Dialog-Frame.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-wrt-attr :
define  input parameter p-doc-code   like ub.wth-doc.doc-code    no-undo.
define  input parameter p-attr-code  like ub.wth-doc-attr.attr-code  no-undo.
define  input parameter p-attr-value like ub.wth-doc-attr.attr-value no-undo.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-wrt in g#wthcalib ( input p-doc-code ,
                       input p-attr-code ,
                       input p-attr-value ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message( 1 ) '"' + p-attr-code + '"'
      view-as alert-box error.
    end.
END PROCEDURE.
PROCEDURE reposition-wth-doc :
define input parameter p-direction as character no-undo .
define variable v-new-wth-doc-recid as recid no-undo .
do
on error undo, return error
:
  if valid-handle(p-call-prog)
  then do:
    run reposition-wth-doc in p-call-prog
      (input  p-direction
      ,output v-new-wth-doc-recid
      ).
    if v-new-wth-doc-recid <> ?
    then do:
      define buffer buf_wth-doc for ub.wth-doc .
      find first buf_wth-doc no-lock
        where recid(buf_wth-doc) = v-new-wth-doc-recid
        no-error .
      assign
      p-doc-rec = v-new-wth-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список документов МЦ не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.
END PROCEDURE.
FUNCTION get-place-name RETURNS CHARACTER
  (   INPUT p-obj-type AS CHARACTER
     ,INPUT p-obj-code AS INTEGER
     ,INPUT p-w-p-code AS INTEGER ) :
DEFINE BUFFER buf_wth-place FOR ub.wth-place.
IF p-w-p-code = 0
AND lookup(tt-wth-doc.ext-doc-type, 'ci,ce':U) = 0 THEN DO:
    RETURN ''.
END.
FIND FIRST buf_wth-place NO-LOCK WHERE
    buf_wth-place.obj-type = p-obj-type
 AND buf_wth-place.obj-code = p-obj-code
 AND buf_wth-place.w-p-code = p-w-p-code NO-ERROR.
IF AVAILABLE buf_wth-place THEN DO:
  RETURN buf_wth-place.w-p-name.
END.
RETURN "!!!Неизвестное МХ МЦ".
END FUNCTION.
