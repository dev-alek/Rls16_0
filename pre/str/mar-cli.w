DEFINE BUFFER find_cd-clu FOR ub.cd-clu.
DEFINE BUFFER locked_cash-desk FOR ub.cash-desk.
DEFINE BUFFER X_cd-clu FOR ub.cd-clu.
DEFINE BUFFER X_cli-obj FOR ub.clients.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
DEFINE INPUT PARAMETER p-mode  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-curr-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-curr-obj-code LIKE ub.clients.obj-code NO-UNDO.
define input parameter p-pos-type as character no-undo .
define input-output param p-rid-list    as  char no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Клиенты на кассе МАРИЯ".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure cd-attr-code :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  define output parameter p-prop-list      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-code in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ,output p-prop-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-tooltip :
  define input  parameter p-ucode   as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-tooltip in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-value :
  define input  parameter p-db-num    like ub.cash-desk-attr.db-num        no-undo .
  define input  parameter p-obj-code  like ub.cash-desk-attr.obj-code      no-undo .
  define input  parameter p-pos-type  like ub.cash-desk-attr.pos-type      no-undo .
  define input  parameter p-cash-num  like ub.cash-desk-attr.cash-num      no-undo .
  define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code      no-undo .
  define input  parameter p-code      like ub.cash-desk-attr.attr-code      no-undo .
  define output parameter p-character like ub.cash-desk-attr.attr-value-character    no-undo .
  define output parameter p-date      like ub.cash-desk-attr.attr-value-date         no-undo .
  define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal      no-undo .
  define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer      no-undo .
  define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical      no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-character
      ,output p-date
      ,output p-decimal
      ,output p-integer
      ,output p-logical
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-write :
  define input parameter p-db-num    like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code  like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type  like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num  like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code      like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-character like ub.cash-desk-attr.attr-value-character no-undo .
  define input parameter p-date      like ub.cash-desk-attr.attr-value-date      no-undo .
  define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal   no-undo .
  define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer   no-undo .
  define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-write in g#attr-lib
      (input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-ucode
      ,input p-code
      ,input p-character
      ,input p-date
      ,input p-decimal
      ,input p-integer
      ,input p-logical
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  define input  parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input  parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input  parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-delete :
  define input parameter  p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter  p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter  p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter  p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter  p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter  p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-news :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  define output parameter p-from-gbd       as logical   no-undo .
  define output parameter p-from-ubd       as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-news in g#attr-lib
      (
       input  p-ucode
      ,input  p-code
      ,output p-news
      ,output p-from-gbd
      ,output p-from-ubd
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-hist :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-hist           as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-hist in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-hist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-parse-date-time returns date
(input  p-string as character
,output p-time   as integer
):
  define variable v-return-value as date      no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-parse-date-time-proc in g#attr-lib
    (input  p-string
    ,output p-time
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run last-check-date-time in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-cd-datetostring returns character
(input  p-date as date
):
  define variable v-return-value as character no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-cd-datetostring-proc in g#attr-lib
    (input  p-date
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr-last-report-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-report-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-maria in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-periodic-tasks in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr_get-attr-int returns integer
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as integer   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-int-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-int-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
function cd-attr_get-attr-log returns logical
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as logical   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-log-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-log-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr_check-marketer :
  define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_check-marketer in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-manual-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-manual-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-batch-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-send-param :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-send-param in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-send-param
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE cd-mrkt_plu-marketer :
define input parameter p-silence as logical no-undo .
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-id as character no-undo .
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-b-str like ub.prod-bc.b-str no-undo .
define input parameter p-loc-ean as logical no-undo .
define input parameter p-is-petrolium as logical no-undo .
define input parameter p-extra as character no-undo .
define variable v-tot-gds as integer no-undo .
define variable v-max-gds as integer no-undo .
define variable v-petrol-start as integer no-undo .
define variable v-petrol-range as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-plu-type as character no-undo .
define variable v-int as integer no-undo .
define buffer  buf_cd-plu for ub.cd-plu.
define buffer  loc_cd-plu for ub.cd-plu.
define variable  ii as integer no-undo.
define variable v-mes as character no-undo .
_main:
DO ON ERROR undo, leave on stop undo, leave:
  if buf_cash-desk.pos-type <> 'MARIA':U
  or buf_cash-desk.cash-num <> 0 then do:
    assign
    v-mes =
    substitute("Товары на кассах можно определять только для кассовых менеджеров (номер кассы = 0) для типов касс &1"
              , buf_cash-desk.pos-type).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    return error v-mes.
  end.
  v-tot-gds = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_operative':U
                                  ,input (if buf_cash-desk.pos-type = 'MARIA':U
                                        and p-is-petrolium
                                        then 'tot-petrol':U
                                        else 'tot-gds':U)
                                  , output v-mes).
  if v-tot-gds = ? then undo _main, return error v-mes.
  v-max-gds = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_general':U
                                  ,input 'max-gds':U
                                  ,output v-mes).
  if v-max-gds = ? then undo _main, return error v-mes.
  v-petrol-range = cd-attr_get-attr-int(buffer buf_cash-desk
                                       ,input 'petrolium-range':U
                                       ,input 'petrolium-range':U
                                       ,output v-mes).
  if v-petrol-range = ? then undo _main, return error v-mes.
  if buf_cash-desk.pos-type = 'MARIA':U then do:
    assign
    v-petrol-start = 1
    v-max-gds = (if p-is-petrolium
                 then v-petrol-range
                 else v-max-gds)
    v-plu-type = (if p-is-petrolium
               then 'топ':U
               else '':U)
    .
    if p-is-petrolium then do:
      if p-id = '':U then do:
        v-mes = substitute( "Топливо с кодом &1 не привязано к складскому месту&2" +
                            "Невозможно привязать к кассе типа &3"
                            , p-b-str
                            , chr(10)
                            , 'MARIA':U).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
      end.
      assign
      v-int = integer(p-id)
      no-error
      .
      if error-status:error
      or v-int > v-petrol-range then do:
        v-mes = substitute( "№ резервуара &1 для топлива с кодом &1 не укладывается&3" +
                            "в диапазоны номеров резервуаров для кассы типа &4"
                            , p-id
                            , p-b-str
                            , chr(10)
                            , 'MARIA':U).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
      end.
    end.
  end.
  if buf_cash-desk.pos-type = 'MARIA':U
  and p-is-petrolium then do:
    find first loc_cd-plu where
             loc_cd-plu.obj-type = 'маг':U
         and loc_cd-plu.obj-code = buf_cash-desk.obj-code
         and loc_cd-plu.pos-type = buf_cash-desk.pos-type
         and loc_cd-plu.plu-type = 'топ':U
   no-error .
   if available loc_cd-plu then do:
     if loc_cd-plu.b-code = p-b-code
     and loc_cd-plu.b-str = p-b-str then do:
        v-mes = substitute( "№ резервуара &1 на кассе УЖЕ привязан к топливу с кодом &1,&3"
                            , p-id
                            , p-b-str
                            , chr(10)
                            ).
        if not p-silence then
        message
        v-mes
        view-as alert-box WARNING .
        return v-mes.
     end.
     else do:
        v-mes = substitute( "№ резервуара &1 на кассе привязан к топливу с кодом &1,&3" +
                            "нельзя его привязать к топливу &2&3"
                            , p-id
                            , loc_cd-plu.b-str
                            , chr(10)
                            , p-b-str).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
     end.
   end.
   ii = v-int.
  end.
  else do:
    DO ii = (if p-is-petrolium
            then v-petrol-start
            else (if buf_cash-desk.pos-type = 'MARIA':U
                 then 1
                 else (if v-petrol-start = 1
                        then (v-petrol-range + 1)
                        else 1)
                )
            )
      to v-max-gds :
      if not can-find (loc_cd-plu where
                      loc_cd-plu.obj-type = 'маг':U
                   and loc_cd-plu.obj-code =  buf_Cash-desk.obj-code
                   and loc_cd-plu.pos-type = buf_Cash-desk.pos-type
                   and loc_cd-plu.plu-type = v-plu-type
                   and loc_cd-plu.plu-code = ii
                    )
      then LEAVE .
    END .
  end.
  if ii > v-max-gds then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество &5 &1" +
                "для касс &2 &3&4"
                , chr(10)
                , v-max-gds
                , 'маг':U
                , buf_cash-desk.obj-code
                , (if p-is-petrolium then "топлив" else "товаров")
                )
      view-as alert-box ERROR .
      undo, return error "max-gds":U.
  end.
  DO ii = (if p-is-petrolium
           then v-petrol-start
           else (if v-petrol-start = 1
                 then (v-petrol-range + 1)
                 else 1)
           )
     to v-max-gds :
    if not can-find (loc_cd-plu where
                      loc_cd-plu.obj-type = 'маг':U
                   and loc_cd-plu.obj-code =  buf_Cash-desk.obj-code
                   and loc_cd-plu.pos-type = buf_Cash-desk.pos-type
                   and loc_cd-plu.plu-type = v-plu-type
                   and loc_cd-plu.plu-code = ii
                   )
    then LEAVE .
  END .
  if ii > v-max-gds then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество &5 &1" +
                "для касс &2 &3&4"
                , chr(10)
                , v-max-gds
                , 'маг':U
                , buf_cash-desk.obj-code
                , (if p-is-petrolium then "топлив" else "товаров")
                )
      view-as alert-box ERROR .
      undo, return error "max-gds":U.
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_cd-plu.
  assign
  buf_cd-plu.b-code = p-b-code
  buf_cd-plu.b-str = p-b-str
  buf_cd-plu.charkey_two = (if buf_cash-desk.pos-type = 'MARIA':U
                                      then buf_cash-desk.addr-path
                                      else "U":U)
  buf_cd-plu.to-send = yes
  buf_cd-plu.charkey_one = "":U
  buf_cd-plu.to-del = no
  buf_cd-plu.plu-code = ii
  buf_cd-plu.obj-type = 'маг':U
  buf_cd-plu.obj-code = buf_cash-desk.obj-code
  buf_cd-plu.pos-type = buf_cash-desk.pos-type
  buf_cd-plu.plu-type = v-plu-type
  buf_cd-plu.logkey_one = p-loc-ean
  buf_cd-plu.key#_one = integer(p-extra)
  .
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  substitute("&1_operative", buf_cash-desk.pos-type)
                                        ,input (if buf_cash-desk.pos-type = 'MARIA':U
                                              and p-is-petrolium
                                              then 'tot-petrol':U
                                              else 'tot-gds':U)
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input  (v-tot-gds + 1)
                                        ,input no
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <текущее количество товаров на кассе> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'to-send':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input yes
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <Есть коды товаров, не отправленные на кассу> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  return "":U.
end.
END PROCEDURE.
procedure cd-mrkt_update-marketer :
define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
define input parameter p-is-petrolium as logical no-undo .
define variable v-to-send as logical no-undo .
define variable v-tot-gds as integer no-undo .
define variable v-max-plu as integer no-undo .
define buffer buf_cd-plu for ub.cd-plu.
define variable v-plu-type as character no-undo .
  do
  on error undo, return error
  :
    v-to-send = no.
    v-tot-gds = 0.
    assign
    v-plu-type = (if p-is-petrolium
                  then  'топ':U
                  else '':U
              )
    .
    FOR EACH buf_cd-plu WHERE
           buf_cd-plu.obj-type = 'маг':U
      and  buf_cd-plu.obj-code = p-obj-code
      and  buf_cd-plu.pos-type = p-pos-type
      and  buf_cd-plu.plu-type = v-plu-type
          :
      if  buf_cd-plu.to-del
      or  buf_cd-plu.to-send then do:
        assign
        v-to-send = yes.
      end.
      assign
      v-tot-gds = v-tot-gds + 1.
    end.
    run cd-attr-write  in this-procedure (
                                            input   p-db-num
                                            ,input  p-obj-code
                                            ,input  p-pos-type
                                            ,input  p-cash-num
                                            ,input  'MARIA_operative':U
                                            ,input  (if p-pos-type = 'MARIA':U
                                                     and p-is-petrolium
                                                     then  'tot-petrol':U
                                                     else 'tot-gds':U)
                                            ,input ''
                                            ,input ?
                                            ,input 0.0
                                            ,input v-tot-gds
                                            ,input no
                                                                                        ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
    run cd-attr-write  in this-procedure (
                                            input   p-db-num
                                            ,input  p-obj-code
                                            ,input  p-pos-type
                                            ,input  p-cash-num
                                            ,input  'MARIA_operative':U
                                            ,input  (if p-pos-type = 'MARIA':U
                                                     and p-is-petrolium
                                                     then  'petrol-to-send':U
                                                     else 'to-send':U)
                                            ,input ''
                                            ,input ?
                                            ,input 0.0
                                            ,input 0
                                            ,input v-to-send
                                            ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
    FIND LAST buf_cd-plu NO-LOCK  WHERE
             buf_cd-plu.obj-type = 'маг':U
         and buf_cd-plu.obj-code = p-obj-code
         and buf_cd-plu.pos-type = p-pos-type
         and buf_cd-plu.plu-type = v-plu-type  use-index pi no-error .
    if available buf_cd-plu then do:
      if v-max-plu < buf_cd-plu.plu-code
      then
      v-max-plu = buf_cd-plu.plu-code .
    end.
    else do:
      v-max-plu = 0.
    end.
    run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  'MARIA_operative':U
                                          ,input  (if p-pos-type = 'MARIA':U
                                                  and p-is-petrolium
                                                  then 'max-petrol-plu':U
                                                  else 'max-plu':U)
                                            ,input ''
                                            ,input ?
                                            ,input 0.0
                                            ,input v-max-plu
                                            ,input no
                                          ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
  end.
end procedure.
PROCEDURE cd-mrkt_clu-marketer :
define input parameter p-silence as logical no-undo .
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable v-tot-cli as integer no-undo .
define variable v-max-cli as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer  buf_cd-clu for ub.cd-clu.
define buffer  loc_cd-clu for ub.cd-clu.
define variable  ii as integer no-undo.
define variable v-mes as character no-undo .
_main:
DO ON ERROR undo, leave on stop undo, leave:
  if buf_cash-desk.pos-type <> 'MARIA':U
  or buf_cash-desk.cash-num <> 0 then do:
    assign
    v-mes =
    substitute("Клиенты на кассах можно определять только для кассовых менеджеров (номер кассы = 0) для типов касс &1"
              , buf_cash-desk.pos-type).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    return error v-mes.
  end.
  v-tot-cli = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_operative':U
                                  ,input 'tot-cli':U
                                  ,output v-mes).
  if v-tot-cli = ? then undo _main, return error v-mes.
  v-max-cli = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_general':U
                                  ,input 'max-cli':U
                                  , output v-mes).
  if v-max-cli = ? then undo _main, return error v-mes.
  DO ii = 1
     to v-max-cli :
    if not can-find (loc_cd-clu where
                    loc_cd-clu.obj-type = 'маг':U
                and loc_cd-clu.obj-code = buf_cash-desk.obj-code
                and loc_cd-clu.pos-type = buf_cash-desk.pos-type
                and loc_cd-clu.clu-type = '':U
                and loc_cd-clu.clu-code = ii
                   )
    then LEAVE .
  END .
  if ii > v-max-cli then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество клиентов &1" +
                "для касс &2 &3&4"
                , chr(10)
                , v-max-cli
                , 'маг':U
                , buf_cash-desk.obj-code
                )
      view-as alert-box ERROR .
      undo, return error "max-cli":U.
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_cd-clu.
  assign
  buf_cd-clu.cli-code = p-obj-code
  buf_cd-clu.cli-type = p-obj-type
  buf_cd-clu.obj-type = 'маг':U
  buf_cd-clu.obj-code = buf_Cash-desk.obj-code
  buf_cd-clu.pos-type = buf_cash-desk.pos-type
  buf_cd-clu.clu-type = '':U
  buf_cd-clu.to-send = yes
  buf_cd-clu.charkey_two = (if buf_cash-desk.pos-type = 'MARIA':U
                            then buf_cash-desk.addr-path
                            else "U":U)
  buf_cd-clu.clu-code = ii
  .
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'tot-cli':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input  (v-tot-cli + 1)
                                        ,input no
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <текущее количество клиентов на кассе> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'cli-to-send':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input yes
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <Есть коды клиентов, не отправленные на кассу> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  return "":U.
end.
END PROCEDURE.
procedure cd-mrkt_update-marketer-cli :
define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
define variable v-cli-to-send as logical no-undo .
define variable v-tot-cli as integer no-undo .
define variable v-max-clu as integer no-undo .
define buffer buf_cd-clu for ub.cd-clu.
do
on error undo, return error return-value
:
  v-cli-to-send = no.
  v-tot-cli = 0.
  FOR EACH buf_cd-clu WHERE
        buf_cd-clu.obj-type = 'маг':U
    and buf_cd-clu.obj-code =  p-obj-code
    and buf_cd-clu.pos-type =  p-pos-type
    and buf_cd-clu.clu-type =  '':U
    :
    if buf_cd-clu.to-del = yes then do:
      assign
      v-cli-to-send = yes.
    end.
    assign
    v-tot-cli = v-tot-cli + 1.
  end.
  run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  'MARIA_operative':U
                                          ,input  'tot-cli':U
                                          ,input ''
                                          ,input ?
                                          ,input 0.0
                                          ,input v-tot-cli
                                          ,input no
                                          ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.
  run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  'MARIA_operative':U
                                          ,input  'cli-to-send':U
                                          ,input ''
                                          ,input ?
                                          ,input 0.0
                                          ,input 0
                                          ,input v-cli-to-send
                                          ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.
  FIND LAST buf_cd-clu WHERE
          buf_cd-clu.obj-type = 'маг':U
      and buf_cd-clu.obj-code = p-obj-code
      and buf_cd-clu.pos-type = p-pos-type
      and buf_cd-clu.clu-type = '':U
      NO-LOCK use-index pi no-error .
  if available buf_cd-clu then do:
    if v-max-clu < buf_cd-clu.clu-code
    then
    v-max-clu = buf_cd-clu.clu-code.
  end.
  else do:
    v-max-clu = 0.
  end.
  run cd-attr-write  in this-procedure (
                                        input   p-db-num
                                        ,input  p-obj-code
                                        ,input  p-pos-type
                                        ,input  p-cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'max-clu':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input v-max-clu
                                        ,input no
                                        ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.
end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table dc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table save-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table save-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE cash-cli no-undo
FIELD cli-type          like ub.clients.obj-type
FIELD cli-code          like ub.clients.obj-code
FIELD cli-name          like ub.clients.obj-name
FIELD obj-name          like ub.clients.obj-name
FIELD cli-name2         like ub.person.name1
FIELD cli-name3         like ub.person.name2
FIELD cli-adr           like ub.firm.addres1
FIELD cli-adr2          like ub.firm.addres2
FIELD director          like ub.firm.director
FIELD e-mail            like ub.firm.e-mail
FIELD engl-name         like ub.firm.engl-name
FIELD is-pboul          like ub.firm.is-pboul
FIELD okonh             like ub.firm.okonh
FIELD okpo              like ub.firm.okpo
FIELD cli-city          like ub.firm.city
FIELD cli-ind           like ub.firm.ind
FIELD cli-inn           like ub.firm.inn
FIELD cli-phone         like ub.firm.phone
FIELD fax               like ub.firm.fax
FIELD telex             like ub.firm.telex
FIELD phone1-note       like ub.firm.phone1-note
FIELD post-addr1        like ub.firm.post-addr1
FIELD post-addr2        like ub.firm.post-addr2
FIELD position          like ub.firm.head-position
FIELD post-box          like ub.person.post-box
FIELD h-ka              as integer
FIELD kpp               like ub.person.kpp
FIELD justface          as integer
FIELD kat-pcnt          as integer
FIELD d-card            like ub.dis-card.d-card
FIELD lim-kr            like ub.clients.lim-kr
FIELD current-saldo     as decimal
FIELD current-saldo-rubl as decimal
FIELD current-saldo-base as decimal
FIELD d-pcnt            like ub.dis-card.d-pcnt
FIELD cash-d-pcnt       like ub.dis-card.cash-d-pcnt
FIELD d-pcnt-method     like ub.dis-card.d-pcnt-method
FIELD cli-status_       like ub.clients.stts
FIELD status_           as character
FIELD issue-code        like ub.dis-card.issue-code
FIELD issue-date        like ub.dis-card.issue-date
FIELD type              like ub.dis-card.type
FIELD emitent-host-code like ub.dis-card-type.emitent-host-code
FIELD d-pcnt-byshop     like ub.dis-card-type.d-pcnt-byshop
FIELD card-media        like ub.dis-card-type.card-media
FIELD credit-card       like ub.dis-card.credit-card
FIELD debet-card        like ub.dis-card.debet-card
FIELD staff-card        like ub.dis-card.staff-card
FIELD cli-message       like ub.dis-card.cli-message
FIELD fiscal-pay        like ub.dis-card-type.fiscal-pay
FIELD given-by          like ub.person.given-by
FIELD passport          as character
FIELD pay-code          like ub.dis-card-type.pay-code
FIELD mixed-pay         like ub.dis-card-type.mixed-pay
FIELD sourced-card      like ub.dis-card.sourced-card
FIELD mask-card         like ub.dis-card.mask-card
FIELD valid-date        as date initial 12/31/9999
FIELD property-value-chr as character extent 4
field dcr-pcnt            as integer
field dcr-abs             as integer
field dcr-pcnt-qnty       as integer
field dcr-pcnt-tot        as integer
field dcr-debet-pay       as integer
field dcr-credit-pay      as integer
field has-attrs           as logical
field has-attrs-lim       as logical
field ef-access-key       as character
field ef-format           as integer
FIELD crf as integer
FIELD rc as recid
index pi is unique primary crf
index icli cli-type cli-code
index idcard d-card
.
define NEW SHARED temp-table cash-cli-attr no-undo
field d-card             like ub.dis-card.d-card
field dc-petrol-code      as integer
field cdpay-code          as integer
field curr-code           as integer
field dc-car-brand        as character
field dc-car-reg-number   as character
field dc-limit-type       as character
field dc-limit            as decimal
field dc-limit-l          as decimal
field account-type        as integer
field dc-sum-id           as character
field dc-minnum           as decimal
field dc-maxnum           as decimal
field caller_id           as character
index pi is unique primary
d-card
dc-petrol-code
dc-sum-id
caller_id
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table dcp-list no-undo like ub.dis-card-property
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index d-card-i is primary d-card host-code obj-type obj-code dt-code node-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable filter-point as character no-undo init "mar-cli" .
define variable filter-point0 as character no-undo init "mar-cli" .
define variable filter-label as character no-undo init "Клиенты на кассе МАРИЯ" .
define variable filter-label0 as character no-undo init "Клиенты на кассе МАРИЯ" .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
DEFINE VARIABLE v-obj-db-num like ub.db.db-num no-undo .
define variable lns-cnt as integer no-undo .
define variable glog as logical no-undo .
define variable SendOption as character no-undo .
define variable v-cd-list-update as character no-undo .
define variable v-cd-list-delete as character no-undo .
DEFINE VARIABLE v-max-cli AS integer no-undo .
DEFINE VARIABLE v-max-CLU AS integer no-undo .
DEFINE VARIABLE v-tot-cli AS integer no-undo .
DEFINE VARIABLE l-exist-cd AS logical no-undo .
define variable line-rec as recid no-undo .
define buffer pos_cd-clu for ub.cd-clu.
DEFINE MENU POPUP-MENU-B-send
       MENU-ITEM m_all          LABEL "Все"
       MENU-ITEM m_changed      LABEL "Измененные"    .
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-GO DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-send
     LABEL "&Послать"
     SIZE 10 BY 1.
DEFINE VARIABLE f-max-cli AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Max кол-во кодов"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-max-CLU AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Max тек CLU"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-tot-cli AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Тек кол-во кодов"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE loc-name AS CHARACTER FORMAT "X(256)":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE IMAGE cd-image
     FILENAME "adeicon/blank":U
     SIZE 3 BY 1 TOOLTIP "Отправьте клиентов на кассы".
DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Код", "b-code",
"&CLU", "CLU"
     SIZE 29.5 BY 1 NO-UNDO.
DEFINE QUERY br-mcli FOR
      X_cd-clu,
      X_clients SCROLLING.
DEFINE BROWSE br-mcli
  QUERY br-mcli NO-LOCK DISPLAY
      X_cd-clu.clu-code COLUMN-LABEL "CLU" FORMAT "999":U WIDTH 12
X_cd-clu.cli-type + string(X_cd-clu.cli-code) FORMAT "X(12)":U
X_cd-clu.to-send  COLUMn-LABEL "И" FORMAT "+/":U
X_cd-clu.to-DEL COLUMN-LABEL "У" FORMAT "+/":U
X_clients.obj-name FORMAT "X(50)":U
('K':U + string(if X_cd-clu.cli-type = 'орг':U then 1 else 0) + string(X_cd-clu.cli-code, '999999999')) COLUMN-LABEL 'Клиент-Счет' FORMAT "X(11)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.25 BY 17.5 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lkp AT ROW 1 COL 31
     B-chg AT ROW 1 COL 41
     B-send AT ROW 1 COL 51
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     a-n-c AT ROW 2 COL 2 NO-LABEL
     loc-name AT ROW 2 COL 55 COLON-ALIGNED
     loc-code AT ROW 2 COL 55 COLON-ALIGNED
     br-mcli AT ROW 4.25 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     f-max-cli AT ROW 3 COL 1
     f-tot-cli AT ROW 3 COL 25
     f-max-CLU AT ROW 3 COL 50
     cd-image AT ROW 2.25 COL 92
     SPACE(4.25) SKIP(18.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Клиенты на кассе".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-send:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-B-send:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF a-n-c IN FRAME Dialog-Frame
DO:
    case input frame Dialog-Frame a-n-c :
    when "b-code" then do:
      enable
      loc-code
      with frame Dialog-Frame.
      loc-code:label = "Код".
      display
      loc-code
      with frame Dialog-Frame.
      hide
      loc-name
      in frame Dialog-Frame.
      apply "entry" to loc-code in frame Dialog-Frame.
    end.
    when "CLU" then do:
      enable
      loc-code
      with frame Dialog-Frame.
      loc-code:label = "CLU (без № маг)".
      display
      loc-code
      with frame Dialog-Frame.
      hide
      loc-name
      in frame Dialog-Frame.
      apply "entry" to loc-code in frame Dialog-Frame.
    end.
    when "obj-type" then do:
      enable
      loc-name
      with frame Dialog-Frame.
      loc-name:label = "Доп.БК".
      display
      loc-name
      with frame Dialog-Frame.
      hide
      loc-code
      in frame Dialog-Frame.
      apply "entry" to loc-name in frame Dialog-Frame.
    end.
  end.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
  RUN proc-b-chg IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
    IF NOT AVAILABLE  X_cd-clu THEN RETURN NO-APPLY.
    run ref/showcli.p
    (input parParentProc
    ,input X_cd-clu.cli-type
    ,input X_cd-clu.cli-code
    ).
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo .
  if available X_cd-clu then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid20 as character no-undo .
define variable v-num-entry20 as integer   no-undo .
assign
  v-str-recid20 = trim( string( recid( X_cd-clu ) , "->>>>>>>>>>>9":U ) )
  v-num-entry20 = lookup( v-str-recid20 , p-rid-list )
.
if v-num-entry20 > 0 then do:
  assign
    entry( v-num-entry20, p-rid-list ) = "":U
    p-rid-list = trim( replace( p-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    p-rid-list = p-rid-list + ( if p-rid-list = "":U then "":U else chr(44) ) + v-str-recid20
  .
end.
    loc#log = br-mcli:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-mcli:select-next-row ().
        apply "VALUE-CHANGED" to br-mcli in frame Dialog-Frame.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-mcli in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  if not avail X_cd-clu then return no-apply.
  run proc-b-print in this-procedure  no-error.
  if error-status:error then do:
     return no-apply.
  end.
  APPLY "ENTRY" to br-mcli.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
  if ( available X_cd-clu ) then do:
    if ( p-rid-list = "" ) or b-mark:sensitive = no then
    p-rid-list = string( recid( X_cd-clu ) ) .
  end.
END.
ON CHOOSE OF B-send IN FRAME Dialog-Frame
DO:
if SendOption = "" then
run gbl/pop-up.p (self:handle, yes) no-error.
if SendOption = "" then return no-apply.
v-doc-rec = recid(X_cd-clu).
define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-clients_add-def':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-curr-obj-type
    ,input  p-curr-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if NOT glog THEN return no-apply.
RUN general-send no-error.
if error-status:error then do:
    Sendoption = "".
  return no-apply.
end.
Sendoption = "".
RUn OpenBR in this-procedure ( input yes, input no, input '':U).
run disp-cd in this-procedure .
reposition br-mcli to recid v-doc-rec no-error.
END.
ON MOUSE-SELECT-CLICK OF cd-image IN FRAME Dialog-Frame
OR selection of cd-image DO:
  run general-send in this-procedure  no-error .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  run fill-vars in this-procedure no-error .
  run disp-cd in this-procedure no-error.
  reposition br-mcli to recid v-doc-rec no-error.
END.
ON CTRL-J OF loc-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure(a-n-c, YES, input frame Dialog-Frame loc-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF loc-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure(a-n-c, no, input frame Dialog-Frame loc-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF loc-name IN FRAME Dialog-Frame
DO:
  run proc-find-obj-type in this-procedure(a-n-c, YES, input frame Dialog-Frame loc-name) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF loc-name IN FRAME Dialog-Frame
DO:
    run proc-find-obj-type in this-procedure(a-n-c, NO, input frame Dialog-Frame loc-name) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_all
DO:
    assign
  SendOption = "ALL":U.
  APPLY "CHOOSE" to b-send  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_changed
DO:
    assign
  SendOption = "changed":U.
  APPLY "CHOOSE" to b-send  in frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        v-diasize-browse-handle     = browse br-mcli :handle
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
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
def var sort-labelbr-mcli   as character no-undo .
def var sort-clmnbr-mcli    as handle    no-undo .
def var cur-clmnbr-mcli     as handle    no-undo .
def var cur-clmn-locbr-mcli as integer   no-undo .
def var re-querybr-mcli     as logical   initial no no-undo .
on start-search, ctrl-o of br-mcli in frame Dialog-Frame do:
   run sort-brbr-mcli
     (input (if available X_cd-clu
             then recid(X_cd-clu)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-mcli :
  define input parameter p-recid as recid no-undo .
  if re-querybr-mcli = no then do:
    assign
       cur-clmnbr-mcli = br-mcli:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-mcli <> ? then sort-clmnbr-mcli:column-fgcolor = 0.
    if cur-clmnbr-mcli = sort-clmnbr-mcli then do:
      assign
         sort-labelbr-mcli = ""
         sort-clmnbr-mcli = ?
      .
     end.
     else do:
       assign
         sort-labelbr-mcli = cur-clmnbr-mcli:label
         sort-clmnbr-mcli  = cur-clmnbr-mcli
         sort-clmnbr-mcli:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-mcli = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-mcli:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-mcli then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-mcli = cur-clmn-locbr-mcli + 1
    .
  end.
  case sort-labelbr-mcli:
        when X_cd-clu.clu-code:label in browse br-mcli then DO:    assign       sort-column-name = "X_cd-clu.clu-code"     .     run OpenBr in this-procedure  ( input yes, input no, input '':U).   . END.
        when ' '  then DO:    assign       sort-column-name = "X_cd-clu.cli-type + string(X_cd-clu.cli-CODE)"     .     run OpenBr in this-procedure  ( input yes, input no, input '':U).   . END.
        when X_clients.obj-name:label in browse br-mcli then DO:    assign       sort-column-name = "X_clients.obj-name"     .     run OpenBr in this-procedure  ( input yes, input no, input '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input '':U).
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-mcli') then do:
          run mv-brw-defaultbr-mcli.
        end.
      if sort-labelbr-mcli <> "" then do:
        assign
          cur-clmnbr-mcli:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-mcli = ?
      .
    end.
  end case.
    if cur-clmn-locbr-mcli <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-mcli') then do:
        run ch-clmnbr-mcli in this-procedure (cur-clmn-locbr-mcli).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-mcli to recid p-recid no-error.
    apply "value-changed" to br-mcli in frame Dialog-Frame.
  end.
  apply "entry" to br-mcli in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-mcli:
if cur-clmnbr-mcli = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input '':U).
end.
else do:
   assign re-querybr-mcli = yes.
   run sort-brbr-mcli
     (input (if available X_cd-clu
             then recid(X_cd-clu)
             else ?
            )
     ).
   assign re-querybr-mcli = no.
end.
end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-mcli :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-mcli as INT EXTENT 9 no-undo.
DEF VAR varmvibr-mcli       as INT no-undo.
DEF VAR varmvjbr-mcli       as INT no-undo.
DEF VAR varmvkbr-mcli       as INT no-undo.
DEF VAR varmvlbr-mcli       as INT no-undo.
DEF VAR move-elementbr-mcli as INT no-undo.
def var jjbr-mcli           as int no-undo.
do varmvibr-mcli = 1 to EXTENT(cur-clmn-numbr-mcli):
  ASSIGN cur-clmn-numbr-mcli[varmvibr-mcli] = varmvibr-mcli.
END.
RUN start-mv-clmnbr-mcli.
PROCEDURE start-mv-clmnbr-mcli:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  true  THEN DO:
   DO jjbr-mcli = NUM-ENTRIES('1,2,3,4,5,6,7,8,9') TO 1 BY -1:
     RUN re-move-clmnbr-mcli ( cur-clmn-numbr-mcli[INTEGER(ENTRY (jjbr-mcli, '1,2,3,4,5,6,7,8,9'))] , 2).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-mcli do:
  RUN re-move-clmnbr-mcli ( 2, 9).
END.
ON ctrl-cursor-left OF BROWSE br-mcli do:
  RUN re-move-clmnbr-mcli (9, 2).
END.
PROCEDURE re-move-clmnbr-mcli:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-mcli = 1 TO EXTENT(cur-clmn-numbr-mcli):
    if cur-clmn-numbr-mcli[varmvibr-mcli] = source-column THEN cur-clmn-numbr-mcli[varmvibr-mcli] = -1.
  END.
  if br-mcli:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-mcli = source-column - 1 to target-column BY -1:
    DO varmvibr-mcli = 1 TO EXTENT(cur-clmn-numbr-mcli):
        if cur-clmn-numbr-mcli[varmvibr-mcli] = varmvjbr-mcli THEN DO:
          cur-clmn-numbr-mcli[varmvibr-mcli] = cur-clmn-numbr-mcli[varmvibr-mcli] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-mcli = source-column + 1 to target-column:
    DO varmvibr-mcli = 1 TO EXTENT(cur-clmn-numbr-mcli):
      if cur-clmn-numbr-mcli[varmvibr-mcli] = varmvjbr-mcli THEN DO:
        cur-clmn-numbr-mcli[varmvibr-mcli] = cur-clmn-numbr-mcli[varmvibr-mcli] - 1.
      END.
    END.
  END.
  DO varmvibr-mcli = 1 TO EXTENT(cur-clmn-numbr-mcli):
    if cur-clmn-numbr-mcli[varmvibr-mcli] = -1 THEN cur-clmn-numbr-mcli[varmvibr-mcli] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-mcli:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 2 then do:
    return .
  end.
  DO varmvibr-mcli = 1 TO EXTENT(cur-clmn-numbr-mcli):
    if cur-clmn-numbr-mcli[varmvibr-mcli] = cur-clmn-loc THEN move-elementbr-mcli = varmvibr-mcli.
  END.
  RUN re-move-clmnbr-mcli (cur-clmn-loc, 2).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-mcli:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-mcli = 2 to EXTENT(cur-clmn-numbr-mcli):
    RUN re-move-clmnbr-mcli (cur-clmn-numbr-mcli[varmvlbr-mcli], varmvlbr-mcli).
  END.
  RUN start-mv-clmnbr-mcli.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    if p-mode <> 'все':U
    AND p-mode <> 'объект':U then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.
 find first X_cli-obj no-lock where
                X_cli-obj.obj-type = p-curr-obj-type
            and X_cli-obj.obj-code = p-curr-obj-code no-error.
  if not available X_cli-obj then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-curr-obj-type и/или p-curr-obj-code"
        view-as alert-box ERROR.
      return.
  end.
  if p-rid-list <> "" then do:
      FIND FIRST find_cd-clu No-LOCK where
                 recid(find_cd-clu) = integer(entry(1, p-rid-list)) No-ERROR.
      if not avail find_cd-clu then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-rid-list" p-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, p-rid-list)).
    end.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-obj-db-num
  )  .
  if v-obj-db-num <> v-db-num then do:
    message
    "Нельзя работать с клиентами кассы объекта удаленной БД"
    view-as alert-box error .
    undo, return error .
  end.
  do transaction
  on error undo main-block, return error
  :
    FIND FIRST LOCKED_cash-desk EXCLUSIVE-LOCK WHERE
              LOCKED_cash-desk.obj-code = p-curr-obj-code
          AND LOCKED_cash-desk.db-num = v-db-num
          AND LOCKED_cash-desk.pos-type = p-pos-type
          AND (p-pos-type = 'MARIA':U or LOCKED_cash-desk.cash-num = 0) NO-WAIT NO-ERROR.
    IF NOT AVAILABLE locked_cash-desk AND NOT LOCKED locked_cash-desk THEN DO:
        MESSAGE
        SUBSTITUTE("На &1&2 не определена касса типа &3 с номером 0 - кассовый менеджер&4" +
                  "Нельзя работать с клиентами на кассе"
                  , p-curr-obj-type
                  , p-curr-obj-code
                  , p-pos-type
                  , chr(10)
                  )
      VIEW-AS ALERT-BOX ERROR.
      UNDO main-block, RETURN ERROR.
    END.
    IF LOCKED locked_cash-desk THEN DO:
        MESSAGE
        SUBSTITUTE("На &1&2 в настоящее время занята запись кассы типа &3&4" +
                  "с номером 0 - кассовый менеджер" +
                  "Нельзя работать с клиентами на кассе"
                  , p-curr-obj-type
                  , p-curr-obj-code
                  , p-pos-type
                  , chr(10))
      VIEW-AS ALERT-BOX ERROR.
      UNDO main-block, RETURN ERROR.
    END.
    case p-pos-type:
      when 'MARIA':U then do:
         assign
         v-cd-list-delete = locked_cash-desk.addr-path
         v-cd-list-update = locked_cash-desk.addr-path
         .
      end.
    END CASE.
  end.
  RUN fill-vars IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN UNDO main-block, RETURN ERROR.
  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame Dialog-Frame .
  if p-rid-list <> "":U then
  REPOSITION br-mcli to recid integer(entry(1, p-rid-list)) No-ERROR.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disp-cd :
DEFINE VARIABLE v-mes AS CHARACTER NO-UNDO.
define buffer buf_cd-clu for ub.cd-clu .
  l-exist-cd = cd-attr_get-attr-log(buffer locked_cash-desk
                                    ,input 'MARIA_operative':U
                                    ,input 'to-send':U
                                    ,output v-mes).
if l-exist-cd = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
do with frame Dialog-Frame:   if l-exist-cd then           assign       glog = cd-image:load-image ("cmp/l-cd.bmp")       cd-image :selectable = yes       cd-image :sensitive = yes       cd-image :tooltip = cd-image :private-data       .    else do:     assign     glog = cd-image:load-image (?)       cd-image :selectable = no       cd-image :sensitive = no       cd-image :tooltip = '':U     .   end. end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY a-n-c loc-name loc-code mark-num f-max-cli f-tot-cli f-max-CLU
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-lkp B-chg B-send B-print B-sch B-Help cd-image
         a-n-c loc-name loc-code br-mcli mark-num f-max-cli f-tot-cli f-max-CLU
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-mcli FOR EACH X_cd-clu NO-LOCK,              FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_cd-clu.cli-type     AND X_clients.obj-code = X_cd-clu.cli-code INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE fill-vars :
define variable v-mes as character no-undo .
do
on error undo, return error
:
v-tot-cli = cd-attr_get-attr-int(buffer locked_cash-desk
                                ,input 'MARIA_operative':U
                                ,input 'tot-cli':U
                                ,output v-mes).
if v-tot-cli = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
v-max-cli = cd-attr_get-attr-int(buffer locked_cash-desk
                                ,input 'MARIA_general':U
                                ,input 'max-cli':U
                                ,output v-mes).
if v-max-cli = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
v-max-CLU = cd-attr_get-attr-int(buffer locked_cash-desk
                                ,input 'MARIA_operative':U
                                ,input 'max-clu':U
                                ,output v-mes).
if v-max-CLU = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
l-exist-cd = cd-attr_get-attr-log(buffer locked_cash-desk
                                 ,input 'MARIA_operative':U
                                 ,input 'max-clu':U
                                 ,output v-mes).
if l-exist-cd  = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
end.
DISPLAY
v-tot-cli @ f-tot-cli
v-max-cli @ f-max-cli
v-max-CLU @ f-max-CLU
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE general-send :
DEFINE VARIABLE err1 as logical init yes.
DEFINE VARIABLE jj as integer no-undo.
define variable v-step as integer no-undo .
define variable glog as logical no-undo .
define variable v-d-card like ub.dis-card.d-card no-undo .
define buffer buf_cd-clu  for ub.cd-clu.
define buffer buf_clients for ub.clients.
message
"Вы уверены что Вы приняли ВСЕ ЧЕКИ С КАССЫ?" skip
"В противном случае при изменении списка клиентов на кассе," skip
"может возникнуть ПЕРЕСОРТИЦА и/или появиться чеки с НЕОПОЗНАННЫМ КЛИЕНТОМ"
view-as alert-box QUESTION buttons YES-NO update glog.
if not glog then return error .
  FOR EACH dc-list :
    delete dc-list .
  END .
do
on error undo, return error
:
_zz:
DO ON STOP UNDO, return error
      ON END-KEY UNDO, return error
      ON ERROR UNDO, LEAVE:
  run waitfram-show in this-procedure ( 'Подождите ...' ) .
  jj = 0.
  _jj:
  FOR EACH buf_cd-clu WHERE
         buf_cd-clu.obj-type = p-curr-obj-type
     and buf_cd-clu.obj-code = p-curr-obj-code
     and buf_cd-clu.pos-type = 'MARIA':U
     and buf_cd-clu.clu-type = '':U ,
      first buf_clients no-lock where
          buf_clients.obj-type = buf_cd-clu.cli-type
      and buf_clients.obj-code = buf_cd-clu.cli-code :
    IF sendoption <> "ALL"
    AND buf_cd-clu.to-DEL = no
    AND  buf_cd-clu.to-send = no THEN NEXT _jj.
    v-d-card = ('K':U + string(if buf_cd-clu.cli-type = 'орг':U then 1 else 0) + string(buf_cd-clu.cli-code, '999999999')).
    v-d-card = 'C' + string((if buf_cd-clu.cli-type = 'чел':U then 0 else 1000000000) + buf_cd-clu.cli-code).
    find first cash-cli no-lock where
              cash-cli.d-card = v-d-card no-error .
    if not available cash-cli then do:
      create cash-cli.
      assign
      cash-cli.d-card = v-d-card
      cash-cli.emitent-host-code = 0
      cash-cli.cli-type = buf_cd-clu.cli-type
      cash-cli.cli-code = buf_cd-clu.cli-code
      cash-cli.obj-name = buf_clients.obj-name
      cash-cli.crf = buf_cd-clu.clu-code
      .
    end.
    jj = jj + 1.
    if ( jj modulo 10 = 0 ) then
    run waitfram-show in this-procedure (substitute("Обработано &1 кодов", jj)).
  END.
END.
  run str/diallog.w (   parparentproc
              , this-procedure
              , 'str/send-cli.p':U
              , (string( p-curr-obj-code) + chr(4) +
                 "U":U + chr(4) +
                 "no":U + chr(4) +
                 "no":U + chr(4) +
                 "del-mrkt-cli":U
                 )
              , no
              , '':U
              , 'Отправка клиентов на кассу') no-error .
  run cd-mrkt_update-marketer-cli in this-procedure (
                                                  input locked_cash-desk.db-num
                                                  ,input locked_cash-desk.obj-code
                                                  ,input locked_cash-desk.pos-type
                                                  ,input locked_cash-desk.cash-num
                                                )  .
end.
run fill-vars in this-procedure .
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN b-send:MENU-MOUSE in frame Dialog-Frame  = 1.
ASSIGN
cd-image:private-data in frame Dialog-Frame = cd-image:TOOLTIP
cd-image:fgcolor in frame Dialog-Frame = GRAY_COLOR
cd-image:bgcolor in frame Dialog-Frame = GRAY_COLOR
.
DISPLAY
a-n-c
loc-name
loc-code
mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark WHEN LOOKUP("b-mark", bttns) > 0
b-sel  WHEN LOOKUP("b-sel", bttns) > 0
B-chg
B-sch
B-print
B-Help
b-send
a-n-c
loc-name
loc-code
br-mcli
mark-num
b-lkp
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
hide
loc-name in frame Dialog-Frame.
RUN disp-cd IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = substitute("Клиенты на кассе &1"
                    , p-pos-type).
run waitfram-show in this-procedure ("Ждите...").
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
define variable l-open-query as logical   no-undo .
CASE p-mode :
  WHEN 'все':U        THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1", filter-label0)
    .
    if p-open-query then do:
      frame Dialog-Frame:TITLE = title0.
    end.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-39  as logical   no-undo .
define variable  l-filter-open-39    as logical   .
define variable  flt-rec-39       as recid     no-undo .
define variable  filter-name-39      as character no-undo .
define variable  where-phrase-39     as character no-undo .
define variable  sort-phrase-39      as character no-undo .
define variable  where-phrase-rus-39 as character no-undo .
define variable  sort-phrase-rus-39  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-39
  ,output filter-name-39
  ,output where-phrase-39
  ,output sort-phrase-39
  ,output where-phrase-rus-39
  ,output sort-phrase-rus-39
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-39
      ) no-error .
  assign
    l-filter-open-39 = false
  .
  if flt-rec-39 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-39 as character no-undo .
    define variable  parameter-3-39 as character no-undo .
    define variable  parameter-4-39 as character no-undo .
    define variable  parameter-5-39 as character no-undo .
    define variable  parameter-6-39 as character no-undo .
    define variable  parameter-7-39 as character no-undo .
      assign
      parameter-3-39 =
                              "FOR EACH X_cd-clu"
      parameter-4-39 =
        (
          if (" X_cd-clu.clu-type = '':U and X_cd-clu.pos-type = 'MARIA':U " + " " + where-phrase-39) <> ""
          then  substitute('X_cd-clu.clu-type = &1&1 and X_cd-clu.pos-type = &1&2&1 ', chr(34), 'MARIA':U) + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + ", first X_clients NO-LOCK WHERE X_clients.obj-type = X_cd-clu.cli-type and  X_clients.obj-code = X_cd-clu.cli-code")
      parameter-6-39 = if sort-phrase-39 = ''
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
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-39 =
          (" X_cd-clu.clu-type = '':U and X_cd-clu.pos-type = 'MARIA':U " + " " + where-phrase-39 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-mcli:handle
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
                          )
      .
      assign
        l-filter-open-39 = true
      .
    end.
    if l-filter-open-39 = false then do:
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
  if l-filter-open-39 = false then do:
    OPEN QUERY br-mcli FOR EACH X_cd-clu
      where  X_cd-clu.clu-type = '':U and X_cd-clu.pos-type = 'MARIA':U
    , first X_clients NO-LOCK WHERE X_clients.obj-type = X_cd-clu.cli-type and  X_clients.obj-code = X_cd-clu.cli-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_cd-clu )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-mcli:handle:get-buffer-handle(1) = (buffer X_cd-clu:handle) then do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-4-39 =
        "where ":u +  substitute('X_cd-clu.clu-type = &1&1 and X_cd-clu.pos-type = &1&2&1 ', chr(34), 'MARIA':U) + " ":u + where-phrase-39 + " ":u + p-find-condition + " " + ""
      parameter-5-39 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-mcli:handle
                          ,input rowid(X_cd-clu)
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input (buffer X_cd-clu:handle)
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-3-39 =  "FOR EACH X_cd-clu"
      parameter-4-39 =
        (
          if (" X_cd-clu.clu-type = '':U and X_cd-clu.pos-type = 'MARIA':U " + " " + where-phrase-39) <> ""
          then  substitute('X_cd-clu.clu-type = &1&1 and X_cd-clu.pos-type = &1&2&1 ', chr(34), 'MARIA':U) + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + ", first X_clients NO-LOCK WHERE X_clients.obj-type = X_cd-clu.cli-type and  X_clients.obj-code = X_cd-clu.cli-code" + " " + p-find-condition)
      parameter-6-39 = if sort-phrase-39 = ''
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
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-mcli:handle
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
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
  END.
  WHEN 'объект':U THEN DO:
    ASSIGN
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 Один объект", filter-label0)
    .
    if p-open-query then do:
      frame Dialog-Frame:TITLE = title0 +
                                    substitute(" &1&2", p-curr-obj-type, p-curr-obj-code).
    end.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-41  as logical   no-undo .
define variable  l-filter-open-41    as logical   .
define variable  flt-rec-41       as recid     no-undo .
define variable  filter-name-41      as character no-undo .
define variable  where-phrase-41     as character no-undo .
define variable  sort-phrase-41      as character no-undo .
define variable  where-phrase-rus-41 as character no-undo .
define variable  sort-phrase-rus-41  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-41
  ,output filter-name-41
  ,output where-phrase-41
  ,output sort-phrase-41
  ,output where-phrase-rus-41
  ,output sort-phrase-rus-41
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-41
      ) no-error .
  assign
    l-filter-open-41 = false
  .
  if flt-rec-41 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-41 as character no-undo .
    define variable  parameter-3-41 as character no-undo .
    define variable  parameter-4-41 as character no-undo .
    define variable  parameter-5-41 as character no-undo .
    define variable  parameter-6-41 as character no-undo .
    define variable  parameter-7-41 as character no-undo .
      assign
      parameter-3-41 =
                              "FOR EACH X_cd-clu"
      parameter-4-41 =
        (
          if ("         X_cd-clu.obj-type = p-curr-obj-type and X_cd-clu.obj-code = p-curr-obj-code         and X_cd-clu.pos-type = 'MARIA':U and X_cd-clu.clu-type = '':U                      " + " " + where-phrase-41) <> ""
          then  substitute(' X_cd-clu.obj-type = &1&2&1 and X_cd-clu.obj-code = &3         and X_cd-clu.pos-type = &1&4&1 and X_cd-clu.clu-type = &1&1 ', chr(34), p-curr-obj-type, p-curr-obj-code, 'MARIA':U) + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + ", first X_clients NO-LOCK WHERE X_clients.obj-type = X_cd-clu.cli-type and  X_clients.obj-code = X_cd-clu.cli-code")
      parameter-6-41 = if sort-phrase-41 = ''
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
        " " + sort-phrase-41
        )
      parameter-7-41 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-41 =
          ("         X_cd-clu.obj-type = p-curr-obj-type and X_cd-clu.obj-code = p-curr-obj-code         and X_cd-clu.pos-type = 'MARIA':U and X_cd-clu.clu-type = '':U                      " + " " + where-phrase-41 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-mcli:handle
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
                          )
      .
      assign
        l-filter-open-41 = true
      .
    end.
    if l-filter-open-41 = false then do:
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
  if l-filter-open-41 = false then do:
    OPEN QUERY br-mcli FOR EACH X_cd-clu
      where          X_cd-clu.obj-type = p-curr-obj-type and X_cd-clu.obj-code = p-curr-obj-code         and X_cd-clu.pos-type = 'MARIA':U and X_cd-clu.clu-type = '':U
    , first X_clients NO-LOCK WHERE X_clients.obj-type = X_cd-clu.cli-type and  X_clients.obj-code = X_cd-clu.cli-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_cd-clu )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-mcli:handle:get-buffer-handle(1) = (buffer X_cd-clu:handle) then do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-4-41 =
        "where ":u +  substitute(' X_cd-clu.obj-type = &1&2&1 and X_cd-clu.obj-code = &3         and X_cd-clu.pos-type = &1&4&1 and X_cd-clu.clu-type = &1&1 ', chr(34), p-curr-obj-type, p-curr-obj-code, 'MARIA':U) + " ":u + where-phrase-41 + " ":u + p-find-condition + " " + ""
      parameter-5-41 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-mcli:handle
                          ,input rowid(X_cd-clu)
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input (buffer X_cd-clu:handle)
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-41 = (if p-find-next then "true":u else "false":u )
      parameter-3-41 =  "FOR EACH X_cd-clu"
      parameter-4-41 =
        (
          if ("         X_cd-clu.obj-type = p-curr-obj-type and X_cd-clu.obj-code = p-curr-obj-code         and X_cd-clu.pos-type = 'MARIA':U and X_cd-clu.clu-type = '':U                      " + " " + where-phrase-41) <> ""
          then  substitute(' X_cd-clu.obj-type = &1&2&1 and X_cd-clu.obj-code = &3         and X_cd-clu.pos-type = &1&4&1 and X_cd-clu.clu-type = &1&1 ', chr(34), p-curr-obj-type, p-curr-obj-code, 'MARIA':U) + " " + where-phrase-41
          else "true"
        )
      parameter-5-41 = (" " + "" + " " + ", first X_clients NO-LOCK WHERE X_clients.obj-type = X_cd-clu.cli-type and  X_clients.obj-code = X_cd-clu.cli-code" + " " + p-find-condition)
      parameter-6-41 = if sort-phrase-41 = ''
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
        " " + sort-phrase-41
        )
      parameter-7-41 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-mcli:handle
                          ,input logical(parameter-2-41)
                          ,input no-lock
                          ,input parameter-3-41
                          ,input parameter-4-41
                          ,input parameter-5-41
                          ,input parameter-6-41
                          ,input parameter-7-41
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
  END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-mcli to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-mcli:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-mcli in frame Dialog-Frame.
APPLY "ENTRY" TO br-mcli.
END PROCEDURE.
PROCEDURE proc-b-chg :
define variable old-mode as char no-undo.
define variable old-handle as handle no-undo.
define variable old-type as char no-undo.
define variable old-stat as char no-undo.
define variable old-flag as logical no-undo.
define variable old-internal as logical no-undo.
DEFINE VARIABLE v-skip-next as logical no-undo .
DEFINE VARIABLE v-update as logical no-undo .
define variable v-f-name as character no-undo .
define variable l-empty-scale as logical no-undo .
define variable ves-err as integer no-undo .
define variable v-to-send as logical no-undo .
define variable v-mes as character no-undo .
define variable v-restore as logical   no-undo .
define buffer buf_clients for ub.clients.
DEFINE BUFFER buf_cd-clu FOR ub.cd-clu.
define buffer buf_dis-card for ub.dis-card.
FOR EACH dc-list :
    delete dc-list.
END.
FOR EACH save-list:
  delete save-list.
end.
run waitfram-show in this-procedure ( input "ЖДИТЕ.  Заполняется список...").
_block:
DO ON error UNDO _block, return error
on stop undo _block, return error:
_cd-clu:
  FOR EACH buf_cd-clu  WHERE
          buf_cd-clu.obj-type = p-curr-obj-type
      and buf_cd-clu.obj-code = p-curr-obj-code
      and buf_cd-clu.pos-type = 'MARIA':U
      and buf_cd-clu.clu-type = '':U
  by buf_cd-clu.clu-code:
    IF buf_cd-clu.to-DEL = yes
    and buf_cd-clu.charkey_one = v-cd-list-delete THEN NEXT.
    assign
    buf_cd-clu.to-del = yes
    buf_cd-clu.charkey_one = v-cd-list-delete.
    FIND FIRST buf_clients WHERE
            buf_clients.obj-type = buf_cd-clu.cli-type
        and buf_clients.obj-code = buf_cd-clu.cli-code  NO-LOCK no-error .
    if not available buf_clients then do:
      assign
      buf_cd-clu.to-del = yes
      buf_cd-clu.charkey_one = v-cd-list-delete.
      next _cd-clu.
    end.
    find first buf_dis-card no-lock where
              buf_dis-card.d-card = ('K':U + string(if buf_clients.obj-type = 'орг':U then 1 else 0) + string(buf_clients.obj-code, '999999999')) no-error.
    if not available buf_dis-card then do:
      assign
      buf_cd-clu.to-del = yes
      buf_cd-clu.charkey_one = v-cd-list-delete.
      next _cd-clu.
    end.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find dc-list
  where dc-list.d-card = buf_dis-card.d-card
  no-error .
if available dc-list then do:
  assign
    dc-list.to-del = no
  .
end.
else do:
  create dc-list .
  buffer-copy buf_dis-card to dc-list
  assign
    dc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (dc-list)
  .
end.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    assign
    buf_cd-clu.to-DEL = yes
    buf_cd-clu.charkey_one = v-cd-list-delete
    .
  end.
run waitfram-hide in this-procedure .
END.
run run-dc-list no-error .
if error-status:error then do:
  assign
  v-restore = yes.
end.
if not v-restore then do:
  message
  substitute("Вы действительно хотите изменить список клиентов на кассах &4 на &1&2&3" +
            "в соответствии с данным списком кодов?&3" +
            "(В список будут добавлены ТОЛЬКО карты типа КЛИЕНТ-СЧЕТ)"
            , p-curr-obj-type
            , p-curr-obj-code
            , chr(10)
            , p-pos-type
            )
  view-as alert-box QUESTION buttons YES-NO update v-update.
end.
if not v-update then do:
  FOR EACH dc-list:
    delete dc-list.
  END.
  FOR EACH buf_cd-clu where
          buf_cd-clu.obj-type = p-curr-obj-type
      and buf_cd-clu.obj-code = p-curr-obj-code
      and buf_cd-clu.pos-type = 'MARIA':U
      and buf_cd-clu.clu-type = '':U ,
      FIRST save-list WHERE
            save-list.cli-type = buf_cd-clu.cli-type
        AND save-list.cli-code = buf_cd-clu.cli-code NO-LOCK:
    assign
    buf_cd-clu.to-DEL = no
    buf_cd-clu.charkey_one = '':U
    .
    delete save-list.
  end.
    return .
end.
run waitfram-show in this-procedure ("ЖДИТЕ.  Началось изменение справочника.").
ves-err = 0.
DO ON error UNDO, return error :
_TO-cli:
FOR EACH dc-list:
  ACCUMULATE dc-list.d-card ( count ).
  if ( accum count dc-list.d-card ) modulo 100 = 0 then do:
    run waitfram-show in this-procedure ("ЖДИТЕ.  Обработано строк списка : " +
                                   string ( accum count dc-list.d-card ) ) .
  end.
  FIND FIRST buf_cd-clu WHERE
          buf_cd-clu.obj-type = p-curr-obj-type
      and buf_cd-clu.obj-code = p-curr-obj-code
      and buf_cd-clu.pos-type = 'MARIA':U
      and buf_cd-clu.clu-type = '':U
      AND buf_cd-clu.cli-code = dc-list.cli-code
      AND buf_cd-clu.cli-type = dc-list.cli-type  NO-ERROR.
  if available buf_cd-clu then do:
    assign
    buf_cd-clu.to-DEL = no
    buf_cd-clu.charkey_one = "":U
    .
  end.
  else do:
    if v-skip-next then do:
      delete dc-list.
    end.
    else do:
      CASE p-pos-type:
        when 'MARIA':U then do:
          if dc-list.type <> '@client':U
          or dc-list.d-card <> ('K':U + string(if dc-list.cli-type = 'орг':U then 1 else 0) + string(dc-list.cli-code, '999999999'))
          then do:
            ves-err = ves-err + 1.
            next _TO-cli.
          end.
          run cd-mrkt_CLU-marketer(
                                    input no
                                  ,buffer locked_cash-desk
                                  ,input dc-list.cli-type
                                  ,input dc-list.cli-code
                                  ) no-error.
          if error-status:error then do:
            if return-value = "max-cli":U then dO:
              assign
              v-skip-next = yes
              ves-err = ves-err + 1.
              NEXT _to-cli.
            end.
            else do:
              ves-err = ves-err + 1.
              next _TO-cli.
            end.
          end.
          else do:
            delete dc-list.
          end.
        end.
      end CASE.
    end.
  end.
END .
_mrktr-cli:
FOR EACH buf_cd-clu WHERE
        buf_cd-clu.obj-type = p-curr-obj-type
    and buf_cd-clu.obj-code = p-curr-obj-code
    and buf_cd-clu.pos-type = 'MARIA':U
    and buf_cd-clu.clu-type = '':U :
  IF buf_cd-clu.charkey_one <> v-cd-list-delete THEN NEXT _mrktr-cli.
  assign
  buf_cd-clu.to-send = yes
  buf_cd-clu.charkey_two = v-cd-list-update.
END .
run cd-mrkt_update-marketer-cli in this-procedure (
                                                input locked_cash-desk.db-num
                                                ,input locked_cash-desk.obj-code
                                                ,input locked_cash-desk.pos-type
                                                ,input locked_cash-desk.cash-num
                                              )  no-error .
if error-status:error then do:
  run waitfram-hide in this-procedure .
  undo, return error .
end.
END.
run waitfram-hide in this-procedure .
RUn OpenBR in this-procedure ( input yes, input no, input '':U).
run fill-vars in this-procedure .
run disp-cd in this-procedure .
if ves-err > 0 then
message
SUBSTITUTE("При добавлении клиентов на кассы встретилось &1 кодов,&2" +
            "для которых не удалось создать запись клиента на кассе&2&2" +
            "Эти клиенты на кассы НЕ ДОБАВЛЕНЫ !!!!"
            , ves-err
            ,chr(10))
view-as alert-box warning.
END PROCEDURE.
PROCEDURE proc-b-print :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      CHARACTER    no-undo.
define variable Line            as      CHARACTER    no-undo.
define variable for-time        as      CHARACTER    no-undo.
define variable v-card-no as character no-undo .
DEFINE FRAME cd-clu-list
X_cd-clu.clu-code COLUMN-LABEL "CLU" FORMAT "999":U
X_cd-clu.cli-type COLUMN-LABEL "Тип!IBS TH" FORMAT "X(3)":U
X_cd-clu.cli-code COLUMN-LABEL "Код!IBS TH" FORMAT "999999999":U
X_cd-clu.to-del COLUMN-LABEL "У" FORMAT "+/":U
X_cd-clu.to-send COLUMN-LABEL "И" FORMAT "+/":U
X_clients.obj-name  FORMAT "X(50)"
v-card-no  COLUMN-LABEL 'Клиент-Счет' FORMAT "X(11)":U
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 105 PAGE-NUMBER(PrnLibStream) AT 115 FORMAT ">>9" SKIP
Line format "X(130)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 130).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame Dialog-Frame:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(130)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME cd-clu-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_cd-clu).
DO WHILE available X_cd-clu :
  GET prev br-mcli.
END.
GET next br-mcli.
DO WHILE available X_cd-clu :
  Display STREAM PrnLibStream
  X_cd-clu.clu-code
  X_cd-clu.cli-type
  X_cd-clu.cli-code
  X_cd-clu.to-DEL
  X_cd-clu.to-send
  X_clients.obj-name
  ('K':U + string(if X_clients.obj-type = 'орг':U then 1 else 0) + string(X_clients.obj-code, '999999999')) @ v-card-no
  with FRAME cd-clu-list .
  DOWN STREAM PrnLibStream 1
  with FRAME cd-clu-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-mcli.
END.
UNDERLINE  STREAM PrnLibStream
X_cd-clu.clu-code
X_cd-clu.cli-type
X_cd-clu.cli-code
X_cd-clu.to-del
X_cd-clu.to-send
X_clients.obj-name
v-card-no
with FRAME cd-clu-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_cd-clu.clu-code
accum-count @ X_cd-clu.cli-type
with frame cd-clu-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME cd-clu-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-mcli to recid v-doc-rec no-error.
APPLY "entry" to br-mcli.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'cd-clu'
  join-tbl = 'X_cd-clu'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('CLU-code', 'CLU', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('CLI-code', 'Код в TH IBS', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type', 'Тип в TH IBS', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('to-del', 'Статус удаления', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('to-send', 'Статус изменения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT (filter-point + chr(4) + filter-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
PROCEDURE proc-find-code :
define input parameter p-a-n-c as character no-undo.
define input parameter p-next as logical no-undo.
define input parameter p-code AS integer no-undo.
DEFINE VARIABLE v-code AS CHARACTER NO-UNDO.
IF input frame Dialog-Frame a-n-c = "b-code":U THEN DO:
    run OpenBr in this-procedure
        (input false
        ,input p-next
        ,input substitute("and X_cd-clu.cli-code = &1 "
          , p-code)
        ).
END.
IF input frame Dialog-Frame a-n-c = "CLU":U THEN DO:
    run OpenBr in this-procedure
        (input false
        ,input p-next
        ,input substitute("and X_cd-clu.clu-code = &1 "
          , p-code)
        ).
END.
apply "entry":u to loc-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-obj-type :
define input parameter p-a-n-c as character no-undo.
define input parameter p-next as logical no-undo.
define input parameter p-obj-type AS character no-undo.
assign
p-obj-type = replace(p-obj-type, chr(34), "":U)
p-obj-type = replace(p-obj-type, chr(39), chr(39) + chr(39))
p-obj-type = chr(34) + p-obj-type + chr(34)
.
run OpenBr in this-procedure
(input false
,input p-next
,input substitute("and X_cd-clu.cli-type = &1 "
  , p-obj-type)
).
apply "entry":u to loc-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE RUN-dc-list :
define variable v-host-code like ub.sysconf.host-code no-undo .
DO
ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
  run str/dc-list.w (
                INPUT parparentproc
                ,input v-host-code
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ).
END.
END PROCEDURE.
