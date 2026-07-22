DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_dis-card FOR ub.dis-card.
DEFINE BUFFER buf_inkas FOR ub.inkas.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER c-doc FOR ub.chk-doc.
DEFINE BUFFER chk-gds FOR ub.chk-gds.
DEFINE BUFFER dis-obj FOR ub.dis-obj.
DEFINE BUFFER find_chk-gds FOR ub.chk-gds.
DEFINE BUFFER find_inkas FOR ub.inkas.
define input parameter parparentproc as widget-handle no-undo .
define input parameter b-c like ub.bar-code.b-code no-undo.
define input parameter bttns  as char   no-undo .
define input parameter par-mode  as char   no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parout-code like ub.chk-doc.out-code no-undo.
define input parameter pard-card like ub.chk-doc.d-card no-undo.
define output param rid-list    as  char no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список чеков по бар-коду":U.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
function shift-name-no-err return char (
                                        buffer loc-chk-doc for ub.chk-doc
 ).
define variable varshift-name as character no-undo.
define variable varshift-name-num as character no-undo.
  varshift-name = loc-chk-doc.shift-name.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnme in g#lib-trn3 ( input  loc-chk-doc.obj-type,
                       input  loc-chk-doc.obj-code,
                       input  loc-chk-doc.shift-date,
                       input  loc-chk-doc.shift-num,
                       input-output varshift-name,
                       output varshift-name-num
                       ) no-error .
  if error-status:error then do:
    return "":u.
  end.
  return varshift-name-num.
end function.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable filter-point as character no-undo  .
define variable filter-point0 as character no-undo   .
define variable filter-label as character no-undo init "Список чеков по бар-коду" .
define variable filter-label0 as character no-undo  init "Список чеков по бар-коду" .
assign
filter-point0 = ('соб-БК':U + chr(44) + 'чеки':U)
.
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define  variable cas-shft as logical no-undo init no.
DEFINE VARIABLE v-cycle as logical no-undo .
DEFINE VARIABLE v-one-time as logical no-undo .
DEFINE VARIABLE deleted as logical no-undo .
define variable del-type as character no-undo.
define variable v-curr-r-b as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-print-host-code like ub.sysconf.host-code no-undo.
define variable p-chk-type like ub.chk-doc.chk-type no-undo .
define variable v-inkas-host-code as integer no-undo .
define variable v-inkas-obj-type as character no-undo .
define variable v-inkas-obj-code as integer no-undo .
define buffer buf_cli for ub.clients.
define buffer out_inkas for ub.inkas .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_gds-prt for ub.gds-prt.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def temp-table gds-bar no-undo
field b-code like ub.bar-code.b-code
field qnty   as decimal
index art is unique b-code .
DEFINE MENU m-print
       MENU-ITEM m-gds          LABEL "Список строк чеков"
       RULE
       MENU-ITEM m-one-time     LABEL "Игнорировать повторение строк чеков"
              TOGGLE-BOX
       MENU-ITEM m-list         LABEL "Список чеков"
       RULE
       MENU-ITEM m-one          LABEL "Чек"
       MENU-ITEM m-spcf         LABEL "Спецификация"  .
DEFINE MENU MENU-B-del
       MENU-ITEM m_one          LABEL "Один чек"
       MENU-ITEM m_list         LABEL "Список чеков"  .
DEFINE BUTTON b-allgood
     LABEL "Все &БК"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "Искл&ючить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sale
     LABEL "П&родажа"
     SIZE 10 BY 1.
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE Cb-chk-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 19 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(20)":U
     LABEL "номеру"
     VIEW-AS FILL-IN
     SIZE 19.1 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999":U
     LABEL "дате"
     VIEW-AS FILL-IN
     SIZE 11.6 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-price AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "цене"
     VIEW-AS FILL-IN
     SIZE 19.1 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE RS-sort AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Без сортировки/по фильтру", "unsort",
"По коду чека в БД", "doc-code"
     SIZE 51.9 BY 1.13 NO-UNDO.
DEFINE QUERY BR-docs FOR
                ub.chk-gds,
                ub.c-doc SCROLLING.
