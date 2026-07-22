define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code as integer   no-undo .
define input  parameter p-db-num    as integer   no-undo .
define input  parameter ref-mode    as character no-undo .
define input  parameter p-doc-code  as character no-undo .
define input  parameter p-chip-num  as integer   no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Просмотр и изменения счета-фактуры":U.
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define variable g-log as logical   no-undo .
define variable res as logical   no-undo .
define variable ii as integer   no-undo .
define variable s-no-VAT as decimal   no-undo .
define variable s-0-VAT  as decimal   no-undo .
define variable s-10-VAT as decimal   no-undo .
define variable s-20-VAT  as decimal   no-undo .
define variable p-sys-time as character no-undo .
define buffer buf_schet-fact-doc for  ub.schet-fact-doc .
define buffer buf_c-schet-fact-doc for  ub.c-schet-fact-doc .
define buffer buf_person for ub.person.
define buffer buf_firm for ub.firm.
define buffer buf_clients for ub.clients.
define buffer buf_goods for ub.goods  .
define new shared variable br-handle as handle  no-undo .
define new shared variable next-prev as logical no-undo .
define new shared buffer   buf_contract for ub.contract.
define temp-table temp-line no-undo like ub.schet-fact-line
  field   artic as character init  ""
  field   edit  as logical init no
  index pi1 edit
.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>"
     SIZE 5 BY 1.
DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<"
     SIZE 5 BY 1.
DEFINE BUTTON B-sel-contract
     LABEL "До&говор"
     SIZE 10 BY 1 TOOLTIP "Просмотр договора".
DEFINE BUTTON B-sel-docum
     LABEL "Доку&мент"
     SIZE 10 BY 1 TOOLTIP "Просмотр документа-родителя".
DEFINE BUTTON BUTTON-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE BUTTON BUTTON-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.88 BY 1.
DEFINE VARIABLE book-code AS CHARACTER FORMAT "X(14)"
     LABEL "№ в кн."
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE cli-address LIKE ub.schet-fact-doc.cli-address
     LABEL "Адрес"
     VIEW-AS FILL-IN
     SIZE 90.63 BY 1 NO-UNDO.
DEFINE VARIABLE cli-code AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1.
DEFINE VARIABLE cli-inn LIKE ub.schet-fact-doc.cli-inn
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE cli-KPP AS CHARACTER FORMAT "X(20)"
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE cli-name LIKE ub.schet-fact-doc.cli-name
     VIEW-AS FILL-IN
     SIZE 47 BY 1 NO-UNDO.
DEFINE VARIABLE cli-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1.
DEFINE VARIABLE contract-code LIKE ub.schet-fact-doc.contract-code
     LABEL "Договор"
     VIEW-AS FILL-IN
     SIZE 6.5 BY 1 NO-UNDO.
DEFINE VARIABLE country AS CHARACTER FORMAT "X(30)"
     LABEL "Страна "
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE doc-code LIKE ub.schet-fact-doc.doc-code
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE doc-date LIKE ub.schet-fact-doc.doc-date
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE ext-doc-type LIKE ub.schet-fact-doc.ext-doc-type
     LABEL "Тип"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE Gruz-otprav LIKE ub.schet-fact-doc.Gruz-otprav
     VIEW-AS FILL-IN
     SIZE 79.63 BY 1 NO-UNDO.
DEFINE VARIABLE Gruz-poluch LIKE ub.schet-fact-doc.Gruz-poluch
     VIEW-AS FILL-IN
     SIZE 79.63 BY 1 NO-UNDO.
DEFINE VARIABLE gtd LIKE ub.schet-fact-doc.gtd
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.
DEFINE VARIABLE in-date LIKE ub.schet-fact-doc.in-date
     LABEL "Оприход"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 TOOLTIP "Дата оприходывания по документу" NO-UNDO.
DEFINE VARIABLE own-address LIKE ub.schet-fact-doc.own-address
     LABEL "Адрес"
     VIEW-AS FILL-IN
     SIZE 56.63 BY 1 NO-UNDO.
DEFINE VARIABLE own-inn LIKE ub.schet-fact-doc.own-inn
     VIEW-AS FILL-IN
     SIZE 19 BY .92 NO-UNDO.
DEFINE VARIABLE own-KPP AS CHARACTER FORMAT "X(20)"
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE own-name LIKE ub.schet-fact-doc.own-name
     VIEW-AS FILL-IN
     SIZE 26.5 BY 1 NO-UNDO.
DEFINE VARIABLE pay-date LIKE ub.schet-fact-doc.pay-date
     LABEL "Оплата"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 TOOLTIP "Дата оплаты" NO-UNDO.
DEFINE VARIABLE plat-ras-doc LIKE ub.schet-fact-doc.plat-ras-doc
     LABEL "К док-ту №"
     VIEW-AS FILL-IN
     SIZE 23.5 BY 1 TOOLTIP "К пл.-рас. док-ту №" NO-UNDO.
DEFINE VARIABLE PS LIKE ub.schet-fact-doc.PS
     VIEW-AS FILL-IN
     SIZE 85.5 BY 1 NO-UNDO.
DEFINE VARIABLE status_ LIKE ub.schet-fact-doc.status_
     VIEW-AS FILL-IN
     SIZE 7.13 BY 1 NO-UNDO.
