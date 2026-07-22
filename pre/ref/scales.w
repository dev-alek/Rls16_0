DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE input parameter bttns           as    char                       no-undo.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
DEFINE output parameter rid-list    as  char no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник весов".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable ri as recid no-undo .
define variable CmdStr      as char no-undo .
define variable Gds-Option as Char no-undo init "".
define variable PurgOption as Char no-undo init "".
define variable PrintOption as char no-undo init "".
define variable v-doc-rec as recid no-undo .
define variable sendoption as character no-undo .
define variable attr-option as character no-undo .
define variable send-rid-list as character no-undo .
define variable v-rec as recid no-undo .
DEFINE VARIABLE v-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE rum-option   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-scallist AS CHARACTER NO-UNDO.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ProcPricePrint.
define input parameter par-print-option as character no-undo .
define parameter buffer locked_scales for ub.scales.
define variable print-mode as char init "bar"   no-undo .
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.
define variable Line   as char              no-undo.
define variable bar_code as char              no-undo.
define variable obj-attr as char              no-undo.
define variable price as char no-undo .
define variable g#report-num as integer no-undo .
define variable v-type as character no-undo .
DEFINE BUFFER buf_gds-obj-attr FOR ub.gds-obj-attr.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER buf_prod-bc FOR ub.prod-bc.
DEFINE BUFFER buf_scales-gds FOR ub.scales-gds.
define buffer buf_bar-code for ub.bar-code.
DEFINE FRAME List-PLU
sym1 column-label ":" format "x(1)"
buf_scales-gds.PLU-code column-label "PLU" format ">>>9"
v-type COLUMN-LABEL "Тип" format "x(3)"
bar_code COLUMN-LABEL "Вес.код" format "x(7)" space(2)
buf_goods.artic COLUMN-LABEL "Артикул" format "x(16)"
buf_goods.gds-name COLUMN-LABEL "Название" format "x(40)"
price COLUMN-LABEL "Цена продажи" format "x(15)"
sym5 column-label ":" format "x(1)"
obj-attr COLUMN-LABEL "Объект" format "x(9)"
sym6 column-label ":" format "x(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 56 format "X(15)" SKIP
Line format "x(103)" AT 1
with width 160 down use-text stream-io no-box.
DEFINE FRAME List-BAR
sym1 column-label ":" format "x(1)"
bar_code COLUMN-LABEL "Вес.код" format "x(7)"
buf_scales-gds.PLU-code column-label "PLU" format ">>>9" space(2)
v-type COLUMN-LABEL "Тип" format "x(3)"
buf_goods.artic COLUMN-LABEL "Артикул" format "x(16)"
buf_goods.gds-name COLUMN-LABEL "Название" format "x(40)"
price COLUMN-LABEL "Цена продажи" format "x(15)"
sym5 column-label ":" format "x(1)"
obj-attr COLUMN-LABEL "Объект" format "x(9)"
sym6 column-label ":" format "x(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 56 format "X(15)" SKIP
Line format "x(103)" AT 1
with width 160 down use-text stream-io no-box.
DEFINE FRAME List-NAME
sym1 column-label ":" format "x(1)"
buf_goods.artic COLUMN-LABEL "Артикул" format "x(16)"
buf_goods.gds-name COLUMN-LABEL "Название" format "x(40)" space(2)
buf_scales-gds.PLU-code column-label "PLU" format ">>>9"
v-type COLUMN-LABEL "Тип" format "x(3)"
bar_code COLUMN-LABEL "Вес.код" format "x(7)"
price COLUMN-LABEL "Цена продажи" format "x(15)"
sym5 column-label ":" format "x(1)"
obj-attr COLUMN-LABEL "Объект" format "x(9)"
sym6 column-label ":" format "x(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 56 format "X(15)" SKIP
Line format "x(103)" AT 1
with width 160 down use-text stream-io no-box.
Line = fill( "-" , 103 ) .
run ref/scprmode.w ( output print-mode ) .
if print-mode = "отказ" then
    return error .