DEFINE BROWSE BR-docs
  QUERY BR-docs DISPLAY
      c-doc.office FORMAT "X(7)":U
  mark-string(recid(chk-gds), rid-list) COLUMN-LABEL '*' FORMAT "X(1)":U
  c-doc.doc-code COLUMN-LABEL "Номер_чека" FORMAT "X(20)":U
  entry (lookup (string(c-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U) COLUMN-LABEL 'Тип_чека' FORMAT "X(8)":U
  chk-gds.line-num COLUMN-LABEL "NN" FORMAT "->>9":U
  c-doc.chk-num COLUMN-LABEL "N_по_кассе" FORMAT "->>>>>>>>9":U
  c-doc.chk-date FORMAT "99/99/9999":U
  (string (c-doc.chk-time, 'HH:MM')) COLUMN-LABEL 'Время'
  chk-gds.doc-qnty FORMAT "->>,>>>,>>9.<<<":U
  chk-gds.price-base FORMAT "->>>,>>>,>>9.99":U
  chk-gds.discnt FORMAT "->>>,>>>,>>9.99":U
  (chk-gds.discnt / chk-gds.price-base * 100) COLUMN-LABEL '%' FORMAT "->>9.<%":U
  (chk-gds.price-base - chk-gds.discnt) COLUMN-LABEL 'Нетто цена' FORMAT "->>>,>>>,>>9.99":U
  chk-gds.pump COLUMN-LABEL 'ТРК' FORMAT ">9":U
  chk-gds.nozzle-code COLUMN-LABEL 'Пист' FORMAT ">>9":U
  chk-gds.loc1 COLUMN-LABEL 'Рез' FORMAT "X(3)":U
  entry (lookup (string(chk-gds.write-off-code),  '?,0,1,-6,-9,2,-2,3,-3,-4,17':U), ',,Без_оплаты,Отмена_позиции,Полн_Отмена,Модификатор,Модификатор,Модификатор(+спис),Модификатор(-спис),Модификатор(-спис),Техпролив':U) COLUMN-LABEL 'Код_спис' FORMAT "X(10)":U
  c-doc.shift-date COLUMN-LABEL "Смена_от" FORMAT "99/99/9999":U
 shift-name-no-err( buffer c-doc) COLUMN-LABEL "№_см." FORMAT "X(6)":U
  c-doc.shift-date COLUMN-LABEL "Смена_от" FORMAT "99/99/9999":U
  c-doc.shift-num COLUMN-LABEL "П" FORMAT ">9":U
  c-doc.netto COLUMN-LABEL "Сумма_оплат" FORMAT "->>>,>>>,>>9.99":U
  c-doc.tot-doc COLUMN-LABEL "Сумма_товарная" FORMAT "->>>,>>>,>>9.99":U
  c-doc.discnt COLUMN-LABEL "Скидка_общая" FORMAT "->>>,>>>,>>9.99":U
  c-doc.sub-discnt COLUMN-LABEL "Списания" FORMAT "->>>,>>>,>>9.99":U
  c-doc.pay-desk FORMAT ">>>9":U
  c-doc.cashier FORMAT "99999":U
  c-doc.sales-man COLUMN-LABEL "Прод-w" FORMAT "99999":U
  c-doc.out-code COLUMN-LABEL "Номер_РН" FORMAT "X(14)":U
  c-doc.d-card COLUMN-LABEL "N_диск._карты" FORMAT "X(19)":U
  c-doc.doc-num COLUMN-LABEL "№_док-та" FORMAT "X(19)":U
  ENABLE
  c-doc.cashier
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.03.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 31
     b-allgood AT ROW 1 COL 41
     B-del AT ROW 1 COL 51
     B-sale AT ROW 1 COL 61
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     Cb-chk-type AT ROW 2 COL 1 NO-LABEL
     RS-sort AT ROW 2.03 COL 45 NO-LABEL
     BR-docs AT ROW 3.3 COL 1
     ED-notes AT ROW 18.67 COL 1 NO-LABEL
     sch-code AT ROW 20.8 COL 17.6 COLON-ALIGNED
     sch-date AT ROW 20.83 COL 48.3 COLON-ALIGNED
     sch-price AT ROW 20.83 COL 77.5 COLON-ALIGNED
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.3 BY 1 AT ROW 20.8 COL 1.5
          FGCOLOR 4
     "Сортировка" VIEW-AS TEXT
          SIZE 12.8 BY .8 AT ROW 2.3 COL 30
          FGCOLOR 4
     SPACE(56.20) SKIP(18.89)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-del:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-del:HANDLE.
ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-print:HANDLE.
ON ENDKEY OF FRAME Dialog-Frame
DO:
  if deleted then return "deleted".
END.
ON GO OF FRAME Dialog-Frame
DO:
  if deleted then return "deleted".
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-allgood IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE rid-list as character no-undo .
   run ref/gds-chks.w ( input parparentproc
                  ,input recid(buf_goods)
                  ,input bttns
                  ,input "gds-chk":U + chr(44) + par-mode
                  ,input ?
                  ,input parobj-type
                  ,input parobj-code
                  ,input parout-code
                  ,input pard-card
                  ,output rid-list
                    ).
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
   if not available c-doc then return no-apply.
 if del-type = "" then do:
    run gbl/pop-up.p ( input b-del:handle, input no) no-error.
    if error-status:error then return no-apply.
 end.
 if del-type = "" then return no-apply.
 run proc-b-del in this-procedure ( input del-type) no-error.
  if error-status:error then do:
    del-type = '':U.
    return no-apply.
end.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
define variable next-prev as character no-undo .
  next-prev = '':U.
  DO WHILE next-prev = '':U:
        if NOT available c-doc then do:
                message "Неправильно выбран чек." view-as alert-box ERROR.
                return no-apply.
        end.
        v-doc-rec = recid (c-doc).
        .
       run str/superchk.w
                      (
                        input parparentproc
                       ,input 'ПРОСМОТР':U
                       ,input c-doc.obj-type
                       ,input c-doc.obj-code
                       ,input-output v-doc-rec
                       ,input this-procedure:handle
                       ,input-output next-prev
                                    ).
  END .
  apply "entry" to br-docs in frame Dialog-Frame.
  apply "value-changed" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
    if available chk-gds then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid16 as character no-undo .
define variable v-num-entry16 as integer   no-undo .
assign
  v-str-recid16 = trim( string( recid( chk-gds ) , "->>>>>>>>>>>9":U ) )
  v-num-entry16 = lookup( v-str-recid16 , rid-list )
.
if v-num-entry16 > 0 then do:
  assign
    entry( v-num-entry16, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid16
  .
end.
      glog = br-docs:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          glog = br-docs:select-next-row ().
          apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
      end.
      if num-entries( rid-list ) = 0
      then
          hide mark-num in frame Dialog-Frame.
      else
          disp num-entries( rid-list ) @ mark-num with frame Dialog-Frame.
    end.
    apply "entry" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
  def buffer s-doc for ub.trn-doc.
  if not avail chk-gds then do:
    print-type = "":U.
    return no-apply.
  end.
   if print-type = "" then do:
     run gbl/pop-up.p ( input self:handle, input no) no-error.
   end.
   if print-type = "list":U or print-type = "gds":U then do:
      if (par-mode = 'объект':U or par-mode = 'все':U) and index(frame Dialog-Frame:title,"ФИЛЬТР" ) = 0 then do:
        CASE print-type:
          when "list":U then do:
               message "Вы хотите напечатать весь список чеков при невключенном фильтре!" skip
               "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
              WARNING buttons YES-NO update glog.
              if NOT glog then return no-apply.
          end.
          when "gds":U then do:
               message "Вы хотите напечатать все строки чеков при невключенном фильтре!" skip
               "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
              WARNING buttons YES-NO update glog.
              if NOT glog then return no-apply.
          end.
        END CASE.
      end.
      v-doc-rec = recid( chk-gds ).
      DO WHILE available chk-gds :
            GET prev br-docs no-lock.
      END.
      CASE print-type:
        when "list":U then do:
          run PrintProc in this-procedure.
        end.
        when "gds":U then do:
          run PrintProcGds in this-procedure.
        end.
     END CASE.
      print-type = "".
      reposition br-docs to recid v-doc-rec no-error.
      apply "entry" to br-docs in frame Dialog-Frame.
    end.
    else do:
        if NOT available c-doc then do:
            message "Неправильно выбран чек." view-as alert-box ERROR.
            return no-apply.
        end.
        CASE print-type:
            when "one":U then do:
                run str/checkp.p ( input parparentproc, input c-doc.doc-code) no-error.
                print-type = "".
            end.
            when "spcf":U then do:
               if can-do( 'т':U, c-doc.office ) AND ( c-doc.d-card <> "" ) then
               run rep/r-specsr.p ( input parparentproc, input recid( c-doc ), input 'касс':U ) .
              else
              message "Чек все еще ошибочный ! " view-as alert-box ERROR.
            end.
        END CASE.
    end.
END.
ON CHOOSE OF B-sale IN FRAME Dialog-Frame
DO:
    if NOT available chk-gds then do:
        message "Неправильно выбран чек." view-as alert-box ERROR.
        return no-apply.
    end.
    FIND find_inkas where
            find_inkas.inkas-code = chk-gds.out-code NO-LOCK no-error.
    if NOT available find_inkas then do:
            message "Для данного чека нет отчета о продаже.".
            return no-apply.
     end.
    run str/ink-lkp.p ( input parparentproc
                  ,input recid(find_inkas) ).
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if ( available chk-gds ) AND ( rid-list = "" ) then
    rid-list = string( recid( chk-gds ) ) .
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
OR MOUSE-SELECT-DBLCLICK OF BR-docs IN FRAME Dialog-Frame
DO:
      if b-sel:sensitive in frame Dialog-Frame  = yes then
        apply "choose" to b-sel in frame Dialog-Frame.
    else
        apply "choose" to b-lkp in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE dops as character no-undo .
  dops = if available c-doc then c-doc.ps else '':U.
  ED-notes:screen-value = dops.
END.
ON VALUE-CHANGED OF Cb-chk-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  CB-chk-type
  p-chk-type = integer(cb-chk-type)
  .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
END.
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
  define buffer ps_chk-doc for ub.chk-doc.
   DO on stop undo, return no-apply:
        FIND PS_chk-doc where recid (ps_chk-doc) = recid(c-doc) exclusive.
        if ps_CHk-doc.PS <> input frame Dialog-Frame ed-notes then
        ps_chk-doc.PS = input frame Dialog-Frame ed-notes.
    END.
END.
ON CHOOSE OF MENU-ITEM m-gds
DO:
    print-type = "gds":U.
    apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-list
DO:
    print-type = "list":U.
    apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-one
DO:
    print-type = "one":U.
    apply "choose" to b-print in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF MENU-ITEM m-one-time
DO:
  assign
  v-one-time = menu-item m-one-time:checked in menu m-print.
END.
ON CHOOSE OF MENU-ITEM m_list
DO:
    del-type = "list":U.
    apply "choose" to b-del in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_one
DO:
    del-type = "one":U.
    apply "choose" to b-del in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF RS-sort IN FRAME Dialog-Frame
DO:
  assign
  RS-sort.
  Run OpenBr in this-procedure ( input yes, input no, input '':U).
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
    run proc-find-date in this-procedure ( input yes, input frame Dialog-Frame sch-date) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-date IN FRAME Dialog-Frame
DO:
  run proc-find-date in this-procedure ( input no, input frame Dialog-Frame sch-date) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-price IN FRAME Dialog-Frame
DO:
  run proc-find-price in this-procedure ( input yes, input frame Dialog-Frame sch-price) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-price IN FRAME Dialog-Frame
DO:
  run proc-find-price in this-procedure ( input no, input frame Dialog-Frame sch-price) no-error.
  if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-docs :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  v-doc-rec = recid(chk-gds). run OpenBr in this-procedure ( input yes, input no, input '':U). reposition br-docs to recid v-doc-rec no-error. v-doc-rec = ?.
             apply 'value-changed' TO BR-DOCS.
    apply "VALUE-CHANGED" to BR-docs.
end.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
def var sort-labelBR-docs   as character no-undo .
def var sort-clmnBR-docs    as handle    no-undo .
def var cur-clmnBR-docs     as handle    no-undo .
def var cur-clmn-locBR-docs as integer   no-undo .
def var re-queryBR-docs     as logical   initial no no-undo .
on start-search, ctrl-o of BR-docs in frame Dialog-Frame do:
   run sort-brBR-docs
     (input (if available chk-gds
             then recid(chk-gds)
             else ?
            )
     ).
end.
PROCEDURE sort-brBR-docs :
  define input parameter p-recid as recid no-undo .
  if re-queryBR-docs = no then do:
    assign
       cur-clmnBR-docs = BR-docs:current-column in frame Dialog-Frame
    .
    if sort-clmnBR-docs <> ? then sort-clmnBR-docs:column-fgcolor = 0.
    if cur-clmnBR-docs = sort-clmnBR-docs then do:
      assign
         sort-labelBR-docs = ""
         sort-clmnBR-docs = ?
      .
     end.
     else do:
       assign
         sort-labelBR-docs = cur-clmnBR-docs:label
         sort-clmnBR-docs  = cur-clmnBR-docs
         sort-clmnBR-docs:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBR-docs = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BR-docs:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBR-docs then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBR-docs = cur-clmn-locBR-docs + 1
    .
  end.
  case sort-labelBR-docs:
        when c-doc.office:label in browse BR-docs then DO:    assign       sort-column-name = "c-doc.office"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(chk-gds), &1&2&1)', chr(34), rid-list)     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when c-doc.doc-code:label in browse BR-docs then DO:    assign       sort-column-name = "c-doc.doc-code"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when 'Тип_чека'  then DO:    assign       sort-column-name = "entry (lookup (string(c-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when c-doc.chk-num:label in browse BR-docs then DO:    assign       sort-column-name = "c-doc.chk-num"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when c-doc.chk-date:label in browse BR-docs then DO:    assign       sort-column-name = "c-doc.chk-date"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when 'Время'  then DO:    assign       sort-column-name = "(string (c-doc.chk-time, 'HH:MM'))"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when chk-gds.doc-qnty:label in browse BR-docs then DO:    assign       sort-column-name = "chk-gds.doc-qnty"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when chk-gds.price-base:label in browse BR-docs then DO:    assign       sort-column-name = "chk-gds.price-base"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when chk-gds.discnt:label in browse BR-docs then DO:    assign       sort-column-name = "chk-gds.discnt"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when '%'  then DO:    assign       sort-column-name = "(chk-gds.discnt / chk-gds.price-base * 100)"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when 'Нетто цена'  then DO:    assign       sort-column-name = "(chk-gds.price-base - chk-gds.discnt)"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when 'ТРК'  then DO:    assign       sort-column-name = "chk-gds.pump"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when 'Пист'  then DO:    assign       sort-column-name = "chk-gds.nozzle-code"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when 'Рез'  then DO:    assign       sort-column-name = "chk-gds.loc1"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when 'Код_спис'  then DO:    assign       sort-column-name = "entry (lookup (string(chk-gds.write-off-code),  '?,0,1,-6,-9,2,-2,3,-3,-4,17':U), ',,Без_оплаты,Отмена_позиции,Полн_Отмена,Модификатор,Модификатор,Модификатор(+спис),Модификатор(-спис),Модификатор(-спис),Техпролив':U)"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when c-doc.shift-date:label in browse BR-docs then DO:    assign       sort-column-name = "c-doc.shift-date"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when c-doc.pay-desk:label in browse BR-docs then DO:    assign       sort-column-name = "c-doc.pay-desk"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when c-doc.cashier:label in browse BR-docs then DO:    assign       sort-column-name = "c-doc.cashier"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when c-doc.sales-man:label in browse BR-docs then DO:    assign       sort-column-name = "c-doc.sales-man"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when c-doc.out-code:label in browse BR-docs then DO:    assign       sort-column-name = "c-doc.out-code"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
        when c-doc.d-card:label in browse BR-docs then DO:    assign       sort-column-name = "c-doc.d-card"     .     run OpenBr  in this-procedure ( input yes, input no, input '').   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input '').
      if sort-labelBR-docs <> "" then do:
        assign
          cur-clmnBR-docs:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBR-docs = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition BR-docs to recid p-recid no-error.
    apply "value-changed" to BR-docs in frame Dialog-Frame.
  end.
  apply "entry" to BR-docs in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBR-docs:
if cur-clmnBR-docs = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input '').
end.
else do:
   assign re-queryBR-docs = yes.
   run sort-brBR-docs
     (input (if available chk-gds
             then recid(chk-gds)
             else ?
            )
     ).
   assign re-queryBR-docs = no.
