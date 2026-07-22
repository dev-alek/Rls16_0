DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_dis-card FOR ub.dis-card.
DEFINE BUFFER buf_icnt-doc FOR ub.icnt-doc.
DEFINE BUFFER buf_inkas FOR ub.inkas.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_shop FOR ub.shop.
DEFINE BUFFER buf_trn-doc FOR ub.trn-doc.
DEFINE BUFFER buf_wth-doc FOR ub.wth-doc.
DEFINE BUFFER c-doc FOR ub.chk-doc.
DEFINE BUFFER dis-obj FOR ub.dis-obj.
DEFINE BUFFER find_chk-doc FOR ub.chk-doc.
DEFINE BUFFER find_inkas FOR ub.inkas.
DEFINE BUFFER find_trn-doc FOR ub.trn-doc.
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
define input parameter par-mode  as char   no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parout-code like ub.chk-doc.out-code no-undo.
define input parameter pard-card like ub.chk-doc.d-card no-undo.
define input parameter p-pay-desk as integer no-undo .
define input parameter p-start-date like ub.chk-doc.chk-date no-undo .
define input parameter p-end-date like ub.chk-doc.chk-date no-undo .
define input parameter p-chk-type as integer no-undo .
define output param rid-list    as  char no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: 6557e99634e7, 3192, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: EShklyar $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: 2022/12/27 12:54:28 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: chk-docs.w $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: str/chk-docs.w $":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список чеков":U.
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
define variable filter-label as character no-undo init "Список чеков" .
define variable filter-label0 as character no-undo init "Список чеков" .
define variable filter-point0 as character no-undo init 'чеки':U .
define variable filter-point as character no-undo init 'чеки':U .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .
define variable chk-spfc as logical init no no-undo.
define  variable cas-shft as logical no-undo init no.
define variable l-shift-on as logical no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-rep-rec as recid no-undo .
define variable v-print-host-code like ub.sysconf.host-code no-undo.
define buffer buf_cli for ub.clients.
define buffer out_inkas for ub.inkas .
define buffer buf_currency for ub.currency.
define variable v-base-code like ub.currency.curr-code no-undo .
define variable v-base-type like ub.currency.curr-abbr no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-start as logical no-undo init yes.
DEFINE VARIABLE v-chk-autotank AS CHARACTER NO-UNDO .
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
field b-code like ub.bar-code.b-code
field qnty   as decimal
index art is unique b-code .
define temp-table temp-pay no-undo like ub.chk-pay
index pi is unique primary pay-code curr-code
.
DEFINE MENU m-chg
       MENU-ITEM m-one-change   LABEL "Изменить один чек"
       MENU-ITEM m-list-shift   LABEL "Изменить список чеков".
DEFINE MENU m-del
       MENU-ITEM m-list-del     LABEL "Удалить список чеков"
       MENU-ITEM m-one-del      LABEL "Удалить один чек".
DEFINE MENU m-print
       MENU-ITEM m-list         LABEL "Список чеков"
       MENU-ITEM m-gds          LABEL "Список строк чеков"
       MENU-ITEM m-pay          LABEL "Список оплат чеков"
       MENU-ITEM m-one          LABEL "Чек"
       MENU-ITEM m-gds-list     LABEL "Товары чеков в файл"
       MENU-ITEM m-spcf         LABEL "Спецификация"
       MENU-ITEM m-akt-spi    LABEL "Акт списания"
         .
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменение чека".
DEFINE BUTTON B-del
     LABEL "&Удал"
     SIZE 10 BY 1 TOOLTIP "Удаление чека/исключение чека из документа".
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр чека".
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1 TOOLTIP "Печать списка чеков, списка строк по всем чекам, списка оплат ...".
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sale
     LABEL "&Док-нт"
     SIZE 10 BY 1 TOOLTIP "Просмотр документа, к которому привязан чек(продажа, инвентаризация)".
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1 TOOLTIP "Установка фильтра на список чеков".
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
     LABEL "номер"
     VIEW-AS FILL-IN
     SIZE 19.13 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999":U
     LABEL "дата"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-sum AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "сумма оплат"
     VIEW-AS FILL-IN
     SIZE 19.13 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE QUERY BR-docs FOR c-doc SCROLLING.
DEFINE BROWSE BR-docs
  QUERY BR-docs DISPLAY
      c-doc.office FORMAT "X(255)":U WIDTH 7
      mark-string(RECID( c-doc), rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      c-doc.doc-code COLUMN-LABEL "Номер_чека" FORMAT "X(20)":U
      entry (lookup (string(c-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U) COLUMN-LABEL "Тип_чека" FORMAT "X(8)":U
      c-doc.chk-num COLUMN-LABEL "№/кассе" FORMAT "->>>>>>>>9":U
      v-chk-autotank COLUMN-LABEL "СдНал" FORMAT 'x(1)':U
      c-doc.chk-date FORMAT "99/99/9999":U
      (string (c-doc.chk-time, "HH:MM"))
      c-doc.shift-date COLUMN-LABEL "Смена_от" FORMAT "99/99/9999":U
      shift-name-no-err(buffer c-doc) COLUMN-LABEL "№ смены" FORMAT "X(6)":U
      c-doc.netto COLUMN-LABEL "Сумма_оплат" FORMAT "->>>,>>>,>>9.99":U
      c-doc.tot-doc COLUMN-LABEL "Сумма_товарная" FORMAT "->>>,>>>,>>9.99":U
      c-doc.discnt COLUMN-LABEL "Скидка_общая" FORMAT "->>>,>>>,>>9.99":U
      c-doc.sub-discnt COLUMN-LABEL "Списания" FORMAT "->>>,>>>,>>9.99":U
      c-doc.pay-desk FORMAT ">>>9":U
      c-doc.cashier FORMAT "99999":U
      c-doc.sales-man COLUMN-LABEL "Прод-ц" FORMAT "99999":U
      c-doc.out-code COLUMN-LABEL "Номер_РН" FORMAT "X(14)":U
      c-doc.d-card COLUMN-LABEL "N_диск._карты" FORMAT "X(19)":U
      c-doc.doc-num COLUMN-LABEL "№_док-та" FORMAT "X(22)":U
      c-doc.doc-num2 COLUMN-LABEL "№_заказа" FORMAT "X(22)":U
      c-doc.src-tot-doc COLUMN-LABEL "Брутто-чек" FORMAT "->,>>>,>>9.99"
  ENABLE
      c-doc.cashier
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.67.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lookup AT ROW 1 COL 31
     B-chg AT ROW 1 COL 41
     B-del AT ROW 1 COL 51
     B-sale AT ROW 1 COL 61
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     Cb-chk-type AT ROW 2 COL 1 NO-LABEL
     BR-docs AT ROW 2.67 COL 1
     ED-notes AT ROW 18.67 COL 1 NO-LABEL
     sch-code AT ROW 20.83 COL 20 COLON-ALIGNED
     sch-date AT ROW 20.83 COL 48.25 COLON-ALIGNED
     sch-sum AT ROW 20.83 COL 77.5 COLON-ALIGNED
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     "ПОИСК" VIEW-AS TEXT
          SIZE 6 BY 1 AT ROW 20.79 COL 1.5
          FGCOLOR 4
     SPACE(91.50) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-chg:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-chg:HANDLE.
ASSIGN
       B-del:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-del:HANDLE.
ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-print:HANDLE.
ON END-ERROR OF FRAME Dialog-Frame
DO:
  if deleted then return "deleted".
END.
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
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define variable v-host-code as integer no-undo .
  define buffer s-doc for ub.trn-doc.
  if not available c-doc then return no-apply.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  c-doc.obj-type
  ,input  c-doc.obj-code
  ,output v-host-code
  )  .
  if change-type = '':U then do:
    run gbl/pop-up.p ( input b-chg:handle, input no) no-error.
  end.
  if change-type = '':U then return no-apply.
  if change-type <> "list-shift" and
  (c-doc.chk-type = integer('44':U)
  or c-doc.chk-type = integer('43':U) )
  then do :
    message "Чеки коррекции нельзя изменять!" view-as alert-box.
    return no-apply.
  end.
  run proc-b-chg in this-procedure ( input change-type) no-error.
  assign
  change-type = "":U.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
 if del-type = "" then do:
    run gbl/pop-up.p ( input b-del:handle, input no) no-error.
 end.
 if del-type = "" then return no-apply.
   if c-doc.chk-type = 13 or c-doc.chk-type = 40 then
   do:
      message
         "Удаление чеков открытия/закрытия смены невозможно."
         view-as alert-box INFORMATION .
      return no-apply.
   end.
run proc-b-del in this-procedure ( input del-type) no-error.
if error-status:error then do:
    del-type = '':U.
    return no-apply.
end.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
define variable next-prev as character no-undo .
define variable v-doc-rec as recid no-undo .
assign
next-prev = '':U
.
DO WHILE next-prev = '':U:
  if NOT available c-doc then do:
          message "Неправильно выбран чек." view-as alert-box ERROR.
          return no-apply.
  end.
  v-doc-rec = recid(c-doc).
    run str/superchk.w
                  (
                    input parparentproc
                    ,input 'ПРОСМОТР':U
                    ,input c-doc.obj-type
                    ,input c-doc.obj-code
                    ,input-output v-doc-rec
                    ,input this-procedure:handle
                    ,input-output next-prev
                                )
    .
END .
apply "entry" to br-docs in frame Dialog-Frame.
apply "value-changed" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
  if available c-doc then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid18 as character no-undo .
define variable v-num-entry18 as integer   no-undo .
assign
  v-str-recid18 = trim( string( recid( c-doc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry18 = lookup( v-str-recid18 , rid-list )
.
if v-num-entry18 > 0 then do:
  assign
    entry( v-num-entry18, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid18
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
define variable v-doc-rec as recid no-undo .
define variable glog as logical no-undo .
define buffer s-doc for ub.trn-doc.
if NOT available c-doc then do:
  return no-apply.
end.
  if print-type = "" then do:
    run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if print-type = "list":U or print-type = "gds":U or print-type = "pay":U or print-type = "gds-list":U then do:
    if par-mode = 'объект':U and index(frame Dialog-Frame:title,"ФИЛЬТР" ) = 0 then do:
      CASE print-type:
        when "list":U then do:
              message "Вы хотите напечатать весь список чеков по объекту при невключенном фильтре!" skip
              "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
            WARNING buttons YES-NO update glog.
            if NOT glog then return no-apply.
        end.
        when "gds":U then do:
              message "Вы хотите напечатать строки всего списка чеков по объекту при невключенном фильтре!" skip
              "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
            WARNING buttons YES-NO update glog.
            if NOT glog then return no-apply.
        end.
        when "pay":U then do:
              message "Вы хотите напечатать оплаты всего списка чеков по объекту при невключенном фильтре!" skip
              "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
            WARNING buttons YES-NO update glog.
            if NOT glog then return no-apply.
        end.
        when "gds-list":U then do:
              message "Вы хотите сохранить товары всего списка чеков по объекту при невключенном фильтре!" skip
                      "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
            WARNING buttons YES-NO update glog.
            if NOT glog then return no-apply.
        end.
      when "akt-spi" then do:
          end.
      END CASE.
    end.
    v-doc-rec = recid( c-doc ).
    DO WHILE available c-doc :
          GET prev br-docs no-lock.
    END.
    CASE print-type:
      when "list":U then do:
        run PrintProc in this-procedure.
      end.
      when "gds":U then do:
        run PrintProcGds in this-procedure.
      end.
      when "pay":U then do:
        run PrintProcPay in this-procedure.
      end.
      when "gds-list":U then do:
        run PrintProcGds-list in this-procedure.
      end.
    END CASE.
    print-type = "".
    reposition br-docs to recid v-doc-rec no-error.
    apply "entry" to br-docs in frame Dialog-Frame.
  end.
  else do:
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
        when "one":U then do:
          if lookup(string(c-doc.chk-type), '2,3,4,5,7':U) > 0 then do:
            run str/checkwp.p ( input parparentproc, input c-doc.doc-code) no-error.
            print-type = "".
          end.
          else do:
            run str/checkp.p ( input parparentproc, input c-doc.doc-code) no-error.
            print-type = "".
          end.
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
 define buffer lkp_trn-doc for ub.trn-doc.
  if NOT available c-doc then do:
      message "Неправильно выбран чек." view-as alert-box ERROR.
      return no-apply.
  end.
  find first lkp_trn-doc no-lock where
            lkp_trn-doc.doc-code = c-doc.out-code no-error.
  if not available lkp_trn-doc then do:
    message
    "Для данного чека нет документа."
    view-as alert-box .
    return no-apply.
  end.
  case lkp_trn-doc.ext-doc-type:
    when 'es':U then do:
      FIND find_inkas where
                find_inkas.inkas-code = c-doc.out-code.
      run str/ink-lkp.p ( input parparentproc, input recid(find_inkas) ).
    end.
    when 'vt':U then do:
      run str/showdoc.p (  input parparentproc
                      ,input lkp_trn-doc.doc-code
                      ,input '':U
                      ,input '':U
                      ,input 0
                      ,input true).
      end.
  end case.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if ( available c-doc ) AND ( rid-list = "" ) then
    rid-list = string( recid( c-doc ) ) .
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
      if b-sel:sensitive in frame Dialog-Frame then
      APPLY "CHOOSE" to b-sel.
END.
ON ROW-DISPLAY OF BR-docs IN FRAME Dialog-Frame
DO:
  IF CAN-FIND(FIRST chk-pay WHERE chk-pay.doc-code = c-doc.doc-code
                           AND chk-pay.line-num > 1 AND
      CAN-FIND(FIRST chk-pay-attr WHERE chk-pay-attr.doc-code = chk-pay.doc-code
               AND chk-pay-attr.line-num = chk-pay.line-num
               AND chk-pay-attr.attr-code = "autotank-sum-return")) THEN
   DO:
      ASSIGN
          v-chk-autotank = "+"
          .
   END.
   ELSE
       v-chk-autotank = "" .
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
  define variable is-cre as integer no-undo .
  define buffer ps_chk-doc for ub.chk-doc.
  if not available c-doc then return no-apply.
   DO on stop undo, return no-apply:
        FIND PS_chk-doc where recid (ps_chk-doc) = recid(c-doc) exclusive.
        assign
        is-cre = index(ps_chk-doc.PS, "!":U)
        .
        if ps_CHk-doc.PS <> input frame Dialog-Frame ed-notes then
        assign
        ps_chk-doc.PS = (if is-cre > 0 then "!":U else "":U) +
                        left-trim(input frame Dialog-Frame ed-notes, "!":U)
        .
    END.
END.
ON CHOOSE OF MENU-ITEM m-gds
DO:
    print-type = "gds":U.
    apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-gds-list
DO:
      print-type = "gds-list":U.
    apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-akt-spi
DO:
      print-type = "akt-spi":U.
    apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-list
DO:
    print-type = "list":U.
    apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-list-del
DO:
   del-type = "list".
    apply "choose" to b-del in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-list-shift
DO:
   change-type = "list-shift":U.
   apply "choose" to b-chg in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-one
DO:
    print-type = "one":U.
    apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-one-change
DO:
    change-type = "one-change":U.
    apply "choose" to b-chg in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-one-del
DO:
  del-type = "one".
    apply "choose" to b-del in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-pay
DO:
      print-type = "pay":U.
    apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-spcf
DO:
    print-type = "spcf":U.
    apply "choose" to b-print in frame Dialog-Frame.
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
ON CTRL-J OF sch-sum IN FRAME Dialog-Frame
DO:
  run proc-find-sum in this-procedure ( input yes, input frame Dialog-Frame sch-sum) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-sum IN FRAME Dialog-Frame
DO:
  run proc-find-sum in this-procedure ( input no, input frame Dialog-Frame sch-sum) no-error.
  if error-status:error then return no-apply.
END.
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
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lookup :sensitive then DO: apply "CHOOSE":U to b-lookup in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date29
    MENU-ITEM m-ed-date29-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date29-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date29-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date29-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date29 :HANDLE
      sch-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle29 as handle no-undo .
  assign
    v-label-handle29 = sch-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle29)
  then do:
    if v-label-handle29 :tooltip = ""
    or v-label-handle29 :tooltip = ?
    then do:
      assign
        v-label-handle29 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date29-1 in menu m-ed-date29 DO:
    apply "ctrl-b":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date29-2 in menu m-ed-date29 DO:
    apply "ctrl-d":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date29-3 in menu m-ed-date29 DO:
    apply "ctrl-e":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date29-4 in menu m-ed-date29 DO:
    apply "ctrl-f":U to sch-date in frame Dialog-Frame .
  END.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-rep-rec = ?. if available c-doc then v-rep-rec = recid(c-doc). RUn OpenBR in this-procedure ( input yes, input no, input '':U).  reposition br-docs to recid v-rep-rec no-error.
    apply "VALUE-CHANGED" to BR-docs.
end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-docs :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    or when  'объект':U
    or when "free":U
    or when "chk-date":U
    or when 'vt':U
    or when 'dis-card':U
    or when 'IBS-TH':U
    THEN DO:
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
    WHEN 'продажа':U  or when ("d-card" + chr(44) + 'продажа':U) or when "to-sale":U then do:
        FIND buf_inkas where buf_inkas.inkas-code = parout-code NO-LOCK no-error.
      if not avail buf_inkas then do:
          message vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова parout-code" parout-code
          view-as alert-box ERROR.
          return.
      end.
    end.
    WHEN "out-code":U then do:
        FIND buf_wth-doc where buf_wth-doc.doc-code = parout-code NO-LOCK no-error.
      if not avail buf_wth-doc then do:
          message vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова parout-code" parout-code
          view-as alert-box ERROR.
          return.
      end.
    end.
    when "chk-date":U then do:
      if p-start-date > p-end-date
      or p-start-date = ?
      or p-end-date = ?
      then do:
          message vss-workfile vss-revision vss-description skip
          "Неверное значение параметров p-start-date p-end-date" p-start-date p-end-date
          view-as alert-box ERROR.
          return.
      end.
    end.
    when "to-inv" then do:
      FIND buf_trn-doc where buf_trn-doc.doc-code = parout-code NO-LOCK no-error.
      if not avail buf_trn-doc then do:
          message vss-workfile vss-revision vss-description skip
          "Неверное значение параметра вызова parout-code" parout-code
          view-as alert-box ERROR.
          return.
      end.
    end.
    when "to-" + 'сч-трк-погр':U
    or
    when 'сч-трк-погр':U
    then do:
      if parout-code <> '':U then do:
        FIND buf_icnt-doc where buf_icnt-doc.doc-code = parout-code NO-LOCK no-error.
        if not avail buf_icnt-doc then do:
            message vss-workfile vss-revision vss-description skip
            "Неверное значение параметра вызова parout-code" parout-code
            view-as alert-box ERROR.
            return.
        end.
      end.
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - par-mode=" par-mode
      view-as alert-box ERROR.
      return.
    end.
  end CASE.
    if pardoc-rec <> ? then do:
      FIND FIRST find_chk-doc No-LOCK where
                 recid(find_chk-doc) = pardoc-rec No-ERROR.
      if not avail find_chk-doc then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова pardoc-rec" pardoc-rec
        view-as alert-box error .
        return error.
      end.
    end.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  if v-curr-r-b = 'base':U then do:
    if v-print-host-code <> 0 then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if p-chk-type > 0
  and lookup(string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,43,44':U) = 0 then do:
    message
    substitute("Неверное значение параметра p-chk-type=&1", p-chk-type)
    view-as alert-box error .
    undo, return error ''.
  end.
  RUN MyEnable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-docs as INT EXTENT 20 no-undo.
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
       IF  par-mode = 'vt':U or p-chk-type <> 0  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,19,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,20') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,19,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,20'))] , 3).
   END.
       END.
       IF  par-mode = 'IBS-TH':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,4,5,6,7,10,11,12,13,14,15,16,18,20,8,9,17,19') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,4,5,6,7,10,11,12,13,14,15,16,18,20,8,9,17,19'))] , 3).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs ( 3, 20).
