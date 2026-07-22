block-level on error undo, throw.
define input  parameter p-obj-type               as character no-undo .
define input  parameter p-obj-code               as integer   no-undo .
define output parameter p-err-num                as integer   no-undo .
define output parameter p-last-date              as date      no-undo .
define output parameter p-error-description      as character no-undo .
define output parameter p-detail-error-file-name as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: car-ahsp.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/car-ahsp.p $":U .
define variable vss-description as character no-undo initial "Программа проверки складского архива по поставщикам".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info6 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info6 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info6 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      assign
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
    or p-sum-base       = ?
    or p-sum-rubl       = ?
    or p-vat-base       = ?
    or p-vat-rubl       = ?
    or p-slt-base       = ?
    or p-slt-rubl       = ?
    or p-road-tax-base  = ?
    or p-road-tax-rubl  = ?
    or p-transport-base = ?
    or p-transport-rubl = ?
    or p-other-base     = ?
    or p-other-rubl     = ?
    or p-excise-base    = ?
    or p-excise-rubl    = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info6 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
define variable v-ind            as integer   no-undo .
define variable v-total-err      as integer   no-undo .
define variable v-today          as date      no-undo .
define variable v-time           as integer   no-undo .
define variable v-log-err-file   as character no-undo .
define stream sout .
define temp-table temp-date no-undo
  field arch-date          as date    format '99/99/9999':u
  field fact-ord-begin-day as decimal format '>>>,>>>,>>9.99':u
  field fact-ord-end-day   as decimal format '>>>,>>>,>>9.99':u
  field temp-date-ok       as logical
  index xpk is primary unique arch-date
    .
define temp-table temp-ot-supp-day no-undo
  field temp-cli-type       as character
  field temp-cli-code       as integer
  field temp-artic          as character
  field temp-prod-type      as character
  field temp-prod-code      as integer
  field temp-sum-type       as character
  field temp-cat-id         as character
  field temp-fact-qnty      as decimal
  field temp-sum-base       as decimal
  field temp-sum-rubl       as decimal
  field temp-VAT-base       as decimal
  field temp-VAT-rubl       as decimal
  field temp-SLT-base       as decimal
  field temp-SLT-rubl       as decimal
  field temp-road-tax-base  as decimal
  field temp-road-tax-rubl  as decimal
  field temp-excise-base    as decimal
  field temp-excise-rubl    as decimal
  field temp-transport-base as decimal
  field temp-transport-rubl as decimal
  field temp-other-base     as decimal
  field temp-other-rubl     as decimal
  index xpk is primary unique
    temp-cli-type
    temp-cli-code
    temp-artic
    temp-prod-type
    temp-prod-code
    temp-sum-type
    temp-cat-id
  index xie temp-sum-type
    .
define temp-table temp-stk-supp-line no-undo
  field temp-artic          as character
  field temp-prod-type      as character
  field temp-prod-code      as integer
  field temp-cli-type       as character
  field temp-cli-code       as integer
  field temp-fact-qnty      as decimal
  field temp-fact-order     as decimal
  field temp-gds-qnty       as decimal
  index xpk is primary unique
    temp-artic
    temp-prod-type
    temp-prod-code
    temp-cli-type
    temp-cli-code
    .
define temp-table temp-gds no-undo
  field temp-artic          as character
  field temp-prod-type      as character
  field temp-prod-code      as integer
  index xpk is primary unique
    temp-artic
    temp-prod-type
    temp-prod-code
    .
do
on error undo, return error return-value
:
  assign
    v-log-err-file = substitute('car-ahsp-&1-&2.err':U
                               ,p-obj-type
                               ,p-obj-code
                               )
    p-detail-error-file-name = v-log-err-file
  .
  os-delete value(v-log-err-file) .
  run fill-temp-date in this-procedure .
  run check-temp-date in this-procedure .
  run clear-temp-date in this-procedure .
  run clear-temp-ot-supp-day in this-procedure .
  run validate-free-zone in this-procedure .
  run clear-temp-stk-supp-line in this-procedure .
  run check-fact-order in this-procedure .
  run fill-temp-stk-supp-line in this-procedure .
  run check-free-zone-from-stk-supp-line in this-procedure .
  run check-sub-type-stk-supp-line in this-procedure .
  assign
    p-err-num = v-total-err
  .
end.
procedure clear-temp-date :
  define buffer buf_temp-date for temp-date .
  do
  on error undo, return error return-value
  :
    for each buf_temp-date
    on error undo, return error return-value
    :
      delete buf_temp-date .
    end.
  end.
end procedure.
procedure fill-temp-date :
  define variable v-attr-value          as character no-undo .
  define variable v-attr-type           as character no-undo .
  define variable v-ahsp-detail-date    as date      no-undo .
  define variable v-fact-ord-begin-ahsp as decimal   no-undo .
  define variable v-fact-date           as date      no-undo .
  define variable v-fact-ord-begin-day  as decimal   no-undo .
  define variable v-fact-ord-end-day    as decimal   no-undo .
  define buffer buf_temp-date for temp-date .
  define buffer buf_ot-supp-line for ub.ot-supp-line .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  do
  on error undo, return error return-value
  :
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'ahsp-detail':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-ahsp-detail-date = date(v-attr-value)
    .
    if v-ahsp-detail-date <> ?
    then do:
      run day-begin-fact-order in this-procedure
        (input  v-ahsp-detail-date
        ,output v-fact-ord-begin-ahsp
        ) .
    end.
    else do:
      assign
        v-fact-ord-begin-ahsp = 0
      .
    end.
    find first buf_ot-supp-line no-lock
      where buf_ot-supp-line.obj-type   = p-obj-type
        and buf_ot-supp-line.obj-code   = p-obj-code
        and buf_ot-supp-line.fact-order > v-fact-ord-begin-ahsp
      use-index fact-order
      no-error .
    do while available buf_ot-supp-line
    :
      run factord-to-date in this-procedure
        (input  buf_ot-supp-line.fact-order
        ,output v-fact-date
        ) .
      run day-begin-fact-order in this-procedure
        (input  v-fact-date
        ,output v-fact-ord-begin-day
        ) .
      run factord-end-day in this-procedure
        (input  v-fact-date
        ,output v-fact-ord-end-day
        ) .
      create buf_temp-date .
      assign
        buf_temp-date.arch-date          = v-fact-date
        buf_temp-date.fact-ord-begin-day = v-fact-ord-begin-day
        buf_temp-date.fact-ord-end-day   = v-fact-ord-end-day
      .
      find first buf_ot-supp-line no-lock
        where buf_ot-supp-line.obj-type   = p-obj-type
          and buf_ot-supp-line.obj-code   = p-obj-code
          and buf_ot-supp-line.fact-order > v-fact-ord-end-day
        use-index fact-order
        no-error .
    end.
    find first buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.fact-order > v-fact-ord-begin-ahsp
      use-index fact-order
      no-error .
    do while available buf_stk-supp-line
    :
      run factord-to-date in this-procedure
        (input  buf_stk-supp-line.fact-order
        ,output v-fact-date
        ) .
      run day-begin-fact-order in this-procedure
        (input  v-fact-date
        ,output v-fact-ord-begin-day
        ) .
      run factord-end-day in this-procedure
        (input  v-fact-date
        ,output v-fact-ord-end-day
        ) .
      find first buf_temp-date
        where buf_temp-date.arch-date = v-fact-date
        no-error .
      if not available buf_temp-date
      then do:
        create buf_temp-date .
        assign
          buf_temp-date.arch-date          = v-fact-date
          buf_temp-date.fact-ord-begin-day = v-fact-ord-begin-day
          buf_temp-date.fact-ord-end-day   = v-fact-ord-end-day
        .
      end.
      find first buf_stk-supp-line no-lock
        where buf_stk-supp-line.obj-type   = p-obj-type
          and buf_stk-supp-line.obj-code   = p-obj-code
          and buf_stk-supp-line.fact-order > v-fact-ord-end-day
        use-index fact-order
        no-error .
    end.
  end.
end procedure.
procedure check-temp-date :
  define buffer buf_temp-date for temp-date .
  do
  on error undo, return error return-value
  :
    define variable v-ahsp-detail-date as date      no-undo .
    define variable v-attr-value      as character no-undo .
    define variable v-attr-type       as character no-undo .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'ahsp-detail':U
      ,output v-attr-value
      ,output v-attr-type
      ) .
    assign
      v-ahsp-detail-date = date(v-attr-value)
    .
    for each buf_temp-date
    on error undo, return error return-value
    :
      run waitfram-show in this-procedure
        (input substitute("Анализ складского архива по поставщикам. Ошибок &1. Объект &2 &3. Дата &4."
                        ,v-total-err
                        ,p-obj-type
                        ,p-obj-code
                        ,string(buf_temp-date.arch-date, '99/99/9999':u)
                        )
        ).
      run clear-temp-ot-supp-day in this-procedure .
      run fill-temp-ot-supp-day in this-procedure
        (input  buf_temp-date.arch-date
        ,input  buf_temp-date.fact-ord-begin-day
        ,input  buf_temp-date.fact-ord-end-day
        ) .
      run validate-ot-supp-line-stk in this-procedure
        (input  buf_temp-date.arch-date
        ,input  buf_temp-date.fact-ord-begin-day
        ,input  buf_temp-date.fact-ord-end-day
        ) .
      run validate-ot-supp-line-cost-sale in this-procedure
        (input  buf_temp-date.arch-date
        ,input  buf_temp-date.fact-ord-begin-day
        ,input  buf_temp-date.fact-ord-end-day
        ,input  'cost':U
        ,input  'sale':U
        ) .
      run validate-ot-supp-line-cost-sale in this-procedure
        (input buf_temp-date.arch-date
        ,input buf_temp-date.fact-ord-begin-day
        ,input buf_temp-date.fact-ord-end-day
        ,input 'sale':U
        ,input 'cost':U
        ) .
      if v-ahsp-detail-date = ?
      or (v-ahsp-detail-date <> ?
          and buf_temp-date.arch-date >= v-ahsp-detail-date
         )
      then do:
        run validate-stk-supp-line in this-procedure
          (input buf_temp-date.arch-date
          ,input buf_temp-date.fact-ord-begin-day
          ,input buf_temp-date.fact-ord-end-day
          ) .
      end.
    end.
  end.
