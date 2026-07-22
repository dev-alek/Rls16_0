DEFINE TEMP-TABLE x-abc-analysis NO-UNDO LIKE ub.abc-analysis.
DEFINE TEMP-TABLE x-abc-analysis-doc NO-UNDO LIKE ub.abc-analysis-doc.
DEFINE TEMP-TABLE x-abc-analysis-obj NO-UNDO LIKE ub.abc-analysis-obj.
DEFINE TEMP-TABLE x-abc-analysis-period NO-UNDO LIKE ub.abc-analysis-period.
DEFINE BUFFER x-criterion-analysis FOR ub.criterion-analysis.
define input  parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-mode as character no-undo .
define input  parameter p-id     like ub.abc-analysis.abc-id NO-UNDO.
define input  parameter p-db-num like ub.abc-analysis.db-num NO-UNDO.
define input-output parameter p-doc-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма задания параметров для формирования АВСанализа".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
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
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function func-get-name-from-ext-type   returns char
  ( p-ext-type as character   ,
    p-caps     as logical ).
define variable v-ext-name as character no-undo .
run get-name-from-ext-type in this-procedure (
    input p-ext-type  ,
    input p-caps  ,
    output v-ext-name )
    no-error .
    if error-status :error then do:
       assign
         v-ext-name = p-ext-type
       .
    end.
 return (v-ext-name) .
end.
procedure get-name-from-ext-type :
 do
 on error undo, return error return-value
 :
define input  parameter p-ext-type as character no-undo .
define input  parameter p-caps     as logical no-undo   .
define output parameter p-ext-name as character no-undo .
define variable v-num as integer no-undo .
  if lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) = 0 then do :
    message
      vss-include-info10 skip
      "Неправильно задано значение входящего параметра! "
      "Нет такого типа документов " p-ext-type
      view-as alert-box error .
      undo, return error .
  end.
  v-num      = lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) .
  p-ext-name = entry  ( v-num , 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) .
  if p-caps  = true then do :
     p-ext-name = caps(substring(p-ext-name,1,1) ) + substring(p-ext-name, 2 , length (p-ext-name) - 1 ) .
  end .
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-index_name-value no-undo
field name-key  as character
field value-key as character
index pi name-key
.
define temp-table temp-sub-index_name no-undo
field name-key  as character
field nn as integer
index pi nn
.
procedure def-hash :
  do
  on error undo, return error return-value
  :
  define input  parameter p-full-string as character no-undo .
  define output parameter p-possb-keep-string as logical   no-undo .
  define output parameter p-string            as character no-undo .
  define output parameter p-hash-string       as character no-undo .
    p-full-string = trim( p-full-string ) .
    if length (p-full-string ) > 150 then do:
    assign
      p-possb-keep-string =  false
      p-string            =  substring(p-full-string,1,150)
      p-hash-string       =  encode(p-full-string)
    .
    end.
    else do:
    assign
      p-possb-keep-string =  true
      p-string            =  p-full-string
      p-hash-string       =  encode(p-full-string)
    .
    end.
  end.
end procedure.
procedure find-from-hash :
  do
  on error undo, return error return-value
  :
define input  parameter  p-full-string            as character no-undo .
define input  parameter  p-table-name             as character no-undo .
define input  parameter  p-field-possb-keep-name  as character no-undo .
define input  parameter  p-field-string-name      as character no-undo .
define input  parameter  p-field-hash-string-name as character no-undo .
define input  parameter  p-sub-table-name         as character no-undo .
define output parameter  p-recid                  as recid     no-undo .
define variable v-possb-keep-string as logical   no-undo .
define variable v-string            as character no-undo .
define variable v-hash-string       as character no-undo .
define variable v-query-prepare     as character no-undo .
define variable i  as integer no-undo .
define variable qh as widget-handle no-undo .
define variable bh as widget-handle no-undo .
define variable p-rez as logical   no-undo .
run def-hash in this-procedure (input  p-full-string ,
              output v-possb-keep-string ,
              output v-string            ,
              output v-hash-string
              ).
p-recid = ? .
create buffer bh for table p-table-name.
create query qh.
   v-query-prepare =
    "for each " + p-table-name + " no-lock where "
    + p-field-possb-keep-name   + " = "  + string(v-possb-keep-string) + " and "
    + p-field-string-name       + " = '" + v-string            + "' and "
    + p-field-hash-string-name  + " = '" + v-hash-string       + "'"
    .
if v-possb-keep-string = true then do:
    qh:set-buffers(bh).
    qh:query-prepare(v-query-prepare).
    qh:query-open.
    qh:get-first.
    p-recid = bh:recid.
end.
else do:
message false "анализ hash" .
  qh:set-buffers(bh).
  qh:query-prepare(v-query-prepare).
  qh:query-open.
  qh:get-first.
  p-recid = bh:recid.
  repeat :
    qh:get-next.
    if bh:available then do:
       qh:get-first.
       run ver-sub-table in this-procedure (
           input  p-full-string ,
           input  p-table-name ,
           input  p-sub-table-name ,
           input  bh:recid  ,
           output p-rez
           ).
       if p-rez = true  then do:
          p-recid = bh:recid .
          leave.
       end.
       else do:
         next.
       end.
    end.
    leave.
  end.
end.
delete widget bh.
delete widget qh.
  end.
end procedure.
procedure ver-sub-table :
  do
  on error undo, return error return-value
  :
define input  parameter p-full-string as character no-undo .
define input  parameter p-name-table as character no-undo .
define input  parameter p-sub-name-table as character no-undo .
define input  parameter p-recid as recid no-undo .
define output parameter p-ok as logical   no-undo .
define variable v-query-prepare     as character no-undo .
define variable i  as integer no-undo .
define variable qh as widget-handle no-undo .
define variable bh as widget-handle no-undo .
define variable p-rez as logical   no-undo .
for each temp-index_name-value : delete temp-index_name-value . end.
for each temp-sub-index_name : delete temp-sub-index_name . end.
    create buffer bh for table p-name-table.
    create query qh.
    v-query-prepare = "for each " + p-name-table + " no-lock where recid(" + p-name-table + ") = " + string ( p-recid ) .
    qh:set-buffers(bh).
    qh:query-prepare(v-query-prepare).
    qh:query-open.
    qh:get-first.
    p-recid = bh:recid.
define variable v-inf-ind AS CHAR NO-UNDO.
define variable v-name-pi as character no-undo .
define variable v-num-fl-inkey as integer   no-undo .
define variable v-num-fl       as integer   no-undo .
define variable j as integer   no-undo .
v-name-pi = bh:PRIMARY .
v-inf-ind = "1".
i = 0.
DO while ( v-inf-ind <> ? )
    on error undo, return error:
    i = i + 1 .
    v-inf-ind = bh:INDEX-INFORMATION(i) .
    if v-inf-ind = ? then leave.
    if entry( 1 , v-inf-ind ) = v-name-pi then do:
       v-num-fl-inkey = ( num-entries(v-inf-ind) - 4 ) / 2 .
       v-num-fl       = ( num-entries(v-inf-ind) - 4 )     .
      if v-num-fl-inkey >= 1 then do:
          do j = 5 to v-num-fl  by 2 :
              create temp-index_name-value .
              assign
                temp-index_name-value.name-key  = entry( j , v-inf-ind )
                temp-index_name-value.value-key = bh:BUFFER-FIELD(entry( j , v-inf-ind )):BUFFER-VALUE
              .
          end.
       end.
    end.
END.
define variable qh-sub as widget-handle no-undo .
define variable bh-sub as widget-handle no-undo .
    create buffer bh-sub for table p-sub-name-table.
    create query qh-sub.
define variable k as integer   no-undo init 0 .
    v-query-prepare = "for each " + p-sub-name-table + " no-lock where " .
    for each temp-index_name-value :
        v-query-prepare = v-query-prepare  + p-sub-name-table + "." + temp-index_name-value.name-key +
                      " = " + temp-index_name-value.value-key + " and " .
    end.
    v-query-prepare = v-query-prepare + " true = true " .
    qh-sub:set-buffers(bh-sub).
    qh-sub:query-prepare(v-query-prepare).
    qh-sub:query-open.
      v-name-pi = bh-sub:PRIMARY .
      v-inf-ind = "1".
      i = 0.
      DO while ( v-inf-ind <> ? )
          on error undo, return error:
          i = i + 1 .
          v-inf-ind = bh-sub:INDEX-INFORMATION(i) .
          if v-inf-ind = ? then leave.
          if entry( 1 , v-inf-ind ) = v-name-pi then do:
            v-num-fl-inkey = ( num-entries(v-inf-ind) - 4 ) / 2 .
            v-num-fl       = ( num-entries(v-inf-ind) - 4 )     .
            if v-num-fl-inkey >= 1 then do:
                do j = 5 to v-num-fl  by 2 :
                    if not can-find (first temp-index_name-value  where temp-index_name-value.name-key =  entry( j , v-inf-ind )) then do:
                        create temp-sub-index_name .
                        assign
                          temp-sub-index_name.name-key  = entry( j , v-inf-ind )
                          temp-sub-index_name.nn  = j
                        .
                    end.
                end.
            end.
          end.
      END.
      define variable v-qw as character no-undo .
      v-qw = "".
      qh-sub:GET-first.
      DO WHILE (bh-sub:AVAILABLE):
        for each temp-sub-index_name :
            v-qw = v-qw + string(bh-sub:BUFFER-FIELD(temp-sub-index_name.name-key):BUFFER-VALUE) .
        end.
        v-qw = v-qw + ",".
        qh-sub:GET-NEXT.
      END.
      p-ok = false .
      if trim(p-full-string, ",")  =  trim (v-qw, ",") then p-ok = true  .
    delete widget bh-sub.
    delete widget qh-sub.
    delete widget bh.
    delete widget qh.
  end.
end procedure.
PROCEDURE update-rang-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-a as decimal   no-undo .
define input  parameter p-b as decimal   no-undo .
define input  parameter p-c as decimal   no-undo .
define input  parameter p-d as decimal   no-undo .
define input  parameter p-e as decimal   no-undo .
define input  parameter p-f as decimal   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define buffer buf_rang-abc-def     for ub.rang-abc-def.
define buffer buf_rang-abc-def-obj for ub.rang-abc-def-obj.
find first buf_rang-abc-def exclusive-lock where recid(buf_rang-abc-def) = p-recid no-error .
if not available buf_rang-abc-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_rang-abc-def.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
end.
else do:
  assign
      v-exist = true
      p-id = buf_rang-abc-def.raad-id
      p-db = buf_rang-abc-def.db-num
      p-hash-string-obj       = buf_rang-abc-def.raad-hash-string-obj
      p-possb-keep-string-obj = buf_rang-abc-def.raad-possb-keep-string-obj
      p-string-obj            = buf_rang-abc-def.raad-string-obj
  .
end.
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_rang-abc-def.raad-hash-string-obj       = p-hash-string-obj
          buf_rang-abc-def.raad-possb-keep-string-obj = p-possb-keep-string-obj
          buf_rang-abc-def.raad-string-obj            = p-string-obj
          buf_rang-abc-def.raad-a                     = p-a
          buf_rang-abc-def.raad-b                     = p-b
          buf_rang-abc-def.raad-c                     = p-c
          buf_rang-abc-def.raad-d                     = p-d
          buf_rang-abc-def.raad-e                     = p-e
          buf_rang-abc-def.raad-f                     = p-f
          buf_rang-abc-def.raad-id                    = p-id
          buf_rang-abc-def.raad-date                  = v-date
          buf_rang-abc-def.raad-db-num                = g#db-num
          buf_rang-abc-def.db-num                     = p-db
          buf_rang-abc-def.raad-time                  = v-time
          buf_rang-abc-def.raad-who                   = g#userid
      .
if v-exist = true then do:
   for each buf_rang-abc-def-obj exclusive-lock where
            buf_rang-abc-def-obj.raad-id = buf_rang-abc-def.raad-id and
            buf_rang-abc-def-obj.db-num  = buf_rang-abc-def.db-num :
            delete buf_rang-abc-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, "," ).
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_rang-abc-def-obj.
  assign
    buf_rang-abc-def-obj.raad-id  = buf_rang-abc-def.raad-id
    buf_rang-abc-def-obj.db-num   = buf_rang-abc-def.db-num
    buf_rang-abc-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_rang-abc-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
RELEASE buf_rang-abc-def .
END PROCEDURE.
PROCEDURE update-rang-xyz-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-x as decimal   no-undo .
define input  parameter p-y as decimal   no-undo .
define input  parameter p-z as decimal   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define buffer buf_rang-xyz-def     for ub.rang-xyz-def.
define buffer buf_rang-xyz-def-obj for ub.rang-xyz-def-obj.
find first buf_rang-xyz-def exclusive-lock where recid(buf_rang-xyz-def) = p-recid no-error .
if not available buf_rang-xyz-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_rang-xyz-def.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
end.
else do:
  assign
      v-exist = true
      p-id = buf_rang-xyz-def.raxd-id
      p-db = buf_rang-xyz-def.db-num
      p-hash-string-obj       = buf_rang-xyz-def.raxd-hash-string-obj
      p-possb-keep-string-obj = buf_rang-xyz-def.raxd-possb-keep-string-obj
      p-string-obj            = buf_rang-xyz-def.raxd-string-obj
  .
end.
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_rang-xyz-def.raxd-hash-string-obj       = p-hash-string-obj
          buf_rang-xyz-def.raxd-possb-keep-string-obj = p-possb-keep-string-obj
          buf_rang-xyz-def.raxd-string-obj            = p-string-obj
          buf_rang-xyz-def.raxd-x                     = p-x
          buf_rang-xyz-def.raxd-y                     = p-y
          buf_rang-xyz-def.raxd-z                     = p-z
          buf_rang-xyz-def.raxd-id                    = p-id
          buf_rang-xyz-def.raxd-date                  = v-date
          buf_rang-xyz-def.raxd-db-num                = g#db-num
          buf_rang-xyz-def.db-num                     = p-db
          buf_rang-xyz-def.raxd-time                  = v-time
          buf_rang-xyz-def.raxd-who                   = g#userid
      .
