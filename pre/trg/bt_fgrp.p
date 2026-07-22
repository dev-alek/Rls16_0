block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обработка изменений группы меню".
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
DEFINE New SHARED TEMP-TABLE cash-fgrp no-undo
FIELD node-code like ub.fbr-gds-grp.node-code
FIELD upper-code like ub.fbr-gds-grp.upper-code
FIELD out-code like ub.fbr-gds-grp.out-code
FIELD node-name like ub.fbr-gds-grp.node-name
FIELD upper-out-code like ub.fbr-gds-grp.out-code
FIELD lvl-num        like ub.fbr-gds-grp.lvl-num
FIELD stts  as integer
FIELD action-code as integer
index iout-code IS PRIMARY out-code
index istts stts
index ilvl action-code lvl-num
.
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
define temp-table temp-fgrp-list no-undo
  field action-num  as integer
  field obj-type    like ub.fbr-gds-grp.obj-type
  field obj-code    like ub.fbr-gds-grp.obj-code
  field node-code   like ub.fbr-gds-grp.node-code
  field out-code    like ub.fbr-gds-grp.out-code
  field upper-code  like ub.fbr-gds-grp.upper-code
  field upper-out-code  like ub.fbr-gds-grp.out-code
  field lvl-num      like ub.fbr-gds-grp.lvl-num
  field action      as character
  field bp_rowid    as rowid
  index xpk is primary unique action-num
  index iobj obj-type obj-code
.
define variable  p-message-on as logical   no-undo .
define variable log-file-name as character no-undo init "send-cd.txt":U.
define variable v-view-log as logical no-undo .
define variable v-stop as logical no-undo .
main-block:
do
on error undo main-block, return error return-value
:
  assign
  p-message-on = (if entry(1, p-parameter, chr(4)) = "yes"
                  then yes
                  else (if entry(1, p-parameter, chr(4)) = "no"
                        then no
                        else ?)
                )
  no-error
  .
  if error-status:error or p-message-on = ? then return error.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ждите... Поиск информации, подлежащей отправке на кассы...")
                                            ).
  run create-fgrp-list in this-procedure .
  run waitfram-hide in this-procedure .
  run process-fgrp-list in this-procedure .
  run close-fgrp-list in this-procedure .
end.
procedure create-fgrp-list :
  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_temp-fgrp-list for temp-fgrp-list .
  do
  on error undo, return error return-value
  :
    for each buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = 'fgrp':U
        and buf_BatchProcess.bp_status     = 'N':U
    on error undo, return error return-value
    :
      create buf_temp-fgrp-list .
      assign
        buf_temp-fgrp-list.action-num  = buf_BatchProcess.BatchProcess#
        buf_temp-fgrp-list.obj-type    = buf_BatchProcess.charkey_one
        buf_temp-fgrp-list.obj-code    = buf_BatchProcess.key#_one
        buf_temp-fgrp-list.node-code   = buf_BatchProcess.key#_two
        buf_temp-fgrp-list.upper-code  = buf_BatchProcess.key#_three
        buf_temp-fgrp-list.out-code    = integer(buf_BatchProcess.charkey_two)
        buf_temp-fgrp-list.upper-out-code = integer(entry(1, buf_BatchProcess.charkey_three))
        buf_temp-fgrp-list.lvl-num     = integer(entry(2, buf_BatchProcess.charkey_three))
        buf_temp-fgrp-list.action      = buf_BatchProcess.bp_execsystime
        buf_temp-fgrp-list.bp_rowid   = rowid(buf_BatchProcess)
      .
    end.
  end.