end procedure.
procedure validate-ot-supp-line-stk :
  define input  parameter p-fact-date            as date      no-undo .
  define input  parameter p-fact-order-begin-day as decimal   no-undo .
  define input  parameter p-fact-order-end-day   as decimal   no-undo .
  define variable v-fact-qnty      as decimal   no-undo .
  define variable v-sum-base       as decimal   no-undo .
  define variable v-sum-rubl       as decimal   no-undo .
  define variable v-VAT-base       as decimal   no-undo .
  define variable v-VAT-rubl       as decimal   no-undo .
  define variable v-SLT-base       as decimal   no-undo .
  define variable v-SLT-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-excise-base    as decimal   no-undo .
  define variable v-excise-rubl    as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .
  define buffer buf_stk-supp-line    for ub.stk-supp-line .
  define buffer buf_temp-ot-supp-day for temp-ot-supp-day .
  do
  on error undo, return error return-value
  :
    for each buf_temp-ot-supp-day
    on error undo, return error return-value
    :
      if buf_temp-ot-supp-day.temp-sum-type begins 'cost':U
      or buf_temp-ot-supp-day.temp-sum-type begins 'csdt':U
      or buf_temp-ot-supp-day.temp-sum-type begins 'sadt':U
      then do:
        if buf_temp-ot-supp-day.temp-sum-type begins 'cost':U
        then do:
          find last buf_stk-supp-line no-lock
            where buf_stk-supp-line.obj-type   = p-obj-type
              and buf_stk-supp-line.obj-code   = p-obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-ot-supp-day.temp-cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-ot-supp-day.temp-cli-code
              and buf_stk-supp-line.artic      = buf_temp-ot-supp-day.temp-artic
              and buf_stk-supp-line.prod-type  = buf_temp-ot-supp-day.temp-prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-ot-supp-day.temp-prod-code
              and buf_stk-supp-line.sum-type   = 'cost':U
              and buf_stk-supp-line.cat-id     = '##':U
              and buf_stk-supp-line.fact-order < p-fact-order-begin-day
              and buf_stk-supp-line.shift-date = ?
            use-index category
            no-error .
          if  available buf_stk-supp-line
          and buf_temp-ot-supp-day.temp-sum-type <> 'cost':U
          then do:
            define variable v-sub-fact-order as decimal   no-undo .
            assign
              v-sub-fact-order = buf_stk-supp-line.fact-order
            .
            find last buf_stk-supp-line no-lock
              where buf_stk-supp-line.obj-type   = p-obj-type
                and buf_stk-supp-line.obj-code   = p-obj-code
                and buf_stk-supp-line.cli-type   = buf_temp-ot-supp-day.temp-cli-type
                and buf_stk-supp-line.cli-code   = buf_temp-ot-supp-day.temp-cli-code
                and buf_stk-supp-line.artic      = buf_temp-ot-supp-day.temp-artic
                and buf_stk-supp-line.prod-type  = buf_temp-ot-supp-day.temp-prod-type
                and buf_stk-supp-line.prod-code  = buf_temp-ot-supp-day.temp-prod-code
                and buf_stk-supp-line.sum-type   = buf_temp-ot-supp-day.temp-sum-type
                and buf_stk-supp-line.cat-id     = buf_temp-ot-supp-day.temp-cat-id
                and buf_stk-supp-line.fact-order = v-sub-fact-order
                and buf_stk-supp-line.shift-date = ?
              use-index category
              no-error .
          end.
        end.
        else do:
          find last buf_stk-supp-line no-lock
            where buf_stk-supp-line.obj-type   = p-obj-type
              and buf_stk-supp-line.obj-code   = p-obj-code
              and buf_stk-supp-line.cli-type   = buf_temp-ot-supp-day.temp-cli-type
              and buf_stk-supp-line.cli-code   = buf_temp-ot-supp-day.temp-cli-code
              and buf_stk-supp-line.artic      = buf_temp-ot-supp-day.temp-artic
              and buf_stk-supp-line.prod-type  = buf_temp-ot-supp-day.temp-prod-type
              and buf_stk-supp-line.prod-code  = buf_temp-ot-supp-day.temp-prod-code
              and buf_stk-supp-line.sum-type   = buf_temp-ot-supp-day.temp-sum-type
              and buf_stk-supp-line.cat-id     = buf_temp-ot-supp-day.temp-cat-id
              and buf_stk-supp-line.fact-order < p-fact-order-begin-day
              and buf_stk-supp-line.shift-date = ?
            use-index category
            no-error .
        end.
        if available buf_stk-supp-line
        then do:
          assign
            v-fact-qnty      = - buf_stk-supp-line.fact-qnty
            v-sum-base       = - buf_stk-supp-line.sum-base
            v-sum-rubl       = - buf_stk-supp-line.sum-rubl
            v-VAT-base       = - buf_stk-supp-line.VAT-base
            v-VAT-rubl       = - buf_stk-supp-line.VAT-rubl
            v-SLT-base       = - buf_stk-supp-line.SLT-base
            v-SLT-rubl       = - buf_stk-supp-line.SLT-rubl
            v-road-tax-base  = - buf_stk-supp-line.road-tax-base
            v-road-tax-rubl  = - buf_stk-supp-line.road-tax-rubl
            v-excise-base    = - buf_stk-supp-line.excise-base
            v-excise-rubl    = - buf_stk-supp-line.excise-rubl
            v-transport-base = - buf_stk-supp-line.transport-base
            v-transport-rubl = - buf_stk-supp-line.transport-rubl
            v-other-base     = - buf_stk-supp-line.other-base
            v-other-rubl     = - buf_stk-supp-line.other-rubl
          .
        end.
        else do:
          assign
            v-fact-qnty      = 0
            v-sum-base       = 0
            v-sum-rubl       = 0
            v-VAT-base       = 0
            v-VAT-rubl       = 0
            v-SLT-base       = 0
            v-SLT-rubl       = 0
            v-road-tax-base  = 0
            v-road-tax-rubl  = 0
            v-excise-base    = 0
            v-excise-rubl    = 0
            v-transport-base = 0
            v-transport-rubl = 0
            v-other-base     = 0
            v-other-rubl     = 0
          .
        end.
        assign
          v-fact-qnty      = v-fact-qnty      - buf_temp-ot-supp-day.temp-fact-qnty
          v-sum-base       = v-sum-base       - buf_temp-ot-supp-day.temp-sum-base
          v-sum-rubl       = v-sum-rubl       - buf_temp-ot-supp-day.temp-sum-rubl
          v-VAT-base       = v-VAT-base       - buf_temp-ot-supp-day.temp-VAT-base
          v-VAT-rubl       = v-VAT-rubl       - buf_temp-ot-supp-day.temp-VAT-rubl
          v-SLT-base       = v-SLT-base       - buf_temp-ot-supp-day.temp-SLT-base
          v-SLT-rubl       = v-SLT-rubl       - buf_temp-ot-supp-day.temp-SLT-rubl
          v-road-tax-base  = v-road-tax-base  - buf_temp-ot-supp-day.temp-road-tax-base
          v-road-tax-rubl  = v-road-tax-rubl  - buf_temp-ot-supp-day.temp-road-tax-rubl
          v-excise-base    = v-excise-base    - buf_temp-ot-supp-day.temp-excise-base
          v-excise-rubl    = v-excise-rubl    - buf_temp-ot-supp-day.temp-excise-rubl
          v-transport-base = v-transport-base - buf_temp-ot-supp-day.temp-transport-base
          v-transport-rubl = v-transport-rubl - buf_temp-ot-supp-day.temp-transport-rubl
          v-other-base     = v-other-base     - buf_temp-ot-supp-day.temp-other-base
          v-other-rubl     = v-other-rubl     - buf_temp-ot-supp-day.temp-other-rubl
        .
        find first buf_stk-supp-line no-lock
          where buf_stk-supp-line.obj-type   = p-obj-type
            and buf_stk-supp-line.obj-code   = p-obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-ot-supp-day.temp-cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-ot-supp-day.temp-cli-code
            and buf_stk-supp-line.artic      = buf_temp-ot-supp-day.temp-artic
            and buf_stk-supp-line.prod-type  = buf_temp-ot-supp-day.temp-prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-ot-supp-day.temp-prod-code
            and buf_stk-supp-line.sum-type   = buf_temp-ot-supp-day.temp-sum-type
            and buf_stk-supp-line.cat-id     = buf_temp-ot-supp-day.temp-cat-id
            and buf_stk-supp-line.fact-order = p-fact-order-end-day
          use-index category
          no-error .
        if available buf_stk-supp-line
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      + buf_stk-supp-line.fact-qnty
            v-sum-base       = v-sum-base       + buf_stk-supp-line.sum-base
            v-sum-rubl       = v-sum-rubl       + buf_stk-supp-line.sum-rubl
            v-VAT-base       = v-VAT-base       + buf_stk-supp-line.VAT-base
            v-VAT-rubl       = v-VAT-rubl       + buf_stk-supp-line.VAT-rubl
            v-SLT-base       = v-SLT-base       + buf_stk-supp-line.SLT-base
            v-SLT-rubl       = v-SLT-rubl       + buf_stk-supp-line.SLT-rubl
            v-road-tax-base  = v-road-tax-base  + buf_stk-supp-line.road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  + buf_stk-supp-line.road-tax-rubl
            v-excise-base    = v-excise-base    + buf_stk-supp-line.excise-base
            v-excise-rubl    = v-excise-rubl    + buf_stk-supp-line.excise-rubl
            v-transport-base = v-transport-base + buf_stk-supp-line.transport-base
            v-transport-rubl = v-transport-rubl + buf_stk-supp-line.transport-rubl
            v-other-base     = v-other-base     + buf_stk-supp-line.other-base
            v-other-rubl     = v-other-rubl     + buf_stk-supp-line.other-rubl
          .
        end.
        else do:
          if  buf_temp-ot-supp-day.temp-sum-type begins 'cost':U
          and buf_temp-ot-supp-day.temp-sum-type <>     'cost':U
          and v-fact-qnty       = 0
          and v-sum-base        = 0
          and v-sum-rubl        = 0
          and v-VAT-base        = 0
          and v-VAT-rubl        = 0
          and v-SLT-base        = 0
          and v-SLT-rubl        = 0
          and v-road-tax-base   = 0
          and v-road-tax-rubl   = 0
          and v-excise-base     = 0
          and v-excise-rubl     = 0
          and v-transport-base  = 0
          and v-transport-rubl  = 0
          and v-other-base      = 0
          and v-other-rubl      = 0
          then do:
          end.
          else do:
            assign
              v-total-err = v-total-err + 1
            .
            run cur-time in this-procedure
              (output v-today
              ,output v-time
              ) .
            run update-last-date in this-procedure
              (input p-fact-date
              ) .
            output stream sout to value(v-log-err-file) append .
            export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
            export stream sout "error-01: stk-supp-line not found" .
            export stream sout "obj-type"       p-obj-type                          .
            export stream sout "obj-code"       p-obj-code                          .
            export stream sout "fact-date"      p-fact-date                         .
            export stream sout "cli-type"       buf_temp-ot-supp-day.temp-cli-type  .
            export stream sout "cli-code"       buf_temp-ot-supp-day.temp-cli-code  .
            export stream sout "artic"          buf_temp-ot-supp-day.temp-artic     .
            export stream sout "prod-type"      buf_temp-ot-supp-day.temp-prod-type .
            export stream sout "prod-code"      buf_temp-ot-supp-day.temp-prod-code .
            export stream sout "sum-type"       buf_temp-ot-supp-day.temp-sum-type  .
            export stream sout "cat-id"         buf_temp-ot-supp-day.temp-cat-id    .
            export stream sout "fact-order"     p-fact-order-end-day                .
            export stream sout "fact-qnty"      v-fact-qnty                         .
            export stream sout "sum-base"       v-sum-base                          .
            export stream sout "sum-rubl"       v-sum-rubl                          .
            export stream sout "VAT-base"       v-VAT-base                          .
            export stream sout "VAT-rubl"       v-VAT-rubl                          .
            export stream sout "SLT-base"       v-SLT-base                          .
            export stream sout "SLT-rubl"       v-SLT-rubl                          .
            export stream sout "road-tax-base"  v-road-tax-base                     .
            export stream sout "road-tax-rubl"  v-road-tax-rubl                     .
            export stream sout "excise-base"    v-excise-base                       .
            export stream sout "excise-rubl"    v-excise-rubl                       .
            export stream sout "transport-base" v-transport-base                    .
            export stream sout "transport-rubl" v-transport-rubl                    .
            export stream sout "other-base"     v-other-base                        .
            export stream sout "other-rubl"     v-other-rubl                        .
            output stream sout close .
          end.
        end.
        if v-fact-qnty      <> 0
        or v-sum-base       <> 0
        or v-sum-rubl       <> 0
        or v-VAT-base       <> 0
        or v-VAT-rubl       <> 0
        or v-SLT-base       <> 0
        or v-SLT-rubl       <> 0
        or v-road-tax-base  <> 0
        or v-road-tax-rubl  <> 0
        or v-excise-base    <> 0
        or v-excise-rubl    <> 0
        or v-transport-base <> 0
        or v-transport-rubl <> 0
        or v-other-base     <> 0
        or v-other-rubl     <> 0
        then do:
          assign
            v-total-err = v-total-err + 1
          .
          run cur-time in this-procedure
            (output v-today
            ,output v-time
            ) .
          run update-last-date in this-procedure
            (input p-fact-date
            ) .
          output stream sout to value(v-log-err-file) append .
          export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
          export stream sout "error-02: stk-supp-line different quantity" .
          export stream sout "obj-type"       p-obj-type                          .
          export stream sout "obj-code"       p-obj-code                          .
          export stream sout "fact-date"      p-fact-date                         .
          export stream sout "cli-type"       buf_temp-ot-supp-day.temp-cli-type  .
          export stream sout "cli-code"       buf_temp-ot-supp-day.temp-cli-code  .
          export stream sout "artic"          buf_temp-ot-supp-day.temp-artic     .
          export stream sout "prod-type"      buf_temp-ot-supp-day.temp-prod-type .
          export stream sout "prod-code"      buf_temp-ot-supp-day.temp-prod-code .
          export stream sout "sum-type"       buf_temp-ot-supp-day.temp-sum-type  .
          export stream sout "cat-id"         buf_temp-ot-supp-day.temp-cat-id    .
          export stream sout "fact-order"     p-fact-order-end-day                .
          export stream sout "fact-qnty"      v-fact-qnty                         .
          export stream sout "sum-base"       v-sum-base                          .
          export stream sout "sum-rubl"       v-sum-rubl                          .
          export stream sout "VAT-base"       v-VAT-base                          .
          export stream sout "VAT-rubl"       v-VAT-rubl                          .
          export stream sout "SLT-base"       v-SLT-base                          .
          export stream sout "SLT-rubl"       v-SLT-rubl                          .
          export stream sout "road-tax-base"  v-road-tax-base                     .
          export stream sout "road-tax-rubl"  v-road-tax-rubl                     .
          export stream sout "excise-base"    v-excise-base                       .
          export stream sout "excise-rubl"    v-excise-rubl                       .
          export stream sout "transport-base" v-transport-base                    .
          export stream sout "transport-rubl" v-transport-rubl                    .
          export stream sout "other-base"     v-other-base                        .
          export stream sout "other-rubl"     v-other-rubl                        .
          output stream sout close .
        end.
      end.
    end.
  end.
