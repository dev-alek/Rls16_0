DEFINE NEW SHARED TEMP-TABLE x-contract NO-UNDO LIKE ub.contract.
define input parameter parparentproc  as widget-handle no-undo.
define input parameter bttns          as character   no-undo .
define input parameter par-mode       as character   no-undo .
define input parameter pardoc-rec     as recid no-undo.
define input parameter par-host-code  like ub.clients.obj-code no-undo.
define input parameter p-doc-type     as character no-undo .
define input parameter p-status_      as character no-undo .
define input parameter p-char         as character no-undo .
define output parameter rid-list      as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список фин.обязательств".
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
define variable varfactur          as   character             no-undo.
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
define variable p-debts as decimal   no-undo .
define variable p-doc-type-full   as character no-undo .
define variable var-fin-calc as integer no-undo .
define variable hard-flt-cli-code  as integer   no-undo .
define variable hard-flt-cli-type  as character no-undo .
define variable r-31 as integer   no-undo init 1.
define variable r-32 as integer   no-undo init 1.
define variable d-1 as integer   no-undo init 1.
define variable d-2 as integer   no-undo init 1.
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
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
procedure proc-close-one-fin-ob :
 do
 on error undo, return error return-value
 :
define input parameter p-recid  as recid no-undo .
define buffer buf_fin-liab-fo   for ub.fin-ob .
define buffer buf_fin-ob-before for ub.fin-ob-before .
define buffer ff_fin-ob-trn     for ub.fin-ob-trn  .
define variable  v-fact-date            as date    no-undo .
define variable  v-fact-time            as integer no-undo .
define variable  v-fact-num             as integer no-undo .
define variable  v-shift-date           as date    no-undo .
define variable  v-shift-num            as integer no-undo .
define variable  v-shift-on             as logical no-undo .
define variable  v-fact-order           as decimal no-undo .
define variable  v-shift-end-fact-order as decimal no-undo .
define variable  v-day-end-fact-order   as decimal no-undo .
define variable  var-fo-fact as logical   no-undo .
define variable  par-type         as character no-undo .
define variable  v-value-date     as date   no-undo .
define variable  v-value-decimal  as decimal   no-undo .
define variable  v-value-integer  as integer   no-undo .
define variable  v-value-logical  as logical   no-undo .
define variable v-found           as logical   no-undo .
define variable v-value-character as character no-undo .
define variable v-i as integer   no-undo .
define variable p-recalc     as logical   no-undo .
define variable p-recalc2    as logical   no-undo .
define buffer recalc_fin-ob for ub.fin-ob  .
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   'fin-global':U ,
  input   'fo-fact'  ,
  output  v-value-character ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  var-fo-fact  ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
if error-status :error then var-fo-fact = false .
find first buf_fin-liab-fo no-lock where recid(buf_fin-liab-fo) = p-recid  no-error .
release buf_fin-liab-fo no-error .
find first  buf_fin-liab-fo  exclusive-lock  where recid(buf_fin-liab-fo) = p-recid  no-error .
if not available buf_fin-liab-fo then return error .
   if buf_fin-liab-fo.pay-date = ? then do:
      message "Финансовое обязательство : " buf_fin-liab-fo.prn-doc-code  skip
              "не задана дата платежа!"  skip
              "Закрывать ФО ?"
              view-as alert-box question
              buttons yes-no
              update v-ok as log
            .
      if v-ok = false then  return.
   end.
   if buf_fin-liab-fo.status_ = 'факт':U then do:
      message "Финансовое обязательство " buf_fin-liab-fo.prn-doc-code  " уже закрыто до ФАКТ".
      return.
   end.
  run cur-time
      ( output v-fact-date
      , output v-fact-time
      ).
  if var-fo-fact = yes then do:
     v-fact-date = 01/01/1900 .
     v-i = 0 .
     for each ff_fin-ob-trn no-lock  where
              ff_fin-ob-trn.doc-code  =  buf_fin-liab-fo.doc-code and
              ff_fin-ob-trn.host-code =  buf_fin-liab-fo.host-code
            :
            v-i = v-i + 1.
           case ff_fin-ob-trn.doc-type  :
           when "spc" then do:
              run cur-time
                  ( output v-fact-date
                  , output v-fact-time
                  ).
           end.
           when "order" then do:
                find first ub.ord-doc   no-lock where ub.ord-doc.doc-code   =  ff_fin-ob-trn.trn-doc-code no-error .
                if available ub.ord-doc then do:
                    if v-fact-date < ub.ord-doc.fact-date then v-fact-date = ub.ord-doc.fact-date.
                end.
           end.
           when "rcv" then do:
              run cur-time
                  ( output v-fact-date
                  , output v-fact-time
                  ).
           end.
           when "add" then do:
              run cur-time
                  ( output v-fact-date
                  , output v-fact-time
                  ).
           end.
           otherwise do:
                find first ub.trn-doc   no-lock where ub.trn-doc.doc-code   =  ff_fin-ob-trn.trn-doc-code no-error .
                if available ub.trn-doc then do:
                    if v-fact-date < ub.trn-doc.fact-date then v-fact-date = ub.trn-doc.fact-date.
                end.
                find first ub.c-trn-doc no-lock where ub.c-trn-doc.doc-code =  ff_fin-ob-trn.trn-doc-code
                                                  and ub.c-trn-doc.is-del = true   no-error .
                if available ub.c-trn-doc then do:
                    if v-fact-date < ub.c-trn-doc.corr-date then v-fact-date = ub.c-trn-doc.corr-date.
                end.
           end.
           end case.
     end.
     if v-i = 0  then do:
          run cur-time
              ( output v-fact-date
              , output v-fact-time
              ).
     end.
  end.
  assign
      v-fact-num   = next-value ( s-fin-ob-fact, ub )
      v-shift-date = ?
      v-shift-num  = ?
      v-shift-on   = false
  .
   run factord in this-procedure (
       input  v-fact-date
      ,input  v-fact-time
      ,input  v-fact-num
      ,input  v-shift-date
      ,input  v-shift-num
      ,input  v-shift-on
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) .
   assign
    buf_fin-liab-fo.fact-order       =  v-fact-order
    buf_fin-liab-fo.status_          =  'факт':U
    buf_fin-liab-fo.fact-date        =  v-fact-date
    buf_fin-liab-fo.user-db-num-fact =  g#db-num
    buf_fin-liab-fo.user-name-fact   =  g#userid
   .
   run str/calc-bal.p (input "finob", input yes, input buf_fin-liab-fo.doc-type, input buf_fin-liab-fo.host-code, input buf_fin-liab-fo.contract-code, input buf_fin-liab-fo.sum-contract, input buf_fin-liab-fo.sum-rubl, input buf_fin-liab-fo.sum-base) .
   find first ub.contract no-lock
        where ub.contract.contract-code = buf_fin-liab-fo.contract-code and
              ub.contract.host-code     = buf_fin-liab-fo.host-code
              no-error.
   if available ub.contract then do:
     if ( ub.contract.gen-factur = 2 or
          ub.contract.gen-factur = 12 or
          ub.contract.gen-factur = 102 or
          ub.contract.gen-factur = 112) then
       assign
         buf_fin-liab-fo.need-factur = 1
         .
   end.
   for each buf_fin-ob-before  exclusive-lock  where
            buf_fin-ob-before.host-code = buf_fin-liab-fo.host-code and
            buf_fin-ob-before.doc-code  = buf_fin-liab-fo.doc-code and
            buf_fin-ob-before.status_   = 'авто':U
            on error undo, return error :
        assign
          buf_fin-ob-before.fact-order       =  v-fact-order
          buf_fin-ob-before.status_          =  'факт':U
          buf_fin-ob-before.fact-date        =  v-fact-date
          buf_fin-ob-before.user-db-num-fact =  g#db-num
          buf_fin-ob-before.user-name-fact   =  g#userid
        .
   end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libofarh) <> true) then do:   run str/libofarh.p persistent no-error .   if error-status :error or (valid-handle(g#libofarh) <> true) then do:     message       "Error starting libofarh.p" skip       g#libofarh skip       g#libofarh :type skip       g#libofarh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libofarh_taskclco in g#libofarh
(input buf_fin-liab-fo.host-code
,input buf_fin-liab-fo.doc-code
,input g#userid
,input 'close':u
,input yes
,output p-recalc
) no-error
.
        if error-status :error then do:
          message
            "При обновлении архива обнаружена ошибка " skip
            return-value skip
            error-status :get-message(1) skip
            view-as alert-box error .
          undo, return error "Ошибка расчета архива" .
        end.
        if p-recalc then do:
              for each recalc_fin-ob no-lock where
                       recalc_fin-ob.host-code = buf_fin-liab-fo.host-code  and
                       recalc_fin-ob.status_   = 'факт':U  and
                       recalc_fin-ob.fact-order > buf_fin-liab-fo.fact-order
                       break by recalc_fin-ob.fact-order
                  :
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libofarh) <> true) then do:   run str/libofarh.p persistent no-error .   if error-status :error or (valid-handle(g#libofarh) <> true) then do:     message       "Error starting libofarh.p" skip       g#libofarh skip       g#libofarh :type skip       g#libofarh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libofarh_taskclco in g#libofarh
(input recalc_fin-ob.host-code
,input recalc_fin-ob.doc-code
,input g#userid
,input 'close':u
,input yes
,output p-recalc2
) no-error
.
                    if error-status :error then do:
                      message
                      "При персчете архива обнаружена ошибка " skip
                      return-value skip
                      error-status :get-message(1) skip
                      view-as alert-box error .
                      undo, return error "Ошибка расчета архива" .
                    end.
              end.
        end.
 end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userhsts_temp-user-host no-undo
  field host-code as integer
  index xpk is primary unique host-code
  .
procedure userhsts_clear :
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    for each buf_userhsts_temp-user-host
    on error undo, return error return-value
    :
      delete buf_userhsts_temp-user-host .
    end.
  end.
end procedure.
procedure userhsts_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userhsts_temp-user-host
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end procedure.
procedure userhsts_append :
  define input  parameter p-host-code as integer   no-undo .
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    find first buf_userhsts_temp-user-host
      where buf_userhsts_temp-user-host.host-code = p-host-code
      no-error .
    if not available buf_userhsts_temp-user-host
    then do:
      create buf_userhsts_temp-user-host .
      assign
        buf_userhsts_temp-user-host.host-code = p-host-code
      .
    end.
  end.
end procedure.
procedure userhsts_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    find first buf_userhsts_temp-user-host
      no-error .
    if not available buf_userhsts_temp-user-host
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
end procedure.
procedure userhsts_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userhsts_transfer: Передача списка объектов".
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
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
    if p-callback-handle :get-signature("userhsts_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userhsts_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userhsts_temp-user-host
    on error undo, return error return-value
    :
      run userhsts_append in p-callback-handle
        (input  buf_userhsts_temp-user-host.host-code
        ) .
    end.
  end.
end procedure.
procedure userhsts_select-one :
  define input  parameter parparentproc      as widget-handle no-undo .
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-curr-host-code   as integer   no-undo .
  define output parameter p-user-select      as logical   no-undo .
  define output parameter p-select-host-code as character no-undo .
  DEFINE VARIABLE v-List-select-host-code AS CHARACTER NO-UNDO INITIAL "".
  do
  on error undo, return error return-value
  :
    run gbl/userhsts.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-curr-host-code
      ,input  "b-sel"
      ,output p-user-select
      ,output p-select-host-code
      ,OUTPUT v-List-Select-host-code
      ) .
  end.
end procedure.
procedure userhsts_select-many :
  define input  parameter parparentproc      as widget-handle no-undo .
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-curr-host-code   as integer   no-undo .
  define output parameter p-user-select      as logical   no-undo .
  define variable v-select-host-code as integer   no-undo .
  DEFINE VARIABLE v-List-select-host-code AS CHARACTER NO-UNDO INITIAL "".
  do
  on error undo, return error return-value
  :
    run gbl/userhsts.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-curr-host-code
      ,input  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-host-code
      ,OUTPUT v-List-Select-host-code
      ) .
  end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info15, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info15, return-value, chr(10), error-status :get-message (1)).
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable filter-point as character no-undo init "Список финобязательства" .
define variable filter-point0 as character no-undo init "Фин_обязательства_" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .
define new shared variable br-handle as handle  no-undo .
define new shared variable next-prev as logical no-undo .
DEFINE NEW SHARED BUFFER buf_fin-liab FOR ub.fin-ob.
DEFINE NEW SHARED BUFFER xx-contract for x-contract .
define buffer find_code for ub.fin-ob .
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
run uf-get in this-procedure(
     input  'fin-ob-p':U
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
   if v-order-col = "" or v-order-col = ? then v-order-col = "4,5,6,7,8,9,10,11,12,13,14,15,16,17,18".
end.
FUNCTION contract-gen RETURNS CHARACTER
(input p-rec as recid )  FORWARD.
FUNCTION contract-id RETURNS CHARACTER
  ( input p-rec as recid )  FORWARD.
FUNCTION debts RETURNS DECIMAL
  ( input p-rec as recid )  FORWARD.
FUNCTION f-factur RETURNS CHARACTER
  (input p-rec as recid )  FORWARD.
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int )  FORWARD.
FUNCTION val-abbr-type RETURNS CHARACTER
  ( input p-rec as recid)  FORWARD.
DEFINE MENU POPUP-MENU-b-fact
       MENU-ITEM m_gen-1        LABEL "Генерация"
       MENU-ITEM m_gen-2        LABEL "Отказаться от генерации счета-фактуры"
       MENU-ITEM m_gen-3        LABEL "Снять признак - есть генерация счета-фактуры"
       MENU-ITEM m_gen-4        LABEL "Снять 'не опред'"
       MENU-ITEM m_sf           LABEL "Просмотр Счета-фактуры"
       .
DEFINE MENU POPUP-MENU-b-print
       MENU-ITEM m_print-1      LABEL "Финансовые обязательства"
       MENU-ITEM m_print-2      LABEL "Заявка на оплату".
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавление записи"
     BGCOLOR 8 .
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменение записи"
     BGCOLOR 8 .
DEFINE BUTTON B-close
     LABEL "&Закрыть"
     SIZE 10 BY 1 TOOLTIP "Перевод в другой статус финансовых обязательств"
     BGCOLOR 8 .
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удаление записи"
     BGCOLOR 8 .
DEFINE BUTTON b-exec-fo
     LABEL "&Генерация"
     SIZE 10 BY 1 TOOLTIP "Создание фин.обязательств"
     BGCOLOR 8 .
DEFINE BUTTON b-exec-pay
     LABEL "Плате&ж"
     SIZE 10 BY 1 TOOLTIP "Создание платежей"
     BGCOLOR 8 .
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 13 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Export
     LABEL "&Экспорт"
     SIZE 10 BY 1 TOOLTIP "Экспорт в XML"
     BGCOLOR 8 .
DEFINE BUTTON b-fact
     LABEL "С&чет-факт":L
     SIZE 10 BY 1 TOOLTIP "Счет-фактура".
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-History
     LABEL "Ис&тория"
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
DEFINE BUTTON B-PFO
     LABEL "ПФ&О"
     SIZE 10 BY 1 TOOLTIP "ПредФинОбязательства"
     BGCOLOR 8 .
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1 TOOLTIP "Печать текущего списка"
     BGCOLOR 8 .
DEFINE BUTTON B-reopen-br
     LABEL "Применит&ь"
     SIZE 10 BY 1 TOOLTIP "Сделать выборку по заданным параметрам".
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1 TOOLTIP "Фильтрация списка"
     BGCOLOR 8 .
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1 TOOLTIP "Выбор отмеченных или текущей записи"
     BGCOLOR 8 .
DEFINE BUTTON B-trn
     LABEL "Д&окум."
     SIZE 10 BY 1 TOOLTIP "Просмотр складских документов, породивших ФО"
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
DEFINE VARIABLE FILL-IN-22 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата создания"
      VIEW-AS TEXT
     SIZE 13.5 BY .67
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-24 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата платежа"
      VIEW-AS TEXT
     SIZE 12.5 BY .67
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-26 AS CHARACTER FORMAT "X(256)":U INITIAL "Задолжен."
      VIEW-AS TEXT
     SIZE 9 BY .67 TOOLTIP "Непогашеная задолженность"
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
     SIZE 12.88 BY .67
     FGCOLOR 4
     NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE p-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата фин.об."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиск по дате создания фин.об. (Поиск первой записи - <ВВОД>; поиск следующей -<CTRL-J>)"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE p-desc AS CHARACTER FORMAT "X(80)":U
     LABEL "№ договора"
     VIEW-AS FILL-IN
     SIZE 20.63 BY 1 TOOLTIP "Поиск по № договора. (Поиск первой записи - <ВВОД>; поиск следующей -<CTRL-J>)"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE r-abbr AS CHARACTER FORMAT "X(256)":U INITIAL "abbr_rub_allshift"
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE s-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 23.5 BY .58
     FONT 2 NO-UNDO.
DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(12)":U
     LABEL "№ фин.обяз"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск по номеру ФО. (Поиск первой записи - <ВВОД>; поиск следующей -<CTRL-J>)"
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
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 1.25 TOOLTIP "Параметры для выборки"
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE R-2 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 11.5 BY 1.25 TOOLTIP "Параметры для выборки"
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE R-3 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Есть", 2,
"Нет", 3
     SIZE 7 BY 2 TOOLTIP "Параметры для выборки. Непогашеная задолженность"
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 93 BY 3.5 TOOLTIP "Параметры для выборки ФО".
DEFINE VARIABLE S-tt AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE NO-DRAG SCROLLBAR-VERTICAL
     SIZE 19.5 BY 3.5 TOOLTIP "Список договоров"
     BGCOLOR 8 FGCOLOR 0 FONT 2 NO-UNDO.
DEFINE VARIABLE T-paket AS LOGICAL INITIAL no
     LABEL "П&акетный режим"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 TOOLTIP "Работа с выделенным списком финобязательств" NO-UNDO.
DEFINE new shared QUERY BR-docs FOR
      buf_fin-liab except ,
      xx-contract SCROLLING.
DEFINE BROWSE BR-docs
  QUERY BR-docs DISPLAY
     mark-string(recid( buf_fin-liab), rid-list) @ p-mark  COLUMN-LABEL '*'   FORMAT "x(1)"
     buf_fin-liab.status_    COLUMN-LABEL 'Статус'          Format "x(6)"
     buf_fin-liab.prn-doc-code    COLUMN-LABEL '№ док-та'          Format "x(10)"
     buf_fin-liab.doc-date    COLUMN-LABEL 'Создан'          format "99/99/99"
     buf_fin-liab.fact-date    COLUMN-LABEL 'Закрыт'          format "99/99/99"
     contract-id(recid( buf_fin-liab)) @ p-contr   COLUMN-LABEL 'Договор'          Format "x(16)"
     (buf_fin-liab.receiver-type + ' ' + string(buf_fin-liab.receiver-code))    COLUMN-LABEL 'Получатель'          Format "x(10)"
     (buf_fin-liab.payer-type + ' ' + string(buf_fin-liab.payer-code))    COLUMN-LABEL 'Плательщик'          Format "x(10)"
     buf_fin-liab.pay-date   COLUMN-LABEL 'Платеж'           format "99/99/99"
     val-abbr-type(recid( buf_fin-liab))  @ l-curr COLUMN-LABEL 'Вал'         Format "x(3)"
     buf_fin-liab.sum-doc   COLUMN-LABEL 'Сумма в валюте!док-та'
     buf_fin-liab.doc-code   COLUMN-LABEL 'Внутр.№'         Format "99999999"
     if buf_fin-liab.doc-type = 'при':U then 'с покупателем' else 'с поставщиком' @ p-type   COLUMN-LABEL 'Тип'          Format "x(13)"
     debts(recid (buf_fin-liab)) @ p-debts  COLUMN-LABEL 'Непогаш.задолж!(руб.)'          Format  "->>>>>>>>>>>9.99"
     (buf_fin-liab.obj-type + ' ' + string(buf_fin-liab.obj-code)) @ p-obj  COLUMN-LABEL 'Объект'   Format "x(9)"
     buf_fin-liab.receiver-name   COLUMN-LABEL 'Наименование'          Format "x(40)"
     contract-gen(recid(buf_fin-liab)) @ p-gen  COLUMN-LABEL 'Условие генерации'          Format "x(40)"
     f-factur(recid(buf_fin-liab)) @ varfactur column-label 'Счет-фактура' format "x(8)"
      enable buf_fin-liab.status_
    WITH NO-ROW-MARKERS SEPARATORS SIZE 93.75 BY 12.5.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-sel AT ROW 1 COL 14
     B-close AT ROW 1 COL 24
     B-Export AT ROW 1 COL 34
     b-fact AT ROW 1 COL 44
     B-trn AT ROW 1 COL 54
     B-parts AT ROW 1 COL 64
     B-PFO AT ROW 1 COL 74
     B-Help AT ROW 1 COL 84
     B-sch AT ROW 1 COL 84
     B-History AT ROW 1 COL 85
     B-mark AT ROW 2 COL 1
     B-add AT ROW 2 COL 4
     B-lkp AT ROW 2 COL 14
     B-chg AT ROW 2 COL 24
     B-del AT ROW 2 COL 34
     b-exec-fo AT ROW 2 COL 44
     b-exec-pay AT ROW 2 COL 64
     B-print AT ROW 2 COL 84
     S-tt AT ROW 3 COL 25 NO-LABEL
     R-1 AT ROW 3.75 COL 1 NO-LABEL
     R-2 AT ROW 3.75 COL 13.5 NO-LABEL
     v-date-doc-1 AT ROW 3.75 COL 47.5 COLON-ALIGNED
     v-date-pay-1 AT ROW 3.75 COL 60.75 COLON-ALIGNED
     R-3 AT ROW 3.75 COL 72 NO-LABEL
     v-date-doc-2 AT ROW 4.75 COL 47.5 COLON-ALIGNED
     v-date-pay-2 AT ROW 4.75 COL 60.75 COLON-ALIGNED
     B-reopen-br AT ROW 5 COL 84
     sch-code AT ROW 6.58 COL 10.87
     p-desc AT ROW 6.58 COL 37.13
     p-date AT ROW 6.58 COL 70
     BR-docs AT ROW 7.71 COL 1.5
     T-paket AT ROW 21.08 COL 73.75
     FILL-IN-20 AT ROW 3 COL 1 NO-LABEL
     FILL-IN-21 AT ROW 3 COL 13.5 NO-LABEL
     FILL-IN-22 AT ROW 3 COL 44.5 NO-LABEL
     FILL-IN-24 AT ROW 3 COL 58.75 NO-LABEL
     FILL-IN-26 AT ROW 3 COL 72 NO-LABEL
     s-name AT ROW 5.25 COL 1 NO-LABEL
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
     mark-num AT ROW 22.5 COL 74 NO-LABEL
     loc_sum-contr AT ROW 22.71 COL 44.5 COLON-ALIGNED
     v-abbr-contr AT ROW 22.71 COL 62.88 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 3 COL 1
     SPACE(1.63) SKIP(17.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Финансовые обязательства"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-fact:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-fact:HANDLE.
ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-print:HANDLE.
ASSIGN
       BR-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.
ASSIGN
       mark-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       S-tt:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  define variable g-log as logical no-undo .
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run add-proc in this-procedure .
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .
define variable v-list as character no-undo .
  assign
    cur-clmn-loc  = 1
    column-handle = BR-docs:first-column
    v-list        = column-handle:label + "#"
  .
  do while valid-handle(column-handle) :
    if cur-clmn-loc = BR-docs:num-columns then do:
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
   repeat v-i = 1 to BR-docs:num-columns :
      v-elem = entry( v-i, v-list , "#") .
      v-pos = lookup( v-elem, '*' + '#' +  'Статус' + '#' +  '№ док-та' + '#' +  'Создан' + '#' +  'Закрыт' + '#' +  'Договор' + '#' +  'Получатель' + '#' +  'Плательщик' + '#' +  'Платеж' + '#' +  'Вал' + '#' +  'Сумма в валюте!док-та' + '#' +  'Внутр.№' + '#' +  'Тип' + '#' +  'Непогаш.задолж!(руб.)' + '#' +  'Объект' + '#' +  'Наименование' + '#' +  'Условие генерации' + '#' +  'Счет-фактура' , "#") .
      v-list-new = v-list-new + string(v-pos) + "," .
   end.
   define variable v-list-str as character no-undo .
   define variable v-1 as integer   no-undo .
   v-list-str = "" .
   v-1 = num-entries(v-list-new)  .
   repeat v-i = 1 to v-1 :
      v-elem = entry(v-i , v-list-new ) .
      if int(v-elem) > 3 then
      v-list-str  = v-list-str + v-elem + "," .
   end.
   v-list-new = trim(v-list-str ,",")  +  chr(4)
              + string(decimal( buf_fin-liab.receiver-name:width in browse BR-docs)) +  chr(4)
              + string(decimal( p-gen:width                    in browse BR-docs)) +  chr(4)
              + string(decimal( buf_fin-liab.sum-doc:width     in browse BR-docs)) +  chr(4)
              + string(decimal( p-contr:width                  in browse BR-docs)) +  chr(4)
              + string(decimal( buf_fin-liab.status_:width     in browse BR-docs)) +  chr(4)  .
run uf-set in this-procedure(
    input  'fin-ob-p':U
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
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_update':U
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
if not available buf_fin-liab then return .
if  buf_fin-liab.status_ = 'факт':U then do:
    message "Финансовое обязательство в статусе " buf_fin-liab.status_ " изменять нельзя !!!"
    view-as alert-box information .
    return no-apply.
end.
define variable rr as recid no-undo .
    if available buf_fin-liab then do:
        rr = recid( buf_fin-liab ).
        p-doc-type = buf_fin-liab.doc-type .
        p-status_  = buf_fin-liab.status_  .
        run str/fi-liabi.w
           (input parParentProc ,
            input 'ИЗМЕНЕНИЕ':U ,
            input-output rr ,
            input par-host-code  ,
            input p-doc-type,
            input p-status_
            ).
        g-log =  BR-docs:refresh() .
        apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
    end.
END.
ON CHOOSE OF B-close IN FRAME Dialog-Frame
DO:
  run proc-close in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
if not available buf_fin-liab then return .
define buffer buf_del-fin-ob for ub.fin-ob .
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-recid as integer no-undo .
  define variable ii as integer no-undo .
  assign
  t-paket
  .
  if t-paket then do:
    define variable rr as integer init 0 no-undo .
    define variable v-2 as integer   no-undo .
    v-2 = num-entries (rid-list) .
    repeat ii = 1 to v-2 :
       v-recid = integer(entry(ii, rid-list)).
       find first buf_del-fin-ob no-lock where recid(buf_del-fin-ob) = v-recid no-error .
        if error-status :error then next.
        if  buf_del-fin-ob.status_ = 'факт':U then next.
        find first buf_del-fin-ob  exclusive-lock   where recid(buf_del-fin-ob) = v-recid no-error .
        if available buf_del-fin-ob then do:
          delete buf_del-fin-ob .
          rr = rr + 1.
        end.
    end.
  end.
  else do:
        find current buf_fin-liab  exclusive-lock  no-error .
        v-recid = recid ( buf_fin-liab ) .
        if available buf_fin-liab then do:
           delete buf_fin-liab  .
        end.
   end.
    define variable g#log as logical no-undo .
    define variable v-doc-rec as recid no-undo .
  br-handle = BR-docs:handle in frame Dialog-Frame .
  if valid-handle (br-handle) then do:
    g#log = br-handle:select-next-row().
    if not g#log then g#log = br-handle:select-prev-row().
    v-doc-rec = recid (buf_fin-liab) .
  end.
   run OpenBr in this-procedure (yes, no, '':U).
   apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
   reposition BR-docs to recid v-doc-rec no-error.
END.
ON CHOOSE OF b-exec-fo IN FRAME Dialog-Frame
DO:
  define variable g-log as logical no-undo .
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if p-doc-type = 'при':U then
  run str/gen-fbuy.w
  ( input parParentProc,
    input par-host-code,
    input ? ,
    input ""
    ).
else
  run str/gen-fl.w
  ( input parParentProc,
    input par-host-code,
    input ? ,
    input ""
    ).
  run OpenBr in this-procedure (yes, no, '':U).
  apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF B-Export IN FRAME Dialog-Frame
DO:
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-b-exp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
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
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      br-handle = BR-docs:handle in frame Dialog-Frame .
      next-prev = no.
      do while next-prev <> ?:
        if not available buf_fin-liab then do:
          message "Неправильный выбор документа.".
          return no-apply.
        end.
        run str/fi-liabi.w
           ( parParentProc,
           'ПРОСМОТР':U ,
           input-output rr ,
           input par-host-code  ,
           input p-doc-type,
           input p-status_
           ).
        if br-handle = ? then reposition BR-docs to recid rr no-error.
      end.
     end.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
      if available buf_fin-liab then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid28 as character no-undo .
define variable v-num-entry28 as integer   no-undo .
assign
  v-str-recid28 = trim( string( recid( buf_fin-liab ) , "->>>>>>>>>>>9":U ) )
  v-num-entry28 = lookup( v-str-recid28 , rid-list )
.
if v-num-entry28 > 0 then do:
  assign
    entry( v-num-entry28, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid28
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
            end.
    end.
    apply "entry" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF B-parts IN FRAME Dialog-Frame
DO:
    if not available buf_fin-liab then return .
    run str/fi-parts.w
      ( input parParentProc ,
        input buf_fin-liab.doc-code ,
        input par-host-code  ) .
END.
ON CHOOSE OF B-PFO IN FRAME Dialog-Frame
DO:
if available buf_fin-liab then do:
run str/fin-pob.w
(   input parParentProc ,
    input ""        ,
    input "fin-ob":u   ,
    input ?   ,
    input par-host-code,
    input p-doc-type   ,
    input p-status_    ,
    input string(buf_fin-liab.doc-code) ,
    output rid-list    ) no-error  .
  if error-status:error then return no-apply.
end.
END.
ON CHOOSE OF B-reopen-br IN FRAME Dialog-Frame
DO:
  run set-selection in this-procedure .
  run OpenBr in this-procedure (yes, no, '':U).
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
ON CHOOSE OF B-trn IN FRAME Dialog-Frame
DO:
if not available buf_fin-liab then return .
   run str/fi-trns.w
    ( input parParentProc ,
      input par-host-code,
      input buf_fin-liab.doc-code,
      input ? ,
      input "fin-ob":U
      ) .
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
  .
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
ON CHOOSE OF MENU-ITEM m_gen-1
DO:
run proc-m_gen-1 in this-procedure  no-error .
  if error-status :error then do:
     message
       error-status :get-message(1) skip
       return-value skip
       view-as alert-box error
     .
     return no-apply.
   end.
END.
ON CHOOSE OF MENU-ITEM m_gen-2
DO:
run proc-m_gen-2 in this-procedure  no-error .
  if error-status :error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_gen-3
DO:
run proc-m_gen-3 in this-procedure  no-error .
  if error-status :error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_gen-4
DO:
run proc-m_gen-4 in this-procedure  no-error .
  if error-status :error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_sf
DO:
define variable v-rid-list as character no-undo .
if not available buf_fin-liab then  return .
  run str/s-f-docs.w
    ( input parparentproc,
      input v-cntxt-host-code-obj,
      ?,
      ?,
      ?,
      "fo" ,
      buf_fin-liab.doc-type,
      buf_fin-liab.doc-code,
      "" ,
      input "in-doc",
      input-output v-rid-list
      ) no-error .
  if error-status :error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_print-1
DO:
  run print-proc in this-procedure  no-error .
END.
ON CHOOSE OF MENU-ITEM m_print-2
DO:
  if not available buf_fin-liab then  return .
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run rep/prn-zay.p ( input parParentProc
                    , input recid (buf_fin-liab)
                    , input "fo"
                    , input no
                    ).
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
  run proc-find-desc in this-procedure ( yes, input frame Dialog-Frame p-desc) no-error.
    if error-status:error then return no-apply.
END.
ON RETURN OF p-desc IN FRAME Dialog-Frame
DO:
  run proc-find-desc in this-procedure ( no, input frame Dialog-Frame p-desc) no-error.
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
  def buffer b#clients for ub.clients.
       run ref/cli-all.w ( parparentproc, input "b-sel", 'орг':U, ?, ?, ?, ?, ?, output  rid-list).
           find first b#clients where recid(b#clients) = integer(rid-list) no-lock no-error.
   if available  b#clients then do:
       hard-flt-cli-code = b#clients.obj-code.
       hard-flt-cli-type = b#clients.obj-type.
       s-name = b#clients.obj-name.
   end.
   else do:
     r-1 = 1.
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
      run str/cont-all.w
      (   input   parParentProc   ,
          input   par-host-code   ,
          input   "b-sel,b-mark"  ,
          input   'фирма':U      ,
          input   v-cli-type      ,
          input   v-cli-code      ,
          input   ?               ,
          input   ?               ,
          input   "current"       ,
          input  ( if p-doc-type = 'при':U then 'рас':U else 'при':U ) ,
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
          define variable v-3 as integer   no-undo .
          v-3 = num-entries (p-rid-list) .
          repeat ii = 1 to v-3 :
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
  run proc-find-code in this-procedure ( no, input frame Dialog-Frame sch-code) no-error.
  return no-apply.
END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure ( yes, input frame Dialog-Frame sch-code) no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF T-paket IN FRAME Dialog-Frame
DO:
  assign T-paket.
  rid-list = "" .
  g-log = br-docs:SELECT-ROW(1) no-error  .
  if error-status :get-message(1) = "" then
     g-log = br-docs:refresh()  .
  IF t-paket= TRUE THEN DO:
      ENABLE B-close
             B-del
             B-lkp when LOOKUP("b-lkp":U,  bttns) > 0
             B-mark
             with frame Dialog-Frame .
      disable
         B-add     when LOOKUP("b-add":U,  bttns) > 0
         B-chg     when LOOKUP("b-chg":U,  bttns) > 0
         B-sel     when LOOKUP("b-sel":U,  bttns) > 0
         b-exec-fo
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
         B-add     when LOOKUP("b-add":U,  bttns) > 0
         B-chg     when LOOKUP("b-chg":U,  bttns) > 0
         B-sel     when LOOKUP("b-sel":U,  bttns) > 0
         b-exec-fo when LOOKUP("b-exec-fo":U,  bttns) > 0
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
b-fact:menu-mouse = 1.
b-print:menu-mouse = 1.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  run OpenBr in this-procedure (yes, no, '':U).
    apply "VALUE-CHANGED" to BR-docs.
end.
define buffer buf_contract for ub.contract  .
define variable v-right-supp as logical no-undo .
define variable v-right-buyer as logical   no-undo .
v-right-supp = true .
v-right-buyer = true .
  case p-doc-type :
    when 'рас':U then do:
      p-doc-type-full = " c ПОСТАВЩИКАМИ ".
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    end.
    when 'при':U then do:
      p-doc-type-full = " с ПОКУПАТЕЛЯМИ ".
      hide b-pfo in frame Dialog-Frame .
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-buyer':U
    ,input  'firm':U
    ,input  par-host-code
    ,input  ''
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-right-buyer
    )  .
end.
    end.
    otherwise do:
      p-doc-type-full = " ".
    end.
  end.
if v-right-supp = false or v-right-buyer = false  then return .
def var vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_file for ub.fin-ob .
procedure current-db :
 do
 on error undo, return error return-value
 :
define input parameter  p-host-code as integer no-undo .
define input parameter  c-host-code as integer no-undo .
define output parameter ret         as logical no-undo .
define buffer current_sysconf for ub.sysconf.
define variable v-current-db as integer no-undo .
find first current_sysconf where current_sysconf.host-code = c-host-code no-lock no-error .
if error-status :error then return error .
   v-current-db = current_sysconf.firm-db-num .
   ret = true .
find first ub.sysconf where ub.sysconf.host-code = p-host-code no-lock no-error .
if not( ub.sysconf.firm-db-num = v-current-db or
        ub.sysconf.firm-db-num = 0 )
  then do:
  ret = false .
  message "Нельзя добавлять запись в  справочнике  для фирмы с не главной БД !!!" view-as alert-box information .
  return .
end.
 end.
end procedure.
procedure ver-db :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter  c-host-code as integer no-undo .
define input parameter  par-ver-db  as integer no-undo .
define input parameter  p-mess as logical no-undo .
define output parameter ret         as logical no-undo .
define buffer current_sysconf for ub.sysconf.
define variable v-current-db as integer no-undo .
find first current_sysconf where current_sysconf.host-code = c-host-code no-lock no-error .
if error-status :error then return error .
   v-current-db = current_sysconf.firm-db-num .
   ret = true .
if not( par-ver-db = v-current-db or
        par-ver-db = 0 )
  then do:
  ret = false .
  if p-mess = true then message "База , на которой мы работаем не является главной базой данных текущей фирмы!!!" view-as alert-box information .
  return .
end.
 end.
end procedure.
procedure fin-ob-code :
 do
 on error undo, return error return-value
 :
  define input  parameter p-db-num as integer no-undo .
  define output parameter p-fin-ob-code  as character no-undo .
  if p-db-num = 0 then
      p-fin-ob-code = string( next-value(s-fin-ob, ub)) .
      else
      p-fin-ob-code = string( next-value(s-fin-ob, ub)) + "-" + string(p-db-num).
 end.
end procedure.
procedure create-fin-liab :
 do
 on error undo, return error return-value
 :
define input parameter p-ver as logical no-undo .
define input parameter p-doc-code            like ub.fin-ob.doc-code             no-undo .
define input parameter p-doc-date            like ub.fin-ob.doc-date             no-undo .
define input parameter p-doc-type            like ub.fin-ob.doc-type             no-undo .
define input parameter p-payer-name            like ub.fin-ob.payer-name             no-undo .
define input parameter p-receiver-name            like ub.fin-ob.receiver-name             no-undo .
define input parameter p-curr-code           like ub.fin-ob.curr-code            no-undo .
define input parameter p-sum-doc             like ub.fin-ob.sum-doc              no-undo .
define input parameter p-user-db-num-doc     like ub.fin-ob.user-db-num-doc      no-undo .
define input parameter p-user-name-doc       like ub.fin-ob.user-name-doc        no-undo .
define input parameter p-base-rate           like ub.fin-ob.base-rate            no-undo .
define input parameter p-base-scale          like ub.fin-ob.base-scale           no-undo .
define input parameter p-receiver-code            like ub.fin-ob.receiver-code             no-undo .
define input parameter p-receiver-type            like ub.fin-ob.receiver-type             no-undo .
define input parameter p-contract-code       like ub.fin-ob.contract-code        no-undo .
define input parameter p-exch-rate           like ub.fin-ob.exch-rate            no-undo .
define input parameter p-exch-scale          like ub.fin-ob.exch-scale           no-undo .
define input parameter p-contract-curr           like ub.fin-ob.contract-curr            no-undo .
define input parameter p-contract-rate           like ub.fin-ob.contract-rate            no-undo .
define input parameter p-contract-scale          like ub.fin-ob.contract-scale           no-undo .
define input parameter p-fact-date           like ub.fin-ob.fact-date            no-undo .
define input parameter p-fact-order          like ub.fin-ob.fact-order           no-undo .
define input parameter p-host-code           like ub.fin-ob.host-code            no-undo .
define input parameter p-payer-code          like ub.fin-ob.payer-code           no-undo .
define input parameter p-payer-type          like ub.fin-ob.payer-type           no-undo .
define input parameter p-pay-date            like ub.fin-ob.pay-date             no-undo .
define input parameter p-prn-doc-code        like ub.fin-ob.prn-doc-code         no-undo .
define input parameter p-status_             like ub.fin-ob.status_              no-undo .
define input parameter p-sum-base-orig       like ub.fin-ob.sum-base-orig        no-undo .
define input parameter p-sum-base            like ub.fin-ob.sum-base             no-undo .
define input parameter p-sum-doc-orig        like ub.fin-ob.sum-doc-orig         no-undo .
define input parameter p-sum-rubl-orig       like ub.fin-ob.sum-rubl-orig        no-undo .
define input parameter p-sum-rubl            like ub.fin-ob.sum-rubl             no-undo .
define input parameter p-sum-contract        like ub.fin-ob.sum-contract         no-undo .
define input parameter p-trn-doc-code        like ub.fin-ob.trn-doc-code         no-undo .
define input parameter p-user-db-num-fact    like ub.fin-ob.user-db-num-fact     no-undo .
define input parameter p-user-db-num-pay     like ub.fin-ob.user-db-num-pay     no-undo .
define input parameter p-user-name-fact      like ub.fin-ob.user-name-fact       no-undo .
define input parameter p-user-name-pay       like ub.fin-ob.user-name-pay       no-undo .
define input parameter p-in-type             like ub.fin-ob.in-type              no-undo .
define input parameter p-sum-tax-base         like ub.fin-ob.sum-tax-base     no-undo .
define input parameter p-sum-tax-doc          like ub.fin-ob.sum-tax-doc      no-undo .
define input parameter p-sum-tax-rubl         like ub.fin-ob.sum-tax-rubl     no-undo .
define input parameter p-sum-tax-contract     like ub.fin-ob.sum-tax-contract no-undo .
define input parameter p-ps                   like ub.fin-ob.ps               no-undo .
define output parameter p-rec-id as recid no-undo .
if p-ver then do:
    find first  buf_file no-lock  where buf_file.host-code = p-host-code and
                                        buf_file.doc-code  = p-doc-code no-error .
    if available buf_file then return error .
end.
define variable p-ret as logical no-undo .
run current-db in this-procedure (
    input p-host-code,
    input p-host-code,
    output p-ret ) .
 if p-ret = no then return.
p-rec-id = ? .
 create ub.fin-ob.
 assign
   ub.fin-ob.host-code     =     p-host-code
   ub.fin-ob.doc-code      =     p-doc-code
   ub.fin-ob.status_       =     p-status_
   ub.fin-ob.doc-date      =     p-doc-date
   ub.fin-ob.doc-type      =     p-doc-type
   ub.fin-ob.payer-name    =     p-payer-name
   ub.fin-ob.receiver-name =     p-receiver-name
   ub.fin-ob.curr-code     =     p-curr-code
   ub.fin-ob.user-db-num-doc =   p-user-db-num-doc
   ub.fin-ob.user-name-doc   =   p-user-name-doc
   ub.fin-ob.base-rate     =     p-base-rate
   ub.fin-ob.base-scale    =     p-base-scale
   ub.fin-ob.receiver-code =     p-receiver-code
   ub.fin-ob.receiver-type =     p-receiver-type
   ub.fin-ob.contract-code =     p-contract-code
   ub.fin-ob.exch-rate     =     p-exch-rate
   ub.fin-ob.exch-scale    =     p-exch-scale
   ub.fin-ob.contract-curr =     p-contract-curr
   ub.fin-ob.contract-rate =     p-contract-rate
   ub.fin-ob.contract-scale =    p-contract-scale
   ub.fin-ob.fact-date     =     p-fact-date
   ub.fin-ob.fact-order    =     p-fact-order
   ub.fin-ob.host-code     =     p-host-code
   ub.fin-ob.payer-code    =     p-payer-code
   ub.fin-ob.payer-type    =     p-payer-type
   ub.fin-ob.pay-date      =     p-pay-date
   ub.fin-ob.prn-doc-code  =     p-prn-doc-code
   ub.fin-ob.status_       =     p-status_
   ub.fin-ob.sum-doc       =     p-sum-doc
   ub.fin-ob.sum-base      =     p-sum-base
   ub.fin-ob.sum-contract  =     p-sum-contract
   ub.fin-ob.sum-rubl      =     p-sum-rubl
   ub.fin-ob.sum-tax-doc   =     p-sum-tax-doc
   ub.fin-ob.sum-tax-base  =     p-sum-tax-base
   ub.fin-ob.sum-tax-contract =  p-sum-tax-contract
   ub.fin-ob.sum-tax-rubl  =     p-sum-tax-rubl
   ub.fin-ob.sum-doc-orig  =     p-sum-doc-orig
   ub.fin-ob.sum-rubl-orig =     p-sum-rubl-orig
   ub.fin-ob.sum-base-orig =     p-sum-base-orig
   ub.fin-ob.trn-doc-code  =     p-trn-doc-code
   ub.fin-ob.user-db-num-fact =  p-user-db-num-fact
   ub.fin-ob.user-db-num-pay  =  p-user-db-num-pay
   ub.fin-ob.user-name-fact   =  p-user-name-fact
   ub.fin-ob.user-name-pay    =  p-user-name-pay
   ub.fin-ob.in-type          =  p-in-type
   ub.fin-ob.ps               =  p-PS
  no-error .
  if error-status :error then do:
      message vss-include-info34 skip
              error-status :get-message(1)
              view-as alert-box error .
      return error .
  end.
  if ub.fin-ob.status_ = 'факт':U then
    run str/calc-bal.p (input "finob", input yes, input ub.fin-ob.doc-type, input ub.fin-ob.host-code, input ub.fin-ob.contract-code, input ub.fin-ob.sum-contract, input ub.fin-ob.sum-rubl, input ub.fin-ob.sum-base) .
  p-rec-id = recid(fin-ob) .
 end.
end procedure.
procedure create-fin-ob-before :
 do
 on error undo, return error return-value
 :
define input parameter p-ver as logical no-undo .
define input parameter p-doc-id              like ub.fin-ob-before.before-code             no-undo .
define input parameter p-doc-code            like ub.fin-ob.doc-code             no-undo .
define input parameter p-doc-date            like ub.fin-ob.doc-date             no-undo .
define input parameter p-doc-type            like ub.fin-ob.doc-type             no-undo .
define input parameter p-payer-name            like ub.fin-ob.payer-name             no-undo .
define input parameter p-receiver-name            like ub.fin-ob.receiver-name             no-undo .
define input parameter p-curr-code           like ub.fin-ob.curr-code            no-undo .
define input parameter p-sum-doc             like ub.fin-ob.sum-doc              no-undo .
define input parameter p-user-db-num-doc     like ub.fin-ob.user-db-num-doc      no-undo .
define input parameter p-user-name-doc       like ub.fin-ob.user-name-doc        no-undo .
define input parameter p-base-rate           like ub.fin-ob.base-rate            no-undo .
define input parameter p-base-scale          like ub.fin-ob.base-scale           no-undo .
define input parameter p-receiver-code            like ub.fin-ob.receiver-code             no-undo .
define input parameter p-receiver-type            like ub.fin-ob.receiver-type             no-undo .
define input parameter p-contract-code       like ub.fin-ob.contract-code        no-undo .
define input parameter p-exch-rate           like ub.fin-ob.exch-rate            no-undo .
define input parameter p-exch-scale          like ub.fin-ob.exch-scale           no-undo .
define input parameter p-contract-curr           like ub.fin-ob.contract-curr            no-undo .
define input parameter p-contract-rate           like ub.fin-ob.contract-rate            no-undo .
define input parameter p-contract-scale          like ub.fin-ob.contract-scale           no-undo .
define input parameter p-fact-date           like ub.fin-ob.fact-date            no-undo .
define input parameter p-fact-order          like ub.fin-ob.fact-order           no-undo .
define input parameter p-host-code           like ub.fin-ob.host-code            no-undo .
define input parameter p-payer-code          like ub.fin-ob.payer-code           no-undo .
define input parameter p-payer-type          like ub.fin-ob.payer-type           no-undo .
define input parameter p-pay-date            like ub.fin-ob.pay-date             no-undo .
define input parameter p-prn-doc-code        like ub.fin-ob.prn-doc-code         no-undo .
define input parameter p-status_             like ub.fin-ob.status_              no-undo .
define input parameter p-sum-base-orig       like ub.fin-ob.sum-base-orig        no-undo .
define input parameter p-sum-base            like ub.fin-ob.sum-base             no-undo .
define input parameter p-sum-doc-orig        like ub.fin-ob.sum-doc-orig         no-undo .
define input parameter p-sum-rubl-orig       like ub.fin-ob.sum-rubl-orig        no-undo .
define input parameter p-sum-rubl            like ub.fin-ob.sum-rubl             no-undo .
define input parameter p-sum-contract        like ub.fin-ob.sum-contract         no-undo .
define input parameter p-trn-doc-code        like ub.fin-ob.trn-doc-code         no-undo .
define input parameter p-trn-doc-code-orig   like ub.fin-ob.trn-doc-code         no-undo .
define input parameter p-user-db-num-fact    like ub.fin-ob.user-db-num-fact     no-undo .
define input parameter p-user-db-num-pay     like ub.fin-ob.user-db-num-pay     no-undo .
define input parameter p-user-name-fact      like ub.fin-ob.user-name-fact       no-undo .
define input parameter p-user-name-pay       like ub.fin-ob.user-name-pay       no-undo .
define input parameter p-in-type             like ub.fin-ob.in-type              no-undo .
define input parameter p-sum-tax-base         like ub.fin-ob.sum-tax-base     no-undo .
define input parameter p-sum-tax-doc          like ub.fin-ob.sum-tax-doc      no-undo .
define input parameter p-sum-tax-rubl         like ub.fin-ob.sum-tax-rubl     no-undo .
define input parameter p-sum-tax-contract     like ub.fin-ob.sum-tax-contract no-undo .
define input parameter p-ps                   like ub.fin-ob.ps               no-undo .
define output parameter p-rec-id as recid no-undo .
define buffer buf_file for ub.fin-ob-before .
if p-ver then do:
    find first  buf_file no-lock  where buf_file.host-code = p-host-code and
                                        buf_file.doc-code  = p-doc-code  and
                                        buf_file.before-code =  p-doc-id
                                        no-error .
    if available buf_file then return error .
end.
define variable p-ret as logical no-undo .
run current-db in this-procedure  (
    input p-host-code,
    input p-host-code,
    output p-ret ) .
 if p-ret = no then return.
p-rec-id = ? .
 create ub.fin-ob-before.
 assign
   ub.fin-ob-before.before-code   =  p-doc-id
   ub.fin-ob-before.host-code     =     p-host-code
   ub.fin-ob-before.doc-code      =     p-doc-code
   ub.fin-ob-before.status_       =     p-status_
   ub.fin-ob-before.doc-date      =     p-doc-date
   ub.fin-ob-before.doc-type      =     p-doc-type
   ub.fin-ob-before.payer-name    =     p-payer-name
   ub.fin-ob-before.receiver-name =     p-receiver-name
   ub.fin-ob-before.curr-code     =     p-curr-code
   ub.fin-ob-before.user-db-num-doc =   p-user-db-num-doc
   ub.fin-ob-before.user-name-doc   =   p-user-name-doc
   ub.fin-ob-before.base-rate     =     p-base-rate
   ub.fin-ob-before.base-scale    =     p-base-scale
   ub.fin-ob-before.receiver-code =     p-receiver-code
   ub.fin-ob-before.receiver-type =     p-receiver-type
   ub.fin-ob-before.contract-code =     p-contract-code
   ub.fin-ob-before.exch-rate     =     p-exch-rate
   ub.fin-ob-before.exch-scale    =     p-exch-scale
   ub.fin-ob-before.contract-curr =     p-contract-curr
   ub.fin-ob-before.contract-rate =     p-contract-rate
   ub.fin-ob-before.contract-scale =    p-contract-scale
   ub.fin-ob-before.fact-date     =     p-fact-date
   ub.fin-ob-before.fact-order    =     p-fact-order
   ub.fin-ob-before.host-code     =     p-host-code
   ub.fin-ob-before.payer-code    =     p-payer-code
   ub.fin-ob-before.payer-type    =     p-payer-type
   ub.fin-ob-before.pay-date      =     p-pay-date
   ub.fin-ob-before.prn-doc-code  =     p-prn-doc-code
   ub.fin-ob-before.status_       =     p-status_
   ub.fin-ob-before.sum-doc       =     p-sum-doc
   ub.fin-ob-before.sum-base      =     p-sum-base
   ub.fin-ob-before.sum-contract  =     p-sum-contract
   ub.fin-ob-before.sum-rubl      =     p-sum-rubl
   ub.fin-ob-before.sum-tax-doc   =     p-sum-tax-doc
   ub.fin-ob-before.sum-tax-base  =     p-sum-tax-base
   ub.fin-ob-before.sum-tax-contract =  p-sum-tax-contract
   ub.fin-ob-before.sum-tax-rubl  =     p-sum-tax-rubl
   ub.fin-ob-before.sum-doc-orig  =     p-sum-doc-orig
   ub.fin-ob-before.sum-rubl-orig =     p-sum-rubl-orig
   ub.fin-ob-before.sum-base-orig =     p-sum-base-orig
   ub.fin-ob-before.trn-doc-code  =     p-trn-doc-code
   ub.fin-ob-before.trn-doc-code-orig  =     p-trn-doc-code-orig
   ub.fin-ob-before.user-db-num-fact =  p-user-db-num-fact
   ub.fin-ob-before.user-db-num-pay  =  p-user-db-num-pay
   ub.fin-ob-before.user-name-fact   =  p-user-name-fact
   ub.fin-ob-before.user-name-pay    =  p-user-name-pay
   ub.fin-ob-before.in-type          =  p-in-type
   ub.fin-ob-before.ps               =  p-ps
  no-error .
  if error-status :error then do:
      message vss-include-info34 skip
              error-status :get-message(1)
              view-as alert-box error .
      return error .
  end.
  p-rec-id = recid(fin-ob-before) .
 end.
end procedure.
procedure make-tax :
 do
 on error undo, return error return-value
 :
define input parameter p-doc-code  like ub.fin-ob.doc-code no-undo .
define input parameter p-host-code as integer no-undo .
define buffer buf_fin-gds-part for  ub.fin-gds-part .
define buffer buf_fin-ob-tax   for  ub.fin-ob-tax .
define buffer buf_fin-ob       for  ub.fin-ob     .
define variable v-line              as integer no-undo .
define variable v-sum               as decimal no-undo .
define variable v-sum-rubl          as decimal no-undo .
define variable v-sum-base          as decimal no-undo .
define variable v-sum-contract      as decimal no-undo .
define variable v-sum-slt           as decimal no-undo .
define variable v-sum-rubl-slt      as decimal no-undo .
define variable v-sum-base-slt      as decimal no-undo .
define variable v-sum-contract-slt  as decimal no-undo .
define variable v-sum-vat           as decimal no-undo .
define variable v-sum-rubl-vat      as decimal no-undo .
define variable v-sum-base-vat      as decimal no-undo .
define variable v-sum-contract-vat  as decimal no-undo .
define variable v-tax-sum           as decimal no-undo .
define variable v-tax-sum-rubl      as decimal no-undo .
define variable v-tax-sum-base      as decimal no-undo .
define variable v-tax-sum-contr     as decimal no-undo .
define variable v-tax-sum-doc       as decimal no-undo .
define variable var-doc             as decimal no-undo .
define variable var-doc-slt         as decimal no-undo .
define variable var-doc-vat         as decimal no-undo .
define variable v-basecode as integer no-undo .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-basecode
  )  .
for each buf_fin-ob  exclusive-lock  where  buf_fin-ob.host-code = p-host-code and
                                            buf_fin-ob.doc-code  = p-doc-code
                                            on error undo, return error :
   assign
    v-tax-sum-rubl  = 0
    v-tax-sum-base  = 0
    v-tax-sum-contr = 0
    v-tax-sum-doc   = 0
    v-sum           = 0
    v-sum-rubl      = 0
    v-sum-base      = 0
    v-sum-contract  = 0
    v-sum-vat       = 0
    v-sum-rubl-vat  = 0
    v-sum-base-vat  = 0
    v-sum-contract-vat  = 0
    v-sum-slt           = 0
    v-sum-rubl-slt      = 0
    v-sum-base-slt      = 0
    v-sum-contract-slt  = 0
    v-line = 0
    .
    for each buf_fin-gds-part no-lock where
             buf_fin-gds-part.host-code   = buf_fin-ob.host-code and
             buf_fin-gds-part.fin-ob-code = buf_fin-ob.doc-code
             break  by buf_fin-gds-part.SLT-pc
                    by buf_fin-gds-part.vat-pc
             on error undo, return error :
              case buf_fin-ob.curr-code:
                when 0 then do :
                assign
                var-doc      =  buf_fin-gds-part.sum-rubl
                var-doc-slt  =  buf_fin-gds-part.slt-rubl
                var-doc-vat  =  buf_fin-gds-part.vat-rubl
                .
                end.
                when v-basecode then do :
                assign
                var-doc      =  buf_fin-gds-part.sum-base
                var-doc-slt  =  buf_fin-gds-part.slt-base
                var-doc-vat  =  buf_fin-gds-part.vat-base
                .
                end.
                when buf_fin-ob.contract-curr then do :
                assign
                var-doc      =  buf_fin-gds-part.sum-contract
                var-doc-slt  =  buf_fin-gds-part.slt-contract
                var-doc-vat  =  buf_fin-gds-part.vat-contract
                .
                end.
              end case.
             assign
               v-sum           = v-sum          + var-doc
               v-sum-rubl      = v-sum-rubl     + buf_fin-gds-part.sum-rubl
               v-sum-base      = v-sum-base     + buf_fin-gds-part.sum-base
               v-sum-contract  = v-sum-contract + buf_fin-gds-part.sum-contract
               v-sum-slt           = v-sum-slt          + var-doc-slt
               v-sum-rubl-slt      = v-sum-rubl-slt     + buf_fin-gds-part.slt-rubl
               v-sum-base-slt      = v-sum-base-slt     + buf_fin-gds-part.slt-base
               v-sum-contract-slt  = v-sum-contract-slt + buf_fin-gds-part.slt-contract
               v-sum-vat           = v-sum-vat          + var-doc-vat
               v-sum-rubl-vat      = v-sum-rubl-vat     + buf_fin-gds-part.vat-rubl
               v-sum-base-vat      = v-sum-base-vat     + buf_fin-gds-part.vat-base
               v-sum-contract-vat  = v-sum-contract-vat + buf_fin-gds-part.vat-contract
             .
             if last-of(buf_fin-gds-part.vat-pc) then do:
                v-line = v-line + 1.
                create buf_fin-ob-tax.
                assign
                    buf_fin-ob-tax.doc-code           = buf_fin-ob.doc-code
                    buf_fin-ob-tax.host-code          = buf_fin-ob.host-code
                    buf_fin-ob-tax.line-num           = v-line
                    buf_fin-ob-tax.slt-pc             = buf_fin-gds-part.slt-pc
                    buf_fin-ob-tax.vat-pc             = buf_fin-gds-part.vat-pc
                    buf_fin-ob-tax.with-slt           = true
                    buf_fin-ob-tax.with-vat           = true
                    buf_fin-ob-tax.sum-line-rubl      = v-sum-rubl
                    buf_fin-ob-tax.sum-slt-line-rubl  = v-sum-rubl-slt
                    buf_fin-ob-tax.sum-vat-line-rubl  = v-sum-rubl-vat
                    buf_fin-ob-tax.sum-line-base       = v-sum-base
                    buf_fin-ob-tax.sum-line-contr      = v-sum-contract
                    buf_fin-ob-tax.sum-line-doc        = v-sum
                    buf_fin-ob-tax.sum-slt-line-base    = v-sum-base-slt
                    buf_fin-ob-tax.sum-slt-line-contr   = v-sum-contract-slt
                    buf_fin-ob-tax.sum-slt-line-doc     = v-sum-slt
                    buf_fin-ob-tax.sum-vat-line-base    = v-sum-base-vat
                    buf_fin-ob-tax.sum-vat-line-contr   = v-sum-contract-vat
                    buf_fin-ob-tax.sum-vat-line-doc     = v-sum-vat
                    .
                    assign
                        buf_fin-ob-tax.with-slt-orig            = buf_fin-ob-tax.with-slt
                        buf_fin-ob-tax.slt-pc-orig              = buf_fin-ob-tax.slt-pc
                        buf_fin-ob-tax.vat-pc-orig              = buf_fin-ob-tax.vat-pc
                        buf_fin-ob-tax.sum-slt-line-doc-orig    = buf_fin-ob-tax.sum-slt-line-doc
                        buf_fin-ob-tax.sum-slt-line-base-orig   = buf_fin-ob-tax.sum-slt-line-base
                        buf_fin-ob-tax.sum-slt-line-contr-orig  = buf_fin-ob-tax.sum-slt-line-contr
                        buf_fin-ob-tax.sum-slt-line-rubl-orig   = buf_fin-ob-tax.sum-slt-line-rubl
                        buf_fin-ob-tax.with-vat-orig            = buf_fin-ob-tax.with-vat
                        buf_fin-ob-tax.sum-vat-line-doc-orig    = buf_fin-ob-tax.sum-vat-line-doc
                        buf_fin-ob-tax.sum-vat-line-base-orig   = buf_fin-ob-tax.sum-vat-line-base
                        buf_fin-ob-tax.sum-vat-line-contr-orig  = buf_fin-ob-tax.sum-vat-line-contr
                        buf_fin-ob-tax.sum-vat-line-rubl-orig   = buf_fin-ob-tax.sum-vat-line-rubl
                    .
                    assign
                       v-tax-sum-rubl   = v-tax-sum-rubl  + v-sum-rubl-slt  + v-sum-rubl-vat
                       v-tax-sum-base   = v-tax-sum-base  + v-sum-base-slt  + v-sum-base-vat
                       v-tax-sum-contr  = v-tax-sum-contr + v-sum-contract-slt + v-sum-contract-vat
                       v-tax-sum-doc    = v-tax-sum-doc   + v-sum-slt   + v-sum-vat
                    .
                    assign
                    v-sum  = 0
                    v-sum-rubl      = 0
                    v-sum-base      = 0
                    v-sum-contract  = 0
                    v-sum-slt           =0
                    v-sum-rubl-slt      =0
                    v-sum-base-slt      =0
                    v-sum-contract-slt  =0
                    v-sum-vat           =0
                    v-sum-rubl-vat      =0
                    v-sum-base-vat      =0
                    v-sum-contract-vat  =0
                    .
              end.
    end.
    assign
      buf_fin-ob.sum-tax-doc      = v-tax-sum-doc
      buf_fin-ob.sum-tax-rubl     = v-tax-sum-rubl
      buf_fin-ob.sum-tax-base     = v-tax-sum-base
      buf_fin-ob.sum-tax-contract = v-tax-sum-contr
      buf_fin-ob.base-rate        = if buf_fin-ob.base-rate <> 0 then buf_fin-ob.base-rate else round ( buf_fin-ob.sum-rubl / buf_fin-ob.sum-base , 4)
      buf_fin-ob.exch-rate        = round ( buf_fin-ob.sum-rubl / buf_fin-ob.sum-doc  , 4)
      buf_fin-ob.contract-rate    = round ( buf_fin-ob.sum-rubl / buf_fin-ob.sum-contract , 4)
      buf_fin-ob.base-scale       = 1
      buf_fin-ob.exch-scale       = 1
      buf_fin-ob.contract-scale   = 1
    .
    assign
    v-tax-sum-rubl  = 0
    v-tax-sum-base  = 0
    v-tax-sum-contr = 0
    v-tax-sum-doc   = 0
    v-sum-vat          = 0
    v-sum-rubl-vat     = 0
    v-sum-base-vat     = 0
    v-sum-contract-vat    = 0
    v-sum-slt          = 0
    v-sum-rubl-slt     = 0
    v-sum-base-slt     = 0
    v-sum-contract-slt    = 0
    .
end.
 end.
end procedure.
procedure update-fin-ob_obj :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-code  like ub.fin-ob.doc-code no-undo .
define input parameter p-host-code as integer no-undo .
define buffer buf_fin-gds-part for  ub.fin-gds-part .
define buffer buf_fin-ob       for  ub.fin-ob     .
define variable v-obj-code as integer no-undo init 0 .
define variable v-obj-type as character no-undo init "" .
define variable var-fin-calc as integer no-undo .
find first ub.sysconf no-lock where ub.sysconf.host-code = p-host-code no-error .
var-fin-calc = ub.sysconf.fin-calc   .
if var-fin-calc = 0 then return.
for each buf_fin-ob  exclusive-lock  where  buf_fin-ob.host-code = p-host-code and
                                            buf_fin-ob.doc-code = p-doc-code
                                            on error undo, return error :
    for each buf_fin-gds-part no-lock where
             buf_fin-gds-part.host-code   = buf_fin-ob.host-code and
             buf_fin-gds-part.fin-ob-code = buf_fin-ob.doc-code
             on error undo, return error :
          assign
             v-obj-code  =  buf_fin-gds-part.obj-code
             v-obj-type  =  buf_fin-gds-part.obj-type
             .
           leave.
    end.
    assign
      buf_fin-ob.obj-code  =   v-obj-code
      buf_fin-ob.obj-type  =   v-obj-type
    .
end.
 end.
end procedure.
procedure make-tax-rubl :
 do
 on error undo, return error return-value
 :
define input parameter p-doc-code like ub.fin-ob.doc-code no-undo .
define input parameter p-host-code as integer no-undo .
define buffer buf_fin-gds-part for  ub.fin-gds-part .
define buffer buf_fin-ob-tax   for  ub.fin-ob-tax .
define buffer buf_fin-ob       for  ub.fin-ob     .
define variable v-line    as integer no-undo .
define variable v-sum         as decimal no-undo .
define variable v-tax-sum       as decimal no-undo .
define variable v-tax-sum-rubl  as decimal no-undo .
define variable v-tax-sum-base  as decimal no-undo .
define variable v-tax-sum-contr as decimal no-undo .
define variable v-tax-sum-doc   as decimal no-undo .
for each buf_fin-ob  exclusive-lock  where  buf_fin-ob.host-code = p-host-code and
                                            buf_fin-ob.doc-code = p-doc-code
                                            on error undo, return error :
   assign
    v-tax-sum-rubl = 0
    v-tax-sum-base = 0
    v-tax-sum-contr = 0
    v-tax-sum-doc  = 0
    v-sum          = 0
    v-line = 0
    .
    for each buf_fin-gds-part no-lock where
             buf_fin-gds-part.host-code   = buf_fin-ob.host-code and
             buf_fin-gds-part.fin-ob-code = buf_fin-ob.doc-code
             break  by buf_fin-gds-part.SLT-pc
                    by buf_fin-gds-part.vat-pc
             on error undo, return error :
             assign
               v-sum       = v-sum + buf_fin-gds-part.sum-rubl
             .
             if last-of(buf_fin-gds-part.vat-pc) then do:
                v-line = v-line + 1.
                create buf_fin-ob-tax.
                assign
                    buf_fin-ob-tax.doc-code           = buf_fin-ob.doc-code
                    buf_fin-ob-tax.host-code          = buf_fin-ob.host-code
                    buf_fin-ob-tax.line-num           = v-line
                    buf_fin-ob-tax.slt-pc             = buf_fin-gds-part.slt-pc
                    buf_fin-ob-tax.vat-pc             = buf_fin-gds-part.vat-pc
                    buf_fin-ob-tax.with-slt           = true
                    buf_fin-ob-tax.with-vat           = true
                    buf_fin-ob-tax.sum-line-rubl      = v-sum
                    buf_fin-ob-tax.sum-slt-line-rubl  = buf_fin-ob-tax.slt-PC *  buf_fin-ob-tax.sum-line-rubl  / ( 100 + buf_fin-ob-tax.slt-PC )
                    buf_fin-ob-tax.sum-vat-line-rubl  = buf_fin-ob-tax.vat-PC * (( buf_fin-ob-tax.sum-line-rubl  - buf_fin-ob-tax.sum-slt-line-rubl  ) / ( 100  + buf_fin-ob-tax.vat-PC))
                    buf_fin-ob-tax.sum-line-base       = ( buf_fin-ob.base-scale     / buf_fin-ob.base-rate)     * buf_fin-ob-tax.sum-line-rubl
                    buf_fin-ob-tax.sum-line-doc        = ( buf_fin-ob.exch-scale     / buf_fin-ob.exch-rate)     * buf_fin-ob-tax.sum-line-rubl
                    buf_fin-ob-tax.sum-line-contr      = ( buf_fin-ob.contract-scale / buf_fin-ob.contract-rate) * buf_fin-ob-tax.sum-line-rubl
                    buf_fin-ob-tax.sum-slt-line-base    = ( buf_fin-ob.base-scale     / buf_fin-ob.base-rate)     * buf_fin-ob-tax.sum-slt-line-rubl
                    buf_fin-ob-tax.sum-slt-line-doc     = ( buf_fin-ob.exch-scale     / buf_fin-ob.exch-rate)     * buf_fin-ob-tax.sum-slt-line-rubl
                    buf_fin-ob-tax.sum-slt-line-contr   = ( buf_fin-ob.contract-scale / buf_fin-ob.contract-rate) * buf_fin-ob-tax.sum-slt-line-rubl
                    buf_fin-ob-tax.sum-vat-line-base    = ( buf_fin-ob.base-scale     / buf_fin-ob.base-rate)     * buf_fin-ob-tax.sum-vat-line-rubl
                    buf_fin-ob-tax.sum-vat-line-doc     = ( buf_fin-ob.exch-scale     / buf_fin-ob.exch-rate)     * buf_fin-ob-tax.sum-vat-line-rubl
                    buf_fin-ob-tax.sum-vat-line-contr   = ( buf_fin-ob.contract-scale / buf_fin-ob.contract-rate) * buf_fin-ob-tax.sum-vat-line-rubl
                    .
                    assign
                        buf_fin-ob-tax.with-slt-orig            = buf_fin-ob-tax.with-slt
                        buf_fin-ob-tax.slt-pc-orig              = buf_fin-ob-tax.slt-pc
                        buf_fin-ob-tax.vat-pc-orig              = buf_fin-ob-tax.vat-pc
                        buf_fin-ob-tax.sum-slt-line-doc-orig    = buf_fin-ob-tax.sum-slt-line-doc
                        buf_fin-ob-tax.sum-slt-line-base-orig   = buf_fin-ob-tax.sum-slt-line-base
                        buf_fin-ob-tax.sum-slt-line-contr-orig  = buf_fin-ob-tax.sum-slt-line-contr
                        buf_fin-ob-tax.sum-slt-line-rubl-orig   = buf_fin-ob-tax.sum-slt-line-rubl
                        buf_fin-ob-tax.with-vat-orig            = buf_fin-ob-tax.with-vat
                        buf_fin-ob-tax.sum-vat-line-doc-orig    = buf_fin-ob-tax.sum-vat-line-doc
                        buf_fin-ob-tax.sum-vat-line-base-orig   = buf_fin-ob-tax.sum-vat-line-base
                        buf_fin-ob-tax.sum-vat-line-contr-orig  = buf_fin-ob-tax.sum-vat-line-contr
                        buf_fin-ob-tax.sum-vat-line-rubl-orig   = buf_fin-ob-tax.sum-vat-line-rubl
                    .
                    assign
                       v-tax-sum-rubl   = v-tax-sum-rubl  + buf_fin-ob-tax.sum-slt-line-rubl  + buf_fin-ob-tax.sum-vat-line-rubl
                       v-tax-sum-base   = v-tax-sum-base  + buf_fin-ob-tax.sum-slt-line-base  + buf_fin-ob-tax.sum-vat-line-base
                       v-tax-sum-contr  = v-tax-sum-contr + buf_fin-ob-tax.sum-slt-line-contr + buf_fin-ob-tax.sum-vat-line-contr
                       v-tax-sum-doc    = v-tax-sum-doc   + buf_fin-ob-tax.sum-slt-line-doc   + buf_fin-ob-tax.sum-vat-line-doc
                    .
                    v-sum  = 0 .
              end.
    end.
    buf_fin-ob.sum-tax-doc   = v-tax-sum-doc   .
    buf_fin-ob.sum-tax-rubl  = v-tax-sum-rubl  .
    buf_fin-ob.sum-tax-base  = v-tax-sum-base  .
    buf_fin-ob.sum-tax-contract = v-tax-sum-contr .
    v-tax-sum-rubl  = 0 .
    v-tax-sum-base  = 0 .
    v-tax-sum-contr = 0 .
    v-tax-sum-doc   = 0 .
end.
 end.
end procedure.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-docs :SET-REPOSITIONED-ROW(8, "CONDITIONAL") .
end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date38
    MENU-ITEM m-ed-date38-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date38-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date38-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date38-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if p-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      p-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date38 :HANDLE
      p-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle38 as handle no-undo .
  assign
    v-label-handle38 = p-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle38)
  then do:
    if v-label-handle38 :tooltip = ""
    or v-label-handle38 :tooltip = ?
    then do:
      assign
        v-label-handle38 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date38-1 in menu m-ed-date38 DO:
    apply "ctrl-b":U to p-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date38-2 in menu m-ed-date38 DO:
    apply "ctrl-d":U to p-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date38-3 in menu m-ed-date38 DO:
    apply "ctrl-e":U to p-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date38-4 in menu m-ed-date38 DO:
    apply "ctrl-f":U to p-date in frame Dialog-Frame .
  END.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date40
    MENU-ITEM m-ed-date40-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date40-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date40-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date40-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date-doc-1 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date-doc-1 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date40 :HANDLE
      v-date-doc-1 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle40 as handle no-undo .
  assign
    v-label-handle40 = v-date-doc-1 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle40)
  then do:
    if v-label-handle40 :tooltip = ""
    or v-label-handle40 :tooltip = ?
    then do:
      assign
        v-label-handle40 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date40-1 in menu m-ed-date40 DO:
    apply "ctrl-b":U to v-date-doc-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date40-2 in menu m-ed-date40 DO:
    apply "ctrl-d":U to v-date-doc-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date40-3 in menu m-ed-date40 DO:
    apply "ctrl-e":U to v-date-doc-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date40-4 in menu m-ed-date40 DO:
    apply "ctrl-f":U to v-date-doc-1 in frame Dialog-Frame .
  END.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date42
    MENU-ITEM m-ed-date42-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date42-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date42-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date42-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date-doc-2 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date-doc-2 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date42 :HANDLE
      v-date-doc-2 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle42 as handle no-undo .
  assign
    v-label-handle42 = v-date-doc-2 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle42)
  then do:
    if v-label-handle42 :tooltip = ""
    or v-label-handle42 :tooltip = ?
    then do:
      assign
        v-label-handle42 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date42-1 in menu m-ed-date42 DO:
    apply "ctrl-b":U to v-date-doc-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date42-2 in menu m-ed-date42 DO:
    apply "ctrl-d":U to v-date-doc-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date42-3 in menu m-ed-date42 DO:
    apply "ctrl-e":U to v-date-doc-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date42-4 in menu m-ed-date42 DO:
    apply "ctrl-f":U to v-date-doc-2 in frame Dialog-Frame .
  END.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date44
    MENU-ITEM m-ed-date44-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date44-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date44-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date44-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date-pay-1 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date-pay-1 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date44 :HANDLE
      v-date-pay-1 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle44 as handle no-undo .
  assign
    v-label-handle44 = v-date-pay-1 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle44)
  then do:
    if v-label-handle44 :tooltip = ""
    or v-label-handle44 :tooltip = ?
    then do:
      assign
        v-label-handle44 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date44-1 in menu m-ed-date44 DO:
    apply "ctrl-b":U to v-date-pay-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date44-2 in menu m-ed-date44 DO:
    apply "ctrl-d":U to v-date-pay-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date44-3 in menu m-ed-date44 DO:
    apply "ctrl-e":U to v-date-pay-1 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date44-4 in menu m-ed-date44 DO:
    apply "ctrl-f":U to v-date-pay-1 in frame Dialog-Frame .
  END.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date46
    MENU-ITEM m-ed-date46-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date46-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date46-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date46-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if v-date-pay-2 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      v-date-pay-2 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date46 :HANDLE
      v-date-pay-2 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle46 as handle no-undo .
  assign
    v-label-handle46 = v-date-pay-2 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle46)
  then do:
    if v-label-handle46 :tooltip = ""
    or v-label-handle46 :tooltip = ?
    then do:
      assign
        v-label-handle46 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date46-1 in menu m-ed-date46 DO:
    apply "ctrl-b":U to v-date-pay-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date46-2 in menu m-ed-date46 DO:
    apply "ctrl-d":U to v-date-pay-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date46-3 in menu m-ed-date46 DO:
    apply "ctrl-e":U to v-date-pay-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date46-4 in menu m-ed-date46 DO:
    apply "ctrl-f":U to v-date-pay-2 in frame Dialog-Frame .
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
def var sort-labelBR-docs   as character no-undo .
def var sort-clmnBR-docs    as handle    no-undo .
def var cur-clmnBR-docs     as handle    no-undo .
def var cur-clmn-locBR-docs as integer   no-undo .
def var re-queryBR-docs     as logical   initial no no-undo .
on start-search, ctrl-o of BR-docs in frame Dialog-Frame do:
   run sort-brBR-docs
     (input (if available ub.fin-ob
             then recid(ub.fin-ob)
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
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(buf_fin-liab), &1&2&1)', chr(34), rid-list)     .     run OpenBr (yes, no, '':U).   . END.
        when 'Статус'  then DO:    assign       sort-column-name = "buf_fin-liab.status_"     .     run OpenBr (yes, no, '':U).   . END.
        when '№ док-та'  then DO:    assign       sort-column-name = "buf_fin-liab.prn-doc-code"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Создан'  then DO:    assign       sort-column-name = "buf_fin-liab.doc-date"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Закрыт'  then DO:    assign       sort-column-name = "buf_fin-liab.fact-date"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Договор'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1contract-id&1, recid(buf_fin-liab))', chr(34))     .     run OpenBr (yes, no, '':U).   . END.
        when 'Получатель'  then DO:    assign       sort-column-name = "buf_fin-liab.receiver-name"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Плательщик'  then DO:    assign       sort-column-name = "buf_fin-liab.payer-name"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Платеж'  then DO:    assign       sort-column-name = "buf_fin-liab.pay-date"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Вал'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1val-abbr-type&1, recid(buf_fin-liab))', chr(34))     .     run OpenBr (yes, no, '':U).   . END.
        when 'Сумма в валюте!док-та'  then DO:    assign       sort-column-name = "buf_fin-liab.sum-doc"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Внутр.№'  then DO:    assign       sort-column-name = "buf_fin-liab.doc-code"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Тип'  then DO:    assign       sort-column-name = "buf_fin-liab.doc-type"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Непогаш.задолж!(руб.)'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1debts&1, recid(buf_fin-liab))', chr(34))     .     run OpenBr (yes, no, '':U).   . END.
        when 'Объект'  then DO:    assign       sort-column-name = "buf_fin-liab.obj-code"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Наименование'  then DO:    assign       sort-column-name = "buf_fin-liab.receiver-name"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Условие генерации'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1contract-gen&1, recid(buf_fin-liab))', chr(34))     .     run OpenBr (yes, no, '':U).   . END.
        when 'Счет-фактура'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1f-factur&1, recid(buf_fin-liab))', chr(34))     .     run OpenBr (yes, no, '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr (yes, no, '':U).
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
   run OpenBr (yes, no, '':U).