END.
ON ctrl-cursor-left OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (20, 3).
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
  if cur-clmn-loc <= 3 then do:
    return .
  end.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-loc THEN move-elementbr-docs = varmvibr-docs.
  END.
  RUN re-move-clmnbr-docs (cur-clmn-loc, 3).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-docs = 3 to EXTENT(cur-clmn-numbr-docs):
    RUN re-move-clmnbr-docs (cur-clmn-numbr-docs[varmvlbr-docs], varmvlbr-docs).
  END.
  RUN start-mv-clmnbr-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
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
  DISPLAY Cb-chk-type ED-notes sch-code sch-date sch-sum mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-lookup B-chg B-del B-sale B-print B-sch B-Help
         Cb-chk-type BR-docs ED-notes sch-code sch-date sch-sum mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE get-params :
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
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
IF not error-status:error then do:
  chk-spfc = v-value-logical.
end.
delete object v-tth.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type36 as character no-undo .
define variable v-value-character36 as character no-undo .
define variable v-value-date36 as date no-undo .
define variable v-value-decimal36 as decimal no-undo .
define variable v-value-integer36 as INTEGER no-undo .
define variable v-tth36 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  parobj-type
    ,input  parobj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character36
    ,output v-value-date36
    ,output v-value-decimal36
    ,output v-value-integer36
    ,output cas-shft
    ,output v-param-type36
    ,INPUT-OUTPUT table-handle v-tth36
    )  .
delete object v-tth36.
find first buf_shop no-lock where buf_shop.obj-code = parobj-code.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  'маг':U
  ,input  parobj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
END PROCEDURE.
PROCEDURE MyEnable :
DEF VAR v-hdl AS HANDLE NO-UNDO .
if par-mode = 'IBS-TH':U
and lookup(string(p-chk-type), '201,206,208,301,306':U) = 0 then do:
  assign
  sch-code:label in frame Dialog-Frame = "№/кассе"
  .
end.
ASSIGN
c-doc.doc-code:resizable in browse br-docs = yes
c-doc.doc-code:width in browse br-docs = 16
cb-chk-type:LIST-ITEM-PAIRS  in frame Dialog-Frame =  "Все типы чеков" + chr(44) + '0':U + chr(44) +
                                                       'Продажа,1,Возврат,6,ВзврСпис,96,СбросТрнзкц,14,Перелив,15,ПеревТрнзкц,16,РазблТрнзкц,36,ТехПролив,17,Списание,69,Аннуляция,8,Инвентаризация,11,Закрытие_смены,13,Открытие_смены,40,Z-отчет,12,_Продажа,101,_Возврат,106,_ВзврСпис,196,_СбросТрнзкц,114,_Перелив,115,_ПеревТрнзкц,116,_ТехПролив,117,_Списание,169,_Аннуляция,108,_Инвентаризация,111,_Z-отчет,112,_СбросТрнзкц,114,_РазблТрнзкц,136,_Закрытие_смены,113,>Продажа,201,>Возврат,206,>Аннуляция,208,>>Продажа,301,>>Возврат,306,Инкассация,2,Касс_фонд,3,Перевод_опл,4,Расход_кассы,5,Декл_ден_ящ,7,Приход_Корр,43,Расход_Корр,44':U
cb-chk-type = string(p-chk-type)
br-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 6
b-chg:MENU-MOUSE = 1
b-print:MENU-MOUSE = 1
b-del:MENU-MOUSE = 1
c-doc.cashier:READ-ONLY IN BROWSE BR-docs = YES
c-doc.office:RESIZABLE IN BROWSE BR-docs = YES
.
run get-params in this-procedure no-error .
ASSIGN b-del:MENU-MOUSE = 1.
if lookup(par-mode, 'продажа':U + chr(44) + 'vt':U) > 0 then do:
    assign
    pardoc-rec = ?
    b-del:label = "Искл&ючить"
    menu-item m-list-shift:sensitive in menu m-chg = no
    menu-item m-one-change:sensitive in menu m-chg = no
    .
end.
if par-mode = "to-inv" then do:
  cb-chk-type = '11':U.
  p-chk-type = integer('11':U).
end.
if par-mode = 'сч-трк-погр':U
or par-mode = "to-" + 'сч-трк-погр':U
then do:
  cb-chk-type = '17':U.
  p-chk-type = integer('17':U).
end.
DISPLAY
cb-chk-type when (par-mode = 'продажа':U
                 or par-mode = "free"
                 or par-mode = "to-sale"
                 or par-mode = "to-inv"
                 or par-mode = 'сч-трк-погр':U
                 or par-mode = "to-" + 'сч-трк-погр':U
                 or par-mode = 'объект':U
                 or par-mode = 'IBS-TH':U
                 )
ED-notes
sch-code
sch-date
sch-sum
mark-num
WITH FRAME Dialog-Frame .
ENABLE
cb-chk-type when (par-mode = 'продажа':U
                 or par-mode = "free"
                 or par-mode = "to-sale"
                 or par-mode = 'объект':U
                 or par-mode = "chk-date"
                 or par-mode = 'dis-card':U
                 or par-mode = "d-card"
                 or par-mode = 'продажа':U
                 or par-mode = "out-code"
                 or par-mode = 'IBS-TH':U
                 ) and (p-chk-type = 0 or p-chk-type = ?)
b-quit
b-lookup
b-sch
b-sale when par-mode <> 'продажа':U
b-help
br-docs
b-sel  when LOOKUP("b-sel":U, bttns) > 0
b-mark when LOOKUP("b-mark":U, bttns) > 0
sch-code
sch-date
sch-sum
ed-notes
b-del when LOOKUP("b-del":U, bttns) > 0
b-chg when par-mode <> 'продажа':U
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
if par-mode = 'продажа':U then do:
  IF available buf_inkas and (buf_inkas.status_ = 'факт':U or buf_inkas.status_ = 'запрос':U)
  then disable b-del  with frame Dialog-Frame.
end.
if par-mode = 'vt':U then do:
  IF available buf_trn-doc and buf_trn-doc.status_ <> 'накл':U
  then disable b-del  with frame Dialog-Frame.
end.
if not chk-spfc then
menu-item m-spcf:sensitive in menu m-print  = no .
if (cb-chk-type:visible in frame Dialog-Frame  = yes) then do:
  assign
  br-docs:height = br-docs:height  - 0.5
  br-docs:row = br-docs:row + 0.5
  .
