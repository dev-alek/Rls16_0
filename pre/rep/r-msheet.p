block-level on error undo, throw.
define input parameter parparentproc      as widget-handle      no-undo.
define input parameter pardate-shift      as integer            no-undo.
define input parameter parstart_date      as date               no-undo.
define input parameter parstart_shift_num as integer            no-undo.
define input parameter parend_date        as date               no-undo.
define input parameter parend_shift_num   as integer            no-undo.
define input parameter pargds-code        like ub.goods.gds-code   no-undo.
define input parameter parobj-type        like ub.clients.obj-type no-undo.
define input parameter parobj-code        like ub.clients.obj-code no-undo.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-msheet.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-msheet.p $":U .
def var vss-description as character no-undo init "Накопительная ведомость".
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
define   stream repstr.
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
        output stream repstr to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream repstr to value( v-report-name )
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
        OUTPUT stream repstr TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream repstr TO value ( p-ReportFileName ) PAGE-SIZE 0.
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
define variable p-host-code as integer no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output p-host-code
  )  .
define buffer frm-clients  for ub.clients.
define buffer bef-rvs-doc  for ub.rvs-doc.
define buffer aft-rvs-doc  for ub.rvs-doc.
define buffer bef-rvs-line for ub.rvs-line.
define buffer aft-rvs-line for ub.rvs-line.
define buffer buf_goods    for ub.goods .
define buffer buf_clients  for ub.clients .
define buffer buf_trn-doc  for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_doc-pl   for ub.doc-pl .
def var v-ind         as integer   no-undo .
def var v-line        as character no-undo format "X(135)" .
assign
  v-line = fill("-", 135 )
.
def var v-line1        as character no-undo format "X(135)" .
def var v-line2        as character no-undo format "X(135)" .
def var v-line3        as character no-undo format "X(135)" .
assign
  v-line1 = v-line
  v-line2 = v-line
  v-line3 = v-line
.
def var sym1  as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym2  as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym3  as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym4  as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym5  as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym6  as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym7  as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym8  as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym9  as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym10 as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym11 as character no-undo format "x(1)":u label '!':u init ":":u .
def var sym12 as character no-undo format "x(1)":u label '!':u init ":":u .
run waitfram-show in this-procedure ( input 'Подождите ...' ).
run prn-lib-open-stream in this-procedure ( input parparentproc, input 45, input yes, input no ).
def var v-host-name   as character no-undo.
def var v-obj-name    as character no-undo.
def var v-header-name as character no-undo.
def var v-print-time  as character no-undo.
define variable vardate-shift  as   character      no-undo.
define variable vardeviationdoc-qnty like ub.doc-line.doc-qnty         no-undo.
define variable vardeviationcli-qnty like ub.doc-line.fact-qnty        no-undo.
define variable vardeviationperc     as decimal format "->>>9.99<"  no-undo.
define variable vardevfactdoc-qnty   like ub.doc-line.doc-qnty         no-undo.
define variable vardevfactcli-qnty   like ub.doc-line.fact-qnty        no-undo.
define variable vardevfactperc       as decimal format "->>>9.99<"  no-undo.
define variable varmeasure-qnty      like ub.rvs-line.measure-qnty     no-undo.
define variable varmeasure-cli-qnty  like ub.rvs-line.measure-cli-qnty no-undo.
assign
  v-header-name = "                           Н А К О П И Т Е Л Ь Н А Я  В Е Д О М О С Т Ь "
  v-print-time  = cur-time-string()
.
find first buf_goods where buf_goods.gds-code = pargds-code no-lock.
find first buf_clients no-lock
  where buf_clients.obj-type = parobj-type
    and buf_clients.obj-code = parobj-code
  .
assign
  v-obj-name = buf_clients.obj-name
.
find first frm-clients no-lock
  where frm-clients.obj-type = 'орг':U
    and frm-clients.obj-code = p-host-code
  .
assign
  v-host-name = frm-clients.obj-name
