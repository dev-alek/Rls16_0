DEFINE NEW SHARED BUFFER buf_matrix FOR ub.assortment-matrix.
define input parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns             as character   no-undo .
define input parameter p-curr-obj-type   like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code   like ub.clients.obj-code no-undo .
define input parameter p-mode            as character   no-undo .
define input parameter p-sts             as integer   no-undo .
define input-output param p-rid-list     as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список ассортиментных матриц".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure assmatat-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-code in g#attr-lib
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
end procedure.
procedure assmatat-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-value :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-value in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-write :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define input parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-write in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-exist :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-exist in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-delete :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code     like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-delete in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable mark-str  AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable filter-point as character no-undo init "Список Асортиментных матриц" .
define variable filter-point0 as character no-undo init "Асортиментные_матрицы" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark     as character no-undo .
define variable p-shablon     as character no-undo .
define variable p-obj      as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status   as character no-undo .
define variable v-type-s as character no-undo .
define variable v-type-o as character no-undo .
define variable p-asmt-type  as character no-undo .
define buffer pos_assortment-matrix for ub.assortment-matrix.
FUNCTION attrRootShablon RETURNS CHARACTER
  ( p-recid as recid )  FORWARD.
FUNCTION f-name-link RETURNS CHARACTER
  ( p-recid as recid )  FORWARD.
FUNCTION shablon-type RETURNS CHARACTER
  ( p-recid as recid )  FORWARD.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить название матрицы".
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-demark-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Снять все отметки".
DEFINE BUTTON B-goods AUTO-GO
     LABEL "&Товары"
     SIZE 10 BY 1 TOOLTIP "Состав матрицы".
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить".
DEFINE BUTTON B-mark-all
     LABEL "&+"
     SIZE 3 BY 1 TOOLTIP "Отметить все".
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Тип:"
      VIEW-AS TEXT
     SIZE 4.5 BY 1 NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE name-link AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 32 BY 1.25 TOOLTIP "Привязан к Шаблону"
     BGCOLOR 8 FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE v-text_object-bd AS CHARACTER FORMAT "X(256)":U INITIAL "ОбъектыБД:"
      VIEW-AS TEXT
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE v-user-name-corr AS CHARACTER FORMAT "X(256)":U
     LABEL "Изменил"
      VIEW-AS TEXT
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-user-name-create AS CHARACTER FORMAT "X(256)":U
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE IMAGE I-link
     FILENAME "cmp/link.bmp":U
     SIZE 4.5 BY 1.25 TOOLTIP "Привязан к Шаблону".
DEFINE VARIABLE RS-object AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 22.5 BY 1 NO-UNDO.
DEFINE VARIABLE RS-sts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 33.5 BY 1 NO-UNDO.
DEFINE VARIABLE RS-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 33.5 BY 1 NO-UNDO.
DEFINE QUERY BROWSE-AM FOR
      buf_matrix SCROLLING.
DEFINE BROWSE BROWSE-AM
  QUERY BROWSE-AM NO-LOCK DISPLAY
      mark-string(recid( buf_Matrix ), p-rid-list) @ p-mark COLUMN-LABEL "*" FORMAT "x(1)":U
      buf_matrix.asmt-name COLUMN-LABEL "Название" FORMAT "X(20)":U
      buf_matrix.asmt-type + shablon-type (recid ( buf_Matrix )) @ p-asmt-type COLUMN-LABEL "Тип" FORMAT "X(7)":U
      IF (buf_Matrix.obj-code <> 0 ) THEN (buf_Matrix.obj-type + ' ' + string(buf_Matrix.obj-code)) ELSE ("")  @ p-obj COLUMN-LABEL "Объект" FORMAT "x(11)":U
      entry (lookup (STRING(buf_Matrix.asmt-status), '0,1,50,99':U), 'тек,удал,блок,удаление':U) @ p-status COLUMN-LABEL "Статус" FORMAT "x(6)":U
      buf_matrix.asmt-date-update COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      STRING (buf_Matrix.asmt-time-update,"HH:MM") @ p-time-upd COLUMN-LABEL "Время" FORMAT "x(5)":U
      buf_matrix.asmt-db-num-update COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      buf_matrix.asmt-date-create COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      STRING (buf_Matrix.asmt-time-create,"HH:MM") @ p-time-cr COLUMN-LABEL "Время" FORMAT "x(5)":U
      attrRootShablon ( recid ( buf_Matrix ) ) @ p-shablon COLUMN-LABEL "Связка с!шаблоном"
      buf_matrix.asmt-db-num-create COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
  ENABLE
      buf_matrix.asmt-name
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 11.75 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 17.5
     B-add AT ROW 1 COL 27.5
     B-lookup AT ROW 1 COL 37.5
     B-chg AT ROW 1 COL 47.5
     B-del AT ROW 1 COL 57.5
     B-Help AT ROW 1 COL 87.5
     B-mark-all AT ROW 2 COL 11.13 WIDGET-ID 6
     B-demark-all AT ROW 2 COL 14.25 WIDGET-ID 8
     B-goods AT ROW 2 COL 17.5
     B-print AT ROW 2 COL 87.5
     RS-sts AT ROW 3 COL 11.5 NO-LABEL
     B-hist AT ROW 3 COL 87.5
     RS-type AT ROW 4 COL 11.5 NO-LABEL
     RS-object AT ROW 5 COL 11.5 NO-LABEL
     BROWSE-AM AT ROW 6.08 COL 1.5
     ub.buf_matrix.asmt-des AT ROW 19.42 COL 1.5 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 94 BY 2.5
     mark-num AT ROW 1 COL 12 COLON-ALIGNED NO-LABEL
     FILL-IN-1 AT ROW 3 COL 3.5 NO-LABEL
     FILL-IN-2 AT ROW 4 COL 6.5 NO-LABEL
     v-text_object-bd AT ROW 5 COL 1 NO-LABEL
     v-user-name-create AT ROW 17.96 COL 9.5 COLON-ALIGNED WIDGET-ID 2
     name-link AT ROW 18 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     v-user-name-corr AT ROW 18.75 COL 9.5 COLON-ALIGNED WIDGET-ID 4
     I-link AT ROW 18 COL 28.5 WIDGET-ID 10
     SPACE(64.74) SKIP(2.91)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список Ассортиментных матриц".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       buf_matrix.asmt-name:COLUMN-READ-ONLY IN BROWSE BROWSE-AM = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