end.
else do:
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
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Список чеков" + chr(32).
define variable sort-column-phrase as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
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
  CASE par-mode :
    WHEN 'все':U        THEN DO:
      assign
      filter-point = filter-point0 + par-mode
      filter-label = substitute("&1", filter-label0)
      .
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
          if (" TRUE " + " " + where-phrase-39) <> ""
          then " TRUE " + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + "")
      parameter-6-39 = if sort-phrase-39 = ''
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
          (" TRUE " + " " + where-phrase-39 = "")
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
      where  TRUE
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
        "where ":u + " TRUE " + " ":u + where-phrase-39 + " ":u + p-find-condition + " " + ""
      parameter-5-39 = "  "
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
          if (" TRUE " + " " + where-phrase-39) <> ""
          then " TRUE " + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-39 = if sort-phrase-39 = ''
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
    END.
    WHEN 'объект':U THEN DO:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
      assign
      filter-point = filter-point0 + par-mode
      filter-label = substitute("&1 Один объект", filter-label0)
      .
      if p-chk-type = 0 then do:
       if p-open-query then do:
        ASSIGN
        frame Dialog-Frame:TITLE = substitute("&1 Объект: &2&3", title0 , parobj-type , parobj-code)
              .
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
                              "FOR EACH c-doc"
      parameter-4-42 =
        (
          if ("           c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code                            " + " " + where-phrase-42) <> ""
          then  substitute('c-doc.obj-type  = &1&2&1  AND           c-doc.obj-code  = &3 ', chr(34), parobj-type, parobj-code)  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "")
      parameter-6-42 = if sort-phrase-42 = ''
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
          ("           c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code                            " + " " + where-phrase-42 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where            c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code
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
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-4-42 =
        "where ":u +  substitute('c-doc.obj-type  = &1&2&1  AND           c-doc.obj-code  = &3 ', chr(34), parobj-type, parobj-code)  + " ":u + where-phrase-42 + " ":u + p-find-condition + " " + ""
      parameter-5-42 = " USE-INDEX obj-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
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
      parameter-3-42 =  "FOR EACH c-doc"
      parameter-4-42 =
        (
          if ("           c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code                            " + " " + where-phrase-42) <> ""
          then  substitute('c-doc.obj-type  = &1&2&1  AND           c-doc.obj-code  = &3 ', chr(34), parobj-type, parobj-code)  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-42 = if sort-phrase-42 = ''
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
        " " + sort-phrase-42
        )
      parameter-7-42 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
      end.
      else do:
        if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Объект: &2&3 &4", title0 , parobj-type , parobj-code, entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)).
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
                              "FOR EACH c-doc"
      parameter-4-44 =
        (
          if ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.chk-type = p-chk-type                       " + " " + where-phrase-44) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.chk-type = &4 ', chr(34), parobj-type, parobj-code, p-chk-type)  + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "")
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + " USE-INDEX ichk-type " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX ichk-type " +
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
          ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.chk-type = p-chk-type                       " + " " + where-phrase-44 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where                  c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.chk-type = p-chk-type
       USE-INDEX ichk-type
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
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-4-44 =
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.chk-type = &4 ', chr(34), parobj-type, parobj-code, p-chk-type)  + " ":u + where-phrase-44 + " ":u + p-find-condition + " " + ""
      parameter-5-44 = " USE-INDEX ichk-type "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
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
      parameter-3-44 =  "FOR EACH c-doc"
      parameter-4-44 =
        (
          if ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.chk-type = p-chk-type                       " + " " + where-phrase-44) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.chk-type = &4 ', chr(34), parobj-type, parobj-code, p-chk-type)  + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + " USE-INDEX ichk-type " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX ichk-type " +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
      end.
    END.
    WHEN "chk-date":U THEN DO:
       assign
       filter-point = filter-point0 + par-mode
       filter-label = substitute("&1 по датам", filter-label0)
       .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
       if p-chk-type = 0 then do:
       if p-open-query then do:
        ASSIGN frame Dialog-Frame:TITLE = substitute((title0 + " Объект: &1&2 c &3 по &4")
                                                      , parobj-type
                                                      , parobj-code
                                                      , string(p-start-date)
                                                      , string(p-end-date))
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
          if ("           c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code  AND           c-doc.chk-date  >= p-start-date  AND           c-doc.chk-date  <= p-end-date                        " + " " + where-phrase-47) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND           c-doc.obj-code  = &3  AND           c-doc.chk-date  >= &4  AND           c-doc.chk-date  <= &5  ', chr(34), parobj-type, parobj-code, p-start-date, p-end-date)  + " " + where-phrase-47
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
          ("           c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code  AND           c-doc.chk-date  >= p-start-date  AND           c-doc.chk-date  <= p-end-date                        " + " " + where-phrase-47 = "")
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
      where            c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code  AND           c-doc.chk-date  >= p-start-date  AND           c-doc.chk-date  <= p-end-date
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
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND           c-doc.obj-code  = &3  AND           c-doc.chk-date  >= &4  AND           c-doc.chk-date  <= &5  ', chr(34), parobj-type, parobj-code, p-start-date, p-end-date)  + " ":u + where-phrase-47 + " ":u + p-find-condition + " " + ""
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
          if ("           c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code  AND           c-doc.chk-date  >= p-start-date  AND           c-doc.chk-date  <= p-end-date                        " + " " + where-phrase-47) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND           c-doc.obj-code  = &3  AND           c-doc.chk-date  >= &4  AND           c-doc.chk-date  <= &5  ', chr(34), parobj-type, parobj-code, p-start-date, p-end-date)  + " " + where-phrase-47
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
      else do:
        if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE = substitute((title0 + " Объект: &1&2 c &3 по &4, &5")
                                                    , parobj-type
                                                    , parobj-code
                                                    , string(p-start-date)
                                                    , string(p-end-date)
                                                    ,entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)
                                                    )
                                                    .
        end.
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
          if ("           c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code  AND           c-doc.chk-date  >= p-start-date  AND           c-doc.chk-date  <= p-end-date  AND           c-doc.chk-type = p-chk-type                       " + " " + where-phrase-49) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND           c-doc.obj-code  = &3  AND           c-doc.chk-date  >= &4  AND           c-doc.chk-date  <= &5  AND           c-doc.chk-type = &6 ', chr(34), parobj-type, parobj-code, p-start-date, p-end-date, p-chk-type)  + " " + where-phrase-49
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
          ("           c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code  AND           c-doc.chk-date  >= p-start-date  AND           c-doc.chk-date  <= p-end-date  AND           c-doc.chk-type = p-chk-type                       " + " " + where-phrase-49 = "")
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
      where            c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code  AND           c-doc.chk-date  >= p-start-date  AND           c-doc.chk-date  <= p-end-date  AND           c-doc.chk-type = p-chk-type
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
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND           c-doc.obj-code  = &3  AND           c-doc.chk-date  >= &4  AND           c-doc.chk-date  <= &5  AND           c-doc.chk-type = &6 ', chr(34), parobj-type, parobj-code, p-start-date, p-end-date, p-chk-type)  + " ":u + where-phrase-49 + " ":u + p-find-condition + " " + ""
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
          if ("           c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code  AND           c-doc.chk-date  >= p-start-date  AND           c-doc.chk-date  <= p-end-date  AND           c-doc.chk-type = p-chk-type                       " + " " + where-phrase-49) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND           c-doc.obj-code  = &3  AND           c-doc.chk-date  >= &4  AND           c-doc.chk-date  <= &5  AND           c-doc.chk-type = &6 ', chr(34), parobj-type, parobj-code, p-start-date, p-end-date, p-chk-type)  + " " + where-phrase-49
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
    END.
    WHEN 'dis-card':U    THEN DO:
       assign
       filter-point = filter-point0 + "ДК":U
       filter-label = substitute("&1 с ДК по объекту", filter-label0)
       .
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
       if p-chk-type = 0 then do:
         if p-open-query then do:
           ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки по всем ДК Объект &2&3"
                                                      , title0
                                                      , parobj-type
                                                      , parobj-code).
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
                              "FOR EACH c-doc"
      parameter-4-52 =
        (
          if ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  > '':U                             " + " " + where-phrase-52) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3  AND             c-doc.d-card  > &1&4&1 ', chr(34), parobj-type, parobj-code, chr(32) ) + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + "")
      parameter-6-52 = if sort-phrase-52 = ''
                           then
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX d-card " +
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
          ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  > '':U                             " + " " + where-phrase-52 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where              c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  > '':U
       USE-INDEX d-card
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
      parameter-2-52 = (if p-find-next then "true":u else "false":u )
      parameter-4-52 =
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3  AND             c-doc.d-card  > &1&4&1 ', chr(34), parobj-type, parobj-code, chr(32) ) + " ":u + where-phrase-52 + " ":u + p-find-condition + " " + ""
      parameter-5-52 = " USE-INDEX d-card "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-52)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
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
      parameter-3-52 =  "FOR EACH c-doc"
      parameter-4-52 =
        (
          if ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  > '':U                             " + " " + where-phrase-52) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3  AND             c-doc.d-card  > &1&4&1 ', chr(34), parobj-type, parobj-code, chr(32) ) + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-52 = if sort-phrase-52 = ''
                           then
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + sort-phrase-52
        )
      parameter-7-52 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
       end.
       else do:
                 if p-open-query then do:
            ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки по всем ДК Объект &2&3, &4"
                                                      , title0
                                                      , parobj-type
                                                      , parobj-code
                                                      ,entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)
                                                      ).
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
                              "FOR EACH c-doc"
      parameter-4-54 =
        (
          if ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  > '':U                             " + " " + where-phrase-54) <> ""
          then  substitute('c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3  AND             c-doc.d-card  > &1&4&1 ', chr(34),  parobj-type, parobj-code, chr(32))  + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + "")
      parameter-6-54 = if sort-phrase-54 = ''
                           then
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX d-card " +
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
          ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  > '':U                             " + " " + where-phrase-54 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where              c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  > '':U
       USE-INDEX d-card
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
      parameter-2-54 = (if p-find-next then "true":u else "false":u )
      parameter-4-54 =
        "where ":u +  substitute('c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3  AND             c-doc.d-card  > &1&4&1 ', chr(34),  parobj-type, parobj-code, chr(32))  + " ":u + where-phrase-54 + " ":u + p-find-condition + " " + ""
      parameter-5-54 = " USE-INDEX d-card "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-54)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
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
      parameter-3-54 =  "FOR EACH c-doc"
      parameter-4-54 =
        (
          if ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  > '':U                             " + " " + where-phrase-54) <> ""
          then  substitute('c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3  AND             c-doc.d-card  > &1&4&1 ', chr(34),  parobj-type, parobj-code, chr(32))  + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-54 = if sort-phrase-54 = ''
                           then
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + sort-phrase-54
        )
      parameter-7-54 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
       end.
    END.
    WHEN "d-card":U    THEN DO:
       assign
       filter-point = filter-point0 + "КЛИЕНТ":U
       filter-label = substitute("&1 одна ДК по объекту", filter-label0)
       .
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
       if p-chk-type = 0 then do:
         if p-open-query then do:
            ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки по карте № &2 Объект &3&4"
                                                      , title0
                                                      , pard-card
                                                      , parobj-type
                                                      , parobj-code).
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
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
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
                              "FOR EACH c-doc"
      parameter-4-57 =
        (
          if ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  = pard-card                              " + " " + where-phrase-57) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3  AND             c-doc.d-card  = &1&4&1', chr(34), parobj-type, parobj-code, pard-card )   + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + "")
      parameter-6-57 = if sort-phrase-57 = ''
                           then
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + sort-phrase-57
        )
      parameter-7-57 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-57 =
          ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  = pard-card                              " + " " + where-phrase-57 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where              c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  = pard-card
       USE-INDEX d-card
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
      parameter-2-57 = (if p-find-next then "true":u else "false":u )
      parameter-4-57 =
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3  AND             c-doc.d-card  = &1&4&1', chr(34), parobj-type, parobj-code, pard-card )   + " ":u + where-phrase-57 + " ":u + p-find-condition + " " + ""
      parameter-5-57 = " USE-INDEX d-card "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-57)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
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
      parameter-3-57 =  "FOR EACH c-doc"
      parameter-4-57 =
        (
          if ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  = pard-card                              " + " " + where-phrase-57) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3  AND             c-doc.d-card  = &1&4&1', chr(34), parobj-type, parobj-code, pard-card )   + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-57 = if sort-phrase-57 = ''
                           then
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + sort-phrase-57
        )
      parameter-7-57 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
  run waitfram-hide in this-procedure .
       end.
       else do:
                if p-open-query then do:
           ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки по карте № &2 Объект &3&4, &5"
                                                      , title0
                                                      , pard-card
                                                      , parobj-type
                                                      , parobj-code
                                                      ,entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)
                                                      ).
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
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
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
                              "FOR EACH c-doc"
      parameter-4-59 =
        (
          if ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  = pard-card                              " + " " + where-phrase-59) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3  AND             c-doc.d-card  = &1&4&1 ', chr(34), parobj-type, parobj-code, pard-card)   + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + "")
      parameter-6-59 = if sort-phrase-59 = ''
                           then
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + sort-phrase-59
        )
      parameter-7-59 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-59 =
          ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  = pard-card                              " + " " + where-phrase-59 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
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
    OPEN QUERY br-docs FOR EACH c-doc
      where              c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  = pard-card
       USE-INDEX d-card
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
      parameter-2-59 = (if p-find-next then "true":u else "false":u )
      parameter-4-59 =
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3  AND             c-doc.d-card  = &1&4&1 ', chr(34), parobj-type, parobj-code, pard-card)   + " ":u + where-phrase-59 + " ":u + p-find-condition + " " + ""
      parameter-5-59 = " USE-INDEX d-card "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-59)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
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
      parameter-3-59 =  "FOR EACH c-doc"
      parameter-4-59 =
        (
          if ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code  AND             c-doc.d-card  = pard-card                              " + " " + where-phrase-59) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3  AND             c-doc.d-card  = &1&4&1 ', chr(34), parobj-type, parobj-code, pard-card)   + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-59 = if sort-phrase-59 = ''
                           then
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + sort-phrase-59
        )
      parameter-7-59 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
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
  run waitfram-hide in this-procedure .
       end.
    END.
    WHEN ("d-card":U  + chr(44) + 'продажа':U)   THEN DO:
       assign
       filter-point = filter-point0 + "КЛИЕНТ":U
       filter-label = substitute("&1 одна ДК по одной продаже", filter-label0)
       .
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
       if p-open-query then do:
         ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки по карте № &2 и отчету &3 Объект &4&5"
                                                     , title0
                                                     , pard-card
                                                     , parout-code
                                                     , parobj-type
                                                     , parobj-code).
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
          if ("           c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code  AND           c-doc.d-card  = pard-card      AND           c-doc.out-code = parout-code                       " + " " + where-phrase-62) <> ""
          then  substitute('  c-doc.obj-type  = &1&2&1  AND           c-doc.obj-code  = &3  AND           c-doc.d-card  = &1&4&1     AND           c-doc.out-code = &1&5&1 ', chr(34), parobj-type, parobj-code, pard-card , parout-code)   + " " + where-phrase-62
          else "true"
        )
      parameter-5-62 = (" " + "" + " " + "")
      parameter-6-62 = if sort-phrase-62 = ''
                           then
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX d-card " +
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
          ("           c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code  AND           c-doc.d-card  = pard-card      AND           c-doc.out-code = parout-code                       " + " " + where-phrase-62 = "")
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
      where            c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code  AND           c-doc.d-card  = pard-card      AND           c-doc.out-code = parout-code
       USE-INDEX d-card
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
        "where ":u +  substitute('  c-doc.obj-type  = &1&2&1  AND           c-doc.obj-code  = &3  AND           c-doc.d-card  = &1&4&1     AND           c-doc.out-code = &1&5&1 ', chr(34), parobj-type, parobj-code, pard-card , parout-code)   + " ":u + where-phrase-62 + " ":u + p-find-condition + " " + ""
      parameter-5-62 = " USE-INDEX d-card "
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
          if ("           c-doc.obj-type  = parobj-type  AND           c-doc.obj-code  = parobj-code  AND           c-doc.d-card  = pard-card      AND           c-doc.out-code = parout-code                       " + " " + where-phrase-62) <> ""
          then  substitute('  c-doc.obj-type  = &1&2&1  AND           c-doc.obj-code  = &3  AND           c-doc.d-card  = &1&4&1     AND           c-doc.out-code = &1&5&1 ', chr(34), parobj-type, parobj-code, pard-card , parout-code)   + " " + where-phrase-62
          else "true"
        )
      parameter-5-62 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-62 = if sort-phrase-62 = ''
                           then
        (
        " " + " USE-INDEX d-card " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX d-card " +
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
    END.
    WHEN 'продажа':U
    or when "out-code"
    THEN DO:
       assign
       filter-point = filter-point0 + par-mode
       filter-label = (if par-mode = 'продажа':U
                       then substitute("&1 одна продажа", filter-label0)
                       else substitute("&1 один документ", filter-label0)
                       )
       .
      if p-chk-type = 0 then do:
        if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE =  (if par-mode = 'продажа':U
                                              then substitute("&1 Чеки по отчету № &2", title0, parout-code)
                                              else substitute("&1 Чеки по документу № &2", title0, parout-code)
                                              ).
        end.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-65  as logical   no-undo .
define variable  l-filter-open-65    as logical   .
define variable  flt-rec-65       as recid     no-undo .
define variable  filter-name-65      as character no-undo .
define variable  where-phrase-65     as character no-undo .
define variable  sort-phrase-65      as character no-undo .
define variable  where-phrase-rus-65 as character no-undo .
define variable  sort-phrase-rus-65  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-65
  ,output filter-name-65
  ,output where-phrase-65
  ,output sort-phrase-65
  ,output where-phrase-rus-65
  ,output sort-phrase-rus-65
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-65
      ) no-error .
  assign
    l-filter-open-65 = false
  .
  if flt-rec-65 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-65 as character no-undo .
    define variable  parameter-3-65 as character no-undo .
    define variable  parameter-4-65 as character no-undo .
    define variable  parameter-5-65 as character no-undo .
    define variable  parameter-6-65 as character no-undo .
    define variable  parameter-7-65 as character no-undo .
      assign
      parameter-3-65 =
                              "FOR EACH c-doc"
      parameter-4-65 =
        (
          if ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.out-code  = parout-code                            " + " " + where-phrase-65) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.out-code  = &1&4&1 ', chr(34), parobj-type, parobj-code, parout-code)    + " " + where-phrase-65
          else "true"
        )
      parameter-5-65 = (" " + "" + " " + "")
      parameter-6-65 = if sort-phrase-65 = ''
                           then
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + sort-phrase-65
        )
      parameter-7-65 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-65 =
          ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.out-code  = parout-code                            " + " " + where-phrase-65 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-65
                          ,input parameter-4-65
                          ,input parameter-5-65
                          ,input parameter-6-65
                          ,input parameter-7-65
                          )
      .
      assign
        l-filter-open-65 = true
      .
    end.
    if l-filter-open-65 = false then do:
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
  if l-filter-open-65 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where                  c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.out-code  = parout-code
       USE-INDEX chk-out
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
      parameter-2-65 = (if p-find-next then "true":u else "false":u )
      parameter-4-65 =
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.out-code  = &1&4&1 ', chr(34), parobj-type, parobj-code, parout-code)    + " ":u + where-phrase-65 + " ":u + p-find-condition + " " + ""
      parameter-5-65 = " USE-INDEX chk-out "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-65)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-65
                          ,input parameter-5-65
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-65 = (if p-find-next then "true":u else "false":u )
      parameter-3-65 =  "FOR EACH c-doc"
      parameter-4-65 =
        (
          if ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.out-code  = parout-code                            " + " " + where-phrase-65) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.out-code  = &1&4&1 ', chr(34), parobj-type, parobj-code, parout-code)    + " " + where-phrase-65
          else "true"
        )
      parameter-5-65 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-65 = if sort-phrase-65 = ''
                           then
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + sort-phrase-65
        )
      parameter-7-65 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-65)
                          ,input no-lock
                          ,input parameter-3-65
                          ,input parameter-4-65
                          ,input parameter-5-65
                          ,input parameter-6-65
                          ,input parameter-7-65
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
      else do:
        if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE =  (if par-mode = 'продажа':U
                                              then substitute("&1 Чеки по отчету № &2: &3", title0, parout-code, entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                              else substitute("&1 Чеки по документу № &2: &3", title0, parout-code, entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                              ).
        end.
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-67  as logical   no-undo .
define variable  l-filter-open-67    as logical   .
define variable  flt-rec-67       as recid     no-undo .
define variable  filter-name-67      as character no-undo .
define variable  where-phrase-67     as character no-undo .
define variable  sort-phrase-67      as character no-undo .
define variable  where-phrase-rus-67 as character no-undo .
define variable  sort-phrase-rus-67  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-67
  ,output filter-name-67
  ,output where-phrase-67
  ,output sort-phrase-67
  ,output where-phrase-rus-67
  ,output sort-phrase-rus-67
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-67
      ) no-error .
  assign
    l-filter-open-67 = false
  .
  if flt-rec-67 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-67 as character no-undo .
    define variable  parameter-3-67 as character no-undo .
    define variable  parameter-4-67 as character no-undo .
    define variable  parameter-5-67 as character no-undo .
    define variable  parameter-6-67 as character no-undo .
    define variable  parameter-7-67 as character no-undo .
      assign
      parameter-3-67 =
                              "FOR EACH c-doc"
      parameter-4-67 =
        (
          if ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.out-code  = parout-code  AND
                c-doc.chk-type = p-chk-type                       " + " " + where-phrase-67) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.out-code  = &1&4&1  AND
                c-doc.chk-type = &1&5&1 ', chr(34), parobj-type, parobj-code, parout-code, p-chk-type)  + " " + where-phrase-67
          else "true"
        )
      parameter-5-67 = (" " + "" + " " + "")
      parameter-6-67 = if sort-phrase-67 = ''
                           then
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + sort-phrase-67
        )
      parameter-7-67 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-67 =
          ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.out-code  = parout-code  AND
                c-doc.chk-type = p-chk-type                       " + " " + where-phrase-67 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-67
                          ,input parameter-4-67
                          ,input parameter-5-67
                          ,input parameter-6-67
                          ,input parameter-7-67
                          )
      .
      assign
        l-filter-open-67 = true
      .
    end.
    if l-filter-open-67 = false then do:
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
  if l-filter-open-67 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where                  c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.out-code  = parout-code  AND
                c-doc.chk-type = p-chk-type
       USE-INDEX chk-out
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
      parameter-2-67 = (if p-find-next then "true":u else "false":u )
      parameter-4-67 =
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.out-code  = &1&4&1  AND
                c-doc.chk-type = &1&5&1 ', chr(34), parobj-type, parobj-code, parout-code, p-chk-type)  + " ":u + where-phrase-67 + " ":u + p-find-condition + " " + ""
      parameter-5-67 = " USE-INDEX chk-out "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-67)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-67
                          ,input parameter-5-67
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-67 = (if p-find-next then "true":u else "false":u )
      parameter-3-67 =  "FOR EACH c-doc"
      parameter-4-67 =
        (
          if ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.out-code  = parout-code  AND
                c-doc.chk-type = p-chk-type                       " + " " + where-phrase-67) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.out-code  = &1&4&1  AND
                c-doc.chk-type = &1&5&1 ', chr(34), parobj-type, parobj-code, parout-code, p-chk-type)  + " " + where-phrase-67
          else "true"
        )
      parameter-5-67 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-67 = if sort-phrase-67 = ''
                           then
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + sort-phrase-67
        )
      parameter-7-67 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-67)
                          ,input no-lock
                          ,input parameter-3-67
                          ,input parameter-4-67
                          ,input parameter-5-67
                          ,input parameter-6-67
                          ,input parameter-7-67
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
    END.
    WHEN 'vt':U   THEN DO:
       assign
       filter-point = filter-point0 + par-mode
       filter-label = substitute("&1 одна инвентаризация", filter-label0)
       .
       if p-open-query then do:
         ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки по документу инвентаризации № &2", title0, parout-code).
       end.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-69  as logical   no-undo .
