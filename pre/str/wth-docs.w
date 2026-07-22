DEFINE NEW SHARED BUFFER X_wth-doc FOR ub.wth-doc.
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
define input parameter par-mode as character no-undo .
define input parameter parhost-code  like ub.sysconf.host-code no-undo.
define input parameter parobj-type   like ub.clients.obj-type no-undo.
define input parameter parobj-code   like ub.clients.obj-code no-undo.
define input parameter parcli-type   like ub.clients.obj-type no-undo.
define input parameter parcli-code   like ub.clients.obj-code no-undo.
define input parameter parext-type   like ub.wth-doc.ext-doc-type no-undo.
define input parameter parstatus     like ub.wth-doc.status_ no-undo.
define input parameter par-type      like ub.wth-doc.doc-type no-undo.
define input-output param p-rid-list    as  char no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Документы движения материальных ценностей":U.
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
function shift-name-no-err return char (
                                        buffer loc-wth-doc for ub.wth-doc
 ).
define variable varshift-name as character no-undo.
define variable varshift-name-num as character no-undo.
  varshift-name = loc-wth-doc.shift-name.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnme in g#lib-trn3 ( input  loc-wth-doc.obj-type,
                       input  loc-wth-doc.obj-code,
                       input  loc-wth-doc.shift-date,
                       input  loc-wth-doc.shift-num,
                       input-output varshift-name,
                       output varshift-name-num
                       ) no-error .
  if error-status:error then do:
    return "":u.
  end.
  return varshift-name-num.
