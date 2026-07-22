block-level on error undo, throw.
define input  parameter p-imp-handle as handle    no-undo .
define input  parameter p-counter    as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmdcmpgd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmdcmpgd.p $":U .
define variable vss-description as character no-undo init "Распределённая проверка целостности остатков по товару".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3':u,p-counter,p-obj-type,p-obj-code)
    .
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
define temp-table temp-gds-obj no-undo like ub.gds-obj .
define temp-table temp-prt-obj no-undo like ub.prt-obj .
define temp-table temp-parts   no-undo like ub.parts .
define temp-table temp-cmp-gds-obj no-undo
  field gds-code          as integer
  field current-fact-qnty as decimal
  field current-free-qnty as decimal
  field remote-fact-qnty  as decimal
  field remote-free-qnty  as decimal
  field error-qnty        as logical
  index xpk is primary unique gds-code
  index xie1 error-qnty
  .
define temp-table temp-cmp-prt-obj no-undo
  field gds-code          as integer
  field prt-code          as integer
  field current-fact-qnty as decimal
  field current-free-qnty as decimal
  field remote-fact-qnty  as decimal
  field remote-free-qnty  as decimal
  index xpk is primary unique gds-code prt-code
  .
define temp-table temp-cmp-parts no-undo
  field gds-code          as integer
  field in-code           as character
  field out-code          as character
  field part-code         as character
  field current-fact-qnty as decimal
  field remote-fact-qnty  as decimal
  index xpk is primary unique gds-code in-code out-code part-code
  .