OR ENDKEY OF FRAME Dialog-Frame DO:
    run gbl/markqwa.p
    (    input b-mark:sensitive
       , input p-rid-list) no-error.
    if error-status:error then return no-apply.
    else p-rid-list = "" .
    APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo.
  define variable loc-doc-rec as recid no-undo .
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr_add-def':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
  if loc#log <> yes then do: return no-apply. end.
  run ref/assmatri.w
                (
                   input parParentProc
                  ,input p-curr-obj-type
                  ,input p-curr-obj-code
                  ,input 'ДОБАВЛЕНИЕ':U
                  ,input 0
                  ,input-output loc-doc-rec
                              ) no-error
  .
  if loc-doc-rec <> ? THEN DO:
      run OpenBR in this-procedure .
      reposition BROWSE-AM to recid loc-doc-rec no-error.
      if error-status:error then do:                           find first pos_assortment-matrix no-lock where                                   recid(pos_assortment-matrix) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи AM" skip                            string(if avail pos_assortment-matrix                                     then  substitute("Вн код AM: &1"                                                     , pos_assortment-matrix.asmt-id)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
  END.
  apply "entry" to BROWSE-AM in frame Dialog-Frame.
  apply "value-changed" to BROWSE-AM in frame Dialog-Frame.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available buf_matrix then return no-apply.
if  buf_matrix.asmt-status = 1  then do:
    message "Корректировать можно только запись в статусе  ТЕК."
    view-as alert-box information .
    return no-apply.
end.
assign
loc-doc-rec = recid(buf_matrix).
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr_update':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
   if loc#log <> yes then do: return no-apply. end.
if buf_matrix.asmt-type = 'Шаблон':U then do:
if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> buf_matrix.asmt-db-num-create then do:
   message
    "Нельзя редактировать ШАБЛОН Ассортиментная матрица созданный в чужой УБД"
    view-as alert-box error.
    return  no-apply.
end.
end.
else do:
define variable obj-db-num as integer   no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_matrix.obj-type
  ,input  buf_matrix.obj-code
  ,output obj-db-num
  )  .
if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> obj-db-num  then do:
   message
    "Нельзя редактировать запись Ассортиментная матрица чужой УБД"
    view-as alert-box error.
    return  no-apply.
end.
end.
   run ref/assmatri.w
                 (
                    input parParentProc
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input 'ИЗМЕНЕНИЕ':U
                   ,input buf_matrix.asmt-id
                   ,input-output loc-doc-rec
                               ) no-error
   .
   if loc-doc-rec <> ? THEN DO:
       run OpenBR in this-procedure .
       reposition BROWSE-AM to recid loc-doc-rec no-error.
       if error-status:error then do:                           find first pos_assortment-matrix no-lock where                                   recid(pos_assortment-matrix) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи AM" skip                            string(if avail pos_assortment-matrix                                     then  substitute("Вн код AM: &1"                                                     , pos_assortment-matrix.asmt-id)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
   END.
   apply "entry" to BROWSE-AM in frame Dialog-Frame.
   apply "value-changed" to BROWSE-AM in frame Dialog-Frame.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
if not available buf_matrix then return no-apply.
if buf_matrix.asmt-type = 'Шаблон':U then do:
if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> buf_matrix.asmt-db-num-create then do:
   message
    "Нельзя удалять ШАБЛОН Ассортиментная матрица созданный в чужой УБД"
    view-as alert-box error.
    return  no-apply.
end.
end.
else do:
define variable obj-db-num as integer   no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_matrix.obj-type
  ,input  buf_matrix.obj-code
  ,output obj-db-num
  )  .
if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> obj-db-num  then do:
   message
    "Нельзя удалять запись Ассортиментная матрица чужой УБД"
    view-as alert-box error.
    return  no-apply.
end.
end.
run proc-b-del in this-procedure no-error.
if error-status:error then return no-apply.
END.
ON ALT-- OF B-demark-all IN FRAME Dialog-Frame
DO:
  apply "CHOOSE":U to b-demark-all in frame Dialog-Frame .
END.
ON CHOOSE OF B-demark-all IN FRAME Dialog-Frame
DO:
  p-rid-list = "".
  run OpenBR in this-procedure .
  apply "entry" to BROWSE-AM in frame Dialog-Frame.
END.
ON CHOOSE OF B-goods IN FRAME Dialog-Frame
DO:
if not available buf_matrix then return no-apply.
define variable loc#log as logical   no-undo .
define variable loc-doc-rec as recid no-undo .
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-gds_lookup':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
  if loc#log <> yes then do: return no-apply. end.
 loc-doc-rec = recid(buf_matrix).
  run ref/gds-matr.w ( parParentProc ,
                   buf_matrix.asmt-id ,
                   buf_matrix.db-num  ,
                   p-curr-obj-type   ,
                   p-curr-obj-code ,
                   (IF buf_matrix.asmt-status = 0 THEN "all" ELSE "no-button")
                   ) NO-ERROR.
if error-status :error  then do:
  message error-status :get-message(1) return-value .
  return no-apply.
end.
  run OpenBR in this-procedure .
  reposition BROWSE-AM to recid loc-doc-rec no-error.
  if error-status:error then do:                           find first pos_assortment-matrix no-lock where                                   recid(pos_assortment-matrix) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи AM" skip                            string(if avail pos_assortment-matrix                                     then  substitute("Вн код AM: &1"                                                     , pos_assortment-matrix.asmt-id)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
  return no-apply.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  define variable pp-rid-list as character no-undo .
if not available buf_matrix then return no-apply.
 run str/cassmatr.w (
  input  parparentproc ,
  input  buf_Matrix.asmt-id ,
  input  buf_Matrix.db-num ,
  input-output pp-rid-list    ).
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available buf_matrix then return no-apply.
assign
loc-doc-rec = recid(buf_matrix).
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr_lookup':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
   if loc#log <> yes then do: return no-apply. end.
   run ref/assmatri.w
                 (
                    input parParentProc
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input 'ПРОСМОТР':U
                   ,input buf_matrix.asmt-id
                   ,input-output loc-doc-rec
                   ) no-error   .
   apply "entry" to BROWSE-AM in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo .
  if AVAILABLE buf_matrix  then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid19 as character no-undo .
define variable v-num-entry19 as integer   no-undo .
assign
  v-str-recid19 = trim( string( recid( buf_matrix ) , "->>>>>>>>>>>9":U ) )
  v-num-entry19 = lookup( v-str-recid19 , p-rid-list )