end procedure.
procedure validate-ot-supp-line-cost-sale :
  define input  parameter p-fact-date            as date      no-undo .
  define input  parameter p-fact-order-begin-day as decimal   no-undo .
  define input  parameter p-fact-order-end-day   as decimal   no-undo .
  define input  parameter p-scan-sum-type        as character no-undo .
  define input  parameter p-compare-sum-type     as character no-undo .
  define variable v-fact-qnty      as decimal   no-undo .
  define variable v-sum-base       as decimal   no-undo .
  define variable v-sum-rubl       as decimal   no-undo .
  define variable v-VAT-base       as decimal   no-undo .
  define variable v-VAT-rubl       as decimal   no-undo .
  define variable v-SLT-base       as decimal   no-undo .
  define variable v-SLT-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-excise-base    as decimal   no-undo .
  define variable v-excise-rubl    as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .
  define buffer buf_temp-ot-supp-day      for temp-ot-supp-day .
  define buffer buf_other_temp-ot-supp-day for temp-ot-supp-day .
  do
  on error undo, return error return-value
  :
    for each buf_temp-ot-supp-day
      where buf_temp-ot-supp-day.temp-sum-type = p-scan-sum-type
    on error undo, return error return-value
    :
      find first buf_other_temp-ot-supp-day
        where buf_other_temp-ot-supp-day.temp-cli-type  = buf_temp-ot-supp-day.temp-cli-type
          and buf_other_temp-ot-supp-day.temp-cli-code  = buf_temp-ot-supp-day.temp-cli-code
          and buf_other_temp-ot-supp-day.temp-artic     = buf_temp-ot-supp-day.temp-artic
          and buf_other_temp-ot-supp-day.temp-prod-type = buf_temp-ot-supp-day.temp-prod-type
          and buf_other_temp-ot-supp-day.temp-prod-code = buf_temp-ot-supp-day.temp-prod-code
          and buf_other_temp-ot-supp-day.temp-sum-type  = p-compare-sum-type
          and buf_other_temp-ot-supp-day.temp-cat-id    = '##':U
        no-error .
      if (available buf_other_temp-ot-supp-day
          and buf_other_temp-ot-supp-day.temp-fact-qnty <> buf_temp-ot-supp-day.temp-fact-qnty
         )
      or (not available buf_other_temp-ot-supp-day
          and buf_temp-ot-supp-day.temp-fact-qnty <> 0
         )
      then do:
        assign
          v-total-err = v-total-err + 1
        .
        run cur-time in this-procedure
          (output v-today
          ,output v-time
          ) .
        run update-last-date in this-procedure
          (input p-fact-date
          ) .
        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        if available buf_other_temp-ot-supp-day
        then do:
          export stream sout "error-03: " + p-compare-sum-type + " record not found" .
        end.
        else do:
          export stream sout "error-04: " + p-compare-sum-type + " record different quantity" .
        end.
        export stream sout "obj-type"  p-obj-type                               .
        export stream sout "obj-code"  p-obj-code                               .
        export stream sout "fact-date" p-fact-date                              .
        export stream sout "cli-type"  buf_temp-ot-supp-day.temp-cli-type       .
        export stream sout "cli-code"  buf_temp-ot-supp-day.temp-cli-code       .
        export stream sout "artic"     buf_temp-ot-supp-day.temp-artic          .
        export stream sout "prod-type" buf_temp-ot-supp-day.temp-prod-type      .
        export stream sout "prod-code" buf_temp-ot-supp-day.temp-prod-code      .
        export stream sout "sum-type"  buf_temp-ot-supp-day.temp-sum-type       .
        export stream sout "cat-id"    buf_temp-ot-supp-day.temp-cat-id         .
        export stream sout p-scan-sum-type + "-fact-order"     p-fact-order-end-day                     .
        export stream sout p-scan-sum-type + "-fact-qnty"      buf_temp-ot-supp-day.temp-fact-qnty           .
        export stream sout p-scan-sum-type + "-sum-base"       buf_temp-ot-supp-day.temp-sum-base            .
        export stream sout p-scan-sum-type + "-sum-rubl"       buf_temp-ot-supp-day.temp-sum-rubl            .
        export stream sout p-scan-sum-type + "-VAT-base"       buf_temp-ot-supp-day.temp-VAT-base            .
        export stream sout p-scan-sum-type + "-VAT-rubl"       buf_temp-ot-supp-day.temp-VAT-rubl            .
        export stream sout p-scan-sum-type + "-SLT-base"       buf_temp-ot-supp-day.temp-SLT-base            .
        export stream sout p-scan-sum-type + "-SLT-rubl"       buf_temp-ot-supp-day.temp-SLT-rubl            .
        export stream sout p-scan-sum-type + "-road-tax-base"  buf_temp-ot-supp-day.temp-road-tax-base       .
        export stream sout p-scan-sum-type + "-road-tax-rubl"  buf_temp-ot-supp-day.temp-road-tax-rubl       .
        export stream sout p-scan-sum-type + "-excise-base"    buf_temp-ot-supp-day.temp-excise-base         .
        export stream sout p-scan-sum-type + "-excise-rubl"    buf_temp-ot-supp-day.temp-excise-rubl         .
        export stream sout p-scan-sum-type + "-transport-base" buf_temp-ot-supp-day.temp-transport-base      .
        export stream sout p-scan-sum-type + "-transport-rubl" buf_temp-ot-supp-day.temp-transport-rubl      .
        export stream sout p-scan-sum-type + "-other-base"     buf_temp-ot-supp-day.temp-other-base          .
        export stream sout p-scan-sum-type + "-other-rubl"     buf_temp-ot-supp-day.temp-other-rubl          .
        if available buf_other_temp-ot-supp-day
        then do:
          export stream sout p-compare-sum-type + "-fact-qnty"      buf_other_temp-ot-supp-day.temp-fact-qnty      .
          export stream sout p-compare-sum-type + "-sum-base"       buf_other_temp-ot-supp-day.temp-sum-base       .
          export stream sout p-compare-sum-type + "-sum-rubl"       buf_other_temp-ot-supp-day.temp-sum-rubl       .
          export stream sout p-compare-sum-type + "-VAT-base"       buf_other_temp-ot-supp-day.temp-VAT-base       .
          export stream sout p-compare-sum-type + "-VAT-rubl"       buf_other_temp-ot-supp-day.temp-VAT-rubl       .
          export stream sout p-compare-sum-type + "-SLT-base"       buf_other_temp-ot-supp-day.temp-SLT-base       .
          export stream sout p-compare-sum-type + "-SLT-rubl"       buf_other_temp-ot-supp-day.temp-SLT-rubl       .
          export stream sout p-compare-sum-type + "-road-tax-base"  buf_other_temp-ot-supp-day.temp-road-tax-base  .
          export stream sout p-compare-sum-type + "-road-tax-rubl"  buf_other_temp-ot-supp-day.temp-road-tax-rubl  .
          export stream sout p-compare-sum-type + "-excise-base"    buf_other_temp-ot-supp-day.temp-excise-base    .
          export stream sout p-compare-sum-type + "-excise-rubl"    buf_other_temp-ot-supp-day.temp-excise-rubl    .
          export stream sout p-compare-sum-type + "-transport-base" buf_other_temp-ot-supp-day.temp-transport-base .
          export stream sout p-compare-sum-type + "-transport-rubl" buf_other_temp-ot-supp-day.temp-transport-rubl .
          export stream sout p-compare-sum-type + "-other-base"     buf_other_temp-ot-supp-day.temp-other-base     .
          export stream sout p-compare-sum-type + "-other-rubl"     buf_other_temp-ot-supp-day.temp-other-rubl     .
        end.
        output stream sout close .
      end.
    end.
  end.
end procedure.
procedure clear-temp-ot-supp-day :
  define buffer buf_temp-ot-supp-day for temp-ot-supp-day .
  do
  on error undo, return error return-value
  :
    for each buf_temp-ot-supp-day
    on error undo, return error return-value
    :
      delete buf_temp-ot-supp-day .
    end.
  end.
