block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-pexcis.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-pexcis.p $":U .
def var vss-description as character no-undo init "Топливо: расчет акциза".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE LastDate:
    def input parameter in-date as date no-undo.
    def output parameter LastDate as date no-undo.
    LastDate = ((DATE(MONTH(in-date),28,YEAR(in-date)) + 4) - DAY(DATE(MONTH(in-date),28,YEAR(in-date)) + 4)).
END PROCEDURE.
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
define variable v-month         as integer  no-undo format "99" .
define variable v-year          as integer  no-undo format "9999" .
define variable l-ok            as logical  no-undo .
define variable v-first-date    as date     no-undo .
define variable v-last-date     as date     no-undo .
define variable v-today         as date     no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table temp-parts no-undo
    field artic                   like ub.parts.artic
    field prod-type               like ub.parts.prod-type
    field prod-code               like ub.parts.prod-code
    field in-code                 like ub.parts.in-code
    field part-code               like ub.parts.part-code
    field income-qnty             like ub.parts.fact-qnty
    field fact-date               like ub.parts.fact-date
    field this-month-sell-qnty    like ub.parts.fact-qnty
    field this-month-kg-sell-qnty like ub.parts.fact-qnty
    field this-month-excise       as decimal
    field before-sell-qnty        like ub.parts.fact-qnty
    field free-qnty               like ub.parts.fact-qnty
    field cli-base-rate           like ub.parts.cli-base-rate
    field density                 like ub.doc-line.doc-density
    index xpk in-code part-code
  .
