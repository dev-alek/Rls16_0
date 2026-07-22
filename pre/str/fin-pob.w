define variable  vss-revision    as character no-undo init "$Revision$":U .
define variable  vss-author      as character no-undo init "$Author$":U .
define variable  vss-date        as character no-undo init "$Date$":U .
define variable  vss-workfile    as character no-undo init "$Workfile$":U .
define variable  vss-archive     as character no-undo init "$Archive$":U .
define variable  vss-description as character no-undo init "Список пред.фин.обязательств".
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
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as character   no-undo .
define input parameter par-mode  as character   no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter par-host-code like ub.clients.obj-code no-undo.
define input parameter p-doc-type   as character no-undo .
define input parameter p-status_   as character no-undo .
define input parameter p-char      as character no-undo .
define output param rid-list    as  character no-undo .
define variable g-log as logical no-undo .
define variable doc-rec as recid no-undo .
define variable g#report-num as integer no-undo .
define variable p-base-code as integer no-undo .
define variable l-curr as character no-undo .
define variable p-contr as character no-undo .
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
define new global shared variable g#lib-farh as handle no-undo .
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
define variable filter-point as character no-undo init "Список пред.финобязательства" .
define variable filter-point0 as character no-undo init "пред.Фин_обязательства_" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .
define new shared variable br-handle as handle  no-undo .
define new shared variable next-prev as logical no-undo .
DEFINE NEW SHARED BUFFER buf_fin-liab-before FOR ub.fin-ob-before.
DEFINE NEW SHARED BUFFER buf_fin-liab        FOR ub.fin-ob.
define buffer find_code for ub.fin-ob-before .
FUNCTION contract-id RETURNS CHARACTER
  ( p-curr-code as recid )  FORWARD.
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int )  FORWARD.
FUNCTION val-abbr-type RETURNS CHARACTER
( p-curr-code as recid )  FORWARD.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удаление записи"
     BGCOLOR 8 .
DEFINE BUTTON b-exec-fo
     LABEL "&Генерация"
     SIZE 10 BY 1 TOOLTIP "Создание фин.обязательств по ПФО"
     BGCOLOR 8 .
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Export
     LABEL "&Экспорт"
     SIZE 10 BY 1 TOOLTIP "Экспорт в XML"
     BGCOLOR 8 .
DEFINE BUTTON B-fo
     LABEL "Фин.Об&яз."
     SIZE 10 BY 1 TOOLTIP "Просмотр фин.обязательства"
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр записи".
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить строки списка"
     BGCOLOR 8 .
DEFINE BUTTON B-parts
     LABEL "Па&ртии"
     SIZE 10 BY 1 TOOLTIP "Просмотр складского документа"
     BGCOLOR 8 .
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1 TOOLTIP "Печать текущего списка"
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1 TOOLTIP "Фильтрация списка"
     BGCOLOR 8 .
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1 TOOLTIP "Выбор отмеченных или текущей записи"
     BGCOLOR 8 .
DEFINE BUTTON B-trn
     LABEL "Р&Н"
     SIZE 7 BY 1 TOOLTIP "Просмотр складского документа"
     BGCOLOR 8 .
DEFINE BUTTON B-trn-2
     LABEL "ПН"
     SIZE 7 BY 1 TOOLTIP "Просмотр складского документа"
     BGCOLOR 8 .
DEFINE VARIABLE d-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "ПОИСК ПО"
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_payer-name AS CHARACTER FORMAT "X(40)"
     LABEL "Плательщик"
      VIEW-AS TEXT
     SIZE 21.13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_receiver-name AS CHARACTER FORMAT "X(40)"
     LABEL "Получатель"
      VIEW-AS TEXT
     SIZE 21.13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_sum-base AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма б.в."
      VIEW-AS TEXT
     SIZE 17.5 BY .67 NO-UNDO.
DEFINE VARIABLE loc_sum-contr AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма дог."
      VIEW-AS TEXT
     SIZE 17.5 BY .67 TOOLTIP "Сумма в валюте договора" NO-UNDO.
DEFINE VARIABLE loc_sum-doc AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма док."
      VIEW-AS TEXT
     SIZE 17.5 BY .67 NO-UNDO.
DEFINE VARIABLE loc_sum-rubl AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма abbr_rub."
      VIEW-AS TEXT
     SIZE 17.5 BY .67 NO-UNDO.
DEFINE VARIABLE loc_user-name AS CHARACTER FORMAT "X(10)"
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 12.88 BY .67 NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE p-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 12.75 BY 1 TOOLTIP "Поиск по дате создания пред.фин.об. Поиск первой записи - <ВВОД>;  поиск следующей - <CTRL-J>"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE p-desc AS CHARACTER FORMAT "X(80)":U
     LABEL "№ договора"
     VIEW-AS FILL-IN
     SIZE 12.75 BY 1 TOOLTIP "Поиск по № договора  Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE p-desc-2 AS CHARACTER FORMAT "X(80)":U
     LABEL "№ РН"
     VIEW-AS FILL-IN
     SIZE 12.75 BY 1 TOOLTIP "Поиск по № РН  Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE r-abbr AS CHARACTER FORMAT "X(256)":U INITIAL "abbr_rub_allshift"
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(12)":U
     LABEL "№ ПредФинОбяз"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск по номеру Поиск первой записи - <ВВОД>; поиск следующей -  <CTRL-J>"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scr-proc AS DECIMAL FORMAT "->>>>9.99%":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9.5 BY .67 TOOLTIP "Процент суммы ПФО к сумме ПН"
     BGCOLOR 4 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE v-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE v-abbr-contr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE T-paket AS LOGICAL INITIAL no
     LABEL "П&акетный режим"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 TOOLTIP "Работа с выделенным списком пред.финобязательств" NO-UNDO.
DEFINE QUERY BR-docs FOR
      buf_fin-liab-before SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      ub.fin-ob-before SCROLLING.
