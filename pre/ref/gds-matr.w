DEFINE BUFFER Buf_goods FOR ub.goods.
DEFINE BUFFER Buf_matrix-goods FOR ub.assortment-matrix-goods.
define input  parameter parParentProc AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-id        like ub.assortment-matrix.asmt-id  no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input  parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input  parameter p-mode  as character no-undo .
define variable bttns   as character no-undo init "b-add".
if p-mode = "no-button"  then bttns = "" .
define variable p-sts   as integer   no-undo .
define variable p-rid-list                    as character no-undo .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-log as logical   no-undo .
define variable is-shablonLink as logical   no-undo .
define variable is-objLink as logical   no-undo .
define variable is-objLink-id as integer   no-undo .
define variable is-objLink-db as integer   no-undo .
define variable del-option     as character no-undo .
define buffer buf_matrix for ub.assortment-matrix .
find first buf_matrix no-lock where
           buf_matrix.asmt-id  = p-id     and
           buf_matrix.db-num   = p-db-num no-error .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ассортиментныая матрица".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#lib-Matrix  as handle no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-ind1 :
main-block:
  do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
define input-output parameter p-doc-rec  as recid no-undo.
define input  parameter p-gds-code                   like  ub.gds-obj-prop.gds-code no-undo.
define input  parameter p-obj-type                   like  ub.gds-obj-prop.obj-type no-undo.
define input  parameter p-obj-code                   like  ub.gds-obj-prop.obj-code no-undo.
define input  parameter p-gdop-igt                   like  ub.gds-obj-prop.gdop-igt no-undo.
define input  parameter p-gdop-assort-min            like  ub.gds-obj-prop.gdop-assort-min  no-undo.
define input  parameter p-gdop-min-stock             like  ub.gds-obj-prop.gdop-min-stock   no-undo.
define input  parameter p-grop-level-always-presence like  ub.gds-obj-prop.grop-level-always-presence  no-undo.
define input  parameter p-grop-max-stock             like  ub.gds-obj-prop.grop-max-stock              no-undo.
define input  parameter p-grop-min-order             like  ub.gds-obj-prop.grop-min-order              no-undo.
define buffer bufs_gds-obj-prop for ub.gds-obj-prop.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-db-num-obj like ub.db.db-num no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
run cur-time in this-procedure(output v-date, output v-time).
  find first bufs_gds-obj-prop exclusive-lock where
            bufs_gds-obj-prop.gds-code          = p-gds-code   and
            bufs_gds-obj-prop.obj-type          = p-obj-type   and
            bufs_gds-obj-prop.obj-code          = p-obj-code  no-error .
    if not available bufs_gds-obj-prop then do:
        create bufs_gds-obj-prop.
        assign
            bufs_gds-obj-prop.gds-code           = p-gds-code
            bufs_gds-obj-prop.grop-date-update   = v-date
            bufs_gds-obj-prop.grop-time-update   = v-time
            bufs_gds-obj-prop.grop-db-num-update = v-db-num
            bufs_gds-obj-prop.obj-type           = p-obj-type
            bufs_gds-obj-prop.obj-code           = p-obj-code
        no-error .
        if error-status :error then message "Ошибка при создании записи" error-status :error error-status :get-message(1) .
    end.
if  p-gdop-igt                     <> ? then    bufs_gds-obj-prop.gdop-igt                   = p-gdop-igt.
if  p-gdop-assort-min              <> ? then    bufs_gds-obj-prop.gdop-assort-min            = p-gdop-assort-min.
if  p-gdop-min-stock               <> ? then    bufs_gds-obj-prop.gdop-min-stock             = p-gdop-min-stock  .
if  p-grop-level-always-presence   <> ? then    bufs_gds-obj-prop.grop-level-always-presence = p-grop-level-always-presence.
if  p-grop-max-stock               <> ? then    bufs_gds-obj-prop.grop-max-stock             = p-grop-max-stock           .
if  p-grop-min-order               <> ? then    bufs_gds-obj-prop.grop-min-order             = p-grop-min-order           .
      p-doc-rec = recid(bufs_gds-obj-prop)    .
end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-longchar-asstro  as longchar no-undo .
define temp-table temp-goods no-undo
  field gds-code as integer
  field status_  as integer
  index pi gds-code
.
PROCEDURE translate-to-other :
define input  parameter p-asmt-id as integer   no-undo .
define input  parameter p-db-num  as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-recid as recid no-undo .
define buffer Oth_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer obj_assortment-matrix for ub.assortment-matrix  .
define buffer sh_assortment-matrix for ub.assortment-matrix  .
define buffer bufs_gds-obj-prop for ub.gds-obj-prop  .
  find first  sh_assortment-matrix no-lock where
              sh_assortment-matrix.asmt-id = p-asmt-id and
              sh_assortment-matrix.db-num  = p-db-num  and
              sh_assortment-matrix.asmt-status = 0 and
              sh_assortment-matrix.asmt-type = 'Шаблон':U no-error .
if not available sh_assortment-matrix then return .
define variable v-doc-rec as recid no-undo .
define variable v-gds-prop-recid as recid no-undo .
define variable v-stt as integer   no-undo .
v-longchar-asstro = "".
   run waitfram-show in this-procedure  ("Передача изменений в связанные матрицы ... " ) .
   for each obj_assortment-matrix no-lock where
            obj_assortment-matrix.asmt-status = 0 and
            obj_assortment-matrix.asmt-type = 'Объект':U ,
      first ub.assortment-matrix-attr no-lock where
            ub.assortment-matrix-attr.asmt-id    = obj_assortment-matrix.asmt-id and
            ub.assortment-matrix-attr.db-num     = obj_assortment-matrix.db-num and
            ub.assortment-matrix-attr.attr-code  = 'RootShablon':U and
            ub.assortment-matrix-attr.attr-value = substitute("&1&3&2" , p-asmt-id, p-db-num,chr(4))
            :
        run waitfram-show in this-procedure ( substitute(" Передаю изменения в Матрицу: &1" ,obj_assortment-matrix.asmt-name )) .
        for each temp-goods :
           if temp-goods.status_ = 0 then do:
                find first Oth_assortment-matrix-goods no-lock where
                            Oth_assortment-matrix-goods.asmt-id  = ub.assortment-matrix-attr.asmt-id and
                            Oth_assortment-matrix-goods.db-num   = ub.assortment-matrix-attr.db-num  and
                            Oth_assortment-matrix-goods.gds-code = temp-goods.gds-code and
                            Oth_assortment-matrix-goods.asmg-status = 0 no-error .
                    if not available Oth_assortment-matrix-goods then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat1 in g#lib-Matrix
 (input this-procedure
 ,input-output v-doc-rec
 ,input 'ДОБАВЛЕНИЕ':U
 ,input ub.assortment-matrix-attr.asmt-id
 ,input ub.assortment-matrix-attr.db-num
 ,input temp-goods.gds-code
 ,input ''
  ) no-error .
                        if error-status :error then do:
                          v-longchar-asstro = v-longchar-asstro + return-value + chr(10) .
                          next.
                        end.
                    end.
              end.
              else do:
                v-stt = 1.
                find first Oth_assortment-matrix-goods no-lock where
                            Oth_assortment-matrix-goods.asmt-id  = ub.assortment-matrix-attr.asmt-id and
                            Oth_assortment-matrix-goods.db-num   = ub.assortment-matrix-attr.db-num  and
                            Oth_assortment-matrix-goods.gds-code = temp-goods.gds-code and
                            Oth_assortment-matrix-goods.asmg-status = 0 no-error .
                    if available Oth_assortment-matrix-goods then do:
                        v-recid = recid(Oth_assortment-matrix-goods).
                        find first bufs_gds-obj-prop exclusive-lock where
                                   bufs_gds-obj-prop.gds-code = Oth_assortment-matrix-goods.gds-code   and
                                   bufs_gds-obj-prop.obj-type = Oth_assortment-matrix-goods.obj-type   and
                                   bufs_gds-obj-prop.obj-code = Oth_assortment-matrix-goods.obj-code  no-error .
                        if not available bufs_gds-obj-prop
                          or not (bufs_gds-obj-prop.gdop-igt = 'Пусто':U or
                                  bufs_gds-obj-prop.gdop-igt = 'На вывод из ассортимента':U ) then do:
                        v-longchar-asstro = v-longchar-asstro +
                        substitute("Принудительная смена ИЖТ_ товара &1  на ПУСТО на объекте &2&3&4" ,
                            Oth_assortment-matrix-goods.gds-code ,
                            Oth_assortment-matrix-goods.obj-type ,
                            Oth_assortment-matrix-goods.obj-code ,
                            chr(10)) .
                        run gds-ind1
                            (input-output v-gds-prop-recid
                            ,Oth_assortment-matrix-goods.gds-code
                            ,Oth_assortment-matrix-goods.obj-type
                            ,Oth_assortment-matrix-goods.obj-code
                            ,'Пусто':U
                            ,?
                            ,?
                            ,?
                            ,?
                            ,?
                            ) no-error  .
                          end.
                          if not error-status :error then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat2 in g#lib-Matrix
 (input this-procedure
 ,input v-recid
 ,input-output v-stt
 ,input no
  ) no-error .
                                if error-status :error then do:
                                   v-longchar-asstro = v-longchar-asstro + return-value + chr(10) .
                                end.
                           end.
                           else do:
                              v-longchar-asstro = v-longchar-asstro + return-value + chr(10) .
                           end.
                    end.
               end.
        end.
   end.
   run waitfram-hide in this-procedure.
end.
END PROCEDURE.
PROCEDURE translate-to-other-gds :
define input  parameter p-asmt-id  as integer   no-undo .
define input  parameter p-db-num   as integer   no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-status_  as integer   no-undo .
  do
  on error undo, return error return-value
  :
define buffer Oth_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer obj_assortment-matrix for ub.assortment-matrix  .
define buffer sh_assortment-matrix for ub.assortment-matrix  .
define buffer bufs_gds-obj-prop for ub.gds-obj-prop  .
  find first  sh_assortment-matrix no-lock where
              sh_assortment-matrix.asmt-id = p-asmt-id and
              sh_assortment-matrix.db-num  = p-db-num  and
              sh_assortment-matrix.asmt-status = 0 and
              sh_assortment-matrix.asmt-type = 'Шаблон':U no-error .
if not available sh_assortment-matrix then return .
define variable v-doc-rec as recid no-undo .
define variable v-gds-prop-recid as recid no-undo .
define variable v-stt as integer   no-undo .
define variable v-recid as recid no-undo .
 v-longchar-asstro = "" .
   for each obj_assortment-matrix no-lock where
            obj_assortment-matrix.asmt-status = 0 and
            obj_assortment-matrix.asmt-type = 'Объект':U ,
      first ub.assortment-matrix-attr no-lock where
            ub.assortment-matrix-attr.asmt-id    = obj_assortment-matrix.asmt-id and
            ub.assortment-matrix-attr.db-num     = obj_assortment-matrix.db-num and
            ub.assortment-matrix-attr.attr-code  = 'RootShablon':U and
            ub.assortment-matrix-attr.attr-value = substitute("&1&3&2" , p-asmt-id, p-db-num,chr(4))
            :
           if p-status_ = 0 then do:
                find first Oth_assortment-matrix-goods no-lock where
                            Oth_assortment-matrix-goods.asmt-id  = ub.assortment-matrix-attr.asmt-id and
                            Oth_assortment-matrix-goods.db-num   = ub.assortment-matrix-attr.db-num  and
                            Oth_assortment-matrix-goods.gds-code = p-gds-code and
                            Oth_assortment-matrix-goods.asmg-status = 0 no-error .
                    if not available Oth_assortment-matrix-goods then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat1 in g#lib-Matrix
 (input this-procedure
 ,input-output v-doc-rec
 ,input 'ДОБАВЛЕНИЕ':U
 ,input ub.assortment-matrix-attr.asmt-id
 ,input ub.assortment-matrix-attr.db-num
 ,input p-gds-code
 ,input ''
  ) no-error .
                        if error-status :error then do:
                           v-longchar-asstro = v-longchar-asstro + return-value + chr(10) .
                           next.
                        end.
                    end.
              end.
              else do:
                v-stt = 1.
                find first Oth_assortment-matrix-goods no-lock where
                            Oth_assortment-matrix-goods.asmt-id  = ub.assortment-matrix-attr.asmt-id and
                            Oth_assortment-matrix-goods.db-num   = ub.assortment-matrix-attr.db-num  and
                            Oth_assortment-matrix-goods.gds-code = p-gds-code and
                            Oth_assortment-matrix-goods.asmg-status = 0 no-error .
                    if available Oth_assortment-matrix-goods then do:
                        v-recid = recid(Oth_assortment-matrix-goods) .
                        find first bufs_gds-obj-prop exclusive-lock where
                                   bufs_gds-obj-prop.gds-code = Oth_assortment-matrix-goods.gds-code   and
                                   bufs_gds-obj-prop.obj-type = Oth_assortment-matrix-goods.obj-type   and
                                   bufs_gds-obj-prop.obj-code = Oth_assortment-matrix-goods.obj-code  no-error .
                        if not available bufs_gds-obj-prop
                          or not (bufs_gds-obj-prop.gdop-igt = 'Пусто':U or
                                  bufs_gds-obj-prop.gdop-igt = 'На вывод из ассортимента':U ) then do:
                        v-longchar-asstro = v-longchar-asstro +
                        substitute("Принудительная смена ИЖТ. товара &1  на ПУСТО на объекте &2&3&4" ,
                            Oth_assortment-matrix-goods.gds-code ,
                            Oth_assortment-matrix-goods.obj-type ,
                            Oth_assortment-matrix-goods.obj-code ,
                            chr(10)) .
                        run gds-ind1
                            (input-output v-gds-prop-recid
                            ,Oth_assortment-matrix-goods.gds-code
                            ,Oth_assortment-matrix-goods.obj-type
                            ,Oth_assortment-matrix-goods.obj-code
                            ,'Пусто':U
                            ,?
                            ,?
                            ,?
                            ,?
                            ,?
                            ) no-error  .
                           end.
                           if not error-status :error then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat2 in g#lib-Matrix
 (input this-procedure
 ,input v-recid
 ,input-output v-stt
 ,input no
  ) no-error .
                                if error-status :error then do:
                                   v-longchar-asstro = v-longchar-asstro + return-value + chr(10) .
                                end.
                           end.
                           else do:
                             v-longchar-asstro = v-longchar-asstro + return-value + chr(10) .
                           end.
                    end.
               end.
   end.
