define input parameter parparentproc  as widget-handle no-undo.
define input parameter bttns     as character   no-undo .
define input parameter par-mode  as character   no-undo .
define input parameter par-host-code like ub.clients.obj-code no-undo.
define input parameter par-doc-code as character no-undo .
define output parameter rid-list        as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История финансовых обязательств".
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
define variable  p-doc-type   as character no-undo .
define variable  p-status_   as character no-undo .
define variable  p-char      as character no-undo .
define variable g-log as logical no-undo .
define variable doc-rec as recid no-undo .
define variable g#report-num as integer no-undo .
define variable p-base-code as integer no-undo .
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
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE  var br-handle as handle no-undo.
define buffer find_code for c-fin-ob .
DEFINE NEW SHARED BUFFER buf_c-fin-liab FOR c-fin-ob .
define temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
index pi is unique primary
f_name.
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int )  FORWARD.
FUNCTION val-abbr-type RETURNS CHARACTER
  ( p-recid as recid  )  FORWARD.
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр записи".
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить строки списка"
     BGCOLOR 8 .
DEFINE BUTTON B-parts
     LABEL "Партии"
     SIZE 10 BY 1 TOOLTIP "Просмотр складского документа"
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "Фильтр"
     SIZE 10 BY 1 TOOLTIP "Фильтрация списка"
     BGCOLOR 8 .
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1 TOOLTIP "Выбор отмеченных или текущей записи"
     BGCOLOR 8 .
DEFINE VARIABLE d-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE loc_payer-name AS CHARACTER FORMAT "X(40)"
     LABEL "Плательщик"
      VIEW-AS TEXT
     SIZE 21.13 BY .67 NO-UNDO.
DEFINE VARIABLE loc_receiver-name AS CHARACTER FORMAT "X(40)"
     LABEL "Получатель"
      VIEW-AS TEXT
     SIZE 21.13 BY .67 NO-UNDO.
DEFINE VARIABLE loc_sum-base AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма б.в."
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE loc_sum-doc AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма док."
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE loc_sum-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма "
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE r-abbr AS CHARACTER FORMAT "X(256)":U INITIAL "РУБ"
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE v-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.88 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
DEFINE new shared QUERY BR-docs FOR
      buf_c-fin-liab SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      c-fin-ob SCROLLING.
DEFINE BROWSE BR-changes
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(25)"
      temp-changes.v_old COLUMn-LABEL "Было" format "X(35)"
      temp-changes.v_new COLUMn-LABEL "Стало" format "X(35)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 90.75 BY 9.67.