if v-exist = true then do:
   for each buf_rang-xyz-def-obj exclusive-lock where
            buf_rang-xyz-def-obj.raxd-id = buf_rang-xyz-def.raxd-id and
            buf_rang-xyz-def-obj.db-num  = buf_rang-xyz-def.db-num :
            delete buf_rang-xyz-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, "," ).
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_rang-xyz-def-obj.
  assign
    buf_rang-xyz-def-obj.raxd-id  = buf_rang-xyz-def.raxd-id
    buf_rang-xyz-def-obj.db-num   = buf_rang-xyz-def.db-num
    buf_rang-xyz-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_rang-xyz-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
RELEASE buf_rang-xyz-def .
END PROCEDURE.
PROCEDURE update-doc-xyz-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-list-doc as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define variable  p-possb-keep-string-doc as logical   no-undo .
define variable  p-string-doc            as character no-undo .
define variable  p-hash-string-doc       as character no-undo .
define buffer buf_doc-xyz-def     for ub.doc-xyz-def.
define buffer buf_doc-xyz-def-obj for ub.doc-xyz-def-obj.
define buffer buf_doc-xyz-def-doc for ub.doc-xyz-def-doc.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
    run def-hash in this-procedure  (
         input   p-list-doc
        ,output  p-possb-keep-string-doc
        ,output  p-string-doc
        ,output  p-hash-string-doc
        ).
find first buf_doc-xyz-def exclusive-lock where recid(buf_doc-xyz-def) = p-recid no-error .
if not available buf_doc-xyz-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_doc-xyz-def.
end.
else do:
  assign
      v-exist = true
      p-id = buf_doc-xyz-def.doxd-id
      p-db = buf_doc-xyz-def.db-num
  .
end .
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_doc-xyz-def.doxd-hash-string-obj       = p-hash-string-obj
          buf_doc-xyz-def.doxd-possb-keep-string-obj = p-possb-keep-string-obj
          buf_doc-xyz-def.doxd-string-obj            = p-string-obj
          buf_doc-xyz-def.doxd-hash-string-doc       = p-hash-string-doc
          buf_doc-xyz-def.doxd-possb-keep-string-doc = p-possb-keep-string-doc
          buf_doc-xyz-def.doxd-string-doc            = p-string-doc
          buf_doc-xyz-def.doxd-id                    = p-id
          buf_doc-xyz-def.doxd-date                  = v-date
          buf_doc-xyz-def.doxd-db-num                = g#db-num
          buf_doc-xyz-def.doxd-time                  = v-time
          buf_doc-xyz-def.doxd-who                   = g#userid
          buf_doc-xyz-def.db-num                     = p-db
      .
if v-exist = true then do:
   for each buf_doc-xyz-def-doc exclusive-lock where
            buf_doc-xyz-def-doc.doxd-id = buf_doc-xyz-def.doxd-id and
            buf_doc-xyz-def-doc.db-num  = buf_doc-xyz-def.db-num :
            delete buf_doc-xyz-def-doc.
   end.
   for each buf_doc-xyz-def-obj exclusive-lock where
            buf_doc-xyz-def-obj.doxd-id = buf_doc-xyz-def.doxd-id and
            buf_doc-xyz-def-obj.db-num  = buf_doc-xyz-def.db-num :
            delete buf_doc-xyz-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, ",")  .
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_doc-xyz-def-obj.
  assign
    buf_doc-xyz-def-obj.doxd-id  = buf_doc-xyz-def.doxd-id
    buf_doc-xyz-def-obj.db-num   = buf_doc-xyz-def.db-num
    buf_doc-xyz-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_doc-xyz-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
p-list-doc = trim(p-list-doc , ",") .
k = num-entries(p-list-doc, ",") .
repeat  i = 1 to k :
  create buf_doc-xyz-def-doc.
  assign
    buf_doc-xyz-def-doc.doxd-id  = buf_doc-xyz-def.doxd-id
    buf_doc-xyz-def-doc.db-num   = buf_doc-xyz-def.db-num
    buf_doc-xyz-def-doc.dxdd-ext-doc-type = entry(i, p-list-doc)
  .
end.
RELEASE buf_doc-xyz-def .
END PROCEDURE.
PROCEDURE update-doc-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-list-doc as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define variable  p-possb-keep-string-doc as logical   no-undo .
define variable  p-string-doc            as character no-undo .
define variable  p-hash-string-doc       as character no-undo .
define buffer buf_doc-abc-def     for ub.doc-abc-def.
define buffer buf_doc-abc-def-obj for ub.doc-abc-def-obj.
define buffer buf_doc-abc-def-doc for ub.doc-abc-def-doc.
    run def-hash  in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
    run def-hash  in this-procedure (
         input   p-list-doc
        ,output  p-possb-keep-string-doc
        ,output  p-string-doc
        ,output  p-hash-string-doc
        ).
find first buf_doc-abc-def exclusive-lock where recid(buf_doc-abc-def) = p-recid no-error .
if not available buf_doc-abc-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_doc-abc-def.
end.
else do:
  assign
      v-exist = true
      p-id = buf_doc-abc-def.doad-id
      p-db = buf_doc-abc-def.db-num
  .
end .
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_doc-abc-def.doad-hash-string-obj       = p-hash-string-obj
          buf_doc-abc-def.doad-possb-keep-string-obj = p-possb-keep-string-obj
          buf_doc-abc-def.doad-string-obj            = p-string-obj
          buf_doc-abc-def.doad-hash-string-doc       = p-hash-string-doc
          buf_doc-abc-def.doad-possb-keep-string-doc = p-possb-keep-string-doc
          buf_doc-abc-def.doad-string-doc            = p-string-doc
          buf_doc-abc-def.doad-id                    = p-id
          buf_doc-abc-def.doad-date                  = v-date
          buf_doc-abc-def.doad-db-num                = g#db-num
          buf_doc-abc-def.doad-time                  = v-time
          buf_doc-abc-def.doad-who                   = g#userid
          buf_doc-abc-def.db-num                     = p-db
      .
if v-exist = true then do:
   for each buf_doc-abc-def-doc exclusive-lock where
            buf_doc-abc-def-doc.doad-id = buf_doc-abc-def.doad-id and
            buf_doc-abc-def-doc.db-num  = buf_doc-abc-def.db-num :
            delete buf_doc-abc-def-doc.
   end.
   for each buf_doc-abc-def-obj exclusive-lock where
            buf_doc-abc-def-obj.doad-id = buf_doc-abc-def.doad-id and
            buf_doc-abc-def-obj.db-num  = buf_doc-abc-def.db-num :
            delete buf_doc-abc-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, ",")  .
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_doc-abc-def-obj.
  assign
    buf_doc-abc-def-obj.doad-id  = buf_doc-abc-def.doad-id
    buf_doc-abc-def-obj.db-num   = buf_doc-abc-def.db-num
    buf_doc-abc-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_doc-abc-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
p-list-doc = trim(p-list-doc , ",") .
k = num-entries(p-list-doc, ",") .
repeat  i = 1 to k :
  create buf_doc-abc-def-doc.
  assign
    buf_doc-abc-def-doc.doad-id  = buf_doc-abc-def.doad-id
    buf_doc-abc-def-doc.db-num   = buf_doc-abc-def.db-num
    buf_doc-abc-def-doc.dadd-ext-doc-type = entry(i, p-list-doc)
  .
end.
RELEASE buf_doc-abc-def .
END PROCEDURE.
PROCEDURE find-def-analysis-obj :
define input  parameter p-type     as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-abc-id   as integer   no-undo .
define output parameter p-db-num   as integer   no-undo .
  do
  on error undo, return error return-value
  :
  if p-type = "abc"  then do:
      define buffer buf_abc-analysis-obj for ub.abc-analysis-obj  .
      define buffer buf_abc-analysis     for ub.abc-analysis      .
      find first buf_abc-analysis-obj no-lock where
                buf_abc-analysis-obj.obj-type = p-obj-type and
                buf_abc-analysis-obj.obj-code = p-obj-code and
                buf_abc-analysis-obj.is-def   = true use-index objdef no-error .
                if available buf_abc-analysis-obj then do:
                    p-abc-id = buf_abc-analysis-obj.abc-id .
                    p-db-num = buf_abc-analysis-obj.db-num .
                end.
                else do:
                    p-abc-id = 0 .
                    p-db-num = 0.
                    return "На объекте нет анализа по умолчанию" .
                end.
  end.
  if p-type = "xyz"  then do:
      define buffer buf_xyz-analysis-obj for ub.xyz-analysis-obj  .
      define buffer buf_xyz-analysis     for ub.xyz-analysis      .
      find first buf_xyz-analysis-obj no-lock where
                buf_xyz-analysis-obj.obj-type = p-obj-type and
                buf_xyz-analysis-obj.obj-code = p-obj-code and
                buf_xyz-analysis-obj.is-def   = true use-index objdef no-error .
                if available buf_xyz-analysis-obj then do:
                    p-abc-id = buf_xyz-analysis-obj.xyz-id .
                    p-db-num = buf_xyz-analysis-obj.db-num .
                end.
                else do:
                    p-abc-id = 0 .
                    p-db-num = 0 .
                    return "На объекте нет анализа по умолчанию" .
                end.
  end.
  return .
end.
END PROCEDURE.
procedure save-def-analysis-obj :
define input  parameter p-type     as character no-undo .
define input  parameter p-db-num   as integer   no-undo .
define input  parameter p-abc-id   as integer   no-undo .
define output parameter v-log      as logical   no-undo .
  do
  on error undo, return error return-value
  :
  v-log = true .
  if p-type = "abc"  then do:
      define buffer buf_abc-analysis-obj for ub.abc-analysis-obj  .
      define buffer buf_abc-obj          for ub.abc-analysis-obj  .
      define buffer buf_abc-analysis     for ub.abc-analysis      .
      for each buf_abc-obj no-lock where
               buf_abc-obj.abc-id = p-abc-id and
               buf_abc-obj.db-num = p-db-num :
            define variable v-exist    as logical   no-undo init false .
            define variable v-list-anal as character no-undo init ""    .
            for each  buf_abc-analysis-obj no-lock where
                      not (buf_abc-analysis-obj.abc-id = p-abc-id and
                           buf_abc-analysis-obj.db-num = p-db-num) and
                      buf_abc-analysis-obj.is-def   = true   and
                      buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                      buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code
                      :
                v-exist    = true .
                v-list-anal = string( buf_abc-analysis-obj.abc-id ) + "," .
            end.
            if v-exist then do:
                message "На объекте "
                buf_abc-obj.obj-type
                buf_abc-obj.obj-code
                skip
                "уже есть анализы по умолчанию , их внутренние номера :" skip
                v-list-anal                                              skip
                "Сделать по умолчанию анализ текущий " p-abc-id " ?"
                view-as alert-box question
                buttons yes-no update v-log .
                if v-log then do:
                    for each  buf_abc-analysis-obj exclusive-lock where
                              buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                              buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code :
                      if ( buf_abc-analysis-obj.abc-id = p-abc-id and
                           buf_abc-analysis-obj.db-num = p-db-num ) then
                              buf_abc-analysis-obj.is-def   = true .
                      else buf_abc-analysis-obj.is-def   = false  .
                    end.
                end.
            end.
            else do:
              for each  buf_abc-analysis-obj exclusive-lock where
                        buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                        buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code and
                        buf_abc-analysis-obj.abc-id = p-abc-id and
                        buf_abc-analysis-obj.db-num = p-db-num
                        :
                  buf_abc-analysis-obj.is-def   = true .
              end.
            end.
      end.
  end.
  if p-type = "xyz"  then do:
      define buffer buf_xyz-analysis-obj for ub.xyz-analysis-obj  .
      define buffer buf_xyz-obj          for ub.xyz-analysis-obj  .
      define buffer buf_xyz-analysis     for ub.xyz-analysis      .
      for each buf_xyz-obj no-lock where
               buf_xyz-obj.xyz-id = p-abc-id and
               buf_xyz-obj.db-num = p-db-num :
            v-exist = false .
            v-list-anal = ""    .
            for each  buf_xyz-analysis-obj no-lock where
                      not (buf_xyz-analysis-obj.xyz-id = p-abc-id and
                           buf_xyz-analysis-obj.db-num = p-db-num) and
                      buf_xyz-analysis-obj.is-def   = true   and
                      buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                      buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code
                      :
                v-exist    = true .
                v-list-anal = string( buf_xyz-analysis-obj.xyz-id ) + "," .
            end.
            if v-exist then do:
                message "На объекте "
                buf_xyz-obj.obj-type
                buf_xyz-obj.obj-code
                skip
                "уже есть анализы по умолчанию , их внутренние номера :" skip
                v-list-anal                                              skip
                "Сделать по умолчанию анализ текущий " p-abc-id " ?"
                view-as alert-box question
                buttons yes-no update v-log .
                if v-log then do:
                    for each  buf_xyz-analysis-obj exclusive-lock where
                              buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                              buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code :
                      if ( buf_xyz-analysis-obj.xyz-id = p-abc-id and
                           buf_xyz-analysis-obj.db-num = p-db-num ) then
                              buf_xyz-analysis-obj.is-def   = true .
                      else buf_xyz-analysis-obj.is-def   = false  .
                    end.
                end.
            end.
            else do:
              for each  buf_xyz-analysis-obj exclusive-lock where
                        buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                        buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code and
                        buf_xyz-analysis-obj.xyz-id = p-abc-id and
                        buf_xyz-analysis-obj.db-num = p-db-num
                        :
                  buf_xyz-analysis-obj.is-def   = true .
              end.
            end.
      end.
  end.