end procedure.
procedure fill-temp-ot-supp-day :
  define input  parameter p-fact-date            as date      no-undo .
  define input  parameter p-fact-order-begin-day as decimal   no-undo .
  define input  parameter p-fact-order-end-day   as decimal   no-undo .
  define buffer buf_temp-ot-supp-day for temp-ot-supp-day .
  define buffer buf_ot-supp-line     for ub.ot-supp-line .
  do
  on error undo, return error return-value
  :
    for each buf_ot-supp-line no-lock
      where buf_ot-supp-line.obj-type   = p-obj-type
        and buf_ot-supp-line.obj-code   = p-obj-code
        and buf_ot-supp-line.fact-order > p-fact-order-begin-day
        and buf_ot-supp-line.fact-order < p-fact-order-end-day
    on error undo, return error return-value
    :
      find first buf_temp-ot-supp-day
        where buf_temp-ot-supp-day.temp-cli-type  = buf_ot-supp-line.cli-type
          and buf_temp-ot-supp-day.temp-cli-code  = buf_ot-supp-line.cli-code
          and buf_temp-ot-supp-day.temp-artic     = buf_ot-supp-line.artic
          and buf_temp-ot-supp-day.temp-prod-type = buf_ot-supp-line.prod-type
          and buf_temp-ot-supp-day.temp-prod-code = buf_ot-supp-line.prod-code
          and buf_temp-ot-supp-day.temp-sum-type  = buf_ot-supp-line.sum-type
          and buf_temp-ot-supp-day.temp-cat-id    = buf_ot-supp-line.cat-id
        no-error .
      if not available buf_temp-ot-supp-day
      then do:
        create buf_temp-ot-supp-day .
        assign
          buf_temp-ot-supp-day.temp-cli-type  = buf_ot-supp-line.cli-type
          buf_temp-ot-supp-day.temp-cli-code  = buf_ot-supp-line.cli-code
          buf_temp-ot-supp-day.temp-artic     = buf_ot-supp-line.artic
          buf_temp-ot-supp-day.temp-prod-type = buf_ot-supp-line.prod-type
          buf_temp-ot-supp-day.temp-prod-code = buf_ot-supp-line.prod-code
          buf_temp-ot-supp-day.temp-sum-type  = buf_ot-supp-line.sum-type
          buf_temp-ot-supp-day.temp-cat-id    = buf_ot-supp-line.cat-id
        .
      end.
      assign
        buf_temp-ot-supp-day.temp-fact-qnty      = buf_temp-ot-supp-day.temp-fact-qnty
                                                 + buf_ot-supp-line.fact-qnty
        buf_temp-ot-supp-day.temp-sum-base       = buf_temp-ot-supp-day.temp-sum-base
                                                 + buf_ot-supp-line.sum-base
        buf_temp-ot-supp-day.temp-sum-rubl       = buf_temp-ot-supp-day.temp-sum-rubl
                                                 + buf_ot-supp-line.sum-rubl
        buf_temp-ot-supp-day.temp-VAT-base       = buf_temp-ot-supp-day.temp-VAT-base
                                                 + buf_ot-supp-line.VAT-base
        buf_temp-ot-supp-day.temp-VAT-rubl       = buf_temp-ot-supp-day.temp-VAT-rubl
                                                 + buf_ot-supp-line.VAT-rubl
        buf_temp-ot-supp-day.temp-SLT-base       = buf_temp-ot-supp-day.temp-SLT-base
                                                 + buf_ot-supp-line.SLT-base
        buf_temp-ot-supp-day.temp-SLT-rubl       = buf_temp-ot-supp-day.temp-SLT-rubl
                                                 + buf_ot-supp-line.SLT-rubl
        buf_temp-ot-supp-day.temp-road-tax-base  = buf_temp-ot-supp-day.temp-road-tax-base
                                                 + buf_ot-supp-line.road-tax-base
        buf_temp-ot-supp-day.temp-road-tax-rubl  = buf_temp-ot-supp-day.temp-road-tax-rubl
                                                 + buf_ot-supp-line.road-tax-rubl
        buf_temp-ot-supp-day.temp-excise-base    = buf_temp-ot-supp-day.temp-excise-base
                                                 + buf_ot-supp-line.excise-base
        buf_temp-ot-supp-day.temp-excise-rubl    = buf_temp-ot-supp-day.temp-excise-rubl
                                                 + buf_ot-supp-line.excise-rubl
        buf_temp-ot-supp-day.temp-transport-base = buf_temp-ot-supp-day.temp-transport-base
                                                 + buf_ot-supp-line.transport-base
        buf_temp-ot-supp-day.temp-transport-rubl = buf_temp-ot-supp-day.temp-transport-rubl
                                                 + buf_ot-supp-line.transport-rubl
        buf_temp-ot-supp-day.temp-other-base     = buf_temp-ot-supp-day.temp-other-base
                                                 + buf_ot-supp-line.other-base
        buf_temp-ot-supp-day.temp-other-rubl     = buf_temp-ot-supp-day.temp-other-rubl
                                                 + buf_ot-supp-line.other-rubl
      .
      if buf_ot-supp-line.sum-type = 'cost':U
      then do:
        find first buf_temp-ot-supp-day
          where buf_temp-ot-supp-day.temp-cli-type  = buf_ot-supp-line.cli-type
            and buf_temp-ot-supp-day.temp-cli-code  = buf_ot-supp-line.cli-code
            and buf_temp-ot-supp-day.temp-artic     = buf_ot-supp-line.artic
            and buf_temp-ot-supp-day.temp-prod-type = buf_ot-supp-line.prod-type
            and buf_temp-ot-supp-day.temp-prod-code = buf_ot-supp-line.prod-code
            and buf_temp-ot-supp-day.temp-sum-type  = 'csdt':U + buf_ot-supp-line.ext-doc-type
            and buf_temp-ot-supp-day.temp-cat-id    = '##':U
          no-error .
        if not available buf_temp-ot-supp-day
        then do:
          create buf_temp-ot-supp-day .
          assign
            buf_temp-ot-supp-day.temp-cli-type  = buf_ot-supp-line.cli-type
            buf_temp-ot-supp-day.temp-cli-code  = buf_ot-supp-line.cli-code
            buf_temp-ot-supp-day.temp-artic     = buf_ot-supp-line.artic
            buf_temp-ot-supp-day.temp-prod-type = buf_ot-supp-line.prod-type
            buf_temp-ot-supp-day.temp-prod-code = buf_ot-supp-line.prod-code
            buf_temp-ot-supp-day.temp-sum-type  = 'csdt':U + buf_ot-supp-line.ext-doc-type
            buf_temp-ot-supp-day.temp-cat-id    = '##':U
          .
        end.
        assign
          buf_temp-ot-supp-day.temp-fact-qnty      = buf_temp-ot-supp-day.temp-fact-qnty
                                                   + buf_ot-supp-line.fact-qnty
          buf_temp-ot-supp-day.temp-sum-base       = buf_temp-ot-supp-day.temp-sum-base
                                                   + buf_ot-supp-line.sum-base
          buf_temp-ot-supp-day.temp-sum-rubl       = buf_temp-ot-supp-day.temp-sum-rubl
                                                   + buf_ot-supp-line.sum-rubl
          buf_temp-ot-supp-day.temp-VAT-base       = buf_temp-ot-supp-day.temp-VAT-base
                                                   + buf_ot-supp-line.VAT-base
          buf_temp-ot-supp-day.temp-VAT-rubl       = buf_temp-ot-supp-day.temp-VAT-rubl
                                                   + buf_ot-supp-line.VAT-rubl
          buf_temp-ot-supp-day.temp-SLT-base       = buf_temp-ot-supp-day.temp-SLT-base
                                                   + buf_ot-supp-line.SLT-base
          buf_temp-ot-supp-day.temp-SLT-rubl       = buf_temp-ot-supp-day.temp-SLT-rubl
                                                   + buf_ot-supp-line.SLT-rubl
          buf_temp-ot-supp-day.temp-road-tax-base  = buf_temp-ot-supp-day.temp-road-tax-base
                                                   + buf_ot-supp-line.road-tax-base
          buf_temp-ot-supp-day.temp-road-tax-rubl  = buf_temp-ot-supp-day.temp-road-tax-rubl
                                                   + buf_ot-supp-line.road-tax-rubl
          buf_temp-ot-supp-day.temp-excise-base    = buf_temp-ot-supp-day.temp-excise-base
                                                   + buf_ot-supp-line.excise-base
          buf_temp-ot-supp-day.temp-excise-rubl    = buf_temp-ot-supp-day.temp-excise-rubl
                                                   + buf_ot-supp-line.excise-rubl
          buf_temp-ot-supp-day.temp-transport-base = buf_temp-ot-supp-day.temp-transport-base
                                                   + buf_ot-supp-line.transport-base
          buf_temp-ot-supp-day.temp-transport-rubl = buf_temp-ot-supp-day.temp-transport-rubl
                                                   + buf_ot-supp-line.transport-rubl
          buf_temp-ot-supp-day.temp-other-base     = buf_temp-ot-supp-day.temp-other-base
                                                   + buf_ot-supp-line.other-base
          buf_temp-ot-supp-day.temp-other-rubl     = buf_temp-ot-supp-day.temp-other-rubl
                                                   + buf_ot-supp-line.other-rubl
        .
      end.
      if buf_ot-supp-line.sum-type = 'sale':U
      then do:
        find first buf_temp-ot-supp-day
          where buf_temp-ot-supp-day.temp-cli-type  = buf_ot-supp-line.cli-type
            and buf_temp-ot-supp-day.temp-cli-code  = buf_ot-supp-line.cli-code
            and buf_temp-ot-supp-day.temp-artic     = buf_ot-supp-line.artic
            and buf_temp-ot-supp-day.temp-prod-type = buf_ot-supp-line.prod-type
            and buf_temp-ot-supp-day.temp-prod-code = buf_ot-supp-line.prod-code
            and buf_temp-ot-supp-day.temp-sum-type  = 'sadt':U + buf_ot-supp-line.ext-doc-type
            and buf_temp-ot-supp-day.temp-cat-id    = '##':U
          no-error .
        if not available buf_temp-ot-supp-day
        then do:
          create buf_temp-ot-supp-day .
          assign
            buf_temp-ot-supp-day.temp-cli-type  = buf_ot-supp-line.cli-type
            buf_temp-ot-supp-day.temp-cli-code  = buf_ot-supp-line.cli-code
            buf_temp-ot-supp-day.temp-artic     = buf_ot-supp-line.artic
            buf_temp-ot-supp-day.temp-prod-type = buf_ot-supp-line.prod-type
            buf_temp-ot-supp-day.temp-prod-code = buf_ot-supp-line.prod-code
            buf_temp-ot-supp-day.temp-sum-type  = 'sadt':U + buf_ot-supp-line.ext-doc-type
            buf_temp-ot-supp-day.temp-cat-id    = '##':U
          .
        end.
        assign
          buf_temp-ot-supp-day.temp-fact-qnty      = buf_temp-ot-supp-day.temp-fact-qnty
                                                   + buf_ot-supp-line.fact-qnty
          buf_temp-ot-supp-day.temp-sum-base       = buf_temp-ot-supp-day.temp-sum-base
                                                   + buf_ot-supp-line.sum-base
          buf_temp-ot-supp-day.temp-sum-rubl       = buf_temp-ot-supp-day.temp-sum-rubl
                                                   + buf_ot-supp-line.sum-rubl
          buf_temp-ot-supp-day.temp-VAT-base       = buf_temp-ot-supp-day.temp-VAT-base
                                                   + buf_ot-supp-line.VAT-base
          buf_temp-ot-supp-day.temp-VAT-rubl       = buf_temp-ot-supp-day.temp-VAT-rubl
                                                   + buf_ot-supp-line.VAT-rubl
          buf_temp-ot-supp-day.temp-SLT-base       = buf_temp-ot-supp-day.temp-SLT-base
                                                   + buf_ot-supp-line.SLT-base
          buf_temp-ot-supp-day.temp-SLT-rubl       = buf_temp-ot-supp-day.temp-SLT-rubl
                                                   + buf_ot-supp-line.SLT-rubl
          buf_temp-ot-supp-day.temp-road-tax-base  = buf_temp-ot-supp-day.temp-road-tax-base
                                                   + buf_ot-supp-line.road-tax-base
          buf_temp-ot-supp-day.temp-road-tax-rubl  = buf_temp-ot-supp-day.temp-road-tax-rubl
                                                   + buf_ot-supp-line.road-tax-rubl
          buf_temp-ot-supp-day.temp-excise-base    = buf_temp-ot-supp-day.temp-excise-base
                                                   + buf_ot-supp-line.excise-base
          buf_temp-ot-supp-day.temp-excise-rubl    = buf_temp-ot-supp-day.temp-excise-rubl
                                                   + buf_ot-supp-line.excise-rubl
          buf_temp-ot-supp-day.temp-transport-base = buf_temp-ot-supp-day.temp-transport-base
                                                   + buf_ot-supp-line.transport-base
          buf_temp-ot-supp-day.temp-transport-rubl = buf_temp-ot-supp-day.temp-transport-rubl
                                                   + buf_ot-supp-line.transport-rubl
          buf_temp-ot-supp-day.temp-other-base     = buf_temp-ot-supp-day.temp-other-base
                                                   + buf_ot-supp-line.other-base
          buf_temp-ot-supp-day.temp-other-rubl     = buf_temp-ot-supp-day.temp-other-rubl
                                                   + buf_ot-supp-line.other-rubl
        .
      end.
    end.
  end.