DEFINE VARIABLE sum-rubl LIKE ub.schet-fact-doc.sum-rubl
     LABEL "Сумма с НДС"
      VIEW-AS TEXT
     SIZE 21.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE VAT-10-rubl LIKE ub.schet-fact-doc.VAT-10-rubl
     LABEL "НДС 10%"
      VIEW-AS TEXT
     SIZE 18.5 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE VAT-20-rubl LIKE ub.schet-fact-doc.VAT-20-rubl
     LABEL "НДС 18%"
      VIEW-AS TEXT
     SIZE 18.5 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
      temp-line SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 NO-LOCK DISPLAY
      temp-line.artic COLUMN-LABEL "Артикул" WIDTH 10
      temp-line.gds-name WIDTH 38
      temp-line.unit-base
      temp-line.fact-qnty COLUMN-LABEL "Кол-во"
      temp-line.price-rubl COLUMN-LABEL "Цена" WIDTH 17.5
      temp-line.sum-rubl COLUMN-LABEL "Стоим. без НДС" WIDTH 17
      temp-line.excise WIDTH 7.5
      temp-line.VAT-pc COLUMN-LABEL "% НДС"
      temp-line.VAT-rubl COLUMN-LABEL "Сумма НДС" WIDTH 14
      temp-line.sum-rubl-VAT COLUMN-LABEL "Сумма" WIDTH 20.25
      temp-line.country WIDTH 21.13
      temp-line.gtd WIDTH 18.38
      temp-line.part-code WIDTH 9.38
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 9.75 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-OK AT ROW 1 COL 1
     b-exit AT ROW 1 COL 11
     b-next AT ROW 1 COL 21
     b-prev AT ROW 1 COL 26
     B-sel-contract AT ROW 1 COL 31 WIDGET-ID 12
     B-sel-docum AT ROW 1 COL 41 WIDGET-ID 14
     b-hist AT ROW 1 COL 80
     B-Help AT ROW 1 COL 90
     doc-code AT ROW 2 COL 7 COLON-ALIGNED HELP
          ""
     book-code AT ROW 2 COL 26.38 COLON-ALIGNED WIDGET-ID 2
     doc-date AT ROW 2 COL 43.75 COLON-ALIGNED HELP
          "" FORMAT "99/99/9999"
     ext-doc-type AT ROW 2 COL 60.13 COLON-ALIGNED HELP
          ""
          LABEL "Тип"
     status_ AT ROW 2 COL 72.38 COLON-ALIGNED HELP
          ""
     contract-code AT ROW 2 COL 88.88 COLON-ALIGNED HELP
          ""
          LABEL "Договор" FORMAT ">>>>>>>>9"
     BUTTON-contr AT ROW 2 COL 97.5 WIDGET-ID 10
     own-name AT ROW 3.04 COL 7 COLON-ALIGNED HELP
          "" NO-LABEL
     own-address AT ROW 3.04 COL 36.5 HELP
          ""
          LABEL "Адрес"
     own-inn AT ROW 4.08 COL 11.5 COLON-ALIGNED HELP
          ""
     own-KPP AT ROW 4.08 COL 41.5 COLON-ALIGNED WIDGET-ID 18
     cli-code AT ROW 5.04 COL 11.5 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     cli-type AT ROW 5.04 COL 17.88 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     BUTTON-cli AT ROW 5.04 COL 24.88 WIDGET-ID 4
     cli-name AT ROW 5.04 COL 26.5 COLON-ALIGNED HELP
          "" NO-LABEL FORMAT "X(47)"
     cli-inn AT ROW 6.08 COL 11.5 COLON-ALIGNED HELP
          ""
     cli-KPP AT ROW 6.08 COL 41.5 COLON-ALIGNED WIDGET-ID 20
     cli-address AT ROW 7.08 COL 2.5 HELP
          ""
          LABEL "Адрес"
     Gruz-otprav AT ROW 8.13 COL 2.5 HELP
          ""
     Gruz-poluch AT ROW 9.17 COL 3.5 HELP
          ""
     gtd AT ROW 10.21 COL 4.38 COLON-ALIGNED HELP
          ""
     country AT ROW 10.25 COL 40 COLON-ALIGNED
     pay-date AT ROW 10.25 COL 68.5 COLON-ALIGNED HELP
          ""
          LABEL "Оплата" FORMAT "99/99/99"
     in-date AT ROW 10.25 COL 86.88 COLON-ALIGNED HELP
          ""
          LABEL "Оприход"
     PS AT ROW 11.25 COL 2 HELP
          "" FORMAT "X(255)"
     plat-ras-doc AT ROW 12.25 COL 12 COLON-ALIGNED HELP
          ""
          LABEL "К док-ту №"
     B-add AT ROW 13.42 COL 1
     b-chg AT ROW 13.42 COL 11
     B-del AT ROW 13.42 COL 21
     BROWSE-1 AT ROW 14.5 COL 1
     VAT-10-rubl AT ROW 12.58 COL 79 COLON-ALIGNED HELP
          ""
          LABEL "НДС 10%"
          FGCOLOR 1
     sum-rubl AT ROW 12.63 COL 48.75 COLON-ALIGNED HELP
          ""
          LABEL "Сумма с НДС"
          FGCOLOR 4
     VAT-20-rubl AT ROW 13.42 COL 79 COLON-ALIGNED HELP
          ""
          LABEL "НДС 18%"
          FGCOLOR 1
     "Контрагент:" VIEW-AS TEXT
          SIZE 11.5 BY .67 AT ROW 5.17 COL 1.5
          FGCOLOR 4
     "Фирма:" VIEW-AS TEXT
          SIZE 7.25 BY .67 AT ROW 3.25 COL 1.5
          FGCOLOR 4
     SPACE(91.63) SKIP(20.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Cчет-фактура".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-next:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-prev:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
define variable gds-name   as character no-undo .
define variable unit-base  as character no-undo .
define variable fact-qnty  as decimal   no-undo .
define variable price-rubl as decimal   no-undo .
define variable sum-rubl1  as decimal   no-undo .
define variable excise     as decimal   no-undo .
define variable VAT-pc     as decimal   no-undo .
define variable VAT-rubl   as decimal   no-undo .
define variable sum-rubl-VAT as decimal   no-undo .
define variable country1   as character no-undo .
define variable gtd1       as character no-undo .
  assign gtd country .
  assign
    country1 = country
    gtd1     = gtd
  .
  assign res = no .
  run str/s-f-line.w
      ( input parParentProc,
        input-output gds-name, input-output unit-base, input-output fact-qnty, input-output price-rubl,
        input-output sum-rubl1, input-output excise,    input-output VAT-pc,    input-output VAT-rubl,
        input-output sum-rubl-VAT, input-output country1,   input-output gtd1 ,  input-output res) .
  if res then do:
    create temp-line .
    assign
      temp-line.db-num        = p-db-num
      temp-line.gds-name      = gds-name
      temp-line.unit-base     = unit-base
      temp-line.fact-qnty     = fact-qnty
      temp-line.price-rubl    = price-rubl
      temp-line.sum-rubl      = sum-rubl1
      temp-line.excise        = excise
      temp-line.VAT-pc        = VAT-pc
      temp-line.VAT-rubl      = VAT-rubl
      temp-line.sum-rubl-VAT  = sum-rubl-VAT
      temp-line.country       = country1
      temp-line.gtd           = gtd1
      temp-line.artic         = ""
      temp-line.edit          = yes
    .
    if gtd = "" or gtd = ?  then assign gtd = gtd1 .
    if country = "" then assign country = country1 .
    run proc-calc .
    DISPLAY VAT-10-rubl VAT-20-rubl  sum-rubl gtd country  WITH FRAME Dialog-Frame.
    OPEN QUERY BROWSE-1 FOR EACH temp-line INDEXED-REPOSITION.
  end.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  if not available temp-line then return no-apply.
define variable gds-name   as character no-undo .
define variable unit-base  as character no-undo .
define variable fact-qnty  as decimal   no-undo .
define variable price-rubl as decimal   no-undo .
define variable sum-rubl1  as decimal   no-undo .
define variable excise     as decimal   no-undo .
define variable VAT-pc     as decimal   no-undo .
define variable VAT-rubl   as decimal   no-undo .
define variable sum-rubl-VAT as decimal   no-undo .
define variable country1   as character no-undo .
define variable gtd1       as character no-undo .
    assign
      gds-name      = temp-line.gds-name
      unit-base     = temp-line.unit-base
      fact-qnty     = temp-line.fact-qnty
      price-rubl    = temp-line.price-rubl
      sum-rubl1     = temp-line.sum-rubl
      excise        = temp-line.excise
      VAT-pc        = temp-line.VAT-pc
      VAT-rubl      = temp-line.VAT-rubl
      sum-rubl-VAT  = temp-line.sum-rubl-VAT
      country1      = temp-line.country
      gtd1          = temp-line.gtd
   .
  assign res = no .
  run str/s-f-line.w
    ( input parParentProc,
      input-output gds-name, input-output unit-base, input-output fact-qnty, input-output price-rubl,
      input-output sum-rubl1, input-output excise,    input-output VAT-pc,    input-output VAT-rubl,
      input-output sum-rubl-VAT, input-output country1,   input-output gtd1 ,  input-output res) .
  if res then do:
    assign
      temp-line.gds-name      = gds-name
      temp-line.unit-base     = unit-base
      temp-line.fact-qnty     = fact-qnty
      temp-line.price-rubl    = price-rubl
      temp-line.sum-rubl      = sum-rubl1
      temp-line.excise        = excise
      temp-line.VAT-pc        = VAT-pc
      temp-line.VAT-rubl      = VAT-rubl
      temp-line.sum-rubl-VAT  = sum-rubl-VAT
      temp-line.country       = country1
      temp-line.gtd           = gtd1
      temp-line.artic         = ""
      temp-line.edit          = yes
    .
    run proc-calc .
    if gtd = "" then assign gtd = gtd1 .
    if country = "" then assign country = country1 .
    OPEN QUERY BROWSE-1 FOR EACH temp-line INDEXED-REPOSITION.
    DISPLAY VAT-10-rubl VAT-20-rubl  sum-rubl gtd country  WITH FRAME Dialog-Frame.
  end.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  if not avail temp-line then return no-apply.
  DISPLAY VAT-10-rubl VAT-20-rubl  sum-rubl   WITH FRAME Dialog-Frame.
  delete temp-line .
  run proc-calc .
  DISPLAY VAT-10-rubl VAT-20-rubl  sum-rubl  WITH FRAME Dialog-Frame.
  OPEN QUERY BROWSE-1 FOR EACH temp-line INDEXED-REPOSITION.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  if ref-mode = 'ИЗМЕНЕНИЕ':U or ref-mode = 'ДОБАВЛЕНИЕ':U then do:
    message "Отменить сделанные изменения?"  view-as alert-box QUESTION BUTTONS YES-NO update g-log .
    if g-log = no then return no-apply.
  end.
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
DO:
  run str/s-f-hist.w (input parparentproc, input p-host-code, p-doc-code) .
END.
ON CHOOSE OF b-next IN FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF b-OK IN FRAME Dialog-Frame
DO:
  if ref-mode = 'ИЗМЕНЕНИЕ':U or ref-mode = 'ДОБАВЛЕНИЕ':U then do:
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
    assign contract-code doc-code book-code  doc-date  own-name  own-inn  own-address  cli-code  cli-type  cli-name  cli-address
           cli-inn ext-doc-type  status_ Gruz-otprav Gruz-poluch  gtd    country  plat-ras-doc
           pay-date  in-date         PS  own-kpp cli-kpp .
    find first temp-line no-error .
    if not available temp-line then do:
      message  "Нет товарных строк!"   view-as alert-box.
      return no-apply .
    end.
    if doc-date > pay-date then do:
      message  "Дата оплаты " pay-date " меньше даты создания "  doc-date "!"   view-as alert-box.
      return no-apply .
    end.
    define variable str as character init "" no-undo .
    find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error .
    if error-status :error then do:
       message "Не верно задан Контрагент"  view-as alert-box information .
       return no-apply .
    end.
    if cli-name <> buf_clients.obj-name then assign str = str + "наименование контрагента в с-ф " + cli-name + " не совпадает с наименованием в справочнике " + buf_clients.obj-name + chr(10) .
    if buf_clients.obj-type = 'орг':U then do:
      find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code .
      if cli-inn <> buf_firm.inn then assign str = str + "ИНН контрагента в с-ф " + cli-inn + " не совпадает с ИНН в справочнике " + buf_firm.inn + chr(10) .
      if cli-kpp <> buf_firm.kpp then assign str = str + "КПП контрагента в с-ф " + cli-kpp + " не совпадает с КПП в справочнике " + buf_firm.kpp + chr(10) .
      if cli-address <> (trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)) then assign str = str + "адрес контрагента в с-ф " + cli-address + " не совпадает с адресом в справочнике " + (trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)) + chr(10) .
    end.
    else do:
      find first buf_person no-lock where buf_person.psn-code = buf_clients.obj-code no-error.
      if cli-address <> buf_person.address then assign str = str + "адрес контрагента в с-ф " + cli-address + " не совпадает с адресом в справочнике " + buf_person.address + chr(10) .
    end.
    find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = p-host-code .
    if own-name <> buf_clients.obj-name then assign str = str + "наименование фирмы в с-ф " + own-name + " не совпадает с наименованием в справочнике " + buf_clients.obj-name + chr(10) .
    find first buf_firm no-lock where buf_firm.firm-code = p-host-code .
    if own-inn <> buf_firm.inn then assign str = str + "ИНН фирмы в с-ф " + own-inn + " не совпадает с ИНН в справочнике " + buf_firm.inn + chr(10) .
    if own-kpp <> buf_firm.kpp then assign str = str + "КПП фирмы в с-ф " + own-inn + " не совпадает с КПП в справочнике " + buf_firm.kpp + chr(10) .
    if own-address <> (trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)) then assign str = str + "адрес фирмы в с-ф " + own-address + " не совпадает с адресом в справочнике " + (trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)) + chr(10) .
    if str <> "" then do:
      message str "Продолжить?"  view-as alert-box QUESTION BUTTONS YES-NO update g-log .
      if g-log = no then return no-apply.
    end.
    define variable v-sum-all as decimal   no-undo init 0.
    define variable v-sum-all-vat as decimal   no-undo init 0.
    for each  temp-line :
       v-sum-all = v-sum-all + temp-line.sum-rubl-VAT.
       v-sum-all-vat = v-sum-all-vat + temp-line.vat-rubl.
    end.
    if v-sum-all <> sum-rubl then do:
       message "Не верно введены суммы" skip v-sum-all skip  sum-rubl view-as alert-box information .
       return no-apply .
    end.
    if v-sum-all-vat  <> (VAT-10-rubl + VAT-20-rubl) then do:
       message "Не верно введены суммы НДС" skip 'по строкам ' v-sum-all-vat skip  VAT-10-rubl VAT-20-rubl view-as alert-box information .
       return no-apply .
    end.
    if ref-mode = 'ДОБАВЛЕНИЕ':U then do:
      if book-code <> "" and book-code <> ? then do:
        find first ub.schet-fact-doc no-lock where ub.schet-fact-doc.host-code = p-host-code and ub.schet-fact-doc.book-code = book-code no-error .
        if available ub.schet-fact-doc and year(ub.schet-fact-doc.doc-date) = year(doc-date) then do:
          message substitute("Уже есть счет-фактура с таким № &2 в книге продаж за &1 год ." , year(doc-date) , book-code ) view-as alert-box.
          return no-apply .
        end.
      end.
      create buf_schet-fact-doc .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output buf_schet-fact-doc.user-db-num
  ,output buf_schet-fact-doc.user-name
  ,output buf_schet-fact-doc.sys-date
  ,output p-sys-time
  ,output buf_schet-fact-doc.sys-time
  )  .
      assign
        buf_schet-fact-doc.doc-code           = string(next-value(s-sf-doc, ub))
        buf_schet-fact-doc.db-num             = v-cntxt-db-num
        buf_schet-fact-doc.status_            = 'новый':U
        buf_schet-fact-doc.ext-doc-type       = ""
        buf_schet-fact-doc.host-code          = p-host-code
        buf_schet-fact-doc.contract-code      = contract-code
        buf_schet-fact-doc.doc-date           = doc-date
        buf_schet-fact-doc.cli-code           = cli-code
        buf_schet-fact-doc.cli-type           = cli-type
        buf_schet-fact-doc.obj-code           = v-cntxt-obj-code
        buf_schet-fact-doc.obj-type           = v-cntxt-obj-type
        buf_schet-fact-doc.sum-rubl           = sum-rubl
        buf_schet-fact-doc.VAT-10-rubl        = VAT-10-rubl
        buf_schet-fact-doc.VAT-20-rubl        = VAT-20-rubl
        buf_schet-fact-doc.office             = yes
      .
      ii = 0.
      for each temp-line :
         ii = ii + 1 .
        create ub.schet-fact-line .
        buffer-copy temp-line  to ub.schet-fact-line
        assign
          ub.schet-fact-line.line-num      = ii
          ub.schet-fact-line.doc-code      = buf_schet-fact-doc.doc-code
          ub.schet-fact-line.db-num        = buf_schet-fact-doc.user-db-num
          ub.schet-fact-line.gds-code      = ?
          ub.schet-fact-line.type          = 'новый':U
          ub.schet-fact-line.ext-doc-type  = buf_schet-fact-doc.ext-doc-type
          ub.schet-fact-line.fact-order    = buf_schet-fact-doc.fact-order
          ub.schet-fact-line.status_       = buf_schet-fact-doc.status_
          ub.schet-fact-line.obj-code      = v-cntxt-obj-code
          ub.schet-fact-line.obj-type      = v-cntxt-obj-type
          ub.schet-fact-line.host-code     = p-host-code
          ub.schet-fact-line.in-code       = ""
          ub.schet-fact-line.other-base    = 0
          ub.schet-fact-line.other-rubl    = 0
        .
      end.
    end.
    else do:
      if book-code <> "" and book-code <> ? then do:
        find first ub.schet-fact-doc no-lock
          where ub.schet-fact-doc.host-code = p-host-code
            and ub.schet-fact-doc.book-code = book-code
        no-error .
        if available ub.schet-fact-doc and ub.schet-fact-doc.doc-code <> p-doc-code and year(ub.schet-fact-doc.doc-date) = year(doc-date) then do:
          message substitute("Уже есть счет-фактура с таким № &1 в книге продаж за &2 год .", p-doc-code , year(doc-date)) view-as alert-box.
          return no-apply .
        end.
      end.
      find first buf_schet-fact-doc exclusive-lock where buf_schet-fact-doc.doc-code = p-doc-code and buf_schet-fact-doc.db-num = p-db-num no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      if  B-add:visible = yes then do:
        assign
          buf_schet-fact-doc.contract-code   = contract-code
          buf_schet-fact-doc.doc-type        = 'при':U
          buf_schet-fact-doc.VAT-20-rubl     = VAT-20-rubl
          buf_schet-fact-doc.sum-rubl        = sum-rubl
          buf_schet-fact-doc.VAT-10-rubl     = VAT-10-rubl
          buf_schet-fact-doc.sum-VAT-no-rubl = s-no-VAT
          buf_schet-fact-doc.sum-VAT-0-rubl  = s-0-VAT
          buf_schet-fact-doc.sum-VAT-10-rubl = s-10-VAT
          buf_schet-fact-doc.sum-VAT-20-rubl = s-20-VAT
          buf_schet-fact-doc.office     = yes
        .
        for each ub.schet-fact-line exclusive-lock where ub.schet-fact-line.doc-code = p-doc-code and ub.schet-fact-line.db-num = buf_schet-fact-doc.db-num :
          delete ub.schet-fact-line .
        end.
        ii = 0 .
        for each temp-line :
          ii = ii + 1.
          create ub.schet-fact-line .
          buffer-copy temp-line to ub.schet-fact-line
          assign
            ub.schet-fact-line.line-num      = ii
            ub.schet-fact-line.type          = 'новый':U
            ub.schet-fact-line.doc-code      = buf_schet-fact-doc.doc-code
            ub.schet-fact-line.gds-code      = ?
            ub.schet-fact-line.ext-doc-type  = buf_schet-fact-doc.ext-doc-type
            ub.schet-fact-line.fact-order    = buf_schet-fact-doc.fact-order
            ub.schet-fact-line.status_       = buf_schet-fact-doc.status_
            ub.schet-fact-line.host-code     = p-host-code
            ub.schet-fact-line.obj-code      = v-cntxt-obj-code
            ub.schet-fact-line.obj-type      = v-cntxt-obj-type
            ub.schet-fact-line.in-code       = ""
            ub.schet-fact-line.other-base    = 0
            ub.schet-fact-line.other-rubl    = 0
          .
        end.
      end.
    end.
    assign
      buf_schet-fact-doc.book-code      =     book-code
      buf_schet-fact-doc.own-name       =     own-name
      buf_schet-fact-doc.own-inn        =     own-inn
      buf_schet-fact-doc.own-kpp        =     own-kpp
      buf_schet-fact-doc.own-address    =     own-address
      buf_schet-fact-doc.cli-name       =     cli-name
      buf_schet-fact-doc.cli-address    =     cli-address
      buf_schet-fact-doc.cli-inn        =     cli-inn
      buf_schet-fact-doc.cli-kpp        =     cli-kpp
      buf_schet-fact-doc.Gruz-otprav    =     Gruz-otprav
      buf_schet-fact-doc.Gruz-poluch    =     Gruz-poluch
      buf_schet-fact-doc.gtd            =     gtd
      buf_schet-fact-doc.country        =     country
      buf_schet-fact-doc.plat-ras-doc   =     plat-ras-doc
      buf_schet-fact-doc.pay-date       =     pay-date
      buf_schet-fact-doc.in-date        =     in-date
      buf_schet-fact-doc.PS             =     PS
    .
  end.
