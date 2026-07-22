DEFINE TEMP-TABLE tt-staff NO-UNDO LIKE staff.
DEFINE TEMP-TABLE tt-staff-attr NO-UNDO LIKE staff-attr.
DEFINE BUFFER X_clients FOR clients.
DEFINE BUFFER X_person FOR person.
DEFINE BUFFER X_staff FOR staff.
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
DEFINE input parameter p-role AS CHARACTER NO-UNDO .
DEFINE input parameter p-db-num   like ub.db.db-num NO-UNDO .
DEFINE input parameter p-psn-code like ub.person.psn-code NO-UNDO .
define output parameter rid-list    as  char no-undo .
define variable vss-revision    as character no-undo init "$Revision: a44284873617, 2302, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Fri Feb 14 16:31:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: staffs.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/staffs.w $":U .
define variable vss-description as character no-undo init "Справочник персонала".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
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
DEFINE NEW SHARED TEMP-TABLE cash-cash no-undo
FIELD stts like ub.clients.stts
FIELD psn-code like ub.person.psn-code
FIELD cash-code as integer
FIELD slr-code  as integer
FIELD superviser as integer
FIELD cash-name like ub.clients.obj-name
FIELD psswd as character
FIELD s-psswd as character
FIELD ident-type as integer
index icli IS PRIMARY psn-code
index icash cash-code stts
index islr  slr-code stts
.
define variable log-res as log no-undo.
define variable choice as log no-undo.
define variable cli-name as char no-undo.
define variable ri-str  as char no-undo.
define variable per-stts      like  ub.clients.stts     no-undo .
define variable glog as logical no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable v-date-end like ub.staff.date-end no-undo .
DEFINE VARIABLE v-role AS CHARACTER NO-UNDO.
define variable title0 as character no-undo .
DEFINE VARIABLE v-tab-order as character no-undo .
define variable v-doc-rec   as recid no-undo .
define variable v-role-name as character no-undo .
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE change-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE delete-option AS CHARACTER NO-UNDO.
define variable sort-column-name as character no-undo .
define variable filter-label0 as character no-undo init "Список персонала" .
define variable filter-label as character no-undo init "Список персонала" .
define variable filter-point0 as character no-undo init "staffs" .
define variable filter-point as character no-undo init "staffs" .
define variable log-file-name as character no-undo init "send-cd.txt".
define variable v-view-log as logical no-undo .
FUNCTION get-staff-name RETURNS CHARACTER ( input p-obj-name as character
                                          , input p-psn-code as integer
                                          , input p-stts as integer):
define variable v-full-name as character no-undo .
define buffer buf_person for ub.person.
find first buf_person no-lock where
          buf_person.psn-code = p-psn-code no-error.
v-full-name = substitute("&1 &2 &3"
                   , p-obj-name
                   , (if available buf_person then buf_person.name1 else '')
                   , (if available buf_person then buf_person.name2 else '')
                   ).
RETURN
(IF (p-stts = integer('0':U))
THEN v-full-name
ELSE (substring (v-full-name,1, 25) +
                FILL (chr(32), 25 - LENGTH (substring (v-full-name, 1, 25)) )) +
                '---  УДАЛЕН  ---':U).
END FUNCTION.
DEFINE MENU MENU-add
       MENU-ITEM m-add-new      LABEL "Новое физ-лицо"
       MENU-ITEM m-add-old      LABEL "Выбрать из справочника".
DEFINE MENU MENU-b-chg
       MENU-ITEM m_psn          LABEL "Физ.лицо"
       MENU-ITEM m_staff        LABEL "Данные персонала".
DEFINE MENU MENU-b-chg-2
       MENU-ITEM m_psn-2        LABEL "Физ.лицо"
       MENU-ITEM m_staff-2      LABEL "Данные персонала".
DEFINE MENU MENU-b-del
       MENU-ITEM m_client       LABEL "Физ.лицо"
       MENU-ITEM m_delstaff     LABEL "Данные персонала".
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-arch
     LABEL "&Архив"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 3 BY 1.
DEFINE BUTTON b-qrCode
     LABEL "&QR-код кассира"
     SIZE 15 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.
DEFINE VARIABLE f-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "№ БД"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE f-staff-code AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1 NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4.75 BY .75
     FGCOLOR 10  NO-UNDO.
DEFINE VARIABLE RS-status AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 0,
"Текущие", 1
     SIZE 28 BY 1 NO-UNDO.
DEFINE QUERY br-staff FOR
      X_staff,
      X_person,
      X_clients SCROLLING.
DEFINE BROWSE br-staff
  QUERY br-staff NO-LOCK DISPLAY
      (mark-string ( INPUT RECID( X_staff), INPUT rid-list)) COLUMN-LABEL '*' FORMAT "x(1)":U