end.
else do:
   assign re-queryBR-docs = yes.
   run sort-brBR-docs
     (input (if available ub.fin-ob
             then recid(ub.fin-ob)
             else ?
            )
     ).
   assign re-queryBR-docs = no.
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find first ub.sysconf no-lock where ub.sysconf.host-code = par-host-code no-error .
  var-fin-calc = ub.sysconf.fin-calc   .
buf_fin-liab.receiver-name:resizable in browse BR-docs   = true .
p-gen:resizable                      in browse BR-docs   = true .
buf_fin-liab.sum-doc:resizable in browse BR-docs   = true .
p-contr:resizable              in browse BR-docs   = true .
buf_fin-liab.status_:resizable in browse BR-docs   = true .
buf_fin-liab.receiver-name:width     in browse BR-docs   = v-size-col1 .
p-gen:width                          in browse BR-docs   = v-size-col2 .
buf_fin-liab.sum-doc:width     in browse BR-docs   = v-size-col3 .
p-contr:width                  in browse BR-docs   = v-size-col4 .
buf_fin-liab.status_:width     in browse BR-docs   = v-size-col5 .
buf_fin-liab.status_:read-only in browse BR-docs = true .
 if var-fin-calc = 0 then
    p-obj:visible in browse BR-docs = false .
