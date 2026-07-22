DEFINE BUFFER X_clob-bind FOR ub.clob-bind.
DEFINE BUFFER X_clob-data FOR ub.clob-data.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-parent-handle AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns as character no-undo .
define input parameter p-list-mode as character no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-resource-type as character no-undo.
define input parameter p-uniq-key-rec as character no-undo.
define input parameter p-db-num as integer no-undo.
define input-output  parameter p-rid-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список CLOB-DATA".
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
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure progs-name :
  define input  parameter p-action-code         as character no-undo .
  define output parameter p-main-prog-name      as character no-undo .
  define output parameter p-list-db-proc-name   as character no-undo .
  define output parameter p-commit-proc-name    as character no-undo .
  define output parameter p-execution-proc-name as character no-undo .
  define output parameter p-recover-proc-name   as character no-undo .
  define output parameter p-after-proc-name     as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
            when 'crush_code-range':U then do:     assign       p-main-prog-name      = 'trg/code-rgt.p':U       p-list-db-proc-name   = 'utl/cdrg-dbl.p':U       p-commit-proc-name    = 'comm-crush-cdrg':U       p-execution-proc-name = 'exec-crush-cdrg':U       p-recover-proc-name   = 'rcvr-crush-cdrg':U       p-after-proc-name     = '':U     .   end.
            when 'delete_code-range':U then do:     assign       p-main-prog-name      = 'trg/code-rgt.p':U       p-list-db-proc-name   = 'utl/cdrg-dbl.p':U       p-commit-proc-name    = 'comm-del-cdrg':U       p-execution-proc-name = 'exec-del-cdrg':U       p-recover-proc-name   = 'rcvr-del-cdrg':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-prt-bar-code':U then do:     assign       p-main-prog-name      = 'trg/bar-codt.p':U       p-list-db-proc-name   = 'str/barcddb.p':U       p-commit-proc-name    = 'block-del-prt-bar-code':U       p-execution-proc-name = 'delete-prt-bar-code':U       p-recover-proc-name   = 'undo-delete-prt-bar-code':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-part-bar-code':U then do:     assign       p-main-prog-name      = 'trg/bar-codt.p':U       p-list-db-proc-name   = 'str/barcddb.p':U       p-commit-proc-name    = 'block-del-part-bar-code':U       p-execution-proc-name = 'delete-part-bar-code':U       p-recover-proc-name   = 'undo-delete-part-bar-code':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-ucli-bar-code':U then do:     assign       p-main-prog-name      = 'trg/bar-codt.p':U       p-list-db-proc-name   = 'str/barcddb.p':U       p-commit-proc-name    = 'block-del-ucli-bar-code':U       p-execution-proc-name = 'delete-ucli-bar-code':U       p-recover-proc-name   = 'undo-delete-ucli-bar-code':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-dis-card':U then do:     assign       p-main-prog-name      = 'trg/discardt.p':U       p-list-db-proc-name   = 'trg/discardb.p':U       p-commit-proc-name    = 'block-del-dis-card':U       p-execution-proc-name = 'delete-dis-card':U       p-recover-proc-name   = 'undo-delete-dis-card':U       p-after-proc-name     = '':U     .   end.
            when 'chown-dis-card':U then do:     assign       p-main-prog-name      = 'trg/discardt.p':U       p-list-db-proc-name   = 'trg/discardb.p':U       p-commit-proc-name    = 'block-chown-dis-card':U       p-execution-proc-name = 'chown-dis-card':U       p-recover-proc-name   = 'undo-chown-dis-card':U       p-after-proc-name     = 'after-chown-dis-card':U     .   end.
            when 'delete_nu-dis-rule':U then do:     assign       p-main-prog-name      = 'trg/dis-rult.p':U       p-list-db-proc-name   = 'trg/disruldb.p':U       p-commit-proc-name    = 'block-del-dis-rule':U       p-execution-proc-name = 'delete-dis-rule':U       p-recover-proc-name   = 'undo-delete-dis-rule':U       p-after-proc-name     = '':U     .   end.
            when 'ren-art':U then do:     assign       p-main-prog-name      = 'trg/goodst.p':U       p-list-db-proc-name   = 'utl/renartcd.p':U       p-commit-proc-name    = 'comm-ren-art':U       p-execution-proc-name = 'exec-ren-art':U       p-recover-proc-name   = 'rcvr-ren-art':U       p-after-proc-name     = 'after-ren-art':U     .   end.
            when 'delete_nu-clob-data':U then do:     assign       p-main-prog-name      = 'trg/clobdatt.p':U       p-list-db-proc-name   = 'trg/clbdatdb.p':U       p-commit-proc-name    = 'block-del-clob-data':U       p-execution-proc-name = 'delete-clob-data':U       p-recover-proc-name   = 'undo-delete-clob-data':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-layout':U then do:     assign       p-main-prog-name      = 'trg/layoutt.p':U       p-list-db-proc-name   = 'trg/layoutdb.p':U       p-commit-proc-name    = 'block-del-layout':U       p-execution-proc-name = 'delete-layout':U       p-recover-proc-name   = 'undo-delete-layout':U       p-after-proc-name     = '':U     .   end.
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info3, p-action-code ).
      end.
    end case.
  end.
  return.
end procedure.
procedure progs-title :
  define input  parameter p-action-code         as character no-undo .
  define output parameter p-action-title      as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
            when 'crush_code-range':U then do:     assign       p-action-title        = "Разбиение диапазона кодов (code-range)"     .   end.
            when 'delete_code-range':U then do:     assign       p-action-title        = "Удаление диапазона кодов (code-range)"     .   end.
            when 'delete_nu-prt-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода признака"     .   end.
            when 'delete_nu-part-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода партиии"     .   end.
            when 'delete_nu-ucli-bar-code':U then do:     assign       p-action-title        = "Удаление неисп.бар-кода на доп ед.изм."     .   end.
            when 'delete_nu-dis-card':U then do:     assign       p-action-title        = "Удаление неиспользуемой ДК"     .   end.
            when 'chown-dis-card':U then do:     assign       p-action-title        = "Смена владельца ДК"     .   end.
            when 'delete_nu-dis-rule':U then do:     assign       p-action-title        = "Удаление правила скидки по фирме и глобального правила скидки"     .   end.
            when 'ren-art':U then do:     assign       p-action-title        = "Изм. артикула и(или) произв. товара"     .   end.
            when 'delete_nu-clob-data':U then do:     assign       p-action-title        = "Удаление неиспользуемой clob-data"     .   end.
            when 'delete_nu-layout':U then do:     assign       p-action-title        = "Удаление РАСКЛАДКИ"     .   end.
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info3, p-action-code ).
      end.
    end case.
  end.
  return.
end procedure.
FUNCTION progs-title-function returns character(
   input  p-action-code         as character):
define variable p-action-title      as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
            when 'crush_code-range':U then do:     assign       p-action-title        = "Разбиение диапазона кодов (code-range)"     .   end.
            when 'delete_code-range':U then do:     assign       p-action-title        = "Удаление диапазона кодов (code-range)"     .   end.
            when 'delete_nu-prt-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода признака"     .   end.
            when 'delete_nu-part-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода партиии"     .   end.
            when 'delete_nu-ucli-bar-code':U then do:     assign       p-action-title        = "Удаление неисп.бар-кода на доп ед.изм."     .   end.
            when 'delete_nu-dis-card':U then do:     assign       p-action-title        = "Удаление неиспользуемой ДК"     .   end.
            when 'chown-dis-card':U then do:     assign       p-action-title        = "Смена владельца ДК"     .   end.
            when 'delete_nu-dis-rule':U then do:     assign       p-action-title        = "Удаление правила скидки по фирме и глобального правила скидки"     .   end.
            when 'ren-art':U then do:     assign       p-action-title        = "Изм. артикула и(или) произв. товара"     .   end.
            when 'delete_nu-clob-data':U then do:     assign       p-action-title        = "Удаление неиспользуемой clob-data"     .   end.
            when 'delete_nu-layout':U then do:     assign       p-action-title        = "Удаление РАСКЛАДКИ"     .   end.
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info3, p-action-code ).
      end.
    end case.
  end.
  return p-action-title.
