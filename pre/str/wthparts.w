define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-coll-point     as character no-undo .
define input parameter p-edit-mode  as character no-undo .
define input parameter p-wth-code   as integer   no-undo.
define input parameter p-par-code   as INTEGER   no-undo.
define input parameter p-ser-code   as INTEGER   no-undo.
define input parameter p-db-num     as INTEGER no-undo.
define input parameter p-wth-doc    as character no-undo.
define input parameter p-w-p-code   as INTEGER no-undo.
define input parameter p-cli-type  like ub.clients.obj-type no-undo .
define input parameter p-cli-code  like ub.clients.obj-code no-undo .
define input parameter p-type      as character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран просмотра партий МЦ".
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info8, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info8, return-value, chr(10), error-status :get-message (1)).
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure fact-order-mpl :
  do
  on error undo, return error return-value
  :
define input  parameter p-doc-date as date     no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-fact-order as decimal   no-undo .
define variable v-fact-date            as date    no-undo .
define variable v-fact-time            as integer no-undo .
define variable v-fact-order           as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable l-shift-on as logical no-undo .
define variable l-date as date      no-undo .
define variable l-time as integer   no-undo .
define variable shift-date as date      no-undo .
define variable shift-num  as integer   no-undo .
define variable shift-name as character no-undo .
define variable max-fact-order as decimal   no-undo .
define buffer buf_global-state for ub.global-state  .
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
  run cur-time in this-procedure
  ( output v-fact-date ,
    output v-fact-time  ).
if p-doc-date = ? then do:
if buf_global-state.pl-use-sys-date-time  = true then do:
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  ?
        ,input  ?
        ,input  false
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
else do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error then return error "Неопределена дата на объекте " + return-value .
      if p-doc-date <> ? then do:
      end.
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error substitute(" Ошибка из factdate.p: &1 &2"  , return-value , error-status :get-message(1)   ) .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
end.
else do:
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error "Ошибка factdate.p " + return-value .
      v-fact-date = p-doc-date .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
  end.
end procedure.
DEFINE TEMP-TABLE tt_price-all NO-UNDO LIKE ub.price-all
field sale-qnty as decimal
field sale-sum  as decimal
field sale-tnv  as decimal
field price-sale-base as decimal
field price-sale-rubl as decimal
field road-tax-base   as decimal
field road-tax-rubl   as decimal
field excise-base as decimal
field excise-rubl as decimal
field date-1 as date
field date-2 as date
field shift-1 as int
field shift-2 as int
field time-1 as int
field time-2 as int
field grp-name as char
field interv-name as char
field pay-name as char
field unit-cli as char
index pi
plt-priority DESCENDING
fact-order DESCENDING
qnty-from asc
sum-from asc
turnover-from asc
date-1 DESCENDING
time-1 DESCENDING
date-2 DESCENDING
time-2 DESCENDING
type-price DESCENDING
.
procedure mpl-autoprice :
define input  parameter p-only-b-code as logical   no-undo .
define input  parameter p-cli-type    as character no-undo .
define input  parameter p-cli-code    as integer   no-undo .
define input  parameter p-main-b-code as integer   no-undo .
define input  parameter p-b-code      as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-qnty-doc    as decimal   no-undo .
define input  parameter p-sum-doc     as decimal   no-undo .
define input  parameter p-vid-pay        as character no-undo .
define input  parameter p-cash-pay-type  as character no-undo .
define input  parameter p-fact-order  as decimal   no-undo .
define output parameter p-plt-id          as integer   no-undo .
define output parameter p-plt-db-num      as integer   no-undo .
define output parameter p-pdf-id          as integer   no-undo .
define output parameter p-pdf-db-num      as integer   no-undo .
define output parameter p-sale-price-base as decimal   no-undo .
define output parameter p-sale-price-rubl as decimal   no-undo .
define output parameter p-road-tax-base as decimal   no-undo .
define output parameter p-road-tax-rubl as decimal   no-undo .
define output parameter p-excise-base   as decimal   no-undo .
define output parameter p-excise-rubl   as decimal   no-undo .
define variable v-cli-oborot-ALL as decimal   no-undo .
define buffer buf_buyer-in-buyer-group   for ub.buyer-in-buyer-group  .
define buffer buf_turnover-buyer-main    for ub.turnover-buyer-main  .
define buffer buf1_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf2_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf_price-all              for ub.price-all  .
define buffer buf_goods                  for ub.goods      .
define buffer buf_global-state           for ub.global-state  .
define buffer buf_buyer-group            for ub.buyer-group  .
define buffer buf_turnover-group         for ub.turnover-group  .
define buffer buf_main-code              for ub.bar-code  .
define buffer buf_bar-code               for ub.bar-code  .
define buffer buf_pay-type               for ub.pay-type  .
define buffer buf_cash-pay               for ub.cash-pay  .
define variable to-day          as date      no-undo .
define variable v-base-rate0    as decimal   no-undo .
define variable v-base-scale0   as decimal   no-undo .
define variable v-exch-rate0    as decimal   no-undo .
define variable v-exch-scale0   as decimal   no-undo .
define variable v-base-rate     as decimal   no-undo .
define variable v-base-scale    as decimal   no-undo .
define variable v-exch-rate     as decimal   no-undo .
define variable v-exch-scale    as decimal   no-undo .
define variable v-host-code     as integer   no-undo .
define variable v-curr-abbr     as character no-undo .
define variable v-grp-name      as character no-undo .
define variable v-date-1        as date      no-undo .
define variable v-date-2        as date      no-undo .
define variable v-interv        as character no-undo .
define variable v-pay-name      as character no-undo .
define variable v-cli-oborot    as decimal   no-undo .
define variable v-trn-pay-code  as integer   no-undo .
define variable v-cash-pay-curr as integer   no-undo .
define variable v-cash-pay-code as integer   no-undo .
do
on error undo, return error return-value
:
find first buf_main-code no-lock where buf_main-code.b-code = p-main-b-code .
find first buf_goods no-lock where buf_goods.gds-code = buf_main-code.gds-code.
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ).
end.
if p-vid-pay <> "" then do:
   find first buf_pay-type no-lock where  buf_pay-type.obj-code = integer(p-vid-pay) no-error .
   if available buf_pay-type
      then v-trn-pay-code = buf_pay-type.obj-code.
      else v-trn-pay-code =  0.
end.
else v-trn-pay-code = 0 .
if p-cash-pay-type <> "" then do:
   find first buf_cash-pay no-lock where  recid(buf_cash-pay) = integer(p-cash-pay-type) no-error .
   if available buf_pay-type
      then
        assign
          v-cash-pay-curr = buf_cash-pay.curr-code
          v-cash-pay-code = buf_cash-pay.cdpay-code
        .
      else
        assign
          v-cash-pay-curr = 0
          v-cash-pay-code = 0
          .
end.
else
  assign
    v-cash-pay-curr = 0
    v-cash-pay-code = 0
    .
for each tt_price-all  : delete tt_price-all . end.
assign
  p-plt-id             = ?
  p-plt-db-num         = ?
  p-pdf-id             = ?
  p-pdf-db-num         = ?
  p-sale-price-base    = ?
  p-sale-price-rubl    = ?
  v-cli-oborot         = 0
.
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  to-day
  ,output v-base-rate0
  ,output v-base-scale0
  )  .
  v-cli-oborot-ALL  = 0 .
  for each buf_turnover-buyer-main no-lock  where
           buf_turnover-buyer-main.cli-type = p-cli-type  and
           buf_turnover-buyer-main.cli-code = p-cli-code
           :
           v-cli-oborot-ALL = v-cli-oborot-ALL + buf_turnover-buyer-main.sum-doc-rubl-itog .
  end.
for each buf_price-all no-lock where
         buf_price-all.obj-type = p-obj-type and
         buf_price-all.obj-code = p-obj-code and
         buf_price-all.gds-code = buf_goods.gds-code and
         buf_price-all.status_  = 'акт':U  and
       ( p-only-b-code = false   or
       ( buf_price-all.b-code = p-main-b-code or
         buf_price-all.b-code = p-b-code))    and
        ( p-only-b-code = true  or
          buf_price-all.b-code = p-b-code)
          and
          buf_price-all.fact-order-sys-from  <= p-fact-order  and
        ( buf_price-all.fact-order-sys-to = ? or
          buf_price-all.fact-order-sys-to    >= p-fact-order)
        :
         v-interv   = "" .
         v-grp-name = "" .
         v-pay-name = "" .
         if buf_price-all.fact-order = 0  and buf_price-all.plt-priority = 0  then next.
         if buf_price-all.bgr-id > 0 then do:
            find first buf_buyer-group no-lock where
                       buf_buyer-group.bgr-id     = buf_price-all.bgr-id  and
                       buf_buyer-group.bgr-db-num = buf_price-all.bgr-db-num  no-error .
            if available buf_buyer-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
               find first buf_buyer-in-buyer-group no-lock where
                          buf_buyer-in-buyer-group.stts         = 0 and
                          buf_buyer-in-buyer-group.bgr-id       = buf_buyer-group.bgr-id     and
                          buf_buyer-in-buyer-group.bgr-db-num   = buf_buyer-group.bgr-db-num  and
                          buf_buyer-in-buyer-group.bbg-obj-type = p-cli-type and
                          buf_buyer-in-buyer-group.bbg-obj-code = p-cli-code
                          no-error .
                          if not available buf_buyer-in-buyer-group then do:
                             v-grp-name = "".
                             next.
                          end.
                          v-grp-name = buf_buyer-group.name .
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.tog-id > 0 then do:
            find first buf_turnover-group no-lock where
                       buf_turnover-group.tog-id     = buf_price-all.tog-id      and
                       buf_turnover-group.tog-db-num = buf_price-all.tog-db-num  no-error .
            if available buf_turnover-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
                  v-cli-oborot = v-cli-oborot-all  .
                  find first buf1_tnv-in-turnover-group no-lock where
                             buf1_tnv-in-turnover-group.stts       =  0     and
                             buf1_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf1_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf1_tnv-in-turnover-group.ttg-summa  <=  v-cli-oborot no-error .
                  find first buf2_tnv-in-turnover-group no-lock where
                             buf2_tnv-in-turnover-group.stts       =  0     and
                             buf2_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf2_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf2_tnv-in-turnover-group.ttg-summa  >=  v-cli-oborot no-error .
                  if not (available buf1_tnv-in-turnover-group and
                          available buf2_tnv-in-turnover-group ) then do:
                          v-grp-name = "".
                          next .
                  end.
                  v-grp-name = buf_turnover-group.name.
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.plt-fix-cource-crc-base = true then
            assign
              v-base-rate  = buf_price-all.pdf-base-rate
              v-base-scale = buf_price-all.pdf-base-scale
            .
            else
            assign
              v-base-rate  = v-base-rate0
              v-base-scale = v-base-scale0
            .
         if buf_price-all.plt-fix-cource-crc-doc = true then
            assign
              v-exch-rate  = buf_price-all.pdf-exch-rate
              v-exch-scale = buf_price-all.pdf-exch-scale
            .
            else do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_price-all.curr-code
  ,input  to-day
  ,output v-exch-rate0
  ,output v-exch-scale0
  ,output v-curr-abbr
  )  .
            assign
              v-exch-rate  = v-exch-rate0
              v-exch-scale = v-exch-scale0
              .
           end.
           v-date-1 = date ( "" )  .
           if buf_price-all.fact-order-sys-from > 0 then do:
              if buf_price-all.start-sys-date <> ?   then  v-date-1 = buf_price-all.start-sys-date.
              if buf_price-all.start-shift-date <> ? then  v-date-1 = buf_price-all.start-shift-date.
              if buf_price-all.start-date <> ?       then  v-date-1 = buf_price-all.start-date.
           end.
           v-date-2 =  date ( "" )  .
           if buf_price-all.fact-order-sys-to > 0 then do:
              if buf_price-all.end-sys-date <> ?     then  v-date-2 = buf_price-all.end-sys-date.
              if buf_price-all.end-shift-date <> ?   then  v-date-2 = buf_price-all.end-shift-date.
              if buf_price-all.end-date <> ?         then  v-date-2 = buf_price-all.end-date.
           end.
           if buf_price-all.qnty-from <> ? then do :
              if not (
              ( p-qnty-doc  >= buf_price-all.qnty-from and buf_price-all.qnty-to = ? ) or
              ( p-qnty-doc  >= buf_price-all.qnty-from and p-qnty-doc <= buf_price-all.qnty-to and buf_price-all.qnty-to <> ?)
              ) then do:
                     v-interv = "".
                     next.
              end.
              v-interv = "К: " + string(buf_price-all.qnty-from) + " - " + ( if buf_price-all.qnty-to = ? then "и более" else string(buf_price-all.qnty-to)) .
           end.
           if buf_price-all.sum-from <> ? then do :
              if not (
              ( p-sum-doc  >= buf_price-all.sum-from and buf_price-all.sum-to = ? ) or
              ( p-sum-doc  >= buf_price-all.sum-from and p-sum-doc <= buf_price-all.sum-to and buf_price-all.sum-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "C: " +  string(buf_price-all.sum-from) + " - " + ( if buf_price-all.sum-to = ? then "и более" else string(buf_price-all.sum-to)) .
           end.
           if buf_price-all.turnover-from <> ? then do :
              if not (
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and buf_price-all.turnover-to = ? ) or
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and v-cli-oborot-ALL <= buf_price-all.turnover-to and buf_price-all.turnover-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "O: " +  string(buf_price-all.turnover-from) + " - " + ( if buf_price-all.turnover-to = ? then "и более" else string(buf_price-all.turnover-to)) .
           end.
           if buf_price-all.use-pay-type = 1 then do :
              if buf_price-all.pay-code <> v-trn-pay-code then do:
                 v-pay-name = "" .
                 next.
               end.
               v-pay-name = 'Оплата':U +  ":" + string(buf_price-all.pay-code) .
           end.
           if buf_price-all.use-cash-pay = 1 then do :
              if v-cash-pay-code <> 0 and  not ( buf_price-all.curr-pay-code = v-cash-pay-curr and
                                                 buf_price-all.cdpay-code    = v-cash-pay-code ) then do:
                v-pay-name = "" .
                next.
              end.
              v-pay-name = 'Касс.платеж':U + ":" + string(buf_price-all.cdpay-code) + "_" + string(buf_price-all.curr-pay-code).
           end.
          find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
          create tt_price-all .
          buffer-copy buf_price-all to tt_price-all
          assign
            tt_price-all.price-sale-rubl = buf_price-all.price-sale  * v-exch-rate / v-exch-scale
            tt_price-all.road-tax-rubl   = buf_price-all.road-tax    * v-exch-rate / v-exch-scale
            tt_price-all.excise-rubl     = buf_price-all.excise      * v-exch-rate / v-exch-scale
            tt_price-all.price-sale-base = tt_price-all.price-sale-rubl  / v-base-rate * v-base-scale
            tt_price-all.road-tax-base   = tt_price-all.road-tax-rubl    / v-base-rate * v-base-scale
            tt_price-all.excise-base     = tt_price-all.excise-rubl      / v-base-rate * v-base-scale
            tt_price-all.price-sale     = buf_price-all.price-sale
            tt_price-all.road-tax       = buf_price-all.road-tax
            tt_price-all.excise         = buf_price-all.excise
            tt_price-all.pdf-exch-rate   = v-exch-rate
            tt_price-all.pdf-exch-scale  = v-exch-scale
            tt_price-all.pdf-base-rate   = v-base-rate
            tt_price-all.pdf-base-scale  = v-base-scale
            tt_price-all.grp-name        = v-grp-name
            tt_price-all.date-1          = v-date-1
            tt_price-all.shift-1         = buf_price-all.start-shift-num
            tt_price-all.time-1          = buf_price-all.start-sys-time
            tt_price-all.date-2          = v-date-2
            tt_price-all.shift-2         = buf_price-all.end-shift-num
            tt_price-all.time-2          = buf_price-all.end-sys-time
            tt_price-all.interv-name     = v-interv
            tt_price-all.pay-name        = v-pay-name
            tt_price-all.unit-cli        = buf_bar-code.unit-cli
          .
end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = p-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = neos_price-all.price-sale-base
            p-sale-price-rubl  = neos_price-all.price-sale-rubl
            p-road-tax-base    = neos_price-all.road-tax-base
            p-road-tax-rubl    = neos_price-all.road-tax-rubl
            p-excise-base      = neos_price-all.excise-base
            p-excise-rubl      = neos_price-all.excise-rubl
            .
         end.
         else do:
              find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
              if error-status :error    then do:
                message "Не найден бар-код" p-b-code view-as alert-box error .
                return error return-value .
              end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
end.
end procedure.
procedure mpl-tpl-auto :
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-fact-order as decimal   no-undo .
define output parameter p-sale-price as decimal   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ) .
end.
assign
  p-pdf-id      = ?
  p-pdf-db-num  = ?
  p-sale-price  = ?
.
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods for ub.goods  .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
if error-status :error then return error return-value .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
if error-status :error then return error return-value .
define variable v-main-b-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
define buffer buf_price-all for ub.price-all  .
for each tt_price-all : delete tt_price-all. end.
    for each buf_price-all no-lock where
            buf_price-all.plt-id     = p-plt-id                 and
            buf_price-all.plt-db-num = p-plt-db-num             and
            buf_price-all.obj-type   = p-obj-type               and
            buf_price-all.obj-code   = p-obj-code               and
            buf_price-all.gds-code   = buf_goods.gds-code       and
          ( buf_price-all.b-code = v-main-b-code or
            buf_price-all.b-code = p-b-code)    and
            buf_price-all.status_    = 'акт':U         and
            buf_price-all.fact-order-sys-from  <= p-fact-order  and
          ( buf_price-all.fact-order-sys-to = ? or
            buf_price-all.fact-order-sys-to >=  p-fact-order)
            :
              create tt_price-all .
              buffer-copy buf_price-all to tt_price-all
              assign
                tt_price-all.price-sale  = buf_price-all.price-sale
              .
    end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = v-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = neos_price-all.price-sale
            .
         end.
         else do:
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        if error-status :error    then do:
           message "Не найден бар-код" p-b-code view-as alert-box error .
           return error return-value .
        end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
  end.
end procedure.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
def temp-table tt-wthlib-parts no-undo like ub.wth-parts.
Procedure wth-doc-close:
    define input parameter p-rec        as recid     no-undo .
    DEFINE BUFFER cur-wth-parts FOR ub.wth-parts.
  do
  on error undo, return error return-value
  :
    find first cur-wth-parts where recid(cur-wth-parts) = p-rec exclusive-lock no-wait no-error.
    if not available cur-wth-parts then return error substitute("Не найдена партия").
    CASE cur-wth-parts.ext-doc-type:
        WHEN 'ie':U or when 'rf':U or when 'ff':U
        OR WHEN 'fj':U
        THEN DO:
           RUN wth-parts-close(BUFFER cur-wth-parts, 'free-zone':U ).
        END.
        WHEN 'ee':U THEN DO:
            RUN wth-parts-close(BUFFER cur-wth-parts, 'cli-zone':U ).
        END.
        WHEN 'ps':U OR WHEN 'pz':U OR WHEN 'rp':U
          OR WHEN 'ip':U OR WHEN 'pc':U
          OR WHEN 'pj':U
           THEN DO:
            RUN wth-parts-close(BUFFER cur-wth-parts, 'put-zone':U ).
        END.
        WHEN 'df':U OR WHEN 'dp':U OR WHEN 'dc':U THEN DO:
          RUN wth-parts-close(BUFFER cur-wth-parts, 'out-zone':U ).
        end.
        when 'ep':U or when 'ef':U
        OR WHEN 'oj':U or when 'jj':U
        then .
        when 'xc':U then do:
          if cur-wth-parts.type = 'при':U then
               RUN wth-parts-close(BUFFER cur-wth-parts, 'put-zone':U ).
          else RUN wth-parts-close(BUFFER cur-wth-parts, 'cli-zone':U ).
        end.
        OTHERWISE DO:
            RETURN ERROR substitute("Неверный вызов процедуры закрытия: расш. тип = &1"
                                 , cur-wth-parts.ext-doc-type
                                    ).
        END.
    END CASE.
    RELEASE cur-wth-parts.
    END.
END.
PROCEDURE wth-parts-close:
    DEFINE PARAMETER BUFFER bfrom_wth-parts FOR ub.wth-parts.
    DEFINE INPUT PARAMETER p-zone AS CHAR NO-UNDO.
    define variable v-rec as recid.
    if bfrom_wth-parts.stts  = 1 then return.
       run str/wthpartp.p  ( INPUT     'ДОБАВЛЕНИЕ':U,
                  INPUT     bfrom_wth-parts.obj-type,
                  INPUT     bfrom_wth-parts.obj-code,
                  INPUT     bfrom_wth-parts.w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,
                  INPUT     p-zone,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo  ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code               ,
                  INPUT     bfrom_wth-parts.price-rubl    ,
                  INPUT     bfrom_wth-parts.price-base    ,
                  INPUT     bfrom_wth-parts.supp-type,
                  INPUT     bfrom_wth-parts.supp-code,
                  INPUT     bfrom_wth-parts.in-obj-type      ,
                  INPUT     bfrom_wth-parts.in-obj-code      ,
                  INPUT     bfrom_wth-parts.ext-doc-type,
                  INPUT     bfrom_wth-parts.gds-code,
                  INPUT     bfrom_wth-parts.stts               ,
                  INPUT     bfrom_wth-parts.beg-dt        ,
                  INPUT     bfrom_wth-parts.end-dt        ,
                  INPUT     bfrom_wth-parts.vat-pc        ,
                  INPUT     bfrom_wth-parts.cli-code,
                  INPUT     bfrom_wth-parts.cli-type,
                  INPUT     bfrom_wth-parts.out-obj-code,
                  INPUT     bfrom_wth-parts.out-obj-type,
                  INPUT     bfrom_wth-parts.sale-obj-code,
                  INPUT     bfrom_wth-parts.sale-obj-type,
                  INPUT     bfrom_wth-parts.out-code ,
                  INPUT  yes,
                  INPUT     '':U ,
                  INPUT-OUTPUT v-rec
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
END.
Procedure wth-doc-razrez:
    define input parameter p-rec as recid NO-UNDO.
    define input parameter p-doc-del AS log NO-UNDO.
    define variable v-mess AS CHAR NO-UNDO.
    define variable p-silent AS LOG INIT NO NO-UNDO.
    DEFINE BUFFER b-wth-parts FOR ub.wth-parts.
    DEFINE BUFFER buf_wth-parts FOR ub.wth-parts.
    DEFINE BUFFER cur-wth-parts FOR ub.wth-parts.
  do
  on error undo, return error return-value
  :
    FIND FIRST cur-wth-parts WHERE recid(cur-wth-parts) = p-rec
                              EXCLUSIVE-LOCK .
    IF AVAILABLE cur-wth-parts THEN DO:
        CASE cur-wth-parts.ext-doc-type:
            WHEN 'ie':U or when 'ip':U or when 'rp':U
            or when 'ff':U or when 'rf':U
            or when 'fj':U or when 'pj':U
            THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, "":U,p-doc-del) .
            END.
            WHEN 'ee':U or when 'ef':U or when 'jj':U
            THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'free-zone':U,p-doc-del) .
            END.
            WHEN 'ep':U or when 'oj':U THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'put-zone':U,p-doc-del) .
            END.
            WHEN 'pc':U THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'cli-zone':U,p-doc-del)  .
            END.
            WHEN 'dp':U THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'put-zone':U,p-doc-del)  .
            END.
            WHEN 'df':U THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'free-zone':U,p-doc-del)  .
            END.
            WHEN 'dc':U THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'cli-zone':U,p-doc-del)  .
            END.
            WHEN 'ps':U OR WHEN 'pz':U THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'cli-zone':U,p-doc-del).
            END.
            when 'xc':U then do:
              if cur-wth-parts.type = 'при':U then
                   RUN wth-parts-raz(BUFFER cur-wth-parts, 'cli-zone':U,p-doc-del ).
              else RUN wth-parts-raz(BUFFER cur-wth-parts,  'free-zone':U ,p-doc-del).
            end.
            OTHERWISE DO:
                RETURN ERROR substitute("Неверный вызов процедуры разрезервирования: расш. тип =  :&1&2&3"
                                     , cur-wth-parts.ext-doc-type
                                     , error-status:get-message(1)
                                     , return-value
                                     ).
            END.
        END CASE.
    END.
  END.
