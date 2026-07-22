DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_dis-card FOR ub.dis-card.
DEFINE BUFFER X_dis-host FOR ub.dis-host.
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
define input parameter p-list-mode as character no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-first-main-card   like ub.dis-card.first-main-card no-undo .
define input parameter  cli-recid  as recid no-undo .
define output parameter rid-list    as  char no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник дисконтных карт" .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dcard-algo-field-name as character no-undo extent 3 init [
 'd-pcnt':U
,'cash-d-pcnt':U
,'pcnt-kat':U].
define variable algo-field-abbr as character no-undo extent 3 init [
 'ITEM%':U
,'TOTAL%':U
,'CATEG':U].
FUNCTION dct-algo-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + chr(47) +
             string(Month(p-date), "99":U) + chr(47) +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
function dct-algo-string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION dct-algo-get-sum-id-from-DT-CODE returns character ( input p-DT-CODE as integer):
define buffer buf_prop-ref for ub.prop-ref.
find first buf_prop-ref no-lock where
          buf_prop-ref.DT-CODE = p-DT-CODE no-error.
if not available buf_prop-ref then do:
  return chr(63).
end.
return buf_prop-ref.sum-id.
END FUNCTION.
FUNCTION dct-algo-get-description-sum-id returns character ( input p-dt-code as integer):
define variable v-des as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
find first buf_prop-ref no-lock where
          buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then do:
  return substitute("Срез/итог по ДК c кодом &1 - срез не найден", p-dt-code).
end.
find first buf_prop-head no-lock where
        buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error.
if not available buf_prop-head then do:
  return substitute("Срез/итог по ДК &1 c кодом &2 - неизвестное", p-dt-code, buf_prop-ref.dtm-code).
end.
assign
v-des = substitute("&1  &2 &3"
                  , buf_prop-head.prop-name
                  , buf_prop-ref.sum-id
                  , buf_prop-ref.caller_id).
return v-des.
end FUNCTION.
FUNCTION dct-algo-get-description-node-code returns character ( input p-dtm-code as integer
                                                            ,input p-dt-code as integer
                                                            ,input p-node-code as integer
                                                            ):
define variable v-des as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-map for ub.prop-map.
find first buf_prop-ref no-lock where
          buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then do:
  return substitute("Срез/итог по ДК c кодом &1 - срез не найден", p-dt-code).
end.
find first buf_prop-head no-lock where
        buf_prop-head.dtm-code = p-dtm-code no-error.
if not available buf_prop-head then do:
  return substitute("Срез/итог по ДК &1 c кодом &2 - неизвестное", p-dt-code, p-dtm-code).
end.
find first buf_prop-map no-lock where
        buf_prop-map.dtm-code = p-dtm-code
    and buf_prop-map.node-code = p-node-code no-error .
if not available buf_prop-map then do:
  return substitute("Срез/итог по ДК &1, &2.&3 - неизвестно"
                    , p-dt-code
                    , buf_prop-head.prop-label
                    , p-node-code).
end.
assign
v-des = substitute("&1.&2 &3 &4"
                  , buf_prop-head.prop-label
                  , buf_prop-map.node-label
                  , buf_prop-ref.sum-id
                  , buf_prop-ref.caller_id).
return v-des.
end FUNCTION.
function dct-algo-get-prev-sum-id RETURNS integer (
                                                    input p-dt-code as integer
                                                   ):
define variable v-dtm-code as integer no-undo .
define variable v-sum-id as character no-undo .
define variable v-caller-id as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
find first buf_prop-ref no-lock where
        buf_prop-ref.dt-code = p-dt-code no-error.
if not available buf_prop-ref then return ?.
assign
v-dtm-code = buf_prop-ref.dtm-code
v-sum-id = buf_prop-ref.sum-id.
v-caller-id = buf_prop-ref.caller_id.
find last buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = v-dtm-code
     and  buf_prop-ref.sum-id < v-sum-id
     and  buf_prop-ref.caller_id = v-caller-id
     no-error.
if available buf_prop-ref then return buf_prop-ref.dt-code.
return -1 .
END FUNCTION.
FUNCTION dct-algo-get_dcproperty-value returns logical (
                                                          input p-prop-name as character
                                                        , input p-d-card    as character
                                                        , input p-host-code as integer
                                                        , input p-obj-type  as character
                                                        , input p-obj-code  as integer
                                                        , output p-value-character as character
                                                        , output p-value-date   as date
                                                        , output p-value-integer as integer
                                                        , output p-value-decimal as decimal
                                                        , output p-value-logical as logical):
  return no.
END FUNCTION.
FUNCTION dct-algo-get_dcproperty-value-chr returns logical (
                                                          input p-d-card    as character
                                                        , input p-emitent-host-code as integer
                                                        , input p-type as character
                                                        , input p-host-code as integer
                                                        , input p-obj-type  as character
                                                        , input p-obj-code  as integer
                                                        , output p-value-chr as character):
define variable v-dt-code as integer no-undo .
define variable v-node-code as integer no-undo .
define variable v-field-name as character no-undo .
define variable v-storage-place as character no-undo .
define variable v-sum-id-value as character no-undo .
define variable v-sum-id-output as logical no-undo .
define variable v-value-chr as character no-undo .
define variable v-ii as integer no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_dis-obj for ub.dis-obj.
run get-cd-sumid in this-procedure (
                                      input p-emitent-host-code
                                     ,input p-type
                                     ,input p-host-code
                                     ,input p-obj-type
                                     ,input p-obj-code
                                     ,output v-sum-id-value
                                     ,output v-sum-id-output
                                    ) no-error.
if not v-sum-id-output then do:
  return no.
end.
do v-ii = 1 to num-entries(v-sum-id-value):
  assign
  v-storage-place = entry(1, entry(v-ii, v-sum-id-value), chr(4))
  v-dt-code = integer(entry(2, entry(v-ii, v-sum-id-value), chr(4)))
  v-node-code = integer(entry(3, entry(v-ii, v-sum-id-value), chr(4)))
  v-field-name = entry(4, entry(v-ii, v-sum-id-value), chr(4))
  no-error .
  if not error-status:error then do:
    case v-storage-place:
      when 'dis-card-property':U then do:
        find first buf_dis-card-property no-lock where
                  buf_dis-card-property.d-card = p-d-card
            and  buf_dis-card-property.host-code = p-host-code
            and  buf_dis-card-property.obj-type = p-obj-type
            and  buf_dis-card-property.obj-code = p-obj-code
            and  buf_dis-card-property.dt-code = v-dt-code
            and  buf_dis-card-property.node-code = v-node-code no-error .
        if available buf_dis-card-property then do:
          v-value-chr = buffer buf_dis-card-property:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
      when 'dis-obj':U then do:
        find first buf_dis-obj no-lock where
                  buf_dis-obj.d-card = p-d-card
            and  buf_dis-obj.obj-type = p-obj-type
            and  buf_dis-obj.obj-code = p-obj-code
            and  buf_dis-obj.dt-code = v-dt-code no-error .
        if available buf_dis-obj then do:
          v-value-chr = buffer buf_dis-obj:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
      when 'dis-host':U then do:
        find first buf_dis-host no-lock where
                  buf_dis-host.d-card = p-d-card
            and  buf_dis-host.host-code = p-host-code
            and  buf_dis-host.dt-code = v-dt-code no-error .
        if available buf_dis-host then do:
          v-value-chr = buffer buf_dis-host:handle:buffer-field(v-field-name):string-value.
        end.
        else do:
          v-value-chr = chr(63).
        end.
      end.
    end.
  end.
  p-value-chr = p-value-chr + (if v-ii = 1 then '':U else chr(44)) + v-value-chr.
end.
END FUNCTION.
FUNCTION dct-algo_custom-sent-description RETURNS CHARACTER
  ( INPUT p-custom-sent as character ) :
DEFINE VARIABLE v-storage-place AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dtm-code AS integer NO-UNDO.
DEFINE VARIABLE v-sum-id AS character NO-UNDO.
DEFINE VARIABLE v-caller-id AS character NO-UNDO.
DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-sum-id-description AS CHARACTER.
DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
IF p-custom-sent = chr(63) THEN RETURN "Не отсылать".
assign
v-storage-place = entry(1, p-custom-sent, chr(4))
v-dtm-code = integer(entry(2, p-custom-sent, chr(4)))
v-sum-id   = entry(3, p-custom-sent, chr(4))
v-caller-id = entry(4, p-custom-sent, chr(4))
v-node-code = integer(entry(5, p-custom-sent, chr(4)))
no-error .
IF ERROR-STATUS:ERROR THEN DO:
  MESSAGE
  "Не могу разобрать строку, описывающую итог"
   VIEW-AS ALERT-BOX WARNING.
  RETURN chr(63).
END.
FIND FIRST buf_prop-ref NO-LOCK WHERE
          buf_prop-ref.dtm-code = v-dtm-code
     AND  buf_prop-ref.sum-id = v-sum-id
     AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
IF NOT AVAILABLE buf_prop-ref THEN DO:
  FIND FIRST buf_prop-ref NO-LOCK WHERE
            buf_prop-ref.dtm-code = v-dtm-code
      AND  buf_prop-ref.caller_id = v-caller-id NO-ERROR.
  IF NOT AVAILABLE buf_prop-ref THEN DO:
      MESSAGE
      "Не могу разобрать строку, описывающую итог"
       VIEW-AS ALERT-BOX WARNING.
      RETURN chr(63).
   end.
end.
ASSIGN
v-sum-id-description =  dct-algo-get-description-node-code ( v-dtm-code
                                                       ,buf_prop-ref.dt-code
                                                       ,v-node-code).
RETURN v-sum-id-description.
END FUNCTION.
FUNCTION one-base-cur-for-objs  returns logical (output p-glob-curr-code as integer):
define variable v-glob-val as logical no-undo init yes.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
assign
p-glob-curr-code =  -1
.
FOR EACH buf_sysconf NO-LOCK,
    first buf_clients no-lock where
         buf_clients.host-code = buf_sysconf.host-code:
    if p-glob-curr-code = -1 then
    assign
    p-glob-curr-code = buf_sysconf.base-code
    .
    else if p-glob-curr-code <> buf_sysconf.base-code then do:
        assign
        v-glob-val = no
        p-glob-curr-code = ?
        .
        LEAVE.
    end.
END.
return v-glob-val.
END FUNCTION.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable log-res as log no-undo.
define variable choice as log no-undo.
define variable ri-str  as char no-undo.
define variable ri          as      recid   no-undo     init ? .
define buffer b_clients for ub.clients.
define buffer b-d-c for ub.dis-card .
define variable filter-point-name as character no-undo .
define variable filter-point-name0 as character no-undo init "Дисконтные_карты" .
define variable filter-point as character no-undo .
define variable filter-point0 as character no-undo init "discards" .
define variable status-type as char no-undo.
define variable new-type as char no-undo init "".
define variable glob-val as logical no-undo init yes.
define variable v-glob-curr-code like ub.currency.curr-code no-undo .
define variable dopi as integer no-undo init -1.
define variable hist-option as character no-undo.
define variable add-option as character no-undo .
define variable chk-option as character no-undo .
define variable LOOKUP-option as character no-undo .
define variable obj-d-pcnt like ub.dis-card.d-pcnt no-undo.
define variable obj-cash-d-pcnt like ub.dis-card.cash-d-pcnt no-undo.
define variable v-is-dc as character no-undo .
define variable v-is-ef as character no-undo .
define variable v-conf-type as character no-undo .
define variable attr-option as character no-undo .
define variable prop-option as character no-undo .
define variable disc-option as character no-undo .
define variable glog as logical no-undo .
define variable v-host-name as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
DEFINE VARIABLE v-cli-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cli-type-code AS CHARACTER NO-UNDO.
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-initial-height as decimal no-undo .
define buffer pos_dis-card for ub.dis-card.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-dpcn RETURNS CHARACTER (
     input p-d-card as character
    ,input p-emitent-host-code as integer
    ,input p-type as character
    ,input parhost-code as integer
    ,input parobj-type as character
    ,input parobj-code as integer
    ,input p-node-code as integer
    ,input p-d-pcnt as decimal
    ,input p-cash-d-pcnt as decimal
    ,input p-category as integer
    ) :
define buffer buf_dis-card-type for ub.dis-card-type.
define variable loc-d-v as decimal no-undo init ?.
define variable v-discnt-role as character no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
find first buf_dis-card-type no-lock where
          buf_dis-card-type.type = p-type
      and buf_dis-card-type.emitent-host-code = p-emitent-host-code
      and buf_dis-card-type.host-code = 0
      and buf_dis-card-type.obj-type = '':U
      and buf_dis-card-type.obj-code = 0 no-error.
if available buf_dis-card-type then do:
  case p-node-code:
    when 1 then do:
      assign
      v-discnt-role = 'def-pcnt':U .
    end.
    when 2 then do:
      assign
      v-discnt-role = 'def-cash-pcnt':U.
    end.
    when 3 then do:
      assign
      v-discnt-role = 'def-categ':U.
    end.
  end case.
  if buf_dis-card-type.d-pcnt-byshop then do:
   find first buf_dis-card-property no-lock where
             buf_dis-card-property.d-card = p-d-card
         and buf_dis-card-property.dtm-code = 26
         and buf_dis-card-property.host-code = parhost-code
         and buf_dis-card-property.obj-type = parobj-type
         and buf_dis-card-property.obj-code = parobj-code
         and buf_dis-card-property.node-code = p-node-code no-error.
   if available buf_dis-card-property then do:
     if v-discnt-role = 'def-categ':U then do:
       assign
       loc-d-v = buf_dis-card-property.property-value-integer.
     end.
     else do:
       assign
       loc-d-v = buf_dis-card-property.property-value-decimal.
     end.
   end.
   if loc-d-v = ? then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  p-type
  ,input  p-emitent-host-code
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,input  v-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.d-card = p-d-card
            and buf_dis-card-property.dtm-code = 26
            and buf_dis-card-property.host-code = parhost-code
            and buf_dis-card-property.obj-type = ''
            and buf_dis-card-property.obj-code = 0
            and buf_dis-card-property.node-code = p-node-code no-error.
      if available buf_dis-card-property then do:
        if v-discnt-role = 'def-categ':U then do:
          assign
          loc-d-v = buf_dis-card-property.property-value-integer.
        end.
        else do:
          assign
          loc-d-v = buf_dis-card-property.property-value-decimal.
        end.
      end.
    end.
    if loc-d-v = ? then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  p-type
  ,input  p-emitent-host-code
  ,input  parhost-code
  ,input  ''
  ,input  0
  ,input  v-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      case v-discnt-role:
        when 'def-categ':U then do:
          loc-d-v = p-category.
        end.
        when 'def-pcnt':U then do:
          loc-d-v = p-d-pcnt.
        end.
        when 'def-cash-pcnt':U then do:
          loc-d-v = p-cash-d-pcnt.
        end.
      end case.
    end.
    if v-discnt-role = 'def-categ':U then do:
      return substitute("(i) &1", string(loc-d-v, ">>>9")).
    end.
    else do:
      return substitute("(i) &1", string(loc-d-v, "->9.99%")).
    end.
  end.
