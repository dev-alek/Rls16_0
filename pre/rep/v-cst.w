define input parameter parparentproc as widget-handle no-undo .
define input parameter parobj-type  like ub.parts.obj-type no-undo.
define input parameter parobj-code  like ub.parts.obj-code no-undo.
define input parameter from-date    as date no-undo .
define input parameter to-date      as date no-undo .
define input parameter partnved     as character        no-undo.
define input parameter parcst-units as character        no-undo.
define input parameter parkindrep   as character        no-undo.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Таможенный отчет".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
DEFINE  SHARED TEMP-TABLE TT-tnved NO-UNDO
FIELD tnved  AS CHAR FORMAT "X(10)"  LABEL 'Код ТНВЭД':U
FIELD f-name AS CHAR FORMAT "X(255)" LABEL 'Полное наименование':U
INDEX tnved IS UNIQUE PRIMARY  tnved.
DEFINE new SHARED TEMP-TABLE gds-brutto NO-UNDO
    FIELD artic          LIKE ub.goods.artic
    FIELD prod-type      LIKE ub.parts.prod-type
    FIELD prod-code      LIKE ub.parts.prod-code
    FIELD cst-code       LIKE ub.parts.cst-code
    FIELD gds-name       LIKE ub.goods.gds-name
    FIELD unit           LIKE ub.goods.unit-base
    FIELD in-qnty        LIKE ub.parts.fact-qnty
    FIELD in-wt-brutto   LIKE ub.doc-line.wt-brutto
    FIELD in-fact-place  LIKE ub.doc-line.num-place
    FIELD out-qnty       LIKE ub.parts.fact-qnty
    FIELD out-wt-brutto  LIKE ub.doc-line.wt-brutto
    FIELD out-fact-place LIKE ub.doc-line.num-place
    INDEX art IS PRIMARY artic cst-code ASCENDING
    .
DEFINE new SHARED TEMP-TABLE parts-brutto    NO-UNDO
    FIELD in-code       LIKE ub.parts.in-code
    FIELD out-code      LIKE ub.parts.out-code
    FIELD part-code     LIKE ub.parts.part-code
    FIELD part-type     AS   CHARACTER
    FIELD obj-code      LIKE ub.parts.obj-code
    FIELD obj-type      LIKE ub.parts.obj-type
    FIELD host-code     LIKE ub.parts.host-code
    FIELD artic         LIKE ub.parts.artic
    FIELD prod-type     LIKE ub.parts.prod-type
    FIELD prod-code     LIKE ub.parts.prod-code
    FIELD gds-name      LIKE ub.goods.gds-name
    FIELD tnved         LIKE tt-tnved.tnved
    FIELD nationality   LIKE ub.goods.nationality
    FIELD unit          LIKE ub.goods.unit-base
    FIELD fact-date     LIKE ub.parts.fact-date
    FIELD fact-num      LIKE ub.parts.fact-num
    FIELD cst-code      LIKE ub.parts.cst-code
    FIELD fact-qnty     LIKE ub.parts.fact-qnty
    FIELD qnty-up       LIKE ub.parts.fact-qnty
    FIELD down-qnty     LIKE ub.parts.fact-qnty
    FIELD fact-brutto   LIKE ub.doc-line.wt-brutto
    FIELD fact-place    LIKE ub.doc-line.num-place
    INDEX atom IS PRIMARY
                  part-type
                  host-code
                  obj-code
                  obj-type
                  artic
                  prod-type
                  prod-code
                  cst-code
    INDEX fact-num fact-num  ASCENDING.
DEFINE BUFFER bf-parts-brutto  FOR parts-brutto.
DEFINE BUFFER out-parts-brutto FOR parts-brutto.
DEFINE BUFFER in-parts-brutto FOR parts-brutto.
DEFINE new SHARED TEMP-TABLE prt-parts-brutto    NO-UNDO
    FIELD in-date        AS   CHARACTER
    FIELD cst-code       LIKE ub.parts.cst-code
    FIELD artic          LIKE ub.goods.artic
    FIELD prod-code      LIKE ub.goods.prod-code
    FIELD prod-type      LIKE ub.goods.prod-type
    FIELD obj-code       LIKE ub.parts.obj-code
    FIELD obj-type       LIKE ub.parts.obj-type
    FIELD host-code      LIKE ub.parts.host-code
    FIELD in-num         LIKE ub.parts.fact-num
    FIELD out-num        LIKE ub.parts.fact-num
    FIELD tnved          LIKE tt-tnved.tnved
    FIELD gds-name       LIKE ub.goods.gds-name
    FIELD nationality    LIKE ub.goods.nationality
    FIELD unit           LIKE ub.goods.unit-base
    FIELD in-qnty        AS   CHARACTER
    FIELD in-qnty-up     AS   CHARACTER
    FIELD in-wt-brutto   AS   CHARACTER
    FIELD in-fact-place  AS   CHARACTER
    FIELD out-date       AS   CHARACTER
    FIELD out-qnty       AS   CHARACTER
    FIELD out-qnty-up    AS   CHARACTER
    FIELD out-wt-brutto  AS   CHARACTER
    FIELD out-fact-place AS   CHARACTER
    FIELD des            AS   CHARACTER
    INDEX in-out IS PRIMARY cst-code in-num out-num ASCENDING .
define new global shared variable g#libbcrcn as handle no-undo .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable line-rec as recid no-undo .
IF partnved = "Всё" THEN ASSIGN partnved = "".
DEFINE BUFFER l-gds-brutto FOR gds-brutto.
DEFINE BUFFER in-doc FOR ub.trn-doc.
DEFINE BUFFER in-line FOR ub.doc-line.
def var conf-par as char no-undo.
def var par-type as char no-undo.
def var in-out-qnty like ub.parts.fact-qnty no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
DEFINE BUTTON b-excel DEFAULT
     LABEL "Excel"
     size 9 by 1.
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     size 9 by 1.
DEFINE BUTTON b-parts DEFAULT
     LABEL "&Детализация"
     size 12 by 1.
DEFINE BUTTON b-print DEFAULT
     LABEL "Пе&чать"
     size 9 by 1.
DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "Вы&ход "
     size 9 by 1
     BGCOLOR 8 .
DEFINE VARIABLE loc-art AS CHARACTER FORMAT "X(16)":U
     LABEL "Начало артикула"
     VIEW-AS FILL-IN
     size 17 by 1
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE loc-code AS CHARACTER FORMAT "X(13)":U
     LABEL "Бар-код (весь)"
     VIEW-AS FILL-IN
     size 14 by 1
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE loc-name AS CHARACTER FORMAT "X(50)":U
     LABEL "Начало названия"
     VIEW-AS FILL-IN
     size 20 by 1
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&А", "art",
"&Н", "name",
"&К", "code"
     size 15 by 1 NO-UNDO.
DEFINE QUERY br-gds-brutto FOR
      gds-brutto SCROLLING.
DEFINE BROWSE br-gds-brutto
  QUERY br-gds-brutto DISPLAY
      gds-brutto.artic         COLUMN-LABEL "Артикул! "