.
define frame doc-line-frm
  sym1  space(0) buf_trn-doc.shift-name   format "X(5)" column-label "1" space(0)
  sym2  space(0) buf_trn-doc.shift-date   format "99/99/99" column-label "2" space(0)
  sym3  space(0) buf_trn-doc.doc-code     format "x(14)" column-label "3" space(0)
  sym4  space(0) buf_doc-line.doc-qnty    format "->>,>>>,>>9.<<<" column-label "4" space(0)
  sym5  space(0) buf_doc-line.cli-qnty    format "->>,>>>,>>9.<<<" column-label "5" space(0)
  sym6  space(0) vardeviationdoc-qnty    format "->>,>>>,>>9.<<<" column-label "6" space(0)
  sym7  space(0) vardeviationcli-qnty    format "->>,>>>,>>9.<<<" column-label "7" space(0)
  sym8  space(0) vardeviationperc        format "->>>,>>>9.99<" column-label "8" space(0)
  sym9  space(0) vardevfactdoc-qnty      format "->>,>>>,>>9.<<<" column-label "9" space(0)
  sym10 space(0) vardevfactcli-qnty      format "->>,>>>,>>9.<<<" column-label "10" space(0)
  sym11 space(0) vardevfactperc          format "->>>,>>>9.99<" column-label "11" space(0)
  sym12 space(0)
  with width 137  down stream-io use-text .
form with frame doc-line-frm .
put stream repstr unformatted
  "   Наименование организации " string(v-host-name + fill(" ", 40), "x(40)")  skip
  "   АЗС: "  v-obj-name  skip
  "                           Н А К О П И Т Е Л Ь Н А Я  В Е Д О М О С Т Ь " skip
  "   Начало периода " (if pardate-shift <= 2 then string(parstart_date) else string(parstart_date) + ":" + string(parstart_shift_num)) skip
  "   Конец периода  " (if pardate-shift <= 2 then string(parend_date)   else string(parend_date)   + ":" + string(parend_shift_num))   skip
  "   Наименование нефтепродукта " buf_goods.artic " " buf_goods.gds-name skip
  .
put stream repstr unformatted
  v-line skip
   STRING("!     ", "X(6)") STRING("!        ", "X(9)") STRING("!              ", "X(15)") STRING("!            ", "X(13)") STRING("             ", "X(13)") STRING("!  Отклонение", "X(13)") STRING(" принятого   ", "X(13)") STRING("!            ", "X(13)") STRING("!  Отклонение", "X(13)") STRING(" принятого   ", "X(13)") STRING("!            !", "X(14)") skip
   STRING("!Номер", "X(6)") STRING("!  Дата  ", "X(9)") STRING("!              ", "X(15)") STRING("!  Поступило ", "X(13)") STRING("по ТТН       ", "X(13)") STRING("!          по", "X(13)") STRING(" приборам    ", "X(13)") STRING("!Погрешность ", "X(13)") STRING("!          по", "X(13)") STRING(" факту       ", "X(13)") STRING("!Погрешность !", "X(14)") skip
   STRING("!смены", "X(6)") STRING("! начала ", "X(9)") STRING("!    № ТТН     ", "X(15)") STRING("!____________", "X(13)") STRING("_____________", "X(13)") STRING("!____________", "X(13)") STRING("_____________", "X(13)") STRING("!     в %    ", "X(13)") STRING("!____________", "X(13)") STRING("_____________", "X(13)") STRING("!     в %    !", "X(14)") skip
   STRING("!     ", "X(6)") STRING("! смены  ", "X(9)") STRING("!              ", "X(15)") STRING("!      в     ", "X(13)") STRING("!     в      ", "X(13)") STRING("!      в     ", "X(13)") STRING("!      в     ", "X(13)") STRING("!            ", "X(13)") STRING("!      в     ", "X(13)") STRING("!      в     ", "X(13)") STRING("!            !", "X(14)") skip
   STRING("!     ", "X(6)") STRING("!        ", "X(9)") STRING("!              ", "X(15)") STRING("!   литрах   ", "X(13)") STRING("!килограммах ", "X(13)") STRING("!    литрах  ", "X(13)") STRING("! килограммах", "X(13)") STRING("!            ", "X(13)") STRING("!    литрах  ", "X(13)") STRING("! килограммах", "X(13)") STRING("!            !", "X(14)") skip
  v-line
  .
form header
  v-line1 at 1 skip
  v-header-name format "x(50)" at 1
    "Дата:" at 60
    v-print-time format "x(20)"
    "Стр." at 100 string( page-number(repstr), ">>>9" )  skip
  v-line2 at 1 skip
  with frame topframe
  width 137 page-top no-labels no-box .
