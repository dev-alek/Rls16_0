DEFINE BUFFER locked_fin-statement FOR ub.fin-statement.
DEFINE BUFFER locked_fin-statement-line FOR ub.fin-statement-line.
DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt-fin-statement NO-UNDO LIKE ub.fin-statement.
DEFINE TEMP-TABLE tt0-fin-statement-attr NO-UNDO LIKE ub.fin-statement-attr.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_curr_sysconf FOR ub.sysconf.
DEFINE BUFFER X_fin-bank FOR ub.fin-bank.
DEFINE BUFFER X_fin-schet FOR ub.fin-schet.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-curr-host-code LIKE ub.fin-statement.host-code NO-UNDO.
DEFINE INPUT PARAMETER p-mode           AS character NO-UNDO.
DEFINE INPUT PARAMETER p-host-code LIKE ub.fin-statement.host-code NO-UNDO.
DEFINE INPUT PARAMETER p-sttm-code LIKE ub.fin-statement.sttm-code NO-UNDO.
DEFINE INPUT PARAMETER p-fins-ext-doc-type LIKE ub.fin-statement.fins-ext-doc-type NO-UNDO.
DEFINE INPUT PARAMETER p-code-bank  LIKE ub.fin-statement.code-bank NO-UNDO.
DEFINE INPUT PARAMETER p-code-schet LIKE ub.fin-statement.code-schet NO-UNDO.
DEFINE INPUT PARAMETER p-other           AS character NO-UNDO.
define input-output parameter p-doc-rec as recid no-undo.
define input-output parameter p-line-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование и просмотр банковский выписки".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  (BUFFER buf_fin-statement-line FOR ub.fin-statement-line )  FORWARD.
DEFINE MENU MENU-B-add
       MENU-ITEM m_no-th        LABEL "Неучтенный в TH платеж"
       MENU-ITEM m_income       LABEL "Приход"
       MENU-ITEM m_expense      LABEL "Расход"        .
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "&История"
     SIZE 10 BY 1.
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-schet
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE VARIABLE e-line-ps AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 49 BY 4 NO-UNDO.
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
      locked_fin-statement-line SCROLLING.