do while true :
  for each temp-parts:
      delete temp-parts.
  end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-today
  )  .
  assign
    v-year  = year( v-today )
    v-month = month( v-today )
  .
  run rep/d-pinp.w
    (input  parparentproc
    ,input  "Расчет акциза"
    ,input-output v-month
    ,input-output v-year
    ,output l-ok
    ).
  if l-ok <> true then do:
    return .
  end.
  def var v-month-name as character no-undo format "x(12)".
  run gbl/monthnam.p
    (input  v-month
    ,output v-month-name
    ).
  assign
    v-first-date = date(v-month, 1, v-year)
  .
  run lastdate in this-procedure
    (input  v-first-date
    ,output v-last-date
    ).
  run fill-temp-parts in this-procedure .
  def var v-ind         as integer   no-undo .
  def var v-line        as character no-undo format "X(136)" .
  assign
    v-line = fill("-", 136 )
  .
  def var v-line1        as character no-undo format "X(136)" .
  def var v-line2        as character no-undo format "X(136)" .
  def var v-line3        as character no-undo format "X(136)" .
  assign
    v-line1 = v-line
    v-line2 = v-line
    v-line3 = v-line
  .
  def var sym1          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym2          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym3          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym4          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym5          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym6          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym7          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym8          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym9          as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym10         as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym11         as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym12         as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym13         as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym14         as character no-undo format "x(1)":u label '!':u init ":":u .
  def var sym15         as character no-undo format "x(1)":u label '!':u init ":":u .
  run waitfram-show in this-procedure
    (input 'Подождите ...'
    ) .
  run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
  find first clients no-lock
    where clients.obj-type = p-curr-obj-type
      and clients.obj-code = p-curr-obj-code
    .
  def var v-header-name as character no-undo .
  def var v-print-time  as character no-undo .
  assign
    v-header-name = "РАСЧЕТ АКЦИЗА - основан на алгоритме FIFO"
    v-print-time  = cur-time-string()
  .
  form header
    v-line1 at 1 skip
    v-header-name + ": " + v-month-name + " " + string(v-year) format "x(50)" at 1
      "Дата печати :" at 60
      v-print-time format "x(20)"
      "Стр." at 111 string( page-number(PrnLibStream), ">>>9" )  skip
    "ОБЪЕКТ:" at 1 clients.obj-type + " " + string(clients.obj-code) format "x(15)"
    clients.obj-name skip
    v-line2 at 1 skip
    with frame topframe
    width 160 page-top no-labels no-box .
  view stream PrnLibStream frame topframe .
  form header
    v-line at 1 skip
    "Продолжение на следующей странице" at 30 skip
    with frame bottomframe
    width 160 page-bottom no-labels no-box .
  view stream PrnLibStream frame bottomframe .
  def var v-decrement-sell-qnty like ub.parts.fact-qnty no-undo .
  define frame excise-frm
    goods.gds-name                     format "x(40)" column-label "ПРИХОД"
    temp-parts.fact-date               column-label "ДАТА ПРИХОДА"
    temp-parts.this-month-kg-sell-qnty column-label "КОЛ-ВО (КГ)"
    temp-parts.density                 column-label "ПЛ-ТЬ"
    temp-parts.this-month-sell-qnty    column-label "КОЛ-ВО"
    units.long-name                    format "x(20)" column-label "ЕД.ИЗМ."
    v-decrement-sell-qnty              column-label ""
    with width 160 down stream-io use-text .
  form with frame excise-frm .
  for each gds-list no-lock
  ,first goods no-lock
    where goods.artic     = gds-list.artic
      and goods.prod-type = gds-list.prod-type
      and goods.prod-code = gds-list.prod-code
  :
    find first units no-lock
      where units.unit-name = goods.unit-base
      .
    assign
      v-ind = v-ind + 1
    .
    process events .
    run waitfram-show in this-procedure
      (input "Печать отчета. Обработано линий: " + string(v-ind)
      ) .
    def var v-total-month-sell-qnty    like ub.parts.fact-qnty .
    def var v-total-month-kg-sell-qnty as decimal no-undo .
    def var v-total-month-excise-qnty  as decimal no-undo .
    assign
      v-total-month-sell-qnty    = 0
      v-total-month-excise-qnty  = 0
      v-total-month-kg-sell-qnty = 0
    .
    for each temp-parts no-lock
      where temp-parts.artic                = goods.artic
        and temp-parts.prod-type            = goods.prod-type
        and temp-parts.prod-code            = goods.prod-code
    :
      assign
        v-total-month-sell-qnty    = v-total-month-sell-qnty
                                   + temp-parts.this-month-sell-qnty
        v-total-month-excise-qnty  = v-total-month-excise-qnty
                                   + temp-parts.this-month-excise
        v-total-month-kg-sell-qnty = v-total-month-kg-sell-qnty
                                   + temp-parts.this-month-kg-sell-qnty
      .
      assign
        temp-parts.free-qnty       = temp-parts.income-qnty
                                   - ( temp-parts.before-sell-qnty
                                     + temp-parts.this-month-sell-qnty
                                     )
      .
    end.
    run on-same-page in this-procedure (input 3) .
    put stream PrnLibStream
      goods.gds-name at 1 skip
      .
    put stream PrnLibStream
      "КОЛИЧЕСТВО "
      fill("-", 89) + ">" format "x(90)"
      v-total-month-sell-qnty  skip
      .
    assign
      v-decrement-sell-qnty = v-total-month-sell-qnty
    .
    for each temp-parts no-lock
      where temp-parts.artic                = goods.artic
        and temp-parts.prod-type            = goods.prod-type
        and temp-parts.prod-code            = goods.prod-code
        and temp-parts.this-month-sell-qnty > 0
    :
      assign
        v-decrement-sell-qnty = v-decrement-sell-qnty
                              - temp-parts.this-month-sell-qnty
      .
      display stream PrnLibStream
        "ПРИХОД " + temp-parts.in-code +
          (if temp-parts.free-qnty > 0 then ".1" else "") @ goods.gds-name
        temp-parts.fact-date
        temp-parts.this-month-kg-sell-qnty
        temp-parts.density
        temp-parts.this-month-sell-qnty
        units.long-name
        v-decrement-sell-qnty
        with frame excise-frm .
      down stream PrnLibStream 1 with frame excise-frm .
    end.
    if v-total-month-kg-sell-qnty <> 0
    or v-total-month-sell-qnty    <> 0 then do:
      run on-same-page in this-procedure (input 3) .
      put stream PrnLibStream
        v-line  skip
        .
      display stream PrnLibStream
        "ПРОДАЖИ ЗА МЕСЯЦ"           @ goods.gds-name
        v-total-month-kg-sell-qnty @ temp-parts.this-month-kg-sell-qnty
        v-total-month-sell-qnty    @ temp-parts.this-month-sell-qnty
        units.long-name
        with frame excise-frm .
      down stream PrnLibStream 1 with frame excise-frm .
      put stream PrnLibStream
        v-line  skip
        .
    end.
    for each temp-parts no-lock
      where temp-parts.artic     = goods.artic
        and temp-parts.prod-type = goods.prod-type
        and temp-parts.prod-code = goods.prod-code
        and temp-parts.free-qnty > 0
    :
      display stream PrnLibStream
        "ПРИХОД " + temp-parts.in-code +
          (if temp-parts.free-qnty > 0 then ".2" else "") @ goods.gds-name
        temp-parts.fact-date
        (temp-parts.free-qnty / temp-parts.cli-base-rate ) @ temp-parts.this-month-kg-sell-qnty
        temp-parts.density
        temp-parts.free-qnty @ temp-parts.this-month-sell-qnty
        units.long-name
        with frame excise-frm .
      down stream PrnLibStream 1 with frame excise-frm .
    end.
    if v-total-month-kg-sell-qnty <> 0
    or v-total-month-sell-qnty    <> 0 then do:
      run on-same-page in this-procedure (input 6) .
      put stream PrnLibStream
        v-line skip
        goods.gds-name at 1 skip
        .
      put stream PrnLibStream
        "Итог"      at 1
          units.long-name format "x(20)" at 40
          "Кг"            at 70
          "Тонны"         at 90
        skip
        "продано за месяц"       at 1
          v-total-month-sell-qnty             at 40
          v-total-month-kg-sell-qnty          at 70
          (v-total-month-kg-sell-qnty / 1000) format "->>>,>>>,>>9.999999" at 90
        skip
        "акциз за месяц на тонну" at 1
          ( v-total-month-excise-qnty * 1000
          / v-total-month-kg-sell-qnty ) format "->>>,>>>,>>9.999999" at 90
        skip
        "акциз к оплате" at 1
          v-total-month-excise-qnty format "->>>,>>>,>>9.99" at 90
        skip
        .
    end.
    put stream PrnLibStream
      SKIP(2)
      .
  end.
  hide frame input-frm .
  run on-same-page in this-procedure (input 2) .
  put stream PrnLibStream
    v-line  skip
    space(10) "Всего страниц в отчете" page-number(PrnLibStream) skip
    .
  hide stream PrnLibStream frame bottomframe .
  output stream PrnLibStream close.
  run waitfram-hide in this-procedure .
  run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