end.
else do:
 return "ОШИБКА-НЕТ ТИПА".
end.
case v-discnt-role:
  when 'def-categ':U then do:
     loc-d-v = p-category.
     return string(loc-d-v, ">>>9").
  end.
  when 'def-pcnt':U then do:
    loc-d-v = p-d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
  when 'def-cash-pcnt':U then do:
    loc-d-v = p-cash-d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
end case.
END FUNCTION.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable num-chk as integer no-undo.
define variable gds-sum as decimal no-undo.
define variable disc-sum as decimal no-undo.
define variable netto-sum as decimal no-undo.
define variable pay-sum as decimal no-undo.
define variable credit-sum as decimal no-undo.
define variable saldo-sum as decimal no-undo.
define variable gds-sum-ch as char no-undo.
define variable disc-sum-ch as char no-undo.
define variable netto-sum-ch as char no-undo.
define variable pay-sum-ch as char no-undo.
define variable credit-sum-ch as char no-undo.
define variable pravo as logical no-undo.
define variable smart-pravo as logical no-undo .
FUNCTION get-cli-name RETURNS CHARACTER
  (  input p-cli-type as character, input p-cli-code as integer ) :
define buffer buf_clients for ub.clients.
find first buf_clients no-lock where buf_clients.obj-type = p-cli-type
and buf_clients.obj-code = p-cli-code no-error.
if available buf_clients then return buf_clients.obj-name.
RETURN (p-cli-type + string(p-cli-code)).
END FUNCTION.
FUNCTION Get-num-chk RETURNS CHARACTER(input rs-val as character
                                     , input p-pravo as logical
                                     , buffer buf_dis-card for ub.dis-card
                                     , input p-db-num as integer
                                     ):
DEFINE variable num-chk-ch as char no-undo.
define variable loc-smart-pravo as logical no-undo .
define buffer buf_dis-host for ub.dis-host.
define buffer buf_hist-nws-option for ub.hist-nws-option.
  if NOT p-pravo then do:
      assign
      num-chk = 0
      gds-sum-ch = ""
      disc-sum-ch = ""
      netto-sum-ch = ""
      pay-sum-ch = ""
      credit-sum-ch = ""
      .
      return "Нет прав".
  end.
  IF not avail buf_dis-card then do:
      assign
      num-chk = 0
      gds-sum-ch = ""
      disc-sum-ch = ""
      netto-sum-ch = ""
      pay-sum-ch = ""
      credit-sum-ch = ""
      .
      return "".
  end.
  assign
  num-chk = 0
  gds-sum = 0
  disc-sum = 0
  netto-sum = 0
  pay-sum = 0
  credit-sum = 0
  .
  if p-db-num > 0 then do:
    find first buf_HIST-NWS-OPTION WHERE
      buf_HIST-NWS-OPTION.db-num = 0
      and buf_hist-nws-option.table-name = 'dis-host':U
      and buf_hist-nws-option.host-code = buf_dis-card.emitent-host-code
      and buf_hist-nws-option.obj-type = '':U
      and buf_hist-nws-option.obj-code = 0
      and buf_hist-nws-option.key#_one = 1
      and buf_hist-nws-option.charkey_one = buf_dis-card.type
      and buf_hist-nws-option.subject-group = 'c-dc-hist':U NO-ERROR.
    if available buf_hist-nws-option
    and buf_hist-nws-option.smart-nws >= 0 then loc-smart-pravo = yes.
    if loc-smart-pravo then do:
      assign
      num-chk = ?
      gds-sum = ?
      disc-sum = ?
      netto-sum = ?
      pay-sum = ?
      credit-sum = ?
      .
      return "".
    end.
  end.
  find first buf_Dis-host no-lock where
            buf_dis-host.host-code = buf_Dis-card.emitent-host-code
        and buf_dis-host.d-card = buf_Dis-card.d-card
        and buf_Dis-host.dt-code = 0 no-error.
  if not available buf_Dis-host then return "".
  IF RS-val = 'rubl':U then do:
    assign
    num-chk = buf_dis-host.num-chk
    gds-sum = buf_dis-host.gds-tot-rubl
    disc-sum = buf_dis-host.gds-dis-rubl
    netto-sum = gds-sum - disc-sum
    pay-sum = buf_dis-host.pay-tot-rubl
    credit-sum = netto-sum - pay-sum
    saldo-sum = buf_dis-card.saldo-rubl.
  end.
  else do:
    assign
    num-chk = buf_dis-host.num-chk
    gds-sum = buf_dis-host.gds-tot-base
    disc-sum = buf_dis-host.gds-dis-base
    netto-sum = gds-sum - disc-sum
    pay-sum = buf_dis-host.pay-tot-base
    credit-sum = netto-sum - pay-sum
    saldo-sum = buf_dis-card.saldo-base.
  end.
  assign
  gds-sum-ch = string(gds-sum, "->>>,>>>,>>9.99")
  disc-sum-ch = string(disc-sum, "->>>,>>>,>>9.99")
  netto-sum-ch = string(netto-sum, "->>>,>>>,>>9.99")
  pay-sum-ch = string(pay-sum, "->>>,>>>,>>9.99")
  num-chk-ch = string(num-chk, "->>>>>>>9")
  credit-sum-ch = string(credit-sum, "->>>,>>>,>>9.99")
  .
  RETURN num-chk-ch.
END FUNCTION.
FUNCTION Get-num-chk-l RETURNS integer(input rs-val as character
                                     , input p-pravo as logical
                                     , input p-num-chk as integer
                                     , input p-type as character
                                     , input p-emitent-host-code as integer
                                     , input p-db-num as integer
                                     ):
define buffer buf_hist-nws-option for ub.hist-nws-option.
  smart-pravo = no.
  if NOT p-pravo then do:
    return 0.
  end.
  if p-db-num > 0 then do:
    find first buf_HIST-NWS-OPTION WHERE
      buf_HIST-NWS-OPTION.db-num = 0
      and buf_hist-nws-option.table-name = 'dis-host':U
      and buf_hist-nws-option.host-code = p-emitent-host-code
      and buf_hist-nws-option.obj-type = '':U
      and buf_hist-nws-option.obj-code = 0
      and buf_hist-nws-option.key#_one = 1
      and buf_hist-nws-option.charkey_one = p-type
      and buf_hist-nws-option.subject-group = 'c-dc-hist':U NO-ERROR.
    if available buf_hist-nws-option
    and buf_hist-nws-option.smart-nws >= 0 then smart-pravo = yes.
    else smart-pravo = no.
  end.
  if smart-pravo then return ?.
  return p-num-chk.
end FUNCTION.
FUNCTION Get-gds-sum-l RETURNS decimal(
                                       input rs-val as character
                                     , input p-pravo as logical
                                     , input p-gds-tot-rubl as decimal
                                     , input p-gds-tot-base as decimal):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = 'rubl':U then
  return p-gds-tot-rubl.
  else
  return p-gds-tot-base.
end FUNCTION.
FUNCTION Get-disc-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , input p-gds-dis-rubl as decimal
                                     , input p-gds-dis-base as decimal):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = 'rubl':U then
  return p-gds-dis-rubl.
  else
  return p-gds-dis-base.
end FUNCTION.
FUNCTION Get-netto-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , input p-gds-tot-rubl as decimal
                                     , input p-gds-tot-base as decimal
                                     , input p-gds-dis-rubl as decimal
                                     , input p-gds-dis-base as decimal):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = 'rubl':U then
  return (p-gds-tot-rubl - p-gds-dis-rubl).
  else
  return (p-gds-tot-base - p-gds-dis-base).
end FUNCTION.
FUNCTION Get-pay-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , buffer buf_dis-host for ub.dis-host):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = 'rubl':U then
  return buf_dis-host.pay-tot-rubl.
  else
  return buf_dis-host.pay-tot-base.
end FUNCTION.
FUNCTION Get-credit-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , input p-gds-tot-rubl as decimal
                                     , input p-gds-tot-base as decimal
                                     , input p-gds-dis-rubl as decimal
                                     , input p-gds-dis-base as decimal
                                     , input p-pay-tot-rubl as decimal
                                     , input p-pay-tot-base as decimal):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = 'rubl':U then
  return (p-gds-tot-rubl - p-gds-dis-rubl - p-pay-tot-rubl).
  else
  return (p-gds-tot-base - p-gds-dis-base - p-pay-tot-base).
end FUNCTION.
FUNCTION Get-saldo-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , buffer buf_dis-card for ub.dis-card):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = 'rubl':U then
  return buf_dis-card.saldo-rubl.
  else
  return buf_dis-card.saldo-base.
end FUNCTION.
DEFINE MENU MENU-b-add
       MENU-ITEM m_glob         LABEL "Глобальная"
       MENU-ITEM m_company      LABEL "По фирме"
       MENU-ITEM m_cli-sourced  LABEL "Перевыпустить"
       MENU-ITEM m_cli-subsid   LABEL "Дополнительная"
       RULE
       MENU-ITEM m_dct-client   LABEL "Клиент-Счет"   .
DEFINE MENU MENU-b-add-copy
       MENU-ITEM m_add          LABEL "Добавить"
       MENU-ITEM m_copy         LABEL "Копировать"
       MENU-ITEM m_sourced      LABEL "Перевыпустить"
       MENU-ITEM m_subsid       LABEL "Дополнительная".
DEFINE MENU MENU-b-chk
       MENU-ITEM m_chk-doc      LABEL "Чеки"
       MENU-ITEM m_ef-cd-trans  LABEL "Транзакции EasyFuel".
DEFINE MENU MENU-b-disc
       MENU-ITEM m_lookup-disc  LABEL "Просмотр"
       MENU-ITEM m_update-disc  LABEL "Изменение"     .
DEFINE MENU MENU-b-history
       MENU-ITEM m_c-dc-hist    LABEL "По одной карте"
       MENU-ITEM m_c-dc-hist_plus LABEL "С учетом перевыпуска карт".
DEFINE MENU MENU-b-lkp
       MENU-ITEM m_one          LABEL "Карта"
       MENU-ITEM m_first-main-card LABEL "Пул карт"      .
DEFINE MENU MENU-B-prop
       MENU-ITEM m_lookup-prop  LABEL "Просмотр"
       MENU-ITEM m_update-prop  LABEL "Изменение"     .
DEFINE MENU POPUP-MENU-b-del
       MENU-ITEM m-curr         LABEL "Текущий"
       MENU-ITEM m-del          LABEL "Удалить"
       MENU-ITEM m-block        LABEL "Блокирован"    .
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chk
     LABEL "Ч&еки"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Статус"
     SIZE 10 BY 1.
DEFINE BUTTON b-disc
     LABEL "&Скидки"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-history
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-payment
     LABEL "Плате&жи"
     SIZE 10 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 3 BY 1.
DEFINE BUTTON B-prop
     LABEL "Свойства"
     SIZE 10 BY 1.
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-sl
     LABEL "Стопл-ты"
     SIZE 10 BY 1.
DEFINE BUTTON B-type
     LABEL "Тип &карты"
     SIZE 10 BY 1.
DEFINE BUTTON b-view
     LABEL "&Архив"
     SIZE 10 BY 1.
DEFINE BUTTON b_clientsi
     LABEL "&Клиент"
     SIZE 10 BY 1.
DEFINE VARIABLE F-credit-sum AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "В кредит"
      VIEW-AS TEXT
     SIZE 16.6 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE F-disc-sum AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Скидки"
      VIEW-AS TEXT
     SIZE 16.6 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE F-gds-sum AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Покупки"
      VIEW-AS TEXT
     SIZE 16.6 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE F-netto-sum AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Нетто"
      VIEW-AS TEXT
     SIZE 16.6 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE F-num-chk AS INTEGER FORMAT "->>>>>9":U INITIAL 0
     LABEL "Чеков"
      VIEW-AS TEXT
     SIZE 8 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE F-pay-sum AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Платежи"
      VIEW-AS TEXT
     SIZE 16.6 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.
DEFINE VARIABLE F-saldo-sum AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Баланс"
      VIEW-AS TEXT
     SIZE 16.6 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4.8 BY .77
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE SPattern AS CHARACTER FORMAT "X(256)":U
     LABEL "Поиск"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE t-totals AS CHARACTER FORMAT "X(256)":U INITIAL "Итоги по всем картам клиента"
      VIEW-AS TEXT
     SIZE 55 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE RS-global AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1",
"2", "2",
"3", "3"
     SIZE 37 BY .93 NO-UNDO.
DEFINE VARIABLE RS-SEARCH AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", "1",
"2", "2",
"3", "3"
     SIZE 26.9 BY 1 NO-UNDO.
DEFINE VARIABLE RS-val AS CHARACTER INITIAL "rubl"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "abbr_rubli_firstshift", "rubl",
"Баз.вал.", "base"
     SIZE 19.6 BY .67 NO-UNDO.
DEFINE QUERY br-discard FOR
                X_dis-card,
                X_clients,
                X_dis-host SCROLLING.
DEFINE BROWSE br-discard
  QUERY br-discard NO-LOCK DISPLAY
      (mark-string ( INPUT RECID( X_dis-card), INPUT rid-list)) COLUMN-LABEL '*' FORMAT "x(1)":U