end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info12, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info12, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable p-rid-list    as  char no-undo .
define variable mark-str  AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable filter-point as character no-undo init "Форма задания параметров для АВСанализа" .
define variable filter-point0 as character no-undo init "Форма_задания_параметров_для_АВСанализа" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark as character no-undo .
define variable p-obj  as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status as character no-undo .
define buffer locked_abc-analysis for ub.abc-analysis.
define variable v-last-code as integer   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable par-abc-mode as character no-undo .
define variable par-abc-one  as character no-undo .
define variable par-abc-two  as character no-undo .
define variable par-type     as character no-undo .
define variable v-abc-one as character no-undo .
define temp-table temp-rez no-undo
field n        as int
field ABC      as character
field Sum-cr   as decimal
field Sum_prc  as decimal
field qnty     as decimal
field qnty_prc as decimal
index pi as primary n
.
define variable par-abc-type as character no-undo .
FUNCTION f-name-doc RETURNS CHARACTER
  ( BUFFER buf_abc-analysis-doc FOR  x-abc-analysis-doc   )  FORWARD.
DEFINE BUTTON B-add-doc
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Добавить типы документов".
DEFINE BUTTON B-add-obj
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Добавить объекты".
DEFINE BUTTON B-add-period
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Добавить период".
DEFINE BUTTON B-crt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Справочник критериев анализа".
DEFINE BUTTON B-del-doc
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Удалить тип документа".
DEFINE BUTTON B-del-obj
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Удалить объект".
DEFINE BUTTON B-del-period
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Удалить период".
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Расчет"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-gds-list
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U
     LABEL "?"
     SIZE 3 BY .88.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-rez
     LABEL "Товары"
     SIZE 10 BY 1 TOOLTIP "Просмотр результатов АВСанализа по товарам".
DEFINE BUTTON B-save-doc-typd
     LABEL "Сохранить ТД"
     SIZE 15 BY 1 TOOLTIP "Сохранить список типов док-тов(ТД) по выбранным объектам".
DEFINE BUTTON B-save-rang
     LABEL "Сохранить АВС%"
     SIZE 16.5 BY 1 TOOLTIP "Сохранить соотношение ранжирования(АВС%) по выбранным объектам".
DEFINE VARIABLE F-a AS CHARACTER FORMAT "X(256)":U INITIAL "А=9999"
      VIEW-AS TEXT
     SIZE 6.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-b AS CHARACTER FORMAT "X(256)":U INITIAL "B=9999"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE F-c AS CHARACTER FORMAT "X(256)":U INITIAL "C=9999"
      VIEW-AS TEXT
     SIZE 6.5 BY .67
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE F-d AS CHARACTER FORMAT "X(256)":U INITIAL "D=9999"
      VIEW-AS TEXT
     SIZE 6.5 BY .67
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE F-E AS CHARACTER FORMAT "X(256)":U INITIAL "E=9999"
      VIEW-AS TEXT
     SIZE 6.5 BY .67
     FGCOLOR 5  NO-UNDO.
DEFINE VARIABLE F-F AS CHARACTER FORMAT "X(256)":U INITIAL "F=9999"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 7  NO-UNDO.
DEFINE VARIABLE F-time AS CHARACTER FORMAT "X(5)":U
      VIEW-AS TEXT
     SIZE 6 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Уровни ранжирования нарастающим итогом"
      VIEW-AS TEXT
     SIZE 38.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-10 AS CHARACTER FORMAT "X(256)":U INITIAL "IIб. Отсекание по % во 2й группе:"
      VIEW-AS TEXT
     SIZE 35 BY .67 TOOLTIP "2 этап - Отсечь во 2й группе товыры с низким процентом по критерию"
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-11 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 14.63 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":U INITIAL "Доли по критерию анализа"
      VIEW-AS TEXT
     SIZE 25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-8 AS CHARACTER FORMAT "X(256)":U INITIAL "I.Разбить товары в пропорции:"
      VIEW-AS TEXT
     SIZE 29.5 BY .67 TOOLTIP "1 этап - Разбить товары в пропорции методом ABC"
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-9 AS CHARACTER FORMAT "X(256)":U INITIAL "IIа. ABC-анализ 1й группы:"
      VIEW-AS TEXT
     SIZE 27.5 BY .67 TOOLTIP "2 этап - Разбить товары 1й группы методом ABC"
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-rez AS CHARACTER FORMAT "X(256)":U INITIAL "Результат анализа:"
      VIEW-AS TEXT
     SIZE 19.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-A
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE .13 BY 1.75.
DEFINE RECTANGLE RECT-B
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE .13 BY 1.75.
DEFINE RECTANGLE RECT-C
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE .13 BY 1.75.
DEFINE RECTANGLE RECT-D
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE .13 BY 1.75.
DEFINE RECTANGLE RECT-E
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE .13 BY 1.75.
DEFINE RECTANGLE RECT-f
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE .13 BY 1.75.
DEFINE QUERY BROWSE-obj FOR
      x-abc-analysis-obj SCROLLING.
DEFINE QUERY BROWSE-period FOR
      x-abc-analysis-period SCROLLING.
DEFINE QUERY BROWSE-rez FOR
      temp-rez SCROLLING.
DEFINE QUERY BROWSE-type-doc FOR
      x-abc-analysis-doc SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      x-abc-analysis,
      x-criterion-analysis SCROLLING.
DEFINE BROWSE BROWSE-obj
  QUERY BROWSE-obj NO-LOCK DISPLAY
      x-abc-analysis-obj.obj-type FORMAT "X(3)":U
      x-abc-analysis-obj.obj-code FORMAT ">>>>>>>>9":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 13 BY 5.75
         TITLE "Объекты" ROW-HEIGHT-CHARS .63 EXPANDABLE TOOLTIP "Объекты АВС анализа".
DEFINE BROWSE BROWSE-period
  QUERY BROWSE-period NO-LOCK DISPLAY
      x-abc-analysis-period.abcp-start COLUMN-LABEL "Начало" FORMAT "99/99/99":U
      x-abc-analysis-period.abcp-end COLUMN-LABEL "Конец" FORMAT "99/99/99":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 20 BY 5.75
         TITLE "Интервалы анализа" ROW-HEIGHT-CHARS .63 EXPANDABLE TOOLTIP "Интервалы анализа".
DEFINE BROWSE BROWSE-rez
  QUERY BROWSE-rez DISPLAY
      temp-rez.ABC       COLUMN-LABEL "A!B!C"           FORMAT "x(5)"
      temp-rez.Sum-cr    COLUMN-LABEL "Сумма!группы! "  FORMAT "->>>>>>>>>>9.99"
      temp-rez.Sum_prc   COLUMN-LABEL "Доля!группы! "
      temp-rez.qnty      COLUMN-LABEL "Число!артик.!"    FORMAT ">>>>>>9.99"
      temp-rez.qnty_prc  COLUMN-LABEL "Распределение!номенклатуры!по группам"
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 57.75 BY 8.29 ROW-HEIGHT-CHARS .67 EXPANDABLE.
DEFINE BROWSE BROWSE-type-doc
  QUERY BROWSE-type-doc NO-LOCK DISPLAY
      f-name-doc ( buffer x-abc-analysis-doc) COLUMN-LABEL "Тип документа" FORMAT "x(22)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 25 BY 5.75
         TITLE "Типы документов" ROW-HEIGHT-CHARS .63 EXPANDABLE TOOLTIP "Типы документов анализа".
DEFINE FRAME Dialog-Frame
     BROWSE-rez AT ROW 12.46 COL 1.25
     x-abc-analysis.double-line-proc AT ROW 5.83 COL 59.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9.75 BY .88
     x-abc-analysis.abc-type AT ROW 2.08 COL 39.5 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Простой", "1":U,
"Двухуровневый", "2":U
          SIZE 30 BY .71
          FGCOLOR 4
     FILL-IN-11 AT ROW 5.83 COL 69.75 COLON-ALIGNED NO-LABEL
     FILL-IN-8 AT ROW 5 COL 57.5 COLON-ALIGNED NO-LABEL
     x-abc-analysis.LE-proc AT ROW 16.71 COL 86.38 COLON-ALIGNED
          LABEL "<= %" FORMAT "->>>>9.999"
          VIEW-AS FILL-IN
          SIZE 8 BY .83 TOOLTIP "Ограничение последней группы"
     x-abc-analysis.r-goods AT ROW 18.21 COL 60.5 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "По всем товарам", 1,
"Выборочно", 2
          SIZE 18.5 BY 1.75
     B-gds-list AT ROW 19.21 COL 78.88
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-save-rang AT ROW 1 COL 36.75
     B-save-doc-typd AT ROW 1 COL 53.25
     B-rez AT ROW 1 COL 68.25
     B-Help AT ROW 1 COL 87.5
     x-abc-analysis.abc-name AT ROW 2.92 COL 3
          LABEL "Название анализа"
          VIEW-AS FILL-IN
          SIZE 76.5 BY 1
          FGCOLOR 4
     B-crt AT ROW 4 COL 25
     B-add-obj AT ROW 4.92 COL 1
     B-del-obj AT ROW 4.92 COL 4
     B-add-period AT ROW 4.92 COL 14
     B-del-period AT ROW 4.92 COL 17
     B-add-doc AT ROW 4.92 COL 34.5
     B-del-doc AT ROW 4.92 COL 37.5
     BROWSE-obj AT ROW 5.96 COL 1
     BROWSE-period AT ROW 5.96 COL 14
     BROWSE-type-doc AT ROW 5.96 COL 34
     x-abc-analysis.abc-a AT ROW 9 COL 61 COLON-ALIGNED
          LABEL "A" FORMAT ">9.9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     x-abc-analysis.abc-b AT ROW 9 COL 73 COLON-ALIGNED
          LABEL "B" FORMAT ">9.9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     x-abc-analysis.abc-c AT ROW 9 COL 86 COLON-ALIGNED
          LABEL "C" FORMAT ">9.9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     x-abc-analysis.abc-d AT ROW 10 COL 61 COLON-ALIGNED
          LABEL "D" FORMAT ">9.9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     x-abc-analysis.abc-e AT ROW 10 COL 73 COLON-ALIGNED
          LABEL "E" FORMAT ">9.9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     x-abc-analysis.abc-des AT ROW 20.75 COL 45.5 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 52.5 BY 2
     x-abc-analysis.abc-id AT ROW 2.25 COL 19 COLON-ALIGNED
          LABEL "Вн.код ABC анализа"
           VIEW-AS TEXT
          SIZE 14 BY .67
     x-abc-analysis.cral-id AT ROW 4.13 COL 19.5 COLON-ALIGNED
          LABEL "Критерий анализа" FORMAT ">>9"
           VIEW-AS TEXT
          SIZE 3 BY .67
     x-criterion-analysis.cral-name AT ROW 4.25 COL 26.5 COLON-ALIGNED NO-LABEL FORMAT "X(50)"
           VIEW-AS TEXT
          SIZE 68 BY .67
     FILL-IN-1 AT ROW 7.75 COL 59.5 NO-LABEL
     FILL-IN-2 AT ROW 9 COL 67.25 COLON-ALIGNED NO-LABEL
     FILL-IN-4 AT ROW 9 COL 92.25 COLON-ALIGNED NO-LABEL
     FILL-IN-6 AT ROW 10 COL 79.25 COLON-ALIGNED NO-LABEL
     FILL-IN-3 AT ROW 9 COL 79.25 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .
DEFINE FRAME Dialog-Frame
     FILL-IN-5 AT ROW 10 COL 67.25 COLON-ALIGNED NO-LABEL
     F-a AT ROW 14 COL 58.5 COLON-ALIGNED NO-LABEL
     F-b AT ROW 14 COL 66 COLON-ALIGNED NO-LABEL
     F-c AT ROW 14 COL 73.5 COLON-ALIGNED NO-LABEL
     F-d AT ROW 14 COL 81 COLON-ALIGNED NO-LABEL
     F-E AT ROW 14 COL 88.5 COLON-ALIGNED NO-LABEL
     F-F AT ROW 15 COL 73.5 COLON-ALIGNED NO-LABEL
     FILL-rez AT ROW 11.71 COL 1.5 NO-LABEL
     x-abc-analysis.abc-who-create AT ROW 20.8 COL 23.5 COLON-ALIGNED FORMAT "X(15)"
           VIEW-AS TEXT
          SIZE 14 BY .67
     x-abc-analysis.abc-date-create AT ROW 21.5 COL 23.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 13 BY .67
     F-time AT ROW 21.5 COL 37 COLON-ALIGNED NO-LABEL
     x-abc-analysis.abc-db-num-create AT ROW 22.25 COL 23.5 COLON-ALIGNED
          LABEL "БД создания анализа"
           VIEW-AS TEXT
          SIZE 3 BY .67
     FILL-IN-7 AT ROW 11.25 COL 60.5 NO-LABEL
     FILL-IN-9 AT ROW 6.92 COL 59.5 COLON-ALIGNED NO-LABEL
     FILL-IN-10 AT ROW 15.92 COL 59.5 COLON-ALIGNED NO-LABEL
     RECT-f AT ROW 12.25 COL 60.5
     RECT-E AT ROW 12.25 COL 60.5
     RECT-D AT ROW 12.25 COL 60.5
     RECT-C AT ROW 12.25 COL 60.5
     RECT-B AT ROW 12.25 COL 60.5
     RECT-A AT ROW 12.25 COL 60.5
     SPACE(39.36) SKIP(8.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список ABC-анализов".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       F-a:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       F-b:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       F-c:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       F-d:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       F-E:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       F-F:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       FILL-IN-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       FILL-IN-11:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       FILL-IN-7:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON LEAVE OF x-abc-analysis.abc-a IN FRAME Dialog-Frame
DO:
    ASSIGN x-abc-analysis.abc-a
           x-abc-analysis.abc-b
           x-abc-analysis.abc-c
           x-abc-analysis.abc-d
           x-abc-analysis.abc-e
           .
  RUN proc-sel-rec
  ( x-abc-analysis.abc-a,
    x-abc-analysis.abc-b,
    x-abc-analysis.abc-c,
    x-abc-analysis.abc-d,
    x-abc-analysis.abc-e
    )  no-error .
  if error-status :error then message return-value .
END.
ON return OF x-abc-analysis.abc-a IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  x-abc-analysis.abc-a:handle ) .
  return no-apply .
