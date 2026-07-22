block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter startdate as date no-undo .
define input parameter enddate as date no-undo .
define input parameter X-SelectObject as char no-undo .
define input parameter SelectObject as char no-undo .
define input parameter method as char no-undo .
define input parameter ByObject as logical no-undo .
define input parameter Whstart as integer no-undo .
define input parameter WHEnd as integer no-undo .
define input parameter TREE as logical no-undo.
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .
define input parameter checked-time-intervals as char no-undo.
define variable  vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable  vss-author      as character no-undo init "$Author: expertek $":U .
define variable  vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable  vss-workfile    as character no-undo init "$Workfile: sxgrp-h.p $":U .
define variable  vss-archive     as character no-undo init "$Archive: rep/sxgrp-h.p $":U .
define variable  vss-description as character no-undo init "Почасовая статистика розничных продаж по СУММАМ ПРОДАЖ вывод в    EXCEL".
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
def
 shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable  With-Goods as logical no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED temp-table grp-h no-undo
    field obj-code like ub.clients.obj-code
    field grp-code like ub.goods.grp-code
    field other-code as integer
    field sum      as   decimal extent 24
    field sum_disc as   decimal extent 24
    field num-chk as integer extent 24 format ">>>>>9"
    INDEX pi IS PRIMARY obj-code grp-code other-code ASCENDING .
DEFINE SHARED temp-table gds-h no-undo
   field obj-code like ub.clients.obj-code
    field grp-code like ub.goods.grp-code
    field b-code   like ub.bar-code.b-code
    field gds-name like ub.goods.gds-name
    field uniq     as   char
    field artic    like ub.goods.artic
    field sum      as   decimal extent 24
    field sum_disc as   decimal extent 24
    INDEX pi IS PRIMARY obj-code grp-code b-code ASCENDING
    INDEX uu obj-code grp-code uniq ASCENDING .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE   temp-table full-grp no-undo
    field obj-code like ub.clients.obj-code
    field grp-code like ub.gds-grp.node-code
    field full-name like ub.goods.grp-name
    field other-code as integer
    INDEX i1 full-name ASCENDING
    INDEX i2
    obj-code
    grp-code other-code
      .
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input 'орг':U
  ,input p-curr-host-code
  ,input 'report-firm':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.
define SHARED temp-table temp-dis-card-type no-undo like ub.dis-card-type.
define   shared variable Use-column   as logical extent 256 no-undo .
define buffer b-grp-h for grp-h .
define buffer b-gds-h for gds-h .
define buffer for-grp for ub.gds-grp.
define variable tot-by-grp as decimal no-undo .
define variable tot-nc-by-grp as decimal no-undo format ">>>>>9".
define variable ii as integer no-undo .
define variable kk as integer no-undo .
define variable cycle as integer no-undo .
define variable cycle1 as integer no-undo .
define variable hours as character no-undo.
define variable sums as decimal no-undo.
define variable v-accum-sum as decimal no-undo .
define variable v-accum-sum_disc as decimal no-undo .
define variable v-accum-num-chk as integer no-undo .
define variable accum-sum as decimal extent 24 no-undo .
define variable accum-num-chk as integer extent 24 no-undo .
define variable accum-tot-by-grp as decimal no-undo .
define variable accum-tot-nc-by-grp as decimal no-undo format ">>>>>9".
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-obj-name as character no-undo .
define variable accum-obj-list as integer no-undo .
define variable  for-title as char no-undo.
define buffer cli-obj for ub.clients .
CASE method:
  when "pay-desk":U then for-title = "Кассы".
  when "pays":U then for-title = "Виды кассовых платежей".
  otherwise for-title = "Группа товаров ( по классификатору )".
END CASE.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer tot_full-grp for full-grp.
for each obj-list no-lock:
  assign
  accum-obj-list = accum-obj-list + 1.
  if accum-obj-list > 1 then LEAVE.