X_dis-card.d-card COLUMN-LABEL 'Номер' FORMAT "X(19)":U
X_clients.obj-name @ V-CLI-NAME COLUMN-LABEL 'Название/ФИО' FORMAT "x(29)":U
X_dis-card.issue-code COLUMN-LABEL 'Маг-н' FORMAT "99999":U
X_dis-card.issue-date COLUMN-LABEL 'Выдано' FORMAT "99/99/9999":U
get-dpcn(X_dis-card.d-card, X_dis-card.emitent-host-code, X_dis-card.type, input p-curr-host-code, input p-curr-obj-type, input p-curr-obj-code, input 1,  X_dis-card.d-pcnt, X_dis-card.cash-d-pcnt, X_dis-card.category) COLUMN-LABEL 'Скидка на!товар' FORMAT "X(11)":U
X_dis-card.status_ COLUMN-LABEL 'Статус' FORMAT "X(4)":U
X_dis-card.emitent-host-code COLUMN-LABEL 'Фирма' FORMAT ">>>>>99999":U
X_dis-card.sourceD-card COLUMN-LABEL 'Перевыпуск' FORMAT "X(19)":U
X_dis-card.overissue-num COLUMN-LABEL '#' FORMAT ">9":U
X_dis-card.first-main-card COLUMN-LABEL 'Перв.осн.' FORMAT "X(19)":U
X_dis-card.valid-date COLUMN-LABEL 'Действ.по' FORMAT "99/99/9999":U
X_dis-card.type COLUMN-LABEL 'Тип' FORMAT "X(8)":U
X_dis-card.credit-card COLUMN-LABEL 'Кред.?' FORMAT "+/":U
X_dis-card.lim-kr COLUMN-LABEL 'Лимит кредита!(в вал.продаж)' FORMAT ">>>,>>>,>>>,>>9.99":U
(X_dis-card.cli-type + ' ' + STRING (X_dis-card.cli-code)) @ V-CLI-TYPE-CODE COLUMN-LABEL 'Клиент' FORMAT "X(12)":U
Get-num-chk-l(input rs-val, input pravo, input X_dis-host.num-chk, input X_dis-card.type, input X_dis-card.emitent-host-code, input v-cntxt-db-num) COLUMN-LABEL 'Кол-во!чеков' FORMAT "->>>>>>>>>>>9"
Get-gds-sum-l(input rs-val, input pravo, X_dis-host.gds-tot-rubl, X_dis-host.gds-tot-base) COLUMN-LABEL 'Сумма покупок' FORMAT "->>,>>>,>>>,>>9.99"
Get-disc-sum-l(input rs-val, input pravo, X_dis-host.gds-dis-rubl, X_dis-host.gds-dis-base) COLUMN-LABEL 'Скидка' FORMAT "->>>,>>>,>>9.99"
Get-netto-sum-l(input rs-val, input pravo, X_dis-host.gds-tot-rubl, X_dis-host.gds-tot-base, X_dis-host.gds-dis-rubl, X_dis-host.gds-dis-base) COLUMN-LABEL 'Сумма покупок!нетто' FORMAT "->>>,>>>,>>9.99"
Get-credit-sum-l(input rs-val, input pravo, X_dis-host.gds-tot-rubl, X_dis-host.gds-tot-base, X_dis-host.gds-dis-rubl, X_dis-host.gds-dis-base, X_dis-host.pay-tot-rubl, X_dis-host.pay-tot-base) COLUMN-LABEL 'Сумма в кредит' FORMAT "->>>,>>>,>>9.99"
get-dpcn( X_dis-card.d-card, X_dis-card.emitent-host-code, X_dis-card.type, input p-curr-host-code, input p-curr-obj-type, input p-curr-obj-code, input 2, X_dis-card.d-pcnt, X_dis-card.cash-d-pcnt, X_dis-card.category) COLUMN-LABEL 'Скидка на!итог' FORMAT "X(11)":U
entry (lookup (string(X_dis-card.d-pcnt-method), '1,2,3':U), 'Товар,Итог_чека,Товары_и_итог_чека':U) COLUMN-LABEL 'Использ.скидки' FORMAT "X(13)":U
X_dis-card.is-subsid COLUMN-LABEL 'Дополн?' FORMAT "+/":U
X_dis-card.main-card COLUMN-LABEL 'Основная' FORMAT "X(19)":U
ENABLE
X_dis-card.issue-date
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.03
         BGCOLOR 15 FGCOLOR 0 .
DEFINE FRAME d-dis-card
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-lkp AT ROW 1 COL 34
     b-chg AT ROW 1 COL 44
     b-del AT ROW 1 COL 54
     b-chk AT ROW 1 COL 64
     b-disc AT ROW 1 COL 74 WIDGET-ID 6
     b-print AT ROW 1 COL 86
     B-sch AT ROW 1 COL 89
     b-history AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     B-prop AT ROW 2 COL 39 WIDGET-ID 4
     B-type AT ROW 2 COL 59
     b-payment AT ROW 2 COL 69
     b-view AT ROW 2 COL 79
     b_clientsi AT ROW 2 COL 89
     RS-global AT ROW 2.07 COL 1 NO-LABEL
     b-sl AT ROW 3 COL 89 WIDGET-ID 8
     RS-SEARCH AT ROW 3.27 COL 4 NO-LABEL
     SPattern AT ROW 3.27 COL 36.6 COLON-ALIGNED
     RS-val AT ROW 3.47 COL 59 NO-LABEL
     br-discard AT ROW 4.63 COL 1
     mark-num AT ROW 3.33 COL 2.5 NO-LABEL
     t-totals AT ROW 19.93 COL 20.1 COLON-ALIGNED NO-LABEL
     F-gds-sum AT ROW 20.93 COL 8 COLON-ALIGNED
     F-netto-sum AT ROW 20.93 COL 35 COLON-ALIGNED
     F-credit-sum AT ROW 20.93 COL 64 COLON-ALIGNED
     F-num-chk AT ROW 20.93 COL 88 COLON-ALIGNED
     F-disc-sum AT ROW 22.2 COL 8 COLON-ALIGNED
     F-pay-sum AT ROW 22.2 COL 35 COLON-ALIGNED
     F-saldo-sum AT ROW 22.2 COL 64 COLON-ALIGNED
     SPACE(16.40) SKIP(0.42)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дисконтные карты":L.
ASSIGN
       FRAME d-dis-card:SCROLLABLE       = FALSE
       FRAME d-dis-card:PRIVATE-DATA     =
                "DLGCLOSE".
ASSIGN
       b-add:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-b-add:HANDLE.
ASSIGN
       b-chg:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-b-add-copy:HANDLE.
ASSIGN
       b-chk:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-b-chk:HANDLE.
ASSIGN
       b-del:POPUP-MENU IN FRAME d-dis-card       = MENU POPUP-MENU-b-del:HANDLE.
ASSIGN
       b-disc:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-b-disc:HANDLE.
ASSIGN
       b-history:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-b-history:HANDLE.
ASSIGN
       b-lkp:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-b-lkp:HANDLE.
ASSIGN
       B-prop:POPUP-MENU IN FRAME d-dis-card       = MENU MENU-B-prop:HANDLE.
ASSIGN
       br-discard:NUM-LOCKED-COLUMNS IN FRAME d-dis-card     = 2.
ON CHOOSE OF b-add IN FRAME d-dis-card
DO:
define buffer b-dis-card for ub.dis-card .
define buffer for-clients for ub.clients.
define variable old-list-mode as char no-undo.
DEFINE VARIABLE varhost-code like ub.sysconf.host-code no-undo .
  define variable v-ok as logical no-undo .
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_referense-dis_input-deletion-updating':U
    ,input  'firm':U
    ,input  p-curr-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
  if v-ok <> true
  then do:
    undo, return no-apply .
  end.
