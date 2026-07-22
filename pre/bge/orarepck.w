define input  parameter parparentproc as handle    no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита перевыгрузки пакета для Oracle".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DEF STREAM stmXMLOut.
DEF STREAM stmXMLLog.
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
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure strtdate :
  define input  parameter p-str         as character no-undo .
  define output parameter p-value       as date      no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
do
on error undo, return error return-value
:
  define variable v-value       as date      no-undo .
  define variable v-i           as integer   no-undo .
  define variable v-num         as integer   no-undo .
  define variable v-delim       as character no-undo .
  define variable v-delim-list  as character no-undo .
  define variable v-day         as integer   no-undo .
  define variable v-month       as integer   no-undo .
  define variable v-year        as integer   no-undo .
  define variable v-day-str     as character no-undo .
  define variable v-month-str   as character no-undo .
  define variable v-year-str    as character no-undo .
  assign
    p-value       = ?
    p-data-valid  = false
  .
  if p-str = ?
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Не задана строка для преобразования. " )
    .
    return .
  end.
  if p-str = ""
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Задана пустая строка для преобразования. " )
    .
    return .
  end.
  if length(p-str)  > 10
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверная длина строки. " )
    .
    return .
  end.
  assign
    v-delim-list = '/,-,.':U
  .
  _delim:
  do v-i = 1 to num-entries( v-delim-list )
  :
    assign
      v-delim = entry( v-i , v-delim-list )
      v-num   = num-entries( p-str , v-delim )
    .
    if v-num <> 3
    then do:
      assign
        v-delim = ''
      .
    end.
    else do:
      leave _delim.
    end.
  end.
  if v-delim = ''
  then do:
    assign
      p-message = substitute( "Ошибка при преобразовании к дате. Неправильный разделитель, либо ошибочное количество разделителей. " )
    .
    return .
  end.
  assign
    v-day-str   = entry( 1, p-str , v-delim)
    v-month-str = entry( 2, p-str , v-delim)
    v-year-str  = entry( 3, p-str , v-delim)
  .
  if  length(v-day-str) > 2   or
      length(v-day-str) < 1   or
      length(v-month-str) > 2 or
      length(v-month-str) < 1 or
      (
        length(v-year-str) <> 2 and
        length(v-year-str) <> 4
      )
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неправильное количество символов числа, месяца, либо года. " )
    .
    return .
  end.
  if length( v-year-str ) = 2
  then do:
    assign
      v-year-str = substring( string( year(today) ), 1 , 2 ) + v-year-str
    .
  end.
  assign
    v-day   = integer( v-day-str )
    v-month = integer( v-month-str)
    v-year  = integer( v-year-str)
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный формат символов числа, месяца, либо года. " )
    .
    return .
  end.
  if v-day < 1  or
     v-day > 31 or
     v-month < 1 or
     v-month > 12 or
     v-year < 0   or
     v-year > 5000
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный диапозон числа, месяца, года. " )
    .
    return .
  end.
  assign
    v-value = date( v-month, v-day, v-year )
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. &1. " , error-status :get-message(1))
    .
    return .
  end.
  assign
    p-value       = v-value
    p-data-valid  = true
  .
end.
end procedure.
define variable v-bge-xml-bgecliiv      as logical  init no  no-undo.
define variable v-bge-xml-bgeclall      as logical  init no  no-undo.
define variable v-bge-xml-bgedict       as logical  init no  no-undo.
define variable v-bge-xml-bgeflold      as character         no-undo.
define variable v-bge-xml-bgefmt        as character         no-undo.
define variable v-bge-xml-shift-mode    as logical           no-undo.
define variable v-bge-xml-bgeflnm-doc   as character         no-undo.
define variable v-bge-xml-bgeflnm-day   as character         no-undo.
define variable v-bge-xml-log-file-name as character    no-undo.
define variable v-bge-xml-dbf-file-name as character    no-undo.
define variable v-bge-xml-db-num-str    as character    no-undo .
define variable v-bge-xml-static-log-file-name as character    no-undo.
define temp-table temp_ext-doc-type no-undo
    field edt-key               as integer
    field ext-doc-type          as character
    field ext-doc-type-label    as character
    index pi is primary unique
        edt-key
.
define temp-table temp_bge-xml_goods no-undo
    field gds-code as integer
    index pi is primary unique gds-code
.
define temp-table temp_bge-xml_clients no-undo
    field obj-type as character
    field obj-code as integer
    field shift-date    as date
    field shift-num     as integer
    index pi is primary unique
        obj-type
        obj-code
.
define temp-table temp_bge-xml_dis-card no-undo
    field d-card as character
    index pi is primary unique
        d-card
.
define temp-table temp_doc-code no-undo
    field doc-code as character
    index pi is primary unique
        doc-code
.
define temp-table temp_del-doc-code no-undo
    field doc-code as character
    index pi is primary unique
        doc-code
.
define temp-table temp_pr-doc-num no-undo
    field doc-num as character
    index pi is primary unique
        doc-num
.
define temp-table temp_fin-doc-code no-undo
    field host-code as integer
    field fin-doc-code as integer
    index pi is primary unique
        host-code
        fin-doc-code
.
define temp-table temp_del-fin-doc-code no-undo
    field host-code as integer
    field fin-doc-code as integer
    field corr-user-db-num as integer
    field chip-num as integer
    index pi is primary unique
        host-code
        fin-doc-code
        corr-user-db-num
        chip-num
.
define temp-table temp_fin-ob no-undo
    field host-code as integer
    field fin-doc-code as character
    index pi is primary unique
        host-code
        fin-doc-code
.
define temp-table temp_del-fin-ob no-undo
    field host-code as integer
    field fin-doc-code as character
    field corr-user-db-num as integer
    field chip-num as integer
    index pi is primary unique
        host-code
        fin-doc-code
        corr-user-db-num
        chip-num
.
define temp-table temp_ord-doc-code no-undo
  field doc-code as character
index pi is primary unique
  doc-code
.
define temp-table tt-bge-xml-bgecliiv no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
index pi is primary unique
  obj-type
  obj-code
.
FUNCTION w-XMLPutParamInTag RETURNS CHAR (INPUT sParName AS CHAR, INPUT sToPlace AS CHAR,
                                          INPUT iFlagEmpty AS INTEGER).
    DEF VAR sOut AS CHAR FORMAT "X(255)" NO-UNDO.
    IF sToPlace = "" OR sToPlace = ? OR sToPlace = "0" THEN
        DO:
            IF iFlagEmpty = 0                           THEN RETURN "".
            ELSE IF iFlagEmpty = 1                      THEN RETURN sParName + "=&#034;&#034;".
            ELSE IF iFlagEmpty = 2 AND sToPlace = "0"   THEN RETURN sParName + "=&#034;0&#034;".
            ELSE IF iFlagEmpty = 3 AND sToPlace = ""    THEN RETURN sParName + "=&#034;&#034;".
            ELSE RETURN "".
        END.
    ELSE DO:
        run xmlchar-encode in this-procedure (
              input sToPlace
            , output sToPlace
        ).
        ASSIGN
            sToPlace = sParName + '="' + sToPlace + '"'
        .
        RETURN sToPlace.
    END.
END FUNCTION.
function bge-xml-date returns character
( input p-date as date )
:
  define variable v-date-str as character no-undo .
  run bge-xml-date-to-str in this-procedure ( input   p-date
                                            , output  v-date-str
                                            ) .
  return v-date-str.
end function.
function bge-xml-str-date returns character
( input p-date-str as character )
:
  define variable v-date-str as character no-undo .
  run bge-xml-date-str-to-str in this-procedure ( input   p-date-str
                                                , output  v-date-str
                                                ) .
  return v-date-str.
end function.
function bge-xml-normalize-dec returns decimal
( input p-val as decimal )
:
  return (if p-val = ? then 0 else p-val) .
end function.
PROCEDURE wp-XMLTagOpen:
DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
DEF INPUT PARAM sParValue AS CHAR NO-UNDO.
    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    if v-bge-xml-bgefmt = "dbf":U
    then do:
    end.
    else do:
        assign
            v-out-string = substitute( "&1&2<&3&4>"
                                    , chr(10)
                                    , fill( " ":U, 4 * iTagLevel)
                                    , sTagName
                                    , ( if sParValue = "":U or sParValue = ? then "":U else " " + sParValue )
                            )
        .
        put stream stmXMLOut unformatted
            v-out-string
        .
    end.