end.
IF METHOD = "GOODS" then WIth-goods = yes.
else with-goods = no.
CASE method:
  when "pay-desk":U then do:
    for each ub.cash-desk no-lock :
      if X-SelectObject = 'все':U then.
      else do:
        find first obj-list No-LOCK WHERE
                  obj-list.obj-code = ub.cash-desk.obj-code AND
                  obj-list.obj-type = 'маг':U No-ERROR.
        if not available obj-list then next.
      end.
      create full-grp.
      assign
      full-grp.grp-code =   ub.cash-desk.cash-num
      full-grp.other-code = ub.cash-desk.obj-code
      full-grp.full-name = substitute("БД_&1_маг_&2_Касса_&3"
                                                ,  ub.cash-desk.db-num
                                                ,  ub.cash-desk.obj-code
                                                ,  ub.cash-desk.cash-num)
      .
    end.
    create full-grp.
    assign
    full-grp.grp-code =   0
    full-grp.other-code = 0
    full-grp.full-name = '':U
    .
  end.
  when "pays":U then do:
    for each ub.cash-pay No-LOCK:
      create full-grp.
      assign
      full-grp.obj-code = 0
      full-grp.grp-code = ub.cash-pay.cdpay-code
      full-grp.other-code = ub.cash-pay.curr-code
      .
      FIND FIRST ub.currency No-LOCK WHERE
                ub.currency.curr-code = ub.cash-pay.curr-code no-error.
      full-grp.full-name = substitute("&1_Валюта_&2"
                                      , ub.cash-pay.obj-name
                                      ,(if available ub.currency
                                        then ub.currency.curr-abbr
                                        else string(cash-pay.curr-code))).
    end.
  end.
  when "GOODS" or
  when "GROUPS" then do:
    run waitfram-show in this-procedure ("Строю дерево групп ...").
    for each ub.gds-grp no-lock:
      find first for-grp where
                for-grp.upper-code = ub.gds-grp.node-code No-LOCK No-ERROR.
      if not avail for-grp then do:
        create full-grp.
        assign
        full-grp.obj-code = 0
        full-grp.grp-code = ub.gds-grp.node-code.
        if tree then
        run grplib-get-full-name in this-procedure(input ub.gds-grp.node-code, output full-grp.full-name).
        else
        full-grp.full-name = ub.gds-grp.node-name.
        full-grp.full-name = replace(full-grp.full-name, " ", "_").
      end.
    end.
    run waitfram-hide in this-procedure .
  end.
end CASE.
if method <> "TOTALS":U and method <> "pays":U then do:
  for each grp-h :
    assign
    grp-h.sum[1] = grp-h.sum[1] - grp-h.sum_disc[1]
    grp-h.sum[2] = grp-h.sum[2] - grp-h.sum_disc[2]
    grp-h.sum[3] = grp-h.sum[3] - grp-h.sum_disc[3]
    grp-h.sum[4] = grp-h.sum[4] - grp-h.sum_disc[4]
    grp-h.sum[5] = grp-h.sum[5] - grp-h.sum_disc[5]
    grp-h.sum[6] = grp-h.sum[6] - grp-h.sum_disc[6]
    grp-h.sum[7] = grp-h.sum[7] - grp-h.sum_disc[7]
    grp-h.sum[8] = grp-h.sum[8] - grp-h.sum_disc[8]
    grp-h.sum[9] = grp-h.sum[9] - grp-h.sum_disc[9]
    grp-h.sum[10] = grp-h.sum[10] - grp-h.sum_disc[10]
    grp-h.sum[11] = grp-h.sum[11] - grp-h.sum_disc[11]
    grp-h.sum[12] = grp-h.sum[12] - grp-h.sum_disc[12]
    grp-h.sum[13] = grp-h.sum[13] - grp-h.sum_disc[13]
    grp-h.sum[14] = grp-h.sum[14] - grp-h.sum_disc[14]
    grp-h.sum[15] = grp-h.sum[15] - grp-h.sum_disc[15]
    grp-h.sum[16] = grp-h.sum[16] - grp-h.sum_disc[16]
    grp-h.sum[17] = grp-h.sum[17] - grp-h.sum_disc[17]
    grp-h.sum[18] = grp-h.sum[18] - grp-h.sum_disc[18]
    grp-h.sum[19] = grp-h.sum[19] - grp-h.sum_disc[19]
    grp-h.sum[20] = grp-h.sum[20] - grp-h.sum_disc[20]
    grp-h.sum[21] = grp-h.sum[21] - grp-h.sum_disc[21]
    grp-h.sum[22] = grp-h.sum[22] - grp-h.sum_disc[22]
    grp-h.sum[23] = grp-h.sum[23] - grp-h.sum_disc[23]
    grp-h.sum[24] = grp-h.sum[24] - grp-h.sum_disc[24]
    .
  end.
