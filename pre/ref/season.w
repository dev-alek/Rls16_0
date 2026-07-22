using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter bttns  as character   no-undo .
define output parameter rid-list    as  character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник сезонов".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
PROCEDURE chk-gdssea :
define input  parameter p-gds-code as integer no-undo.
define input  parameter p-seaobj as character no-undo.
define input  parameter p-i-date1 as integer no-undo.
define input  parameter p-i-date2 as integer no-undo.
define input  parameter p-rowid as rowid no-undo.
define output parameter p-sea-code as integer no-undo.
define output parameter p-db-num as integer no-undo.
define output parameter p-ok as logical no-undo init yes.
define buffer buf_season for ub.season.
define buffer buf1_season for ub.season.
define buffer buf1_gds-season for ub.gds-season.
define buffer buf_season-attr for ub.season-attr.
define buffer buf1_season-attr for ub.season-attr.
  for each buf1_season no-lock where ((buf1_season.sea-month-1 <= p-i-date1 and buf1_season.sea-month-2 >= p-i-date1)
    or (buf1_season.sea-month-1 <= p-i-date2 and buf1_season.sea-month-2 >= p-i-date2)
    or (buf1_season.sea-month-1 <= p-i-date1 and buf1_season.sea-month-2 >= p-i-date1))
    and (rowid (buf1_season) <> p-rowid or p-rowid = ?):
      if can-find (first buf1_season-attr where buf1_season-attr.sea-code = buf1_season.sea-code
                                            and buf1_season-attr.db-num = buf1_season.db-num
                                            and buf1_season-attr.attr-code = 'sea-obj':U
                                            and buf1_season-attr.attr-value = p-seaobj
                                            )
        or
        (not can-find (first buf1_season-attr where buf1_season-attr.sea-code = buf1_season.sea-code
                                              and buf1_season-attr.db-num = buf1_season.db-num
                                              and buf1_season-attr.attr-code = 'sea-obj':U
                                              )
        and p-seaobj = "")
      then do:
        if can-find (first buf1_gds-season where  buf1_gds-season.sea-code = buf1_season.sea-code
                                              and buf1_gds-season.db-num = buf1_gds-season.db-num
                                              and buf1_gds-season.gds-code = p-gds-code)
        then do:
        assign
          p-ok = false
          p-sea-code = buf1_season.sea-code
          p-db-num = buf1_season.db-num.
          leave.
        end.
      end.
  end.