end function.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
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
define temp-table tt-upd-attr no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define temp-table tt-upd-attr-fuel no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
procedure wthcattr-sprcli :
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-mode  as character no-undo.
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  DEFINE VARIABLE v-value as character no-undo .
  define variable v-cli-type as character no-undo .
  define variable v-cli-code as integer no-undo .
  define buffer buf_clients   for ub.clients.
  define variable v_rid as character no-undo.
  define variable ref-rec as recid no-undo .
  do
  on error undo, return error
  :
      v-value = p-value.
   if p-value <> '':U then do:
    assign
    v-cli-type = substring(p-value, 1, 3)
    v-cli-code = integer(substring(p-value, 4))
    no-error.
    if error-status:error then do:
      assign
      v-cli-type = '':U
      v-cli-code = 0
      .
    end.
   end.
   FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = v-cli-type AND
            buf_clients.obj-code = v-cli-code  NO-ERROR.
   IF available(buf_clients) then do:
    run ref/cli-all.w (
                input parparentproc
               ,input if p-mode = 'ИЗМЕНЕНИЕ':U then "b-sel":U else "":U
               ,input v-cli-type
               ,input 'все':U
               ,input 'все':U
               ,input RECID( buf_clients )
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  ELSE if p-mode = 'ИЗМЕНЕНИЕ':U then DO:
    run ref/cli-all.w (
                 input parparentproc
                ,INPUT "b-sel":U
               ,input  v-cli-type
               ,input 'все':U
               ,input 'текущие':U
               ,input ?
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  else do:
    message
    if p-value = "":U then 'Атрибут не задан!'
    else substitute('Не найден клиент &1',p-value)
    view-as alert-box warning.
  end.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_clients NO-LOCK WHERE
               RECID( buf_clients ) = ref-rec NO-ERROR.
    IF AVAIL buf_clients THEN DO:
      v-value = buf_clients.obj-type + string(buf_clients.obj-code, ">>>>>>>>9").
    end.
  end.
  if v-value <> p-value then do:
    p-value = v-value.
    p-setted = yes.
  end.
  end.
end procedure.
  define new global shared variable g#wthcalib as handle no-undo.
define variable filter-label0 as character no-undo init "Движение матценностей" .
define variable filter-label as character no-undo init "Движение матценностей" .
define variable filter-point as character no-undo init "wth-docs" .
define variable filter-point0 as character no-undo init "wth-docs" .
define variable sort-column-name as character no-undo .
define variable v-rid-list as character no-undo .
define variable vcli-name like ub.clients.obj-name no-undo.
define variable vhost-name like ub.clients.obj-name no-undo.
define variable print-option as character no-undo.
define variable add-option as character no-undo.
define variable glog as logical no-undo .
define variable v-r-b-abbr like ub.currency.curr-abbr no-undo .
define variable v-doc-rec as recid no-undo .
define variable parext-doc-name as character no-undo.
define buffer buf_cli for ub.clients.
define buffer buf_obj for ub.clients .
define new shared buffer wth-doc for ub.wth-doc.
DEFINE MENU MENU-B-print
       MENU-ITEM m_one          LABEL "Документ"
       MENU-ITEM m_list         LABEL "Список"        .
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-attr
     LABEL "Атрибуты"
     SIZE 10 BY 1.
DEFINE BUTTON b-auto
     LABEL "По чекам"
     SIZE 10 BY 1 TOOLTIP "Добавить документ по чекам МЦ".
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-close
     LABEL "&Закрыть"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-open
     LABEL "&Открыть"
     SIZE 10 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 8 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(14)":U
     LABEL "номеру"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999":U
     LABEL "дате"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-fact AS DATE FORMAT "99/99/9999":U
     LABEL "дате факт"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE v_creid AS CHARACTER FORMAT "X(256)":U
     LABEL "Опер"
      VIEW-AS TEXT
     SIZE 14 BY .71
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v_deliver AS CHARACTER FORMAT "X(256)":U
     LABEL "Передал"
      VIEW-AS TEXT
     SIZE 14 BY .71
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v_operator AS CHARACTER FORMAT "X(256)":U
     LABEL "Исп"
      VIEW-AS TEXT
     SIZE 14 BY .71
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v_receiver AS CHARACTER FORMAT "X(256)":U
     LABEL "Получил"
      VIEW-AS TEXT
     SIZE 14 BY .79
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-auto AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"По чекам", 2,
"Созд. вручную", 3
     SIZE 40.5 BY 1 NO-UNDO.
DEFINE NEW SHARED QUERY BR-docs FOR
                X_wth-doc SCROLLING.
DEFINE BROWSE BR-docs
  QUERY BR-docs NO-LOCK DISPLAY
      mark-string( recid(X_wth-doc), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
X_wth-doc.doc-type COLUMN-LABEL "Т" FORMAT "X(1)":U
X_wth-doc.status_  COLUMN-LABEL "Стат" FORMAT "X(4)":U
X_wth-doc.doc-code  FORMAT "X(12)":U  COLUMN-LABEL "№ документа"
X_wth-doc.fact-date FORMAT "99/99/99":U
X_wth-doc.doc-date  FORMAT "99/99/99":U
shift-name-no-err(buffer X_wth-doc) COLUMN-LABEL "№" FORMAT "X(3)":U
(substring ((string (X_wth-doc.shift-date)), 1, 5)) COLUMN-LABEL "Смена" FORMAT "X(5)":U
X_wth-doc.inter_ COLUMN-LABEL "В" FORMAT "+/":U
X_wth-doc.exter_ COLUMN-LABEL "Ш" FORMAT "+/":U
X_wth-doc.auto-fill COLUMN-LABEL "А" FORMAT "+/":U
X_wth-doc.cli-name FORMAT "X(20)":U
X_wth-doc.fact-sum FORMAT "->>,>>>,>>9.99":U COLUMN-LABEL "Кол-во "WIDTH 11
X_wth-doc.sum-gds-rubl COLUMN-LABEL "Сумма (тов)" FORMAT "->>>,>>>,>>9.99":U WIDTH 12
X_wth-doc.doc-sum  COLUMN-LABEL "Кол-во(док)" FORMAT "->>,>>>,>>9.99":U
X_wth-doc.sum-gds-base FORMAT "->>>,>>>,>>9.99":U COLUMN-LABEL "Сумма по тов. (баз. вал.)"
(trim (X_wth-doc.obj-type) + " " + string (X_wth-doc.obj-code, ">>>>9")) COLUMN-LABEL "Объект" FORMAT "X(9)":U
X_wth-doc.source-type + chr(32) + X_wth-doc.source-ref COLUMN-LABEL "На документ" FORMAT "X(20)":U
X_wth-doc.bge-date COLUMN-LABEL "Внеш.пров." FORMAT "99/99/99":U
ENABLE
X_wth-doc.bge-date
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 14.25.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1.13
     B-mark AT ROW 1 COL 9
     B-sel AT ROW 1 COL 16
     B-add AT ROW 1 COL 26
     b-lkp AT ROW 1 COL 36
     B-chg AT ROW 1 COL 46
     B-del AT ROW 1 COL 56
     B-close AT ROW 1 COL 66
     B-open AT ROW 1 COL 76
     B-sch AT ROW 1 COL 86
     B-print AT ROW 1 COL 89
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     b-auto AT ROW 2 COL 26 WIDGET-ID 2
     b-attr AT ROW 2 COL 36 WIDGET-ID 10
     rs-auto AT ROW 3.25 COL 1 NO-LABEL WIDGET-ID 4
     BR-docs AT ROW 4.25 COL 1.13
     ED-notes AT ROW 19.75 COL 1 NO-LABEL
     sch-code AT ROW 22 COL 19 COLON-ALIGNED
     sch-date AT ROW 22 COL 46 COLON-ALIGNED
     sch-fact AT ROW 22 COL 77.5 COLON-ALIGNED
     mark-num AT ROW 1 COL 10 COLON-ALIGNED NO-LABEL
     v_operator AT ROW 18.75 COL 5 COLON-ALIGNED
     v_deliver AT ROW 18.75 COL 30 COLON-ALIGNED
     v_receiver AT ROW 18.75 COL 55 COLON-ALIGNED
     v_creid AT ROW 18.75 COL 80 COLON-ALIGNED
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.25 BY 1 AT ROW 22 COL 1.5
          FGCOLOR 4
     SPACE(88.54) SKIP(0.19)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Движение материальных ценностей"
         DEFAULT-BUTTON b-lkp.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
define variable v-doc-rec as recid no-undo .
define variable next-prev as character no-undo .
  if lookup(parext-type,"ip,rp,rj,pc,ff,rf,fj,pj,ii,rj,ci,ce,de") > 0 or parext-type = '':U then do:
    message 'Добавить документ в данном режиме невозможно' view-as alert-box.
    return no-apply.
  end.
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wth-doc_add-def':U
    ,input  'object':U
    ,input  parhost-code
    ,input  parobj-type
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  IF glog <> YES THEN DO:
    add-option = "":U.
    RETURN NO-APPLY.
  END.
  ASSIGN
  v-doc-rec = RECID( X_wth-doc )
  .
    CASE par-type :
    WHEN 'при':U OR
    WHEN 'рас':U OR
    WHEN 'спи':U OR
    WHEN 'обмен':U OR
    when 'декл':U thEN DO:
        run str/wth-inc.w (
                         INPUT parparentproc
                        ,INPUT 'ДОБАВЛЕНИЕ':U
                        ,INPUT parhost-code
                        ,INPUT parobj-type
                        ,INPUT parobj-code
                        ,INPUT parcli-type
                        ,INPUT parcli-code
                        ,INPUT parext-type
                        ,INPUT par-type
                        ,INPUT (add-option = "auto":U )
                        ,INPUT-OUTPUT v-doc-rec
                        ,input ?
                        ,input-output next-prev
                        ).
    END.
    WHEN 'инв':U THEN DO:
        run str/wth-inv.w (
                        INPUT parparentproc
                        ,INPUT 'ДОБАВЛЕНИЕ':U
                        ,INPUT parhost-code
                        ,INPUT parobj-type
                        ,INPUT parobj-code
                        ,INPUT parcli-type
                        ,INPUT parcli-code
                        ,INPUT parext-type
                        ,INPUT (add-option = "auto":U )
                        ,INPUT-OUTPUT v-doc-rec
                        ,input ?
                        ,input-output next-prev
                      ).
    END.
  END CASE.
  add-option = "":U.
  if v-doc-rec <> ? then do:
    RUN OpenBr in this-procedure ( input yes
                                 , input no
                                 , input '':U).
    reposition br-docs to recid v-doc-rec no-error.
  end.
  APPLY "Value-CHanged" to br-docs.
  APPLY "ENTRY" to br-docs.
END.
ON CHOOSE OF b-attr IN FRAME Dialog-Frame
DO:
  if not avail X_wth-doc then return no-apply.
  run init-attr-general in this-procedure no-error .
  if error-status:error then do:
    message return-value skip
    error-status:get-message(1)
    view-as alert-box.
  end.
  IF not (lookup('b-add':U, bttns) > 0 and (par-mode = 'ext-doc-type':U) and ub.sys-ctrl.db-num = buf_obj.db-num  ) THEN DO:
    run str/wthdattr.w (input parparentproc,
                        input "b-lkp",
                        input X_wth-doc.doc-code,
                        input table tt-upd-attr) no-error.
  END.
  else if X_wth-doc.STATUS_ = 'факт':U then do:
     run str/wthdattr.w (input parparentproc,
                         input "b-lkp,b-chg,b-add,b-del",
                         input X_wth-doc.doc-code,
                         input table tt-upd-attr) no-error.
  end.
  else do:
     run str/wthdattr.w (input parparentproc,
                         input "b-lkp,b-chg,b-add,b-del,no-news",
                         input X_wth-doc.doc-code,
                         input table tt-upd-attr) no-error.
  end.
  if error-status:error then do:
    message return-value skip
    error-status:get-message(1)
    view-as alert-box.
  end.
END.
ON CHOOSE OF b-auto IN FRAME Dialog-Frame
DO:
  assign
  add-option = 'auto':U.
  APPLY "CHOOSE" to b-add in frame Dialog-Frame.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
define variable v-doc-rec as recid no-undo .
define variable next-prev as character no-undo .
 define buffer check_wth-doc for ub.wth-doc .
   if not avail X_wth-doc then return no-apply.
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wth-doc_update':U
    ,input  'object':U
    ,input  parhost-code
    ,input  parobj-type
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  IF glog <> YES THEN DO:
    RETURN NO-APPLY.
  END.
  do on stop undo, return no-apply:
    FIND FIRST check_wth-doc where
              recid(check_wth-doc) = RECID(X_wth-doc) No-ERROR.
    if not avail check_WTH-DOC THEN DO:
        RETURN NO-APPLY.
    END.
    IF CHECK_WTH-DOC.STATUS_ = 'факт':U THEN Do:
        message "Документ движения МЦ с N " check_wth-doc.doc-code  " имеет статус " check_wth-doc.status_ SKIP
                "Изменения не допускаются"
        view-as alert-box error.
        return no-apply.
    end.
    if  check_wth-doc.doc-type = 'возврат':U then do:
        message  substitute("Изменение документов с типом &1 не допускается!",'возврат':U)
        view-as alert-box error.
        return no-apply.
    end.
    if  parobj-type <> check_wth-doc.obj-type
    or parobj-code <> check_wth-doc.obj-code then do:
            message  "Документ может быть изменен только на активной стороне!"
                view-as alert-box ERROR.
                return no-apply.
    end.
    ASSIGN
    v-doc-rec = RECID( X_wth-doc )
    .
    CASE X_wth-doc.doc-type :
      WHEN 'при':U OR
      WHEN 'рас':U OR
      when 'возврат':U  OR
      WHEN 'обмен':U OR
      WHEN 'спи':U THEN DO:
          run str/wth-inc.w (
                          INPUT parparentproc
                          ,INPUT 'ИЗМЕНЕНИЕ':U
                          ,INPUT parhost-code
                          ,INPUT parobj-type
                          ,INPUT parobj-code
                          ,INPUT X_wth-doc.cli-type
                          ,INPUT X_wth-doc.cli-code
                          ,INPUT X_wth-doc.ext-doc-type
                          ,INPUT X_wth-doc.doc-type
                          ,INPUT X_wth-doc.auto-fill
                          ,INPUT-OUTPUT v-doc-rec
                          ,input ?
                          ,INPUT-OUTPUT next-prev
                            ) no-error .
      END.
      WHEN 'инв':U THEN DO:
                run str/wth-inv.w (
                          INPUT parparentproc
                          ,INPUT 'ИЗМЕНЕНИЕ':U
                          ,INPUT parhost-code
                          ,INPUT parobj-type
                          ,INPUT parobj-code
                          ,INPUT X_wth-doc.cli-type
                          ,INPUT X_wth-doc.cli-code
                          ,INPUT X_wth-doc.ext-doc-type
                          ,INPUT X_wth-doc.auto-fill
                          ,INPUT-OUTPUT v-doc-rec
                          ,input ?
                          ,INPUT-OUTPUT next-prev
                        ) no-error .
                        if error-status:error then message return-value.
      END.
    END CASE.
  end.
  ASSIGN glog = br-docs:REFRESH( ).
  reposition br-docs to recid v-doc-rec No-ERROR.
  APPLY "Value-CHanged" to br-docs.
  APPLY "ENTRY" to br-docs.
END.
ON CHOOSE OF B-close IN FRAME Dialog-Frame
DO:
  if not avail X_wth-doc then return no-apply.
  run proc-b-close in this-procedure  ( input self:name) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  define variable glog as logical no-undo .
  define variable v-chip-num as integer no-undo .
  define buffer buf_wth-doc for ub.wth-doc.
  define buffer buf_out_wth-doc for ub.wth-doc.
  define variable v-user-action    as character no-undo.
  define variable v-printed        as logical   no-undo.
  define variable v-proc-name-err    as character    no-undo.
  define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
  find first buf_wth-doc exclusive-lock where
  recid(buf_wth-doc) = recid(X_wth-doc) NO-ERROR.
  if not avail buf_wth-doc then return no-apply.
  IF buf_wth-doc.status_ <> 'факт':U
    and buf_wth-doc.status_ <> 'накл':U THEN DO:
     message
     substitute("Документы перемещения МЦ можно удалять только в статусах &1 и &2"
                , 'накл':U
                , 'факт':U)
    view-as alert-box error .
    return no-apply.
  end.
  if not (buf_wth-doc.obj-type = parobj-type and
          buf_wth-doc.obj-code = parobj-code)  then do:
      message "Документ можно удалять только на объекте создания!"
      view-as alert-box error.
      return no-apply.
  end.
v-proc-name-err = string(session:TEMP-DIRECTORY) + '/delWdoc.err':U .
if search (v-proc-name-err) <> ? then do:
  os-delete value(v-proc-name-err).
end.
  IF buf_wth-doc.status_ = 'факт':U
  THEN DO:
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wth-doc_del-fact':U
    ,input  'object':U
    ,input  parhost-code
    ,input  parobj-type
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    IF glog <> YES
    THEN DO:
      RETURN NO-APPLY.
    END.
    if buf_wth-doc.borned = yes then do:
       message
       substitute("Данный документ МЦ &1 порожден другим документом &2&3" +
                  "для удаления связки документов выберите для удаления документ МЦ &2"
                  , buf_wth-doc.doc-code
                  , buf_wth-doc.source-ref
                  , chr(10)
                  )
       view-as alert-box error .
       RETURN NO-APPLY.
    end.
    if buf_wth-doc.ext-doc-type = 'ci':U
    or buf_wth-doc.ext-doc-type = 'ce':U then do:
       message
       substitute("Документы МЦ с типом &1 и типом &2 удаляются при удалении создавшего их отчета о продаже"
                  ,'возврат покупателю через кассы':U
                  ,'приход внешний через кассы':U )
       view-as alert-box error .
       RETURN NO-APPLY.
    end.
    MESSAGE
    "Документ перемещения МЦ закрыт на факт" skip
    "Вы действительно хотите его удалить?"
    VIEW-AS ALERT-BOX QUESTION buttons YES-NO update glog.
    if not glog then    RETURN NO-APPLY.
       run waitfram-show in this-procedure ( input "Ждите..." ).
       run trg/wthdocdl.p ( input buf_wth-doc.doc-code
                          ,input  ?
                          ,input v-proc-name-err
                          ,output v-chip-num) no-error.
       if error-status:error then do:
        run waitfram-hide in this-procedure .
        message vss-workfile vss-revision vss-description skip
        "Ошибка удаления документа МЦ" skip
        error-status:get-message(1) skip
        return-value skip
        view-as alert-box error title 'Ошибка удаления'.
        if search (v-proc-name-err) <> ? then do:
         run gbl/prnfilen.w
           (input  "Ошибки при закрытии документа"
           ,input  0
           ,input  v-proc-name-err
           ,input  7
           ,output v-user-action
           ,output v-printed
           ).
        end.
        return no-apply.
       end.
  END.
  else if buf_wth-doc.status_ = 'накл':U
  then do:
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wth-doc_deletion':U
    ,input  'object':U
    ,input  parhost-code
    ,input  parobj-type
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    IF glog <> YES
    THEN DO:
      RETURN NO-APPLY.
    END.
    MESSAGE "Вы уверены, что хотите удалить документ?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
    IF glog <> YES THEN DO:
      RETURN NO-APPLY.
    END.
    if buf_wth-doc.borned = yes then do:
       message
       substitute("Данный документ МЦ &1 порожден другим документом &2&3" +
                  "для удаления связки документов выберите для удаления документ МЦ &2"
                  , buf_wth-doc.doc-code
                  , buf_wth-doc.source-ref
                  , chr(10)
                  )
       view-as alert-box error .
       RETURN NO-APPLY.
    end.
    for each ub.chk-doc EXCLUSIVE-LOCK WHERE
            ub.chk-doc.out-code = buf_wth-doc.doc-code
            and  lookup(string(ub.chk-doc.chk-type),'2,3,4,5,7':U )  > 0
    ON ERROR UNDO, return no-apply
    ON STOP UNDO, return no-apply
            :
      FOR each ub.chk-pay exclusive-lock where
            ub.chk-pay.doc-code = ub.chk-doc.doc-code:
        ub.chk-pay.out-code = ?.
      END.
      ub.chk-doc.out-code = ?.
    END.
    for each buf_inkas-pay-wth exclusive-lock where
            buf_inkas-pay-wth.inkas-code = buf_wth-doc.doc-code
    ON ERROR UNDO, return no-apply
    ON STOP UNDO, return no-apply
    :
       delete buf_inkas-pay-wth.
    end.
    DELETE buf_wth-doc no-error.
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      message return-value skip error-status:get-message(1)
      view-as alert-box error.
      return no-apply.
    end.
  end.
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
  reposition br-docs to row 1 No-ERROR.
  APPLY "Value-CHanged" to br-docs.
  APPLY "ENTRY" to br-docs.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
  if not available X_wth-doc then return no-apply.
    run str/wthcdocs.w
      (
       input  parparentproc
      ,input  'b-add'
      ,input  'one':U
      ,input  X_wth-doc.host-code
      ,input  X_wth-doc.obj-type
      ,input  X_wth-doc.obj-code
      ,input  '':U
      ,input  0
      ,input '':U
      ,input  X_wth-doc.doc-code
      ,output v-rid-list
      ).
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
define variable v-doc-rec as recid no-undo .
define variable next-prev as character no-undo .
  IF NOT AVAIL X_wth-doc THEN RETURN NO-apply.
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wth-doc_lookup':U
    ,input  'object':U
    ,input  parhost-code
    ,input  parobj-type
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  IF glog <> YES
  THEN DO:
    RETURN NO-APPLY.
  END.
  ASSIGN
  v-doc-rec = recid(X_wth-doc)
  next-prev = '':U
  .
  DO WHILE next-prev = "":U:
      if NOT available X_wth-doc then do:
        message "Неправильно выбран документ МЦ." view-as alert-box ERROR.
        return no-apply.
      end.
    CASE X_wth-doc.doc-type :
      WHEN 'инв':U THEN DO:
          run str/wth-inv.w (  INPUT parparentproc
                          ,INPUT 'ПРОСМОТР':U
                          ,INPUT X_wth-doc.host-code
                          ,INPUT X_wth-doc.obj-type
                          ,INPUT X_wth-doc.obj-code
                          ,INPUT X_wth-doc.cli-type
                          ,INPUT X_wth-doc.cli-code
                          ,INPUT X_wth-doc.ext-doc-type
                          ,INPUT X_wth-doc.auto-fill
                          ,INPUT-OUTPUT v-doc-rec
                          ,input this-procedure:handle
                          ,input-output next-prev
                          ).
      END.
      otherwise do:
                run str/wth-inc.w (
                           INPUT parparentproc
                          ,INPUT 'ПРОСМОТР':U
                          ,INPUT X_wth-doc.host-code
                          ,INPUT X_wth-doc.obj-type
                          ,INPUT X_wth-doc.obj-code
                          ,INPUT X_wth-doc.cli-type
                          ,INPUT X_wth-doc.cli-code
                          ,INPUT X_wth-doc.ext-doc-type
                          ,INPUT X_wth-doc.doc-type
                          ,INPUT X_wth-doc.auto-fill
                          ,INPUT-OUTPUT v-doc-rec
                          ,input this-procedure:handle
                          ,input-output next-prev
                          ).
      end.
    END CASE.
 END.
 RUN OpenBr in this-procedure ( input yes, input no, input '':U).
 reposition br-docs to recid v-doc-rec no-error.
 APPLY "ENTRY":U  TO br-docs IN FRAME Dialog-Frame.
 APPLY "VALUE-CHANGED":U TO br-docs IN FRAME Dialog-Frame.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  if available X_wth-doc then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid20 as character no-undo .
define variable v-num-entry20 as integer   no-undo .
assign
  v-str-recid20 = trim( string( recid( X_wth-doc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry20 = lookup( v-str-recid20 , v-rid-list )
.
if v-num-entry20 > 0 then do:
  assign
    entry( v-num-entry20, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid20
  .
end.
    glog = br-docs:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-docs:select-next-row ().
        apply "iteration-changed" to br-docs in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF B-open IN FRAME Dialog-Frame
DO:
  if not avail X_wth-doc then return no-apply.
  run proc-b-close in this-procedure ( input self:name) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
    if not avail X_wth-doc then
    return no-apply.
    if print-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
    end.
    if print-option = '':U then return no-apply.
    run proc-b-print in this-procedure (
          input X_wth-doc.doc-code
        , input print-option
    ) no-error.
    if error-status:error then do:
        print-option = '':U.
        return no-apply.
    end.
    APPLY "ENTRY" to br-docs.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
run proc-b-sch in this-procedure no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
      if ( available X_wth-doc ) AND ( v-rid-list = ""  or
        b-mark:sensitive = no ) then
    v-rid-list = string( recid( X_wth-doc ) ) .
END.
ON ANY-PRINTABLE OF BR-docs IN FRAME Dialog-Frame
DO:
   sch-code:screen-value = sch-code:screen-value + last-event:label.
    apply "entry" to sch-code in frame Dialog-Frame.
apply "end" to sch-code in frame Dialog-Frame.
END.
ON DELETE-CHARACTER OF BR-docs IN FRAME Dialog-Frame
DO:
   if b-mark:sensitive in frame Dialog-Frame then
  APPLY "CHOOSE" to b-mark.
END.
ON INSERT-MODE OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame Dialog-Frame then
  APPLY "CHOOSE" to b-mark.
    else do:
      if b-sel:sensitive in frame Dialog-Frame then
      APPLY "CHOOSE" to b-sel.
    end.
END.
ON RETURN OF BR-docs IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-docs IN FRAME Dialog-Frame DO:
  apply "choose" to b-lkp in frame Dialog-Frame.
    return no-apply.
END.
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
    define buffer buf-oper for ub.clients.
    define buffer buf-deliver for ub.clients.
    define buffer buf-receiver for ub.clients.
      if available X_wth-doc then do:
        FIND buf-oper NO-LOCK WHERE
                buf-oper.obj-type = 'чел':U AND
                buf-oper.obj-code = X_wth-doc.operator NO-ERROR.
        FIND buf-deliver NO-LOCK WHERE
                buf-deliver.obj-type = 'чел':U AND
                buf-deliver.obj-code = X_wth-doc.deliver NO-ERROR.
        FIND buf-receiver NO-LOCK WHERE
                buf-receiver.obj-type = 'чел':U AND
                buf-receiver.obj-code = X_wth-doc.receiver NO-ERROR.
        assign
        ed-notes = X_wth-doc.PS
        v_operator = ( IF AVAIL buf-oper THEN buf-oper.obj-name ELSE "":U ).
        v_deliver =  ( IF AVAIL buf-deliver THEN buf-deliver.obj-name ELSE "":U ).
        v_receiver = ( IF AVAIL buf-receiver THEN buf-receiver.obj-name ELSE "":U ).
        .
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  X_wth-doc.user-name
  ,output v_creid
  )  .
        if X_wth-doc.status_ = 'факт':U then do:
          disable
          b-open
          b-close
          b-chg
          with frame Dialog-Frame .
        end.
        else do:
          enable
          b-open  when (lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num)
          b-close when (lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num)
          b-chg when lookup('b-add':U, bttns) > 0 and ub.sys-ctrl.db-num = buf_obj.db-num  and parstatus <> 'факт':U and lookup(parext-type,"ci,ce,rj,pc,") = 0
          with frame Dialog-Frame .
        end.
        enable
        b-lkp
        b-attr when lookup('b-add':U, bttns) >0 and (par-mode = 'ext-doc-type':U) and ub.sys-ctrl.db-num = buf_obj.db-num and lookup(parext-type,"ip,rp,rj,pc,ff,rf,fj,pj,ii,rj,ci,ce,de") = 0
        B-del when lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num  and ( not par-mode = 'ext-doc-type':U or lookup(parext-type,"ip,rp,rj,pc,ff,rf,fj,pj,ii,rj,ci,ce,de") = 0)
        with frame Dialog-Frame .
    end.
    else do:
        assign
        ed-notes = '':U
        v_operator = '':U
        v_deliver = '':U
        v_receiver = '':U
        v_creid = '':U
        .
        disable
          b-open
          b-close
          b-chg
          b-del
          b-attr
          b-lkp
        with frame Dialog-Frame .
    end.
    display
    ed-notes
    v_creid
    v_deliver
    v_operator
    v_receiver
    with frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_list
DO:
 assign
  print-option = 'LIST':U.
  APPLY "CHOOSE" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_one
DO:
 assign
  print-option = 'ONE':U.
  APPLY "CHOOSE" to b-print  in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF rs-auto IN FRAME Dialog-Frame
DO:
      RUN OpenBr in this-procedure ( input yes
                                 , input no
                                 , input '':U).
END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure ( input yes, input frame Dialog-Frame sch-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure ( input no, input frame Dialog-Frame sch-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-date IN FRAME Dialog-Frame
DO:
   run proc-find-date in this-procedure ( input yes, input frame Dialog-Frame sch-date, "doc-date") no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-date IN FRAME Dialog-Frame
DO:
    run proc-find-date in this-procedure ( input no, input frame Dialog-Frame sch-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-fact IN FRAME Dialog-Frame
DO:
   run proc-find-date in this-procedure ( input yes, input frame Dialog-Frame sch-fact, "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-fact IN FRAME Dialog-Frame
DO:
  run proc-find-date in this-procedure ( input no, input frame Dialog-Frame sch-fact, "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-docs :handle
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
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
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
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-doc-rec = recid(X_wth-doc).  RUn OpenBR in this-procedure ( input yes, input no, input '':U).               REPOSITION br-docs to recid v-doc-rec No-ERROR.               APPLY 'ENTRY' to br-docs. APPLY 'VALUE-CHANGED' to br-docS.
    apply "VALUE-CHANGED" to BR-docs.
end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-docs :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  FIND FIRST ub.sys-ctrl NO-LOCK.
  if avail sys-ctrl then do:
    FIND FIRST ub.db no-LOCK where
              ub.db.db-num = ub.sys-ctrl.db-num NO-ERROR.
    if not avail db then do:
      message "Отсутствует запись о БД (db)"
      view-as alert-box ERROR.
      return error.
    end.
  END.
  FIND FIRST buf_obj No-LOCK WHERE
                  buf_obj.obj-type = parobj-type and
                  buf_obj.obj-code = parobj-code No-ERROR.
  if not avail buf_obj then do:
      message vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова parobj-type и/или parobj-code"
      parobj-type parobj-code
      view-as alert-box ERROR.
      return.
  end.
  CASE par-mode:
    WHEN 'все':U        THEN DO:
    END.
    WHEN 'фирма':U    THEN DO:
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = 'орг':U and
                        buf_cli.obj-code = parhost-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            view-as alert-box ERROR.
            return.
        end.
        FIND FIRST ub.sysconf No-LOCK WHERE
                          ub.sysconf.host-code = parhost-code No-ERROR.
        if not avail ub.sysconf then do:
            message vss-workfile vss-revision vss-description skip
            view-as alert-box ERROR.
            return.
        end.
        assign vhost-name = buf_cli.obj-name.
    END.
    WHEN 'объект':U then dO:
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = parobj-type and
                        buf_cli.obj-code = parobj-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            view-as alert-box ERROR.
            return.
        end.
    end.
    WHEN "doc-type":U    THEN DO:
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = 'орг':U and
                        buf_cli.obj-code = parhost-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметров вызова parobj-type и/или parobj-code"
            parobj-type parobj-code
            view-as alert-box ERROR.
            return.
        end.
        if NOT (par-type = 'при':U or par-type = 'рас':U or par-type = 'инв':U or par-type = 'спи':U) then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметра вызова par-type" par-type
            view-as alert-box ERROR.
            return.
        end.
    END.
    WHEN "ext-doc-type":U    THEN DO:
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = 'орг':U and
                        buf_cli.obj-code = parhost-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметров вызова parobj-type и/или parobj-code"
            parobj-type parobj-code
            view-as alert-box ERROR.
            return.
        end.
        if lookup(parext-type,'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u) = 0 then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметра вызова parext-type" parext-type
            view-as alert-box ERROR.
            return.
        end.
    END.
    WHEN 'Контрагент':U    THEN DO:
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = parobj-type and
                        buf_cli.obj-code = parobj-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметров вызова parobj-type и/или parobj-code"
            parobj-type parobj-code
            view-as alert-box ERROR.
            return.
        end.
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = parcli-type and
                        buf_cli.obj-code = parcli-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметров вызова parcli-type и/или parcli-code"
            parcli-type parcli-code
            view-as alert-box ERROR.
            return.
        end.
        assign vcli-name = buf_cli.obj-name.
    END.
    otherwise do:
      if not (par-mode = 'auto':U or par-mode = 'auto-nfact':U )  then do:
        message vss-workfile vss-revision vss-description skip
        "Неверный вызов - par-mode=" par-mode
        view-as alert-box ERROR.
        return.
      end.
    end.
  end CASE.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-abbr in g#library
  (input  buf_obj.host-code
  ,output v-r-b-abbr
  )  .
  v-rid-list = p-rid-list.
  if v-rid-list <> '':U then do:
    v-doc-rec = integer(entry(1, v-rid-list)).
  end.
  RUN MyEnable in this-procedure  .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-docs as INT EXTENT 18 no-undo.
DEF VAR varmvibr-docs       as INT no-undo.
DEF VAR varmvjbr-docs       as INT no-undo.
DEF VAR varmvkbr-docs       as INT no-undo.
DEF VAR varmvlbr-docs       as INT no-undo.
DEF VAR move-elementbr-docs as INT no-undo.
def var jjbr-docs           as int no-undo.
do varmvibr-docs = 1 to EXTENT(cur-clmn-numbr-docs):
  ASSIGN cur-clmn-numbr-docs[varmvibr-docs] = varmvibr-docs.
END.
RUN start-mv-clmnbr-docs.
PROCEDURE start-mv-clmnbr-docs:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  par-mode = 'все':U or par-mode = 'фирма':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18'))] , 1).
   END.
       END.
       IF  par-mode = 'объект':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17,18,13') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17,18,13'))] , 1).
   END.
       END.
       IF  par-mode = 'auto' or par-mode = 'auto-nfact'  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,11,12,13,14,15,16,17,18,10') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,4,5,6,7,8,9,11,12,13,14,15,16,17,18,10'))] , 1).
   END.
       END.
       IF  par-mode = 'doc-type':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,3,4,5,6,7,8,9,10,11,12,4,15,16,17,18,13,2') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,3,4,5,6,7,8,9,10,11,12,4,15,16,17,18,13,2'))] , 1).
   END.
       END.
       IF  par-mode = 'Контрагент':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10,11,14,15,16,17,18,13,12') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,4,5,6,7,8,9,10,11,14,15,16,17,18,13,12'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs ( 1, 18).
