define input  parameter parParentProc  as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет Реестр документов по секциям".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable sym1  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym2  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym3  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym4  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym5  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym6  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym7  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym8  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym9  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym10 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym11 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym12 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym13 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym14 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym15 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym16 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym17 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym18 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym19 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym20 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym21 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym22 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym23 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym24 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym25 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym26 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym27 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable temp1 as integer   no-undo.
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
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function func-get-name-from-ext-type   returns char
  ( p-ext-type as character   ,
    p-caps     as logical ).
define variable v-ext-name as character no-undo .
run get-name-from-ext-type in this-procedure (
    input p-ext-type  ,
    input p-caps  ,
    output v-ext-name )
    no-error .
    if error-status :error then do:
       assign
         v-ext-name = p-ext-type
       .
    end.
 return (v-ext-name) .
end.
procedure get-name-from-ext-type :
 do
 on error undo, return error return-value
 :
define input  parameter p-ext-type as character no-undo .
define input  parameter p-caps     as logical no-undo   .
define output parameter p-ext-name as character no-undo .
define variable v-num as integer no-undo .
  if lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) = 0 then do :
    message
      vss-include-info2 skip
      "Неправильно задано значение входящего параметра! "
      "Нет такого типа документов " p-ext-type
      view-as alert-box error .
      undo, return error .
  end.
  v-num      = lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) .
  p-ext-name = entry  ( v-num , 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) .
  if p-caps  = true then do :
     p-ext-name = caps(substring(p-ext-name,1,1) ) + substring(p-ext-name, 2 , length (p-ext-name) - 1 ) .
  end .
  end.