END PROCEDURE.
define variable v-sel-obj-type like ub.clients.obj-type no-undo .
define variable v-sel-obj-code like ub.clients.obj-code no-undo .
define variable v-sel-obj-list as character no-undo .
define variable v-sel-ok as character no-undo .
define variable g#report-num as integer   no-undo .
define shared variable g#db-num as integer   no-undo .
run get-report-num  in parParentProc ( output g#report-num ).
define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable v-log as logical   no-undo .
define variable v-user-select as logical no-undo .
define variable v-cur-time as character no-undo.
define temp-table tt-season no-undo
    field sea-code as integer format "->>>,>>>,>>9"
    field db-num as integer  format ">>>>9"
    field is-glob-sea as logical
    field attr-value as character format "X(30)"
index pi as primary unique sea-code db-num
.
def stream ListStream .
define variable sort-column-name as character no-undo .
define buffer buf_gds-season for ub.gds-season.
define buffer buf_gds-season-attr for ub.gds-season-attr.
define buffer buf1_gds-season for ub.gds-season.
define buffer buf1_gds-season-attr for ub.gds-season-attr.
define buffer buf_season for ub.season.
define buffer buf_season-attr for ub.season-attr.
define buffer buf_goods for ub.goods.
define temp-table tt-line no-undo
    field sea-code as integer format "->>>,>>>,>>9"
    field db-num as integer  format ">>>>9"
    field sea-name as character
    field sea-month-1 as integer  format ">9"
    field sea-month-2 as integer  format ">9"
    field attr-value as character
    index pi as primary unique sea-code db-num
.
FUNCTION date-func RETURNS DATE
( input date-int as int)  FORWARD.
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 9 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 12 BY 1.
DEFINE BUTTON b-goods
     LABEL "Товары":L
     SIZE 10 BY 1.
DEFINE BUTTON b-copy
     LABEL "Копировать":L
     SIZE 12 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.
DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 10 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-upd
     LABEL "&Изменить":L
     SIZE 10 BY 1.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Глобальные", 1,
          "Локальные", 2
     SIZE 15 BY 2 NO-UNDO.
DEFINE VARIABLE RADIO-SET-2 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
          "Текущий", 2,
          "Выборочно", 3
     SIZE 12 BY 2 NO-UNDO.
DEFINE QUERY br-season FOR
      ub.season,
      tt-season SCROLLING.
DEFINE BROWSE br-season
  QUERY br-season NO-LOCK DISPLAY
      (IF ( CAN-DO (rid-list, string( recid( ub.season ) ) ) ) THEN ("*") ELSE (" ")) COLUMN-LABEL "*" FORMAT "X(1)":U
      ub.season.sea-code COLUMN-LABEL "Код" FORMAT ">>>>>>>>>9":U
      date-func(ub.season.sea-month-1) COLUMN-LABEL "с" FORMAT "99/99/99":U
      date-func(ub.season.sea-month-2) COLUMN-LABEL "по" FORMAT "99/99/99":U
      ub.season.sea-name FORMAT "X(100)":U
      ub.season.db-num COLUMN-LABEL "БД" FORMAT ">>>>9":U
    WITH SEPARATORS SIZE 56 BY 18.46
         BGCOLOR 15 FGCOLOR 0 .
DEFINE FRAME d-type-tmp
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 13
     b-goods AT ROW 1 COL 23
     b-copy AT ROW 1 COL 33
     b-hist AT ROW 1 COL 33
     b-help AT ROW 1 COL 43
     B-mark AT ROW 2 COL 1
     b-add AT ROW 2 COL 4
     b-upd AT ROW 2 COL 13
     b-del AT ROW 2 COL 23
     RADIO-SET-1 AT ROW 3 COL 15 NO-LABEL
     RADIO-SET-2 AT ROW 3 COL 30 NO-LABEL
     "Сезоны" VIEW-AS TEXT
     SIZE 8 BY .62 AT ROW 3.5 COL 5 WIDGET-ID 8
     mark-num AT ROW 2 COL 34 NO-LABEL
     b-print AT ROW 2 COL 43
     br-season AT ROW 5.25 COL 1.5
     SPACE(0.37) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Сезоны":L.
ASSIGN
       FRAME d-type-tmp:SCROLLABLE       = FALSE.
ASSIGN
       br-season:NUM-LOCKED-COLUMNS IN FRAME d-type-tmp     = 3.
ON CHOOSE OF b-add IN FRAME d-type-tmp
DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_season_add-def':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return no-apply .
 run ref/seasoni.w ( parParentProc , 'ДОБАВЛЕНИЕ':U, input-output rr ).
 if rr <> ? then
    do:
        run open-br.
        reposition br-season to recid rr no-error.
        log-res  = br-season:select-focused-row( ) no-error.
        apply "ENTRY":U to br-season.
        apply "home"    to br-season.
    end.
END.
ON CHOOSE OF b-del IN FRAME d-type-tmp
DO:
define variable g-log as logical   no-undo .
define variable v-recid as integer no-undo .
define variable ii as integer no-undo .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_season_deletion':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
if not available ub.season or v-log = false then  return no-apply.
if not g#db-num = 0 and not can-find (buf_season-attr where buf_season-attr.sea-code = ub.season.sea-code
                                            and buf_season-attr.db-num = ub.season.db-num
                                            and buf_season-attr.attr-code = 'sea-obj':U)
then do:
  message "Нельзя удалить глобальный сезон в УБД."
          view-as alert-box information.
  return no-apply.