end.
END PROCEDURE.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure correct-message :
define input  parameter p-longchar as longchar no-undo .
define variable v-longchar as longchar no-undo .
define variable v-err-ext  as logical  no-undo .
  do
  on error undo, return error return-value
  :
   run get-long-message in this-procedure  (output v-longchar ).
    v-longchar = v-longchar + p-longchar.
    v-err-ext  = true .
    run set-long-message  in this-procedure  (input v-longchar,  input v-err-ext ).
  end.
end procedure.
define variable v-longchar as longchar no-undo .
define variable v-err-ext as logical   no-undo .
procedure get-long-message  :
define output parameter p-longchar  as longchar no-undo .
  do
  on error undo, return error return-value
  :
     p-longchar = v-longchar .
  end.
end procedure.
procedure set-long-message :
define input  parameter  p-longchar as longchar   no-undo .
define input  parameter  p-err-ext as logical   no-undo .
  do
  on error undo, return error return-value
  :
    v-longchar  =  p-longchar .
    v-err-ext   =  p-err-ext  .
  end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure assmatat-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-value :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-value in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-write :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define input parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-write in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-exist :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-exist in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-delete :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code     like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-delete in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
DEFINE VARIABLE vss-include-info19 AS CHARACTER FORMAT "x(65)" NO-UNDO INITIAL "@(#)$Workfile$ $Revision$".
FUNCTION indicator-life-gds-n RETURNS CHARACTER ( input p-rec as recid ) FORWARD.
DEFINE VARIABLE v-gl-iProc-Otkl AS DECIMAL NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-lAM-Is-Obj         AS LOGICAL NO-UNDO INITIAL FALSE.
DEFINE VARIABLE v-gl-iAM-Gds-All        AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-iAM-Sbl-Gds-All    AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-iAM-Gds-Vyv        AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-lAM-Ref-Shablon    AS LOGICAL NO-UNDO INITIAL FALSE.
DEFINE VARIABLE v-gl-dAM-Proc-Otkl      AS DECIMAL NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-dAM-Proc-Otkl-Ras  AS DECIMAL NO-UNDO INITIAL 0.
FUNCTION Is-Gds-In-AssMatr RETURN LOGICAL(
   p-Gds-code AS INTEGER,
   p-Asmt-id  AS INTEGER,
   p-Db-num   AS INTEGER):
   DEFINE BUFFER buf_Gds FOR Ub.Assortment-matrix-goods.
   RETURN CAN-FIND(FIRST buf_Gds WHERE
                         buf_Gds.Asmt-id     = p-Asmt-id
                     AND buf_Gds.Db-num      = p-Db-num
                     AND buf_Gds.Gds-code    = p-Gds-code
                     AND buf_Gds.Asmg-status = INTEGER('0':U)
                   NO-LOCK).
END FUNCTION.
PROCEDURE Get-Delta-Gds-2-Matrix:
   DEFINE PARAMETER BUFFER buf_AM-1 FOR ub.Assortment-matrix.
   DEFINE PARAMETER BUFFER buf_AM-2 FOR ub.Assortment-matrix.
   DEFINE OUTPUT PARAMETER iDelta AS INTEGER NO-UNDO INITIAL 0.
   DEFINE BUFFER buf_Gds-1 FOR ub.Assortment-matrix-goods.
   DEFINE BUFFER buf_Gds-2 FOR ub.Assortment-matrix-goods.
   FOR EACH buf_Gds-1 WHERE
            buf_Gds-1.Asmt-id = buf_AM-1.Asmt-id
        AND buf_Gds-1.Db-num  = buf_AM-1.Db-num
        AND buf_Gds-1.Asmg-status = INTEGER('0':U)
       NO-LOCK:
       IF NOT CAN-FIND(FIRST buf_Gds-2 WHERE
                             buf_Gds-2.Asmt-id     = buf_AM-2.Asmt-id
                         AND buf_Gds-2.Db-num      = buf_AM-2.Db-num
                         AND buf_Gds-2.Gds-code    = buf_Gds-1.Gds-code
                         AND buf_Gds-2.Asmg-status = INTEGER('0':U)
                         NO-LOCK) THEN DO:
          ASSIGN
             iDelta = iDelta + 1.
       END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Cntrl-AM-Add-1:
   DEFINE INPUT PARAMETER iDelta  AS INTEGER   NO-UNDO.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   IF v-gl-iProc-Otkl = 0      THEN RETURN.
   IF NOT v-gl-lAM-Is-Obj      THEN RETURN.
   IF NOT v-gl-lAM-Ref-Shablon THEN RETURN.
   RUN Calc-Proc-Otkl IN THIS-PROCEDURE(iDelta).
   IF iDelta = 0 THEN DO:
      IF v-gl-dAM-Proc-Otkl >= v-gl-iProc-Otkl THEN DO:
         cError = "В данной матрице процент отклонения товаров от шаблона (=" + STRING(v-gl-dAM-Proc-Otkl) + ")" + chr(10) +
                  " больше допустимого (=" + STRING( v-gl-iProc-Otkl) +  ")." + chr(10) +
                  "Добавление товаров невозможно !".
      END.
   END. ELSE DO:
      IF v-gl-dAM-Proc-Otkl-Ras >= v-gl-iProc-Otkl THEN DO:
         cError = "В данной матрице будущий расчетный процент отклонения товаров от шаблона (=" + STRING(v-gl-dAM-Proc-Otkl-Ras) + ")" + chr(10) +
                  " больше допустимого (=" + STRING( v-gl-iProc-Otkl ) +  ")." + chr(10) +
                  " Добавление товаров невозможно !".
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Get-Gl-Param-Proc-Otkl:
   DEFINE INPUT PARAMETER   p-Asmt-Id AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Db-num  AS INTEGER    NO-UNDO.
   DEFINE OUTPUT PARAMETER  cError    AS CHARACTER  NO-UNDO INITIAL "".
   DEFINE BUFFER buf_AM   FOR ub.Assortment-Matrix.
   FIND FIRST buf_AM WHERE
              buf_AM.asmt-id = p-Asmt-id
          AND buf_AM.db-num  = p-Db-num
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_AM THEN DO:
      cError = PROGRAM-NAME(1) +  ":Не найдена АМ id=" + STRING(p-Asmt-id) + " db-num=" + STRING(p-Db-num).
      RETURN.
   END.
   RUN Get-Gl-Set-Proc-Otkl IN THIS-PROCEDURE(
       buf_AM.obj-type,
       buf_AM.obj-code
       ).
   RUN Get-Gl-Param-AM-All in THIS-PROCEDURE(
       buf_AM.Asmt-id,
       buf_AM.db-num
       ).
   RETURN.
END PROCEDURE.
PROCEDURE Get-Gl-Param-AM-All:
   DEFINE INPUT PARAMETER   p-Asmt-Id AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Db-num  AS INTEGER    NO-UNDO.
   DEFINE VARIABLE lIsAmObj    AS LOGICAL    NO-UNDO INITIAL FALSE.
   DEFINE VARIABLE iSh-Asmt-id AS INTEGER    NO-UNDO INITIAL 0.
   DEFINE VARIABLE iSh-Db-num  AS INTEGER    NO-UNDO INITIAL 0.
   DEFINE VARIABLE cSh-Type    AS CHARACTER  NO-UNDO INITIAL "".
   DEFINE VARIABLE cError      AS CHARACTER  NO-UNDO INITIAL "".
   DEFINE VARIABLE dAmt        AS DECIMAL    EXTENT 2  NO-UNDO INITIAL 0.
   DEFINE VARIABLE cMode       AS CHARACTER  NO-UNDO INITIAL "".
   ASSIGN
      v-gl-iAM-Gds-All     = 0
      v-gl-iAM-Sbl-Gds-All = 0
      v-gl-iAM-Gds-Vyv     = 0
      v-gl-dAM-Proc-Otkl   = 0
      v-gl-lAM-Ref-Shablon = FALSE
      .
   RUN Get-Param-AM IN THIS-PROCEDURE (
       p-Asmt-id,
       p-Db-num,
       OUTPUT lIsAmObj,
       OUTPUT iSh-Asmt-id,
       OUTPUT iSh-Db-num,
       OUTPUT cSh-Type,
       OUTPUT cError
       ).
   IF cError <> "" THEN DO:
      MESSAGE
         PROGRAM-NAME(1) ":" SKIP
         "Такого быть не должно !!!" SKIP
         cError SKIP
         VIEW-AS ALERT-BOX INFO BUTTONS OK.
      RETURN.
   END.
   ASSIGN
      cMode                 = (IF lIsAmObj THEN "IL_GDS":U ELSE "")
      v-gl-lAM-Ref-Shablon  = (IF iSh-Asmt-id = 0 THEN FALSE ELSE TRUE)
      .
   RUN Get-Param-AM-Gds IN THIS-PROCEDURE(
       p-Asmt-Id,
       p-Db-num,
       '0':U,
       cMode,
       OUTPUT dAmt
       ).
   ASSIGN
      v-gl-iAM-Gds-All = dAmt[1]
      v-gl-iAM-Gds-Vyv = (IF lIsAmObj THEN dAmt[2] ELSE 0)
      .
    IF NOT v-gl-lAM-Ref-Shablon THEN DO:
       RETURN.
    END.
   RUN Get-Param-AM-Gds IN THIS-PROCEDURE(
       iSh-Asmt-id,
       iSh-Db-num,
       '0':U,
       "",
       OUTPUT dAmt
       ).
   ASSIGN
      v-gl-iAM-Sbl-Gds-All = dAmt[1].
   RUN Calc-Proc-Otkl IN THIS-PROCEDURE(0).
   RETURN.
