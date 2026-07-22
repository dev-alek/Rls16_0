DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_dis-card FOR ub.dis-card.
DEFINE BUFFER buf_icnt-doc FOR ub.icnt-doc.
DEFINE BUFFER buf_inkas    FOR ub.inkas.
DEFINE BUFFER buf_obj      FOR ub.clients.
DEFINE BUFFER buf_shop     FOR ub.shop.
DEFINE BUFFER buf_trn-doc  FOR ub.trn-doc.
DEFINE BUFFER c-doc        FOR ub.chk-doc.
DEFINE BUFFER dis-obj      FOR ub.dis-obj.
DEFINE BUFFER find_chk-doc FOR ub.chk-doc.
DEFINE BUFFER find_inkas   FOR ub.inkas.
DEFINE BUFFER find_trn-doc FOR ub.trn-doc.
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
define input parameter par-mode  as char   no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parout-code like ub.chk-doc.out-code no-undo.
define input parameter pard-card like ub.chk-doc.d-card no-undo.
define input parameter p-start-date like ub.chk-doc.chk-date no-undo .
define input parameter p-end-date like ub.chk-doc.chk-date no-undo .
define output param rid-list    as  char no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Таблица пересменки по кассе":U.
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable filter-label       as character no-undo init "Таблица пересменки по кассе" .
define variable filter-label0      as character no-undo init "Таблица пересменки по кассе" .
define variable filter-point0      as character no-undo init 'чеки':U .
define variable filter-point       as character no-undo init 'чеки':U .
define variable sort-column-name   as character no-undo .
define variable print-type         as character no-undo.
define variable del-type           as character no-undo.
define variable deleted            as logical   no-undo init no.
DEFINE VARIABLE change-type        as character init "" no-undo .
define variable chk-spfc           as logical   init no no-undo.
define variable cas-shft           as logical   no-undo init no.
define variable l-shift-on         as logical   no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b         as character no-undo .
define variable v-rep-rec          as recid     no-undo .
define variable v-print-host-code  like ub.sysconf.host-code no-undo.
define buffer buf_cli      for ub.clients.
define buffer out_inkas    for ub.inkas .
define buffer buf_currency for ub.currency.
define variable v-base-code    like ub.currency.curr-code no-undo .
define variable v-base-type    like ub.currency.curr-abbr no-undo .
define variable v-doc-rec      as recid     no-undo .
define variable p-chk-type     like ub.chk-doc.chk-type no-undo .
DEFINE VARIABLE v-chk-autotank AS CHARACTER NO-UNDO .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable paycardv as character no-undo .
FUNCTION f-paycardv RETURNS CHARACTER(input p-pay-card as character, p-cash-pay-obj-code as integer, p-cash-pay-curr-code as integer):
define variable kk as integer no-undo .
define variable pay-card-num as character no-undo .
define buffer buf_cash-pay for ub.cash-pay.
find first buf_cash-pay no-lock where
           buf_cash-pay.cdpay-code = p-cash-pay-obj-code
       AND buf_cash-pay.curr-code = p-cash-pay-curr-code no-error .
if not avail buf_cash-pay then return "":U.
if p-pay-card = "":u
or p-pay-card = ? then return "":U.
assign
pay-card-num = "":U
.
_kk:
do kk = 1 to num-entries(buf_cash-pay.pay-card-view):
  if p-pay-card begins entry(kk, buf_cash-pay.pay-card-view) then do:
    assign
    pay-card-num = p-pay-card
    .
    return pay-card-num.
  end.
end.
if pay-card-num = "":u then do:
  if length(p-pay-card) > 4 then
  assign
  pay-card-num = fill("*":U, length(p-pay-card) - 4) +
                  substr(p-pay-card, (length(p-pay-card) - 3), 4)
  .
  else
  return fill("*":U, length(p-pay-card)).
end.
return pay-card-num.
END FUNCTION.
def temp-table gds-bar no-undo
   field b-code like bar-code.b-code
   field qnty   as decimal
   index art is unique b-code .
define temp-table temp-pay no-undo like ub.chk-pay
   index pi is unique primary pay-code curr-code
   .
DEFINE MENU m-print
   MENU-ITEM m-list         LABEL "Список чеков"
   .
DEFINE BUTTON B-Help
   LABEL "Помо&щь"
   SIZE 3 BY 1
   BGCOLOR 8 .
DEFINE BUTTON B-print
   LABEL "Пе&чать"
   SIZE 3 BY 1 TOOLTIP "Печать списка чеков ...".
DEFINE BUTTON b-quit AUTO-END-KEY
   LABEL "&Выход"
   SIZE 10 BY 1
   BGCOLOR 8 .
DEFINE BUTTON B-sch
   LABEL "&Фильтр"
   SIZE 3 BY 1 TOOLTIP "Установка фильтра на список чеков".
DEFINE BUTTON b-sel AUTO-GO
   LABEL "Вы&бор"
   SIZE 10 BY 1
   BGCOLOR 8 .
DEFINE VARIABLE Cb-chk-type AS CHARACTER FORMAT "X(256)":U
   VIEW-AS COMBO-BOX INNER-LINES 10
   LIST-ITEM-PAIRS "Все",0,"Закрытие",13,"Открытие",40
   DROP-DOWN-LIST
   SIZE 19 BY 1
   BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE ED-notes    AS CHARACTER
   VIEW-AS EDITOR SCROLLBAR-VERTICAL
   SIZE 98 BY 2
   BGCOLOR 8 FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE mark-num    AS CHARACTER FORMAT "X(256)":U
   VIEW-AS TEXT
   SIZE 6 BY 1
   FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE sch-code    AS CHARACTER FORMAT "X(20)":U
   LABEL "номер"
   VIEW-AS FILL-IN
   SIZE 19.13 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-date    AS DATE      FORMAT "99/99/9999":U
   LABEL "дата"
   VIEW-AS FILL-IN
   SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE QUERY BR-docs FOR c-doc SCROLLING.