define variable p-file-label as character no-undo .
p-file-label =  "Финансовые обязательства".
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
        if p-char <> "" then do:
            assign
            r-31 = 2
            r-32 = 1
            d-2 = 2
            v-date-pay-1 = 01/01/91
            v-date-pay-2 = date(p-char).
        end.
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
  run my-enable_UI in this-procedure .
  r-1 = 1 .
  r-2 = 1 .
  r-3 = 1 .
  FIND FIRST buf_contract no-lock  no-error .
if available buf_contract then do:
        CREATE xx-contract.
        BUFFER-COPY buf_contract TO xx-contract  .
    end.
    else  do:
      CREATE xx-contract.
      assign
        xx-contract.contract-code = 1
        xx-contract.host-code = 1
      .
    end.
  run OpenBR in this-procedure (yes, no, '':U).
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numBR-docs as INT EXTENT 19 no-undo.
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
       IF  true = true   THEN DO:
   DO jjBR-docs = NUM-ENTRIES(v-order-col) TO 1 BY -1:
     RUN re-move-clmnBR-docs ( cur-clmn-numBR-docs[INTEGER(ENTRY (jjBR-docs, v-order-col))] , 4).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE BR-docs do:
  RUN re-move-clmnBR-docs ( 4, 19).
END.
ON ctrl-cursor-left OF BROWSE BR-docs do:
  RUN re-move-clmnBR-docs (19, 4).
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
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmviBR-docs = 1 TO EXTENT(cur-clmn-numBR-docs):
    if cur-clmn-numBR-docs[varmviBR-docs] = cur-clmn-loc THEN move-elementBR-docs = varmviBR-docs.
  END.
  RUN re-move-clmnBR-docs (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultBR-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlBR-docs = 4 to EXTENT(cur-clmn-numBR-docs):
    RUN re-move-clmnBR-docs (cur-clmn-numBR-docs[varmvlBR-docs], varmvlBR-docs).
  END.
  RUN start-mv-clmnBR-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  hide mark-num in frame Dialog-Frame .
  if pardoc-rec <> ? then
     reposition br-docs to recid doc-rec no-error.
  apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame focus br-docs.
END.
run disable_UI in this-procedure .
PROCEDURE add-proc :
define variable v-doc-rec as recid no-undo .
if  p-doc-type = ?   then do:
  message  "Добавление финансовых обязательств возможно только  по типам !" view-as alert-box information .
  return .
end.
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run OpenBr in this-procedure (yes, no, '':U).
  reposition br-docs to recid v-doc-rec no-error .
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY R-1 R-2 v-date-doc-1 v-date-pay-1 R-3 v-date-doc-2 v-date-pay-2
          sch-code p-desc p-date T-paket FILL-IN-20 FILL-IN-21 FILL-IN-22
          FILL-IN-24 FILL-IN-26 s-name FILL-IN-1 loc_receiver-name loc_sum-doc
          d-abbr loc_user-name loc_payer-name loc_sum-rubl r-abbr loc_sum-base
          v-abbr mark-num loc_sum-contr v-abbr-contr
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-1 B-sel B-close B-Export b-fact B-trn B-parts B-PFO B-Help
         B-sch B-History B-mark B-add B-lkp B-chg B-del b-exec-fo b-exec-pay
         B-print R-1 R-2 v-date-doc-1 v-date-pay-1 R-3 v-date-doc-2
         v-date-pay-2 B-reopen-br sch-code p-desc p-date BR-docs T-paket
         FILL-IN-20 FILL-IN-21 FILL-IN-22 FILL-IN-24 FILL-IN-26 s-name
         FILL-IN-1 loc_receiver-name loc_sum-doc d-abbr loc_user-name
         loc_payer-name loc_sum-rubl r-abbr loc_sum-base v-abbr mark-num
         loc_sum-contr v-abbr-contr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-docs FOR EACH buf_fin-liab  NO-LOCK ,        FIRST xx-contract .
END PROCEDURE.
PROCEDURE my-enable_UI :
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
         B-add       when LOOKUP("b-add":U,  bttns) > 0
         B-chg       when LOOKUP("b-chg":U,  bttns) > 0
         b-exec-fo   when LOOKUP("b-exec-fo":U,  bttns) > 0
         B-Export
         B-close
         B-PFO       when LOOKUP("no-B-PFO":U,  bttns) = 0
         B-History
         b-trn
         b-parts
         B-sch
         B-print
         B-Help
         b-sel       when LOOKUP("b-sel":U,  bttns) > 0
         b-mark      when LOOKUP("b-mark":U, bttns) > 0
         b-del
         b-fact
         BR-docs sch-code p-desc p-date  mark-num
         T-paket
      B-reopen-br R-1 R-2 r-3  v-date-doc-1 v-date-doc-2 v-date-pay-1 v-date-pay-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  hide b-exec-pay  in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define buffer buff_contract for ub.contract.
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
  CASE par-mode :
    WHEN 'фирма':U THEN DO:
       ASSIGN frame Dialog-Frame:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " код: " +  string(par-host-code).
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
                              "FOR EACH buf_fin-liab"
      parameter-4-54 =
        (
          if ("     buf_fin-liab.host-code = par-host-code  and    ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))    " + " " + where-phrase-54) <> ""
          then           substitute('           buf_fin-liab.host-code = &2  and           ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and          ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ' , chr(34) , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 ,r-32) +          substitute('           ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and          ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 ))           ' , chr(34) , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 )           + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + substitute(' , FIRST xx-contract where (  &1 = 1  or (  xx-contract.contract-code = buf_fin-liab.contract-code )) ' , r-2 ))
      parameter-6-54 = if sort-phrase-54 = ''
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
          ("     buf_fin-liab.host-code = par-host-code  and    ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))    " + " " + where-phrase-54 = "")
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
    OPEN QUERY br-docs FOR EACH buf_fin-liab no-lock
      where      buf_fin-liab.host-code = par-host-code  and    ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))
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
    if query br-docs:handle:get-buffer-handle(1) = (buffer buf_fin-liab:handle) then do:
      assign
      parameter-2-54 = (if p-find-next then "true":u else "false":u )
      parameter-4-54 =
        "where ":u +           substitute('           buf_fin-liab.host-code = &2  and           ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and          ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ' , chr(34) , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 ,r-32) +          substitute('           ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and          ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 ))           ' , chr(34) , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 )           + " ":u + where-phrase-54 + " ":u + p-find-condition + " " + ""
      parameter-5-54 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(buf_fin-liab)
                          ,input logical(parameter-2-54)
                          ,input no-lock
                          ,input (buffer buf_fin-liab:handle)
                          ,input parameter-4-54
                          ,input parameter-5-54
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-54 = (if p-find-next then "true":u else "false":u )
      parameter-3-54 =  "FOR EACH buf_fin-liab"
      parameter-4-54 =
        (
          if ("     buf_fin-liab.host-code = par-host-code  and    ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))    " + " " + where-phrase-54) <> ""
          then           substitute('           buf_fin-liab.host-code = &2  and           ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and          ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ' , chr(34) , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 ,r-32) +          substitute('           ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and          ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 ))           ' , chr(34) , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 )           + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + substitute(' , FIRST xx-contract where (  &1 = 1  or (  xx-contract.contract-code = buf_fin-liab.contract-code )) ' , r-2 ) + " " + p-find-condition)
      parameter-6-54 = if sort-phrase-54 = ''
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
       ASSIGN frame Dialog-Frame:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " код: " +  string(par-host-code)
                                          + " Тип: " +  p-doc-type-full .
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-56  as logical   no-undo .
define variable  l-filter-open-56    as logical   .
define variable  flt-rec-56       as recid     no-undo .
define variable  filter-name-56      as character no-undo .
define variable  where-phrase-56     as character no-undo .
define variable  sort-phrase-56      as character no-undo .
define variable  where-phrase-rus-56 as character no-undo .
define variable  sort-phrase-rus-56  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-56
  ,output filter-name-56
  ,output where-phrase-56
  ,output sort-phrase-56
  ,output where-phrase-rus-56
  ,output sort-phrase-rus-56
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-56
      ) no-error .
  assign
    l-filter-open-56 = false
  .
  if flt-rec-56 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-56 as character no-undo .
    define variable  parameter-3-56 as character no-undo .
    define variable  parameter-4-56 as character no-undo .
    define variable  parameter-5-56 as character no-undo .
    define variable  parameter-6-56 as character no-undo .
    define variable  parameter-7-56 as character no-undo .
      assign
      parameter-3-56 =
                              "FOR EACH buf_fin-liab"
      parameter-4-56 =
        (
          if (" buf_fin-liab.host-code = par-host-code   and buf_fin-liab.doc-type = p-doc-type and   ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))   " + " " + where-phrase-56) <> ""
          then           substitute('           buf_fin-liab.host-code = &2  and           ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and          ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ' , chr(34) , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 , r-32 ) +          substitute('           ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and          ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 ))  and            buf_fin-liab.doc-type = &1&8&1          ' , chr(34) , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 , p-doc-type )           + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + substitute(' , FIRST xx-contract where (  &1 = 1  or (  xx-contract.contract-code = buf_fin-liab.contract-code )) ' , r-2 ))
      parameter-6-56 = if sort-phrase-56 = ''
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
        " " + sort-phrase-56
        )
      parameter-7-56 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-56 =
          (" buf_fin-liab.host-code = par-host-code   and buf_fin-liab.doc-type = p-doc-type and   ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))   " + " " + where-phrase-56 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-56
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ,input parameter-6-56
                          ,input parameter-7-56
                          )
      .
      assign
        l-filter-open-56 = true
      .
    end.
    if l-filter-open-56 = false then do:
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
  if l-filter-open-56 = false then do:
    OPEN QUERY br-docs FOR EACH buf_fin-liab no-lock
      where  buf_fin-liab.host-code = par-host-code   and buf_fin-liab.doc-type = p-doc-type and   ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))
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
    if query br-docs:handle:get-buffer-handle(1) = (buffer buf_fin-liab:handle) then do:
      assign
      parameter-2-56 = (if p-find-next then "true":u else "false":u )
      parameter-4-56 =
        "where ":u +           substitute('           buf_fin-liab.host-code = &2  and           ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and          ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ' , chr(34) , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 , r-32 ) +          substitute('           ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and          ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 ))  and            buf_fin-liab.doc-type = &1&8&1          ' , chr(34) , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 , p-doc-type )           + " ":u + where-phrase-56 + " ":u + p-find-condition + " " + ""
      parameter-5-56 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(buf_fin-liab)
                          ,input logical(parameter-2-56)
                          ,input no-lock
                          ,input (buffer buf_fin-liab:handle)
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-56 = (if p-find-next then "true":u else "false":u )
      parameter-3-56 =  "FOR EACH buf_fin-liab"
      parameter-4-56 =
        (
          if (" buf_fin-liab.host-code = par-host-code   and buf_fin-liab.doc-type = p-doc-type and   ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))   " + " " + where-phrase-56) <> ""
          then           substitute('           buf_fin-liab.host-code = &2  and           ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and          ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ' , chr(34) , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 , r-32 ) +          substitute('           ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and          ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 ))  and            buf_fin-liab.doc-type = &1&8&1          ' , chr(34) , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 , p-doc-type )           + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + substitute(' , FIRST xx-contract where (  &1 = 1  or (  xx-contract.contract-code = buf_fin-liab.contract-code )) ' , r-2 ) + " " + p-find-condition)
      parameter-6-56 = if sort-phrase-56 = ''
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
        " " + sort-phrase-56
        )
      parameter-7-56 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-56)
                          ,input no-lock
                          ,input parameter-3-56
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ,input parameter-6-56
                          ,input parameter-7-56
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
       ASSIGN frame Dialog-Frame:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " код: " +  string(par-host-code)
                                          + " Тип: "    +  p-doc-type-full
                                          + " Статус: " +  string(p-status_) .
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-58  as logical   no-undo .
define variable  l-filter-open-58    as logical   .
define variable  flt-rec-58       as recid     no-undo .
define variable  filter-name-58      as character no-undo .
define variable  where-phrase-58     as character no-undo .
define variable  sort-phrase-58      as character no-undo .
define variable  where-phrase-rus-58 as character no-undo .
define variable  sort-phrase-rus-58  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-58
  ,output filter-name-58
  ,output where-phrase-58
  ,output sort-phrase-58
  ,output where-phrase-rus-58
  ,output sort-phrase-rus-58
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-58
      ) no-error .
  assign
    l-filter-open-58 = false
  .
  if flt-rec-58 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-58 as character no-undo .
    define variable  parameter-3-58 as character no-undo .
    define variable  parameter-4-58 as character no-undo .
    define variable  parameter-5-58 as character no-undo .
    define variable  parameter-6-58 as character no-undo .
    define variable  parameter-7-58 as character no-undo .
      assign
      parameter-3-58 =
                              "FOR EACH buf_fin-liab"
      parameter-4-58 =
        (
          if (" buf_fin-liab.host-code = par-host-code  and buf_fin-liab.doc-type = p-doc-type  and buf_fin-liab.status_= p-status_ and   ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))   " + " " + where-phrase-58) <> ""
          then           substitute('           buf_fin-liab.host-code = &2  and           ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and          ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ' , chr(34) , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 , r-32 ) +          substitute('           ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and          ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 )) and            buf_fin-liab.doc-type = &1&8&1 and            buf_fin-liab.status_  = &1&9&1          ' , chr(34) , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 , p-doc-type , p-status_ )           + " " + where-phrase-58
          else "true"
        )
      parameter-5-58 = (" " + "" + " " + substitute(' , FIRST xx-contract where (  &1 = 1  or (  xx-contract.contract-code = buf_fin-liab.contract-code )) ' , r-2 ))
      parameter-6-58 = if sort-phrase-58 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-58
        )
      parameter-7-58 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-58 =
          (" buf_fin-liab.host-code = par-host-code  and buf_fin-liab.doc-type = p-doc-type  and buf_fin-liab.status_= p-status_ and   ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))   " + " " + where-phrase-58 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-58
                          ,input parameter-4-58
                          ,input parameter-5-58
                          ,input parameter-6-58
                          ,input parameter-7-58
                          )
      .
      assign
        l-filter-open-58 = true
      .
    end.
    if l-filter-open-58 = false then do:
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
  if l-filter-open-58 = false then do:
    OPEN QUERY br-docs FOR EACH buf_fin-liab no-lock
      where  buf_fin-liab.host-code = par-host-code  and buf_fin-liab.doc-type = p-doc-type  and buf_fin-liab.status_= p-status_ and   ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))
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
    if query br-docs:handle:get-buffer-handle(1) = (buffer buf_fin-liab:handle) then do:
      assign
      parameter-2-58 = (if p-find-next then "true":u else "false":u )
      parameter-4-58 =
        "where ":u +           substitute('           buf_fin-liab.host-code = &2  and           ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and          ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ' , chr(34) , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 , r-32 ) +          substitute('           ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and          ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 )) and            buf_fin-liab.doc-type = &1&8&1 and            buf_fin-liab.status_  = &1&9&1          ' , chr(34) , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 , p-doc-type , p-status_ )           + " ":u + where-phrase-58 + " ":u + p-find-condition + " " + ""
      parameter-5-58 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(buf_fin-liab)
                          ,input logical(parameter-2-58)
                          ,input no-lock
                          ,input (buffer buf_fin-liab:handle)
                          ,input parameter-4-58
                          ,input parameter-5-58
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-58 = (if p-find-next then "true":u else "false":u )
      parameter-3-58 =  "FOR EACH buf_fin-liab"
      parameter-4-58 =
        (
          if (" buf_fin-liab.host-code = par-host-code  and buf_fin-liab.doc-type = p-doc-type  and buf_fin-liab.status_= p-status_ and   ( r-1 = 1  or ( buf_fin-liab.receiver-code = hard-flt-cli-code and buf_fin-liab.receiver-type = hard-flt-cli-type )) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))   " + " " + where-phrase-58) <> ""
          then           substitute('           buf_fin-liab.host-code = &2  and           ( &3 = 1 or ( buf_fin-liab.receiver-code = &4 and buf_fin-liab.receiver-type = &1&5&1 )) and          ( &6 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &7 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ' , chr(34) , par-host-code , r-1 , hard-flt-cli-code , hard-flt-cli-type , r-31 , r-32 ) +          substitute('           ( &2 = 1  or ( &3 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &4 )) and          ( &5 = 1  or ( &6 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &7 )) and            buf_fin-liab.doc-type = &1&8&1 and            buf_fin-liab.status_  = &1&9&1          ' , chr(34) , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1 , v-date-pay-2 , p-doc-type , p-status_ )           + " " + where-phrase-58
          else "true"
        )
      parameter-5-58 = (" " + "" + " " + substitute(' , FIRST xx-contract where (  &1 = 1  or (  xx-contract.contract-code = buf_fin-liab.contract-code )) ' , r-2 ) + " " + p-find-condition)
      parameter-6-58 = if sort-phrase-58 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-58
        )
      parameter-7-58 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-58)
                          ,input no-lock
                          ,input parameter-3-58
                          ,input parameter-4-58
                          ,input parameter-5-58
                          ,input parameter-6-58
                          ,input parameter-7-58
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
    WHEN "contract":U THEN DO:
    hide r-1 r-2 s-tt FILL-IN-20  FILL-IN-21  in frame Dialog-Frame .
    find first buff_contract no-lock where buff_contract.host-code     = par-host-code and
                                           buff_contract.contract-code = integer(p-char) no-error .
    if available buff_contract then
       loc_contract-code        =  buff_contract.contract-prn-code .
       else loc_contract-code   = "".
       ASSIGN frame Dialog-Frame:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " код: " +  string(par-host-code)
                                                 + " Договор: " + loc_contract-code     + " ( вн.№ " + string(p-char) +  " )" .
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-60  as logical   no-undo .
define variable  l-filter-open-60    as logical   .
define variable  flt-rec-60       as recid     no-undo .
define variable  filter-name-60      as character no-undo .
define variable  where-phrase-60     as character no-undo .
define variable  sort-phrase-60      as character no-undo .
define variable  where-phrase-rus-60 as character no-undo .
define variable  sort-phrase-rus-60  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-60
  ,output filter-name-60
  ,output where-phrase-60
  ,output sort-phrase-60
  ,output where-phrase-rus-60
  ,output sort-phrase-rus-60
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-60
      ) no-error .
  assign
    l-filter-open-60 = false
  .
  if flt-rec-60 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-60 as character no-undo .
    define variable  parameter-3-60 as character no-undo .
    define variable  parameter-4-60 as character no-undo .
    define variable  parameter-5-60 as character no-undo .
    define variable  parameter-6-60 as character no-undo .
    define variable  parameter-7-60 as character no-undo .
      assign
      parameter-3-60 =
                              "FOR EACH buf_fin-liab"
      parameter-4-60 =
        (
          if (" buf_fin-liab.host-code = par-host-code  and buf_fin-liab.contract-code = integer(p-char) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))    " + " " + where-phrase-60) <> ""
          then           substitute('           buf_fin-liab.host-code = &2  and           ( &3 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &4 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ( &5 = 1 or ( &6 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &7 )) and          ( &8 = 1 or ( &9 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &1 )) and          ' , v-date-pay-2 , par-host-code , r-31 , r-32  , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1  ) +          substitute(' buf_fin-liab.contract-code = integer(&1)  ' , p-char)    + " " + where-phrase-60
          else "true"
        )
      parameter-5-60 = (" " + "" + " " + substitute(' , FIRST xx-contract ' ))
      parameter-6-60 = if sort-phrase-60 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-60
        )
      parameter-7-60 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-60 =
          (" buf_fin-liab.host-code = par-host-code  and buf_fin-liab.contract-code = integer(p-char) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))    " + " " + where-phrase-60 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-60
                          ,input parameter-4-60
                          ,input parameter-5-60
                          ,input parameter-6-60
                          ,input parameter-7-60
                          )
      .
      assign
        l-filter-open-60 = true
      .
    end.
    if l-filter-open-60 = false then do:
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
  if l-filter-open-60 = false then do:
    OPEN QUERY br-docs FOR EACH buf_fin-liab no-lock
      where  buf_fin-liab.host-code = par-host-code  and buf_fin-liab.contract-code = integer(p-char) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))
    , FIRST xx-contract
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
    if query br-docs:handle:get-buffer-handle(1) = (buffer buf_fin-liab:handle) then do:
      assign
      parameter-2-60 = (if p-find-next then "true":u else "false":u )
      parameter-4-60 =
        "where ":u +           substitute('           buf_fin-liab.host-code = &2  and           ( &3 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &4 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ( &5 = 1 or ( &6 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &7 )) and          ( &8 = 1 or ( &9 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &1 )) and          ' , v-date-pay-2 , par-host-code , r-31 , r-32  , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1  ) +          substitute(' buf_fin-liab.contract-code = integer(&1)  ' , p-char)    + " ":u + where-phrase-60 + " ":u + p-find-condition + " " + ""
      parameter-5-60 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(buf_fin-liab)
                          ,input logical(parameter-2-60)
                          ,input no-lock
                          ,input (buffer buf_fin-liab:handle)
                          ,input parameter-4-60
                          ,input parameter-5-60
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-60 = (if p-find-next then "true":u else "false":u )
      parameter-3-60 =  "FOR EACH buf_fin-liab"
      parameter-4-60 =
        (
          if (" buf_fin-liab.host-code = par-host-code  and buf_fin-liab.contract-code = integer(p-char) and   ( r-31 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and   ( r-32 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and   ( d-1 = 1  or ( v-date-doc-1 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= v-date-doc-2 )) and   ( d-2 = 1  or ( v-date-pay-1 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= v-date-pay-2 ))    " + " " + where-phrase-60) <> ""
          then           substitute('           buf_fin-liab.host-code = &2  and           ( &3 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl > 0 ))  and          ( &4 = 1 or ( buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl <= 0 )) and          ( &5 = 1 or ( &6 <= buf_fin-liab.doc-date and buf_fin-liab.doc-date <= &7 )) and          ( &8 = 1 or ( &9 <= buf_fin-liab.pay-date and buf_fin-liab.pay-date <= &1 )) and          ' , v-date-pay-2 , par-host-code , r-31 , r-32  , d-1  , v-date-doc-1 , v-date-doc-2 , d-2 , v-date-pay-1  ) +          substitute(' buf_fin-liab.contract-code = integer(&1)  ' , p-char)    + " " + where-phrase-60
          else "true"
        )
      parameter-5-60 = (" " + "" + " " + substitute(' , FIRST xx-contract ' ) + " " + p-find-condition)
      parameter-6-60 = if sort-phrase-60 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-60
        )
      parameter-7-60 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-60)
                          ,input no-lock
                          ,input parameter-3-60
                          ,input parameter-4-60
                          ,input parameter-5-60
                          ,input parameter-6-60
                          ,input parameter-7-60
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
reposition br-docs to recid doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
END PROCEDURE.
PROCEDURE print-proc :
define variable vss-include-info61 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 EMPTY TEMP-TABLE tt-val .
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
     buf_fin-liab.status_    COLUMN-LABEL 'Статус'        Format "x(6)"
     buf_fin-liab.prn-doc-code    COLUMN-LABEL '№ док-та'        Format "x(10)"
     buf_fin-liab.doc-date    COLUMN-LABEL 'Создан'      format "99/99/99"
     buf_fin-liab.fact-date    COLUMN-LABEL 'Закрыт'        format "99/99/99"
     p-contr   COLUMN-LABEL 'Договор'           Format "x(16)"
     buf_fin-liab.receiver-name    COLUMN-LABEL 'Получатель'      Format "x(10)"
     buf_fin-liab.payer-name    COLUMN-LABEL 'Плательщик'      Format "x(10)"
     buf_fin-liab.pay-date   COLUMN-LABEL 'Платеж'         format "99/99/99"
     l-curr COLUMN-LABEL 'Вал'              Format "x(3)"
     buf_fin-liab.sum-doc   COLUMN-LABEL "Сумма в вал.док"
     p-delta   COLUMN-LABEL "Задолженность в вал.док"   format "->,>>>,>>>,>>>,>>9.99"
     p-gen   COLUMN-LABEL 'Условие генерации'           Format "x(25)"
        HEADER  date_string AT 5 format "X(35)"
                    string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
                    Line format "X(157)" AT 1
    with width 232 down stream-io use-text    .
    Line = fill("-", 157).
    date_string = cur-time-print() .
    run prn-lib-open-stream in this-procedure
    (  input parParentProc
      ,input 43
      ,input yes
      ,input no
      ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame Dialog-Frame:title )
    format "x(157)" SKIP(1) .
    FORM HEADER
            Line format "X(177)" AT 1 SKIP
            "Продолжение - на следующей странице" AT 30 SKIP
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
              buf_fin-liab.fact-date
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
            GET next br-docs.
      END.
      UNDERLINE  STREAM PrnLibStream
        buf_fin-liab.status_
        buf_fin-liab.prn-doc-code
        buf_fin-liab.doc-date
        buf_fin-liab.fact-date
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
        buf_fin-liab.fact-date
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
define variable varxmldocfl      as character no-undo.
define variable varxmldocfl-type as character no-undo.
define variable v-file-name as character no-undo .
define variable for-dir as character no-undo .
define variable accum-count as integer no-undo init 0.
define variable accum-count-ok as integer no-undo init 0 .
define variable loclog as logical no-undo .
define variable ii as integer no-undo .
define variable ii0 as integer no-undo .
define buffer buf_fin-ob for ub.fin-ob.
if not available buf_fin-liab then do:
  message "Неправильный выбор документа.".
  return no-apply.