end FUNCTION.
procedure get-row-keyr-string :
 define input  parameter p-key-rec  as character no-undo.
 define output parameter p-tbl-title as character no-undo.
 define output parameter p-rec-string  as character no-undo.
  do
  on error undo, return error
  :
    define variable v-full-tbl-name as character no-undo .
    define variable bh_tbl-name     as handle    no-undo .
    define variable fh              as handle    no-undo .
    define variable v-ok            as logical   no-undo .
    define variable v-field-num     as integer   no-undo .
    define variable v-count-fld     as integer   no-undo .
    define variable v-tbl-name as character no-undo.
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (get-row-keyr-string). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = "ub.":U + v-tbl-name
      v-field-num     = num-entries( p-key-rec, chr(3) ) - 1
      p-rec-string         = "":U
      v-count-fld     = 0
    .
    find ub._file
      where ub._file._file-name = v-tbl-name
      no-error.
    if not available ub._file then do:
      return error substitute( "&1. Таблица &2 отсутствует в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
    p-tbl-title = ub._file._file-label
    .
    find ub._index
      where recid( ub._index  ) = ub._file._prime-index
      no-error.
    if not available ub._index
      or LC( ub._index._index-name ) = "default":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    block_where :
    for each ub._index-field of ub._index  ,
        each ub._field of _index-field
        break by _index-seq
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      if p-rec-string = "":U then do:
        assign
          p-rec-string = "":U
        .
      end.
      else do:
        assign
          p-rec-string = p-rec-string + chr(32) + chr(44)
        .
      end.
      assign
        p-rec-string = p-rec-string + (if p-rec-string = "":u then "":U else chr(32)) + substitute( "&1 = &2":U, ub._field._label, entry( v-count-fld + 1 , p-key-rec, chr(3) ) )
      .
    end.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info3, v-tbl-name ).
    end.
  end.
  return.
end procedure.
FUNCTION uniq-key-rec-string-f returns character(
   input  p-uniq-key-rec         as character):
define variable v-tbl-title as character no-undo .
define variable v-rec-string as character no-undo .
  do
  on error undo, return error
  :
    run get-row-keyr-string in this-procedure (
                                              input p-uniq-key-rec
                                              ,output v-tbl-title
                                              ,output v-rec-string).
    assign
    v-rec-string = (if v-tbl-title <> ? and
                    v-tbl-title <> "":U
                    then (v-tbl-title + ":")
                   else "":U) + chr(32) + v-rec-string
    .
  end.
  return v-rec-string.
end FUNCTION.
procedure create_db-rec_route :
  define input parameter p1-uniq-key-rec as character no-undo .
  define input parameter p1-action       as character no-undo .
  define input parameter p1-operation    as character no-undo .
  define input parameter p1-send-db-list as character no-undo .
  define input parameter p1-db-init      as integer   no-undo .
  define input parameter p1-parameters   as character no-undo .
  define input parameter p1-answer-code  as integer   no-undo .
  define input parameter p1-answer-msg   as character no-undo .
  do
  on error undo, return error
  :
    define variable v-command     as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-curr-db     as integer   no-undo .
    define variable v-db-for-send as character no-undo .
    define variable v-db-num      as integer   no-undo .
    define variable v-db-num-char as character no-undo .
    define buffer buf_sys-ctrl    for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    assign
      v-curr-db     = buf_sys-ctrl.db-num
      v-db-for-send = "":U
    .
    if v-curr-db = 0 then do:
      if p1-answer-code >= 0 then do:
        if v-curr-db <> p1-db-init then do:
          assign
            v-db-for-send = string( p1-db-init )
          .
        end.
      end.
      else do:
        assign
          v-num-entries = num-entries( p1-send-db-list, chr(44) )
        .
        do v-ind = 1 to v-num-entries:
          assign
            v-db-num-char = entry( v-ind, p1-send-db-list, chr(44) )
            v-db-num      = integer( v-db-num-char )
          .
          if v-db-num <> v-curr-db
            and v-db-num <> p1-db-init
          then do:
            if v-db-for-send = "":U then do:
              assign
                v-db-for-send = v-db-num-char
              .
            end.
            else do:
              assign
                v-db-for-send =  v-db-for-send + chr(1) + v-db-num-char
              .
            end.
          end.
        end.
      end.
    end.
    else do:
      assign
        v-db-for-send = "0":U
      .
    end.
    if v-db-for-send <> "":U then do:
      assign
        v-command = "command":U + chr(1)
                    + "two-commit":U + chr(1)
                    + p1-action + chr(1)
                    + p1-operation + chr(1)
                    + p1-uniq-key-rec + chr(1)
                    + string( p1-db-init ) + chr(1)
                    + p1-parameters + chr(1)
                    + string( p1-answer-code ) + chr(1)
                    + p1-answer-msg
      .
      run nws/cr-route.p ( input 'send-cmd':U
                    ,input v-command
                    ,input ?
                    ,input v-db-for-send
                    ) no-error .
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
  return.
end procedure.
procedure create_msg_route :
  define input parameter p2-send-db-list as character no-undo .
  define input parameter p2-msg          as character no-undo .
  do
  on error undo, return error
  :
    define variable v-msg-command as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-curr-db     as integer   no-undo .
    define variable v-db-for-send as character no-undo .
    define variable v-db-num      as integer   no-undo .
    define variable v-db-num-char as character no-undo .
    define buffer buf_sys-ctrl    for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    assign
      v-curr-db     = buf_sys-ctrl.db-num
      v-db-for-send = "":U
    .
    if v-curr-db = 0 then do:
      assign
        v-num-entries = num-entries( p2-send-db-list, chr(44) )
      .
      do v-ind = 1 to v-num-entries:
        assign
          v-db-num-char = entry( v-ind, p2-send-db-list, chr(44) )
          v-db-num      = integer( v-db-num-char )
        .
        if v-db-num <> v-curr-db then do:
          if v-db-for-send = "":U then do:
            assign
              v-db-for-send = v-db-num-char
            .
          end.
          else do:
            assign
              v-db-for-send =  v-db-for-send + chr(1) + v-db-num-char
            .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-db-for-send = "0":U
      .
    end.
    if v-db-for-send <> "":U then do:
      assign
        v-msg-command = "command":U + chr(1)
                        + "message-to-log":U + chr(1)
                        + p2-msg
      .
      run nws/cr-route.p ( input 'send-cmd':U
                    ,input v-msg-command
                    ,input ?
                    ,input v-db-for-send
                    ) no-error .
      if error-status :error then do:
        return error substitute( "&1&2&3"
                                  , return-value
                                  , chr(10)
                                  , error-status :get-message(1)
                                ).
      end.
    end.
  end.
  return.
end procedure.
function get-send-db-list returns character
  ( input p-curr-db     as integer
   ,input p-all-db-list as character
  )
:
  define variable v-send-db-list as character no-undo .
  if p-curr-db = 0 then do:
    assign
      v-send-db-list = p-all-db-list
    .
  end.
  else do:
    assign
      v-send-db-list = string(p-curr-db)
    .
  end.
  return v-send-db-list .