END.
ON ctrl-cursor-left OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (18, 1).
END.
PROCEDURE re-move-clmnbr-docs:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = source-column THEN cur-clmn-numbr-docs[varmvibr-docs] = -1.
  END.
  if br-docs:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-docs = source-column - 1 to target-column BY -1:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
        if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
          cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-docs = source-column + 1 to target-column:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
      if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
        cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] - 1.
      END.
    END.
  END.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = -1 THEN cur-clmn-numbr-docs[varmvibr-docs] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-docs:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-loc THEN move-elementbr-docs = varmvibr-docs.
  END.
  RUN re-move-clmnbr-docs (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-docs = 1 to EXTENT(cur-clmn-numbr-docs):
    RUN re-move-clmnbr-docs (cur-clmn-numbr-docs[varmvlbr-docs], varmvlbr-docs).
  END.
  RUN start-mv-clmnbr-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  HIDE mark-num in frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE cr-tt-upd-general :
do on error undo, return error return-value :
define variable v-other as character   no-undo.
for each tt-upd-attr : delete tt-upd-attr . end.
create tt-upd-attr.  assign  tt-upd-attr.code =  'wthreason':U  .
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-cod in g#wthcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output tt-upd-attr.other ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.    end.
if lookup(X_wth-doc.ext-doc-type, "ie,ee,pz") > 0
then do:
    create tt-upd-attr.  assign  tt-upd-attr.code =  'wthnsf':U  .
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-cod in g#wthcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output tt-upd-attr.other ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.    end.
    create tt-upd-attr.  assign  tt-upd-attr.code =  'wthdsf':U  .
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-cod in g#wthcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output tt-upd-attr.other ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.    end.
    create tt-upd-attr.  assign  tt-upd-attr.code =  'wthpaydoc':U  .
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-cod in g#wthcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output tt-upd-attr.other ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.    end.
    create tt-upd-attr.  assign  tt-upd-attr.code =  'wthconsignee':U  .
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-cod in g#wthcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output tt-upd-attr.other ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.    end.
end.
if lookup(X_wth-doc.ext-doc-type, "ie,ee,pz,xc") > 0
then do:
    create tt-upd-attr.  assign  tt-upd-attr.code =  'wthproxy':U  .
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-cod in g#wthcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output tt-upd-attr.other ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.    end.
    create tt-upd-attr.  assign  tt-upd-attr.code =  'wthreceiver':U  .
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-cod in g#wthcalib (  input tt-upd-attr.code ,
                       output tt-upd-attr.type-attr ,
                       output tt-upd-attr.format-attr ,
                       output tt-upd-attr.fillin_width ,
                       output tt-upd-attr.fillin_height ,
                       output tt-upd-attr.label-attr ,
                       output tt-upd-attr.user-can-edit ,
                       output tt-upd-attr.output-display ,
                       output tt-upd-attr.other ) no-error .
                                if error-status :error then do:       message "Ошибка при установке атрибутов документа." skip            error-status :get-message(1) skip return-value    view-as alert-box.    return error.    end.