END.
for each gds-h:
  assign
  gds-h.sum[1] = gds-h.sum[1] - gds-h.sum_disc[1]
  gds-h.sum[2] = gds-h.sum[2] - gds-h.sum_disc[2]
  gds-h.sum[3] = gds-h.sum[3] - gds-h.sum_disc[3]
  gds-h.sum[4] = gds-h.sum[4] - gds-h.sum_disc[4]
  gds-h.sum[5] = gds-h.sum[5] - gds-h.sum_disc[5]
  gds-h.sum[6] = gds-h.sum[6] - gds-h.sum_disc[6]
  gds-h.sum[7] = gds-h.sum[7] - gds-h.sum_disc[7]
  gds-h.sum[8] = gds-h.sum[8] - gds-h.sum_disc[8]
  gds-h.sum[9] = gds-h.sum[9] - gds-h.sum_disc[9]
  gds-h.sum[10] = gds-h.sum[10] - gds-h.sum_disc[10]
  gds-h.sum[11] = gds-h.sum[11] - gds-h.sum_disc[11]
  gds-h.sum[12] = gds-h.sum[12] - gds-h.sum_disc[12]
  gds-h.sum[13] = gds-h.sum[13] - gds-h.sum_disc[13]
  gds-h.sum[14] = gds-h.sum[14] - gds-h.sum_disc[14]
  gds-h.sum[15] = gds-h.sum[15] - gds-h.sum_disc[15]
  gds-h.sum[16] = gds-h.sum[16] - gds-h.sum_disc[16]
  gds-h.sum[17] = gds-h.sum[17] - gds-h.sum_disc[17]
  gds-h.sum[18] = gds-h.sum[18] - gds-h.sum_disc[18]
  gds-h.sum[19] = gds-h.sum[19] - gds-h.sum_disc[19]
  gds-h.sum[20] = gds-h.sum[20] - gds-h.sum_disc[20]
  gds-h.sum[21] = gds-h.sum[21] - gds-h.sum_disc[21]
  gds-h.sum[22] = gds-h.sum[22] - gds-h.sum_disc[22]
  gds-h.sum[23] = gds-h.sum[23] - gds-h.sum_disc[23]
  gds-h.sum[24] = gds-h.sum[24] - gds-h.sum_disc[24]
  .
end.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
PUT stream PrnLibStream UNFORMATTED
"Почасовая статистика розничных продаж ( по СУММЕ ПРОДАЖ ) ЗА ПЕРИОД c" +
string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) + "."      format "x(110)" SKIP(1).
if t-dis-card then do:
  PUT stream PrnLibStream UNFORMATTED
  "Только покупки по дисконтным картам" skip.
  if rs-dis-card = 1 then do:
    for each temp-dis-card-type No-LOCK:
      PUT stream PrnLibStream UNFORMATTED
      temp-dis-card-type.type
      skip.
    END.
  end.