view stream repstr frame topframe .
form header
  v-line skip
  "Продолжение на следующей странице " at 30 skip
  with frame bottomframe
  width 137 page-bottom no-labels no-box .
view stream repstr frame bottomframe .
CASE pardate-shift :
    WHEN 1 THEN DO:
            for each buf_trn-doc where                             buf_trn-doc.obj-type    = parobj-type and                             buf_trn-doc.obj-code    = parobj-code and                             buf_trn-doc.fact-date >= parstart_date and buf_trn-doc.fact-date <= parend_date and                             buf_trn-doc.status_     = 'факт':U                              and buf_trn-doc.doc-type = 'при':U and buf_trn-doc.internal = no,                                                     each buf_doc-line no-lock where                             buf_doc-line.doc-code   = buf_trn-doc.doc-code     and                             buf_doc-line.artic      = buf_goods.artic     and                             buf_doc-line.prod-type  = buf_goods.prod-type and                             buf_doc-line.prod-code  = buf_goods.prod-code                                                  :
ASSIGN varmeasure-qnty     = ?
       varmeasure-cli-qnty = ?.
find first bef-rvs-doc where bef-rvs-doc.out-code = buf_trn-doc.doc-code and
                             bef-rvs-doc.rvs-type = 'перед_док':U no-lock no-error.
if available bef-rvs-doc then do:
   find first aft-rvs-doc where aft-rvs-doc.out-code = buf_trn-doc.doc-code and
                                aft-rvs-doc.rvs-type = 'перед_док':U no-lock no-error.
   if available aft-rvs-doc then do:
      for each buf_doc-pl where buf_doc-pl.out-code = buf_trn-doc.doc-code and
                            buf_doc-pl.gds-code = buf_goods.gds-code   no-lock:
          find first bef-rvs-line where bef-rvs-line.rvs-code = bef-rvs-doc.rvs-code and
                                        bef-rvs-line.obj-type = buf_doc-pl.obj-type      and
                                        bef-rvs-line.obj-code = buf_doc-pl.obj-code      and
                                        bef-rvs-line.pl-code  = buf_doc-pl.pl-code       and
                                        bef-rvs-line.gds-code = buf_doc-pl.gds-code      no-lock.
          find first aft-rvs-line where aft-rvs-line.rvs-code = aft-rvs-doc.rvs-code and
                                        aft-rvs-line.obj-type = buf_doc-pl.obj-type      and
                                        aft-rvs-line.obj-code = buf_doc-pl.obj-code      and
                                        aft-rvs-line.pl-code  = buf_doc-pl.pl-code       and
                                        aft-rvs-line.gds-code = buf_doc-pl.gds-code      no-lock.
          ACCUMULATE (aft-rvs-line.measure-qnty     - bef-rvs-line.measure-qnty)     (TOTAL)
                     (aft-rvs-line.measure-cli-qnty - bef-rvs-line.measure-cli-qnty) (TOTAL).
      end.
      ASSIGN varmeasure-qnty     = (ACCUM TOTAL (aft-rvs-line.measure-qnty     - bef-rvs-line.measure-qnty)    )
             varmeasure-cli-qnty = (ACCUM TOTAL (aft-rvs-line.measure-cli-qnty - bef-rvs-line.measure-cli-qnty)).
   end.
end.
ASSIGN
vardeviationdoc-qnty = buf_doc-line.doc-qnty - varmeasure-qnty
vardeviationcli-qnty = buf_doc-line.cli-qnty - varmeasure-cli-qnty
vardeviationperc     = vardeviationdoc-qnty / buf_doc-line.doc-qnty * 100
vardevfactdoc-qnty   = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty
vardevfactcli-qnty   = buf_doc-line.cli-qnty - buf_doc-line.fact-qnty / buf_doc-line.cli-base-rate
vardevfactperc       = vardevfactdoc-qnty   / buf_doc-line.doc-qnty * 100.
ACCUMULATE buf_doc-line.doc-qnty    (TOTAL)
           buf_doc-line.cli-qnty    (TOTAL)
           vardeviationdoc-qnty (TOTAL)
           vardeviationcli-qnty (TOTAL)
           vardevfactdoc-qnty   (TOTAL)
           vardevfactcli-qnty   (TOTAL).