DEFINE BROWSE BR-docs
  QUERY BR-docs DISPLAY
      mark-string(recid( ub.buf_fin-liab-before), rid-list)    COLUMN-LABEL '*'          FORMAT "x(1)"
     buf_fin-liab-before.prn-doc-code    COLUMN-LABEL '№ ПФО'          Format "x(10)"
     val-abbr-type(recid( buf_fin-liab-before))  @ l-curr  COLUMN-LABEL 'Вал'         Format "x(3)"
     buf_fin-liab-before.sum-doc   COLUMN-LABEL 'Сумма в вал.док.'
     buf_fin-liab-before.trn-doc-code   COLUMN-LABEL '№ РН'         Format "x(14)"
     buf_fin-liab-before.doc-code   COLUMN-LABEL 'ФинОб'         Format "x(14)"
     buf_fin-liab-before.trn-doc-code-orig   COLUMN-LABEL '№ ПН'         Format "x(14)"
     substring(string(buf_fin-liab-before.doc-date),1,5)    COLUMN-LABEL 'Создан'          format "x(5)"
     buf_fin-liab-before.fact-date    COLUMN-LABEL 'Закрыт'          format "99/99/99"
     contract-id(recid( buf_fin-liab-before))  @ p-contr  COLUMN-LABEL 'Договор'          Format "x(16)"
     (buf_fin-liab-before.receiver-type + ' ' + string(buf_fin-liab-before.receiver-code))    COLUMN-LABEL 'Получатель'          Format "x(10)"
     (buf_fin-liab-before.payer-type + ' ' + string(buf_fin-liab-before.payer-code))    COLUMN-LABEL 'Плательщик'          Format "x(10)"
     buf_fin-liab-before.sum-rubl   COLUMN-LABEL 'Сумма РУБ'
       buf_fin-liab-before.status_
      enable buf_fin-liab-before.prn-doc-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 93.75 BY 15.79.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-sch AT ROW 1 COL 31
     b-exec-fo AT ROW 1 COL 41
     B-trn AT ROW 1 COL 51
     B-trn-2 AT ROW 1 COL 58
     B-parts AT ROW 1 COL 65.13
     B-print AT ROW 1 COL 75.13
     B-Help AT ROW 1 COL 85.13
     B-lkp AT ROW 2.13 COL 1
     B-del AT ROW 2.13 COL 11
     B-fo AT ROW 2.13 COL 21
     B-Export AT ROW 2.13 COL 31
     BR-docs AT ROW 3.25 COL 1.25
     T-paket AT ROW 19.96 COL 74.13
     sch-code AT ROW 22.5 COL 1.5
     p-date AT ROW 22.5 COL 31.5
     p-desc-2 AT ROW 22.5 COL 51
     p-desc AT ROW 22.5 COL 70.5
     mark-num AT ROW 1 COL 14.88 NO-LABEL
     scr-proc AT ROW 2.25 COL 83.5 COLON-ALIGNED NO-LABEL
     loc_receiver-name AT ROW 19.13 COL 1.88
     loc_sum-doc AT ROW 19.13 COL 45.25 COLON-ALIGNED
     d-abbr AT ROW 19.13 COL 63.63 COLON-ALIGNED NO-LABEL
     loc_user-name AT ROW 19.13 COL 79.88 COLON-ALIGNED
     loc_payer-name AT ROW 19.96 COL 1.88
     loc_sum-rubl AT ROW 19.96 COL 45.25 COLON-ALIGNED
     r-abbr AT ROW 19.96 COL 63.63 COLON-ALIGNED NO-LABEL
     loc_sum-base AT ROW 20.79 COL 45.25 COLON-ALIGNED
     v-abbr AT ROW 20.79 COL 63.63 COLON-ALIGNED NO-LABEL
     loc_sum-contr AT ROW 21.58 COL 45.25 COLON-ALIGNED
     v-abbr-contr AT ROW 21.58 COL 63.63 COLON-ALIGNED NO-LABEL
     FILL-IN-1 AT ROW 21.88 COL 1 NO-LABEL
     SPACE(85.62) SKIP(1.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "ПредФинОбязательства"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BR-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 2.
ASSIGN
       T-paket:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
if not available buf_fin-liab-before then return .
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_deletion':U
    ,input  'firm':U
    ,input  par-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
if not g-log then  return .
  else do:
      message "Удалить запись ?"
      view-as alert-box question
      buttons yes-no
      update g-log.
      if g-log = false then return no-apply.
  end.
  if  buf_fin-liab-before.status_ = 'факт':U then do:
      message "ПредФинОбязательство в статусе ФАКТ не может быть удалено !!!"
      view-as alert-box information .
      return no-apply.
  end.
  find current buf_fin-liab-before  exclusive-lock  no-error .
  if available buf_fin-liab-before then do:
    delete buf_fin-liab-before .
    run openbr in this-procedure (yes, no, '':u).
  end.
END.
ON CHOOSE OF b-exec-fo IN FRAME Dialog-Frame
DO:
define variable par-text as character no-undo .
  run str/gen-bfl.p (
      input parParentProc,
      input par-host-code,
      input true ,
      output par-text
      ).
  run openbr in this-procedure (yes, no, '':u).
END.
ON CHOOSE OF B-Export IN FRAME Dialog-Frame
DO:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_export':U
    ,input  'firm':U
    ,input  par-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
if not g-log then  return .
  run proc-b-exp in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-fo IN FRAME Dialog-Frame
DO:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_lookup':U
    ,input  'firm':U
    ,input  par-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
if not g-log then  return .
define variable rr as recid no-undo .
define variable v-doc-type like ub.fin-ob.doc-type  no-undo .
define variable v-status_  like ub.fin-ob.status_   no-undo .
define buffer buf_fin-ob for ub.fin-ob .
find first buf_fin-ob no-lock where buf_fin-ob.doc-code = buf_fin-liab-before.doc-code no-error .
    if available buf_fin-ob then do:
        rr = recid( buf_fin-ob ).
        find first buf_fin-liab no-lock where recid (buf_fin-liab) = rr no-error .
        v-doc-type = buf_fin-ob.doc-type .
        v-status_  = buf_fin-ob.status_  .
        br-handle = ? .
        next-prev = ?.
        run str/fi-liabi.w ( parParentProc, 'ПРОСМОТР':U , input-output rr , input par-host-code  , input v-doc-type, input v-status_).
        br-handle = ? .
     end.
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_lookup':U
    ,input  'firm':U
    ,input  par-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
if not g-log then  return .
define variable rr as recid no-undo .
    if available buf_fin-liab-before then do:
        rr = recid( buf_fin-liab-before ).
        p-doc-type = buf_fin-liab-before.doc-type .
        p-status_  = buf_fin-liab-before.status_  .
      br-handle = BR-docs:handle in frame Dialog-Frame .
      next-prev = no.
      do while next-prev <> ?:
        if not available buf_fin-liab-before then do:
          message "Неправильный выбор документа.".
          return no-apply.
        end.
        run str/fi-liabb.w ( parParentProc, 'ПРОСМОТР':U , input-output rr , input par-host-code  , input p-doc-type, input p-status_).
        if br-handle = ? then reposition BR-docs to recid rr no-error.
      end.
     end.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
      if available buf_fin-liab-before then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid16 as character no-undo .
define variable v-num-entry16 as integer   no-undo .
assign
  v-str-recid16 = trim( string( recid( buf_fin-liab-before ) , "->>>>>>>>>>>9":U ) )
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
        g-log = br-docs:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = br-docs:select-next-row ().
            apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
        end.
        if num-entries( rid-list ) = 0
        then
            hide mark-num in frame Dialog-Frame.
        else do:
            mark-num:screen-value in frame Dialog-Frame  = string (num-entries( rid-list )) .
            enable mark-num with frame Dialog-Frame.
            end.
    end.
    apply "entry" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF B-parts IN FRAME Dialog-Frame
DO:
    if not available buf_fin-liab-before then return .
    run str/fi-parts.w
      (input parParentProc ,
       input buf_fin-liab-before.before-code ,
       input par-host-code  ) .
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  run print-proc in this-procedure .
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
    if ( available buf_fin-liab-before ) AND ( rid-list = "" ) then
    rid-list = string( recid( buf_fin-liab-before ) ) .
END.
ON CHOOSE OF B-trn IN FRAME Dialog-Frame
DO:
define buffer buf_trn-doc for ub.trn-doc.
define buffer buff_fin-ob-trn for ub.fin-ob-trn.
define variable glog as logical no-undo .
if not available buf_fin-liab-before then return .
if  buf_fin-liab-before.trn-doc-code <> ""
  and buf_fin-liab-before.trn-doc-code <> ?
  then do:
   find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_fin-liab-before.trn-doc-code no-error .
   if available buf_trn-doc then do:
      run str/fishdoc.p (  ParParentProc,
                      par-host-code   ,
                      buf_trn-doc.obj-type ,
                      buf_trn-doc.obj-code ,
                      buf_fin-liab-before.trn-doc-code ,
                      ? ) .
      end.
  end.
  else do:
      find first buff_fin-ob-trn no-lock where buff_fin-ob-trn.doc-code = buf_fin-liab-before.before-code     no-error .
      find first buf_trn-doc     no-lock where buf_trn-doc.doc-code     = buff_fin-ob-trn.trn-doc-code no-error .
      if available buff_fin-ob-trn then do:
              run str/fishdoc.p ( ParParentProc,
                  par-host-code        ,
                  buf_trn-doc.obj-type ,
                  buf_trn-doc.obj-code ,
                  buff_fin-ob-trn.trn-doc-code ,
                  ? ) .
      end.
  end.
END.
ON CHOOSE OF B-trn-2 IN FRAME Dialog-Frame
DO:
define buffer buf_trn-doc for ub.trn-doc.
define variable glog as logical no-undo .
if not available buf_fin-liab-before then return .
if  buf_fin-liab-before.trn-doc-code-orig <> ""
  and buf_fin-liab-before.trn-doc-code-orig <> ?
  then do:
   find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_fin-liab-before.trn-doc-code-orig no-error .
   if available buf_trn-doc then do:
      run str/fishdoc.p (  ParParentProc,
                 par-host-code ,
                 buf_trn-doc.obj-type,
                 buf_trn-doc.obj-code,
                 buf_fin-liab-before.trn-doc-code-orig , ? ) .
      end.
  end.
  else do:
  end.
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
        apply "choose" to B-lkp in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
if available buf_fin-liab-before then do:
    assign
    loc_receiver-name  = buf_fin-liab-before.receiver-name
    loc_payer-name        = buf_fin-liab-before.payer-name
    loc_sum-base  = buf_fin-liab-before.sum-base
    loc_sum-doc   = buf_fin-liab-before.sum-doc
    loc_sum-rubl  = buf_fin-liab-before.sum-rubl
    loc_sum-contr  =  buf_fin-liab-before.sum-contract
    d-abbr        = sel-abbr(buf_fin-liab-before.curr-code)
    v-abbr        = sel-abbr(p-base-code)
    v-abbr-contr    = sel-abbr(buf_fin-liab-before.contract-curr)
    loc_user-name = buf_fin-liab-before.user-name-doc
  .
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  buf_fin-liab-before.user-name-doc
  ,output loc_user-name
  )  .
