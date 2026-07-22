define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилиты проверки целостности БД".
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
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
define temp-table temp-object no-undo
  field obj-type   like ub.trn-doc.obj-type
  field obj-code   like ub.trn-doc.obj-code
  field status_    like ub.trn-doc.status_
  field fact-order like ub.trn-doc.fact-order
  index xpk is primary unique obj-type obj-code
.
define temp-table temp-procedure no-undo
  field proc-order    as integer   format ">9"    label "N"
  field proc-mark     as character format "X(1)"  label "*"
  field proc-label    as character format "x(20)" label "Проверка"
  field proc-descr    as character format "x(45)" label "Описание"
  field proc-group    as character format "x(1)"  label "Группа"
  field proc-name     as character format "x(20)" label "Процедура"
  index xpk is primary unique proc-order
.
define variable v-proc-order as integer   no-undo .
define variable del-list     as character no-undo.
define variable mark         as character no-undo COLUMN-LABEL "*"      FORMAT "x(1)"  .
FUNCTION get-mark RETURNS CHARACTER
  ( input v-recid  as recid )  FORWARD.
DEFINE BUTTON b-check
     LABEL "&Проверить"
     SIZE 12 BY 1.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Подробная проверка целостности товаров".
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1 TOOLTIP "Подробная проверка целостности товаров".
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.
DEFINE VARIABLE EDITOR-Help AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 35.88 BY 5 NO-UNDO.
DEFINE VARIABLE EDITOR-Log AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 42.38 BY 5
     BGCOLOR 15  NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
      temp-procedure SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 DISPLAY
      proc-order
      get-mark(recid(temp-procedure)) @ mark
      proc-label
      proc-descr
      proc-group
      proc-name
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79.25 BY 8.5
         BGCOLOR 15 .
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.5 COL 2
     b-help AT ROW 1.5 COL 12.13
     b-mark AT ROW 1.5 COL 22.13
     b-check AT ROW 1.5 COL 26.13
     BROWSE-1 AT ROW 2.71 COL 2
     EDITOR-Log AT ROW 11.5 COL 2.13 NO-LABEL
     EDITOR-Help AT ROW 11.5 COL 45.5 NO-LABEL
     SPACE(0.49) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Утилиты проверки БД"
         CANCEL-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.
ASSIGN
       EDITOR-Help:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       EDITOR-Log:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-check IN FRAME Dialog-Frame
DO:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable lok          as logical   no-undo .
  define variable process-list as character no-undo .
  do
  on stop undo, return no-apply
  :
    if del-list = "" then do:
      if not available temp-procedure then do:
        message
          "Неправильный выбор поцедуры"
          view-as alert-box .
        return no-apply.
      end.
      assign
        process-list = string(recid(temp-procedure))
      .
    end.
    else do:
      assign
        process-list = del-list
      .
    end.
    lok = no.
    message
      "Выбрано" num-entries(process-list) "процедур проверки" skip
      "Продолжить?"
      view-as alert-box question buttons ok-cancel update lok .
    if lok <> true then do:
      return no-apply.
    end.
    define variable v-ind as integer no-undo .
    do v-ind = 1 to num-entries(process-list) :
      run make-check in this-procedure
        (input integer (entry (v-ind, process-list))
        ) .
    end.
    assign
      lok = browse BROWSE-1 :refresh() .
    .
  end.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if not available temp-procedure then do:
    message
      "Неправильный выбор партии."
      view-as alert-box .
    return no-apply.
  end.
  define variable v-temp-procedure-recid as character no-undo .
  assign
    v-temp-procedure-recid = string (recid (temp-procedure))
  .
  if lookup( v-temp-procedure-recid, del-list ) > 0 then do:
    assign
      del-list = diff-list(del-list, v-temp-procedure-recid, "" )
    .
    disp "" @ mark with browse BROWSE-1 .
  end.
  else do:
    assign
      del-list = add-list(del-list, v-temp-procedure-recid, "" )
    .
    disp "*" @ mark with browse BROWSE-1 .
  end.
  define variable lok as logical no-undo .
  lok = BROWSE-1 :select-next-row ().
  apply "entry":u to BROWSE-1 in frame Dialog-Frame.
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run fill-temp-procedure in this-procedure .
  RUN enable_UI.
  RUN show-help in this-procedure  .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE chk-allcheck :
  define variable icount      as integer no-undo .
  define variable v-test-name as character no-undo .
  assign
    v-test-name = "Подробная проверка товара (chk-allcheck)"
  .
  run log-test-started in this-procedure
    (input v-test-name
    ).
  run utl/allcheck.p (input parparentproc) .
  assign
    icount = integer(return-value) no-error
  .
  run log-test-finished in this-procedure
    (input v-test-name
    ,input icount
    ) .