DEFINE BROWSE BR-lines
  QUERY BR-lines NO-LOCK DISPLAY
      mark-string(recid(locked_fin-statement-line), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U WIDTH 1
locked_fin-statement-line.line-num COLUMN-LABEL "Строка" FORMAT ">,>>9":U
locked_fin-statement-line.prn-doc-code FORMAT "X(16)":U
locked_fin-statement-line.fin-doc-code COLUMN-LABEL "Внутр.№" FORMAT "999999999":U
locked_fin-statement-line.fin-ext-doc-type COLUMN-LABEL "Тип" FORMAT "X(8)":U
    WIDTH 8
locked_fin-statement-line.sum-doc FORMAT ">,>>>,>>>,>>>,>>9.99":U
get-cli-name(BUFFER locked_fin-statement-line) @ v-cli-name COLUMN-LABEL "Контрагент" FORMAT "X(20)":U WIDTH 21
ENABLE
locked_fin-statement-line.prn-doc-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.27 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-mark AT ROW 1 COL 29
     B-add AT ROW 1 COL 39
     B-lookup AT ROW 1 COL 49
     B-del AT ROW 1 COL 59
     B-print AT ROW 1 COL 69
     B-hist AT ROW 1 COL 79
     B-Help AT ROW 1 COL 89
     tt-fin-statement.prn-doc-code AT ROW 2 COL 1
          LABEL "№" FORMAT "X(22)"
          VIEW-AS FILL-IN
          SIZE 25.5 BY 1
          FGCOLOR 4
     tt-fin-statement.num-docs AT ROW 2 COL 67 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-fin-statement.num-docs-th AT ROW 2 COL 88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     tt-fin-statement.sttm-code AT ROW 3 COL 8 COLON-ALIGNED
          LABEL "Внутр.№" FORMAT "999999999"
          VIEW-AS FILL-IN
          SIZE 10.4 BY 1
     tt-fin-statement.doc-date AT ROW 3 COL 21.5
          LABEL "Дата сост." FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-statement.start-sum-doc AT ROW 3 COL 54.5 COLON-ALIGNED
          LABEL "Вход.ост." FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-fin-statement.start-sum-doc-th AT ROW 3 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     tt-fin-statement.bank-date AT ROW 4 COL 31.5 COLON-ALIGNED
          LABEL "Дата банк" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-fin-statement.in-sum-doc AT ROW 4 COL 54.5 COLON-ALIGNED
          LABEL "Приход" FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-fin-statement.in-sum-doc-th AT ROW 4 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     tt-fin-statement.fact-date AT ROW 5 COL 31.5 COLON-ALIGNED
          LABEL "Дата факт" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-statement.out-sum-doc AT ROW 5 COL 54.5 COLON-ALIGNED
          LABEL "Расход" FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-fin-statement.out-sum-doc-th AT ROW 5 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     tt-fin-statement.start-date AT ROW 6 COL 15 COLON-ALIGNED
          LABEL "С" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-statement.end-date AT ROW 6 COL 31.5 COLON-ALIGNED
          LABEL "по" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-statement.end-sum-doc AT ROW 6 COL 54.5 COLON-ALIGNED
          LABEL "Исход.ост." FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 9
     tt-fin-statement.end-sum-doc-th AT ROW 6 COL 76 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          FGCOLOR 4
     B-schet AT ROW 7 COL 6
     BR-lines AT ROW 9 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
DEFINE FRAME Dialog-Frame
     e-line-ps AT ROW 18 COL 1 NO-LABEL
     tt-fin-statement.PS AT ROW 18 COL 50 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 49 BY 4 TOOLTIP "Дополнительная информация"
     mark-num AT ROW 1 COL 30.5 COLON-ALIGNED NO-LABEL
     f-bank-data AT ROW 2 COL 56.5 NO-LABEL
     f-th-data AT ROW 2 COL 78 NO-LABEL
     tt-fin-statement.curr-code AT ROW 5 COL 1
          LABEL "Вал" FORMAT ">>9"
           VIEW-AS TEXT
          SIZE 4 BY .67
     F-curr-abbr AT ROW 5 COL 6 COLON-ALIGNED NO-LABEL
     f-bank AT ROW 7 COL 1 NO-LABEL
     tt-fin-statement.r-schet AT ROW 7 COL 8 COLON-ALIGNED NO-LABEL FORMAT "X(20)"
           VIEW-AS TEXT
          SIZE 21 BY .67
          FGCOLOR 4
     tt-fin-statement.bank-name AT ROW 7 COL 30 COLON-ALIGNED NO-LABEL FORMAT "X(100)"
           VIEW-AS TEXT
          SIZE 50 BY .67
     tt-fin-statement.bik AT ROW 8.2 COL 8 COLON-ALIGNED
          LABEL "БИК" FORMAT "X(9)"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     tt-fin-statement.bank-city AT ROW 8.2 COL 29 COLON-ALIGNED
          LABEL "Город"
           VIEW-AS TEXT
          SIZE 25.5 BY .67
     "Примечания к выписке" VIEW-AS TEXT
          SIZE 29.5 BY .67 AT ROW 17.33 COL 50
          FGCOLOR 4 FONT 4
     "Примечания к строке выписки" VIEW-AS TEXT
          SIZE 29.5 BY .67 AT ROW 17.33 COL 1.5
          FONT 4
     SPACE(67.99) SKIP(4.02)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выписка №"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  if add-option = '':U then do:
    run gbl/pop-up.p ( input self:handle, no) no-error.
  end.
  if add-option = '':U then return no-apply.
  run proc-b-add in this-procedure ( input add-option) no-error.
  add-option = '':U.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE loc#log AS LOGICAL NO-UNDO.
  DEFINE VARIABLE v-loc-rid-list AS character NO-UNDO.
  IF NOT AVAILABLE LOCKED_fin-statement-line AND v-rid-list = '':U THEN RETURN NO-APPLY.
  CASE v-rid-list:
      WHEN '':U THEN DO:
          MESSAGE
          substitute("Вы действительно хотите удалить из выписки платеж &1 (внутр. №&2)"
                     , LOCKED_fin-statement-line.prn-doc-code
                     , LOCKED_fin-statement-line.fin-doc-code)
          VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE loc#log.
          IF NOT loc#log THEN  RETURN no-apply.
          v-loc-rid-list = string(RECID(LOCKED_fin-statement-line)).
      END.
      OTHERWISE DO:
          MESSAGE
          substitute("Вы действительно хотите удалить из выписки отмеченные платежи")
          VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE loc#log.
          IF NOT loc#log THEN  RETURN no-apply.
         v-loc-rid-list = v-rid-list.
     END.
  END CASE.
  RUN proc-b-del IN THIS-PROCEDURE( input v-loc-rid-list) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  IF p-mode = 'ПРОСМОТР':U THEN DO:
      RETURN NO-APPLY.
  END.
  RUN proc-save IN THIS-PROCEDURE ( INPUT lock-doc) no-error.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
  p-doc-rec = v-doc-rec.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE LOCKED_fin-statement-line THEN RETURN NO-APPLY.
  IF locked_fin-statement-line.fin-doc-code = 0 THEN DO:
      MESSAGE
      "К данной строке платеж в системе не привязан!" SKIP
      "Просмотр невозможен!"
      VIEW-AS ALERT-BOX.
  END.
  run ref/showfind.p
                  (INPUT  parParentProc
                   ,input p-curr-host-code
                   ,input p-host-code
                   ,input locked_fin-statement-line.fin-doc-code) NO-ERROR.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
  if available locked_fin-statement then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid5 as character no-undo .
define variable v-num-entry5 as integer   no-undo .
assign
  v-str-recid5 = trim( string( recid( locked_fin-statement ) , "->>>>>>>>>>>9":U ) )
  v-num-entry5 = lookup( v-str-recid5 , v-rid-list )
.
if v-num-entry5 > 0 then do:
  assign
    entry( v-num-entry5, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid5
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
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
define variable v-format as integer no-undo .
define variable v-cmp as character no-undo .
define variable v-log as logical no-undo .
buffer-compare tt-fin-statement to locked_fin-statement
case-sensitive
save result in v-cmp .
if v-cmp <> "":U then do:
   run proc-save in this-procedure ( input v-log) no-error.
end.
if error-status:error then return no-apply.
END.
ON CHOOSE OF B-quit IN FRAME Dialog-Frame
DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  case p-mode:
    when 'ДОБАВЛЕНИЕ':U then do:
      if available locked_fin-statement
      AND locked_fin-statement.status_ = 'новый':U THEN DO:
        RUN control-line IN THIS-PROCEDURE ( OUTPUT lock-doc).
        IF lock-doc = NO THEN DO:
            MESSAGE
            "Вы уверены, что не хотите сохранить выписку?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE gLOG.
            IF glog THEN DO:
              DELETE LOCKED_fin-statement.
              p-doc-rec = ?.
            END.
        END.
        else do:
          p-doc-rec = v-doc-rec.
        end.
      END.
    end.
  END CASE.
END.
ON CHOOSE OF B-schet IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo.
define variable ref-rec as recid no-undo.
define variable v-status_ like ub.fin-schet.status_ no-undo init 'тек':U.
define buffer buf_fin-schet for ub.fin-schet .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if available X_fin-schet then
assign
v-rid-list = string(recid(X_fin-schet))
v-status_ = X_fin-schet.status_
.
  run ref/finschts.w (
               INPUT parParentProc
              ,INPUT p-curr-host-code
              ,input "b-sel":U
              ,input "company-host":U
              ,input 'орг':U
              ,input p-host-code
              ,input ?
              ,input tt-fin-statement.host-code
              ,input 0
              ,input-output v-status_
              ,input-output v-rid-list
) no-error.
if v-rid-list = "" then   do:
  apply "entry" to b-schet in frame Dialog-Frame.
  return no-apply.
end.
 ref-rec = integer( v-rid-list ).
FIND FIRST buf_fin-schet WHERE
      recid (buf_fin-schet) = ref-rec NO-LOCK  .
if buf_fin-schet.status_ <> 'тек':U then do:
  message
  "Статус выбранного Вами счета" buf_fin-schet.status_ " - нельзя работать с таким счетом"
  view-as alert-box error .
  return no-apply.
end.
FIND FIRST X_fin-schet WHERE
      recid (X_fin-schet) = ref-rec NO-LOCK  .
find first X_fin-bank no-lock where
          X_fin-bank.host-code = tt-fin-statement.host-code
      AND X_fin-bank.code-bank = X_fin-schet.code-bank .
  assign
  tt-fin-statement.bank-name = X_fin-bank.bank-name
  tt-fin-statement.bank-city = X_fin-bank.bank-city
  tt-fin-statement.dop1      =  X_fin-schet.dop1
  tt-fin-statement.dop2      =  X_fin-schet.dop2
  tt-fin-statement.bik       =  X_fin-bank.bik
  tt-fin-statement.r-schet   =  X_fin-schet.r-schet
  tt-fin-statement.c-schet   =  X_fin-schet.c-schet
  tt-fin-statement.code-schet = X_fin-schet.code-schet
  tt-fin-statement.curr-code = X_fin-schet.curr-code
  tt-fin-statement.code-bank = X_fin-schet.code-bank
  .
  display
  tt-fin-statement.bank-name
  tt-fin-statement.bank-city
  tt-fin-statement.bik
  tt-fin-statement.r-schet
  tt-fin-statement.curr-code
  with frame Dialog-Frame.
  run control-line in this-procedure ( output lock-doc).
  run lock-proc in this-procedure ( input lock-doc).
  APPLY "Value-changed" TO tt-fin-statement.curr-code.
END.
ON VALUE-CHANGED OF BR-lines IN FRAME Dialog-Frame
DO:
  IF AVAILABLE locked_fin-statement-line THEN DO:
    ASSIGN e-line-ps:SCREEN-VALUE = locked_fin-statement-line.PS.
  END.
  ELSE DO:
    ASSIGN e-line-ps:SCREEN-VALUE = '':U.
  END.
END.
ON VALUE-CHANGED OF tt-fin-statement.curr-code IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_currency FOR ub.currency.
  FIND FIRST buf_currency NO-LOCK WHERE
            buf_currency.curr-code = tt-fin-statement.curr-code NO-ERROR.
  IF  AVAILABLE buf_currency THEN DO:
      DISPLAY
      buf_currency.curr-abbr @ f-curr-abbr
      WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
      DISPLAY
       ? @ f-curr-abbr
       WITH FRAME Dialog-Frame.
  END.
END.
ON CHOOSE OF MENU-ITEM m_expense
DO:
    assign
  add-option = 'рпп':U.
  APPLY "CHOOSE" to b-add  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_income
DO:
    assign
  add-option = 'ппп':U.
  APPLY "CHOOSE" to b-add  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_no-th
DO:
  assign
  add-option = "no-th".
  APPLY "CHOOSE" to b-add  in frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame Dialog-Frame.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
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
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
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
          return.
        end.
        else do:
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
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
def var sort-labelBR-lines   as character no-undo .
def var sort-clmnBR-lines    as handle    no-undo .
def var cur-clmnBR-lines     as handle    no-undo .
def var cur-clmn-locBR-lines as integer   no-undo .
def var re-queryBR-lines     as logical   initial no no-undo .
on start-search, ctrl-o of BR-lines in frame Dialog-Frame do:
   run sort-brBR-lines
     (input (if available locked_fin-statement-line
             then recid(locked_fin-statement-line)
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
        when '*'  then DO:   assign     sort-column-name = "mark-string(recid(locked_fin-statement-line), v-rid-list)"   .   run OpenBr in this-procedure ( yes, no, no).   . END.
        when locked_fin-statement-line.line-num:label in browse BR-lines then DO:   assign     sort-column-name = "locked_fin-statement-line.line-num"   .   run OpenBr in this-procedure ( yes, no, no).   . END.
        when locked_fin-statement-line.prn-doc-code:label in browse BR-lines then DO:   assign     sort-column-name = "locked_fin-statement-line.prn-doc-code"   .   run OpenBr in this-procedure ( yes, no, no).   . END.
        when locked_fin-statement-line.fin-doc-code:label in browse BR-lines then DO:   assign     sort-column-name = "locked_fin-statement-line.fin-doc-code"   .   run OpenBr in this-procedure ( yes, no, no).   . END.
        when 'Контрагент'  then DO:   assign     sort-column-name = "get-cli-name(buffer locked_fin-statement-line)"   .   run OpenBr in this-procedure ( yes, no, no).   . END.
        when locked_fin-statement-line.sum-doc:label in browse BR-lines then DO:   assign     sort-column-name = "locked_fin-statement-line.sum-doc"   .   run OpenBr in this-procedure ( yes, no, no).   . END.
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
     (input (if available locked_fin-statement-line
             then recid(locked_fin-statement-line)
             else ?
            )
     ).
   assign re-queryBR-lines = no.
end.
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-lines :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  v-doc-rec = recid(locked_fin-statement-line). run OpenBr in this-procedure ( yes, no, '':U). reposition br-lines to recid v-doc-rec no-error. v-doc-rec = ?.
    apply "VALUE-CHANGED" to BR-lines.
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of tt-fin-statement.doc-date in frame Dialog-Frame
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
on delete-character of tt-fin-statement.doc-date in frame Dialog-Frame
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
on ctrl-d of tt-fin-statement.doc-date in frame Dialog-Frame
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
on ctrl-b of tt-fin-statement.doc-date in frame Dialog-Frame
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
on ctrl-e of tt-fin-statement.doc-date in frame Dialog-Frame
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
on ctrl-f of tt-fin-statement.doc-date in frame Dialog-Frame
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
  define MENU m-ed-date16
    MENU-ITEM m-ed-date16-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date16-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date16-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date16-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if tt-fin-statement.doc-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      tt-fin-statement.doc-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date16 :HANDLE
      tt-fin-statement.doc-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle16 as handle no-undo .
  assign
    v-label-handle16 = tt-fin-statement.doc-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle16)
  then do:
    if v-label-handle16 :tooltip = ""
    or v-label-handle16 :tooltip = ?
    then do:
      assign
        v-label-handle16 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date16-1 in menu m-ed-date16 DO:
    apply "ctrl-b":U to tt-fin-statement.doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date16-2 in menu m-ed-date16 DO:
    apply "ctrl-d":U to tt-fin-statement.doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date16-3 in menu m-ed-date16 DO:
    apply "ctrl-e":U to tt-fin-statement.doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date16-4 in menu m-ed-date16 DO:
    apply "ctrl-f":U to tt-fin-statement.doc-date in frame Dialog-Frame .
  END.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of tt-fin-statement.bank-date in frame Dialog-Frame
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
on delete-character of tt-fin-statement.bank-date in frame Dialog-Frame
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
on ctrl-d of tt-fin-statement.bank-date in frame Dialog-Frame
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
on ctrl-b of tt-fin-statement.bank-date in frame Dialog-Frame
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
on ctrl-e of tt-fin-statement.bank-date in frame Dialog-Frame
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
on ctrl-f of tt-fin-statement.bank-date in frame Dialog-Frame
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
  define MENU m-ed-date18
    MENU-ITEM m-ed-date18-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date18-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date18-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date18-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if tt-fin-statement.bank-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      tt-fin-statement.bank-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date18 :HANDLE
      tt-fin-statement.bank-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle18 as handle no-undo .
  assign
    v-label-handle18 = tt-fin-statement.bank-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle18)
  then do:
    if v-label-handle18 :tooltip = ""
    or v-label-handle18 :tooltip = ?
    then do:
      assign
        v-label-handle18 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date18-1 in menu m-ed-date18 DO:
    apply "ctrl-b":U to tt-fin-statement.bank-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date18-2 in menu m-ed-date18 DO:
    apply "ctrl-d":U to tt-fin-statement.bank-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date18-3 in menu m-ed-date18 DO:
    apply "ctrl-e":U to tt-fin-statement.bank-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date18-4 in menu m-ed-date18 DO:
    apply "ctrl-f":U to tt-fin-statement.bank-date in frame Dialog-Frame .
  END.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of tt-fin-statement.fact-date in frame Dialog-Frame
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
on delete-character of tt-fin-statement.fact-date in frame Dialog-Frame
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
on ctrl-d of tt-fin-statement.fact-date in frame Dialog-Frame
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
on ctrl-b of tt-fin-statement.fact-date in frame Dialog-Frame
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
on ctrl-e of tt-fin-statement.fact-date in frame Dialog-Frame
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
on ctrl-f of tt-fin-statement.fact-date in frame Dialog-Frame
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
  define MENU m-ed-date20
    MENU-ITEM m-ed-date20-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date20-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date20-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date20-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if tt-fin-statement.fact-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      tt-fin-statement.fact-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date20 :HANDLE
      tt-fin-statement.fact-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle20 as handle no-undo .
  assign
    v-label-handle20 = tt-fin-statement.fact-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle20)
  then do:
    if v-label-handle20 :tooltip = ""
    or v-label-handle20 :tooltip = ?
    then do:
      assign
        v-label-handle20 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date20-1 in menu m-ed-date20 DO:
    apply "ctrl-b":U to tt-fin-statement.fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date20-2 in menu m-ed-date20 DO:
    apply "ctrl-d":U to tt-fin-statement.fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date20-3 in menu m-ed-date20 DO:
    apply "ctrl-e":U to tt-fin-statement.fact-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date20-4 in menu m-ed-date20 DO:
    apply "ctrl-f":U to tt-fin-statement.fact-date in frame Dialog-Frame .
  END.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of tt-fin-statement.start-date in frame Dialog-Frame
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
on delete-character of tt-fin-statement.start-date in frame Dialog-Frame
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
on ctrl-d of tt-fin-statement.start-date in frame Dialog-Frame
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
on ctrl-b of tt-fin-statement.start-date in frame Dialog-Frame
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
on ctrl-e of tt-fin-statement.start-date in frame Dialog-Frame
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
on ctrl-f of tt-fin-statement.start-date in frame Dialog-Frame
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
  if tt-fin-statement.start-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      tt-fin-statement.start-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date22 :HANDLE
      tt-fin-statement.start-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle22 as handle no-undo .
  assign
    v-label-handle22 = tt-fin-statement.start-date :side-label-handle in frame Dialog-Frame
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
    apply "ctrl-b":U to tt-fin-statement.start-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date22-2 in menu m-ed-date22 DO:
    apply "ctrl-d":U to tt-fin-statement.start-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date22-3 in menu m-ed-date22 DO:
    apply "ctrl-e":U to tt-fin-statement.start-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date22-4 in menu m-ed-date22 DO:
    apply "ctrl-f":U to tt-fin-statement.start-date in frame Dialog-Frame .
  END.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of tt-fin-statement.end-date in frame Dialog-Frame
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
on delete-character of tt-fin-statement.end-date in frame Dialog-Frame
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
on ctrl-d of tt-fin-statement.end-date in frame Dialog-Frame
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
on ctrl-b of tt-fin-statement.end-date in frame Dialog-Frame
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
on ctrl-e of tt-fin-statement.end-date in frame Dialog-Frame
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
on ctrl-f of tt-fin-statement.end-date in frame Dialog-Frame
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
  if tt-fin-statement.end-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      tt-fin-statement.end-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date24 :HANDLE
      tt-fin-statement.end-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle24 as handle no-undo .
  assign
    v-label-handle24 = tt-fin-statement.end-date :side-label-handle in frame Dialog-Frame
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
    apply "ctrl-b":U to tt-fin-statement.end-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-2 in menu m-ed-date24 DO:
    apply "ctrl-d":U to tt-fin-statement.end-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-3 in menu m-ed-date24 DO:
    apply "ctrl-e":U to tt-fin-statement.end-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-4 in menu m-ed-date24 DO:
    apply "ctrl-f":U to tt-fin-statement.end-date in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN check-parameters IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO main-block, RETURN ERROR.
  RUN fill-tables IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO main-block, RETURN ERROR.
  RUN Myenable in this-procedure .
  run control-line in this-procedure ( output lock-doc).
  run lock-proc in this-procedure ( input lock-doc).
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  APPLY "Value-changed" TO br-lines.
  HIDE mark-num in frame Dialog-Frame .
  if p-line-rec <> ? then
  REPOSITION br-lines to recid p-line-rec No-ERROR.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-base-code
  )  .