end function .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure clbdattd_two-commit-del :
define parameter buffer buf_clob-data for ub.clob-data.
define input parameter p-error-mode as integer no-undo .
define variable v-key-rec as character no-undo .
define variable v-param as character no-undo .
define variable v-ext-prg-handle as handle no-undo .
define variable v-rec as recid no-undo .
define variable l-is-used as logical   no-undo init yes.
define variable v-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-curr-db as integer   no-undo .
define buffer buf2_clob-data for ub.clob-data.
define buffer buf_sys-ctrl for ub.sys-ctrl .
define buffer buf_db-rec-attr for ub.db-rec-attr .
main-block:
do
on error undo, return error return-value
:
  if can-find(first ub.db where ub.db.db-num > 0) then do:
    run gen-key-rec( input 'clob-data':U
                    ,input (buffer buf_clob-data:handle )
                    ,output v-key-rec
                  ) no-error.
    if error-status :error then do:
      undo main-block, return error substitute("&1 &2 &3&4Ошибка при генерации уникального ключа для clob-data4&5&6&5&7"
                                                ,vss-workfile
                                                ,vss-revision
                                                ,vss-description
                                                , buf_clob-data.file-name_
                                                ,chr(10)
                                                , error-status:get-message(1)
                                                , return-value ).
    end.
    assign
    v-param = string(buf_clob-data.db-num) + chr(4) +
              string(buf_clob-data.int64-id) + chr(4) +
              buf_clob-data.crc-field
    v-db-num = buf_clob-data.db-num
    v-int64-id = buf_clob-data.int64-id
    .
    run nws/db-rec.p (
                        input 'delete_nu-clob-data':U
                        ,input v-key-rec
                        ,input v-param
                      ) no-error .
    if error-status:error then do:
      if p-error-mode = 0 then do:
        find first buf_sys-ctrl no-lock .
        assign
          v-curr-db  = buf_sys-ctrl.db-num.
        find first buf_db-rec-attr exclusive-lock
          where buf_db-rec-attr.db-num       = v-curr-db
            and buf_db-rec-attr.uniq-key-rec = v-key-rec
            and buf_db-rec-attr.attr-code    = 'delete_nu-clob-data':U
          no-wait no-error.
        if available buf_db-rec-attr
          or ( not available buf_db-rec-attr
              and locked buf_db-rec-attr
            )
        then do:
          return.
        end.
      end.
      else do:
      undo, return error substitute("&1&2&3"
                                     ,error-status:get-message(1)
                                     ,chr(10)
                                     , return-value ).
    end.
    end.
    find first buf2_clob-data no-lock where
              buf2_clob-data.db-num = buf_clob-data.db-num
          and buf2_clob-data.int64-id = buf_clob-data.int64-id no-error.
    if available buf2_clob-data
    and buf2_clob-data.crc-field > '':U
    and p-error-mode = 1
    then do:
      message return-value
      view-as alert-box .
    end.
  end.
  else do:
    run trg/clobdatt.p persistent set v-ext-prg-handle .
    find current buf_clob-data  exclusive-lock.
    assign
    v-rec = recid(buf_clob-data)
    buf_clob-data.crc-field = '':U
    .
    release buf_clob-data.
    find first buf_clob-data where
            recid(buf_clob-data) = v-rec.
    run value( "proc-is-used-clob-data" ) in v-ext-prg-handle (
                                                                buffer buf_clob-data
                                                              , input g#db-num
                                                              , output l-is-used) no-error .
    if not error-status:error
    and not l-is-used then do:
      delete buf_clob-data no-error .
    end.
    if valid-handle(v-ext-prg-handle) then do:
      delete procedure v-ext-prg-handle  .
    end.
    find first buf2_clob-data no-lock where
              buf2_clob-data.db-num = buf_clob-data.db-num
          and buf2_clob-data.int64-id = buf_clob-data.int64-id no-error.
    if available buf2_clob-data
    and buf2_clob-data.crc-field > '':U
    and p-error-mode = 1
    then do:
      message return-value
      view-as alert-box .
    end.
    else do:
      error-status:error = no.
    end.
  end.
  if error-status :error then do:
    undo, return error substitute("Ошибка при запуске удаления clob-data &1&2&3&4&3&5"
                                  ,v-db-num
                                  ,v-int64-id
                                  ,chr(10)
                                  , error-status:get-message(1)
                                  , return-value ).
  end.
end.
end procedure.
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info7 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info7, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info7, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info7 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info7, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info7, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info7, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info7, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info7, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info7, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info7 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info7, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info7 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def new shared temp-table cli-list no-undo like ub.clients
  field to-del as logical
  index obj  is primary unique obj-type obj-code
  index cli-name      obj-name
  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table cli-list-hist no-undo
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
define new shared temp-table dc-list no-undo like ub.dis-card
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table dc-list-hist no-undo
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
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
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
define variable glog as logical no-undo .
define variable del-option as character no-undo.
define variable chg-option as character no-undo.
define variable v-start as logical no-undo init yes.
define variable v-rid-list as character no-undo .
define variable filter-point0 as character no-undo init "clobbnds" .
define variable filter-point as character no-undo INIT "clobbnds".
define variable filter-label as character no-undo INIT "".
define variable filter-label0 as character no-undo init "" .
define variable sort-column-name as character no-undo .
define variable v-rec as recid no-undo .
define variable v-list-proc-handle as handle no-undo .
DEFINE MENU MENU-b-chg
       MENU-ITEM m_descr        LABEL "Описание"
       MENU-ITEM m_data         LABEL "Данные"        .
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
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
     SIZE 10 BY 1.
DEFINE BUTTON b-send
     LABEL "&Глоб."
     SIZE 10 BY 1 TOOLTIP "Пересылка по СПН - из ГБД во все УБД, из УБД в ГБД".
DEFINE VARIABLE E-descr AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2 NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY br-clobs FOR
      X_clob-bind,
      X_clob-data SCROLLING.