end.
else
 assign
   loc_receiver-name  = ""
   loc_payer-name        = ""
   loc_sum-base            = 0
   loc_sum-doc             = 0
   loc_sum-rubl            = 0
   loc_user-name           = ""
   d-abbr                         = ""
   loc_sum-contr            = 0
      v-abbr-contr  = ""
    .
display
  loc_receiver-name
  loc_payer-name
  loc_sum-base
  loc_sum-doc
  loc_sum-rubl
  loc_sum-contr
  r-abbr
  v-abbr
  d-abbr
  loc_user-name
  v-abbr-contr
  with frame Dialog-Frame.
END.
ON LEAVE OF p-date IN FRAME Dialog-Frame
DO:
END.
ON CTRL-J OF p-date IN FRAME Dialog-Frame
DO:
assign p-date no-error .
  if error-status:error then return no-apply.
      run proc-find-date in this-procedure(yes, p-date) no-error.
      if error-status:error then return no-apply.
END.
ON RETURN OF p-date IN FRAME Dialog-Frame
DO:
assign p-date no-error .
if error-status:error then return no-apply.
  run proc-find-date in this-procedure(no, p-date) no-error.
  return no-apply.
END.
ON LEAVE OF p-desc IN FRAME Dialog-Frame
DO:
END.
ON CTRL-J OF p-desc IN FRAME Dialog-Frame
DO:
  run proc-find-desc in this-procedure(yes, input frame Dialog-Frame p-desc) no-error.
    if error-status:error then return no-apply.
END.
ON RETURN OF p-desc IN FRAME Dialog-Frame
DO:
  run proc-find-desc in this-procedure(no, input frame Dialog-Frame p-desc) no-error.
  return no-apply.
END.
ON LEAVE OF p-desc-2 IN FRAME Dialog-Frame
DO:
END.
ON CTRL-J OF p-desc-2 IN FRAME Dialog-Frame
DO:
  run proc-find-desc-2 in this-procedure(yes, input frame Dialog-Frame p-desc-2) no-error.
    if error-status:error then return no-apply.
END.
ON RETURN OF p-desc-2 IN FRAME Dialog-Frame
DO:
  run proc-find-desc-2 in this-procedure(no, input frame Dialog-Frame p-desc-2) no-error.
  return no-apply.
END.
ON RETURN OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure(no, input frame Dialog-Frame sch-code) no-error.
  return no-apply.
END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure(yes, input frame Dialog-Frame sch-code) no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF T-paket IN FRAME Dialog-Frame
DO:
  assign T-paket.
END.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-docs :SET-REPOSITIONED-ROW(8, "CONDITIONAL") .
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of p-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of p-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of p-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of p-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of p-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of p-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date23
    MENU-ITEM m-ed-date23-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date23-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date23-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date23-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if p-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      p-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date23 :HANDLE
      p-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle23 as handle no-undo .
  assign
    v-label-handle23 = p-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle23)
  then do:
    if v-label-handle23 :tooltip = ""
    or v-label-handle23 :tooltip = ?
    then do:
      assign
        v-label-handle23 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date23-1 in menu m-ed-date23 DO:
    apply "ctrl-b":U to p-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date23-2 in menu m-ed-date23 DO:
    apply "ctrl-d":U to p-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date23-3 in menu m-ed-date23 DO:
    apply "ctrl-e":U to p-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date23-4 in menu m-ed-date23 DO:
    apply "ctrl-f":U to p-date in frame Dialog-Frame .
  END.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numBR-docs as INT EXTENT 13 no-undo.
DEF VAR varmviBR-docs       as INT no-undo.
DEF VAR varmvjBR-docs       as INT no-undo.
DEF VAR varmvkBR-docs       as INT no-undo.
DEF VAR varmvlBR-docs       as INT no-undo.
DEF VAR move-elementBR-docs as INT no-undo.
def var jjBR-docs           as int no-undo.
do varmviBR-docs = 1 to EXTENT(cur-clmn-numBR-docs):
  ASSIGN cur-clmn-numBR-docs[varmviBR-docs] = varmviBR-docs.