gds-brutto.gds-name      COLUMN-LABEL "Название товара! "
gds-brutto.cst-code      COLUMN-LABEL "Номер ГТД" FORMAT "X(31)"
gds-brutto.unit          COLUMN-LABEL "Ед.!Изм." FORMAT "X(5)"
gds-brutto.in-qnty       COLUMN-LABEL "Приход! количество"   FORMAT "->,>>>,>>9.<<<"
gds-brutto.in-wt-brutto  COLUMN-LABEL "Приход! вес брутто"   FORMAT "->,>>>,>>9.<<<"
gds-brutto.in-fact-place COLUMN-LABEL "Приход! кол-во мест"  FORMAT "->,>>>,>>9.<<<"
gds-brutto.out-qnty      COLUMN-LABEL "Расход! количество"   FORMAT "->,>>>,>>9.<<<"
gds-brutto.out-wt-brutto COLUMN-LABEL "Расход! вес брутто"   FORMAT "->,>>>,>>9.<<<"
gds-brutto.out-fact-place COLUMN-LABEL "Расход! кол-во мест" FORMAT "->,>>>,>>9.<<<"
gds-brutto.in-qnty - gds-brutto.out-qnty COLUMN-LABEL "Остаток! по приходу"  FORMAT "->,>>>,>>9.<<<"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 11.75.
DEFINE FRAME v-suppl
     b-excel at row 1.17 col 45
     b-print at row 1.17 col 12
     b-help at row 1.17 col 35
     b-quit at row 1.17 col 2
     loc-art at row 2.5 col 33.5 COLON-ALIGNED
     b-parts at row 1.17 col 22
     a-n-c at row 2.5 col 2 NO-LABEL
     loc-code at row 2.5 col 33.5 COLON-ALIGNED
     loc-name at row 2.5 col 33.5 COLON-ALIGNED
     br-gds-brutto AT ROW 3.71 COL 1.38
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D
         size 98.88 by 15.79
         TITLE "".
ASSIGN
       FRAME v-suppl:SCROLLABLE       = FALSE
       FRAME v-suppl:HIDDEN           = TRUE.
ASSIGN
       loc-art:HIDDEN IN FRAME v-suppl           = TRUE.
ASSIGN
       loc-code:HIDDEN IN FRAME v-suppl           = TRUE.
ASSIGN
       loc-name:HIDDEN IN FRAME v-suppl           = TRUE.
ON WINDOW-CLOSE OF FRAME v-suppl
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-excel IN FRAME v-suppl
DO:
DEFINE VARIABLE chExcelApplication      AS COM-HANDLE.
DEFINE VARIABLE chWorkbook              AS COM-HANDLE.
DEFINE VARIABLE chWorksheet             AS COM-HANDLE.
DEFINE VARIABLE iColumn                 AS INTEGER INITIAL 1.
DEFINE VARIABLE cColumn                 AS CHARACTER.
DEFINE VARIABLE cRange                  AS CHARACTER.
CREATE "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        return no-apply .
    end.
chExcelApplication:Visible = TRUE.
chWorkbook = chExcelApplication:Workbooks:Add().
chWorkSheet = chExcelApplication:Sheets:Item(1).
chWorkSheet:Columns("A":U):ColumnWidth = 17.
chWorkSheet:Columns("B":U):ColumnWidth = 15.
chWorkSheet:Columns("C":U):ColumnWidth = 22.
chWorkSheet:Columns("D":U):ColumnWidth = 10.
chWorkSheet:Columns("E":U):ColumnWidth = 16.
chWorkSheet:Columns("F":U):ColumnWidth = 40.
chWorkSheet:Columns("G":U):ColumnWidth = 20.
chWorkSheet:Columns("H":U):ColumnWidth = 3.
chWorkSheet:Columns("I":U):ColumnWidth = 25.
chWorkSheet:Columns("J":U):ColumnWidth = 25.
chWorkSheet:Columns("K":U):ColumnWidth = 25.
chWorkSheet:Columns("L":U):ColumnWidth = 25.
chWorkSheet:Columns("M":U):ColumnWidth = 10.
chWorkSheet:Columns("N":U):ColumnWidth = 25.
chWorkSheet:Columns("O":U):ColumnWidth = 25.
chWorkSheet:Columns("P":U):ColumnWidth = 25.
chWorkSheet:Columns("Q":U):ColumnWidth = 25.
chWorkSheet:Columns("R":U):ColumnWidth = 25.
chWorkSheet:Columns("S":U):ColumnWidth = 25.
chWorkSheet:Range("A1:S1"):Font:Bold = TRUE.
chWorkSheet:Range("A1"):Value = "Номер по порядку".
chWorkSheet:Range("B1"):Value = "Дата поступления".
chWorkSheet:Range("C1"):Value = "ГТД".
chWorkSheet:Range("D1"):Value = "ТаможКод".
chWorkSheet:Range("E1"):Value = "Артикул".
chWorkSheet:Range("F1"):Value = "Наименование товара".
chWorkSheet:Range("G1"):Value = "Статус товара".
chWorkSheet:Range("H1"):Value = "Ед".
chWorkSheet:Range("I1"):Value = "Кол-во ед. при поступлении".
chWorkSheet:Range("J1"):Value = "Кол-во уп. при поступлении".
chWorkSheet:Range("K1"):Value = "Вес при поступлении".
chWorkSheet:Range("L1"):Value = "Кол-во мест при поступлении".
chWorkSheet:Range("M1"):Value = "Дата выбытия".
chWorkSheet:Range("N1"):Value = "Кол-во ед. при выбытии".
chWorkSheet:Range("O1"):Value = "Кол-во уп. при выбытии".
chWorkSheet:Range("P1"):Value = "Вес при выбытии".
chWorkSheet:Range("Q1"):Value = "Кол-во мест при выбытии".
chWorkSheet:Range("R1"):Value = "Остаток".
chWorkSheet:Range("S1"):Value = "Примечание".
FOR EACH prt-parts-brutto:
  iColumn = iColumn + 1.
  cColumn = STRING(iColumn).
  cRange = "A":U + cColumn.
  chWorkSheet:Range(cRange):Value = iColumn - 1.
  cRange = "B":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.in-date.
  cRange = "C":U + cColumn.
  chWorkSheet:Range(cRange):NumberFormat = "@" .
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.cst-code.
  cRange = "D":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.tnved.
  cRange = "E":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.artic.
  cRange = "F":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.gds-name.
  cRange = "G":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.nationality.
  cRange = "H":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.unit.
  cRange = "I":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.in-qnty.
  cRange = "J":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.in-qnty-up.
  cRange = "K":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.in-wt-brutto.
  cRange = "L":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.in-fact-place.
  cRange = "M":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.out-date.
  cRange = "M":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.out-qnty.
  cRange = "N":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.out-qnty-up.
  cRange = "O":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.out-wt-brutto.
  cRange = "P":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.out-fact-place.
  cRange = "R":U + cColumn.
  chWorkSheet:Range(cRange):Value = decimal(prt-parts-brutto.in-qnty) - decimal(prt-parts-brutto.out-qnty).
  cRange = "S":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.des.