end.
END PROCEDURE.
PROCEDURE wp-XMLTagPut:
  DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
  DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
  DEF INPUT PARAM sParValue AS CHAR NO-UNDO.
  DEF INPUT PARAM iFlagEmpty AS INTEGER NO-UNDO.
    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    if v-bge-xml-bgefmt = "dbf":U
    then do:
        if v-bge-xml-dbf-file-name <> "":U
        then do:
            output stream stmXMLOut to value( v-bge-xml-dbf-file-name ) append.
            export stream stmXMLOut
                sTagName
                sParValue
            .
            output stream stmXMLOut close.
        end.
    end.
    else do:
        IF  iFlagEmpty = 1
        OR (iFlagEmpty = 0 AND (sParValue <> "" AND sParValue <> ?) )
        OR (iFlagEmpty = 2 AND (sParValue <> "" AND sParValue <> ? AND sParValue <> "0"))
        OR (iFlagEmpty = 3 AND (sParValue <> "" AND sParValue <> ? AND CAPS(sParValue) <> "NO"))
        THEN DO:
            run xmlchar-encode in this-procedure (
                input sParValue
                , output sParValue
            ).
            assign
                v-out-string = substitute( "&1&2<&3>&4</&3>"
                                            , chr(10)
                                            , FILL(" ", 4 * iTagLevel)
                                            , sTagName
                                            , sParValue
                            )
            .
            PUT STREAM stmXMLOut UNFORMATTED
                v-out-string
            .
        END.
    end.
end.
END PROCEDURE.
PROCEDURE wp-XMLTagClose:
DEF INPUT PARAM iTagLevel AS INTEGER NO-UNDO.
DEF INPUT PARAM sTagName AS CHAR NO-UNDO.
    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    if v-bge-xml-bgefmt = "dbf":U
    then do:
    end.
    else do:
        assign
            v-out-string = substitute( "&1&2</&3>"
                                , ( if iTagLevel=0 then "":U else chr(10) )
                                , fill( " ", 4 * iTagLevel )
                                , sTagName
                        )
        .
        PUT STREAM stmXMLOut UNFORMATTED
            v-out-string
        .
    end.
end.
END PROCEDURE.
PROCEDURE wp-XMLWriteLog:
  DEF INPUT PARAMETER sFileName AS CHAR     NO-UNDO.
  DEF INPUT PARAMETER iLogLevel AS INTEGER  NO-UNDO.
  DEF INPUT PARAMETER sToWrite  AS CHAR     NO-UNDO.
define variable v-str              as character no-undo .
define variable v-error-append     as logical   no-undo .
define variable v-error-append-msg as character no-undo .
assign
  v-str = chr(10)
          + (if (iLogLevel = 0 or sToWrite = "&DLine" or sToWrite = "&Line") then "" else cur-time-string-sec() + " ")
          + (if sToWrite = "&Line" then fill("-", 80) else if sToWrite = "&DLine" then fill("=", 80) else sToWrite)
  v-str = replace(v-str, (chr(10) + chr(13)), chr(10) )
  v-str = replace(v-str, (chr(13) + chr(10)), chr(10) )
  v-str = replace(v-str, chr(10), (chr(13) + chr(10)) )
.
run bge/bge-log.p (input v-str) no-error .
if error-status:error then do:
  assign
    v-error-append     = yes
    v-error-append-msg = return-value
  .
end.
run gbl/fileapnd.p
  ( input sFileName
  , input v-str
  , input 10
  ) no-error .
if error-status:error then do:
  assign
    v-error-append     = yes
    v-error-append-msg = substitute( "&1&2&3"
                                    , v-error-append-msg
                                    , chr(10)
                                    , return-value
                                    )
  .
end.
if v-error-append
then do:
  return error substitute( "&1" , v-error-append-msg ) .
end.
END PROCEDURE.
PROCEDURE wp-XMLWriteEDT:
  DEF INPUT PARAMETER hEDT AS HANDLE NO-UNDO.
  DEF INPUT PARAMETER iLogLevel AS INTEGER  NO-UNDO.
  DEF INPUT PARAMETER sToWrite  AS CHAR     NO-UNDO.
    if valid-handle ( hEDT )
    then do:
        hEDT :move-to-eof().
        hEDT :insert-string(IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                        OR sToWrite = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        hEDT :insert-string(IF sToWrite = "&Line" THEN FILL("-", 80)
                ELSE IF sToWrite = "&DLine" THEN FILL("=", 80)
                ELSE FILL(" ", iLogLevel) + sToWrite).
        hEDT :insert-string(chr(10)).
    end.
    process events.
    output to 'bgescn.txt' append.
        put unformatted
            chr(10) string( (IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                        OR sToWrite = "&Line") THEN "" ELSE
                                        STRING(TODAY) + " " + STRING(TIME, "hh:mm:ss") + " ") )
            string( (IF sToWrite = "&Line" THEN FILL("-", 80)
                ELSE IF sToWrite = "&DLine" THEN FILL("=", 80)
                ELSE FILL(" ", iLogLevel) + sToWrite) )
        .
    output close.
END PROCEDURE.
PROCEDURE wp-XMLShowCNT:
  DEF INPUT PARAMETER hCNT     AS HANDLE   NO-UNDO.
    if valid-handle( hCNT )
    then do:
        ASSIGN hCNT :VISIBLE = TRUE.
    end.
END PROCEDURE.
PROCEDURE wp-XMLHideCNT:
  DEF INPUT PARAMETER hCNT     AS HANDLE   NO-UNDO.
    if valid-handle( hCNT )
    then do:
        ASSIGN hCNT :VISIBLE = FALSE.
    end.
END PROCEDURE.
PROCEDURE wp-XMLWriteCNT:
  DEF INPUT PARAMETER hCNT     AS HANDLE  NO-UNDO.
  DEF INPUT PARAMETER sCounter AS CHAR    NO-UNDO.
    if valid-handle( hCNT )
    then do:
        ASSIGN hCNT :SCREEN-VALUE = sCounter.
    end.
END PROCEDURE.
procedure bge-xml-write-header:
do
on error undo, return error
:
define input parameter p-xml-file-name  as character        no-undo.
define input parameter p-doc-name       as character        no-undo.
define input parameter p-version        as character        no-undo.
define input parameter p-db-num         as integer          no-undo.
define input parameter p-date-from      as date             no-undo.
define input parameter p-shift-num-from as integer          no-undo.
define input parameter p-date-to        as date             no-undo.
define input parameter p-shift-num-to   as integer          no-undo.
define input parameter p-obj-list       as character        no-undo.
define input parameter p-doc-type-list  as character        no-undo.
define input parameter p-pay-code       as logical          no-undo.
define input parameter p-cst            as logical          no-undo.
define input parameter p-parts          as logical          no-undo.
define input parameter p-chk-pay-code   as logical          no-undo.
define input parameter p-pay-desk       as logical          no-undo.
define input parameter p-pay-desk-cards as logical          no-undo.
define input parameter p-deleted        as logical          no-undo.
define input parameter p-opened-docs    as logical          no-undo.
define variable v-out-string    as character    no-undo.
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251".
assign
    v-out-string = substitute( "&1&2&3"
                        , "<?xml version='1.0' encoding='windows-1251'?>":U
                        , chr(10)
                        , "<IBS_Trade_House>":U )
.
put stream stmXMLOut unformatted
    v-out-string
.
run wp-XMLTagOpen(1, "header","").
if v-bge-xml-bgeflold = "oracle":u
then do:
  run wp-XMLTagOpen in this-procedure  ( 2, "delivery", "").
  run wp-XMLTagput in this-procedure ( 3, "message","", 1).
  run wp-XMLTagput in this-procedure ( 3, "from","IBS Trade House", 1).
  run wp-XMLTagput in this-procedure ( 3, "to","Oracle Retail", 1).
  run wp-XMLTagClose in this-procedure ( 2, "delivery"    ).