DEFINE BROWSE br-clobs
  QUERY br-clobs NO-LOCK DISPLAY
      mark-string( recid(X_clob-bind), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
X_clob-data.is-cs column-label "Глоб" format "+/"
X_clob-bind.uniq-key-rec column-label "Тип" format "X(40)" width 20
X_clob-bind.field-name_ column-label "ID" format "X(22)"
X_clob-bind.descr column-label "Описание" format "X(255)" width 45
X_clob-bind.part-num column-label "№!файла" format ">9"
X_clob-bind.sys-date column-label "Дата" format "99/99/9999"
X_clob-bind.sys-time column-label "Время" format "X(8)"
usrfulnf(X_clob-bind.user-name) column-label 'Создал' format "X(8)"
X_clob-data.int64-id column-label "ID данных"
X_clob-data.file-size column-label "Длина файла"
X_clob-data.sys-date column-label "Дата!данных" format "99/99/9999"
X_clob-data.sys-time column-label "Время!данных" format "X(8)"
usrfulnf(X_clob-data.user-name) column-label 'Изменил' format "X(8)"
enable
X_clob-bind.descr
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.27 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 14
     b-sel AT ROW 1 COL 14 WIDGET-ID 16
     b-add AT ROW 1 COL 31 WIDGET-ID 2
     b-chg AT ROW 1 COL 41 WIDGET-ID 4
     b-lkp AT ROW 1 COL 51 WIDGET-ID 12
     b-del AT ROW 1 COL 61 WIDGET-ID 6
     b-send AT ROW 1 COL 71 WIDGET-ID 22
     B-sch AT ROW 1 COL 92 WIDGET-ID 20
     B-Help AT ROW 1 COL 95
     mark-num AT ROW 2 COL 1 NO-LABEL WIDGET-ID 18
     br-clobs AT ROW 3 COL 1 WIDGET-ID 100
     E-descr AT ROW 21.27 COL 1 NO-LABEL WIDGET-ID 10
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-chg:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-chg:HANDLE.
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
define variable glog as logical   no-undo .
define variable v-list-type as character no-undo .
define variable v-list-types as character no-undo .
define variable v-list-labels as character no-undo .
define variable v-title as character no-undo .
 if not (p-resource-type = 'list':U
 or p-resource-type = 'list-macro':U)
 then do:
   message
   "Нельзя добавлять ресурсы типа" p-resource-type
   view-as alert-box error .
   undo, return no-apply.
 end.
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_clob-list_work':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then undo, return no-apply.
  if p-uniq-key-rec = ''
  and lookup("managed", bttns) > 0 then do:
    assign
    v-list-types = "gds-list" + chr(44) +
                  "cli-list" + chr(44) +
                  "dc-list"
    .
    if p-resource-type = 'list':U then do:
      assign
      v-title = "Выберите тип хранимого списка"
      v-list-labels  = "Хранимый список товаров" + chr(44) +
                      "Хранимый список клиентов" + chr(44) +
                      "Хранимый список ДК"
                      .
    end.
    else do:
      assign
      v-title = "Выберите тип хранимого макроса формирования списка"
      v-list-labels  = "Хранимый макрос формирования списка товаров" + chr(44) +
                      "Хранимый макрос формирования списка клиентов" + chr(44) +
                      "Хранимый макрос формирования списка ДК"
                      .
    end.
    run gbl/d-list.w ( input "b-sel"
                      ,input v-title
                      ,input v-list-types
                      ,input v-list-labels
                      ,input chr(44)
                      ,input ''
                      ,output v-list-type) no-error.
    if error-status:error
    or v-list-type = ''
    then do:
      return .
    end.
  end.
  else do:
    v-list-type = p-uniq-key-rec.
  end.
  message
  "По умолчанию список/макрос сохраняется ТОЛЬКО в текущей БД"
  "Для доступности в других БД - выберите опцию ГЛОБАЛЬНЫЙ"
  view-as alert-box warning.
  if not v-start
  and p-mode = 'ИЗМЕНЕНИЕ':U then do:
    message
    "Вы уже сохраняли текущий список/макрос в БД" skip
    "Вы действительно хотите это сделать еще раз??"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return no-apply.
  end.
  if lookup("managed", bttns) > 0 then do:
    case v-list-type:
      when "gds-list" then do:
         run str/gdslistp.w ( input parparentproc
                             ,input this-procedure:handle
                             ,input v-cntxt-host-code-obj
                             ,input v-cntxt-obj-type
                             ,input v-cntxt-obj-code
                             ,input p-resource-type + chr(44) + "clobbnds_add"
                             ,input substitute("СПИСОК ТОВАРОВ - добавление/изменение &1"
                                               , (if p-resource-type = 'list':U
                                                  then "хранимого списка"
                                                  else "хранимого макроса формирования списка")
                                                  )
                             ,input no).
      end.
      when "cli-list" then do:
         run str/clilistp.w ( input parparentproc
                             ,input this-procedure:handle
                             ,input v-cntxt-host-code-obj
                             ,input v-cntxt-obj-type
                             ,input v-cntxt-obj-code
                             ,input p-resource-type + chr(44) +  "clobbnds_add"
                             ,input substitute("СПИСОК КЛИЕНТОВ - добавление/изменение &1"
                                               , (if p-resource-type = 'list':U
                                                  then "хранимого списка"
                                                  else "хранимого макроса формирования списка")
                                                 )
                             ,input no).
      end.
      when "dc-list" then do:
         run str/dc-listp.w ( input parparentproc
                             ,input this-procedure:handle
                             ,input v-cntxt-host-code-obj
                             ,input v-cntxt-obj-type
                             ,input v-cntxt-obj-code
                             ,input p-resource-type + chr(44) + "clobbnds_add"
                             ,input substitute("СПИСОК ДК - добавление/изменение &1"
                                               , (if p-resource-type = 'list':U
                                                  then "хранимого списка"
                                                  else "хранимого макроса формирования списка")
                                                )
                             ,input no).
      end.
    end case.
  end.
  else do:
    run clobbnds_add in this-procedure ( input ?
                                      ,input p-resource-type
                                      ,input v-list-type
                                      ) no-error.
  end.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  if not available X_clob-bind then undo, return no-apply.
 IF chg-option = '':U THEN DO:
    run gbl/pop-up.p ( INPUT SELF :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if chg-option = "":U then do:
      return no-apply.
  end.
 if not (p-resource-type = 'list':U
 or p-resource-type = 'list-macro':U)
 then do:
   message
   "Нельзя изменять ресурсы типа" p-resource-type
   view-as alert-box error .
   undo, return no-apply.
 end.
define variable glog as logical   no-undo .
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_clob-list_work':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then undo, return no-apply.
  if not v-start
  and chg-option = "data"
  and p-mode = 'ИЗМЕНЕНИЕ':U then do:
    message
    "Вы уже сохраняли текущий список/макрос в БД" skip
    "Вы действительно хотите это сделать еще раз??"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return no-apply.
  end.
  run proc-b-chg in this-procedure (
                                      input chg-option
                                      ) no-error.
  chg-option = ''.
  if error-status:error then do:
    undo, return no-apply.
  end.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  define variable v-rec as recid no-undo.
  if not available X_clob-bind
  and not available X_clob-data
  then undo, return no-apply.
 if not (p-resource-type = 'list':U
 or p-resource-type = 'list-macro':U)
 then do:
   message
   "Нельзя удалять ресурсы типа" p-resource-type
   view-as alert-box error .
   undo, return no-apply.
 end.
define variable glog as logical   no-undo .
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_clob-list_work':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then undo, return no-apply.
  message
  "Вы действительно хотите удалить хранимый файл?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
  run proc-b-del in this-procedure  no-error.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
    define variable v-longchar as longchar no-undo .
    define variable v-ok as logical no-undo .
    if not available X_clob-data then return no-apply.
  case X_clob-bind.resource-type:
    when 'report-xml':U then do:
      run gbl/clbxmlvw.p (  input parparentproc
                           ,input rowid(X_clob-data)
                           ,input X_clob-bind.descr
                           ) no-error.
    end.
    otherwise do:
    v-longchar = X_clob-data.cdata.
    run gbl/d-longchar.w (
                           input ?
                          ,input (
                                      'title=':u + X_clob-bind.descr + '\':u
                                  + 'Editor_row=2\':u
                                  + 'Editor_col=1\':u
                                  + 'Editor_width=96\':u
                                  + 'Editor_height=15\':u
                                    + 'readonly=yes\':u
                                    + 'resource-type=' + X_clob-bind.resource-type + '\':u
                                    )
                          ,input-output v-longchar
                          ,output v-ok ) no-error .
    assign
    v-longchar = '':U.
    end.
  end case.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  if not available X_clob-bind then return no-apply.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid23 as character no-undo .
define variable v-num-entry23 as integer   no-undo .
assign
  v-str-recid23 = trim( string( recid( X_clob-bind ) , "->>>>>>>>>>>9":U ) )
  v-num-entry23 = lookup( v-str-recid23 , v-rid-list )
.
if v-num-entry23 > 0 then do:
  assign
    entry( v-num-entry23, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid23
  .
end.
  glog = br-clobs  :refresh( ) in frame Dialog-Frame.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
          glog = br-clobs:select-next-row () in frame Dialog-Frame.
          apply "value-changed" to br-clobs in frame Dialog-Frame.
  end.
  if num-entries (v-rid-list) = 0 then
      hide mark-num in frame Dialog-Frame.
  else
  disp num-entries (v-rid-list) @ mark-num
  with frame Dialog-Frame.
  apply "entry" to br-clobs in frame Dialog-Frame.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
    if ( available X_clob-bind ) AND ( v-rid-list = "" ) then
        v-rid-list = string( recid( X_clob-bind ) ) .
END.
ON CHOOSE OF b-send IN FRAME Dialog-Frame
DO:
  if not available X_clob-bind then return no-apply.
 if not (p-resource-type = 'list':U
 or p-resource-type = 'list-macro':U)
 then do:
   message
   "Нельзя добавлять ресурсы типа" p-resource-type
   view-as alert-box error .
   undo, return no-apply.
 end.
define variable glog as logical   no-undo .
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_clob-list_send':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then undo, return no-apply.
  run proc-b-send in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF br-clobs IN FRAME Dialog-Frame
DO:
  if available X_clob-bind then do:
    e-descr:screen-value = X_clob-bind.descr.
  end.
  else do:
    e-descr:screen-value = "".
  end.
END.
ON CHOOSE OF MENU-ITEM m_data
DO:
   ASSIGN
  chg-option = "data".
  apply "CHOOSE" to b-chg in frame Dialog-Frame .
  ASSIGN
  chg-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_descr
DO:
   ASSIGN
  chg-option = "descr".
  apply "CHOOSE" to b-chg in frame Dialog-Frame .
  ASSIGN
  chg-option = '':U.
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
        v-diasize-browse-handle     = browse br-clobs :handle
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var sort-labelbr-clobs   as character no-undo .
def var sort-clmnbr-clobs    as handle    no-undo .
def var cur-clmnbr-clobs     as handle    no-undo .
def var cur-clmn-locbr-clobs as integer   no-undo .
def var re-querybr-clobs     as logical   initial no no-undo .
on start-search, ctrl-o of br-clobs in frame Dialog-Frame do:
   run sort-brbr-clobs
     (input (if available X_clob-bind
             then recid(X_clob-bind)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-clobs :
  define input parameter p-recid as recid no-undo .
  if re-querybr-clobs = no then do:
    assign
       cur-clmnbr-clobs = br-clobs:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-clobs <> ? then sort-clmnbr-clobs:column-fgcolor = 0.
    if cur-clmnbr-clobs = sort-clmnbr-clobs then do:
      assign
         sort-labelbr-clobs = ""
         sort-clmnbr-clobs = ?
      .
     end.
     else do:
       assign
         sort-labelbr-clobs = cur-clmnbr-clobs:label
         sort-clmnbr-clobs  = cur-clmnbr-clobs
         sort-clmnbr-clobs:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-clobs = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-clobs:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-clobs then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-clobs = cur-clmn-locbr-clobs + 1
    .
  end.
  case sort-labelbr-clobs:
        when X_clob-bind.field-name_:label in browse br-clobs then DO:    assign       sort-column-name = "X_clob-bind.field-name_"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when X_clob-bind.descr:label in browse br-clobs then DO:    assign       sort-column-name = "X_clob-bind.descr"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when X_clob-bind.sys-date:label in browse br-clobs then DO:    assign       sort-column-name = "X_clob-bind.sys-date"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when X_clob-bind.sys-time:label in browse br-clobs then DO:    assign       sort-column-name = "X_clob-bind.sys-time"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Создал'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1usrfulnf&1, X_clob-bind.user-name)', chr(34))     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Изменил'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1usrfulnf&1, X_clob-data.user-name)', chr(34))     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input no).
      if sort-labelbr-clobs <> "" then do:
        assign
          cur-clmnbr-clobs:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-clobs = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-clobs to recid p-recid no-error.
    apply "value-changed" to br-clobs in frame Dialog-Frame.
  end.
  apply "entry" to br-clobs in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-clobs:
if cur-clmnbr-clobs = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input no).
end.
else do:
   assign re-querybr-clobs = yes.
   run sort-brbr-clobs
     (input (if available X_clob-bind
             then recid(X_clob-bind)
             else ?
            )
     ).
   assign re-querybr-clobs = no.
end.
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-clobs :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   if available X_clob-bind then v-rec = recid(X_clob-bind). Run openbr in this-procedure  ( input yes, input no, input '':U).
    apply "VALUE-CHANGED" to br-clobs.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   if lookup(p-resource-type, 'report':U + chr(44) +
                            'report-xml':U + chr(44) +
                            'list':U + chr(44) +
                            'list-macro':U
                            ) = 0 then do:
    message
    substitute("Неверный тип параметра p-resource-type=&1", p-resource-type)
    view-as alert-box error.
    undo main-block, return error.
  end.
  if lookup(p-uniq-key-rec , "gds-list,cli-list,dc-list,obj-list,,") = 0 then do:
    message
    substitute("Неверный тип параметра p-uniq-key-rec=&1", p-uniq-key-rec)
    view-as alert-box error.
    undo main-block, return error.
  end.
   if lookup(p-resource-type, 'report':U + chr(44) +
                            'report-xml':U
                            ) > 0
   and p-uniq-key-rec >  ""
   then do:
    message
    substitute("Неверный тип параметра p-resource-type=&1 или p-uniq-key-rec=&2"
             , p-resource-type
             , p-uniq-key-rec)
    view-as alert-box error.
    undo main-block, return error.
  end.
  if lookup(p-uniq-key-rec, "gds-list,cli-list,dc-list,obj-list") = 0
  and p-mode <> ''
  then do:
    message
    substitute("Неверный тип параметра p-mode=&1 или p-uniq-key-rec=&2"
             , p-mode
             , p-uniq-key-rec)
    view-as alert-box error.
    undo main-block, return error.
  end.
  if lookup(p-uniq-key-rec, "gds-list,cli-list,dc-list,obj-list") > 0
  and not (p-mode = '' or p-mode = 'ИЗМЕНЕНИЕ':U)
  then do:
    message
    substitute("Неверный тип параметра p-mode=&1 или p-uniq-key-rec=&2"
             , p-mode
             , p-uniq-key-rec)
    view-as alert-box error.
    undo main-block, return error.
  end.
  v-rid-list = p-rid-list.
  if p-rid-list <> '' then do:
  end.
  v-rec = integer(entry(1, p-rid-list)).
  if lookup("managed", bttns) > 0 then do:
    v-list-proc-handle = ?.
  end.
  else do:
    v-list-proc-handle = p-parent-handle.
  end.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY mark-num E-descr
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel b-add b-chg b-lkp b-del b-send B-sch B-Help
         mark-num br-clobs E-descr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-res-title as character no-undo.
define variable v-mode-title as character no-undo.
define variable v-db-title as character no-undo.
case p-resource-type:
  when 'report':U then do:
     assign
     v-res-title = "Хранимые отчеты".
  end.
  when 'report-xml':U then do:
     assign
     v-res-title  = "Хранимые отчеты-XML".
  end.
  when 'list':U then do:
     assign
     v-res-title  = "Хранимые списки".
  end.
  when 'list-macro':U then do:
     assign
     v-res-title  = "Хранимые макросы формирования списков".
  end.
end case.
filter-label = v-res-title.
filter-label0 = v-res-title .
case p-list-mode:
   when 'все':U then do:
   end.
   when "uniq-key-rec" then do:
      case p-uniq-key-rec:
         when "gds-list" then do:
            assign
            v-mode-title = "Список товаров".
         end.
         when "cli-list" then do:
            assign
            v-mode-title = "Список клиентов".
         end.
         when "dc-list" then do:
            assign
            v-mode-title = "Список карт".
         end.
         when "obj-list" then do:
            assign
            v-mode-title = "Список объектов".
         end.
      end.
   end.
end case.
case p-db-num:
   when -1 then do:
     v-db-title = "".
   end.
   otherwise do:
      v-db-title = substitute("БД &1", p-db-num).
   end.
end case.
assign
frame Dialog-Frame:title = substitute("&1, &2&3 &4"
                                     , v-res-title
                                     , v-mode-title
                                     , (if v-db-title = '' then '' else chr(44))
                                     , v-db-title).
assign
b-del:menu-mouse in frame Dialog-Frame  = 1
E-descr:read-only in frame Dialog-Frame = yes
X_clob-bind.uniq-key-rec:visible in browse br-clobs = (if ((p-resource-type = 'list':U
                                                       or p-resource-type = 'list-macro':U)
                                                          and p-uniq-key-rec <> '')
                                                       then no else yes)
X_clob-bind.descr:read-only in browse br-clobs = yes
X_clob-bind.descr:resizable in browse br-clobs = yes
X_clob-bind.field-name_:resizable in browse br-clobs = yes
b-chg:menu-mouse in frame Dialog-Frame = 1
menu-item m_descr:sensitive in menu menu-b-chg = (not (p-resource-type = 'report':U or p-resource-type = 'report-xml':U) and not transaction)
menu-item m_data:sensitive in menu menu-b-chg = (lookup("b-add", bttns ) > 0
                                                 and not (p-resource-type = 'report':U or p-resource-type = 'report-xml':U)
                                                 and not transaction)
X_clob-bind.uniq-key-rec:width in browse br-clobs = (if p-resource-type = 'list':U
                                                      or p-resource-type = 'list-macro':U
                                                      then 8
                                                      else (X_clob-bind.uniq-key-rec:width in browse br-clobs))
.
ENABLE
b-quit
b-add when lookup("b-add", bttns ) > 0
                  and not (p-resource-type = 'report':U or p-resource-type = 'report-xml':U
                  and not transaction
                  )
b-chg when (not (p-resource-type = 'report':U or p-resource-type = 'report-xml':U)
           and not transaction)
b-del when (lookup("b-add", bttns ) > 0
            and not (p-resource-type = 'report':U or p-resource-type = 'report-xml':U)
            and not transaction)
b-sel when (lookup("b-sel", bttns) > 0)
b-mark when (lookup("b-mark", bttns) > 0
             and not transaction)
b-lkp
b-sch
B-Help
b-send when   not (p-resource-type = 'report':U or p-resource-type = 'report-xml':U
             and lookup("b-add", bttns ) > 0
             and not transaction
              )
br-clobs
E-descr
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
Run openbr in this-procedure  ( input yes, input no, input '':U).
apply "value-changed" to br-clobs.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
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
filter-point = filter-point0 + p-resource-type.
CASE p-list-mode:
  when 'все':U then do:
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
                              "FOR EACH X_clob-bind no-lock"
      parameter-4-33 =
        (
          if (" X_clob-bind.resource-type = p-resource-type and                       (p-db-num = -1 or X_clob-bind.db-num = p-db-num) " + " " + where-phrase-33) <> ""
          then  substitute(' X_clob-bind.resource-type = &1&2&1 and                          ( &3 = -1 or X_clob-bind.db-num = &3)', chr(34), p-resource-type, p-db-num)  + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + ", first X_clob-data NO-LOCK where       (X_clob-data.db-num = X_clob-bind.db-num   and X_clob-data.int64-id = X_clob-bind.int64-id )")
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-33 =
          (" X_clob-bind.resource-type = p-resource-type and                       (p-db-num = -1 or X_clob-bind.db-num = p-db-num) " + " " + where-phrase-33 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-clobs:handle
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
    OPEN QUERY br-clobs FOR EACH X_clob-bind no-lock
      where  X_clob-bind.resource-type = p-resource-type and                       (p-db-num = -1 or X_clob-bind.db-num = p-db-num)
    , first X_clob-data NO-LOCK where       (X_clob-data.db-num = X_clob-bind.db-num   and X_clob-data.int64-id = X_clob-bind.int64-id )
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
  END.
  when "uniq-key-rec" then do:
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
                              "FOR EACH X_clob-bind no-lock"
      parameter-4-35 =
        (
          if (" X_clob-bind.resource-type = p-resource-type and                     X_clob-bind.uniq-key-rec = p-uniq-key-rec and       (p-db-num = -1 or X_clob-bind.db-num = p-db-num)  " + " " + where-phrase-35) <> ""
          then  substitute(' X_clob-bind.resource-type = &1&2&1 and                                       X_clob-bind.uniq-key-rec = &1&3&1 and       (&4 = -1 or X_clob-bind.db-num = &4)', chr(34), p-resource-type, p-uniq-key-rec, p-db-num)  + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + ", first X_clob-data NO-LOCK where       (X_clob-data.db-num = X_clob-bind.db-num   and X_clob-data.int64-id = X_clob-bind.int64-id )")
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
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-35 =
          (" X_clob-bind.resource-type = p-resource-type and                     X_clob-bind.uniq-key-rec = p-uniq-key-rec and       (p-db-num = -1 or X_clob-bind.db-num = p-db-num)  " + " " + where-phrase-35 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-clobs:handle
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
    OPEN QUERY br-clobs FOR EACH X_clob-bind no-lock
      where  X_clob-bind.resource-type = p-resource-type and                     X_clob-bind.uniq-key-rec = p-uniq-key-rec and       (p-db-num = -1 or X_clob-bind.db-num = p-db-num)
    , first X_clob-data NO-LOCK where       (X_clob-data.db-num = X_clob-bind.db-num   and X_clob-data.int64-id = X_clob-bind.int64-id )
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
  END.
END CASE.
apply "entry" to br-clobs in frame Dialog-Frame.
if v-rec <> ? then reposition br-clobs to recid v-rec no-error.
if error-status:error then do:
  reposition br-clobs to row 1 no-error.
end.
run waitfram-hide in this-procedure .
if avail X_clob-data then
APPLY "VALUE-CHANGED":U to br-clobs.
END PROCEDURE.
PROCEDURE clobbnds_add :
define input parameter p-list-handle as handle no-undo .
define input parameter p-resource-type as character no-undo .
define input parameter p-list-type as character no-undo .
define variable v-part-num as integer   no-undo .
define variable v-clob-db-num as integer   no-undo init ?.
define variable v-int64-id as int64 no-undo .
define variable v-descr                   as character                no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_clob-bind for ub.clob-bind.
run gbl/d-prompt.w (
    'title=':u + "Добавление списка/макроса" + '\':u
  + 'text1=':u + "Введите описание" + '\':u
  + 'format=X(90)\':u
  + 'type=char\':u
  + 'fillin_row=1\':u
  + 'fillin_col=1\':u
  + 'fillin_width=92\':u
  + 'fillin_height=1\':u
  + 'max-chars=90\':u
  ,input-output v-descr
  ).
if return-value = 'false':u
then do:
  return 'quit'.
end.
run gbl/_tmpfile.p ( input ""
                    ,input "tmp"
                    ,output v-file-name) .
output to value(v-file-name).
put 1 skip.
output close.
run gbl/filename.p (
              input v-file-name
              ,output v-full-path
              ,output v-path
              ,output v-file-name
              ,output v-file-name-no-ext
              ,output v-file-name-ext
              ) no-error .
if error-status:error then do:
  undo, return error .
end.
if p-list-handle = ? then do:
  p-list-handle = p-parent-handle.
end.
case p-resource-type:
  when 'list':U then do:
    run cb_fill-lob-res-list in p-list-handle ( input v-full-path) no-error.
  end.
  when 'list-macro':U then do:
    run cb_fill-lob-res-list-macro in p-list-handle ( input v-full-path) no-error.
  end.
end case.
if error-status:error then do:
  os-delete value(v-full-path) no-error.
  return no-apply.
end.
run gbl/file2clb.p ( input 'ДОБАВЛЕНИЕ':U
                    ,input ",no"
                    ,input ?
                    ,input p-list-type
                    ,input '':U
                    ,input v-descr
                    ,input-output v-part-num
                    ,input p-resource-type
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input v-full-path
                    ,input ?
                    ) no-error .
if error-status:error then do:
  message error-status :error  skip
  return-value
  view-as alert-box error .
  undo, return error  .
end.
v-start = no.
find first buf_clob-bind no-lock where
          buf_clob-bind.db-num = v-clob-db-num
      and buf_clob-bind.int64-id = v-int64-id no-error.
if available buf_clob-bind then do:
  v-rec = recid(buf_clob-bind).
end.
run OpenBr in this-procedure  ( input yes, input no, input '':U).
apply "value-changed" to br-clobs in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-chg :
define input parameter p-chg-option as character no-undo.
define variable v-part-num as integer   no-undo .
define variable v-clob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-old-clob-db-num as integer   no-undo .
define variable v-old-int64-id as int64 no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable v-longchar as longchar no-undo.
define variable v-str as character no-undo.
define variable v-prod-type like ub.goods.prod-type.
define variable v-prod-code like ub.goods.prod-code.
define variable v-artic     like ub.goods.artic.
define variable v-obj-type  like ub.clients.obj-type.
define variable v-obj-code  like ub.clients.obj-code.
define variable v-cli-type  like ub.clients.obj-type.
define variable v-cli-code  like ub.clients.obj-code.
define variable v-d-card    like ub.dis-card.d-card.
define variable v-descr as character no-undo .
define variable v-file-name0 as character no-undo .
define variable v-ok as logical   no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_clob-data for ub.clob-data.
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_goods for ub.goods.
assign
v-old-clob-db-num = X_clob-bind.db-num
v-old-int64-id = X_clob-bind.int64-id
v-clob-db-num = X_clob-bind.db-num
v-int64-id = X_clob-bind.int64-id
v-part-num = X_clob-bind.part-num
v-descr = X_clob-bind.descr
v-rec = recid(X_clob-bind)
.
if (g#db-num > 0 and X_clob-bind.db-num <> g#db-num)
or (g#db-num = 0 and X_clob-bind.db-num > 0 and can-find( first ub.db where ub.db.db-num = X_clob-bind.db-num))
then do:
  message
  "Нельзя изменить список или отчет, созданный в другой БД!"
  view-as alert-box error  .
  undo, return error .
end.
find first buf_clob-data share-lock where
          buf_clob-data.db-num = X_clob-bind.db-num
      and buf_clob-data.int64-id = X_clob-bind.int64-id .
if buf_clob-data.crc-field = '' then do:
    message
    "В настоящий момент работает распределенная команда УДАЛЕНИЯ данного файла" skip
    "Изменение невозможно"
    view-as alert-box error .
    undo, return error .
end.
case p-chg-option:
when "descr" then do:
    run gbl/d-prompt.w (
        'title=':u + "Изменение описания списка макроса" + '\':u
      + 'text1=':u + "Можете изменить описание" + '\':u
      + 'format=X(90)\':u
      + 'type=char\':u
      + 'fillin_row=1\':u
      + 'fillin_col=1\':u
      + 'fillin_width=92\':u
      + 'fillin_height=1\':u
      + 'max-chars=90\':u
      ,input-output v-descr
      ).
    if return-value = 'false':u
    then do:
      return 'quit'.
    end.
    find first buf_clob-bind where
                recid(buf_clob-bind) = recid(X_clob-bind).
    assign
    buf_clob-bind.descr = v-descr.
    release buf_clob-bind.
end.
when "data" then do:
    define variable v-list-type as character no-undo .
    if p-uniq-key-rec = '' then do:
      v-list-type = X_clob-bind.uniq-key-rec.
    end.
    else do:
      v-list-type = p-uniq-key-rec.
    end.
    v-longchar = X_clob-data.cdata.
    if lookup("managed", bttns) > 0 then do:
      case v-list-type:
        when "gds-list" then do:
          run gbl/_tmpfile.p ( input ""
                              ,input "txt"
                              ,output v-file-name) .
          output to value(v-file-name).
          put 1 skip.
          output close.
          run gbl/filename.p (
                        input v-file-name
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
          if error-status:error then do:
            undo, return error .
          end.
          copy-lob
          FROM object v-longchar
          to FILE v-full-path
          no-convert
          NO-ERROR.
          input from value(v-full-path) .
            repeat :
              import  v-prod-type v-prod-code v-artic   .
              find buf_goods where buf_goods.prod-type = v-prod-type
                                and buf_goods.prod-code = v-prod-code
                                and buf_goods.artic     = v-artic no-error.
              if available buf_goods then do :
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = buf_goods.prod-type
    and gds-list.prod-code = buf_goods.prod-code
    and gds-list.artic     = buf_goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last36 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last36 = gds-list.order-num .
  end.
  else do:
    v-last36 = 0 .
  end.
  create gds-list .
  buffer-copy buf_goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last36 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
              end.
            end.
          input close.
          os-delete value(v-full-path).
          run str/gdslistp.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input v-cntxt-host-code-obj
                              ,input v-cntxt-obj-type
                              ,input v-cntxt-obj-code
                              ,input p-resource-type + chr(44) + "clobbnds_chg"
                              ,input "HH"
                              ,input no).
          for each gds-list :
            delete gds-list.
          end.
        end.
        when "cli-list" then do:
          run gbl/_tmpfile.p ( input ""
                              ,input "txt"
                              ,output v-file-name) .
          output to value(v-file-name).
          put 1 skip.
          output close.
          run gbl/filename.p (
                        input v-file-name
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
          if error-status:error then do:
            undo, return error .
          end.
          copy-lob
          FROM object v-longchar
          to FILE v-full-path
          no-convert
          NO-ERROR.
          input from value(v-full-path) .
            repeat :
              import  v-obj-type v-obj-code .
              find clients where clients.obj-type = v-obj-type
                             and clients.obj-code = v-obj-code no-lock.
              if available clients then do :
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find cli-list
  where cli-list.obj-type = clients.obj-type
    and cli-list.obj-code = clients.obj-code
  no-error .
if available cli-list then do:
  assign
    cli-list.to-del = no
  .
end.
else do:
  create cli-list .
  buffer-copy clients to cli-list
  assign
    cli-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (cli-list)
  .
end.
              end.
            end.
          input close.
          os-delete value(v-full-path).
          run str/clilistp.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input v-cntxt-host-code-obj
                              ,input v-cntxt-obj-type
                              ,input v-cntxt-obj-code
                              ,input p-resource-type + chr(44) + "clobbnds_chg"
                              ,input "HH"
                              ,input no).
          for each cli-list :
            delete cli-list.
          end.
        end.
        when "dc-list" then do:
          run gbl/_tmpfile.p ( input ""
                              ,input "txt"
                              ,output v-file-name) .
          output to value(v-file-name).
          put 1 skip.
          output close.
          run gbl/filename.p (
                        input v-file-name
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
          if error-status:error then do:
            undo, return error .
          end.
          copy-lob
          FROM object v-longchar
          to FILE v-full-path
          no-convert
          NO-ERROR.
          input from value(v-full-path) .
            repeat :
              import  v-d-card v-cli-type v-cli-code .
              find dis-card where dis-card.d-card   = v-d-card
                              and dis-card.cli-type = v-cli-type
                              and dis-card.cli-code = v-cli-code no-lock.
              if available dis-card then do :
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find dc-list
  where dc-list.d-card = dis-card.d-card
  no-error .
if available dc-list then do:
  assign
    dc-list.to-del = no
  .
end.
else do:
  create dc-list .
  buffer-copy dis-card to dc-list
  assign
    dc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (dc-list)
  .
end.
              end.
            end.
          input close.
          os-delete value(v-full-path).
          run str/dc-listp.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input v-cntxt-host-code-obj
                              ,input v-cntxt-obj-type
                              ,input v-cntxt-obj-code
                              ,input p-resource-type + chr(44) + "clobbnds_chg"
                              ,input "HH"
                              ,input no).
          for each dc-list :
            delete dc-list.
          end.
        end.
      end case.
    end.
    else do:
      run clobbnds_chg in this-procedure ( input ?).
    end.
  end.
end case.
v-longchar = '':U.
run OpenBr in this-procedure  ( input yes, input no, input '':U).
apply "value-changed" to br-clobs in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE clobbnds_chg :
define input parameter p-list-handle as handle no-undo .
define variable v-part-num as integer   no-undo .
define variable v-clob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-old-clob-db-num as integer   no-undo .
define variable v-old-int64-id as int64 no-undo .
define variable v-descr as character no-undo .
define variable v-file-name0 as character no-undo .
define variable v-ok as logical   no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_clob-data for ub.clob-data.
define buffer buf_clob-bind for ub.clob-bind.
assign
v-old-clob-db-num = X_clob-bind.db-num
v-old-int64-id = X_clob-bind.int64-id
v-clob-db-num = X_clob-bind.db-num
v-int64-id = X_clob-bind.int64-id
v-part-num = X_clob-bind.part-num
v-descr = X_clob-bind.descr
v-rec = recid(X_clob-bind)
.
    run gbl/_tmpfile.p ( input ""
                        ,input "tmp"
                        ,output v-file-name) .
    output to value(v-file-name).
    put 1 skip.
    output close.
    run gbl/filename.p (
                  input v-file-name
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
    if error-status:error then do:
      undo, return error .
    end.
if p-list-handle = ? then do:
  p-list-handle = p-parent-handle.
end.
    case p-resource-type:
      when 'list':U then do:
    run cb_fill-lob-res-list in p-list-handle ( input v-full-path) no-error.
      end.
      when 'list-macro':U then do:
    run cb_fill-lob-res-list-macro in p-list-handle ( input v-full-path) no-error.
      end.
    end case.
    if error-status:error then do:
      os-delete value(v-full-path) no-error.
      return no-apply.
    end.
    run gbl/file2clb.p ( input 'ИЗМЕНЕНИЕ':U
                        ,input "add-new,no"
                        ,input ?
                    ,input X_clob-bind.uniq-key-rec
                        ,input X_clob-bind.field-name_
                        ,input v-descr
                        ,input-output v-part-num
                        ,input p-resource-type
                        ,input-output v-clob-db-num
                        ,input-output v-int64-id
                        ,input v-full-path
                        ,input ?
                        ) no-error .
    if error-status:error then do:
      message error-status :error  skip
      return-value
      view-as alert-box error .
      undo, return error  .
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = v-old-clob-db-num
          and buf_clob-data.int64-id = v-old-int64-id no-error.
    if available buf_clob-data then do:
      run clbdattd_two-commit-del in this-procedure ( buffer buf_clob-data, input 1) no-error.
      if error-status :error then do:
        undo , return error substitute("Ошибка при попытке запустить удаление неиспользуемых clob-data &1 (&2&3)(2)&4&5&4&6"
                                                  ,buf_clob-data.file-name_
                                                  ,buf_clob-data.db-num
                                                  ,buf_clob-data.int64-id
                                                  ,chr(10)
                                                  , error-status:get-message(1)
                                                  , return-value ).
      end.
    end.
    v-start = no.
END PROCEDURE.
PROCEDURE proc-b-del :
define variable v-clob-db-num as integer   no-undo .
define variable v-int64-id as int64 no-undo .
define variable v-part-num as integer   no-undo .
define buffer buf_clob-data for ub.clob-data.
if (g#db-num > 0 and X_clob-bind.db-num <> g#db-num)
or (g#db-num = 0 and X_clob-bind.db-num > 0 and can-find( first ub.db where ub.db.db-num = X_clob-bind.db-num))
then do:
  message
  "Нельзя удалить список или отчет, созданный в другой БД!"
  view-as alert-box error
  .
  undo, return error .
end.
find first buf_clob-data share-lock where
        buf_clob-data.db-num = X_clob-bind.db-num
    and buf_clob-data.int64-id = X_clob-bind.int64-id no-error.
if buf_clob-data.crc-field = '' then do:
  message
  "В настоящий момент УЖЕ работает распределенная команда УДАЛЕНИЯ данного файла" skip
  view-as alert-box error .
  undo, return error .
end.
assign
v-clob-db-num = X_clob-bind.db-num
v-int64-id = X_clob-bind.int64-id
v-part-num = X_clob-bind.part-num
.
run gbl/file2clb.p ( input 'удаление':U
                    ,input "delete"
                    ,input ?
                    ,input X_clob-bind.uniq-key-rec
                    ,input X_clob-bind.field-name
                    ,input '':U
                    ,input-output v-part-num
                    ,input p-resource-type
                    ,input-output v-clob-db-num
                    ,input-output v-int64-id
                    ,input X_clob-bind.uniq-key-rec
                    ,input ?
                    ) no-error .
if error-status :error then do:
  message
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo , return error return-value .
end.
if available buf_clob-data then do:
  run clbdattd_two-commit-del in this-procedure ( buffer buf_clob-data, input 1) no-error.
  if error-status :error then do:
    undo , return error substitute("Ошибка при попытке запустить удаление неиспользуемых хранимых данных &1 (&2&3)(2)&4&5&4&6"
                                              ,buf_clob-data.file-name_
                                              ,buf_clob-data.db-num
                                              ,buf_clob-data.int64-id
                                              ,chr(10)
                                              , error-status:get-message(1)
                                              , return-value ).
  end.
end.
v-rec = ?.
run OpenBr in this-procedure  ( input yes, input no, input '':U).
apply "value-changed" to br-clobs in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
tbl = 'clob-bind'
join-tbl = 'X_clob-bind'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('uniq-key-rec', 'Тип', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('field-name_', 'ID', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('db-num', 'БД', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name', 'Создал', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
DO on stop undo, leave:
    run gbl/filter.w ( input parparentproc
                      ,input (filter-point + chr(4) +
                         filter-label  + chr(4) +
                         string(yes))
                      ,input tbl
                      ,input join-tbl
                      ,input fld
                      ,input lab
                      ,input spr
                      ,input dim).
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END .
END PROCEDURE.
PROCEDURE proc-b-send :
define variable v-old-is-cs as logical no-undo .
define buffer buf_clob-data for ub.clob-data.
main-block:
do transaction:
  find first buf_clob-data share-lock where
            recid(buf_clob-data) = recid(X_clob-data).
    if buf_clob-data.crc-field = '' then do:
      message
      "В настоящий момент работает распределенная команда УДАЛЕНИЯ данного файла" skip
      "Отсылка невозможна"
      view-as alert-box error .
      undo, return error .
    end.
  assign
  v-old-is-cs = buf_clob-data.is-cs
  buf_clob-data.is-cs = yes.
  if v-old-is-cs = no then do:
     run str/callnews.p ( input 'clob-bind':U
                        ,input (buffer X_clob-bind:handle)
                        ) no-error .
    if error-status:error then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове callnews.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo,  return error return-value .
    end.
    release buf_clob-data.
    find first buf_clob-data share-lock where
              recid(buf_clob-data) = recid(X_clob-data).
   run str/callnews.p ( input 'clob-bind':U
                        ,input (buffer X_clob-bind:handle)
                        ) no-error .
    if error-status:error then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове callnews.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo main-block,  return error return-value .
    end.
    end.
  br-clobs:refresh() in frame Dialog-Frame .
end.
END PROCEDURE.