END.
ON CHOOSE OF b-prev IN FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF B-sel-contract IN FRAME Dialog-Frame
DO:
assign
  contract-code
.
  if contract-code = 0 or contract-code = ? then do:
  end.
define variable ri as recid no-undo .
define buffer b_contract for ub.contract.
find first b_contract no-lock  where b_contract.contract-code     = contract-code and
                                     b_contract.host-code         = p-host-code
                                     no-error .
if error-status :error then return no-apply.
  ri = recid (b_contract) .
  run str/sh-contr.p
      ( input parParentProc ,
        input ri
      ).
END.
ON CHOOSE OF B-sel-docum IN FRAME Dialog-Frame
DO:
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_fin-ob  for ub.fin-ob  .
define buffer buf_add-doc for ub.add-doc  .
define variable v-r as recid no-undo .
  if buf_schet-fact-doc.in-doc-code = "" and buf_schet-fact-doc.in-doc-code = ? then do:
     return no-apply .
  end.
  case buf_schet-fact-doc.in-doc-type :
    when 'fo' then do:
        find first buf_fin-ob no-lock where buf_fin-ob.doc-code =  buf_schet-fact-doc.in-doc-code and
                                          buf_fin-ob.host-code = p-host-code no-error .
        if available buf_fin-ob then do:
            run str/sh-finob.p ( input parParentProc, input v-cntxt-host-code-obj, input recid(buf_fin-ob)).
        end.
    end.
    when 'fd' then do:
       run ref/showfind.p
        (  input parparentproc
          ,input v-cntxt-host-code-obj
          ,input p-host-code
          ,input buf_schet-fact-doc.in-doc-code)
          .
    end.
    when 'td' then do:
      find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = buf_schet-fact-doc.in-doc-code no-error .
      if available buf_trn-doc then
          run str/fishdoc.p
            (  parparentproc,
              buf_trn-doc.host-code ,
              buf_trn-doc.obj-type,
              buf_trn-doc.obj-code,
              buf_trn-doc.doc-code ,
              ? ) .
    end.
    when  'ad':U then do:
      find first buf_add-doc no-lock  where buf_add-doc.doc-code = buf_schet-fact-doc.in-doc-code no-error .
      if available buf_add-doc then
          v-r = recid(buf_add-doc) .
          run str/add-docu.w ( input parparentproc  ,
                               input-output v-r ,
                               input 'ПРОСМОТР':U  ,
                               input ?
                               ).
    end.
   end case .