X_staff.staff-code COLUMN-LABEL 'Код!перс.' FORMAT ">>>>9":U
get-staff-name ( X_clients.obj-name, X_clients.obj-code, X_clients.stts ) COLUMN-LABEL 'Имя' FORMAT "x(40)":U
X_person.firm-name COLUMN-LABEL 'Организация' FORMAT "x(20)":U
X_person.psn-code COLUMN-LABEL 'Код!физ.лица' FORMAT ">>>>>>>>9":U
X_staff.db-num COLUMN-LABEL 'БД!№' FORMAT ">>>>9":U
X_staff.date-start COLUMN-LABEL 'c' FORMAT "99/99/9999":U
(IF X_staff.date-end = 12/31/9999 THEN '':u ELSE string(X_staff.date-end, '99/99/9999')) COLUMN-LABEL 'по' FORMAT "X(10)":U
ENABLE X_staff.staff-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.
DEFINE FRAME d-sel
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 15
     b-add AT ROW 1 COL 25
     b-lkp AT ROW 1 COL 35
     b-chg AT ROW 1 COL 45
     b-del AT ROW 1 COL 55
     b-qrCode AT ROW 1 COL 65 WIDGET-ID 2
     b-print AT ROW 1 COL 86
     b-hist AT ROW 1 COL 89
     b-sch AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     RS-status AT ROW 2 COL 15.5 NO-LABEL
     b-arch AT ROW 2 COL 45
     f-db-num AT ROW 3 COL 24.5 COLON-ALIGNED
     f-staff-code AT ROW 3 COL 42 COLON-ALIGNED
     br-staff AT ROW 4 COL 1
     mark-num AT ROW 2.96 COL 3.5 COLON-ALIGNED NO-LABEL
     SPACE(88.75) SKIP(15.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "ПЕРСОНАЛ":L.
ASSIGN
       FRAME d-sel:SCROLLABLE       = FALSE
       FRAME d-sel:PRIVATE-DATA     =
                "DLGCLOSE".
ASSIGN
       b-add:POPUP-MENU IN FRAME d-sel       = MENU MENU-add:HANDLE.
ASSIGN
       b-arch:HIDDEN IN FRAME d-sel           = TRUE.
ASSIGN
       b-chg:POPUP-MENU IN FRAME d-sel       = MENU MENU-b-chg:HANDLE.
ASSIGN
       b-del:POPUP-MENU IN FRAME d-sel       = MENU MENU-b-del:HANDLE.
ASSIGN
       b-qrCode:POPUP-MENU IN FRAME d-sel       = MENU MENU-b-chg-2:HANDLE.
ON ENDKEY OF FRAME d-sel
DO:
END.
ON CHOOSE OF B-quit IN FRAME d-sel
DO:
  define variable recid_attr as character no-undo .
  for each tt-staff-attr :
    find first X_staff no-lock where X_staff.staff-code = tt-staff-attr.staff-code and
    X_staff.role = tt-staff-attr.role no-error .
    find first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U
        AND X_clients.obj-code = X_staff.psn-code no-error .
          create cash-cash.
          assign
          cash-cash.cash-code = X_staff.staff-code
          cash-cash.cash-name = X_clients.obj-name
          cash-cash.stts = (if X_staff.date-end < today then 1 else 0)
          cash-cash.psn-code = X_staff.psn-code
          cash-cash.psswd = X_staff.password
          .
          find first ub.staff-attr no-lock where ub.staff-attr.attr-code = "CashierQRCode"
          and ub.staff-attr.role = X_staff.role
          and ub.staff-attr.role-level = X_staff.role-level
          and ub.staff-attr.staff-code = X_staff.staff-code no-error .
          if available (ub.staff-attr) then
          recid_attr = recid_attr + chr(44) + string(recid(ub.staff-attr)) .
   end.
  if can-find(first cash-cash) then do:
      run str/diallog.w (
            input parparentproc
          , input this-procedure
          , input "str/send-all.p":U
          , input ( v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + 'U':U + chr(4) + 'qrCode' + chr(4) + 'Отсылка QR-code на кассы':U + chr(4) + string(recid_attr))
          , input ?
          , input "":U
          , input substitute("Отсылка QR-code на кассы &1", 'IBM-XML':U)
        ) no-error.
  end.
END.
ON CHOOSE OF b-add IN FRAME d-sel
DO:
DEFINE VARIABLE v-option AS CHARACTER NO-UNDO.
IF add-option = '':U THEN DO:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
END.
if add-option = '':U then return no-apply.
v-option = add-option.
add-option = '':U.
run proc-b-add in this-procedure ( input v-option) no-error.
if error-status:error then do:
   return no-apply.
end.
END.
ON CHOOSE OF b-arch IN FRAME d-sel
DO:
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE v-cashier-db-num like ub.clients.db-num no-undo .
define variable v-cashier-code as integer no-undo .
define buffer shop_cli for ub.clients .
  if available X_person then do:
    run calc-arch in this-procedure .
    if return-value <> "0" then do:
        run cur-time in this-procedure ( output v-today, output v-time) .
        assign
        v-cashier-code = X_staff.staff-code
        .
        run ref/cshrsarc.w (
                        input parparentproc
                       ,input X_staff.staff-code
                       ,input  X_person.psn-code ) .
        if month(v-today) > 1 then do:
          FOR EACH ub.cshr-month WHERE
                (ub.cshr-month.cashier-psn-code = X_person.psn-code
                or ub.cshr-month.cashier-psn-code = 0)
                AND
                ub.cshr-month.cshr-code = v-cashier-code AND
                ub.cshr-month.year_ = year( v-today ) AND
                (ub.cshr-month.month_ = month( v-today ) or ub.cshr-month.month_ = month(v-today) - 1):
            if ub.cshr-month.obj-code <> 0 then do:
              find first shop_cli no-lock where
                         shop_cli.obj-type = cshr-month.obj-type .
              assign
              v-cashier-db-num = shop_cli.db-num
              .
            end.
            else v-cashier-db-num = ?.
            if v-cashier-db-num = ? or v-cashier-db-num = v-cntxt-db-num then
            delete cshr-month .
          END.
       end.
       else do:
          FOR EACH cshr-month WHERE
                (cshr-month.cashier-psn-code = X_person.psn-code
                or cshr-month.cashier-psn-code = 0)
                AND
                cshr-month.cshr-code = v-cashier-code AND
                (cshr-month.year_ = year( v-today ) AND
                cshr-month.month_ = month( v-today )) or
                (cshr-month.year_ = year( v-today ) - 1 AND
                cshr-month.month_ = 12 ):
            if cshr-month.obj-code <> 0 then do:
              find first shop_cli no-lock where
                         shop_cli.obj-type = cshr-month.obj-type .
              assign
              v-cashier-db-num = shop_cli.db-num
              .
            end.
            else v-cashier-db-num = ?.
            if v-cashier-db-num = ? or v-cashier-db-num = v-cntxt-db-num then
            delete cshr-month .
          END.
       end.
    end.
  end.
  apply "entry" to br-staff .
END.
ON CHOOSE OF b-chg IN FRAME d-sel
DO:
DEFINE VARIABLE v-option AS CHARACTER NO-UNDO.
IF change-option = '':U THEN DO:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
END.
if change-option = '':U then return no-apply.
v-option = change-option.
change-option = '':U.
run proc-b-chg in this-procedure (input v-option) no-error.
if error-status:error then do:
  return no-apply.
end.
END.
ON CHOOSE OF b-del IN FRAME d-sel
DO:
DEFINE VARIABLE v-option AS CHARACTER NO-UNDO.
IF delete-option = '':U THEN DO:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
END.
if delete-option = '':U then return no-apply.
v-option = delete-option.
delete-option = '':U.
run proc-b-del in this-procedure ( input v-option) no-error.
if error-status:error then do:
  v-option ='':U.
  return no-apply.
end.
END.
ON CHOOSE OF b-hist IN FRAME d-sel
DO:
define variable v-rid-list as character no-undo .
    if available X_staff THEN
    run ref/cstaffs.w (
                      input parparentproc
                    , input v-cntxt-obj-type
                    , input v-cntxt-obj-code
                    , input "":U
                    , "one":U
                    , input X_staff.role
                    , input X_staff.role-level
                    , input X_staff.work-place
                    , input X_staff.staff-code
                    , input X_staff.date-start
                    , input-output v-rid-list  ) no-error .
    apply "entry" to br-staff .
END.
ON CHOOSE OF b-lkp IN FRAME d-sel
DO:
define variable ri as recid no-undo .
  if available X_staff then do:
    run ref/showcli.p (
      input parParentProc
      ,input X_clients.obj-type
      ,input X_clients.obj-code
      ).
  end.
  apply "entry" to br-staff .
END.
ON CHOOSE OF b-mark IN FRAME d-sel
DO:
define variable glog as logical no-undo .
if available X_staff then  do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid15 as character no-undo .
define variable v-num-entry15 as integer   no-undo .
assign
  v-str-recid15 = trim( string( recid( X_staff ) , "->>>>>>>>>>>9":U ) )
  v-num-entry15 = lookup( v-str-recid15 , rid-list )
.
if v-num-entry15 > 0 then do:
  assign
    entry( v-num-entry15, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid15
  .
end.
glog = br-staff:refresh() .
if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
  glog = br-staff:select-next-row ().
  apply "iteration-changed" to br-staff in frame d-sel.
end.
if num-entries( rid-list ) = 0 then
    hide mark-num in frame d-sel.
else
    disp num-entries( rid-list ) @ mark-num with frame d-sel.
end.
apply "entry" to br-staff in frame d-sel.
END.
ON CHOOSE OF b-print IN FRAME d-sel
DO:
define variable Line                    as char         no-undo.
define variable cli-attr                 as char         no-undo.
define variable ii                  as integer   no-undo.
define variable ri as recid no-undo .
DEFINE VARIABLE v-work-place AS CHARACTER no-undo.
define variable v-role-level as character no-undo .
define variable v-obj-type as character no-undo .
DEFINE VARIABLE v-date-end-chr AS CHARACTER NO-UNDO.
DEFINE FRAME List
X_staff.staff-code column-label "Код" format ">>>>9"
X_person.name1 column-label "Имя " format "X(60)"
X_person.firm-name column-label "Организация" format "x(30)"
X_staff.psn-code column-label "Код физ.лица" format ">>>>>>>>9"
v-work-place COLUMN-LABEL "Работает" FORMAT "X(15)"
X_staff.date-start COLUMN-LABEL "c" FORMAT "99/99/9999"
v-date-end-chr COLUMN-LABEL "по" FORMAT "X(10)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 85 format "X(15)" SKIP
Line format "x(105)" AT 1
with width 160 down use-text stream-io no-box .
if num-results( "br-staff" ) = 0 then do:
    message "Список  П У С Т !" skip view-as alert-box information .
    return no-apply .
end.
if session:set-wait-state( "compiler" ) then .
Line = fill( "-" , 150 ) .
ri = recid(X_staff).
DO WHILE available X_staff :
  GET prev br-staff NO-LOCK .
END.
GET next br-staff NO-LOCK .
ii = 1 .
run prn-lib-open-stream  in this-procedure (
                                          input parParentProc
                                          ,input 62
                                          ,input yes
                                          ,input no
                                          ).
FORM HEADER
Line format "X(105)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME CliBottomFrame width 160 PAGE-BOTTOM NO-LABELS no-box.
VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream unformatted space(20) frame d-sel:title skip.
FORM with frame List .
DO WHILE available X_staff :
  assign
  v-role-level =  X_staff.role-level
  no-error .
  if p-psn-code = 0 then do:
    CASE X_staff.role-level:
      when 'db':U then do:
        v-work-place = substitute("БД &1", X_staff.db-num).
      end.
      when 'firm':U then do:
        v-work-place = substitute("Фирма &1", X_staff.host-code).
      end.
      when 'object':U then do:
        v-work-place =  X_staff.work-place.
      end.
      otherwise do:
        v-work-place = ''.
      end.
    END CASE.
  end.
  else do:
    v-work-place = gbclcode-get-position ( input X_staff.role
                                          ,input X_staff.role-level
                                          ,input X_staff.work-place
                                          ,input X_staff.staff-code ).
  end.
  DISPLAY stream PrnLibStream
  X_staff.staff-code
  get-staff-name ( X_clients.obj-name, X_clients.obj-code, X_clients.stts ) @ X_person.name1
  X_person.firm-name
  X_staff.psn-code
  v-work-place
  X_staff.date-start
  IF X_staff.date-end = 12/31/9999 THEN "":U ELSE string(X_staff.date-end, "99/99/9999") @ v-date-end-chr
  with frame List .
  DOWN stream PrnLibStream 1 with frame List .
  ii =  ii + 1 .
  if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
    run waitfram-show in this-procedure ( input "Просмотрено строк : " + string( ii ) ) .
  GET next br-staff NO-LOCK .
END.
PUT stream PrnLibStream Line format "X(105)" SKIP.
HIDE stream PrnLibStream FRAME CliBottomFrame .
output stream PrnLibStream close .
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                        input parParentProc
                                        ,input 0
                                        ).
reposition br-staff to recid ri no-error.
END.
ON CHOOSE OF b-qrCode IN FRAME d-sel
DO:
  define variable v-update as logical no-undo .
  define variable attr-value as character no-undo .
  if available (X_staff) then do:
    buffer-copy X_staff to tt-staff .
    find first ub.staff-attr no-lock where ub.staff-attr.attr-code = "CashierQRCode" and
    ub.staff-attr.date-start <= today and
    ub.staff-attr.role = X_staff.role and
    ub.staff-attr.staff-code = X_staff.staff-code no-error .
    attr-value = if available (ub.staff-attr) then ub.staff-attr.attr-value else "" .
    run ref\view-qrCode.w(parparentproc, input-output attr-value, input table tt-staff, output v-update).
  if v-update then do:
    find first tt-staff-attr no-lock where tt-staff-attr.attr-code = "CashierQRCode" and
    tt-staff-attr.date-start = today and
    tt-staff-attr.role = X_staff.role and
    tt-staff-attr.staff-code = X_staff.staff-code no-error .
    if not available (tt-staff-attr) then do:
      create tt-staff-attr .
      assign
      tt-staff-attr.attr-code = "CashierQRCode"
      tt-staff-attr.date-start = today
      tt-staff-attr.role = X_staff.role
      tt-staff-attr.role-level = X_staff.role-level
      tt-staff-attr.staff-code = X_staff.staff-code
      .
    end.
    tt-staff-attr.attr-value = attr-value .
  end.
  end.
  else do:
    message "Не выбран кассир."
    view-as alert-box.
  end.
END.
ON CHOOSE OF b-sch IN FRAME d-sel
DO:
    run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-sel IN FRAME d-sel
DO:
    if ( available X_staff ) AND ( rid-list = "" ) then
        rid-list = string( recid( X_staff ) ) .
END.
ON MOUSE-SELECT-DBLCLICK OF br-staff IN FRAME d-sel
OR INSERT-MODE  OF br-staff IN FRAME d-sel DO:
    if can-do(bttns, "b-mark") then
    apply "choose" to b-mark in frame d-sel .
    else if can-do( bttns, "b-sel" ) then
        apply "choose" to b-sel in frame d-sel .
    else
        apply "choose" to b-lkp in frame d-sel .
END.
ON RETURN OF br-staff IN FRAME d-sel
DO:
    if can-do( bttns, "b-sel" ) then
        apply "choose" to b-sel in frame d-sel .
    else
        apply "choose" to b-lkp in frame d-sel .
END.
ON RETURN OF f-db-num IN FRAME d-sel
DO:
  DEFINE VARIABLE v-int AS INTEGER NO-UNDO.
  DEFINE BUFFER buf_db FOR ub.db.
  ASSIGN
  f-db-num
  v-int = f-db-num
  .
  IF v-int <> ? THEN DO:
      FIND FIRST buf_db NO-LOCK WHERE
                buf_db.db-num = v-int NO-ERROR.
      IF NOT AVAILABLE buf_db THEN DO:
          MESSAGE
          substitute("Нет БД № &1", f-db-num)
          VIEW-AS ALERT-BOX ERROR.
          RETURN NO-APPLY.
      END.
  END.
  assign
  v-db-num = f-db-num.
  run OpenBr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
END.
ON RETURN OF f-staff-code IN FRAME d-sel
DO:
  run proc-find_staff-code in THIS-PROCEDURE ( INPUT no, input frame d-sel f-staff-code) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-add-new
DO:
DEFINE VARIABLE v-option AS CHARACTER NO-UNDO.
  ASSIGN
  add-option = "new":U.
  run proc-b-add IN THIS-PROCEDURE ( INPUT add-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      ASSIGN
      add-option = '':U.
      RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF MENU-ITEM m-add-old
DO:
DEFINE VARIABLE v-option AS CHARACTER NO-UNDO.
ASSIGN
 add-option = "old":U.
 run proc-b-add IN THIS-PROCEDURE ( INPUT add-option) NO-ERROR.
 IF ERROR-STATUS:ERROR THEN DO:
     ASSIGN
     add-option = '':U.
     RETURN NO-APPLY.
 END.
END.
ON CHOOSE OF MENU-ITEM m_client
DO:
  ASSIGN
  delete-option = 'чел':U.
  APPLY "CHOOSE" TO b-del IN FRAME d-sel.
END.
ON CHOOSE OF MENU-ITEM m_delstaff
DO:
 ASSIGN
 delete-option = 'staff'.
 APPLY "CHOOSE" TO b-del IN FRAME d-sel.
END.
ON CHOOSE OF MENU-ITEM m_psn
DO:
  ASSIGN
  change-option = 'чел':U.
  APPLY "CHOOSE" TO b-chg IN FRAME d-sel.
END.
ON CHOOSE OF MENU-ITEM m_psn-2
DO:
  ASSIGN
  change-option = 'чел':U.
  APPLY "CHOOSE" TO b-chg IN FRAME d-sel.
END.
ON CHOOSE OF MENU-ITEM m_staff
DO:
  ASSIGN
  change-option = 'staff'.
  APPLY "CHOOSE" TO b-chg  IN FRAME d-sel.
END.
ON CHOOSE OF MENU-ITEM m_staff-2
DO:
  ASSIGN
  change-option = 'staff'.
  APPLY "CHOOSE" TO b-chg  IN FRAME d-sel.
END.
ON VALUE-CHANGED OF RS-status IN FRAME d-sel
DO:
  ASSIGN
  rs-status
  .
  assign
  v-date-end = (IF rs-status = 0 THEN ? ELSE 12/31/9999) .
  run OpenBr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-sel:PARENT eq ?
THEN FRAME d-sel:PARENT = ACTIVE-WINDOW.
def var sort-labelbr-staff   as character no-undo .
def var sort-clmnbr-staff    as handle    no-undo .
def var cur-clmnbr-staff     as handle    no-undo .
def var cur-clmn-locbr-staff as integer   no-undo .
def var re-querybr-staff     as logical   initial no no-undo .
on start-search, ctrl-o of br-staff in frame d-sel do:
   run sort-brbr-staff
     (input (if available X_staff
             then recid(X_staff)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-staff :
  define input parameter p-recid as recid no-undo .
  if re-querybr-staff = no then do:
    assign
       cur-clmnbr-staff = br-staff:current-column in frame d-sel
    .
    if sort-clmnbr-staff <> ? then sort-clmnbr-staff:column-fgcolor = 0.
    if cur-clmnbr-staff = sort-clmnbr-staff then do:
      assign
         sort-labelbr-staff = ""
         sort-clmnbr-staff = ?
      .
     end.
     else do:
       assign
         sort-labelbr-staff = cur-clmnbr-staff:label
         sort-clmnbr-staff  = cur-clmnbr-staff
         sort-clmnbr-staff:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-staff = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-staff:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-staff then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-staff = cur-clmn-locbr-staff + 1
    .
  end.
  case sort-labelbr-staff:
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, RECID( X_staff), &1&2&1)', chr(34),rid-list)     .     run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).   . END.
        when 'Код!перс.'  then DO:    assign       sort-column-name = "X_staff.staff-code"     .     run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).   . END.
        when 'Имя'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-staff-name&1, X_clients.obj-name, X_clients.obj-code, X_clients.stts)', chr(34))     .     run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).   . END.
        when 'Организация'  then DO:    assign       sort-column-name = "X_person.firm-name"     .     run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).   . END.
        when 'Код!физ.лица'  then DO:    assign       sort-column-name = "X_person.psn-code"     .     run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).   . END.
        when 'БД!№'  then DO:    assign       sort-column-name = "X_staff.db-num"     .     run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).   . END.
        when 'c'  then DO:    assign       sort-column-name = "X_staff.date-start"     .     run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).   . END.
        when 'по'  then DO:   assign       sort-column-name = substitute('string(X_staff.date-end)')     .     run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).
      if sort-labelbr-staff <> "" then do:
        assign
          cur-clmnbr-staff:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-staff = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-staff to recid p-recid no-error.
    apply "value-changed" to br-staff in frame d-sel.
  end.
  apply "entry" to br-staff in frame d-sel.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-staff:
if cur-clmnbr-staff = ? then do:
   run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).
end.
else do:
   assign re-querybr-staff = yes.
   run sort-brbr-staff
     (input (if available X_staff
             then recid(X_staff)
             else ?
            )
     ).
   assign re-querybr-staff = no.
end.
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame d-sel:
    if p-filter-name > "" then do:
      assign
        frame d-sel:title
          = frame d-sel:title + "   ФИЛЬТР: " + p-filter-name.
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-sel
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
on choose of b-help in frame d-sel
do:
  apply "help":u to frame d-sel .
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
                v-frame-width = frame d-sel:width - 0.3
                fh            = frame d-sel:first-child
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
    if frame d-sel :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-sel :height-chars)
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
    if frame d-sel :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-sel :height-chars)
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
            frame d-sel :height = v-frame-height
          .
          if frame d-sel :scrollable = true
          then do:
            assign
              frame d-sel :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-sel :scrollable = true
          then do:
            assign
              frame d-sel :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-sel :height = v-frame-height
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
      v-frame-height = frame d-sel :height
      v-frame-virtual-height = frame d-sel :virtual-height
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
      v-field-group-handle = frame d-sel :first-child
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
    do with frame d-sel
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-sel :scrollable = true
      then do:
        assign
          frame d-sel :virtual-height = frame d-sel :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-sel :height = frame d-sel :height + p-change-value
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
        frame d-sel :height = frame d-sel :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-sel :scrollable = true
      then do:
        assign
          frame d-sel :virtual-height = frame d-sel :virtual-height + p-change-value
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
          ,input  string(frame d-sel :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-sel :height)
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
    if frame d-sel :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-sel :width
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
    if frame d-sel :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-sel :width
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
            frame d-sel :width = v-frame-width
          .
          if frame d-sel :scrollable = true
          then do:
            assign
              frame d-sel :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-sel :scrollable = true
          then do:
            assign
              frame d-sel :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-sel :width = v-frame-width
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
      v-frame-width = frame d-sel :width
      v-frame-virtual-width = frame d-sel :virtual-width
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
      v-field-group-handle = frame d-sel :first-child
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
    do with frame d-sel
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-sel :scrollable = true
      then do:
        assign
          frame d-sel :virtual-width = frame d-sel :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-sel :width = v-frame-width + p-change-value
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
        frame d-sel :width = frame d-sel :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-sel :scrollable = true
      then do:
        assign
          frame d-sel :virtual-width = frame d-sel :virtual-width + p-change-value
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
          ,input  string(frame d-sel :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-sel :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-sel
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-sel :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-sel :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-sel :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-sel :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-sel
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
      v-row-delta = v-new-row - frame d-sel :height
      v-col-delta = v-new-col - frame d-sel :width
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
            - frame d-sel :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-sel :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-sel :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-sel :height-chars
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
      v-diasize-current-frame-width  = frame d-sel :width
      v-diasize-current-frame-height = frame d-sel :height
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
    do with frame d-sel
    :
      assign
        v-diasize-orig-frame-height = frame d-sel :height
        v-diasize-orig-frame-width  = frame d-sel :width
        v-diasize-browse-handle     = browse br-staff :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-sel :first-child
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
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-sel anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-sel. END.
  return no-apply.
end.
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-sel anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-sel. END.
  return no-apply.
end.
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-sel anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-sel. END.
  return no-apply.
end.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-sel anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-sel. END.
  return no-apply.
end.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-sel anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-sel. END.
  return no-apply.
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame d-sel anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame d-sel. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame d-sel anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame d-sel. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame d-sel anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame d-sel. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-staff :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame d-sel:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame d-sel:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame d-sel:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame d-sel:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame d-sel anywhere
do:
  v-doc-rec = ?. if available X_staff then assign v-doc-rec = recid(X_staff) no-error. Run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U). reposition br-staff to recid v-doc-rec no-error.               APPLY 'entry' to br-staff. APPLY 'VALUE-CHANGED' to br-staff. v-doc-rec = ?.
    apply "VALUE-CHANGED" to br-staff.