END.
RELEASE OBJECT chWorksheet NO-ERROR.
RELEASE OBJECT chWorkbook NO-ERROR.
chExcelApplication :QUIT().
RELEASE OBJECT  chExcelApplication  NO-ERROR.
END.
ON CHOOSE OF b-parts IN FRAME v-suppl
DO:
  if available gds-brutto then
  run rep/v-cst-dt.w (input from-date, input to-date, input gds-brutto.cst-code, input gds-brutto.artic).
  APPLY "ENTRY" TO BROWSE br-gds-brutto.
END.
ON CHOOSE OF b-print IN FRAME v-suppl
DO:
def var num-order as int no-undo.
def var sym1 as char init ":"   no-undo.
def var sym2 as char init ":"   no-undo.
def var sym3 as char init ":"   no-undo.
def var sym4 as char init ":"   no-undo.
def var sym5 as char init ":"   no-undo.
def var sym6 as char init ":"   no-undo.
def var sym7 as char init ":"   no-undo.
def var sym8 as char init ":"   no-undo.
def var sym9 as char init ":"   no-undo.
def var sym10 as char init ":"   no-undo.
def var sym11 as char init ":"   no-undo.
def var sym12 as char init ":"   no-undo.
def var sym13 as char init ":"   no-undo.
def var sym14 as char init ":"   no-undo.
def var sym15 as char init ":"   no-undo.
def var Line as char no-undo.
def var varTemp as char no-undo.
DEFINE FRAME gds-brutto-store
      sym1 column-label ":!:" format "X(1)"
      num-order COLUMN-LABEL "Номер по!порядку "
      sym2 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-date COLUMN-LABEL "Поступ! на склад"
      sym3 column-label ":!:" format "X(1)"
      prt-parts-brutto.cst-code COLUMN-LABEL "Номер!ГТД" FORMAT "X(31)"
      sym4 column-label ":!:" format "X(1)"
      prt-parts-brutto.tnved COLUMN-LABEL "Тамож.код"
      sym5 column-label ":!:" format "X(1)"
      prt-parts-brutto.gds-name format "x(25)" COLUMN-LABEL "Таможенное название!"
      sym6 column-label ":!:" format "X(1)"
      prt-parts-brutto.artic COLUMN-LABEL "Артикул"
      sym7 column-label ":!:" format "X(1)"
      prt-parts-brutto.nationality COLUMN-LABEL "Статус!товара"
      sym8 column-label ":!:" format "X(1)"
      prt-parts-brutto.unit COLUMN-LABEL "ЕдИзм"
      sym9 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-qnty COLUMN-LABEL "Кол-во пост."
      sym10 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-wt-brutto COLUMN-LABEL "Вес брутто! пост."
      sym11 column-label ":!:" format "X(1)"
      prt-parts-brutto.out-date  COLUMN-LABEL "Дата! выпуска"
      sym12 column-label ":!:" format "X(1)"
      prt-parts-brutto.out-qnty COLUMN-LABEL "Кол-во вып."
      sym13 column-label ":!:" format "X(1)"
      prt-parts-brutto.out-wt-brutto  COLUMN-LABEL "Вес брутто! вып."
      sym14 column-label ":!:" format "X(1)"
      varTemp format "X(2)" column-label "Прим"
      sym15 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Отчет по таможенной позиции: " + partnved) AT 45 format "X(40)"
        string( "Количества указаны в " + (if parcst-units = "Базовая" then "базовых еденицах." else "таможенных еденицах.") ) AT 100 format "X(42)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 150 format "X(13)" SKIP
        Line format "X(229)" AT 1
    with width 232 down stream-io.
DEFINE FRAME gds-brutto-shop
      sym1 column-label ":!:" format "X(1)"
      num-order COLUMN-LABEL "Номер по!порядку "
      sym2 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-date COLUMN-LABEL "Дата пост! в магазин"
      sym3 column-label ":!:" format "X(1)"
      prt-parts-brutto.cst-code COLUMN-LABEL "Номер!ГТД" FORMAT "X(31)"
      sym4 column-label ":!:" format "X(1)"
      prt-parts-brutto.tnved COLUMN-LABEL "Тамож. код"
      sym5 column-label ":!:" format "X(1)"
      prt-parts-brutto.artic COLUMN-LABEL "Артикул"
      sym6 column-label ":!:" format "X(1)"
      prt-parts-brutto.gds-name FORMAT "X(25)" COLUMN-LABEL "Таможенное название!"
      sym7 column-label ":!:" format "X(1)"
      prt-parts-brutto.nationality COLUMN-LABEL "Статус!товара"
      sym8 column-label ":!:" format "X(1)"
      prt-parts-brutto.unit COLUMN-LABEL "ЕдИзм"
      sym9 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-qnty COLUMN-LABEL "Кол-во пост."
      sym10 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-fact-place COLUMN-LABEL "Кол-во мест"
      sym11 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-wt-brutto COLUMN-LABEL "Вес брутто в кг"
      sym12 column-label ":!:" format "X(1)"
      prt-parts-brutto.out-qnty COLUMN-LABEL "Реализовано"
      sym13 column-label ":!:" format "X(1)"
      in-out-qnty COLUMN-LABEL "Остаток"
      sym14 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Отчет по таможенной позиции: " + partnved) AT 45 format "X(40)"
        string( "Количества указаны в " + (if parcst-units = "Базовая" then "базовых еденицах." else "таможенных еденицах.") ) AT 100 format "X(42)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 150 format "X(13)" SKIP
        Line format "X(229)" AT 1
    with width 232 down stream-io.
if session:set-wait-state("COMPILER") then.
assign Line = fill("-", 232).
if parkindrep = "OUT" THEN DO:
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input 43
                                              ,input yes
                                              ,input no
                                              ).
   FORM with FRAME gds-brutto-store.
END.
ELSE DO:
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input 43
                                              ,input yes
                                              ,input no
                                              ).
     FORM with FRAME gds-brutto-shop.
END.
FORM HEADER
    Line format "X(229)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 60 SKIP
    with FRAME BottomFrame width 232
    PAGE-BOTTOM no-labels no-box.
VIEW STREAM PrnLibStream FRAME BottomFrame .
PUT STREAM PrnLibStream
    string( "Отчет за период с: " + string(from-date,"99/99/9999") + " по: " + string(to-date,"99/99/9999"))
    AT 37 format "X(229)" SKIP(1).
    ASSIGN num-order = 0.