end.
message "Удалить запись ? При этом удаляется привязка товаров к сезону."
          view-as alert-box question
          buttons yes-no
          update g-log.
          if g-log = false then return no-apply.
find current ub.season exclusive-lock no-error .
if available ub.season then delete ub.season.
run open-br.
END.
ON CHOOSE OF b-goods IN FRAME d-type-tmp
DO:
  if not available ub.season then return no-apply.
  run ref/seagdsl.w
    ( input Parparentproc,
      input ub.season.sea-code,
      input ub.season.db-num,
      input ub.season.sea-name
      ).
END.
ON CHOOSE OF b-copy IN FRAME d-type-tmp
DO:
  define variable v-user-select as logical   no-undo .
  define variable v-ok as logical no-undo.
  define variable v-seaobj as character no-undo.
  define variable v-sea-code as integer no-undo.
  define variable v-db-num as integer no-undo.
  define variable v-longchar as longchar no-undo .
  if not available ub.season then return no-apply.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parParentProc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
  if v-user-select then do:
    _foreach-userobj:
    for each userobjs_temp-user-obj no-lock:
      for each buf_gds-season no-lock where buf_gds-season.sea-code = ub.season.sea-code
        and buf_gds-season.db-num = ub.season.db-num:
        run chk-gdssea in this-procedure
          ( input buf_gds-season.gds-code,
            input userobjs_temp-user-obj.obj-type + string (userobjs_temp-user-obj.obj-code),
            input ub.season.sea-month-1,
            input ub.season.sea-month-2,
            input ?,
            output v-sea-code,
            output v-db-num,
            output v-ok) no-error.
        if not v-ok then do:
          find first buf_goods no-lock where buf_goods.gds-code = buf_gds-season.gds-code no-error.
          find first buf_season no-lock where buf_season.sea-code = v-sea-code
            and buf_season.db-num = v-db-num
          no-error.
          assign
            v-longchar = v-longchar +
              substitute ("Товар &1 &2 пересекается с сезоном &3 &4.&5", buf_goods.gds-code, buf_goods.gds-name, v-sea-code, buf_season.sea-name, chr(10))
            v-ok = true
            .
        end.
      end.
      if v-longchar <> "" then do:
        assign
          v-longchar = v-longchar +
            substitute ("Сезон &1 &2 не скопирован для объекта &3.&4",
                        ub.season.sea-code,
                        buf_season.sea-name,
                        userobjs_temp-user-obj.obj-type + string (userobjs_temp-user-obj.obj-code),
                        chr(10)
                        ).
        next _foreach-userobj.
      end.
      do transaction:
        create buf_season.
        assign
          buf_season.sea-code = next-value ( s-casm , ub )
          buf_season.db-num = v-cntxt-db-num
          .
        buffer-copy ub.season except ub.season.sea-code ub.season.db-num ub.season.sea-name to buf_season.
        buf_season.sea-name = ub.season.sea-name + " " + userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code).
        create buf_season-attr.
        assign
          buf_season-attr.sea-code = buf_season.sea-code
          buf_season-attr.db-num = buf_season.db-num
          buf_season-attr.attr-code = 'sea-obj':U
          buf_season-attr.attr-value = userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code)
          .
        for each buf_gds-season where buf_gds-season.sea-code = ub.season.sea-code
          and buf_gds-season.db-num = ub.season.db-num:
          create buf1_gds-season.
          assign
            buf1_gds-season.sea-code = buf_season.sea-code
            buf1_gds-season.db-num = buf_season.db-num
            .
          buffer-copy buf_gds-season except buf_gds-season.sea-code buf_gds-season.db-num to buf1_gds-season.
          for each buf_gds-season-attr where buf_gds-season-attr.sea-code = ub.season.sea-code
            and buf_gds-season-attr.db-num = ub.season.db-num
            and buf_gds-season-attr.gds-code = buf1_gds-season.gds-code:
            create buf1_gds-season-attr.
            assign
              buf1_gds-season-attr.sea-code = buf_season.sea-code
              buf1_gds-season-attr.db-num = buf_season.db-num
              .
            buffer-copy buf_gds-season-attr except buf_gds-season-attr.sea-code buf_gds-season-attr.db-num to buf1_gds-season-attr.
          end.
        end.
      end.
    end.
  end.
  if v-longchar <> "" then do:
    run gbl/d-longchar.w (
            ?,
            'Editor_row=2\':u
          + 'title=Проверка товарного наполнения сезона: при копировании сезона возникли пересечения\':u
          + 'Editor_col=1\':u
          + 'Editor_width=96\':u
          + 'Editor_height=21\':u
          + 'readonly=yes\':u
        ,input-output v-longchar
        ,output v-ok ) no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "4"
          view-as alert-box error
        .
    assign
      v-longchar = "".
  end.