END.
RUN start-mv-clmnBR-docs.
PROCEDURE start-mv-clmnBR-docs:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE BR-docs do:
  RUN re-move-clmnBR-docs ( 3, 13).
END.
ON ctrl-cursor-left OF BROWSE BR-docs do:
  RUN re-move-clmnBR-docs (13, 3).
END.
PROCEDURE re-move-clmnBR-docs:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmviBR-docs = 1 TO EXTENT(cur-clmn-numBR-docs):
    if cur-clmn-numBR-docs[varmviBR-docs] = source-column THEN cur-clmn-numBR-docs[varmviBR-docs] = -1.
  END.
  if BR-docs:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjBR-docs = source-column - 1 to target-column BY -1:
    DO varmviBR-docs = 1 TO EXTENT(cur-clmn-numBR-docs):
        if cur-clmn-numBR-docs[varmviBR-docs] = varmvjBR-docs THEN DO:
          cur-clmn-numBR-docs[varmviBR-docs] = cur-clmn-numBR-docs[varmviBR-docs] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjBR-docs = source-column + 1 to target-column:
    DO varmviBR-docs = 1 TO EXTENT(cur-clmn-numBR-docs):
      if cur-clmn-numBR-docs[varmviBR-docs] = varmvjBR-docs THEN DO:
        cur-clmn-numBR-docs[varmviBR-docs] = cur-clmn-numBR-docs[varmviBR-docs] - 1.
      END.
    END.
  END.
  DO varmviBR-docs = 1 TO EXTENT(cur-clmn-numBR-docs):
    if cur-clmn-numBR-docs[varmviBR-docs] = -1 THEN cur-clmn-numBR-docs[varmviBR-docs] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnBR-docs:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 3 then do:
    return .
  end.
  DO varmviBR-docs = 1 TO EXTENT(cur-clmn-numBR-docs):
    if cur-clmn-numBR-docs[varmviBR-docs] = cur-clmn-loc THEN move-elementBR-docs = varmviBR-docs.
  END.
  RUN re-move-clmnBR-docs (cur-clmn-loc, 3).
END PROCEDURE.
PROCEDURE mv-brw-defaultBR-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlBR-docs = 3 to EXTENT(cur-clmn-numBR-docs):
    RUN re-move-clmnBR-docs (cur-clmn-numBR-docs[varmvlBR-docs], varmvlBR-docs).
  END.
  RUN start-mv-clmnBR-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelBR-docs   as character no-undo .
def var sort-clmnBR-docs    as handle    no-undo .
def var cur-clmnBR-docs     as handle    no-undo .
def var cur-clmn-locBR-docs as integer   no-undo .
def var re-queryBR-docs     as logical   initial no no-undo .
on start-search, ctrl-o of BR-docs in frame Dialog-Frame do:
   run sort-brBR-docs
     (input (if available ub.fin-ob-before
             then recid(ub.fin-ob-before)
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
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(buf_fin-liab-before), &1&2&1)', chr(34), rid-list)     .     run OpenBr(yes, no, '':U).   . END.
        when '№ ПФО'  then DO:    assign       sort-column-name = "buf_fin-liab-before.prn-doc-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Создан'  then DO:    assign       sort-column-name = "substring(string(buf_fin-liab-before.doc-date),1,5)"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Закрыт'  then DO:    assign       sort-column-name = "buf_fin-liab-before.fact-date"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Договор'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1contract-id&1, recid(buf_fin-liab-before))', chr(34))     .     run OpenBr(yes, no, '':U).   . END.
        when 'Получатель'  then DO:    assign       sort-column-name = "(buf_fin-liab-before.receiver-type + ' ' + string(buf_fin-liab-before.receiver-code))"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Плательщик'  then DO:    assign       sort-column-name = "(buf_fin-liab-before.payer-type + ' ' + string(buf_fin-liab-before.payer-code))"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Сумма РУБ'  then DO:    assign       sort-column-name = "buf_fin-liab-before.sum-rubl"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Вал'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1val-abbr-type&1, recid(buf_fin-liab-before))', chr(34))     .     run OpenBr(yes, no, '':U).   . END.
        when 'Сумма в вал.док.'  then DO:    assign       sort-column-name = "buf_fin-liab-before.sum-doc"     .     run OpenBr(yes, no, '':U).   . END.
        when '№ РН'  then DO:    assign       sort-column-name = "buf_fin-liab-before.trn-doc-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'ФинОб'  then DO:    assign       sort-column-name = "buf_fin-liab-before.doc-code"     .     run OpenBr(yes, no, '':U).   . END.
        when '№ ПН'  then DO:    assign       sort-column-name = "buf_fin-liab-before.trn-doc-code-orig"     .     run OpenBr(yes, no, '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr(yes, no, '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultBR-docs') then do:
          run mv-brw-defaultBR-docs.
        end.
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
    if cur-clmn-locBR-docs <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnBR-docs') then do:
        run ch-clmnBR-docs in this-procedure (cur-clmn-locBR-docs).
      end.
    end.
  if p-recid <> ? then do:
    reposition BR-docs to recid p-recid no-error.
    apply "value-changed" to BR-docs in frame Dialog-Frame.
  end.
  apply "entry" to BR-docs in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBR-docs:
if cur-clmnBR-docs = ? then do:
   run OpenBr(yes, no, '':U).
end.
else do:
   assign re-queryBR-docs = yes.
   run sort-brBR-docs
     (input (if available ub.fin-ob-before
             then recid(ub.fin-ob-before)
             else ?
            )
     ).
   assign re-queryBR-docs = no.
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-right-supp as logical no-undo .
v-right-supp = true .
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-supp':U
    ,input  'firm':U
    ,input  par-host-code
    ,input  ''
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-right-supp
    )  .
end.
 if v-right-supp = false then return .
buf_fin-liab-before.prn-doc-code:read-only in browse BR-docs = true .
define variable p-file-label as character no-undo .
p-file-label =  "Финансовые обязательства".
r-abbr =  "РУБ".
define buffer buf_clients for  ub.clients .
CASE par-mode:
    WHEN 'фирма':U THEN DO:
      find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = 'орг':U no-error .
      if not available buf_clients then  return .
    END.
    WHEN "doc-type":U THEN DO:
      find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = 'орг':U no-error .
      if not available buf_clients then  return .
    END.
    WHEN "status":U THEN DO:
      find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = 'орг':U no-error .
      if not available buf_clients then  return .
    END.
    WHEN "fin-ob":U THEN DO:
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - par-mode=" par-mode
      view-as alert-box ERROR.
      return.
    end.
  end CASE.
    if pardoc-rec <> ? then do:
      FIND FIRST find_code No-LOCK where
                 recid(find_code) = pardoc-rec No-ERROR.
      if not avail find_code then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова pardoc-rec" pardoc-rec
        view-as alert-box error .
        return error.
      end.
      doc-rec = pardoc-rec.
    end.
  run calc-proc.
  run my-enable_ui.
  run openbr in this-procedure (yes, no, '':u).
  hide mark-num in frame Dialog-Frame .
  if pardoc-rec <> ? then
  reposition br-docs to recid doc-rec no-error.
  apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame focus br-docs.
