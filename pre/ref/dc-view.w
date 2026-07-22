DEFINE TEMP-TABLE hrtt-dis-card NO-UNDO LIKE ub.dis-card.
DEFINE TEMP-TABLE htt-dis-card NO-UNDO LIKE ub.dis-card.
DEFINE TEMP-TABLE rtt-dis-card NO-UNDO LIKE ub.dis-card.
DEFINE BUFFER r_dis-host FOR ub.dis-host.
DEFINE BUFFER r_dis-obj FOR ub.dis-obj.
DEFINE BUFFER r_shop FOR ub.shop.
DEFINE BUFFER r_sysconf FOR ub.sysconf.
DEFINE TEMP-TABLE tt-dis-card NO-UNDO LIKE ub.dis-card.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter inp-d-card like ub.dis-card.d-card no-undo .
define input parameter p-legacy as logical no-undo .
define input parameter p-subsid as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Итоги по дисконтным картам" .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dcard-algo-field-name as character no-undo extent 3 init [
 'd-pcnt':U
,'cash-d-pcnt':U
,'pcnt-kat':U].
define variable algo-field-abbr as character no-undo extent 3 init [
 'ITEM%':U
,'TOTAL%':U
,'CATEG':U].
FUNCTION dct-algo-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + chr(47) +
             string(Month(p-date), "99":U) + chr(47) +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
function dct-algo-string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION dct-algo-get-sum-id-from-DT-CODE returns character ( input p-DT-CODE as integer):
define buffer buf_prop-ref for ub.prop-ref.
find first buf_prop-ref no-lock where
          buf_prop-ref.DT-CODE = p-DT-CODE no-error.
if not available buf_prop-ref then do:
  return chr(63).
end.
return buf_prop-ref.sum-id.
END FUNCTION.
FUNCTION dct-algo-get-description-sum-id returns character ( input p-dt-code as integer):
define variable v-des as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
find first buf_prop-ref no-lock where
          buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then do:
  return substitute("Срез/итог по ДК c кодом &1 - срез не найден", p-dt-code).
end.
find first buf_prop-head no-lock where
        buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error.
if not available buf_prop-head then do:
  return substitute("Срез/итог по ДК &1 c кодом &2 - неизвестное", p-dt-code, buf_prop-ref.dtm-code).
end.
assign
v-des = substitute("&1  &2 &3"
                  , buf_prop-head.prop-name
                  , buf_prop-ref.sum-id
                  , buf_prop-ref.caller_id).
return v-des.
end FUNCTION.
FUNCTION dct-algo-get-description-node-code returns character ( input p-dtm-code as integer
                                                            ,input p-dt-code as integer
                                                            ,input p-node-code as integer
                                                            ):
define variable v-des as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-map for ub.prop-map.
find first buf_prop-ref no-lock where
          buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then do:
  return substitute("Срез/итог по ДК c кодом &1 - срез не найден", p-dt-code).
end.
find first buf_prop-head no-lock where
        buf_prop-head.dtm-code = p-dtm-code no-error.
if not available buf_prop-head then do:
  return substitute("Срез/итог по ДК &1 c кодом &2 - неизвестное", p-dt-code, p-dtm-code).
end.
find first buf_prop-map no-lock where
        buf_prop-map.dtm-code = p-dtm-code
    and buf_prop-map.node-code = p-node-code no-error .
if not available buf_prop-map then do:
  return substitute("Срез/итог по ДК &1, &2.&3 - неизвестно"
                    , p-dt-code
                    , buf_prop-head.prop-label
                    , p-node-code).
end.
assign
v-des = substitute("&1.&2 &3 &4"
                  , buf_prop-head.prop-label
                  , buf_prop-map.node-label
                  , buf_prop-ref.sum-id
                  , buf_prop-ref.caller_id).
return v-des.
end FUNCTION.
function dct-algo-get-prev-sum-id RETURNS integer (
                                                    input p-dt-code as integer
                                                   ):
define variable v-dtm-code as integer no-undo .
define variable v-sum-id as character no-undo .
define variable v-caller-id as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
find first buf_prop-ref no-lock where
        buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then return ?.
assign
v-dtm-code = buf_prop-ref.dtm-code
v-sum-id = buf_prop-ref.sum-id.
v-caller-id = buf_prop-ref.caller_id.
find last buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = v-dtm-code
     and  buf_prop-ref.sum-id < v-sum-id
     and  buf_prop-ref.caller_id = v-caller-id
     no-error.
if available buf_prop-ref then return buf_prop-ref.dt-code.
return -1 .
END FUNCTION.
FUNCTION dct-algo-get_dcproperty-value returns logical (
                                                          input p-prop-name as character
                                                        , input p-d-card    as character
                                                        , input p-host-code as integer
                                                        , input p-obj-type  as character
                                                        , input p-obj-code  as integer
                                                        , output p-value-character as character
                                                        , output p-value-date   as date
                                                        , output p-value-integer as integer
                                                        , output p-value-decimal as decimal
                                                        , output p-value-logical as logical):
  return no.
END FUNCTION.
FUNCTION dct-algo-get_dcproperty-value-chr returns logical (
                                                          input p-d-card    as character
                                                        , input p-emitent-host-code as integer
                                                        , input p-type as character
                                                        , input p-host-code as integer
                                                        , input p-obj-type  as character
                                                        , input p-obj-code  as integer
                                                        , output p-value-chr as character):
define variable v-dt-code as integer no-undo .
define variable v-node-code as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-storage-place as character no-undo .
define variable v-sum-id-value as character no-undo .
define variable v-sum-id-output as logical no-undo .
define variable v-value-chr as character no-undo .
define variable v-ii as integer no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_dis-obj for ub.dis-obj.
run get-cd-sumid in this-procedure (
                                      input p-emitent-host-code
                                     ,input p-type
                                     ,input p-host-code
                                     ,input p-obj-type
                                     ,input p-obj-code
                                     ,output v-sum-id-value
                                     ,output v-sum-id-output
                                    ) no-error.
if not v-sum-id-output then do:
  return no.
end.
do v-ii = 1 to num-entries(v-sum-id-value):
  assign
  v-storage-place = entry(1, entry(v-ii, v-sum-id-value), chr(4))
  v-dt-code = integer(entry(2, entry(v-ii, v-sum-id-value), chr(4)))
  v-node-code = integer(entry(3, entry(v-ii, v-sum-id-value), chr(4)))
  v-field-name = entry(4, entry(v-ii, v-sum-id-value), chr(4))
  no-error .
  if not error-status:error then do:
    case v-storage-place:
      when 'dis-card-property':U then do:
        find first buf_dis-card-property no-lock where
                  buf_dis-card-property.d-card = p-d-card
            and  buf_dis-card-property.host-code = p-host-code
            and  buf_dis-card-property.obj-type = p-obj-type
            and  buf_dis-card-property.obj-code = p-obj-code
            and  buf_dis-card-property.dt-code = v-dt-code
            and  buf_dis-card-property.node-code = v-node-code no-error .
        if available buf_dis-card-property then do:
          v-value-chr = buffer buf_dis-card-property:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
      when 'dis-obj':U then do:
        find first buf_dis-obj no-lock where
                  buf_dis-obj.d-card = p-d-card
            and  buf_dis-obj.obj-type = p-obj-type
            and  buf_dis-obj.obj-code = p-obj-code
            and  buf_dis-obj.dt-code = v-dt-code no-error .
        if available buf_dis-obj then do:
          v-value-chr = buffer buf_dis-obj:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
      when 'dis-host':U then do:
        find first buf_dis-host no-lock where
                  buf_dis-host.d-card = p-d-card
            and  buf_dis-host.host-code = p-host-code
            and  buf_dis-host.dt-code = v-dt-code no-error .
        if available buf_dis-host then do:
          v-value-chr = buffer buf_dis-host:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
    end.
  end.
  p-value-chr = p-value-chr + (if v-ii = 1 then '':U else chr(44)) + v-value-chr.
end.
END FUNCTION.
FUNCTION dct-algo_custom-sent-description RETURNS CHARACTER
  ( INPUT p-custom-sent as character ) :
DEFINE VARIABLE v-storage-place AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dtm-code AS integer NO-UNDO.
DEFINE VARIABLE v-sum-id AS character NO-UNDO.
DEFINE VARIABLE v-caller-id AS character NO-UNDO.
DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-sum-id-description AS CHARACTER.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
IF p-custom-sent = chr(63) THEN RETURN "Не отсылать".
assign
v-storage-place = entry(1, p-custom-sent, chr(4))
v-dtm-code = integer(entry(2, p-custom-sent, chr(4)))
v-sum-id   = entry(3, p-custom-sent, chr(4))
v-caller-id = entry(4, p-custom-sent, chr(4))
v-node-code = integer(entry(5, p-custom-sent, chr(4)))
no-error .
IF ERROR-STATUS:ERROR THEN DO:
  MESSAGE
  "Не могу разобрать строку, описывающую итог"
   VIEW-AS ALERT-BOX WARNING.
  RETURN chr(63).
END.
FIND FIRST buf_prop-ref NO-LOCK WHERE
          buf_prop-ref.dtm-code = v-dtm-code
     AND  buf_prop-ref.sum-id = v-sum-id
     AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
IF NOT AVAILABLE buf_prop-ref THEN DO:
  FIND FIRST buf_prop-ref NO-LOCK WHERE
            buf_prop-ref.dtm-code = v-dtm-code
      AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
  IF NOT AVAILABLE buf_prop-ref THEN DO:
      MESSAGE
      "Не могу разобрать строку, описывающую итог"
       VIEW-AS ALERT-BOX WARNING.
      RETURN chr(63).
   end.
end.
ASSIGN
v-sum-id-description =  dct-algo-get-description-node-code ( v-dtm-code
                                                       ,buf_prop-ref.dt-code
                                                       ,v-node-code).
RETURN v-sum-id-description.
END FUNCTION.
FUNCTION one-base-cur-for-objs  returns logical (output p-glob-curr-code as integer):
define variable v-glob-val as logical no-undo init yes.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
assign
p-glob-curr-code =  -1
.
FOR EACH buf_sysconf NO-LOCK,
    first buf_clients no-lock where
         buf_clients.host-code = buf_sysconf.host-code:
    if p-glob-curr-code = -1 then
    assign
    p-glob-curr-code = buf_sysconf.base-code
    .
    else if p-glob-curr-code <> buf_sysconf.base-code then do:
        assign
        v-glob-val = no
        p-glob-curr-code = ?
        .
        LEAVE.
    end.
END.
return v-glob-val.
END FUNCTION.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function dc-smart_is-this-correct RETURNS CHARACTER
  ( INPUT p-dt-code AS INTEGER
  , INPUT p-table-name AS CHARACTER
  , INPUT p-db-num AS INTEGER
  , INPUT p-type AS CHARACTER
  , INPUT p-emitent-host-code AS INTEGER
  , INPUT p-obj-type AS CHARACTER
   ,input p-obj-code AS INTEGER
   ,INPUT p-d-card AS CHARACTER
    ) :
define VARIABLE v-dtm-code AS INTEGER NO-UNDO.
define VARIABLE v-smart-nws AS INTEGER NO-UNDO.
define VARIABLE v-obj-db-num AS INTEGER NO-UNDO INIT -1.
DEFINE BUFFER buf_dis-obj FOR ub.dis-obj.
DEFINE BUFFER buf_hist-nws-option FOR ub.hist-nws-option.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
DEFINE BUFFER buf_clients FOR ub.clients.
IF p-db-num = 0 THEN  RETURN "+".
IF p-table-name = 'dis-obj':U THEN DO:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  ) NO-ERROR .
  IF v-obj-db-num = p-db-num THEN RETURN "+".
END.
IF p-dt-code = 0 THEN DO:
  v-dtm-code = 1.
END.
ELSE DO:
   FIND FIRST buf_prop-ref NO-LOCK WHERE
            buf_prop-ref.dt-code = p-dt-code NO-ERROR.
  IF AVAILABLE buf_prop-ref  THEN DO:
    v-dtm-code = buf_prop-ref.dtm-code.
  END.
END.
find first buf_HIST-NWS-OPTION WHERE
      buf_HIST-NWS-OPTION.db-num = 0
      and buf_hist-nws-option.table-name = p-table-name
      and buf_hist-nws-option.host-code = p-emitent-host-code
      and buf_hist-nws-option.obj-type = '':U
      and buf_hist-nws-option.obj-code = 0
      and buf_hist-nws-option.key#_one = 1
      and buf_hist-nws-option.charkey_one = p-type
      and buf_hist-nws-option.subject-group = 'c-dc-hist':U NO-ERROR.
IF NOT AVAILABLE buf_hist-nws-option THEN v-smart-nws = -1.
ELSE v-smart-nws = buf_hist-nws-option.smart-nws .
IF v-smart-nws = INTEGER('0':U) THEN DO:
  FOR EACH buf_dis-obj NO-LOCK WHERE
           buf_Dis-obj.d-card = p-d-card,
      FIRST buf_clients NO-LOCK WHERE
          buf_Clients.obj-type = buf_dis-obj.obj-type
       AND buf_clients.obj-code = buf_dis-obj.obj-code
      AND buf_clients.db-num =  p-db-num:
     LEAVE.
  END.
  IF AVAILABLE buf_dis-obj THEN RETURN "+".
  RETURN "-".
END.
IF v-smart-nws = INTEGER('1':U) THEN RETURN "-".
RETURN "+".
END FUNCTION.
define variable LogRes as logical no-undo .
define buffer for-dis for ub.dis-obj.
define variable max-pay-sum like ub.dis-obj.pay-tot-base.
define variable TotalPayPrim as decimal no-undo.
define variable CreditSumPrim as decimal no-undo.
define variable TotalSumPrim as decimal no-undo.
define variable DiscSumPrim as decimal no-undo.
define variable NettoSumPrim as decimal no-undo.
define variable MustPayPrim as decimal no-undo.
define variable SaldosumPrim as decimal no-undo.
define variable RestLimitPrim as decimal no-undo.
define variable LimitSumPrim as decimal no-undo.
define variable globalcard as logical no-undo.
define variable sort-column-name as character no-undo .
define variable rid as recid no-undo.
define variable glob-val as logical no-undo init yes.
define variable v-glob-curr-code like ub.currency.curr-code no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-first as logical no-undo init yes.
define variable vhb as character no-undo .
define variable vhr as character NO-UNDO .
define variable vob as character no-undo .
define variable vor as character no-undo .
DEFINE VARIABLE v-ok-dis-obj AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ok-rdis-obj AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ok-dis-host AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ok-rdis-host AS CHARACTER NO-UNDO.
define buffer current_dis-card for ub.dis-card.
DEFINE BUTTON B-chk
     LABEL "Че&ки"
     SIZE 10 BY 1.
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1.
DEFINE BUTTON b-history
     LABEL "Ис&тория"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_Cost
     LABEL "&Учет"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE CreditSum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE DiscSum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE f-smart-info-sums AS CHARACTER FORMAT "X(256)":U INITIAL "Нет маршрутизации:данные м.б. некорректны!!!!"
      VIEW-AS TEXT
     SIZE 46.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE LimitSum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE lNumCard AS CHARACTER FORMAT "X(256)":U INITIAL "Карт с учетом перевыпуска"
      VIEW-AS TEXT
     SIZE 27.3 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE Mustpay AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE NettoSum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .7
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE NumCard AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 6.8 BY .67
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE NumChk AS INTEGER FORMAT "->>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 8 BY .67
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE RestLimit AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE SaldoSum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE TotalPay AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .7
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE TotalSum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99" INITIAL 0
      VIEW-AS TEXT
     SIZE 19 BY .67
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE val-title AS CHARACTER FORMAT "X(256)":U INITIAL "ИТОГО по карте (данные офиса)"
      VIEW-AS TEXT
     SIZE 29.4 BY .67 NO-UNDO.