end.
run wp-XMLTagOpen( 2, "manifest", "").
run wp-XMLTagOpen( 3, "document", "").
run wp-XMLTagput( 4, "name", p-doc-name, 0).
run wp-XMLTagput( 4, "description", "", 0).
run wp-XMLTagput( 4, "version", p-version, 0).
run wp-XMLTagclose( 3, "document" ).
run wp-XMLTagclose( 2, "manifest" ).
run wp-XMLTagclose( 1, "header" ).
run wp-XMLTagOpen(1, "options","").
run wp-XMLTagput( 2, "exportDate",      string( today,              "99/99/9999" ), 0).
run wp-XMLTagput( 2, "exportDateXml",   bge-xml-date( today )                     , 0).
run wp-XMLTagput( 2, "exportTime",      string( time,               "HH:MM:SS"   ), 0).
run wp-XMLTagput( 2, "baseNum",         string( p-db-num                         ), 0).
run wp-XMLTagput( 2, "dateFrom",        string( p-date-from,        "99/99/9999" ), 0).
run wp-XMLTagput( 2, "dateFromXml",     bge-xml-date( p-date-from )               , 0).
run wp-XMLTagput( 2, "shiftNumFrom",    string( p-shift-num-from                 ), 2).
run wp-XMLTagput( 2, "dateTo",          string( p-date-to,          "99/99/9999" ), 0).
run wp-XMLTagput( 2, "dateToXml",       bge-xml-date( p-date-to )                 , 0).
run wp-XMLTagput( 2, "shiftNumTo",      string( p-shift-num-to                   ), 2).
run wp-XMLTagput( 2, "objList",                 p-obj-list                        , 0).
run wp-XMLTagput( 2, "docTypeList",             p-doc-type-list                   , 0).
run wp-XMLTagput( 2, "payCode",         string( p-pay-code                       ), 0).
run wp-XMLTagput( 2, "cst",             string( p-cst                            ), 0).
run wp-XMLTagput( 2, "parts",           string( p-parts                          ), 0).
run wp-XMLTagput( 2, "chkPayCode",      string( p-chk-pay-code                   ), 0).
run wp-XMLTagput( 2, "chkPayDesk",      string( p-pay-desk                       ), 0).
run wp-XMLTagput( 2, "chkPayDeskCards", string( p-pay-desk-cards                 ), 0).
run wp-XMLTagput( 2, "deletedDocs",     string( p-deleted                        ), 0).
run wp-XMLTagput( 2, "openedDocs",      string( p-opened-docs                    ), 0).
run wp-XMLTagClose(1, "options").
run wp-XMLTagOpen( 1, "body", "" ).
output stream stmXMLOut close.
end.
end procedure.
procedure xml-bge-write-footer:
do
on error undo, return error return-value
:
define input parameter p-xml-file-name as character    no-undo.
define variable v-error-num     as integer           no-undo.
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
run wp-XMLTagClose( 1, "body" ).
run wp-XMLTagClose( 0, "IBS_Trade_House" ).
output stream stmXMLOut close.
if v-bge-xml-bgeflold = "oracle":u
then do:
  define variable v-tmp-file-name         as character no-undo .
  define variable v-zip-file-name         as character no-undo .
  define variable v-exch-file-name        as character no-undo .
  define variable v-heap-file-name        as character no-undo .
  define variable v-i                     as integer   no-undo .
  define variable v-file-name             as character no-undo .
  define variable v-arc                   as character no-undo .
  define variable v-str                   as character no-undo .
  define variable v-exch-tmp-file-name    as character no-undo .
  define variable v-bge-xml-tmp-exch-dir  as character no-undo .
  define variable v-bge-xml-exch-dir      as character no-undo .
  define variable v-bge-xml-heap-dir      as character no-undo .
  define variable v-bge-xml-compress-heap as logical   no-undo .
  define variable v-home-dir              as character no-undo .
  define variable v-os-command            as character no-undo .
  get-key-value section "BGE" key "Dirfrg-acc" value v-home-dir.
  if v-home-dir = ?
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Не найден параметр ini-файла, определяющий каталог экспорта.":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  assign
    v-home-dir = v-home-dir
  .
  run gbl/dir-cre.p ( input v-home-dir ) no-error.
  if error-status :error
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Неверно задан каталог экспорта.":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  get-key-value section "BGE" key "dir-exch" value v-bge-xml-exch-dir .
  if v-bge-xml-exch-dir = ?
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Не найден параметр ini-файла, определяющий каталог экспорта (exch).":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  run gbl/dir-cre.p ( input v-bge-xml-exch-dir ) no-error.
  if error-status :error
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Неверно задан каталог экспорта (exch).":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  get-key-value section "BGE" key "dir-heap" value v-bge-xml-heap-dir.
  if v-bge-xml-heap-dir = ?
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Не найден параметр ini-файла, определяющий каталог экспорта (heap).":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  run gbl/dir-cre.p ( input v-bge-xml-heap-dir ) no-error.
  if error-status :error
  then do:
    undo, return error substitute( "&1&2&3"
                                  , "Неверно задан каталог экспорта (heap).":u
                                  , chr(10)
                                  , "Обратитесь к администратору.":u
                                  ).
  end.
  get-key-value section "BGE" key "heap-compress" value v-str.
  assign
    v-i = int(v-str)
  no-error .
  if v-i = ? or v-i = 0
  then do:
    assign
      v-bge-xml-compress-heap = no
    .
  end.
  else do:
    assign
      v-bge-xml-compress-heap = yes
    .
  end.
  assign
    v-arc = search( "exe/7za.exe":u )
  .
  if v-arc = ? or v-arc = ""
  then do:
    undo, return error("Не найдена программа 7za.exe, невозможно упаковать файлы в архив.":u).
  end.
  assign
    v-file-name            = entry(num-entries( p-xml-file-name , chr(47) ) , p-xml-file-name , chr(47) )
    v-tmp-file-name        = session :temp-directory + v-file-name + "DAT":u
    v-zip-file-name        = session :temp-directory + v-file-name + "DAT.zip":u
    v-bge-xml-tmp-exch-dir = v-bge-xml-exch-dir + ".000"
    v-exch-tmp-file-name   = v-bge-xml-tmp-exch-dir + chr(47) + v-file-name + "tmp":u
    v-exch-file-name       = v-bge-xml-exch-dir + chr(47) + v-file-name + "DAT.zip":u
    v-heap-file-name       = v-bge-xml-heap-dir + chr(47) + v-file-name + "DAT":u
  .
  run gbl/del-file.p (input v-tmp-file-name) .
  run gbl/del-file.p (input v-zip-file-name) .
  run bge/os_copy.p ("M", p-xml-file-name + "xm1":u, v-tmp-file-name, output v-error-num ).
  if v-error-num > 0
  then do:
      undo, return error substitute( "Ошибка переноса из &1 в &2. Код ошибки: &3"
                                   , p-xml-file-name + "xm1":u
                                   , v-tmp-file-name
                                   , v-error-num
                                   ).
  end.
  assign
    v-os-command     = substitute( "&1 a -tzip &2 &3"
                                 , v-arc
                                 , v-zip-file-name
                                 , v-tmp-file-name
                                 )
  .
  os-command silent value ( v-os-command ) .
  run gbl/del-file.p (input v-heap-file-name) .
  if v-bge-xml-compress-heap = no
  then do:
    run bge/os_copy.p ("C", v-tmp-file-name, v-heap-file-name, output v-error-num ).
    if v-error-num > 0
    then do:
        undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                     , v-tmp-file-name
                                     , v-heap-file-name
                                     , v-error-num
                                     ) .
    end.
  end.
  else do:
    run bge/os_copy.p ("C", v-zip-file-name, v-heap-file-name + ".zip", output v-error-num ).
    if v-error-num > 0
    then do:
        undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                     , v-zip-file-name
                                     , v-heap-file-name
                                     , v-error-num
                                     ) .
    end.
  end.
  run gbl/del-file.p (input v-tmp-file-name) .
  run gbl/dir-cre.p ( input v-bge-xml-tmp-exch-dir ) no-error.
  if error-status :error then do:
    undo, return error substitute( "&1&2&3"
                                  , substitute( "Не удалось создать каталог &1.", v-bge-xml-tmp-exch-dir )
                                  , chr(10)
                                  , "Обратитесь к администратору."
                                  ).
  end.
  run gbl/del-file.p (input v-exch-file-name) .
  run gbl/del-file.p (input v-exch-tmp-file-name ) .
  run bge/os_copy.p ("M", v-zip-file-name, v-exch-tmp-file-name, output v-error-num ).
  if v-error-num > 0
  then do:
    undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                  , v-zip-file-name
                                  , v-exch-tmp-file-name
                                  , v-error-num
                                  ) .
  end.
  run bge/os_copy.p ("M", v-exch-tmp-file-name, v-exch-file-name , output v-error-num ).
  if v-error-num > 0
  then do:
    undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                  , v-exch-tmp-file-name
                                  , v-exch-file-name
                                  , v-error-num
                                  ) .
  end.
  run gbl/del-file.p (input v-bge-xml-tmp-exch-dir ) .
end.
else do:
  run bge/os_copy.p ("M", p-xml-file-name + "xm1", p-xml-file-name + "xml", output v-error-num ).
  if v-error-num > 0
  then do:
    undo, return error substitute( "Ошибка копирования из &1 в &2. Код ошибки: &3"
                                  , p-xml-file-name + "xm1"
                                  , p-xml-file-name + "xml"
                                  , v-error-num
                                  ) .
  end.
end.
if opsys = "unix"
then do:
    os-command silent chmod 666 value (p-xml-file-name + "xml") 2>/dev/null.