run open-br.
END.
ON CHOOSE OF b-hist IN FRAME d-type-tmp
DO:
  find current ub.season no-lock no-error .
  if available ub.season THEN
      run ref/seasonh.w
      ( input parParentProc ,
        input ub.season.sea-code,
        input ub.season.db-num
        ).
END.
ON CHOOSE OF B-mark IN FRAME d-type-tmp
DO:
  if not available ub.season then return.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid10 as character no-undo .
define variable v-num-entry10 as integer   no-undo .
assign
  v-str-recid10 = trim( string( recid( ub.season ) , "->>>>>>>>>>>9":U ) )
  v-num-entry10 = lookup( v-str-recid10 , rid-list )
.
if v-num-entry10 > 0 then do:
  assign
    entry( v-num-entry10, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid10
  .
end.
    v-log = br-season :refresh( )  in frame d-type-tmp.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
      v-log = br-season:select-next-row () in frame d-type-tmp.
      apply "iteration-changed" to br-season in frame d-type-tmp.
  end.
  if num-entries (rid-list) = 0 then
     hide mark-num in frame d-type-tmp.
  else
    disp num-entries (rid-list) @ mark-num
    with frame d-type-tmp.
  apply "entry" to br-season in frame d-type-tmp.
END.
ON CHOOSE OF b-print IN FRAME d-type-tmp
DO:
   for each tt-line no-lock :
   delete tt-line.
   end.
   v-cur-time = cur-time-print ().
   define variable v-file-name as character no-undo.
   if RADIO-SET-1:screen-value = "1" then do:
      FOR EACH ub.season ,EACH tt-season
      WHERE season.sea-month-1 <> 0
             AND season.sea-month-2 <> 0
             AND tt-season.sea-code = season.sea-code
             AND tt-season.db-num = season.db-num
             AND tt-season.is-glob-sea = true:
     create tt-line.
     tt-line.sea-code = tt-season.sea-code.
     tt-line.db-num = tt-season.db-num.
     tt-line.sea-name = season.sea-name.
     tt-line.sea-month-1 = season.sea-month-1.
     tt-line.sea-month-2 = season.sea-month-2.
     tt-line.attr-value = "глоб".
     end.
   end.
   if RADIO-SET-1:screen-value in frame d-type-tmp = "2"
  AND RADIO-SET-2:screen-value in frame d-type-tmp = "1"  then do:
     FOR EACH ub.season ,EACH tt-season
      WHERE season.sea-month-1 <> 0
             AND season.sea-month-2 <> 0
             AND tt-season.sea-code = season.sea-code
             AND tt-season.db-num = season.db-num
             AND tt-season.is-glob-sea = false:
     create tt-line.
     tt-line.sea-code = tt-season.sea-code.
     tt-line.db-num = tt-season.db-num.
     tt-line.sea-name = season.sea-name.
     tt-line.sea-month-1 = season.sea-month-1.
     tt-line.sea-month-2 = season.sea-month-2.
     tt-line.attr-value  = tt-season.attr-value.
     end.
    end.
   if RADIO-SET-1:screen-value in frame d-type-tmp = "2"
  AND RADIO-SET-2:screen-value in frame d-type-tmp = "2"  then do:
     FOR EACH ub.season ,EACH tt-season
      WHERE season.sea-month-1 <> 0
             AND season.sea-month-2 <> 0
             AND tt-season.sea-code = season.sea-code
             AND tt-season.db-num = season.db-num
             AND tt-season.is-glob-sea = false
             AND tt-season.attr-value = v-cntxt-obj-type + string( v-cntxt-obj-code ):
     create tt-line.
     tt-line.sea-code = tt-season.sea-code.
     tt-line.db-num = tt-season.db-num.
     tt-line.sea-name = season.sea-name.
     tt-line.sea-month-1 = season.sea-month-1.
     tt-line.sea-month-2 = season.sea-month-2.
     tt-line.attr-value  = tt-season.attr-value.
     end.
   end.
   if RADIO-SET-1:screen-value in frame d-type-tmp = "2"
  AND RADIO-SET-2:screen-value in frame d-type-tmp = "3"  then do:
     FOR EACH ub.season ,EACH tt-season
      WHERE season.sea-month-1 <> 0
             AND season.sea-month-2 <> 0
             AND tt-season.sea-code = season.sea-code
             AND tt-season.db-num = season.db-num
             AND tt-season.is-glob-sea = false
             AND lookup(tt-season.attr-value, v-sel-obj-list) > 0:
     create tt-line.
     tt-line.sea-code = tt-season.sea-code.
     tt-line.db-num = tt-season.db-num.
     tt-line.sea-name = season.sea-name.
     tt-line.sea-month-1 = season.sea-month-1.
     tt-line.sea-month-2 = season.sea-month-2.
     tt-line.attr-value  = tt-season.attr-value.
     end.
    end.
   run create-rep(output v-file-name).
   if v-file-name = ? then
        MESSAGE "Не удалось создать html-файл"
        VIEW-AS ALERT-BOX.
    else
        run open-ie(v-file-name).
END.
ON CHOOSE OF b-sel IN FRAME d-type-tmp
DO:
    if ( available ub.season ) AND ( rid-list = "" ) then
        rid-list = string( recid( ub.season ) ) .
END.
ON CHOOSE OF b-upd IN FRAME d-type-tmp
DO:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_season_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
    if not available ub.season or v-log = false then  return no-apply.
        rr = recid( ub.season ).
        run ref/seasoni.w
            (parParentProc , 'ИЗМЕНЕНИЕ':U, input-output rr ).
        run open-br.
        reposition br-season to recid rr .
 END.
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME d-type-tmp
DO:
RADIO-SET-2:screen-value in frame d-type-tmp = "1".
if RADIO-SET-1:screen-value = "1" then do:  DISABLE RADIO-SET-2 WITH FRAME  d-type-tmp.
                                            run open-br.
                                       end.
if RADIO-SET-1:screen-value = "2" then do: ENABLE RADIO-SET-2 WITH FRAME  d-type-tmp.
                                           run open-br.
                                       end.
END.
ON VALUE-CHANGED OF RADIO-SET-2 IN FRAME d-type-tmp
DO:
if RADIO-SET-2:screen-value = "1" then run open-br.
if RADIO-SET-2:screen-value = "2" then run open-br.
    if RADIO-SET-2:screen-value = "3"  then run open-br-when-b-obj.
END.
ON DEFAULT-ACTION OF br-season IN FRAME d-type-tmp
DO:
  case yes:
      when  b-upd:sensitive THEN apply "CHOOSE":U to b-upd.
  end case.
END.
ON MOUSE-SELECT-DBLCLICK OF br-season IN FRAME d-type-tmp
DO:
    if lookup ( "b-sel", bttns ) > 0  then
        do:
            apply "choose" to b-sel in frame d-type-tmp .
            return no-apply .
        end.
END.
ON RETURN OF br-season IN FRAME d-type-tmp
DO:
    if Lookup( "b-sel",  bttns ) > 0 then
        do:
            apply "choose" to b-sel in frame d-type-tmp .
            return no-apply .
        end.
    else
        apply "DEFAULT-ACTION":U to self.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-type-tmp:PARENT eq ?
THEN FRAME d-type-tmp:PARENT = ACTIVE-WINDOW.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-type-tmp
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
on choose of b-help in frame d-type-tmp
do:
  apply "help":u to frame d-type-tmp .
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-type-tmp:width - 0.3
                fh            = frame d-type-tmp:first-child
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-type-tmp :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-type-tmp :height-chars)
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
    if frame d-type-tmp :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-type-tmp :height-chars)
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
            frame d-type-tmp :height = v-frame-height
          .
          if frame d-type-tmp :scrollable = true
          then do:
            assign
              frame d-type-tmp :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-type-tmp :scrollable = true
          then do:
            assign
              frame d-type-tmp :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-type-tmp :height = v-frame-height
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
      v-frame-height = frame d-type-tmp :height
      v-frame-virtual-height = frame d-type-tmp :virtual-height
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
      v-field-group-handle = frame d-type-tmp :first-child
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
    do with frame d-type-tmp
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-type-tmp :scrollable = true
      then do:
        assign
          frame d-type-tmp :virtual-height = frame d-type-tmp :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-type-tmp :height = frame d-type-tmp :height + p-change-value
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
        frame d-type-tmp :height = frame d-type-tmp :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-type-tmp :scrollable = true
      then do:
        assign
          frame d-type-tmp :virtual-height = frame d-type-tmp :virtual-height + p-change-value
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
          ,input  string(frame d-type-tmp :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-type-tmp :height)
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
    if frame d-type-tmp :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-type-tmp :width
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
    if frame d-type-tmp :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-type-tmp :width
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
            frame d-type-tmp :width = v-frame-width
          .
          if frame d-type-tmp :scrollable = true
          then do:
            assign
              frame d-type-tmp :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-type-tmp :scrollable = true
          then do:
            assign
              frame d-type-tmp :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-type-tmp :width = v-frame-width
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
      v-frame-width = frame d-type-tmp :width
      v-frame-virtual-width = frame d-type-tmp :virtual-width
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
      v-field-group-handle = frame d-type-tmp :first-child
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
    do with frame d-type-tmp
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-type-tmp :scrollable = true
      then do:
        assign
          frame d-type-tmp :virtual-width = frame d-type-tmp :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-type-tmp :width = v-frame-width + p-change-value
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
        frame d-type-tmp :width = frame d-type-tmp :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-type-tmp :scrollable = true
      then do:
        assign
          frame d-type-tmp :virtual-width = frame d-type-tmp :virtual-width + p-change-value
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
          ,input  string(frame d-type-tmp :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-type-tmp :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-type-tmp
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-type-tmp :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-type-tmp :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-type-tmp :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-type-tmp :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-type-tmp
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
      v-row-delta = v-new-row - frame d-type-tmp :height
      v-col-delta = v-new-col - frame d-type-tmp :width
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
            - frame d-type-tmp :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-type-tmp :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-type-tmp :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-type-tmp :height-chars
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
      v-diasize-current-frame-width  = frame d-type-tmp :width
      v-diasize-current-frame-height = frame d-type-tmp :height
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
    do with frame d-type-tmp
    :
      assign
        v-diasize-orig-frame-height = frame d-type-tmp :height
        v-diasize-orig-frame-width  = frame d-type-tmp :width
        v-diasize-browse-handle     = browse br-season :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-type-tmp :first-child
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
ON WINDOW-CLOSE OF FRAME d-type-tmp APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run enable_ui.
    APPLY "VALUE-CHANGED":U TO br-season in frame d-type-tmp.
    ub.season.sea-name:RESIZABLE in  browse br-season   = true .
    if num-entries (rid-list) = 0 then
        hide mark-num in frame d-type-tmp.
    else
        disp
        num-entries (rid-list) @ mark-num
        with frame d-type-tmp.
    run open-br.
    WAIT-FOR GO OF FRAME d-type-tmp.
END.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME d-type-tmp.
END PROCEDURE.
PROCEDURE enable_UI :
    RADIO-SET-1:screen-value in frame d-type-tmp = "1".
    RADIO-SET-2:screen-value in frame d-type-tmp = "1".
    ENABLE
        br-season
        b-exit
        b-copy
        b-add WHEN  (lookup  ( "b-add" , bttns) > 0 )
        b-sel WHEN  (lookup  ( "b-sel" , bttns) > 0 )
        b-mark when (lookup  ( "b-mark", bttns) > 0 )
        b-upd WHEN  (lookup  ( "b-add" , bttns) > 0 )
        b-del WHEN  (lookup  ( "b-add" , bttns) > 0 )
        b-print
        b-hist
        b-help
        b-goods
        RADIO-SET-1
        WITH FRAME  d-type-tmp.
    if available ub.season then
        log-res  = br-season:select-focused-row( ) in frame d-type-tmp.
    run open-br.
END PROCEDURE.
PROCEDURE open-br-when-b-obj :
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-sel-ok
  )  .
  if v-sel-ok = 'yes' then do:
    v-sel-obj-list = "".
    for each userobjs_temp-user-obj  :
      v-sel-obj-list = v-sel-obj-list + "," + userobjs_temp-user-obj.obj-type + string(userobjs_temp-user-obj.obj-code).
    end.
    v-sel-obj-list = trim (v-sel-obj-list, ",").
    OPEN QUERY br-season FOR EACH ub.season ,      EACH tt-season       WHERE season.sea-month-1 <> 0              AND season.sea-month-2 <> 0              AND tt-season.sea-code = season.sea-code              AND tt-season.db-num = season.db-num              AND tt-season.is-glob-sea = false              AND lookup(tt-season.attr-value, v-sel-obj-list) > 0              NO-LOCK.
    apply "entry" to br-season in frame d-type-tmp.
  end.
