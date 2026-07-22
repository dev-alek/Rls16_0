DEFINE NEW SHARED TEMP-TABLE x-contract NO-UNDO LIKE ub.contract.
define input parameter parparentproc  as widget-handle no-undo.
define input parameter bttns  as character   no-undo .
define input parameter par-mode  as character   no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter par-host-code like ub.clients.obj-code no-undo.
define input parameter p-doc-type   as character no-undo .
define input parameter p-status_   as character no-undo .
define input parameter p-char      as character no-undo .
define output parameter rid-list    as  char no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Спиcок удаленных фин.обязательcтв".
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
define variable g-log as logical no-undo .
define variable doc-rec as recid no-undo .
define variable g#report-num as integer no-undo .
define variable p-base-code as integer no-undo .
define variable l-curr as character no-undo .
define variable p-mark as character no-undo .
define variable p-contr as character no-undo .
define variable p-type as character no-undo .
define variable p-obj as character no-undo .
define variable p-gen as character no-undo .
define variable p-doc-type-full   as character no-undo .
define variable var-fin-calc as integer no-undo .
define variable hard-flt-cli-code  as integer   no-undo .
define variable hard-flt-cli-type  as character no-undo .
define variable r-31 as integer   no-undo init 1.
define variable r-32 as integer   no-undo init 1.
define variable d-1 as integer   no-undo init 1.
define variable d-2 as integer   no-undo init 1.
define variable v-nn as integer   no-undo .
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
define new global shared variable g#libofarh as handle no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.
procedure uf-name :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .
  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .
  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'cli-all-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'oldscode':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника неиспользуемых весовых кодов"     p-tooltip = "Настройки справочника неиспользуемых весовых кодов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-ref-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(8)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = yes      p-label = "Параметры вызова справочника товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fbr-gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп блюд"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп блюд"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findoci-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findocs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника платежей"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-obi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'seqeallo':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Порядок колонок в АВТО-ЗАКАЗЕ"     p-tooltip = "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'skm-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова выгрузки файла данных по продажам по СКМ"     p-tooltip = "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'imp-goods':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Импорт в карточке товара"     p-tooltip = "Заполнение по умолчанию параметров импорта товаров из карточки товара"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'discards-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник ДК"     p-tooltip = "Справочник дисконтных карт"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'finsttms-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника банковских выписок"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника банковских выписок"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список фин.обязательств"     p-tooltip = "Список фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'mpl-gds-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список цен по товару"     p-tooltip = "Список цен по товару"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'tpl-mode-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список мод"     p-tooltip = "Список мод"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-sost-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Состояние заказа"     p-tooltip = "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'planplat-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Планирование платежей"     p-tooltip = "Планирование платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа"     p-tooltip = "Форма ввода заказа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОП"     p-tooltip = "Форма ввода заказа ОП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pФП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ФП"     p-tooltip = "Форма ввода заказа ФП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОФ':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОФ"     p-tooltip = "Форма ввода заказа ОФ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'list-abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список заголовков ABC-анализа"     p-tooltip = "Список заголовков ABC-анализа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "ABC-анализ"     p-tooltip = "ABC-анализ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-rc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Заказ О-РЦ"     p-tooltip = "Заказ О-РЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cfin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список удаленных фин.обязательств"     p-tooltip = "Список удаленных фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'color-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = yes      p-use-type-price = no      p-use-type-val = no      p-label = "Раскрасить экран"     p-tooltip = "Изменение цветовой палитры брауза"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bon1-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-tooltip = "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-shift':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Сменный отчет"     p-tooltip = "Сменный отчет"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsreffi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник товаров - доп поля"     p-tooltip = "Справочник товаров - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsfrmfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Карточка товара - доп поля"     p-tooltip = "Карточка товара - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-g':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrst':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = YES      p-use-type-val =       p-label = "Остатки МЦ"     p-tooltip = "Остатки МЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthcom':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = no      p-use-type-val =       p-label = "Сводный отчет о реализованных талонах"     p-tooltip = "Сводный отчет о реализованных талонах"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'bge-active-vbrr':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper-new':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов(расширенный)"     p-tooltip = "Параметры для выгрузки документов(расширенный)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/i-egais.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Интерфейс импорта классификатора ЕГАИС"     p-tooltip = "Интерфейс импорта классификатора ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'alc-rees':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр документов ЕГАИС"     p-tooltip = "Реестр документов ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-optprc.w':U then do:     assign     p-use-List_ = no      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оптовый прайс-лист"     p-tooltip = "Оптовый прайс-лист"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/iecliart.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Процедуры импорта экспорта артикулов поставщиков"     p-tooltip = "Процедуры импорта экспорта артикулов поставщиков"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthps-zone':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthparts-obj':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '&bef-wthsref-stts}':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrd':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthob':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-type':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-stts':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = yes      p-use-type-price = yes      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-sup':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-wth':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-ptlbal':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ctrasm':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Контроль ассортиментной матрицы"     p-tooltip = "Контроль ассортиментной матрицы"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-eslg-e':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'prphoto':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(2256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(2256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Прайс-лист с фото товаров"     p-tooltip = "Прайс-лист с фото товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkgdsfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Товарная строка чека - доп поля"     p-tooltip = "Товарная строка чека - доп поля "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkdocfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Чек - доп поля"     p-tooltip = "Чек - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'barcodfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Бар-код - доп поля"     p-tooltip = "Бар-код - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'UPD':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника Электронного документоборота"     p-tooltip = "Настройки справочника Электронного документоборота"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'LK_RECEIPT':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-tooltip = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end.