end.
end.
END PROCEDURE.
PROCEDURE create-attr :
define  input parameter p-doc-code   like ub.wth-doc.doc-code    no-undo.
define  input parameter p-attr-code  like ub.wth-doc-attr.attr-code  no-undo.
define  input parameter p-attr-value like ub.wth-doc-attr.attr-value no-undo.
define output parameter p-exist      as   logical                no-undo.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-xst in g#wthcalib (  input p-doc-code ,
                        input p-attr-code ,
                       output p-exist )  .
  if p-exist = no then do:
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-wrt in g#wthcalib ( input p-doc-code ,
                       input p-attr-code ,
                       input p-attr-value ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message( 1 ) '"' + p-attr-code + '"'
      view-as alert-box error.
    end.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-auto ED-notes sch-code sch-date sch-fact mark-num v_operator
          v_deliver v_receiver v_creid
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add b-lkp B-chg B-del B-close B-open B-sch
         B-print B-hist B-Help rs-auto BR-docs ED-notes sch-code sch-date
         sch-fact mark-num v_operator v_deliver v_receiver v_creid
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-attr-general :
if available X_wth-doc
then
do on error undo, return error return-value :
run cr-tt-upd-general .
define variable varexist                  as logical   no-undo.
if lookup(X_wth-doc.ext-doc-type, "ie,ee,pz") > 0
then do:
      run create-attr in this-procedure (   input X_wth-doc.doc-code                                                         , input 'wthnsf':U                                                         , input  ""                                                         , output varexist ) no-error.
      run create-attr in this-procedure (   input X_wth-doc.doc-code                                                         , input 'wthdsf':U                                                         , input  ""                                                         , output varexist ) no-error.
      run create-attr in this-procedure (   input X_wth-doc.doc-code                                                         , input 'wthpaydoc':U                                                         , input  ""                                                         , output varexist ) no-error.
  if X_wth-doc.doc-type <> 'при':U then do:
        run create-attr in this-procedure (   input X_wth-doc.doc-code                                                         , input 'wthconsignee':U                                                         , input  ""                                                         , output varexist ) no-error.
  end.
end.
if lookup(X_wth-doc.ext-doc-type, "ie,ee,pz,xc") > 0
then do:
      run create-attr in this-procedure (   input X_wth-doc.doc-code                                                         , input 'wthproxy':U                                                         , input  ""                                                         , output varexist ) no-error.
      run create-attr in this-procedure (   input X_wth-doc.doc-code                                                         , input 'wthreceiver':U                                                         , input  ""                                                         , output varexist ) no-error.
END.
run create-attr in this-procedure (   input X_wth-doc.doc-code                                                         , input 'wthreason':U                                                         , input  ""                                                         , output varexist ) no-error.
end.
END PROCEDURE.
PROCEDURE Myenable :
ASSIGN
  br-docs:NUM-LOCKED-COLUMNS IN FRAME  Dialog-Frame  = 4
  X_wth-doc.bge-date:READ-ONLY IN BROWSE BR-docs = YES
  b-print:MENU-MOUSE = 1
.
if par-type = 'спи':U then
DISPLAY
ED-notes
sch-code
sch-date
sch-fact
mark-num
v_operator
v_deliver
v_receiver
v_creid
WITH FRAME Dialog-Frame.
ENABLE
b-quit
rs-auto
B-mark when lookup('b-mark':U, bttns) >0
B-sel  when lookup('b-sel':U, bttns) >0
B-add  when lookup('b-add':U, bttns) >0 and (par-mode = 'ext-doc-type':U) and ub.sys-ctrl.db-num = buf_obj.db-num and lookup(parext-type,"ip,rp,rj,pc,ff,rf,fj,pj,ii,rj,ci,ce,de") = 0
b-attr
b-auto when lookup('b-add':U, bttns) >0 and (par-mode = 'ext-doc-type':U) and ub.sys-ctrl.db-num = buf_obj.db-num and lookup(parext-type,'ii,fj,jj,pj,oj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,xc':U) = 0 and lookup(parext-type,"ip,rp,rj,pc,ff,rf,fj,pj,ii,rj,ci,ce,de") = 0
b-lkp
B-chg when lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num  and parstatus <> 'факт':U and lookup(parext-type,"ci,ce,rj,pc,") = 0
B-del when lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num  and ( not par-mode = 'ext-doc-type':U or lookup(parext-type,"ip,rp,rj,pc,ff,rf,fj,pj,ii,rj,ci,ce,de") = 0)
B-close when (lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num)
B-open  when (lookup('b-add':U, bttns) >0 and ub.sys-ctrl.db-num = buf_obj.db-num)
B-sch
B-print
B-hist
B-Help
BR-docs
ED-notes
sch-code
sch-date
sch-fact
mark-num
v_operator
v_deliver
v_receiver
v_creid
WITH FRAME Dialog-Frame.
if not ( (par-mode = 'ext-doc-type':U and lookup(parext-type,"ie,ee,ij,ej,iy,de") > 0) or
          par-mode = 'объект':U or
          par-mode = 'doc-type':U or
          par-mode = 'фирма':U or
          par-mode = 'все':U
       )