END PROCEDURE.
PROCEDURE open-br :
for each tt-season no-lock :
  delete tt-season.
end.
FOR EACH ub.season
WHERE season.sea-month-1 <> 0
AND season.sea-month-2 <>  0 :
  create tt-season.
  tt-season.sea-code = season.sea-code.
  tt-season.db-num = season.db-num.
  tt-season.is-glob-sea = not can-find ( buf_season-attr where buf_season-attr.sea-code = ub.season.sea-code
                       and buf_season-attr.db-num = ub.season.db-num
                       and buf_season-attr.attr-code = 'sea-obj':U ).
  find first ub.season-attr no-lock where season-attr.sea-code = season.sea-code
                                    and season-attr.db-num = season.db-num no-error.
  if available  season-attr then tt-season.attr-value = season-attr.attr-value.
END.
if RADIO-SET-1:screen-value in frame d-type-tmp = "1" then OPEN QUERY br-season FOR EACH ub.season ,      EACH tt-season       WHERE season.sea-month-1 <> 0              AND season.sea-month-2 <> 0              AND tt-season.sea-code = season.sea-code              AND tt-season.db-num = season.db-num              AND tt-season.is-glob-sea = true              NO-LOCK.
if RADIO-SET-1:screen-value in frame d-type-tmp = "2"
  AND RADIO-SET-2:screen-value in frame d-type-tmp = "1"  then
  OPEN QUERY br-season FOR EACH ub.season ,      EACH tt-season       WHERE season.sea-month-1 <> 0              AND season.sea-month-2 <> 0              AND tt-season.sea-code = season.sea-code              AND tt-season.db-num = season.db-num              AND tt-season.is-glob-sea = false              NO-LOCK.