END PROCEDURE.
PROCEDURE Get-Param-AM-Gds:
   DEFINE INPUT PARAMETER   p-Asmt-Id AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Db-num  AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Stat    AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Mode    AS CHARACTER  NO-UNDO.
   DEFINE OUTPUT PARAMETER  o-dAmt    AS DECIMAL    EXTENT 2 NO-UNDO INITIAL 0.
   DEFINE BUFFER buf_AM-goods FOR ub.Assortment-matrix-goods.
   FOR EACH buf_AM-goods WHERE
            buf_AM-goods.Asmt-id      = p-Asmt-Id
        AND buf_AM-goods.Db-num       = p-Db-num
        AND buf_AM-goods.asmg-status  = p-Stat
       NO-LOCK:
       ASSIGN
          o-dAmt[1] = o-dAmt[1] + 1.
       IF CAN-DO("IL_GDS":U, p-Mode) THEN DO:
          IF Indicator-life-gds-n(recid(buf_AM-goods)) = 'На вывод из ассортимента':U THEN DO:
             ASSIGN
                o-dAmt[2] = o-dAmt[2] + 1.
          END.
       END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Get-Param-AM:
   DEFINE INPUT  PARAMETER  p-Asmt-id   AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER  p-Db-num    AS INTEGER   NO-UNDO.
   DEFINE OUTPUT PARAMETER  lIsObj      AS LOGICAL   NO-UNDO INITIAL FALSE.
   DEFINE OUTPUT PARAMETER  o-Asmt-id   AS INTEGER   NO-UNDO INITIAL 0.
   DEFINE OUTPUT PARAMETER  o-Db-Num    AS INTEGER   NO-UNDO INITIAL 0.
   DEFINE OUTPUT PARAMETER  v-Type      AS CHARACTER NO-UNDO INITIAL "".
   DEFINE OUTPUT PARAMETER  cError      AS CHARACTER NO-UNDO INITIAL "".
   DEFINE VARIABLE v-value AS  CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_AM   FOR ub.Assortment-Matrix.
   DEFINE BUFFER buf_AM-2 FOR ub.Assortment-Matrix.
   ASSIGN
      v-gl-lAM-Is-Obj = FALSE.
   FIND FIRST buf_AM WHERE
              buf_AM.asmt-id = p-Asmt-id
          AND buf_AM.db-num  = p-Db-num
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_AM THEN DO:
      cError = "Не найдена АМ id=" + STRING(p-Asmt-id) + " db-num=" + STRING(p-Db-num).
      RETURN.
   END.
   IF buf_AM.asmt-type <> 'Объект':U THEN DO:
      RETURN.
   END. ELSE DO:
      ASSIGN
         lIsObj           = TRUE
         v-gl-lAM-Is-Obj  = TRUE
         .
   END.
   run assmatat-value (
       input buf_AM.asmt-id
      ,input buf_AM.db-num
      ,input 'RootShablon':U
      ,output v-value
      ,output v-type
      ) .
   IF v-value = "" OR v-value = ? THEN DO:
      RETURN.
   END.
   ASSIGN
      o-Asmt-id = INTEGER(ENTRY(1, v-value, chr(4)))
      o-Db-num  = INTEGER(ENTRY(2, v-value, chr(4)))
      NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      cError = PROGRAM-NAME(1) + ":" + ERROR-STATUS:GET-MESSAGE(1).
      RETURN.
   END.
   FIND FIRST buf_AM-2 WHERE
              buf_AM-2.asmt-id = o-Asmt-id
          AND buf_AM-2.db-num  = o-Db-num
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_AM-2 THEN DO:
      cError = "Не найден шаблон АМ id=" + STRING(o-Asmt-id) + " db-num=" + STRING(o-Db-num).
      RETURN.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Get-Gl-Set-Proc-Otkl:
   DEFINE INPUT PARAMETER  cObj-type AS CHARACTER NO-UNDO.
   DEFINE INPUT PARAMETER  iObj-code AS INTEGER   NO-UNDO.
   DEFINE VARIABLE v-Character   AS CHARACTER  NO-UNDO .
   DEFINE VARIABLE v-Date        AS DATE       NO-UNDO .
   DEFINE VARIABLE v-Decimal     AS DECIMAL    NO-UNDO .
   DEFINE VARIABLE v-Integer     AS INTEGER    NO-UNDO .
   DEFINE VARIABLE v-Logical     AS LOGICAL    NO-UNDO .
   DEFINE VARIABLE v-Param-Type  AS CHARACTER  NO-UNDO .
   ASSIGN
      v-gl-iProc-Otkl = 0
      .
   EMPTY TEMP-TABLE thbjattr_thbj-attr .
   RUN adm/shattri.p (
           INPUT  "get":U,
           INPUT  cObj-type,
           INPUT  iObj-code,
           INPUT  'Ass-obj':U,
           INPUT  'ass-proc-matr-shabl':U ,
           OUTPUT v-Character,
           OUTPUT v-Date,
           OUTPUT v-Decimal,
           OUTPUT v-Integer,
           OUTPUT v-Logical,
           OUTPUT v-Param-Type,
           INPUT-OUTPUT TABLE thbjattr_thbj-attr
       ) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      ASSIGN
         v-Integer  = 0
         v-Decimal  = 0.
   END. ELSE DO:
      ASSIGN
         v-gl-iProc-Otkl = v-Integer
         .
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Calc-Proc-Otkl:
   DEFINE INPUT PARAMETER iDeltaGds AS INTEGER NO-UNDO.
   DEFINE VARIABLE iTmp AS INTEGER NO-UNDO INITIAL 0.
   ASSIGN
      v-gl-dAM-Proc-Otkl     = 0
      v-gl-dAM-Proc-Otkl-Ras = 0
      .
   IF NOT v-gl-lAM-Ref-Shablon THEN DO:
      RETURN.
   END.
   IF v-gl-iAM-Sbl-Gds-All = 0 THEN DO:
      ASSIGN
         v-gl-dAM-Proc-Otkl     = 999999
         v-gl-dAM-Proc-Otkl-Ras = 999999
         .
      RETURN.
   END.
   ASSIGN
      iTmp = (v-gl-iAM-Gds-All - v-gl-iAM-Sbl-Gds-All)
      v-gl-dAM-Proc-Otkl     = ROUND(iTmp * 100 / v-gl-iAM-Sbl-Gds-All, 2)
      v-gl-dAM-Proc-Otkl-Ras = ROUND((iTmp + iDeltaGds)  * 100 / v-gl-iAM-Sbl-Gds-All, 2)
      .
   RETURN.
END PROCEDURE.
FUNCTION indicator-life-gds-n RETURNS CHARACTER
( input p-rec as recid ) :
define buffer buf_matrix-goods for ub.assortment-matrix-goods .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-assort-min                  as LOGICAL   NO-UNDO.
DEFINE variable v-indicator-life-gds          as CHARACTER NO-UNDO.
find first buf_matrix-goods no-lock where recid (buf_matrix-goods) = p-rec no-error .
if error-status :error then return '' .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_Matrix-goods.obj-type
  ,input  buf_Matrix-goods.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  buf_Matrix-goods.gds-code
  ,output v-assort-min
  ,output v-indicator-life-gds
  ,output v-gdop-min-stock
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
  return v-indicator-life-gds.
end function.
define variable mark-str  as character no-undo.
define variable v-doc-rec as recid no-undo.
define variable filter-point as character no-undo init "Ассортиментная матрица" .
define variable filter-point0 as character no-undo init "Состав_ассортиментной_матрицы" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark as character no-undo .
define variable p-shablon as logical   no-undo .
define variable p-indicator-life-gds as character no-undo .
define variable p-obj  as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status as character no-undo .
define variable gds-rec as recid no-undo .
define variable v-indicator-life-gds like  ub.gds-obj-prop.gdop-igt        column-label "ИЖТ" format "x(25)" no-undo .
define variable v-assort-min         like  ub.gds-obj-prop.gdop-assort-min column-label "AMin" format "*/ " no-undo .
define variable p-assort-min  as logical   no-undo .
define variable p-name as character no-undo .
define temp-table tt-gds-list no-undo like goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
define variable varschartic like price-list.artic initial " " no-undo.
define variable ref-list    as character no-undo.
v-err-ext = false  .
v-longchar = "".
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clear-longmess in g#lib-Matrix
   .
FUNCTION indicator-life-gds RETURNS CHARACTER
( input p-rec as recid ) :
define buffer buf_matrix-goods for ub.assortment-matrix-goods .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
find first buf_matrix-goods no-lock where recid (buf_matrix-goods) = p-rec no-error .
if error-status :error then return '' .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_Matrix-goods.obj-type
  ,input  buf_Matrix-goods.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  buf_Matrix-goods.gds-code
  ,output v-assort-min
  ,output v-indicator-life-gds
  ,output v-gdop-min-stock
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
  return v-indicator-life-gds.
end function.
FUNCTION f-shablon RETURNS logical
( input p-rec as recid ) :
define buffer buf_matrix-goods for ub.assortment-matrix-goods .
define buffer sh_assortment-matrix-goods for ub.assortment-matrix-goods  .
find first buf_matrix-goods no-lock where recid (buf_matrix-goods) = p-rec no-error .
if error-status :error then return no .
  if is-objLink = true  then do:
      find first sh_assortment-matrix-goods no-lock where
                 sh_assortment-matrix-goods.asmt-id = is-objLink-id and
                 sh_assortment-matrix-goods.db-num  = is-objLink-db and
                 sh_assortment-matrix-goods.asmg-status  = 0          and
                 sh_assortment-matrix-goods.gds-code   =  buf_matrix-goods.gds-code no-error .
        if available sh_assortment-matrix-goods then return true .
        else return false .
  end.
  else do:
    return true .
  end.
end function.
FUNCTION assort-min RETURNS logical
( input p-rec as recid ) :
define buffer buf_matrix-goods for ub.assortment-matrix-goods .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
find first buf_matrix-goods no-lock where recid (buf_matrix-goods) = p-rec no-error .
if error-status :error then return no .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_Matrix-goods.obj-type
  ,input  buf_Matrix-goods.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  buf_Matrix-goods.gds-code
  ,output v-assort-min
  ,output v-indicator-life-gds
  ,output v-gdop-min-stock
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
  return v-assort-min.
end function.
define buffer pos_assortment-matrix for ub.assortment-matrix.
DEFINE MENU menu-del
  MENU-ITEM m_del1   LABEL "удалить - отмеченные"
  MENU-ITEM m_del2   LABEL "удалить - по списку".
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg-izt
     LABEL "И&ЖТ"
     SIZE 10 BY 1 TOOLTIP "Изменить ИЖТ по выделенным товарам".
DEFINE BUTTON B-copy
     LABEL "&Копировать из"
     SIZE 14 BY 1 TOOLTIP "Копировать из .... ".
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-grpAcc
     LABEL "По &группам"
     SIZE 14 BY 1 TOOLTIP "Иерархический интерфейс".
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 2.5 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-link-obj
     IMAGE-UP FILE "cmp/link-i.bmp":U
     IMAGE-DOWN FILE "cmp/link-i.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/link-i.bmp":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Есть привязанные АссМатрицы".
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-mark-all
     LABEL "&+"
     SIZE 3 BY 1 TOOLTIP "Отметить все".
DEFINE BUTTON B-mark-del-all
     LABEL "&-"
     SIZE 3 BY 1 TOOLTIP "Снять все отметки".
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 2.5 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "f"
     SIZE 2.5 BY .75.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE VARIABLE ED_asmg-des AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 72 BY 2 NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск:"
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 2.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sch-artic AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск по артиклу" NO-UNDO.
DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>>>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1 TOOLTIP "Поиск по коду" NO-UNDO.
DEFINE VARIABLE sch-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 37.5 BY 1 TOOLTIP "Поиск по началу Наименования" NO-UNDO.
DEFINE VARIABLE v-kol-all AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Всего в АМ"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Общее количество товаров в матрице(SCU) в статусе ТЕК" NO-UNDO.
DEFINE VARIABLE v-kol-del AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "На вывод"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Количество товаров в матрице(SCU) с ИЖТ на вывод из ассортимента в статусе ТЕК"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-kol-in-shabl AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "в шаблоне"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Общее количество товаров в матрице(SCU) в статусе ТЕК" NO-UNDO.
DEFINE VARIABLE v-proc-otkl AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "% отклонения"
      VIEW-AS TEXT
     SIZE 9 BY .67 TOOLTIP "Общее количество товаров в матрице(SCU) в статусе ТЕК" NO-UNDO.
DEFINE VARIABLE v-raznost AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "разность"
      VIEW-AS TEXT
     SIZE 8.5 BY .67 TOOLTIP "Общее количество товаров в матрице(SCU) в статусе ТЕК" NO-UNDO.
DEFINE VARIABLE v-user-name-corr AS CHARACTER FORMAT "X(256)":U
     LABEL "Изменил"
      VIEW-AS TEXT
     SIZE 20 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-user-name-create AS CHARACTER FORMAT "X(256)":U
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 20.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE a-n-c AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "А", 1,
"Н", 2,
"К", 3
     SIZE 12 BY 1 TOOLTIP "Поиск товара по Артиклу, Названию , Коду" NO-UNDO.
DEFINE VARIABLE RS-sts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текушие-", "1",
"Все-", "2",
"Удаленные3", "3"
     SIZE 31.38 BY 1 NO-UNDO.
DEFINE QUERY BROWSE-am-goods FOR
      Buf_matrix-goods,
      Buf_goods SCROLLING.