then disable rs-auto
with frame Dialog-Frame.
VIEW FRAME Dialog-Frame.
rs-auto:screen-value = '1'.
RUN openbr in this-procedure ( input yes, input no, input '':U).
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Движение материальных ценностей".
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .
assign frame Dialog-Frame rs-auto.
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
filter-point = filter-point0 + par-mode.
CASE par-mode :
WHEN 'все':U        THEN DO:
  assign
  frame Dialog-Frame:TITLE = title0
  filter-label = substitute("&1", filter-label0)
  .
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
                              "FOR EACH X_wth-doc"
      parameter-4-40 =
        (
          if (" (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) ) " + " " + where-phrase-40) <> ""
          then  substitute(' ( &1 = 1 or ( &1 = 2 and X_wth-doc.auto-fill ) or ( &1 = 3 and not X_wth-doc.auto-fill ) )', rs-auto )  + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "")
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + ' USE-INDEX host-date ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' USE-INDEX host-date ' +
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
          (" (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) ) " + " " + where-phrase-40 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH X_wth-doc
      where  (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )
       USE-INDEX host-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_wth-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer X_wth-doc:handle) then do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-4-40 =
        "where ":u +  substitute(' ( &1 = 1 or ( &1 = 2 and X_wth-doc.auto-fill ) or ( &1 = 3 and not X_wth-doc.auto-fill ) )', rs-auto )  + " ":u + where-phrase-40 + " ":u + p-find-condition + " " + ""
      parameter-5-40 = ' USE-INDEX host-date '
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(X_wth-doc)
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input (buffer X_wth-doc:handle)
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
      parameter-3-40 =  "FOR EACH X_wth-doc"
      parameter-4-40 =
        (
          if (" (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) ) " + " " + where-phrase-40) <> ""
          then  substitute(' ( &1 = 1 or ( &1 = 2 and X_wth-doc.auto-fill ) or ( &1 = 3 and not X_wth-doc.auto-fill ) )', rs-auto )  + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-40 = if sort-phrase-40 = ''
                           then
        (
        " " + ' USE-INDEX host-date ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' USE-INDEX host-date ' +
          " " + sort-column-phrase +
        " " + sort-phrase-40
        )
      parameter-7-40 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
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
WHEN 'фирма':U    THEN DO:
  if p-open-query then do:
    ASSIGN
    frame Dialog-Frame:TITLE = title0 + " Фирма: " + vhost-name .
  end.
    filter-label = substitute("&1 Одна фирма", filter-label0).
    .
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
                              "FOR EACH X_wth-doc"
      parameter-4-42 =
        (
          if (" X_wth-doc.host-code = parhost-code and (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )" + " " + where-phrase-42) <> ""
          then  substitute(' X_wth-doc.host-code = &1 and ( &2 = 1 or ( &2 = 2 and X_wth-doc.auto-fill ) or ( &2 = 3 and not X_wth-doc.auto-fill ) )' , parhost-code , rs-auto)  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "")
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + ' USE-INDEX host-date ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' USE-INDEX host-date ' +
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
          (" X_wth-doc.host-code = parhost-code and (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )" + " " + where-phrase-42 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH X_wth-doc
      where  X_wth-doc.host-code = parhost-code and (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )
       USE-INDEX host-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_wth-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer X_wth-doc:handle) then do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-4-42 =
        "where ":u +  substitute(' X_wth-doc.host-code = &1 and ( &2 = 1 or ( &2 = 2 and X_wth-doc.auto-fill ) or ( &2 = 3 and not X_wth-doc.auto-fill ) )' , parhost-code , rs-auto)  + " ":u + where-phrase-42 + " ":u + p-find-condition + " " + ""
      parameter-5-42 = ' USE-INDEX host-date '
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(X_wth-doc)
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input (buffer X_wth-doc:handle)
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
      parameter-3-42 =  "FOR EACH X_wth-doc"
      parameter-4-42 =
        (
          if (" X_wth-doc.host-code = parhost-code and (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )" + " " + where-phrase-42) <> ""
          then  substitute(' X_wth-doc.host-code = &1 and ( &2 = 1 or ( &2 = 2 and X_wth-doc.auto-fill ) or ( &2 = 3 and not X_wth-doc.auto-fill ) )' , parhost-code , rs-auto)  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + ' USE-INDEX host-date ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' USE-INDEX host-date ' +
          " " + sort-column-phrase +
        " " + sort-phrase-42
        )
      parameter-7-42 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
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
WHEN 'объект':U THEN DO:
  if p-open-query then do:
    ASSIGN
    frame Dialog-Frame:TITLE = title0 + " Объект: " + parobj-type + string(parobj-code).
  end.
    filter-label = substitute("&1 Один объект", filter-label0).
    .
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
                              "FOR EACH X_wth-doc"
      parameter-4-44 =
        (
          if ("       X_wth-doc.host-code = parhost-code AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )                     " + " " + where-phrase-44) <> ""
          then  substitute( '       X_wth-doc.host-code  = &1 AND       X_wth-doc.obj-type   = &5&2&5 AND       X_wth-doc.obj-code   = &3 AND       ( &4 = 1 or ( &4 = 2 and X_wth-doc.auto-fill ) or ( &4 = 3 and not X_wth-doc.auto-fill ) )        '       , parhost-code              , parobj-type               , parobj-code               , rs-auto                   , chr(34)         )        + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "")
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + ' USE-INDEX obj-date ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' USE-INDEX obj-date ' +
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
          ("       X_wth-doc.host-code = parhost-code AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )                     " + " " + where-phrase-44 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH X_wth-doc
      where        X_wth-doc.host-code = parhost-code AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )
       USE-INDEX obj-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_wth-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer X_wth-doc:handle) then do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-4-44 =
        "where ":u +  substitute( '       X_wth-doc.host-code  = &1 AND       X_wth-doc.obj-type   = &5&2&5 AND       X_wth-doc.obj-code   = &3 AND       ( &4 = 1 or ( &4 = 2 and X_wth-doc.auto-fill ) or ( &4 = 3 and not X_wth-doc.auto-fill ) )        '       , parhost-code              , parobj-type               , parobj-code               , rs-auto                   , chr(34)         )        + " ":u + where-phrase-44 + " ":u + p-find-condition + " " + ""
      parameter-5-44 = ' USE-INDEX obj-date '
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(X_wth-doc)
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input (buffer X_wth-doc:handle)
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
      parameter-3-44 =  "FOR EACH X_wth-doc"
      parameter-4-44 =
        (
          if ("       X_wth-doc.host-code = parhost-code AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )                     " + " " + where-phrase-44) <> ""
          then  substitute( '       X_wth-doc.host-code  = &1 AND       X_wth-doc.obj-type   = &5&2&5 AND       X_wth-doc.obj-code   = &3 AND       ( &4 = 1 or ( &4 = 2 and X_wth-doc.auto-fill ) or ( &4 = 3 and not X_wth-doc.auto-fill ) )        '       , parhost-code              , parobj-type               , parobj-code               , rs-auto                   , chr(34)         )        + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + ' USE-INDEX obj-date ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' USE-INDEX obj-date ' +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
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
WHEN "doc-type":U    THEN DO:
  if p-open-query then do:  ASSIGN
    frame Dialog-Frame:TITLE = title0 + " Объект: " + parobj-type + string(parobj-code) + chr(32) + par-type.
  end.
    filter-label = substitute("&1 Один тип док-тов", filter-label0).
    .
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
                              "FOR EACH X_wth-doc"
      parameter-4-46 =
        (
          if ("       X_wth-doc.host-code = parhost-code  AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.doc-type  = par-type AND        (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )                   " + " " + where-phrase-46) <> ""
          then  substitute( '       X_wth-doc.host-code  = &1 AND       X_wth-doc.obj-type   = &6&2&6 AND       X_wth-doc.obj-code   = &3 AND       X_wth-doc.doc-type   = &6&4&6 AND       ( &5 = 1 or ( &5 = 2 and X_wth-doc.auto-fill ) or ( &5 = 3 and not X_wth-doc.auto-fill ) )       '       , parhost-code              , parobj-type               , parobj-code               , par-type                  , rs-auto                   , chr(34)         )        + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + "")
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + ' USE-INDEX obj-type ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' USE-INDEX obj-type ' +
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
          ("       X_wth-doc.host-code = parhost-code  AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.doc-type  = par-type AND        (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )                   " + " " + where-phrase-46 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH X_wth-doc
      where        X_wth-doc.host-code = parhost-code  AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.doc-type  = par-type AND        (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )
       USE-INDEX obj-type
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_wth-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer X_wth-doc:handle) then do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-4-46 =
        "where ":u +  substitute( '       X_wth-doc.host-code  = &1 AND       X_wth-doc.obj-type   = &6&2&6 AND       X_wth-doc.obj-code   = &3 AND       X_wth-doc.doc-type   = &6&4&6 AND       ( &5 = 1 or ( &5 = 2 and X_wth-doc.auto-fill ) or ( &5 = 3 and not X_wth-doc.auto-fill ) )       '       , parhost-code              , parobj-type               , parobj-code               , par-type                  , rs-auto                   , chr(34)         )        + " ":u + where-phrase-46 + " ":u + p-find-condition + " " + ""
      parameter-5-46 = ' USE-INDEX obj-type '
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(X_wth-doc)
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input (buffer X_wth-doc:handle)
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
      parameter-3-46 =  "FOR EACH X_wth-doc"
      parameter-4-46 =
        (
          if ("       X_wth-doc.host-code = parhost-code  AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.doc-type  = par-type AND        (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) )                   " + " " + where-phrase-46) <> ""
          then  substitute( '       X_wth-doc.host-code  = &1 AND       X_wth-doc.obj-type   = &6&2&6 AND       X_wth-doc.obj-code   = &3 AND       X_wth-doc.doc-type   = &6&4&6 AND       ( &5 = 1 or ( &5 = 2 and X_wth-doc.auto-fill ) or ( &5 = 3 and not X_wth-doc.auto-fill ) )       '       , parhost-code              , parobj-type               , parobj-code               , par-type                  , rs-auto                   , chr(34)         )        + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + ' USE-INDEX obj-type ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' USE-INDEX obj-type ' +
          " " + sort-column-phrase +
        " " + sort-phrase-46
        )
      parameter-7-46 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
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
WHEN 'Контрагент':U    THEN DO:
  if p-open-query then do:
    ASSIGN
    frame Dialog-Frame:TITLE = title0 + " Объект: " + parobj-type + string(parobj-code) + " Контрагент: " + vcli-name.
  end.
    filter-label = substitute("&1 Один объект, один контрагент", filter-label0).
    .
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
                              "FOR EACH X_wth-doc"
      parameter-4-48 =
        (
          if ("       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND                 X_wth-doc.cli-type = parcli-type AND                 X_wth-doc.cli-code = parcli-code                   " + " " + where-phrase-48) <> ""
          then  substitute( '       X_wth-doc.obj-type = &5&1&5 AND       X_wth-doc.obj-code = &2 AND       X_wth-doc.cli-type = &5&3&5 AND       X_wth-doc.cli-code = &4           '       , parobj-type               , parobj-code               , parcli-type               , parcli-code               , chr(34)         )        + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + "")
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + ' USE-INDEX iobj ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' USE-INDEX iobj ' +
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
          ("       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND                 X_wth-doc.cli-type = parcli-type AND                 X_wth-doc.cli-code = parcli-code                   " + " " + where-phrase-48 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH X_wth-doc
      where        X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND                 X_wth-doc.cli-type = parcli-type AND                 X_wth-doc.cli-code = parcli-code
       USE-INDEX iobj
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_wth-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer X_wth-doc:handle) then do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-4-48 =
        "where ":u +  substitute( '       X_wth-doc.obj-type = &5&1&5 AND       X_wth-doc.obj-code = &2 AND       X_wth-doc.cli-type = &5&3&5 AND       X_wth-doc.cli-code = &4           '       , parobj-type               , parobj-code               , parcli-type               , parcli-code               , chr(34)         )        + " ":u + where-phrase-48 + " ":u + p-find-condition + " " + ""
      parameter-5-48 = ' USE-INDEX iobj '
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(X_wth-doc)
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input (buffer X_wth-doc:handle)
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
      parameter-3-48 =  "FOR EACH X_wth-doc"
      parameter-4-48 =
        (
          if ("       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND                 X_wth-doc.cli-type = parcli-type AND                 X_wth-doc.cli-code = parcli-code                   " + " " + where-phrase-48) <> ""
          then  substitute( '       X_wth-doc.obj-type = &5&1&5 AND       X_wth-doc.obj-code = &2 AND       X_wth-doc.cli-type = &5&3&5 AND       X_wth-doc.cli-code = &4           '       , parobj-type               , parobj-code               , parcli-type               , parcli-code               , chr(34)         )        + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + ' USE-INDEX iobj ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' USE-INDEX iobj ' +
          " " + sort-column-phrase +
        " " + sort-phrase-48
        )
      parameter-7-48 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
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
WHEN "auto":U THEN DO:
  if p-open-query then do:
    ASSIGN
    frame Dialog-Frame:TITLE = title0 + " Объект: " + parobj-type + string(parobj-code) + chr(32) + "Автоматические документы".
  end.
    filter-label = substitute("&1 Автодокументы", filter-label0).
    .
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
                              "FOR EACH X_wth-doc"
      parameter-4-50 =
        (
          if ("       X_wth-doc.host-code = parhost-code AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.auto-fill = yes                    " + " " + where-phrase-50) <> ""
          then  substitute( '       X_wth-doc.host-code = &1  AND       X_wth-doc.obj-type  = &4&2&4  AND       X_wth-doc.obj-code  = &3  AND       X_wth-doc.auto-fill = yes           '       , parhost-code              , parobj-type               , parobj-code               , chr(34)         )        + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + "")
      parameter-6-50 = if sort-phrase-50 = ''
                           then
        (
        " " + ' use-index auto-date ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' use-index auto-date ' +
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
          ("       X_wth-doc.host-code = parhost-code AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.auto-fill = yes                    " + " " + where-phrase-50 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH X_wth-doc
      where        X_wth-doc.host-code = parhost-code AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.auto-fill = yes
       use-index auto-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_wth-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer X_wth-doc:handle) then do:
      assign
      parameter-2-50 = (if p-find-next then "true":u else "false":u )
      parameter-4-50 =
        "where ":u +  substitute( '       X_wth-doc.host-code = &1  AND       X_wth-doc.obj-type  = &4&2&4  AND       X_wth-doc.obj-code  = &3  AND       X_wth-doc.auto-fill = yes           '       , parhost-code              , parobj-type               , parobj-code               , chr(34)         )        + " ":u + where-phrase-50 + " ":u + p-find-condition + " " + ""
      parameter-5-50 = ' use-index auto-date '
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(X_wth-doc)
                          ,input logical(parameter-2-50)
                          ,input no-lock
                          ,input (buffer X_wth-doc:handle)
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-50 = (if p-find-next then "true":u else "false":u )
      parameter-3-50 =  "FOR EACH X_wth-doc"
      parameter-4-50 =
        (
          if ("       X_wth-doc.host-code = parhost-code AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.auto-fill = yes                    " + " " + where-phrase-50) <> ""
          then  substitute( '       X_wth-doc.host-code = &1  AND       X_wth-doc.obj-type  = &4&2&4  AND       X_wth-doc.obj-code  = &3  AND       X_wth-doc.auto-fill = yes           '       , parhost-code              , parobj-type               , parobj-code               , chr(34)         )        + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-50 = if sort-phrase-50 = ''
                           then
        (
        " " + ' use-index auto-date ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' use-index auto-date ' +
          " " + sort-column-phrase +
        " " + sort-phrase-50
        )
      parameter-7-50 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
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
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
END.
WHEN "auto-nfact":U THEN DO:
  if p-open-query then do:
    ASSIGN
    frame Dialog-Frame:TITLE = title0 + " Объект: " + parobj-type + string(parobj-code) + chr(32) + "Незакрытые автоматические документы".
    end.
    filter-label = substitute("&1 Незакрытые автодокументы", filter-label0).
    .
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-52  as logical   no-undo .
define variable  l-filter-open-52    as logical   .
define variable  flt-rec-52       as recid     no-undo .
define variable  filter-name-52      as character no-undo .
define variable  where-phrase-52     as character no-undo .
define variable  sort-phrase-52      as character no-undo .
define variable  where-phrase-rus-52 as character no-undo .
define variable  sort-phrase-rus-52  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-52
  ,output filter-name-52
  ,output where-phrase-52
  ,output sort-phrase-52
  ,output where-phrase-rus-52
  ,output sort-phrase-rus-52
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-52
      ) no-error .
  assign
    l-filter-open-52 = false
  .
  if flt-rec-52 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-52 as character no-undo .
    define variable  parameter-3-52 as character no-undo .
    define variable  parameter-4-52 as character no-undo .
    define variable  parameter-5-52 as character no-undo .
    define variable  parameter-6-52 as character no-undo .
    define variable  parameter-7-52 as character no-undo .
      assign
      parameter-3-52 =
                              "FOR EACH X_wth-doc"
      parameter-4-52 =
        (
          if ("       X_wth-doc.host-code = parhost-code AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.status_  <> 'факт':U  AND       X_wth-doc.auto-fill = yes                    " + " " + where-phrase-52) <> ""
          then  substitute( '       X_wth-doc.host-code =  &1 AND       X_wth-doc.obj-type  =  &5&2&5 AND       X_wth-doc.obj-code  =  &3 AND       X_wth-doc.status_   <> &5&4&5 AND       X_wth-doc.auto-fill = yes        '       , parhost-code              , parobj-type               , parobj-code               , 'факт':U                   , chr(34)         )        + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + "")
      parameter-6-52 = if sort-phrase-52 = ''
                           then
        (
        " " + ' use-index auto-date ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' use-index auto-date ' +
          " " + sort-column-phrase +
        " " + sort-phrase-52
        )
      parameter-7-52 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-52 =
          ("       X_wth-doc.host-code = parhost-code AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.status_  <> 'факт':U  AND       X_wth-doc.auto-fill = yes                    " + " " + where-phrase-52 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-52
                          ,input parameter-4-52
                          ,input parameter-5-52
                          ,input parameter-6-52
                          ,input parameter-7-52
                          )
      .
      assign
        l-filter-open-52 = true
      .
    end.
    if l-filter-open-52 = false then do:
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
  if l-filter-open-52 = false then do:
    OPEN QUERY br-docs FOR EACH X_wth-doc
      where        X_wth-doc.host-code = parhost-code AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.status_  <> 'факт':U  AND       X_wth-doc.auto-fill = yes
       use-index auto-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_wth-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer X_wth-doc:handle) then do:
      assign
      parameter-2-52 = (if p-find-next then "true":u else "false":u )
      parameter-4-52 =
        "where ":u +  substitute( '       X_wth-doc.host-code =  &1 AND       X_wth-doc.obj-type  =  &5&2&5 AND       X_wth-doc.obj-code  =  &3 AND       X_wth-doc.status_   <> &5&4&5 AND       X_wth-doc.auto-fill = yes        '       , parhost-code              , parobj-type               , parobj-code               , 'факт':U                   , chr(34)         )        + " ":u + where-phrase-52 + " ":u + p-find-condition + " " + ""
      parameter-5-52 = ' use-index auto-date '
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(X_wth-doc)
                          ,input logical(parameter-2-52)
                          ,input no-lock
                          ,input (buffer X_wth-doc:handle)
                          ,input parameter-4-52
                          ,input parameter-5-52
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-52 = (if p-find-next then "true":u else "false":u )
      parameter-3-52 =  "FOR EACH X_wth-doc"
      parameter-4-52 =
        (
          if ("       X_wth-doc.host-code = parhost-code AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.status_  <> 'факт':U  AND       X_wth-doc.auto-fill = yes                    " + " " + where-phrase-52) <> ""
          then  substitute( '       X_wth-doc.host-code =  &1 AND       X_wth-doc.obj-type  =  &5&2&5 AND       X_wth-doc.obj-code  =  &3 AND       X_wth-doc.status_   <> &5&4&5 AND       X_wth-doc.auto-fill = yes        '       , parhost-code              , parobj-type               , parobj-code               , 'факт':U                   , chr(34)         )        + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-52 = if sort-phrase-52 = ''
                           then
        (
        " " + ' use-index auto-date ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' use-index auto-date ' +
          " " + sort-column-phrase +
        " " + sort-phrase-52
        )
      parameter-7-52 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-52)
                          ,input no-lock
                          ,input parameter-3-52
                          ,input parameter-4-52
                          ,input parameter-5-52
                          ,input parameter-6-52
                          ,input parameter-7-52
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
WHEN "ext-doc-type":U THEN DO:
    parext-doc-name = ENTRY(LOOKUP(parext-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u) no-error.
if p-open-query then     ASSIGN frame Dialog-Frame:TITLE = title0 + " Объект: " + parobj-type + chr(32) + string(parobj-code) + chr(32) + parext-doc-name.
    filter-label = substitute("&1 Один расш. тип док-тов", filter-label0).
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-54  as logical   no-undo .
define variable  l-filter-open-54    as logical   .
define variable  flt-rec-54       as recid     no-undo .
define variable  filter-name-54      as character no-undo .
define variable  where-phrase-54     as character no-undo .
define variable  sort-phrase-54      as character no-undo .
define variable  where-phrase-rus-54 as character no-undo .
define variable  sort-phrase-rus-54  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-54
  ,output filter-name-54
  ,output where-phrase-54
  ,output sort-phrase-54
  ,output where-phrase-rus-54
  ,output sort-phrase-rus-54
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-54
      ) no-error .
  assign
    l-filter-open-54 = false
  .
  if flt-rec-54 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-54 as character no-undo .
    define variable  parameter-3-54 as character no-undo .
    define variable  parameter-4-54 as character no-undo .
    define variable  parameter-5-54 as character no-undo .
    define variable  parameter-6-54 as character no-undo .
    define variable  parameter-7-54 as character no-undo .
      assign
      parameter-3-54 =
                              "FOR EACH X_wth-doc"
      parameter-4-54 =
        (
          if ("       X_wth-doc.host-code = parhost-code  AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.ext-doc-type  = parext-type AND       (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) ) AND       (if parstatus > '' and parstatus <> 'все':U then (if parstatus = 'факт':U then X_wth-doc.status_ = 'факт':U else X_wth-doc.status_ <> 'факт':U ) else true)                   " + " " + where-phrase-54) <> ""
          then  substitute( '       X_wth-doc.host-code    = &1 AND       X_wth-doc.obj-type     = &7&2&7 AND       X_wth-doc.obj-code     = &3 AND       X_wth-doc.ext-doc-type = &7&4&7 AND       ( &5 = 1 or ( &5 = 2 and X_wth-doc.auto-fill ) or ( &5 = 3 and not X_wth-doc.auto-fill ) ) AND        ( if &7&6&7 > &7&7 and &7&6&7 <> &7&8&7         then (if &7&6&7 = &7&9&7                 then X_wth-doc.status_ =  &7&9&7                      else X_wth-doc.status_ <> &7&9&7                   )         else true       )       '       , parhost-code                  , parobj-type                   , parobj-code                   , parext-type                   , rs-auto                       , parstatus                     , chr(34)             , 'все':U                        , 'факт':U                       )        + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + "")
      parameter-6-54 = if sort-phrase-54 = ''
                           then
        (
        " " + ' USE-INDEX obj-date ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' USE-INDEX obj-date ' +
          " " + sort-column-phrase +
        " " + sort-phrase-54
        )
      parameter-7-54 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-54 =
          ("       X_wth-doc.host-code = parhost-code  AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.ext-doc-type  = parext-type AND       (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) ) AND       (if parstatus > '' and parstatus <> 'все':U then (if parstatus = 'факт':U then X_wth-doc.status_ = 'факт':U else X_wth-doc.status_ <> 'факт':U ) else true)                   " + " " + where-phrase-54 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-54
                          ,input parameter-4-54
                          ,input parameter-5-54
                          ,input parameter-6-54
                          ,input parameter-7-54
                          )
      .
      assign
        l-filter-open-54 = true
      .
    end.
    if l-filter-open-54 = false then do:
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
  if l-filter-open-54 = false then do:
    OPEN QUERY br-docs FOR EACH X_wth-doc
      where        X_wth-doc.host-code = parhost-code  AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.ext-doc-type  = parext-type AND       (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) ) AND       (if parstatus > '' and parstatus <> 'все':U then (if parstatus = 'факт':U then X_wth-doc.status_ = 'факт':U else X_wth-doc.status_ <> 'факт':U ) else true)
       USE-INDEX obj-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_wth-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer X_wth-doc:handle) then do:
      assign
      parameter-2-54 = (if p-find-next then "true":u else "false":u )
      parameter-4-54 =
        "where ":u +  substitute( '       X_wth-doc.host-code    = &1 AND       X_wth-doc.obj-type     = &7&2&7 AND       X_wth-doc.obj-code     = &3 AND       X_wth-doc.ext-doc-type = &7&4&7 AND       ( &5 = 1 or ( &5 = 2 and X_wth-doc.auto-fill ) or ( &5 = 3 and not X_wth-doc.auto-fill ) ) AND        ( if &7&6&7 > &7&7 and &7&6&7 <> &7&8&7         then (if &7&6&7 = &7&9&7                 then X_wth-doc.status_ =  &7&9&7                      else X_wth-doc.status_ <> &7&9&7                   )         else true       )       '       , parhost-code                  , parobj-type                   , parobj-code                   , parext-type                   , rs-auto                       , parstatus                     , chr(34)             , 'все':U                        , 'факт':U                       )        + " ":u + where-phrase-54 + " ":u + p-find-condition + " " + ""
      parameter-5-54 = ' USE-INDEX obj-date '
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(X_wth-doc)
                          ,input logical(parameter-2-54)
                          ,input no-lock
                          ,input (buffer X_wth-doc:handle)
                          ,input parameter-4-54
                          ,input parameter-5-54
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-54 = (if p-find-next then "true":u else "false":u )
      parameter-3-54 =  "FOR EACH X_wth-doc"
      parameter-4-54 =
        (
          if ("       X_wth-doc.host-code = parhost-code  AND       X_wth-doc.obj-type  = parobj-type  AND       X_wth-doc.obj-code  = parobj-code  AND       X_wth-doc.ext-doc-type  = parext-type AND       (rs-auto = 1 or (rs-auto = 2 and X_wth-doc.auto-fill) or (rs-auto = 3 and not X_wth-doc.auto-fill ) ) AND       (if parstatus > '' and parstatus <> 'все':U then (if parstatus = 'факт':U then X_wth-doc.status_ = 'факт':U else X_wth-doc.status_ <> 'факт':U ) else true)                   " + " " + where-phrase-54) <> ""
          then  substitute( '       X_wth-doc.host-code    = &1 AND       X_wth-doc.obj-type     = &7&2&7 AND       X_wth-doc.obj-code     = &3 AND       X_wth-doc.ext-doc-type = &7&4&7 AND       ( &5 = 1 or ( &5 = 2 and X_wth-doc.auto-fill ) or ( &5 = 3 and not X_wth-doc.auto-fill ) ) AND        ( if &7&6&7 > &7&7 and &7&6&7 <> &7&8&7         then (if &7&6&7 = &7&9&7                 then X_wth-doc.status_ =  &7&9&7                      else X_wth-doc.status_ <> &7&9&7                   )         else true       )       '       , parhost-code                  , parobj-type                   , parobj-code                   , parext-type                   , rs-auto                       , parstatus                     , chr(34)             , 'все':U                        , 'факт':U                       )        + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-54 = if sort-phrase-54 = ''
                           then
        (
        " " + ' USE-INDEX obj-date ' +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + ' USE-INDEX obj-date ' +
          " " + sort-column-phrase +
        " " + sort-phrase-54
        )
      parameter-7-54 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-54)
                          ,input no-lock
                          ,input parameter-3-54
                          ,input parameter-4-54
                          ,input parameter-5-54
                          ,input parameter-6-54
                          ,input parameter-7-54
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
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-docs to recid v-doc-rec No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-docs in frame Dialog-Frame.
APPLY "ENTRY" TO br-docs.
END PROCEDURE.
PROCEDURE proc-b-close :
DEFINE INPUT PARAMETER loc-mode as character no-undo.
define variable r_w-doc-recid AS RECID NO-UNDO.
DEF BUFFER b_wth-doc  FOR ub.wth-doc.
DEF BUFFER buf_wth-obj  FOR ub.wth-obj.
DEF BUFFER buf_wth-line FOR ub.wth-line.
define variable v-proc-name-err as char no-undo.
define variable v-user-action    as character no-undo.
define variable v-printed        as logical   no-undo.
define variable vss-include-info55 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wth-doc_update':U
    ,input  'object':U
    ,input  parhost-code
    ,input  parobj-type
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if not glog
then do:
  return error.