END.
ON LEAVE OF x-abc-analysis.abc-b IN FRAME Dialog-Frame
DO:
        ASSIGN x-abc-analysis.abc-a x-abc-analysis.abc-b x-abc-analysis.abc-c x-abc-analysis.abc-d x-abc-analysis.abc-e  .
  RUN proc-sel-rec
  ( x-abc-analysis.abc-a,
    x-abc-analysis.abc-b,
    x-abc-analysis.abc-c,
    x-abc-analysis.abc-d,
    x-abc-analysis.abc-e
    )  no-error .
  if error-status :error then message return-value .
END.
ON return OF x-abc-analysis.abc-b IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  x-abc-analysis.abc-b:handle ) .
  return no-apply .
END.
ON LEAVE OF x-abc-analysis.abc-c IN FRAME Dialog-Frame
DO:
    ASSIGN x-abc-analysis.abc-a x-abc-analysis.abc-b x-abc-analysis.abc-c x-abc-analysis.abc-d x-abc-analysis.abc-e  .
RUN proc-sel-rec
( x-abc-analysis.abc-a,
x-abc-analysis.abc-b,
x-abc-analysis.abc-c,
x-abc-analysis.abc-d,
x-abc-analysis.abc-e
)  no-error .
if error-status :error then message return-value .
END.
ON return OF x-abc-analysis.abc-c IN FRAME Dialog-Frame
DO:
 run next-focus in this-procedure  (input  x-abc-analysis.abc-c:handle ) .
 return no-apply .
END.
ON LEAVE OF x-abc-analysis.abc-d IN FRAME Dialog-Frame
DO:
    ASSIGN x-abc-analysis.abc-a x-abc-analysis.abc-b x-abc-analysis.abc-c x-abc-analysis.abc-d x-abc-analysis.abc-e  .
RUN proc-sel-rec
( x-abc-analysis.abc-a,
x-abc-analysis.abc-b,
x-abc-analysis.abc-c,
x-abc-analysis.abc-d,
x-abc-analysis.abc-e
)  no-error .
if error-status :error then message return-value .
END.
ON return OF x-abc-analysis.abc-d IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  x-abc-analysis.abc-d:handle ) .
 return no-apply .
END.
ON return OF x-abc-analysis.abc-des IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  x-abc-analysis.abc-des:handle ) .
  return no-apply .
END.
ON LEAVE OF x-abc-analysis.abc-e IN FRAME Dialog-Frame
DO:
    ASSIGN x-abc-analysis.abc-a x-abc-analysis.abc-b x-abc-analysis.abc-c x-abc-analysis.abc-d x-abc-analysis.abc-e  .
RUN proc-sel-rec
( x-abc-analysis.abc-a,
x-abc-analysis.abc-b,
x-abc-analysis.abc-c,
x-abc-analysis.abc-d,
x-abc-analysis.abc-e
)  no-error .
if error-status :error then message return-value .
END.
ON return OF x-abc-analysis.abc-e IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  x-abc-analysis.abc-e:handle ) .
 return no-apply .
END.
ON return OF x-abc-analysis.abc-name IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  x-abc-analysis.abc-name:handle ) .
  return no-apply .
END.
ON VALUE-CHANGED OF x-abc-analysis.abc-type IN FRAME Dialog-Frame
DO:
  ASSIGN x-abc-analysis.abc-type .
  if x-abc-analysis.abc-type = "2" then do:
      display FILL-IN-10 FILL-IN-11 FILL-IN-8 FILL-IN-9 x-abc-analysis.LE-proc  x-abc-analysis.double-line-proc
      with FRAME Dialog-Frame .
      enable  x-abc-analysis.LE-proc x-abc-analysis.double-line-proc  with FRAME Dialog-Frame .
   end.
  else do:
      HIDE FILL-IN-10 FILL-IN-11 FILL-IN-8 FILL-IN-9 x-abc-analysis.LE-proc x-abc-analysis.double-line-proc
      IN FRAME Dialog-Frame .
  end.
END.
ON CHOOSE OF B-add-doc IN FRAME Dialog-Frame
DO:
define variable  pattr-codes as character no-undo.
define variable pattr-labels as character no-undo.
define variable ppresel-codes as character no-undo.
define variable  psel-codes as character no-undo.
pattr-codes      =  'ee,es,re,rs,we':u .
pattr-labels     =  'расход внешний,касса продажа,возврат внешний,касса возврат,списание':u .
if p-id = ? then p-id = 1 .
  run gbl/d-list.w (
      "b-sel,b-mark"     ,
      "Расширенный тип"  ,
      pattr-codes        ,
      pattr-labels       ,
      ","                ,
      ppresel-codes  ,
      OUTPUT  psel-codes             ) .
if  psel-codes = "" then return no-apply.
define variable ii as integer   no-undo .
define variable i-all as integer   no-undo .
i-all = num-entries (psel-codes) .
repeat ii = 1 to  i-all :
       find first x-abc-analysis-doc where x-abc-analysis-doc.abcd-ext-doc-type = entry(ii, psel-codes ) no-error .
         if not available x-abc-analysis-doc   then do:
              create x-abc-analysis-doc .
              assign
                x-abc-analysis-doc.abc-id   = p-id
                x-abc-analysis-doc.db-num   = p-db-num
                x-abc-analysis-doc.abcd-ext-doc-type = entry(ii, psel-codes )
              .
         end.
end.
OPEN QUERY BROWSE-type-doc FOR EACH x-abc-analysis-doc       WHERE x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and x-abc-analysis-doc.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
END.
ON return OF B-add-doc IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  B-add-doc:handle ) .
  return no-apply .
END.
ON CHOOSE OF B-add-obj IN FRAME Dialog-Frame
DO:
define variable p-obj-type like ub.clients.obj-type no-undo.
define variable p-obj-code like ub.clients.obj-code no-undo.
  define variable v-user-select as logical   no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
  if v-user-select <> true
  then do:
    return no-apply .
  end.
  if p-id = ?
  then do:
    assign
      p-id = 1
    .
  end.
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  for each buf_userobjs_temp-user-obj
    on error undo, return no-apply  :
    find first x-abc-analysis-obj where
               x-abc-analysis-obj.obj-type = buf_userobjs_temp-user-obj.obj-type and
               x-abc-analysis-obj.obj-code = buf_userobjs_temp-user-obj.obj-code no-error .
    if error-status :error then do :
        create x-abc-analysis-obj .
        assign
          x-abc-analysis-obj.abc-id   = p-id
          x-abc-analysis-obj.db-num   = p-db-num
          x-abc-analysis-obj.obj-type = buf_userobjs_temp-user-obj.obj-type
          x-abc-analysis-obj.obj-code = buf_userobjs_temp-user-obj.obj-code
        .
    end.
  end.
OPEN QUERY BROWSE-obj FOR EACH x-abc-analysis-obj       WHERE x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and x-abc-analysis-obj.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
 if x-abc-analysis.abc-a = 0 then do:
    run find-hash-obj in this-procedure .
 end.
END.
ON return OF B-add-obj IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  B-add-obj:handle ) .
  return no-apply .
END.
ON CHOOSE OF B-add-period IN FRAME Dialog-Frame
DO:
if p-id = ? then p-id = 1 .
define variable date-1  as date   no-undo .
define variable date-2  as date   no-undo .
define variable v-ok as logical   no-undo .
   run gbl/get-per.w (
        output        v-ok ,
        input-output  date-1  ,
        input-output  date-2  ) .
    if v-ok then do:
       find first x-abc-analysis-period where
          x-abc-analysis-period.abcp-end   = date-2 and
          x-abc-analysis-period.abcp-start = date-1 no-error .
       if not available x-abc-analysis-period then do:
        create x-abc-analysis-period .
        assign
          x-abc-analysis-period.abc-id     = p-id
          x-abc-analysis-period.db-num     = p-db-num
          x-abc-analysis-period.abcp-end   = date-2
          x-abc-analysis-period.abcp-start = date-1
        .
       end.
    end.
  OPEN QUERY BROWSE-period FOR EACH x-abc-analysis-period       WHERE x-abc-analysis-period.abc-id = x-abc-analysis.abc-id and x-abc-analysis-period.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
END.
ON return OF B-add-period IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  B-add-period:handle ) .
  return no-apply .
END.
ON CHOOSE OF B-crt IN FRAME Dialog-Frame
DO:
define VAR v-rid-list    as  char no-undo .
      DISPLAY
       "" @ x-abc-analysis.cral-id
       "" @ x-criterion-analysis.cral-name
      WITH FRAME Dialog-Frame.
run ref/critanal.w (parParentProc,"b-sel", "", OUTPUT v-rid-list ) no-error .
  if error-status :error or  v-rid-list = "" or v-rid-list = ? then do:
     message "Не выбран критерий анализа!" skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error
     .
     return no-apply.
  end.
  find first x-criterion-analysis no-lock where recid(x-criterion-analysis) = integer(v-rid-list) no-error.
      if error-status :error or  v-rid-list = "" or v-rid-list = ? then do:
        message "Не правильно выбран критерий анализа!" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error
        .
        return no-apply.
      end.
      if x-criterion-analysis.cral-status <> 0 then do:
        message "Не правильно выбран критерий анализа! Статус критерия должен быть АКТИВНЫЙ ." skip
        view-as alert-box error
        .
        return no-apply.
      end.
   ASSIGN
      x-abc-analysis.cral-id = x-criterion-analysis.cral-id
    .
      DISPLAY
        x-abc-analysis.cral-id
        x-criterion-analysis.cral-name
      WITH FRAME Dialog-Frame.
END.
ON return OF B-crt IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  B-crt:handle ) .
  return no-apply .
END.
ON CHOOSE OF B-del-doc IN FRAME Dialog-Frame
DO:
  IF AVAILABLE x-abc-analysis-doc THEN DELETE x-abc-analysis-doc.
  OPEN QUERY BROWSE-type-doc FOR EACH x-abc-analysis-doc       WHERE x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and x-abc-analysis-doc.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
END.
ON CHOOSE OF B-del-obj IN FRAME Dialog-Frame
DO:
 IF AVAILABLE x-abc-analysis-obj THEN DELETE x-abc-analysis-obj.
OPEN QUERY BROWSE-obj FOR EACH x-abc-analysis-obj       WHERE x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and x-abc-analysis-obj.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
END.
ON CHOOSE OF B-del-period IN FRAME Dialog-Frame
DO:
  IF AVAILABLE x-abc-analysis-period THEN DELETE x-abc-analysis-period.
  OPEN QUERY BROWSE-period FOR EACH x-abc-analysis-period       WHERE x-abc-analysis-period.abc-id = x-abc-analysis.abc-id and x-abc-analysis-period.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
    run proc-save in this-procedure no-error.
    if error-status:error then do:
        case return-value
        :
        when "cral-id"
          then do:
              apply "CHOOSE" to B-crt IN FRAME Dialog-Frame .
          end.
        when "obj"
          then do:
              apply "CHOOSE" to B-add-obj IN FRAME Dialog-Frame .
          end.
        when "doc"
          then do:
              apply "CHOOSE" to B-add-doc IN FRAME Dialog-Frame .
          end.
        when "period"
          then do:
              apply "CHOOSE" to B-add-period IN FRAME Dialog-Frame .
          end.
        when "abc-name"
          then do:
              apply "entry" to x-abc-analysis.abc-name IN FRAME Dialog-Frame .
          end.
        when "abc-rang"
          then do:
              apply "entry" to x-abc-analysis.abc-a IN FRAME Dialog-Frame .
          end.
        otherwise do:
          MESSAGE  RETURN-VALUE "ДЛЯ ОТЛАДКИ !!! " view-as alert-box information .
        end.
        end case.
        return no-apply.
    end.
    find first locked_abc-analysis no-lock where
                      recid(locked_abc-analysis) = p-doc-rec no-error .
    run ref/abc-a.p  (
        input parparentproc
      , input "abc":U
      , input locked_abc-analysis.abc-id
      , input locked_abc-analysis.db-num
      , input table x-abc-analysis
      , input table x-abc-analysis-doc
      , input table x-abc-analysis-obj
      , input table x-abc-analysis-period )
    no-error.
    if error-status:error then do:
        MESSAGE "Ошибка расчета АВС анализа"
        error-status :get-message(1)
        return-value
        "456" skip
    .
      return no-apply.
      end.
    run ref/abc-view.w (
    parParentProc,
    locked_abc-analysis.abc-id ,
    locked_abc-analysis.db-num
    )  .
END.
ON CHOOSE OF B-gds-list IN FRAME Dialog-Frame
DO:
define variable v-ps as character no-undo .
v-ps = "".
for each gds-list-hist:
  v-ps = v-ps + gds-list-hist.des + chr(10).
end.
  run gbl/d-prompt.w (
        'title=':u + "Список товаров" + '\':u
      + 'format=' + "x(1000)" + '\':u
      + 'type=' + "edit" + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=60\':u
      + 'fillin_height=10\':u
      + 'max-chars=1000\':u
      + 'readonly=yes\':u
      , input-output v-ps
      ) no-error.
END.
ON CHOOSE OF B-rez IN FRAME Dialog-Frame
DO:
  run ref/abc-view.w (
  parParentProc,
  x-abc-analysis.abc-id ,
  x-abc-analysis.db-num
  ) no-error .
  if error-status :error then
  message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value                 skip
  "Ошибка процедуры abc-view.w"
  .
  run make-temp-rez .