DEFINE BROWSE BROWSE-am-goods
  QUERY BROWSE-am-goods NO-LOCK DISPLAY
      mark-string(recid( buf_Matrix-goods) , p-rid-list) @ p-mark COLUMN-LABEL "*" FORMAT "x(1)":U
      f-shablon(recid( buf_Matrix-goods)) @ p-shablon COLUMN-LABEL " !Ш" FORMAT "+/-":U
      Buf_goods.artic FORMAT "X(16)":U COLUMN-LABEL 'Артикул! '
      STRING ( if Buf_goods.stts <> 0 then substring(Buf_goods.gds-name,1,15) + " <УДАЛЕН>"  else Buf_goods.gds-name ) @ p-name COLUMN-LABEL 'Название! ' FORMAT "X(30)":U
      Buf_matrix-goods.asmg-date-update COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      STRING (buf_Matrix-goods.asmg-time-update, 'HH:MM' ) FORMAT "x(5)":U  COLUMN-LABEL 'Время!изм '
      Buf_matrix-goods.asmg-db-num-update COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      Buf_matrix-goods.asmg-date-create COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      STRING (buf_Matrix-goods.asmg-time-create, 'HH:MM' )  FORMAT "x(5)":U COLUMN-LABEL "Время! "
      indicator-life-gds(recid( buf_Matrix-goods) ) @ p-indicator-life-gds COLUMN-LABEL "ИЖТ! " FORMAT "x(15)":U
      assort-min(recid( buf_Matrix-goods) ) @ p-assort-min COLUMN-LABEL "Acc!Min" FORMAT "*/":U
      Buf_matrix-goods.asmg-db-num-create COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
      entry (lookup (STRING(buf_Matrix-goods.asmg-status), '0,1,50,99':U), 'тек,удал,блок,удаление':U) @ p-status COLUMN-LABEL "Статус! " FORMAT "x(6)":U
      Buf_goods.grp-name COLUMN-LABEL "Группа! " FORMAT "x(45)":U
      Buf_goods.gds-code COLUMN-LABEL "Группа!код "
  ENABLE
      Buf_matrix-goods.asmg-db-num-update
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.5 BY 13.5 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-mark-all AT ROW 1 COL 14 WIDGET-ID 12
     B-mark-del-all AT ROW 1 COL 17 WIDGET-ID 14
     B-sel AT ROW 1 COL 23
     B-add AT ROW 1 COL 33
     B-lookup AT ROW 1 COL 43
     B-chg AT ROW 1 COL 53
     B-del AT ROW 1 COL 63
     B-copy AT ROW 1 COL 73.13
     B-print AT ROW 1 COL 92.38
     B-Help AT ROW 1 COL 95
     B-chg-izt AT ROW 2 COL 63 WIDGET-ID 10
     B-grpAcc AT ROW 2 COL 73.13 WIDGET-ID 8
     b-sch AT ROW 2 COL 95 WIDGET-ID 6
     RS-sts AT ROW 2.17 COL 9.63 NO-LABEL
     a-n-c AT ROW 3 COL 9.5 NO-LABEL
     sch-name AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     sch-code AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     sch-artic AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     B-link-obj AT ROW 3 COL 94.5 WIDGET-ID 16
     BROWSE-am-goods AT ROW 4.25 COL 1
     ED_asmg-des AT ROW 19.75 COL 25.5 NO-LABEL
     mark-num AT ROW 1 COL 18.25 COLON-ALIGNED NO-LABEL
     FILL-IN-1 AT ROW 2.13 COL 1.5 NO-LABEL
     FILL-IN-7 AT ROW 2.96 COL 2.5 NO-LABEL
     v-user-name-create AT ROW 17.75 COL 8.5 COLON-ALIGNED WIDGET-ID 2
     v-user-name-corr AT ROW 17.75 COL 74.5 COLON-ALIGNED WIDGET-ID 4
     v-kol-all AT ROW 18.75 COL 12.5 COLON-ALIGNED WIDGET-ID 18
     v-kol-in-shabl AT ROW 18.75 COL 35 COLON-ALIGNED WIDGET-ID 22
     v-raznost AT ROW 18.75 COL 58 COLON-ALIGNED WIDGET-ID 24
     v-proc-otkl AT ROW 18.75 COL 84.5 COLON-ALIGNED WIDGET-ID 26
     v-kol-del AT ROW 20.25 COL 12.5 COLON-ALIGNED WIDGET-ID 20
     SPACE(73.24) SKIP(0.86)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ассортиментная матрица".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-del:POPUP-MENU IN FRAME Dialog-Frame       = MENU menu-del:HANDLE.
ASSIGN
       B-link-obj:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-sch:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       sch-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       sch-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
OR ENDKEY OF FRAME Dialog-Frame
OR END-ERROR OF FRAME DIALOG-FRAME
DO:
  run gbl/markqwa.p
      ( input b-mark:sensitive
      , input p-rid-list ) no-error.
  if error-status:error then return no-apply.
  if buf_matrix.asmt-type <> 'Шаблон':U then return .
   run translate-to-other ( buf_matrix.asmt-id, buf_matrix.db-num ).
    if v-longchar-asstro <> ""  then do:
    define variable v-ok as logical   no-undo .
    run gbl/d-longchar.w (
            ?,
            'Editor_row=2\':u
          + 'title=При транслировании в Ассортиментные матрицы\':u
          + 'Editor_col=1\':u
          + 'Editor_width=96\':u
          + 'Editor_height=21\':u
          + 'readonly=yes\':u
        ,input-output v-longchar-asstro
        ,output v-ok ) no-error .
        v-longchar-asstro = "" .
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clear-longmess in g#lib-Matrix
   .
    end.
   return .
END.
ON VALUE-CHANGED OF a-n-c IN FRAME Dialog-Frame
DO:
  ASSIGN a-n-c .
  case a-n-c  :
  when 1 then do:
    enable sch-artic with frame Dialog-Frame .
    hide sch-name sch-code in frame Dialog-Frame .
  end.
  when 2 then do:
    enable sch-name with frame Dialog-Frame .
    hide sch-artic sch-code in frame Dialog-Frame .
  end.
  when 3  then do:
    enable sch-code with frame Dialog-Frame .
    hide sch-name sch-artic in frame Dialog-Frame .
  end.
  end case.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo.
  define variable loc-doc-rec as recid no-undo .
  DEFINE VARIABLE cError as CHARACTER NO-UNDO INITIAL "".
if  buf_matrix.asmt-status = 1  then do:
    message "Добавлять можно  в  АССОРТИМЕНТНУЮ МАТРИЦУ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.
run ver-db no-error .
if error-status :error then return no-apply .
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-gds_add-def':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return no-apply .
  RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
      0,
      OUTPUT cError
      ).
  if cError <> "" THEN DO:
     MESSAGE cError
         VIEW-AS ALERT-BOX INFO BUTTONS OK.
     RETURN NO-APPLY.
  END.
  run proc-add in this-procedure (output loc-doc-rec ) no-error  .
  if error-status:error then DO:
     message
  error-status :get-message(1)
  return-value
  view-as alert-box error
  .
     RETURN NO-APPLY.
  END.
  if loc-doc-rec <> ? THEN DO:
      run openbr in this-procedure .
      reposition BROWSE-am-goods to recid loc-doc-rec no-error.
      if error-status:error then do:                           find first pos_assortment-matrix no-lock where                                   recid(pos_assortment-matrix) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи AM" skip                            string(if avail pos_assortment-matrix                                     then  substitute("Вн код AM: &1"                                                     , pos_assortment-matrix.asmt-id)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
     RUN Calc-itogi in THIS-PROCEDURE.
  END.
  apply "entry" to BROWSE-am-goods in frame Dialog-Frame.
  apply "value-changed" to BROWSE-am-goods in frame Dialog-Frame.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available Buf_matrix-goods then return no-apply.
if  Buf_matrix-goods.asmg-status = 1  then do:
    message "Корректировать можно только запись в статусе  ТЕК."
    view-as alert-box information .
    return no-apply.
end.
run ver-db no-error .
if error-status :error then return no-apply .
if  buf_matrix.asmt-status = 1  then do:
    message "Корректировать можно  в  АССОРТИМЕНТНОЙ МАТРИЦЕ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.
assign
loc-doc-rec = recid(Buf_matrix-goods).
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-gds_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return no-apply .
   run ref/gds-mati.w
    (  input parParentProc
      ,input 'ИЗМЕНЕНИЕ':U
      ,input Buf_matrix-goods.asmt-id
      ,input Buf_matrix-goods.db-num
      ,input-output loc-doc-rec
    ) no-error
   .
   if loc-doc-rec <> ? THEN DO:
       run openbr in this-procedure .
       reposition BROWSE-am-goods to recid loc-doc-rec no-error.
       if error-status:error then do:                           find first pos_assortment-matrix no-lock where                                   recid(pos_assortment-matrix) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи AM" skip                            string(if avail pos_assortment-matrix                                     then  substitute("Вн код AM: &1"                                                     , pos_assortment-matrix.asmt-id)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
   END.
   apply "entry" to BROWSE-am-goods in frame Dialog-Frame.
   apply "value-changed" to BROWSE-am-goods in frame Dialog-Frame.
END.
ON CHOOSE OF B-chg-izt IN FRAME Dialog-Frame
DO:
define variable v-log as logical   no-undo .
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available buf_matrix-goods then return no-apply.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-izt_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return no-apply .
assign
loc-doc-rec = recid(buf_matrix-goods).
if  buf_matrix.asmt-type = 'Шаблон':U then do:
    message "Корректировать ИЖТ можно  в  АССОРТИМЕНТНОЙ МАТРИЦЕ объекта"
    view-as alert-box information .
    return no-apply.
end.
if  buf_matrix.asmt-status = 1  then do:
    message "Корректировать ИЖТ можно  в  АССОРТИМЕНТНОЙ МАТРИЦЕ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.
run ver-db no-error .
if error-status :error then return no-apply .
loc#log = false .
if num-entries(p-rid-list) > 0 then do:
      message "Корректировать ИЖТ на выделенных записях ?"
      view-as alert-box question
      buttons yes-no update v-logq as logical .
      if v-logq = false then return no-apply .
    end.
    else do:
        if available Buf_matrix-goods  then do:
           loc#log = true .
           p-rid-list = string( recid(Buf_matrix-goods)) .
        end.
        else do:
          message "Не выделено ни одной записи"
          view-as alert-box information .
          return no-apply.
        end.
    end.
  run proc-b-izt in this-procedure ( p-rid-list ) no-error.
  if error-status:error then return no-apply.
  if loc#log = true then p-rid-list = "" .
  if loc-doc-rec <> ? then do:
    run openbr in this-procedure .
    reposition BROWSE-am-goods to recid loc-doc-rec no-error.
    if error-status:error then do:                           find first pos_assortment-matrix no-lock where                                   recid(pos_assortment-matrix) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи AM" skip                            string(if avail pos_assortment-matrix                                     then  substitute("Вн код AM: &1"                                                     , pos_assortment-matrix.asmt-id)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
  end.
  apply "entry" to BROWSE-am-goods in frame Dialog-Frame.
  apply "value-changed" to BROWSE-am-goods in frame Dialog-Frame .
END.
ON CHOOSE OF B-copy IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo.
  define variable loc-doc-rec as recid no-undo .
  DEFINE VARIABLE cError as CHARACTER NO-UNDO INITIAL "".
if  buf_matrix.asmt-status = 1  then do:
    message "Добавлять можно в АССОРТИМЕНТНУЮ МАТРИЦУ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.
run ver-db no-error .
if error-status :error then return no-apply .
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-gds_add-def':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return no-apply .
 RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
     0,
     OUTPUT cError
     ).
 if cError <> "" THEN DO:
    MESSAGE cError
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
    RETURN NO-APPLY.
 END.
    run proc-copy in this-procedure (output loc-doc-rec ) no-error  .
  if error-status :error then DO:
     message
    error-status :get-message(1)
    return-value .
     RETURN NO-APPLY.
  END.
  if loc-doc-rec <> ? THEN DO:
      run openbr in this-procedure .
  END.
  apply "entry" to BROWSE-am-goods in frame Dialog-Frame.
  apply "value-changed" to BROWSE-am-goods in frame Dialog-Frame.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
define variable is-many as logical   no-undo .
  if del-option = "":U then do:
     run gbl/pop-up.p ( input self :handle, input yes ) no-error.
     if error-status :error then do:
     return no-apply. end.
  end.
  if del-option = "":U then do:
      return no-apply.
  end.
if del-option = "list":U then do:
assign
  p-rid-list = ""
  del-option = ""