END.
ON CHOOSE OF BUTTON-cli IN FRAME Dialog-Frame
DO:
  define variable agnt-list as character no-undo .
  run ref/cli-all.w (parParentProc, "b-sel", 'все':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, "without-obj":U, output agnt-list ) .
  if agnt-list <> "" then do:
    find first buf_clients no-lock where RECID(buf_clients) = int (agnt-list) no-error.
    if buf_clients.obj-type <> 'чел':U and buf_clients.obj-type <> 'орг':U then do:
      message
        "Контрагент может быть только " 'орг':U " или " 'чел':U
        view-as alert-box ERROR .
      return no-apply.
    end.
    assign
      cli-name = buf_clients.obj-name
      cli-code = buf_clients.obj-code
      cli-type = buf_clients.obj-type
    .
    if buf_clients.obj-type = 'орг':U then do:
      find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error.
      if available buf_firm then
         assign
           cli-kpp = buf_firm.kpp
           cli-inn = buf_firm.inn
           cli-address = trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)
         .
    end.
    else do:
      find first buf_person no-lock where buf_person.psn-code = buf_clients.obj-code no-error.
      if available buf_person then assign  cli-address = buf_person.address   cli-inn = ""  cli-kpp = "".
    end.
  end.
  else assign cli-name = ""  cli-inn = "" cli-kpp = ""  cli-address = ""  cli-code = ?  cli-type  = ? .
  display cli-name    cli-code     cli-type  cli-inn cli-kpp  cli-address  with frame Dialog-Frame.
