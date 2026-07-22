DEFINE BUFFER buf_cli FOR ub.clients.
DEFINE BUFFER for-cash-desk FOR ub.cash-desk.
DEFINE BUFFER X_cash-desk   FOR ub.cash-desk.
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT  PARAMETER bttns  as character  no-undo .
DEFINE INPUT  PARAMETER parref-mode as character no-undo.
DEFINE INPUT  PARAMETER pardb-num like ub.sys-ctrl.db-num no-undo.
DEFINE INPUT  PARAMETER parhost-code like ub.sysconf.host-code no-undo.
DEFINE INPUT  PARAMETER parobj-type like ub.clients.obj-type no-undo.
DEFINE INPUT  PARAMETER parobj-code like ub.clients.obj-code no-undo.
define input  parameter p-rec       as recid no-undo .
DEFINE OUTPUT PARAMETER  p-rid-list    as  char no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник касс" .
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
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
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info7, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info7, return-value, chr(10), error-status :get-message (1)).
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
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info13 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info13, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info13, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info13, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info13, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info13 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info13, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info13 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info13, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info13, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info13, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info13, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info13, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info13, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info13 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info13 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info13, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info13, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info13, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info13 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info13 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info13, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info13, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cd-attr-code :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  define output parameter p-prop-list      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-code in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ,output p-prop-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-tooltip :
  define input  parameter p-ucode   as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-tooltip in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-value :
  define input  parameter p-db-num    like ub.cash-desk-attr.db-num        no-undo .
  define input  parameter p-obj-code  like ub.cash-desk-attr.obj-code      no-undo .
  define input  parameter p-pos-type  like ub.cash-desk-attr.pos-type      no-undo .
  define input  parameter p-cash-num  like ub.cash-desk-attr.cash-num      no-undo .
  define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code      no-undo .
  define input  parameter p-code      like ub.cash-desk-attr.attr-code      no-undo .
  define output parameter p-character like ub.cash-desk-attr.attr-value-character    no-undo .
  define output parameter p-date      like ub.cash-desk-attr.attr-value-date         no-undo .
  define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal      no-undo .
  define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer      no-undo .
  define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical      no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-character
      ,output p-date
      ,output p-decimal
      ,output p-integer
      ,output p-logical
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-write :
  define input parameter p-db-num    like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code  like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type  like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num  like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code      like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-character like ub.cash-desk-attr.attr-value-character no-undo .
  define input parameter p-date      like ub.cash-desk-attr.attr-value-date      no-undo .
  define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal   no-undo .
  define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer   no-undo .
  define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-write in g#attr-lib
      (input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-ucode
      ,input p-code
      ,input p-character
      ,input p-date
      ,input p-decimal
      ,input p-integer
      ,input p-logical
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  define input  parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input  parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input  parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-delete :
  define input parameter  p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter  p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter  p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter  p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter  p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter  p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-news :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  define output parameter p-from-gbd       as logical   no-undo .
  define output parameter p-from-ubd       as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-news in g#attr-lib
      (
       input  p-ucode
      ,input  p-code
      ,output p-news
      ,output p-from-gbd
      ,output p-from-ubd
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-hist :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-hist           as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-hist in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-hist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-parse-date-time returns date
(input  p-string as character
,output p-time   as integer
):
  define variable v-return-value as date      no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-parse-date-time-proc in g#attr-lib
    (input  p-string
    ,output p-time
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run last-check-date-time in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-cd-datetostring returns character
(input  p-date as date
):
  define variable v-return-value as character no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-cd-datetostring-proc in g#attr-lib
    (input  p-date
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr-last-report-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-report-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-maria in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-periodic-tasks in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr_get-attr-int returns integer
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as integer   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-int-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-int-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
function cd-attr_get-attr-log returns logical
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as logical   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-log-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-log-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr_check-marketer :
  define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_check-marketer in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-manual-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-manual-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-batch-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-send-param :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-send-param in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-send-param
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character, input p-num as integer) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character, input p-num as integer):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    if p-data = ? then p-data = 0 .
    p-data = round(p-data, p-num).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
END FUNCTION.
define stream Out-Stream .
define stream OutStr-html.
define variable log-res          as log       no-undo.
define variable rr               as recid     no-undo.
define variable jj               as integer   no-undo .
define variable str              as char      no-undo.
define variable conf-attr        as character no-undo .
define variable conf-par         as char      no-undo.
define variable par-type         as char      no-undo.
define variable vartbl-name      as char      no-undo.
define variable varact           as char      no-undo.
define variable l-shift-on       as logical   no-undo.
define variable v-shift-date     as date      no-undo.
define variable v-shift-num      as integer   no-undo.
define variable v-shift-name     as character no-undo.
define variable filter-point0    as character no-undo init "cashlist" .
define variable filter-point     as character no-undo INIT "cashlist".
define variable filter-label     as character no-undo INIT "Справочник_касс_".
define variable filter-label0    as character no-undo init "Справочник_касс_" .
define variable sort-column-name as character no-undo .
define variable glog             as logical   no-undo .
define variable v-glog           as logical   no-undo .
DEFINE VARIABLE attr-option      AS CHARACTER NO-UNDO.
define VARIABLE v-mode           AS CHARACTER NO-UNDO .
define VARIABLE del-mode         AS logical   NO-UNDO .
define variable v-rid-list       as character no-undo .
define variable mdevice          as class     ibs.th.str.cash.CashDevice
  no-undo.
mdevice = new ibs.th.str.cash.CashDevice().
FUNCTION cash-desk-auto RETURNS CHARACTER
  ( p-autonomy AS INTEGER )  FORWARD.
FUNCTION signExecution RETURNS CHARACTER
  ( INPUT p-device-kind AS INTEGER)  FORWARD.
FUNCTION get-fo-version RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.
FUNCTION get-OptVER RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT p-cash-num AS INTEGER)  FORWARD.
FUNCTION get-ffd-version RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.
FUNCTION get-kkt-schema RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.
FUNCTION get-date RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.
FUNCTION get-time RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.
FUNCTION get-GISMT_FAST RETURNS INTEGER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.
FUNCTION get-GISMT_TIMEOUT RETURNS INTEGER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER)  FORWARD.
DEFINE MENU MENU-B-attr
  MENU-ITEM m_lookup-attr  LABEL "Просмотр"
  MENU-ITEM m_update-attr  LABEL "Изменение"     .
DEFINE MENU MENU-B-attr-2
  MENU-ITEM m_lookup-attr-2 LABEL "Просмотр"
  MENU-ITEM m_update-attr-2 LABEL "Изменение"     .
DEFINE BUTTON B-add
  LABEL "&Добавить"
  SIZE 10 BY 1.
DEFINE BUTTON B-attr
  LABEL "&Оп.данные"
  SIZE 10 BY 1.
DEFINE BUTTON B-attr-2
  LABEL "&Настройки"
  SIZE 10 BY 1.
DEFINE BUTTON B-chg
  LABEL "&Изменить"
  SIZE 10 BY 1.
DEFINE BUTTON B-cli-attr
  LABEL "&Пар-тры типа кассы"
  SIZE 20 BY 1.
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
DEFINE BUTTON B-mark
  LABEL "&*"
  SIZE 3 BY 1.
DEFINE BUTTON B-on
  LABEL "Вкл/В&ыкл"
  SIZE 10 BY 1.
DEFINE BUTTON B-print
  LABEL "Пе&чать"
  SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
  LABEL "&Выход"
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE BUTTON B-sch
  LABEL "&Фильтр"
  SIZE 3 BY 1.
DEFINE BUTTON b-sel AUTO-GO
  LABEL "Вы&бор"
  SIZE 10 BY 1.
DEFINE BUTTON B-shft
  LABEL "С&мены"
  SIZE 10 BY 1.
DEFINE BUTTON b-version
  LABEL "Версия?"
  SIZE 10 BY 1.
DEFINE BUTTON b-tso
  LABEL "Управление ТСО"
  SIZE 15 BY 1.
