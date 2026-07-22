block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getdcmsk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/getdcmsk.p $":U .
define variable vss-description as character no-undo init "Вывод непересекающихся диапазонов ДК".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define temp-table tt-dis-card no-undo
like ub.dis-card
field d-card-u like ub.dis-card.d-card
index pi is unique primary
d-card.
define temp-table temp-dc-mask no-undo
field d-card-start like ub.dis-card.d-card
field d-card-end   like ub.dis-card.d-card
field bis-d-card-start like ub.dis-card.d-card
field bis-d-card-end   like ub.dis-card.d-card
field type         like ub.dis-card-type.type
field num-recs     as integer
field num-recs-calc as decimal
field maska        as character
field maska-save   as character
field length_      as integer
field node-code    as integer
field upper-code   as integer
field high-code    as decimal
field to-decompose as logical
field cut-down     as logical
field cut-up       as logical
index pi is unique primary
node-code
index iupper upper-code
index i1 d-card-start maska
index isave
length_ maska-save
index isort1
length_ bis-d-card-start
index isort2
length_ bis-d-card-end
index ishow
length_
d-card-start
index id
to-decompose
.
define variable v-get-data  as character no-undo .
define variable ii as integer no-undo .
define variable v-not-number as logical no-undo .
define variable v-type like ub.dis-card-type.type no-undo .
define variable v-length as integer no-undo .
define variable v-dopi as decimal no-undo .
define variable v-print as logical no-undo .
define variable v-d-card like ub.dis-card.d-card no-undo .
define variable v-count as integer no-undo .
define variable v-flag as logical no-undo init yes.
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
define variable v-seq as integer no-undo .
define variable v-found as logical no-undo .
define variable v-file-name as character no-undo .
define variable v-file-directory as character no-undo .
define variable v-choose as logical no-undo .
define variable v-dopd as decimal no-undo .
define variable v-choice as integer no-undo .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_clients for ub.clients.
define buffer buf_temp-dc-mask for temp-dc-mask.
define stream InStream.
  run gbl/d-askw.w (  input "Сбор данных по диапазонам ДК"
                ,input "получаем информацию по непересекающимся диапазонам карт"
                ,input "|"
                ,input ("Из БД|" +
                       "Из файла|" +
                       "Отказ")
                ,input "||"
                ,input 1
                ,input 3
                ,output v-choice).
if v-choice = 3 then return.
if v-choice = 1 then v-get-data = 'db'.
if v-choice = 2 then v-get-data = 'file'.
if v-get-data = 'db':U then do:
  for each tt-dis-card:
    delete tt-dis-card.
  end.
  for each buf_dis-card no-lock
  by buf_dis-card.d-card   :
    assign
    ii = ii + 1
    .
    if ii modulo 100 = 0 then do:
      run waitfram-show in this-procedure (string(ii)).
    end.
      create tt-dis-card.
    buffer-copy buf_dis-card
    to tt-dis-card
    assign
    tt-dis-card.d-card-u = fill('#':U , 19 - length(buf_dis-card.d-card)) + buf_dis-card.d-card.
  end.
  ii = 0.
  for each tt-dis-card no-lock
  by tt-dis-card.d-card-u   :
    assign
    ii = ii + 1
    v-print = no
    .
    if ii modulo 100 = 0 then do:
      run waitfram-show in this-procedure (string(ii)).
    end.
    if  length(tt-dis-card.d-card) <> v-length
    or tt-dis-card.type <> v-type then do:
      if v-type <> '':U then do:
        if available temp-dc-mask then
        assign
        temp-dc-mask.d-card-end = v-d-card
        temp-dc-mask.num-recs = v-count
        .
      end.
      v-count = 0.
      find first temp-dc-mask no-lock where
                temp-dc-mask.d-card-start = tt-dis-card.d-card no-error .
      if not available temp-dc-mask then do:
        create temp-dc-mask.
        assign
        temp-dc-mask.upper-code   = 0
        temp-dc-mask.node-code    = v-seq + 1
        v-seq                     = v-seq + 1
        temp-dc-mask.high-code    = temp-dc-mask.node-code
        temp-dc-mask.d-card-start = tt-dis-card.d-card
        temp-dc-mask.type = tt-dis-card.type
        temp-dc-mask.length_ = length(tt-dis-card.d-card)
        .
      end.
    end.
    assign
    v-length = length(tt-dis-card.d-card)
    v-type = tt-dis-card.type
    v-count = v-count + 1
    v-d-card = tt-dis-card.d-card
    .
    process events.
  end.
  find first temp-dc-mask where
            temp-dc-mask.node-code = v-seq - 1 no-error .
  if available temp-dc-mask then
  assign
  temp-dc-mask.d-card-end = v-d-card
  temp-dc-mask.num-recs = v-count
  .
