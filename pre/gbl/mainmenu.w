CREATE WIDGET-POOL.
define input  parameter p-process-pid as integer   no-undo .
define input  parameter p-user-id     as character no-undo .
define input  parameter p-password    as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Главное окно IBS Trade House".
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
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define new global shared variable g#libbcrcn as handle no-undo .
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
DEFINE new SHARED TEMP-TABLE TT-tnved NO-UNDO
FIELD tnved  AS CHAR FORMAT "X(10)"  LABEL 'Код ТНВЭД':U
FIELD f-name AS CHAR FORMAT "X(255)" LABEL 'Полное наименование':U
INDEX tnved IS UNIQUE PRIMARY  tnved.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrnickf returns character ( input p-user-id as character):
   define variable v-nick      as character    no-undo.
   if p-user-id = ?
   OR p-user-id = "":U
   then do:
      return '':U .
   end.
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrnick in g#library
  (input  p-user-id
  ,output v-nick
  ) no-error .
   if error-status :error
   then do:
      return p-user-id.
   end.
   else do:
      return v-nick.
   end.
end function.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure godendo-date-to-offset :
  define input  parameter p-today  as date      no-undo .
  define input  parameter p-date   as date      no-undo .
  define output parameter p-offset as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-date  = ?
    or p-today = ?
    then do:
      assign
        p-offset = ?
      .
    end.
    else do:
      assign
        p-offset = p-date - p-today + 1
      .
    end.
  end.
end procedure.
procedure godendo-offset-to-date :
  define input  parameter p-today  as date      no-undo .
  define input  parameter p-offset as integer   no-undo .
  define output parameter p-date   as date      no-undo .
  do
  on error undo, return error return-value
  :
    if p-today  = ?
    or p-offset = ?
    then do:
      assign
        p-date = ?
      .
    end.
    else do:
      assign
        p-date = p-offset + p-today - 1
      .
    end.
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uh9 as handle no-undo .
define variable v-found9 as logical no-undo .
v-uh9 = session:first-procedure no-error.
do while valid-handle(v-uh9):
  if v-uh9:type = "PROCEDURE" then do:
    if v-uh9:file-name = "gbl/mainproc.p" then do:
      v-found9 = yes.
      leave.
    end.
  end.
  v-uh9 = v-uh9:next-sibling no-error.
end.
if not v-found9 then do:
  run gbl/mainproc.p persistent.
end.
procedure mainhandle_parentproc_indicator :
return.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure db-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
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
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
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
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
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
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
function is-gas returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'metan':U) no-error.
return result.
end function.
define variable v-cntxt-developer              as logical   no-undo .
define variable v-cntxt-db-num                 as integer   no-undo .
define variable v-cntxt-user-id                as character no-undo .
define variable v-cntxt-process-id             as integer   no-undo .
define variable v-cntxt-password               as character no-undo .
define variable v-cntxt-level                  as character no-undo .
define variable v-cntxt-host-code-obj          as integer   no-undo .
define variable v-cntxt-obj-type               as character no-undo .
define variable v-cntxt-obj-code               as integer   no-undo .
define variable v-cntxt-db-num-obj             as integer   no-undo .
define variable v-cntxt-menu-code              as integer   no-undo .
define variable v-cntxt-menu-group-code        as integer   no-undo .
define variable v-cntxt-previous-menu-group-id as character no-undo .
define variable v-cntxt-report-num             as integer   no-undo .
define variable v-cntxt-quest-print            as logical   no-undo .
define variable v-cntxt-inp-jewel              as logical   no-undo .
define variable v-cntxt-gds-engl               as logical   no-undo .
define variable v-cntxt-bc-price               as logical   no-undo .
define variable v-cntxt-is-admin               as logical   no-undo .
define variable g#dm-menu-handle               as handle    no-undo .
define variable v-menu-control-number          as character no-undo.
define variable parparentproc                  as widget-handle       no-undo.
DEFINE VARIABLE fi-menu-group-name AS CHARACTER no-undo.
define variable v-show-display-name as character format "x(60)" label "Меню" .
define variable v-logo-image-visible    as logical      no-undo.
define variable v-db-attr-value         as character    no-undo .
define variable v-db-attr-type          as character    no-undo .
define variable v-mess-id               as integer      no-undo .
define temp-table temp-menu-item no-undo
  field num-level      as integer
  field show-child     as character format "x(1)"  label " "
  field display-name   as character format "x(45)" label "Меню"
  field full-name      as character
  field item-code      as integer                  label "Номер"
  field item-type      as character
  field item-name      as character
  field item-id        as character
  field item-procedure as character
  field parent-code    as integer
  field show-menu-item as logical
  index xpk is primary unique item-code
  index xie1 show-menu-item item-code
  index xie2 parent-code item-code
  index i-name IS WORD-INDEX item-name
  .
define temp-table temp-menu-item-open no-undo
  field item-code as integer
  index xpk is primary unique item-code
  .
define temp-table temp-image no-undo
  field image-code          as integer
  field image-handle        as widget-handle
  field image-visible       as logical
  field image-procedure     as character
  field image-file-name     as character
  field image-sel-file-name as character
  field image-name          as character
  index xpk is primary unique image-code
  .
define temp-table temp-check-image no-undo
  field check-image-index               as integer
  field check-image-name                as character
  field check-image-context             as character
  field check-image-menu-group-id-list  as character
  field check-image-procedure-list      as character
  field check-image-visible-procedure   as character
  field check-image-image-procedure     as character
  field check-image-image-file-name     as character
  field check-image-image-name          as character
  index xpk is primary unique check-image-index
  index xie1 check-image-name
  .
define variable o-code      as integer   no-undo .
define variable rid#        as recid     no-undo .
define variable ri-list     as character no-undo .
define variable tnved-fn    as character no-undo .
define variable v-work-file as character no-undo .
define variable conf-par    as character no-undo .
define variable par-type    as character no-undo .
define variable wth-type    as character no-undo .
define variable v-obj-date  as date      no-undo .
define variable v-connect-usr          as integer   no-undo .
define variable v-connect-device       as character no-undo .
define variable v-userio-id            as integer   no-undo .
define variable v-menu-user-call-rowid as rowid     no-undo .
define variable v-userio-ai-read       as decimal   no-undo .
define variable v-userio-ai-write      as decimal   no-undo .
define variable v-userio-bi-read       as decimal   no-undo .
define variable v-userio-bi-write      as decimal   no-undo .
define variable v-userio-db-access     as decimal   no-undo .
define variable v-userio-db-read       as decimal   no-undo .
define variable v-userio-db-write      as decimal   no-undo .
define variable par-is-cctv as character no-undo .
define variable is-cctv     as logical   no-undo .
define variable v-vid-ok    as logical   no-undo .
define variable v-vid-mes   as character no-undo .
define variable v-vid-param as longchar  no-undo .
define variable menu-bar-handle    as widget-handle no-undo.
define variable v-menu-item-choose as logical   no-undo .
define stream sinp .
FUNCTION get-display-name RETURNS CHARACTER
  ( buffer buf_temp-menu-item for temp-menu-item )  FORWARD.
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.
DEFINE BUTTON b-copy
     IMAGE-UP FILE "cmp/btn-copy.bmp":U
     LABEL "b-copy"
     SIZE 3 BY 1 TOOLTIP "Скопировать название пункта меню".
DEFINE BUTTON b-open-gds
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "b-copy"
     SIZE 3 BY 1 TOOLTIP "Показать подробную информацию о штрих-коде".
DEFINE BUTTON b-search-bar-code
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     LABEL "b-copy"
     SIZE 3 BY 1 TOOLTIP "Показать подробную информацию о штрих-коде".
DEFINE BUTTON b-show-date
     IMAGE-UP FILE "cmp/calend.bmp":U
     IMAGE-DOWN FILE "cmp/calend.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/calend.bmp":U
     LABEL "b-copy"
     SIZE 2.5 BY .67 TOOLTIP "Показать дату на объекте".
DEFINE VARIABLE ed-menu-item-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 57.25 BY 2.33 NO-UNDO.
DEFINE VARIABLE fi-bar-code AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30.25 BY .67 TOOLTIP "Штрих код" NO-UNDO.
DEFINE VARIABLE fi-close-date AS DATE FORMAT "99/99/9999":U
     LABEL "Период"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Дата закрытия периода на объекте"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-db-num AS CHARACTER FORMAT "X(256)":U
     LABEL "БД"
      VIEW-AS TEXT
     SIZE 20 BY .67 TOOLTIP "База данных"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-gds-artic AS CHARACTER FORMAT "X(256)":U
     LABEL "Артикул"
      VIEW-AS TEXT
     SIZE 32.63 BY .67 TOOLTIP "Артикул"
     FGCOLOR 4 .
DEFINE VARIABLE fi-gds-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
      VIEW-AS TEXT
     SIZE 34.75 BY .67 TOOLTIP "Наименование товара"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-gds-price-sale AS CHARACTER FORMAT "X(256)":U
     LABEL "Цена"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Цена товара"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-gds-qnty AS CHARACTER FORMAT "X(256)":U
     LABEL "Кол-во"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Количество товара"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-host AS CHARACTER FORMAT "X(256)":U
     LABEL "Фирма"
      VIEW-AS TEXT
     SIZE 13 BY .67 TOOLTIP "Фирма"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-host-basecode-desc AS CHARACTER FORMAT "X(3)":U
     LABEL "Баз.вал"
      VIEW-AS TEXT
     SIZE 5 BY .67 TOOLTIP "Фирма"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-host-description AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 41.63 BY .67 TOOLTIP "Фирма"
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE fi-nickname AS CHARACTER FORMAT "X(35)":U
     LABEL "Псевдоним"
      VIEW-AS TEXT
     SIZE 30.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-obj AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект"
      VIEW-AS TEXT
     SIZE 20 BY .67 TOOLTIP "Объект"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-obj-date AS DATE FORMAT "99/99/9999":U
     LABEL "Сегодня"
      VIEW-AS TEXT
     SIZE 11.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-obj-description AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 41.63 BY .67 TOOLTIP "Фирма"
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE fi-shift-date AS CHARACTER FORMAT "X(256)":U
     LABEL "Смена"
      VIEW-AS TEXT
     SIZE 10.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-shift-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер"
      VIEW-AS TEXT
     SIZE 2.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-shift-order AS CHARACTER FORMAT "X(256)":U
     LABEL "Порядок"
      VIEW-AS TEXT
     SIZE 2.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-user-login AS CHARACTER FORMAT "X(40)":U
     LABEL "Логин"
      VIEW-AS TEXT
     SIZE 30.25 BY .67 TOOLTIP "Логин"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-user-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 41.63 BY .67 TOOLTIP "Имя"
     FGCOLOR 1  NO-UNDO.
DEFINE IMAGE b-select-context
     FILENAME "cmp/btn-search.bmp":U
     SIZE 7.5 BY 2.5 TOOLTIP "Выбрать фирму, объект, группу меню (Alt-F10)".
DEFINE IMAGE IMAGE-1
     FILENAME "cmp/btn-off.bmp":U
     SIZE 7.5 BY 2.5.
DEFINE IMAGE IMAGE-10
     FILENAME "cmp/blank.bmp":U
     SIZE 7.5 BY 2.5.
DEFINE IMAGE IMAGE-11
     FILENAME "cmp/blank.bmp":U
     SIZE 7.5 BY 2.5.
DEFINE IMAGE IMAGE-12
     FILENAME "cmp/blank.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE IMAGE-13
     FILENAME "cmp/blank.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE IMAGE-14
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-15
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-16
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-17
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-18
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-19
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-2
     FILENAME "cmp/btn-str.bmp":U
     SIZE 7.5 BY 2.5.
DEFINE IMAGE IMAGE-20
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-21
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-22
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-23
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-24
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-25
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-26
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-27
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-28
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-29
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-3
     FILENAME "cmp/btn-shp.bmp":U
     SIZE 7.5 BY 2.5.
DEFINE IMAGE IMAGE-30
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-31
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-32
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-33
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-34
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-35
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-36
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-37
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-38
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-39
     FILENAME "cmp/blank.bmp":U
     SIZE 2.5 BY .75.
DEFINE IMAGE IMAGE-4
     FILENAME "cmp/btn-res.bmp":U
     SIZE 7.5 BY 2.5.
DEFINE IMAGE IMAGE-5
     FILENAME "cmp/btn-fin.bmp":U
     SIZE 7.5 BY 2.5.
DEFINE IMAGE IMAGE-54
     FILENAME "cmp/main.bmp":U TRANSPARENT
     SIZE 108.5 BY 24.13.
DEFINE IMAGE IMAGE-6
     FILENAME "cmp/btn-bge.bmp":U
     SIZE 7.5 BY 2.5.
DEFINE IMAGE IMAGE-7
     FILENAME "cmp/btn-adm.bmp":U
     SIZE 7.5 BY 2.5.
DEFINE IMAGE IMAGE-8
     FILENAME "cmp/blank.bmp":U
     SIZE 7.5 BY 2.5.
DEFINE IMAGE IMAGE-9
     FILENAME "cmp/blank.bmp":U
     SIZE 7.5 BY 2.5.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46.5 BY 2.38.
DEFINE RECTANGLE rect-db-user
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46.5 BY 3.42.
DEFINE RECTANGLE rect-host-obj
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46.5 BY 4.42.
DEFINE RECTANGLE rect-host-obj-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46.63 BY 4.42.
DEFINE RECTANGLE rect-image
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46.5 BY 2.46.
DEFINE VARIABLE t-obj-active AS LOGICAL INITIAL no
     LABEL "Активный"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.
DEFINE QUERY br-menu-item FOR
      temp-menu-item SCROLLING.
DEFINE BROWSE br-menu-item
  QUERY br-menu-item DISPLAY
      get-display-name(buffer temp-menu-item) @ v-show-display-name
    WITH NO-LABELS NO-ROW-MARKERS SIZE 60.38 BY 17.63
         BGCOLOR 8  ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE FRAME DEFAULT-FRAME
     ed-menu-item-name AT ROW 5.04 COL 1.13 NO-LABEL
     b-copy AT ROW 6.29 COL 58.38
     br-menu-item AT ROW 7.5 COL 1
     fi-user-name AT ROW 10.04 COL 61.13 COLON-ALIGNED NO-LABEL
     b-show-date AT ROW 11.58 COL 85
     t-obj-active AT ROW 14.13 COL 93.38
     fi-obj-description AT ROW 15.17 COL 61.13 COLON-ALIGNED NO-LABEL
     fi-host-description AT ROW 17.21 COL 61.13 COLON-ALIGNED NO-LABEL
     b-search-bar-code AT ROW 18.58 COL 105.25
     fi-bar-code AT ROW 18.75 COL 72.38 COLON-ALIGNED NO-LABEL
     b-open-gds AT ROW 19.67 COL 105.25
     fi-nickname AT ROW 8 COL 72.38 COLON-ALIGNED WIDGET-ID 114
     fi-user-login AT ROW 9.04 COL 72.38 COLON-ALIGNED
     fi-obj-date AT ROW 11.58 COL 70 COLON-ALIGNED
     fi-close-date AT ROW 11.58 COL 95 COLON-ALIGNED WIDGET-ID 120
     fi-shift-date AT ROW 12.63 COL 68 COLON-ALIGNED
     fi-shift-name AT ROW 12.63 COL 89 COLON-ALIGNED
     fi-shift-order AT ROW 12.63 COL 102.5 COLON-ALIGNED
     fi-obj AT ROW 14.13 COL 69 COLON-ALIGNED
     fi-host AT ROW 16.17 COL 68.13 COLON-ALIGNED
     fi-host-basecode-desc AT ROW 16.17 COL 97.75 COLON-ALIGNED
     fi-db-num AT ROW 17.79 COL 71.5 COLON-ALIGNED
     fi-gds-artic AT ROW 19.75 COL 70 COLON-ALIGNED
     fi-gds-name AT ROW 20.75 COL 68 COLON-ALIGNED
     fi-gds-qnty AT ROW 21.79 COL 69 COLON-ALIGNED
     fi-gds-price-sale AT ROW 21.79 COL 92.63 COLON-ALIGNED
     "Штрих код:" VIEW-AS TEXT
          SIZE 10.5 BY .67 AT ROW 18.75 COL 63 WIDGET-ID 130
     rect-db-user AT ROW 7.67 COL 62
     rect-host-obj AT ROW 13.79 COL 62
     rect-image AT ROW 5.04 COL 62
     IMAGE-1 AT ROW 1.79 COL 1.5 WIDGET-ID 2
     IMAGE-2 AT ROW 1.79 COL 10 WIDGET-ID 4
     IMAGE-3 AT ROW 1.79 COL 18.5 WIDGET-ID 6
     IMAGE-4 AT ROW 1.79 COL 27 WIDGET-ID 8
     IMAGE-5 AT ROW 1.79 COL 35.5 WIDGET-ID 10
     IMAGE-6 AT ROW 1.79 COL 43.88 WIDGET-ID 12
     IMAGE-7 AT ROW 1.79 COL 52.38 WIDGET-ID 14
     IMAGE-8 AT ROW 1.79 COL 60.88 WIDGET-ID 16
     IMAGE-9 AT ROW 1.79 COL 69.38 WIDGET-ID 18
     IMAGE-10 AT ROW 1.79 COL 77.88 WIDGET-ID 20
     IMAGE-11 AT ROW 1.79 COL 86.25 WIDGET-ID 22
     IMAGE-12 AT ROW 5.04 COL 58.38 WIDGET-ID 24
     IMAGE-13 AT ROW 5.04 COL 58.38 WIDGET-ID 26
         IMAGE-14 AT ROW 5.33 COL 63.5 WIDGET-ID 34
     IMAGE-15 AT ROW 5.33 COL 67 WIDGET-ID 44
     IMAGE-16 AT ROW 5.33 COL 70.5 WIDGET-ID 46
     IMAGE-17 AT ROW 5.33 COL 74 WIDGET-ID 48
     IMAGE-18 AT ROW 5.33 COL 77.5 WIDGET-ID 50
     IMAGE-19 AT ROW 5.33 COL 81 WIDGET-ID 52
     IMAGE-20 AT ROW 5.33 COL 84.5 WIDGET-ID 54
     IMAGE-21 AT ROW 5.33 COL 88 WIDGET-ID 56
     IMAGE-22 AT ROW 5.33 COL 91.5 WIDGET-ID 58
     IMAGE-23 AT ROW 5.33 COL 95 WIDGET-ID 36
     IMAGE-24 AT ROW 5.33 COL 98.5 WIDGET-ID 38
     IMAGE-25 AT ROW 5.33 COL 102 WIDGET-ID 40
     IMAGE-26 AT ROW 5.33 COL 105.5 WIDGET-ID 42
     IMAGE-27 AT ROW 6.42 COL 63.5 WIDGET-ID 60
     IMAGE-28 AT ROW 6.42 COL 67 WIDGET-ID 62
     IMAGE-29 AT ROW 6.42 COL 70.5 WIDGET-ID 64
     IMAGE-30 AT ROW 6.42 COL 74 WIDGET-ID 66
     IMAGE-31 AT ROW 6.42 COL 77.5 WIDGET-ID 68
     IMAGE-32 AT ROW 6.42 COL 81 WIDGET-ID 70
     IMAGE-33 AT ROW 6.42 COL 84.5 WIDGET-ID 72
     IMAGE-34 AT ROW 6.42 COL 88 WIDGET-ID 74
     IMAGE-35 AT ROW 6.42 COL 91.5 WIDGET-ID 76
     IMAGE-36 AT ROW 6.42 COL 95 WIDGET-ID 78
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 108.5 BY 24.13.
DEFINE FRAME DEFAULT-FRAME
     IMAGE-37 AT ROW 6.42 COL 98.5 WIDGET-ID 80
     IMAGE-38 AT ROW 6.42 COL 102 WIDGET-ID 82
     IMAGE-39 AT ROW 6.42 COL 105.38 WIDGET-ID 84
     RECT-1 AT ROW 11.25 COL 62 WIDGET-ID 116
     IMAGE-54 AT ROW 1 COL 1 WIDGET-ID 126
     rect-host-obj-2 AT ROW 18.38 COL 62 WIDGET-ID 128
     b-select-context AT ROW 1.79 COL 101 WIDGET-ID 132
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 108.5 BY 24.13.
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Trade House"
         HEIGHT             = 24.13
         WIDTH              = 108.25
         MAX-HEIGHT         = 42.42
         MAX-WIDTH          = 240
         VIRTUAL-HEIGHT     = 42.42
         VIRTUAL-WIDTH      = 240
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE C-Win = CURRENT-WINDOW.
ASSIGN
       ed-menu-item-name:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.