DEFINE VARIABLE mark-num  AS CHARACTER FORMAT "X(256)":U
  VIEW-AS FILL-IN
  SIZE 9 BY 1
  FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE Rs-del    AS LOGICAL
  VIEW-AS RADIO-SET HORIZONTAL
  RADIO-BUTTONS
  "Тек.", no,
  "Все", ?
  SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE Rs-object AS CHARACTER
  VIEW-AS RADIO-SET HORIZONTAL
  RADIO-BUTTONS
  "БД", "db",
  "Объект", "object"
  SIZE 19 BY 1 NO-UNDO.
DEFINE QUERY BR-cash-desk FOR
  X_cash-desk SCROLLING.
DEFINE BROWSE BR-cash-desk
  QUERY BR-cash-desk DISPLAY
  mark-string( recid(X_cash-desk), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
  X_cash-desk.cash-on COLUMN-LABEL "Вкл" FORMAT "+/":U
  X_cash-desk.obj-code COLUMN-LABEL "Магазин" FORMAT "99999":U
  X_cash-desk.db-num FORMAT ">>>>9":U
  X_cash-desk.cash-num FORMAT ">>>9":U
  entry (lookup (X_cash-desk.pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U) COLUMN-LABEL "Тип POS" FORMAT "X(15)":U
  cash-desk-auto(X_cash-desk.autonomy) COLUMN-LABEL "Активность" FORMAT "X(20)":U
  if X_cash-desk.pos-type = 'IBM-XML':U
  or X_cash-desk.pos-type = 'Autotank':U
  then
  (if num-entries(X_cash-desk.addr-path, chr(4)) > 1
  then (entry(1, X_cash-desk.addr-path, chr(4)) + ":\\":U +
  entry(2, X_cash-desk.addr-path, chr(4)))
  else X_cash-desk.addr-path)
  else X_cash-desk.addr-path COLUMN-LABEL "Адрес (путь к кассе)" FORMAT "X(35)":U
  X_cash-desk.cash-os FORMAT "X(12)":U
  signExecution(X_cash-desk.device-kind) COLUMN-LABEL "Признак исполнения" FORMAT "X(25)":U
  string(if X_cash-desk.is-del then 'удал':U else 'тек':U) COLUMN-LABEL "Статус" FORMAT "X(8)":U
  (if X_cash-desk.remote = 1 then yes else no) COLUMN-LABEL "Удаленная!дистанционно" FORMAT "+/":U
  X_cash-desk.version COLUMN-LABEL "Версия!протокола" FORMAT "X(17)":U
  get-fo-version(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)  COLUMN-LABEL "Версия кассовой программы" FORMAT "X(35)":U
  get-OptVer(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)  COLUMN-LABEL 'Версия "ПО Коннектор" ' FORMAT "X(35)":U
  get-ffd-version(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)  COLUMN-LABEL "Версия ФФД" FORMAT "X(15)":U
  get-kkt-schema(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)  COLUMN-LABEL "Схема интеграции ККТ" FORMAT "X(20)":U
  string(get-GISMT_TIMEOUT(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num))  COLUMN-LABEL "Таймаут ответа! ГИСМТ" FORMAT "X(15)":U
  string(get-GISMT_FAST(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num))  COLUMN-LABEL "Быстрый ответ! ГИСМТ" FORMAT "X(15)":U
  string(get-date(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)) + " " + string(get-time(X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num))  COLUMN-LABEL "Дата/время!последнего опроса касс" FORMAT "X(20)":U
  X_cash-desk.registration-code COLUMN-LABEL "Регистрационный номер" FORMAT "X(30)":U
  X_cash-desk.serial-code       COLUMN-LABEL "Номер производителя"   FORMAT "X(30)":U
    WITH NO-ROW-MARKERS SEPARATORS DROP-TARGET SIZE 98 BY 18.3.
DEFINE FRAME Dialog-Frame
  b-quit AT ROW 1 COL 1
  B-mark AT ROW 1 COL 11
  b-sel AT ROW 1 COL 14
  B-add AT ROW 1 COL 24
  B-chg AT ROW 1 COL 34
  B-del AT ROW 1 COL 44
  B-on AT ROW 1 COL 54
  B-shft AT ROW 1 COL 64
  B-attr AT ROW 1 COL 74
  B-print AT ROW 1 COL 86
  B-hist AT ROW 1 COL 89
  B-sch AT ROW 1 COL 92
  B-Help AT ROW 1 COL 95
  mark-num AT ROW 2 COL 1 NO-LABEL
  Rs-object AT ROW 2 COL 5 NO-LABEL
  Rs-del AT ROW 2 COL 21.5 NO-LABEL
  B-cli-attr AT ROW 2 COL 54
  B-attr-2 AT ROW 2 COL 74 WIDGET-ID 4
  b-version AT ROW 2 COL 84 WIDGET-ID 2
  b-tso AT ROW 2 COL 39
  BR-cash-desk AT ROW 3.43 COL 1
  SPACE(0.24) SKIP(0.30)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Справочник касс"
  CANCEL-BUTTON b-quit.
ASSIGN
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
  B-attr:POPUP-MENU IN FRAME Dialog-Frame = MENU MENU-B-attr:HANDLE.
ASSIGN
  B-attr-2:POPUP-MENU IN FRAME Dialog-Frame = MENU MENU-B-attr-2:HANDLE.
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
    glog = FALSE.
    define variable v-cash-desk-host-code as integer no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  parobj-code
  ,output v-cash-desk-host-code
  )  .
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-reference_input-deletion-updating':U
    ,input  'object':U
    ,input  v-cash-desk-host-code
    ,input  'маг':U
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then  return no-apply .
    rr = ?.
    jj = br-cash-desk:FOCUSED-ROW .
    run ref/cashlsti.w (
      input parparentproc
      ,input 'ДОБАВЛЕНИЕ':U
      ,input v-cntxt-db-num
      ,input parobj-code
      ,input "":U
      ,input 0
      ,input-output rr ).
    if rr <> ? then
    do:
      run OpenBr in this-procedure  ( input yes, input no, input '':U).
      glog = br-cash-desk:SET-REPOSITIONED-ROW( jj, "ALWAYS" ).
      REPOSITION br-cash-desk TO RECID RR.
    end.
  END.
ON CHOOSE OF B-attr IN FRAME Dialog-Frame
  DO:
    define variable v-by-section as logical   no-undo .
    define variable v-rid-list   as character no-undo .
    if not available X_cash-desk THEN return no-apply.
    DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
    if attr-option = "":U then
    do:
      run gbl/pop-up.p ( input self :handle, input no ) no-error.
      if error-status :error then
      do:
        return no-apply.
      end.
    end.
    if attr-option = "":U then
    do:
      return no-apply.
    end.
    IF attr-option = 'ИЗМЕНЕНИЕ':U THEN
    DO:
      define variable v-cash-desk-host-code as integer no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  X_cash-desk.obj-code
  ,output v-cash-desk-host-code
  )  .
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-change_date_time':U
    ,input  'object':U
    ,input  v-cash-desk-host-code
    ,input  'маг':U
    ,input  X_cash-desk.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-glog
    )  .
end.
      if v-glog then
      do:
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-reference_input-deletion-updating':U
    ,input  'object':U
    ,input  v-cash-desk-host-code
    ,input  'маг':U
    ,input  X_cash-desk.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
        if NOT glog then return no-apply .
      end.
    END.
    if X_cash-desk.pos-type = 'IBS-TH':U then
    do:
      run ref/cda-cc.w ( input parparentproc
        ,input X_cash-desk.db-num
        ,input 'маг':U
        ,input X_cash-desk.obj-code
        ,input X_cash-desk.pos-type
        ,input X_cash-desk.cash-num
        ,input ''
        ,input-output v-rid-list) no-error.
    end.
    else
    do:
      run ref/cd-atti.w (   input parparentproc
        ,input attr-option
        ,input "oper"
        ,input X_cash-desk.db-num
        ,input X_cash-desk.obj-code
        ,input X_cash-desk.pos-type
        ,input X_cash-desk.cash-num
        ,input v-glog
        ) NO-ERROR.
    end.
    attr-option = ''.
  END.