find first X_curr_sysconf no-lock where
              X_curr_sysconf.host-code = p-curr-host-code.
find first X_sysconf no-lock where
            X_sysconf.host-code = p-host-code.
if p-mode  <> 'ДОБАВЛЕНИЕ':U
and p-mode <> 'ИЗМЕНЕНИЕ':U
and p-mode <> 'ПРОСМОТР':U
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
if p-mode <> 'ПРОСМОТР':U then do:
if p-curr-host-code <> p-host-code
or (v-db-num <> X_sysconf.firm-db-num)
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметров вызова p-mode и/или p-host-code и/или p-curr-host-code" p-mode p-host-code  p-curr-host-code
  view-as alert-box ERROR.
  undo, return error.
end.
end.
FIND FIRST X_sysconf NO-LOCK WHERE
        X_sysconf.host-code = p-host-code NO-ERROR.
IF NOT AVAILABLE X_sysconf THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-host-code"  p-curr-host-code
    view-as alert-box ERROR.
    undo, return error.
END.
IF p-code-bank <> 0 THEN DO:
  FIND FIRST X_fin-bank NO-LOCK WHERE
            X_fin-bank.host-code = p-host-code
       AND  X_fin-bank.code-bank = p-code-bank NO-ERROR.
    IF NOT AVAILABLE X_fin-bank THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-code-bank"  p-code-bank
        view-as alert-box ERROR.
        undo, return error.
    END.