end.
PUT stream PrnLibStream UNFORMATTED
SPACE(10) SelectObject SKIP(0)
(if byobject then "С разбивкой по объектам" else '')  SKIP(1).
PUT stream PrnLibStream UNFORMATTED
SKIP
cur-time-print() format "x(35)" SKIP.
IF METHOD = "TOTALS" THEN DO:
  PUT stream PrnLibStream UNformatted
  "_" p-XL-delim
  "Сумма_брутто" p-XL-delim
  "Сумма_скидок" p-XL-delim
  "Сумма_нетто"  p-XL-delim
  "Количество_чеков" p-XL-delim
  skip.
  _cycle:
  do  cycle = 1 to 0 by -1:
    if byobject and cycle = 0 and accum-obj-list = 1 then LEAVE _cycle.
    _obj-list:
    for each obj-list no-lock:
      if not byobject and cycle = 1 then LEAVE _obj-list.
      if cycle = 1 then v-obj-code = obj-list.obj-code.
      if cycle = 0 then v-obj-code = 0.
      ASSIGN
      v-accum-SUM = 0
      v-accum-SUM_DISC = 0
      v-accum-NUM-CHK = 0
      .
      if cycle = 1 then do:
        FIND FIRST ub.clients NO-LOCK WHERE
                  ub.clients.obj-code = v-obj-code AND
                  ub.clients.obj-type = 'маг':U NO-ERROR.
        if available ub.clients then do:
          v-obj-name = replace(ub.clients.obj-name, chr(32), "_").
        end.
        else v-obj-name = string(v-obj-code).
      end.
      if byobject and cycle = 0 then do:
        v-obj-name = "ПО_ВСЕМ_ОБЪЕКТАМ".
      end.
      put stream PrnLibstream Unformatted
      v-obj-name
      skip.
      FOR EACH grp-h No-LOCK where
              grp-h.obj-code = v-obj-code
      by grp-h.obj-code :
        DO ii = 0 TO 23 :
            if entry(ii + 1, checked-time-intervals) = "no" then next.
            HOURS = string(ii, "99") + ".00-" + string(ii, "99") + ".59".
            PUT stream PrnLibStream UNFORMATTED
            HOURS p-XL-delim
            grp-h.sum[ii + 1] p-XL-delim
            grp-h.sum_disc[ii + 1] p-XL-delim
            grp-h.sum[ii + 1] - grp-h.sum_disc[ii + 1] p-XL-delim
            grp-h.num-chk[ii + 1] p-XL-delim
            skip
            .
            assign
            V-ACCUM-sum = v-accum-sum + grp-h.sum[ii + 1]
            V-ACCUM-sum_disc = v-accum-sum_disc + grp-h.sum_disc[ii + 1]
            V-ACCUM-num-chk = v-accum-num-chk + grp-h.num-chk[ii + 1]
            .
            IF ii = 23 then do:
              PUT stream PrnLibStream UNFORMATTED
              (if cycle = 1
              then substitute("Итого_&1", grp-h.obj-code)
              else "ИТОГО") p-XL-delim
              v-ACCUM-sum p-XL-delim
              v-ACCUM-sum_disc p-XL-delim
              v-ACCUM-sum - v-accum-sum_disc p-XL-delim
              v-aCCUM-num-chk p-XL-delim
            SKIP.
            end.
          END.
        END.
        if cycle = 0 then LEAVE _obj-list.
     end.
   end.