DEFINE VARIABLE Rs-gen-private AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Общие", 0,
"Частные", 1
     SIZE 18 BY .67 NO-UNDO.
DEFINE VARIABLE rs-host-obj AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Объекты", "obj",
"Фирмы", "host"
     SIZE 18 BY .67 NO-UNDO.
DEFINE VARIABLE SelectCurr AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "abbr_rubli_firstshift", "rubl",
"Баз.вал.", "base"
     SIZE 25.8 BY .63 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 7.33
     BGCOLOR 8 FGCOLOR 0 .
DEFINE VARIABLE T-legacy AS LOGICAL INITIAL no
     LABEL "Перевыпуск"
     VIEW-AS TOGGLE-BOX
     SIZE 12.5 BY .97 TOOLTIP "С учетом перевыпуска карт" NO-UNDO.
DEFINE VARIABLE T-subsid AS LOGICAL INITIAL no
     LABEL "Дополнит-ные"
     VIEW-AS TOGGLE-BOX
     SIZE 15.5 BY .97 TOOLTIP "С учетом дополнительных карт" NO-UNDO.
DEFINE QUERY BR-dis-host-b FOR
      htt-dis-card,
      ub.dis-host,
      ub.sysconf SCROLLING.
DEFINE QUERY BR-dis-host-r FOR
      hrtt-dis-card,
      r_dis-host,
      r_sysconf SCROLLING.
DEFINE QUERY BR-dis-obj-b FOR
      tt-dis-card,
      ub.dis-obj,
      ub.shop SCROLLING.
DEFINE QUERY BR-dis-obj-r FOR
      rtt-dis-card,
      r_dis-obj,
      r_shop SCROLLING.
DEFINE BROWSE BR-dis-host-b
  QUERY BR-dis-host-b NO-LOCK DISPLAY
      dc-smart_is-this-correct( INPUT dis-host.dt-code
                      ,INPUT 'dis-host':U
                      ,INPUT v-cntxt-db-num
                      ,INPUT htt-dis-card.TYPE
                       ,INPUT htt-dis-card.emitent-host-code
                       ,INPUT 'орг':U
                       ,INPUT dis-host.host-code
                       ,INPUT htt-dis-card.d-card)
      @ v-ok-dis-host COLUMN-LABEL "OK" FORMAT "X(1)"
      dis-host.host-code COLUMN-LABEL "Фирма" FORMAT "99999"
      dct-algo-get-sum-id-from-dt-code(INPUT dis-host.dt-code) @ vhb COLUMN-LABEL "ЧАСТНЫЙ ИТОГ" FORMAT "X(32)"
      dis-host.gds-tot-base COLUMN-LABEL "Сумма товарная" format "->>,>>>,>>>,>>>,>>9.99"
      dis-host.gds-dis-base COLUMN-LABEL "Скидка товарная" format "->>,>>>,>>>,>>>,>>9.99"
      dis-host.gds-tot-base  - dis-host.gds-dis-base COLUMN-LABEL "Сумма нетто" FORMAT "->>,>>>,>>>,>>>,>>>.<<"
      dis-host.num-chk COLUMN-LABEL "Число!чеков" format "->>>>>9"
      dis-host.gds-tot-base  - dis-host.gds-dis-base  - dis-host.pay-tot-base COLUMN-LABEL "Сумма в кредит" FORMAT "->>,>>>,>>>,>>>,>>>.<<"
      dis-host.d-card COLUMN-LABEL "Дисконтная карта" format "X(16)"
   ENABLE
      dis-host.num-chk
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.63
         BGCOLOR 15
         TITLE BGCOLOR 15 "В баз. вал.".
DEFINE BROWSE BR-dis-host-r
  QUERY BR-dis-host-r NO-LOCK DISPLAY
      dc-smart_is-this-correct( INPUT r_dis-host.dt-code
                      ,INPUT 'dis-host':U
                      ,INPUT v-cntxt-db-num
                      ,INPUT hrtt-dis-card.TYPE
                       ,INPUT hrtt-dis-card.emitent-host-code
                       ,INPUT 'орг':U
                       ,INPUT r_dis-host.host-code
                       ,INPUT hrtt-dis-card.d-card)
      @ v-ok-rdis-host COLUMN-LABEL "OK" FORMAT "X(1)"
      r_dis-host.host-code COLUMN-LABEL "Фирма" FORMAT "99999"
      dct-algo-get-sum-id-from-dt-code(INPUT r_dis-host.dt-code) @ vhr COLUMN-LABEL "ЧАСТНЫЙ ИТОГ" FORMAT "X(32)"
      r_dis-host.gds-tot-rubl COLUMN-LABEL "Сумма товарная" format "->>,>>>,>>>,>>>,>>9.99"
      r_dis-host.gds-dis-rubl COLUMN-LABEL "Скидка товарная" format "->>,>>>,>>>,>>>,>>9.99"
      r_dis-host.gds-tot-rubl  - r_dis-host.gds-dis-rubl COLUMN-LABEL "Сумма нетто" FORMAT "->>,>>>,>>>,>>>,>>>.<<"
      r_dis-host.num-chk COLUMN-LABEL "Число!чеков" format "->>>>>9"
      r_dis-host.gds-tot-rubl - r_dis-host.gds-dis-rubl - r_dis-host.pay-tot-rubl COLUMN-LABEL "Сумма в кредит" FORMAT "->>,>>>,>>>,>>>,>>>.<<"
      r_dis-host.d-card COLUMN-LABEL "Дисконтная карта" format "X(16)"
  ENABLE
      r_dis-host.num-chk
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.63
         BGCOLOR 15 FGCOLOR 0
         TITLE BGCOLOR 15 FGCOLOR 0 "В abbr_rublyah".
DEFINE BROWSE BR-dis-obj-b
  QUERY BR-dis-obj-b NO-LOCK DISPLAY
      dc-smart_is-this-correct( INPUT ub.dis-obj.dt-code
                      ,INPUT 'dis-obj':U
                      ,INPUT v-cntxt-db-num
                      ,INPUT tt-dis-card.TYPE
                       ,INPUT tt-dis-card.emitent-host-code
                       ,INPUT ub.dis-obj.obj-type
                       ,INPUT ub.dis-obj.obj-code
                       ,INPUT tt-dis-card.d-card)
      @ v-ok-dis-obj COLUMN-LABEL "OK" FORMAT "X(1)"
      ub.dis-obj.obj-code COLUMN-LABEL "Магазин" FORMAT ">>>>9"
      dct-algo-get-sum-id-from-dt-code(INPUT ub.dis-obj.dt-code) @ vob COLUMN-LABEL "ЧАСТНЫЙ ИТОГ" FORMAT "X(32)"
      ub.dis-obj.gds-tot-base COLUMN-LABEL "Сумма товарная"  format "->>,>>>,>>>,>>>,>>9.99"
      ub.dis-obj.gds-dis-base COLUMN-LABEL "Скидка товарная" format "->>,>>>,>>>,>>>,>>9.99"
      ub.dis-obj.gds-tot-base + ub.dis-obj.sum-tot-base - ub.dis-obj.gds-dis-base - ub.dis-obj.sum-dis-base COLUMN-LABEL "Сумма нетто" FORMAT "->>,>>>,>>>,>>>,>>9.99"
      ub.dis-obj.num-chk COLUMN-LABEL "Число!чеков" format "->>>>>9"
      ub.dis-obj.gds-tot-base - ub.dis-obj.gds-dis-base + ub.dis-obj.sum-tot-base - ub.dis-obj.sum-dis-base - ub.dis-obj.pay-tot-base COLUMN-LABEL "Сумма в кредит" FORMAT "->>,>>>,>>>,>>>,>>9.99"
      ub.dis-obj.d-card COLUMN-LABEL "Дисконтная карта" format "X(16)"
   ENABLE
      ub.dis-obj.num-chk
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.63
         BGCOLOR 15 FGCOLOR 0
         TITLE BGCOLOR 15 FGCOLOR 0 "В баз. вал.".
DEFINE BROWSE BR-dis-obj-r
  QUERY BR-dis-obj-r NO-LOCK DISPLAY
      dc-smart_is-this-correct( INPUT r_dis-obj.dt-code
                      ,INPUT 'dis-obj':U
                      ,INPUT v-cntxt-db-num
                      ,INPUT rtt-dis-card.TYPE
                      ,INPUT rtt-dis-card.emitent-host-code
                      ,INPUT r_dis-obj.obj-type
                      ,INPUT r_dis-obj.obj-code
                      ,INPUT rtt-dis-card.d-card)
      @ v-ok-rdis-obj COLUMN-LABEL "OK" FORMAT "X(1)"
      r_dis-obj.obj-code COLUMN-LABEL "Магазин" FORMAT "99999"
      dct-algo-get-sum-id-from-dt-code(INPUT r_dis-obj.dt-code) @ vor COLUMN-LABEL "ЧАСТНЫЙ ИТОГ" FORMAT "X(32)"
      r_dis-obj.gds-tot-rubl COLUMN-LABEL "Сумма товарная" format "->>,>>>,>>>,>>>,>>9.99"
      r_dis-obj.gds-dis-rubl COLUMN-LABEL "Скидка товарная" format "->>,>>>,>>>,>>>,>>9.99"
      r_dis-obj.gds-tot-rubl + r_dis-obj.sum-tot-rubl - r_dis-obj.gds-dis-rubl - r_dis-obj.sum-dis-rubl COLUMN-LABEL "Сумма нетто" FORMAT "->>,>>>,>>>,>>>,>>>.<<"
      r_dis-obj.num-chk COLUMN-LABEL "Число!чеков" format "->>>>>9"
      r_dis-obj.gds-tot-rubl + r_dis-obj.sum-tot-rubl - r_dis-obj.gds-dis-rubl - r_dis-obj.sum-dis-rubl - r_dis-obj.pay-tot-rubl COLUMN-LABEL "Сумма в кредит" FORMAT "->>,>>>,>>>,>>>,>>>.<<"
      r_dis-obj.d-card COLUMN-LABEL "Дисконтная карта" format "X(16)"
      ENABLE
      r_dis-obj.num-chk
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.63
         BGCOLOR 15 FGCOLOR 0
         TITLE BGCOLOR 15 FGCOLOR 0 "В abbr_rublyah".