DEFINE BROWSE BR-docs
   QUERY BR-docs DISPLAY
   c-doc.pay-desk FORMAT ">>>9"  COLUMN-LABEL "Номер!АРМ Кассира":U
   c-doc.obj-code FORMAT ">>>>9" COLUMN-LABEL "Номер!магазина":U
   shift-name-no-err(buffer c-doc) COLUMN-LABEL "№ смены" FORMAT "X(6)":U
   c-doc.chk-date FORMAT "99/99/9999" COLUMN-LABEL "Дата чека на!АРМ Кассира":U
   (string (c-doc.chk-time, "HH:MM")) COLUMN-LABEL "Время чека на!АРМ Кассира":U
   c-doc.chk-num FORMAT "->>>>>>>>9" COLUMN-LABEL "№ чека!на АРМ Кассира":U
      entry (lookup (string(c-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U) COLUMN-LABEL "Тип_чека" FORMAT "X(45)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.67 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
   b-quit AT ROW 1 COL 1
   B-print AT ROW 1 COL 89
   B-sch AT ROW 1 COL 92
   B-Help AT ROW 1 COL 95
   Cb-chk-type AT ROW 2 COL 1 NO-LABEL
   BR-docs AT ROW 2.67 COL 1
   ED-notes AT ROW 18.67 COL 1 NO-LABEL
   sch-code AT ROW 20.79 COL 17.63 COLON-ALIGNED
   sch-date AT ROW 20.83 COL 48.25 COLON-ALIGNED
   mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
   "ПОИСК ПО" VIEW-AS TEXT
   SIZE 9.25 BY 1 AT ROW 20.79 COL 1.5
   FGCOLOR 4
   SPACE(88.62) SKIP(0.20)
   WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
   SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
   TITLE ""
   CANCEL-BUTTON b-quit.
ASSIGN
   FRAME Dialog-Frame:SCROLLABLE = FALSE
   FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
   B-print:POPUP-MENU IN FRAME Dialog-Frame = MENU m-print:HANDLE.
ON ENDKEY OF FRAME Dialog-Frame
   DO:
      if deleted then return "deleted".
   END.
ON GO OF FRAME Dialog-Frame
   DO:
      APPLY "LEAVE" to ED-notes.
      if deleted then return "deleted".
   END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
   DO:
      APPLY "END-ERROR":U TO SELF.
   END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
   DO:
      define variable v-doc-rec as recid   no-undo .
      define variable glog      as logical no-undo .
      define buffer s-doc for trn-doc.
      if NOT available c-doc then
      do:
         return no-apply.
      end.
      if print-type = "" then
      do:
         run gbl/pop-up.p ( input self:handle, input no) no-error.
      end.
      if print-type = "list":U or print-type = "gds":U or print-type = "pay":U or print-type = "gds-list":U   then
      do:
         if par-mode = 'объект':U and index(frame Dialog-Frame:title,"ФИЛЬТР" ) = 0 then
         do:
            CASE print-type:
               when "list":U then
                  do:
                     message "Вы хотите напечатать весь список чеков по объекту при невключенном фильтре!" skip
                        "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
                        WARNING buttons YES-NO update glog.
                     if NOT glog then return no-apply.
                  end.
               when "gds":U then
                  do:
                     message "Вы хотите напечатать строки всего списка чеков по объекту при невключенном фильтре!" skip
                        "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
                        WARNING buttons YES-NO update glog.
                     if NOT glog then return no-apply.
                  end.
               when "pay":U then
                  do:
                     message "Вы хотите напечатать оплаты всего списка чеков по объекту при невключенном фильтре!" skip
                        "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
                        WARNING buttons YES-NO update glog.
                     if NOT glog then return no-apply.
                  end.
               when "gds-list":U then
                  do:
                     message "Вы хотите сохранить товары всего списка чеков по объекту при невключенном фильтре!" skip
                        "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
                        WARNING buttons YES-NO update glog.
                     if NOT glog then return no-apply.
                  end.
               when "akt-spi" then
                  do:
                  end.
            END CASE.
         end.
         v-doc-rec = recid( c-doc ).
         DO WHILE available c-doc :
            GET prev br-docs no-lock.
         END.
         CASE print-type:
            when "list":U then
               do:
                  run PrintProc in this-procedure.
               end.
            when "gds":U then
               do:
                  run PrintProcGds in this-procedure.
               end.
            when "pay":U then
               do:
                  run PrintProcPay in this-procedure.
               end.
            when "gds-list":U then
               do:
                  run PrintProcGds-list in this-procedure.
               end.
         END CASE.
         print-type = "".
         reposition br-docs to recid v-doc-rec no-error.
         apply "entry" to br-docs in frame Dialog-Frame.
      end.
      else
      do:
         CASE print-type:
            when "akt-spi" then
               do:
                  if c-doc.chk-type <>  integer('17':U) then
                  do:
                     message "Акт списания делается только по чекам ТехПролива" view-as alert-box ERROR.
                     return no-apply.
                  end.
                  run rep/r-akt-spis.p (input c-doc.doc-code ).
               end.
            when "one":U then
               do:
                  run str/checkp.p ( input parparentproc, input c-doc.doc-code) no-error.
                  print-type = "".
               end.
            when "spcf":U then
               do:
                  if can-do( 'т':U, c-doc.office ) AND ( c-doc.d-card <> "" ) then
                     run rep/r-specsr.p ( input parparentproc, input recid( c-doc ), input 'касс':U ) .
                  else
                     message "Чек все еще ошибочный ! " view-as alert-box ERROR.
               end.
         END CASE.
      end.
   END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
   DO:
      Cb-chk-type = "0" .
      sch-code = "" .
      sch-date = ? .
      display
      Cb-chk-type
      sch-code
      sch-date
      with frame Dialog-Frame .
      run proc-b-sch in this-procedure no-error.
      if error-status:error then return no-apply.
   END.
ON ANY-PRINTABLE OF BR-docs IN FRAME Dialog-Frame
   DO:
      sch-code:screen-value = sch-code:screen-value + last-event:label.
      apply "entry" to sch-code in frame Dialog-Frame.
      apply "end" to sch-code in frame Dialog-Frame.
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
   END.
ON CHOOSE OF MENU-ITEM m-list
   DO:
      print-type = "list":U.
      apply "choose" to b-print in frame Dialog-Frame.
   END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
   DO:
      assign sch-code .
      run proc-find-code in this-procedure ( input yes, input frame Dialog-Frame sch-code) no-error.
      if error-status:error then return no-apply.
   END.
ON RETURN OF sch-code IN FRAME Dialog-Frame
   DO:
      assign sch-code .
      RUn OpenBR in this-procedure ( input yes, input no, input '':U).
   END.
ON CTRL-J OF sch-date IN FRAME Dialog-Frame
   DO:
      assign sch-date .
      run proc-find-date in this-procedure ( input yes, input frame Dialog-Frame sch-date) no-error.
      if error-status:error then return no-apply.
   END.
ON RETURN OF sch-date IN FRAME Dialog-Frame
   DO:
      assign sch-date .
      RUn OpenBR in this-procedure ( input yes, input no, input '':U).
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
on ' ' of sch-date in frame Dialog-Frame
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
on delete-character of sch-date in frame Dialog-Frame
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
on ctrl-d of sch-date in frame Dialog-Frame
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
on ctrl-b of sch-date in frame Dialog-Frame
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
on ctrl-e of sch-date in frame Dialog-Frame
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
on ctrl-f of sch-date in frame Dialog-Frame
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
  if sch-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date22 :HANDLE
      sch-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle22 as handle no-undo .
  assign
    v-label-handle22 = sch-date :side-label-handle in frame Dialog-Frame
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
    apply "ctrl-b":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date22-2 in menu m-ed-date22 DO:
    apply "ctrl-d":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date22-3 in menu m-ed-date22 DO:
    apply "ctrl-e":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date22-4 in menu m-ed-date22 DO:
    apply "ctrl-f":U to sch-date in frame Dialog-Frame .
  END.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-rep-rec = ?. if available c-doc then v-rep-rec = recid(c-doc). RUn OpenBR in this-procedure ( input yes, input no, input '':U).  reposition br-docs to recid v-rep-rec no-error.
    apply "VALUE-CHANGED" to BR-docs.
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-docs :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
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
   CASE par-mode:
      WHEN  'все':U
      or
      when  'объект':U
      or
      when "free":U
      or
      when "chk-date":U
      or
      when 'vt':U
      or
      when 'dis-card':U
      THEN
         DO:
            FIND FIRST buf_obj No-LOCK WHERE
               buf_obj.obj-type = parobj-type and
               buf_obj.obj-code = parobj-code No-ERROR.
            if not avail buf_obj then
            do:
               message vss-workfile vss-revision vss-description skip
                  "Неверное значение параметров вызова parobj-type и/или parobj-code"
                  parobj-type parobj-code
                  view-as alert-box ERROR.
               return.
            end.
         END.
      when "d-card":U or
      when ("d-card" + chr(44) + 'продажа':U) then
         do:
            FIND FIRST buf_dis-card where
               buf_dis-card.d-card = pard-card No-LOCK NO-ERROR.
            if not avail buf_dis-card then
            do:
               message vss-workfile vss-revision vss-description skip
                  "Неверное значение параметра вызова pard-card" pard-card
                  view-as alert-box ERROR.
               return.
            end.
            FIND FIrst  buf_clients NO-LOCK WHERE
               buf_clients.obj-type = buf_dis-card.cli-type AND
               buf_clients.obj-code = buf_dis-card.cli-code No-ERROR.
         end.
      WHEN 'продажа':U  or
      when ("d-card" + chr(44) + 'продажа':U) or
      when "to-sale":U then
         do:
            FIND buf_inkas where buf_inkas.inkas-code = parout-code NO-LOCK no-error.
            if not avail buf_inkas then
            do:
               message vss-workfile vss-revision vss-description skip
                  "Неверное значение параметра вызова parout-code" parout-code
                  view-as alert-box ERROR.
               return.
            end.
         end.
      when "chk-date":U then
         do:
            if p-start-date > p-end-date
               or p-start-date = ?
               or p-end-date = ?
               then
            do:
               message vss-workfile vss-revision vss-description skip
                  "Неверное значение параметров p-start-date p-end-date" p-start-date p-end-date
                  view-as alert-box ERROR.
               return.
            end.
         end.
      when "to-inv" then
         do:
            FIND buf_trn-doc where buf_trn-doc.doc-code = parout-code NO-LOCK no-error.
            if not avail buf_trn-doc then
            do:
               message vss-workfile vss-revision vss-description skip
                  "Неверное значение параметра вызова parout-code" parout-code
                  view-as alert-box ERROR.
               return.
            end.
         end.
      when "to-" + 'сч-трк-погр':U
      or
      when 'сч-трк-погр':U
      then
         do:
            if parout-code <> '':U then
            do:
               FIND buf_icnt-doc where buf_icnt-doc.doc-code = parout-code NO-LOCK no-error.
               if not avail buf_icnt-doc then
               do:
                  message vss-workfile vss-revision vss-description skip
                     "Неверное значение параметра вызова parout-code" parout-code
                     view-as alert-box ERROR.
                  return.
               end.
            end.
         end.
      otherwise
      do:
         message vss-workfile vss-revision vss-description skip
            "Неверный вызов - par-mode=" par-mode
            view-as alert-box ERROR.
         return.
      end.
   end CASE.
   if pardoc-rec <> ? then
   do:
      FIND FIRST find_chk-doc No-LOCK where
         recid(find_chk-doc) = pardoc-rec No-ERROR.
      if not avail find_chk-doc then
      do:
         message
            vss-workfile vss-revision vss-description skip
            "Неверное значение параметра вызова pardoc-rec" pardoc-rec
            view-as alert-box error .
         return error.
      end.
   end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
   if v-curr-r-b = 'base':U then
   do:
      if v-print-host-code <> 0 then
      do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-print-host-code
  ,output v-base-code
  )  .
         find first buf_currency where
            buf_currency.curr-code = v-base-code.
         assign
            v-base-type = buf_currency.curr-abbr.
      end.
      assign
         v-header-base-curr = string( "( Б.Вал. - " + caps( v-base-type ) + " )" )
         .
   end.
   RUN MyEnable in this-procedure .
   RUn OpenBR in this-procedure ( input yes, input no, input '':U).
   HIDE mark-num in frame Dialog-Frame .
   if pardoc-rec <> ? then
      REPOSITION br-docs to recid pardoc-rec No-ERROR.
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE disable_UI :
   HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
   DISPLAY Cb-chk-type ED-notes sch-code sch-date   mark-num
      WITH FRAME Dialog-Frame.
   ENABLE b-quit         B-print B-sch B-Help
      Cb-chk-type BR-docs ED-notes sch-code sch-date  mark-num
      WITH FRAME Dialog-Frame.
   VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE get-params :
   define variable v-param-type      as character no-undo .
   define variable v-value-character as character no-undo .
   define variable v-value-date      as date      no-undo .
   define variable v-value-decimal   as decimal   no-undo .
   define variable v-value-integer   as INTEGER   no-undo .
   define variable v-value-logical   AS LOGICAL   no-undo .
   define variable v-tth             as handle    no-undo .
   run adm/shattri.p (
      input "get":U
      ,input  parobj-type
      ,input  parobj-code
      ,input  'chk-view':U
      ,input  'chk-spfc':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
   IF not error-status:error then
   do:
      chk-spfc = v-value-logical.
   end.
   delete object v-tth.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type28 as character no-undo .
define variable v-value-character28 as character no-undo .
define variable v-value-date28 as date no-undo .
define variable v-value-decimal28 as decimal no-undo .
define variable v-value-integer28 as INTEGER no-undo .
define variable v-tth28 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  parobj-type
    ,input  parobj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character28
    ,output v-value-date28
    ,output v-value-decimal28
    ,output v-value-integer28
    ,output cas-shft
    ,output v-param-type28
    ,INPUT-OUTPUT table-handle v-tth28
    )  .
delete object v-tth28.
   find first buf_shop no-lock where buf_shop.obj-code = parobj-code.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  'маг':U
  ,input  parobj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
END PROCEDURE.
PROCEDURE MyEnable :
   DEF VAR v-hdl AS HANDLE NO-UNDO .
   ASSIGN
      cb-chk-type                                       = string(0)
      p-chk-type                                        = integer(cb-chk-type)
      br-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 6
      b-print:MENU-MOUSE                                = 1
      .
   run get-params in this-procedure no-error .
   if par-mode = "to-inv" then
   do:
      cb-chk-type = '11':U.
      p-chk-type = integer('11':U).
   end.
   if par-mode = 'сч-трк-погр':U
      or par-mode = "to-" + 'сч-трк-погр':U
      then
   do:
      cb-chk-type = '17':U.
      p-chk-type = integer('17':U).
   end.
   DISPLAY
      cb-chk-type
      when (par-mode = 'продажа':U
      or par-mode = "free"
      or par-mode = "to-sale"
      or par-mode = "to-inv"
      or par-mode = 'сч-трк-погр':U
      or par-mode = "to-" + 'сч-трк-погр':U
      )
      ED-notes
      sch-code
      sch-date
      mark-num
      WITH FRAME Dialog-Frame .
   ENABLE
      cb-chk-type
      when (par-mode = 'продажа':U
      or par-mode = "free"
      or par-mode = "to-sale"
      or par-mode = 'объект':U
      or par-mode = 'все':U
      or par-mode = "chk-date"
      or par-mode = 'dis-card':U
      or par-mode = "d-card"
      or par-mode = 'продажа':U
      or par-mode = "out-code"
      )
      b-quit
      b-sch
      b-help
      br-docs
      sch-code
      sch-date
      ed-notes
      b-print
      WITH FRAME Dialog-Frame.
   IF NOT CAN-FIND(FIRST cash-desk WHERE cash-desk.db-num >=0
      AND cash-desk.obj-code = parobj-code
      AND cash-desk.pos-type = 'Autotank':U) THEN
   DO:
      v-hdl = br-docs:FIRST-COLUMN .
      DO WHILE VALID-HANDLE(v-hdl):
         IF v-hdl:LABEL = "СдНал":U THEN v-hdl:VISIBLE = NO .
         v-hdl = v-hdl:NEXT-COLUMN .
      END.
   END.
   assign
      br-docs:height = br-docs:height  - 0.5
      br-docs:row    = br-docs:row + 0.5
      .
   VIEW FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE OpenBr :
   define input  parameter p-open-query     as logical   no-undo .
   define input  parameter p-find-next      as logical   no-undo .
   define input  parameter p-find-condition as character no-undo .
   define variable l-query-was-opened as logical   no-undo .
   define variable title0             as character no-undo.
   title0 = "Таблица пересменки по кассе" + chr(32).
   define variable sort-column-phrase as character no-undo .
   define variable l-open-query       as logical   no-undo .
   CASE par-mode :
      WHEN 'все':U        THEN
         DO:
            assign
               filter-point = filter-point0 + par-mode
               filter-label = substitute("&1", filter-label0)
               .
            if p-open-query then
            do:
               ASSIGN
                  frame Dialog-Frame:TITLE = substitute("&1 ", title0 )
                  .
            end.
            if sch-code <> "" and sch-date <> ? then
            do:
               case Cb-chk-type:
                  when "0" then
                     do:
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
                              "FOR EACH c-doc"
      parameter-4-31 =
        (
          if (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date " + " " + where-phrase-31) <> ""
          then  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-31
          else "true"
        )
      parameter-5-31 = (" " + "" + " " + "")
      parameter-6-31 = if sort-phrase-31 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-31
        )
      parameter-7-31 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-31 =
          (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date " + " " + where-phrase-31 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where  (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-31 = (if p-find-next then "true":u else "false":u )
      parameter-4-31 =
        "where ":u +  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-31 + " ":u + p-find-condition + " " + ""
      parameter-5-31 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-31)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-31
                          ,input parameter-5-31
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-31 = (if p-find-next then "true":u else "false":u )
      parameter-3-31 =  "FOR EACH c-doc"
      parameter-4-31 =
        (
          if (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date " + " " + where-phrase-31) <> ""
          then  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-31
          else "true"
        )
      parameter-5-31 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-31 = if sort-phrase-31 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-31
        )
      parameter-7-31 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
                     end.
                  when "13" then
                     do:
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
                              "FOR EACH c-doc"
      parameter-4-33 =
        (
          if ("  c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  " + " " + where-phrase-33) <> ""
          then  substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "")
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-33 =
          ("  c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  " + " " + where-phrase-33 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where   c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-4-33 =
        "where ":u +  substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-33 + " ":u + p-find-condition + " " + ""
      parameter-5-33 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-3-33 =  "FOR EACH c-doc"
      parameter-4-33 =
        (
          if ("  c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  " + " " + where-phrase-33) <> ""
          then  substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-33
        )
      parameter-7-33 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
                     end.
                  when "40" then
                     do:
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
                              "FOR EACH c-doc"
      parameter-4-35 =
        (
          if (" c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  " + " " + where-phrase-35) <> ""
          then  substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "")
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-35
        )
      parameter-7-35 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-35 =
          (" c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  " + " " + where-phrase-35 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where  c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-4-35 =
        "where ":u +  substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-35 + " ":u + p-find-condition + " " + ""
      parameter-5-35 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-3-35 =  "FOR EACH c-doc"
      parameter-4-35 =
        (
          if (" c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  " + " " + where-phrase-35) <> ""
          then  substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-35
        )
      parameter-7-35 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
                     end.
               end case.
            end.
            else if sch-code = "" and sch-date <> ? then
               do:
                  case Cb-chk-type:
                     when "0" then
                        do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-37  as logical   no-undo .
define variable  l-filter-open-37    as logical   .
define variable  flt-rec-37       as recid     no-undo .
define variable  filter-name-37      as character no-undo .
define variable  where-phrase-37     as character no-undo .
define variable  sort-phrase-37      as character no-undo .
define variable  where-phrase-rus-37 as character no-undo .
define variable  sort-phrase-rus-37  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
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
                              "FOR EACH c-doc"
      parameter-4-37 =
        (
          if (" (c-doc.chk-type = 13 or c-doc.chk-type = 40) and c-doc.chk-date = sch-date " + " " + where-phrase-37) <> ""
          then  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + "")
      parameter-6-37 = if sort-phrase-37 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-37
        )
      parameter-7-37 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-37 =
          (" (c-doc.chk-type = 13 or c-doc.chk-type = 40) and c-doc.chk-date = sch-date " + " " + where-phrase-37 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where  (c-doc.chk-type = 13 or c-doc.chk-type = 40) and c-doc.chk-date = sch-date
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-4-37 =
        "where ":u +  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-37 + " ":u + p-find-condition + " " + ""
      parameter-5-37 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
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
      parameter-3-37 =  "FOR EACH c-doc"
      parameter-4-37 =
        (
          if (" (c-doc.chk-type = 13 or c-doc.chk-type = 40) and c-doc.chk-date = sch-date " + " " + where-phrase-37) <> ""
          then  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-37 = if sort-phrase-37 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-37
        )
      parameter-7-37 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
  run waitfram-hide in this-procedure .
                        end.
                     when "13" then
                        do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-39  as logical   no-undo .
define variable  l-filter-open-39    as logical   .
define variable  flt-rec-39       as recid     no-undo .
define variable  filter-name-39      as character no-undo .
define variable  where-phrase-39     as character no-undo .
define variable  sort-phrase-39      as character no-undo .
define variable  where-phrase-rus-39 as character no-undo .
define variable  sort-phrase-rus-39  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
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
                              "FOR EACH c-doc"
      parameter-4-39 =
        (
          if (" c-doc.chk-type = 13 and c-doc.chk-date = sch-date " + " " + where-phrase-39) <> ""
          then  substitute(' c-doc.chk-type = 13 and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + "")
      parameter-6-39 = if sort-phrase-39 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-39 =
          (" c-doc.chk-type = 13 and c-doc.chk-date = sch-date " + " " + where-phrase-39 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where  c-doc.chk-type = 13 and c-doc.chk-date = sch-date
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-4-39 =
        "where ":u +  substitute(' c-doc.chk-type = 13 and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-39 + " ":u + p-find-condition + " " + ""
      parameter-5-39 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
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
      parameter-3-39 =  "FOR EACH c-doc"
      parameter-4-39 =
        (
          if (" c-doc.chk-type = 13 and c-doc.chk-date = sch-date " + " " + where-phrase-39) <> ""
          then  substitute(' c-doc.chk-type = 13 and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-39 = if sort-phrase-39 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
  run waitfram-hide in this-procedure .
                        end.
                     when "40" then
                        do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-41  as logical   no-undo .
define variable  l-filter-open-41    as logical   .
define variable  flt-rec-41       as recid     no-undo .
define variable  filter-name-41      as character no-undo .
define variable  where-phrase-41     as character no-undo .
define variable  sort-phrase-41      as character no-undo .
define variable  where-phrase-rus-41 as character no-undo .
define variable  sort-phrase-rus-41  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-41
  ,output filter-name-41
  ,output where-phrase-41
  ,output sort-phrase-41
  ,output where-phrase-rus-41
  ,output sort-phrase-rus-41
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-41
      ) no-error .
  assign
    l-filter-open-41 = false
  .
  if flt-rec-41 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-41 as character no-undo .
    define variable  parameter-3-41 as character no-undo .
    define variable  parameter-4-41 as character no-undo .
    define variable  parameter-5-41 as character no-undo .
    define variable  parameter-6-41 as character no-undo .
    define variable  parameter-7-41 as character no-undo .
      assign
      parameter-3-41 =
                              "FOR EACH c-doc"
      parameter-4-41 =
        (
          if (" c-doc.chk-type = 40 and c-doc.chk-date = sch-date " + " " + where-phrase-41) <> ""
          then  substitute(' c-doc.chk-type = 40 and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + "")
      parameter-6-41 = if sort-phrase-41 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-41
        )
      parameter-7-41 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-41 =
          (" c-doc.chk-type = 40 and c-doc.chk-date = sch-date " + " " + where-phrase-41 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
                          )
      .
      assign
        l-filter-open-41 = true
      .
    end.
    if l-filter-open-41 = false then do:
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
  if l-filter-open-41 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where  c-doc.chk-type = 40 and c-doc.chk-date = sch-date
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-4-41 =
        "where ":u +  substitute(' c-doc.chk-type = 40 and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-41 + " ":u + p-find-condition + " " + ""
      parameter-5-41 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-3-41 =  "FOR EACH c-doc"
      parameter-4-41 =
        (
          if (" c-doc.chk-type = 40 and c-doc.chk-date = sch-date " + " " + where-phrase-41) <> ""
          then  substitute(' c-doc.chk-type = 40 and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-41 = if sort-phrase-41 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-41
        )
      parameter-7-41 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
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
                        end.
                  end case.
               end.
               else if sch-code <> "" and sch-date = ? then
                  do:
                     case Cb-chk-type:
                        when "0" then
                           do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-43  as logical   no-undo .
define variable  l-filter-open-43    as logical   .
define variable  flt-rec-43       as recid     no-undo .
define variable  filter-name-43      as character no-undo .
define variable  where-phrase-43     as character no-undo .
define variable  sort-phrase-43      as character no-undo .
define variable  where-phrase-rus-43 as character no-undo .
define variable  sort-phrase-rus-43  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-43
  ,output filter-name-43
  ,output where-phrase-43
  ,output sort-phrase-43
  ,output where-phrase-rus-43
  ,output sort-phrase-rus-43
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-43
      ) no-error .
  assign
    l-filter-open-43 = false
  .
  if flt-rec-43 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-43 as character no-undo .
    define variable  parameter-3-43 as character no-undo .
    define variable  parameter-4-43 as character no-undo .
    define variable  parameter-5-43 as character no-undo .
    define variable  parameter-6-43 as character no-undo .
    define variable  parameter-7-43 as character no-undo .
      assign
      parameter-3-43 =
                              "FOR EACH c-doc"
      parameter-4-43 =
        (
          if (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-43) <> ""
          then  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + "")
      parameter-6-43 = if sort-phrase-43 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-43
        )
      parameter-7-43 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-43 =
          (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-43 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-43
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ,input parameter-6-43
                          ,input parameter-7-43
                          )
      .
      assign
        l-filter-open-43 = true
      .
    end.
    if l-filter-open-43 = false then do:
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
  if l-filter-open-43 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where  (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code)
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-43 = (if p-find-next then "true":u else "false":u )
      parameter-4-43 =
        "where ":u +  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-43 + " ":u + p-find-condition + " " + ""
      parameter-5-43 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-43)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-43 = (if p-find-next then "true":u else "false":u )
      parameter-3-43 =  "FOR EACH c-doc"
      parameter-4-43 =
        (
          if (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-43) <> ""
          then  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-43 = if sort-phrase-43 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-43
        )
      parameter-7-43 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-43)
                          ,input no-lock
                          ,input parameter-3-43
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ,input parameter-6-43
                          ,input parameter-7-43
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
                           end.
                        when "13" then
                           do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-45  as logical   no-undo .
define variable  l-filter-open-45    as logical   .
define variable  flt-rec-45       as recid     no-undo .
define variable  filter-name-45      as character no-undo .
define variable  where-phrase-45     as character no-undo .
define variable  sort-phrase-45      as character no-undo .
define variable  where-phrase-rus-45 as character no-undo .
define variable  sort-phrase-rus-45  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-45
  ,output filter-name-45
  ,output where-phrase-45
  ,output sort-phrase-45
  ,output where-phrase-rus-45
  ,output sort-phrase-rus-45
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-45
      ) no-error .
  assign
    l-filter-open-45 = false
  .
  if flt-rec-45 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-45 as character no-undo .
    define variable  parameter-3-45 as character no-undo .
    define variable  parameter-4-45 as character no-undo .
    define variable  parameter-5-45 as character no-undo .
    define variable  parameter-6-45 as character no-undo .
    define variable  parameter-7-45 as character no-undo .
      assign
      parameter-3-45 =
                              "FOR EACH c-doc"
      parameter-4-45 =
        (
          if (" c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-45) <> ""
          then  substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + "")
      parameter-6-45 = if sort-phrase-45 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-45
        )
      parameter-7-45 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-45 =
          (" c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-45 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-45
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ,input parameter-6-45
                          ,input parameter-7-45
                          )
      .
      assign
        l-filter-open-45 = true
      .
    end.
    if l-filter-open-45 = false then do:
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
  if l-filter-open-45 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where  c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code)
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-45 = (if p-find-next then "true":u else "false":u )
      parameter-4-45 =
        "where ":u +  substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-45 + " ":u + p-find-condition + " " + ""
      parameter-5-45 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-45)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-45 = (if p-find-next then "true":u else "false":u )
      parameter-3-45 =  "FOR EACH c-doc"
      parameter-4-45 =
        (
          if (" c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-45) <> ""
          then  substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-45 = if sort-phrase-45 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-45
        )
      parameter-7-45 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-45)
                          ,input no-lock
                          ,input parameter-3-45
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ,input parameter-6-45
                          ,input parameter-7-45
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
                           end.
                        when "40" then
                           do:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-47  as logical   no-undo .
define variable  l-filter-open-47    as logical   .
define variable  flt-rec-47       as recid     no-undo .
define variable  filter-name-47      as character no-undo .
define variable  where-phrase-47     as character no-undo .
define variable  sort-phrase-47      as character no-undo .
define variable  where-phrase-rus-47 as character no-undo .
define variable  sort-phrase-rus-47  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
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
                              "FOR EACH c-doc"
      parameter-4-47 =
        (
          if (" c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-47) <> ""
          then  substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + "")
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-47
        )
      parameter-7-47 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-47 =
          (" c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-47 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where  c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code)
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-4-47 =
        "where ":u +  substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-47 + " ":u + p-find-condition + " " + ""
      parameter-5-47 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
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
      parameter-3-47 =  "FOR EACH c-doc"
      parameter-4-47 =
        (
          if (" c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-47) <> ""
          then  substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-47
        )
      parameter-7-47 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
  run waitfram-hide in this-procedure .
                           end.
                     end case.
                  end.
                  else
                  do:
                     case Cb-chk-type:
                        when "0" then
                           do:
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-49  as logical   no-undo .
define variable  l-filter-open-49    as logical   .
define variable  flt-rec-49       as recid     no-undo .
define variable  filter-name-49      as character no-undo .
define variable  where-phrase-49     as character no-undo .
define variable  sort-phrase-49      as character no-undo .
define variable  where-phrase-rus-49 as character no-undo .
define variable  sort-phrase-rus-49  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
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
                              "FOR EACH c-doc"
      parameter-4-49 =
        (
          if ("           (c-doc.chk-type = 13 OR c-doc.chk-type = 40)
                          " + " " + where-phrase-49) <> ""
          then "           (c-doc.chk-type = 13 OR c-doc.chk-type = 40)
                          " + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + "")
      parameter-6-49 = if sort-phrase-49 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-49
        )
      parameter-7-49 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-49 =
          ("           (c-doc.chk-type = 13 OR c-doc.chk-type = 40)
                          " + " " + where-phrase-49 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where            (c-doc.chk-type = 13 OR c-doc.chk-type = 40)
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-49 = (if p-find-next then "true":u else "false":u )
      parameter-4-49 =
        "where ":u + "           (c-doc.chk-type = 13 OR c-doc.chk-type = 40)
                          " + " ":u + where-phrase-49 + " ":u + p-find-condition + " " + ""
      parameter-5-49 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-49)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
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
      parameter-3-49 =  "FOR EACH c-doc"
      parameter-4-49 =
        (
          if ("           (c-doc.chk-type = 13 OR c-doc.chk-type = 40)
                          " + " " + where-phrase-49) <> ""
          then "           (c-doc.chk-type = 13 OR c-doc.chk-type = 40)
                          " + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-49 = if sort-phrase-49 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-49
        )
      parameter-7-49 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
  run waitfram-hide in this-procedure .
                           end.
                        when "13" then
                           do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-51  as logical   no-undo .
define variable  l-filter-open-51    as logical   .
define variable  flt-rec-51       as recid     no-undo .
define variable  filter-name-51      as character no-undo .
define variable  where-phrase-51     as character no-undo .
define variable  sort-phrase-51      as character no-undo .
define variable  where-phrase-rus-51 as character no-undo .
define variable  sort-phrase-rus-51  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-51
  ,output filter-name-51
  ,output where-phrase-51
  ,output sort-phrase-51
  ,output where-phrase-rus-51
  ,output sort-phrase-rus-51
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-51
      ) no-error .
  assign
    l-filter-open-51 = false
  .
  if flt-rec-51 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-51 as character no-undo .
    define variable  parameter-3-51 as character no-undo .
    define variable  parameter-4-51 as character no-undo .
    define variable  parameter-5-51 as character no-undo .
    define variable  parameter-6-51 as character no-undo .
    define variable  parameter-7-51 as character no-undo .
      assign
      parameter-3-51 =
                              "FOR EACH c-doc"
      parameter-4-51 =
        (
          if ("           (c-doc.chk-type = 13)
                          " + " " + where-phrase-51) <> ""
          then "           (c-doc.chk-type = 13)
                          " + " " + where-phrase-51
          else "true"
        )
      parameter-5-51 = (" " + "" + " " + "")
      parameter-6-51 = if sort-phrase-51 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-51
        )
      parameter-7-51 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-51 =
          ("           (c-doc.chk-type = 13)
                          " + " " + where-phrase-51 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-51
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ,input parameter-6-51
                          ,input parameter-7-51
                          )
      .
      assign
        l-filter-open-51 = true
      .
    end.
    if l-filter-open-51 = false then do:
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
  if l-filter-open-51 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where            (c-doc.chk-type = 13)
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-51 = (if p-find-next then "true":u else "false":u )
      parameter-4-51 =
        "where ":u + "           (c-doc.chk-type = 13)
                          " + " ":u + where-phrase-51 + " ":u + p-find-condition + " " + ""
      parameter-5-51 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-51)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-51 = (if p-find-next then "true":u else "false":u )
      parameter-3-51 =  "FOR EACH c-doc"
      parameter-4-51 =
        (
          if ("           (c-doc.chk-type = 13)
                          " + " " + where-phrase-51) <> ""
          then "           (c-doc.chk-type = 13)
                          " + " " + where-phrase-51
          else "true"
        )
      parameter-5-51 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-51 = if sort-phrase-51 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-51
        )
      parameter-7-51 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-51)
                          ,input no-lock
                          ,input parameter-3-51
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ,input parameter-6-51
                          ,input parameter-7-51
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
                           end.
                        when "40" then
                           do:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-53  as logical   no-undo .
define variable  l-filter-open-53    as logical   .
define variable  flt-rec-53       as recid     no-undo .
define variable  filter-name-53      as character no-undo .
define variable  where-phrase-53     as character no-undo .
define variable  sort-phrase-53      as character no-undo .
define variable  where-phrase-rus-53 as character no-undo .
define variable  sort-phrase-rus-53  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-53
  ,output filter-name-53
  ,output where-phrase-53
  ,output sort-phrase-53
  ,output where-phrase-rus-53
  ,output sort-phrase-rus-53
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-53
      ) no-error .
  assign
    l-filter-open-53 = false
  .
  if flt-rec-53 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-53 as character no-undo .
    define variable  parameter-3-53 as character no-undo .
    define variable  parameter-4-53 as character no-undo .
    define variable  parameter-5-53 as character no-undo .
    define variable  parameter-6-53 as character no-undo .
    define variable  parameter-7-53 as character no-undo .
      assign
      parameter-3-53 =
                              "FOR EACH c-doc"
      parameter-4-53 =
        (
          if ("           (c-doc.chk-type = 40)
                          " + " " + where-phrase-53) <> ""
          then "           (c-doc.chk-type = 40)
                          " + " " + where-phrase-53
          else "true"
        )
      parameter-5-53 = (" " + "" + " " + "")
      parameter-6-53 = if sort-phrase-53 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-53
        )
      parameter-7-53 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-53 =
          ("           (c-doc.chk-type = 40)
                          " + " " + where-phrase-53 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-53
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ,input parameter-6-53
                          ,input parameter-7-53
                          )
      .
      assign
        l-filter-open-53 = true
      .
    end.
    if l-filter-open-53 = false then do:
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
  if l-filter-open-53 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where            (c-doc.chk-type = 40)
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-53 = (if p-find-next then "true":u else "false":u )
      parameter-4-53 =
        "where ":u + "           (c-doc.chk-type = 40)
                          " + " ":u + where-phrase-53 + " ":u + p-find-condition + " " + ""
      parameter-5-53 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-53)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-53 = (if p-find-next then "true":u else "false":u )
      parameter-3-53 =  "FOR EACH c-doc"
      parameter-4-53 =
        (
          if ("           (c-doc.chk-type = 40)
                          " + " " + where-phrase-53) <> ""
          then "           (c-doc.chk-type = 40)
                          " + " " + where-phrase-53
          else "true"
        )
      parameter-5-53 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-53 = if sort-phrase-53 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-53
        )
      parameter-7-53 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-53)
                          ,input no-lock
                          ,input parameter-3-53
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ,input parameter-6-53
                          ,input parameter-7-53
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
                           end.
                     end case.
                  end.
         END.
      WHEN 'объект':U THEN
         DO:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
            assign
               filter-point = filter-point0 + par-mode
               filter-label = substitute("&1 Один объект", filter-label0)
               .
               if p-open-query then
               do:
                  ASSIGN
                     frame Dialog-Frame:TITLE = substitute("&1 Объект: &2&3", title0 , parobj-type , parobj-code)
                     .
               end.
            if sch-code <> "" and sch-date <> ? then
            do:
               case Cb-chk-type:
                  when "0" then
                     do:
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
                              "FOR EACH c-doc"
      parameter-4-56 =
        (
          if (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date " + " " + where-phrase-56) <> ""
          then  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + "")
      parameter-6-56 = if sort-phrase-56 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-56
        )
      parameter-7-56 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-56 =
          (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date " + " " + where-phrase-56 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where  (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-56 = (if p-find-next then "true":u else "false":u )
      parameter-4-56 =
        "where ":u +  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-56 + " ":u + p-find-condition + " " + ""
      parameter-5-56 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-56)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-56 = (if p-find-next then "true":u else "false":u )
      parameter-3-56 =  "FOR EACH c-doc"
      parameter-4-56 =
        (
          if (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date " + " " + where-phrase-56) <> ""
          then  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-56 = if sort-phrase-56 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-56
        )
      parameter-7-56 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
                     end.
                  when "13" then
                     do:
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
                              "FOR EACH c-doc"
      parameter-4-58 =
        (
          if ("  c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  " + " " + where-phrase-58) <> ""
          then  substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-58
          else "true"
        )
      parameter-5-58 = (" " + "" + " " + "")
      parameter-6-58 = if sort-phrase-58 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-58
        )
      parameter-7-58 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-58 =
          ("  c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  " + " " + where-phrase-58 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where   c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-58 = (if p-find-next then "true":u else "false":u )
      parameter-4-58 =
        "where ":u +  substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-58 + " ":u + p-find-condition + " " + ""
      parameter-5-58 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-58)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-58
                          ,input parameter-5-58
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-58 = (if p-find-next then "true":u else "false":u )
      parameter-3-58 =  "FOR EACH c-doc"
      parameter-4-58 =
        (
          if ("  c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  " + " " + where-phrase-58) <> ""
          then  substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-58
          else "true"
        )
      parameter-5-58 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-58 = if sort-phrase-58 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-58
        )
      parameter-7-58 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
                     end.
                  when "40" then
                     do:
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
                              "FOR EACH c-doc"
      parameter-4-60 =
        (
          if (" c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  " + " " + where-phrase-60) <> ""
          then  substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-60
          else "true"
        )
      parameter-5-60 = (" " + "" + " " + "")
      parameter-6-60 = if sort-phrase-60 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-60
        )
      parameter-7-60 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-60 =
          (" c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  " + " " + where-phrase-60 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where  c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-60 = (if p-find-next then "true":u else "false":u )
      parameter-4-60 =
        "where ":u +  substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-60 + " ":u + p-find-condition + " " + ""
      parameter-5-60 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-60)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-60
                          ,input parameter-5-60
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-60 = (if p-find-next then "true":u else "false":u )
      parameter-3-60 =  "FOR EACH c-doc"
      parameter-4-60 =
        (
          if (" c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) and c-doc.chk-date = sch-date  " + " " + where-phrase-60) <> ""
          then  substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-60
          else "true"
        )
      parameter-5-60 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-60 = if sort-phrase-60 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-60
        )
      parameter-7-60 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
                     end.
               end case.
            end.
            else if sch-code = "" and sch-date <> ? then
               do:
                  case Cb-chk-type:
                     when "0" then
                        do:
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-62  as logical   no-undo .
define variable  l-filter-open-62    as logical   .
define variable  flt-rec-62       as recid     no-undo .
define variable  filter-name-62      as character no-undo .
define variable  where-phrase-62     as character no-undo .
define variable  sort-phrase-62      as character no-undo .
define variable  where-phrase-rus-62 as character no-undo .
define variable  sort-phrase-rus-62  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
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
                              "FOR EACH c-doc"
      parameter-4-62 =
        (
          if (" (c-doc.chk-type = 13 or c-doc.chk-type = 40) and c-doc.chk-date = sch-date " + " " + where-phrase-62) <> ""
          then  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-62
          else "true"
        )
      parameter-5-62 = (" " + "" + " " + "")
      parameter-6-62 = if sort-phrase-62 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-62
        )
      parameter-7-62 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-62 =
          (" (c-doc.chk-type = 13 or c-doc.chk-type = 40) and c-doc.chk-date = sch-date " + " " + where-phrase-62 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where  (c-doc.chk-type = 13 or c-doc.chk-type = 40) and c-doc.chk-date = sch-date
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-62 = (if p-find-next then "true":u else "false":u )
      parameter-4-62 =
        "where ":u +  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-62 + " ":u + p-find-condition + " " + ""
      parameter-5-62 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-62)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
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
      parameter-3-62 =  "FOR EACH c-doc"
      parameter-4-62 =
        (
          if (" (c-doc.chk-type = 13 or c-doc.chk-type = 40) and c-doc.chk-date = sch-date " + " " + where-phrase-62) <> ""
          then  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-62
          else "true"
        )
      parameter-5-62 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-62 = if sort-phrase-62 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-62
        )
      parameter-7-62 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
  run waitfram-hide in this-procedure .
                        end.
                     when "13" then
                        do:
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-64  as logical   no-undo .
define variable  l-filter-open-64    as logical   .
define variable  flt-rec-64       as recid     no-undo .
define variable  filter-name-64      as character no-undo .
define variable  where-phrase-64     as character no-undo .
define variable  sort-phrase-64      as character no-undo .
define variable  where-phrase-rus-64 as character no-undo .
define variable  sort-phrase-rus-64  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-64
  ,output filter-name-64
  ,output where-phrase-64
  ,output sort-phrase-64
  ,output where-phrase-rus-64
  ,output sort-phrase-rus-64
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-64
      ) no-error .
  assign
    l-filter-open-64 = false
  .
  if flt-rec-64 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-64 as character no-undo .
    define variable  parameter-3-64 as character no-undo .
    define variable  parameter-4-64 as character no-undo .
    define variable  parameter-5-64 as character no-undo .
    define variable  parameter-6-64 as character no-undo .
    define variable  parameter-7-64 as character no-undo .
      assign
      parameter-3-64 =
                              "FOR EACH c-doc"
      parameter-4-64 =
        (
          if (" c-doc.chk-type = 13 and c-doc.chk-date = sch-date " + " " + where-phrase-64) <> ""
          then  substitute(' c-doc.chk-type = 13 and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-64
          else "true"
        )
      parameter-5-64 = (" " + "" + " " + "")
      parameter-6-64 = if sort-phrase-64 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-64
        )
      parameter-7-64 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-64 =
          (" c-doc.chk-type = 13 and c-doc.chk-date = sch-date " + " " + where-phrase-64 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-64
                          ,input parameter-4-64
                          ,input parameter-5-64
                          ,input parameter-6-64
                          ,input parameter-7-64
                          )
      .
      assign
        l-filter-open-64 = true
      .
    end.
    if l-filter-open-64 = false then do:
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
  if l-filter-open-64 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where  c-doc.chk-type = 13 and c-doc.chk-date = sch-date
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-64 = (if p-find-next then "true":u else "false":u )
      parameter-4-64 =
        "where ":u +  substitute(' c-doc.chk-type = 13 and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-64 + " ":u + p-find-condition + " " + ""
      parameter-5-64 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-64)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-64
                          ,input parameter-5-64
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-64 = (if p-find-next then "true":u else "false":u )
      parameter-3-64 =  "FOR EACH c-doc"
      parameter-4-64 =
        (
          if (" c-doc.chk-type = 13 and c-doc.chk-date = sch-date " + " " + where-phrase-64) <> ""
          then  substitute(' c-doc.chk-type = 13 and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-64
          else "true"
        )
      parameter-5-64 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-64 = if sort-phrase-64 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-64
        )
      parameter-7-64 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-64)
                          ,input no-lock
                          ,input parameter-3-64
                          ,input parameter-4-64
                          ,input parameter-5-64
                          ,input parameter-6-64
                          ,input parameter-7-64
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
                        end.
                     when "40" then
                        do:
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-66  as logical   no-undo .
define variable  l-filter-open-66    as logical   .
define variable  flt-rec-66       as recid     no-undo .
define variable  filter-name-66      as character no-undo .
define variable  where-phrase-66     as character no-undo .
define variable  sort-phrase-66      as character no-undo .
define variable  where-phrase-rus-66 as character no-undo .
define variable  sort-phrase-rus-66  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-66
  ,output filter-name-66
  ,output where-phrase-66
  ,output sort-phrase-66
  ,output where-phrase-rus-66
  ,output sort-phrase-rus-66
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-66
      ) no-error .
  assign
    l-filter-open-66 = false
  .
  if flt-rec-66 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-66 as character no-undo .
    define variable  parameter-3-66 as character no-undo .
    define variable  parameter-4-66 as character no-undo .
    define variable  parameter-5-66 as character no-undo .
    define variable  parameter-6-66 as character no-undo .
    define variable  parameter-7-66 as character no-undo .
      assign
      parameter-3-66 =
                              "FOR EACH c-doc"
      parameter-4-66 =
        (
          if (" c-doc.chk-type = 40 and c-doc.chk-date = sch-date " + " " + where-phrase-66) <> ""
          then  substitute(' c-doc.chk-type = 40 and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-66
          else "true"
        )
      parameter-5-66 = (" " + "" + " " + "")
      parameter-6-66 = if sort-phrase-66 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-66
        )
      parameter-7-66 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-66 =
          (" c-doc.chk-type = 40 and c-doc.chk-date = sch-date " + " " + where-phrase-66 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-66
                          ,input parameter-4-66
                          ,input parameter-5-66
                          ,input parameter-6-66
                          ,input parameter-7-66
                          )
      .
      assign
        l-filter-open-66 = true
      .
    end.
    if l-filter-open-66 = false then do:
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
  if l-filter-open-66 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where  c-doc.chk-type = 40 and c-doc.chk-date = sch-date
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-66 = (if p-find-next then "true":u else "false":u )
      parameter-4-66 =
        "where ":u +  substitute(' c-doc.chk-type = 40 and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-66 + " ":u + p-find-condition + " " + ""
      parameter-5-66 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-66)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-66
                          ,input parameter-5-66
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-66 = (if p-find-next then "true":u else "false":u )
      parameter-3-66 =  "FOR EACH c-doc"
      parameter-4-66 =
        (
          if (" c-doc.chk-type = 40 and c-doc.chk-date = sch-date " + " " + where-phrase-66) <> ""
          then  substitute(' c-doc.chk-type = 40 and c-doc.chk-date = &3 ', chr(34), sch-code, sch-date)  + " " + where-phrase-66
          else "true"
        )
      parameter-5-66 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-66 = if sort-phrase-66 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-66
        )
      parameter-7-66 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-66)
                          ,input no-lock
                          ,input parameter-3-66
                          ,input parameter-4-66
                          ,input parameter-5-66
                          ,input parameter-6-66
                          ,input parameter-7-66
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
                        end.
                  end case.
               end.
               else if sch-code <> "" and sch-date = ? then
                  do:
                     case Cb-chk-type:
                        when "0" then
                           do:
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-68  as logical   no-undo .
define variable  l-filter-open-68    as logical   .
define variable  flt-rec-68       as recid     no-undo .
define variable  filter-name-68      as character no-undo .
define variable  where-phrase-68     as character no-undo .
define variable  sort-phrase-68      as character no-undo .
define variable  where-phrase-rus-68 as character no-undo .
define variable  sort-phrase-rus-68  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-68
  ,output filter-name-68
  ,output where-phrase-68
  ,output sort-phrase-68
  ,output where-phrase-rus-68
  ,output sort-phrase-rus-68
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-68
      ) no-error .
  assign
    l-filter-open-68 = false
  .
  if flt-rec-68 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-68 as character no-undo .
    define variable  parameter-3-68 as character no-undo .
    define variable  parameter-4-68 as character no-undo .
    define variable  parameter-5-68 as character no-undo .
    define variable  parameter-6-68 as character no-undo .
    define variable  parameter-7-68 as character no-undo .
      assign
      parameter-3-68 =
                              "FOR EACH c-doc"
      parameter-4-68 =
        (
          if (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-68) <> ""
          then  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " " + where-phrase-68
          else "true"
        )
      parameter-5-68 = (" " + "" + " " + "")
      parameter-6-68 = if sort-phrase-68 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-68
        )
      parameter-7-68 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-68 =
          (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-68 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-68
                          ,input parameter-4-68
                          ,input parameter-5-68
                          ,input parameter-6-68
                          ,input parameter-7-68
                          )
      .
      assign
        l-filter-open-68 = true
      .
    end.
    if l-filter-open-68 = false then do:
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
  if l-filter-open-68 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where  (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code)
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-68 = (if p-find-next then "true":u else "false":u )
      parameter-4-68 =
        "where ":u +  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-68 + " ":u + p-find-condition + " " + ""
      parameter-5-68 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-68)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-68
                          ,input parameter-5-68
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-68 = (if p-find-next then "true":u else "false":u )
      parameter-3-68 =  "FOR EACH c-doc"
      parameter-4-68 =
        (
          if (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-68) <> ""
          then  substitute(' (c-doc.chk-type = 13 OR c-doc.chk-type = 40) and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " " + where-phrase-68
          else "true"
        )
      parameter-5-68 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-68 = if sort-phrase-68 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-68
        )
      parameter-7-68 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-68)
                          ,input no-lock
                          ,input parameter-3-68
                          ,input parameter-4-68
                          ,input parameter-5-68
                          ,input parameter-6-68
                          ,input parameter-7-68
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
                           end.
                        when "13" then
                           do:
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-70  as logical   no-undo .
define variable  l-filter-open-70    as logical   .
define variable  flt-rec-70       as recid     no-undo .
define variable  filter-name-70      as character no-undo .
define variable  where-phrase-70     as character no-undo .
define variable  sort-phrase-70      as character no-undo .
define variable  where-phrase-rus-70 as character no-undo .
define variable  sort-phrase-rus-70  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-70
  ,output filter-name-70
  ,output where-phrase-70
  ,output sort-phrase-70
  ,output where-phrase-rus-70
  ,output sort-phrase-rus-70
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-70
      ) no-error .
  assign
    l-filter-open-70 = false
  .
  if flt-rec-70 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-70 as character no-undo .
    define variable  parameter-3-70 as character no-undo .
    define variable  parameter-4-70 as character no-undo .
    define variable  parameter-5-70 as character no-undo .
    define variable  parameter-6-70 as character no-undo .
    define variable  parameter-7-70 as character no-undo .
      assign
      parameter-3-70 =
                              "FOR EACH c-doc"
      parameter-4-70 =
        (
          if (" c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-70) <> ""
          then  substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " " + where-phrase-70
          else "true"
        )
      parameter-5-70 = (" " + "" + " " + "")
      parameter-6-70 = if sort-phrase-70 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-70
        )
      parameter-7-70 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-70 =
          (" c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-70 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-70
                          ,input parameter-4-70
                          ,input parameter-5-70
                          ,input parameter-6-70
                          ,input parameter-7-70
                          )
      .
      assign
        l-filter-open-70 = true
      .
    end.
    if l-filter-open-70 = false then do:
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
  if l-filter-open-70 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where  c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code)
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-70 = (if p-find-next then "true":u else "false":u )
      parameter-4-70 =
        "where ":u +  substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-70 + " ":u + p-find-condition + " " + ""
      parameter-5-70 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-70)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-70
                          ,input parameter-5-70
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-70 = (if p-find-next then "true":u else "false":u )
      parameter-3-70 =  "FOR EACH c-doc"
      parameter-4-70 =
        (
          if (" c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-70) <> ""
          then  substitute(' c-doc.chk-type = 13 and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " " + where-phrase-70
          else "true"
        )
      parameter-5-70 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-70 = if sort-phrase-70 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-70
        )
      parameter-7-70 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-70)
                          ,input no-lock
                          ,input parameter-3-70
                          ,input parameter-4-70
                          ,input parameter-5-70
                          ,input parameter-6-70
                          ,input parameter-7-70
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
                           end.
                        when "40" then
                           do:
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-72  as logical   no-undo .
define variable  l-filter-open-72    as logical   .
define variable  flt-rec-72       as recid     no-undo .
define variable  filter-name-72      as character no-undo .
define variable  where-phrase-72     as character no-undo .
define variable  sort-phrase-72      as character no-undo .
define variable  where-phrase-rus-72 as character no-undo .
define variable  sort-phrase-rus-72  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-72
  ,output filter-name-72
  ,output where-phrase-72
  ,output sort-phrase-72
  ,output where-phrase-rus-72
  ,output sort-phrase-rus-72
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-72
      ) no-error .
  assign
    l-filter-open-72 = false
  .
  if flt-rec-72 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-72 as character no-undo .
    define variable  parameter-3-72 as character no-undo .
    define variable  parameter-4-72 as character no-undo .
    define variable  parameter-5-72 as character no-undo .
    define variable  parameter-6-72 as character no-undo .
    define variable  parameter-7-72 as character no-undo .
      assign
      parameter-3-72 =
                              "FOR EACH c-doc"
      parameter-4-72 =
        (
          if (" c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-72) <> ""
          then  substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " " + where-phrase-72
          else "true"
        )
      parameter-5-72 = (" " + "" + " " + "")
      parameter-6-72 = if sort-phrase-72 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-72
        )
      parameter-7-72 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-72 =
          (" c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-72 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-72
                          ,input parameter-4-72
                          ,input parameter-5-72
                          ,input parameter-6-72
                          ,input parameter-7-72
                          )
      .
      assign
        l-filter-open-72 = true
      .
    end.
    if l-filter-open-72 = false then do:
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
  if l-filter-open-72 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where  c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code)
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-72 = (if p-find-next then "true":u else "false":u )
      parameter-4-72 =
        "where ":u +  substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " ":u + where-phrase-72 + " ":u + p-find-condition + " " + ""
      parameter-5-72 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-72)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-72
                          ,input parameter-5-72
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-72 = (if p-find-next then "true":u else "false":u )
      parameter-3-72 =  "FOR EACH c-doc"
      parameter-4-72 =
        (
          if (" c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(sch-code) " + " " + where-phrase-72) <> ""
          then  substitute(' c-doc.chk-type = 40 and string(c-doc.chk-num) begins string(&2) ', chr(34), sch-code, sch-date)  + " " + where-phrase-72
          else "true"
        )
      parameter-5-72 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-72 = if sort-phrase-72 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-72
        )
      parameter-7-72 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-72)
                          ,input no-lock
                          ,input parameter-3-72
                          ,input parameter-4-72
                          ,input parameter-5-72
                          ,input parameter-6-72
                          ,input parameter-7-72
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
                           end.
                     end case.
                  end.
                  else
                  do:
                     case Cb-chk-type:
                        when "0" then
                           do:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-74  as logical   no-undo .
