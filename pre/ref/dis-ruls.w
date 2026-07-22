DEFINE TEMP-TABLE tt-dis-rule-bc NO-UNDO LIKE ub.dis-rule
       field price-brutto like ub.gds-obj.price-sale
       field price-netto like ub.gds-obj.price-sale
       field price-discnt like ub.gds-obj.price-sale
       field sum-brutto like ub.trn-doc.tot-sale
       field sum-netto like ub.trn-doc.tot-sale
       field sum-discnt like ub.trn-doc.tot-sale
       field d-pcnt like ub.dis-rule.discnt-value
       field sale-qnty like ub.dis-rule.doc-qnty.
DEFINE TEMP-TABLE tt0-template_dis-rule NO-UNDO LIKE ub.dis-cfg-rule.
DEFINE BUFFER X_bar-code FOR ub.bar-code.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_dis-rule FOR ub.dis-rule.
DEFINE BUFFER X_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER X_term-dis-rule FOR ub.dis-rule.
DEFINE BUFFER X_upper-dis-rule FOR ub.dis-rule.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter bttns  as char   no-undo .
define input parameter p-mode  as char   no-undo .
define input parameter p-upper-rule-num like ub.dis-rule.upper-rule-num no-undo .
define input parameter p-time-templ-rl-root like ub.dis-rule.time-templ-rl-root no-undo .
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input-output parameter p-sts like ub.dis-rule.sts no-undo .
define input-output param p-rid-list    as  char no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список ПРАВИЛ СКИДОК":U.
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
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
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dr-code :
  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-rule.des               no-undo .
    define output parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
    define output parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
    define output parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
    define output parameter  p-level-1           as character no-undo .
    define output parameter  p-level-2           as character no-undo .
    define output parameter  p-global             as integer no-undo .
    define output parameter  p-host               as integer no-undo .
    define output parameter  p-object             as integer no-undo .
    define output parameter  p-output-display as logical   no-undo .
    define output parameter  p-tree           as char  no-undo .
    define output parameter  p-other          as character no-undo .
    define variable v-other as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-templ-rl-root no-error.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("неизвестный шаблон скидки &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-rule.des
    p-discnt-type = buf_dis-rule.discnt-type
    p-subject-type = buf_dis-rule.subject-type
    p-value-type = buf_dis-rule.value-type
    p-global = (if available buf_dis-cfg-rule
                then buf_dis-cfg-rule.has-global
                else 0)
    p-host = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-host
              else 0)
    p-object = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-obj
              else 0)
    p-output-display = (buf_dis-rule.sts = integer('0':U))
    p-tree = buf_Dis-rule.uniq-field
    p-other = buf_dis-rule.other-inf
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    .
  end.
end procedure.
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
procedure disrules-get-interface-form :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define output parameter p-form-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
find first buf_temp-drt-prop where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "InputForm"
      and buf_temp-drt-prop.prop-code = "FormName" no-error.
if not available buf_temp-drt-prop then do:
  find first buf_drt-prop where
            buf_drt-prop.templ-rl-root = p-templ-rl-root
        and buf_drt-prop.upper-prop-code = "InputForm"
        and buf_drt-prop.prop-code = "FormName" no-error.
  if available buf_drt-prop then do:
    p-form-name = buf_drt-prop.property-value.
  end.
  else do:
    p-form-name = "ref/dis-ruli.w".
  end.
end.
else do:
  p-form-name = buf_temp-drt-prop.property-value.