.
if v-num-entry19 > 0 then do:
  assign
    entry( v-num-entry19, p-rid-list ) = "":U
    p-rid-list = trim( replace( p-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    p-rid-list = p-rid-list + ( if p-rid-list = "":U then "":U else chr(44) ) + v-str-recid19
  .
end.
    loc#log = BROWSE-AM:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = BROWSE-AM:select-next-row ().
        apply "VALUE-CHANGED" to BROWSE-AM in frame Dialog-Frame.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to BROWSE-AM in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark-all IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
     run OpenBR in this-procedure .
        DO WHILE available buf_matrix  :
          if available buf_matrix then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid21 as character no-undo .
define variable v-num-entry21 as integer   no-undo .
assign
  v-str-recid21 = trim( string( recid( buf_matrix ) , "->>>>>>>>>>>9":U ) )
  v-num-entry21 = lookup( v-str-recid21 , p-rid-list )
.
if v-num-entry21 > 0 then do:
  assign
    entry( v-num-entry21, p-rid-list ) = "":U
    p-rid-list = trim( replace( p-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    p-rid-list = p-rid-list + ( if p-rid-list = "":U then "":U else chr(44) ) + v-str-recid21
  .
end.
        end.
        GET next BROWSE-AM.
    end.
  run OpenBR in this-procedure .
  apply "entry" to BROWSE-AM in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
  IF  p-rid-list = "" THEN DO:
      IF AVAILABLE buf_matrix THEN p-rid-list = string(RECID(buf_matrix)).
  END.
END.
ON ROW-DISPLAY OF BROWSE-AM IN FRAME Dialog-Frame
DO:
  IF can-find (first  assortment-matrix-goods no-lock where
                      assortment-matrix-goods.db-num  = buf_matrix.db-num and
                      assortment-matrix-goods.asmg-status  = 0 and
                      assortment-matrix-goods.asmt-id = buf_matrix.asmt-id )  THEN DO:
      buf_matrix.asmt-date-create   :fgcolor in browse BROWSE-AM = ?.
      buf_matrix.asmt-date-update   :fgcolor in browse BROWSE-AM = ?.
      buf_matrix.asmt-db-num-create :fgcolor in browse BROWSE-AM = ?.
      buf_matrix.asmt-db-num-update :fgcolor in browse BROWSE-AM = ?.
      buf_matrix.asmt-name         :fgcolor in browse BROWSE-AM = ? .
      p-asmt-type         :fgcolor in browse BROWSE-AM = ? .
      p-mark                       :fgcolor in browse BROWSE-AM = ? .
      p-obj                        :fgcolor in browse BROWSE-AM = ? .
      p-time-upd                   :fgcolor in browse BROWSE-AM = ? .
      p-time-cr                    :fgcolor in browse BROWSE-AM = ? .
      p-status                     :fgcolor in browse BROWSE-AM = ? .
  END.
  ELSE DO:
      buf_matrix.asmt-date-create   :fgcolor in browse BROWSE-AM = DARK_GRAY_COLOR.
      buf_matrix.asmt-date-update   :fgcolor in browse BROWSE-AM = DARK_GRAY_COLOR.
      buf_matrix.asmt-db-num-create :fgcolor in browse BROWSE-AM = DARK_GRAY_COLOR.
      buf_matrix.asmt-db-num-update :fgcolor in browse BROWSE-AM = DARK_GRAY_COLOR.
      buf_matrix.asmt-name         :fgcolor in browse BROWSE-AM  = DARK_GRAY_COLOR.
      p-asmt-type         :fgcolor in browse BROWSE-AM  = DARK_GRAY_COLOR.
      p-mark                       :fgcolor in browse BROWSE-AM  = DARK_GRAY_COLOR.
      p-obj                        :fgcolor in browse BROWSE-AM  = DARK_GRAY_COLOR.
      p-time-upd                   :fgcolor in browse BROWSE-AM  = DARK_GRAY_COLOR.
      p-time-cr                    :fgcolor in browse BROWSE-AM  = DARK_GRAY_COLOR.
      p-status                     :fgcolor in browse BROWSE-AM  = DARK_GRAY_COLOR.
  END.
END.
ON VALUE-CHANGED OF BROWSE-AM IN FRAME Dialog-Frame
DO:
    IF AVAILABLE buf_Matrix THEN DO:
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  buf_matrix.asmt-who-create
  ,output v-user-name-create
  )  .
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  buf_matrix.asmt-who-update
  ,output v-user-name-corr
  )  .
        DISPLAY buf_Matrix.asmt-des
                v-user-name-corr
                v-user-name-create
        WITH FRAME Dialog-Frame.
        name-link = f-name-link(recid(buf_Matrix)).
       if name-link <> "" then do:
          display i-link name-link with frame Dialog-Frame .
       end.
       else do:
         hide i-link name-link in frame Dialog-Frame .
       end.
    END.
    else do:
      hide i-link name-link in frame Dialog-Frame .
    end.
END.
ON VALUE-CHANGED OF RS-object IN FRAME Dialog-Frame
DO:
  run openbr in this-procedure no-error.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF RS-sts IN FRAME Dialog-Frame
DO:
  RUN openbr IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF RS-type IN FRAME Dialog-Frame
DO:
  RUN openbr IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
    end.
    else do:
    end.
  end.
end procedure.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-AM :handle
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
def var sort-labelBROWSE-AM   as character no-undo .
def var sort-clmnBROWSE-AM    as handle    no-undo .
def var cur-clmnBROWSE-AM     as handle    no-undo .
def var cur-clmn-locBROWSE-AM as integer   no-undo .
def var re-queryBROWSE-AM     as logical   initial no no-undo .
on start-search, ctrl-o of BROWSE-AM in frame Dialog-Frame do:
   run sort-brBROWSE-AM
     (input (if available buf_Matrix
             then recid(buf_Matrix)
             else ?
            )
     ).
end.
PROCEDURE sort-brBROWSE-AM :
  define input parameter p-recid as recid no-undo .
  if re-queryBROWSE-AM = no then do:
    assign
       cur-clmnBROWSE-AM = BROWSE-AM:current-column in frame Dialog-Frame
    .
    if sort-clmnBROWSE-AM <> ? then sort-clmnBROWSE-AM:column-fgcolor = 0.
    if cur-clmnBROWSE-AM = sort-clmnBROWSE-AM then do:
      assign
         sort-labelBROWSE-AM = ""
         sort-clmnBROWSE-AM = ?
      .
     end.
     else do:
       assign
         sort-labelBROWSE-AM = cur-clmnBROWSE-AM:label
         sort-clmnBROWSE-AM  = cur-clmnBROWSE-AM
         sort-clmnBROWSE-AM:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBROWSE-AM = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BROWSE-AM:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBROWSE-AM then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBROWSE-AM = cur-clmn-locBROWSE-AM + 1
    .
  end.
  case sort-labelBROWSE-AM:
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(buf_Matrix), &1&2&1)', chr(34), p-rid-list)     .     run OpenBr.   . END.
        when 'Название'  then DO:    assign       sort-column-name = "buf_Matrix.asmt-name"     .     run OpenBr.   . END.
        when 'Тип'  then DO:    assign       sort-column-name = "buf_Matrix.asmt-type"     .     run OpenBr.   . END.
        when 'Объект'  then DO:    assign       sort-column-name = "buf_Matrix.obj-type + ' ' + string(buf_Matrix.obj-code,'>>>>>>>>>')"     .     run OpenBr.   . END.
        when 'Дата!изменения'  then DO:    assign       sort-column-name = "buf_Matrix.asmt-date-update"     .     run OpenBr.   . END.
        when 'Время'  then DO:    assign       sort-column-name = "STRING (buf_Matrix.asmt-time-update,'HH:MM')"     .     run OpenBr.   . END.
        when 'Кто!изменил'  then DO:    assign       sort-column-name = "buf_Matrix.asmt-who-update"     .     run OpenBr.   . END.
        when 'БД!изм'  then DO:    assign       sort-column-name = "buf_Matrix.asmt-db-num-update"     .     run OpenBr.   . END.
        when 'Дата!создания'  then DO:    assign       sort-column-name = "buf_Matrix.asmt-date-create"     .     run OpenBr.   . END.
        when 'Время'  then DO:    assign       sort-column-name = "STRING (buf_Matrix.asmt-time-create,'HH:MM')"     .     run OpenBr.   . END.
        when 'Кто!создал'  then DO:    assign       sort-column-name = "buf_Matrix.asmt-who-create"     .     run OpenBr.   . END.
        when 'БД!соз'  then DO:    assign       sort-column-name = "buf_Matrix.asmt-db-num-create"     .     run OpenBr.   . END.
        when 'Статус'  then DO:    assign       sort-column-name = "entry (lookup (STRING(buf_Matrix.asmt-status), '0,1,50,99':U), 'тек,удал,блок,удаление':U)"     .     run OpenBr.   . END.
        when 'Связка с!шаблоном'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1attrRootShablon&1, recid(buf_Matrix))', chr(34))     .     run OpenBr.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr.
      if sort-labelBROWSE-AM <> "" then do:
        assign
          cur-clmnBROWSE-AM:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBROWSE-AM = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition BROWSE-AM to recid p-recid no-error.
    apply "value-changed" to BROWSE-AM in frame Dialog-Frame.
  end.
  apply "entry" to BROWSE-AM in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBROWSE-AM:
if cur-clmnBROWSE-AM = ? then do:
   run OpenBr.
end.
else do:
   assign re-queryBROWSE-AM = yes.
   run sort-brBROWSE-AM
     (input (if available buf_Matrix
             then recid(buf_Matrix)
             else ?
            )
     ).
   assign re-queryBROWSE-AM = no.
end.
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BROWSE-AM :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
  run my_enable in this-procedure .
  hide mark-num in frame Dialog-Frame .
  if v-doc-rec <> ? then
  reposition BROWSE-AM to recid v-doc-rec no-error.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_ui in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RS-sts RS-type RS-object mark-num FILL-IN-1 FILL-IN-2 v-text_object-bd
          v-user-name-create name-link v-user-name-corr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_matrix THEN
    DISPLAY buf_matrix.asmt-des
      WITH FRAME Dialog-Frame.
  ENABLE b-quit I-link B-mark B-sel B-add B-lookup B-chg B-del B-Help
         B-mark-all B-demark-all B-goods B-print RS-sts B-hist RS-type
         RS-object BROWSE-AM buf_matrix.asmt-des mark-num FILL-IN-1 FILL-IN-2
         v-text_object-bd v-user-name-create name-link v-user-name-corr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-AM FOR EACH buf_matrix NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE my_enable :
define variable v-db-num like ub.db.db-num no-undo .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
buf_Matrix.asmt-name:read-only in browse BROWSE-AM = true .
buf_Matrix.asmt-name:resizable in browse BROWSE-AM = true .
ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME Dialog-Frame
              = "Текущие&+" + chr(44) +  '0':U + chr(44) +
              "Все&!" + chr(44) + 'все':U + chr(44) +
              "Удаленные&-" + chr(44) + '1':U
rs-sts = (IF p-sts = ? THEN '0':U ELSE string(p-sts))
rs-type:RADIO-BUTTONS IN FRAME Dialog-Frame
                = "Все" + chr(44) +  "1" + chr(44) +
                "Объект" + chr(44) + "2" + chr(44) +
                "Шаблон" + chr(44) + "3"
rs-object:RADIO-BUTTONS IN FRAME Dialog-Frame
                = "Своя БД" + chr(44) +  "1" + chr(44) +
                  "Все БД" + chr(44) + "2"
.
if v-db-num = 0 then
      assign
        rs-object = "2"
        rs-type = "1"
      .
    else
      assign
        rs-object = "1"
        rs-type = "1"
      .
if p-mode = 'Шаблон':U then do:
   rs-type = "3" .
   rs-type:RADIO-BUTTONS IN FRAME Dialog-Frame =   "Шаблон" + chr(44) + "3" .
   display rs-type with frame Dialog-Frame .
end.
v-type-s  = 'Шаблон':U  .
v-type-o  = 'Объект':U .
if rs-type = "3" then v-type = 'Шаблон':U .
if rs-type = "2" then v-type = 'Объект':U .
rs-sts = '0':U .
DISPLAY mark-num
FILL-IN-1
FILL-IN-2
v-text_object-bd
RS-sts
RS-type
RS-object
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-mark-all when LOOKUP("b-mark":U, bttns) > 0
B-demark-all when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-add when LOOKUP("b-add":U, bttns) > 0
B-lookup
B-chg when LOOKUP("b-add":U, bttns) > 0
B-del when LOOKUP("b-add":U, bttns) > 0
B-print
B-Help
B-hist
BROWSE-AM
mark-num
RS-sts
RS-type
RS-object
b-goods
buf_matrix.asmt-des
with FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
buf_matrix.asmt-des:READ-ONLY = TRUE.
run openbr in this-procedure no-error.
IF ERROR-STATUS:ERROR  THEN RETURN error.
END PROCEDURE.
PROCEDURE openBr :
define variable p-open-query     as logical   no-undo init true .
define variable l-query-was-opened as logical no-undo .
define variable doc-rec  as recid     no-undo .
define variable  p-find-next      as logical   no-undo .
define variable  p-find-condition as character no-undo .
ASSIGN  FRAME Dialog-Frame
  rs-sts
  rs-object
  rs-type
    .
ASSIGN
  p-sts = (IF rs-sts = 'все':U THEN ? ELSE INTEGER(rs-sts))
  .
  if rs-type = "3" then v-type = 'Шаблон':U .
  if rs-type = "2" then v-type = 'Объект':U .
  if rs-type = "1" then v-type = "" .
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
define variable title0 as character no-undo init "Список Ассортиментных матриц".
IF p-sts = ? THEN DO:
    frame Dialog-Frame:TITLE = title0  .
    if rs-type = "1" or rs-type = "" then do:
        if rs-object = "2" then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-32  as logical   no-undo .