end.
end.
end procedure.
procedure xml-bge-filename0:
define input parameter p-prefix   as character no-undo .
define input parameter p-name     as character no-undo .
define input parameter p-shared-process as logical no-undo .
define input parameter p-home-dir as character no-undo . // из ini-параметра [BGE] Dirfrg-acc
define output parameter p-xml-file-name  as character no-undo .
// define output parameter p-fullfnamenoext as character no-undo .
define output parameter p-locked         as logical      no-undo.
define variable v-fullfnamenoext as character no-undo .
define variable v-fileext        as character no-undo .
define variable v-fullfname      as character no-undo .
define variable v-error-num      as integer   no-undo .
do
on error undo, return error
:
  case v-bge-xml-bgeflold :
    when "old" then do:
      v-fullfnamenoext = substitute ("&1&2&3&4", p-home-dir, chr(47), p-name, v-bge-xml-db-num-str) .
      v-fileext       = ".xml":U .
      v-fullfname     = v-fullfnamenoext + v-fileext .
      p-xml-file-name = v-fullfname .
      run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
      if v-error-num > 0 then do:
        return error.
      end.
    end.
    when "var" then do:
      case p-prefix :
        when "doc" then do:
          v-fullfnamenoext = substitute ("&1&2&3&4", p-home-dir, chr(47), p-name, v-bge-xml-bgeflnm-doc) .
          v-fileext       = ".xml":U .
          v-fullfname     = v-fullfnamenoext + v-fileext .
          p-xml-file-name = v-fullfname .
        end.
        when "day" then do:
          v-fullfnamenoext = substitute ("&1&2&3&4", p-home-dir, chr(47), p-name, v-bge-xml-bgeflnm-day) .
          v-fileext       = ".xml":U .
          v-fullfname     = v-fullfnamenoext + v-fileext .
          p-xml-file-name = v-fullfname .
        end.
        otherwise do:
          v-fullfnamenoext = substitute ("&1&2&3", p-home-dir, chr(47), p-name) .
          v-fileext       = ".xml":U .
          v-fullfname     = v-fullfnamenoext + v-fileext .
          p-xml-file-name = v-fullfname .
        end.
      end case.
      run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
      if v-error-num > 0 then do:
        return error.
      end.
    end.
    when "new" then do:
                run bge/genfname.p (
                    input p-home-dir
                    , input p-prefix
                    , input ""
                    , input "xml"
                    , input ""
                    , output p-xml-file-name
                ).
    end.
    when "no-parameter" then do:
      if p-shared-process then do:
                    run bge/genfname.p (
                        input p-home-dir
                        , input "d"
                        , input ""
                        , input "xml"
                        , input ""
                        , output p-xml-file-name
                    ).
      end.
      else do:
        v-fullfnamenoext = substitute ("&1&2&3", p-home-dir, chr(47), p-name) .
        v-fileext       = ".xml":U .
        v-fullfname     = v-fullfnamenoext + v-fileext .
        p-xml-file-name = v-fullfname .
        run bge/os_copy.p ("D", p-xml-file-name, "", output v-error-num ).
        if v-error-num > 0 then do:
          return error.
        end.
      end.
    end.
  end case.
  assign
    p-xml-file-name = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
    p-locked = ( search ( p-xml-file-name + "lk" ) <> ? )
  .