END.
run disable_ui.
PROCEDURE calc-proc :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define buffer buf1_fin-ob for ub.fin-ob.
define buffer buf1_fin-ob-before for ub.fin-ob-before.
define variable v-PFO-sum as decimal no-undo init 0.
define variable v-FO-sum as decimal no-undo init 0 .
find first buf1_fin-ob no-lock  where
           buf1_fin-ob.host-code = par-host-code and
           buf1_fin-ob.doc-code  =  p-char
           no-error .
if error-status :error then return .
v-FO-sum = abs(buf1_fin-ob.sum-doc) .
for each buf1_fin-ob-before no-lock where
    buf1_fin-ob-before.doc-code = p-char  and
    buf1_fin-ob-before.host-code = par-host-code
    on error undo, return error :
    v-PFO-sum = v-PFO-sum + buf1_fin-ob-before.sum-doc .
end.
scr-proc =  100 * v-PFO-sum / v-FO-sum.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH ub.fin-ob-before SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY T-paket sch-code p-date p-desc-2 p-desc mark-num scr-proc
          loc_receiver-name loc_sum-doc d-abbr loc_user-name loc_payer-name
          loc_sum-rubl r-abbr loc_sum-base v-abbr loc_sum-contr v-abbr-contr
          FILL-IN-1
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-mark B-sel B-sch b-exec-fo B-trn B-trn-2 B-parts B-print
         B-Help B-lkp B-del B-fo B-Export BR-docs sch-code p-date p-desc-2
         p-desc mark-num scr-proc loc_receiver-name loc_sum-doc d-abbr
         loc_user-name loc_payer-name loc_sum-rubl r-abbr loc_sum-base v-abbr
         loc_sum-contr v-abbr-contr FILL-IN-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-docs FOR EACH buf_fin-liab-before share-lock.
END PROCEDURE.
PROCEDURE my-enable_UI :
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  par-host-code
  ,output p-base-code
  )  .
assign
loc_sum-rubl:label in frame Dialog-Frame = "Сумма руб."
.
DISPLAY sch-code p-desc p-desc-2  p-date mark-num FILL-IN-1
      scr-proc when par-mode = "fin-ob"
      WITH FRAME Dialog-Frame.
  ENABLE B-exit
         B-lkp
         b-exec-fo
         b-trn
         B-trn-2
         b-parts
         B-sch
         B-print
         B-Help
         b-sel       when LOOKUP("b-sel":U,  bttns) > 0
         b-mark      when LOOKUP("b-mark":U, bttns) > 0
         b-del       when LOOKUP("b-del":U,  bttns) > 0
         b-fo
         b-export
          BR-docs sch-code p-desc p-desc-2 p-date  mark-num
         T-paket
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if  par-mode <> "fin-ob" then
     hide  scr-proc in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable  l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define buffer buff_contract for ub.contract.
define variable loc_contract-code as character no-undo .
title0 = caps( "ПредФинОбязательства" ) + chr(32).
define variable  sort-column-phrase as character no-undo .
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
       find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = 'орг':U no-error .
       if not available buf_clients then return .
       filter-point = filter-point0 + par-mode.
  CASE par-mode :
    WHEN 'фирма':U THEN DO:
       ASSIGN frame Dialog-Frame:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " " +  string(par-host-code).
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-29  as logical   no-undo .
define variable  l-filter-open-29    as logical   .
define variable  flt-rec-29       as recid     no-undo .
define variable  filter-name-29      as character no-undo .
define variable  where-phrase-29     as character no-undo .
define variable  sort-phrase-29      as character no-undo .
define variable  where-phrase-rus-29 as character no-undo .
define variable  sort-phrase-rus-29  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-29
  ,output filter-name-29
  ,output where-phrase-29
  ,output sort-phrase-29
  ,output where-phrase-rus-29
  ,output sort-phrase-rus-29
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-29
      ) no-error .
  assign
    l-filter-open-29 = false
  .
  if flt-rec-29 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-29 as character no-undo .
    define variable  parameter-3-29 as character no-undo .
    define variable  parameter-4-29 as character no-undo .
    define variable  parameter-5-29 as character no-undo .
    define variable  parameter-6-29 as character no-undo .
    define variable  parameter-7-29 as character no-undo .
      assign
      parameter-3-29 =
                              "FOR EACH buf_fin-liab-before"
      parameter-4-29 =
        (
          if (" buf_fin-liab-before.host-code = par-host-code   " + " " + where-phrase-29) <> ""
          then substitute(' buf_fin-liab-before.host-code =   &1 ' , par-host-code ) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + "")
      parameter-6-29 = if sort-phrase-29 = ''
                           then
        (
        " " + " USE-INDEX by_date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX by_date " +
          " " + sort-column-phrase +
        " " + sort-phrase-29
        )
      parameter-7-29 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-29 =
          (" buf_fin-liab-before.host-code = par-host-code   " + " " + where-phrase-29 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-29
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ,input parameter-6-29
                          ,input parameter-7-29
                          )
      .
      assign
        l-filter-open-29 = true
      .
    end.
    if l-filter-open-29 = false then do:
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
  if l-filter-open-29 = false then do:
    OPEN QUERY br-docs FOR EACH buf_fin-liab-before
      where  buf_fin-liab-before.host-code = par-host-code
       USE-INDEX by_date
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_fin-liab-before )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer buf_fin-liab-before:handle) then do:
      assign
      parameter-2-29 = (if p-find-next then "true":u else "false":u )
      parameter-4-29 =
        "where ":u + substitute(' buf_fin-liab-before.host-code =   &1 ' , par-host-code ) + " ":u + where-phrase-29 + " ":u + p-find-condition + " " + ""
      parameter-5-29 = " USE-INDEX by_date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(buf_fin-liab-before)
                          ,input logical(parameter-2-29)
                          ,input no-lock
                          ,input (buffer buf_fin-liab-before:handle)
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-29 = (if p-find-next then "true":u else "false":u )
      parameter-3-29 =  "FOR EACH buf_fin-liab-before"
      parameter-4-29 =
        (
          if (" buf_fin-liab-before.host-code = par-host-code   " + " " + where-phrase-29) <> ""
          then substitute(' buf_fin-liab-before.host-code =   &1 ' , par-host-code ) + " " + where-phrase-29
          else "true"
        )
      parameter-5-29 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-29 = if sort-phrase-29 = ''
                           then
        (
        " " + " USE-INDEX by_date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX by_date " +
          " " + sort-column-phrase +
        " " + sort-phrase-29
        )
      parameter-7-29 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-29)
                          ,input no-lock
                          ,input parameter-3-29
                          ,input parameter-4-29
                          ,input parameter-5-29
                          ,input parameter-6-29
                          ,input parameter-7-29
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
    END.
    WHEN "doc-type":U THEN DO:
       ASSIGN frame Dialog-Frame:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " " +  string(par-host-code)
                                          + " Тип: " +  string(p-doc-type) .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-31  as logical   no-undo .