if new-type = ""
and add-option = "":U
then  run gbl/pop-up.p ( input self:handle, input no) no-error.
if add-option = 'КОПИРОВАНИЕ':U
or add-option = ('ИЗМЕНЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U)
or add-option = ('ДОБАВЛЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U)
then do:
  if not available X_dis-card then do:
    message
    "Выберите карту для копирования, перевыпуска или выпуска дополн. карты"
    view-as alert-box .
    assign
    add-option = "":u.
    return no-apply.
  end.
  assign
  ri = recid(X_dis-card)
  varhost-code = X_dis-card.emitent-host-code
  .
end.
if p-list-mode = "client":u then do:
  assign
  cli-recid = recid(b_clients).
end.
if add-option = ('ИЗМЕНЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U) then do:
  assign
  cli-recid = recid(X_clients).
end.
old-list-mode = p-list-mode.
if old-list-mode <> "client"
and add-option <> ('ИЗМЕНЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U)
then do:
  assign
  ri-str = "".
  run ref/cli-all.w (
                  input parparentproc
                ,input "b-sel,b-add"
                ,input 'чел':U
                ,input 'все':U
                ,input 'все':U
                ,input ?
                ,input  ",,,,,,NO"
                ,input ?
                ,output ri-str ) .
  if ri-str <> "" then do:
          cli-recid = integer( ri-str ).
  end.
  else return no-apply.
end.
FIND for-clients WHERE recid( for-clients ) = cli-recid NO-LOCK .
if NOT for-clients.stts = 0 then do:
  message
  "Нельзя создавать дисконтные карты для удаленных клиентов!"
  view-as alert-box ERROR.
  return no-apply.
end.
if add-option = ('ИЗМЕНЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U)
or for-clients.obj-type = 'чел':U
or for-clients.obj-type = 'орг':U
then do:
  if old-list-mode = "client":u then
  p-list-mode = new-type.
  else do:
    p-list-mode = old-list-mode.
  end.
  assign
  varhost-code = (if p-list-mode = 'фирма':U
                  then p-curr-host-code
                  else (if p-list-mode = 'все':U then 0 else -1))
  varhost-code = (if add-option = '@client':U then 0 else varhost-code)
  .
  run ref/dcardi.w (
                input parparentproc
              , input  (if add-option = "":U
                 then 'ДОБАВЛЕНИЕ':U
                 else add-option)
              , input varhost-code
              , input p-curr-host-code
              , input p-curr-obj-type
              , input p-curr-obj-code
              , input cli-recid
              , input-output ri ) no-error .
  assign
  add-option = "":U.
  if ri <> ? then do:
    run OpenBr in this-procedure ( input yes, input no, input no).
    reposition br-discard to recid ri no-error.
    if error-status:error then do:
      if error-status:error then do:                           find first pos_dis-card no-lock where                                   recid(pos_dis-card) = ri no-error .                             message                             "Невозможно позиционироваться на записи ДИСКОНТНАЯ КАРТА" skip                            string(if avail pos_dis-card                                     then  substitute("Номер карты: &1"                                                     , pos_dis-card.d-card)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
    end.
    if available X_dis-card then do:
        log-res = br-discard:select-focused-row( ).
    end.
  end.
end.
else do:
  message
  "Дисконтные карты выдаются" skip
  "только внешним контрагентам."
  view-as alert-box INFORMATION .
end.
apply "entry" to br-discard.
END.
ON CHOOSE OF b-chg IN FRAME d-dis-card
DO:
    define variable old-d-pcnt like ub.dis-card.d-pcnt no-undo.
    define variable v-ok as logical no-undo .
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_referense-dis_input-deletion-updating':U
    ,input  'firm':U
    ,input  p-curr-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
    if v-ok <> true
    then do:
      undo, return no-apply .
    end.
    if available X_dis-card THEN do:
        if X_dis-card.emitent-host-code <> p-curr-host-code and X_dis-card.emitent-host-code <> 0 then do:
            message "Данная дисконтная карта принадлежит другой фирме!" skip
                            "изменение запрещено" view-as alert-box ERROR.
                            return no-apply.
        end.
        ri = recid( X_dis-card ) .
        old-d-pcnt = X_dis-card.d-pcnt.
        run ref/dcardi.w (
                       input parparentproc
                     , input  'ИЗМЕНЕНИЕ':U
                     , input X_dis-card.emitent-host-code
                     , input p-curr-host-code
                     , input p-curr-obj-type
                     , input p-curr-obj-code
                     , input ?
                     , input-output ri ) .
        if ri <> ? then do:
            run OpenBr in this-procedure ( input yes, input no, input no).
            reposition br-discard to recid ri no-error.
            if error-status:error then do:
                                if error-status:error then do:                           find first pos_dis-card no-lock where                                   recid(pos_dis-card) = ri no-error .                             message                             "Невозможно позиционироваться на записи ДИСКОНТНАЯ КАРТА" skip                            string(if avail pos_dis-card                                     then  substitute("Номер карты: &1"                                                     , pos_dis-card.d-card)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
            end.
            if available X_dis-card then do:
               log-res = br-discard:select-focused-row( ).
            end.
        end.
    end.
    apply "entry" to br-discard.
END.
ON CHOOSE OF b-chk IN FRAME d-dis-card
DO:
DEFINE VARIABLE varrid-list as character no-undo .
IF NOT AVAILABLE X_DIS-CARD THEN RETURN NO-APPLY.
IF chk-OPTION = '':u THEN DO:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
END.
IF chk-OPTION = '':u THEN RETURN NO-APPLY.
CASE chk-OPTION:
  WHEN "chk-docs" THEN DO:
    run str/chk-docs.w (
                    input parparentproc
                    ,input '':U
                    ,input "d-card":U
                    ,input ?
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input '':U
                    ,input X_dis-card.d-card
                    ,input 0
                    ,input ?
                    ,input ?
                    ,input 0
                    ,output varrid-list) no-error.
  end.
  when "ef" then do:
    run str/cd-trans.w (
                        input parparentproc
                       ,input ""
                       ,input "charkey_one"
                       ,input integer('40':U)
                       ,input p-curr-obj-type
                       ,input p-curr-obj-code
                       ,input 01/01/2008
                       ,input 12/31/9999
                       ,input X_dis-card.d-card
                       ,input ""
                       ,output varrid-list    ) no-error.
  end.
end case.
chk-option = "".
apply "entry" to br-discard.
END.
ON CHOOSE OF b-del IN FRAME d-dis-card
DO:
define variable ok-restore as logical no-undo .
  define variable v-ok as logical no-undo .
if X_dis-card.status_  = 'удал':U then do:
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_referense-dis_current-status':U
    ,input  'firm':U
    ,input  p-curr-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output ok-restore
    ) no-error .
end.
    if ok-restore <> true
    then do:
      undo, return no-apply .
    end.
  end.
  else do:
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_referense-dis_input-deletion-updating':U
    ,input  'firm':U
    ,input  p-curr-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    ) no-error .
end.
    if v-ok <> true
    then do:
      undo, return no-apply .
    end.
  end.
    if status-type = "" then do:
        run gbl/pop-up.p ( input b-del:handle, input no) no-error.
    end.
    if error-status:error or status-type = "" or not avail X_dis-card then do:
      status-type = "":U.
      return no-apply.
    end.
    assign
    ri = recid(X_dis-card).
    run ref/dcardi02.p (
                    input parparentproc
                   ,input recid(X_dis-card)
                   ,input no
                   ,input ok-restore
                   ,input '':U
                   ,input '':U
                   ,input '':U
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input-output status-type) no-error.
    if not error-status:error then do:
      run OpenBr in this-procedure ( input yes, input no, input no).
      REPOSITION br-discard to recid ri No-error.
    if error-status:error then do:
      if error-status:error then do:                           find first pos_dis-card no-lock where                                   recid(pos_dis-card) = ri no-error .                             message                             "Невозможно позиционироваться на записи ДИСКОНТНАЯ КАРТА" skip                            string(if avail pos_dis-card                                     then  substitute("Номер карты: &1"                                                     , pos_dis-card.d-card)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
    end.
      if available X_dis-card then do:
        log-res = br-discard:select-focused-row( ).
      end.
    end.
    apply "ENTRY" to br-discard.
END.
ON CHOOSE OF b-disc IN FRAME d-dis-card
DO:
if disc-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if disc-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-disc IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-history IN FRAME d-dis-card
DO:
  if not avail X_dis-card then return no-apply.
  if hist-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if hist-option = '':U then return no-apply.
  run proc-b-history in this-procedure ( input hist-option) no-error.
  if error-status:error then do:
    hist-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-discard.
END.
ON CHOOSE OF b-lkp IN FRAME d-dis-card
DO:
define variable old-d-pcnt like X_dis-card.d-pcnt no-undo.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
IF NOT AVAILABLE X_DIS-CARD THEN RETURN NO-APPLY.
IF LOOKUP-OPTION = '':u THEN DO:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
END.
IF LOOKUP-OPTION = '':u THEN RETURN NO-APPLY.
CASE LOOKUP-OPTION:
  WHEN 'ПРОСМОТР':U THEN DO:
    if X_dis-card.emitent-host-code <> p-curr-host-code and X_dis-card.emitent-host-code <> 0 then do:
       message
       "Данная дисконтная карта принадлежит другой фирме!" skip
       "ПРОСМОТР запрещен" view-as alert-box ERROR.
       return no-apply.
    end.
    ri = recid( X_dis-card ) .
    run ref/dcardi.w (
                  input parparentproc
                , input 'ПРОСМОТР':U
                , input X_dis-card.emitent-host-code
                , input p-curr-host-code
                , input p-curr-obj-type
                , input p-curr-obj-code
                , input ?
                , input-output ri ) NO-ERROR.
  END.
  WHEN "first-main-card" THEN DO:
     run ref/discards.w (
                    input parparentproc
                   ,input  "":U
                   ,input "card":u
                   ,input p-curr-host-code
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input X_dis-card.first-main-card
                   ,input ?
                   ,output v-rid-list ) no-error .
  END.
END CASE.
LOOKUP-OPTION = '':u.
apply "entry" to br-discard.
END.
ON CHOOSE OF b-mark IN FRAME d-dis-card
DO:
    if available X_dis-card then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid21 as character no-undo .
define variable v-num-entry21 as integer   no-undo .
assign
  v-str-recid21 = trim( string( recid( X_dis-card ) , "->>>>>>>>>>>9":U ) )
  v-num-entry21 = lookup( v-str-recid21 , rid-list )
.
if v-num-entry21 > 0 then do:
  assign
    entry( v-num-entry21, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid21
  .
end.
      glog = br-discard:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
        glog = br-discard:select-next-row ().
        apply "iteration-changed" to br-discard in frame d-dis-card.
      end.
      if num-entries( rid-list ) = 0 then
          hide mark-num in frame d-dis-card.
      else
          disp num-entries( rid-list ) @ mark-num with frame d-dis-card.
    end.
    apply "entry" to br-discard in frame d-dis-card.
END.
ON CHOOSE OF b-payment IN FRAME d-dis-card
DO:
  define variable v-ok as logical no-undo .
  define variable v-is-credit as character no-undo .
  define variable v-is-fin as logical no-undo .
  define variable v-conf-type as character no-undo .
  define variable v-rid-list as character no-undo .
  define variable v-add as logical no-undo .
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_payments-reference_lookup':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
  if v-ok <> true
  then do:
    undo, return no-apply .
  end.
  if available X_dis-card THEN  do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-fin
  ,output v-conf-type
  ) no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'iscredit'
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  NO
  ,output v-is-credit
  ,output v-conf-type
  ) NO-ERROR .
    assign
    v-add = (X_dis-card.credit-card
            and X_dis-card.emitent-host-code <> 0
            and logical(v-is-credit) = yes
            )
    no-error.
    run ref/payments.w (
                     input parparentproc
                    ,input (if v-add then "b-add" else '')
                    ,input 'карта':U
                    ,input ?
                    ,input ?
                    ,input ""
                    ,input ""
                    ,input X_dis-card.d-card
                    ,output v-rid-list) no-error .
  end.
  apply "entry" to br-discard.
END.
ON CHOOSE OF b-print IN FRAME d-dis-card
DO:
    run ref/discardp.p (
                   input parparentproc
                  ,input frame d-dis-card:title
                  ,input pravo
                  ,input rs-val
                  ,input p-curr-host-code
                  ,input p-curr-obj-type
                  ,input p-curr-obj-code
                  ,buffer X_dis-card
                  ,input query br-discard:handle
                    ) no-error.
    If error-status:error then do:
        return no-apply.
    end.
END.
ON CHOOSE OF B-prop IN FRAME d-dis-card
DO:
  if prop-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if prop-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-prop IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sch IN FRAME d-dis-card
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-sel IN FRAME d-dis-card
DO:
    if ( available X_dis-card ) AND ( rid-list = "" ) then
        rid-list = string( recid( X_dis-card ) ) .
END.
ON CHOOSE OF b-sl IN FRAME d-dis-card
DO:
  define variable v-loc-rid-list as character no-undo .
  if not available X_dis-card then undo, return no-apply.
  run ref/stop-lls.w ( INPUT parparentproc
                  ,INPUT "":U
                  ,INPUT 'ПРОСМОТР':U
                  ,INPUT '':U
                  ,input X_dis-card.d-card
                  ,INPUT-OUTPUT v-loc-rid-list ) NO-ERROR.
END.
ON CHOOSE OF B-type IN FRAME d-dis-card
DO:
define variable dctype-ri as recid no-undo.
  if not avail X_dis-card then return no-apply.
    FIND FIRST ub.dis-card-type No-LOCK WHERE
                ub.dis-card-type.type = X_dis-card.type AND
                ub.dis-card-type.emitent-host-code = X_dis-card.emitent-host-code AND
                ub.dis-card-type.host-code = 0 and
                ub.dis-card-type.obj-type = "":U and
                ub.dis-card-type.obj-code = 0 No-ERROR.
     if not avail ub.dis-card-type then do:
        message "Неверный тип дисконтной карты"
        view-as alert-box ERROR.
        return no-apply.
     end.
     dctype-ri = recid( ub.dis-card-type ) .
     run ref/dc-typei.w (
                    input parparentproc
                   ,input 'ПРОСМОТР':U
                   ,input p-curr-host-code
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input-output dctype-ri ).
     apply "ENTRY" to br-discard.
END.
ON CHOOSE OF b-view IN FRAME d-dis-card
DO:
define buffer b-dis-card for ub.dis-card .
define variable rc as recid.
define variable old-d-pcnt like ub.dis-card.d-pcnt.
define variable old-val as character no-undo .
if available X_dis-card then  do:
  rc = recid(X_dis-card).
  if X_dis-card.emitent-host-code = p-curr-host-code or X_dis-card.emitent-host-code = 0 then do:
      old-d-pcnt = X_dis-card.d-pcnt.
      old-val = rs-val.
      run ref/dc-view.w ( input parparentproc
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input X_dis-card.d-card
                    ,input (if p-list-mode = "card" then no else ?)
                    ,input (if p-list-mode = "card" then no else ?)
                    ) .
      rs-val = old-val.
      DISPLAY RS-val with frame d-dis-card.
      run OpenBR in this-procedure ( input yes, input no, input no).
      REPOSITION br-discard to recid rc NO-ERROR.
    if error-status:error then do:
        if error-status:error then do:                           find first pos_dis-card no-lock where                                   recid(pos_dis-card) = rc no-error .                             message                             "Невозможно позиционироваться на записи ДИСКОНТНАЯ КАРТА" skip                            string(if avail pos_dis-card                                     then  substitute("Номер карты: &1"                                                     , pos_dis-card.d-card)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
    end.
  end.
  else do:
      message "Данная дисконтная карта принадлежит другой фирме - просмотр запрещен!"
      view-as alert-box ERROR.
  end.
end.
apply "entry" to br-discard.
END.
ON DEFAULT-ACTION OF br-discard IN FRAME d-dis-card
DO:
    if b-sel:sensitive THEN
        apply "CHOOSE":U to b-sel.
    else
        apply "CHOOSE":U to b-view.
END.
ON ITERATION-CHANGED OF br-discard IN FRAME d-dis-card
DO:
    if available X_dis-card then
        log-res = br-discard:select-focused-row( ).
END.
ON LEFT-MOUSE-DBLCLICK OF br-discard IN FRAME d-dis-card
DO:
    apply "DEFAULT-ACTION":U to self.
END.
ON RETURN OF br-discard IN FRAME d-dis-card
DO:
    apply "DEFAULT-ACTION":U to self.
END.
ON CHOOSE OF b_clientsi IN FRAME d-dis-card
DO:
define variable cli-ri as recid init ? no-undo .
    if available X_dis-card THEN do:
            run ref/showcli.p (
             input parparentproc
            ,input X_dis-card.cli-type
            ,input X_dis-card.cli-code
            ).
        end.
    apply "entry" to br-discard.
END.
ON CHOOSE OF MENU-ITEM m-block
DO:
    status-type = 'блок':U.
    apply "choose" to b-del in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m-curr
DO:
    status-type = 'тек':U.
    apply "choose" to b-del in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m-del
DO:
    status-type = 'удал':U.
    apply "choose" to b-del in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_add
DO:
   assign
   new-type = "":U
   add-option = 'ДОБАВЛЕНИЕ':U.
  apply "CHOOSE" to b-add in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_c-dc-hist
DO:
      assign
  hist-option = 'c-dc-hist':U.
  APPLY "CHOOSE" to b-history in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_c-dc-hist_plus
DO:
      assign
  hist-option = 'c-dc-hist-plus':U.
  APPLY "CHOOSE" to b-history in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_chk-doc
DO:
  ASSIGN chk-OPTION = "chk-docs".
  apply "CHOOSE" to b-chk in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_cli-sourced
DO:
  add-option = ('ИЗМЕНЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U).
  apply "CHOOSE" to b-add in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_cli-subsid
DO:
  add-option = ('ДОБАВЛЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U).
  apply "CHOOSE" to b-add in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_company
DO:
  new-type = 'фирма':U.
  apply "CHOOSE" to b-add in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_copy
DO:
   assign
   new-type = "":U
   add-option = 'КОПИРОВАНИЕ':U.
  apply "CHOOSE" to b-add in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_dct-client
DO:
   assign
   new-type = "":U
   add-option = '@client':U.
  apply "CHOOSE" to b-add in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_ef-cd-trans
DO:
  ASSIGN chk-OPTION = "ef".
  apply "CHOOSE" to b-chk in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_first-main-card
DO:
  ASSIGN LOOKUP-OPTION = "first-main-card".
  apply "CHOOSE" to b-LKP in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_glob
DO:
  new-type = 'все':U.
  apply "CHOOSE" to b-add in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_lookup-disc
DO:
  assign
  disc-option = 'ПРОСМОТР':U
  .
  RUN proc-b-disc IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    disc-option = '':U.
    RETURN NO-APPLY.
  end.
  disc-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_lookup-prop
DO:
    assign
  prop-option = 'ПРОСМОТР':U
  .
  RUN proc-b-prop IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    prop-option = '':U.
    RETURN NO-APPLY.
  end.
  assign
  prop-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_one
DO:
  ASSIGN LOOKUP-OPTION = 'ПРОСМОТР':U.
  apply "CHOOSE" to b-LKP in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_sourced
DO:
 assign
 new-type = "":U
 add-option =   'ИЗМЕНЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U.
apply "CHOOSE" to b-add in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_subsid
DO:
  add-option = ('ДОБАВЛЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U).
  apply "CHOOSE" to b-add in frame d-dis-card.
END.
ON CHOOSE OF MENU-ITEM m_update-disc
DO:
    assign
  disc-option = 'ИЗМЕНЕНИЕ':U
  .
  RUN proc-b-disc IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    disc-option = '':U.
    RETURN NO-APPLY.
  end.
  disc-option = '':U.
END.
ON CHOOSE OF MENU-ITEM m_update-prop
DO:
  assign
  prop-option = 'ИЗМЕНЕНИЕ':U
  .
  RUN proc-b-prop IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    prop-option = '':U.
    RETURN NO-APPLY.
  end.
  prop-option = '':U.
END.
ON VALUE-CHANGED OF RS-global IN FRAME d-dis-card
DO:
  ASSIGN
  RS-GLOBAL.
  assign
  p-list-mode = Rs-GLobal.
  run Enable_ui in this-procedure .
  run OpenBr in this-procedure ( input yes, input no, input no).
  if ri <> ? then
  reposition br-discard to recid ri no-error.
  if available X_dis-card then
   log-res = br-discard:select-focused-row( ).
END.
ON VALUE-CHANGED OF RS-val IN FRAME d-dis-card
DO:
 define variable v-doc-rec as recid no-undo .
  if available X_dis-card then do:
    v-doc-rec = recid(X_dis-card).
  end.
  Assign Rs-val.
  run OpenBr in this-procedure ( input yes, input no, input no).
  reposition br-discard to recid v-doc-rec no-error .
  APPLY "ENTRY" to br-discard.
  APPLY "VALUE-CHANGED" to br-discard.
  IF (p-list-mode = "client":u
  or p-list-mode = "card":U )
  and pravo then do:
      run get-totals in this-procedure No-ERROR.
      if error-status:error then do:
        message
        substitute("Нельзя подсчитать итоги по объектам фирм с разными базовыми валютами&1или не удалось определить валюты по одной из фирм!"
                   , chr(10))
        view-as alert-box ERROR.
        RS-val = 'rubl':U.
        DISPLAY RS-VAL
        WITH FRAME d-dis-card.
        return no-apply.
    end.
  end.
END.
ON RETURN OF SPattern IN FRAME d-dis-card
OR CTRL-J OF SPattern IN FRAME d-dis-card DO:
 DEFINE VARIABLE v-next AS LOGICAL NO-UNDO.
 IF LAST-EVENT:LABEL = "CTRL-J" THEN DO:
   v-next = YES.
 END.
  assign RS-SEARCH SPattern.
  CASE rs-search:
    WHEN 'карта':U THEN DO:
       run proc-find-d-card in THIS-PROCEDURE ( INPUT v-next, input frame d-dis-card spattern) no-error.
    END.
    WHEN 'Контрагент':U THEN DO:
      run proc-find-client in THIS-PROCEDURE ( INPUT v-next, input frame d-dis-card spattern) no-error.
    END.
    WHEN 'название':U THEN DO:
       run proc-find-name in THIS-PROCEDURE ( INPUT v-next, input frame d-dis-card spattern) no-error.
    END.
  END CASE.
  if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-dis-card:PARENT eq ?
THEN FRAME d-dis-card:PARENT = ACTIVE-WINDOW.
def var sort-labelbr-DISCARD   as character no-undo .
def var sort-clmnbr-DISCARD    as handle    no-undo .
def var cur-clmnbr-DISCARD     as handle    no-undo .
def var cur-clmn-locbr-DISCARD as integer   no-undo .
def var re-querybr-DISCARD     as logical   initial no no-undo .
on start-search, ctrl-o of br-DISCARD in frame d-dis-card do:
   run sort-brbr-DISCARD
     (input (if available X_DIS-CARD
             then recid(X_DIS-CARD)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-DISCARD :
  define input parameter p-recid as recid no-undo .
  if re-querybr-DISCARD = no then do:
    assign
       cur-clmnbr-DISCARD = br-DISCARD:current-column in frame d-dis-card
    .
    if sort-clmnbr-DISCARD <> ? then sort-clmnbr-DISCARD:column-fgcolor = 0.
    if cur-clmnbr-DISCARD = sort-clmnbr-DISCARD then do:
      assign
         sort-labelbr-DISCARD = ""
         sort-clmnbr-DISCARD = ?
      .
     end.
     else do:
       assign
         sort-labelbr-DISCARD = cur-clmnbr-DISCARD:label
         sort-clmnbr-DISCARD  = cur-clmnbr-DISCARD
         sort-clmnbr-DISCARD:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-DISCARD = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-DISCARD:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-DISCARD then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-DISCARD = cur-clmn-locbr-DISCARD + 1
    .
  end.
  case sort-labelbr-DISCARD:
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(X_dis-card), &1&2&1)', chr(34), rid-list)     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Номер'  then DO:    assign       sort-column-name = "X_dis-card.d-card"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Название/ФИО'  then DO:    assign       sort-column-name = "X_clients.obj-name"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Маг-н'  then DO:    assign       sort-column-name = "X_dis-card.issue-code"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Выдано'  then DO:    assign       sort-column-name = "X_dis-card.issue-date"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Скидка на!товар'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-dpcn&1, X_dis-card.d-card,  X_dis-card.emitent-host-code, X_dis-card.type, &2, &1&3&1, &4, &1&5&1, X_dis-card.d-pcnt, X_dis-card.cash-d-pcnt, X_dis-card.category)', chr(34), p-curr-host-code,  p-curr-obj-type, p-curr-obj-code, 1)     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Статус'  then DO:    assign       sort-column-name = "X_dis-card.status_"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Фирма'  then DO:    assign       sort-column-name = "X_dis-card.emitent-host-code"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Перевыпуск'  then DO:    assign       sort-column-name = "X_dis-card.sourceD-card"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when '#'  then DO:    assign       sort-column-name = "X_dis-card.overissue-num"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Перв.осн.'  then DO:    assign       sort-column-name = "X_dis-card.first-main-card"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Скидка на!объекте'  then DO:    assign       sort-column-name = "obj-d-pcnt"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Действ.по'  then DO:    assign       sort-column-name = "X_dis-card.valid-date"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Тип'  then DO:    assign       sort-column-name = "X_dis-card.type"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Кред.?'  then DO:    assign       sort-column-name = "X_dis-card.credit-card"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Лимит кредита!(в вал.продаж)'  then DO:    assign       sort-column-name = "X_dis-card.lim-kr"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Клиент'  then DO:    assign       sort-column-name = "(X_dis-card.cli-type + ' ' + STRING (X_dis-card.cli-code))"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Кол-во!чеков'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1Get-num-chk-l&1, &1&2&1, &3, X_dis-host.num-chk, &1X_dis-card.type&1, X_dis-card.emitent-host-code, input &4)', chr(34), rs-val, pravo, v-cntxt-db-num)     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Сумма покупок'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1Get-gds-sum-l&1, &1&2&1, &3, X_dis-host.gds-tot-rubl, X_dis-host.gds-tot-base)', chr(34), rs-val, pravo)     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Скидка'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1Get-disc-sum-l&1, &1&2&1, &3, X_dis-host.gds-dis-rubl, X_dis-host.gds-dis-base)', chr(34), rs-val, pravo)     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Сумма покупок!нетто'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1Get-netto-sum-l&1, &1&2&1, &3, X_dis-host.gds-tot-rubl, X_dis-host.gds-tot-base, X_dis-host.gds-dis-rubl, X_dis-host.gds-dis-base)', chr(34), rs-val, pravo)     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Сумма в кредит'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1Get-credit-sum-l&1, &1&2&1, &3, X_dis-host.gds-tot-rubl, X_dis-host.gds-tot-base, X_dis-host.gds-dis-rubl, X_dis-host.gds-dis-base, X_dis-host.pay-tot-rubl, X_dis-host.pay-tot-base)', chr(34), rs-val, pravo)     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Скидка на!итог'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-dpcn&1, X_dis-card.d-card,  X_dis-card.emitent-host-code, X_dis-card.type, &2, &1&3&1, &4, &1&5&1, X_dis-card.d-pcnt, X_dis-card.cash-d-pcnt, X_dis-card.category)',  chr(34), p-curr-host-code, p-curr-obj-type, p-curr-obj-code, 2)     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Использ.скидки'  then DO:    assign       sort-column-name = "entry (lookup (string(X_dis-card.d-pcnt-method), '1,2,3':U), 'Товар,Итог_чека,Товары_и_итог_чека':U)"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Дополн?'  then DO:    assign       sort-column-name = "X_dis-card.is-subsid"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
        when 'Основная'  then DO:    assign       sort-column-name = "X_dis-card.main-card"     .     run OpenBr in this-procedure ( input yes, input no, input no).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input no).
      if sort-labelbr-DISCARD <> "" then do:
        assign
          cur-clmnbr-DISCARD:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-DISCARD = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-DISCARD to recid p-recid no-error.
    apply "value-changed" to br-DISCARD in frame d-dis-card.
  end.
  apply "entry" to br-DISCARD in frame d-dis-card.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-DISCARD:
if cur-clmnbr-DISCARD = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input no).
end.
else do:
   assign re-querybr-DISCARD = yes.
   run sort-brbr-DISCARD
     (input (if available X_DIS-CARD
             then recid(X_DIS-CARD)
             else ?
            )
     ).
   assign re-querybr-DISCARD = no.
end.
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-dis-card
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
on choose of b-help in frame d-dis-card
do:
  apply "help":u to frame d-dis-card .
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-dis-card:width - 0.3
                fh            = frame d-dis-card:first-child
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
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-dis-card :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-dis-card :height-chars)
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
    if frame d-dis-card :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-dis-card :height-chars)
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
            frame d-dis-card :height = v-frame-height
          .
          if frame d-dis-card :scrollable = true
          then do:
            assign
              frame d-dis-card :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-dis-card :scrollable = true
          then do:
            assign
              frame d-dis-card :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-dis-card :height = v-frame-height
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
      v-frame-height = frame d-dis-card :height
      v-frame-virtual-height = frame d-dis-card :virtual-height
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
      v-field-group-handle = frame d-dis-card :first-child
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
    do with frame d-dis-card
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-dis-card :scrollable = true
      then do:
        assign
          frame d-dis-card :virtual-height = frame d-dis-card :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-dis-card :height = frame d-dis-card :height + p-change-value
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
        frame d-dis-card :height = frame d-dis-card :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-dis-card :scrollable = true
      then do:
        assign
          frame d-dis-card :virtual-height = frame d-dis-card :virtual-height + p-change-value
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
          ,input  string(frame d-dis-card :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-dis-card :height)
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
    if frame d-dis-card :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-dis-card :width
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
    if frame d-dis-card :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-dis-card :width
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
            frame d-dis-card :width = v-frame-width
          .
          if frame d-dis-card :scrollable = true
          then do:
            assign
              frame d-dis-card :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-dis-card :scrollable = true
          then do:
            assign
              frame d-dis-card :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-dis-card :width = v-frame-width
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
      v-frame-width = frame d-dis-card :width
      v-frame-virtual-width = frame d-dis-card :virtual-width
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
      v-field-group-handle = frame d-dis-card :first-child
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
    do with frame d-dis-card
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-dis-card :scrollable = true
      then do:
        assign
          frame d-dis-card :virtual-width = frame d-dis-card :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-dis-card :width = v-frame-width + p-change-value
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
        frame d-dis-card :width = frame d-dis-card :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-dis-card :scrollable = true
      then do:
        assign
          frame d-dis-card :virtual-width = frame d-dis-card :virtual-width + p-change-value
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
          ,input  string(frame d-dis-card :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-dis-card :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-dis-card
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-dis-card :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-dis-card :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-dis-card :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-dis-card :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-dis-card
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
      v-row-delta = v-new-row - frame d-dis-card :height
      v-col-delta = v-new-col - frame d-dis-card :width
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
            - frame d-dis-card :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-dis-card :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-dis-card :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-dis-card :height-chars
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
      v-diasize-current-frame-width  = frame d-dis-card :width
      v-diasize-current-frame-height = frame d-dis-card :height
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
    do with frame d-dis-card
    :
      assign
        v-diasize-orig-frame-height = frame d-dis-card :height
        v-diasize-orig-frame-width  = frame d-dis-card :width
        v-diasize-browse-handle     = browse br-discard :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-dis-card :first-child
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
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-dis-card anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-dis-card. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-dis-card anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-dis-card. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-dis-card anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-dis-card. END.
  return no-apply.
end.
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-dis-card anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-dis-card. END.
  return no-apply.
end.
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-dis-card anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-dis-card. END.
  return no-apply.
end.
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame d-dis-card anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame d-dis-card. END.
  return no-apply.
end.
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame d-dis-card anywhere do:
  if b-exit :sensitive then DO: apply "CHOOSE":U to b-exit in frame d-dis-card. END.
  return no-apply.
end.
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame d-dis-card anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame d-dis-card. END.
  return no-apply.
end.
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ALT-F8 of frame d-dis-card anywhere do:
  if b-history :sensitive then DO: apply "CHOOSE":U to b-history in frame d-dis-card. END.
  return no-apply.
end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame d-dis-card:
    if p-filter-name > "" then do:
      assign
        frame d-dis-card:title
          = frame d-dis-card:title + "   ФИЛЬТР: " + p-filter-name.
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
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-discard :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame d-dis-card anywhere
do:
   if available X_dis-card then ri = recid(X_dis-card).     RUn OpenBr in this-procedure ( input yes, input no, input no).     reposition br-discard to recid ri no-error.
    apply "VALUE-CHANGED" to br-discard.
end.
ASSIGN b-add:MENU-MOUSE = 1.
ON WINDOW-CLOSE OF FRAME d-dis-card APPLY "END-ERROR":U TO SELF.
ON ENDKEY, END-ERROR OF FRAME d-dis-card OR  CHOOSE of b-exit
DO:
  run gbl/markqwa.p (
                  input b-mark:sensitive
                , input rid-list) no-error.
    if error-status:error then return no-apply.
assign
v-uf-list_ =  (if available X_dis-card then string(recid(X_dis-card)) else chr(63)) + chr(4) +
              string(X_dis-card.d-card:width in browse br-discard ) + chr(4) +
              string(v-cli-name:WIDTH in browse br-discard) + chr(4) +
              string(v-cli-type-code:width in browse br-discard) + chr(4) +
              string(X_dis-card.sourceD-card:width in browse br-discard )
.
  run uf-set in this-procedure (
      input  ('discards-p':U + chr(4) + p-list-mode)
      ,input  v-cntxt-userid
      ,input v-uf-List_
      ,input v-uf-Naim
      ,input v-uf-print-graft
      ,input v-uf-sort-gr
      ,input v-uf-type-price
      ,input v-uf-type-val
  )  no-error .
END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-dc'
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  NO
  ,output v-is-dc
  ,output v-conf-type
  ) NO-ERROR .
  IF ERROR-STATUS:ERROR OR
    v-conf-type <> 'L':U THEN
    v-is-dc = "no".
  if logical(v-is-dc) = no then do:
    message
    "В Вашей системе недоступна функциональность работы с дисконтными картами"
    view-as alert-box WARNING.
    undo main-block, return error .
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ef'
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  NO
  ,output v-is-ef
  ,output v-conf-type
  ) NO-ERROR .
  IF ERROR-STATUS:ERROR OR
    v-conf-type <> 'L':U THEN
    v-is-ef = "no".
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
   glog = no.
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_discount-cards-totals_print':U
    ,input  'firm':U
    ,input  p-curr-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
    if NOT glog then pravo = no.
    else pravo = yes.
    ASSIGN b-del:MENU-MOUSE = 1.
    RS-GLOBAL:radio-buttons =  "Перв.осн." + chr(44) + 'карта':U + chr(44) +
                               "Клиент" + chr(44) + 'карты-клиента':U + chr(44) +
                               "По фирме" + chr(44) + 'фирма':U + chr(44) +
                               "Глоб." + chr(44) + 'все':U.
    RS-SEARCH:radio-buttons =   "Номер" + chr(44) + 'карта':U + chr(44) +
                                "Код" + chr(44) + 'Контрагент':U + chr(44) +
                                "Назв./ФИО" + chr(44) + 'название':U.
    assign
    rs-val:radio-buttons =  "Рубли" + chr(44) + 'rubl':U + chr(44) +
                            "Баз.вал." + chr(44) + 'base':U.
    run enable_UI in this-procedure .
    run OpenBr in this-procedure ( input yes, input no, input no).
    if ri <> ? then
    reposition br-discard to recid ri no-error.
    if available X_dis-card then
    log-res = br-discard:select-focused-row( ).
    IF (p-list-mode = "client":u
    or p-list-mode = "card":U) and pravo then do:
      run get-totals in this-procedure .
    end.
    HIDE mark-num in frame d-dis-card .
    WAIT-FOR GO OF FRAME d-dis-card.
