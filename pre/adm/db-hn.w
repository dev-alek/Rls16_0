DEFINE BUFFER locked_hist-nws-option FOR ub.hist-nws-option.
DEFINE TEMP-TABLE tt-hist-nws-option NO-UNDO LIKE ub.hist-nws-option
       field hist-to-nws-is-on as logical
       field nws-to-hist-is-on as logical
       field get-hist-from-nws-is-on as logical
       field hist-to-nws-can as logical
       field nws-to-hist-can as logical
       field get-hist-from-nws-can as logical.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-db-num AS integer NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Опции записи истории и маршрутизации для БД".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-col as widget-handle extent 3.
DEFINE VARIABLE v-groups AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-subject-group AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-col-tbl-name AS WIDGET-HANDLE NO-UNDO.
FUNCTION get-hn-group-label RETURNS CHARACTER
  ( INPUT p-subject-group AS CHARACTER )  FORWARD.
FUNCTION get-hn-label RETURNS CHARACTER
  ( INPUT p-hn-option AS integer )  FORWARD.
DEFINE BUTTON b-copyrdb
     LABEL "&Копир.на все УБД"
     SIZE 20 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE CB-subject-group AS CHARACTER FORMAT "X(256)":U
     LABEL "Группы данных"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 32 BY 1 NO-UNDO.
DEFINE VARIABLE last-modify AS CHARACTER FORMAT "X(256)":U
     LABEL "Дата и время посл. обновления"
     VIEW-AS FILL-IN
     SIZE 21 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BR-option FOR
      tt-hist-nws-option SCROLLING.
DEFINE BROWSE BR-option
  QUERY BR-option DISPLAY
      get-hn-group-label(tt-hist-nws-option.subject-group) FORMAT "X(40)" COLUMN-LABEL "Группа данных"
tt-hist-nws-option.option-descr FORMAT "X(40)" COLUMN-LABEL "Сущность"
get-hn-label(tt-hist-nws-option.hist-to-nws) FORMAT "X(15)" COLUMN-LABEL "Пересылка ист.!в другие БД"
tt-hist-nws-option.hist-to-nws-is-on COLUMN-LABEL "Вкл/!выкл" VIEW-AS TOGGLE-BOX
get-hn-label(tt-hist-nws-option.nws-to-hist) FORMAT "X(15)" COLUMN-LABEL "Создание ист.!при приеме!по СПН"
tt-hist-nws-option.nws-to-hist-is-on COLUMN-LABEL "Вкл/!выкл" VIEW-AS TOGGLE-BOX
get-hn-label(tt-hist-nws-option.get-hist-from-nws) FORMAT "X(15)" COLUMN-LABEL "Прием истории!из другой!УБД"
tt-hist-nws-option.get-hist-from-nws-is-on COLUMN-LABEL "Вкл/!выкл" VIEW-AS TOGGLE-BOX
ENABLE
tt-hist-nws-option.hist-to-nws-is-on
tt-hist-nws-option.nws-to-hist-is-on
tt-hist-nws-option.get-hist-from-nws-is-on
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20.37 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     CB-subject-group AT ROW 1 COL 35 COLON-ALIGNED WIDGET-ID 4
     b-copyrdb AT ROW 1 COL 69
     b-hist AT ROW 1 COL 92 WIDGET-ID 8
     B-Help AT ROW 1 COL 95
     last-modify AT ROW 2.07 COL 74 COLON-ALIGNED WIDGET-ID 6
     BR-option AT ROW 3.27 COL 1
     SPACE(0.24) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Опции записи истории и маршрутизации для БД"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       CB-subject-group:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       last-modify:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-copyrdb IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE tt-hist-nws-option THEN RETURN NO-APPLY.
  RUN proc-copy-udb IN THIS-PROCEDURE ( BUFFER tt-hist-nws-option) NO-ERROR.
  if error-status:error then do:
    message
    error-status:get-message(1)
    substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    view-as alert-box error .
    return no-apply.
  end.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then do:
    message
    error-status:get-message(1)
    substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    view-as alert-box error .
    return no-apply.
  end.
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE tt-hist-nws-option THEN RETURN NO-APPLY.
  IF tt-hist-nws-option.table-name = '':U  THEN DO:
     run ref/hstcnws.w ( INPUT parparentproc
                        ,INPUT "":U
                        ,INPUT "subject-group-db"
                        ,INPUT tt-hist-nws-option.db-num
                        ,INPUT tt-hist-nws-option.subject-group
                        ,INPUT '':U
                        ,INPUT-OUTPUT v-rid-list ) NO-ERROR.
  END.
  ELSE DO:
      run ref/hstcnws.w ( INPUT parparentproc
                         ,INPUT "":U
                         ,INPUT "one-db"
                         ,INPUT tt-hist-nws-option.db-num
                         ,INPUT '':U
                         ,INPUT tt-hist-nws-option.table-name
                         ,INPUT-OUTPUT v-rid-list ) NO-ERROR.
  END.
  APPLY "ENTRY" TO br-option.