ON CHOOSE OF B-attr-2 IN FRAME Dialog-Frame
  DO:
    define variable v-setted as logical no-undo .
    if not available X_cash-desk THEN return no-apply.
    DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
    if attr-option = "":U then
    do:
      run gbl/pop-up.p ( input self :handle, input no ) no-error.
      if error-status :error then
      do:
        return no-apply.
      end.
    end.
    if attr-option = "":U then
    do:
      return no-apply.
    end.
    IF attr-option = 'ИЗМЕНЕНИЕ':U THEN
    DO:
      define variable v-cash-desk-host-code as integer no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  X_cash-desk.obj-code
  ,output v-cash-desk-host-code
  )  .
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-reference_input-deletion-updating':U
    ,input  'object':U
    ,input  v-cash-desk-host-code
    ,input  'маг':U
    ,input  X_cash-desk.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
      if NOT glog then return no-apply .
    END.
    case X_cash-desk.pos-type:
      when 'IBS-TH':U then
        do:
          run ref/cda-29.w ( input parparentproc
            ,input attr-option
            ,input X_cash-desk.db-num
            ,input X_cash-desk.obj-code
            ,input X_cash-desk.pos-type
            ,input X_cash-desk.cash-num
            ,input ""
            ,input ''
            ,output v-setted) no-error.
        end.
      when 'IBS-TH-MOB':U then
        do:
          run ref/cda-31.w ( input parparentproc
            ,input attr-option
            ,input X_cash-desk.db-num
            ,input X_cash-desk.obj-code
            ,input X_cash-desk.pos-type
            ,input X_cash-desk.cash-num
            ,input ""
            ,input ''
            ,output v-setted) no-error.
        end.
      otherwise
      do:
        run ref/cd-atti.w (   input parparentproc
          ,input attr-option
          ,input "ref"
          ,input X_cash-desk.db-num
          ,input X_cash-desk.obj-code
          ,input X_cash-desk.pos-type
          ,input X_cash-desk.cash-num
          ) NO-ERROR.
      end.
    end case.
    attr-option = ''.
  END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
  DO:
    define variable v-shift-on as character no-undo .
    if not available X_cash-desk THEN return no-apply.
    if X_cash-desk.db-num <> pardb-num then
    do:
      message "Касса принадлежит другой БД"
        view-as alert-box error .
      return no-apply.
    end.
    define variable v-cash-desk-host-code as integer no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  X_cash-desk.obj-code
  ,output v-cash-desk-host-code
  )  .
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-reference_input-deletion-updating':U
    ,input  'object':U
    ,input  v-cash-desk-host-code
    ,input  'маг':U
    ,input  X_cash-desk.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then return no-apply .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  'маг':U
  ,input  X_cash-desk.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
    if l-shift-on then
    do:
      run curshift in this-procedure ( input X_cash-desk.obj-code
        , input no)  no-error.
      if not error-status:error and v-shift-num > 0 then
      do:
        message
          substitute("   Внимание, на объекте &1 открыта смена! &2В этом режиме для редактирования доступны не все свойства ККМ.
                    &2 &2 Продолжить?"
          , X_cash-desk.obj-code
          ,chr(10)
          )
          view-as alert-box question buttons YES-NO update glog.
        if not glog then return no-apply.
        v-shift-on = string(l-shift-on).
      end.
      else
      do:
        v-shift-on = string(no).
      end.
    end.
    rr = recid( X_cash-desk ).
    run ref/cashlsti.w (
      input parparentproc
      ,input 'ИЗМЕНЕНИЕ':U + (if v-shift-on = '' then '' else chr(4)) + v-shift-on
      ,input X_cash-desk.db-num
      ,input X_cash-desk.obj-code
      ,input X_cash-desk.pos-type
      ,input X_cash-desk.cash-num
      , input-output rr ).
    run OpenBr in this-procedure  ( input yes, input no, input '':U).
    reposition br-cash-desk to recid rr .
  END.
ON CHOOSE OF B-cli-attr IN FRAME Dialog-Frame
  DO:
    define variable attr-type           as character no-undo .
    define variable attr-format         as character no-undo .
    define variable attr-label          as character no-undo .
    define variable attr-user-can-edit  as logical   no-undo .
    define variable attr-output-display as logical   no-undo .
    define variable attr-other          as char      no-undo .
    define variable attr-value          as char      no-undo .
    define variable v-prop-list         as character no-undo .
    define variable v-prop-type-list    as character no-undo .
    define variable v-prop-label-list   as character no-undo .
    define variable v-global            as logical   no-undo .
    define variable v-host              as logical   no-undo .
    define variable v-shop              as logical   no-undo .
    define variable v-store             as logical   no-undo .
    define variable v-db                as logical   no-undo .
    define variable v-spr               as character no-undo .
    define variable ii                  as integer   no-undo .
    IF NOT AVAILABLE X_cash-desk  THEN RETURN NO-APPLY.
    run thbjattr_code in this-procedure (
      input ("cd-type-":U +
      (if X_cash-desk.pos-type = 'NCR-AS@R':U
      then "ncr-as-r"
      else (if X_cash-desk.pos-type = 'IPC-Servis+':U
      then "ipc-servispl"
      else X_cash-desk.pos-type)))
      ,input '':U
      ,output attr-label
      ,output attr-user-can-edit
      ,output attr-output-display
      ,output attr-other
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
      ).
    do ii = 1 to num-entries(attr-other, chr(47)):
      if entry(ii, attr-other, chr(47)) begins "spr-ext=":U then
      do:
        assign
          v-spr = entry(2, entry(ii, attr-other, chr(47)), "=").
      end.
    end.
    run value(v-spr)(
      input parparentproc
      ,input 'ПРОСМОТР':U
      ,input 'маг':U
      ,input X_cash-desk.obj-code
      ).
  END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
  DO:
    define buffer check_cash-desk for Ub.cash-desk.
    define buffer buf_db          for ub.db.
    if not available X_cash-desk then return no-apply.
    FIND FIRST check_cash-desk where
      recid(check_cash-desk) = recid(X_cash-desk) no-error.
    if not avail check_cash-desk then return no-apply.
    if check_cash-desk.db-num <> pardb-num then
    do:
      find first buf_db no-lock where
        buf_db.db-num = check_cash-desk.db-num no-error.
      if available buf_db then
      do:
        message "Касса принадлежит другой БД"
          view-as alert-box error .
        return no-apply.
      end.
    end.
    glog = FALSE.
    define variable v-cash-desk-host-code as integer no-undo .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  X_cash-desk.obj-code
  ,output v-cash-desk-host-code
  )  .
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-reference_input-deletion-updating':U
    ,input  'object':U
    ,input  v-cash-desk-host-code
    ,input  'маг':U
    ,input  X_cash-desk.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then return no-apply .
    message
      "Вы уверены?"
      view-as alert-box buttons YES-NO update glog.
    if not glog then return no-apply.
    run ref/cashdsk3.p ( input recid(check_cash-desk)) no-error .
    if error-status:error then
    do:
      message
        substitute("Ошибка при удалении кассы&1&2&1&3"
        ,chr(10)
        , error-status:get-message(1)
        , return-value )
        view-as alert-box error .
      return no-apply.
    end.
    Run Openbr in this-procedure  ( input yes, input no, input '':U).
    APPLY "ENTRY" To browse BR-cash-desk.
  END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
  DO:
    define variable v-rid-list as character no-undo .
    if available X_cash-desk THEN
      run ref/ccshlist.w (
        input parparentproc
        , INPUT "":U
        , INPUT "one":U
        , OUTPUT  v-rid-list
        , INPUT X_cash-desk.db-num
        , INPUT 'маг':U
        , INPUT X_cash-desk.obj-code
        , input X_cash-desk.pos-type
        , input X_cash-desk.cash-num
        , input "":U
        ).
    apply "entry" to br-cash-desk.
  END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
  DO:
    if not available X_cash-desk then return no-apply.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid28 as character no-undo .
define variable v-num-entry28 as integer   no-undo .
assign
  v-str-recid28 = trim( string( recid( X_cash-desk ) , "->>>>>>>>>>>9":U ) )
  v-num-entry28 = lookup( v-str-recid28 , v-rid-list )