ASSIGN
       fi-db-num:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-1:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-10:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-11:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-12:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-14:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-15:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-16:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-17:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-18:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-19:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-2:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-20:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-21:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-22:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-23:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-24:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-25:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-26:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-27:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-28:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-29:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-3:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-30:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-31:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-32:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-33:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-34:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-35:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-36:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-37:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-38:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-39:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-4:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-5:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-6:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-7:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-8:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
ASSIGN
       IMAGE-9:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.
ON END-ERROR OF C-Win
OR ENDKEY OF C-Win ANYWHERE DO:
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF C-Win
DO:
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.
ON CHOOSE OF b-copy IN FRAME DEFAULT-FRAME
DO:
  run menu-item-copy-full-name in this-procedure .
END.
ON CHOOSE OF b-open-gds IN FRAME DEFAULT-FRAME
DO:
  assign
    fi-bar-code
  .
  run search-bar-code in this-procedure .
END.
ON CHOOSE OF b-search-bar-code IN FRAME DEFAULT-FRAME
DO:
  define variable v-bar-code as character no-undo .
  assign
    fi-bar-code
  .
  run search-bar-code in this-procedure .
  run str/bc-ab.p
    (input  this-procedure :handle
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  fi-bar-code
    ,output v-bar-code
    ) no-error .
  apply "entry" to fi-bar-code in frame DEFAULT-FRAME.
  run search-bar-code in this-procedure .
END.
ON CHOOSE OF b-show-date IN FRAME DEFAULT-FRAME
DO:
  define variable v-disp-date as date      no-undo .
  define variable v-ok        as logical   no-undo .
  assign
    v-disp-date = date(fi-obj-date :screen-value)
  .
  run gbl/d-inpday.w
    (input ?
    ,input "Календарь"
    ,input ""
    ,input ""
    ,input-output v-disp-date
    ,output v-ok
    ) .
END.
ON DEFAULT-ACTION OF br-menu-item IN FRAME DEFAULT-FRAME
DO:
  run menu-item-choose in this-procedure .
END.
ON MOUSE-SELECT-CLICK OF br-menu-item IN FRAME DEFAULT-FRAME
DO:
  if available temp-menu-item
  then do:
    if  temp-menu-item.item-type  = 's-m':U
    then do:
      run menu-item-choose in this-procedure .
    end.
  end.
END.
ON ROW-DISPLAY OF br-menu-item IN FRAME DEFAULT-FRAME
DO:
  if available temp-menu-item then do:
      assign
        v-show-display-name :fgcolor in browse br-menu-item = black_color
        v-show-display-name :bgcolor in browse br-menu-item = gray_color
      .
  end.
END.
ON VALUE-CHANGED OF br-menu-item IN FRAME DEFAULT-FRAME
DO:
    define buffer buf_menu-group for ub.menu-group .
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code       = v-cntxt-menu-code
        and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
      no-error .
    if available buf_menu-group
    then do:
      assign
        fi-menu-group-name = buf_menu-group.menu-group-name
      .
    end.
  run menu-item-display-full-name in this-procedure .
END.
ON RETURN OF fi-bar-code IN FRAME DEFAULT-FRAME
DO:
  run search-bar-code in this-procedure .
END.
ON ANY-KEY OF fi-bar-code IN FRAME DEFAULT-FRAME
DO:
  if lastkey = 308 then
    return no-apply.
END.
ASSIGN CURRENT-WINDOW                = C-Win
       THIS-PROCEDURE:CURRENT-WINDOW = C-Win.
assign
   parparentproc = this-procedure
.
PROCEDURE SetCurrentDirectoryA EXTERNAL "kernel32.dll"
:
    DEFINE INPUT  PARAMETER chrCurDir AS CHARACTER.
    DEFINE RETURN PARAMETER intResult AS LONG.
END PROCEDURE.
PROCEDURE OpenFile EXTERNAL "kernel32.dll" :
    DEFINE INPUT PARAMETER lpszFileName as MEMPTR .
    DEFINE INPUT-OUTPUT PARAMETER lpOpenBuff as MEMPTR .
    DEFINE INPUT PARAMETER fuMode as SHORT.
    DEFINE RETURN PARAMETER RetValue as SHORT .
END PROCEDURE .
on "ALT-F10":U of frame DEFAULT-FRAME anywhere
do:
  run trigger-select-context in this-procedure no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
end.
on alt-shift-f5 anywhere do:
  run logo in this-procedure .
end.
on mouse-select-click, selection of
b-select-context
do:
  run trigger-select-context in this-procedure no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
end.
on mouse-select-click, selection of
IMAGE-1  ,
IMAGE-2  ,
IMAGE-3  ,
IMAGE-4  ,
IMAGE-5  ,
IMAGE-6  ,
IMAGE-7  ,
IMAGE-8  ,
IMAGE-9  ,
IMAGE-10 ,
IMAGE-11 ,
IMAGE-12 ,
IMAGE-13 ,
IMAGE-14 ,
IMAGE-15 ,
IMAGE-16 ,
IMAGE-17 ,
IMAGE-18 ,
IMAGE-19 ,
IMAGE-20 ,
IMAGE-21 ,
IMAGE-22 ,
IMAGE-23 ,
IMAGE-24 ,
IMAGE-25 ,
IMAGE-26 ,
IMAGE-27 ,
IMAGE-28 ,
IMAGE-29 ,
IMAGE-30 ,
IMAGE-31 ,
IMAGE-32 ,
IMAGE-33 ,
IMAGE-34 ,
IMAGE-35 ,
IMAGE-36 ,
IMAGE-37 ,
IMAGE-38 ,
IMAGE-39
do:
  run choose-image in this-procedure
    (input self :private-data
    ) .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DEFAULT-FRAME
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-menu-item :SET-REPOSITIONED-ROW(4, "CONDITIONAL") .
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame DEFAULT-FRAME :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame DEFAULT-FRAME :height-chars)
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
    if frame DEFAULT-FRAME :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame DEFAULT-FRAME :height-chars)
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
            frame DEFAULT-FRAME :height = v-frame-height
          .
          if frame DEFAULT-FRAME :scrollable = true
          then do:
            assign
              frame DEFAULT-FRAME :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            C-Win :height = v-window-height
            C-Win :virtual-height = v-window-virtual-height
          .
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          assign
            C-Win :virtual-height = v-window-virtual-height
            C-Win :height = v-window-height
          .
          if frame DEFAULT-FRAME :scrollable = true
          then do:
            assign
              frame DEFAULT-FRAME :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame DEFAULT-FRAME :height = v-frame-height
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
      v-frame-height = frame DEFAULT-FRAME :height
      v-frame-virtual-height = frame DEFAULT-FRAME :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    assign
      v-window-height = C-Win :height
      v-window-virtual-height = C-Win :virtual-height
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
      v-field-group-handle = frame DEFAULT-FRAME :first-child
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
    do with frame DEFAULT-FRAME
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      assign
        C-Win :virtual-height = C-Win :virtual-height + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        C-Win :height = C-Win :height + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame DEFAULT-FRAME :scrollable = true
      then do:
        assign
          frame DEFAULT-FRAME :virtual-height = frame DEFAULT-FRAME :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame DEFAULT-FRAME :height = frame DEFAULT-FRAME :height + p-change-value
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
        frame DEFAULT-FRAME :height = frame DEFAULT-FRAME :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame DEFAULT-FRAME :scrollable = true
      then do:
        assign
          frame DEFAULT-FRAME :virtual-height = frame DEFAULT-FRAME :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        C-Win :height = C-Win :height + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        C-Win :virtual-height = C-Win :virtual-height + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
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
          ,input  string(frame DEFAULT-FRAME :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame DEFAULT-FRAME :height)
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
    if frame DEFAULT-FRAME :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame DEFAULT-FRAME :width
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
    if frame DEFAULT-FRAME :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame DEFAULT-FRAME :width
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
            frame DEFAULT-FRAME :width = v-frame-width
          .
          if frame DEFAULT-FRAME :scrollable = true
          then do:
            assign
              frame DEFAULT-FRAME :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            C-Win :width = v-window-width
            C-Win :virtual-width = v-window-virtual-width
          .
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          assign
            C-Win :virtual-width = v-window-virtual-width
            C-Win :width = v-window-width
          .
          if frame DEFAULT-FRAME :scrollable = true
          then do:
            assign
              frame DEFAULT-FRAME :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame DEFAULT-FRAME :width = v-frame-width
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
      v-frame-width = frame DEFAULT-FRAME :width
      v-frame-virtual-width = frame DEFAULT-FRAME :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    assign
      v-window-width = C-Win :width
      v-window-virtual-width = C-Win :virtual-width
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
      v-field-group-handle = frame DEFAULT-FRAME :first-child
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
    do with frame DEFAULT-FRAME
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      assign
        C-Win :virtual-width = C-Win :virtual-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        C-Win :width = C-Win :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame DEFAULT-FRAME :scrollable = true
      then do:
        assign
          frame DEFAULT-FRAME :virtual-width = frame DEFAULT-FRAME :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame DEFAULT-FRAME :width = v-frame-width + p-change-value
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
        frame DEFAULT-FRAME :width = frame DEFAULT-FRAME :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame DEFAULT-FRAME :scrollable = true
      then do:
        assign
          frame DEFAULT-FRAME :virtual-width = frame DEFAULT-FRAME :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        C-Win :width = C-Win :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        C-Win :virtual-width = C-Win :virtual-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
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
          ,input  string(frame DEFAULT-FRAME :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame DEFAULT-FRAME :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame DEFAULT-FRAME
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame DEFAULT-FRAME :height - v-diasize-resize-button :height
                  - 1
                  - (frame DEFAULT-FRAME :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame DEFAULT-FRAME :width - v-diasize-resize-button :width
                  - 1
                  - (frame DEFAULT-FRAME :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame DEFAULT-FRAME
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
      v-row-delta = v-new-row - frame DEFAULT-FRAME :height
      v-col-delta = v-new-col - frame DEFAULT-FRAME :width
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
            - frame DEFAULT-FRAME :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame DEFAULT-FRAME :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame DEFAULT-FRAME :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame DEFAULT-FRAME :height-chars
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
      v-diasize-current-frame-width  = frame DEFAULT-FRAME :width
      v-diasize-current-frame-height = frame DEFAULT-FRAME :height
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
    do with frame DEFAULT-FRAME
    :
      assign
        v-diasize-orig-frame-height = frame DEFAULT-FRAME :height
        v-diasize-orig-frame-width  = frame DEFAULT-FRAME :width
        v-diasize-browse-handle     = br-menu-item :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame DEFAULT-FRAME :first-child
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
on "CTRL-K":U anywhere do:
  run gbl/hotkey.p
    (input "calc":U
    ,input focus
    ).
end.
ON +, CURSOR-RIGHT OF br-menu-item IN FRAME DEFAULT-FRAME
DO:
  run menu-item-expand in this-procedure .
  run mainmenu-menu-item-open in this-procedure
    (input  temp-menu-item.item-code
    ) .
  return no-apply.
END.
ON -, CURSOR-LEFT OF br-menu-item IN FRAME DEFAULT-FRAME
DO:
  define buffer buf_temp-menu-item for temp-menu-item .
  if  available temp-menu-item
  and ( temp-menu-item.item-type = 'm-i':U
        or
        (temp-menu-item.item-type = 's-m':U
         and
         temp-menu-item.show-child = '+':U
        )
      )
  then do:
    find first buf_temp-menu-item
      where buf_temp-menu-item.item-code = temp-menu-item.parent-code
      no-error .
    if available buf_temp-menu-item
    then do:
      reposition br-menu-item to rowid rowid(buf_temp-menu-item) .
    end.
  end.
  run menu-item-collapse in this-procedure .
  run mainmenu-menu-item-open in this-procedure
    (input  temp-menu-item.item-code
    ) .
  return no-apply.
END.
on close of this-procedure
    do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-cctv'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-cctv
  ,output par-type
  ) no-error .
        is-cctv = lookup(par-is-cctv, "true,yes":U) > 0 .
        if is-cctv then
        do:
            v-vid-param =
                "SHOP_NUM=" + string(v-cntxt-obj-code) + chr(4) +
                "Login=" + fi-user-login + chr(4) +
                "THname=" + fi-nickname .
    run db-attr-value in this-procedure ( input v-cntxt-db-num
                                          , input 'mess-id-video':U
                                          , output v-db-attr-value
                                          , output v-db-attr-type
                                          ) no-error .
    assign
      v-mess-id = integer (v-db-attr-value) no-error.
    if v-mess-id = ?
      then v-mess-id = 0.
    v-vid-param = v-vid-param + chr(4) +
     "MESSAGE_ID=" + string (v-mess-id)
    .
    v-mess-id = v-mess-id + 1.
    run db-attr-write in this-procedure ( input v-cntxt-db-num
                                        , input 'mess-id-video':U
                                        , input string (v-mess-id)
                                        ) no-error .
            run trg/video-action.p (input 63,
                input v-vid-param,
                output v-vid-ok,
                output v-vid-mes) .
        end.
        run disable_ui .
    end.
on window-close of C-Win
do:
  apply 'close':U to this-procedure .
end.
on endkey, end-error of C-Win anywhere
    do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-cctv'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-cctv
  ,output par-type
  ) no-error .
        is-cctv = lookup(par-is-cctv, "true,yes":U) > 0 .
        if is-cctv then
        do:
            v-vid-param =
                "SHOP_NUM=" + string(v-cntxt-obj-code) + chr(4) +
                "Login=" + fi-user-login + chr(4) +
                "THname=" + fi-nickname .
    run db-attr-value in this-procedure ( input v-cntxt-db-num
                                          , input 'mess-id-video':U
                                          , output v-db-attr-value
                                          , output v-db-attr-type
                                          ) no-error .
    assign
      v-mess-id = integer (v-db-attr-value) no-error.
    if v-mess-id = ?
      then v-mess-id = 0.
    v-vid-param = v-vid-param + chr(4) +
     "MESSAGE_ID=" + string (v-mess-id)
    .
    v-mess-id = v-mess-id + 1.
    run db-attr-write in this-procedure ( input v-cntxt-db-num
                                        , input 'mess-id-video':U
                                        , input string (v-mess-id)
                                        ) no-error .
            run trg/video-action.p (input 63,
                input v-vid-param,
                output v-vid-ok,
                output v-vid-mes) .
        end.
        return no-apply .
    end.
pause 0 before-hide.
assign
  SESSION :SYSTEM-ALERT-BOXES = yes
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define variable v-sys-key     as character no-undo .
  define variable v-param-value as character no-undo .
  define variable v-param-type  as character no-undo .
  assign
    v-cntxt-developer = false
  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
  if v-sys-key = 'ExpertekIBS':U
  then do:
    assign
      v-cntxt-developer = true
    .
  end.
  run gbl/getconn.p
    (output v-connect-usr
    ,output v-connect-device
    ,output v-userio-id
    ) .
  RUN enable_UI.
    image-54:move-to-bottom().
  run fill-temp-image in this-procedure .
  CREATE MENU MENU-BAR-handle.
  C-Win :MENUBAR = MENU-BAR-handle.
  define variable v-user-select         as logical   no-undo .
  define variable v-cntxt-valid         as logical   no-undo .
  define variable v-cntxt-error-message as character no-undo .
  define variable v-cur-date-error-code as integer      no-undo.
  run gbl/actn-upd.p
      (input this-procedure
      ) no-error .
   if error-status :error
   then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при обновлении прав" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      undo, return no-apply return-value .
   end.
   define buffer buf_cd-events      for ub.cd-events .
   define variable v-version    as integer      no-undo.
   FIND LAST buf_cd-events NO-LOCK NO-ERROR.
   IF AVAILABLE buf_cd-events
   THEN DO:
      ASSIGN
         v-version = buf_cd-events.version
      .
      RELEASE buf_cd-events.
   END.
   ELSE DO:
      ASSIGN
         v-version = 0
      .
   END.
   run utl/cdevload.p ( INPUT THIS-PROCEDURE
                      , INPUT-OUTPUT v-version
                      ) .
   define buffer buf_sys-ctrl      for ub.sys-ctrl.
   find first buf_sys-ctrl no-lock.
   run gbl/menu-upd.p
      (input  this-procedure
      ,input  ?
      ,input  0
      ,input  buf_sys-ctrl.db-num
      ) no-error .
   if error-status :error
   then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при обновлении меню" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      undo, return no-apply return-value .
   end.
   release buf_sys-ctrl.
  run get-last-context in this-procedure
    (output v-cntxt-db-num
    ,output v-cntxt-user-id
    ,output v-cntxt-process-id
    ,output v-cntxt-password
    ,output v-cntxt-valid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-menu-code
    ,output v-cntxt-menu-group-code
    ,output v-cntxt-report-num
    ,output v-cntxt-quest-print
    ,output v-cntxt-inp-jewel
    ,output v-cntxt-gds-engl
    ,output v-cntxt-bc-price
    ,output v-cntxt-is-admin
    ) .
   if v-cntxt-valid = true
   then do:
      run gbl/cntxtchk.p
         (input  v-cntxt-db-num
         ,input  v-cntxt-user-id
         ,input  v-cntxt-menu-code
         ,input  v-cntxt-menu-group-code
         ,input  v-cntxt-level
         ,input  v-cntxt-host-code-obj
         ,input  v-cntxt-obj-type
         ,input  v-cntxt-obj-code
         ,input  v-cntxt-db-num-obj
         ,output v-cntxt-valid
         ,output v-cntxt-error-message
         ) .
   end.
   run gbl/code-upd.p(input  this-procedure)  no-error .
   if error-status :error
   then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при обновлении справочников" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      undo, return no-apply return-value .
   end.
   run gbl/verinfo.p.
   run utl/chgpsw.p (yes) no-error.
   if error-status:error
   then do:
      message return-value view-as alert-box.
      return error return-value .
   end.
  user-number:
  DO
  ON ERROR   UNDO user-number, RETRY user-number
  ON END-KEY UNDO user-number, RETURN:
      IF RETRY
      OR v-cntxt-valid = false
      then do:
         run select-context in this-procedure
            (input  false
            ,output v-user-select
            ) .
         if v-user-select <> true
         then do:
            return .
         end.
      end.
      define buffer buf_menu-group for ub.menu-group .
      find first buf_menu-group no-lock
         where buf_menu-group.menu-code       = v-cntxt-menu-code
            and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
         no-error .
      if not available buf_menu-group
      then do:
         message
            vss-workfile vss-revision vss-description skip
            "Ошибка при поиске группы пунктов меню" skip
            "Код группы пунктов меню" v-cntxt-menu-group-code skip
            view-as alert-box error .
         undo, return error return-value .
      end.
      define variable v-chk-usr-numa as logical   no-undo .
      define variable v-work-usr-num as integer   no-undo .
      run chk-usr-numa in this-procedure
         (output v-chk-usr-numa
         ) .
      if v-chk-usr-numa = true
      then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  buf_menu-group.menu-group-licence-param
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  yes
  ,output v-param-value
  ,output v-param-type
  ) no-error .
            if error-status :error
            then do:
            message
               vss-workfile vss-revision vss-description skip
               "Ошибка чтения конфигурационного параметра" buf_menu-group.menu-group-licence-param skip
               error-status :get-message(1) skip
               return-value skip
               view-as alert-box error .
            undo, return error return-value .
            end.
            run adm/isanybdy.p
            (input  true
            ,input  buf_menu-group.menu-code
            ,input  buf_menu-group.menu-group-id
            ,output v-work-usr-num
            ).
            if v-work-usr-num >= integer(v-param-value)
            then do:
               message
               "Превышено максимальное количество пользователей, работающих в группе меню" buf_menu-group.menu-group-description skip
               "Количество лицензий" integer(v-param-value) skip
               "Работает пользователей" v-work-usr-num skip
               return-value skip
               view-as alert-box error .
               assign
                  v-cntxt-valid = false
               .
               UNDO user-number, retry user-number.
            end.
      END.
  END.
  run create-dm-menu in this-procedure
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании меню" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  run logo in this-procedure .
  run disp-static in this-procedure
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры disp-static" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  run mainmenu-disp-mutable in this-procedure (
    output v-cur-date-error-code
  )  no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры mainmenu-disp-mutable" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if transaction = true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Активна транзакция" skip
      "В главном окне не должно быть активной транзакции" skip
      "Невозможно продолжить работу системы" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  run diasize_init in this-procedure .
  run load-tnved in this-procedure .
  run ver-movepar in this-procedure .
  if not this-procedure:persistent
  then do:
    wait-for close of this-procedure.
  end.
  os-delete value( string(v-cntxt-report-num) + ".srt" ) .
  os-delete value( string(v-cntxt-report-num) + ".whr" ) .
  os-delete value( "tmp_" + string(v-cntxt-report-num) + ".xml" ) .
  define variable v-out-dir as character no-undo .
  get-key-value section 'kassa-ibm':U key 'out':U value v-out-dir .
  if v-out-dir <> ? then do:
    if  substring(v-out-dir, length(v-out-dir), 1) <> '/':U
    and substring(v-out-dir, length(v-out-dir), 1) <> '\':U
    then do:
      assign
        v-out-dir = v-out-dir + '/':U
      .
    end.
    define buffer buf_scales for ub.scales .
    for each buf_scales no-lock
      where buf_scales.db-num = v-cntxt-db-num
    on error undo, next
    :
      os-delete value( v-out-dir + 'plu':U + string(v-cntxt-report-num) +
                      '.':U + string(buf_scales.scales-num, '999':U ) ) .
    end.
  end.
  define variable RetOpenFile     as integer   no-undo .
  define variable lp_filename     as memptr    no-undo .
  define variable lp_openbuff     as memptr    no-undo .
  define variable Mode            as integer   no-undo .
  assign
    Mode                    = 512
    set-size( lp_FileName ) = 128
    set-size( lp_OpenBuff ) = 288
  .
  if  get-size( lp_FileName ) <> 0
  and get-size( lp_OpenBuff ) <> 0
  then do:
    assign
      put-string( lp_FileName, 1 ) = string( session:temp-directory
                                          + "rpt" + string( v-cntxt-report-num ) )
    .
    run openfile
      (input lp_filename
      ,input-output lp_openbuff
      ,input mode
      ,output retopenfile
      ) .
    assign
      put-string( lp_FileName, 1 ) = string( session:temp-directory
                                          + "plt" + string( v-cntxt-report-num )
                                          )
    .
    run openfile
      (input lp_filename
      ,input-output lp_openbuff
      ,input mode
      ,output retopenfile
      ) .
    assign
      set-size( lp_OpenBuff ) = 0
      set-size( lp_FileName ) = 0
    .
  end.
  run delete-dm-menu in this-procedure
    no-error .