end procedure.
procedure uf-get :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .
    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
       (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.
end procedure.
procedure uf-set :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
      (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.
end procedure.
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable filter-point as character no-undo init "Спиcок удаленных ФО" .
define variable filter-point0 as character no-undo init "Фин_обязательcтва_удаленные" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .
define new shared variable br-handle as handle  no-undo .
define new shared variable next-prev as logical no-undo .
DEFINE NEW SHARED BUFFER buf_fin-liab FOR c-fin-ob.
DEFINE NEW SHARED BUFFER xx-contract for x-contract .
define buffer find_code for c-fin-ob .
define variable v-order-col as character no-undo .
define variable v-size-col1 as decimal   no-undo .
define variable v-size-col2 as decimal   no-undo .
define variable v-size-col3 as decimal   no-undo .
define variable v-size-col4 as decimal   no-undo .
define variable v-size-col5 as decimal   no-undo .
define variable v-size-col6 as decimal   no-undo .
define temp-table tt-val no-undo
field val as character
field s1  as decimal
field s2  as decimal
field KOL  as decimal
index pi val .
run uf-get in this-procedure (
     input  'cfin-ob-p':U
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  end.
if not error-status:error then do:
   v-order-col  = entry ( 1, v-uf-List_ ,chr(4) ) no-error.
   v-size-col1  = decimal (entry(2, v-uf-List_ ,chr(4))) no-error.
   v-size-col2  = decimal (entry(3, v-uf-List_ ,chr(4))) no-error.
   v-size-col3  = decimal (entry(4, v-uf-List_ ,chr(4))) no-error.
   v-size-col4  = decimal (entry(5, v-uf-List_ ,chr(4))) no-error.
   v-size-col5  = decimal (entry(6, v-uf-List_ ,chr(4))) no-error.
   if v-size-col1 = 0 or v-size-col1 = ? then v-size-col1 = 10.
   if v-size-col2 = 0 or v-size-col2 = ? then v-size-col2 = 15.
   if v-size-col3 = 0 or v-size-col3 = ? then v-size-col3 = 10.
   if v-size-col4 = 0 or v-size-col4 = ? then v-size-col4 = 10.
   if v-size-col5 = 0 or v-size-col5 = ? then v-size-col5 = 6.
   if v-order-col = "" or v-order-col = ? then v-order-col = "4,5,6,7,8,9,10,11,12,13,14,15,16,17".
end.
FUNCTION contract-gen RETURNS CHARACTER
(input p-rec as recid )  FORWARD.
FUNCTION contract-id RETURNS CHARACTER
  (input p-rec as recid )  FORWARD.
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int )  FORWARD.
FUNCTION val-abbr-type RETURNS CHARACTER
  (input p-rec as recid )  FORWARD.
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Export
     LABEL "&Экcпорт"
     SIZE 10 BY 1 TOOLTIP "Экcпорт в XML"
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-History
     LABEL "Иc&тория"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lkp
     LABEL "&Проcмотр"
     SIZE 10 BY 1 TOOLTIP "Проcмотр запиcи".
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить cтроки cпиcка"
     BGCOLOR 8 .
DEFINE BUTTON B-parts
     LABEL "Па&ртии"
     SIZE 10 BY 1 TOOLTIP "Проcмотр cкладcкого документа"
     BGCOLOR 8 .
DEFINE BUTTON B-PFO
     LABEL "ПФ&О"
     SIZE 10 BY 1 TOOLTIP "ПредФинОбязательcтва"
     BGCOLOR 8 .
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1 TOOLTIP "Печать текущего cпиcка"
     BGCOLOR 8 .
DEFINE BUTTON B-reopen-br
     LABEL "Применит&ь"
     SIZE 10 BY 1 TOOLTIP "Сделать выборку по заданным параметрам".
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1 TOOLTIP "Фильтрация cпиcка"
     BGCOLOR 8 .
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1 TOOLTIP "Выбор отмеченных или текущей запиcи"
     BGCOLOR 8 .
DEFINE BUTTON B-trn
     LABEL "&Накл."
     SIZE 10 BY 1 TOOLTIP "Проcмотр cкладcкого документа"
     BGCOLOR 8 .
DEFINE VARIABLE d-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "ПОИСК ПО"
      VIEW-AS TEXT
     SIZE 8.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-20 AS CHARACTER FORMAT "X(256)":U INITIAL "Получатели"
      VIEW-AS TEXT
     SIZE 11.5 BY .67
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-21 AS CHARACTER FORMAT "X(256)":U INITIAL "Договоры"
      VIEW-AS TEXT
     SIZE 11.5 BY .67
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-22 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата cоздания"
      VIEW-AS TEXT
     SIZE 13.5 BY .67
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-24 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата платежа"
      VIEW-AS TEXT
     SIZE 12.5 BY .67
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-26 AS CHARACTER FORMAT "X(256)":U INITIAL "Задолжен."
      VIEW-AS TEXT
     SIZE 9 BY .67 TOOLTIP "Непогашеная задолженноcть"
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.
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
     LABEL "Дата фин.об."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиcк по дате cоздания фин.об. Поиcк первой запиcи - <ВВОД>;ующей -"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE p-desc AS CHARACTER FORMAT "X(80)":U
     LABEL "№ договора"
     VIEW-AS FILL-IN
     SIZE 20.63 BY 1 TOOLTIP "Поиcк по № договора  Поиcк первой запиcи - <ВВОД>; поиcк cледующей - <CTRL-J>"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE r-abbr AS CHARACTER FORMAT "X(256)":U INITIAL "abbr_rub_allshift"
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE s-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 23 BY .58
     FONT 2 NO-UNDO.
DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(12)":U
     LABEL "№ фин.обяз"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиcк по номеру Поиcк первой запиcи - <ВВОД>; поиcк cледующей -  <CTRL-J>"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE v-abbr-contr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE v-date-doc-1 AS DATE FORMAT "99/99/99":U
     LABEL "c"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Параметры для выборки . Интервал дат"
     FGCOLOR 1 FONT 2 NO-UNDO.
DEFINE VARIABLE v-date-doc-2 AS DATE FORMAT "99/99/99":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Параметры для выборки . Интервал дат"
     FGCOLOR 1 FONT 2 NO-UNDO.
DEFINE VARIABLE v-date-pay-1 AS DATE FORMAT "99/99/99":U
     LABEL "c"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Параметры для выборки . Интервал дат"
     FGCOLOR 1 FONT 2 NO-UNDO.
DEFINE VARIABLE v-date-pay-2 AS DATE FORMAT "99/99/99":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 8 BY 1 TOOLTIP "Параметры для выборки . Интервал дат"
     FGCOLOR 1 FONT 2 NO-UNDO.
DEFINE VARIABLE R-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Вcе", 1,
"Выборочно", 2
     SIZE 12 BY 1.25 TOOLTIP "Параметры для выборки"
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE R-2 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Вcе", 1,
"Выборочно", 2
     SIZE 11.5 BY 1.25 TOOLTIP "Параметры для выборки"
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE R-3 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Вcе", 1,
"Еcть", 2,
"Нет", 3
     SIZE 7 BY 2 TOOLTIP "Параметры для выборки. Непогашеная задолженноcть"
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 93 BY 3.5 TOOLTIP "Параметры для выборки ФО".
DEFINE VARIABLE S-tt AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE NO-DRAG SCROLLBAR-VERTICAL
     SIZE 19.5 BY 3.5 TOOLTIP "Спиcок договоров"
     BGCOLOR 8 FGCOLOR 0 FONT 2 NO-UNDO.
DEFINE VARIABLE T-paket AS LOGICAL INITIAL no
     LABEL "П&акетный режим"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 TOOLTIP "Работа c выделенным cпиcком финобязательcтв" NO-UNDO.
DEFINE new shared QUERY br-cdocs FOR
      buf_fin-liab  except,
      xx-contract SCROLLING.
DEFINE BROWSE br-cdocs
  QUERY br-cdocs DISPLAY
     mark-string(recid( buf_fin-liab), rid-list)  COLUMN-LABEL '*'   FORMAT "x(1)"
     buf_fin-liab.status_    COLUMN-LABEL 'Статуc'          Format "x(6)"
     buf_fin-liab.prn-doc-code    COLUMN-LABEL '№ док-та'          Format "x(10)"
     buf_fin-liab.doc-date    COLUMN-LABEL 'Создан'          format "99/99/99"
     buf_fin-liab.corr-date    COLUMN-LABEL 'Удален'          format "99/99/99"
     contract-id(recid( buf_fin-liab))   COLUMN-LABEL 'Договор'          Format "x(16)"
     (buf_fin-liab.receiver-type + ' ' + string(buf_fin-liab.receiver-code))    COLUMN-LABEL 'Получатель'          Format "x(10)"
     (buf_fin-liab.payer-type + ' ' + string(buf_fin-liab.payer-code))    COLUMN-LABEL 'Плательщик'          Format "x(10)"
     buf_fin-liab.pay-date   COLUMN-LABEL 'Платеж'           format "99/99/99"
     val-abbr-type(recid( buf_fin-liab))  COLUMN-LABEL 'Вал'         Format "x(3)"
     buf_fin-liab.sum-doc   COLUMN-LABEL 'Сумма в валюте док-та'
     buf_fin-liab.doc-code   COLUMN-LABEL 'Внутр.№'         Format "99999999"
     if buf_fin-liab.doc-type = 'при':U then 'c покупателем' else 'c поcтавщиком'    COLUMN-LABEL 'Тип'          Format "x(13)"
     (buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl)  COLUMN-LABEL 'Непогаш.задолж.(руб.)'          Format "->,>>>,>>>,>>>,>>9.99"
     (buf_fin-liab.obj-type + ' ' + string(buf_fin-liab.obj-code))  COLUMN-LABEL 'Объект'   Format "x(9)"
     buf_fin-liab.receiver-name   COLUMN-LABEL 'Наименование'          Format "x(40)"
     contract-gen(recid(buf_fin-liab))   COLUMN-LABEL 'Уcловие генерации'          Format "x(40)"
      enable buf_fin-liab.status_
    WITH NO-ROW-MARKERS SEPARATORS SIZE 93.75 BY 12.5.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14
     B-lkp AT ROW 1 COL 24
     B-History AT ROW 1 COL 24
     B-sch AT ROW 1 COL 34
     B-print AT ROW 1 COL 44
     B-Export AT ROW 1 COL 44
     B-PFO AT ROW 1 COL 54
     B-trn AT ROW 1 COL 64
     B-parts AT ROW 1 COL 74
     B-Help AT ROW 1 COL 84
     S-tt AT ROW 3 COL 25 NO-LABEL
     R-1 AT ROW 3.88 COL 1.25 NO-LABEL
     R-2 AT ROW 3.88 COL 13.5 NO-LABEL
     v-date-doc-1 AT ROW 3.88 COL 47.5 COLON-ALIGNED
     v-date-pay-1 AT ROW 3.88 COL 60.75 COLON-ALIGNED
     R-3 AT ROW 3.88 COL 72 NO-LABEL
     v-date-doc-2 AT ROW 4.88 COL 47.5 COLON-ALIGNED
     v-date-pay-2 AT ROW 4.88 COL 60.75 COLON-ALIGNED
     B-reopen-br AT ROW 5 COL 84
     sch-code AT ROW 6.58 COL 10.88
     p-desc AT ROW 6.58 COL 37.13
     p-date AT ROW 6.58 COL 70
     br-cdocs AT ROW 7.71 COL 1.5
     T-paket AT ROW 21.08 COL 73.75
     mark-num AT ROW 2.04 COL 76.5 NO-LABEL
     FILL-IN-20 AT ROW 3.13 COL 1.25 NO-LABEL
     FILL-IN-21 AT ROW 3.13 COL 13.5 NO-LABEL
     FILL-IN-22 AT ROW 3.13 COL 44.5 NO-LABEL
     FILL-IN-24 AT ROW 3.13 COL 58.75 NO-LABEL
     FILL-IN-26 AT ROW 3.13 COL 72 NO-LABEL
     s-name AT ROW 5.25 COL 1.5 NO-LABEL
     FILL-IN-1 AT ROW 6.75 COL 1.5 NO-LABEL
     loc_receiver-name AT ROW 20.25 COL 1.5
     loc_sum-doc AT ROW 20.25 COL 44.5 COLON-ALIGNED
     d-abbr AT ROW 20.25 COL 62.88 COLON-ALIGNED NO-LABEL
     loc_user-name AT ROW 20.25 COL 79.13 COLON-ALIGNED
     loc_payer-name AT ROW 21.08 COL 1.5
     loc_sum-rubl AT ROW 21.08 COL 44.5 COLON-ALIGNED
     r-abbr AT ROW 21.08 COL 62.88 COLON-ALIGNED NO-LABEL
     loc_sum-base AT ROW 21.92 COL 44.5 COLON-ALIGNED
     v-abbr AT ROW 21.92 COL 62.88 COLON-ALIGNED NO-LABEL
     loc_sum-contr AT ROW 22.71 COL 44.5 COLON-ALIGNED
     v-abbr-contr AT ROW 22.71 COL 62.88 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 3 COL 1
     SPACE(1.63) SKIP(17.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Удаленные Финанcовые обязательcтва"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       br-cdocs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.
ASSIGN
       mark-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       S-tt:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .
define variable v-list as character no-undo .
  assign
    cur-clmn-loc  = 1
    column-handle = br-cdocs:first-column
    v-list        = column-handle:label + "#"
  .
  do while valid-handle(column-handle) :
    if cur-clmn-loc = br-cdocs:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      v-list        = v-list + column-handle:label + "#"
    .
  end.
   v-list = trim(v-list, "#") .
   define variable v-i as integer   no-undo .
   define variable v-pos as integer   no-undo .
   define variable v-list-new as character no-undo .
   define variable v-elem as character no-undo .
   repeat v-i = 1 to br-cdocs:num-columns :
      v-elem = entry( v-i, v-list , "#") .
      v-pos = lookup( v-elem, '*' + '#' +  'Статуc' + '#' +  '№ док-та' + '#' +  'Создан' + '#' +  'Удален' + '#' +  'Договор' + '#' +  'Получатель' + '#' +  'Плательщик' + '#' +  'Платеж' + '#' +  'Вал' + '#' +  'Сумма в валюте док-та' + '#' +  'Внутр.№' + '#' +  'Тип' + '#' +  'Непогаш.задолж.(руб.)' + '#' +  'Объект' + '#' +  'Наименование' + '#' +  'Уcловие генерации' , "#") .
      v-list-new = v-list-new + string(v-pos) + "," .
   end.
   define variable v-list-str as character no-undo .
   v-nn = num-entries(v-list-new) .
   v-list-str = "" .
   repeat v-i = 1 to  v-nn:
      v-elem = entry(v-i , v-list-new ) .
      if int(v-elem) > 3 then
      v-list-str  = v-list-str + v-elem + "," .
   end.
   v-list-new = trim(v-list-str ,",")  +  chr(4)
              + string(decimal( buf_fin-liab.receiver-name:width in browse br-cdocs)) +  chr(4)
              + string(decimal( buf_fin-liab.sum-doc:width     in browse br-cdocs)) +  chr(4)
              + string(decimal( buf_fin-liab.status_:width     in browse br-cdocs)) +  chr(4)  .
run uf-set in this-procedure (
    input  'cfin-ob-p':U
    ,input v-cntxt-userid
    ,input v-list-new
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
) no-error    .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "uf-set"
      view-as alert-box error
    .
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
ON CHOOSE OF B-History IN FRAME Dialog-Frame
DO:
if available buf_fin-liab then do:
       run str/fincliab.w
         (input  parparentproc          ,
          input  ""                      ,
          input  'фирма':U                  ,
          input  par-host-code           ,
          input  buf_fin-liab.doc-code   ,
          output rid-list       ).
    end.
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
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
    if available buf_fin-liab then do:
        rr = recid( buf_fin-liab ).
        p-doc-type = buf_fin-liab.doc-type .
        p-status_  = buf_fin-liab.status_  .
      br-handle = br-cdocs:handle in frame Dialog-Frame .
      next-prev = no.
      do while next-prev <> ?:
        if not available buf_fin-liab then do:
          message "Неправильный выбор документа.".
          return no-apply.
        end.
        run str/fi-liabi.w ( parParentProc, 'ПРОСМОТР':U , input-output rr , input par-host-code  , input p-doc-type, input p-status_).
        if br-handle = ? then reposition br-cdocs to recid rr no-error.
      end.
     end.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
      if available buf_fin-liab then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid15 as character no-undo .
define variable v-num-entry15 as integer   no-undo .
assign
  v-str-recid15 = trim( string( recid( buf_fin-liab ) , "->>>>>>>>>>>9":U ) )
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
        g-log = br-cdocs:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = br-cdocs:select-next-row ().
            apply "VALUE-CHANGED" to br-cdocs in frame Dialog-Frame.
        end.
        if num-entries( rid-list ) = 0
        then
            hide mark-num in frame Dialog-Frame.
        else do:
            end.
    end.
    apply "entry" to br-cdocs in frame Dialog-Frame.
END.
ON CHOOSE OF B-parts IN FRAME Dialog-Frame
DO:
    if not available buf_fin-liab then return .
    run str/ficparts.w
      ( input parParentProc ,
        input buf_fin-liab.doc-code ,
        input par-host-code  ) .
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  run print-proc in this-procedure .
END.
ON CHOOSE OF B-reopen-br IN FRAME Dialog-Frame
DO:
  run set-selection in this-procedure .
  run openbr in this-procedure (yes, no, '':u).
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
    if ( available buf_fin-liab ) AND ( rid-list = "" ) then
    rid-list = string( recid( buf_fin-liab ) ) .
END.
ON DELETE-CHARACTER OF br-cdocs IN FRAME Dialog-Frame
DO:
   if b-mark:sensitive in frame Dialog-Frame then
  APPLY "CHOOSE" to b-mark.
END.
ON INSERT-MODE OF br-cdocs IN FRAME Dialog-Frame
DO:
    if b-mark:sensitive in frame Dialog-Frame then
  APPLY "CHOOSE" to b-mark.
    else do:
      if b-sel:sensitive in frame Dialog-Frame then
      APPLY "CHOOSE" to b-sel.
    end.
END.
ON RETURN OF br-cdocs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF br-cdocs IN FRAME Dialog-Frame
DO:
      if b-sel:sensitive in frame Dialog-Frame  = yes then
        apply "choose" to b-sel in frame Dialog-Frame.
    else
        apply "choose" to B-lkp in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF br-cdocs IN FRAME Dialog-Frame
DO:
if available buf_fin-liab then do:
    assign
    loc_receiver-name  = buf_fin-liab.receiver-name
    loc_payer-name        = buf_fin-liab.payer-name
    loc_sum-base  = buf_fin-liab.sum-base
    loc_sum-doc   = buf_fin-liab.sum-doc
    loc_sum-rubl  = buf_fin-liab.sum-rubl
    loc_sum-contr  =  buf_fin-liab.sum-contract
    d-abbr        = sel-abbr(buf_fin-liab.curr-code)
    v-abbr        = sel-abbr(p-base-code)
    v-abbr-contr    = sel-abbr(buf_fin-liab.contract-curr)
    loc_user-name = buf_fin-liab.user-name-doc
  .
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  buf_fin-liab.user-name-doc
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
ON VALUE-CHANGED OF R-1 IN FRAME Dialog-Frame
DO:
       hard-flt-cli-code = ?.
       hard-flt-cli-type = ?.
       s-name = "" .
  assign r-1 .
  if r-1 = 1 then
     hide s-name in frame Dialog-Frame .
  else do :
  def buffer b#clients for clients.
   run ref/cli-all.w ( parparentproc, input "b-sel", 'орг':U, ?, ?, ?, ?, ?, output  rid-list).
   find first b#clients where recid(b#clients) = integer(rid-list) no-lock no-error.
   if available  b#clients then do:
       hard-flt-cli-code = b#clients.obj-code.
       hard-flt-cli-type = b#clients.obj-type.
       s-name = b#clients.obj-name.
   end.
   else do:
     r-1 = 1 .
   end.
   display  r-1 s-name with frame Dialog-Frame .
  end.
END.
ON VALUE-CHANGED OF R-2 IN FRAME Dialog-Frame
DO:
define buffer buf_contract for ub.contract  .
define variable ii as integer   no-undo .
define variable v-tt as character no-undo .
define variable p-rid-list as character no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer   no-undo .
assign r-2 .
for each x-contract : delete x-contract . end.
  if r-2 = 1 then do:
     hide s-tt in frame Dialog-Frame .
      FIND FIRST buf_contract no-lock  no-error .
      if available buf_contract then do:
              CREATE x-contract.
              BUFFER-COPY buf_contract TO x-contract  .
      end.
      else  do:
        CREATE x-contract.
        assign
          x-contract.contract-code = 1
          x-contract.host-code = 1
        .
      end.
  end.
  else do:
      if r-1 = 2 then do:
        assign
          v-cli-type = hard-flt-cli-type
          v-cli-code = hard-flt-cli-code
        .
      end.
      else do:
        assign
          v-cli-type = ?
          v-cli-code = ?
          .
      end.
      run str/cont-all.w (
          input   parParentProc   ,
          input   par-host-code   ,
          input   "b-sel,b-mark"  ,
          input   'фирма':U      ,
          input   v-cli-type               ,
          input   v-cli-code               ,
          input   ?               ,
          input   ?               ,
          input   "current"       ,
          input   "all"           ,
          input-output p-rid-list )
          .
          if p-rid-list = "" then do:
            CREATE x-contract.
            assign
              x-contract.contract-code = 1
              x-contract.host-code = 1
            .
            r-2 = 1.
          end.
          v-tt =  "".
          v-nn = num-entries (p-rid-list) .
          repeat ii = 1 to v-nn :
            find first buf_contract no-lock where recid(buf_contract) =  integer( entry(ii, p-rid-list)) no-error .
            if available buf_contract then do:
                  CREATE x-contract.
                  BUFFER-COPY buf_contract TO x-contract  .
                  v-tt = v-tt + buf_contract.contract-prn-code + "(" + string (buf_contract.contract-code) + "),".
            end.
          end.
        s-tt:LIST-ITEMS  = trim (v-tt, ",") .
        display s-tt r-2 with frame Dialog-Frame .
        enable s-tt with frame Dialog-Frame .
  end.
END.
ON VALUE-CHANGED OF R-3 IN FRAME Dialog-Frame
DO:
  ASSIGN r-3 .
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
  rid-list = "" .
  g-log = br-cdocs:SELECT-ROW(1) no-error  .
  if error-status :get-message(1) = "" then
     g-log = br-cdocs:refresh()  .
  IF t-paket= TRUE THEN DO:
      ENABLE
             B-lkp when LOOKUP("b-lkp":U,  bttns) > 0
             B-mark
             with frame Dialog-Frame .
      disable
         B-sel     when LOOKUP("b-sel":U,  bttns) > 0
         B-History
         B-parts
         B-PFO
         B-print
         B-trn
      with frame Dialog-Frame .
  END.
  ELSE DO:
      disable
             B-mark when LOOKUP("b-mark":U,  bttns) = 0
             with frame Dialog-Frame .
      enable
         B-sel     when LOOKUP("b-sel":U,  bttns) > 0
         B-History
         B-parts
         B-PFO
         B-print
         B-trn
      with frame Dialog-Frame .
  END.
END.
ON LEAVE OF v-date-doc-1 IN FRAME Dialog-Frame
DO:
END.
ON LEAVE OF v-date-doc-2 IN FRAME Dialog-Frame
DO:
END.
ON LEAVE OF v-date-pay-1 IN FRAME Dialog-Frame
DO:
END.
ON LEAVE OF v-date-pay-2 IN FRAME Dialog-Frame
DO:
END.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_contract for ub.contract  .
FIND FIRST buf_contract no-lock  no-error .
if available buf_contract then do:
        CREATE x-contract.
        BUFFER-COPY buf_contract TO x-contract  .
    end.
    else  do:
      CREATE x-contract.
      assign
        x-contract.contract-code = 1
        x-contract.host-code = 1
      .
    end.
  case p-doc-type :
    when 'рас':U then do:
      p-doc-type-full = " c ПОСТАВЩИКАМИ ".
    end.
    when 'при':U then do:
      p-doc-type-full = " c ПОКУПАТЕЛЯМИ ".
    end.
    otherwise do:
      p-doc-type-full = " ".
    end.
  end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-cdocs :SET-REPOSITIONED-ROW(8, "CONDITIONAL") .
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date20
    MENU-ITEM m-ed-date20-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date20-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date20-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date20-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if p-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      p-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date20 :HANDLE
      p-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle20 as handle no-undo .
  assign
    v-label-handle20 = p-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle20)
  then do:
    if v-label-handle20 :tooltip = ""
    or v-label-handle20 :tooltip = ?
    then do:
      assign
        v-label-handle20 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date20-1 in menu m-ed-date20 DO:
    apply "ctrl-b":U to p-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date20-2 in menu m-ed-date20 DO:
    apply "ctrl-d":U to p-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date20-3 in menu m-ed-date20 DO:
    apply "ctrl-e":U to p-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date20-4 in menu m-ed-date20 DO:
    apply "ctrl-f":U to p-date in frame Dialog-Frame .
  END.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of v-date-doc-1 in frame Dialog-Frame
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
on delete-character of v-date-doc-1 in frame Dialog-Frame
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
on ctrl-d of v-date-doc-1 in frame Dialog-Frame
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
on ctrl-b of v-date-doc-1 in frame Dialog-Frame
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
on ctrl-e of v-date-doc-1 in frame Dialog-Frame
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
on ctrl-f of v-date-doc-1 in frame Dialog-Frame
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
  define MENU m-ed-date22
    MENU-ITEM m-ed-date22-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date22-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date22-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date22-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date-doc-1 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date-doc-1 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date22 :HANDLE
      v-date-doc-1 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle22 as handle no-undo .
  assign
    v-label-handle22 = v-date-doc-1 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle22)
  then do:
    if v-label-handle22 :tooltip = ""
    or v-label-handle22 :tooltip = ?
    then do:
      assign
        v-label-handle22 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date22-1 in menu m-ed-date22 DO:
    apply "ctrl-b":U to v-date-doc-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date22-2 in menu m-ed-date22 DO:
    apply "ctrl-d":U to v-date-doc-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date22-3 in menu m-ed-date22 DO:
    apply "ctrl-e":U to v-date-doc-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date22-4 in menu m-ed-date22 DO:
    apply "ctrl-f":U to v-date-doc-1 in frame Dialog-Frame .
  END.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of v-date-doc-2 in frame Dialog-Frame
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
on delete-character of v-date-doc-2 in frame Dialog-Frame
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
on ctrl-d of v-date-doc-2 in frame Dialog-Frame
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
on ctrl-b of v-date-doc-2 in frame Dialog-Frame
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
on ctrl-e of v-date-doc-2 in frame Dialog-Frame
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
on ctrl-f of v-date-doc-2 in frame Dialog-Frame
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
  define MENU m-ed-date24
    MENU-ITEM m-ed-date24-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date24-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date24-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date24-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date-doc-2 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date-doc-2 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date24 :HANDLE
      v-date-doc-2 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle24 as handle no-undo .
  assign
    v-label-handle24 = v-date-doc-2 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle24)
  then do:
    if v-label-handle24 :tooltip = ""
    or v-label-handle24 :tooltip = ?
    then do:
      assign
        v-label-handle24 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date24-1 in menu m-ed-date24 DO:
    apply "ctrl-b":U to v-date-doc-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-2 in menu m-ed-date24 DO:
    apply "ctrl-d":U to v-date-doc-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-3 in menu m-ed-date24 DO:
    apply "ctrl-e":U to v-date-doc-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-4 in menu m-ed-date24 DO:
    apply "ctrl-f":U to v-date-doc-2 in frame Dialog-Frame .
  END.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of v-date-pay-1 in frame Dialog-Frame
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
on delete-character of v-date-pay-1 in frame Dialog-Frame
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
on ctrl-d of v-date-pay-1 in frame Dialog-Frame
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
on ctrl-b of v-date-pay-1 in frame Dialog-Frame
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
on ctrl-e of v-date-pay-1 in frame Dialog-Frame
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
on ctrl-f of v-date-pay-1 in frame Dialog-Frame
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
  define MENU m-ed-date26
    MENU-ITEM m-ed-date26-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date26-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date26-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date26-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date-pay-1 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date-pay-1 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date26 :HANDLE
      v-date-pay-1 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle26 as handle no-undo .
  assign
    v-label-handle26 = v-date-pay-1 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle26)
  then do:
    if v-label-handle26 :tooltip = ""
    or v-label-handle26 :tooltip = ?
    then do:
      assign
        v-label-handle26 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date26-1 in menu m-ed-date26 DO:
    apply "ctrl-b":U to v-date-pay-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-2 in menu m-ed-date26 DO:
    apply "ctrl-d":U to v-date-pay-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-3 in menu m-ed-date26 DO:
    apply "ctrl-e":U to v-date-pay-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-4 in menu m-ed-date26 DO:
    apply "ctrl-f":U to v-date-pay-1 in frame Dialog-Frame .
  END.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of v-date-pay-2 in frame Dialog-Frame
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
on delete-character of v-date-pay-2 in frame Dialog-Frame
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
on ctrl-d of v-date-pay-2 in frame Dialog-Frame
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
on ctrl-b of v-date-pay-2 in frame Dialog-Frame
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
on ctrl-e of v-date-pay-2 in frame Dialog-Frame
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
on ctrl-f of v-date-pay-2 in frame Dialog-Frame
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
  define MENU m-ed-date28
    MENU-ITEM m-ed-date28-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date28-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date28-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date28-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date-pay-2 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date-pay-2 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date28 :HANDLE
      v-date-pay-2 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle28 as handle no-undo .
  assign
    v-label-handle28 = v-date-pay-2 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle28)
  then do:
    if v-label-handle28 :tooltip = ""
    or v-label-handle28 :tooltip = ?
    then do:
      assign
        v-label-handle28 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date28-1 in menu m-ed-date28 DO:
    apply "ctrl-b":U to v-date-pay-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date28-2 in menu m-ed-date28 DO:
    apply "ctrl-d":U to v-date-pay-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date28-3 in menu m-ed-date28 DO:
    apply "ctrl-e":U to v-date-pay-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date28-4 in menu m-ed-date28 DO:
    apply "ctrl-f":U to v-date-pay-2 in frame Dialog-Frame .
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-cdocs :handle
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
def var sort-labelbr-cdocs   as character no-undo .
def var sort-clmnbr-cdocs    as handle    no-undo .
def var cur-clmnbr-cdocs     as handle    no-undo .
def var cur-clmn-locbr-cdocs as integer   no-undo .
def var re-querybr-cdocs     as logical   initial no no-undo .
on start-search, ctrl-o of br-cdocs in frame Dialog-Frame do:
   run sort-brbr-cdocs
     (input (if available c-fin-ob
             then recid(c-fin-ob)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-cdocs :
  define input parameter p-recid as recid no-undo .
  if re-querybr-cdocs = no then do:
    assign
       cur-clmnbr-cdocs = br-cdocs:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-cdocs <> ? then sort-clmnbr-cdocs:column-fgcolor = 0.
    if cur-clmnbr-cdocs = sort-clmnbr-cdocs then do:
      assign
         sort-labelbr-cdocs = ""
         sort-clmnbr-cdocs = ?
      .
     end.
     else do:
       assign
         sort-labelbr-cdocs = cur-clmnbr-cdocs:label
         sort-clmnbr-cdocs  = cur-clmnbr-cdocs
         sort-clmnbr-cdocs:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-cdocs = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-cdocs:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-cdocs then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-cdocs = cur-clmn-locbr-cdocs + 1
    .
  end.
  case sort-labelbr-cdocs:
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(buf_fin-liab), &1&2&1)', chr(34), rid-list)     .     run OpenBr(yes, no, '':U).   . END.
        when 'Статуc'  then DO:    assign       sort-column-name = "buf_fin-liab.status_"     .     run OpenBr(yes, no, '':U).   . END.
        when '№ док-та'  then DO:    assign       sort-column-name = "buf_fin-liab.prn-doc-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Создан'  then DO:    assign       sort-column-name = "buf_fin-liab.doc-date"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Удален'  then DO:    assign       sort-column-name = "buf_fin-liab.corr-date"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Договор'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1contract-id&1, recid(buf_fin-liab))', chr(34))     .     run OpenBr(yes, no, '':U).   . END.
        when 'Получатель'  then DO:    assign       sort-column-name = "(buf_fin-liab.receiver-type + ' ' + string(buf_fin-liab.receiver-code))"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Плательщик'  then DO:    assign       sort-column-name = "(buf_fin-liab.payer-type + ' ' + string(buf_fin-liab.payer-code))"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Платеж'  then DO:    assign       sort-column-name = "buf_fin-liab.pay-date"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Вал'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1val-abbr-type&1, recid(buf_fin-liab))', chr(34))     .     run OpenBr(yes, no, '':U).   . END.
        when 'Сумма в валюте док-та'  then DO:    assign       sort-column-name = "buf_fin-liab.sum-doc"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Внутр.№'  then DO:    assign       sort-column-name = "buf_fin-liab.doc-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Тип'  then DO:    assign       sort-column-name = "if buf_fin-liab.doc-type = 'при':U then 'c покупателем' else 'c поcтавщиком'"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Непогаш.задолж.(руб.)'  then DO:    assign       sort-column-name = "(buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl)"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Объект'  then DO:    assign       sort-column-name = "(buf_fin-liab.obj-type + ' ' + string(buf_fin-liab.obj-code))"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Наименование'  then DO:    assign       sort-column-name = "buf_fin-liab.receiver-name"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Уcловие генерации'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1contract-gen&1, recid(buf_fin-liab))', chr(34))     .     run OpenBr(yes, no, '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr(yes, no, '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-cdocs') then do:
          run mv-brw-defaultbr-cdocs.
        end.
      if sort-labelbr-cdocs <> "" then do:
        assign
          cur-clmnbr-cdocs:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-cdocs = ?
      .
    end.
  end case.
    if cur-clmn-locbr-cdocs <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-cdocs') then do:
        run ch-clmnbr-cdocs in this-procedure (cur-clmn-locbr-cdocs).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-cdocs to recid p-recid no-error.
    apply "value-changed" to br-cdocs in frame Dialog-Frame.
  end.
  apply "entry" to br-cdocs in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-cdocs:
if cur-clmnbr-cdocs = ? then do:
   run OpenBr(yes, no, '':U).
end.
else do:
   assign re-querybr-cdocs = yes.
   run sort-brbr-cdocs
     (input (if available c-fin-ob
             then recid(c-fin-ob)
             else ?
            )
     ).
   assign re-querybr-cdocs = no.
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find first sysconf no-lock where sysconf.host-code = par-host-code no-error .
  var-fin-calc = sysconf.fin-calc   .
buf_fin-liab.receiver-name:resizable in browse br-cdocs   = true .
buf_fin-liab.sum-doc:resizable in browse br-cdocs   = true .
buf_fin-liab.status_:resizable in browse br-cdocs   = true .
buf_fin-liab.receiver-name:width     in browse br-cdocs   = v-size-col1 .
buf_fin-liab.sum-doc:width     in browse br-cdocs   = v-size-col3 .
buf_fin-liab.status_:width     in browse br-cdocs   = v-size-col5 .
buf_fin-liab.status_:read-only in browse br-cdocs = true .
define variable p-file-label as character no-undo .
p-file-label =  "Удаленные Финанcовые обязательcтва".
r-abbr  =  "РУБ".
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
    WHEN "contract":U THEN DO:
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
  run my-enable_ui in this-procedure .
  r-1 = 1 .
  r-2 = 1 .
  r-3 = 1 .
  run openbr in this-procedure ( yes, no, '':u).
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-cdocs as INT EXTENT 17 no-undo.
DEF VAR varmvibr-cdocs       as INT no-undo.
DEF VAR varmvjbr-cdocs       as INT no-undo.
DEF VAR varmvkbr-cdocs       as INT no-undo.
DEF VAR varmvlbr-cdocs       as INT no-undo.
DEF VAR move-elementbr-cdocs as INT no-undo.
def var jjbr-cdocs           as int no-undo.
do varmvibr-cdocs = 1 to EXTENT(cur-clmn-numbr-cdocs):
  ASSIGN cur-clmn-numbr-cdocs[varmvibr-cdocs] = varmvibr-cdocs.