END.
ON VALUE-CHANGED OF CB-subject-group IN FRAME Dialog-Frame
DO:
 RUN switch-subject IN THIS-PROCEDURE .
 RUN Openbr IN THIS-PROCEDURE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-option :handle
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
ON "leave" OF tt-hist-nws-option.hist-to-nws-is-on  IN BROWSE br-option
DO:
   IF tt-hist-nws-option.hist-to-nws-can = NO
   or p-mode = 'ПРОСМОТР':U
   THEN DO:
    BELL.
    assign
    tt-hist-nws-option.hist-to-nws-is-on = (IF tt-hist-nws-option.hist-to-Nws = integer('10':U)
                                            THEN YES
                                            ELSE NO).
    display
    tt-hist-nws-option.hist-to-nws-is-on
    with browse br-option.
  END.
END.
ON "leave" OF tt-hist-nws-option.nws-to-hist-is-on  IN BROWSE br-option
DO:
   IF tt-hist-nws-option.nws-to-hist-can = NO
   or p-mode = 'ПРОСМОТР':U
   THEN DO:
    BELL.
    assign
    tt-hist-nws-option.nws-to-hist-is-on = (IF tt-hist-nws-option.nws-to-hist = integer('10':U)
                                            THEN YES
                                            ELSE NO).
    display
    tt-hist-nws-option.nws-to-hist-is-on
    with browse br-option.
  END.
END.
ON "leave" OF tt-hist-nws-option.get-hist-from-nws-is-on  IN BROWSE br-option
DO:
   IF tt-hist-nws-option.get-hist-from-nws-can = NO
   or p-mode = 'ПРОСМОТР':U
   THEN DO:
    BELL.
    assign
    tt-hist-nws-option.get-hist-from-nws-is-on = (IF tt-hist-nws-option.get-hist-from-nws = integer('10':U)
                                            THEN YES
                                            ELSE NO).
    display
    tt-hist-nws-option.get-hist-from-nws-is-on
    with browse br-option.
  END.
END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
IF NOT (p-mode = 'ИЗМЕНЕНИЕ':U
        OR p-mode = 'ПРОСМОТР':U) THEN  DO:
   MESSAGE
   vss-workfile vss-revision vss-description skip
   "Неверное значение параметра p-mode" p-mode
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN ERROR.
END.
if g#db-num <> 0
and p-db-num <> G#db-num
and p-mode <> 'ПРОСМОТР':U
then do:
  MESSAGE
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра p-db-num" p-db-num skip
  "Нельзя работать с настройками записи истории и машрутизации в чужой УБД"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
end.
IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
  DO ON ERROR UNDO, RETURN ERROR
     ON STOP UNDO, RETURN ERROR:
    FIND FIRST locked_hist-nws-option EXCLUSIVE-LOCK WHERE
            locked_hist-nws-option.db-num = p-db-num
        AND locked_hist-nws-option.hn-id = 0 NO-WAIT NO-ERROR .
    IF NOT AVAILABLE LOCKED_hist-nws-option
    AND NOT LOCKED LOCKED_hist-nws-option THEN DO:
        CREATE locked_hist-nws-option.
        ASSIGN
        locked_hist-nws-option.db-num = p-db-num
        locked_hist-nws-option.hn-id = 0
        .
    END.
    ELSE DO:
        FIND FIRST locked_hist-nws-option EXCLUSIVE-LOCK WHERE
                locked_hist-nws-option.db-num = p-db-num
            AND locked_hist-nws-option.hn-id = 0 NO-ERROR .
    END.
  END.