define variable  l-filter-open-31    as logical   .
define variable  flt-rec-31       as recid     no-undo .
define variable  filter-name-31      as character no-undo .
define variable  where-phrase-31     as character no-undo .
define variable  sort-phrase-31      as character no-undo .
define variable  where-phrase-rus-31 as character no-undo .
define variable  sort-phrase-rus-31  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-31
  ,output filter-name-31
  ,output where-phrase-31
  ,output sort-phrase-31
  ,output where-phrase-rus-31
  ,output sort-phrase-rus-31
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-31
      ) no-error .
  assign
    l-filter-open-31 = false
  .
  if flt-rec-31 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-31 as character no-undo .
    define variable  parameter-3-31 as character no-undo .
    define variable  parameter-4-31 as character no-undo .
    define variable  parameter-5-31 as character no-undo .
    define variable  parameter-6-31 as character no-undo .
    define variable  parameter-7-31 as character no-undo .
      assign
      parameter-3-31 =
                              "FOR EACH buf_fin-liab-before"
      parameter-4-31 =
        (
          if (" buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-type = p-doc-type " + " " + where-phrase-31) <> ""
          then substitute(' buf_fin-liab-before.host-code = &1 and buf_fin-liab-before.doc-type = &3&2&3 ' , par-host-code , p-doc-type , chr(34)  ) + " " + where-phrase-31
          else "true"
        )
      parameter-5-31 = (" " + "" + " " + "")
      parameter-6-31 = if sort-phrase-31 = ''
                           then
        (
        " " + " USE-INDEX by_date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX by_date " +
          " " + sort-column-phrase +
        " " + sort-phrase-31
        )
      parameter-7-31 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-31 =
          (" buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-type = p-doc-type " + " " + where-phrase-31 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-31
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ,input parameter-6-31
                          ,input parameter-7-31
                          )
      .
      assign
        l-filter-open-31 = true
      .
    end.
    if l-filter-open-31 = false then do:
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
  if l-filter-open-31 = false then do:
    OPEN QUERY br-docs FOR EACH buf_fin-liab-before
      where  buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-type = p-doc-type
       USE-INDEX by_date
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_fin-liab-before )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer buf_fin-liab-before:handle) then do:
      assign
      parameter-2-31 = (if p-find-next then "true":u else "false":u )
      parameter-4-31 =
        "where ":u + substitute(' buf_fin-liab-before.host-code = &1 and buf_fin-liab-before.doc-type = &3&2&3 ' , par-host-code , p-doc-type , chr(34)  ) + " ":u + where-phrase-31 + " ":u + p-find-condition + " " + ""
      parameter-5-31 = " USE-INDEX by_date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(buf_fin-liab-before)
                          ,input logical(parameter-2-31)
                          ,input no-lock
                          ,input (buffer buf_fin-liab-before:handle)
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-31 = (if p-find-next then "true":u else "false":u )
      parameter-3-31 =  "FOR EACH buf_fin-liab-before"
      parameter-4-31 =
        (
          if (" buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-type = p-doc-type " + " " + where-phrase-31) <> ""
          then substitute(' buf_fin-liab-before.host-code = &1 and buf_fin-liab-before.doc-type = &3&2&3 ' , par-host-code , p-doc-type , chr(34)  ) + " " + where-phrase-31
          else "true"
        )
      parameter-5-31 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-31 = if sort-phrase-31 = ''
                           then
        (
        " " + " USE-INDEX by_date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX by_date " +
          " " + sort-column-phrase +
        " " + sort-phrase-31
        )
      parameter-7-31 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-31)
                          ,input no-lock
                          ,input parameter-3-31
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ,input parameter-6-31
                          ,input parameter-7-31
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
    END.
    WHEN "status":U THEN DO:
       ASSIGN frame Dialog-Frame:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " " +  string(par-host-code)
                                          + " Тип: " +  string(p-doc-type)
                                          + " Статус: " +  string(p-status_) .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-33  as logical   no-undo .
define variable  l-filter-open-33    as logical   .
define variable  flt-rec-33       as recid     no-undo .
define variable  filter-name-33      as character no-undo .
define variable  where-phrase-33     as character no-undo .
define variable  sort-phrase-33      as character no-undo .
define variable  where-phrase-rus-33 as character no-undo .
define variable  sort-phrase-rus-33  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-33
  ,output filter-name-33
  ,output where-phrase-33
  ,output sort-phrase-33
  ,output where-phrase-rus-33
  ,output sort-phrase-rus-33
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-33
      ) no-error .
  assign
    l-filter-open-33 = false
  .
  if flt-rec-33 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-33 as character no-undo .
    define variable  parameter-3-33 as character no-undo .
    define variable  parameter-4-33 as character no-undo .
    define variable  parameter-5-33 as character no-undo .
    define variable  parameter-6-33 as character no-undo .
    define variable  parameter-7-33 as character no-undo .
      assign
      parameter-3-33 =
                              "FOR EACH buf_fin-liab-before"
      parameter-4-33 =
        (
          if (" buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-type = p-doc-type  and buf_fin-liab-before.status_= p-status_" + " " + where-phrase-33) <> ""
          then substitute(' buf_fin-liab-before.host-code = &1 and buf_fin-liab-before.doc-type = &3&2&3 and buf_fin-liab-before.status_ = &3&4&3  ' , par-host-code , p-doc-type , chr(34) , p-status_ ) + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "")
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + " USE-INDEX by_date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX by_date " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-33 =
          (" buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-type = p-doc-type  and buf_fin-liab-before.status_= p-status_" + " " + where-phrase-33 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
                          )
      .
      assign
        l-filter-open-33 = true
      .
    end.
    if l-filter-open-33 = false then do:
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
  if l-filter-open-33 = false then do:
    OPEN QUERY br-docs FOR EACH buf_fin-liab-before
      where  buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-type = p-doc-type  and buf_fin-liab-before.status_= p-status_
       USE-INDEX by_date
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_fin-liab-before )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer buf_fin-liab-before:handle) then do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-4-33 =
        "where ":u + substitute(' buf_fin-liab-before.host-code = &1 and buf_fin-liab-before.doc-type = &3&2&3 and buf_fin-liab-before.status_ = &3&4&3  ' , par-host-code , p-doc-type , chr(34) , p-status_ ) + " ":u + where-phrase-33 + " ":u + p-find-condition + " " + ""
      parameter-5-33 = " USE-INDEX by_date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(buf_fin-liab-before)
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input (buffer buf_fin-liab-before:handle)
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-3-33 =  "FOR EACH buf_fin-liab-before"
      parameter-4-33 =
        (
          if (" buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-type = p-doc-type  and buf_fin-liab-before.status_= p-status_" + " " + where-phrase-33) <> ""
          then substitute(' buf_fin-liab-before.host-code = &1 and buf_fin-liab-before.doc-type = &3&2&3 and buf_fin-liab-before.status_ = &3&4&3  ' , par-host-code , p-doc-type , chr(34) , p-status_ ) + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + " USE-INDEX by_date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX by_date " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
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
    END.
    WHEN "fin-ob":U THEN DO:
       ASSIGN frame Dialog-Frame:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " " +  string(par-host-code)
                                          + " по Фин.обязательству: " +  p-char   .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-35  as logical   no-undo .
define variable  l-filter-open-35    as logical   .
define variable  flt-rec-35       as recid     no-undo .
define variable  filter-name-35      as character no-undo .
define variable  where-phrase-35     as character no-undo .
define variable  sort-phrase-35      as character no-undo .
define variable  where-phrase-rus-35 as character no-undo .
define variable  sort-phrase-rus-35  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-35
  ,output filter-name-35
  ,output where-phrase-35
  ,output sort-phrase-35
  ,output where-phrase-rus-35
  ,output sort-phrase-rus-35
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-35
      ) no-error .
  assign
    l-filter-open-35 = false
  .
  if flt-rec-35 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-35 as character no-undo .
    define variable  parameter-3-35 as character no-undo .
    define variable  parameter-4-35 as character no-undo .
    define variable  parameter-5-35 as character no-undo .
    define variable  parameter-6-35 as character no-undo .
    define variable  parameter-7-35 as character no-undo .
      assign
      parameter-3-35 =
                              "FOR EACH buf_fin-liab-before"
      parameter-4-35 =
        (
          if (" buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-code = p-char" + " " + where-phrase-35) <> ""
          then substitute(' buf_fin-liab-before.host-code = &1 and buf_fin-liab-before.doc-code = &3&2&3 ' , par-host-code , p-char , chr(34)  ) + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "")
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + " USE-INDEX by_fo " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX by_fo " +
          " " + sort-column-phrase +
        " " + sort-phrase-35
        )
      parameter-7-35 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-35 =
          (" buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-code = p-char" + " " + where-phrase-35 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
                          )
      .
      assign
        l-filter-open-35 = true
      .
    end.
    if l-filter-open-35 = false then do:
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
  if l-filter-open-35 = false then do:
    OPEN QUERY br-docs FOR EACH buf_fin-liab-before
      where  buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-code = p-char
       USE-INDEX by_fo
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_fin-liab-before )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer buf_fin-liab-before:handle) then do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-4-35 =
        "where ":u + substitute(' buf_fin-liab-before.host-code = &1 and buf_fin-liab-before.doc-code = &3&2&3 ' , par-host-code , p-char , chr(34)  ) + " ":u + where-phrase-35 + " ":u + p-find-condition + " " + ""
      parameter-5-35 = " USE-INDEX by_fo "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(buf_fin-liab-before)
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input (buffer buf_fin-liab-before:handle)
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-3-35 =  "FOR EACH buf_fin-liab-before"
      parameter-4-35 =
        (
          if (" buf_fin-liab-before.host-code = par-host-code  and buf_fin-liab-before.doc-code = p-char" + " " + where-phrase-35) <> ""
          then substitute(' buf_fin-liab-before.host-code = &1 and buf_fin-liab-before.doc-code = &3&2&3 ' , par-host-code , p-char , chr(34)  ) + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + " USE-INDEX by_fo " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX by_fo " +
          " " + sort-column-phrase +
        " " + sort-phrase-35
        )
      parameter-7-35 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
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
    END.
