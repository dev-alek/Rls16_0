DEFINE NEW SHARED TEMP-TABLE tt-db NO-UNDO LIKE ub.db.
DEFINE NEW SHARED TEMP-TABLE tt-ext-file NO-UNDO LIKE ub.ext-file.
DEFINE NEW SHARED TEMP-TABLE tt-ext-file-par NO-UNDO LIKE ub.ext-file-par.
DEFINE BUFFER X_db FOR ub.db.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-db-num   as integer no-undo .
define input parameter p-from-db-num   as integer no-undo .
DEFINE INPUT PARAMETER p-status_ AS CHARACTER NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Опции пересылки файлов через систему СПН".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function prepare-path returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, chr(92), chr(47))
v-prepared-path = right-trim(v-prepared-path, chr(47))
.
return v-prepared-path.
END FUNCTION.
function prepare-path2 returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, chr(47), chr(92))
v-prepared-path = right-trim(v-prepared-path, chr(92))
.
return v-prepared-path.
END FUNCTION.
function quote-spaces returns character ( input p-full-path as character):
define variable v-ii as integer no-undo .
define variable v-result as character no-undo .
do v-ii = 1 to num-entries(p-full-path, chr(92)):
  v-result = v-result + (if v-ii = 1 then '' else chr(92)) +
             (if index(entry(v-ii, p-full-path, chr(92)), chr(32)) > 0
             then  substitute("&1&2&1", chr(34), entry(v-ii, p-full-path, chr(92)))
             else entry(v-ii, p-full-path, chr(92))
             )
  .
end.
return v-result.
end function.
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
DEFINE VARIABLE v-file-num AS INTEGER NO-UNDO.
define variable glog as logical no-undo .
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-all-deselect
     LABEL "&-Все"
     SIZE 10 BY 1.
DEFINE BUTTON B-all-select
     LABEL "&+Все"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
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
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.
DEFINE BUTTON B-params
     LABEL "&Пар-тры"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-path AS CHARACTER FORMAT "X(256)":U
     LABEL "Путь"
     VIEW-AS FILL-IN
     SIZE 55.5 BY 1 TOOLTIP "Абс. путь, относ. путь или настройка ini-файла (секция,параметр)" NO-UNDO.
DEFINE VARIABLE Rs-mode AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Сохранить в текущей БД", "save-this-db",
"Выложить на диск другой БД", "save-disk",
"Сохранить в другой БД", "save-db",
"Пакет обновления", "save-install",
"Выложить на диск другой БД и запустить", "save-disk-and-run",
"Сохранить в другой БД и запустить", "save-DB-and-run"
     SIZE 45 BY 4.27 NO-UNDO.
DEFINE VARIABLE rs-path-type AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Относительный", 0,
"Абсолютный", 1,
"Настройки из ini-файла IBS TH", 2
     SIZE 39.5 BY 2.7 NO-UNDO.
DEFINE QUERY BR-db FOR
      X_db,
      tt-db SCROLLING.
DEFINE QUERY BR-files FOR
      tt-ext-file SCROLLING.