define variable  l-filter-open-74    as logical   .
define variable  flt-rec-74       as recid     no-undo .
define variable  filter-name-74      as character no-undo .
define variable  where-phrase-74     as character no-undo .
define variable  sort-phrase-74      as character no-undo .
define variable  where-phrase-rus-74 as character no-undo .
define variable  sort-phrase-rus-74  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-74
  ,output filter-name-74
  ,output where-phrase-74
  ,output sort-phrase-74
  ,output where-phrase-rus-74
  ,output sort-phrase-rus-74
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-74
      ) no-error .
  assign
    l-filter-open-74 = false
  .
  if flt-rec-74 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-74 as character no-undo .
    define variable  parameter-3-74 as character no-undo .
    define variable  parameter-4-74 as character no-undo .
    define variable  parameter-5-74 as character no-undo .
    define variable  parameter-6-74 as character no-undo .
    define variable  parameter-7-74 as character no-undo .
      assign
      parameter-3-74 =
                              "FOR EACH c-doc"
      parameter-4-74 =
        (
          if (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) " + " " + where-phrase-74) <> ""
          then " (c-doc.chk-type = 13 OR c-doc.chk-type = 40) " + " " + where-phrase-74
          else "true"
        )
      parameter-5-74 = (" " + "" + " " + "")
      parameter-6-74 = if sort-phrase-74 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-74
        )
      parameter-7-74 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-74 =
          (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) " + " " + where-phrase-74 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-74
                          ,input parameter-4-74
                          ,input parameter-5-74
                          ,input parameter-6-74
                          ,input parameter-7-74
                          )
      .
      assign
        l-filter-open-74 = true
      .
    end.
    if l-filter-open-74 = false then do:
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
  if l-filter-open-74 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where  (c-doc.chk-type = 13 OR c-doc.chk-type = 40)
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-74 = (if p-find-next then "true":u else "false":u )
      parameter-4-74 =
        "where ":u + " (c-doc.chk-type = 13 OR c-doc.chk-type = 40) " + " ":u + where-phrase-74 + " ":u + p-find-condition + " " + ""
      parameter-5-74 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-74)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-74
                          ,input parameter-5-74
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-74 = (if p-find-next then "true":u else "false":u )
      parameter-3-74 =  "FOR EACH c-doc"
      parameter-4-74 =
        (
          if (" (c-doc.chk-type = 13 OR c-doc.chk-type = 40) " + " " + where-phrase-74) <> ""
          then " (c-doc.chk-type = 13 OR c-doc.chk-type = 40) " + " " + where-phrase-74
          else "true"
        )
      parameter-5-74 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-74 = if sort-phrase-74 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-74
        )
      parameter-7-74 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-74)
                          ,input no-lock
                          ,input parameter-3-74
                          ,input parameter-4-74
                          ,input parameter-5-74
                          ,input parameter-6-74
                          ,input parameter-7-74
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
                           end.
                        when "13" then
                           do:
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-76  as logical   no-undo .
define variable  l-filter-open-76    as logical   .
define variable  flt-rec-76       as recid     no-undo .
define variable  filter-name-76      as character no-undo .
define variable  where-phrase-76     as character no-undo .
define variable  sort-phrase-76      as character no-undo .
define variable  where-phrase-rus-76 as character no-undo .
define variable  sort-phrase-rus-76  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-76
  ,output filter-name-76
  ,output where-phrase-76
  ,output sort-phrase-76
  ,output where-phrase-rus-76
  ,output sort-phrase-rus-76
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-76
      ) no-error .
  assign
    l-filter-open-76 = false
  .
  if flt-rec-76 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-76 as character no-undo .
    define variable  parameter-3-76 as character no-undo .
    define variable  parameter-4-76 as character no-undo .
    define variable  parameter-5-76 as character no-undo .
    define variable  parameter-6-76 as character no-undo .
    define variable  parameter-7-76 as character no-undo .
      assign
      parameter-3-76 =
                              "FOR EACH c-doc"
      parameter-4-76 =
        (
          if ("           (c-doc.chk-type = 13)
                          " + " " + where-phrase-76) <> ""
          then "           (c-doc.chk-type = 13)
                          " + " " + where-phrase-76
          else "true"
        )
      parameter-5-76 = (" " + "" + " " + "")
      parameter-6-76 = if sort-phrase-76 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-76
        )
      parameter-7-76 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-76 =
          ("           (c-doc.chk-type = 13)
                          " + " " + where-phrase-76 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-76
                          ,input parameter-4-76
                          ,input parameter-5-76
                          ,input parameter-6-76
                          ,input parameter-7-76
                          )
      .
      assign
        l-filter-open-76 = true
      .
    end.
    if l-filter-open-76 = false then do:
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
  if l-filter-open-76 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where            (c-doc.chk-type = 13)
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-76 = (if p-find-next then "true":u else "false":u )
      parameter-4-76 =
        "where ":u + "           (c-doc.chk-type = 13)
                          " + " ":u + where-phrase-76 + " ":u + p-find-condition + " " + ""
      parameter-5-76 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-76)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-76
                          ,input parameter-5-76
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-76 = (if p-find-next then "true":u else "false":u )
      parameter-3-76 =  "FOR EACH c-doc"
      parameter-4-76 =
        (
          if ("           (c-doc.chk-type = 13)
                          " + " " + where-phrase-76) <> ""
          then "           (c-doc.chk-type = 13)
                          " + " " + where-phrase-76
          else "true"
        )
      parameter-5-76 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-76 = if sort-phrase-76 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-76
        )
      parameter-7-76 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-76)
                          ,input no-lock
                          ,input parameter-3-76
                          ,input parameter-4-76
                          ,input parameter-5-76
                          ,input parameter-6-76
                          ,input parameter-7-76
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
                           end.
                        when "40" then
                           do:
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-78  as logical   no-undo .
define variable  l-filter-open-78    as logical   .
define variable  flt-rec-78       as recid     no-undo .
define variable  filter-name-78      as character no-undo .
define variable  where-phrase-78     as character no-undo .
define variable  sort-phrase-78      as character no-undo .
define variable  where-phrase-rus-78 as character no-undo .
define variable  sort-phrase-rus-78  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-78
  ,output filter-name-78
  ,output where-phrase-78
  ,output sort-phrase-78
  ,output where-phrase-rus-78
  ,output sort-phrase-rus-78
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-78
      ) no-error .
  assign
    l-filter-open-78 = false
  .
  if flt-rec-78 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-78 as character no-undo .
    define variable  parameter-3-78 as character no-undo .
    define variable  parameter-4-78 as character no-undo .
    define variable  parameter-5-78 as character no-undo .
    define variable  parameter-6-78 as character no-undo .
    define variable  parameter-7-78 as character no-undo .
      assign
      parameter-3-78 =
                              "FOR EACH c-doc"
      parameter-4-78 =
        (
          if ("           (c-doc.chk-type = 40)
                          " + " " + where-phrase-78) <> ""
          then "           (c-doc.chk-type = 40)
                          " + " " + where-phrase-78
          else "true"
        )
      parameter-5-78 = (" " + "" + " " + "")
      parameter-6-78 = if sort-phrase-78 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-78
        )
      parameter-7-78 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-78 =
          ("           (c-doc.chk-type = 40)
                          " + " " + where-phrase-78 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-78
                          ,input parameter-4-78
                          ,input parameter-5-78
                          ,input parameter-6-78
                          ,input parameter-7-78
                          )
      .
      assign
        l-filter-open-78 = true
      .
    end.
    if l-filter-open-78 = false then do:
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
  if l-filter-open-78 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where            (c-doc.chk-type = 40)
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
    v-doc-rec = recid( c-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer c-doc:handle) then do:
      assign
      parameter-2-78 = (if p-find-next then "true":u else "false":u )
      parameter-4-78 =
        "where ":u + "           (c-doc.chk-type = 40)
                          " + " ":u + where-phrase-78 + " ":u + p-find-condition + " " + ""
      parameter-5-78 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-78)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-78
                          ,input parameter-5-78
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-78 = (if p-find-next then "true":u else "false":u )
      parameter-3-78 =  "FOR EACH c-doc"
      parameter-4-78 =
        (
          if ("           (c-doc.chk-type = 40)
                          " + " " + where-phrase-78) <> ""
          then "           (c-doc.chk-type = 40)
                          " + " " + where-phrase-78
          else "true"
        )
      parameter-5-78 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-78 = if sort-phrase-78 = ''
                           then
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-78
        )
      parameter-7-78 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-78)
                          ,input no-lock
                          ,input parameter-3-78
                          ,input parameter-4-78
                          ,input parameter-5-78
                          ,input parameter-6-78
                          ,input parameter-7-78
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
                           end.
                     end case.
                  end.
         END.
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
   define variable date_string      as char      no-undo.
   define variable Line             as char      no-undo.
   define variable for-time         as char.
   define variable accum-count      as integer.
   define variable accum-tot-doc    as decimal.
   define variable accum-discnt     as decima.
   define variable accum-sub-discnt as decimal.
   define variable accum-netto      as decimal.
   define variable v-chk-type       as character no-undo .
   define variable v-shift-name-num as character no-undo.
   DEFINE FRAME Chk-List
      c-doc.office        column-label "Тип"                format "X(8)"
      c-doc.doc-code      column-label "Номер_чека"  format "X(17)"
      v-chk-type          column-label "Тип_чека"               format "X(8)"
      c-doc.chk-num       column-label "№/кассе" format "->>>>>>>9"
      c-doc.chk-date      column-label "Дата" format "99/99/9999"
      for-time            column-label "Время"   format "X(5)"
      c-doc.shift-date    column-label "Смена_от" format "99/99/9999"
      v-shift-name-num    column-label "N_см." FORMAT "X(6)"
      c-doc.discnt        column-label "Скидка_общая"
      c-doc.sub-discnt    column-label "Списания"
      c-doc.netto         column-label "Сумма_оплат"
      c-doc.pay-desk      column-label "Касса"
      c-doc.cashier       column-label "Кссир"       format ">>>>9"
      c-doc.sales-man     column-label "Прд-ц"       format ">>>>9"
      c-doc.out-code      column-label "Номер_РН"
      c-doc.d-card        column-label "Номер_диск._карты"              space(0)
      HEADER  date_string AT 5 format "X(35)"
      v-header-base-curr        format "X(20)" AT 42
      string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
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
      SPACE(25) ( frame Dialog-Frame:title )
      format "x(90)" SKIP(1) .
   FORM HEADER
      Line format "X(177)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
   VIEW  STREAM PrnLibStream FRAME BottomFrame .
   FORM with FRAME Chk-List  .
   run waitfram-show in this-procedure ( input "Ждите...").
   GET next br-docs  no-lock.
   DO WHILE available c-doc :
      v-chk-type = entry (lookup (string(c-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U) .
      Display STREAM PrnLibStream
         c-doc.office
         c-doc.doc-code
         v-chk-type
         c-doc.chk-num
         c-doc.chk-date
         string(c-doc.chk-time, "HH:mm") @ for-time
         c-doc.shift-date
         shift-name-no-err(buffer c-doc) @ v-shift-name-num
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
         accum-count      = accum-count + 1
         accum-tot-doc    = accum-tot-doc
         accum-discnt     = accum-discnt + c-doc.discnt
         accum-sub-discnt = accum-sub-discnt + c-doc.sub-discnt
         accum-netto      = accum-netto + c-doc.netto.
      GET next br-docs  no-lock.
   END.
   UNDERLINE  STREAM PrnLibStream
      c-doc.office
      c-doc.doc-code
      v-chk-type
      c-doc.chk-num
      c-doc.chk-date
      for-time
      c-doc.shift-date
      v-shift-name-num
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
      "______" @ v-shift-name-num
      accum-tot-doc
      accum-discnt @ c-doc.discnt
      accum-sub-discnt @ c-doc.sub-discnt
      accum-netto @ c-doc.netto
      with frame Chk-List.
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
   define variable date_string    as char      no-undo.
   define variable Line           as char      no-undo.
   define variable for-time       as char      no-undo.
   define variable accum-count    as integer   no-undo.
   define variable accum-qnty     as decimal   no-undo.
   define variable accum-tot-doc  as decimal   no-undo.
   define variable accum-discnt   as decimal   no-undo.
   define variable accum-netto    as decimal   no-undo.
   define variable fgds-discnt-pc as decimal   no-undo.
   define variable for-gds-sum    like chk-doc.netto no-undo.
   define variable for-gds-price  like chk-gds.price-base no-undo.
   define variable v-write-off    as logical   no-undo .
   define variable V-RECEIPT-NAME as character no-undo .
   DEFINE FRAME Goods-Frame
      chk-gds.doc-code column-label "Номер_чека" FORMAT "X(18)"
      v-receipt-name column-labeL "Тип_чека" format "x(8)"
      chk-gds.line-num column-label "NN" FORMAT "-999"
      chk-gds.b-code   column-label "Код"
      goods.artic
      goods.gds-name    FORMAT "X(27)"
      gds-prt.f-name   FORMAT "X(14)"
      chk-gds.is-error COLUMN-LABEL "Ош" FORMAT "+/ "
      chk-gds.src-code Column-label "Код в спул-файле" FORMAT "X(19)"
      chk-gds.pump column-label "ТРК"
      clients.obj-name    COLUMN-LABEL "Производитель" FORMAT "X(20)"
      chk-gds.doc-qnty
      bar-code.unit-cli     COLUMN-LABEL "Изм" FORMAT "X(3)"
      chk-gds.price-base
      chk-gds.discnt
      fgds-discnt-pc COLUMn-LABEL "% ск."  FORMAT "->9.99%"
      for-gds-price COLUMN-LABEL "Цена нетто"
      v-write-off COLUMn-LABEL "Сп" FORMAT "+/"
      HEADER  date_string AT 5 format "X(35)"
      v-header-base-curr        format "X(20)" AT 42
      string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
      Line format "X(230)" AT 1
      with width 232 down stream-io use-text .
   Line = fill("-", 230).
   date_string = cur-time-print() .
   run prn-lib-open-stream  in this-procedure (
      input parParentProc
      ,input 43
      ,input yes
      ,input no
      ).
   PUT  STREAM PrnLibStream
      SPACE(25) ( frame Dialog-Frame:title + ": строки чеков")
      format "x(90)" SKIP(1) .
   FORM HEADER
      Line format "X(230)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
   VIEW  STREAM PrnLibStream FRAME BottomFrame .
   FORM with FRAME Goods-Frame  .
   run waitfram-show in this-procedure ( input "Ждите...").
   GET next br-docs  no-lock.
   DO WHILE available c-doc :
      FOR EACH chk-gds NO-LOCK Where
         chk-gds.doc-code = c-doc.doc-code by chk-gds.line-num:
         FIND FIRST bar-code No-LOCK WHERE
            bar-code.b-code = chk-gds.b-code NO-ERROR.
         IF AVAIL bar-code then
         do:
            FIND FIRST goods NO-LOCK WHERE
               goods.gds-code = bar-code.gds-code NO-ERROR.
            FIND FIRST  clients NO-LOCK WHERE
               clients.obj-type = goods.prod-type AND
               clients.obj-code = goods.prod-code NO-ERROR.
            FIND FIRST gds-prt No-LOCK where
               gds-prt.upper-code = goods.prt-root NO-ERROR.
         end.
         assign
            fgds-discnt-pc = (chk-gds.discnt / (chk-gds.price-base + chk-gds.price-service) * 100)
            for-gds-sum    = (chk-gds.price-base + chk-gds.price-service - chk-gds.discnt) * chk-gds.doc-qnty
            for-gds-price  = chk-gds.price-base + chk-gds.price-service - chk-gds.discnt
            .
         DISPLAY Stream PrnLibStream
            chk-gds.doc-code
    entry (lookup (STRING(C-DOC.CHK-TYPE), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U) @ V-RECEIPT-NAME
    chk-gds.line-num
    chk-gds.b-code
    if avail bar-code then goods.artic else "" @ goods.artic
    if avail bar-code then goods.gds-name else "" @ goods.gds-name
    IF avail bar-code then (IF ( ub.gds-prt.node-name <> '_Пустая шкала':U)  then gds-prt.f-name  else "" ) else "" @ gds-prt.f-name
    chk-gds.is-error
    chk-gds.src-code
    chk-gds.pump
    if avail bar-code then clients.obj-name else "" @ clients.obj-name
    chk-gds.doc-qnty
    if avail bar-code then bar-code.unit-cli else "" @ bar-code.unit-cli
    (chk-gds.price-base + chk-gds.price-service) @ chk-gds.price-base
    chk-gds.discnt
    fgds-discnt-pc
    for-gds-price
    (if chk-gds.write-off-code <> ?
    and chk-gds.write-off-code <> 0
    then yes
    else no
    )  @ v-write-off
    WITH FRAME Goods-Frame.
         DOWN STREAM PrnLibStream with FRAME Goods-Frame .
         assign
            accum-count   = accum-count + 1
            accum-qnty    = accum-qnty + chk-gds.doc-qnty
            accum-tot-doc = accum-tot-doc + chk-gds.doc-qnty * (chk-gds.price-base + price-service)
            accum-discnt  = accum-discnt + chk-gds.doc-qnty * chk-gds.discnt
            accum-netto   = accum-netto + chk-gds.doc-qnty * (chk-gds.price-base + chk-gds.price-service - chk-gds.discnt)
            .
      END.
      GET next br-docs  no-lock.
   END.
   UNDERLINE  STREAM PrnLibStream
      chk-gds.doc-code
      chk-gds.line-num
      chk-gds.b-code
      goods.artic
      goods.gds-name
      gds-prt.f-name
      chk-gds.is-error
      chk-gds.src-code
      chk-gds.pump
      clients.obj-name
      chk-gds.doc-qnty
      bar-code.unit-cli
      chk-gds.price-base
      chk-gds.discnt
      fgds-discnt-pc
      for-gds-price
      v-write-off
      with FRAME Goods-Frame .
   DISPLAY STREAM PrnLibStream
      "ИТОГО"  @ chk-gds.doc-code
      "_" @ chk-gds.line-num
      accum-count @ chk-gds.b-code
      "_" @ goods.artic
      "_" @ goods.gds-name
      "_" @ gds-prt.f-name
      "_" @ chk-gds.is-error
      "_" @ chk-gds.src-code
      "_" @ chk-gds.pump
      "_" @ clients.obj-name
      ACCUM-qnty @ chk-gds.doc-qnty
      "_" @ bar-code.unit-cli
      accum-tot-doc @ chk-gds.price-base
(accum-discnt / accum-tot-doc * 100) @ fgds-discnt-pc
accum-discnt @ chk-gds.discnt
accum-netto @ for-gds-price
"_" @ v-write-off
WITH FRAME Goods-Frame.
   HIDE  STREAM PrnLibStream FRAME BottomFrame .
   HIDE  STREAM PrnLibStream FRAME Goods-Frame.
   output  STREAM PrnLibStream CLOSE.
   run waitfram-hide in this-procedure .
   run prn-lib-prn-file in this-procedure (
      input parParentProc
      ,input 9
      ).
END PROCEDURE.
PROCEDURE PrintprocGds-List :
   define variable v-num    as integer no-undo.
   define variable f-name   as char    no-undo.
   define variable lns-cnt  as integer no-undo .
   define variable line-rec as recid   no-undo .
   DEFINE VARIABLE ii       as integer no-undo .
   define variable glog     as logical no-undo .
   run waitfram-show in this-procedure ( input "Ждите...").
   FOR EACH gds-list :
      delete gds-list .
   END .
   FOR EACH gds-bar :
      delete gds-bar .
   END .
   GET next br-docs  no-lock.
   ii = 0.
   DO WHILE available c-doc :
      FOR EACH chk-gds NO-LOCK Where
         chk-gds.doc-code = c-doc.doc-code by chk-gds.line-num:
         FIND FIRST bar-code No-LOCK WHERE
            bar-code.b-code = chk-gds.b-code NO-ERROR.
         IF AVAIL bar-code then
         do:
            FIND FIRST goods NO-LOCK WHERE
               goods.gds-code = bar-code.gds-code NO-ERROR.
            FIND FIRST gds-prt No-LOCK where
               gds-prt.upper-code = goods.prt-root NO-ERROR.
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = goods.prod-type
    and gds-list.prod-code = goods.prod-code
    and gds-list.artic     = goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last79 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last79 = gds-list.order-num .
  end.
  else do:
    v-last79 = 0 .
  end.
  create gds-list .
  buffer-copy goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last79 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
            assign
               gds-list.qnty = gds-list.qnty + chk-gds.doc-qnty.
            FIND FIRST gds-bar where gds-bar.b-code = bar-code.b-code No-ERROR.
            if not avail gds-bar then
            do:
               create gds-bar.
               assign
                  gds-bar.b-code = bar-code.b-code.
            end.
            assign
               gds-bar.qnty = gds-bar.qnty + chk-gds.doc-qnty.
         end.
      END.
      GET next br-docs  no-lock.
   END.
   run waitfram-hide in this-procedure .
   REPEAT while v-num <> 4:
      run gbl/d-askw.w (
         input "Сохранение списка товаров"
         ,input "Выберите формат для сохранения списка товаров"
         ,input "|"
         ,input "Файл списка товаров|Файл мобильного сканера|Таблица EXCEL|Отказ"
         ,input "|||"
         ,input 1
         ,input 4
         ,output v-num ).
      if v-num = 4 then return.
      CASE v-num:
         when 1 then
            do:
               assign
                  f-name = "default.gds"
                  glog   = yes
                  .
               system-dialog get-file f-name
                  filters "Списки товаров *.gds" "*.gds"
                  ask-overwrite
                  save-as
                  use-filename
                  update glog
                  default-extension "gds".
               if not glog then
               do:
                  return.
               end.
               output to value (f-name).
               for each gds-list:
                  export gds-list.prod-type
                     gds-list.prod-code
                     gds-list.artic
                     gds-list.qnty
                     .
               end.
               output close.
            end.
         when 2 then
            do:
               assign
                  f-name = "default.inv"
                  glog   = yes
                  .
               system-dialog get-file f-name
                  filters "Инвентаризация касса *.inv" "*.inv"
                  ask-overwrite
                  save-as
                  use-filename
                  update glog
                  default-extension "inv".
               if not glog then
               do:
                  return .
               end.
               run waitfram-show in this-procedure ( input "Сохранение в формате мобильного сканера.    ЖДИТЕ...").
               output to value (f-name).
               for each gds-bar NO-LOCK:
                  if gds-bar.qnty <> 0 then
                     put unformatted string (gds-bar.b-code) + "," + string (gds-bar.qnty) skip.
               end.
               output close.
               run waitfram-hide in this-procedure .
            end.
         when 3 then
            do:
               do on stop  undo, return no-apply
                  on error undo, return no-apply
                  on quit  undo, return no-apply
                  :
                  run str/gdsl-xls.p (
                     input parparentproc
                     , input parobj-type
                     , input parobj-code) no-error.
                  run waitfram-hide in this-procedure .
               end.
            end.
      END CASE.
   end.
END PROCEDURE.
PROCEDURE PrintProcPay :
   define variable date_string    as char    no-undo.
   define variable Line           as char    no-undo.
   define variable for-time       as char.
   define variable accum-count    as integer.
   define variable accum-tot-base as decima.
   define variable accum-tot-rubl as decimal.
   define variable pay-card-num   like ub.chk-pay.pay-card no-undo .
   DEFINE FRAME Pay-Frame
      chk-pay.doc-code column-label "Номер_чека" FORMAT "X(20)"
      chk-pay.line-num column-label "NN"
      chk-pay.curr-code column-label "Код. вал"
      currency.curr-name column-label "Валюта" FORMAT "X(15)"
      chk-pay.pay-code Column-label "Код платежа"
      cash-pay.obj-name COLUMn-LABEL "Платеж"
      pay-card-num COLUMN-LABEL "Платежн.карта"
      chk-pay.tot-sum COLUMN-LABEL "Сумма в вал. платежа"
      chk-pay.tot-base COLUMN-LABEL "Сумма в баз.вал"
      chk-pay.tot-rubl  COLUMN-LABEL "Сумма в рублях"
      HEADER  date_string AT 5 format "X(35)"
      v-header-base-curr        format "X(20)" AT 42
      string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
      Line format "X(175)" AT 1
      with width 232 down stream-io use-text    .
   Line = fill("-", 175).
   date_string = cur-time-print() .
   run prn-lib-open-stream  in this-procedure (
      input parParentProc
      ,input 43
      ,input yes
      ,input no
      ).
   PUT  STREAM PrnLibStream
      SPACE(25) ( frame Dialog-Frame:title  + ": оплаты")
      format "x(90)" SKIP(1) .
   FORM HEADER
      Line format "X(175)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
   VIEW  STREAM PrnLibStream FRAME BottomFrame .
   FORM with FRAME Pay-Frame  .
   run waitfram-show in this-procedure ( input "Ждите...").
   GET next br-docs  no-lock.
   for each temp-pay:
      delete temp-pay.
   end.
   DO WHILE available c-doc :
      FOR EACH chk-pay No-LOCK WHERE chk-pay.doc-code = c-doc.doc-code by chk-pay.line-num:
         FIND FIRST currency No-LOCK WHERE
            currency.curr-code = chk-pay.curr-code NO-ERROR.
         FIND FIRST cash-pay No-LOCK WHERE
            cash-pay.cdpay-code = chk-pay.pay-code AND
            cash-pay.curr-code = chk-pay.curr-code No-ERROR.
         find first temp-pay WHERE
            temp-pay.pay-code = chk-pay.pay-code AND
            temp-pay.curr-code = chk-pay.curr-code NO-ERROR.
         if not avail temp-pay then
         do:
            create temp-pay.
            buffer-copy chk-pay except tot-base tot-sum tot-rubl line-num to temp-pay
               assign
               temp-pay.line-num = 0
               .
         end.
         assign
            temp-pay.tot-sum  = temp-pay.tot-sum + chk-pay.tot-sum
            temp-pay.tot-base = temp-pay.tot-base + chk-pay.tot-base
            temp-pay.tot-rubl = temp-pay.tot-rubl + chk-pay.tot-rubl
            temp-pay.line-num = temp-pay.line-num + 1
            .
         DISPLAY STREAM PrnLibStream
            chk-pay.doc-code
            chk-pay.line-num
            chk-pay.curr-code
            if avail currency then currency.curr-name else "НЕОПОЗНАННАЯ ВАЛЮТА" @ currency.curr-name
            chk-pay.pay-code
            if avail cash-pay then cash-pay.obj-name else "НЕОПОЗНАННАЯ ОПЛАТА" @ cash-pay.obj-name
            f-paycardv(chk-pay.pay-card, chk-pay.pay-code, chk-pay.curr-code) @ pay-card-num
            chk-pay.tot-sum
            chk-pay.tot-base
            chk-pay.tot-rubl
            WITH FRAME Pay-Frame.
         DOWN STREAM PrnLibStream  with frame Pay-Frame.
         assign
            accum-count    = accum-count + 1
            accum-tot-rubl = accum-tot-rubl + chk-pay.tot-rubl
            accum-tot-base = accum-tot-base + chk-pay.tot-base
            .
      END.
      GET next br-docs  no-lock.
   END.
   UNDERLINE  STREAM PrnLibStream
      chk-pay.doc-code
      chk-pay.line-num
      chk-pay.curr-code
      currency.curr-name
      chk-pay.pay-code
      cash-pay.obj-name
      pay-card-num
      chk-pay.tot-sum
      chk-pay.tot-base
      chk-pay.tot-rubl
      with FRAME Pay-Frame .
   for each temp-pay No-LOCK
      by temp-pay.pay-code
      by temp-pay.curr-code:
      FIND FIRST currency No-LOCK WHERE
         currency.curr-code = temp-pay.curr-code NO-ERROR.
      FIND FIRST cash-pay No-LOCK WHERE
         cash-pay.cdpay-code = temp-pay.pay-code AND
         cash-pay.curr-code = temp-pay.curr-code No-ERROR.
      DISPLAY STREAM PrnLibStream
         "кол. по типу оплаты:" @ chk-pay.doc-code
    (if temp-pay.line-num < 1000 then temp-pay.line-num else ?) @ chk-pay.line-num
    temp-pay.curr-code @ chk-pay.curr-code
    if avail currency then currency.curr-name else "НЕОПОЗНАННАЯ ВАЛЮТА" @ currency.curr-name
    temp-pay.pay-code @ chk-pay.pay-code
    if avail cash-pay then cash-pay.obj-name else "НЕОПОЗНАННАЯ ОПЛАТА" @ cash-pay.obj-name
    temp-pay.tot-sum @ chk-pay.tot-sum
    temp-pay.tot-base @ chk-pay.tot-base
    temp-pay.tot-rubl @ chk-pay.tot-rubl
    WITH FRAME Pay-Frame.
      DOWN STREAM PrnLibStream  with frame Pay-Frame.
   end.
   UNDERLINE  STREAM PrnLibStream
      chk-pay.doc-code
      chk-pay.line-num
      chk-pay.curr-code
      currency.curr-name
      chk-pay.pay-code
      cash-pay.obj-name
      pay-card-num
      chk-pay.tot-sum
      chk-pay.tot-base
      chk-pay.tot-rubl
      with FRAME Pay-Frame .
   DISPLAY STREAM PrnLibStream
      "ИТОГО"  @ chk-pay.doc-code
(if accum-count < 1000 then accum-count else ? )  @ chk-pay.line-num
"_" @ chk-pay.curr-code
"_" @ chk-pay.pay-code
"_" @ cash-pay.obj-name
string(accum-count) @ currency.curr-name
accum-tot-base @ chk-pay.tot-base
accum-tot-rubl @ chk-pay.tot-rubl
"_" @ chk-pay.tot-sum
with frame Pay-Frame.
   HIDE  STREAM PrnLibStream FRAME BottomFrame .
   HIDE  STREAM PrnLibStream FRAME Pay-Frame.
   output  STREAM PrnLibStream CLOSE.
   run waitfram-hide in this-procedure .
   run prn-lib-prn-file in this-procedure (
      input parParentProc
      ,input 8
      ).
END PROCEDURE.
PROCEDURE proc-b-chg :
   define input parameter p-change-type as character no-undo .
   DEFINE VARIABLE v-doc-rec              as recid     no-undo.
   DEFINE VARIABLE v-change-fields        as character no-undo .
   define variable v-can-back-shift       as logical   no-undo .
   DEFINE VARIABLE v-shift-date           like ub.chk-doc.shift-date no-undo .
   DEFINE VARIABLE v-shift-num            like ub.chk-doc.shift-num no-undo .
   define variable v-shift-name           like ub.chk-doc.shift-name no-undo .
   define variable v-shift-reservoir-from as int       no-undo.
   define variable v-shift-reservoir-to   as int       no-undo.
   DEFINE VARIABLE v-first-record         as recid     no-undo .
   define variable v-added                as logical   no-undo .
   define variable v-changed              as logical   no-undo.
   define variable v-added-num            as integer   no-undo .
   define variable v-changed-num          as int       no-undo.
   define variable l-shift-on             as logical   no-undo .
   define variable next-prev              as character no-undo .
   define variable glog                   as logical   no-undo .
   define variable v-pump                 like ub.chk-gds.pump no-undo .
   define variable v-b-code               like ub.chk-gds.b-code no-undo .
   do
      on error undo, return error
      on stop undo, return error
      :
      CASE p-change-type:
         when "one-change":U then
            do:
               if NOT available c-doc then
               do:
                  message
                     "Неправильно выбран чек."
                     view-as alert-box ERROR.
                  return error.
               end.
               if c-doc.out-code <> ? then
               do:
                  message
                     "Этот чек включен в отчет о продаже." skip
                     "Изменение невозможно."
                     view-as alert-box INFORMATION .
                  return error.
               end.
               assign
                  v-doc-rec = recid(c-doc).
               run str/superchk.w
                  (
                  input parparentproc
                  ,input 'ИЗМЕНЕНИЕ':U
                  ,input c-doc.obj-type
                  ,input c-doc.obj-code
                  ,input-output v-doc-rec
                  ,input ?
                  ,input-output next-prev
                  )
                  .
               RUN OpenBr in this-procedure ( input yes, input no, input '':U).
               REPOSITION br-docs to recid v-doc-rec no-error .
            end.
         when "list-shift":U then
            do:
               if p-change-type = "list-shift" then
               do:
                  message
                     "Вы хотите изменить дату, номер смены или резервуар для чеков?" skip
                     string(if index(frame Dialog-Frame:title,"ФИЛЬТР" ) = 0 then
                     "Эта процедура может занять долгое время! Продолжать?"
                     else "":U)
                     view-as alert-box WARNING buttons YES-NO update glog.
                  if NOT glog then return error.
                  run str/chgshift.w (
                     input parparentproc
                     ,input 'chk-doc':U
                     ,input parobj-type
                     ,input parobj-code
                     ,output v-shift-date
                     ,output v-shift-num
                     ,output v-shift-name
                     ,output v-shift-reservoir-from
                     ,output v-shift-reservoir-to
                     ,output v-change-fields
                     ,output v-can-back-shift
                     ).
                  if v-change-fields = '':U then return error.
               end.
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  'маг':U
  ,input  parobj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
               DO WHILE available c-doc :
                  GET prev br-docs  no-lock.
               END.
               GET next br-docs.
               if p-change-type = "list-shift" then
               do:
                  _shift:
                  DO WHILE available c-doc
                     on error undo, next _shift
                     on stop undo, next _shift
                     :
                     run waitfram-show in this-procedure ( input "Ждите...").
                     assign
                        v-doc-rec = recid(c-doc)
                        v-added   = no
                        v-changed = no.
                     .
                     run str/chkshift.p (
                        input parparentproc
                        ,input l-shift-on
                        ,input v-doc-rec
                        ,input v-shift-date
                        ,input v-shift-num
                        ,input v-shift-name
                        ,input v-shift-reservoir-from
                        ,input v-shift-reservoir-to
                        ,input v-change-fields
                        ,input v-can-back-shift
                        ,output v-added
                        ,output v-changed
                        ) no-error.
                     if error-status:error then
                     do:
                        GET next br-docs.
                        NEXT _shift.
                     end.
                     if v-changed then
                        assign
                           v-changed-num = v-changed-num + 1.
                     if v-added then
                        assign
                           v-added-num = v-added-num + 1
                           .
                     if v-first-record = ? then v-first-record = v-doc-rec.
                     GET next br-docs.
                  END.
                  run waitfram-hide in this-procedure .
               end.
               change-type = "".
               RUN OpenBr in this-procedure ( input yes, input no, input '':U).
               APPLY "page-UP"   to br-docs.
               APPLY "page-down"   to br-docs.
               reposition br-docs to recid v-first-record no-error.
               apply "entry" to br-docs in frame Dialog-Frame.
               if l-shift-on and p-change-type = "list-shift" then
               do:
                  message
                     substitute("В результате изменения даты/номера смены или резервуара в указанной смене появилось &1 чеков, изменено &2 чеков", v-added-num, v-changed-num)
                     view-as alert-box  .
               end.
               if p-change-type = "list-pump" then
               do:
                  message
                     substitute("N ТРК изменен для &1 чеков", v-added-num)
                     view-as alert-box .
               end.
            end.
      END CASE.
   end.
   run trg/userlog.p (
      input 'update':U
      , input 'chk-doc':U
      , input ( buffer c-doc :handle )
      , input ?
      , input ""
      ) no-error.
   if error-status :error
      then
   do:
      undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
         , chr(10)
         , vss-workfile
         , return-value
         , error-status :get-message ( 1 ) ).
   end.
END PROCEDURE.
PROCEDURE proc-b-del :
   define input parameter del-type as character no-undo.
   define variable old-netto      as decimal no-undo.
   define variable old-tot-doc    as decimal no-undo.
   define variable old-discnt     as decimal no-undo.
   DEFINE VARIABLE v-first-record as recid   no-undo .
   define variable glog           as logical no-undo .
   define variable v-doc-rec      as recid   no-undo .
   define variable v-host-code    as integer no-undo .
   define variable varlog         as logical no-undo .
   define buffer del_chk-doc for chk-doc.
   define buffer buf_inkas   for inkas.
   define buffer buf_trn-doc for ub.trn-doc.
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-host-code
  )  .
define variable vss-include-info82 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_receipts_deletion':U
    ,input  'object':U
    ,input  v-host-code
    ,input  c-doc.obj-type
    ,input  c-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
   if NOT glog then return no-apply.
   case del-type:
      when "list":U then
         do:
            IF par-mode = 'продажа':U then
            do:
               if index(frame Dialog-Frame:title,"ФИЛЬТР" ) = 0
                  and p-chk-type = 0
                  then
               do:
                  message
                     "Вы хотите исключить ВСЕ чеки из продажи!" skip
                     "Эта процедура может занять долгое время! Продолжать?"
                     view-as alert-box WARNING buttons YES-NO update glog.
                  if NOT glog then return no-apply.
               end.
               ELSE
               DO:
                  message
                     "Вы действительно хотите исключить ВСЕ чеки по текущему списку из продажи?!" skip
                     view-as alert-box WARNING buttons YES-NO update glog.
                  if NOT glog then return no-apply.
               END.
            end.
            ELSE
            DO:
               IF par-mode = 'vt':U then
               do:
                  message
                     "Вы действительно хотите исключить ВСЕ чеки по текущему списку из инвентаризации?!" skip
                     view-as alert-box WARNING buttons YES-NO update glog.
                  if NOT glog then return no-apply.
               end.
               else
               do:
                  if index(frame Dialog-Frame:title,"ФИЛЬТР" ) = 0
                     and p-chk-type = 0
                     then
                  do:
                     message
                        "Вы хотите удалить ВСЕ НЕУЧТЕННЫЕ чеки по объекту!" skip
                        "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
                        WARNING buttons YES-NO update glog.
                     if NOT glog then return no-apply.
                  end.
                  ELSE
                  DO:
                     message
                        "Вы действительно хотите удалить ВСЕ НЕУЧТЕННЫЕ чеки по текущему списку?!" skip
                        view-as alert-box WARNING buttons YES-NO update glog.
                     if NOT glog then return no-apply.
                  END.
               end.
            end.
         end.
   END CASE.
   CASE par-mode:
      WHEN 'продажа':U then
         do:
            if del-type = "list" then
            do:
               DO WHILE available c-doc :
                  GET prev br-docs  no-lock.
               END.
               GET NEXT br-docs.
               _list0:
               DO WHILE available c-doc
                  on error undo, next _list0
                  on stop undo, next _list0
                  :
                  FIND FIRST del_chk-doc where
                     recid (del_chk-doc) = recid(c-doc) No-ERROR.
                  if not avail del_chk-doc then NEXT _list0.
                  if del_chk-doc.out-code <> ? then
                  DO  :
                     run waitfram-show in this-procedure ( input "Ждите...").
                     FIND FIRST buf_inkas No-LOCK WHERE
                        buf_inkas.inkas-code = del_chk-doc.out-code No-ERROR.
                     assign
                        old-netto   = buf_inkas.netto
                        old-tot-doc = buf_inkas.tot-doc
                        old-discnt  = buf_inkas.discnt.
                     run str/excl-chk.p ( input parparentproc,  input v-curr-r-b, buffer del_chk-doc) no-error.
                     if error-status:error OR
                        (del_chk-doc.chk-type <> integer('43':U) and del_chk-doc.chk-type <> integer('44':U)
                        and
                        (buf_inkas.netto <> old-netto  - del_chk-doc.netto OR
                        buf_inkas.tot-doc <> old-tot-doc  - del_chk-doc.tot-doc OR
                        buf_inkas.discnt <> old-discnt - del_chk-doc.discnt)
                        )
                        then
                     do:
                        message
                           substitute("Исключение чека &1 из продажи &2 не удалось:&3&4 &5"
                           ,del_chk-doc.doc-code
                           ,del_chk-doc.out-code
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
               RUN OpenBr in this-procedure  ( input yes, input no, input '':U).
               APPLY "page-UP"   to br-docs.
               APPLY "page-down"   to br-docs.
               reposition br-docs to row 1 no-error.
               apply "entry" to br-docs in frame Dialog-Frame.
            end.
            if del-type = "one":U then
            do:
               if available c-doc then
               do:
                  if c-doc.out-code <> ? then
                  do:
                     FIND FIRST del_chk-doc where
                        recid (del_chk-doc) = recid(c-doc) No-ERROR.
                     if not avail del_chk-doc then return error.
                     varlog = br-docs:select-next-row().
                     if not varlog then varlog = br-docs:select-prev-row().
                     v-doc-rec = recid(c-doc).
                     FIND FIRST buf_inkas No-LOCK WHERE
                        buf_inkas.inkas-code = del_chk-doc.out-code No-ERROR.
                     assign
                        old-netto   = buf_inkas.netto
                        old-tot-doc = buf_inkas.tot-doc
                        old-discnt  = buf_inkas.discnt.
                     run str/excl-chk.p ( input parparentproc, input v-curr-r-b, buffer del_chk-doc) no-error.
                     if error-status:error  OR
                        buf_inkas.netto <> old-netto  - del_chk-doc.netto OR
                        buf_inkas.tot-doc <> old-tot-doc  - del_chk-doc.tot-doc OR
                        buf_inkas.discnt <> old-discnt - del_chk-doc.discnt then
                     do:
                        message
                           substitute("Исключение чека &1 из продажи &2 не удалось:&3&4 &5"
                           ,del_chk-doc.doc-code
                           ,del_chk-doc.out-code
                           , chr(10)
                           ,error-status:get-message(1)
                           ,return-value
                           )
                           view-as alert-box ERROR.
                        undo, return error .
                     end.
                     deleted = yes.
                     RUN OpenBr in this-procedure ( input yes, input no, input '':U).
                     reposition br-docs to recid v-doc-rec no-error.
                     APPLY "ENTRY" to br-docs.
                     APPLY "VALUE-CHANGED" to br-docs.
                     return no-apply.
                  end.
               end.
            end.
         END.
      WHEN 'vt':U then
         do:
            if del-type = "list" then
            do:
               DO WHILE available c-doc :
                  GET prev br-docs no-lock.
               END.
               GET NEXT br-docs.
               _list0:
               DO WHILE available c-doc
                  on error undo, next _list0
                  on stop undo, next _list0
                  :
                  v-doc-rec = recid( c-doc ).
                  FIND FIRST del_chk-doc where
                     recid (del_chk-doc) = v-doc-rec No-ERROR.
                  if not avail del_chk-doc then NEXT _list0.
                  if del_chk-doc.out-code <> ? then
                  DO  :
                     run waitfram-show in this-procedure ( input "Ждите...").
                     FIND FIRST buf_inkas No-LOCK WHERE
                        buf_inkas.inkas-code = del_chk-doc.out-code No-ERROR.
                     run str/exclichk.p ( input parparentproc,   buffer del_chk-doc) no-error.
                     if error-status:error then
                     do:
                        message
                           substitute("Исключение чека &1 из инвентаризации &2 не удалось:&3&4 &5"
                           ,del_chk-doc.doc-code
                           ,del_chk-doc.out-code
                           , chr(10)
                           ,error-status:get-message(1)
                           ,return-value
                           )
                           view-as alert-box ERROR.
                        undo, NEXT.
                     end.
                     deleted = yes.
                  END.
                  GET next br-docs .
               END.
               run waitfram-hide in this-procedure .
               del-type = "".
               RUN OpenBr in this-procedure( input yes,  input no,  input '':U).
               APPLY "page-UP"   to br-docs.
               APPLY "page-down"   to br-docs.
               reposition br-docs to row 1 no-error.
               apply "entry" to br-docs in frame Dialog-Frame.
            end.
            if del-type = "one":U then
            do:
               if available c-doc then
               do:
                  if c-doc.out-code <> ? then
                  do:
                     v-doc-rec = recid (c-doc).
                     FIND FIRST del_chk-doc where
                        recid (del_chk-doc) = v-doc-rec No-ERROR.
                     if not avail del_chk-doc then return error.
                     varlog = br-docs:select-next-row().
                     if not varlog then varlog = br-docs:select-prev-row().
                     v-doc-rec = recid(c-doc).
                     FIND FIRST buf_trn-doc No-LOCK WHERE
                        buf_trn-doc.doc-code = del_chk-doc.out-code No-ERROR.
                     run str/exclichk.p ( input parparentproc, buffer del_chk-doc) no-error.
                     if error-status:error  then
                     do:
                        message
                           substitute("Исключение чека &1 из инвентаризации &2 не удалось:&3&4 &5"
                           ,del_chk-doc.doc-code
                           ,del_chk-doc.out-code
                           , chr(10)
                           ,error-status:get-message(1)
                           ,return-value
                           )
                           view-as alert-box ERROR.
                        undo, return error .
                     end.
                     deleted = yes.
                     RUN OpenBr in this-procedure( input yes,  input no,  input '':U).
                     reposition br-docs to recid v-doc-rec no-error.
                     APPLY "ENTRY" to br-docs.
                     APPLY "VALUE-CHANGED" to br-docs.
                     return no-apply.
                  end.
               end.
            end.
         END.
      OTHERWISE
      DO:
         CASE del-type:
            when "list":U then
               do:
                  DO WHILE available c-doc :
                     GET prev br-docs  no-lock.
                  END.
                  GET NEXT br-docs.
                  _list1:
                  DO WHILE available c-doc
                     on error undo, next _list1
                     on stop undo, next _list1
                     :
                     run waitfram-show in this-procedure ( input "Ждите...").
                     FIND FIRST del_chk-doc where recid(del_chk-doc) = recid(c-doc) no-error.
                     if not avail del_chk-doc then next _list1.
                     run trg/userlog.p (
                        input 'delete':U
                        , input 'chk-doc':U
                        , input ( buffer del_chk-doc :handle )
                        , input ?
                        , input ""
                        ) no-error.
                     if error-status :error
                        then
                     do:
                        undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                           , chr(10)
                           , vss-workfile
                           , return-value
                           , error-status :get-message ( 1 ) ).
                     end.
                     if del_chk-doc.out-code = ? then delete del_chk-doc no-error .
                     if error-status:error then
                     do:
                        message
                           error-status:get-message(1) skip
                           return-value
                           view-as alert-box .
                     end.
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
            when "one":U then
               do:
                  if NOT available c-doc then
                  do:
                     message "Неправильно выбран чек." view-as alert-box ERROR.
                     return no-apply.
                  end.
                  FIND del_chk-doc where recid (del_chk-doc) = recid(c-doc) No-ERROR.
                  if not avail del_chk-doc then return error.
                  varlog = br-docs:select-next-row().
                  if not varlog then varlog = br-docs:select-prev-row().
                  v-doc-rec = recid(c-doc).
                  run trg/userlog.p (
                     input 'delete':U
                     , input 'chk-doc':U
                     , input ( buffer del_chk-doc :handle )
                     , input ?
                     , input ""
                     ) no-error.
                  if error-status :error
                     then
                  do:
                     undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                        , chr(10)
                        , vss-workfile
                        , return-value
                        , error-status :get-message ( 1 ) ).
                  end.
                  if del_chk-doc.out-code = ?  then delete del_chk-doc no-error.
                  if error-status:error then
                  do:
                     message
                        error-status:get-message(1) skip
                        return-value
                        view-as alert-box .
                     del-type = "".
                     return no-apply.
                  end.
                  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
                  reposition br-docs to recid v-doc-rec no-error.
                  APPLY "ENTRY" to br-docs.
                  APPLY "VALUE-CHANGED" to br-docs.
                  return no-apply.
               end.
         END CASE.
      END.
   END CASE.