if RADIO-SET-1:screen-value in frame d-type-tmp = "2"
  AND RADIO-SET-2:screen-value in frame d-type-tmp = "2"  then
  OPEN QUERY br-season FOR EACH ub.season ,      EACH tt-season       WHERE season.sea-month-1 <> 0              AND season.sea-month-2 <> 0              AND tt-season.sea-code = season.sea-code              AND tt-season.db-num = season.db-num              AND tt-season.is-glob-sea = false              AND tt-season.attr-value = v-cntxt-obj-type + string( v-cntxt-obj-code )              NO-LOCK.
 if RADIO-SET-1:screen-value in frame d-type-tmp = "2"
  AND RADIO-SET-2:screen-value in frame d-type-tmp = "3"  then
  OPEN QUERY br-season FOR EACH ub.season ,      EACH tt-season       WHERE season.sea-month-1 <> 0              AND season.sea-month-2 <> 0              AND tt-season.sea-code = season.sea-code              AND tt-season.db-num = season.db-num              AND tt-season.is-glob-sea = false              AND lookup(tt-season.attr-value, v-sel-obj-list) > 0              NO-LOCK.
apply "entry" to br-season in frame d-type-tmp.
END PROCEDURE.
FUNCTION date-func RETURNS DATE
( input date-int as int) :
 define variable date-res as date no-undo.
   if  date-int <= 12 then return error.
   assign date-res = date (date-int) no-error.
 RETURN date-res.
