DEFINE BUFFER locked_c-fin-statement FOR ub.c-fin-statement.
DEFINE BUFFER locked_c-fin-statement-line FOR ub.c-fin-statement-line.
DEFINE TEMP-TABLE tt-c-fin-statement NO-UNDO LIKE ub.c-fin-statement.
DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt0-c-fin-statement-attr NO-UNDO LIKE ub.c-fin-statement-attr.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_curr_sysconf FOR ub.sysconf.
DEFINE BUFFER X_fin-bank FOR ub.fin-bank.
DEFINE BUFFER X_fin-schet FOR ub.fin-schet.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-curr-host-code LIKE ub.c-fin-statement.host-code NO-UNDO.
DEFINE INPUT PARAMETER p-mode           AS character NO-UNDO.
DEFINE INPUT PARAMETER p-host-code LIKE ub.c-fin-statement.host-code NO-UNDO.
DEFINE INPUT PARAMETER p-sttm-code LIKE ub.c-fin-statement.sttm-code NO-UNDO.
DEFINE INPUT PARAMETER p-fins-ext-doc-type LIKE ub.c-fin-statement.fins-ext-doc-type NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.
define input-output parameter p-line-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр истории банковский выписки".
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
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
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
DEFINE VARIABLE v-cli-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-mark AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-base-code LIKE ub.sysconf.base-code NO-UNDO.
DEFINE VARIABLE lock-doc as logical no-undo.
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-first AS LOGICAL NO-UNDO init yes.
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-limit-access as integer no-undo .
FUNCTION get-cli-name RETURNS CHARACTER
  (BUFFER buf_c-fin-statement-line FOR ub.c-fin-statement-line )  FORWARD.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-bank AS CHARACTER FORMAT "X(256)":U INITIAL "Счет"
      VIEW-AS TEXT
     SIZE 4.4 BY .77
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-bank-data AS CHARACTER FORMAT "X(256)":U INITIAL "Данные банка"
      VIEW-AS TEXT
     SIZE 12.5 BY .77
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE F-curr-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-th-data AS CHARACTER FORMAT "X(256)":U INITIAL "Док-ты TH"
      VIEW-AS TEXT
     SIZE 11 BY .77
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BR-lines FOR
      locked_c-fin-statement-line SCROLLING.