DEFINE BROWSE BR-db
  QUERY BR-db NO-LOCK DISPLAY
      (if available tt-db then "*" else "":U) FORMAT "X(1)":U WIDTH 2
      X_db.db-num FORMAT ">>>>9":U WIDTH 6
      X_db.db-name FORMAT "X(40)":U WIDTH 22
    WITH NO-ROW-MARKERS SEPARATORS SIZE 33.3 BY 8.67
         TITLE "Список БД" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE BROWSE BR-files
  QUERY BR-files NO-LOCK DISPLAY
      tt-ext-file.file-name COLUMN-LABEL "Имя и путь к файлу - на компьютере источнике" FORMAT "X(255)":U
            WIDTH 74
      tt-ext-file.file-size COLUMN-LABEL "Размер (б)" FORMAT ">>>>>>>>9":U
      tt-ext-file.update-sys-date COLUMN-LABEL "Дата изм." FORMAT "99/99/9999":U
            WIDTH 11
      tt-ext-file.update-sys-time COLUMN-LABEL "Время изм." FORMAT "X(8)":U
            WIDTH 9
      tt-ext-file.create-sys-date COLUMN-LABEL "Дата созд." FORMAT "99/99/9999":U
      tt-ext-file.create-sys-time COLUMN-LABEL "Время созд." FORMAT "X(8)":U
            WIDTH 9
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.07 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 88
     b-mark AT ROW 2 COL 66.5
     B-all-select AT ROW 2 COL 70.5
     B-all-deselect AT ROW 2 COL 80.5
     BR-db AT ROW 3 COL 66.5
     Rs-mode AT ROW 3.13 COL 2.5 NO-LABEL
     rs-path-type AT ROW 9 COL 2.5 NO-LABEL
     f-path AT ROW 11.8 COL 6.5 COLON-ALIGNED
     b-add AT ROW 12 COL 66.5
     b-del AT ROW 12 COL 76.5
     B-params AT ROW 12 COL 86.5
     BR-files AT ROW 13 COL 1
     "Тип пути к файлу - (на компьютере-приемнике)" VIEW-AS TEXT
          SIZE 44 BY .8 AT ROW 8 COL 2.5
          FGCOLOR 4
     "Режим передачи файла" VIEW-AS TEXT
          SIZE 44 BY .8 AT ROW 2 COL 2.5
          FGCOLOR 4
     SPACE(53.30) SKIP(17.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Опции пересылки файлов чере СПН и/или регистрации пакетов обновлений"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  run proc-add-file IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-all-deselect IN FRAME Dialog-Frame
DO:
  run proc-b-all-deselect IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-all-select IN FRAME Dialog-Frame
DO:
  run proc-b-all-select IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_tt-ext-file FOR tt-ext-file.
  IF NOT AVAILABLE tt-ext-file THEN RETURN NO-APPLY.
  FIND FIRST buf_tt-ext-file WHERE
            recid(buf_tt-ext-file) = RECID(tt-ext-file).
  DELETE buf_tt-ext-file.
  OPEN QUERY BR-files FOR EACH tt-ext-file NO-LOCK INDEXED-REPOSITION.
  find FIRST buf_tt-ext-file NO-LOCK NO-ERROR.
  IF NOT AVAILABLE buf_tt-ext-file
  and p-mode = 'save-install':U
  THEN DO:
      rs-mode:ENABLE(radio-label('save-install':U, RS-mode:RADIO-BUTTONS IN FRAME Dialog-Frame)) IN FRAME Dialog-Frame.
  END.
  IF NOT AVAILABLE buf_tt-ext-file
  and p-mode = 'save-this-db':U
  THEN DO:
      rs-mode:ENABLE(radio-label('save-this-db':U, RS-mode:RADIO-BUTTONS IN FRAME Dialog-Frame)) IN FRAME Dialog-Frame.
  END.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  define buffer buf_tt-ext-file for tt-ext-file.
  ASSIGN
  rs-mode
  rs-path-type
  f-path.
  find first buf_tt-ext-file no-lock no-error.
  if not available buf_tt-ext-file then do:
    message
    "Вы не выбрали ни одного файла для пересылки/сохранения"
    view-as alert-box error .
    return no-apply.
  end.
  IF rs-path-type > 0
  AND f-path = '':U
  AND rs-mode <> 'save-db':U    THEN DO:
     MESSAGE
     substitute("Для типа пути АБСОЛЮТНЫЙ или НАСТРОЙКИ ИЗ INI-ФАЙЛА IBS TH&1" +
                "необходимо указать ПУТЬ"
                , chr(10)
                )
     VIEW-AS ALERT-BOX ERROR .
     RETURN NO-APPLY.
  END.
  IF rs-path-type = 0
   AND f-path = '':U
  AND not (rs-mode = 'save-db':U
          or
          rs-mode = 'save-db-and-run':U
          or
          rs-mode = 'save-this-db':U
          or
          rs-mode = 'save-install':U)
  THEN DO:
      MESSAGE
      substitute("Файлы будут установлены в директорию R-кодов IBS TH&1" +
                 "Вы уверены в Вашем решении?"
                 , chr(10)
                 )
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog .
      IF NOT glog  THEN RETURN NO-APPLY.
  END.
  run proc-run IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
  run proc-mark-db IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-params IN FRAME Dialog-Frame
DO:
  IF rs-mode <> 'save-disk-and-run':U
  AND rs-mode <> 'save-db-and-run':U THEN DO:
    RETURN NO-APPLY.
  END.
  run nws/sndfnwp.w (
                  input parparentproc
                 ,input 'ИЗМЕНЕНИЕ':U
                 ,input "input"
                 ,input 0
                 ,input 0
                 ,input 0
                 ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF Rs-mode IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v_manifest-file AS CHARACTER NO-UNDO.
DEFINE VARIABLE ll_commit AS logical NO-UNDO.
DEFINE VARIABLE old-rs-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
DEFINE BUFFER buf_tt-ext-file FOR tt-ext-file.
  ASSIGN
  old-rs-mode = rs-mode
  rs-mode
  .
  CASE rs-mode:
    WHEN 'save-this-db':U THEN DO:
      ASSIGN
      f-path = '':U
      rs-path-type = 0.
      DISPLAY
      rs-path-type
      f-path
      WITH FRAME Dialog-Frame.
      DISABLE
      rs-path-type
      f-path
      b-params
      WITH FRAME Dialog-Frame.
    END.
    WHEN 'save-db':U THEN DO:
      ASSIGN
      f-path = '':U
      rs-path-type = 0.
      DISPLAY
      rs-path-type
      f-path
      WITH FRAME Dialog-Frame.
      DISABLE
      rs-path-type
      f-path
      b-params
      WITH FRAME Dialog-Frame.
    END.
    WHEN 'save-install':U THEN DO:
      FIND FIRST buf_tt-ext-file NO-LOCK  no-error.
      IF AVAILABLE buf_tt-ext-file THEN DO:
         MESSAGE
         "Уже есть выбранные файлы для пересылки" SKIP
         "Невозможно переключиться в режим пересылки ПАКЕТА ОБНОВЛЕНИЙ"
          VIEW-AS ALERT-BOX ERROR.
          UNDO, RETURN NO-APPLY.
      END.
      ASSIGN
      f-path = '':U
      rs-path-type = 0.
      DISPLAY
      rs-path-type
      f-path
      WITH FRAME Dialog-Frame.
      DISABLE
      rs-path-type
      f-path
      b-params
      WITH FRAME Dialog-Frame.
      SYSTEM-DIALOG GET-FILE v_manifest-file
      TITLE "Выберите файл манифеста данного пакета обновлений"
      FILTERS
        " Файлы манифеста пакета обновлений (*.mf) " "*.mf"
      INITIAL-FILTER 1
      DEFAULT-EXTENSION ".mf"
      USE-FILENAME
      MUST-EXIST
      UPDATE ll_commit
      .
      IF ll_commit <> YES THEN do:
         RETURN NO-APPLY.
      end.
      run nws/sndpckp.p ( INPUT v_manifest-file) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
      DISPLAY
      entry(1, v_manifest-file, ".") @ f-path
      with frame Dialog-Frame.
      OPEN QUERY BR-files FOR EACH tt-ext-file NO-LOCK INDEXED-REPOSITION.
    END.
    WHEN 'save-disk':U THEN DO:
      ENABLE
      rs-path-type
      f-path
      WITH FRAME Dialog-Frame.
      DISABLE
      b-params
      WITH FRAME Dialog-Frame.
    END.
    WHEN 'save-db-and-run':U THEN DO:
      ASSIGN
      f-path = '':U
      rs-path-type = 0.
      DISPLAY
      rs-path-type
      f-path
      WITH FRAME Dialog-Frame.
      DISABLE
      rs-path-type
      f-path
      WITH FRAME Dialog-Frame.
      ENABLE
      b-params
      WITH FRAME Dialog-Frame.
    END.
    WHEN 'save-disk-and-run':U THEN DO:
      ENABLE
      rs-path-type
      f-path
      b-params
      WITH FRAME Dialog-Frame.
    END.
  END CASE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-db :handle
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN Myenable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE confirm-password :
DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-today AS date NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS LOGICAL no-undo.
DEFINE VARIABLE v-psw-buf AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-need-password AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-need-password-int AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
p-ok = YES.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Rs-mode rs-path-type f-path
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help b-mark B-all-select B-all-deselect BR-db Rs-mode
         rs-path-type f-path b-add b-del B-params BR-files
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  IF p-db-num = ? THEN DO:   IF v-cntxt-db-num = 0 THEN DO:      OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num > 0,                  EACH tt-db OF X_db OUTER-JOIN NO-LOCK .   END.   ELSE DO:     OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num = 0,                  EACH tt-db OF X_db OUTER-JOIN NO-LOCK .    END. END. ELSE DO:     IF v-cntxt-db-num = 0 THEN DO:        OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num = p-db-num,                    EACH tt-db OF X_db OUTER-JOIN NO-LOCK .     END. END.    OPEN QUERY BR-files FOR EACH tt-ext-file NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE MyEnable :
assign
rs-mode:radio-buttons in frame Dialog-Frame =
"Сохранить в текущей БД" + chr(44) + 'save-this-db':U + chr(44) +
"Выложить на диск другой БД" + chr(44) + 'save-disk':U + chr(44) +
"Сохранить в другой БД" + chr(44) + 'save-db':U  + chr(44) +
"Пакет обновления" + chr(44) + 'save-install':U + chr(44) +
"Выложить на диск другой БД и запустить" + chr(44) + 'save-disk-and-run':U + chr(44) +
"Сохранить в другой БД и запустить" + chr(44) + 'save-db-and-run':U.
IF p-mode <> "":U THEN DO:
  assign
  rs-mode = p-mode.
  .
END.
DISPLAY
Rs-mode
rs-path-type
f-path
WITH FRAME Dialog-Frame.
ENABLE
B-exit
b-quit
B-Help
b-mark
B-all-select WHEN p-db-num = ?
B-all-deselect WHEN p-db-num = ?
BR-db
Rs-mode WHEN (p-mode = "":U)
rs-path-type
f-path
b-add
b-del
BR-files
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if p-mode = 'save-install':U
or p-mode = 'save-this-db':U
then do:
  rs-mode:disable(radio-label('save-db':U, RS-mode:RADIO-BUTTONS IN FRAME Dialog-Frame)) IN FRAME Dialog-Frame.
  rs-mode:disable(radio-label('save-disk':U, RS-mode:RADIO-BUTTONS IN FRAME Dialog-Frame)) IN FRAME Dialog-Frame.
  rs-mode:disable(radio-label('save-disk-and-run':U, RS-mode:RADIO-BUTTONS IN FRAME Dialog-Frame)) IN FRAME Dialog-Frame.
  rs-mode:disable(radio-label('save-disk-and-run':U, RS-mode:RADIO-BUTTONS IN FRAME Dialog-Frame)) IN FRAME Dialog-Frame.
  if p-mode = 'save-install':U then
  rs-mode:disable(radio-label('save-this-db':U, RS-mode:RADIO-BUTTONS IN FRAME Dialog-Frame)) IN FRAME Dialog-Frame.
  if p-mode = 'save-this-db':U then
  rs-mode:disable(radio-label('save-install':U, RS-mode:RADIO-BUTTONS IN FRAME Dialog-Frame)) IN FRAME Dialog-Frame.
end.
else do:
   rs-mode:disable(radio-label('save-install':U, RS-mode:RADIO-BUTTONS IN FRAME Dialog-Frame)) IN FRAME Dialog-Frame.
   rs-mode:disable(radio-label('save-this-db':U, RS-mode:RADIO-BUTTONS IN FRAME Dialog-Frame)) IN FRAME Dialog-Frame.
end.
APPLY "value-changed" TO rs-mode IN FRAME Dialog-Frame.
IF p-db-num = ? THEN DO:   IF v-cntxt-db-num = 0 THEN DO:      OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num > 0,                  EACH tt-db OF X_db OUTER-JOIN NO-LOCK .   END.   ELSE DO:     OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num = 0,                  EACH tt-db OF X_db OUTER-JOIN NO-LOCK .    END. END. ELSE DO:     IF v-cntxt-db-num = 0 THEN DO:        OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num = p-db-num,                    EACH tt-db OF X_db OUTER-JOIN NO-LOCK .     END. END.    OPEN QUERY BR-files FOR EACH tt-ext-file NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE proc-add-file :
define variable v_os-file   AS CHAR NO-UNDO INIT "".
define variable ll_commit AS LOG    NO-UNDO INIT NO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
DEFINE VARIABLE v-md5-signature AS CHARACTER NO-undo.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE BUFFER buf_tt-ext-file FOR tt-ext-file.
run gbl/dm-file.p ( INPUT (" Файлы Progress (*.i, *.r, *.p, *.w, *.d) " + "|" + "*.i;*.r;*.p;*.w;*.d"
                + "|" + " Текстовые файлы (*.txt) " + "|" + "*.txt"
                + "|" + " Все файлы (*.*) "  + "|" +  "*.*")
                ,INPUT "."
                ,INPUT "Выберите один или несколько файлов"
                ,input frame Dialog-Frame:hwnd
                ,OUTPUT v_os-file
                ,OUTPUT ll_commit
                            ).
IF ll_commit <> YES THEN do:
   RETURN error.
end.
_ii:
DO ii = 1 TO NUM-ENTRIES (v_os-file, "|"):
    run gbl/filename.p (
                     input  entry(ii, v_os-file, '|')
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
    if error-status:error  = ? then do:
      message
      substitute("Ошибка при поиске файла файла &1&2" +
                 "возможно файл уже удален"
                 , v-full-path
                 , chr(10))
     view-as alert-box error .
     next _ii.
    end.
    assign
    v-full-path = prepare-path(v-full-path).
    FIND FIRST buf_tt-ext-file NO-LOCK WHERE
              buf_tt-ext-file.FILE-NAME = v-full-path NO-ERROR.
    IF AVAILABLE buf_tt-ext-file THEN DO:
       MESSAGE
       substitute("В списке выбранных файлов уже есть файл &1&2&1" +
                  "Дата файла &3, время файла &4")
       VIEW-AS ALERT-BOX.
    END.
    file-info:FILE-NAME = v-full-path.
    run gbl/md5.p (
       input  v-full-path
      ,output v-md5-signature
      ) no-error.
    if error-status:error then do:
      message
      substitute("Ошибка при выполнении подсчета КС файла &1&2" +
                 "&3&2&4"
                 , v-full-path
                 , chr(10)
                 , error-status:get-message(1)
                 , return-value )
     view-as alert-box error .
     next _ii.
    end.
    run cur-time in this-procedure ( output v-today, output v-time).
    CREATE buf_tt-ext-file.
    ASSIGN
    buf_tt-ext-file.FILE-NAME = v-full-path
    buf_tt-ext-file.file-num = v-file-num + 1
    v-file-num = v-file-num + 1
    buf_tt-ext-file.create-sys-date      = file-info:FILE-mod-DATE
    buf_tt-ext-file.create-sys-time      = STRING(file-info:FILE-mod-TIME, "HH:MM:SS")
    buf_tt-ext-file.create-sys-time-INT  = file-info:FILE-mod-TIME
    buf_tt-ext-file.update-sys-date      = v-today
    buf_tt-ext-file.update-sys-time      = STRING(v-time, "HH:MM:SS")
    buf_tt-ext-file.update-sys-time-INT  = file-info:FILE-MOD-TIME
    buf_tt-ext-file.file-size            = FILE-INFO:FILE-SIZE
    buf_tt-ext-file.crc-field            = v-md5-signature
    .
    rs-mode:DISABLE(radio-label('save-install':U, RS-mode:RADIO-BUTTONS IN FRAME Dialog-Frame)) IN FRAME Dialog-Frame.
    RELEASE buf_tt-ext-file.
    OPEN QUERY BR-files FOR EACH tt-ext-file NO-LOCK INDEXED-REPOSITION.
END.
END PROCEDURE.
PROCEDURE proc-b-all-deselect :
DEFINE BUFFER buf_tt-db FOR tt-db.
FOR EACH buf_tt-db:
   DELETE buf_tt-db.
END.
IF p-db-num = ? THEN DO:   IF v-cntxt-db-num = 0 THEN DO:      OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num > 0,                  EACH tt-db OF X_db OUTER-JOIN NO-LOCK .   END.   ELSE DO:     OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num = 0,                  EACH tt-db OF X_db OUTER-JOIN NO-LOCK .    END. END. ELSE DO:     IF v-cntxt-db-num = 0 THEN DO:        OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num = p-db-num,                    EACH tt-db OF X_db OUTER-JOIN NO-LOCK .     END. END.
END PROCEDURE.
PROCEDURE proc-b-all-select :
DEFINE BUFFER buf_tt-db FOR tt-db.
GET first br-db no-lock.
DO WHILE available X_db :
    GET prev br-db no-lock.
END.
GET next br-db no-lock.
DO WHILE available X_db :
   FIND FIRST buf_tt-db NO-LOCK WHERE
             buf_tt-db.db-num = X_db.db-num NO-ERROR.
   IF NOT AVAILABLE buf_tt-db THEN DO:
       CREATE buf_tt-db.
       BUFFER-COPY X_db TO buf_tt-db.
       RELEASE buf_Tt-db.
   END.
   GET next br-db no-lock.
END.
GET first br-db no-lock.
IF p-db-num = ? THEN DO:   IF v-cntxt-db-num = 0 THEN DO:      OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num > 0,                  EACH tt-db OF X_db OUTER-JOIN NO-LOCK .   END.   ELSE DO:     OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num = 0,                  EACH tt-db OF X_db OUTER-JOIN NO-LOCK .    END. END. ELSE DO:     IF v-cntxt-db-num = 0 THEN DO:        OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num = p-db-num,                    EACH tt-db OF X_db OUTER-JOIN NO-LOCK .     END. END.
END PROCEDURE.
PROCEDURE proc-mark-db :
DEFINE VARIABLE v-deleted-db-num AS INTEGER NO-UNDO.
DEFINE VARIABLE v-new-db-num AS INTEGER NO-UNDO.
DEFINE BUFFER buf_tt-db FOR tt-db.
DEFINE BUFFER buf_db FOR ub.db.
IF NOT AVAILABLE X_db THEN RETURN.
IF AVAILABLE tt-db THEN DO:
  FIND FIRST buf_tt-db WHERE
         RECID(buf_tt-db) = RECID(tt-db).
  v-deleted-db-num = tt-db.db-num.
  DELETE buf_tt-db.
  IF p-db-num = ? THEN DO:   IF v-cntxt-db-num = 0 THEN DO:      OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num > 0,                  EACH tt-db OF X_db OUTER-JOIN NO-LOCK .   END.   ELSE DO:     OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num = 0,                  EACH tt-db OF X_db OUTER-JOIN NO-LOCK .    END. END. ELSE DO:     IF v-cntxt-db-num = 0 THEN DO:        OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num = p-db-num,                    EACH tt-db OF X_db OUTER-JOIN NO-LOCK .     END. END.
  FIND first buf_db NO-LOCK WHERE
            buf_db.db-num > v-deleted-db-num NO-ERROR.
  IF AVAILABLE buf_db THEN DO:
    REPOSITION br-db TO RECID RECID(buf_db).
  END.
  else do:
    FIND first buf_db NO-LOCK WHERE
              buf_db.db-num = v-deleted-db-num NO-ERROR.
    IF AVAILABLE buf_db THEN DO:
      REPOSITION br-db TO RECID RECID(buf_db).
    END.
    else do:
      FIND first buf_db NO-LOCK NO-ERROR.
      REPOSITION br-db TO RECID RECID(buf_db).
    end.
  end.
END.
ELSE DO:
    CREATE buf_tt-db.
    BUFFER-COPY X_db TO buf_tt-db.
    v-new-db-num = X_db.db-num.
    RELEASE buf_tt-db.
    IF p-db-num = ? THEN DO:   IF v-cntxt-db-num = 0 THEN DO:      OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num > 0,                  EACH tt-db OF X_db OUTER-JOIN NO-LOCK .   END.   ELSE DO:     OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num = 0,                  EACH tt-db OF X_db OUTER-JOIN NO-LOCK .    END. END. ELSE DO:     IF v-cntxt-db-num = 0 THEN DO:        OPEN QUERY BR-db FOR EACH X_db NO-LOCK WHERE X_db.db-num = p-db-num,                    EACH tt-db OF X_db OUTER-JOIN NO-LOCK .     END. END.
    FIND FIRST buf_db NO-LOCK WHERE
              buf_db.db-num > v-new-db-num NO-ERROR.
    IF AVAILABLE buf_db THEN DO:
      REPOSITION br-db TO RECID RECID(buf_db).
    END.
    else do:
      FIND first buf_db NO-LOCK WHERE
                buf_db.db-num = v-new-db-num NO-ERROR.
      IF AVAILABLE buf_db THEN DO:
        REPOSITION br-db TO RECID RECID(buf_db).
      END.
    end.
END.
END PROCEDURE.
PROCEDURE proc-run :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
define buffer buf_db for ub.db.
define buffer buf_tt-db for tt-db.
define buffer buf_tt-ext-file for tt-ext-file.
define buffer buf_tt-ext-file-par for tt-ext-file-par.
find first tt-db no-lock no-error.
if not available tt-db then do:
  if p-mode = 'save-this-db':U then do:
    find first buf_db no-lock where buf_db.db-num = v-cntxt-db-num.
    create buf_tt-db.
    buffer-copy buf_db to buf_tt-db.
    release buf_tt-db.
  end.
  else do:
    if v-cntxt-db-num = 0 then do:
      message
      "Не выбрана ни одна БД для пересылки"
      view-as alert-box error .
      return error.
    end.
    else do:
      find first buf_db no-lock where buf_db.db-num = 0.
      create buf_tt-db.
      buffer-copy buf_db to buf_tt-db.
      release buf_tt-db.
    end.
  end.
end.
IF rs-mode = 'save-disk-and-run':U
OR rs-mode = 'save-db-and-run':U THEN DO:
  DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
  DEFINE VARIABLE v-file-name AS character NO-UNDO.
  v-ii = 0.
  FOR EACH buf_tt-ext-file NO-LOCK:
    v-ii = v-ii + 1.
    IF v-ii = 2 THEN DO:
      MESSAGE
      "В данном режиме для пересылки можно выбрать только ОДИН файл"
      VIEW-AS ALERT-BOX ERROR.
      RETURN error.
    END.
  END.
  FIND FIRST buf_tt-ext-file.
  ASSIGN
  v-file-name = prepare-path(buf_tt-ext-file.FILE-NAME)
  v-file-name = entry(num-entries(v-file-name, chr(47))
                           , v-file-name
                           , chr(47)
                          ).
  run cur-time in THIS-PROCEDURE ( output v-today, output v-time).
  for each buf_tt-ext-file-par no-lock:
    if (buf_tt-ext-file-par.param-type = 'C':U
       AND buf_tt-ext-file-par.param-name = '':U)
    or (buf_tt-ext-file-par.param-type= 'T':U
       AND buf_tt-ext-file-par.param-date-name = '':U)
    or (buf_tt-ext-file-par.param-type = 'I':U
       AND buf_tt-ext-file-par.param-int-name = '':U)
    or (buf_tt-ext-file-par.param-type = 'D':U
       AND buf_tt-ext-file-par.param-decimal-name = '':U)
    or (buf_tt-ext-file-par.param-type = 'L':U
        AND buf_tt-ext-file-par.param-log-name = '':U) then do:
       message
       "Не всем входным параметрам присвоены имена"
       view-as alert-box error.
       undo, return error .
    end.
  end.
  message "ЕЩЕ РАЗ ПРОВЕРЬТЕ ВХОДНЫЕ ПАРАМЕТРЫ!!!!"
  view-as alert-box .
  run nws/sndfnwp.w (
                  input parparentproc
                 ,input 'ИЗМЕНЕНИЕ':U
                 ,input "input"
                 ,input 0
                 ,input 0
                 ,input 0
                 ) NO-ERROR.
  MESSAGE
  substitute("ПРОДОЛЖИТЬ ВЫПОЛНЕНИЕ ОПЕРАЦИИ &1 над выбранным файлом с выбранными параметрами?"
             , rs-mode)
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF glog = NO THEN RETURN ERROR.
END.
else do:
  run cur-time in THIS-PROCEDURE ( output v-today, output v-time).
  RUN confirm-password IN THIS-PROCEDURE (
                                          INPUT '':U
                                          ,INPUT v-today
                                          ,OUTPUT v-ok) NO-ERROR.
  IF NOT v-ok
  THEN DO:
      MESSAGE
      "Пароль неверный"
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
end.
run str/diallog.w (
            INPUT parparentproc
          , INPUT this-procedure:HANDLE
          , INPUT 'nws/sndfnwr.p':U
          , INPUT (rs-mode + chr(4) +
                   string(rs-path-TYPE) + chr(4) +
                   f-path + chr(4) +
                   p-status_)
          , INPUT no
          , input 'Прервать'
          , INPUT (if p-mode = 'save-this-db':U then 'Сохранение файлов в текущей БД' else 'Пересылка файлов через СПН')) no-error .
END PROCEDURE.