END.
ON CHOOSE OF BUTTON-contr IN FRAME Dialog-Frame
DO:
  if ( ref-mode = 'ИЗМЕНЕНИЕ':U and buf_schet-fact-doc.office = yes ) or ref-mode = 'ДОБАВЛЕНИЕ':U then do:
    define variable cont-list as character no-undo .
    find first buf_contract no-lock where buf_contract.contract-code = contract-code and buf_contract.host-code = p-host-code no-error .
    if available buf_contract then assign cont-list = string(recid(buf_contract)) .
    run str/cont-all.w ( parParentProc, p-host-code, "b-sel", 'фирма':U, ?, ?, ?, ?, "current":U, 'при':U, input-output cont-list ) .
    if cont-list = "" then do:
      assign  contract-code = ? .
    end.
    else do:
      define variable ii as integer   no-undo .
      do ii = 1 to num-entries (cont-list):
        find first ub.contract no-lock where recid(ub.contract) = integer (entry (ii, cont-list)) .
        assign contract-code = ub.contract.contract-code .
      end.
    end.
    display contract-code with frame Dialog-Frame.
  end.
  else do:
    find first buf_contract no-lock where buf_contract.contract-code = contract-code and buf_contract.host-code = p-host-code no-error .
    if not avail buf_contract then return no-apply.
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-contract_lookup':U
    ,input  'firm':U
    ,input  p-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
    if not g-log then return no-apply .
    define variable ri as recid     no-undo .
    assign ri = recid( buf_contract ) .
    run str/contr.w ( input parParentProc,input p-host-code, input 'ПРОСМОТР':U, input 'при':U, input-output ri).
  end.
END.
ON LEAVE OF cli-code IN FRAME Dialog-Frame
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code.
  if cli-type <> 'орг':U and cli-type <> 'чел':U then do:
    find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = cli-code no-error.
    if not available buf_clients then do:
      find first buf_clients no-lock where buf_clients.obj-type = 'чел':U and buf_clients.obj-code = cli-code no-error.
    end.
  end.
  else find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
  if not available buf_clients then do:
    if cli-code = 0 then assign cli-code = ? .
    if cli-code = ? then do:
      assign cli-name = ""  cli-inn = ""  cli-kpp = "" cli-address = ""  cli-code = ?  cli-type  = ? .
      display cli-name    cli-code     cli-type  cli-inn cli-kpp  cli-address   with frame Dialog-Frame.
    end.
    else do:
      apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
    end.
    return.
  end.
  assign
    cli-name = buf_clients.obj-name
    cli-code = buf_clients.obj-code
    cli-type = buf_clients.obj-type
  .
  if buf_clients.obj-type = 'орг':U then do:
    find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error.
    if available buf_firm then
       assign
         cli-kpp = buf_firm.kpp
         cli-inn = buf_firm.inn
         cli-address = trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)
      .
  end.
  else do:
    find first buf_person no-lock where buf_person.psn-code = buf_clients.obj-code no-error.
    if available buf_person then assign  cli-address = buf_person.address   cli-inn = "" cli-kpp = "".
  end.
  display cli-name    cli-code     cli-type  cli-inn cli-kpp  cli-address   with frame Dialog-Frame.