end.
procedure on-same-page :
  define input parameter p-line-number as integer no-undo .
  if p-line-number > page-size( PrnLibStream ) then do:
    return .
  end.
  if line-counter( PrnLibStream ) + p-line-number > page-size( PrnLibStream ) then do:
    page stream PrnLibStream .
  end.
end procedure.
procedure next-page :
  page stream PrnLibStream .
end procedure.
procedure fill-temp-parts :
  run waitfram-show in this-procedure
    (input "Сбор данных..."
    ) .
  def var v-lookup-ind as integer no-undo .
  for each gds-list no-lock
  ,first goods no-lock
    where goods.artic     = gds-list.artic
      and goods.prod-type = gds-list.prod-type
      and goods.prod-code = gds-list.prod-code
  :
    find first units no-lock
      where units.unit-name = goods.unit-base
      .
    assign
      v-lookup-ind = v-lookup-ind + 1
    .
    run waitfram-show in this-procedure
      (input "Сбор данных. Обработано строк: " + string(v-lookup-ind)
      ) .
    for each doc-line no-lock
      where doc-line.obj-type  = p-curr-obj-type
        and doc-line.obj-code  = p-curr-obj-code
        and doc-line.artic     = goods.artic
        and doc-line.prod-type = goods.prod-type
        and doc-line.prod-code = goods.prod-code
        and doc-line.status_   = 'факт':U
    , first trn-doc no-lock
      where trn-doc.doc-code = doc-line.doc-code
        and trn-doc.doc-type = 'рас':U
        and trn-doc.internal = false
        and trn-doc.fact-date >= v-first-date
        and trn-doc.fact-date <= v-last-date
    :
      for each parts no-lock
        where parts.out-code  = doc-line.doc-code
          and parts.obj-type  = doc-line.obj-type
          and parts.obj-code  = doc-line.obj-code
          and parts.artic     = doc-line.artic
          and parts.prod-type = doc-line.prod-type
          and parts.prod-code = doc-line.prod-code
      :
        run create-temp-parts
          (buffer temp-parts
          ,buffer parts
          ).
        assign
          temp-parts.this-month-sell-qnty    = temp-parts.this-month-sell-qnty
                                             + parts.fact-qnty
          temp-parts.this-month-kg-sell-qnty = temp-parts.this-month-sell-qnty
                                             / temp-parts.cli-base-rate
          temp-parts.density                 = 1 / temp-parts.cli-base-rate
          temp-parts.this-month-excise       = temp-parts.this-month-excise
                                             + parts.fact-qnty * doc-line.excise
        .
      end.
    end.
  end.
  run waitfram-hide in this-procedure .