define variable  l-filter-open-69    as logical   .
define variable  flt-rec-69       as recid     no-undo .
define variable  filter-name-69      as character no-undo .
define variable  where-phrase-69     as character no-undo .
define variable  sort-phrase-69      as character no-undo .
define variable  where-phrase-rus-69 as character no-undo .
define variable  sort-phrase-rus-69  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-69
  ,output filter-name-69
  ,output where-phrase-69
  ,output sort-phrase-69
  ,output where-phrase-rus-69
  ,output sort-phrase-rus-69
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-69
      ) no-error .
  assign
    l-filter-open-69 = false
  .
  if flt-rec-69 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-69 as character no-undo .
    define variable  parameter-3-69 as character no-undo .
    define variable  parameter-4-69 as character no-undo .
    define variable  parameter-5-69 as character no-undo .
    define variable  parameter-6-69 as character no-undo .
    define variable  parameter-7-69 as character no-undo .
      assign
      parameter-3-69 =
                              "FOR EACH c-doc"
      parameter-4-69 =
        (
          if ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.out-code  = parout-code                       " + " " + where-phrase-69) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.out-code  = &1&4&1 ', chr(34), parobj-type, parobj-code, parout-code)  + " " + where-phrase-69
          else "true"
        )
      parameter-5-69 = (" " + "" + " " + "")
      parameter-6-69 = if sort-phrase-69 = ''
                           then
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + sort-phrase-69
        )
      parameter-7-69 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-69 =
          ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.out-code  = parout-code                       " + " " + where-phrase-69 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-69
                          ,input parameter-4-69
                          ,input parameter-5-69
                          ,input parameter-6-69
                          ,input parameter-7-69
                          )
      .
      assign
        l-filter-open-69 = true
      .
    end.
    if l-filter-open-69 = false then do:
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
  if l-filter-open-69 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where                  c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.out-code  = parout-code
       USE-INDEX chk-out
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
      parameter-2-69 = (if p-find-next then "true":u else "false":u )
      parameter-4-69 =
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.out-code  = &1&4&1 ', chr(34), parobj-type, parobj-code, parout-code)  + " ":u + where-phrase-69 + " ":u + p-find-condition + " " + ""
      parameter-5-69 = " USE-INDEX chk-out "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-69)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-69
                          ,input parameter-5-69
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-69 = (if p-find-next then "true":u else "false":u )
      parameter-3-69 =  "FOR EACH c-doc"
      parameter-4-69 =
        (
          if ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.out-code  = parout-code                       " + " " + where-phrase-69) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.out-code  = &1&4&1 ', chr(34), parobj-type, parobj-code, parout-code)  + " " + where-phrase-69
          else "true"
        )
      parameter-5-69 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-69 = if sort-phrase-69 = ''
                           then
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + sort-phrase-69
        )
      parameter-7-69 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-69)
                          ,input no-lock
                          ,input parameter-3-69
                          ,input parameter-4-69
                          ,input parameter-5-69
                          ,input parameter-6-69
                          ,input parameter-7-69
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
    WHEN "to-sale":U   THEN DO:
      assign
      filter-point = filter-point0 + par-mode
      filter-label = substitute("&1 для включения в пролажу", filter-label0)
      .
      if p-open-query then do:
        ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки для включения в отчет № &2 &3"
                                                       , title0
                                                       , parout-code
                                                       , (if p-chk-type = 0 then '':U else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))).
      end.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
      if cas-shft then do:
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
          if ("                   c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = buf_inkas.shift-date AND                   c-doc.shift-num  = buf_inkas.shift-num AND
                  (p-chk-type = 0 or c-doc.chk-type = p-chk-type)                         " + " " + where-phrase-72) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                   c-doc.obj-code  = &3  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = &4 AND                   c-doc.shift-num  = &5 AND
                  (&6 = 0 or c-doc.chk-type = &6) ', chr(34), parobj-type, parobj-code, buf_inkas.shift-date, buf_inkas.shift-num, p-chk-type)  + " " + where-phrase-72
          else "true"
        )
      parameter-5-72 = (" " + "" + " " + "")
      parameter-6-72 = if sort-phrase-72 = ''
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
          ("                   c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = buf_inkas.shift-date AND                   c-doc.shift-num  = buf_inkas.shift-num AND
                  (p-chk-type = 0 or c-doc.chk-type = p-chk-type)                         " + " " + where-phrase-72 = "")
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
      where                    c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = buf_inkas.shift-date AND                   c-doc.shift-num  = buf_inkas.shift-num AND
                  (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
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
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND                   c-doc.obj-code  = &3  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = &4 AND                   c-doc.shift-num  = &5 AND
                  (&6 = 0 or c-doc.chk-type = &6) ', chr(34), parobj-type, parobj-code, buf_inkas.shift-date, buf_inkas.shift-num, p-chk-type)  + " ":u + where-phrase-72 + " ":u + p-find-condition + " " + ""
      parameter-5-72 = "  "
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
          if ("                   c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = buf_inkas.shift-date AND                   c-doc.shift-num  = buf_inkas.shift-num AND
                  (p-chk-type = 0 or c-doc.chk-type = p-chk-type)                         " + " " + where-phrase-72) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                   c-doc.obj-code  = &3  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = &4 AND                   c-doc.shift-num  = &5 AND
                  (&6 = 0 or c-doc.chk-type = &6) ', chr(34), parobj-type, parobj-code, buf_inkas.shift-date, buf_inkas.shift-num, p-chk-type)  + " " + where-phrase-72
          else "true"
        )
      parameter-5-72 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-72 = if sort-phrase-72 = ''
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
      else do:
        if buf_shop.day-only then do:
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
          if ("                   c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = buf_Inkas.shift-date AND                   (p-chk-type = 0 or c-doc.chk-type = p-chk-type)                         " + " " + where-phrase-74) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                   c-doc.obj-code  = &3  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = &4 AND                   (&5 = 0 or c-doc.chk-type = &5) ', chr(34), parobj-type, parobj-code, buf_Inkas.shift-date, p-chk-type)  + " " + where-phrase-74
          else "true"
        )
      parameter-5-74 = (" " + "" + " " + "")
      parameter-6-74 = if sort-phrase-74 = ''
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
          ("                   c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = buf_Inkas.shift-date AND                   (p-chk-type = 0 or c-doc.chk-type = p-chk-type)                         " + " " + where-phrase-74 = "")
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
      where                    c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = buf_Inkas.shift-date AND                   (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
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
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND                   c-doc.obj-code  = &3  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = &4 AND                   (&5 = 0 or c-doc.chk-type = &5) ', chr(34), parobj-type, parobj-code, buf_Inkas.shift-date, p-chk-type)  + " ":u + where-phrase-74 + " ":u + p-find-condition + " " + ""
      parameter-5-74 = "  "
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
          if ("                   c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = buf_Inkas.shift-date AND                   (p-chk-type = 0 or c-doc.chk-type = p-chk-type)                         " + " " + where-phrase-74) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                   c-doc.obj-code  = &3  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = &4 AND                   (&5 = 0 or c-doc.chk-type = &5) ', chr(34), parobj-type, parobj-code, buf_Inkas.shift-date, p-chk-type)  + " " + where-phrase-74
          else "true"
        )
      parameter-5-74 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-74 = if sort-phrase-74 = ''
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
        else do:
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
          if ("                     c-doc.obj-type  = parobj-type  AND                     c-doc.obj-code  = parobj-code  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= buf_Inkas.shift-date AND                     (p-chk-type = 0 or c-doc.chk-type = p-chk-type)                           " + " " + where-phrase-76) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                     c-doc.obj-code  = &3  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= &4 AND                     (&5 = 0 or c-doc.chk-type = &5) ', chr(34), parobj-type, parobj-code, buf_Inkas.shift-date, p-chk-type)  + " " + where-phrase-76
          else "true"
        )
      parameter-5-76 = (" " + "" + " " + "")
      parameter-6-76 = if sort-phrase-76 = ''
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
          ("                     c-doc.obj-type  = parobj-type  AND                     c-doc.obj-code  = parobj-code  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= buf_Inkas.shift-date AND                     (p-chk-type = 0 or c-doc.chk-type = p-chk-type)                           " + " " + where-phrase-76 = "")
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
      where                      c-doc.obj-type  = parobj-type  AND                     c-doc.obj-code  = parobj-code  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= buf_Inkas.shift-date AND                     (p-chk-type = 0 or c-doc.chk-type = p-chk-type)
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
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND                     c-doc.obj-code  = &3  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= &4 AND                     (&5 = 0 or c-doc.chk-type = &5) ', chr(34), parobj-type, parobj-code, buf_Inkas.shift-date, p-chk-type)  + " ":u + where-phrase-76 + " ":u + p-find-condition + " " + ""
      parameter-5-76 = "  "
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
          if ("                     c-doc.obj-type  = parobj-type  AND                     c-doc.obj-code  = parobj-code  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= buf_Inkas.shift-date AND                     (p-chk-type = 0 or c-doc.chk-type = p-chk-type)                           " + " " + where-phrase-76) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                     c-doc.obj-code  = &3  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= &4 AND                     (&5 = 0 or c-doc.chk-type = &5) ', chr(34), parobj-type, parobj-code, buf_Inkas.shift-date, p-chk-type)  + " " + where-phrase-76
          else "true"
        )
      parameter-5-76 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-76 = if sort-phrase-76 = ''
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
      end.
    END.
    WHEN "to-inv":U   THEN DO:
      assign
      filter-point = filter-point0 + par-mode
      filter-label = substitute("&1 для включения в инвентаризацию", filter-label0)
      .
      if p-open-query then do:
        ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки для включения в док.инвентаризации № &2 &3"
                                                       , title0
                                                       , parout-code
                                                       , (if p-chk-type = 0 then '':U else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))).
      end.
      if l-shift-on then do:
        define variable v-shift-date as date no-undo .
        define variable v-shift-num as integer no-undo .
        define variable v-shift-name as character no-undo .
        define variable v-chk-date as date no-undo .
        define variable v-chk-time as integer no-undo .
        run gbl/factdate.p (
                          INPUT         parobj-type
                          ,INPUT        parobj-code
                          ,INPUT-OUTPUT v-chk-date
                          ,INPUT-OUTPUT v-chk-time
                          ,INPUT-OUTPUT v-shift-date
                          ,INPUT-OUTPUT v-shift-num
                          ,input-output v-shift-name
                          ,INPUT        YES
                            ) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
          message
          error-status:get-message(1) SKIP
          return-value
          view-as alert-box error .
          UNDO, return error .
        END.
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
          if ("                   c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = v-shift-date AND                   c-doc.shift-num  = v-shift-num AND
                  c-doc.chk-type = p-chk-type                         " + " " + where-phrase-78) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                   c-doc.obj-code  = &3 AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = &4 AND                   c-doc.shift-num  = &5 AND
                  c-doc.chk-type = &6 ', chr(34), parobj-type, parobj-code, v-shift-date, v-shift-num , p-chk-type)  + " " + where-phrase-78
          else "true"
        )
      parameter-5-78 = (" " + "" + " " + "")
      parameter-6-78 = if sort-phrase-78 = ''
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
          ("                   c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = v-shift-date AND                   c-doc.shift-num  = v-shift-num AND
                  c-doc.chk-type = p-chk-type                         " + " " + where-phrase-78 = "")
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
      where                    c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = v-shift-date AND                   c-doc.shift-num  = v-shift-num AND
                  c-doc.chk-type = p-chk-type
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
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND                   c-doc.obj-code  = &3 AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = &4 AND                   c-doc.shift-num  = &5 AND
                  c-doc.chk-type = &6 ', chr(34), parobj-type, parobj-code, v-shift-date, v-shift-num , p-chk-type)  + " ":u + where-phrase-78 + " ":u + p-find-condition + " " + ""
      parameter-5-78 = "  "
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
          if ("                   c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = v-shift-date AND                   c-doc.shift-num  = v-shift-num AND
                  c-doc.chk-type = p-chk-type                         " + " " + where-phrase-78) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                   c-doc.obj-code  = &3 AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date = &4 AND                   c-doc.shift-num  = &5 AND
                  c-doc.chk-type = &6 ', chr(34), parobj-type, parobj-code, v-shift-date, v-shift-num , p-chk-type)  + " " + where-phrase-78
          else "true"
        )
      parameter-5-78 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-78 = if sort-phrase-78 = ''
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
      else do:
        if buf_shop.day-only then do:
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-80  as logical   no-undo .
define variable  l-filter-open-80    as logical   .
define variable  flt-rec-80       as recid     no-undo .
define variable  filter-name-80      as character no-undo .
define variable  where-phrase-80     as character no-undo .
define variable  sort-phrase-80      as character no-undo .
define variable  where-phrase-rus-80 as character no-undo .
define variable  sort-phrase-rus-80  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-80
  ,output filter-name-80
  ,output where-phrase-80
  ,output sort-phrase-80
  ,output where-phrase-rus-80
  ,output sort-phrase-rus-80
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-80
      ) no-error .
  assign
    l-filter-open-80 = false
  .
  if flt-rec-80 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-80 as character no-undo .
    define variable  parameter-3-80 as character no-undo .
    define variable  parameter-4-80 as character no-undo .
    define variable  parameter-5-80 as character no-undo .
    define variable  parameter-6-80 as character no-undo .
    define variable  parameter-7-80 as character no-undo .
      assign
      parameter-3-80 =
                              "FOR EACH c-doc"
      parameter-4-80 =
        (
          if ("                   c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = buf_trn-doc.doc-date AND                   c-doc.chk-type = p-chk-type                         " + " " + where-phrase-80) <> ""
          then  substitute('c-doc.obj-type  = &1&2&1  AND                   c-doc.obj-code  = &3 AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = &4 AND                   c-doc.chk-type = &5 ', chr(34), parobj-type, parobj-code , buf_trn-doc.doc-date, p-chk-type)  + " " + where-phrase-80
          else "true"
        )
      parameter-5-80 = (" " + "" + " " + "")
      parameter-6-80 = if sort-phrase-80 = ''
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
        " " + sort-phrase-80
        )
      parameter-7-80 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-80 =
          ("                   c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = buf_trn-doc.doc-date AND                   c-doc.chk-type = p-chk-type                         " + " " + where-phrase-80 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-80
                          ,input parameter-4-80
                          ,input parameter-5-80
                          ,input parameter-6-80
                          ,input parameter-7-80
                          )
      .
      assign
        l-filter-open-80 = true
      .
    end.
    if l-filter-open-80 = false then do:
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
  if l-filter-open-80 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where                    c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = buf_trn-doc.doc-date AND                   c-doc.chk-type = p-chk-type
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
      parameter-2-80 = (if p-find-next then "true":u else "false":u )
      parameter-4-80 =
        "where ":u +  substitute('c-doc.obj-type  = &1&2&1  AND                   c-doc.obj-code  = &3 AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = &4 AND                   c-doc.chk-type = &5 ', chr(34), parobj-type, parobj-code , buf_trn-doc.doc-date, p-chk-type)  + " ":u + where-phrase-80 + " ":u + p-find-condition + " " + ""
      parameter-5-80 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-80)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-80
                          ,input parameter-5-80
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-80 = (if p-find-next then "true":u else "false":u )
      parameter-3-80 =  "FOR EACH c-doc"
      parameter-4-80 =
        (
          if ("                   c-doc.obj-type  = parobj-type  AND                   c-doc.obj-code  = parobj-code  AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = buf_trn-doc.doc-date AND                   c-doc.chk-type = p-chk-type                         " + " " + where-phrase-80) <> ""
          then  substitute('c-doc.obj-type  = &1&2&1  AND                   c-doc.obj-code  = &3 AND                   c-doc.out-code  = ?            AND                   c-doc.shift-date  = &4 AND                   c-doc.chk-type = &5 ', chr(34), parobj-type, parobj-code , buf_trn-doc.doc-date, p-chk-type)  + " " + where-phrase-80
          else "true"
        )
      parameter-5-80 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-80 = if sort-phrase-80 = ''
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
        " " + sort-phrase-80
        )
      parameter-7-80 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-80)
                          ,input no-lock
                          ,input parameter-3-80
                          ,input parameter-4-80
                          ,input parameter-5-80
                          ,input parameter-6-80
                          ,input parameter-7-80
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
        else do:
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-82  as logical   no-undo .
define variable  l-filter-open-82    as logical   .
define variable  flt-rec-82       as recid     no-undo .
define variable  filter-name-82      as character no-undo .
define variable  where-phrase-82     as character no-undo .
define variable  sort-phrase-82      as character no-undo .
define variable  where-phrase-rus-82 as character no-undo .
define variable  sort-phrase-rus-82  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-82
  ,output filter-name-82
  ,output where-phrase-82
  ,output sort-phrase-82
  ,output where-phrase-rus-82
  ,output sort-phrase-rus-82
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-82
      ) no-error .
  assign
    l-filter-open-82 = false
  .
  if flt-rec-82 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-82 as character no-undo .
    define variable  parameter-3-82 as character no-undo .
    define variable  parameter-4-82 as character no-undo .
    define variable  parameter-5-82 as character no-undo .
    define variable  parameter-6-82 as character no-undo .
    define variable  parameter-7-82 as character no-undo .
      assign
      parameter-3-82 =
                              "FOR EACH c-doc"
      parameter-4-82 =
        (
          if ("                     c-doc.obj-type  = parobj-type  AND                     c-doc.obj-code  = parobj-code  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= buf_trn-doc.doc-date AND                     c-doc.chk-type = p-chk-type                           " + " " + where-phrase-82) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                     c-doc.obj-code  = &3  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= &4 AND                     c-doc.chk-type = &5 ', chr(34), parobj-type, parobj-code, buf_trn-doc.doc-date, p-chk-type)  + " " + where-phrase-82
          else "true"
        )
      parameter-5-82 = (" " + "" + " " + "")
      parameter-6-82 = if sort-phrase-82 = ''
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
        " " + sort-phrase-82
        )
      parameter-7-82 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-82 =
          ("                     c-doc.obj-type  = parobj-type  AND                     c-doc.obj-code  = parobj-code  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= buf_trn-doc.doc-date AND                     c-doc.chk-type = p-chk-type                           " + " " + where-phrase-82 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-82
                          ,input parameter-4-82
                          ,input parameter-5-82
                          ,input parameter-6-82
                          ,input parameter-7-82
                          )
      .
      assign
        l-filter-open-82 = true
      .
    end.
    if l-filter-open-82 = false then do:
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
  if l-filter-open-82 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where                      c-doc.obj-type  = parobj-type  AND                     c-doc.obj-code  = parobj-code  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= buf_trn-doc.doc-date AND                     c-doc.chk-type = p-chk-type
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
      parameter-2-82 = (if p-find-next then "true":u else "false":u )
      parameter-4-82 =
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND                     c-doc.obj-code  = &3  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= &4 AND                     c-doc.chk-type = &5 ', chr(34), parobj-type, parobj-code, buf_trn-doc.doc-date, p-chk-type)  + " ":u + where-phrase-82 + " ":u + p-find-condition + " " + ""
      parameter-5-82 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-82)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-82
                          ,input parameter-5-82
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-82 = (if p-find-next then "true":u else "false":u )
      parameter-3-82 =  "FOR EACH c-doc"
      parameter-4-82 =
        (
          if ("                     c-doc.obj-type  = parobj-type  AND                     c-doc.obj-code  = parobj-code  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= buf_trn-doc.doc-date AND                     c-doc.chk-type = p-chk-type                           " + " " + where-phrase-82) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                     c-doc.obj-code  = &3  AND                     c-doc.out-code  = ?            AND                     c-doc.shift-date  <= &4 AND                     c-doc.chk-type = &5 ', chr(34), parobj-type, parobj-code, buf_trn-doc.doc-date, p-chk-type)  + " " + where-phrase-82
          else "true"
        )
      parameter-5-82 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-82 = if sort-phrase-82 = ''
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
        " " + sort-phrase-82
        )
      parameter-7-82 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-82)
                          ,input no-lock
                          ,input parameter-3-82
                          ,input parameter-4-82
                          ,input parameter-5-82
                          ,input parameter-6-82
                          ,input parameter-7-82
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
      end.
    END.
    WHEN "to-" + 'сч-трк-погр':U   THEN DO:
       assign
       filter-point = filter-point0 + par-mode
       filter-label = substitute("&1 для включения в док-нт изм.погрешности счетчика ТРК", filter-label0)
       .
       if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки для включения в док.измерения погрешности ТРК № &2 &3 &4"
                                                       , title0
                                                       , parout-code
                                                       , (if p-chk-type = 0 then '':U else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                                       , string(p-start-date, "99/99/9999")
                                                       ).
      end.
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-84  as logical   no-undo .
define variable  l-filter-open-84    as logical   .
define variable  flt-rec-84       as recid     no-undo .
define variable  filter-name-84      as character no-undo .
define variable  where-phrase-84     as character no-undo .
define variable  sort-phrase-84      as character no-undo .
define variable  where-phrase-rus-84 as character no-undo .
define variable  sort-phrase-rus-84  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-84
  ,output filter-name-84
  ,output where-phrase-84
  ,output sort-phrase-84
  ,output where-phrase-rus-84
  ,output sort-phrase-rus-84
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-84
      ) no-error .
  assign
    l-filter-open-84 = false
  .
  if flt-rec-84 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-84 as character no-undo .
    define variable  parameter-3-84 as character no-undo .
    define variable  parameter-4-84 as character no-undo .
    define variable  parameter-5-84 as character no-undo .
    define variable  parameter-6-84 as character no-undo .
    define variable  parameter-7-84 as character no-undo .
      assign
      parameter-3-84 =
                              "FOR EACH c-doc"
      parameter-4-84 =
        (
          if (" c-doc.obj-type = parobj-type                     AND c-doc.obj-code = parobj-code                     AND c-doc.chk-date = p-start-date                     AND c-doc.chk-type = p-chk-type                     and c-doc.out-2-code = ? " + " " + where-phrase-84) <> ""
          then  substitute('c-doc.obj-type = &1&2&1                     AND c-doc.obj-code = &3                     AND c-doc.chk-date = &4                     AND c-doc.chk-type = &5                     and c-doc.out-2-code = ? ', chr(34), parobj-type, parobj-code, p-start-date, p-chk-type) + " " + where-phrase-84
          else "true"
        )
      parameter-5-84 = (" " + "" + " " + "")
      parameter-6-84 = if sort-phrase-84 = ''
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
        " " + sort-phrase-84
        )
      parameter-7-84 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-84 =
          (" c-doc.obj-type = parobj-type                     AND c-doc.obj-code = parobj-code                     AND c-doc.chk-date = p-start-date                     AND c-doc.chk-type = p-chk-type                     and c-doc.out-2-code = ? " + " " + where-phrase-84 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-84
                          ,input parameter-4-84
                          ,input parameter-5-84
                          ,input parameter-6-84
                          ,input parameter-7-84
                          )
      .
      assign
        l-filter-open-84 = true
      .
    end.
    if l-filter-open-84 = false then do:
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
  if l-filter-open-84 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where  c-doc.obj-type = parobj-type                     AND c-doc.obj-code = parobj-code                     AND c-doc.chk-date = p-start-date                     AND c-doc.chk-type = p-chk-type                     and c-doc.out-2-code = ?
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
      parameter-2-84 = (if p-find-next then "true":u else "false":u )
      parameter-4-84 =
        "where ":u +  substitute('c-doc.obj-type = &1&2&1                     AND c-doc.obj-code = &3                     AND c-doc.chk-date = &4                     AND c-doc.chk-type = &5                     and c-doc.out-2-code = ? ', chr(34), parobj-type, parobj-code, p-start-date, p-chk-type) + " ":u + where-phrase-84 + " ":u + p-find-condition + " " + ""
      parameter-5-84 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-84)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-84
                          ,input parameter-5-84
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-84 = (if p-find-next then "true":u else "false":u )
      parameter-3-84 =  "FOR EACH c-doc"
      parameter-4-84 =
        (
          if (" c-doc.obj-type = parobj-type                     AND c-doc.obj-code = parobj-code                     AND c-doc.chk-date = p-start-date                     AND c-doc.chk-type = p-chk-type                     and c-doc.out-2-code = ? " + " " + where-phrase-84) <> ""
          then  substitute('c-doc.obj-type = &1&2&1                     AND c-doc.obj-code = &3                     AND c-doc.chk-date = &4                     AND c-doc.chk-type = &5                     and c-doc.out-2-code = ? ', chr(34), parobj-type, parobj-code, p-start-date, p-chk-type) + " " + where-phrase-84
          else "true"
        )
      parameter-5-84 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-84 = if sort-phrase-84 = ''
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
        " " + sort-phrase-84
        )
      parameter-7-84 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-84)
                          ,input no-lock
                          ,input parameter-3-84
                          ,input parameter-4-84
                          ,input parameter-5-84
                          ,input parameter-6-84
                          ,input parameter-7-84
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
    WHEN 'сч-трк-погр':U   THEN DO:
      assign
      filter-point = filter-point0 + par-mode
      filter-label = substitute("&1  док-нтf изм.погрешности счетчика ТРК", filter-label0)
      .
      if p-open-query then do:
        ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Чеки по док-ту измерения погрешности ТРК № &2 &3"
                                                       , title0
                                                       , parout-code
                                                       , (if p-chk-type = 0 then '':U else entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U))
                                                       ).
      end.
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-86  as logical   no-undo .
define variable  l-filter-open-86    as logical   .
define variable  flt-rec-86       as recid     no-undo .
define variable  filter-name-86      as character no-undo .
define variable  where-phrase-86     as character no-undo .
define variable  sort-phrase-86      as character no-undo .
define variable  where-phrase-rus-86 as character no-undo .
define variable  sort-phrase-rus-86  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-86
  ,output filter-name-86
  ,output where-phrase-86
  ,output sort-phrase-86
  ,output where-phrase-rus-86
  ,output sort-phrase-rus-86
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-86
      ) no-error .
  assign
    l-filter-open-86 = false
  .
  if flt-rec-86 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-86 as character no-undo .
    define variable  parameter-3-86 as character no-undo .
    define variable  parameter-4-86 as character no-undo .
    define variable  parameter-5-86 as character no-undo .
    define variable  parameter-6-86 as character no-undo .
    define variable  parameter-7-86 as character no-undo .
      assign
      parameter-3-86 =
                              "FOR EACH c-doc"
      parameter-4-86 =
        (
          if (" c-doc.obj-type = parobj-type                     AND c-doc.obj-code = parobj-code                     AND c-doc.chk-date = p-start-date                     AND c-doc.chk-type = p-chk-type                     and c-doc.out-2-code = parout-code " + " " + where-phrase-86) <> ""
          then  substitute('c-doc.obj-type = &1&2&1                     AND c-doc.obj-code = &3                     AND c-doc.chk-date = &4                     AND c-doc.chk-type = &5                     and c-doc.out-2-code = &1&6&1 ', chr(34), parobj-type, parobj-code, p-start-date, p-chk-type, parout-code) + " " + where-phrase-86
          else "true"
        )
      parameter-5-86 = (" " + "" + " " + "")
      parameter-6-86 = if sort-phrase-86 = ''
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
        " " + sort-phrase-86
        )
      parameter-7-86 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-86 =
          (" c-doc.obj-type = parobj-type                     AND c-doc.obj-code = parobj-code                     AND c-doc.chk-date = p-start-date                     AND c-doc.chk-type = p-chk-type                     and c-doc.out-2-code = parout-code " + " " + where-phrase-86 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-86
                          ,input parameter-4-86
                          ,input parameter-5-86
                          ,input parameter-6-86
                          ,input parameter-7-86
                          )
      .
      assign
        l-filter-open-86 = true
      .
    end.
    if l-filter-open-86 = false then do:
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
  if l-filter-open-86 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where  c-doc.obj-type = parobj-type                     AND c-doc.obj-code = parobj-code                     AND c-doc.chk-date = p-start-date                     AND c-doc.chk-type = p-chk-type                     and c-doc.out-2-code = parout-code
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
      parameter-2-86 = (if p-find-next then "true":u else "false":u )
      parameter-4-86 =
        "where ":u +  substitute('c-doc.obj-type = &1&2&1                     AND c-doc.obj-code = &3                     AND c-doc.chk-date = &4                     AND c-doc.chk-type = &5                     and c-doc.out-2-code = &1&6&1 ', chr(34), parobj-type, parobj-code, p-start-date, p-chk-type, parout-code) + " ":u + where-phrase-86 + " ":u + p-find-condition + " " + ""
      parameter-5-86 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-86)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-86
                          ,input parameter-5-86
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-86 = (if p-find-next then "true":u else "false":u )
      parameter-3-86 =  "FOR EACH c-doc"
      parameter-4-86 =
        (
          if (" c-doc.obj-type = parobj-type                     AND c-doc.obj-code = parobj-code                     AND c-doc.chk-date = p-start-date                     AND c-doc.chk-type = p-chk-type                     and c-doc.out-2-code = parout-code " + " " + where-phrase-86) <> ""
          then  substitute('c-doc.obj-type = &1&2&1                     AND c-doc.obj-code = &3                     AND c-doc.chk-date = &4                     AND c-doc.chk-type = &5                     and c-doc.out-2-code = &1&6&1 ', chr(34), parobj-type, parobj-code, p-start-date, p-chk-type, parout-code) + " " + where-phrase-86
          else "true"
        )
      parameter-5-86 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-86 = if sort-phrase-86 = ''
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
        " " + sort-phrase-86
        )
      parameter-7-86 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-86)
                          ,input no-lock
                          ,input parameter-3-86
                          ,input parameter-4-86
                          ,input parameter-5-86
                          ,input parameter-6-86
                          ,input parameter-7-86
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
    WHEN "free":U    THEN DO:
      assign
      filter-point = filter-point0 + "НЕУЧТЕННЫЕ":U
      filter-label = substitute("&1 неучтенные", filter-label0)
      .
      if p-chk-type = 0 then do:
        if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE = substitute("&1 НЕ включенные в отчеты чеки, Объект &2&3"
                                                       , title0, parobj-type, parobj-code).
        end.
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-89  as logical   no-undo .
define variable  l-filter-open-89    as logical   .
define variable  flt-rec-89       as recid     no-undo .
define variable  filter-name-89      as character no-undo .
define variable  where-phrase-89     as character no-undo .
define variable  sort-phrase-89      as character no-undo .
define variable  where-phrase-rus-89 as character no-undo .
define variable  sort-phrase-rus-89  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-89
  ,output filter-name-89
  ,output where-phrase-89
  ,output sort-phrase-89
  ,output where-phrase-rus-89
  ,output sort-phrase-rus-89
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-89
      ) no-error .
  assign
    l-filter-open-89 = false
  .
  if flt-rec-89 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-89 as character no-undo .
    define variable  parameter-3-89 as character no-undo .
    define variable  parameter-4-89 as character no-undo .
    define variable  parameter-5-89 as character no-undo .
    define variable  parameter-6-89 as character no-undo .
    define variable  parameter-7-89 as character no-undo .
      assign
      parameter-3-89 =
                              "FOR EACH c-doc"
      parameter-4-89 =
        (
          if ("         c-doc.obj-type  = parobj-type  AND         c-doc.obj-code  = parobj-code  AND         c-doc.out-code  = ?                            " + " " + where-phrase-89) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND         c-doc.obj-code  = &3  AND         c-doc.out-code  = ? ', chr(34), parobj-type, parobj-code)  + " " + where-phrase-89
          else "true"
        )
      parameter-5-89 = (" " + "" + " " + "")
      parameter-6-89 = if sort-phrase-89 = ''
                           then
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + sort-phrase-89
        )
      parameter-7-89 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-89 =
          ("         c-doc.obj-type  = parobj-type  AND         c-doc.obj-code  = parobj-code  AND         c-doc.out-code  = ?                            " + " " + where-phrase-89 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-89
                          ,input parameter-4-89
                          ,input parameter-5-89
                          ,input parameter-6-89
                          ,input parameter-7-89
                          )
      .
      assign
        l-filter-open-89 = true
      .
    end.
    if l-filter-open-89 = false then do:
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
  if l-filter-open-89 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where          c-doc.obj-type  = parobj-type  AND         c-doc.obj-code  = parobj-code  AND         c-doc.out-code  = ?
       USE-INDEX chk-out
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
      parameter-2-89 = (if p-find-next then "true":u else "false":u )
      parameter-4-89 =
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND         c-doc.obj-code  = &3  AND         c-doc.out-code  = ? ', chr(34), parobj-type, parobj-code)  + " ":u + where-phrase-89 + " ":u + p-find-condition + " " + ""
      parameter-5-89 = " USE-INDEX chk-out "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-89)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-89
                          ,input parameter-5-89
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-89 = (if p-find-next then "true":u else "false":u )
      parameter-3-89 =  "FOR EACH c-doc"
      parameter-4-89 =
        (
          if ("         c-doc.obj-type  = parobj-type  AND         c-doc.obj-code  = parobj-code  AND         c-doc.out-code  = ?                            " + " " + where-phrase-89) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND         c-doc.obj-code  = &3  AND         c-doc.out-code  = ? ', chr(34), parobj-type, parobj-code)  + " " + where-phrase-89
          else "true"
        )
      parameter-5-89 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-89 = if sort-phrase-89 = ''
                           then
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + sort-phrase-89
        )
      parameter-7-89 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-89)
                          ,input no-lock
                          ,input parameter-3-89
                          ,input parameter-4-89
                          ,input parameter-5-89
                          ,input parameter-6-89
                          ,input parameter-7-89
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
      else do:
        if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE = substitute("&1 НЕ включенные в отчеты чеки, Объект &2&3: &4"
                                                      , title0
                                                      , parobj-type
                                                      , parobj-code
                                                      , entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)
                                                      ).
       end.
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-91  as logical   no-undo .
define variable  l-filter-open-91    as logical   .
define variable  flt-rec-91       as recid     no-undo .
define variable  filter-name-91      as character no-undo .
define variable  where-phrase-91     as character no-undo .
define variable  sort-phrase-91      as character no-undo .
define variable  where-phrase-rus-91 as character no-undo .
define variable  sort-phrase-rus-91  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-91
  ,output filter-name-91
  ,output where-phrase-91
  ,output sort-phrase-91
  ,output where-phrase-rus-91
  ,output sort-phrase-rus-91
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-91
      ) no-error .
  assign
    l-filter-open-91 = false
  .
  if flt-rec-91 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-91 as character no-undo .
    define variable  parameter-3-91 as character no-undo .
    define variable  parameter-4-91 as character no-undo .
    define variable  parameter-5-91 as character no-undo .
    define variable  parameter-6-91 as character no-undo .
    define variable  parameter-7-91 as character no-undo .
      assign
      parameter-3-91 =
                              "FOR EACH c-doc"
      parameter-4-91 =
        (
          if ("         c-doc.obj-type  = parobj-type  AND         c-doc.obj-code  = parobj-code  AND         c-doc.out-code  = ?  AND         c-doc.chk-type = p-chk-type   " + " " + where-phrase-91) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND         c-doc.obj-code  = &3  AND         c-doc.out-code  = ?  AND         c-doc.chk-type = &4 ', chr(34), parobj-type, parobj-code, p-chk-type) + " " + where-phrase-91
          else "true"
        )
      parameter-5-91 = (" " + "" + " " + "")
      parameter-6-91 = if sort-phrase-91 = ''
                           then
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + sort-phrase-91
        )
      parameter-7-91 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-91 =
          ("         c-doc.obj-type  = parobj-type  AND         c-doc.obj-code  = parobj-code  AND         c-doc.out-code  = ?  AND         c-doc.chk-type = p-chk-type   " + " " + where-phrase-91 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-91
                          ,input parameter-4-91
                          ,input parameter-5-91
                          ,input parameter-6-91
                          ,input parameter-7-91
                          )
      .
      assign
        l-filter-open-91 = true
      .
    end.
    if l-filter-open-91 = false then do:
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
  if l-filter-open-91 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where          c-doc.obj-type  = parobj-type  AND         c-doc.obj-code  = parobj-code  AND         c-doc.out-code  = ?  AND         c-doc.chk-type = p-chk-type
       USE-INDEX chk-out
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
      parameter-2-91 = (if p-find-next then "true":u else "false":u )
      parameter-4-91 =
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND         c-doc.obj-code  = &3  AND         c-doc.out-code  = ?  AND         c-doc.chk-type = &4 ', chr(34), parobj-type, parobj-code, p-chk-type) + " ":u + where-phrase-91 + " ":u + p-find-condition + " " + ""
      parameter-5-91 = " USE-INDEX chk-out "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-91)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-91
                          ,input parameter-5-91
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-91 = (if p-find-next then "true":u else "false":u )
      parameter-3-91 =  "FOR EACH c-doc"
      parameter-4-91 =
        (
          if ("         c-doc.obj-type  = parobj-type  AND         c-doc.obj-code  = parobj-code  AND         c-doc.out-code  = ?  AND         c-doc.chk-type = p-chk-type   " + " " + where-phrase-91) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND         c-doc.obj-code  = &3  AND         c-doc.out-code  = ?  AND         c-doc.chk-type = &4 ', chr(34), parobj-type, parobj-code, p-chk-type) + " " + where-phrase-91
          else "true"
        )
      parameter-5-91 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-91 = if sort-phrase-91 = ''
                           then
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX chk-out " +
          " " + sort-column-phrase +
        " " + sort-phrase-91
        )
      parameter-7-91 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-91)
                          ,input no-lock
                          ,input parameter-3-91
                          ,input parameter-4-91
                          ,input parameter-5-91
                          ,input parameter-6-91
                          ,input parameter-7-91
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
    END.
    WHEN 'IBS-TH':U THEN DO:
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-print-host-code
  )  .
      assign
      filter-point = filter-point0 + par-mode
      filter-label = substitute("&1 Один объект", filter-label0)
      .
      if p-chk-type = 0 then do:
        if p-open-query then do:
          ASSIGN
          frame Dialog-Frame:TITLE = substitute("&1 Объект: &2&3", title0 , parobj-type , parobj-code)
                .
        end.
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-94  as logical   no-undo .
define variable  l-filter-open-94    as logical   .
define variable  flt-rec-94       as recid     no-undo .
define variable  filter-name-94      as character no-undo .
define variable  where-phrase-94     as character no-undo .
define variable  sort-phrase-94      as character no-undo .
define variable  where-phrase-rus-94 as character no-undo .
define variable  sort-phrase-rus-94  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-94
  ,output filter-name-94
  ,output where-phrase-94
  ,output sort-phrase-94
  ,output where-phrase-rus-94
  ,output sort-phrase-rus-94
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-94
      ) no-error .
  assign
    l-filter-open-94 = false
  .
  if flt-rec-94 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-94 as character no-undo .
    define variable  parameter-3-94 as character no-undo .
    define variable  parameter-4-94 as character no-undo .
    define variable  parameter-5-94 as character no-undo .
    define variable  parameter-6-94 as character no-undo .
    define variable  parameter-7-94 as character no-undo .
      assign
      parameter-3-94 =
                              "FOR EACH c-doc"
      parameter-4-94 =
        (
          if ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code                              " + " " + where-phrase-94) <> ""
          then  substitute('c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3 ', chr(34), parobj-type, parobj-code)  + " " + where-phrase-94
          else "true"
        )
      parameter-5-94 = (" " + "" + " " + "")
      parameter-6-94 = if sort-phrase-94 = ''
                           then
        (
        " " + " by c-doc.obj-type by c-doc.obj-code by c-doc.chk-date descending by c-doc.chk-time descending " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " by c-doc.obj-type by c-doc.obj-code by c-doc.chk-date descending by c-doc.chk-time descending " +
          " " + sort-column-phrase +
        " " + sort-phrase-94
        )
      parameter-7-94 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-94 =
          ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code                              " + " " + where-phrase-94 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-94
                          ,input parameter-4-94
                          ,input parameter-5-94
                          ,input parameter-6-94
                          ,input parameter-7-94
                          )
      .
      assign
        l-filter-open-94 = true
      .
    end.
    if l-filter-open-94 = false then do:
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
  if l-filter-open-94 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where              c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code
       by c-doc.obj-type by c-doc.obj-code by c-doc.chk-date descending by c-doc.chk-time descending
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
      parameter-2-94 = (if p-find-next then "true":u else "false":u )
      parameter-4-94 =
        "where ":u +  substitute('c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3 ', chr(34), parobj-type, parobj-code)  + " ":u + where-phrase-94 + " ":u + p-find-condition + " " + ""
      parameter-5-94 = " by c-doc.obj-type by c-doc.obj-code by c-doc.chk-date descending by c-doc.chk-time descending "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-94)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-94
                          ,input parameter-5-94
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-94 = (if p-find-next then "true":u else "false":u )
      parameter-3-94 =  "FOR EACH c-doc"
      parameter-4-94 =
        (
          if ("             c-doc.obj-type  = parobj-type  AND             c-doc.obj-code  = parobj-code                              " + " " + where-phrase-94) <> ""
          then  substitute('c-doc.obj-type  = &1&2&1  AND             c-doc.obj-code  = &3 ', chr(34), parobj-type, parobj-code)  + " " + where-phrase-94
          else "true"
        )
      parameter-5-94 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-94 = if sort-phrase-94 = ''
                           then
        (
        " " + " by c-doc.obj-type by c-doc.obj-code by c-doc.chk-date descending by c-doc.chk-time descending " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " by c-doc.obj-type by c-doc.obj-code by c-doc.chk-date descending by c-doc.chk-time descending " +
          " " + sort-column-phrase +
        " " + sort-phrase-94
        )
      parameter-7-94 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-94)
                          ,input no-lock
                          ,input parameter-3-94
                          ,input parameter-4-94
                          ,input parameter-5-94
                          ,input parameter-6-94
                          ,input parameter-7-94
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
        if v-doc-rec = ?
        and v-start = yes
        then do:
          for each buf_chk-doc no-lock  where
                      buf_chk-doc.obj-type = parobj-type
                  and buf_chk-doc.obj-code = parobj-code
                  and buf_chk-doc.pay-desk = p-pay-desk
          by buf_chk-doc.obj-type
          by buf_chk-doc.obj-code
          by buf_chk-doc.chk-type
          by buf_chk-doc.chk-date descending
          by buf_chk-doc.chk-time descending:
            v-doc-rec = recid(buf_chk-doc).
            REPOSITION br-docs to recid v-doc-rec No-ERROR.
            if not error-status:error then leave.
          end.
        end.
      end.
      else do:
        if p-open-query then do:
          ASSIGN frame Dialog-Frame:TITLE = substitute("&1 Объект: &2&3 &4", title0 , parobj-type , parobj-code, entry (lookup (string(p-chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)).
        end.
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-96  as logical   no-undo .
define variable  l-filter-open-96    as logical   .
define variable  flt-rec-96       as recid     no-undo .
define variable  filter-name-96      as character no-undo .
define variable  where-phrase-96     as character no-undo .
define variable  sort-phrase-96      as character no-undo .
define variable  where-phrase-rus-96 as character no-undo .
define variable  sort-phrase-rus-96  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-96
  ,output filter-name-96
  ,output where-phrase-96
  ,output sort-phrase-96
  ,output where-phrase-rus-96
  ,output sort-phrase-rus-96
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-96
      ) no-error .
  assign
    l-filter-open-96 = false
  .
  if flt-rec-96 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-96 as character no-undo .
    define variable  parameter-3-96 as character no-undo .
    define variable  parameter-4-96 as character no-undo .
    define variable  parameter-5-96 as character no-undo .
    define variable  parameter-6-96 as character no-undo .
    define variable  parameter-7-96 as character no-undo .
      assign
      parameter-3-96 =
                              "FOR EACH c-doc"
      parameter-4-96 =
        (
          if ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.chk-type = p-chk-type                       " + " " + where-phrase-96) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.chk-type = &4 ', chr(34), parobj-type, parobj-code, p-chk-type)  + " " + where-phrase-96
          else "true"
        )
      parameter-5-96 = (" " + "" + " " + "")
      parameter-6-96 = if sort-phrase-96 = ''
                           then
        (
        " " + " by c-doc.obj-type by c-doc.obj-code by c-doc.chk-date descending by c-doc.chk-time descending " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " by c-doc.obj-type by c-doc.obj-code by c-doc.chk-date descending by c-doc.chk-time descending " +
          " " + sort-column-phrase +
        " " + sort-phrase-96
        )
      parameter-7-96 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-96 =
          ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.chk-type = p-chk-type                       " + " " + where-phrase-96 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-96
                          ,input parameter-4-96
                          ,input parameter-5-96
                          ,input parameter-6-96
                          ,input parameter-7-96
                          )
      .
      assign
        l-filter-open-96 = true
      .
    end.
    if l-filter-open-96 = false then do:
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
  if l-filter-open-96 = false then do:
    OPEN QUERY br-docs FOR EACH c-doc
      where                  c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.chk-type = p-chk-type
       by c-doc.obj-type by c-doc.obj-code by c-doc.chk-date descending by c-doc.chk-time descending
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
      parameter-2-96 = (if p-find-next then "true":u else "false":u )
      parameter-4-96 =
        "where ":u +  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.chk-type = &4 ', chr(34), parobj-type, parobj-code, p-chk-type)  + " ":u + where-phrase-96 + " ":u + p-find-condition + " " + ""
      parameter-5-96 = " by c-doc.obj-type by c-doc.obj-code by c-doc.chk-date descending by c-doc.chk-time descending "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(c-doc)
                          ,input logical(parameter-2-96)
                          ,input no-lock
                          ,input (buffer c-doc:handle)
                          ,input parameter-4-96
                          ,input parameter-5-96
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-96 = (if p-find-next then "true":u else "false":u )
      parameter-3-96 =  "FOR EACH c-doc"
      parameter-4-96 =
        (
          if ("                 c-doc.obj-type  = parobj-type  AND                 c-doc.obj-code  = parobj-code  AND                 c-doc.chk-type = p-chk-type                       " + " " + where-phrase-96) <> ""
          then  substitute(' c-doc.obj-type  = &1&2&1  AND                 c-doc.obj-code  = &3  AND                 c-doc.chk-type = &4 ', chr(34), parobj-type, parobj-code, p-chk-type)  + " " + where-phrase-96
          else "true"
        )
      parameter-5-96 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-96 = if sort-phrase-96 = ''
                           then
        (
        " " + " by c-doc.obj-type by c-doc.obj-code by c-doc.chk-date descending by c-doc.chk-time descending " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " by c-doc.obj-type by c-doc.obj-code by c-doc.chk-date descending by c-doc.chk-time descending " +
          " " + sort-column-phrase +
        " " + sort-phrase-96
        )
      parameter-7-96 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-96)
                          ,input no-lock
                          ,input parameter-3-96
                          ,input parameter-4-96
                          ,input parameter-5-96
                          ,input parameter-6-96
                          ,input parameter-7-96
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
        if v-doc-rec = ?
        and v-start = yes
        then do:
          for each buf_chk-doc no-lock  where
                      buf_chk-doc.obj-type = parobj-type
                  and buf_chk-doc.obj-code = parobj-code
                  and buf_chk-doc.pay-desk = p-pay-desk
                  and buf_chk-doc.chk-type = p-chk-type
          by buf_chk-doc.obj-type
          by buf_chk-doc.obj-code
          by buf_chk-doc.chk-type
          by buf_chk-doc.chk-date descending
          by buf_chk-doc.chk-time descending:
            v-doc-rec = recid(buf_chk-doc).
            REPOSITION br-docs to recid v-doc-rec No-ERROR.
            if not error-status:error then leave.
          end.
        end.
      end.
    END.