end procedure.
procedure validate-stk-supp-line :
  define input  parameter p-fact-date            as date      no-undo .
  define input  parameter p-fact-order-begin-day as decimal   no-undo .
  define input  parameter p-fact-order-end-day   as decimal   no-undo .
  define variable v-fact-qnty      as decimal   no-undo .
  define variable v-sum-base       as decimal   no-undo .
  define variable v-sum-rubl       as decimal   no-undo .
  define variable v-VAT-base       as decimal   no-undo .
  define variable v-VAT-rubl       as decimal   no-undo .
  define variable v-SLT-base       as decimal   no-undo .
  define variable v-SLT-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-excise-base    as decimal   no-undo .
  define variable v-excise-rubl    as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_prev_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-ot-supp-day for temp-ot-supp-day .
  do
  on error undo, return error return-value
  :
    for each buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type   = p-obj-type
        and buf_stk-supp-line.obj-code   = p-obj-code
        and buf_stk-supp-line.fact-order = p-fact-order-end-day
    on error undo, return error return-value
    :
      if buf_stk-supp-line.sum-type = 'cost':U
      then do:
        assign
          v-fact-qnty      = buf_stk-supp-line.fact-qnty
          v-sum-base       = buf_stk-supp-line.sum-base
          v-sum-rubl       = buf_stk-supp-line.sum-rubl
          v-VAT-base       = buf_stk-supp-line.VAT-base
          v-VAT-rubl       = buf_stk-supp-line.VAT-rubl
          v-SLT-base       = buf_stk-supp-line.SLT-base
          v-SLT-rubl       = buf_stk-supp-line.SLT-rubl
          v-road-tax-base  = buf_stk-supp-line.road-tax-base
          v-road-tax-rubl  = buf_stk-supp-line.road-tax-rubl
          v-excise-base    = buf_stk-supp-line.excise-base
          v-excise-rubl    = buf_stk-supp-line.excise-rubl
          v-transport-base = buf_stk-supp-line.transport-base
          v-transport-rubl = buf_stk-supp-line.transport-rubl
          v-other-base     = buf_stk-supp-line.other-base
          v-other-rubl     = buf_stk-supp-line.other-rubl
        .
        find last buf_prev_stk-supp-line no-lock
          where buf_prev_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
            and buf_prev_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
            and buf_prev_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
            and buf_prev_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
            and buf_prev_stk-supp-line.artic      = buf_stk-supp-line.artic
            and buf_prev_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
            and buf_prev_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
            and buf_prev_stk-supp-line.sum-type   = 'cost':U
            and buf_prev_stk-supp-line.cat-id     = '##':U
            and buf_prev_stk-supp-line.fact-order < p-fact-order-begin-day
            and buf_prev_stk-supp-line.shift-date = ?
          use-index category
          no-error .
        if  available buf_prev_stk-supp-line
        and buf_stk-supp-line.sum-type <> 'cost':U
        then do:
          define variable v-prev-fact-order as decimal   no-undo .
          assign
            v-prev-fact-order = buf_prev_stk-supp-line.fact-order
          .
          find last buf_prev_stk-supp-line no-lock
            where buf_prev_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
              and buf_prev_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
              and buf_prev_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
              and buf_prev_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
              and buf_prev_stk-supp-line.artic      = buf_stk-supp-line.artic
              and buf_prev_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
              and buf_prev_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
              and buf_prev_stk-supp-line.sum-type   = buf_stk-supp-line.sum-type
              and buf_prev_stk-supp-line.cat-id     = buf_stk-supp-line.cat-id
              and buf_prev_stk-supp-line.fact-order = v-prev-fact-order
              and buf_prev_stk-supp-line.shift-date = ?
            use-index category
            no-error .
        end.
        if available buf_prev_stk-supp-line
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      - buf_prev_stk-supp-line.fact-qnty
            v-sum-base       = v-sum-base       - buf_prev_stk-supp-line.sum-base
            v-sum-rubl       = v-sum-rubl       - buf_prev_stk-supp-line.sum-rubl
            v-VAT-base       = v-VAT-base       - buf_prev_stk-supp-line.VAT-base
            v-VAT-rubl       = v-VAT-rubl       - buf_prev_stk-supp-line.VAT-rubl
            v-SLT-base       = v-SLT-base       - buf_prev_stk-supp-line.SLT-base
            v-SLT-rubl       = v-SLT-rubl       - buf_prev_stk-supp-line.SLT-rubl
            v-road-tax-base  = v-road-tax-base  - buf_prev_stk-supp-line.road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  - buf_prev_stk-supp-line.road-tax-rubl
            v-excise-base    = v-excise-base    - buf_prev_stk-supp-line.excise-base
            v-excise-rubl    = v-excise-rubl    - buf_prev_stk-supp-line.excise-rubl
            v-transport-base = v-transport-base - buf_prev_stk-supp-line.transport-base
            v-transport-rubl = v-transport-rubl - buf_prev_stk-supp-line.transport-rubl
            v-other-base     = v-other-base     - buf_prev_stk-supp-line.other-base
            v-other-rubl     = v-other-rubl     - buf_prev_stk-supp-line.other-rubl
          .
        end.
        find first buf_temp-ot-supp-day
          where buf_temp-ot-supp-day.temp-cli-type  = buf_stk-supp-line.cli-type
            and buf_temp-ot-supp-day.temp-cli-code  = buf_stk-supp-line.cli-code
            and buf_temp-ot-supp-day.temp-artic     = buf_stk-supp-line.artic
            and buf_temp-ot-supp-day.temp-prod-type = buf_stk-supp-line.prod-type
            and buf_temp-ot-supp-day.temp-prod-code = buf_stk-supp-line.prod-code
            and buf_temp-ot-supp-day.temp-sum-type  = buf_stk-supp-line.sum-type
            and buf_temp-ot-supp-day.temp-cat-id    = buf_stk-supp-line.cat-id
          no-error .
        if available buf_temp-ot-supp-day
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      - buf_temp-ot-supp-day.temp-fact-qnty
            v-sum-base       = v-sum-base       - buf_temp-ot-supp-day.temp-sum-base
            v-sum-rubl       = v-sum-rubl       - buf_temp-ot-supp-day.temp-sum-rubl
            v-VAT-base       = v-VAT-base       - buf_temp-ot-supp-day.temp-VAT-base
            v-VAT-rubl       = v-VAT-rubl       - buf_temp-ot-supp-day.temp-VAT-rubl
            v-SLT-base       = v-SLT-base       - buf_temp-ot-supp-day.temp-SLT-base
            v-SLT-rubl       = v-SLT-rubl       - buf_temp-ot-supp-day.temp-SLT-rubl
            v-road-tax-base  = v-road-tax-base  - buf_temp-ot-supp-day.temp-road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  - buf_temp-ot-supp-day.temp-road-tax-rubl
            v-excise-base    = v-excise-base    - buf_temp-ot-supp-day.temp-excise-base
            v-excise-rubl    = v-excise-rubl    - buf_temp-ot-supp-day.temp-excise-rubl
            v-transport-base = v-transport-base - buf_temp-ot-supp-day.temp-transport-base
            v-transport-rubl = v-transport-rubl - buf_temp-ot-supp-day.temp-transport-rubl
            v-other-base     = v-other-base     - buf_temp-ot-supp-day.temp-other-base
            v-other-rubl     = v-other-rubl     - buf_temp-ot-supp-day.temp-other-rubl
          .
        end.
        if v-fact-qnty      <> 0
        or v-sum-base       <> 0
        or v-sum-rubl       <> 0
        or v-VAT-base       <> 0
        or v-VAT-rubl       <> 0
        or v-SLT-base       <> 0
        or v-SLT-rubl       <> 0
        or v-road-tax-base  <> 0
        or v-road-tax-rubl  <> 0
        or v-excise-base    <> 0
        or v-excise-rubl    <> 0
        or v-transport-base <> 0
        or v-transport-rubl <> 0
        or v-other-base     <> 0
        or v-other-rubl     <> 0
        then do:
          assign
            v-total-err = v-total-err + 1
          .
          run cur-time in this-procedure
            (output v-today
            ,output v-time
            ) .
          run update-last-date in this-procedure
            (input buf_stk-supp-line.fact-date
            ) .
          output stream sout to value(v-log-err-file) append .
          export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
          export stream sout "error-05: stk-supp-line record different quantity" .
          export stream sout "obj-type"       buf_stk-supp-line.obj-type       .
          export stream sout "obj-code"       buf_stk-supp-line.obj-code       .
          export stream sout "fact-date"      buf_stk-supp-line.fact-date      .
          export stream sout "cli-type"       buf_stk-supp-line.cli-type       .
          export stream sout "cli-code"       buf_stk-supp-line.cli-code       .
          export stream sout "artic"          buf_stk-supp-line.artic          .
          export stream sout "prod-type"      buf_stk-supp-line.prod-type      .
          export stream sout "prod-code"      buf_stk-supp-line.prod-code      .
          export stream sout "sum-type"       buf_stk-supp-line.sum-type       .
          export stream sout "cat-id"         buf_stk-supp-line.cat-id         .
          export stream sout "fact-order"     buf_stk-supp-line.fact-order     .
          export stream sout "fact-qnty"      buf_stk-supp-line.fact-qnty      .
          export stream sout "sum-base"       buf_stk-supp-line.sum-base       .
          export stream sout "sum-rubl"       buf_stk-supp-line.sum-rubl       .
          export stream sout "VAT-base"       buf_stk-supp-line.VAT-base       .
          export stream sout "VAT-rubl"       buf_stk-supp-line.VAT-rubl       .
          export stream sout "SLT-base"       buf_stk-supp-line.SLT-base       .
          export stream sout "SLT-rubl"       buf_stk-supp-line.SLT-rubl       .
          export stream sout "road-tax-base"  buf_stk-supp-line.road-tax-base  .
          export stream sout "road-tax-rubl"  buf_stk-supp-line.road-tax-rubl  .
          export stream sout "excise-base"    buf_stk-supp-line.excise-base    .
          export stream sout "excise-rubl"    buf_stk-supp-line.excise-rubl    .
          export stream sout "transport-base" buf_stk-supp-line.transport-base .
          export stream sout "transport-rubl" buf_stk-supp-line.transport-rubl .
          export stream sout "other-base"     buf_stk-supp-line.other-base     .
          export stream sout "other-rubl"     buf_stk-supp-line.other-rubl     .
          output stream sout close .
        end.
      end.
      if buf_stk-supp-line.sum-type begins 'sadt':U
      then do:
        assign
          v-fact-qnty      = buf_stk-supp-line.fact-qnty
          v-sum-base       = buf_stk-supp-line.sum-base
          v-sum-rubl       = buf_stk-supp-line.sum-rubl
          v-VAT-base       = buf_stk-supp-line.VAT-base
          v-VAT-rubl       = buf_stk-supp-line.VAT-rubl
          v-SLT-base       = buf_stk-supp-line.SLT-base
          v-SLT-rubl       = buf_stk-supp-line.SLT-rubl
          v-road-tax-base  = buf_stk-supp-line.road-tax-base
          v-road-tax-rubl  = buf_stk-supp-line.road-tax-rubl
          v-excise-base    = buf_stk-supp-line.excise-base
          v-excise-rubl    = buf_stk-supp-line.excise-rubl
          v-transport-base = buf_stk-supp-line.transport-base
          v-transport-rubl = buf_stk-supp-line.transport-rubl
          v-other-base     = buf_stk-supp-line.other-base
          v-other-rubl     = buf_stk-supp-line.other-rubl
        .
        find last buf_prev_stk-supp-line no-lock
          where buf_prev_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
            and buf_prev_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
            and buf_prev_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
            and buf_prev_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
            and buf_prev_stk-supp-line.artic      = buf_stk-supp-line.artic
            and buf_prev_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
            and buf_prev_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
            and buf_prev_stk-supp-line.sum-type   = buf_stk-supp-line.sum-type
            and buf_prev_stk-supp-line.cat-id     = buf_stk-supp-line.cat-id
            and buf_prev_stk-supp-line.fact-order < p-fact-order-begin-day
            and buf_prev_stk-supp-line.shift-date = ?
          use-index category
          no-error .
        if available buf_prev_stk-supp-line
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      - buf_prev_stk-supp-line.fact-qnty
            v-sum-base       = v-sum-base       - buf_prev_stk-supp-line.sum-base
            v-sum-rubl       = v-sum-rubl       - buf_prev_stk-supp-line.sum-rubl
            v-VAT-base       = v-VAT-base       - buf_prev_stk-supp-line.VAT-base
            v-VAT-rubl       = v-VAT-rubl       - buf_prev_stk-supp-line.VAT-rubl
            v-SLT-base       = v-SLT-base       - buf_prev_stk-supp-line.SLT-base
            v-SLT-rubl       = v-SLT-rubl       - buf_prev_stk-supp-line.SLT-rubl
            v-road-tax-base  = v-road-tax-base  - buf_prev_stk-supp-line.road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  - buf_prev_stk-supp-line.road-tax-rubl
            v-excise-base    = v-excise-base    - buf_prev_stk-supp-line.excise-base
            v-excise-rubl    = v-excise-rubl    - buf_prev_stk-supp-line.excise-rubl
            v-transport-base = v-transport-base - buf_prev_stk-supp-line.transport-base
            v-transport-rubl = v-transport-rubl - buf_prev_stk-supp-line.transport-rubl
            v-other-base     = v-other-base     - buf_prev_stk-supp-line.other-base
            v-other-rubl     = v-other-rubl     - buf_prev_stk-supp-line.other-rubl
          .
        end.
        find first buf_temp-ot-supp-day
          where buf_temp-ot-supp-day.temp-cli-type  = buf_stk-supp-line.cli-type
            and buf_temp-ot-supp-day.temp-cli-code  = buf_stk-supp-line.cli-code
            and buf_temp-ot-supp-day.temp-artic     = buf_stk-supp-line.artic
            and buf_temp-ot-supp-day.temp-prod-type = buf_stk-supp-line.prod-type
            and buf_temp-ot-supp-day.temp-prod-code = buf_stk-supp-line.prod-code
            and buf_temp-ot-supp-day.temp-sum-type  = buf_stk-supp-line.sum-type
            and buf_temp-ot-supp-day.temp-cat-id    = buf_stk-supp-line.cat-id
          no-error .
        if available buf_temp-ot-supp-day
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      - buf_temp-ot-supp-day.temp-fact-qnty
            v-sum-base       = v-sum-base       - buf_temp-ot-supp-day.temp-sum-base
            v-sum-rubl       = v-sum-rubl       - buf_temp-ot-supp-day.temp-sum-rubl
            v-VAT-base       = v-VAT-base       - buf_temp-ot-supp-day.temp-VAT-base
            v-VAT-rubl       = v-VAT-rubl       - buf_temp-ot-supp-day.temp-VAT-rubl
            v-SLT-base       = v-SLT-base       - buf_temp-ot-supp-day.temp-SLT-base
            v-SLT-rubl       = v-SLT-rubl       - buf_temp-ot-supp-day.temp-SLT-rubl
            v-road-tax-base  = v-road-tax-base  - buf_temp-ot-supp-day.temp-road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  - buf_temp-ot-supp-day.temp-road-tax-rubl
            v-excise-base    = v-excise-base    - buf_temp-ot-supp-day.temp-excise-base
            v-excise-rubl    = v-excise-rubl    - buf_temp-ot-supp-day.temp-excise-rubl
            v-transport-base = v-transport-base - buf_temp-ot-supp-day.temp-transport-base
            v-transport-rubl = v-transport-rubl - buf_temp-ot-supp-day.temp-transport-rubl
            v-other-base     = v-other-base     - buf_temp-ot-supp-day.temp-other-base
            v-other-rubl     = v-other-rubl     - buf_temp-ot-supp-day.temp-other-rubl
          .
        end.
        if v-fact-qnty      <> 0
        or v-sum-base       <> 0
        or v-sum-rubl       <> 0
        or v-VAT-base       <> 0
        or v-VAT-rubl       <> 0
        or v-SLT-base       <> 0
        or v-SLT-rubl       <> 0
        or v-road-tax-base  <> 0
        or v-road-tax-rubl  <> 0
        or v-excise-base    <> 0
        or v-excise-rubl    <> 0
        or v-transport-base <> 0
        or v-transport-rubl <> 0
        or v-other-base     <> 0
        or v-other-rubl     <> 0
        then do:
          assign
            v-total-err = v-total-err + 1
          .
          run cur-time in this-procedure
            (output v-today
            ,output v-time
            ) .
          run update-last-date in this-procedure
            (input buf_stk-supp-line.fact-date
            ) .
          output stream sout to value(v-log-err-file) append .
          export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
          export stream sout "error-06: stk-supp-line record different quantity" .
          export stream sout "obj-type"       buf_stk-supp-line.obj-type       .
          export stream sout "obj-code"       buf_stk-supp-line.obj-code       .
          export stream sout "fact-date"      buf_stk-supp-line.fact-date      .
          export stream sout "cli-type"       buf_stk-supp-line.cli-type       .
          export stream sout "cli-code"       buf_stk-supp-line.cli-code       .
          export stream sout "artic"          buf_stk-supp-line.artic          .
          export stream sout "prod-type"      buf_stk-supp-line.prod-type      .
          export stream sout "prod-code"      buf_stk-supp-line.prod-code      .
          export stream sout "sum-type"       buf_stk-supp-line.sum-type       .
          export stream sout "cat-id"         buf_stk-supp-line.cat-id         .
          export stream sout "fact-order"     buf_stk-supp-line.fact-order     .
          export stream sout "fact-qnty"      buf_stk-supp-line.fact-qnty      .
          export stream sout "sum-base"       buf_stk-supp-line.sum-base       .
          export stream sout "sum-rubl"       buf_stk-supp-line.sum-rubl       .
          export stream sout "VAT-base"       buf_stk-supp-line.VAT-base       .
          export stream sout "VAT-rubl"       buf_stk-supp-line.VAT-rubl       .
          export stream sout "SLT-base"       buf_stk-supp-line.SLT-base       .
          export stream sout "SLT-rubl"       buf_stk-supp-line.SLT-rubl       .
          export stream sout "road-tax-base"  buf_stk-supp-line.road-tax-base  .
          export stream sout "road-tax-rubl"  buf_stk-supp-line.road-tax-rubl  .
          export stream sout "excise-base"    buf_stk-supp-line.excise-base    .
          export stream sout "excise-rubl"    buf_stk-supp-line.excise-rubl    .
          export stream sout "transport-base" buf_stk-supp-line.transport-base .
          export stream sout "transport-rubl" buf_stk-supp-line.transport-rubl .
          export stream sout "other-base"     buf_stk-supp-line.other-base     .
          export stream sout "other-rubl"     buf_stk-supp-line.other-rubl     .
          output stream sout close .
        end.
      end.
      if buf_stk-supp-line.sum-type begins 'csdt':U
      then do:
        assign
          v-fact-qnty      = buf_stk-supp-line.fact-qnty
          v-sum-base       = buf_stk-supp-line.sum-base
          v-sum-rubl       = buf_stk-supp-line.sum-rubl
          v-VAT-base       = buf_stk-supp-line.VAT-base
          v-VAT-rubl       = buf_stk-supp-line.VAT-rubl
          v-SLT-base       = buf_stk-supp-line.SLT-base
          v-SLT-rubl       = buf_stk-supp-line.SLT-rubl
          v-road-tax-base  = buf_stk-supp-line.road-tax-base
          v-road-tax-rubl  = buf_stk-supp-line.road-tax-rubl
          v-excise-base    = buf_stk-supp-line.excise-base
          v-excise-rubl    = buf_stk-supp-line.excise-rubl
          v-transport-base = buf_stk-supp-line.transport-base
          v-transport-rubl = buf_stk-supp-line.transport-rubl
          v-other-base     = buf_stk-supp-line.other-base
          v-other-rubl     = buf_stk-supp-line.other-rubl
        .
        find last buf_prev_stk-supp-line no-lock
          where buf_prev_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
            and buf_prev_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
            and buf_prev_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
            and buf_prev_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
            and buf_prev_stk-supp-line.artic      = buf_stk-supp-line.artic
            and buf_prev_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
            and buf_prev_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
            and buf_prev_stk-supp-line.sum-type   = buf_stk-supp-line.sum-type
            and buf_prev_stk-supp-line.cat-id     = buf_stk-supp-line.cat-id
            and buf_prev_stk-supp-line.fact-order < p-fact-order-begin-day
            and buf_prev_stk-supp-line.shift-date = ?
          use-index category
          no-error .
        if available buf_prev_stk-supp-line
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      - buf_prev_stk-supp-line.fact-qnty
            v-sum-base       = v-sum-base       - buf_prev_stk-supp-line.sum-base
            v-sum-rubl       = v-sum-rubl       - buf_prev_stk-supp-line.sum-rubl
            v-VAT-base       = v-VAT-base       - buf_prev_stk-supp-line.VAT-base
            v-VAT-rubl       = v-VAT-rubl       - buf_prev_stk-supp-line.VAT-rubl
            v-SLT-base       = v-SLT-base       - buf_prev_stk-supp-line.SLT-base
            v-SLT-rubl       = v-SLT-rubl       - buf_prev_stk-supp-line.SLT-rubl
            v-road-tax-base  = v-road-tax-base  - buf_prev_stk-supp-line.road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  - buf_prev_stk-supp-line.road-tax-rubl
            v-excise-base    = v-excise-base    - buf_prev_stk-supp-line.excise-base
            v-excise-rubl    = v-excise-rubl    - buf_prev_stk-supp-line.excise-rubl
            v-transport-base = v-transport-base - buf_prev_stk-supp-line.transport-base
            v-transport-rubl = v-transport-rubl - buf_prev_stk-supp-line.transport-rubl
            v-other-base     = v-other-base     - buf_prev_stk-supp-line.other-base
            v-other-rubl     = v-other-rubl     - buf_prev_stk-supp-line.other-rubl
          .
        end.
        find first buf_temp-ot-supp-day
          where buf_temp-ot-supp-day.temp-cli-type  = buf_stk-supp-line.cli-type
            and buf_temp-ot-supp-day.temp-cli-code  = buf_stk-supp-line.cli-code
            and buf_temp-ot-supp-day.temp-artic     = buf_stk-supp-line.artic
            and buf_temp-ot-supp-day.temp-prod-type = buf_stk-supp-line.prod-type
            and buf_temp-ot-supp-day.temp-prod-code = buf_stk-supp-line.prod-code
            and buf_temp-ot-supp-day.temp-sum-type  = buf_stk-supp-line.sum-type
            and buf_temp-ot-supp-day.temp-cat-id    = buf_stk-supp-line.cat-id
          no-error .
        if available buf_temp-ot-supp-day
        then do:
          assign
            v-fact-qnty      = v-fact-qnty      - buf_temp-ot-supp-day.temp-fact-qnty
            v-sum-base       = v-sum-base       - buf_temp-ot-supp-day.temp-sum-base
            v-sum-rubl       = v-sum-rubl       - buf_temp-ot-supp-day.temp-sum-rubl
            v-VAT-base       = v-VAT-base       - buf_temp-ot-supp-day.temp-VAT-base
            v-VAT-rubl       = v-VAT-rubl       - buf_temp-ot-supp-day.temp-VAT-rubl
            v-SLT-base       = v-SLT-base       - buf_temp-ot-supp-day.temp-SLT-base
            v-SLT-rubl       = v-SLT-rubl       - buf_temp-ot-supp-day.temp-SLT-rubl
            v-road-tax-base  = v-road-tax-base  - buf_temp-ot-supp-day.temp-road-tax-base
            v-road-tax-rubl  = v-road-tax-rubl  - buf_temp-ot-supp-day.temp-road-tax-rubl
            v-excise-base    = v-excise-base    - buf_temp-ot-supp-day.temp-excise-base
            v-excise-rubl    = v-excise-rubl    - buf_temp-ot-supp-day.temp-excise-rubl
            v-transport-base = v-transport-base - buf_temp-ot-supp-day.temp-transport-base
            v-transport-rubl = v-transport-rubl - buf_temp-ot-supp-day.temp-transport-rubl
            v-other-base     = v-other-base     - buf_temp-ot-supp-day.temp-other-base
            v-other-rubl     = v-other-rubl     - buf_temp-ot-supp-day.temp-other-rubl
          .
        end.
        if v-fact-qnty      <> 0
        or v-sum-base       <> 0
        or v-sum-rubl       <> 0
        or v-VAT-base       <> 0
        or v-VAT-rubl       <> 0
        or v-SLT-base       <> 0
        or v-SLT-rubl       <> 0
        or v-road-tax-base  <> 0
        or v-road-tax-rubl  <> 0
        or v-excise-base    <> 0
        or v-excise-rubl    <> 0
        or v-transport-base <> 0
        or v-transport-rubl <> 0
        or v-other-base     <> 0
        or v-other-rubl     <> 0
        then do:
          assign
            v-total-err = v-total-err + 1
          .
          run cur-time in this-procedure
            (output v-today
            ,output v-time
            ) .
          run update-last-date in this-procedure
            (input buf_stk-supp-line.fact-date
            ) .
          output stream sout to value(v-log-err-file) append .
          export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
          export stream sout "error-07: stk-supp-line record different quantity" .
          export stream sout "obj-type"       buf_stk-supp-line.obj-type       .
          export stream sout "obj-code"       buf_stk-supp-line.obj-code       .
          export stream sout "fact-date"      buf_stk-supp-line.fact-date      .
          export stream sout "cli-type"       buf_stk-supp-line.cli-type       .
          export stream sout "cli-code"       buf_stk-supp-line.cli-code       .
          export stream sout "artic"          buf_stk-supp-line.artic          .
          export stream sout "prod-type"      buf_stk-supp-line.prod-type      .
          export stream sout "prod-code"      buf_stk-supp-line.prod-code      .
          export stream sout "sum-type"       buf_stk-supp-line.sum-type       .
          export stream sout "cat-id"         buf_stk-supp-line.cat-id         .
          export stream sout "fact-order"     buf_stk-supp-line.fact-order     .
          export stream sout "fact-qnty"      buf_stk-supp-line.fact-qnty      .
          export stream sout "sum-base"       buf_stk-supp-line.sum-base       .
          export stream sout "sum-rubl"       buf_stk-supp-line.sum-rubl       .
          export stream sout "VAT-base"       buf_stk-supp-line.VAT-base       .
          export stream sout "VAT-rubl"       buf_stk-supp-line.VAT-rubl       .
          export stream sout "SLT-base"       buf_stk-supp-line.SLT-base       .
          export stream sout "SLT-rubl"       buf_stk-supp-line.SLT-rubl       .
          export stream sout "road-tax-base"  buf_stk-supp-line.road-tax-base  .
          export stream sout "road-tax-rubl"  buf_stk-supp-line.road-tax-rubl  .
          export stream sout "excise-base"    buf_stk-supp-line.excise-base    .
          export stream sout "excise-rubl"    buf_stk-supp-line.excise-rubl    .
          export stream sout "transport-base" buf_stk-supp-line.transport-base .
          export stream sout "transport-rubl" buf_stk-supp-line.transport-rubl .
          export stream sout "other-base"     buf_stk-supp-line.other-base     .
          export stream sout "other-rubl"     buf_stk-supp-line.other-rubl     .
          output stream sout close .
        end.
      end.
    end.
  end.