END.
PROCEDURE bc-brief :
  define input parameter v-bar-code as integer   no-undo .
  define variable v-r-b-abbr   as character no-undo .
  define variable v-doc-num    as character no-undo .
  define variable v-price-sale as decimal   no-undo .
  define variable v-road-tax   as decimal   no-undo .
  define variable v-excise     as decimal   no-undo .
  define variable v-fact-qnty  as decimal   no-undo .
  define variable v-qnty-type  as character no-undo .
  define variable v-qnty-recid as recid     no-undo .
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods .
  do
  on error undo, return error return-value
  :
    assign
      fi-gds-artic      = '':U
      fi-gds-name       = '':U
      fi-gds-qnty       = '':U
      fi-gds-price-sale = '':U
    .
    find buf_bar-code no-lock
      where buf_bar-code.b-code = v-bar-code
      no-error .
    if available buf_bar-code
    then do:
      find buf_goods no-lock
        where buf_goods.gds-code = buf_bar-code.gds-code
        no-error .
      if available buf_goods
      then do:
        assign
          fi-gds-artic = substitute('&1 &2 &3':U
                                   ,buf_goods.artic
                                   ,buf_goods.prod-type
                                   ,buf_goods.prod-code
                                   )
          fi-gds-name  = buf_goods.gds-name
        .
      end.
      if v-cntxt-level = 'object':U
      then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-abbr in g#library
  (input  v-cntxt-host-code-obj
  ,output v-r-b-abbr
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  buf_bar-code.b-code
  ,input  0
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeqnt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  buf_bar-code.b-code
  ,input  0
  ,output v-fact-qnty
  ,output v-qnty-type
  ,output v-qnty-recid
  )  .
        assign
          fi-gds-price-sale = substitute('&1 &2'
                                        ,v-price-sale
                                        ,v-r-b-abbr
                                        )
          fi-gds-qnty       = substitute('&1 &2'
                                        ,v-fact-qnty
                                        ,buf_goods.unit-base
                                        )
        .
      end.
    end.
    do with frame DEFAULT-FRAME:
       assign
         fi-gds-artic     :screen-value = fi-gds-artic
         fi-gds-name      :screen-value = fi-gds-name
         fi-gds-qnty      :screen-value = fi-gds-qnty
         fi-gds-price-sale:screen-value = fi-gds-price-sale
         fi-gds-artic     :visible      = yes
         fi-gds-name      :visible      = yes
         fi-gds-qnty      :visible      = yes
         fi-gds-price-sale:visible      = yes
         .
     end.
  end.
END PROCEDURE.
PROCEDURE check-load-menu :
define output parameter p-locked as logical no-undo .
define output parameter p-new    as logical no-undo .
define buffer buf_menu-head for ub.menu-head .
do
on error undo, return error
:
    find first buf_menu-head
         where buf_menu-head.menu-code = 0
         exclusive-lock
         no-error
         no-wait
         .
    if not available buf_menu-head
    AND locked buf_menu-head then do:
         assign
            p-locked = TRUE
         .
    end.
    ELSE do:
      IF v-menu-control-number <> buf_menu-head.control-number then do:
         assign
            p-new = TRUE
         .
      end.
    END.
end.
END PROCEDURE.
PROCEDURE chk-db-num-0 :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-current-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
    if v-current-db-num = 0
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-firm-db-num :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-current-db-num as integer   no-undo .
  define variable v-firm-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run frmdbnum in g#library2
  (input  v-cntxt-host-code-obj
  ,output v-firm-db-num
  )  .
    if v-current-db-num = v-firm-db-num
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-holding :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-holding as character no-undo .
  define variable par-type  as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-holding
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра holding" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  v-holding = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-bge :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-bge as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-bge':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-bge
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-bge" skip
        view-as alert-box error .
      return error.
    end.
    if  v-is-bge = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-mmr :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-mmr as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-mmr':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-mmr
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-mmr" skip
        view-as alert-box error .
      return error.
    end.
    if  v-is-mmr = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-dc :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-dc  as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-dc':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-dc
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-dc" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  v-is-dc = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-edi :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-edi as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-edi':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-edi
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-edi" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  v-is-edi = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-ef :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-ef  as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ef':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-ef
  ,output par-type
  ) no-error .
    if error-status :error
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      if par-type <> 'L':U then do:
        message
          vss-workfile vss-revision vss-description skip
          "Неправильный тип конфигурационного параметра is-ef" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if  v-is-ef = 'yes':U
      then do:
        assign
          p-enable-item = true
        .
      end.
      else do:
        assign
          p-enable-item = false
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-fbr :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-fbr as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fbr':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-fbr
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-fbr" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  v-is-fbr = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-fin :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-fin as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-fin
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-fin" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  v-is-fin = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-off :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-off as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-off':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-off
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-off" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  v-is-off = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-previous-menu-group :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-enable-item = (v-cntxt-previous-menu-group-id <> '':U)
    .
  end.
END PROCEDURE.
PROCEDURE chk-is-ptrl :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-ptrl as character no-undo .
  define variable par-type  as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-ptrl
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-ptrl" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  v-is-ptrl = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-res :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-res as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-res':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-res
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-res" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  v-is-res = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-shp :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-shp as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-shp':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-shp
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-shp" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  v-is-shp = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-str :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-str as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-str':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-str
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-str" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  v-is-str = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-thpos :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-thpos  as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-thpos':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-thpos
  ,output par-type
  ) no-error .
    if error-status :error
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      if par-type <> 'L':U then do:
        message
          vss-workfile vss-revision vss-description skip
          "Неправильный тип конфигурационного параметра is-thpos" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if  v-is-thpos = 'yes':U
      then do:
        assign
          p-enable-item = true
        .
      end.
      else do:
        assign
          p-enable-item = false
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE chk-is-wth :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-wth as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-wth':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-wth
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра is-wth" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  v-is-wth = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
procedure chk-is-addcharges :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-add as character no-undo .
  define variable par-type   as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-addch':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-add
  ,output par-type
  ) no-error .
    if v-is-add = 'yes'
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
procedure chk-is-not-addcharges :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-is-add as character no-undo .
  define variable par-type   as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-addch':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-add
  ,output par-type
  ) no-error .
    if v-is-add = 'yes'
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      assign
        p-enable-item = true
      .
    end.
  end.
end procedure.
procedure chk-obj-type-shop :
  define output parameter p-enable-item as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if v-cntxt-obj-type = 'маг':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
end procedure.
PROCEDURE chk-menu-group-valid :
  define input  parameter p-menu-group-id as character no-undo .
  define output parameter p-enable-item   as logical   no-undo .
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code     = v-cntxt-menu-code
        and buf_menu-group.menu-group-id = p-menu-group-id
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        "Код меню" v-cntxt-menu-code skip
        "Идентификатор группы" p-menu-group-id skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usmgrava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-user-id
  ,input  buf_menu-group.menu-code
  ,input  buf_menu-group.menu-group-code
  ,input  v-cntxt-level
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output p-enable-item
  )  .
  end.
END PROCEDURE.
PROCEDURE chk-num-cd :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-num-cd as character no-undo .
  define variable par-type as character no-undo .
  define variable v-num    as integer      no-undo.
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'num-cd':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-num-cd
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'I':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра num-cd" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      v-num = integer(v-num-cd)
      no-error
    .
    IF error-status:error = TRUE THEN
    do:
       assign
         v-num = 0
       .
    end.
    if v-num > 0
    or v-num-cd = "":U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-num-scls :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-num-scls as character no-undo .
  define variable par-type   as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'num-scls':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-num-scls
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'I':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра num-scls" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if integer(v-num-scls) > 0
    OR v-num-scls = ""
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-orders :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-orders as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'orders':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-orders
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра orders" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  v-orders = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-rtexch :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-rtexch as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'rtexch':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-rtexch
  ,output par-type
  ) no-error .
    if error-status :error
    then do:
      assign
        v-rtexch = 'no':U
      .
    end.
    if  v-rtexch = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-usr-numa :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-usr-numa as character no-undo .
  define variable par-type   as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'usr-numa':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-usr-numa
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра usr-numa" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-usr-numa = 'yes':U
    then do:
      assign
        p-enable-item = true
      .
    end.
    else do:
      assign
        p-enable-item = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE chk-usr-numa-no :
  define output parameter p-enable-item as logical   no-undo .
  define variable v-usr-numa as character no-undo .
  define variable par-type as character no-undo .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'usr-numa':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-usr-numa
  ,output par-type
  ) no-error .
    if error-status :error
    or par-type <> 'L':U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип конфигурационного параметра usr-numa" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if v-usr-numa = 'yes':U
    then do:
      assign
        p-enable-item = false
      .
    end.
    else do:
      assign
        p-enable-item = true
      .
    end.
  end.
END PROCEDURE.
PROCEDURE choose-image :
  define input  parameter p-private-data as character no-undo .
  define buffer buf_temp-image for temp-image .
  do
  on error undo, return error return-value
  :
    find first buf_temp-image
      where buf_temp-image.image-code = integer(p-private-data)
      no-error .
    if not available buf_temp-image
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Не найдено описание изображения с кодом" p-private-data skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    case entry(1, buf_temp-image.image-procedure, chr(44))
    :
      when 'int':U
      then do:
        run run-procedure-int in g#dm-menu-handle
          (input entry(2, buf_temp-image.image-procedure, chr(44))
          ) .
      end.
    end case.
  end.
END PROCEDURE.
PROCEDURE choose-menu-item :
  do
  on error undo, return error return-value
  :
    if v-menu-item-choose = true
    then do:
      message
        "Вы уже выбрали пункт меню" skip
        view-as alert-box information .
      undo, return error .
    end.
    assign
      v-menu-item-choose = true
    .
  end.
END PROCEDURE.
PROCEDURE create-dm-menu :
  if not valid-handle (g#dm-menu-handle)
  then do:
    run gbl/dm-menu.p persistent set g#dm-menu-handle
      ( input  this-procedure
      , input  menu-bar-handle
      , input  v-cntxt-menu-code
      , input  v-cntxt-menu-group-code
      , output v-menu-control-number
      ) no-error.
    if error-status :error
    then do:
      message
        "Ошибка вызова процедуры dm-menu.p" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return error.
    end.
  end.
END PROCEDURE.
PROCEDURE delete-dm-menu :
  if valid-handle (g#dm-menu-handle)
  then do:
    run clear-menu in g#dm-menu-handle no-error .
    if error-status :error
    then do:
      message
        "Ошибка при очистке меню" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return error .
    end.
    delete procedure g#dm-menu-handle .
    assign
      g#dm-menu-handle = ?
    .
  end.
END PROCEDURE.
PROCEDURE delete-menu-item :
  define input  parameter p-item-code as integer   no-undo .
  define buffer buf_temp-menu-item for temp-menu-item .
  do
  on error undo, return error return-value
  :
    for each buf_temp-menu-item
      where buf_temp-menu-item.parent-code = p-item-code
    on error undo, return error return-value
    :
      if buf_temp-menu-item.item-type = 's-m':U
      then do:
        run delete-menu-item in this-procedure
          (input buf_temp-menu-item.item-code
          ) .
      end.
      delete buf_temp-menu-item .
    end.
  end.
END PROCEDURE.
PROCEDURE deselect-menu-item :
  do
  on error undo, return error return-value
  :
    assign
      v-menu-item-choose = false
    .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE disp-static :
  define variable v-host-name like ub.clients.obj-name no-undo .
  define variable v-curr-abbr like ub.currency.curr-abbr no-undo .
  define variable v-retail like ub.sysconf.ord-prt no-undo .
  define buffer buf_clients for ub.clients .
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    assign
      fi-db-num             = string(v-cntxt-db-num)
      fi-user-login         = '':U
      fi-user-name          = '':U
      fi-host               = '':U
      fi-host-basecode-desc = '':U
      fi-host-description   = '':U
      fi-obj                = '':U
      fi-obj-description    = '':U
      t-obj-active          = ?
      fi-menu-group-name    = '':U
    .
    define buffer buf_user-account for ub.user-account .
    define buffer buf_user-login   for ub.user-login .
    find first buf_user-account no-lock
      where buf_user-account.user-id = v-cntxt-user-id
      no-error .
    if available buf_user-account
    then do:
      assign
        fi-user-name = substitute('&1 &2 &3':U
                                ,buf_user-account.last-name
                                ,buf_user-account.first-name
                                ,buf_user-account.second-name
                                )
      .
    end.
    find first buf_user-login no-lock
      where buf_user-login.db-num  = v-cntxt-db-num
        and buf_user-login.user-id = v-cntxt-user-id
      no-error .
    if available buf_user-login
    then do:
      assign
        fi-user-login = buf_user-login.user-login
        fi-nickname   = usrnickf(buf_user-login.user-id)
      .
    end.
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code       = v-cntxt-menu-code
        and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
      no-error .
    if available buf_menu-group
    then do:
      assign
        fi-menu-group-name = buf_menu-group.menu-group-name
      .
      run menu-item-display-full-name in this-procedure .
    end.
    if v-cntxt-level = 'firm':U
    or v-cntxt-level = 'object':U
    then do:
      assign
        fi-host = substitute('&1 &2':U
                            ,'орг':U
                            ,v-cntxt-host-code-obj
                            )
      .
      find buf_clients no-lock
        where buf_clients.obj-type = 'орг':U
          and buf_clients.obj-code = v-cntxt-host-code-obj
        no-error .
      if available buf_clients
      then do:
        assign
          fi-host-description = buf_clients.obj-name
        .
      end.
      define variable v-base-code as integer   no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output v-base-code
  )  .
      define buffer buf_currency for ub.currency .
      find buf_currency no-lock
        where buf_currency.curr-code = v-base-code
        .
      assign
        fi-host-basecode-desc = buf_currency.curr-abbr
      .
    end.
    if v-cntxt-level = 'object':U
    then do:
      assign
        fi-obj  = substitute('&1 &2':U
                            ,v-cntxt-obj-type
                            ,v-cntxt-obj-code
                            )
      .
      find buf_clients no-lock
        where buf_clients.obj-type = v-cntxt-obj-type
          and buf_clients.obj-code = v-cntxt-obj-code
        no-error .
      if available buf_clients
      then do:
        assign
          fi-obj-description = buf_clients.obj-name
        .
      end.
      define variable v-obj-active as logical   no-undo .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'active=request':U
  ,output v-obj-active
  )  .
      assign
        t-obj-active = v-obj-active
      .
    end.
    do with frame DEFAULT-FRAME
    :
      assign
        fi-nickname:screen-value = fi-nickname
        fi-user-login:screen-value = fi-user-login
        fi-user-name:screen-value = fi-user-name
        fi-nickname:visible = yes
        fi-user-login:visible = yes
        fi-user-name:visible = yes
         .
      if v-cntxt-level = 'global':U
      then do:
        assign
          fi-host               :visible = no
          fi-host-basecode-desc :visible = no
          fi-obj                :visible = no
          fi-obj-description    :visible = no
          t-obj-active          :visible = no
          fi-host-description            = "Без фирмы объекта."
          fi-host-description   :screen-value = fi-host-description
          fi-host-description   :visible = yes
        .
      end.
      if v-cntxt-level = 'firm':U
      then do:
        assign
          fi-host              :screen-value = fi-host
          fi-host-basecode-desc:screen-value = fi-host-basecode-desc
          fi-host-description  :screen-value = fi-host-description
          fi-host              :visible      = yes
          fi-host-basecode-desc:visible      = yes
          fi-host-description  :visible      = yes
          fi-obj               :visible      = no
          fi-obj-description   :visible      = no
          t-obj-active         :visible      = no
         .
      end.
      if v-cntxt-level = 'object':U
      then do:
        assign
          fi-host              :screen-value = fi-host
          fi-host-basecode-desc:screen-value = fi-host-basecode-desc
          fi-host-description  :screen-value = fi-host-description
          fi-obj               :screen-value = fi-obj
          fi-obj-description   :screen-value = fi-obj-description
          t-obj-active         :screen-value = string(t-obj-active)
          fi-host              :visible      = yes
          fi-host-basecode-desc:visible      = yes
          fi-host-description  :visible      = yes
          fi-obj               :visible      = yes
          fi-obj-description   :visible      = yes
          t-obj-active         :visible      = yes
           .
      end.
    end.
    define variable v-arm-title as character no-undo .
    run set-mainmenu-title in this-procedure
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при изменении заголовка окна" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return error.
    end.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY ed-menu-item-name fi-user-name t-obj-active fi-obj-description
          fi-host-description fi-nickname fi-user-login fi-obj-date
          fi-close-date fi-shift-date fi-shift-name fi-shift-order fi-obj
          fi-host fi-host-basecode-desc fi-gds-artic fi-gds-name fi-gds-qnty
          fi-gds-price-sale
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE rect-db-user rect-host-obj rect-image IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4
         IMAGE-5 IMAGE-6 IMAGE-7 IMAGE-8 IMAGE-9 IMAGE-10 IMAGE-11 IMAGE-12 IMAGE-13
         IMAGE-14 IMAGE-15 IMAGE-16 IMAGE-17 IMAGE-18 IMAGE-19 IMAGE-20
         IMAGE-21 IMAGE-22 IMAGE-23 IMAGE-24 IMAGE-25 IMAGE-26 IMAGE-27
         IMAGE-28 IMAGE-29 IMAGE-30 IMAGE-31 IMAGE-32 IMAGE-33 IMAGE-34
         IMAGE-35 IMAGE-36 IMAGE-37 IMAGE-38 IMAGE-39 RECT-1 rect-host-obj-2
         b-select-context ed-menu-item-name b-copy br-menu-item b-show-date
         b-search-bar-code fi-bar-code b-open-gds fi-nickname fi-user-login
         fi-obj-date fi-close-date fi-shift-date fi-shift-name fi-shift-order
         fi-obj fi-host fi-host-basecode-desc fi-gds-artic
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  run mainmenu-menu-item-open in this-procedure (input 0) .
  VIEW C-Win.