END.
IF p-code-schet <> 0 THEN DO:
  FIND FIRST X_fin-schet NO-LOCK WHERE
            X_fin-schet.host-code = p-host-code
       AND  X_fin-schet.code-schet = p-code-schet NO-ERROR.
    IF NOT AVAILABLE X_fin-schet THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-code-schet"  p-code-schet
        view-as alert-box ERROR.
        undo, return error.
    END.
    IF p-code-bank <> 0 THEN do:
      IF X_fin-schet.code-bank <>  p-code-bank THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-code-schet и/или p-code-bank"  p-code-schet p-code-bank
        view-as alert-box ERROR.
        undo, return error.
      END.
      FIND FIRST X_fin-bank NO-LOCK WHERE
                X_fin-bank.host-code = X_fin-schet.host-code
           AND  X_fin-bank.code-bank = X_fin-schet.code-bank.
   END.
END.
END PROCEDURE.
PROCEDURE control-line :
DEFINE OUTPUT PARAMETER p-lock-doc as logical no-undo.
IF CAN-FIND(FIRST ub.fin-statement-line No-LOCK WHERE
                  ub.fin-statement-line.host-code = tt-fin-statement.host-code
             AND  ub.fin-statement-line.sttm-code = tt-fin-statement.sttm-code) then