define variable  l-filter-open-32    as logical   .
define variable  flt-rec-32       as recid     no-undo .
define variable  filter-name-32      as character no-undo .
define variable  where-phrase-32     as character no-undo .
define variable  sort-phrase-32      as character no-undo .
define variable  where-phrase-rus-32 as character no-undo .
define variable  sort-phrase-rus-32  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-32
  ,output filter-name-32
  ,output where-phrase-32
  ,output sort-phrase-32
  ,output where-phrase-rus-32
  ,output sort-phrase-rus-32
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-32
      ) no-error .
  assign
    l-filter-open-32 = false
  .
  if flt-rec-32 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-32 as character no-undo .
    define variable  parameter-3-32 as character no-undo .
    define variable  parameter-4-32 as character no-undo .
    define variable  parameter-5-32 as character no-undo .
    define variable  parameter-6-32 as character no-undo .
    define variable  parameter-7-32 as character no-undo .
      assign
      parameter-3-32 =
                              "FOR EACH buf_Matrix"
      parameter-4-32 =
        (
          if (" true " + " " + where-phrase-32) <> ""
          then  'true'  + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + "")
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + " USE-INDEX asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX asmt-name " +
          " " + sort-column-phrase +
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-32 =
          (" true " + " " + where-phrase-32 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input parameter-3-32
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ,input parameter-6-32
                          ,input parameter-7-32
                          )
      .
      assign
        l-filter-open-32 = true
      .
    end.
    if l-filter-open-32 = false then do:
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
  if l-filter-open-32 = false then do:
    OPEN QUERY BROWSE-AM FOR EACH buf_Matrix
      where  true
       USE-INDEX asmt-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_matrix )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-AM:handle:get-buffer-handle(1) = (buffer buf_Matrix:handle) then do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-4-32 =
        "where ":u +  'true'  + " ":u + where-phrase-32 + " ":u + p-find-condition + " " + ""
      parameter-5-32 = " USE-INDEX asmt-name "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input rowid(buf_matrix)
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input (buffer buf_matrix:handle)
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-32 = (if p-find-next then "true":u else "false":u )
      parameter-3-32 =  "FOR EACH buf_Matrix"
      parameter-4-32 =
        (
          if (" true " + " " + where-phrase-32) <> ""
          then  'true'  + " " + where-phrase-32
          else "true"
        )
      parameter-5-32 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-32 = if sort-phrase-32 = ''
                           then
        (
        " " + " USE-INDEX asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX asmt-name " +
          " " + sort-column-phrase +
        " " + sort-phrase-32
        )
      parameter-7-32 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input logical(parameter-2-32)
                          ,input no-lock
                          ,input parameter-3-32
                          ,input parameter-4-32
                          ,input parameter-5-32
                          ,input parameter-6-32
                          ,input parameter-7-32
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        end.
        else do:
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
                              "FOR EACH buf_Matrix"
      parameter-4-34 =
        (
          if (" ( buf_Matrix.db-num-obj = v-db-num  and  buf_Matrix.asmt-type = v-type-o) or ( buf_Matrix.asmt-type = v-type-s )" + " " + where-phrase-34) <> ""
          then  substitute(' ( buf_Matrix.db-num-obj = &2 and  buf_Matrix.asmt-type = &1&3&1 ) or ( buf_Matrix.asmt-type = &1&4&1  ) ' , chr(34) ,v-db-num  , v-type-o , v-type-s )  + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + "")
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + " USE-INDEX asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX asmt-name " +
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
          (" ( buf_Matrix.db-num-obj = v-db-num  and  buf_Matrix.asmt-type = v-type-o) or ( buf_Matrix.asmt-type = v-type-s )" + " " + where-phrase-34 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
    OPEN QUERY BROWSE-AM FOR EACH buf_Matrix
      where  ( buf_Matrix.db-num-obj = v-db-num  and  buf_Matrix.asmt-type = v-type-o) or ( buf_Matrix.asmt-type = v-type-s )
       USE-INDEX asmt-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_matrix )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-AM:handle:get-buffer-handle(1) = (buffer buf_Matrix:handle) then do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-4-34 =
        "where ":u +  substitute(' ( buf_Matrix.db-num-obj = &2 and  buf_Matrix.asmt-type = &1&3&1 ) or ( buf_Matrix.asmt-type = &1&4&1  ) ' , chr(34) ,v-db-num  , v-type-o , v-type-s )  + " ":u + where-phrase-34 + " ":u + p-find-condition + " " + ""
      parameter-5-34 = " USE-INDEX asmt-name "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input rowid(buf_matrix)
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input (buffer buf_matrix:handle)
                          ,input parameter-4-34
                          ,input parameter-5-34
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-3-34 =  "FOR EACH buf_Matrix"
      parameter-4-34 =
        (
          if (" ( buf_Matrix.db-num-obj = v-db-num  and  buf_Matrix.asmt-type = v-type-o) or ( buf_Matrix.asmt-type = v-type-s )" + " " + where-phrase-34) <> ""
          then  substitute(' ( buf_Matrix.db-num-obj = &2 and  buf_Matrix.asmt-type = &1&3&1 ) or ( buf_Matrix.asmt-type = &1&4&1  ) ' , chr(34) ,v-db-num  , v-type-o , v-type-s )  + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + " USE-INDEX asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX asmt-name " +
          " " + sort-column-phrase +
        " " + sort-phrase-34
        )
      parameter-7-34 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        end.
    end.
    else do:
        if rs-object = "2" then do:
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
                              "FOR EACH buf_Matrix"
      parameter-4-36 =
        (
          if (" buf_Matrix.asmt-type = v-type  " + " " + where-phrase-36) <> ""
          then  substitute(' buf_Matrix.asmt-type = &1&2&1  ' , chr(34) , v-type )  + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + "")
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
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
          (" buf_Matrix.asmt-type = v-type  " + " " + where-phrase-36 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
    OPEN QUERY BROWSE-AM FOR EACH buf_Matrix
      where  buf_Matrix.asmt-type = v-type
       USE-INDEX  asmt-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_matrix )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-AM:handle:get-buffer-handle(1) = (buffer buf_Matrix:handle) then do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-4-36 =
        "where ":u +  substitute(' buf_Matrix.asmt-type = &1&2&1  ' , chr(34) , v-type )  + " ":u + where-phrase-36 + " ":u + p-find-condition + " " + ""
      parameter-5-36 = " USE-INDEX  asmt-name "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input rowid(buf_matrix)
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input (buffer buf_matrix:handle)
                          ,input parameter-4-36
                          ,input parameter-5-36
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-3-36 =  "FOR EACH buf_Matrix"
      parameter-4-36 =
        (
          if (" buf_Matrix.asmt-type = v-type  " + " " + where-phrase-36) <> ""
          then  substitute(' buf_Matrix.asmt-type = &1&2&1  ' , chr(34) , v-type )  + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + sort-phrase-36
        )
      parameter-7-36 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        end.
        else do:
            if v-type = 'Шаблон':U then do:
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
                              "FOR EACH buf_Matrix"
      parameter-4-38 =
        (
          if (" buf_Matrix.asmt-type = v-type  " + " " + where-phrase-38) <> ""
          then  substitute(' buf_Matrix.asmt-type = &1&2&1  ' , chr(34) , v-type )  + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + "")
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
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
          (" buf_Matrix.asmt-type = v-type  " + " " + where-phrase-38 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
    OPEN QUERY BROWSE-AM FOR EACH buf_Matrix
      where  buf_Matrix.asmt-type = v-type
       USE-INDEX  asmt-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_matrix )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-AM:handle:get-buffer-handle(1) = (buffer buf_Matrix:handle) then do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-4-38 =
        "where ":u +  substitute(' buf_Matrix.asmt-type = &1&2&1  ' , chr(34) , v-type )  + " ":u + where-phrase-38 + " ":u + p-find-condition + " " + ""
      parameter-5-38 = " USE-INDEX  asmt-name "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input rowid(buf_matrix)
                          ,input logical(parameter-2-38)
                          ,input no-lock
                          ,input (buffer buf_matrix:handle)
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-38 = (if p-find-next then "true":u else "false":u )
      parameter-3-38 =  "FOR EACH buf_Matrix"
      parameter-4-38 =
        (
          if (" buf_Matrix.asmt-type = v-type  " + " " + where-phrase-38) <> ""
          then  substitute(' buf_Matrix.asmt-type = &1&2&1  ' , chr(34) , v-type )  + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-38 = if sort-phrase-38 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + sort-phrase-38
        )
      parameter-7-38 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
            end.
            else do:
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
                              "FOR EACH buf_Matrix"
      parameter-4-40 =
        (
          if (" buf_Matrix.asmt-type = v-type and buf_Matrix.db-num-obj = v-db-num " + " " + where-phrase-40) <> ""
          then  substitute(' buf_Matrix.asmt-type = &1&2&1 and buf_Matrix.db-num-obj = &3 ' , chr(34) , v-type , v-db-num )  + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "")
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
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
          (" buf_Matrix.asmt-type = v-type and buf_Matrix.db-num-obj = v-db-num " + " " + where-phrase-40 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
    OPEN QUERY BROWSE-AM FOR EACH buf_Matrix
      where  buf_Matrix.asmt-type = v-type and buf_Matrix.db-num-obj = v-db-num
       USE-INDEX  asmt-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_matrix )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-AM:handle:get-buffer-handle(1) = (buffer buf_Matrix:handle) then do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-4-40 =
        "where ":u +  substitute(' buf_Matrix.asmt-type = &1&2&1 and buf_Matrix.db-num-obj = &3 ' , chr(34) , v-type , v-db-num )  + " ":u + where-phrase-40 + " ":u + p-find-condition + " " + ""
      parameter-5-40 = " USE-INDEX  asmt-name "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input rowid(buf_matrix)
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input (buffer buf_matrix:handle)
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-3-40 =  "FOR EACH buf_Matrix"
      parameter-4-40 =
        (
          if (" buf_Matrix.asmt-type = v-type and buf_Matrix.db-num-obj = v-db-num " + " " + where-phrase-40) <> ""
          then  substitute(' buf_Matrix.asmt-type = &1&2&1 and buf_Matrix.db-num-obj = &3 ' , chr(34) , v-type , v-db-num )  + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + sort-phrase-40
        )
      parameter-7-40 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
            end.
        end.
    end.