end procedure.
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable v-log as logical   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
define buffer buf_rep_currency for ub.currency.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .
run get-report-num  in parParentProc ( output g#report-num ).
run get-gds-engl in parParentProc ( output g#gds-engl ) .
define variable v-archive-ok as logical   no-undo .
define variable v-comment    as character no-undo .
define variable v-can-print  as logical   no-undo .
define variable Log-Res as log   no-undo .
define variable Prev-Per as log   no-undo .
define variable qnty            as  decimal   no-undo.
define variable d-qnty          as  decimal   no-undo.
define variable doc-sum         as  decimal     no-undo.
define variable cost-sum        as  decimal     no-undo.
define variable sale-sum        as  decimal     no-undo.
define variable ret-sale-sum    as  decimal     no-undo.
define variable ov-sum          as  decimal     no-undo.
define variable ret-ov-sum      as  decimal     no-undo.
define variable SumSLT          as  decimal     no-undo.
define variable ret-SumSLT      as  decimal     no-undo.
define variable VAT_pc         as  decimal     no-undo.
define variable SLT_pc         as  decimal     no-undo.
define variable VAT-sum        as  decimal     no-undo.
define variable SLT-sum        as  decimal     no-undo.
define variable VAT-cost       as  decimal     no-undo.
define variable SLT-cost       as  decimal     no-undo.
define variable VAT-sale       as  decimal     no-undo.
define variable SLT-sale       as  decimal     no-undo.
define variable VAT-salePr     as  decimal     no-undo.
define variable SLT-salePr     as  decimal     no-undo.
define variable SumSale        as  decimal     no-undo.
define variable SumCrsa        as  decimal     no-undo.
define variable SumOv          as  decimal     no-undo.
define variable SumDisc        as  decimal     no-undo.
define variable SumVat         as  decimal     no-undo.
define variable UpFact         as  decimal     no-undo.
define variable tot-qnty              as  decimal   no-undo.
define variable tot-doc-sum      as  decimal     no-undo.
define variable tot-cost-sum      as  decimal     no-undo.
define variable tot-sale-sum      as  decimal     no-undo.
define variable Line       as char    no-undo.
define variable curr-rep as char no-undo.
def stream OutStream .
define variable NAmeoper as char no-undo.
define variable NAmenode as char no-undo.
define variable T-NAme-node as char no-undo.
define variable T-fact-date as date no-undo.
define variable T-doc-num as char no-undo.
define variable t-cli-name as char no-undo.
define variable PayType as int no-undo.
define variable  Quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  Fact-order-1 like ub.stk-tot.Fact-order no-undo.
define variable  Quantity1    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Fact-order-2 like ub.stk-tot.Fact-order no-undo.
define variable  Quantity2    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Quantity3    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat       like ub.stk-tot.sum-rubl   no-undo.
define variable  CoastSLT       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat3-1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat2       like ub.stk-tot.sum-rubl   no-undo.
define variable  CoastSLT-1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Quantity3-1  like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast3-1     like ub.stk-tot.sum-rubl   no-undo.
define variable  QuantityCrsa    like ub.stk-tot.fact-qnty  no-undo.
define variable  CoastCrsa       like ub.stk-tot.sum-rubl   no-undo.
define variable  QuantityCrsa-1  like ub.stk-tot.fact-qnty  no-undo.
define variable  CoastCrsa-1     like ub.stk-tot.sum-rubl   no-undo.
define variable RootGrp like  ub.gds-grp.node-code  no-undo.
define variable FL as int init 0 no-undo.
define variable ii as int init 0 no-undo.
define variable hh as int init 0 no-undo.
define variable grp-name-temp as char init '' no-undo.
define variable Sum-qnty  like ub.ot-line.fact-qnty no-undo.
define variable Sum-Coast like ub.ot-line.sum-rubl no-undo.
define variable Sum-NDS   like ub.ot-line.VAT-rubl no-undo.
define variable Sum-SLT   like ub.ot-line.SLT-rubl no-undo.
define variable Sum-Disc  like ub.ot-line.other-rubl no-undo.
define variable Sum-ov    like ub.ot-line.other-rubl no-undo.
define variable Sum-Crsa  like ub.ot-line.other-rubl no-undo.
define variable v-today   as date      no-undo.
DEFINE WORK-TABLE tdedt no-undo
  FIELD id AS char
  FIELD NAme AS char FORMAT "x(40)"
  FIELD n AS char .
DEFINE TEMP-TABLE TMP NO-UNDO
 FIELD           T-NAme-node_   as char
 FIELD           T-doc-num_     as char
 FIELD           T-fact-date_   as DAte
 FIELD           T-cli-name_    as char
 FIELD           qnty_          as decimal
 FIELD           SumSale_    as decimal
 FIELD           SumCrsa_    as decimal
 FIELD           SumOv_      as decimal
 FIELD           SumDisc_    as decimal
 FIELD           SumVat_     as decimal
 FIELD           SumSLT_     as decimal.
define buffer ot-line-crsa for  ub.ot-line .
define buffer ot-line-sale for  ub.ot-line .
define buffer stk-tot2 for  ub.stk-tot .
define buffer stk-line2 for  ub.stk-line .
define variable  Quantity-Itog0    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast-Itog0       like ub.stk-tot.sum-rubl  no-undo.
define variable  Coast-ItogOther       like ub.stk-tot.sum-rubl  no-undo.
define variable  Coast-ItogVAT       like ub.stk-tot.sum-rubl  no-undo.
define variable  Coast-ItogSLT       like ub.stk-tot.sum-rubl  no-undo.
define variable  Quantity-ItogCrsa    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast-ItogCrsa       like ub.stk-tot.sum-rubl  no-undo.
define variable  Quantity-Itog1    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast-Itog1       like ub.stk-tot.sum-rubl  no-undo.
define variable res as char INIT 'все':U no-undo.
DEF VAR TEMPSTR AS CHAR NO-UNDO.
DEFINE FRAME DocsRep
    sym11 column-label ":!:" format "X(1)" space(0)
    T-NAme-node column-label "Секция! ":C40 format "x(40)" space(0)
    sym1 column-label ":!:" format "X(1)" space(0)
    t-fact-date column-label "Дата!закрытия":C10 format "99/99/9999" space(0)
    sym2 column-label ":!:" format "X(1)" space(0)
    t-doc-num column-label "Номер!документа":C10 format "X(10)" space(0)
    sym3 column-label ":!:" format "X(1)" space(0)
    t-cli-name column-label "Контрагент! ":C28 format "X(28)" space(0)
    sym4 column-label ":!:" format "X(1)" space(0)
    qnty column-label "Количество! ":C13 format "->>>>>>>9.999" space(0)
    sym5 column-label ":!:" format "X(1)" space(0)
    SumSale column-label "Сумма! ":C14 format "->>>>>>>>>9.99" space(0)
    sym6 column-label ":!:" format "X(1)" space(0)
    SumVat column-label " НДС! ":C14 format "->>>>>>>>>9.99" space(0)
    sym7 column-label ":!:" format "X(1)" space(0)
    SumSLT column-label "НП! ":C14 format "->>>>>>>>>9.99" space(0)
    sym8 column-label ":!:" format "X(1)" space(0)
    SumDisc column-label "Скидка! ":C14 format "->>>>>>>>>9.99" space(0)
    sym9 column-label ":!:" format "X(1)" space(0)
    SumOv column-label "Автоматическая!переоценка":C14 format "->>>>>>>>>9.99" space(0)
    sym10 column-label ":!:" format "X(1)" space(0)
    SumCrsa column-label "Сумма!в прод.ценах":C14 format "->>>>>>>>>9.99" space(0)
    sym12 column-label ":!:" format "X(1)" space(0)
    HEADER
        string( cur-time-print() ) AT 5 format "X(35)"
        string( "Реестр документов (товарный отчет) ") AT 50 format "X(35)"
        string( "цены и суммы указаны в руб." ) AT 90 format "X(27)"
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>9" ) ) AT 145 format "X(13)" SKIP
        Line format "X(197)" AT 1
    with width 232 down stream-io use-text NO-BOX.
DEFINE FRAME DocsRep-cost
    sym11 column-label ":!:" format "X(1)" space(0)
    T-NAme-node column-label "Секция! ":C40 format "x(40)" space(0)
    sym1 column-label ":!:" format "X(1)" space(0)
    t-fact-date column-label "Дата!закрытия":C10 format "99/99/9999" space(0)
    sym2 column-label ":!:" format "X(1)" space(0)
    t-doc-num column-label "Номер!документа":C10 format "X(10)" space(0)
    sym3 column-label ":!:" format "X(1)" space(0)
    t-cli-name column-label "Контрагент! ":C28 format "X(28)" space(0)
    sym4 column-label ":!:" format "X(1)" space(0)
    qnty column-label "Количество! ":C13 format "->>>>>>>9.999" space(0)
    sym5 column-label ":!:" format "X(1)" space(0)
    SumSale column-label "Сумма! ":C14 format "->>>>>>>>>9.99" space(0)
    sym6 column-label ":!:" format "X(1)" space(0)
    SumVat column-label " НДС! ":C14 format "->>>>>>>>>9.99" space(0)
    sym7 column-label ":!:" format "X(1)" space(0)
    SumSLT column-label "НП! ":C14 format "->>>>>>>>>9.99" space(0)
    sym8 column-label ":!:" format "X(1)" space(0)
    HEADER
        string( cur-time-print() ) AT 5 format "X(35)"
        string( "Реестр документов (товарный отчет) ") AT 50 format "X(35)"
        string( "цены и суммы указаны в руб." ) AT 90 format "X(27)"
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>9" ) ) AT 145 format "X(13)" SKIP
        Line format "X(152)" AT 1
    with width 232 down stream-io use-text NO-BOX.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     size 10 by 1
     BGCOLOR 8 .
DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     size 10 by 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход":L
     size 10 by 1
     BGCOLOR 8 .
DEFINE VARIABLE combo-node AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          'все':U, 1,
"Выборочо", 2
     SIZE 12 BY 2.67 NO-UNDO.
DEFINE VARIABLE enddate AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     size 11 by 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE startdate AS DATE FORMAT "99/99/9999":U
     LABEL "С"
     VIEW-AS FILL-IN
     size 11 by 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE text2 AS CHARACTER FORMAT "X(256)":U INITIAL "Секции:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE SET_PAY_TYPE AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
 "Цены документа", 1,
 "Учетные цены", 2
     SIZE 20.75 BY 2.33 NO-UNDO.
DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     size 42.5 by 4.17.
DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     size 42.5 by 3.13.
DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     size 42.5 by 7.29.
DEFINE VARIABLE CalcRest AS LOGICAL INITIAL yes
     LABEL "Расчет остатков"
     VIEW-AS TOGGLE-BOX
     size 18.5 by 0.75 NO-UNDO.
DEFINE FRAME DLGOKCAN
     text2 AT ROW 10.13 COL 17.5 COLON-ALIGNED NO-LABEL
     startdate at row 3.33 col 4 COLON-ALIGNED
     enddate at row 3.33 col 27 COLON-ALIGNED
     CalcRest at row 4.75 col 14
     SET_PAY_TYPE AT ROW 6.54 COL 12.88 NO-LABEL
     combo-node AT ROW 11.04 COL 16.63 NO-LABEL
     b-print at row 1 col 12
     b-help at row 1.04 col 33.88
     b-quit at row 1 col 2
     RECT-11 at row 2 col 1.5
     RECT-14 at row 6.29 col 1.5
     RECT-15 at row 9.71 col 1.5
          ub.gds-grp.node-name AT ROW 14.13 COL 3.25 NO-LABEL
           VIEW-AS TEXT
          SIZE 39.25 BY .96
          FGCOLOR 1
     "Период :" VIEW-AS TEXT
          size 9 by 0.75 at row 2.29 col 18.75
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D
         size 45 by 17.29
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 0 "Реестр документов  по секциям":L
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE
       FRAME DLGOKCAN:PRIVATE-DATA     =
                "DLGCLOSE".
ON CHOOSE OF b-print IN FRAME DLGOKCAN
DO:
  if INPUT FRAME DLGOKCAN startdate > INPUT FRAME DLGOKCAN enddate
  then do:
    message
      "Дата окончания должна быть не меньше даты начала!"
      .
  end.
  else do:
    assign
      startdate
      enddate
      .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
    if enddate > v-today
    then do:
      message
        "Дата окончания превышает текущую дату!"
        .
    end.
    else do:
      assign
        PayType = integer(SET_PAY_TYPE :screen-value)
      .
    end.
    define variable v-start-date as date      no-undo .
    define variable v-end-date   as date      no-undo .
    assign
      v-start-date = startdate
      v-end-date   = enddate
    .
    run rep/chk-ahz.p
      (input        v-cntxt-obj-type
      ,input        v-cntxt-obj-code
      ,input        false
      ,input        true
      ,input        false
      ,input        false
      ,input        true
      ,input        v-cntxt-db-num
      ,input        v-cntxt-userid
      ,input-output v-start-date
      ,input-output v-end-date
      ,output       v-archive-ok
      ,output       v-comment
      ,output       v-can-print
      ).
    if v-archive-ok = false
    then do:
      if v-can-print = true
      then do:
        define variable v-choice as logical   no-undo .
        message
          "ВНИМАНИЕ!" skip
          v-comment skip
          "" skip
          "Продолжить формирование отчета ?" skip
          view-as alert-box question buttons yes-no update v-choice .
        if v-choice = false
        then do:
          return .
        end.
      end.
      else do:
        message
          "ВНИМАНИЕ !!!" skip
          "Отчет не может быть сформирован!" skip
          "На запрошенную дату нет архивов или они сжаты" skip
          v-comment skip
          view-as alert-box information .
        return .
      end.
    end.
    else do:
      run main-proc in this-procedure .
    end.
  end.
END.
ON VALUE-CHANGED OF combo-node IN FRAME DLGOKCAN
DO:
RES = 'все':U.
  Assign combo-node.
  if combo-node = 2 Then DO:
    run cus/sel-grp0.w (1).
    RES = return-value .
    if RES = 'все':U OR RES = '' Then DO:
            Assign combo-node = 1 RES = 'все':U.
            Display combo-node  with frame DLGOKCAN .
            End.
    END.
    IF RES <> 'все':U THEN DO:
    find first ub.gds-grp where ub.gds-grp.node-code = integer(res) no-lock no-error.
    if available ub.gds-grp THEN DO:
      enable ub.gds-grp.node-name  with frame DLGOKCAN .
      Display ub.gds-grp.node-name  with frame DLGOKCAN .
      End.
    END.
    IF RES = 'все':U THEN hide ub.gds-grp.node-name  in frame DLGOKCAN .
    Display combo-node  with frame DLGOKCAN .
END.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DLGOKCAN
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
on choose of b-help in frame DLGOKCAN
do:
  apply "help":u to frame DLGOKCAN .
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DLGOKCAN:width - 0.3
                fh            = frame DLGOKCAN:first-child
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DLGOKCAN:PARENT eq ?
THEN FRAME DLGOKCAN:PARENT = ACTIVE-WINDOW.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of Startdate in frame DLGOKCAN
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of Startdate in frame DLGOKCAN
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of Startdate in frame DLGOKCAN
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of Startdate in frame DLGOKCAN
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of Startdate in frame DLGOKCAN
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of Startdate in frame DLGOKCAN
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date12
    MENU-ITEM m-ed-date12-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date12-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date12-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date12-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if Startdate :POPUP-MENU in frame DLGOKCAN = ?
  then do:
    ASSIGN
      Startdate :POPUP-MENU in frame DLGOKCAN = MENU m-ed-date12 :HANDLE
      Startdate :MENU-MOUSE in frame DLGOKCAN = 3
    .
  end.
  define variable v-label-handle12 as handle no-undo .
  assign
    v-label-handle12 = Startdate :side-label-handle in frame DLGOKCAN
  .
  if valid-handle (v-label-handle12)
  then do:
    if v-label-handle12 :tooltip = ""
    or v-label-handle12 :tooltip = ?
    then do:
      assign
        v-label-handle12 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date12-1 in menu m-ed-date12 DO:
    apply "ctrl-b":U to Startdate in frame DLGOKCAN .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-2 in menu m-ed-date12 DO:
    apply "ctrl-d":U to Startdate in frame DLGOKCAN .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-3 in menu m-ed-date12 DO:
    apply "ctrl-e":U to Startdate in frame DLGOKCAN .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-4 in menu m-ed-date12 DO:
    apply "ctrl-f":U to Startdate in frame DLGOKCAN .
  END.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of enddate in frame DLGOKCAN
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of enddate in frame DLGOKCAN
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of enddate in frame DLGOKCAN
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of enddate in frame DLGOKCAN
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of enddate in frame DLGOKCAN
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of enddate in frame DLGOKCAN
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date14
    MENU-ITEM m-ed-date14-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date14-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date14-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date14-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if enddate :POPUP-MENU in frame DLGOKCAN = ?
  then do:
    ASSIGN
      enddate :POPUP-MENU in frame DLGOKCAN = MENU m-ed-date14 :HANDLE
      enddate :MENU-MOUSE in frame DLGOKCAN = 3
    .
  end.
  define variable v-label-handle14 as handle no-undo .
  assign
    v-label-handle14 = enddate :side-label-handle in frame DLGOKCAN
  .
  if valid-handle (v-label-handle14)
  then do:
    if v-label-handle14 :tooltip = ""
    or v-label-handle14 :tooltip = ?
    then do:
      assign
        v-label-handle14 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date14-1 in menu m-ed-date14 DO:
    apply "ctrl-b":U to enddate in frame DLGOKCAN .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date14-2 in menu m-ed-date14 DO:
    apply "ctrl-d":U to enddate in frame DLGOKCAN .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date14-3 in menu m-ed-date14 DO:
    apply "ctrl-e":U to enddate in frame DLGOKCAN .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date14-4 in menu m-ed-date14 DO:
    apply "ctrl-f":U to enddate in frame DLGOKCAN .
  END.
ON WINDOW-CLOSE OF FRAME DLGOKCAN APPLY "END-ERROR":U TO SELF.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
ASSIGN
    startdate = v-today - 7
    enddate   = v-today .
Find first ub.gds-grp where ub.gds-grp.upper-code =0 no-lock no-error.
     If AVAILABLE ub.gds-grp then Rootgrp = ub.gds-grp.node-code.
        Else DO:
             message "Отчет пуст ! Не заполнен классификатор групп товаров!".
             Return.
             End.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if session:set-wait-state("COMPILER") then.
    run enable_ui.
    WAIT-FOR GO OF FRAME DLGOKCAN.
END.
run disable_ui.
PROCEDURE Calc-Itog-node :
if CalcRest then
    do:
      FIND LAST ub.stk-line WHERE ub.stk-line.obj-type  = v-cntxt-obj-type
                          AND ub.stk-line.obj-code   = v-cntxt-obj-code
                          AND ub.stk-line.prod-code  = ub.gds-obj.prod-code
                          AND ub.stk-line.prod-type  = ub.gds-obj.prod-type
                          AND ub.stk-line.artic      = ub.gds-obj.artic
                          AND ub.stk-line.fact-order <= fact-order-1
                          AND ub.stk-line.sum-type   =  (IF PayType = 2  then  'cost':U
                                                                    else  'crsa':U )
                          AND ub.stk-line.cat-id     = '##,##':U
                          USE-INDEX category no-lock no-error.
      If Available ub.stk-line then Assign Quantity3-1    = Quantity3-1 + ub.stk-line.fact-qnty
                                        Coast3-1       = Coast3-1 + ub.stk-line.sum-rubl
                                        coast-vat3-1     = coast-vat3-1 + ub.stk-line.VAT-rubl
                                        CoastSLT-1     = CoastSLT-1 + ub.stk-line.SLT-rubl
                                        .
      FIND LAST stk-line2 WHERE stk-line2.obj-type  = v-cntxt-obj-type
                          AND stk-line2.obj-code   = v-cntxt-obj-code
                          AND stk-line2.prod-code  = ub.gds-obj.prod-code
                          AND stk-line2.prod-type  = ub.gds-obj.prod-type
                          AND stk-line2.artic      = ub.gds-obj.artic
                          AND stk-line2.fact-order <= fact-order-1
                          AND stk-line2.sum-type   =  'crsa':U no-lock no-error.
      If Available stk-line2 then Assign QuantityCrsa-1    = QuantityCrsa-1 + stk-line2.fact-qnty
                                         CoastCrsa-1       = CoastCrsa-1 + stk-line2.sum-rubl .
   End.
 END PROCEDURE.
PROCEDURE Calc-Itog-node-end :
if CalcRest then
    do:
      FIND LAST ub.stk-line WHERE ub.stk-line.obj-type  = v-cntxt-obj-type
                          AND ub.stk-line.obj-code   = v-cntxt-obj-code
                          AND ub.stk-line.prod-code  = ub.gds-obj.prod-code
                          AND ub.stk-line.prod-type  = ub.gds-obj.prod-type
                          AND ub.stk-line.artic      = ub.gds-obj.artic
                          AND ub.stk-line.fact-order <= fact-order-2
                          AND ub.stk-line.sum-type   =  (IF PayType = 2  then  'cost':U
                                                                      else  'crsa':U )
                          AND ub.stk-line.cat-id     = '##,##':U
                          USE-INDEX category no-lock no-error.
      If Available ub.stk-line then Assign Quantity3    = Quantity3 + ub.stk-line.fact-qnty
                                        Coast3       = Coast3 + ub.stk-line.sum-rubl
                                        coast-vat     = coast-vat + ub.stk-line.VAT-rubl
                                        CoastSLT     = CoastSLT + ub.stk-line.SLT-rubl
                                        .
      FIND LAST stk-line2 WHERE stk-line2.obj-type   = v-cntxt-obj-type
                          AND stk-line2.obj-code     = v-cntxt-obj-code
                          AND stk-line2.prod-code    = ub.gds-obj.prod-code
                          AND stk-line2.prod-type    = ub.gds-obj.prod-type
                          AND stk-line2.artic        = ub.gds-obj.artic
                          AND stk-line2.fact-order   <= fact-order-2
                          AND stk-line2.sum-type     = 'crsa':U
                          no-lock no-error.
      If Available stk-line2 then Assign QuantityCrsa   = QuantityCrsa + stk-line2.fact-qnty
                                        CoastCrsa       = CoastCrsa + stk-line2.sum-rubl.
   End.
 END PROCEDURE.
PROCEDURE CalcItog :
FIND FIRST ub.stk-tot WHERE ub.stk-tot.obj-type = v-cntxt-obj-type
                                   AND ub.stk-tot.obj-code   = v-cntxt-obj-code
                                   AND ub.stk-tot.Fact-date >= startdate - 1
                                   AND ub.stk-tot.Fact-date <= Enddate
                                   AND ub.stk-tot.sum-type = (IF PayType = 2  then  'cost':U
                                                                            else  'crsa':U )
                                   AND ub.stk-tot.cat-id  = '##,##':U
                                   USE-INDEX fact-date no-lock no-error.
If Available ub.stk-tot then Assign Fact-order-1 = ub.stk-tot.Fact-order.
                      Else Assign Fact-order-1 = 0.
FIND last ub.stk-tot WHERE ub.stk-tot.obj-type = v-cntxt-obj-type
                                   AND ub.stk-tot.obj-code   = v-cntxt-obj-code
                                   AND ub.stk-tot.Fact-date <= startdate - 1
                                   AND ub.stk-tot.sum-type = (IF PayType = 2  then  'cost':U
                                                                            else  'crsa':U )
                                   AND ub.stk-tot.cat-id  = '##,##':U
                                   USE-INDEX fact-date no-lock no-error.
If Available ub.stk-tot then Assign Fact-order-1 = ub.stk-tot.Fact-order
                                 Quantity1    = ub.stk-tot.fact-qnty
                                 Coast1       = ub.stk-tot.sum-rubl
                                 Coast-vat1   = ub.stk-tot.vat-rubl
                                 .
                      Else Assign Fact-order-1 = 0
                                 Quantity1    = 0
                                 Coast1       = 0
                                 Coast-vat1   = 0
                                 .
FIND LAST ub.stk-tot WHERE ub.stk-tot.obj-type = v-cntxt-obj-type
                                   AND ub.stk-tot.obj-code   = v-cntxt-obj-code
                                   AND ub.stk-tot.Fact-date >= startdate
                                   AND ub.stk-tot.Fact-date <= Enddate
                                   AND ub.stk-tot.sum-type = (IF PayType = 2  then  'cost':U
                                                                           else  'crsa':U )
                                   AND ub.stk-tot.cat-id  = '##,##':U
                                   USE-INDEX fact-date no-lock no-error.
If Available ub.stk-tot then Assign Fact-order-2 = ub.stk-tot.Fact-order .
                     else Assign Fact-order-2 = 0.
FIND LAST ub.stk-tot WHERE ub.stk-tot.obj-type = v-cntxt-obj-type
                                   AND ub.stk-tot.obj-code   = v-cntxt-obj-code
                                   AND ub.stk-tot.Fact-date <= Enddate
                                   AND ub.stk-tot.sum-type = (IF PayType = 2  then  'cost':U
                                                                           else  'crsa':U )
                                   AND ub.stk-tot.cat-id  = '##,##':U
                                   USE-INDEX fact-date no-lock no-error.
If Available ub.stk-tot then Assign Quantity2    = ub.stk-tot.fact-qnty
                                 Coast2       = ub.stk-tot.sum-rubl
                                 Coast-vat2    = ub.stk-tot.vat-rubl
                                 .
                     else Assign Quantity2    = 0
                                 Coast2       = 0
                                 Coast-vat2   = 0
                                 .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY text2 startdate enddate CalcRest SET_PAY_TYPE COMBO-node
      WITH FRAME DLGOKCAN.
  ENABLE RECT-11 RECT-14 RECT-15 text2 startdate enddate CalcRest SET_PAY_TYPE
         COMBO-node b-print b-help b-quit
      WITH FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE Foreach :
For each ub.gds-grp where ub.gds-grp.upper-code = Rootgrp no-lock:
  IF res <> 'все':U Then  If ub.gds-grp.node-code <> integer(res) then NEXT.
    T-NAme-node = ub.gds-grp.node-name.
    NAmenode = ub.gds-grp.node-name.
    run u-line.
    run printdetitogo.
For each ub.gds-obj where ub.gds-obj.grp-name begins ub.gds-grp.node-name
                           AND ub.gds-obj.obj-code = v-cntxt-obj-code
                           AND ub.gds-obj.obj-type = v-cntxt-obj-type no-lock:
  run calc-itog-node.
  run calc-itog-node-end .
  For each ot-line-crsa
                   where   ot-line-crsa.sum-type = 'crsa':U
                          AND ot-line-crsa.fact-order >  fact-order-1
                          AND ot-line-crsa.fact-order <= fact-order-2
                          AND ot-line-crsa.obj-code   = v-cntxt-obj-code
                          AND ot-line-crsa.obj-type   = v-cntxt-obj-type
                          AND ot-line-crsa.prod-code  = ub.gds-obj.prod-code
                          AND ot-line-crsa.prod-type  = ub.gds-obj.prod-type
                          AND ot-line-crsa.artic      = ub.gds-obj.artic
                          no-lock
                          BREAK  BY ot-line-crsa.ext-doc-type  BY ot-line-crsa.doc-code  :
                      Find  First ub.ot-line where
                              ub.ot-line.fact-order = ot-line-crsa.fact-order
                          AND ub.ot-line.obj-code   = ot-line-crsa.obj-code
                          AND ub.ot-line.obj-type   = ot-line-crsa.obj-type
                          AND ub.ot-line.prod-code  = ot-line-crsa.prod-code
                          AND ub.ot-line.prod-type  = ot-line-crsa.prod-type
                          AND ub.ot-line.artic      = ot-line-crsa.artic
                          and ub.ot-line.sum-type   =
                           (IF PayType = 2  then  'cost':U  else  'sale':U )
                          no-lock  no-error .
                      Find  First ot-line-sale where
                              ot-line-sale.fact-order = ot-line-crsa.fact-order
                          AND ot-line-sale.obj-code   = ot-line-crsa.obj-code
                          AND ot-line-sale.obj-type   = ot-line-crsa.obj-type
                          AND ot-line-sale.prod-code  = ot-line-crsa.prod-code
                          AND ot-line-sale.prod-type  = ot-line-crsa.prod-type
                          AND ot-line-sale.artic      = ot-line-crsa.artic
                          and ot-line-sale.sum-type   = 'sale':U
                          no-lock  no-error .
      ii = ii + 1.
If Integer(25) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer(25) .
     IF ( ii modulo Temp1 = 0 ) AND ( ii >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( ii )) .
   if available  ub.ot-line then do :
      Accumulate ub.ot-line.fact-qnty      (TOTAL BY ot-line-crsa.doc-code).
      Accumulate ub.ot-line.sum-rubl       (TOTAL BY ot-line-crsa.doc-code).
      Accumulate ub.ot-line.VAT-rubl       (TOTAL BY ot-line-crsa.doc-code).
      Accumulate ub.ot-line.SLT-rubl       (TOTAL BY ot-line-crsa.doc-code).
      Accumulate ub.ot-line.other-rubl     (TOTAL BY ot-line-crsa.doc-code).
      Quantity-Itog0 = Quantity-Itog0    + ub.ot-line.fact-qnty.
      Coast-Itog0    = Coast-Itog0       + ub.ot-line.sum-rubl.
      Coast-ItogVAT    = Coast-ItogVAt       + ub.ot-line.VAT-rubl.
      Coast-ItogSLT    = Coast-ItogSLT       + ub.ot-line.SLT-rubl.
      Coast-ItogOther  = Coast-ItogOther     + ub.ot-line.other-rubl.
      End.
      Accumulate ot-line-crsa.sum-rubl  (TOTAL BY ot-line-crsa.doc-code).
      Coast-ItogCRSA    = Coast-ItogCRSA + ot-line-crsa.sum-rubl.
   FIND First TDEDT where tdedt.id = ot-line-crsa.ext-doc-type no-error .
   If LAST-OF (ot-line-crsa.doc-code) Then DO:
      Find Last ub.trn-doc where ub.trn-doc.doc-code = ot-line-crsa.doc-code no-lock no-error.
           If NOT Available ub.trn-doc then
              Find Last ub.price-doc where ub.price-doc.doc-num = ot-line-crsa.doc-code no-lock no-error.
      Create Tmp.
      Assign
           Tmp.T-fact-date_   = If Available ub.trn-doc then  ub.trn-doc.fact-date Else (If Available ub.price-doc THEN ub.price-doc.fact-date ELSE DATE(''))
           Tmp.T-cli-name_    = If Available ub.trn-doc then ub.trn-doc.cli-name Else ""
           Tmp.T-NAme-node_   = ( If available tdedt then tdedt.n + tdedt.name else ( ot-line-crsa.ext-doc-type + ' нет в справочнике!'))
           Tmp.T-doc-num_     = ot-line-crsa.doc-code.
           Tmp.qnty_          = (Accum TOTAL BY ot-line-crsa.doc-code ub.ot-line.fact-qnty).
           Tmp.SumSale_       = (Accum TOTAL BY ot-line-crsa.doc-code ub.ot-line.sum-rubl)  .
           Tmp.SumVat_        = (Accum TOTAL BY ot-line-crsa.doc-code ub.ot-line.VAT-rubl).
           Tmp.SumSLT_        = (Accum TOTAL BY ot-line-crsa.doc-code ub.ot-line.SLT-rubl).
           Tmp.SumCrsa_       = (Accum TOTAL BY ot-line-crsa.doc-code ot-line-crsa.sum-rubl).
           Tmp.SumDisc_       = (Accum TOTAL BY ot-line-crsa.doc-code ub.ot-line.other-rubl) .
           Tmp.SumOv_         = Tmp.SumCrsa_ - Tmp.SumSale_ - Tmp.SumDisc_ .
      if ot-line-crsa.ext-doc-type = 'rs':U or ot-line-crsa.ext-doc-type = 'es':U  tHEN do:
         Assign  Tmp.T-NAme-node_   = "16" + "касса"
                 Tmp.T-doc-num_     = Substring(ot-line-crsa.doc-code,1, LENGTH(trim(ot-line-crsa.doc-code)) - 1 ).
         eND.
     End.
    End.
   End.
       For each tmp Break BY Tmp.T-NAme-node_ BY Tmp.T-doc-num_:
                    Accumulate Tmp.qnty_        (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.SumSale_     (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.SumCrsa_     (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.Sumov_       (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.Sumdisc_     (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.SumVat_      (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.SumSLT_      (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.qnty_        (TOTAL BY Tmp.T-NAme-node_).
                    Accumulate Tmp.SumSale_     (TOTAL BY Tmp.T-NAme-node_).
                    Accumulate Tmp.SumVat_      (TOTAL BY Tmp.T-NAme-node_).
                    Accumulate Tmp.SumSLT_      (TOTAL BY Tmp.T-NAme-node_).
                    Accumulate Tmp.SumCrsa_     (TOTAL BY Tmp.T-NAme-node_).
                    Accumulate Tmp.Sumov_       (TOTAL BY Tmp.T-NAme-node_).
                    Accumulate Tmp.Sumdisc_     (TOTAL BY Tmp.T-NAme-node_).
            If FIRST-OF (Tmp.T-NAme-node_) Then DO:
              Assign
                   T-NAme-node   = ''
                   T-doc-num     = ''
                   T-fact-date   = Date('')
                   T-cli-name    = Substring(Tmp.T-NAme-node_,3)
                   qnty          = 0
                   SumSale       = 0
                   SumCrsa       = 0
                   SumDisc       = 0
                   Sumov         = 0
                   SumVat        = 0
                   SumSLT        = 0   .
                   run printdetitogo.
                End.
           If LAST-OF (Tmp.T-doc-num_) Then DO:
               Assign
                   T-NAme-node   = ''
                   T-doc-num     = Tmp.T-doc-num_
                   T-fact-date   = Tmp.T-fact-date_
                   T-cli-name    = Tmp.T-cli-name_
                   qnty          = (Accum TOTAL BY Tmp.T-doc-num_ Tmp.qnty_)
                   SumSale    = (Accum TOTAL BY Tmp.T-doc-num_ Tmp.SumSale_)
                   SumCrsa    = (Accum TOTAL BY Tmp.T-doc-num_ Tmp.SumCrsa_)
                   SumOv      = (Accum TOTAL BY Tmp.T-doc-num_ Tmp.SumOv_)
                   SumDisc    = (Accum TOTAL BY Tmp.T-doc-num_ Tmp.SumDisc_)
                   SumVat     = (Accum TOTAL BY Tmp.T-doc-num_ Tmp.SumVat_)
                   SumSLT     = (Accum TOTAL BY Tmp.T-doc-num_ tmp.SumSLT_).
                   if PayType = 2 then DO:
                   if NOT (qnty  = 0 and  SumSale = 0 )  then
                               run printdetaile2.
                               End.
                   Else do:
                   if NOT (qnty  = 0 and  SumSale = 0  and  SumCRSA = 0)  then
                               run printdetaile2.
                               End.
             End.
             If LAST-OF (Tmp.T-NAme-node_) Then DO:
              Assign
                   T-NAme-node = ''
                   T-doc-num   = ''
                   T-fact-date = Date('')
                   T-cli-name  = "Итого по типу " + Substring(Tmp.T-NAme-node_,3)
                   qnty       = (Accum TOTAL BY Tmp.T-NAme-node_ Tmp.qnty_)
                   SumSale    = (Accum TOTAL BY Tmp.T-NAme-node_ Tmp.SumSale_)
                   SumCrsa    = (Accum TOTAL BY Tmp.T-NAme-node_ Tmp.SumCrsa_)
                   SumOv      = (Accum TOTAL BY Tmp.T-NAme-node_ Tmp.SumOv_)
                   SumDisc    = (Accum TOTAL BY Tmp.T-NAme-node_ Tmp.SumDisc_)
                   SumVat     = (Accum TOTAL BY Tmp.T-NAme-node_ Tmp.SumVat_)
                   SumSLT     = (Accum TOTAL BY Tmp.T-NAme-node_ tmp.SumSLT_).
                   run printdetaile2.
                   run p-line.
             End.
       End.
    For each tmp: delete tmp. end.
    run itog0.
  End .
END PROCEDURE.
PROCEDURE Itog0 :
  run itog0start.
      Assign
           T-NAme-node = trim(NAmenode) + "   ИТОГО оборот"
           T-doc-num     = ''
           T-fact-date = Date('')
           T-cli-name    =''
           qnty       = Quantity-Itog0
           SumSale    = Coast-Itog0
           SumCrsa    = Coast-ItogCRSA
           SumDisc    = Coast-ItogOther
           SumOv      = Coast-ItogCRSA - Coast-Itog0 -  Coast-ItogOther
           SumVat     = Coast-ItogVAt
           SumSLT     = Coast-ItogSLT                .
           run print-o.
           Quantity-Itog0 = 0 .
           Coast-Itog0    = 0 .
           Coast-ItogCRSA = 0 .
           Coast-ItogOther = 0 .
           Coast-ItogVAT   = 0 .
           Coast-ItogSLT   = 0 .
if CalcRest then
    do:
       Assign
           T-NAme-node = string( "   Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )
           T-doc-num     = ''
           T-fact-date = Date('')
           T-cli-name    =''
           qnty          = Quantity3
           SumSale       = Coast3
           SumCrsa       = CoastCRSA
           SumDisc       = 0
           SumOv         = 0
           SumVat        = coast-vat
           SumSLT        = CoastSLT               .
           run printdetaile2.
    end.
    Quantity3 = 0 .
    Coast3    = 0 .
    CoastCRSA = 0 .
    coast-vat = 0 .
    CoastSLT = 0 .
END PROCEDURE.
PROCEDURE Itog0Start :
if CalcRest then
    do:
       Assign
           T-NAme-node = string( "   Остаток на начало периода(" + string( startdate, "99/99/9999" ) + ")" )
           T-doc-num     = ''
           T-fact-date = Date('')
           T-cli-name    =''
           qnty          = Quantity3-1
           SumSale       = Coast3-1
           SumCrsa       = CoastCRSA-1
           SumVat        = coast-vat3-1
           SumDisc       = 0
           SumOv         = 0
           SumSLT        = COASTSLT-1     .
           run printdetaile2.
    end.
    Quantity3-1 = 0 .
    Coast3-1    = 0 .
    CoastCRSA-1 = 0 .
    coast-vat3-1  = 0 .
    CoastSLT-1  = 0 .
END PROCEDURE.
PROCEDURE main-proc :
run maketemptabl.
define variable last_day as integer no-undo .
define variable firstdate as date no-undo .
define variable m-str as char no-undo .
define variable doc_str   as char no-undo.
define variable doc_str1 as char no-undo.
Line = fill("-", 214).
assign frame DLGOKCAN
    CalcRest Enddate startdate Set_Pay_Type combo-node.
assign
    II=0
    tot-qnty     = 0
    tot-doc-sum  = 0
    tot-cost-sum = 0
    tot-sale-sum = 0
    .
run nsum.
FIND ub.clients WHERE ub.clients.obj-type = v-cntxt-obj-type
                                   AND ub.clients.obj-code = v-cntxt-obj-code
                                   NO-LOCK .
run waitfram-show ( 'Подождите ...' ) .
output STREAM OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
if PayType = 2 then
   FORM with FRAME DocsRep-cost .
   Else
   FORM with FRAME DocsRep .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "X(197)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 232 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
 run calcitog.
 run printheader.
if paytype = 2 then
   form with frame docsrep-cost .
   else
   form with frame docsrep .
  run foreach.
  hide stream outstream frame bottomframe .
  run printfooter.
  if paytype = 2 then
  hide stream outstream frame docsrep-cost .
  else hide stream outstream frame docsrep .
  output stream outstream close.
  run waitfram-hide .
define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
DisabledOptions = 8.
run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
  ,input  7
  ,output v-user-action
  ,output v-printed
  ) .
END PROCEDURE.
PROCEDURE MakeTempTabl :
create tdedt.
assign tdedt.id =  'ie':U
       tdedt.n  = "01"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'iv':U
       tdedt.n  = "02"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'im':U
       tdedt.n  = "03"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  're':U
       tdedt.n  = "04"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'rv':U
       tdedt.n  = "05"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'we':U
       tdedt.n  = "06"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'wm':U
       tdedt.n  = "07"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'ev':U
       tdedt.n  = "08"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'em':U
       tdedt.n  = "09"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'ee':U
       tdedt.n  = "10"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'ep':U
       tdedt.n  = "11"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'rs':U
       tdedt.n  = "12"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'es':U
       tdedt.n  = "13"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'ot':U
       tdedt.n  = "14"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'vt':U
       tdedt.n  = "15"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'vp':U
       tdedt.n  = "17"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'mp':U
       tdedt.n  = "18"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
END PROCEDURE.
PROCEDURE NSum :
Assign
           qnty          = 0
           SumSale    = 0
           SumCrsa    = 0
           SumVat = 0
           SumSLT    = 0
           SumOv      = 0
           SumDisc      = 0
           Sum-qnty      = 0
           Sum-Coast     = 0
           Sum-NDS       = 0
           Sum-SLT       = 0.
END PROCEDURE.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then do:
    return .
  end.
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:
    page stream OutStream .
  end.
end procedure.
PROCEDURE P-line :
if paytype = 2 then DO:
Underline stream OutStream
        sym11
        sym3 T-fact-date
        sym4 T-doc-num
        sym5 T-cli-name
        sym6 qnty
        sym7 SumSale
        sym8 SumVat
        SumSLT
        with FRAME DocsRep-cost.
        DOWN stream OutStream 1 with FRAME DocsRep-cost.
        end.
        Else do:
Underline stream OutStream
        sym11 sym12
        sym3 T-fact-date
        sym4 T-doc-num
        sym5 T-cli-name
        sym6 qnty
        sym7 SumSale
        sym8 SumVat
        sym9 SumSLT
        sym10 sumcrsa
        sumov sumdisc
        with FRAME DocsRep.
        DOWN stream OutStream 1 with FRAME DocsRep.
       End.
END PROCEDURE.
PROCEDURE PrintDetaile2 :
if paytype =  2 then
  DISPLAY stream OutStream
       T-NAme-node
       sym1  T-fact-date
       sym2  T-doc-num
       sym3  T-cli-name
       sym4  qnty    format "->>>>>>>9.999"
       sym5  SumSale format "->>>>>>>>>9.99"
       sym6  SumVat  format "->>>>>>>>>9.99"
       sym7  SumSLT  format "->>>>>>>>>9.99"
       sym8
       sym11
         with FRAME DocsRep-cost.
    ELSE
  DISPLAY stream OutStream
        T-NAme-node
       sym1  T-fact-date
       sym2  T-doc-num
       sym3  T-cli-name
       sym4  qnty    format "->>>>>>>9.999"
       sym5  SumSale format "->>>>>>>>>9.99" when NOT (TRIM(T-NAme-node)  begins "Остаток")
       sym6  SumVat  format "->>>>>>>>>9.99" when NOT (TRIM(T-NAme-node)  begins "Остаток")
       sym7  SumSLT  format "->>>>>>>>>9.99" when NOT (TRIM(T-NAme-node)  begins "Остаток")
       sym8  SumCrsa format "->>>>>>>>>9.99"
       sym9
       SumOv   format "->>>>>>>>>9.99"       when NOT (TRIM(T-NAme-node)  begins "Остаток")
       sym10
       SumDisc format "->>>>>>>>>9.99"       when NOT (TRIM(T-NAme-node)  begins "Остаток")
       sym11
       sym12
         with FRAME DocsRep.
    if PayType = 2
    then DOWN stream OutStream 1 with FRAME DocsRep-cost.
    else DOWN stream OutStream 1 with FRAME DocsRep.
END PROCEDURE.
PROCEDURE PrintDetItogo :
if paytype = 2 THEN
    Put Stream OutStream UNFORMATTED
    sym11
    string(T-NAme-node  ,"x(40)")
    sym1  space(10)
    sym2  space(10)
    sym3  String(T-cli-name   ,"x(28)")
    sym4  space(13)
    sym5  space(14)
    sym6  space(14)
    sym7  space(14)
    sym8
    skip.
 Else
    Put Stream OutStream UNFORMATTED
    sym11
    string(T-NAme-node  ,"x(40)")
    sym1  space(10)
    sym2  space(10)
    sym3  String(T-cli-name   ,"x(28)")
    sym4  space(13)
    sym5  space(14)
    sym6  space(14)
    sym7  space(14)
    sym8  space(14)
    sym9  space(14)
    sym10 space(14)
    sym12
    skip.
END PROCEDURE.
PROCEDURE PrintFooter :
 run u-line.
  run on-same-page in this-procedure (input 11) .
  hide stream OutStream frame bottomframe .
    Quantity = Quantity2 - Quantity1.
    Coast = Coast2 - Coast1 .
    Coast-vat = Coast-vat2 - Coast-vat1 .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE "" :
WHEN  "1" then
TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .
WHEN "2" then
TEMPSTR = string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
OTHERWISE
TEMPSTR =string( "Оборот с " + string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) )  .
end CASE.
PUT STREAM OutStream
SKIP
SPACE(5)
TEMPSTR format "x(72)"
SKIP
SPACE(32) string( "Количество: " + trim( string( Quantity, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
SKIP.
IF PayType = 2 OR PayType = 0  then do:
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
if  v-log = true  then
PUT STREAM OutStream
SPACE(23) string( "Cумма   УЧЕТНЫХ  цен: " +
            trim( string( Coast , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
PUT STREAM OutStream
SPACE(23) string( "Cумма УЧЕТНЫХ цен без НДС: " +
     trim( string( (Coast - Coast-vat  ) , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
     curr-rep
     ) format "x(72)"
     SKIP.
end.
Else   PUT STREAM OutStream
SPACE(23) string(  "Cумма ПРОДАЖНЫХ цен: " +
            trim( string( Coast, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
.
if CalcRest then
    do:
        PUT STREAM OutStream "По всем секциям " skip.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE "2" :
WHEN  "1" then
TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .
WHEN "2" then
TEMPSTR = string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
OTHERWISE
TEMPSTR =string( "Оборот с " + string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) )  .
end CASE.
PUT STREAM OutStream
SKIP
SPACE(5)
TEMPSTR format "x(72)"
SKIP
SPACE(32) string( "Количество: " + trim( string( Quantity2, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
SKIP.
IF PayType = 2 OR PayType = 0  then do:
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
if  v-log = true  then
PUT STREAM OutStream
SPACE(23) string( "Cумма   УЧЕТНЫХ  цен: " +
            trim( string( Coast2 , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
PUT STREAM OutStream
SPACE(23) string( "Cумма УЧЕТНЫХ цен без НДС: " +
     trim( string( (Coast2 - Coast-vat2  ) , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
     curr-rep
     ) format "x(72)"
     SKIP.
end.
Else   PUT STREAM OutStream
SPACE(23) string(  "Cумма ПРОДАЖНЫХ цен: " +
            trim( string( Coast2, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
.
    end.
PUT STREAM OutStream " " SKIP(2)
    SPACE(20) "Заведующий __________________" format "X(32)"
    SPACE(20) "Ст. продавец __________________" format "X(32)"
    SPACE(20) "Бухгалтер __________________" format "X(32)" SKIP
    .
   run on-same-page in this-procedure (input 10) .
END PROCEDURE.
PROCEDURE PrintHeader :
PUT STREAM OutStream SPACE(27)
        "Р Е Е С Т Р   Д О К У М Е Н Т О В ( Т О В А Р Н Ы Й   О Т Ч Е Т )"
            format "X(80)" SKIP(1)
        SPACE(40) "за период  с  " format "X(14)" startdate format "99.99.9999"
            "  по  " enddate format "99.99.9999"
        SPACE(32) string("По объекту  : " + ub.clients.obj-name ) format "X(80)" SKIP
        If paytype = 2 Then "Суммы указаны в УЧЕТНЫХ ценах"
                       Else "Суммы указаны в ЦЕНАХ ДОКУМЕНТА"  format "X(80)"
        SKIP
        .
if CalcRest then
    do:
        PUT STREAM OutStream "По всем секциям " skip.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE "1" :
WHEN  "1" then
TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .
WHEN "2" then
TEMPSTR = string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
OTHERWISE
TEMPSTR =string( "Оборот с " + string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) )  .
end CASE.
PUT STREAM OutStream
SKIP
SPACE(5)
TEMPSTR format "x(72)"
SKIP
SPACE(32) string( "Количество: " + trim( string( Quantity1, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
SKIP.
IF PayType = 2 OR PayType = 0  then do:
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
if  v-log = true  then
PUT STREAM OutStream
SPACE(23) string( "Cумма   УЧЕТНЫХ  цен: " +
            trim( string( Coast1 , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
PUT STREAM OutStream
SPACE(23) string( "Cумма УЧЕТНЫХ цен без НДС: " +
     trim( string( (Coast1 - Coast-vat1  ) , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
     curr-rep
     ) format "x(72)"
     SKIP.
end.
Else   PUT STREAM OutStream
SPACE(23) string(  "Cумма ПРОДАЖНЫХ цен: " +
            trim( string( Coast1, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
.
    end.
END PROCEDURE.
PROCEDURE u-line :
if PayType = 2 then
Underline stream OutStream
        sym1 T-NAme-node
        sym2 T-fact-date
        sym3 T-doc-num
        sym4 T-cli-name
        sym5 qnty
        sym6
        SumSale
        sym7 SumVat
        sym8 SumSLT
        sym11
        with FRAME DocsRep-cost.
Else
Underline stream OutStream
        sym1 T-NAme-node
        sym2 T-fact-date
        sym3 T-doc-num
        sym4 T-cli-name
        sym5 qnty
        sym6
        SumSale
        SumCrsa
        SumOv
        SumDisc
        sym7 SumVat
        sym8 SumSLT
        sym9
        sym10
        sym11
        sym12
        with FRAME DocsRep.
 if PayType = 2 then
 DOWN stream OutStream 1 with FRAME DocsRep-cost.
 Else DOWN stream OutStream 1 with FRAME DocsRep.
END PROCEDURE.
PROCEDURE Print-o :
if PayType = 2 then
Put Stream OutStream UNFORMATTED
  sym11  string(T-NAme-node  ,"x(51)")
  sym1   space(10)
  sym3   space(28)
  sym4  qnty     format "->>>>>>>9.999"
  sym5  SumSale  format "->>>>>>>>>9.99"
  sym6  SumVat   format "->>>>>>>>>9.99"
  sym7  SumSLT   format "->>>>>>>>>9.99"
  sym8
  skip.
  Else
Put Stream OutStream UNFORMATTED
  sym11  string(T-NAme-node  ,"x(51)")
  sym1   space(10)
  sym3   space(28)
  sym4  qnty     format "->>>>>>>9.999"
  sym5  SumSale  format "->>>>>>>>>9.99"
  sym6  SumVat   format "->>>>>>>>>9.99"
  sym7  SumSLT   format "->>>>>>>>>9.99"
  sym8  Sumdisc  format "->>>>>>>>>9.99"
  sym9  Sumov    format "->>>>>>>>>9.99"
  sym10 SumCrsa  format "->>>>>>>>>9.99"
  sym12
  skip.
END PROCEDURE.