p-lock-doc = yes.
else p-lock-doc = no.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY e-line-ps mark-num f-bank-data f-th-data F-curr-abbr f-bank
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fin-statement THEN
    DISPLAY tt-fin-statement.prn-doc-code tt-fin-statement.num-docs
          tt-fin-statement.num-docs-th tt-fin-statement.sttm-code
          tt-fin-statement.doc-date tt-fin-statement.start-sum-doc
          tt-fin-statement.start-sum-doc-th tt-fin-statement.bank-date
          tt-fin-statement.in-sum-doc tt-fin-statement.in-sum-doc-th
          tt-fin-statement.fact-date tt-fin-statement.out-sum-doc
          tt-fin-statement.out-sum-doc-th tt-fin-statement.start-date
          tt-fin-statement.end-date tt-fin-statement.end-sum-doc
          tt-fin-statement.end-sum-doc-th tt-fin-statement.PS
          tt-fin-statement.curr-code tt-fin-statement.r-schet
          tt-fin-statement.bank-name tt-fin-statement.bik
          tt-fin-statement.bank-city
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-mark B-add B-lookup B-del B-print B-hist B-Help
         tt-fin-statement.prn-doc-code tt-fin-statement.num-docs
         tt-fin-statement.num-docs-th tt-fin-statement.doc-date
         tt-fin-statement.start-sum-doc tt-fin-statement.start-sum-doc-th
         tt-fin-statement.bank-date tt-fin-statement.in-sum-doc
         tt-fin-statement.in-sum-doc-th tt-fin-statement.out-sum-doc
         tt-fin-statement.out-sum-doc-th tt-fin-statement.start-date
         tt-fin-statement.end-date tt-fin-statement.end-sum-doc
         tt-fin-statement.end-sum-doc-th B-schet BR-lines e-line-ps
         tt-fin-statement.PS mark-num tt-fin-statement.curr-code
         tt-fin-statement.r-schet tt-fin-statement.bank-name
         tt-fin-statement.bik tt-fin-statement.bank-city
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
for each tt-fin-statement:
  delete tt-fin-statement.
end.
for each tt0-fin-statement-attr:
  delete tt0-fin-statement-attr.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U
or p-mode = 'ПРОСМОТР':U
then do:
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  find first locked_fin-statement EXclusive-lock where
                recid(locked_fin-statement) = p-doc-rec no-wait no-error.
  if locked locked_fin-statement then do:
    message
    vss-workfile vss-revision vss-description skip
    "Запись БАНКОВСКАЯ ВЫПИСКА занята"
    view-as alert-box error .
    undo, return error.
  end.
end.
else do:
  find first locked_fin-statement no-lock where
              recid(locked_fin-statement) = p-doc-rec no-error .
   if not available locked_fin-statement then do:
      find first locked_fin-statement no-lock where
                 locked_fin-statement.host-code = p-host-code
             AND locked_fin-statement.sttm-code = p-sttm-code no-error .
   end.
end.
if not available locked_fin-statement then do:
  message
  vss-workfile vss-revision vss-description skip
  "Не найдена запись БАНКОВСКОЙ ВЫПИСКИР"
  view-as alert-box error .
  undo, return error.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U
    AND not (locked_fin-statement.status_ = 'новый':U
          or locked_fin-statement.status_ = 'банк':U
             )
    then do:
      message
      "ВЫПИСКА находится в статусе" locked_fin-statement.status_ skip
      "Изменение невозможно"
      view-as alert-box error .
      undo, return error.
    end.
    if locked_fin-statement.status_ = 'банк':U  then do:
      assign
      v-limit-access = 1
      .
    end.
    create tt-fin-statement.
    buffer-copy locked_fin-statement to tt-fin-statement.
  end.
  else do:
    run cur-time in this-procedure ( output v-today, output v-time).
    create tt-fin-statement.
    assign
    tt-fin-statement.host-code = p-host-code
    tt-fin-statement.sttm-code  = next-value(s-fin-sttm, ub)
    tt-fin-statement.curr-code = (IF AVAILABLE X_fin-schet THEN X_fin-schet.curr-code ELSE 0)
    tt-fin-statement.code-schet = (IF AVAILABLE X_fin-schet THEN X_fin-schet.code-schet ELSE 0)
    tt-fin-statement.code-bank = (IF AVAILABLE X_fin-bank THEN X_fin-bank.code-bank ELSE 0)
    tt-fin-statement.c-schet  = (IF AVAILABLE X_fin-schet THEN X_fin-schet.c-schet ELSE '':u)
    tt-fin-statement.r-schet  = (IF AVAILABLE X_fin-schet THEN X_fin-schet.r-schet ELSE '':u)
    tt-fin-statement.bik  = (IF AVAILABLE X_fin-bank THEN X_fin-bank.bik ELSE '':u)
    tt-fin-statement.cl-bank  = (IF AVAILABLE X_fin-bank THEN X_fin-bank.cl-bank ELSE '':u)
    tt-fin-statement.bank-name = (IF AVAILABLE X_fin-bank THEN X_fin-bank.bank-name ELSE '':u)
    tt-fin-statement.bank-city = (IF AVAILABLE X_fin-bank THEN X_fin-bank.bank-city ELSE '':u)
    tt-fin-statement.cli-name  = X_CLIENTS.obj-NAME
    tt-fin-statement.PS  = '':U
    tt-fin-statement.prn-doc-code  = '':U
    tt-fin-statement.num-docs  = 0
    tt-fin-statement.fins-ext-doc-type = '':U
    tt-fin-statement.fins-doc-type = '':U
    tt-fin-statement.start-date  = v-today
    tt-fin-statement.end-date  = v-TODAY
    tt-fin-statement.doc-date      = v-today
    tt-fin-statement.fins-doc-type  = 'стд':U
    tt-fin-statement.fins-ext-doc-type  = 'стд':U
    tt-fin-statement.prn-doc-code  = "":U
    tt-fin-statement.status_       = 'новый':U
    .
  end.
