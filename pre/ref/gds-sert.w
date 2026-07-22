define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-mode as character no-undo .
define input parameter i-point as char no-undo.
define input parameter i-b-code like ub.bar-code.b-code no-undo.
define input parameter i-type as char no-undo.
define input parameter i-code as integer no-undo.
define input parameter i-sert-code as character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник сертификатов".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
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
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define new shared buffer b-sert for ub.sert.
define new shared buffer b-sert-join for ub.sert-join.
define new shared buffer b-clients for ub.clients.
define new shared buffer b-goods for ub.goods.
define new shared buffer b-bar-code for ub.bar-code.
DEFINE VAR cli-name like ub.clients.obj-name no-undo.
DEFINE VAR gds-name like ub.goods.gds-name no-undo.
define variable rec as recid no-undo.
define variable sort-column-name as character no-undo .
define variable i-days as integer no-undo.
define variable s-point as char no-undo.
define variable s-b-code like ub.bar-code.b-code no-undo.
define variable s-type as char no-undo.
define variable s-code as integer no-undo.
define stream prnlibstream.
DEFINE variable for-cli-name as character no-undo.
DEFINE variable for-status as character no-undo.
DEFINE variable for-artic as character no-undo.
DEFINE variable for-gds-name as character no-undo.
define variable v-doc-rec as recid no-undo .
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
DEFINE VARIABLE hist-option AS CHARACTER NO-UNDO.
DEFINE FRAME SErtF
b-sert.cli-type COLUMN-LABEL " Тип"
b-sert.cli-code COLUMN-LABEL " Код" format "9999999999"
for-cli-name COLUMN-LABEL "Контрагент" FORMAT "X(30)"
b-sert.sert-code format "x(20)" COLUMN-LABEL  "Код сертификата"
b-sert.first-date
b-sert.last-date
for-status COLUMN-LABEL "Статус" FORMAT "X(7)"
b-sert.PS
for-artic COLUMN-LABEL "Артикул" FORMAT "X(16)"
for-gds-name COLUMN-LABEL "Наименование" FORMAT "X(25)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(prnlibstream) AT 125 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width 232 down stream-io use-text    .
FUNCTION get-cli-name RETURNS CHARACTER
  (buffer loc-cli-gds for b-sert )  FORWARD.
FUNCTION get-gds-artic RETURNS CHARACTER
  (buffer loc-gds for b-sert-join )  FORWARD.
FUNCTION get-gds-name RETURNS CHARACTER
  (buffer l-gds for b-sert-join )  FORWARD.
FUNCTION get-status RETURNS CHARACTER
  (buffer buf-sert for b-sert )  FORWARD.
DEFINE MENU MENU-B-hist
       MENU-ITEM m-all          LABEL "Все сертификаты"
       MENU-ITEM m-one          LABEL "Один сертификат".
DEFINE BUTTON b-cli
     LABEL "&Подключить"
     SIZE 11 BY 1 TOOLTIP "Поключение сертификатов для товара".
DEFINE BUTTON b-del
     LABEL "&Отключить"
     SIZE 10 BY 1 TOOLTIP "Отключение выбранного сертификата для товара".
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.
DEFINE VARIABLE v-artic AS CHARACTER FORMAT "X(16)"
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE v-b-code AS INTEGER FORMAT "->>>>>>>>9" INITIAL 0
     LABEL "Бар-код"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE v-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 17.88 BY 1 NO-UNDO.
DEFINE VARIABLE v-days AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE v-gds-name AS CHARACTER FORMAT "X(40)"
     LABEL "Название товара"
     VIEW-AS FILL-IN
     SIZE 56.63 BY 1
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE v-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 5.75 BY 1 NO-UNDO.
DEFINE VARIABLE r-b-sort AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Контрагент", 2,
"Код товара", 3,
"Действ.", 4,
"Просроч.", 5,
"Истекающ.", 6
     SIZE 63.75 BY .96 NO-UNDO.
DEFINE QUERY br-docs FOR
      b-sert-join,
      b-sert SCROLLING.