FOR EACH prt-parts-brutto:
      ASSIGN num-order = num-order + 1.
      if parkindrep = "OUT" THEN DO:
         DISPLAY STREAM PrnLibStream
         sym1
         num-order
         sym2
         prt-parts-brutto.in-date
         sym3
         prt-parts-brutto.cst-code
         sym4
         prt-parts-brutto.tnved
         sym5
         prt-parts-brutto.gds-name
         sym6
         prt-parts-brutto.artic
         sym7
         prt-parts-brutto.nationality
         sym8
         prt-parts-brutto.unit
         sym9
         prt-parts-brutto.in-qnty
         sym10
         prt-parts-brutto.in-wt-brutto
         sym11
         prt-parts-brutto.out-date
         sym12
         prt-parts-brutto.out-qnty
         sym13
         prt-parts-brutto.out-wt-brutto
         sym14
         varTemp
         sym15
         with FRAME gds-brutto-store.
         DOWN STREAM PrnLibStream 1 with FRAME gds-brutto-store .
      END.
      ELSE DO:
         DISPLAY STREAM PrnLibStream
         sym1
         num-order
         sym2
         prt-parts-brutto.in-date
         sym3
         prt-parts-brutto.cst-code
         sym4
         prt-parts-brutto.tnved
         sym5
         prt-parts-brutto.artic
         sym6
         prt-parts-brutto.gds-name
         sym7
         prt-parts-brutto.nationality
         sym8
         prt-parts-brutto.unit
         sym9
         prt-parts-brutto.in-qnty
         sym10
         prt-parts-brutto.in-fact-place
         sym11
         prt-parts-brutto.in-wt-brutto
         sym12
         prt-parts-brutto.out-qnty
         sym13
         STRING(DECIMAL(prt-parts-brutto.in-qnty) -
         DECIMAL(prt-parts-brutto.out-qnty)) @ in-out-qnty
         sym14
         with FRAME gds-brutto-shop.
         DOWN STREAM PrnLibStream 1 with FRAME gds-brutto-shop.
      END.
END.
IF parkindrep = "OUT" THEN DO:
   PUT STREAM PrnLibStream Line format "X(229)" SKIP.
   DOWN STREAM PrnLibStream 1 with FRAME gds-brutto-store .
END.
ELSE DO:
    PUT STREAM PrnLibStream Line format "X(229)" SKIP.
    DOWN STREAM PrnLibStream 1 with FRAME gds-brutto-shop .
END.
HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.
if session:set-wait-state("") then.
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
APPLY "ENTRY" TO BROWSE br-gds-brutto.
END.
ON MOUSE-SELECT-DBLCLICK OF br-gds-brutto IN FRAME v-suppl
DO:
  APPLY "CHOOSE" TO b-parts IN FRAME v-suppl.
END.
ON RETURN OF br-gds-brutto IN FRAME v-suppl
DO:
  APPLY "CHOOSE" TO b-parts IN FRAME v-suppl.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME v-suppl:PARENT eq ?
THEN FRAME v-suppl:PARENT = ACTIVE-WINDOW.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref6 as character no-undo .
define variable varpgscales-pref6 as character no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type7 as character no-undo.
varscales-pref6  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref6
  ,output varscales-pref-type7
  ) no-error .
if varscales-pref6 = ? then do:
  assign
  varscales-pref6 = '21,23,25':U.
end.
define variable varpgscales-pref-type7 as character no-undo.
varpgscales-pref6  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref6
  ,output varpgscales-pref-type7
  ) no-error .
if varpgscales-pref6 = ? then do:
  assign
  varpgscales-pref6 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
on value-changed of a-n-c in frame v-suppl do:
  run proc-valchg-a-n-c in this-procedure  no-error.
  return no-apply.
end.
on any-printable of br-gds-brutto in frame v-suppl do:
  run proc-any-printable-br-gds-brutto in this-procedure   no-error.
  return no-apply.
end.
on backspace of br-gds-brutto in frame v-suppl do:
  run proc-backspace-br-gds-brutto in this-procedure   no-error.
  return no-apply.
end.
ON return OF loc-code IN FRAME v-suppl do:
  run proc-mouse-dbl-click-loc-code in this-procedure   no-error.
  return no-apply.
end.
ON return, Ctrl-J OF loc-name IN FRAME v-suppl do:
  run proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.
PROCEDURE proc-valchg-a-n-c:
  case input frame v-suppl a-n-c :
    when "art" then do:
      apply "entry" to br-gds-brutto in frame v-suppl.
      hide loc-name loc-code
      in frame v-suppl.
      loc-art = "".
    end.
    when "name" then do:
      enable loc-name with frame v-suppl.
      disp loc-name with frame v-suppl.
      hide loc-art loc-code
      in frame v-suppl.
      apply "entry" to loc-name in frame v-suppl.
    end.
    when "code"
 or when "DataMatrix" then
    do:
      enable loc-code with frame v-suppl.
      disp loc-code with frame v-suppl.
      hide loc-art loc-name
      in frame v-suppl.
      apply "entry" to loc-code in frame v-suppl.
    end.
  end CASE.
END PROCEDURE.
PROCEDURE proc-any-printable-br-gds-brutto :
  if input frame v-suppl a-n-c = "art" then do:
    if last-event:label = " " and
       loc-art = "" then
    return error.
    find first l-gds-brutto where
                l-gds-brutto.artic begins (loc-art + last-event:label)
               no-lock no-error.
    if available l-gds-brutto then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame v-suppl.
      line-rec = recid (l-gds-brutto).
      reposition br-gds-brutto to recid line-rec no-error.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-backspace-br-gds-brutto:
  if input frame v-suppl a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
    find first l-gds-brutto where
                l-gds-brutto.artic begins loc-art
               no-lock.
    disp loc-art with frame v-suppl.
    line-rec = recid (l-gds-brutto).
    reposition br-gds-brutto to recid line-rec no-error.
  end.
END PROCEDURE.
PROCEDURE proc-mouse-dbl-click-loc-code:
def var str-code as integer no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define buffer l-goods for ub.goods.
define buffer l-bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
  assign
  frame v-suppl
  loc-code
  a-n-c.
  if a-n-c = "datamatrix"
  then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_dm-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  parobj-type
,input  parobj-code
,input  yes
,input  no
,input  varscales-pref6
,input  varpgscales-pref6
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
     if varresult eq "prod-bc"
     then
        loc-code:screen-value in frame v-suppl = buf_prod-bc.b-str.
  end.
  else do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  parobj-type
,input  parobj-code
,input  yes
,input  no
,input  varscales-pref6
,input  varpgscales-pref6
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
end.
  if available buf_bar-code then do:
        find first l-goods where
                  l-goods.gds-code =
  buf_bar-code.gds-code No-LOCK.
        find first l-gds-brutto where
                  l-gds-brutto.artic = l-goods.artic AND
                  l-gds-brutto.prod-type = l-goods.prod-type AND
                  l-gds-brutto.prod-code = l-goods.prod-code no-lock no-error.
    if available l-gds-brutto then do:
      line-rec = recid (l-gds-brutto).
      reposition br-gds-brutto to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  end.
  else
    message "Бар-код не найден."
            view-as alert-box error.
  apply "entry" to loc-code in frame v-suppl.