END PROCEDURE.
PROCEDURE chk-batchprocess :
END PROCEDURE.
PROCEDURE chk-doc-line :
  define variable icount      as integer no-undo .
  define variable ind         as integer no-undo .
  define variable v-artic-str as character no-undo .
  define variable v-test-name as character no-undo .
  assign
    v-test-name = "Проверка строк складских документов (chk-doc-line)"
  .
  run log-test-started in this-procedure
    (input v-test-name
    ).
  run waitfram-show in this-procedure
    (input v-test-name
    ).
  run clear-temp-object in this-procedure .
  for each doc-line no-lock
  :
    assign
      ind = ind + 1
    .
    if ind mod 10 = 0 then do:
      assign
        v-artic-str = string(doc-line.artic)
                    + " " + string(doc-line.prod-type)
                    + " " + string(doc-line.prod-code)
      .
      run waitfram-show in this-procedure
        (input "Документ " + string(doc-line.doc-code, 'x(14)':u)
          + " Артикул " + string(v-artic-str, 'x(25)':u)
          + " Найдено ошибок " + STRING(icount)
        ).
    end.
    find first ub.trn-doc no-lock
      where ub.trn-doc.doc-code = ub.doc-line.doc-code
      no-error .
    if not available ub.trn-doc then do:
      assign
        icount = icount + 1
      .
      run register-document in this-procedure
        (input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.status_
        ,input ub.doc-line.fact-order
        ).
      run log-error
        (input "doc-line"
        ,input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.artic
        ,input ub.doc-line.prod-type
        ,input ub.doc-line.prod-code
        ,input 'trn-doc-not-exist '
          + ' doc-code = ' + string(ub.doc-line.doc-code)
        ).
      next .
    end.
    find first ub.goods no-lock
      where ub.goods.artic     = ub.doc-line.artic
        and ub.goods.prod-type = ub.doc-line.prod-type
        and ub.goods.prod-code = ub.doc-line.prod-code
      no-error .
    if not available ub.goods then do:
      assign
        icount = icount + 1
      .
      run register-document in this-procedure
        (input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.status_
        ,input ub.doc-line.fact-order
        ).
      run log-error
        (input "doc-line"
        ,input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.artic
        ,input ub.doc-line.prod-type
        ,input ub.doc-line.prod-code
        ,input 'goods-not-exist '
          + ' doc-code = ' + string(ub.doc-line.doc-code)
        ).
      next .
    end.
    if ub.doc-line.status_ <> ub.trn-doc.status_  then do:
      assign
        icount = icount + 1
      .
      run register-document in this-procedure
        (input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.status_
        ,input ub.doc-line.fact-order
        ).
      run register-document in this-procedure
        (input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.trn-doc.status_
        ,input ub.doc-line.fact-order
        ).
      run log-error
        (input "doc-line"
        ,input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.artic
        ,input ub.doc-line.prod-type
        ,input ub.doc-line.prod-code
        ,input 'doc-line.status_ '
          + ' doc-code = ' + string(ub.doc-line.doc-code)
          + ' trn-doc.status_  = ' + string(ub.trn-doc.status_)
          + ' doc-line.status_ = ' + string(ub.doc-line.status_)
        ).
      next .
    end.
    if ub.doc-line.obj-type <> ub.trn-doc.obj-type
    or ub.doc-line.obj-code <> ub.trn-doc.obj-code
    then do:
      assign
        icount = icount + 1
      .
      run register-document in this-procedure
        (input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.status_
        ,input ub.doc-line.fact-order
        ).
      run log-error
        (input "doc-line_obj-type_obj-code"
        ,input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.artic
        ,input ub.doc-line.prod-type
        ,input ub.doc-line.prod-code
        ,input 'doc-line.obj-type doc-line.obj-code '
          + ' doc-code = ' + string(ub.doc-line.doc-code)
        ).
      next .
    end.
    if ub.trn-doc.status_ <> 'факт':U then do:
      next .
    end.
    define variable v-parts-fact-qnty    as decimal no-undo .
    define variable v-gds-dtl-fact-qnty  as decimal no-undo .
    assign
      v-parts-fact-qnty   = 0
      v-gds-dtl-fact-qnty = 0
    .
    if ub.goods.gds-type = 'т':U then do:
      for each ub.parts no-lock
        where ub.parts.out-code  = ub.doc-line.doc-code
          and ub.parts.obj-type  = ub.doc-line.obj-type
          and ub.parts.obj-code  = ub.doc-line.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-type = ub.doc-line.prod-type
          and ub.parts.prod-code = ub.doc-line.prod-code
      :
        assign
          v-parts-fact-qnty = v-parts-fact-qnty + parts.fact-qnty
        .
      end.
    end.
    else do:
      find first ub.parts no-lock
        where ub.parts.out-code  = ub.doc-line.doc-code
          and ub.parts.obj-type  = ub.doc-line.obj-type
          and ub.parts.obj-code  = ub.doc-line.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-type = ub.doc-line.prod-type
          and ub.parts.prod-code = ub.doc-line.prod-code
        no-error .
      if available parts then do:
        assign
          icount = icount + 1
        .
        run register-document in this-procedure
          (input ub.doc-line.obj-type
          ,input ub.doc-line.obj-code
          ,input ub.doc-line.status_
          ,input ub.doc-line.fact-order
          ).
        run log-error
          (input "doc-line"
          ,input ub.doc-line.obj-type
          ,input ub.doc-line.obj-code
          ,input ub.doc-line.artic
          ,input ub.doc-line.prod-type
          ,input ub.doc-line.prod-code
          ,input 'not_goods_has_parts '
            + ' doc-code = ' + string(ub.doc-line.doc-code)
          ).
        next .
      end.
      assign
        v-parts-fact-qnty = ub.doc-line.fact-qnty
      .
    end.
    for each ub.gds-dtl no-lock
      where ub.gds-dtl.doc-code  = ub.doc-line.doc-code
        and ub.gds-dtl.artic     = ub.doc-line.artic
        and ub.gds-dtl.prod-type = ub.doc-line.prod-type
        and ub.gds-dtl.prod-code = ub.doc-line.prod-code
    :
      assign
        v-gds-dtl-fact-qnty = v-gds-dtl-fact-qnty
                            + (if ub.trn-doc.doc-type <> 'инв':U
                               then ub.gds-dtl.fact-qnty
                               else ub.gds-dtl.doc-qnty
                              )
      .
    end.
    if (( ub.doc-line.fact-qnty <> v-parts-fact-qnty
     or ub.doc-line.fact-qnty <> v-gds-dtl-fact-qnty ) and
        ub.trn-doc.doc-type <> 'инв':U )
     or
      ( ub.trn-doc.doc-type = 'инв':U   and
        ub.doc-line.fact-qnty <> v-parts-fact-qnty )   then do:
      assign
        icount = icount + 1
      .
      run register-document in this-procedure
            (input ub.doc-line.obj-type
            ,input ub.doc-line.obj-code
            ,input ub.doc-line.status_
            ,input ub.doc-line.fact-order
            ).
          run log-error
            (input "doc-line"
            ,input ub.doc-line.obj-type
            ,input ub.doc-line.obj-code
            ,input ub.doc-line.artic
            ,input ub.doc-line.prod-type
            ,input ub.doc-line.prod-code
            ,input 'trn-doc-fact-qnty '
              + ' doc-code = ' + string(ub.doc-line.doc-code)
              + ' doc-line.fact-qnty = ' + string(ub.doc-line.fact-qnty)
              + ' v-parts-fact-qnty = ' + STRING(v-parts-fact-qnty)
              + ' v-gds-dtl-fact-qnty = ' + STRING(v-gds-dtl-fact-qnty)
              + ' тип документа = ' + STRING(ub.trn-doc.doc-type)
              + ' статус = ' + STRING(ub.trn-doc.status_)
            ).
    end.
  end.
  run waitfram-hide in this-procedure .
  run output-temp-object in this-procedure .
  run log-test-finished in this-procedure
    (input v-test-name
    ,input icount
    ) .