end.
ASSIGN v-doc-rec = RECID( X_wth-doc ).
ASSIGN r_w-doc-recid = v-doc-rec.
FIND FIRST b_wth-doc where
                recid(b_wth-doc) = v-doc-rec No-ERROR.
if not avail b_wth-doc then return error.
ASSIGN glog = NO.
CASE LOC-MODE:
WHEN "B-CLOSE":U THEN DO:
  IF b_wth-doc.status_ = 'факт':U THEN DO:
    MESSAGE "Документ уже закрыт на ФАКТ!  " VIEW-AS ALERT-BOX ERROR.
    RETURN error.
  END.
  MESSAGE
    "Вы собираетесь закрыть документ со статуса ~"" + CAPS( b_wth-doc.status_ ) +
    "~" на статус ~"" + CAPS(
    ( IF b_wth-doc.status_ = 'накл':U AND  b_wth-doc.doc-type = 'инв':U
      THEN 'разрешен':U
      ELSE 'факт':U ) ) + "~"." SKIP
    "Учтите, что закрытые документы открывать нельзя!" SKIP( 1 )
    "Вы уверены, что хотите закрыть документ?     "
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF glog <> YES THEN DO:
    RETURN error.
  END.
END.
WHEN "B-OPEN":U THEN DO:
  IF b_wth-doc.status_ = 'накл':U THEN DO:
    MESSAGE "Документ уже открыт!  " VIEW-AS ALERT-BOX ERROR.
    RETURN error.
  END.
  if b_wth-doc.status_ = 'факт':U then do:
    message "Нельзя открыть документ, закрытый на факт"
    view-as alert-box error .
    return error.
  end.
  MESSAGE
    "Вы собираетесь открыть документ со статуса ~"" + CAPS( b_wth-doc.status_ ) +
    "~" на статус ~"" + CAPS(
    ( IF b_wth-doc.status_ = 'разрешен':U THEN 'накл':U ELSE '') ) + "~"." SKIP
    "Вы уверены, что хотите открыть документ?     "
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF glog <> YES THEN DO:
    RETURN error.
  END.