.
  run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code ) no-error .
  for each gds-list :
     find first buf_matrix-goods
     where buf_matrix-goods.gds-code = gds-list.gds-code
     and Buf_matrix-goods.db-num = p-db-num
     and Buf_matrix-goods.asmt-id = p-id
     no-error.
     if available buf_matrix-goods then do :
           if p-rid-list = "" then do :
              assign p-rid-list = string( recid(Buf_matrix-goods)) .
           end.
           else do :
              assign p-rid-list = p-rid-list + "," + string( recid(Buf_matrix-goods)) .
           end.
     end.
     else do :
        message
          substitute( "Выбранный товар &1 &2", gds-list.artic, gds-list.gds-name ) skip
          "не входит в данную Ассортиментную матрицу"
        view-as alert-box information.
     end.
  end.
  run ver-db no-error .
  if error-status :error then return no-apply .
  assign is-many = true .
end.
else do :
  assign
    is-many = false
    del-option = ""
  .
  if  buf_matrix.asmt-status = 1  then do:
      message "Корректировать и удалять можно  в  АССОРТИМЕНТНОЙ МАТРИЦЕ в статусе тек."
      view-as alert-box information .
      return no-apply.
  end.
  run ver-db no-error .
  if error-status :error then return no-apply .
  if num-entries(p-rid-list) > 0 then do:
    message "Удалять выделенные записи ?"
    view-as alert-box question
    Buttons yes-no update v-logq as log.
    if v-logq = false then return .
    assign is-many = true .
  end.
end.
run proc-b-del in this-procedure ( p-rid-list , is-many ) no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF B-grpAcc IN FRAME Dialog-Frame
DO:
run ver-db no-error .
if error-status :error then return no-apply .
if  buf_matrix.asmt-status = 1  then do:
    message "Корректировать можно  в  АССОРТИМЕНТНОЙ МАТРИЦЕ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.
  define variable ri-list as character no-undo .
  run ref/grp-ass.w (
     input parparentproc,
     input p-db-num,
     input p-id,
     input '',
     input v-cntxt-obj-type,
     input v-cntxt-obj-code,
     input-output ri-list) .
  run openbr in this-procedure .
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available Buf_matrix-goods then return no-apply.
assign
loc-doc-rec = recid(Buf_matrix-goods).
   run ref/gds-mati.w
    (  input parParentProc
      ,input 'ПРОСМОТР':U
      ,input Buf_matrix-goods.asmt-id
      ,input Buf_matrix-goods.db-num
      ,input-output loc-doc-rec
      ) no-error   .
   apply "entry" to BROWSE-am-goods in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo .
  if AVAILABLE Buf_matrix-goods  then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid28 as character no-undo .
define variable v-num-entry28 as integer   no-undo .
assign
  v-str-recid28 = trim( string( recid( Buf_matrix-goods ) , "->>>>>>>>>>>9":U ) )
  v-num-entry28 = lookup( v-str-recid28 , p-rid-list )