end.
end procedure.
~
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dtr-code :
  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-time-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-time-rule.des               no-undo .
    define output parameter  p-upper-time-rule-num    like ub.dis-time-rule.upper-time-rule-num    no-undo .
    define output parameter  p-value-type        like ub.dis-time-rule.value-type        no-undo .
    define output parameter  p-level-1 as character no-undo .
    define output parameter  p-level-2 as character no-undo .
    define output parameter  p-output-display as logical   no-undo .
    define output parameter  p-tree           as char  no-undo .
    define output parameter  p-other          as character no-undo .
    define variable v-templ-rl-root like ub.dis-time-rule.templ-rl-root no-undo .
    define buffer buf_dis-time-rule for ub.dis-time-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    if p-templ-rl-root < 50000 then
    v-templ-rl-root = (p-templ-rl-root + 50000).
    else v-templ-rl-root = p-templ-rl-root.
    find first buf_dis-time-rule no-lock where
              buf_dis-time-rule.time-rule-num = v-templ-rl-root no-error .
    if not available buf_dis-time-rule then do:
      undo, return error substitute("неизвестный тип расписания &1", p-templ-rl-root) .
    end.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = 0
        and buf_dis-cfg-rule.time-templ-rl-root = p-templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("неизвестный тип расписания &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-time-rule.des
    p-upper-time-rule-num = (buf_dis-time-rule.upper-time-rule-num - 50000)
    p-value-type = buf_dis-time-rule.value-type
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    p-output-display = (buf_dis-time-rule.sts = integer('0':U))
    p-tree = buf_dis-time-rule.uniq-field
    p-other = buf_dis-time-rule.other-inf
    .
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
~
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discfgru-check :
define input parameter p-table-name as character no-undo .
define input parameter p-templ-rl-root as integer no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-pos-type as character no-undo .
define output parameter p-disnct-role as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
  do
  on error undo, return error return-value
  :
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.table-name = p-table-name
        and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and (p-time-templ-rl-root = ? or  buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root)
        and buf_dis-cfg-rule.pos-type = p-pos-type no-error.
    if not available buf_dis-cfg-rule
    or p-pos-type = "":U
    then do:
       return error substitute("Для места использования типа &1 не определен тип скидки с шаблоном &2 &3"
                               ,entry (lookup (p-pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
                               , p-templ-rl-root
                               , (if p-time-templ-rl-root = ?
                                  then '':U
                                  else substitute("с расписанием типа &1", p-time-templ-rl-root)
                                  )
                               ).
    end.
    assign
    p-disnct-role = buf_dis-cfg-rule.discnt-role
    .
  end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
procedure disgdsru-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :
  define input  parameter p-templ-rl-root  as integer no-undo .
  define output parameter p-label          as character no-undo .
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.
  if available buf_dis-rule
  then do:
    if buf_dis-rule.rule-num > 0 then
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function disgdsru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disgdsru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function disgdsru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
return entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u).
end function.
procedure disgdsru-write :
  do
  on error undo, return error
  :
    define input parameter p-obj-type       like ub.dis-gds-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-gds-rule.obj-code   no-undo .
    define input parameter p-gds-code       like ub.dis-gds-rule.gds-code   no-undo .
    define input parameter p-pos-type       like ub.dis-gds-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-gds-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-gds-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-gds-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-gds-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-gds-rule.nonunique   no-undo .
    define buffer buf_dis-gds-rule for ub.dis-gds-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer lock_dis-gds-rule for ub.dis-gds-rule .
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-gds-rule':U
                                         ,input p-templ-rl-root
                                         ,input p-time-templ-rl-root
                                         ,input p-pos-type
                                         ,output v-discnt-role
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-discnt-role = ? then do:
      p-discnt-role = v-discnt-role.
    end.
    if p-discnt-role <> v-discnt-role then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не может быть по шаблону &7 и расписанию &8"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type13 as character no-undo .
define variable v-value-date13 as date no-undo .
define variable v-value-decimal13 as decimal no-undo .
define variable v-value-integer13 as INTEGER no-undo .
define variable v-value-logical13 AS LOGICAL no-undo .
define variable v-tth13 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date13
    ,output v-value-decimal13
    ,output v-value-integer13
    ,output v-value-logical13
    ,output v-param-type13
    ,INPUT-OUTPUT table-handle v-tth13
    )  .
delete object v-tth13 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не найдено правило скидки &7"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6правило скидки &7 - некорневое"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if not (p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code)
    and not ( (p-obj-type = 'маг':U or p-obj-type = 'скл':U )
             and
             (buf_dis-rule.obj-type = 'орг':U or buf_dis-rule.obj-type = ""))
     then do:
      undo, return error (substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ) +
                          substitute("Правило скидки &1 определено для &2&3" +
                                     "а привязка к товару для &4"
                                     ,buf_dis-rule.rule-num
                                     ,get-objregion( buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,chr(10)
                                     ,get-objregion( p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-gds-rule exclusive-lock where
               buf_dis-gds-rule.gds-code  = p-gds-code
           AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
           AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
           AND buf_dis-gds-rule.pos-type  = p-pos-type
           AND buf_dis-gds-rule.discnt-role = p-discnt-role
           and buf_dis-gds-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-gds-rule then do:
      find first buf_dis-gds-rule exclusive-lock where
                buf_dis-gds-rule.gds-code  = p-gds-code
            AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
            AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
            AND buf_dis-gds-rule.pos-type  = p-pos-type
            AND buf_dis-gds-rule.discnt-role = p-discnt-role
            no-error .
      if available buf_Dis-gds-rule then do:
        if p-nonunique = ''
        and available buf_dis-gds-rule
        then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует (детализ. &3)"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                   , p-nonunique
                                  ).
        end.
        if available buf_dis-gds-rule
        and buf_dis-gds-rule.nonunique = ''
        and p-nonunique <> ''then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                  ).
        end.
      end.
      create buf_dis-gds-rule .
      assign
      buf_dis-gds-rule.gds-code  = p-gds-code
      buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
      buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
      buf_dis-gds-rule.pos-type = p-pos-type
      buf_dis-gds-rule.discnt-role = v-discnt-role
      buf_dis-gds-rule.rule-num = p-rule-num
      buf_dis-gds-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-gds-rule.rule-num = p-rule-num
    buf_dis-gds-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-gds-rule.templ-rl-root = p-templ-rl-root
    buf_dis-gds-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
PROCEDURE cmp-disgdsru-write :
do
on error undo, return error
:
  define input parameter p-gds-code like ub.dis-gds-rule.gds-code   no-undo .
  define input parameter p-obj-type like ub.dis-gds-rule.obj-type   no-undo .
  define input parameter p-obj-code like ub.dis-gds-rule.obj-code   no-undo .
  define input parameter p-pos-type like ub.dis-gds-rule.pos-type   no-undo .
  define input parameter p-templ-rl-root     like ub.dis-gds-rule.templ-rl-root  no-undo .
  define input parameter p-time-templ-rl-root     like ub.dis-gds-rule.time-templ-rl-root  no-undo .
  define input parameter p-discnt-role like ub.dis-gds-rule.discnt-role no-undo .
  define input parameter p-rule-num    like ub.dis-gds-rule.rule-num no-undo .
  define input parameter p-nonunique like ub.dis-gds-rule.nonunique no-undo .
  define variable v-rule-label          as character no-undo .
  define buffer buf_tt0-dis-gds-rule for ub.dis-gds-rule .
  define buffer buf_dis-rule     for ub.dis-rule.
  run disgdsru-name in this-procedure (
                                      input  p-templ-rl-root
                                      ,output v-rule-label
                                      ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_tt0-dis-gds-rule exclusive-lock where
              buf_tt0-dis-gds-rule.gds-code  = p-gds-code
          AND buf_tt0-dis-gds-rule.obj-type  = p-obj-type
          AND buf_tt0-dis-gds-rule.obj-code  = p-obj-code
          AND buf_tt0-dis-gds-rule.pos-type  = p-pos-type
          AND buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
          AND buf_tt0-dis-gds-rule.nonunique = p-nonunique
          no-error .
  if not available buf_tt0-dis-gds-rule then do:
    create buf_tt0-dis-gds-rule .
    assign
    buf_tt0-dis-gds-rule.gds-code  = p-gds-code
    buf_tt0-dis-gds-rule.obj-type  = p-obj-type
    buf_tt0-dis-gds-rule.obj-code  = p-obj-code
    buf_tt0-dis-gds-rule.pos-type  = p-pos-type
    buf_tt0-dis-gds-rule.nonunique = p-nonunique
    buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
    no-error
    .
  end.
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-rule-num.
  ASSIGN
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rule-num = p-rule-num
  buf_tt0-dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
  buf_tt0-dis-gds-rule.nonunique = p-nonunique
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rl-root = buf_Dis-rule.rl-root
  no-error.
  release buf_tt0-dis-gds-rule no-error .
  if error-status:error then do:
    undo, return error return-value .
  end.
end.
END PROCEDURE.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gtregion RETURNS CHARACTER
  ( input parhost-code as integer
  , input parobj-type as character
  , input parobj-code as integer
  , input p-templ-rl-root as integer
  , input p-template as logical
  , input p-tab as logical
  ) :
  def var par-region as character no-undo.
  define variable v-g as character no-undo .
  define variable v-h as character no-undo .
  define variable v-o as character no-undo .
  define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    if p-template then do:
      find first buf_dis-cfg-rule no-lock where
                buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root no-error.
      assign
      v-g = (if available buf_dis-cfg-rule
            and buf_dis-cfg-rule.has-global = 1
            then "Глоб"
            else '')
      par-region = v-g + chr(44)
      v-h =  (if available buf_dis-cfg-rule
              and buf_dis-cfg-rule.has-host = 1
              then "Фирма"
              else '')
      par-region = trim(par-region + v-h, chr(44)) + chr(44)
      v-o = (if available buf_dis-cfg-rule
             and buf_dis-cfg-rule.has-obj = 1
             then "Объ."
             else '')
      par-region = trim(par-region + v-o, chr(44))
      .
      return par-region.
    end.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = "" and
       parobj-code = 0 then do:
       par-region = if p-tab then fill(chr(32), 2) else "":U +
                    "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    par-region = if p-tab then fill(chr(32), 4) else "":U +
                 parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable p-value-type as character no-undo .
define variable v-rid-list as character no-undo .
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable add-option as character no-undo .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable filter-point as character no-undo init "dis-ruls" .
define variable filter-point0 as character no-undo init "dis-ruls" .
define variable filter-label as character no-undo init "Правила скидок" .
define variable filter-label0 as character no-undo init "dis-ruls" .
DEFINE variable v-display-time-rule-num AS CHARACTER NO-UNDO.
DEFINE variable v-display-dis-kat AS CHARACTER  NO-UNDO.
DEFINE variable v-display-doc-qnty AS CHARACTER  NO-UNDO.
DEFINE variable v-display-tot-sum AS CHARACTER  NO-UNDO.
DEFINE variable v-display-key#_one AS CHARACTER  NO-UNDO.
DEFINE variable v-display-key#_two AS CHARACTER  NO-UNDO.
DEFINE variable v-display-key#_three AS CHARACTER  NO-UNDO.
DEFINE variable v-display-charkey_one AS CHARACTER  NO-UNDO.
DEFINE variable v-display-charkey_two AS CHARACTER  NO-UNDO.
DEFINE variable v-display-charkey_three AS CHARACTER  NO-UNDO.
DEFINE variable v-display-deckey_one AS CHARACTER  NO-UNDO.
DEFINE variable v-display-deckey_two AS CHARACTER  NO-UNDO.
DEFINE variable v-display-deckey_three AS CHARACTER  NO-UNDO.
DEFINE VARIABLE v-display-discnt-value AS CHARACTER  NO-UNDO.
DEFINE VARIABLE v-price-sale LIKE ub.price-list.price-sale NO-UNDO.
define varIABLE v-attr-type as character no-undo .
define varIABLE v-attr-format as character no-undo .
define varIABLE v-attr-label as character no-undo .
define variable v-attr-range as integer no-undo.
define varIABLE v-attr-value as character no-undo .
define varIABLE v-attr-user-can-edit as logical no-undo .
define varIABLE v-attr-output-display as logical no-undo .
define varIABLE v-attr-other as char no-undo .
define variable v-cd   as character no-undo .
define variable v-discnt-role as character no-undo .
define variable v-region as character no-undo .
DEFINE VARIABLE lookup-option AS CHARACTER NO-UNDO.
define variable v-using-fields as character no-undo .
define temp-table print-dis-rule no-undo
field srule-num as integer
field display-time-rule-num AS CHARACTER
field display-dis-kat AS CHARACTER
field display-doc-qnty AS CHARACTER
field display-tot-sum AS CHARACTER
field display-key#_one AS CHARACTER
field display-key#_two AS CHARACTER
field display-key#_three AS CHARACTER
field display-charkey_one AS CHARACTER
field display-charkey_two AS CHARACTER
field display-charkey_three AS CHARACTER
field display-deckey_one AS CHARACTER
field display-deckey_two AS CHARACTER
field display-deckey_three AS CHARACTER
field display-discnt-value AS CHARACTER
index pi is unique primary srule-num
.
define buffer pos_dis-rule for ub.dis-rule.
DEFINE BUFFER tt-template_dis-rule FOR tt0-template_dis-rule.
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-dis-rule FOR ub.dis-rule, input mark-list as CHARACTER )  FORWARD.
DEFINE MENU MENU-B-add
       MENU-ITEM m_global       LABEL "Глобально"
       MENU-ITEM m_host         LABEL "Фирма"
       MENU-ITEM m_object       LABEL "Объект"        .
DEFINE MENU MENU-B-copy
       MENU-ITEM m_global-copy  LABEL "Глобально"
       MENU-ITEM m_host-copy    LABEL "Фирма"
       MENU-ITEM m_object-copy  LABEL "Объект"
       RULE
       MENU-ITEM m_list-copy    LABEL "На другие объекты по списку" .
DEFINE MENU MENU-B-lookup
       MENU-ITEM M_rule         LABEL "Правило"
       MENU-ITEM m_subject      LABEL "Объекты приложения правила".
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-copy
     LABEL "&Копия"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-dis-rules
     LABEL "Пр&авила"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-history
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE BUTTON B-stat
     LABEL "&Статус"
     SIZE 10 BY 1.
DEFINE BUTTON B-time-rule
     LABEL "&Распис."
     SIZE 10 BY 1.
DEFINE VARIABLE Cb-pos-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-des AS CHARACTER FORMAT "X(255)"
      VIEW-AS TEXT
     SIZE 98 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE RS-sts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 32 BY 1 NO-UNDO.
DEFINE QUERY br-dis-rule FOR
                X_dis-rule,
                tt-template_dis-rule SCROLLING.
DEFINE QUERY BR-gds-obj FOR
      tt-dis-rule-bc SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      X_dis-rule SCROLLING.
DEFINE BROWSE br-dis-rule
  QUERY br-dis-rule NO-LOCK DISPLAY
      mark-string(buffer X_dis-rule, v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
X_dis-rule.des FORMAT "X(255)":U
    WIDTH 50
v-display-discnt-value COLUMN-LABEL "Знач. скидки" FORMAT "X(15)":U
gtregion(X_dis-rule.host-code, X_dis-rule.obj-type, X_dis-rule.obj-code, X_dis-rule.templ-rl-root, X_dis-rule.lvl-num = 0, no) COLUMN-LABEL "Область действия" FORMAT "X(15)":U
entry (lookup (string(X_dis-rule.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U) COLUMN-LABEL "Тип скидки" FORMAT "X(20)":U
    WIDTH 22
entry (lookup (STRING(X_dis-rule.subject-type), '0,1,2,3,4,5,7,8':U), 'Неизв,Товар,Подитог,Итог,Чек,Оплата,Товар_б/итог.скидки,Группа':U) COLUMN-LABEL "Объект!воздействия!скидки" FORMAT "X(20)":U
    WIDTH 12
entry (lookup (STRING(X_dis-rule.value-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U) COLUMN-LABEL "Тип!знач." FORMAT "X(7)":U
v-display-dis-kat COLUMN-LABEL "Катег." FORMAT "X(4)":U
v-display-doc-qnty COLUMN-LABEL "Кол-во для!скидки" FORMAT "X(10)":U
v-display-tot-sum COLUMN-LABEL "Сумма для!скидки" FORMAT "X(14)":U
v-display-time-rule-num COLUMN-LABEL "Расписание" FORMAT "X(9)":U
v-display-deckey_one COLUMN-LABEL "ДПоле1" FORMAT "->>,>>9.99"
v-display-deckey_two COLUMN-LABEL "ДПоле2" FORMAT "->>,>>9.99"
v-display-deckey_three COLUMN-LABEL "ДПоле3" FORMAT "->>,>>9.99"
v-display-charkey_one COLUMN-LABEL "Поле1" FORMAT "X(12)"
v-display-charkey_two COLUMN-LABEL "Поле2" FORMAT "X(12)"
v-display-charkey_three COLUMN-LABEL "Поле3" FORMAT "X(12)"
v-display-key#_one COLUMN-LABEL "ИнтПоле1" FORMAT "X(10)"
v-display-key#_two COLUMN-LABEL "ИнтПоле2" FORMAT "X(10)"
v-display-key#_three COLUMN-LABEL "ИнтПоле3" FORMAT "X(10)"
entry (lookup (STRING(X_dis-rule.sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U) COLUMN-LABEL "Статус"
X_dis-rule.rule-num COLUMN-LABEL "№ правила" FORMAT ">>>>>>>>9":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.
DEFINE BROWSE BR-gds-obj
  QUERY BR-gds-obj NO-LOCK DISPLAY
      entry (lookup (string(tt-dis-rule-bc.value-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U) COLUMN-LABEL "Тип" FORMAT "X(10)":U
            WIDTH 10
tt-dis-rule-bc.dis-kat COLUMN-LABEL "Катег" FORMAT "->>>9":U
tt-dis-rule-bc.doc-qnty COLUMN-LABEL "Кол-во!для скидки" FORMAT "->>,>>>,>>9.<<<":U
tt-dis-rule-bc.tot-sum COLUMN-LABEL "Сумма для!скидки" FORMAT "->>>,>>>,>>9.99":U
tt-dis-rule-bc.time-rule-num FORMAT "->>>>>>>>9":U
tt-dis-rule-bc.discnt-value COLUMN-LABEL "Знач. скидки" FORMAT "->>>,>>>,>>9.99":U
tt-dis-rule-bc.d-pcnt COLUMN-LABEL "% скидки"
tt-dis-rule-bc.sale-qnty COLUMN-LABEL "Кол-во!для скидки" FORMAT ">>,>>>,>>9.<<<":U
tt-dis-rule-bc.price-brutto COLUMN-LABEL "Цена без скидки" FORMAT ">>,>>>,>>9.99":U
tt-dis-rule-bc.price-discnt COLUMN-LABEL "Скидка за ед" FORMAT "->>,>>>,>>9.99":U
tt-dis-rule-bc.price-netto COLUMN-LABEL "Цена со скидкой" FORMAT ">>,>>>,>>9.99":U
tt-dis-rule-bc.sum-brutto COLUMN-LABEL "Сумма без скидки" FORMAT ">,>>>,>>>,>>9.99":U
tt-dis-rule-bc.sum-discnt COLUMN-LABEL "Сумма скидки" FORMAT ">,>>>,>>>,>>9.99":U
tt-dis-rule-bc.sum-netto COLUMN-LABEL "Сумма со скидкой" FORMAT ">,>>>,>>>,>>9.99":U
tt-dis-rule-bc.charkey_one COLUMN-LABEL "Поле1" FORMAT "X(12)":U
tt-dis-rule-bc.charkey_two COLUMN-LABEL "Поле2" FORMAT "X(12)":U
tt-dis-rule-bc.charkey_three COLUMN-LABEL "Поле3" FORMAT "X(12)":U
tt-dis-rule-bc.key#_one COLUMN-LABEL "ИнтПоле1" FORMAT "->>>>>>>>9":U
tt-dis-rule-bc.key#_two COLUMN-LABEL "ИнтПоле2" FORMAT "->>>>>>>>9":U
tt-dis-rule-bc.key#_three COLUMN-LABEL "ИНтПоле3" FORMAT "->>>>>>>>9":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9
         FGCOLOR 1 FONT 4
         TITLE FGCOLOR 1 "Суммы и цены по товару после применения скидки" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 26
     B-add AT ROW 1 COL 36
     B-copy AT ROW 1 COL 46 WIDGET-ID 4
     B-lookup AT ROW 1 COL 56
     B-chg AT ROW 1 COL 66
     B-del AT ROW 1 COL 76
     b-history AT ROW 1 COL 86
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     RS-sts AT ROW 2 COL 1.5 NO-LABEL
     Cb-pos-type AT ROW 2 COL 32 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     B-stat AT ROW 2 COL 56
     B-dis-rules AT ROW 2 COL 66
     B-time-rule AT ROW 2 COL 76
     br-dis-rule AT ROW 3.25 COL 1
     BR-gds-obj AT ROW 12.25 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     v-des AT ROW 21.38 COL 1 NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Правила скидок".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-add:HIDDEN IN FRAME Dialog-Frame           = TRUE
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.
ASSIGN
       B-chg:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-copy:HIDDEN IN FRAME Dialog-Frame           = TRUE
       B-copy:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-copy:HANDLE.
ASSIGN
       B-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-dis-rules:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-lookup:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-lookup:HANDLE.
ASSIGN
       B-time-rule:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       BR-gds-obj:HIDDEN  IN FRAME Dialog-Frame                = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  ASSIGN
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
OR ENDKEY OF FRAME Dialog-Frame DO:
  run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input v-rid-list) no-error.
  if error-status:error then return no-apply.
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT 'ДОБАВЛЕНИЕ':U ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
    RUN proc-b-chg IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-copy IN FRAME Dialog-Frame
DO:
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT 'КОПИРОВАНИЕ':U ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
if not available X_dis-rule then return no-apply.
  run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-dis-rules IN FRAME Dialog-Frame
DO:
RUN proc-b-dis-rules IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-history IN FRAME Dialog-Frame
DO:
  RUN proc-b-history IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
 IF lookup-option = '':U  THEN DO:
   run gbl/pop-up.p ( INPUT self :handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
 end.
 if lookup-option = "":U then do:
      return no-apply.
 end.
 RUN proc-b-lookup IN THIS-PROCEDURE ( INPUT lookup-option) NO-ERROR.
 IF ERROR-STATUS:ERROR THEN do:
    lookup-option = '':U.
    RETURN NO-APPLY.
 END.
 lookup-option = '':U.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  RUN proc-b-mark IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-dis-rule.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
    if ( available X_dis-rule ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_dis-rule ) ) .
  end.
END.
ON CHOOSE OF B-stat IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
  IF NOT AVAILABLE X_dis-rule THEN RETURN NO-APPLY.
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_discount_work':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
  if not loc#log then return no-apply.
  v-doc-rec = recid(X_dis-rule).
  RUN proc-b-stat IN THIS-PROCEDURE ( input recid(X_dis-rule)) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
  RUN openbr IN THIS-PROCEDURE( input YES, input NO, input '':U) NO-ERROR.
   REPOSITION br-dis-rule to recid v-doc-rec No-ERROR.
END.
ON CHOOSE OF B-time-rule IN FRAME Dialog-Frame
DO:
  RUN proc-b-time-rule IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON RETURN OF br-dis-rule IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-dis-rule IN FRAME Dialog-Frame
    DO:
    run proc-br-dis-rule in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF br-dis-rule IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_dis-rule  THEN DO:
    ASSIGN
    v-des = X_dis-rule.des
    .
  END.
  ELSE DO:
    ASSIGN
    v-des = "":U.
  END.
  DISPLAY
  v-des
  WITH FRAME Dialog-Frame.
  assign
  menu-item m_subject:sensitive  in menu menu-b-lookup =   (available X_dis-rule and X_dis-rule.upper-rule-num <  99999)
  .
  RUN OpenBrgds-obj IN THIS-PROCEDURE.
  APPLY "ENTRY" TO br-dis-rule.
END.
ON VALUE-CHANGED OF Cb-pos-type IN FRAME Dialog-Frame
DO:
  assign
  cb-pos-type
  v-cd = cb-pos-type
  .
  run fill-tables in this-procedure .
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON CHOOSE OF MENU-ITEM m_global
DO:
  ASSIGN
  ADD-OPTION = "global":U.
  APPLY "CHOOSE" TO b-add IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_global-copy
DO:
  ASSIGN
  ADD-OPTION = "global":U.
  APPLY "CHOOSE" TO b-copy IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_host
DO:
  ASSIGN
  ADD-OPTION = "host":U.
  APPLY "CHOOSE" TO b-add  IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_host-copy
DO:
  ASSIGN
  ADD-OPTION = "host":U.
  APPLY "CHOOSE" TO b-copy  IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_object
DO:
  ASSIGN
  ADD-OPTION = "object":U.
  APPLY "CHOOSE" TO b-add  IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_list-copy
DO:
define variable loc-doc-rec as recid no-undo .
  case p-mode:
    when 'объект':U then do:
      if available X_dis-rule then do:
        loc-doc-rec = recid(X_dis-rule).
      end.
      run utl/drc_obj.w ( input parparentproc
                     ,input 'объект':U
                     ,input 0
                     ,input p-curr-obj-type
                     ,input p-curr-obj-code
                     ) no-error.
    end.
    when "template" then do:
      if not available X_dis-rule then do:
        undo, return no-apply.
      end.
      run utl/drc_obj.w ( input parparentproc
                     ,input "template"
                     ,input X_dis-rule.templ-rl-root
                     ,input ''
                     ,input 0
                     ) no-error.
    end.
    otherwise do:
      if not available X_dis-rule then do:
        undo, return no-apply.
      end.
      if not (X_dis-rule.obj-type = 'маг':U
              or
              X_dis-rule.obj-type = 'скл':U) then do:
        message
        "Нельзя скопировать с правила скидки, которое действует НЕ ПО ОБЪЕКТУ"
        view-as alert-box error .
        undo, return no-apply.
      end.
      loc-doc-rec = recid(X_dis-rule).
      run utl/drc_obj.w ( input parparentproc
                     ,input "rule-num"
                     ,input X_dis-rule.rule-num
                     ,input ''
                     ,input 0
                     ) no-error.
    end.
  end case.
RUn OpenBR in this-procedure ( input YES, input NO, input '':U).
reposition br-dis-rule to recid loc-doc-rec no-error.
if error-status:error then do:                           find first pos_dis-rule no-lock where                                   recid(pos_dis-rule) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи ПРАВИЛО СКИДКИ" skip                            string(if avail pos_dis-rule                                     then  substitute("номер правила скидки: &1"                                                     , pos_dis-rule.rule-num)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
apply "entry" to br-dis-rule in frame Dialog-Frame.
apply "value-changed" to br-dis-rule in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_object-copy
DO:
  ASSIGN
  ADD-OPTION = "object":U.
  APPLY "CHOOSE" TO b-copy  IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM M_rule
DO:
   ASSIGN
  lookup-option = "rule".
  RUN proc-b-lookup IN THIS-PROCEDURE ( INPUT lookup-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      ASSIGN
      lookup-option = '':U.
      RETURN NO-APPLY.
  END.
  ASSIGN
  lookup-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_subject
DO:
  ASSIGN
  lookup-option = "subject".
  RUN proc-b-lookup IN THIS-PROCEDURE ( INPUT lookup-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      ASSIGN
      lookup-option = '':U.
      RETURN NO-APPLY.
  END.
  ASSIGN
  lookup-option = '':U.
END.
ON VALUE-CHANGED OF RS-sts IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-sts
  p-sts = (IF rs-sts = 'все':U THEN -1 ELSE INTEGER(rs-sts))
  .
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
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
        v-diasize-browse-handle     = browse br-dis-rule :handle
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-doc-rec = ?. if available X_dis-rule then v-doc-rec = recid(X_dis-rule). run openbr in this-procedure ( input yes, input no, input '':U).  reposition br-dis-rule to recid v-doc-rec no-error.                apply 'entry' to br-dis-rule in frame Dialog-Frame.                 APPLY 'value-changed' to br-dis-rule.
    apply "VALUE-CHANGED" to br-dis-rule.
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var sort-labelbr-dis-rule   as character no-undo .
def var sort-clmnbr-dis-rule    as handle    no-undo .
def var cur-clmnbr-dis-rule     as handle    no-undo .
def var cur-clmn-locbr-dis-rule as integer   no-undo .
def var re-querybr-dis-rule     as logical   initial no no-undo .
on start-search, ctrl-o of br-dis-rule in frame Dialog-Frame do:
   run sort-brbr-dis-rule
     (input (if available X_dis-rule
             then recid(X_dis-rule)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-dis-rule :
  define input parameter p-recid as recid no-undo .
  if re-querybr-dis-rule = no then do:
    assign
       cur-clmnbr-dis-rule = br-dis-rule:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-dis-rule <> ? then sort-clmnbr-dis-rule:column-fgcolor = 0.
    if cur-clmnbr-dis-rule = sort-clmnbr-dis-rule then do:
      assign
         sort-labelbr-dis-rule = ""
         sort-clmnbr-dis-rule = ?
      .
     end.
     else do:
       assign
         sort-labelbr-dis-rule = cur-clmnbr-dis-rule:label
         sort-clmnbr-dis-rule  = cur-clmnbr-dis-rule
         sort-clmnbr-dis-rule:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-dis-rule = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-dis-rule:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-dis-rule then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-dis-rule = cur-clmn-locbr-dis-rule + 1
    .
  end.
  case sort-labelbr-dis-rule:
        when X_dis-rule.rule-num:label in browse br-dis-rule then DO:    assign       sort-column-name = "X_dis-rule.rule-num"     .     run OpenBr in this-procedure ( input YES, input NO, input '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input YES, input NO, input '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-dis-rule') then do:
          run mv-brw-defaultbr-dis-rule.
        end.
      if sort-labelbr-dis-rule <> "" then do:
        assign
          cur-clmnbr-dis-rule:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-dis-rule = ?
      .
    end.
  end case.
    if cur-clmn-locbr-dis-rule <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-dis-rule') then do:
        run ch-clmnbr-dis-rule in this-procedure (cur-clmn-locbr-dis-rule).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-dis-rule to recid p-recid no-error.
    apply "value-changed" to br-dis-rule in frame Dialog-Frame.
  end.
  apply "entry" to br-dis-rule in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-dis-rule:
if cur-clmnbr-dis-rule = ? then do:
   run OpenBr in this-procedure ( input YES, input NO, input '':U).
end.
else do:
   assign re-querybr-dis-rule = yes.
   run sort-brbr-dis-rule
     (input (if available X_dis-rule
             then recid(X_dis-rule)
             else ?
            )
     ).
   assign re-querybr-dis-rule = no.
end.
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-dis-rule :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lookup :sensitive then DO: apply "CHOOSE":U to b-lookup in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ALT-F8 of frame Dialog-Frame anywhere do:
  if b-history :sensitive then DO: apply "CHOOSE":U to b-history in frame Dialog-Frame. END.
  return no-apply.
end.
on f6 anywhere do:
define buffer buf0_dis-rule for ub.dis-rule.
find first buf0_dis-rule no-lock where
        buf0_dis-rule.rule-num = 0 no-error .
if available buf0_dis-rule then do:
  message
  "Версия структуры скидок" buf0_dis-rule.des
  view-as alert-box .
end.
else do:
  message
  "Не найдена головная запись структуры скидок!"
  view-as alert-box error .
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  v-rid-list = p-rid-list.
  if p-time-templ-rl-root = ? then do:
    p-time-templ-rl-root = -1.
  end.
  if p-sts = ? then do:
    p-sts = -1.
  end.
  RUN main-proc IN this-procedure no-error.
  if error-status:error then  undo, return error .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-dis-rule as INT EXTENT 19 no-undo.
DEF VAR varmvibr-dis-rule       as INT no-undo.
DEF VAR varmvjbr-dis-rule       as INT no-undo.
DEF VAR varmvkbr-dis-rule       as INT no-undo.
DEF VAR varmvlbr-dis-rule       as INT no-undo.
DEF VAR move-elementbr-dis-rule as INT no-undo.
def var jjbr-dis-rule           as int no-undo.
do varmvibr-dis-rule = 1 to EXTENT(cur-clmn-numbr-dis-rule):
  ASSIGN cur-clmn-numbr-dis-rule[varmvibr-dis-rule] = varmvibr-dis-rule.
END.
RUN start-mv-clmnbr-dis-rule.
PROCEDURE start-mv-clmnbr-dis-rule:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  p-mode = 'все':U or p-mode = 'template':U  THEN DO:
   DO jjbr-dis-rule = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19') TO 1 BY -1:
     RUN re-move-clmnbr-dis-rule ( cur-clmn-numbr-dis-rule[INTEGER(ENTRY (jjbr-dis-rule, '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19'))] , 1).
   END.
       END.
       IF  p-mode = 'upper-rule-num':U  THEN DO:
   DO jjbr-dis-rule = NUM-ENTRIES('1,2,3,4,8,9,10,11,5,6,7,12,13,14,15,16,17,18,19') TO 1 BY -1:
     RUN re-move-clmnbr-dis-rule ( cur-clmn-numbr-dis-rule[INTEGER(ENTRY (jjbr-dis-rule, '1,2,3,4,8,9,10,11,5,6,7,12,13,14,15,16,17,18,19'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-dis-rule do:
  RUN re-move-clmnbr-dis-rule ( 1, 19).
END.
ON ctrl-cursor-left OF BROWSE br-dis-rule do:
  RUN re-move-clmnbr-dis-rule (19, 1).
END.
PROCEDURE re-move-clmnbr-dis-rule:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-dis-rule = 1 TO EXTENT(cur-clmn-numbr-dis-rule):
    if cur-clmn-numbr-dis-rule[varmvibr-dis-rule] = source-column THEN cur-clmn-numbr-dis-rule[varmvibr-dis-rule] = -1.
  END.
  if br-dis-rule:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-dis-rule = source-column - 1 to target-column BY -1:
    DO varmvibr-dis-rule = 1 TO EXTENT(cur-clmn-numbr-dis-rule):
        if cur-clmn-numbr-dis-rule[varmvibr-dis-rule] = varmvjbr-dis-rule THEN DO:
          cur-clmn-numbr-dis-rule[varmvibr-dis-rule] = cur-clmn-numbr-dis-rule[varmvibr-dis-rule] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-dis-rule = source-column + 1 to target-column:
    DO varmvibr-dis-rule = 1 TO EXTENT(cur-clmn-numbr-dis-rule):
      if cur-clmn-numbr-dis-rule[varmvibr-dis-rule] = varmvjbr-dis-rule THEN DO:
        cur-clmn-numbr-dis-rule[varmvibr-dis-rule] = cur-clmn-numbr-dis-rule[varmvibr-dis-rule] - 1.
      END.
    END.
  END.
  DO varmvibr-dis-rule = 1 TO EXTENT(cur-clmn-numbr-dis-rule):
    if cur-clmn-numbr-dis-rule[varmvibr-dis-rule] = -1 THEN cur-clmn-numbr-dis-rule[varmvibr-dis-rule] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-dis-rule:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-dis-rule = 1 TO EXTENT(cur-clmn-numbr-dis-rule):
    if cur-clmn-numbr-dis-rule[varmvibr-dis-rule] = cur-clmn-loc THEN move-elementbr-dis-rule = varmvibr-dis-rule.
  END.
  RUN re-move-clmnbr-dis-rule (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-dis-rule:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-dis-rule = 1 to EXTENT(cur-clmn-numbr-dis-rule):
    RUN re-move-clmnbr-dis-rule (cur-clmn-numbr-dis-rule[varmvlbr-dis-rule], varmvlbr-dis-rule).
  END.
  RUN start-mv-clmnbr-dis-rule.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse BR-gds-obj :handle
    ) .
  run diasize_init in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH X_dis-rule SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY RS-sts Cb-pos-type mark-num v-des
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-copy B-lookup B-chg B-del b-history
         B-print B-sch B-Help RS-sts Cb-pos-type B-stat B-dis-rules B-time-rule
         br-dis-rule BR-gds-obj mark-num v-des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
define variable jj as integer no-undo .
define buffer buf_tt0-template_dis-rule for tt0-template_dis-rule.
define buffer buf_dis-rule  for ub.dis-rule.
define buffer buf0_dis-rule  for ub.dis-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
if p-mode = 'dis-gds-rule':U
or p-mode = 'dis-dc-rule':U
or p-mode = 'dis-dct-rule':U
or p-mode = 'dis-cp-rule':U
or p-mode = 'dis-thbj-rule':U
or p-mode = 'dis-grp-rule':U
or p-mode = 'dis-some-rule':U
or p-mode = "dis-gds-rule-gds-obj"
or p-mode = "cd-obj":U then do:
end.
else do:
  for each buf_tt0-template_dis-rule:
    delete buf_tt0-template_dis-rule.
  end.
  if v-cd = '':U then do:
    find first buf_dis-rule no-lock where buf_dis-rule.rule-num = 0 no-error .
    if available buf_dis-rule then do:
      create buf_tt0-template_Dis-rule.
      buffer-copy buf_dis-rule to
      buf_tt0-template_dis-rule.
    end.
  end.
  else do:
    for each buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.pos-type = v-cd:
      create buf_tt0-template_Dis-rule.
      buffer-copy buf_dis-cfg-rule to
      buf_tt0-template_dis-rule.
    end.
  end.
end.
END PROCEDURE.
PROCEDURE fill-tables-gds-obj :
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
define buffer buf_units for ub.units.
define variable v-meas as integer no-undo init 3.
define variable ii as integer no-undo .
FOR EACH tt-dis-rule-bc:
  DELETE tt-dis-rule-bc.
END.
IF NOT AVAILABLE X_dis-rule THEN DO:
    return.
END.
find first buf_units no-lock where
           buf_units.unit-name = X_goods.unit-base no-error.
if available buf_units then do:
  assign
  v-meas = if( LOOKUP('шту':U, buf_units.type) > 0 or LOOKUP('сер':U, buf_units.type) > 0 )
           then 0
           else v-meas.
end.
CASE X_dis-rule.is-term:
    WHEN YES THEN DO:
       CREATE tt-dis-rule-bc.
       BUFFER-COPY X_dis-rule to tt-dis-rule-bc
       ASSIGN
       tt-dis-rule-bc.price-brutto = v-price-sale
       .
       if X_dis-rule.tot-sum = - 1 then do:                                                                                                                                                                       assign  tt-dis-rule-bc.d-pcnt      = tt-dis-rule-bc.discnt-value .                                                 CASE tt-dis-rule-bc.value-type:                                                                                            WHEN INTEGER('1':U) THEN DO:                                                                             ASSIGN                                                                                                             tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.discnt-value / 100                          tt-dis-rule-bc.price-netto = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-discnt                             tt-dis-rule-bc.sum-brutto = ABS(tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.doc-qnty)                             tt-dis-rule-bc.sum-netto = ABS(tt-dis-rule-bc.price-netto * tt-dis-rule-bc.doc-qnty)                               tt-dis-rule-bc.sum-discnt = ABS(tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.doc-qnty).                         END.                                                                                                               WHEN INTEGER('2':U) THEN DO:                                                                               ASSIGN                                                                                                             tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.discnt-value                                                          tt-dis-rule-bc.d-pcnt       = 100 * (1 - tt-dis-rule-bc.price-netto / tt-dis-rule-bc.price-brutto)                 tt-dis-rule-bc.price-netto = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-discnt                             tt-dis-rule-bc.sum-brutto = ABS(tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.doc-qnty)                             tt-dis-rule-bc.sum-netto = ABS(tt-dis-rule-bc.price-netto * tt-dis-rule-bc.doc-qnty)                               tt-dis-rule-bc.sum-discnt = ABS(tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.doc-qnty).                        END.                                                                                                               WHEN INTEGER('3':U) THEN DO:                                                                                ASSIGN                                                                                                             tt-dis-rule-bc.price-netto = tt-dis-rule-bc.discnt-value                                                           tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-netto                             tt-dis-rule-bc.sum-brutto = ABS(tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.doc-qnty)                             tt-dis-rule-bc.sum-netto = ABS(tt-dis-rule-bc.price-netto * tt-dis-rule-bc.doc-qnty)                               tt-dis-rule-bc.sum-discnt = ABS(tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.doc-qnty).                         END.                                                                                                          END CASE.                                                                                                       end.                                                                                                               else do:                                                                                                                                                                                         assign  tt-dis-rule-bc.sale-qnty = truncate(tt-dis-rule-bc.tot-sum / tt-dis-rule-bc.price-brutto, v-meas).         CASE tt-dis-rule-bc.value-type:                                                                                            WHEN INTEGER('1':U) THEN DO:                                                                             ASSIGN                                                                                                             tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.discnt-value / 100                          tt-dis-rule-bc.d-pcnt      = tt-dis-rule-bc.discnt-value                                                           tt-dis-rule-bc.price-netto = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-discnt                             tt-dis-rule-bc.sum-brutto = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.sale-qnty                                 tt-dis-rule-bc.sum-netto = tt-dis-rule-bc.price-netto * tt-dis-rule-bc.sale-qnty                                   tt-dis-rule-bc.sum-discnt = tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.sale-qnty .                             END.                                                                                                               WHEN INTEGER('2':U) THEN DO:                                                                               ASSIGN                                                                                                             tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.discnt-value                                                          tt-dis-rule-bc.d-pcnt       = 100 * (1 - tt-dis-rule-bc.price-netto / tt-dis-rule-bc.price-brutto)                 tt-dis-rule-bc.price-netto = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-discnt                             tt-dis-rule-bc.sum-brutto = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.sale-qnty                                 tt-dis-rule-bc.sum-netto = tt-dis-rule-bc.price-netto * tt-dis-rule-bc.sale-qnty                                   tt-dis-rule-bc.sum-discnt = tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.sale-qnty .                           END.                                                                                                               WHEN INTEGER('3':U) THEN DO:                                                                                ASSIGN                                                                                                             tt-dis-rule-bc.price-netto = tt-dis-rule-bc.discnt-value                                                           tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-netto                             tt-dis-rule-bc.sum-brutto = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.sale-qnty                                 tt-dis-rule-bc.sum-netto = tt-dis-rule-bc.price-netto * tt-dis-rule-bc.sale-qnty                                   tt-dis-rule-bc.sum-discnt = tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.sale-qnty .                            END.                                                                                                          END CASE.                                                                                                       end.
    END.
    WHEN NO  THEN DO:
        FOR EACH buf_dis-rule NO-LOCK WHERE
                buf_dis-rule.upper-rule-num = X_dis-rule.rule-num:
            CREATE tt-dis-rule-bc.
            BUFFER-COPY buf_dis-rule to tt-dis-rule-bc
            ASSIGN
            tt-dis-rule-bc.price-brutto = v-price-sale
            .
            if X_dis-rule.tot-sum = - 1 then do:                                                                                                                                                                       assign  tt-dis-rule-bc.d-pcnt      = tt-dis-rule-bc.discnt-value .                                                 CASE tt-dis-rule-bc.value-type:                                                                                            WHEN INTEGER('1':U) THEN DO:                                                                             ASSIGN                                                                                                             tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.discnt-value / 100                          tt-dis-rule-bc.price-netto = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-discnt                             tt-dis-rule-bc.sum-brutto = ABS(tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.doc-qnty)                             tt-dis-rule-bc.sum-netto = ABS(tt-dis-rule-bc.price-netto * tt-dis-rule-bc.doc-qnty)                               tt-dis-rule-bc.sum-discnt = ABS(tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.doc-qnty).                         END.                                                                                                               WHEN INTEGER('2':U) THEN DO:                                                                               ASSIGN                                                                                                             tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.discnt-value                                                          tt-dis-rule-bc.d-pcnt       = 100 * (1 - tt-dis-rule-bc.price-netto / tt-dis-rule-bc.price-brutto)                 tt-dis-rule-bc.price-netto = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-discnt                             tt-dis-rule-bc.sum-brutto = ABS(tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.doc-qnty)                             tt-dis-rule-bc.sum-netto = ABS(tt-dis-rule-bc.price-netto * tt-dis-rule-bc.doc-qnty)                               tt-dis-rule-bc.sum-discnt = ABS(tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.doc-qnty).                        END.                                                                                                               WHEN INTEGER('3':U) THEN DO:                                                                                ASSIGN                                                                                                             tt-dis-rule-bc.price-netto = tt-dis-rule-bc.discnt-value                                                           tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-netto                             tt-dis-rule-bc.sum-brutto = ABS(tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.doc-qnty)                             tt-dis-rule-bc.sum-netto = ABS(tt-dis-rule-bc.price-netto * tt-dis-rule-bc.doc-qnty)                               tt-dis-rule-bc.sum-discnt = ABS(tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.doc-qnty).                         END.                                                                                                          END CASE.                                                                                                       end.                                                                                                               else do:                                                                                                                                                                                         assign  tt-dis-rule-bc.sale-qnty = truncate(tt-dis-rule-bc.tot-sum / tt-dis-rule-bc.price-brutto, v-meas).         CASE tt-dis-rule-bc.value-type:                                                                                            WHEN INTEGER('1':U) THEN DO:                                                                             ASSIGN                                                                                                             tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.discnt-value / 100                          tt-dis-rule-bc.d-pcnt      = tt-dis-rule-bc.discnt-value                                                           tt-dis-rule-bc.price-netto = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-discnt                             tt-dis-rule-bc.sum-brutto = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.sale-qnty                                 tt-dis-rule-bc.sum-netto = tt-dis-rule-bc.price-netto * tt-dis-rule-bc.sale-qnty                                   tt-dis-rule-bc.sum-discnt = tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.sale-qnty .                             END.                                                                                                               WHEN INTEGER('2':U) THEN DO:                                                                               ASSIGN                                                                                                             tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.discnt-value                                                          tt-dis-rule-bc.d-pcnt       = 100 * (1 - tt-dis-rule-bc.price-netto / tt-dis-rule-bc.price-brutto)                 tt-dis-rule-bc.price-netto = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-discnt                             tt-dis-rule-bc.sum-brutto = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.sale-qnty                                 tt-dis-rule-bc.sum-netto = tt-dis-rule-bc.price-netto * tt-dis-rule-bc.sale-qnty                                   tt-dis-rule-bc.sum-discnt = tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.sale-qnty .                           END.                                                                                                               WHEN INTEGER('3':U) THEN DO:                                                                                ASSIGN                                                                                                             tt-dis-rule-bc.price-netto = tt-dis-rule-bc.discnt-value                                                           tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-netto                             tt-dis-rule-bc.sum-brutto = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.sale-qnty                                 tt-dis-rule-bc.sum-netto = tt-dis-rule-bc.price-netto * tt-dis-rule-bc.sale-qnty                                   tt-dis-rule-bc.sum-discnt = tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.sale-qnty .                            END.                                                                                                          END CASE.                                                                                                       end.
        END.
    END.
END CASE.
END PROCEDURE.
PROCEDURE get-tree :
DEFINE PARAMETER BUFFER loc_dis-rule for ub.dis-rule.
DEFINE OUTPUT PARAMETER p-display-time-rule-num AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-display-dis-kat AS CHARACTER  NO-UNDO.
DEFINE OUTPUT PARAMETER p-display-doc-qnty AS CHARACTER  NO-UNDO.
DEFINE OUTPUT PARAMETER p-display-tot-sum AS CHARACTER  NO-UNDO.
define output parameter p-display-charkey_one as character no-undo .
define output parameter p-display-charkey_two as character no-undo .
define output parameter p-display-charkey_three as character no-undo .
define output parameter p-display-deckey_one as character no-undo .
define output parameter p-display-deckey_two as character no-undo .
define output parameter p-display-deckey_three as character no-undo .
define output parameter p-display-key#_one as character no-undo .
define output parameter p-display-key#_two as character no-undo .
define output parameter p-display-key#_three as character no-undo .
DEFINE OUTPUT PARAMETER p-display-discnt-value AS CHARACTER  NO-UNDO.
define output parameter p-using-fields as character no-undo .
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO INIT ?.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
define variable v-level-1 as character no-undo .
define variable v-level-2 as character no-undo .
define variable v-curr-level as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
IF loc_dis-rule.uniq-field <> "":U
AND loc_dis-rule.upper-rule-num <= 99999 THEN DO:
  DO ii = 1 TO NUM-ENTRIES(loc_dis-rule.uniq-field):
    v-entry = ENTRY(ii, loc_dis-rule.uniq-field).
    CASE v-entry:
      WHEN "time-rule-num" THEN DO:
        ASSIGN
        p-display-time-rule-num = "...    ".
      END.
      WHEN "doc-qnty" THEN DO:
        ASSIGN
        p-display-doc-qnty = "...    ".
      END.
      WHEN "tot-sum" THEN DO:
        ASSIGN
        p-display-tot-sum = "...    ".
      END.
      WHEN "dis-kat" THEN DO:
        ASSIGN
        p-display-dis-kat = "...    ".
      END.
      WHEN "charkey_one" THEN DO:
        ASSIGN
        p-display-charkey_one = "...    ".
      END.
      WHEN "charkey_two" THEN DO:
        ASSIGN
        p-display-charkey_two = "...    ".
      END.
      WHEN "charkey_three" THEN DO:
        ASSIGN
        p-display-charkey_three = "...    ".
      END.
      WHEN "deckey_one" THEN DO:
        ASSIGN
        p-display-deckey_one = "...    ".
      END.
      WHEN "deckey_two" THEN DO:
        ASSIGN
        p-display-deckey_two = "...    ".
      END.
      WHEN "deckey_three" THEN DO:
        ASSIGN
        p-display-deckey_three = "...    ".
      END.
      WHEN "key#_one" THEN DO:
        ASSIGN
        p-display-key#_one = "...    ".
      END.
      WHEN "key#_two" THEN DO:
        ASSIGN
        p-display-key#_two = "...    ".
      END.
      WHEN "key#_three" THEN DO:
        ASSIGN
        p-display-key#_three = "...    ".
      END.
    END CASE.
  END.
  ASSIGN
  p-using-fields = ?
  .
END.
find first buf_Dis-cfg-rule no-lock where
          buf_Dis-cfg-rule.templ-rl-root = loc_dis-rule.templ-rl-root
     and  buf_Dis-cfg-rule.table-name = '':U
     and  buf_Dis-cfg-rule.pos-type = '':U
     and  buf_Dis-cfg-rule.discnt-role = '':U
     and  buf_Dis-cfg-rule.self-nonunique = '':U
     and buf_Dis-cfg-rule.time-templ-rl-root = 0 no-error .
if error-status:error then do:
end.
if loc_dis-rule.rule-num > 99999 then do:
  assign
  v-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
  v-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                else '')
  p-using-fields = (if loc_dis-rule.upper-rule-num <= 99999
                  then v-level-1
                  else v-level-2).
  ASSIGN
  p-display-time-rule-num = (if p-display-time-rule-num = "...    "
                             then p-display-time-rule-num
                             else (if lookup("time-rule-num", p-using-fields) = 0
                                  then "":U
                                  else string(loc_dis-rule.time-rule-num))
                            )
  p-display-dis-kat =  (if p-display-dis-kat = "...    "
                        then p-display-dis-kat
                        else  (if lookup("dis-kat", p-using-fields) = 0
                                then "":U else string(loc_dis-rule.dis-kat))
                                )
  p-display-doc-qnty = (if p-display-doc-qnty = "...    "
                        then p-display-doc-qnty
                        else (if lookup("doc-qnty", p-using-fields) = 0
                              then "":U else string(loc_dis-rule.doc-qnty))
                        )
  p-display-tot-sum  = (if p-display-tot-sum = "...    "
                        then p-display-tot-sum
                        else (if lookup("tot-sum", p-using-fields) = 0
                             then "":U else string(loc_dis-rule.tot-sum))
                        )
  p-display-discnt-value = (if p-display-discnt-value = "...    "
                            then p-display-discnt-value
                            else (if loc_dis-rule.value-type = integer('1':U)
                                  then STRING(loc_dis-rule.discnt-value, "->9.99%")
                                  else STRING(loc_dis-rule.discnt-value))
                            )
  p-display-charkey_one = (if p-display-charkey_one = "...    "
                           then p-display-charkey_one
                           else (if lookup("charkey_one", p-using-fields) = 0
                                then "":U else string(loc_dis-rule.charkey_one))
                           )
  p-display-charkey_two = (if p-display-charkey_two = "...    "
                           then p-display-charkey_two
                           else (if lookup("charkey_two", p-using-fields) = 0
                                then "":U else string(loc_dis-rule.charkey_two))
                           )
  p-display-charkey_three = (if p-display-charkey_three = "...    "
                             then p-display-charkey_three
                             else (if lookup("charkey_three", p-using-fields) = 0
                                  then "":U else string(loc_dis-rule.charkey_three))
                             )
  p-display-deckey_one = (if p-display-deckey_one = "...    "
                          then p-display-deckey_one
                          else (if lookup("deckey_one", p-using-fields) = 0
                                then "":U else string(loc_dis-rule.deckey_one))
                          )
  p-display-deckey_two = (if p-display-deckey_two = "...    "
                          then p-display-deckey_two
                          else (if lookup("deckey_two", p-using-fields) = 0
                               then "":U else string(loc_dis-rule.deckey_two))
                          )
  p-display-deckey_three = (if p-display-deckey_three = "...    "
                            then p-display-deckey_three
                            else (if lookup("deckey_three", p-using-fields) = 0
                               then "":U else string(loc_dis-rule.deckey_three))
                           )
  p-display-key#_one = (if p-display-key#_one = "...    "
                        then p-display-key#_one
                        else (if lookup("key#_one", p-using-fields) = 0
                              then "":U else string(loc_dis-rule.key#_one))
                        )
  p-display-key#_two = (if p-display-key#_two = "...    "
                        then p-display-key#_two
                        else (if lookup("key#_two", p-using-fields) = 0
                             then "":U else string(loc_dis-rule.key#_two))
                        )
  p-display-key#_three = (if p-display-key#_three = "...    "
                          then  p-display-key#_three
                          else (if lookup("key#_three", p-using-fields) = 0
                               then "":U else string(loc_dis-rule.key#_three))
                          )
  .
end.
END PROCEDURE.
PROCEDURE main-proc :
define variable  vget-des     as character no-undo .
define variable  vget-dis-kat           like ub.dis-rule.dis-kat           no-undo .
define variable  vget-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  vget-doc-qnty          like ub.dis-rule.doc-qnty          no-undo .
define variable  vget-tot-sum           like ub.dis-rule.tot-sum           no-undo .
define variable  vget-charkey_one       like ub.dis-rule.charkey_one       no-undo .
define variable  vget-charkey_two       like ub.dis-rule.charkey_two       no-undo .
define variable  vget-charkey_theree    like ub.dis-rule.charkey_three     no-undo .
define variable  vget-key#_one          like ub.dis-rule.key#_one          no-undo .
define variable  vget-key#_two          like ub.dis-rule.key#_two          no-undo .
define variable  vget-key#_theree       like ub.dis-rule.key#_three        no-undo .
define variable  vget-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  vget-time-rule-num     like ub.dis-rule.time-rule-num     no-undo .
define variable  vget-upper-rule-num    like ub.dis-rule.upper-rule-num    no-undo .
define variable  vget-value-type        like ub.dis-rule.value-type        no-undo .
define variable  vget-global            as integer no-undo .
define variable  vget-host              as integer no-undo .
define variable  vget-object            as integer no-undo .
define variable  vget-output-display as logical   no-undo .
define variable  vget-tree            as character no-undo .
define variable  vget-other          as character no-undo .
define buffer get_dis-rule for ub.dis-rule.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_tt0-template_dis-rule for tt0-template_dis-rule.
if not (p-curr-obj-type = "":U and p-curr-obj-code = 0)
 OR p-mode = "upper-rule-num-gds-obj"
 or p-mode  = "dis-gds-rule-gds-obj"
 or p-mode = "cd-obj"
 then do:
  find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-curr-obj-type
       AND X_curr_clients.obj-code = p-curr-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-obj-type p-curr-obj-code"
    p-curr-obj-type p-curr-obj-code
    view-as alert-box ERROR.
    return error .
  end.
 end.
 if LOOKUP(p-mode,  ('все':U + chr(4) +
                    "upper-rule-num":U + chr(4) +
                    "upper-rule-num-object":U + chr(4) +
                    "upper-rule-num-all-obj":U + chr(4) +
                    "upper-rule-num-host":U + chr(4) +
                    "upper-rule-num-global":U + chr(4) +
                    "upper-rule-num-gds-obj":U + chr(4) +
                    "template":U + chr(4) +
                    "time-rule-num" + chr(4) +
                    'объект':U),
                chr(4)) = 0
    and entry(1, p-mode, "=") <> 'dis-gds-rule':U
    and entry(1, p-mode, "=") <> "dis-gds-rule-gds-obj":U
    and entry(1, p-mode, "=") <> "cd-obj":U
    and entry(1, p-mode, "=") <> 'dis-dc-rule':U
    and entry(1, p-mode, "=") <> 'dis-dct-rule':U
    and entry(1, p-mode, "=") <> 'dis-cp-rule':U
    and entry(1, p-mode, "=") <> 'dis-grp-rule':U
    and entry(1, p-mode, "=") <> 'dis-some-rule':U
    and entry(1, p-mode, "=") <> "template-value-type"
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 if entry(1, p-mode, "=":U) = "template-value-type" then do:
   assign
   p-value-type = entry(2, p-mode, "=":U)
   no-error .
   p-mode = entry(1, p-mode, "=":U).
 end.
 IF entry(1, p-mode, "=":U) = 'dis-gds-rule':U
 or entry(1, p-mode, "=":U) = "dis-gds-rule-gds-obj" then do:
   assign
   v-discnt-role = entry(2, p-mode, "=":U)
   no-error .
   for each buf_dis-cfg-rule no-lock where
          buf_dis-cfg-rule.table-name = 'dis-gds-rule':U
      and buf_dis-cfg-rule.discnt-role = v-discnt-role  :
     if p-time-templ-rl-root <> -1
     and buf_dis-cfg-rule.time-templ-rl-root <> p-time-templ-rl-root then do:
       next.
     end.
     create buf_tt0-template_dis-rule.
     buffer-copy buf_dis-cfg-rule to
     buf_tt0-template_dis-rule.
   end.
   if entry(1, p-mode, "=":U) = 'dis-gds-rule':U then do:
     assign
     p-mode = 'dis-gds-rule':U.
   end.
 end.
 IF entry(1, p-mode, "=":U) = 'dis-cp-rule':U
 or entry(1, p-mode, "=":U) = 'dis-dc-rule':U
 or entry(1, p-mode, "=":U) = 'dis-dct-rule':U
 or entry(1, p-mode, "=":U) = 'dis-grp-rule':U
 or entry(1, p-mode, "=":U) = 'dis-some-rule':U
 then do:
   if num-entries(p-mode, "=") > 2 then do:
     v-region = entry(3, p-mode, "=").
   end.
   assign
   v-discnt-role = entry(2, p-mode, "=":U)
   p-mode = entry(1, p-mode, "=":U)
   no-error .
   for each buf_dis-cfg-rule no-lock where
          buf_dis-cfg-rule.table-name = p-mode
      and buf_dis-cfg-rule.discnt-role = v-discnt-role :
     if p-time-templ-rl-root <> -1
     and buf_dis-cfg-rule.time-templ-rl-root <> p-time-templ-rl-root then do:
       next.
     end.
     create buf_tt0-template_dis-rule.
     buffer-copy buf_dis-cfg-rule to
     buf_tt0-template_dis-rule.
   end.
 end.
 IF entry(1, p-mode, "=":U) = "cd-obj"
 THEN DO:
   assign
   v-cd = entry(2, p-mode, "=":U)
   p-mode = entry(1, p-mode, "=":U)
   .
    for each buf_dis-cfg-rule no-lock where
          buf_dis-cfg-rule.pos-type = v-cd :
     if p-time-templ-rl-root <> -1
     and buf_dis-cfg-rule.time-templ-rl-root <> p-time-templ-rl-root then do:
       next.
     end.
     create buf_tt0-template_dis-rule.
     buffer-copy buf_dis-cfg-rule to
     buf_tt0-template_dis-rule.
   end.
 END.
  if p-mode = "upper-rule-num"
  or p-mode = "upper-rule-num-object"
  or p-mode = "upper-rule-num-all-obj"
  or p-mode = "upper-rule-num-gds-obj"
  or p-mode = "upper-rule-num-host"
  or p-mode = "upper-rule-num-global"
  then do:
   find first X_upper-dis-rule no-lock where
          X_upper-dis-rule.rule-num = p-upper-rule-num no-error.
   if not available X_upper-dis-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-upper-rule-num"
    p-upper-rule-num
    view-as alert-box ERROR.
    return error .
   end.
   if X_upper-dis-rule.rule-num > 99999
   and (lookup(bttns, "b-sel") > 0 or lookup(bttns, "b-mark") > 0) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова bttn или p-upper-rule-num"
    bttns p-upper-rule-num
    view-as alert-box ERROR.
    return error .
   end.
  end.
  if p-mode = "time-rule-num" then do:
   find first X_dis-time-rule no-lock where
          X_dis-time-rule.time-rule-num = p-time-templ-rl-root no-error.
   if not available X_dis-time-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-upper-rule-num"
    p-upper-rule-num
    view-as alert-box ERROR.
    return error .
   end.
  end.
  if p-mode = "upper-rule-num-gds-obj"
  or p-mode = "dis-gds-rule-gds-obj"
  then do:
    find first X_bar-code no-lock where
              X_bar-code.b-code = p-b-code no-error.
    if not available X_bar-code then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-b-code" p-b-code
      view-as alert-box ERROR.
      return error .
    end.
    find first X_goods no-lock where
             X_goods.gds-code = x_bar-code.gds-code no-error .
    if not available X_goods then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-b-code" p-b-code skip
      "Не найден товар для бар-кода" p-b-code
      view-as alert-box ERROR.
      return error .
    end.
  end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
 run fill-tables in this-procedure no-error.
 if error-status:error then  undo, return error .
 RUN MyEnable in this-procedure .
 assign
 v-doc-rec = integer(entry(1, v-rid-list))
 .
 RUn OpenBR IN THIS-PROCEDURE ( input YES, input NO, input '':U).
 if v-doc-rec <> ?
 and v-doc-rec <> 0
 then do:
   reposition br-dis-rule to recid v-doc-rec no-error.
   apply "ENTRY" to br-dis-rule in frame Dialog-Frame .
   APPLY "VALUE-CHANGED" to br-dis-rule.
 end.
 HIDE mark-num in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-host-code like ub.sysconf.host-code no-undo .
DEFINE VARIABLE v-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-global            as integer no-undo .
define variable  v-host              as integer no-undo .
define variable  v-object            as integer no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-tree              as character no-undo .
define variable  v-other          as character no-undo .
DEFINE VARIABLE v-doc-num LIKE ub.price-list.doc-num NO-UNDO.
DEFINE VARIABLE v-road-tax LIKE ub.price-list.road-tax NO-UNDO.
DEFINE VARIABLE v-excise LIKE ub.price-list.excise NO-UNDO.
DEFINE VARIABLE ii AS INTEGer NO-UNDO.
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-curr-level as character no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable v-h as handle no-undo .
define variable v-real-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
if p-upper-rule-num <> ?
and  p-upper-rule-num <> 0 then do:
  v-templ-rl-root = (if p-upper-rule-num <= 99999
                     then p-upper-rule-num
                     else X_upper-dis-rule.templ-rl-root).
  run dr-code  in this-procedure (
                                   input  v-templ-rl-root
                                  ,output v-des
                                  ,output v-discnt-type
                                  ,output v-subject-type
                                  ,output v-value-type
                                  ,output v-level-1
                                  ,output v-level-2
                                  ,OUTPUT v-global
                                  ,OUTPUT v-host
                                  ,OUTPUT v-object
                                  ,output v-output-display
                                  ,output v-tree
                                  ,output v-other
                                                            )  NO-ERROR.
  run disrules-fill-properties in this-procedure ( input v-templ-rl-root).
end.
ASSIGN
b-lookup:MENU-MOUSE IN FRAME Dialog-Frame = 1
X_dis-rule.des:resizable in browse br-dis-rule = yes
.
assign
v-list-items = "":U + chr(44) + "":U.
DO v-ii = 1 TO NUM-ENTRIES('IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U):
    ASSIGN
    v-list-items = v-list-items +  chr(44) +
                   ENTRY(v-ii, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,MARIA,Накладная,Бэкофис':U) + chr(44) +
                   ENTRY(v-ii, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U).
END.
assign
cb-pos-type:list-item-pairs in frame Dialog-Frame = v-list-items.
IF v-cd > '':U THEN DO:
   ASSIGN
   cb-pos-type = v-cd.
END.
IF p-mode = "upper-rule-num-gds-obj"
or p-mode = "dis-gds-rule-gds-obj"
THEN DO:
  if X_upper-dis-rule.value-type = integer('1':U) then do:
    tt-dis-rule-bc.discnt-value:LABEL in browse br-gds-obj =
    tt-dis-rule-bc.discnt-value:LABEL in browse br-gds-obj + "%".
  end.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,input  p-b-code
  ,input  0
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
  ASSIGN
  tt-dis-rule-bc.doc-qnty:VISIBLE IN BROWSE br-gds-obj = NO
  tt-dis-rule-bc.sum-brutto:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.sum-discnt:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.sum-netto:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.tot-sum:VISIBLE IN BROWSE br-gds-obj = NO
  tt-dis-rule-bc.dis-kat:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.charkey_one:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.charkey_two:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.charkey_three:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.key#_one:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.key#_two:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.key#_three:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.d-pcnt:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.sale-qnty:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.time-rule-num:VISIBLE IN BROWSE br-gds-obj = no
  .
  v-h = br-gds-obj:FIRST-COLUMN IN FRAME Dialog-Frame.
  DO while valid-handle(v-h) :
    if lookup(v-h:name, v-level-1) > 0
    or lookup(v-h:name, v-level-2) > 0
    then do:
      ASSIGN
      v-h:visible = yes
      .
      find first buf_temp-drt-prop no-lock where
                buf_temp-drt-prop.templ-rl-root = v-templ-rl-root
            and buf_temp-drt-prop.upper-prop-code = v-h:name
            and buf_temp-drt-prop.prop-code = "column-label" no-error.
      if available buf_temp-drt-prop then do:
        assign
        v-h:label = buf_temp-drt-prop.property-value.
      end.
      find first buf_temp-drt-prop no-lock where
                buf_temp-drt-prop.templ-rl-root = v-templ-rl-root
            and buf_temp-drt-prop.upper-prop-code = v-h:name
            and buf_temp-drt-prop.prop-code = "format":U no-error.
      if available buf_temp-drt-prop then do:
        assign
        v-h:format = buf_temp-drt-prop.property-value.
      end.
      case v-h:name:
        when "doc-qnty" then do:
          assign
          tt-dis-rule-bc.sum-brutto:VISIBLE IN BROWSE br-gds-obj = YES
          tt-dis-rule-bc.sum-discnt:VISIBLE IN BROWSE br-gds-obj = YES
          tt-dis-rule-bc.sum-netto:VISIBLE IN BROWSE br-gds-obj = YES
           .
         end.
         when "tot-sum" then do:
           assign
          tt-dis-rule-bc.sale-qnty:VISIBLE IN BROWSE br-gds-obj = YES
          tt-dis-rule-bc.doc-qnty:VISIBLE IN BROWSE br-gds-obj = YES
          tt-dis-rule-bc.sum-brutto:VISIBLE IN BROWSE br-gds-obj = YES
          tt-dis-rule-bc.sum-discnt:VISIBLE IN BROWSE br-gds-obj = YES
          tt-dis-rule-bc.sum-netto:VISIBLE IN BROWSE br-gds-obj = YES
          .
         end.
       end case.
    end.
    v-h = v-h:NEXT-COLUMN.
  END.
  if X_upper-dis-rule.value-type <> integer('1':U) then
  tt-dis-rule-bc.d-pcnt:VISIBLE IN BROWSE br-gds-obj = YES.
END.
ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME Dialog-Frame
                       = "Использ&+" + chr(44) +  '0':U + chr(44) +
                       "Все&!" + chr(44) + 'все':U + chr(44) +
                        "Неиспольз&-" + chr(44) + '1':U
rs-sts = (IF p-sts = -1 THEN 'все':U ELSE string(p-sts))
.
if not (p-curr-obj-type = "":U and p-curr-obj-code = 0) then do:
  if p-curr-obj-type = 'орг':U then do:
    assign
    v-host-code = p-curr-obj-code
    v-obj-type = v-cntxt-obj-type
    v-obj-code = v-cntxt-obj-code
    .
  end.
  else do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
  assign
  v-obj-type = p-curr-obj-type
  v-obj-code = p-curr-obj-code
  .
end.
end.
else do:
  assign
  v-host-code = v-cntxt-host-code-obj
  v-obj-type = v-cntxt-obj-type
  v-obj-code = v-cntxt-obj-code
  .
end.
assign
b-add:MENU-MOUSE in frame Dialog-Frame = 1
b-copy:MENU-MOUSE in frame Dialog-Frame = 1
menu-item m_global:sensitive in menu menu-b-add = (if  v-cntxt-db-num = 0 then yes else no)
menu-item m_host:sensitive in menu menu-b-add = (if v-cntxt-db-num = 0 then yes else no)
menu-item m_object:sensitive in menu menu-b-add = yes
menu-item m_host:label in menu menu-b-add = "Фирма" + chr(32) + string(v-host-code)
menu-item m_object:label in menu menu-b-add = v-obj-type + string(v-obj-code)
menu-item m_global-copy:sensitive in menu menu-b-copy = (if  v-cntxt-db-num = 0 then yes else no)
menu-item m_host-copy:sensitive in menu menu-b-copy = (if v-cntxt-db-num = 0 then yes else no)
menu-item m_object-copy:sensitive in menu menu-b-copy = yes
menu-item m_host-copy:label in menu menu-b-copy = "Фирма" + chr(32) + string(v-host-code)
menu-item m_object-copy:label in menu menu-b-copy = v-obj-type + string(v-obj-code)
.
IF p-upper-rule-num = ?
or p-upper-rule-num = 0
or p-upper-rule-num > 99999 then do:
  ASSIGN
  MENU-ITEM m_global :SENSITIVE IN MENU menu-b-add = NO
  MENU-ITEM m_host :SENSITIVE IN MENU menu-b-add = NO
  MENU-ITEM m_object :SENSITIVE IN MENU menu-b-add = NO
  MENU-ITEM m_global-copy :SENSITIVE IN MENU menu-b-copy = NO
  MENU-ITEM m_host-copy :SENSITIVE IN MENU menu-b-copy = NO
  MENU-ITEM m_object-copy :SENSITIVE IN MENU menu-b-copy = NO
  .
END.
ELSE DO:
  ASSIGN
  MENU-ITEM m_global :SENSITIVE IN MENU menu-b-add = (v-global > 0 AND v-cntxt-db-num = 0)
  MENU-ITEM m_host :SENSITIVE IN MENU menu-b-add = (v-host > 0 AND v-cntxt-db-num = 0)
  MENU-ITEM m_object :SENSITIVE IN MENU menu-b-add = (v-object > 0)
  MENU-ITEM m_global-copy :SENSITIVE IN MENU menu-b-copy = (v-global > 0 AND v-cntxt-db-num = 0)
  MENU-ITEM m_host-copy :SENSITIVE IN MENU menu-b-copy = (v-host > 0 AND v-cntxt-db-num = 0)
  MENU-ITEM m_object-copy:SENSITIVE IN MENU menu-b-copy = (v-object > 0)
  .
END.
if p-mode = 'объект':U
or p-mode = "template" then do:
   assign
   MENU-ITEM m_global-copy :SENSITIVE IN MENU menu-b-copy =  no
   MENU-ITEM m_host-copy :SENSITIVE IN MENU menu-b-copy = no
   MENU-ITEM m_object-copy:SENSITIVE IN MENU menu-b-copy = no
   .
end.
if p-mode = "template" then do:
  MENU-ITEM m_list-copy:label IN MENU menu-b-copy =  "Правила скидок этого типа на другие объекты по списку".
end.
if p-mode = 'объект':U then do:
  MENU-ITEM m_list-copy:label IN MENU menu-b-copy =  "Скидки, действующие на этом объекте на другие объекты по списку".
end.
IF p-mode <> "upper-rule-num-gds-obj"
and p-mode <> "dis-gds-rule-gds-obj"
THEN DO:
  ASSIGN
   br-dis-rule:HEIGHT = br-dis-rule:height * 2.
END.
DISPLAY mark-num
rs-sts
br-gds-obj WHEN (p-mode = "upper-rule-num-gds-obj" or p-mode = "dis-gds-rule-gds-obj")
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-add when LOOKUP("b-add":U, bttns) > 0 and
(p-mode = "upper-rule-num":U OR
 p-mode = "upper-rule-num-object":U OR
 p-mode = "upper-rule-num-all-obj":U OR
 p-mode = "upper-rule-num-gds-obj":U or
 p-mode = "upper-rule-num-host":U or
 p-mode = "upper-rule-num-global":U
 )
    AND X_upper-dis-rule.upper-rule-num  = 0 AND p-upper-rule-num <> 0
and not TRANSACTION
B-copy when ((LOOKUP("b-add":U, bttns) > 0 and
(p-mode = "upper-rule-num":U OR
 p-mode = "upper-rule-num-object":U OR
 p-mode = "upper-rule-num-all-obj":U OR
 p-mode = "upper-rule-num-gds-obj":U or
 p-mode = "upper-rule-num-host":U or
 p-mode = "upper-rule-num-global":U
 )
    AND X_upper-dis-rule.upper-rule-num  = 0 AND p-upper-rule-num <> 0)
    or p-mode = 'объект':U or p-mode = "template")
and not TRANSACTION
B-lookup
B-chg when LOOKUP("b-add":U, bttns) > 0 and
     (p-mode = "upper-rule-num":U OR
 p-mode = "upper-rule-num-object":U OR
 p-mode = "upper-rule-num-all-obj":U OR
 p-mode = "upper-rule-num-gds-obj":U OR
 p-mode = "upper-rule-num-global":U OR
 p-mode = "upper-rule-num-host":U
 )
   AND X_upper-dis-rule.upper-rule-num  = 0 AND p-upper-rule-num <> 0
and not TRANSACTION
B-del when LOOKUP("b-add":U, bttns) > 0 and
    (p-mode = "upper-rule-num":U OR
p-mode = "upper-rule-num-object":U OR
p-mode = "upper-rule-num-all-obj":U OR
p-mode = "upper-rule-num-gds-obj":U OR
p-mode = "upper-rule-num-global":U OR
p-mode = "upper-rule-num-host":U
)
AND X_upper-dis-rule.upper-rule-num  = 0 AND p-upper-rule-num <> 0
and not TRANSACTION
B-print
B-Help
b-history
b-stat when LOOKUP("b-add", bttns) > 0
and
 (p-mode = "upper-rule-num":U OR
  p-mode = "upper-rule-num-object":U OR
  p-mode = "upper-rule-num-all-obj":U OR
  p-mode = "upper-rule-num-gds-obj":U OR
p-mode = "upper-rule-num-global":U OR
p-mode = "upper-rule-num-host":U
  )
  and not TRANSACTION
B-dis-rules WHEN p-mode = "template":U or p-mode = "template-value-type" OR p-upper-rule-num = 0 or v-tree <> "":U
br-dis-rule
b-time-rule when
    not ((p-mode = "upper-rule-num"
         or
         p-mode = "upper-rule-num-object"
         or
         p-mode = "upper-rule-num-all-obj"
         or
         p-mode = "upper-rule-num-gds-obj"
         or
         p-mode = "upper-rule-num-global"
         or
         p-mode = "upper-rule-num-host")
         and X_upper-dis-rule.time-rule-num = 0
        )
b-sch
mark-num
rs-sts when not (p-mode = "template":U
                 or p-mode = "template-value-type"
                 or (p-upper-rule-num = 0 and p-mode = "upper-rule-num":U)
                 or
                  (p-mode =  "upper-rule-num":U
                  and X_upper-dis-rule.rule-num > 99999)
                  )
with FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
IF not (p-mode = "template":U
        or
        p-mode = "template-value-type")
or p-upper-rule-num <> 0 THEN DO:
  assign
  b-dis-rules:label in frame Dialog-Frame = "Детально"
  .
END.
if p-mode = "template"
or p-mode = "template-value-type"
or (p-upper-rule-num = 0  and p-mode = "upper-rule-num":U)
then do:
  DISABLE
  rs-sts
  with FRAME Dialog-Frame.
end.
assign
v-display-discnt-value:visible in browse br-dis-rule = no
v-display-dis-kat:visible in browse br-dis-rule = no
v-display-doc-qnty:visible in browse br-dis-rule = no
v-display-tot-sum:visible in browse br-dis-rule = no
v-display-time-rule-num:visible in browse br-dis-rule = no
v-display-charkey_one:visible in browse br-dis-rule = no
v-display-charkey_two:visible in browse br-dis-rule = no
v-display-charkey_three:visible in browse br-dis-rule = no
v-display-deckey_one:visible in browse br-dis-rule = no
v-display-deckey_two:visible in browse br-dis-rule = no
v-display-deckey_three:visible in browse br-dis-rule = no
v-display-key#_one:visible in browse br-dis-rule = no
v-display-key#_two:visible in browse br-dis-rule = no
v-display-key#_three:visible in browse br-dis-rule = no
.
case p-mode:
  when "template"
  or
  when 'все':U
  or
  when "template-value-type"
  then do:
  end.
  otherwise do:
    if p-upper-rule-num = 0
    or p-upper-rule-num = ?
    then do:
    end.
    else do:
      if p-upper-rule-num <= 99999 then do:
        v-curr-level = v-level-1.
      end.
      else do:
        v-curr-level = v-level-2.
      end.
      v-h = br-dis-rule:FIRST-COLUMN IN FRAME Dialog-Frame.
      DO while valid-handle(v-h) :
        v-real-name = replace(v-h:name, "v-display-", "").
        if lookup(v-real-name, v-curr-level) > 0
        then do:
          ASSIGN
          v-h:visible = yes
          .
          find first buf_temp-drt-prop no-lock where
                    buf_temp-drt-prop.templ-rl-root = v-templ-rl-root
                and buf_temp-drt-prop.upper-prop-code = v-real-name
                and buf_temp-drt-prop.prop-code = "column-label" no-error.
          if available buf_temp-drt-prop then do:
            assign
            v-h:label = buf_temp-drt-prop.property-value.
          end.
          find first buf_temp-drt-prop no-lock where
                    buf_temp-drt-prop.templ-rl-root = v-templ-rl-root
                and buf_temp-drt-prop.upper-prop-code = v-real-name
                and buf_temp-drt-prop.prop-code = "format":U no-error.
          if available buf_temp-drt-prop then do:
            assign
            v-h:format = buf_temp-drt-prop.property-value.
          end.
        end.
        v-h = v-h:NEXT-COLUMN.
      end.
    end.
  end.
end case.
IF p-mode <> "upper-rule-num-gds-obj"
and p-mode <> "dis-gds-rule-gds-obj"
THEN DO:
   HIDE br-gds-obj
   IN FRAME Dialog-Frame.
END.
else do:
  enable
  BR-gds-obj
  with frame Dialog-Frame .
end.
if p-mode = "upper-rule-num" and X_upper-dis-rule.rule-num > 99999 then do:
  HIDE
  b-add
  b-copy
  b-chg
  b-del
  b-stat
  IN FRAME Dialog-Frame.
end.
IF v-cd = '':U THEN DO:
   enable
   cb-pos-type
   WITH FRAME Dialog-Frame.
END.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo init "Правила скидок".
define variable v-jj as integer   no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
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
if not( p-curr-obj-type = "":U and p-curr-obj-code = 0 ) then do:
  if p-curr-obj-type = 'орг':U then do:
    assign
    p-host-code = p-curr-obj-code
    .
  end.
  else do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output p-host-code
  )  .
end.
end.
define variable l-open-query as logical   no-undo .
CASE p-mode :
  WHEN 'все':U        THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1", filter-label0)
    .
    if v-cd <> '':U then
        ASSIGN
        frame Dialog-Frame:TITLE = substitute("&1 для POS &2", v-cd).
    IF p-sts = -1  THEN DO:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-40  as logical   no-undo .
define variable  l-filter-open-40    as logical   .
define variable  flt-rec-40       as recid     no-undo .
define variable  filter-name-40      as character no-undo .
define variable  where-phrase-40     as character no-undo .
define variable  sort-phrase-40      as character no-undo .
define variable  where-phrase-rus-40 as character no-undo .
define variable  sort-phrase-rus-40  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-40
  ,output filter-name-40
  ,output where-phrase-40
  ,output sort-phrase-40
  ,output where-phrase-rus-40
  ,output sort-phrase-rus-40
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-40
      ) no-error .
  assign
    l-filter-open-40 = false
  .
  if flt-rec-40 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-40 as character no-undo .
    define variable  parameter-3-40 as character no-undo .
    define variable  parameter-4-40 as character no-undo .
    define variable  parameter-5-40 as character no-undo .
    define variable  parameter-6-40 as character no-undo .
    define variable  parameter-7-40 as character no-undo .
      assign
      parameter-3-40 =
                              "FOR EACH X_dis-rule"
      parameter-4-40 =
        (
          if (" TRUE " + " " + where-phrase-40) <> ""
          then " TRUE " + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-40 = if sort-phrase-40 = ''
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
        " " + sort-phrase-40
        )
      parameter-7-40 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-40 =
          (" TRUE " + " " + where-phrase-40 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input parameter-3-40
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ,input parameter-6-40
                          ,input parameter-7-40
                          )
      .
      assign
        l-filter-open-40 = true
      .
    end.
    if l-filter-open-40 = false then do:
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
  if l-filter-open-40 = false then do:
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where  TRUE
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-4-40 =
        "where ":u + " TRUE " + " ":u + where-phrase-40 + " ":u + p-find-condition + " " + ""
      parameter-5-40 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-40 = (if p-find-next then "true":u else "false":u )
      parameter-3-40 =  "FOR EACH X_dis-rule"
      parameter-4-40 =
        (
          if (" TRUE " + " " + where-phrase-40) <> ""
          then " TRUE " + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-40 = if sort-phrase-40 = ''
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
        " " + sort-phrase-40
        )
      parameter-7-40 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input logical(parameter-2-40)
                          ,input no-lock
                          ,input parameter-3-40
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ,input parameter-6-40
                          ,input parameter-7-40
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
    ELSE DO:
      if v-cd = '':U then do:
        ASSIGN
        frame Dialog-Frame:TITLE = substitute("&1 &2", title0, entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U)).
      end.
      else do:
        ASSIGN
        frame Dialog-Frame:TITLE = substitute("&1 &2 для POS &3", title0, entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U), v-cd).
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
                              "FOR EACH X_dis-rule"
      parameter-4-42 =
        (
          if (" X_dis-rule.sts = p-sts " + " " + where-phrase-42) <> ""
          then  substitute('X_dis-rule.sts = &1', p-sts ) + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-42 = if sort-phrase-42 = ''
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
          (" X_dis-rule.sts = p-sts " + " " + where-phrase-42 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where  X_dis-rule.sts = p-sts
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-42 = (if p-find-next then "true":u else "false":u )
      parameter-4-42 =
        "where ":u +  substitute('X_dis-rule.sts = &1', p-sts ) + " ":u + where-phrase-42 + " ":u + p-find-condition + " " + ""
      parameter-5-42 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-42)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-42 =  "FOR EACH X_dis-rule"
      parameter-4-42 =
        (
          if (" X_dis-rule.sts = p-sts " + " " + where-phrase-42) <> ""
          then  substitute('X_dis-rule.sts = &1', p-sts ) + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-42 = if sort-phrase-42 = ''
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
        " " + sort-phrase-42
        )
      parameter-7-42 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    END.
  END.
  WHEN "upper-rule-num":U THEN DO:
    filter-point = filter-point0 + p-mode.
    filter-label = substitute("&1", filter-label0) .
    if X_upper-dis-rule.rule-num > 99999 then do:
      ASSIGN
      frame Dialog-Frame:TITLE =
                                  substitute(" Правило скидок №&1: &2: Детализация"
                                  , X_upper-dis-rule.rule-num
                                  , X_upper-dis-rule.des
                                  )
                                  .
    end.
    else do:
      if v-cd = '':U then
      ASSIGN
      frame Dialog-Frame:TITLE =
                                  substitute(" Правила скидок типа: &1 &2"
                                  , X_upper-dis-rule.des
                                  , (if p-sts = -1 then "":U else  entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
                                  )
                                  .
      else
      ASSIGN
      frame Dialog-Frame:TITLE =
                                  substitute(" Правила скидок типа: &1 POS &2 &3"
                                  , X_upper-dis-rule.des
                                  , v-cd
                                  , (if p-sts = -1 then "":U else  entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
                                  )
                                  .
    end.
    IF p-sts = -1 THEN DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-44 =
        (
          if ("           X_dis-rule.upper-rule-num  = p-upper-rule-num           and ((p-time-templ-rl-root = -1) or (X_dis-rule.time-templ-rl-root = p-time-templ-rl-root))                        " + " " + where-phrase-44) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1           and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) ', p-upper-rule-num, p-time-templ-rl-root )  + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-44 = if sort-phrase-44 = ''
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
          ("           X_dis-rule.upper-rule-num  = p-upper-rule-num           and ((p-time-templ-rl-root = -1) or (X_dis-rule.time-templ-rl-root = p-time-templ-rl-root))                        " + " " + where-phrase-44 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where            X_dis-rule.upper-rule-num  = p-upper-rule-num           and ((p-time-templ-rl-root = -1) or (X_dis-rule.time-templ-rl-root = p-time-templ-rl-root))
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-4-44 =
        "where ":u +  substitute(' X_dis-rule.upper-rule-num  = &1           and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) ', p-upper-rule-num, p-time-templ-rl-root )  + " ":u + where-phrase-44 + " ":u + p-find-condition + " " + ""
      parameter-5-44 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-44 =  "FOR EACH X_dis-rule"
      parameter-4-44 =
        (
          if ("           X_dis-rule.upper-rule-num  = p-upper-rule-num           and ((p-time-templ-rl-root = -1) or (X_dis-rule.time-templ-rl-root = p-time-templ-rl-root))                        " + " " + where-phrase-44) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1           and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) ', p-upper-rule-num, p-time-templ-rl-root )  + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-44 = if sort-phrase-44 = ''
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
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    END.
    ELSE DO:
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
if p-open-query then do:
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
                              "FOR EACH X_dis-rule"
      parameter-4-46 =
        (
          if ("             X_dis-rule.upper-rule-num  = p-upper-rule-num                and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)             AND X_dis-rule.sts = p-sts " + " " + where-phrase-46) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1                and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2))             AND X_dis-rule.sts = &3 ', p-upper-rule-num, p-time-templ-rl-root, p-sts) + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-46 = if sort-phrase-46 = ''
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
        " " + sort-phrase-46
        )
      parameter-7-46 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-46 =
          ("             X_dis-rule.upper-rule-num  = p-upper-rule-num                and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)             AND X_dis-rule.sts = p-sts " + " " + where-phrase-46 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where              X_dis-rule.upper-rule-num  = p-upper-rule-num                and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)             AND X_dis-rule.sts = p-sts
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-4-46 =
        "where ":u +  substitute(' X_dis-rule.upper-rule-num  = &1                and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2))             AND X_dis-rule.sts = &3 ', p-upper-rule-num, p-time-templ-rl-root, p-sts) + " ":u + where-phrase-46 + " ":u + p-find-condition + " " + ""
      parameter-5-46 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-3-46 =  "FOR EACH X_dis-rule"
      parameter-4-46 =
        (
          if ("             X_dis-rule.upper-rule-num  = p-upper-rule-num                and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)             AND X_dis-rule.sts = p-sts " + " " + where-phrase-46) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1                and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2))             AND X_dis-rule.sts = &3 ', p-upper-rule-num, p-time-templ-rl-root, p-sts) + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-46 = if sort-phrase-46 = ''
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
        " " + sort-phrase-46
        )
      parameter-7-46 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input parameter-3-46
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ,input parameter-6-46
                          ,input parameter-7-46
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
  END.
  WHEN "upper-rule-num-object":U THEN DO:
      filter-point = filter-point0 + p-mode.
      filter-label = substitute("&1 для одного объекта", filter-label0).
      if X_upper-dis-rule.rule-num > 99999
      then
      ASSIGN
      frame Dialog-Frame:TITLE =
                                  substitute("&1&2 Правило скидок №&3: &4: Детализация"
                                  , p-curr-obj-type
                                  , p-curr-obj-code
                                  , X_upper-dis-rule.rule-num
                                  , X_upper-dis-rule.des
                                  )
                                  .
    else
      ASSIGN
      frame Dialog-Frame:TITLE =
                                  substitute("&1&2 Правила скидок типа: &1 &3"
                                  , p-curr-obj-type
                                  , p-curr-obj-code
                                  , X_upper-dis-rule.des
                                  , (if p-sts = -1 then "":U else  entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
                                  )
                                  .
    IF p-sts = -1 THEN DO:
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
if p-open-query then do:
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
                              "FOR EACH X_dis-rule"
      parameter-4-48 =
        (
          if ("         X_dis-rule.upper-rule-num  = p-upper-rule-num           AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = p-curr-obj-type           AND X_dis-rule.obj-code = p-curr-obj-code           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                     " + " " + where-phrase-48) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1           AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&4&3           AND X_dis-rule.obj-code = &5           and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '         , p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root) + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
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
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-48 =
          ("         X_dis-rule.upper-rule-num  = p-upper-rule-num           AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = p-curr-obj-type           AND X_dis-rule.obj-code = p-curr-obj-code           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                     " + " " + where-phrase-48 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where          X_dis-rule.upper-rule-num  = p-upper-rule-num           AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = p-curr-obj-type           AND X_dis-rule.obj-code = p-curr-obj-code           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-4-48 =
        "where ":u +  substitute(' X_dis-rule.upper-rule-num  = &1           AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&4&3           AND X_dis-rule.obj-code = &5           and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '         , p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root) + " ":u + where-phrase-48 + " ":u + p-find-condition + " " + ""
      parameter-5-48 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-3-48 =  "FOR EACH X_dis-rule"
      parameter-4-48 =
        (
          if ("         X_dis-rule.upper-rule-num  = p-upper-rule-num           AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = p-curr-obj-type           AND X_dis-rule.obj-code = p-curr-obj-code           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                     " + " " + where-phrase-48) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1           AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&4&3           AND X_dis-rule.obj-code = &5           and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '         , p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root) + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
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
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input parameter-3-48
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ,input parameter-6-48
                          ,input parameter-7-48
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
    ELSE DO:
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
if p-open-query then do:
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
                              "FOR EACH X_dis-rule"
      parameter-4-50 =
        (
          if ("             X_dis-rule.upper-rule-num  = p-upper-rule-num            AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = p-curr-obj-type           AND X_dis-rule.obj-code = p-curr-obj-code           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = p-sts " + " " + where-phrase-50) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1            AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&4&3           AND X_dis-rule.obj-code = &5           and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = &7 ', p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, p-sts) + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
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
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-50 =
          ("             X_dis-rule.upper-rule-num  = p-upper-rule-num            AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = p-curr-obj-type           AND X_dis-rule.obj-code = p-curr-obj-code           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = p-sts " + " " + where-phrase-50 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where              X_dis-rule.upper-rule-num  = p-upper-rule-num            AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = p-curr-obj-type           AND X_dis-rule.obj-code = p-curr-obj-code           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = p-sts
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-50 = (if p-find-next then "true":u else "false":u )
      parameter-4-50 =
        "where ":u +  substitute(' X_dis-rule.upper-rule-num  = &1            AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&4&3           AND X_dis-rule.obj-code = &5           and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = &7 ', p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, p-sts) + " ":u + where-phrase-50 + " ":u + p-find-condition + " " + ""
      parameter-5-50 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-50)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-50 = (if p-find-next then "true":u else "false":u )
      parameter-3-50 =  "FOR EACH X_dis-rule"
      parameter-4-50 =
        (
          if ("             X_dis-rule.upper-rule-num  = p-upper-rule-num            AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = p-curr-obj-type           AND X_dis-rule.obj-code = p-curr-obj-code           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = p-sts " + " " + where-phrase-50) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1            AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&4&3           AND X_dis-rule.obj-code = &5           and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = &7 ', p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, p-sts) + " " + where-phrase-50
          else "true"
        )
      parameter-5-50 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
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
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input logical(parameter-2-50)
                          ,input no-lock
                          ,input parameter-3-50
                          ,input parameter-4-50
                          ,input parameter-5-50
                          ,input parameter-6-50
                          ,input parameter-7-50
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
  END.
  WHEN "upper-rule-num-all-obj":U THEN DO:
      filter-point = filter-point0 + p-mode.
      filter-label = substitute("&1 все для одного объекта", filter-label0).
      if X_upper-dis-rule.rule-num > 99999
      then
      ASSIGN
      frame Dialog-Frame:TITLE =
                                  substitute("&1&2 Правило скидок №&3: &4: Детализация"
                                  , p-curr-obj-type
                                  , p-curr-obj-code
                                  , X_upper-dis-rule.rule-num
                                  , X_upper-dis-rule.des
                                  )
                                  .
    else
      ASSIGN
      frame Dialog-Frame:TITLE =
                                  substitute("&1&2 Правила скидок типа: &1 &3"
                                  , p-curr-obj-type
                                  , p-curr-obj-code
                                  , X_upper-dis-rule.des
                                  , (if p-sts = -1 then "":U else  entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
                                  )
                                  .
    IF p-sts = -1 THEN DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-52 =
        (
          if ("         X_dis-rule.upper-rule-num  = p-upper-rule-num           AND ( X_dis-rule.host-code  = p-host-code   OR X_dis-rule.host-code  = 0  )         AND ( X_dis-rule.obj-type = p-curr-obj-type OR X_dis-rule.obj-type = '':U )         AND ( X_dis-rule.obj-code = p-curr-obj-code OR X_dis-rule.obj-code = 0    )         and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                     " + " " + where-phrase-52) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1           AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&4&3           AND X_dis-rule.obj-code = &5           and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '         , p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root) + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
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
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-52 =
          ("         X_dis-rule.upper-rule-num  = p-upper-rule-num           AND ( X_dis-rule.host-code  = p-host-code   OR X_dis-rule.host-code  = 0  )         AND ( X_dis-rule.obj-type = p-curr-obj-type OR X_dis-rule.obj-type = '':U )         AND ( X_dis-rule.obj-code = p-curr-obj-code OR X_dis-rule.obj-code = 0    )         and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                     " + " " + where-phrase-52 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where          X_dis-rule.upper-rule-num  = p-upper-rule-num           AND ( X_dis-rule.host-code  = p-host-code   OR X_dis-rule.host-code  = 0  )         AND ( X_dis-rule.obj-type = p-curr-obj-type OR X_dis-rule.obj-type = '':U )         AND ( X_dis-rule.obj-code = p-curr-obj-code OR X_dis-rule.obj-code = 0    )         and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-52 = (if p-find-next then "true":u else "false":u )
      parameter-4-52 =
        "where ":u +  substitute(' X_dis-rule.upper-rule-num  = &1           AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&4&3           AND X_dis-rule.obj-code = &5           and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '         , p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root) + " ":u + where-phrase-52 + " ":u + p-find-condition + " " + ""
      parameter-5-52 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-52)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-52 =  "FOR EACH X_dis-rule"
      parameter-4-52 =
        (
          if ("         X_dis-rule.upper-rule-num  = p-upper-rule-num           AND ( X_dis-rule.host-code  = p-host-code   OR X_dis-rule.host-code  = 0  )         AND ( X_dis-rule.obj-type = p-curr-obj-type OR X_dis-rule.obj-type = '':U )         AND ( X_dis-rule.obj-code = p-curr-obj-code OR X_dis-rule.obj-code = 0    )         and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                     " + " " + where-phrase-52) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1           AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&4&3           AND X_dis-rule.obj-code = &5           and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '         , p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root) + " " + where-phrase-52
          else "true"
        )
      parameter-5-52 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
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
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    END.
    ELSE DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-54 =
        (
          if ("             X_dis-rule.upper-rule-num  = p-upper-rule-num            AND ( X_dis-rule.host-code  = p-host-code   OR X_dis-rule.host-code  = 0  )         AND ( X_dis-rule.obj-type = p-curr-obj-type OR X_dis-rule.obj-type = '':U )         AND ( X_dis-rule.obj-code = p-curr-obj-code OR X_dis-rule.obj-code = 0    )         and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = p-sts " + " " + where-phrase-54) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1            AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&4&3           AND X_dis-rule.obj-code = &5           and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = &7 ', p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, p-sts) + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-54 = if sort-phrase-54 = ''
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
          ("             X_dis-rule.upper-rule-num  = p-upper-rule-num            AND ( X_dis-rule.host-code  = p-host-code   OR X_dis-rule.host-code  = 0  )         AND ( X_dis-rule.obj-type = p-curr-obj-type OR X_dis-rule.obj-type = '':U )         AND ( X_dis-rule.obj-code = p-curr-obj-code OR X_dis-rule.obj-code = 0    )         and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = p-sts " + " " + where-phrase-54 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where              X_dis-rule.upper-rule-num  = p-upper-rule-num            AND ( X_dis-rule.host-code  = p-host-code   OR X_dis-rule.host-code  = 0  )         AND ( X_dis-rule.obj-type = p-curr-obj-type OR X_dis-rule.obj-type = '':U )         AND ( X_dis-rule.obj-code = p-curr-obj-code OR X_dis-rule.obj-code = 0    )         and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = p-sts
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-54 = (if p-find-next then "true":u else "false":u )
      parameter-4-54 =
        "where ":u +  substitute(' X_dis-rule.upper-rule-num  = &1            AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&4&3           AND X_dis-rule.obj-code = &5           and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = &7 ', p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, p-sts) + " ":u + where-phrase-54 + " ":u + p-find-condition + " " + ""
      parameter-5-54 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-54)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-54 =  "FOR EACH X_dis-rule"
      parameter-4-54 =
        (
          if ("             X_dis-rule.upper-rule-num  = p-upper-rule-num            AND ( X_dis-rule.host-code  = p-host-code   OR X_dis-rule.host-code  = 0  )         AND ( X_dis-rule.obj-type = p-curr-obj-type OR X_dis-rule.obj-type = '':U )         AND ( X_dis-rule.obj-code = p-curr-obj-code OR X_dis-rule.obj-code = 0    )         and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = p-sts " + " " + where-phrase-54) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1            AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&4&3           AND X_dis-rule.obj-code = &5           and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))             AND X_dis-rule.sts = &7 ', p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, p-sts) + " " + where-phrase-54
          else "true"
        )
      parameter-5-54 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-54 = if sort-phrase-54 = ''
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
        " " + sort-phrase-54
        )
      parameter-7-54 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    END.
  END.
  WHEN "upper-rule-num-host":U THEN DO:
      filter-point = filter-point0 + p-mode.
      filter-label = substitute("&1 для одной фирмы", filter-label0).
      if X_upper-dis-rule.rule-num > 99999
      then
      ASSIGN
      frame Dialog-Frame:TITLE =
                                  substitute("Фирма &1 Правило скидок №&2: &3: Детализация"
                                  , p-host-code
                                  , X_upper-dis-rule.rule-num
                                  , X_upper-dis-rule.des
                                  )
                                  .
    else
      ASSIGN
      frame Dialog-Frame:TITLE =
                                  substitute("Фирма &1 Правила скидок типа: &2 &3"
                                  , p-host-code
                                  , X_upper-dis-rule.des
                                  , (if p-sts = -1 then "":U else  entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
                                  )
                                  .
    IF p-sts = -1 THEN DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-56 =
        (
          if ("         X_dis-rule.upper-rule-num  = p-upper-rule-num           AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                     " + " " + where-phrase-56) <> ""
          then  substitute('X_dis-rule.upper-rule-num  = &1         AND X_dis-rule.host-code  = &2          AND X_dis-rule.obj-type = &3&3           AND X_dis-rule.obj-code = 0           and ((&4 = -1) or (X_dis-rule.time-templ-rl-root = &4)) ', p-upper-rule-num, p-host-code, chr(34), p-time-templ-rl-root )  + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-56 = if sort-phrase-56 = ''
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
          ("         X_dis-rule.upper-rule-num  = p-upper-rule-num           AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                     " + " " + where-phrase-56 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where          X_dis-rule.upper-rule-num  = p-upper-rule-num           AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-56 = (if p-find-next then "true":u else "false":u )
      parameter-4-56 =
        "where ":u +  substitute('X_dis-rule.upper-rule-num  = &1         AND X_dis-rule.host-code  = &2          AND X_dis-rule.obj-type = &3&3           AND X_dis-rule.obj-code = 0           and ((&4 = -1) or (X_dis-rule.time-templ-rl-root = &4)) ', p-upper-rule-num, p-host-code, chr(34), p-time-templ-rl-root )  + " ":u + where-phrase-56 + " ":u + p-find-condition + " " + ""
      parameter-5-56 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-56)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-56 =  "FOR EACH X_dis-rule"
      parameter-4-56 =
        (
          if ("         X_dis-rule.upper-rule-num  = p-upper-rule-num           AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                     " + " " + where-phrase-56) <> ""
          then  substitute('X_dis-rule.upper-rule-num  = &1         AND X_dis-rule.host-code  = &2          AND X_dis-rule.obj-type = &3&3           AND X_dis-rule.obj-code = 0           and ((&4 = -1) or (X_dis-rule.time-templ-rl-root = &4)) ', p-upper-rule-num, p-host-code, chr(34), p-time-templ-rl-root )  + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-56 = if sort-phrase-56 = ''
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
        " " + sort-phrase-56
        )
      parameter-7-56 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    END.
    ELSE DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-58 =
        (
          if ("             X_dis-rule.upper-rule-num  = p-upper-rule-num            AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)             AND X_dis-rule.sts = p-sts " + " " + where-phrase-58) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1            AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&3           AND X_dis-rule.obj-code = 0           and ((&4 = -1) or (X_dis-rule.time-templ-rl-root = &4 ))            AND X_dis-rule.sts = &5 ',  p-upper-rule-num , p-host-code, chr(34), p-time-templ-rl-root, p-sts) + " " + where-phrase-58
          else "true"
        )
      parameter-5-58 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
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
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-58 =
          ("             X_dis-rule.upper-rule-num  = p-upper-rule-num            AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)             AND X_dis-rule.sts = p-sts " + " " + where-phrase-58 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where              X_dis-rule.upper-rule-num  = p-upper-rule-num            AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)             AND X_dis-rule.sts = p-sts
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-58 = (if p-find-next then "true":u else "false":u )
      parameter-4-58 =
        "where ":u +  substitute(' X_dis-rule.upper-rule-num  = &1            AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&3           AND X_dis-rule.obj-code = 0           and ((&4 = -1) or (X_dis-rule.time-templ-rl-root = &4 ))            AND X_dis-rule.sts = &5 ',  p-upper-rule-num , p-host-code, chr(34), p-time-templ-rl-root, p-sts) + " ":u + where-phrase-58 + " ":u + p-find-condition + " " + ""
      parameter-5-58 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-58)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-58 =  "FOR EACH X_dis-rule"
      parameter-4-58 =
        (
          if ("             X_dis-rule.upper-rule-num  = p-upper-rule-num            AND X_dis-rule.host-code  = p-host-code           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)             AND X_dis-rule.sts = p-sts " + " " + where-phrase-58) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1            AND X_dis-rule.host-code  = &2           AND X_dis-rule.obj-type = &3&3           AND X_dis-rule.obj-code = 0           and ((&4 = -1) or (X_dis-rule.time-templ-rl-root = &4 ))            AND X_dis-rule.sts = &5 ',  p-upper-rule-num , p-host-code, chr(34), p-time-templ-rl-root, p-sts) + " " + where-phrase-58
          else "true"
        )
      parameter-5-58 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
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
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    END.
  END.
  WHEN "upper-rule-num-global":U THEN DO:
      filter-point = filter-point0 + p-mode.
      filter-label = substitute("&1 ", filter-label0).
      if X_upper-dis-rule.rule-num > 99999
      then
      ASSIGN
      frame Dialog-Frame:TITLE =
                                  substitute("Правило скидок №&1: &2: Детализация"
                                  , X_upper-dis-rule.rule-num
                                  , X_upper-dis-rule.des
                                  )
                                  .
    else
      ASSIGN
      frame Dialog-Frame:TITLE =
                                  substitute("Правила скидок типа: &1 &2"
                                  , X_upper-dis-rule.des
                                  , (if p-sts = -1 then "":U else  entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
                                  )
                                  .
    IF p-sts = -1 THEN DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-60 =
        (
          if ("         X_dis-rule.upper-rule-num  = p-upper-rule-num           AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                     " + " " + where-phrase-60) <> ""
          then  substitute('X_dis-rule.upper-rule-num  = &1         AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = &2&2           AND X_dis-rule.obj-code = 0           and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3))', p-upper-rule-num, chr(34), p-time-templ-rl-root ) + " " + where-phrase-60
          else "true"
        )
      parameter-5-60 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
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
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-60 =
          ("         X_dis-rule.upper-rule-num  = p-upper-rule-num           AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                     " + " " + where-phrase-60 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where          X_dis-rule.upper-rule-num  = p-upper-rule-num           AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-60 = (if p-find-next then "true":u else "false":u )
      parameter-4-60 =
        "where ":u +  substitute('X_dis-rule.upper-rule-num  = &1         AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = &2&2           AND X_dis-rule.obj-code = 0           and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3))', p-upper-rule-num, chr(34), p-time-templ-rl-root ) + " ":u + where-phrase-60 + " ":u + p-find-condition + " " + ""
      parameter-5-60 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-60)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-60 =  "FOR EACH X_dis-rule"
      parameter-4-60 =
        (
          if ("         X_dis-rule.upper-rule-num  = p-upper-rule-num           AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                     " + " " + where-phrase-60) <> ""
          then  substitute('X_dis-rule.upper-rule-num  = &1         AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = &2&2           AND X_dis-rule.obj-code = 0           and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3))', p-upper-rule-num, chr(34), p-time-templ-rl-root ) + " " + where-phrase-60
          else "true"
        )
      parameter-5-60 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
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
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    END.
    ELSE DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-62 =
        (
          if ("             X_dis-rule.upper-rule-num  = p-upper-rule-num            AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)             AND X_dis-rule.sts = p-sts " + " " + where-phrase-62) <> ""
          then  substitute('X_dis-rule.upper-rule-num  = &1         AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = &2&2           AND X_dis-rule.obj-code = 0           and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3))             AND X_dis-rule.sts = &4 ', p-upper-rule-num, chr(34), p-time-templ-rl-root, p-sts ) + " " + where-phrase-62
          else "true"
        )
      parameter-5-62 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-62 = if sort-phrase-62 = ''
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
          ("             X_dis-rule.upper-rule-num  = p-upper-rule-num            AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)             AND X_dis-rule.sts = p-sts " + " " + where-phrase-62 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where              X_dis-rule.upper-rule-num  = p-upper-rule-num            AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)             AND X_dis-rule.sts = p-sts
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-62 = (if p-find-next then "true":u else "false":u )
      parameter-4-62 =
        "where ":u +  substitute('X_dis-rule.upper-rule-num  = &1         AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = &2&2           AND X_dis-rule.obj-code = 0           and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3))             AND X_dis-rule.sts = &4 ', p-upper-rule-num, chr(34), p-time-templ-rl-root, p-sts ) + " ":u + where-phrase-62 + " ":u + p-find-condition + " " + ""
      parameter-5-62 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-62)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-62 =  "FOR EACH X_dis-rule"
      parameter-4-62 =
        (
          if ("             X_dis-rule.upper-rule-num  = p-upper-rule-num            AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = '':U           AND X_dis-rule.obj-code = 0           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)             AND X_dis-rule.sts = p-sts " + " " + where-phrase-62) <> ""
          then  substitute('X_dis-rule.upper-rule-num  = &1         AND X_dis-rule.host-code  = 0           AND X_dis-rule.obj-type = &2&2           AND X_dis-rule.obj-code = 0           and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3))             AND X_dis-rule.sts = &4 ', p-upper-rule-num, chr(34), p-time-templ-rl-root, p-sts ) + " " + where-phrase-62
          else "true"
        )
      parameter-5-62 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-62 = if sort-phrase-62 = ''
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
        " " + sort-phrase-62
        )
      parameter-7-62 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
  END.
  WHEN "upper-rule-num-gds-obj":U THEN DO:
        filter-point = filter-point0 + p-mode.
        filter-label = substitute("&1 товарные", filter-label0).
        ASSIGN
        frame Dialog-Frame:TITLE =
                                    substitute("&1&2 Правила скидок к товару &3 &4: для бар-кода &5"
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , X_goods.gds-code
                                    , string(X_goods.gds-name, "X(20)")
                                    , p-b-code
                                    )
                                    .
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
                              "FOR EACH X_dis-rule"
      parameter-4-64 =
        (
          if ("           X_dis-rule.upper-rule-num  = p-upper-rule-num             AND X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.obj-code = p-curr-obj-code             and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))           and (p-sts = -1 or X_dis-rule.sts = p-sts)                       " + " " + where-phrase-64) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1             AND X_dis-rule.host-code  = &2             AND X_dis-rule.obj-type = &3&4&3            AND X_dis-rule.obj-code = &5             and (&6 = -1 or X_dis-rule.time-templ-rl-root = &6  or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))           and ((&7 = -1) or (X_dis-rule.sts = &7)) ', p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, p-sts) + " " + where-phrase-64
          else "true"
        )
      parameter-5-64 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-64 = if sort-phrase-64 = ''
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
          ("           X_dis-rule.upper-rule-num  = p-upper-rule-num             AND X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.obj-code = p-curr-obj-code             and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))           and (p-sts = -1 or X_dis-rule.sts = p-sts)                       " + " " + where-phrase-64 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where            X_dis-rule.upper-rule-num  = p-upper-rule-num             AND X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.obj-code = p-curr-obj-code             and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))           and (p-sts = -1 or X_dis-rule.sts = p-sts)
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-64 = (if p-find-next then "true":u else "false":u )
      parameter-4-64 =
        "where ":u +  substitute(' X_dis-rule.upper-rule-num  = &1             AND X_dis-rule.host-code  = &2             AND X_dis-rule.obj-type = &3&4&3            AND X_dis-rule.obj-code = &5             and (&6 = -1 or X_dis-rule.time-templ-rl-root = &6  or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))           and ((&7 = -1) or (X_dis-rule.sts = &7)) ', p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, p-sts) + " ":u + where-phrase-64 + " ":u + p-find-condition + " " + ""
      parameter-5-64 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-64)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-64 =  "FOR EACH X_dis-rule"
      parameter-4-64 =
        (
          if ("           X_dis-rule.upper-rule-num  = p-upper-rule-num             AND X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.obj-code = p-curr-obj-code             and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))           and (p-sts = -1 or X_dis-rule.sts = p-sts)                       " + " " + where-phrase-64) <> ""
          then  substitute(' X_dis-rule.upper-rule-num  = &1             AND X_dis-rule.host-code  = &2             AND X_dis-rule.obj-type = &3&4&3            AND X_dis-rule.obj-code = &5             and (&6 = -1 or X_dis-rule.time-templ-rl-root = &6  or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))           and ((&7 = -1) or (X_dis-rule.sts = &7)) ', p-upper-rule-num, p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, p-sts) + " " + where-phrase-64
          else "true"
        )
      parameter-5-64 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-64 = if sort-phrase-64 = ''
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
        " " + sort-phrase-64
        )
      parameter-7-64 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
  END.
  WHEN "time-rule-num":U THEN DO:
      filter-point = filter-point0 + p-mode.
      filter-label = substitute("&1 с опред. расписанием", filter-label0).
      ASSIGN
      frame Dialog-Frame:TITLE =
                                  substitute(" Правила скидок с расписанием &1: &2"
                                  , X_dis-time-rule.time-rule-num
                                  , X_dis-time-rule.des
                                  )
                                  .
    IF p-sts = -1 THEN DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-66 =
        (
          if ("         X_dis-rule.time-rule-num  = p-time-templ-rl-root                       " + " " + where-phrase-66) <> ""
          then  substitute(' X_dis-rule.time-rule-num  = &1', p-time-templ-rl-root ) + " " + where-phrase-66
          else "true"
        )
      parameter-5-66 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-66 = if sort-phrase-66 = ''
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
          ("         X_dis-rule.time-rule-num  = p-time-templ-rl-root                       " + " " + where-phrase-66 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where          X_dis-rule.time-rule-num  = p-time-templ-rl-root
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-66 = (if p-find-next then "true":u else "false":u )
      parameter-4-66 =
        "where ":u +  substitute(' X_dis-rule.time-rule-num  = &1', p-time-templ-rl-root ) + " ":u + where-phrase-66 + " ":u + p-find-condition + " " + ""
      parameter-5-66 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-66)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-66 =  "FOR EACH X_dis-rule"
      parameter-4-66 =
        (
          if ("         X_dis-rule.time-rule-num  = p-time-templ-rl-root                       " + " " + where-phrase-66) <> ""
          then  substitute(' X_dis-rule.time-rule-num  = &1', p-time-templ-rl-root ) + " " + where-phrase-66
          else "true"
        )
      parameter-5-66 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-66 = if sort-phrase-66 = ''
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
        " " + sort-phrase-66
        )
      parameter-7-66 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    END.
    ELSE DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-68 =
        (
          if ("             X_dis-rule.time-rule-num  = p-upper-rule-num                AND X_dis-rule.sts = p-sts " + " " + where-phrase-68) <> ""
          then  substitute(' X_dis-rule.time-rule-num  = &1                AND X_dis-rule.sts = &2 ', p-upper-rule-num, p-sts)  + " " + where-phrase-68
          else "true"
        )
      parameter-5-68 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-68 = if sort-phrase-68 = ''
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
          ("             X_dis-rule.time-rule-num  = p-upper-rule-num                AND X_dis-rule.sts = p-sts " + " " + where-phrase-68 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where              X_dis-rule.time-rule-num  = p-upper-rule-num                AND X_dis-rule.sts = p-sts
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-68 = (if p-find-next then "true":u else "false":u )
      parameter-4-68 =
        "where ":u +  substitute(' X_dis-rule.time-rule-num  = &1                AND X_dis-rule.sts = &2 ', p-upper-rule-num, p-sts)  + " ":u + where-phrase-68 + " ":u + p-find-condition + " " + ""
      parameter-5-68 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-68)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-68 =  "FOR EACH X_dis-rule"
      parameter-4-68 =
        (
          if ("             X_dis-rule.time-rule-num  = p-upper-rule-num                AND X_dis-rule.sts = p-sts " + " " + where-phrase-68) <> ""
          then  substitute(' X_dis-rule.time-rule-num  = &1                AND X_dis-rule.sts = &2 ', p-upper-rule-num, p-sts)  + " " + where-phrase-68
          else "true"
        )
      parameter-5-68 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-68 = if sort-phrase-68 = ''
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
        " " + sort-phrase-68
        )
      parameter-7-68 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    END.
  END.
WHEN 'объект':U THEN DO:
    filter-point = filter-point0 + p-mode.
    filter-label = substitute("&1 действующие на объекте", filter-label0).
    ASSIGN
    frame Dialog-Frame:TITLE = title0 +
                                substitute(" действующие на объекте: &1&2"
                                , p-curr-obj-type
                                , p-curr-obj-code
                                )
                                .
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
                              "FOR EACH X_dis-rule"
      parameter-4-70 =
        (
          if (" X_dis-rule.upper-rule-num > 0 and X_dis-rule.sts = integer('0':U)     AND (X_dis-rule.host-code = 0     or (X_dis-rule.host-code = p-host-code       and X_dis-rule.obj-type = '':U       AND X_dis-rule.obj-code = 0)     or (X_dis-rule.host-code = p-host-code       and X_dis-rule.obj-type = p-curr-obj-type       AND X_dis-rule.obj-code = p-curr-obj-code))      and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                   " + " " + where-phrase-70) <> ""
          then  substitute('X_dis-rule.upper-rule-num > 0 and X_dis-rule.sts = integer(&2&6&2)     AND (X_dis-rule.host-code = 0     or (X_dis-rule.host-code = &1       and X_dis-rule.obj-type = &2&2       AND X_dis-rule.obj-code = 0)     or (X_dis-rule.host-code = &1       and X_dis-rule.obj-type = &2&3&2       AND X_dis-rule.obj-code = &4))      and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5)) '      , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, '0':U) + " " + where-phrase-70
          else "true"
        )
      parameter-5-70 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-70 = if sort-phrase-70 = ''
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
          (" X_dis-rule.upper-rule-num > 0 and X_dis-rule.sts = integer('0':U)     AND (X_dis-rule.host-code = 0     or (X_dis-rule.host-code = p-host-code       and X_dis-rule.obj-type = '':U       AND X_dis-rule.obj-code = 0)     or (X_dis-rule.host-code = p-host-code       and X_dis-rule.obj-type = p-curr-obj-type       AND X_dis-rule.obj-code = p-curr-obj-code))      and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                   " + " " + where-phrase-70 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where  X_dis-rule.upper-rule-num > 0 and X_dis-rule.sts = integer('0':U)     AND (X_dis-rule.host-code = 0     or (X_dis-rule.host-code = p-host-code       and X_dis-rule.obj-type = '':U       AND X_dis-rule.obj-code = 0)     or (X_dis-rule.host-code = p-host-code       and X_dis-rule.obj-type = p-curr-obj-type       AND X_dis-rule.obj-code = p-curr-obj-code))      and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-70 = (if p-find-next then "true":u else "false":u )
      parameter-4-70 =
        "where ":u +  substitute('X_dis-rule.upper-rule-num > 0 and X_dis-rule.sts = integer(&2&6&2)     AND (X_dis-rule.host-code = 0     or (X_dis-rule.host-code = &1       and X_dis-rule.obj-type = &2&2       AND X_dis-rule.obj-code = 0)     or (X_dis-rule.host-code = &1       and X_dis-rule.obj-type = &2&3&2       AND X_dis-rule.obj-code = &4))      and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5)) '      , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, '0':U) + " ":u + where-phrase-70 + " ":u + p-find-condition + " " + ""
      parameter-5-70 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-70)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-70 =  "FOR EACH X_dis-rule"
      parameter-4-70 =
        (
          if (" X_dis-rule.upper-rule-num > 0 and X_dis-rule.sts = integer('0':U)     AND (X_dis-rule.host-code = 0     or (X_dis-rule.host-code = p-host-code       and X_dis-rule.obj-type = '':U       AND X_dis-rule.obj-code = 0)     or (X_dis-rule.host-code = p-host-code       and X_dis-rule.obj-type = p-curr-obj-type       AND X_dis-rule.obj-code = p-curr-obj-code))      and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                   " + " " + where-phrase-70) <> ""
          then  substitute('X_dis-rule.upper-rule-num > 0 and X_dis-rule.sts = integer(&2&6&2)     AND (X_dis-rule.host-code = 0     or (X_dis-rule.host-code = &1       and X_dis-rule.obj-type = &2&2       AND X_dis-rule.obj-code = 0)     or (X_dis-rule.host-code = &1       and X_dis-rule.obj-type = &2&3&2       AND X_dis-rule.obj-code = &4))      and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5)) '      , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, '0':U) + " " + where-phrase-70
          else "true"
        )
      parameter-5-70 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-70 = if sort-phrase-70 = ''
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
        " " + sort-phrase-70
        )
      parameter-7-70 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
END.
WHEN "template":U THEN DO:
    filter-point = filter-point0 + p-mode.
    filter-label = substitute("&1 - ШАБЛОНЫ", filter-label0).
    ASSIGN
    frame Dialog-Frame:TITLE =  substitute(" Типы правил (Шаблоны) скидок &1"
                                            ,(if p-sts = -1 then "":U else  entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
                                            )
                                            .
  IF p-sts = -1 THEN DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-72 =
        (
          if ("       X_dis-rule.rule-num  <= 93          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                   " + " " + where-phrase-72) <> ""
          then  substitute('X_dis-rule.rule-num  <= &1        and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) ', 93, p-time-templ-rl-root) + " " + where-phrase-72
          else "true"
        )
      parameter-5-72 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-72 = if sort-phrase-72 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " " +
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
          ("       X_dis-rule.rule-num  <= 93          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                   " + " " + where-phrase-72 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where        X_dis-rule.rule-num  <= 93          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-72 = (if p-find-next then "true":u else "false":u )
      parameter-4-72 =
        "where ":u +  substitute('X_dis-rule.rule-num  <= &1        and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) ', 93, p-time-templ-rl-root) + " ":u + where-phrase-72 + " ":u + p-find-condition + " " + ""
      parameter-5-72 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-72)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-72 =  "FOR EACH X_dis-rule"
      parameter-4-72 =
        (
          if ("       X_dis-rule.rule-num  <= 93          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                   " + " " + where-phrase-72) <> ""
          then  substitute('X_dis-rule.rule-num  <= &1        and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) ', 93, p-time-templ-rl-root) + " " + where-phrase-72
          else "true"
        )
      parameter-5-72 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-72 = if sort-phrase-72 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-72
        )
      parameter-7-72 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
  END.
  ELSE DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-74 =
        (
          if ("           X_dis-rule.rule-num  <= 93              AND X_dis-rule.sts = p-sts
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root )                     " + " " + where-phrase-74) <> ""
          then  substitute('  X_dis-rule.rule-num  <= &1             AND X_dis-rule.sts = &2
          and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3 )) ', 93,  p-sts, p-time-templ-rl-root)  + " " + where-phrase-74
          else "true"
        )
      parameter-5-74 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-74 = if sort-phrase-74 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-rule.rule-num  "
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
          ("           X_dis-rule.rule-num  <= 93              AND X_dis-rule.sts = p-sts
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root )                     " + " " + where-phrase-74 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where            X_dis-rule.rule-num  <= 93              AND X_dis-rule.sts = p-sts
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root )
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
       by X_dis-rule.rule-num
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-74 = (if p-find-next then "true":u else "false":u )
      parameter-4-74 =
        "where ":u +  substitute('  X_dis-rule.rule-num  <= &1             AND X_dis-rule.sts = &2
          and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3 )) ', 93,  p-sts, p-time-templ-rl-root)  + " ":u + where-phrase-74 + " ":u + p-find-condition + " " + ""
      parameter-5-74 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-74)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-74 =  "FOR EACH X_dis-rule"
      parameter-4-74 =
        (
          if ("           X_dis-rule.rule-num  <= 93              AND X_dis-rule.sts = p-sts
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root )                     " + " " + where-phrase-74) <> ""
          then  substitute('  X_dis-rule.rule-num  <= &1             AND X_dis-rule.sts = &2
          and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3 )) ', 93,  p-sts, p-time-templ-rl-root)  + " " + where-phrase-74
          else "true"
        )
      parameter-5-74 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-74 = if sort-phrase-74 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-rule.rule-num  "
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
                          ,input query br-dis-rule:handle
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
  END.
END.
WHEN "template-value-type":U THEN DO:
    filter-point = filter-point0 + p-mode.
    filter-label = substitute("&1 - ШАБЛОНЫ (опред тип значения скидки)", filter-label0).
    ASSIGN
    frame Dialog-Frame:TITLE =  substitute(" Типы правил (Шаблоны) скидок &1:"
                                            ,(if p-sts = -1 then "":U else  entry (lookup (STRING(p-sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))).
    DO V-jj = 1 TO num-entries(p-value-type):
       frame Dialog-Frame:TITLE = frame Dialog-Frame:TITLE + chr(32) + entry (lookup (ENTRY(V-jj, p-value-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U).
    end.
  IF p-sts = -1 THEN DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-76 =
        (
          if ("       X_dis-rule.rule-num  <= 93          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)       and lookup(string(X_dis-rule.value-type), p-value-type) > 0                   " + " " + where-phrase-76) <> ""
          then  substitute('X_dis-rule.rule-num  <= &1        and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) and lookup(string(X_dis-rule.value-type), &3) > 0', 93, p-time-templ-rl-root, p-value-type) + " " + where-phrase-76
          else "true"
        )
      parameter-5-76 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-76 = if sort-phrase-76 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " " +
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
          ("       X_dis-rule.rule-num  <= 93          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)       and lookup(string(X_dis-rule.value-type), p-value-type) > 0                   " + " " + where-phrase-76 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where        X_dis-rule.rule-num  <= 93          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)       and lookup(string(X_dis-rule.value-type), p-value-type) > 0
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-76 = (if p-find-next then "true":u else "false":u )
      parameter-4-76 =
        "where ":u +  substitute('X_dis-rule.rule-num  <= &1        and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) and lookup(string(X_dis-rule.value-type), &3) > 0', 93, p-time-templ-rl-root, p-value-type) + " ":u + where-phrase-76 + " ":u + p-find-condition + " " + ""
      parameter-5-76 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-76)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-76 =  "FOR EACH X_dis-rule"
      parameter-4-76 =
        (
          if ("       X_dis-rule.rule-num  <= 93          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)       and lookup(string(X_dis-rule.value-type), p-value-type) > 0                   " + " " + where-phrase-76) <> ""
          then  substitute('X_dis-rule.rule-num  <= &1        and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) and lookup(string(X_dis-rule.value-type), &3) > 0', 93, p-time-templ-rl-root, p-value-type) + " " + where-phrase-76
          else "true"
        )
      parameter-5-76 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-76 = if sort-phrase-76 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-76
        )
      parameter-7-76 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
  END.
  ELSE DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-78 =
        (
          if ("           X_dis-rule.rule-num  <= 93              AND X_dis-rule.sts = p-sts
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root )            and lookup(string(X_dis-rule.value-type), p-value-type) > 0                     " + " " + where-phrase-78) <> ""
          then  substitute('  X_dis-rule.rule-num  <= &1             AND X_dis-rule.sts = &2
          and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3 )) and LOOKUP(STRING(X_dis-rule.value-type), &4) > 0 ', 93,  p-sts, p-time-templ-rl-root, p-value-type)  + " " + where-phrase-78
          else "true"
        )
      parameter-5-78 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-78 = if sort-phrase-78 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-rule.rule-num  "
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
          ("           X_dis-rule.rule-num  <= 93              AND X_dis-rule.sts = p-sts
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root )            and lookup(string(X_dis-rule.value-type), p-value-type) > 0                     " + " " + where-phrase-78 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where            X_dis-rule.rule-num  <= 93              AND X_dis-rule.sts = p-sts
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root )            and lookup(string(X_dis-rule.value-type), p-value-type) > 0
    , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
       by X_dis-rule.rule-num
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-78 = (if p-find-next then "true":u else "false":u )
      parameter-4-78 =
        "where ":u +  substitute('  X_dis-rule.rule-num  <= &1             AND X_dis-rule.sts = &2
          and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3 )) and LOOKUP(STRING(X_dis-rule.value-type), &4) > 0 ', 93,  p-sts, p-time-templ-rl-root, p-value-type)  + " ":u + where-phrase-78 + " ":u + p-find-condition + " " + ""
      parameter-5-78 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-78)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-78 =  "FOR EACH X_dis-rule"
      parameter-4-78 =
        (
          if ("           X_dis-rule.rule-num  <= 93              AND X_dis-rule.sts = p-sts
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root )            and lookup(string(X_dis-rule.value-type), p-value-type) > 0                     " + " " + where-phrase-78) <> ""
          then  substitute('  X_dis-rule.rule-num  <= &1             AND X_dis-rule.sts = &2
          and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3 )) and LOOKUP(STRING(X_dis-rule.value-type), &4) > 0 ', 93,  p-sts, p-time-templ-rl-root, p-value-type)  + " " + where-phrase-78
          else "true"
        )
      parameter-5-78 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-78 = if sort-phrase-78 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-rule.rule-num  "
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
                          ,input query br-dis-rule:handle
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
  END.
END.
WHEN 'dis-gds-rule':U
OR
WHEN "cd-obj":U
OR
WHEN 'dis-dc-rule':U
OR
WHEN 'dis-dct-rule':U
OR
WHEN 'dis-cp-rule':U
OR
WHEN 'dis-grp-rule':U
THEN DO:
  filter-point = filter-point0 + p-mode.
  filter-label = substitute("&1 по объекту приложения скидки", filter-label0).
  IF p-mode = 'dis-gds-rule':U  THEN
  ASSIGN
  frame Dialog-Frame:TITLE =
                              substitute("&1&2 Правила скидок, действующие для товара на объекте &3"
                              , (if p-curr-obj-type = '':U then "" else p-curr-obj-type)
                              , (if p-curr-obj-type = '':U then "" else string(p-curr-obj-code))
                              , entry (lookup (v-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              )
                              .
  if p-mode = "cd-obj" then
  ASSIGN
  frame Dialog-Frame:TITLE =
                              substitute("&1&2 Правила скидок, применимые к кассе &3"
                              , (if p-curr-obj-type = '':U then "" else p-curr-obj-type)
                              , (if p-curr-obj-type = '':U then "" else string(p-curr-obj-code))
                              , v-cd
                                )
                              .
  if p-mode = 'dis-dc-rule':U then
  ASSIGN
  frame Dialog-Frame:TITLE =
                              substitute("&1&2 Правила скидок для карт"
                              , (if p-curr-obj-type = '':U then "" else p-curr-obj-type)
                              , (if p-curr-obj-type = '':U then "" else string(p-curr-obj-code))
                              , entry (lookup (v-discnt-role, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u)
                              )
                              .
  if p-mode = 'dis-dct-rule':U then
  ASSIGN
  frame Dialog-Frame:TITLE =
                              substitute("&1&2 Правила скидок для типов ДК &3"
                              , (if p-curr-obj-type = '':U then "" else p-curr-obj-type)
                              , (if p-curr-obj-type = '':U then "" else string(p-curr-obj-code) )
                              , entry (lookup (v-discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u)
                              )
                              .
  if p-mode = 'dis-cp-rule':U then
  ASSIGN
  frame Dialog-Frame:TITLE =
                              substitute("&1&2 Правила скидок для платежей &3"
                              , (if p-curr-obj-type = '':U then "" else p-curr-obj-type)
                              , (if p-curr-obj-type = '':U then "" else string(p-curr-obj-code))
                              , entry (lookup (v-discnt-role, 'simple-pay,qnty-pay':u) + 1, ',' + 'Скидка при оплате,Скидка на количество при оплате':u)
                              )
                              .
  if p-mode = 'dis-grp-rule':U then
  ASSIGN
  frame Dialog-Frame:TITLE =
                              substitute("&1&2 Правила скидок для групп &3"
                              , (if p-curr-obj-type = '':U then "" else p-curr-obj-type)
                              , (if p-curr-obj-type = '':U then "" else string(p-curr-obj-code))
                              , entry (lookup (v-discnt-role, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) + 1, ',' + '% скидка на группу товара,% скидка на группу товара для кат.клиентов,Abs скидка на группу товара,% Скидка на группу товара по кол-ву,% Скидка на группу товара на сумму':u)
                              )
                              .
      case v-region:
    when '' then do:
      IF p-sts = -1 THEN DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-80 =
        (
          if ("               ((X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.obj-code = p-curr-obj-code)             or (X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = '':U             AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))                       " + " " + where-phrase-80) <> ""
          then  substitute('((X_dis-rule.host-code  = &1             AND X_dis-rule.obj-type = &2&3&2             AND X_dis-rule.obj-code = &4)             or (X_dis-rule.host-code  = &1             AND X_dis-rule.obj-type = &2&2             AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.upper-rule-num < &6           AND X_dis-rule.rule-num > &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ',           p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999) + " " + where-phrase-80
          else "true"
        )
      parameter-5-80 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
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
          ("               ((X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.obj-code = p-curr-obj-code)             or (X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = '':U             AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))                       " + " " + where-phrase-80 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where                ((X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.obj-code = p-curr-obj-code)             or (X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = '':U             AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))
    , FIRST tt-template_dis-rule NO-LOCK WHERE tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-80 = (if p-find-next then "true":u else "false":u )
      parameter-4-80 =
        "where ":u +  substitute('((X_dis-rule.host-code  = &1             AND X_dis-rule.obj-type = &2&3&2             AND X_dis-rule.obj-code = &4)             or (X_dis-rule.host-code  = &1             AND X_dis-rule.obj-type = &2&2             AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.upper-rule-num < &6           AND X_dis-rule.rule-num > &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ',           p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999) + " ":u + where-phrase-80 + " ":u + p-find-condition + " " + ""
      parameter-5-80 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-80)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-80 =  "FOR EACH X_dis-rule"
      parameter-4-80 =
        (
          if ("               ((X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.obj-code = p-curr-obj-code)             or (X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = '':U             AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))                       " + " " + where-phrase-80) <> ""
          then  substitute('((X_dis-rule.host-code  = &1             AND X_dis-rule.obj-type = &2&3&2             AND X_dis-rule.obj-code = &4)             or (X_dis-rule.host-code  = &1             AND X_dis-rule.obj-type = &2&2             AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.upper-rule-num < &6           AND X_dis-rule.rule-num > &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ',           p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999) + " " + where-phrase-80
          else "true"
        )
      parameter-5-80 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
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
                          ,input query br-dis-rule:handle
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
      END.
      ELSE DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-82 =
        (
          if ("               ((X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = p-curr-obj-type                   AND X_dis-rule.obj-code = p-curr-obj-code)             or (X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = '':U                   AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                         " + " " + where-phrase-82) <> ""
          then  substitute('((X_dis-rule.host-code  = &1                   AND X_dis-rule.obj-type = &2&3&2                   AND X_dis-rule.obj-code = &4)             or (X_dis-rule.host-code  = &1                   AND X_dis-rule.obj-type = &2&2                   AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.rule-num > &7               AND X_dis-rule.sts = &5               and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '               , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, 99999)  + " " + where-phrase-82
          else "true"
        )
      parameter-5-82 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
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
          ("               ((X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = p-curr-obj-type                   AND X_dis-rule.obj-code = p-curr-obj-code)             or (X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = '':U                   AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                         " + " " + where-phrase-82 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where                ((X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = p-curr-obj-type                   AND X_dis-rule.obj-code = p-curr-obj-code)             or (X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = '':U                   AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )
    , FIRST tt-template_dis-rule NO-LOCK WHERE tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-82 = (if p-find-next then "true":u else "false":u )
      parameter-4-82 =
        "where ":u +  substitute('((X_dis-rule.host-code  = &1                   AND X_dis-rule.obj-type = &2&3&2                   AND X_dis-rule.obj-code = &4)             or (X_dis-rule.host-code  = &1                   AND X_dis-rule.obj-type = &2&2                   AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.rule-num > &7               AND X_dis-rule.sts = &5               and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '               , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, 99999)  + " ":u + where-phrase-82 + " ":u + p-find-condition + " " + ""
      parameter-5-82 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-82)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-82 =  "FOR EACH X_dis-rule"
      parameter-4-82 =
        (
          if ("               ((X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = p-curr-obj-type                   AND X_dis-rule.obj-code = p-curr-obj-code)             or (X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = '':U                   AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                         " + " " + where-phrase-82) <> ""
          then  substitute('((X_dis-rule.host-code  = &1                   AND X_dis-rule.obj-type = &2&3&2                   AND X_dis-rule.obj-code = &4)             or (X_dis-rule.host-code  = &1                   AND X_dis-rule.obj-type = &2&2                   AND X_dis-rule.obj-code = 0)             or (X_dis-rule.host-code  = 0))             AND X_dis-rule.rule-num > &7               AND X_dis-rule.sts = &5               and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '               , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, 99999)  + " " + where-phrase-82
          else "true"
        )
      parameter-5-82 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
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
                          ,input query br-dis-rule:handle
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
      END.
    end.
    when "global" then do:
      IF p-sts = -1 THEN DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-84 =
        (
          if ("               X_dis-rule.host-code  = 0             AND X_dis-rule.obj-type = ''             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))                       " + " " + where-phrase-84) <> ""
          then  substitute('X_dis-rule.host-code  = 0             AND X_dis-rule.obj-type = &2&2             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < &6           AND X_dis-rule.rule-num > &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ',           p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999) + " " + where-phrase-84
          else "true"
        )
      parameter-5-84 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
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
          ("               X_dis-rule.host-code  = 0             AND X_dis-rule.obj-type = ''             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))                       " + " " + where-phrase-84 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where                X_dis-rule.host-code  = 0             AND X_dis-rule.obj-type = ''             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))
    , FIRST tt-template_dis-rule NO-LOCK WHERE tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-84 = (if p-find-next then "true":u else "false":u )
      parameter-4-84 =
        "where ":u +  substitute('X_dis-rule.host-code  = 0             AND X_dis-rule.obj-type = &2&2             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < &6           AND X_dis-rule.rule-num > &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ',           p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999) + " ":u + where-phrase-84 + " ":u + p-find-condition + " " + ""
      parameter-5-84 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-84)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-84 =  "FOR EACH X_dis-rule"
      parameter-4-84 =
        (
          if ("               X_dis-rule.host-code  = 0             AND X_dis-rule.obj-type = ''             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))                       " + " " + where-phrase-84) <> ""
          then  substitute('X_dis-rule.host-code  = 0             AND X_dis-rule.obj-type = &2&2             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < &6           AND X_dis-rule.rule-num > &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ',           p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999) + " " + where-phrase-84
          else "true"
        )
      parameter-5-84 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
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
                          ,input query br-dis-rule:handle
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
      ELSE DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-86 =
        (
          if ("               X_dis-rule.host-code  = 0                   AND X_dis-rule.obj-type = ''                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                         " + " " + where-phrase-86) <> ""
          then  substitute('X_dis-rule.host-code  = 0                   AND X_dis-rule.obj-type = &2&2                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > &7               AND X_dis-rule.sts = &5               and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '               , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, 99999)  + " " + where-phrase-86
          else "true"
        )
      parameter-5-86 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
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
          ("               X_dis-rule.host-code  = 0                   AND X_dis-rule.obj-type = ''                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                         " + " " + where-phrase-86 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where                X_dis-rule.host-code  = 0                   AND X_dis-rule.obj-type = ''                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )
    , FIRST tt-template_dis-rule NO-LOCK WHERE tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-86 = (if p-find-next then "true":u else "false":u )
      parameter-4-86 =
        "where ":u +  substitute('X_dis-rule.host-code  = 0                   AND X_dis-rule.obj-type = &2&2                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > &7               AND X_dis-rule.sts = &5               and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '               , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, 99999)  + " ":u + where-phrase-86 + " ":u + p-find-condition + " " + ""
      parameter-5-86 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-86)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-86 =  "FOR EACH X_dis-rule"
      parameter-4-86 =
        (
          if ("               X_dis-rule.host-code  = 0                   AND X_dis-rule.obj-type = ''                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                         " + " " + where-phrase-86) <> ""
          then  substitute('X_dis-rule.host-code  = 0                   AND X_dis-rule.obj-type = &2&2                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > &7               AND X_dis-rule.sts = &5               and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '               , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, 99999)  + " " + where-phrase-86
          else "true"
        )
      parameter-5-86 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
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
                          ,input query br-dis-rule:handle
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
    end.
    when "host" then do:
      IF p-sts = -1 THEN DO:
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-88  as logical   no-undo .
define variable  l-filter-open-88    as logical   .
define variable  flt-rec-88       as recid     no-undo .
define variable  filter-name-88      as character no-undo .
define variable  where-phrase-88     as character no-undo .
define variable  sort-phrase-88      as character no-undo .
define variable  where-phrase-rus-88 as character no-undo .
define variable  sort-phrase-rus-88  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-88
  ,output filter-name-88
  ,output where-phrase-88
  ,output sort-phrase-88
  ,output where-phrase-rus-88
  ,output sort-phrase-rus-88
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-88
      ) no-error .
  assign
    l-filter-open-88 = false
  .
  if flt-rec-88 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-88 as character no-undo .
    define variable  parameter-3-88 as character no-undo .
    define variable  parameter-4-88 as character no-undo .
    define variable  parameter-5-88 as character no-undo .
    define variable  parameter-6-88 as character no-undo .
    define variable  parameter-7-88 as character no-undo .
      assign
      parameter-3-88 =
                              "FOR EACH X_dis-rule"
      parameter-4-88 =
        (
          if ("               X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = ''             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))                       " + " " + where-phrase-88) <> ""
          then  substitute('X_dis-rule.host-code  = &1             AND X_dis-rule.obj-type = &2&2             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < &6           AND X_dis-rule.rule-num > &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ',           p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999) + " " + where-phrase-88
          else "true"
        )
      parameter-5-88 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-88 = if sort-phrase-88 = ''
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
        " " + sort-phrase-88
        )
      parameter-7-88 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-88 =
          ("               X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = ''             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))                       " + " " + where-phrase-88 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input parameter-3-88
                          ,input parameter-4-88
                          ,input parameter-5-88
                          ,input parameter-6-88
                          ,input parameter-7-88
                          )
      .
      assign
        l-filter-open-88 = true
      .
    end.
    if l-filter-open-88 = false then do:
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
  if l-filter-open-88 = false then do:
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where                X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = ''             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))
    , FIRST tt-template_dis-rule NO-LOCK WHERE tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-88 = (if p-find-next then "true":u else "false":u )
      parameter-4-88 =
        "where ":u +  substitute('X_dis-rule.host-code  = &1             AND X_dis-rule.obj-type = &2&2             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < &6           AND X_dis-rule.rule-num > &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ',           p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999) + " ":u + where-phrase-88 + " ":u + p-find-condition + " " + ""
      parameter-5-88 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-88)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
                          ,input parameter-4-88
                          ,input parameter-5-88
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-88 = (if p-find-next then "true":u else "false":u )
      parameter-3-88 =  "FOR EACH X_dis-rule"
      parameter-4-88 =
        (
          if ("               X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = ''             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))                       " + " " + where-phrase-88) <> ""
          then  substitute('X_dis-rule.host-code  = &1             AND X_dis-rule.obj-type = &2&2             AND X_dis-rule.obj-code = 0             AND X_dis-rule.upper-rule-num < &6           AND X_dis-rule.rule-num > &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ',           p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999) + " " + where-phrase-88
          else "true"
        )
      parameter-5-88 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-88 = if sort-phrase-88 = ''
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
        " " + sort-phrase-88
        )
      parameter-7-88 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input logical(parameter-2-88)
                          ,input no-lock
                          ,input parameter-3-88
                          ,input parameter-4-88
                          ,input parameter-5-88
                          ,input parameter-6-88
                          ,input parameter-7-88
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
      ELSE DO:
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-90  as logical   no-undo .
define variable  l-filter-open-90    as logical   .
define variable  flt-rec-90       as recid     no-undo .
define variable  filter-name-90      as character no-undo .
define variable  where-phrase-90     as character no-undo .
define variable  sort-phrase-90      as character no-undo .
define variable  where-phrase-rus-90 as character no-undo .
define variable  sort-phrase-rus-90  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-90
  ,output filter-name-90
  ,output where-phrase-90
  ,output sort-phrase-90
  ,output where-phrase-rus-90
  ,output sort-phrase-rus-90
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-90
      ) no-error .
  assign
    l-filter-open-90 = false
  .
  if flt-rec-90 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-90 as character no-undo .
    define variable  parameter-3-90 as character no-undo .
    define variable  parameter-4-90 as character no-undo .
    define variable  parameter-5-90 as character no-undo .
    define variable  parameter-6-90 as character no-undo .
    define variable  parameter-7-90 as character no-undo .
      assign
      parameter-3-90 =
                              "FOR EACH X_dis-rule"
      parameter-4-90 =
        (
          if ("               X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = ''                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                         " + " " + where-phrase-90) <> ""
          then  substitute('X_dis-rule.host-code  = &1                   AND X_dis-rule.obj-type = &2&2                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > &7               AND X_dis-rule.sts = &5               and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '               , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, 99999)  + " " + where-phrase-90
          else "true"
        )
      parameter-5-90 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-90 = if sort-phrase-90 = ''
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
        " " + sort-phrase-90
        )
      parameter-7-90 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-90 =
          ("               X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = ''                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                         " + " " + where-phrase-90 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input parameter-3-90
                          ,input parameter-4-90
                          ,input parameter-5-90
                          ,input parameter-6-90
                          ,input parameter-7-90
                          )
      .
      assign
        l-filter-open-90 = true
      .
    end.
    if l-filter-open-90 = false then do:
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
  if l-filter-open-90 = false then do:
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where                X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = ''                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )
    , FIRST tt-template_dis-rule NO-LOCK WHERE tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-90 = (if p-find-next then "true":u else "false":u )
      parameter-4-90 =
        "where ":u +  substitute('X_dis-rule.host-code  = &1                   AND X_dis-rule.obj-type = &2&2                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > &7               AND X_dis-rule.sts = &5               and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '               , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, 99999)  + " ":u + where-phrase-90 + " ":u + p-find-condition + " " + ""
      parameter-5-90 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-90)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
                          ,input parameter-4-90
                          ,input parameter-5-90
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-90 = (if p-find-next then "true":u else "false":u )
      parameter-3-90 =  "FOR EACH X_dis-rule"
      parameter-4-90 =
        (
          if ("               X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = ''                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                         " + " " + where-phrase-90) <> ""
          then  substitute('X_dis-rule.host-code  = &1                   AND X_dis-rule.obj-type = &2&2                   AND X_dis-rule.obj-code = 0             AND X_dis-rule.rule-num > &7               AND X_dis-rule.sts = &5               and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '               , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, 99999)  + " " + where-phrase-90
          else "true"
        )
      parameter-5-90 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-90 = if sort-phrase-90 = ''
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
        " " + sort-phrase-90
        )
      parameter-7-90 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input logical(parameter-2-90)
                          ,input no-lock
                          ,input parameter-3-90
                          ,input parameter-4-90
                          ,input parameter-5-90
                          ,input parameter-6-90
                          ,input parameter-7-90
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
    end.
    when "object" then do:
      IF p-sts = -1 THEN DO:
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-92  as logical   no-undo .
define variable  l-filter-open-92    as logical   .
define variable  flt-rec-92       as recid     no-undo .
define variable  filter-name-92      as character no-undo .
define variable  where-phrase-92     as character no-undo .
define variable  sort-phrase-92      as character no-undo .
define variable  where-phrase-rus-92 as character no-undo .
define variable  sort-phrase-rus-92  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-92
  ,output filter-name-92
  ,output where-phrase-92
  ,output sort-phrase-92
  ,output where-phrase-rus-92
  ,output sort-phrase-rus-92
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-92
      ) no-error .
  assign
    l-filter-open-92 = false
  .
  if flt-rec-92 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-92 as character no-undo .
    define variable  parameter-3-92 as character no-undo .
    define variable  parameter-4-92 as character no-undo .
    define variable  parameter-5-92 as character no-undo .
    define variable  parameter-6-92 as character no-undo .
    define variable  parameter-7-92 as character no-undo .
      assign
      parameter-3-92 =
                              "FOR EACH X_dis-rule"
      parameter-4-92 =
        (
          if ("               X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))                       " + " " + where-phrase-92) <> ""
          then  substitute('X_dis-rule.host-code  = &1             AND X_dis-rule.obj-type = &2&3&2             AND X_dis-rule.obj-code = &4             AND X_dis-rule.upper-rule-num < &6           AND X_dis-rule.rule-num > &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ',           p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999) + " " + where-phrase-92
          else "true"
        )
      parameter-5-92 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-92 = if sort-phrase-92 = ''
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
        " " + sort-phrase-92
        )
      parameter-7-92 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-92 =
          ("               X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))                       " + " " + where-phrase-92 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input parameter-3-92
                          ,input parameter-4-92
                          ,input parameter-5-92
                          ,input parameter-6-92
                          ,input parameter-7-92
                          )
      .
      assign
        l-filter-open-92 = true
      .
    end.
    if l-filter-open-92 = false then do:
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
  if l-filter-open-92 = false then do:
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where                X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))
    , FIRST tt-template_dis-rule NO-LOCK WHERE tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-92 = (if p-find-next then "true":u else "false":u )
      parameter-4-92 =
        "where ":u +  substitute('X_dis-rule.host-code  = &1             AND X_dis-rule.obj-type = &2&3&2             AND X_dis-rule.obj-code = &4             AND X_dis-rule.upper-rule-num < &6           AND X_dis-rule.rule-num > &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ',           p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999) + " ":u + where-phrase-92 + " ":u + p-find-condition + " " + ""
      parameter-5-92 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-92)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
                          ,input parameter-4-92
                          ,input parameter-5-92
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-92 = (if p-find-next then "true":u else "false":u )
      parameter-3-92 =  "FOR EACH X_dis-rule"
      parameter-4-92 =
        (
          if ("               X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.upper-rule-num < 99999           AND X_dis-rule.rule-num > 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no))                       " + " " + where-phrase-92) <> ""
          then  substitute('X_dis-rule.host-code  = &1             AND X_dis-rule.obj-type = &2&3&2             AND X_dis-rule.obj-code = &4             AND X_dis-rule.upper-rule-num < &6           AND X_dis-rule.rule-num > &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ',           p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999) + " " + where-phrase-92
          else "true"
        )
      parameter-5-92 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-92 = if sort-phrase-92 = ''
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
        " " + sort-phrase-92
        )
      parameter-7-92 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input logical(parameter-2-92)
                          ,input no-lock
                          ,input parameter-3-92
                          ,input parameter-4-92
                          ,input parameter-5-92
                          ,input parameter-6-92
                          ,input parameter-7-92
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
      ELSE DO:
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
                              "FOR EACH X_dis-rule"
      parameter-4-94 =
        (
          if ("               X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = p-curr-obj-type                   AND X_dis-rule.obj-code = p-curr-obj-code             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                         " + " " + where-phrase-94) <> ""
          then  substitute('X_dis-rule.host-code  = &1                   AND X_dis-rule.obj-type = &2&3&2                   AND X_dis-rule.obj-code = &4             AND X_dis-rule.rule-num > &7               AND X_dis-rule.sts = &5               and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '               , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, 99999)  + " " + where-phrase-94
          else "true"
        )
      parameter-5-94 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd))
      parameter-6-94 = if sort-phrase-94 = ''
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
          ("               X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = p-curr-obj-type                   AND X_dis-rule.obj-code = p-curr-obj-code             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                         " + " " + where-phrase-94 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where                X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = p-curr-obj-type                   AND X_dis-rule.obj-code = p-curr-obj-code             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )
    , FIRST tt-template_dis-rule NO-LOCK WHERE tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-94 = (if p-find-next then "true":u else "false":u )
      parameter-4-94 =
        "where ":u +  substitute('X_dis-rule.host-code  = &1                   AND X_dis-rule.obj-type = &2&3&2                   AND X_dis-rule.obj-code = &4             AND X_dis-rule.rule-num > &7               AND X_dis-rule.sts = &5               and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '               , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, 99999)  + " ":u + where-phrase-94 + " ":u + p-find-condition + " " + ""
      parameter-5-94 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-94)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-94 =  "FOR EACH X_dis-rule"
      parameter-4-94 =
        (
          if ("               X_dis-rule.host-code  = p-host-code                   AND X_dis-rule.obj-type = p-curr-obj-type                   AND X_dis-rule.obj-code = p-curr-obj-code             AND X_dis-rule.rule-num > 99999               AND X_dis-rule.sts = p-sts               and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) )                         " + " " + where-phrase-94) <> ""
          then  substitute('X_dis-rule.host-code  = &1                   AND X_dis-rule.obj-type = &2&3&2                   AND X_dis-rule.obj-code = &4             AND X_dis-rule.rule-num > &7               AND X_dis-rule.sts = &5               and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) '               , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, 99999)  + " " + where-phrase-94
          else "true"
        )
      parameter-5-94 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  chr(34), v-cd) + " " + p-find-condition)
      parameter-6-94 = if sort-phrase-94 = ''
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
        " " + sort-phrase-94
        )
      parameter-7-94 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
      END.
    end.
  end case.