END.
  OTHERWISE RETURN ERROR.
end case.
v-proc-name-err = string(session:TEMP-DIRECTORY) + '/clsWdoc.err':U .
if search (v-proc-name-err) <> ? then do:
  os-delete value(v-proc-name-err).
end.
run str/wth-stts.p (
                 input parparentproc
                ,BUFFER b_wth-doc
                ,INPUT (if loc-mode = "b-close":U then "+":U else "-":U)
                ,INPUT YES
                ,INPUT parobj-type
                ,INPUT PAROBJ-code
                ,input v-proc-name-err ) NO-ERROR.
IF ERROR-STATUS :ERROR THEN DO:
  case loc-mode:
    when "b-close":U then
    MESSAGE "Не удалось закрыть документ!  " VIEW-AS ALERT-BOX ERROR.
    when "b-open":U then
    MESSAGE "Не удалось открыть документ!  " VIEW-AS ALERT-BOX ERROR.
  end CASE.
  if search (v-proc-name-err) <> ? then do:
    run gbl/prnfilen.w
      (input  "Ошибки при закрытии документа"
      ,input  0
      ,input  v-proc-name-err
      ,input  7
      ,output v-user-action
      ,output v-printed
      ).
  end.
  RETURN error.
END.
else if return-value = 'warning':U  and search (v-proc-name-err) <> ? then do:
     message 'Документ закрыт успешно.' skip
             'Просмотрите дополнительную информацию в лог-файле.'
             view-as alert-box warning.