END PROCEDURE.
PROCEDURE fill-temp-image :
  define buffer buf_temp-image for temp-image .
  do
  on error undo, return error return-value
  :
    for each buf_temp-image
    on error undo, return error return-value
    :
      delete buf_temp-image .
    end.
    do with frame DEFAULT-FRAME
    :
      create buf_temp-image . assign buf_temp-image.image-code = 1  buf_temp-image.image-handle = image-1  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 2  buf_temp-image.image-handle = image-2  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 3  buf_temp-image.image-handle = image-3  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 4  buf_temp-image.image-handle = image-4  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 5  buf_temp-image.image-handle = image-5  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 6  buf_temp-image.image-handle = image-6  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 7  buf_temp-image.image-handle = image-7  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 8  buf_temp-image.image-handle = image-8  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 9  buf_temp-image.image-handle = image-9  :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 10 buf_temp-image.image-handle = image-10 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 11 buf_temp-image.image-handle = image-11 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 12 buf_temp-image.image-handle = image-12 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 13 buf_temp-image.image-handle = image-13 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 14 buf_temp-image.image-handle = image-14 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 15 buf_temp-image.image-handle = image-15 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 16 buf_temp-image.image-handle = image-16 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 17 buf_temp-image.image-handle = image-17 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 18 buf_temp-image.image-handle = image-18 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 19 buf_temp-image.image-handle = image-19 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 20 buf_temp-image.image-handle = image-20 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 21 buf_temp-image.image-handle = image-21 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 22 buf_temp-image.image-handle = image-22 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 23 buf_temp-image.image-handle = image-23 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 24 buf_temp-image.image-handle = image-24 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 25 buf_temp-image.image-handle = image-25 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 26 buf_temp-image.image-handle = image-26 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 27 buf_temp-image.image-handle = image-27 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 28 buf_temp-image.image-handle = image-28 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 29 buf_temp-image.image-handle = image-29 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 30 buf_temp-image.image-handle = image-30 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 31 buf_temp-image.image-handle = image-31 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 32 buf_temp-image.image-handle = image-32 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 33 buf_temp-image.image-handle = image-33 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 34 buf_temp-image.image-handle = image-34 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 35 buf_temp-image.image-handle = image-35 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 36 buf_temp-image.image-handle = image-36 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 37 buf_temp-image.image-handle = image-37 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 38 buf_temp-image.image-handle = image-38 :handle .
      create buf_temp-image . assign buf_temp-image.image-code = 39 buf_temp-image.image-handle = image-39 :handle .
    end.
    for each buf_temp-image
    :
      assign
        buf_temp-image.image-handle :private-data = string(buf_temp-image.image-code)
      .
    end.
  end.
END PROCEDURE.
PROCEDURE get-bc-price :
  define output parameter p-bc-price as logical no-undo .
  do
  on error undo, return error
  :
    assign
      p-bc-price = v-cntxt-bc-price
    .
  end.
END PROCEDURE.
PROCEDURE get-db-num :
  define output parameter p-db-num like ub.sys-ctrl.db-num no-undo.
  define buffer buf_sys-ctrl for ub.sys-ctrl.
  find first buf_sys-ctrl no-lock.
  assign
    p-db-num = buf_sys-ctrl.db-num
  .
END PROCEDURE.
PROCEDURE get-gds-engl :
  define output parameter p-gds-engl as logical no-undo .
  do
  on error undo, return error
  :
    assign
      p-gds-engl = v-cntxt-gds-engl
    .
  end.
END PROCEDURE.
PROCEDURE get-inp-jewel :
  define output parameter p-inp-jewel as logical no-undo .
  do
  on error undo, return error
  :
    assign
      p-inp-jewel = v-cntxt-inp-jewel
    .
  end.
END PROCEDURE.
PROCEDURE get-news :
define output parameter p-news as logical no-undo .
  do
  on error undo, return error
  :
     p-news = no.
  end.
end procedure.
PROCEDURE get-esys :
define output parameter p-esys as logical no-undo .
  do
  on error undo, return error
  :
     p-esys = no.
  end.
end procedure.
PROCEDURE get-last-context :
  define output parameter p-cntxt-db-num                  as integer   no-undo .
  define output parameter p-cntxt-user-id                 as character no-undo .
  define output parameter p-cntxt-process-id              as integer   no-undo .
  define output parameter p-cntxt-password                as character no-undo .
  define output parameter p-cntxt-valid                   as logical   no-undo .
  define output parameter p-cntxt-level                   as character no-undo .
  define output parameter p-cntxt-host-code-obj           as integer   no-undo .
  define output parameter p-cntxt-obj-type                as character no-undo .
  define output parameter p-cntxt-obj-code                as integer   no-undo .
  define output parameter p-cntxt-db-num-obj              as integer   no-undo .
  define output parameter p-cntxt-menu-code               as integer   no-undo .
  define output parameter p-cntxt-menu-group-code         as integer   no-undo .
  define output parameter p-cntxt-report-num              as integer   no-undo .
  define output parameter p-cntxt-quest-print             as logical   no-undo .
  define output parameter p-cntxt-inp-jewel               as logical   no-undo .
  define output parameter p-cntxt-gds-engl                as logical   no-undo .
  define output parameter p-cntxt-bc-price                as logical   no-undo .
  define output parameter p-cntxt-is-admin                as logical   no-undo .
  define buffer buf_user-login for ub.user-login .
  do
  on error undo, return error return-value
  :
    assign
      p-cntxt-user-id  = p-user-id
      p-cntxt-password = p-password
    .
    run gbl/getprcid.p
      (output p-cntxt-process-id
      ) .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    assign
      p-cntxt-db-num = buf_sys-ctrl.db-num
    .
    run gbl/cntxtget.p
      (input  p-cntxt-db-num
      ,input  p-cntxt-user-id
      ,output p-cntxt-valid
      ,output p-cntxt-menu-code
      ,output p-cntxt-menu-group-code
      ,output p-cntxt-level
      ,output p-cntxt-host-code-obj
      ,output p-cntxt-obj-type
      ,output p-cntxt-obj-code
      ) .
    if p-cntxt-level = 'object':U
    then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-cntxt-obj-type
  ,input  p-cntxt-obj-code
  ,output p-cntxt-db-num-obj
  ) no-error .
    end.
    else do:
      assign
        p-cntxt-db-num-obj = ?
      .
    end.
    assign
      p-cntxt-report-num = ibs.th.gbl.gbl-inipar:cntxt-report-num .
    .
    find first buf_user-login no-lock
      where buf_user-login.db-num  = p-cntxt-db-num
        and buf_user-login.user-id = p-cntxt-user-id
      no-error .
    if available buf_user-login
    then do:
      assign
            p-cntxt-quest-print = buf_user-login.quest-print
            p-cntxt-is-admin    = buf_user-login.user-administrator
      .
    end.
  end.
END PROCEDURE.
PROCEDURE get-quest-print :
  define output parameter p-quest-print as logical no-undo .
  do
  on error undo, return error
  :
    assign
      p-quest-print = v-cntxt-quest-print
    .
  end.
END PROCEDURE.
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
  on error undo, return error
  :
    assign
      p-report-num = v-cntxt-report-num
    .
  end.
END PROCEDURE.
PROCEDURE get-user-password :
  define output parameter p-password as character no-undo .
  do
  on error undo, return error
  :
    assign
      p-password = v-cntxt-password
    .
  end.
END PROCEDURE.
PROCEDURE get-userid :
  define output parameter p-user-id as character    no-undo .
  do
  on error undo, return error
  :
    assign
      p-user-id = v-cntxt-user-id
    .
  end.
