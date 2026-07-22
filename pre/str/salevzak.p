block-level on error undo, throw.
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-mode         as character no-undo .
define output parameter p-frame-width as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salevzak.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salevzak.p $":U .
define variable vss-description as character no-undo init "ОТЧЕТ ПО ЗАРЕЗЕРВИРОВАННЫМ ПАРТИЯМ ПРОДАЖИ ПО ВАРИАНТАМ ЗАКУПКИ".
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
define variable v-curr-r-b as character no-undo .
define variable v-r-b-abbr as character no-undo .
define variable var-sale-sum      as decimal no-undo .
define variable v-z-number like ub.chk-doc.z-number no-undo .
define variable v-pay-desk like ub.chk-doc.pay-desk no-undo .
define variable v-rec-list as character no-undo .
define variable v-density as decimal no-undo.
define buffer buf_inkas for ub.inkas .
define buffer buf_shop for ub.shop.
define buffer buf_clients for ub.clients.
define buffer buf_trn-doc for ub.trn-doc.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table sj-goods no-undo
field gds-code       like ub.goods.gds-code
field artic          like ub.goods.artic
field prod-type      like ub.goods.prod-type
field prod-code      like ub.goods.prod-code
field gds-name       like ub.goods.gds-name
field prod-name      like ub.goods.gds-name
field qnty           as   decimal
field rest-qnty      as   decimal
field sale-sum       like ub.trn-doc.tot-sale
field price-sale     like ub.gds-dtl.price-rubl
field supp-type      like ub.parts.supp-type
field supp-code      like ub.parts.supp-code
field price-flag     as logical init no
field supp-flag      as logical init no
field var-purch      as integer
field is-out         as logical
INDEX p1 IS PRIMARY UNIQUE
is-out
gds-code
var-purch
supp-type
supp-code
INDEX p2
is-out
var-purch
sale-sum descending
.
define NEW SHARED temp-table sj-print no-undo                                   ~
field gds-code       like ub.goods.gds-code
field artic          like ub.goods.artic
field prod-type      like ub.goods.prod-type
field prod-code      like ub.goods.prod-code
field gds-name       like ub.goods.gds-name
field prod-name      like ub.goods.gds-name
field qnty           as   decimal
field sale-sum       like ub.trn-doc.tot-sale
field price-sale     like ub.gds-dtl.price-rubl
field supp-type      like ub.parts.supp-type
field supp-code      like ub.parts.supp-code
field price-flag     as logical init no
field supp-flag      as logical init no
field var-purch      as integer
field is-cash        as logical
field is-out         as logical
INDEX p1 IS PRIMARY UNIQUE
is-out
gds-code
var-purch
is-cash
supp-type
supp-code
INDEX p2
is-out descending
gds-code
var-purch
sale-sum descending
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-chk-gds no-undo
field doc-code like ub.chk-doc.doc-code
FIELD b-code like ub.chk-gds.b-code
FIELD src-code like ub.chk-gds.src-code
field sum as decimal
field sum-change as decimal
field qnty like ub.chk-gds.doc-qnty
field qnty2 like ub.chk-gds.doc-qnty
field price-base as decimal
field rec-type as integer
field gds-type as integer
field line-num as integer
field pump as integer
field nozzle-code as integer
field jj_ as integer
field jjp_ as integer
field jjo_ as integer
index pi iS unique primary
doc-code
rec-type
src-code
index ijj is unique
jj_
index ijjp
jjp_
index ijjo
jjo_
.
define temp-table temp-chk-pay no-undo like ub.chk-pay
field pet-good as integer
field obj-name like ub.cash-pay.obj-name
field is-cash  like ub.cash-pay.is-cash
field register like ub.cash-pay.register
index pi is primary unique line-num
index isort
pet-good  descending
line-num
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-3 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD netto-rubl as decimal
FIELD rest-qnty as decimal
FIELD src-code like ub.chk-gds.src-code
FIELD is-out   as logical
INDEX pi IS UNIQUE PRIMARY
     is-out
     gds-code
     is-pay DESCENDING
     src-code
INDEX vi
IS UNIQUE
      gds-code
      ii