END PROCEDURE.
PROCEDURE  proc-mouse-dbl-click-loc-name:
  assign
  frame v-suppl
  loc-name.
    if last-event:label = "Ctrl-J" then
      find next l-gds-brutto where
                can-find (ub.goods where ub.goods.artic = l-gds-brutto.artic and
                ub.goods.prod-type = l-gds-brutto.prod-type and
                ub.goods.prod-code = l-gds-brutto.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    else
      find first l-gds-brutto where
                can-find (ub.goods where ub.goods.artic = l-gds-brutto.artic and
                ub.goods.prod-type = l-gds-brutto.prod-type and
                ub.goods.prod-code = l-gds-brutto.prod-code and
                ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if available l-gds-brutto then do:
      line-rec = recid (l-gds-brutto).
      reposition br-gds-brutto to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  apply "entry" to loc-name in frame v-suppl.
END PROCEDURE.
on value-changed of br-gds-brutto in frame v-suppl do:
if not available gds-brutto or recid (gds-brutto) <> line-rec then do:
    hide loc-art in frame v-suppl.
    loc-art = "".
end.
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame v-suppl
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
on choose of b-help in frame v-suppl
do:
  apply "help":u to frame v-suppl .
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame v-suppl:width - 0.3
                fh            = frame v-suppl:first-child
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame v-suppl :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame v-suppl :height-chars)
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
    if frame v-suppl :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame v-suppl :height-chars)
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
            frame v-suppl :height = v-frame-height
          .
          if frame v-suppl :scrollable = true
          then do:
            assign
              frame v-suppl :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame v-suppl :scrollable = true
          then do:
            assign
              frame v-suppl :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame v-suppl :height = v-frame-height
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
      v-frame-height = frame v-suppl :height
      v-frame-virtual-height = frame v-suppl :virtual-height
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
      v-field-group-handle = frame v-suppl :first-child
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
    do with frame v-suppl
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame v-suppl :scrollable = true
      then do:
        assign
          frame v-suppl :virtual-height = frame v-suppl :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame v-suppl :height = frame v-suppl :height + p-change-value
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
        frame v-suppl :height = frame v-suppl :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame v-suppl :scrollable = true
      then do:
        assign
          frame v-suppl :virtual-height = frame v-suppl :virtual-height + p-change-value
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
          ,input  string(frame v-suppl :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame v-suppl :height)
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
    if frame v-suppl :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame v-suppl :width
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
    if frame v-suppl :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame v-suppl :width
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
            frame v-suppl :width = v-frame-width
          .
          if frame v-suppl :scrollable = true
          then do:
            assign
              frame v-suppl :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame v-suppl :scrollable = true
          then do:
            assign
              frame v-suppl :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame v-suppl :width = v-frame-width
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
      v-frame-width = frame v-suppl :width
      v-frame-virtual-width = frame v-suppl :virtual-width
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
      v-field-group-handle = frame v-suppl :first-child
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
    do with frame v-suppl
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame v-suppl :scrollable = true
      then do:
        assign
          frame v-suppl :virtual-width = frame v-suppl :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame v-suppl :width = v-frame-width + p-change-value
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
        frame v-suppl :width = frame v-suppl :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame v-suppl :scrollable = true
      then do:
        assign
          frame v-suppl :virtual-width = frame v-suppl :virtual-width + p-change-value
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
          ,input  string(frame v-suppl :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame v-suppl :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame v-suppl
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame v-suppl :height - v-diasize-resize-button :height
                  - 1
                  - (frame v-suppl :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame v-suppl :width - v-diasize-resize-button :width
                  - 1
                  - (frame v-suppl :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame v-suppl
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
      v-row-delta = v-new-row - frame v-suppl :height
      v-col-delta = v-new-col - frame v-suppl :width
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
            - frame v-suppl :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame v-suppl :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame v-suppl :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame v-suppl :height-chars
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
      v-diasize-current-frame-width  = frame v-suppl :width
      v-diasize-current-frame-height = frame v-suppl :height
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
    do with frame v-suppl
    :
      assign
        v-diasize-orig-frame-height = frame v-suppl :height
        v-diasize-orig-frame-width  = frame v-suppl :width
        v-diasize-browse-handle     = browse br-gds-brutto :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame v-suppl :first-child
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-host-code
  )  .
   IF parobj-type = "all" THEN DO:
      for each ub.store where ub.store.host-code = v-host-code no-lock:
          RUN calc (input 'скл':U, input ub.store.obj-code) no-error.
          IF ERROR-STATUS:ERROR THEN RETURN ERROR.
      end.
      for each ub.shop where ub.shop.host-code = v-host-code no-lock:
          RUN calc (input 'маг':U, input ub.shop.obj-code) no-error.
          IF ERROR-STATUS:ERROR THEN RETURN ERROR.
      end.
  END.
  ELSE RUN calc (input parobj-type, input parobj-code) no-error.
  RUN enable_UI.
  IF parobj-type = "all" THEN
  FRAME v-suppl:TITLE =  "Сводный отчет c: " + string(from-date,"99/99/9999") +
                               " по: " + string(to-date,"99/99/9999").
  ELSE IF parkindrep = "OUT" THEN
  FRAME v-suppl:TITLE =  "Книга учета товаров на объекте:" + parobj-type + " " + STRING(parobj-code) +
                               " c: " + string(from-date,"99/99/9999") +
                               " по: " + string(to-date,"99/99/9999").
  ELSE
  FRAME v-suppl:TITLE =  "Отчет о поступлении и реализации товаров:" + parobj-type + " " + STRING(parobj-code) +
                               " c: " + string(from-date,"99/99/9999") +
                               " по: " + string(to-date,"99/99/9999").
  apply "entry" to br-gds-brutto in frame v-suppl.
  WAIT-FOR GO OF FRAME v-suppl.
END.
RUN disable_UI.
PROCEDURE bef-parts :
DEFINE INPUT PARAMETER basis-parts-type AS CHARACTER NO-UNDO.
FOR EACH bf-parts-brutto WHERE parts-brutto.part-type = basis-parts-type
    NO-LOCK BREAK BY bf-parts-brutto.host-code
                  BY bf-parts-brutto.obj-code
                  BY bf-parts-brutto.obj-type
                  BY bf-parts-brutto.artic
                  BY bf-parts-brutto.prod-code
                  BY bf-parts-brutto.prod-type
                  BY bf-parts-brutto.in-code:
    IF FIRST-OF(bf-parts-brutto.in-code) THEN DO:
       FOR EACH ub.parts WHERE  ub.parts.host-code  = bf-parts-brutto.host-code
                         AND ub.parts.obj-code   = bf-parts-brutto.obj-code
                         AND ub.parts.obj-type   = bf-parts-brutto.obj-type
                         AND ub.parts.artic      = bf-parts-brutto.artic
                         AND ub.parts.prod-code  = bf-parts-brutto.prod-code
                         AND ub.parts.prod-type  = bf-parts-brutto.prod-type
                         AND ub.parts.status_    = yes
                         AND ub.parts.fact-date  < from-date
                         AND ub.parts.in-code    = bf-parts-brutto.in-code
                         AND ub.parts.doc-type <> 'акт':U
                         NO-LOCK:
              find first in-doc where in-doc.doc-code  = ub.parts.in-code no-lock no-error.
              IF AVAILABLE in-doc THEN DO:
                 FIND FIRST in-line WHERE in-line.doc-code  = in-doc.doc-code AND
                                          in-line.artic     = parts.artic     AND
                                          in-line.prod-code = parts.prod-code AND
                                          in-line.prod-type = parts.prod-type NO-LOCK NO-ERROR.
                 IF NOT AVAILABLE in-line THEN DO:
                    MESSAGE "Во внешней приходной накладной:" in-doc.doc-code SKIP
                            "Не найдена строка по товару:" parts.artic " " parts.prod-code " " parts.prod-type SKIP
                    VIEW-AS ALERT-BOX ERROR.
                    RETURN ERROR.
                 END.
              END.
              FIND FIRST ub.goods WHERE ub.goods.artic     = ub.parts.artic     AND
                                     ub.goods.prod-code = ub.parts.prod-code AND
                                     ub.goods.prod-type = ub.parts.prod-type NO-LOCK.
              RUN cr-parts-brutto.
       END.
    END.
END.
END PROCEDURE.
PROCEDURE calc :
DEFINE INPUT PARAMETER lparobj-type LIKE ub.parts.obj-type NO-UNDO.
DEFINE INPUT PARAMETER lparobj-code LIKE ub.parts.obj-code NO-UNDO.
def buffer b-parts for ub.parts.
if session:set-wait-state("COMPILER") then.
run waitfram-show in this-procedure
  (input "Подождите..."
  ).
FOR EACH ub.goods WHERE ub.goods.tnved begins partnved NO-LOCK,
    EACH ub.parts WHERE ub.parts.host-code  = v-host-code
                 AND ub.parts.obj-code   = lparobj-code
                 AND ub.parts.obj-type   = lparobj-type
                 AND ub.parts.artic      = ub.goods.artic
                 AND ub.parts.prod-code  = ub.goods.prod-code
                 AND ub.parts.prod-type  = ub.goods.prod-type
                 AND ub.parts.status_    = yes
                 AND ub.parts.fact-date <= to-date
                 AND ub.parts.fact-date >= from-date
                 AND ub.parts.doc-type <> 'акт':U NO-LOCK:
    IF parobj-type = "all" THEN DO:
       FIND FIRST ub.trn-doc WHERE ub.trn-doc.doc-code = ub.parts.out-code no-lock.
       IF ub.trn-doc.internal = yes THEN NEXT.
    END.
    IF (parcst-units = "Базовая" AND ub.parts.fact-qnty = 0)
       OR (parcst-units <> "Базовая" and ub.parts.fact-qnty * ub.goods.cst-base-rate = 0) THEN NEXT.
    find first in-doc where in-doc.doc-code  = ub.parts.in-code no-lock no-error.
    IF AVAILABLE in-doc THEN DO:
       FIND FIRST in-line WHERE in-line.doc-code  = in-doc.doc-code AND
                                in-line.artic     = ub.parts.artic     AND
                                in-line.prod-code = ub.parts.prod-code AND
                                in-line.prod-type = ub.parts.prod-type NO-LOCK NO-ERROR.
       IF NOT AVAILABLE in-line THEN DO:
          MESSAGE "Во внешней приходной накладной:" in-doc.doc-code SKIP
                  "Не найдена строка по товару:" ub.parts.artic " " ub.parts.prod-code " " ub.parts.prod-type SKIP
          VIEW-AS ALERT-BOX ERROR.
          RETURN ERROR.
       END.
    END.
    ELSE
    FIND FIRST ub.doc-line WHERE ub.doc-line.doc-code  = ub.parts.out-code  AND
                              ub.doc-line.artic     = ub.parts.artic          AND
                              ub.doc-line.prod-type = ub.parts.prod-type      AND
                              ub.doc-line.prod-code = ub.parts.prod-code      NO-LOCK.
    RUN cr-parts-brutto.
    FIND FIRST gds-brutto WHERE gds-brutto.artic    = parts-brutto.artic    AND
                                gds-brutto.cst-code = parts-brutto.cst-code NO-LOCK NO-ERROR.
    IF NOT AVAILABLE gds-brutto THEN DO:
       CREATE gds-brutto.
       ASSIGN gds-brutto.artic     = parts-brutto.artic
              gds-brutto.prod-type = parts-brutto.prod-type
              gds-brutto.prod-code = parts-brutto.prod-code
              gds-brutto.cst-code  = parts-brutto.cst-code
              gds-brutto.gds-name  = goods.gds-name
              gds-brutto.unit      = (IF parcst-units = "Базовая" THEN goods.unit-base ELSE goods.unit-cst).
    END.
    IF (parts.doc-type = 'рас':U OR                           parts.doc-type = 'спи':U OR                          (parts.doc-type = 'инв':U AND parts.fact-qnty < 0)) THEN
    ASSIGN gds-brutto.out-qnty      = gds-brutto.out-qnty      + (IF parcst-units = "Базовая" THEN parts.fact-qnty ELSE parts.fact-qnty * goods.cst-base-rate)
           gds-brutto.out-wt-brutto = gds-brutto.out-wt-brutto +
           (IF AVAILABLE in-doc
            THEN (in-line.wt-brutto  / in-line.fact-qnty) * parts.fact-qnty
            ELSE (doc-line.wt-brutto / doc-line.fact-qnty) * parts.fact-qnty)
           gds-brutto.out-fact-place  = gds-brutto.out-fact-place  +
           (IF AVAILABLE in-doc
            THEN (in-line.num-place  / in-line.fact-qnty) * parts.fact-qnty
            ELSE (doc-line.num-place / doc-line.fact-qnty) * parts.fact-qnty)            .
    ELSE
    ASSIGN gds-brutto.in-qnty       = gds-brutto.in-qnty       + (IF parcst-units = "Базовая" THEN parts.fact-qnty ELSE parts.fact-qnty * goods.cst-base-rate)
           gds-brutto.in-wt-brutto  = gds-brutto.in-wt-brutto  +
           (IF AVAILABLE in-doc
            THEN (in-line.wt-brutto  / in-line.fact-qnty) * parts.fact-qnty
            ELSE (doc-line.wt-brutto / doc-line.fact-qnty) * parts.fact-qnty)
           gds-brutto.in-fact-place  = gds-brutto.in-fact-place  +
           (IF AVAILABLE in-doc
            THEN (in-line.num-place  / in-line.fact-qnty) * parts.fact-qnty
            ELSE (doc-line.num-place / doc-line.fact-qnty) * parts.fact-qnty)            .
END.
IF parkindrep = "OUT" then run bef-parts ("OUT").
                      else run bef-parts ("IN").
FOR EACH parts-brutto WHERE  parts-brutto.part-type = "IN"
    BY parts-brutto.fact-num:
    IF parkindrep = "IN"                 AND
       parts-brutto.fact-date >= from-date THEN DO:
       CREATE prt-parts-brutto.
       ASSIGN
       prt-parts-brutto.des           = STRING(parts-brutto.out-code)
       prt-parts-brutto.in-date       = STRING(parts-brutto.fact-date)
       prt-parts-brutto.cst-code      = parts-brutto.cst-code
       prt-parts-brutto.obj-code      = parts-brutto.obj-code
       prt-parts-brutto.obj-type      = parts-brutto.obj-type
       prt-parts-brutto.host-code     = parts-brutto.host-code
       prt-parts-brutto.artic         = parts-brutto.artic
       prt-parts-brutto.prod-code     = parts-brutto.prod-code
       prt-parts-brutto.prod-type     = parts-brutto.prod-type
       prt-parts-brutto.in-num        = parts-brutto.fact-num
       prt-parts-brutto.tnved         = parts-brutto.tnved
       prt-parts-brutto.gds-name      = parts-brutto.gds-name
       prt-parts-brutto.nationality   = parts-brutto.nationality
       prt-parts-brutto.unit          = parts-brutto.unit
       prt-parts-brutto.in-qnty       = STRING(parts-brutto.fact-qnty)
       prt-parts-brutto.in-qnty-up    = string(parts-brutto.qnty-up)
       prt-parts-brutto.in-wt-brutto  = STRING(parts-brutto.fact-brutto)
       prt-parts-brutto.in-fact-place = STRING(parts-brutto.fact-place)
       prt-parts-brutto.out-qnty      = "0"
       prt-parts-brutto.out-qnty-up   = "0"
       prt-parts-brutto.out-wt-brutto = "0"
       prt-parts-brutto.out-fact-place = "0".
    END.
    IF parkindrep = "OUT" AND
       NOT CAN-FIND (FIRST out-parts-brutto WHERE out-parts-brutto.part-type = "OUT"                   AND
                                                  out-parts-brutto.host-code  = parts-brutto.host-code AND
                                                  out-parts-brutto.obj-code   = parts-brutto.obj-code  AND
                                                  out-parts-brutto.obj-type   = parts-brutto.obj-type  AND
                                                  out-parts-brutto.artic      = parts-brutto.artic     AND
                                                  out-parts-brutto.prod-type  = parts-brutto.prod-type AND
                                                  out-parts-brutto.prod-code  = parts-brutto.prod-code AND
                                                  out-parts-brutto.in-code    = parts-brutto.in-code   AND
                                                  out-parts-brutto.fact-num   > parts-brutto.fact-num  AND
                                                  out-parts-brutto.fact-qnty  - parts-brutto.down-qnty > 0)
                                    THEN DO:
       CREATE prt-parts-brutto.
       ASSIGN
       prt-parts-brutto.des           = STRING(parts-brutto.out-code)
       prt-parts-brutto.in-date       = STRING(parts-brutto.fact-date)
       prt-parts-brutto.cst-code      = parts-brutto.cst-code
       prt-parts-brutto.obj-code      = parts-brutto.obj-code
       prt-parts-brutto.obj-type      = parts-brutto.obj-type
       prt-parts-brutto.host-code     = parts-brutto.host-code
       prt-parts-brutto.artic         = parts-brutto.artic
       prt-parts-brutto.prod-code     = parts-brutto.prod-code
       prt-parts-brutto.prod-type     = parts-brutto.prod-type
       prt-parts-brutto.in-num        = parts-brutto.fact-num
       prt-parts-brutto.out-num       = ?
       prt-parts-brutto.tnved         = parts-brutto.tnved
       prt-parts-brutto.gds-name      = parts-brutto.gds-name
       prt-parts-brutto.nationality   = parts-brutto.nationality
       prt-parts-brutto.unit          = parts-brutto.unit
       prt-parts-brutto.in-qnty       = STRING(parts-brutto.fact-qnty)
       prt-parts-brutto.in-qnty-up    = string(parts-brutto.qnty-up)
       prt-parts-brutto.in-wt-brutto  = STRING(parts-brutto.fact-brutto)
       prt-parts-brutto.in-fact-place = STRING(parts-brutto.fact-place)
       prt-parts-brutto.out-date      = "НЕТ"
       prt-parts-brutto.out-qnty      = ""
       prt-parts-brutto.out-qnty-up   = ""
       prt-parts-brutto.out-wt-brutto = ""
       prt-parts-brutto.out-fact-place = "".
    END.
    FOR EACH out-parts-brutto WHERE out-parts-brutto.part-type  = "OUT"                       AND
                                    out-parts-brutto.host-code  = parts-brutto.host-code      AND
                                    out-parts-brutto.obj-code   = parts-brutto.obj-code       AND
                                    out-parts-brutto.obj-type   = parts-brutto.obj-type       AND
                                    out-parts-brutto.artic      = parts-brutto.artic          AND
                                    out-parts-brutto.prod-type  = parts-brutto.prod-type      AND
                                    out-parts-brutto.prod-code  = parts-brutto.prod-code      AND
                                    out-parts-brutto.in-code    = parts-brutto.in-code        AND
                                    out-parts-brutto.fact-num   > parts-brutto.fact-num       AND
                                    out-parts-brutto.fact-qnty  - parts-brutto.down-qnty > 0
                                    BREAK BY out-parts-brutto.fact-num:
        ASSIGN out-parts-brutto.down-qnty = out-parts-brutto.fact-qnty
               parts-brutto.down-qnty     = parts-brutto.down-qnty + out-parts-brutto.fact-qnty.
        IF (out-parts-brutto.fact-date >= from-date OR
            parts-brutto.fact-date     >= from-date )
           AND parkindrep = "OUT" THEN DO:
              CREATE prt-parts-brutto.
              ASSIGN
               prt-parts-brutto.des           = STRING(parts-brutto.out-code)
               prt-parts-brutto.in-date       = IF FIRST(out-parts-brutto.fact-num) THEN STRING(parts-brutto.fact-date) ELSE ""
               prt-parts-brutto.cst-code      = parts-brutto.cst-code
               prt-parts-brutto.artic         = parts-brutto.artic
               prt-parts-brutto.obj-code      = parts-brutto.obj-code
               prt-parts-brutto.obj-type      = parts-brutto.obj-type
               prt-parts-brutto.host-code     = parts-brutto.host-code
               prt-parts-brutto.prod-code     = parts-brutto.prod-code
               prt-parts-brutto.prod-type     = parts-brutto.prod-type
               prt-parts-brutto.in-num        = parts-brutto.fact-num
               prt-parts-brutto.out-num       = out-parts-brutto.fact-num
               prt-parts-brutto.tnved         = IF FIRST(out-parts-brutto.fact-num) THEN parts-brutto.tnved       ELSE ""
               prt-parts-brutto.gds-name      = IF FIRST(out-parts-brutto.fact-num) THEN parts-brutto.gds-name    ELSE ""
               prt-parts-brutto.nationality   = IF FIRST(out-parts-brutto.fact-num) THEN parts-brutto.nationality ELSE ""
               prt-parts-brutto.unit          = IF FIRST(out-parts-brutto.fact-num) THEN parts-brutto.unit        ELSE ""
               prt-parts-brutto.in-qnty       = IF FIRST(out-parts-brutto.fact-num)    AND
                                                   parts-brutto.fact-date >= from-date THEN STRING(parts-brutto.fact-qnty) ELSE ""
               prt-parts-brutto.in-qnty-up    = IF FIRST(out-parts-brutto.fact-num)    AND
                                                   parts-brutto.fact-date >= from-date THEN STRING(parts-brutto.qnty-up) ELSE ""
               prt-parts-brutto.in-wt-brutto  = IF FIRST(out-parts-brutto.fact-num)    AND
                                                   parts-brutto.fact-date >= from-date THEN STRING(parts-brutto.fact-brutto) ELSE ""
               prt-parts-brutto.in-fact-place  = IF FIRST(out-parts-brutto.fact-num)    AND
                                                   parts-brutto.fact-date >= from-date THEN STRING(parts-brutto.fact-place) ELSE ""
               prt-parts-brutto.out-date      = STRING(out-parts-brutto.fact-date)
               prt-parts-brutto.out-qnty      = STRING(out-parts-brutto.fact-qnty)
               prt-parts-brutto.out-qnty-up   = STRING(out-parts-brutto.qnty-up)
               prt-parts-brutto.out-wt-brutto = STRING(out-parts-brutto.fact-brutto)
               prt-parts-brutto.out-fact-place = STRING(out-parts-brutto.fact-place).
        END.
        ELSE IF parkindrep = "IN"  AND
                parts-brutto.fact-date >= from-date THEN DO:
              ASSIGN
               prt-parts-brutto.out-qnty       = STRING(DECIMAL(prt-parts-brutto.out-qnty) + out-parts-brutto.fact-qnty)
               prt-parts-brutto.out-wt-brutto  = STRING(DECIMAL(prt-parts-brutto.out-wt-brutto) + out-parts-brutto.fact-brutto)
               prt-parts-brutto.out-fact-place = STRING(DECIMAL(prt-parts-brutto.out-fact-place) + out-parts-brutto.fact-place).
        END.
        IF parts-brutto.fact-qnty - parts-brutto.down-qnty = 0 THEN LEAVE.
    END.
END.
IF parkindrep = "OUT" THEN
FOR EACH parts-brutto WHERE parts-brutto.part-type = "OUT" AND
                            NOT CAN-FIND(FIRST in-parts-brutto WHERE
                                          in-parts-brutto.part-type  = "IN"                        AND
                                          in-parts-brutto.host-code  = parts-brutto.host-code      AND
                                          in-parts-brutto.obj-code   = parts-brutto.obj-code       AND
                                          in-parts-brutto.obj-type   = parts-brutto.obj-type       AND
                                          in-parts-brutto.artic      = parts-brutto.artic          AND
                                          in-parts-brutto.prod-type  = parts-brutto.prod-type      AND
                                          in-parts-brutto.prod-code  = parts-brutto.prod-code      AND
                                          in-parts-brutto.in-code    = parts-brutto.in-code NO-LOCK) :
       CREATE prt-parts-brutto.
       ASSIGN
       prt-parts-brutto.in-date       = ?
       prt-parts-brutto.des           = STRING(parts-brutto.out-code)
       prt-parts-brutto.cst-code      = parts-brutto.cst-code
       prt-parts-brutto.obj-code      = parts-brutto.obj-code
       prt-parts-brutto.obj-type      = parts-brutto.obj-type
       prt-parts-brutto.host-code     = parts-brutto.host-code
       prt-parts-brutto.artic         = parts-brutto.artic
       prt-parts-brutto.prod-code     = parts-brutto.prod-code
       prt-parts-brutto.prod-type     = parts-brutto.prod-type
       prt-parts-brutto.in-num        = ?
       prt-parts-brutto.out-num       = ?
       prt-parts-brutto.tnved         = parts-brutto.tnved
       prt-parts-brutto.gds-name      = parts-brutto.gds-name
       prt-parts-brutto.nationality   = parts-brutto.nationality
       prt-parts-brutto.unit          = parts-brutto.unit
       prt-parts-brutto.in-qnty       = ?
       prt-parts-brutto.in-qnty-up    = ?
       prt-parts-brutto.in-wt-brutto  = ?
       prt-parts-brutto.in-fact-place = ?
       prt-parts-brutto.out-date      = STRING(parts-brutto.fact-date)
       prt-parts-brutto.out-qnty      = STRING(parts-brutto.fact-qnty)
       prt-parts-brutto.out-qnty-up   = string(parts-brutto.qnty-up)
       prt-parts-brutto.out-wt-brutto = STRING(parts-brutto.fact-brutto)
       prt-parts-brutto.out-fact-place = STRING(parts-brutto.fact-place).
END.
output close.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE cr-parts-brutto :
    FIND FIRST parts-brutto WHERE
                            parts-brutto.host-code     = ub.parts.host-code  AND
                            parts-brutto.obj-code      = ub.parts.obj-code   AND
                            parts-brutto.obj-type      = ub.parts.obj-type   AND
                            parts-brutto.artic         = ub.parts.artic      AND
                            parts-brutto.prod-type     = ub.parts.prod-type  AND
                            parts-brutto.prod-code     = ub.parts.prod-code  AND
                            parts-brutto.in-code       = ub.parts.in-code    AND
                            parts-brutto.part-type     = IF (parts.doc-type = 'рас':U OR                           parts.doc-type = 'спи':U OR                          (parts.doc-type = 'инв':U AND parts.fact-qnty < 0)) THEN "OUT" ELSE "IN" NO-ERROR.
    IF NOT AVAILABLE parts-brutto THEN DO:
       CREATE parts-brutto.
       ASSIGN
       parts-brutto.in-code       = ub.parts.in-code
       parts-brutto.out-code      = ub.parts.out-code
       parts-brutto.part-code     = ub.parts.part-code
       parts-brutto.host-code     = v-host-code
       parts-brutto.obj-code      = ub.parts.obj-code
       parts-brutto.obj-type      = ub.parts.obj-type
       parts-brutto.artic         = ub.parts.artic
       parts-brutto.prod-type     = ub.parts.prod-type
       parts-brutto.prod-code     = ub.parts.prod-code
       parts-brutto.gds-name      = ub.goods.gds-name
       parts-brutto.tnved         = ub.goods.tnved
       parts-brutto.nationality   = ub.goods.nationality
       parts-brutto.unit          = (IF parcst-units = "Базовая" THEN ub.goods.unit-base ELSE ub.goods.unit-cst)
       parts-brutto.part-type     = (IF (parts.doc-type = 'рас':U OR                           parts.doc-type = 'спи':U OR                          (parts.doc-type = 'инв':U AND parts.fact-qnty < 0)) THEN "OUT" ELSE "IN")
       parts-brutto.fact-date     = if available in-doc then in-doc.exch-date else parts.fact-date
       parts-brutto.fact-num      = ub.parts.fact-num
       parts-brutto.cst-code      = if ub.parts.cst-code <> ? then ub.parts.cst-code else ?.
    END.
    ASSIGN
    parts-brutto.fact-qnty     = parts-brutto.fact-qnty + (IF parcst-units = "Базовая" THEN parts.fact-qnty ELSE parts.fact-qnty * goods.cst-base-rate)
    parts-brutto.qnty-up       = parts-brutto.fact-qnty / ub.goods.qnty-cart
    parts-brutto.fact-brutto   = parts-brutto.fact-brutto +
    (IF AVAILABLE in-doc
     THEN (in-line.wt-brutto  / in-line.fact-qnty) * ub.parts.fact-qnty
     ELSE (ub.doc-line.wt-brutto / ub.doc-line.fact-qnty) * ub.parts.fact-qnty)
    parts-brutto.fact-place   = parts-brutto.fact-place +
    (IF AVAILABLE in-doc
     THEN (in-line.num-place  / in-line.fact-qnty) * ub.parts.fact-qnty
     ELSE (doc-line.num-place / ub.doc-line.fact-qnty) * ub.parts.fact-qnty).
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME v-suppl.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY a-n-c
      WITH FRAME v-suppl.
  ENABLE b-excel b-print b-help b-quit b-parts a-n-c br-gds-brutto
      WITH FRAME v-suppl.
  VIEW FRAME v-suppl.
  OPEN QUERY br-gds-brutto FOR EACH gds-brutto.
END PROCEDURE.