END CASE.
v-start = no.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-docs to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-docs in frame Dialog-Frame.
APPLY "ENTRY" TO br-docs.
END PROCEDURE.
PROCEDURE PrintProc :
define variable  date_string     as      char    no-undo.
define variable  Line                as      char    no-undo.
define variable  for-time as char.
define variable  accum-count as integer.
define variable  accum-tot-doc as decimal.
define variable  accum-discnt as decima.
define variable  accum-sub-discnt as decimal.
define variable  accum-netto as decimal.
define variable v-chk-type as character no-undo .
define variable v-shift-name-num as character no-undo.
DEFINE FRAME Chk-List
c-doc.office        column-label "Тип"                format "X(8)"
c-doc.doc-code      column-label "Номер_чека"  format "X(17)"
v-chk-type          column-label "Тип_чека"               format "X(8)"
c-doc.chk-num       column-label "№/кассе" format "->>>>>9"
c-doc.chk-date      column-label "Дата" format "99/99/9999"
for-time            column-label "Время"   format "X(5)"
c-doc.shift-date    column-label "Смена_от" format "99/99/9999"
v-shift-name-num    column-label "N_см." FORMAT "X(6)"
c-doc.tot-doc       column-label "Сумма_товарная"
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
"______" @ v-shift-name-num
accum-tot-doc @ c-doc.tot-doc
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
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char no-undo.
define variable accum-count as integer no-undo.
define variable accum-qnty as decimal no-undo.
define variable accum-tot-doc as decimal no-undo.
define variable accum-discnt as decimal no-undo.
define variable accum-netto as decimal no-undo.
define variable fgds-discnt-pc as decimal no-undo.
define variable for-gds-sum like ub.chk-doc.netto no-undo.
define variable for-gds-price like ub.chk-gds.price-base no-undo.
define variable v-write-off as logical no-undo .
define variable V-RECEIPT-NAME as character no-undo .
DEFINE FRAME Goods-Frame
ub.chk-gds.doc-code column-label "Номер_чека" FORMAT "X(18)"
v-receipt-name column-labeL "Тип_чека" format "x(8)"
ub.chk-gds.line-num column-label "NN" FORMAT "-999"
ub.chk-gds.b-code   column-label "Код"
ub.goods.artic
ub.goods.gds-name    FORMAT "X(27)"
ub.gds-prt.f-name   FORMAT "X(14)"
ub.chk-gds.is-error COLUMN-LABEL "Ош" FORMAT "+/ "
ub.chk-gds.src-code Column-label "Код в спул-файле" FORMAT "X(19)"
ub.chk-gds.pump column-label "ТРК"
ub.clients.obj-name    COLUMN-LABEL "Производитель" FORMAT "X(20)"
ub.chk-gds.doc-qnty
ub.bar-code.unit-cli     COLUMN-LABEL "Изм" FORMAT "X(3)"
ub.chk-gds.price-base
ub.chk-gds.discnt
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
    IF AVAIL bar-code then do:
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
    for-gds-sum = (chk-gds.price-base + chk-gds.price-service - chk-gds.discnt) * chk-gds.doc-qnty
    for-gds-price = chk-gds.price-base + chk-gds.price-service - chk-gds.discnt
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
    accum-count = accum-count + 1
    accum-qnty = accum-qnty + chk-gds.doc-qnty
    accum-tot-doc = accum-tot-doc + chk-gds.doc-qnty * (chk-gds.price-base + price-service)
    accum-discnt = accum-discnt + chk-gds.doc-qnty * chk-gds.discnt
    accum-netto = accum-netto + chk-gds.doc-qnty * (chk-gds.price-base + chk-gds.price-service - chk-gds.discnt)
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
define variable v-num as integer no-undo.
define variable f-name as char no-undo.
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
DEFINE VARIABLE ii as integer no-undo .
define variable glog as logical no-undo .
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
  FOR EACH ub.chk-gds NO-LOCK Where
           ub.chk-gds.doc-code = c-doc.doc-code by chk-gds.line-num:
    FIND FIRST ub.bar-code No-LOCK WHERE
               ub.bar-code.b-code = ub.chk-gds.b-code NO-ERROR.
    IF AVAIL ub.bar-code then do:
      FIND FIRST ub.goods NO-LOCK WHERE
                 ub.goods.gds-code = ub.bar-code.gds-code NO-ERROR.
      FIND FIRST ub.gds-prt No-LOCK where
                 ub.gds-prt.upper-code = ub.goods.prt-root NO-ERROR.
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-last97 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last97 = gds-list.order-num .
  end.
  else do:
    v-last97 = 0 .
  end.
  create gds-list .
  buffer-copy goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last97 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
      assign
      gds-list.qnty = gds-list.qnty + ub.chk-gds.doc-qnty.
      FIND FIRST gds-bar where gds-bar.b-code = ub.bar-code.b-code No-ERROR.
      if not avail gds-bar then do:
        create gds-bar.
        assign
        gds-bar.b-code = ub.bar-code.b-code.
      end.
      assign
      gds-bar.qnty = gds-bar.qnty + ub.chk-gds.doc-qnty.
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
  when 1 then do:
    assign
      f-name = "default.gds"
      glog = yes
      .
    system-dialog get-file f-name
      filters "Списки товаров *.gds" "*.gds"
      ask-overwrite
      save-as
      use-filename
      update glog
      default-extension "gds".
    if not glog then do:
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
  when 2 then do:
    assign
      f-name = "default.inv"
      glog = yes
      .
    system-dialog get-file f-name
      filters "Инвентаризация касса *.inv" "*.inv"
      ask-overwrite
      save-as
      use-filename
      update glog
      default-extension "inv".
    if not glog then do:
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
  when 3 then do:
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
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable accum-count as integer.
define variable accum-tot-base as decima.
define variable accum-tot-rubl as decimal.
define variable pay-card-num like ub.chk-pay.pay-card no-undo .
DEFINE FRAME Pay-Frame
ub.chk-pay.doc-code column-label "Номер_чека" FORMAT "X(20)"
ub.chk-pay.line-num column-label "NN"
ub.chk-pay.curr-code column-label "Код. вал"
ub.currency.curr-name column-label "Валюта" FORMAT "X(15)"
ub.chk-pay.pay-code Column-label "Код платежа"
ub.cash-pay.obj-name COLUMn-LABEL "Платеж"
pay-card-num COLUMN-LABEL "Платежн.карта"
ub.chk-pay.tot-sum COLUMN-LABEL "Сумма в вал. платежа"
ub.chk-pay.tot-base COLUMN-LABEL "Сумма в баз.вал"
ub.chk-pay.tot-rubl  COLUMN-LABEL "Сумма в рублях"
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
    if not avail temp-pay then do:
      create temp-pay.
      buffer-copy chk-pay except tot-base tot-sum tot-rubl line-num to temp-pay
      assign temp-pay.line-num = 0
      .
    end.
    assign
    temp-pay.tot-sum = temp-pay.tot-sum + chk-pay.tot-sum
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
    accum-count = accum-count + 1
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
DEFINE VARIABLE v-doc-rec as recid no-undo.
DEFINE VARIABLE v-change-fields as character no-undo .
define variable v-can-back-shift as logical no-undo .
DEFINE VARIABLE v-shift-date like ub.chk-doc.shift-date no-undo .
DEFINE VARIABLE v-shift-num like ub.chk-doc.shift-num no-undo .
define variable v-shift-name like ub.chk-doc.shift-name no-undo .
define variable v-shift-reservoir-from as int no-undo.
define variable v-shift-reservoir-to as int no-undo.
DEFINE VARIABLE v-first-record as recid no-undo .
define variable v-added as logical no-undo .
define variable v-changed as logical no-undo.
define variable v-added-num as integer no-undo .
define variable v-changed-num as int no-undo.
define variable l-shift-on as logical no-undo .
define variable next-prev as character no-undo .
define variable glog as logical no-undo .
define variable v-pump like ub.chk-gds.pump no-undo .
define variable v-b-code like ub.chk-gds.b-code no-undo .
define variable v-host-code as integer no-undo .
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-host-code
  )  .
  do
  on error undo, return error
  on stop undo, return error
  :
  CASE p-change-type:
    when "one-change":U then do:
      if NOT available c-doc then do:
        message
        "Неправильно выбран чек."
        view-as alert-box ERROR.
        return error.
      end.
      if c-doc.out-code <> ? then do:
        message
        "Этот чек включен в отчет о продаже или документ МЦ." skip
        "Изменение невозможно."
        view-as alert-box INFORMATION .
        return error.
      end.
      if c-doc.chk-type = 13 or c-doc.chk-type = 40 then do:
        message
        "Изменение чеков открытия/закрытия смены невозможно."
        view-as alert-box INFORMATION .
        return error.
      end.
      assign
      v-doc-rec = recid(c-doc).
      if lookup(string(c-doc.chk-type), '2,3,4,5,7':U) > 0 then do:
define variable vss-include-info99 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wth-receipts_update':U
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
        run str/checkwth.w
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
      end.
      else do:
define variable vss-include-info100 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_receipt_input':U
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
      end.
      RUN OpenBr in this-procedure ( input yes, input no, input '':U).
      REPOSITION br-docs to recid v-doc-rec no-error .
    end.
    when "list-shift":U then do:
      if p-change-type = "list-shift" then do:
        message
        "Вы хотите изменить дату, номер смены или резервуар для чеков?" skip
        string(if index(frame Dialog-Frame:title,"ФИЛЬТР" ) = 0 then
        "Эта процедура может занять долгое время! Продолжать?"
        else "":U)
        view-as alert-box WARNING buttons YES-NO update glog.
        if NOT glog then return error.
        run str/chgshift.w (
                       input parparentproc
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
define variable vss-include-info101 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      if p-change-type = "list-shift" then do:
      _shift:
      DO WHILE available c-doc
      on error undo, next _shift
      on stop undo, next _shift
      :
        run waitfram-show in this-procedure ( input "Ждите...").
        assign
        v-doc-rec = recid(c-doc)
        v-added = no
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
        if error-status:error then do:
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
     if l-shift-on and p-change-type = "list-shift" then do:
      message
      substitute("В результате изменения даты/номера смены или резервуара в указанной смене появилось &1 чеков, изменено &2 чеков", v-added-num, v-changed-num)
      view-as alert-box  .
     end.
     if p-change-type = "list-pump" then do:
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
define variable old-netto as decimal no-undo.
define variable old-tot-doc as decimal no-undo.
define variable old-discnt as decimal no-undo.
DEFINE VARIABLE v-first-record as recid no-undo .
define variable glog as logical no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-host-code as integer no-undo .
define variable varlog as logical no-undo .
define buffer del_chk-doc for ub.chk-doc.
define buffer buf_inkas for ub.inkas.
define buffer buf_trn-doc for ub.trn-doc.
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-host-code
  )  .