DEFINE BROWSE br-docs
  QUERY br-docs NO-LOCK DISPLAY
      b-sert.cli-type COLUMN-LABEL " Тип"
      b-sert.cli-code COLUMN-LABEL " Код" format "9999999999"
      get-cli-name (buffer b-sert) COLUMN-LABEL "Контрагент" FORMAT "X(30)"
      b-sert.sert-code format "x(35)" COLUMN-LABEL  "Код сертификата"
      b-sert.first-date
      b-sert.last-date
      get-status (buffer b-sert) COLUMN-LABEL "Статус" FORMAT "X(7)"
      b-sert.PS
      get-gds-artic (buffer b-sert-join) COLUMN-LABEL "Артикул" FORMAT "X(16)"
      get-gds-name (buffer b-sert-join) COLUMN-LABEL "Наименование" FORMAT "X(25)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 18.5 ROW-HEIGHT-CHARS .75.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cli AT ROW 1 COL 11
     b-del AT ROW 1 COL 22.13
     B-print AT ROW 1 COL 32.13
     v-b-code AT ROW 1 COL 59.5 COLON-ALIGNED
     B-hist AT ROW 1 COL 78
     B-Help AT ROW 1 COL 88
     v-artic AT ROW 2.13 COL 8.25 COLON-ALIGNED
     v-gds-name AT ROW 2.13 COL 39.88 COLON-ALIGNED
     v-days AT ROW 3.25 COL 70.5 COLON-ALIGNED NO-LABEL
     v-code AT ROW 3.25 COL 72.5 COLON-ALIGNED NO-LABEL
     v-type AT ROW 3.25 COL 90.63 COLON-ALIGNED NO-LABEL
     r-b-sort AT ROW 3.29 COL 8 NO-LABEL
     br-docs AT ROW 4.75 COL 1.5
     "Фильтр:" VIEW-AS TEXT
          SIZE 7 BY 1 AT ROW 3.25 COL 1
     SPACE(90.74) SKIP(19.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Сертификаты для товара"
         CANCEL-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-hist:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-hist:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-cli IN FRAME Dialog-Frame
DO:
  run ref/cli-sert.w ( input parparentproc
                     , input p-curr-obj-type
                     , input p-curr-obj-code
                     , input "all":U
                     , input ?
                     , input ?
                     , input i-b-code).
  run Openbr in this-procedure .
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
  define variable ri as recid no-undo.
  define variable rr as recid no-undo.
  if not available b-sert-join THEN return no-apply.
  message "Отсоединить сертификат " b-sert.sert-code " от товара?"
                   view-as alert-box  warning buttons  yes-no set OK as log .
  if OK   then do:
      ri = recid( b-sert-join ).
      get prev br-docs .
      if available b-sert-join
          then   rr = recid( b-sert-join ).
          else do:
              get next br-docs.
              get next br-docs.
              rr = recid( b-sert-join ).
          end.
      find b-sert-join where recid( b-sert-join ) = ri.
      delete b-sert-join.
      run Openbr in this-procedure .
      reposition br-docs to recid rr no-error.
      apply "ENTRY":U to br-docs.
      apply "VALUE-CHANGED":U to br-docs.
   end.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE b-sert-join THEN RETURN.
  if hist-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if hist-option = '':U then return no-apply.
  run ref/c-serts.w (
                INPut parParentProc
               ,INPUT '':U
               ,INPUT 'subject'
               ,INPUT (IF hist-option = 'all' THEN '':U ELSE b-sert-join.cli-type)
               ,INPUT (IF hist-option = 'all' THEN 0 ELSE b-sert-join.cli-code)
               ,INPUT (IF hist-option = 'all' THEN '':U ELSE b-sert-join.sert-code)
               ,INPUT b-sert-join.b-code
               ,INPUT 'sert-join':U
               ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  APPLY "entry" TO br-docs.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
if i-point = 'все':U then do:
      message "Вы хотите напечатать весь список сертифицированных товаров" skip
      "Эта процедура может занять долгое время! Продолжать?" view-as alert-box
      WARNING buttons YES-NO update loc#log.
      if NOT loc#log then return no-apply.
end.
v-doc-rec = recid( b-sert-join ).
DO WHILE available b-sert-join :
      GET prev br-docs.
END.
run Print-List in this-procedure .
reposition br-docs to recid v-doc-rec no-error.
apply "entry" to br-docs in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF br-docs IN FRAME Dialog-Frame
DO:
        find ub.bar-code where ub.bar-code.b-code = b-sert-join.b-code no-lock no-error.
        if available ub.bar-code then do:
            find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code no-lock.
            assign
                v-gds-name = ub.goods.gds-name
                v-artic = ub.goods.artic
                v-b-code = b-sert-join.b-code.
        end.
        else if i-b-code <> ? then do:
            find ub.bar-code where ub.bar-code.b-code = i-b-code no-lock no-error.
            if available ub.bar-code then do:
                find ub.goods where goods.gds-code = ub.bar-code.gds-code no-lock.
                assign
                    v-gds-name = goods.gds-name
                    v-artic = goods.artic
                    v-b-code = i-b-code.
             end.
         end.
         disp v-gds-name v-artic v-b-code with frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-all
DO:
  assign
  hist-option = 'all'.
  APPLY "CHOOSE" to b-hist  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-one
DO:
  assign
  hist-option = 'one'.
  APPLY "CHOOSE" to b-hist  in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF r-b-sort IN FRAME Dialog-Frame
DO:
  assign r-b-sort.
    case r-b-sort:
    when 2 then do:
        disable v-b-code v-days with frame Dialog-Frame.
        hide v-b-code v-days .
        if i-point = "cli":U then do:
            message "Сортировка итак по одному клиенту" view-as alert-box warning.
            r-b-sort = 1.
            disp r-b-sort with frame Dialog-Frame.
            apply "VALUE-CHANGED":U to r-b-sort.
            return no-apply.
        end.
        view v-code v-type.
        enable v-code v-type with frame Dialog-Frame.
        apply "entry" to v-code.
        return no-apply.
    end.
    when 3 then do:
        disable v-type v-code v-days with frame Dialog-Frame.
        hide v-type v-code v-days .
        if i-point = "gds:U" then do:
            message "Сортировка итак по одному товару" view-as alert-box warning.
            r-b-sort = 1.
            disp r-b-sort with frame Dialog-Frame.
            apply "VALUE-CHANGED":U to r-b-sort.
        end.
        else do:
            enable v-b-code with frame Dialog-Frame.
            apply "entry" to v-b-code.
            return no-apply.
        end.
    end.
    when 5 then do:
        disable v-type v-code v-b-code v-days with frame Dialog-Frame.
        hide v-type v-code v-b-code.
        if i-point = "over":U then do:
            message "Сортировка итак по просроченным" view-as alert-box warning.
            r-b-sort = 1.
            disp r-b-sort with frame Dialog-Frame.
            apply "VALUE-CHANGED":U to r-b-sort.
        end.
        i-point = "over":U.
        RUN OpenBr in this-procedure .
    end.
    when 4 then do:
        disable v-type v-code v-b-code v-days with frame Dialog-Frame.
        hide v-type v-code v-b-code.
        if i-point = "true":U then do:
            message "Сортировка итак по действующим" view-as alert-box warning.
            r-b-sort = 1.
            disp r-b-sort with frame Dialog-Frame.
            apply "VALUE-CHANGED":U to r-b-sort.
        end.
        i-point = "true":U.
        RUN OpenBr in this-procedure .
    end.
    when 6 then do:
        disable v-type v-code v-b-code with frame Dialog-Frame.
        hide v-type v-code v-b-code .
        enable v-days with frame Dialog-Frame.
        apply "entry" to v-days.
        return no-apply.
    end.
    otherwise do:
        disable v-code v-type v-b-code v-days with frame Dialog-Frame.
        hide v-code v-type v-b-code v-days .
        i-point = "all":U.
        run Openbr in this-procedure .
     end.
  end case.
END.
ON RETURN OF v-b-code IN FRAME Dialog-Frame
DO:
def buffer buf-b-code for ub.bar-code.
  assign
      v-b-code
      i-b-code = v-b-code
      i-point = "gds":U.
  find first buf-b-code where
             buf-b-code.b-code =  i-b-code no-lock no-error.
  if available buf-b-code then do:
      find first ub.goods where
                 ub.goods.gds-code = buf-b-code.gds-code no-lock.
      FIND FIRST ub.gds-prt WHERE
                 ub.gds-prt.upper-code = goods.prt-root NO-LOCK .
      find FIRST ub.bar-code where
                 ub.bar-code.gds-code = ub.goods.gds-code AND
                 ub.bar-code.node-code = ub.gds-prt.node-code AND
                 ub.bar-code.part-code = "" AND
                 ub.bar-code.in-code = "" AND
                 ub.bar-code.unit-cli = ub.goods.unit-base no-lock.
      i-b-code = ub.bar-code.b-code.
      run Openbr in this-procedure .
  end.
  else
    message "Нет такого товара" view-as alert-box warning.
  i-point = "ALL":U.
  return no-apply.
END.
ON RETURN OF v-code IN FRAME Dialog-Frame
DO:
  assign v-code .
  if v-code <> 0 then do:
        apply "ENTRY" to v-type.
        apply "VALUE-CHANGED":U to br-docs.
  end.
  else do:
            r-b-sort = 1.
            disp r-b-sort with frame Dialog-Frame.
            apply "VALUE-CHANGED":U to r-b-sort.
            return no-apply.
  end.
END.
ON RETURN OF v-days IN FRAME Dialog-Frame
DO:
   assign
      v-days
      i-days = v-days
      i-point = "day-off":U.
      run Openbr in this-procedure .
  return no-apply.
END.
ON RETURN OF v-type IN FRAME Dialog-Frame
DO:
  assign
  v-code v-type
  i-code = v-code
  i-type = v-type
  i-point = "cli":U.
  if can-find(first ub.clients where
                    ub.clients.obj-type = v-type and ub.clients.obj-code = v-code) then  dO:
      run Openbr in this-procedure .
  end.
  else do:
    message "Нет такого контрагента" view-as alert-box warning.
  i-point = "all":U.
  end.
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-docs :handle
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-docs :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  v-doc-rec = recid(b-sert). run openbr in this-procedure. reposition br-docs to recid(v-doc-rec). v-doc-rec = ? .
    apply "VALUE-CHANGED" to br-docs.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if i-point = "all":U then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр i-point при вызове процедуры"
    view-as alert-box ERROR
    .
    return.
  end.
  Run MyENable in this-procedure no-error.
  if error-status:error then return no-apply.
  RUN Openbr in this-procedure .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-docs as INT EXTENT 21 no-undo.
DEF VAR varmvibr-docs       as INT no-undo.
DEF VAR varmvjbr-docs       as INT no-undo.
DEF VAR varmvkbr-docs       as INT no-undo.
DEF VAR varmvlbr-docs       as INT no-undo.
DEF VAR move-elementbr-docs as INT no-undo.
def var jjbr-docs           as int no-undo.
do varmvibr-docs = 1 to EXTENT(cur-clmn-numbr-docs):
  ASSIGN cur-clmn-numbr-docs[varmvibr-docs] = varmvibr-docs.
END.
RUN start-mv-clmnbr-docs.
PROCEDURE start-mv-clmnbr-docs:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  s-point = 'day-off':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('9,10,1,2,3,4,5,6,7,8') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '9,10,1,2,3,4,5,6,7,8'))] ,  + 1).
   END.
       END.
       IF  s-point = 'sert':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('9,10,1,2,3,4,5,6,7,8') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '9,10,1,2,3,4,5,6,7,8'))] ,  + 1).
   END.
       END.
       IF  s-point = 'gds':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('4,5,6,7,8,9,10,1,2,3') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '4,5,6,7,8,9,10,1,2,3'))] ,  + 1).
   END.
       END.
       IF  S-POINT = 'gds-cli':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,4,5,6,7,8,9,10'))] ,  + 1).
   END.
       END.
       IF  S-POINT = 'true':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,4,5,6,7,8,9,10'))] ,  + 1).
   END.
       END.
       IF  s-point = 'over':U  THEN DO:
   DO jjbr-docs = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10') TO 1 BY -1:
     RUN re-move-clmnbr-docs ( cur-clmn-numbr-docs[INTEGER(ENTRY (jjbr-docs, '1,2,3,4,5,6,7,8,9,10'))] ,  + 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (  + 1, 21).
END.
ON ctrl-cursor-left OF BROWSE br-docs do:
  RUN re-move-clmnbr-docs (21,  + 1).
END.
PROCEDURE re-move-clmnbr-docs:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = source-column THEN cur-clmn-numbr-docs[varmvibr-docs] = -1.
  END.
  if br-docs:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-docs = source-column - 1 to target-column BY -1:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
        if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
          cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-docs = source-column + 1 to target-column:
    DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
      if cur-clmn-numbr-docs[varmvibr-docs] = varmvjbr-docs THEN DO:
        cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-numbr-docs[varmvibr-docs] - 1.
      END.
    END.
  END.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = -1 THEN cur-clmn-numbr-docs[varmvibr-docs] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-docs:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <=  + 1 then do:
    return .
  end.
  DO varmvibr-docs = 1 TO EXTENT(cur-clmn-numbr-docs):
    if cur-clmn-numbr-docs[varmvibr-docs] = cur-clmn-loc THEN move-elementbr-docs = varmvibr-docs.
  END.
  RUN re-move-clmnbr-docs (cur-clmn-loc,  + 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-docs:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-docs =  + 1 to EXTENT(cur-clmn-numbr-docs):
    RUN re-move-clmnbr-docs (cur-clmn-numbr-docs[varmvlbr-docs], varmvlbr-docs).
  END.
  RUN start-mv-clmnbr-docs.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-b-code v-artic v-gds-name v-days v-code v-type r-b-sort
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cli b-del B-print v-b-code B-hist B-Help v-days v-code v-type
         r-b-sort br-docs
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-docs FOR EACH b-sert-join WHERE             b-sert-join.b-code = i-b-code NO-LOCK,            each b-sert WHERE b-sert.SERT-CODE = B-SERT-JOIN.SERT-CODE no-lock     BY b-sert.last-date DESCENDING.
END PROCEDURE.
PROCEDURE MyEnable :
define variable loc#log as logical no-undo.
define variable disablevar as integer no-undo.
b-hist:MENU-MOUSE in frame Dialog-Frame = 1.
assign
s-point = i-point
s-b-code = i-b-code
s-type = i-type
s-code = i-code
i-point = "all":U
.
  DISPLAY
  v-b-code
  v-artic
  v-gds-name
  WITH FRAME Dialog-Frame.
  ENABLE
  b-exit
  b-print
  B-Help
  b-hist
  br-docs
  r-b-sort
  WITH FRAME Dialog-Frame.
  CASE S-point:
    when "sert":U then do:
      frame Dialog-Frame:title = " Товары  сертификата " + i-sert-code.
      disablevar = 2.
    end.
    when "gds":U then do:
      FIND FIRST ub.goods No-LOCK WHERE
                 ub.goods.gds-code = i-b-code No-ERROR.
      if not avail goods then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найден товар  с  бар-кодом " i-b-code
        view-as alert-box error.
        return error .
      end.
      frame Dialog-Frame:title = "Сертификаты для товара " + goods.artic + chr(32) +
                                  string(ub.goods.gds-name, "X(25)").
      disablevar = 3.
    end.
    when "cli":U then do:
      frame Dialog-Frame:title = "Товары сертифицированные фирмой " + i-type + string(i-code).
      disablevar = 2.
    end.
    when "gds-cli":U then do:
      FIND FIRST goods No-LOCK WHERE
                 goods.gds-code = i-b-code No-ERROR.
      if not avail goods then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найден товар с бар-кодом " i-b-code
        view-as alert-box error.
        return error .
      end.
      disablevar = 2.
      assign
      loc#log = r-b-sort:disable(radio-label(string(disablevar), r-b-sort:radio-buttons)).
      disablevar = 3.
    end.
    when "true":U then do:
      frame Dialog-Frame:title = "Товары по действующим сертификатам".
      disablevar = 4.
    end.
    when "over":U then do:
      frame Dialog-Frame:title = "Товары по просроченным серфтификатам".
      disablevar = 5.
    end.
    when "day-off":U then do:
      frame Dialog-Frame:title = "Товары по истекающим серфтификатам".
      disablevar = 6.
    end.
  END CASE.
  assign
  loc#log = r-b-sort:disable(radio-label(string(disablevar), r-b-sort:radio-buttons)) no-error.
  ENABLE
  b-del when (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U)
  b-cli when (p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U) and s-point = "gds"
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Openbr :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).
case i-point:
    when "all":u then do:
        CASE s-point:
          when "sert":U then
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.sert-code = i-sert-code AND
                     b-sert-join.cli-type = i-type AND
                     b-sert-join.cli-code = i-code NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "gds":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.b-code = s-b-code or s-b-code = ?) NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
         when "gds-cli":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.b-code = s-b-code  or s-b-code = ?) AND
                     (b-sert-join.cli-type = s-type or s-type = ? ) and
                     (b-sert-join.cli-code = s-code or s-code = ?) NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
         when "cli" then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? )  and
                     (b-sert-join.cli-code = s-code  or s-code = ?) NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
       END CASE.
    end.
    when "gds":u then do:
        CASE s-point:
          WHeN "sert":u then
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.b-code = i-b-code AND
                     b-sert-join.sert-code = i-sert-code AND
                     b-sert-join.cli-type = i-type AND
                     b-sert-join.cli-code = i-code NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
          WHEN "GDS":U THEN RETURN.
          WHEN "GDS-CLI":u THEN RETURN.
          WHeN "CLI":u then
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.b-code = i-b-code AND
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
        END CASE.
    end.
    when "gds-cli":u then do:
        CASE s-point:
          WHEN "sert":U THEN
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.sert-code = i-sert-code  AND
                     b-sert-join.b-code = i-b-code AND
                     b-sert-join.cli-type = i-type and
                     b-sert-join.cli-code = i-code NO-LOCK,
                FIRST b-sert WHERE
                     b-sert.cli-type = b-sert-join.cli-type AND
                     b-sert.cli-code = b-sert-join.cli-code AND
                     b-sert.sErt-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
          WHEN "GDS-CLI":u THEN RETURN.
          WHeN "GDS":u then RETURN.
       END CASE.
    end.
    WHEN "cli":U then do:
        CASE s-point:
          when "sert":U then
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.sert-code = i-sert-code AND
                     b-sert-join.cli-type = i-type and
                     b-sert-join.cli-code = i-code NO-LOCK,
                FIRST b-sert WHERE
                      b-sert.cli-type = b-sert-join.cli-type AND
                      b-sert.cli-code = b-sert-join.cli-code AND
                      b-sert.sert-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "cli":U then RETURN.
          WHEN "cli-gds":U then RETURN.
          when "gds":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.b-code = s-b-code  or s-b-code = ?) AND
                     b-sert-join.cli-type = i-type and
                     b-sert-join.cli-code = i-code NO-LOCK,
                FIRST b-sert WHERE
                      b-sert.cli-type = b-sert-join.cli-type AND
                      b-sert.cli-code = b-sert-join.cli-code AND
                      b-sert.sert-code = b-sert-join.sert-code NO-LOCK
            BY b-sert.last-date DESCENDING.
        end case.
    END.
    WHEN "over":U then  do:
        case s-point:
          when "sert":U then do:
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.sert-code = i-sert-code AND
                     b-sert-join.cli-type = i-type and
                     b-sert-join.cli-code = i-code NO-LOCK,
                first b-sert where
                      b-sert.cli-type = b-sert-join.cli-type AND
                      b-sert.cli-code = b-sert-join.cli-code AND
                      b-sert.sert-code = b-sert-join.sert-code and
                      B-SERT.LAST-DATE < v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
          end.
          when "gds":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.b-code = s-b-code or s-b-code = ?) NO-LOCK,
                first b-sert where
                      b-sert.cli-type = b-sert-join.cli-type AND
                      b-sert.cli-code = b-sert-join.cli-code AND
                      b-sert.sert-code = b-sert-join.sert-code and
                      B-SERT.LAST-DATE < v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "gds-cli":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) and
                     (b-sert-join.b-code = s-b-code  or s-b-code = ?) NO-LOCK,
                first b-sert where
                      b-sert.cli-type = b-sert-join.cli-type AND
                      b-sert.cli-code = b-sert-join.cli-code AND
                      b-sert.sert-code = b-sert-join.sert-code and
                      B-SERT.LAST-DATE < v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "cli" then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) NO-LOCK,
                first b-sert where
                      b-sert.cli-type = b-sert-join.cli-type AND
                      b-sert.cli-code = b-sert-join.cli-code AND
                      b-sert.sert-code = b-sert-join.sert-code and
                      B-SERT.LAST-DATE < v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
        END CASE.
    end.
    WHEN "true":U then do:
        case s-point:
          when "sert":U then
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.sert-code = i-sert-code AND
                     b-sert-join.cli-type = i-type and
                     b-sert-join.cli-code = i-code NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  B-SERT.LAST-DATE >= v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "gds":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.b-code = s-b-code  or s-b-code = ?) NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  B-SERT.LAST-DATE >= v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "gds-cli":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) and
                     (b-sert-join.b-code = s-b-code or s-b-code = ?) NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  B-SERT.LAST-DATE >= v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "cli":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  B-SERT.LAST-DATE >= v-TODAY NO-LOCK
            BY b-sert.last-date DESCENDING.
        END case.
    end.
    WHEN "day-off":U then do:
        CASE s-point:
          when "sert":U then
            open query br-docs
            for each b-sert-join WHERE
                     b-sert-join.sert-code = i-sert-code AND
                     b-sert-join.cli-type = i-type and
                     b-sert-join.cli-code = i-code NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  (B-SERT.LAST-DATE > v-TODAY AND (B-SERT.LAST-DATE - v-TODAY) <= i-days) NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "gds":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.b-code = s-b-code  or s-b-code = ?) NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  (B-SERT.LAST-DATE > v-TODAY AND (B-SERT.LAST-DATE - v-TODAY) <= i-days) NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "gds-cli":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) and
                     (b-sert-join.b-code = s-b-code  or s-b-code = ?) NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  (B-SERT.LAST-DATE > v-TODAY AND (B-SERT.LAST-DATE - v-TODAY) <= i-days) NO-LOCK
            BY b-sert.last-date DESCENDING.
          when "cli":U then
            open query br-docs
            for each b-sert-join WHERE
                     (b-sert-join.cli-type = s-type  or s-type = ? ) and
                     (b-sert-join.cli-code = s-code  or s-code = ?) NO-LOCK,
            first b-sert where
                  b-sert.cli-type = b-sert-join.cli-type AND
                  b-sert.cli-code = b-sert-join.cli-code AND
                  b-sert.sert-code = b-sert-join.sert-code and
                  (B-SERT.LAST-DATE > v-TODAY AND (B-SERT.LAST-DATE - v-TODAY) <= i-days) NO-LOCK
            BY b-sert.last-date DESCENDING.
       END CASE.
    END.