end procedure.
procedure create-temp-parts :
  define parameter buffer buf_temp-parts for temp-parts .
  define parameter buffer buf_parts      for parts .
  find first buf_temp-parts no-lock
    where buf_temp-parts.artic     = buf_parts.artic
      and buf_temp-parts.prod-type = buf_parts.prod-type
      and buf_temp-parts.prod-code = buf_parts.prod-code
      and buf_temp-parts.in-code   = buf_parts.in-code
      and buf_temp-parts.part-code = buf_parts.part-code
    no-error .
  if not available buf_temp-parts then do:
    create buf_temp-parts .
    assign
      buf_temp-parts.artic     = buf_parts.artic
      buf_temp-parts.prod-type = buf_parts.prod-type
      buf_temp-parts.prod-code = buf_parts.prod-code
      buf_temp-parts.in-code   = buf_parts.in-code
      buf_temp-parts.part-code = buf_parts.part-code
    .
    assign
      buf_temp-parts.cli-base-rate = buf_parts.cli-base-rate
    .
    define buffer buf_income-trn-doc for ub.trn-doc .
    find first buf_income-trn-doc no-lock
      where buf_income-trn-doc.doc-code = buf_parts.in-code
      no-error .
    if  available buf_income-trn-doc
    and buf_income-trn-doc.doc-type = 'при':U
    and buf_income-trn-doc.internal = false
    then do:
      define buffer buf_income-parts for ub.parts .
      find first buf_income-parts no-lock
        where buf_income-parts.obj-type  = buf_income-trn-doc.obj-type
          and buf_income-parts.obj-code  = buf_income-trn-doc.obj-code
          and buf_income-parts.artic     = buf_parts.artic
          and buf_income-parts.prod-type = buf_parts.prod-type
          and buf_income-parts.prod-code = buf_parts.prod-code
          and buf_income-parts.in-code   = buf_income-trn-doc.doc-code
          and buf_income-parts.out-code  = buf_income-trn-doc.doc-code
          and buf_income-parts.part-code = buf_parts.part-code
        no-error .
      if available buf_income-parts then do:
        assign
          buf_temp-parts.income-qnty = buf_income-parts.fact-qnty
          buf_temp-parts.fact-date   = buf_income-parts.fact-date
        .
      end.
    end.
    define buffer buf_sell-trn-doc for ub.trn-doc .
    define buffer buf_sell-parts   for ub.parts .
    for each buf_sell-parts no-lock
      where buf_sell-parts.artic      = buf_parts.artic
        and buf_sell-parts.prod-type  = buf_parts.prod-type
        and buf_sell-parts.prod-code  = buf_parts.prod-code
        and buf_sell-parts.in-code    = buf_parts.in-code
        and buf_sell-parts.part-code  = buf_parts.part-code
        and buf_sell-parts.status_    = yes
        and buf_sell-parts.rsrv-free  = ?
        and buf_sell-parts.fact-date  < v-first-date
    ,first buf_sell-trn-doc no-lock
      where buf_sell-trn-doc.doc-code = buf_sell-parts.out-code
        and buf_sell-trn-doc.status_  = 'факт':U
        and trn-doc.doc-type          = 'рас':U
        and trn-doc.internal          = false
    :
      assign
        buf_temp-parts.before-sell-qnty = buf_temp-parts.before-sell-qnty
                                        + buf_sell-parts.fact-qnty
      .
    end.
  end.
end procedure.