END PROCEDURE.
PROCEDURE chk-firm-db-num :
  define variable icount      as integer no-undo .
  define variable ind         as integer no-undo .
  define variable v-test-name as character no-undo .
  assign
    v-test-name = "Проверка соответствия БД объекта главной БД фирмы  (chk-firm-db-num)"
  .
  run log-test-started in this-procedure
    (input v-test-name
    ).
  run utl/chkfrmdb.p (
                  input  this-procedure:handle
                 ,output icount).
  run log-test-finished in this-procedure
    (input v-test-name
    ,input icount
    ) .
END PROCEDURE.
PROCEDURE chk-idxinact :
  define variable icount      as integer no-undo .
  define variable v-test-name as character no-undo .
  assign
    v-test-name = "Неактивные индексы (chk-idxinact)"
  .
  run log-test-started in this-procedure
    (input v-test-name
    ).
  run utl/idxinact.p .
  run log-test-finished in this-procedure
    (input v-test-name
    ,input icount
    ) .
END PROCEDURE.
PROCEDURE chk-price-doc :
  define variable icount      as integer no-undo .
  define variable ind         as integer no-undo .
  define variable v-test-name as character no-undo .
  assign
    v-test-name = "Проверка заголовков переоценок (chk-price-doc)"
  .
  run log-test-started in this-procedure
    (input v-test-name
    ).
  run waitfram-show in this-procedure
    (input v-test-name
    ).
  define buffer buf_price-doc for ub.price-doc .
  for each ub.price-doc no-lock
  :
    assign
      ind = ind + 1
    .
    if ind mod 10 = 0 then do:
      run waitfram-show in this-procedure
        (input "Переоценка " + string(ub.price-doc.doc-num, 'x(8)':u)
          + " Найдено ошибок " + STRING(icount)
        ).
    end.
    if (ub.price-doc.fact-num > 0) <> (ub.price-doc.status_ = 'акт':U) then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input 'price-doc':U
        ,input price-doc.obj-type
        ,input price-doc.obj-code
        ,input ""
        ,input ""
        ,input 0
        ,input 'price-doc-status-fact-num '
          + ' doc-num = ' + string(price-doc.doc-num)
          + ' status_ = ' + string(price-doc.status_)
        ).
    end.
    if ub.price-doc.status_ = 'акт':U then do:
      if ub.price-doc.fact-date = ? then do:
        assign
          icount = icount + 1
        .
        run log-error
          (input 'price-doc':U
          ,input price-doc.obj-type
          ,input price-doc.obj-code
          ,input ""
          ,input ""
          ,input 0
          ,input 'price-doc-status-fact-date '
            + ' doc-num = ' + string(price-doc.doc-num)
            + ' status_ = ' + string(price-doc.status_)
            + ' fact-date = ' + string(price-doc.fact-date)
          ).
      end.
    end.
    if ub.price-doc.status_ = 'акт':U then do:
      find last buf_price-doc no-lock
        where buf_price-doc.obj-type = ub.price-doc.obj-type
          and buf_price-doc.obj-code = ub.price-doc.obj-code
          and buf_price-doc.fact-num < ub.price-doc.fact-num
        use-index fact-close
        no-error .
      if available buf_price-doc then do:
        if buf_price-doc.fact-date > ub.price-doc.fact-date then do:
          assign
            icount = icount + 1
          .
          run log-error
            (input 'price-doc':U
            ,input price-doc.obj-type
            ,input price-doc.obj-code
            ,input ""
            ,input ""
            ,input 0
            ,input 'price-doc-close-fact-order '
              + ' price-doc.doc-num = ' + string(price-doc.doc-num)
              + ' price-doc.fact-num = ' + string(price-doc.fact-num)
              + ' price-doc.fact-date = ' + string(price-doc.fact-date)
              + ' buf_price-doc.doc-num = ' + string(buf_price-doc.doc-num)
              + ' buf_price-doc.fact-num = ' + string(buf_price-doc.fact-num)
              + ' buf_price-doc.fact-date = ' + string(buf_price-doc.fact-date)
            ).
        end.
      end.
    end.
  end.
  run waitfram-hide in this-procedure .
  run log-test-finished in this-procedure
    (input v-test-name
    ,input icount
    ) .