DEFINE BROWSE BR-lines
  QUERY BR-lines NO-LOCK DISPLAY
      mark-string(recid(locked_c-fin-statement-line), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U WIDTH 1
locked_c-fin-statement-line.line-num COLUMN-LABEL "Строка" FORMAT ">,>>9":U
locked_c-fin-statement-line.prn-doc-code FORMAT "X(16)":U
locked_c-fin-statement-line.fin-doc-code COLUMN-LABEL "Внутр.№" FORMAT "999999999":U
locked_c-fin-statement-line.fin-ext-doc-type COLUMN-LABEL "Тип" FORMAT "X(8)":U
    WIDTH 8
locked_c-fin-statement-line.sum-doc FORMAT ">,>>>,>>>,>>>,>>9.99":U
get-cli-name(BUFFER locked_c-fin-statement-line) @ v-cli-name COLUMN-LABEL "Контрагент" FORMAT "X(20)":U WIDTH 21
ENABLE
locked_c-fin-statement-line.prn-doc-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.77 EXPANDABLE.
DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 29
     B-lookup AT ROW 1 COL 49
     B-Help AT ROW 1 COL 89
     tt-c-fin-statement.prn-doc-code AT ROW 2 COL 1
          LABEL "№" FORMAT "X(22)"
          VIEW-AS FILL-IN
          SIZE 25.5 BY 1
          FGCOLOR 4
     tt-c-fin-statement.num-docs AT ROW 2 COL 67 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-c-fin-statement.num-docs-th AT ROW 2 COL 88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-c-fin-statement.sttm-code AT ROW 3 COL 8 COLON-ALIGNED
          LABEL "Внутр.№" FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 10.4 BY 1
     tt-c-fin-statement.doc-date AT ROW 3 COL 21.5
          LABEL "Дата сост." FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-c-fin-statement.start-sum-doc AT ROW 3 COL 54.5 COLON-ALIGNED
          LABEL "Вход.ост." FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-c-fin-statement.start-sum-doc-th AT ROW 3 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     tt-c-fin-statement.bank-date AT ROW 4 COL 31.5 COLON-ALIGNED
          LABEL "Дата банк" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-fin-statement.in-sum-doc AT ROW 4 COL 54.5 COLON-ALIGNED
          LABEL "Приход" FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-c-fin-statement.in-sum-doc-th AT ROW 4 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     tt-c-fin-statement.fact-date AT ROW 5 COL 31.5 COLON-ALIGNED
          LABEL "Дата факт" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-c-fin-statement.out-sum-doc AT ROW 5 COL 54.5 COLON-ALIGNED
          LABEL "Расход" FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-c-fin-statement.out-sum-doc-th AT ROW 5 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     tt-c-fin-statement.start-date AT ROW 6 COL 15 COLON-ALIGNED
          LABEL "С" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-fin-statement.end-date AT ROW 6 COL 31.5 COLON-ALIGNED
          LABEL "по" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-fin-statement.end-sum-doc AT ROW 6 COL 54.5 COLON-ALIGNED
          LABEL "Исход.ост." FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-c-fin-statement.end-sum-doc-th AT ROW 6 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     BR-lines AT ROW 8 COL 1
     tt-c-fin-statement.PS AT ROW 20 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 2 TOOLTIP "Дополнительная информация"
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON B-quit.
DEFINE FRAME Dialog-Frame
     mark-num AT ROW 1 COL 30.5 COLON-ALIGNED NO-LABEL
     f-bank-data AT ROW 2 COL 56.5 NO-LABEL
     f-th-data AT ROW 2 COL 78 NO-LABEL
     tt-c-fin-statement.curr-code AT ROW 5 COL 1
          LABEL "Вал" FORMAT ">>9"
           VIEW-AS TEXT
          SIZE 4 BY .67
     F-curr-abbr AT ROW 5 COL 6 COLON-ALIGNED NO-LABEL
     f-bank AT ROW 7 COL 1 NO-LABEL
     tt-c-fin-statement.r-schet AT ROW 7 COL 8 COLON-ALIGNED NO-LABEL FORMAT "X(20)"
           VIEW-AS TEXT
          SIZE 21 BY .67
          FGCOLOR 4
     tt-c-fin-statement.bank-name AT ROW 7 COL 30 COLON-ALIGNED NO-LABEL FORMAT "X(100)"
           VIEW-AS TEXT
          SIZE 50 BY .67
     tt-c-fin-statement.bik AT ROW 7 COL 87 COLON-ALIGNED
          LABEL "БИК" FORMAT "X(9)"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     SPACE(0.24) SKIP(14.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выписка №"
         CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
define buffer buf_fin-doc for ub.fin-doc.
  IF NOT AVAILABLE LOCKED_c-fin-statement-line THEN RETURN NO-APPLY.
  IF locked_c-fin-statement-line.fin-doc-code = 0 THEN DO:
      MESSAGE
      "К данной строке платеж в системе не привязан!" SKIP
      "Просмотр невозможен!"
      VIEW-AS ALERT-BOX.
  END.
  find first buf_fin-doc no-lock where
            buf_fin-doc.host-code = locked_c-fin-statement.host-code
       and buf_fin-doc.fin-doc-code = locked_c-fin-statement-line.fin-doc-code no-error.
  if not available buf_Fin-doc then do:
  end.
  else do:
    run ref/shwcfind.p (
                        input parParentProc
                      ,input p-curr-host-code
                      ,input locked_c-fin-statement-line.host-code
                      ,input locked_c-fin-statement-line.fin-doc-code
                      ,input locked_c-fin-statement-line.corr-user-db-num
                      ,input locked_c-fin-statement-line.chip-num).
  end.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
  if available locked_c-fin-statement then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid4 as character no-undo .
define variable v-num-entry4 as integer   no-undo .
assign
  v-str-recid4 = trim( string( recid( locked_c-fin-statement ) , "->>>>>>>>>>>9":U ) )
  v-num-entry4 = lookup( v-str-recid4 , v-rid-list )
.
if v-num-entry4 > 0 then do:
  assign
    entry( v-num-entry4, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid4
  .
end.
    loc#log = br-lines:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-lines:select-next-row ().
        apply "VALUE-CHANGED" to br-lines in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-lines in frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-lines :handle
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
def var sort-labelBR-lines   as character no-undo .
def var sort-clmnBR-lines    as handle    no-undo .
def var cur-clmnBR-lines     as handle    no-undo .
def var cur-clmn-locBR-lines as integer   no-undo .
def var re-queryBR-lines     as logical   initial no no-undo .
on start-search, ctrl-o of BR-lines in frame Dialog-Frame do:
   run sort-brBR-lines
     (input (if available locked_c-fin-statement-line
             then recid(locked_c-fin-statement-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brBR-lines :
  define input parameter p-recid as recid no-undo .
  if re-queryBR-lines = no then do:
    assign
       cur-clmnBR-lines = BR-lines:current-column in frame Dialog-Frame
    .
    if sort-clmnBR-lines <> ? then sort-clmnBR-lines:column-fgcolor = 0.
    if cur-clmnBR-lines = sort-clmnBR-lines then do:
      assign
         sort-labelBR-lines = ""
         sort-clmnBR-lines = ?
      .
     end.
     else do:
       assign
         sort-labelBR-lines = cur-clmnBR-lines:label
         sort-clmnBR-lines  = cur-clmnBR-lines
         sort-clmnBR-lines:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBR-lines = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BR-lines:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBR-lines then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBR-lines = cur-clmn-locBR-lines + 1
    .
  end.
  case sort-labelBR-lines:
        when '*'  then DO:   assign     sort-column-name = "mark-string(recid(locked_c-fin-statement-line), v-rid-list)"   .   run OpenBr in this-procedure ( yes, no, no).   . END.
        when locked_c-fin-statement-line.line-num:label in browse BR-lines then DO:   assign     sort-column-name = "locked_c-fin-statement-line.line-num"   .   run OpenBr in this-procedure ( yes, no, no).   . END.
        when locked_c-fin-statement-line.prn-doc-code:label in browse BR-lines then DO:   assign     sort-column-name = "locked_c-fin-statement-line.prn-doc-code"   .   run OpenBr in this-procedure ( yes, no, no).   . END.
        when locked_c-fin-statement-line.fin-doc-code:label in browse BR-lines then DO:   assign     sort-column-name = "locked_c-fin-statement-line.fin-doc-code"   .   run OpenBr in this-procedure ( yes, no, no).   . END.
        when 'Контрагент'  then DO:   assign     sort-column-name = "get-cli-name(buffer locked_c-fin-statement-line)"   .   run OpenBr in this-procedure ( yes, no, no).   . END.
        when locked_c-fin-statement-line.sum-doc:label in browse BR-lines then DO:   assign     sort-column-name = "locked_c-fin-statement-line.sum-doc"   .   run OpenBr in this-procedure ( yes, no, no).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( yes, no, no).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultBR-lines') then do:
          run mv-brw-defaultBR-lines.
        end.
      if sort-labelBR-lines <> "" then do:
        assign
          cur-clmnBR-lines:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBR-lines = ?
      .
    end.
  end case.
    if cur-clmn-locBR-lines <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnBR-lines') then do:
        run ch-clmnBR-lines in this-procedure (cur-clmn-locBR-lines).
      end.
    end.
  if p-recid <> ? then do:
    reposition BR-lines to recid p-recid no-error.
    apply "value-changed" to BR-lines in frame Dialog-Frame.
  end.
  apply "entry" to BR-lines in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBR-lines:
if cur-clmnBR-lines = ? then do:
   run OpenBr in this-procedure ( yes, no, no).
end.
else do:
   assign re-queryBR-lines = yes.
   run sort-brBR-lines
     (input (if available locked_c-fin-statement-line
             then recid(locked_c-fin-statement-line)
             else ?
            )
     ).
   assign re-queryBR-lines = no.
end.
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-lines :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  v-doc-rec = recid(locked_c-fin-statement-line). run OpenBr in this-procedure ( yes, no, '':U). reposition br-lines to recid v-doc-rec no-error. v-doc-rec = ?.
    apply "VALUE-CHANGED" to BR-lines.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN check-parameters IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO main-block, RETURN ERROR.
  RUN fill-tables IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO main-block, RETURN ERROR.
  RUN Myenable in this-procedure .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame Dialog-Frame .
  if p-line-rec <> ? then
  REPOSITION br-lines to recid p-line-rec No-ERROR.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-lines as INT EXTENT 7 no-undo.
DEF VAR varmvibr-lines       as INT no-undo.
DEF VAR varmvjbr-lines       as INT no-undo.
DEF VAR varmvkbr-lines       as INT no-undo.
DEF VAR varmvlbr-lines       as INT no-undo.
DEF VAR move-elementbr-lines as INT no-undo.
def var jjbr-lines           as int no-undo.
do varmvibr-lines = 1 to EXTENT(cur-clmn-numbr-lines):
  ASSIGN cur-clmn-numbr-lines[varmvibr-lines] = varmvibr-lines.
END.
RUN start-mv-clmnbr-lines.
PROCEDURE start-mv-clmnbr-lines:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  yes  THEN DO:
   DO jjbr-lines = NUM-ENTRIES('1,2,3,4,5,6,7') TO 1 BY -1:
     RUN re-move-clmnbr-lines ( cur-clmn-numbr-lines[INTEGER(ENTRY (jjbr-lines, '1,2,3,4,5,6,7'))] , 2).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-lines do:
  RUN re-move-clmnbr-lines ( 2, 7).
END.
ON ctrl-cursor-left OF BROWSE br-lines do:
  RUN re-move-clmnbr-lines (7, 2).
END.
PROCEDURE re-move-clmnbr-lines:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
    if cur-clmn-numbr-lines[varmvibr-lines] = source-column THEN cur-clmn-numbr-lines[varmvibr-lines] = -1.
  END.
  if br-lines:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-lines = source-column - 1 to target-column BY -1:
    DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
        if cur-clmn-numbr-lines[varmvibr-lines] = varmvjbr-lines THEN DO:
          cur-clmn-numbr-lines[varmvibr-lines] = cur-clmn-numbr-lines[varmvibr-lines] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-lines = source-column + 1 to target-column:
    DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
      if cur-clmn-numbr-lines[varmvibr-lines] = varmvjbr-lines THEN DO:
        cur-clmn-numbr-lines[varmvibr-lines] = cur-clmn-numbr-lines[varmvibr-lines] - 1.
      END.
    END.
  END.
  DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
    if cur-clmn-numbr-lines[varmvibr-lines] = -1 THEN cur-clmn-numbr-lines[varmvibr-lines] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-lines:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 2 then do:
    return .
  end.
  DO varmvibr-lines = 1 TO EXTENT(cur-clmn-numbr-lines):
    if cur-clmn-numbr-lines[varmvibr-lines] = cur-clmn-loc THEN move-elementbr-lines = varmvibr-lines.
  END.
  RUN re-move-clmnbr-lines (cur-clmn-loc, 2).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-lines:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-lines = 2 to EXTENT(cur-clmn-numbr-lines):
    RUN re-move-clmnbr-lines (cur-clmn-numbr-lines[varmvlbr-lines], varmvlbr-lines).
  END.
  RUN start-mv-clmnbr-lines.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-parameters :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-base-code
  )  .
find first X_curr_sysconf no-lock where
              X_curr_sysconf.host-code = p-curr-host-code.
find first X_sysconf no-lock where
            X_sysconf.host-code = p-host-code.
if p-mode <> 'ПРОСМОТР':U
then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
end.
FIND FIRST X_curr_sysconf NO-LOCK WHERE
        X_curr_sysconf.host-code = p-curr-host-code NO-ERROR.
IF NOT AVAILABLE X_curr_sysconf THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-curr-host-code"  p-curr-host-code
    view-as alert-box ERROR.
    undo, return error.
END.
find first X_clients no-lock where
        X_clients.obj-type = 'орг':U
    and X_clients.obj-code = p-curr-host-code.
FIND FIRST X_sysconf NO-LOCK WHERE
        X_sysconf.host-code = p-host-code NO-ERROR.
IF NOT AVAILABLE X_sysconf THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-host-code"  p-curr-host-code
    view-as alert-box ERROR.
    undo, return error.
END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY mark-num f-bank-data f-th-data F-curr-abbr f-bank
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-fin-statement THEN
    DISPLAY tt-c-fin-statement.prn-doc-code tt-c-fin-statement.num-docs
          tt-c-fin-statement.num-docs-th tt-c-fin-statement.sttm-code
          tt-c-fin-statement.doc-date tt-c-fin-statement.start-sum-doc
          tt-c-fin-statement.start-sum-doc-th tt-c-fin-statement.bank-date
          tt-c-fin-statement.in-sum-doc tt-c-fin-statement.in-sum-doc-th
          tt-c-fin-statement.fact-date tt-c-fin-statement.out-sum-doc
          tt-c-fin-statement.out-sum-doc-th tt-c-fin-statement.start-date
          tt-c-fin-statement.end-date tt-c-fin-statement.end-sum-doc
          tt-c-fin-statement.end-sum-doc-th tt-c-fin-statement.PS
          tt-c-fin-statement.curr-code tt-c-fin-statement.r-schet
          tt-c-fin-statement.bank-name tt-c-fin-statement.bik
      WITH FRAME Dialog-Frame.
  ENABLE B-quit B-mark B-lookup B-Help tt-c-fin-statement.prn-doc-code
         tt-c-fin-statement.num-docs tt-c-fin-statement.num-docs-th
         tt-c-fin-statement.doc-date tt-c-fin-statement.start-sum-doc
         tt-c-fin-statement.start-sum-doc-th tt-c-fin-statement.bank-date
         tt-c-fin-statement.in-sum-doc tt-c-fin-statement.in-sum-doc-th
         tt-c-fin-statement.out-sum-doc tt-c-fin-statement.out-sum-doc-th
         tt-c-fin-statement.start-date tt-c-fin-statement.end-date
         tt-c-fin-statement.end-sum-doc tt-c-fin-statement.end-sum-doc-th
         BR-lines tt-c-fin-statement.PS mark-num tt-c-fin-statement.curr-code
         tt-c-fin-statement.r-schet tt-c-fin-statement.bank-name
         tt-c-fin-statement.bik
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
for each tt-c-fin-statement:
  delete tt-c-fin-statement.
end.
for each tt0-c-fin-statement-attr:
  delete tt0-c-fin-statement-attr.
end.
find first locked_c-fin-statement no-lock where
          recid(locked_c-fin-statement) = p-doc-rec no-error .
if not available locked_c-fin-statement then do:
  find first locked_c-fin-statement no-lock where
              locked_c-fin-statement.host-code = p-host-code
          AND locked_c-fin-statement.sttm-code = p-sttm-code no-error .
end.
if not available locked_c-fin-statement then do:
  message
  vss-workfile vss-revision vss-description skip
  "Не найдена запись БАНКОВСКОЙ ВЫПИСКИР"
  view-as alert-box error .
  undo, return error.
end.
run cur-time in this-procedure ( output v-today, output v-time).
create tt-c-fin-statement.
assign
tt-c-fin-statement.host-code = p-host-code
tt-c-fin-statement.sttm-code  = next-value(s-fin-sttm, ub)
tt-c-fin-statement.curr-code = (IF AVAILABLE X_fin-schet THEN X_fin-schet.curr-code ELSE 0)
tt-c-fin-statement.code-schet = (IF AVAILABLE X_fin-schet THEN X_fin-schet.code-schet ELSE 0)
tt-c-fin-statement.code-bank = (IF AVAILABLE X_fin-bank THEN X_fin-bank.code-bank ELSE 0)
tt-c-fin-statement.c-schet  = (IF AVAILABLE X_fin-schet THEN X_fin-schet.c-schet ELSE '':u)
tt-c-fin-statement.r-schet  = (IF AVAILABLE X_fin-schet THEN X_fin-schet.r-schet ELSE '':u)
tt-c-fin-statement.bik  = (IF AVAILABLE X_fin-bank THEN X_fin-bank.bik ELSE '':u)
tt-c-fin-statement.cl-bank  = (IF AVAILABLE X_fin-bank THEN X_fin-bank.cl-bank ELSE '':u)
tt-c-fin-statement.bank-name = (IF AVAILABLE X_fin-bank THEN X_fin-bank.bank-name ELSE '':u)
tt-c-fin-statement.bank-city = (IF AVAILABLE X_fin-bank THEN X_fin-bank.bank-city ELSE '':u)
tt-c-fin-statement.cli-name  = X_CLIENTS.obj-NAME
tt-c-fin-statement.PS  = '':U
tt-c-fin-statement.prn-doc-code  = '':U
tt-c-fin-statement.num-docs  = 0
tt-c-fin-statement.fins-ext-doc-type = '':U
tt-c-fin-statement.fins-doc-type = '':U
tt-c-fin-statement.start-date  = v-today
tt-c-fin-statement.end-date  = v-TODAY
tt-c-fin-statement.doc-date      = v-today
tt-c-fin-statement.fins-doc-type  = 'стд':U
tt-c-fin-statement.fins-ext-doc-type  = 'стд':U
tt-c-fin-statement.prn-doc-code  = "":U
tt-c-fin-statement.status_       = 'новый':U
.
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN
LOCKED_c-fin-statement-line.prn-doc-code:READ-ONLY  IN BROWSE  br-lines = YES
v-cli-name:resizable IN BROWSE  br-lines  = YES
.
ASSIGN
v-tab-order = "b-quit,b-mark,b-lookup,b-help,"
.
DISPLAY
F-curr-abbr
mark-num
f-bank
f-bank-data
f-th-data
WITH FRAME Dialog-Frame.
IF AVAILABLE tt-c-fin-statement THEN
DISPLAY
tt-c-fin-statement.num-docs
tt-c-fin-statement.num-docs-th
tt-c-fin-statement.prn-doc-code
tt-c-fin-statement.sttm-code
tt-c-fin-statement.doc-date
tt-c-fin-statement.bank-date
tt-c-fin-statement.fact-date
tt-c-fin-statement.curr-code
tt-c-fin-statement.start-date
tt-c-fin-statement.end-date
tt-c-fin-statement.start-sum-doc tt-c-fin-statement.start-sum-doc-th
tt-c-fin-statement.in-sum-doc tt-c-fin-statement.in-sum-doc-th
tt-c-fin-statement.out-sum-doc tt-c-fin-statement.out-sum-doc-th
tt-c-fin-statement.end-sum-doc tt-c-fin-statement.end-sum-doc-th
tt-c-fin-statement.r-schet
tt-c-fin-statement.bank-name
tt-c-fin-statement.bik
tt-c-fin-statement.PS
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark WHEN NOT (p-mode = 'ПРОСМОТР':U AND p-line-rec = ?)
B-lookup
B-Help
BR-lines
mark-num
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
assign
frame Dialog-Frame:title = substitute("&1 Срез &2", frame Dialog-Frame:title, tt-c-fin-statement.chip-num).
APPLY "Value-changed" TO tt-c-fin-statement.curr-code.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
OPEN QUERY br-lines FOR EACH locked_c-fin-statement-line NO-LOCK where
    locked_c-fin-statement-line.host-code = tt-c-fin-statement.host-code
 AND locked_c-fin-statement-line.sttm-code = tt-c-fin-statement.sttm-code INDEXED-REPOSITION.
END PROCEDURE.
FUNCTION get-cli-name RETURNS CHARACTER
  (BUFFER buf_c-fin-statement-line FOR ub.c-fin-statement-line ) :
DEFINE BUFFER buf_fin-doc FOR ub.fin-doc.
IF buf_c-fin-statement-line.fin-doc-code = 0  THEN DO:
    RETURN '':U.
END.
FIND FIRST buf_fin-doc NO-LOCK WHERE
          buf_fin-doc.host-code = buf_c-fin-statement-line.host-code
     AND  buf_fin-doc.fin-doc-code = buf_c-fin-statement-line.fin-doc-code NO-ERROR.
IF NOT AVAILABLE buf_fin-doc THEN DO:
    RETURN "!!!Не найден платеж".
END.
CASE buf_fin-doc.fin-ext-doc-type:
    WHEN 'ппп':U THEN DO:
        RETURN buf_fin-doc.payer-name.
    END.
    WHEN 'рпп':U THEN DO:
       RETURN buf_fin-doc.receiver-name.
    END.
END CASE.
  RETURN "".
END FUNCTION.
