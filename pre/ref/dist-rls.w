DEFINE TEMP-TABLE tt0-template_dis-time-rule NO-UNDO LIKE ub.dis-time-rule.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_dis-rule FOR ub.dis-rule.
DEFINE BUFFER X_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER X_upper-dis-time-rule FOR ub.dis-time-rule.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
define input parameter p-mode  as char   no-undo .
define input parameter p-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-upper-time-rule-num like ub.dis-time-rule.upper-time-rule-num no-undo .
define input parameter p-pos-type as character no-undo .
define input-output parameter p-sts like ub.dis-time-rule.sts no-undo .
define input-output param p-rid-list    as  char no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список РАСПИСАНИЙ СКИДОК":U.
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dr-code :
  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-rule.des               no-undo .
    define output parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
    define output parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
    define output parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
    define output parameter  p-level-1           as character no-undo .
    define output parameter  p-level-2           as character no-undo .
    define output parameter  p-global             as integer no-undo .
    define output parameter  p-host               as integer no-undo .
    define output parameter  p-object             as integer no-undo .
    define output parameter  p-output-display as logical   no-undo .
    define output parameter  p-tree           as char  no-undo .
    define output parameter  p-other          as character no-undo .
    define variable v-other as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-templ-rl-root no-error.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("неизвестный шаблон скидки &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-rule.des
    p-discnt-type = buf_dis-rule.discnt-type
    p-subject-type = buf_dis-rule.subject-type
    p-value-type = buf_dis-rule.value-type
    p-global = (if available buf_dis-cfg-rule
                then buf_dis-cfg-rule.has-global
                else 0)
    p-host = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-host
              else 0)
    p-object = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-obj
              else 0)
    p-output-display = (buf_dis-rule.sts = integer('0':U))
    p-tree = buf_Dis-rule.uniq-field
    p-other = buf_dis-rule.other-inf
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    .
  end.
end procedure.
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
procedure disrules-get-interface-form :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define output parameter p-form-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
find first buf_temp-drt-prop where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "InputForm"
      and buf_temp-drt-prop.prop-code = "FormName" no-error.
if not available buf_temp-drt-prop then do:
  find first buf_drt-prop where
            buf_drt-prop.templ-rl-root = p-templ-rl-root
        and buf_drt-prop.upper-prop-code = "InputForm"
        and buf_drt-prop.prop-code = "FormName" no-error.
  if available buf_drt-prop then do:
    p-form-name = buf_drt-prop.property-value.
  end.
  else do:
    p-form-name = "ref/dis-ruli.w".
  end.
end.
else do:
  p-form-name = buf_temp-drt-prop.property-value.
end.
end procedure.
~
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dtr-code :
  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-time-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-time-rule.des               no-undo .
    define output parameter  p-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
    define output parameter  p-value-type        like ub.dis-time-rule.value-type        no-undo .
    define output parameter  p-level-1 as character no-undo .
    define output parameter  p-level-2 as character no-undo .
    define output parameter  p-output-display as logical   no-undo .
    define output parameter  p-tree           as char  no-undo .
    define output parameter  p-other          as character no-undo .
    define variable v-templ-rl-root like ub.dis-time-rule.templ-rl-root no-undo .
    define buffer buf_dis-time-rule for ub.dis-time-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    if p-templ-rl-root < 50000 then
    v-templ-rl-root = (p-templ-rl-root + 50000).
    else v-templ-rl-root = p-templ-rl-root.
    find first buf_dis-time-rule no-lock where
              buf_dis-time-rule.time-rule-num = v-templ-rl-root no-error .
    if not available buf_dis-time-rule then do:
      undo, return error substitute("неизвестный тип расписания &1", p-templ-rl-root) .
    end.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = 0
        and buf_dis-cfg-rule.time-templ-rl-root = p-templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("неизвестный тип расписания &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-time-rule.des
    p-upper-time-rule-num = (buf_dis-time-rule.upper-time-rule-num - 50000)
    p-value-type = buf_dis-time-rule.value-type
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    p-output-display = (buf_dis-time-rule.sts = integer('0':U))
    p-tree = buf_dis-time-rule.uniq-field
    p-other = buf_dis-time-rule.other-inf
    .
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gtregion RETURNS CHARACTER
  ( input parhost-code as integer
  , input parobj-type as character
  , input parobj-code as integer
  , input p-tab as logical
  ) :
  def var par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = "" and
       parobj-code = 0 then do:
       par-region = if p-tab then fill(chr(32), 2) else "":U +
                    "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    par-region = if p-tab then fill(chr(32), 4) else "":U +
                 parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable v-rid-list as character no-undo .
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable filter-point as character no-undo init "dist-rls" .
define variable filter-point0 as character no-undo init "dist-rls" .
define variable filter-label as character no-undo init "Список расписаний" .
define variable filter-label0 as character no-undo init "Список расписаний" .
DEFINE variable v-display-time-from AS CHARACTER NO-UNDO.
DEFINE variable v-display-time-to AS CHARACTER NO-UNDO.
DEFINE variable v-display-date-from AS CHARACTER NO-UNDO.
DEFINE variable v-display-date-to AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-0 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-1 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-2 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-3 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-4 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-5 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-6 AS CHARACTER NO-UNDO.
DEFINE variable v-display-week-day-7 AS CHARACTER NO-UNDO.
DEFINE variable v-display-month-day AS CHARACTER NO-UNDO.
define variable v-using-fields as character no-undo .
define buffer pos_dis-time-rule for ub.dis-time-rule.
DEFINE BUFFER tt-template_dis-time-rule FOR tt0-template_dis-time-rule.
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-dis-time-rule FOR ub.dis-time-rule, input mark-list as CHARACTER )  FORWARD.
FUNCTION time-v-name RETURNS CHARACTER
  ( BUFFER loc_dis-time-rule FOR ub.dis-time-rule )  FORWARD.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-dis-rule
     LABEL "Пр&авила"
     SIZE 10 BY 1.
DEFINE BUTTON B-dis-time-rules
     LABEL "&Расп-ния"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-history
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE BUTTON B-stat
     LABEL "&Статус"
     SIZE 10 BY 1.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-des AS CHARACTER FORMAT "X(255)"
      VIEW-AS TEXT
     SIZE 98 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE RS-sts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 40 BY 1 NO-UNDO.
DEFINE QUERY br-dis-time-rule FOR
                X_dis-time-rule,
                tt-template_dis-time-rule SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      X_dis-time-rule SCROLLING.