.
if v-num-entry28 > 0 then do:
  assign
    entry( v-num-entry28, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid28
  .
end.
    glog = br-cash-desk  :refresh( ) in frame Dialog-Frame.
    if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then
    do:
      glog = br-cash-desk:select-next-row () in frame Dialog-Frame.
      apply "value-changed" to br-cash-desk in frame Dialog-Frame.
    end.
    if num-entries (v-rid-list) = 0 then
      hide mark-num in frame Dialog-Frame.
    else
      disp num-entries (v-rid-list) @ mark-num
        with frame Dialog-Frame.
    apply "entry" to br-cash-desk in frame Dialog-Frame.
  END.
ON CHOOSE OF B-on IN FRAME Dialog-Frame
  DO:
    define variable v-on like ub.cash-desk.cash-on no-undo .
    if not avail X_cash-desk then return no-apply.
    define buffer check_cash-desk for ub.cash-desk.
    if X_cash-desk.db-num <> pardb-num then
    do:
      message "Касса принадлежит другой БД"
        view-as alert-box error .
      return no-apply.
    end.
    FIND FIRST check_cash-desk where
      recid(check_cash-desk) = recid(X_cash-desk) no-error.
    if not avail check_cash-desk then return no-apply.
    if check_cash-desk.obj-code <> parobj-code then
    do:
      message
        "Для включения/выключения кассы " check_cash-desk.cash-num
        "текущим объектом должен быть магазин " check_cash-desk.obj-code
        view-as alert-box ERROR.
      return no-apply.
    end.
    if check_cash-desk.pos-type = 'r-keeper':U then
    do :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-rkeep':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
      if error-status :error
        or conf-par <> 'yes'
        then
      do:
        message
          "В системе запрещена работа с кассами R-Keeper либо отсутсвует конфигурационный параметр is-rkeep" skip
          "Обратитесь к администратору" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply.
      end.
    end.
    glog = FALSE.
    define variable v-cash-desk-host-code as integer no-undo .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  X_cash-desk.obj-code
  ,output v-cash-desk-host-code
  )  .
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-reference_on-off':U
    ,input  'object':U
    ,input  v-cash-desk-host-code
    ,input  'маг':U
    ,input  X_cash-desk.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    if NOT glog then return no-apply .
    message
      "Вы уверены?"
      view-as alert-box buttons YES-NO update glog.
    if not glog then return no-apply.
    rr = recid( check_cash-desk ).
    v-on = ?.
    run ref/cashdsk2.p ( input parparentproc
      , input recid(check_cash-desk)
      , input-output v-on) no-error .
    if error-status:error then
    do:
      if return-value <> "":U then
        message
          return-value
          view-as alert-box .
      return no-apply.
    end.
    Browse br-cash-desk:REFRESH().
    APPLY "ENTRY" To browse br-cash-desk.
  END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
  DO:
    run proc-b-print in this-procedure no-error.
    if error-status:error then return no-apply.
    apply "ENTRY" to br-cash-desk.
  END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
  DO:
    run proc-b-sch in this-procedure no-error.
    if error-status:error then return no-apply.
  END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
  DO:
    if ( available X_cash-desk ) AND ( v-rid-list = "" ) then
      v-rid-list = string( recid( X_cash-desk ) ) .
  END.
ON CHOOSE OF B-shft IN FRAME Dialog-Frame
  DO:
    define variable old-list-mode as char.
    define variable v-shft        as integer no-undo init 0.
    define variable cas-shft      as logical no-undo.
    define buffer check_cash-desk for ub.cash-desk.
    if not available X_cash-desk then return no-apply.
    FIND FIRST check_cash-desk where
      recid(check_cash-desk) = recid(X_cash-desk) no-error.
    if not avail check_cash-desk then return no-apply.
    FIND FIRST ub.shop No-LOCK WHERE
      ub.shop.obj-code = check_cash-desk.obj-code No-ERROR.
    if not avail ub.shop then return no-apply.
    find first ub.sysconf No-LOCK WHERE
      ub.sysconf.host-code = ub.shop.host-code.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type31 as character no-undo .
define variable v-value-character31 as character no-undo .
define variable v-value-date31 as date no-undo .
define variable v-value-decimal31 as decimal no-undo .
define variable v-value-integer31 as INTEGER no-undo .
define variable v-tth31 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  ub.shop.obj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character31
    ,output v-value-date31
    ,output v-value-decimal31
    ,output v-value-integer31
    ,output cas-shft
    ,output v-param-type31
    ,INPUT-OUTPUT table-handle v-tth31
    )  .
delete object v-tth31.
    if cas-shft then
    do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type32 as character no-undo .
define variable v-value-character32 as character no-undo .
define variable v-value-date32 as date no-undo .
define variable v-value-decimal32 as decimal no-undo .
define variable v-value-logical32 as INTEGER no-undo .
define variable v-tth32 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  ub.shop.obj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character32
    ,output v-value-date32
    ,output v-value-decimal32
    ,output v-shft
    ,output v-value-logical32
    ,output v-param-type32
    ,INPUT-OUTPUT table-handle v-tth32
    )  .
