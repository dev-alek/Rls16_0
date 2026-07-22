block-level on error undo, throw.
define input-output parameter p-rid      as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-silent          as logical no-undo .
define input parameter p-role            as character no-undo .
define input parameter p-staff-code      as integer no-undo .
define input parameter p-psn-code        like  ub.person.psn-code      no-undo .
define input parameter p-level           as character no-undo .
define input parameter p-date-start      like ub.staff.date-start no-undo .
define input parameter p-date-end        like ub.staff.date-end no-undo .
define input parameter p-db-num          like ub.db.db-num no-undo .
define input parameter p-host-code       like ub.sysconf.host-code no-undo .
define input parameter p-obj-type        like ub.clients.obj-type no-undo .
define input parameter p-obj-code        like ub.clients.obj-code no-undo .
define input parameter p-work-place      as character no-undo .
define input parameter p-password        as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: staff01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/staff01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке персонала".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable v-curr-db-num like ub.db.db-num no-undo .
define variable v-err-mess as character no-undo .
define variable v-role-name as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-role-level as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-work-place as character no-undo .
define variable v-no-uniq as logical no-undo .
define buffer buf_staff for ub.staff.
define buffer main_staff for ub.staff .
define temp-table tt-staff no-undo like ub.staff.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U
and p-mode <> 'удаление':U
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
  if lookup( p-role, 'C,S':U) = 0 then do:
    assign
    v-err-mess = substitute("Неизвестная роль персонала &1", p-role).
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo main-block, return error '':U.
  end.
      assign
      v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
      no-error.
  if v-curr-db-num  <> 0
  and v-curr-db-num <> p-db-num
  and p-level = 'db':U  then do:
    assign
    v-err-mess = substitute("Нельзя изменять запись &1 в чужой БД&2БД для &1 - &3, текущая БД &4"
                           , p-role
                           , chr(10)
                           , v-role-name
                           , p-db-num
                           , v-curr-db-num
                           ).
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo main-block, return error '':U.
  end.
  if p-staff-code = 0
  or p-staff-code = ? then do:
    assign
    v-err-mess = substitute("Код персонала для роли типа &1 должен быть > 0 "
                            , v-role-name).
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo main-block, return error (if p-silent then v-err-mess else "staff-code":U).
  end.
  if p-date-start > p-date-end
  or (p-mode = 'удаление':U
     and p-date-start > v-today
     )
  then do:
    assign
    v-err-mess = substitute("Дата начала работы &1 в данной должности должна быть меньше даты окончания работы &1 "
                            , string(p-date-start, "99/99/9999")
                            , string(p-date-end, "99/99/9999")
                            ).
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo main-block, return error (if p-silent then v-err-mess else "date-start":U).
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    v-work-place = gbclcode-get-work-place (
                                             input p-role
                                            ,input p-level
                                            ,input p-db-num
                                            ,input p-host-code
                                            ,input p-obj-type
                                            ,input p-obj-code
                                               ) .
  end.
  else do:
    FIND FIRST main_staff EXCLUSIVE-lock where
              recid(main_staff) = p-rid No-ERROR.
    if not available main_staff then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ПЕРСОНАЛА - p-rid" p-rid
      view-as alert-box error .
      undo main-block, return error '':u.
    end.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    if not available tt-staff then create tt-staff.
    ASSIGN
    tt-staff.role       = p-role
    tt-staff.role-level = p-level
    tt-staff.work-place = v-work-place
    tt-staff.staff-code = p-staff-code
    tt-staff.date-start = p-date-start
    tt-staff.date-end   = p-date-end
    .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (p-mode = 'ДОБАВЛЕНИЕ':U) then do:
  find first buf_staff no-lock where
            buf_staff.role = tt-staff.role
        and buf_staff.role-level = tt-staff.role-level
        and buf_staff.work-place = tt-staff.work-place
        and buf_staff.staff-code = tt-staff.staff-code
        and buf_staff.date-start >= tt-staff.date-start no-error .
  if available buf_staff
  and recid(buf_staff) <> recid(tt-staff)
  then do:
      v-no-uniq = yes.
  end.
end.
if not v-no-uniq then do:
  find first buf_staff no-lock where
            buf_staff.role = tt-staff.role
        and buf_staff.role-level = tt-staff.role-level
        and buf_staff.work-place = tt-staff.work-place
        and buf_staff.staff-code = tt-staff.staff-code
        and buf_staff.date-start = tt-staff.date-start no-error .
  if available buf_staff
  and recid(buf_staff) <> recid(tt-staff)
  then do:
      v-no-uniq = yes.
  end.
end.
if not v-no-uniq then do:
  find first buf_staff no-lock where
            buf_staff.role = tt-staff.role
        and buf_staff.role-level = tt-staff.role-level
        and buf_staff.work-place = tt-staff.work-place
        and buf_staff.staff-code = tt-staff.staff-code
        and buf_staff.date-start <= tt-staff.date-start
        and buf_staff.date-end >= tt-staff.date-start
        no-error .
  if available buf_staff
  and recid(buf_staff) <> recid(tt-staff)
  then do:
      v-no-uniq = yes.
  end.