display stream repstr
sym1  space(0) buf_trn-doc.shift-name
sym2  space(0) buf_trn-doc.shift-date
sym3  space(0) buf_trn-doc.doc-code
sym4  space(0) buf_doc-line.doc-qnty
sym5  space(0) buf_doc-line.cli-qnty
sym6  space(0) vardeviationdoc-qnty
sym7  space(0) vardeviationcli-qnty
sym8  space(0) vardeviationperc
sym9  space(0) vardevfactdoc-qnty
sym10 space(0) vardevfactcli-qnty
sym11 space(0) vardevfactperc
sym12 space(0)
with frame doc-line-frm .
down stream repstr 1 with frame doc-line-frm.                    end.
    END.
    WHEN 2 THEN DO:
            for each buf_trn-doc where                             buf_trn-doc.obj-type    = parobj-type and                             buf_trn-doc.obj-code    = parobj-code and                             buf_trn-doc.shift-date >= parstart_date and buf_trn-doc.shift-date <= parend_date and                             buf_trn-doc.status_     = 'факт':U                              and buf_trn-doc.doc-type = 'при':U and buf_trn-doc.internal = no,                                                     each buf_doc-line no-lock where                             buf_doc-line.doc-code   = buf_trn-doc.doc-code     and                             buf_doc-line.artic      = buf_goods.artic     and                             buf_doc-line.prod-type  = buf_goods.prod-type and                             buf_doc-line.prod-code  = buf_goods.prod-code                                                  :
ASSIGN varmeasure-qnty     = ?
       varmeasure-cli-qnty = ?.
find first bef-rvs-doc where bef-rvs-doc.out-code = buf_trn-doc.doc-code and
                             bef-rvs-doc.rvs-type = 'перед_док':U no-lock no-error.
if available bef-rvs-doc then do:
   find first aft-rvs-doc where aft-rvs-doc.out-code = buf_trn-doc.doc-code and
                                aft-rvs-doc.rvs-type = 'перед_док':U no-lock no-error.
   if available aft-rvs-doc then do:
      for each buf_doc-pl where buf_doc-pl.out-code = buf_trn-doc.doc-code and
                            buf_doc-pl.gds-code = buf_goods.gds-code   no-lock:
          find first bef-rvs-line where bef-rvs-line.rvs-code = bef-rvs-doc.rvs-code and
                                        bef-rvs-line.obj-type = buf_doc-pl.obj-type      and
                                        bef-rvs-line.obj-code = buf_doc-pl.obj-code      and
                                        bef-rvs-line.pl-code  = buf_doc-pl.pl-code       and
                                        bef-rvs-line.gds-code = buf_doc-pl.gds-code      no-lock.
          find first aft-rvs-line where aft-rvs-line.rvs-code = aft-rvs-doc.rvs-code and
                                        aft-rvs-line.obj-type = buf_doc-pl.obj-type      and
                                        aft-rvs-line.obj-code = buf_doc-pl.obj-code      and
                                        aft-rvs-line.pl-code  = buf_doc-pl.pl-code       and
                                        aft-rvs-line.gds-code = buf_doc-pl.gds-code      no-lock.
          ACCUMULATE (aft-rvs-line.measure-qnty     - bef-rvs-line.measure-qnty)     (TOTAL)
                     (aft-rvs-line.measure-cli-qnty - bef-rvs-line.measure-cli-qnty) (TOTAL).
      end.
      ASSIGN varmeasure-qnty     = (ACCUM TOTAL (aft-rvs-line.measure-qnty     - bef-rvs-line.measure-qnty)    )
             varmeasure-cli-qnty = (ACCUM TOTAL (aft-rvs-line.measure-cli-qnty - bef-rvs-line.measure-cli-qnty)).
   end.