END.
run disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME d-dis-card.
END PROCEDURE.
PROCEDURE enable_UI :
define variable v-d-card-width as integer no-undo init 19.
define variable v-cli-name-width as integer no-undo init 29.
define variable v-cli-type-code-width as integer no-undo init 10.
define variable v-sourced-card-width as integer no-undo init 19.
run uf-get in this-procedure (
    input  ('discards-p':U + chr(4) + p-list-mode)
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if not error-status:error
and num-entries(v-uf-List_, chr(4)) = 5 then do:
    assign
    ri = (if entry(1, v-uf-list_, chr(4)) = chr(63)
         then ?
         else integer(entry(1, v-uf-list_, chr(4))))
    v-d-card-width = integer(entry(2, v-uf-list_, chr(4) ))
    v-cli-name-width = integer(entry(3, v-uf-list_, chr(4) ))
    v-cli-type-code-width = integer(entry(4, v-uf-list_, chr(4) ))
    v-sourced-card-width = integer(entry(5, v-uf-list_, chr(4) ))
    .
end.
if v-initial-height = 0 then do:
  v-initial-height = br-discard:height in frame d-dis-card .
end.
ASSIGN
X_dis-card.issue-date:READ-ONLY IN BROWSE BR-DISCARD = YES
b-history:MENU-MOUSE in frame d-dis-card = 1
b-chk:menu-mouse in frame d-dis-card = 1
menu-item m_ef-cd-trans:sensitive in menu menu-b-chk = logical(v-is-ef)
b-CHG:POPUP-MENU IN FRAME d-dis-card = ?
b-add:MENU-MOUSE in frame d-dis-card = 1
b-lkp:MENU-MOUSE in frame d-dis-card =1
b-prop:MENU-MOUSE in frame d-dis-card = 1
b-disc:MENU-MOUSE in frame d-dis-card = 1
X_dis-card.d-card:resizable in browse br-discard = true
X_dis-card.d-card:width in browse br-discard = v-d-card-width
v-cli-name:resizable in browse br-discard = true
v-cli-name:width in browse br-discard = v-cli-name-width
v-cli-type-code:resizable in browse br-discard = true
v-cli-type-code:width in browse br-discard = v-cli-type-code-width
X_dis-card.sourced-card:resizable in browse br-discard = true
X_dis-card.sourced-card:width in browse br-discard = v-sourced-card-width
MENU-ITEM m_first-main-card:SENSITIVE IN MENU menu-b-lkp = (p-list-mode <> 'card':U)
br-discard:height = v-initial-height + ( if p-list-mode = "client" or p-list-mode = "card"
                                          then 0.0
                                          else 3.0)
MENU-ITEM m_cli-sourced:sensitive in menu menu-b-add = yes
MENU-ITEM m_sourced:sensitive in menu menu-b-add-copy = yes
.
if cli-recid <> ? then
FIND b_clients WHERE recid( b_clients ) = cli-recid NO-LOCK .
ENABLE
br-discard
b-exit
b-mark  WHEN can-do( bttns, "b-mark" )
b-sel  WHEN can-do( bttns, "b-sel" )
b-payment when v-cntxt-db-num = 0
b-sch
b-print
b-history
b-help
b-chk WHEN p-curr-obj-type = 'маг':U
b-lkp
b-add WHEN (not transaction and v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-del WHEN (not transaction and v-cntxt-db-num = 0 )
b-chg WHEN (not transaction and v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0)
b-prop
b-disc
b_clientsi WHEN cli-recid = ?
b-view
b-type
b-disc
RS-SEARCH
SPattern
RS-Global
b-sl
WITH FRAME d-dis-card.
if transaction then do:
  menu-item m_update-prop:sensitive in menu menu-b-prop  = no.
  menu-item m_update-disc:sensitive in menu menu-b-disc  = no.
end.
case p-list-mode:
  when 'все':U then do:
    assign
    glob-val = one-base-cur-for-objs(output v-glob-curr-code)
    .
    ASSIGN
    b-add:POPUP-MENU IN FRAME d-dis-card = MENU MENU-b-add-copy:HANDLE.
    RS-GLOBAL = 'все':U.
    glog = RS-GLOBAL:disable("Клиент").
    glog = RS-GLOBAL:disable("Перв.осн.").
  end.
  when 'фирма':U then do:
    ASSIGN
    b-add:POPUP-MENU IN FRAME d-dis-card = MENU MENU-b-add-copy:HANDLE.
    RS-GLOBAL = 'фирма':U.
    glog = RS-GLOBAL:disable("Клиент").
    glog = RS-GLOBAL:disable("Перв.осн.").
    glob-val = yes.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output RS-val
  )  .
    display
    rs-val
    with frame d-dis-card.
  end.
  when "client" then do:
    RS-GLOBAL = 'карты-клиента':U.
    glog = RS-GLOBAL:disable("Глоб.").
    glog = RS-GLOBAL:disable("По фирме").
    glog = RS-GLOBAL:disable("Перв.осн.").
    glob-val = yes.
  end.
  when "card" then do:
    t-totals = substitute("Итоги по всем картам к первич. осн. карте &1", p-first-main-card).
    RS-GLOBAL = 'карта':U.
    glog = RS-GLOBAL:disable("Глоб.").
    glog = RS-GLOBAL:disable("По фирме").
    glog = RS-GLOBAL:disable("Клиент").
    glob-val = yes.
  end.
end case.
display
RS-GLOBAL
WITH frame d-dis-card.
IF glob-val AND pravo then
ENABLE RS-VAL when glob-val
WITH FRAME d-dis-card.
else do:
  rs-val = 'rubl':U.
  display
  rs-val
  with frame d-dis-card.
  disable
  Rs-val
  WITH FRAME d-dis-card.
end.
if NOT ((p-list-mode = "client":u
        or
        p-list-mode = "card":u )
and pravo) then
HIDE
F-disc-sum
F-gds-sum
F-netto-sum
F-pay-sum
F-num-chk
F-credit-sum
F-saldo-sum
t-totals
b-disc
IN FRAME d-dis-card.
END PROCEDURE.
PROCEDURE Get-Totals :
DEFINE variable dopi2 as integer no-undo init -1.
define variable dop-num-chk as integer no-undo.
define variable dop-gds-sum as decimal no-undo.
define variable dop-disc-sum as decimal no-undo.
define variable dop-netto-sum as decimal no-undo.
define variable dop-pay-sum as decimal no-undo.
define variable dop-credit-sum as decimal no-undo.
define variable dop-saldo-sum as decimal no-undo.
CASE p-list-mode:
  when "client":U then do:
    IF RS-val = 'rubl':U then do:
      FOR EACH b-d-c No-LOCK WHERE
              b-d-c.cli-type = b_clients.obj-type
          AND b-d-c.cli-code = b_clients.obj-code,
          EACH ub.dis-host NO-LOCK WHERE
              ub.dis-host.d-card = b-d-c.d-card
          AND ub.dis-host.host-code > 0
          and ub.dis-host.dt-code = 0
          :
        assign
        dop-num-chk = dop-num-chk + ub.dis-host.num-chk
        dop-gds-sum = dop-gds-sum + ub.dis-host.gds-tot-rubl
        dop-disc-sum = dop-disc-sum + ub.dis-host.gds-dis-rubl
        dop-netto-sum = dop-gds-sum - dop-disc-sum
        dop-pay-sum = dop-pay-sum + ub.dis-host.pay-tot-rubl
        dop-credit-sum = dop-netto-sum - dop-pay-sum
        dop-saldo-sum = dop-saldo-sum + b-d-c.saldo-rubl
        .
      END.
    end.
    if RS-VAL = 'base':U then do:
        FOR EACH b-d-c No-LOCK WHERE
                b-d-c.cli-type = b_clients.obj-type
            AND b-d-c.cli-code = b_clients.obj-code,
            EACH dis-host NO-LOCK WHERE
                dis-host.d-card = b-d-c.d-card
            AND dis-host.host-code > 0
            and dis-host.dt-code = 0
            :
        if dopi2 = -1 then do:
            dopi2 = ub.dis-host.host-code.
            FINd FIRST ub.sysconf No-LOCK WHERE ub.sysconf.host-code = ub.dis-host.host-code no-error .
            if not available sysconf then do:
               undo, return error .
            end.
            dopi = sysconf.base-code.
        end.
        else if dopi2 <> ub.dis-host.host-code then do:
            FIND FIRST ub.sysconf No-LOCK WHERE ub.sysconf.host-code = ub.dis-host.host-code no-error .
            if not available ub.sysconf then do:
               undo, return error .
            end.
            if ub.sysconf.base-code <> dopi then do:
                return error.
            end.
        end.
        assign
        dop-num-chk = dop-num-chk + dis-host.num-chk
        dop-gds-sum = dop-gds-sum + dis-host.gds-tot-base
        dop-disc-sum = dop-disc-sum + dis-host.gds-dis-base
        dop-netto-sum = dop-gds-sum - dop-disc-sum
        dop-pay-sum = dop-pay-sum + dis-host.pay-tot-base
        dop-credit-sum = dop-netto-sum - dop-pay-sum
        dop-saldo-sum = dop-saldo-sum + b-d-c.saldo-base
        .
      END.
    end.
  end.
  when "card":U then do:
    IF RS-val = 'rubl':U then do:
      FOR EACH b-d-c No-LOCK WHERE
              b-d-c.first-main-card = p-first-main-card,
          EACH dis-host NO-LOCK WHERE
              dis-host.d-card = b-d-c.d-card
          AND dis-host.host-code > 0
          and dis-host.dt-code = 0:
        assign
        dop-num-chk = dop-num-chk + dis-host.num-chk
        dop-gds-sum = dop-gds-sum + dis-host.gds-tot-rubl
        dop-disc-sum = dop-disc-sum + dis-host.gds-dis-rubl
        dop-netto-sum = dop-gds-sum - dop-disc-sum
        dop-pay-sum = dop-pay-sum + dis-host.pay-tot-rubl
        dop-credit-sum = dop-netto-sum - dop-pay-sum
        dop-saldo-sum = dop-saldo-sum + b-d-c.saldo-rubl
        .
      END.
    end.
    if RS-VAL = 'base':U then do:
        FOR EACH b-d-c No-LOCK WHERE
                b-d-c.first-main-card = p-first-main-card,
            EACH dis-host NO-LOCK WHERE
                dis-host.d-card = b-d-c.d-card
            AND dis-host.host-code > 0
            and dis-host.dt-code = 0 :
        if dopi2 = -1 then do:
            dopi2 = dis-host.host-code.
            FINd FIRST sysconf No-LOCK WHERE sysconf.host-code = dis-host.host-code.
            dopi = sysconf.base-code.
        end.
        else if dopi2 <> dis-host.host-code then do:
            FIND FIRST sysconf No-LOCK WHERE sysconf.host-code = dis-host.host-code.
            if sysconf.base-code <> dopi then do:
                return error.
            end.
        end.
        assign
        dop-num-chk = dop-num-chk + dis-host.num-chk
        dop-gds-sum = dop-gds-sum + dis-host.gds-tot-base
        dop-disc-sum = dop-disc-sum + dis-host.gds-dis-base
        dop-netto-sum = dop-gds-sum - dop-disc-sum
        dop-pay-sum = dop-pay-sum + dis-host.pay-tot-base
        dop-credit-sum = dop-netto-sum - dop-pay-sum
        dop-saldo-sum = dop-saldo-sum + b-d-c.saldo-base
        .
      END.
    end.
  end.
END CASE.
assign
f-num-chk = dop-num-chk
f-gds-sum = dop-gds-sum
f-disc-sum = dop-disc-sum
f-netto-sum = dop-netto-sum
F-pay-sum = dop-pay-sum
f-credit-sum = dop-credit-sum
f-saldo-sum = dop-saldo-sum
.
DISPLAY
t-totals
f-disc-sum
f-gds-sum
f-netto-sum
F-pay-sum
f-num-chk
f-credit-sum
f-saldo-sum
WITH FRAME d-dis-card.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
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
CASE p-list-mode:
    when 'фирма':U then do:
      if p-open-query then do:
        ASSIGN
        frame d-dis-card:TITLE = substitute("ДИСКОНТНЫЕ КАРТЫ ПО ФИРМЕ &1", v-host-name).
      end.
      assign
      filter-point-name = filter-point-name0 + " " + p-list-mode
      filter-point = filter-point0 + " " + p-list-mode.
      if rs-search = 'название':U then do:
                if sort-column-name = '':u then do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-43  as logical   no-undo .
define variable  l-filter-open-43    as logical   .
define variable  flt-rec-43       as recid     no-undo .
define variable  filter-name-43      as character no-undo .
define variable  where-phrase-43     as character no-undo .
define variable  sort-phrase-43      as character no-undo .
define variable  where-phrase-rus-43 as character no-undo .
define variable  sort-phrase-rus-43  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-43
  ,output filter-name-43
  ,output where-phrase-43
  ,output sort-phrase-43
  ,output where-phrase-rus-43
  ,output sort-phrase-rus-43
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-43
      ) no-error .
  assign
    l-filter-open-43 = false
  .
  if flt-rec-43 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-43 as character no-undo .
    define variable  parameter-3-43 as character no-undo .
    define variable  parameter-4-43 as character no-undo .
    define variable  parameter-5-43 as character no-undo .
    define variable  parameter-6-43 as character no-undo .
    define variable  parameter-7-43 as character no-undo .
      assign
      parameter-3-43 =
                              "FOR EACH X_dis-card"
      parameter-4-43 =
        (
          if (" X_dis-card.emitent-host-code = p-curr-host-code " + " " + where-phrase-43) <> ""
          then  substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code)  + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0")
      parameter-6-43 = if sort-phrase-43 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-card.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-43
        )
      parameter-7-43 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-43 =
          (" X_dis-card.emitent-host-code = p-curr-host-code " + " " + where-phrase-43 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input parameter-3-43
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ,input parameter-6-43
                          ,input parameter-7-43
                          )
      .
      assign
        l-filter-open-43 = true
      .
    end.
    if l-filter-open-43 = false then do:
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
  if l-filter-open-43 = false then do:
    OPEN QUERY br-discard FOR EACH X_dis-card
      where  X_dis-card.emitent-host-code = p-curr-host-code
    , FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0
       by X_dis-card.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-card )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-discard:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-43 = (if p-find-next then "true":u else "false":u )
      parameter-4-43 =
        "where ":u +  substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code)  + " ":u + where-phrase-43 + " ":u + p-find-condition + " " + ""
      parameter-5-43 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input rowid(X_dis-card)
                          ,input logical(parameter-2-43)
                          ,input no-lock
                          ,input (buffer X_dis-card:handle)
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-43 = (if p-find-next then "true":u else "false":u )
      parameter-3-43 =  "FOR EACH X_dis-card"
      parameter-4-43 =
        (
          if (" X_dis-card.emitent-host-code = p-curr-host-code " + " " + where-phrase-43) <> ""
          then  substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code)  + " " + where-phrase-43
          else "true"
        )
      parameter-5-43 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0" + " " + p-find-condition)
      parameter-6-43 = if sort-phrase-43 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-card.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-43
        )
      parameter-7-43 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input logical(parameter-2-43)
                          ,input no-lock
                          ,input parameter-3-43
                          ,input parameter-4-43
                          ,input parameter-5-43
                          ,input parameter-6-43
                          ,input parameter-7-43
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
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-45  as logical   no-undo .
define variable  l-filter-open-45    as logical   .
define variable  flt-rec-45       as recid     no-undo .
define variable  filter-name-45      as character no-undo .
define variable  where-phrase-45     as character no-undo .
define variable  sort-phrase-45      as character no-undo .
define variable  where-phrase-rus-45 as character no-undo .
define variable  sort-phrase-rus-45  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-45
  ,output filter-name-45
  ,output where-phrase-45
  ,output sort-phrase-45
  ,output where-phrase-rus-45
  ,output sort-phrase-rus-45
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-45
      ) no-error .
  assign
    l-filter-open-45 = false
  .
  if flt-rec-45 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-45 as character no-undo .
    define variable  parameter-3-45 as character no-undo .
    define variable  parameter-4-45 as character no-undo .
    define variable  parameter-5-45 as character no-undo .
    define variable  parameter-6-45 as character no-undo .
    define variable  parameter-7-45 as character no-undo .
      assign
      parameter-3-45 =
                              "FOR EACH X_dis-card"
      parameter-4-45 =
        (
          if (" X_dis-card.emitent-host-code = p-curr-host-code " + " " + where-phrase-45) <> ""
          then  substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code)  + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0")
      parameter-6-45 = if sort-phrase-45 = ''
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
        " " + sort-phrase-45
        )
      parameter-7-45 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-45 =
          (" X_dis-card.emitent-host-code = p-curr-host-code " + " " + where-phrase-45 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input parameter-3-45
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ,input parameter-6-45
                          ,input parameter-7-45
                          )
      .
      assign
        l-filter-open-45 = true
      .
    end.
    if l-filter-open-45 = false then do:
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
  if l-filter-open-45 = false then do:
    OPEN QUERY br-discard FOR EACH X_dis-card
      where  X_dis-card.emitent-host-code = p-curr-host-code
    , FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-card )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-discard:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-45 = (if p-find-next then "true":u else "false":u )
      parameter-4-45 =
        "where ":u +  substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code)  + " ":u + where-phrase-45 + " ":u + p-find-condition + " " + ""
      parameter-5-45 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input rowid(X_dis-card)
                          ,input logical(parameter-2-45)
                          ,input no-lock
                          ,input (buffer X_dis-card:handle)
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-45 = (if p-find-next then "true":u else "false":u )
      parameter-3-45 =  "FOR EACH X_dis-card"
      parameter-4-45 =
        (
          if (" X_dis-card.emitent-host-code = p-curr-host-code " + " " + where-phrase-45) <> ""
          then  substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code)  + " " + where-phrase-45
          else "true"
        )
      parameter-5-45 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0" + " " + p-find-condition)
      parameter-6-45 = if sort-phrase-45 = ''
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
        " " + sort-phrase-45
        )
      parameter-7-45 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input logical(parameter-2-45)
                          ,input no-lock
                          ,input parameter-3-45
                          ,input parameter-4-45
                          ,input parameter-5-45
                          ,input parameter-6-45
                          ,input parameter-7-45
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
      else do:
              if sort-column-name = '':u then do:
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
                              "FOR EACH X_dis-card"
      parameter-4-47 =
        (
          if (" X_dis-card.emitent-host-code = p-curr-host-code " + " " + where-phrase-47) <> ""
          then  substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code)  + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0")
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-card.d-card "
        )
                           else
        (
        " " + "  " +
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
          (" X_dis-card.emitent-host-code = p-curr-host-code " + " " + where-phrase-47 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-discard:handle
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
    OPEN QUERY br-discard FOR EACH X_dis-card
      where  X_dis-card.emitent-host-code = p-curr-host-code
    , FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0
       by X_dis-card.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-card )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-discard:handle:get-buffer-handle(1) = (buffer X_dis-card:handle) then do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-4-47 =
        "where ":u +  substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code)  + " ":u + where-phrase-47 + " ":u + p-find-condition + " " + ""
      parameter-5-47 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input rowid(X_dis-card)
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input (buffer X_dis-card:handle)
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
      parameter-3-47 =  "FOR EACH X_dis-card"
      parameter-4-47 =
        (
          if (" X_dis-card.emitent-host-code = p-curr-host-code " + " " + where-phrase-47) <> ""
          then  substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code)  + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0" + " " + p-find-condition)
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-card.d-card "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-47
        )
      parameter-7-47 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
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
                              "FOR EACH X_dis-card"
      parameter-4-49 =
        (
          if (" X_dis-card.emitent-host-code = p-curr-host-code " + " " + where-phrase-49) <> ""
          then  substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code)  + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0")
      parameter-6-49 = if sort-phrase-49 = ''
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
          (" X_dis-card.emitent-host-code = p-curr-host-code " + " " + where-phrase-49 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-discard:handle
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
    OPEN QUERY br-discard FOR EACH X_dis-card
      where  X_dis-card.emitent-host-code = p-curr-host-code
    , FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-card )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-discard:handle:get-buffer-handle(1) = (buffer X_dis-card:handle) then do:
      assign
      parameter-2-49 = (if p-find-next then "true":u else "false":u )
      parameter-4-49 =
        "where ":u +  substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code)  + " ":u + where-phrase-49 + " ":u + p-find-condition + " " + ""
      parameter-5-49 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input rowid(X_dis-card)
                          ,input logical(parameter-2-49)
                          ,input no-lock
                          ,input (buffer X_dis-card:handle)
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
      parameter-3-49 =  "FOR EACH X_dis-card"
      parameter-4-49 =
        (
          if (" X_dis-card.emitent-host-code = p-curr-host-code " + " " + where-phrase-49) <> ""
          then  substitute('X_dis-card.emitent-host-code = &1', p-curr-host-code)  + " " + where-phrase-49
          else "true"
        )
      parameter-5-49 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0" + " " + p-find-condition)
      parameter-6-49 = if sort-phrase-49 = ''
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
        " " + sort-phrase-49
        )
      parameter-7-49 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
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
    end.
    end.
    when 'все':U then do:
      if p-open-query then do:
        ASSIGN
        frame d-dis-card:TITLE = "ГЛОБАЛЬНЫЕ ДИСКОНТНЫЕ КАРТЫ ".
      end.
      assign
      filter-point-name = filter-point-name0 + " " + p-list-mode
      filter-point = filter-point0 + " " + p-list-mode.
      if rs-search = 'название':U then do:
              if sort-column-name = '':u then do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-51  as logical   no-undo .