END PROCEDURE.
PROCEDURE chk-price-list :
  define variable icount      as integer no-undo .
  define variable ind         as integer no-undo .
  define variable v-artic-str as character no-undo .
  define variable v-test-name as character no-undo .
  assign
    v-test-name = "Проверка строк переоценок (chk-price-list)"
  .
  run log-test-started in this-procedure
    (input v-test-name
    ).
  run waitfram-show in this-procedure
    (input v-test-name
    ).
  for each ub.price-list no-lock
  :
    assign
      ind = ind + 1
    .
    if ind mod 10 = 0 then do:
      assign
        v-artic-str = string(price-list.artic)
                    + " " + string(price-list.prod-type)
                    + " " + string(price-list.prod-code)
      .
      run waitfram-show in this-procedure
        (input "Переоценка " + string(price-list.doc-num, 'x(8)':u)
          + " Артикул " + string(v-artic-str, 'x(25)':u)
          + " Найдено ошибок " + STRING(icount)
        ).
    end.
    find first ub.price-doc no-lock
      where ub.price-doc.doc-num = ub.price-list.doc-num
      no-error .
    if not available ub.price-doc then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "price-list"
        ,input price-list.obj-type
        ,input price-list.obj-code
        ,input price-list.artic
        ,input price-list.prod-type
        ,input price-list.prod-code
        ,input 'price-doc-not-exist '
          + ' doc-num = ' + string(price-list.doc-num)
        ).
      next .
    end.
    find first ub.goods no-lock
      where ub.goods.artic     = ub.price-list.artic
        and ub.goods.prod-type = ub.price-list.prod-type
        and ub.goods.prod-code = ub.price-list.prod-code
      no-error .
    if not available ub.goods then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "price-list"
        ,input price-list.obj-type
        ,input price-list.obj-code
        ,input price-list.artic
        ,input price-list.prod-type
        ,input price-list.prod-code
        ,input 'price-list-goods-not-exist '
          + ' doc-num = ' + string(price-list.doc-num)
        ).
      next .
    end.
    if ub.price-list.obj-type <> ub.price-doc.obj-type
    or ub.price-list.obj-code <> ub.price-doc.obj-code
    then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "price-list"
        ,input price-list.obj-type
        ,input price-list.obj-code
        ,input price-list.artic
        ,input price-list.prod-type
        ,input price-list.prod-code
        ,input 'price-list-object '
          + ' price-doc.obj-type ' + ' = ' + string(price-doc.obj-type)
          + ' price-doc.obj-code ' + ' = ' + string(price-doc.obj-code)
        ).
    end.
    if ub.price-list.fact-order <> ub.price-doc.fact-order then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "price-list"
        ,input price-list.obj-type
        ,input price-list.obj-code
        ,input price-list.artic
        ,input price-list.prod-type
        ,input price-list.prod-code
        ,input 'price-list-fact-num '
          + ' price-list.fact-num ' + ' = ' + string(price-list.fact-order)
          + ' price-doc.fact-num ' + ' = ' + string(price-doc.fact-order)
        ).
    end.
  end.
  run waitfram-hide in this-procedure .
  run log-test-finished in this-procedure
    (input v-test-name
    ,input icount
    ) .