end.
ASSIGN
vardeviationdoc-qnty = buf_doc-line.doc-qnty - varmeasure-qnty
vardeviationcli-qnty = buf_doc-line.cli-qnty - varmeasure-cli-qnty
vardeviationperc     = vardeviationdoc-qnty / buf_doc-line.doc-qnty * 100
vardevfactdoc-qnty   = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty
vardevfactcli-qnty   = buf_doc-line.cli-qnty - buf_doc-line.fact-qnty / buf_doc-line.cli-base-rate
vardevfactperc       = vardevfactdoc-qnty   / buf_doc-line.doc-qnty * 100.
ACCUMULATE buf_doc-line.doc-qnty    (TOTAL)
           buf_doc-line.cli-qnty    (TOTAL)
           vardeviationdoc-qnty (TOTAL)
           vardeviationcli-qnty (TOTAL)
           vardevfactdoc-qnty   (TOTAL)
           vardevfactcli-qnty   (TOTAL).
display stream repstr
sym1  space(0) buf_trn-doc.shift-name
sym2  space(0) buf_trn-doc.shift-date
sym3  space(0) buf_trn-doc.doc-code
sym4  space(0) buf_doc-line.doc-qnty
sym5  space(0) buf_doc-line.cli-qnty
sym6  space(0) vardeviationdoc-qnty
sym7  space(0) vardeviationcli-qnty
sym8  space(0) vardeviationperc
sym9  space(0) vardevfactdoc-qnty
sym10 space(0) vardevfactcli-qnty
sym11 space(0) vardevfactperc
sym12 space(0)
with frame doc-line-frm .
down stream repstr 1 with frame doc-line-frm.                    end.
    END.
    WHEN 3 THEN DO:
              for each buf_trn-doc where                             buf_trn-doc.obj-type    = parobj-type and                             buf_trn-doc.obj-code    = parobj-code and                             ( buf_trn-doc.shift-date >  parstart_date        or                                buf_trn-doc.shift-date  = parstart_date        and                               buf_trn-doc.shift-num  >= parstart_shift_num ) and                             ( buf_trn-doc.shift-date <  parend_date          or                                buf_trn-doc.shift-date  = parend_date          and                               buf_trn-doc.shift-num  <= parend_shift_num )   and                             buf_trn-doc.status_     = 'факт':U                              and buf_trn-doc.doc-type = 'при':U and buf_trn-doc.internal = no,                                                     each buf_doc-line no-lock where                             buf_doc-line.doc-code   = buf_trn-doc.doc-code     and                             buf_doc-line.artic      = buf_goods.artic     and                             buf_doc-line.prod-type  = buf_goods.prod-type and                             buf_doc-line.prod-code  = buf_goods.prod-code                                                  :
ASSIGN varmeasure-qnty     = ?
       varmeasure-cli-qnty = ?.
find first bef-rvs-doc where bef-rvs-doc.out-code = buf_trn-doc.doc-code and
                             bef-rvs-doc.rvs-type = 'перед_док':U no-lock no-error.
if available bef-rvs-doc then do:
   find first aft-rvs-doc where aft-rvs-doc.out-code = buf_trn-doc.doc-code and
                                aft-rvs-doc.rvs-type = 'перед_док':U no-lock no-error.
   if available aft-rvs-doc then do:
      for each buf_doc-pl where buf_doc-pl.out-code = buf_trn-doc.doc-code and
                            buf_doc-pl.gds-code = buf_goods.gds-code   no-lock:
          find first bef-rvs-line where bef-rvs-line.rvs-code = bef-rvs-doc.rvs-code and
                                        bef-rvs-line.obj-type = buf_doc-pl.obj-type      and
                                        bef-rvs-line.obj-code = buf_doc-pl.obj-code      and
                                        bef-rvs-line.pl-code  = buf_doc-pl.pl-code       and
                                        bef-rvs-line.gds-code = buf_doc-pl.gds-code      no-lock.
          find first aft-rvs-line where aft-rvs-line.rvs-code = aft-rvs-doc.rvs-code and
                                        aft-rvs-line.obj-type = buf_doc-pl.obj-type      and
                                        aft-rvs-line.obj-code = buf_doc-pl.obj-code      and
                                        aft-rvs-line.pl-code  = buf_doc-pl.pl-code       and
                                        aft-rvs-line.gds-code = buf_doc-pl.gds-code      no-lock.
          ACCUMULATE (aft-rvs-line.measure-qnty     - bef-rvs-line.measure-qnty)     (TOTAL)
                     (aft-rvs-line.measure-cli-qnty - bef-rvs-line.measure-cli-qnty) (TOTAL).
      end.
      ASSIGN varmeasure-qnty     = (ACCUM TOTAL (aft-rvs-line.measure-qnty     - bef-rvs-line.measure-qnty)    )
             varmeasure-cli-qnty = (ACCUM TOTAL (aft-rvs-line.measure-cli-qnty - bef-rvs-line.measure-cli-qnty)).
   end.