DEFINE FRAME d-disc
     Btn_Cancel AT ROW 1 COL 1
     B-chk AT ROW 1 COL 21
     Btn_Cost AT ROW 1 COL 31
     B-print AT ROW 1 COL 89
     b-history AT ROW 1 COL 92
     B-help AT ROW 1 COL 95
     T-legacy AT ROW 2.33 COL 71
     T-subsid AT ROW 2.33 COL 84
     SelectCurr AT ROW 2.5 COL 1 NO-LABEL
     Rs-gen-private AT ROW 2.5 COL 32 NO-LABEL
     rs-host-obj AT ROW 2.5 COL 53 NO-LABEL
     BR-dis-obj-r AT ROW 3.5 COL 1
     BR-dis-obj-b AT ROW 3.5 COL 1
     BR-dis-host-r AT ROW 3.5 COL 1
     BR-dis-host-b AT ROW 3.5 COL 1
     f-smart-info-sums AT ROW 12.2 COL 46.5 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     val-title AT ROW 12.33 COL 4 COLON-ALIGNED NO-LABEL
     TotalSum AT ROW 13.13 COL 38.5 RIGHT-ALIGNED NO-LABEL
     lNumCard AT ROW 13.87 COL 60.9 COLON-ALIGNED NO-LABEL
     NumCard AT ROW 13.93 COL 98.1 RIGHT-ALIGNED NO-LABEL
     NumChk AT ROW 13.97 COL 61 RIGHT-ALIGNED NO-LABEL
     DiscSum AT ROW 14.17 COL 38.5 RIGHT-ALIGNED NO-LABEL
     NettoSum AT ROW 15.3 COL 38.4 RIGHT-ALIGNED NO-LABEL
     SaldoSum AT ROW 16.47 COL 76.1 RIGHT-ALIGNED NO-LABEL
     TotalPay AT ROW 16.67 COL 38.5 RIGHT-ALIGNED NO-LABEL
     Mustpay AT ROW 17.77 COL 76.1 RIGHT-ALIGNED NO-LABEL
     CreditSum AT ROW 17.93 COL 38.4 RIGHT-ALIGNED NO-LABEL
     RestLimit AT ROW 18.93 COL 76.1 RIGHT-ALIGNED NO-LABEL
     LimitSum AT ROW 18.97 COL 38.4 RIGHT-ALIGNED NO-LABEL
     "Чеков" VIEW-AS TEXT
          SIZE 6 BY 1 AT ROW 13.7 COL 43.9
          BGCOLOR 8 FGCOLOR 1
     "Лимит кредита" VIEW-AS TEXT
          SIZE 15.5 BY .83 AT ROW 18.93 COL 2.8
          BGCOLOR 8 FGCOLOR 1
     "Cумма к оплате" VIEW-AS TEXT
          SIZE 15.5 BY 1 AT ROW 17.63 COL 40.4
          BGCOLOR 8 FGCOLOR 1
     "Сумма скидок" VIEW-AS TEXT
          SIZE 13.3 BY 1 AT ROW 14.07 COL 2.9
          BGCOLOR 8 FGCOLOR 1
     "Cумма в кредит" VIEW-AS TEXT
          SIZE 15.5 BY 1 AT ROW 17.63 COL 2.8
          BGCOLOR 8 FGCOLOR 1
     "Сумма оплат" VIEW-AS TEXT
          SIZE 13.3 BY 1 AT ROW 16.53 COL 2.9
          BGCOLOR 8 FGCOLOR 1
     "Остаток лимита" VIEW-AS TEXT
          SIZE 15.5 BY .83 AT ROW 18.93 COL 40.4
          BGCOLOR 8 FGCOLOR 1
     "Баланс карты" VIEW-AS TEXT
          SIZE 15.5 BY 1 AT ROW 16.33 COL 40.4
          BGCOLOR 8 FGCOLOR 1
     "Сумма покупок" VIEW-AS TEXT
          SIZE 13.3 BY 1 AT ROW 12.93 COL 2.8
          BGCOLOR 8 FGCOLOR 1
     "Сумма нетто" VIEW-AS TEXT
          SIZE 13.3 BY 1 AT ROW 15.27 COL 2.8
          BGCOLOR 8 FGCOLOR 1
     RECT-1 AT ROW 12.53 COL 1.4
     SPACE(0.33) SKIP(0.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE "Архивы по магазинам текущей фирмы"
         DEFAULT-BUTTON Btn_Cancel CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME d-disc:SCROLLABLE       = FALSE
       FRAME d-disc:HIDDEN           = TRUE.
ASSIGN
       BR-dis-host-b:HIDDEN  IN FRAME d-disc                = TRUE
       BR-dis-host-b:NUM-LOCKED-COLUMNS IN FRAME d-disc     = 1.
ASSIGN
       BR-dis-host-r:NUM-LOCKED-COLUMNS IN FRAME d-disc     = 1.
ASSIGN
       BR-dis-obj-b:HIDDEN  IN FRAME d-disc                = TRUE
       BR-dis-obj-b:NUM-LOCKED-COLUMNS IN FRAME d-disc     = 1.
ASSIGN
       BR-dis-obj-r:NUM-LOCKED-COLUMNS IN FRAME d-disc     = 1.
ASSIGN
       Btn_Cost:HIDDEN IN FRAME d-disc           = TRUE.
ASSIGN
       f-smart-info-sums:HIDDEN IN FRAME d-disc           = TRUE.
ON WINDOW-CLOSE OF FRAME d-disc
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-chk IN FRAME d-disc
DO:
    DEFINE VARIABLE varrid-list as character no-undo .
    if available ub.dis-obj THEN  do:
        run str/chk-docs.w (
                        input parparentproc
                       ,input '':U
                       ,input "d-card":U
                       ,input ?
                       ,input (if selectcurr = 'base':U then dis-obj.obj-type else r_dis-obj.obj-type)
                       ,input  (if selectcurr = 'base':U then dis-obj.obj-code else r_dis-obj.obj-code)
                       ,input '':U
                       ,input (if selectcurr = 'base':U then entry(1, dis-obj.d-card, chr(4)) else entry(1, r_dis-obj.d-card, chr(4)) )
                       ,input 0
                       ,input  ?
                       ,input  ?
                       ,input 0
                       ,output varrid-list) no-error.
    end.
    if SelectCurr = 'rubl':U then
    apply "entry" to br-dis-obj-r.
    else
    apply "entry" to br-dis-obj-b.
END.
ON CHOOSE OF b-history IN FRAME d-disc
DO:
define variable parref-list as character no-undo .
CASE rs-host-obj:
  when 'объект':U then do:
    if
    (SelectCurr = 'rubl':U
    and available r_dis-obj )
    or
    (SelectCurr = 'base':U
    and
    available ub.dis-obj ) then
    run ref/cdchist.w (
                      INPUT parparentproc
                      ,input p-curr-host-code
                      ,input p-curr-obj-type
                      ,input p-curr-obj-code
                      ,input "":U
                      ,input "subject-object":U
                      ,input dis-obj.d-card
                      ,input ?
                      ,input (if selectcurr = 'base':U then dis-obj.obj-type else r_dis-obj.obj-type)
                      ,input (if selectcurr = 'base':U then dis-obj.obj-code else r_dis-obj.obj-code)
                      ,input (if selectcurr = 'base':U then dis-obj.host-code else r_dis-obj.host-code)
                      ,input ?
                      ,input "":U
                      ,input 'dis-obj':U
                      ,input ?
                      ,input-output parref-list
                  ) no-error .
      if SelectCurr = 'rubl':U then
      apply "entry" to BR-dis-obj-r.
      else
      apply "entry" to BR-dis-obj-b.
   end.
   when 'фирма':U then do:
    if
    (SelectCurr = 'rubl':U
    and available r_dis-host )
    or
    (SelectCurr = 'base':U
    and
    available ub.dis-host ) then
     run ref/cdchist.w (
                        INPUT parparentproc
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input "":U
                        ,input "subject"
                        ,input dis-obj.d-card
                        ,input ?
                        ,input '':U
                        ,input 0
                        ,input (if selectcurr = 'base':U then dis-host.host-code else r_dis-host.host-code)
                        ,input ?
                        ,input "":U
                        ,input 'dis-host':U
                        ,input ?
                        ,input-output parref-list
                    ) no-error .
      if SelectCurr = 'rubl':U then
      apply "entry" to BR-dis-host-r.
      else
      apply "entry" to BR-dis-host-b.
     end.
   END CASE.
 END.
ON CHOOSE OF B-print IN FRAME d-disc
DO:
define variable v-doc-rec as recid no-undo .
 CASE rs-host-obj:
     WHEN 'объект':U THEN DO:
      v-doc-rec = recid( ub.dis-obj ).
      DO WHILE available ub.dis-obj :
        GET prev br-dis-obj-b.
      END.
      run PrintProc IN THIS-PROCEDURE (rs-gen-private, rs-host-obj) .
      reposition br-dis-obj-b to recid v-doc-rec no-error.
      IF selectcurr = 'base':U THEN
      apply "entry" to br-dis-obj-b in frame d-disc.
      ELSE
      apply "entry" to br-dis-obj-r in frame d-disc.
   END.
   WHEN 'фирма':U THEN DO:
      v-doc-rec = recid( ub.dis-host ).
      DO WHILE available ub.dis-host :
          GET prev br-dis-host-b.
      END.
      run PrintProc IN THIS-PROCEDURE (rs-gen-private, rs-host-obj) .
      reposition br-dis-host-b to recid v-doc-rec no-error.
      IF selectcurr = 'base':U THEN
      apply "entry" to br-dis-host-b in frame d-disc.
      ELSE
      apply "entry" to br-dis-host-r in frame d-disc.
  END.
 END CASE.
END.
ON CHOOSE OF Btn_Cost IN FRAME d-disc
DO:
  if available ub.dis-obj
  or available r_Dis-obj
  then do:
    define variable v-host-code as integer   no-undo .
    define variable v-obj-type as character no-undo .
    define variable v-obj-code as integer no-undo .
    define variable v-base-sum as decimal no-undo .
    define variable v-rubl-sum as decimal no-undo .
    case selectcurr:
      when 'rubl':U then do:
        assign
        v-obj-type = (if available r_dis-obj
                      then r_dis-obj.obj-type
                      else ?)
        v-obj-code = (if available r_dis-obj
                      then r_dis-obj.obj-code
                      else ?)
        v-base-sum = r_dis-obj.gds-tot-b0
        v-rubl-sum = r_dis-obj.gds-tot-r0
        .
      end.
      when 'base':U then do:
        assign
        v-obj-type = (if available dis-obj
                      then dis-obj.obj-type
                      else ?)
        v-obj-code = (if available dis-obj
                      then dis-obj.obj-code
                      else ?)
        v-base-sum = dis-obj.gds-tot-b0
        v-rubl-sum = dis-obj.gds-tot-r0
        .
      end.
    end.
    if v-obj-type = ? then do:
      return no-apply.
    end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-host-code
    ,input  v-obj-type
    ,input  v-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output LogRes
    )  .
end.
    if NOT LogRes then
        return no-apply.
    else do:
      message
      substitute("Сумма учетных цен (б.в.) : &1&2"  +
                  "Сумма учетных цен (руб.) : &3"
                  ,v-base-sum
                  ,chr(10)
                  ,v-rubl-sum)
                  view-as alert-box INFORMATION
      title substitute( "По объекту &1&2"
                        ,v-obj-type
                        ,v-obj-code ) .
    end.
  end.
END.
ON VALUE-CHANGED OF Rs-gen-private IN FRAME d-disc
DO:
  assign rs-gen-private.
  if RS-gen-PRivate = 1 then do:                          hide SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum in frame d-disc.            display selectcurr with frame d-disc.      end.                                                  else do:                                                display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.     end.
  RUN OpenBr IN THIS-PROCEDURE (
                                input t-legacy
                              , input t-subsid
                              , input selectcurr
                              , input rs-gen-private
                              , input rs-host-obj).
  IF rs-host-obj = 'объект':U THEN DO:
      IF SELECTcurr = 'base':U THEN
      apply "ENTRY" to BR-dis-obj-b.
      ELSE
      apply "ENTRY" to BR-dis-obj-r.
  END.
  IF rs-host-obj = 'фирма':U THEN DO:
      IF SELECTcurr = 'base':U THEN
      apply "ENTRY" to BR-dis-host-b.
      ELSE
      apply "ENTRY" to BR-dis-host-r.
  END.
END.
ON VALUE-CHANGED OF rs-host-obj IN FRAME d-disc
DO:
  assign RS-host-obj.
  RUN openbr IN THIS-PROCEDURE (
                                 input t-legacy
                               , input t-subsid
                               , INPUT selectcurr
                               , INPUT rs-gen-private
                               , input rs-host-obj).
  IF rs-host-obj = 'объект':U THEN DO:
    ENABLE
    b-chk
    btn_cost
    with frame d-disc .
  if SelectCurr = 'rubl':U then do:
    run diasize_restore-orig-size in this-procedure .
    run diasize_set-browse-handle in this-procedure
      (input browse BR-dis-obj-r :handle
      ) .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  RECT-1 :handle
      ) .
    run diasize_restore-current-size in this-procedure .
    run GetSums in this-procedure .
    if RS-gen-PRivate = 1 then do:                          hide SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum in frame d-disc.            display selectcurr with frame d-disc.      end.                                                  else do:                                                display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.     end.
    apply "ENTRY" to BR-dis-obj-r.
  end.
  else do:
     run diasize_restore-orig-size in this-procedure .
    run diasize_set-browse-handle in this-procedure
      (input browse BR-dis-obj-b :handle
      ) .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  RECT-1 :handle
      ) .
    run diasize_restore-current-size in this-procedure .
    run GetSums in this-procedure .
    if RS-gen-PRivate = 1 then do:                          hide SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum in frame d-disc.            display selectcurr with frame d-disc.      end.                                                  else do:                                                display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.     end.
    apply "ENTRY" to BR-dis-obj-b.
  end.
  END.
  ELSE DO:
    DISABLE
    b-chk
    btn_cost
    with frame d-disc .
    if SelectCurr = 'rubl':U then do:
      run diasize_restore-orig-size in this-procedure .
      run diasize_set-browse-handle in this-procedure
        (input browse BR-dis-host-r :handle
        ) .
      run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  RECT-1 :handle
        ) .
      run diasize_restore-current-size in this-procedure .
      run GetSums in this-procedure  .
      if RS-gen-PRivate = 1 then do:                          hide SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum in frame d-disc.            display selectcurr with frame d-disc.      end.                                                  else do:                                                display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.     end.
      apply "ENTRY" to BR-dis-host-r.
    end.
    else do:
      run diasize_restore-orig-size in this-procedure .
      run diasize_set-browse-handle in this-procedure
        (input browse BR-dis-host-b :handle
        ) .
      run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  RECT-1 :handle
        ) .
      run diasize_restore-current-size in this-procedure .
      run GetSums in this-procedure .
      if RS-gen-PRivate = 1 then do:                          hide SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum in frame d-disc.            display selectcurr with frame d-disc.      end.                                                  else do:                                                display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.     end.
      apply "ENTRY" to BR-dis-host-b.
    end.
  END.
END.
ON VALUE-CHANGED OF SelectCurr IN FRAME d-disc
DO:
  assign SelectCurr.
  if rs-host-obj = 'объект':U then do:
    if SelectCurr = 'base':U then do:
      HIDE
      BR-dis-obj-r
      IN FRAME d-disc
      .
      enable
      BR-dis-obj-b
      with frame d-disc .
      VIEW
      BR-dis-obj-b
      IN FRAME d-disc
      .
      run diasize_restore-orig-size in this-procedure .
      run diasize_set-browse-handle in this-procedure
        (input browse BR-dis-obj-b :handle
        ) .
      run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  RECT-1 :handle
        ) .
      run diasize_restore-current-size in this-procedure .
      run GetSums in this-procedure  .
      if RS-gen-PRivate = 1 then do:                          hide SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum in frame d-disc.            display selectcurr with frame d-disc.      end.                                                  else do:                                                display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.     end.
      apply "ENTRY" to BR-dis-obj-b.
    end.
    else do:
      HIDE
      BR-dis-obj-b
      IN FRAME d-disc
      .
      enable
      BR-dis-obj-r
      with frame d-disc .
      VIEW
      BR-dis-obj-r
      IN FRAME d-disc
      .
      run diasize_restore-orig-size in this-procedure .
      run diasize_set-browse-handle in this-procedure
        (input browse BR-dis-obj-r :handle
        ) .
      run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  RECT-1 :handle
        ) .
      run diasize_restore-current-size in this-procedure .
      run GetSums in this-procedure .
      if RS-gen-PRivate = 1 then do:                          hide SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum in frame d-disc.            display selectcurr with frame d-disc.      end.                                                  else do:                                                display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.     end.
      apply "ENTRY" to BR-dis-obj-r.
    end.
  end.
  else do:
      if SelectCurr = 'base':U then do:
      HIDE
      BR-dis-host-r
      IN FRAME d-disc
      .
      enable
      BR-dis-host-b
      with frame d-disc .
      VIEW
      BR-dis-host-b
      IN FRAME d-disc
      .
      run diasize_restore-orig-size in this-procedure .
      run diasize_set-browse-handle in this-procedure
        (input browse BR-dis-host-b :handle
        ) .
      run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  RECT-1 :handle
        ) .
      run diasize_restore-current-size in this-procedure .
      run GetSums in this-procedure  .
      if RS-gen-PRivate = 1 then do:                          hide SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum in frame d-disc.            display selectcurr with frame d-disc.      end.                                                  else do:                                                display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.     end.
      apply "ENTRY" to BR-dis-host-b.
    end.
    else do:
      HIDE
      BR-dis-host-b
      IN FRAME d-disc
      .
      enable
      BR-dis-host-r
      with frame d-disc .
      VIEW
      BR-dis-host-r
      IN FRAME d-disc
      .
      run diasize_restore-orig-size in this-procedure .
      run diasize_set-browse-handle in this-procedure
        (input browse BR-dis-host-r :handle
        ) .
      run diasize_add_browse in this-procedure
        (input  'width':u
        ,input  RECT-1 :handle
        ) .
      run diasize_restore-current-size in this-procedure .
      run GetSums in this-procedure .
      if RS-gen-PRivate = 1 then do:                          hide SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum in frame d-disc.            display selectcurr with frame d-disc.      end.                                                  else do:                                                display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.     end.
      apply "ENTRY" to BR-dis-host-r.
    end.
  end.