define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable v-today    as date      no-undo .
define variable v-time     as integer   no-undo .
define buffer buf_batchprocess     for ub.batchprocess .
define buffer buf_temp-gds-obj     for temp-gds-obj .
define buffer buf_temp-prt-obj     for temp-prt-obj .
define buffer buf_temp-parts       for temp-parts .
define buffer buf_gds-obj          for ub.gds-obj .
define buffer buf_prt-obj          for ub.prt-obj .
define buffer buf_parts            for ub.parts .
define buffer buf_temp-cmp-gds-obj for temp-cmp-gds-obj .
define buffer buf_temp-cmp-prt-obj for temp-cmp-prt-obj .
define buffer buf_temp-cmp-parts   for temp-cmp-parts .
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  do counter = 1 to p-counter
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    if counter modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Получение остатков по товарам из УБД. Объект УБД &1 &2. Получено &3", p-obj-type, p-obj-code, counter)
        ) .
    end.
    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, chr(1) )
    .
    CASE entry(1, v-rec-name, chr(4)) :
      when 'gds-obj':U
      then do:
        create buf_temp-gds-obj .
        run nws-impl in p-imp-handle
          ( input 'gds-obj':U
           ,input (buffer buf_temp-gds-obj:handle)
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
      end.
      when 'prt-obj':U
      then do:
        create buf_temp-prt-obj .
        run nws-impl in p-imp-handle
          ( input 'prt-obj':U
           ,input (buffer buf_temp-prt-obj:handle)
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
      end.
      when 'parts':U
      then do:
        create buf_temp-parts .
        run nws-impl in p-imp-handle
          ( input 'parts':U
            ,input (buffer buf_temp-parts:handle)
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Не предусмотрен прием таблицы " v-rec-name skip
          "в составе команды" 'cmd-transfer-goods':U skip
          view-as alert-box error .
        return error .
      end.
    end case.
  end.
  run waitfram-hide .
  run gbl/lockgdoc.p
    (input  p-obj-type
    ,input  p-obj-code
    ,input  'gdoc':U
    ,input  'disable':U
    ,buffer buf_batchprocess
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке возможности создания записей товара на объекте" skip
      "Объект" p-obj-type p-obj-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable v-ind as integer   no-undo .
  do transaction
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    for each buf_gds-obj exclusive-lock
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
          (input substitute("Блокировка товаров на объекте. Объект УБД &1 &2. Заблокировано &3", p-obj-type, p-obj-code, v-ind)
          ) .
      end.
      create buf_temp-cmp-gds-obj .
      assign
        buf_temp-cmp-gds-obj.gds-code          = buf_gds-obj.gds-code
        buf_temp-cmp-gds-obj.current-fact-qnty = buf_gds-obj.fact-qnty
        buf_temp-cmp-gds-obj.current-free-qnty = buf_gds-obj.free-qnty
      .
      for each buf_prt-obj share-lock
        where buf_prt-obj.obj-type  = buf_gds-obj.obj-type
          and buf_prt-obj.obj-code  = buf_gds-obj.obj-code
          and buf_prt-obj.artic     = buf_gds-obj.artic
          and buf_prt-obj.prod-type = buf_gds-obj.prod-type
          and buf_prt-obj.prod-code = buf_gds-obj.prod-code
      on error undo, return error return-value
      :
        create buf_temp-cmp-prt-obj .
        assign
          buf_temp-cmp-prt-obj.gds-code          = buf_gds-obj.gds-code
          buf_temp-cmp-prt-obj.prt-code          = buf_prt-obj.prt-code
          buf_temp-cmp-prt-obj.current-fact-qnty = buf_prt-obj.fact-qnty
          buf_temp-cmp-prt-obj.current-free-qnty = buf_prt-obj.free-qnty
        .
      end.
      for each buf_parts share-lock
        where buf_parts.obj-type  = buf_gds-obj.obj-type
          and buf_parts.obj-code  = buf_gds-obj.obj-code
          and buf_parts.artic     = buf_gds-obj.artic
          and buf_parts.prod-type = buf_gds-obj.prod-type
          and buf_parts.prod-code = buf_gds-obj.prod-code
          and buf_parts.rsrv-free = yes
          and buf_parts.status_   = no
          and buf_parts.in-code   <> buf_parts.out-code
      on error undo, return error return-value
      :
        create buf_temp-cmp-parts .
        assign
          buf_temp-cmp-parts.gds-code          = buf_gds-obj.gds-code
          buf_temp-cmp-parts.in-code           = buf_parts.in-code
          buf_temp-cmp-parts.out-code          = buf_parts.out-code
          buf_temp-cmp-parts.part-code         = buf_parts.part-code
          buf_temp-cmp-parts.current-fact-qnty = buf_parts.fact-qnty
        .
      end.
    end.
    run waitfram-hide in this-procedure .
  end.
  for each buf_temp-gds-obj
  on error undo, return error return-value
  :
    find first buf_temp-cmp-gds-obj
      where buf_temp-cmp-gds-obj.gds-code = buf_temp-gds-obj.gds-code
      no-error .
    if not available buf_temp-cmp-gds-obj
    then do:
      create buf_temp-cmp-gds-obj .
      assign
        buf_temp-cmp-gds-obj.gds-code = buf_temp-gds-obj.gds-code
      .
    end.
    assign
      buf_temp-cmp-gds-obj.remote-fact-qnty = buf_temp-gds-obj.fact-qnty
      buf_temp-cmp-gds-obj.remote-free-qnty = buf_temp-gds-obj.free-qnty
    .
    for each buf_temp-prt-obj
      where buf_temp-prt-obj.obj-type  = buf_temp-gds-obj.obj-type
        and buf_temp-prt-obj.obj-code  = buf_temp-gds-obj.obj-code
        and buf_temp-prt-obj.artic     = buf_temp-gds-obj.artic
        and buf_temp-prt-obj.prod-type = buf_temp-gds-obj.prod-type
        and buf_temp-prt-obj.prod-code = buf_temp-gds-obj.prod-code
    on error undo, return error return-value
    :
      find first buf_temp-cmp-prt-obj
        where buf_temp-cmp-prt-obj.gds-code = buf_temp-gds-obj.gds-code
          and buf_temp-cmp-prt-obj.prt-code = buf_temp-prt-obj.prt-code
        no-error .
      if not available buf_temp-cmp-prt-obj
      then do:
        create buf_temp-cmp-prt-obj .
        assign
          buf_temp-cmp-prt-obj.gds-code = buf_temp-gds-obj.gds-code
          buf_temp-cmp-prt-obj.prt-code = buf_temp-prt-obj.prt-code
        .
      end.
      assign
        buf_temp-cmp-prt-obj.remote-fact-qnty = buf_temp-prt-obj.fact-qnty
        buf_temp-cmp-prt-obj.remote-free-qnty = buf_temp-prt-obj.free-qnty
      .
    end.
    for each buf_temp-parts
      where buf_temp-parts.obj-type  = buf_temp-gds-obj.obj-type
        and buf_temp-parts.obj-code  = buf_temp-gds-obj.obj-code
        and buf_temp-parts.artic     = buf_temp-gds-obj.artic
        and buf_temp-parts.prod-type = buf_temp-gds-obj.prod-type
        and buf_temp-parts.prod-code = buf_temp-gds-obj.prod-code
    on error undo, return error return-value
    :
      find first buf_temp-cmp-parts
        where buf_temp-cmp-parts.gds-code  = buf_temp-gds-obj.gds-code
          and buf_temp-cmp-parts.in-code   = buf_temp-parts.in-code
          and buf_temp-cmp-parts.out-code  = buf_temp-parts.out-code
          and buf_temp-cmp-parts.part-code = buf_temp-parts.part-code
        no-error .
      if not available buf_temp-cmp-parts
      then do:
        create buf_temp-cmp-parts .
        assign
          buf_temp-cmp-parts.gds-code  = buf_temp-gds-obj.gds-code
          buf_temp-cmp-parts.in-code   = buf_temp-parts.in-code
          buf_temp-cmp-parts.out-code  = buf_temp-parts.out-code
          buf_temp-cmp-parts.part-code = buf_temp-parts.part-code
        .
      end.
      assign
        buf_temp-cmp-parts.remote-fact-qnty = buf_temp-parts.fact-qnty
      .
    end.
  end.
  define variable v-error-file-name as character no-undo .
  define variable v-log-file-name   as character no-undo .
  define variable v-error-exist     as logical   no-undo .
  define variable v-error-message   as character no-undo .
  define variable v-log-message     as character no-undo .
  assign
    v-error-exist     = false
    v-error-file-name = 'cmdcmpgd.err':u
    v-log-file-name   = 'cmdcmpgd.log':u
  .
  for each buf_temp-cmp-gds-obj
  on error undo, return error return-value
  :
    if buf_temp-cmp-gds-obj.current-fact-qnty <> buf_temp-cmp-gds-obj.remote-fact-qnty
    then do:
      assign
        buf_temp-cmp-gds-obj.error-qnty = true
      .
    end.
    for each buf_temp-cmp-prt-obj
      where buf_temp-cmp-prt-obj.gds-code = buf_temp-cmp-gds-obj.gds-code
    on error undo, return error return-value
    :
      if buf_temp-cmp-prt-obj.current-fact-qnty <> buf_temp-cmp-prt-obj.remote-fact-qnty
      then do:
        assign
          buf_temp-cmp-gds-obj.error-qnty = true
        .
      end.
    end.
  end.
  for each buf_temp-cmp-gds-obj
    where buf_temp-cmp-gds-obj.error-qnty = true
  on error undo, return error return-value
  :
    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ) .
    assign
      v-error-exist   = true
      v-error-message = substitute("&1 товар_на_объекте код_товара &2 факт_количество_в_ГБД &3 факт_количество_в_УБД &4 свободное_количество_в_ГБД &5 свободное_количество_в_УБД &6"
                                  ,substitute('&1 &2 &3 &4':u
                                             ,string(v-today, '99/99/9999':u)
                                             ,string(v-time, 'HH:MM:SS':u)
                                             ,p-obj-type
                                             ,p-obj-code
                                             )
                                  ,buf_temp-cmp-gds-obj.gds-code
                                  ,buf_temp-cmp-gds-obj.current-fact-qnty
                                  ,buf_temp-cmp-gds-obj.remote-fact-qnty
                                  ,buf_temp-cmp-gds-obj.current-free-qnty
                                  ,buf_temp-cmp-gds-obj.remote-free-qnty
                                  )
                      + chr(10)
    .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run file-wr in g#library
  (input v-error-file-name
  ,input v-error-message
  )  .
    for each buf_temp-cmp-prt-obj
      where buf_temp-cmp-prt-obj.gds-code = buf_temp-cmp-gds-obj.gds-code
    on error undo, return error return-value
    :
      run cur-time in this-procedure
        (output v-today
        ,output v-time
        ) .
      assign
        v-error-message = substitute("  признак_на_объекте код_товара &1 код_признака &2 факт_количество_в_ГБД &3 факт_количество_в_УБД &4 свободное_количество_в_ГБД &5 свободное_количество_в_УБД &6"
                                    ,buf_temp-cmp-prt-obj.gds-code
                                    ,buf_temp-cmp-prt-obj.prt-code
                                    ,buf_temp-cmp-prt-obj.current-fact-qnty
                                    ,buf_temp-cmp-prt-obj.remote-fact-qnty
                                    ,buf_temp-cmp-prt-obj.current-free-qnty
                                    ,buf_temp-cmp-prt-obj.remote-free-qnty
                                    )
                        + chr(10)
      .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run file-wr in g#library
  (input v-error-file-name
  ,input v-error-message
  )  .
    end.
    for each buf_temp-cmp-parts
      where buf_temp-cmp-parts.gds-code = buf_temp-cmp-gds-obj.gds-code
    on error undo, return error return-value
    :
      assign
        v-error-exist   = true
        v-error-message = substitute("  партия код_товара &1 документ &2 резерв &3 код_партии &4 факт_количество_в_ГБД &5 факт_количество_в_УБД &6"
                                    ,buf_temp-cmp-parts.gds-code
                                    ,buf_temp-cmp-parts.in-code
                                    ,buf_temp-cmp-parts.out-code
                                    ,buf_temp-cmp-parts.part-code
                                    ,buf_temp-cmp-parts.current-fact-qnty
                                    ,buf_temp-cmp-parts.remote-fact-qnty
                                    )
                        + chr(10)
      .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run file-wr in g#library
  (input v-error-file-name
  ,input v-error-message
  )  .
    end.
  end.
  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .
  if v-error-exist = true
  then do:
    assign
      v-log-message = substitute("** &1 &2 объект &3 &4 найдены_ошибки_при_сравнении_товаров"
                                ,string(v-today,'99/99/9999':u)
                                ,string(v-time,'HH:MM:SS':U)
                                ,p-obj-type
                                ,p-obj-code
                                )
                    + chr(10)
    .
  end.
  else do:
    assign
      v-log-message = substitute("__ &1 &2 объект &3 &4 сравнение_остатков_прошло_успешно"
                                ,string(v-today,'99/99/9999':u)
                                ,string(v-time,'HH:MM:SS':U)
                                ,p-obj-type
                                ,p-obj-code
                                )
                    + chr(10)
    .
  end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run file-wr in g#library
  (input v-log-file-name
  ,input v-log-message
  )  .
end.