end.
ASSIGN
vardeviationdoc-qnty = buf_doc-line.doc-qnty - varmeasure-qnty
vardeviationcli-qnty = buf_doc-line.cli-qnty - varmeasure-cli-qnty
vardeviationperc     = vardeviationdoc-qnty / buf_doc-line.doc-qnty * 100
vardevfactdoc-qnty   = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty
vardevfactcli-qnty   = buf_doc-line.cli-qnty - buf_doc-line.fact-qnty / buf_doc-line.cli-base-rate
vardevfactperc       = vardevfactdoc-qnty   / buf_doc-line.doc-qnty * 100.
ACCUMULATE buf_doc-line.doc-qnty    (TOTAL)
           buf_doc-line.cli-qnty    (TOTAL)
           vardeviationdoc-qnty (TOTAL)
           vardeviationcli-qnty (TOTAL)
           vardevfactdoc-qnty   (TOTAL)
           vardevfactcli-qnty   (TOTAL).
display stream repstr
sym1  space(0) buf_trn-doc.shift-name
sym2  space(0) buf_trn-doc.shift-date
sym3  space(0) buf_trn-doc.doc-code
sym4  space(0) buf_doc-line.doc-qnty
sym5  space(0) buf_doc-line.cli-qnty
sym6  space(0) vardeviationdoc-qnty
sym7  space(0) vardeviationcli-qnty
sym8  space(0) vardeviationperc
sym9  space(0) vardevfactdoc-qnty
sym10 space(0) vardevfactcli-qnty
sym11 space(0) vardevfactperc
sym12 space(0)
with frame doc-line-frm .
down stream repstr 1 with frame doc-line-frm.                    end.
    END.
    WHEN 4 THEN DO:
               for each buf_trn-doc where                             buf_trn-doc.obj-type    = parobj-type and                             buf_trn-doc.obj-code    = parobj-code and                             buf_trn-doc.shift-date >= parstart_date      and                             buf_trn-doc.shift-num   = parstart_shift_num and                             buf_trn-doc.shift-date <= parend_date        and                             buf_trn-doc.shift-num   = parend_shift_num   and                             buf_trn-doc.status_     = 'факт':U                              and buf_trn-doc.doc-type = 'при':U and buf_trn-doc.internal = no,                                                     each buf_doc-line no-lock where                             buf_doc-line.doc-code   = buf_trn-doc.doc-code     and                             buf_doc-line.artic      = buf_goods.artic     and                             buf_doc-line.prod-type  = buf_goods.prod-type and                             buf_doc-line.prod-code  = buf_goods.prod-code                                                  :
ASSIGN varmeasure-qnty     = ?
       varmeasure-cli-qnty = ?.
find first bef-rvs-doc where bef-rvs-doc.out-code = buf_trn-doc.doc-code and
                             bef-rvs-doc.rvs-type = 'перед_док':U no-lock no-error.
if available bef-rvs-doc then do:
   find first aft-rvs-doc where aft-rvs-doc.out-code = buf_trn-doc.doc-code and
                                aft-rvs-doc.rvs-type = 'перед_док':U no-lock no-error.
   if available aft-rvs-doc then do:
      for each buf_doc-pl where buf_doc-pl.out-code = buf_trn-doc.doc-code and
                            buf_doc-pl.gds-code = buf_goods.gds-code   no-lock:
          find first bef-rvs-line where bef-rvs-line.rvs-code = bef-rvs-doc.rvs-code and
                                        bef-rvs-line.obj-type = buf_doc-pl.obj-type      and
                                        bef-rvs-line.obj-code = buf_doc-pl.obj-code      and
                                        bef-rvs-line.pl-code  = buf_doc-pl.pl-code       and
                                        bef-rvs-line.gds-code = buf_doc-pl.gds-code      no-lock.
          find first aft-rvs-line where aft-rvs-line.rvs-code = aft-rvs-doc.rvs-code and
                                        aft-rvs-line.obj-type = buf_doc-pl.obj-type      and
                                        aft-rvs-line.obj-code = buf_doc-pl.obj-code      and
                                        aft-rvs-line.pl-code  = buf_doc-pl.pl-code       and
                                        aft-rvs-line.gds-code = buf_doc-pl.gds-code      no-lock.
          ACCUMULATE (aft-rvs-line.measure-qnty     - bef-rvs-line.measure-qnty)     (TOTAL)
                     (aft-rvs-line.measure-cli-qnty - bef-rvs-line.measure-cli-qnty) (TOTAL).
      end.
      ASSIGN varmeasure-qnty     = (ACCUM TOTAL (aft-rvs-line.measure-qnty     - bef-rvs-line.measure-qnty)    )
             varmeasure-cli-qnty = (ACCUM TOTAL (aft-rvs-line.measure-cli-qnty - bef-rvs-line.measure-cli-qnty)).
   end.