end.
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-docs as INT EXTENT 28 no-undo.
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
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs ( 10, 28).
END.
ON ctrl-cursor-left OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (28, 10).
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
  if cur-clmn-loc <= 10 then do:
    return .
  end.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-loc THEN move-elementbr-docs = varmvibr-docs.
  END.
  RUN re-move-clmnbr-docs (cur-clmn-loc, 10).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-docs = 10 to EXTENT(cur-clmn-numbr-docs):
    RUN re-move-clmnbr-docs (cur-clmn-numbr-docs[varmvlbr-docs], varmvlbr-docs).
  END.
  RUN start-mv-clmnbr-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if entry(1, par-mode) = "gds-chks":u then do:
  assign
  v-cycle = yes
  par-mode = substr(par-mode, 10)
  .
end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  find buf_bar-code where
       buf_bar-code.b-code = b-c no-lock no-error.
  if not available buf_bar-code then do:
    return error.
  end.
  find FIRST buf_goods where
             buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK.
  find FIRST buf_gds-prt where
             buf_gds-prt.node-code = buf_bar-code.node-code no-lock.
CASE par-mode:
    WHEN 'все':U        THEN DO:
    END.
    WHEN 'объект':U or when "free":U THEN DO:
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
    END.
    when "d-card":U or when ("d-card" + chr(44) + 'продажа':U) then do:
        FIND FIRST buf_dis-card where
                          buf_dis-card.d-card = pard-card No-LOCK NO-ERROR.
      if not avail buf_dis-card then do:
          message vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова pard-card" pard-card
          view-as alert-box ERROR.
          return.
      end.
       FIND FIrst  buf_clients NO-LOCK WHERE
                        buf_clients.obj-type = buf_dis-card.cli-type AND
                        buf_clients.obj-code = buf_dis-card.cli-code No-ERROR.
    end.
    WHEN 'продажа':U  or when ("d-card" + chr(44) + 'продажа':U) then do:
        FIND buf_inkas where buf_inkas.inkas-code = parout-code NO-LOCK no-error.
      if not avail buf_inkas then do:
          message vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова parout-code" parout-code
          view-as alert-box ERROR.
          return.
      end.
      assign
      v-inkas-host-code = buf_inkas.host-code
      v-inkas-obj-type = buf_inkas.obj-type
      v-inkas-obj-code = buf_inkas.obj-code
      .
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - par-mode=" par-mode
      view-as alert-box ERROR.
      return.
    end.
  end CASE.
    if pardoc-rec <> ? then do:
      FIND FIRST find_chk-gds No-LOCK where
                 recid(find_chk-gds) = pardoc-rec No-ERROR.
      if not avail find_chk-gds then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова pardoc-rec" pardoc-rec
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = pardoc-rec.
    end.
  RUN MyEnable in this-procedure .
  RUn OpenBR  in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame Dialog-Frame .
  if pardoc-rec <> ? then
  REPOSITION br-docs to recid v-doc-rec No-ERROR.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Cb-chk-type RS-sort ED-notes sch-code sch-date sch-price mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel b-lkp b-allgood B-del B-sale B-print B-sch B-Help
         Cb-chk-type RS-sort BR-docs ED-notes sch-code sch-date sch-price
         mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE get-params :
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type32 as character no-undo .
define variable v-value-character32 as character no-undo .
define variable v-value-date32 as date no-undo .
define variable v-value-decimal32 as decimal no-undo .
define variable v-value-integer32 as INTEGER no-undo .
define variable v-tth32 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  parobj-type
    ,input  parobj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character32
    ,output v-value-date32
    ,output v-value-decimal32
    ,output v-value-integer32
    ,output cas-shft
    ,output v-param-type32
    ,INPUT-OUTPUT table-handle v-tth32
    )  .
delete object v-tth32.
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN
cb-chk-type:LIST-ITEM-PAIRS  in frame Dialog-Frame =  "Все типы чеков" + chr(44) + '0':U + chr(44) +
                                                       'Продажа,1,Возврат,6,ВзврСпис,96,СбросТрнзкц,14,Перелив,15,ПеревТрнзкц,16,РазблТрнзкц,36,ТехПролив,17,Списание,69,Аннуляция,8,Инвентаризация,11,Z-отчет,12,_Продажа,101,_Возврат,106,_ВзврСпис,196,_СбросТрнзкц,114,_Перелив,115,_ПеревТрнзкц,116,_ТехПролив,117,_Списание,169,_Аннуляция,108,_Инвентаризация,111,_Z-отчет,112,_СбросТрнзкц,114,_РазблТрнзкц,136,>Продажа,201,>Возврат,206,>Аннуляция,208,>>Продажа,301,>>Возврат,306':U
cb-chk-type = string(0)
p-chk-type = integer(cb-chk-type)
br-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 6
b-print:MENU-MOUSE = 1
b-del:MENU-MOUSE = 1
c-doc.cashier:READ-ONLY IN BROWSE BR-docs = YES
RS-Sort = "doc-code":U
.
if lookup ('продажа':U, par-mode) > 0 then do:
    assign
    v-doc-rec = ?
    .
end.
DISPLAY
ED-notes
sch-code
sch-date
sch-price
mark-num
Rs-sort
cb-chk-type when par-mode <> 'все':U
WITH FRAME Dialog-Frame .
ENABLE
b-allgood when v-cycle = no
b-quit
b-lkp
b-sch
b-sale when par-mode <> 'продажа':U
b-help
br-docs
b-sel  when LOOKUP("b-sel":U, bttns) > 0
b-mark when LOOKUP("b-mark":U, bttns) > 0
b-del WHEN LOOKUP("b-del":U, bttns) > 0 and lookup ('продажа':U, par-mode) > 0 AND buf_Inkas.STATUS_ <> 'факт':U and buf_inkas.status_ <> 'запрос':U
sch-code
sch-date
sch-price
ed-notes
b-print
Rs-sort
cb-chk-type when par-mode <> 'все':U
WITH FRAME Dialog-Frame.
IF lookup ('продажа':U, par-mode) = 0 THEN DO:
    HIDE
    b-del
    IN FRAME Dialog-Frame.
END.
if par-mode = 'все':U then do:
  hide
  cb-chk-type
  in frame Dialog-Frame .
end.
VIEW FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
DEFINE VARIABLE l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список чеков по бар-коду:" + chr(32) + string (b-c) + chr(32) +
         "Артикул:" + chr(32) + buf_goods.artic + chr(32) + buf_goods.gds-name + chr(32) .
run waitfram-show in this-procedure ( input "Ждите...").
DEFINE VARIABLE sort-column-phrase as character no-undo .
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
CASE Rs-sort:
  when "unsort":U then do:
      CASE par-mode :
        WHEN 'все':U        THEN DO:
         assign
        filter-point = filter-point0 + par-mode
        filter-label = substitute("&1", filter-label0)
        .
        if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE = substitute("&1", title0).
        end.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-34  as logical   no-undo .
define variable  l-filter-open-34    as logical   .
define variable  flt-rec-34       as recid     no-undo .
define variable  filter-name-34      as character no-undo .
define variable  where-phrase-34     as character no-undo .
define variable  sort-phrase-34      as character no-undo .
define variable  where-phrase-rus-34 as character no-undo .
define variable  sort-phrase-rus-34  as character no-undo .
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
                              "FOR EACH chk-gds"
      parameter-4-34 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-34) <> ""
          then  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + ", FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code")
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-34
        )
      parameter-7-34 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-34 =
          (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-34 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
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
    OPEN QUERY br-docs FOR EACH chk-gds
      where  chk-gds.b-code = buf_bar-code.b-code
    , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( chk-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer chk-gds:handle) then do:
      assign
      parameter-2-34 = (if p-find-next then "true":u else "false":u )
      parameter-4-34 =
        "where ":u +  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " ":u + where-phrase-34 + " ":u + p-find-condition + " " + ""
      parameter-5-34 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(chk-gds)
                          ,input logical(parameter-2-34)
                          ,input no-lock
                          ,input (buffer chk-gds:handle)
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
      parameter-3-34 =  "FOR EACH chk-gds"
      parameter-4-34 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-34) <> ""
          then  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " " + where-phrase-34
          else "true"
        )
      parameter-5-34 = (" " + "" + " " + ", FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code" + " " + p-find-condition)
      parameter-6-34 = if sort-phrase-34 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-34
        )
      parameter-7-34 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
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
          v-print-host-code = 0.
        END.
        WHEN 'объект':U THEN DO:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
          assign
          filter-point = filter-point0 + par-mode
          filter-label = substitute("&1 Один объект", filter-label0)
          .
          if p-open-query then do:
            ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Объект: &2&3 &4"
                                                        , title0
                                                        , parobj-type
                                                        , parobj-code
                                                        , (if p-chk-type = 0 then '':u else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                                        )
            .
          end.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-37  as logical   no-undo .