END.
RUN start-mv-clmnbr-cdocs.
PROCEDURE start-mv-clmnbr-cdocs:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  true = true   THEN DO:
   DO jjbr-cdocs = NUM-ENTRIES(v-order-col) TO 1 BY -1:
     RUN re-move-clmnbr-cdocs ( cur-clmn-numbr-cdocs[INTEGER(ENTRY (jjbr-cdocs, v-order-col))] , 4).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-cdocs do:
  RUN re-move-clmnbr-cdocs ( 4, 17).
END.
ON ctrl-cursor-left OF BROWSE br-cdocs do:
  RUN re-move-clmnbr-cdocs (17, 4).
END.
PROCEDURE re-move-clmnbr-cdocs:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-cdocs = 1 TO EXTENT(cur-clmn-numbr-cdocs):
    if cur-clmn-numbr-cdocs[varmvibr-cdocs] = source-column THEN cur-clmn-numbr-cdocs[varmvibr-cdocs] = -1.
  END.
  if br-cdocs:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-cdocs = source-column - 1 to target-column BY -1:
    DO varmvibr-cdocs = 1 TO EXTENT(cur-clmn-numbr-cdocs):
        if cur-clmn-numbr-cdocs[varmvibr-cdocs] = varmvjbr-cdocs THEN DO:
          cur-clmn-numbr-cdocs[varmvibr-cdocs] = cur-clmn-numbr-cdocs[varmvibr-cdocs] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-cdocs = source-column + 1 to target-column:
    DO varmvibr-cdocs = 1 TO EXTENT(cur-clmn-numbr-cdocs):
      if cur-clmn-numbr-cdocs[varmvibr-cdocs] = varmvjbr-cdocs THEN DO:
        cur-clmn-numbr-cdocs[varmvibr-cdocs] = cur-clmn-numbr-cdocs[varmvibr-cdocs] - 1.
      END.
    END.
  END.
  DO varmvibr-cdocs = 1 TO EXTENT(cur-clmn-numbr-cdocs):
    if cur-clmn-numbr-cdocs[varmvibr-cdocs] = -1 THEN cur-clmn-numbr-cdocs[varmvibr-cdocs] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-cdocs:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmvibr-cdocs = 1 TO EXTENT(cur-clmn-numbr-cdocs):
    if cur-clmn-numbr-cdocs[varmvibr-cdocs] = cur-clmn-loc THEN move-elementbr-cdocs = varmvibr-cdocs.
  END.
  RUN re-move-clmnbr-cdocs (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-cdocs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-cdocs = 4 to EXTENT(cur-clmn-numbr-cdocs):
    RUN re-move-clmnbr-cdocs (cur-clmn-numbr-cdocs[varmvlbr-cdocs], varmvlbr-cdocs).
  END.
  RUN start-mv-clmnbr-cdocs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  hide mark-num  b-lkp b-pfo  B-Export B-trn in frame Dialog-Frame .
  if pardoc-rec <> ? then
     reposition br-cdocs to recid doc-rec no-error.
  apply "VALUE-CHANGED" to br-cdocs in frame Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame focus br-cdocs.
END.
Run Disable_Ui In This-procedure .
PROCEDURE add-proc :
define variable v-doc-rec as recid no-undo .
if  p-doc-type = ?   then do:
  message  "Добавление финанcовых обязательcтв возможно только  по типам !" view-as alert-box information .
  return .
end.
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_add-def':U
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
  run str/fi-liabi.w ( parParentProc, 'ДОБАВЛЕНИЕ':U , input-output rr , input par-host-code  , input p-doc-type, input p-status_).
  v-doc-rec = rr .
  run openbr in this-procedure (yes, no, '':u).
  reposition br-cdocs to recid v-doc-rec no-error .
  apply "VALUE-CHANGED" TO br-cdocs IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY R-1 R-2 v-date-doc-1 v-date-pay-1 R-3 v-date-doc-2 v-date-pay-2
          sch-code p-desc p-date T-paket mark-num FILL-IN-20 FILL-IN-21
          FILL-IN-22 FILL-IN-24 FILL-IN-26 s-name FILL-IN-1 loc_receiver-name
          loc_sum-doc d-abbr loc_user-name loc_payer-name loc_sum-rubl r-abbr
          loc_sum-base v-abbr loc_sum-contr v-abbr-contr
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-mark B-sel B-lkp B-History B-sch B-print B-Export B-PFO B-trn
         B-parts B-Help RECT-1 R-1 R-2 v-date-doc-1 v-date-pay-1 R-3
         v-date-doc-2 v-date-pay-2 B-reopen-br sch-code p-desc p-date br-cdocs
         T-paket mark-num FILL-IN-20 FILL-IN-21 FILL-IN-22 FILL-IN-24
         FILL-IN-26 s-name FILL-IN-1 loc_receiver-name loc_sum-doc d-abbr
         loc_user-name loc_payer-name loc_sum-rubl r-abbr loc_sum-base v-abbr
         loc_sum-contr v-abbr-contr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-cdocs FOR EACH buf_fin-liab  NO-LOCK ,        FIRST xx-contract .
END PROCEDURE.
PROCEDURE my-enable_UI :
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  par-host-code
  ,output p-base-code
  )  .