end.
ON WINDOW-CLOSE OF FRAME d-sel APPLY "END-ERROR":U TO SELF.
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
    if v-cntxt-db-num <> 0
    or (v-cntxt-db-num = 0  and p-db-num = 0)
    then do:
      assign
      p-db-num = v-cntxt-db-num
      v-db-num = p-db-num
      .
    end.
    run enable_UI  in this-procedure .
    HIDE mark-num in frame d-sel .
    WAIT-FOR GO OF FRAME d-sel.
END.
run disable_UI in this-procedure .
PROCEDURE calc-arch :
define variable StartMonth  like ub.cshr-month.month_ no-undo .
define variable StartYear   like ub.cshr-month.year_       no-undo .
define variable StartMonth-psn  like ub.cshr-month.month_ no-undo .
define variable StartYear-psn   like ub.cshr-month.year_       no-undo .
define variable StartDate   as date no-undo .
define variable StartDate-psn   as date no-undo .
define variable ChkMonth as integer no-undo.
define variable ChkYear as integer no-undo.
define variable DateBuf-Start as date no-undo .
define variable DateBuf-End as date no-undo .
define variable EndDay_ as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE v-v12-3 as date no-undo .
define variable v-out-totchk  as integer no-undo .
define variable v-out-totsum  as decimal no-undo .
define variable v-out-count   as integer no-undo .
define variable v-out-qnty    as decimal no-undo .
define variable v-out-sum     as decimal no-undo .
define variable v-ret-totchk  as integer no-undo .
define variable v-ret-totsum  as decimal no-undo .
define variable v-ret-count   as integer no-undo .
define variable v-ret-qnty    as decimal no-undo .
define variable v-ret-sum     as decimal no-undo .
define buffer shop_cli for ub.clients.
find first ub.upgrade no-lock where
           ub.upgrade.db-num = v-db-num
      and  ub.upgrade.version-num = "12.3":U no-error .
assign
StartDate = ?
StartDate-psn = ?
v-db-num = v-cntxt-db-num
v-v12-3 = if available ub.upgrade then ub.upgrade.upgdate else ?
.
FIND FIRST ub.cshr-month WHERE
            ub.cshr-month.cshr-code = X_staff.staff-code
        AND ub.cshr-month.cashier-psn-code = 0
NO-LOCK NO-ERROR .
if available ub.cshr-month then do:
  if ub.cshr-month.month_ < 12 then do:
    assign
        StartMonth = ub.cshr-month.month_ + 1
        StartYear = ub.cshr-month.year_ .
  end.
  else do:
    assign
        StartMonth = 1
        StartYear = ub.cshr-month.year_ + 1 .
  end.
  StartDate = date( StartMonth, 1, StartYear ) .
end.
for each  cshr-month NO-LOCK WHERE
            cshr-month.cshr-code = X_staff.staff-code
        AND cshr-month.cashier-psn-code = X_person.psn-code:
  if StartDate-psn = ? or
    Startdate-psn > date(cshr-month.month_, 1, cshr-month.year_) then do:
    if cshr-month.month_ < 12 then do:
      assign
          StartMonth-PSN = cshr-month.month_ + 1
          StartYear-PSN = cshr-month.year_ .
    end.
    else do:
      assign
          StartMonth-PSN = 1
          StartYear-PSN = cshr-month.year_ + 1 .
    end.
    StartDate-PSN = date( StartMonth-PSN, 1, StartYear-pSN ) .
  end.
END.
if startdate = ? or startdate-psn = ? then do:
  FOR EACH ub.shop NO-LOCK :
    FIND LAST ub.chk-doc NO-LOCK WHERE
            ub.chk-doc.obj-type = 'маг':U AND
            ub.chk-doc.obj-code = shop.obj-code AND
            ub.chk-doc.cashier = X_staff.staff-code
            use-index cash-desk no-error.
    if available ub.chk-doc then do:
      if ub.chk-doc.cashier-psn-code = ? then do:
        if StartDate = ? then do:
          assign
          StartDate = date( month( chk-doc.chk-date ), 1, year( chk-doc.chk-date ) ) .
        end.
        else do:
          if StartDate > chk-doc.chk-date then do:
            assign
            StartDate = date( month( chk-doc.chk-date ), 1, year( chk-doc.chk-date ) )
            .
          end.
        end.
      end.
      if chk-doc.cashier-psn-code <> ? and chk-doc.cashier-psn-code = X_person.psn-code then do:
        if StartDate-psn = ? then do:
          assign
          StartDate-psn = date( month( chk-doc.chk-date ), 1, year( chk-doc.chk-date ) ) .
        end.
        else do:
          if StartDate-psn > chk-doc.chk-date then do:
            assign
            StartDate-psn = date( month( chk-doc.chk-date ), 1, year( chk-doc.chk-date ) )
            .
          end.
        end.
      end.
    END.
  END .
  if startdate <> ? and startdate-psn = ? then do:
    if v-v12-3 = ? then v-v12-3 = Startdate.
    FOR EACH shop_cli NO-LOCK where
            shop_cli.obj-type = 'маг':U
        AND  shop_cli.db-num = v-cntxt-db-num,
        EACH chk-doc NO-LOCK WHERE
              chk-doc.obj-type = 'маг':U AND
              chk-doc.obj-code = shop_cli.obj-code AND
              chk-doc.cashier = X_staff.staff-code AND
              chk-doc.chk-date > v-v12-3
    by chk-doc.chk-date descending
    by chk-doc.chk-time descending:
      if chk-doc.cashier-psn-code <> ? and chk-doc.cashier-psn-code <> X_person.psn-code then NEXT.
      if StartDate-psn = ? then do:
        assign
        StartDate-psn = date( month( chk-doc.chk-date ), 1, year( chk-doc.chk-date ) ) .
      end.
      else do:
        if StartDate-psn > chk-doc.chk-date then do:
          assign
          StartDate-psn = date( month( chk-doc.chk-date ), 1, year( chk-doc.chk-date ) )
          .
        end.
      end.
    END .
  end.
end.
if StartDate = ? and startdate-psn = ? then do:
  message
  "Архивы по данному кассиру пусты."
  view-as alert-box INFORMATION .
  return "0" .