define variable  l-filter-open-51    as logical   .
define variable  flt-rec-51       as recid     no-undo .
define variable  filter-name-51      as character no-undo .
define variable  where-phrase-51     as character no-undo .
define variable  sort-phrase-51      as character no-undo .
define variable  where-phrase-rus-51 as character no-undo .
define variable  sort-phrase-rus-51  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-51
  ,output filter-name-51
  ,output where-phrase-51
  ,output sort-phrase-51
  ,output where-phrase-rus-51
  ,output sort-phrase-rus-51
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-51
      ) no-error .
  assign
    l-filter-open-51 = false
  .
  if flt-rec-51 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-51 as character no-undo .
    define variable  parameter-3-51 as character no-undo .
    define variable  parameter-4-51 as character no-undo .
    define variable  parameter-5-51 as character no-undo .
    define variable  parameter-6-51 as character no-undo .
    define variable  parameter-7-51 as character no-undo .
      assign
      parameter-3-51 =
                              "FOR EACH X_dis-card"
      parameter-4-51 =
        (
          if (" X_dis-card.emitent-host-code = 0 " + " " + where-phrase-51) <> ""
          then " X_dis-card.emitent-host-code = 0 " + " " + where-phrase-51
          else "true"
        )
      parameter-5-51 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0")
      parameter-6-51 = if sort-phrase-51 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-card.d-card  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-51
        )
      parameter-7-51 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-51 =
          (" X_dis-card.emitent-host-code = 0 " + " " + where-phrase-51 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input parameter-3-51
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ,input parameter-6-51
                          ,input parameter-7-51
                          )
      .
      assign
        l-filter-open-51 = true
      .
    end.
    if l-filter-open-51 = false then do:
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
  if l-filter-open-51 = false then do:
    OPEN QUERY br-discard FOR EACH X_dis-card
      where  X_dis-card.emitent-host-code = 0
    , FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0
       by X_dis-card.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-card )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-discard:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-51 = (if p-find-next then "true":u else "false":u )
      parameter-4-51 =
        "where ":u + " X_dis-card.emitent-host-code = 0 " + " ":u + where-phrase-51 + " ":u + p-find-condition + " " + ""
      parameter-5-51 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input rowid(X_dis-card)
                          ,input logical(parameter-2-51)
                          ,input no-lock
                          ,input (buffer X_dis-card:handle)
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-51 = (if p-find-next then "true":u else "false":u )
      parameter-3-51 =  "FOR EACH X_dis-card"
      parameter-4-51 =
        (
          if (" X_dis-card.emitent-host-code = 0 " + " " + where-phrase-51) <> ""
          then " X_dis-card.emitent-host-code = 0 " + " " + where-phrase-51
          else "true"
        )
      parameter-5-51 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0" + " " + p-find-condition)
      parameter-6-51 = if sort-phrase-51 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-card.d-card  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-51
        )
      parameter-7-51 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input logical(parameter-2-51)
                          ,input no-lock
                          ,input parameter-3-51
                          ,input parameter-4-51
                          ,input parameter-5-51
                          ,input parameter-6-51
                          ,input parameter-7-51
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
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-53  as logical   no-undo .
define variable  l-filter-open-53    as logical   .
define variable  flt-rec-53       as recid     no-undo .
define variable  filter-name-53      as character no-undo .
define variable  where-phrase-53     as character no-undo .
define variable  sort-phrase-53      as character no-undo .
define variable  where-phrase-rus-53 as character no-undo .
define variable  sort-phrase-rus-53  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-53
  ,output filter-name-53
  ,output where-phrase-53
  ,output sort-phrase-53
  ,output where-phrase-rus-53
  ,output sort-phrase-rus-53
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-53
      ) no-error .
  assign
    l-filter-open-53 = false
  .
  if flt-rec-53 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-53 as character no-undo .
    define variable  parameter-3-53 as character no-undo .
    define variable  parameter-4-53 as character no-undo .
    define variable  parameter-5-53 as character no-undo .
    define variable  parameter-6-53 as character no-undo .
    define variable  parameter-7-53 as character no-undo .
      assign
      parameter-3-53 =
                              "FOR EACH X_dis-card"
      parameter-4-53 =
        (
          if (" X_dis-card.emitent-host-code = 0 " + " " + where-phrase-53) <> ""
          then " X_dis-card.emitent-host-code = 0 " + " " + where-phrase-53
          else "true"
        )
      parameter-5-53 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0")
      parameter-6-53 = if sort-phrase-53 = ''
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
        " " + sort-phrase-53
        )
      parameter-7-53 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-53 =
          (" X_dis-card.emitent-host-code = 0 " + " " + where-phrase-53 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input parameter-3-53
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ,input parameter-6-53
                          ,input parameter-7-53
                          )
      .
      assign
        l-filter-open-53 = true
      .
    end.
    if l-filter-open-53 = false then do:
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
  if l-filter-open-53 = false then do:
    OPEN QUERY br-discard FOR EACH X_dis-card
      where  X_dis-card.emitent-host-code = 0
    , FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-card )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-discard:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-53 = (if p-find-next then "true":u else "false":u )
      parameter-4-53 =
        "where ":u + " X_dis-card.emitent-host-code = 0 " + " ":u + where-phrase-53 + " ":u + p-find-condition + " " + ""
      parameter-5-53 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input rowid(X_dis-card)
                          ,input logical(parameter-2-53)
                          ,input no-lock
                          ,input (buffer X_dis-card:handle)
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-53 = (if p-find-next then "true":u else "false":u )
      parameter-3-53 =  "FOR EACH X_dis-card"
      parameter-4-53 =
        (
          if (" X_dis-card.emitent-host-code = 0 " + " " + where-phrase-53) <> ""
          then " X_dis-card.emitent-host-code = 0 " + " " + where-phrase-53
          else "true"
        )
      parameter-5-53 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0" + " " + p-find-condition)
      parameter-6-53 = if sort-phrase-53 = ''
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
        " " + sort-phrase-53
        )
      parameter-7-53 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input logical(parameter-2-53)
                          ,input no-lock
                          ,input parameter-3-53
                          ,input parameter-4-53
                          ,input parameter-5-53
                          ,input parameter-6-53
                          ,input parameter-7-53
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
      else do:
                if sort-column-name = '':u then do:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-55  as logical   no-undo .