END.
WHEN "dis-gds-rule-gds-obj":U THEN DO:
        filter-point = filter-point0 + p-mode.
        filter-label = substitute("&1 для товаров на определ. объекте", filter-label0).
        ASSIGN
        frame Dialog-Frame:TITLE =
                                    substitute("&1&2 Правила скидок для тов. на объекте товар &3 &4: для бар-кода &5"
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , X_goods.gds-code
                                    , string(X_goods.gds-name, "X(20)")
                                    , p-b-code
                                    )
                                    .
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
                              "FOR EACH X_dis-rule"
      parameter-4-96 =
        (
          if ("               X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.obj-code = p-curr-obj-code             AND X_dis-rule.upper-rule-num < 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                       " + " " + where-phrase-96) <> ""
          then  substitute(' X_dis-rule.host-code  = &1            AND X_dis-rule.obj-type = &2&3&2             AND X_dis-rule.obj-code = &4             AND X_dis-rule.upper-rule-num < &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5)) '           , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999 )  + " " + where-phrase-96
          else "true"
        )
      parameter-5-96 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     NO-LOCK WHERE (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)'                                        , chr(34), v-cd))
      parameter-6-96 = if sort-phrase-96 = ''
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
          ("               X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.obj-code = p-curr-obj-code             AND X_dis-rule.upper-rule-num < 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                       " + " " + where-phrase-96 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-dis-rule:handle
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
    OPEN QUERY br-dis-rule FOR EACH X_dis-rule
      where                X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.obj-code = p-curr-obj-code             AND X_dis-rule.upper-rule-num < 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)
    , FIRST tt-template_dis-rule NO-LOCK WHERE (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-rule )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-dis-rule:handle:get-buffer-handle(1) = (buffer X_dis-rule:handle) then do:
      assign
      parameter-2-96 = (if p-find-next then "true":u else "false":u )
      parameter-4-96 =
        "where ":u +  substitute(' X_dis-rule.host-code  = &1            AND X_dis-rule.obj-type = &2&3&2             AND X_dis-rule.obj-code = &4             AND X_dis-rule.upper-rule-num < &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5)) '           , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999 )  + " ":u + where-phrase-96 + " ":u + p-find-condition + " " + ""
      parameter-5-96 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
                          ,input rowid(X_dis-rule)
                          ,input logical(parameter-2-96)
                          ,input no-lock
                          ,input (buffer X_dis-rule:handle)
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
      parameter-3-96 =  "FOR EACH X_dis-rule"
      parameter-4-96 =
        (
          if ("               X_dis-rule.host-code  = p-host-code             AND X_dis-rule.obj-type = p-curr-obj-type             AND X_dis-rule.obj-code = p-curr-obj-code             AND X_dis-rule.upper-rule-num < 99999           and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root)                       " + " " + where-phrase-96) <> ""
          then  substitute(' X_dis-rule.host-code  = &1            AND X_dis-rule.obj-type = &2&3&2             AND X_dis-rule.obj-code = &4             AND X_dis-rule.upper-rule-num < &6           and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5)) '           , p-host-code, chr(34), p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, 99999 )  + " " + where-phrase-96
          else "true"
        )
      parameter-5-96 = (" " + "" + " " + substitute(', FIRST tt-template_dis-rule     NO-LOCK WHERE (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)'                                        , chr(34), v-cd) + " " + p-find-condition)
      parameter-6-96 = if sort-phrase-96 = ''
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
        " " + sort-phrase-96
        )
      parameter-7-96 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-dis-rule:handle
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
  END.