end.
if not v-no-uniq then do:
  find first buf_staff no-lock where
            buf_staff.role = tt-staff.role
        and buf_staff.role-level = tt-staff.role-level
        and buf_staff.work-place = tt-staff.work-place
        and buf_staff.staff-code = tt-staff.staff-code
        and buf_staff.date-start <= tt-staff.date-end
        and buf_staff.date-end >= tt-staff.date-end
        no-error .
  if available buf_staff
  and recid(buf_staff) <> recid(tt-staff)
  then do:
      v-no-uniq = yes.
  end.
end.
if not v-no-uniq then do:
  find first buf_staff no-lock where
            buf_staff.role = tt-staff.role
        and buf_staff.role-level = tt-staff.role-level
        and buf_staff.work-place = tt-staff.work-place
        and buf_staff.staff-code = tt-staff.staff-code
        and buf_staff.date-start >= tt-staff.date-start
        and buf_staff.date-start <= tt-staff.date-end
        no-error .
  if available buf_staff and
  recid(buf_staff) <> recid(tt-staff)
  then do:
      v-no-uniq = yes.
  end.
end.
if not v-no-uniq then do:
  find first buf_staff no-lock where
            buf_staff.role = tt-staff.role
        and buf_staff.role-level = tt-staff.role-level
        and buf_staff.work-place = tt-staff.work-place
        and buf_staff.staff-code = tt-staff.staff-code
        and buf_staff.date-end >= tt-staff.date-start
        and buf_staff.date-end <= tt-staff.date-end
        no-error .
  if available buf_staff
  and recid(buf_staff) <> recid(tt-staff)
  then do:
      v-no-uniq = yes.
  end.
end.
if v-no-uniq then do:
  v-err-mess =  substitute("Запись ПЕРСОНАЛА с определенным кодом должна быть уникальна&1" +
              "в пределах БД или фирмы или объекта во всем периоде действия&1" +
              "(Добавлять можно только если начиная с текущего момента других таких записей нет)&1" +
              "Попытка сохранить запись - &2 Действует с &3 по &4&1" +
              "Найдена уже существующая запись - &5 Действует с &6 по &7"
              ,chr(10)
              ,gbclcode-get-position  ( input tt-staff.role
                                        ,input tt-staff.role-level
                                        ,input tt-staff.work-place
                                        ,input tt-staff.staff-code )
              ,string(tt-staff.date-start, "99/99/9999")
              ,(if tt-staff.date-end = 12/31/9999 then "настоящее время" else string(tt-staff.date-end, "99/99/9999"))
              ,gbclcode-get-position  ( input buf_staff.role
                                        ,input buf_staff.role-level
                                        ,input buf_staff.work-place
                                        ,input buf_staff.staff-code )
              ,string(buf_staff.date-start, "99/99/9999")
              ,(if buf_staff.date-end = 12/31/9999 then "настоящее время" else string(buf_staff.date-end, "99/99/9999"))
              ).
end.
  end.
  else do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (p-mode = 'ДОБАВЛЕНИЕ':U) then do:
  find first buf_staff no-lock where
            buf_staff.role = main_staff.role
        and buf_staff.role-level = main_staff.role-level
        and buf_staff.work-place = main_staff.work-place
        and buf_staff.staff-code = main_staff.staff-code
        and buf_staff.date-start >= main_staff.date-start no-error .
  if available buf_staff
  and recid(buf_staff) <> recid(main_staff)
  then do:
      v-no-uniq = yes.
  end.
end.
if not v-no-uniq then do:
  find first buf_staff no-lock where
            buf_staff.role = main_staff.role
        and buf_staff.role-level = main_staff.role-level
        and buf_staff.work-place = main_staff.work-place
        and buf_staff.staff-code = main_staff.staff-code
        and buf_staff.date-start = main_staff.date-start no-error .
  if available buf_staff
  and recid(buf_staff) <> recid(main_staff)
  then do:
      v-no-uniq = yes.
  end.
end.
if not v-no-uniq then do:
  find first buf_staff no-lock where
            buf_staff.role = main_staff.role
        and buf_staff.role-level = main_staff.role-level
        and buf_staff.work-place = main_staff.work-place
        and buf_staff.staff-code = main_staff.staff-code
        and buf_staff.date-start <= main_staff.date-start
        and buf_staff.date-end >= main_staff.date-start
        no-error .
  if available buf_staff
  and recid(buf_staff) <> recid(main_staff)
  then do:
      v-no-uniq = yes.
  end.