END PROCEDURE.
PROCEDURE lock-proc :
DEFINE INPUT PARAMETER p-loc-doc AS LOGICAL NO-UNDO.
if p-mode = 'ПРОСМОТР':U then return.
if p-loc-doc then do:
    DISABLE
    b-schet
    tt-fin-statement.start-date
    tt-fin-statement.end-date
    tt-fin-statement.start-sum-doc-th
    with frame Dialog-Frame
    .
end.
else do:
    ENABLE
    b-schet WHEN tt-fin-statement.STATUS_ = 'новый':U
    tt-fin-statement.start-sum-doc-th WHEN tt-fin-statement.STATUS_ = 'новый':U
    tt-fin-statement.start-date WHEN tt-fin-statement.STATUS_ = 'новый':U
    tt-fin-statement.end-date WHEN tt-fin-statement.STATUS_ = 'новый':U
    with frame Dialog-Frame
    .
end.
IF tt-fin-statement.code-schet <> 0 THEN DO:
    ENABLE
    b-add WHEN tt-fin-statement.STATUS_ = 'новый':U
    b-lookup WHEN tt-fin-statement.STATUS_ = 'новый':U
    b-del WHEN tt-fin-statement.STATUS_ = 'новый':U
    with frame Dialog-Frame .
END.
ELSE DO:
    DISABLE
    b-add
    b-lookup
    b-del
    with frame Dialog-Frame .
END.
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN
LOCKED_fin-statement-line.prn-doc-code:READ-ONLY  IN BROWSE  br-lines = YES
v-cli-name:resizable IN BROWSE  br-lines  = YES
b-add:MENU-MOUSE in frame Dialog-Frame = 1
.
ASSIGN
v-tab-order = "b-exit,b-quit,b-mark,b-add,b-lookup,b-del,b-print,b-hist,b-help," +
              "prn-doc-code,doc-date,bank-date," +
              "start-date,end-date,start-sum-doc,start-sum-doc-th,fact-date,in-sum-doc,out-sum-doc,end-sum-doc,b-schet"
.
DISPLAY
F-curr-abbr
mark-num
f-bank
f-bank-data
f-th-data
WITH FRAME Dialog-Frame.
IF AVAILABLE tt-fin-statement THEN
DISPLAY
tt-fin-statement.num-docs
tt-fin-statement.num-docs-th
tt-fin-statement.prn-doc-code
tt-fin-statement.sttm-code
tt-fin-statement.doc-date
tt-fin-statement.bank-date
tt-fin-statement.fact-date
tt-fin-statement.curr-code
tt-fin-statement.start-date
tt-fin-statement.end-date
tt-fin-statement.start-sum-doc tt-fin-statement.start-sum-doc-th
tt-fin-statement.in-sum-doc tt-fin-statement.in-sum-doc-th
tt-fin-statement.out-sum-doc tt-fin-statement.out-sum-doc-th
tt-fin-statement.end-sum-doc tt-fin-statement.end-sum-doc-th
tt-fin-statement.r-schet
tt-fin-statement.bank-name
tt-fin-statement.bank-city
tt-fin-statement.bik
tt-fin-statement.PS
WITH FRAME Dialog-Frame.
e-line-ps:READ-ONLY IN FRAME Dialog-Frame = YES.
ENABLE
B-exit WHEN p-mode <> 'ПРОСМОТР':U
b-quit
B-mark WHEN NOT (p-mode = 'ПРОСМОТР':U AND p-line-rec = ?)
B-add   WHEN p-mode <> 'ПРОСМОТР':U  and v-limit-access = 0
B-lookup
B-del   WHEN p-mode <> 'ПРОСМОТР':U  and v-limit-access = 0
B-print
B-hist WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
B-Help
tt-fin-statement.prn-doc-code WHEN p-mode <> 'ПРОСМОТР':U
tt-fin-statement.PS
tt-fin-statement.doc-date     WHEN p-mode <> 'ПРОСМОТР':U
tt-fin-statement.bank-date    WHEN p-mode <> 'ПРОСМОТР':U
B-schet                       WHEN (p-mode <> 'ПРОСМОТР':U AND tt-fin-statement.num-docs = 0)
BR-lines
e-line-ps
mark-num
tt-fin-statement.start-date    WHEN (p-mode <> 'ПРОСМОТР':U AND tt-fin-statement.STATUS_ = 'новый':U)
tt-fin-statement.end-date      WHEN (p-mode <> 'ПРОСМОТР':U AND tt-fin-statement.STATUS_ = 'новый':U)
tt-fin-statement.num-docs      WHEN (p-mode <> 'ПРОСМОТР':U AND tt-fin-statement.STATUS_ = 'новый':U AND tt-fin-statement.cl-bank = '':U)
tt-fin-statement.start-sum-doc WHEN (p-mode <> 'ПРОСМОТР':U AND tt-fin-statement.STATUS_ = 'новый':U AND tt-fin-statement.cl-bank = '':U)
tt-fin-statement.start-sum-doc-th WHEN (p-mode <> 'ПРОСМОТР':U AND tt-fin-statement.STATUS_ = 'новый':U)
tt-fin-statement.in-sum-doc    WHEN (p-mode <> 'ПРОСМОТР':U AND tt-fin-statement.STATUS_ = 'новый':U AND tt-fin-statement.cl-bank = '':U)
tt-fin-statement.out-sum-doc   WHEN (p-mode <> 'ПРОСМОТР':U AND tt-fin-statement.STATUS_ = 'новый':U AND tt-fin-statement.cl-bank = '':U)
tt-fin-statement.end-sum-doc   WHEN (p-mode <> 'ПРОСМОТР':U AND tt-fin-statement.STATUS_ = 'новый':U AND tt-fin-statement.cl-bank = '':U)
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
IF p-mode = 'ПРОСМОТР':U THEN DO:
    HIDE
    b-exit
    IN FRAME Dialog-Frame.
    ASSIGN
    b-quit:LABEL = '&Выход'
    b-quit:COLUMN = 1
    tt-fin-statement.ps:READ-ONLY IN FRAME Dialog-Frame = YES
    .
END.
APPLY "Value-changed" TO tt-fin-statement.curr-code.
ASSIGN FRAME Dialog-Frame:TITLE = substitute("Выписка &1", tt-fin-statement.prn-doc-code).
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
OPEN QUERY br-lines FOR EACH locked_fin-statement-line NO-LOCK where
    locked_fin-statement-line.host-code = tt-fin-statement.host-code
 AND locked_fin-statement-line.sttm-code = tt-fin-statement.sttm-code INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE proc-b-add :