end.
if v-get-data = 'file' then do:
  run gbl/d-file.p (
  input-output v-file-name
  ,input-output v-file-directory
  ,input        "Текстовые файлы,Все файлы"
  ,input        "*.txt,*.*":U
  ,input        ","
  ,input        "txt,all":U
  ,input        yes
  ,input        no
  ,input        yes
  ,input        "Введите имя файла, содержащего данные по диапазонам карт"
  ,output       v-choose
  ).
  if not v-choose then return.
  input stream Instream from value(v-file-name).
  _repeat:
  repeat:
    create temp-dc-mask.
    temp-dc-mask.num-recs = ?.
    import stream Instream temp-dc-mask.type temp-dc-mask.d-card-start temp-dc-mask.d-card-end temp-dc-mask.num-recs no-error .
    if error-status:error then do:
      message
      substitute("Строка &1&2Ошибка при импорте&2&3&2&4"
                , v-seq + 1
                , chr(10)
                , error-status:get-message(1)
                , return-value )
     view-as alert-box error .
     next _repeat.
    end.
    if length(temp-dc-mask.d-card-start) <> length(temp-dc-mask.d-card-end) then do:
      message
      substitute("Строка &1&2Разная длина номера карты для карты начала и конца диапазона"
                , v-seq + 1
                , chr(10))
      view-as alert-box error .
      next _repeat.
    end.
    assign
    v-dopd = decimal(temp-dc-mask.d-card-start) no-error.
    if ( error-status:error ) OR
        index( temp-dc-mask.d-card-start , "." ) > 0 OR
        index( temp-dc-mask.d-card-start , chr(44) ) > 0 OR
        index( temp-dc-mask.d-card-start , "-" ) > 0 OR
        index( temp-dc-mask.d-card-start , "+" ) > 0 then do:
      message
      substitute("Строка&1&2Возможно только цифровое значение номера дисконтной карты"
                 , v-seq + 1
                 , chr(10))
      view-as alert-box error .
    end.
    assign
    v-dopd = decimal(temp-dc-mask.d-card-end) no-error.
    if ( error-status:error ) OR
        index( temp-dc-mask.d-card-start , "." ) > 0 OR
        index( temp-dc-mask.d-card-start , chr(44) ) > 0 OR
        index( temp-dc-mask.d-card-start , "-" ) > 0 OR
        index( temp-dc-mask.d-card-start , "+" ) > 0 then do:
      message
      substitute("Строка&1&2Возможно только цифровое значение номера дисконтной карты"
                 , v-seq + 1
                 , chr(10))
      view-as alert-box error .
    end.
    assign
    temp-dc-mask.upper-code   = 0
    temp-dc-mask.node-code    = v-seq + 1
    v-seq                     = v-seq + 1
    temp-dc-mask.high-code    = temp-dc-mask.node-code
    temp-dc-mask.length_ = length(temp-dc-mask.d-card-start)
    temp-dc-mask.num-recs = (if temp-dc-mask.num-recs = ?
                             then decimal(temp-dc-mask.d-card-end) - decimal(temp-dc-mask.d-card-start) + 1
                             else temp-dc-mask.num-recs)
    .
  end.
  input stream Instream close.
  find first temp-dc-mask where
  temp-dc-mask.type = '':U no-error .
  if available temp-dc-mask then delete temp-dc-mask.