END PROCEDURE.
PROCEDURE clear-temp-object :
  define buffer buf_temp-object for temp-object .
  for each buf_temp-object :
    delete buf_temp-object .
  end.
END PROCEDURE.
PROCEDURE create-temp-procedure :
  define input parameter p-label     as character no-undo .
  define input parameter p-proc-name as character no-undo .
  define input parameter p-group     as character no-undo .
  define input parameter p-descr     as character no-undo .
  define buffer buf_temp-procedure for temp-procedure .
  assign
    v-proc-order = v-proc-order + 1
  .
  create buf_temp-procedure .
  assign
    buf_temp-procedure.proc-order = v-proc-order
    buf_temp-procedure.proc-label = p-label
    buf_temp-procedure.proc-name  = p-proc-name
    buf_temp-procedure.proc-group = p-group
    buf_temp-procedure.proc-descr = p-descr
  .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY EDITOR-Log EDITOR-Help
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help b-mark b-check BROWSE-1 EDITOR-Log EDITOR-Help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-1 FOR EACH temp-procedure .
END PROCEDURE.
PROCEDURE fill-temp-procedure :
  run create-temp-procedure in this-procedure
    (input "Свободно <-> Факт"
    ,input "find-bad-goods-free-fact"
    ,input "1"
    ,input ""
    ) .
  run create-temp-procedure in this-procedure
    (input "Товар <-> Шкала"
    ,input "find-bad-goods-prt-obj"
    ,input "1"
    ,input ""
    ) .
  run create-temp-procedure in this-procedure
    (input "Товар <-> Партии"
    ,input "find-bad-goods-parts"
    ,input "1"
    ,input ""
    ) .
  run create-temp-procedure in this-procedure
    (input "Документы"
    ,input "chk-doc-line"
    ,input "1"
    ,input ""
    ) .
  run create-temp-procedure in this-procedure
    (input "Переоценка Строки"
    ,input "chk-price-list"
    ,input "1"
    ,input ""
    ) .
  run create-temp-procedure in this-procedure
    (input "Переоценка Заголовки"
    ,input "chk-price-doc"
    ,input "1"
    ,input ""
    ) .
  run create-temp-procedure in this-procedure
    (input "Товар - Подробно"
    ,input "chk-allcheck"
    ,input "2"
    ,input "Подробная проверка товара"
    ) .
  run create-temp-procedure in this-procedure
    (input "Объекты-Главная БД фирмы"
    ,input "chk-firm-db-num"
    ,input "2"
    ,input "Поиск объектов, у которых БД не равна БД фирмы"
    ) .
  run create-temp-procedure in this-procedure
    (input "Активные индексы"
    ,input "chk-idxinact"
    ,input "3"
    ,input "Поиск неактивных индексов в базе данных"
    ) .