DEFINE BROWSE BR-docs
  QUERY BR-docs DISPLAY
     mark-string(recid( buf_c-fin-liab), rid-list)    COLUMN-LABEL '*'  FORMAT "x(1)"
     buf_c-fin-liab.doc-type    COLUMN-LABEL 'Т'  Format "x(1)"
     buf_c-fin-liab.status_    COLUMN-LABEL 'Статус'  Format "x(6)"
     buf_c-fin-liab.prn-doc-code    COLUMN-LABEL '№ док-та'  Format "x(10)"
     substring(string(buf_c-fin-liab.doc-date),1,5)    COLUMN-LABEL 'Создан'  format "x(5)"
     buf_c-fin-liab.fact-date    COLUMN-LABEL 'Закрыт'  format "99/99/99"
     buf_c-fin-liab.contract-code    COLUMN-LABEL 'Договор'
     buf_c-fin-liab.receiver-type + " " + string(buf_c-fin-liab.receiver-code)    COLUMN-LABEL 'Получатель'  Format "x(10)"
     buf_c-fin-liab.payer-type + " " + string(buf_c-fin-liab.payer-code)    COLUMN-LABEL 'Плательщик'  Format "x(10)"
     buf_c-fin-liab.pay-date    COLUMN-LABEL 'Платеж'  format "99/99/99"
     val-abbr-type(recid( buf_c-fin-liab))   COLUMN-LABEL 'Вал' Format "x(3)"
     buf_c-fin-liab.sum-doc   COLUMN-LABEL 'Сумма в валюте док-та'
     buf_c-fin-liab.doc-code   COLUMN-LABEL 'Внутр.№' Format "99999999"
     buf_c-fin-liab.corr-date   COLUMN-LABEL 'Дата изменения'
     buf_c-fin-liab.corr-doc-code   COLUMN-LABEL 'Документ изменения'
     string(buf_c-fin-liab.corr-time,'hh:mm:ss')   COLUMN-LABEL 'Время изменения '  LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
     buf_c-fin-liab.corr-user-db-num   COLUMN-LABEL 'Изменение с БД №'  format ">>>>9" LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
     buf_c-fin-liab.corr-user-name   COLUMN-LABEL 'Изменил' LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
      usrfulnf(buf_c-fin-liab.corr-user-name) COLUMN-LABEL "Кто изменил!ФИО" Format "x(15)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
      buf_c-fin-liab.chip-num
      buf_c-fin-liab.sum-base
      buf_c-fin-liab.sum-rubl
      buf_c-fin-liab.sum-contract
      buf_c-fin-liab.con-stat
      buf_c-fin-liab.con-sum-base
      buf_c-fin-liab.con-sum-rubl
      buf_c-fin-liab.con-sum-base
      buf_c-fin-liab.con-sum-rubl
      buf_c-fin-liab.con-sum-contr
      buf_c-fin-liab.contract-curr     COLUMN-LABEL  "вал.договора"
      buf_c-fin-liab.contract-rate     COLUMN-LABEL  "вал.дог м"
      buf_c-fin-liab.contract-scale    COLUMN-LABEL  "вал.дог ш"
      buf_c-fin-liab.base-rate         COLUMN-LABEL  "баз.вал. м"
      buf_c-fin-liab.base-scale        COLUMN-LABEL  "баз.вал. ш"
      buf_c-fin-liab.curr-code         COLUMN-LABEL  "вал.платежа"
      buf_c-fin-liab.exch-rate         COLUMN-LABEL  "баз.пл. м"
      buf_c-fin-liab.exch-scale        COLUMN-LABEL  "баз.пл. ш"
      buf_c-fin-liab.corr-doc
      buf_c-fin-liab.is-back-date
      buf_c-fin-liab.is-corr
      buf_c-fin-liab.is-del
      buf_c-fin-liab.is-doc-del
     enable buf_c-fin-liab.doc-type
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 90 BY 8.92.
DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11.5
     B-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 31.13
     B-sch AT ROW 1 COL 41.25
     B-parts AT ROW 1 COL 51.25
     B-Help AT ROW 1 COL 81.5
     BR-docs AT ROW 2.21 COL 1.25
     BR-changes AT ROW 13.92 COL 1
     mark-num AT ROW 1 COL 14.88 NO-LABEL
     loc_receiver-name AT ROW 11.21 COL 2.88
     loc_sum-doc AT ROW 11.21 COL 50 COLON-ALIGNED
     d-abbr AT ROW 11.21 COL 64.63 COLON-ALIGNED NO-LABEL
     loc_payer-name AT ROW 12.04 COL 2.88
     loc_sum-rubl AT ROW 12.04 COL 49.88 COLON-ALIGNED
     r-abbr AT ROW 12.04 COL 64.63 COLON-ALIGNED NO-LABEL
     loc_sum-base AT ROW 12.88 COL 50 COLON-ALIGNED
     v-abbr AT ROW 12.88 COL 64.63 COLON-ALIGNED NO-LABEL
     SPACE(21.24) SKIP(10.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Финансовые обязательства"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-parts:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       BR-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 4.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
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
    if available buf_c-fin-liab then do:
        rr = recid( buf_c-fin-liab ).
        p-doc-type = buf_c-fin-liab.doc-type .
        p-status_  = buf_c-fin-liab.status_  .
        run str/fi-liabi.w
        ( input parparentproc ,
          input 'ПРОСМОТР':U ,
          input-output rr ,
          input par-host-code  ,
          input p-doc-type,
          input p-status_
          ).
     end.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
      if available buf_c-fin-liab then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid15 as character no-undo .
define variable v-num-entry15 as integer   no-undo .
assign
  v-str-recid15 = trim( string( recid( buf_c-fin-liab ) , "->>>>>>>>>>>9":U ) )
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
    run str/fi-parts.w
      ( input parParentProc ,
        input buf_c-fin-liab.doc-code ,
        input par-host-code  ) .
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if not available buf_c-fin-liab then run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
    if ( available buf_c-fin-liab ) AND ( rid-list = "" ) then
    rid-list = string( recid( buf_c-fin-liab ) ) .
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
        apply "choose" to b-lookup in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
if available buf_c-fin-liab then do:
assign
    loc_receiver-name  = buf_c-fin-liab.receiver-name
    loc_payer-name  = buf_c-fin-liab.payer-name
    loc_sum-base  = buf_c-fin-liab.sum-base
    loc_sum-doc   = buf_c-fin-liab.sum-doc
    loc_sum-rubl  = buf_c-fin-liab.sum-rubl
    d-abbr        = sel-abbr(buf_c-fin-liab.curr-code)
    v-abbr        = sel-abbr(p-base-code)
    .
end.
else
 assign
   loc_receiver-name  = ""
   loc_payer-name  = ""
   loc_sum-base  = 0
   loc_sum-doc   = 0
   loc_sum-rubl  = 0
   d-abbr = ""
    .
  display
  loc_receiver-name loc_payer-name loc_sum-base loc_sum-doc loc_sum-rubl
  r-abbr v-abbr  d-abbr
  with frame Dialog-Frame.
  run proc-view-changes in this-procedure no-error.
END.
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      message vss-include-info16 skip
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
      message vss-include-info16 skip
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-changes :handle
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numBR-changes as INT EXTENT 13 no-undo.
DEF VAR varmviBR-changes       as INT no-undo.
DEF VAR varmvjBR-changes       as INT no-undo.
DEF VAR varmvkBR-changes       as INT no-undo.
DEF VAR varmvlBR-changes       as INT no-undo.
DEF VAR move-elementBR-changes as INT no-undo.
def var jjBR-changes           as int no-undo.
do varmviBR-changes = 1 to EXTENT(cur-clmn-numBR-changes):
  ASSIGN cur-clmn-numBR-changes[varmviBR-changes] = varmviBR-changes.
END.
RUN start-mv-clmnBR-changes.
PROCEDURE start-mv-clmnBR-changes:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE BR-changes do:
  RUN re-move-clmnBR-changes ( 4, 13).
END.
ON ctrl-cursor-left OF BROWSE BR-changes do:
  RUN re-move-clmnBR-changes (13, 4).
END.
PROCEDURE re-move-clmnBR-changes:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmviBR-changes = 1 TO EXTENT(cur-clmn-numBR-changes):
    if cur-clmn-numBR-changes[varmviBR-changes] = source-column THEN cur-clmn-numBR-changes[varmviBR-changes] = -1.
  END.
  if BR-changes:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjBR-changes = source-column - 1 to target-column BY -1:
    DO varmviBR-changes = 1 TO EXTENT(cur-clmn-numBR-changes):
        if cur-clmn-numBR-changes[varmviBR-changes] = varmvjBR-changes THEN DO:
          cur-clmn-numBR-changes[varmviBR-changes] = cur-clmn-numBR-changes[varmviBR-changes] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjBR-changes = source-column + 1 to target-column:
    DO varmviBR-changes = 1 TO EXTENT(cur-clmn-numBR-changes):
      if cur-clmn-numBR-changes[varmviBR-changes] = varmvjBR-changes THEN DO:
        cur-clmn-numBR-changes[varmviBR-changes] = cur-clmn-numBR-changes[varmviBR-changes] - 1.
      END.
    END.
  END.
  DO varmviBR-changes = 1 TO EXTENT(cur-clmn-numBR-changes):
    if cur-clmn-numBR-changes[varmviBR-changes] = -1 THEN cur-clmn-numBR-changes[varmviBR-changes] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnBR-changes:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmviBR-changes = 1 TO EXTENT(cur-clmn-numBR-changes):
    if cur-clmn-numBR-changes[varmviBR-changes] = cur-clmn-loc THEN move-elementBR-changes = varmviBR-changes.
  END.
  RUN re-move-clmnBR-changes (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultBR-changes:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlBR-changes = 4 to EXTENT(cur-clmn-numBR-changes):
    RUN re-move-clmnBR-changes (cur-clmn-numBR-changes[varmvlBR-changes], varmvlBR-changes).
  END.
  RUN start-mv-clmnBR-changes.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelBR-changes   as character no-undo .
def var sort-clmnBR-changes    as handle    no-undo .
def var cur-clmnBR-changes     as handle    no-undo .
def var cur-clmn-locBR-changes as integer   no-undo .
def var re-queryBR-changes     as logical   initial no no-undo .
on start-search, ctrl-o of BR-changes in frame Dialog-Frame do:
   run sort-brBR-changes
     (input (if available c-fin-ob
             then recid(c-fin-ob)
             else ?
            )
     ).
end.
PROCEDURE sort-brBR-changes :
  define input parameter p-recid as recid no-undo .
  if re-queryBR-changes = no then do:
    assign
       cur-clmnBR-changes = BR-changes:current-column in frame Dialog-Frame
    .
    if sort-clmnBR-changes <> ? then sort-clmnBR-changes:column-fgcolor = 0.
    if cur-clmnBR-changes = sort-clmnBR-changes then do:
      assign
         sort-labelBR-changes = ""
         sort-clmnBR-changes = ?
      .
     end.
     else do:
       assign
         sort-labelBR-changes = cur-clmnBR-changes:label
         sort-clmnBR-changes  = cur-clmnBR-changes
         sort-clmnBR-changes:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBR-changes = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BR-changes:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBR-changes then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBR-changes = cur-clmn-locBR-changes + 1
    .
  end.
  case sort-labelBR-changes:
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(buf_c-fin-liab), &1&2&1)', chr(34), rid-list)     .     run OpenBr (yes, no, '':U).   . END.
        when 'Т'  then DO:    assign       sort-column-name = "buf_c-fin-liab.doc-type"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Статус'  then DO:    assign       sort-column-name = "buf_c-fin-liab.status_"     .     run OpenBr (yes, no, '':U).   . END.
        when '№ док-та'  then DO:    assign       sort-column-name = "buf_c-fin-liab.prn-doc-code"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Создан'  then DO:    assign       sort-column-name = "substring(string(buf_c-fin-liab.doc-date),1,5)"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Закрыт'  then DO:    assign       sort-column-name = "buf_c-fin-liab.fact-date"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Договор'  then DO:    assign       sort-column-name = "buf_c-fin-liab.contract-code"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Получатель'  then DO:    assign       sort-column-name = "buf_c-fin-liab.receiver-type + "     .     run OpenBr (yes, no, '':U).   . END.
        when 'Плательщик'  then DO:    assign       sort-column-name = "buf_c-fin-liab.payer-type + "     .     run OpenBr (yes, no, '':U).   . END.
        when 'Платеж'  then DO:    assign       sort-column-name = "buf_c-fin-liab.pay-date"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Вал'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1val-abbr-type&1, recid(buf_c-fin-liab))', chr(34))     .     run OpenBr (yes, no, '':U).   . END.
        when 'Сумма в валюте док-та'  then DO:    assign       sort-column-name = "buf_c-fin-liab.sum-doc"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Внутр.№'  then DO:    assign       sort-column-name = "buf_c-fin-liab.doc-code"     .     run OpenBr (yes, no, '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr (yes, no, '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultBR-changes') then do:
          run mv-brw-defaultBR-changes.
        end.
      if sort-labelBR-changes <> "" then do:
        assign
          cur-clmnBR-changes:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBR-changes = ?
      .
    end.
  end case.
    if cur-clmn-locBR-changes <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnBR-changes') then do:
        run ch-clmnBR-changes in this-procedure (cur-clmn-locBR-changes).
      end.
    end.
  if p-recid <> ? then do:
    reposition BR-changes to recid p-recid no-error.
    apply "value-changed" to BR-changes in frame Dialog-Frame.
  end.
  apply "entry" to BR-changes in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBR-changes:
if cur-clmnBR-changes = ? then do:
   run OpenBr (yes, no, '':U).
end.
else do:
   assign re-queryBR-changes = yes.
   run sort-brBR-changes
     (input (if available c-fin-ob
             then recid(c-fin-ob)
             else ?
            )
     ).
   assign re-queryBR-changes = no.
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
buf_c-fin-liab.doc-type:read-only in browse br-docs = true .
loc_sum-rubl:LABEL = "Сумма руб." .
define variable p-file-label as character no-undo .
p-file-label =  "Финансовые обязательства - история".
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
    otherwise do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - par-mode=" par-mode
      view-as alert-box ERROR.
      return.
    end.
  end CASE.
  run my-enable_ui.
  run openbr (yes, no, '':u).
  hide mark-num in frame Dialog-Frame .
  apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
  wait-for go of frame Dialog-Frame.
END.
run disable_ui.
PROCEDURE add-proc :
define variable v-doc-rec as recid no-undo .
if  p-doc-type = ?   then do:
  message  "Добавление финансовых обязательств возможно только  по типам !" view-as alert-box information .
  return .
end.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run str/fi-liabi.w
    ( input parparentproc,
      input 'ДОБАВЛЕНИЕ':U ,
      input-output rr ,
      input par-host-code  ,
      input p-doc-type,
      input p-status_
      ).
  v-doc-rec = rr .
  run openbr (yes, no, '':u).
  reposition br-docs to recid v-doc-rec no-error .
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH c-fin-ob SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY mark-num loc_receiver-name loc_sum-doc d-abbr loc_payer-name
          loc_sum-rubl r-abbr loc_sum-base v-abbr
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-mark B-sel B-Help BR-docs BR-changes mark-num
         loc_receiver-name loc_sum-doc d-abbr loc_payer-name loc_sum-rubl
         r-abbr loc_sum-base v-abbr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-docs FOR EACH buf_c-fin-liab no-lock.