END CASE.
if not p-open-query then
REPOSITION br-docs to recid doc-rec No-ERROR.
if error-status :error then return error .
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
END PROCEDURE.
PROCEDURE print-proc :
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_print':U
    ,input  'firm':U
    ,input  par-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
if not g-log then  return .
define variable  sym1  as character format "X(1)" init ":".
define variable  sym2  as character format "X(1)" init ":".
define variable  sym3  as character format "X(1)" init ":".
define variable  sym4  as character format "X(1)" init ":".
define variable  sym5  as character format "X(1)" init ":".
define variable  sym6  as character format "X(1)" init ":".
define variable  sym7  as character format "X(1)" init ":".
define variable  sym8  as character format "X(1)" init ":".
define variable  sym9  as character format "X(1)" init ":".
define variable  sym10 as character format "X(1)" init ":".
define variable  sym11 as character format "X(1)" init ":".
define variable  sym12 as character format "X(1)" init ":".
define variable  date_string     as      character    no-undo.
define variable  Line                as      character    no-undo.
define variable  for-time as char.
DEFINE FRAME prt-frame
     buf_fin-liab-before.prn-doc-code                  column-label '№ ПФО' Format "x(10)"      space(0)     sym3                      column-label "_"       format "X(1)"       space(0)
     buf_fin-liab-before.doc-date      column-label 'Создан' format  "99/99/99"  space(0)     sym4                      column-label "_"       format "X(1)"       space(0)
     buf_fin-liab-before.fact-date                  column-label 'Закрыт' format "99/99/99"   space(0)     sym5                      column-label "_"       format "X(1)"       space(0)
     p-contr                    column-label 'Договор'                     space(0)     sym6                      column-label "_"       format "X(1)"       space(0)
     buf_fin-liab-before.receiver-name column-label 'Получатель' Format "x(10)"      space(0)        sym7                      column-label "_"       format "X(1)"       space(0)
     buf_fin-liab-before.payer-name    column-label 'Плательщик' Format "x(10)"      space(0)     sym8                      column-label "_"       format "X(1)"       space(0)
     buf_fin-liab-before.sum-rubl                  column-label 'Сумма РУБ'                space(0)     sym9                      column-label "_"       format "X(1)"       space(0)
     l-curr                     column-label 'Вал' Format "x(3)"      space(0)   sym10                     column-label "_"       format "X(1)"       space(0)
     buf_fin-liab-before.sum-doc                 column-label 'Сумма в вал.док.'                    space(0)     sym11                     column-label "_"       format "X(1)"       space(0)
     buf_fin-liab-before.trn-doc-code                 column-label '№ РН' Format "x(14)"      space(0)
        HEADER  date_string AT 5 format "X(35)"
                    string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
                    Line format "X(116)" AT 1
    with width 232 down stream-io use-text    .
    Line = fill("-", 116).
    date_string = cur-time-print() .
    run prn-lib-open-stream  in this-procedure (
       input parParentProc
      ,input 43
      ,input yes
      ,input no
      ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame Dialog-Frame:title )
    format "x(116)" SKIP(1) .
    FORM HEADER
            Line format "X(177)" AT 1 SKIP
            "Продолжение - на следующей странице" AT 30 SKIP
            with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .
    FORM with FRAME prt-frame  .
    run waitfram-show in this-procedure ("Ждите...").
    run OpenBR in this-procedure (yes, no, '':U).
     DO WHILE available buf_fin-liab-before :
        Display STREAM PrnLibStream
             buf_fin-liab-before.prn-doc-code
             sym3
             buf_fin-liab-before.doc-date
             sym4
             buf_fin-liab-before.fact-date
             sym5
             contract-id(recid( buf_fin-liab-before)) @ p-contr
             sym6
             buf_fin-liab-before.receiver-name
             sym7
             buf_fin-liab-before.payer-name
             sym8
             buf_fin-liab-before.sum-rubl
             sym9
             val-abbr-type(recid( buf_fin-liab-before)) @ l-curr
             sym10
             buf_fin-liab-before.sum-doc
             sym11
             buf_fin-liab-before.trn-doc-code
            with FRAME prt-frame .
            DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
            GET next br-docs.
      END.
      UNDERLINE  STREAM PrnLibStream
             buf_fin-liab-before.prn-doc-code
             sym3
             buf_fin-liab-before.doc-date
             sym4
             buf_fin-liab-before.fact-date
             sym5
             p-contr
             sym6
             buf_fin-liab-before.receiver-name
             sym7
             buf_fin-liab-before.payer-name
             sym8
             buf_fin-liab-before.sum-rubl
             sym9
             l-curr
             sym10
             buf_fin-liab-before.sum-doc
             sym11
             buf_fin-liab-before.trn-doc-code
    with FRAME prt-frame .
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    reposition br-docs  to row 1 no-error .
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
        input parParentProc
       ,input 8
        ).