END PROCEDURE.
PROCEDURE find-bad-goods-free-fact :
  define variable icount       as integer no-undo .
  define variable v-object-str as character no-undo .
  define variable v-artic-str  as character no-undo .
  define variable v-test-name as character no-undo .
  assign
    v-test-name = "Проверка свободного количества (find-bad-goods-free-fact)"
  .
  run log-test-started in this-procedure
    (input v-test-name
    ).
  run waitfram-show in this-procedure
    (input v-test-name
    ).
  for each ub.gds-obj no-lock
    where ub.gds-obj.free-qnty <> ub.gds-obj.fact-qnty
  :
    assign
      v-object-str = string(ub.gds-obj.obj-type)
                  + " " + string(ub.gds-obj.obj-code)
      v-artic-str  = string(ub.gds-obj.artic)
                  + " " + string(ub.gds-obj.prod-type)
                  + " " + string(ub.gds-obj.prod-code)
    .
    run waitfram-show in this-procedure
      (input "Объект " + string(v-object-str, 'x(10)':u)
        + " Артикул " + string(v-artic-str, 'x(25)':u)
        + " Найдено ошибок " + STRING(icount)
      ).
    find first ub.parts no-lock
      where ub.parts.obj-type  = ub.gds-obj.obj-type
        and ub.parts.obj-code  = ub.gds-obj.obj-code
        and ub.parts.artic     = ub.gds-obj.artic
        and ub.parts.prod-type = ub.gds-obj.prod-type
        and ub.parts.prod-code = ub.gds-obj.prod-code
        and ub.parts.out-code  <> 'free-zone':U
        and ub.parts.rsrv-free = yes
        and ub.parts.status_   = no
      no-error .
    if not available ub.parts then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "gds-obj"
        ,input ub.gds-obj.obj-type
        ,input ub.gds-obj.obj-code
        ,input ub.gds-obj.artic
        ,input ub.gds-obj.prod-type
        ,input ub.gds-obj.prod-code
        ,input 'free-fact gds-obj.free-qnty = ' + STRING(ub.gds-obj.free-qnty)
              + ' gds-obj.fact-qnty = ' + STRING(ub.gds-obj.fact-qnty)
        ).
    end.
  end.
  run waitfram-hide in this-procedure .
  run log-test-finished in this-procedure
    (input v-test-name
    ,input icount
    ) .
END PROCEDURE.
PROCEDURE find-bad-goods-parts :
define variable icount       as integer   no-undo .
define variable jcount       as integer   no-undo .
define variable v-object-str as character no-undo .
define variable v-artic-str  as character no-undo .
define variable v-test-name as character no-undo .
define variable v-gds-obj as decimal   no-undo .
  assign
    v-test-name = "Проверка партий свободной зоны (find-bad-goods-parts)"
  .
  run log-test-started in this-procedure
    (input v-test-name
    ).
  define variable v-parts-qnty as decimal no-undo .
  run waitfram-show in this-procedure
    (input v-test-name
    ).
  for each ub.gds-obj no-lock
  :
    assign
      v-object-str  = string(ub.gds-obj.obj-type)
                    + " " + string(ub.gds-obj.obj-code)
      v-artic-str   = string(ub.gds-obj.artic)
                    + " " + string(ub.gds-obj.prod-type)
                    + " " + string(ub.gds-obj.prod-code)
    .
    run waitfram-show in this-procedure
      (input "Объект " + string(v-object-str, 'x(10)':u)
        + " Артикул " + string(v-artic-str, 'x(25)':u)
        + " Найдено ошибок " + STRING(icount)
      ).
    assign
      v-parts-qnty = 0
    .
    for each ub.parts no-lock
      where ub.parts.obj-type  = ub.gds-obj.obj-type
        and ub.parts.obj-code  = ub.gds-obj.obj-code
        and ub.parts.artic     = ub.gds-obj.artic
        and ub.parts.prod-type = ub.gds-obj.prod-type
        and ub.parts.prod-code = ub.gds-obj.prod-code
        and ub.parts.status_   = no
        and ub.parts.rsrv-free = yes
    :
      if ub.parts.out-code = 'free-zone':U then do:
        assign
          v-parts-qnty = v-parts-qnty + ub.parts.qnty
        .
      end.
      else do:
        find first ub.trn-doc where ub.trn-doc.doc-code = ub.parts.out-code .
        if lookup(ub.trn-doc.ext-doc-type,"ee,ep,es,we,") > 0 then do:
            assign
              v-parts-qnty = v-parts-qnty  - ub.parts.qnty
            .
        end.
        else do:
            assign
              v-parts-qnty = v-parts-qnty + ub.parts.qnty
            .
        end.
      end.
    end.
    if v-parts-qnty <> ub.gds-obj.fact-qnty then do:
      assign
        icount = icount + 1
        v-gds-obj = ub.gds-obj.fact-qnty
      .
      run log-error
        (input "gds-obj"
        ,input ub.gds-obj.obj-type
        ,input ub.gds-obj.obj-code
        ,input ub.gds-obj.artic
        ,input ub.gds-obj.prod-type
        ,input ub.gds-obj.prod-code
        ,input 'parts free-parts-qnty = ' + STRING(v-parts-qnty)
              + ' gds-obj.fact-qnty =' + STRING(v-gds-obj)
        ).
    end.
  end.
  run waitfram-hide in this-procedure .
  run log-test-finished in this-procedure
    (input v-test-name
    ,input icount
    ) .