define variable  l-filter-open-37    as logical   .
define variable  flt-rec-37       as recid     no-undo .
define variable  filter-name-37      as character no-undo .
define variable  where-phrase-37     as character no-undo .
define variable  sort-phrase-37      as character no-undo .
define variable  where-phrase-rus-37 as character no-undo .
define variable  sort-phrase-rus-37  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-37
  ,output filter-name-37
  ,output where-phrase-37
  ,output sort-phrase-37
  ,output where-phrase-rus-37
  ,output sort-phrase-rus-37
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-37
      ) no-error .
  assign
    l-filter-open-37 = false
  .
  if flt-rec-37 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-37 as character no-undo .
    define variable  parameter-3-37 as character no-undo .
    define variable  parameter-4-37 as character no-undo .
    define variable  parameter-5-37 as character no-undo .
    define variable  parameter-6-37 as character no-undo .
    define variable  parameter-7-37 as character no-undo .
      assign
      parameter-3-37 =
                              "FOR EACH chk-gds"
      parameter-4-37 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-37) <> ""
          then  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)'                                     ,parobj-type                                     ,parobj-code                                     ,p-chk-type))
      parameter-6-37 = if sort-phrase-37 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-37
        )
      parameter-7-37 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-37 =
          (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-37 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
                          )
      .
      assign
        l-filter-open-37 = true
      .
    end.
    if l-filter-open-37 = false then do:
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
  if l-filter-open-37 = false then do:
    OPEN QUERY br-docs FOR EACH chk-gds
      where  chk-gds.b-code = buf_bar-code.b-code
    , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = parobj-type AND c-doc.obj-code = parobj-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( chk-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer chk-gds:handle) then do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-4-37 =
        "where ":u +  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " ":u + where-phrase-37 + " ":u + p-find-condition + " " + ""
      parameter-5-37 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(chk-gds)
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input (buffer chk-gds:handle)
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-3-37 =  "FOR EACH chk-gds"
      parameter-4-37 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-37) <> ""
          then  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)'                                     ,parobj-type                                     ,parobj-code                                     ,p-chk-type) + " " + p-find-condition)
      parameter-6-37 = if sort-phrase-37 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-37
        )
      parameter-7-37 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
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
        END.
        WHEN "d-card":U    THEN DO:
          ASSIGN
          filter-point = filter-point0 + "КЛИЕНТ":U
          filter-label = substitute("&1 Один объект, Одна ДК", filter-label0)
          .
          if p-open-query then do:
            assign
            frame Dialog-Frame:TITLE = substitute("&1 Чеки по карте № &2 Объект &3&4 &5"
                                                        ,title0
                                                        ,pard-card
                                                        ,parobj-type
                                                        ,parobj-code
                                                        , (if p-chk-type = 0 then '':u else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                                        ) .
          end.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-39  as logical   no-undo .
define variable  l-filter-open-39    as logical   .
define variable  flt-rec-39       as recid     no-undo .
define variable  filter-name-39      as character no-undo .
define variable  where-phrase-39     as character no-undo .
define variable  sort-phrase-39      as character no-undo .
define variable  where-phrase-rus-39 as character no-undo .
define variable  sort-phrase-rus-39  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-39
  ,output filter-name-39
  ,output where-phrase-39
  ,output sort-phrase-39
  ,output where-phrase-rus-39
  ,output sort-phrase-rus-39
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-39
      ) no-error .
  assign
    l-filter-open-39 = false
  .
  if flt-rec-39 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-39 as character no-undo .
    define variable  parameter-3-39 as character no-undo .
    define variable  parameter-4-39 as character no-undo .
    define variable  parameter-5-39 as character no-undo .
    define variable  parameter-6-39 as character no-undo .
    define variable  parameter-7-39 as character no-undo .
      assign
      parameter-3-39 =
                              "FOR EACH chk-gds"
      parameter-4-39 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-39) <> ""
          then  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.d-card = "&1" and ( &2 = 0 or c-doc.chk-type = &2)'                                     ,pard-card                                     ,p-chk-type ))
      parameter-6-39 = if sort-phrase-39 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-39
        )
      parameter-7-39 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-39 =
          (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-39 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
                          )
      .
      assign
        l-filter-open-39 = true
      .
    end.
    if l-filter-open-39 = false then do:
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
  if l-filter-open-39 = false then do:
    OPEN QUERY br-docs FOR EACH chk-gds
      where  chk-gds.b-code = buf_bar-code.b-code
    , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.d-card = pard-card and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( chk-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer chk-gds:handle) then do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-4-39 =
        "where ":u +  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " ":u + where-phrase-39 + " ":u + p-find-condition + " " + ""
      parameter-5-39 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(chk-gds)
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input (buffer chk-gds:handle)
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-3-39 =  "FOR EACH chk-gds"
      parameter-4-39 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-39) <> ""
          then  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.d-card = "&1" and ( &2 = 0 or c-doc.chk-type = &2)'                                     ,pard-card                                     ,p-chk-type ) + " " + p-find-condition)
      parameter-6-39 = if sort-phrase-39 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-39
        )
      parameter-7-39 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
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
        END.
        WHEN ("d-card":U  + chr(44) + 'продажа':U)   THEN DO:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
          ASSIGN
          filter-point = filter-point0 + "КЛИЕНТ":U
          filter-label = substitute("&1 Один объект, Одна ДК, Одна продажа", filter-label0)
          .
          if p-open-query then do:
            assign
            frame Dialog-Frame:TITLE = substitute("&1 Чеки по карте № &2 и отчету &3 Объект &4&5 &6"
                                                        ,title0
                                                        ,pard-card
                                                        ,parout-code
                                                        ,parobj-type
                                                        ,parobj-code
                                                        , (if p-chk-type = 0 then '':u else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                                        ) .
          end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-42  as logical   no-undo .
define variable  l-filter-open-42    as logical   .
define variable  flt-rec-42       as recid     no-undo .
define variable  filter-name-42      as character no-undo .
define variable  where-phrase-42     as character no-undo .
define variable  sort-phrase-42      as character no-undo .
define variable  where-phrase-rus-42 as character no-undo .
define variable  sort-phrase-rus-42  as character no-undo .
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
                              "FOR EACH chk-gds"
      parameter-4-42 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code " + " " + where-phrase-42) <> ""
          then  substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, chr(34), parout-code)  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.d-card = "&1" AND c-doc.obj-type = "&2" AND c-doc.obj-code = &3 and (&4 = 0 or c-doc.chk-type = &4)'                                     ,pard-card                                     ,parobj-type                                     ,parobj-code                                     ,p-chk-type))
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
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
          (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code " + " " + where-phrase-42 = "")
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
    OPEN QUERY br-docs FOR EACH chk-gds
      where  chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code
    , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.d-card = pard-card AND c-doc.obj-code = parobj-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( chk-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer chk-gds:handle) then do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-4-42 =
        "where ":u +  substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, chr(34), parout-code)  + " ":u + where-phrase-42 + " ":u + p-find-condition + " " + ""
      parameter-5-42 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(chk-gds)
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input (buffer chk-gds:handle)
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
      parameter-3-42 =  "FOR EACH chk-gds"
      parameter-4-42 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code " + " " + where-phrase-42) <> ""
          then  substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, chr(34), parout-code)  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.d-card = "&1" AND c-doc.obj-type = "&2" AND c-doc.obj-code = &3 and (&4 = 0 or c-doc.chk-type = &4)'                                     ,pard-card                                     ,parobj-type                                     ,parobj-code                                     ,p-chk-type) + " " + p-find-condition)
      parameter-6-42 = if sort-phrase-42 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
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
        END.
        WHEN 'продажа':U   THEN DO:
        define buffer buf_inkas for ub.inkas.
          find first buf_inkas no-lock where buf_inkas.inkas-code = parout-code .
          v-print-host-code = buf_inkas.host-code.
          assign
          filter-point = filter-point0 + par-mode
          filter-label = substitute("&1 Одна продажа", filter-label0)
          .
          if p-open-query then do:
            ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки по отчету &2 Объект &3&4 &5"
                                                          ,title0
                                                          ,parout-code
                                                          ,parobj-type
                                                          ,parobj-code
                                                          , (if p-chk-type = 0 then '':u else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                                          )
            .
          end.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-44  as logical   no-undo .
define variable  l-filter-open-44    as logical   .
define variable  flt-rec-44       as recid     no-undo .
define variable  filter-name-44      as character no-undo .
define variable  where-phrase-44     as character no-undo .
define variable  sort-phrase-44      as character no-undo .
define variable  where-phrase-rus-44 as character no-undo .
define variable  sort-phrase-rus-44  as character no-undo .
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
                              "FOR EACH chk-gds"
      parameter-4-44 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code " + " " + where-phrase-44) <> ""
          then  substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, chr(34), parout-code)  + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code and (&1 = 0 or c-doc.chk-type = &1)'                                                 , p-chk-type))
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
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
          (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code " + " " + where-phrase-44 = "")
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
    OPEN QUERY br-docs FOR EACH chk-gds
      where  chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code
    , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( chk-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer chk-gds:handle) then do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-4-44 =
        "where ":u +  substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, chr(34), parout-code)  + " ":u + where-phrase-44 + " ":u + p-find-condition + " " + ""
      parameter-5-44 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(chk-gds)
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input (buffer chk-gds:handle)
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
      parameter-3-44 =  "FOR EACH chk-gds"
      parameter-4-44 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code " + " " + where-phrase-44) <> ""
          then  substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, chr(34), parout-code)  + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code and (&1 = 0 or c-doc.chk-type = &1)'                                                 , p-chk-type) + " " + p-find-condition)
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
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
        END.
        WHEN "free":U    THEN DO:
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
          assign
          filter-label = substitute("&1 Свободные чеки", filter-label0)
                                                        .
          filter-point = filter-point0 + "НЕУЧТЕННЫЕ":U.
          if p-open-query then do:
            ASSIGN frame Dialog-Frame:TITLE = substitute("&1 НЕ включенные в отчеты чеки Объект &2&3 &4"
                                                          ,title0
                                                          ,parobj-type
                                                          ,parobj-code
                                                          , (if p-chk-type = 0 then '':u else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                                          )
            .
          end.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-47  as logical   no-undo .
define variable  l-filter-open-47    as logical   .
define variable  flt-rec-47       as recid     no-undo .
define variable  filter-name-47      as character no-undo .
define variable  where-phrase-47     as character no-undo .
define variable  sort-phrase-47      as character no-undo .
define variable  where-phrase-rus-47 as character no-undo .
define variable  sort-phrase-rus-47  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-47
  ,output filter-name-47
  ,output where-phrase-47
  ,output sort-phrase-47
  ,output where-phrase-rus-47
  ,output sort-phrase-rus-47
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-47
      ) no-error .
  assign
    l-filter-open-47 = false
  .
  if flt-rec-47 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-47 as character no-undo .
    define variable  parameter-3-47 as character no-undo .
    define variable  parameter-4-47 as character no-undo .
    define variable  parameter-5-47 as character no-undo .
    define variable  parameter-6-47 as character no-undo .
    define variable  parameter-7-47 as character no-undo .
      assign
      parameter-3-47 =
                              "FOR EACH chk-gds"
      parameter-4-47 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = ? " + " " + where-phrase-47) <> ""
          then  substitute('chk-gds.b-code = &1 AND chk-gds.out-code = ? ', buf_bar-code.b-code)  + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)'                                     ,parobj-type                                     ,parobj-code                                     ,p-chk-type))
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-47
        )
      parameter-7-47 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-47 =
          (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = ? " + " " + where-phrase-47 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-47
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ,input parameter-6-47
                          ,input parameter-7-47
                          )
      .
      assign
        l-filter-open-47 = true
      .
    end.
    if l-filter-open-47 = false then do:
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
  if l-filter-open-47 = false then do:
    OPEN QUERY br-docs FOR EACH chk-gds
      where  chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = ?
    , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = parobj-type AND c-doc.obj-code = parobj-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( chk-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer chk-gds:handle) then do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-4-47 =
        "where ":u +  substitute('chk-gds.b-code = &1 AND chk-gds.out-code = ? ', buf_bar-code.b-code)  + " ":u + where-phrase-47 + " ":u + p-find-condition + " " + ""
      parameter-5-47 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(chk-gds)
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input (buffer chk-gds:handle)
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-3-47 =  "FOR EACH chk-gds"
      parameter-4-47 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = ? " + " " + where-phrase-47) <> ""
          then  substitute('chk-gds.b-code = &1 AND chk-gds.out-code = ? ', buf_bar-code.b-code)  + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)'                                     ,parobj-type                                     ,parobj-code                                     ,p-chk-type) + " " + p-find-condition)
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-47
        )
      parameter-7-47 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input parameter-3-47
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ,input parameter-6-47
                          ,input parameter-7-47
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
        END.
    END CASE.
  end.
  when "doc-code":U then do:
      CASE par-mode :
        WHEN 'все':U        THEN DO:
         assign
        filter-point = filter-point0 + par-mode
        filter-label = substitute("&1", filter-label0)
        .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-49  as logical   no-undo .