define input parameter p-fin-doc-type like ub.fin-doc.fin-doc-type no-undo .
define variable v-rid-list as character no-undo .
define variable v-line-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-pay-date LIKE ub.fin-doc.fact-date NO-UNDO.
define variable v-bik like ub.fin-statement-line.rp-bik no-undo .
define variable v-bank-name like ub.fin-statement-line.rp-bank-name no-undo .
define variable v-bank-city like ub.fin-statement-line.rp-bank-city no-undo .
define variable v-c-schet like ub.fin-statement-line.rp-c-schet no-undo .
define variable v-r-schet like ub.fin-statement-line.rp-r-schet no-undo .
define variable v-name like ub.fin-statement-line.rp-name no-undo .
define variable v-inn like ub.fin-statement-line.rp-inn no-undo .
define variable v-kpp like ub.fin-statement-line.rp-kpp no-undo .
DEFINE VARIABLE v-prn-doc-code LIKE ub.fin-doc.prn-doc-code NO-UNDO.
DEFINE VARIABLE v-fin-ext-doc-type LIKE ub.fin-doc.fin-ext-doc-type NO-UNDO.
define variable v-sum-doc as decimal no-undo .
define variable v-ps as character no-undo .
define variable ii as integer no-undo .
define buffer buf_fin-doc for ub.fin-doc.
run proc-save in this-procedure ( input no) No-ERROR.
if error-status:error then do:
   MESSAGE ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX.
   return error.
END.
assign
v-doc-rec = recid(locked_fin-statement)
v-line-rec = ?
.
IF p-fin-doc-type = 'no-th':U THEN DO:
  run ref/finsttli.w (
                  input tt-fin-statement.start-date
                 ,input tt-fin-statement.end-date
                 ,OUTPUT v-prn-doc-code
                 ,output v-fin-ext-doc-type
                 ,output v-pay-date
                 ,output v-bik
                 ,output v-bank-name
                 ,output v-bank-city
                 ,output v-c-schet
                 ,output v-r-schet
                 ,output v-name
                 ,output v-inn
                 ,output v-kpp
                 ,OUTPUT v-sum-doc
                 ,output v-ps
                 ) NO-ERROR.
  IF ERROR-STATUS:ERROR
  OR v-prn-doc-code = '':U THEN DO:
      RETURN .
  END.
    run ref/finsttml.p (
                   INPUT NO
                  ,INPUT-OUTPUT v-line-rec
                  ,INPUT 'ДОБАВЛЕНИЕ':U
                  ,INPUT tt-fin-statement.host-code
                  ,INPUT tt-fin-statement.sttm-code
                  ,INPUT 0
                  ,INPUT v-pay-date
                  ,INPUT v-prn-doc-code
                  ,INPUT v-fin-ext-doc-type
                  ,input v-bik
                  ,input v-bank-name
                  ,input v-bank-city
                  ,input v-c-schet
                  ,input v-r-schet
                  ,input v-name
                  ,input v-inn
                  ,input v-kpp
                  ,INPUT v-sum-doc
                  ,INPUT '':U
                  ,input v-ps
                    )
        no-error.
    if error-status:error then do:
      run control-line in this-procedure ( output lock-doc).
      run lock-proc in this-procedure ( input lock-doc).
      return error.
    end.
END.
ELSE DO:
    run ref/findocs.w (
                   input parparentproc
                  ,input p-curr-host-code
                  ,input "b-sel,b-mark":U
                  ,input (IF p-fin-doc-type = 'рпп':U
                          THEN "schet-fact-order-expense-cashless":U
                          ELSE "schet-fact-order-income-cashless":U)
                  ,input 'все':U
                  ,input tt-fin-statement.host-code
                  ,input "":U
                  ,input 0
                  ,input 'факт':U
                  ,input "":U
                  ,input p-fins-ext-doc-type
                  ,input tt-fin-statement.start-date
                  ,input tt-fin-statement.end-date
                  ,input "":U
                  ,input "":U
                  ,input 0
                  ,input "":U
                  ,input "":U
                  ,input 0
                  ,input "":U
                  ,input ?
                  ,input X_fin-schet.code-schet
                  ,input X_fin-schet.code-schet
                  ,input 0
                  ,input 0
                  ,input 0
                  ,input 0
                  ,input 0
                  ,input-output v-rid-list) NO-ERROR.
    IF v-rid-list <> '':U THEN DO:
        _ii:
        DO ii = 1 TO NUM-ENTRIES(v-rid-list)
        ON ERROR UNDO, NEXT _ii
        ON stop UNDO, NEXT _ii
            :
            FIND FIRST buf_fin-doc EXCLUSIVE-LOCK where
                   recid(buf_fin-doc) = INTEGER(ENTRY(ii, v-rid-list)).
            run ref/finsttml.p
                          (INPUT NO
                          ,INPUT-OUTPUT v-line-rec
                          ,INPUT 'ДОБАВЛЕНИЕ':U
                          ,INPUT tt-fin-statement.host-code
                          ,INPUT tt-fin-statement.sttm-code
                          ,INPUT buf_fin-doc.fin-doc-code
                          ,INPUT buf_fin-doc.pay-date
                          ,INPUT buf_fin-doc.prn-doc-code
                          ,INPUT buf_fin-doc.fin-ext-doc-type
                          ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                                then buf_fin-doc.receiver-bik
                                else buf_fin-doc.payer-bik)
                          ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                                then buf_fin-doc.receiver-bank-name
                                else buf_fin-doc.payer-bank-name)
                          ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                                then buf_fin-doc.receiver-bank-city
                                else buf_fin-doc.payer-bank-city)
                          ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                                then buf_fin-doc.receiver-c-schet
                                else buf_fin-doc.payer-c-schet )
                          ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                                then buf_fin-doc.receiver-r-schet
                                else buf_fin-doc.payer-r-schet )
                          ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                                then buf_fin-doc.receiver-name
                                else buf_fin-doc.payer-name )
                          ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                                then buf_fin-doc.receiver-inn
                                else buf_fin-doc.payer-inn )
                          ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                                then buf_fin-doc.receiver-kpp
                                else buf_fin-doc.payer-kpp )
                          ,INPUT buf_fin-doc.sum-doc
                          ,INPUT '':U
                          ,input buf_fin-doc.ps
                            )
                no-error.
            if error-status:error then do:
              run control-line in this-procedure ( output lock-doc).
              run lock-proc in this-procedure ( input lock-doc).
              return error.
            end.
        END.
    END.