END PROCEDURE.
PROCEDURE my-enable_UI :
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  par-host-code
  ,output p-base-code
  )  .
DISPLAY   mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel
         B-sch
         B-Help
         b-sel       when LOOKUP("b-sel":U,  bttns) > 0
         b-mark      when LOOKUP("b-mark":U, bttns) > 0
         BR-docs   mark-num
         BR-changes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
def var l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = caps(p-file-label) + chr(32).
def var sort-column-phrase as character no-undo .
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
       ASSIGN frame Dialog-Frame:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + " Код фирмы " +  string(par-host-code).
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-26  as logical   no-undo .
define variable  l-filter-open-26    as logical   .
define variable  flt-rec-26       as recid     no-undo .
define variable  filter-name-26      as character no-undo .
define variable  where-phrase-26     as character no-undo .
define variable  sort-phrase-26      as character no-undo .
define variable  where-phrase-rus-26 as character no-undo .
define variable  sort-phrase-rus-26  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-26
  ,output filter-name-26
  ,output where-phrase-26
  ,output sort-phrase-26
  ,output where-phrase-rus-26
  ,output sort-phrase-rus-26
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-26
      ) no-error .
  assign
    l-filter-open-26 = false
  .
  if flt-rec-26 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-26 as character no-undo .
    define variable  parameter-3-26 as character no-undo .
    define variable  parameter-4-26 as character no-undo .
    define variable  parameter-5-26 as character no-undo .
    define variable  parameter-6-26 as character no-undo .
    define variable  parameter-7-26 as character no-undo .
      assign
      parameter-3-26 =
                              "FOR EACH buf_c-fin-liab"
      parameter-4-26 =
        (
          if (" buf_c-fin-liab.doc-code = par-doc-code and  buf_c-fin-liab.host-code =  par-host-code  " + " " + where-phrase-26) <> ""
          then   substitute(' buf_c-fin-liab.host-code = &2  and  buf_c-fin-liab.doc-code = &1&3&1'                            , chr(34) , par-host-code , par-doc-code )  + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + "")
      parameter-6-26 = if sort-phrase-26 = ''
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
        " " + sort-phrase-26
        )
      parameter-7-26 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-26 =
          (" buf_c-fin-liab.doc-code = par-doc-code and  buf_c-fin-liab.host-code =  par-host-code  " + " " + where-phrase-26 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-26
                          ,input parameter-4-26
                          ,input parameter-5-26
                          ,input parameter-6-26
                          ,input parameter-7-26
                          )
      .
      assign
        l-filter-open-26 = true
      .
    end.
    if l-filter-open-26 = false then do:
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
  if l-filter-open-26 = false then do:
    OPEN QUERY br-docs FOR EACH buf_c-fin-liab
      where  buf_c-fin-liab.doc-code = par-doc-code and  buf_c-fin-liab.host-code =  par-host-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_c-fin-liab )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer buf_c-fin-liab:handle) then do:
      assign
      parameter-2-26 = (if p-find-next then "true":u else "false":u )
      parameter-4-26 =
        "where ":u +   substitute(' buf_c-fin-liab.host-code = &2  and  buf_c-fin-liab.doc-code = &1&3&1'                            , chr(34) , par-host-code , par-doc-code )  + " ":u + where-phrase-26 + " ":u + p-find-condition + " " + ""
      parameter-5-26 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(buf_c-fin-liab)
                          ,input logical(parameter-2-26)
                          ,input no-lock
                          ,input (buffer buf_c-fin-liab:handle)
                          ,input parameter-4-26
                          ,input parameter-5-26
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-26 = (if p-find-next then "true":u else "false":u )
      parameter-3-26 =  "FOR EACH buf_c-fin-liab"
      parameter-4-26 =
        (
          if (" buf_c-fin-liab.doc-code = par-doc-code and  buf_c-fin-liab.host-code =  par-host-code  " + " " + where-phrase-26) <> ""
          then   substitute(' buf_c-fin-liab.host-code = &2  and  buf_c-fin-liab.doc-code = &1&3&1'                            , chr(34) , par-host-code , par-doc-code )  + " " + where-phrase-26
          else "true"
        )
      parameter-5-26 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-26 = if sort-phrase-26 = ''
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
        " " + sort-phrase-26
        )
      parameter-7-26 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input logical(parameter-2-26)
                          ,input no-lock
                          ,input parameter-3-26
                          ,input parameter-4-26
                          ,input parameter-5-26
                          ,input parameter-6-26
                          ,input parameter-7-26
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
    END.