define variable  l-filter-open-49    as logical   .
define variable  flt-rec-49       as recid     no-undo .
define variable  filter-name-49      as character no-undo .
define variable  where-phrase-49     as character no-undo .
define variable  sort-phrase-49      as character no-undo .
define variable  where-phrase-rus-49 as character no-undo .
define variable  sort-phrase-rus-49  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-49
  ,output filter-name-49
  ,output where-phrase-49
  ,output sort-phrase-49
  ,output where-phrase-rus-49
  ,output sort-phrase-rus-49
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-49
      ) no-error .
  assign
    l-filter-open-49 = false
  .
  if flt-rec-49 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-49 as character no-undo .
    define variable  parameter-3-49 as character no-undo .
    define variable  parameter-4-49 as character no-undo .
    define variable  parameter-5-49 as character no-undo .
    define variable  parameter-6-49 as character no-undo .
    define variable  parameter-7-49 as character no-undo .
      assign
      parameter-3-49 =
                              "FOR EACH chk-gds"
      parameter-4-49 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-49) <> ""
          then  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)'                                     ,parobj-type                                     ,parobj-code                                     ,p-chk-type))
      parameter-6-49 = if sort-phrase-49 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by chk-gds.doc-code descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-49
        )
      parameter-7-49 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-49 =
          (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-49 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-49
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ,input parameter-6-49
                          ,input parameter-7-49
                          )
      .
      assign
        l-filter-open-49 = true
      .
    end.
    if l-filter-open-49 = false then do:
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
  if l-filter-open-49 = false then do:
    OPEN QUERY br-docs FOR EACH chk-gds
      where  chk-gds.b-code = buf_bar-code.b-code
    , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code
       by chk-gds.doc-code descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( chk-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer chk-gds:handle) then do:
      assign
      parameter-2-49 = (if p-find-next then "true":u else "false":u )
      parameter-4-49 =
        "where ":u +  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " ":u + where-phrase-49 + " ":u + p-find-condition + " " + ""
      parameter-5-49 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(chk-gds)
                          ,input logical(parameter-2-49)
                          ,input no-lock
                          ,input (buffer chk-gds:handle)
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-49 = (if p-find-next then "true":u else "false":u )
      parameter-3-49 =  "FOR EACH chk-gds"
      parameter-4-49 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-49) <> ""
          then  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)'                                     ,parobj-type                                     ,parobj-code                                     ,p-chk-type) + " " + p-find-condition)
      parameter-6-49 = if sort-phrase-49 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by chk-gds.doc-code descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-49
        )
      parameter-7-49 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-49)
                          ,input no-lock
                          ,input parameter-3-49
                          ,input parameter-4-49
                          ,input parameter-5-49
                          ,input parameter-6-49
                          ,input parameter-7-49
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
        END.
        WHEN 'объект':U THEN DO:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
          ASSIGN
          filter-point = filter-point0 + par-mode
          filter-label = substitute("&1 Один чек, Один объект", filter-label0)
          .
          if p-open-query then do:
            assign
            frame Dialog-Frame:TITLE = substitute("&1 Объект: &2&3 &4"
                                                          , title0
                                                          , parobj-type
                                                          , parobj-code
                                                          , (if p-chk-type = 0 then '':u else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                                          ).
          end.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-52  as logical   no-undo .
define variable  l-filter-open-52    as logical   .
define variable  flt-rec-52       as recid     no-undo .
define variable  filter-name-52      as character no-undo .
define variable  where-phrase-52     as character no-undo .
define variable  sort-phrase-52      as character no-undo .
define variable  where-phrase-rus-52 as character no-undo .
define variable  sort-phrase-rus-52  as character no-undo .
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
                              "FOR EACH chk-gds"
      parameter-4-52 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-52) <> ""
          then  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)'                                     ,parobj-type                                     ,parobj-code                                     ,p-chk-type ))
      parameter-6-52 = if sort-phrase-52 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by chk-gds.doc-code descending "
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
          (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-52 = "")
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
    OPEN QUERY br-docs FOR EACH chk-gds
      where  chk-gds.b-code = buf_bar-code.b-code
    , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = parobj-type AND c-doc.obj-code = parobj-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
       by chk-gds.doc-code descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( chk-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer chk-gds:handle) then do:
      assign
      parameter-2-52 = (if p-find-next then "true":u else "false":u )
      parameter-4-52 =
        "where ":u +  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " ":u + where-phrase-52 + " ":u + p-find-condition + " " + ""
      parameter-5-52 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(chk-gds)
                          ,input logical(parameter-2-52)
                          ,input no-lock
                          ,input (buffer chk-gds:handle)
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
      parameter-3-52 =  "FOR EACH chk-gds"
      parameter-4-52 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-52) <> ""
          then  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)'                                     ,parobj-type                                     ,parobj-code                                     ,p-chk-type ) + " " + p-find-condition)
      parameter-6-52 = if sort-phrase-52 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by chk-gds.doc-code descending "
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
        END.
        WHEN "d-card":U    THEN DO:
          assign
          filter-point = filter-point0 + "КЛИЕНТ":U
          filter-label = substitute("&1 Один объект, Одна ДК", filter-label0)
          .
          if p-open-query then do:
            ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки по карте № &2 Объект &3&4 &5"
                                                          ,title0
                                                          ,pard-card
                                                          ,parobj-type
                                                          ,parobj-code
                                                          , (if p-chk-type = 0 then '':u else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                                          )
                                                                .
          end.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-54  as logical   no-undo .