DEFINE BROWSE br-dis-time-rule
  QUERY br-dis-time-rule NO-LOCK DISPLAY
      mark-string(buffer X_dis-time-rule, v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_dis-time-rule.des FORMAT "X(50)":U
      entry (lookup (STRING(X_dis-time-rule.sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U) COLUMN-LABEL "Статус"
      v-display-time-from COLUMN-LABEL "Время!нач." FORMAT "X(5)":U
            WIDTH 6
      v-display-time-to COLUMN-LABEL "Время!конца" FORMAT "X(5)":U
            WIDTH 6
      v-display-date-from COLUMN-LABEL "Дата нач." FORMAT "X(10)":U
      v-display-date-to COLUMN-LABEL "Дата!конца" FORMAT "X(10)":U
            WIDTH 11
      v-display-week-day-0 COLUMN-LABEL "ДН" FORMAT "X(1)":U
      v-display-week-day-1 COLUMN-LABEL "Пн" FORMAT "X(3)":U
      v-display-week-day-2 COLUMN-LABEL "Вт" FORMAT "X(3)":U
      v-display-week-day-3 COLUMN-LABEL "Ср" FORMAT "X(3)":U
      v-display-week-day-4 COLUMN-LABEL "Чт" FORMAT "X(3)":U
      v-display-week-day-5 COLUMN-LABEL "Птн" FORMAT "X(3)":U
      v-display-week-day-6 COLUMN-LABEL "Сб" FORMAT "X(3)":U
      v-display-week-day-7 COLUMN-LABEL "Вс" FORMAT "X(3)":U
      v-display-month-day COLUMN-LABEL "ДМ" FORMAT "X(2)":U
      time-v-name(buffer X_dis-time-rule) COLUMN-LABEL "Тип расп-ния" FORMAT "X(16)":U
      X_dis-time-rule.time-rule-num COLUMN-LABEL "№ расп-ния" FORMAT ">>>>>>>>9":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 31
     B-lookup AT ROW 1 COL 41
     B-chg AT ROW 1 COL 51
     B-del AT ROW 1 COL 61
     B-stat AT ROW 1 COL 71
     B-print AT ROW 1 COL 86
     b-history AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-dis-time-rules AT ROW 2 COL 51
     B-dis-rule AT ROW 2 COL 61
     RS-sts AT ROW 3.5 COL 3.5 NO-LABEL
     br-dis-time-rule AT ROW 5 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     v-des AT ROW 21.38 COL 1 NO-LABEL
     SPACE(0.12) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Расписания скидок".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-add:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-chg:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-dis-time-rules:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
OR ENDKEY OF FRAME Dialog-Frame DO:
  run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input v-rid-list) no-error.
  if error-status:error then return no-apply.
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable  v-templ-rl-root     like ub.dis-time-rule.templ-rl-root     no-undo .
define variable v-attr-codes as character no-undo .
define variable v-attr-labels as character no-undo .
define variable v-presel-codes as character no-undo .
define variable v-sel-codes as character no-undo .
define buffer root_dis-time-rule for ub.dis-time-rule.
define buffer buf_tt-template_dis-time-rule for tt0-template_dis-time-rule.
define buffer template_dis-time-rule for ub.dis-time-rule.
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_discount_work':U
    ,input  'global':U
    ,input  0
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
if p-mode <> "upper-time-rule-num":U
or not avail X_upper-dis-time-rule
or X_upper-dis-time-rule.upper-time-rule-num  = 0
or p-upper-time-rule-num <> 0 then do:
  if p-mode = 'dis-rule':U
  or p-mode = "rule-num":U
  then do:
    for each buf_tt-template_dis-time-rule no-lock where
            buf_tt-template_dis-time-rule.sts = integer('0':U):
       assign
       v-attr-codes   =  v-attr-codes +  chr(4) + string(buf_tt-template_dis-time-rule.time-rule-num)
       v-attr-labels  =  v-attr-labels +  chr(4) + substitute("&1 (тип &2)"
                                                                    ,buf_tt-template_dis-time-rule.des
                                                                    ,buf_tt-template_dis-time-rule.time-rule-num)
       .
    end.
    assign
    v-attr-codes = trim (v-attr-codes, chr(4))
    v-attr-labels = trim (v-attr-labels, chr(4))
    .
  end.
  else do:
    for each template_dis-time-rule no-lock where
            template_dis-time-rule.sts = integer('0':U):
       assign
       v-attr-codes   =  v-attr-codes +  chr(4) + string(template_dis-time-rule.time-rule-num)
       v-attr-labels  =  v-attr-labels +  chr(4) + substitute("&1 (тип &2)"
                                                                    ,template_dis-time-rule.des
                                                                    ,template_dis-time-rule.time-rule-num)
       .
    end.
    assign
    v-attr-codes = trim (v-attr-codes, chr(4))
    v-attr-labels = trim (v-attr-labels, chr(4))
    .
  end.
  run gbl/d-list.w (
               input "b-sel":U
              ,input "Выберите тип расписания"
              ,input v-attr-codes
              ,input v-attr-labels
              ,input chr(4)
              ,input v-presel-codes
              ,output v-sel-codes).
   if v-sel-codes = "":U then return no-apply.
   assign
   v-templ-rl-root = integer(v-sel-codes)
   .
end.
else do:
  assign
  v-templ-rl-root = X_upper-dis-time-rule.templ-rl-root
  .
end.
run ref/dis-timi.w
              (
                 input parParentProc
                ,input 'ДОБАВЛЕНИЕ':U
                ,input v-templ-rl-root
                ,input 0
                ,input p-upper-time-rule-num
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input YES, input NO, input '':U).
  reposition br-dis-time-rule to recid loc-doc-rec no-error.
  if error-status:error then do:                           find first pos_dis-time-rule no-lock where                                   recid(pos_dis-time-rule) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи РАСПИСАНИЕ" skip                            string(if avail pos_dis-time-rule                                     then  substitute("номер расписания: &1"                                                     , pos_dis-time-rule.time-rule-num)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
end.
apply "entry" to br-dis-time-rule in frame Dialog-Frame.
apply "value-changed" to br-dis-time-rule in frame Dialog-Frame.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_dis-time-rule then return no-apply.
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_discount_work':U
    ,input  'global':U
    ,input  0
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
loc-doc-rec = recid(X_dis-time-rule)
.
run ref/dis-timi.w
              (
                 input parParentProc
                ,input 'ИЗМЕНЕНИЕ':U
                ,input X_dis-time-rule.templ-rl-root
                ,input X_dis-time-rule.time-rule-num
                ,input X_dis-time-rule.upper-time-rule-num
                ,input-output loc-doc-rec
                            ) no-error
.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input YES, input NO, input NO).
  reposition br-dis-time-rule to recid loc-doc-rec no-error.
  if error-status:error then do:                           find first pos_dis-time-rule no-lock where                                   recid(pos_dis-time-rule) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи РАСПИСАНИЕ" skip                            string(if avail pos_dis-time-rule                                     then  substitute("номер расписания: &1"                                                     , pos_dis-time-rule.time-rule-num)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
end.
apply "entry" to br-dis-time-rule in frame Dialog-Frame.
apply "value-changed" to br-dis-time-rule in frame Dialog-Frame.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
if not available X_dis-time-rule then return no-apply.
  run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-dis-rule IN FRAME Dialog-Frame
DO:
   DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define variable v-sts as integer no-undo init ?.
    IF NOT AVAILABLE X_dis-time-rule THEN RETURN no-apply.
    IF X_dis-time-rule.sts = INTEGER('1':U) THEN RETURN NO-APPLY.
    IF X_dis-time-rule.sts = INTEGER('2':U) THEN RETURN NO-APPLY.
    run ref/dis-ruls.w (
                 input parParentProc
                ,input 0
                ,input "":U
                ,input 0
                ,input "":U
                ,input "time-rule-num":U
                ,input 0
                ,input X_dis-time-rule.time-rule-num
                ,input 0
                ,input-output v-sts
                ,input-output v-rid-list ) no-error .
    APPLY "ENTRY" TO br-dis-time-rule.
END.
ON CHOOSE OF B-dis-time-rules IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-sts as integer no-undo init ?.
 IF NOT AVAILABLE X_dis-time-rule THEN RETURN no-apply.
  IF X_dis-time-rule.sts = INTEGER('1':U) THEN RETURN NO-APPLY.
  if X_dis-time-rule.uniq-field <> "":U
  and X_dis-time-rule.time-rule-num > 99999
  then do:
    v-sts = integer('2':U).
  end.
  run ref/dist-rls.w (
               input parParentProc
              ,input "b-add":U
              ,input "upper-time-rule-num":U
              ,input 0
              ,input X_dis-time-rule.time-rule-num
              ,input p-pos-type
              ,input-output v-sts
              ,input-output v-rid-list ) no-error .
  APPLY "ENTRY" TO br-dis-time-rule.
END.
ON CHOOSE OF b-history IN FRAME Dialog-Frame
DO:
  define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if NOT available X_dis-time-rule then return no-apply.
  loc-doc-rec = recid (X_dis-time-rule).
  run ref/disctrls.w (
                   INPUT parParentProc
                  ,input "":U
                  ,input (if X_dis-time-rule.uniq-field = "":U then "one":U else "rl-root":U)
                  ,input X_dis-time-rule.time-rule-num
                  ,input X_dis-time-rule.upper-time-rule-num
                  ,input-output v-rid-list ).
  apply "entry" to br-dis-time-rule in frame Dialog-Frame.
  apply "value-changed" to br-dis-time-rule in frame Dialog-Frame.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_dis-time-rule then return no-apply.
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_discount_work':U
    ,input  'global':U
    ,input  0
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
ASSIGN
loc-doc-rec = recid(X_dis-time-rule)
.
run ref/dis-timi.w
              (
                 input parParentProc
                ,input 'ПРОСМОТР':U
                ,input X_dis-time-rule.templ-rl-root
                ,input X_dis-time-rule.time-rule-num
                ,input X_dis-time-rule.upper-time-rule-num
                ,input-output loc-doc-rec
                            ) no-error
.
apply "entry" to br-dis-time-rule in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo .
  if available X_dis-time-rule then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid17 as character no-undo .
define variable v-num-entry17 as integer   no-undo .
assign
  v-str-recid17 = trim( string( recid( X_dis-time-rule ) , "->>>>>>>>>>>9":U ) )
  v-num-entry17 = lookup( v-str-recid17 , v-rid-list )
.
if v-num-entry17 > 0 then do:
  assign
    entry( v-num-entry17, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid17
  .
end.
    loc#log = br-dis-time-rule:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-dis-time-rule:select-next-row ().
        apply "VALUE-CHANGED" to br-dis-time-rule in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-dis-time-rule in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-dis-time-rule.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
    if ( available X_dis-time-rule ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_dis-time-rule ) ) .
  end.
END.
ON CHOOSE OF B-stat IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
  IF NOT AVAILABLE X_dis-time-rule THEN RETURN NO-APPLY.
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_discount_work':U
    ,input  'global':U
    ,input  0
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
v-doc-rec = recid(X_dis-time-rule).
 RUN proc-b-stat IN THIS-PROCEDURE ( input recid(X_dis-time-rule)) NO-ERROR.
 IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
 RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
 REPOSITION br-dis-time-rule to recid v-doc-rec No-ERROR.
END.
ON RETURN OF br-dis-time-rule IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-dis-time-rule IN FRAME Dialog-Frame
    DO:
    run proc-br-dis-time-rule no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF br-dis-time-rule IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_dis-time-rule  THEN DO:
    ASSIGN
    v-des = X_dis-time-rule.des
    .
  END.
  ELSE DO:
    ASSIGN
    v-des = "":U.
  END.
  DISPLAY
  v-des
  WITH FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF RS-sts IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-sts
  p-sts = (IF rs-sts = 'все':U THEN ? ELSE INTEGER(rs-sts))
  .
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-dis-time-rule :handle
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var sort-labelbr-dis-time-rule   as character no-undo .
def var sort-clmnbr-dis-time-rule    as handle    no-undo .
def var cur-clmnbr-dis-time-rule     as handle    no-undo .
def var cur-clmn-locbr-dis-time-rule as integer   no-undo .
def var re-querybr-dis-time-rule     as logical   initial no no-undo .
on start-search, ctrl-o of br-dis-time-rule in frame Dialog-Frame do:
   run sort-brbr-dis-time-rule
     (input (if available tt-template_dis-time-rule
             then recid(tt-template_dis-time-rule)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-dis-time-rule :
  define input parameter p-recid as recid no-undo .
  if re-querybr-dis-time-rule = no then do:
    assign
       cur-clmnbr-dis-time-rule = br-dis-time-rule:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-dis-time-rule <> ? then sort-clmnbr-dis-time-rule:column-fgcolor = 0.
    if cur-clmnbr-dis-time-rule = sort-clmnbr-dis-time-rule then do:
      assign
         sort-labelbr-dis-time-rule = ""
         sort-clmnbr-dis-time-rule = ?
      .
     end.
     else do:
       assign
         sort-labelbr-dis-time-rule = cur-clmnbr-dis-time-rule:label
         sort-clmnbr-dis-time-rule  = cur-clmnbr-dis-time-rule
         sort-clmnbr-dis-time-rule:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-dis-time-rule = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-dis-time-rule:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-dis-time-rule then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-dis-time-rule = cur-clmn-locbr-dis-time-rule + 1
    .
  end.
  case sort-labelbr-dis-time-rule:
        when X_dis-time-rule.time-rule-num:label in browse br-dis-time-rule then DO:    assign       sort-column-name = "X_dis-time-rule.time-rule-num"     .     run OpenBr in this-procedure ( input YES, input NO, input '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input YES, input NO, input '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-dis-time-rule') then do:
          run mv-brw-defaultbr-dis-time-rule.
        end.
      if sort-labelbr-dis-time-rule <> "" then do:
        assign
          cur-clmnbr-dis-time-rule:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-dis-time-rule = ?
      .
    end.
  end case.
    if cur-clmn-locbr-dis-time-rule <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-dis-time-rule') then do:
        run ch-clmnbr-dis-time-rule in this-procedure (cur-clmn-locbr-dis-time-rule).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-dis-time-rule to recid p-recid no-error.
    apply "value-changed" to br-dis-time-rule in frame Dialog-Frame.
  end.
  apply "entry" to br-dis-time-rule in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-dis-time-rule:
if cur-clmnbr-dis-time-rule = ? then do:
   run OpenBr in this-procedure ( input YES, input NO, input '':U).
end.
else do:
   assign re-querybr-dis-time-rule = yes.
   run sort-brbr-dis-time-rule
     (input (if available tt-template_dis-time-rule
             then recid(tt-template_dis-time-rule)
             else ?
            )
     ).
   assign re-querybr-dis-time-rule = no.
end.
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-doc-rec = recid(X_dis-time-rule). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-dis-time-rule to recid v-doc-rec no-error. v-doc-rec = ?.   apply 'entry' to br-dis-time-rule in frame Dialog-Frame.    apply 'value-changed' to br-dis-time-rule in frame Dialog-Frame.
    apply "VALUE-CHANGED" to br-dis-time-rule.
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-dis-time-rule :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lookup :sensitive then DO: apply "CHOOSE":U to b-lookup in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ALT-F8 of frame Dialog-Frame anywhere do:
  if b-history :sensitive then DO: apply "CHOOSE":U to b-history in frame Dialog-Frame. END.
  return no-apply.
end.
on f6 anywhere do:
define buffer buf0_dis-time-rule for ub.dis-time-rule.
find first buf0_dis-time-rule no-lock where
        buf0_dis-time-rule.time-rule-num = 0 + 50000 no-error .
if available buf0_dis-time-rule then do:
  message
  "Версия структуры расписаний" buf0_dis-time-rule.des
  view-as alert-box .
end.
else do:
  message
  "Не найдена головная запись структуры расписаний!"
  view-as alert-box error .
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 if LOOKUP(p-mode, ('все':U + chr(4) +
                    "upper-time-rule-num":U + chr(4) +
                    "template":U + chr(4) +
                    "rule-num" + chr(4) +
                    'dis-rule':U +  chr(4) +
                    ("rule-num" + chr(44) + 'ИЗМЕНЕНИЕ':U)
                    ),
                chr(4)) = 0
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 if p-mode = "upper-time-rule-num" then do:
   find first X_upper-dis-time-rule no-lock where
          X_upper-dis-time-rule.time-rule-num = p-upper-time-rule-num no-error.
   if not available X_upper-dis-time-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-upper-time-rule-num"
    p-upper-time-rule-num
    view-as alert-box ERROR.
    return error .
   end.
   if X_upper-dis-time-rule.time-rule-num > 99999
   and (lookup(bttns, "b-sel") > 0 or lookup(bttns, "b-mark") > 0) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова bttn или p-upper-time-rule-num"
    bttns p-upper-time-rule-num
    view-as alert-box ERROR.
    return error .
   end.
  end.
  IF p-mode = 'dis-rule':U
  or p-mode = "rule-num" + chr(44) + 'ИЗМЕНЕНИЕ':U
  OR p-mode = "rule-num":U
  THEN do:
    FIND FIRST X_dis-rule NO-LOCK WHERE
              X_dis-rule.rule-num = p-rule-num NO-ERROR.
    IF NOT AVAILABLE X_dis-rule THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-rule-num"
        p-rule-num
        view-as alert-box ERROR.
        return error .
    END.
  END.
  v-rid-list = p-rid-list.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
  RUN fill-tables IN THIS-PROCEDURE ( IF AVAILABLE X_dis-rule THEN X_dis-rule.templ-rl-root else 0) NO-ERROR.
 IF ERROR-STATUS:ERROR THEN UNDO main-block, RETURN ERROR.
  RUN MyEnable in this-procedure .
  assign
  v-doc-rec = integer(entry(1, v-rid-list))
  .
  RUn OpenBR IN THIS-PROCEDURE ( input YES, input NO, input '':U).
  REPOSITION br-dis-time-rule to recid v-doc-rec No-ERROR.
  HIDE mark-num in frame Dialog-Frame .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-dis-time-rule as INT EXTENT 12 no-undo.
DEF VAR varmvibr-dis-time-rule       as INT no-undo.
DEF VAR varmvjbr-dis-time-rule       as INT no-undo.
DEF VAR varmvkbr-dis-time-rule       as INT no-undo.
DEF VAR varmvlbr-dis-time-rule       as INT no-undo.
DEF VAR move-elementbr-dis-time-rule as INT no-undo.
def var jjbr-dis-time-rule           as int no-undo.
do varmvibr-dis-time-rule = 1 to EXTENT(cur-clmn-numbr-dis-time-rule):
  ASSIGN cur-clmn-numbr-dis-time-rule[varmvibr-dis-time-rule] = varmvibr-dis-time-rule.
END.
RUN start-mv-clmnbr-dis-time-rule.
PROCEDURE start-mv-clmnbr-dis-time-rule:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  p-mode = 'все':U or p-mode = 'template':U  THEN DO:
   DO jjbr-dis-time-rule = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10,11,12') TO 1 BY -1:
     RUN re-move-clmnbr-dis-time-rule ( cur-clmn-numbr-dis-time-rule[INTEGER(ENTRY (jjbr-dis-time-rule, '1,2,3,4,5,6,7,8,9,10,11,12'))] , 1).
   END.
       END.
       IF  p-mode = 'upper-time-rule-num':U  THEN DO:
   DO jjbr-dis-time-rule = NUM-ENTRIES('1,2,3,4,8,9,10,11,5,6,7,12') TO 1 BY -1:
     RUN re-move-clmnbr-dis-time-rule ( cur-clmn-numbr-dis-time-rule[INTEGER(ENTRY (jjbr-dis-time-rule, '1,2,3,4,8,9,10,11,5,6,7,12'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-dis-time-rule do:
  RUN re-move-clmnbr-dis-time-rule ( 1, 12).
END.
ON ctrl-cursor-left OF BROWSE br-dis-time-rule do:
  RUN re-move-clmnbr-dis-time-rule (12, 1).
END.
PROCEDURE re-move-clmnbr-dis-time-rule:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-dis-time-rule = 1 TO EXTENT(cur-clmn-numbr-dis-time-rule):
    if cur-clmn-numbr-dis-time-rule[varmvibr-dis-time-rule] = source-column THEN cur-clmn-numbr-dis-time-rule[varmvibr-dis-time-rule] = -1.
  END.
  if br-dis-time-rule:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-dis-time-rule = source-column - 1 to target-column BY -1:
    DO varmvibr-dis-time-rule = 1 TO EXTENT(cur-clmn-numbr-dis-time-rule):
        if cur-clmn-numbr-dis-time-rule[varmvibr-dis-time-rule] = varmvjbr-dis-time-rule THEN DO:
          cur-clmn-numbr-dis-time-rule[varmvibr-dis-time-rule] = cur-clmn-numbr-dis-time-rule[varmvibr-dis-time-rule] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-dis-time-rule = source-column + 1 to target-column:
    DO varmvibr-dis-time-rule = 1 TO EXTENT(cur-clmn-numbr-dis-time-rule):
      if cur-clmn-numbr-dis-time-rule[varmvibr-dis-time-rule] = varmvjbr-dis-time-rule THEN DO:
        cur-clmn-numbr-dis-time-rule[varmvibr-dis-time-rule] = cur-clmn-numbr-dis-time-rule[varmvibr-dis-time-rule] - 1.
      END.
    END.
  END.
  DO varmvibr-dis-time-rule = 1 TO EXTENT(cur-clmn-numbr-dis-time-rule):
    if cur-clmn-numbr-dis-time-rule[varmvibr-dis-time-rule] = -1 THEN cur-clmn-numbr-dis-time-rule[varmvibr-dis-time-rule] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-dis-time-rule:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-dis-time-rule = 1 TO EXTENT(cur-clmn-numbr-dis-time-rule):
    if cur-clmn-numbr-dis-time-rule[varmvibr-dis-time-rule] = cur-clmn-loc THEN move-elementbr-dis-time-rule = varmvibr-dis-time-rule.
  END.
  RUN re-move-clmnbr-dis-time-rule (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-dis-time-rule:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-dis-time-rule = 1 to EXTENT(cur-clmn-numbr-dis-time-rule):
    RUN re-move-clmnbr-dis-time-rule (cur-clmn-numbr-dis-time-rule[varmvlbr-dis-time-rule], varmvlbr-dis-time-rule).
  END.
  RUN start-mv-clmnbr-dis-time-rule.
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
  DISPLAY RS-sts mark-num v-des
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-lookup B-chg B-del B-stat B-print
         b-history B-sch B-Help B-dis-time-rules B-dis-rule RS-sts
         br-dis-time-rule mark-num v-des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule NO-LOCK,              EACH tt-template_dis-time-rule OF ub.X_dis-time-rule  NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE fill-tables :
define input parameter p-templ-rl-root as integer no-undo .
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-time-template-list AS character NO-UNDO.
DEFINE VARIABLE v-entry AS character NO-UNDO.
define variable v-pos-type as character no-undo .
FOR EACH tt-template_dis-time-rule:
    DELETE tt-template_dis-time-rule.
END.
CASE p-mode:
    WHEN 'все':U THEN DO:
      FOR EACH buf_dis-time-rule NO-LOCK WHERE
                buf_dis-time-rule.time-rule-num < 99999:
         CREATE tt-template_dis-time-rule.
         BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
      END.
    END.
    WHEN "template" THEN DO:
        FOR EACH buf_dis-time-rule NO-LOCK WHERE
                        buf_dis-time-rule.time-rule-num < 99999:
                 CREATE tt-template_dis-time-rule.
                 BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
              END.
    END.
    WHEN "upper-time-rule-num" THEN DO:
        FOR EACH buf_dis-time-rule NO-LOCK WHERE
                        buf_dis-time-rule.templ-rl-root = X_upper-dis-time-rule.templ-rl-root:
                 CREATE tt-template_dis-time-rule.
                 BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
              END.
    END.
    WHEN 'dis-rule':U then do:
      for each buf_dis-cfg-rule no-lock where
              buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root:
        if buf_dis-cfg-rule.time-templ-rl-root <= 0 then next.
        if p-pos-type <> ''
        and buf_dis-cfg-rule.pos-type <> p-pos-type then next.
        FIND FIRST buf_dis-time-rule NO-LOCK WHERE
                buf_dis-time-rule.time-rule-num = buf_dis-cfg-rule.time-templ-rl-root  NO-ERROR.
        IF NOT AVAILABLE buf_dis-time-rule THEN DO:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова p-rule-num" p-rule-num skip
          "Ссылка на расписание c time-rule-num " buf_dis-cfg-rule.time-templ-rl-root
          view-as alert-box ERROR.
          return error .
        END.
        find first tt-template_dis-time-rule no-lock where
                  tt-template_dis-time-rule.templ-rl-root = buf_dis-time-rule.templ-rl-root no-error.
        if not available tt-template_dis-time-rule then do:
          CREATE tt-template_dis-time-rule.
          BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
        end.
      end.
    END.
    WHEN ("rule-num" + chr(44) + 'ИЗМЕНЕНИЕ':U) THEN DO:
      FOR EACH buf_dis-rule NO-LOCK WHERE
        buf_dis-rule.rule-num = p-rule-num,
        FIRST buf_dis-time-rule no-lock WHERE
            buf_dis-time-rule.time-rule-num = buf_dis-rule.time-templ-rl-root:
        find first tt-template_dis-time-rule no-lock where
                  tt-template_dis-time-rule.templ-rl-root = buf_dis-time-rule.templ-rl-root no-error.
        if not available tt-template_dis-time-rule then do:
          CREATE tt-template_dis-time-rule.
          BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
        end.
      END.
      find first buf_dis-rule NO-LOCK WHERE
        buf_dis-rule.rule-num = p-rule-num no-error.
      if buf_dis-rule.time-templ-rl-root = 0 then do:
        for each buf_dis-cfg-rule no-lock where
                buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
            and buf_dis-cfg-rule.time-templ-rl-root > 0
                :
          if v-pos-type <> ''
          and v-pos-type <> buf_dis-cfg-rule.pos-type then do:
            run ref/dcr-pos.p (
                              input p-mode
                              ,input no
                              ,input p-templ-rl-root
                              ,input buf_dis-rule.host-code
                              ,input buf_dis-rule.obj-type
                              ,input buf_dis-rule.obj-code
                              ,input buf_dis-rule.sts
                              ,input buf_dis-rule.rule-num
                              ,output v-pos-type) no-error.
            leave.
          end.
          v-pos-type = buf_dis-cfg-rule.pos-type.
        end.
        for each buf_dis-cfg-rule no-lock where
                buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
           and  buf_dis-cfg-rule.pos-type = v-pos-type,
          FIRST buf_dis-time-rule no-lock WHERE
              buf_dis-time-rule.time-rule-num = buf_dis-cfg-rule.time-templ-rl-root:
          find first tt-template_dis-time-rule no-lock where
                    tt-template_dis-time-rule.templ-rl-root = buf_dis-time-rule.templ-rl-root no-error.
          if not available tt-template_dis-time-rule then do:
            CREATE tt-template_dis-time-rule.
            BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
          end.
        END.
      end.
    END.
    WHEN "rule-num" THEN DO:
      FOR EACH buf_dis-rule NO-LOCK WHERE
        buf_dis-rule.upper-rule-num = p-rule-num,
        FIRST buf_dis-time-rule no-lock WHERE
            buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num:
        find first tt-template_dis-time-rule no-lock where
                  tt-template_dis-time-rule.templ-rl-root = buf_dis-time-rule.templ-rl-root no-error.
        if not available tt-template_dis-time-rule then do:
          CREATE tt-template_dis-time-rule.
          BUFFER-COPY buf_dis-time-rule to tt-template_dis-time-rule.
        end.
      END.
    END.
END CASE.
END PROCEDURE.
PROCEDURE get-tree :
DEFINE PARAMETER BUFFER loc_dis-time-rule for ub.dis-time-rule.
define output parameter p-display-time-from as character no-undo .
define output parameter p-display-time-to as character no-undo .
define output parameter p-display-date-from as character no-undo .
define output parameter p-display-date-to as character no-undo .
define output parameter p-display-week-day-0 as character no-undo .
define output parameter p-display-week-day-1 as character no-undo .
define output parameter p-display-week-day-2 as character no-undo .
define output parameter p-display-week-day-3 as character no-undo .
define output parameter p-display-week-day-4 as character no-undo .
define output parameter p-display-week-day-5 as character no-undo .
define output parameter p-display-week-day-6 as character no-undo .
define output parameter p-display-week-day-7 as character no-undo .
define output parameter p-display-month-day as character no-undo .
define output parameter p-using-fields as character no-undo .
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO INIT ?.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
define variable v-level-1 as character no-undo .
define variable v-level-2 as character no-undo .
define variable v-curr-level as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
IF loc_dis-time-rule.uniq-field <> "":U
  AND loc_dis-time-rule.upper-time-rule-num <= 99999 THEN DO:
  DO ii = 1 TO NUM-ENTRIES(loc_dis-time-rule.uniq-field):
    v-entry = ENTRY(ii, loc_dis-time-rule.uniq-field).
    CASE v-entry:
        WHEN "time-from" THEN DO:
            ASSIGN
            p-display-time-from = "...    ".
        END.
        WHEN "time-to" THEN DO:
            ASSIGN
            p-display-time-to = "...    ".
        END.
        WHEN "time-period" THEN DO:
            ASSIGN
            p-display-time-from = "...    "
            p-display-time-to = "...    ".
        END.
        WHEN "date-from" THEN DO:
            ASSIGN
            p-display-date-from = "...    ".
        END.
        WHEN "date-to" THEN DO:
            ASSIGN
            p-display-date-to = "...    ".
        END.
        WHEN "date-period" THEN DO:
            ASSIGN
            p-display-date-from = "...    "
            p-display-date-to = "...    ".
        END.
        WHEN "week-day-0" THEN DO:
            ASSIGN
            p-display-week-day-0 = "...    ".
        END.
        WHEN "week-day-1" THEN DO:
            ASSIGN
            p-display-week-day-1 = "...    ".
        END.
        WHEN "week-day-2" THEN DO:
            ASSIGN
            p-display-week-day-2 = "...    ".
        END.
        WHEN "week-day-3" THEN DO:
            ASSIGN
            p-display-week-day-3 = "...    ".
        END.
        WHEN "week-day-4" THEN DO:
            ASSIGN
            p-display-week-day-4 = "...    ".
        END.
        WHEN "week-day-5" THEN DO:
            ASSIGN
            p-display-week-day-5 = "...    ".
        END.
        WHEN "week-day-6" THEN DO:
            ASSIGN
            p-display-week-day-6 = "...    ".
        END.
        WHEN "week-day-7" THEN DO:
            ASSIGN
            p-display-week-day-7 = "...    ".
        END.
        WHEN "month-day" THEN DO:
            ASSIGN
            p-display-month-day = "...    ".
        END.
        when "week-day-a" then do:
            ASSIGN
            p-display-week-day-0 = "...    "
            p-display-week-day-1 = "...    "
            p-display-week-day-2 = "...    "
            p-display-week-day-3 = "...    "
            p-display-week-day-4 = "...    "
            p-display-week-day-5 = "...    "
            p-display-week-day-6 = "...    "
            p-display-week-day-7 = "...    ".
        end.
        when "week-day-b" then do:
            ASSIGN
            p-display-week-day-1 = "...    "
            p-display-week-day-2 = "...    "
            p-display-week-day-3 = "...    "
            p-display-week-day-4 = "...    "
            p-display-week-day-5 = "...    "
            p-display-week-day-6 = "...    "
            p-display-week-day-7 = "...    ".
        end.
        when "week-day-c" then do:
            if lookup("week-day-1", loc_dis-time-rule.uniq-field) > 0 then
            ASSIGN
            p-display-week-day-1 = "...    ".
            if lookup("week-day-2", loc_dis-time-rule.uniq-field) > 0 then
            p-display-week-day-2 = "...    ".
            if lookup("week-day-3", loc_dis-time-rule.uniq-field) > 0 then
            p-display-week-day-3 = "...    ".
            if lookup("week-day-4", loc_dis-time-rule.uniq-field) > 0 then
            p-display-week-day-4 = "...    ".
            if lookup("week-day-5", loc_dis-time-rule.uniq-field) > 0 then
            p-display-week-day-5 = "...    ".
            if lookup("week-day-6", loc_dis-time-rule.uniq-field) > 0 then
            p-display-week-day-6 = "...    ".
            if lookup("week-day-7", loc_dis-time-rule.uniq-field) > 0 then
            p-display-week-day-7 = "...    ".
        end.
    END CASE.
  END.
END.
else do:
find first buf_Dis-cfg-rule no-lock where
          buf_Dis-cfg-rule.time-templ-rl-root = loc_dis-time-rule.templ-rl-root
     and  buf_Dis-cfg-rule.table-name = '':U
     and  buf_Dis-cfg-rule.pos-type = '':U
     and  buf_Dis-cfg-rule.discnt-role = '':U
     and  buf_Dis-cfg-rule.self-nonunique = '':U
     and buf_Dis-cfg-rule.templ-rl-root = 0 no-error .
if error-status:error then do:
end.
  assign
  v-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
  v-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                else '')
  p-using-fields = (if loc_dis-time-rule.upper-time-rule-num <= 99999
                  then v-level-1
                  else v-level-2).
  ASSIGN
  p-display-time-from = (if lookup("time-from", p-using-fields) = 0
                         then "":U else string(loc_dis-time-rule.time-from, "HH:MM"))
  p-display-time-to = (if lookup("time-to", p-using-fields) = 0
                       then "":U else string(loc_dis-time-rule.time-to, "HH:MM"))
  p-display-date-from = (if lookup("date-from", p-using-fields) = 0
                         then "":U else string(loc_dis-time-rule.date-from, "99/99/9999"))
  p-display-date-to = (if lookup("date-to", p-using-fields) = 0
                       then "":U else string(loc_dis-time-rule.date-to, "99/99/9999"))
  p-display-week-day-0 = (if lookup("week-day-0", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-0, "*/":U))
  p-display-week-day-1 = (if lookup("week-day-1", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-1, "Пн/":U))
  p-display-week-day-2 = (if lookup("week-day-2", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-2, "Вт/":U))
  p-display-week-day-3 = (if lookup("week-day-3", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-3, "Ср/":U))
  p-display-week-day-4 = (if lookup("week-day-4", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-4, "Чт/":U))
  p-display-week-day-5 = (if lookup("week-day-5", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-5, "Птн/":U))
  p-display-week-day-6 = (if lookup("week-day-6", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-6, "Сб/":U))
  p-display-week-day-7 = (if lookup("week-day-7", p-using-fields) = 0
                          then "":U else string(loc_dis-time-rule.week-day-7, "Вс/":U))
  p-display-month-day = (if lookup("month-day", p-using-fields) = 0
                         then "":U else string(loc_dis-time-rule.month-day, "99"))
  .
end.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-rule-num LIKE ub.dis-time-rule.time-rule-num NO-UNDO.
define variable  v-des               like ub.dis-time-rule.des               no-undo .
define variable v-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
define variable v-value-type        like ub.dis-time-rule.value-type        no-undo .
define variable vt-level-1 as character no-undo .
define variable vt-level-2 as character no-undo .
define variable v-output-display as logical   no-undo .
define variable v-tree              as character no-undo .
define variable v-other          as character no-undo .
ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME Dialog-Frame
                       = "Используемые&+" + chr(44) +  '0':U + chr(44) +
                       "Все&!" + chr(44) + 'все':U + chr(44) +
                        "Неиспользуемые&-" + chr(44) + '1':U
rs-sts = (IF p-sts = ? THEN 'все':U ELSE string(p-sts))
.
    run dtr-code  in this-procedure (
     input  p-upper-time-rule-num
    ,output v-des
    ,output v-upper-time-rule-num
    ,output v-value-type
    ,output vt-level-1
    ,output vt-level-2
    ,output v-output-display
    ,output v-tree
    ,output v-other
                               )  NO-ERROR.
DISPLAY mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-add when (LOOKUP("b-add":U, bttns) > 0
            and not transaction)
B-lookup
B-chg when (LOOKUP("b-add":U, bttns) > 0
           and not transaction)
B-del when (LOOKUP("b-add":U, bttns) > 0
            and p-mode = "upper-time-rule-num":U
            AND X_upper-dis-time-rule.upper-time-rule-num  = 0
            AND p-upper-time-rule-num <> 0
            and not transaction)
B-print
B-Help
b-history
B-dis-time-rules WHEN p-mode = "template":U OR p-upper-time-rule-num = 0 or v-tree <> "":U
br-dis-time-rule
b-dis-rule WHEN p-mode <> "template":U and p-upper-time-rule-num <> 0
b-sch
mark-num
rs-sts when not (p-mode = "template":U or p-upper-time-rule-num = 50000)
b-stat when LOOKUP("b-add", bttns) > 0
with FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
IF (p-mode <> "template":U and p-mode <> 'все':U) or p-upper-time-rule-num <> 0 THEN DO:
  assign
  b-dis-time-rules:label in frame Dialog-Frame = "Детально"
  .
END.
if p-mode = "template"
or p-upper-time-rule-num = 0 then do:
  DISABLE
  rs-sts
  b-stat
  with FRAME Dialog-Frame.
end.
if p-mode = "upper-time-rule-num" and X_upper-dis-time-rule.time-rule-num > 99999 then do:
  HIDE
  b-add
  b-chg
  b-del
  b-stat
  IN FRAME Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo init "Список расписаний".
define variable p-host-code like ub.sysconf.host-code no-undo .
run waitfram-show in this-procedure (  input "Ждите...").
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
     assign
     filter-point = filter-point0 + p-mode
     filter-label = substitute("&1", filter-label0)
     .
     IF p-sts = -1  THEN DO:
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
                              "FOR EACH X_dis-time-rule no-lock"
      parameter-4-37 =
        (
          if (" TRUE " + " " + where-phrase-37) <> ""
          then " TRUE " + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root")
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
          (" TRUE " + " " + where-phrase-37 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
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
    OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule no-lock
      where  TRUE
    , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-time-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-time-rule:handle:get-buffer-handle(1) = (buffer X_dis-time-rule:handle) then do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-4-37 =
        "where ":u + " TRUE " + " ":u + where-phrase-37 + " ":u + p-find-condition + " " + ""
      parameter-5-37 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
                          ,input rowid(X_dis-time-rule)
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input (buffer X_dis-time-rule:handle)
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
      parameter-3-37 =  "FOR EACH X_dis-time-rule no-lock"
      parameter-4-37 =
        (
          if (" TRUE " + " " + where-phrase-37) <> ""
          then " TRUE " + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root" + " " + p-find-condition)
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
                          ,input QUERY br-dis-time-rule:handle
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
          ASSIGN
          frame Dialog-Frame:TITLE = title0 + chr(32) + entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U)
          filter-label = substitute("&1  с определенным статусом", filter-label0, entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
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
                              "FOR EACH X_dis-time-rule no-lock"
      parameter-4-39 =
        (
          if (" X_dis-time-rule.sts = p-sts " + " " + where-phrase-39) <> ""
          then  substitute('X_dis-time-rule.sts = &1', p-sts ) + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root")
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
          (" X_dis-time-rule.sts = p-sts " + " " + where-phrase-39 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
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
    OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule no-lock
      where  X_dis-time-rule.sts = p-sts
    , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-time-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-time-rule:handle:get-buffer-handle(1) = (buffer X_dis-time-rule:handle) then do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-4-39 =
        "where ":u +  substitute('X_dis-time-rule.sts = &1', p-sts ) + " ":u + where-phrase-39 + " ":u + p-find-condition + " " + ""
      parameter-5-39 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
                          ,input rowid(X_dis-time-rule)
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input (buffer X_dis-time-rule:handle)
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
      parameter-3-39 =  "FOR EACH X_dis-time-rule no-lock"
      parameter-4-39 =
        (
          if (" X_dis-time-rule.sts = p-sts " + " " + where-phrase-39) <> ""
          then  substitute('X_dis-time-rule.sts = &1', p-sts ) + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root" + " " + p-find-condition)
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
                          ,input QUERY br-dis-time-rule:handle
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
    WHEN "upper-time-rule-num":U THEN DO:
       assign
       filter-point = filter-point0 + p-mode
       .
       if X_upper-dis-time-rule.time-rule-num > 99999
       then
       ASSIGN
       frame Dialog-Frame:TITLE = title0 +
                                   substitute(" Расписание №&1: &2: Детализация"
                                   , X_upper-dis-time-rule.time-rule-num
                                   , X_upper-dis-time-rule.des
                                   )
       filter-label = substitute("&1 Детализация", filter-label0)
                                   .
      else
       ASSIGN
       frame Dialog-Frame:TITLE = title0 +
                                   substitute(" Расписания типа: &1 &2"
                                   , X_upper-dis-time-rule.des
                                   , (if p-sts = -1 then "":U else  entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
                                   )
       filter-label = substitute("&1 Расписания одного типа", filter-label0)
                                   .
      IF p-sts = -1 THEN DO:
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
                              "FOR EACH X_dis-time-rule no-lock"
      parameter-4-41 =
        (
          if (" X_dis-time-rule.upper-time-rule-num  = p-upper-time-rule-num                         " + " " + where-phrase-41) <> ""
          then  substitute('X_dis-time-rule.upper-time-rule-num  = &1', p-upper-time-rule-num )   + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root")
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
          (" X_dis-time-rule.upper-time-rule-num  = p-upper-time-rule-num                         " + " " + where-phrase-41 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
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
    OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule no-lock
      where  X_dis-time-rule.upper-time-rule-num  = p-upper-time-rule-num
    , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-time-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-time-rule:handle:get-buffer-handle(1) = (buffer X_dis-time-rule:handle) then do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-4-41 =
        "where ":u +  substitute('X_dis-time-rule.upper-time-rule-num  = &1', p-upper-time-rule-num )   + " ":u + where-phrase-41 + " ":u + p-find-condition + " " + ""
      parameter-5-41 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
                          ,input rowid(X_dis-time-rule)
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input (buffer X_dis-time-rule:handle)
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
      parameter-3-41 =  "FOR EACH X_dis-time-rule no-lock"
      parameter-4-41 =
        (
          if (" X_dis-time-rule.upper-time-rule-num  = p-upper-time-rule-num                         " + " " + where-phrase-41) <> ""
          then  substitute('X_dis-time-rule.upper-time-rule-num  = &1', p-upper-time-rule-num )   + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root" + " " + p-find-condition)
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
                          ,input QUERY br-dis-time-rule:handle
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
                              "FOR EACH X_dis-time-rule no-lock"
      parameter-4-43 =
        (
          if (" X_dis-time-rule.upper-time-rule-num  = p-upper-time-rule-num                 AND X_dis-time-rule.sts = p-sts " + " " + where-phrase-43) <> ""
          then  substitute('X_dis-time-rule.upper-time-rule-num  = &1                 AND X_dis-time-rule.sts = &2 ', p-upper-time-rule-num, p-sts)  + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root")
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
          (" X_dis-time-rule.upper-time-rule-num  = p-upper-time-rule-num                 AND X_dis-time-rule.sts = p-sts " + " " + where-phrase-43 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
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
    OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule no-lock
      where  X_dis-time-rule.upper-time-rule-num  = p-upper-time-rule-num                 AND X_dis-time-rule.sts = p-sts
    , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-time-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-time-rule:handle:get-buffer-handle(1) = (buffer X_dis-time-rule:handle) then do:
      assign
      parameter-2-43 = (if p-find-next then "true":u else "false":u )
      parameter-4-43 =
        "where ":u +  substitute('X_dis-time-rule.upper-time-rule-num  = &1                 AND X_dis-time-rule.sts = &2 ', p-upper-time-rule-num, p-sts)  + " ":u + where-phrase-43 + " ":u + p-find-condition + " " + ""
      parameter-5-43 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
                          ,input rowid(X_dis-time-rule)
                          ,input logical(parameter-2-43)
                          ,input no-lock
                          ,input (buffer X_dis-time-rule:handle)
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
      parameter-3-43 =  "FOR EACH X_dis-time-rule no-lock"
      parameter-4-43 =
        (
          if (" X_dis-time-rule.upper-time-rule-num  = p-upper-time-rule-num                 AND X_dis-time-rule.sts = p-sts " + " " + where-phrase-43) <> ""
          then  substitute('X_dis-time-rule.upper-time-rule-num  = &1                 AND X_dis-time-rule.sts = &2 ', p-upper-time-rule-num, p-sts)  + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root" + " " + p-find-condition)
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
                          ,input QUERY br-dis-time-rule:handle
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
    WHEN "template":U THEN DO:
       filter-point = filter-point0 + p-mode.
       ASSIGN
       frame Dialog-Frame:TITLE =  substitute(" Типы расписаний (Шаблоны) &1"
                                               ,(if p-sts = -1 then "":U else  entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
                                               )
       filter-label = substitute("&1 Шаблоны расписаний", filter-label0)
                                               .
      IF p-sts = -1 THEN DO:
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
                              "FOR EACH X_dis-time-rule no-lock"
      parameter-4-45 =
        (
          if ("  X_dis-time-rule.time-rule-num  <= 99999                          " + " " + where-phrase-45) <> ""
          then   substitute('X_dis-time-rule.time-rule-num  <= &1', 99999)   + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root")
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
          ("  X_dis-time-rule.time-rule-num  <= 99999                          " + " " + where-phrase-45 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
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
    OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule no-lock
      where   X_dis-time-rule.time-rule-num  <= 99999
    , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-time-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-time-rule:handle:get-buffer-handle(1) = (buffer X_dis-time-rule:handle) then do:
      assign
      parameter-2-45 = (if p-find-next then "true":u else "false":u )
      parameter-4-45 =
        "where ":u +   substitute('X_dis-time-rule.time-rule-num  <= &1', 99999)   + " ":u + where-phrase-45 + " ":u + p-find-condition + " " + ""
      parameter-5-45 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
                          ,input rowid(X_dis-time-rule)
                          ,input logical(parameter-2-45)
                          ,input no-lock
                          ,input (buffer X_dis-time-rule:handle)
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
      parameter-3-45 =  "FOR EACH X_dis-time-rule no-lock"
      parameter-4-45 =
        (
          if ("  X_dis-time-rule.time-rule-num  <= 99999                          " + " " + where-phrase-45) <> ""
          then   substitute('X_dis-time-rule.time-rule-num  <= &1', 99999)   + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root" + " " + p-find-condition)
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
                          ,input QUERY br-dis-time-rule:handle
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
                              "FOR EACH X_dis-time-rule no-lock"
      parameter-4-47 =
        (
          if (" X_dis-time-rule.time-rule-num  <= 99999                 AND X_dis-time-rule.sts = p-sts " + " " + where-phrase-47) <> ""
          then  substitute('X_dis-time-rule.time-rule-num  <= &1                 AND X_dis-time-rule.sts = &2 ', 99999, p-sts) + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root")
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
          (" X_dis-time-rule.time-rule-num  <= 99999                 AND X_dis-time-rule.sts = p-sts " + " " + where-phrase-47 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
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
    OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule no-lock
      where  X_dis-time-rule.time-rule-num  <= 99999                 AND X_dis-time-rule.sts = p-sts
    , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-time-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-time-rule:handle:get-buffer-handle(1) = (buffer X_dis-time-rule:handle) then do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-4-47 =
        "where ":u +  substitute('X_dis-time-rule.time-rule-num  <= &1                 AND X_dis-time-rule.sts = &2 ', 99999, p-sts) + " ":u + where-phrase-47 + " ":u + p-find-condition + " " + ""
      parameter-5-47 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
                          ,input rowid(X_dis-time-rule)
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input (buffer X_dis-time-rule:handle)
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
      parameter-3-47 =  "FOR EACH X_dis-time-rule no-lock"
      parameter-4-47 =
        (
          if (" X_dis-time-rule.time-rule-num  <= 99999                 AND X_dis-time-rule.sts = p-sts " + " " + where-phrase-47) <> ""
          then  substitute('X_dis-time-rule.time-rule-num  <= &1                 AND X_dis-time-rule.sts = &2 ', 99999, p-sts) + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root" + " " + p-find-condition)
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
                          ,input QUERY br-dis-time-rule:handle
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
    when 'dis-rule':U then do:
     filter-point = filter-point0 + p-mode.
      ASSIGN
      frame Dialog-Frame:TITLE =  substitute(" Расписания доступные для правил скидок с типом &1: &2"
                                              , X_dis-rule.des
                                              ,(if p-sts = -1 then "":U else  entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
                                              )
      filter-label = substitute("&1 доступные для правил скидок определенного типа", filter-label0)
                                              .
     IF p-sts = -1  THEN DO:
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
                              "FOR EACH X_dis-time-rule no-lock"
      parameter-4-49 =
        (
          if (" X_dis-time-rule.lvl-num = 1" + " " + where-phrase-49) <> ""
          then " X_dis-time-rule.lvl-num = 1" + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root")
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
          (" X_dis-time-rule.lvl-num = 1" + " " + where-phrase-49 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
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
    OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule no-lock
      where  X_dis-time-rule.lvl-num = 1
    , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-time-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-time-rule:handle:get-buffer-handle(1) = (buffer X_dis-time-rule:handle) then do:
      assign
      parameter-2-49 = (if p-find-next then "true":u else "false":u )
      parameter-4-49 =
        "where ":u + " X_dis-time-rule.lvl-num = 1" + " ":u + where-phrase-49 + " ":u + p-find-condition + " " + ""
      parameter-5-49 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
                          ,input rowid(X_dis-time-rule)
                          ,input logical(parameter-2-49)
                          ,input no-lock
                          ,input (buffer X_dis-time-rule:handle)
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
      parameter-3-49 =  "FOR EACH X_dis-time-rule no-lock"
      parameter-4-49 =
        (
          if (" X_dis-time-rule.lvl-num = 1" + " " + where-phrase-49) <> ""
          then " X_dis-time-rule.lvl-num = 1" + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root" + " " + p-find-condition)
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
                          ,input QUERY br-dis-time-rule:handle
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
          ASSIGN
          frame Dialog-Frame:TITLE = title0 + chr(32) + entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U).
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
                              "FOR EACH X_dis-time-rule no-lock"
      parameter-4-51 =
        (
          if (" X_dis-time-rule.sts = p-sts " + " " + where-phrase-51) <> ""
          then  substitute('X_dis-time-rule.sts = &1', p-sts)  + " " + where-phrase-51
          else "true"
        )
      parameter-5-51 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root")
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
          (" X_dis-time-rule.sts = p-sts " + " " + where-phrase-51 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
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
    OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule no-lock
      where  X_dis-time-rule.sts = p-sts
    , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-time-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-time-rule:handle:get-buffer-handle(1) = (buffer X_dis-time-rule:handle) then do:
      assign
      parameter-2-51 = (if p-find-next then "true":u else "false":u )
      parameter-4-51 =
        "where ":u +  substitute('X_dis-time-rule.sts = &1', p-sts)  + " ":u + where-phrase-51 + " ":u + p-find-condition + " " + ""
      parameter-5-51 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
                          ,input rowid(X_dis-time-rule)
                          ,input logical(parameter-2-51)
                          ,input no-lock
                          ,input (buffer X_dis-time-rule:handle)
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
      parameter-3-51 =  "FOR EACH X_dis-time-rule no-lock"
      parameter-4-51 =
        (
          if (" X_dis-time-rule.sts = p-sts " + " " + where-phrase-51) <> ""
          then  substitute('X_dis-time-rule.sts = &1', p-sts)  + " " + where-phrase-51
          else "true"
        )
      parameter-5-51 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root" + " " + p-find-condition)
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
                          ,input QUERY br-dis-time-rule:handle
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
    end.
    when ("rule-num":U + chr(44) + 'ИЗМЕНЕНИЕ':U) then do:
       filter-point = filter-point0 + p-mode.
        ASSIGN
        frame Dialog-Frame:TITLE =  substitute(" Расписания для правила скидки №&1 &2"
                                                , X_dis-rule.rule-num
                                                , X_dis-rule.des
                                                )
       filter-label = substitute("&1 в правиле скидки", filter-label0)
                                                .
     IF p-sts = -1  THEN DO:
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
                              "FOR EACH X_dis-time-rule no-lock"
      parameter-4-53 =
        (
          if (" X_dis-time-rule.lvl-num = 1" + " " + where-phrase-53) <> ""
          then " X_dis-time-rule.lvl-num = 1" + " " + where-phrase-53
          else "true"
        )
      parameter-5-53 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root")
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
          (" X_dis-time-rule.lvl-num = 1" + " " + where-phrase-53 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
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
    OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule no-lock
      where  X_dis-time-rule.lvl-num = 1
    , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-time-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-time-rule:handle:get-buffer-handle(1) = (buffer X_dis-time-rule:handle) then do:
      assign
      parameter-2-53 = (if p-find-next then "true":u else "false":u )
      parameter-4-53 =
        "where ":u + " X_dis-time-rule.lvl-num = 1" + " ":u + where-phrase-53 + " ":u + p-find-condition + " " + ""
      parameter-5-53 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
                          ,input rowid(X_dis-time-rule)
                          ,input logical(parameter-2-53)
                          ,input no-lock
                          ,input (buffer X_dis-time-rule:handle)
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
      parameter-3-53 =  "FOR EACH X_dis-time-rule no-lock"
      parameter-4-53 =
        (
          if (" X_dis-time-rule.lvl-num = 1" + " " + where-phrase-53) <> ""
          then " X_dis-time-rule.lvl-num = 1" + " " + where-phrase-53
          else "true"
        )
      parameter-5-53 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root" + " " + p-find-condition)
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
                          ,input QUERY br-dis-time-rule:handle
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
          ASSIGN
          frame Dialog-Frame:TITLE = title0 + chr(32) + entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U).
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
                              "FOR EACH X_dis-time-rule no-lock"
      parameter-4-55 =
        (
          if (" X_dis-time-rule.sts = p-sts " + " " + where-phrase-55) <> ""
          then  substitute('X_dis-time-rule.sts = &1', p-sts)  + " " + where-phrase-55
          else "true"
        )
      parameter-5-55 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root")
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
          (" X_dis-time-rule.sts = p-sts " + " " + where-phrase-55 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
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
    OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule no-lock
      where  X_dis-time-rule.sts = p-sts
    , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-time-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-time-rule:handle:get-buffer-handle(1) = (buffer X_dis-time-rule:handle) then do:
      assign
      parameter-2-55 = (if p-find-next then "true":u else "false":u )
      parameter-4-55 =
        "where ":u +  substitute('X_dis-time-rule.sts = &1', p-sts)  + " ":u + where-phrase-55 + " ":u + p-find-condition + " " + ""
      parameter-5-55 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
                          ,input rowid(X_dis-time-rule)
                          ,input logical(parameter-2-55)
                          ,input no-lock
                          ,input (buffer X_dis-time-rule:handle)
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
      parameter-3-55 =  "FOR EACH X_dis-time-rule no-lock"
      parameter-4-55 =
        (
          if (" X_dis-time-rule.sts = p-sts " + " " + where-phrase-55) <> ""
          then  substitute('X_dis-time-rule.sts = &1', p-sts)  + " " + where-phrase-55
          else "true"
        )
      parameter-5-55 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.time-rule-num = X_dis-time-rule.templ-rl-root" + " " + p-find-condition)
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
                          ,input QUERY br-dis-time-rule:handle
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
   end.
    when "rule-num":U then do:
       filter-point = filter-point0 + p-mode.
        ASSIGN
        frame Dialog-Frame:TITLE =  substitute(" Расписания в детализации правил скидки №&1 &2"
                                                , X_dis-rule.rule-num
                                                , X_dis-rule.des
                                                )
       filter-label = substitute("&1 в детализации правила скидки", filter-label0)
                                                .
       IF p-sts = -1  THEN DO:
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
                              "FOR EACH X_dis-time-rule no-lock"
      parameter-4-57 =
        (
          if (" TRUE " + " " + where-phrase-57) <> ""
          then " TRUE " + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.templ-rl-root = X_dis-time-rule.templ-rl-root  AND X_dis-time-rule.time-rule-num = tt-template_dis-time-rule.time-rule-num")
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
          (" TRUE " + " " + where-phrase-57 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
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
    OPEN QUERY br-dis-time-rule FOR EACH X_dis-time-rule no-lock
      where  TRUE
    , first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.templ-rl-root = X_dis-time-rule.templ-rl-root  AND X_dis-time-rule.time-rule-num = tt-template_dis-time-rule.time-rule-num
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-time-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-dis-time-rule:handle:get-buffer-handle(1) = (buffer X_dis-time-rule:handle) then do:
      assign
      parameter-2-57 = (if p-find-next then "true":u else "false":u )
      parameter-4-57 =
        "where ":u + " TRUE " + " ":u + where-phrase-57 + " ":u + p-find-condition + " " + ""
      parameter-5-57 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-dis-time-rule:handle
                          ,input rowid(X_dis-time-rule)
                          ,input logical(parameter-2-57)
                          ,input no-lock
                          ,input (buffer X_dis-time-rule:handle)
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
      parameter-3-57 =  "FOR EACH X_dis-time-rule no-lock"
      parameter-4-57 =
        (
          if (" TRUE " + " " + where-phrase-57) <> ""
          then " TRUE " + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + ", first tt-template_dis-time-rule no-lock where tt-template_dis-time-rule.templ-rl-root = X_dis-time-rule.templ-rl-root  AND X_dis-time-rule.time-rule-num = tt-template_dis-time-rule.time-rule-num" + " " + p-find-condition)
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
                          ,input QUERY br-dis-time-rule:handle
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
   end.
END CASE.
if not p-open-query then
REPOSITION br-dis-time-rule to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-time-rule:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if error-status:error then do:
  REPOSITION br-dis-time-rule to row 1 No-ERROR.
end.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-dis-time-rule in frame Dialog-Frame.
APPLY "ENTRY" TO br-dis-time-rule.
END PROCEDURE.
PROCEDURE proc-b-del :
define variable loc#log as logical no-undo.
define variable v-sts like ub.dis-time-rule.sts no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
define buffer loc_dis-time-rule for ub.dis-time-rule.
if not available X_dis-time-rule then return error.
do
on error undo, return error
on stop undo, return error
:
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_discount_work':U
    ,input  'global':U
    ,input  0
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
loc#log = no.
message
"Вы действительно хотите удалить данное РАСПИСАНИЕ?"
view-as alert-box QUESTION buttons YEs-NO update loc#log.
if not loc#log then undo, return error .
    find first loc_dis-time-rule exclusive-lock where
              recid(loc_dis-time-rule) = loc-doc-rec .
    run ref/dis-tim3.p (
                      buffer loc_dis-time-rule
                    , input no
                    , input no
                    ) no-error.
    if error-status:error then do:
      message
      "Ошибка при удалении РАСПИСАНИЯ" skip
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .
      undo, return error .
    end.
  RUN OpenBr in this-procedure ( input YES, input NO, input NO).
  REPOSITION br-dis-time-rule to recid loc-doc-rec No-error.
  if error-status:error then do:                           find first pos_dis-time-rule no-lock where                                   recid(pos_dis-time-rule) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи РАСПИСАНИЕ" skip                            string(if avail pos_dis-time-rule                                     then  substitute("номер расписания: &1"                                                     , pos_dis-time-rule.time-rule-num)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
  if available X_dis-time-rule then do:
    loc#log = br-dis-time-rule:select-focused-row( ) IN FRAME Dialog-Frame.
  end.
  apply "ENTRY" to br-dis-time-rule.
end.
END PROCEDURE.
PROCEDURE proc-b-print :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
DEFINE VARIABLE v-sts-chr AS CHARACTER NO-UNDO.
define variable v-value-type as character no-undo .
define variable v-mark as character no-undo .
DEFINE FRAME dis-time-rule-list
X_dis-time-rule.des FORMAT "X(65)"
v-sts-chr FORMAT "X(8)" COLUMN-LABEL "Статус"
v-display-time-from COLUMN-LABEL "Время!нач." FORMAT "X(5)":U
v-display-time-to COLUMN-LABEL "Время!конца" FORMAT "X(5)":U
v-display-date-from COLUMN-LABEL "Дата нач." FORMAT "X(10)":U
v-display-date-to COLUMN-LABEL "Дата!конца" FORMAT "X(10)":U
v-display-week-day-0 COLUMN-LABEL "ДН" FORMAT "X(1)":U
v-display-week-day-1 COLUMN-LABEL "Пн" FORMAT "X(3)":U
v-display-week-day-2 COLUMN-LABEL "Вт" FORMAT "X(3)":U
v-display-week-day-3 COLUMN-LABEL "Ср" FORMAT "X(3)":U
v-display-week-day-4 COLUMN-LABEL "Чт" FORMAT "X(3)":U
v-display-week-day-5 COLUMN-LABEL "Птн" FORMAT "X(3)":U
v-display-week-day-6 COLUMN-LABEL "Сб" FORMAT "X(3)":U
v-display-week-day-7 COLUMN-LABEL "Вс" FORMAT "X(3)":U
v-display-month-day COLUMN-LABEL "ДМ" FORMAT "X(2)":U
v-value-type        COLUMN-LABEL "Тип расп-ния" FORMAT "X(20)":U
X_dis-time-rule.time-rule-num COLUMN-LABEL "Номер!расп-ния"
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
FORM with FRAME dis-time-rule-list  .
run waitfram-show in this-procedure (  input "Ждите...").
v-doc-rec = recid(X_dis-time-rule).
DO WHILE available X_dis-time-rule :
  GET prev br-dis-time-rule.
END.
GET next br-dis-time-rule.
DO WHILE available X_dis-time-rule :
  assign
  v-sts-chr = entry (lookup (string(X_dis-time-rule.sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U)
  v-value-type = time-v-name(buffer X_dis-time-rule)
  v-mark = mark-string(buffer X_dis-time-rule, v-rid-list)
  .
  Display STREAM PrnLibStream
  X_dis-time-rule.des
  entry (lookup (string(X_dis-time-rule.sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U) @ v-sts-chr
  v-display-time-from
  v-display-time-to
  v-display-date-from
  v-display-date-to
  v-display-week-day-0
  v-display-week-day-1
  v-display-week-day-2
  v-display-week-day-3
  v-display-week-day-4
  v-display-week-day-5
  v-display-week-day-6
  v-display-week-day-7
  v-display-month-day
  v-value-type
  X_dis-time-rule.time-rule-num
  with FRAME dis-time-rule-list .
  DOWN STREAM PrnLibStream 1
  with FRAME dis-time-rule-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-dis-time-rule.
END.
UNDERLINE  STREAM PrnLibStream
X_dis-time-rule.des
v-sts-chr
v-display-time-from
v-display-time-to
v-display-date-from
v-display-date-to
v-display-week-day-0
v-display-week-day-1
v-display-week-day-2
v-display-week-day-3
v-display-week-day-4
v-display-week-day-5
v-display-week-day-6
v-display-week-day-7
v-display-month-day
v-value-type
X_dis-time-rule.time-rule-num
with FRAME dis-time-rule-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_dis-time-rule.des
accum-count @ v-sts-chr
with frame dis-time-rule-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME dis-time-rule-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-dis-time-rule to recid v-doc-rec no-error.
APPLY "entry" to br-dis-time-rule.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'dis-time-rule'
  join-tbl = 'X_dis-time-rule'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('des', 'Описание расписания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
if p-mode <> "template" and p-upper-time-rule-num <> 0 and p-mode <> "upper-time-rule-num" then do:
  run fltfield-add in this-procedure('templ-rl-root', 'Номер типа(шаблона) расписания', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
end.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                    ,INPUT (filter-point + chr(4) + filter-label)
                    ,INPUT tbl
                    ,INPUT join-tbl
                    ,INPUT fld
                    ,INPUT lab
                    ,INPUT spr
                    ,INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
PROCEDURE proc-b-stat :
define input parameter p-doc-rec as recid no-undo .
define variable v-sts like ub.dis-time-rule.sts no-undo .
define buffer loc_dis-time-rule for ub.dis-rule.
do
on error undo, return error
:
  find first loc_dis-time-rule exclusive-lock where
            recid(loc_Dis-time-rule) = p-doc-rec .
  v-sts = ?.
  run ref/dis-tim2.p (
                    buffer loc_dis-time-rule
                  , input no
                  , input-output v-sts
                  ) no-error.
end.
END PROCEDURE.
PROCEDURE proc-br-dis-time-rule :
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-dis-time-rule FOR ub.dis-time-rule, input mark-list as CHARACTER ) :
  RUN get-tree IN THIS-PROCEDURE(
         BUFFER loc-dis-time-rule
        ,output v-display-time-from
        ,OUTPUT v-display-time-to
        ,output v-display-date-from
        ,OUTPUT v-display-date-to
        ,OUTPUT v-display-week-day-0
        ,OUTPUT v-display-week-day-1
        ,OUTPUT v-display-week-day-2
        ,OUTPUT v-display-week-day-3
        ,OUTPUT v-display-week-day-4
        ,OUTPUT v-display-week-day-5
        ,OUTPUT v-display-week-day-6
        ,OUTPUT v-display-week-day-7
        ,OUTPUT v-display-month-day
        ,output v-using-fields
    ).
RETURN ( IF LOOKUP( STRING( RECID( loc-dis-time-rule ) ), mark-list ) > 0 THEN "*" ELSE "":U ).
END FUNCTION.
FUNCTION time-v-name RETURNS CHARACTER
  ( BUFFER loc_dis-time-rule FOR ub.dis-time-rule ) :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-str AS CHARACTER NO-UNDO.
DO ii = 1 TO NUM-ENTRIES(loc_dis-time-rule.value-type):
   ASSIGN
   v-str = v-str + (IF v-str = "":U THEN "":U ELSE chr(44)) +
                   entry (lookup (ENTRY(ii, loc_dis-time-rule.value-type), '0,1,2,4,8,16':U), '?,Период времени,Период дат,День недели,Дата,День месяца':U) NO-ERROR.
END.
RETURN v-str.
END FUNCTION.
