DEFINE NEW SHARED BUFFER buf-oo_ord-doc FOR ub.ord-doc.
DEFINE BUFFER buf-oo_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER buf-oo_trn-doc FOR trn-doc.
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns         as character    no-undo .
define input parameter par-mode      as character    no-undo .
define input parameter pardoc-rec    as recid no-undo.
define input parameter par-host-code like ub.clients.obj-code no-undo.
define input parameter p-obj-code    like ub.clients.obj-code no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-doc-type    as character no-undo .
define input parameter p-status_     as character no-undo .
define input parameter p-char        as character no-undo .
define output param rid-list         as  character  no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список заказов ОО ".
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
define buffer buf_clients for ub.clients.
define variable g#log      as logical   no-undo .
define variable doc-rec    as recid no-undo .
define VARIABLE next-prev    as logical   no-undo .
define variable p-mark as character no-undo .
define variable g-log as logical no-undo .
define variable v-doc-rec as recid no-undo .
define variable sch-field as character  no-undo.
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
define variable to-day       as date no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable filter-point as character no-undo init "Список заказов ОО" .
define variable filter-point0 as character no-undo init "Заказы ОО" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .
define variable br-handle as handle  no-undo .
DEFINE new SHARED VARIABLE Sort-gr AS LOGICAL
     LABEL "Сортировать по группам товаров"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO init false .
DEFINE new Shared VARIABLE print-graft AS LOGICAL
     LABEL "Отладочная печать"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO init true .
FUNCTION f-direct RETURNS CHARACTER
( par1 as recid ) FORWARD.
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 9 BY 1 TOOLTIP "Добавить новый заказ".
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 12 BY 1 TOOLTIP "Корректировка заказа".
DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     SIZE 12 BY 1 TOOLTIP "Закрыть заказ".
DEFINE BUTTON B-close-trn
     LABEL "Закр&ыть"
     SIZE 10 BY 1 TOOLTIP "Закрыть накладную".
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 12 BY 1 TOOLTIP "Удалитиь заказ".
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-history
     LABEL "&История":L
     SIZE 3 BY 1 TOOLTIP "История заказа".
DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 12 BY 1 TOOLTIP "Просмотр заказа без корректировки".
DEFINE BUTTON B-lkp-2
     LABEL "Просмо&тр"
     SIZE 10 BY 1 TOOLTIP "Просмотр запроса".
DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.
DEFINE BUTTON b-move
     LABEL "Р&аспределить":L
     SIZE 16.8 BY 1 TOOLTIP "Сформировать заявки по заказам".
DEFINE BUTTON b-move-to
     LABEL "Отправить":L
     SIZE 16.8 BY 1 TOOLTIP "Перенаправить заказ новый+ на распределение".
DEFINE BUTTON b-open
     LABEL "&Открыть":L
     SIZE 12 BY 1 TOOLTIP "Открыть запр+ до запр-".
DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 3 BY 1 TOOLTIP "Печать заказа".
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 12 BY 1 TOOLTIP "Выход из режима".
DEFINE BUTTON B-rez
     LABEL "Резе&рв"
     SIZE 10 BY 1 TOOLTIP "Создать расходный запрос у контрагента".
DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     SIZE 3 BY 1 TOOLTIP "Фильтр по списку заказов".
DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     SIZE 12 BY 1 TOOLTIP "Выход из режима и выбор текущего номера  заказа".
DEFINE VARIABLE loc-ps AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 94.6 BY 1.76 TOOLTIP "Примечание"
     FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE loc-agnt AS CHARACTER FORMAT "X(256)":U
     LABEL "Исп"
      VIEW-AS TEXT
     SIZE 17.2 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc-boss AS CHARACTER FORMAT "X(256)":U
     LABEL "М-р"
      VIEW-AS TEXT
     SIZE 17.2 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc-creid AS CHARACTER FORMAT "X(256)":U
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc-wrkr AS CHARACTER FORMAT "X(256)":U
     LABEL "Кл-к"
      VIEW-AS TEXT
     SIZE 17.2 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sch-code AS CHARACTER FORMAT "x(12)"
     LABEL "&Начало номера"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999"
     LABEL "Д&ата"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE sch-fact AS DATE FORMAT "99/99/9999"
     LABEL "Фа&кт"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE sch-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE new shared QUERY br-docs FOR
      buf-oo_ord-doc SCROLLING.
DEFINE QUERY br-zapr FOR
      buf-oo_ord-doc-rcv,
      ord-chain,
      buf-oo_trn-doc SCROLLING.
DEFINE BROWSE br-docs
  QUERY  br-docs NO-LOCK DISPLAY
      mark-string(recid(ub.buf-oo_ord-doc), rid-list) COLUMN-LABEL '*' FORMAT "X(1)"
      buf-oo_ord-doc.status_ COLUMN-LABEL 'Статус' Format "X(6)"
      buf-oo_ord-doc.flag_ COLUMN-LABEL 'OK' format "+/-"
      buf-oo_ord-doc.doc-code COLUMN-LABEL '№ док-та' Format "X(9)"
      buf-oo_ord-doc.doc-date COLUMN-LABEL 'Создан' FORMAT "99/99/99"
      buf-oo_ord-doc.fact-date COLUMN-LABEL 'Факт' FORMAT "99/99/99"
      buf-oo_ord-doc.ship-date COLUMN-LABEL 'Поставка' FORMAT "99/99/99"
      buf-oo_ord-doc.obj-code COLUMN-LABEL 'Объект' format ">>>>>9"
      buf-oo_ord-doc.obj-type COLUMN-LABEL 'Тип' format "x(3)"
      buf-oo_ord-doc.out-code COLUMN-LABEL 'Нераспред.!остаток' Format "X(9)"
      buf-oo_ord-doc.qnty COLUMN-LABEL 'Количество'
      buf-oo_ord-doc.sum-rubl COLUMN-LABEL 'Сумма в руб.' format ">,>>>,>>>,>>9.99"
      f-direct(recid( ub.buf-oo_ord-doc)) COLUMN-LABEL '>' format "x(1)"
      buf-oo_ord-doc.ship-date COLUMN-LABEL 'Поставка' FORMAT "99/99/99"
  ENABLE
       buf-oo_ord-doc.status_
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.4 BY 9.81
         BGCOLOR 15 .