define variable  l-filter-open-54    as logical   .
define variable  flt-rec-54       as recid     no-undo .
define variable  filter-name-54      as character no-undo .
define variable  where-phrase-54     as character no-undo .
define variable  sort-phrase-54      as character no-undo .
define variable  where-phrase-rus-54 as character no-undo .
define variable  sort-phrase-rus-54  as character no-undo .
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
                              "FOR EACH chk-gds"
      parameter-4-54 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-54) <> ""
          then  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.d-card = "&1" and (&2 = 0 or c-doc.chk-type = &2)'                                     ,pard-card                                     ,p-chk-type ))
      parameter-6-54 = if sort-phrase-54 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by chk-gds.doc-code descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-54
        )
      parameter-7-54 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-54 =
          (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-54 = "")
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
    OPEN QUERY br-docs FOR EACH chk-gds
      where  chk-gds.b-code = buf_bar-code.b-code
    , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.d-card = pard-card and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
       by chk-gds.doc-code descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( chk-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer chk-gds:handle) then do:
      assign
      parameter-2-54 = (if p-find-next then "true":u else "false":u )
      parameter-4-54 =
        "where ":u +  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " ":u + where-phrase-54 + " ":u + p-find-condition + " " + ""
      parameter-5-54 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(chk-gds)
                          ,input logical(parameter-2-54)
                          ,input no-lock
                          ,input (buffer chk-gds:handle)
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
      parameter-3-54 =  "FOR EACH chk-gds"
      parameter-4-54 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code " + " " + where-phrase-54) <> ""
          then  substitute('chk-gds.b-code = &1', buf_bar-code.b-code)  + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.d-card = "&1" and (&2 = 0 or c-doc.chk-type = &2)'                                     ,pard-card                                     ,p-chk-type ) + " " + p-find-condition)
      parameter-6-54 = if sort-phrase-54 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by chk-gds.doc-code descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-54
        )
      parameter-7-54 =
        "   "
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
        END.
        WHEN ("d-card":U  + chr(44) + 'продажа':U)   THEN DO:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
          ASSIGN
          filter-point = filter-point0 + "КЛИЕНТ":U
          filter-label = substitute("&1 Один объект, Один ДК, одна продажа", filter-label0)
          .
          if p-open-query then do:
            assign
            frame Dialog-Frame:TITLE = substitute("&1 Чеки по карте № &2 и отчету &3 Объект &4&5 &6"
                                                          ,title0
                                                          ,pard-card
                                                          ,parout-code
                                                          ,parobj-type
                                                          ,parobj-code
                                                          , (if p-chk-type = 0 then '':u else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                                          ) .
          end.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-57  as logical   no-undo .
define variable  l-filter-open-57    as logical   .
define variable  flt-rec-57       as recid     no-undo .
define variable  filter-name-57      as character no-undo .
define variable  where-phrase-57     as character no-undo .
define variable  sort-phrase-57      as character no-undo .
define variable  where-phrase-rus-57 as character no-undo .
define variable  sort-phrase-rus-57  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-57
  ,output filter-name-57
  ,output where-phrase-57
  ,output sort-phrase-57
  ,output where-phrase-rus-57
  ,output sort-phrase-rus-57
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-57
      ) no-error .
  assign
    l-filter-open-57 = false
  .
  if flt-rec-57 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-57 as character no-undo .
    define variable  parameter-3-57 as character no-undo .
    define variable  parameter-4-57 as character no-undo .
    define variable  parameter-5-57 as character no-undo .
    define variable  parameter-6-57 as character no-undo .
    define variable  parameter-7-57 as character no-undo .
      assign
      parameter-3-57 =
                              "FOR EACH chk-gds"
      parameter-4-57 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code " + " " + where-phrase-57) <> ""
          then  substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, chr(34), parout-code )  + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.d-card = "&1" AND c-doc.obj-type = "&2" AND c-doc.obj-code = &3 and (&4 = 0 or c-doc.chk-type = &4)'                                     ,pard-card                                      ,parobj-type                                     ,parobj-code                                     ,p-chk-type))
      parameter-6-57 = if sort-phrase-57 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by chk-gds.doc-code descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-57
        )
      parameter-7-57 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-57 =
          (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code " + " " + where-phrase-57 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-57
                          ,input parameter-4-57
                          ,input parameter-5-57
                          ,input parameter-6-57
                          ,input parameter-7-57
                          )
      .
      assign
        l-filter-open-57 = true
      .
    end.
    if l-filter-open-57 = false then do:
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
  if l-filter-open-57 = false then do:
    OPEN QUERY br-docs FOR EACH chk-gds
      where  chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code
    , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.d-card = pard-card AND c-doc.obj-code = parobj-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
       by chk-gds.doc-code descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( chk-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer chk-gds:handle) then do:
      assign
      parameter-2-57 = (if p-find-next then "true":u else "false":u )
      parameter-4-57 =
        "where ":u +  substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, chr(34), parout-code )  + " ":u + where-phrase-57 + " ":u + p-find-condition + " " + ""
      parameter-5-57 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(chk-gds)
                          ,input logical(parameter-2-57)
                          ,input no-lock
                          ,input (buffer chk-gds:handle)
                          ,input parameter-4-57
                          ,input parameter-5-57
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-57 = (if p-find-next then "true":u else "false":u )
      parameter-3-57 =  "FOR EACH chk-gds"
      parameter-4-57 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code " + " " + where-phrase-57) <> ""
          then  substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, chr(34), parout-code )  + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.d-card = "&1" AND c-doc.obj-type = "&2" AND c-doc.obj-code = &3 and (&4 = 0 or c-doc.chk-type = &4)'                                     ,pard-card                                      ,parobj-type                                     ,parobj-code                                     ,p-chk-type) + " " + p-find-condition)
      parameter-6-57 = if sort-phrase-57 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by chk-gds.doc-code descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-57
        )
      parameter-7-57 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-57)
                          ,input no-lock
                          ,input parameter-3-57
                          ,input parameter-4-57
                          ,input parameter-5-57
                          ,input parameter-6-57
                          ,input parameter-7-57
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
        END.
        WHEN 'продажа':U   THEN DO:
          find first buf_inkas no-lock where buf_inkas.inkas-code = parout-code .
          v-print-host-code = buf_inkas.host-code.
          assign
          filter-label = substitute("&1 одна продажа", filter-label0)
          filter-point = filter-point0 + par-mode.
          if p-open-query then do:
            ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки по отчету &2 Объект &3&4 &5"
                                                        ,title0
                                                        ,parout-code
                                                        ,parobj-type
                                                        ,parobj-code
                                                        , (if p-chk-type = 0 then '':u else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                                        )
            .
          end.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-59  as logical   no-undo .
define variable  l-filter-open-59    as logical   .
define variable  flt-rec-59       as recid     no-undo .
define variable  filter-name-59      as character no-undo .
define variable  where-phrase-59     as character no-undo .
define variable  sort-phrase-59      as character no-undo .
define variable  where-phrase-rus-59 as character no-undo .
define variable  sort-phrase-rus-59  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-59
  ,output filter-name-59
  ,output where-phrase-59
  ,output sort-phrase-59
  ,output where-phrase-rus-59
  ,output sort-phrase-rus-59
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-59
      ) no-error .
  assign
    l-filter-open-59 = false
  .
  if flt-rec-59 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-59 as character no-undo .
    define variable  parameter-3-59 as character no-undo .
    define variable  parameter-4-59 as character no-undo .
    define variable  parameter-5-59 as character no-undo .
    define variable  parameter-6-59 as character no-undo .
    define variable  parameter-7-59 as character no-undo .
      assign
      parameter-3-59 =
                              "FOR EACH chk-gds"
      parameter-4-59 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code " + " " + where-phrase-59) <> ""
          then  substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, chr(34), parout-code)  + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code and (&1 = 0 or c-doc.chk-type = &1)'                                                  ,p-chk-type ))
      parameter-6-59 = if sort-phrase-59 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by chk-gds.doc-code descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-59
        )
      parameter-7-59 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-59 =
          (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code " + " " + where-phrase-59 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-59
                          ,input parameter-4-59
                          ,input parameter-5-59
                          ,input parameter-6-59
                          ,input parameter-7-59
                          )
      .
      assign
        l-filter-open-59 = true
      .
    end.
    if l-filter-open-59 = false then do:
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
  if l-filter-open-59 = false then do:
    OPEN QUERY br-docs FOR EACH chk-gds
      where  chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code
    , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
       by chk-gds.doc-code descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( chk-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer chk-gds:handle) then do:
      assign
      parameter-2-59 = (if p-find-next then "true":u else "false":u )
      parameter-4-59 =
        "where ":u +  substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, chr(34), parout-code)  + " ":u + where-phrase-59 + " ":u + p-find-condition + " " + ""
      parameter-5-59 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(chk-gds)
                          ,input logical(parameter-2-59)
                          ,input no-lock
                          ,input (buffer chk-gds:handle)
                          ,input parameter-4-59
                          ,input parameter-5-59
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-59 = (if p-find-next then "true":u else "false":u )
      parameter-3-59 =  "FOR EACH chk-gds"
      parameter-4-59 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = parout-code " + " " + where-phrase-59) <> ""
          then  substitute(' chk-gds.b-code = &1 AND chk-gds.out-code = &2&3&2 ', buf_bar-code.b-code, chr(34), parout-code)  + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code and (&1 = 0 or c-doc.chk-type = &1)'                                                  ,p-chk-type ) + " " + p-find-condition)
      parameter-6-59 = if sort-phrase-59 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by chk-gds.doc-code descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-59
        )
      parameter-7-59 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-59)
                          ,input no-lock
                          ,input parameter-3-59
                          ,input parameter-4-59
                          ,input parameter-5-59
                          ,input parameter-6-59
                          ,input parameter-7-59
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
        END.
        WHEN "free":U    THEN DO:
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
          assign
          filter-label = substitute("&1 свободные чеки", filter-label0)
          filter-point = filter-point0 + "НЕУЧТЕННЫЕ":U
          .
          if p-open-query then do:
            ASSIGN frame Dialog-Frame:TITLE = substitute("&1 НЕ включенные в отчеты чеки Объект &2&3 &4"
                                                          ,title0
                                                          ,parobj-type
                                                          ,parobj-code
                                                          , (if p-chk-type = 0 then '':u else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                                          )
            .
          end.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-62  as logical   no-undo .
define variable  l-filter-open-62    as logical   .
define variable  flt-rec-62       as recid     no-undo .
define variable  filter-name-62      as character no-undo .
define variable  where-phrase-62     as character no-undo .
define variable  sort-phrase-62      as character no-undo .
define variable  where-phrase-rus-62 as character no-undo .
define variable  sort-phrase-rus-62  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-62
  ,output filter-name-62
  ,output where-phrase-62
  ,output sort-phrase-62
  ,output where-phrase-rus-62
  ,output sort-phrase-rus-62
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-62
      ) no-error .
  assign
    l-filter-open-62 = false
  .
  if flt-rec-62 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-62 as character no-undo .
    define variable  parameter-3-62 as character no-undo .
    define variable  parameter-4-62 as character no-undo .
    define variable  parameter-5-62 as character no-undo .
    define variable  parameter-6-62 as character no-undo .
    define variable  parameter-7-62 as character no-undo .
      assign
      parameter-3-62 =
                              "FOR EACH chk-gds"
      parameter-4-62 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = ? " + " " + where-phrase-62) <> ""
          then  substitute('chk-gds.b-code = &1 AND chk-gds-out-code = ?', buf_bar-code.b-code)  + " " + where-phrase-62
          else "true"
        )
      parameter-5-62 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)'                                     ,parobj-type                                     ,parobj-code                                     ,p-chk-type))
      parameter-6-62 = if sort-phrase-62 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by chk-gds.doc-code descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-62
        )
      parameter-7-62 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-62 =
          (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = ? " + " " + where-phrase-62 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-62
                          ,input parameter-4-62
                          ,input parameter-5-62
                          ,input parameter-6-62
                          ,input parameter-7-62
                          )
      .
      assign
        l-filter-open-62 = true
      .
    end.
    if l-filter-open-62 = false then do:
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
  if l-filter-open-62 = false then do:
    OPEN QUERY br-docs FOR EACH chk-gds
      where  chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = ?
    , FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = parobj-type AND c-doc.obj-code = parobj-code and (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
       by chk-gds.doc-code descending
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( chk-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer chk-gds:handle) then do:
      assign
      parameter-2-62 = (if p-find-next then "true":u else "false":u )
      parameter-4-62 =
        "where ":u +  substitute('chk-gds.b-code = &1 AND chk-gds-out-code = ?', buf_bar-code.b-code)  + " ":u + where-phrase-62 + " ":u + p-find-condition + " " + ""
      parameter-5-62 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(chk-gds)
                          ,input logical(parameter-2-62)
                          ,input no-lock
                          ,input (buffer chk-gds:handle)
                          ,input parameter-4-62
                          ,input parameter-5-62
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-62 = (if p-find-next then "true":u else "false":u )
      parameter-3-62 =  "FOR EACH chk-gds"
      parameter-4-62 =
        (
          if (" chk-gds.b-code = buf_bar-code.b-code AND chk-gds.out-code = ? " + " " + where-phrase-62) <> ""
          then  substitute('chk-gds.b-code = &1 AND chk-gds-out-code = ?', buf_bar-code.b-code)  + " " + where-phrase-62
          else "true"
        )
      parameter-5-62 = (" " + "" + " " + substitute(', FIRST c-doc No-LOCK WHERE c-doc.doc-code = chk-gds.doc-code                                     AND c-doc.obj-type = "&1" AND c-doc.obj-code = &2 and (&3 = 0 or c-doc.chk-type = &3)'                                     ,parobj-type                                     ,parobj-code                                     ,p-chk-type) + " " + p-find-condition)
      parameter-6-62 = if sort-phrase-62 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by chk-gds.doc-code descending "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-62
        )
      parameter-7-62 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-62)
                          ,input no-lock
                          ,input parameter-3-62
                          ,input parameter-4-62
                          ,input parameter-5-62
                          ,input parameter-6-62
                          ,input parameter-7-62
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
        END.
    END CASE.
  end.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-docs to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-docs in frame Dialog-Frame.