END.
PROCEDURE wth-parts-raz:
    DEFINE PARAMETER BUFFER bfrom_wth-parts FOR ub.wth-parts.
    DEFINE INPUT PARAMETER p-zone AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER p-doc-del AS log NO-UNDO.
    define variable v-mes as char no-undo.
    define variable v-rec as recid no-undo.
    DEFINE BUFFER buf_wth-parts FOR ub.wth-parts.
  do
  on error undo, return error return-value
  :
    v-mes = substitute('Код серии: &1-&2 Диапазон &3-&4'
                                   ,bfrom_wth-parts.ser-code
                                   ,bfrom_wth-parts.db-num
                                   ,bfrom_wth-parts.doc-rangeFrom
                                   ,bfrom_wth-parts.doc-rangeTo).
    IF lookup(bfrom_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) > 0 THEN DO:
        RETURN ERROR substitute("Нельзя удалять партии МЦ из зоны :&1&2&3&4&5"
                             , error-status:get-message(1)
                             , bfrom_wth-parts.out-code
                             , return-value
                             ,chr(10)
                             ,v-mes
                             ).
    END.
    v-rec = recid(bfrom_wth-parts).
    CASE bfrom_wth-parts.ext-doc-type:
        WHEN 'ie':U  or when 'fj':U or when  'pj':U THEN DO:
            delete bfrom_wth-parts NO-ERROR.
            if error-status:error then do:
              return error substitute("Ошибка при удалении записи партии МЦ:&1&2&3&2&4"
                                   , error-status:get-message(1)
                                   , chr(10)
                                   , return-value
                                   ,v-mes
                                   ).
            END.
        END.
        when 'rp':U or when 'rf':U then do:
          if p-doc-del then do:
            delete bfrom_wth-parts NO-ERROR.
            if error-status:error then do:
              return error substitute("Ошибка при удалении записи партии МЦ:&1&2&3&2&4"
                                   , error-status:get-message(1)
                                   , chr(10)
                                   , return-value
                                   ,v-mes
                                   ).
            END.
          end.
          else   RETURN ERROR 'Нельзя удалять партии документа внутреннего возврата.'  .
        end.
        when 'ip':U or when 'ff':U then do:
          if p-doc-del then do:
            delete bfrom_wth-parts NO-ERROR.
            if error-status:error then do:
              return error substitute("Ошибка при удалении записи партии МЦ:&1&2&3&2&4"
                                   , error-status:get-message(1)
                                   , chr(10)
                                   , return-value
                                   ,v-mes
                                   ).
            END.
          end.
          else do:
            run str/wthpartp.p  ( INPUT     'ИЗМЕНЕНИЕ':U,
                  INPUT     bfrom_wth-parts.obj-type,
                  INPUT     bfrom_wth-parts.obj-code,
                  INPUT     bfrom_wth-parts.w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,
                  INPUT     bfrom_wth-parts.out-code,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo   ,
                  INPUT     bfrom_wth-parts.doc-RangeFrom ,
                  INPUT     bfrom_wth-parts.doc-rangeTo  ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code ,
                  INPUT     bfrom_wth-parts.price-rubl    ,
                  INPUT     bfrom_wth-parts.price-base    ,
                  INPUT     bfrom_wth-parts.supp-type,
                  INPUT     bfrom_wth-parts.supp-code,
                  INPUT     bfrom_wth-parts.in-obj-type      ,
                  INPUT     bfrom_wth-parts.in-obj-code      ,
                  INPUT     bfrom_wth-parts.ext-doc-type,
                  INPUT     bfrom_wth-parts.gds-code,
                  INPUT     1            ,
                  INPUT     bfrom_wth-parts.beg-dt        ,
                  INPUT     bfrom_wth-parts.end-dt        ,
                  INPUT     bfrom_wth-parts.vat-pc        ,
                  INPUT     bfrom_wth-parts.cli-code,
                  INPUT     bfrom_wth-parts.cli-type,
                  INPUT     bfrom_wth-parts.out-obj-code,
                  INPUT     bfrom_wth-parts.out-obj-type,
                  INPUT     bfrom_wth-parts.sale-obj-code,
                  INPUT     bfrom_wth-parts.sale-obj-type,
                  INPUT     bfrom_wth-parts.doc-code ,
                  INPUT  yes,
                  INPUT     bfrom_wth-parts.type ,
                  INPUT-OUTPUT v-rec
                  ) no-error.
             if error-status:error then undo, return error return-value + chr(10) + error-status:get-message(1) .
          end.
        end.
        OTHERWISE DO:
         run str/wthpartp.p  ( INPUT     'ИЗМЕНЕНИЕ':U,
                  INPUT     bfrom_wth-parts.obj-type,
                  INPUT     bfrom_wth-parts.obj-code,
                  INPUT     bfrom_wth-parts.w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,
                  INPUT     p-zone,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo   ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo  ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code ,
                  INPUT     bfrom_wth-parts.price-rubl    ,
                  INPUT     bfrom_wth-parts.price-base    ,
                  INPUT     bfrom_wth-parts.supp-type,
                  INPUT     bfrom_wth-parts.supp-code,
                  INPUT     bfrom_wth-parts.in-obj-type      ,
                  INPUT     bfrom_wth-parts.in-obj-code      ,
                  INPUT     bfrom_wth-parts.ext-doc-type,
                  INPUT     bfrom_wth-parts.gds-code,
                  INPUT     bfrom_wth-parts.stts             ,
                  INPUT     bfrom_wth-parts.beg-dt        ,
                  INPUT     bfrom_wth-parts.end-dt        ,
                  INPUT     bfrom_wth-parts.vat-pc        ,
                  INPUT     bfrom_wth-parts.cli-code,
                  INPUT     bfrom_wth-parts.cli-type,
                  INPUT     bfrom_wth-parts.out-obj-code,
                  INPUT     bfrom_wth-parts.out-obj-type,
                  INPUT     bfrom_wth-parts.sale-obj-code,
                  INPUT     bfrom_wth-parts.sale-obj-type,
                  INPUT     bfrom_wth-parts.doc-code ,
                  INPUT  yes,
                  INPUT      "":U ,
                  INPUT-OUTPUT v-rec
                  ) no-error.
    if error-status:error then undo, return error return-value + chr(10) + error-status:get-message(1) .
        END.
    END CASE.
  END.
END.
procedure wth-parts-rezerv:
    define input parameter        p-param            as logical no-undo.
    define input parameter        p-fact-rangeFrom   LIKE ub.wth-parts.Fact-RangeFrom no-undo .
    define input parameter        p-fact-RangeTo     LIKE ub.wth-parts.Fact-RangeTo no-undo   .
    define input parameter        p-beg-dt           LIKE ub.wth-parts.beg-dt no-undo .
    define input parameter        p-end-dt           LIKE ub.wth-parts.end-dt no-undo .
    define input parameter        p-ser-code         LIKE ub.wth-parts.ser-code no-undo.
    define input parameter        p-db-num           LIKE ub.wth-parts.db-num no-undo .
    define input parameter        p-price-rubl       LIKE ub.wth-parts.price-rubl no-undo .
    define input parameter        p-price-base       LIKE ub.wth-parts.price-base no-undo .
    define input parameter        p-vat-pc           LIKE ub.wth-parts.vat-pc no-undo .
    define input parameter        p-host-code        LIKE ub.wth-parts.host-code no-undo .
    define input parameter        p-obj-type         LIKE ub.wth-parts.obj-type no-undo .
    define input parameter        p-obj-code         LIKE ub.wth-parts.obj-code no-undo .
    define input parameter        p-w-p-code         LIKE ub.wth-parts.w-p-code no-undo .
    define input parameter        p-wth-code         LIKE ub.wth-parts.wth-code no-undo .
    define input parameter        p-par-code         LIKE ub.wth-parts.par-code no-undo .
    define input parameter        p-in-code          LIKE ub.wth-parts.in-code no-undo .
    define input parameter        p-doc-code         LIKE ub.wth-parts.out-code no-undo .
    define input parameter        p-cli-type         LIKE ub.wth-parts.cli-type no-undo .
    define input parameter        p-cli-code         LIKE ub.wth-parts.cli-code no-undo .
    define input parameter        p-ext-doc-type     LIKE ub.wth-parts.ext-doc-type no-undo .
    define input parameter        p-gds-code         LIKE ub.wth-parts.gds-code no-undo .
    define input parameter        p-type             LIKE ub.wth-parts.type no-undo .
    define input-output parameter p-rec        as recid     no-undo .
  define buffer bfrom_wth-parts   for ub.wth-parts.
  define buffer bufr_wth-doc      for ub.wth-doc.
  define variable v-rec    as recid        no-undo.
  define variable v-recDop as recid        no-undo.
  define variable v-zone   as character    no-undo.
  DEFINE variable v-beg-dt           LIKE ub.wth-parts.beg-dt no-undo .
  define VARIABLE v-end-dt           LIKE ub.wth-parts.end-dt no-undo .
  define variable v-price-rubl       LIKE ub.wth-parts.price-rubl no-undo .
  define variable v-price-base       LIKE ub.wth-parts.price-base no-undo .
  define variable v-vat-pc           LIKE ub.wth-parts.vat-pc no-undo .
  define variable v-mpl-date         as date      no-undo.
  empty temp-table tt-wthlib-parts.