END.
ELSE DO:
  CASE method:
    when "GROUPS":U then do:
      PUT stream PrnLibStream  UNFORMATTED
      "Группа_товара"
      p-XL-delim.
    end.
    when "GOODS":U then do:
      PUT stream PrnLibStream  UNFORMATTED
      ("Группа_товара/Артикул" + p-XL-delim + "Назв.товара")
      p-XL-delim.
    end.
    when "pay-desk":U then do :
      PUT stream PrnLibStream  UNFORMATTED
      "Касса"
      p-XL-delim.
    end.
    when "pays":U then do :
      PUT stream PrnLibStream  UNFORMATTED
      "Вид_кассового_платежа"
      p-XL-delim.
    end.
  END CASE.
  if use-column[4] then
    PUT stream PrnLibStream  UNFORMATTED
    "0.00-0.59" p-XL-delim.
  if use-column[5] then
    PUT stream PrnLibStream  UNFORMATTED
    "1.00-1.59" p-XL-delim.
  if use-column[6] then
    PUT stream PrnLibStream  UNFORMATTED
    "2.00-2.59" p-XL-delim.
  if use-column[7] then
    PUT stream PrnLibStream  UNFORMATTED
    "3.00-3.59" p-XL-delim.
  if use-column[8] then
    PUT stream PrnLibStream  UNFORMATTED
    "4.00-4.59" p-XL-delim.
  if use-column[9] then
    PUT stream PrnLibStream  UNFORMATTED
    "5.00-5.59" p-XL-delim.
  if use-column[10] then
    PUT stream PrnLibStream  UNFORMATTED
    "6.00-6.59" p-XL-delim.
  if use-column[11] then
    PUT stream PrnLibStream  UNFORMATTED
    "7.00-7.59" p-XL-delim.
  if use-column[12] then
    PUT stream PrnLibStream  UNFORMATTED
    "8.00-8.59" p-XL-delim.
  if use-column[13] then
    PUT stream PrnLibStream  UNFORMATTED
    "9.00-9.59" p-XL-delim.
  if use-column[14] then
    PUT stream PrnLibStream  UNFORMATTED
    "10.00-10.59" p-XL-delim.
  if use-column[15] then
    PUT stream PrnLibStream  UNFORMATTED
    "11.00-11.59" p-XL-delim.
  if use-column[16] then
    PUT stream PrnLibStream  UNFORMATTED
    "12.00-12.59" p-XL-delim.
  if use-column[17] then
    PUT stream PrnLibStream  UNFORMATTED
    "13.00-13.59" p-XL-delim.
  if use-column[18] then
    PUT stream PrnLibStream  UNFORMATTED
    "14.00-14.59" p-XL-delim.
  if use-column[19] then
    PUT stream PrnLibStream  UNFORMATTED
    "15.00-15.59" p-XL-delim.
  if use-column[20] then
    PUT stream PrnLibStream  UNFORMATTED
    "16.00-16.59" p-XL-delim.
  if use-column[21] then
    PUT stream PrnLibStream  UNFORMATTED
    "17.00-17.59" p-XL-delim.
  if use-column[22] then
    PUT stream PrnLibStream  UNFORMATTED
    "18.00-18.59" p-XL-delim.
  if use-column[23] then
    PUT stream PrnLibStream  UNFORMATTED
    "19.00-19.59" p-XL-delim.
  if use-column[24] then
    PUT stream PrnLibStream  UNFORMATTED
    "20.00-20.59" p-XL-delim.
  if use-column[25] then
    PUT stream PrnLibStream  UNFORMATTED
    "21.00-21.59" p-XL-delim.
  if use-column[26] then
    PUT stream PrnLibStream  UNFORMATTED
    "22.00-22.59" p-XL-delim.
  if use-column[27] then
    PUT stream PrnLibStream  UNFORMATTED
    "23.00-23.59" p-XL-delim.
  PUT stream PrnLibStream  UNFORMATTED
  "Итого_по_строке" p-XL-delim .
  IF method = "pay-desk":U
  OR method = "pays":U then do:
    PUT stream PrnLibStream UNFORMATTED
    (if method = "pay-desk"
    then "Пробито_чеков"
    else "Кол-во_платежей") p-XL-delim.
  if use-column[4] then
    PUT stream PrnLibStream  UNFORMATTED
    "0.00-0.59" p-XL-delim.
  if use-column[5] then
    PUT stream PrnLibStream  UNFORMATTED
    "1.00-1.59" p-XL-delim.
  if use-column[6] then
    PUT stream PrnLibStream  UNFORMATTED
    "2.00-2.59" p-XL-delim.
  if use-column[7] then
    PUT stream PrnLibStream  UNFORMATTED
    "3.00-3.59" p-XL-delim.
  if use-column[8] then
    PUT stream PrnLibStream  UNFORMATTED
    "4.00-4.59" p-XL-delim.
  if use-column[9] then
    PUT stream PrnLibStream  UNFORMATTED
    "5.00-5.59" p-XL-delim.
  if use-column[10] then
    PUT stream PrnLibStream  UNFORMATTED
    "6.00-6.59" p-XL-delim.
  if use-column[11] then
    PUT stream PrnLibStream  UNFORMATTED
    "7.00-7.59" p-XL-delim.
  if use-column[12] then
    PUT stream PrnLibStream  UNFORMATTED
    "8.00-8.59" p-XL-delim.
  if use-column[13] then
    PUT stream PrnLibStream  UNFORMATTED
    "9.00-9.59" p-XL-delim.
  if use-column[14] then
    PUT stream PrnLibStream  UNFORMATTED
    "10.00-10.59" p-XL-delim.
  if use-column[15] then
    PUT stream PrnLibStream  UNFORMATTED
    "11.00-11.59" p-XL-delim.
  if use-column[16] then
    PUT stream PrnLibStream  UNFORMATTED
    "12.00-12.59" p-XL-delim.
  if use-column[17] then
    PUT stream PrnLibStream  UNFORMATTED
    "13.00-13.59" p-XL-delim.
  if use-column[18] then
    PUT stream PrnLibStream  UNFORMATTED
    "14.00-14.59" p-XL-delim.
  if use-column[19] then
    PUT stream PrnLibStream  UNFORMATTED
    "15.00-15.59" p-XL-delim.
  if use-column[20] then
    PUT stream PrnLibStream  UNFORMATTED
    "16.00-16.59" p-XL-delim.
  if use-column[21] then
    PUT stream PrnLibStream  UNFORMATTED
    "17.00-17.59" p-XL-delim.
  if use-column[22] then
    PUT stream PrnLibStream  UNFORMATTED
    "18.00-18.59" p-XL-delim.
  if use-column[23] then
    PUT stream PrnLibStream  UNFORMATTED
    "19.00-19.59" p-XL-delim.
  if use-column[24] then
    PUT stream PrnLibStream  UNFORMATTED
    "20.00-20.59" p-XL-delim.
  if use-column[25] then
    PUT stream PrnLibStream  UNFORMATTED
    "21.00-21.59" p-XL-delim.
  if use-column[26] then
    PUT stream PrnLibStream  UNFORMATTED
    "22.00-22.59" p-XL-delim.
  if use-column[27] then
    PUT stream PrnLibStream  UNFORMATTED
    "23.00-23.59" p-XL-delim.
  PUT stream PrnLibStream  UNFORMATTED
    "Итого_по_строке" p-XL-delim skip.
  end.
  else do:
    PUT stream PrnLibStream unformatted skip.
  end.
  _cycle2:
  DO cycle = 1 to 0 by -1:
     if byobject and cycle = 0 and accum-obj-list = 1 then LEAVE _cycle2.
    _obj-list2:
    for each obj-list no-lock:
      if not byobject and cycle = 1 then LEAVE _obj-list2.
      if cycle = 1 then v-obj-code = obj-list.obj-code.
      if cycle = 0 then v-obj-code = 0.
      if cycle = 1 then do:
        FIND FIRST ub.clients NO-LOCK WHERE
                  ub.clients.obj-code = v-obj-code AND
                  ub.clients.obj-type = 'маг':U NO-ERROR.
        if available ub.clients then do:
          v-obj-name = ub.clients.obj-name.
        end.
        else v-obj-name = string(v-obj-code).
      end.
      if byobject and cycle = 0 then do:
        v-obj-name = "ПО_ВСЕМ_ ОБЪЕКТАМ".
      end.
      if  byobject and not (cycle = 0 and method = "pay-desk")  then
      PUT stream PrnLibStream unformatted
      v-obj-name
      skip.
      assign
      tot-nc-by-grp  = 0
      tot-by-grp     = 0
      accum-sum[1]   = 0
      accum-sum[2]   = 0
      accum-sum[3]   = 0
      accum-sum[4]   = 0
      accum-sum[5]   = 0
      accum-sum[6]   = 0
      accum-sum[7]   = 0
      accum-sum[8]   = 0
      accum-sum[9]   = 0
      accum-sum[10]  = 0
      accum-sum[11]  = 0
      accum-sum[12]  = 0
      accum-sum[13]  = 0
      accum-sum[14]  = 0
      accum-sum[15]  = 0
      accum-sum[16]  = 0
      accum-sum[17]  = 0
      accum-sum[18]  = 0
      accum-sum[19]  = 0
      accum-sum[20]  = 0
      accum-sum[21]  = 0
      accum-sum[22]  = 0
      accum-sum[23]  = 0
      accum-sum[24]  = 0
      accum-tot-by-grp = 0
      accum-num-chk[1] =  0
      accum-num-chk[2] =  0
      accum-num-chk[3] =  0
      accum-num-chk[4] =  0
      accum-num-chk[5] =  0
      accum-num-chk[6] =  0
      accum-num-chk[7] =  0
      accum-num-chk[8] =  0
      accum-num-chk[9] =  0
      accum-num-chk[10] = 0
      accum-num-chk[11] = 0
      accum-num-chk[12] = 0
      accum-num-chk[13] = 0
      accum-num-chk[14] = 0
      accum-num-chk[15] = 0
      accum-num-chk[16] = 0
      accum-num-chk[17] = 0
      accum-num-chk[18] = 0
      accum-num-chk[19] = 0
      accum-num-chk[20] = 0
      accum-num-chk[21] = 0
      accum-num-chk[22] = 0
      accum-num-chk[23] = 0
      accum-num-chk[24] = 0
      accum-tot-nc-by-grp = 0
      .
      FOR EACH full-grp NO-LOCK,
          EACH grp-h WHERE
               grp-h.obj-code = v-obj-code
           AND grp-h.grp-code = full-grp.grp-code
      BREAK
      BY full-grp.full-name
      BY grp-h.obj-code
      BY grp-h.grp-code
      BY grp-h.other-code :
        if cycle = 1 and method = "pay-desk" and full-grp.other-code <> v-obj-code then next.
        if (method = "pays":U and first-of( grp-h.other-code )) or
           (method <> "pays":U and first-of(grp-h.grp-code)) then do:
         assign
            tot-nc-by-grp = 0
            tot-by-grp = 0
          .
          if method = "pay-desk":U or method = "pays":U then do:
            do cycle1 = 1 to 24.
              if use-column[cycle1 + 3] then tot-nc-by-grp = grp-h.num-chk[cycle1] + tot-nc-by-grp .
            end.
          end.
          do cycle1 = 1 to 24.
            if use-column[cycle1 + 3] then tot-by-grp = grp-h.sum[cycle1] + tot-by-grp .
          end.
          if method = "pay-desk":U  or method = "pays":U then do:
            if method = "pay-desk" and cycle = 0 then.
            else do:
              PUT stream PrnLibStream UNFORMATTED
              full-grp.FULL-NAME p-XL-delim.
              do cycle1 = 1 to 24.
                if use-column[cycle1 + 3] then
                  PUT stream PrnLibStream UNFORMATTED
                  grp-h.sum[cycle1]     p-XL-delim.
              end.
              PUT stream PrnLibStream UNFORMATTED
              tot-by-grp p-XL-delim
              .
              PUT stream PrnLibStream UNFORMATTED
              (if method = "pays":U
              then "число_платежей"
              else "пробито_чеков")      p-XL-delim.
              do cycle1 = 1 to 24.
                if use-column[cycle1 + 3] then
                  PUT stream PrnLibStream UNFORMATTED
                  grp-h.num-chk[cycle1]     p-XL-delim.
              end.
              PUT stream PrnLibStream UNFORMATTED
              tot-nc-by-grp p-XL-delim
              SKIP .
            end.
            assign
            accum-num-chk[1] = accum-num-chk[1] + grp-h.num-chk[1]
            accum-num-chk[2] = accum-num-chk[2] + grp-h.num-chk[2]
            accum-num-chk[3] = accum-num-chk[3] + grp-h.num-chk[3]
            accum-num-chk[4] = accum-num-chk[4] + grp-h.num-chk[4]
            accum-num-chk[5] = accum-num-chk[5] + grp-h.num-chk[5]
            accum-num-chk[6] = accum-num-chk[6] + grp-h.num-chk[6]
            accum-num-chk[7] = accum-num-chk[7] + grp-h.num-chk[7]
            accum-num-chk[8] = accum-num-chk[8] + grp-h.num-chk[8]
            accum-num-chk[9] = accum-num-chk[9] + grp-h.num-chk[9]
            accum-num-chk[10] = accum-num-chk[10] + grp-h.num-chk[10]
            accum-num-chk[11] = accum-num-chk[11] + grp-h.num-chk[11]
            accum-num-chk[12] = accum-num-chk[12] + grp-h.num-chk[12]
            accum-num-chk[13] = accum-num-chk[13] + grp-h.num-chk[13]
            accum-num-chk[14] = accum-num-chk[14] + grp-h.num-chk[14]
            accum-num-chk[15] = accum-num-chk[15] + grp-h.num-chk[15]
            accum-num-chk[16] = accum-num-chk[16] + grp-h.num-chk[16]
            accum-num-chk[17] = accum-num-chk[17] + grp-h.num-chk[17]
            accum-num-chk[18] = accum-num-chk[18] + grp-h.num-chk[18]
            accum-num-chk[19] = accum-num-chk[19] + grp-h.num-chk[19]
            accum-num-chk[20] = accum-num-chk[20] + grp-h.num-chk[20]
            accum-num-chk[21] = accum-num-chk[21] + grp-h.num-chk[21]
            accum-num-chk[22] = accum-num-chk[22] + grp-h.num-chk[22]
            accum-num-chk[23] = accum-num-chk[23] + grp-h.num-chk[23]
            accum-num-chk[24] = accum-num-chk[24] + grp-h.num-chk[24]
            accum-tot-nc-by-grp = accum-tot-nc-by-grp + tot-nc-by-grp
            .
          end.
          else do:
            PUT stream PrnLibStream UNFORMATTED
            full-grp.full-name p-XL-delim
            (if With-Goods then p-XL-delim else "").
            do cycle1 = 1 to 24.
              if use-column[cycle1 + 3] then
                PUT stream PrnLibStream UNFORMATTED
                grp-h.sum[cycle1]     p-XL-delim.
            end.
            PUT stream PrnLibStream UNFORMATTED
            tot-by-grp
            SKIP .
          end.
          if With-Goods then do:
            FOR EACH gds-h WHERE
                    gds-h.obj-code = grp-h.obj-code
                AND gds-h.grp-code = grp-h.grp-code
                    use-index uu BREAK BY gds-h.uniq :
              if first-of( gds-h.uniq ) then do:
                PUT stream PrnLibStream UNFORMATTED
                string( gds-h.artic, "x(16)" )  p-XL-delim
                replace(gds-h.gds-name, " " , "_" ) p-XL-delim.
                do cycle1 = 1 to 24.
                  if use-column[cycle1 + 3] then
                    PUT stream PrnLibStream UNFORMATTED
                    gds-h.sum[cycle1]     p-XL-delim.
                end.
                PUT stream PrnLibStream UNFORMATTED
                SKIP.
              end.
            END .
          end.
          ASSIGN
          accum-sum[1] = accum-sum[1] + grp-h.sum[1]
          accum-sum[2] = accum-sum[2] + grp-h.sum[2]
          accum-sum[3] = accum-sum[3] + grp-h.sum[3]
          accum-sum[4] = accum-sum[4] + grp-h.sum[4]
          accum-sum[5] = accum-sum[5] + grp-h.sum[5]
          accum-sum[6] = accum-sum[6] + grp-h.sum[6]
          accum-sum[7] = accum-sum[7] + grp-h.sum[7]
          accum-sum[8] = accum-sum[8] + grp-h.sum[8]
          accum-sum[9] = accum-sum[9] + grp-h.sum[9]
          accum-sum[10] = accum-sum[10] + grp-h.sum[10]
          accum-sum[11] = accum-sum[11] + grp-h.sum[11]
          accum-sum[12] = accum-sum[12] + grp-h.sum[12]
          accum-sum[13] = accum-sum[13] + grp-h.sum[13]
          accum-sum[14] = accum-sum[14] + grp-h.sum[14]
          accum-sum[15] = accum-sum[15] + grp-h.sum[15]
          accum-sum[16] = accum-sum[16] + grp-h.sum[16]
          accum-sum[17] = accum-sum[17] + grp-h.sum[17]
          accum-sum[18] = accum-sum[18] + grp-h.sum[18]
          accum-sum[19] = accum-sum[19] + grp-h.sum[19]
          accum-sum[20] = accum-sum[20] + grp-h.sum[20]
          accum-sum[21] = accum-sum[21] + grp-h.sum[21]
          accum-sum[22] = accum-sum[22] + grp-h.sum[22]
          accum-sum[23] = accum-sum[23] + grp-h.sum[23]
          accum-sum[24] = accum-sum[24] + grp-h.sum[24]
          accum-tot-by-grp = accum-tot-by-grp + tot-by-grp
          .
        end.
      END .
    CASE method:
      when "pay-desk":U then do:
        PUT stream PrnLibStream UNFORMATTED
        substitute("ИТОГО_&1_по_всем_кассам", v-obj-name)
        p-XL-delim
        .
      end.
      when "GROUPS":U then do:
        PUT stream PrnLibStream UNFORMATTED
        substitute("ИТОГО_&1_по_всем_группам", v-obj-name)
        p-XL-delim
        .
      end.
      when "pays":U then do:
        PUT stream PrnLibStream UNFORMATTED
        substitute("ИТОГО_&1_по_всем_платежам", v-obj-name)
        p-XL-delim
        .
      end.
      otherwise do:
        PUT stream PrnLibStream UNFORMATTED
        substitute("ИТОГО_&1_по_всем_платежам", v-obj-name) p-xl-delim
        p-XL-delim
        .
      end.
    END.
    do cycle1 = 1 to 24.
      if use-column[cycle1 + 3] then
        PUT stream PrnLibStream UNFORMATTED
        ACCUM-sum[cycle1]     p-XL-delim.
    end.
    PUT stream PrnLibStream UNFORMATTED
      ACCUM-tot-by-grp            .
      IF method = "pay-desk":U or method = "pays":U then do:
        PUT stream PrnLibStream  UNFORMATTED p-XL-delim.
      end.
      else do:
        PUT stream PrnLibStream  UNFORMATTED SKIP .
      end.
      IF method = "pay-desk":U
      or method = "pays" then do:
        PUT stream PrnLibStream UNFORMATTED
        (if method = "pay-desk":U
        then "пробито_чеков"
        else "количество_платежей")      p-XL-delim.
        do cycle1 = 1 to 24.
          if use-column[cycle1 + 3] then
            PUT stream PrnLibStream UNFORMATTED
            ACCUM-num-chk[cycle1]     p-XL-delim.
        end.
        PUT stream PrnLibStream UNFORMATTED
        ACCUM-tot-nc-by-grp format ">>>>>9" p-XL-delim
        SKIP .
      end.
      if cycle = 0 then LEAVE _obj-list2.
    end.
  end.
END.
output stream PrnLibStream CLOSE .