end.
CASE T-paket:
  when no then do:
    assign
    v-file-name =  ?
    .
    run bge/xmlfo.p ( input buf_fin-liab.host-code, buf_fin-liab.doc-code, input-output v-file-name, yes, yes) no-error .
  end.
  when  yes then do:
    if rid-list = "":U then do:
        message
        "Вы не отметили ни одного ФО"
        view-as alert-box error.
        return error.
    end.
    run gbl/d-file.p
      (input-output v-file-name
      ,input-output for-dir
      ,input  (" Все файлы XML (*.xml) ")
      ,input  ("*.xml":U)
      ,input  chr(44)
      ,input  (".xml":U)
      ,input  no
      ,input  yes
      ,input  yes
      ,input  "Введите имя файла"
      ,output loclog
      ) .
    if not loclog then do:
      return .
    end.
    run waitfram-show in this-procedure ("Ждите...").
    assign
     ii0 = num-entries(rid-list)
    .
    repeat  ii = 1 to ii0 :
      find first buf_fin-ob no-lock where
                recid(buf_fin-ob) = integer(entry(ii, rid-list)) no-error .
      if available buf_fin-ob then do:
        assign
          accum-count = accum-count + 1
        .
        run bge/xmlfo.p
        (               input buf_fin-ob.host-code
                      , input buf_fin-ob.doc-code
                      , input-output v-file-name
                      , input (accum-count-ok = 0)
                      , input ii = ii0
                      ) no-error .
        if not error-status:error then
        assign
          accum-count-ok = accum-count-ok + 1
        .
      end.
    run waitfram-hide in this-procedure .
  end.