end.
run waitfram-show in this-procedure ( input "Подождите ..." ) .
run cur-time in this-procedure ( output v-today, output v-time).
assign
v-v12-3 = (if StartDate-psn <> ? then startdate-psn else v-today)
.
DO TRANSACTION
ON STOP undo, return no-apply
ON ERROR undo, return no-apply
ON END-KEY undo, return no-apply :
  if StartDate = ? then.
  else do:
    assign
    DateBuf-Start = StartDate
    StartMonth = month( StartDate )
    StartYear = year( StartDate )
    .
    DO WHILE DateBuf-Start < v-v12-3  :
      run gbl/lastday.p ( input DateBuf-Start, output EndDay_ ) .
      assign
      DateBuf-End = date( StartMonth, EndDay_ , StartYear )
      DateBuf-end = min(dateBuf-end, v-v12-3)
      .
  shop-cycle:
      FOR EACH shop NO-LOCK:
        FIND FIRST chk-doc WHERE
                  chk-doc.obj-type = 'маг':U AND
                  chk-doc.obj-code = shop.obj-code AND
                  chk-doc.cashier = X_staff.staff-code AND
                  chk-doc.chk-date >= DateBuf-Start AND
                  chk-doc.chk-date <= DateBuf-End AND
                  chk-doc.out-code <> ? NO-LOCK NO-ERROR .
        if available chk-doc AND
            ( NOT can-find( cshr-month WHERE
                            cshr-month.cshr-code = X_staff.staff-code AND
                            cshr-month.cashier-psn-code = 0 AND
                            cshr-month.obj-type = "":U and
                            cshr-month.obj-code = 0 AND
                            cshr-month.year_ = StartYear AND
                            cshr-month.month_ = StartMonth ) ) then do:
          CREATE cshr-month .
          assign
          cshr-month.cshr-code = X_staff.staff-code
          cshr-month.year_ = year( chk-doc.chk-date )
          cshr-month.month_ = month( chk-doc.chk-date )
          cshr-month.cashier-psn-code = 0
          cshr-month.obj-type = "":U
          cshr-month.obj-code = 0
          .
          LEAVE shop-cycle.
        end.
      END.
      if month( DateBuf-Start ) < 12 then do:
        assign
        StartMonth = month( DateBuf-Start ) + 1
        StartYear = year( DateBuf-Start )
        .
      end.
      else do:
        assign
        StartMonth = 1
        StartYear = year( DateBuf-Start ) + 1
        .
      end.
      DateBuf-Start = date( StartMonth, 1, StartYear ) .
    END .
    assign
    StartMonth = month( StartDate )
    StartYear = year( StartDate )
    .
    FOR EACH cshr-month WHERE
            cshr-month.cshr-code = X_staff.staff-code AND
            cshr-month.cashier-psn-code = 0 AND
            cshr-month.obj-type = "":U and
            cshr-month.obj-code = 0 and
            ( ( cshr-month.year_ = StartYear ) AND
              ( cshr-month.month_ >= StartMonth )
            OR ( cshr-month.year_ > StartYear ) ) :
      assign
      DateBuf-Start = date( cshr-month.month_ , 1, cshr-month.year_ )
      .
      run gbl/lastday.p ( input DateBuf-Start, output EndDay_ ) .
      assign
      DateBuf-End = date( cshr-month.month_ , EndDay_ , cshr-month.year_ ) .
      assign
      v-out-totchk  = 0
      v-out-totsum  = 0
      v-out-count   = 0
      v-out-qnty    = 0
      v-out-sum     = 0
      v-ret-totchk  = 0
      v-ret-totsum  = 0
      v-ret-count   = 0
      v-ret-qnty    = 0
      v-ret-sum     = 0
      .
      FOR EACH shop NO-LOCK,
          EACH chk-doc WHERE
            chk-doc.obj-type = 'маг':U AND
            chk-doc.obj-code = shop.obj-code AND
            chk-doc.cashier = X_staff.staff-code AND
            chk-doc.chk-date >= DateBuf-Start AND
            chk-doc.chk-date <= DateBuf-End AND
            chk-doc.out-code <> ?  NO-LOCK :
          if chk-doc.cashier-psn-code <> ? then NEXT.
          if lookup(string(chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next .
          if chk-doc.netto >= 0 then do:
            assign
            v-out-totchk = v-out-totchk + 1
            v-out-totsum = v-out-totsum + chk-doc.netto
            .
            if v-out-totchk modulo 20 = 0
            AND v-out-totchk >= 20 then
            run waitfram-show in this-procedure ( input substitute("Обработано чеков : &1",  v-out-totchk) ) .
          end.
          else do:
            assign
            v-ret-totchk = v-ret-totchk + 1
            v-ret-totsum = v-ret-totsum + chk-doc.netto
            .
          end.
          if ( ( chk-doc.netto < 0 ) AND
              can-find( first ub.chk-gds where
                              ub.chk-gds.doc-code = chk-doc.doc-code AND
                              ub.chk-gds.doc-qnty > 0 ) ) OR
                  ( ( ub.chk-doc.netto > 0 ) AND
                      can-find( first ub.chk-gds where
                                      ub.chk-gds.doc-code = chk-doc.doc-code AND
                                      ub.chk-gds.doc-qnty < 0 ) ) then do:
            if ub.chk-doc.netto < 0 then  do:
              FOR EACH ub.chk-gds WHERE
                      ub.chk-gds.doc-code = chk-doc.doc-code AND
                      ub.chk-gds.doc-qnty > 0 NO-LOCK :
                assign
                v-ret-count = v-ret-count + 1
                v-ret-qnty = v-ret-qnty + abs(chk-gds.doc-qnty)
                v-ret-sum = v-ret-sum + abs(  chk-gds.price-base - chk-gds.discnt ) * chk-gds.doc-qnty
                .
              END .
            end.
            else do:
              FOR EACH chk-gds WHERE
                        chk-gds.doc-code = chk-doc.doc-code AND
                        chk-gds.doc-qnty < 0 NO-LOCK :
                assign
                v-out-count = v-out-count + 1
                v-out-qnty = v-out-qnty + chk-gds.doc-qnty
                v-out-sum = v-out-sum + ( chk-gds.price-base - chk-gds.discnt ) * chk-gds.doc-qnty
                .
              END .
            end.
          end.
      END .
      assign
      cshr-month.out-totchk = v-out-totchk
      cshr-month.out-totsum = v-out-totsum
      cshr-month.out-count  = v-out-count
      cshr-month.out-qnty   = v-out-qnty
      cshr-month.out-sum    = v-out-sum
      cshr-month.ret-totchk = v-ret-totchk
      cshr-month.ret-totsum = v-ret-totsum
      cshr-month.ret-count  = v-ret-count
      cshr-month.ret-qnty   = v-ret-qnty
      cshr-month.ret-sum    = v-ret-sum
      .
    END.
  end.
  if StartDate-Psn = ? then .
  else do:
    assign
    DateBuf-Start = StartDate-PSN
    StartMonth-PSN = month( StartDate-PSN )
    StartYear-PSN = year( StartDate-PSN )
    .
    DO WHILE DateBuf-Start < v-today  :
      run gbl/lastday.p ( input DateBuf-Start, output EndDay_ ) .
      assign
      DateBuf-End = date( StartMonth-PSN, EndDay_ , StartYear-PSN )
      .
  shop-cycle:
      FOR EACH shop_cli NO-LOCK WHERE
               shop_cli.obj-type = 'маг':U
           AND shop_cli.db-num = v-cntxt-db-num:
        _chk-doc:
        FOR EACH chk-doc NO-LOCK WHERE
                  chk-doc.obj-type = 'маг':U AND
                  chk-doc.obj-code = shop_cli.obj-code AND
                  chk-doc.cashier = X_staff.staff-code AND
                  chk-doc.chk-date >= DateBuf-Start AND
                  chk-doc.chk-date <= DateBuf-End AND
                  chk-doc.out-code <> ?:
          if lookup(string(chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
          if chk-doc.cashier-psn-code <> X_person.psn-code then NEXT _chk-doc.
          if ( NOT can-find( cshr-month WHERE
                            cshr-month.cshr-code = X_staff.staff-code AND
                            cshr-month.cashier-psn-code = X_person.psn-code AND
                            cshr-month.obj-type = 'маг':U and
                            cshr-month.obj-code = shop_cli.obj-code AND
                            cshr-month.year_ = StartYear-PSN AND
                            cshr-month.month_ = StartMonth-PSN ) ) then do:
            CREATE cshr-month .
            assign
            cshr-month.cshr-code = X_staff.staff-code
            cshr-month.year_ = year( chk-doc.chk-date )
            cshr-month.month_ = month( chk-doc.chk-date )
            cshr-month.cashier-psn-code = X_person.psn-code
            cshr-month.obj-type = 'маг':U
            cshr-month.obj-code = shop_cli.obj-code
            .
            NEXT shop-cycle.
          END.
        end.
      END.
      if month( DateBuf-Start ) < 12 then do:
        assign
        StartMonth-PSN = month( DateBuf-Start ) + 1
        StartYear-PSN = year( DateBuf-Start )
        .
      end.
      else do:
        assign
        StartMonth-PSN = 1
        StartYear-PSN = year( DateBuf-Start ) + 1
        .
      end.
      DateBuf-Start = date( StartMonth-PSN, 1, StartYear-PSN ) .
    END .
    assign
    StartMonth-PSN = month( StartDate-PSN )
    StartYear-PSN = year( StartDate-PSN )
    .
    FOR EACH cshr-month WHERE
            cshr-month.cshr-code = X_staff.staff-code AND
            cshr-month.cashier-psn-code = X_person.psn-code AND
            ( ( cshr-month.year_ = StartYear-pSN ) AND
              ( cshr-month.month_ >= StartMonth-PSN )
            OR ( cshr-month.year_ > StartYear-PSN ) ) :
      assign
      DateBuf-Start = date( cshr-month.month_ , 1, cshr-month.year_ )
      .
      run gbl/lastday.p ( input DateBuf-Start, output EndDay_ ) .
      assign
      DateBuf-End = date( cshr-month.month_ , EndDay_ , cshr-month.year_ ) .
      assign
      v-out-totchk  = 0
      v-out-totsum  = 0
      v-out-count   = 0
      v-out-qnty    = 0
      v-out-sum     = 0
      v-ret-totchk  = 0
      v-ret-totsum  = 0
      v-ret-count   = 0
      v-ret-qnty    = 0
      v-ret-sum     = 0
      .
      FOR  EACH chk-doc WHERE
          chk-doc.obj-type = cshr-month.obj-type AND
          chk-doc.obj-code = cshr-month.obj-code AND
          chk-doc.cashier = X_staff.staff-code AND
          chk-doc.chk-date >= DateBuf-Start AND
          chk-doc.chk-date <= DateBuf-End AND
          chk-doc.out-code <> ?  NO-LOCK :
        if lookup(string(chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next.
        if chk-doc.cashier-psn-code <> X_person.psn-code then NEXT.
        if chk-doc.netto > 0 then do:
          assign
          v-out-totchk = v-out-totchk + 1
          v-out-totsum = v-out-totsum + chk-doc.netto
          .
          if v-out-totchk modulo 20  = 0
          and v-out-totchk >= 20 then
          run waitfram-show in this-procedure ( input substitute("Обработано чеков : &1",  v-out-totchk ) ) .
        end.
        else do:
          assign
          v-ret-totchk = v-ret-totchk + 1
          v-ret-totsum = v-ret-totsum + chk-doc.netto
          .
        end.
        if ( ( chk-doc.netto < 0 ) AND
            can-find( first chk-gds where
                            chk-gds.doc-code = chk-doc.doc-code AND
                            chk-gds.doc-qnty > 0 ) ) OR
                ( ( chk-doc.netto > 0 ) AND
                    can-find( first chk-gds where
                                    chk-gds.doc-code = chk-doc.doc-code AND
                                    chk-gds.doc-qnty < 0 ) ) then do:
          if chk-doc.netto < 0 then  do:
            FOR EACH chk-gds WHERE
                    chk-gds.doc-code = chk-doc.doc-code AND
                    chk-gds.doc-qnty > 0 NO-LOCK :
              assign
              v-ret-count = v-ret-count +  1
              v-ret-qnty = v-ret-qnty + abs( chk-gds.doc-qnty )
              v-ret-sum = v-ret-sum + abs( ( chk-gds.price-base - chk-gds.discnt ) * chk-gds.doc-qnty )
              .
            END .
          end.
          else do:
            FOR EACH chk-gds WHERE
                      chk-gds.doc-code = chk-doc.doc-code AND
                      chk-gds.doc-qnty < 0 NO-LOCK :
              assign
              v-out-count = v-out-count + 1
              v-out-qnty = v-out-qnty +  chk-gds.doc-qnty
              v-out-sum = v-out-sum   + ( chk-gds.price-base - chk-gds.discnt ) * chk-gds.doc-qnty
              .
            END .
          end.
        end.
        assign
        cshr-month.out-totchk = v-out-totchk
        cshr-month.out-totsum = v-out-totsum
        cshr-month.out-count  = v-out-count
        cshr-month.out-qnty   = v-out-qnty
        cshr-month.out-sum    = v-out-sum
        cshr-month.ret-totchk = v-ret-totchk
        cshr-month.ret-totsum = v-ret-totsum
        cshr-month.ret-count  = v-ret-count
        cshr-month.ret-qnty   = v-ret-qnty
        cshr-month.ret-sum    = v-ret-sum
        .
      END .
    END.
  END.
END.
run waitfram-hide in this-procedure .
return "1" .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME d-sel.
END PROCEDURE.
PROCEDURE enable_UI :
define buffer buf_db for ub.db.
ASSIGN
br-staff:NUM-LOCKED-COLUMNS IN FRAME d-sel = 2
X_staff.staff-code:read-only in browse br-staff = yes
.
ASSIGN
b-add:MENU-MOUSE = 1
b-chg:MENU-MOUSE = 1
b-del:MENU-MOUSE = 1
f-db-num = p-db-num
.
find first buf_db no-lock where buf_db.db-num = v-cntxt-db-num.
ASSIGN
v-tab-order = "b-exit,b-mark,b-add,b-sel,b-lkp,b-chg,b-del,b-hist,b-print,b-help,f-db-num," +
              "rs-status,b-arch,b-sch,f-db-num,f-staff-code" .
ENABLE
br-staff
b-quit
b-qrCode when p-role = 'C':U
b-mark WHEN lookup( "b-mark", bttns) > 0
b-sel  WHEN lookup( "b-sel", bttns) > 0
b-print
b-hist
b-help
b-add WHEN lookup( "b-add", bttns) > 0
b-del WHEN lookup( "b-add", bttns) > 0
b-chg WHEN lookup( "b-add", bttns) > 0
b-sch
b-lkp
f-db-num WHEN v-cntxt-db-num = 0
f-staff-code
RS-status
b-arch when p-role = 'C':U
WITH FRAME d-sel .
disable b-qrCode  WHEN lookup( "b-sel", bttns) > 0 with frame d-sel .
if p-role <> 'C':U then
hide b-qrCode in frame d-sel .
assign
MENU-ITEM m-add-new:sensitive in menu menu-add = (lookup( "b-add", bttns) > 0  and buf_db.add-clients)
MENU-ITEM m_psn:sensitive in menu menu-b-chg = (lookup( "b-add", bttns) > 0  and buf_db.add-clients)
MENU-ITEM m_client:sensitive in menu menu-b-del = (lookup( "b-add", bttns) > 0  and buf_db.add-clients)
.
CASE p-role:
  when 'C':U then do.
    title0 = "КАССИРЫ".
  end.
  when 'S':U then do.
    title0 = "ПРОДАВЦЫ".
  end.
END CASE.
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U).
IF NOT (v-cntxt-db-num = 0 AND p-db-num = ?)THEN DO:
    HIDE
    f-db-num
    IN FRAME d-sel.
END.
else do:
  display
  f-db-num
  with frame d-sel .
end.
Run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U)  .
if available X_staff
then log-res = br-staff:select-focused-row( ).
APPLY "ENTRY" to br-staff.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable v-stts as integer no-undo .
define variable p-user-name as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
title0 = substitute("Список персонала").
run waitfram-show in this-procedure ("Ждите...").
def var sort-column-phrase as character no-undo .
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
 ASSIGN
 frame d-sel:TITLE = title0.
if v-db-num = ? then do:
if p-open-query then do:
 assign
 frame d-sel:title = substitute("&1 &2 &3 &4"
                                               , title0
                                               , entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
                                               , (IF rs-status = 0 THEN "Все" ELSE "Текущие")
                                               , if p-psn-code= 0 then '':U else ('чел':U + string(p-psn-code))).
end.
  IF p-psn-code = 0 THEN DO:
    IF rs-status = 0  THEN DO:
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
                              "FOR EACH X_staff no-lock"
      parameter-4-34 =
        (
          if (" X_staff.role = p-role " + " " + where-phrase-34) <> ""
          then  substitute('X_staff.role = &1&2&1', chr(34), p-role ) + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code")
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
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
          (" X_staff.role = p-role " + " " + where-phrase-34 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-staff:handle
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
    OPEN QUERY br-staff FOR EACH X_staff no-lock
      where  X_staff.role = p-role
    , first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code
       BY X_staff.staff-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_staff )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-staff:handle:get-buffer-handle(1) = (buffer X_staff:handle) then do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-4-34 =
        "where ":u +  substitute('X_staff.role = &1&2&1', chr(34), p-role ) + " ":u + where-phrase-34 + " ":u + p-find-condition + " " + ""
      parameter-5-34 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
                          ,input rowid(X_staff)
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input (buffer X_staff:handle)
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
      parameter-3-34 =  "FOR EACH X_staff no-lock"
      parameter-4-34 =
        (
          if (" X_staff.role = p-role " + " " + where-phrase-34) <> ""
          then  substitute('X_staff.role = &1&2&1', chr(34), p-role ) + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code" + " " + p-find-condition)
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-34
        )
      parameter-7-34 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
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
    ELSE DO:
      run cur-time in this-procedure ( output v-today, output v-time).
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
                              "FOR EACH X_staff no-lock"
      parameter-4-36 =
        (
          if (" X_staff.role = p-role and X_staff.date-end >= v-today " + " " + where-phrase-36) <> ""
          then  substitute('X_staff.role = &1&2&1 and X_staff.date-end >= &3 ', chr(34), p-role, v-today) + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code")
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
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
          (" X_staff.role = p-role and X_staff.date-end >= v-today " + " " + where-phrase-36 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-staff:handle
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
    OPEN QUERY br-staff FOR EACH X_staff no-lock
      where  X_staff.role = p-role and X_staff.date-end >= v-today
    , first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code
       BY X_staff.staff-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_staff )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-staff:handle:get-buffer-handle(1) = (buffer X_staff:handle) then do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-4-36 =
        "where ":u +  substitute('X_staff.role = &1&2&1 and X_staff.date-end >= &3 ', chr(34), p-role, v-today) + " ":u + where-phrase-36 + " ":u + p-find-condition + " " + ""
      parameter-5-36 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
                          ,input rowid(X_staff)
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input (buffer X_staff:handle)
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
      parameter-3-36 =  "FOR EACH X_staff no-lock"
      parameter-4-36 =
        (
          if (" X_staff.role = p-role and X_staff.date-end >= v-today " + " " + where-phrase-36) <> ""
          then  substitute('X_staff.role = &1&2&1 and X_staff.date-end >= &3 ', chr(34), p-role, v-today) + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code" + " " + p-find-condition)
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-36
        )
      parameter-7-36 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
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
  END.
  ELSE DO:
      IF rs-status = 0  THEN DO:
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
                              "FOR EACH X_staff no-lock"
      parameter-4-38 =
        (
          if (" X_staff.role = p-role and X_staff.psn-code = p-psn-code " + " " + where-phrase-38) <> ""
          then  substitute('X_staff.role = &1&2&1 and X_staff.psn-code = &3 ', chr(34), p-role, p-psn-code) + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code")
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
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
          (" X_staff.role = p-role and X_staff.psn-code = p-psn-code " + " " + where-phrase-38 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-staff:handle
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
    OPEN QUERY br-staff FOR EACH X_staff no-lock
      where  X_staff.role = p-role and X_staff.psn-code = p-psn-code
    , first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code
       BY X_staff.staff-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_staff )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-staff:handle:get-buffer-handle(1) = (buffer X_staff:handle) then do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-4-38 =
        "where ":u +  substitute('X_staff.role = &1&2&1 and X_staff.psn-code = &3 ', chr(34), p-role, p-psn-code) + " ":u + where-phrase-38 + " ":u + p-find-condition + " " + ""
      parameter-5-38 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
                          ,input rowid(X_staff)
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input (buffer X_staff:handle)
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
      parameter-3-38 =  "FOR EACH X_staff no-lock"
      parameter-4-38 =
        (
          if (" X_staff.role = p-role and X_staff.psn-code = p-psn-code " + " " + where-phrase-38) <> ""
          then  substitute('X_staff.role = &1&2&1 and X_staff.psn-code = &3 ', chr(34), p-role, p-psn-code) + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code" + " " + p-find-condition)
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-38
        )
      parameter-7-38 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
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
      ELSE DO:
        run cur-time in this-procedure ( output v-today, output v-time).
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
                              "FOR EACH X_staff no-lock"
      parameter-4-40 =
        (
          if (" X_staff.role = p-role and X_staff.psn-code = p-psn-code                               and X_staff.date-end >= v-today " + " " + where-phrase-40) <> ""
          then  substitute('X_staff.role = &1&2&1 and X_staff.psn-code = &3                               and X_staff.date-end >= &4 ', chr(34), p-role, p-psn-code, v-today) + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code")
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
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
          (" X_staff.role = p-role and X_staff.psn-code = p-psn-code                               and X_staff.date-end >= v-today " + " " + where-phrase-40 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-staff:handle
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
    OPEN QUERY br-staff FOR EACH X_staff no-lock
      where  X_staff.role = p-role and X_staff.psn-code = p-psn-code                               and X_staff.date-end >= v-today
    , first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code
       BY X_staff.staff-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_staff )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-staff:handle:get-buffer-handle(1) = (buffer X_staff:handle) then do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-4-40 =
        "where ":u +  substitute('X_staff.role = &1&2&1 and X_staff.psn-code = &3                               and X_staff.date-end >= &4 ', chr(34), p-role, p-psn-code, v-today) + " ":u + where-phrase-40 + " ":u + p-find-condition + " " + ""
      parameter-5-40 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
                          ,input rowid(X_staff)
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input (buffer X_staff:handle)
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
      parameter-3-40 =  "FOR EACH X_staff no-lock"
      parameter-4-40 =
        (
          if (" X_staff.role = p-role and X_staff.psn-code = p-psn-code                               and X_staff.date-end >= v-today " + " " + where-phrase-40) <> ""
          then  substitute('X_staff.role = &1&2&1 and X_staff.psn-code = &3                               and X_staff.date-end >= &4 ', chr(34), p-role, p-psn-code, v-today) + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code" + " " + p-find-condition)
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-40
        )
      parameter-7-40 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
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
  END.
end.
ELSE DO:
  if p-open-query then do:
    assign
    frame d-sel:title = substitute("&1 &2 БД &3 &4"
                                          , title0
                                          , (IF rs-status = 0 THEN "Все" ELSE "Текущие")
                                          , v-db-num
                                          , if p-psn-code= 0 then '':U else ('чел':U + string(p-psn-code)) ).
  end.
  IF p-psn-code = 0 THEN DO:
    IF rs-status = 0  THEN DO:
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
                              "FOR EACH X_staff no-lock"
      parameter-4-42 =
        (
          if (" X_staff.role = p-role and X_staff.db-num = v-db-num " + " " + where-phrase-42) <> ""
          then  substitute('X_staff.role = &1&2&1 and X_staff.db-num = &3 ', chr(34), p-role, v-db-num) + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code")
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
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
          (" X_staff.role = p-role and X_staff.db-num = v-db-num " + " " + where-phrase-42 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-staff:handle
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
    OPEN QUERY br-staff FOR EACH X_staff no-lock
      where  X_staff.role = p-role and X_staff.db-num = v-db-num
    , first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code
       BY X_staff.staff-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_staff )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-staff:handle:get-buffer-handle(1) = (buffer X_staff:handle) then do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-4-42 =
        "where ":u +  substitute('X_staff.role = &1&2&1 and X_staff.db-num = &3 ', chr(34), p-role, v-db-num) + " ":u + where-phrase-42 + " ":u + p-find-condition + " " + ""
      parameter-5-42 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
                          ,input rowid(X_staff)
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input (buffer X_staff:handle)
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
      parameter-3-42 =  "FOR EACH X_staff no-lock"
      parameter-4-42 =
        (
          if (" X_staff.role = p-role and X_staff.db-num = v-db-num " + " " + where-phrase-42) <> ""
          then  substitute('X_staff.role = &1&2&1 and X_staff.db-num = &3 ', chr(34), p-role, v-db-num) + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code" + " " + p-find-condition)
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-42
        )
      parameter-7-42 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
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
    ELSE DO:
        run cur-time in this-procedure ( output v-today, output v-time).
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
                              "FOR EACH X_staff no-lock"
      parameter-4-44 =
        (
          if (" X_staff.role = p-role                            and X_staff.db-num = v-db-num                            and X_staff.date-end >= v-today " + " " + where-phrase-44) <> ""
          then  substitute('X_staff.role = &1&2&1                            and X_staff.db-num = &3                            and X_staff.date-end >= &4 ', chr(34), p-role, v-db-num, v-today) + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code")
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
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
          (" X_staff.role = p-role                            and X_staff.db-num = v-db-num                            and X_staff.date-end >= v-today " + " " + where-phrase-44 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-staff:handle
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
    OPEN QUERY br-staff FOR EACH X_staff no-lock
      where  X_staff.role = p-role                            and X_staff.db-num = v-db-num                            and X_staff.date-end >= v-today
    , first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code
       BY X_staff.staff-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_staff )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-staff:handle:get-buffer-handle(1) = (buffer X_staff:handle) then do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-4-44 =
        "where ":u +  substitute('X_staff.role = &1&2&1                            and X_staff.db-num = &3                            and X_staff.date-end >= &4 ', chr(34), p-role, v-db-num, v-today) + " ":u + where-phrase-44 + " ":u + p-find-condition + " " + ""
      parameter-5-44 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
                          ,input rowid(X_staff)
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input (buffer X_staff:handle)
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
      parameter-3-44 =  "FOR EACH X_staff no-lock"
      parameter-4-44 =
        (
          if (" X_staff.role = p-role                            and X_staff.db-num = v-db-num                            and X_staff.date-end >= v-today " + " " + where-phrase-44) <> ""
          then  substitute('X_staff.role = &1&2&1                            and X_staff.db-num = &3                            and X_staff.date-end >= &4 ', chr(34), p-role, v-db-num, v-today) + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code" + " " + p-find-condition)
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
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
  END.
  ELSE DO:
      IF rs-status = 0  THEN DO:
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-46  as logical   no-undo .
define variable  l-filter-open-46    as logical   .
define variable  flt-rec-46       as recid     no-undo .
define variable  filter-name-46      as character no-undo .
define variable  where-phrase-46     as character no-undo .
define variable  sort-phrase-46      as character no-undo .
define variable  where-phrase-rus-46 as character no-undo .
define variable  sort-phrase-rus-46  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-46
  ,output filter-name-46
  ,output where-phrase-46
  ,output sort-phrase-46
  ,output where-phrase-rus-46
  ,output sort-phrase-rus-46
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-46
      ) no-error .
  assign
    l-filter-open-46 = false
  .
  if flt-rec-46 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-46 as character no-undo .
    define variable  parameter-3-46 as character no-undo .
    define variable  parameter-4-46 as character no-undo .
    define variable  parameter-5-46 as character no-undo .
    define variable  parameter-6-46 as character no-undo .
    define variable  parameter-7-46 as character no-undo .
      assign
      parameter-3-46 =
                              "FOR EACH X_staff no-lock"
      parameter-4-46 =
        (
          if (" X_staff.role = p-role                               and X_staff.db-num = v-db-num                              and X_staff.psn-code = p-psn-code " + " " + where-phrase-46) <> ""
          then  substitute('X_staff.role = &1&2&1                               and X_staff.db-num = &3                              and X_staff.psn-code = &4 ', chr(34), p-role, v-db-num, p-psn-code) + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code")
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-46
        )
      parameter-7-46 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-46 =
          (" X_staff.role = p-role                               and X_staff.db-num = v-db-num                              and X_staff.psn-code = p-psn-code " + " " + where-phrase-46 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-staff:handle
                          ,input parameter-3-46
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ,input parameter-6-46
                          ,input parameter-7-46
                          )
      .
      assign
        l-filter-open-46 = true
      .
    end.
    if l-filter-open-46 = false then do:
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
  if l-filter-open-46 = false then do:
    OPEN QUERY br-staff FOR EACH X_staff no-lock
      where  X_staff.role = p-role                               and X_staff.db-num = v-db-num                              and X_staff.psn-code = p-psn-code
    , first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code
       BY X_staff.staff-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_staff )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-staff:handle:get-buffer-handle(1) = (buffer X_staff:handle) then do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-4-46 =
        "where ":u +  substitute('X_staff.role = &1&2&1                               and X_staff.db-num = &3                              and X_staff.psn-code = &4 ', chr(34), p-role, v-db-num, p-psn-code) + " ":u + where-phrase-46 + " ":u + p-find-condition + " " + ""
      parameter-5-46 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
                          ,input rowid(X_staff)
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input (buffer X_staff:handle)
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-3-46 =  "FOR EACH X_staff no-lock"
      parameter-4-46 =
        (
          if (" X_staff.role = p-role                               and X_staff.db-num = v-db-num                              and X_staff.psn-code = p-psn-code " + " " + where-phrase-46) <> ""
          then  substitute('X_staff.role = &1&2&1                               and X_staff.db-num = &3                              and X_staff.psn-code = &4 ', chr(34), p-role, v-db-num, p-psn-code) + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code" + " " + p-find-condition)
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-46
        )
      parameter-7-46 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input parameter-3-46
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ,input parameter-6-46
                          ,input parameter-7-46
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
        run cur-time in this-procedure ( output v-today, output v-time).
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-48  as logical   no-undo .
define variable  l-filter-open-48    as logical   .
define variable  flt-rec-48       as recid     no-undo .
define variable  filter-name-48      as character no-undo .
define variable  where-phrase-48     as character no-undo .
define variable  sort-phrase-48      as character no-undo .
define variable  where-phrase-rus-48 as character no-undo .
define variable  sort-phrase-rus-48  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-48
  ,output filter-name-48
  ,output where-phrase-48
  ,output sort-phrase-48
  ,output where-phrase-rus-48
  ,output sort-phrase-rus-48
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-48
      ) no-error .
  assign
    l-filter-open-48 = false
  .
  if flt-rec-48 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-48 as character no-undo .
    define variable  parameter-3-48 as character no-undo .
    define variable  parameter-4-48 as character no-undo .
    define variable  parameter-5-48 as character no-undo .
    define variable  parameter-6-48 as character no-undo .
    define variable  parameter-7-48 as character no-undo .
      assign
      parameter-3-48 =
                              "FOR EACH X_staff no-lock"
      parameter-4-48 =
        (
          if (" X_staff.role = p-role
                              and X_staff.psn-code = p-psn-code                               and X_staff.db-num = v-db-num                               and X_staff.date-end >= v-today " + " " + where-phrase-48) <> ""
          then  substitute('X_staff.role = &1&2&1
                              and X_staff.psn-code = &3                               and X_staff.db-num = &4                               and X_staff.date-end >= &5 ', chr(34), p-role, p-psn-code, v-db-num , v-today) + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code")
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-48
        )
      parameter-7-48 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-48 =
          (" X_staff.role = p-role
                              and X_staff.psn-code = p-psn-code                               and X_staff.db-num = v-db-num                               and X_staff.date-end >= v-today " + " " + where-phrase-48 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-staff:handle
                          ,input parameter-3-48
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ,input parameter-6-48
                          ,input parameter-7-48
                          )
      .
      assign
        l-filter-open-48 = true
      .
    end.
    if l-filter-open-48 = false then do:
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
  if l-filter-open-48 = false then do:
    OPEN QUERY br-staff FOR EACH X_staff no-lock
      where  X_staff.role = p-role
                              and X_staff.psn-code = p-psn-code                               and X_staff.db-num = v-db-num                               and X_staff.date-end >= v-today
    , first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code
       BY X_staff.staff-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_staff )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-staff:handle:get-buffer-handle(1) = (buffer X_staff:handle) then do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-4-48 =
        "where ":u +  substitute('X_staff.role = &1&2&1
                              and X_staff.psn-code = &3                               and X_staff.db-num = &4                               and X_staff.date-end >= &5 ', chr(34), p-role, p-psn-code, v-db-num , v-today) + " ":u + where-phrase-48 + " ":u + p-find-condition + " " + ""
      parameter-5-48 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
                          ,input rowid(X_staff)
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input (buffer X_staff:handle)
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-3-48 =  "FOR EACH X_staff no-lock"
      parameter-4-48 =
        (
          if (" X_staff.role = p-role
                              and X_staff.psn-code = p-psn-code                               and X_staff.db-num = v-db-num                               and X_staff.date-end >= v-today " + " " + where-phrase-48) <> ""
          then  substitute('X_staff.role = &1&2&1
                              and X_staff.psn-code = &3                               and X_staff.db-num = &4                               and X_staff.date-end >= &5 ', chr(34), p-role, p-psn-code, v-db-num , v-today) + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + ", first X_person NO-LOCK WHERE X_person.psn-code = X_staff.psn-code, first X_clients NO-LOCK WHERE X_clients.obj-type = 'чел':U         AND X_clients.obj-code = X_staff.psn-code" + " " + p-find-condition)
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_staff.staff-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-48
        )
      parameter-7-48 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-staff:handle
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input parameter-3-48
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ,input parameter-6-48
                          ,input parameter-7-48
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
END.
if not p-open-query then
REPOSITION br-staff to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-staff:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-staff in frame d-sel.
APPLY "ENTRY" TO br-staff.
END PROCEDURE.
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable glog as logical no-undo .
define variable ri as recid no-undo .
define variable vss-include-info49 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-reference-prs_add-del':U
    ,input  'global':U
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
if NOT glog then  return no-apply .
run ref/rolei.p ( INPUT parparentproc
            ,input 'ДОБАВЛЕНИЕ':U
            ,input (IF add-option = "new":u
                    THEN 0
                    ELSE ?   )
            ,input p-role
            ,input ?
            ,input-output ri
            ,input-output table tt-staff
            ) .
if ri <> ? then  do:
    Run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U ).
    reposition br-staff to recid ri no-error .
end.
apply "entry" to br-staff IN FRAME d-sel .
END PROCEDURE.
PROCEDURE proc-b-chg :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable v-old-cshr as integer no-undo .
define variable glog as logical no-undo .
define variable ri as recid no-undo .
define variable ric as recid no-undo .
define buffer buf_person for ub.person.
IF NOT AVAILABLE X_staff THEN RETURN.
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-reference_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
if NOT glog
and p-option = "staff":U
and X_staff.role = 'C':U
then do :
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-cashiers_update':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
  if NOT glog
  then do :
    message "У вас не хватает прав на изменение." skip
            "(actn_cashdesk-cashiers_update)"
    view-as alert-box error .
    return no-apply .
  end .
end.
if NOT glog
then do :
  message "У вас не хватает прав на изменение." skip
          "(actn_client-reference_update)"
  view-as alert-box error .
  return no-apply .
end .
assign
ric = recid( X_clients )
ri = recid( X_staff )
.
CASE p-option:
  WHEN 'чел':U THEN DO:
    run ref/personi.w (
                     input parparentproc
                    ,input 'ИЗМЕНЕНИЕ':U
                    ,input X_clients.obj-code
                    ,input X_clients.grp-code
                    ,input p-role
                    ,input-output  ric) .
    if ric <> ? then do:
      run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).
      reposition br-staff to recid ri no-error .
    end.
  END.
  WHEN  "staff":U THEN DO:
     run ref/rolei.p (
                     input parparentproc
                    ,input 'ИЗМЕНЕНИЕ':U
                    ,input X_clients.obj-code
                    ,input X_staff.role
                    ,input X_staff.role-level
                    ,input-output  ri
                    ,input-output table tt-staff
                    ) .
    IF ri <> ? THEN DO:
        run OpenBr in this-procedure ( INPUT yes, INPUT no, INPUT '':U).
        reposition br-staff to recid ri no-error .
    END.
  END.
END CASE.
apply "entry" to br-staff IN FRAME d-sel .
END PROCEDURE.
PROCEDURE proc-b-del :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
define variable glog as logical no-undo .
define variable ri as recid no-undo .
define variable ric as recid no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_clients for ub.clients.
IF NOT AVAILABLE X_staff  THEN RETURN.
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-reference-prs_add-del':U
    ,input  'global':U
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
if NOT glog then return no-apply .
CASE p-option :
  WHEN 'staff' THEN DO:
    run cur-time in this-procedure ( output v-today, output v-time).
    message
    substitute("Вы уверены, что хотите удалить запись типа &1&2" +
               "для физ.лица &3 (дата удаления - сегодня, &4)?&2" +
               "Это может привести к ошибкам при разборе чеков&2"
               ,v-role-name
               ,chr(10)
               ,X_clients.obj-name
               , string(v-today, "99/99/9999")
               )
    view-as alert-box QUESTION buttons yes-no update glog.
    if not glog then do:
       undo, return no-apply.
    end.
    ri = recid (X_staff).
    run ref/staff01.p (
                   input-output ri
                  ,input 'удаление':U
                  ,input no
                  ,input X_staff.role
                  ,input X_staff.staff-code
                  ,input X_staff.psn-code
                  ,input X_staff.role-level
                  ,input X_staff.date-start
                  ,input ?
                  ,input X_staff.db-num
                  ,input X_staff.host-code
                  ,input X_staff.obj-type
                  ,input X_staff.obj-code
                  ,input X_staff.work-place
                  ,input X_staff.password) no-error .
    if error-status:error then do:
      undo, return error.
    end.
  END.
  WHEN 'чел':U THEN DO:
    if X_clients.stts <> 0 then do:
      message
      SUBSTITUTE("Данное физ.лицо&1&2&1У Ж Е  имеет статус У Д А Л Е Н. &1Восстановить"
                 , chr(10)
                 ,X_clients.obj-name )
      view-as alert-box question buttons yes-no update choice .
      if choice then  do:
        ri = recid( X_staff ).
        ric = recid( X_clients ).
        FIND FIRST buf_clients WHERE recid( buf_clients ) = ric .
        buf_clients.stts = 0 .
        br-staff:refresh() IN FRAME d-sel.
      end.
    end.
    else do:
      message "Установить статус УДАЛЕН  для данного клиента?"
      view-as alert-box question buttons yes-no update choice .
      if choice then  do:
        ri = recid( X_clients ).
        ric = recid( X_clients ).
        FIND FIRST buf_clients WHERE recid( buf_clients ) = ric .
        buf_clients.stts = 1.
      end.
    end.
  END.
END CASE.
br-staff:refresh().
reposition br-staff to row 1 no-error .
apply "ENTRY" to br-staff .
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'staff'
  join-tbl = 'X_staff'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
IF p-psn-code = 0 THEN DO:
  run fltfield-add in this-procedure('psn-code', 'Код Физ.лица', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
END.
run fltfield-add in this-procedure('staff-code', 'Код персонала', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('date-start', 'Работает с', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('date-end', 'Работал по', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT filter-point0 + chr(4) + filter-label
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  run OpenBr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
END.
END PROCEDURE.
PROCEDURE proc-find_staff-code :
define input parameter p-next as logical no-undo.
define input parameter p-staff-code like ub.staff.staff-code no-undo.
run OpenBr in THIS-PROCEDURE (
                              input false
                             ,input p-next
                             ,input substitute("and X_staff.staff-code = &1 ", p-staff-code)
                            ).
apply "entry":u to f-staff-code in frame d-sel .
END PROCEDURE.