END CASE.
if not p-open-query then
REPOSITION br-dis-rule to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-rule:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if error-status:error then do:
  REPOSITION br-dis-rule to row 1 No-ERROR.
end.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-dis-rule in frame Dialog-Frame.
APPLY "ENTRY" TO br-dis-rule.
END PROCEDURE.
PROCEDURE OpenBrgds-obj :
if available X_dis-rule and X_dis-rule.templ-rl-root = 34 then do:
  hide
  br-gds-obj
  in frame Dialog-Frame .
end.
else do:
  display
  br-gds-obj WHEN (p-mode = "upper-rule-num-gds-obj" or p-mode = "dis-gds-rule-gds-obj")
  with frame Dialog-Frame .
  RUN fill-tables-gds-obj IN THIS-PROCEDURE NO-ERROR.
  OPEN QUERY br-gds-obj FOR EACH tt-dis-rule-bc NO-LOCK.
end.
END PROCEDURE.
PROCEDURE proc-b-add :
DEFINE INPUT parameter p-add-mode AS CHARACTER NO-UNDO.
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-rule-num like ub.dis-rule.rule-num no-undo .
define variable  v-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-global            as integer no-undo .
define variable  v-host              as integer no-undo .
define variable  v-object            as integer no-undo .
define variable  v-output-display as logical   no-undo .
define variable v-tree            as character no-undo .
define variable  v-other          as character no-undo .
define variable v-obj-type like ub.dis-rule.obj-type no-undo .
define variable v-obj-code like ub.dis-rule.obj-code no-undo .
define variable v-attr-codes as character no-undo .
define variable v-attr-labels as character no-undo .
define variable v-presel-codes as character no-undo .
define variable v-sel-codes as character no-undo .
define variable v-upper-rule-num as integer   no-undo .
define buffer buf_tt-template_dis-rule for tt0-template_dis-rule .
define buffer buf_dis-rule for ub.dis-rule.
define buffer root_dis-rule for ub.dis-rule.
IF p-add-mode = 'КОПИРОВАНИЕ':U
AND NOT AVAILABLE X_dis-rule THEN RETURN ERROR.
define variable vss-include-info97 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_discount_work':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
if not loc#log then return no-apply.
if not ( p-curr-obj-type = '':U
        and
        p-curr-obj-code = 0) then do:
  if p-curr-obj-type = 'орг':U then do:
    assign
    v-host-code = p-curr-obj-code
    v-obj-type = v-cntxt-obj-type
    v-obj-code = v-cntxt-obj-code
    .
  end.
  else do:
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
end.
end.
else do:
  if p-host-code > 0 then v-host-code = p-host-code.