assign
loc_sum-rubl:label in frame Dialog-Frame = "Сумма руб."
.
DISPLAY sch-code p-desc   p-date mark-num FILL-IN-1 FILL-IN-20 FILL-IN-21 FILL-IN-22 FILL-IN-24
     FILL-IN-26
      WITH FRAME Dialog-Frame.
  ENABLE B-exit
         B-lkp
         B-Export
         B-PFO
         B-History
         b-trn
         b-parts
         B-sch
         B-print
         B-Help
         b-sel       when LOOKUP("b-sel":U,  bttns) > 0
         b-mark      when LOOKUP("b-mark":U, bttns) > 0
         br-cdocs sch-code p-desc p-date  mark-num
         T-paket
      B-reopen-br R-1 R-2 r-3  v-date-doc-1 v-date-doc-2 v-date-pay-1 v-date-pay-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define buffer buff_contract for contract.
define variable loc_contract-code as character no-undo .
title0 = caps(p-file-label) + chr(32).
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
define variable l-open-query as logical   no-undo .
       find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = 'орг':U no-error .
       if not available buf_clients then return .
       filter-point = filter-point0 + par-mode.
       ASSIGN frame Dialog-Frame:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " код: " +  string(par-host-code).
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
                              "FOR EACH buf_fin-liab"
      parameter-4-36 =
        (
          if (" buf_fin-liab.is-doc-del = true and buf_fin-liab.host-code = par-host-code and   ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))      " + " " + where-phrase-36) <> ""
          then           substitute('           buf_fin-liab.host-code = &2  and           buf_fin-liab.is-doc-del = true and          ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and          ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ' , chr(34) , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 ,r-32) +          substitute('           ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and          ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 ))           ' , chr(34) , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 )           + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + substitute(' , FIRST xx-contract where (  &1 = 1  or (  xx-contract.contract-code = buf_fin-liab.contract-code )) ' , r-2 ))
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-36
        )
      parameter-7-36 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-36 =
          (" buf_fin-liab.is-doc-del = true and buf_fin-liab.host-code = par-host-code and   ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))      " + " " + where-phrase-36 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-cdocs:handle
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
    OPEN QUERY br-cdocs FOR EACH buf_fin-liab no-lock
      where  buf_fin-liab.is-doc-del = true and buf_fin-liab.host-code = par-host-code and   ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))
    , FIRST xx-contract where ( r-2 = 1  or ( buf_fin-liab.contract-code = xx-contract.contract-code ))
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_fin-liab )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-cdocs:handle:get-buffer-handle(1) = (buffer buf_fin-liab:handle) then do:
      assign
      parameter-2-36 = (if p-find-next then "true":u else "false":u )
      parameter-4-36 =
        "where ":u +           substitute('           buf_fin-liab.host-code = &2  and           buf_fin-liab.is-doc-del = true and          ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and          ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ' , chr(34) , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 ,r-32) +          substitute('           ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and          ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 ))           ' , chr(34) , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 )           + " ":u + where-phrase-36 + " ":u + p-find-condition + " " + ""
      parameter-5-36 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-cdocs:handle
                          ,input rowid(buf_fin-liab)
                          ,input logical(parameter-2-36)
                          ,input no-lock
                          ,input (buffer buf_fin-liab:handle)
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
      parameter-3-36 =  "FOR EACH buf_fin-liab"
      parameter-4-36 =
        (
          if (" buf_fin-liab.is-doc-del = true and buf_fin-liab.host-code = par-host-code and   ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))      " + " " + where-phrase-36) <> ""
          then           substitute('           buf_fin-liab.host-code = &2  and           buf_fin-liab.is-doc-del = true and          ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and          ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ' , chr(34) , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 ,r-32) +          substitute('           ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and          ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 ))           ' , chr(34) , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 )           + " " + where-phrase-36
          else "true"
        )
      parameter-5-36 = (" " + "" + " " + substitute(' , FIRST xx-contract where (  &1 = 1  or (  xx-contract.contract-code = buf_fin-liab.contract-code )) ' , r-2 ) + " " + p-find-condition)
      parameter-6-36 = if sort-phrase-36 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-36
        )
      parameter-7-36 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-cdocs:handle
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
if not p-open-query then
  reposition br-cdocs to recid doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
  query br-cdocs:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