define variable  l-filter-open-55    as logical   .
define variable  flt-rec-55       as recid     no-undo .
define variable  filter-name-55      as character no-undo .
define variable  where-phrase-55     as character no-undo .
define variable  sort-phrase-55      as character no-undo .
define variable  where-phrase-rus-55 as character no-undo .
define variable  sort-phrase-rus-55  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-55
  ,output filter-name-55
  ,output where-phrase-55
  ,output sort-phrase-55
  ,output where-phrase-rus-55
  ,output sort-phrase-rus-55
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-55
      ) no-error .
  assign
    l-filter-open-55 = false
  .
  if flt-rec-55 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-55 as character no-undo .
    define variable  parameter-3-55 as character no-undo .
    define variable  parameter-4-55 as character no-undo .
    define variable  parameter-5-55 as character no-undo .
    define variable  parameter-6-55 as character no-undo .
    define variable  parameter-7-55 as character no-undo .
      assign
      parameter-3-55 =
                              "FOR EACH X_dis-card"
      parameter-4-55 =
        (
          if (" X_dis-card.emitent-host-code = 0 " + " " + where-phrase-55) <> ""
          then " X_dis-card.emitent-host-code = 0 " + " " + where-phrase-55
          else "true"
        )
      parameter-5-55 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0")
      parameter-6-55 = if sort-phrase-55 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-card.d-card  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-55
        )
      parameter-7-55 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-55 =
          (" X_dis-card.emitent-host-code = 0 " + " " + where-phrase-55 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input parameter-3-55
                          ,input parameter-4-55
                          ,input parameter-5-55
                          ,input parameter-6-55
                          ,input parameter-7-55
                          )
      .
      assign
        l-filter-open-55 = true
      .
    end.
    if l-filter-open-55 = false then do:
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
  if l-filter-open-55 = false then do:
    OPEN QUERY br-discard FOR EACH X_dis-card
      where  X_dis-card.emitent-host-code = 0
    , FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0
       by X_dis-card.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-card )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-discard:handle:get-buffer-handle(1) = (buffer X_dis-card:handle) then do:
      assign
      parameter-2-55 = (if p-find-next then "true":u else "false":u )
      parameter-4-55 =
        "where ":u + " X_dis-card.emitent-host-code = 0 " + " ":u + where-phrase-55 + " ":u + p-find-condition + " " + ""
      parameter-5-55 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input rowid(X_dis-card)
                          ,input logical(parameter-2-55)
                          ,input no-lock
                          ,input (buffer X_dis-card:handle)
                          ,input parameter-4-55
                          ,input parameter-5-55
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-55 = (if p-find-next then "true":u else "false":u )
      parameter-3-55 =  "FOR EACH X_dis-card"
      parameter-4-55 =
        (
          if (" X_dis-card.emitent-host-code = 0 " + " " + where-phrase-55) <> ""
          then " X_dis-card.emitent-host-code = 0 " + " " + where-phrase-55
          else "true"
        )
      parameter-5-55 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0" + " " + p-find-condition)
      parameter-6-55 = if sort-phrase-55 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-card.d-card  "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-55
        )
      parameter-7-55 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input logical(parameter-2-55)
                          ,input no-lock
                          ,input parameter-3-55
                          ,input parameter-4-55
                          ,input parameter-5-55
                          ,input parameter-6-55
                          ,input parameter-7-55
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
                              "FOR EACH X_dis-card"
      parameter-4-57 =
        (
          if (" X_dis-card.emitent-host-code = 0 " + " " + where-phrase-57) <> ""
          then " X_dis-card.emitent-host-code = 0 " + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0")
      parameter-6-57 = if sort-phrase-57 = ''
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
          (" X_dis-card.emitent-host-code = 0 " + " " + where-phrase-57 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-discard:handle
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
    OPEN QUERY br-discard FOR EACH X_dis-card
      where  X_dis-card.emitent-host-code = 0
    , FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-card )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-discard:handle:get-buffer-handle(1) = (buffer X_dis-card:handle) then do:
      assign
      parameter-2-57 = (if p-find-next then "true":u else "false":u )
      parameter-4-57 =
        "where ":u + " X_dis-card.emitent-host-code = 0 " + " ":u + where-phrase-57 + " ":u + p-find-condition + " " + ""
      parameter-5-57 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input rowid(X_dis-card)
                          ,input logical(parameter-2-57)
                          ,input no-lock
                          ,input (buffer X_dis-card:handle)
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
      parameter-3-57 =  "FOR EACH X_dis-card"
      parameter-4-57 =
        (
          if (" X_dis-card.emitent-host-code = 0 " + " " + where-phrase-57) <> ""
          then " X_dis-card.emitent-host-code = 0 " + " " + where-phrase-57
          else "true"
        )
      parameter-5-57 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0" + " " + p-find-condition)
      parameter-6-57 = if sort-phrase-57 = ''
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
        " " + sort-phrase-57
        )
      parameter-7-57 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
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
       end.
    end.
    when "client":u then do:
      if p-open-query then do:
        ASSIGN
        frame d-dis-card:TITLE = substitute("ДИСКОНТНЫЕ КАРТЫ ПО КЛИЕНТУ &1", b_clients.obj-name)
        .
      end.
      assign
      filter-point-name = filter-point-name0 + " " + p-list-mode
      filter-point = filter-point0 + " " + p-list-mode.
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
                              "FOR EACH X_dis-card"
      parameter-4-59 =
        (
          if (" X_dis-card.cli-type = b_clients.obj-type AND X_dis-card.cli-code = b_clients.obj-code " + " " + where-phrase-59) <> ""
          then  substitute('X_dis-card.cli-type = &1&2&1 AND X_dis-card.cli-code = &3 ', chr(34), b_clients.obj-type, b_clients.obj-code) + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0")
      parameter-6-59 = if sort-phrase-59 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-card.d-card   "
        )
                           else
        (
        " " + "  " +
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
          (" X_dis-card.cli-type = b_clients.obj-type AND X_dis-card.cli-code = b_clients.obj-code " + " " + where-phrase-59 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-discard:handle
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
    OPEN QUERY br-discard FOR EACH X_dis-card
      where  X_dis-card.cli-type = b_clients.obj-type AND X_dis-card.cli-code = b_clients.obj-code
    , FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0
       by X_dis-card.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-card )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-discard:handle:get-buffer-handle(1) = (buffer X_dis-card:handle) then do:
      assign
      parameter-2-59 = (if p-find-next then "true":u else "false":u )
      parameter-4-59 =
        "where ":u +  substitute('X_dis-card.cli-type = &1&2&1 AND X_dis-card.cli-code = &3 ', chr(34), b_clients.obj-type, b_clients.obj-code) + " ":u + where-phrase-59 + " ":u + p-find-condition + " " + ""
      parameter-5-59 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input rowid(X_dis-card)
                          ,input logical(parameter-2-59)
                          ,input no-lock
                          ,input (buffer X_dis-card:handle)
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
      parameter-3-59 =  "FOR EACH X_dis-card"
      parameter-4-59 =
        (
          if (" X_dis-card.cli-type = b_clients.obj-type AND X_dis-card.cli-code = b_clients.obj-code " + " " + where-phrase-59) <> ""
          then  substitute('X_dis-card.cli-type = &1&2&1 AND X_dis-card.cli-code = &3 ', chr(34), b_clients.obj-type, b_clients.obj-code) + " " + where-phrase-59
          else "true"
        )
      parameter-5-59 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0" + " " + p-find-condition)
      parameter-6-59 = if sort-phrase-59 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-card.d-card   "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-59
        )
      parameter-7-59 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
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
    when "card":u then do:
      if p-open-query then do:
        ASSIGN
        frame d-dis-card:TITLE = substitute("ДИСКОНТНЫЕ КАРТЫ ПО перв.осн. КАРТЕ &1" , p-first-main-card)
        .
      end.
      assign
      filter-point-name = filter-point-name0 + " " + p-list-mode
      filter-point = filter-point0 + " " + p-list-mode.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-61  as logical   no-undo .