.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-g-treal-3.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
define input parameter p-is-out  as logical no-undo .
DEFINE INPUT PARAMETER p-src-code like ub.chk-gds.src-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
_main:
DO ON ERROR UNDO _main, return error:
    create treal-3.
    assign
    treal-3.gds-code = pgds-code
    treal-3.is-out   = p-is-out
    treal-3.src-code = p-src-code
    treal-3.qnty1  =  pqnty1
    treal-3.netto = pnetto
    treal-3.out-name = pout-name
    treal-3.is-pay = pis-pay
    treal-3.ii = pii
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
main-block:
do
on error undo, return error
:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  if p-mode = "work" then do:
    do transaction
    on error undo main-block, return error
    :
      find first buf_inkas exclusive-lock where
                  buf_inkas.inkas-code = p-inkas-code no-wait no-error .
      IF NOT AVAILABLE buf_inkas
      AND NOT LOCKED buf_inkas THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Неправильный выбор кассового отчета."
        view-as alert-box WARNING .
        UNDO main-block, RETURN ERROR.
      END.
      IF LOCKED buf_inkas THEN DO:
          MESSAGE
          SUBSTITUTE("В настоящее время занята запись ОТЧЕТА ПРОДАЖИ &1"
                    , p-inkas-code
                    )
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
      END.
    end.
  end.
  else do:
    find first buf_inkas no-lock where
                buf_inkas.inkas-code = p-inkas-code no-error .
    if NOT available buf_inkas then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильный выбор кассового отчета."
      view-as alert-box WARNING .
      return error .
    end.
  end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-abbr in g#library
  (input  buf_inkas.host-code
  ,output v-r-b-abbr
  )  .
  find first buf_shop no-lock where
            buf_shop.obj-code = buf_inkas.obj-code no-error .
  if not available buf_shop then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден объекта для кассового отчета." p-inkas-code
    view-as alert-box WARNING .
    return error .
  end.
  find first buf_clients no-lock where
            buf_clients.obj-type = 'маг':U
        AND buf_clients.obj-code = buf_shop.obj-code no-error .
  find first buf_trn-doc no-lock where
            buf_trn-doc.doc-code = buf_inkas.inkas-code.
  IF  can-find (first ub.gds-dtl no-lock where
                        ub.gds-dtl.doc-code = buf_trn-doc.doc-code
                    AND ub.gds-dtl.doc-qnty <> ub.gds-dtl.fact-qnty USE-INDEX pi)
  then do:
    message
    "Не все товары в расходной части продажи зарезервированы" skip
    "Печать отчета невозможна"
    view-as alert-box ERROR.
    return .
  end.
  run cre-sj in this-procedure (
                                 input v-curr-r-b
                               , buf_inkas.inkas-code
                               , input 0
                               , input "":U
                               , input "":U
                               , input 0
                               , input ?
                               , input ?
                                 ).
  run process-inkas in this-procedure (buffer buf_inkas, (if p-mode <> "export" then yes else no), output v-z-number, output v-pay-desk).
  CASE p-mode:
    when  "print" then do:
      run process-two-tables in this-procedure (0, ?)  .
      run proc-print in this-procedure .
    end.
    when "work" then do:
      run process-two-tables in this-procedure (0, ?).
      run str/salevzaw.w (
                       input parparentproc
                      ,buffer buf_inkas
                      ,input this-procedure
                      ,input (if buf_Inkas.status_ <> 'факт':U then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
                      ,input "":U
                      ,input-output v-rec-list
                      ) no-error .
    end.
    when  "export" then do:
      run proc-export in this-procedure(buffer buf_inkas, input v-z-number, input v-pay-desk) .
    end.
  END CASE.
end.
procedure cre-sj :
define input parameter p-curr-r-b as character no-undo .
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-gds-code   like ub.goods.gds-code no-undo.
define input parameter p-artic      like ub.goods.artic no-undo.
define input parameter p-prod-type  like ub.goods.prod-type no-undo.
define input parameter p-prod-code  like ub.goods.prod-code no-undo.
define input parameter p-is-out     as logical              no-undo .
define input parameter p-doc-line-rec as recid no-undo.
define variable v-b-code like ub.bar-code.b-code no-undo .
define variable v-price-sale      like ub.price-list.price-sale no-undo.
define variable v-price-sale-calc like ub.price-list.price-sale no-undo.
define variable v-price-base      like ub.price-list.price-sale no-undo.
define variable v-price-rubl      like ub.price-list.price-sale no-undo.
define variable v-price-flag       as logical no-undo .
define variable sale_sum_r-b     as decimal no-undo .
define variable v-price-netto    as decimal no-undo .
define variable my-accum          as integer no-undo .
define variable v-var-purch       as integer no-undo .
define variable v-is-out          as logical no-undo .
define buffer buf_trn for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_parts for ub.parts.
define buffer buf_goods for ub.goods.
define buffer buf_sj-goods for sj-goods.
define buffer sj-goods0 for sj-goods.
define buffer sj-goods00 for sj-goods.
define buffer sj-goods01v for sj-goods.
define buffer sj-goods02v for sj-goods.
define buffer sj-goods01r for sj-goods.
define buffer sj-goods02r for sj-goods.
define buffer buf_clients for ub.clients.
  do
  on error undo, return error
  :
    find first buf_trn no-lock where
              buf_trn.doc-code = p-inkas-code no-error .
    if not available buf_trn then do:
      undo, return error substitute("Не найдена расходная часть для кассового отчета &1", p-inkas-code).
    end.
    if p-gds-code = 0 then do:
      for each sj-goods:
        delete sj-goods.
      end.
      create sj-goods00.
      assign
      sj-goods00.gds-code = 0
      sj-goods00.var-purch = 0
      sj-goods00.prod-type = "":U
      sj-goods00.prod-code = 0
      sj-goods00.artic     = "":U
      sj-goods00.gds-name = "ИТОГО по всем вариантам закупки"
      sj-goods00.is-out  = ?
      .
      create sj-goods01r.
      assign
      sj-goods01r.gds-code = 0
      sj-goods01r.var-purch = 1
      sj-goods01r.prod-type = "":U
      sj-goods01r.prod-code = 0
      sj-goods01r.artic     = "":U
      sj-goods01r.is-out    = yes
      sj-goods01r.gds-name = "Итого по варианту закупки 1"
      sj-goods01r.prod-name = "по расходам"
      .
      create sj-goods01v.
      assign
      sj-goods01v.gds-code = 0
      sj-goods01v.var-purch = 1
      sj-goods01v.prod-type = "":U
      sj-goods01v.prod-code = 0
      sj-goods01v.artic     = "":U
      sj-goods01v.is-out    = no
      sj-goods01v.gds-name = "Итого по варианту закупки 1"
      sj-goods01v.prod-name = "по возвратам"
      .
      create sj-goods02r.
      assign
      sj-goods02r.gds-code = 0
      sj-goods02r.var-purch = 2
      sj-goods02r.prod-type = "":U
      sj-goods02r.prod-code = 0
      sj-goods02r.artic     = "":U
      sj-goods02r.is-out    = yes
      sj-goods02r.gds-name = "Итого по варианту закупки 2"
      sj-goods02r.prod-name = "по расходам"
      .
      create sj-goods02v.
      assign
      sj-goods02v.gds-code = 0
      sj-goods02v.var-purch = 2
      sj-goods02v.prod-type = "":U
      sj-goods02v.prod-code = 0
      sj-goods02v.artic     = "":U
      sj-goods02v.is-out    = no
      sj-goods02v.gds-name = "Итого по варианту закупки 2"
      sj-goods02v.prod-name = "по возвратам"
      .
    end.
    else do:
      find first sj-goods00 where
              sj-goods00.gds-code = 0
          AND sj-goods00.var-purch = 0
          AND sj-goods00.is-out  = ?
          AND sj-goods00.supp-type = "":U
          AND sj-goods00.supp-code = 0
      .
      find  first sj-goods01r where
              sj-goods01r.gds-code = 0
          AND sj-goods01r.var-purch = 1
          AND sj-goods01r.is-out    = yes
          AND sj-goods01r.supp-type = "":U
          AND sj-goods01r.supp-code = 0
      .
      find first sj-goods01v where
              sj-goods01v.gds-code = 0
          AND sj-goods01v.var-purch = 1
          AND sj-goods01v.supp-type = "":U
          AND sj-goods01v.supp-code = 0
          AND sj-goods01v.is-out    = no
              .
      find first sj-goods02r where
              sj-goods02r.gds-code = 0
         AND  sj-goods02r.var-purch = 2
         AND  sj-goods02r.supp-type = "":U
         AND  sj-goods02r.supp-code = 0
         AND  sj-goods02r.is-out    = yes
      .
      find first sj-goods02v where
              sj-goods02v.gds-code = 0
         AND  sj-goods02v.var-purch = 2
         AND  sj-goods02v.supp-type = "":U
         AND  sj-goods02v.supp-code = 0
         AND  sj-goods02v.is-out    = no
              .
      for each buf_sj-goods where
             buf_sj-goods.gds-code = p-gds-code
         AND buf_sj-goods.is-out   = p-is-out:
       for each sj-goods no-lock where
               sj-goods.gds-code = 0
           and (sj-goods.is-out = ? or sj-goods.is-out = p-is-out )
           and (sj-goods.var-purch = 0 or sj-goods.var-purch = buf_sj-goods.var-purch)
           :
         assign
         sj-goods.qnty = sj-goods.qnty - buf_sj-goods.qnty
         sj-goods.sale-sum = sj-goods.sale-sum - buf_sj-goods.sale-sum
         sj-goods.rest-qnty = sj-goods.rest-qnty
         .
       end.
       delete buf_sj-goods.
      end.
      for each treal-3 where
              treal-3.gds-code = p-gds-code
         AND  treal-3.gds-code = p-gds-code
         AND treal-3.is-out = p-is-out:
         assign
         treal-3.rest-qnty = treal-3.qnty1
         .
      end.
    end.
    run waitfram-show in this-procedure ("Ждите..." ).
    for each buf_doc-line no-lock where
             (p-doc-line-rec = ? and
             (buf_doc-line.doc-code = buf_trn.doc-code
             or
             buf_doc-line.doc-code = buf_trn.out-code))
             or recid(buf_doc-line) = p-doc-line-rec
             :
      assign
      v-is-out = (buf_doc-line.doc-code = buf_trn-doc.doc-code).
      find first buf_goods no-lock where
                buf_goods.artic = buf_doc-line.artic
            AND buf_goods.prod-type = buf_doc-line.prod-type
            and buf_goods.prod-code = buf_doc-line.prod-code no-error .
      if not available buf_goods then do:
      end.
      find first buf_clients no-lock where
                buf_Clients.obj-type = buf_doc-line.prod-type
            AND buf_Clients.obj-code = buf_doc-line.prod-code no-error .
      if not available buf_clients then do:
      end.
      my-accum = my-accum + 1.
      IF my-accum MODULO 50  = 0 then do:
          run waitfram-show in this-procedure ("Обработано " + string(my-accum) + " строк накладных ").
      end.
      assign
      sale_sum_r-b  = 0
      v-price-flag  = ?
      .
      FOR EACH buf_gds-dtl No-LOCK WHERE
              buf_gds-dtl.doc-code = buf_doc-line.doc-code AND
              buf_gds-dtl.artic = buf_doc-line.artic AND
              buf_gds-dtl.prod-type = buf_doc-line.prod-type AND
              buf_gds-dtl.prod-code = buf_doc-line.prod-code:
        assign
        v-price-netto =  (If p-curr-r-b = 'rubl':U
                          then (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
                          else (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
                          )
        v-price-flag  = (if v-price-flag = ? or v-price-flag = yes
                         then (v-price-flag = ?
                              or
                              (v-price-sale = v-price-netto)
                              )
                         else v-price-flag)
        v-price-sale   = (if v-price-flag = yes or v-price-flag = yes
                         then v-price-netto
                         else v-price-sale)
        sale_sum_r-b = sale_sum_r-b + (if v-is-out then 1 else - 1) * v-price-netto * buf_gds-dtl.fact-qnty
        .
      END.
      assign
      v-price-sale-calc  = sale_sum_r-b / buf_doc-line.fact-qnty
      .
      assign
      sj-goods00.sale-sum  = sj-goods00.sale-sum  + sale_sum_r-b
      sj-goods00.qnty      = sj-goods00.qnty + (if v-is-out then 1 else - 1) * buf_Doc-line.fact-qnty
      sj-goods00.rest-qnty = sj-goods00.qnty
      .
      FOR EACH buf_parts NO-LOCK WHERE
              buf_parts.artic = buf_doc-line.artic AND
              buf_parts.prod-type = buf_doc-line.prod-type AND
              buf_parts.prod-code = buf_doc-line.prod-code AND
              buf_parts.out-code = buf_doc-line.doc-code AND
              buf_parts.obj-type = buf_doc-line.obj-type AND
              buf_parts.obj-code = buf_doc-line.obj-code:
        CASE buf_parts.purch-code:
          when integer('4':U) then do:
            assign
            v-var-purch = 2.
            find first sj-goods where
                      sj-goods.gds-code = buf_goods.gds-code
                  AND sj-goods.is-out   = v-is-out
                  AND sj-goods.var-purch = 2
                  and sj-goods.supp-type = buf_parts.supp-type
                  and sj-goods.supp-code = buf_parts.supp-code  no-error.
          end.
          otherwise do:
            assign
            v-var-purch = 1.
            find first sj-goods where
                      sj-goods.gds-code = buf_goods.gds-code
                  AND sj-goods.is-out   =  v-is-out
                  AND sj-goods.var-purch = 1
                  and sj-goods.supp-type = buf_parts.supp-type
                  and sj-goods.supp-code = buf_parts.supp-code  no-error.
          end.
        END CASE.
        if not available sj-goods then do:
          create sj-goods.
          assign
          sj-goods.gds-code = buf_goods.gds-code
          sj-goods.is-out   = v-is-out
          sj-goods.gds-name = buf_goods.gds-name
          sj-goods.prod-name = buf_clients.obj-name
          sj-goods.var-purch = v-var-purch
          sj-goods.prod-type = buf_doc-line.prod-type
          sj-goods.prod-code = buf_doc-line.prod-code
          sj-goods.artic     = buf_doc-line.artic
          sj-goods.price-flag    = not v-price-flag
          sj-goods.price-sale = (if v-price-flag
                                 then v-price-sale
                                 else ?)
          sj-goods.supp-type = (if sj-goods.supp-type = "":U
                                then buf_parts.supp-type
                                else sj-goods.supp-type)
          sj-goods.supp-code = (if sj-goods.supp-code = 0
                                then buf_parts.supp-code
                                else sj-goods.supp-code)
          sj-goods.supp-flag = (if sj-goods.supp-flag = yes
                                then (sj-goods.supp-type = buf_parts.supp-type
                                      and
                                      sj-goods.supp-code = buf_parts.supp-code)
                                else sj-goods.supp-flag)
          .
        end.
        assign
        sj-goods.qnty          = sj-goods.qnty + (if v-is-out then 1 else - 1) * buf_parts.qnty
        sj-goods.rest-qnty     = sj-goods.qnty
        sj-goods.sale-sum      = sale_sum_r-b / buf_doc-line.fact-qnty * abs(sj-goods.qnty)
        .
        if v-is-out then do:
          if v-var-purch = 1 then do:
            assign
            sj-goods01r.sale-sum = sj-goods01r.sale-sum  +
                                   sale_sum_r-b / buf_doc-line.fact-qnty * buf_parts.qnty
            sj-goods01r.qnty     = sj-goods01r.qnty + (if v-is-out then 1 else - 1) * buf_parts.qnty
            .
          end.
          else do:
            assign
            sj-goods02r.sale-sum = sj-goods02r.sale-sum  +
                                   sale_sum_r-b / buf_doc-line.fact-qnty * buf_parts.qnty
            sj-goods02r.qnty     = sj-goods02r.qnty + (if v-is-out then 1 else - 1) * buf_parts.qnty
            .
          end.
        end.
        else do:
          if v-var-purch = 1 then do:
            assign
            sj-goods01v.sale-sum = sj-goods01v.sale-sum  +
                                   sale_sum_r-b / buf_doc-line.fact-qnty * buf_parts.qnty
            sj-goods01v.qnty     = sj-goods01v.qnty + (if v-is-out then 1 else - 1) * buf_parts.qnty
            .
          end.
          else do:
            assign
            sj-goods02v.sale-sum = sj-goods02v.sale-sum  +
                                   sale_sum_r-b / buf_doc-line.fact-qnty * buf_parts.qnty
            sj-goods02v.qnty     = sj-goods02v.qnty + (if v-is-out then 1 else - 1) * buf_parts.qnty
            .
          end.
        end.
      end.
    end.
    release sj-goods00.
    run waitfram-hide in this-procedure .
  end.
end procedure.
procedure process-inkas :
define parameter buffer buf_inkas for ub.inkas.
define input parameter p-without-src-code as logical no-undo .
define output parameter p-z-number   like ub.chk-doc.z-number no-undo .
define output parameter p-pay-desk  like ub.chk-doc.pay-desk no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable p-by-pay-desk as logical no-undo .
define variable v-curr-code like ub.currency.curr-code no-undo init ?.
define variable v-one-curr-code as logical no-undo .
define variable v-flag as logical no-undo .
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer buf_goods   for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define variable v-ret-doc-code like ub.trn-doc.doc-code no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable pychk_kk as integer no-undo .
define variable pychk_jj as integer no-undo .
define variable pychk_jjp as integer no-undo .
define variable pychk_jjo as integer no-undo .
define variable pychk_pay-sum as decimal no-undo .
DEFINE VARIABLE pychk_No-EXCH as logical no-undo.
DEFINE VARIABLE pychk_No-EXCH-rubl as logical no-undo.
DEFINE VARIABLE pychk_dop-sump as decimal No-UNDO.
DEFINE VARIABLE pychk_dop-sumg as decimal No-UNDO.
DEFINE VARIABLE pychk_dop-sumk as decimal No-UNDO.
DEFINE VARIABLE pychk_exch as decimal No-UNDO.
DEFINE VARIABLE pychk_exch-rubl as decimal No-UNDO.
define variable pychk_pay-desk like ub.chk-doc.pay-desk no-undo init 0.
DEFINE VARIABLE pychk_classify as logical no-undo  init no.
DEFINE VARIABLE pychk_selectgood as logical no-undo init no.
define variable pychk_rv as integer no-undo .
DEFINE VARIABLE pychk_density AS DECIMAL NO-UNDO.
DEFINE VARIABLE pychk_SHEET2 as logical no-undo.
DEFINE VARIABLE pychk_SHEET3 as logical no-undo.
DEFINE VARIABLE pychk_SHEET4 as logical no-undo.
DEFINE VARIABLE pychk_SHEET8 as logical no-undo.
define variable pychk_doc-code-r as character no-undo .
define variable pychk_doc-code-v as character no-undo .
define variable pychk_doc-code as character no-undo .
define buffer pychk_ret-doc for ub.trn-doc .
define buffer pychk_ras-doc for ub.trn-doc .
define variable pychk_without-src-code as logical no-undo .
DEFINE BUFFER b-treal-3 for treal-3.
do
on error undo, return error
:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  buf_inkas.host-code
  ,output v-base-code
  )  .
  if v-curr-r-b = 'base':U or
  v-base-code = 0 then pychk_NO-exch = yes.
  else pychk_No-exch = no.
  if v-curr-r-b = 'rubl':U or
  v-base-code = 0 then pychk_NO-exch-rubl = yes.
  else pychk_No-exch-rubl = no.
  assign
  v-curr-code = (if v-curr-code = ? then v-base-code else v-curr-code)
  v-one-curr-code = (if v-base-code = v-curr-code then yes else no)
  .
  pychk_without-src-code = p-without-src-code.
  find first buf_trn-doc no-lock where
            buf_trn-doc.doc-code = buf_inkas.inkas-code .
  find first buf_ret-doc no-lock where
            buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
  if available buf_ret-doc then
  assign
  v-ret-doc-code = buf_ret-doc.doc-code
  .
  assign
  pychk_sheet3 = yes
  .
  for each treal-3:
    delete treal-3.
  end.
  v-flag = ?.
  for each temp-chk-gds:
    delete temp-chk-gds.
  end.
    _chk-doc:
  FOR EACH ub.chk-doc No-LOCK WHERE
          ub.chk-doc.obj-type = buf_inkas.obj-type AND
          ub.chk-doc.obj-code = buf_inkas.obj-code AND
          ub.chk-doc.out-code = buf_inkas.inkas-code,
    EACH ub.chk-pay NO-LOCK WHERE
            ub.chk-pay.doc-code = ub.chk-doc.doc-code
      BREAK
      BY CHK-pay.DOC-CODE
      BY CHK-pay.LINE-NUM:
    if v-flag = ? then do:
      assign
      p-z-number  = chk-doc.z-number
      p-pay-desk = chk-doc.pay-desk
      v-flag = no
      .
    end.
    if lookup(string(chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
    if (chk-doc.z-number <> p-z-number
    or chk-doc.pay-desk <> p-pay-desk)
    and not v-flag
    then do:
      message
      substitute("В Вашей продаже &1 обнаружены чеки по разным Z-отчетам или разным кассам", buf_inkas.inkas-code) skip
      "ЭКСПОРТ БУДЕТ НЕПРАВИЛЬНЫМ" SKIP
      "Продолжать формирование экспорта?"
      view-as alert-box question buttons yes-no update v-flag.
      if not v-flag then  return error .
    end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first-of(CHK-pay.DOC-CODE) THEN Do:
  assign
  pychk_kk = 0
  pychk_jj = 1
  pychk_jjp = 0
  pychk_jjo = 0
  pychk_pay-sum = chk-doc.netto
  pychk_dop-sumg = 0
  .
 if ub.chk-doc.netto < 0 then do:
        if pychk_doc-code-r <> ub.chk-doc.out-code
        then do:
          find first pychk_ras-doc no-lock
            where pychk_ras-doc.doc-code = ub.chk-doc.out-code
            no-error .
          if not available pychk_ras-doc then do:
            message
              substitute("Отсутствует документ расхода по чеку &1"
                        , ub.chk-doc.doc-code
                        )   skip
              "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
              view-as alert-box error .
            return error .
          end.
          pychk_doc-code-r = pychk_ras-doc.doc-code.
          find first pychk_ret-doc no-lock
            where pychk_ret-doc.doc-code = pychk_ras-doc.out-code
            no-error .
          if not available pychk_ret-doc then do:
            message
              substitute("Отсутствует документ возврата по чеку &1"
                        , ub.chk-doc.doc-code
                        )   skip
              "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
              view-as alert-box error .
            return error .
          end.
          pychk_doc-code-v = pychk_ret-doc.doc-code.
        end.
        assign
          pychk_doc-code = pychk_doc-code-v
        .
      end.
      else do:
        assign
          pychk_doc-code = ub.chk-doc.out-code
        .
      end.
  FOR EACH ub.chk-gds No-LOCK WHERE
           ub.chk-gds.doc-code = ub.chk-pay.doc-code
  BY ub.chk-gds.line-num:
  pychk_density = 0.
  if ub.chk-gds.write-off-code <> ?
  and ub.chk-gds.write-off-code > 0 then NEXT.
      if chk-gds.src-code = ?
      or chk-gds.src-code = "":U then do:
        message
        substitute("Обнаружено незаполненное поле ИСХОДНЫЙ КОД в чеке &1, товарная строка &2"
                  , chk-gds.doc-code
                  , chk-gds.line-num)   skip
        "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
        view-as alert-box error .
        return error .
      end.
      find first temp-chk-gds where
                temp-chk-gds.src-code = chk-gds.src-code
           AND  temp-chk-gds.doc-code = chk-gds.doc-code
           and temp-chk-gds.rec-type = 0  no-error.
      IF AVAILABLE TEMP-CHK-GDS THEN DO:
        assign
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.DOC-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + chk-gds.doc-qnty * pychk_density
        temp-chk-gds.sum-change = temp-chk-gds.sum
        .
      end.
      else do:
        find first temp-chk-gds where temp-chk-gds.jj_ = pychk_jj use-index ijj no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          pychk_jj = pychk_jj + 1
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          .
        end.
        else do:
          assign
          pychk_jj = pychk_jj + 1
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          .
        end.
        ASSIGN
        temp-chk-gds.doc-code = chk-gds.doc-code
        temp-chk-gds.src-code = chk-gds.src-code
        temp-chk-gds.b-code = chk-gds.b-code
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.DOC-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + chk-gds.doc-qnty * pychk_density
        temp-chk-gds.sum-change = temp-chk-gds.sum
        temp-chk-gds.rec-type = 0
        temp-chk-gds.gds-type =
                                  (if entry(1, chk-gds.line-type, chr(4)) = 'у':U then 3 else 2)
        pychk_jjo = pychk_jjo + 1
        temp-chk-gds.jjp_  = 0
        temp-chk-gds.jjo_  = pychk_jjo
        .
      end.
  END.
end.
FIND FIRST ub.cash-pay No-LOCK WHERE
          ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
          ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
if available ub.cash-pay then do:
  find first temp-chk-pay where
          temp-chk-pay.line-num = chk-pay.line-num
      AND  temp-chk-pay.doc-code = chk-pay.doc-code  no-error.
  find first temp-chk-pay use-index pi where
          temp-chk-pay.line-num = chk-pay.line-num no-error.
  if not available temp-chk-pay then do:
    create temp-chk-pay.
  end.
  buffer-copy chk-pay to temp-chk-pay
  assign
  temp-chk-pay.pet-good = integer(cash-pay.atr64) * 2 + integer(cash-pay.is-cash)
  temp-chk-pay.obj-name = cash-pay.obj-name
  temp-chk-pay.is-cash  = cash-pay.is-cash
  temp-chk-pay.register = cash-pay.register
  .
end.
if last-of(chk-pay.doc-code) then do:
  for each temp-chk-pay where
          temp-chk-pay.doc-code = chk-pay.doc-code
  by temp-chk-pay.pet-good descending
  by temp-chk-pay.line-num:
    assign
    pychk_dop-sump = (if v-curr-r-b = 'rubl':U then temp-chk-pay.tot-rubl else temp-chk-pay.tot-base)
    pychk_exch = if pychk_No-exch then 1 else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base
    pychk_exch-rubl = if pychk_No-exch-rubl then 1 else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base
    .
    _repeat:
    REPEAT WHILE  abs(pychk_dop-sump) > 0 :
      if pychk_dop-sumg = 0 then do:
        assign
        pychk_kk = pychk_kk + 1
        .
        if pychk_kk >= pychk_jj then LEAVE _repeat.
        if pychk_kk <= pychk_jjp then
        find first temp-chk-gds where
                  temp-chk-gds.doc-code = chk-doc.doc-code
            AND  temp-chk-gds.jjp_ = pychk_kk no-error .
        else
        find first temp-chk-gds where
                  temp-chk-gds.doc-code = chk-doc.doc-code
            AND  temp-chk-gds.jjo_ = pychk_kk - pychk_jjp no-error .
        if not available temp-chk-gds or temp-chk-gds.sum = 0 then do:
          NEXT _repeat.
        end.
        assign
        pychk_dop-sumg = temp-chk-gds.sum
        .
      end.
      assign
      pychk_dop-sumk = min(abs(pychk_dop-sumg), abs(pychk_dop-sump))  * (if pychk_dop-sump > 0 then 1 else -1 )
      pychk_pay-sum = pychk_pay-sum - pychk_dop-sumk
      pychk_dop-sump = pychk_dop-sump - pychk_dop-sumk
      pychk_dop-sumg = pychk_dop-sumg - pychk_dop-sumk
      .
      FIND FIRST ub.bar-code No-LOCK WHERE
                ub.bar-code.b-code =  temp-chk-gds.b-code No-ERROR.
      IF NOT AVAIL ub.bar-code then NEXT _repeat.
        if yes then do:
      CASE temp-chk-gds.gds-type:
        WHEN 2   then do:
                if pychk_sheet3 then do:
            FIND FIRST ub.goods No-LOCK WHERE
                        ub.goods.gds-code = ub.bar-code.gds-code No-ERROR.
            IF NOT AVAIL ub.goods then NEXT _repeat.
            FIND FIRST treal-3 No-LOCK WHERE
                      treal-3.gds-code = ub.goods.gds-code AND
                      treal-3.is-out   = (chk-doc.chk-type = integer('1':U)) AND
                      (
                      p-without-src-code = yes
                      or
                      treal-3.src-code = temp-chk-gds.src-code) AND
                      treal-3.is-pay = temp-chk-pay.is-cash
                      No-ERROR.
            IF NOT AVAIL treal-3 then do:
              FIND last b-treal-3 No-LOCK WHERE
                        b-treal-3.gds-code = ub.goods.gds-code use-index vi No-ERROR.
              run create-g-treal-3 in this-procedure (
                            INPUT ub.goods.gds-code,
                            INPUT (chk-doc.chk-type = integer('1':U)),
                            INPUT  (if p-without-src-code then "":U else temp-chk-gds.src-code),
                            INPUT 0,
                            INPUT 0,
                            INPUT temp-chk-pay.obj-name,
                            input temp-chk-pay.is-cash,
                            INPUT (if avail b-treal-3
                                    then b-treal-3.ii + 1
                                    else 1)
                                  ) no-error.
            END.
            assign
            treal-3.netto = treal-3.netto + pychk_dop-sumk / pychk_exch
            treal-3.qnty1 = treal-3.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
            treal-3.netto-rubl = treal-3.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
            treal-3.rest-qnty = treal-3.qnty1
            .
          END.
        END.
      END CASE.
        end.
      if pychk_dop-sumg <= 0 then do:
        assign
        pychk_kk = pychk_kk + 1.
        if pychk_kk >= pychk_jj then LEAVE _repeat.
        if pychk_kk <= pychk_jjp then do:
          find first temp-chk-gds where
                    temp-chk-gds.doc-code = chk-doc.doc-code
              AND  temp-chk-gds.jjp_ = pychk_kk no-error .
        end.
        else do:
          find first temp-chk-gds where
                    temp-chk-gds.doc-code = chk-doc.doc-code
              AND  temp-chk-gds.jjo_ = pychk_kk - pychk_jjp no-error .
          if not available temp-chk-gds then do:
            LEAVE _repeat.
          end.
        end.
        pychk_dop-sumg = temp-chk-gds.sum.
        pychk_dop-sumg = temp-chk-gds.sum.
      end.
    END.
  end.
output close.
end.
  END.
end.
end procedure.
procedure process-two-tables :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-is-out   as logical no-undo .
define variable v-is-out-int     as integer no-undo .
  do
  on error undo, return error
  :
  run waitfram-show in this-procedure ("Ждите...").
  v-is-out-int = (if p-is-out then 1 else - 1).
  if p-gds-code = 0 then do:
    for each sj-print:
      delete sj-print.
    end.
  end.
  else do:
    for each sj-print where
          sj-print.gds-code = p-gds-code
      AND sj-print.is-out = p-is-out :
      delete sj-print.
    end.
  end.
  _cycle:
  for each sj-goods where
          sj-goods.gds-code > 0
       AND (p-gds-code = 0 or sj-goods.gds-code = p-gds-code)
       and (p-is-out = ? or sj-goods.is-out = p-is-out)
       and sj-goods.var-purch > 0,
  each treal-3 where
      treal-3.is-out   = sj-goods.is-out
  AND treal-3.gds-code = sj-goods.gds-code
  break
  by sj-goods.is-out
  by sj-goods.gds-code
  by sj-goods.var-purch
  by sj-goods.sale-sum descending
  by treal-3.is-out
  by treal-3.gds-code
  by treal-3.is-pay descending:
    if sj-goods.rest-qnty = 0
    or treal-3.rest-qnty = 0 then NEXT _cycle.
    if sj-goods.rest-qnty = treal-3.rest-qnty then do:
      create sj-print.                                                       buffer-copy sj-goods                                                   except sj-goods.qnty                                                   to sj-print                                                            assign                                                                 sj-print.qnty = (if sj-goods.is-out then 1 else (- 1)) * min(abs(treal-3.rest-qnty), abs(sj-goods.rest-qnty))             sj-print.is-cash = treal-3.is-pay                                      sj-print.sale-sum = (if sj-print.qnty = sj-goods.qnty                                       then sj-goods.sale-sum                                                 else (if sj-goods.price-flag                                                 then sj-goods.price-sale                                               else sj-goods.sale-sum / sj-goods.qnty) * sj-print.qnty                            ).
      assign
      treal-3.rest-qnty = 0
      sj-goods.rest-qnty = 0
      .
      next _cycle.
    end.
    if abs(sj-goods.rest-qnty) < abs(treal-3.rest-qnty) then do:
      create sj-print.                                                       buffer-copy sj-goods                                                   except sj-goods.qnty                                                   to sj-print                                                            assign                                                                 sj-print.qnty = (if sj-goods.is-out then 1 else (- 1)) * min(abs(treal-3.rest-qnty), abs(sj-goods.rest-qnty))             sj-print.is-cash = treal-3.is-pay                                      sj-print.sale-sum = (if sj-print.qnty = sj-goods.qnty                                       then sj-goods.sale-sum                                                 else (if sj-goods.price-flag                                                 then sj-goods.price-sale                                               else sj-goods.sale-sum / sj-goods.qnty) * sj-print.qnty                            ).
      assign
      treal-3.rest-qnty = (if sj-goods.is-out then 1 else (- 1)) * (abs(treal-3.rest-qnty) - abs(sj-goods.rest-qnty))
      sj-goods.rest-qnty = 0
      .
      next _cycle.
    end.
    if abs(sj-goods.rest-qnty) > abs(treal-3.rest-qnty) then do:
      create sj-print.                                                       buffer-copy sj-goods                                                   except sj-goods.qnty                                                   to sj-print                                                            assign                                                                 sj-print.qnty = (if sj-goods.is-out then 1 else (- 1)) * min(abs(treal-3.rest-qnty), abs(sj-goods.rest-qnty))             sj-print.is-cash = treal-3.is-pay                                      sj-print.sale-sum = (if sj-print.qnty = sj-goods.qnty                                       then sj-goods.sale-sum                                                 else (if sj-goods.price-flag                                                 then sj-goods.price-sale                                               else sj-goods.sale-sum / sj-goods.qnty) * sj-print.qnty                            ).
      assign
      sj-goods.rest-qnty = (if sj-goods.is-out then 1 else (- 1)) * (abs(sj-goods.rest-qnty) - abs(treal-3.rest-qnty))
      treal-3.rest-qnty = 0
      .
      next _cycle.
    end.
  end.
  run waitfram-hide in this-procedure .
  end.
end procedure.
procedure proc-print :
define variable v-supp as character no-undo .
define variable v-supp-name as character no-undo .
define variable date_string as character no-undo.
define variable v-header-base-curr as character no-undo .
DEFINE VARIABLE Line                as character                    no-undo .
define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo .
define variable g#log as logical no-undo .
define variable v-is-out-border as logical no-undo .
define variable v-is-out-border-2 as logical no-undo .
define buffer sj-goods00 for sj-goods.
DEFINE FRAME Purch-frame
sj-print.gds-code     column-label "Код товара"
sj-print.gds-name     column-label "Название товара" format "X(30)"
sj-print.price-sale   column-label "Цена нетто"
sj-print.price-flag   column-label "При!вед"            format "+/"
sj-print.is-cash      column-label "Нал"                format "+/"
sj-print.qnty         column-label "Количество"
sj-print.sale-sum     column-label "Сумма нетто"
sj-print.artic        column-label "Артикул"
sj-print.prod-name    column-label "Производитель"   format "X(30)"
v-supp                column-label "Поставщик"       format "X(12)"
v-supp-name           column-label "Поставщик-название" format "X(30)"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(177)" AT 1
with width 232 down stream-io use-text    .
  do
  on error undo, return error
  :
  date_string = cur-time-print() .
  if v-curr-r-b = 'base':U then do:
    assign
    v-header-base-curr = string( "( Б.Вал. - " + caps( v-r-b-abbr ) + " )" )
    .
  end.
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input 43
                                              ,input yes
                                              ,input no
                                              ).
  PUT  STREAM PrnLibStream
  SPACE(25) ( substitute("Отчет по зарезервированным партиям продажи &1 по вариантам закупки", buf_inkas.inkas-code) )
  format "x(90)" SKIP(2) .
  Line = fill("-", 198).
  FORM HEADER
  string(Line, "X(198)") AT 1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW  STREAM PrnLibStream FRAME BottomFrame .
  FORM with FRAME Purch-frame .
  run waitfram-show in this-procedure ("Ждите...").
  find first sj-goods00 no-lock where
            sj-goods00.gds-code = 0
         and sj-goods00.var-purch = 0 .
  display stream PrnLibStream
  "Вариант закупки 1" @ sj-print.qnty
  with frame Purch-Frame.
  DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
  assign
  v-is-out-border = yes
  v-is-out-border-2 = yes
  .
  for each sj-print no-lock where
         sj-print.gds-code > 0
     and sj-print.var-purch = 1
  break
  by sj-print.is-out descending
  by sj-print.var-purch
  by sj-print.sale-sum descending
   :
    if first-of(sj-print.is-out) then do:
      if sj-print.is-out then do:
        display stream PrnLibStream
        "РАСХОД" @ sj-print.qnty
        with frame Purch-Frame.
        DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
      end.
      else do:
        display stream PrnLibStream
        "ВОЗВРАТ" @ sj-print.qnty
        with frame Purch-Frame.
        DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
      end.
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = sj-print.supp-type
          AND buf_clients.obj-code = sj-print.supp-code no-error .
    Display STREAM PrnLibStream
    sj-print.gds-code
    sj-print.artic
    sj-print.gds-name
    sj-print.prod-name
    (sj-print.supp-type + string(sj-print.supp-code)) @ v-supp
    (if available buf_clients then buf_clients.obj-name else "":U) @ v-supp-name
    (if sj-print.price-flag
    then sj-print.price-sale
    else sj-print.sale-sum / sj-print.qnty) @ sj-print.price-sale
    sj-print.price-flag @ sj-print.price-flag
    sj-print.is-cash
    sj-print.qnty
    sj-print.sale-sum
    with FRAME Purch-Frame .
    DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
    if last-of(sj-print.is-out) then do:
      if sj-print.is-out then do:
        find first sj-goods no-lock where
                  sj-goods.gds-code = 0
              and sj-goods.is-out   =  yes
              and sj-goods.var-purch = 1 .
        assign
        var-sale-sum = var-sale-sum + sj-goods.sale-sum
        .
        UNDERLINE stream PrnLibStream    sj-print.gds-code                sj-print.artic                   sj-print.gds-name                sj-print.prod-name               v-supp                           v-supp-name                      sj-print.price-sale              sj-print.qnty                    sj-print.sale-sum                with frame Purch-Frame.
        display stream PrnLibStream                               sj-goods.gds-name  @ sj-print.gds-name                    sj-goods.prod-name @ sj-print.prod-name                   sj-goods.qnty      @ sj-print.qnty                        sj-goods.sale-sum  @ sj-print.sale-sum                    with frame Purch-Frame.                                   DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
        UNDERLINE stream PrnLibStream    sj-print.gds-code                sj-print.artic                   sj-print.gds-name                sj-print.prod-name               v-supp                           v-supp-name                      sj-print.price-sale              sj-print.qnty                    sj-print.sale-sum                with frame Purch-Frame.
      end.
      if not sj-print.is-out then do:
        find first sj-goods no-lock where
                  sj-goods.gds-code = 0
              AND SJ-GOODS.IS-OUT  = NO
              and sj-goods.var-purch = 1 .
        assign
        var-sale-sum = var-sale-sum + sj-goods.sale-sum
        .
        UNDERLINE stream PrnLibStream    sj-print.gds-code                sj-print.artic                   sj-print.gds-name                sj-print.prod-name               v-supp                           v-supp-name                      sj-print.price-sale              sj-print.qnty                    sj-print.sale-sum                with frame Purch-Frame.
        display stream PrnLibStream                               sj-goods.gds-name  @ sj-print.gds-name                    sj-goods.prod-name @ sj-print.prod-name                   sj-goods.qnty      @ sj-print.qnty                        sj-goods.sale-sum  @ sj-print.sale-sum                    with frame Purch-Frame.                                   DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
        UNDERLINE stream PrnLibStream    sj-print.gds-code                sj-print.artic                   sj-print.gds-name                sj-print.prod-name               v-supp                           v-supp-name                      sj-print.price-sale              sj-print.qnty                    sj-print.sale-sum                with frame Purch-Frame.
      end.
    end.
  END.
  display stream PrnLibStream
  "Итого по варианту закупки 1 в %" @ sj-print.gds-name
  string(var-sale-sum / sj-goods00.sale-sum * 100, "->>9.999%") @ sj-print.sale-sum
  with frame Purch-Frame.
  DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
  assign
  var-sale-sum = 0
  .
  put stream PrnLibStream unformatted string(Line, "X(198)") skip.
  display stream PrnLibStream
  "Вариант закупки 2" @ sj-print.qnty
  with frame Purch-Frame.
  DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
  for each sj-print no-lock where
         sj-print.gds-code > 0
     and sj-print.var-purch = 2
  break
  by sj-print.is-out descending
  by sj-print.var-purch
  by sj-print.sale-sum descending
  :
    if first-of(sj-print.is-out) then do:
      if sj-print.is-out then do:
        display stream PrnLibStream
        "РАСХОД" @ sj-print.qnty
        with frame Purch-Frame.
        DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
      end.
      else do:
        display stream PrnLibStream
        "ВОЗВРАТ" @ sj-print.qnty
        with frame Purch-Frame.
        DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
      end.
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = sj-print.supp-type
          AND buf_clients.obj-code = sj-print.supp-code no-error .
    Display STREAM PrnLibStream
    sj-print.gds-code
    sj-print.artic
    sj-print.gds-name
    sj-print.prod-name
    (sj-print.supp-type + string(sj-print.supp-code)) @ v-supp
    (if available buf_clients then buf_clients.obj-name else "":U) @ v-supp-name
    (if not sj-print.price-flag
    then sj-print.price-sale
    else sj-print.sale-sum / sj-print.qnty) @ sj-print.price-sale
    sj-print.price-flag @ sj-print.price-flag
    sj-print.is-cash
    sj-print.qnty
    sj-print.sale-sum
    with FRAME Purch-Frame .
    DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
    if last-of(sj-print.is-out) then do:
      if sj-print.is-out then do:
        find first sj-goods no-lock where
                  sj-goods.gds-code = 0
              and sj-goods.is-out   =  yes
              and sj-goods.var-purch = 2 .
        assign
        var-sale-sum = var-sale-sum + sj-goods.sale-sum
        .
        UNDERLINE stream PrnLibStream    sj-print.gds-code                sj-print.artic                   sj-print.gds-name                sj-print.prod-name               v-supp                           v-supp-name                      sj-print.price-sale              sj-print.qnty                    sj-print.sale-sum                with frame Purch-Frame.
        display stream PrnLibStream                               sj-goods.gds-name  @ sj-print.gds-name                    sj-goods.prod-name @ sj-print.prod-name                   sj-goods.qnty      @ sj-print.qnty                        sj-goods.sale-sum  @ sj-print.sale-sum                    with frame Purch-Frame.                                   DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
        UNDERLINE stream PrnLibStream    sj-print.gds-code                sj-print.artic                   sj-print.gds-name                sj-print.prod-name               v-supp                           v-supp-name                      sj-print.price-sale              sj-print.qnty                    sj-print.sale-sum                with frame Purch-Frame.
      end.
      else do:
        find first sj-goods no-lock where
                  sj-goods.gds-code = 0
              and sj-goods.is-out = no
              and sj-goods.var-purch = 2 .
        assign
        var-sale-sum = var-sale-sum + sj-goods.sale-sum
        .
        UNDERLINE stream PrnLibStream    sj-print.gds-code                sj-print.artic                   sj-print.gds-name                sj-print.prod-name               v-supp                           v-supp-name                      sj-print.price-sale              sj-print.qnty                    sj-print.sale-sum                with frame Purch-Frame.
        display stream PrnLibStream                               sj-goods.gds-name  @ sj-print.gds-name                    sj-goods.prod-name @ sj-print.prod-name                   sj-goods.qnty      @ sj-print.qnty                        sj-goods.sale-sum  @ sj-print.sale-sum                    with frame Purch-Frame.                                   DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
        UNDERLINE stream PrnLibStream    sj-print.gds-code                sj-print.artic                   sj-print.gds-name                sj-print.prod-name               v-supp                           v-supp-name                      sj-print.price-sale              sj-print.qnty                    sj-print.sale-sum                with frame Purch-Frame.
      end.
    end.
  END.
  display stream PrnLibStream
  "Итого по варианту закупки 2 в %" @ sj-print.gds-name
  string(var-sale-sum / sj-goods00.sale-sum * 100, "->>9.999%") @ sj-print.sale-sum
  with frame Purch-Frame.
  DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
  UNDERLINE stream PrnLibStream    sj-print.gds-code                sj-print.artic                   sj-print.gds-name                sj-print.prod-name               v-supp                           v-supp-name                      sj-print.price-sale              sj-print.qnty                    sj-print.sale-sum                with frame Purch-Frame.
  display stream PrnLibStream
  "ИТОГО ПО ВСЕМ ВАРИАНТАМ ЗАКУПКИ" @ sj-print.gds-name
  sj-goods00.sale-sum  @ sj-print.sale-sum
  with frame Purch-Frame.
  DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
  HIDE  STREAM PrnLibStream FRAME BottomFrame .
  HIDE  STREAM PrnLibStream FRAME Chk-List.
  output STREAM PrnLibStream CLOSE.
  run get-report-num  in parParentProc(output g#report-num).
  run get-quest-print in parParentProc(output g#quest-print).
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 8 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
  end.
end procedure.
procedure proc-export :
define parameter buffer buf_inkas for ub.inkas.
define input parameter p-z-number   like ub.chk-doc.z-number no-undo .
define input parameter p-pay-desk  like ub.chk-doc.pay-desk no-undo .
define variable v-short-file-name as character no-undo .
define variable v-file-name         as character no-undo .
define variable v-full-path         as character no-undo .
define variable v-path              as character no-undo .
define variable v-file-name-no-ext  as character no-undo .
define variable v-file-name-ext     as character no-undo .
define variable ii                  as integer no-undo .
define variable v-is-out-int        as integer no-undo .
define variable v-full-path-two     as character no-undo .
  do
  on error undo, return error
  :
    run waitfram-show in this-procedure ("Ждите...").
    do ii = 1 to 2:
      assign
      v-short-file-name = 'маг':U + string(buf_inkas.obj-code) + "_"  +
                          "kassa":U + string(p-pay-desk) + "_" +
                          "z":U + string(p-z-number) + "_" +
                          (if ii = 1 then "v" else "r") + ".txt".
      v-is-out-int = if ii = 1 then (- 1) else 1.
      output stream PrnLibStream to value(v-short-file-name).
      _cycle:
      for each sj-goods where
              sj-goods.gds-code > 0
          and sj-goods.var-purch > 0
          and sj-goods.is-out = (if ii = 1 then no else yes) ,
      each treal-3 where
          treal-3.is-out   = sj-goods.is-out
      AND treal-3.gds-code = sj-goods.gds-code
      break
      by sj-goods.is-out
      by sj-goods.gds-code
      by sj-goods.var-purch
      by sj-goods.sale-sum descending
      by treal-3.is-out
      by treal-3.gds-code
      by treal-3.is-pay descending
      by treal-3.src-code:
        if sj-goods.rest-qnty = 0
        or treal-3.rest-qnty = 0 then next _cycle.
        if sj-goods.rest-qnty = treal-3.rest-qnty then do:
          if sj-goods.var-purch = 2 and treal-3.is-pay then do:          put stream PrnLibStream unformatted         treal-3.src-code chr(44) v-is-out-int * min(abs(treal-3.rest-qnty), abs(sj-goods.rest-qnty)) chr(32) .       end.
          assign
          sj-goods.rest-qnty = 0
          treal-3.rest-qnty = 0
          .
          next _cycle.
        end.
        if abs(sj-goods.rest-qnty) < abs(treal-3.rest-qnty) then do:
          if sj-goods.var-purch = 2 and treal-3.is-pay then do:          put stream PrnLibStream unformatted         treal-3.src-code chr(44) v-is-out-int * min(abs(treal-3.rest-qnty), abs(sj-goods.rest-qnty)) chr(32) .       end.
          assign
          treal-3.rest-qnty = v-is-out-int * (abs(treal-3.rest-qnty) - abs(sj-goods.rest-qnty))
          sj-goods.rest-qnty = 0
          .
          next _cycle.
        end.
        if abs(sj-goods.rest-qnty) > abs(treal-3.rest-qnty) then do:
          if sj-goods.var-purch = 2 and treal-3.is-pay then do:          put stream PrnLibStream unformatted         treal-3.src-code chr(44) v-is-out-int * min(abs(treal-3.rest-qnty), abs(sj-goods.rest-qnty)) chr(32) .       end.
          assign
          sj-goods.rest-qnty = v-is-out-int * (abs(sj-goods.rest-qnty) - abs(treal-3.rest-qnty))
          treal-3.rest-qnty = 0
          .
          next _cycle.
        end.
      end.
      put stream PrnLibStream unformatted skip.
      output STREAM PrnLibStream CLOSE.
      run gbl/filename.p
        (input  v-short-file-name
        ,output v-full-path
        ,output v-path
        ,output v-file-name
        ,output v-file-name-no-ext
        ,output v-file-name-ext
        ) no-error  .
      if error-status :error
      then do:
        message
        "Не найден файл экспорта" v-short-file-name
        view-as alert-box .
      end.
      v-full-path-two = v-full-path-two + chr(10) + v-full-path.
    end.
    run waitfram-hide in this-procedure .
    message
    "Экспорт завершен" skip
    "Файл(-ы) экспорта" v-full-path-two
    view-as alert-box.
  end.
end procedure.