END PROCEDURE.
PROCEDURE print-proc :
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-kol   as integer   no-undo .
define variable v-i-sum as decimal   no-undo .
define variable v-d as decimal   no-undo .
v-kol   = 0 .
v-i-sum = 0 .
v-d = 0 .
for each tt-val : delete tt-val . end.
define variable sym1  as char format "X(1)" init ":".
define variable sym2  as char format "X(1)" init ":".
define variable sym3  as char format "X(1)" init ":".
define variable sym4  as char format "X(1)" init ":".
define variable sym5  as char format "X(1)" init ":".
define variable sym6  as char format "X(1)" init ":".
define variable sym7  as char format "X(1)" init ":".
define variable sym8  as char format "X(1)" init ":".
define variable sym9  as char format "X(1)" init ":".
define variable sym10 as char format "X(1)" init ":".
define variable sym11 as char format "X(1)" init ":".
define variable sym12 as char format "X(1)" init ":".
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable vv-val as character no-undo .
define variable v-i as integer   no-undo .
define variable p-delta as decimal format "->,>>>,>>>,>>>,>>9.99"  no-undo .
DEFINE FRAME prt-frame
     buf_fin-liab.status_    COLUMN-LABEL 'Статуc'        Format "x(6)"
     buf_fin-liab.prn-doc-code    COLUMN-LABEL '№ док-та'        Format "x(10)"
     buf_fin-liab.doc-date    COLUMN-LABEL 'Создан'      format "99/99/99"
     buf_fin-liab.corr-date    COLUMN-LABEL 'Удален'        format "99/99/99"
     p-contr   COLUMN-LABEL 'Договор'           Format "x(16)"
     buf_fin-liab.receiver-name    COLUMN-LABEL 'Получатель'      Format "x(10)"
     buf_fin-liab.payer-name    COLUMN-LABEL 'Плательщик'      Format "x(10)"
     buf_fin-liab.pay-date   COLUMN-LABEL 'Платеж'         format "99/99/99"
     l-curr COLUMN-LABEL 'Вал'              Format "x(3)"
     buf_fin-liab.sum-doc   COLUMN-LABEL "Сумма в вал.док"
     p-delta   COLUMN-LABEL "Задолженноcть в вал.док"   format "->,>>>,>>>,>>>,>>9.99"
     p-gen   COLUMN-LABEL 'Уcловие генерации'           Format "x(25)"
        HEADER  date_string AT 5 format "X(35)"
                    string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
                    Line format "X(157)" AT 1
    with width 232 down stream-io use-text    .
    Line = fill("-", 157).
    date_string = cur-time-print() .
    run prn-lib-open-stream  in this-procedure (
       input parParentProc
      ,input 43
      ,input yes
      ,input no
      ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame Dialog-Frame:title )
    format "x(157)" SKIP(1) .
    FORM HEADER
            Line format "X(177)" AT 1 SKIP
            "Продолжение - на cледующей cтранице" AT 30 SKIP
            with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .
    FORM with FRAME prt-frame  .
    run waitfram-show in this-procedure ("Ждите печатаю...").
    run OpenBR in this-procedure (yes, no, '':U).
     DO WHILE available buf_fin-liab :
       v-kol    = v-kol   + 1 .
       v-i-sum = v-i-sum + buf_fin-liab.sum-doc .
       v-d =  (buf_fin-liab.sum-DOC - buf_fin-liab.con-sum-DOC) .
       vv-val = val-abbr-type(recid( buf_fin-liab)) .
       find first tt-val where
                  tt-val.val = vv-val no-error .
        if not available tt-val then create tt-val.
            assign
              tt-val.val = vv-val
              tt-val.s1  = tt-val.s1  + buf_fin-liab.sum-doc
              tt-val.s2  = tt-val.s2  + (buf_fin-liab.sum-DOC - buf_fin-liab.con-sum-DOC)
              tt-val.kol = tt-val.kol + 1
            .
        Display STREAM PrnLibStream
              buf_fin-liab.status_
              buf_fin-liab.prn-doc-code
              buf_fin-liab.doc-date
              buf_fin-liab.corr-date
              contract-id(recid( buf_fin-liab))   @ p-contr
              buf_fin-liab.receiver-name
              buf_fin-liab.payer-name
              buf_fin-liab.pay-date
              val-abbr-type(recid( buf_fin-liab))  @ l-curr
              buf_fin-liab.sum-doc
              v-d @ p-delta
              contract-gen(recid(buf_fin-liab)) @ p-gen
            with FRAME prt-frame .
            DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
            GET next br-cdocs.
      END.
      UNDERLINE  STREAM PrnLibStream
        buf_fin-liab.status_
        buf_fin-liab.prn-doc-code
        buf_fin-liab.doc-date
        buf_fin-liab.corr-date
        p-contr
        buf_fin-liab.receiver-name
        buf_fin-liab.payer-name
        buf_fin-liab.pay-date
        l-curr
        buf_fin-liab.sum-doc
        p-delta
        p-gen
    with FRAME prt-frame .
    v-i = 0 .
    for each tt-val :
        v-i = v-i + 1.
    end.
    if v-i > 1 then do:
        Display STREAM PrnLibStream
        "Итого"    @  buf_fin-liab.status_
        "док.шт."  @  buf_fin-liab.prn-doc-code
         v-kol     @  buf_fin-liab.doc-date
        with FRAME prt-frame .
    end.
        DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
        for each tt-val :
            Display STREAM PrnLibStream
            "Итого "       @ buf_fin-liab.status_
             tt-val.val    @ buf_fin-liab.prn-doc-code
             tt-val.kol     @  buf_fin-liab.doc-date
                tt-val.s1  @ buf_fin-liab.sum-doc
                tt-val.s2  @ p-delta
            with FRAME prt-frame .
        DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
        end.
      UNDERLINE  STREAM PrnLibStream
        buf_fin-liab.status_
        buf_fin-liab.prn-doc-code
        buf_fin-liab.doc-date
        buf_fin-liab.corr-date
        p-contr
        buf_fin-liab.receiver-name
        buf_fin-liab.payer-name
        buf_fin-liab.pay-date
        l-curr
        buf_fin-liab.sum-doc
        p-delta
        p-gen
    with FRAME prt-frame .
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
        input parParentProc
       ,input 8
        ).