end.
if not v-no-uniq then do:
  find first buf_staff no-lock where
            buf_staff.role = main_staff.role
        and buf_staff.role-level = main_staff.role-level
        and buf_staff.work-place = main_staff.work-place
        and buf_staff.staff-code = main_staff.staff-code
        and buf_staff.date-start <= main_staff.date-end
        and buf_staff.date-end >= main_staff.date-end
        no-error .
  if available buf_staff
  and recid(buf_staff) <> recid(main_staff)
  then do:
      v-no-uniq = yes.
  end.
end.
if not v-no-uniq then do:
  find first buf_staff no-lock where
            buf_staff.role = main_staff.role
        and buf_staff.role-level = main_staff.role-level
        and buf_staff.work-place = main_staff.work-place
        and buf_staff.staff-code = main_staff.staff-code
        and buf_staff.date-start >= main_staff.date-start
        and buf_staff.date-start <= main_staff.date-end
        no-error .
  if available buf_staff and
  recid(buf_staff) <> recid(main_staff)
  then do:
      v-no-uniq = yes.
  end.
end.
if not v-no-uniq then do:
  find first buf_staff no-lock where
            buf_staff.role = main_staff.role
        and buf_staff.role-level = main_staff.role-level
        and buf_staff.work-place = main_staff.work-place
        and buf_staff.staff-code = main_staff.staff-code
        and buf_staff.date-end >= main_staff.date-start
        and buf_staff.date-end <= main_staff.date-end
        no-error .
  if available buf_staff
  and recid(buf_staff) <> recid(main_staff)
  then do:
      v-no-uniq = yes.
  end.
end.
if v-no-uniq then do:
  v-err-mess =  substitute("Запись ПЕРСОНАЛА с определенным кодом должна быть уникальна&1" +
              "в пределах БД или фирмы или объекта во всем периоде действия&1" +
              "(Добавлять можно только если начиная с текущего момента других таких записей нет)&1" +
              "Попытка сохранить запись - &2 Действует с &3 по &4&1" +
              "Найдена уже существующая запись - &5 Действует с &6 по &7"
              ,chr(10)
              ,gbclcode-get-position  ( input main_staff.role
                                        ,input main_staff.role-level
                                        ,input main_staff.work-place
                                        ,input main_staff.staff-code )
              ,string(main_staff.date-start, "99/99/9999")
              ,(if main_staff.date-end = 12/31/9999 then "настоящее время" else string(main_staff.date-end, "99/99/9999"))
              ,gbclcode-get-position  ( input buf_staff.role
                                        ,input buf_staff.role-level
                                        ,input buf_staff.work-place
                                        ,input buf_staff.staff-code )
              ,string(buf_staff.date-start, "99/99/9999")
              ,(if buf_staff.date-end = 12/31/9999 then "настоящее время" else string(buf_staff.date-end, "99/99/9999"))
              ).
end.
  end.
  if v-no-uniq then do:
    undo main-block, return error v-err-mess.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create main_staff.
    assign
    main_staff.role = p-role
    main_staff.role-level = p-level
    main_staff.work-place = v-work-place
    main_staff.date-start = p-date-start
    main_staff.staff-code = p-staff-code
    main_staff.db-num = p-db-num
    main_staff.host-code = p-host-code
    main_staff.obj-type = p-obj-type
    main_staff.obj-code = p-obj-code
    main_staff.obj-code = p-obj-code
    p-rid = recid(main_staff)
    .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    v-work-place = p-work-place.
    if p-mode <> 'удаление':U
    then do:
      if main_staff.psn-code <>  p-psn-code
      or main_staff.role <>  p-role
      or main_staff.role-level <>  p-level
      or main_staff.work-place <>  v-work-place
      or main_staff.date-start <>  p-date-start
      or main_staff.db-num     <>  p-db-num
      or main_staff.host-code  <>  p-host-code
      or main_staff.obj-type   <>  p-obj-type
      or main_staff.obj-code   <>  p-obj-code
      then do:
        message
        vss-workfile vss-revision vss-description skip
        "Для уже имеющейся записи нельзя изменить"
        "код физ.лица и/или" skip
        "роль" skip
        "место работы и/или" skip
        "дату начала работы в данной роли и/или" skip
        "№ БД, код фирмы, объект" skip
        view-as alert-box ERROR.
        undo main-block, return error '':U.
      end.
    end.
  end.
  if p-mode = 'удаление':U then do:
    run cur-time in this-procedure ( output v-today, output v-time).
    assign
    main_staff.date-end = v-today
    .
  end.
  else do:
    assign
    main_staff.psn-code = p-psn-code
    main_staff.password = p-password
    main_staff.date-end = p-date-end
    .
  end.
  release main_staff no-error.
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при сохранении записи ПЕРСОНАЛА" skip
    ERROR-STATUS:GET-NUMBER(1) skip
    return-value
    view-as alert-box .
    undo main-block, return error "":U.
  end.
end.
PROCEDURE err-mess:
DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("&1 чел&2: &3", v-role-name, p-psn-code,  p-mess).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