.
if v-num-entry28 > 0 then do:
  assign
    entry( v-num-entry28, p-rid-list ) = "":U
    p-rid-list = trim( replace( p-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    p-rid-list = p-rid-list + ( if p-rid-list = "":U then "":U else chr(44) ) + v-str-recid28
  .
end.
    loc#log = BROWSE-am-goods:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = BROWSE-am-goods:select-next-row ().
        apply "VALUE-CHANGED" to BROWSE-am-goods in frame Dialog-Frame.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to BROWSE-am-goods in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark-all IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo .
p-rid-list = "" .
IF p-sts = ? THEN DO:
    for each buf_Matrix-goods no-lock where Buf_matrix-goods.db-num = p-db-num  AND Buf_matrix-goods.asmt-id = p-id :
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid30 as character no-undo .
define variable v-num-entry30 as integer   no-undo .
assign
  v-str-recid30 = trim( string( recid( buf_Matrix-goods ) , "->>>>>>>>>>>9":U ) )
  v-num-entry30 = lookup( v-str-recid30 , p-rid-list )
.
if v-num-entry30 > 0 then do:
  assign
    entry( v-num-entry30, p-rid-list ) = "":U
    p-rid-list = trim( replace( p-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    p-rid-list = p-rid-list + ( if p-rid-list = "":U then "":U else chr(44) ) + v-str-recid30
  .
end.
    end.
END.
ELSE DO:
    for each buf_Matrix-goods no-lock where  buf_matrix-goods.db-num = p-db-num  and buf_matrix-goods.asmt-id = p-id and buf_matrix-goods.asmg-status = p-sts :
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid32 as character no-undo .
define variable v-num-entry32 as integer   no-undo .
assign
  v-str-recid32 = trim( string( recid( buf_Matrix-goods ) , "->>>>>>>>>>>9":U ) )
  v-num-entry32 = lookup( v-str-recid32 , p-rid-list )
.
if v-num-entry32 > 0 then do:
  assign
    entry( v-num-entry32, p-rid-list ) = "":U
    p-rid-list = trim( replace( p-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    p-rid-list = p-rid-list + ( if p-rid-list = "":U then "":U else chr(44) ) + v-str-recid32
  .
end.
    end.
end.
  run openbr in this-procedure .
  apply "entry" to BROWSE-am-goods in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark-del-all IN FRAME Dialog-Frame
DO:
   p-rid-list  = "".
  run openbr in this-procedure .
  apply "entry" to BROWSE-am-goods in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
  apply "WINDOW-CLOSE" to BROWSE-am-goods in frame Dialog-Frame.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
   IF  p-rid-list = "" THEN DO:
      IF AVAILABLE buf_matrix-goods THEN p-rid-list = string(RECID(buf_matrix-goods)).
  END.
END.
ON ROW-DISPLAY OF BROWSE-am-goods IN FRAME Dialog-Frame
DO:
define buffer sh_assortment-matrix-goods for ub.assortment-matrix-goods  .
    if available buf_matrix-goods then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_matrix.obj-type
  ,input  buf_matrix.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  buf_Matrix-goods.gds-code
  ,output v-assort-min
  ,output v-indicator-life-gds
  ,output v-gdop-min-stock
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
        case v-indicator-life-gds :
            when 'Новинка':U then do:
              p-indicator-life-gds:bgcolor  in browse BROWSE-am-goods   = 14 .
            end.
            when 'На вывод из ассортимента':U then do:
              p-indicator-life-gds:bgcolor  in browse BROWSE-am-goods   = 12 .
            end.
            when 'Нештатный':U then do:
              p-indicator-life-gds:bgcolor  in browse BROWSE-am-goods   = 8 .
            end.
        end case.
        if buf_goods.stts <> 0 then p-name:fgcolor  in browse BROWSE-am-goods   = 12 .
            Buf_goods.artic:fgcolor  in browse BROWSE-am-goods   = ? .
            p-shablon:fgcolor  in browse BROWSE-am-goods         = ?.
            if is-objLink = true  then do:
                if not f-shablon ( recid (buf_matrix-goods )) then do:
                   Buf_goods.artic:fgcolor  in browse BROWSE-am-goods   = 9 .
                   p-name:fgcolor     in browse BROWSE-am-goods   = 9 .
                   p-shablon:fgcolor  in browse BROWSE-am-goods   = 9 .
                end.
            end.
    end.
END.
ON VALUE-CHANGED OF BROWSE-am-goods IN FRAME Dialog-Frame
DO:
    if available buf_matrix-goods then do:
        ed_asmg-des = buf_matrix-goods.asmg-des .
        display ed_asmg-des with frame Dialog-Frame.
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  buf_matrix-goods.asmg-who-create
  ,output v-user-name-create
  )  .
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  buf_matrix-goods.asmg-who-update
  ,output v-user-name-corr
  )  .
    end.
    display v-user-name-corr v-user-name-create  with frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_del1
DO:
  assign
    del-option = "mark":U
  .
  APPLY "CHOOSE" TO b-del IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_del2
DO:
  assign
    del-option = "list":U
  .
  APPLY "CHOOSE" TO b-del IN FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF RS-sts IN FRAME Dialog-Frame
DO:
  run openbr in this-procedure no-error.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON CTRL-J OF sch-artic IN FRAME Dialog-Frame
DO:
  run proc-find-artic in this-procedure ( yes, input frame Dialog-Frame sch-artic) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-artic IN FRAME Dialog-Frame
DO:
  run proc-find-artic in this-procedure ( no , input frame Dialog-Frame sch-artic ) no-error.
  return no-apply.
END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure ( yes, input frame Dialog-Frame sch-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure ( no, input frame Dialog-Frame sch-code) no-error.
  return no-apply.
END.
ON CTRL-J OF sch-name IN FRAME Dialog-Frame
DO:
  run proc-find-name in this-procedure ( yes, input frame Dialog-Frame sch-name) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-name IN FRAME Dialog-Frame
DO:
  run proc-find-name in this-procedure ( no, input frame Dialog-Frame sch-name ) no-error.
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-am-goods :handle
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
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   assign v-doc-rec = ?. if available Buf_matrix-goods then v-doc-rec = recid(Buf_matrix-goods). run OpenBr. reposition BROWSE-am-goods to recid v-doc-rec no-error. apply 'entry' to BROWSE-am-goods.
    apply "VALUE-CHANGED" to BROWSE-am-goods.
end.
def var sort-labelBROWSE-am-goods   as character no-undo .
def var sort-clmnBROWSE-am-goods    as handle    no-undo .
def var cur-clmnBROWSE-am-goods     as handle    no-undo .
def var cur-clmn-locBROWSE-am-goods as integer   no-undo .
def var re-queryBROWSE-am-goods     as logical   initial no no-undo .
on start-search, ctrl-o of BROWSE-am-goods in frame Dialog-Frame do:
   run sort-brBROWSE-am-goods
     (input (if available buf_Matrix
             then recid(buf_Matrix)
             else ?
            )
     ).
end.
PROCEDURE sort-brBROWSE-am-goods :
  define input parameter p-recid as recid no-undo .
  if re-queryBROWSE-am-goods = no then do:
    assign
       cur-clmnBROWSE-am-goods = BROWSE-am-goods:current-column in frame Dialog-Frame
    .
    if sort-clmnBROWSE-am-goods <> ? then sort-clmnBROWSE-am-goods:column-fgcolor = 0.
    if cur-clmnBROWSE-am-goods = sort-clmnBROWSE-am-goods then do:
      assign
         sort-labelBROWSE-am-goods = ""
         sort-clmnBROWSE-am-goods = ?
      .
     end.
     else do:
       assign
         sort-labelBROWSE-am-goods = cur-clmnBROWSE-am-goods:label
         sort-clmnBROWSE-am-goods  = cur-clmnBROWSE-am-goods
         sort-clmnBROWSE-am-goods:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBROWSE-am-goods = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BROWSE-am-goods:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBROWSE-am-goods then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBROWSE-am-goods = cur-clmn-locBROWSE-am-goods + 1
    .
  end.
  case sort-labelBROWSE-am-goods:
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(buf_Matrix-goods), &1&2&1)', chr(34), p-rid-list)     .     run OpenBr.   . END.
        when 'Артикул! '  then DO:    assign       sort-column-name = "Buf_goods.artic"     .     run OpenBr.   . END.
        when 'Название! '  then DO:    assign       sort-column-name = "Buf_goods.gds-name"     .     run OpenBr.   . END.
        when 'Кто!изменил'  then DO:    assign       sort-column-name = "Buf_matrix-goods.asmg-who-update"     .     run OpenBr.   . END.
        when 'Дата!изменения'  then DO:    assign       sort-column-name = "Buf_matrix-goods.asmg-date-update"     .     run OpenBr.   . END.
        when 'Время!изм '  then DO:    assign       sort-column-name = "STRING(buf_Matrix-goods.asmg-time-update,'HH:MM')"     .     run OpenBr.   . END.
        when 'БД!изм'  then DO:    assign       sort-column-name = "Buf_matrix-goods.asmg-db-num-update"     .     run OpenBr.   . END.
        when 'Дата!создания'  then DO:    assign       sort-column-name = "Buf_matrix-goods.asmg-date-create"     .     run OpenBr.   . END.
        when 'Время! '  then DO:    assign       sort-column-name = "STRING(buf_Matrix-goods.asmg-time-create,'HH:MM')"     .     run OpenBr.   . END.
        when 'Кто!создал'  then DO:    assign       sort-column-name = "Buf_matrix-goods.asmg-who-create"     .     run OpenBr.   . END.
        when 'БД!соз'  then DO:    assign       sort-column-name = "Buf_matrix-goods.asmg-db-num-create"     .     run OpenBr.   . END.
        when 'Статус! '  then DO:    assign       sort-column-name = "entry (lookup (STRING(buf_Matrix-goods.asmg-status), '0,1,50,99':U), 'тек,удал,блок,удаление':U)"     .     run OpenBr.   . END.
        when 'ИЖТ! '  then DO:   assign       sort-column-name = substitute('dynamic-function(&1indicator-life-gds&1, recid(buf_Matrix-goods))', chr(34))     .     run OpenBr.   . END.
        when 'Acc!Min'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1assort-min&1,recid(buf_Matrix-goods))',chr(34))     .     run OpenBr.   . END.
        when 'Группа! '  then DO:    assign       sort-column-name = "Buf_goods.grp-name"     .     run OpenBr.   . END.
        when ' !Ш'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1f-shablon&1,recid(buf_Matrix-goods))',chr(34))     .     run OpenBr.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr.
      if sort-labelBROWSE-am-goods <> "" then do:
        assign
          cur-clmnBROWSE-am-goods:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBROWSE-am-goods = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition BROWSE-am-goods to recid p-recid no-error.
    apply "value-changed" to BROWSE-am-goods in frame Dialog-Frame.
  end.
  apply "entry" to BROWSE-am-goods in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBROWSE-am-goods:
if cur-clmnBROWSE-am-goods = ? then do:
   run OpenBr.
end.
else do:
   assign re-queryBROWSE-am-goods = yes.
   run sort-brBROWSE-am-goods
     (input (if available buf_Matrix
             then recid(buf_Matrix)
             else ?
            )
     ).
   assign re-queryBROWSE-am-goods = no.
end.
end.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  run init-gds-rec.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to BROWSE-am-goods in frame Dialog-Frame.
  return no-apply.
end.
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-gds_lookup':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return .
RUN Get-Gl-Set-Proc-Otkl IN THIS-PROCEDURE(
    buf_Matrix.obj-type,
    buf_Matrix.obj-code
    ).
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
  run ini-proc in this-procedure .
  run my_enable in this-procedure .
   hide mark-num in frame Dialog-Frame .
  if v-doc-rec <> ? then
  reposition BROWSE-am-goods to recid v-doc-rec no-error.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numBROWSE-am-goods as INT EXTENT 16 no-undo.
DEF VAR varmviBROWSE-am-goods       as INT no-undo.
DEF VAR varmvjBROWSE-am-goods       as INT no-undo.
DEF VAR varmvkBROWSE-am-goods       as INT no-undo.
DEF VAR varmvlBROWSE-am-goods       as INT no-undo.
DEF VAR move-elementBROWSE-am-goods as INT no-undo.
def var jjBROWSE-am-goods           as int no-undo.
do varmviBROWSE-am-goods = 1 to EXTENT(cur-clmn-numBROWSE-am-goods):
  ASSIGN cur-clmn-numBROWSE-am-goods[varmviBROWSE-am-goods] = varmviBROWSE-am-goods.
END.
RUN start-mv-clmnBROWSE-am-goods.
PROCEDURE start-mv-clmnBROWSE-am-goods:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE BROWSE-am-goods do:
  RUN re-move-clmnBROWSE-am-goods ( 1, 16).
END.
ON ctrl-cursor-left OF BROWSE BROWSE-am-goods do:
  RUN re-move-clmnBROWSE-am-goods (16, 1).
END.
PROCEDURE re-move-clmnBROWSE-am-goods:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmviBROWSE-am-goods = 1 TO EXTENT(cur-clmn-numBROWSE-am-goods):
    if cur-clmn-numBROWSE-am-goods[varmviBROWSE-am-goods] = source-column THEN cur-clmn-numBROWSE-am-goods[varmviBROWSE-am-goods] = -1.
  END.
  if BROWSE-am-goods:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjBROWSE-am-goods = source-column - 1 to target-column BY -1:
    DO varmviBROWSE-am-goods = 1 TO EXTENT(cur-clmn-numBROWSE-am-goods):
        if cur-clmn-numBROWSE-am-goods[varmviBROWSE-am-goods] = varmvjBROWSE-am-goods THEN DO:
          cur-clmn-numBROWSE-am-goods[varmviBROWSE-am-goods] = cur-clmn-numBROWSE-am-goods[varmviBROWSE-am-goods] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjBROWSE-am-goods = source-column + 1 to target-column:
    DO varmviBROWSE-am-goods = 1 TO EXTENT(cur-clmn-numBROWSE-am-goods):
      if cur-clmn-numBROWSE-am-goods[varmviBROWSE-am-goods] = varmvjBROWSE-am-goods THEN DO:
        cur-clmn-numBROWSE-am-goods[varmviBROWSE-am-goods] = cur-clmn-numBROWSE-am-goods[varmviBROWSE-am-goods] - 1.
      END.
    END.
  END.
  DO varmviBROWSE-am-goods = 1 TO EXTENT(cur-clmn-numBROWSE-am-goods):
    if cur-clmn-numBROWSE-am-goods[varmviBROWSE-am-goods] = -1 THEN cur-clmn-numBROWSE-am-goods[varmviBROWSE-am-goods] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnBROWSE-am-goods:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmviBROWSE-am-goods = 1 TO EXTENT(cur-clmn-numBROWSE-am-goods):
    if cur-clmn-numBROWSE-am-goods[varmviBROWSE-am-goods] = cur-clmn-loc THEN move-elementBROWSE-am-goods = varmviBROWSE-am-goods.
  END.
  RUN re-move-clmnBROWSE-am-goods (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultBROWSE-am-goods:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlBROWSE-am-goods = 1 to EXTENT(cur-clmn-numBROWSE-am-goods):
    RUN re-move-clmnBROWSE-am-goods (cur-clmn-numBROWSE-am-goods[varmvlBROWSE-am-goods], varmvlBROWSE-am-goods).
  END.
  RUN start-mv-clmnBROWSE-am-goods.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  apply "VALUE-CHANGED" to BROWSE-am-goods in frame Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame focus BROWSE-am-goods.
END.
run disable_ui in this-procedure .
PROCEDURE assort-polit :
do
on error undo, return error return-value
:
end.
END PROCEDURE.
PROCEDURE calc-itogi :
DEFINE BUFFER Buf_matrix-goods1 FOR ub.assortment-matrix-goods.
DEFINE VARIABLE  v-value as CHARACTER  NO-UNDO INITIAL "".
DEFINE VARIABLE  lIsObj       as LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE  v-iAsmt-id   as INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE  v-iDb-num    as INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE  v-type       as CHARACTER  NO-UNDO INITIAL "".
DEFINE VARIABLE  cError       as CHARACTER  NO-UNDO INITIAL "".
ASSIGN
   v-kol-all       = 0
   v-kol-del       = 0
   v-kol-in-shabl  = 0
   v-raznost       = 0
   v-proc-otkl     = 0
   .
RUN Get-Gl-Param-Proc-Otkl in THIS-PROCEDURE(
    p-Id,
    p-Db-num,
    OUTPUT cError
    ).
if cError <> "" THEN DO:
   MESSAGE
      PROGRAM-NAME(1) ":"  SKIP
      "Ошибок быть не должно !" SKIP
      cError SKIP
      VIEW-AS ALERT-BOX INFO BUTTONS OK.
END.
ASSIGN
   v-kol-all       = v-gl-iAM-Gds-All
   v-kol-del       = v-gl-iAM-Gds-Vyv
   v-kol-in-shabl  = v-gl-iAM-Sbl-Gds-All
   v-raznost       = (IF v-gl-lAM-Is-Obj AND v-gl-lAM-Ref-Shablon
                         THEN (v-gl-iAM-Gds-All  - v-gl-iAM-Sbl-Gds-All)
                         ELSE 0)
   v-proc-otkl     = v-gl-dAM-Proc-Otkl
   .
DISPLAY
   v-kol-all
   v-kol-del
   v-kol-in-shabl
   v-raznost
   v-proc-otkl
   WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE create-tt-gds :
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-status as integer   no-undo .
find first temp-goods where
  temp-goods.gds-code = p-gds-code no-error .
  if not available temp-goods then create temp-goods.
    assign
      temp-goods.gds-code = p-gds-code
      temp-goods.status_ = p-status
      .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE econom-mode :
define output parameter p-is as logical   no-undo .
p-is = true .
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RS-sts a-n-c sch-artic ED_asmg-des mark-num FILL-IN-1 FILL-IN-7
          v-user-name-create v-user-name-corr v-kol-all v-kol-in-shabl v-raznost
          v-proc-otkl v-kol-del
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-mark-all B-mark-del-all B-sel B-add B-lookup B-chg
         B-del B-copy B-print B-Help B-chg-izt B-grpAcc RS-sts a-n-c sch-artic
         BROWSE-am-goods ED_asmg-des mark-num FILL-IN-1 FILL-IN-7
         v-user-name-create v-user-name-corr v-kol-all v-kol-in-shabl v-raznost
         v-proc-otkl v-kol-del
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-am-goods FOR EACH Buf_matrix-goods       WHERE Buf_matrix-goods.db-num =  p-db-num         AND Buf_matrix-goods.asmt-id = p-id NO-LOCK,          first Buf_goods NO-LOCK where Buf_matrix-goods.gds-code =  Buf_goods.gds-code .
END PROCEDURE.
PROCEDURE ini-proc :
define buffer obj_assortment-matrix for ub.assortment-matrix  .
define buffer sh_assortment-matrix for ub.assortment-matrix  .
  for each temp-goods :
      delete temp-goods.
  end.
  is-shablonLink = false .
  is-objLink = false .
  if buf_matrix.asmt-type <> 'Объект':U  then do:
   for each obj_assortment-matrix no-lock where
            obj_assortment-matrix.asmt-status = 0 and
            obj_assortment-matrix.asmt-type = 'Объект':U ,
      first ub.assortment-matrix-attr no-lock where
            ub.assortment-matrix-attr.asmt-id    = obj_assortment-matrix.asmt-id and
            ub.assortment-matrix-attr.db-num     = obj_assortment-matrix.db-num and
            ub.assortment-matrix-attr.attr-code  = 'RootShablon':U and
            ub.assortment-matrix-attr.attr-value = substitute("&1&3&2" , buf_matrix.asmt-id,buf_matrix.db-num,chr(4))
            :
            is-shablonLink = true  .
            leave.
   end.
  end.
  else do:
    find first ub.assortment-matrix-attr no-lock where
          ub.assortment-matrix-attr.asmt-id    = buf_matrix.asmt-id and
          ub.assortment-matrix-attr.db-num     = buf_matrix.db-num and
          ub.assortment-matrix-attr.attr-code  = 'RootShablon':U
     no-error .
     if available ub.assortment-matrix-attr then do:
        find first sh_assortment-matrix no-lock where
                    sh_assortment-matrix.asmt-status = 0 and
                    sh_assortment-matrix.asmt-type   = 'Шаблон':U and
                    sh_assortment-matrix.asmt-id     = int(entry(1,ub.assortment-matrix-attr.attr-value,chr(4))) and
                    sh_assortment-matrix.db-num = int(entry(2,ub.assortment-matrix-attr.attr-value,chr(4))) no-error .
        if available sh_assortment-matrix then do:
           assign
            is-objLink = true
            is-objLink-id = sh_assortment-matrix.asmt-id
            is-objLink-db = sh_assortment-matrix.db-num
          .
        end.
     end.
  end.
END PROCEDURE.
PROCEDURE init-gds-rec :
if available buf_goods then do:
   gds-rec = recid (buf_goods) .
end.
END PROCEDURE.
PROCEDURE my_enable :
define variable v-db-num like ub.db.db-num no-undo .
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
Buf_matrix-goods.asmg-db-num-update:read-only in browse BROWSE-am-goods = true .
p-indicator-life-gds:resizable in browse BROWSE-am-goods = true .
p-name:resizable  in browse BROWSE-am-goods = true .
p-indicator-life-gds:width in browse BROWSE-am-goods = 8.
ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME Dialog-Frame
              = "Текущие&+" + chr(44) +  '0':U + chr(44) +
              "Все&!" + chr(44) + 'все':U + chr(44) +
              "Удаленные&-" + chr(44) + '1':U
rs-sts = (IF p-sts = ? THEN '0':U ELSE string(p-sts))
.
rs-sts = '0':U .
DISPLAY mark-num
FILL-IN-1
RS-sts
fill-in-7
WITH FRAME Dialog-Frame.
if is-shablonLink then enable B-link-obj with frame Dialog-Frame .
else do:
  disable B-link-obj with frame Dialog-Frame .
  hide B-link-obj in frame Dialog-Frame .
end.
if is-objLink then do:
 p-shablon:visible  in browse BROWSE-am-goods = true   .
end.
else do:
 p-shablon:visible  in browse BROWSE-am-goods = false  .
end.
ENABLE
b-quit
B-mark when transaction = false
B-mark-all when transaction = false
B-mark-del-all when transaction = false
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-add when LOOKUP("b-add":U, bttns) > 0  and transaction = false
B-lookup
B-chg when LOOKUP("b-add":U, bttns) > 0  and transaction = false
B-del when LOOKUP("b-add":U, bttns) > 0   and transaction = false
B-print
B-grpAcc
B-Help
B-copy when LOOKUP("b-add":U, bttns) > 0   and transaction = false
BROWSE-am-goods
mark-num
RS-sts
ed_asmg-des
a-n-c
sch-artic
B-chg-izt when LOOKUP("b-add":U, bttns) > 0  and transaction = false
with FRAME Dialog-Frame.
if buf_matrix.asmt-type <> 'Объект':U  then do:
   hide B-grpAcc in frame Dialog-Frame .
end.
ed_asmg-des:READ-ONLY = TRUE.
run openbr in this-procedure no-error.
IF ERROR-STATUS:ERROR  THEN RETURN error.
END PROCEDURE.
PROCEDURE openBr :
define variable p-open-query     as logical   no-undo init true .
def var l-query-was-opened as logical no-undo .
define variable doc-rec  as recid     no-undo .
define variable  p-find-next      as logical   no-undo .
define variable  p-find-condition as character no-undo .
ASSIGN  FRAME Dialog-Frame
  rs-sts
    .
ASSIGN
  p-sts = (IF rs-sts = 'все':U THEN ? ELSE INTEGER(rs-sts))
  .
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
define variable title0 as character no-undo init "Ассортиментная матрица" .
 title0 = "Ассортиментная матрица " + buf_matrix.asmt-name.
IF p-sts = ? THEN DO:
    frame Dialog-Frame:TITLE = title0  .
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
                              "FOR EACH Buf_matrix-goods"
      parameter-4-46 =
        (
          if (" Buf_matrix-goods.db-num = p-db-num  AND Buf_matrix-goods.asmt-id = p-id " + " " + where-phrase-46) <> ""
          then  substitute(' Buf_matrix-goods.db-num = &1 AND Buf_matrix-goods.asmt-id = &2 ' , p-db-num , p-id  )  + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + ", first Buf_goods NO-LOCK where Buf_matrix-goods.gds-code = Buf_goods.gds-code")
      parameter-6-46 = if sort-phrase-46 = ''
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
        " " + sort-phrase-46
        )
      parameter-7-46 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-46 =
          (" Buf_matrix-goods.db-num = p-db-num  AND Buf_matrix-goods.asmt-id = p-id " + " " + where-phrase-46 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-am-goods:handle
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
    OPEN QUERY BROWSE-am-goods FOR EACH Buf_matrix-goods no-lock
      where  Buf_matrix-goods.db-num = p-db-num  AND Buf_matrix-goods.asmt-id = p-id
    , first Buf_goods NO-LOCK where Buf_matrix-goods.gds-code = Buf_goods.gds-code
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_matrix-goods )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-am-goods:handle:get-buffer-handle(1) = (buffer Buf_matrix-goods:handle) then do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-4-46 =
        "where ":u +  substitute(' Buf_matrix-goods.db-num = &1 AND Buf_matrix-goods.asmt-id = &2 ' , p-db-num , p-id  )  + " ":u + where-phrase-46 + " ":u + p-find-condition + " " + ""
      parameter-5-46 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-am-goods:handle
                          ,input rowid(buf_matrix-goods)
                          ,input logical(parameter-2-46)
                          ,input no-lock
                          ,input (buffer buf_matrix-goods:handle)
                          ,input parameter-4-46
                          ,input parameter-5-46
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-46 = (if p-find-next then "true":u else "false":u )
      parameter-3-46 =  "FOR EACH Buf_matrix-goods"
      parameter-4-46 =
        (
          if (" Buf_matrix-goods.db-num = p-db-num  AND Buf_matrix-goods.asmt-id = p-id " + " " + where-phrase-46) <> ""
          then  substitute(' Buf_matrix-goods.db-num = &1 AND Buf_matrix-goods.asmt-id = &2 ' , p-db-num , p-id  )  + " " + where-phrase-46
          else "true"
        )
      parameter-5-46 = (" " + "" + " " + ", first Buf_goods NO-LOCK where Buf_matrix-goods.gds-code = Buf_goods.gds-code" + " " + p-find-condition)
      parameter-6-46 = if sort-phrase-46 = ''
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
        " " + sort-phrase-46
        )
      parameter-7-46 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-am-goods:handle
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
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
END.
ELSE DO:
    frame Dialog-Frame:TITLE = title0 + chr(32) + entry (lookup (STRING(p-sts), '0,1,50,99':U), 'тек,удал,блок,удаление':U).
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
                              "FOR EACH Buf_matrix-goods"
      parameter-4-48 =
        (
          if (" buf_matrix-goods.db-num = p-db-num  and buf_matrix-goods.asmt-id = p-id and buf_matrix-goods.asmg-status = p-sts " + " " + where-phrase-48) <> ""
          then  substitute(' Buf_matrix-goods.db-num = &1 AND Buf_matrix-goods.asmt-id = &2 and buf_Matrix-goods.asmg-status = &3' , p-db-num , p-id , p-sts )  + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + ", first Buf_goods NO-LOCK where Buf_matrix-goods.gds-code = Buf_goods.gds-code")
      parameter-6-48 = if sort-phrase-48 = ''
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
          (" buf_matrix-goods.db-num = p-db-num  and buf_matrix-goods.asmt-id = p-id and buf_matrix-goods.asmg-status = p-sts " + " " + where-phrase-48 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-am-goods:handle
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
    OPEN QUERY BROWSE-am-goods FOR EACH Buf_matrix-goods no-lock
      where  buf_matrix-goods.db-num = p-db-num  and buf_matrix-goods.asmt-id = p-id and buf_matrix-goods.asmg-status = p-sts
    , first Buf_goods NO-LOCK where Buf_matrix-goods.gds-code = Buf_goods.gds-code
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_matrix-goods )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-am-goods:handle:get-buffer-handle(1) = (buffer Buf_matrix-goods:handle) then do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-4-48 =
        "where ":u +  substitute(' Buf_matrix-goods.db-num = &1 AND Buf_matrix-goods.asmt-id = &2 and buf_Matrix-goods.asmg-status = &3' , p-db-num , p-id , p-sts )  + " ":u + where-phrase-48 + " ":u + p-find-condition + " " + ""
      parameter-5-48 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-am-goods:handle
                          ,input rowid(buf_matrix-goods)
                          ,input logical(parameter-2-48)
                          ,input no-lock
                          ,input (buffer buf_matrix-goods:handle)
                          ,input parameter-4-48
                          ,input parameter-5-48
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-48 = (if p-find-next then "true":u else "false":u )
      parameter-3-48 =  "FOR EACH Buf_matrix-goods"
      parameter-4-48 =
        (
          if (" buf_matrix-goods.db-num = p-db-num  and buf_matrix-goods.asmt-id = p-id and buf_matrix-goods.asmg-status = p-sts " + " " + where-phrase-48) <> ""
          then  substitute(' Buf_matrix-goods.db-num = &1 AND Buf_matrix-goods.asmt-id = &2 and buf_Matrix-goods.asmg-status = &3' , p-db-num , p-id , p-sts )  + " " + where-phrase-48
          else "true"
        )
      parameter-5-48 = (" " + "" + " " + ", first Buf_goods NO-LOCK where Buf_matrix-goods.gds-code = Buf_goods.gds-code" + " " + p-find-condition)
      parameter-6-48 = if sort-phrase-48 = ''
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
        " " + sort-phrase-48
        )
      parameter-7-48 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-am-goods:handle
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
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
END.
APPLY "VALUE-CHANGED" TO BROWSE-am-goods in frame Dialog-Frame.
APPLY "ENTRY" TO BROWSE-am-goods.
RUN calc-itogi .
END PROCEDURE.
PROCEDURE proc-add :
define output parameter p-doc-rec as recid no-undo .
define variable v-host-code as integer   no-undo .
DEFINE VARIABLE dTmp-1 as DECIMAL NO-UNDO INITIAL 0.
DEFINE VARIABLE dTmp-2 as DECIMAL NO-UNDO INITIAL 0.
DEFINE VARIABLE dTmp-3 as DECIMAL NO-UNDO INITIAL 0.
DEFINE VARIABLE iCountGds as INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE cTmp      as CHARACTER  NO-UNDO INITIAL "".
DEFINE VARIABLE iDelta    as INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE cError    as CHARACTER  NO-UNDO INITIAL "".
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
for each tt-gds-list :
   delete tt-gds-list.