end.
IF p-add-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
  if p-upper-rule-num = 0 then do:
    for each buf_tt-template_dis-rule no-lock,
          first buf_dis-rule no-lock where
                buf_dis-rule.rule-num = buf_tt-template_dis-rule.templ-rl-root
            and buf_dis-rule.sts = integer('0':U):
      assign
      v-attr-codes   =  v-attr-codes +  chr(4) + string(buf_tt-template_dis-rule.templ-rl-root)
      v-attr-labels  =  v-attr-labels +  chr(4) + buf_dis-rule.des
      .
    end.
    assign
    v-attr-codes = trim (v-attr-codes, chr(4))
    v-attr-labels = trim (v-attr-labels, chr(4))
    .
    run gbl/d-list.w (
                      input "b-sel":U
                      ,input "Выберите тип правила"
                      ,input v-attr-codes
                      ,input v-attr-labels
                      ,input chr(4)
                      ,input v-presel-codes
                      ,output v-sel-codes).
    if v-sel-codes = "":U then return no-apply.
    assign
    v-upper-rule-num = integer(v-sel-codes)
    .
  end.
  else do:
    ASSIGN
    v-upper-rule-num = p-upper-rule-num
    .
  end.
  find first root_dis-rule where
          root_dis-rule.rule-num = v-upper-rule-num.
  do while root_dis-rule.upper-rule-num <> 0:
    assign
    v-upper-rule-num = root_dis-rule.upper-rule-num
    .
    find first root_dis-rule where
          root_dis-rule.rule-num = v-upper-rule-num .
  end.
  assign
  v-templ-rl-root = v-upper-rule-num
  .