END.
ON VALUE-CHANGED OF T-legacy IN FRAME d-disc
DO:
  assign
  t-legacy.
  if ub.dis-card.is-subsid = yes
  and t-legacy = yes
  then do:
    assign
    t-subsid = yes.
    display
    t-subsid
    with frame d-disc .
    disable
    t-subsid
    with frame d-disc .
  end.
  else do:
    enable
    t-subsid
    with frame d-disc .
  end.
  run fill-tables in this-procedure ( input t-legacy, input t-subsid ).
  run openbr in this-procedure ( input t-legacy
                               , input t-subsid
                               , input selectcurr
                               , input rs-gen-private
                               , input rs-host-obj).
  RUN start-mv-clmnbr-dis-obj-b.
  RUN start-mv-clmnbr-dis-obj-r.
  run GetSums in this-procedure .
  if RS-gen-PRivate = 1 then do:                          hide SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum in frame d-disc.            display selectcurr with frame d-disc.      end.                                                  else do:                                                display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.     end.
  CASE t-legacy:
    when yes then do:
      display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.
    end.
    when no then do:
      hide lnumcard numcard in frame d-disc.
    end.
  END CASE.
END.
ON VALUE-CHANGED OF T-subsid IN FRAME d-disc
DO:
  assign
  t-subsid.
  run fill-tables in this-procedure ( input t-legacy, input t-subsid).
  run openbr in this-procedure (
                                 input t-legacy
                               , input t-subsid
                               , input selectcurr
                               , input rs-gen-private
                               , input rs-host-obj).
  RUN start-mv-clmnbr-dis-obj-b.
  RUN start-mv-clmnbr-dis-obj-r.
  run GetSums in this-procedure .
  if RS-gen-PRivate = 1 then do:                          hide SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum in frame d-disc.            display selectcurr with frame d-disc.      end.                                                  else do:                                                display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.     end.
  CASE t-subsid:
    when yes then do:
      display SelectCurr TotalSum NumCard NumChk DiscSum NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum with frame d-disc.
    end.
    when no then do:
      hide lnumcard numcard in frame d-disc.
    end.
  END CASE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-disc:PARENT eq ?
THEN FRAME d-disc:PARENT = ACTIVE-WINDOW.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-disc
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
on choose of b-help in frame d-disc
do:
  apply "help":u to frame d-disc .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-disc:width - 0.3
                fh            = frame d-disc:first-child
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-disc :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-disc :height-chars)
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
    if frame d-disc :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-disc :height-chars)
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
            frame d-disc :height = v-frame-height
          .
          if frame d-disc :scrollable = true
          then do:
            assign
              frame d-disc :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-disc :scrollable = true
          then do:
            assign
              frame d-disc :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-disc :height = v-frame-height
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
      v-frame-height = frame d-disc :height
      v-frame-virtual-height = frame d-disc :virtual-height
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
      v-field-group-handle = frame d-disc :first-child
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
    do with frame d-disc
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-disc :scrollable = true
      then do:
        assign
          frame d-disc :virtual-height = frame d-disc :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-disc :height = frame d-disc :height + p-change-value
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
        frame d-disc :height = frame d-disc :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-disc :scrollable = true
      then do:
        assign
          frame d-disc :virtual-height = frame d-disc :virtual-height + p-change-value
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
          ,input  string(frame d-disc :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-disc :height)
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
    if frame d-disc :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-disc :width
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
    if frame d-disc :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-disc :width
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
            frame d-disc :width = v-frame-width
          .
          if frame d-disc :scrollable = true
          then do:
            assign
              frame d-disc :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-disc :scrollable = true
          then do:
            assign
              frame d-disc :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-disc :width = v-frame-width
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
      v-frame-width = frame d-disc :width
      v-frame-virtual-width = frame d-disc :virtual-width
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
      v-field-group-handle = frame d-disc :first-child
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
    do with frame d-disc
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-disc :scrollable = true
      then do:
        assign
          frame d-disc :virtual-width = frame d-disc :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-disc :width = v-frame-width + p-change-value
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
        frame d-disc :width = frame d-disc :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-disc :scrollable = true
      then do:
        assign
          frame d-disc :virtual-width = frame d-disc :virtual-width + p-change-value
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
          ,input  string(frame d-disc :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-disc :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-disc
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-disc :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-disc :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-disc :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-disc :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-disc
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
      v-row-delta = v-new-row - frame d-disc :height
      v-col-delta = v-new-col - frame d-disc :width
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
            - frame d-disc :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-disc :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-disc :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-disc :height-chars
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
      v-diasize-current-frame-width  = frame d-disc :width
      v-diasize-current-frame-height = frame d-disc :height
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
    do with frame d-disc
    :
      assign
        v-diasize-orig-frame-height = frame d-disc :height
        v-diasize-orig-frame-width  = frame d-disc :width
        v-diasize-browse-handle     = browse BR-dis-host-b :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-disc :first-child
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-dis-host-b :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
def var sort-labelBR-dis-obj-b   as character no-undo .
def var sort-clmnBR-dis-obj-b    as handle    no-undo .
def var cur-clmnBR-dis-obj-b     as handle    no-undo .
def var cur-clmn-locBR-dis-obj-b as integer   no-undo .
def var re-queryBR-dis-obj-b     as logical   initial no no-undo .
on start-search, ctrl-o of BR-dis-obj-b in frame d-disc do:
   run sort-brBR-dis-obj-b
     (input (if available tt-dis-card
             then recid(tt-dis-card)
             else ?
            )
     ).
end.
PROCEDURE sort-brBR-dis-obj-b :
  define input parameter p-recid as recid no-undo .
  if re-queryBR-dis-obj-b = no then do:
    assign
       cur-clmnBR-dis-obj-b = BR-dis-obj-b:current-column in frame d-disc
    .
    if sort-clmnBR-dis-obj-b <> ? then sort-clmnBR-dis-obj-b:column-fgcolor = 0.
    if cur-clmnBR-dis-obj-b = sort-clmnBR-dis-obj-b then do:
      assign
         sort-labelBR-dis-obj-b = ""
         sort-clmnBR-dis-obj-b = ?
      .
     end.
     else do:
       assign
         sort-labelBR-dis-obj-b = cur-clmnBR-dis-obj-b:label
         sort-clmnBR-dis-obj-b  = cur-clmnBR-dis-obj-b
         sort-clmnBR-dis-obj-b:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBR-dis-obj-b = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BR-dis-obj-b:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBR-dis-obj-b then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBR-dis-obj-b = cur-clmn-locBR-dis-obj-b + 1
    .
  end.
  case sort-labelBR-dis-obj-b:
        when ub.dis-obj.obj-code:label in browse BR-dis-obj-b then DO:   assign     sort-column-name = "ub.dis-obj.obj-code"   .   run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).   . END.
        when ub.dis-obj.d-card:label in browse BR-dis-obj-b then DO:   assign     sort-column-name = "ub.dis-obj.d-card"   .   run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).   . END.
        when vob:label in browse BR-dis-obj-b then DO:   assign     sort-column-name = "vob"   .   run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultBR-dis-obj-b') then do:
          run mv-brw-defaultBR-dis-obj-b.
        end.
      if sort-labelBR-dis-obj-b <> "" then do:
        assign
          cur-clmnBR-dis-obj-b:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBR-dis-obj-b = ?
      .
    end.
  end case.
    if cur-clmn-locBR-dis-obj-b <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnBR-dis-obj-b') then do:
        run ch-clmnBR-dis-obj-b in this-procedure (cur-clmn-locBR-dis-obj-b).
      end.
    end.
  if p-recid <> ? then do:
    reposition BR-dis-obj-b to recid p-recid no-error.
    apply "value-changed" to BR-dis-obj-b in frame d-disc.
  end.
  apply "entry" to BR-dis-obj-b in frame d-disc.
END PROCEDURE.
procedure re-open-query-srt-clmnBR-dis-obj-b:
if cur-clmnBR-dis-obj-b = ? then do:
   run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).
end.
else do:
   assign re-queryBR-dis-obj-b = yes.
   run sort-brBR-dis-obj-b
     (input (if available tt-dis-card
             then recid(tt-dis-card)
             else ?
            )
     ).
   assign re-queryBR-dis-obj-b = no.
end.
end.
def var sort-labelBR-dis-obj-r   as character no-undo .
def var sort-clmnBR-dis-obj-r    as handle    no-undo .
def var cur-clmnBR-dis-obj-r     as handle    no-undo .
def var cur-clmn-locBR-dis-obj-r as integer   no-undo .
def var re-queryBR-dis-obj-r     as logical   initial no no-undo .
on start-search, ctrl-o of BR-dis-obj-r in frame d-disc do:
   run sort-brBR-dis-obj-r
     (input (if available rtt-dis-card
             then recid(rtt-dis-card)
             else ?
            )
     ).
end.
PROCEDURE sort-brBR-dis-obj-r :
  define input parameter p-recid as recid no-undo .
  if re-queryBR-dis-obj-r = no then do:
    assign
       cur-clmnBR-dis-obj-r = BR-dis-obj-r:current-column in frame d-disc
    .
    if sort-clmnBR-dis-obj-r <> ? then sort-clmnBR-dis-obj-r:column-fgcolor = 0.
    if cur-clmnBR-dis-obj-r = sort-clmnBR-dis-obj-r then do:
      assign
         sort-labelBR-dis-obj-r = ""
         sort-clmnBR-dis-obj-r = ?
      .
     end.
     else do:
       assign
         sort-labelBR-dis-obj-r = cur-clmnBR-dis-obj-r:label
         sort-clmnBR-dis-obj-r  = cur-clmnBR-dis-obj-r
         sort-clmnBR-dis-obj-r:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBR-dis-obj-r = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BR-dis-obj-r:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBR-dis-obj-r then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBR-dis-obj-r = cur-clmn-locBR-dis-obj-r + 1
    .
  end.
  case sort-labelBR-dis-obj-r:
        when r_dis-obj.obj-code:label in browse BR-dis-obj-r then DO:   assign     sort-column-name = "r_dis-obj.obj-code"   .   run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).   . END.
        when r_dis-obj.d-card:label in browse BR-dis-obj-r then DO:   assign     sort-column-name = "r_dis-obj.d-card"   .   run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).   . END.
        when vor:label in browse BR-dis-obj-r then DO:   assign     sort-column-name = "vor"   .   run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultBR-dis-obj-r') then do:
          run mv-brw-defaultBR-dis-obj-r.
        end.
      if sort-labelBR-dis-obj-r <> "" then do:
        assign
          cur-clmnBR-dis-obj-r:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBR-dis-obj-r = ?
      .
    end.
  end case.
    if cur-clmn-locBR-dis-obj-r <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnBR-dis-obj-r') then do:
        run ch-clmnBR-dis-obj-r in this-procedure (cur-clmn-locBR-dis-obj-r).
      end.
    end.
  if p-recid <> ? then do:
    reposition BR-dis-obj-r to recid p-recid no-error.
    apply "value-changed" to BR-dis-obj-r in frame d-disc.
  end.
  apply "entry" to BR-dis-obj-r in frame d-disc.
END PROCEDURE.
procedure re-open-query-srt-clmnBR-dis-obj-r:
if cur-clmnBR-dis-obj-r = ? then do:
   run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).
end.
else do:
   assign re-queryBR-dis-obj-r = yes.
   run sort-brBR-dis-obj-r
     (input (if available rtt-dis-card
             then recid(rtt-dis-card)
             else ?
            )
     ).
   assign re-queryBR-dis-obj-r = no.
end.
end.
def var sort-labelBR-dis-host-b   as character no-undo .
def var sort-clmnBR-dis-host-b    as handle    no-undo .
def var cur-clmnBR-dis-host-b     as handle    no-undo .
def var cur-clmn-locBR-dis-host-b as integer   no-undo .
def var re-queryBR-dis-host-b     as logical   initial no no-undo .
on start-search, ctrl-o of BR-dis-host-b in frame d-disc do:
   run sort-brBR-dis-host-b
     (input (if available htt-dis-card
             then recid(htt-dis-card)
             else ?
            )
     ).