END PROCEDURE.
PROCEDURE find-bad-goods-prt-obj :
  define variable v-object-str as character no-undo .
  define variable v-artic-str  as character no-undo .
  define variable v-test-name as character no-undo .
  assign
    v-test-name = "Проверка количеств по шкалам (find-bad-goods-prt-obj)"
  .
  run log-test-started in this-procedure
    (input v-test-name
    ).
  define variable v-total-fact-qnty as decimal no-undo .
  define variable v-total-free-qnty as decimal no-undo .
  define variable icount as integer no-undo .
  run waitfram-show in this-procedure
    (input v-test-name
    ).
  for each gds-obj no-lock
  :
    assign
      v-object-str  = string(ub.gds-obj.obj-type)
                    + " " + string(ub.gds-obj.obj-code)
      v-artic-str   = string(ub.gds-obj.artic)
                    + " " + string(ub.gds-obj.prod-type)
                    + " " + string(ub.gds-obj.prod-code)
    .
    run waitfram-show in this-procedure
      (input "Объект " + string(v-object-str, 'x(10)':u)
        + " Артикул " + string(v-artic-str, 'x(25)':u)
        + " Найдено ошибок " + STRING(icount)
      ).
    assign
      v-total-fact-qnty = 0
      v-total-free-qnty  = 0
    .
    find first ub.goods no-lock
      where ub.goods.artic     = ub.gds-obj.artic
        and ub.goods.prod-type = ub.gds-obj.prod-type
        and ub.goods.prod-code = ub.gds-obj.prod-code
      no-error .
    if not available ub.goods then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "gds-obj"
        ,input ub.gds-obj.obj-type
        ,input ub.gds-obj.obj-code
        ,input ub.gds-obj.artic
        ,input ub.gds-obj.prod-type
        ,input ub.gds-obj.prod-code
        ,input 'goods not found'
        ).
      next .
    end.
    find first ub.gds-prt no-lock
      where ub.gds-prt.upper-code = ub.goods.prt-root
      no-error .
    if not available ub.gds-prt then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "gds-obj"
        ,input ub.gds-obj.obj-type
        ,input ub.gds-obj.obj-code
        ,input ub.gds-obj.artic
        ,input ub.gds-obj.prod-type
        ,input ub.gds-obj.prod-code
        ,input 'root_node_not_found goods.prt-root=' + string(ub.goods.prt-root)
        ).
      next .
    end.
    for each ub.prt-obj no-lock
      where ub.prt-obj.obj-type  = ub.gds-obj.obj-type
        and ub.prt-obj.obj-code  = ub.gds-obj.obj-code
        and ub.prt-obj.artic     = ub.gds-obj.artic
        and ub.prt-obj.prod-type = ub.gds-obj.prod-type
        and ub.prt-obj.prod-code = ub.gds-obj.prod-code
        and ub.prt-obj.prt-code  = ub.gds-prt.node-code
    :
      assign
        v-total-fact-qnty = v-total-fact-qnty  + ub.prt-obj.fact-qnty
        v-total-free-qnty = v-total-free-qnty  + ub.prt-obj.free-qnty
      .
    end.
    if v-total-fact-qnty <> ub.gds-obj.fact-qnty
    or v-total-free-qnty <> ub.gds-obj.free-qnty
    then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "gds-obj"
        ,input ub.gds-obj.obj-type
        ,input ub.gds-obj.obj-code
        ,input ub.gds-obj.artic
        ,input ub.gds-obj.prod-type
        ,input ub.gds-obj.prod-code
        ,input 'goods-gds-prt gds-obj.free-qnty = ' + STRING(ub.gds-obj.free-qnty)
          + ' gds-obj.fact-qnty = '            + STRING(ub.gds-obj.fact-qnty)
          + ' total prt-obj.free-qnty = '      + STRING(v-total-free-qnty)
          + ' total prt-obj.fact-qnty = '      + STRING(v-total-fact-qnty)
        ).
    end.
  end.
  run waitfram-hide in this-procedure .
  run log-test-finished in this-procedure
    (input v-test-name
    ,input icount
    ) .