END.
BUFFER-COPY LOCKED_fin-statement TO tt-fin-statement.
DISPLAY
tt-fin-statement.start-sum-doc-th
tt-fin-statement.in-sum-doc-th
tt-fin-statement.out-sum-doc-th
tt-fin-statement.end-sum-doc-th
tt-fin-statement.num-docs-th
tt-fin-statement.num-docs
with frame Dialog-Frame .
run control-line in this-procedure ( output lock-doc).
run lock-proc in this-procedure ( input lock-doc).
RUN OpenBr IN THIS-PROCEDURE ( input YES, input NO, input NO).
reposition br-lines to recid v-line-rec no-error.
apply "entry" to br-lines.
END PROCEDURE.
PROCEDURE proc-b-del :
DEFINE INPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-line-rec AS RECID NO-UNDO.
DEFINE BUFFER buf_fin-statement-line FOR ub.fin-statement-line.
_ii:
DO ii = 1 TO NUM-ENTRIES(p-rid-list)
ON ERROR UNDO, NEXT _ii
ON stop UNDO, NEXT _ii
    :
    FIND FIRST buf_fin-statement-line EXCLUSIVE-LOCK where
           recid(buf_fin-statement-line) = INTEGER(ENTRY(ii, p-rid-list)).
        v-line-rec = RECID(buf_fin-statement-line).
        run ref/finsttml.p (
                       INPUT NO
                      ,INPUT-OUTPUT v-line-rec
                      ,INPUT 'удаление':U
                      ,INPUT tt-fin-statement.host-code
                      ,INPUT tt-fin-statement.sttm-code
                      ,INPUT buf_fin-statement-line.fin-doc-code
                      ,INPUT buf_fin-statement-line.pay-date
                      ,INPUT buf_fin-statement-line.prn-doc-code
                      ,INPUT buf_fin-statement-line.fin-ext-doc-type
                      ,input buf_fin-statement-line.rp-bik
                      ,input buf_fin-statement-line.rp-bank-name
                      ,input buf_fin-statement-line.rp-bank-city
                      ,input buf_fin-statement-line.rp-c-schet
                      ,input buf_fin-statement-line.rp-r-schet
                      ,input buf_fin-statement-line.rp-name
                      ,input buf_fin-statement-line.rp-inn
                      ,input buf_fin-statement-line.rp-kpp
                      ,INPUT buf_fin-statement-line.sum-doc
                      ,INPUT '':U
                      ,input '':U
                        )
            no-error.
        if error-status:error then do:
          run control-line in this-procedure ( output lock-doc).
          run lock-proc in this-procedure ( input lock-doc).
          return error.
        end.
END.
BUFFER-COPY LOCKED_fin-statement TO tt-fin-statement.
DISPLAY
tt-fin-statement.start-sum-doc-th
tt-fin-statement.in-sum-doc-th
tt-fin-statement.out-sum-doc-th
tt-fin-statement.end-sum-doc-th
tt-fin-statement.num-docs-th
with frame Dialog-Frame .
run control-line in this-procedure ( output lock-doc).
run lock-proc in this-procedure ( input lock-doc).
RUN OpenBr IN THIS-PROCEDURE ( input YES, input NO, input NO).
reposition br-lines to recid v-line-rec no-error.
apply "entry" to br-lines.
END PROCEDURE.
PROCEDURE proc-save :
define input parameter parlines-exist as logical no-undo .
 IF p-mode = 'ПРОСМОТР':U THEN DO:
    RETURN.
 END.
 DO TRANSACTION
     ON ERROR UNDO, RETURN ERROR
     ON stop UNDO, RETURN ERROR:
 assign
 frame Dialog-Frame
 tt-fin-statement.prn-doc-code
 tt-fin-statement.doc-date
 tt-fin-statement.start-date
 tt-fin-statement.end-date
 tt-fin-statement.start-sum-doc-th
 tt-fin-statement.start-sum-doc when tt-fin-statement.cl-bank = '':U
 tt-fin-statement.end-sum-doc when tt-fin-statement.cl-bank = '':U
 tt-fin-statement.in-sum-doc when tt-fin-statement.cl-bank = '':U
 tt-fin-statement.out-sum-doc when tt-fin-statement.cl-bank = '':U
 tt-fin-statement.num-docs when tt-fin-statement.cl-bank = '':U
 tt-fin-statement.sum-doc = tt-fin-statement.in-sum-doc - tt-fin-statement.out-sum-doc
 tt-fin-statement.PS
 tt-fin-statement.start-date
 tt-fin-statement.end-date
 .
 v-doc-rec = (IF AVAILABLE locked_fin-statement THEN recid(locked_fin-statement) ELSE ?).
 run ref/finsttm0.p
                 (input no
                 ,input-output v-doc-rec
                 ,input       (IF v-first AND p-mode = 'ДОБАВЛЕНИЕ':U THEN  'ДОБАВЛЕНИЕ':U ELSE 'ИЗМЕНЕНИЕ':U)
                 ,input        '':U
                 ,input tt-fin-statement.host-code            ,input tt-fin-statement.sttm-code            ,input tt-fin-statement.curr-code            ,input tt-fin-statement.doc-date             ,input tt-fin-statement.bank-date            ,input tt-fin-statement.fact-date            ,input tt-fin-statement.fins-doc-type        ,input tt-fin-statement.fins-ext-doc-type    ,input tt-fin-statement.code-bank            ,input tt-fin-statement.bank-name            ,input tt-fin-statement.bank-city            ,input tt-fin-statement.bik                  ,input tt-fin-statement.code-schet           ,input tt-fin-statement.r-schet              ,input tt-fin-statement.c-schet              ,input tt-fin-statement.cli-name             ,input tt-fin-statement.prn-doc-code         ,input tt-fin-statement.PS                   ,input tt-fin-statement.sum-doc              ,input tt-fin-statement.start-sum-doc-th     ,input tt-fin-statement.start-sum-doc        ,input tt-fin-statement.in-sum-doc           ,input tt-fin-statement.out-sum-doc          ,input tt-fin-statement.end-sum-doc          ,input tt-fin-statement.num-docs             ,input tt-fin-statement.start-date           ,input tt-fin-statement.end-date
                 ,input 'новый':U
                 ,input parlines-exist
                 ) no-error .
if error-status:error then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
end.
else do:
  IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
     FIND FIRST LOCKED_fin-statement EXCLUSIVE-LOCK WHERE
               recid(LOCKED_fin-statement) = v-doc-rec.
       v-first = NO.
    hide
    b-quit in frame Dialog-Frame .
    assign
    b-exit:label in frame Dialog-Frame = "&Выход"
    .
  END.
 end.
END.
p-doc-rec = ?.
END PROCEDURE.
FUNCTION get-cli-name RETURNS CHARACTER
  (BUFFER buf_fin-statement-line FOR ub.fin-statement-line ) :
DEFINE BUFFER buf_fin-doc FOR ub.fin-doc.
IF buf_fin-statement-line.fin-doc-code = 0  THEN DO:
    RETURN '':U.
END.
FIND FIRST buf_fin-doc NO-LOCK WHERE
          buf_fin-doc.host-code = buf_fin-statement-line.host-code
     AND  buf_fin-doc.fin-doc-code = buf_fin-statement-line.fin-doc-code NO-ERROR.
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