end.
ASSIGN
vardeviationdoc-qnty = buf_doc-line.doc-qnty - varmeasure-qnty
vardeviationcli-qnty = buf_doc-line.cli-qnty - varmeasure-cli-qnty
vardeviationperc     = vardeviationdoc-qnty / buf_doc-line.doc-qnty * 100
vardevfactdoc-qnty   = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty
vardevfactcli-qnty   = buf_doc-line.cli-qnty - buf_doc-line.fact-qnty / buf_doc-line.cli-base-rate
vardevfactperc       = vardevfactdoc-qnty   / buf_doc-line.doc-qnty * 100.
ACCUMULATE buf_doc-line.doc-qnty    (TOTAL)
           buf_doc-line.cli-qnty    (TOTAL)
           vardeviationdoc-qnty (TOTAL)
           vardeviationcli-qnty (TOTAL)
           vardevfactdoc-qnty   (TOTAL)
           vardevfactcli-qnty   (TOTAL).
display stream repstr
sym1  space(0) buf_trn-doc.shift-name
sym2  space(0) buf_trn-doc.shift-date
sym3  space(0) buf_trn-doc.doc-code
sym4  space(0) buf_doc-line.doc-qnty
sym5  space(0) buf_doc-line.cli-qnty
sym6  space(0) vardeviationdoc-qnty
sym7  space(0) vardeviationcli-qnty
sym8  space(0) vardeviationperc
sym9  space(0) vardevfactdoc-qnty
sym10 space(0) vardevfactcli-qnty
sym11 space(0) vardevfactperc
sym12 space(0)
with frame doc-line-frm .
down stream repstr 1 with frame doc-line-frm.                    end.
    END.
END CASE.
put stream repstr
  v-line
  skip(2)
  .
display stream repstr
sym1  space(0)
sym2  space(0)
sym3  space(0) "Итого"                                                              @ buf_trn-doc.doc-code
sym4  space(0) (ACCUM TOTAL buf_doc-line.doc-qnty)                                      @ buf_doc-line.doc-qnty
sym5  space(0) (ACCUM TOTAL buf_doc-line.cli-qnty)                                      @ buf_doc-line.cli-qnty
sym6  space(0) (ACCUM TOTAL vardeviationdoc-qnty)                                   @ vardeviationdoc-qnty
sym7  space(0) (ACCUM TOTAL vardeviationcli-qnty)                                   @ vardeviationcli-qnty
sym8  space(0) (ACCUM TOTAL vardeviationdoc-qnty) / (ACCUM TOTAL buf_doc-line.doc-qnty) @ vardeviationperc
sym9  space(0) (ACCUM TOTAL vardevfactdoc-qnty)                                     @ vardevfactdoc-qnty
sym10 space(0) (ACCUM TOTAL vardevfactcli-qnty)                                     @ vardevfactcli-qnty
sym11 space(0) (ACCUM TOTAL vardevfactdoc-qnty)   / (ACCUM TOTAL buf_doc-line.doc-qnty) @  vardevfactperc
sym12 space(0)
with frame doc-line-frm .
down stream repstr 1 with frame doc-line-frm.
put stream repstr unformatted
  "   Начальник АЗС ___________________________ "
  .
hide stream repstr frame bottomframe .
output stream repstr close.
run waitfram-hide in this-procedure.
run prn-lib-prn-file in this-procedure ( input parparentproc, input 7 ).