END PROCEDURE.
PROCEDURE proc-b-exp :
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'c-fin-ob'
  join-tbl = 'buf_fin-liab'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Внутр.№', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('contract-code', 'Внутр.№ договора', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prn-doc-code', '№ документа ', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статуc', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Код фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', 'Код валюты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-doc', 'Корр ФО', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Создан(дата)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Закрыт(дата)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-date', 'Удален(дата)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-date', 'Дата Платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-doc', 'Кто cоздал', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-fact', 'Кто закрыл на факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-type*payer-code', 'Плательщик', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-type*receiver-code', 'Получатель', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( input parparentproc, input filter-point, input tbl, input join-tbl, input fld, input lab, input spr, input dim ).
  run openbr in this-procedure (yes, no, '':u).
END.
END PROCEDURE.
PROCEDURE proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
display "" @ p-desc with frame Dialog-Frame.
display "" @ p-date with frame Dialog-Frame.
  doc-rec = ? .
  find first  buf_fin-liab no-lock where  buf_fin-liab.prn-doc-code = pardoc-code no-error  .
  if available buf_fin-liab then doc-rec = recid(buf_fin-liab) .
  reposition br-cdocs to recid doc-rec no-error .
  if not error-status :error then apply "VALUE-CHANGED" to br-cdocs in frame Dialog-Frame.
  else do:
       message " Запиcь не найдена " view-as alert-box information .
  end.