DEFINE BROWSE br-zapr
  QUERY br-zapr NO-LOCK DISPLAY
      buf-oo_trn-doc.doc-code
      buf-oo_trn-doc.doc-type FORMAT "X(3)"
      buf-oo_trn-doc.status_ COLUMN-LABEL "Стат" FORMAT "X(4)"
      buf-oo_trn-doc.flag_ COLUMN-LABEL "Ок" FORMAT "+/-"
      buf-oo_trn-doc.cli-type + string(buf-oo_trn-doc.cli-code)  COLUMN-LABEL "Контрагент"
      buf-oo_trn-doc.obj-type + string(buf-oo_trn-doc.obj-code)  COLUMN-LABEL "Объект"
      buf-oo_trn-doc.doc-date
      buf-oo_trn-doc.fact-date
      buf-oo_trn-doc.tot-lines
      buf-oo_trn-doc.fact-qnty COLUMN-LABEL "Количество" FORMAT ">>>>>>>>9.<<<"
      buf-oo_trn-doc.tot-rubl  COLUMN-LABEL "Сумма руб." FORMAT ">>>>>>>>>9.99"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 94.8 BY 5.57.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 2
     b-sel AT ROW 1 COL 14
     b-close AT ROW 1 COL 26
     b-open AT ROW 1 COL 38
     b-move-to AT ROW 1 COL 50
     b-sch AT ROW 1 COL 87
     b-history AT ROW 1 COL 90
     b-help AT ROW 1 COL 93
     b-mark AT ROW 2 COL 2
     b-add AT ROW 2 COL 5
     b-lkp AT ROW 2 COL 14
     b-chg AT ROW 2 COL 26
     b-del AT ROW 2 COL 38
     b-move AT ROW 2 COL 50
     b-print AT ROW 2 COL 93
     sch-code AT ROW 3.1 COL 26 COLON-ALIGNED
     sch-date AT ROW 3.1 COL 47 COLON-ALIGNED
     sch-fact AT ROW 3.1 COL 65.8 COLON-ALIGNED
     br-docs AT ROW 4.19 COL 1
     loc-ps AT ROW 15.1 COL 1.6 NO-LABEL WIDGET-ID 6
     B-lkp-2 AT ROW 16.95 COL 1
     B-close-trn AT ROW 16.95 COL 11
     B-rez AT ROW 16.95 COL 21
     br-zapr AT ROW 18.14 COL 1.6
     sch-num AT ROW 3.24 COL 80.4 COLON-ALIGNED NO-LABEL
     loc-boss AT ROW 14.38 COL 4.6 COLON-ALIGNED
     loc-agnt AT ROW 14.38 COL 27.8 COLON-ALIGNED
     loc-wrkr AT ROW 14.38 COL 53 COLON-ALIGNED
     loc-creid AT ROW 14.38 COL 80.4 COLON-ALIGNED
     " Поиск по:" VIEW-AS TEXT
          SIZE 10.2 BY .67 AT ROW 3.24 COL 1.6
          BGCOLOR 3 FGCOLOR 15
     SPACE(84.59) SKIP(19.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список заказов ОО".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-close-trn:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-rez:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       br-docs:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.
ASSIGN
       loc-ps:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  run proc-add in this-procedure .
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
if not available buf-oo_ord-doc then return.
do on stop undo, return no-apply :
  find current buf-OO_ord-doc exclusive-lock.
end.
 define variable rr as recid no-undo .
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_o-o_update':U
    ,input  'object':U
    ,input  buf-oo_ord-doc.host-code
    ,input  buf-oo_ord-doc.obj-type
    ,input  buf-oo_ord-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
   if not( buf-oo_ord-doc.status_ = 'новый':U and buf-oo_ord-doc.flag_ = false ) then do:
      message "Нельзя корректировать заказ! " view-as alert-box  .
      return.
  end.
 rr = recid(buf-oo_ord-doc) .
    run cus/ord-oou.w (
    input parParentProc ,
    input 'ИЗМЕНЕНИЕ':U ,
    input-output rr  ,
    input-output br-handle ,
    input-output next-prev ) .
  v-doc-rec = rr .
  g#log =  br-docs:refresh() .
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
  apply "entry" TO BR-docs IN FRAME Dialog-Frame.
END.
ON CHOOSE OF b-close IN FRAME Dialog-Frame
DO:
  define variable rr as recid no-undo .
  if not available buf-oo_ord-doc then return.
  rr = recid(buf-oo_ord-doc) .
  run ord-close in this-procedure (recid(buf-oo_ord-doc)) .
  run openbr in this-procedure ( yes, no, '':u).
  reposition br-docs to recid rr no-error.
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
  apply "entry" TO BR-docs IN FRAME Dialog-Frame.
END.
ON CHOOSE OF B-close-trn IN FRAME Dialog-Frame
DO:
 if not available buf-oo_trn-doc   then return.
 message "Закрыть внутренний запрос ?"
  view-as alert-box question
  buttons yes-no
  update g-log.
  if g-log = false then return no-apply.
  if not (buf-oo_trn-doc.status_  = 'запрос':U   ) then do:
    message "Закрыть можно только ЗАПР !"
            view-as alert-box information .
    return no-apply.
  end.
  run close-zapr in this-procedure (buf-oo_trn-doc.doc-code) .
  OPEN QUERY br-zapr FOR EACH buf-oo_ord-doc-rcv WHERE                   buf-oo_ord-doc-rcv.doc-code = buf-oo_ord-doc.doc-code NO-LOCK,            each ub.ord-chain no-lock where             ub.ord-chain.doc-code = buf-oo_ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and             ub.ord-chain.rel-doc-type = 'trn'    ,              EACH buf-oo_trn-doc  where                  buf-oo_trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  if not available buf-oo_ord-doc then return.
  do on stop undo, return no-apply :
    find current buf-OO_ord-doc exclusive-lock .
  end.
  if not( buf-oo_ord-doc.status_ = 'новый':U and buf-oo_ord-doc.flag_ = false ) then do:
    message "Нельзя удалять заказ ! " view-as alert-box  .
    return .
  end.
  run ord-del in this-procedure ( recid(buf-oo_ord-doc)) .
END.
ON CHOOSE OF b-history IN FRAME Dialog-Frame
DO:
if not available buf-oo_ord-doc then return .
    run cus/ordcdoc.w
    (
    parParentProc,
    buf-oo_ord-doc.host-code,
    buf-oo_ord-doc.doc-code,
    "" ) .
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
 define variable rr as recid no-undo .
 rr = recid(buf-oo_ord-doc) .
      br-handle = br-docs:handle in frame Dialog-Frame .
      next-prev = no.
      do while next-prev <> ?:
        if not available buf-oo_ord-doc then do:
          message "Неправильный выбор документа.".
          return no-apply.
        end.
    run cus/ord-oou.w (
        input parParentProc ,
        input 'ПРОСМОТР':U ,
        input-output rr  ,
        input-output br-handle ,
        input-output next-prev ) .
          v-doc-rec = rr .
        if br-handle = ? then reposition br-docs to recid rr no-error.
      end.
apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
END.
ON CHOOSE OF B-lkp-2 IN FRAME Dialog-Frame
DO:
   if available buf-oo_trn-doc then
      run str/showdoc.p
          (input parparentproc
          ,input buf-oo_trn-doc.doc-code
          ,input ""
          ,input ""
          ,input 0
          ,input true
          ) no-error .
          if error-status :error then message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "Ошибка из showdoc.p"
            view-as alert-box error
          .
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
    if available buf-oo_ord-doc then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid17 as character no-undo .
define variable v-num-entry17 as integer   no-undo .
assign
  v-str-recid17 = trim( string( recid( buf-oo_ord-doc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry17 = lookup( v-str-recid17 , rid-list )
.
if v-num-entry17 > 0 then do:
  assign
    entry( v-num-entry17, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid17
  .
end.
    g-log = br-docs:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        g-log = br-docs:select-next-row ().
        apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
    end.
end.
apply "entry" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF b-move IN FRAME Dialog-Frame
DO:
if not available buf-oo_ord-doc then return.
if not( buf-oo_ord-doc.status_ = 'запрос':U and
       buf-oo_ord-doc.flag_ = false  )  then do :
        Message
          "Нельзя распределять  заказ в статусе " caps(buf-oo_ord-doc.status_) + string(buf-oo_ord-doc.flag_,"+/-") skip
          "Документ" buf-oo_ord-doc.doc-code view-as alert-box information
          .
        return.
      end.
 if v-cntxt-db-num = 0 and buf-oo_ord-doc.order-type = 3 then do:
        Message
          "Распределение заказа указано в Удаленной БД!" skip
          "Документ" buf-oo_ord-doc.doc-code view-as alert-box information
          .
        return.
  end.
 if v-cntxt-db-num <> 0 and buf-oo_ord-doc.order-type = 2 then do:
        Message
          "Распределение заказа указано в Главной БД!"   skip
          "Документ" buf-oo_ord-doc.doc-code view-as alert-box information
          .
        return.
  end.
 define variable rr as recid no-undo .
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_o-o_add-def':U
    ,input  'object':U
    ,input  buf-oo_ord-doc.host-code
    ,input  buf-oo_ord-doc.obj-type
    ,input  buf-oo_ord-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
    rr = recid(buf-oo_ord-doc) .
    message "Распределить заказ автоматически ?"
        view-as alert-box question
        buttons yes-no
        update g-log.
        if g-log = true then do:
            run cus/ord-ooam.p
                ( input parParentProc ,
                  input-output rr ) .
            v-doc-rec = rr .
        end.
        else do:
            run cus/ord-oorm.w
               ( input parParentProc ,
                 input-output rr ) .
            v-doc-rec = rr .
        end.
  run openbr in this-procedure ( yes, no, '':u).
  reposition br-docs to recid rr no-error.
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
  apply "entry" TO BR-docs IN FRAME Dialog-Frame.
END.
ON CHOOSE OF b-move-to IN FRAME Dialog-Frame
DO:
if not available buf-oo_ord-doc then return.
if not( buf-oo_ord-doc.status_ = 'новый':U  and
       buf-oo_ord-doc.flag_ = yes )  then do :
        Message
          "Нельзя перенаправить распределять  заказ в статусе "
          caps(buf-oo_ord-doc.status_) + string(buf-oo_ord-doc.flag_,"+/-") skip
          "Документ" buf-oo_ord-doc.doc-code view-as alert-box information
          .
        return.
      end.
 if v-cntxt-db-num = 0 and buf-oo_ord-doc.order-type = 3 then do:
        Message
          "Распределение заказа уже указано в Удаленной БД!" skip
          "Изменить нельзя." skip
          "Документ" buf-oo_ord-doc.doc-code view-as alert-box information
          .
        return.
  end.
 if v-cntxt-db-num <> 0 and buf-oo_ord-doc.order-type = 2 then do:
        Message
          "Распределение заказа уже указано в Главной БД!"   skip
          "Изменить нельзя." skip
          "Документ" buf-oo_ord-doc.doc-code view-as alert-box information
          .
        return.
  end.
  define buffer buf_clients for ub.clients .
  find first buf_clients no-lock where
              buf_clients.obj-code = buf-oo_ord-doc.obj-code and
              buf_clients.obj-type = buf-oo_ord-doc.obj-type no-error .
  if v-cntxt-db-num = 0 and  buf_clients.db-num = 0
  then do:
        Message
          "Нельзя перенаправить распределение в УБД для объекта главной БД "
           skip
          "Документ" buf-oo_ord-doc.doc-code view-as alert-box information
          .
        return.
  end.
 define variable rr as recid no-undo .
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_o-o_add-def':U
    ,input  'object':U
    ,input  buf-oo_ord-doc.host-code
    ,input  buf-oo_ord-doc.obj-type
    ,input  buf-oo_ord-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
    rr = recid(buf-oo_ord-doc) .
    message "Перенаправить распределение заказа в другую БД по СПН ?"
        view-as alert-box question
        buttons yes-no
        update g-log.
        if g-log = true then do:
            find current buf-oo_ord-doc  exclusive-lock  no-error .
            if v-cntxt-db-num = 0 then do:
               buf-oo_ord-doc.order-type = 3 .
            end.
            else do:
               buf-oo_ord-doc.order-type = 2 .
            end.
        end.
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
  apply "entry" TO BR-docs IN FRAME Dialog-Frame.
END.
ON CHOOSE OF b-open IN FRAME Dialog-Frame
DO:
  define variable rr as recid no-undo .
  if not available buf-oo_ord-doc then return.
  rr = recid(buf-oo_ord-doc) .
  run ord-open in this-procedure ( recid(buf-oo_ord-doc) ) .
  run openbr in this-procedure (yes, no, '':u).
  reposition br-docs to recid rr no-error.
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
  apply "entry" TO BR-docs IN FRAME Dialog-Frame.
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
  find current buf-oo_ord-doc no-lock no-error .
  if available buf-oo_ord-doc then
      run cus/torg-26.p
       ( input parParentProc ,
         recid (buf-oo_ord-doc) ) .
END.
ON CHOOSE OF B-rez IN FRAME Dialog-Frame
DO:
  if available buf-oo_trn-doc   then do:
     run cus/ord-mrz.p
      ( input parParentProc ,
        input recid(buf-oo_trn-doc))
        .
     OPEN QUERY br-zapr FOR EACH buf-oo_ord-doc-rcv WHERE                   buf-oo_ord-doc-rcv.doc-code = buf-oo_ord-doc.doc-code NO-LOCK,            each ub.ord-chain no-lock where             ub.ord-chain.doc-code = buf-oo_ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and             ub.ord-chain.rel-doc-type = 'trn'    ,              EACH buf-oo_trn-doc  where                  buf-oo_trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK.
   end.
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
    run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if ( available buf-oo_ord-doc ) AND ( rid-list = "" ) then
    rid-list = string( recid( buf-oo_ord-doc ) ) .
END.
ON VALUE-CHANGED OF br-docs IN FRAME Dialog-Frame
DO:
 if not available buf-oo_ord-doc then do:
    OPEN QUERY br-zapr FOR EACH buf-oo_ord-doc-rcv WHERE                   buf-oo_ord-doc-rcv.doc-code = buf-oo_ord-doc.doc-code NO-LOCK,            each ub.ord-chain no-lock where             ub.ord-chain.doc-code = buf-oo_ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and             ub.ord-chain.rel-doc-type = 'trn'    ,              EACH buf-oo_trn-doc  where                  buf-oo_trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK.
    return .
 end.
 define buffer buf_clients for ub.clients.
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  buf-oo_ord-doc.creid
  ,output loc-creid
  )  .
 find first buf_clients no-lock where
         buf_clients.obj-type = 'чел':U  and
         buf_clients.obj-code  = buf-oo_ord-doc.boss no-error.
    if available buf_clients then loc-boss = buf_clients.obj-name.
    else loc-boss = "".
 find first buf_clients no-lock where
         buf_clients.obj-type = 'чел':U  and
         buf_clients.obj-code  = buf-oo_ord-doc.agnt no-error.
    if available buf_clients then loc-agnt = buf_clients.obj-name.
    else loc-agnt = "".
 find first buf_clients no-lock where
         buf_clients.obj-type = 'чел':U  and
         buf_clients.obj-code  = buf-oo_ord-doc.wrkr no-error.
    if available buf_clients then loc-wrkr = buf_clients.obj-name.
    else loc-wrkr = "".
  loc-ps = trim(buf-oo_ord-doc.PS).
  display loc-creid
    loc-boss
    loc-agnt
    loc-wrkr
    loc-ps
  with frame Dialog-Frame.
  OPEN QUERY br-zapr FOR EACH buf-oo_ord-doc-rcv WHERE                   buf-oo_ord-doc-rcv.doc-code = buf-oo_ord-doc.doc-code NO-LOCK,            each ub.ord-chain no-lock where             ub.ord-chain.doc-code = buf-oo_ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and             ub.ord-chain.rel-doc-type = 'trn'    ,              EACH buf-oo_trn-doc  where                  buf-oo_trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK.
END.
ON return OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-sch-code in this-procedure(no, input frame Dialog-Frame sch-code) no-error.
  return no-apply.
END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-sch-code in this-procedure(yes, input frame Dialog-Frame sch-code) no-error.
  if error-status:error then return no-apply.
END.
ON return OF sch-date IN FRAME Dialog-Frame
DO:
  run proc-sch-date in this-procedure(no, input frame Dialog-Frame sch-date) no-error.
  return no-apply.
END.
ON CTRL-J OF sch-date IN FRAME Dialog-Frame
DO:
  run proc-sch-date in this-procedure(yes, input frame Dialog-Frame sch-date) no-error.
  if error-status:error then return no-apply.
END.
ON return OF sch-fact IN FRAME Dialog-Frame
DO:
  run proc-sch-fact in this-procedure(no, input frame Dialog-Frame sch-fact) no-error.
  return no-apply.
END.
ON CTRL-J OF sch-fact IN FRAME Dialog-Frame
DO:
  run proc-sch-fact in this-procedure(yes, input frame Dialog-Frame sch-fact) no-error.
  if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-docs :SET-REPOSITIONED-ROW(8, "CONDITIONAL") .
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date24
    MENU-ITEM m-ed-date24-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date24-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date24-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date24-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date24 :HANDLE
      sch-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle24 as handle no-undo .
  assign
    v-label-handle24 = sch-date :side-label-handle in frame Dialog-Frame
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
    apply "ctrl-b":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-2 in menu m-ed-date24 DO:
    apply "ctrl-d":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-3 in menu m-ed-date24 DO:
    apply "ctrl-e":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-4 in menu m-ed-date24 DO:
    apply "ctrl-f":U to sch-date in frame Dialog-Frame .
  END.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-fact in frame Dialog-Frame
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
on delete-character of sch-fact in frame Dialog-Frame
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
on ctrl-d of sch-fact in frame Dialog-Frame
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
on ctrl-b of sch-fact in frame Dialog-Frame
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
on ctrl-e of sch-fact in frame Dialog-Frame
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
on ctrl-f of sch-fact in frame Dialog-Frame
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
  if sch-fact :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-fact :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date26 :HANDLE
      sch-fact :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle26 as handle no-undo .
  assign
    v-label-handle26 = sch-fact :side-label-handle in frame Dialog-Frame
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
    apply "ctrl-b":U to sch-fact in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-2 in menu m-ed-date26 DO:
    apply "ctrl-d":U to sch-fact in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-3 in menu m-ed-date26 DO:
    apply "ctrl-e":U to sch-fact in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-4 in menu m-ed-date26 DO:
    apply "ctrl-f":U to sch-fact in frame Dialog-Frame .
  END.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  run OpenBr(yes, no, '':U).
    apply "VALUE-CHANGED" to br-docs.
end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-docs as INT EXTENT 12 no-undo.
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
  RUN re-move-clmnbr-docs ( 5, 12).
END.
ON ctrl-cursor-left OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (12, 5).
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
  if cur-clmn-loc <= 5 then do:
    return .
  end.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-loc THEN move-elementbr-docs = varmvibr-docs.
  END.
  RUN re-move-clmnbr-docs (cur-clmn-loc, 5).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-docs = 5 to EXTENT(cur-clmn-numbr-docs):
    RUN re-move-clmnbr-docs (cur-clmn-numbr-docs[varmvlbr-docs], varmvlbr-docs).
  END.
  RUN start-mv-clmnbr-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelbr-docs   as character no-undo .
def var sort-clmnbr-docs    as handle    no-undo .
def var cur-clmnbr-docs     as handle    no-undo .
def var cur-clmn-locbr-docs as integer   no-undo .
def var re-querybr-docs     as logical   initial no no-undo .
on start-search, ctrl-o of br-docs in frame Dialog-Frame do:
   run sort-brbr-docs
     (input (if available buf-oo_ord-doc
             then recid(buf-oo_ord-doc)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-docs :
  define input parameter p-recid as recid no-undo .
  if re-querybr-docs = no then do:
    assign
       cur-clmnbr-docs = br-docs:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-docs <> ? then sort-clmnbr-docs:column-fgcolor = 0.
    if cur-clmnbr-docs = sort-clmnbr-docs then do:
      assign
         sort-labelbr-docs = ""
         sort-clmnbr-docs = ?
      .
     end.
     else do:
       assign
         sort-labelbr-docs = cur-clmnbr-docs:label
         sort-clmnbr-docs  = cur-clmnbr-docs
         sort-clmnbr-docs:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-docs = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-docs:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-docs then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-docs = cur-clmn-locbr-docs + 1
    .
  end.
  case sort-labelbr-docs:
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(buf-oo_ord-doc), &1&2&1)', chr(34), rid-list)     .     run OpenBr(yes, no, '':U).   . END.
        when 'Статус'  then DO:    assign       sort-column-name = "buf-oo_ord-doc.status_"     .     run OpenBr(yes, no, '':U).   . END.
        when 'OK'  then DO:    assign       sort-column-name = "buf-oo_ord-doc.flag_"     .     run OpenBr(yes, no, '':U).   . END.
        when '№ док-та'  then DO:    assign       sort-column-name = "buf-oo_ord-doc.doc-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Создан'  then DO:    assign       sort-column-name = "buf-oo_ord-doc.doc-date"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Факт'  then DO:    assign       sort-column-name = "buf-oo_ord-doc.fact-date"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Объект'  then DO:    assign       sort-column-name = "buf-oo_ord-doc.obj-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Тип'  then DO:    assign       sort-column-name = "buf-oo_ord-doc.obj-type"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Нераспред.!остаток'  then DO:    assign       sort-column-name = "buf-oo_ord-doc.out-code"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Количество'  then DO:    assign       sort-column-name = "buf-oo_ord-doc.qnty"     .     run OpenBr(yes, no, '':U).   . END.
        when 'Сумма в руб.'  then DO:    assign       sort-column-name = "buf-oo_ord-doc.sum-rubl"     .     run OpenBr(yes, no, '':U).   . END.
        when '>'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1f-direct&1, recid(buf-oo_ord-doc))', chr(34))     .     run OpenBr(yes, no, '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr(yes, no, '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-docs') then do:
          run mv-brw-defaultbr-docs.
        end.
      if sort-labelbr-docs <> "" then do:
        assign
          cur-clmnbr-docs:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-docs = ?
      .
    end.
  end case.
    if cur-clmn-locbr-docs <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-docs') then do:
        run ch-clmnbr-docs in this-procedure (cur-clmn-locbr-docs).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-docs to recid p-recid no-error.
    apply "value-changed" to br-docs in frame Dialog-Frame.
  end.
  apply "entry" to br-docs in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-docs:
if cur-clmnbr-docs = ? then do:
   run OpenBr(yes, no, '':U).
end.
else do:
   assign re-querybr-docs = yes.
   run sort-brbr-docs
     (input (if available buf-oo_ord-doc
             then recid(buf-oo_ord-doc)
             else ?
            )
     ).
   assign re-querybr-docs = no.
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   buf-oo_ord-doc.status_:read-only in browse br-docs = true .
   buf-oo_ord-doc.doc-code:resizable in browse br-docs = true .
   buf-oo_ord-doc.out-code:resizable in browse br-docs = true .
   define buffer find_code for ub.ord-doc.
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
  run openbr in this-procedure (yes, no, '':u).
  if pardoc-rec <> ? then
  reposition br-docs to recid doc-rec no-error.
  run diasize_add_browse in this-procedure
      (input  'width':u
      ,input  browse br-zapr :handle
      ) .
  run diasize_init in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame focus br-docs.
END.
run disable_ui in this-procedure .
PROCEDURE close-zapr :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-trn-code as character no-undo .
define buffer buf_s-trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return as logical no-undo .
define variable varchg-inv as logical no-undo .
assign
  varmode        =  '<закрытие документа>':U
  varstatus      = 'запрос':U
  varflag        = false
  varcopystatus  = 'запрос':U
  varcopyflag    = true
  varcheck-return = true
  varchg-inv = true
  .
run str/trn-graf.p
    (input  p-trn-code,
     input  v-cntxt-db-num,
     input  varmode,
     output varstatus,
     output varflag,
     output varcopystatus,
     output varcopyflag
    ) no-error.
.
if error-status:error then do:
   if error-status :get-message(1) <> "" or
      return-value = ""                  then do:
     message "Ошибка при вызове trn-graf.p." skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error.
   end.
   else do:
     message return-value
     view-as alert-box error.
   end.
   return error.
end.
define variable g#in-ov       like  ub.sysconf.in-ov     no-undo .
define variable g#rsrv-time   like  ub.sysconf.rsrv-time no-undo .
define variable g#load-time   like  ub.sysconf.load-time no-undo .
define variable g#holidays    like  ub.sysconf.holidays  no-undo .
define buffer buf_sysconf for ub.sysconf  .
find first buf_sysconf no-lock where   buf_sysconf.host-code = par-host-code no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Не верный код фирмы" par-host-code
  view-as alert-box error
.
assign
    g#in-ov      = buf_sysconf.in-ov
    g#rsrv-time  = buf_sysconf.rsrv-time
    g#load-time  = buf_sysconf.load-time
    g#holidays   = buf_sysconf.holidays
.
run str/trn-stat.p (
                input  parParentProc ,
                input this-procedure ,
                input  varmode,
                input  p-trn-code,
                input  varcheck-return,
                input  v-cntxt-db-num,
                input  g#in-ov,
                input  g#rsrv-time,
                input  g#load-time,
                input  g#holidays,
                input  yes,
                output varchg-inv,
                output table gds-list) no-error.
if error-status:error then do:
   message
     vss-workfile vss-revision vss-description skip
     "Ошибка при принудительном закрытии документа " p-trn-code skip
     return-value skip
     trim(error-status :get-message(1))
     trim(error-status :get-message(2))
     trim(error-status :get-message(3))
     trim(error-status :get-message(4))
     trim(error-status :get-message(5)) skip
     view-as alert-box error.
   return error.
end.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY sch-code sch-date sch-fact loc-ps sch-num loc-boss loc-agnt
          loc-wrkr loc-creid
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-sel b-close b-open b-move-to b-sch b-history b-help b-mark
         b-add b-lkp b-chg b-del b-move b-print sch-code sch-date sch-fact
         br-docs loc-ps B-lkp-2 br-zapr sch-num loc-boss loc-agnt
         loc-wrkr loc-creid
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-docs FOR EACH buf-oo_ord-doc NO-LOCK.    OPEN QUERY br-zapr FOR EACH buf-oo_ord-doc-rcv WHERE                   buf-oo_ord-doc-rcv.doc-code = buf-oo_ord-doc.doc-code NO-LOCK,            each ub.ord-chain no-lock where             ub.ord-chain.doc-code = buf-oo_ord-doc-rcv.rcv-code and             ub.ord-chain.doc-type = 'rcv'                  and             ub.ord-chain.rel-doc-type = 'trn'    ,              EACH buf-oo_trn-doc  where                  buf-oo_trn-doc.doc-code = ub.ord-chain.rel-doc-code  NO-LOCK.
END PROCEDURE.
PROCEDURE main-ord :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter   p-in-ord-num as character no-undo .
define output parameter  p-out-ord-num as character no-undo .
if num-entries(p-in-ord-num , "." ) = 1 then
   p-out-ord-num = p-in-ord-num .
   else do:
     p-out-ord-num = entry(1, entry( 1 , p-in-ord-num , "." ) , "-" )  + "-" + entry( 2 , p-in-ord-num , "."  ) .
   end.
  end.
END PROCEDURE.
PROCEDURE my-enable_UI :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  if v-cntxt-db-num = 0 then
  assign
    b-move-to:label in frame Dialog-Frame  = "---> УБД"
  .
  else
  assign
    b-move-to:label in frame Dialog-Frame  = "---> ГБД"
  .
  DISPLAY
     sch-code sch-date sch-fact
      WITH FRAME Dialog-Frame.
  ENABLE b-quit
         b-mark       when LOOKUP("b-mark":U,  bttns) > 0
         b-sel        when LOOKUP("b-sel":U,   bttns) > 0
         b-history
         b-sch
         b-help
         b-add        when LOOKUP("b-add":U,  bttns) > 0
         b-lkp
         b-lkp-2
         b-chg        when LOOKUP("b-chg":U,  bttns) > 0
         b-del        when LOOKUP("b-del":U,  bttns) > 0
         b-close
         b-open
         b-print
         b-move
         b-move-to
         sch-code sch-date sch-fact
         br-docs br-zapr
         loc-ps
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE OpenBr :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable p-file-label as character no-undo .
p-file-label = "Заказы Объект-Объект".
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
    WHEN 'объ':U THEN DO:
       ASSIGN frame Dialog-Frame:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name
                                          + " Объект: " +  p-obj-type
                                          + "  " +   string (p-obj-code)
                                          .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-33  as logical   no-undo .
define variable  l-filter-open-33    as logical   .
define variable  flt-rec-33       as recid     no-undo .
define variable  filter-name-33      as character no-undo .
define variable  where-phrase-33     as character no-undo .
define variable  sort-phrase-33      as character no-undo .
define variable  where-phrase-rus-33 as character no-undo .
define variable  sort-phrase-rus-33  as character no-undo .
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
                              "FOR EACH buf-oo_ord-doc"
      parameter-4-33 =
        (
          if (" buf-oo_ord-doc.host-code = par-host-code and buf-oo_ord-doc.obj-code = p-obj-code and buf-oo_ord-doc.obj-type = p-obj-type and buf-oo_ord-doc.doc-type = p-doc-type" + " " + where-phrase-33) <> ""
          then  substitute('buf-oo_ord-doc.host-code = &2 and buf-oo_ord-doc.obj-code = &3 and buf-oo_ord-doc.obj-type = &1&4&1 and buf-oo_ord-doc.doc-type = &1&5&1', chr(34) ,par-host-code , p-obj-code , p-obj-type , p-doc-type)  + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "")
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + " USE-INDEX by-obj " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX by-obj " +
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
          (" buf-oo_ord-doc.host-code = par-host-code and buf-oo_ord-doc.obj-code = p-obj-code and buf-oo_ord-doc.obj-type = p-obj-type and buf-oo_ord-doc.doc-type = p-doc-type" + " " + where-phrase-33 = "")
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
    OPEN QUERY br-docs FOR EACH buf-oo_ord-doc
      where  buf-oo_ord-doc.host-code = par-host-code and buf-oo_ord-doc.obj-code = p-obj-code and buf-oo_ord-doc.obj-type = p-obj-type and buf-oo_ord-doc.doc-type = p-doc-type
       USE-INDEX by-obj
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf-oo_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer buf-oo_ord-doc:handle) then do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-4-33 =
        "where ":u +  substitute('buf-oo_ord-doc.host-code = &2 and buf-oo_ord-doc.obj-code = &3 and buf-oo_ord-doc.obj-type = &1&4&1 and buf-oo_ord-doc.doc-type = &1&5&1', chr(34) ,par-host-code , p-obj-code , p-obj-type , p-doc-type)  + " ":u + where-phrase-33 + " ":u + p-find-condition + " " + ""
      parameter-5-33 = " USE-INDEX by-obj "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(buf-oo_ord-doc)
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input (buffer buf-oo_ord-doc:handle)
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
      parameter-3-33 =  "FOR EACH buf-oo_ord-doc"
      parameter-4-33 =
        (
          if (" buf-oo_ord-doc.host-code = par-host-code and buf-oo_ord-doc.obj-code = p-obj-code and buf-oo_ord-doc.obj-type = p-obj-type and buf-oo_ord-doc.doc-type = p-doc-type" + " " + where-phrase-33) <> ""
          then  substitute('buf-oo_ord-doc.host-code = &2 and buf-oo_ord-doc.obj-code = &3 and buf-oo_ord-doc.obj-type = &1&4&1 and buf-oo_ord-doc.doc-type = &1&5&1', chr(34) ,par-host-code , p-obj-code , p-obj-type , p-doc-type)  + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-33 = if sort-phrase-33 = ''
                           then
        (
        " " + " USE-INDEX by-obj " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " USE-INDEX by-obj " +
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
    END.
    WHEN "status":U THEN DO:
       ASSIGN frame Dialog-Frame:TITLE = title0 + "  ФИРМА: " + buf_clients.obj-name
                                          + " Объект: " +  p-obj-type
                                          + "  " +   string (p-obj-code)
                                          + "   Статус: " +  string(p-status_) .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-35  as logical   no-undo .
define variable  l-filter-open-35    as logical   .
define variable  flt-rec-35       as recid     no-undo .
define variable  filter-name-35      as character no-undo .
define variable  where-phrase-35     as character no-undo .
define variable  sort-phrase-35      as character no-undo .
define variable  where-phrase-rus-35 as character no-undo .
define variable  sort-phrase-rus-35  as character no-undo .
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
                              "FOR EACH buf-oo_ord-doc"
      parameter-4-35 =
        (
          if (" buf-oo_ord-doc.host-code = par-host-code and buf-oo_ord-doc.obj-code = p-obj-code and buf-oo_ord-doc.obj-type = p-obj-type and buf-oo_ord-doc.doc-type = p-doc-type  and buf-oo_ord-doc.status_= p-status_" + " " + where-phrase-35) <> ""
          then  substitute('buf-oo_ord-doc.host-code = &2 and buf-oo_ord-doc.obj-code = &3 and buf-oo_ord-doc.obj-type = &1&4&1 and buf-oo_ord-doc.doc-type = &1&5&1 and buf-oo_ord-doc.status_ = &1&6&1', chr(34) ,par-host-code , p-obj-code , p-obj-type , p-doc-type, p-status_ )  + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "")
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + " USE-INDEX by-obj-type " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX by-obj-type " +
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
          (" buf-oo_ord-doc.host-code = par-host-code and buf-oo_ord-doc.obj-code = p-obj-code and buf-oo_ord-doc.obj-type = p-obj-type and buf-oo_ord-doc.doc-type = p-doc-type  and buf-oo_ord-doc.status_= p-status_" + " " + where-phrase-35 = "")
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
    OPEN QUERY br-docs FOR EACH buf-oo_ord-doc
      where  buf-oo_ord-doc.host-code = par-host-code and buf-oo_ord-doc.obj-code = p-obj-code and buf-oo_ord-doc.obj-type = p-obj-type and buf-oo_ord-doc.doc-type = p-doc-type  and buf-oo_ord-doc.status_= p-status_
       USE-INDEX by-obj-type
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf-oo_ord-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-docs:handle:get-buffer-handle(1) = (buffer buf-oo_ord-doc:handle) then do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-4-35 =
        "where ":u +  substitute('buf-oo_ord-doc.host-code = &2 and buf-oo_ord-doc.obj-code = &3 and buf-oo_ord-doc.obj-type = &1&4&1 and buf-oo_ord-doc.doc-type = &1&5&1 and buf-oo_ord-doc.status_ = &1&6&1', chr(34) ,par-host-code , p-obj-code , p-obj-type , p-doc-type, p-status_ )  + " ":u + where-phrase-35 + " ":u + p-find-condition + " " + ""
      parameter-5-35 = " USE-INDEX by-obj-type "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-docs:handle
                          ,input rowid(buf-oo_ord-doc)
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input (buffer buf-oo_ord-doc:handle)
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
      parameter-3-35 =  "FOR EACH buf-oo_ord-doc"
      parameter-4-35 =
        (
          if (" buf-oo_ord-doc.host-code = par-host-code and buf-oo_ord-doc.obj-code = p-obj-code and buf-oo_ord-doc.obj-type = p-obj-type and buf-oo_ord-doc.doc-type = p-doc-type  and buf-oo_ord-doc.status_= p-status_" + " " + where-phrase-35) <> ""
          then  substitute('buf-oo_ord-doc.host-code = &2 and buf-oo_ord-doc.obj-code = &3 and buf-oo_ord-doc.obj-type = &1&4&1 and buf-oo_ord-doc.doc-type = &1&5&1 and buf-oo_ord-doc.status_ = &1&6&1', chr(34) ,par-host-code , p-obj-code , p-obj-type , p-doc-type, p-status_ )  + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-35 = if sort-phrase-35 = ''
                           then
        (
        " " + " USE-INDEX by-obj-type " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX by-obj-type " +
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
    END.
END CASE.
if not p-open-query then
  REPOSITION br-docs to recid doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame  .
  end.
END PROCEDURE.
PROCEDURE ord-close :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-loc-recid as recid no-undo .
message "Закрыть заказ ?"
view-as alert-box question
buttons yes-no
update g-log.
if g-log = false then return no-apply.
  run cus/ordoocls.p
    ( input parParentProc ,
      input p-loc-recid ,
      input true
    ) no-error .
  if error-status :error then do:
  message vss-workfile vss-revision vss-description skip
         "Ошибка ordoocls.p " skip
          skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error
  .
  return error .
  end.
  else do:
    run OpenBr in this-procedure (yes, no, '':U).
  end.
  end.
END PROCEDURE.
PROCEDURE ord-del :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-loc-recid as recid no-undo .
find current buf-oo_ord-doc  exclusive-lock    no-error .
if not available buf-oo_ord-doc  then return .
define variable g-log as log no-undo.
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_o-o_deletion':U
    ,input  'object':U
    ,input  buf-oo_ord-doc.host-code
    ,input  buf-oo_ord-doc.obj-type
    ,input  buf-oo_ord-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
if not g-log then  return .
if  buf-oo_ord-doc.status_ = 'факт':U  then do:
    message "Заказ в статусе ФАКТ не может быть удален !!!"
    view-as alert-box information .
    return error .
end.
message "Удалить запись ?"
view-as alert-box question
buttons yes-no
update g-log.
if g-log = false then return no-apply.
delete buf-oo_ord-doc .
run openbr in this-procedure (yes, no, '':u).
  end.
END PROCEDURE.
PROCEDURE ord-open :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-loc-recid as recid no-undo .
message "Открыть заказ ?"
view-as alert-box question
buttons yes-no
update g-log.
if g-log = false then return no-apply.
  run cus/ordooopn.p ( parParentProc , p-loc-recid ) no-error .
  if error-status :error then do:
  message vss-workfile vss-revision vss-description skip
         "Ошибка ordooopn.p " skip
          skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error
  .
  return error .
  end.
  else do:
    run openbr in this-procedure (yes, no, '':u).
  end.
  end.
END PROCEDURE.
PROCEDURE proc-add :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_o-o_add-def':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
if not g-log then  return .
define variable rr as recid no-undo .
  rr = ? .
    run cus/ord-oou.w (
        input parParentProc ,
        input 'ДОБАВЛЕНИЕ':U ,
        input-output rr  ,
        input-output br-handle ,
        input-output next-prev ) .
  v-doc-rec = rr .
  run openbr in this-procedure (yes, no, '':u).
  reposition br-docs to recid v-doc-rec no-error .
  apply "VALUE-CHANGED" TO BR-docs IN FRAME Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE proc-b-sch :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
assign
  tbl = 'ord-doc'
  join-tbl = 'buf-oo_ord-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code'                      , '№ заказа'  , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_'                       , 'Статус'    , 'order-status-all',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('flag_'                         , 'ОК'        , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date'                      , 'Дата док-та', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date'                     , 'Дата факт'  , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type*obj-code'  , 'Объект'     , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('agnt'                          , 'Исполнитель', 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('boss'                          , 'Менеджер'   , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('wrkr'                          , 'Кладовщик'  , 'cli',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('creid'                         , 'Создал'     , 'usr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code'                     , 'Фирма'      , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-code'                      , 'Код оплаты' , 'pay',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-date'                     , 'Дата доставки заказа' , '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-time'                     , 'Время доставки заказа', 'time',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS'                            , 'Примечание', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('exch-code'                      , 'Валюта','curr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name'                      , 'Правил', 'usr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( input parParentProc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run openbr in this-procedure (yes, no, '':U).
END.
  end.
END PROCEDURE.
PROCEDURE proc-sch-code :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as character  no-undo.
display "" @ sch-date with frame Dialog-Frame.
display "" @ sch-fact with frame Dialog-Frame.
assign
  pardoc-code = chr(34) + pardoc-code + chr(34) .
run OpenBr in this-procedure
    (input false
    ,input par-next
    ,input substitute("and buf-oo_ord-doc.doc-code begins &1 "
    , pardoc-code)
    ) no-error .
    if error-status :error or return-value = ? then
       message "Не найдено ни одной записи !" view-as alert-box .
 apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE proc-sch-date :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as date no-undo.
define variable ppp as character no-undo .
display "" @ sch-fact with frame Dialog-Frame.
display "" @ sch-code with frame Dialog-Frame.
ppp =  string( day(pardoc-code)) + "/" +  string(month (pardoc-code)) + "/" +  string( year(pardoc-code)) .
run OpenBr in this-procedure
    (input false
    ,input par-next
    ,input substitute(" and buf-oo_ord-doc.doc-date = &1 " , ppp )
    ) no-error .
    if error-status :error or return-value = ? then
       message "За эту дату не найдено ни одной записи !" view-as alert-box .
apply "VALUE-CHANGED" to br-docs  in frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE proc-sch-fact :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as date no-undo.
define variable ppp as character no-undo .
display "" @ sch-date with frame Dialog-Frame.
display "" @ sch-code with frame Dialog-Frame.
ppp =  string( day(pardoc-code)) + "/" +  string( month(pardoc-code)) + "/" +  string( year(pardoc-code)) .
run OpenBr in this-procedure
    (input false
    ,input par-next
    ,input substitute("and buf-oo_ord-doc.fact-date = &1 "
      , ppp )
    ) no-error .
    if error-status :error or return-value = ? then
       message "За эту дату не найдено ни одной записи !" view-as alert-box .
apply "VALUE-CHANGED" to br-docs  in frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE UI-on :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 run openbr in this-procedure ( yes, no, '':u).
  end.
END PROCEDURE.
FUNCTION f-direct RETURNS CHARACTER
( par1 as recid ):
define buffer fl for ub.ord-doc.
define variable v-res as character no-undo .
define variable v-res-0 as character no-undo .
find first fl no-lock where recid(fl) = par1 no-error .
if error-status :error then return chr(32) .
v-res = chr(42) .
v-res-0 = chr(32) .
if v-cntxt-db-num = 0 then
    if fl.order-type = 3  then return v-res.
      else return v-res-0 .
else
   if fl.order-type = 2  then return v-res.
      else return v-res-0 .
END FUNCTION.