end procedure.
procedure process-fgrp-list :
  define buffer buf_temp-fgrp-list for temp-fgrp-list .
  define buffer cli_shops for ub.clients .
  define buffer buf_cash-desk for ub.cash-desk .
  define variable lns-cnt as integer no-undo .
  define variable line-rec as recid no-undo .
  define variable v-db-num like ub.db.db-num no-undo .
  define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
  define buffer buf_clients for ub.clients.
  do
  on error undo, return error return-value
  :
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
    _buf_temp-fgrp-list:
    for each buf_temp-fgrp-list
    break
    by buf_temp-fgrp-list.obj-type
    by buf_temp-fgrp-list.obj-code
    on error undo, return error return-value
    :
      if first-of(buf_temp-fgrp-list.obj-code) then do:
        run get-stop-state in p-log-handle (output v-stop).
        if v-stop then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Процедура пересылки остановлена пользователем"
                                  )
                                    ).
          leave _buf_temp-fgrp-list.
        end.
        for each cash-fgrp:
          delete cash-fgrp.
        end.
      end.
      find first cash-fgrp where
                cash-fgrp.out-code = buf_temp-fgrp-list.out-code no-error .
      if not avail cash-fgrp then do:
        create cash-fgrp.
        assign
        cash-fgrp.out-code = buf_temp-fgrp-list.out-code
        .
      end.
      assign
      cash-fgrp.node-code = buf_temp-fgrp-list.node-code
      cash-fgrp.upper-code = buf_temp-fgrp-list.upper-code
      cash-fgrp.upper-out-code = buf_temp-fgrp-list.upper-out-code
      cash-fgrp.stts = (if buf_temp-fgrp-list.action = "D":U then 1 else 0)
      cash-fgrp.lvl-num = buf_temp-fgrp-list.lvl-num
      cash-fgrp.action-code = buf_temp-fgrp-list.action-num
      .
      if last-of(buf_temp-fgrp-list.obj-code) then do:
        if can-find(first cash-fgrp)
        and can-find(first buf_cash-desk where
                          buf_cash-desk.db-num = v-db-num
                      AND buf_cash-desk.OBJ-CODE = buf_temp-fgrp-list.obj-code
                      AND buf_cash-desk.pos-type = 'MAGIA-XML':U
                          ) then do:
           run str/send-fgr.p (
                             input parparentproc
                            ,input this-procedure
                            ,input p-log-handle
                            ,input(string(buf_temp-fgrp-list.obj-code) + chr(4) + "U":U + chr(4) + "yes":U)
                          ) no-error .
          if error-status:error then do:
            run set-view-log in p-log-handle(yes).
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure close-fgrp-list :
  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_temp-fgrp-list for temp-fgrp-list .
  do
  on error undo, return error return-value
  :
    for each buf_temp-fgrp-list
    on error undo, return error return-value
    :
      do transaction
      on error undo, return error return-value
      :
  find first buf_batchprocess exclusive-lock
    where rowid(buf_batchprocess) = buf_temp-fgrp-list.bp_rowid
    no-error .
  if not available buf_batchprocess then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись пересчета архива" skip
      view-as alert-box error .
    undo, return error .
  end.
  if buf_batchprocess.bp_status <> 'N':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запись пересчета архива имеет статус, отличный от" 'N':U skip
      "BP_Type"       buf_batchprocess.BP_Type       skip
      "BP_Status"     buf_batchprocess.BP_Status     skip
      "Key#_One"      buf_batchprocess.Key#_One      skip
      "Key#_Two"      buf_batchprocess.Key#_Two      skip
      "Key#_Three"    buf_batchprocess.Key#_Three    skip
      "CharKey_One"   buf_batchprocess.CharKey_One   skip
      "CharKey_Two"   buf_batchprocess.CharKey_Two   skip
      "CharKey_Three" buf_batchprocess.CharKey_Three skip
      view-as alert-box error .
    undo, return error .
  end.
    define variable v-btpr_upd-today-4 as date      no-undo.
  define variable v-btpr_upd-time-4  as integer   no-undo.
  run cur-time in this-procedure ( output v-btpr_upd-today-4
                                 , output v-btpr_upd-time-4
                                 ).
  assign
    buf_batchprocess.bp_status         = 'D':U
    buf_batchprocess.bp_execcounttries = buf_batchprocess.bp_execcounttries + 1
    buf_batchprocess.bp_execuser_id    = g#userid
    buf_batchprocess.bp_execsysdate    = v-btpr_upd-today-4
    buf_batchprocess.bp_execsystime    = string(v-btpr_upd-time-4, 'hh:mm')
    buf_batchprocess.bp_execsystimeint = v-btpr_upd-time-4
  .
      end.
    end.
  end.
end procedure.