END PROCEDURE.
PROCEDURE image-display-as-min :
define buffer x-gds-obj-prop for ub.gds-obj-prop.
define buffer x-gds-obj      for ub.gds-obj.
define variable l-exist-as-min as log no-undo .
  do
  on error undo, return error return-value
  :
   l-exist-as-min = false  .
   for  EACH x-gds-obj-prop no-lock WHERE
             x-gds-obj-prop.gdop-assort-min = true AND
             x-gds-obj-prop.obj-code = v-cntxt-obj-code  AND
             x-gds-obj-prop.obj-type = v-cntxt-obj-type  ,
                EACH x-gds-obj no-lock WHERE
                     x-gds-obj.gds-code = x-gds-obj-prop.gds-code AND
                     x-gds-obj.obj-code = x-gds-obj-prop.obj-code AND
                     x-gds-obj.obj-type = x-gds-obj-prop.obj-type and
                     x-gds-obj.fact-qnty < x-gds-obj-prop.gdop-min-stock
                     :
      l-exist-as-min = true .
      leave.
    end.
    run image-display-update-visible in this-procedure
      (input l-exist-as-min
      ,input 'as-min':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-cd :
  do
  on error undo, return error return-value
  :
    def var l-exist-cd as log no-undo .
    define variable v-send as logical no-undo .
    define buffer buf_BatchProcess for ub.batchProcess .
    assign
    l-exist-cd =
        can-find (first  buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = 'gds':U
          and buf_BatchProcess.bp_status     = 'N':U
                )
        or
        can-find (first  buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = 'goa':U
          and buf_BatchProcess.bp_status     = 'N':U
                )
        or
        can-find (first  buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = 'dcard':U
          and buf_BatchProcess.bp_status     = 'N':U
                )
        or
        can-find (first  buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = 'slr':U
          and buf_BatchProcess.bp_status     = 'N':U
                )
        or
        can-find (first  buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = 'cshr':U
          and buf_BatchProcess.bp_status     = 'N':U
                )
    .
    run str/mrkt-ts.p
                (input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input '':U
                ,output v-send) no-error .
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'str/mrkt-ts.p':U skip
        error-status:get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      l-exist-cd = l-exist-cd or v-send
    .
    run image-display-update-visible in this-procedure
      (input l-exist-cd
      ,input 'cd':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-curses :
  do
  on error undo, return error return-value
  :
    def var l-exist-curses as log no-undo .
    assign
      l-exist-curses =
          can-find (first ub.curr-shop where
                          ub.curr-shop.obj-type = v-cntxt-obj-type and
                          ub.curr-shop.obj-code = v-cntxt-obj-code and
                          year (ub.curr-shop.exch-date) = 9999 no-lock)
    .
    run image-display-update-visible in this-procedure
      (input l-exist-curses
      ,input 'curses':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-in-ov :
  define variable l-exist-in-ov as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'exist-in-ov=request'
  ,output l-exist-in-ov
  ) no-error .
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        error-status:get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run image-display-update-visible in this-procedure
      (input l-exist-in-ov
      ,input 'in-ov':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-nwsc :
  do
  on error undo, return error return-value
  :
    define variable l-exist-nwsc as log no-undo .
    define buffer buf_batchprocess for ub.batchprocess.
    find first buf_batchprocess no-lock where
              buf_batchprocess.bp_type = 'coll':u
          and buf_batchprocess.bp_status = 'N':U no-error .
    assign
      l-exist-nwsc = available buf_batchprocess
    .
    run image-display-update-visible in this-procedure
      (input l-exist-nwsc
      ,input 'nwsc':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-ord-do :
  do
  on error undo, return error return-value
  :
    define variable l-exist-ord-do as logical no-undo .
    assign
    l-exist-ord-do   = false .
 if   can-find (first ub.ord-doc no-lock  where ub.ord-doc.cycle-day > 0
        and ub.ord-doc.host-code = v-cntxt-host-code-obj
        and (integer(today - ub.ord-doc.doc-date) >= ub.ord-doc.cycle-day)
        and ub.ord-doc.order-type = 1
        and ub.ord-doc.status_ <> 'новый':U
        )
         or
       can-find ( first ub.ord-doc no-lock  where
           ub.ord-doc.host-code = v-cntxt-host-code-obj
        and ub.ord-doc.order-type = 4
        and ub.ord-doc.status_ <> 'новый':U
         )
        then do:
         l-exist-ord-do = true .
        end.
    assign
      l-exist-ord-do =   can-find (first ub.ord-doc where ub.ord-doc.cycle-day > 0
                          and ub.ord-doc.host-code = v-cntxt-host-code-obj
                          and (integer(today - ub.ord-doc.doc-date) >= ub.ord-doc.cycle-day)
                          and ub.ord-doc.order-type = 1
                          and ub.ord-doc.status_ <> 'новый':U
                          no-lock)
    .
    run image-display-update-visible in this-procedure
      (input l-exist-ord-do
      ,input 'ord-do':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-ovrval :
  do
  on error undo, return error return-value
  :
    define variable l-exist-ovrval as log no-undo init false .
    define buffer buf_price-doc for ub.price-doc.
    find first buf_price-doc no-lock
      where buf_price-doc.obj-type  = v-cntxt-obj-type
        and buf_price-doc.obj-code  = v-cntxt-obj-code
        and buf_price-doc.status_   = 'приказ':U
    no-error .
    if available buf_price-doc then do:
      assign
        l-exist-ovrval = yes
      .
    end.
    run image-display-update-visible in this-procedure
      (input l-exist-ovrval
      ,input 'ovrval':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-priper :
  do
  on error undo, return error return-value
  :
    define variable l-exist-priper as log no-undo .
    define buffer buf_trn-doc for ub.trn-doc.
    define buffer buf_clients for ub.clients.
    find first buf_trn-doc no-lock
      where buf_trn-doc.obj-type      = v-cntxt-obj-type
        and buf_trn-doc.obj-code      = v-cntxt-obj-code
        and buf_trn-doc.internal      = yes
        and buf_trn-doc.doc-type      = 'при':U
        and buf_trn-doc.ext-doc-type  = 'iv':U
        and buf_trn-doc.status_       = 'накл':U
        and buf_trn-doc.flag_         = yes no-error .
      if available buf_trn-doc then do:
          assign
            l-exist-priper = yes
          .
      end.
    run image-display-update-visible in this-procedure
      (input l-exist-priper
      ,input 'priper':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-sales :
  do
  on error undo, return error return-value
  :
    define variable v-notes as character no-undo .
    define variable  l-exist-ck-gds as logical no-undo .
    define variable  l-exist-fls-ck as logical no-undo .
    define variable  l-exist-gds-sl as logical no-undo .
    define variable not-all-saled-chk    as logical   no-undo .
    define variable not-all-normal-chk   as logical   no-undo .
    define variable not-all-inkas-closed as logical   no-undo .
    if v-cntxt-obj-type = 'маг':U
    and v-cntxt-db-num-obj = v-cntxt-db-num then do:
      run str/chk-inf.p
        (input  this-procedure
        ,input  v-cntxt-host-code-obj
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input  no
        ,input  no
        ,input  ?
        ,output v-notes
        ,output l-exist-ck-gds
        ,output l-exist-fls-ck
        ,output l-exist-gds-sl
        ) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" 'str/chk-inf.p':U skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
    end.
    run image-display-update-visible in this-procedure
      (input l-exist-ck-gds
      ,input 'ck-gds':U
      ) .
    run image-display-update-visible in this-procedure
      (input l-exist-fls-ck
      ,input 'fls-ck':U
      ) .
    run image-display-update-visible in this-procedure
      (input l-exist-gds-sl
      ,input 'gds-sl':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-scales :
  do
  on error undo, return error return-value
  :
    def var l-exist-scales as log no-undo .
    assign
      l-exist-scales =
          can-find (first ub.scales-gds where
                          ub.scales-gds.obj-type = v-cntxt-obj-type and
                          ub.scales-gds.obj-code = v-cntxt-obj-code and
                          ub.scales-gds.to-send = yes no-lock)
    .
    run image-display-update-visible in this-procedure
      (input l-exist-scales
      ,input 'scales':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-twotpl :
define variable l-exist-twotpl as logical   no-undo .
define buffer buf_BatchProcess for ub.BatchProcess  .
l-exist-twotpl =   can-find (first  buf_BatchProcess no-lock
        where buf_BatchProcess.bp_type       = 'twotpl':U
          and buf_BatchProcess.bp_status     = 'N':U
                ) .
    run image-display-update-visible in this-procedure
      (input l-exist-twotpl
      ,input 'twotpl':U
      ) .
END PROCEDURE.
PROCEDURE image-display-update-visible :
  define input  parameter p-image-visible as logical   no-undo .
  define input  parameter p-image-name    as character no-undo .
  define buffer buf_temp-check-image for temp-check-image .
  do
  on error undo, return error return-value
  :
    if p-image-visible <> true
    then do:
      find first buf_temp-check-image
        where buf_temp-check-image.check-image-name = p-image-name
        no-error .
      if available buf_temp-check-image
      then do:
        find first temp-image where
                   temp-image.image-file-name = buf_temp-check-image.check-image-image-file-name no-error .
         if available temp-image then do:
          assign
            temp-image.image-visible = false
            temp-image.image-handle :sensitive = false
            temp-image.image-handle :visible = false
          .
        end.
        delete buf_temp-check-image .
      end.
    end.
    else do:
      find first buf_temp-check-image
        where buf_temp-check-image.check-image-name = p-image-name
        no-error .
      if available buf_temp-check-image
      then do:
        find first temp-image where
                   temp-image.image-file-name = buf_temp-check-image.check-image-image-file-name no-error .
         if available temp-image then do:
          assign
            temp-image.image-handle :sensitive = true
          .
        end.
        end.
    end.
  end.
END PROCEDURE.
PROCEDURE image-display-vozper :
  do
  on error undo, return error return-value
  :
    define variable l-exist-vozper as log no-undo .
    define buffer buf_trn-doc for ub.trn-doc.
    define buffer buf_clients for ub.clients.
    _trn-doc:
    for each buf_trn-doc no-lock
      where
        (   buf_trn-doc.obj-type      = v-cntxt-obj-type
        and buf_trn-doc.obj-code      = v-cntxt-obj-code
        and buf_trn-doc.internal      = yes
        and buf_trn-doc.doc-type      = 'возврат':U
        and buf_trn-doc.ext-doc-type  = 'rv':U
        and buf_trn-doc.status_       = 'накл':U
        )
        or
        (   buf_trn-doc.obj-type      = v-cntxt-obj-type
        and buf_trn-doc.obj-code      = v-cntxt-obj-code
        and buf_trn-doc.internal      = yes
        and buf_trn-doc.doc-type      = 'возврат':U
        and buf_trn-doc.ext-doc-type  = 'rv':U
        and buf_trn-doc.status_       = 'разрешен':U
        )
    :
          assign
            l-exist-vozper = yes
          .
          leave _trn-doc.
    end .
    run image-display-update-visible in this-procedure
      (input l-exist-vozper
      ,input 'vozper':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-wth :
  do
  on error undo, return error return-value
  :
    define variable v-notes as character no-undo .
    DEFINE VARIABLE  l-exist-all-ck-wth as logical no-undo .
    DEFINE VARIABLE  l-exist-err-ck-wth as logical no-undo .
    DEFINE VARIABLE  l-exist-awth   as logical no-undo .
    DEFINE VARIABLE  l-exist-ck-wth as logical no-undo .
    if v-cntxt-obj-type = 'маг':U
    and v-cntxt-db-num = v-cntxt-db-num-obj then do:
      run str/chk-winf.p (
                      input THIS-PROCEDURE
                      ,input v-cntxt-host-code-obj
                      ,input v-cntxt-obj-type
                      ,input v-cntxt-obj-code
                      ,input no
                      ,input no
                      ,input ?
                      ,output v-notes
                      ,output l-exist-ck-wth
                      ,output l-exist-err-ck-wth
                      ,output l-exist-awth) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры" 'str/chk-winf.p':U skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
    end.
    assign
      l-exist-ck-wth = l-exist-ck-wth or l-exist-err-ck-wth
    .
    run image-display-update-visible in this-procedure
      (input l-exist-ck-wth
      ,input 'ck-wth':U
      ) .
    run image-display-update-visible in this-procedure
      (input l-exist-awth
      ,input 'awth':U
      ) .
  end.
END PROCEDURE.
PROCEDURE load-tnved :
  do
  on error undo, return error return-value
  :
    define variable custvalue   as character no-undo .
    define variable custtype    as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-custm':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output custvalue
  ,output custtype
  ) no-error .
    if custvalue = "yes"
    then do:
      if not can-find (first tt-tnved)
      then do:
        get-key-value section "custom" key "rep-tnved" value tnved-fn.
        run ref/l-tnved.p
          (input search(tnved-fn)
          ).
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE logo :
do with frame DEFAULT-FRAME:
  if  v-logo-image-visible
  and v-cntxt-level = 'object':U
  then do:
    assign
      v-logo-image-visible = false
    .
  end.
end.
END PROCEDURE.
PROCEDURE mainmenu-disp-mutable :
define output parameter p-cur-date-error-code   as integer          no-undo.
  define variable v-obj-shift           as logical      no-undo .
  define variable v-shift-date          as date         no-undo .
  define variable v-shift-num           as integer      no-undo .
  define variable v-shift-name          as character    no-undo .
  define variable v-result              as integer      no-undo .
  define variable v-time                as integer      no-undo .
  do
  on error undo, return error return-value
  :
    assign
      file-info :file-name = '.'
    .
    if v-work-file = ""
    then do:
      assign
        v-work-file = file-info :full-pathname
      .
    end.
    else do:
      if v-work-file <> file-info :full-pathname
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Рабочая директория изменилась" skip
          "Новая рабочая директория" file-info :full-pathname skip
          "Старая рабочая директория" v-work-file skip
          view-as alert-box error .
        run SetCurrentDirectoryA
          (input  v-work-file
          ,output v-result
          ).
        assign
          file-info :file-name = '.'
        .
        if v-work-file = file-info :full-pathname
        then do:
          message
            "Рабочая директория восстановлена" skip
            "Текущая рабочая директория" file-info :full-pathname skip
            view-as alert-box information .
        end.
        else do:
          message
            "Рабочая директория не восстановлена" skip
            "Текущая рабочая директория" file-info :full-pathname skip
            "Пожалуйста завершите работу программы" skip
            view-as alert-box error .
        end.
      end.
    end.
    do with frame DEFAULT-FRAME
    :
      assign
        fi-obj-date           = ?
        fi-close-date         = ?
        fi-shift-date         = ?
        fi-shift-name         = '':U
        fi-shift-order        = '':U
      .
        if v-cntxt-level = 'global':U
        or v-cntxt-level = 'firm':U
        then do:
            run cur-time in this-procedure (
                output fi-obj-date
              , output v-time ) .
            assign
                fi-shift-date :visible      = no
                fi-shift-name :visible      = no
                fi-shift-order:visible      = no
                b-show-date   :visible      = no
                fi-obj-date   :screen-value = string(fi-obj-date,"99/99/9999":U)
                fi-obj-date   :visible      = yes
            .
        end.
        if v-cntxt-level = 'object':U
        then do:
            run adm/cur-date.w (
                  input this-procedure
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input '':u
                , output p-cur-date-error-code
            ) no-error .
            if error-status :error
            then do:
                message
                "Ошибка установки текущей даты на объекте!"
                view-as alert-box error.
                undo, return error.
            end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output fi-obj-date
  ) no-error .
            if error-status :error
            then do:
                message
                "Текущая дата не установлена!"
                view-as alert-box error.
                undo, return error.
            end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'shift-on=request'
  ,output v-obj-shift
  ) no-error .
            if error-status :error
            then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при запуске процедуры objat" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            return.
            end.
            if v-obj-shift = true
            then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
                if error-status :error
                then do:
                    assign
                        fi-shift-date         = ?
                        fi-shift-name         = '':U
                        fi-shift-order        = '':U
                    .
                end.
                else do:
                    assign
                        fi-shift-date         = string(v-shift-date, '99/99/9999':U)
                        fi-shift-name         = v-shift-name
                        fi-shift-order        = string(v-shift-num)
                    .
                end.
                assign
                    fi-shift-date:screen-value  = fi-shift-date
                    fi-shift-name:screen-value  = fi-shift-name
                    fi-shift-order:screen-value = fi-shift-order
                    fi-shift-date:visible       = yes
                    fi-shift-name:visible       = yes
                    fi-shift-order:visible      = yes
                .
            end.
            else do:
               assign
                  fi-shift-date :visible       = no
                  fi-shift-name :visible       = no
                  fi-shift-order:visible       = no
               .
            end.
            assign
                fi-obj-date:screen-value = string(fi-obj-date, '99/99/9999':U)
                fi-obj-date:visible      = yes
                b-show-date:visible      = yes
            .
            run proc-check-RVD in this-procedure .
            run proc-check-place-imp in this-procedure .
        end.
        run proc-fi-close-date in this-procedure
            ( output fi-close-date  ) .
        if fi-close-date = ? then hide fi-close-date.
        else assign
                fi-close-date :screen-value  = string(fi-close-date, '99/99/9999':U)
                fi-close-date :visible       = yes
             .
    end.
    run update-image in this-procedure
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обновлении картинок" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return error.
    end.
  end.
END PROCEDURE.
PROCEDURE mainmenu-menu-item-clear :
  define buffer buf_temp-menu-item for temp-menu-item .
  do
  on error undo, return error return-value
  :
    for each buf_temp-menu-item
    on error undo, return error return-value
    :
      delete buf_temp-menu-item .
    end.
  end.
END PROCEDURE.
PROCEDURE mainmenu-menu-item-create :
  define input  parameter p-item-code      as integer   no-undo .
  define input  parameter p-item-type      as character no-undo .
  define input  parameter p-item-name      as character no-undo .
  define input  parameter p-item-id        as character no-undo .
  define input  parameter p-item-procedure as character no-undo .
  define input  parameter p-parent-code    as integer   no-undo .
  define input  parameter p-show-menu-item as logical   no-undo .
  define buffer buf_temp-menu-item for temp-menu-item .
  define buffer buf_parent_temp-menu-item for temp-menu-item .
  define variable v-parent-full-name as character no-undo .
  do
  on error undo, return error return-value
  :
    IF CAN-FIND ( FIRST buf_temp-menu-item
                  WHERE buf_temp-menu-item.item-code = p-item-code
                  NO-LOCK
                ) THEN RETURN.
    create buf_temp-menu-item .
    assign
      buf_temp-menu-item.item-code      = p-item-code
      buf_temp-menu-item.item-type      = p-item-type
      buf_temp-menu-item.item-name      = p-item-name
      buf_temp-menu-item.item-id        = p-item-id
      buf_temp-menu-item.item-procedure = p-item-procedure
      buf_temp-menu-item.parent-code    = p-parent-code
      buf_temp-menu-item.show-menu-item = p-show-menu-item
    .
    find first buf_parent_temp-menu-item
      where buf_parent_temp-menu-item.item-code = buf_temp-menu-item.parent-code
      no-error .
    if not available buf_parent_temp-menu-item
    then do:
      assign
        buf_temp-menu-item.num-level = 0
        v-parent-full-name           = ""
      .
    end.
    else do:
      assign
        buf_temp-menu-item.num-level = buf_parent_temp-menu-item.num-level + 1
        v-parent-full-name           = buf_parent_temp-menu-item.full-name
      .
      if buf_parent_temp-menu-item.show-menu-item = false
      then do:
        assign
          buf_temp-menu-item.show-menu-item = false
        .
      end.
    end.
    assign
      buf_temp-menu-item.show-child   = ""
      buf_temp-menu-item.display-name = replace(buf_temp-menu-item.item-name
                                               ,"&"
                                               ,""
                                               )
      buf_temp-menu-item.full-name    = v-parent-full-name
                                      + (if v-parent-full-name <> ""
                                         then '/':U
                                         else '':U
                                        )
                                      + replace(buf_temp-menu-item.item-name
                                               ,"&"
                                               ,""
                                               )
    .
    if buf_temp-menu-item.item-type = 's-m':U
    then do:
      assign
        buf_temp-menu-item.show-child = '+':U
      .
    end.
    define variable v-item-value     as logical   no-undo .
    define variable v-procedure-type as character no-undo .
    define variable v-item-procedure as character no-undo .
    if buf_temp-menu-item.item-type = 'm-t':U
    then do:
      assign
        v-procedure-type = entry(1, buf_temp-menu-item.item-procedure, chr(44))
        v-item-procedure = entry(2, buf_temp-menu-item.item-procedure, chr(44))
      .
      case v-procedure-type
      :
        when 'int':U
        then do:
          run value(v-item-procedure) in g#dm-menu-handle
            (input  'get':U
            ,input-output v-item-value
            ) .
        end.
        when 'ext':U
        then do:
          run value(v-item-procedure)
            (input  'get':U
            ,input-output v-item-value
            ) .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Код пункта меню" buf_temp-menu-item.item-code skip
            "Неизвестный тип процедуры" v-procedure-type skip
            "Процедура" v-item-procedure skip
            view-as alert-box error .
        end.
      end case .
      if v-item-value = true
      then do:
        assign
          buf_temp-menu-item.display-name = '*':U + ' ':U + buf_temp-menu-item.display-name
        .
      end.
      else do:
        assign
          buf_temp-menu-item.display-name = '_':U + ' ':U + buf_temp-menu-item.display-name
        .
      end.
    end.
    if buf_temp-menu-item.item-type = 'r-l':U
    then do:
      assign
        buf_temp-menu-item.display-name = fill(" ", buf_temp-menu-item.num-level * 2)
                                        + fill('-', 80)
        buf_temp-menu-item.full-name    = ""
      .
    end.
  end.
END PROCEDURE.
PROCEDURE mainmenu-menu-item-create-parent :
  define input  parameter p-parent-code as integer   no-undo .
  define buffer buf_temp-menu-item      for temp-menu-item .
  define buffer buf_menu-item           for ub.menu-item .
  define buffer buf_temp-menu-item-open for temp-menu-item-open .
  do
  on error undo, return error return-value
  :
    find first buf_temp-menu-item
      where buf_temp-menu-item.item-code = p-parent-code
      no-error .
    if not available buf_temp-menu-item
    then do:
      find first buf_menu-item no-lock
        where buf_menu-item.menu-code = v-cntxt-menu-code
          and buf_menu-item.item-code = p-parent-code
        no-error .
      if not available buf_menu-item
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Ошибка при поиске пункта меню" skip
          "menu-code" v-cntxt-menu-code skip
          "item-code" p-parent-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      run mainmenu-menu-item-create-parent in this-procedure
        (input  buf_menu-item.parent-code
        ) .
      find first buf_temp-menu-item
        where buf_temp-menu-item.item-code = buf_menu-item.parent-code
        .
      assign
        buf_temp-menu-item.show-child = '-':U
      .
      find first buf_temp-menu-item-open
        where buf_temp-menu-item-open.item-code = buf_temp-menu-item.item-code
        no-error .
      if not available buf_temp-menu-item-open
      then do:
        create buf_temp-menu-item-open .
        assign
          buf_temp-menu-item-open.item-code = buf_temp-menu-item.item-code
        .
      end.
      run proc-create-menu-item in g#dm-menu-handle
        (input  buf_menu-item.parent-code
        ,input  ?
        ,input  false
        ,input  true
        ) .
    end.
  end.
END PROCEDURE.
PROCEDURE mainmenu-menu-item-open :
  define input  parameter p-item-code as integer   no-undo .
  define buffer buf_temp-menu-item for temp-menu-item .
  define variable v-item-id as character no-undo .
  do
  on error undo, return error return-value
  :
    open query br-menu-item
      for each temp-menu-item
        where temp-menu-item.show-menu-item = true
      by temp-menu-item.item-code .
    if p-item-code <> 0
    then do:
      find first buf_temp-menu-item
        where buf_temp-menu-item.item-code = p-item-code
        no-error .
      if  available buf_temp-menu-item
      and buf_temp-menu-item.show-menu-item = true
      then do:
        reposition br-menu-item to rowid rowid(buf_temp-menu-item) .
      end.
    end.
    run menu-item-display-full-name in this-procedure .
  end.
END PROCEDURE.
PROCEDURE mainmenu-set-menu-toggle :
  define input  parameter p-item-code  as integer   no-undo .
  define input  parameter p-item-value as logical   no-undo .
  define buffer buf_temp-menu-item for temp-menu-item .
  do
  on error undo, return error return-value
  :
    find first buf_temp-menu-item
      where buf_temp-menu-item.item-code = p-item-code
      no-error .
    if available buf_temp-menu-item
    then do:
      if p-item-value = true
      then do:
        assign
          substring(buf_temp-menu-item.display-name, 1, 1) = '*':U
        .
      end.
      else do:
        assign
          substring(buf_temp-menu-item.display-name, 1, 1) = '_':U
        .
      end.
    end.
    else do:
      message
        "Пункт меню не найден" skip
        p-item-code skip
        view-as alert-box error .
    end.
  end.
END PROCEDURE.
PROCEDURE mainmenu-show-item :
  define input  parameter p-item-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run mainmenu-menu-item-create-parent in this-procedure
      (input  p-item-code
      ) .
    run mainmenu-menu-item-open in this-procedure
      (input p-item-code
      ) .
  end.
END PROCEDURE.
PROCEDURE mainmenu-start-item :
  define input  parameter p-item-code as integer   no-undo .
  define buffer buf_menu-user-call for ubflt.menu-user-call .
  define buffer buf_temp-menu-item for temp-menu-item .
  define buffer buf_menu-item      for ub.menu-item .
  do
  on error undo, return error return-value
  :
    assign
      v-menu-user-call-rowid = ?
    .
    run mainmenu-menu-item-create-parent in this-procedure
      (input  p-item-code
      ) .
    find first buf_temp-menu-item
      where buf_temp-menu-item.item-code = p-item-code
      no-error .
    if not available buf_temp-menu-item
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Не найден пункт меню с кодом" p-item-code skip
        view-as alert-box error .
      return .
    end.
    define buffer buf_menu-group for ub.menu-group .
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code       = v-cntxt-menu-code
        and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
      no-error .
    if available buf_menu-group and buf_menu-group.menu-group-id eq "adm"
    then
       run trg/userlog.p (
                input 'run-proc'
                , input ('Выбран пункт меню '
                + buf_temp-menu-item.full-name +  '"' + chr(3) + buf_temp-menu-item.item-procedure )
                , input ?
                , input ?
                , input "") no-error.
    define variable v-sys-time-mjd as decimal   no-undo .
    define variable v-arm-title    as character no-undo .
    run gbl/getustat.p
      (input  v-userio-id
      ,output v-sys-time-mjd
      ,output v-userio-ai-read
      ,output v-userio-ai-write
      ,output v-userio-bi-read
      ,output v-userio-bi-write
      ,output v-userio-db-access
      ,output v-userio-db-read
      ,output v-userio-db-write
      ) .
    define variable v-menu-user-call-id as integer   no-undo .
    assign
      v-menu-user-call-id = dynamic-next-value( "s-menu-user-call":U, "ubflt":U)
    .
    find first buf_menu-user-call exclusive-lock
      where buf_menu-user-call.db-num                 = v-cntxt-db-num
        and buf_menu-user-call.user-id                = v-cntxt-user-id
        and buf_menu-user-call.stop-menu-user-call-id = 0
      no-error .
    if available buf_menu-user-call
    then do:
      assign
        buf_menu-user-call.stop-mjd               = v-sys-time-mjd
        buf_menu-user-call.stop-menu-user-call-id = v-menu-user-call-id
      .
      assign
        v-menu-user-call-id = dynamic-next-value( "s-menu-user-call":U, "ubflt":U)
      .
    end.
    create buf_menu-user-call .
    assign
      buf_menu-user-call.db-num                 = v-cntxt-db-num
      buf_menu-user-call.menu-user-call-id      = v-menu-user-call-id
      buf_menu-user-call.user-id                = v-cntxt-user-id
      buf_menu-user-call.menu-code              = v-cntxt-menu-code
      buf_menu-user-call.start-mjd              = v-sys-time-mjd
      buf_menu-user-call.stop-mjd               = 0
      buf_menu-user-call.stop-menu-user-call-id = 0
      buf_menu-user-call.menu-code              = v-cntxt-menu-code
      buf_menu-user-call.item-id                = buf_temp-menu-item.item-id
      buf_menu-user-call.cntxt-level            = v-cntxt-level
      buf_menu-user-call.cntxt-host-code        = v-cntxt-host-code-obj
      buf_menu-user-call.cntxt-obj-type         = v-cntxt-obj-type
      buf_menu-user-call.cntxt-obj-code         = v-cntxt-obj-code
      buf_menu-user-call.item-procedure         = buf_temp-menu-item.item-procedure
      buf_menu-user-call.full-name              = buf_temp-menu-item.full-name
      buf_menu-user-call.param-value            = ''
      buf_menu-user-call.userio-ai-read         = 0
      buf_menu-user-call.userio-ai-write        = 0
      buf_menu-user-call.userio-bi-read         = 0
      buf_menu-user-call.userio-bi-write        = 0
      buf_menu-user-call.userio-db-access       = 0
      buf_menu-user-call.userio-db-read         = 0
      buf_menu-user-call.userio-db-write        = 0
      buf_menu-user-call.connect-usr            = string(v-connect-usr)
      buf_menu-user-call.connect-device         = v-connect-device
    .
    assign
      v-menu-user-call-rowid = rowid(buf_menu-user-call)
    .
  end.
END PROCEDURE.
PROCEDURE mainmenu-stop-item :
  define buffer buf_menu-user-call for ubflt.menu-user-call .
  define variable v-sys-time-mjd         as decimal   no-undo .
  define variable v-new-userio-ai-read   as decimal   no-undo .
  define variable v-new-userio-ai-write  as decimal   no-undo .
  define variable v-new-userio-bi-read   as decimal   no-undo .
  define variable v-new-userio-bi-write  as decimal   no-undo .
  define variable v-new-userio-db-access as decimal   no-undo .
  define variable v-new-userio-db-read   as decimal   no-undo .
  define variable v-new-userio-db-write  as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    if v-menu-user-call-rowid = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка" skip
        "Неопределенное значение указателя v-menu-user-call-rowid" skip
        "Работа программы будет продолжена" skip
        view-as alert-box error .
      return .
    end.
    do transaction
    on error undo, return error return-value
    :
      find first buf_menu-user-call exclusive-lock
        where rowid(buf_menu-user-call) = v-menu-user-call-rowid
        no-error .
      if not available buf_menu-user-call
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Ошибка при поиске записи buf_menu-user-call" skip
          "Неверное значение указателя v-menu-user-call-rowid" skip
          "Работа программы будет продолжена" skip
          view-as alert-box error .
        return .
      end.
      run gbl/getustat.p
        (input  v-userio-id
        ,output v-sys-time-mjd
        ,output v-new-userio-ai-read
        ,output v-new-userio-ai-write
        ,output v-new-userio-bi-read
        ,output v-new-userio-bi-write
        ,output v-new-userio-db-access
        ,output v-new-userio-db-read
        ,output v-new-userio-db-write
        ) .
      define variable v-menu-user-call-id as integer   no-undo .
      assign
        v-menu-user-call-id = dynamic-next-value( "s-menu-user-call":U, "ubflt":U)
      .
      assign
        buf_menu-user-call.stop-mjd               = v-sys-time-mjd
        buf_menu-user-call.stop-menu-user-call-id = v-menu-user-call-id
        buf_menu-user-call.userio-ai-read         = v-new-userio-ai-read
                                                  - v-userio-ai-read
        buf_menu-user-call.userio-ai-write        = v-new-userio-ai-write
                                                  - v-userio-ai-write
        buf_menu-user-call.userio-bi-read         = v-new-userio-bi-read
                                                  - v-userio-bi-read
        buf_menu-user-call.userio-bi-write        = v-new-userio-bi-write
                                                  - v-userio-bi-write
        buf_menu-user-call.userio-db-access       = v-new-userio-db-access
                                                  - v-userio-db-access
        buf_menu-user-call.userio-db-read         = v-new-userio-db-read
                                                  - v-userio-db-read
        buf_menu-user-call.userio-db-write        = v-new-userio-db-write
                                                  - v-userio-db-write
      .
    end.
  end.
END PROCEDURE.
PROCEDURE mainmenu_getcntxt :
  define output parameter p-cntxt-db-num        as integer   no-undo .
  define output parameter p-cntxt-user-id       as character no-undo .
  define output parameter p-cntxt-level         as character no-undo .
  define output parameter p-cntxt-host-code-obj as integer   no-undo .
  define output parameter p-cntxt-obj-type      as character no-undo .
  define output parameter p-cntxt-obj-code      as integer   no-undo .
  define output parameter p-cntxt-db-num-obj    as integer   no-undo .
  define output parameter p-cntxt-is-admin      as logical   no-undo .
  do
  on error undo, return error
  :
    assign
      p-cntxt-db-num        = v-cntxt-db-num
      p-cntxt-user-id       = v-cntxt-user-id
      p-cntxt-level         = v-cntxt-level
      p-cntxt-host-code-obj = v-cntxt-host-code-obj
      p-cntxt-obj-type      = v-cntxt-obj-type
      p-cntxt-obj-code      = v-cntxt-obj-code
      p-cntxt-db-num-obj    = v-cntxt-db-num-obj
      p-cntxt-is-admin      = v-cntxt-is-admin
    .
  end.
END PROCEDURE.
PROCEDURE menu-item-choose :
    define variable v-procedure-parameter as character no-undo .
    define variable v-load                as logical      no-undo.
    define variable v-new                 as logical      no-undo.
    define variable v-cur-date-error-code as integer      no-undo.
    define buffer buf_menu-head    for ub.menu-head.
do
on error undo, return error return-value
:
    run check-load-menu IN THIS-PROCEDURE
        ( OUTPUT v-load
        , output v-new
        ) .
    IF v-load = TRUE then do:
        message
            "Производится загрузка меню другим пользователем." SKIP
            "Для корректной работы системы необходимо подождать."
        view-as alert-box.
        run waitfram-show in this-procedure ( input "Происходит загрузка меню. Ждите..." ).
        REPEAT :
            find first buf_menu-head
            where buf_menu-head.menu-code = 0
            exclusive-lock
            no-error
            no-wait
            .
            IF AVAILABLE buf_menu-head THEN DO:
            run waitfram-hide in this-procedure .
            release buf_menu-head.
            run delete-dm-menu in this-procedure
                no-error .
            run create-dm-menu in this-procedure
                no-error .
            if error-status :error
            then do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при создании меню" skip
                    error-status :get-message(1) skip
                    return-value skip
                view-as alert-box error .
                undo, return error return-value .
            end.
            RETURN.
            END.
            pause 10 no-message.
        END.
    end.
    IF v-new then do:
        message
            "Другой пользователь произвел перезагрузку меню." SKIP
            "Для корректной работы меню будет обновлено."
        view-as alert-box.
        run delete-dm-menu in this-procedure
            no-error .
        run create-dm-menu in this-procedure
            no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании меню" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
            undo, return error return-value .
        end.
        RETURN.
    end.
    if available temp-menu-item
    then do:
        case temp-menu-item.item-type
        :
            when 'm-i':U or
            when 'm-t':U
            then do:
            if num-entries(temp-menu-item.item-procedure, chr(44)) > 2
            then do:
                assign
                v-procedure-parameter = entry(3, temp-menu-item.item-procedure, chr(44))
                .
            end.
            else do:
                assign
                v-procedure-parameter = '':U
                .
            end.
            run dm-menu-choose-item in g#dm-menu-handle
                (input  temp-menu-item.item-type
                ,input  temp-menu-item.item-code
                ,input  entry(1, temp-menu-item.item-procedure, chr(44))
                ,input  entry(2, temp-menu-item.item-procedure, chr(44))
                ,input  v-procedure-parameter
                ) .
            if temp-menu-item.item-type = 'm-t':U
            then do:
                display
                get-display-name(buffer temp-menu-item) @ v-show-display-name
                with browse br-menu-item .
            end.
            end.
            when 's-m':U
            then do:
            case temp-menu-item.show-child
            :
                when '+':U
                then do:
                run menu-item-expand in this-procedure .
                end.
                when '-':U
                then do:
                run menu-item-collapse in this-procedure .
                end.
                otherwise do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Внутренняя ошибка" skip
                    "Неизвестное значение поля show-child" skip
                    "temp-menu-item.show-child" temp-menu-item.show-child skip
                    view-as alert-box error .
                end.
            end case .
            run mainmenu-menu-item-open in this-procedure
                (input  temp-menu-item.item-code
                ) .
            end.
        end case .
    end.
end.
END PROCEDURE.
PROCEDURE menu-item-collapse :
  define buffer buf_temp-menu-item-open for temp-menu-item-open .
  do
  on error undo, return error return-value
  :
    if  available temp-menu-item
    and temp-menu-item.item-type = 's-m':U
    and temp-menu-item.show-child = '-':U
    then do:
      assign
        temp-menu-item.show-child = '+':U
      .
      find first buf_temp-menu-item-open
        where buf_temp-menu-item-open.item-code = temp-menu-item.item-code
        no-error .
      if available buf_temp-menu-item-open
      then do:
        delete buf_temp-menu-item-open .
      end.
      run delete-menu-item in this-procedure
        (input  temp-menu-item.item-code
        ) .
    end.
  end.
END PROCEDURE.
PROCEDURE menu-item-copy-full-name :
  define variable v-arm-title      as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame DEFAULT-FRAME
    :
      run gbl/clipbrd.p
        (input  temp-menu-item.full-name
        ) .
    end.
  end.
END PROCEDURE.
PROCEDURE menu-item-display-full-name :
  do
  on error undo, return error return-value
  :
    if available temp-menu-item
    then do:
      do with frame DEFAULT-FRAME
      :
        assign
          ed-menu-item-name :screen-value = fi-menu-group-name + "/" + temp-menu-item.full-name
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE menu-item-expand :
  define buffer buf_temp-menu-item-open for temp-menu-item-open .
  do
  on error undo, return error return-value
  :
    if  available temp-menu-item
    and temp-menu-item.item-type = 's-m':U
    and temp-menu-item.show-child = '+':U
    then do:
      assign
        temp-menu-item.show-child = '-':U
      .
      find first buf_temp-menu-item-open
        where buf_temp-menu-item-open.item-code = temp-menu-item.item-code
        no-error .
      if not available buf_temp-menu-item-open
      then do:
        create buf_temp-menu-item-open .
        assign
          buf_temp-menu-item-open.item-code = temp-menu-item.item-code
        .
      end.
      run proc-create-menu-item in g#dm-menu-handle
        (input  temp-menu-item.item-code
        ,input  ?
        ,input  false
        ,input  true
        ) .
      run menu-item-expand-open in this-procedure
        (input temp-menu-item.item-code
        ) .
    end.
  end.
END PROCEDURE.
PROCEDURE menu-item-expand-open :
  define input  parameter p-item-code as integer   no-undo .
  define buffer buf_temp-menu-item for temp-menu-item .
  define buffer buf_temp-menu-item-open for temp-menu-item-open .
  do
  on error undo, return error return-value
  :
    for each buf_temp-menu-item
      where buf_temp-menu-item.parent-code = p-item-code
    on error undo, return error return-value
    :
      find first buf_temp-menu-item-open
        where buf_temp-menu-item-open.item-code = buf_temp-menu-item.item-code
        no-error .
      if  available buf_temp-menu-item-open
      and buf_temp-menu-item.show-child = '+':U
      then do:
        assign
          buf_temp-menu-item.show-child = '-':U
        .
        run proc-create-menu-item in g#dm-menu-handle
          (input  buf_temp-menu-item.item-code
          ,input  ?
          ,input  false
          ,input  true
          ) .
      end.
      run menu-item-expand-open in this-procedure
        (input buf_temp-menu-item.item-code
        ) .
    end.
  end.
END PROCEDURE.
PROCEDURE menu-item-open-in-multiedit :
  define variable v-ok          as logical   no-undo .
  define buffer buf_menu-item for ub.menu-item .
  do
  on error undo, return error return-value
  :
    if  available temp-menu-item
    and temp-menu-item.item-type <> 's-m':u
    then do:
      find first buf_menu-item no-lock
        where buf_menu-item.item-code = temp-menu-item.item-code
        no-error .
      if not available buf_menu-item
      then do:
        message
          "Не найден пункт меню с кодом" temp-menu-item.item-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        v-ok = true
      .
      message
        "Открыть файл в multiedit" skip
        "Код пункта меню" temp-menu-item.item-code skip
        "Идентификатор пункта меню" buf_menu-item.item-id skip
        "Процедура" temp-menu-item.item-procedure skip
        "Продолжить?"
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok = true
      then do:
        run utl/meopen.p
          (input buf_menu-item.item-id
          ,input temp-menu-item.item-procedure
          ) .
      end.
    end.
  end.
END PROCEDURE.
procedure proc-check-place-imp :
  define buffer buf_place for ub.place .
  define buffer buf_place-attr for ub.place-attr .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf_goods for ub.goods .
  define variable v-pending-message as character no-undo .
  define variable v-applied-message as character no-undo .
  define variable v-ok-pending as logical no-undo .
  define variable v-ok-applied as logical no-undo .
  define variable v-place-mess as character no-undo .
  assign
    v-ok-pending = no
    v-ok-applied = no
    v-pending-message = "Внимание! После закрытия смены будет осуществлен переход на новые градуировочные таблицы для резервуаров:"
    v-applied-message = "Внимание! Новые градуировочные таблицы применены для резервуаров:"
  .
  for each buf_place-attr no-lock where buf_place-attr.obj-type = v-cntxt-obj-type
                                    and buf_place-attr.obj-code = v-cntxt-obj-code
                                    and buf_place-attr.attr-code = "message-table-version"
  :
    find first buf_place no-lock where buf_place.obj-type = buf_place-attr.obj-type
                                   and buf_place.obj-code = buf_place-attr.obj-code
                                   and buf_place.pl-code  = buf_place-attr.pl-code
                                   no-error .
    find first buf_pl-gds no-lock where buf_pl-gds.obj-type = buf_place-attr.obj-type
                                    and buf_pl-gds.obj-code = buf_place-attr.obj-code
                                    and buf_pl-gds.pl-code  = buf_place-attr.pl-code
                                    no-error .
    if available buf_pl-gds
    then do :
      find first buf_goods no-lock where buf_goods.gds-code = buf_pl-gds.gds-code no-error .
    end .
    if buf_place-attr.attr-value = "pending"
    then do :
      assign
        v-place-mess = "Резервуар " + (if available buf_place then buf_place.loc1 else "?") +
                       " код " + string(buf_place-attr.pl-code) +
                       " " + (if available buf_place then buf_place.pl-name else "") +
                       " c " + (if available buf_goods then buf_goods.gds-name else "?")
        v-ok-pending = yes
        v-pending-message = v-pending-message + chr(10) + v-place-mess
      .
    end .
    if buf_place-attr.attr-value = "applied"
    then do :
      assign
        v-place-mess = "Резервуар " + (if available buf_place then buf_place.loc1 else "?") +
                       " код " + string(buf_place-attr.pl-code) +
                       " " + (if available buf_place then buf_place.pl-name else "") +
                       " c " + (if available buf_goods then buf_goods.gds-name else "?")
        v-ok-applied = yes
        v-applied-message = v-applied-message + chr(10) + v-place-mess
      .
    end .
  end .
  if v-ok-pending
  then do :
    run ref/message_place-imp.w (input v-pending-message) .
  end .
  if v-ok-applied
  then do :
    run ref/message_place-imp.w (input v-applied-message) .
  end .
  for each buf_place-attr exclusive-lock where buf_place-attr.obj-type = v-cntxt-obj-type
                                           and buf_place-attr.obj-code = v-cntxt-obj-code
                                           and buf_place-attr.attr-code = "message-table-version"
  :
    delete buf_place-attr .
  end .
end procedure .
procedure proc-check-RVD :
  define buffer buf_place for ub.place .
  define buffer buf_place-attr for ub.place-attr .
  define buffer buf_clients-attr for ub.clients-attr .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf_goods for ub.goods .
  define buffer buf_place-attr2 for ub.place-attr .
  define variable v-message as character no-undo .
  define variable v-attr-value as character no-undo .
  define variable v-attr-type as character no-undo .
  define variable v-ok as logical no-undo init no .
  if v-cntxt-db-num = 0 then return .
  find first buf_place-attr no-lock where buf_place-attr.obj-type = v-cntxt-obj-type
                                      and buf_place-attr.obj-code = v-cntxt-obj-code
                                      and buf_place-attr.attr-code = "place-need-RVD-rvs"
                                      and logical(buf_place-attr.attr-value) = yes
                                      no-error .
  if available buf_place-attr
  then do :
    v-message = "Установлено разрешение РВД. Необходимо выполнить ручные замеры параметров НП и внести их в документ сверки. Резервуары и параметры, требующие ручных замеров:" + chr(10) .
    for each buf_place-attr no-lock where buf_place-attr.obj-type = v-cntxt-obj-type
                                      and buf_place-attr.obj-code = v-cntxt-obj-code
                                      and buf_place-attr.attr-code = "place-need-RVD-rvs"
                                      and logical(buf_place-attr.attr-value) = yes,
    first buf_place no-lock where buf_place.obj-type = v-cntxt-obj-type
                              and buf_place.obj-code = v-cntxt-obj-code
                              and buf_place.pl-code = buf_place-attr.pl-code
                              and buf_place.status_ = "",
    first buf_pl-gds no-lock where buf_pl-gds.obj-type = v-cntxt-obj-type
                               and buf_pl-gds.obj-code = v-cntxt-obj-code
                               and buf_pl-gds.pl-code = buf_place.pl-code,
    first buf_goods no-lock where buf_goods.gds-code = buf_pl-gds.gds-code
    :
      if is-gas(buf_goods.gds-code) then next .
      v-ok = yes .
      v-message = v-message + " Резервуар " + buf_place.loc1 + " код " + string(buf_place.pl-code) + " " + buf_place.pl-name + " с " + buf_goods.gds-name + chr(10) .
      for first buf_place-attr2 no-lock where buf_place-attr2.obj-type = v-cntxt-obj-type
                                          and buf_place-attr2.obj-code = v-cntxt-obj-code
                                          and buf_place-attr2.pl-code  = buf_place.pl-code
                                          and buf_place-attr2.attr-code = "place-rvd-dnsty"
                                          and logical(buf_place-attr2.attr-value) = yes
                                          :
        v-message = v-message + "   - Плотность" + chr(10) .
      end .
      for first buf_place-attr2 no-lock where buf_place-attr2.obj-type = v-cntxt-obj-type
                                          and buf_place-attr2.obj-code = v-cntxt-obj-code
                                          and buf_place-attr2.pl-code  = buf_place.pl-code
                                          and buf_place-attr2.attr-code = "place-rvd-tmp"
                                          and logical(buf_place-attr2.attr-value) = yes
                                          :
        v-message = v-message + "   - Температура" + chr(10) .
      end .
      for first buf_place-attr2 no-lock where buf_place-attr2.obj-type = v-cntxt-obj-type
                                          and buf_place-attr2.obj-code = v-cntxt-obj-code
                                          and buf_place-attr2.pl-code  = buf_place.pl-code
                                          and buf_place-attr2.attr-code = "place-rvd-lvl"
                                          and logical(buf_place-attr2.attr-value) = yes
                                          :
        v-message = v-message + "   - Уровень" + chr(10) .
      end .
    end .
    if v-ok
    then do :
      message v-message view-as alert-box title "Внимание!" .
    end .
  end .
end procedure .
PROCEDURE proc-fi-close-date :
define output  parameter p-date as date      no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .
empty temp-table thbjattr_thbj-attr .
case v-cntxt-level :
when 'object':U then do:
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input 'nakl_par':U
      ,input  "date-close-period"
      ,output v-value-character
      ,output p-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
end.
when 'firm':U then do:
  run adm/shattri.p (
       input "get":U
      ,input 'орг':U
      ,input v-cntxt-host-code-obj
      ,input 'nakl_par':U
      ,input  "date-close-period"
      ,output v-value-character
      ,output p-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
end.
when 'global':U then do:
  run adm/shattri.p (
       input "get":U
      ,input ""
      ,input 0
      ,input 'nakl_par':U
      ,input  "date-close-period"
      ,output v-value-character
      ,output p-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
end.
end case.
if error-status :error then message
  error-status :get-message(1) skip
  return-value skip
  "Ошибка"
  view-as alert-box error
.
END PROCEDURE.
PROCEDURE run-help :
  APPLY "HELP":U TO FRAME DEFAULT-FRAME.
END PROCEDURE.
PROCEDURE search-bar-code :
  define variable varresult   as character                no-undo.
  define variable vartype-bc  as character                no-undo.
  define variable varweight   as decimal                  no-undo.
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_prod-bc  for ub.prod-bc .
  define buffer buf_place    for ub.place .
  do
  on error undo, return error return-value
  :
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type29 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type29
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type29 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type29
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
    do with frame DEFAULT-FRAME
    :
      assign
        fi-bar-code
      .
    end.
    if fi-bar-code = '':U
    or fi-bar-code = ?
    then do:
      run bc-brief in this-procedure
        (input ?
        ).
      message
        substitute("Не задан штрих-код для поиска товара") skip
        view-as alert-box information .
    end.
    else do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  this-procedure
,input  fi-bar-code
,input  ?
,input  v-cntxt-obj-type
,input  v-cntxt-obj-code
,input  yes
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
      if available buf_bar-code
      then do:
        run bc-brief in this-procedure
          (input  buf_bar-code.b-code
          ).
      end.
      else do:
        run bc-brief in this-procedure
          (input  ?
          ).
        message
          substitute("Штрих-код &1 не найден"
                    ,fi-bar-code
                    ) skip
          view-as alert-box information .
      end.
    end.
    apply "entry" to fi-bar-code in frame DEFAULT-FRAME.
  end.
END PROCEDURE.
PROCEDURE select-context :
  define input  parameter p-cntxt-valid as logical   no-undo .
  define output parameter p-user-select as logical   no-undo .
  define variable v-select-cntxt-menu-code       as integer   no-undo .
  define variable v-select-cntxt-menu-group-code as integer   no-undo .
  define variable v-select-cntxt-level           as character no-undo .
  define variable v-select-cntxt-host-code-obj   as integer   no-undo .
  define variable v-select-cntxt-obj-type        as character no-undo .
  define variable v-select-cntxt-obj-code        as integer   no-undo .
  define variable v-select-cntxt-db-num-obj      as integer   no-undo .
  define variable v-select-cntxt-valid           as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-user-select = false
    .
    if p-cntxt-valid = true
    then do:
      assign
        v-select-cntxt-menu-code       = v-cntxt-menu-code
        v-select-cntxt-menu-group-code = v-cntxt-menu-group-code
        v-select-cntxt-level           = v-cntxt-level
        v-select-cntxt-host-code-obj   = v-cntxt-host-code-obj
        v-select-cntxt-obj-type        = v-cntxt-obj-type
        v-select-cntxt-obj-code        = v-cntxt-obj-code
      .
    end.
    else do:
      assign
        v-select-cntxt-menu-code       = 0
        v-select-cntxt-menu-group-code = 0
        v-select-cntxt-level           = 'global':U
        v-select-cntxt-host-code-obj   = 0
        v-select-cntxt-obj-type        = '':U
        v-select-cntxt-obj-code        = 0
      .
    end.
    assign
      v-select-cntxt-valid = false
    .
    _loop-select:
    do while v-select-cntxt-valid = false
    on error undo, return error return-value
    :
      run gbl/cntxtsel.w
        (input  this-procedure :handle
        ,input  v-cntxt-db-num
        ,input  0
        ,input  v-cntxt-user-id
        ,input  v-select-cntxt-menu-code
        ,input  v-select-cntxt-menu-group-code
        ,input  v-select-cntxt-level
        ,input  v-select-cntxt-host-code-obj
        ,input  v-select-cntxt-obj-type
        ,input  v-select-cntxt-obj-code
        ,output v-select-cntxt-menu-code
        ,output v-select-cntxt-menu-group-code
        ,output v-select-cntxt-level
        ,output v-select-cntxt-host-code-obj
        ,output v-select-cntxt-obj-type
        ,output v-select-cntxt-obj-code
        ,output v-user-select
        ) .
      if v-user-select <> true
      then do:
        assign
          p-user-select = false
        .
        return .
      end.
      define variable v-chk-usr-numa as logical   no-undo .
      define variable v-work-usr-num as integer   no-undo .
      define buffer bf_menu-group     for ub.menu-group .
      run chk-usr-numa in this-procedure
         (output v-chk-usr-numa
         ) .
      if v-chk-usr-numa = true
      then do:
         FIND FIRST bf_menu-group
            WHERE bf_menu-group.menu-code        = v-select-cntxt-menu-code
               AND bf_menu-group.menu-group-code  = v-select-cntxt-menu-group-code
            NO-LOCK
            no-error
            .
        if not available bf_menu-group
        then do:
        message
            vss-workfile vss-revision vss-description skip
            "Неизвестный код группы пунктов меню" skip
            "Код меню" v-select-cntxt-menu-code skip
            "Код группы пунктов меню" v-select-cntxt-menu-group-code skip
            view-as alert-box error .
            undo _loop-select, return error return-value .
        end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  bf_menu-group.menu-group-licence-param
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  yes
  ,output v-param-value
  ,output v-param-type
  ) no-error .
         if error-status :error
         then do:
         message
            vss-workfile vss-revision vss-description skip
            "Ошибка чтения конфигурационного параметра" bf_menu-group.menu-group-licence-param skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
         undo, return error return-value .
         end.
         run adm/isanybdy.p
               (input  true
               ,input  bf_menu-group.menu-code
               ,input  bf_menu-group.menu-group-id
               ,output v-work-usr-num
               ).
         if v-work-usr-num >= integer(v-param-value)
         then do:
               message
                  "Превышено максимальное количество пользователей, работающих в группе меню" bf_menu-group.menu-group-description skip
                  "Количество лицензий" integer(v-param-value) skip
                  "Работает пользователей" v-work-usr-num skip
                  return-value skip
               view-as alert-box error .
               UNDO _loop-select, RETRY _loop-select.
         end.
      END.
      if v-select-cntxt-level = 'object':U
      then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-select-cntxt-obj-type
  ,input  v-select-cntxt-obj-code
  ,output v-select-cntxt-db-num-obj
  )  .
      end.
      else do:
        assign
          v-select-cntxt-db-num-obj = ?
        .
      end.
      run gbl/cntxtchk.p
        (input  v-cntxt-db-num
        ,input  v-cntxt-user-id
        ,input  v-select-cntxt-menu-code
        ,input  v-select-cntxt-menu-group-code
        ,input  v-select-cntxt-level
        ,input  v-select-cntxt-host-code-obj
        ,input  v-select-cntxt-obj-type
        ,input  v-select-cntxt-obj-code
        ,input  v-select-cntxt-db-num-obj
        ,output v-select-cntxt-valid
        ,output v-cntxt-error-message
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при проверке контекста" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-select-cntxt-valid = false
      then do:
        message
          v-cntxt-error-message skip
          "" skip
          "Необходимо выбрать текущую Группу меню, Фирму, Объект" skip
          view-as alert-box information .
      end.
    end.
    assign
      p-user-select = true
    .
    assign
      v-cntxt-menu-code       = v-select-cntxt-menu-code
      v-cntxt-menu-group-code = v-select-cntxt-menu-group-code
      v-cntxt-level           = v-select-cntxt-level
      v-cntxt-host-code-obj   = v-select-cntxt-host-code-obj
      v-cntxt-obj-type        = v-select-cntxt-obj-type
      v-cntxt-obj-code        = v-select-cntxt-obj-code
      v-cntxt-db-num-obj      = v-select-cntxt-db-num-obj
    .
    run gbl/cntxtstr.p
      (input  v-cntxt-db-num
      ,input  v-cntxt-user-id
      ,input  v-cntxt-menu-code
      ,input  v-cntxt-menu-group-code
      ,input  v-cntxt-level
      ,input  v-cntxt-host-code-obj
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ) .
  end.
END PROCEDURE.
PROCEDURE select-menu-group :
  define input  parameter p-menu-group-code as integer   no-undo .
  define buffer buf_menu-group for ub.menu-group .
  define variable v-new-menu-group-id      as character no-undo .
  define variable v-previous-menu-group-id as character no-undo .
  define variable v-cur-date-error-code    as integer      no-undo.
  do
  on error undo, return error return-value
  :
    assign
        v-cur-date-error-code = 1
    .
    choose-item:
    do while v-cur-date-error-code = 1
    on error undo, return error
    :
        find first buf_menu-group no-lock
        where buf_menu-group.menu-code       = v-cntxt-menu-code
            and buf_menu-group.menu-group-code = p-menu-group-code
        no-error .
        if not available buf_menu-group
        then do:
        message
            vss-workfile vss-revision vss-description skip
            "Неизвестный код группы пунктов меню" skip
            "Код меню" v-cntxt-menu-code skip
            "Код группы пунктов меню" p-menu-group-code skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.
        assign
        v-new-menu-group-id = buf_menu-group.menu-group-id
        .
        define variable v-chk-usr-numa as logical   no-undo .
        define variable v-work-usr-num as integer   no-undo .
        define buffer bf_menu-group     for ub.menu-group .
        run chk-usr-numa in this-procedure
           (output v-chk-usr-numa
           ) .
        if v-chk-usr-numa = true
        then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  buf_menu-group.menu-group-licence-param
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  yes
  ,output v-param-value
  ,output v-param-type
  ) no-error .
            if error-status :error
            then do:
            message
               vss-workfile vss-revision vss-description skip
               "Ошибка чтения конфигурационного параметра" buf_menu-group.menu-group-licence-param skip
               error-status :get-message(1) skip
               return-value skip
               view-as alert-box error .
            undo, return error return-value .
            end.
            run adm/isanybdy.p
                  (input  true
                  ,input  buf_menu-group.menu-code
                  ,input  buf_menu-group.menu-group-id
                  ,output v-work-usr-num
                  ).
            if v-work-usr-num >= integer(v-param-value)
            then do:
                  message
                     "Превышено максимальное количество пользователей, работающих в группе меню" buf_menu-group.menu-group-description skip
                     "Количество лицензий" integer(v-param-value) skip
                     "Работает пользователей" v-work-usr-num skip
                     return-value skip
                  view-as alert-box error .
                  undo choose-item, return .
            end.
        END.
        find first buf_menu-group no-lock
        where buf_menu-group.menu-code       = v-cntxt-menu-code
            and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
        no-error .
        if available buf_menu-group
        then do:
            assign
                v-cntxt-previous-menu-group-id = buf_menu-group.menu-group-id
            .
        end.
        else do:
            assign
                v-cntxt-previous-menu-group-id = '':U
            .
        end.
        find first buf_menu-group no-lock
        where buf_menu-group.menu-code     = v-cntxt-menu-code
            and buf_menu-group.menu-group-id = v-new-menu-group-id
        no-error .
        if not available buf_menu-group
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Неизвестный код группы пунктов меню" skip
                "Код меню" v-cntxt-menu-code skip
                "Идентификатор группы пунктов меню" v-new-menu-group-id skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.
        assign
            v-cntxt-menu-group-code = buf_menu-group.menu-group-code
        .
        run delete-dm-menu in this-procedure
        no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении меню" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.
        run create-dm-menu in this-procedure
        no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании меню" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.
        do with frame DEFAULT-FRAME
        :
            assign
                fi-menu-group-name = buf_menu-group.menu-group-name
            .
        end.
        APPLY "value-changed" TO br-menu-item.
        run disp-static in this-procedure
        no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры disp-static" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.
        run mainmenu-disp-mutable in this-procedure (
            output v-cur-date-error-code
        )  no-error.
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры mainmenu-disp-mutable" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error .
        end.
        run gbl/cntxtstr.p
         ( input  v-cntxt-db-num
         , input  v-cntxt-user-id
         , input  v-cntxt-menu-code
         , input  v-cntxt-menu-group-code
         , input  v-cntxt-level
         , input  v-cntxt-host-code-obj
         , input  v-cntxt-obj-type
         , input  v-cntxt-obj-code
         ) .
    end.
end.
END PROCEDURE.
PROCEDURE select-previous-menu-group-id :
  define buffer buf_menu-group for ub.menu-group .
  do
  on error undo, return error return-value
  :
    if v-cntxt-previous-menu-group-id <> ""
    and v-cntxt-previous-menu-group-id <> ?
    THEN DO:
      find first buf_menu-group no-lock
         where buf_menu-group.menu-code = v-cntxt-menu-code
         and buf_menu-group.menu-group-id = v-cntxt-previous-menu-group-id
         no-error .
    END.
    else do:
      find first buf_menu-group no-lock
         where buf_menu-group.menu-code = v-cntxt-menu-code
         and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
         no-error .
    end.
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run select-menu-group in this-procedure
      (input buf_menu-group.menu-group-code
      ) .
  end.
END PROCEDURE.
PROCEDURE set-bc-price :
  define input parameter p-bc-price as logical no-undo .
  do
  on error undo, return error
  :
    assign
      v-cntxt-bc-price = p-bc-price
    .
  end.
END PROCEDURE.
PROCEDURE set-gds-engl :
  define input parameter p-gds-engl as logical no-undo .
  do
  on error undo, return error
  :
    assign
      v-cntxt-gds-engl = p-gds-engl
    .
  end.
END PROCEDURE.
PROCEDURE set-inp-jewel :
  define input parameter p-inp-jewel as logical no-undo .
  do
  on error undo, return error
  :
    assign
      v-cntxt-inp-jewel = p-inp-jewel
    .
  end.
END PROCEDURE.
PROCEDURE set-mainmenu-title :
  define buffer buf_clients for ub.clients .
  define variable v-version-name     as character no-undo .
  define variable v-version-name-str as character no-undo .
  define variable v-host-str         as character no-undo .
  define variable v-obj-str          as character no-undo .
  define variable v-user-str         as character no-undo .
  define variable v-db-num-str       as character no-undo .
  define variable v-user-id-str      as character no-undo .
  define variable v-process-id-str   as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-host-str = '':U
      v-obj-str  = '':U
    .
    case v-cntxt-level
    :
      when 'global':U
      then do:
      end.
      when 'firm':U
      then do:
        find first buf_clients no-lock
          where buf_clients.obj-type = 'орг':U
            and buf_clients.obj-code = v-cntxt-host-code-obj
          no-error .
        if available buf_clients
        then do:
          assign
            v-host-str = substitute("Фирма: &1 &2"
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
          .
        end.
      end.
      when 'object':U
      then do:
        find first buf_clients no-lock
          where buf_clients.obj-type = 'орг':U
            and buf_clients.obj-code = v-cntxt-host-code-obj
          no-error .
        if available buf_clients
        then do:
          assign
            v-host-str = substitute("Фирма: &1 &2"
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
          .
        end.
        find first buf_clients no-lock
          where buf_clients.obj-type = v-cntxt-obj-type
            and buf_clients.obj-code = v-cntxt-obj-code
          no-error .
        if available buf_clients
        then do:
          assign
            v-obj-str = substitute("Объект: &1 &2"
                                  ,buf_clients.obj-type
                                  ,buf_clients.obj-code
                                  )
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение переменной уровень контекста" skip
          "Значение" v-cntxt-level skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    run gbl/getvers.p
      (output v-version-name
      ) .
    assign
      v-version-name-str = substitute("TH &1", v-version-name)
    .
    assign
      v-db-num-str = substitute("БД: &1", v-cntxt-db-num)
    .
    assign
      v-user-id-str = substitute("Пользователь: &1", fi-user-login)
    .
    assign
      v-process-id-str = substitute("PID: &1", v-cntxt-process-id)
    .
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
    define variable v-title as character no-undo .
    if objSrv:SystemSetting:DeveloperMode then
      v-title = substitute('&1, &2, &3&4&5, &6, PID &7 &8':U
                          ,fi-menu-group-name
                          ,entry( 2,v-db-num-str,":")
                          ,(if v-host-str <> '':U
                              then entry( 2,v-host-str,":") + ', ':U
                              else '':U
                            )
                          , (if v-obj-str <> '':U
                              then entry( 2,v-obj-str,":") + ', ':U
                              else '':U
                            )
                          ,entry( 2,v-user-id-str,":")
                          ,v-version-name-str
                          ,v-cntxt-process-id
                          ,dbparam("ub")
                          )
    .
    else
    assign
      v-title = substitute('&1, &2, &3&4&5, &6, PID &7 &8':U
                          ,fi-menu-group-name
                          ,v-db-num-str
                          ,(if v-host-str <> '':U
                              then v-host-str + ', ':U
                              else '':U
                            )
                          , (if v-obj-str <> '':U
                              then v-obj-str + ', ':U
                              else '':U
                            )
                          ,v-user-id-str
                          ,v-version-name-str
                          ,v-cntxt-process-id
                          ,""
                          )
    .
    assign
      C-Win :title = v-title
    .
  end.
END PROCEDURE.
PROCEDURE set-quest-print :
  define input parameter p-quest-print as logical no-undo .
  define buffer buf_user-login for ub.user-login .
  do
  on error undo, return error
  :
    assign
      v-cntxt-quest-print = p-quest-print
    .
    find first buf_user-login exclusive-lock
      where buf_user-login.db-num  = v-cntxt-db-num
        and buf_user-login.user-id = v-cntxt-user-id
      no-error .
    if available buf_user-login then do:
      assign
        buf_user-login.quest-print = v-cntxt-quest-print
      .
    end.
  end.
END PROCEDURE.
PROCEDURE trigger-select-context :
    define variable v-cur-date-error-code   as integer      no-undo.
    define variable v-user-select           as logical      no-undo.
do
on error undo, return error return-value
:
    assign
        v-cur-date-error-code = 1
    .
    choose-item:
    do while v-cur-date-error-code = 1
    on error undo, return error
    :
        run select-context in this-procedure
        (input  true
        ,output v-user-select
        ) .
        if v-user-select <> true
        then do:
            UNDO, return ERROR.
        end.
        run delete-dm-menu in this-procedure
        no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении меню" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.
        run create-dm-menu in this-procedure
        no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании меню" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.
        run disp-static in this-procedure
        no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры disp-static" skip
                error-status :get-message(1) skip
                return-value skip
            view-as alert-box error .
            undo choose-item, return error return-value .
        end.
        run mainmenu-disp-mutable in this-procedure (
            output v-cur-date-error-code
        )  no-error.
        if error-status :error
        then do:
            if v-cur-date-error-code <> 1
            then do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при вызове процедуры mainmenu-disp-mutable" skip
                    error-status :get-message(1) skip
                    return-value skip
                view-as alert-box error .
                undo choose-item, return error .
            end.
        end.
        run select-menu-group  IN THIS-PROCEDURE ( INPUT v-cntxt-menu-group-code) NO-ERROR.
        if error-status :error
        then do:
            undo, retry.
        END.
    end.
end.
END PROCEDURE.
PROCEDURE update-image :
  define buffer buf_temp-image for temp-image .
  define buffer buf_temp-check-image for temp-check-image .
  define buffer buf_menu-group for ub.menu-group .
  define buffer buf_user-menu-group for ub.user-menu-group .
  define variable v-enable-item                    as logical   no-undo .
  define variable v-image-code                     as integer   no-undo .
  define variable v-check-image-index              as integer   no-undo .
  define variable v-check-image-name               as character no-undo .
  define variable v-check-image-context            as character no-undo .
  define variable v-check-image-menu-group-id-list as character no-undo .
  define variable v-check-image-procedure-list     as character no-undo .
  define variable v-check-image-visible-procedure  as character no-undo .
  define variable v-check-image-image-procedure    as character no-undo .
  define variable v-check-image-image-file-name    as character no-undo .
  define variable v-check-image-image-name         as character no-undo .
  define variable v-sel-img-file-name              as character no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_temp-image
    on error undo, return error return-value
    :
      assign
        buf_temp-image.image-visible   = false
        buf_temp-image.image-procedure = '':U
        buf_temp-image.image-file-name = '':U
      .
    end.
    assign
      v-image-code = 0
    .
    for each buf_menu-group no-lock
    on error undo, return error return-value
    :
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usmgrava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-user-id
  ,input  buf_menu-group.menu-code
  ,input  buf_menu-group.menu-group-code
  ,input  v-cntxt-level
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-enable-item
  )  .
      if  v-enable-item = true
      then do:
        assign
          v-image-code = v-image-code + 1
        .
        if v-image-code = 12 then do:
          assign
            v-image-code = 14
          .
        end.
        find first buf_temp-image
          where buf_temp-image.image-code = v-image-code
          no-error .
        if  available buf_temp-image
        then do:
          assign
            v-sel-img-file-name = substring( buf_menu-group.button-image-name , 1 , index( buf_menu-group.button-image-name , '.') - 1)
                          + 's'
                          + substring( buf_menu-group.button-image-name , index( buf_menu-group.button-image-name , '.') )
            buf_temp-image.image-visible          = true
            buf_temp-image.image-handle :sensitive = true
            buf_temp-image.image-file-name        = buf_menu-group.button-image-name
            buf_temp-image.image-sel-file-name    = v-sel-img-file-name
            buf_temp-image.image-procedure        = buf_menu-group.menu-group-procedure
            buf_temp-image.image-handle :TOOLTIP  = buf_menu-group.menu-group-description
          .
        end.
        if v-cntxt-menu-group-code = buf_menu-group.menu-group-code then do:
            assign
              buf_temp-image.image-handle :sensitive = false
              v-sel-img-file-name                 = buf_temp-image.image-file-name
              buf_temp-image.image-file-name      = buf_temp-image.image-sel-file-name
              buf_temp-image.image-sel-file-name  = v-sel-img-file-name
            .
        end.
        else do :
          assign
            buf_temp-image.image-handle :sensitive = true
          .
         end.
      end.
    end.
    find first buf_temp-image
      where buf_temp-image.image-code = 12
      no-error .
    if available buf_temp-image then do:
      assign
        buf_temp-image.image-visible          = true
        buf_temp-image.image-file-name        = "cmp/btn-rfr.bmp":U
        buf_temp-image.image-procedure        = "int,m__rfr-exe"
        buf_temp-image.image-handle :TOOLTIP  = "Обновить экран"
      .
    end.
    if v-cntxt-previous-menu-group-id <> ""
    and v-cntxt-previous-menu-group-id <> ?
    THEN DO:
      find first buf_menu-group no-lock
         where buf_menu-group.menu-code = v-cntxt-menu-code
         and buf_menu-group.menu-group-id = v-cntxt-previous-menu-group-id
         no-error .
    END.
    else do:
      find first buf_menu-group no-lock
         where buf_menu-group.menu-code = v-cntxt-menu-code
         and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
         no-error .
    end.
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена группа пунктов меню" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_temp-image
      where buf_temp-image.image-code = 13
      no-error .
    if  available buf_temp-image
    then do:
      assign
        buf_temp-image.image-visible            = true
        buf_temp-image.image-procedure          = buf_menu-group.menu-group-procedure
        buf_temp-image.image-handle :TOOLTIP    = buf_menu-group.menu-group-description
      .
      if v-cntxt-menu-group-code = buf_menu-group.menu-group-code then do:
        assign
          buf_temp-image.image-handle :sensitive  = false
          buf_temp-image.image-file-name          = "cmp/btn-bck.bmp":U
        .
      end.
      else do:
        assign
          buf_temp-image.image-handle :sensitive  = true
          buf_temp-image.image-file-name          = buf_menu-group.button-image-name
        .
      end.
    end.
    assign
      v-check-image-index = 0
      v-image-code = INTEGER ( TRUNCATE ( ( v-image-code - 0.5  ) / 13 , 0 ) + 1 ) * 13
    .
    for each buf_temp-check-image
    on error undo, return error return-value
    :
      delete buf_temp-check-image .
    end.
define variable v-lamp-name as character no-undo .
    v-lamp-name = search("cmp/image.txt").
    input stream sinp from value(v-lamp-name) .
    repeat
    :
      assign
        v-check-image-name               = '':U
        v-check-image-context            = '':U
        v-check-image-menu-group-id-list = '':U
        v-check-image-procedure-list     = '':U
        v-check-image-visible-procedure  = '':U
        v-check-image-image-procedure    = '':U
        v-check-image-image-file-name    = '':U
        v-check-image-image-name         = '':U
      .
      import stream sinp
        v-check-image-name
        v-check-image-context
        v-check-image-menu-group-id-list
        v-check-image-procedure-list
        v-check-image-visible-procedure
        v-check-image-image-procedure
        v-check-image-image-file-name
        v-check-image-image-name
        .
      assign
        v-check-image-index = v-check-image-index + 1
      .
      create buf_temp-check-image .
      assign
        buf_temp-check-image.check-image-index              = v-check-image-index
        buf_temp-check-image.check-image-name               = v-check-image-name
        buf_temp-check-image.check-image-context            = v-check-image-context
        buf_temp-check-image.check-image-menu-group-id-list = v-check-image-menu-group-id-list
        buf_temp-check-image.check-image-procedure-list     = v-check-image-procedure-list
        buf_temp-check-image.check-image-visible-procedure  = v-check-image-visible-procedure
        buf_temp-check-image.check-image-image-procedure    = v-check-image-image-procedure
        buf_temp-check-image.check-image-image-file-name    = v-check-image-image-file-name
        buf_temp-check-image.check-image-image-name         = v-check-image-image-name
      .
    end.
    input stream sinp close .
    find first buf_menu-group no-lock
      where buf_menu-group.menu-code       = v-cntxt-menu-code
        and buf_menu-group.menu-group-code = v-cntxt-menu-group-code
      no-error .
    if not available buf_menu-group
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена текущая группа меню" skip
        "Код меню" v-cntxt-menu-code skip
        "Код группы меню" v-cntxt-menu-group-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    define variable v-need-show-image as logical   no-undo .
    for each buf_temp-check-image
    on error undo, return error return-value
    :
      assign
        v-need-show-image = true
      .
      if lookup(buf_menu-group.menu-group-id, buf_temp-check-image.check-image-menu-group-id-list) = 0
      then do:
        assign
          v-need-show-image = false
        .
      end.
      if v-need-show-image = true
      then do:
        if buf_temp-check-image.check-image-context = 'global':U
        or (buf_temp-check-image.check-image-context = 'firm':U
            and
            (v-cntxt-level = 'firm':U
              or
              v-cntxt-level = 'object':U
            )
           )
        or (buf_temp-check-image.check-image-context = 'object':U
            and
            v-cntxt-level = 'object':U
           )
        then do:
        end.
        else do:
          assign
            v-need-show-image = false
          .
        end.
      end.
      if v-need-show-image = true
      then do:
        if buf_temp-check-image.check-image-procedure-list = ''
        then do:
        end.
        else do:
          define variable v-check-index as integer   no-undo .
          define variable v-num-entries-procedure-list as integer   no-undo .
          assign
            v-num-entries-procedure-list = num-entries(buf_temp-check-image.check-image-procedure-list)
          .
          check_block :
          do v-check-index = 1 to v-num-entries-procedure-list
          :
            run value(entry(v-check-index, buf_temp-check-image.check-image-procedure-list)) in this-procedure
              (output v-need-show-image
              ) .
            if v-need-show-image <> true
            then do:
              leave check_block .
            end.
          end.
        end.
      end.
      if v-need-show-image <> true
      then do:
        delete buf_temp-check-image .
      end.
    end.
    define variable v-check-image-visible-proc-list as character no-undo .
    assign
      v-check-image-visible-proc-list = '':U
    .
    for each buf_temp-check-image
    on error undo, return error return-value
    :
      if lookup(buf_temp-check-image.check-image-visible-procedure, v-check-image-visible-proc-list) = 0
      then do:
        assign
          v-check-image-visible-proc-list = v-check-image-visible-proc-list
                                          + (if v-check-image-visible-proc-list <> '':U then ',':U else '':U )
                                          + buf_temp-check-image.check-image-visible-procedure
        .
      end.
    end.
    assign
      v-num-entries-procedure-list = num-entries(v-check-image-visible-proc-list)
    .
    do v-check-index = 1 to v-num-entries-procedure-list
    :
      run value(entry(v-check-index, v-check-image-visible-proc-list)) in this-procedure .
    end.
    for each buf_temp-check-image
    :
      assign
        v-image-code = v-image-code + 1
      .
      find first buf_temp-image
        where buf_temp-image.image-code = v-image-code
        no-error .
      if available buf_temp-image
      then do:
        assign
          buf_temp-image.image-visible   = true
          buf_temp-image.image-handle :sensitive = true
          buf_temp-image.image-file-name = buf_temp-check-image.check-image-image-file-name
          buf_temp-image.image-procedure = buf_temp-check-image.check-image-image-procedure
          buf_temp-image.image-handle :tooltip = buf_temp-check-image.check-image-image-name
        .
      end.
    end.
    for each buf_temp-image
    on error undo, return error return-value
    :
      if buf_temp-image.image-visible = true
      then do:
        assign
          buf_temp-image.image-handle :visible = true
        .
        if
            buf_temp-image.image-handle:image <> buf_temp-image.image-file-name
        then do:
            buf_temp-image.image-handle:load-image(buf_temp-image.image-file-name) .
        end.
        if buf_temp-image.image-code > 8 then do:
            buf_temp-image.image-handle :width-chars  =  3 .
            buf_temp-image.image-handle :height-chars =  1 .
        end.
      end.
      else do:
          if buf_temp-image.image-handle:image <> "" then do:
        buf_temp-image.image-handle :load-image(?) .
        assign
          buf_temp-image.image-handle :visible = false
        .
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE ver-movepar :
  do
  on error undo, return error return-value
  :
  find first ub.config  no-lock where
             ub.config.param-code  = "type-vat"  and
             ub.config.db-num      = v-cntxt-db-num  no-error .
  end.
END PROCEDURE.
FUNCTION get-display-name RETURNS CHARACTER
  ( buffer buf_temp-menu-item for temp-menu-item ) :
  if available buf_temp-menu-item
  then do:
    return fill(" ", buf_temp-menu-item.num-level * 2)
         + (if buf_temp-menu-item.item-type = 's-m':U
            then (if buf_temp-menu-item.show-child = '+':u
                  then chr(187) + ' ':U
                  else chr(171) + ' ':U
                 )
            else chr(149) + ' ':U
           )
         + buf_temp-menu-item.display-name
         .
  end.
  else do:
    return '':U .
  end.
END FUNCTION.
PROCEDURE image-display-ovrorc :
  do
  on error undo, return error return-value
  :
    define variable l-exist-ovrorc as log no-undo init false .
    define buffer buf_price-doc for ub.price-doc.
    define buffer buf_trn-doc   for ub.trn-doc.
    define buffer buf_ord-doc   for ub.ord-doc.
    find first buf_ord-doc no-lock
      where buf_ord-doc.cli-type  = v-cntxt-obj-type
        and buf_ord-doc.cli-code  = v-cntxt-obj-code
        and buf_ord-doc.doc-type  = 'ОР':U
        and buf_ord-doc.status_   = 'запрос':U
            no-error .
       if not available buf_ord-doc then do:
          assign
            l-exist-ovrorc = false
          .
        end.
    else do:
    find first buf_trn-doc no-lock
      where buf_trn-doc.obj-type  = v-cntxt-obj-type
        and buf_trn-doc.obj-code  = v-cntxt-obj-code
        and buf_trn-doc.ext-doc-type  = 'iv':U
        and buf_trn-doc.status_   = 'запрос':U
        and buf_trn-doc.flag_     = true
        no-error .
    if not available buf_trn-doc then do:
       l-exist-ovrorc = false .
    end.
    else do:
        find first buf_price-doc no-lock
          where buf_price-doc.obj-type    = v-cntxt-obj-type
            and buf_price-doc.obj-code    = v-cntxt-obj-code
            and buf_price-doc.status_     = 'акт':U
            and
            ( buf_price-doc.fact-date  >  buf_trn-doc.real-date-create or
            ( buf_price-doc.fact-date  =  buf_trn-doc.real-date-create and
              buf_price-doc.fact-time  >=  buf_trn-doc.real-time-create ))
            no-error .
        if available buf_price-doc then do:
          assign
            l-exist-ovrorc = yes
          .
        end.
    end.
    end.
    run image-display-update-visible in this-procedure
      (input l-exist-ovrorc
      ,input 'ovrorc':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-qntorc :
  do
  on error undo, return error return-value
  :
    define variable l-exist-qntorc as log no-undo init false .
    define buffer buf_gds-obj   for ub.gds-obj.
    define buffer buf_trn-doc   for ub.trn-doc.
    define buffer buf_doc-line  for ub.doc-line.
    define buffer buf_ord-doc   for ub.ord-doc.
    find first buf_ord-doc no-lock
      where buf_ord-doc.cli-type  = v-cntxt-obj-type
        and buf_ord-doc.cli-code  = v-cntxt-obj-code
        and buf_ord-doc.doc-type  = 'ОР':U
        and buf_ord-doc.status_   = 'запрос':U
            no-error .
       if not available buf_ord-doc then do:
          assign
            l-exist-qntorc = false
          .
        end.
    else do:
    find first buf_trn-doc no-lock
      where buf_trn-doc.obj-type  = v-cntxt-obj-type
        and buf_trn-doc.obj-code  = v-cntxt-obj-code
        and buf_trn-doc.ext-doc-type  = 'iv':U
        and buf_trn-doc.status_   = 'запрос':U
        and buf_trn-doc.flag_     = true
        no-error .
    if not available buf_trn-doc then do:
       l-exist-qntorc = false .
    end.
    else do:
       for each buf_doc-line no-lock where
                buf_doc-line.doc-code = buf_trn-doc.doc-code :
        find first buf_gds-obj no-lock
          where buf_gds-obj.obj-type    = v-cntxt-obj-type
            and buf_gds-obj.obj-code    = v-cntxt-obj-code
            and buf_gds-obj.artic       = buf_doc-line.artic
            and buf_gds-obj.prod-type   = buf_doc-line.prod-type
            and buf_gds-obj.prod-code   = buf_doc-line.prod-code no-error .
             if error-status :error then do:
                l-exist-qntorc = false .
                leave.
             end.
                l-exist-qntorc = true .
                if buf_gds-obj.fact-qnty < buf_doc-line.fact-qnty then do:
                    l-exist-qntorc = false .
                    leave.
                end.
        end.
    end.
    end.
    run image-display-update-visible in this-procedure
      (input l-exist-qntorc
      ,input 'qntorc':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-srgdn :
  do
  on error undo, return error return-value
  :
define variable l-exist as log no-undo init false .
define variable v-srok as integer   no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-today as date      no-undo .
define variable v-time as integer   no-undo .
define variable v-godendo as date      no-undo .
  empty temp-table thbjattr_thbj-attr .
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input 'Ass-obj':U
      ,input 'crit-srokgod':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-srok
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
    if v-srok = 0 then do:
       l-exist = false  .
        run image-display-update-visible in this-procedure
          (input l-exist
          ,input 'srgdn':U
          ) .
       return .
    end.
    else do:
      l-exist = true .
    end.
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    run godendo-offset-to-date in this-procedure (
          input  v-today
        , input  v-srok
        , output v-godendo
    ).
    define buffer buf_parts for ub.parts  .
    find first buf_parts no-lock where
               buf_parts.obj-type = v-cntxt-obj-type and
               buf_parts.obj-code = v-cntxt-obj-code and
               buf_parts.last-date <= v-godendo and
               buf_parts.out-code = 'free-zone':U no-error .
    if available buf_parts then do:
       l-exist = true .
    end.
    else do:
      l-exist = false .
    end.
    run image-display-update-visible in this-procedure
      (input l-exist
      ,input 'srgdn':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-defec :
  do
  on error undo, return error return-value
  :
    define variable l-exist as log no-undo init false .
    assign
      l-exist = false
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-pharm':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-param-value
  ,output v-param-type
  ) no-error .
    if not error-status :error
      and v-param-value = 'yes':U
    then do:
      define buffer buf_parts for ub.parts  .
      find first buf_parts no-lock where
                 buf_parts.obj-type = v-cntxt-obj-type and
                 buf_parts.obj-code = v-cntxt-obj-code and
                 buf_parts.defect = logical('yes':U) and
                 buf_parts.out-code = 'free-zone':U no-error .
      if available buf_parts then do:
         l-exist = true .
      end.
    end.
    run image-display-update-visible in this-procedure
      (input l-exist
      ,input 'defec':U
      ) .
  end.
END PROCEDURE.
PROCEDURE image-display-pharm :
define variable v-pharm      as logical   no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-type  as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-pharm'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-attr-value
  ,output v-attr-type
  ) no-error .
    if error-status :error
    then do:
      v-pharm = false .
    end.
    else do:
       if lookup(v-attr-value, "true,yes") > 0 then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$workfile: $ $revision: $".
define variable v-o-pharm    as character no-undo .
define variable v-o-var-type as character no-undo .
  run clntattr-value in this-procedure
    ( input   v-cntxt-obj-type ,
      input   v-cntxt-obj-code ,
      input  'pharm':U,
      output v-o-pharm    ,
      output v-o-var-type )
     no-error .
  if v-o-pharm <> "yes":u or error-status :error then do:
     v-attr-value = "no"  .
  end.
       end.
      assign
        v-pharm = lookup(v-attr-value, "true,yes") > 0
      .
    end.
    run image-display-update-visible in this-procedure
      (input v-pharm
      ,input 'pharm':U
      ) .
END PROCEDURE.
PROCEDURE image-display-petrol :
define variable v-attr-value as character no-undo .
define variable v-attr-type  as character no-undo .
define variable v-shift-on   as logical   no-undo .
define variable l-exist      as logical   no-undo .
define buffer bf_goods   for ub.goods    .
define buffer bf_units   for ub.units    .
define buffer bf_gds-obj for ub.gds-obj  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-attr-value
  ,output v-attr-type
  ) no-error .
    if error-status :error
      or v-attr-value = 'no'
      or v-attr-value = 'false'
    then do:
      l-exist = false .
    end.
    else do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
      if v-shift-on = false then do:
          l-exist = false .
       end.
       else do:
        for each bf_units no-lock
          where lookup( 'топ':U, bf_units.type) > 0
          ,each bf_goods no-lock
          where bf_goods.unit-base = bf_units.unit-name
          ,first bf_gds-obj no-lock
          where bf_gds-obj.obj-type  = v-cntxt-obj-type
            and bf_gds-obj.obj-code  = v-cntxt-obj-code
            and bf_gds-obj.artic     = bf_goods.artic
            and bf_gds-obj.prod-type = bf_goods.prod-type
            and bf_gds-obj.prod-code = bf_goods.prod-code
        :
          l-exist = true .
          leave .
        end.
      end.
    end.
    run image-display-update-visible in this-procedure
      (input l-exist
      ,input 'petrol':U
      ) .
END PROCEDURE.
PROCEDURE image-display-pr-fin :
define variable v-attr-value as character no-undo.
define variable v-attr-type  as character no-undo.
define variable l-is-fin     as logical no-undo.
define buffer   buf_fin-ob   for ub.fin-ob.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin':U
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-attr-value
  ,output v-attr-type
  ) no-error .
    if error-status :error
       or v-attr-value = 'no'
       or v-attr-value = 'false'
    then do:
      l-is-fin = false.
    end.
    else do:
      if can-find(first buf_fin-ob where (buf_fin-ob.host-code = v-cntxt-host-code-obj and buf_fin-ob.sum-rubl > buf_fin-ob.con-sum-rubl)
                             and buf_fin-ob.pay-date < (today - 1))
      then l-is-fin = true.
    end.
    run image-display-update-visible in this-procedure
      (input l-is-fin
      ,input 'pr-fin':U
      ) .
END PROCEDURE.