END PROCEDURE.
PROCEDURE proc-b-sch :
   define variable l-shift-on as logical   no-undo .
   define variable conf-attr  as character no-undo .
   define variable conf-par   as character no-undo .
   define variable par-type   as character no-undo .
   define variable cas-shft   as logical   no-undo .
   assign
      sch-code = ""
      sch-date = ?
      .
   display
      sch-code
      sch-date
      .
   assign
      tbl      = 'chk-doc'
      join-tbl = 'c-doc'
      fld      = ""
      lab      = ""
      spr      = ""
      dim      = '0'
      .
   run fltfield-add in this-procedure('chk-date', 'Дата чека на АРМ кассира', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
   run fltfield-add in this-procedure('shift-name', '№ смены', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
   run fltfield-add in this-procedure('obj-code', 'Номер магазина', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
   run fltfield-add in this-procedure('chk-num', 'Номер чека', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
   run fltfield-add in this-procedure('pay-desk', 'Номер АРМ Кассира', '',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
   run fltfield-add in this-procedure('chk-time', 'Время чека', 'time',
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
   Filter-Block:
   DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
      ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
      ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
      run gbl/filter.w ( input parparentproc
         , INPUT (filter-point + chr(4) + filter-label)
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
   define input parameter pardoc-code like ub.chk-doc.doc-code no-undo.
   assign
      pardoc-code = chr(34) + pardoc-code + chr(34).
   run OpenBr in this-procedure (
      input true
      ,input par-next
      ,input substitute("and c-doc.doc-code   begins &1 "
      , pardoc-code)
      ).
   apply "entry":u to sch-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-date :
   define input parameter par-next as logical no-undo.
   define input parameter parchk-date like ub.chk-doc.chk-date no-undo.
   define variable varchk-datechr as character no-undo.
   assign
      varchk-datechr = string(day(parchk-date)) + chr(47) +
                 string(month(parchk-date)) + chr(47) +
                 string(year(parchk-date)).
   run OpenBr in this-procedure (
      input true
      ,input true
      ,input substitute("and c-doc.chk-date = &1 "
      , varchk-datechr)
      ).
   apply "entry":u to sch-date in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-find-sum :
   define input parameter par-next as logical no-undo.
   define input parameter partot-doc like ub.chk-doc.tot-doc no-undo.
   assign
      sch-date = ?
      .
   display
      sch-date
      "":U @ sch-code
      with frame Dialog-Frame.
   run OpenBr in this-procedure (
      input false
      ,input par-next
      ,input substitute("and c-doc.netto = &1 "
      , partot-doc)
      ).
END PROCEDURE.
PROCEDURE reposition-chk-doc :
   define input  parameter p-direction   as character no-undo .
   define output parameter p-chk-doc-recid as recid no-undo .
   case p-direction :
      when "first":U
      then
         do:
            get first br-docs.
         end.
      when "last":U
      then
         do:
            get last br-docs.
         end.
      when "prev":U
      then
         do:
            get prev br-docs.
            if not available c-doc then
            do:
               message
                  "Это первый чек списка"
                  view-as alert-box.
            end.
         end.
      when "next":U
      then
         do:
            get next br-docs.
            if not available c-doc then
            do:
               message
                  "Это последний чек списка"
                  view-as alert-box.
            end.
         end.
   end case .
   assign
      p-chk-doc-recid = recid(c-doc)
      .
   run reposition-query in this-procedure
      (input p-chk-doc-recid
      ).
END PROCEDURE.
PROCEDURE reposition-query :
   define input parameter p-recid as recid no-undo .
   if p-recid <> ?
      then
   do:
      reposition br-docs to recid p-recid no-error.
   end.
   do with frame Dialog-Frame:
      apply "entry":u to browse BR-docs .
      apply "VALUE-CHANGED":u to browse BR-docs .
   end.
END PROCEDURE.