end.
run str/chsgdsls.w
(   parParentProc ,
    input "gds-matr" ,
    input "Ассортиментная матрица " + buf_matrix.asmt-name  , ? , ? ,
    input v-host-code,
    input-output varschartic,
    output ref-list,
    output table tt-gds-list,
    false )
     no-error .
     if error-status :error then do:
     message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error
        .
     end.
 v-longchar = "" .
 v-err-ext = false .
DEFINE VARIABLE vss-include-info50 AS CHARACTER FORMAT "x(65)" NO-UNDO INITIAL "@(#)$Workfile$ $Revision$".
FOR EACH tt-gds-list NO-LOCK:
    IF NOT CAN-FIND(FIRST ub.Assortment-matrix-goods WHERE
                          ub.Assortment-matrix-goods.Asmt-id      = buf_matrix.Asmt-id
                      AND ub.Assortment-matrix-goods.Db-num       = buf_matrix.db-num
                      AND ub.Assortment-matrix-goods.gds-code     = tt-gds-list.gds-code
                      AND ub.Assortment-matrix-goods.asmg-status  = INTEGER('0':U)
                      NO-LOCK) THEN DO:
       ASSIGN
          iDelta = iDelta + 1.
    END.
END.
 RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
     iDelta,
     OUTPUT cError
     ).
 if cError <> "" THEN DO:
    RETURN ERROR cError.
 END.
 run waitfram-show in this-procedure ( "Добавление товаров в ассортиментную матрицу ... " ) .
  for each tt-gds-list:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat1 in g#lib-Matrix
 (input this-procedure
 ,input-output p-doc-rec
 ,input 'ДОБАВЛЕНИЕ':U
 ,input buf_matrix.asmt-id
 ,input buf_matrix.db-num
 ,input tt-gds-list.gds-code
 ,input ''
  ) no-error .
       if error-status :error then do:
          v-longchar = v-longchar + return-value  + chr(10).
          v-err-ext  = true  .
          next.
       end.
       run create-tt-gds in this-procedure  (tt-gds-list.gds-code, 0 ) .
 end.
run waitfram-hide in this-procedure .
if v-err-ext = true  then do:
define variable v-ok as logical   no-undo .
  run gbl/d-longchar.w (
      ? ,
        'Editor_row=2\':u
      + 'title=При добавлении в Ассортиментные матрицы\':u
      + 'Editor_col=1\':u
      + 'Editor_width=96\':u
      + 'Editor_height=21\':u
      + 'readonly=yes\':u
    ,input-output v-longchar
    ,output v-ok ) no-error .
end.
END PROCEDURE.
PROCEDURE proc-b-del :
define input  parameter p-recid as character no-undo .
define input  parameter p-model as logical   no-undo .
define variable loc#log as logical no-undo.
define variable v-log as logical   no-undo .
define variable v-sts like ub.assortment-matrix-goods.asmg-status no-undo .
define variable loc-doc-rec as recid no-undo.
define variable i as integer   no-undo .
do
on error undo, return error
on stop undo, return error
:
v-err-ext  = false   .
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-gds_deletion':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return no-apply .
  assign
  v-sts = ?
  loc-doc-rec = RECID(buf_Matrix-goods)
  .
  if p-model = false then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat2 in g#lib-Matrix
 (input this-procedure
 ,input recid(buf_Matrix-goods)
 ,input-output v-sts
 ,input true
  ) no-error .
    if error-status:error then do:
       message return-value
       view-as alert-box information .
       undo, return error.
    end.
    run create-tt-gds in this-procedure  (buf_Matrix-goods.gds-code, 1 ) .
    if return-value <> "" then message  substitute("&1 &2" ,buf_Matrix-goods.gds-code, return-value  ) view-as alert-box information .
  end.
  else do:
      v-longchar = "".
      v-err-ext  = false   .
      repeat i = 1 to num-entries(p-recid) :
      find first buf_Matrix-goods no-lock where
           recid(buf_Matrix-goods) = integer(entry(i,p-recid )) no-error .
        if buf_Matrix-goods.asmg-status = 0 then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat2 in g#lib-Matrix
 (input this-procedure
 ,input entry(i,p-recid)
 ,input-output v-sts
 ,input false
  ) no-error .
               if error-status :error then do:
                  v-longchar = v-longchar + return-value  + chr(10).
                  v-err-ext  = true  .
               end.
               if not error-status :error then do:
                  run create-tt-gds in this-procedure  (buf_Matrix-goods.gds-code, 1 ) .
                  if return-value <> "" then do:
                      v-longchar = v-longchar + substitute("&1 &2&3" ,buf_Matrix-goods.gds-code, return-value ,chr(10)) .
                      v-err-ext  = true  .
                  end.
               end.
        end.
      end.
    assign
      p-recid = ""
      p-rid-list = ""
    .
    if v-err-ext = true  then do:
    define variable v-ok as logical   no-undo .
      run gbl/d-longchar.w (
            ?,
            'Editor_row=2\':u
          + 'title=При корректировке в Ассортиментные матрицы\':u
          + 'Editor_col=1\':u
          + 'Editor_width=96\':u
          + 'Editor_height=21\':u
          + 'readonly=yes\':u
        ,input-output v-longchar
        ,output v-ok ) no-error .
    end.
  end.
  run openbr in this-procedure .
  REPOSITION BROWSE-am-goods to recid loc-doc-rec No-error.
  if error-status:error then do:                           find first pos_assortment-matrix no-lock where                                   recid(pos_assortment-matrix) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи AM" skip                            string(if avail pos_assortment-matrix                                     then  substitute("Вн код AM: &1"                                                     , pos_assortment-matrix.asmt-id)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
  if available buf_Matrix-goods then do:
    loc#log = BROWSE-am-goods:select-focused-row( ) IN FRAME Dialog-Frame.
    loc#log = BROWSE-am-goods:refresh() .
  end.
  RUN calc-itogi IN THIS-PROCEDURE.
  apply "ENTRY" to BROWSE-am-goods.