END.
ON CHOOSE OF B-save-doc-typd IN FRAME Dialog-Frame
DO:
  if not can-find (first x-abc-analysis-obj no-lock
        where x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
              x-abc-analysis-obj.db-num = x-abc-analysis.db-num  ) then do:
              message "Не выбрано ни одного объекта! Сохранить список типов документов можно после определения списка объектов." view-as alert-box information .
              return .
  end.
  if not can-find (first x-abc-analysis-doc no-lock
        where x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and
              x-abc-analysis-doc.db-num = x-abc-analysis.db-num  ) then do:
              message "Список типов документов для сохранения пуст! Заполните список типов документов." view-as alert-box information .
              return .
  end.
  run waitfram-show ("Ждите...").
  define variable v-list-obj as character no-undo .
  define variable v-list-doc as character no-undo .
  define variable v-possb-keep-string-obj as logical   no-undo .
  define variable v-string-obj            as character no-undo .
  define variable v-hash-string-obj       as character no-undo .
  define variable v-possb-keep-string-doc as logical   no-undo .
  define variable v-string-doc            as character no-undo .
  define variable v-hash-string-doc       as character no-undo .
  define variable v-id as integer   no-undo .
  define variable v-db as integer   no-undo .
  define variable v-recid as recid  no-undo .
  v-list-obj = "".
  for each x-abc-analysis-obj no-lock
      where x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
            x-abc-analysis-obj.db-num = x-abc-analysis.db-num  :
            v-list-obj = v-list-obj + x-abc-analysis-obj.obj-type + string(x-abc-analysis-obj.obj-code) + "," .
  end.
  v-list-doc = "".
  for each x-abc-analysis-doc no-lock
      where x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and
            x-abc-analysis-doc.db-num = x-abc-analysis.db-num  :
            v-list-doc = v-list-doc + x-abc-analysis-doc.abcd-ext-doc-type  + "," .
  end.
  run find-from-hash  (
     input v-list-obj
    ,input "doc-abc-def"
    ,input "doad-possb-keep-string-obj"
    ,input "doad-string-obj"
    ,input "doad-hash-string-obj"
    ,input "doc-abc-def-obj"
    ,output v-recid
    ).
  run update-doc-def (
     input v-recid
    ,input v-list-obj
    ,input v-list-doc
    ).
  run waitfram-hide in this-procedure .
END.
ON CHOOSE OF B-save-rang IN FRAME Dialog-Frame
DO:
  if not can-find (first x-abc-analysis-obj no-lock
        where x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
              x-abc-analysis-obj.db-num = x-abc-analysis.db-num  ) then do:
              message "Не выбрано ни одного объекта! Сохранить ранжирование можно после определения списка объектов." view-as alert-box information .
              return .
  end.
  if  x-abc-analysis.abc-a  = 0  or  x-abc-analysis.abc-b = 0  then do:
              message "Ранжирование АВС не задано !!!" view-as alert-box information .
              return .
  end.
  run waitfram-show ("Ждите...").
  define variable v-list-obj as character no-undo .
  define variable v-possb-keep-string-obj as logical   no-undo .
  define variable v-string-obj            as character no-undo .
  define variable v-hash-string-obj       as character no-undo .
  define variable v-id as integer   no-undo .
  define variable v-db as integer   no-undo .
  define variable v-recid as recid  no-undo .
  v-list-obj = "".
  for each x-abc-analysis-obj no-lock
      where x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
            x-abc-analysis-obj.db-num = x-abc-analysis.db-num  :
            v-list-obj = v-list-obj + x-abc-analysis-obj.obj-type + string(x-abc-analysis-obj.obj-code) + "," .
  end.
  run find-from-hash  (
     input v-list-obj
    ,input "rang-abc-def"
    ,input "raad-possb-keep-string-obj"
    ,input "raad-string-obj"
    ,input "raad-hash-string-obj"
    ,input "rang-abc-def-obj"
    ,output v-recid
    ).
  run update-rang-def (
     input v-recid
    ,input v-list-obj
    ,input x-abc-analysis.abc-a
    ,input x-abc-analysis.abc-b
    ,input x-abc-analysis.abc-c
    ,input x-abc-analysis.abc-d
    ,input x-abc-analysis.abc-e
    ,input x-abc-analysis.abc-f ) .
    assign
        x-abc-analysis.raad-a = x-abc-analysis.abc-a
        x-abc-analysis.raad-b = x-abc-analysis.abc-b
        x-abc-analysis.raad-c = x-abc-analysis.abc-c
        x-abc-analysis.raad-d = x-abc-analysis.abc-d
        x-abc-analysis.raad-e = x-abc-analysis.abc-e
        x-abc-analysis.raad-f = x-abc-analysis.abc-f
    .
  run waitfram-hide in this-procedure .
END.
ON ROW-DISPLAY OF BROWSE-rez IN FRAME Dialog-Frame
DO:
  IF AVAILABLE temp-rez THEN DO:
      IF  temp-rez.ABC = "A" THEN DO:
          temp-rez.ABC:fgcolor in browse BROWSE-rez = 12 .
          temp-rez.Sum-cr:fgcolor in browse BROWSE-rez = 12 .
          temp-rez.Sum_prc:fgcolor in browse BROWSE-rez = 12 .
          temp-rez.qnty:fgcolor in browse BROWSE-rez = 12 .
          temp-rez.qnty_prc:fgcolor in browse BROWSE-rez = 12 .
      END.
      IF  temp-rez.ABC = "B" THEN DO:
          temp-rez.ABC:fgcolor      in browse BROWSE-rez = 9 .
          temp-rez.Sum-cr:fgcolor     in browse BROWSE-rez = 9 .
          temp-rez.Sum_prc:fgcolor  in browse BROWSE-rez = 9 .
          temp-rez.qnty:fgcolor     in browse BROWSE-rez = 9 .
          temp-rez.qnty_prc:fgcolor in browse BROWSE-rez = 9 .
      END.
      IF  temp-rez.ABC = "D" THEN DO:
          temp-rez.ABC:fgcolor      in browse BROWSE-rez = 3 .
          temp-rez.Sum-cr:fgcolor   in browse BROWSE-rez = 3 .
          temp-rez.Sum_prc:fgcolor  in browse BROWSE-rez = 3 .
          temp-rez.qnty:fgcolor     in browse BROWSE-rez = 3 .
          temp-rez.qnty_prc:fgcolor in browse BROWSE-rez = 3 .
      END.
      IF  temp-rez.ABC = "E" THEN DO:
          temp-rez.ABC:fgcolor      in browse BROWSE-rez = 5 .
          temp-rez.Sum-cr:fgcolor   in browse BROWSE-rez = 5 .
          temp-rez.Sum_prc:fgcolor  in browse BROWSE-rez = 5 .
          temp-rez.qnty:fgcolor     in browse BROWSE-rez = 5 .
          temp-rez.qnty_prc:fgcolor in browse BROWSE-rez = 5 .
      END.
      IF  temp-rez.ABC = "F" THEN DO:
          temp-rez.ABC:fgcolor      in browse BROWSE-rez = 7 .
          temp-rez.Sum-cr:fgcolor   in browse BROWSE-rez = 7 .
          temp-rez.Sum_prc:fgcolor  in browse BROWSE-rez = 7 .
          temp-rez.qnty:fgcolor     in browse BROWSE-rez = 7 .
          temp-rez.qnty_prc:fgcolor in browse BROWSE-rez = 7 .
      END.
  END.
END.
ON LEAVE OF x-abc-analysis.double-line-proc IN FRAME Dialog-Frame
DO:
  ASSIGN x-abc-analysis.double-line-proc .
  FILL-IN-11 = "/ " + string(100 - x-abc-analysis.double-line-proc) + " %" .
  DISPLAY FILL-IN-11 WITH FRAME Dialog-Frame .
END.
ON VALUE-CHANGED OF x-abc-analysis.r-goods IN FRAME Dialog-Frame
DO:
    ASSIGN x-abc-analysis.r-goods.
    IF x-abc-analysis.r-goods = 2 THEN DO:
       run str/gds-list.w (input parParentProc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code ).
    END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-obj :handle
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable loc#log as logical   no-undo .
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ABC-XYZ_lookup':U
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
   if not loc#log then return .
  for each x-abc-analysis:
    delete x-abc-analysis.
  end.