END.
ELSE DO:
    frame Dialog-Frame:TITLE = title0 + chr(32) + entry (lookup (STRING(p-sts), '0,1,50,99':U), 'тек,удал,блок,удаление':U).
    if rs-type = "1" or rs-type = "" then do:
        if rs-object = "2" then do:
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
                              "FOR EACH buf_Matrix"
      parameter-4-42 =
        (
          if (" buf_Matrix.asmt-status = p-sts " + " " + where-phrase-42) <> ""
          then  substitute(' buf_Matrix.asmt-status = &1 ' , p-sts )  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "")
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
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
          (" buf_Matrix.asmt-status = p-sts " + " " + where-phrase-42 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
    OPEN QUERY BROWSE-AM FOR EACH buf_Matrix
      where  buf_Matrix.asmt-status = p-sts
       USE-INDEX  asmt-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_matrix )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-AM:handle:get-buffer-handle(1) = (buffer buf_Matrix:handle) then do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-4-42 =
        "where ":u +  substitute(' buf_Matrix.asmt-status = &1 ' , p-sts )  + " ":u + where-phrase-42 + " ":u + p-find-condition + " " + ""
      parameter-5-42 = " USE-INDEX  asmt-name "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input rowid(buf_matrix)
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input (buffer buf_matrix:handle)
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-3-42 =  "FOR EACH buf_Matrix"
      parameter-4-42 =
        (
          if (" buf_Matrix.asmt-status = p-sts " + " " + where-phrase-42) <> ""
          then  substitute(' buf_Matrix.asmt-status = &1 ' , p-sts )  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + sort-phrase-42
        )
      parameter-7-42 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        end.
        else do:
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
                              "FOR EACH buf_Matrix"
      parameter-4-44 =
        (
          if (" buf_Matrix.asmt-status = p-sts and TRUE and ((buf_Matrix.db-num-obj = v-db-num  and  buf_Matrix.asmt-type = v-type-o) or ( buf_Matrix.asmt-type = v-type-s )) " + " " + where-phrase-44) <> ""
          then  substitute(' buf_Matrix.asmt-status = &5 and TRUE and (( buf_Matrix.db-num-obj = &2 and  buf_Matrix.asmt-type = &1&3&1 ) or ( buf_Matrix.asmt-type = &1&4&1  )) ' , chr(34) ,v-db-num  , v-type-o , v-type-s ,p-sts)  + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "")
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
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
          (" buf_Matrix.asmt-status = p-sts and TRUE and ((buf_Matrix.db-num-obj = v-db-num  and  buf_Matrix.asmt-type = v-type-o) or ( buf_Matrix.asmt-type = v-type-s )) " + " " + where-phrase-44 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
    OPEN QUERY BROWSE-AM FOR EACH buf_Matrix
      where  buf_Matrix.asmt-status = p-sts and TRUE and ((buf_Matrix.db-num-obj = v-db-num  and  buf_Matrix.asmt-type = v-type-o) or ( buf_Matrix.asmt-type = v-type-s ))
       USE-INDEX  asmt-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_matrix )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-AM:handle:get-buffer-handle(1) = (buffer buf_Matrix:handle) then do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-4-44 =
        "where ":u +  substitute(' buf_Matrix.asmt-status = &5 and TRUE and (( buf_Matrix.db-num-obj = &2 and  buf_Matrix.asmt-type = &1&3&1 ) or ( buf_Matrix.asmt-type = &1&4&1  )) ' , chr(34) ,v-db-num  , v-type-o , v-type-s ,p-sts)  + " ":u + where-phrase-44 + " ":u + p-find-condition + " " + ""
      parameter-5-44 = " USE-INDEX  asmt-name "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input rowid(buf_matrix)
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input (buffer buf_matrix:handle)
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-3-44 =  "FOR EACH buf_Matrix"
      parameter-4-44 =
        (
          if (" buf_Matrix.asmt-status = p-sts and TRUE and ((buf_Matrix.db-num-obj = v-db-num  and  buf_Matrix.asmt-type = v-type-o) or ( buf_Matrix.asmt-type = v-type-s )) " + " " + where-phrase-44) <> ""
          then  substitute(' buf_Matrix.asmt-status = &5 and TRUE and (( buf_Matrix.db-num-obj = &2 and  buf_Matrix.asmt-type = &1&3&1 ) or ( buf_Matrix.asmt-type = &1&4&1  )) ' , chr(34) ,v-db-num  , v-type-o , v-type-s ,p-sts)  + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        end.
    end.
    else do:
        if rs-object = "2" then do:
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
                              "FOR EACH buf_Matrix"
      parameter-4-46 =
        (
          if (" buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type " + " " + where-phrase-46) <> ""
          then  substitute(' buf_matrix.asmt-status = &2 and true and buf_matrix.asmt-type = &1&3&1 ' , chr(34) , p-sts , v-type )  + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + "")
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
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
          (" buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type " + " " + where-phrase-46 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
    OPEN QUERY BROWSE-AM FOR EACH buf_Matrix
      where  buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type
       USE-INDEX  asmt-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_matrix )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-AM:handle:get-buffer-handle(1) = (buffer buf_Matrix:handle) then do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-4-46 =
        "where ":u +  substitute(' buf_matrix.asmt-status = &2 and true and buf_matrix.asmt-type = &1&3&1 ' , chr(34) , p-sts , v-type )  + " ":u + where-phrase-46 + " ":u + p-find-condition + " " + ""
      parameter-5-46 = " USE-INDEX  asmt-name "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input rowid(buf_matrix)
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input (buffer buf_matrix:handle)
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-3-46 =  "FOR EACH buf_Matrix"
      parameter-4-46 =
        (
          if (" buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type " + " " + where-phrase-46) <> ""
          then  substitute(' buf_matrix.asmt-status = &2 and true and buf_matrix.asmt-type = &1&3&1 ' , chr(34) , p-sts , v-type )  + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + sort-phrase-46
        )
      parameter-7-46 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        end.
        else do:
            if v-type = 'Шаблон':U then do:
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
                              "FOR EACH buf_Matrix"
      parameter-4-48 =
        (
          if (" buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type " + " " + where-phrase-48) <> ""
          then  substitute(' buf_matrix.asmt-status = &2 and true and buf_matrix.asmt-type = &1&3&1  ' , chr(34) , p-sts , v-type )  + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + "")
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
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
          (" buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type " + " " + where-phrase-48 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
    OPEN QUERY BROWSE-AM FOR EACH buf_Matrix
      where  buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type
       USE-INDEX  asmt-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_matrix )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-AM:handle:get-buffer-handle(1) = (buffer buf_Matrix:handle) then do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-4-48 =
        "where ":u +  substitute(' buf_matrix.asmt-status = &2 and true and buf_matrix.asmt-type = &1&3&1  ' , chr(34) , p-sts , v-type )  + " ":u + where-phrase-48 + " ":u + p-find-condition + " " + ""
      parameter-5-48 = " USE-INDEX  asmt-name "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input rowid(buf_matrix)
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input (buffer buf_matrix:handle)
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-3-48 =  "FOR EACH buf_Matrix"
      parameter-4-48 =
        (
          if (" buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type " + " " + where-phrase-48) <> ""
          then  substitute(' buf_matrix.asmt-status = &2 and true and buf_matrix.asmt-type = &1&3&1  ' , chr(34) , p-sts , v-type )  + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + sort-phrase-48
        )
      parameter-7-48 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
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
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
            end.
            else do:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-50  as logical   no-undo .
define variable  l-filter-open-50    as logical   .
define variable  flt-rec-50       as recid     no-undo .
define variable  filter-name-50      as character no-undo .
define variable  where-phrase-50     as character no-undo .
define variable  sort-phrase-50      as character no-undo .
define variable  where-phrase-rus-50 as character no-undo .
define variable  sort-phrase-rus-50  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-50
  ,output filter-name-50
  ,output where-phrase-50
  ,output sort-phrase-50
  ,output where-phrase-rus-50
  ,output sort-phrase-rus-50
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-50
      ) no-error .
  assign
    l-filter-open-50 = false
  .
  if flt-rec-50 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-50 as character no-undo .
    define variable  parameter-3-50 as character no-undo .
    define variable  parameter-4-50 as character no-undo .
    define variable  parameter-5-50 as character no-undo .
    define variable  parameter-6-50 as character no-undo .
    define variable  parameter-7-50 as character no-undo .
      assign
      parameter-3-50 =
                              "FOR EACH buf_Matrix"
      parameter-4-50 =
        (
          if (" buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type  and buf_Matrix.db-num-obj = v-db-num" + " " + where-phrase-50) <> ""
          then  substitute(' buf_matrix.asmt-status = &2 and true and buf_matrix.asmt-type = &1&3&1 and buf_Matrix.db-num-obj = &4 ' , chr(34) , p-sts , v-type  , v-db-num)  + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + "")
      parameter-6-50 = if sort-phrase-50 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + sort-phrase-50
        )
      parameter-7-50 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-50 =
          (" buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type  and buf_Matrix.db-num-obj = v-db-num" + " " + where-phrase-50 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input parameter-3-50
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ,input parameter-6-50
                          ,input parameter-7-50
                          )
      .
      assign
        l-filter-open-50 = true
      .
    end.
    if l-filter-open-50 = false then do:
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
  if l-filter-open-50 = false then do:
    OPEN QUERY BROWSE-AM FOR EACH buf_Matrix
      where  buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type  and buf_Matrix.db-num-obj = v-db-num
       USE-INDEX  asmt-name
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_matrix )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-AM:handle:get-buffer-handle(1) = (buffer buf_Matrix:handle) then do:
      assign
      parameter-2-50 = (if p-find-next then "true":u else "false":u )
      parameter-4-50 =
        "where ":u +  substitute(' buf_matrix.asmt-status = &2 and true and buf_matrix.asmt-type = &1&3&1 and buf_Matrix.db-num-obj = &4 ' , chr(34) , p-sts , v-type  , v-db-num)  + " ":u + where-phrase-50 + " ":u + p-find-condition + " " + ""
      parameter-5-50 = " USE-INDEX  asmt-name "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input rowid(buf_matrix)
                          ,input logical(parameter-2-50)
                          ,input no-lock
                          ,input (buffer buf_matrix:handle)
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-50 = (if p-find-next then "true":u else "false":u )
      parameter-3-50 =  "FOR EACH buf_Matrix"
      parameter-4-50 =
        (
          if (" buf_Matrix.asmt-status = p-sts and TRUE and buf_Matrix.asmt-type = v-type  and buf_Matrix.db-num-obj = v-db-num" + " " + where-phrase-50) <> ""
          then  substitute(' buf_matrix.asmt-status = &2 and true and buf_matrix.asmt-type = &1&3&1 and buf_Matrix.db-num-obj = &4 ' , chr(34) , p-sts , v-type  , v-db-num)  + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-50 = if sort-phrase-50 = ''
                           then
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX  asmt-name " +
          " " + sort-column-phrase +
        " " + sort-phrase-50
        )
      parameter-7-50 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-AM:handle
                          ,input logical(parameter-2-50)
                          ,input no-lock
                          ,input parameter-3-50
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ,input parameter-6-50
                          ,input parameter-7-50
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
            end.
        end.
    end.