END PROCEDURE.
PROCEDURE proc-b-exp :
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable v-file-name as character no-undo .
define variable for-dir as character no-undo .
define variable accum-count as integer no-undo init 0.
define variable accum-count-ok as integer no-undo init 0 .
define variable loclog as logical no-undo .
define variable ii as integer no-undo .
define variable ii0 as integer no-undo .
define buffer buf_fin-ob-before for ub.fin-ob-before.
if not available buf_fin-liab-before then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
    assign
    v-file-name =  ?
    .
    run bge/xmlfob.p (input buf_fin-liab-before.host-code, buf_fin-liab-before.before-code, input-output v-file-name, yes, yes) no-error .
if error-status:ERROR then do:
  message
  "Ошибка при выгрузке ФО в XML-формате" skip
  error-status :get-message(1)
  view-as alert-box .
   return error .
end.
define variable v-sys-key   as character         no-undo.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
if search ("exmldoc.bat") <> ? then do:
  os-command silent value(search ("exmldoc.bat") + " " + v-file-name + " " + v-sys-key).
end.
else do:
  if search (v-file-name ) <> ? then do:
    if accum-count-ok  > 1 then
       message "ФО выгружены в файл " v-file-name view-as alert-box.
    else
      message "ФО выгружен в файл " v-file-name view-as alert-box.
  end.
end.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'ub.fin-ob-before'
  join-tbl = 'buf_fin-liab-before'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('before-code', '№ ПФО', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-code', 'Вн.№ фин.об', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('trn-doc-code', '№ РН', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('trn-doc-code-orig', '№ ПН', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('contract-code', 'Вн.№ договора', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-doc', 'Создал', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Дата документа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Дата факта', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', 'Валюта', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run openbr in this-procedure (yes, no, '':u).
END.
END PROCEDURE.
PROCEDURE proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as character no-undo.
display "" @ p-desc with frame Dialog-Frame.
display "" @ p-desc-2 with frame Dialog-Frame.
display "" @ p-date with frame Dialog-Frame.
assign
  pardoc-code = chr(34) + pardoc-code + chr(34) .
run OpenBr in this-procedure
    (input false
    ,input par-next
    ,input substitute("and buf_fin-liab-before.prn-doc-code = &1 "
      , pardoc-code )
    ) no-error .
    if error-status :error or return-value = ? then
       message "Не найдено ни одной записи !" view-as alert-box .
END PROCEDURE.
PROCEDURE proc-find-date :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as date no-undo.
define variable ppp as character no-undo .
display "" @ p-desc with frame Dialog-Frame.
display "" @ p-desc-2 with frame Dialog-Frame.
display "" @ sch-code with frame Dialog-Frame.
ppp =  string( day(pardoc-code)) + "/" +  string( month(pardoc-code)) + "/" +  string( year(pardoc-code)) .
run OpenBr in this-procedure
    (input false
    ,input par-next
    ,input substitute("and buf_fin-liab-before.doc-date = &1 "
      , ppp )
    )  no-error .
    if error-status :error or return-value = ? then
       message "За эту дату не найдено ни одной записи !" view-as alert-box .
END PROCEDURE.
PROCEDURE proc-find-desc :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as character no-undo.
define variable pp as integer no-undo .
define buffer b_contract for ub.contract .
display "" @ sch-code with frame Dialog-Frame.
display "" @ p-date with frame Dialog-Frame.
display "" @ p-desc-2 with frame Dialog-Frame.
if  par-next = true then
    find next b_contract no-lock where b_contract.host-code = par-host-code and b_contract.contract-prn-code = pardoc-code use-index num no-error .
else
  find first b_contract no-lock where b_contract.host-code = par-host-code and b_contract.contract-prn-code = pardoc-code  use-index num no-error .
if available b_contract
then do:
pp = b_contract.contract-code.
    run OpenBr in this-procedure
        (input false
        ,input par-next
        ,input substitute("and buf_fin-liab-before.contract-code = &1 "
          , pp)
        ) no-error .
    if error-status :error or return-value = ? then
       message "Не найдено ни одной записи !" view-as alert-box .
end.
else do:
message "Договор с таким номером не найден !!!" .
apply "entry":u to p-desc in frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE proc-find-desc-2 :
 do
 on error undo, return error return-value
 :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as character no-undo.
define variable pp as integer no-undo .
define buffer b_contract for ub.contract .
display "" @ sch-code with frame Dialog-Frame.
display "" @ p-date with frame Dialog-Frame.
display "" @ p-desc with frame Dialog-Frame.
run OpenBr in this-procedure
    (input false
    ,input par-next
    ,input substitute("and buf_fin-liab-before.trn-doc-code begins '&1' "
      , pardoc-code)
    ) no-error .
if error-status :error or return-value = ? then do:
    message "Запись не найдена !!!" .
    apply "entry":u to p-desc-2 in frame Dialog-Frame .
end.
  end.
END PROCEDURE.
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.
  end.
END PROCEDURE.
FUNCTION contract-id RETURNS CHARACTER
( input p-rec as recid ) :
define  BUFFER loc-fin-liab FOR ub.fin-ob-before .
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .
  define variable rr as character no-undo .
  define buffer buf-f_contract for ub.contract.
  find first buf-f_contract no-lock where  buf-f_contract.host-code      = par-host-code  and
                                          buf-f_contract.contract-code  = loc-fin-liab.contract-code  no-error.
  if available buf-f_contract then   rr = buf-f_contract.contract-prn-code.
     else rr = "".
  RETURN rr.
END FUNCTION.
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int ) :
  define variable rr as character no-undo .
  find first ub.currency no-lock where  ub.currency.curr-code  = p-curr-code no-error.
  rr = ub.currency.curr-abbr .
  RETURN rr.
END FUNCTION.
FUNCTION val-abbr-type RETURNS CHARACTER
( input p-rec as recid ) :
define  BUFFER loc-fin-liab FOR ub.fin-ob-before .
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .
define variable rr as character no-undo .
find first ub.currency no-lock where  ub.currency.curr-code  = loc-fin-liab.curr-code no-error.
if available ub.currency then  rr = ub.currency.curr-abbr .
else rr = ""   .
RETURN rr.
END FUNCTION.