end.
END PROCEDURE.
PROCEDURE proc-b-izt :
define input  parameter p-recid as character no-undo .
  do
  on error undo, return error return-value
  :
  define variable i as integer   no-undo .
  define variable v-old as character no-undo .
  define variable v-new as character no-undo .
     empty temp-table gds-list.
     empty temp-table obj-list.
      repeat i = 1 to num-entries(p-recid) :
        find first buf_Matrix-goods no-lock where
              recid(buf_Matrix-goods) = integer(entry(i,p-recid)) no-error .
        find first buf_goods no-lock where
                   buf_goods.gds-code = buf_Matrix-goods.gds-code.
              create gds-list.
              buffer-copy buf_goods to gds-list.
      end.
  run create_obj-list ( buf_matrix.obj-type , buf_matrix.obj-code ) .
  run ref/graf-igt.w ( output v-old, output v-new ) .
      if not ( v-old = "" and v-new = "" )  then do:
          run ref/chg-igt.p
            ( input v-old, input v-new , input true ) no-error  .
              if error-status :error then
              message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                ""
                view-as alert-box error
              .
      end.
  end.
END PROCEDURE.
PROCEDURE proc-b-print :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      character    no-undo.
define variable Line            as      character    no-undo.
define variable v-time-cr as character no-undo .
define variable v-time-up as character no-undo .
define variable v-st      as character no-undo .
DEFINE FRAME buf_Matrix-list
      Buf_goods.artic FORMAT "X(16)":U
      Buf_goods.gds-name FORMAT "X(30)":U
      Buf_matrix-goods.asmg-who-update COLUMN-LABEL "Кто!изменил" FORMAT "X(8)":U
      Buf_matrix-goods.asmg-date-update COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      p-time-upd COLUMN-LABEL "Время" FORMAT "x(5)":U
      Buf_matrix-goods.asmg-db-num-update COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      Buf_matrix-goods.asmg-date-create COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      p-time-cr COLUMN-LABEL "Время" FORMAT "x(5)":U
      Buf_matrix-goods.asmg-who-create COLUMN-LABEL "Кто!создал" FORMAT "X(8)":U
      Buf_matrix-goods.asmg-db-num-create COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
      p-status COLUMN-LABEL "Статус" FORMAT "x(6)":U
      v-indicator-life-gds COLUMN-LABEL "ИЖТ" FORMAT "x(20)":U
      v-assort-min         column-label "AMin" format "*/ "
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
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
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME buf_Matrix-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(buf_Matrix-goods).
DO WHILE available buf_Matrix-goods :
  GET prev BROWSE-am-goods.
END.
GET next BROWSE-am-goods.
DO WHILE available buf_Matrix-goods :
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_matrix.obj-type
  ,input  buf_matrix.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  buf_Matrix-goods.gds-code
  ,output v-assort-min
  ,output v-indicator-life-gds
  ,output v-gdop-min-stock
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
  Display STREAM PrnLibStream
    STRING (buf_Matrix-goods.asmg-time-create,'HH:MM') @ p-time-cr
    STRING (buf_Matrix-goods.asmg-time-update,'HH:MM') @ p-time-upd
           entry (lookup (STRING(p-sts), '0,1,50,99':U), 'тек,удал,блок,удаление':U) @ p-status
            Buf_goods.artic
            Buf_goods.gds-name
            Buf_matrix-goods.asmg-who-update
            Buf_matrix-goods.asmg-date-update
            Buf_matrix-goods.asmg-db-num-update
            Buf_matrix-goods.asmg-date-create
            Buf_matrix-goods.asmg-who-create
            Buf_matrix-goods.asmg-db-num-create
            v-indicator-life-gds
            v-assort-min
 with FRAME buf_Matrix-list .
  DOWN STREAM PrnLibStream 1
  with FRAME buf_Matrix-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next BROWSE-am-goods.
END.
UNDERLINE  STREAM PrnLibStream
    p-time-cr
    p-time-upd
    p-status
    Buf_goods.artic
    Buf_goods.gds-name
    Buf_matrix-goods.asmg-who-update
    Buf_matrix-goods.asmg-date-update
    Buf_matrix-goods.asmg-db-num-update
    Buf_matrix-goods.asmg-date-create
    Buf_matrix-goods.asmg-who-create
    Buf_matrix-goods.asmg-db-num-create
    v-indicator-life-gds
    v-assort-min
with FRAME buf_Matrix-list .
DISPLAY STREAM PrnLibStream
"ИТОГО"     @ Buf_goods.artic
accum-count @ Buf_goods.gds-name
with frame buf_Matrix-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME buf_Matrix-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION BROWSE-am-goods to recid v-doc-rec no-error.
APPLY "entry" to BROWSE-am-goods.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
PROCEDURE proc-br :
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE proc-copy :
define output parameter p-doc-rec as recid no-undo .
define variable  v-rid-list as character no-undo .
define buffer bb_assortment-matrix for assortment-matrix.
define buffer bb_assortment-matrix-goods for ub.assortment-matrix-goods.
define variable v-calc0    as integer   no-undo init 1 .
define variable v-calc     as integer   no-undo init 0 .
define variable v-calc-err as integer   no-undo init 0 .
DEFINE VARIABLE iDelta     as INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE cError     as CHARACTER NO-UNDO INITIAL "".
 v-longchar = "" .
 v-err-ext = false .
run ref/assmatr.w ( input parParentProc , input 'b-sel', p-curr-obj-type , p-curr-obj-code , ? ,  ?, input-output  v-rid-list ).
if v-rid-list <> "" then do:
   find first bb_assortment-matrix no-lock where recid(bb_assortment-matrix) = int(v-rid-list) no-error .
   if available bb_assortment-matrix then do:
      RUN Get-Delta-Gds-2-Matrix in THIS-PROCEDURE(
          BUFFER bb_assortment-matrix,
          BUFFER buf_matrix,
          OUTPUT iDelta
          ).
      RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
          iDelta,
          OUTPUT cError
          ).
      IF cError <> "" THEN DO:
         RETURN ERROR cError.
      END.
      for each  bb_assortment-matrix-goods no-lock where
                bb_assortment-matrix-goods.asmg-status  = 0 and
                bb_assortment-matrix-goods.db-num = bb_assortment-matrix.db-num and
                bb_assortment-matrix-goods.asmt-id = bb_assortment-matrix.asmt-id :
                run waitfram-show in this-procedure  ("Копирование из ассортиментной матрицы " + bb_assortment-matrix.asmt-name + " " + string(v-calc0) ) .
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat1 in g#lib-Matrix
 (input this-procedure
 ,input-output p-doc-rec
 ,input 'ДОБАВЛЕНИЕ':U
 ,input buf_matrix.asmt-id
 ,input buf_matrix.db-num
 ,input bb_assortment-matrix-goods.gds-code
 ,input bb_assortment-matrix-goods.asmg-des
  ) no-error .
                if not error-status :error  then do:
                   v-calc = v-calc + 1 .
                   run create-tt-gds in this-procedure  (bb_assortment-matrix-goods.gds-code, 0 ) .
                end.
                else do:
                  v-longchar = v-longchar + return-value  + chr(10).
                  v-err-ext  = true  .
                  v-calc-err = v-calc-err + 1 .
                end.
                v-calc0 = v-calc0 + 1 .
      end.
      run waitfram-hide in this-procedure .
      message
      "Скопировано" v-calc "товаров" skip
      "Ошибок"      v-calc-err       skip
      view-as alert-box information .
      if v-err-ext = true  then do:
      define variable v-ok as logical   no-undo .
        run gbl/d-longchar.w (
            ? ,
              'Editor_row=2\':u
            + 'title=При добавлении в Ассортиментные матрицы\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
          ,input-output v-longchar
          ,output v-ok ) no-error .
      end.
   end.
end.
END PROCEDURE.
PROCEDURE proc-find-artic :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as character no-undo.
define buffer buff_matrix-goods for ub.assortment-matrix-goods.
define variable doc-rec as recid no-undo.
  doc-rec = ? .
  find first  Buff_matrix-goods no-lock where
              Buff_matrix-goods.db-num   = p-db-num
          AND Buff_matrix-goods.asmt-id  = p-id
          and can-find(first  buf_goods no-lock where
                              buf_goods.gds-code =  Buff_matrix-goods.gds-code and
                              buf_goods.artic begins pardoc-code
                              )
          no-error  .
  if available Buff_matrix-goods then
  doc-rec = recid (Buff_matrix-goods) .
  reposition BROWSE-am-goods to recid doc-rec no-error .
  if not error-status :error then do:
     apply "VALUE-CHANGED" to  BROWSE-am-goods  in frame Dialog-Frame.
  end.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.
END PROCEDURE.
PROCEDURE proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as INTEGER no-undo.
define buffer buff_matrix-goods for ub.assortment-matrix-goods.
define variable doc-rec as recid no-undo.
  doc-rec = ? .
  find first  Buff_matrix-goods no-lock where
              Buff_matrix-goods.gds-code = pardoc-code
          AND Buff_matrix-goods.db-num   = p-db-num
          AND Buff_matrix-goods.asmt-id  = p-id
          no-error  .
  if available Buff_matrix-goods then
  doc-rec = recid (Buff_matrix-goods) .
  reposition BROWSE-am-goods to recid doc-rec no-error .
  if not error-status :error then do:
     apply "VALUE-CHANGED" to  BROWSE-am-goods  in frame Dialog-Frame.
  end.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.
END PROCEDURE.
PROCEDURE proc-find-name :
define input parameter par-next as logical no-undo.
define input parameter par-name as character no-undo .
define buffer buff_matrix-goods for ub.assortment-matrix-goods.
define buffer buff_goods for ub.goods.
define variable doc-rec as recid no-undo.
  doc-rec = ? .
      for each  buff_matrix-goods no-lock where
                buff_matrix-goods.db-num   = p-db-num and
                buff_matrix-goods.asmt-id  = p-id ,
          first buff_goods no-lock where
                buff_goods.gds-code = buff_matrix-goods.gds-code and
                buff_goods.gds-name begins par-name
                :
                doc-rec = recid (Buff_matrix-goods) .
                leave.
      end.
  reposition BROWSE-am-goods to recid doc-rec no-error .
  if not error-status :error then do:
     apply "VALUE-CHANGED" to  BROWSE-am-goods  in frame Dialog-Frame.
  end.
  else do:
       message " Запись не найдена " view-as alert-box information .
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
PROCEDURE ver-db :
if v-cntxt-db-num <> 0 then do:
    if  buf_matrix.asmt-type = 'Шаблон':U  then do:
        if v-cntxt-db-num <> buf_matrix.asmt-db-num-create then do:
          message
            "Нельзя редактировать ШАБЛОН Ассортиментная матрица созданный в чужой УБД"
            view-as alert-box error.
            return  error.
        end.
    end.
    else do:
        define variable obj-db-num as integer   no-undo .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_matrix.obj-type
  ,input  buf_matrix.obj-code
  ,output obj-db-num
  )  .
        if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> obj-db-num  then do:
          message
            "Нельзя редактировать запись Ассортиментная матрица чужой УБД"
            view-as alert-box error.
            return  error.
        end.
    end.
end.
END PROCEDURE.