define variable vss-include-info103 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  when "list":U then do:
    IF par-mode = 'продажа':U then do:
      if index(frame Dialog-Frame:title,"ФИЛЬТР" ) = 0
      and p-chk-type = 0
      then do:
        message
        "Вы хотите исключить ВСЕ чеки из продажи!" skip
        "Эта процедура может занять долгое время! Продолжать?"
        view-as alert-box WARNING buttons YES-NO update glog.
        if NOT glog then return no-apply.
      end.
      ELSE DO:
        message
        "Вы действительно хотите исключить ВСЕ чеки по текущему списку из продажи?!" skip
        view-as alert-box WARNING buttons YES-NO update glog.
        if NOT glog then return no-apply.
      END.
    end.
    ELSE DO:
      IF par-mode = 'vt':U then do:
        message
        "Вы действительно хотите исключить ВСЕ чеки по текущему списку из инвентаризации?!" skip
        view-as alert-box WARNING buttons YES-NO update glog.
        if NOT glog then return no-apply.
      end.
      else do:
        if index(frame Dialog-Frame:title,"ФИЛЬТР" ) = 0
        and p-chk-type = 0
        then do:
          message
          "Вы хотите удалить ВСЕ НЕУЧТЕННЫЕ чеки по объекту!" skip
          "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
          WARNING buttons YES-NO update glog.
          if NOT glog then return no-apply.
        end.
        ELSE DO:
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
  WHEN 'продажа':U then do:
    if del-type = "list" then do:
      DO WHILE available c-doc :
            GET prev br-docs  no-lock.
      END.
      GET next br-docs.
      _list0:
      DO WHILE available c-doc
      on error undo, next _list0
      on stop undo, next _list0
      :
        FIND FIRST del_chk-doc where
                          recid (del_chk-doc) = recid(c-doc) No-ERROR.
        if not avail del_chk-doc then NEXT _list0.
        if del_chk-doc.out-code <> ? then DO  :
          run waitfram-show in this-procedure ( input "Ждите...").
          FIND FIRST buf_inkas No-LOCK WHERE
                          buf_inkas.inkas-code = del_chk-doc.out-code No-ERROR.
          assign
          old-netto = buf_inkas.netto
          old-tot-doc = buf_inkas.tot-doc
          old-discnt = buf_inkas.discnt.
          if lookup(string(del_chk-doc.chk-type), '2,3,4,5,7':U) > 0 then do:
            run str/exclwchk.p ( input parparentproc,  input v-curr-r-b, buffer del_chk-doc) no-error.
          end.
          else do:
            run str/excl-chk.p ( input parparentproc,  input v-curr-r-b, buffer del_chk-doc) no-error.
          end.
          if error-status:error OR
          (del_chk-doc.chk-type <> integer('43':U) and del_chk-doc.chk-type <> integer('44':U)
          and
          (buf_inkas.netto <> old-netto  - del_chk-doc.netto OR
          buf_inkas.tot-doc <> old-tot-doc  - del_chk-doc.tot-doc OR
          buf_inkas.discnt <> old-discnt - del_chk-doc.discnt)
          )
          then do:
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
    if del-type = "one":U then do:
      if available c-doc then do:
        if c-doc.out-code <> ? then do:
          FIND FIRST del_chk-doc where
                    recid (del_chk-doc) = recid(c-doc) No-ERROR.
          if not avail del_chk-doc then return error.
          varlog = br-docs:select-next-row().
          if not varlog then varlog = br-docs:select-prev-row().
          v-doc-rec = recid(c-doc).
          FIND FIRST buf_inkas No-LOCK WHERE
                    buf_inkas.inkas-code = del_chk-doc.out-code No-ERROR.
          assign
          old-netto = buf_inkas.netto
          old-tot-doc = buf_inkas.tot-doc
          old-discnt = buf_inkas.discnt.
          if lookup(string(del_chk-doc.chk-type), '2,3,4,5,7':U) > 0 then do:
            run str/exclwchk.p ( input parparentproc,  input v-curr-r-b, buffer del_chk-doc) no-error.
          end.
          else do:
            run str/excl-chk.p ( input parparentproc, input v-curr-r-b, buffer del_chk-doc) no-error.
          end.
          if error-status:error  OR
          buf_inkas.netto <> old-netto  - del_chk-doc.netto OR
          buf_inkas.tot-doc <> old-tot-doc  - del_chk-doc.tot-doc OR
          buf_inkas.discnt <> old-discnt - del_chk-doc.discnt then do:
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
  WHEN 'vt':U then do:
    if del-type = "list" then do:
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
          FIND FIRST buf_trn-doc No-LOCK WHERE
                          buf_trn-doc.doc-code = del_chk-doc.out-code No-ERROR.
          run str/exclichk.p ( input parparentproc,   buffer del_chk-doc) no-error.
          if error-status:error then do:
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
      if del-type = "one":U then do:
        if available c-doc then do:
          if c-doc.out-code <> ? then do:
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
            if error-status:error  then do:
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
    OTHERWISE DO:
      CASE del-type:
        when "list":U then do:
          DO WHILE available c-doc :
            GET prev br-docs  no-lock.
          END.
          GET next br-docs.
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
            if error-status:error then do:
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
        when "one":U then do:
          if NOT available c-doc then do:
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
          if error-status:error then do:
            message
            error-status:get-message(1) skip
            return-value
            view-as alert-box .
            del-type = "".
            return no-apply.
          end.
          del-type = "".
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
define variable l-shift-on as logical no-undo .
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable cas-shft as logical no-undo .
assign
  tbl = 'chk-doc'
  join-tbl = 'c-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-time', '', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-type', 'Тип чека', 'receipt-code',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Т или у', 'gds-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