END PROCEDURE.
PROCEDURE log-error :
  define input parameter p-table-name as character no-undo .
  define input parameter v-obj-type   like ub.gds-obj.obj-type  no-undo .
  define input parameter v-obj-code   like ub.gds-obj.obj-code  no-undo .
  define input parameter v-artic      like ub.gds-obj.artic     no-undo .
  define input parameter v-prod-type  like ub.gds-obj.prod-type no-undo .
  define input parameter v-prod-code  like ub.gds-obj.prod-code no-undo .
  define input parameter v-error-msg  as character no-undo .
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  output to chkmanag.err append .
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  export
    string(v-today, '99/99/9999':u) string(v-time, 'HH:MM':u)
    p-table-name
    v-obj-type v-obj-code v-artic v-prod-type v-prod-code
    v-error-msg .
  output close .
END PROCEDURE.
PROCEDURE log-information :
  define input parameter p-message as character no-undo .
  define variable lok as logical   no-undo .
  do with frame Dialog-Frame:
    assign
      lok = EDITOR-Log :move-to-eof()
      lok = EDITOR-Log :insert-string(p-message + chr(10) )
    .
  end.
END PROCEDURE.
PROCEDURE log-test-finished :
  define input parameter p-test-name as character no-undo .
  define input parameter p-err-count as integer   no-undo .
  define variable v-message-text as character no-undo .
  assign
    v-message-text = (if p-err-count > 0 then "**" else "  ")
          + " " + cur-time-string()
          + " " + "ошибок" + " " + string(p-err-count)
          + " " + p-test-name
  .
  output to chkmanag.log append .
  export v-message-text .
  output close .
  run log-information
    (input v-message-text
    ) .
END PROCEDURE.
PROCEDURE log-test-started :
  define input parameter p-test-name as character no-undo .
END PROCEDURE.
PROCEDURE make-check :
  define input parameter p-temp-procedure-recid as recid no-undo .
  define buffer buf_temp-procedure for temp-procedure .
  find first buf_temp-procedure
    where recid(buf_temp-procedure) = p-temp-procedure-recid
    .
  run value(buf_temp-procedure.proc-name) in this-procedure .
END PROCEDURE.
PROCEDURE output-temp-object :
  define buffer buf_temp-object for temp-object .
  output to chkmanag.obj .
  for each buf_temp-object :
    display buf_temp-object .
  end.
  output close .
END PROCEDURE.
PROCEDURE register-document :
  define input parameter p-obj-type   like ub.trn-doc.obj-type   no-undo .
  define input parameter p-obj-code   like ub.trn-doc.obj-code   no-undo .
  define input parameter p-status_    like ub.trn-doc.status_    no-undo .
  define input parameter p-fact-order like ub.trn-doc.fact-order no-undo .
  define buffer buf_temp-object for temp-object .
  if p-status_ = 'факт':U then do:
    find first buf_temp-object
      where buf_temp-object.obj-type = p-obj-type
        and buf_temp-object.obj-code = p-obj-code
      no-error .
    if not available buf_temp-object then do:
      create buf_temp-object .
      assign
        buf_temp-object.obj-type = p-obj-type
        buf_temp-object.obj-code = p-obj-code
      .
    end.
    if buf_temp-object.fact-order = ?
    or buf_temp-object.fact-order < p-fact-order then do:
      assign
        buf_temp-object.fact-order = p-fact-order
      .
    end.
  end.
END PROCEDURE.
PROCEDURE show-help :
  do with frame Dialog-Frame:
    assign
      editor-help :screen-value = "Рекомендуемый порядок проверки базы данных: " + chr(10)
        + "Сначала последовательно выполните тесты Группы А. "
        + "После выполнения каждого теста требуется проверить файлы ошибок chkmanag.err и chkmanag.log. "
        + "В случае обнаружения ошибок необходимо обратиться в службу поддержки пользователей. "
        + chr(10)
        + chr(10)
        + "Если в результате выполнения тестов Группы А не были найдены ошибки, то выполните тесты Группы Б."
        + "В случае обнаружения ошибок необходимо обратиться в службу поддержки пользователей. "
        + chr(10)
    .
  end.
END PROCEDURE.
FUNCTION get-mark RETURNS CHARACTER
  ( input v-recid  as recid ) :
  if lookup(string(v-recid), del-list ) > 0 then do:
    return "*".
  end.
  return "".
END FUNCTION.