run waitfram-show in this-procedure ( input "ЖДИТЕ.  Список подготавливается к печати...").
run get-report-num  in parParentProc(output g#report-num).
CASE par-print-option:
  when "scalesman" then do:
    output stream PrnLibStream to value( string( session:temp-directory +
                                        "rpt" + string( g#report-num ) ) )
                                        page-size 24 .
  end.
  when "normal" then dO:
    output stream PrnLibStream to value( string( session:temp-directory +
                                        "rpt" + string( g#report-num ) ) )
                                        page-size 62 .
  end.
end CASE.
FORM HEADER
    Line format "x(103)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 10 SKIP
    with FRAME CliBottomFrame width 103 PAGE-BOTTOM use-text stream-io NO-LABELS no-box.
VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream
substitute( "СПИСОК  КОДОВ  на весах N &1 (БД &2) / &3"
           ,locked_scales.scales-num
           ,locked_scales.db-num
           ,locked_scales.scales-name ) format "x(103)" SKIP.
CASE print-mode :
  when "plu" then do:
    PUT stream PrnLibStream space(4) "( Упорядочен по коду на весах )" SKIP.
    FORM with frame List-PLU .
    FOR EACH buf_scales-gds WHERE
           buf_scales-gds.db-num = locked_scales.db-num AND
           buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = 'scales-code':U AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              NO-LOCK
        , FIRST buf_prod-bc no-lock WHERE
              buf_prod-bc.b-str = buf_gds-obj-attr.attr-value
        BY buf_scales-gds.PLU-code :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  Return error.
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
assign
obj-attr = buf_scales-gds.obj-type + " " + string( buf_scales-gds.obj-code )
price = ( if  gp-price-sale = ?
          then "НЕТ ЦЕНЫ"
          else string( gp-price-sale, "->>>,>>>,>>9.99" ) )
.
DISPLAY stream PrnLibStream
sym1 buf_scales-gds.PLU-code
entry (lookup (string(buf_scales-gds.plu-type), '0,1':U) + 1, ',' + 'Весовой,Штучный':U) @ v-type
buf_goods.artic
(if available buf_prod-bc
then buf_prod-bc.b-str
else (if  available buf_prod-bc
      then buf_prod-bc.b-str
      else chr(63) ))  @ bar_code
caps( buf_goods.gds-name ) @ buf_goods.gds-name
price
sym5 obj-attr
sym6 with frame List-PLU .
DOWN stream PrnLibStream 1 with frame List-PLU .
ACCUMULATE buf_goods.artic( count ).
if ( accum count buf_goods.artic ) modulo 20 = 0 then
run waitfram-show in this-procedure ("Обработано строк списка : " + string ((accum count buf_goods.artic))).
    END.
  end.
  when "bar" then do:
    PUT stream PrnLibStream space(4) "( Упорядочен по весовому коду )" SKIP.
    FORM with frame List-BAR .
    FOR EACH buf_scales-gds WHERE
              buf_scales-gds.db-num = locked_scales.db-num AND
              buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = 'scales-code':U AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              NO-LOCK
      , FIRST buf_prod-bc no-lock WHERE
              buf_prod-bc.b-str = buf_gds-obj-attr.attr-value
         BY buf_prod-bc.b-str :
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  Return error.
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
assign
obj-attr = buf_scales-gds.obj-type + " " + string( buf_scales-gds.obj-code )
price = ( if  gp-price-sale = ?
          then "НЕТ ЦЕНЫ"
          else string( gp-price-sale, "->>>,>>>,>>9.99" ) )
.
DISPLAY stream PrnLibStream
sym1 buf_scales-gds.PLU-code
entry (lookup (string(buf_scales-gds.plu-type), '0,1':U) + 1, ',' + 'Весовой,Штучный':U) @ v-type
buf_goods.artic
(if available buf_prod-bc
then buf_prod-bc.b-str
else (if  available buf_prod-bc
      then buf_prod-bc.b-str
      else chr(63) ))  @ bar_code
caps( buf_goods.gds-name ) @ buf_goods.gds-name
price
sym5 obj-attr
sym6 with frame List-BAR .
DOWN stream PrnLibStream 1 with frame List-BAR .
ACCUMULATE buf_goods.artic( count ).
if ( accum count buf_goods.artic ) modulo 20 = 0 then
run waitfram-show in this-procedure ("Обработано строк списка : " + string ((accum count buf_goods.artic))).
    END.
  end.
  when "name" then do:
    PUT stream PrnLibStream space(4) "( Упорядочен по названию )" SKIP.
    FORM with frame List-NAME .
    FOR EACH buf_scales-gds WHERE
              buf_scales-gds.db-num = locked_scales.db-num AND
              buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = 'scales-code':U AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              NO-LOCK
       , FIRST buf_prod-bc no-lock WHERE
        buf_prod-bc.b-str = buf_gds-obj-attr.attr-value
        BY buf_goods.gds-name :
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  Return error.
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
assign
obj-attr = buf_scales-gds.obj-type + " " + string( buf_scales-gds.obj-code )
price = ( if  gp-price-sale = ?
          then "НЕТ ЦЕНЫ"
          else string( gp-price-sale, "->>>,>>>,>>9.99" ) )
.
DISPLAY stream PrnLibStream
sym1 buf_scales-gds.PLU-code
entry (lookup (string(buf_scales-gds.plu-type), '0,1':U) + 1, ',' + 'Весовой,Штучный':U) @ v-type
buf_goods.artic
(if available buf_prod-bc
then buf_prod-bc.b-str
else (if  available buf_prod-bc
      then buf_prod-bc.b-str
      else chr(63) ))  @ bar_code
caps( buf_goods.gds-name ) @ buf_goods.gds-name
price
sym5 obj-attr
sym6 with frame List-NAME .
DOWN stream PrnLibStream 1 with frame List-NAME .
ACCUMULATE buf_goods.artic( count ).
if ( accum count buf_goods.artic ) modulo 20 = 0 then
run waitfram-show in this-procedure ("Обработано строк списка : " + string ((accum count buf_goods.artic))).
    END.
  end.
  when "group" then do:
    PUT stream PrnLibStream space(4) "( С разбивкой по группам, упорядочен по артикулу )" SKIP.
    FORM with frame List-NAME .
    FOR EACH buf_scales-gds WHERE
              buf_scales-gds.db-num = locked_scales.db-num AND
              buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = 'scales-code':U AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              NO-LOCK
        ,FIRST buf_prod-bc no-lock WHERE
              buf_prod-bc.b-str = buf_gds-obj-attr.attr-value
        BREAK
        BY buf_goods.grp-code
        BY buf_goods.artic:
      IF FIRST-OF(buf_goods.grp-code) then do:
        UNDERLINE stream PrnLibStream
        sym1 buf_scales-gds.PLU-code
        v-type
        buf_goods.artic
        bar_code
        buf_goods.gds-name
        price
        sym5 obj-attr
        sym6 with frame List-NAME .
        DISPLAY stream PrnLibStream
        sym1 " " @ buf_scales-gds.PLU-code
        "Группа " @ buf_goods.artic
        " "  @ bar_code
        CAPS(buf_goods.grp-name)  @ buf_goods.gds-name
        " " @ price
        sym5
        " " @ obj-attr
        sym6 with frame List-NAME .
        DOWN stream PrnLibStream 1 with frame  List-NAME .
        UNDERLINE stream PrnLibStream
        sym1
        buf_scales-gds.PLU-code
        v-type
        buf_goods.artic
        bar_code
        buf_goods.gds-name
        price
        sym5 obj-attr
        sym6 with frame List-NAME .
      end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  Return error.
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
assign
obj-attr = buf_scales-gds.obj-type + " " + string( buf_scales-gds.obj-code )
price = ( if  gp-price-sale = ?
          then "НЕТ ЦЕНЫ"
          else string( gp-price-sale, "->>>,>>>,>>9.99" ) )
.
DISPLAY stream PrnLibStream
sym1 buf_scales-gds.PLU-code
entry (lookup (string(buf_scales-gds.plu-type), '0,1':U) + 1, ',' + 'Весовой,Штучный':U) @ v-type
buf_goods.artic
(if available buf_prod-bc
then buf_prod-bc.b-str
else (if  available buf_prod-bc
      then buf_prod-bc.b-str
      else chr(63) ))  @ bar_code
caps( buf_goods.gds-name ) @ buf_goods.gds-name
price
sym5 obj-attr
sym6 with frame List-NAME .
DOWN stream PrnLibStream 1 with frame List-NAME .
ACCUMULATE buf_goods.artic( count ).
if ( accum count buf_goods.artic ) modulo 20 = 0 then
run waitfram-show in this-procedure ("Обработано строк списка : " + string ((accum count buf_goods.artic))).
    END.
  end.
  when "group-name" then do:
    PUT stream PrnLibStream space(4) "( С разбивкой по группам, упорядочен по названию )" SKIP.
    FORM with frame List-NAME .
    FOR EACH buf_scales-gds WHERE
          buf_scales-gds.db-num = locked_scales.db-num AND
          buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
    FIRST buf_bar-code WHERE
          buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
    FIRST buf_goods WHERE buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
    FIRST buf_gds-obj-attr WHERE
          buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
          buf_gds-obj-attr.attr-code = 'scales-code':U AND
          buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
          buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
          NO-LOCK
    , FIRST buf_prod-bc no-lock WHERE
          buf_prod-bc.b-str = buf_gds-obj-attr.attr-value
    BREAK
    BY buf_goods.grp-code
    BY buf_goods.gds-name:
      IF FIRST-OF(buf_goods.grp-code) then do:
        UNDERLINE stream PrnLibStream
        sym1 buf_scales-gds.PLU-code
        v-type
        buf_goods.artic
        bar_code
        buf_goods.gds-name
        price
        sym5 obj-attr
        sym6 with frame List-NAME .
        DISPLAY stream PrnLibStream
        sym1 " " @ buf_scales-gds.PLU-code
        "Группа " @ buf_goods.artic
        " "  @ bar_code
        CAPS(buf_goods.grp-name)  @ buf_goods.gds-name
        " " @ price
        sym5
        " " @ obj-attr
        sym6 with frame List-NAME .
        DOWN stream PrnLibStream 1 with frame  List-NAME .
        UNDERLINE stream PrnLibStream
        sym1 buf_scales-gds.PLU-code
        v-type
        buf_goods.artic
        bar_code
        buf_goods.gds-name
        price
        sym5 obj-attr
        sym6 with frame List-NAME .
      end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  Return error.
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
assign
obj-attr = buf_scales-gds.obj-type + " " + string( buf_scales-gds.obj-code )
price = ( if  gp-price-sale = ?
          then "НЕТ ЦЕНЫ"
          else string( gp-price-sale, "->>>,>>>,>>9.99" ) )
.
DISPLAY stream PrnLibStream
sym1 buf_scales-gds.PLU-code
entry (lookup (string(buf_scales-gds.plu-type), '0,1':U) + 1, ',' + 'Весовой,Штучный':U) @ v-type
buf_goods.artic
(if available buf_prod-bc
then buf_prod-bc.b-str
else (if  available buf_prod-bc
      then buf_prod-bc.b-str
      else chr(63) ))  @ bar_code
caps( buf_goods.gds-name ) @ buf_goods.gds-name
price
sym5 obj-attr
sym6 with frame List-NAME .
DOWN stream PrnLibStream 1 with frame List-NAME .
ACCUMULATE buf_goods.artic( count ).
if ( accum count buf_goods.artic ) modulo 20 = 0 then
run waitfram-show in this-procedure ("Обработано строк списка : " + string ((accum count buf_goods.artic))).
    END.
  end.
END CASE .
run waitfram-hide in this-procedure .
PUT stream PrnLibStream Line format "x(103)" SKIP.
HIDE stream PrnLibStream FRAME CliBottomFrame .
output stream PrnLibStream close .
END PROCEDURE.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ProcPricePrint-db.
define input parameter par-print-option as character no-undo .
define parameter buffer locked_scales for ub.scales.
define variable print-mode as char init "bar"   no-undo .
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.
define variable Line   as char              no-undo.
define variable bar_code as char              no-undo.
define variable obj-attr as char              no-undo.
define variable price as char no-undo .
define variable g#report-num as integer no-undo .
define variable v-type as character no-undo .
DEFINE BUFFER buf_gds-obj-attr FOR ub.gds-obj-attr.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER buf_prod-bc-db FOR ub.prod-bc-db.
DEFINE BUFFER buf_prod-bc FOR ub.prod-bc.
DEFINE BUFFER buf_scales-gds FOR ub.scales-gds.
define buffer buf_bar-code for ub.bar-code.
DEFINE FRAME List-PLU
sym1 column-label ":" format "x(1)"
buf_scales-gds.PLU-code column-label "PLU" format ">>>9"
v-type COLUMN-LABEL "Тип" format "x(3)"
bar_code COLUMN-LABEL "Вес.код" format "x(7)" space(2)
buf_goods.artic COLUMN-LABEL "Артикул" format "x(16)"
buf_goods.gds-name COLUMN-LABEL "Название" format "x(40)"
price COLUMN-LABEL "Цена продажи" format "x(15)"
sym5 column-label ":" format "x(1)"
obj-attr COLUMN-LABEL "Объект" format "x(9)"
sym6 column-label ":" format "x(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 56 format "X(15)" SKIP
Line format "x(103)" AT 1
with width 160 down use-text stream-io no-box.
DEFINE FRAME List-BAR
sym1 column-label ":" format "x(1)"
bar_code COLUMN-LABEL "Вес.код" format "x(7)"
buf_scales-gds.PLU-code column-label "PLU" format ">>>9" space(2)
v-type COLUMN-LABEL "Тип" format "x(3)"
buf_goods.artic COLUMN-LABEL "Артикул" format "x(16)"
buf_goods.gds-name COLUMN-LABEL "Название" format "x(40)"
price COLUMN-LABEL "Цена продажи" format "x(15)"
sym5 column-label ":" format "x(1)"
obj-attr COLUMN-LABEL "Объект" format "x(9)"
sym6 column-label ":" format "x(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 56 format "X(15)" SKIP
Line format "x(103)" AT 1
with width 160 down use-text stream-io no-box.
DEFINE FRAME List-NAME
sym1 column-label ":" format "x(1)"
buf_goods.artic COLUMN-LABEL "Артикул" format "x(16)"
buf_goods.gds-name COLUMN-LABEL "Название" format "x(40)" space(2)
buf_scales-gds.PLU-code column-label "PLU" format ">>>9"
v-type COLUMN-LABEL "Тип" format "x(3)"
bar_code COLUMN-LABEL "Вес.код" format "x(7)"
price COLUMN-LABEL "Цена продажи" format "x(15)"
sym5 column-label ":" format "x(1)"
obj-attr COLUMN-LABEL "Объект" format "x(9)"
sym6 column-label ":" format "x(1)"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 56 format "X(15)" SKIP
Line format "x(103)" AT 1
with width 160 down use-text stream-io no-box.
Line = fill( "-" , 103 ) .
run ref/scprmode.w ( output print-mode ) .
if print-mode = "отказ" then
    return error .
run waitfram-show in this-procedure ( input "ЖДИТЕ.  Список подготавливается к печати...").
run get-report-num  in parParentProc(output g#report-num).
CASE par-print-option:
  when "scalesman" then do:
    output stream PrnLibStream to value( string( session:temp-directory +
                                        "rpt" + string( g#report-num ) ) )
                                        page-size 24 .
  end.
  when "normal" then dO:
    output stream PrnLibStream to value( string( session:temp-directory +
                                        "rpt" + string( g#report-num ) ) )
                                        page-size 62 .
  end.
end CASE.
FORM HEADER
    Line format "x(103)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 10 SKIP
    with FRAME CliBottomFrame width 103 PAGE-BOTTOM use-text stream-io NO-LABELS no-box.
VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream
substitute( "СПИСОК  КОДОВ  на весах N &1 (БД &2) / &3"
           ,locked_scales.scales-num
           ,locked_scales.db-num
           ,locked_scales.scales-name ) format "x(103)" SKIP.
CASE print-mode :
  when "plu" then do:
    PUT stream PrnLibStream space(4) "( Упорядочен по коду на весах )" SKIP.
    FORM with frame List-PLU .
    FOR EACH buf_scales-gds WHERE
           buf_scales-gds.db-num = locked_scales.db-num AND
           buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = 'scales-code':U AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              NO-LOCK
      BY buf_scales-gds.PLU-code :
        find FIRST buf_prod-bc-db no-lock WHERE
              buf_prod-bc-db.b-str = buf_gds-obj-attr.attr-value
          and buf_prod-bc-db.db-num = locked_scales.db-num  no-error.
       if not available buf_prod-bc-db then do:
         find first buf_prod-bc no-lock where
                  buf_prod-bc.b-code = buf_bar-code.b-code
              and buf_prod-bc.b-str = buf_gds-obj-attr.attr-value no-error.
         if not available buf_prod-bc then next.
       end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  Return error.
end.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
assign
obj-attr = buf_scales-gds.obj-type + " " + string( buf_scales-gds.obj-code )
price = ( if  gp-price-sale = ?
          then "НЕТ ЦЕНЫ"
          else string( gp-price-sale, "->>>,>>>,>>9.99" ) )
.
DISPLAY stream PrnLibStream
sym1 buf_scales-gds.PLU-code
entry (lookup (string(buf_scales-gds.plu-type), '0,1':U) + 1, ',' + 'Весовой,Штучный':U) @ v-type
buf_goods.artic
(if available buf_prod-bc-db
then buf_prod-bc-db.b-str
else (if  available buf_prod-bc
      then buf_prod-bc.b-str
      else chr(63) ))  @ bar_code
caps( buf_goods.gds-name ) @ buf_goods.gds-name
price
sym5 obj-attr
sym6 with frame List-PLU .
DOWN stream PrnLibStream 1 with frame List-PLU .
ACCUMULATE buf_goods.artic( count ).
if ( accum count buf_goods.artic ) modulo 20 = 0 then
run waitfram-show in this-procedure ("Обработано строк списка : " + string ((accum count buf_goods.artic))).
    END.
  end.
  when "bar" then do:
    PUT stream PrnLibStream space(4) "( Упорядочен по весовому коду )" SKIP.
    FORM with frame List-BAR .
    FOR EACH buf_scales-gds WHERE
              buf_scales-gds.db-num = locked_scales.db-num AND
              buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = 'scales-code':U AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              NO-LOCK
        BY buf_gds-obj-attr.attr-value :
       find  FIRST buf_prod-bc-db no-lock WHERE
              buf_prod-bc-db.b-str = buf_gds-obj-attr.attr-value
          and buf_prod-bc-db.db-num = locked_scales.db-num no-error.
       if not available buf_prod-bc-db then do:
         find first buf_prod-bc no-lock where
                  buf_prod-bc.b-code = buf_bar-code.b-code
              and buf_prod-bc.b-str = buf_gds-obj-attr.attr-value no-error.
         if not available buf_prod-bc then next.
       end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  Return error.
end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
assign
obj-attr = buf_scales-gds.obj-type + " " + string( buf_scales-gds.obj-code )
price = ( if  gp-price-sale = ?
          then "НЕТ ЦЕНЫ"
          else string( gp-price-sale, "->>>,>>>,>>9.99" ) )
.
DISPLAY stream PrnLibStream
sym1 buf_scales-gds.PLU-code
entry (lookup (string(buf_scales-gds.plu-type), '0,1':U) + 1, ',' + 'Весовой,Штучный':U) @ v-type
buf_goods.artic
(if available buf_prod-bc-db
then buf_prod-bc-db.b-str
else (if  available buf_prod-bc
      then buf_prod-bc.b-str
      else chr(63) ))  @ bar_code
caps( buf_goods.gds-name ) @ buf_goods.gds-name
price
sym5 obj-attr
sym6 with frame List-BAR .
DOWN stream PrnLibStream 1 with frame List-BAR .
ACCUMULATE buf_goods.artic( count ).
if ( accum count buf_goods.artic ) modulo 20 = 0 then
run waitfram-show in this-procedure ("Обработано строк списка : " + string ((accum count buf_goods.artic))).
    END.
  end.
  when "name" then do:
    PUT stream PrnLibStream space(4) "( Упорядочен по названию )" SKIP.
    FORM with frame List-NAME .
    FOR EACH buf_scales-gds WHERE
              buf_scales-gds.db-num = locked_scales.db-num AND
              buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = 'scales-code':U AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              NO-LOCK
        BY buf_goods.gds-name :
        find FIRST buf_prod-bc-db no-lock WHERE
        buf_prod-bc-db.b-str = buf_gds-obj-attr.attr-value
              and buf_prod-bc-db.db-num = locked_scales.db-num no-error.
       if not available buf_prod-bc-db then do:
         find first buf_prod-bc no-lock where
                  buf_prod-bc.b-code = buf_bar-code.b-code
              and buf_prod-bc.b-str = buf_gds-obj-attr.attr-value no-error.
         if not available buf_prod-bc then next.
       end.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  Return error.
end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
assign
obj-attr = buf_scales-gds.obj-type + " " + string( buf_scales-gds.obj-code )
price = ( if  gp-price-sale = ?
          then "НЕТ ЦЕНЫ"
          else string( gp-price-sale, "->>>,>>>,>>9.99" ) )
.
DISPLAY stream PrnLibStream
sym1 buf_scales-gds.PLU-code
entry (lookup (string(buf_scales-gds.plu-type), '0,1':U) + 1, ',' + 'Весовой,Штучный':U) @ v-type
buf_goods.artic
(if available buf_prod-bc-db
then buf_prod-bc-db.b-str
else (if  available buf_prod-bc
      then buf_prod-bc.b-str
      else chr(63) ))  @ bar_code
caps( buf_goods.gds-name ) @ buf_goods.gds-name
price
sym5 obj-attr
sym6 with frame List-NAME .
DOWN stream PrnLibStream 1 with frame List-NAME .
ACCUMULATE buf_goods.artic( count ).
if ( accum count buf_goods.artic ) modulo 20 = 0 then
run waitfram-show in this-procedure ("Обработано строк списка : " + string ((accum count buf_goods.artic))).
    END.
  end.
  when "group" then do:
    PUT stream PrnLibStream space(4) "( С разбивкой по группам, упорядочен по артикулу )" SKIP.
    FORM with frame List-NAME .
    FOR EACH buf_scales-gds WHERE
              buf_scales-gds.db-num = locked_scales.db-num AND
              buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = 'scales-code':U AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              NO-LOCK
        BREAK
        BY buf_goods.grp-code
        BY buf_goods.artic:
        find FIRST buf_prod-bc-db no-lock WHERE
              buf_prod-bc-db.b-str = buf_gds-obj-attr.attr-value
                            and buf_prod-bc-db.db-num = locked_scales.db-num no-error.
       if not available buf_prod-bc-db then do:
         find first buf_prod-bc no-lock where
                  buf_prod-bc.b-code = buf_bar-code.b-code
              and buf_prod-bc.b-str = buf_gds-obj-attr.attr-value no-error.
         if not available buf_prod-bc then next.
       end.
      IF FIRST-OF(buf_goods.grp-code) then do:
        UNDERLINE stream PrnLibStream
        sym1 buf_scales-gds.PLU-code
        v-type
        buf_goods.artic
        bar_code
        buf_goods.gds-name
        price
        sym5 obj-attr
        sym6 with frame List-NAME .
        DISPLAY stream PrnLibStream
        sym1 " " @ buf_scales-gds.PLU-code
        "Группа " @ buf_goods.artic
        " "  @ bar_code
        CAPS(buf_goods.grp-name)  @ buf_goods.gds-name
        " " @ price
        sym5
        " " @ obj-attr
        sym6 with frame List-NAME .
        DOWN stream PrnLibStream 1 with frame  List-NAME .
        UNDERLINE stream PrnLibStream
        sym1
        buf_scales-gds.PLU-code
        v-type
        buf_goods.artic
        bar_code
        buf_goods.gds-name
        price
        sym5 obj-attr
        sym6 with frame List-NAME .
      end.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  Return error.
end.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
assign
obj-attr = buf_scales-gds.obj-type + " " + string( buf_scales-gds.obj-code )
price = ( if  gp-price-sale = ?
          then "НЕТ ЦЕНЫ"
          else string( gp-price-sale, "->>>,>>>,>>9.99" ) )
.
DISPLAY stream PrnLibStream
sym1 buf_scales-gds.PLU-code
entry (lookup (string(buf_scales-gds.plu-type), '0,1':U) + 1, ',' + 'Весовой,Штучный':U) @ v-type
buf_goods.artic
(if available buf_prod-bc-db
then buf_prod-bc-db.b-str
else (if  available buf_prod-bc
      then buf_prod-bc.b-str
      else chr(63) ))  @ bar_code
caps( buf_goods.gds-name ) @ buf_goods.gds-name
price
sym5 obj-attr
sym6 with frame List-NAME .
DOWN stream PrnLibStream 1 with frame List-NAME .
ACCUMULATE buf_goods.artic( count ).
if ( accum count buf_goods.artic ) modulo 20 = 0 then
run waitfram-show in this-procedure ("Обработано строк списка : " + string ((accum count buf_goods.artic))).
    END.
  end.
  when "group-name" then do:
    PUT stream PrnLibStream space(4) "( С разбивкой по группам, упорядочен по названию )" SKIP.
    FORM with frame List-NAME .
    FOR EACH buf_scales-gds WHERE
          buf_scales-gds.db-num = locked_scales.db-num AND
          buf_scales-gds.scales-num = locked_scales.scales-num NO-LOCK ,
    FIRST buf_bar-code WHERE
          buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
    FIRST buf_goods WHERE buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK,
    FIRST buf_gds-obj-attr WHERE
          buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
          buf_gds-obj-attr.attr-code = 'scales-code':U AND
          buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
          buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
          NO-LOCK
    BREAK
    BY buf_goods.grp-code
    BY buf_goods.gds-name:
    find FIRST buf_prod-bc-db no-lock WHERE
          buf_prod-bc-db.b-str = buf_gds-obj-attr.attr-value
              and buf_prod-bc-db.db-num = locked_scales.db-num no-error.
      if not available buf_prod-bc-db then do:
        find first buf_prod-bc no-lock where
                buf_prod-bc.b-code = buf_bar-code.b-code
            and buf_prod-bc.b-str = buf_gds-obj-attr.attr-value no-error.
        if not available buf_prod-bc then next.
      end.
      IF FIRST-OF(buf_goods.grp-code) then do:
        UNDERLINE stream PrnLibStream
        sym1 buf_scales-gds.PLU-code
        v-type
        buf_goods.artic
        bar_code
        buf_goods.gds-name
        price
        sym5 obj-attr
        sym6 with frame List-NAME .
        DISPLAY stream PrnLibStream
        sym1 " " @ buf_scales-gds.PLU-code
        "Группа " @ buf_goods.artic
        " "  @ bar_code
        CAPS(buf_goods.grp-name)  @ buf_goods.gds-name
        " " @ price
        sym5
        " " @ obj-attr
        sym6 with frame List-NAME .
        DOWN stream PrnLibStream 1 with frame  List-NAME .
        UNDERLINE stream PrnLibStream
        sym1 buf_scales-gds.PLU-code
        v-type
        buf_goods.artic
        bar_code
        buf_goods.gds-name
        price
        sym5 obj-attr
        sym6 with frame List-NAME .
      end.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  Return error.
end.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  Return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
assign
obj-attr = buf_scales-gds.obj-type + " " + string( buf_scales-gds.obj-code )
price = ( if  gp-price-sale = ?
          then "НЕТ ЦЕНЫ"
          else string( gp-price-sale, "->>>,>>>,>>9.99" ) )
.
DISPLAY stream PrnLibStream
sym1 buf_scales-gds.PLU-code
entry (lookup (string(buf_scales-gds.plu-type), '0,1':U) + 1, ',' + 'Весовой,Штучный':U) @ v-type
buf_goods.artic
(if available buf_prod-bc-db
then buf_prod-bc-db.b-str
else (if  available buf_prod-bc
      then buf_prod-bc.b-str
      else chr(63) ))  @ bar_code
caps( buf_goods.gds-name ) @ buf_goods.gds-name
price
sym5 obj-attr
sym6 with frame List-NAME .
DOWN stream PrnLibStream 1 with frame List-NAME .
ACCUMULATE buf_goods.artic( count ).
if ( accum count buf_goods.artic ) modulo 20 = 0 then
run waitfram-show in this-procedure ("Обработано строк списка : " + string ((accum count buf_goods.artic))).
    END.
  end.
END CASE .
run waitfram-hide in this-procedure .
PUT stream PrnLibStream Line format "x(103)" SKIP.
HIDE stream PrnLibStream FRAME CliBottomFrame .
output stream PrnLibStream close .
END PROCEDURE.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE MENU MENU-B-attr
       MENU-ITEM m_lookup       LABEL "Просмотр"
       MENU-ITEM m_update       LABEL "Изменение"     .
DEFINE MENU MENU-B-gds
       MENU-ITEM m___one        LABEL "Товары на весах"
       MENU-ITEM m___all        LABEL "Товары на всех весах БД".
DEFINE MENU MENU-b-price
       MENU-ITEM m_scalesman    LABEL "Для весовщика"
       MENU-ITEM m_normal       LABEL "Обычный"       .
DEFINE MENU MENU-B-purg
       MENU-ITEM m_all          LABEL "Полностью"
       MENU-ITEM m_selective    LABEL "Выборочно"     .
DEFINE MENU MENU-B-rum
       MENU-ITEM m_xml-file-export LABEL "Экспорт в XML-файл"
       RULE
       MENU-ITEM m_xml-file-import LABEL "Импорт из XML-файла".
DEFINE MENU MENU-B-send
       MENU-ITEM m_send_all     LABEL "Все"
       MENU-ITEM m_send_changed LABEL "Измененные"
       MENU-ITEM m_send_selective LABEL "Выборочно"
       RULE
       MENU-ITEM m_send_resend  LABEL "Повторно"      .
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-attr
     LABEL "&Атрибуты"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-gds
     LABEL "&Товары"
     SIZE 10 BY 1.
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-on
     LABEL "&Статус"
     SIZE 10 BY 1.
DEFINE BUTTON b-price
     LABEL "Пра&йслист"
     SIZE 10 BY 1.
DEFINE BUTTON B-purg
     LABEL "&Очистить"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-rum
     LABEL "&Операции над весами"
     SIZE 20 BY 1.
DEFINE BUTTON b-scal-grp
     LABEL "&Группы"
     SIZE 10 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE BUTTON B-send
     LABEL "Пере&слать"
     SIZE 10 BY 1.
DEFINE BUTTON b-ticket
     LABEL "&Ценники"
     SIZE 10 BY 1.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 10  NO-UNDO.
DEFINE VARIABLE Rs-object AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "All",
          "БД", "db",
"Объект", "object"
     SIZE 19 BY 1 NO-UNDO.
DEFINE QUERY BR-scales FOR
      ub.scales SCROLLING.
DEFINE BROWSE BR-scales
  QUERY BR-scales DISPLAY
      IF ( CAN-DO (rid-list, STRING ( recid( scales ) ) ) ) THEN ("*") ELSE (" ") COLUMN-LABEL " *" FORMAT "X(1)":U
      ub.scales.to-send COLUMN-LABEL "И" FORMAT "+/":U
      ub.scales.scales-num FORMAT ">>9":U
      ub.scales.master FORMAT ">>9":U
      ub.scales.scales-name FORMAT "X(35)":U
      ub.scales.tot-gds FORMAT ">>,>>9":U
      entry (lookup (STRING(scales.sts), '0,1,50,99':U), 'тек,удал,блок,удаление':U) COLUMN-LABEL "Статус" FORMAT "X(8)":U
      ub.scales.max-gds FORMAT ">>,>>9":U
      ub.scales.scales-type FORMAT "X(15)":U
      ub.scales.address FORMAT "X(25)":U
      ub.scales.unit-base COLUMN-LABEL "Ед.изм." FORMAT "X(3)":U
      ub.scales.db-num FORMAT ">>>>9":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.93.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     B-mark AT ROW 1 COL 21
     B-add AT ROW 1 COL 24
     B-chg AT ROW 1 COL 34
     B-del AT ROW 1 COL 44
     B-gds AT ROW 1 COL 54
     b-price AT ROW 1 COL 64
     b-scal-grp AT ROW 1 COL 74 WIDGET-ID 2
     B-hist AT ROW 1 COL 92
     B-help AT ROW 1 COL 95
     B-on AT ROW 2 COL 34
     B-purg AT ROW 2 COL 44
     B-send AT ROW 2 COL 54
     b-ticket AT ROW 2 COL 64
     B-rum AT ROW 2 COL 74 WIDGET-ID 4
     Rs-object AT ROW 3 COL 10.5 NO-LABEL WIDGET-ID 6
     B-attr AT ROW 3 COL 74
     BR-scales AT ROW 4.67 COL 1
     mark-num AT ROW 2.13 COL 18.6 COLON-ALIGNED NO-LABEL
     SPACE(72.40) SKIP(20.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник весов"
         DEFAULT-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-attr:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-attr:HANDLE.
ASSIGN
       B-gds:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-gds:HANDLE.
ASSIGN
       b-price:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-price:HANDLE.
ASSIGN
       B-purg:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-purg:HANDLE.
ASSIGN
       B-rum:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-rum:HANDLE.
ASSIGN
       B-send:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-send:HANDLE.
ASSIGN
       scales.address:AUTO-RESIZE IN BROWSE BR-scales = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
 define variable glog as logical no-undo .
 define variable jj as integer no-undo .
 define variable v-rid as recid no-undo .
 def var conf-par as char no-undo.
 def var par-type as char no-undo.
 def buffer bf_scales for ub.scales.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'num-scls'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  '':U
  ,input  yes
  ,output conf-par
  ,output par-type
  ) no-error .
    if error-status:error then do:
        message subst("&1~n&2~n&3~n&4", "Ошибка при получении конф. параметра num-scls", return-value, error-status:GET-MESSAGE (1), ERROR-STATUS:GET-MESSAGE (2))
                view-as alert-box.
        return.
    end.
    if conf-par = "0" then do:
        message "Конф. параметр num-scls запрещает использовать весы."
            view-as alert-box.
        return.
    end.
    jj = br-scales:FOCUSED-ROW .
    run ref/scalesi.w (
                   input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input 'ДОБАВЛЕНИЕ':U
                  ,input v-cntxt-db-num
                  ,input 0
                  ,output v-rid
                  ) no-error .
    if NOT error-status:error
    and v-rid <> ?
    then do:
      Run Openbr in this-procedure .
      REPOSITION br-scales to recid v-rid no-error .
      APPLY "ENTRY" to br-scales.
    end.
END.
ON CHOOSE OF B-attr IN FRAME Dialog-Frame
DO:
    if not available ub.scales THEN return no-apply.
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if attr-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if attr-option = "":U then do:
      return no-apply.
  end.
  IF attr-option = 'ИЗМЕНЕНИЕ':U THEN DO:
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_scales_update':U
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
    if NOT glog then return no-apply.
  END.
  run ref/scl-atti.w (  input parparentproc
                  ,input attr-option
                  ,input ub.scales.db-num
                  ,input ub.scales.scales-num
                 ) NO-ERROR.
  attr-option = "":U.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
define variable v-doc-rec as recid no-undo .
define variable v-rid as recid no-undo .
  if available ub.scales then do:
    assign
    v-doc-rec = recid(scales)
    v-rid = recid(scales)
    .
    run ref/scalesi.w (
                  input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input 'ИЗМЕНЕНИЕ':U
                  ,input scales.db-num
                  ,input scales.scales-num
                  ,output v-rid
                    ) no-error .
    if NOT error-status:error then do:
      Run Openbr in this-procedure .
      reposition br-scales to recid v-doc-rec no-error .
      apply "entry" to br-scales in frame Dialog-Frame .
    end.
  end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
if not available ub.scales then do:
  message "Весы не выбраны.".
  return no-apply.
end.
if can-find ( first ub.scales-gds WHERE
                    ub.scales-gds.db-num = scales.db-num
                AND ub.scales-gds.scales-num = scales.scales-num ) then do:
    message "Есть товары на весах. Удаление невозможно."
    view-as alert-box ERROR .
    return no-apply.
end.
glog = no.
message "Удаление весов. Вы уверены ?"
view-as alert-box question buttons OK-Cancel update glog.
if not glog then return no-apply.
glog = no.
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_scales_deletion':U
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
if not glog then return no-apply.
v-doc-rec = recid (scales).
find scales WHERE recid (scales) = v-doc-rec exclusive.
delete scales.
RUN MyEnable.
apply "entry" to br-scales in frame Dialog-Frame .
END.
ON CHOOSE OF B-gds IN FRAME Dialog-Frame
DO:
define variable goods-lst as character no-undo .
   if Gds-Option = "" then
    run gbl/pop-up.p (self:handle, yes) no-error.
    if Gds-Option = "" then return no-apply.
    case Gds-Option:
        when "ONE":U then do:
            if available ub.scales then do:
                if ub.scales.master > 0 then do:
                    message "Просмотр и изменения товаров на подчиненных весах невозможен"
                    view-as alert-box.
                    Gds-Option = "".
                    return no-apply.
                end.
                ri = recid( ub.scales ) .
                run ref/scalelst.w (
                                input parparentproc
                              , input p-obj-type
                              , input p-obj-code
                              , input scales.db-num
                              , input scales.scales-num
                              , input "b-chg"
                              , input 'все':U
                              , input-output goods-lst ) .
                RUN MyEnable.
                apply "entry" to br-scales in frame Dialog-Frame .
                reposition br-scales to recid ri no-error.
           end.
        end.
        when "ALL":U then do:
            if available ub.scales AND can-find( first ub.scales-gds ) then
            run ref/scalegds.w (
                            input parparentproc
                          , input p-obj-type
                          , input p-obj-code
                          , input scales.db-num
                          ).
            else
            message "В системе не прописаны ни одни весы." SKIP
                    "или нет товаров на весах"
            view-as alert-box WARNING .
        end.
    END CASE.
     Gds-Option = "".
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  define variable rid-list as character no-undo .
    if available ub.scales THEN
    run ref/cscales.w (
                         input parparentproc
                       , INPUT "":U
                       , INPUT "one":U
                       , OUTPUT  rid-list
                       , INPUT ub.scales.db-num
                       , input ub.scales.scales-num
                       , input "":U
                        ).
    apply "entry" to br-scales.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
    if available ub.scales then do:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid55 as character no-undo .
define variable v-num-entry55 as integer   no-undo .
assign
  v-str-recid55 = trim( string( recid( scales ) , "->>>>>>>>>>>9":U ) )
  v-num-entry55 = lookup( v-str-recid55 , rid-list )
.
if v-num-entry55 > 0 then do:
  assign
    entry( v-num-entry55, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid55
  .
end.
      glog = br-scales:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-scales:select-next-row ().
        apply "iteration-changed" to br-scales in frame Dialog-Frame.
      end.
      if num-entries( rid-list ) = 0 then
      hide mark-num in frame Dialog-Frame.
      else
      disp num-entries( rid-list ) @ mark-num with frame Dialog-Frame.
   end.
END.
ON CHOOSE OF B-on IN FRAME Dialog-Frame
DO:
  RUN proc-b-on IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-price IN FRAME Dialog-Frame
DO:
define variable g#report-num as integer no-undo .
define variable glog as logical no-undo .
if not available ub.scales then do:
    message "Весы не выбраны." view-as alert-box WARNING .
    PrintOption = "".
    return no-apply.
end.
if ub.scales.master > 0 then do:
    message "Печать прайс-листа осуществляется только на главныx весах"
    view-as alert-box.
    PrintOption = "".
    return no-apply.
end.
if NOT can-find( first ub.scales-gds where
                       ub.scales-gds.db-num = ub.scales.db-num
                   AND ub.scales-gds.scales-num = ub.scales.scales-num ) then do:
    message
    substitute("НЕТ товаров на весах с номером &1 (БД &2)!"
               ,ub.scales.scales-num
               ,ub.scales.db-num )
    view-as alert-box information .
    PrintOption = "".
    return no-apply.
end.
if PrintOption = "" then do:
   run gbl/pop-up.p (self:handle, yes) no-error.
end.
if PrintOption = "" then return no-apply.
if ub.scales.db-num = v-cntxt-db-num then do:
  RUN ProcPricePrint in this-procedure  ( input PrintOption
                                        ,buffer ub.scales) No-ERROR.
end.
else do:
  RUN ProcPricePrint-db in this-procedure  ( input PrintOption
                                        ,buffer ub.scales) No-ERROR.
end.
IF error-status:error then do:
  PrintOption = "".
  return no-apply.
end.
if PrintOption = "scalesman":U then do:
   run get-report-num  in parParentProc(output g#report-num).
    run adecomm/_osprint.p ( INPUT  ?,
                             INPUT  string( session:temp-directory + "rpt" + string( g#report-num ) ),
                             INPUT  8,
                             INPUT  2,
                             INPUT  0,
                             INPUT  0,
                             OUTPUT glog ).
end.
else do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 0
                                            ).
end.
PrintOption = "".
apply "entry" to br-scales in frame Dialog-Frame .
END.
ON CHOOSE OF B-purg IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
    if PurgOption = "" then
    run gbl/pop-up.p (self:handle, yes) no-error.
    if PurgOption = "" then return no-apply.
    if NOT available ub.scales then do:
            message "Весы не выбраны." view-as alert-box ERROR .
            PurgOption = "".
            return no-apply.
    end.
    if ub.scales.master > 0 then do:
        message "Очистка подчиненных весов осуществляется при очистке главных весов"
        view-as alert-box.
        PurgOption = "".
        return no-apply.
    end.
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_scales_sending':U
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
    if NOT glog then dO:
        PurgOption = "".
        return no-apply.
    end.
    run purg-proc in this-procedure ( buffer scales
                                    , input PurgOption) no-error.
    if error-status:error then do:
      PurgOption = "".
      return no-apply.
    end.
    PurgOption = "".
    apply "entry" to br-scales in frame Dialog-Frame .
END.
ON CHOOSE OF B-rum IN FRAME Dialog-Frame
DO:
  if rum-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if rum-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".
END.
ON CHOOSE OF b-scal-grp IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE ub.scales THEN RETURN NO-APPLY.
  RUN proc-b-scal-grp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
      if rid-list = "" then do:
            if available ub.scales then
                rid-list = string( recid( ub.scales ) ) .
      end.
END.
ON CHOOSE OF B-send IN FRAME Dialog-Frame
DO:
define variable scales-rid as recid no-undo.
define variable glog as logical no-undo .
define variable object-option as character no-undo .
define variable choice as integer no-undo .
define variable goods-lst as character no-undo .
define buffer b-scales for ub.scales.
if SendOption = "" then
run gbl/pop-up.p (self:handle, yes) no-error.
if SendOption = "" then return no-apply.
if not available ub.scales then do:
    message "Весы не выбраны.".
    SendOption = "".
    return no-apply.
end.
if ub.scales.master > 0 then do:
    message
    "Пересылка товаров на подчиненные весы осуществляется при пересылке товаров на главные весы"
    view-as alert-box.
    SendOption = "".
    return no-apply.
end.
define variable vss-include-info57 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_scales_sending':U
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
if NOT glog then do:
    SendOption = "".
    return no-apply.
end.
if SendOption = "SELECTIVE":U then do:
  run ref/scalelst.w ( input parparentproc
                , input p-obj-type
                , input p-obj-code
                , input v-cntxt-db-num
                , input scales.scales-num
                , input "b-sel,b-mark"
                , input 'все':U
                , input-output goods-lst ) .
  if goods-lst = '':U then do:
    return no-apply.
  end.
  send-rid-list = goods-lst.
end.
else do:
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_scales_another_obj':U
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
  if glog then do :
  run gbl/d-askw.w (input "Выбор товаров на весах"
              ,input substitute("Выберите товары на весах №&1 &2"
                                ,scales.scales-num
                                ,scales.scales-name
                                )
              ,input "|"
              ,input substitute("&1&2|Все|Отказ"
                                , p-obj-type
                                , p-obj-code)
              ,input "По текущему объекту|По всем объектам|Отказ"
              ,input 1
              ,input 3
              ,output choice).
  if choice = 3 then do:
    SendOption = "".
    return no-apply.
  end.
  IF choice = 1 THEN OBJECT-option = 'текущие':U.
  IF choice = 2 THEN OBJECT-option = 'все':U.
end.
  else do :
    run gbl/d-askw.w (input "Выбор товаров на весах"
                ,input substitute("Выберите товары на весах №&1 &2"
                                  ,scales.scales-num
                                  ,scales.scales-name
                                  )
                ,input "|"
                ,input substitute("&1&2|Отказ"
                                  , p-obj-type
                                  , p-obj-code)
                ,input "По текущему объекту|Отказ"
                ,input 1
                ,input 2
                ,output choice).
    if choice = 2 then do:
      SendOption = "".
      return no-apply.
    end.
    IF choice = 1 THEN OBJECT-option = 'текущие':U.
  end.
end.
run str/diallog.w (
      input parparentproc
    , input this-procedure
    , input "ref/sendscal.p":U
    , input (p-obj-type + chr(4) + string(p-obj-code) + chr(4) + string(recid(scales)) + chr(4) +
              sendoption + chr(4) + send-rid-list + chr(4) + object-option + chr(4) +
              string(0)
              )
    , input no
    , input "":U
    , input substitute("Отсылка данных на весы")
) no-error.
if error-status:error then do:
    Sendoption = "".
    return no-apply.
end.
IF can-find(first b-scales where
                     b-scales.master = scales.scales-num
                 AND b-scales.db-num = scales.db-num) then do:
  scales-rid = recid(scales).
  run openbr in this-procedure .
  reposition br-scales to recid scales-rid NO-ERROR.
end.
else do:
  DISPLAY
  scales.to-send
  scales.tot-gds
  with BROWSE br-scales .
end.
DISPLAY
scales.to-send
with BROWSE br-scales .
SendOption = "".
apply "entry" to br-scales in frame Dialog-Frame .
END.
ON CHOOSE OF b-ticket IN FRAME Dialog-Frame
DO:
    if available ub.scales
    then do:
      if ub.scales.master > 0 then do:
          message "Печать ценников осуществляется только на главныx весах"
          view-as alert-box.
          return no-apply.
      end.
      if ub.scales.db-num <> v-cntxt-db-num then do:
          message "Печать ценников осуществляется только в БД весов"
          view-as alert-box.
          return no-apply.
      end.
      run rep/tick-scl.p (
                      input parparentproc
                      ,input p-obj-type
                      ,input p-obj-code
                      ,?
                      ,scales.db-num
                      ,scales.scales-num
                      ,"" ) .
    end.
    else
        message "Весы не выбраны." view-as alert-box INFORMATION .
    apply "entry" to br-scales in frame Dialog-Frame .
END.
ON MOUSE-SELECT-DBLCLICK OF BR-scales IN FRAME Dialog-Frame
DO:
    if can-do( bttns, "b-sel" ) then
        apply "choose" to b-sel in frame Dialog-Frame .
    else
        apply "choose" to b-gds in frame Dialog-Frame .
END.
ON RETURN OF BR-scales IN FRAME Dialog-Frame
DO:
    if can-do( bttns, "b-sel" ) then
        apply "choose" to b-sel in frame Dialog-Frame .
    else
        apply "choose" to b-gds in frame Dialog-Frame .
END.
ON MENU-DROP OF MENU MENU-B-gds
DO:
  Gds-Option = "".
END.
ON MENU-DROP OF MENU MENU-b-price
DO:
  PrintOption = "".
END.
ON MENU-DROP OF MENU MENU-B-purg
DO:
  PurgOption = "".
END.
ON MENU-DROP OF MENU MENU-B-send
DO:
    SendOption = "".
END.
ON CHOOSE OF MENU-ITEM m_all
DO:
  assign
  PurgOption = "ALL":U.
  APPLY "CHOOSE" to b-purg in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_lookup
DO:
      assign
  ATTR-option = 'ПРОСМОТР':U
  .
  APPLY "CHOOSE" TO b-attr IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_normal
DO:
  assign
  PRintOption = "NORMAL":U.
  APPLY "CHOOSE" to b-price  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_scalesman
DO:
  assign
  PrintOption = "scalesman":U.
  APPLY "CHOOSE" to b-price  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_selective
DO:
  assign
  PurgOption = "selective":U.
  APPLY "CHOOSE" to b-purg  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_send_all
DO:
  assign
  SendOption = "ALL":U.
  APPLY "CHOOSE" to b-send  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_send_changed
DO:
  assign
  SendOption = "CHANGED":U.
  APPLY "CHOOSE" to b-send  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_send_resend
DO:
  assign
  SendOption = "RESEND":U.
  APPLY "CHOOSE" to b-send  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_send_selective
DO:
  assign
  SendOption = "SELECTIVE":U.
  APPLY "CHOOSE" to b-send  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_update
DO:
      assign
  ATTR-option = 'ИЗМЕНЕНИЕ':U
  .
  APPLY "CHOOSE" TO b-attr IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_xml-file-export
DO:
  rum-option = 'batchwork-export':U.
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".
END.
ON CHOOSE OF MENU-ITEM m_xml-file-import
DO:
  rum-option = 'xml-file-import':U.
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".
END.
ON CHOOSE OF MENU-ITEM m___all
DO:
  assign
  Gds-Option = "ALL":U.
  APPLY "CHOOSE" to b-gds  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m___one
DO:
  assign
  Gds-Option = "ONE":U.
  APPLY "CHOOSE" to b-gds  in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF Rs-object IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
  DEFINE VARIABLE glog  AS LOGICAL NO-UNDO.
  assign
    rs-object
    v-mode = rs-object
  .
  if p-obj-type = 'маг':U then do :
define variable vss-include-info59 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_scales_another_obj':U
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
    if not glog and (rs-object = 'все':U or rs-object = 'db') then do :
      assign
        rs-object = 'объект':U
        v-mode = rs-object
      .
    end.
  end.
  display
    rs-object
  WITH FRAME Dialog-Frame .
  IF AVAILABLE scales  THEN DO:
      v-rec = RECID(scales).
  END.
  RUN openbr IN THIS-PROCEDURE  .
  REPOSITION br-scales  TO RECID v-rec NO-ERROR.
  APPLY "entry" TO br-scales.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-scales :handle
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
define variable vss-include-info63 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info65 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info66 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info67 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info68 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-scales :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  v-rec = recid(ub.scales). run Openbr in this-procedure. reposition br-scales to recid v-rec NO-ERROR. v-rec = ?.                APPLY 'ENTRY' to br-scales. APPLY 'VALUE-CHANGED' to br-scales.
    apply "VALUE-CHANGED" to BR-scales.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  CASE p-mode:
   WHEN 'все':U        THEN DO:
    END.
    when "db":U then do:
    end.
    otherwise do:
            message vss-workfile vss-revision vss-description skip
        "Неверный вызов - p-mode=" p-mode
        view-as alert-box ERROR.
        return.
      end.
    end case.
    v-mode = p-mode.
    RUN MyEnable.
    apply "entry" to br-scales in frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Rs-object mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-sel B-mark B-add B-chg B-del B-gds b-price b-scal-grp B-hist
         B-help B-on B-purg B-send b-ticket B-rum Rs-object B-attr BR-scales
         mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
define variable glog as logical no-undo initial true.
ASSIGN
b-attr:MENU-MOUSE IN frame Dialog-Frame = 1
MENU-ITEM m_update:SENSITIVE IN MENU menu-b-attr = (p-mode = 'db')
b-rum:MENU-MOUSE in frame Dialog-Frame =  1
MENU-ITEM m_xml-file-import:SENSITIVE IN MENU menu-b-rum = no
.
if p-obj-type = 'маг':U then do:
define variable vss-include-info72 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_scales_another_obj':U
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
    rs-object:RADIO-BUTTONS IN FRAME Dialog-Frame = (IF p-mode = 'все':U AND v-cntxt-db-num = 0
                                                      THEN ("Все" + chr(44) + 'все':U + chr(44) +
                                                          "БД" + chr(44) + 'db':U + chr(44) +
                                                            p-obj-type + string(p-obj-code) + chr(44) + 'объект':U)
                                                      ELSE ("БД" + chr(44) + 'db':U + chr(44) +
                                                            p-obj-type + string(p-obj-code) + chr(44) + 'объект':U))
    .
  if p-mode = 'все':U then  do :
    v-mode = p-mode .
  end.
  else do :
    v-mode = 'db' .
  end.
  if glog = true and p-mode = 'все':U AND v-cntxt-db-num = 0 then do :
    assign
      v-mode = 'все':U
      rs-object = 'все':U
    .
  end.
    else do:
      if glog = true then do:
        assign rs-object = 'db':U
               v-mode = 'db':U.
      end.
      else do:
        assign rs-object = 'объект':U
               v-mode = 'объект':U.
      end.
    end.
  if not glog then do :
    MENU-ITEM m___all:SENSITIVE in MENU menu-b-gds = no .
  end.
end.
else do:
  rs-object:RADIO-BUTTONS IN FRAME Dialog-Frame = (IF p-mode = 'все':U AND v-cntxt-db-num = 0
                                                    THEN ("Все" + chr(44) + 'все':U + chr(44) +
                                                        "БД" + chr(44) + 'db':U )
                                                    ELSE ("БД" + chr(44) + 'db':U + chr(44)
                                                          ))
  .
    if p-mode = 'все':U then  do :
      v-mode = p-mode .
end.
    else do :
      v-mode = 'db' .
    end.
end.
DISPLAY
rs-object
mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-mark
b-sel
b-gds
b-send when p-mode = 'db':U
b-quit
b-price
b-help
b-chg  when p-mode = 'db':U
b-purg  when p-mode = 'db':U
b-add   when p-mode = 'db':U
b-del   when p-mode = 'db':U
b-on    when p-mode = 'db':U
b-rum
b-scal-grp
b-hist
br-scales
b-attr
mark-num
b-ticket when p-mode = 'db':U
rs-object
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
RUN Openbr IN THIS-PROCEDURE.
DISABLE
b-mark WHEN NOT can-do( bttns, "b-mark" )
b-sel WHEN NOT can-do( bttns, "b-sel" )
b-send WHEN NOT can-do( bttns, "b-add" )
b-purg WHEN NOT can-do( bttns, "b-add" )
b-chg WHEN NOT can-do( bttns, "b-add" )
b-add WHEN NOT can-do( bttns, "b-add" )
b-del WHEN NOT can-do( bttns, "b-add" )
mark-num WHEN NOT can-do( bttns, "b-mark" )
WITH FRAME Dialog-Frame .
HIDE mark-num in FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE OpenBr :
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
 CASE v-mode:
    WHEN 'все':U THEN DO:
      OPEN QUERY BR-scales FOR EACH ub.scales NO-LOCK.
    END.
    WHEN 'db':U THEN DO:
      OPEN QUERY BR-scales FOR EACH ub.scales NO-LOCK WHERE ub.scales.db-num = v-cntxt-db-num.
    END.
    WHEN 'объект':U THEN DO:
      run adm/shattri.p (
          input "get":U
          ,input  p-obj-type
          ,input  p-obj-code
          ,input  'scale-inf':U
          ,input  'scallist':U
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
      v-scallist = v-value-character.
      delete object v-tth.
          OPEN QUERY BR-scales FOR EACH
          ub.scales NO-LOCK WHERE
          ub.scales.db-num = v-cntxt-db-num
      AND lookup(STRING(ub.scales.scales-num), v-scallist) > 0 .
          .
  END.
END CASE.
END PROCEDURE.
PROCEDURE proc-b-on :
DEFINE VARIABLE loc#log AS LOGICAL NO-UNDO.
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-sts LIKE ub.scales.sts NO-UNDO.
do
on error undo, return error
on stop undo, return error
:
loc#log = no.
define variable vss-include-info73 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_scales_deletion':U
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
  assign
  v-sts = ?
  loc-doc-rec = RECID(ub.scales)
  .
  run ref/scales2.p (
                  input recid(scales)
                  ,input-output v-sts
                 ) no-error .
  if error-status:error then do:
     MESSAGE
     "Ошибка при изменении статуса ВЕСОВ"
     RETURN-VALUE skip
     error-status:get-message(1)
     VIEW-AS ALERT-BOX.
      undo, return error.
  END.
  run openbr in this-procedure.
  REPOSITION br-scales To recid loc-doc-rec No-error.
if available scales then do:
    loc#log = br-scales:select-focused-row( ) IN FRAME Dialog-Frame.
  end.
  apply "ENTRY" to br-scales.
end.
END PROCEDURE.
PROCEDURE proc-b-rum :
define input parameter p-rum-option as character no-undo .
define variable v-radio-button-parameter as character no-undo .
if p-rum-option = 'xml-file-import':U then do:
  v-radio-button-parameter = 'xml-file-import':U.
end.
else do:
  v-radio-button-parameter = 'batchwork-export':U  .
end.
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input "utl/thbjrumr.w":U
    , input 'thref':U + chr(4) + v-radio-button-parameter
    , input no
    , input "&Стоп"
    , input substitute("Операции над весами") ) no-error .
if p-rum-option = 'xml-file-import':U then do:
end.
END PROCEDURE.
PROCEDURE proc-b-scal-grp :
run ref/scal-grp.w (
                input parparentproc
              , input (if v-cntxt-db-num = ub.scales.db-num
                       then 'b-add'
                       else '':U)
              , input v-cntxt-obj-type
              , input v-cntxt-obj-code
              , input 'scales':U
              , input ub.scales.db-num
              , input ub.scales.scales-num
              , input 0  ) no-error .
if error-status :error
then do:
    undo, return error return-value.
end.
END PROCEDURE.
PROCEDURE Purg-proc :
DEFINE parameter buffer loc-scales for ub.scales.
DEFINE INPUT PARAMETER loc-PurgOption as char no-undo.
DEFINE var loc-goods-lst as char no-undo.
define variable qnty-buf as integer no-undo .
define variable for-qnty as character no-undo .
define variable scales-rid as recid no-undo.
define variable glog as logical no-undo .
define buffer b-scales for ub.scales.
glog = FALSE .
if loc-PurgOption = "ALL":U then do:
  message
  substitute("Вы намерены полностью очистить&1"  +
              "весы № &2&1" +
              "Продолжать ?&1"
              ,chr(10)
              ,loc-scales.scales-num)
  view-as alert-box warning buttons yes-no update glog .
end.
else do:
  if can-find(first ub.scales-gds no-lock where
                   ub.scales-gds.scales-num = loc-scales.scales-num
               AND ub.scales-gds.db-num = loc-scales.db-num ) then do:
    assign
    loc-goods-lst = '':U
    .
    run ref/scalelst.w (
                      input parparentproc
                    , input p-obj-type
                    , input p-obj-code
                    , input loc-scales.db-num
                    , input loc-scales.scales-num
                    , input "b-sel,b-mark"
                    , input 'все':U
                    , input-output loc-goods-lst ) .
    if loc-goods-lst <> "" then do:
        message
        "Вы уверены, что хотите удалить с весов выбранные товары!"
        view-as alert-box QUESTION buttons YES-NO update glog.
    end.
    else do:
        message
        "Не найдено товаров, выбранных для очистки!"
        view-as alert-box.
        loc-PurgOption = "".
        return error.
    end.
  end.
end.
if NOT glog then do:
  loc-PurgOption = "".
  return error.
end.
FOR EACH gds-list :
  delete gds-list .
END .
if loc-scales.max-plu = 0 then do:
  if can-find(first ub.scales-gds no-lock where
                    ub.scales-gds.scales-num = loc-scales.scales-num
                AND ub.scales-gds.db-num = loc-scales.db-num) then do:
    message
    substitute("В списке товаров на весах есть товар&1" +
               "но значение поля КОЛИЧЕСТВО ТОВАРА НА ВЕСАХ = 0&1" +
               "вы можете очистить весы, задав количество удаляемых товаров", chr(10))
    view-as alert-box WARNING.
  end.
  assign
  qnty-buf = loc-scales.max-gds
  for-qnty = string(qnty-buf)
  .
  run gbl/d-prompt.w (
    'title=':u + "Сколько удалить" + '\':u
  + 'text1=':u + " Удалить товаров ( начиная с 1-го )" + '\':u
  + 'format=' + ">>>9" + '\':u
  + 'type=' + 'I':U + '\':u
  + 'fillin_row=2\':u
  + 'fillin_col=4\':u
  + 'fillin_width=4\':u
  + 'fillin_height=1\':u
  + 'max-chars=70\':u
  + 'readonly=no\':u
  , input-output for-qnty
  ).
  if return-value = 'false':u then do:
    loc-PurgOption = "".
    return error.
  end.
  qnty-buf = integer(for-qnty).
  if qnty-buf > loc-scales.max-gds then do:
    glog = FALSE .
    message
    substitute("Превышена величина&1"  +
              "максимально допустимой номенклатуры товаров&1"  +
              "для данной марки весов.&1" +
              "Вас это устраивает ?&1&1"
              , chr(10))
            view-as alert-box warning buttons yes-no update glog .
    if NOT glog then do:
        loc-PurgOption = "".
        return error.
    end.
  end.
end.
 else qnty-buf = loc-scales.max-plu .
 run str/diallog.w (
        input parparentproc
      , input this-procedure
      , input "ref/sendscal.p":U
      , input (p-obj-type + chr(4) + string(p-obj-code) + chr(4) + string(recid(ub.scales)) + chr(4) +
                "purge-" + loc-purgoption + chr(4) + loc-goods-lst + chr(4) + '':U + chr(4) +
                string(qnty-buf))
      , input no
      , input "":U
      , input substitute("Очистка весов")
  ) no-error.
IF can-find(first b-scales where
                  b-scales.master = loc-scales.scales-num
              AND b-scales.db-num = loc-scales.db-num) then do:
  scales-rid = recid(b-scales).
  run Openbr in this-procedure .
  reposition br-scales to recid scales-rid NO-ERROR.
end.
else do:
  DISPLAY
  loc-scales.to-send @ scales.to-send
  loc-scales.tot-gds @ scales.tot-gds
  with BROWSE br-scales .
end.
loc-PurgOption = "".
END PROCEDURE.