end .
end procedure .
procedure xml-bge-filename :
do
on error undo, return error
:
define input parameter p-prefix             as character    no-undo.
define input parameter p-name               as character    no-undo.
define input parameter p-shared-process     as logical      no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.
define variable v-home-dir          as character no-undo .
define variable v-error-num         as integer   no-undo .
define variable v-bge-xml-heap-dir  as character no-undo .
    get-key-value section "BGE" key "Dirfrg-acc" value v-home-dir.
    if v-home-dir = ?
    then do:
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgeflold <> "oracle"
    then do:
      assign
          v-home-dir = v-home-dir + chr(47) + "exp-acc"
      .
    end.
    run gbl/dir-cre.p ( input v-home-dir ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgefmt = "dbf":U
    then do:
        assign
            p-xml-file-name = v-home-dir
            p-locked        = no
        .
    end.
    else do:
        run xml-bge-filename0 in this-procedure (p-prefix, p-name, p-shared-process, v-home-dir,
          output p-xml-file-name, output p-locked) .
    end.
    if v-bge-xml-bgeflold = "oracle"
    then do:
      get-key-value section "BGE" key "dir-heap" value v-bge-xml-heap-dir.
      if v-bge-xml-heap-dir = ?
      then do:
        undo, return error substitute( "&1&2&3"
                                      , "Не найден параметр ini-файла, определяющий каталог экспорта (heap).":u
                                      , chr(10)
                                      , "Обратитесь к администратору.":u
                                      ).
      end.
      run gbl/dir-cre.p ( input v-bge-xml-heap-dir ) no-error.
      if error-status :error
      then do:
        undo, return error substitute( "&1&2&3"
                                      , "Неверно задан каталог экспорта (heap).":u
                                      , chr(10)
                                      , "Обратитесь к администратору.":u
                                      ).
      end.
      if r-index( v-bge-xml-heap-dir, chr(47) ) > r-index( v-bge-xml-heap-dir, chr(92) ) then do:
        assign
          p-log-file-name = substring( v-bge-xml-heap-dir, 1, r-index( v-bge-xml-heap-dir, chr(47) ) ) + chr(47) + "actions.log"
        .
      end.
      else do:
        assign
          p-log-file-name = substring( v-bge-xml-heap-dir, 1, r-index( v-bge-xml-heap-dir, chr(92) ) ) + chr(47) + "actions.log"
        .
      end.
    end.
    else do:
      assign
          p-log-file-name = v-home-dir + chr(47) + "actions.log"
      .
    end.
    assign
       v-bge-xml-static-log-file-name = p-log-file-name
    .
end.
end procedure.
procedure bge-xml-read-config :
do
on error undo, return error return-value
:
define input  parameter p-last-date as date      no-undo .
define input  parameter p-db-num    as integer   no-undo .
    define variable v-bgeclall      as character     no-undo.
    define variable v-bgedict       as character     no-undo.
    define variable v-bgeshift      as character     no-undo.
    define variable v-par-type      as character     no-undo.
    define variable v-bgeflnm       as character     no-undo.
    define variable v-bgecliiv      as character     no-undo .
    define variable v-date-chars    as character case-sensitive  init "DD"      no-undo.
    define variable v-month-chars   as character case-sensitive  init "MM"      no-undo.
    define variable v-year-chars    as character case-sensitive  init "YY"      no-undo.
    define variable v-db-num-chars  as character case-sensitive  init "BBBBB"   no-undo.
    define variable v-db-num-str    as character     no-undo .
    define variable v-param-type      as character  no-undo .
    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-decimal   as decimal    no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-value-logical   as logical    no-undo .
    define variable v-tth             as handle      no-undo .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeclall':U
                      , output v-bgecliiv
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgecliiv = no
      .
    end.
    else do:
      run bge-xml-fill-tt-bgecliiv in this-procedure ( input v-bgecliiv ).
    end.
    delete object v-tth.
    assign
        v-bge-xml-bgeclall = no
        v-bge-xml-bgedict  = no
    .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeclall':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgeclall = no
      .
    end.
    else do:
      assign
        v-bge-xml-bgeclall = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgedict':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgedict = no
      .
    end.
    else do:
      assign
        v-bge-xml-bgedict = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgefmt':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgefmt  = "xml":U
      .
    end.
    else do:
      assign
        v-bge-xml-bgefmt  = v-value-character
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeshift':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
          v-bge-xml-shift-mode = no
      .
    end.
    else do:
      assign
          v-bge-xml-shift-mode = ( v-value-character = "distinct":U )
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeflold':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bge-xml-bgeflold = "no-parameter":U
      .
    end.
    else do:
      assign
        v-bge-xml-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.
    assign
      v-db-num-str          = ( if p-db-num <> ? then string(p-db-num ,"99999") else "":u )
      v-bge-xml-db-num-str  = v-db-num-str
    .
    if p-last-date <> ?
    then do:
        run adm/shattri.p ( input "get":U
                          , input  '':u
                          , input  0
                          , input  'bge-export':U
                          , input  'bgeflnm':U
                          , output v-value-character
                          , output v-value-date
                          , output v-value-decimal
                          , output v-value-integer
                          , output v-value-logical
                          , output v-param-type
                          , input-output table-handle v-tth
                          ) no-error .
        if error-status :error
        then do:
          assign
            v-bgeflnm = '':U
          .
        end.
        else do:
          assign
            v-bgeflnm = v-value-character
          .
        end.
        delete object v-tth.
        if v-bge-xml-bgeflold = "var"
        then do:
            if v-bgeflnm = ?
            or num-entries( v-bgeflnm ) < 2
            then do:
                assign
                    v-bge-xml-bgeflold = "new"
                .
            end.
            else do:
                assign
                    v-bge-xml-bgeflnm-doc = entry( 1, v-bgeflnm )
                    v-bge-xml-bgeflnm-day = entry( 2, v-bgeflnm )
                .
                assign
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-date-chars , string( day( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-month-chars, string( month( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-year-chars , substring( string( year( p-last-date ), "9999" ), 3, 2 ) )
                    v-bge-xml-bgeflnm-doc = replace( v-bge-xml-bgeflnm-doc, v-db-num-chars, v-db-num-str )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-date-chars , string( day( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-month-chars, string( month( p-last-date ), "99" ) )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-year-chars , substring( string( year( p-last-date ), "9999" ), 3, 2 ) )
                    v-bge-xml-bgeflnm-day = replace( v-bge-xml-bgeflnm-day, v-db-num-chars, v-db-num-str )
                .
            end.
        end.
    end.
end.
end procedure.
procedure bge-xml-get-ref-filename :
define input parameter p-in-file-name       as character        no-undo.
define output parameter p-home-dir          as character        no-undo.
define output parameter p-out-file-name     as character        no-undo.
define output parameter p-locked            as logical          no-undo.
    define variable v-counter       as integer      no-undo.
    define variable v-error-level   as integer      no-undo.
do
on error undo, return error
:
    run bge/bge-ini.p (
          input "bge"
        , output p-home-dir
    ).
    if return-value <> "OK"
    then do:
        undo, return error.
    end.
    assign
        p-home-dir = p-home-dir + "\dict":U
    .
    run bge/dir_cd.p (
        input p-home-dir
        , input "CA"
    ).
    if return-value = "ERROR"
    then do:
        undo, return error.
    end.
    assign
        p-out-file-name = substitute( "&1\&2.", p-home-dir, p-in-file-name )
    .
    assign
        p-locked = ( search( p-out-file-name + "xml" ) <> ? ).
    .
    wait-lock:
    do v-counter = 1 TO 3
    :
        p-locked = ( search( p-out-file-name + "lk" ) <> ? ).
        if p-locked = no
        then do:
            leave wait-lock.
        end.
        else do:
            readkey pause 1.
        end.
    END.
    if p-locked = yes
    then do:
        undo, return error.
    end.
    run bge/os_copy.p (
          input "D":U
        , input p-out-file-name + "xml":U
        , input "":U
        , output v-error-level
    ).
    if v-error-level > 0
    then do:
        undo, return error.
    end.
end.
end procedure.
procedure bge-xml-write-ref-header :
define input parameter p-bge-name as character        no-undo.
define input parameter p-file-name as character        no-undo.
    define variable v-out-string    as character    no-undo.
do
on error undo, return error
:
    output stream stmXMLOut to value( p-file-name + "xm1") convert target "1251".
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>":U
    .
    assign
        v-out-string = substitute( "&1&2"
                            , chr(10)
                            , "<IBS_Trade_House>":U )
    .
    put stream stmXMLOut unformatted
        v-out-string
    .
    run wp-XMLTagOpen( 1, "header", "" ).
    if v-bge-xml-bgeflold = "oracle":u
    then do:
      run wp-XMLTagOpen in this-procedure  ( 2, "delivery", "").
      run wp-XMLTagput in this-procedure ( 3, "message","", 1).
      run wp-XMLTagput in this-procedure ( 3, "from","IBS Trade House", 1).
      run wp-XMLTagput in this-procedure ( 3, "to","Oracle Retail", 1).
      run wp-XMLTagClose in this-procedure ( 2, "delivery"    ).
    end.
    else do:
      run wp-XMLTagOpen( 2, "delivery", "" ).
      run wp-XMLTagOpen( 3, "to", "" ).
      run wp-XMLTagClose( 3, "to" ).
      run wp-XMLTagOpen( 3, "from", "" ).
      run wp-XMLTagClose( 3, "from" ).
      run wp-XMLTagClose( 2, "delivery" ).
    end.
    run wp-XMLTagOpen( 2, "manifest", "" ).
    run wp-XMLTagOpen( 3, "document", "" ).
    run wp-XMLTagPut( 4, "name", p-bge-name, 0 ).
    run wp-XMLTagPut( 4, "description", "", 0 ).
    run wp-XMLTagClose( 3, "document" ).
    run wp-XMLTagClose( 2, "manifest" ).
    run wp-XMLTagClose( 1, "header" ).
    run wp-XMLTagOpen( 1, "body", "" ).
end.
end procedure.
procedure bge-xml-write-ref-footer :
define input parameter p-file-name as character        no-undo.
    define variable v-error-level   as integer      no-undo.
do
on error undo, return error
:
    run wp-XMLTagClose in this-procedure ( input 1, input "body":U ).
    run wp-XMLTagClose in this-procedure ( input 0, input "IBS_Trade_House":U ).
    output stream stmXMLOut close.
    run bge/os_copy.p (
          input "M":U
        , input p-file-name + "xm1":U
        , input p-file-name + "xml":U
        , output v-error-level
    ).
    if v-error-level > 0
    then do:
        undo, return error.
    end.
end.
end procedure.
procedure bge-xml-out-dir :
define output parameter p-out-dir       as character    no-undo.
define output parameter p-log-file-name as character    no-undo.
do
on error undo, return error
:
    p-out-dir = ibs.th.gbl.gbl-inipar:dirfrgAcc .
    if p-out-dir = ?
    then do:
        message
          skip substitute("Не найден параметр ini-файла, определяющий каталог экспорта (&1)."
                        , ibs.th.gbl.gbl-inipar:dirfrgAccKeyName)
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgeflold <> "oracle" then assign
      p-out-dir = substitute( "&1&2exp-acc":U, p-out-dir, chr(47) )
    .
    run gbl/dir-cre.p ( input p-out-dir ) no-error.
    if error-status :error  then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 0
            , input substitute( "Ошибка проверки или создания каталога &1. &2. &3."
                                , p-out-dir
                                , return-value
                                , trim( error-status :get-message( 1 ) )
                                )
        ).
        undo, return error.
    end.
    assign
        v-bge-xml-static-log-file-name = substitute( "&1&2actions.log":U, p-out-dir, chr(47) )
        p-log-file-name                = substitute( "&1&2actions.log":U, p-out-dir, chr(47) )
    .
end.
end procedure.
procedure bge-xml-out-dir2 :
define output parameter p-out-dir       as character    no-undo.
define output parameter p-out-dirR      as character    no-undo.
define output parameter p-log-file-name as character    no-undo.
do
on error undo, return error
:
    p-out-dir = ibs.th.gbl.gbl-inipar:dirfrgAcc .
    if p-out-dir = ?
    then do:
        message
          skip substitute("Не найден параметр ini-файла, определяющий каталог экспорта (&1)."
                        , ibs.th.gbl.gbl-inipar:dirfrgAccKeyName)
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if v-bge-xml-bgeflold <> "oracle" then assign
          p-out-dirR = substitute( "&1&2exp-reestr":U, p-out-dir, chr(47) )
          p-out-dir  = substitute( "&1&2exp-acc":U,    p-out-dir, chr(47) )
      .
    else p-out-dirR = p-out-dir .
    run gbl/dir-cre.p ( input p-out-dir ) no-error.
    if error-status :error  then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 0
            , input substitute( "Ошибка проверки или создания каталога &1. &2. &3."
                                , p-out-dir
                                , return-value
                                , error-status :get-message( 1 )
                                )
        ).
        undo, return error.
    end.
    if p-out-dirR <> p-out-dir then do:
      run gbl/dir-cre.p ( input p-out-dirR ) no-error.
      if error-status :error then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file-name
            , input 0
            , input substitute( "Ошибка проверки или создания каталога &1. &2. &3."
                                , p-out-dirR
                                , return-value
                                , error-status :get-message( 1 )
                                )
        ).
        p-out-dirR = p-out-dir .
      end.
    end .
    assign
      v-bge-xml-static-log-file-name = substitute( "&1&2actions.log":U, p-out-dir, chr(47) )
      p-log-file-name                = substitute( "&1&2actions.log":U, p-out-dir, chr(47) )
    .
end.
end procedure.
procedure bge-xml-out-file :
do
on error undo, return error
:
define input parameter p-out-dir            as character        no-undo.
define input parameter p-prefix             as character        no-undo.
define input parameter p-sheduled           as logical          no-undo.
define output parameter p-xml-file-name     as character        no-undo.
define output parameter p-locked            as logical          no-undo.
define variable v-home-dir      as character     no-undo.
define variable v-error-num     as integer       no-undo.
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.
    if v-bge-xml-bgefmt = "dbf":U
    then do:
        assign
            p-xml-file-name = p-out-dir
            p-locked        = no
        .
    end.
    else do:
        if v-bge-xml-bgeflold = "firm":U
        then do:
            run bge/genfname.p (
                  input p-out-dir
                , input p-prefix
                , input "":U
                , input "arj":U
                , input "":U
                , output p-xml-file-name
            ).
        end.
        else do:
            run bge/genfname.p (
                  input p-out-dir
                , input p-prefix
                , input "":U
                , input "xml":U
                , input "":U
                , output p-xml-file-name
            ).
        end.
        assign
            p-xml-file-name = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
            p-locked = ( search ( p-xml-file-name + "lk":U ) <> ? )
        .
    end.
end.
end procedure.
procedure bge-xml-init-ext-doc-type :
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_ext-doc-type     for temp_ext-doc-type.
do
for buf_temp_ext-doc-type
on error undo, return error
:
    empty temp-table buf_temp_ext-doc-type.
    do v-counter = 1 to num-entries( 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
    :
        create buf_temp_ext-doc-type.
        assign
            buf_temp_ext-doc-type.edt-key               = v-counter
            buf_temp_ext-doc-type.ext-doc-type          = entry( v-counter, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
            buf_temp_ext-doc-type.ext-doc-type-label    = entry( v-counter, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
        .
    end.
end.
end procedure.
procedure bge-xml-get-decimal-shift-num :
define input parameter p-shift-date     as date             no-undo.
define input parameter p-shift-num      as integer          no-undo.
define output parameter p-shift-decimal as decimal          no-undo.
do
on error undo, return error
:
    assign
        p-shift-decimal = ( p-shift-date - 01/01/1990 ) + truncate( p-shift-num / 1000, 3 )
    .
end.
end procedure.
procedure bge-xml-ora-exp-filename :
  define input  parameter p-table-name  as character no-undo .
  define input  parameter p-doc-code    as character no-undo .
  define input  parameter p-obj-code    as integer   no-undo .
  define output parameter p-filename    as character no-undo .
  define output parameter p-seq-num     as integer   no-undo .
  define variable v-ora-exp-seq     as integer   no-undo .
  define variable v-ora-exp-seq-str as character no-undo .
  define variable v-home-dir        as character no-undo.
do
on error undo, return error return-value
:
  if v-bge-xml-bgeflold = "oracle":u
  then do:
    get-key-value section "BGE" key "Dirfrg-acc" value v-home-dir.
    if v-home-dir = ?
    then do:
      undo, return error substitute( "&1&2&3":U
                                    , "Не найден параметр ini-файла, определяющий каталог экспорта.":U
                                    , chr(10)
                                    , "Обратитесь к администратору.":U
                                    ).
    end.
    assign
        v-home-dir = v-home-dir
    .
    run gbl/dir-cre.p ( input v-home-dir ) no-error.
    if error-status :error
    then do:
      undo, return error substitute( "&1&2&3":U
                                    , "Неверно задан каталог экспорта.":U
                                    , chr(10)
                                    , "Обратитесь к администратору.":U
                                    ).
    end.
    assign
      v-ora-exp-seq = ?
    .
    if  p-table-name <> ? and
        p-doc-code <> ?
    then do:
      run bge/get-oesq.p ( input p-table-name
                         , input p-doc-code
                         , output v-ora-exp-seq
                         ) no-error .
      if error-status :error = yes
      then do:
        undo, return error return-value .
      end.
    end.
    if v-ora-exp-seq = ?
    then do:
      run bge/oesq-get.p ( output v-ora-exp-seq ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
    end.
    if p-table-name <> ? and
       p-doc-code   <> ?
    then do:
      run bge/oesqdoc.p ( input p-table-name
                        , input p-doc-code
                        , input v-ora-exp-seq
                        ) no-error .
      if error-status :error = yes
      then do:
        undo, return error return-value .
      end.
    end.
    assign
      p-seq-num  = v-ora-exp-seq
      p-filename = substitute("&1/&2-000_&3."
                             , v-home-dir
                             , ( if p-obj-code < 1000 then string( p-obj-code, "999") else string(p-obj-code))
                             , string(v-ora-exp-seq , "999999999")
                             )
    .
  end.
end.
end procedure.
procedure bge-xml-date-to-str :
  define input  parameter p-date  as date      no-undo .
  define output parameter p-str   as character no-undo .
do
on error undo, return error return-value
:
  if p-date <> ?
  then do:
    assign
      p-str = substitute( "&1-&2-&3"
                        , string( year(p-date)  , "9999")
                        , string( month(p-date) , "99"  )
                        , string( day(p-date)   , "99"  )
                        )
    .
  end.
  else do:
    assign
      p-str = ?
    .
  end.
end.
end procedure.
procedure bge-xml-date-str-to-str :
  define input  parameter p-date-str  as character no-undo .
  define output parameter p-str       as character no-undo .
  define variable v-date          as date      no-undo .
  define variable v-date-valid    as logical   no-undo .
  define variable v-error-message as character no-undo .
do
on error undo, return error return-value
:
  assign
    p-str = ?
  .
  if p-date-str = ? or p-date-str = ""
  then do:
    return .
  end.
  run strtdate in this-procedure ( input  p-date-str
                                 , output v-date
                                 , output v-date-valid
                                 , output v-error-message
                                 ).
  if v-date-valid <> true
  then do:
    return .
  end.
  assign
    p-str = substitute( "&1-&2-&3"
                      , string( year(v-date)  , "9999")
                      , string( month(v-date) , "99"  )
                      , string( day(v-date)   , "99"  )
                      )
  .
end.
end procedure.
procedure bge-xml-fill-tt-bgecliiv :
  define input  parameter p-str as character no-undo .
  define buffer buf_tt-bge-xml-bgecliiv for tt-bge-xml-bgecliiv.
  define buffer buf_clients             for ub.clients.
  define variable v-i         as integer   no-undo .
  define variable v-count     as integer   no-undo .
  define variable v-cli-count as integer   no-undo .
  define variable v-client    as character no-undo .
  define variable v-obj-type  as character no-undo .
  define variable v-obj-code  as integer   no-undo .
do
on error undo, return error return-value
:
  empty temp-table buf_tt-bge-xml-bgecliiv.
  assign
    v-bge-xml-bgecliiv = no
    v-cli-count        = num-entries(p-str,';')
  .
  if v-cli-count > 0
  then do:
    _cli-cycle:
    do v-i = 1 to v-cli-count
    :
      assign
        v-client = entry(v-i , p-str, ';')
      .
      if num-entries(v-client) <> 2
      then do:
        undo, return error substitute("Неправильный формат записи контрагента в параметре 'bgecliiv'. Позиция записи &1." , v-i).
      end.
      assign
        v-obj-type = entry(1, v-client)
      .
      assign
        v-obj-code = integer(entry(2, v-client))
      no-error .
      if error-status :error
      then do:
        undo, return error substitute("Неправильный формат записи кода контрагента в параметре 'bgecliiv'. Позиция записи &1." , v-i).
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = v-obj-type
          and buf_clients.obj-code = v-obj-code
      no-error.
      if not available buf_clients
      then do:
        next _cli-cycle.
      end.
      find first buf_tt-bge-xml-bgecliiv no-lock
        where buf_tt-bge-xml-bgecliiv.obj-type = buf_clients.obj-type
          and buf_tt-bge-xml-bgecliiv.obj-code = buf_clients.obj-code
      no-error .
      if available buf_tt-bge-xml-bgecliiv
      then do:
        next _cli-cycle.
      end.
      create buf_tt-bge-xml-bgecliiv.
      assign
        buf_tt-bge-xml-bgecliiv.obj-type = buf_clients.obj-type
        buf_tt-bge-xml-bgecliiv.obj-code = buf_clients.obj-code
      .
    end.
  end.
  else do:
    assign
      v-bge-xml-bgecliiv = no
    .
    return .
  end.
  find first buf_tt-bge-xml-bgecliiv no-lock no-error .
  if available buf_tt-bge-xml-bgecliiv
  then do:
    assign
      v-bge-xml-bgecliiv = yes
    .
  end.
end.
end procedure.
procedure bge-xml-resolve-ext-doc-type :
  define input  parameter p-ext-doc-type      as character no-undo .
  define input  parameter p-obj-type          as character no-undo .
  define input  parameter p-obj-code          as integer   no-undo .
  define output parameter p-out-ext-doc-type  as character no-undo .
  define buffer buf_tt-bge-xml-bgecliiv for tt-bge-xml-bgecliiv.
do
on error undo, return error return-value
:
  assign
    p-out-ext-doc-type = p-ext-doc-type
  .
  if p-ext-doc-type <> 'ie':U
  then do:
    return .
  end.
  if v-bge-xml-bgecliiv = yes
  then do:
    find first buf_tt-bge-xml-bgecliiv no-lock
      where buf_tt-bge-xml-bgecliiv.obj-type = p-obj-type
        and buf_tt-bge-xml-bgecliiv.obj-code = p-obj-code
    no-error .
    if available buf_tt-bge-xml-bgecliiv
    then do:
      assign
        p-out-ext-doc-type = 'iv':U
      .
    end.
  end.
end.
end procedure.
procedure safe-wp-xmltagput :
  define input  parameter pTagLevel   as integer   no-undo .
  define input  parameter pTagName    as character no-undo .
  define input  parameter pParValue   as character no-undo .
  define input  parameter pFlagEmpty  as integer   no-undo .
do
on error undo, return error return-value
:
  if v-bge-xml-bgeflold = "oracle":u
  then do:
    return .
  end.
  run wp-xmltagput in this-procedure ( input pTagLevel
                                     , input pTagName
                                     , input pParValue
                                     , input pFlagEmpty
                                     ).
end.
end procedure.
define temp-table tt-docs no-undo
  field doc-type as character
  field doc-code as character
  field obj-type as character
  field obj-code as integer
  field pck-code as integer
  field is-sel   as logical
index pi as primary unique
  doc-type
  doc-code
index sel
  is-sel
  pck-code
.
define buffer buf_tt-docs for tt-docs.
FUNCTION display-selected RETURNS CHARACTER
  ( BUFFER loc_tt-docs FOR tt-docs )  FORWARD.
DEFINE BUTTON b-exit
     LABEL "Выход"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-start
     LABEL "Выгрузить"
     SIZE 10 BY 1.
DEFINE VARIABLE fi-doc-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Код документа"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE fi-pck-code AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Код пакета"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 77.5 BY 11.5.
DEFINE QUERY br-docs FOR
      buf_tt-docs SCROLLING.
DEFINE BROWSE br-docs
  QUERY br-docs DISPLAY
      display-selected(BUFFER buf_tt-docs) FORMAT "X(1)" COLUMN-LABEL "*"
      buf_tt-docs.doc-type FORMAT "X(10)" COLUMN-LABEL "Тип документа"
      buf_tt-docs.doc-code FORMAT "X(18)" COLUMN-LABEL "Код документа"
      buf_tt-docs.pck-code FORMAT ">>>>>>>>>9" COLUMN-LABEL "Номер пакета"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 76 BY 9.75 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-mark AT ROW 1 COL 11 WIDGET-ID 28
     b-help AT ROW 1 COL 66 WIDGET-ID 30
     fi-doc-code AT ROW 3 COL 15 COLON-ALIGNED WIDGET-ID 18
     fi-pck-code AT ROW 3 COL 49.5 COLON-ALIGNED WIDGET-ID 20
     br-docs AT ROW 4.5 COL 2 WIDGET-ID 200
     b-start AT ROW 14.5 COL 67.5 WIDGET-ID 26
     RECT-1 AT ROW 4.25 COL 1 WIDGET-ID 10
     SPACE(0.24) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выгрузить" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  apply "go":U to frame Dialog-Frame.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
  run proc-b-mark in this-procedure no-error .
  if error-status :error = yes
  then do:
    message
      "":U
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    return no-apply.
  end.
END.
ON CHOOSE OF b-start IN FRAME Dialog-Frame
DO:
  run proc-b-start in this-procedure no-error .
  if error-status :error = yes
  then do:
    message
      "":U
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    return no-apply.
  end.
END.
ON LEAVE OF fi-doc-code IN FRAME Dialog-Frame
DO:
END.
ON RETURN OF fi-doc-code IN FRAME Dialog-Frame
DO:
  run proc-doc-code in this-procedure no-error .
  if error-status :error = yes
  then do:
    message
      "":U
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    return no-apply.
  end.
END.
ON LEAVE OF fi-pck-code IN FRAME Dialog-Frame
DO:
END.
ON RETURN OF fi-pck-code IN FRAME Dialog-Frame
DO:
  run proc-pck-code in this-procedure no-error .
  if error-status :error = yes
  then do:
    message
      "":U
      return-value skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
    view-as alert-box error.
    return no-apply.
  end.
END.
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign
    fi-doc-code = ?
    fi-pck-code = ?
  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE cb-fill_bge-xml_clients :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
    define buffer buf_temp_bge-xml_clients      for temp_bge-xml_clients.
do
for buf_temp_bge-xml_clients
on error undo, return error
:
    find first buf_temp_bge-xml_clients
         where buf_temp_bge-xml_clients.obj-type = p-obj-type
           and buf_temp_bge-xml_clients.obj-code = p-obj-code
    no-error.
    if not available buf_temp_bge-xml_clients
    then do:
        create buf_temp_bge-xml_clients.
        assign
            buf_temp_bge-xml_clients.obj-type = p-obj-type
            buf_temp_bge-xml_clients.obj-code = p-obj-code
        .
    end.
end.
END PROCEDURE.
PROCEDURE cb-fill_bge-xml_dis-card :
define input parameter p-d-card as character        no-undo.
    define buffer buf_temp_bge-xml_dis-card     for temp_bge-xml_dis-card.
do
for buf_temp_bge-xml_dis-card
on error undo, return error
:
    find first buf_temp_bge-xml_dis-card
         where buf_temp_bge-xml_dis-card.d-card = p-d-card
    no-error.
    if not available buf_temp_bge-xml_dis-card
    then do:
        create buf_temp_bge-xml_dis-card.
        assign
            buf_temp_bge-xml_dis-card.d-card = p-d-card
        .
    end.
end.
END PROCEDURE.
PROCEDURE cb-fill_bge-xml_goods :
define input parameter p-gds-code   as integer          no-undo.
do
on error undo, return error
:
    find first temp_bge-xml_goods
         where temp_bge-xml_goods.gds-code = p-gds-code
    no-error.
    if not available temp_bge-xml_goods
    then do:
        create temp_bge-xml_goods.
        assign
            temp_bge-xml_goods.gds-code = p-gds-code
        .
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-doc-code fi-pck-code
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-mark b-help RECT-1 fi-doc-code fi-pck-code br-docs b-start
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-docs FOR EACH buf_tt-docs.
END PROCEDURE.
PROCEDURE fill-temp-del-doc-code :
do
on error undo, return error
:
define input parameter p-doc-code   as character    no-undo.
    define buffer buf_temp_del-doc-code     for temp_del-doc-code.
    create buf_temp_del-doc-code.
    assign
        buf_temp_del-doc-code.doc-code = p-doc-code
    .
end.
END PROCEDURE.
PROCEDURE fill-temp-doc-code :
do
on error undo, return error
:
define input parameter p-doc-code   as character    no-undo.
    define buffer buf_temp_doc-code     for temp_doc-code.
    create buf_temp_doc-code.
    assign
        buf_temp_doc-code.doc-code = p-doc-code
    .
end.
END PROCEDURE.
PROCEDURE fill-temp-ord-doc-code :
  define input  parameter p-doc-code  as character no-undo .
  define buffer buf_temp_ord-doc-code for temp_ord-doc-code.
do for buf_temp_ord-doc-code
on error undo, return error return-value
:
  find first buf_temp_ord-doc-code
    where buf_temp_ord-doc-code.doc-code = p-doc-code
  no-error .
  if not available buf_temp_ord-doc-code
  then do:
    create buf_temp_ord-doc-code.
    assign
      buf_temp_ord-doc-code.doc-code = p-doc-code
    .
  end.
end.
END PROCEDURE.
PROCEDURE fill-temp-pr-doc-num :
define input parameter p-doc-num as character    no-undo.
    define buffer buf_temp_pr-doc-num       for temp_pr-doc-num.
do
for buf_temp_pr-doc-num
on error undo, return error
:
    create buf_temp_pr-doc-num.
    assign
        buf_temp_pr-doc-num.doc-num = p-doc-num
    .
end.
END PROCEDURE.
PROCEDURE open-br :
do
on error undo, return error return-value
:
  run waitfram-show in this-procedure ( input "Ждите...":U ).
  open query br-docs
    for each buf_tt-docs no-lock indexed-reposition.
  run waitfram-hide in this-procedure .
end.
END PROCEDURE.
PROCEDURE proc-b-exit :
END PROCEDURE.
PROCEDURE proc-b-mark :
  define variable v-log as logical   no-undo .
do
on error undo, return error return-value
:
  if not available buf_tt-docs
  then do:
    return .
  end.
  assign
    buf_tt-docs.is-sel = not buf_tt-docs.is-sel
  .
  v-log = br-docs:refresh() in frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE proc-b-start :
define variable v-log           as logical   no-undo .
define variable v-host-code     as integer   no-undo .
define variable v-obj-type      as character no-undo .
define variable v-obj-code      as integer   no-undo .
define variable v-need-checks   as logical   no-undo .
define variable v-xml-file-name as character no-undo .
define variable v-log-file-name as character no-undo .
define variable v-out-dir       as character no-undo .
define variable v-error-message as character no-undo .
do
on error undo, return error return-value
:
  find first buf_tt-docs
    where buf_tt-docs.is-sel = yes
  no-error .
  if not available buf_tt-docs
  then do:
    message
      "Не выбран документ"
    view-as alert-box error.
    return .
  end.
  run waitfram-show in this-procedure ( input "Ждите...":U ).
  run bge-xml-out-dir in this-procedure ( output v-out-dir
                                        , output v-log-file-name
                                        ).
  for each buf_tt-docs
    where buf_tt-docs.is-sel = yes
      and buf_tt-docs.pck-code <> ?
  by buf_tt-docs.pck-code
  :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_tt-docs.obj-type
  ,input  buf_tt-docs.obj-code
  ,output v-host-code
  )  .
    run bge/doc-incr.p ( input v-host-code
                       , input today
                       , input today
                       , input buf_tt-docs.obj-type
                       , input buf_tt-docs.obj-code
                       , input yes
                       , input yes
                       , input yes
                       , input yes
                       , input yes
                       , input yes
                       , input yes
                       , input v-xml-file-name
                       , input v-log-file-name
                       , input this-procedure :handle
                       , input ?
                       , input ?
                       , buf_tt-docs.doc-type
                       , buf_tt-docs.doc-code
                       ) no-error.
    if error-status :error
    then do:
      assign
        v-error-message = substitute( "*** Ошибка экспорта документа &1 с кодом: &2.&3&4&5"
                                    , buf_tt-docs.doc-type
                                    , buf_tt-docs.doc-code
                                    , chr(10)
                                    , return-value
                                    , trim(error-status :get-message(1))
                                    )
      .
      run wp-XMLWriteLog in this-procedure ( input v-log-file-name
                                            , input 1
                                            , input v-error-message
                                            ).
      message
        v-error-message
      view-as alert-box error.
      return .
    end.
  end.
  run waitfram-hide in this-procedure .
  message
    "Выгрузка завершена!":U
  view-as alert-box information.
end.
END PROCEDURE.
PROCEDURE proc-doc-code :
  define buffer buf_trn-doc   for ub.trn-doc.
  define buffer buf_price-doc for ub.price-doc.
  define buffer buf_c-trn-doc for ub.c-trn-doc.
  define buffer buf_ord-doc   for ub.ord-doc.
do
on error undo, return error return-value
:
  empty temp-table buf_tt-docs.
  assign
    fi-pck-code = ?
  .
  display
    fi-pck-code
  with frame Dialog-Frame.
  assign
    fi-doc-code
  .
  if fi-doc-code = ""
  then do:
    return .
  end.
  run waitfram-show in this-procedure ( input "Поиск документов...":U ) .
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = fi-doc-code
  no-error .
  if available buf_trn-doc
  then do:
    create buf_tt-docs.
    assign
      buf_tt-docs.doc-type = 'trn-doc':U
      buf_tt-docs.doc-code = buf_trn-doc.doc-code
      buf_tt-docs.obj-type = buf_trn-doc.obj-type
      buf_tt-docs.obj-code = buf_trn-doc.obj-code
    .
    run bge/get-oesq.p ( input 'trn-doc':U
                       , input buf_trn-doc.doc-code
                       , output buf_tt-docs.pck-code
                       ) .
  end.
  find first buf_price-doc no-lock
    where buf_price-doc.doc-num = fi-doc-code
  no-error .
  if available buf_price-doc
  then do:
    create buf_tt-docs.
    assign
      buf_tt-docs.doc-type = 'price-doc':U
      buf_tt-docs.doc-code = buf_price-doc.doc-num
      buf_tt-docs.obj-type = buf_price-doc.obj-type
      buf_tt-docs.obj-code = buf_price-doc.obj-code
    .
    run bge/get-oesq.p ( input 'price-doc':U
                       , input buf_price-doc.doc-num
                       , output buf_tt-docs.pck-code
                       ) .
  end.
  find first buf_c-trn-doc no-lock
    where buf_c-trn-doc.doc-code = fi-doc-code
      and buf_c-trn-doc.is-del   = yes
  no-error .
  if available buf_c-trn-doc
  then do:
    create buf_tt-docs.
    assign
      buf_tt-docs.doc-type = 'c-trn-doc':U
      buf_tt-docs.doc-code = buf_c-trn-doc.doc-code
      buf_tt-docs.obj-type = buf_c-trn-doc.obj-type
      buf_tt-docs.obj-code = buf_c-trn-doc.obj-code
    .
    run bge/get-oesq.p ( input 'c-trn-doc':U
                       , input buf_c-trn-doc.doc-code
                       , output buf_tt-docs.pck-code
                       ) .
  end.
  find first buf_ord-doc no-lock
    where buf_ord-doc.doc-code = fi-doc-code
  no-error .
  if available buf_ord-doc
  then do:
    create buf_tt-docs.
    assign
      buf_tt-docs.doc-type = 'ord-doc':U
      buf_tt-docs.doc-code = buf_ord-doc.doc-code
      buf_tt-docs.obj-type = buf_ord-doc.obj-type
      buf_tt-docs.obj-code = buf_ord-doc.obj-code
    .
    run bge/get-oesq.p ( input 'ord-doc':U
                       , input buf_ord-doc.doc-code
                       , output buf_tt-docs.pck-code
                       ) .
  end.
  run waitfram-hide in this-procedure .
  run open-br in this-procedure .
end.
END PROCEDURE.
PROCEDURE proc-pck-code :
define buffer buf_doc-attr      for ub.doc-attr.
define buffer buf_ord-doc-attr  for ub.ord-doc-attr.
define buffer buf_trn-doc   for ub.trn-doc.
define buffer buf_price-doc for ub.price-doc.
define buffer buf_c-trn-doc for ub.c-trn-doc.
define buffer buf_ord-doc   for ub.ord-doc.
define variable v-doc-code  as character no-undo .
do
on error undo, return error return-value
:
  empty temp-table buf_tt-docs.
  assign
    fi-doc-code = ?
  .
  display
    fi-doc-code
  with frame Dialog-Frame.
  assign
    fi-pck-code
  .
  assign
    v-doc-code = string(fi-pck-code)
  .
  if v-doc-code = ""
  then do:
    return .
  end.
  run waitfram-show in this-procedure ( input "Поиск документов...":U ) .
  find first buf_doc-attr no-lock
    where buf_doc-attr.attr-code  = 'ora-exp-seq-num':U
      and buf_doc-attr.attr-value = v-doc-code
  no-error.
  if available buf_doc-attr
  then do:
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-attr.doc-code
    no-error .
    if available buf_trn-doc
    then do:
      create buf_tt-docs.
      assign
        buf_tt-docs.doc-type = 'trn-doc':U
        buf_tt-docs.doc-code = buf_trn-doc.doc-code
        buf_tt-docs.obj-type = buf_trn-doc.obj-type
        buf_tt-docs.obj-code = buf_trn-doc.obj-code
      .
      run bge/get-oesq.p ( input 'trn-doc':U
                        , input buf_trn-doc.doc-code
                        , output buf_tt-docs.pck-code
                        ) .
    end.
    else do:
      find first buf_price-doc no-lock
        where buf_price-doc.doc-num = buf_doc-attr.doc-code
      no-error .
      if available buf_price-doc
      then do:
        create buf_tt-docs.
        assign
          buf_tt-docs.doc-type = 'price-doc':U
          buf_tt-docs.doc-code = buf_price-doc.doc-num
          buf_tt-docs.obj-type = buf_price-doc.obj-type
          buf_tt-docs.obj-code = buf_price-doc.obj-code
        .
        run bge/get-oesq.p ( input 'price-doc':U
                          , input buf_price-doc.doc-num
                          , output buf_tt-docs.pck-code
                          ) .
      end.
      else do:
        find first buf_c-trn-doc no-lock
          where buf_c-trn-doc.doc-code = buf_doc-attr.doc-code
            and buf_c-trn-doc.is-del   = yes
        no-error .
        if available buf_c-trn-doc
        then do:
          create buf_tt-docs.
          assign
            buf_tt-docs.doc-type = 'c-trn-doc':U
            buf_tt-docs.doc-code = buf_c-trn-doc.doc-code
            buf_tt-docs.obj-type = buf_c-trn-doc.obj-type
            buf_tt-docs.obj-code = buf_c-trn-doc.obj-code
          .
          run bge/get-oesq.p ( input 'c-trn-doc':U
                            , input buf_c-trn-doc.doc-code
                            , output buf_tt-docs.pck-code
                            ) .
        end.
      end.
    end.
  end.
  else do:
    find first buf_ord-doc-attr no-lock
      where buf_ord-doc-attr.attr-code  = 'ora-exp-seq-num':U
        and buf_ord-doc-attr.attr-value = v-doc-code
    no-error .
    if available buf_ord-doc-attr
    then do:
      find first buf_ord-doc no-lock
        where buf_ord-doc.doc-code = buf_ord-doc-attr.doc-code
      no-error .
      if available buf_ord-doc
      then do:
        assign
          buf_tt-docs.doc-type = 'ord-doc':U
          buf_tt-docs.doc-code = buf_ord-doc.doc-code
        .
        run bge/get-oesq.p ( input 'ord-doc':U
                           , input buf_ord-doc.doc-code
                           , output buf_tt-docs.pck-code
                           ) .
      end.
    end.
  end.
  run waitfram-hide in this-procedure .
  run open-br in this-procedure .
end.
END PROCEDURE.
FUNCTION display-selected RETURNS CHARACTER
  ( BUFFER loc_tt-docs FOR tt-docs ) :
  RETURN IF loc_tt-docs.is-sel = YES THEN "*" ELSE "".
END FUNCTION.