END.
ON RETURN OF cli-code IN FRAME Dialog-Frame
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code.
  if cli-type <> 'орг':U and cli-type <> 'чел':U then do:
    find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = cli-code no-error.
    if not available buf_clients then do:
      find first buf_clients no-lock where buf_clients.obj-type = 'чел':U and buf_clients.obj-code = cli-code no-error.
    end.
  end.
  else find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
  if not available buf_clients then do:
    if cli-code = 0 then assign cli-code = ? .
    if cli-code = ? then do:
      assign cli-name = ""  cli-inn = "" cli-kpp = "" cli-address = ""  cli-code = ?  cli-type  = ? .
      display cli-name    cli-code     cli-type  cli-inn  cli-kpp  cli-address   with frame Dialog-Frame.
    end.
    else do:
      apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
    end.
    return.
  end.
  assign
    cli-name = buf_clients.obj-name
    cli-code = buf_clients.obj-code
    cli-type = buf_clients.obj-type
  .
  if buf_clients.obj-type = 'орг':U then do:
    find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error.
    if available buf_firm then
     assign
       cli-kpp = buf_firm.kpp
       cli-inn = buf_firm.inn
       cli-address = trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)
       .
  end.
  else do:
    find first buf_person no-lock where buf_person.psn-code = buf_clients.obj-code no-error.
    if available buf_person then assign  cli-address = buf_person.address   cli-inn = ""  cli-kpp = "".
  end.
  display cli-name    cli-code     cli-type  cli-inn cli-kpp  cli-address   with frame Dialog-Frame.
END.
ON LEAVE OF cli-type IN FRAME Dialog-Frame
DO:
  assign cli-type.
  if cli-type <> 'орг':U and cli-type <> 'чел':U then do:
    find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = cli-code no-error.
    if not available buf_clients then do:
      find first buf_clients no-lock where buf_clients.obj-type = 'чел':U and buf_clients.obj-code = cli-code no-error.
    end.
  end.
  else find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
  if not available buf_clients then do:
    if cli-code = 0 then assign cli-code = ? .
    if cli-code = ? then do:
      assign cli-name = ""  cli-inn = "" cli-kpp = ""  cli-address = ""  cli-code = ?  cli-type  = ? .
      display cli-name    cli-code     cli-type  cli-inn cli-kpp  cli-address   with frame Dialog-Frame.
    end.
    else do:
      apply "CHOOSE" to BUTTON-cli IN FRAME Dialog-Frame .
    end.
    return.
  end.
  assign
    cli-name = buf_clients.obj-name
    cli-code = buf_clients.obj-code
    cli-type = buf_clients.obj-type
  .
  if buf_clients.obj-type = 'орг':U then do:
    find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error.
    if available buf_firm then
      assign
       cli-kpp = buf_firm.kpp
       cli-inn = buf_firm.inn
       cli-address = trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)   .
  end.
  else do:
    find first buf_person no-lock where buf_person.psn-code = buf_clients.obj-code no-error.
    if available buf_person then assign  cli-address = buf_person.address   cli-inn = "" cli-kpp = "".
  end.
  display cli-name    cli-code     cli-type  cli-inn  cli-kpp cli-address   with frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-1 :handle
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of doc-date in frame Dialog-Frame
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
on delete-character of doc-date in frame Dialog-Frame
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
on ctrl-d of doc-date in frame Dialog-Frame
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
on ctrl-b of doc-date in frame Dialog-Frame
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
on ctrl-e of doc-date in frame Dialog-Frame
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
on ctrl-f of doc-date in frame Dialog-Frame
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
  define MENU m-ed-date13
    MENU-ITEM m-ed-date13-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date13-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date13-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date13-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if doc-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      doc-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date13 :HANDLE
      doc-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle13 as handle no-undo .
  assign
    v-label-handle13 = doc-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle13)
  then do:
    if v-label-handle13 :tooltip = ""
    or v-label-handle13 :tooltip = ?
    then do:
      assign
        v-label-handle13 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date13-1 in menu m-ed-date13 DO:
    apply "ctrl-b":U to doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date13-2 in menu m-ed-date13 DO:
    apply "ctrl-d":U to doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date13-3 in menu m-ed-date13 DO:
    apply "ctrl-e":U to doc-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date13-4 in menu m-ed-date13 DO:
    apply "ctrl-f":U to doc-date in frame Dialog-Frame .
  END.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of in-date in frame Dialog-Frame
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
on delete-character of in-date in frame Dialog-Frame
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
on ctrl-d of in-date in frame Dialog-Frame
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
on ctrl-b of in-date in frame Dialog-Frame
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
on ctrl-e of in-date in frame Dialog-Frame
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
on ctrl-f of in-date in frame Dialog-Frame
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
  define MENU m-ed-date15
    MENU-ITEM m-ed-date15-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date15-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date15-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date15-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if in-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      in-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date15 :HANDLE
      in-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle15 as handle no-undo .
  assign
    v-label-handle15 = in-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle15)
  then do:
    if v-label-handle15 :tooltip = ""
    or v-label-handle15 :tooltip = ?
    then do:
      assign
        v-label-handle15 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date15-1 in menu m-ed-date15 DO:
    apply "ctrl-b":U to in-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date15-2 in menu m-ed-date15 DO:
    apply "ctrl-d":U to in-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date15-3 in menu m-ed-date15 DO:
    apply "ctrl-e":U to in-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date15-4 in menu m-ed-date15 DO:
    apply "ctrl-f":U to in-date in frame Dialog-Frame .
  END.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of pay-date in frame Dialog-Frame
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
on delete-character of pay-date in frame Dialog-Frame
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
on ctrl-d of pay-date in frame Dialog-Frame
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
on ctrl-b of pay-date in frame Dialog-Frame
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
on ctrl-e of pay-date in frame Dialog-Frame
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
on ctrl-f of pay-date in frame Dialog-Frame
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
  define MENU m-ed-date17
    MENU-ITEM m-ed-date17-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date17-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date17-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date17-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if pay-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      pay-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date17 :HANDLE
      pay-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle17 as handle no-undo .
  assign
    v-label-handle17 = pay-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle17)
  then do:
    if v-label-handle17 :tooltip = ""
    or v-label-handle17 :tooltip = ?
    then do:
      assign
        v-label-handle17 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date17-1 in menu m-ed-date17 DO:
    apply "ctrl-b":U to pay-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date17-2 in menu m-ed-date17 DO:
    apply "ctrl-d":U to pay-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date17-3 in menu m-ed-date17 DO:
    apply "ctrl-e":U to pay-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date17-4 in menu m-ed-date17 DO:
    apply "ctrl-f":U to pay-date in frame Dialog-Frame .
  END.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  temp-line.gds-name:resizable in browse BROWSE-1   = true .
  own-kpp:label = "КПП" .
  cli-kpp:label = "КПП" .
  run enable_ui .
  run go-proc no-error.
  if error-status:error then return no-apply.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY doc-code book-code doc-date ext-doc-type status_ contract-code
          own-name own-address own-inn own-KPP cli-code cli-type cli-name
          cli-inn cli-KPP cli-address Gruz-otprav Gruz-poluch gtd country
          pay-date in-date PS plat-ras-doc VAT-10-rubl sum-rubl VAT-20-rubl
      WITH FRAME Dialog-Frame.
  ENABLE b-OK b-exit B-sel-contract B-sel-docum b-hist B-Help doc-code
         book-code doc-date ext-doc-type status_ contract-code BUTTON-contr
         own-name own-address own-inn own-KPP cli-code cli-type BUTTON-cli
         cli-name cli-inn cli-KPP cli-address Gruz-otprav Gruz-poluch gtd
         country pay-date in-date PS plat-ras-doc B-add b-chg B-del BROWSE-1
         VAT-10-rubl sum-rubl VAT-20-rubl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-1 FOR EACH temp-line WHERE TRUE  NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE go-proc :