END.
APPLY "VALUE-CHANGED" TO BROWSE-AM in frame Dialog-Frame.
APPLY "ENTRY" TO BROWSE-AM.
END PROCEDURE.
PROCEDURE proc-b-del :
define variable loc#log as logical no-undo.
define variable v-sts like ub.assortment-matrix.asmt-status no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
if not available buf_Matrix then return error.
do
on error undo, return error
on stop undo, return error
:
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr_deletion':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
  if loc#log <> yes then do: return error. end.
  assign
  v-sts = ?
  loc-doc-rec = RECID(buf_Matrix)
  .
  run ref/assmatr2.p (
       input recid ( buf_Matrix )
      ,input-output v-sts )
       no-error .
  if error-status:error then undo, return error.
  run openbr in this-procedure .
  REPOSITION BROWSE-AM to recid loc-doc-rec No-error.
  if error-status:error then do:                           find first pos_assortment-matrix no-lock where                                   recid(pos_assortment-matrix) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи AM" skip                            string(if avail pos_assortment-matrix                                     then  substitute("Вн код AM: &1"                                                     , pos_assortment-matrix.asmt-id)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
  if available buf_Matrix then do:
    loc#log = BROWSE-AM:select-focused-row( ) IN FRAME Dialog-Frame.
  end.
  apply "ENTRY" to BROWSE-AM.