end.
IF p-add-mode = 'КОПИРОВАНИЕ':U THEN DO:
  ASSIGN
  v-templ-rl-root = X_dis-rule.templ-rl-root
  loc-doc-rec = RECID(X_dis-rule)
  .
END.
run dr-code  in this-procedure (
                                input  v-templ-rl-root
                                ,output v-des
                                ,output v-discnt-type
                                ,output v-subject-type
                                ,output v-value-type
                                ,output v-level-1
                                ,output v-level-2
                                ,OUTPUT v-global
                                ,OUTPUT v-host
                                ,OUTPUT v-object
                                ,output v-output-display
                                ,output v-tree
                                ,output v-other
                                                          )  .
IF add-option = "":U  THEN DO:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
  if error-status:error or add-option = "":U then return no-apply.
END.
CASE add-option:
  when "global":U then do:
    if v-global > 0 then do:
      if v-cntxt-db-num = 0  THEN DO:
       assign
      v-host-code = 0
      v-obj-type = "":U
      v-obj-code = 0
      .
      END.
      else do:
        assign
        add-option = "":U.
        message
        "Невозможно добавить правило скидки такого типа в УБД"
        view-as alert-box error .
        return no-apply.
      end.
    end.
  end.
  when "host":U then do:
    if v-host > 0 then do:
      if v-cntxt-db-num = 0  then
      assign
      v-obj-type = "":U
      v-obj-code = 0
      .
      else do:
        assign
        add-option = "":U.
        message
        "Невозможно добавить правило скидки такого типа в УБД"
        view-as alert-box error .
        return no-apply.
      end.
    end.
  end.
  when "object":U then do:
    if v-object > 0 then do:
      assign
      v-obj-type = p-curr-obj-type
      v-obj-code = p-curr-obj-code
      .
    end.
  end.