END CASE.
if not p-open-query then
REPOSITION br-docs to recid doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
APPLY "VALUE-CHANGED" TO br-docs in frame Dialog-Frame.
APPLY "ENTRY" TO br-docs.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'c-fin-ob'
  join-tbl = 'buf_c-fin-liab'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Внутр.№', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prn-doc-code', '№ документа ', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Код фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('curr-code', 'Код валюты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Закрыт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-date', 'Дата Платежа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('trn-doc-code', 'Накладная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-doc', 'Создал', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name-fact', 'Закрыл на факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('payer-type*payer-code', 'Плательщик', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('receiver-type*receiver-code', 'Получатель', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-doc', 'Корр ФО', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run openbr (yes, no, '':u).
END.
END PROCEDURE.
PROCEDURE proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
assign
  pardoc-code = chr(34) + pardoc-code + chr(34) .
run OpenBr in this-procedure
    (input false
    ,input par-next
    ,input substitute("and buf_c-fin-liab.prn-doc-code = &1 "
      , pardoc-code)
    ).
END PROCEDURE.
PROCEDURE proc-view-changes :
define buffer new_c-fin-ob for ub.c-fin-ob.
define buffer current_fin-ob for ub.fin-ob.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
for each temp-changes:
    delete temp-changes.
END.
if not available buf_c-fin-liab then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
find first new_c-fin-ob no-lock where
            new_c-fin-ob.host-code = buf_c-fin-liab.host-code
       AND new_c-fin-ob.doc-code  = buf_c-fin-liab.doc-code
       AND new_c-fin-ob.chip-num  > buf_c-fin-liab.chip-num no-error.
if not available new_c-fin-ob then do:
    find first current_fin-ob no-lock where
               current_fin-ob.host-code = buf_c-fin-liab.host-code
           AND current_fin-ob.doc-code  = buf_c-fin-liab.doc-code no-error.
         if not available current_fin-ob then do:
         return error.
    end.
    buffer-compare current_fin-ob to buf_c-fin-liab
    save result in v-chg-fields.
end.
else do:
    buffer-compare new_c-fin-ob except chip-num corr-date corr-user-name corr-user-db-num to buf_c-fin-liab
    save result in v-chg-fields.
end.
define variable v-nn as integer   no-undo .
v-nn = num-entries(v-chg-fields) .
do ii = 1 to v-nn :
CASE entry(ii, v-chg-fields):
when "base-rate":U then do:     create temp-changes.     assign     temp-changes.f_name = "base-rate":U     temp-changes.l_name = "м-б баз.ва."     temp-changes.v_old = string(buf_c-fin-liab.base-rate)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.base-rate)                               else string(current_fin-ob.base-rate))     .   end.
when "base-scale":U then do:     create temp-changes.     assign     temp-changes.f_name = "base-scale":U     temp-changes.l_name = "шкала баз.вал."     temp-changes.v_old = string(buf_c-fin-liab.base-scale)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.base-scale)                               else string(current_fin-ob.base-scale))     .   end.
when "receiver-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "receiver-code":U     temp-changes.l_name = "Код получателя"     temp-changes.v_old = string(buf_c-fin-liab.receiver-code)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.receiver-code)                               else string(current_fin-ob.receiver-code))     .   end.
when "receiver-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "receiver-name":U     temp-changes.l_name = "Наименование получателя"     temp-changes.v_old = string(buf_c-fin-liab.receiver-name)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.receiver-name)                               else string(current_fin-ob.receiver-name))     .   end.
when "receiver-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "receiver-type":U     temp-changes.l_name = "Тип получателя"     temp-changes.v_old = string(buf_c-fin-liab.receiver-type)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.receiver-type)                               else string(current_fin-ob.receiver-type))     .   end.
when "contract-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "contract-code":U     temp-changes.l_name = "Номер договора"     temp-changes.v_old = string(buf_c-fin-liab.contract-code)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.contract-code)                               else string(current_fin-ob.contract-code))     .   end.
when "curr-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "curr-code":U     temp-changes.l_name = "Код валюты"     temp-changes.v_old = string(buf_c-fin-liab.curr-code)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.curr-code)                               else string(current_fin-ob.curr-code))     .   end.
when "doc-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "doc-code":U     temp-changes.l_name = "вн Номер фин.об."     temp-changes.v_old = string(buf_c-fin-liab.doc-code)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.doc-code)                               else string(current_fin-ob.doc-code))     .   end.
when "doc-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "doc-date":U     temp-changes.l_name = "Дата создания"     temp-changes.v_old = string(buf_c-fin-liab.doc-date)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.doc-date)                               else string(current_fin-ob.doc-date))     .   end.
when "doc-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "doc-type":U     temp-changes.l_name = "Тип фин.обяз-ва."     temp-changes.v_old = string(buf_c-fin-liab.doc-type)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.doc-type)                               else string(current_fin-ob.doc-type))     .   end.
when "exch-rate":U then do:     create temp-changes.     assign     temp-changes.f_name = "exch-rate":U     temp-changes.l_name = "м-б валюты платежа"     temp-changes.v_old = string(buf_c-fin-liab.exch-rate)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.exch-rate)                               else string(current_fin-ob.exch-rate))     .   end.
when "exch-scale":U then do:     create temp-changes.     assign     temp-changes.f_name = "exch-scale":U     temp-changes.l_name = "шкала валюты платежа"     temp-changes.v_old = string(buf_c-fin-liab.exch-scale)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.exch-scale)                               else string(current_fin-ob.exch-scale))     .   end.
when "fact-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-date":U     temp-changes.l_name = "Дата факт"     temp-changes.v_old = string(buf_c-fin-liab.fact-date)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.fact-date)                               else string(current_fin-ob.fact-date))     .   end.
when "fact-order":U then do:     create temp-changes.     assign     temp-changes.f_name = "fact-order":U     temp-changes.l_name = "факт-ордер"     temp-changes.v_old = string(buf_c-fin-liab.fact-order)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.fact-order)                               else string(current_fin-ob.fact-order))     .   end.
when "host-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "host-code":U     temp-changes.l_name = "Код фирмы"     temp-changes.v_old = string(buf_c-fin-liab.host-code)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.host-code)                               else string(current_fin-ob.host-code))     .   end.
when "payer-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "payer-code":U     temp-changes.l_name = "Код плательщика"     temp-changes.v_old = string(buf_c-fin-liab.payer-code)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.payer-code)                               else string(current_fin-ob.payer-code))     .   end.
when "payer-name":U then do:     create temp-changes.     assign     temp-changes.f_name = "payer-name":U     temp-changes.l_name = "Наименование плательщика"     temp-changes.v_old = string(buf_c-fin-liab.payer-name)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.payer-name)                               else string(current_fin-ob.payer-name))     .   end.
when "payer-type":U then do:     create temp-changes.     assign     temp-changes.f_name = "payer-type":U     temp-changes.l_name = "Тип плательщика"     temp-changes.v_old = string(buf_c-fin-liab.payer-type)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.payer-type)                               else string(current_fin-ob.payer-type))     .   end.
when "pay-date":U then do:     create temp-changes.     assign     temp-changes.f_name = "pay-date":U     temp-changes.l_name = "Дата платежа"     temp-changes.v_old = string(buf_c-fin-liab.pay-date)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.pay-date)                               else string(current_fin-ob.pay-date))     .   end.
when "prn-doc-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "prn-doc-code":U     temp-changes.l_name = "Номер фин.обяз"     temp-changes.v_old = string(buf_c-fin-liab.prn-doc-code)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.prn-doc-code)                               else string(current_fin-ob.prn-doc-code))     .   end.
when "status_":U then do:     create temp-changes.     assign     temp-changes.f_name = "status_":U     temp-changes.l_name = "Статус"     temp-changes.v_old = string(buf_c-fin-liab.status_)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.status_)                               else string(current_fin-ob.status_))     .   end.
when "sum-base-orig":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-base-orig":U     temp-changes.l_name = "Сумма в б.в. начальная"     temp-changes.v_old = string(buf_c-fin-liab.sum-base-orig)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.sum-base-orig)                               else string(current_fin-ob.sum-base-orig))     .   end.
when "sum-rubl-orig":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-rubl-orig":U     temp-changes.l_name = "Сумма в руб. начальная"     temp-changes.v_old = string(buf_c-fin-liab.sum-rubl-orig)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.sum-rubl-orig)                               else string(current_fin-ob.sum-rubl-orig))     .   end.
when "sum-doc-orig":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-doc-orig":U     temp-changes.l_name = "Сумма в в.д. начальная"     temp-changes.v_old = string(buf_c-fin-liab.sum-doc-orig)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.sum-doc-orig)                               else string(current_fin-ob.sum-doc-orig))     .   end.
when "sum-base":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-base":U     temp-changes.l_name = "Сумма в б.в. "     temp-changes.v_old = string(buf_c-fin-liab.sum-base)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.sum-base)                               else string(current_fin-ob.sum-base))     .   end.
when "sum-doc":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-doc":U     temp-changes.l_name = "Сумма в в.д."     temp-changes.v_old = string(buf_c-fin-liab.sum-doc)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.sum-doc)                               else string(current_fin-ob.sum-doc))     .   end.
when "sum-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-rubl":U     temp-changes.l_name = "Сумма в руб."     temp-changes.v_old = string(buf_c-fin-liab.sum-rubl)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.sum-rubl)                               else string(current_fin-ob.sum-rubl))     .   end.
when "sum-contract":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-contract":U     temp-changes.l_name = "Сумма в в.дог."     temp-changes.v_old = string(buf_c-fin-liab.sum-contract)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.sum-contract)                               else string(current_fin-ob.sum-contract))     .   end.
when "sum-tax-doc":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-tax-doc":U     temp-changes.l_name = "Сумма налогов в в.д."     temp-changes.v_old = string(buf_c-fin-liab.sum-tax-doc)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.sum-tax-doc)                               else string(current_fin-ob.sum-tax-doc))     .   end.
when "sum-tax-base":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-tax-base":U     temp-changes.l_name = "Сумма налогов в б.в. "     temp-changes.v_old = string(buf_c-fin-liab.sum-tax-base)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.sum-tax-base)                               else string(current_fin-ob.sum-tax-base))     .   end.
when "sum-tax-rubl":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-tax-rubl":U     temp-changes.l_name = "Сумма налога в руб."     temp-changes.v_old = string(buf_c-fin-liab.sum-tax-rubl)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.sum-tax-rubl)                               else string(current_fin-ob.sum-tax-rubl))     .   end.
when "sum-tax-contract":U then do:     create temp-changes.     assign     temp-changes.f_name = "sum-tax-contract":U     temp-changes.l_name = "Сумма налога в в.дог."     temp-changes.v_old = string(buf_c-fin-liab.sum-tax-contract)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.sum-tax-contract)                               else string(current_fin-ob.sum-tax-contract))     .   end.
when "corr-doc":U then do:     create temp-changes.     assign     temp-changes.f_name = "corr-doc":U     temp-changes.l_name = "Корр ФО"     temp-changes.v_old = string(buf_c-fin-liab.corr-doc)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.corr-doc)                               else string(current_fin-ob.corr-doc))     .   end.
when "trn-doc-code":U then do:     create temp-changes.     assign     temp-changes.f_name = "trn-doc-code":U     temp-changes.l_name = "№ складского документа"     temp-changes.v_old = string(buf_c-fin-liab.trn-doc-code)     temp-changes.v_new = (if available new_c-fin-ob                               then string(new_c-fin-ob.trn-doc-code)                               else string(current_fin-ob.trn-doc-code))     .   end.
END CASE.
end.
Open QUery br-changes for each temp-changes.
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