end procedure.
procedure clear-temp-stk-supp-line :
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  do
  on error undo, return error return-value
  :
    for each buf_temp-stk-supp-line
    on error undo, return error return-value
    :
      delete buf_temp-stk-supp-line .
    end.
  end.
end procedure.
procedure validate-free-zone :
  define buffer buf_lock_gds-obj for ub.gds-obj .
  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-parts for temp-parts .
  define variable v-ind as integer   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_gds-obj no-lock
      where buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка остатков. Ошибок &1. Объект &2 &3. Артикул &4 &5 &6."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,buf_gds-obj.artic
                          ,buf_gds-obj.prod-type
                          ,buf_gds-obj.prod-code
                          )
          ).
      end.
      run clear-temp-stk-supp-line in this-procedure .
      do transaction
      on error undo, return error return-value
      :
        find buf_lock_gds-obj exclusive-lock
          where rowid(buf_lock_gds-obj) = rowid(buf_gds-obj)
          .
        run partslib-init-temp-parts in this-procedure
          (input  buf_gds-obj.obj-type
          ,input  buf_gds-obj.obj-code
          ,input  buf_gds-obj.artic
          ,input  buf_gds-obj.prod-type
          ,input  buf_gds-obj.prod-code
          ) .
      end.
      for each buf_temp-parts
      on error undo, return error return-value
      :
        find first buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.temp-artic     = buf_temp-parts.artic
            and buf_temp-stk-supp-line.temp-prod-type = buf_temp-parts.prod-type
            and buf_temp-stk-supp-line.temp-prod-code = buf_temp-parts.prod-code
            and buf_temp-stk-supp-line.temp-cli-type  = buf_temp-parts.supp-type
            and buf_temp-stk-supp-line.temp-cli-code  = buf_temp-parts.supp-code
          no-error .
        if not available buf_temp-stk-supp-line
        then do:
          create buf_temp-stk-supp-line .
          assign
            buf_temp-stk-supp-line.temp-artic     = buf_temp-parts.artic
            buf_temp-stk-supp-line.temp-prod-type = buf_temp-parts.prod-type
            buf_temp-stk-supp-line.temp-prod-code = buf_temp-parts.prod-code
            buf_temp-stk-supp-line.temp-cli-type  = buf_temp-parts.supp-type
            buf_temp-stk-supp-line.temp-cli-code  = buf_temp-parts.supp-code
          .
        end.
        assign
          buf_temp-stk-supp-line.temp-fact-qnty = buf_temp-stk-supp-line.temp-fact-qnty
                                                + buf_temp-parts.fact-qnty
        .
      end.
      for each buf_temp-stk-supp-line
      on error undo, return error return-value
      :
        find last buf_stk-supp-line no-lock
          where buf_stk-supp-line.obj-type   = p-obj-type
            and buf_stk-supp-line.obj-code   = p-obj-code
            and buf_stk-supp-line.cli-type   = buf_temp-stk-supp-line.temp-cli-type
            and buf_stk-supp-line.cli-code   = buf_temp-stk-supp-line.temp-cli-code
            and buf_stk-supp-line.artic      = buf_temp-stk-supp-line.temp-artic
            and buf_stk-supp-line.prod-type  = buf_temp-stk-supp-line.temp-prod-type
            and buf_stk-supp-line.prod-code  = buf_temp-stk-supp-line.temp-prod-code
            and buf_stk-supp-line.sum-type   = 'cost':U
            and buf_stk-supp-line.cat-id     = '##':U
            and buf_stk-supp-line.shift-date = ?
          use-index category
          no-error .
        if (available buf_stk-supp-line
            and buf_temp-stk-supp-line.temp-fact-qnty <> buf_stk-supp-line.fact-qnty
           )
        or (not available buf_stk-supp-line
            and buf_temp-stk-supp-line.temp-fact-qnty <> 0
           )
        then do:
          assign
            v-total-err = v-total-err + 1
          .
          run cur-time in this-procedure
            (output v-today
            ,output v-time
            ) .
          run update-last-date in this-procedure
            (input v-today
            ) .
          output stream sout to value(v-log-err-file) append .
          export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
          if available buf_stk-supp-line
          then do:
            export stream sout "error-08: gds-obj stk-supp-line different fact-qnty" .
          end.
          else do:
            export stream sout "error-09: gds-obj stk-supp-line fact-qnty not found" .
          end.
          export stream sout "obj-type"  p-obj-type                            .
          export stream sout "obj-code"  p-obj-code                            .
          export stream sout "fact-date" v-today                               .
          export stream sout "cli-type"  buf_temp-stk-supp-line.temp-cli-type  .
          export stream sout "cli-code"  buf_temp-stk-supp-line.temp-cli-code  .
          export stream sout "artic"     buf_temp-stk-supp-line.temp-artic     .
          export stream sout "prod-type" buf_temp-stk-supp-line.temp-prod-type .
          export stream sout "prod-code" buf_temp-stk-supp-line.temp-prod-code .
          export stream sout "parts.fact-qnty" buf_temp-stk-supp-line.temp-fact-qnty .
          if available buf_stk-supp-line
          then do:
            export stream sout "stk-supp-line.fact-qnty" buf_stk-supp-line.fact-qnty .
          end.
          output stream sout close .
        end.
      end.
    end.
  end.