END CASE.
assign
add-option = "":U.
define variable v-form-name as character no-undo init "ref/dis-ruli.w".
run disrules-get-interface-form in this-procedure ( input v-templ-rl-root
                                                   ,output v-form-name) .
run value(v-form-name) (
                    input parParentProc
                    ,input p-add-mode
                    ,input v-templ-rl-root
                    ,input v-host-code
                    ,input v-obj-type
                    ,input v-obj-code
                    ,input (IF p-add-mode = 'ДОБАВЛЕНИЕ':U THEN 0 ELSE X_dis-rule.rule-num)
                    ,input p-upper-rule-num
                    ,input (if p-mode = "upper-rule-num-gds-obj":U
                          or p-mode ="dis-gds-rule-gds-obj"
                          then p-b-code else 0)
                    ,input 0
                    ,input v-cd
                    ,input-output loc-doc-rec
                                ) no-error.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input YES, input NO, input '':U).
  reposition br-dis-rule to recid loc-doc-rec no-error.
  if error-status:error then do:                           find first pos_dis-rule no-lock where                                   recid(pos_dis-rule) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи ПРАВИЛО СКИДКИ" skip                            string(if avail pos_dis-rule                                     then  substitute("номер правила скидки: &1"                                                     , pos_dis-rule.rule-num)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
end.
apply "entry" to br-dis-rule in frame Dialog-Frame.
apply "value-changed" to br-dis-rule in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-chg :
DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_dis-rule then return no-apply.
define variable vss-include-info99 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_discount_work':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
if not loc#log then return no-apply.
if (X_dis-rule.host-code = 0
    or X_dis-rule.obj-code = 0)
and v-cntxt-db-num <> 0 then do:
  message
  "Невозможно редактировать данное правило скидки в УБД"
  view-as alert-box error .
  return no-apply.
end.
assign
loc-doc-rec = recid(X_dis-rule)
.
define variable v-form-name as character no-undo init "ref/dis-ruli.w".
run disrules-get-interface-form in this-procedure ( input X_dis-rule.templ-rl-root
                                                   ,output v-form-name) .
run value(v-form-name) (
                      input parParentProc
                      ,input 'ИЗМЕНЕНИЕ':U
                      ,input X_dis-rule.templ-rl-root
                      ,input X_dis-rule.host-code
                      ,input X_dis-rule.obj-type
                      ,input X_dis-rule.obj-code
                      ,input X_dis-rule.rule-num
                      ,input X_dis-rule.upper-rule-num
                      ,input (if p-mode = "upper-rule-num-gds-obj":U
                              or p-mode = "dis-gds-rule-gds-obj"
                              then p-b-code else 0)
                      ,input X_dis-rule.time-templ-rl-root
                      ,input '':U
                      ,input-output loc-doc-rec
                                  ) no-error.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input YES, input NO, input '':U).
  reposition br-dis-rule to recid loc-doc-rec no-error.
  if error-status:error then do:                           find first pos_dis-rule no-lock where                                   recid(pos_dis-rule) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи ПРАВИЛО СКИДКИ" skip                            string(if avail pos_dis-rule                                     then  substitute("номер правила скидки: &1"                                                     , pos_dis-rule.rule-num)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
end.
apply "entry" to br-dis-rule in frame Dialog-Frame.
apply "value-changed" to br-dis-rule in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-del :
define variable loc#log as logical no-undo.
define variable v-sts like ub.dis-rule.sts no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
define buffer loc_dis-rule for ub.dis-rule.
if not available X_dis-rule then return error.
do
on error undo, return error
on stop undo, return error
:
define variable vss-include-info100 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_discount_work':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
if not loc#log then return error.
  if (X_dis-rule.host-code = 0
      or X_dis-rule.obj-code = 0)
  and v-cntxt-db-num <> 0 then do:
    message
    "Невозможно удалять данное правило скидки в УБД"
    view-as alert-box error .
    return no-apply.
  end.
  loc#log = no.
  message
  "Вы действительно хотите удалить это правило скидки?"
  view-as alert-box question buttons YES-NO update loc#log.
  if not loc#log then undo, return error .
  assign
  loc-doc-rec = RECID(X_dis-rule)
  .
  find first loc_dis-rule exclusive-lock where
            recid(loc_Dis-rule) = loc-doc-rec no-error .
  if not available loc_dis-rule then do:
    message
    "Запись уже отсутствует или недоступна"
    view-as alert-box warning.
    return.
  end.
  run ref/disrul30.p (
                    buffer loc_dis-rule
                  ) no-error.
  if error-status:error then do:
    message
    "Ошибка при удалении ПРАВИЛА СКИДКИ" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo, return error .
  end.
  RUN OpenBr in this-procedure ( input YES, input NO, input '':U).
  REPOSITION br-dis-rule to row 1 No-error.
  if error-status:error then do:                           find first pos_dis-rule no-lock where                                   recid(pos_dis-rule) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи ПРАВИЛО СКИДКИ" skip                            string(if avail pos_dis-rule                                     then  substitute("номер правила скидки: &1"                                                     , pos_dis-rule.rule-num)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
  if available X_dis-rule then do:
    loc#log = br-dis-rule:select-focused-row( ) IN FRAME Dialog-Frame.
  end.
  apply "ENTRY" to br-dis-rule.
end.
END PROCEDURE.
PROCEDURE proc-b-dis-rules :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-sts as integer no-undo init -1.
  IF NOT AVAILABLE X_dis-rule THEN RETURN no-apply.
  IF X_dis-rule.sts = INTEGER('1':U) THEN RETURN NO-APPLY.
  if X_dis-rule.uniq-field <> "":U
  and X_dis-rule.rule-num > 99999
  then do:
    v-sts = -1.
  end.
  else do:
    v-sts = integer('0':U).
  end.
  run ref/dis-ruls.w (
                       input parParentProc
                      ,input  p-host-code
                      ,input  p-curr-obj-type
                      ,input  p-curr-obj-code
                      ,input  "b-add":U
                      ,input  "upper-rule-num":U
                      ,input   X_dis-rule.rule-num
                      ,input p-time-templ-rl-root
                      ,input 0
                      ,input-output v-sts
                      ,input-output v-rid-list ) no-error .
  APPLY "ENTRY" TO br-dis-rule IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-history :
define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if NOT available X_dis-rule then return no-apply.
  loc-doc-rec = recid (X_dis-rule).
  run ref/discruls.w (
                      INPUT parParentProc
                      ,input "":U
                      ,input (if X_dis-rule.uniq-field = "":U then "one":U else "rl-root":U)
                      ,input X_dis-rule.rule-num
                      ,input X_dis-rule.upper-rule-num
                      ,input "":U
                      ,input 0
                      ,input-output v-rid-list ).
  reposition br-dis-rule to recid loc-doc-rec no-error.
  apply "entry" to br-dis-rule in frame Dialog-Frame.
  apply "value-changed" to br-dis-rule in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-lookup :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable v-mode as character no-undo .
define variable v-rid-list as character no-undo .
define variable v-table-name as character no-undo .
define variable v-table-name-list as character no-undo .
define variable v-table-labels as character no-undo .
define variable v-classif-type as character no-undo .
define variable v-link-prop as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
if not available X_dis-rule then return error.
CASE p-option:
  WHEN "rule" THEN DO:
define variable vss-include-info101 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_discount_work':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
    if not loc#log then return no-apply.
    ASSIGN
    loc-doc-rec = recid(X_dis-rule)
    .
    define variable v-form-name as character no-undo init "ref/dis-ruli.w".
    run disrules-get-interface-form in this-procedure ( input X_dis-rule.templ-rl-root
                                                      ,output v-form-name) .
    run value(v-form-name) (
                             input parParentProc
                            ,input 'ПРОСМОТР':U
                            ,input X_dis-rule.templ-rl-root
                            ,input X_dis-rule.host-code
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input X_dis-rule.rule-num
                            ,input X_dis-rule.upper-rule-num
                            ,input (if p-mode = "upper-rule-num-gds-obj":U
                                    or p-mode = "dis-gds-rule-gds-obj"
                                    then p-b-code
                                    else 0)
                            ,input X_dis-rule.time-templ-rl-root
                            ,input '':U
                            ,input-output loc-doc-rec
                                        ) no-error .
  END.
  WHEN "subject" THEN DO:
   for each buf_dis-cfg-rule no-lock where
             buf_Dis-cfg-rule.templ-rl-root = X_dis-rule.templ-rl-root
         and buf_Dis-cfg-rule.table-name > '':U
    break
    by buf_dis-cfg-rule.table-name
    by buf_dis-cfg-rule.self-nonunique
    :
      if first-of(buf_dis-cfg-rule.self-nonunique)
      then do:
        assign
        v-table-name-list = v-table-name-list + chr(4) +
                           buf_Dis-cfg-rule.table-name  + ":" +
                           buf_dis-cfg-rule.self-nonunique + ":" +
                           string(buf_dis-cfg-rule.link-prop)
        v-table-labels = v-table-labels + chr(4) + entry (lookup (buf_Dis-cfg-rule.table-name, 'dis-gds-rule,dis-cp-rule,dis-dc-rule,dis-dct-rule,dis-thbj-rule,dis-grp-rule,dis-some-rule':u) + 1, ',' + 'Скидка Товара на объ.,Скидки на платеж,Скидки для ДК,Скидки на типы ДК,Общие скидки,Скидки по группе,Привязка прв скид':u) +  ":" +
                         entry (lookup (buf_dis-cfg-rule.self-nonunique, 'sum-grp,cli-grp':u) + 1, ',' + 'Группы товаров (на кассе),Группа клиентов':u) + chr(32) +
                         entry (lookup (string(buf_dis-cfg-rule.link-prop), '0,1,2,3,-2,-1':U) + 1, ',':U + 'Объект<=>правило,->Условие правила,Объект<=>Ветка правила,Объект<=>Ссылка на правило,Объект<=>Свойство<=>правило,Объект<=>Нет правила':U)
        .
      end.
    end.
    assign
    v-table-name-list = trim(v-table-name-list, chr(4) )
    v-table-labels = trim(v-table-labels, chr(4) )
    .
    if num-entries(v-table-name-list, chr(4)) > 1 then  do:
      run gbl/d-list.w (
                    INPUT "b-sel":U
                    ,INPUT "Выберите тип объекта приложения/условия правила"
                    ,INPUT v-table-name-list
                    ,INPUT v-table-labels
                    ,INPUT chr(4)
                    ,INPUT "":U
                    ,output v-table-name) no-error .
      if v-table-name = '':U then do:
        undo, return error .
      end.
      assign
      v-classif-type = entry(2, v-table-name, ":")
      v-link-prop = entry(3, v-table-name, ":")
      v-table-name = entry(1, v-table-name, ":")
      .
    end.
    else do:
      assign
      v-table-name = entry(1, v-table-name-list, ":")
      v-classif-type = entry(2, v-table-name-list, ":")
      v-link-prop = entry(3, v-table-name-list, ":")
      .
    end.
    case v-table-name:
      when 'dis-gds-rule':U then do:
        if p-mode = "upper-rule-num-gds-obj"
        or p-mode = 'dis-gds-rule':U
        or p-mode = "dis-gds-rule-gds-obj" then do:
           message
           "Просмотр объектов приложения скидок в данном режиме недоступен"
           view-as alert-box error .
           return error.
        end.
        if X_dis-rule.rule-num <  99999  then do:
           if p-mode = "upper-rule-num"
           or p-mode = "template"
           or p-mode = "template"
           then do:
             v-mode = "templ-rl-root".
           end.
           if p-mode = 'объект':U then do:
             v-mode = ('объект':U + chr(44) + "templ-rl-root":U).
           end.
           if p-mode = "cd-obj" then do:
              v-mode = ('объект':U + chr(44) + "pos-type":U).
           end.
        end.
        else do:
          if v-link-prop = '0':U then do:
             v-mode = "rule-num".
          end.
          else do:
             v-mode = "rl-root".
          end.
        end.
        run ref/dis-gdss.w (
                             INPUT parparentproc
                            ,INPUT '':U
                            ,INPUT v-mode
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input (if tt-template_dis-rule.templ-rl-root = 0
                                    then X_dis-rule.templ-rl-root
                                    else tt-template_dis-rule.templ-rl-root)
                            ,input '':U
                            ,input '':U
                            ,input X_dis-rule.rule-num
                            ,input-output v-rid-list ) no-error.
      end.
      when 'dis-dc-rule':U then do:
        if X_dis-rule.rule-num <  99999  then do:
           if p-mode = "upper-rule-num"
           or p-mode = "template"
           or p-mode = "template"
           then do:
             v-mode = "templ-rl-root".
           end.
           if p-mode = 'объект':U then do:
             v-mode = ('объект':U + chr(44) + "templ-rl-root":U).
           end.
           if p-mode = "cd-obj" then do:
              v-mode = ('объект':U + chr(44) + "pos-type":U).
           end.
        end.
        else do:
          if v-link-prop = '0':U then do:
             v-mode = "rule-num".
          end.
          else do:
             v-mode = "rl-root".
          end.
        end.
        run ref/dis-dcs.w (
                             INPUT parparentproc
                            ,INPUT '':U
                            ,INPUT v-mode
                            ,input X_dis-rule.host-code
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input (if tt-template_dis-rule.templ-rl-root = 0
                                    then X_dis-rule.templ-rl-root
                                    else tt-template_dis-rule.templ-rl-root)
                            ,input '':U
                            ,input '':U
                            ,input X_dis-rule.rule-num
                            ,input-output v-rid-list ) no-error.
      end.
      when 'dis-dct-rule':U then do:
        if X_dis-rule.rule-num <  99999  then do:
           if p-mode = "upper-rule-num"
           or p-mode = "template"
           or p-mode = "template"
           then do:
             v-mode = "templ-rl-root".
           end.
           if p-mode = 'объект':U then do:
             v-mode = ('объект':U + chr(44) + "templ-rl-root":U).
           end.
           if p-mode = "cd-obj" then do:
              v-mode = ('объект':U + chr(44) + "pos-type":U).
           end.
        end.
        else do:
          if v-link-prop = '0':U then do:
             v-mode = "rule-num".
          end.
          else do:
             v-mode = "rl-root".
          end.
        end.
        run ref/dis-dcts.w (
                             INPUT parparentproc
                            ,INPUT '':U
                            ,INPUT v-mode
                            ,input 0
                            ,input '':U
                            ,input X_dis-rule.host-code
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input (if tt-template_dis-rule.templ-rl-root = 0
                                    then X_dis-rule.templ-rl-root
                                    else tt-template_dis-rule.templ-rl-root)
                            ,input '':U
                            ,input '':U
                            ,input X_dis-rule.rule-num
                            ,input-output v-rid-list ) no-error.
      end.
      when 'dis-cp-rule':U then do:
        if X_dis-rule.rule-num <  99999  then do:
           if p-mode = "upper-rule-num"
           or p-mode = "template"
           or p-mode = "template"
           then do:
             v-mode = "templ-rl-root".
           end.
           if p-mode = 'объект':U then do:
             v-mode = ('объект':U + chr(44) + "templ-rl-root":U).
           end.
           if p-mode = "cd-obj" then do:
              v-mode = ('объект':U + chr(44) + "pos-type":U).
           end.
        end.
        else do:
          if v-link-prop = '0':U then do:
             v-mode = "rule-num".
          end.
          else do:
             v-mode = "rl-root".
          end.
        end.
        run ref/dis-cps.w (
                             INPUT parparentproc
                            ,INPUT '':U
                            ,INPUT v-mode
                            ,input X_dis-rule.host-code
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input (if tt-template_dis-rule.templ-rl-root = 0
                                    then X_dis-rule.templ-rl-root
                                    else tt-template_dis-rule.templ-rl-root)
                            ,input '':U
                            ,input '':U
                            ,input X_dis-rule.rule-num
                            ,input-output v-rid-list ) no-error.
      end.
      when 'dis-grp-rule':U then do:
        if X_dis-rule.rule-num <  99999  then do:
           if p-mode = "upper-rule-num"
           or p-mode = "template"
           or p-mode = "template"
           then do:
             v-mode = "templ-rl-root".
           end.
           if p-mode = 'объект':U then do:
             v-mode = ('объект':U + chr(44) + "templ-rl-root":U).
           end.
           if p-mode = "cd-obj" then do:
              v-mode = ('объект':U + chr(44) + "pos-type":U).
           end.
        end.
        else do:
          if v-link-prop = '0':U then do:
             v-mode = "rule-num".
          end.
          else do:
             v-mode = "rl-root".
          end.
        end.
        run ref/dis-grps.w (
                             INPUT parparentproc
                            ,INPUT '':U
                            ,INPUT v-mode
                            ,input v-classif-type
                            ,input X_dis-rule.host-code
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input (if tt-template_dis-rule.templ-rl-root = 0
                                    then X_dis-rule.templ-rl-root
                                    else tt-template_dis-rule.templ-rl-root)
                            ,input '':U
                            ,input '':U
                            ,input X_dis-rule.rule-num
                            ,input-output v-rid-list ) no-error.
      end.
      when 'dis-thbj-rule':U then do:
        if X_dis-rule.rule-num <  99999  then do:
           if p-mode = "upper-rule-num"
           or p-mode = "template"
           or p-mode = "template"
           then do:
             v-mode = "templ-rl-root".
           end.
           if p-mode = 'объект':U then do:
             v-mode = ('объект':U + chr(44) + "templ-rl-root":U).
           end.
           if p-mode = "cd-obj" then do:
              v-mode = ('объект':U + chr(44) + "pos-type":U).
           end.
        end.
        else do:
          if v-link-prop = '0':U
          or v-link-prop = '3':U
          then do:
             v-mode = "rule-num".
          end.
          else do:
             v-mode = "rl-root".
          end.
        end.
        run ref/disthbjs.w (
                             INPUT parparentproc
                            ,INPUT '':U
                            ,INPUT v-mode
                            ,input X_dis-rule.host-code
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input (if tt-template_dis-rule.templ-rl-root = 0
                                    then X_dis-rule.templ-rl-root
                                    else tt-template_dis-rule.templ-rl-root)
                            ,input '':U
                            ,input '':U
                            ,input X_dis-rule.rule-num
                            ,input-output v-rid-list ) no-error.
      end.
    end case.
  END.
END CASE.
apply "entry" to br-dis-rule in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-mark :
define variable loc#log as logical no-undo .
  if available X_dis-rule then do:
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid103 as character no-undo .
define variable v-num-entry103 as integer   no-undo .
assign
  v-str-recid103 = trim( string( recid( X_dis-rule ) , "->>>>>>>>>>>9":U ) )
  v-num-entry103 = lookup( v-str-recid103 , v-rid-list )
.
if v-num-entry103 > 0 then do:
  assign
    entry( v-num-entry103, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid103
  .
end.
    loc#log = br-dis-rule:refresh() IN FRAME Dialog-Frame .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-dis-rule:select-next-row ().
        apply "VALUE-CHANGED" to br-dis-rule in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-dis-rule in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-print :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
DEFINE VARIABLE v-sts-chr AS CHARACTER NO-UNDO.
define variable v-region as character no-undo .
define variable v-discnt-type as character no-undo .
define variable v-subject-type as character no-undo .
define variable v-value-type as character no-undo .
define variable v-discnt-value as character no-undo .
DEFINE VARIABLE v1-sts-chr AS CHARACTER NO-UNDO.
define variable v1-region as character no-undo .
define variable v1-discnt-type as character no-undo .
define variable v1-subject-type as character no-undo .
define variable v1-value-type as character no-undo .
define variable v1-discnt-value as character no-undo .
define variable v-mark as character no-undo .
DEFINE variable v1-display-time-rule-num AS CHARACTER NO-UNDO.
DEFINE variable v1-display-dis-kat AS CHARACTER  NO-UNDO.
DEFINE variable v1-display-doc-qnty AS CHARACTER  NO-UNDO.
DEFINE variable v1-display-tot-sum AS CHARACTER  NO-UNDO.
define variable v1-display-charkey_one as character no-undo .
define variable v1-display-charkey_two as character no-undo .
define variable v1-display-charkey_three as character no-undo .
define variable v1-display-deckey_one as character no-undo .
define variable v1-display-deckey_two as character no-undo .
define variable v1-display-deckey_three as character no-undo .
define variable v1-display-key#_one as character no-undo .
define variable v1-display-key#_two as character no-undo .
define variable v1-display-key#_three as character no-undo .
DEFINE VARIABLE v1-display-discnt-value AS CHARACTER  NO-UNDO.
define variable v-h as handle no-undo .
define variable v-fh as handle no-undo .
define variable v-realname as character no-undo .
define variable v-realname2 as character no-undo .
define variable v-char as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-found as logical no-undo .
define variable v-using-fields as character no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_print-dis-rule for print-dis-rule.
DEFINE FRAME dis-rule-list
X_dis-rule.des FORMAT "X(40)"
v-sts-chr FORMAT "X(8)" COLUMN-LABEL "Статус"
v-region FORMAT "X(15)" COLUMN-LABEL "Обл-ть действия"
v-discnt-type COLUMN-LABEL "Тип скидки" FORMAT "X(20)":U
v-subject-type COLUMN-LABEL "Объект!воздействия!скидки" FORMAT "X(12)":U
v-value-type COLUMN-LABEL "Тип!знач." FORMAT "X(7)":U
X_dis-rule.rule-num COLUMN-LABEL "Номер!правила"
v-char column-label "Значения" format "X(72)"
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 145 PAGE-NUMBER(PrnLibStream) AT 155 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 195).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame Dialog-Frame:title )
format "x(130)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME dis-rule-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_dis-rule).
DO WHILE available X_dis-rule :
  GET prev br-dis-rule.
END.
for each buf_print-dis-rule:
  delete buf_print-dis-rule.
end.
create buf_print-dis-rule.
GET next br-dis-rule.
do jj = 1 to 4 :
  assign
  v-h = br-dis-rule:FIRST-COLUMN IN FRAME Dialog-Frame
  v-char = '':U
  ii = 0
  v-found = no
  .
  DO while valid-handle(v-h) :
    if v-h:visible
    and v-h:name <> ?
    then do:
      v-realname = replace(v-h:name, "v-", "").
      assign
      v-fh = buffer buf_print-dis-rule:buffer-field(v-realname) no-error .
      if valid-handle(v-fh) then do:
        assign
        v-char = v-char + (if ii = 0 then '':U else chr(32) ) +
        (if num-entries(v-h:label, "!") >= jj then
        string(entry(jj, v-h:label, "!"), substitute("X(&1)", round(v-h:width, 0)))
        else fill( chr(32), integer(round(v-h:width, 0)))
        )
        ii = ii + 1
        .
        if num-entries(v-h:label, "!") = jj then do:
          v-found = yes.
        end.
      end.
    end.
    v-h = v-h:NEXT-COLUMN.
  end.
  if not v-found and jj > 1 then leave.
  display stream prnlibstream
  v-char
  with FRAME dis-rule-list .
  DOWN STREAM PrnLibStream 1
  with FRAME dis-rule-list  .
end.
DO WHILE available X_dis-rule :
  assign
  v-sts-chr = entry (lookup (string(X_dis-rule.sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U)
  v-region = gtregion(X_dis-rule.host-code, X_dis-rule.obj-type, X_dis-rule.obj-code, X_dis-rule.templ-rl-root, X_dis-rule.lvl-num = 0, NO)
  v-discnt-type = entry (lookup (string(X_dis-rule.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U)
  v-subject-type = entry (lookup (STRING(X_dis-rule.subject-type), '0,1,2,3,4,5,7,8':U), 'Неизв,Товар,Подитог,Итог,Чек,Оплата,Товар_б/итог.скидки,Группа':U)
  v-value-type = entry (lookup (string(X_dis-rule.value-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U)
  v-mark = mark-string(buffer X_dis-rule, v-rid-list)
  .
  RUN get-tree IN THIS-PROCEDURE(
                                   BUFFER X_dis-rule
                                  ,output buf_print-dis-rule.display-time-rule-num
                                  ,OUTPUT buf_print-dis-rule.display-dis-kat
                                  ,OUTPUT buf_print-dis-rule.display-doc-qnty
                                  ,OUTPUT buf_print-dis-rule.display-tot-sum
                                  ,OUTPUT buf_print-dis-rule.display-charkey_one
                                  ,OUTPUT buf_print-dis-rule.display-charkey_two
                                  ,OUTPUT buf_print-dis-rule.display-charkey_three
                                  ,OUTPUT buf_print-dis-rule.display-deckey_one
                                  ,OUTPUT buf_print-dis-rule.display-deckey_two
                                  ,OUTPUT buf_print-dis-rule.display-deckey_three
                                  ,OUTPUT buf_print-dis-rule.display-key#_one
                                  ,OUTPUT buf_print-dis-rule.display-key#_two
                                  ,OUTPUT buf_print-dis-rule.display-key#_three
                                  ,OUTPUT buf_print-dis-rule.display-discnt-value
                                  ,output v-using-fields
                                  ) .
  assign
  v-h = br-dis-rule:FIRST-COLUMN IN FRAME Dialog-Frame
  v-char = '':U
  ii = 0
  .
  DO while valid-handle(v-h) :
    if v-h:visible
    and v-h:name <> ?
    then do:
      v-realname = replace(v-h:name, "v-", "").
      assign
      v-fh = buffer buf_print-dis-rule:buffer-field(v-realname) no-error .
      if valid-handle(v-fh) then do:
        assign
        v-char = v-char + (if ii = 0 then '':U else chr(32) ) +
        string(v-fh:buffer-value, substitute("X(&1)", round(v-h:width, 0)))
        ii = ii + 1
        .
      end.
    end.
    v-h = v-h:NEXT-COLUMN.
  end.
  Display STREAM PrnLibStream
  X_dis-rule.des
  v-sts-chr
  v-region
  v-discnt-type
  v-subject-type
  v-value-type
  X_dis-rule.rule-num
  v-char
  with FRAME dis-rule-list .
  DOWN STREAM PrnLibStream 1
  with FRAME dis-rule-list  .
  assign
  accum-count = accum-count + 1
  .
  if X_dis-rule.is-term = no
  and X_dis-rule.root = yes
  then do:
    for each buf_dis-rule no-lock where
            buf_dis-rule.rl-root = X_dis-rule.rule-num
        and buf_dis-rule.is-term = yes
            :
      assign
      v1-sts-chr = entry (lookup (STRING(buf_dis-rule.sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U)
      v1-region = gtregion(buf_dis-rule.host-code, buf_dis-rule.obj-type, buf_dis-rule.obj-code, buf_dis-rule.templ-rl-root, buf_dis-rule.lvl-num = 0, NO)
      v1-discnt-type = entry (lookup (string(buf_dis-rule.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U)
      v1-subject-type = entry (lookup (STRING(buf_dis-rule.subject-type), '0,1,2,3,4,5,7,8':U), 'Неизв,Товар,Подитог,Итог,Чек,Оплата,Товар_б/итог.скидки,Группа':U)
      v1-value-type = entry (lookup (STRING(buf_dis-rule.value-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U)
      .
      RUN get-tree IN THIS-PROCEDURE(
                                      BUFFER buf_dis-rule
                                      ,output buf_print-dis-rule.display-time-rule-num
                                      ,OUTPUT buf_print-dis-rule.display-dis-kat
                                      ,OUTPUT buf_print-dis-rule.display-doc-qnty
                                      ,OUTPUT buf_print-dis-rule.display-tot-sum
                                      ,OUTPUT buf_print-dis-rule.display-charkey_one
                                      ,OUTPUT buf_print-dis-rule.display-charkey_two
                                      ,OUTPUT buf_print-dis-rule.display-charkey_three
                                      ,OUTPUT buf_print-dis-rule.display-deckey_one
                                      ,OUTPUT buf_print-dis-rule.display-deckey_two
                                      ,OUTPUT buf_print-dis-rule.display-deckey_three
                                      ,OUTPUT buf_print-dis-rule.display-key#_one
                                      ,OUTPUT buf_print-dis-rule.display-key#_two
                                      ,OUTPUT buf_print-dis-rule.display-key#_three
                                      ,OUTPUT buf_print-dis-rule.display-discnt-value
                                      ,output v-using-fields
                                      ) .
      assign
      v-h = br-dis-rule:FIRST-COLUMN IN FRAME Dialog-Frame
      v-char = '':U
      ii = 0
      .
      DO while valid-handle(v-h) :
        if v-h:name <> ?
        then do:
          assign
          v-realname = replace(v-h:name, "v-", "")
          v-realname2 = replace(v-h:name, "v-display-", "")
          .
          assign
          v-fh = buffer buf_print-dis-rule:buffer-field(v-realname) no-error .
          if valid-handle(v-fh)
          and lookup(v-realname2, v-using-fields) > 0
          then do:
            assign
            v-char = v-char + (if ii = 0 then '':U else chr(32) ) +
            string(v-fh:buffer-value, substitute("X(&1)", round(v-h:width, 0)))
            ii = ii + 1
            .
          end.
        end.
        v-h = v-h:NEXT-COLUMN.
      end.
      display STREAM PrnLibStream
      buf_dis-rule.des           @ X_dis-rule.des
      entry (lookup (STRING(buf_dis-rule.sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U)    @ v-sts-chr
      v1-region                  @ v-region
      v1-discnt-type             @ v-discnt-type
      v1-subject-type            @ v-subject-type
      v1-value-type              @ v-value-type
      buf_dis-rule.rule-num      @ X_dis-rule.rule-num
      v-char
      with FRAME dis-rule-list .
      DOWN STREAM PrnLibStream 1
      with FRAME dis-rule-list .
      .
    end.
    DOWN STREAM PrnLibStream 1
    with FRAME dis-rule-list .
    .
  end.
  GET next br-dis-rule.
END.
UNDERLINE  STREAM PrnLibStream
X_dis-rule.des
v-sts-chr
v-region
v-discnt-type
v-subject-type
v-value-type
X_dis-rule.rule-num
v-char
with FRAME dis-rule-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_dis-rule.des
accum-count @ v-sts-chr
with frame dis-rule-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME dis-rule-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-dis-rule to recid v-doc-rec no-error.
APPLY "entry" to br-dis-rule.
run waitfram-hide in this-procedure .
if true   then do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
end.
else do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input (if frame dis-rule-list:width <= 255 then 1 else 20)
                                            ).
end.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'dis-rule'
  join-tbl = 'X_dis-rule'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('des', 'Описание правила скидок', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
if not (p-mode = "template" or p-mode = "template-value-type") and not (p-upper-rule-num = 0 and p-mode = "upper-rule-num") then do:
  run fltfield-add in this-procedure('templ-rl-root', 'Номер типа(шаблона) правила', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('host-code', 'Фирма', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('discnt-value', 'Значение скидки', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
end.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT filter-point + chr(4) + filter-label
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
PROCEDURE proc-b-stat :
define input parameter p-doc-rec as recid no-undo .
define variable v-sts like ub.dis-rule.sts no-undo .
define buffer loc_dis-rule for ub.dis-rule.
do
on error undo, return error
:
  find first loc_dis-rule exclusive-lock where
            recid(loc_Dis-rule) = p-doc-rec no-error .
  v-sts =?.
 if not available loc_dis-rule then do:
    message
    "Запись уже отсутствует или недоступна"
    view-as alert-box warning.
    return.
  end.
  run ref/dis-rul2.p (
                    buffer loc_dis-rule
                  , input no
                  , input ?
                  , input-output v-sts
                  ) no-error.
  if error-status:error then do:
    if error-status:get-message(1) <> '':U
    or return-value <> '':U then
    message
    error-status:get-message(1) skip
    return-value
    view-as alert-box .
  end.
end.
END PROCEDURE.
PROCEDURE proc-b-time-rule :
define variable loc-doc-rec as recid no-undo .
define variable v-sts as integer no-undo init -1.
define variable v-rid-list as character no-undo .
IF NOT AVAILABLE X_dis-rule THEN RETURN no-apply.
if not can-find(first ub.dis-cfg-rule where
                    ub.dis-cfg-rule.templ-rl-root = X_dis-rule.templ-rl-root
                and  ub.dis-cfg-rule.time-templ-rl-root > 0)
then do:
  message
  "С правилами скидок данных типов не может быть связано расписание"
  view-as alert-box error .
  return no-apply.
end.
if X_dis-rule.lvl-num = 0 then do:
  run ref/dist-rls.w (
                  input parparentproc
                ,input "b-add"
                ,input "dis-rule"
                ,input X_dis-rule.templ-rl-root
                ,input 0
                ,input ''
                ,input-output v-sts
                ,input-output v-rid-list) no-error .
end.
else do:
  if lookup("time-rule-num", X_dis-rule.uniq-field) > 0 then do:
      run ref/dist-rls.w (
                    input parparentproc
                    ,input ""
                    ,input "rule-num"
                    ,input (if X_dis-rule.lvl-num = 1
                        then X_dis-rule.rule-num
                        else X_dis-rule.upper-rule-num)
                    ,input 0
                    ,input ''
                    ,input-output v-sts
                    ,input-output v-rid-list) no-error .
  end.
  else do:
    if X_dis-rule.time-rule-num <> 0 then
    run ref/dis-timi.w (
                  input parParentProc
                , input 'ПРОСМОТР':U
                , input 0
                , input  X_dis-rule.time-rule-num
                , input 0
                , input-output loc-doc-rec
                ) no-error .
  end.
end.
APPLY "ENTRY" TO br-dis-rule in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-br-dis-rule :
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if b-sel:sensitive in frame Dialog-Frame then dO:
    if b-mark:sensitive then do:
        apply "choose" to b-mark in frame Dialog-Frame.
    end.
    else do:
        apply "choose" to b-sel in frame Dialog-Frame.
    end.
end.
else do:
    if b-lookup:sensitive then
    apply "choose" to b-lookup in frame Dialog-Frame.
end.
END PROCEDURE.
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-dis-rule FOR ub.dis-rule, input mark-list as CHARACTER ) :
  RUN get-tree IN THIS-PROCEDURE(
                                  BUFFER loc-dis-rule
                                  ,output v-display-time-rule-num
                                  ,OUTPUT v-display-dis-kat
                                  ,OUTPUT v-display-doc-qnty
                                  ,OUTPUT v-display-tot-sum
                                  ,output v-display-charkey_one
                                  ,output v-display-charkey_two
                                  ,output v-display-charkey_three
                                  ,output v-display-deckey_one
                                  ,output v-display-deckey_two
                                  ,output v-display-deckey_three
                                  ,output v-display-key#_one
                                  ,output v-display-key#_two
                                  ,output v-display-key#_three
                                  ,OUTPUT v-display-discnt-value
                                  ,output v-using-fields
                              ).
RETURN ( IF LOOKUP( STRING( RECID( loc-dis-rule ) ), mark-list ) > 0 THEN "*" ELSE "":U ).
END FUNCTION.