define variable  v-value-date    as date   no-undo .
define variable  v-value-decimal as decimal   no-undo .
define variable  v-value-integer as integer   no-undo .
define variable  v-value-logical as logical   no-undo .
define variable v-found as logical   no-undo .
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   'abc-global':U ,
  input   'abc-type'  ,
  output  par-abc-type ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  v-value-logical   ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
  if error-status :error or v-found = false then do:
      message "Нет настроек Ассортиментной политики !!!." view-as alert-box information .
      return error return-value .
  end.
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   'abc-global':U ,
  input   'abc-mode'  ,
  output  par-abc-mode ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  v-value-logical   ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
  if error-status :error or v-found = false then do:
      message "Нет настроек Ассортиментной политики !!!." view-as alert-box information .
      return error return-value .
  end.
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   'abc-global':U ,
  input   'abc-one'  ,
  output  par-abc-one ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  v-value-logical   ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
  if error-status :error or v-found = false then do:
      message "Нет настроек Ассортиментной политики !!!." view-as alert-box information .
      return error return-value .
  end.
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   'abc-global':U ,
  input   'abc-two'  ,
  output  par-abc-two ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  v-value-logical   ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
  if error-status :error or v-found = false then do:
      message "Нет настроек Ассортиментной политики !!!." view-as alert-box information .
      return error return-value .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_abc-analysis  no-lock  where
                  recid(locked_abc-analysis) = p-doc-rec no-wait no-error.
      if locked locked_abc-analysis then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись АBC анализа занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_abc-analysis no-lock where
                       recid(locked_abc-analysis) = p-doc-rec no-error .
      if not avail locked_abc-analysis then do:
        find first locked_abc-analysis no-lock where
                   locked_abc-analysis.db-num = p-db-num and
                   locked_abc-analysis.abc-id = p-id
                   no-error .
      end.
    end.
    if not available locked_abc-analysis then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись АBC анализа"
      view-as alert-box error .
      undo, return error.
    end.
    create x-abc-analysis.
    buffer-copy locked_abc-analysis to x-abc-analysis.
   end.
   else do:
          run cur-time in this-procedure(output v-date, output v-time).
          create x-abc-analysis.
          assign
          x-abc-analysis.abc-id = v-last-code + 1
          x-abc-analysis.db-num = v-db-num
          x-abc-analysis.cral-id = 1
          x-abc-analysis.abc-date-create = v-date
          x-abc-analysis.abc-time-create = v-time
          x-abc-analysis.abc-db-num-create = v-db-num
          x-abc-analysis.abc-who-create  = g#userid
         .
   if par-abc-mode = "bimodal":U then do:
      x-abc-analysis.abc-type = "2" .
      if num-entries(par-abc-two,";") <> 3 then do:
         message "Неверно задан конфигурационный параметр abc-two" view-as alert-box error .
         return error return-value .
      end.
      else do:
         x-abc-analysis.double-line-proc = decimal(entry(1 ,entry(1 , par-abc-two ,";" ),"/" )) .
         x-abc-analysis.LE-proc          = decimal(entry(3 , par-abc-two,";" ))  .
         v-abc-one                       =  entry(2 , par-abc-two,";" )  .
      case par-abc-type :
        when 'ABC' then do:
           if num-entries (v-abc-one ,"/") < 2 then do:
              message "Неверно задан конфигурационный параметр abc-two , задайте не менее двух уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.
           x-abc-analysis.abc-a = decimal( entry ( 1 , v-abc-one ,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , v-abc-one,"/" )) .
           x-abc-analysis.abc-c = 100 .
        end.
        when 'ABCD' then do:
           if num-entries (v-abc-one ,"/") < 3 then do:
              message "Неверно задан конфигурационный параметр abc-two , задайте не менее трех уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.
           x-abc-analysis.abc-a = decimal( entry ( 1 , v-abc-one ,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , v-abc-one,"/" )) .
           x-abc-analysis.abc-c = decimal(  entry ( 3 , v-abc-one,"/" )) .
           x-abc-analysis.abc-d = 100 .
        end.
        when 'ABCDE' then do:
           if num-entries (v-abc-one ,"/") < 4 then do:
              message "Неверно задан конфигурационный параметр abc-two , задайте не менее четырех уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.
           x-abc-analysis.abc-a = decimal(  entry ( 1 , v-abc-one,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , v-abc-one,"/" )) .
           x-abc-analysis.abc-c = decimal(  entry ( 3 , v-abc-one,"/" )) .
           x-abc-analysis.abc-d = decimal(  entry ( 4 , v-abc-one,"/" )) .
           x-abc-analysis.abc-E = 100 .
        end.
        when 'ABCDEF' then do:
           if num-entries (v-abc-one ,"/") < 5 then do:
              message "Неверно задан конфигурационный параметр abc-two , задайте не менее пяти уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.
           x-abc-analysis.abc-a = decimal(  entry ( 1 , v-abc-one,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , v-abc-one,"/" )) .
           x-abc-analysis.abc-c = decimal(  entry ( 3 , v-abc-one,"/" )) .
           x-abc-analysis.abc-d = decimal(  entry ( 4 , v-abc-one,"/" )) .
           x-abc-analysis.abc-E = decimal(  entry ( 5 , v-abc-one,"/" )) .
           x-abc-analysis.abc-f = 100 .
        end.
      end case.
      end.
   end.
   else do:
      x-abc-analysis.abc-type = "1" .
      case par-abc-type :
        when 'ABC' then do:
           if num-entries (par-abc-one,"/") < 2 then do:
              message "Неверно задан конфигурационный параметр abc-one , задайте не менее двух уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.
           x-abc-analysis.abc-a = decimal( entry ( 1 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , par-abc-one,"/" )) .
           x-abc-analysis.abc-c = 100 .
        end.
        when 'ABCD' then do:
           if num-entries (par-abc-one,"/") < 3 then do:
              message "Неверно задан конфигурационный параметр abc-one , задайте не менее трех уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.
           x-abc-analysis.abc-a = decimal( entry ( 1 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , par-abc-one,"/" )) .
           x-abc-analysis.abc-c = decimal(  entry ( 3 , par-abc-one,"/" )) .
           x-abc-analysis.abc-d = 100 .
        end.
        when 'ABCDE' then do:
           if num-entries (par-abc-one,"/") < 4 then do:
               message "Неверно задан конфигурационный параметр abc-one , задайте не менее четырех уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.
           x-abc-analysis.abc-a = decimal(  entry ( 1 , par-abc-one,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , par-abc-one,"/" )) .
           x-abc-analysis.abc-c = decimal(  entry ( 3 , par-abc-one,"/" )) .
           x-abc-analysis.abc-d = decimal(  entry ( 4 , par-abc-one,"/" )) .
           x-abc-analysis.abc-E = 100 .
        end.
        when 'ABCDEF' then do:
           if num-entries (par-abc-one,"/") < 5 then do:
             message "Неверно задан конфигурационный параметр abc-one , задайте не менее пяти уровней процентов через запятую < 100 " view-as alert-box error .
              return error return-value .
           end.
           x-abc-analysis.abc-a = decimal(  entry ( 1 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-b = decimal(  entry ( 2 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-c = decimal(  entry ( 3 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-d = decimal(  entry ( 4 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-E = decimal(  entry ( 5 , par-abc-one ,"/" )) .
           x-abc-analysis.abc-f = 100 .
        end.
      end case.
   end.
   end.
   run my_enable in this-procedure .
       find first x-criterion-analysis no-lock where x-criterion-analysis.cral-id = x-abc-analysis.cral-id no-error .
       if available x-criterion-analysis then
           display x-criterion-analysis.cral-name with frame dialog-frame.
  hide b-save-doc-typd  b-save-rang in frame Dialog-Frame .
  wait-for go of frame Dialog-Frame focus x-abc-analysis.abc-name.
end.
run disable_ui in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY FILL-IN-11 FILL-IN-1 FILL-IN-2 FILL-IN-4 FILL-IN-6 FILL-IN-3 FILL-IN-5
          FILL-rez F-time FILL-IN-7
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-abc-analysis THEN
    DISPLAY x-abc-analysis.double-line-proc x-abc-analysis.abc-type
          x-abc-analysis.LE-proc x-abc-analysis.r-goods x-abc-analysis.abc-name
          x-abc-analysis.abc-a x-abc-analysis.abc-b x-abc-analysis.abc-c
          x-abc-analysis.abc-d x-abc-analysis.abc-e x-abc-analysis.abc-des
          x-abc-analysis.abc-id x-abc-analysis.cral-id
          x-abc-analysis.abc-who-create x-abc-analysis.abc-date-create
          x-abc-analysis.abc-db-num-create
      WITH FRAME Dialog-Frame.
  IF AVAILABLE x-criterion-analysis THEN
    DISPLAY x-criterion-analysis.cral-name
      WITH FRAME Dialog-Frame.
  ENABLE BROWSE-rez x-abc-analysis.double-line-proc x-abc-analysis.abc-type
         FILL-IN-11 x-abc-analysis.LE-proc x-abc-analysis.r-goods B-gds-list
         b-quit B-exit B-save-rang B-save-doc-typd B-rez B-Help
         x-abc-analysis.abc-name B-crt B-add-obj B-del-obj B-add-period
         B-del-period B-add-doc B-del-doc BROWSE-obj BROWSE-period
         BROWSE-type-doc x-abc-analysis.abc-a x-abc-analysis.abc-b
         x-abc-analysis.abc-c x-abc-analysis.abc-d x-abc-analysis.abc-e
         x-abc-analysis.abc-des x-abc-analysis.abc-id x-abc-analysis.cral-id
         x-criterion-analysis.cral-name FILL-IN-1 FILL-IN-2 FILL-IN-4 FILL-IN-6
         FILL-IN-3 FILL-IN-5 FILL-rez x-abc-analysis.abc-who-create
         x-abc-analysis.abc-date-create F-time x-abc-analysis.abc-db-num-create
         FILL-IN-7 RECT-f RECT-E RECT-D RECT-C RECT-B RECT-A
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-obj FOR EACH x-abc-analysis-obj       WHERE x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and x-abc-analysis-obj.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-period FOR EACH x-abc-analysis-period       WHERE x-abc-analysis-period.abc-id = x-abc-analysis.abc-id and x-abc-analysis-period.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-rez FOR EACH temp-rez .    OPEN QUERY BROWSE-type-doc FOR EACH x-abc-analysis-doc       WHERE x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and x-abc-analysis-doc.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE find-hash-obj :
  define variable v-list-obj as character no-undo .
  define variable v-possb-keep-string-obj as logical   no-undo .
  define variable v-string-obj            as character no-undo .
  define variable v-hash-string-obj       as character no-undo .
  define variable v-recid as recid     no-undo .
  v-list-obj = "".
  for each x-abc-analysis-obj no-lock
      where x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
            x-abc-analysis-obj.db-num = x-abc-analysis.db-num  :
            v-list-obj = v-list-obj + x-abc-analysis-obj.obj-type + string(x-abc-analysis-obj.obj-code) + "," .
  end.
  run find-from-hash  (
     input v-list-obj
    ,input "ub.rang-abc-def"
    ,input "ub.raad-possb-keep-string-obj"
    ,input "ub.raad-string-obj"
    ,input "ub.raad-hash-string-obj"
    ,input "ub.rang-abc-def-obj"
    ,output v-recid
    ).
   find first ub.rang-abc-def no-lock where
              recid(ub.rang-abc-def) = v-recid
              no-error .
    if available ub.rang-abc-def then do:
       message "Найдено значение уровней ранжирования для данного списка объектов по умолчанию : " skip
                ub.rang-abc-def.raad-a                                                                skip
                ub.rang-abc-def.raad-b                                                                skip
                ub.rang-abc-def.raad-c                                                                skip
               if  ub.rang-abc-def.raad-d = 0 then "" else string(ub.rang-abc-def.raad-d)                skip
               if  ub.rang-abc-def.raad-e = 0 then "" else string(ub.rang-abc-def.raad-e)                skip
               if  ub.rang-abc-def.raad-f = 0 then "" else string(ub.rang-abc-def.raad-f)
               .
       define variable raad-def as character no-undo .
       define variable v-raad-d as decimal   no-undo .
       define variable v-raad-e as decimal   no-undo .
       define variable v-raad-c as decimal   no-undo .
       if ub.rang-abc-def.raad-d = 0 and  ub.rang-abc-def.raad-e = 0 and ub.rang-abc-def.raad-f = 0 then raad-def = "ABC":U .
       if ub.rang-abc-def.raad-d > 0 and  ub.rang-abc-def.raad-e = 0 and ub.rang-abc-def.raad-f = 0 then raad-def = "ABCD":U .
       if ub.rang-abc-def.raad-d > 0 and  ub.rang-abc-def.raad-e > 0 and ub.rang-abc-def.raad-f = 0 then raad-def = "ABCDE":U .
       if ub.rang-abc-def.raad-d > 0 and  ub.rang-abc-def.raad-e > 0 and ub.rang-abc-def.raad-f > 0 then raad-def = "ABCDEF":U .
       assign
         v-raad-d = ub.rang-abc-def.raad-d
         v-raad-e = ub.rang-abc-def.raad-e
         v-raad-c = ub.rang-abc-def.raad-c
       .
       if length(raad-def) < length(par-abc-type) then do:
          if  ub.rang-abc-def.raad-d = 100 then v-raad-d = 0 .
          if  ub.rang-abc-def.raad-e = 100 then v-raad-e = 0 .
          if  ub.rang-abc-def.raad-c = 100 then v-raad-c = 0 .
       end.
       assign
        x-abc-analysis.abc-a  = ub.rang-abc-def.raad-a
        x-abc-analysis.abc-b  = ub.rang-abc-def.raad-b
        x-abc-analysis.abc-c  = v-raad-c
        x-abc-analysis.abc-d  = v-raad-d
        x-abc-analysis.abc-e  = v-raad-e
        x-abc-analysis.abc-f  = ub.rang-abc-def.raad-f
        x-abc-analysis.raad-f = ub.rang-abc-def.raad-f
        x-abc-analysis.raad-a = ub.rang-abc-def.raad-a
        x-abc-analysis.raad-b = ub.rang-abc-def.raad-b
        x-abc-analysis.raad-c = v-raad-c
        x-abc-analysis.raad-d = v-raad-d
        x-abc-analysis.raad-e = v-raad-e
       .
       if par-abc-type = "ABC":U  then do:
       assign
           x-abc-analysis.abc-c = 100
           x-abc-analysis.abc-d = 0
           x-abc-analysis.abc-e = 0
           x-abc-analysis.abc-f = 0
       .
       end.
       if par-abc-type = "ABCD":U  then do:
       assign
           x-abc-analysis.abc-d = 100
           x-abc-analysis.abc-e = 0
           x-abc-analysis.abc-f = 0
       .
       end.
       if par-abc-type = "ABCDE":U  then do:
       assign
           x-abc-analysis.abc-e = 100
           x-abc-analysis.abc-f = 0
       .
       end.
       if par-abc-type = "ABCDEF":U  then do:
       assign
           x-abc-analysis.abc-f = 100
       .
       end.
       display x-abc-analysis.abc-a
               x-abc-analysis.abc-b
               x-abc-analysis.abc-c  when par-abc-type = "ABCD":U   or  par-abc-type = "ABCDE":U or  par-abc-type = "ABCDEF":U
               x-abc-analysis.abc-d  when par-abc-type = "ABCDE":U  or  par-abc-type = "ABCDEF":U
               x-abc-analysis.abc-e  when par-abc-type = "ABCDEF":U
               with frame Dialog-Frame .
       apply "LEAVE" to x-abc-analysis.abc-b  in frame Dialog-Frame .
    end.
  run find-from-hash  (
     input v-list-obj
    ,input "ub.doc-abc-def"
    ,input "ub.doad-possb-keep-string-obj"
    ,input "ub.doad-string-obj"
    ,input "ub.doad-hash-string-obj"
    ,input "ub.doc-abc-def-obj"
    ,output v-recid
    ).
   find first ub.doc-abc-def no-lock where
              recid(ub.doc-abc-def) = v-recid
              no-error .
    if available ub.doc-abc-def then do:
    for each ub.doc-abc-def-doc no-lock  where
            ub.doc-abc-def-doc.doad-id = ub.doc-abc-def.doad-id and
            ub.doc-abc-def-doc.db-num  = ub.doc-abc-def.db-num   :
        create x-abc-analysis-doc.
         assign
            x-abc-analysis-doc.abcd-ext-doc-type = ub.doc-abc-def-doc.dadd-ext-doc-type
            x-abc-analysis-doc.abc-id   = x-abc-analysis.abc-id
            x-abc-analysis-doc.db-num   = x-abc-analysis.db-num
         .
        OPEN QUERY BROWSE-type-doc FOR EACH x-abc-analysis-doc       WHERE x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and x-abc-analysis-doc.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
    end.
    end.
END PROCEDURE.
PROCEDURE make-temp-rez :
define buffer bb_abc-analysis for ub.abc-analysis.
find first bb_abc-analysis no-lock where
           bb_abc-analysis.abc-id = p-id and
           bb_abc-analysis.db-num = p-db-num
           no-error .
for each temp-rez : delete temp-rez. end.
    CREATE temp-rez.
    ASSIGN
    temp-rez.n  = 1
    temp-rez.ABC  = "A"
    temp-rez.Sum-cr   = bb_abc-analysis.abc-a-sum
    temp-rez.Sum_prc  = bb_abc-analysis.abc-a-sum-prc
    temp-rez.qnty     = bb_abc-analysis.abc-a-qnty
    temp-rez.qnty_prc = bb_abc-analysis.abc-a-prc-qnty
     .
    CREATE temp-rez.
    ASSIGN
    temp-rez.n  = 2
    temp-rez.ABC  = "B"
    temp-rez.Sum-cr   = bb_abc-analysis.abc-b-sum
    temp-rez.Sum_prc  = bb_abc-analysis.abc-b-sum-prc
    temp-rez.qnty     = bb_abc-analysis.abc-b-qnty
    temp-rez.qnty_prc = bb_abc-analysis.abc-b-prc-qnty
     .
    CREATE temp-rez.
    ASSIGN
    temp-rez.n  = 3
    temp-rez.ABC  = "C"
    temp-rez.Sum-cr   = bb_abc-analysis.abc-c-sum
    temp-rez.Sum_prc  = bb_abc-analysis.abc-c-sum-prc
    temp-rez.qnty     = bb_abc-analysis.abc-c-qnty
    temp-rez.qnty_prc = bb_abc-analysis.abc-c-prc-qnty
     .
    if LENGTH(par-abc-type) >= 4 or bb_abc-analysis.abc-type = "2" then  do:
        CREATE temp-rez.
        ASSIGN
        temp-rez.n  = 4
        temp-rez.ABC  = "D"
        temp-rez.Sum-cr   = bb_abc-analysis.abc-d-sum
        temp-rez.Sum_prc  = bb_abc-analysis.abc-d-sum-prc
        temp-rez.qnty     = bb_abc-analysis.abc-d-qnty
        temp-rez.qnty_prc = bb_abc-analysis.abc-d-prc-qnty
        .
    end.
    if LENGTH(par-abc-type) >= 5 or bb_abc-analysis.abc-type = "2" then do:
        CREATE temp-rez.
        ASSIGN
        temp-rez.n  = 5
        temp-rez.ABC  = "E"
        temp-rez.Sum-cr   = bb_abc-analysis.abc-e-sum
        temp-rez.Sum_prc  = bb_abc-analysis.abc-e-sum-prc
        temp-rez.qnty     = bb_abc-analysis.abc-e-qnty
        temp-rez.qnty_prc = bb_abc-analysis.abc-e-prc-qnty
        .
    end.
    if LENGTH(par-abc-type) >= 6 then do:
        CREATE temp-rez.
        ASSIGN
        temp-rez.n  = 6
        temp-rez.ABC  = "F"
        temp-rez.Sum-cr   = bb_abc-analysis.abc-f-sum
        temp-rez.Sum_prc  = bb_abc-analysis.abc-f-sum-prc
        temp-rez.qnty     = bb_abc-analysis.abc-f-qnty
        temp-rez.qnty_prc = bb_abc-analysis.abc-f-prc-qnty
        .
    end.
    CREATE temp-rez.
    ASSIGN
    temp-rez.n  = 7
    temp-rez.ABC  = "ИТОГО"
    temp-rez.Sum-cr     =
                          bb_abc-analysis.abc-a-sum + bb_abc-analysis.abc-b-sum +
                          bb_abc-analysis.abc-c-sum + bb_abc-analysis.abc-d-sum +
                          bb_abc-analysis.abc-e-sum + bb_abc-analysis.abc-f-sum
    temp-rez.Sum_prc    = 100
    temp-rez.qnty       =
                          bb_abc-analysis.abc-a-qnty + bb_abc-analysis.abc-b-qnty +
                          bb_abc-analysis.abc-c-qnty + bb_abc-analysis.abc-d-qnty +
                          bb_abc-analysis.abc-e-qnty + bb_abc-analysis.abc-f-qnty
    temp-rez.qnty_prc   = 100
     .
OPEN QUERY BROWSE-rez FOR EACH temp-rez .
END PROCEDURE.
PROCEDURE my_enable :
   case par-abc-type :
   when 'AB':U then do:
          hide
              f-c in frame Dialog-Frame
              f-d in frame Dialog-Frame
              f-e
              f-f
              rect-c
              rect-d
              rect-e
              rect-f
              fill-in-3
              fill-in-4
              fill-in-5
              fill-in-6
              in frame Dialog-Frame .
   end.
   when 'ABC':U then do:
          hide
              f-d in frame Dialog-Frame
              f-e
              f-f
              rect-d
              rect-e
              rect-f
              fill-in-4
              fill-in-5
              fill-in-6
              in frame Dialog-Frame .
              x-abc-analysis.LE-proc:label = "E <= % "  .
   end.
   when 'ABCD':U then do:
     hide
        f-e
        f-f
        rect-e
        rect-f
        fill-in-5
        fill-in-6
        in frame Dialog-Frame .
     x-abc-analysis.LE-proc:label = "F <= % "  .
   end.
   when 'ABCDE':U  then do:
      hide
      f-f
      rect-f
      fill-in-6
      in frame Dialog-Frame .
      x-abc-analysis.LE-proc:label = "G <= % "  .
   end.
   when 'ABCDEF':U then do:
      x-abc-analysis.LE-proc:label = "H <= % "  .
   end.
   otherwise do:
     message "Не верно задан параметр abc-type " par-abc-type view-as alert-box error .
   end.
   end case.
    if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
   assign frame Dialog-Frame:title = "Просмотр АВС анализа " .
    for each ub.abc-analysis-doc no-lock  where
            ub.abc-analysis-doc.abc-id = x-abc-analysis.abc-id and
            ub.abc-analysis-doc.db-num = x-abc-analysis.db-num   :
        create x-abc-analysis-doc.
        BUFFER-COPY ub.abc-analysis-doc  TO x-abc-analysis-doc
            .
    end.
    for each ub.abc-analysis-obj no-lock  where
            ub.abc-analysis-obj.abc-id = x-abc-analysis.abc-id and
            ub.abc-analysis-obj.db-num = x-abc-analysis.db-num   :
        create x-abc-analysis-obj.
        BUFFER-COPY ub.abc-analysis-obj  TO x-abc-analysis-obj.
    end.
    for each ub.abc-analysis-period no-lock where
            ub.abc-analysis-period.abc-id = x-abc-analysis.abc-id and
            ub.abc-analysis-period.db-num = x-abc-analysis.db-num   :
        create x-abc-analysis-period.
        BUFFER-COPY ub.abc-analysis-period TO x-abc-analysis-period.
    end.
    run make-temp-rez in this-procedure .
end.
define variable v-user-name as character no-undo .
IF AVAILABLE x-abc-analysis THEN DO:
    f-time =  STRING (x-abc-analysis.abc-time-create,'HH:MM') .
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  x-abc-analysis.abc-who-create
  ,output v-user-name
  )  .
    DISPLAY x-abc-analysis.abc-name
            x-abc-analysis.abc-a
            x-abc-analysis.abc-b
            x-abc-analysis.abc-c when  par-abc-type = "ABCD":U   or  par-abc-type = "ABCDE":U or  par-abc-type = "ABCDEF":U
            x-abc-analysis.abc-d when  par-abc-type = "ABCDE":U  or  par-abc-type = "ABCDEF":U
            x-abc-analysis.abc-e when  par-abc-type = "ABCDEF":U
            x-abc-analysis.abc-des
            x-abc-analysis.cral-id
            v-user-name          when p-mode <> 'ДОБАВЛЕНИЕ':U @  x-abc-analysis.abc-who-create
            x-abc-analysis.abc-date-create   when p-mode <> 'ДОБАВЛЕНИЕ':U
            f-time                           when p-mode <> 'ДОБАВЛЕНИЕ':U
            x-abc-analysis.abc-db-num-create when p-mode <> 'ДОБАВЛЕНИЕ':U
            x-abc-analysis.abc-id when p-mode <> 'ДОБАВЛЕНИЕ':U
            fill-in-1
            fill-in-2
            fill-in-3
            fill-in-4 when  par-abc-type = "ABCD":U   or  par-abc-type = "ABCDE":U or  par-abc-type = "ABCDEF":U
            fill-in-5 when  par-abc-type = "ABCDE":U  or  par-abc-type = "ABCDEF":U
            fill-in-6 when  par-abc-type = "ABCDEF":U
            fill-in-7
            B-rez                             when p-mode <> 'ДОБАВЛЕНИЕ':U
            FILL-rez                          when p-mode <> 'ДОБАВЛЕНИЕ':U
            x-abc-analysis.r-goods
            x-abc-analysis.abc-type
            x-abc-analysis.LE-proc WHEN  x-abc-analysis.abc-type = "2"
            x-abc-analysis.double-line-proc WHEN  x-abc-analysis.abc-type = "2"
            fill-in-8  WHEN  x-abc-analysis.abc-type = "2"
            fill-in-9  WHEN  x-abc-analysis.abc-type = "2"
            fill-in-10 WHEN  x-abc-analysis.abc-type = "2"
            fill-in-11 WHEN  x-abc-analysis.abc-type = "2"
            WITH FRAME Dialog-Frame.
    find first x-criterion-analysis no-lock where x-criterion-analysis.cral-id = x-abc-analysis.cral-id no-error .
       IF AVAILABLE x-criterion-analysis THEN
           DISPLAY x-criterion-analysis.cral-name WITH FRAME Dialog-Frame.
 END.
  rect-a:bgcolor in frame Dialog-Frame = 4.
  rect-b:bgcolor in frame Dialog-Frame = 1.
  rect-c:bgcolor in frame Dialog-Frame = 15.
  rect-d:bgcolor in frame Dialog-Frame = 3.
  rect-e:bgcolor in frame Dialog-Frame = 5.
  rect-f:bgcolor in frame Dialog-Frame = 7.
      if p-mode = 'ДОБАВЛЕНИЕ':U then do:
        assign frame Dialog-Frame:title = "Добавление АВС анализа " .
        display  ""  @  x-criterion-analysis.cral-name     with frame Dialog-Frame .
        hide rect-a
             rect-b
             rect-c
             rect-d
             rect-e
             rect-f
             B-rez
             FILL-rez
             BROWSE-rez
             in frame Dialog-Frame .
        hide  x-abc-analysis.abc-c
              x-abc-analysis.abc-d
              x-abc-analysis.abc-e
              in frame Dialog-Frame .
        if x-abc-analysis.abc-a > 0 then
              run proc-sel-rec (
                  x-abc-analysis.abc-a ,
                  x-abc-analysis.abc-b ,
                  x-abc-analysis.abc-c ,
                  x-abc-analysis.abc-d ,
                  x-abc-analysis.abc-e
                  )  .
      end.
      if p-mode = 'ПРОСМОТР':U then do:
        assign
          b-quit:label = "&Выход"
          b-quit:col = 1
        .
          hide b-exit in frame Dialog-Frame.
          if x-abc-analysis.abc-a > 0 then
             run proc-sel-rec (
                 x-abc-analysis.abc-a ,
                 x-abc-analysis.abc-b ,
                 x-abc-analysis.abc-c ,
                 x-abc-analysis.abc-d ,
                 x-abc-analysis.abc-e
                 )  .
      end.
      ENABLE
      B-exit when p-mode <> 'ПРОСМОТР':U
      b-quit
      B-Help
      x-abc-analysis.abc-name when p-mode <> 'ПРОСМОТР':U
      B-crt                   when p-mode <> 'ПРОСМОТР':U
      x-abc-analysis.abc-a    when p-mode <> 'ПРОСМОТР':U
      x-abc-analysis.abc-b    when p-mode <> 'ПРОСМОТР':U
      x-abc-analysis.abc-c    when p-mode <> 'ПРОСМОТР':U and (par-abc-type = "ABCD":U   or  par-abc-type = "ABCDE":U or  par-abc-type = "ABCDEF":U)
      x-abc-analysis.abc-d    when p-mode <> 'ПРОСМОТР':U and (par-abc-type = "ABCDE":U  or  par-abc-type = "ABCDEF":U                             )
      x-abc-analysis.abc-e    when p-mode <> 'ПРОСМОТР':U and (par-abc-type = "ABCDEF":U                                                           )
      FILL-IN-1
      B-add-obj               when p-mode <> 'ПРОСМОТР':U
      B-del-obj               when p-mode <> 'ПРОСМОТР':U
      B-add-period            when p-mode <> 'ПРОСМОТР':U
      B-del-period            when p-mode <> 'ПРОСМОТР':U
      B-add-doc               when p-mode <> 'ПРОСМОТР':U
      B-del-doc               when p-mode <> 'ПРОСМОТР':U
      x-abc-analysis.abc-des  when p-mode <> 'ПРОСМОТР':U
      BROWSE-obj
      BROWSE-period
      BROWSE-type-doc
      BROWSE-rez        when p-mode = 'ПРОСМОТР':U
      B-save-doc-typd   when p-mode <> 'ПРОСМОТР':U
      B-save-rang       when p-mode <> 'ПРОСМОТР':U
      b-rez             when p-mode = 'ПРОСМОТР':U
      x-abc-analysis.r-goods  when p-mode <> 'ПРОСМОТР':U
      x-abc-analysis.abc-type when p-mode <> 'ПРОСМОТР':U
      x-abc-analysis.LE-proc  when ( p-mode = 'ДОБАВЛЕНИЕ':U and  x-abc-analysis.abc-type = "2")
      b-gds-list        when p-mode <> 'ПРОСМОТР':U
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
    FILL-IN-11 = "/ " + string ( 100 - x-abc-analysis.double-line-proc ) + " %" .
    if x-abc-analysis.abc-type <> "2" then do:
      hide FILL-IN-8 FILL-IN-9 FILL-IN-10 FILL-IN-11 x-abc-analysis.le-proc x-abc-analysis.double-line-proc in frame Dialog-Frame .
    end.
    else do:
      display  FILL-IN-8 FILL-IN-9 FILL-IN-10 FILL-IN-11  x-abc-analysis.le-proc x-abc-analysis.double-line-proc with frame Dialog-Frame .
      if p-mode = 'ДОБАВЛЕНИЕ':U then
         enable  x-abc-analysis.le-proc x-abc-analysis.double-line-proc with frame Dialog-Frame .
    end.
  OPEN QUERY BROWSE-obj FOR EACH x-abc-analysis-obj       WHERE x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and x-abc-analysis-obj.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-period FOR EACH x-abc-analysis-period       WHERE x-abc-analysis-period.abc-id = x-abc-analysis.abc-id and x-abc-analysis-period.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-rez FOR EACH temp-rez .    OPEN QUERY BROWSE-type-doc FOR EACH x-abc-analysis-doc       WHERE x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and x-abc-analysis-doc.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE next-focus :
  define input parameter p-widget-handle as handle no-undo .
  define variable l-apply-entry as logical no-undo .
  assign
    l-apply-entry =  true
  .
  do with frame Dialog-Frame :
    if  x-abc-analysis.abc-name  :handle = p-widget-handle then do:    if B-crt                  :sensitive then do: apply "entry":u to B-crt                  .  return . end. end.
    if  B-crt              :handle = p-widget-handle then do:          if B-add-obj              :sensitive then do: apply "entry":u to B-add-obj              .  return . end. end.
    if  B-add-obj          :handle = p-widget-handle then do:          if B-add-period           :sensitive then do: apply "entry":u to B-add-period           .  return . end. end.
    if  B-add-period         :handle = p-widget-handle then do:        if B-add-doc              :sensitive then do: apply "entry":u to B-add-doc              .  return . end. end.
    if  B-add-doc        :handle = p-widget-handle then do:            if x-abc-analysis.abc-a   :sensitive then do: apply "entry":u to x-abc-analysis.abc-a   .  return . end. end.
    if  x-abc-analysis.abc-a        :handle = p-widget-handle then do: if x-abc-analysis.abc-b   :sensitive then do: apply "entry":u to x-abc-analysis.abc-b   .  return . end. end.
    if  x-abc-analysis.abc-b        :handle = p-widget-handle then do: if x-abc-analysis.abc-c   :sensitive then do: apply "entry":u to x-abc-analysis.abc-c .  return . end.
                                                                                                            else do: apply "entry":u to x-abc-analysis.abc-des .  return . end. end.
    if  x-abc-analysis.abc-c        :handle = p-widget-handle then do: if x-abc-analysis.abc-d   :sensitive then do: apply "entry":u to x-abc-analysis.abc-d .  return . end.
                                                                                                            else do: apply "entry":u to x-abc-analysis.abc-des .  return . end. end.
    if  x-abc-analysis.abc-d        :handle = p-widget-handle then do: if x-abc-analysis.abc-e   :sensitive then do: apply "entry":u to x-abc-analysis.abc-e .  return . end.
                                                                                                            else do: apply "entry":u to x-abc-analysis.abc-des .  return . end. end.
    if  x-abc-analysis.abc-e        :handle = p-widget-handle then do: if x-abc-analysis.abc-des :sensitive then do: apply "entry":u to x-abc-analysis.abc-des .  return . end. end.
    if  x-abc-analysis.abc-des      :handle = p-widget-handle then do: if B-exit                 :sensitive then do: apply "entry":u to B-exit                 .  return . end. end.
  end.
END PROCEDURE.
PROCEDURE OpenBR :
OPEN QUERY BROWSE-obj FOR EACH x-abc-analysis-obj       WHERE x-abc-analysis-obj.abc-id = x-abc-analysis.abc-id and x-abc-analysis-obj.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-period FOR EACH x-abc-analysis-period       WHERE x-abc-analysis-period.abc-id = x-abc-analysis.abc-id and x-abc-analysis-period.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-rez FOR EACH temp-rez .    OPEN QUERY BROWSE-type-doc FOR EACH x-abc-analysis-doc       WHERE x-abc-analysis-doc.abc-id = x-abc-analysis.abc-id and x-abc-analysis-doc.db-num = x-abc-analysis.db-num NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE proc-save :
if p-mode = 'ПРОСМОТР':U then do:
    return error.
end.
if not available x-abc-analysis then do:
    create x-abc-analysis.
end.
assign
frame Dialog-Frame
x-abc-analysis.abc-id
x-abc-analysis.abc-name
x-abc-analysis.abc-a
x-abc-analysis.abc-b
x-abc-analysis.abc-c
x-abc-analysis.abc-d
x-abc-analysis.abc-e
x-abc-analysis.r-goods
x-abc-analysis.LE-proc
x-abc-analysis.abc-type
.
IF r-goods = 1 THEN DO:
END.
if LENGTH(par-abc-type) = 3 then do:
x-abc-analysis.abc-c = 100  .
x-abc-analysis.abc-d = 0    .
x-abc-analysis.abc-e = 0    .
x-abc-analysis.abc-f = 0    .
end.
if LENGTH(par-abc-type) = 4 then do:
x-abc-analysis.abc-d = 100    .
x-abc-analysis.abc-e = 0    .
x-abc-analysis.abc-f = 0    .
end.
if LENGTH(par-abc-type) = 5 then do:
x-abc-analysis.abc-e = 100    .
x-abc-analysis.abc-f = 0    .
end.
if LENGTH(par-abc-type) = 6 then do:
x-abc-analysis.abc-f = 100    .
end.
assign
  x-abc-analysis.abc-des = x-abc-analysis.abc-des:SCREEN-VALUE
  .
 run ref/abcanal1.p (
                input-output p-doc-rec
                ,p-mode
                ,table x-abc-analysis
                ,table x-abc-analysis-doc
                ,table x-abc-analysis-obj
                ,table x-abc-analysis-period
                ) no-error .
if error-status :error then do:
    return error return-value .
end.
END PROCEDURE.
PROCEDURE proc-sel-rec :
define input  parameter p-abc-a as decimal   no-undo .
define input  parameter p-abc-b as decimal   no-undo .
define input  parameter p-abc-c as decimal   no-undo .
define input  parameter p-abc-d as decimal   no-undo .
define input  parameter p-abc-e as decimal   no-undo .
define variable v-a as decimal   no-undo .
define variable v-b as decimal   no-undo .
define variable v-c as decimal   no-undo .
define variable v-d as decimal   no-undo .
define variable v-e as decimal   no-undo .
define variable v-f as decimal   no-undo .
define variable v-a-pr as decimal   no-undo .
define variable v-b-pr as decimal   no-undo .
define variable v-c-pr as decimal   no-undo .
define variable v-d-pr as decimal   no-undo .
define variable v-e-pr as decimal   no-undo .
define variable old-par-abc-type as character no-undo .
old-par-abc-type = par-abc-type .
if p-abc-e = 100  then  par-abc-type = 'ABCDE':U .
if p-abc-d = 100  then  par-abc-type = 'ABCD':U .
if p-abc-c = 100  then  par-abc-type = 'ABC':U .
if p-abc-e <> 0 and p-abc-e <> 100 then  par-abc-type = 'ABCDEF':U .
if LENGTH(par-abc-type) > LENGTH(old-par-abc-type) then message "Анализ проведен по типу " par-abc-type " а тип работы выставленный в параметре конфигурации " old-par-abc-type
   view-as alert-box information
.
case par-abc-type :
   when 'ABC':U
   then do:
        assign
          v-c    = 37.5
          v-a-pr = p-abc-a
          v-b-pr = p-abc-b
        .
        if v-a-pr >  v-b-pr and v-b-pr <> 0 then do:
            return error "Уровень ранжирования А должны быть меньше В  !!! "  .
        end.
        if v-a-pr > 100 then do:
            return error "Уровень ранжирования А должны быть меньше 100%  !!! "  .
        end.
        if v-b-pr > 100 then do:
            return error "Уровень ранжирования B должны быть меньше 100%  !!! "  .
        end.
        v-a = v-a-pr * v-c / 100 .
        v-b = v-b-pr * v-c / 100 .
        if v-a > 0 then
            rect-a:WIDTH-CHARS in frame Dialog-Frame  =  v-a.
        if v-b > 0 then
            rect-b:WIDTH-CHARS =  v-b.
            rect-c:WIDTH-CHARS =  v-c.
        DISPLAY
          rect-c
          rect-b when v-b > 0
          rect-a
        WITH FRAME Dialog-Frame.
        DISPLAY
          rect-a
        WITH FRAME Dialog-Frame.
        assign
          f-a = "A=" + string(v-a-pr)
          f-b = "B=" + string(v-b-pr - v-a-pr )
          f-c = "C=" + string( 100 - v-b-pr )
          f-d = ""
          f-e = ""
          f-f = ""
        .
        DISPLAY
          f-c when v-b > 0
          f-b when v-b > 0
          f-a when v-a > 0
        WITH FRAME Dialog-Frame.
        hide
        f-d  rect-d x-abc-analysis.abc-d fill-in-4
        f-e  rect-e x-abc-analysis.abc-e fill-in-5
        f-f  rect-f                      fill-in-6
        in frame Dialog-Frame .
   end.
   when 'ABCD':U
   then do:
        assign
          v-d    = 37.5
          v-a-pr = p-abc-a
          v-b-pr = p-abc-b
          v-c-pr = p-abc-c
        .
        if v-a-pr >  v-b-pr and v-b-pr <> 0 then do:
            return error "Уровень ранжирования А должны быть меньше В  !!! "  .
        end.
        if v-b-pr >  v-c-pr and v-c-pr <> 0 then do:
            return error "Уровень ранжирования B должны быть меньше C  !!! "  .
        end.
        if v-a-pr > 100 then do:
            return error "Уровень ранжирования А должны быть меньше 100%  !!! "  .
        end.
        if v-b-pr > 100 then do:
            return error "Уровень ранжирования B должны быть меньше 100%  !!! "  .
        end.
        if v-c-pr > 100 then do:
            return error "Уровень ранжирования C должны быть меньше 100%  !!! "  .
        end.
        v-a = v-a-pr * v-d / 100 .
        v-b = v-b-pr * v-d / 100 .
        v-c = v-c-pr * v-d / 100 .
        if v-a > 0 then
            rect-a:WIDTH-CHARS =  v-a.
        if v-b > 0 then
            rect-b:WIDTH-CHARS =  v-b.
        if v-c > 0 then
            rect-c:WIDTH-CHARS =  v-c.
            rect-d:WIDTH-CHARS =  v-d.
        DISPLAY
          rect-d
          rect-c when v-c > 0
          rect-b when v-b > 0
          rect-a
        WITH FRAME Dialog-Frame.
        DISPLAY
          rect-a
        WITH FRAME Dialog-Frame.
        assign
          f-a = "A=" + string(v-a-pr)
          f-b = "B=" + string(v-b-pr - v-a-pr )
          f-c = "C=" + string( v-c-pr - v-b-pr )
          f-d = "D=" + string( 100 - v-c-pr )
          f-e = ""
          f-f = ""
        .
        display
          f-a when v-a > 0
          f-b when v-b > 0
          f-c when v-c > 0
          f-d when v-d > 0
        with frame Dialog-Frame.
        hide
        f-e  rect-e x-abc-analysis.abc-e fill-in-5
        f-f  rect-f                      fill-in-6
        in frame Dialog-Frame .
   end.
   when 'ABCDE':U
   then do:
        assign
          v-e    = 37.5
          v-d-pr = p-abc-d
          v-a-pr = p-abc-a
          v-b-pr = p-abc-b
          v-c-pr = p-abc-c
        .
        if v-a-pr >  v-b-pr and v-b-pr <> 0 then do:
            return error "Уровень ранжирования А должны быть меньше В  !!! "  .
        end.
        if v-b-pr >  v-c-pr and v-c-pr <> 0 then do:
            return error "Уровень ранжирования B должны быть меньше C  !!! "  .
        end.
        if v-c-pr >  v-d-pr and v-d-pr <> 0 then do:
            return error "Уровень ранжирования C должны быть меньше D  !!! "  .
        end.
        if v-a-pr > 100 then do:
            return error "Уровень ранжирования А должны быть меньше 100%  !!! "  .
        end.
        if v-b-pr > 100 then do:
            return error "Уровень ранжирования B должны быть меньше 100%  !!! "  .
        end.
        if v-c-pr > 100 then do:
            return error "Уровень ранжирования C должны быть меньше 100%  !!! "  .
        end.
        if v-d-pr > 100 then do:
            return error "Уровень ранжирования D должны быть меньше 100%  !!! "  .
        end.
        v-a = v-a-pr * v-e / 100 .
        v-b = v-b-pr * v-e / 100 .
        v-c = v-c-pr * v-e / 100 .
        v-d = v-d-pr * v-e / 100 .
        if v-a > 0 then
            rect-a:WIDTH-CHARS =  v-a.
        if v-b > 0 then
            rect-b:WIDTH-CHARS =  v-b.
        if v-c > 0 then
            rect-c:WIDTH-CHARS =  v-c.
        if v-d > 0 then
            rect-d:WIDTH-CHARS =  v-d.
            rect-e:WIDTH-CHARS =  v-e.
        DISPLAY
          rect-e
          rect-d when v-d > 0
          rect-c when v-c > 0
          rect-b when v-b > 0
          rect-a
        WITH FRAME Dialog-Frame.
        DISPLAY
          rect-a
        WITH FRAME Dialog-Frame.
        assign
          f-a = "A=" + string(v-a-pr)
          f-b = "B=" + string(v-b-pr - v-a-pr )
          f-c = "C=" + string( v-c-pr - v-b-pr )
          f-d = "D=" + string( v-d-pr - v-c-pr )
          f-e = "E=" + string( 100 - v-d-pr )
          f-f = ""
        .
        display
          f-a when v-a > 0
          f-b when v-b > 0
          f-c when v-c > 0
          f-d when v-d > 0
          f-e when v-e > 0
        with frame Dialog-Frame.
        hide
        f-f  rect-f fill-in-6
        in frame Dialog-Frame .
   end.
   when 'ABCDEF':U
   then do:
        assign
          v-f    = 37.5
          v-a-pr = p-abc-a
          v-b-pr = p-abc-b
          v-c-pr = p-abc-c
          v-d-pr = p-abc-d
          v-e-pr = p-abc-e
        .
        if v-a-pr >  v-b-pr and v-b-pr <> 0 then do:
            return error "Уровень ранжирования А должны быть меньше В  !!! "  .
        end.
        if v-b-pr >  v-c-pr and v-c-pr <> 0 then do:
            return error "Уровень ранжирования B должны быть меньше C  !!! "  .
        end.
        if v-c-pr >  v-d-pr and v-d-pr <> 0 then do:
            return error "Уровень ранжирования C должны быть меньше D  !!! "  .
        end.
        if v-d-pr >  v-e-pr and v-e-pr <> 0 then do:
            return error "Уровень ранжирования D должны быть меньше E  !!! "  .
        end.
        if v-a-pr > 100 then do:
            return error "Уровень ранжирования А должны быть меньше 100%  !!! "  .
        end.
        if v-b-pr > 100 then do:
            return error "Уровень ранжирования B должны быть меньше 100%  !!! "  .
        end.
        if v-c-pr > 100 then do:
            return error "Уровень ранжирования C должны быть меньше 100%  !!! "  .
        end.
        if v-d-pr > 100 then do:
            return error "Уровень ранжирования D должны быть меньше 100%  !!! "  .
        end.
        if v-e-pr > 100 then do:
            return error "Уровень ранжирования E должны быть меньше 100%  !!! "  .
        end.
        v-a = v-a-pr * v-f / 100 .
        v-b = v-b-pr * v-f / 100 .
        v-c = v-c-pr * v-f / 100 .
        v-d = v-d-pr * v-f / 100 .
        v-e = v-e-pr * v-f / 100 .
        if v-a > 0 then
            rect-a:WIDTH-CHARS =  v-a.
        if v-b > 0 then
            rect-b:WIDTH-CHARS =  v-b.
        if v-c > 0 then
            rect-c:WIDTH-CHARS =  v-c.
        if v-d > 0 then
            rect-d:WIDTH-CHARS =  v-d.
        if v-e > 0 then
            rect-e:WIDTH-CHARS =  v-e.
            rect-f:WIDTH-CHARS =  v-f.
DISPLAY
  rect-f
  rect-e
  rect-d
  rect-c
  rect-b
  rect-a
WITH FRAME Dialog-Frame.
assign
  f-a = "A=" + string( v-a-pr)
  f-b = "B=" + string( v-b-pr - v-a-pr )
  f-c = "C=" + string( v-c-pr - v-b-pr )
  f-d = "D=" + string( v-d-pr - v-c-pr )
  f-e = "E=" + string( v-e-pr - v-d-pr )
  f-f = "F=" + string( 100    - v-e-pr )
.
  display
    f-a when v-a > 0
    f-b when v-b > 0
    f-c when v-c > 0
    f-d when v-d > 0
    f-e when v-e > 0
    f-f when v-f > 0
  with frame Dialog-Frame.
   end.
end case.
    DISPLAY
      x-abc-analysis.abc-a
      x-abc-analysis.abc-b
      x-abc-analysis.abc-c when  par-abc-type = "ABCD":U   or  par-abc-type = "ABCDE":U or  par-abc-type = "ABCDEF":U
      x-abc-analysis.abc-d when  par-abc-type = "ABCDE":U  or  par-abc-type = "ABCDEF":U
      x-abc-analysis.abc-e when  par-abc-type = "ABCDEF":U
    with frame Dialog-Frame.
 par-abc-type = old-par-abc-type .
END PROCEDURE.
FUNCTION f-name-doc RETURNS CHARACTER
  ( BUFFER buf_abc-analysis-doc FOR  x-abc-analysis-doc   ) :
  define variable v-ret as character no-undo .
  run get-name-from-ext-type (buf_abc-analysis-doc.abcd-ext-doc-type , no , output v-ret ) .
  RETURN v-ret.
END FUNCTION.