END FUNCTION.
procedure create-rep:
    define output parameter p-filename as character no-undo.
    define variable v-rls-file as character no-undo.
    define variable v-data-file as character no-undo.
    define variable v-xsl-file as character no-undo.
    define variable v-tmp-file as character no-undo.
    define variable hw as handle no-undo.
    define variable rep-out as class Rep-Out no-undo.
    assign
        v-xsl-file = search("exe/season.xsl.html")
        v-data-file = session:temp-directory + string(time) + ".xml"
        v-tmp-file = session:temp-directory + string(time) + ".html"
    .
    create sax-writer hw.
    hw:formatted = true.
    hw:set-output-destination ("file", v-data-file).
    run write-data(hw) .
    rep-out = new rep-out().
    v-rls-file = rep-out:xsl-transform(v-data-file, v-xsl-file).
    os-delete value(v-tmp-file).
    os-copy value(v-rls-file) value(v-tmp-file).
    os-delete value(v-rls-file).
    delete object rep-out.
    p-filename = v-tmp-file.
end.
procedure write-data:
    define input parameter hw as handle no-undo.
        hw:start-document ().
        hw:start-element ("rep").
        hw:start-element ("card").
        hw:insert-attribute ("time", if v-cur-time = ? then "" else v-cur-time ).
        for each tt-line no-lock:
        hw:start-element ("line").
        hw:insert-attribute ("sea-code",if tt-line.sea-code = ? then "" else string(tt-line.sea-code)).
        hw:insert-attribute ("db-num",if tt-line.db-num = ? then "" else string(tt-line.db-num)).
        hw:insert-attribute ("sea-name",if tt-line.sea-name = ? then "" else string(tt-line.sea-name)).
        hw:insert-attribute ("sea-month-1",if tt-line.sea-month-1 = ? then "" else string(date(tt-line.sea-month-1), "99/99/99")).
        hw:insert-attribute ("sea-month-2",if tt-line.sea-month-2 = ? then "" else string(date(tt-line.sea-month-2),"99/99/99")).
        hw:insert-attribute ("attr-value",if tt-line.attr-value = ? then "" else string(tt-line.attr-value)).
        hw:end-element ("line").
        end.
        hw:end-element ("card").
        hw:end-element ("rep").
        hw:end-document ().
end.
procedure open-ie:
    define input parameter p-filename as character no-undo.
    define variable o-IE as com-handle no-undo.
    create "InternetExplorer.Application" o-IE.
    o-IE:addressbar = false.
    o-IE:Navigate(p-filename).
    o-IE:visible = true.
    release object o-IE.
end.