CASE par-mode:
  WHEN  'все':U
  THEN DO:
    run fltfield-add in this-procedure('obj-type*obj-code*shift-date*shift-num'
                                      , 'Объект/Дата смены/№ смены'
                                      , ('sht' + chr(4) +
                                         '':U + chr(4) +
                                         string(0) + chr(4) +
                                         'no'),
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  end.
  otherwise do:
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  'маг':U
  ,input  parobj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
    if not l-shift-on then do:
define variable vss-include-info105 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type105 as character no-undo .
define variable v-value-character105 as character no-undo .
define variable v-value-date105 as date no-undo .
define variable v-value-decimal105 as decimal no-undo .
define variable v-value-integer105 as INTEGER no-undo .
define variable v-tth105 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  parobj-type
    ,input  parobj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character105
    ,output v-value-date105
    ,output v-value-decimal105
    ,output v-value-integer105
    ,output cas-shft
    ,output v-param-type105
    ,INPUT-OUTPUT table-handle v-tth105
    )  .
delete object v-tth105.
    end.
    if l-shift-on
    or cas-shft then do:
      run fltfield-add in this-procedure('shift-date*shift-num'
                                        , 'Дата смены/№ смены'
                                        , ('sht' + chr(4) +
                                          parobj-type + chr(4) +
                                          string(parobj-code) + chr(4) +
                                          'no'),
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    end.
  END.
END CASE.
run fltfield-add in this-procedure('shift-date', 'Дата Смены(учета)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-num', 'Номер по кассе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-desk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cashier', 'Код кассира', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sales-man', 'Код продавца', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cashier-psn-code', 'Кассир-код в справочнике клиентов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('salesman-psn-code', 'Продавец-код в справочнике клиентов', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sub-discnt', 'Списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', 'Нетто сумма (выручка)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('out-code', 'Номер продажи', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', 'N дис.карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('z-number', 'N Z-отчета', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('entry(1 ~~054c-doc.doc-num~~054chr(4))', 'N док-та', 'function_character',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('src-tot-doc', 'брутто-чек', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ps', 'Примечание', '',
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
define variable v-int as integer   no-undo .
assign
sch-date = ?
.
display
sch-date
0 @ sch-sum
with frame Dialog-Frame.
if par-mode = 'IBS-TH':U
and lookup(string(p-chk-type), '201,206,208,301,306':U) = 0 then do:
  assign
  v-int = integer(pardoc-code)
  no-error.
  if error-status :error
  or trim(pardoc-code, "1234567890") <> ''
  or length(pardoc-code) > 9 then do:
    bell.
    undo, return error .
  end.
  assign
  pardoc-code = string(integer(pardoc-code)).
  run OpenBr in this-procedure (
      input false
      ,input par-next
      ,input substitute("and c-doc.chk-num  = &1 "
        , pardoc-code)
      ).
end.
else do:
  assign
  pardoc-code = chr(34) + pardoc-code + chr(34).
  run OpenBr in this-procedure (
      input false
      ,input par-next
      ,input substitute("and c-doc.doc-code   begins &1 "
        , pardoc-code)
      ).
end.
apply "entry":u to sch-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-date :
define input parameter par-next as logical no-undo.
define input parameter parchk-date like ub.chk-doc.chk-date no-undo.
define variable varchk-datechr as character no-undo.
display
'':U @ sch-code
0 @ sch-sum
with frame Dialog-Frame.
assign
varchk-datechr = string(day(parchk-date)) + chr(47) +
                 string(month(parchk-date)) + chr(47) +
                 string(year(parchk-date)).
run OpenBr in this-procedure (
   input false
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
apply "entry":u to sch-sum in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE reposition-chk-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-chk-doc-recid as recid no-undo .
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
  .
  run reposition-query in this-procedure
    (input p-chk-doc-recid
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