define variable  l-filter-open-61    as logical   .
define variable  flt-rec-61       as recid     no-undo .
define variable  filter-name-61      as character no-undo .
define variable  where-phrase-61     as character no-undo .
define variable  sort-phrase-61      as character no-undo .
define variable  where-phrase-rus-61 as character no-undo .
define variable  sort-phrase-rus-61  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-61
  ,output filter-name-61
  ,output where-phrase-61
  ,output sort-phrase-61
  ,output where-phrase-rus-61
  ,output sort-phrase-rus-61
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-61
      ) no-error .
  assign
    l-filter-open-61 = false
  .
  if flt-rec-61 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-61 as character no-undo .
    define variable  parameter-3-61 as character no-undo .
    define variable  parameter-4-61 as character no-undo .
    define variable  parameter-5-61 as character no-undo .
    define variable  parameter-6-61 as character no-undo .
    define variable  parameter-7-61 as character no-undo .
      assign
      parameter-3-61 =
                              "FOR EACH X_dis-card"
      parameter-4-61 =
        (
          if (" X_dis-card.first-main-card = p-first-main-card " + " " + where-phrase-61) <> ""
          then  substitute('X_dis-card.first-main-card = &1&2&1', chr(34), p-first-main-card ) + " " + where-phrase-61
          else "true"
        )
      parameter-5-61 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0")
      parameter-6-61 = if sort-phrase-61 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-card.d-card   "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-61
        )
      parameter-7-61 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-61 =
          (" X_dis-card.first-main-card = p-first-main-card " + " " + where-phrase-61 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input parameter-3-61
                          ,input parameter-4-61
                          ,input parameter-5-61
                          ,input parameter-6-61
                          ,input parameter-7-61
                          )
      .
      assign
        l-filter-open-61 = true
      .
    end.
    if l-filter-open-61 = false then do:
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
  if l-filter-open-61 = false then do:
    OPEN QUERY br-discard FOR EACH X_dis-card
      where  X_dis-card.first-main-card = p-first-main-card
    , FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0
       by X_dis-card.d-card
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_dis-card )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-discard:handle:get-buffer-handle(1) = (buffer X_dis-card:handle) then do:
      assign
      parameter-2-61 = (if p-find-next then "true":u else "false":u )
      parameter-4-61 =
        "where ":u +  substitute('X_dis-card.first-main-card = &1&2&1', chr(34), p-first-main-card ) + " ":u + where-phrase-61 + " ":u + p-find-condition + " " + ""
      parameter-5-61 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input rowid(X_dis-card)
                          ,input logical(parameter-2-61)
                          ,input no-lock
                          ,input (buffer X_dis-card:handle)
                          ,input parameter-4-61
                          ,input parameter-5-61
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-61 = (if p-find-next then "true":u else "false":u )
      parameter-3-61 =  "FOR EACH X_dis-card"
      parameter-4-61 =
        (
          if (" X_dis-card.first-main-card = p-first-main-card " + " " + where-phrase-61) <> ""
          then  substitute('X_dis-card.first-main-card = &1&2&1', chr(34), p-first-main-card ) + " " + where-phrase-61
          else "true"
        )
      parameter-5-61 = (" " + "" + " " + ", FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_dis-card.cli-type AND X_clients.obj-code = X_dis-card.cli-code , FIRST X_dis-host NO-LOCK WHERE          X_dis-host.host-code = 0          AND X_dis-host.d-card = X_dis-card.d-card                        and X_dis-host.dt-code = 0" + " " + p-find-condition)
      parameter-6-61 = if sort-phrase-61 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " by X_dis-card.d-card   "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-61
        )
      parameter-7-61 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-discard:handle
                          ,input logical(parameter-2-61)
                          ,input no-lock
                          ,input parameter-3-61
                          ,input parameter-4-61
                          ,input parameter-5-61
                          ,input parameter-6-61
                          ,input parameter-7-61
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
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-discard to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-discard:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-discard in frame d-dis-card.
APPLY "ENTRY" TO br-discard.
END PROCEDURE.
PROCEDURE proc-b-disc :
DEFINE variable v-is-error AS LOGICAL NO-UNDO.
DEFINE variable v-update-dccr AS LOGICAL NO-UNDO.
define variable loc#log as logical no-undo .
IF NOT AVAILABLE X_dis-card THEN DO:
   disc-option = '':U.
   RETURN NO-APPLY.
END.
IF disc-option = 'ИЗМЕНЕНИЕ':U THEN DO:
define variable vss-include-info62 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_referense-dis_input-deletion-updating':U
    ,input  'firm':U
    ,input  p-curr-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output loc#log
    )  .
end.
END.
run ref/ddcrattr.p (
               input parparentproc
              ,input disc-option
              ,input X_dis-card.d-card
              ,input p-curr-host-code
              ,input p-curr-obj-type
              ,input p-curr-obj-code
              ,input yes
              ,output v-update-dccr
              ,output v-is-error
              ) no-error .
if error-status :error
or v-is-error
then do:
  message
  "Ошибка при вызове списка скидок ДК" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box .
  disc-option = '':U.
  undo, return error.
end.
END PROCEDURE.
PROCEDURE proc-b-history :
DEFINE INPUT PARAMETER loc-option as character no-undo.
define variable parref-list as character no-undo .
if not  available X_dis-card THEN return error.
CASE loc-option:
  when "c-dc-hist":U then do:
    run ref/cdchist.w (
                    INPUT parparentproc
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input "":U
                    ,input "one":U
                    ,input X_dis-card.d-card
                    ,input X_dis-card.card-num
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input p-curr-host-code
                    ,input ?
                    ,input "":U
                    ,input "":U
                    ,input ?
                    ,input-output parref-list
                 ) no-error .
  end.
  when "c-dc-hist-plus":U then do:
    run ref/cdchist.w (
                    INPUT parparentproc
                    ,input p-curr-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input "":U
                    ,input "card-num":U
                    ,input X_dis-card.d-card
                    ,input X_dis-card.card-num
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input p-curr-host-code
                    ,input ?
                    ,input "":U
                    ,input "":U
                    ,input ?
                   ,input-output parref-list
                 ) no-error .
  end.
END CASE.
apply "entry" to br-discard in frame d-dis-card.
END PROCEDURE.
PROCEDURE proc-b-prop :
define variable loc#log as logical no-undo.
define variable v-update-attr as logical no-undo .
define variable v-is-error as logical no-undo .
define variable log-res as logical no-undo .
define buffer prop_dis-card for ub.dis-card.
define buffer buf_dis-card-property for ub.dis-card-property.
if not available X_dis-card then return error .
FIND FIRST prop_dis-card No-LOCK WHERE
             recid(prop_dis-card) = recid(X_dis-card) no-error.
if not available prop_dis-card then return error .
IF prop-option = 'ИЗМЕНЕНИЕ':U THEN DO:
define variable vss-include-info63 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_referense-dis_input-deletion-updating':U
    ,input  'firm':U
    ,input  p-curr-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output loc#log
    )  .
end.
END.
do
on error undo, return error
:
  run ref/dc-propr.p ( input parparentproc
                 ,input (if prop_dis-card.status_ <> 'удал':U
                         and loc#log
                         AND prop-option = 'ИЗМЕНЕНИЕ':U
                         then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
                 ,input prop_dis-card.d-card
                 ,input prop_dis-card.emitent-host-code
                 ,input prop_dis-card.type
                 ,input p-curr-host-code
                 ,input p-curr-obj-type
                 ,input p-curr-obj-code
                 ,input yes
                 ,output v-update-attr
                 ,output v-is-error
                ) no-error .
  if error-status:error then undo, return error .
  if prop-option = 'ИЗМЕНЕНИЕ':U then do:
    ri = recid(X_dis-card).
    run OpenBr in this-procedure ( input yes, input no, input no).
    reposition br-discard to recid ri no-error.
    if error-status:error then do:
      if error-status:error then do:                           find first pos_dis-card no-lock where                                   recid(pos_dis-card) = ri no-error .                             message                             "Невозможно позиционироваться на записи ДИСКОНТНАЯ КАРТА" skip                            string(if avail pos_dis-card                                     then  substitute("Номер карты: &1"                                                     , pos_dis-card.d-card)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
    end.
    if available X_dis-card then do:
      log-res = br-discard:select-focused-row( ) in frame d-dis-card .
    end.
  end.
end.
END PROCEDURE.
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo.
assign
v-ri = (if avail X_dis-card then recid(X_dis-card) else ?)
.
assign
tbl = 'dis-card'
join-tbl = 'X_dis-card'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('cli-type*cli-code', 'Клиент(один)', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type', 'Тип клиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-code', 'Код клиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-pcnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('category', 'Категория', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('emitent-host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('issue-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('issue-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('valid-date', 'Действ.до', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('type', 'Тип карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('credit-card', 'Кредитная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sourced-card', 'К карте', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('saldo-rubl', 'Сальдо рубли', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('saldo-base', 'Сальдо баз_вал', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('main-card', 'Основная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('is-subsid', 'Дополнительная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('first-card', 'Первичная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('first-main-card', 'Первичная основная', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sourced-card', 'Перевыпущена к', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('overissue-num', 'Порядок в цепочке перевыпуска', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
DO on stop undo, leave:
    run gbl/filter.w (  input parparentproc
                  , input (filter-point + chr(4) +
                    filter-point-name + chr(4) +
                    string(yes))
                  , input tbl
                  , input join-tbl
                  , input fld
                  , input lab
                  , input spr
                  , input dim).
    run OpenBr in this-procedure ( input yes, input no, input no).
    if v-ri <> ? then do:
      reposition br-discard to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-discard in frame d-dis-card .
END .
END PROCEDURE.
PROCEDURE proc-find-client :
define input parameter p-next as logical no-undo.
define input parameter p-cli-code like ub.dis-card.cli-code no-undo.
define variable v-cli-code as character no-undo.
define variable v-cli-code-int as integer no-undo .
assign
v-cli-code-int = integer(p-cli-code)
NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    message "Введите ЧИСЛЕННЫЙ код клиента!" view-as alert-box ERROR.
    RETURN ERROR.
END.
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute("and (X_dis-card.cli-type = 'орг':U or X_dis-card.cli-type = 'чел':U) and X_dis-card.cli-code = &1 "
      , v-cli-code-int)
    ).
apply "entry":u to spattern in frame d-dis-card .
END PROCEDURE.
PROCEDURE proc-find-d-card :
define input parameter p-next as logical no-undo.
define input parameter p-d-card like ub.dis-card.d-card no-undo.
assign
p-d-card = replace(p-d-card, chr(34), "":U)
p-d-card = replace(p-d-card, chr(39), chr(39) + chr(39))
p-d-card = chr(34) + p-d-card + chr(34).
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute(" and X_dis-card.d-card  begins &1 " , p-d-card)
    ).
apply "entry":u to spattern in frame d-dis-card .
END PROCEDURE.
PROCEDURE proc-find-name :
define input parameter p-next as logical no-undo.
define input parameter p-name AS CHARACTER no-undo.
DEFINE VARIABLE v-cli-type LIKE ub.dis-card.cli-type NO-UNDO.
DEFINE VARIABLE v-cli-code LIKE ub.dis-card.cli-code NO-UNDO.
assign
p-name = replace(p-name, chr(34), "":U)
p-name = replace(p-name, chr(39), chr(39) + chr(39))
p-name = chr(34) + p-name + chr(34)
    .
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute(" and X_clients.obj-name begins &1 "
                      , p-name)).
apply "entry":u to spattern in frame d-dis-card .
END PROCEDURE.