main-block:
do  transaction
on error  undo main-block, return error return-value + chr(32) + error-status:get-message(1)
on stop   undo main-block, return error
on endkey undo main-block, return error
:
FIND FIRST bufr_wth-doc WHERE bufr_wth-doc.doc-code = p-doc-code NO-LOCK NO-ERROR.
IF NOT AVAILABLE bufr_wth-doc THEN RETURN ERROR SUBSTITUTE('Не найден документ МЦ с номером &1',p-doc-code).
  if lookup(p-ext-doc-type,'ie,ip,rp,fj,pj,ff,rf':U) > 0
        then do:
     run str/wthpartp.p  ( INPUT 'ДОБАВЛЕНИЕ':U,
                  INPUT  p-obj-type,
                  INPUT  p-obj-code,
                  INPUT  p-w-p-code,
                  INPUT  p-wth-code,
                  INPUT  p-par-code,
                  INPUT  p-in-code,
                  INPUT  p-doc-code,
                  INPUT  p-ser-code,
                  INPUT  p-db-num  ,
                  INPUT  p-Fact-RangeFrom ,
                  INPUT  p-fact-rangeTo  ,
                  INPUT  p-Fact-RangeFrom ,
                  INPUT  p-fact-rangeTo ,
                  INPUT  p-host-code     ,
                  INPUT  0   ,
                  INPUT  p-price-rubl    ,
                  INPUT  p-price-base    ,
                  INPUT  '':U,
                  INPUT  0,
                  INPUT  p-obj-type      ,
                  INPUT  p-obj-code      ,
                  INPUT  p-ext-doc-type,
                  INPUT  p-gds-code,
                  INPUT  0           ,
                  INPUT  p-beg-dt        ,
                  INPUT  p-end-dt        ,
                  INPUT  p-vat-pc      ,
                  INPUT  0,
                  INPUT  '':U,
                  INPUT  0,
                  INPUT  '':U,
                  INPUT  0,
                  INPUT  '':U,
                  INPUT  p-doc-code,
                  INPUT  yes,
                  INPUT p-type,
                  INPUT-OUTPUT p-rec
                  ) no-error.
                if error-status:error then undo main-block, return error return-value + error-status:get-message(1) .
  end.
  else do:
    if p-rec <> ? then do:
      find first bfrom_wth-parts exclusive-lock where
                recid(bfrom_wth-parts) = p-rec no-error.
      if  available bfrom_wth-parts
        and bfrom_wth-parts.wth-code = p-wth-code
        and bfrom_wth-parts.par-code = p-par-code
        and bfrom_wth-parts.ser-code = p-ser-code
        and lookup(bfrom_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) > 0
      then.
      else if  available bfrom_wth-parts and lookup(bfrom_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0
      then return error substitute('Резервирование из партии (Код серии: &1-&2 Диапазон &3-&4) невозможно, т.к. партия уже входит в состав документа'
                                   ,bfrom_wth-parts.ser-code
                                   ,bfrom_wth-parts.db-num
                                   ,bfrom_wth-parts.doc-rangeFrom
                                   ,bfrom_wth-parts.doc-rangeTo).
      else if  available bfrom_wth-parts then undo, return error 'Партия указанная для резервирования не соответсвует указанным параметрам!'.
      if available bfrom_wth-parts
         and bfrom_wth-parts.doc-rangeFrom > p-fact-rangeFrom
         or bfrom_wth-parts.doc-rangeTo   < p-fact-rangeTo
      then undo, return error substitute('Нельзя увеличивать границы диапазона.&1Диапазон партии &2-&3.&1Диапазон резервирования &4-&5'
                                         ,chr(10)
                                         ,bfrom_wth-parts.doc-rangeFrom
                                         ,bfrom_wth-parts.doc-rangeTo
                                         ,p-fact-rangeFrom
                                         ,p-fact-rangeTo).
    end.
    else do:
      if p-ext-doc-type = 'pz':U or (p-ext-doc-type = 'xc':U and p-type = 'при':U )then do:
        for first bfrom_wth-parts no-lock where
                                  bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = 'cli-zone':U
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              and bfrom_wth-parts.cli-code = p-cli-code
                              and bfrom_wth-parts.cli-type = p-cli-type
                              and (IF p-in-code > '':U then bfrom_wth-parts.in-code = p-in-code else true)
                              use-index  wth-idnt:
                              p-rec = recid(bfrom_wth-parts).
         end.
        If p-rec = ? and p-in-code > '' then do:
           for first bfrom_wth-parts no-lock where
                                  bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = 'cli-zone':U
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              and bfrom_wth-parts.cli-code = p-cli-code
                              and bfrom_wth-parts.cli-type = p-cli-type
                              use-index  wth-idnt:
                              p-rec = recid(bfrom_wth-parts).
              end.
        end.
              if p-rec <> ? then  find first bfrom_wth-parts no-lock where
                recid(bfrom_wth-parts) = p-rec no-error.
      end.
      else if p-ext-doc-type = 'pc':U or p-ext-doc-type = 'ps':U or p-ext-doc-type = 'dc':U then do:
        for first bfrom_wth-parts no-lock where bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = 'cli-zone':U
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              and (IF p-in-code > '':U then bfrom_wth-parts.in-code = p-in-code else true)
                              use-index wth-idnt:
                              p-rec = recid(bfrom_wth-parts).
         end.
        If p-rec = ? and p-in-code > '' then do:
         for first bfrom_wth-parts no-lock where bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = 'cli-zone':U
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              :
                              p-rec = recid(bfrom_wth-parts).
         end.
        end.
        if p-rec <> ? then  find first bfrom_wth-parts no-lock where
                recid(bfrom_wth-parts) = p-rec no-error.
      end.
      else do:
        CASE p-ext-doc-type:
                WHEN 'ee':U or when 'xc':U or WHEN 'ef':U
                or when 'jj':U THEN DO:
                    v-zone = 'free-zone':U.
                END.
                WHEN 'ep':U or when 'oj':U THEN DO:
                    v-zone = 'put-zone':U.
                END.
                WHEN 'df':U THEN DO:
                    v-zone = 'free-zone':U.
                END.
                WHEN 'dp':U  THEN DO:
                    v-zone = 'put-zone':U.
                END.
                WHEN 'pc':U OR WHEN 'ps':U OR WHEN 'pz':U OR WHEN 'dc':U THEN DO:
                    v-zone = 'cli-zone':U.
                END.
                OTHERWISE DO:
                    RETURN ERROR substitute("Неверный вызов процедуры резервирования: расш. тип = &1"
                                         , p-ext-doc-type
                                            ).
                END.
        END CASE.
        find first bfrom_wth-parts no-lock where
                                  bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.obj-code = p-obj-code
                              and bfrom_wth-parts.obj-type = p-obj-type
                              and bfrom_wth-parts.w-p-code = p-w-p-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = v-zone
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              and (IF p-in-code > '':U then bfrom_wth-parts.in-code = p-in-code else true)
                              no-error.
       If not available bfrom_wth-parts and p-in-code > '' then do:
               find first bfrom_wth-parts no-lock where
                                  bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.obj-code = p-obj-code
                              and bfrom_wth-parts.obj-type = p-obj-type
                              and bfrom_wth-parts.w-p-code = p-w-p-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = v-zone
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              no-error.
       end.
      end.
    end.
    if not available bfrom_wth-parts then do:
         if g#news then do:
          return error 'forged':U.
         end.
         else
          undo, return error substitute("Не найдена партия МЦ для резервирования &1Код МЦ &2&1Код номинала &3&1Код серии &4&1Диапазон с &5 по &6&1
                                        ",chr(10),p-wth-code,p-par-code,p-ser-code,p-fact-rangeFrom,
                                        p-fact-rangeTo).
    end.
    p-rec = recid(bfrom_wth-parts).
    find current bfrom_wth-parts exclusive-lock.
    create tt-wthlib-parts.
    buffer-copy bfrom_wth-parts to tt-wthlib-parts.
        ASSIGN v-beg-dt = if p-param then p-beg-dt else bfrom_wth-parts.beg-dt
               v-end-dt = if p-param then p-end-dt else bfrom_wth-parts.end-dt
               v-vat-pc = if p-param then p-vat-pc else bfrom_wth-parts.vat-pc
               v-price-rubl = if p-param then p-price-rubl else bfrom_wth-parts.price-rubl
               v-price-base = if p-param then p-price-base else bfrom_wth-parts.price-base  .
    IF  not g#news and (p-ext-doc-type = 'ee':U or p-ext-doc-type = 'xc':U)  THEN DO:
        IF v-beg-dt = ? AND v-end-dt = ? THEN DO:
            RUN init_prtdate ( INPUT p-obj-type
                                              ,INPUT p-obj-code
                                              ,INPUT p-ser-code
                                              ,INPUT p-db-num
                                              ,INPUT bufr_wth-doc.doc-date
                                              ,OUTPUT v-beg-dt
                                              ,OUTPUT v-end-dt ) NO-ERROR.
            if error-status:error then undo, return error return-value + error-status:get-message(1) .
        END.
        IF v-price-rubl = 0 AND v-price-base = 0 THEN DO:
          run set-wthmpl-date ( bufr_wth-doc.doc-code
                             ,bufr_wth-doc.doc-date
                             , v-beg-dt
                             , output v-mpl-date) no-error.
            RUN INIT_prtprice (
                          p-host-code
                        , p-obj-type
                        , p-obj-code
                        , p-cli-type
                        , p-cli-code
                        , p-wth-code
                        , p-gds-code
                        , p-par-code
                        , v-mpl-date
                        , OUTPUT  v-vat-pc
                        , OUTPUT  v-price-rubl
                        , OUTPUT  v-price-base
                ) NO-ERROR.
          if error-status:error then undo, return error return-value + error-status:get-message(1) .
        END.
    END.
      run str/wthpartp.p  ( INPUT     'ИЗМЕНЕНИЕ':U,
                  INPUT     p-obj-type,
                  INPUT     p-obj-code,
                  INPUT     p-w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,
                  INPUT     p-doc-code,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     p-Fact-RangeFrom ,
                  INPUT     p-fact-rangeTo  ,
                  INPUT     p-Fact-RangeFrom ,
                  INPUT     p-fact-rangeTo ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code               ,
                  INPUT     v-price-rubl ,
                  INPUT     v-price-base  ,
                  INPUT     bfrom_wth-parts.supp-type,
                  INPUT     bfrom_wth-parts.supp-code,
                  INPUT     bfrom_wth-parts.in-obj-type      ,
                  INPUT     bfrom_wth-parts.in-obj-code      ,
                  INPUT     p-ext-doc-type,
                  INPUT     bfrom_wth-parts.gds-code,
                  INPUT     0              ,
                  INPUT     v-beg-dt    ,
                  INPUT     v-end-dt   ,
                  INPUT     v-vat-pc    ,
                  INPUT     bfrom_wth-parts.cli-code,
                  INPUT     bfrom_wth-parts.cli-type,
                  INPUT     bfrom_wth-parts.out-obj-code,
                  INPUT     bfrom_wth-parts.out-obj-type,
                  INPUT     bfrom_wth-parts.sale-obj-code,
                  INPUT     bfrom_wth-parts.sale-obj-type,
                  INPUT     bfrom_wth-parts.doc-code,
                  INPUT     yes,
                  INPUT     p-type,
                  INPUT-OUTPUT p-rec
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
    if tt-wthlib-parts.fact-rangeFrom <> p-fact-rangeFrom then do:
    run str/wthpartp.p ( INPUT     'ДОБАВЛЕНИЕ':U,
                  INPUT     tt-wthlib-parts.obj-type,
                  INPUT     tt-wthlib-parts.obj-code,
                  INPUT     tt-wthlib-parts.w-p-code,
                  INPUT     tt-wthlib-parts.wth-code,
                  INPUT     tt-wthlib-parts.par-code,
                  INPUT     tt-wthlib-parts.in-code ,
                  INPUT     tt-wthlib-parts.out-code,
                  INPUT     tt-wthlib-parts.ser-code,
                  INPUT     tt-wthlib-parts.db-num  ,
                  INPUT     tt-wthlib-parts.Fact-RangeFrom ,
                  INPUT     p-fact-rangeFrom - 1  ,
                  INPUT     tt-wthlib-parts.Fact-RangeFrom ,
                  INPUT     p-fact-rangeFrom - 1,
                  INPUT     tt-wthlib-parts.host-code     ,
                  INPUT     tt-wthlib-parts.contract-code               ,
                  INPUT     tt-wthlib-parts.price-rubl    ,
                  INPUT     tt-wthlib-parts.price-base    ,
                  INPUT     tt-wthlib-parts.supp-type,
                  INPUT     tt-wthlib-parts.supp-code,
                  INPUT     tt-wthlib-parts.in-obj-type      ,
                  INPUT     tt-wthlib-parts.in-obj-code      ,
                  INPUT     tt-wthlib-parts.ext-doc-type,
                  INPUT     tt-wthlib-parts.gds-code,
                  INPUT     tt-wthlib-parts.stts               ,
                  INPUT     tt-wthlib-parts.beg-dt        ,
                  INPUT     tt-wthlib-parts.end-dt        ,
                  INPUT     tt-wthlib-parts.vat-pc        ,
                  INPUT     tt-wthlib-parts.cli-code,
                  INPUT     tt-wthlib-parts.cli-type,
                  INPUT     tt-wthlib-parts.out-obj-code,
                  INPUT     tt-wthlib-parts.out-obj-type,
                  INPUT     tt-wthlib-parts.sale-obj-code,
                  INPUT     tt-wthlib-parts.sale-obj-type,
                  INPUT     tt-wthlib-parts.doc-code,
                  INPUT  yes,
                  INPUT    tt-wthlib-parts.type,
                  INPUT-OUTPUT v-recDop
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
    end.
    if tt-wthlib-parts.fact-rangeTo <> p-fact-rangeTo then do:
            run str/wthpartp.p    ( INPUT 'ДОБАВЛЕНИЕ':U,
                  INPUT     tt-wthlib-parts.obj-type,
                  INPUT     tt-wthlib-parts.obj-code,
                  INPUT     tt-wthlib-parts.w-p-code,
                  INPUT     tt-wthlib-parts.wth-code,
                  INPUT     tt-wthlib-parts.par-code,
                  INPUT     tt-wthlib-parts.in-code ,
                  INPUT     tt-wthlib-parts.out-code,
                  INPUT     tt-wthlib-parts.ser-code,
                  INPUT     tt-wthlib-parts.db-num  ,
                  INPUT     p-fact-rangeTo + 1 ,
                  INPUT     tt-wthlib-parts.fact-rangeTo  ,
                  INPUT     p-fact-rangeTo + 1 ,
                  INPUT     tt-wthlib-parts.fact-rangeTo,
                  INPUT     tt-wthlib-parts.host-code     ,
                  INPUT     tt-wthlib-parts.contract-code               ,
                  INPUT     tt-wthlib-parts.price-rubl    ,
                  INPUT     tt-wthlib-parts.price-base    ,
                  INPUT     tt-wthlib-parts.supp-type,
                  INPUT     tt-wthlib-parts.supp-code,
                  INPUT     tt-wthlib-parts.in-obj-type      ,
                  INPUT     tt-wthlib-parts.in-obj-code      ,
                  INPUT     tt-wthlib-parts.ext-doc-type,
                  INPUT     tt-wthlib-parts.gds-code,
                  INPUT     tt-wthlib-parts.stts               ,
                  INPUT     tt-wthlib-parts.beg-dt        ,
                  INPUT     tt-wthlib-parts.end-dt        ,
                  INPUT     tt-wthlib-parts.vat-pc        ,
                  INPUT     tt-wthlib-parts.cli-code,
                  INPUT     tt-wthlib-parts.cli-type,
                  INPUT     tt-wthlib-parts.out-obj-code,
                  INPUT     tt-wthlib-parts.out-obj-type,
                  INPUT     tt-wthlib-parts.sale-obj-code,
                  INPUT     tt-wthlib-parts.sale-obj-type,
                  INPUT     tt-wthlib-parts.doc-code,
                  INPUT     yes,
                  INPUT     tt-wthlib-parts.type,
                  INPUT-OUTPUT v-recDop
                  ) no-error.
      if error-status:error then undo, return error return-value + error-status:get-message(1) .
    end.
  end.
end.
end procedure.
procedure wth-parts-inter-edit:
  define input parameter        p-fact-rangeFrom   LIKE ub.wth-parts.Fact-RangeFrom no-undo .
  define input parameter        p-fact-RangeTo     LIKE ub.wth-parts.Fact-RangeTo no-undo   .
  define input-output parameter p-rec        as recid     no-undo .
  define buffer bfrom_wth-parts   for ub.wth-parts.
  define variable v-recDop as recid        no-undo.
  do on error undo, return error:
      find first bfrom_wth-parts exclusive-lock where
                recid(bfrom_wth-parts) = p-rec no-error.
      if not available bfrom_wth-parts then return error
        substitute('Не найдена партия (recid &1)', p-rec).
      if p-fact-rangeFrom < bfrom_wth-parts.doc-rangeFrom or
         p-fact-rangeTo > bfrom_wth-parts.doc-rangeTo then do:
         return error 'Нельзя увеличивать границы диапазона.'.
      end.
      empty temp-table tt-wthlib-parts.
      create tt-wthlib-parts.
      buffer-copy bfrom_wth-parts to tt-wthlib-parts.
      run str/wthpartp.p  ( INPUT     'ИЗМЕНЕНИЕ':U,
                  INPUT     bfrom_wth-parts.obj-type,
                  INPUT     bfrom_wth-parts.obj-code,
                  INPUT     bfrom_wth-parts.w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,
                  INPUT     bfrom_wth-parts.doc-code,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     p-Fact-RangeFrom ,
                  INPUT     p-fact-rangeTo  ,
                  INPUT     p-Fact-RangeFrom ,
                  INPUT     p-fact-rangeTo ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code               ,
                  INPUT     bfrom_wth-parts.price-rubl  ,
                  INPUT     bfrom_wth-parts.price-base    ,
                  INPUT     bfrom_wth-parts.supp-type,
                  INPUT     bfrom_wth-parts.supp-code,
                  INPUT     bfrom_wth-parts.in-obj-type      ,
                  INPUT     bfrom_wth-parts.in-obj-code      ,
                  INPUT     bfrom_wth-parts.ext-doc-type,
                  INPUT     bfrom_wth-parts.gds-code,
                  INPUT     0              ,
                  INPUT     bfrom_wth-parts.beg-dt      ,
                  INPUT     bfrom_wth-parts.end-dt      ,
                  INPUT     bfrom_wth-parts.vat-pc      ,
                  INPUT     bfrom_wth-parts.cli-code,
                  INPUT     bfrom_wth-parts.cli-type,
                  INPUT     bfrom_wth-parts.out-obj-code,
                  INPUT     bfrom_wth-parts.out-obj-type,
                  INPUT     bfrom_wth-parts.sale-obj-code,
                  INPUT     bfrom_wth-parts.sale-obj-type,
                  INPUT     bfrom_wth-parts.doc-code,
                  INPUT     yes,
                  INPUT     bfrom_wth-parts.type,
                  INPUT-OUTPUT p-rec
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
    if tt-wthlib-parts.fact-rangeFrom <> p-fact-rangeFrom then do:
    run str/wthpartp.p ( INPUT     'ДОБАВЛЕНИЕ':U,
                  INPUT     tt-wthlib-parts.obj-type,
                  INPUT     tt-wthlib-parts.obj-code,
                  INPUT     tt-wthlib-parts.w-p-code,
                  INPUT     tt-wthlib-parts.wth-code,
                  INPUT     tt-wthlib-parts.par-code,
                  INPUT     tt-wthlib-parts.in-code ,
                  INPUT     tt-wthlib-parts.out-code,
                  INPUT     tt-wthlib-parts.ser-code,
                  INPUT     tt-wthlib-parts.db-num  ,
                  INPUT     tt-wthlib-parts.Fact-RangeFrom ,
                  INPUT     p-fact-rangeFrom - 1  ,
                  INPUT     tt-wthlib-parts.Fact-RangeFrom ,
                  INPUT     p-fact-rangeFrom - 1,
                  INPUT     tt-wthlib-parts.host-code     ,
                  INPUT     tt-wthlib-parts.contract-code               ,
                  INPUT     tt-wthlib-parts.price-rubl    ,
                  INPUT     tt-wthlib-parts.price-base    ,
                  INPUT     tt-wthlib-parts.supp-type,
                  INPUT     tt-wthlib-parts.supp-code,
                  INPUT     tt-wthlib-parts.in-obj-type      ,
                  INPUT     tt-wthlib-parts.in-obj-code      ,
                  INPUT     tt-wthlib-parts.ext-doc-type,
                  INPUT     tt-wthlib-parts.gds-code,
                  INPUT     1             ,
                  INPUT     tt-wthlib-parts.beg-dt        ,
                  INPUT     tt-wthlib-parts.end-dt        ,
                  INPUT     tt-wthlib-parts.vat-pc        ,
                  INPUT     tt-wthlib-parts.cli-code,
                  INPUT     tt-wthlib-parts.cli-type,
                  INPUT     tt-wthlib-parts.out-obj-code,
                  INPUT     tt-wthlib-parts.out-obj-type,
                  INPUT     tt-wthlib-parts.sale-obj-code,
                  INPUT     tt-wthlib-parts.sale-obj-type,
                  INPUT     tt-wthlib-parts.doc-code,
                  INPUT  yes,
                  INPUT    tt-wthlib-parts.type,
                  INPUT-OUTPUT v-recDop
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
    end.
    if tt-wthlib-parts.fact-rangeTo <> p-fact-rangeTo then do:
            run str/wthpartp.p    ( INPUT 'ДОБАВЛЕНИЕ':U,
                  INPUT     tt-wthlib-parts.obj-type,
                  INPUT     tt-wthlib-parts.obj-code,
                  INPUT     tt-wthlib-parts.w-p-code,
                  INPUT     tt-wthlib-parts.wth-code,
                  INPUT     tt-wthlib-parts.par-code,
                  INPUT     tt-wthlib-parts.in-code ,
                  INPUT     tt-wthlib-parts.out-code,
                  INPUT     tt-wthlib-parts.ser-code,
                  INPUT     tt-wthlib-parts.db-num  ,
                  INPUT     p-fact-rangeTo + 1 ,
                  INPUT     tt-wthlib-parts.fact-rangeTo  ,
                  INPUT     p-fact-rangeTo + 1 ,
                  INPUT     tt-wthlib-parts.fact-rangeTo,
                  INPUT     tt-wthlib-parts.host-code     ,
                  INPUT     tt-wthlib-parts.contract-code               ,
                  INPUT     tt-wthlib-parts.price-rubl    ,
                  INPUT     tt-wthlib-parts.price-base    ,
                  INPUT     tt-wthlib-parts.supp-type,
                  INPUT     tt-wthlib-parts.supp-code,
                  INPUT     tt-wthlib-parts.in-obj-type      ,
                  INPUT     tt-wthlib-parts.in-obj-code      ,
                  INPUT     tt-wthlib-parts.ext-doc-type,
                  INPUT     tt-wthlib-parts.gds-code,
                  INPUT     1             ,
                  INPUT     tt-wthlib-parts.beg-dt        ,
                  INPUT     tt-wthlib-parts.end-dt        ,
                  INPUT     tt-wthlib-parts.vat-pc        ,
                  INPUT     tt-wthlib-parts.cli-code,
                  INPUT     tt-wthlib-parts.cli-type,
                  INPUT     tt-wthlib-parts.out-obj-code,
                  INPUT     tt-wthlib-parts.out-obj-type,
                  INPUT     tt-wthlib-parts.sale-obj-code,
                  INPUT     tt-wthlib-parts.sale-obj-type,
                  INPUT     tt-wthlib-parts.doc-code,
                  INPUT     yes,
                  INPUT     tt-wthlib-parts.type,
                  INPUT-OUTPUT v-recDop
                  ) no-error.
      if error-status:error then undo, return error return-value + error-status:get-message(1) .
      end.
  end.
end procedure.
PROCEDURE INIT_prtdate:
    define input parameter        p-obj-type         LIKE ub.wth-parts.obj-type no-undo .
    define input parameter        p-obj-code         LIKE ub.wth-parts.obj-code no-undo .
    define input parameter        p-ser-code         LIKE ub.wth-parts.ser-code no-undo.
    define input parameter        p-db-num           LIKE ub.wth-parts.db-num no-undo .
    define input parameter        p-date                AS DATE no-undo .
    DEFINE OUTPUT PARAMETER p-beg-dt AS DATE NO-UNDO.
    DEFINE OUTPUT PARAMETER p-end-dt AS DATE NO-UNDO.
    DEFINE BUFFER buf_wth-ser FOR ub.wth-ser.
    DEFINE VARIABLE v-rangeRule AS INT NO-UNDO.
    define variable v-value-character as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-param-type as character no-undo .
    FIND FIRST buf_wth-ser NO-LOCK
        WHERE buf_wth-ser.ser-code = p-ser-code
        AND buf_wth-ser.db-num = p-db-num.
    IF buf_wth-ser.chk-bdt = 2 THEN DO:
        p-beg-dt = buf_wth-ser.beg-dt.
    END.
    IF buf_wth-ser.chk-edt = 2 THEN DO:
        p-end-dt = buf_wth-ser.end-dt.
    END.
    IF buf_wth-ser.chk-bdt = 0 AND buf_wth-ser.chk-edt = 0 THEN DO:
        run adm/shattri.p (
            input "get":U
            ,input  p-obj-type
            ,input  p-obj-code
            ,input  'wthdoc_obj':U
            ,input  'rangerule':U
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-value-logical
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error .
        IF not error-status:error  then do:
            v-rangeRule =  v-value-integer.
        END.
        CASE v-rangeRule:
        WHEN 1 THEN DO:
            IF MONTH(p-date) < 11 THEN ASSIGN p-beg-dt = DATE(substitute('01/&1/&2',MONTH(p-date) + 1,YEAR(p-date)))
                                              p-end-dt = DATE(substitute('01/&1/&2',MONTH(p-date) + 2,YEAR(p-date))) - 1.
            ELSE IF MONTH(p-date) = 11 THEN ASSIGN p-beg-dt = DATE(substitute('01/12/&1',YEAR(p-date)))
                                              p-end-dt = DATE(substitute('31/12/&1',YEAR(p-date) + 1)).
            ELSE IF MONTH(p-date) = 12 THEN ASSIGN p-beg-dt = DATE(substitute('01/01/&1',YEAR(p-date) + 1))
                                              p-end-dt = DATE(substitute('31/01/&1',YEAR(p-date) + 1)).
        END.
        when 2 then do:
          IF MONTH(p-date) = 12 THEN ASSIGN p-beg-dt = DATE(substitute('&1/12/&2',day(p-date),YEAR(p-date)))
                                            p-end-dt = DATE(substitute('31/12/&1',YEAR(p-date))).
          else ASSIGN p-beg-dt = DATE(substitute('&3/&1/&2',MONTH(p-date),YEAR(p-date),day(p-date)))
                      p-end-dt = DATE(substitute('01/&1/&2',MONTH(p-date) + 1,YEAR(p-date))) - 1
                     .
        end.
        WHEN 3 THEN DO:
            IF MONTH(p-date) < 10 THEN ASSIGN p-beg-dt = DATE(substitute('&1/&2/&3',day(p-date),MONTH(p-date),YEAR(p-date)))
                                              p-end-dt = DATE(substitute('01/&1/&2',MONTH(p-date) + 3,YEAR(p-date))) - 1.
            else if MONTH(p-date) = 10 THEN ASSIGN p-beg-dt = DATE(substitute('&1/10/&2',day(p-date),YEAR(p-date)))
                                            p-end-dt = DATE(substitute('31/12/&1',YEAR(p-date))).
            else if MONTH(p-date) = 11 THEN ASSIGN p-beg-dt = DATE(substitute('&1/11/&2',day(p-date),YEAR(p-date)))
                                            p-end-dt = DATE(substitute('31/01/&1',YEAR(p-date) + 1)).
            else if MONTH(p-date) = 12 THEN ASSIGN p-beg-dt = DATE(substitute('&1/12/&2',day(p-date),YEAR(p-date)))
                                            p-end-dt = DATE(substitute('01/03/&1',YEAR(p-date) + 1)) - 1.
        END.
        when 4 then do:
             p-beg-dt = p-date.
             p-end-dt = date(substitute('31/12/&1',YEAR(p-date))).
        end.
        END CASE.
    END.
END.
PROCEDURE INIT_prtprice:
define input parameter        p-host-code        LIKE ub.wth-parts.obj-type no-undo .
define input parameter        p-obj-type         LIKE ub.wth-parts.obj-type no-undo .
define input parameter        p-obj-code         LIKE ub.wth-parts.obj-code no-undo .
define input parameter        p-cli-type         LIKE ub.wth-parts.cli-type no-undo .
define input parameter        p-cli-code         LIKE ub.wth-parts.cli-code no-undo .
define input parameter        p-wth-code         LIKE ub.wth-parts.ser-code no-undo.
define input parameter        p-gds-code         LIKE ub.wth-parts.gds-code no-undo .
define input parameter        p-par-code         LIKE ub.wth-parts.par-code no-undo .
define input parameter        p-date                AS DATE no-undo .
DEFINE OUTPUT PARAMETER p-vat-pc LIKE ub.wth-parts.vat-pc NO-UNDO.
DEFINE OUTPUT PARAMETER p-price-rubl LIKE ub.wth-parts.price-rubl NO-UNDO.
DEFINE OUTPUT PARAMETER p-price-base LIKE ub.wth-parts.price-base NO-UNDO.
DEFINE BUFFER b-cash-pay FOR ub.cash-pay.
DEFINE BUFFER b-wth-par FOR ub.wth-par.
DEF VAR v-cash-type-pay AS CHAR no-undo.
define variable p-plt-id AS INT no-undo.
define variable  p-plt-db-num   AS INT no-undo.
define variable  p-pdf-id  AS INT no-undo.
define variable  p-pdf-db-num AS INT no-undo.
define variable  p-sale-price-base AS DEC no-undo.
define variable  p-sale-price-rubl AS DEC no-undo.
define variable  p-road-tax-base AS DEC no-undo.
define variable  p-road-tax-rubl AS DEC no-undo.
define variable  p-excise-base AS DEC no-undo.
define variable  p-excise-rubl AS DEC no-undo.
define variable  p-fact-order  AS DEC no-undo.
do on error undo, return error return-value :
  FIND FIRST b-wth-par NO-LOCK WHERE b-wth-par.par-code = p-par-code
                                  AND b-wth-par.wth-code = p-wth-code NO-ERROR.
  IF NOT AVAILABLE b-wth-par THEN RETURN ERROR SUBSTITUTE("Не наден номинал с кодом &1",p-par-code).
  FIND FIRST b-cash-pay WHERE b-cash-pay.wth-code = p-wth-code NO-LOCK NO-ERROR.
  IF AVAILABLE b-cash-pay THEN v-cash-type-pay = STRING(recid(b-cash-pay)).
  ELSE v-cash-type-pay = ?.
  run fact-order-mpl (
      INPUT p-date ,
      INPUT p-obj-type ,
      INPUT p-obj-code ,
      OUTPUT p-fact-order
      ) no-error .
  if error-status:error then do:
    message   return-value skip error-status:get-message(1)
    skip  'Получение цены из множественного прайс-листа отклонено.'
    view-as alert-box.
    return.
  end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output p-vat-pc
  ) no-error .
  run mpl-autoprice in this-procedure
    ( input    false
      ,input   p-cli-type
      ,input   p-cli-code
      ,input   p-gds-code
      ,input   p-gds-code
      ,input   p-obj-type
      ,input   p-obj-code
      ,input   0
      ,input   0
      ,input   ""
      ,input   v-cash-type-pay
      ,input   p-fact-order
      ,output  p-plt-id
      ,output  p-plt-db-num
      ,output  p-pdf-id
      ,output  p-pdf-db-num
      ,output  p-sale-price-base
      ,output  p-sale-price-rubl
      ,output  p-road-tax-base
      ,output  p-road-tax-rubl
      ,output  p-excise-base
      ,output  p-excise-rubl
      ) no-error .
  if error-status:error then do:
    message   return-value skip error-status:get-message(1) view-as alert-box.
    return.
  end.
  p-price-rubl = p-sale-price-rubl * b-wth-par.par-val.
  p-price-base = p-sale-price-base * b-wth-par.par-val.
end.
END.
procedure  set-wthmpl-date:
define input parameter p-doc-code like ub.wth-doc.doc-code no-undo.
define input parameter p-doc-date like ub.wth-doc.doc-date no-undo.
define input parameter p-beg-dt   like ub.wth-parts.beg-dt no-undo.
define output parameter p-date    like ub.wth-doc.doc-date no-undo.
define variable v-atrValue      as character no-undo .
define variable v-atrDsf      as CHARACTER no-undo .
define variable v-atrType     as character no-undo .
do on error undo, return error return-value :
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input p-doc-code ,
                        input 'wthdsf':U ,
                       output v-atrValue ,
                       output v-atrType )  .
  p-date = date(v-atrValue) no-error.
  if p-date = ? then p-date = p-beg-dt no-error.
  if p-date = ? then p-date = p-doc-date.
end.
end procedure.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable filter-label as character no-undo init "Материальные_ценности" .
define variable filter-label0 as character no-undo init "Материальные_ценности" .
define variable filter-point0 as character no-undo init "Парти_МЦ" .
define variable filter-point as character no-undo init "Парти_МЦ" .
define variable sort-column-name as character no-undo .
define variable v-prt-rec  as recid no-undo .
DEFINE VARIABLE v-out-name AS CHAR NO-UNDO format 'x(12)':U.
define variable rid-list   as character no-undo .
define variable v-SerDb    as character    no-undo.
define variable v-SerName  as character    no-undo.
DEFINE VARIABLE v-w-p-name AS CHAR NO-UNDO .
define variable v-obj-name as char no-undo.
DEFINE BUFFER b-wth-doc   FOR ub.wth-doc.
DEFINE BUFFER b-wealth    FOR ub.wealth.
DEFINE BUFFER b-wth-par   FOR ub.wth-par.
DEFINE BUFFER b-goods     FOR ub.goods.
DEFINE BUFFER b-wth-ser   for ub.wth-ser.
DEFINE BUFFER buf_wth-ser for ub.wth-ser.
DEFINE BUFFER X_wth-parts FOR ub.wth-parts.
DEFINE BUFFER b-clients   FOR ub.clients.
define buffer buf_wth-place   for ub.wth-place.
DEFINE BUFFER b-wth-parts FOR ub.wth-parts.
FUNCTION get-cli-name RETURNS CHARACTER
  ( f-cli-type AS CHAR, f-cli-code as int  )  FORWARD.
FUNCTION get-ser-name RETURNS CHARACTER
  ( pfser-code AS INT, pfser-db AS INT )  FORWARD.
FUNCTION get-w-p-name RETURNS CHARACTER
  ( vf-w-p-code AS int ,vf-obj-type as char, vf-obj-code as int )  FORWARD.
FUNCTION get-wthparts-out-code RETURNS CHARACTER
  ( vf-out-code AS CHAR )  FORWARD.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-cancel-mark
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Снять все выделения".
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-doc-code
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "Документ"
     SIZE 3 BY 1 TOOLTIP "Документ, породивший партию".
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 4 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3.5 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1 TOOLTIP "Выделить".
DEFINE BUTTON B-mark-all
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выделить все партии".
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 4 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 4.5 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE VARIABLE bar-str AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE fl-doc-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Документ"
     VIEW-AS FILL-IN
     SIZE 10 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-doc-date AS DATE FORMAT "99/99/99":U
     LABEL "от"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-doc-ext-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 44 BY 1 NO-UNDO.
DEFINE VARIABLE fl-gds AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 17.5 BY 1 NO-UNDO.
DEFINE VARIABLE fl-par-price AS CHARACTER FORMAT "X(256)":U
     LABEL "Цена"
     VIEW-AS FILL-IN
     SIZE 8.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-par-val AS CHARACTER FORMAT "X(256)":U
     LABEL "Номинал"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE fl-wth-name AS CHARACTER FORMAT "X(256)":U
     LABEL "МЦ"
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.
DEFINE VARIABLE Fn-rs-obj AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE text-sts AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rsfl-ch AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 0
     SIZE 83.5 BY .75 NO-UNDO.
DEFINE VARIABLE rsfl-obj AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущий объект", 1,
"Все объекты", 2
     SIZE 47.5 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 1.5.
DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 1.5.
DEFINE QUERY br-parts FOR
      X_wth-parts SCROLLING.
DEFINE BROWSE br-parts
  QUERY br-parts NO-LOCK DISPLAY
      mark-string( recid(X_wth-parts), rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
      get-ser-name(X_wth-parts.ser-code,X_wth-parts.db-num) @ v-serName COLUMN-LABEL "Серия"  FORMAT "X(10)":U
      X_wth-parts.fact-rangeFrom  COLUMN-LABEL "Диапазон с" FORMAT "->>>>>>>>9":U
      X_wth-parts.fact-rangeTo  COLUMN-LABEL "по" FORMAT "->>>>>>>>9":U
      X_wth-parts.fact-qnty  FORMAT "->,>>>,>>9":U  COLUMN-LABEL "Колич." WIDTH 8
      get-cli-name(X_wth-parts.obj-type,X_wth-parts.obj-code ) @ v-obj-name   COLUMN-LABEL "Объект"     FORMAT "X(26)":U
      get-w-p-name(X_wth-parts.w-p-code, X_wth-parts.obj-type,X_wth-parts.obj-code) @ v-w-p-name COLUMN-LABEL "МХ"  FORMAT "X(12)":U
      get-wthparts-out-code(X_wth-parts.out-code) @ v-out-name COLUMN-LABEL "Документ\зона"
      X_wth-parts.in-code COLUMN-LABEL "Док. порожд." FORMAT "X(10)":U
      X_wth-parts.price-rubl FORMAT "->>>,>>9.99":U   COLUMN-LABEL "Цена талона"
      X_wth-parts.beg-dt   COLUMN-LABEL "Срок годн. с" format "99/99/99"
      X_wth-parts.end-dt   COLUMN-LABEL "Срок годн. по"  format "99/99/99"
      get-cli-name(X_wth-parts.sale-obj-type,X_wth-parts.sale-obj-code )  COLUMN-LABEL "Объект реализ."   FORMAT "X(14)":U
      get-cli-name(X_wth-parts.cli-type,X_wth-parts.cli-code )   COLUMN-LABEL "Покупатель"     FORMAT "X(14)":U
      get-cli-name(X_wth-parts.out-obj-type,X_wth-parts.out-obj-code )   COLUMN-LABEL "Объект погаш."   FORMAT "X(14)":U
      X_wth-parts.fact-date FORMAT "99/99/99":U  COLUMN-LABEL "Факт. дата"
      X_wth-parts.shift-date FORMAT "99/99/99":U
      X_wth-parts.shift-num FORMAT ">9":U
      get-cli-name(X_wth-parts.in-obj-type,X_wth-parts.out-obj-code )  COLUMN-LABEL "Объект нач. приобрет."   FORMAT "X(14)":U
      get-cli-name(X_wth-parts.supp-type,X_wth-parts.supp-code )    COLUMN-LABEL "Поставщик"    FORMAT "X(14)":U
      X_wth-parts.doc-code COLUMN-LABEL "Документ"
      X_wth-parts.doc-rangeFrom FORMAT "->,>>>,>>>,>>9":U  column-label 'Диапазон с (док.)'
      X_wth-parts.doc-rangeTo FORMAT "->,>>>,>>>,>>9":U    column-label 'Диапазон по (док.)'
      X_wth-parts.qnty-doc FORMAT "->>>,>>>,>>9":U   column-label 'Кол-во (док.)'
      X_wth-parts.price-base FORMAT "->>,>>>,>>9.99":U
      X_wth-parts.VAT-pc FORMAT ">9.9<%":U
      X_wth-parts.host-code COLUMN-LABEL "Код фирмы" FORMAT ">>>>>>>>9":U
      ENTRY(LOOKUP(X_wth-parts.ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u) FORMAT "X(18)":U   column-label 'Расш. тип'
      X_wth-parts.fact-num FORMAT "->,>>>,>>9":U
      X_wth-parts.fact-order FORMAT "9999999999999999999999.9999999999":U
      X_wth-parts.wth-code
      X_wth-parts.par-code
      substitute('&1-&2',X_wth-parts.ser-code,X_wth-parts.db-num) @ v-SerDb COLUMN-LABEL "Код серии"
      X_wth-parts.stts FORMAT ">9":U
      X_wth-parts.TYPE
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 12.25
         FONT 2 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 18
     b-quit AT ROW 1 COL 11 WIDGET-ID 20
     B-mark AT ROW 1 COL 21 WIDGET-ID 12
     B-mark-all AT ROW 1 COL 24 WIDGET-ID 316
     B-cancel-mark AT ROW 1 COL 27 WIDGET-ID 318
     B-sel AT ROW 1 COL 30 WIDGET-ID 16
     b-lkp AT ROW 1 COL 40 WIDGET-ID 22
     B-add AT ROW 1 COL 50 WIDGET-ID 2
     B-chg AT ROW 1 COL 60 WIDGET-ID 4
     B-del AT ROW 1 COL 70 WIDGET-ID 6
     B-sch AT ROW 1 COL 82 WIDGET-ID 60
     B-print AT ROW 1 COL 86.5 WIDGET-ID 14
     B-hist AT ROW 1 COL 90.5 WIDGET-ID 10
     B-Help AT ROW 1 COL 94 WIDGET-ID 8
     rsfl-ch AT ROW 2.25 COL 11 NO-LABEL WIDGET-ID 62
     rsfl-obj AT ROW 3 COL 11 NO-LABEL WIDGET-ID 292
     br-parts AT ROW 4 COL 1 WIDGET-ID 200
     bar-str AT ROW 16.38 COL 16.5 COLON-ALIGNED NO-LABEL WIDGET-ID 320
     fl-wth-name AT ROW 17.75 COL 4.5 COLON-ALIGNED WIDGET-ID 50
     fl-par-val AT ROW 17.75 COL 40 COLON-ALIGNED WIDGET-ID 52
     fl-gds AT ROW 17.75 COL 57 COLON-ALIGNED WIDGET-ID 58
     fl-par-price AT ROW 17.75 COL 82 COLON-ALIGNED WIDGET-ID 326
     b-doc-code AT ROW 19.25 COL 2.5 WIDGET-ID 308
     fl-doc-code AT ROW 19.25 COL 14.5 COLON-ALIGNED WIDGET-ID 304
     fl-doc-date AT ROW 19.25 COL 29 COLON-ALIGNED WIDGET-ID 324
     fl-doc-ext-type AT ROW 19.25 COL 42.5 COLON-ALIGNED NO-LABEL WIDGET-ID 302
     text-sts AT ROW 2.25 COL 1.13 COLON-ALIGNED NO-LABEL WIDGET-ID 314
     Fn-rs-obj AT ROW 3.17 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 312
     "Штрих-код:" VIEW-AS TEXT
          SIZE 10.5 BY .67 AT ROW 16.58 COL 6.63 WIDGET-ID 328
          FGCOLOR 4
     RECT-1 AT ROW 17.5 COL 1 WIDGET-ID 300
     RECT-8 AT ROW 19 COL 1 WIDGET-ID 310
     SPACE(0.00) SKIP(0.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Партии серийных МЦ" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-doc-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       fl-doc-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fl-doc-ext-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       rsfl-ch:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
define variable glog as logical  no-undo .
if not available b-wth-doc then return.
run proc-add in this-procedure.
RUn OpenBr in this-procedure .
apply "entry" to BR-parts in frame Dialog-Frame.
return no-apply.
END.
ON CHOOSE OF B-cancel-mark IN FRAME Dialog-Frame
DO:
 rid-list = ''.
 br-parts:refresh() no-error.
 apply "entry" to br-parts in frame Dialog-Frame.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
If not available X_wth-parts then return.
rep-rec = recid(X_wth-parts).
run str/wthpartl.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,INPUT 'ИЗМЕНЕНИЕ':U
                ,INPUT p-w-p-code
                ,INPUT X_wth-parts.wth-code
                ,INPUT X_wth-parts.par-code
                ,INPUT X_wth-parts.in-code
                ,INPUT p-wth-doc
                ,INPUT X_wth-parts.ser-code
                ,INPUT X_wth-parts.db-num
                ,INPUT X_wth-parts.fact-rangeFrom
                ,INPUT X_wth-parts.fact-rangeTo
                ,INPUT p-type
                ,input-output rep-rec).
if rep-rec <> ? then do:
  v-prt-rec = rep-rec.
  RUn OpenBr in this-procedure .
  apply "entry" to BR-parts in frame Dialog-Frame.
end.
else do:
  apply "entry" to BR-parts in frame Dialog-Frame.
  return no-apply.
end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
 define variable del-rec as recid no-undo.
 define variable glog     as logical no-undo .
 define variable rep-rec as recid no-undo .
 define buffer buf_wth-ser for ub.wth-ser.
 if not available X_wth-parts then do:
   message "Неправильно выбрана строка.".
   return no-apply.
 end.
 run proc-del in this-procedure.
    RUn OpenBr in this-procedure .
    apply "entry" to BR-parts in frame Dialog-Frame.
END.
ON CHOOSE OF b-doc-code IN FRAME Dialog-Frame
DO:
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run show-doc-code in this-procedure .
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
   if p-coll-point <> 'document':U then run save-position in this-procedure.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
rep-rec = recid(X_wth-parts).
        run str/wthpartl.w (
                         input parparentproc
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,INPUT 'ПРОСМОТР':U
                        ,INPUT X_wth-parts.w-p-code
                        ,INPUT X_wth-parts.wth-code
                        ,INPUT X_wth-parts.par-code
                        ,INPUT X_wth-parts.in-code
                        ,INPUT X_wth-parts.out-code
                        ,INPUT X_wth-parts.ser-code
                        ,INPUT X_wth-parts.db-num
                        ,INPUT X_wth-parts.fact-rangeFrom
                        ,INPUT X_wth-parts.fact-rangeTo
                        ,INPUT   X_wth-parts.type
                        ,input-output rep-rec).
if rep-rec <> ? then do:
  v-prt-rec = rep-rec.
  RUn OpenBr in this-procedure .
  apply "entry" to BR-parts in frame Dialog-Frame.
end.
else do:
  apply "entry" to BR-parts in frame Dialog-Frame.
  return no-apply.
end.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
 define variable glog as logical no-undo .
   if available X_wth-parts then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid31 as character no-undo .
define variable v-num-entry31 as integer   no-undo .
assign
  v-str-recid31 = trim( string( recid( X_wth-parts ) , "->>>>>>>>>>>9":U ) )
  v-num-entry31 = lookup( v-str-recid31 , rid-list )
.
if v-num-entry31 > 0 then do:
  assign
    entry( v-num-entry31, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid31
  .
end.
     br-parts:refresh().
     if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
             glog = br-parts:select-next-row ().
             apply "iteration-changed" to br-parts in frame Dialog-Frame.
         end.
   end.
   apply "entry" to br-parts in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark-all IN FRAME Dialog-Frame
DO:
 define variable glog as logical no-undo .
 GET FIRST br-parts NO-LOCK.
 rid-list = ''.
 selectBlock:
 DO WHILE not QUERY-OFF-END("br-parts":U)  :
   if available X_wth-parts then do on error undo, leave selectBlock :
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid33 as character no-undo .
define variable v-num-entry33 as integer   no-undo .
assign
  v-str-recid33 = trim( string( recid( X_wth-parts ) , "->>>>>>>>>>>9":U ) )
  v-num-entry33 = lookup( v-str-recid33 , rid-list )
.
if v-num-entry33 > 0 then do:
  assign
    entry( v-num-entry33, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid33
  .
end.
   end.
   get next br-parts no-lock.
 END.
 br-parts:refresh() no-error.
 apply "entry" to br-parts in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
 define variable doc-rec as recid no-undo .
     doc-rec = recid( X_wth-parts ).
   run PrintProc in this-procedure no-error.
   reposition br-parts to recid doc-rec no-error.
   apply "entry" to br-parts in frame Dialog-Frame.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
if p-coll-point <> 'document':U then run save-position in this-procedure.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  assign
  tbl = 'wth-parts'
  join-tbl = 'X_wth-parts'
  dim = '0':U
  fld = '':U
  lab = '':U
  spr = '':U
  .
  run fltfield-add in this-procedure('wth-code', 'Код МЦ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ser-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('gds-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-rangeFrom', 'Диапазон с', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-rangeTo', 'Диапазон по', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('w-p-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('in-code', 'Номер порожд. док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('doc-code', 'Номер док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-code', 'Номер договора', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cli-type*cli-code', 'Покупатель', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-type*supp-code', 'Поставщик', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sale-obj-type*sale-obj-code', 'Объект реализации', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-obj-type*out-obj-code', 'Объект погашения', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('type', 'Тип док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ext-doc-type', 'Расш. тип док-та', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('beg-dt', 'Дата начала срока годности', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-dt', 'Дата конца срока годности', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('shift-date', 'Дата смены', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    DO on stop undo, leave:
        run gbl/filter.w ( input parparentproc
                         , input filter-point
                         , input tbl
                         , input join-tbl
                         , input  fld
                         , input lab
                         , input spr
                         , input dim).
        RUN OpenBr in this-procedure .
    END .
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
    if  available X_wth-parts AND (rid-list = ""  or
        b-mark:sensitive = no)
    then
    rid-list = string( recid( X_wth-parts ) ) .
END.
ON RETURN OF bar-str IN FRAME Dialog-Frame
DO:
define variable v-ser-code  as integer      no-undo.
define variable v-db-num    as integer      no-undo.
define variable v-stts      as integer      no-undo.
define variable v-wth-code  as integer      no-undo.
define variable v-gds-code  as integer      no-undo.
define variable v-par-code  as integer      no-undo.
define variable v-zone      as character    no-undo.
define variable v-fromDate  as date         no-undo.
define variable v-ToDate    as date         no-undo.
define variable v-rangeNum  as integer      no-undo.
define variable parline-rec    as recid     no-undo.
define variable parparts-rec    as recid    no-undo.
define variable v-start-rec as integer      no-undo.
define variable v-qstrnum as int no-undo.
define variable v-cur-recX as recid no-undo.
assign frame Dialog-Frame bar-str .
if not available x_wth-parts then return.
  run str/wthidnt.p ( input bar-str
          ,output v-ser-code
          ,output v-db-num
          ,output v-stts
          ,output v-wth-code
          ,output v-gds-code
          ,output v-par-code
          ,output v-zone
          ,output v-FromDate
          ,output v-ToDate
          ,output v-rangeNum
          ) no-error.
if error-status:error then do:
   message error-status:get-message(1) + chr(32) + return-value.
   undo, return .
end.
apply 'entry':U to br-parts.
v-cur-recX =  recid(x_wth-parts).
  get next br-parts .
  findBlock: do:
    do while available x_wth-parts and v-cur-recX  <>  recid(x_wth-parts):
        if  x_wth-parts.ser-code =  v-ser-code
        and x_wth-parts.db-num   =  v-db-num
        and x_wth-parts.wth-code =  v-wth-code
        and x_wth-parts.gds-code =  v-gds-code
        and x_wth-parts.par-code =  v-par-code
        and x_wth-parts.fact-RangeFrom <= v-rangeNum
        and x_wth-parts.fact-RangeTo >= v-rangeNum
        then do:
         if not available x_wth-parts then message '2' view-as alert-box.
            reposition br-parts to recid  recid(x_wth-parts).
            leave findBlock.
        end.
       get next br-parts.
       if not available x_wth-parts then get first br-parts.
    end.
    if p-coll-point =   'document'  then
    message substitute( "В данном списке нет талона с указанным штрих-кодом: &1", bar-str ) view-as alert-box warning.
  end.
apply 'entry':U to br-parts.
bar-str:screen-value = '':U.
return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK, return OF br-parts IN FRAME Dialog-Frame
DO:
    IF b-chg:SENSITIVE THEN APPLY "choose":U TO b-chg.
  ELSE APPLY "choose":U TO b-lkp.
END.
ON ROW-DISPLAY OF br-parts IN FRAME Dialog-Frame
DO:
def var v-font as integer no-undo init ?.
if available X_wth-parts then do:
  IF X_wth-parts.in-code = 'фальшивый':U and lookup(X_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) > 0 THEN
  v-font = 12.
  if  lookup(X_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0  then
  v-font = 7.
  ASSIGN v-SerDb:FGCOLOR IN BROWSE br-parts = v-font
       X_wth-parts.fact-rangeFrom:FGCOLOR IN BROWSE br-parts = v-font
       X_wth-parts.fact-rangeTo:FGCOLOR IN BROWSE br-parts = v-font
       X_wth-parts.fact-qnty:FGCOLOR IN BROWSE br-parts = v-font
       X_wth-parts.in-code:FGCOLOR IN BROWSE br-parts = v-font
       v-out-name:FGCOLOR IN BROWSE br-parts = v-font
       v-obj-name:FGCOLOR IN BROWSE br-parts = v-font
       v-w-p-name:FGCOLOR IN BROWSE br-parts = v-font
       v-serName :FGCOLOR IN BROWSE br-parts = v-font.
  if X_wth-parts.stts = 1 then do:
       X_wth-parts.fact-rangeFrom:screen-value IN BROWSE br-parts = '?'.
       X_wth-parts.fact-rangeTo:screen-value IN BROWSE br-parts = '?'.
       X_wth-parts.fact-qnty:screen-value IN BROWSE br-parts = '0'.
  end.
end.
END.
ON VALUE-CHANGED OF br-parts IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_wth-parts THEN DO WITH FRAME Dialog-Frame:
      FIND FIRST b-wealth WHERE b-wealth.wth-code = X_wth-parts.wth-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wealth THEN DISP b-wealth.wth-name @ fl-wth-name.
      ELSE fl-wth-name:SCREEN-VALUE = '?':U.
      FIND FIRST b-wth-par WHERE b-wth-par.wth-code =  X_wth-parts.wth-code AND b-wth-par.par-code = X_wth-parts.par-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wth-par THEN do:
          DISP SUBSTITUTE("&1 &2",b-wth-par.par-val,b-wth-par.par-unit) @ fl-par-val
                         (if X_wth-parts.price-rubl > 0 then  trim(string(X_wth-parts.price-rubl / b-wth-par.par-val,"->>>,>9.99")) else '':U)  @ fl-par-price.
      END.
      ELSE fl-par-val:SCREEN-VALUE = '?':U.
      FIND FIRST b-goods WHERE b-goods.gds-code = X_wth-parts.gds-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-goods THEN DO:
                                disp  b-goods.gds-name  @ fl-gds.
      END.
      ELSE   ASSIGN fl-gds:SCREEN-VALUE = '?':U.
      ENABLE b-lkp
             b-del WHEN p-coll-point = 'document':U AND p-edit-mode = 'ИЗМЕНЕНИЕ':U
             b-chg WHEN p-coll-point = 'document':U AND p-edit-mode = 'ИЗМЕНЕНИЕ':U.
      if lookup(X_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) > 0 then do:
               display  X_wth-parts.doc-code @ fl-doc-code
                        X_wth-parts.fact-date @ fl-doc-date
                     ENTRY(LOOKUP(X_wth-parts.ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u) @ fl-doc-ext-type
            .
      end.
      else do:
         display  X_wth-parts.out-code @ fl-doc-code
                  X_wth-parts.fact-date @ fl-doc-date
                  ENTRY(LOOKUP(X_wth-parts.ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u) @ fl-doc-ext-type
          no-error .
      end.
      if X_wth-parts.stts = 1 and p-edit-mode <> 'ПРОСМОТР':U then do:
        b-del:label = 'Восстанов'.
      end.
      else b-del:label = 'Удалить'.
  END.
  ELSE DO:
      DISABLE b-lkp b-chg b-del WITH FRAME Dialog-Frame.
  END.
END.
ON VALUE-CHANGED OF rsfl-ch IN FRAME Dialog-Frame
DO:
  if self:screen-value = '2' then do:
    hide rsfl-obj Fn-rs-obj in frame Dialog-Frame  .
    v-w-p-name:visible in browse br-parts = no.
    v-out-name:visible in browse br-parts = no.
    X_wth-parts.in-code:visible in browse br-parts = no.
  end.
  else do:
    if p-coll-point <> 'document' then view rsfl-obj Fn-rs-obj in frame Dialog-Frame  .
    v-w-p-name:visible in browse br-parts = yes.
    v-out-name:visible in browse br-parts = yes.
    X_wth-parts.in-code:visible in browse br-parts = yes.
  end.
    RUn OpenBr in this-procedure .
END.
ON VALUE-CHANGED OF rsfl-obj IN FRAME Dialog-Frame
DO:
    RUn OpenBr in this-procedure .
END.
 on "ANY-PRINTABLE":U of br-parts anywhere  do:
    bar-str:screen-value = bar-str:screen-value + last-event:label.
    apply "entry" to bar-str in frame Dialog-Frame.
    apply "end" to bar-str in frame Dialog-Frame.
 end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-parts :handle
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
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-parts :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
CASE p-coll-point:
    WHEN 'Номинал МЦ':U or when 'Серии МЦ':U or when 'Место хранения МЦ':U THEN DO:
      if p-edit-mode = 'ДОБАВЛЕНИЕ':U or  p-edit-mode = 'ИЗМЕНЕНИЕ':U then do:
        message vss-workfile vss-revision vss-description skip
        substitute('Неверные параметры вызова (p-coll-point = "&2",p-edit-mode = "&3" ). Возможен только режим &1.','ПРОСМОТР':U,p-coll-point, p-edit-mode)
        view-as alert-box ERROR.
        return.
      end.
    END.
    WHEN "document":U THEN DO:
    END.
    OTHERWISE DO:
        message vss-workfile vss-revision vss-description skip
        "Неверный вызов - p-coll-point=" p-coll-point
        view-as alert-box ERROR.
        return.
    END.
END CASE.
if p-edit-mode = 'ИЗМЕНЕНИЕ':U or p-edit-mode = 'ДОБАВЛЕНИЕ':U
then do:
  TRANSACTION-MAIN-BLOCK:
  DO TRANSACTION
  ON ERROR   UNDO TRANSACTION-MAIN-BLOCK, LEAVE TRANSACTION-MAIN-BLOCK
  ON END-KEY UNDO TRANSACTION-MAIN-BLOCK, LEAVE TRANSACTION-MAIN-BLOCK
  :
    run main-block-procedure no-error .
    if error-status :error
    then do:
        undo, return error .
    end.
  END.
end.
ELSE if p-edit-mode = 'ПРОСМОТР':U THEN do:
  MAIN-BLOCK:
  DO
  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  :
   run main-block-procedure no-error .
    if error-status :error
    then do:
      LEAVE MAIN-BLOCK .
    end.
  END.
end.
else do:
      message vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова - p-edit-mode=" p-edit-mode
      view-as alert-box error.
      return.
end.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rsfl-ch rsfl-obj bar-str fl-wth-name fl-par-val fl-gds fl-par-price
          fl-doc-code fl-doc-date fl-doc-ext-type text-sts Fn-rs-obj
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-mark B-mark-all B-cancel-mark B-sel b-lkp B-add B-chg
         B-del B-sch B-print B-hist B-Help RECT-1 RECT-8 rsfl-obj br-parts
         bar-str fl-wth-name fl-par-val fl-par-price fl-doc-code fl-doc-date
         fl-doc-ext-type text-sts Fn-rs-obj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-parts FOR EACH X_wth-parts NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE load-position :
define variable v-current-zone-string      as character    no-undo.
define variable v-current-obj-string       as character    no-undo.
define variable v-void-logical              as logical      no-undo.
define variable v-void-character            as character    no-undo.
define variable v-found                     as logical      no-undo.
do   with frame Dialog-Frame
on error undo, return error
:
    run uf-get (
         input 'wthps-zone':U
        , input v-cntxt-userid
        , output v-current-zone-string
        , output v-void-character
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
    ) no-error.
    if not error-status :error  then rsfl-ch:screen-value =  v-current-zone-string.
    run uf-get (
          input 'wthparts-obj':U
        , input v-cntxt-userid
        , output v-current-obj-string
        , output v-void-character
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
    ) no-error.
    if not error-status :error  then rsfl-obj:screen-value =  v-current-obj-string.
 end.
END PROCEDURE.
PROCEDURE main-block-procedure :
if p-wth-code > 0 or p-coll-point = 'Номинал МЦ':U then do:
  find first b-wealth where b-wealth.wth-code = p-wth-code no-lock no-error.
  if not available b-wealth then do:
    message substitute("Не найдена МЦ с кодом &1!",p-wth-code)
    view-as alert-box error.
    return error.
  end.
end.
if p-par-code > 0 or p-coll-point = 'Номинал МЦ':U then do:
  find first b-wth-par where b-wth-par.wth-code = p-wth-code
                          and  b-wth-par.par-code = p-par-code
  no-lock no-error.
  if not available b-wth-par then do:
    message substitute("Не найден номинал МЦ. Код номинала: &1, Код МЦ: &2!",p-par-code, p-wth-code)
    view-as alert-box error.
    return error.
  end.
end.
if p-ser-code > 0 or p-coll-point = 'Серии МЦ':U then do:
  find first b-wth-ser where b-wth-ser.ser-code = p-ser-code
                           and b-wth-ser.db-num = p-db-num
  no-lock no-error.
  if not available b-wth-ser then do:
    message substitute("Не найдена серия МЦ. Код серии &1-&2!",p-ser-code, p-db-num)
    view-as alert-box error.
    return error.
  end.
end.
if p-coll-point = 'document':U then do:
  if p-edit-mode = 'ПРОСМОТР':U then
  FIND FIRST b-wth-doc WHERE b-wth-doc.doc-code = p-wth-doc NO-LOCK NO-ERROR.
  ELSE FIND FIRST b-wth-doc WHERE b-wth-doc.doc-code = p-wth-doc exclusive-lock NO-ERROR.
  if not available b-wth-doc then do:
    message substitute("Не найден документ с номером &1!",p-wth-doc)
    view-as alert-box error.
    return error.
  end.
end.
run MyEnable.
apply "value-changed":U to rsfl-ch in frame Dialog-Frame.
wait-for 'go' of frame    Dialog-Frame  .
END PROCEDURE.
PROCEDURE MyEnable :
br-parts:NUM-LOCKED-COLUMNS IN FRAME  Dialog-Frame  = 4 .
DEF VAR rs-list AS CHAR.
enable rsfl-obj with frame   Dialog-Frame.
rsfl-ch:DELETE("все") IN FRAME Dialog-Frame.
IF p-coll-point = 'document' THEN DO:
    FIND FIRST b-wth-doc WHERE b-wth-doc.doc-code = p-wth-doc NO-LOCK NO-ERROR.
    IF AVAILABLE b-wth-doc THEN do:
        CASE b-wth-doc.ext-doc-type:
            WHEN 'ie':U OR WHEN 'ip':U or when 'ff':U
            or WHEN 'rp':U or WHEN 'rf':U
            or when 'fj':U or when 'pj':U  THEN DO:
                rsfl-ch:ADD-LAST("Документ",0).
            END.
            WHEN 'ee':U or when 'ef':U or when 'jj':U THEN DO:
                rsfl-ch:ADD-LAST("Все",11).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Свободная зона ", 1).
            END.
            WHEN 'ep':U or when 'oj':U THEN DO:
                rsfl-ch:ADD-LAST("Все",13).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Зона погашения", 3).
            END.
            WHEN 'pc':U THEN DO:
                rsfl-ch:ADD-LAST("Все",12).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Зона покупателей", 2).
            END.
            WHEN 'ps':U OR WHEN 'pz':U OR WHEN 'dc':U THEN DO:
                rsfl-ch:ADD-LAST("Все",12).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Зона покупателей", 2).
            END.
            WHEN 'df':U THEN DO:
                rsfl-ch:ADD-LAST("Все",11).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Свободная. зона", 1).
            END.
            WHEN 'dp':U THEN DO:
                rsfl-ch:ADD-LAST("Все",13).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Зона погашения", 3).
            END.
            WHEN 'xc':U THEN DO:
              if p-type = 'при':U then do:
                rsfl-ch:ADD-LAST("Все",12).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Зона покупателей", 2).
              end.
              else do:
                rsfl-ch:ADD-LAST("Все",11).
                rsfl-ch:ADD-LAST("Документ",0).
                rsfl-ch:ADD-LAST("Свободная зона", 1).
              end.
            END.
            OTHERWISE DO:
                MESSAGE substitute("Неверный вызов - ext-doc-type =  :&1&2&3"
                                     , b-wth-doc.ext-doc-type
                                     , error-status:get-message(1)
                                     , return-value
                                   ) VIEW-AS ALERT-BOX ERROR.
                RETURN ERROR.
            END.
        END CASE.
        if b-wth-doc.doc-type = 'при':U and b-wth-doc.exter_ =  no then do:
          br-parts:MOVE-COLUMN(14,6).
          br-parts:MOVE-COLUMN(15,7).
          br-parts:MOVE-COLUMN(16,8).
        end.
    END.
END.
ELSE if p-coll-point = 'Место хранения МЦ':U THEN DO:
    rsfl-ch:ADD-LAST("Все", 0).
    rsfl-ch:ADD-LAST("Свободная зона", 1).
    rsfl-ch:ADD-LAST("Зона погашения", 3).
    rsfl-ch:ADD-LAST("Зона уничтожения", 4).
    view b-doc-code in frame  Dialog-Frame.
    hide rsfl-obj
         Fn-rs-obj in frame  Dialog-Frame.
END.
ELSE DO:
    rsfl-ch:ADD-LAST("Все", 0).
    rsfl-ch:ADD-LAST("Свободная зона", 1).
    rsfl-ch:ADD-LAST("Зона покупателей", 2).
    rsfl-ch:ADD-LAST("Зона погашения", 3).
    rsfl-ch:ADD-LAST("Зона уничтожения", 4).
    view b-doc-code in frame  Dialog-Frame.
END.
ENABLE b-exit when not p-edit-mode = 'ПРОСМОТР':U or p-coll-point ne 'document':U
    b-quit when  p-coll-point = 'document':U
    rsfl-ch
    b-lkp
    br-parts
    b-sch
    b-hist
    b-print
    b-help
    bar-str
    text-sts
    b-mark when p-coll-point = 'document':U and p-edit-mode  <> 'ПРОСМОТР':U
    b-mark-all when p-coll-point = 'document':U and p-edit-mode  <> 'ПРОСМОТР':U
    B-cancel-mark  when p-coll-point = 'document':U and p-edit-mode  <> 'ПРОСМОТР':U
    b-add WHEN p-coll-point = 'document':U AND p-edit-mode <> 'ПРОСМОТР':U and not( b-wth-doc.exter_ = no and  b-wth-doc.doc-type = 'при':U)
    b-chg WHEN p-coll-point = 'document':U AND p-edit-mode = 'ИЗМЕНЕНИЕ':U
    b-del WHEN p-coll-point = 'document':U AND p-edit-mode = 'ИЗМЕНЕНИЕ':U
    b-doc-code  WHEN  not p-coll-point = 'document':U
    rsfl-obj when p-coll-point <> 'Место хранения МЦ':U
WITH FRAME Dialog-Frame.
text-sts:screen-value = 'Статус:'.
if p-coll-point = 'document':U then do:
    disable rsfl-ch when p-edit-mode = 'ПРОСМОТР':U
            rsfl-obj
    with frame Dialog-Frame.
    rsfl-ch:row = 2.7.
    text-sts:row = 2.7.
    text-sts:move-to-top().
    hide rsfl-obj in frame  Dialog-Frame.
    if p-edit-mode = 'ПРОСМОТР':U then  do:
      b-quit:label = 'Выход'.
      rsfl-ch:screen-value = '0'.
    end.
end.
else do:
  run load-position in this-procedure.
  Fn-rs-obj:screen-value = 'Объект:'.
  b-exit:label = 'Выход'.
end.
END PROCEDURE.
PROCEDURE OpenBr :
define variable l-query-was-opened as logical no-undo .
DEF VAR rsfl-par  AS INT.
DEF VAR zone-list AS CHAR.
DEFINE VARIABLE cur-wth-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE cur-par-val AS INTEGER NO-UNDO.
DEFINE VARIABLE cur-par-unit AS CHARACTER NO-UNDO.
DEFINE VARIABLE cur-ser-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE cur-wth-ext-doc-type AS character NO-UNDO.
DEFINE VARIABLE cur-wth-ext-doc-type-text AS character NO-UNDO.
DEFINE VARIABLE cur-wth-doc-code AS CHARACTER NO-UNDO.
zone-list = SUBSTITUTE('&1,&2,&3,&4','free-zone':U,'cli-zone':U,'put-zone':U,'out-zone':U).
ASSIGN FRAME Dialog-Frame rsfl-ch rsfl-obj.
rsfl-par =  rsfl-ch.
IF AVAILABLE b-wealth THEN cur-wth-name = b-wealth.wth-name.
ELSE cur-wth-name = '?':U.
IF AVAILABLE b-wth-par THEN assign cur-par-val  = b-wth-par.par-val
                                   cur-par-unit = b-wth-par.par-unit.
ELSE assign cur-par-val  = ?
            cur-par-unit = '':U.
IF AVAILABLE b-wth-doc THEN do:
    cur-wth-ext-doc-type = b-wth-doc.ext-doc-type.
    cur-wth-ext-doc-type-text = ENTRY (lookup(b-wth-doc.ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u).
    cur-wth-doc-code = b-wth-doc.doc-code.
END.
ELSE do:
    cur-wth-ext-doc-type = '?':U.
    cur-wth-doc-code = '?':U.
END.
if available b-wth-ser then  cur-ser-name = b-wth-ser.series.
run waitfram-show in this-procedure (  input "Ждите...").
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
CASE p-coll-point:
    when 'Номинал МЦ':U then do:
         ASSIGN frame Dialog-Frame:TITLE = substitute("Партии номинала &1 &2 материальной ценности &3", cur-par-val, cur-par-unit,cur-wth-name ).
         filter-label = substitute("&1", filter-label0).
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
                              "FOR EACH X_wth-parts NO-LOCK"
      parameter-4-48 =
        (
          if (" X_wth-parts.wth-code = p-wth-code and X_wth-parts.par-code = p-par-code and (rsfl-par = 0 or X_wth-parts.out-code = entry(rsfl-par,zone-list))                              and (rsfl-obj = 2 or (X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code  ) ) " + " " + where-phrase-48) <> ""
          then  SUBSTITUTE( 'X_wth-parts.wth-code = &1 and X_wth-parts.par-code = &2 and (&3 = 0 or X_wth-parts.out-code = &9&4&9)                                             and (&5 = 2 or (X_wth-parts.obj-type = &9&6&9 and X_wth-parts.obj-code = &7 ) )'                                           , p-wth-code                                            , p-par-code                                            , rsfl-par                                            , IF rsfl-par > 0 then entry(rsfl-par,zone-list) ELSE '':U                                             , rsfl-obj                                            , p-curr-obj-type                                            , p-curr-obj-code                                            , 'cli-zone':U                                            , chr(34)                                            )  + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + "")
      parameter-6-48 = if sort-phrase-48 = ''
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
          (" X_wth-parts.wth-code = p-wth-code and X_wth-parts.par-code = p-par-code and (rsfl-par = 0 or X_wth-parts.out-code = entry(rsfl-par,zone-list))                              and (rsfl-obj = 2 or (X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code  ) ) " + " " + where-phrase-48 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
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
    OPEN QUERY br-parts FOR EACH X_wth-parts NO-LOCK
      where  X_wth-parts.wth-code = p-wth-code and X_wth-parts.par-code = p-par-code and (rsfl-par = 0 or X_wth-parts.out-code = entry(rsfl-par,zone-list))                              and (rsfl-obj = 2 or (X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code  ) )
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
    end.
    when 'Место хранения МЦ':U then do:
         ASSIGN frame Dialog-Frame:TITLE = substitute("Партии серийных МЦ на МХ &1",p-w-p-code ).
         filter-label = substitute("&1", filter-label0).
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
                              "FOR EACH X_wth-parts NO-LOCK"
      parameter-4-50 =
        (
          if (" X_wth-parts.w-p-code = p-w-p-code  and (rsfl-par = 0 or X_wth-parts.out-code = entry(rsfl-par,zone-list))                           " + " " + where-phrase-50) <> ""
          then  SUBSTITUTE( 'X_wth-parts.w-p-code = &1  and (&2 = 0 or X_wth-parts.out-code = &4&3&4)'                                           , p-w-p-code                                           , rsfl-par                                             , IF rsfl-par > 0 then entry(rsfl-par,zone-list) ELSE '':U                                            , chr(34)                                           )  + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + "")
      parameter-6-50 = if sort-phrase-50 = ''
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
          (" X_wth-parts.w-p-code = p-w-p-code  and (rsfl-par = 0 or X_wth-parts.out-code = entry(rsfl-par,zone-list))                           " + " " + where-phrase-50 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
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
    OPEN QUERY br-parts FOR EACH X_wth-parts NO-LOCK
      where  X_wth-parts.w-p-code = p-w-p-code  and (rsfl-par = 0 or X_wth-parts.out-code = entry(rsfl-par,zone-list))
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
    end.
    when 'Серии МЦ':U then do:
    filter-label = substitute("&1", filter-label0).
         ASSIGN frame Dialog-Frame:TITLE = substitute("Партии серии &1 &2 &3 ",cur-ser-name,
                                                      if cur-par-val > 0 then (" номинала " + string(cur-par-val) + ' ' + cur-par-unit)  else "":U,
                                                      if cur-wth-name > '' then ("материальной ценности " + cur-wth-name) else "" ).
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
                              "FOR EACH X_wth-parts NO-LOCK"
      parameter-4-52 =
        (
          if (" X_wth-parts.wth-code = p-wth-code and X_wth-parts.ser-code = p-ser-code and X_wth-parts.db-num = p-db-num                            and (IF rsfl-par ne 0 THEN X_wth-parts.out-code = entry(rsfl-par,zone-list)  else true )                            and (rsfl-obj = 2 or (X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code  )  ) " + " " + where-phrase-52) <> ""
          then  SUBSTITUTE( 'X_wth-parts.wth-code = &1 and X_wth-parts.ser-code = &2 and X_wth-parts.db-num = &3'
                                          , p-wth-code                                           , p-ser-code                                           , p-db-num   )                                           +                                 SUBSTITUTE( ' and (IF &1 ne 0 THEN X_wth-parts.out-code = &7&2&7  else true )                                               and (&3 = 2 or (X_wth-parts.obj-type = &7&4&7 and X_wth-parts.obj-code = &5  )  )'
                                          , rsfl-par                                              , IF rsfl-par > 0 then entry(rsfl-par,zone-list) ELSE '':U                                            , rsfl-obj                                                            , p-curr-obj-type                                                     , p-curr-obj-code                                                     , 'cli-zone':U                                                         , chr(34)                                           )  + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + "")
      parameter-6-52 = if sort-phrase-52 = ''
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
          (" X_wth-parts.wth-code = p-wth-code and X_wth-parts.ser-code = p-ser-code and X_wth-parts.db-num = p-db-num                            and (IF rsfl-par ne 0 THEN X_wth-parts.out-code = entry(rsfl-par,zone-list)  else true )                            and (rsfl-obj = 2 or (X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code  )  ) " + " " + where-phrase-52 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
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
    OPEN QUERY br-parts FOR EACH X_wth-parts NO-LOCK
      where  X_wth-parts.wth-code = p-wth-code and X_wth-parts.ser-code = p-ser-code and X_wth-parts.db-num = p-db-num                            and (IF rsfl-par ne 0 THEN X_wth-parts.out-code = entry(rsfl-par,zone-list)  else true )                            and (rsfl-obj = 2 or (X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code  )  )
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
    end.
    when 'document' then do:
    filter-label = substitute("&1", filter-label0).
      ASSIGN frame Dialog-Frame:TITLE = substitute("Партии номинала &1 &2 МЦ &3 Документ: &4 № &5 &6 " ,cur-par-val, cur-par-unit, cur-wth-name, cur-wth-ext-doc-type-text ,cur-wth-doc-code, if p-edit-mode = 'ПРОСМОТР':U then 'ПРОСМОТР':U else "":U).
      if  lookup(cur-wth-ext-doc-type,'pc,pz,ps':U) > 0 or cur-wth-ext-doc-type = 'dc':U then do:
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
                              "FOR EACH X_wth-parts NO-LOCK"
      parameter-4-54 =
        (
          if (" X_wth-parts.wth-code = p-wth-code and X_wth-parts.par-code = p-par-code and  (if cur-wth-ext-doc-type = 'pz':U then X_wth-parts.cli-type = p-cli-type and X_wth-parts.cli-code = p-cli-code else true ) and (if rsfl-par >= 10 then  (X_wth-parts.out-code = p-wth-doc or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list)) else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) ) " + " " + where-phrase-54) <> ""
          then  SUBSTITUTE( 'X_wth-parts.wth-code = &1 and X_wth-parts.par-code = &2 and                                             (if &7&3&7 = &7&4&7 then X_wth-parts.cli-type = &7&5&7 and X_wth-parts.cli-code = &6 else true )'                                           , p-wth-code                                           , p-par-code                                           , cur-wth-ext-doc-type                                           , 'pz':U                                               , p-cli-type                                                     , p-cli-code                                                     , chr(34)                                           ) +                                                                SUBSTITUTE( 'and (if &1 >= 10 then  (X_wth-parts.out-code = &4&2&4 or X_wth-parts.out-code = &4&3&4) else                                              (if &1 = 0 then (X_wth-parts.out-code = &4&2&4) else (X_wth-parts.out-code = &4&3&4)) )'                                           , rsfl-par                                            , p-wth-doc                                            , IF rsfl-par > 0 then entry(rsfl-par modulo 10,zone-list) ELSE '':U                                            , chr(34)                                           )  + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + "")
      parameter-6-54 = if sort-phrase-54 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " +  SUBSTITUTE( 'by &1', 'X_wth-parts.fact-rangefrom')
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
          (" X_wth-parts.wth-code = p-wth-code and X_wth-parts.par-code = p-par-code and  (if cur-wth-ext-doc-type = 'pz':U then X_wth-parts.cli-type = p-cli-type and X_wth-parts.cli-code = p-cli-code else true ) and (if rsfl-par >= 10 then  (X_wth-parts.out-code = p-wth-doc or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list)) else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) ) " + " " + where-phrase-54 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
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
    OPEN QUERY br-parts FOR EACH X_wth-parts NO-LOCK
      where  X_wth-parts.wth-code = p-wth-code and X_wth-parts.par-code = p-par-code and  (if cur-wth-ext-doc-type = 'pz':U then X_wth-parts.cli-type = p-cli-type and X_wth-parts.cli-code = p-cli-code else true ) and (if rsfl-par >= 10 then  (X_wth-parts.out-code = p-wth-doc or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list)) else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) )
       by X_wth-parts.fact-rangefrom
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
      end.
      else if  cur-wth-ext-doc-type = 'xc':U and p-type = 'при':U then do:
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
                              "FOR EACH X_wth-parts NO-LOCK"
      parameter-4-56 =
        (
          if (" X_wth-parts.wth-code = p-wth-code and X_wth-parts.par-code = p-par-code and                             X_wth-parts.cli-type = p-cli-type and X_wth-parts.cli-code = p-cli-code and                              (if rsfl-par >= 10 then  ((X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type) or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list))                             else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type ) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) ) " + " " + where-phrase-56) <> ""
          then  SUBSTITUTE( 'X_wth-parts.wth-code = &1 and X_wth-parts.par-code = &2 and                                              X_wth-parts.cli-type = &5&3&5 and X_wth-parts.cli-code = &4 and '                                            , p-wth-code                                           , p-par-code                                           , p-cli-type                                           , p-cli-code                                           , chr(34)                                           )                                           +                                 SUBSTITUTE( '(if &1 >= 10 then  ((X_wth-parts.out-code = &5&2&5 and X_wth-parts.type = &5&3&5) or X_wth-parts.out-code = &5&4&5)                                              else (if &1 = 0 then (X_wth-parts.out-code = &5&2&5 and X_wth-parts.type = &5&3&5 ) else (X_wth-parts.out-code = &5&4&5)) )'                                           , rsfl-par                                             , p-wth-doc                                            , p-type                                               , IF rsfl-par > 0 then entry(rsfl-par modulo 10 ,zone-list) ELSE '':U                                            , chr(34)                                           )  + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + "")
      parameter-6-56 = if sort-phrase-56 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " +  SUBSTITUTE( 'by &1', 'X_wth-parts.fact-rangefrom')
        )
                           else
        (
        " " + "  " +
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
          (" X_wth-parts.wth-code = p-wth-code and X_wth-parts.par-code = p-par-code and                             X_wth-parts.cli-type = p-cli-type and X_wth-parts.cli-code = p-cli-code and                              (if rsfl-par >= 10 then  ((X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type) or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list))                             else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type ) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) ) " + " " + where-phrase-56 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
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
    OPEN QUERY br-parts FOR EACH X_wth-parts NO-LOCK
      where  X_wth-parts.wth-code = p-wth-code and X_wth-parts.par-code = p-par-code and                             X_wth-parts.cli-type = p-cli-type and X_wth-parts.cli-code = p-cli-code and                              (if rsfl-par >= 10 then  ((X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type) or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list))                             else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type ) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) )
       by X_wth-parts.fact-rangefrom
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
      end.
      else if  cur-wth-ext-doc-type = 'xc':U         and p-type = 'рас':U then do:
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
                              "FOR EACH X_wth-parts NO-LOCK"
      parameter-4-58 =
        (
          if (" X_wth-parts.wth-code = p-wth-code and X_wth-parts.w-p-code = p-w-p-code             and X_wth-parts.par-code = p-par-code and X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code             and (if rsfl-par >= 10 then  ((X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type) or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list))             else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) ) " + " " + where-phrase-58) <> ""
          then  SUBSTITUTE( 'X_wth-parts.wth-code = &1 and X_wth-parts.w-p-code = &2                                              and X_wth-parts.par-code = &3 and X_wth-parts.obj-type = &6&4&6 and X_wth-parts.obj-code = &5 '                                           , p-wth-code                                           , p-w-p-code                                           , p-par-code                                           , p-curr-obj-type                                           , p-curr-obj-code                                           , chr(34)                                           ) +
                                SUBSTITUTE( 'and (if &1 >= 10 then  ((X_wth-parts.out-code = &5&2&5 and X_wth-parts.type = &5&3&5) or X_wth-parts.out-code = &5&4&5)                                              else (if &1 = 0 then (X_wth-parts.out-code = &5&2&5 and X_wth-parts.type = &5&3&5) else (X_wth-parts.out-code = &5&4&5)) )'                                           , rsfl-par                                           , p-wth-doc                                           , p-type                                              , IF rsfl-par > 0 then entry(rsfl-par modulo 10,zone-list) ELSE '':U                                            , chr(34)                                           )  + " " + where-phrase-58
          else "true"
        )
      parameter-5-58 = (" " + "" + " " + "")
      parameter-6-58 = if sort-phrase-58 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " +  SUBSTITUTE( 'by &1', 'X_wth-parts.fact-rangefrom')
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
          (" X_wth-parts.wth-code = p-wth-code and X_wth-parts.w-p-code = p-w-p-code             and X_wth-parts.par-code = p-par-code and X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code             and (if rsfl-par >= 10 then  ((X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type) or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list))             else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) ) " + " " + where-phrase-58 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
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
    OPEN QUERY br-parts FOR EACH X_wth-parts NO-LOCK
      where  X_wth-parts.wth-code = p-wth-code and X_wth-parts.w-p-code = p-w-p-code             and X_wth-parts.par-code = p-par-code and X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code             and (if rsfl-par >= 10 then  ((X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type) or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list))             else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc and X_wth-parts.type = p-type) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) )
       by X_wth-parts.fact-rangefrom
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
      end.
      else do:
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
                              "FOR EACH X_wth-parts NO-LOCK"
      parameter-4-60 =
        (
          if (" X_wth-parts.wth-code = p-wth-code and X_wth-parts.w-p-code = p-w-p-code             and X_wth-parts.par-code = p-par-code and X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code             and (if rsfl-par >= 10 then  (X_wth-parts.out-code = p-wth-doc or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list)) else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) ) " + " " + where-phrase-60) <> ""
          then  SUBSTITUTE( ' X_wth-parts.wth-code = &1 and X_wth-parts.w-p-code = &2                                              and X_wth-parts.par-code = &3 and X_wth-parts.obj-type = &6&4&6 and X_wth-parts.obj-code = &5 '                                           , p-wth-code                                           , p-w-p-code                                           , p-par-code                                           , p-curr-obj-type                                           , p-curr-obj-code                                           , chr(34)                                           )                                           +                                 SUBSTITUTE( ' and (if &1 >= 10 then  (X_wth-parts.out-code = &4&2&4 or X_wth-parts.out-code = &4&3&4) else (if &1 = 0 then (X_wth-parts.out-code = &4&2&4) else (X_wth-parts.out-code = &4&3&4)) )  '                                           , rsfl-par                                           , p-wth-doc                                            , IF rsfl-par > 0 then entry(rsfl-par modulo 10,zone-list) ELSE '':U                                            , chr(34)                                           )   + " " + where-phrase-60
          else "true"
        )
      parameter-5-60 = (" " + "" + " " + "")
      parameter-6-60 = if sort-phrase-60 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " +  SUBSTITUTE( 'by &1', 'X_wth-parts.fact-rangefrom')
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
          (" X_wth-parts.wth-code = p-wth-code and X_wth-parts.w-p-code = p-w-p-code             and X_wth-parts.par-code = p-par-code and X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code             and (if rsfl-par >= 10 then  (X_wth-parts.out-code = p-wth-doc or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list)) else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) ) " + " " + where-phrase-60 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-parts:handle
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
    OPEN QUERY br-parts FOR EACH X_wth-parts NO-LOCK
      where  X_wth-parts.wth-code = p-wth-code and X_wth-parts.w-p-code = p-w-p-code             and X_wth-parts.par-code = p-par-code and X_wth-parts.obj-type = p-curr-obj-type and X_wth-parts.obj-code = p-curr-obj-code             and (if rsfl-par >= 10 then  (X_wth-parts.out-code = p-wth-doc or X_wth-parts.out-code = entry(rsfl-par - 10, zone-list)) else (if rsfl-par = 0 then (X_wth-parts.out-code = p-wth-doc) else (X_wth-parts.out-code = entry(rsfl-par,zone-list))) )
       by X_wth-parts.fact-rangefrom
  .
      assign
        l-query-was-opened = true
      .
  end.
  run waitfram-hide in this-procedure .
      end.
    end.
END CASE.
if v-prt-rec <> ? then reposition br-parts to recid v-prt-rec no-error.
apply "entry" to br-parts in frame Dialog-Frame.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED":U to br-parts.
END PROCEDURE.
PROCEDURE PrintProc :
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable v-obj    as character    no-undo.
define variable v-cli    as character    no-undo.
define variable v-sum-tot as integer     no-undo.
define variable v-price   as character no-undo.
DEFINE FRAME Wth-List
v-serName                  column-label "Серия"  format "x(10)"
fl-par-val                 column-label "Номинал"  format "x(5)"
X_wth-parts.fact-rangeFrom column-label "Диапазон с"  format ">>>>>>>>"
X_wth-parts.fact-rangeTo   column-label "Диапазон по" format ">>>>>>>>"
v-w-p-name                 COLUMN-LABEL "MX"     FORMAT "X(14)":U
v-obj                      column-label "Объект"
v-obj-name                 COLUMN-LABEL "Объект"     FORMAT "X(14)":U
v-out-name                 column-label "Зона"
X_wth-parts.in-code        column-label "Накл. порожд."
v-cli                      column-label "Покупатель"  format 'x(20)'
v-price                    column-label "Цена за ед."  format 'x(12)'
X_wth-parts.beg-dt         column-label "Срок годн. с"
X_wth-parts.end-dt         column-label "Срок годн. по"
X_wth-parts.fact-date      column-label "Факт. дата"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 100 PAGE-NUMBER(PrnLibStream) AT 110 FORMAT ">>9" SKIP
Line format "X(190)" AT 1
with width 198 down stream-io use-text    .
Line = fill("-", 190).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame Dialog-Frame:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 198 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME Wth-List  .
run waitfram-show in this-procedure ( input "Ждите...").
v-sum-tot = 0.
GET first BR-parts.
DO WHILE available X_wth-parts :
      FIND FIRST b-wealth WHERE b-wealth.wth-code = X_wth-parts.wth-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wealth THEN fl-wth-name =  b-wealth.wth-name.
      ELSE fl-wth-name = '?':U.
      FIND FIRST b-wth-par WHERE b-wth-par.wth-code =  X_wth-parts.wth-code AND b-wth-par.par-code = X_wth-parts.par-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wth-par THEN assign fl-par-val =  SUBSTITUTE("&1&2",b-wth-par.par-val,b-wth-par.par-unit).
  Display STREAM PrnLibStream
       fl-par-val
      get-ser-name(X_wth-parts.ser-code,X_wth-parts.db-num) @ v-serName
      X_wth-parts.fact-rangeFrom
      X_wth-parts.fact-rangeTo
      get-w-p-name(X_wth-parts.w-p-code, X_wth-parts.obj-type,X_wth-parts.obj-code) @ v-w-p-name
      substitute('&1 &2',X_wth-parts.obj-type,X_wth-parts.obj-code) @ v-obj
      get-cli-name(X_wth-parts.obj-type,X_wth-parts.obj-code ) @ v-obj-name   COLUMN-LABEL "Объект"     FORMAT "X(14)":U
            get-wthparts-out-code(X_wth-parts.out-code) @ v-out-name
      X_wth-parts.in-code
      get-cli-name(X_wth-parts.cli-type,X_wth-parts.cli-code ) @ v-cli
      if X_wth-parts.price-rubl > 0 then trim(string((X_wth-parts.price-rubl / b-wth-par.par-val),"->>,>>9.99")) else '':U @ v-price
      X_wth-parts.beg-dt
      X_wth-parts.end-dt
      X_wth-parts.fact-date
  with FRAME Wth-List .
  v-sum-tot = v-sum-tot + X_wth-parts.fact-rangeTo - X_wth-parts.fact-rangeFrom + 1.
  DOWN STREAM PrnLibStream 1 with FRAME Wth-List  .
  GET next BR-parts.
END.
UNDERLINE  STREAM PrnLibStream
    v-serName
   fl-par-val
     X_wth-parts.fact-rangeFrom
   X_wth-parts.fact-rangeTo
    v-w-p-name
    v-obj
    v-obj-name
    v-out-name
    X_wth-parts.in-code
    v-cli
    v-price
    X_wth-parts.beg-dt
    X_wth-parts.end-dt
    X_wth-parts.fact-date
with FRAME Wth-List .
 put STREAM PrnLibStream
  "ИТОГО    " at 20 v-sum-tot at 30 .
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
END PROCEDURE.
PROCEDURE proc-add :
define variable rep-rec as recid no-undo.
define variable v-i as int       no-undo.
define variable v-addrid-list as char no-undo.
if b-wth-doc.ext-doc-type = 'ie':U then do:
  run str/wthpartl.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,INPUT 'ДОБАВЛЕНИЕ':U
                ,INPUT p-w-p-code
                ,INPUT p-wth-code
                ,INPUT p-par-code
                ,INPUT p-wth-doc
                ,INPUT p-wth-doc
                ,INPUT 0
                ,INPUT 0
                ,INPUT 0
                ,INPUT 0
                ,INPUT p-type
                ,input-output rep-rec).
  if rep-rec <> ? then
  v-prt-rec = rep-rec.
end.
else do:
    if  available X_wth-parts AND (rid-list = ""  or
        b-mark:sensitive in frame Dialog-Frame= no)
    then
    rid-list = string( recid( X_wth-parts ) ) .
    v-addrid-list = rid-list.
    list-block:
    do v-i = 1 to num-entries(v-addrid-list,chr(44)):
      rep-rec = int(entry(v-i,v-addrid-list,chr(44))).
      for first b-wth-parts no-lock where recid(b-wth-parts) = rep-rec:
        RUN wth-parts-rezerv ( yes
                              ,b-wth-parts.fact-rangeFrom
                              ,b-wth-parts.fact-RangeTo
                              ,b-wth-parts.beg-dt
                              ,b-wth-parts.end-dt
                              ,b-wth-parts.ser-code
                              ,b-wth-parts.db-num
                              ,b-wth-parts.price-rubl
                              ,b-wth-parts.price-base
                              ,b-wth-parts.vat-pc
                              ,b-wth-doc.host-code
                              ,b-wth-doc.obj-type
                              ,b-wth-doc.obj-code
                              ,p-w-p-code
                              ,b-wth-parts.wth-code
                              ,b-wth-parts.par-code
                              ,b-wth-parts.in-code
                              ,b-wth-doc.doc-code
                              ,b-wth-doc.cli-type
                              ,b-wth-doc.cli-code
                              ,b-wth-doc.ext-doc-type
                              ,b-goods.gds-code
                              ,p-type
                              ,INPUT-OUTPUT rep-rec
                              ) no-error .
        if error-status:error then do:
          if v-i =  num-entries(v-addrid-list,chr(44)) then do:
            MESSAGE RETURN-VALUE
            VIEW-AS ALERT-BOX error.
            leave list-block.
          end.
          else do:
            MESSAGE RETURN-VALUE skip
                    "Продолжить добавление линий в документ?"
            VIEW-AS ALERT-BOX question buttons yes-no update choice as log.
            if choice then.
            else leave list-block.
          end.
        end.
        v-prt-rec = rep-rec.
      end.
      assign
        entry( lookup(string(rep-rec),rid-list),rid-list ) = "":U
        rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
      .
    end.
end.
END PROCEDURE.
PROCEDURE proc-del :
define variable v-i as int no-undo.
define variable v-delrid-list as char no-undo.
define variable rep-rec as recid no-undo.
if  available X_wth-parts AND (rid-list = ""  or
    b-mark:sensitive in frame Dialog-Frame = no)
then
rid-list = string( recid( X_wth-parts ) ) .
v-delrid-list = rid-list.
if num-entries(v-delrid-list,chr(44)) = 1 then do:
    message
       substitute("Удалить партию из документа. Вы уверены?&1Партия:&1Код МЦ &2&1Код серии&3-&4&1Диапазон &5-&6",
                  chr(10)
                 ,X_wth-parts.wth-code
                 ,X_wth-parts.ser-code
                 ,X_wth-parts.db-num
                 ,X_wth-parts.fact-rangeFrom
                 ,X_wth-parts.fact-rangeTo)
       view-as alert-box question buttons OK-Cancel update choice as log.
       if not choice then do:
         apply "entry" to br-parts in frame Dialog-Frame.
         return no-apply.
       end.
end.
else do:
  message substitute('Вы действительно хотите удалить &1 партий из документа?',num-entries(v-delrid-list,chr(44)))
       view-as alert-box question buttons OK-Cancel update choice .
       if not choice then do:
         apply "entry" to br-parts in frame Dialog-Frame.
         return no-apply.
       end.
end.
list-block:
do v-i = 1 to num-entries(v-delrid-list,chr(44)):
  rep-rec = int(entry(v-i,v-delrid-list,chr(44))).
  for first b-wth-parts no-lock where recid(b-wth-parts) = rep-rec:
    if b-wth-parts.stts = 0 then do:
        run  wth-doc-razrez ( input RECID(b-wth-parts),
                              input no ) no-error.
        if error-status:error then DO:
          if v-i = num-entries(v-delrid-list,chr(44)) then do:
            MESSAGE RETURN-VALUE skip
                  Error-status:get-message(1)
            VIEW-AS ALERT-BOX ERROR.
          end.
          else do:
            MESSAGE RETURN-VALUE skip
                  Error-status:get-message(1)  skip
                  'Продолжить удаление?'
            VIEW-AS ALERT-BOX question buttons yes-no update choice.
            if choice then.
            else leave list-block.
          end.
        end.
    end.
    else do:
      run str/wthpartp.p  ( INPUT  'ИЗМЕНЕНИЕ':U,
                            INPUT  b-wth-parts.obj-type,
                            INPUT  b-wth-parts.obj-code,
                            INPUT  b-wth-parts.w-p-code,
                            INPUT  b-wth-parts.wth-code,
                            INPUT  b-wth-parts.par-code,
                            INPUT  b-wth-parts.in-code ,
                            INPUT  b-wth-parts.out-code,
                            INPUT  b-wth-parts.ser-code,
                            INPUT  b-wth-parts.db-num  ,
                            INPUT  b-wth-parts.Fact-RangeFrom ,
                            INPUT  b-wth-parts.fact-rangeTo   ,
                            INPUT  b-wth-parts.doc-RangeFrom ,
                            INPUT  b-wth-parts.doc-rangeTo  ,
                            INPUT  b-wth-parts.host-code     ,
                            INPUT  b-wth-parts.contract-code ,
                            INPUT  b-wth-parts.price-rubl    ,
                            INPUT  b-wth-parts.price-base    ,
                            INPUT  b-wth-parts.supp-type,
                            INPUT  b-wth-parts.supp-code,
                            INPUT  b-wth-parts.in-obj-type      ,
                            INPUT  b-wth-parts.in-obj-code      ,
                            INPUT  b-wth-parts.ext-doc-type,
                            INPUT  b-wth-parts.gds-code,
                            INPUT  0            ,
                            INPUT  b-wth-parts.beg-dt        ,
                            INPUT  b-wth-parts.end-dt        ,
                            INPUT  b-wth-parts.vat-pc        ,
                            INPUT  b-wth-parts.cli-code,
                            INPUT  b-wth-parts.cli-type,
                            INPUT  b-wth-parts.out-obj-code,
                            INPUT  b-wth-parts.out-obj-type,
                            INPUT  b-wth-parts.sale-obj-code,
                            INPUT  b-wth-parts.sale-obj-type,
                            INPUT  b-wth-parts.doc-code ,
                            INPUT  yes,
                            INPUT   b-wth-parts.type ,
                            INPUT-OUTPUT rep-rec
                  ) no-error.
      if error-status:error then do:
        if v-i = num-entries(v-delrid-list,chr(44)) then do:
          MESSAGE RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
        end.
        else do:
          MESSAGE RETURN-VALUE  skip
                  'Продолжить удаление?'
            VIEW-AS ALERT-BOX question buttons yes-no update choice.
            if choice then.
            else leave list-block.
        end.
      end.
    end.
    v-prt-rec = rep-rec.
  end.
  assign
    entry( lookup(string(rep-rec),rid-list),rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
END PROCEDURE.
PROCEDURE save-position :
 do
with frame Dialog-Frame
on error undo, return error
:
assign rsfl-ch rsfl-obj.
        run uf-set (
              input 'wthps-zone':U
            , input v-cntxt-userid
            , input string( rsfl-ch )
            , input 'wthps-zone':U
            , input no
            , input no
            , input no
            , input no
        ) no-error .
              run uf-set (
              input 'wthparts-obj':U
            , input v-cntxt-userid
            , input string( rsfl-obj )
            , input 'wthparts-obj':U
            , input no
            , input no
            , input no
            , input no
        )  no-error.
end.
END PROCEDURE.
PROCEDURE show-doc-code :
if not self:sensitive then return.
 for first b-wth-doc no-lock where b-wth-doc.doc-code = fl-doc-code:screen-value in frame Dialog-Frame:
  run str/wthd-lkp.p (INPUT parparentproc ,
                      input recid(b-wth-doc)) no-error.
  if error-status:error then do:
    message return-value skip
    error-status:get-message(1)
    view-as alert-box error.
  end.
 end.
END PROCEDURE.
FUNCTION get-cli-name RETURNS CHARACTER
  ( f-cli-type AS CHAR, f-cli-code as int  ) :
For FIRST b-clients WHERE b-clients.obj-type = f-cli-type AND
                       b-clients.obj-code = f-cli-code NO-LOCK:
  return   b-clients.obj-name.
end.
RETURN "".
END FUNCTION.
FUNCTION get-ser-name RETURNS CHARACTER
  ( pfser-code AS INT, pfser-db AS INT ) :
FOR FIRST buf_wth-ser NO-LOCK WHERE buf_wth-ser.ser-code = pfser-code
                       AND  buf_wth-ser.db-num =  pfser-db:
    RETURN buf_wth-ser.series.
END.
  RETURN "".
END FUNCTION.
FUNCTION get-w-p-name RETURNS CHARACTER
  ( vf-w-p-code AS int ,vf-obj-type as char, vf-obj-code as int ) :
if vf-w-p-code = 0 or vf-w-p-code = ? then return "":U.
for first buf_wth-place no-lock where buf_wth-place.w-p-code = vf-w-p-code
                                  and buf_wth-place.obj-type = vf-obj-type
                                  and buf_wth-place.obj-code = vf-obj-code:
  return buf_wth-place.w-p-name.
end.
return string(vf-w-p-code).
END FUNCTION.
FUNCTION get-wthparts-out-code RETURNS CHARACTER
  ( vf-out-code AS CHAR ) :
CASE vf-out-code:
    WHEN 'free-zone':U   THEN RETURN 'свободно'.
    WHEN 'out-zone':U THEN RETURN 'списано'.
    WHEN 'put-zone':U    THEN RETURN 'погашено'.
    WHEN 'cli-zone':U    THEN RETURN 'у клиента'.
    WHEN 'фальшивый':U      THEN RETURN 'фальш.'.
END CASE.
RETURN vf-out-code.
END FUNCTION.