end.
ASSIGN glog = br-docs:REFRESH( ) in frame Dialog-Frame.
RUN OpenBr in this-procedure ( input yes, input no, input '':U ).
IF v-doc-rec <> r_w-doc-recid THEN DO:
  ASSIGN v-doc-rec = r_w-doc-recid.
END.
Reposition br-docs to recid v-doc-rec No-ERROR.
END PROCEDURE.
PROCEDURE proc-b-print :
define input parameter p-doc-code   as character        no-undo.
define input parameter loc-option   as character        no-undo.
if loc-option = '':U then return error.
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wth-doc_print':U
    ,input  'object':U
    ,input  parhost-code
    ,input  parobj-type
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
IF glog <> YES
THEN DO:
  RETURN ERROR.
END.
CASE loc-option:
when 'ONE':U
then do:
    run rep/wth-prn.p (
          input parparentproc
        , input p-doc-code
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка печати документа материальных ценностей."
            skip(1)
            skip "Номер документа:" p-doc-code
            skip(1)
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                 trim( error-status :get-message( 2 ) )
                 trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return error.
    end.
end.
when 'LIST':U then do:
    run proc-print-list in this-procedure no-error.
end.
end case.
loc-option = ''.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
tbl = 'wth-doc'
join-tbl = 'X_wth-doc'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('doc-code', 'Номер', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Дата', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-type', 'Тип', 'trn-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ext-doc-type', 'Расш. тип', 'wth-ext-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', 'trn-stat',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('inter_', 'Внутр', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('exter_', 'Внеш', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type*cli-code', 'Контрагент', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-name', 'Имя контраг', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-sum', 'Сумма', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-sum', 'Сумма факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Дата смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('bge-date', 'Дата внеш.пров.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('scf-date', 'Дата сч-факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('source-ref', 'Ссылка на док-т', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('borned', 'Порожден', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('operator', 'Исполнитель', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('deliver', 'Доставил', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver', 'Получил', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', 'Комментарий', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('creid', 'Опер-р', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('credate', 'Дата создания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
  ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
  ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
run gbl/filter.w ( INPUT parparentproc
                  , INPUT (filter-point + chr(4) +
                            filter-label + chr(4) +
                            string(yes))
                  , INPUT tbl
                  , INPUT join-tbl
                  , INPUT fld
                  , INPUT lab
                  , INPUT spr
                  , INPUT dim ).
RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
PROCEDURE proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code like ub.wth-doc.doc-code no-undo.
display
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
with frame Dialog-Frame.
assign
pardoc-code = chr(34) + pardoc-code + chr(34).
run OpenBr in this-procedure
  (input false
  ,input par-next
  ,input substitute("and X_wth-doc.doc-code   begins &1 "
    , pardoc-code)
  ).
apply "entry":u to sch-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-date :
define input parameter par-next as logical no-undo.
define input parameter par-date like ub.wth-doc.doc-date no-undo.
define input parameter parwhat-date as character no-undo.
define variable var-datechr as character no-undo.
display
'':U @ sch-code
with frame Dialog-Frame.
assign
var-datechr = string(day(par-date)) + chr(47) +
              string(month(par-date)) + chr(47) +
              string(year(par-date)).
case parwhat-date:
  when "doc-date":U then do:
    display
    "  /  /":U @ sch-fact
    with frame Dialog-Frame.
    run OpenBr in this-procedure
    (input false
    ,input true
    ,input substitute("and X_wth-doc.doc-date = &1 "
      , var-datechr)
    ).
    apply "entry":u to sch-date in frame Dialog-Frame.
  end.
  when "fact-date":U then do:
    display
    "  /  /":U @ sch-date
    with frame Dialog-Frame.
    run OpenBr in this-procedure
      (input false
      ,input true
      ,input substitute("and X_wth-doc.fact-date = &1 "
      , var-datechr)
      ).
    apply "entry":u to sch-fact in frame Dialog-Frame.
  end.
END.
END PROCEDURE.
PROCEDURE proc-print-list :
DEFINE VARIABLE vardoc-rec as recid no-undo.
DEFINE VARIABLE for-doc-date as character no-undo.
DEFINE VARIABLE for-shift-date as character no-undo.
DEFINE VARIABLE for-obj as character no-undo.
define variable accum-count as integer.
define variable accum-doc-sum as decimal.
define variable accum-fact-sum as decimal.
define variable date_string     as      char    no-undo.
define variable loc-v_operator  as   char    no-undo.
define variable loc-v_deliver as      char    no-undo.
define variable loc-v_receiver as      char    no-undo.
define variable v-shift-name-num as character no-undo.
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
if v-curr-r-b = 'base':U then do:
  assign
  v-header-base-curr = string( "( Б.Вал. - " + caps( v-r-b-abbr ) + " )" )
  .
end.
define variable Line                as      char    no-undo.
define buffer buf-oper for ub.clients.
define buffer buf-deliver for ub.clients.
define buffer buf-receiver for ub.clients.
DEFINE FRAME wth-list
X_wth-doc.doc-type COLUMN-LABEL "Т" FORMAT "X(1)"
X_wth-doc.status_ COLUMN-LABEL "Стат" FORMAT "X(4)"
X_wth-doc.doc-code
for-doc-date  COLUMN-LABEL "Дата" FORMAT "X(5)"
X_wth-doc.fact-date
v-shift-name-num COLUMN-LABEL "N см." FORMAT "X(6)"
for-shift-date  COLUMN-LABEL "Смена" FORMAT "X(5)"
X_wth-doc.inter_ COLUMN-LABEL "В"
X_wth-doc.exter_ COLUMN-LABEL "Ш"
X_wth-doc.cli-name FORMAT "X(26)"
for-obj COLUMN-LABEL "Объект" FORMAT "X(9)"
X_wth-doc.doc-sum COLUMN-LABEL "Сумма по док-ту"
X_wth-doc.fact-sum
X_wth-doc.source-ref COLUMN-LABEL "На документ"
X_wth-doc.bge-date COLUMN-LABEL "Внеш.пров."
loc-v_operator COLUMN-LABEL "Исп" FORMAT "X(8)"
loc-v_deliver  COLUMN-LABEL "Передал" FORMAT "X(8)"
loc-v_receiver  COLUMN-LABEL "Получил" FORMAT "X(8)"
X_wth-doc.creid  COLUMN-LABEL "Опер" FORMAT "X(8)"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width 232 down stream-io use-text    .
if b-sch:tooltip in frame Dialog-Frame <> '' then do:
    message "В списке не установлен фильтр" SKIP
                  "Печать списка может занять длительное время" SKIP
                  "Продолжать?"
    view-as alert-box QUESTION buttons YES-NO update glog.
    if not glog then return.
end.
Line = fill("-", 198).
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
Line format "X(198)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME wth-list  .
run waitfram-show in this-procedure ( input "Ждите..." ).
vardoc-rec = recid(X_wth-doc).
DO WHILE available X_wth-doc :
  GET prev br-docs.
END.
GET next br-docs.
 DO WHILE available X_wth-doc :
        FIND buf-oper NO-LOCK WHERE
                buf-oper.obj-type = 'чел':U AND
                buf-oper.obj-code = X_wth-doc.operator NO-ERROR.
        FIND buf-deliver NO-LOCK WHERE
                buf-deliver.obj-type = 'чел':U AND
                buf-deliver.obj-code = X_wth-doc.deliver NO-ERROR.
        FIND buf-receiver NO-LOCK WHERE
                buf-receiver.obj-type = 'чел':U AND
                buf-receiver.obj-code = X_wth-doc.receiver NO-ERROR.
        assign
        loc-v_operator = ( IF AVAIL buf-oper THEN buf-oper.obj-name ELSE "":U ).
        loc-v_deliver = ( IF AVAIL buf-deliver THEN buf-deliver.obj-name ELSE "":U ).
        loc-v_receiver = ( IF AVAIL buf-receiver THEN buf-receiver.obj-name ELSE "":U )
        .
  Display STREAM PrnLibStream
    X_wth-doc.doc-type
    X_wth-doc.status_
    X_wth-doc.doc-code
    (substring ((string (X_wth-doc.doc-date)), 1, 5)) @ for-doc-date
    X_wth-doc.fact-date
    shift-name-no-err(buffer X_wth-doc) @ v-shift-name-num
    (substring ((string (X_wth-doc.shift-date)), 1, 5)) @ for-shift-date
    X_wth-doc.inter_
    X_wth-doc.exter_
    X_wth-doc.cli-name
    (trim (X_wth-doc.obj-type) + " " + string (X_wth-doc.obj-code, ">>>>9")) @ for-obj
    X_wth-doc.doc-sum
    X_wth-doc.fact-sum
    X_wth-doc.source-ref
    X_wth-doc.bge-date
    loc-v_operator
     loc-v_deliver
    loc-v_receiver
    X_wth-doc.creid
  with FRAME wth-list .
  DOWN STREAM PrnLibStream 1
  with FRAME wth-list  .
  assign
  accum-count = accum-count + 1
  accum-doc-sum = accum-doc-sum + X_wth-doc.doc-sum
    accum-fact-sum = accum-fact-sum + X_wth-doc.fact-sum
    .
  GET next br-docs.
  END.
  UNDERLINE  STREAM PrnLibStream
    X_wth-doc.doc-type
    X_wth-doc.status_
    X_wth-doc.doc-code
    for-doc-date
    X_wth-doc.fact-date
    v-shift-name-num
    for-shift-date
    X_wth-doc.inter_
    X_wth-doc.exter_
    X_wth-doc.cli-name
    for-obj
    X_wth-doc.doc-sum
    X_wth-doc.fact-sum
    X_wth-doc.source-ref
    X_wth-doc.bge-date
    loc-v_operator
    loc-v_deliver
    loc-v_receiver
    X_wth-doc.creid
  with FRAME wth-list .
  DISPLAY STREAM PrnLibStream
  ("ИТОГО" + chr(32) + string(accum-count))  @ X_wth-doc.doc-code
 accum-doc-sum @ X_wth-doc.doc-sum
  accum-fact-sum @ X_wth-doc.fact-sum
  with frame wth-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME wth-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-docs to recid vardoc-rec no-error.
APPLY "entry" to br-docs.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .
  if p-recid <> ?
  then do:
    reposition br-docs to recid p-recid no-error.
  end.
  do with frame Dialog-Frame:
    apply "entry":u to browse BR-docs .
    apply "VALUE-CHANGED":u to browse BR-docs .
  end.
END PROCEDURE.
PROCEDURE reposition-wth-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-wth-doc-recid as recid no-undo .
  case p-direction :
    when "first":U
    then do:
      get first br-docs.
    end.
    when "last":U
    then do:
      get last br-docs.
    end.
    when "prev":U
    then do:
      get prev br-docs.
      if not available X_wth-doc then do:
        message
        "Это первый документ списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-docs.
      if not available X_wth-doc then do:
        message
        "Это последний документ списка"
        view-as alert-box.
      end.
    end.
  end case .
  assign
  p-wth-doc-recid = recid(X_wth-doc)
  .
  run reposition-query in this-procedure
    (input p-wth-doc-recid
    ).
END PROCEDURE.