end case.
APPLY "VALUE-CHANGED" TO BR-docs in frame Dialog-Frame.
APPLY "ENTRY" TO BR-docs in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE Print-List :
define variable accum-count as integer no-undo.
define variable for-ps1 as char no-undo.
define variable for-ps2 as char no-undo.
Line = fill("-", 198).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM prnlibstream
SPACE(25) ( frame Dialog-Frame:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(177)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM prnlibstream FRAME BottomFrame .
FORM with FRAME StreamF  .
run waitfram-show in this-procedure ( input "Ждите...").
GET next br-docs.
accum-count = 0 .
DO WHILE available b-sert-join :
    Assign
    for-cli-name = get-cli-name(buffer b-sert)
    for-status = get-status(buffer b-sert)
    for-artic = get-gds-artic(buffer b-sert-join)
    for-gds-name = get-gds-name(buffer b-sert-join)
    for-ps1 = breakstr(b-sert.PS, 18, input-output for-ps1, input-output for-ps2).
    .
    DISPLAY stream prnlibstream
    b-sert.cli-type
    b-sert.cli-code
    for-cli-name
    b-sert.sert-code
    b-sert.first-date
    b-sert.last-date
    for-status
    for-ps1 @ b-sert.PS
    for-artic
    for-gds-name
    with frame SertF.
    DOWN STREAM prnlibstream 1 with FRAME SertF  .
    if for-ps2 <> "" then do:
        DISPLAY stream prnlibstream
        for-ps2 @ b-sert.PS
        with frame SertF.
        DOWN STREAM prnlibstream 1 with FRAME SertF  .
    end.
    assign
    accum-count = accum-count + 1
    .
    GET next br-docs.
END.
UNDERLINE stream prnlibstream
b-sert.cli-type
b-sert.cli-code
for-cli-name
b-sert.sert-code
b-sert.first-date
b-sert.last-date
for-status
b-sert.PS
for-artic
for-gds-name
with frame SertF.
DOWN STREAM prnlibstream 1 with FRAME SertF  .
DISPLAY stream prnlibstream
"Всего" @ for-cli-name
string(accum-count) + " записей" @ b-sert.sert-code
with frame SertF.
DOWN STREAM prnlibstream 1 with FRAME SertF  .
UNDERLINE stream prnlibstream
b-sert.cli-type
b-sert.cli-code
for-cli-name
b-sert.sert-code
b-sert.first-date
b-sert.last-date
for-status
b-sert.PS
for-artic
for-gds-name
with frame SertF.
DOWN stream prnlibstream 1 with FRAME SertF.
HIDE  STREAM prnlibstream FRAME BottomFrame .
HIDE  STREAM prnlibstream FRAME SertF.
output  STREAM prnlibstream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
FUNCTION get-cli-name RETURNS CHARACTER
  (buffer loc-cli-gds for b-sert ) :
    define variable dop like ub.clients.obj-name.
    FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = loc-cli-gds.cli-type AND
                                     ub.clients.obj-code = loc-cli-gds.cli-code
    No-ERROR.
    IF avail clients then dop = ub.clients.obj-name.
    ELSE dop = "".
  RETURN dop.
END FUNCTION.
FUNCTION get-gds-artic RETURNS CHARACTER
  (buffer loc-gds for b-sert-join ) :
  define buffer ga-goods for ub.goods.
    define variable dop like ub.goods.gds-name.
    FIND FIRST ub.bar-code NO-LOCK WHERE ub.bar-code.b-code = loc-gds.b-code
    No-ERROR.
    IF avail ub.bar-code then do:
       find first ga-goods where ga-goods.gds-code = bar-code.gds-code no-lock.
        dop = ga-goods.artic.
    end.
    ELSE dop = "".
  RETURN dop.
END FUNCTION.
FUNCTION get-gds-name RETURNS CHARACTER
  (buffer l-gds for b-sert-join ) :
    define variable dop like ub.goods.gds-name.
    FIND FIRST ub.bar-code NO-LOCK WHERE ub.bar-code.b-code = l-gds.b-code
    No-ERROR.
    IF avail ub.bar-code then do:
        find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code no-lock no-error.
        dop = ub.goods.gds-name.
    end.
    ELSE dop = "".
  RETURN dop.
END FUNCTION.
FUNCTION get-status RETURNS CHARACTER
  (buffer buf-sert for b-sert ) :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
    define variable stt as char .
    run cur-time in this-procedure ( output v-today, output v-time).
    if buf-sert.first-date > v-today then stt = "Будущие".
    else do:
        if buf-sert.last-date > v-today then stt = "Действ".
        else
            stt =  "Просроч".
    end.
  RETURN stt.
END FUNCTION.