end.
END CASE.
if error-status:error
or (t-paket and accum-count <> accum-count-ok)
then do:
  message
  "Ошибка при выгрузке ФО в XML-формате" skip
  string(if t-paket then substitute("Выгружено &1 ФО из &2", accum-count-ok, accum-count) else "":U) skip
  error-status :get-message(1)
  view-as alert-box .
  if not t-paket then
  return error .
end.
define variable v-sys-key as character no-undo.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
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
  tbl = 'fin-ob'
  join-tbl = 'buf_fin-liab'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure ('doc-code', 'Внутр.№', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('contract-code', 'Внутр.№ договора', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('prn-doc-code', '№ документа ', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('host-code', 'Код фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('curr-code', 'Код валюты', 'curr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('corr-doc', 'Корр ФО', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('doc-date', 'Создан(дата)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('fact-date', 'Закрыт(дата)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('pay-date', 'Дата Платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('user-name-doc', 'Кто создал', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('user-name-fact', 'Кто закрыл на факт', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('payer-type*payer-code', 'Плательщик', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('receiver-type*receiver-code', 'Получатель', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('obj-type*obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run OpenBr in this-procedure (yes, no, '':U).
END.
END PROCEDURE.
PROCEDURE proc-close :
define variable rr as recid no-undo .
define variable ii as integer no-undo .
define variable g-ok as logical no-undo .
define variable v-recid  as recid no-undo .
define variable vss-include-info63 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_close-fact':U
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
  if t-paket then do:
    define variable v-4 as integer   no-undo .
    v-4 = num-entries(rid-list) .
    repeat ii = 1 to v-4 :
      v-recid = integer(entry(ii, rid-list)).
      run proc-close-one-fin-ob in this-procedure ( input v-recid ) .
    end.
  end.
  else do:
    find current   buf_fin-liab no-lock no-error .
    v-recid = recid( buf_fin-liab ).
    run proc-close-one-fin-ob in this-procedure ( input v-recid ) .
  end.
  run OpenBr in this-procedure (yes, no, '':U) .
  reposition br-docs  TO RECID v-recid NO-ERROR .
  if error-status :error then  reposition br-docs  TO row 1 NO-ERROR .
  apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-open :
define variable rr as recid no-undo .
define variable ii as integer no-undo .
define variable v-recid  as recid no-undo .
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_close-fact':U
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
  if t-paket then do:
    define variable v-6 as integer   no-undo .
    v-6 = num-entries(rid-list).
    repeat ii = 1 to v-6 :
      v-recid = integer(entry(ii, rid-list)).
      run proc-open-one in this-procedure ( input v-recid ) .
    end.
  end.
  else do:
    find current   buf_fin-liab no-lock no-error .
    v-recid = recid( buf_fin-liab ).
    run proc-open-one in this-procedure ( input v-recid ) .
  end.
  run OpenBr in this-procedure (yes, no, '':U) .
  reposition br-docs  TO RECID v-recid NO-ERROR .
  apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-open-one :
define input parameter p-recid  as recid no-undo .
find first  buf_fin-liab exclusive-lock  where recid(buf_fin-liab) = p-recid  no-error .
if available buf_fin-liab then do:
    if buf_fin-liab.status_ = 'новый':U then do:
      message "Финансовое обязательство " buf_fin-liab.prn-doc-code " находится в статусе НОВЫЙ".
      return.
    end.
   buf_fin-liab.status_ = 'новый':U .
end.
END PROCEDURE.
PROCEDURE proc-copy :
define variable p-doc-code          as integer no-undo.
define variable p-out-host-code     like ub.sysconf.host-code       no-undo.
define variable p-ok                as logical no-undo.
define variable j                   as integer no-undo.
define variable k                   as integer no-undo.
define variable p-ret               as logical no-undo.
define variable p-doc-date          like ub.fin-ob.doc-date         no-undo.
define variable p-payer-name        like ub.fin-ob.payer-name       no-undo.
define variable p-receiver-name     like ub.fin-ob.receiver-name    no-undo.
define variable p-curr-code         like ub.fin-ob.curr-code        no-undo.
define variable p-sum-doc           like ub.fin-ob.sum-doc          no-undo.
define variable p-user-db-num-doc   like ub.fin-ob.user-db-num-doc  no-undo.
define variable p-user-name-doc     like ub.fin-ob.user-name-doc    no-undo.
define variable p-base-rate         like ub.fin-ob.base-rate        no-undo.
define variable p-base-scale        like ub.fin-ob.base-scale       no-undo.
define variable p-receiver-code     like ub.fin-ob.receiver-code    no-undo.
define variable p-receiver-type     like ub.fin-ob.receiver-type    no-undo.
define variable p-contract-code     like ub.fin-ob.contract-code    no-undo.
define variable p-exch-rate         like ub.fin-ob.exch-rate        no-undo.
define variable p-exch-scale        like ub.fin-ob.exch-scale       no-undo.
define variable p-fact-date         like ub.fin-ob.fact-date        no-undo.
define variable p-fact-order        like ub.fin-ob.fact-order       no-undo.
define variable p-host-code         like ub.fin-ob.host-code        no-undo.
define variable p-payer-code        like ub.fin-ob.payer-code       no-undo.
define variable p-payer-type        like ub.fin-ob.payer-type       no-undo.
define variable p-pay-date          like ub.fin-ob.pay-date         no-undo.
define variable p-prn-doc-code      like ub.fin-ob.prn-doc-code     no-undo.
define variable p-sum-base-orig     like ub.fin-ob.sum-base-orig    no-undo.
define variable p-sum-base          like ub.fin-ob.sum-base         no-undo.
define variable p-sum-doc-orig      like ub.fin-ob.sum-doc-orig     no-undo.
define variable p-sum-rubl-orig     like ub.fin-ob.sum-rubl-orig    no-undo.
define variable p-sum-rubl          like ub.fin-ob.sum-rubl         no-undo.
define variable p-trn-doc-code      like ub.fin-ob.trn-doc-code     no-undo.
define variable p-user-db-num-fact  like ub.fin-ob.user-db-num-fact no-undo.
define variable p-user-db-num-pay   like ub.fin-ob.user-db-num-pay  no-undo.
define variable p-user-name-fact    like ub.fin-ob.user-name-fact   no-undo.
define variable p-user-name-pay     like ub.fin-ob.user-name-pay    no-undo.
define variable p-ri                as recid no-undo.
define buffer buf2_fin-liab for ub.fin-ob.
define variable vss-include-info65 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if not g-log then  return .
if num-entries(rid-list) = 0 then do:
   message "Не отмечены записи для копирования !!!" .
   return .
end.
  define variable v-user-select as logical   no-undo .
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userhsts_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,output v-user-select
  )  .
  if v-user-select <> true
  then do:
    return no-apply .
  end.
  define variable v-total-select as integer   no-undo .
  run userhsts_object-count in this-procedure
    (output v-total-select
    ) .
  if v-total-select  = 0
  then do:
    message "Не выбрана фирма для копирования !!!" .
    return .
  end.
  message
    "Отмечено фирм:" v-total-select skip
    "Скопировать выбранные значения справочника в эти фирмы ?"
    view-as alert-box question
    buttons yes-no
    update p-ok.
  k = 0.
  if p-ok = false then return.
  define variable v-8 as integer   no-undo .
  v-8 = num-entries(rid-list) .
    define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
    for each buf_userhsts_temp-user-host
    :
        repeat j = 1 to v-8
        :
          for each buf2_fin-liab where recid(buf2_fin-liab) =  integer(entry(j,rid-list)):
          if not can-find ( first buf_fin-liab no-lock where
                              buf_fin-liab.host-code      = buf_userhsts_temp-user-host.host-code and
                              buf_fin-liab.doc-code       = buf2_fin-liab.doc-code) then do:
                  run current-db  in this-procedure
                  (   input buf_fin-liab.host-code,
                      input par-host-code,
                      output p-ret ) .
                  if p-ret = no then next.
                  run fin-ob-code     in this-procedure (input g#db-num , output p-doc-code ).
                  run create-fin-liab in this-procedure
                  (   input yes ,
                      input  p-doc-code            ,
                      input  today            ,
                      input  buf2_fin-liab.doc-type            ,
                      input  buf2_fin-liab.payer-name            ,
                      input  buf2_fin-liab.receiver-name            ,
                      input  buf2_fin-liab.curr-code           ,
                      input  buf2_fin-liab.sum-doc             ,
                      input  buf2_fin-liab.user-db-num-doc     ,
                      input  buf2_fin-liab.user-name-doc       ,
                      input  buf2_fin-liab.base-rate           ,
                      input  buf2_fin-liab.base-scale          ,
                      input  buf2_fin-liab.receiver-code       ,
                      input  buf2_fin-liab.receiver-type       ,
                      input  buf2_fin-liab.contract-code       ,
                      input  buf2_fin-liab.exch-rate           ,
                      input  buf2_fin-liab.exch-scale          ,
                      input  buf2_fin-liab.contract-curr       ,
                      input  buf2_fin-liab.contract-rate       ,
                      input  buf2_fin-liab.contract-scale      ,
                      input  buf2_fin-liab.fact-date           ,
                      input  buf2_fin-liab.fact-order          ,
                      input  par-host-code           ,
                      input  buf2_fin-liab.payer-code          ,
                      input  buf2_fin-liab.payer-type          ,
                      input  buf2_fin-liab.pay-date            ,
                      input  buf2_fin-liab.prn-doc-code        ,
                      input  'новый':U          ,
                      input  buf2_fin-liab.sum-base-orig       ,
                      input  buf2_fin-liab.sum-base            ,
                      input  buf2_fin-liab.sum-doc-orig        ,
                      input  buf2_fin-liab.sum-rubl-orig       ,
                      input  buf2_fin-liab.sum-rubl            ,
                      input  buf2_fin-liab.sum-contract        ,
                      input  buf2_fin-liab.trn-doc-code        ,
                      input  buf2_fin-liab.user-db-num-fact    ,
                      input  buf2_fin-liab.user-db-num-pay        ,
                      input  buf2_fin-liab.user-name-fact         ,
                      input  buf2_fin-liab.user-name-pay          ,
                      input  buf2_fin-liab.in-type                ,
                      input  buf2_fin-liab.sum-tax-base           ,
                      input  buf2_fin-liab.sum-tax-doc            ,
                      input  buf2_fin-liab.sum-tax-rubl           ,
                      input  buf2_fin-liab.sum-tax-contract       ,
                      input  ""                       ,
                      output p-ri ).
                      k = k + 1.
                  end.
          end.
        end.
     end.
message "Скопировано " k  "обязательств" view-as alert-box .
END PROCEDURE.
PROCEDURE proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
display "" @ p-desc with frame Dialog-Frame.
display "" @ p-date with frame Dialog-Frame.
  doc-rec = ? .
  find first  buf_fin-liab no-lock where  buf_fin-liab.prn-doc-code = pardoc-code no-error  .
  if available buf_fin-liab then doc-rec = recid(buf_fin-liab) .
  reposition BR-docs to recid doc-rec no-error .
  if not error-status :error then apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
  else do:
       message " Запись не найдена " view-as alert-box information .
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
  reposition BR-docs to recid doc-rec no-error .
  if not error-status :error then apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.
END PROCEDURE.
PROCEDURE proc-find-desc :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
define variable pp as integer no-undo.
define buffer b_contract for ub.contract.
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
  reposition BR-docs to recid doc-rec no-error .
  if not error-status :error then apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.
end.
else do:
  message "Договор с таким номером не найден !!!" .
  apply "entry":u to p-desc in frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE proc-m_gen-1 :
define buffer bf_fin-ob for ub.fin-ob.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varlog as logical   no-undo .
define variable v-list as character no-undo .
define variable v-9 as integer   no-undo .
do on error undo, return error return-value :
  if num-entries(rid-list) = 0 then do:
    message "Не выделено ни одного ФО для генерации счета-фактуры !".
    return .
  end.
    varlog = yes.
    message "Выбрано " + string( num-entries( rid-list)  ) +  " ФО . Провести генерацию счетов-фактур?" skip
            view-as alert-box question buttons OK-Cancel update varlog.
    if not varlog then return.
    v-9 = num-entries (rid-list).
    do vari = 1 to v-9 :
        assign vardoc-code = integer(entry (vari, rid-list)).
        find first bf_fin-ob where recid(bf_fin-ob) = vardoc-code no-lock no-error .
        if not available bf_fin-ob then next.
        if bf_fin-ob.status_ <> 'факт':U then do:
          message "Документ " bf_fin-ob.prn-doc-code " статус " bf_fin-ob.status_ " не в статусе " 'факт':U " . Пропускаем." view-as alert-box.
          next .
        end.
        if bf_fin-ob.cr-factur = yes then do:
          message "По документу " bf_fin-ob.doc-code " уже создавался счет-фактура от " bf_fin-ob.factur-date " числа." view-as alert-box.
        end.
        else do:
          run str/gen-scf.p ( input parParentProc, input vardoc-code, "fin-ob", output v-list) no-error .
          if error-status:error then  return error substitute(" Ошибка создания счета-фактуры по ФО &1 &2 &3" ,bf_fin-ob.prn-doc-code, return-value , error-status :get-message(1)) .
        end.
    end.
    assign rid-list = "" .
    run OpenBr in this-procedure (yes, no, '':U) .
  end.
end procedure.
PROCEDURE proc-m_gen-2 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_fin-ob for ub.fin-ob.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
do on error undo, return error return-value
:
define variable v-10 as integer   no-undo .
v-10 = num-entries (rid-list) .
    if rid-list = "" then do:
      if available buf_fin-liab then assign rid-list = string(recid(buf_fin-liab)).
    end.
vari-cycle:
  do vari = 1 to v-10 :
    assign vardoc-code = integer(entry (vari, rid-list)).
    find first bf_fin-ob where recid(bf_fin-ob) = vardoc-code exclusive-lock.
    if bf_fin-ob.status_ <> 'факт':U then do:
      message "Документ " bf_fin-ob.status_ " не в статусе " 'факт':U " . Пропускаем." view-as alert-box.
      next vari-cycle.
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_fin-ob.host-code no-lock.
    if bf_fin-ob.user-db-num-doc <> g#db-num then do:
      message "БД документа с кодом " bf_fin-ob.doc-code " не coвпадает с текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "БД док-та: " bf_fin-ob.user-db-num-doc  " . Пропускаем."
      view-as alert-box error.
      next vari-cycle.
    end.
    if bf_fin-ob.cr-factur = yes then do:
      message "По документу " bf_fin-ob.doc-code " уже создавался счет-фактура от " bf_fin-ob.factur-date " числа." view-as alert-box.
      next vari-cycle.
    end.
    else do:
      if bf_fin-ob.need-factur = 1 or bf_fin-ob.need-factur = 2 then assign  bf_fin-ob.need-factur = 0.
      else do:
        message "Данный документ не нуждался в генерации счета-фактуры." view-as alert-box.
        next vari-cycle.
      end.
      reposition BR-docs to recid recid(bf_fin-ob) no-error.
      if not error-status:error then do:
        display f-factur (recid( bf_fin-ob)) @ varfactur with browse BR-docs.
      end.
    end.
  end.
  assign rid-list = "".
end.
end procedure.
PROCEDURE proc-m_gen-3 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_fin-ob for ub.fin-ob.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varlog as logical   no-undo .
do on error undo, return error return-value
:
  if rid-list = "" then do:
    if available buf_fin-liab then assign rid-list = string(recid(buf_fin-liab)).
  end.
define variable v-11 as integer   no-undo .
v-11 = num-entries (rid-list) .
vari-cycle:
  do vari = 1 to v-11 :
    assign vardoc-code = integer(entry (vari, rid-list)).
    find first bf_fin-ob where recid(bf_fin-ob) = vardoc-code exclusive-lock.
    find first bf_sysconf where bf_sysconf.host-code = bf_fin-ob.host-code no-lock.
    if bf_fin-ob.status_ <> 'факт':U then do:
      message "Документ " bf_fin-ob.status_ " не в статусе " 'факт':U " . Пропускаем." view-as alert-box.
      next vari-cycle.
    end.
    if bf_fin-ob.user-db-num-doc <> g#db-num then do:
      message "БД документа с кодом " bf_fin-ob.doc-code " не coвпадает с текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "БД док-та: " bf_fin-ob.user-db-num-doc  " . Пропускаем."
      view-as alert-box error.
      next vari-cycle.
    end.
    if bf_fin-ob.cr-factur = yes then do:
      assign
        varlog = no.
        message "По документу " bf_fin-ob.doc-code " был создан счет-фактура от " bf_fin-ob.factur-date " ." skip
                "Вы действительно хотите снять признак, чтобы по этому документу был счет-фактура?"
        view-as alert-box question buttons yes-no update varlog.
       if varlog <> yes then  next vari-cycle.
       assign
         bf_fin-ob.cr-factur   = no
         bf_fin-ob.factur-date = 01/01/1990
       .
       reposition BR-docs to recid recid(bf_fin-ob) no-error.
      if not error-status:error then do:
        display f-factur (recid( bf_fin-ob)) @ varfactur with browse BR-docs.
      end.
    end.
    else do:
      message "По документу " bf_fin-ob.doc-code " не было генерации."
      view-as alert-box.
   end.
 end.
 assign rid-list = "".
end.
end procedure.
PROCEDURE proc-m_gen-4 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_fin-ob for ub.fin-ob.
define variable vari as integer no-undo.
define variable vardoc-code as integer no-undo.
define variable varneed-factur as logical no-undo.
define buffer bf_contract for ub.contract.
do on error undo, return error return-value
:
  if rid-list = "" then do:
    if available buf_fin-liab then assign rid-list = string(recid(buf_fin-liab)).
  end.
define variable v-12 as integer   no-undo .
v-12 = num-entries (rid-list).
vari-cycle:
  do vari = 1 to v-12:
    assign vardoc-code = integer(entry (vari, rid-list)) .
    find first bf_fin-ob where recid(bf_fin-ob) = vardoc-code exclusive-lock.
    find first bf_sysconf where bf_sysconf.host-code = bf_fin-ob.host-code no-lock.
    if bf_fin-ob.status_ <> 'факт':U then do:
      message "Документ " bf_fin-ob.status_ " не в статусе " 'факт':U " . Пропускаем."  view-as alert-box.
      next.
    end.
    if bf_fin-ob.user-db-num-doc <> g#db-num then do:
      message "БД документа с кодом " bf_fin-ob.doc-code " не coвпадает с текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "БД док-та: " bf_fin-ob.user-db-num-doc  " . Пропускаем."
      view-as alert-box error.
      return error.
    end.
    if bf_fin-ob.need-factur = 2 then do:
      if bf_fin-ob.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_fin-ob.host-code   and
                                     bf_contract.contract-code = bf_fin-ob.contract-code no-lock no-error.
        if available bf_contract then do:
          if bf_contract.gen-factur = 2 or bf_contract.gen-factur = 12 or bf_contract.gen-factur = 102 or bf_contract.gen-factur = 112 then do:
            assign bf_fin-ob.need-factur = 1  .
            reposition BR-docs to recid recid(bf_fin-ob) no-error.
            if not error-status:error then display f-factur (recid( bf_fin-ob)) @ varfactur with browse BR-docs.
          end.
          else message "По документу " bf_fin-ob.doc-code " нет договоров для генерации счета-фактуры."  view-as alert-box.
        end.
      end.
    end.
    else do:
      message "Документ " bf_fin-ob.doc-code "не имеет признака 'не опред' генерация счета-фактуры."
      view-as alert-box.
      next vari-cycle.
    end.
  end.
  assign rid-list = "" .
end.
end procedure.
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
  if v-date-doc-1 > v-date-doc-2 then do: message "Не верно задан интервал дат создания ФО ! " view-as alert-box error .
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
define BUFFER loc-fin-liab FOR ub.fin-ob.
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error.
if error-status :error then return ''.
  define variable rr as character no-undo .
  define buffer buf-f_contract for ub.contract.
  find first buf-f_contract no-lock where  buf-f_contract.host-code      = par-host-code  and
                                          buf-f_contract.contract-code  = loc-fin-liab.contract-code  no-error.
  if available buf-f_contract then   rr = buf-f_contract.usl-opl .
     else rr = "".
  RETURN rr.
END FUNCTION.
FUNCTION contract-id RETURNS CHARACTER
( input p-rec as recid ) :
define  BUFFER loc-fin-liab FOR ub.fin-ob.
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
FUNCTION debts RETURNS DECIMAL
( input p-rec as recid ) :
define  BUFFER buf_fin-liab FOR ub.fin-ob .
find first  buf_fin-liab no-lock where recid (buf_fin-liab) = p-rec no-error .
if error-status :error then return ? .
  RETURN buf_fin-liab.sum-rubl - buf_fin-liab.con-sum-rubl .
END FUNCTION.
FUNCTION f-factur RETURNS CHARACTER
( input p-rec as recid ) :
define buffer loc-t-doc for ub.fin-ob .
find first loc-t-doc no-lock where recid (loc-t-doc) = p-rec no-error .
if error-status :error then return '' .
 if loc-t-doc.cr-factur = yes then do:
   return string (loc-t-doc.factur-date, "99/99/99").
 end.
 else do:
   if loc-t-doc.need-factur = 0 then do:
     return "--------".
   end.
   if loc-t-doc.need-factur = 1 then do:
     return " ".
   end.
   if loc-t-doc.need-factur = 2 then do:
     return "не опред".
   end.
 end.
END FUNCTION.
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int ) :
  define variable rr as character no-undo .
  find first ub.currency no-lock where  ub.currency.curr-code  = p-curr-code no-error.
  rr = ub.currency.curr-abbr.
  RETURN rr.
END FUNCTION.
FUNCTION val-abbr-type RETURNS CHARACTER
( input p-rec as recid ) :
define  BUFFER loc-fin-liab FOR ub.fin-ob.
find first loc-fin-liab no-lock where recid (loc-fin-liab) = p-rec no-error .
if error-status :error then return '' .
  define variable rr as character no-undo .
     find first ub.currency no-lock where ub.currency.curr-code  = loc-fin-liab.curr-code no-error.
  rr = currency.curr-abbr .
if available ub.currency then  rr = ub.currency.curr-abbr.
else rr = ""   .
  RETURN rr.
END FUNCTION.