end.
PROCEDURE sort-brBR-dis-host-b :
  define input parameter p-recid as recid no-undo .
  if re-queryBR-dis-host-b = no then do:
    assign
       cur-clmnBR-dis-host-b = BR-dis-host-b:current-column in frame d-disc
    .
    if sort-clmnBR-dis-host-b <> ? then sort-clmnBR-dis-host-b:column-fgcolor = 0.
    if cur-clmnBR-dis-host-b = sort-clmnBR-dis-host-b then do:
      assign
         sort-labelBR-dis-host-b = ""
         sort-clmnBR-dis-host-b = ?
      .
     end.
     else do:
       assign
         sort-labelBR-dis-host-b = cur-clmnBR-dis-host-b:label
         sort-clmnBR-dis-host-b  = cur-clmnBR-dis-host-b
         sort-clmnBR-dis-host-b:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBR-dis-host-b = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BR-dis-host-b:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBR-dis-host-b then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBR-dis-host-b = cur-clmn-locBR-dis-host-b + 1
    .
  end.
  case sort-labelBR-dis-host-b:
        when ub.dis-host.host-code:label in browse BR-dis-host-b then DO:   assign     sort-column-name = "ub.dis-host.host-code"   .   run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).   . END.
        when ub.dis-host.d-card:label in browse BR-dis-host-b then DO:   assign     sort-column-name = "ub.dis-host.d-card"   .   run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).   . END.
        when vhb:label in browse BR-dis-host-b then DO:   assign     sort-column-name = "vhb"   .   run OpenBr in this-procedure ( input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure(input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultBR-dis-host-b') then do:
          run mv-brw-defaultBR-dis-host-b.
        end.
      if sort-labelBR-dis-host-b <> "" then do:
        assign
          cur-clmnBR-dis-host-b:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBR-dis-host-b = ?
      .
    end.
  end case.
    if cur-clmn-locBR-dis-host-b <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnBR-dis-host-b') then do:
        run ch-clmnBR-dis-host-b in this-procedure (cur-clmn-locBR-dis-host-b).
      end.
    end.
  if p-recid <> ? then do:
    reposition BR-dis-host-b to recid p-recid no-error.
    apply "value-changed" to BR-dis-host-b in frame d-disc.
  end.
  apply "entry" to BR-dis-host-b in frame d-disc.
END PROCEDURE.
procedure re-open-query-srt-clmnBR-dis-host-b:
if cur-clmnBR-dis-host-b = ? then do:
   run OpenBr in this-procedure(input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).
end.
else do:
   assign re-queryBR-dis-host-b = yes.
   run sort-brBR-dis-host-b
     (input (if available htt-dis-card
             then recid(htt-dis-card)
             else ?
            )
     ).
   assign re-queryBR-dis-host-b = no.
end.
end.
def var sort-labelBR-dis-host-r   as character no-undo .
def var sort-clmnBR-dis-host-r    as handle    no-undo .
def var cur-clmnBR-dis-host-r     as handle    no-undo .
def var cur-clmn-locBR-dis-host-r as integer   no-undo .
def var re-queryBR-dis-host-r     as logical   initial no no-undo .
on start-search, ctrl-o of BR-dis-host-r in frame d-disc do:
   run sort-brBR-dis-host-r
     (input (if available hrtt-dis-card
             then recid(hrtt-dis-card)
             else ?
            )
     ).
end.
PROCEDURE sort-brBR-dis-host-r :
  define input parameter p-recid as recid no-undo .
  if re-queryBR-dis-host-r = no then do:
    assign
       cur-clmnBR-dis-host-r = BR-dis-host-r:current-column in frame d-disc
    .
    if sort-clmnBR-dis-host-r <> ? then sort-clmnBR-dis-host-r:column-fgcolor = 0.
    if cur-clmnBR-dis-host-r = sort-clmnBR-dis-host-r then do:
      assign
         sort-labelBR-dis-host-r = ""
         sort-clmnBR-dis-host-r = ?
      .
     end.
     else do:
       assign
         sort-labelBR-dis-host-r = cur-clmnBR-dis-host-r:label
         sort-clmnBR-dis-host-r  = cur-clmnBR-dis-host-r
         sort-clmnBR-dis-host-r:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBR-dis-host-r = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BR-dis-host-r:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBR-dis-host-r then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBR-dis-host-r = cur-clmn-locBR-dis-host-r + 1
    .
  end.
  case sort-labelBR-dis-host-r:
        when r_dis-host.host-code:label in browse BR-dis-host-r then DO:   assign     sort-column-name = "r_dis-host.host-code"   .   run OpenBr in this-procedure (input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).   . END.
        when r_dis-host.d-card:label in browse BR-dis-host-r then DO:   assign     sort-column-name = "r_dis-host.d-card"   .   run OpenBr in this-procedure (input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).   . END.
        when vhr:label in browse BR-dis-host-r then DO:   assign     sort-column-name = "vhr"   .   run OpenBr in this-procedure (input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure(input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultBR-dis-host-r') then do:
          run mv-brw-defaultBR-dis-host-r.
        end.
      if sort-labelBR-dis-host-r <> "" then do:
        assign
          cur-clmnBR-dis-host-r:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBR-dis-host-r = ?
      .
    end.
  end case.
    if cur-clmn-locBR-dis-host-r <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnBR-dis-host-r') then do:
        run ch-clmnBR-dis-host-r in this-procedure (cur-clmn-locBR-dis-host-r).
      end.
    end.
  if p-recid <> ? then do:
    reposition BR-dis-host-r to recid p-recid no-error.
    apply "value-changed" to BR-dis-host-r in frame d-disc.
  end.
  apply "entry" to BR-dis-host-r in frame d-disc.
END PROCEDURE.
procedure re-open-query-srt-clmnBR-dis-host-r:
if cur-clmnBR-dis-host-r = ? then do:
   run OpenBr in this-procedure(input t-legacy, input t-subsid, input selectcurr, input rs-gen-private, input rs-host-obj).
end.
else do:
   assign re-queryBR-dis-host-r = yes.
   run sort-brBR-dis-host-r
     (input (if available hrtt-dis-card
             then recid(hrtt-dis-card)
             else ?
            )
     ).
   assign re-queryBR-dis-host-r = no.
end.
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-dis-obj-b as INT EXTENT 9 no-undo.
DEF VAR varmvibr-dis-obj-b       as INT no-undo.
DEF VAR varmvjbr-dis-obj-b       as INT no-undo.
DEF VAR varmvkbr-dis-obj-b       as INT no-undo.
DEF VAR varmvlbr-dis-obj-b       as INT no-undo.
DEF VAR move-elementbr-dis-obj-b as INT no-undo.
def var jjbr-dis-obj-b           as int no-undo.
do varmvibr-dis-obj-b = 1 to EXTENT(cur-clmn-numbr-dis-obj-b):
  ASSIGN cur-clmn-numbr-dis-obj-b[varmvibr-dis-obj-b] = varmvibr-dis-obj-b.
END.
RUN start-mv-clmnbr-dis-obj-b.
PROCEDURE start-mv-clmnbr-dis-obj-b:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  t-legacy = no and t-subsid = no  THEN DO:
   DO jjbr-dis-obj-b = NUM-ENTRIES('1,2,3,4,5,6,7,8,9') TO 1 BY -1:
     RUN re-move-clmnbr-dis-obj-b ( cur-clmn-numbr-dis-obj-b[INTEGER(ENTRY (jjbr-dis-obj-b, '1,2,3,4,5,6,7,8,9'))] , 1).
   END.
       END.
       IF  t-legacy = yes or t-subsid = yes  THEN DO:
   DO jjbr-dis-obj-b = NUM-ENTRIES('9,1,2,3,4,5,6,7,8') TO 1 BY -1:
     RUN re-move-clmnbr-dis-obj-b ( cur-clmn-numbr-dis-obj-b[INTEGER(ENTRY (jjbr-dis-obj-b, '9,1,2,3,4,5,6,7,8'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-dis-obj-b do:
  RUN re-move-clmnbr-dis-obj-b ( 1, 9).
END.
ON ctrl-cursor-left OF BROWSE br-dis-obj-b do:
  RUN re-move-clmnbr-dis-obj-b (9, 1).
END.
PROCEDURE re-move-clmnbr-dis-obj-b:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-dis-obj-b = 1 TO EXTENT(cur-clmn-numbr-dis-obj-b):
    if cur-clmn-numbr-dis-obj-b[varmvibr-dis-obj-b] = source-column THEN cur-clmn-numbr-dis-obj-b[varmvibr-dis-obj-b] = -1.
  END.
  if br-dis-obj-b:MOVE-COLUMN(source-column, target-column) IN FRAME d-disc then.
  if source-column > target-column THEN
  DO varmvjbr-dis-obj-b = source-column - 1 to target-column BY -1:
    DO varmvibr-dis-obj-b = 1 TO EXTENT(cur-clmn-numbr-dis-obj-b):
        if cur-clmn-numbr-dis-obj-b[varmvibr-dis-obj-b] = varmvjbr-dis-obj-b THEN DO:
          cur-clmn-numbr-dis-obj-b[varmvibr-dis-obj-b] = cur-clmn-numbr-dis-obj-b[varmvibr-dis-obj-b] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-dis-obj-b = source-column + 1 to target-column:
    DO varmvibr-dis-obj-b = 1 TO EXTENT(cur-clmn-numbr-dis-obj-b):
      if cur-clmn-numbr-dis-obj-b[varmvibr-dis-obj-b] = varmvjbr-dis-obj-b THEN DO:
        cur-clmn-numbr-dis-obj-b[varmvibr-dis-obj-b] = cur-clmn-numbr-dis-obj-b[varmvibr-dis-obj-b] - 1.
      END.
    END.
  END.
  DO varmvibr-dis-obj-b = 1 TO EXTENT(cur-clmn-numbr-dis-obj-b):
    if cur-clmn-numbr-dis-obj-b[varmvibr-dis-obj-b] = -1 THEN cur-clmn-numbr-dis-obj-b[varmvibr-dis-obj-b] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-dis-obj-b:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-dis-obj-b = 1 TO EXTENT(cur-clmn-numbr-dis-obj-b):
    if cur-clmn-numbr-dis-obj-b[varmvibr-dis-obj-b] = cur-clmn-loc THEN move-elementbr-dis-obj-b = varmvibr-dis-obj-b.
  END.
  RUN re-move-clmnbr-dis-obj-b (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-dis-obj-b:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-dis-obj-b = 1 to EXTENT(cur-clmn-numbr-dis-obj-b):
    RUN re-move-clmnbr-dis-obj-b (cur-clmn-numbr-dis-obj-b[varmvlbr-dis-obj-b], varmvlbr-dis-obj-b).
  END.
  RUN start-mv-clmnbr-dis-obj-b.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-dis-obj-r as INT EXTENT 9 no-undo.
DEF VAR varmvibr-dis-obj-r       as INT no-undo.
DEF VAR varmvjbr-dis-obj-r       as INT no-undo.
DEF VAR varmvkbr-dis-obj-r       as INT no-undo.
DEF VAR varmvlbr-dis-obj-r       as INT no-undo.
DEF VAR move-elementbr-dis-obj-r as INT no-undo.
def var jjbr-dis-obj-r           as int no-undo.
do varmvibr-dis-obj-r = 1 to EXTENT(cur-clmn-numbr-dis-obj-r):
  ASSIGN cur-clmn-numbr-dis-obj-r[varmvibr-dis-obj-r] = varmvibr-dis-obj-r.
END.
RUN start-mv-clmnbr-dis-obj-r.
PROCEDURE start-mv-clmnbr-dis-obj-r:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  t-legacy = no and t-subsid = no  THEN DO:
   DO jjbr-dis-obj-r = NUM-ENTRIES('1,2,3,4,5,6,7,8,9') TO 1 BY -1:
     RUN re-move-clmnbr-dis-obj-r ( cur-clmn-numbr-dis-obj-r[INTEGER(ENTRY (jjbr-dis-obj-r, '1,2,3,4,5,6,7,8,9'))] , 1).
   END.
       END.
       IF  t-legacy = yes or t-subsid = yes THEN DO:
   DO jjbr-dis-obj-r = NUM-ENTRIES('9,1,2,3,4,5,6,7,8') TO 1 BY -1:
     RUN re-move-clmnbr-dis-obj-r ( cur-clmn-numbr-dis-obj-r[INTEGER(ENTRY (jjbr-dis-obj-r, '9,1,2,3,4,5,6,7,8'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-dis-obj-r do:
  RUN re-move-clmnbr-dis-obj-r ( 1, 9).
END.
ON ctrl-cursor-left OF BROWSE br-dis-obj-r do:
  RUN re-move-clmnbr-dis-obj-r (9, 1).
END.
PROCEDURE re-move-clmnbr-dis-obj-r:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-dis-obj-r = 1 TO EXTENT(cur-clmn-numbr-dis-obj-r):
    if cur-clmn-numbr-dis-obj-r[varmvibr-dis-obj-r] = source-column THEN cur-clmn-numbr-dis-obj-r[varmvibr-dis-obj-r] = -1.
  END.
  if br-dis-obj-r:MOVE-COLUMN(source-column, target-column) IN FRAME d-disc then.
  if source-column > target-column THEN
  DO varmvjbr-dis-obj-r = source-column - 1 to target-column BY -1:
    DO varmvibr-dis-obj-r = 1 TO EXTENT(cur-clmn-numbr-dis-obj-r):
        if cur-clmn-numbr-dis-obj-r[varmvibr-dis-obj-r] = varmvjbr-dis-obj-r THEN DO:
          cur-clmn-numbr-dis-obj-r[varmvibr-dis-obj-r] = cur-clmn-numbr-dis-obj-r[varmvibr-dis-obj-r] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-dis-obj-r = source-column + 1 to target-column:
    DO varmvibr-dis-obj-r = 1 TO EXTENT(cur-clmn-numbr-dis-obj-r):
      if cur-clmn-numbr-dis-obj-r[varmvibr-dis-obj-r] = varmvjbr-dis-obj-r THEN DO:
        cur-clmn-numbr-dis-obj-r[varmvibr-dis-obj-r] = cur-clmn-numbr-dis-obj-r[varmvibr-dis-obj-r] - 1.
      END.
    END.
  END.
  DO varmvibr-dis-obj-r = 1 TO EXTENT(cur-clmn-numbr-dis-obj-r):
    if cur-clmn-numbr-dis-obj-r[varmvibr-dis-obj-r] = -1 THEN cur-clmn-numbr-dis-obj-r[varmvibr-dis-obj-r] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-dis-obj-r:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-dis-obj-r = 1 TO EXTENT(cur-clmn-numbr-dis-obj-r):
    if cur-clmn-numbr-dis-obj-r[varmvibr-dis-obj-r] = cur-clmn-loc THEN move-elementbr-dis-obj-r = varmvibr-dis-obj-r.
  END.
  RUN re-move-clmnbr-dis-obj-r (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-dis-obj-r:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-dis-obj-r = 1 to EXTENT(cur-clmn-numbr-dis-obj-r):
    RUN re-move-clmnbr-dis-obj-r (cur-clmn-numbr-dis-obj-r[varmvlbr-dis-obj-r], varmvlbr-dis-obj-r).
  END.
  RUN start-mv-clmnbr-dis-obj-r.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-dis-host-b as INT EXTENT 9 no-undo.
DEF VAR varmvibr-dis-host-b       as INT no-undo.
DEF VAR varmvjbr-dis-host-b       as INT no-undo.
DEF VAR varmvkbr-dis-host-b       as INT no-undo.
DEF VAR varmvlbr-dis-host-b       as INT no-undo.
DEF VAR move-elementbr-dis-host-b as INT no-undo.
def var jjbr-dis-host-b           as int no-undo.
do varmvibr-dis-host-b = 1 to EXTENT(cur-clmn-numbr-dis-host-b):
  ASSIGN cur-clmn-numbr-dis-host-b[varmvibr-dis-host-b] = varmvibr-dis-host-b.
END.
RUN start-mv-clmnbr-dis-host-b.
PROCEDURE start-mv-clmnbr-dis-host-b:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  t-legacy = no and t-subsid = no  THEN DO:
   DO jjbr-dis-host-b = NUM-ENTRIES('1,2,3,4,5,6,7,8,9') TO 1 BY -1:
     RUN re-move-clmnbr-dis-host-b ( cur-clmn-numbr-dis-host-b[INTEGER(ENTRY (jjbr-dis-host-b, '1,2,3,4,5,6,7,8,9'))] , 1).
   END.
       END.
       IF  t-legacy = yes or t-subsid = yes  THEN DO:
   DO jjbr-dis-host-b = NUM-ENTRIES('9,1,2,3,4,5,6,7,8') TO 1 BY -1:
     RUN re-move-clmnbr-dis-host-b ( cur-clmn-numbr-dis-host-b[INTEGER(ENTRY (jjbr-dis-host-b, '9,1,2,3,4,5,6,7,8'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-dis-host-b do:
  RUN re-move-clmnbr-dis-host-b ( 1, 9).
END.
ON ctrl-cursor-left OF BROWSE br-dis-host-b do:
  RUN re-move-clmnbr-dis-host-b (9, 1).
END.
PROCEDURE re-move-clmnbr-dis-host-b:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-dis-host-b = 1 TO EXTENT(cur-clmn-numbr-dis-host-b):
    if cur-clmn-numbr-dis-host-b[varmvibr-dis-host-b] = source-column THEN cur-clmn-numbr-dis-host-b[varmvibr-dis-host-b] = -1.
  END.
  if br-dis-host-b:MOVE-COLUMN(source-column, target-column) IN FRAME d-disc then.
  if source-column > target-column THEN
  DO varmvjbr-dis-host-b = source-column - 1 to target-column BY -1:
    DO varmvibr-dis-host-b = 1 TO EXTENT(cur-clmn-numbr-dis-host-b):
        if cur-clmn-numbr-dis-host-b[varmvibr-dis-host-b] = varmvjbr-dis-host-b THEN DO:
          cur-clmn-numbr-dis-host-b[varmvibr-dis-host-b] = cur-clmn-numbr-dis-host-b[varmvibr-dis-host-b] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-dis-host-b = source-column + 1 to target-column:
    DO varmvibr-dis-host-b = 1 TO EXTENT(cur-clmn-numbr-dis-host-b):
      if cur-clmn-numbr-dis-host-b[varmvibr-dis-host-b] = varmvjbr-dis-host-b THEN DO:
        cur-clmn-numbr-dis-host-b[varmvibr-dis-host-b] = cur-clmn-numbr-dis-host-b[varmvibr-dis-host-b] - 1.
      END.
    END.
  END.
  DO varmvibr-dis-host-b = 1 TO EXTENT(cur-clmn-numbr-dis-host-b):
    if cur-clmn-numbr-dis-host-b[varmvibr-dis-host-b] = -1 THEN cur-clmn-numbr-dis-host-b[varmvibr-dis-host-b] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-dis-host-b:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-dis-host-b = 1 TO EXTENT(cur-clmn-numbr-dis-host-b):
    if cur-clmn-numbr-dis-host-b[varmvibr-dis-host-b] = cur-clmn-loc THEN move-elementbr-dis-host-b = varmvibr-dis-host-b.
  END.
  RUN re-move-clmnbr-dis-host-b (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-dis-host-b:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-dis-host-b = 1 to EXTENT(cur-clmn-numbr-dis-host-b):
    RUN re-move-clmnbr-dis-host-b (cur-clmn-numbr-dis-host-b[varmvlbr-dis-host-b], varmvlbr-dis-host-b).
  END.
  RUN start-mv-clmnbr-dis-host-b.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-dis-host-r as INT EXTENT 9 no-undo.
DEF VAR varmvibr-dis-host-r       as INT no-undo.
DEF VAR varmvjbr-dis-host-r       as INT no-undo.
DEF VAR varmvkbr-dis-host-r       as INT no-undo.
DEF VAR varmvlbr-dis-host-r       as INT no-undo.
DEF VAR move-elementbr-dis-host-r as INT no-undo.
def var jjbr-dis-host-r           as int no-undo.
do varmvibr-dis-host-r = 1 to EXTENT(cur-clmn-numbr-dis-host-r):
  ASSIGN cur-clmn-numbr-dis-host-r[varmvibr-dis-host-r] = varmvibr-dis-host-r.
END.
RUN start-mv-clmnbr-dis-host-r.
PROCEDURE start-mv-clmnbr-dis-host-r:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  t-legacy = no and t-subsid = no  THEN DO:
   DO jjbr-dis-host-r = NUM-ENTRIES('1,2,3,4,5,6,7,8,9') TO 1 BY -1:
     RUN re-move-clmnbr-dis-host-r ( cur-clmn-numbr-dis-host-r[INTEGER(ENTRY (jjbr-dis-host-r, '1,2,3,4,5,6,7,8,9'))] , 1).
   END.
       END.
       IF  t-legacy = yes or t-subsid = yes  THEN DO:
   DO jjbr-dis-host-r = NUM-ENTRIES('9,1,2,3,4,5,6,7,8') TO 1 BY -1:
     RUN re-move-clmnbr-dis-host-r ( cur-clmn-numbr-dis-host-r[INTEGER(ENTRY (jjbr-dis-host-r, '9,1,2,3,4,5,6,7,8'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-dis-host-r do:
  RUN re-move-clmnbr-dis-host-r ( 1, 9).
END.
ON ctrl-cursor-left OF BROWSE br-dis-host-r do:
  RUN re-move-clmnbr-dis-host-r (9, 1).
END.
PROCEDURE re-move-clmnbr-dis-host-r:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-dis-host-r = 1 TO EXTENT(cur-clmn-numbr-dis-host-r):
    if cur-clmn-numbr-dis-host-r[varmvibr-dis-host-r] = source-column THEN cur-clmn-numbr-dis-host-r[varmvibr-dis-host-r] = -1.
  END.
  if br-dis-host-r:MOVE-COLUMN(source-column, target-column) IN FRAME d-disc then.
  if source-column > target-column THEN
  DO varmvjbr-dis-host-r = source-column - 1 to target-column BY -1:
    DO varmvibr-dis-host-r = 1 TO EXTENT(cur-clmn-numbr-dis-host-r):
        if cur-clmn-numbr-dis-host-r[varmvibr-dis-host-r] = varmvjbr-dis-host-r THEN DO:
          cur-clmn-numbr-dis-host-r[varmvibr-dis-host-r] = cur-clmn-numbr-dis-host-r[varmvibr-dis-host-r] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-dis-host-r = source-column + 1 to target-column:
    DO varmvibr-dis-host-r = 1 TO EXTENT(cur-clmn-numbr-dis-host-r):
      if cur-clmn-numbr-dis-host-r[varmvibr-dis-host-r] = varmvjbr-dis-host-r THEN DO:
        cur-clmn-numbr-dis-host-r[varmvibr-dis-host-r] = cur-clmn-numbr-dis-host-r[varmvibr-dis-host-r] - 1.
      END.
    END.
  END.
  DO varmvibr-dis-host-r = 1 TO EXTENT(cur-clmn-numbr-dis-host-r):
    if cur-clmn-numbr-dis-host-r[varmvibr-dis-host-r] = -1 THEN cur-clmn-numbr-dis-host-r[varmvibr-dis-host-r] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-dis-host-r:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-dis-host-r = 1 TO EXTENT(cur-clmn-numbr-dis-host-r):
    if cur-clmn-numbr-dis-host-r[varmvibr-dis-host-r] = cur-clmn-loc THEN move-elementbr-dis-host-r = varmvibr-dis-host-r.
  END.
  RUN re-move-clmnbr-dis-host-r (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-dis-host-r:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-dis-host-r = 1 to EXTENT(cur-clmn-numbr-dis-host-r):
    RUN re-move-clmnbr-dis-host-r (cur-clmn-numbr-dis-host-r[varmvlbr-dis-host-r], varmvlbr-dis-host-r).
  END.
  RUN start-mv-clmnbr-dis-host-r.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    define variable v-ok as logical   no-undo .
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_discount-cards-totals_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output LogRes
    )  .
end.
    if NOT LogRes then
        do:
            message
                "У Вас недостаточно прав" skip
                "для выполнения данного действия." skip
                "Обратитесь к администратору системы." view-as alert-box error.
            LEAVE MAIN-BLOCK .
        end.
    find first ub.dis-card no-lock
      where ub.dis-card.d-card = inp-d-card
      no-error .
    if not available ub.dis-card then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена дисконтная карта с номером " inp-d-card
        view-as alert-box error.
      undo, return error .
    END.
    find first ub.clients no-lock
      where ub.clients.obj-type = ub.dis-card.cli-type
        and ub.clients.obj-code = ub.dis-card.cli-code
        no-error .
    if not available ub.clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден контрагент" ub.dis-card.cli-type ub.dis-card.cli-code skip
        view-as alert-box error.
      undo, return error .
    END.
    assign
      globalcard = (ub.dis-card.emitent-host-code = 0)
    .
    if not globalcard then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  ub.dis-card.emitent-host-code
  ,output v-glob-curr-code
  )  .
    end.
    FIND FIRST ub.sysconf No-LOCK WHERE ub.sysconf.host-code = p-curr-host-code No-ERROR.
    IF Not avail ub.sysconf then do:
      message "Не найдена запись о фирме " p-curr-host-code
      view-as alert-box ERROR.
      return error.
    END.
    assign
    SelectCurr:radio-buttons =  "Рубли" + chr(44) + 'rubl':U + chr(44) +
                            "Баз.вал." + chr(44) + 'base':U
    rs-gen-private = 0
    rs-host-obj = 'объект':U
    .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    SelectCurr = v-curr-r-b.
    assign
    glob-val = (if globalcard then one-base-cur-for-objs(output v-glob-curr-code) else yes)
    .
    RUN MYenable in this-procedure .
    run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  RECT-1 :handle
      ) .
    run diasize_init in this-procedure .
    APPLY "VALUE-CHANGED" to SelectCurr.
    display selectCUrr  with frame d-disc.
   WAIT-FOR GO OF FRAME d-disc.
   END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-disc.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY T-legacy T-subsid SelectCurr Rs-gen-private rs-host-obj
          f-smart-info-sums val-title TotalSum lNumCard NumCard NumChk DiscSum
          NettoSum SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum
      WITH FRAME d-disc.
  ENABLE Btn_Cancel B-chk B-print b-history B-help RECT-1 T-legacy T-subsid
         SelectCurr Rs-gen-private rs-host-obj BR-dis-obj-r BR-dis-obj-b
         BR-dis-host-r TotalSum lNumCard NumCard NumChk DiscSum NettoSum
         SaldoSum TotalPay Mustpay CreditSum RestLimit LimitSum
      WITH FRAME d-disc.
  VIEW FRAME d-disc.
  OPEN QUERY BR-dis-host-b FOR EACH htt-dis-card NO-LOCK,              FIRST ub.dis-host WHERE TRUE  NO-LOCK,              EACH ub.sysconf OF ub.dis-host NO-LOCK.    OPEN QUERY BR-dis-host-r FOR EACH hrtt-dis-card NO-LOCK,              FIRST r_dis-host WHERE TRUE  NO-LOCK,              EACH r_sysconf OF r_dis-host NO-LOCK.    OPEN QUERY BR-dis-obj-b FOR EACH tt-dis-card NO-LOCK,              FIRST ub.dis-obj WHERE TRUE  NO-LOCK,              EACH ub.shop OF ub.dis-obj NO-LOCK.    OPEN QUERY BR-dis-obj-r FOR EACH rtt-dis-card NO-LOCK,              FIRST r_dis-obj WHERE TRUE  NO-LOCK,              EACH r_shop OF r_dis-obj NO-LOCK.
END PROCEDURE.
PROCEDURE fill-tables :
define input parameter  t-legacy as logical no-undo.
define input parameter t-subsid as logical no-undo .
define buffer buf_dis-card for ub.dis-card.
for each tt-dis-card :
    delete tt-dis-card.
end.
for each rtt-dis-card :
    delete rtt-dis-card.
end.
for each htt-dis-card :
    delete htt-dis-card.
end.
for each hrtt-dis-card :
    delete hrtt-dis-card.
end.
CASE t-legacy:
  when no then do:
    CASE t-subsid:
      when no then do:
        create tt-dis-card.
        buffer-copy ub.dis-card to tt-dis-card.
        create rtt-dis-card.
        buffer-copy ub.dis-card to rtt-dis-card.
        create htt-dis-card.
        buffer-copy ub.dis-card to htt-dis-card.
        create hrtt-dis-card.
        buffer-copy ub.dis-card to hrtt-dis-card.
        assign
        numcard = 1.
        find first current_dis-card no-lock where recid(current_dis-card) = recid(dis-card).
      end.
      when yes then do:
        assign
        numcard = 0.
        for each buf_dis-card no-lock where buf_dis-card.main-card = ub.dis-card.main-card:
          if buf_dis-card.main-card = buf_dis-card.d-card then do:
            find first current_dis-card no-lock where recid(current_dis-card) = recid(buf_dis-card).
          end.
          create tt-dis-card.
            buffer-copy buf_dis-card to tt-dis-card.
          create rtt-dis-card.
            buffer-copy buf_dis-card to rtt-dis-card.
            create htt-dis-card.
              buffer-copy buf_dis-card to htt-dis-card.
            create hrtt-dis-card.
              buffer-copy buf_dis-card to hrtt-dis-card.
          assign
          numcard = numcard + 1.
        end.
        find first current_dis-card no-lock where recid(current_dis-card) = recid(dis-card).
      end.
    END CASE.
  end.
  when yes then do:
    CASE t-subsid :
      when no then do:
        assign
        numcard = 0.
        for each buf_dis-card no-lock where buf_dis-card.card-num = ub.dis-card.card-num:
          if buf_dis-card.overissue-num = 0 then do:
            find first current_dis-card no-lock where recid(current_dis-card) = recid(ub.dis-card).
          end.
          create tt-dis-card.
            buffer-copy buf_dis-card to tt-dis-card.
          create rtt-dis-card.
            buffer-copy buf_dis-card to rtt-dis-card.
            create htt-dis-card.
              buffer-copy buf_dis-card to htt-dis-card.
            create hrtt-dis-card.
              buffer-copy buf_dis-card to hrtt-dis-card.
          assign
          numcard = numcard + 1.
        end.
      end.
      when yes then do:
        assign
        numcard = 0.
        for each buf_dis-card no-lock where buf_dis-card.first-main-card = ub.dis-card.first-main-card:
          if buf_dis-card.first-main-card = buf_dis-card.d-card then do:
            find first current_dis-card no-lock where recid(current_dis-card) = recid(buf_dis-card).
          end.
          create tt-dis-card.
          buffer-copy buf_dis-card to tt-dis-card.
          create rtt-dis-card.
          buffer-copy buf_dis-card to rtt-dis-card.
          create htt-dis-card.
          buffer-copy buf_dis-card to htt-dis-card.
          create hrtt-dis-card.
          buffer-copy buf_dis-card to hrtt-dis-card.
          assign
          numcard = numcard + 1.
        end.
      end.
    END CASE.
  end.
END CASE.
END PROCEDURE.
PROCEDURE GetSums :
define buffer buf_tt-dis-card for tt-dis-card.
define variable v-exch-rate like ub.curr-accnt.exch-rate no-undo .
define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
define variable v-abbr-curr as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE v-ok-tot-sums AS logical NO-UNDO.
DEFINE VARIABLE v-ok AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-found AS logical NO-UNDO.
define buffer buf_dis-host for ub.dis-host.
assign frame d-disc
t-legacy
t-subsid
.
run fill-tables in this-procedure ( input t-legacy, input t-subsid).
CASE t-legacy:
  when no then do:
    CASE t-subsid:
      when no then do:
        v-ok-tot-sums = YES.
        FOR EACH buf_dis-host no-lock where
                buf_dis-host.d-card = inp-d-card
          and buf_dis-host.host-code > 0
          and (globalcard or buf_dis-host.host-code = p-curr-host-code)
          and buf_dis-host.dt-code = 0
          :
          v-ok  = dc-smart_is-this-correct( INPUT buf_dis-host.dt-code
                                 ,INPUT 'dis-host':U
                                 ,INPUT v-cntxt-db-num
                                 ,INPUT ub.dis-card.TYPE
                                 ,INPUT ub.dis-card.emitent-host-code
                                 ,INPUT (IF buf_Dis-host.host-code > 0 THEN 'орг':U ELSE "")
                                 ,INPUT buf_dis-host.host-code
                                 ,INPUT dis-card.d-card).
          v-ok-tot-sums = v-ok-tot-sums AND (v-ok = "+").
          v-found = YES.
          ACCUMULATE
          buf_dis-host.pay-tot-rubl ( TOTAL )
          buf_dis-host.gds-tot-rubl ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-rubl ( TOTAL )
          buf_dis-host.pay-tot-base ( TOTAL )
          buf_dis-host.gds-tot-base ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-base ( TOTAL )
          .
        END.
      end.
      when yes then do:
        v-ok-tot-sums = YES.
        for each buf_tt-dis-card no-lock where
               buf_tt-dis-card.main-card = ub.dis-card.main-card,
            EACH buf_dis-host no-lock where
                 buf_dis-host.d-card = buf_tt-dis-card.d-card
          and buf_dis-host.host-code > 0
          and buf_dis-host.dt-code = 0
          and (globalcard or buf_dis-host.host-code = p-curr-host-code):
        v-ok  = dc-smart_is-this-correct( INPUT buf_dis-host.dt-code
                               ,INPUT 'dis-host':U
                               ,INPUT v-cntxt-db-num
                               ,INPUT buf_TT-dis-card.TYPE
                               ,INPUT BUF_TT-dis-card.emitent-host-code
                                 ,INPUT (IF buf_Dis-host.host-code > 0 THEN 'орг':U ELSE "")
                                 ,INPUT buf_dis-host.host-code
                                 ,INPUT buf_tt-dis-card.d-card).
        v-ok-tot-sums = v-ok-tot-sums AND (v-ok = "+").
        v-found = YES.
          ACCUMULATE
          buf_dis-host.pay-tot-rubl ( TOTAL )
          buf_dis-host.gds-tot-rubl ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-rubl ( TOTAL )
          buf_dis-host.pay-tot-base ( TOTAL )
          buf_dis-host.gds-tot-base ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-base ( TOTAL )
          .
        END.
      end.
    END CASE.
  end.
  when yes then do:
    CASE t-subsid:
      when no then do:
        v-ok-tot-sums = YES.
        for each buf_tt-dis-card no-lock,
            each buf_dis-host no-lock where
                  buf_dis-host.d-card = buf_tt-dis-card.d-card
              and buf_dis-host.host-code > 0
              AND (globalcard or buf_dis-host.host-code = p-curr-host-code)
              and buf_dis-host.dt-code = 0
              :
            v-ok  = dc-smart_is-this-correct( INPUT buf_dis-host.dt-code
                                   ,INPUT 'dis-host':U
                                   ,INPUT v-cntxt-db-num
                                   ,INPUT buf_TT-dis-card.TYPE
                                   ,INPUT BUF_TT-dis-card.emitent-host-code
                                     ,INPUT (IF buf_Dis-host.host-code > 0 THEN 'орг':U ELSE "")
                                     ,INPUT buf_dis-host.host-code
                                     ,INPUT buf_tt-dis-card.d-card).
            v-ok-tot-sums = v-ok-tot-sums AND (v-ok = "+").
            v-found = YES.
          ACCUMULATE
          buf_dis-host.pay-tot-rubl ( TOTAL )
          buf_dis-host.gds-tot-rubl ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-rubl ( TOTAL )
          buf_dis-host.pay-tot-base ( TOTAL )
          buf_dis-host.gds-tot-base ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-base ( TOTAL )
          .
        end.
      end.
      when yes then do:
        v-ok-tot-sums = YES.
        for each buf_tt-dis-card no-lock
            where  buf_tt-dis-card.first-main-card = ub.dis-card.first-main-card ,
            each buf_dis-host no-lock where
                buf_dis-host.d-card = buf_tt-dis-card.d-card
              and buf_dis-host.host-code > 0
              AND (globalcard or buf_dis-host.host-code = p-curr-host-code)
              and buf_dis-host.dt-code = 0
              :
            v-ok  = dc-smart_is-this-correct( INPUT buf_dis-host.dt-code
                                   ,INPUT 'dis-host':U
                                   ,INPUT v-cntxt-db-num
                                   ,INPUT buf_TT-dis-card.TYPE
                                   ,INPUT BUF_TT-dis-card.emitent-host-code
                                     ,INPUT (IF buf_Dis-host.host-code > 0 THEN 'орг':U ELSE "")
                                     ,INPUT buf_dis-host.host-code
                                     ,INPUT buf_tt-dis-card.d-card).
            v-ok-tot-sums = v-ok-tot-sums AND (v-ok = "+").
            v-found = YES.
          ACCUMULATE
          buf_dis-host.pay-tot-rubl ( TOTAL )
          buf_dis-host.gds-tot-rubl ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-rubl ( TOTAL )
          buf_dis-host.pay-tot-base ( TOTAL )
          buf_dis-host.gds-tot-base ( TOTAL )
          buf_dis-host.num-chk      ( TOTAL )
          buf_dis-host.gds-dis-base ( TOTAL )
          .
        end.
      end.
    END CASE.
  end.
END CASE.
if glob-val then do:
  run cur-time in this-procedure(output v-today, output v-time).
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-glob-curr-code
  ,input  v-today
  ,output v-exch-rate
  ,output v-exch-scale
  ,output v-abbr-curr
  ) no-error .
  if error-status:error then
  v-exch-rate = ?.
end.
else do:
  assign
  v-exch-rate = ?.
end.
if SelectCurr = 'rubl':U then do:
  ASSIGN
  TotalPay = ( ACCUM TOTAL buf_dis-host.pay-tot-rubl)
  TotalSum = ( ACCUM TOTAL buf_dis-host.gds-tot-rubl )
  DiscSum = ( ACCUM TOTAL buf_dis-host.gds-dis-rubl )
  SaldoSUm = dis-card.saldo-rubl
  TotalPayPrim = ( ACCUM TOTAL buf_dis-host.pay-tot-base)
  TotalSumPrim = ( ACCUM TOTAL buf_dis-host.gds-tot-base )
  DiscSumPrim = ( ACCUM TOTAL buf_dis-host.gds-dis-base )
  SaldoSumPrim = dis-card.saldo-base
  .
  ASSIGN NettoSum = TotalSum - DiscSum
  CreditSUm = NettoSum - TotalPay
  MustPay = if saldosum < 0 then (- saldosum) else 0
  NettoSumPrim = TotalSumPrim - DiscSumPrim
  CreditSUmPrim = NettoSumPrim - TotalPayPrim
  MustPayPrim = if saldosumPrim < 0 then (- saldosum) else 0
  NumChk =  ACCUM TOTAL buf_dis-host.num-chk
  .
  IF v-curr-r-b = 'rubl':U THEN DO:
    assign
    LimitSum = current_dis-card.lim-kr
    RestLimit = LimitSum - (if mustpay > 0 then mustpay else 0)
    LimitSumPrim = current_dis-card.lim-kr / v-exch-rate * v-exch-scale
    RestLimitPrim = LimitSumPrim - (if mustpayPrim > 0 then mustpayPrim else 0)
        .
  END.
  else do:
    assign
    LimitSum =  current_dis-card.lim-kr * v-exch-rate / v-exch-scale
    RestLimit = LimitSum - (if mustpay > 0 then mustpay else 0)
    LimitSumPrim =  current_dis-card.lim-kr
    RestLimitPrim = LimitSumPrim - (if mustpayPrim > 0 then mustpayPrim else 0)
    .
  end.
end.
else do:
  ASSIGN
  TotalPay = ( ACCUM TOTAL buf_dis-host.pay-tot-base)
  TotalSum = ( ACCUM TOTAL buf_dis-host.gds-tot-base )
  DiscSum = ( ACCUM TOTAL buf_dis-host.gds-dis-base )
  SaldoSUm = dis-card.saldo-base
  TotalPayPrim = ( ACCUM TOTAL buf_dis-host.pay-tot-rubl)
  TotalSumPrim = ( ACCUM TOTAL buf_dis-host.gds-tot-rubl )
  DiscSumPrim = ( ACCUM TOTAL buf_dis-host.gds-dis-rubl )
  SaldoSumPrim = dis-card.saldo-rubl
  .
  ASSIGN
  NettoSum = TotalSum - DiscSum
  CreditSUm = NettoSum - TotalPay
  MustPay = if SaldoSUm < 0 then (- saldosum) else 0
  NettoSumPrim = TotalSumPrim - DiscSumPrim
  CreditSumPrim = NettoSumPrim - TotalPayPrim
  MustPayPrim = if SaldoSUmPrim < 0 then (- saldosumPrim) else 0
  NumChk =  ACCUM TOTAL buf_dis-host.num-chk .
  IF v-curr-r-b = 'rubl':U THEN DO:
    assign
    LimitSum =  current_dis-card.lim-kr / v-exch-rate * v-exch-scale
    RestLimit = LimitSum - (if mustpay > 0 then mustpay else 0)
    LimitSumPrim =  current_dis-card.lim-kr
    RestLimitPrim = LimitSumPrim - (if mustpayPrim > 0 then mustpayPrim else 0)
    .
  END.
  else do:
    assign
    LimitSum =  current_dis-card.lim-kr
    RestLimit = LimitSum - (if mustpay > 0 then mustpay else 0)
    LimitSumPrim =  current_dis-card.lim-kr * v-exch-rate / v-exch-scale
    RestLimitPrim = LimitSumPrim  - (if mustpayPrim > 0 then mustpayPrim else 0)
    .
  end.
end.
IF NOT (V-OK-TOT-SUMS AND v-found) THEN
DISPLAY
F-SMART-INFO-SUMS
WITH FRAME d-disc.
ELSE
HIDE
F-SMART-INFO-SUMS
in FRAME d-disc.
END PROCEDURE.
PROCEDURE Myenable :
 assign
 SelectCurr:radio-buttons in frame d-disc = "Рубли" + chr(44) + 'rubl':U + chr(44) +
                                                   "Баз.вал." + chr(44) + 'base':U
 rs-host-obj:radio-buttons in frame d-disc = "Объекты" + chr(44) + 'объект':U + chr(44) +
                                                   "Фирмы" + chr(44) + 'фирма':U
 br-dis-obj-r:title in frame d-disc = "В рублях"
 br-dis-host-r:title in frame d-disc = "В рублях"
 .
  DISPLAY
  SelectCurr
  rs-gen-private
  rs-host-obj
  DiscSum
  Mustpay
  NettoSum
  NumChk
  TotalSum
  val-title
  CreditSum
  SaldoSum
  RestLimit
  LimitSum
  WITH FRAME d-disc.
  assign
  ub.dis-obj.num-chk:read-only in browse br-dis-obj-b = yes
  r_dis-obj.num-chk:read-only in browse br-dis-obj-r = yes
  ub.dis-host.num-chk:read-only in browse br-dis-host-b = yes
  r_dis-host.num-chk:read-only in browse br-dis-host-r = yes
 .
  assign
  t-legacy = no
  t-subsid = no
  .
  ENABLE
  B-help
  b-history
  Btn_Cancel
  B-chk
  btn_cost
  B-print
  SelectCurr
  rs-gen-private
  rs-host-obj
  RECT-1 BR-dis-obj-r BR-dis-obj-b DiscSum Mustpay NettoSum NumChk RestLimit LimitSum
  TotalSum
  t-legacy
  t-subsid
  WITH FRAME d-disc.
  VIEW FRAME d-disc.
  assign
  t-legacy = (if p-legacy <> no then yes  else t-legacy)
  t-subsid = (if p-subsid <> no then yes  else t-subsid)
  .
  display
  t-legacy
  t-subsid
  with frame d-disc .
  run fill-tables in this-procedure ( input t-legacy, input t-subsid).
  APPLY "VALUE-CHANGED" to T-legacy.
  IF rs-host-obj = 'объект':U THEN DO:
    hide
    br-dis-host-b
    br-dis-host-r
    in frame d-disc .
  END.
  IF rs-host-obj = 'фирма':U THEN DO:
    hide
    br-dis-obj-b
    br-dis-obj-r
    in frame d-disc .
  END.
 END PROCEDURE.
PROCEDURE OpenBr :
define input parameter p-legacy as logical no-undo.
define input parameter p-is-subsid as logical no-undo .
DEFINE INPUT PARAMETER p-selectcurr AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-gen-private AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-host-obj AS character NO-UNDO.
DISABLE
br-dis-obj-b
br-dis-obj-r
br-dis-host-b
br-dis-host-r
WITH FRAME d-disc.
hide
br-dis-obj-b
br-dis-obj-r
br-dis-host-b
br-dis-host-r
in FRAME d-disc.
IF p-gen-private = 0
AND p-host-obj = 'объект':U THEN DO:
  ASSIGN
  vob:VISIBLE IN BROWSE br-dis-obj-b = NO
  vor:VISIBLE IN BROWSE br-dis-obj-r = NO
  .
  if globalcard then do:
    assign
    FRAME d-disc:title = "Архивы по магазинам"
    .
  end.
  else do:
    assign
    FRAME d-disc:title = "Архивы по магазинам текущей фирмы".
  end.
  assign
  FRAME d-disc:title = FRAME d-disc:title + substitute(" по карте &1 &2 &3 &4"
                                                                      , inp-d-card
                                                                      , (if t-legacy then "с учетом перевыпуска карт" else "":U)
                                                                      , (if t-subsid then "с учетом дополнительных карт" else "":U)
                                                                      , (if ub.dis-card.is-subsid then "(дополнительная карта)" else "")
                                                                      ).
  OPEN QUERY BR-dis-obj-r
  FOR EACH rtt-dis-card,
      EACH r_dis-obj WHERE
            r_dis-obj.d-card = rtt-dis-card.d-card
       AND r_dis-obj.dt-code = 0
      AND (if globalcard then true else r_dis-obj.host-code = p-curr-host-code) NO-LOCK,
        FIRST r_shop WHERE r_shop.obj-code = r_dis-obj.obj-code NO-LOCK
      BY r_dis-obj.d-card
          BY r_dis-obj.obj-type
          BY r_dis-obj.obj-code.
  OPEN QUERY BR-dis-obj-b
  FOR EACH tt-dis-card,
      each  ub.dis-obj  WHERE
            ub.dis-obj.d-card = tt-dis-card.d-card
      AND ub.dis-obj.dt-code = 0
       and
  (if globalcard then true else ub.dis-obj.host-code = p-curr-host-code) NO-LOCK,
       FIRST ub.shop WHERE ub.shop.obj-code = ub.dis-obj.obj-code NO-LOCK
      BY dis-obj.d-card
          BY dis-obj.obj-type
          BY dis-obj.obj-code.
   CASE p-selectcurr:
     WHEN 'rubl':U THEN DO:
       DISPLAY
       br-dis-obj-r
       WITH FRAME d-disc.
       ENABLE
       br-dis-obj-r
       WITH FRAME d-disc.
       APPLY "entry" TO br-dis-obj-r.
     END.
       WHEN 'base':U THEN DO:
         DISPLAY
         br-dis-obj-b
         WITH FRAME d-disc.
         ENABLE
         br-dis-obj-b
         WITH FRAME d-disc.
         APPLY "entry" TO br-dis-obj-b.
       END.
   END CASE.
END.
IF p-gen-private = 1
AND p-host-obj = 'объект':U THEN DO:
  ASSIGN
  vob:VISIBLE IN BROWSE br-dis-obj-b = YES
  vor:VISIBLE IN BROWSE br-dis-obj-r = YES
  .
  if globalcard then do:
    assign
    FRAME d-disc:title = "Архивы частных итогов по магазинам"
    .
  end.
  else do:
    assign
    FRAME d-disc:title = "Архивы частных итогов по магазинам текущей фирмы".
  end.
  assign
  FRAME d-disc:title = FRAME d-disc:title + substitute(" по карте &1 &2 &3 &4"
                                                                      , inp-d-card
                                                                      , (if t-legacy then " с учетом перевыпуска карт" else "":U)
                                                                      , (if t-subsid then " с учетом дополнительных карт" else "":U )
                                                                      , (if ub.dis-card.is-subsid then "(дополнительная карта)" else "")
                                                                      ).
  OPEN QUERY BR-dis-obj-r
  FOR EACH rtt-dis-card,
      EACH r_dis-obj WHERE
            r_dis-obj.d-card = rtt-dis-card.d-card
       and  r_dis-obj.dt-code > 0
       AND (if globalcard then true else r_dis-obj.host-code = p-curr-host-code) NO-LOCK,
        FIRST r_shop WHERE r_shop.obj-code = r_dis-obj.obj-code NO-LOCK
      BY r_dis-obj.d-card
          BY r_dis-obj.obj-type
          BY r_dis-obj.obj-code.
  OPEN QUERY BR-dis-obj-b
  FOR EACH tt-dis-card,
      each  dis-obj  WHERE
            dis-obj.d-card = tt-dis-card.d-card
        and dis-obj.dt-code > 0
        and (if globalcard then true else dis-obj.host-code = p-curr-host-code) NO-LOCK,
        FIRST shop WHERE shop.obj-code = dis-obj.obj-code NO-LOCK
      BY dis-obj.d-card
          BY dis-obj.obj-type
          BY dis-obj.obj-code.
    CASE p-selectcurr:
      WHEN 'rubl':U THEN DO:
        DISPLAY
        br-dis-obj-r
        WITH FRAME d-disc.
        ENABLE
        br-dis-obj-r
        WITH FRAME d-disc.
        APPLY "entry" TO br-dis-obj-r.
      END.
        WHEN 'base':U THEN DO:
          DISPLAY
          br-dis-obj-b
          WITH FRAME d-disc.
          ENABLE
          br-dis-obj-b
          WITH FRAME d-disc.
          APPLY "entry" TO br-dis-obj-b.
        END.
    END CASE.
END.
IF p-gen-private = 0
AND p-host-obj = 'фирма':U THEN DO:
    ASSIGN
    vhb:VISIBLE IN BROWSE br-dis-host-b = NO
    vhr:VISIBLE IN BROWSE br-dis-host-r = NO
    .
  if globalcard then do:
    assign
    FRAME d-disc:title = "Архивы по фирмам"
    .
  end.
  else do:
    assign
    FRAME d-disc:title = "Архивы по фирме".
  end.
  assign
  FRAME d-disc:title = FRAME d-disc:title + substitute(" по карте &1 &2 &3 &4"
                                                                      , inp-d-card
                                                                      , (if t-legacy then " с учетом перевыпуска карт" else "":U)
                                                                      , (if t-subsid then " с учетом дополнительных карт" else "":U)
                                                                      , (if ub.dis-card.is-subsid then "(дополнительная карта)" else "")
                                                                      ).
  OPEN QUERY BR-dis-host-r
  FOR EACH hrtt-dis-card,
      EACH r_dis-host WHERE
            r_dis-host.d-card = hrtt-dis-card.d-card
       AND r_dis-host.dt-code = 0
       and (if globalcard then true else r_dis-host.host-code = p-curr-host-code) NO-LOCK,
        FIRST r_sysconf WHERE r_sysconf.host-code = r_dis-host.host-code NO-LOCK
      BY r_dis-host.d-card
          BY r_dis-host.host-code.
  OPEN QUERY BR-dis-host-b
  FOR EACH htt-dis-card,
      each  ub.dis-host  WHERE
            ub.dis-host.d-card = htt-dis-card.d-card
      and  ub.dis-host.dt-code = 0
      and  (if globalcard then true else ub.dis-host.host-code = p-curr-host-code) NO-LOCK,
        FIRST ub.sysconf WHERE ub.sysconf.host-code = ub.dis-host.host-code NO-LOCK
      BY ub.dis-host.d-card
          BY ub.dis-host.host-code
          .
    CASE p-selectcurr:
      WHEN 'rubl':U THEN DO:
        DISPLAY
        br-dis-host-r
        WITH FRAME d-disc.
        ENABLE
        br-dis-host-r
        WITH FRAME d-disc.
        APPLY "entry" TO br-dis-host-r.
      END.
        WHEN 'base':U THEN DO:
          DISPLAY
          br-dis-host-b
          WITH FRAME d-disc.
          ENABLE
          br-dis-host-b
          WITH FRAME d-disc.
          APPLY "entry" TO br-dis-host-b.
        END.
    END CASE.
  END.
IF p-gen-private = 1
AND p-host-obj = 'фирма':U THEN DO:
  ASSIGN
  vhb:VISIBLE IN BROWSE br-dis-host-b = YES
  vhr:VISIBLE IN BROWSE br-dis-host-r = YES
  .
  if globalcard then do:
    assign
    FRAME d-disc:title = "Архивы частных итогов по фирмам"
    .
  end.
  else do:
    assign
    FRAME d-disc:title = "Архивы частных итогов по фирме".
  end.
  assign
  FRAME d-disc:title = FRAME d-disc:title + substitute(" по карте &1 &2 &3 &4"
                                                                      , inp-d-card
                                                                      , (if t-legacy then " с учетом перевыпуска карт" else "":U)
                                                                      , (if t-subsid then " с учетом дополнительных карт" else "":U)
                                                                      , (if ub.dis-card.is-subsid then "(дополнительная карта)" else "")
                                                                      ).
  OPEN QUERY BR-dis-host-r
  FOR EACH hrtt-dis-card,
      EACH r_dis-host WHERE
            r_dis-host.d-card = hrtt-dis-card.d-card
        and r_dis-host.dt-code > 0
        AND (if globalcard then true else r_dis-host.host-code = p-curr-host-code) NO-LOCK,
        FIRST r_sysconf WHERE r_sysconf.host-code = r_dis-host.host-code NO-LOCK
      BY r_dis-host.d-card
          BY r_dis-host.host-code.
  OPEN QUERY BR-dis-host-b
  FOR EACH htt-dis-card,
      each  dis-host  WHERE
            dis-host.d-card = htt-dis-card.d-card
        and dis-host.dt-code > 0
        and (if globalcard then true else dis-host.host-code = p-curr-host-code) NO-LOCK,
        FIRST sysconf WHERE sysconf.host-code = dis-host.host-code NO-LOCK
      BY dis-host.d-card
          BY dis-host.host-code.
  CASE p-selectcurr:
    WHEN 'rubl':U THEN DO:
      DISPLAY
      br-dis-host-r
      WITH FRAME d-disc.
      ENABLE
      br-dis-host-r
      WITH FRAME d-disc.
      APPLY "entry" TO br-dis-host-r.
    END.
      WHEN 'base':U THEN DO:
        DISPLAY
        br-dis-host-b
        WITH FRAME d-disc.
        ENABLE
        br-dis-host-b
        WITH FRAME d-disc.
        APPLY "entry" TO br-dis-host-b.
      END.
  END CASE.
          .
  END.
CASE (t-legacy or t-subsid):
    when no then do:
        hide
        NumCard in frame d-disc
        lnumcard in frame d-disc.
    end.
    when yes then do:
        display
        NumCard
        lnumcard
        with frame d-disc.
    end.
END CASE.
END PROCEDURE.
PROCEDURE PrintProc :
DEFINE INPUT PARAMETER p-gen-private AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-host-obj AS CHARACTER NO-UNDO.
define variable sym1   as char format "X(1)" init ":".
define variable sym10 as char format "X(1)" init ":".
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-obj-code as integer FORMAT ">>>>9" no-undo.
define variable for-netto like ub.dis-obj.pay-tot-rubl no-undo.
define variable credit-sum like ub.dis-obj.pay-tot-rubl no-undo.
DEFINE VARIABLE v-sum-id AS CHARACTER NO-UNDO.
DEFINE FRAME List
sym1 column-label " " format "X(1)" space(0)
for-obj-code COLUMN-LABEL "Объект!Фирма"
v-sum-id COLUMN-LABEL "Частный итог" FORMAT "X(32)"
ub.dis-obj.gds-tot-rubl COLUMN-LABEL "Сумма товарная"
ub.dis-obj.gds-dis-rubl COLUMN-LABEL "Скидка товарная"
for-netto COLUMN-LABEL "Сумма нетто"
ub.dis-obj.pay-tot-rubl COLUMN-LABEL "Платежи"
credit-sum COLUMn-LABEL "Сумма в кредит"
ub.dis-obj.num-chk
ub.dis-obj.d-card COLUMN-LABEL "№ карты"
sym10 column-label " " format "X(1)"
HEADER  date_string AT 5 format "X(35)"
string( if SelectCurr = 'base':U then "(баз.вал)" else "(рубли)" ) format "X(20)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(193)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 193).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame d-disc:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(193)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME list  .
run waitfram-show in this-procedure ("Ждите...").
CASE p-host-obj:
  WHEN 'объект':U THEN DO:
    GET next br-dis-obj-b.
    DO WHILE available dis-obj :
        DISPLAY STREAM PrnLibStream
        sym1
        dis-obj.obj-code @ for-obj-code
        dct-algo-get-sum-id-from-dt-code(INPUT dis-obj.dt-code) @ v-sum-id
        (if SelectCurr = 'base':U
        then dis-obj.gds-tot-base
        else dis-obj.gds-tot-rubl) @ dis-obj.gds-tot-rubl
        (if SelectCurr = 'base':U
        then dis-obj.gds-dis-base
        else dis-obj.gds-dis-rubl) @ dis-obj.gds-dis-rubl
        (if SelectCurr = 'base':U then
        (dis-obj.gds-tot-base + dis-obj.sum-tot-base -
        dis-obj.gds-dis-base - dis-obj.sum-dis-base)
        else
        (dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl -
        dis-obj.gds-dis-rubl - dis-obj.sum-dis-rubl)) @ for-netto
        (if SelectCurr = 'base':U
        then
        (dis-obj.gds-tot-base + dis-obj.sum-tot-base -
         dis-obj.gds-dis-base - dis-obj.sum-dis-base -
         dis-obj.pay-tot-base)
        else
        (dis-obj.gds-tot-rubl + dis-obj.sum-tot-rubl -
         dis-obj.gds-dis-rubl - dis-obj.sum-dis-rubl -
         dis-obj.pay-tot-rubl)) @ credit-sum
        dis-obj.num-chk
        (if SelectCurr = 'base':U
        then dis-obj.pay-tot-base
        else dis-obj.pay-tot-rubl) @ dis-obj.pay-tot-rubl
        sym10
        dis-obj.d-card
        with FRAME list .
        DOWN STREAM PrnLibStream 1 with FRAME list  .
        GET next br-dis-obj-b.
    END.
  END.
  WHEN 'фирма':U THEN DO:
    GET next br-dis-host-b.
    DO WHILE available dis-obj :
        DISPLAY STREAM PrnLibStream
        sym1
        ub.dis-host.host-code @ for-obj-code
        dct-algo-get-sum-id-from-dt-code(INPUT ub.dis-host.dt-code) @ v-sum-id
        (if SelectCurr = 'base':U
        then ub.dis-host.gds-tot-base
        else ub.dis-host.gds-tot-rubl) @ dis-obj.gds-tot-rubl
        (if SelectCurr = 'base':U
        then ub.dis-host.gds-dis-base
        else ub.dis-host.gds-dis-rubl) @ dis-obj.gds-dis-rubl
        (if SelectCurr = 'base':U then
        (ub.dis-host.gds-tot-base - ub.dis-host.gds-dis-base)
        else
        (ub.dis-host.gds-tot-rubl  - ub.dis-host.gds-dis-rubl )) @ for-netto
        (if SelectCurr = 'base':U
        then
        (ub.dis-host.gds-tot-base - ub.dis-host.gds-dis-base - ub.dis-host.pay-tot-base)
        else
        (ub.dis-host.gds-tot-rubl - ub.dis-host.gds-dis-rubl - ub.dis-host.pay-tot-rubl))
        @ credit-sum
        ub.dis-host.num-chk @ ub.dis-obj.num-chk
        (if SelectCurr = 'base':U
        then ub.dis-host.pay-tot-base
        else ub.dis-host.pay-tot-rubl) @ ub.dis-obj.pay-tot-rubl
        sym10
        ub.dis-host.d-card @ ub.dis-obj.d-card
        with FRAME list .
        DOWN STREAM PrnLibStream 1 with FRAME list  .
        GET next br-dis-host-b.
     END.
  END.
END CASE.
UNDERLINE  STREAM PrnLibStream
sym1
for-obj-code
dis-obj.gds-tot-rubl
dis-obj.gds-dis-rubl
for-netto
dis-obj.pay-tot-rubl
credit-sum
dis-obj.num-chk
sym10
with FRAME list .
DISPLAY STREAM PrnLibStream
sym1
"ИТОГО б.в."  @ for-obj-code
(IF SelectCurr = 'rubl':U or SelectCurr = "" then TotalSumPrim
                                           else TotalSum)
                                            @ dis-obj.gds-tot-rubl
(IF SelectCurr = 'rubl':U or SelectCurr = "" then DiscSumprim
                                           else DiscSum)
                                            @ dis-obj.gds-dis-rubl
(IF SelectCurr = 'rubl':U or SelectCurr = "" then NettoSumPrim else NettoSum) @ for-netto
(IF SelectCurr = 'rubl':U or SelectCurr = "" then TotalPayPrim else TotalPay) @ dis-obj.pay-tot-rubl
(IF SelectCurr = 'rubl':U or SelectCurr = "" then (NettoSumPrim - TotalPayPrim)
                                   else (NettoSum - TotalPay)) @ credit-sum
NumChk @ dis-obj.num-chk
sym10
with frame list.
DOWN STREAM PrnLibStream 1 with FRAME list  .
DISPLAY STREAM PrnLibStream
sym1
"ИТОГО руб"  @ for-obj-code
(IF SelectCurr = 'rubl':U or SelectCurr = "" then TotalSum
                                           else TotalSumPrim)
                                                        @ dis-obj.gds-tot-rubl
(IF SelectCurr = "rubl" or SelectCurr = "" then DiscSum
                                           else DiscSumPrim)
                                                        @ dis-obj.gds-dis-rubl
(IF SelectCurr = "rubl" or SelectCurr = "" then NettoSum else NettoSumPrim) @ for-netto
(IF SelectCurr = "rubl" or SelectCurr = "" then TotalPay else TotalPayPrim) @ dis-obj.pay-tot-rubl
(IF SelectCurr = "rubl" or SelectCurr = "" then (NettoSum - TotalPay)
                           else (NettoSumPrim - TotalPayPrim)) @ credit-sum
NumChk @ dis-obj.num-chk
sym10
with frame list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