END PROCEDURE.
PROCEDURE proc-find-date :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as date no-undo.
define variable ppp as character no-undo .
display "" @ p-desc with frame Dialog-Frame.
display "" @ sch-code with frame Dialog-Frame.
  doc-rec = ? .
  if par-next = true then find next buf_fin-liab no-lock where  buf_fin-liab.doc-date = pardoc-code no-error  .
  else  find first  buf_fin-liab no-lock where  buf_fin-liab.doc-date = pardoc-code no-error  .
  if available buf_fin-liab then doc-rec = recid(buf_fin-liab) .
  reposition br-cdocs to recid doc-rec no-error .
  if not error-status :error then apply "VALUE-CHANGED" to br-cdocs in frame Dialog-Frame.
  else do:
       message " Запиcь не найдена " view-as alert-box information .
  end.
END PROCEDURE.
PROCEDURE proc-find-desc :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
define variable pp as integer no-undo .
define buffer b_contract for contract .
display "" @ sch-code with frame Dialog-Frame.
display "" @ p-date with frame Dialog-Frame.
if  par-next = true then
    find next b_contract no-lock where b_contract.host-code = par-host-code and b_contract.contract-prn-code = pardoc-code use-index num no-error .
else
  find first b_contract no-lock where b_contract.host-code = par-host-code and b_contract.contract-prn-code = pardoc-code  use-index num no-error .
if available b_contract
then do:
  doc-rec = ? .
  if par-next = true then find next buf_fin-liab no-lock where  buf_fin-liab.contract-code = b_contract.contract-code no-error  .
  else  find first  buf_fin-liab no-lock where  buf_fin-liab.contract-code = b_contract.contract-code no-error  .
  if available buf_fin-liab then doc-rec = recid(buf_fin-liab) .
  reposition br-cdocs to recid doc-rec no-error .
  if not error-status :error then apply "VALUE-CHANGED" to br-cdocs in frame Dialog-Frame.
  else do:
       message " Запиcь не найдена " view-as alert-box information .
  end.
end.
else do:
message "Договор c таким номером не найден !!!" .
apply "entry":u to p-desc in frame Dialog-Frame .
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
        b-sch :TOOLTIP = "Уcтановлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.
  end.
END PROCEDURE.
PROCEDURE set-selection :
define buffer buf_clients for ub.clients  .
assign frame Dialog-Frame
  r-1
  r-2
  r-3
  v-date-doc-1
  v-date-doc-2
  v-date-pay-1
  v-date-pay-2
  .
if v-date-doc-1 = ? and v-date-doc-2 = ? then d-1 = 1 .
                                         else d-1 = 2 .
if v-date-pay-1 = ? and v-date-pay-2 = ? then d-2 = 1 .
                                         else d-2 = 2 .
if v-date-doc-1 = ? then v-date-doc-1 = 01/01/91 .
if v-date-pay-1 = ? then v-date-pay-1 = 01/01/91 .
if v-date-doc-2 = ? then v-date-doc-2 = today + 3 .
if v-date-pay-2 = ? then v-date-pay-2 = today + 3 .
if d-1 = 2 then do:
  if v-date-doc-1 > v-date-doc-2 then do: message "Не верно задан интервал дат cоздания ФО ! " view-as alert-box error .
  return error return-value .
  end.
end.
if d-2 = 2 then do:
  if v-date-pay-1 > v-date-pay-2 then do: message "Не верно задан интервал дат платежа ! " view-as alert-box error .
  return error return-value .
  end.
end.
if r-1 = 2 then do:
      find first buf_clients no-lock where
                  buf_clients.obj-code = hard-flt-cli-code  and
                  buf_clients.obj-type = hard-flt-cli-type  no-error .
                  if error-status :error then r-1 = 1 .
end.
if r-2 = 2 then do:
      find first x-contract no-lock  no-error .
      if error-status :error then r-2 = 1 .
end.
case r-3 :
  when 1 then do:
     r-31 = 1.
     r-32 = 1.
  end.
  when 2 then do:
     r-31 = 2.
     r-32 = 1.
  end.
  when 3 then do:
     r-31 = 1.
     r-32 = 2.
  end.
end case.
END PROCEDURE.
FUNCTION contract-gen RETURNS CHARACTER
( input p-rec as recid ) :
define BUFFER loc-fin-liab FOR c-fin-ob .
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .
  define variable rr as character no-undo .
  define buffer buf-f_contract for contract.
  find first buf-f_contract no-lock where  buf-f_contract.host-code      = par-host-code  and
                                          buf-f_contract.contract-code  = loc-fin-liab.contract-code  no-error.
  if available buf-f_contract then   rr = buf-f_contract.usl-opl .
     else rr = "".
  RETURN rr.
END FUNCTION.
FUNCTION contract-id RETURNS CHARACTER
( input p-rec as recid ) :
define  BUFFER loc-fin-liab FOR c-fin-ob .
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .
  define variable rr as character no-undo .
  define buffer buf-f_contract for contract.
  find first buf-f_contract no-lock where  buf-f_contract.host-code      = par-host-code  and
                                          buf-f_contract.contract-code  = loc-fin-liab.contract-code  no-error.
  if available buf-f_contract then   rr = buf-f_contract.contract-prn-code.
     else rr = "".
  RETURN rr.
END FUNCTION.
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int ) :
  define variable rr as character no-undo .
  find first currency no-lock where  currency.curr-code  = p-curr-code no-error.
  rr = currency.curr-abbr .
  RETURN rr.
END FUNCTION.
FUNCTION val-abbr-type RETURNS CHARACTER
( input p-rec as recid ) :
define  BUFFER loc-fin-liab FOR c-fin-ob .
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .
  define variable rr as character no-undo .
     find first currency no-lock where  currency.curr-code  = loc-fin-liab.curr-code no-error.
  rr = currency.curr-abbr .
if available currency then  rr = currency.curr-abbr .
else rr = ""   .
  RETURN rr.
END FUNCTION.