end procedure.
procedure update-last-date :
  define input  parameter p-update-date as date      no-undo .
  do
  on error undo, return error return-value
  :
    if p-last-date = ?
    or p-last-date < p-update-date
    then do:
      assign
        p-last-date = p-update-date
      .
    end.
  end.
end procedure.
procedure check-fact-order :
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define variable v-ind as integer   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type = p-obj-type
        and buf_stk-supp-line.obj-code = p-obj-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка 02. Ошибок &1. Объект &2 &3. Записей &4."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,v-ind
                          )
          ).
      end.
      define variable v-factord-date as date      no-undo .
      run factord-to-date in this-procedure
        (input  buf_stk-supp-line.fact-order
        ,output v-factord-date
        ) .
      if truncate(buf_stk-supp-line.fact-order, 2) <> buf_stk-supp-line.fact-order
      then do:
        assign
          v-total-err = v-total-err + 1
        .
        run update-last-date in this-procedure
          (input v-factord-date
          ) .
        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-10: fact-order"                .
        export stream sout "obj-type"    buf_stk-supp-line.obj-type   .
        export stream sout "obj-code"    buf_stk-supp-line.obj-code   .
        export stream sout "cli-type"    buf_stk-supp-line.cli-type   .
        export stream sout "cli-code"    buf_stk-supp-line.cli-code   .
        export stream sout "artic"       buf_stk-supp-line.artic      .
        export stream sout "prod-type"   buf_stk-supp-line.prod-type  .
        export stream sout "prod-code"   buf_stk-supp-line.prod-code  .
        export stream sout "fact-order"  buf_stk-supp-line.fact-order .
        export stream sout "sum-type"    buf_stk-supp-line.sum-type   .
        export stream sout "v-factord-date" v-factord-date .
        export stream sout "stk-supp-line" .
        export stream sout buf_stk-supp-line .
        output stream sout close .
      end.
    end.
  end.
end procedure.
procedure fill-temp-stk-supp-line :
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-gds for temp-gds .
  define variable v-ind as integer   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type = p-obj-type
        and buf_stk-supp-line.obj-code = p-obj-code
        and buf_stk-supp-line.sum-type = 'cost':U
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка остатков 02. Ошибок &1. Объект &2 &3. Записей &4."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,v-ind
                          )
          ).
      end.
      find first buf_temp-stk-supp-line
        where buf_temp-stk-supp-line.temp-artic     = buf_stk-supp-line.artic
          and buf_temp-stk-supp-line.temp-prod-type = buf_stk-supp-line.prod-type
          and buf_temp-stk-supp-line.temp-prod-code = buf_stk-supp-line.prod-code
          and buf_temp-stk-supp-line.temp-cli-type  = buf_stk-supp-line.cli-type
          and buf_temp-stk-supp-line.temp-cli-code  = buf_stk-supp-line.cli-code
        no-error .
      if not available buf_temp-stk-supp-line
      then do:
        create buf_temp-stk-supp-line .
        assign
          buf_temp-stk-supp-line.temp-artic      = buf_stk-supp-line.artic
          buf_temp-stk-supp-line.temp-prod-type  = buf_stk-supp-line.prod-type
          buf_temp-stk-supp-line.temp-prod-code  = buf_stk-supp-line.prod-code
          buf_temp-stk-supp-line.temp-cli-type   = buf_stk-supp-line.cli-type
          buf_temp-stk-supp-line.temp-cli-code   = buf_stk-supp-line.cli-code
          buf_temp-stk-supp-line.temp-fact-qnty  = buf_stk-supp-line.fact-qnty
          buf_temp-stk-supp-line.temp-fact-order = buf_stk-supp-line.fact-order
        .
      end.
      if buf_temp-stk-supp-line.temp-fact-order < buf_stk-supp-line.fact-order
      then do:
        assign
          buf_temp-stk-supp-line.temp-fact-qnty  = buf_stk-supp-line.fact-qnty
          buf_temp-stk-supp-line.temp-fact-order = buf_stk-supp-line.fact-order
        .
      end.
      find first buf_temp-gds
        where buf_temp-gds.temp-artic      = buf_stk-supp-line.artic
          and buf_temp-gds.temp-prod-type  = buf_stk-supp-line.prod-type
          and buf_temp-gds.temp-prod-code  = buf_stk-supp-line.prod-code
        no-error .
      if not available buf_temp-gds
      then do:
        create buf_temp-gds .
        assign
          buf_temp-gds.temp-artic      = buf_stk-supp-line.artic
          buf_temp-gds.temp-prod-type  = buf_stk-supp-line.prod-type
          buf_temp-gds.temp-prod-code  = buf_stk-supp-line.prod-code
        .
      end.
    end.
  end.
end procedure.
procedure check-free-zone-from-stk-supp-line :
  define buffer buf_lock_gds-obj for ub.gds-obj .
  define buffer buf_temp-gds for temp-gds .
  define buffer buf_temp-stk-supp-line for temp-stk-supp-line .
  define buffer buf_temp-parts for temp-parts .
  define variable v-ind as integer   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_temp-gds
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка остатков 03. Ошибок &1. Объект &2 &3. Артикул &4 &5 &6."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,buf_temp-gds.temp-artic
                          ,buf_temp-gds.temp-prod-type
                          ,buf_temp-gds.temp-prod-code
                          )
          ).
      end.
      do transaction
      on error undo, return error return-value
      :
        find buf_lock_gds-obj exclusive-lock
          where buf_lock_gds-obj.obj-type  = p-obj-type
            and buf_lock_gds-obj.obj-code  = p-obj-code
            and buf_lock_gds-obj.artic     = buf_temp-gds.temp-artic
            and buf_lock_gds-obj.prod-type = buf_temp-gds.temp-prod-type
            and buf_lock_gds-obj.prod-code = buf_temp-gds.temp-prod-code
          no-error .
        if not available buf_lock_gds-obj
        then do:
          assign
            v-total-err = v-total-err + 1
          .
          run cur-time in this-procedure
            (output v-today
            ,output v-time
            ) .
          run update-last-date in this-procedure
            (input v-today
            ) .
          output stream sout to value(v-log-err-file) append .
          export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
          export stream sout "error-11: gds-obj not found"           .
          export stream sout "obj-type"  p-obj-type                  .
          export stream sout "obj-code"  p-obj-code                  .
          export stream sout "artic"     buf_temp-gds.temp-artic     .
          export stream sout "prod-type" buf_temp-gds.temp-prod-type .
          export stream sout "prod-code" buf_temp-gds.temp-prod-code .
          output stream sout close .
        end.
        else do:
          run partslib-init-temp-parts in this-procedure
            (input  p-obj-type
            ,input  p-obj-code
            ,input  buf_temp-gds.temp-artic
            ,input  buf_temp-gds.temp-prod-type
            ,input  buf_temp-gds.temp-prod-code
            ) .
        end.
      end.
      for each buf_temp-parts
      on error undo, return error return-value
      :
        find first buf_temp-stk-supp-line
          where buf_temp-stk-supp-line.temp-artic     = buf_temp-parts.artic
            and buf_temp-stk-supp-line.temp-prod-type = buf_temp-parts.prod-type
            and buf_temp-stk-supp-line.temp-prod-code = buf_temp-parts.prod-code
            and buf_temp-stk-supp-line.temp-cli-type  = buf_temp-parts.supp-type
            and buf_temp-stk-supp-line.temp-cli-code  = buf_temp-parts.supp-code
          no-error .
        if not available buf_temp-stk-supp-line
        then do:
          create buf_temp-stk-supp-line .
          assign
            buf_temp-stk-supp-line.temp-artic     = buf_temp-parts.artic
            buf_temp-stk-supp-line.temp-prod-type = buf_temp-parts.prod-type
            buf_temp-stk-supp-line.temp-prod-code = buf_temp-parts.prod-code
            buf_temp-stk-supp-line.temp-cli-type  = buf_temp-parts.supp-type
            buf_temp-stk-supp-line.temp-cli-code  = buf_temp-parts.supp-code
          .
        end.
        assign
          buf_temp-stk-supp-line.temp-gds-qnty = buf_temp-stk-supp-line.temp-gds-qnty
                                                + buf_temp-parts.fact-qnty
        .
      end.
    end.
    for each buf_temp-stk-supp-line
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка остатков 04. Ошибок &1. Объект &2 &3. Записей &4."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,v-ind
                          )
          ).
      end.
      if buf_temp-stk-supp-line.temp-fact-qnty <> buf_temp-stk-supp-line.temp-gds-qnty
      then do:
        assign
          v-total-err = v-total-err + 1
        .
        run cur-time in this-procedure
          (output v-today
          ,output v-time
          ) .
        run update-last-date in this-procedure
          (input v-today
          ) .
        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-12: gds-obj stk-supp-line different fact-qnty" .
        export stream sout "obj-type"  p-obj-type                            .
        export stream sout "obj-code"  p-obj-code                            .
        export stream sout "fact-date" v-today                               .
        export stream sout "cli-type"  buf_temp-stk-supp-line.temp-cli-type  .
        export stream sout "cli-code"  buf_temp-stk-supp-line.temp-cli-code  .
        export stream sout "artic"     buf_temp-stk-supp-line.temp-artic     .
        export stream sout "prod-type" buf_temp-stk-supp-line.temp-prod-type .
        export stream sout "prod-code" buf_temp-stk-supp-line.temp-prod-code .
        export stream sout "stk-supp-line.fact-qnty" buf_temp-stk-supp-line.temp-fact-qnty .
        export stream sout "parts.fact-qnty" buf_temp-stk-supp-line.temp-gds-qnty .
        output stream sout close .
      end.
    end.
  end.