end.
END PROCEDURE.
PROCEDURE proc-b-print :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
define variable v-time-cr as character no-undo .
define variable v-time-up as character no-undo .
define variable v-st      as character no-undo .
DEFINE FRAME buf_Matrix-list
      buf_Matrix.asmt-name COLUMN-LABEL "Название" FORMAT "X(30)":U
      buf_Matrix.asmt-type COLUMN-LABEL "Тип" FORMAT "X(6)":U
      buf_Matrix.obj-type  COLUMN-LABEL "Объект"
      buf_Matrix.obj-code
      buf_Matrix.asmt-date-update COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      v-time-up COLUMN-LABEL "Время" FORMAT "x(5)":U
      buf_Matrix.asmt-who-update COLUMN-LABEL "Кто!изменил" FORMAT "X(8)":U
      buf_Matrix.asmt-db-num-update COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      buf_Matrix.asmt-date-create COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      v-time-cr  COLUMN-LABEL "Время" FORMAT "x(5)":U
      buf_Matrix.asmt-who-create COLUMN-LABEL "Кто!создал" FORMAT "X(8)":U
      buf_Matrix.asmt-db-num-create COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
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
FORM with FRAME buf_Matrix-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(buf_Matrix).
DO WHILE available buf_Matrix :
  GET prev BROWSE-AM.
END.
GET next BROWSE-AM.
DO WHILE available buf_Matrix :
  Display STREAM PrnLibStream
      buf_Matrix.asmt-name
      buf_Matrix.asmt-type
      buf_Matrix.obj-type
      buf_Matrix.obj-code
      buf_Matrix.asmt-date-update
      STRING (buf_Matrix.asmt-time-update,"HH:MM") @ v-time-up
      buf_Matrix.asmt-who-update
      buf_Matrix.asmt-db-num-update
      buf_Matrix.asmt-date-create
      STRING (buf_Matrix.asmt-time-create,"HH:MM") @ v-time-cr
      buf_Matrix.asmt-who-create
      buf_Matrix.asmt-db-num-create
with FRAME buf_Matrix-list .
  DOWN STREAM PrnLibStream 1
  with FRAME buf_Matrix-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next BROWSE-AM.
END.
UNDERLINE  STREAM PrnLibStream
      buf_Matrix.asmt-name
      buf_Matrix.asmt-type
      buf_Matrix.obj-type
      buf_Matrix.obj-code
      buf_Matrix.asmt-date-update
      buf_Matrix.asmt-who-update
      buf_Matrix.asmt-db-num-update
      buf_Matrix.asmt-date-create
      buf_Matrix.asmt-who-create
      buf_Matrix.asmt-db-num-create
      v-time-cr
      v-time-up
with FRAME buf_Matrix-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ buf_Matrix.asmt-name
accum-count @ buf_Matrix.asmt-type
with frame buf_Matrix-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME buf_Matrix-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION BROWSE-AM to recid v-doc-rec no-error.
APPLY "entry" to BROWSE-AM.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
PROCEDURE proc-br :
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION attrRootShablon RETURNS CHARACTER
  ( p-recid as recid ) :
define buffer bufs_matrix for ub.assortment-matrix.
define variable v-type as character no-undo .
define variable v-value as character no-undo .
find first bufs_matrix no-lock  where recid(bufs_matrix) = p-recid no-error .
if error-status :error then return "" .
if bufs_matrix.asmt-type = 'Шаблон':U  then
   return substitute("&1&3&2" ,bufs_matrix.asmt-id ,bufs_matrix.db-num, chr(1)  ) .
else do:
  run assmatat-value (
       input bufs_matrix.asmt-id
      ,input bufs_matrix.db-num
      ,input 'RootShablon':U
      ,output v-value
      ,output v-type
      ) .
   return  v-value .
 end.
END FUNCTION.
FUNCTION f-name-link RETURNS CHARACTER
  ( p-recid as recid ) :
define buffer bufs_matrix for ub.assortment-matrix.
define buffer bufr_assortment-matrix for ub.assortment-matrix.
define variable v-type as character no-undo .
define variable v-value as character no-undo .
find first bufs_matrix no-lock  where recid(bufs_matrix) = p-recid no-error .
if error-status :error then return "" .
if bufs_matrix.asmt-type = 'Шаблон':U  then
   return "".
else do:
  run assmatat-value (
       input bufs_matrix.asmt-id
      ,input bufs_matrix.db-num
      ,input 'RootShablon':U
      ,output v-value
      ,output v-type
      ) .
     find first bufr_assortment-matrix no-lock where
                bufr_assortment-matrix.asmt-id = int(entry(1,v-value,chr(4))) and
                bufr_assortment-matrix.db-num  = int(entry(2,v-value,chr(4))) no-error .
    if not available bufr_assortment-matrix then do:
       return  "" .
    end.
    else do:
      return  bufr_assortment-matrix.asmt-name.
    end.
 end.
END FUNCTION.
FUNCTION shablon-type RETURNS CHARACTER
  ( p-recid as recid ) :
define buffer bufs_matrix for ub.assortment-matrix.
define buffer obj_assortment-matrix for ub.assortment-matrix  .
define variable v-type as character no-undo .
define variable v-value as character no-undo .
find first bufs_matrix no-lock  where recid(bufs_matrix) = p-recid no-error .
if error-status :error then return "" .
if bufs_matrix.asmt-type <> 'Шаблон':U  then do:
   return "".
end.
else do:
   for each obj_assortment-matrix no-lock where
            obj_assortment-matrix.asmt-status = 0 and
            obj_assortment-matrix.asmt-type   =   'Объект':U ,
      first ub.assortment-matrix-attr no-lock where
            ub.assortment-matrix-attr.asmt-id    = obj_assortment-matrix.asmt-id and
            ub.assortment-matrix-attr.db-num     = obj_assortment-matrix.db-num  and
            ub.assortment-matrix-attr.attr-code  = 'RootShablon':U and
            ub.assortment-matrix-attr.attr-value = substitute("&1&3&2" , bufs_matrix.asmt-id,bufs_matrix.db-num,chr(4))
            :
            return chr(135) .
   end.
end.
RETURN "".
END FUNCTION.