end.
_temp-dc-mask:
for each temp-dc-mask:
 v-flag = yes.
  do ii = 1 to temp-dc-mask.length_:
    assign
    v-dop1 = substring(temp-dc-mask.d-card-start, ii, 1)
    v-dop2 = substring(temp-dc-mask.d-card-end, ii, 1)
    v-flag = v-flag and (v-dop1 = v-dop2 )
    .
    assign
    temp-dc-mask.maska =  temp-dc-mask.maska +
                         (if v-dop1 = v-dop2
                         and v-flag
                         then v-dop1
                         else chr(63))
    temp-dc-mask.maska-save =  temp-dc-mask.maska
    .
  end.
  if temp-dc-mask.num-recs = 1
  or index(temp-dc-mask.maska, chr(63)) = temp-dc-mask.length_  then do:
    temp-dc-mask.maska = "".
  end.
  assign
  temp-dc-mask.bis-d-card-start = replace(temp-dc-mask.maska-save, chr(63), '0':U)
  temp-dc-mask.bis-d-card-end   = replace(temp-dc-mask.maska-save, chr(63), '9':U)
  .
end.
for each temp-dc-mask
by temp-dc-mask.length_
by temp-dc-mask.d-card-start:
  if temp-dc-mask.maska <> '':U then
  run decompose-mask in this-procedure (buffer temp-dc-mask) .
end.
for each temp-dc-mask:
  if temp-dc-mask.maska <> '':U
  and temp-dc-mask.to-decompose = yes
  then
  run decompose-mask in this-procedure (buffer temp-dc-mask) .
end.
for each temp-dc-mask:
  assign
  temp-dc-mask.bis-d-card-start   = (if (temp-dc-mask.d-card-start >= temp-dc-mask.bis-d-card-start
                                    and temp-dc-mask.d-card-start <= temp-dc-mask.bis-d-card-end)
                                    and temp-dc-mask.cut-down
                                    then temp-dc-mask.d-card-start
                                    else temp-dc-mask.bis-d-card-start)
  temp-dc-mask.bis-d-card-end     = (if (temp-dc-mask.d-card-end >= temp-dc-mask.bis-d-card-start
                                    and temp-dc-mask.d-card-end <= temp-dc-mask.bis-d-card-end)
                                    and temp-dc-mask.cut-up
                                    then temp-dc-mask.d-card-end
                                    else temp-dc-mask.bis-d-card-end)
  temp-dc-mask.num-recs-calc      = decimal(temp-dc-mask.bis-d-card-end) - decimal(temp-dc-mask.bis-d-card-start) + 1
  .
end.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
put stream PrnLibStream unformatted
"Имеющиеся номера дисконтных карт" skip(0)
 cur-time-print() AT 5 format "x(35)" skip(0)
"Диапазоны дисконтных карт разложением на поддиапазоны" AT 5 skip(0)
"Рекоменд. маска"
"Тип карты"    at 21
"Начало диап." at 30
"Конец диап."  at 50
"Кол-во карт"  at 70
skip(0)
"Факт/возможн" at 30
"Факт/возможн" at 50
"Факт/возможн" at 70
skip(0)
fill('-', 80) skip(0).
for each temp-dc-mask where temp-dc-mask.upper-code = 0
by temp-dc-mask.length_
by temp-dc-mask.d-card-start
:
  put stream PrnLibStream unformatted
  temp-dc-mask.maska
  temp-dc-mask.type at 21
  temp-dc-mask.d-card-start at 30
  temp-dc-mask.d-card-end   at 50
  temp-dc-mask.num-recs     at 70
  skip.
  put stream PrnLibStream unformatted
  fill('-', 80) skip(0).
  v-found = no.
  for each buf_temp-dc-mask no-lock where
          buf_temp-dc-mask.upper-code = temp-dc-mask.node-code :
    put stream PrnLibStream unformatted
    buf_temp-dc-mask.maska
    buf_temp-dc-mask.bis-d-card-start at 30
    buf_temp-dc-mask.bis-d-card-end   at 50
    buf_temp-dc-mask.num-recs-calc    at 70
    skip.
    v-found = yes.
  end.
  if not v-found then do:
    put stream PrnLibStream unformatted
    temp-dc-mask.maska
    temp-dc-mask.bis-d-card-start at 30
    temp-dc-mask.bis-d-card-end   at 50
    temp-dc-mask.num-recs-calc    at 70
    skip.
  end.
  put stream PrnLibStream unformatted
  skip(2).