END.
IF p-mode = 'ПРОСМОТР':U THEN DO:
    FIND FIRST locked_hist-nws-option no-LOCK WHERE
            locked_hist-nws-option.db-num = p-db-num
        AND locked_hist-nws-option.hn-id = 0 NO-ERROR.
   IF NOT AVAILABLE locked_hist-nws-option THEN DO:
      CREATE locked_hist-nws-option.
      ASSIGN
      locked_hist-nws-option.db-num = p-db-num
      locked_hist-nws-option.hn-id = 0
      .
   END.
END.
  RUN fill-table IN THIS-PROCEDURE ( INPUT '':U).
  RUN Myenable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY CB-subject-group last-modify
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit CB-subject-group b-copyrdb b-hist B-Help last-modify
         BR-option
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-option FOR EACH tt-hist-nws-option WHERE          (v-subject-group = '':U           AND tt-hist-nws-option.table-name = '':U)          OR (tt-hist-nws-option.subject-group = v-subject-group              AND tt-hist-nws-option.table-name > '':U).
END PROCEDURE.
PROCEDURE fill-table :
DEFINE INPUT PARAMETER p-subject-group AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE BUFFER buf_hist-nws-option FOR ub.hist-nws-option.
run waitfram-show in this-procedure ( "Ждите ... ").
FOR EACH buf_hist-nws-option NO-LOCK WHERE
       buf_hist-nws-option.db-num = p-db-num
   and buf_hist-nws-option.hn-id > 0
   :
  if buf_hist-nws-option.charkey_one <> '':U
  or buf_hist-nws-option.charkey_two <> '':U
  or buf_hist-nws-option.charkey_three <> '':U
  or buf_hist-nws-option.key#_one <> 0
  or buf_hist-nws-option.key#_two <> 0
  or buf_hist-nws-option.key#_three <> 0
  or buf_hist-nws-option.host-code <> 0
  or buf_hist-nws-option.obj-type <> '':U
  or buf_hist-nws-option.obj-code <> 0 then next.
  CREATE tt-hist-nws-option.
  buffer-copy buf_hist-nws-option to tt-hist-nws-option.
  ASSIGN
  tt-hist-nws-option.hist-to-nws-is-on = (tt-hist-nws-option.hist-to-nws >= 0)
  tt-hist-nws-option.nws-to-hist-is-on = (tt-hist-nws-option.nws-to-hist >= 0)
  tt-hist-nws-option.get-hist-from-nws-is-on = (tt-hist-nws-option.get-hist-from-nws >= 0)
  tt-hist-nws-option.hist-to-nws-can = NOT ((tt-hist-nws-option.hist-to-nws = INTEGER('10':U)) OR
                                            (tt-hist-nws-option.hist-to-nws = INTEGER('-10':U)))
  tt-hist-nws-option.nws-to-hist-can = NOT ((tt-hist-nws-option.nws-to-hist = INTEGER('10':U)) OR
                                            (tt-hist-nws-option.nws-to-hist = INTEGER('-10':U)))
  tt-hist-nws-option.get-hist-from-nws-can = NOT ((tt-hist-nws-option.get-hist-from-nws = INTEGER('10':U)) OR
                                                  (tt-hist-nws-option.get-hist-from-nws = INTEGER('-10':U)))
  .
  IF LOOKUP(buf_hist-nws-option.subject-group, v-groups) = 0  THEN DO:
    ASSIGN
    v-groups = v-groups + chr(44) +
                buf_hist-nws-option.subject-group
    v-groups = TRIM(v-groups, chr(44))
    .
  END.
END.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
DEFINE VARIABLE v-h AS WIDGET-HANDLE NO-UNDO.
ASSIGN
cb-subject-group:LIST-ITEMS IN FRAME Dialog-Frame = '':U + chr(44) + v-groups.
DO v-ii = 1 TO BROWSE br-option:NUM-COLUMNS:
   v-h = BROWSE br-option:GET-BROWSE-COLUMN(v-ii).
   IF v-h:LABEL = "Пересылка ист.!в другие БД" THEN DO:
       ASSIGN
       v-col[1] = v-h
       .
   END.
   IF v-h:LABEL = "Создание ист.!при приеме!по СПН" THEN DO:
       ASSIGN
       v-col[2] = v-h
       .
   END.
   IF v-h:LABEL = "Прием истории!из другой!УБД" THEN DO:
       ASSIGN
       v-col[3] = v-h
       .
   END.
   IF v-h:LABEL = "Группа данных" THEN DO:
       ASSIGN
       v-col-tbl-name = v-h
       .
   END.