end procedure.
procedure check-sub-type-stk-supp-line :
  define buffer buf_temp-gds for temp-gds .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_sub_stk-supp-line for ub.stk-supp-line .
  define variable v-ind            as integer   no-undo .
  define variable v-fact-qnty      as decimal   no-undo .
  define variable v-sum-base       as decimal   no-undo .
  define variable v-sum-rubl       as decimal   no-undo .
  define variable v-VAT-base       as decimal   no-undo .
  define variable v-VAT-rubl       as decimal   no-undo .
  define variable v-SLT-base       as decimal   no-undo .
  define variable v-SLT-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-excise-base    as decimal   no-undo .
  define variable v-excise-rubl    as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = p-obj-type
        and buf_stk-supp-line.obj-code  = p-obj-code
        and buf_stk-supp-line.sum-type  = 'cost':U
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Проверка 05. Ошибок &1. Объект &2 &3. Артикул &4 &5 &6."
                          ,v-total-err
                          ,p-obj-type
                          ,p-obj-code
                          ,buf_stk-supp-line.artic
                          ,buf_stk-supp-line.prod-type
                          ,buf_stk-supp-line.prod-code
                          )
          ).
      end.
      assign
        v-fact-qnty      = 0
        v-sum-base       = 0
        v-sum-rubl       = 0
        v-VAT-base       = 0
        v-VAT-rubl       = 0
        v-SLT-base       = 0
        v-SLT-rubl       = 0
        v-road-tax-base  = 0
        v-road-tax-rubl  = 0
        v-excise-base    = 0
        v-excise-rubl    = 0
        v-transport-base = 0
        v-transport-rubl = 0
        v-other-base     = 0
        v-other-rubl     = 0
      .
      for each buf_sub_stk-supp-line no-lock
        where buf_sub_stk-supp-line.obj-type   = buf_stk-supp-line.obj-type
          and buf_sub_stk-supp-line.obj-code   = buf_stk-supp-line.obj-code
          and buf_sub_stk-supp-line.cli-type   = buf_stk-supp-line.cli-type
          and buf_sub_stk-supp-line.cli-code   = buf_stk-supp-line.cli-code
          and buf_sub_stk-supp-line.artic      = buf_stk-supp-line.artic
          and buf_sub_stk-supp-line.prod-type  = buf_stk-supp-line.prod-type
          and buf_sub_stk-supp-line.prod-code  = buf_stk-supp-line.prod-code
          and buf_sub_stk-supp-line.fact-order = buf_stk-supp-line.fact-order
          and buf_sub_stk-supp-line.sum-type   = 'cost':U + 'p':U
      on error undo, return error return-value
      :
        assign
          v-fact-qnty      = v-fact-qnty      + buf_sub_stk-supp-line.fact-qnty
          v-sum-base       = v-sum-base       + buf_sub_stk-supp-line.sum-base
          v-sum-rubl       = v-sum-rubl       + buf_sub_stk-supp-line.sum-rubl
          v-VAT-base       = v-VAT-base       + buf_sub_stk-supp-line.VAT-base
          v-VAT-rubl       = v-VAT-rubl       + buf_sub_stk-supp-line.VAT-rubl
          v-SLT-base       = v-SLT-base       + buf_sub_stk-supp-line.SLT-base
          v-SLT-rubl       = v-SLT-rubl       + buf_sub_stk-supp-line.SLT-rubl
          v-road-tax-base  = v-road-tax-base  + buf_sub_stk-supp-line.road-tax-base
          v-road-tax-rubl  = v-road-tax-rubl  + buf_sub_stk-supp-line.road-tax-rubl
          v-excise-base    = v-excise-base    + buf_sub_stk-supp-line.excise-base
          v-excise-rubl    = v-excise-rubl    + buf_sub_stk-supp-line.excise-rubl
          v-transport-base = v-transport-base + buf_sub_stk-supp-line.transport-base
          v-transport-rubl = v-transport-rubl + buf_sub_stk-supp-line.transport-rubl
          v-other-base     = v-other-base     + buf_sub_stk-supp-line.other-base
          v-other-rubl     = v-other-rubl     + buf_sub_stk-supp-line.other-rubl
        .
      end.
      if buf_stk-supp-line.fact-qnty       <> v-fact-qnty
      or buf_stk-supp-line.sum-base        <> v-sum-base
      or buf_stk-supp-line.sum-rubl        <> v-sum-rubl
      or buf_stk-supp-line.VAT-base        <> v-VAT-base
      or buf_stk-supp-line.VAT-rubl        <> v-VAT-rubl
      or buf_stk-supp-line.SLT-base        <> v-SLT-base
      or buf_stk-supp-line.SLT-rubl        <> v-SLT-rubl
      or buf_stk-supp-line.road-tax-base   <> v-road-tax-base
      or buf_stk-supp-line.road-tax-rubl   <> v-road-tax-rubl
      or buf_stk-supp-line.excise-base     <> v-excise-base
      or buf_stk-supp-line.excise-rubl     <> v-excise-rubl
      or buf_stk-supp-line.transport-base  <> v-transport-base
      or buf_stk-supp-line.transport-rubl  <> v-transport-rubl
      or buf_stk-supp-line.other-base      <> v-other-base
      or buf_stk-supp-line.other-rubl      <> v-other-rubl
      then do:
        output stream sout to value(v-log-err-file) append .
        export stream sout '***':u string(v-today, '99/99/9999':u) string(v-time, 'HH:MM:SS':u) .
        export stream sout "error-13: sub_stk-supp-line different qnty"                              .
        export stream sout "obj-type"            p-obj-type                                     .
        export stream sout "obj-code"            p-obj-code                                     .
        export stream sout "obj-type"            buf_stk-supp-line.obj-type                          .
        export stream sout "obj-type"            buf_stk-supp-line.obj-type                          .
        export stream sout "artic"               buf_stk-supp-line.artic                             .
        export stream sout "prod-type"           buf_stk-supp-line.prod-type                         .
        export stream sout "prod-code"           buf_stk-supp-line.prod-code                         .
        export stream sout "fact-order"          buf_stk-supp-line.fact-order                        .
        export stream sout "diff-fact-qnty"      buf_stk-supp-line.fact-qnty      - v-fact-qnty      .
        export stream sout "diff-sum-base"       buf_stk-supp-line.sum-base       - v-sum-base       .
        export stream sout "diff-sum-rubl"       buf_stk-supp-line.sum-rubl       - v-sum-rubl       .
        export stream sout "diff-VAT-base"       buf_stk-supp-line.VAT-base       - v-VAT-base       .
        export stream sout "diff-VAT-rubl"       buf_stk-supp-line.VAT-rubl       - v-VAT-rubl       .
        export stream sout "diff-SLT-base"       buf_stk-supp-line.SLT-base       - v-SLT-base       .
        export stream sout "diff-SLT-rubl"       buf_stk-supp-line.SLT-rubl       - v-SLT-rubl       .
        export stream sout "diff-road-tax-base"  buf_stk-supp-line.road-tax-base  - v-road-tax-base  .
        export stream sout "diff-road-tax-rubl"  buf_stk-supp-line.road-tax-rubl  - v-road-tax-rubl  .
        export stream sout "diff-excise-base"    buf_stk-supp-line.excise-base    - v-excise-base    .
        export stream sout "diff-excise-rubl"    buf_stk-supp-line.excise-rubl    - v-excise-rubl    .
        export stream sout "diff-transport-base" buf_stk-supp-line.transport-base - v-transport-base .
        export stream sout "diff-transport-rubl" buf_stk-supp-line.transport-rubl - v-transport-rubl .
        export stream sout "diff-other-base"     buf_stk-supp-line.other-base     - v-other-base     .
        export stream sout "diff-other-rubl"     buf_stk-supp-line.other-rubl     - v-other-rubl     .
        export stream sout "sub-sum-type"        'cost':U + 'v':U                       .
        export stream sout "fact-qnty"           buf_stk-supp-line.fact-qnty                         .
        export stream sout "sum-base"            buf_stk-supp-line.sum-base                          .
        export stream sout "sum-rubl"            buf_stk-supp-line.sum-rubl                          .
        export stream sout "VAT-base"            buf_stk-supp-line.VAT-base                          .
        export stream sout "VAT-rubl"            buf_stk-supp-line.VAT-rubl                          .
        export stream sout "SLT-base"            buf_stk-supp-line.SLT-base                          .
        export stream sout "SLT-rubl"            buf_stk-supp-line.SLT-rubl                          .
        export stream sout "road-tax-base"       buf_stk-supp-line.road-tax-base                     .
        export stream sout "road-tax-rubl"       buf_stk-supp-line.road-tax-rubl                     .
        export stream sout "excise-base"         buf_stk-supp-line.excise-base                       .
        export stream sout "excise-rubl"         buf_stk-supp-line.excise-rubl                       .
        export stream sout "transport-base"      buf_stk-supp-line.transport-base                    .
        export stream sout "transport-rubl"      buf_stk-supp-line.transport-rubl                    .
        export stream sout "other-base"          buf_stk-supp-line.other-base                        .
        export stream sout "other-rubl"          buf_stk-supp-line.other-rubl                        .
        export stream sout "sub-fact-qnty"       v-fact-qnty                                    .
        export stream sout "sub-sum-base"        v-sum-base                                     .
        export stream sout "sub-sum-rubl"        v-sum-rubl                                     .
        export stream sout "sub-VAT-base"        v-VAT-base                                     .
        export stream sout "sub-VAT-rubl"        v-VAT-rubl                                     .
        export stream sout "sub-SLT-base"        v-SLT-base                                     .
        export stream sout "sub-SLT-rubl"        v-SLT-rubl                                     .
        export stream sout "sub-road-tax-base"   v-road-tax-base                                .
        export stream sout "sub-road-tax-rubl"   v-road-tax-rubl                                .
        export stream sout "sub-excise-base"     v-excise-base                                  .
        export stream sout "sub-excise-rubl"     v-excise-rubl                                  .
        export stream sout "sub-transport-base"  v-transport-base                               .
        export stream sout "sub-transport-rubl"  v-transport-rubl                               .
        export stream sout "sub-other-base"      v-other-base                                   .
        export stream sout "sub-other-rubl"      v-other-rubl                                   .
        output stream sout close .
      end.
    end.
  end.
end procedure.