do
on error undo, return error
on stop undo, return error
:
  case ref-mode :
    when 'ДОБАВЛЕНИЕ':U then do:
      assign frame Dialog-Frame:title =  "Новый счет-фактура  БД " + string(p-db-num) + "  Фирма: (" + string(p-host-code) + ")":U + " опер. " + usrfulnf(v-cntxt-userid) .
      find first buf_clients no-lock where buf_clients.obj-type = 'орг':U and buf_clients.obj-code = p-host-code no-error .
      find first buf_firm no-lock where buf_firm.firm-code = p-host-code no-error .
      assign
        own-name    = buf_clients.obj-name
        own-inn     = buf_firm.inn
        own-kpp     = buf_firm.kpp
        own-address = trim(buf_firm.addres1) + " " + trim(buf_firm.addres2)
        Gruz-otprav = "он же"
        Gruz-poluch   = substitute( "&1 &2 &3", caps( own-name ),  buf_firm.post-addr1 )
      .
      DISABLE  doc-code ext-doc-type status_ contract-code
       b-sel-contract b-sel-docum
      WITH FRAME Dialog-Frame.
    end.
    when 'ИЗМЕНЕНИЕ':U or when 'ПРОСМОТР':U then do:
      find first buf_schet-fact-doc no-lock where buf_schet-fact-doc.doc-code = p-doc-code and  buf_schet-fact-doc.db-num = p-db-num no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      assign frame Dialog-Frame:title =  "Счет-фактура № " + string(buf_schet-fact-doc.doc-code) + "  БД " + string(buf_schet-fact-doc.db-num) + "  Фирма: (" + string(buf_schet-fact-doc.host-code) + ")":U .
      if buf_schet-fact-doc.ext-doc-type <> "" then
        assign frame Dialog-Frame:title = frame Dialog-Frame:title + " создан по " + buf_schet-fact-doc.ext-doc-type + " " + buf_schet-fact-doc.in-doc-code + " от " + string(buf_schet-fact-doc.in-doc-date,"99/99/9999") .
      for each ub.schet-fact-line no-lock
        where ub.schet-fact-line.doc-code  = p-doc-code
          and ub.schet-fact-line.db-num = p-db-num
        :
        find first buf_goods no-lock where buf_goods.gds-code = ub.schet-fact-line.gds-code no-error .
        create temp-line .
        buffer-copy ub.schet-fact-line to temp-line
        assign
          temp-line.artic = if available buf_goods then buf_goods.artic else ""
        .
      end.
      assign
        contract-code     = buf_schet-fact-doc.contract-code
        doc-code          = buf_schet-fact-doc.doc-code
        book-code         = buf_schet-fact-doc.book-code
        doc-date          = buf_schet-fact-doc.doc-date
        own-name          = buf_schet-fact-doc.own-name
        own-inn           = buf_schet-fact-doc.own-inn
        own-kpp           = buf_schet-fact-doc.own-kpp
        own-address       = buf_schet-fact-doc.own-address
        cli-code          = buf_schet-fact-doc.cli-code
        cli-type          = buf_schet-fact-doc.cli-type
        cli-name          = buf_schet-fact-doc.cli-name
        cli-address       = buf_schet-fact-doc.cli-address
        cli-inn           = buf_schet-fact-doc.cli-inn
        cli-kpp           = buf_schet-fact-doc.cli-kpp
        ext-doc-type      = buf_schet-fact-doc.ext-doc-type
        status_           = buf_schet-fact-doc.status_
        Gruz-otprav       = buf_schet-fact-doc.Gruz-otprav
        Gruz-poluch       = buf_schet-fact-doc.Gruz-poluch
        gtd               = buf_schet-fact-doc.gtd
        country           = buf_schet-fact-doc.country
        plat-ras-doc      = buf_schet-fact-doc.plat-ras-doc
        pay-date          = buf_schet-fact-doc.pay-date
        in-date           = buf_schet-fact-doc.in-date
        VAT-20-rubl       = buf_schet-fact-doc.VAT-20-rubl
        sum-rubl          = buf_schet-fact-doc.sum-rubl
        VAT-10-rubl       = buf_schet-fact-doc.VAT-10-rubl
        PS                = buf_schet-fact-doc.PS
        s-no-VAT          = buf_schet-fact-doc.sum-VAT-no-rubl
        s-0-VAT           = buf_schet-fact-doc.sum-VAT-0-rubl
        s-10-VAT          = buf_schet-fact-doc.sum-VAT-10-rubl
        s-20-VAT          = buf_schet-fact-doc.sum-VAT-20-rubl
      .
      if ref-mode = 'ПРОСМОТР':U then do:
        b-OK:label in frame Dialog-Frame = "&Выход" .
        b-exit:visible = no .
        B-add:visible = no .
        b-chg:visible = no .
        B-del:visible = no .
        DISABLE  doc-code book-code doc-date ext-doc-type status_ contract-code own-name own-inn own-kpp own-address cli-code cli-type
           cli-name cli-inn cli-kpp cli-address Gruz-otprav Gruz-poluch gtd country  plat-ras-doc
           pay-date in-date PS sum-rubl VAT-10-rubl VAT-20-rubl BUTTON-cli BUTTON-contr
        WITH FRAME Dialog-Frame.
      end.
      else do:
        if buf_schet-fact-doc.office = no then do:
          B-add:visible = no .
          b-chg:visible = no .
          B-del:visible = no .
        end.
        if contract-code > 0 then DISABLE BUTTON-contr WITH FRAME Dialog-Frame.
        if v-cntxt-db-num = 0 and buf_schet-fact-doc.db-num > 0 then do:
          B-add:visible = no .
          b-chg:visible = no .
          B-del:visible = no .
          DISABLE  doc-code doc-date ext-doc-type status_ contract-code own-name own-inn own-kpp own-address cli-code cli-type
             cli-name cli-inn cli-kpp cli-address Gruz-otprav Gruz-poluch gtd country  plat-ras-doc
             pay-date in-date sum-rubl VAT-10-rubl VAT-20-rubl BUTTON-cli BUTTON-contr
          WITH FRAME Dialog-Frame.
        end.
        if buf_schet-fact-doc.ext-doc-type <> "" then DISABLE BUTTON-contr WITH FRAME Dialog-Frame.
        DISABLE  doc-code ext-doc-type status_ contract-code cli-code cli-type
            sum-rubl VAT-10-rubl VAT-20-rubl BUTTON-cli
        WITH FRAME Dialog-Frame.
      end.
      enable b-sel-contract b-sel-docum with frame Dialog-Frame .
      if buf_schet-fact-doc.in-doc-code = "" and buf_schet-fact-doc.in-doc-code = ? then hide b-sel-docum in frame Dialog-Frame .
      if buf_schet-fact-doc.status_ = 'факт':U then do:
          B-add:visible = no .
          b-chg:visible = no .
          B-del:visible = no .
          DISABLE  doc-code doc-date ext-doc-type status_ contract-code own-name own-inn own-kpp own-address cli-code cli-type
             cli-name cli-inn cli-kpp cli-address Gruz-otprav Gruz-poluch gtd country  plat-ras-doc
             pay-date in-date sum-rubl VAT-10-rubl VAT-20-rubl BUTTON-cli BUTTON-contr
          WITH FRAME Dialog-Frame.
      end.
    end.
    when "history" then do:
        B-add:visible = no .
        b-chg:visible = no .
        B-del:visible = no .
      find first buf_c-schet-fact-doc no-lock
        where buf_c-schet-fact-doc.doc-code = p-doc-code
          and buf_c-schet-fact-doc.db-num   = p-db-num
          and buf_c-schet-fact-doc.chip-num = p-chip-num
        .
      for each ub.c-schet-fact-line no-lock
        where ub.c-schet-fact-line.doc-code  = p-doc-code
          and ub.c-schet-fact-line.db-num    = p-db-num
        :
        create temp-line .
        buffer-copy ub.c-schet-fact-line except chip-num  corr-user-db-num  corr-user-name  corr-date  corr-time to temp-line .
      end.
      assign
        contract-code     = buf_c-schet-fact-doc.contract-code
        doc-code          = buf_c-schet-fact-doc.doc-code
        book-code         = buf_c-schet-fact-doc.book-code
        doc-date          = buf_c-schet-fact-doc.doc-date
        own-name          = buf_c-schet-fact-doc.own-name
        own-inn           = buf_c-schet-fact-doc.own-inn
        own-kpp           = buf_c-schet-fact-doc.own-kpp
        own-address       = buf_c-schet-fact-doc.own-address
        cli-code          = buf_c-schet-fact-doc.cli-code
        cli-type          = buf_c-schet-fact-doc.cli-type
        cli-name          = buf_c-schet-fact-doc.cli-name
        cli-address       = buf_c-schet-fact-doc.cli-address
        cli-inn           = buf_c-schet-fact-doc.cli-inn
        cli-kpp           = buf_c-schet-fact-doc.cli-kpp
        ext-doc-type      = buf_c-schet-fact-doc.ext-doc-type
        status_           = buf_c-schet-fact-doc.status_
        Gruz-otprav       = buf_c-schet-fact-doc.Gruz-otprav
        Gruz-poluch       = buf_c-schet-fact-doc.Gruz-poluch
        gtd               = buf_c-schet-fact-doc.gtd
        country           = buf_c-schet-fact-doc.country
        plat-ras-doc       = buf_c-schet-fact-doc.plat-ras-doc
        pay-date          = buf_c-schet-fact-doc.pay-date
        in-date           = buf_c-schet-fact-doc.in-date
        VAT-20-rubl       = buf_c-schet-fact-doc.VAT-20-rubl
        sum-rubl          = buf_c-schet-fact-doc.sum-rubl
        VAT-10-rubl       = buf_c-schet-fact-doc.VAT-10-rubl
        PS                = buf_c-schet-fact-doc.PS
      .
      b-OK:label in frame Dialog-Frame = "&Выход" .
      b-exit:visible = no .
      DISABLE  doc-code book-code doc-date ext-doc-type status_ contract-code own-name own-inn own-kpp own-address cli-code cli-type
           cli-name cli-inn cli-kpp cli-address Gruz-otprav Gruz-poluch gtd country  plat-ras-doc
           pay-date in-date PS sum-rubl VAT-10-rubl VAT-20-rubl BUTTON-cli BUTTON-contr
      WITH FRAME Dialog-Frame.
    end.
  end.
  display doc-code book-code doc-date ext-doc-type status_ contract-code own-name own-address own-inn own-KPP cli-code cli-type cli-name cli-inn cli-KPP cli-address Gruz-otprav Gruz-poluch gtd country pay-date in-date PS plat-ras-doc VAT-10-rubl sum-rubl VAT-20-rubl with frame Dialog-Frame.
  OPEN QUERY BROWSE-1 FOR EACH temp-line INDEXED-REPOSITION.
end.
END PROCEDURE.
PROCEDURE proc-calc :
do on error undo, return error return-value :
    define buffer b_temp-line for temp-line.
    assign
      sum-rubl    = 0
      s-no-VAT    = 0
      VAT-10-rubl = 0
      s-10-VAT    = 0
      VAT-20-rubl = 0
      s-20-VAT    = 0
    .
    for each b_temp-line :
      assign sum-rubl = sum-rubl + b_temp-line.sum-rubl-VAT .
      if b_temp-line.VAT-pc < 1 then do:
        assign s-no-VAT = s-no-VAT + b_temp-line.sum-rubl - b_temp-line.VAT-rubl .
      end.
      else do:
        if b_temp-line.VAT-pc < 11 then
          assign
            VAT-10-rubl = VAT-10-rubl + b_temp-line.VAT-rubl
            s-10-VAT    = s-10-VAT + b_temp-line.sum-rubl - b_temp-line.VAT-rubl
        .
        else
          assign
            VAT-20-rubl = VAT-20-rubl + b_temp-line.VAT-rubl
            s-20-VAT = s-20-VAT + b_temp-line.sum-rubl - b_temp-line.VAT-rubl
          .
      end.
    end.
  end.
end procedure.