end.
put stream PrnLibStream unformatted
skip(0)
"В порядке номеров карт" AT 5 skip(0)
fill('-', 80) skip(1)
.
for each temp-dc-mask
by temp-dc-mask.length_
by temp-dc-mask.bis-d-card-start:
  find first buf_temp-dc-mask no-lock where
            buf_temp-dc-mask.upper-code = temp-dc-mask.node-code no-error .
  if not available buf_temp-dc-mask then do:
    put stream PrnLibStream unformatted
    temp-dc-mask.maska
    temp-dc-mask.type at 21
    temp-dc-mask.bis-d-card-start at 30
    temp-dc-mask.bis-d-card-end   at 50
    temp-dc-mask.num-recs-calc    at 70
    skip.
  end.
end.
output stream PrnLibStream close.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
procedure decompose-mask :
define parameter buffer buf_temp-dc-mask for temp-dc-mask.
define variable v-mask as character no-undo .
define variable v-first-ques as integer no-undo .
define variable v-start as integer no-undo .
define variable v-end as integer no-undo .
define variable v-found as logical no-undo .
define variable v-new-maska as character no-undo .
define buffer buf1_temp-dc-mask for temp-dc-mask .
define buffer buf2_temp-dc-mask for temp-dc-mask .
do
on error undo, return error
:
  _buf2:
  for each buf2_temp-dc-mask where
            buf2_temp-dc-mask.length_ = buf_temp-dc-mask.length_
       and  buf2_temp-dc-mask.maska > '':U
       AND  (
             (buf2_temp-dc-mask.bis-d-card-start >= buf_temp-dc-mask.bis-d-card-start
              AND  buf2_temp-dc-mask.bis-d-card-start   <= buf_temp-dc-mask.bis-d-card-end)
              or
             (buf2_temp-dc-mask.bis-d-card-end >= buf_temp-dc-mask.bis-d-card-start
              AND  buf2_temp-dc-mask.bis-d-card-end   <= buf_temp-dc-mask.bis-d-card-end)
            ):
    if buf2_temp-dc-mask.high-code = buf_temp-dc-mask.high-code then next.
    assign
    v-mask = buf_temp-dc-mask.maska
    v-first-ques = index(v-mask, chr(63))
    .
    buf2_temp-dc-mask.to-decompose = yes.
    if v-first-ques = 0 then do:
      next _buf2.
    end.
    if
    (buf2_temp-dc-mask.bis-d-card-start >= buf_temp-dc-mask.bis-d-card-start
    AND  buf2_temp-dc-mask.bis-d-card-start   <= buf_temp-dc-mask.bis-d-card-end)  then do:
      assign
      buf_temp-dc-mask.cut-down = yes.
    end.
    if (buf2_temp-dc-mask.bis-d-card-end >= buf_temp-dc-mask.bis-d-card-start
    AND  buf2_temp-dc-mask.bis-d-card-end   <= buf_temp-dc-mask.bis-d-card-end) then do:
      assign
      buf_temp-dc-mask.cut-up = yes.
    end.
    assign
    v-start = integer(substring(buf_temp-dc-mask.d-card-start, v-first-ques , 1))
    v-end   = integer(substring(buf_temp-dc-mask.d-card-end, v-first-ques , 1))
    buf_temp-dc-mask.maska = '':U
    .
    do ii = v-start to v-end:
      v-new-maska                          = v-mask.
      substring(v-new-maska, v-first-ques, 1) = string(ii).
      create buf1_temp-dc-mask.
      buffer-copy buf_temp-dc-mask
      except cut-down cut-up
      to buf1_temp-dc-mask
      assign
      buf1_temp-dc-mask.upper-code         = buf_temp-dc-mask.node-code
      buf1_temp-dc-mask.node-code          = v-seq + 1
      v-seq                                = v-seq + 1
      buf1_temp-dc-mask.maska              = v-new-maska
      buf1_temp-dc-mask.bis-d-card-start   = replace(buf1_temp-dc-mask.maska, chr(63), '0':U)
      buf1_temp-dc-mask.bis-d-card-end     = replace(buf1_temp-dc-mask.maska, chr(63), '9':U)
      .
    end.
    for each buf1_temp-dc-mask where
    buf1_temp-dc-mask.upper-code = buf_temp-dc-mask.node-code:
      run decompose-mask in this-procedure (buffer buf1_temp-dc-mask).
    end.
    buf_temp-dc-mask.to-decompose = no.
  end.
end.
end procedure.