APPLY "ENTRY" TO br-docs.
END PROCEDURE.
PROCEDURE PrintProc :
DEFINE VARIABLE date_string     as      char    no-undo.
DEFINE VARIABLE Line                as      char    no-undo.
DEFINE VARIABLE for-time as char.
DEFINE VARIABLE accum-count as integer.
DEFINE VARIABLE accum-tot-doc as decimal.
DEFINE VARIABLE accum-discnt as decima.
DEFINE VARIABLE accum-sub-discnt as decimal.
DEFINE VARIABLE accum-netto as decimal.
define variable v-shift-name-num as character no-undo .
DEFINE VARIABLE v-doc-code like ub.chk-doc.doc-code no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-base-code like ub.sysconf.host-code no-undo .
define variable v-base-type like ub.currency.curr-abbr no-undo .
define variable V-RECEIPT-NAME as character no-undo .
define buffer buf_currency for ub.currency.
if v-curr-r-b = 'base':U then do:
  if v-print-host-code <> ? then do:
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-print-host-code
  ,output v-base-code
  )  .
    find first buf_currency where
            buf_currency.curr-code = v-base-code.
    assign
    v-base-type = buf_currency.curr-abbr.
  end.
end.
assign
v-header-base-curr = string( "( Б.Вал. - " + caps( v-base-type ) + " )" )
.
DEFINE FRAME Chk-List
c-doc.office        column-label "Тип"                format "X(8)"
c-doc.doc-code      column-label "Номер_чека/Номер_строки"  format "X(23)"
V-RECEIPT-NAME      COLUMN-LABEL "Тип_чека" format "X(8)"
c-doc.chk-num       column-label "N_касс" format "->>>>>>9"
c-doc.chk-date      column-label "Дата" format "99/99/9999"
for-time            column-label "Время"   format "X(5)"
c-doc.shift-date    column-label "Смена_от" format "99/99/9999"
v-shift-name-num    column-label "№_см." FORMAT "X(6)"
c-doc.tot-doc       column-label "Сумма_товарная"
c-doc.discnt        column-label "Скидка_общая"
c-doc.sub-discnt    column-label "Списания"
c-doc.netto         column-label "Сумма_оплат"
c-doc.pay-desk      column-label "Касса"
c-doc.cashier       column-label "Кассир"       format ">>>>9"
c-doc.sales-man     column-label "Прод-ц"       format ">>>>9"
c-doc.out-code      column-label "Номер_РН"
c-doc.d-card        column-label "Номер_диск.карты" format "X(16)" space(0)
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
v-header-base-curr        format "X(20)"
Line format "X(198)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 198).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
( frame Dialog-Frame:title )
format "x(198)" SKIP(1) .
FORM HEADER
Line format "X(198)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME Chk-List  .
run waitfram-show in this-procedure ( input "Ждите...").
GET next br-docs no-lock.
assign
v-doc-code = chk-gds.doc-code
.
DO WHILE available chk-gds :
  if v-one-time = no OR v-doc-code <> chk-gds.doc-code then do:
      Display STREAM PrnLibStream
    c-doc.office
    (if v-one-time
    then c-doc.doc-code
    else (string(c-doc.doc-code, "X(20)") + chr(32) + string(chk-gds.line-num, "-99"))) @ c-doc.doc-code
    entry (lookup (string(c-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U) @ v-receipt-name
    c-doc.chk-num
    c-doc.chk-date
    string(c-doc.chk-time, "HH:mm") @ for-time
    c-doc.shift-date
    shift-name-no-err(buffer c-doc) @ v-shift-name-num
    c-doc.tot-doc
    c-doc.discnt
    c-doc.sub-discnt
    c-doc.netto
    c-doc.pay-desk
    c-doc.cashier
    c-doc.sales-man
    if c-doc.out-code <> ? then c-doc.out-code else "" @ c-doc.out-code
    c-doc.d-card
    with FRAME Chk-List .
    DOWN STREAM PrnLibStream 1 with FRAME CHk-List  .
    assign
    accum-count = accum-count + 1
    accum-tot-doc = accum-tot-doc + c-doc.tot-doc
    accum-discnt = accum-discnt + c-doc.discnt
    accum-sub-discnt = accum-sub-discnt + c-doc.sub-discnt
    accum-netto = accum-netto + c-doc.netto.
  end.
  assign
  v-doc-code = chk-gds.doc-code
  .
  GET next br-docs no-lock.
END.
if v-one-time then do:
  UNDERLINE  STREAM PrnLibStream
  c-doc.office
  c-doc.doc-code
  v-receipt-name
  c-doc.chk-num
  c-doc.chk-date
  for-time
  c-doc.shift-date
  v-shift-name-num
  c-doc.tot-doc
  c-doc.discnt
  c-doc.sub-discnt
  c-doc.netto
  c-doc.pay-desk
  c-doc.cashier
  c-doc.sales-man
  c-doc.out-code
  c-doc.d-card
  with FRAME Chk-List .
  DISPLAY STREAM PrnLibStream
  "ИТОГО"  @ c-doc.doc-code
  accum-count @ c-doc.chk-num
  "_" @ c-doc.chk-date
  "_ " @ for-time
  "_" @ c-doc.shift-date
  "_____" @ v-shift-name-num
  accum-tot-doc @ c-doc.tot-doc
  accum-discnt @ c-doc.discnt
  accum-sub-discnt @ c-doc.sub-discnt
  accum-netto @ c-doc.netto
  with frame Chk-List.
end.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
PROCEDURE PrintProcGds :
DEFINE VARIABLE date_string     as      char    no-undo.
DEFINE VARIABLE Line                as      char    no-undo.
DEFINE VARIABLE for-time as char no-undo.
DEFINE VARIABLE accum-count as integer no-undo.
DEFINE VARIABLE accum-qnty as decimal no-undo.
DEFINE VARIABLE accum-tot-doc as decimal no-undo.
DEFINE VARIABLE accum-discnt as decimal no-undo.
DEFINE VARIABLE accum-netto as decimal no-undo.
DEFINE VARIABLE fgds-discnt-pc as decimal no-undo.
DEFINE VARIABLE for-gds-price like ub.chk-gds.price-base no-undo.
DEFINE VARIABLE for-gds-brutto like ub.chk-doc.netto no-undo.
DEFINE VARIABLE for-gds-netto like ub.chk-doc.netto no-undo.
DEFINE VARIABLE for-gds-discnt like ub.chk-doc.netto no-undo.
define variable v-write-off as logical no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-base-code like ub.sysconf.host-code no-undo .
define variable v-base-type like ub.currency.curr-abbr no-undo .
define buffer buf_currency for ub.currency.
if v-curr-r-b = 'base':U then do:
  if v-print-host-code <> ? then do:
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-print-host-code
  ,output v-base-code
  )  .
    find first buf_currency where
            buf_currency.curr-code = v-base-code.
    assign
    v-base-type = buf_currency.curr-abbr.
  end.
end.
assign
v-header-base-curr = string( "( Б.Вал. - " + caps( v-base-type ) + " )" )
.
DEFINE FRAME Goods-Frame
chk-gds.doc-code column-label "Номер_чека" FORMAT "X(18)"
chk-gds.line-num column-label "NN" format "-99"
chk-gds.is-error COLUMN-LABEL "Ош" FORMAT "+/ "
chk-gds.src-code Column-label "Код в спул-файле" FORMAT "X(16)"
chk-gds.pump column-label "ТРК"
chk-gds.nozzle-code column-label "Пист"
chk-gds.loc1 column-label "Рез"
chk-gds.doc-qnty
chk-gds.price-base
chk-gds.discnt
fgds-discnt-pc COLUMn-LABEL "% ск."  FORMAT "->9.99%"
for-gds-price COLUMN-LABEL "Цена нетто"
v-write-off COLUMn-LABEL "Сп" FORMAT "+/"
chk-gds.road-tax
for-gds-brutto COLUMN-LABEL "Сумма брутто"
for-gds-discnt COLUMN-LABEL "Сумма скидки"
for-gds-netto COLUMN-LABEL "Сумма нетто"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
 Line format "X(230)" AT 1
with width 232 down stream-io use-text .
Line = fill("-", 183).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
(frame Dialog-Frame:title + chr(32) + "- строки чеков")
format "x(180)" SKIP(1) .
FORM HEADER
Line format "X(230)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME Goods-Frame  .
run waitfram-show in this-procedure ( input "Ждите..." ).
GET next br-docs no-lock.
DO WHILE available chk-gds :
    assign
    fgds-discnt-pc = (chk-gds.discnt / (chk-gds.price-base + chk-gds.price-service) * 100)
    for-gds-brutto = (chk-gds.price-base + chk-gds.price-service) * chk-gds.doc-qnty
    for-gds-discnt = chk-gds.discnt * chk-gds.doc-qnty
    for-gds-netto = (chk-gds.price-base + chk-gds.price-service - chk-gds.discnt) * chk-gds.doc-qnty
    for-gds-price = chk-gds.price-base + chk-gds.price-service - chk-gds.discnt
    .
    DISPLAY Stream PrnLibStream
    chk-gds.doc-code
    chk-gds.line-num
    chk-gds.is-error
    chk-gds.src-code
    chk-gds.pump
    chk-gds.nozzle-code
    chk-gds.loc1
    chk-gds.doc-qnty
    (chk-gds.price-base + chk-gds.price-service) @ chk-gds.price-base
    chk-gds.discnt
    fgds-discnt-pc
    for-gds-price
    (if chk-gds.write-off-code <> ?
    and chk-gds.write-off-code <> 0
    then yes
    else no
    )  @ v-write-off
    chk-gds.road-tax
    for-gds-brutto
    for-gds-discnt
    for-gds-netto
    WITH FRAME Goods-Frame.
    DOWN STREAM PrnLibStream with FRAME Goods-Frame .
    assign
    accum-count = accum-count + 1
    accum-qnty = accum-qnty + chk-gds.doc-qnty
    accum-tot-doc = accum-tot-doc + chk-gds.doc-qnty * (chk-gds.price-base + price-service)
    accum-discnt = accum-discnt + chk-gds.doc-qnty * chk-gds.discnt
    accum-netto = accum-netto + chk-gds.doc-qnty * (chk-gds.price-base + chk-gds.price-service - chk-gds.discnt)
    .
  GET next br-docs no-lock.
END.
UNDERLINE  STREAM PrnLibStream
chk-gds.doc-code
chk-gds.line-num
chk-gds.is-error
chk-gds.src-code
chk-gds.pump
chk-gds.nozzle-code
chk-gds.loc1
chk-gds.doc-qnty
chk-gds.price-base
chk-gds.discnt
fgds-discnt-pc
for-gds-price
v-write-off
chk-gds.road-tax
for-gds-brutto
for-gds-discnt
for-gds-netto
with FRAME Goods-Frame .
DISPLAY STREAM PrnLibStream
"ИТОГО"  @ chk-gds.doc-code
"_" @ chk-gds.line-num
"_" @ chk-gds.is-error
string(accum-count) @ chk-gds.src-code
"__" @ chk-gds.pump
"___" @ chk-gds.nozzle-code
"___" @ chk-gds.loc1
"_" @ chk-gds.price-base
"_" @ chk-gds.discnt
"_" @ fgds-discnt-pc
"_" @ for-gds-price
"_" @ v-write-off
"_" @ chk-gds.road-tax
ACCUM-qnty @ chk-gds.doc-qnty
accum-tot-doc @ for-gds-brutto
accum-discnt @ for-gds-discnt
accum-netto @ for-gds-netto
WITH FRAME Goods-Frame.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME Goods-Frame.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
PROCEDURE proc-b-del :
define input parameter del-type as character no-undo.
define variable old-netto as decimal no-undo.
define  variable old-tot-doc as decimal no-undo.
define  variable old-discnt as decimal no-undo.
define variable glog as logical no-undo .
define buffer buf_inkas for ub.inkas .
define buffer del_chk-doc for ub.chk-doc.
define variable v-rec as recid no-undo .
IF par-mode = 'продажа':U then do:
CASE del-type:
   when "list":U then do:
        if index(frame Dialog-Frame:title,"ФИЛЬТР" ) = 0 then do:
       message
       "Вы хотите исключить ВСЕ чеки с товаром, проданным по данному бар-коду из продажи!" skip
       "Эта процедура может занять долгое время! Продолжать?"
       view-as alert-box WARNING buttons YES-NO update glog.
       if NOT glog then return error.
     end.
     ELSE DO:
       message
       "Вы действительно хотите исключить ВСЕ чеки текущему списка с товаром, проданным по данному бар-коду из продажи?!" skip
       view-as alert-box WARNING buttons YES-NO update glog.
       if NOT glog then return error.
     END.
      DO WHILE available c-doc :
            GET prev br-docs no-lock.
      END.
      GET next br-docs.
      _list0:
      DO WHILE available c-doc
      on error undo, next _list0
      on stop undo, next _list0
      :
        v-doc-rec = recid( c-doc ).
        FIND FIRST del_chk-doc where
                          recid (del_chk-doc) = v-doc-rec No-ERROR.
        if not avail del_chk-doc then NEXT _list0.
        if del_chk-doc.out-code <> ? then DO  :
          run waitfram-show in this-procedure ( input "Ждите...").
          FIND FIRST buf_inkas No-LOCK WHERE
                          buf_inkas.inkas-code = del_chk-doc.out-code No-ERROR.
          assign
          old-netto = buf_inkas.netto
          old-tot-doc = buf_inkas.tot-doc
          old-discnt = buf_inkas.discnt.
          run str/excl-chk.p (
                              input parparentproc
                            , input v-curr-r-b
                           , buffer del_chk-doc) no-error.
          if error-status:error OR
          buf_inkas.netto <> old-netto  - del_chk-doc.netto OR
          buf_inkas.tot-doc <> old-tot-doc  - del_chk-doc.tot-doc OR
          buf_inkas.discnt <> old-discnt - del_chk-doc.discnt then do:
            message
            substitute("Исключение чека &1 из продажи &2 не удалось:&3&4 &5"
                     ,del_chk-doc.doc-code
                     ,buf_inkas.inkas-code
                     , chr(10)
                     ,error-status:get-message(1)
                     ,return-value
                     )
            view-as alert-box ERROR.
            undo, NEXT.
          end.
          deleted = yes.
        END.
        GET next br-docs.
      END.
      run waitfram-hide in this-procedure .
      del-type = "".
      RUN OpenBr in this-procedure ( input yes, input no, input '':U).
      APPLY "page-UP"   to br-docs.
      APPLY "page-down"   to br-docs.
      reposition br-docs to row 1 no-error.
      apply "entry" to br-docs in frame Dialog-Frame.
   end.
   when "one":U then do:
    if c-doc.out-code <> ? then do:
    v-doc-rec = recid (c-doc).
       get prev br-docs .
       v-rec = ?.
       if not available chk-gds then get first br-docs.
       else do :
        v-rec = recid(chk-gds).
       end.
       FIND FIRST del_chk-doc where
                  recid (del_chk-doc) = v-doc-rec No-ERROR.
       if not avail del_chk-doc then return error.
       FIND FIRST buf_inkas No-LOCK WHERE
                  buf_inkas.inkas-code = del_chk-doc.out-code No-ERROR.
       assign
       old-netto = buf_inkas.netto
       old-tot-doc = buf_inkas.tot-doc
       old-discnt = buf_inkas.discnt.
       del-type = "".
       run str/excl-chk.p (   input parparentproc
                        , input v-curr-r-b
                        , buffer del_chk-doc) no-error.
       if error-status:error  OR
       buf_inkas.netto <> old-netto  - del_chk-doc.netto OR
       buf_inkas.tot-doc <> old-tot-doc  - del_chk-doc.tot-doc OR
       buf_inkas.discnt <> old-discnt - del_chk-doc.discnt then do:
         message
         substitute("Исключение чека &1 из продажи &2 не удалось:&3&4 &5"
                     ,del_chk-doc.doc-code
                     ,buf_inkas.inkas-code
                     , chr(10)
                     ,error-status:get-message(1)
                     ,return-value
                     )
         view-as alert-box ERROR.
         return error.
       end.
       deleted = yes.
       RUN OpenBr in this-procedure ( input yes, input no, input '':U).
       if v-rec <> ? then reposition br-docs to recid v-rec no-error.
       do with frame dialog-frame:
          apply "entry":u to browse br-docs .
          apply "VALUE-CHANGED":u to browse br-docs .
       end.
    end.
  end.
END CASE.
end.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'chk-gds'
  join-tbl = 'chk-gds'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', 'Дата чека', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('out-code', 'Номер продажи', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('line-num', 'Номер строки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-code', 'Исходный код', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-qnty', 'Кол-во', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('price-base', 'Цена продажи', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pump', 'N ТРК', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('nozzle-code', 'Пистолет', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('loc1', 'Резервуар', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                  , INPUT (filter-point + chr(4) + filter-label)
                  , INPUT tbl
                  , INPUT join-tbl
                  , INPUT fld
                  , INPUT lab
                  , INPUT spr
                  , INPUT dim ).
  if return-value = 'undo':U then return error.
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
PROCEDURE proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code like ub.chk-doc.doc-code no-undo.
display
"  /  /":U @ sch-date
0 @ sch-price
with frame Dialog-Frame.
assign
pardoc-code = chr(34) + pardoc-code + chr(34).
run OpenBr in this-procedure (
     input false
    ,input par-next
    ,input substitute("and chk-gds.doc-code   begins &1 "
      , pardoc-code)
    ).
apply "entry":u to sch-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-date :
define input parameter par-next as logical no-undo.
define input parameter parchk-date like ub.chk-doc.chk-date no-undo.
define variable varchk-datechr as character no-undo.
display
'':U @ sch-code
0 @ sch-price
with frame Dialog-Frame.
assign
varchk-datechr = string(day(parchk-date)) + chr(47) +
                 string(month(parchk-date)) + chr(47) +
                 string(year(parchk-date)).
run OpenBr in this-procedure (
   input false
  ,input true
  ,input substitute("and chk-gds.chk-date = &1 "
    , varchk-datechr)
  ).
apply "entry":u to sch-date in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-find-price :
define input parameter par-next as logical no-undo.
define input parameter par-price-base like ub.chk-gds.price-base no-undo.
display
"  /  /":U @ sch-date
"":U @ sch-code
with frame Dialog-Frame.
run OpenBr in this-procedure (
     input false
    ,input par-next
    ,input substitute("and chk-gds.price-base = &1 "
      , par-price-base)
    ).
apply "entry":u to sch-price in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE reposition-chk-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-chk-doc-recid as recid no-undo .
define variable v-chk-gds-recid  as recid no-undo .
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
      if not available c-doc then do:
        message
        "Это первый чек списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-docs.
      if not available c-doc then do:
        message
        "Это последний чек списка"
        view-as alert-box.
      end.
    end.
  end case .
  assign
  p-chk-doc-recid = recid(c-doc)
  v-chk-gds-recid = recid (chk-gds)
  .
  run reposition-query in this-procedure
    (input v-chk-gds-recid
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