END.
DISPLAY
locked_hist-nws-option.option-descr @ last-modify
WITH FRAME Dialog-Frame.
ENABLE
B-exit
b-quit
B-Help
b-copyrdb WHEN (p-mode = 'ИЗМЕНЕНИЕ':U AND (g#db-num = p-db-num OR g#db-num = 0 ))
b-hist
BR-option
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
IF p-mode = 'ПРОСМОТР':U THEN DO:
   HIDE
   b-exit IN FRAME Dialog-Frame.
   ASSIGN
   b-quit:LABEL = "&Выход"
   b-quit:COLUMN = 1
   FRAME Dialog-Frame:TITLE = substitute("&1 &2", FRAME Dialog-Frame:TITLE, p-db-num)
   tt-hist-nws-option.hist-to-nws-is-on:READ-ONLY in browse br-option = YES
   tt-hist-nws-option.nws-to-hist-is-on :READ-ONLY in browse br-option = YES
   tt-hist-nws-option.get-hist-from-nws-is-on:READ-ONLY in browse br-option = YES
   .
END.
APPLY "Value-changed" TO cb-subject-group.
END PROCEDURE.
PROCEDURE OpenBr :
IF v-subject-group = '':U THEN DO:
    OPEN QUERY br-option
    FOR EACH tt-hist-nws-option WHERE
            tt-hist-nws-option.db-num = p-db-num
        and tt-hist-nws-option.hn-id > 0
        and tt-hist-nws-option.table-name = '':U.
END.
ELSE DO:
    OPEN QUERY br-oprion
    FOR EACH tt-hist-nws-option WHERE
            tt-hist-nws-option.db-num = p-db-num
        and tt-hist-nws-option.hn-id > 0
        and  (tt-hist-nws-option.subject-group = v-subject-group
                 AND tt-hist-nws-option.table-name > '':U).
END.
END PROCEDURE.
PROCEDURE proc-copy-udb :
DEFINE PARAMETER BUFFER buf_tt-hist-nws-option FOR tt-hist-nws-option.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE glog as LOGICAL no-undo .
DEFINE VARIABLE v-attr-value as character no-undo .
DEFINE BUFFER buf_db FOR ub.db.
DEFINE BUFFER bufo_tt-hist-nws-option for TT-hist-nws-option.
IF g#db-num > 0 THEN DO:
  UNDO, RETURN ERROR.
END.
MESSAGE
SUBSTITUTE("Вы действительно хотите скопировать&1" +
           "настройки записи истории и маршрутизации &2 на все УБД?&1" +
           "Измения будут сохранены в момент сохранения изменений для опций БД &3&1" +
           "(Нажатие клавиши ВВОД"
           , chr(10)
           , buf_tt-hist-nws-option.option-descr
           , p-db-num)
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN DO:
    UNDO, RETURN NO-APPLY.
END.
do TRANSACTION
ON ERROR UNDO, RETURN ERROR:
    FOR EACH buf_db NO-LOCK WHERE
            buf_db.db-num > 0
    ON error undo, return error :
      FIND FIRST bufo_tt-hist-nws-option WHERE
                bufo_tt-hist-nws-option.db-num = buf_db.db-num
           AND  bufo_tt-hist-nws-option.hn-id = buf_tt-hist-nws-option.hn-id NO-ERROR.
      IF NOT AVAILABLE bufo_tt-hist-nws-option THEN DO:
         CREATE bufo_tt-hist-nws-option.
         BUFFER-COPY buf_tt-hist-nws-option
         except db-num
         TO bufo_tt-hist-nws-option
         assign
         bufo_tt-hist-nws-option.db-num = buf_db.db-num
         .
      END.
      else do:
        BUFFER-COPY buf_tt-hist-nws-option
        except db-num
        TO bufo_tt-hist-nws-option
        .
      end.
    END.
END.
run openbr in this-procedure .
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE BUFFER buf_hist-nws-option FOR ub.hist-nws-option.
DEFINE BUFFER buf_tt-hist-nws-option FOR tt-hist-nws-option.
DEFINE BUFFER main_tt-hist-nws-option FOR tt-hist-nws-option.
DEFINE BUFFER subject_hist-nws-option FOR tt-hist-nws-option.
DEFINE BUFFER last_hist-nws-option FOR ub.hist-nws-option.
define buffer main_hist-nws-option for ub.hist-nws-option.
if g#db-num = p-db-num then do:
  message
  "Сделанные Вами изменения вступят в силу для всех пользователей не позже, чем через полчаса" skip
  "(или сразу же после перезагрузки IBS TH)"
  view-as alert-box .
end.
_hist-nws-option:
FOR EACH buf_tt-hist-nws-option
ON error UNDO, RETURN ERROR return-value
ON STOP UNDO, RETURN ERROR return-value :
  if buf_tt-hist-nws-option.hn-id = 0 then next _hist-nws-option.
  FIND FIRST buf_hist-nws-option WHERE
            buf_hist-nws-option.db-num = buf_tt-hist-nws-option.db-num
        and buf_hist-nws-option.hn-id = buf_tt-hist-nws-option.hn-id NO-ERROR.
  IF NOT AVAILABLE buf_hist-nws-option THEN DO:
    next _hist-nws-option.
  END.
  if buf_tt-hist-nws-option.db-num <> p-db-num then do:
    find first main_tt-hist-nws-option where
              main_tt-hist-nws-option.db-num = buf_tt-hist-nws-option.db-num
         and  main_tt-hist-nws-option.hn-id = 0 no-error.
    if not available main_tt-hist-nws-option then do:
      create main_tt-hist-nws-option.
      assign
      main_tt-hist-nws-option.db-num = buf_tt-hist-nws-option.db-num
      main_tt-hist-nws-option.hn-id  = 0
      .
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    assign
    main_tt-hist-nws-option.option-descr = substitute("&1 &2", string(v-today, "99/99/9999"), string(v-time, "HH:MM:SS")).
  end.
  IF v-subject-group = '':U THEN DO:
    FIND FIRST subject_hist-nws-option WHERE
              subject_hist-nws-option.db-num = buf_tt-hist-nws-option.db-num
        AND  subject_hist-nws-option.subject-group = buf_tt-hist-nws-option.subject-group
        AND  subject_hist-nws-option.table-name = '':U NO-ERROR.
    IF AVAILABLE subject_hist-nws-option THEN DO:
      assign
      buf_hist-nws-option.hist-to-nws = (IF buf_tt-hist-nws-option.hist-to-nws-can
                                        THEN (IF subject_hist-nws-option.hist-to-nws-is-on
                                              THEN INTEGER('0':U)
                                              ELSE INTEGER('-1':U)
                                              )
                                        ELSE buf_hist-nws-option.hist-to-nws)
      buf_hist-nws-option.nws-to-hist = (IF buf_tt-hist-nws-option.nws-to-hist-can
                                          THEN (IF subject_hist-nws-option.nws-to-hist-is-on
                                                  THEN INTEGER('0':U)
                                                  ELSE INTEGER('-1':U)
                                                  )
                                          ELSE buf_hist-nws-option.nws-to-hist)
      buf_hist-nws-option.get-hist-from-nws = (IF buf_tt-hist-nws-option.get-hist-from-nws-can
                                          THEN (IF subject_hist-nws-option.get-hist-from-nws-is-on
                                                  THEN INTEGER('0':U)
                                                  ELSE INTEGER('-1':U)
                                                  )
                                          ELSE buf_hist-nws-option.get-hist-from-nws)
      .
    END.
  END.
  ELSE DO:
    assign
    buf_hist-nws-option.hist-to-nws = (IF buf_tt-hist-nws-option.hist-to-nws-can
                                        THEN (IF buf_tt-hist-nws-option.hist-to-nws-is-on
                                              THEN INTEGER('0':U)
                                              ELSE INTEGER('-1':U)
                                            )
                                        ELSE buf_hist-nws-option.hist-to-nws)
    buf_hist-nws-option.nws-to-hist = (IF buf_tt-hist-nws-option.nws-to-hist-can
                                        THEN (IF buf_tt-hist-nws-option.nws-to-hist-is-on
                                                  THEN INTEGER('0':U)
                                                  ELSE INTEGER('-1':U)
                                                )
                                        ELSE buf_hist-nws-option.nws-to-hist)
    buf_hist-nws-option.get-hist-from-nws = (IF buf_tt-hist-nws-option.get-hist-from-nws-can
                                        THEN (IF buf_tt-hist-nws-option.get-hist-from-nws-is-on
                                                  THEN INTEGER('0':U)
                                                  ELSE INTEGER('-1':U)
                                                )
                                        ELSE buf_hist-nws-option.get-hist-from-nws)
    .
  END.
END.
run cur-time in this-procedure ( output v-today, output v-time).
ASSIGN
locked_hist-nws-option.option-descr = STRING(v-today, "99/99/9999") + chr(32) + STRING(v-time, "HH:MM:SS")
.
_main-hist-nws-option:
FOR EACH main_tt-hist-nws-option
ON error UNDO, RETURN ERROR return-value
ON STOP UNDO, RETURN ERROR return-value :
  if main_tt-hist-nws-option.hn-id <> 0
  or main_tt-hist-nws-option.db-num = p-db-num
  then next _main-hist-nws-option.
  FIND FIRST buf_hist-nws-option WHERE
            buf_hist-nws-option.db-num = main_tt-hist-nws-option.db-num
        and buf_hist-nws-option.hn-id = main_tt-hist-nws-option.hn-id NO-ERROR.
  IF NOT AVAILABLE buf_hist-nws-option THEN DO:
    next _main-hist-nws-option.
  END.
  buffer-copy main_tt-hist-nws-option to buf_hist-nws-option.
end.
run gbl/clearlib.p .
END PROCEDURE.
PROCEDURE Switch-subject :
IF cb-subject-group = '':U THEN DO:
    ASSIGN
    v-col[1]:VISIBLE = NO
    tt-hist-nws-option.hist-to-nws-is-on:LABEL IN BROWSE br-option = "Пересылка ист.!в другие БД"
    tt-hist-nws-option.hist-to-nws-is-on:width IN BROWSE br-option = 15
    v-col[2]:VISIBLE = NO
    tt-hist-nws-option.nws-to-hist-is-on:LABEL IN BROWSE br-option = "Создание ист.!при приеме!по СПН"
    tt-hist-nws-option.nws-to-hist-is-on:width IN BROWSE br-option = 15
    v-col[3]:VISIBLE = NO
    tt-hist-nws-option.get-hist-from-nws-is-on:LABEL IN BROWSE br-option = "Прием истории!из другой!УБД"
    tt-hist-nws-option.get-hist-from-nws-is-on:width IN BROWSE br-option = 15
    v-col-tbl-name:VISIBLE  = NO
    tt-hist-nws-option.option-descr:LABEL  = "Группа данных"
    .
  END.
  ELSE DO:
     ASSIGN
     v-col[1]:VISIBLE = YES
     tt-hist-nws-option.hist-to-nws-is-on:LABEL IN BROWSE br-option = "Вкл!Выкл"
     tt-hist-nws-option.hist-to-nws-is-on:width IN BROWSE br-option = 4
     v-col[2]:VISIBLE = YES
     tt-hist-nws-option.nws-to-hist-is-on:LABEL IN BROWSE br-option = "Вкл!Выкл"
     tt-hist-nws-option.nws-to-hist-is-on:width IN BROWSE br-option = 4
     v-col[3]:VISIBLE = YES
     tt-hist-nws-option.get-hist-from-nws-is-on:LABEL IN BROWSE br-option = "Вкл!Выкл"
     tt-hist-nws-option.get-hist-from-nws-is-on:width IN BROWSE br-option = 4
     v-col-tbl-name:VISIBLE  = YES
     tt-hist-nws-option.option-descr:label  = "Сущность"
     .
  END.
END PROCEDURE.
FUNCTION get-hn-group-label RETURNS CHARACTER
  ( INPUT p-subject-group AS CHARACTER ) :
RETURN p-subject-group.
END FUNCTION.
FUNCTION get-hn-label RETURNS CHARACTER
  ( INPUT p-hn-option AS integer ) :
  RETURN entry (lookup (string(p-hn-option), '0,-1,1,10,-10':U) + 1, ',' + 'Да,Нет,Смарт2,Всегда,Никогда':U).
END FUNCTION.