delete object v-tth32.
    end.
    if cas-shft  then
    do:
      run ref/shftcshs.w (  input parparentproc
        ,input (if lookup("b-add", bttns) > 0 then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
        ,input 'касс':U
        ,input recid( check_cash-desk )
        ,input  ?
        ,input check_cash-desk.obj-code ) .
    end.
    else
    do:
      message
        "Для магазина, к которому относится касса," skip
        "не ведется таблица кассовых смен!"
        view-as alert-box ERROR.
    end.
    apply "entry" to br-cash-desk.
  END.
ON CHOOSE OF b-version IN FRAME Dialog-Frame
  DO:
    RUN proc-b-version IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  END.
ON CHOOSE OF b-tso IN FRAME Dialog-Frame
  DO:
    run ref/tso-ctrl.w (input parparentproc,
      input parref-mode) .
  END.
ON DEFAULT-ACTION OF BR-cash-desk IN FRAME Dialog-Frame
  DO:
    if b-chg:sensitive THEN apply "CHOOSE":U to b-chg.
    else if b-sel:sensitive then apply "CHOOSE":U to b-sel.
  END.
ON RETURN OF BR-cash-desk IN FRAME Dialog-Frame
  DO:
    apply "DEFAULT-ACTION":U to self.
  END.
ON VALUE-CHANGED OF BR-cash-desk IN FRAME Dialog-Frame
  DO:
    assign
      MENU-ITEM m_lookup-attr:sensitive in menu menu-b-attr     = no
      MENU-ITEM m_update-attr:sensitive in menu menu-b-attr     = no
      MENU-ITEM m_lookup-attr-2:sensitive in menu menu-b-attr-2 = no
      MENU-ITEM m_update-attr-2:sensitive in menu menu-b-attr-2 = no
      .
    IF NOT AVAILABLE X_cash-desk THEN
    DO:
      DISABLE
        b-version
        with FRAME Dialog-Frame.
    END.
    ELSE
    DO:
      CASE X_cash-desk.pos-type:
        WHEN 'IBM-XML':U OR
        WHEN 'Autotank':U THEN
          DO:
            enable
              b-version
              when parref-mode <> 'все':U
              with FRAME Dialog-Frame.
            assign
              MENU-ITEM m_lookup-attr:sensitive in menu menu-b-attr     = yes
              MENU-ITEM m_update-attr:sensitive in menu menu-b-attr     = yes
              MENU-ITEM m_lookup-attr-2:sensitive in menu menu-b-attr-2 = yes
              MENU-ITEM m_update-attr-2:sensitive in menu menu-b-attr-2 = yes
              .
          END.
        when 'IBS-TH':U then
          do:
            assign
              MENU-ITEM m_lookup-attr:sensitive in menu menu-b-attr     = yes
              MENU-ITEM m_update-attr:sensitive in menu menu-b-attr     = no
              MENU-ITEM m_lookup-attr-2:sensitive in menu menu-b-attr-2 = yes
              MENU-ITEM m_update-attr-2:sensitive in menu menu-b-attr-2 = yes
              .
          end.
        OTHERWISE
        DO:
          DISABLE
            b-version
            with FRAME Dialog-Frame.
          assign
            MENU-ITEM m_lookup-attr:sensitive in menu menu-b-attr     = yes
            MENU-ITEM m_update-attr:sensitive in menu menu-b-attr     = yes
            MENU-ITEM m_lookup-attr-2:sensitive in menu menu-b-attr-2 = yes
            MENU-ITEM m_update-attr-2:sensitive in menu menu-b-attr-2 = yes
            .
        END.
      END CASE.
    END.
  END.
ON CHOOSE OF MENU-ITEM m_lookup-attr
  DO:
    assign
      ATTR-option = 'ПРОСМОТР':U
      .
    APPLY "CHOOSE" TO b-attr IN FRAME Dialog-Frame.
  END.
ON CHOOSE OF MENU-ITEM m_lookup-attr-2
  DO:
    assign
      ATTR-option = 'ПРОСМОТР':U
      .
    APPLY "CHOOSE" TO b-attr-2 IN FRAME Dialog-Frame.
  END.
ON CHOOSE OF MENU-ITEM m_update-attr
  DO:
    assign
      ATTR-option = 'ИЗМЕНЕНИЕ':U
      .
    APPLY "CHOOSE" TO b-attr IN FRAME Dialog-Frame.
  END.
ON CHOOSE OF MENU-ITEM m_update-attr-2
  DO:
    assign
      ATTR-option = 'ИЗМЕНЕНИЕ':U
      .
    APPLY "CHOOSE" TO b-attr-2 IN FRAME Dialog-Frame.
  END.
ON VALUE-CHANGED OF Rs-del IN FRAME Dialog-Frame
  DO:
    DEFINE VARIABLE v-rec AS RECID NO-UNDO.
    ASSIGN
      rs-del
      del-mode = rs-del.
    IF AVAILABLE X_cash-desk  THEN
    DO:
      v-rec = RECID(X_cash-desk).
    END.
    run openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
    REPOSITION br-cash-desk  TO RECID v-rec NO-ERROR.
    APPLY "entry" TO br-cash-desk.
  END.
ON VALUE-CHANGED OF Rs-object IN FRAME Dialog-Frame
  DO:
    DEFINE VARIABLE v-rec AS RECID NO-UNDO.
    ASSIGN
      rs-object
      v-mode = rs-object.
    IF AVAILABLE X_cash-desk  THEN
    DO:
      v-rec = RECID(X_cash-desk).
    END.
    RUN openbr IN THIS-PROCEDURE  ( input yes, input no, input '':U).
    REPOSITION br-cash-desk  TO RECID v-rec NO-ERROR.
    APPLY "entry" TO br-cash-desk.
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
  THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-cash-desk :handle
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
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-cash-desk :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   if available X_cash-desk then p-rec = recid(X_cash-desk). Run openbr in this-procedure  ( input yes, input no, input '':U).
    apply "VALUE-CHANGED" to BR-cash-desk.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  FIND FIRST buf_cli No-LOCK WHERE
    buf_cli.obj-type = parobj-type and
    buf_cli.obj-code = parobj-code No-ERROR.
  if not avail buf_cli then
  do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверный вызов - parobj-type=" parobj-type "parobj-code=" parobj-code
      view-as alert-box ERROR.
    return.
  end.
  CASE parref-mode:
    WHEN 'все':U        THEN
      DO:
      END.
    WHen 'объект':U then
      do:
      end.
    when "db":U then
      do:
      end.
    otherwise
    do:
      message vss-workfile vss-revision vss-description skip
        "Неверный вызов - parref-mode=" parref-mode
        view-as alert-box ERROR.
      return.
    end.
  end case.
  v-mode = parref-mode.
  if v-mode = 'все':U then del-mode = ?.
  else del-mode = no.
  RUN MyEnable in this-procedure .
  HIDE mark-num in frame Dialog-Frame .
  run OpenBR in this-procedure  ( input yes, input no, input '':U).
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE curshift :
  DEFINE INPUT PARAMETER shop-code like ub.cash-desk.obj-code no-undo.
  DEFINE INPUT PARAMETER silence as logical no-undo.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  'маг':U
  ,input  shop-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
  if error-status:error then
  do:
    if silence then
      message return-value view-as alert-box ERROR.
    return error return-value.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY mark-num Rs-object Rs-del
    WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-add B-chg B-del B-on B-shft B-attr B-print
    B-hist B-sch B-Help mark-num Rs-object Rs-del B-cli-attr B-attr-2
    b-version BR-cash-desk b-tso
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
  ASSIGN
    b-attr:MENU-MOUSE IN frame Dialog-Frame       = 1
    b-attr-2:MENU-MOUSE IN frame Dialog-Frame     = 1
    rs-object:RADIO-BUTTONS IN FRAME Dialog-Frame = (IF parref-mode = 'все':U AND v-cntxt-db-num = 0
                                                  THEN ("Все" + chr(44) + 'все':U + chr(44) +
                                                      "БД" + chr(44) + 'db':U + chr(44) +
                                                        parobj-type + string(parobj-code) + chr(44) + 'объект':U)
                                                  ELSE ("БД" + chr(44) + 'db':U + chr(44) +
                                                        parobj-type + string(parobj-code) + chr(44) + 'объект':U))
    rs-del                                         = del-mode.
  DISPLAY
    mark-num
    rs-del
    WITH FRAME Dialog-Frame .
  ENABLE
    B-quit
    B-mark
    when lookup('b-mark':U, bttns) >0
    B-sel
    when lookup('b-sel':U, bttns) >0
    B-add
    when lookup('b-add':U, bttns) >0 and parref-mode <> 'все':U AND NOT TRANSACTION
    B-chg
    when lookup('b-add':U, bttns) >0 and parref-mode <> 'все':U AND NOT TRANSACTION
    B-del
    when lookup('b-add':U, bttns) >0 and parref-mode <> 'все':U AND NOT TRANSACTION
    B-on
    when lookup('b-on':U, bttns) >0 and parref-mode <> 'все':U AND NOT TRANSACTION
    B-version
    when lookup('b-add':U, bttns) >0 and parref-mode <> 'все':U AND NOT TRANSACTION
    b-tso
    b-attr
    b-attr-2
    b-cli-attr
    B-shft
    B-sch
    B-print
    B-hist
    B-Help
    rs-object
    rs-del
    WHEN parref-mode <> 'все':U
    BR-cash-desk
    mark-num
    WITH FRAME Dialog-Frame .
  VIEW FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE OpenBr :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable l-query-was-opened as logical   no-undo .
  define variable sort-column-phrase as character no-undo .
  case sort-column-name :
    when "" then
      do:
        assign
          sort-column-phrase = ""
          .
      end.
    otherwise
    do:
      assign
        sort-column-phrase = "by " + sort-column-name
        .
    end.
  end case.
  CASE v-mode:
    when 'все':U then
      do:
        CASE del-mode :
          WHEN ? THEN
            DO:
              ASSIGN
                frame Dialog-Frame:TITLE = "Справочник касс"
                filter-point              = filter-point0 + parref-mode.
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
                              "FOR EACH X_cash-desk"
      parameter-4-42 =
        (
          if (" TRUE " + " " + where-phrase-42) <> ""
          then " TRUE " + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "")
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_cash-desk.db-num by X_cash-desk.obj-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-42
        )
      parameter-7-42 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-42 =
          (" TRUE " + " " + where-phrase-42 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-cash-desk:handle
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
    OPEN QUERY br-cash-desk FOR EACH X_cash-desk
      where  TRUE
       by X_cash-desk.db-num by X_cash-desk.obj-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
            END.
          WHEN NO THEN
            DO:
              ASSIGN
                frame Dialog-Frame:TITLE = "Справочник касс - неудаленные"
                filter-point              = filter-point0 + parref-mode.
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
                              "FOR EACH X_cash-desk"
      parameter-4-44 =
        (
          if (" X_cash-desk.is-del = no " + " " + where-phrase-44) <> ""
          then " X_cash-desk.is-del = no " + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "")
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_cash-desk.db-num by X_cash-desk.obj-code "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-44 =
          (" X_cash-desk.is-del = no " + " " + where-phrase-44 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-cash-desk:handle
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
    OPEN QUERY br-cash-desk FOR EACH X_cash-desk
      where  X_cash-desk.is-del = no
       by X_cash-desk.db-num by X_cash-desk.obj-code
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
            END.
        END CASE.
      end.
    when 'объект':U then
      do:
        CASE del-mode:
          WHEN ? THEN
            DO:
              ASSIGN
                frame Dialog-Frame:TITLE = substitute("Справочник касс &1&2 &3"
                                                      ,parobj-type
                                                      ,parobj-code
                                                      ,buf_cli.obj-name).
              filter-point = filter-point0 + parref-mode.
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
                              "FOR EACH X_cash-desk"
      parameter-4-46 =
        (
          if (" X_cash-desk.obj-code = parobj-code " + " " + where-phrase-46) <> ""
          then  substitute('X_cash-desk.obj-code = &1', parobj-code)  + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + "")
      parameter-6-46 = if sort-phrase-46 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_cash-desk.cash-num "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-46
        )
      parameter-7-46 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-46 =
          (" X_cash-desk.obj-code = parobj-code " + " " + where-phrase-46 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-cash-desk:handle
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
    OPEN QUERY br-cash-desk FOR EACH X_cash-desk
      where  X_cash-desk.obj-code = parobj-code
       by X_cash-desk.cash-num
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
            END.
          WHEN NO THEN
            DO:
              ASSIGN
                frame Dialog-Frame:TITLE = substitute("Справочник касс &1&2 &3 - неудаленные"
                                                        ,parobj-type
                                                        ,parobj-code
                                                        ,buf_cli.obj-name).
              filter-point = filter-point0 + parref-mode.
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
                              "FOR EACH X_cash-desk"
      parameter-4-48 =
        (
          if (" X_cash-desk.obj-code = parobj-code and X_cash-desk.is-del = no " + " " + where-phrase-48) <> ""
          then  substitute('X_cash-desk.obj-code = &1 and X_cash-desk.is-del = no', parobj-code)  + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + "")
      parameter-6-48 = if sort-phrase-48 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_cash-desk.cash-num "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-48
        )
      parameter-7-48 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-48 =
          (" X_cash-desk.obj-code = parobj-code and X_cash-desk.is-del = no " + " " + where-phrase-48 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-cash-desk:handle
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
    OPEN QUERY br-cash-desk FOR EACH X_cash-desk
      where  X_cash-desk.obj-code = parobj-code and X_cash-desk.is-del = no
       by X_cash-desk.cash-num
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
            END.
        END CASE.
      end.
    when "db":U then
      do:
        CASE del-mode:
          WHEN ?  THEN
            DO:
              ASSIGN
                frame Dialog-Frame:TITLE = substitute("Справочник касс БД: &1", pardb-num).
              filter-point = filter-point0 + parref-mode.
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
                              "FOR EACH X_cash-desk"
      parameter-4-50 =
        (
          if (" X_cash-desk.db-num = pardb-num " + " " + where-phrase-50) <> ""
          then  substitute('X_cash-desk.db-num = &1', pardb-num)  + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + "")
      parameter-6-50 = if sort-phrase-50 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_cash-desk.db-num by X_cash-desk.obj-code by X_cash-desk.cash-num "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-50
        )
      parameter-7-50 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-50 =
          (" X_cash-desk.db-num = pardb-num " + " " + where-phrase-50 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-cash-desk:handle
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
    OPEN QUERY br-cash-desk FOR EACH X_cash-desk
      where  X_cash-desk.db-num = pardb-num
       by X_cash-desk.db-num by X_cash-desk.obj-code by X_cash-desk.cash-num
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
            END.
          WHEN NO THEN
            DO:
              ASSIGN
                frame Dialog-Frame:TITLE = substitute("Справочник касс БД: &1 - неудаленные", pardb-num).
              filter-point = filter-point0 + parref-mode.
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
                              "FOR EACH X_cash-desk"
      parameter-4-52 =
        (
          if (" X_cash-desk.db-num = pardb-num and X_cash-desk.is-del = no " + " " + where-phrase-52) <> ""
          then  substitute('X_cash-desk.db-num = &1 and X_cash-desk.is-del = no ', pardb-num)  + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + "")
      parameter-6-52 = if sort-phrase-52 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_cash-desk.db-num by X_cash-desk.is-del by X_cash-desk.obj-code by X_cash-desk.cash-num "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-52
        )
      parameter-7-52 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-52 =
          (" X_cash-desk.db-num = pardb-num and X_cash-desk.is-del = no " + " " + where-phrase-52 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-cash-desk:handle
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
    OPEN QUERY br-cash-desk FOR EACH X_cash-desk
      where  X_cash-desk.db-num = pardb-num and X_cash-desk.is-del = no
       by X_cash-desk.db-num by X_cash-desk.is-del by X_cash-desk.obj-code by X_cash-desk.cash-num
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
            END.
        END CASE.
      end.
  END CASE.
  apply "entry" to br-cash-desk in frame Dialog-Frame.
  if p-rec <> ? then reposition br-cash-desk to recid p-rec no-error.
  if error-status:error then
  do:
    reposition br-cash-desk to row 1 no-error.
  end.
  run waitfram-hide in this-procedure .
  if avail X_cash-desk then
    APPLY "VALUE-CHANGED":U to br-cash-desk.
END PROCEDURE.
PROCEDURE proc-b-print :
  define VARIABLE p-report-id         as character no-undo .
  define variable v-file-name-rep-htm as character no-undo .
  run get-report-num (output p-report-id).
  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".
  define variable ii              as integer   no-undo.
  define variable StartRecid      as integer   no-undo.
  define variable v-fo-version    as CHARACTER no-undo.
  define variable v-OptVer        as CHARACTER no-undo.
  define variable v-ffd-version   as CHARACTER no-undo.
  define variable v-GISMT_TIMEOUT as CHARACTER no-undo.
  define variable v-GISMT_FAST    as CHARACTER no-undo.
  define variable v-date          as CHARACTER no-undo.
  define variable v-time          as CHARACTER no-undo.
  define variable v-kkt-schema    as CHARACTER no-undo.
  define variable v-autonomy      as character no-undo .
  define variable v-addr-path     as character no-undo .
  define variable v-signExecution as character no-undo .
  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    .
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
  put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 20px;"></td>' skip
    '<td style="width: 40px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '</tr>' skip
    .
  put stream OutStr-html unformatted
    '<TR><TD colspan="18"></TD></TR>' skip
    '<TR>' skip
    '<Td colspan="18" style="height: 14px; text-align: center; font-weight: bold;">СПРАВОЧНИК КАСС</Td>' skip
    '</TR>'skip
    '</thead>' skip
    '<tbody>' skip
    '<tr>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Магазин</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">БД</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Номер</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Тип POS</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Активность</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Адрес (путь к кассе)</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Тип ОС</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Признак исполнения</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Статус</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Удаленная дистанционно</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Версия протокола</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Версия кассовой программы</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Версия ПО «Коннектор»</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Схема интеграции ККТ</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Версия ФФД</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Таймаут ответа ГИСМТ</th>' skip
    '<th rowspan="2" text_wrap="true" style="text-align: center;">Быстрый ответ ГИСМТ</th>' skip
    '<th colspan="2" text_wrap="true" style="text-align: center;">Дата/время последнего опроса касс</th>' skip
    '</tr>' skip
    '<tr>' skip
    '<td text_wrap="true" style="text-align: center;">Дата</td>' skip
    '<td text_wrap="true" style="text-align: center;">Время</td>' skip
    '</tr>' skip
    .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="text-align: center;">1</td>' skip
    '<td style="text-align: center;">2</td>' skip
    '<td style="text-align: center;">3</td>' skip
    '<td style="text-align: center;">4</td>' skip
    '<td style="text-align: center;">5</td>' skip
    '<td style="text-align: center;">6</td>' skip
    '<td style="text-align: center;">7</td>' skip
    '<td style="text-align: center;">8</td>' skip
    '<td style="text-align: center;">9</td>' skip
    '<td style="text-align: center;">10</td>' skip
    '<td style="text-align: center;">11</td>' skip
    '<td style="text-align: center;">12</td>' skip
    '<td style="text-align: center;">13</td>' skip
    '<td style="text-align: center;">14</td>' skip
    '<td style="text-align: center;">15</td>' skip
    '<td style="text-align: center;">16</td>' skip
    '<td style="text-align: center;">17</td>' skip
    '<td style="text-align: center;">18</td>' skip
    '<td style="text-align: center;">19</td>' skip
    '</tr>' skip
    .
  define variable vQuery as handle no-undo.
  vQuery = query br-cash-desk:handle.
  do while available X_cash-desk:
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td text_wrap="true" style="text-align: center;">' + string(X_cash-desk.obj-code) + '</td>' skip
      '<td text_wrap="true" style="text-align: center;">' + string(X_cash-desk.db-num) + '</td>' skip
      '<td text_wrap="true" style="text-align: center;">' + string(X_cash-desk.cash-num) + '</td>' skip
      '<td text_wrap="true" style="text-align: center;">' + string(X_cash-desk.pos-type) + '</td>' skip
      .
    case X_cash-desk.autonomy:
      when 0 then
        v-autonomy = 'Автономная касса':U .
      when 1 then
        v-autonomy = 'Подчиненная касса':U .
      when 2 then
        v-autonomy = 'Кассовый менеджер':U .
    end case .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + v-autonomy  + '</td>' skip .
    if X_cash-desk.pos-type = 'IBM-XML':U or X_cash-desk.pos-type = 'Autotank':U then
    do:
      if num-entries(X_cash-desk.addr-path, chr(4)) > 1 then
        v-addr-path = (entry(1, X_cash-desk.addr-path, chr(4)) + ":\\":U + entry(2, X_cash-desk.addr-path, chr(4))) .
      else v-addr-path = X_cash-desk.addr-path .
    end.
    else v-addr-path = X_cash-desk.addr-path .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + string(v-addr-path) + '</td>' skip
      '<td text_wrap="true" style="text-align: center;">' + string(X_cash-desk.cash-os) + '</td>' skip
      .
    v-signExecution = signExecution(X_cash-desk.device-kind) .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + string(v-signExecution) + '</td>' skip
      .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + string(if X_cash-desk.is-del then 'удал':U else 'тек':U) + '</td>' skip
      '<td text_wrap="true" style="text-align: center;">' + string((if X_cash-desk.remote = 1 then '+' else ' ')) + '</td>' skip
      '<td text_wrap="true" style="text-align: center;">' + if X_cash-desk.version <> ? then string(X_cash-desk.version) + '</td>' else "" + '</td>'skip
      .
    v-fo-version = get-fo-version( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) .
    if v-fo-version = ? then v-fo-version = "" .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + string(v-fo-version) + '</td>' skip
      .
    v-OptVer = get-OptVer( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) .
    if (v-OptVer = ? or v-OptVer = '?') then v-OptVer = "" .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + v-OptVer + '</td>' skip
      .
    v-kkt-schema = get-kkt-schema( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) .
    if v-kkt-schema = ? then v-kkt-schema = " - " .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + string(v-kkt-schema) + '</td>' skip
      .
    v-ffd-version = get-ffd-version( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) .
    if v-ffd-version = ? then v-ffd-version = " - " .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + string(v-ffd-version) + '</td>' skip
      .
    v-GISMT_TIMEOUT = string(get-GISMT_TIMEOUT( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)) .
    if v-GISMT_TIMEOUT = ? then v-GISMT_TIMEOUT = " - " .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + string(v-GISMT_TIMEOUT) + '</td>' skip
      .
    v-GISMT_FAST = string(get-GISMT_FAST( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num)) .
    if v-GISMT_FAST = ? then v-GISMT_FAST = " - " .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + string(v-GISMT_FAST) + '</td>' skip
      .
    v-date = get-date( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) .
    if v-date = "" then v-date = " - " .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + string(v-date) + '</td>' skip
      .
    v-time = get-time( X_cash-desk.db-num, X_cash-desk.obj-code, X_cash-desk.pos-type, X_cash-desk.cash-num) .
    if v-time = "" then v-time = " - " .
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="text-align: center;">' + string(v-time) + '</td>' skip
      .
    put stream OutStr-html unformatted
      '</tr>' skip
      .
    ii =  ii + 1 .
    if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
    do:
      run waitfram-show in this-procedure ( "Просмотрено строк : " + string( ii ) ) .
    end.
    GET NEXT br-cash-desk.
  END.
  put stream OutStr-html unformatted
    '</tbody>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
  output stream OutStr-html close.
  run prn-lib-reportviewer-report-name in this-procedure (
    input parparentproc
    ,input v-file-name-rep-htm
    ) .
  if error-status:error then
  do:
    message return-value view-as alert-box.
    return .
  end.
  run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE proc-b-sch :
  assign
    tbl      = 'cash-desk'
    join-tbl = 'X_cash-desk'
    fld      = ""
    lab      = ""
    spr      = ""
    dim      = '0'
    .
  run fltfield-add in this-procedure('autonomy', 'Активность', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('db-num', 'БД', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-code', 'Код объекта', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cash-num', 'Номер', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pos-type', 'Тип POS', 'cd-types-real',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cash-on', 'Вкл', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('addr-path', 'Адрес (путь к кассе)', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('is-del', 'Удал.?', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('registration-code', 'Регистрационный №', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('serial-code', 'Серийный №', '',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('device-kind', 'Признак исполнения', 'cd-device-kind',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  DO on stop undo, leave:
    run gbl/filter.w ( input parparentproc
      ,input (filter-point0 + parref-mode + chr(4) +
      filter-label  + chr(4) +
      string(yes))
      ,input tbl
      ,input join-tbl
      ,input fld
      ,input lab
      ,input spr
      ,input dim).
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
  END .
END PROCEDURE.
PROCEDURE proc-b-version :
  define variable v-uniq-key-rec as character no-undo .
  define variable glog           as logical   no-undo .
  message
    substitute("Проверить и изменить в справочнике касс (если неверная) версию ПО для кассы &1", X_cash-desk.cash-num)
    view-as alert-box question buttons yes-no update glog.
  if not glog then return.
  run gen-key-rec in this-procedure ( input 'cash-desk':U
    ,input (buffer X_cash-desk:handle)
    ,output v-uniq-key-rec).
  run str/diallog.w ( input parparentproc
    ,input this-procedure
    ,input 'str/get-chkf.p':U
    ,input (v-cntxt-obj-type + chr(4) +
    string(v-cntxt-obj-code) + chr(4) +
    string(0) + chr(4) +
    string(0) + chr(4) +
    chr(4) +
    chr(4) +
    chr(4) +
    substitute("&1=version,&2"
    ,X_cash-desk.pos-type
    ,v-uniq-key-rec)
    )
    ,input no
    ,input ''
    ,input 'Получение версии ПО кассы') .
  run OpenBr in this-procedure  ( input yes, input no, input '':U).
END PROCEDURE.
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.
END PROCEDURE.
FUNCTION cash-desk-auto RETURNS CHARACTER
  ( p-autonomy AS INTEGER ) :
  RETURN entry (lookup (string(p-autonomy), '0,1,2':U), 'Автономная касса,Подчиненная касса,Кассовый менеджер':U).
END FUNCTION.
FUNCTION signExecution RETURNS CHARACTER
  ( INPUT p-device-kind AS INTEGER) :
  return mdevice:GetLabel(integer(p-device-kind)).
END FUNCTION.
FUNCTION get-fo-version RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-fo-version AS CHARACTER NO-UNDO.
  define variable v-date       as date      no-undo .
  define variable v-decimal    as decimal   no-undo .
  define variable v-integer    as integer   no-undo .
  define variable v-logical    as logical   no-undo .
  run cd-attr-value in this-procedure (
    input   p-db-num
    ,input  p-obj-code
    ,input  p-pos-type
    ,input  p-cash-num
    ,input  (if p-pos-type = 'IBM-XML':U
    then 'IBM-XML_operative':U
    else 'AUTOTANK_operative':U)
    ,input  (if p-pos-type = 'IBM-XML':U
    then 'fo-version':U
    else 'fo-version':U)
    ,output v-fo-version
    ,output v-date
    ,output v-decimal
    ,output v-integer
    ,output v-logical
    ,output v-dop) no-error.
  RETURN v-fo-version.
END FUNCTION.
FUNCTION get-OptVer RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-OptVer     AS CHARACTER NO-UNDO.
  define variable v-date       as date      no-undo .
  define variable v-decimal    as decimal   no-undo .
  define variable v-integer    as integer   no-undo .
  define variable v-logical    as logical   no-undo .
  run cd-attr-value in this-procedure (
    input   p-db-num
    ,input  p-obj-code
    ,input  p-pos-type
    ,input  p-cash-num
    ,input  (if p-pos-type = 'IBM-XML':U
    then 'IBM-XML_operative':U
    else 'AUTOTANK_operative':U)
    ,input  (if p-pos-type = 'IBM-XML':U
    then 'OptVer':U
    else 'OptVer':U)
    ,output v-OptVer
    ,output v-date
    ,output v-decimal
    ,output v-integer
    ,output v-logical
    ,output v-dop) no-error.
  RETURN v-OptVer.
END FUNCTION.
FUNCTION get-ffd-version RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop          AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-ffd-version  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-kkt-version  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-ffd-version_ AS CHARACTER NO-UNDO.
  define variable v-date         as date      no-undo .
  define variable v-decimal      as decimal   no-undo .
  define variable v-integer      as integer   no-undo .
  define variable v-logical      as logical   no-undo .
  run cd-attr-value in this-procedure (
    input   p-db-num
    ,input  p-obj-code
    ,input  p-pos-type
    ,input  p-cash-num
    ,input  (if p-pos-type = 'IBM-XML':U
    then 'IBM-XML_operative':U
    else 'AUTOTANK_operative':U)
    ,input  'USE_FFD_VERSION':U
    ,output v-ffd-version
    ,output v-date
    ,output v-decimal
    ,output v-integer
    ,output v-logical
    ,output v-dop) no-error.
  case v-ffd-version :
    when "0" then
      do:
        run cd-attr-value in this-procedure (
          input   p-db-num
          ,input  p-obj-code
          ,input  p-pos-type
          ,input  p-cash-num
          ,input  (if p-pos-type = 'IBM-XML':U
          then 'IBM-XML_operative':U
          else 'AUTOTANK_operative':U)
          ,input  'KKT_FFD_VERSION':U
          ,output v-kkt-version
          ,output v-date
          ,output v-decimal
          ,output v-integer
          ,output v-logical
          ,output v-dop) no-error.
        if error-status:error or v-kkt-version = "0" or v-kkt-version = "" then v-ffd-version_ = "авт" .
        else
        do:
          case v-kkt-version:
            when "2" then
              v-ffd-version_ = "1.05(авт)" .
            when "3" then
              v-ffd-version_ = "1.1(авт)" .
            when "4" then
              v-ffd-version_ = "1.2(авт)" .
          end case.
        end.
      end.
    when "2" then
      v-ffd-version_ = "1.05" .
    when "3" then
      v-ffd-version_ = "1.1" .
    when "4" then
      v-ffd-version_ = "1.2" .
    otherwise
    v-ffd-version_ = " - " .
  end case .
  RETURN v-ffd-version_.
END FUNCTION.
FUNCTION get-kkt-schema RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-kkt-schema  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-kkt-schema_ AS CHARACTER NO-UNDO.
  define variable v-date        as date      no-undo .
  define variable v-decimal     as decimal   no-undo .
  define variable v-integer     as integer   no-undo .
  define variable v-logical     as logical   no-undo .
  run cd-attr-value in this-procedure (
    input   p-db-num
    ,input  p-obj-code
    ,input  p-pos-type
    ,input  p-cash-num
    ,input  (if p-pos-type = 'IBM-XML':U
    then 'IBM-XML_operative':U
    else 'AUTOTANK_operative':U)
    ,input  'KKT_SCHEMA':U
    ,output v-kkt-schema
    ,output v-date
    ,output v-decimal
    ,output v-integer
    ,output v-logical
    ,output v-dop) no-error.
  case v-kkt-schema :
    when "0" then
      v-kkt-schema_ = "с ожиданием ответа" .
    when "1" then
      v-kkt-schema_ = "без ожидания ответа" .
    otherwise
    v-kkt-schema_ = " - " .
  end case .
  RETURN v-kkt-schema_.
END FUNCTION.
FUNCTION get-date RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop             AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-last-date-polls AS CHARACTER NO-UNDO.
  define variable v-date            as date      no-undo .
  define variable v-decimal         as decimal   no-undo .
  define variable v-integer         as integer   no-undo .
  define variable v-logical         as logical   no-undo .
  run cd-attr-value in this-procedure (
    input   p-db-num
    ,input  p-obj-code
    ,input  p-pos-type
    ,input  p-cash-num
    ,input  (if p-pos-type = 'IBM-XML':U
    then 'IBM-XML_operative':U
    else 'AUTOTANK_operative':U)
    ,input  'last-date-polls':U
    ,output v-last-date-polls
    ,output v-date
    ,output v-decimal
    ,output v-integer
    ,output v-logical
    ,output v-dop) no-error.
  RETURN v-last-date-polls.
END FUNCTION.
FUNCTION get-time RETURNS CHARACTER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop             AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-last-time-polls AS CHARACTER NO-UNDO.
  define variable v-date            as date      no-undo .
  define variable v-decimal         as decimal   no-undo .
  define variable v-integer         as integer   no-undo .
  define variable v-logical         as logical   no-undo .
  run cd-attr-value in this-procedure (
    input   p-db-num
    ,input  p-obj-code
    ,input  p-pos-type
    ,input  p-cash-num
    ,input  (if p-pos-type = 'IBM-XML':U
    then 'IBM-XML_operative':U
    else 'AUTOTANK_operative':U)
    ,input  'last-time-polls':U
    ,output v-last-time-polls
    ,output v-date
    ,output v-decimal
    ,output v-integer
    ,output v-logical
    ,output v-dop) no-error.
  RETURN v-last-time-polls.
END FUNCTION.
FUNCTION get-GISMT_FAST RETURNS INTEGER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop               AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-GISMT_FAST_ANSWER AS INTEGER   no-undo init ?.
  find first ub.cash-desk-attr no-lock where ub.cash-desk-attr.attr-code = 'GISMT_FAST_ANSWER':U and
    ub.cash-desk-attr.cash-num = p-cash-num and
    ub.cash-desk-attr.db-num = p-db-num and
    ub.cash-desk-attr.obj-code = p-obj-code no-error .
  if available (ub.cash-desk-attr) then v-GISMT_FAST_ANSWER = integer(ub.cash-desk-attr.attr-value-character) .
  RETURN v-GISMT_FAST_ANSWER.
END FUNCTION.
FUNCTION get-GISMT_TIMEOUT RETURNS INTEGER
  ( INPUT p-db-num AS INTEGER
  ,INPUT p-obj-code AS INTEGER
  ,INPUT p-pos-type AS CHARACTER
  ,INPUT  p-cash-num AS INTEGER) :
  DEFINE VARIABLE v-dop                   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-GISMT_CHECK_TIMEOUT   AS INTEGER   no-undo init ?.
  DEFINE VARIABLE v-GISMT_OPENCON_TIMEOUT AS INTEGER   no-undo init ?.
  DEFINE VARIABLE v-GISMT_TIMEOUT         AS INTEGER   no-undo init ?.
  find first ub.cash-desk-attr no-lock where ub.cash-desk-attr.attr-code = 'GISMT_CHECK_TIMEOUT':U and
    ub.cash-desk-attr.cash-num = p-cash-num and
    ub.cash-desk-attr.db-num = p-db-num and
    ub.cash-desk-attr.obj-code = p-obj-code no-error .
  if available (ub.cash-desk-attr) then v-GISMT_CHECK_TIMEOUT = integer(ub.cash-desk-attr.attr-value-character) .
  find first ub.cash-desk-attr no-lock where ub.cash-desk-attr.attr-code = 'GISMT_OPENCON_TIMEOUT':U and
    ub.cash-desk-attr.cash-num = p-cash-num and
    ub.cash-desk-attr.db-num = p-db-num and
    ub.cash-desk-attr.obj-code = p-obj-code no-error .
  if available (ub.cash-desk-attr) then v-GISMT_OPENCON_TIMEOUT = integer(ub.cash-desk-attr.attr-value-character) .
  v-GISMT_TIMEOUT = v-GISMT_OPENCON_TIMEOUT + v-GISMT_CHECK_TIMEOUT .
  RETURN v-GISMT_TIMEOUT.
END FUNCTION.
