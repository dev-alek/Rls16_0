DEFINE NEW SHARED BUFFER bufs_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER buf_ord-chain FOR ub.ord-chain.
DEFINE NEW SHARED BUFFER buf_ord-doc FOR ub.ord-doc.
DEFINE NEW SHARED BUFFER buf_trn-doc FOR ub.trn-doc.
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-host-code    as integer   no-undo .
define input  parameter p-g#type       as character no-undo .
define input  parameter p-g#stat       as character no-undo .
define input  parameter p-g#cons-code  as character no-undo .
define input  parameter list-mode      as character no-undo .
define output parameter del-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список поставок".
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info6 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info6, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info6, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info6 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info6, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info6 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info6, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info6, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info6, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info6, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info6, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info6 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info6 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info6, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info6 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info6 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION status-edoc-nn RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
define variable v-obj-db-num as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients  .
define buffer obj_clients for ub.clients  .
define buffer buf_ext-classif for ub.ext-classif  .
define buffer buf2_ext-classif for ub.ext-classif  .
define buffer buf_ext-system  for ub.ext-system  .
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> 'ОП':U  then do:
  p-color = ?.
  return ''.
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  loc-o-doc.obj-type
  ,input  loc-o-doc.obj-code
  ,output v-obj-db-num
  )  .
find first  buf_clients no-lock where
            buf_clients.obj-type = loc-o-doc.cli-type and
            buf_clients.obj-code = loc-o-doc.cli-code
              no-error .
if not available buf_clients then do:
  p-color = ?.
  return "" .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'clients-edoc-nn':U no-error.
if available buf_ext-classif then do :
  assign
  p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , '14,12,?,10,10,?,?,?,?,?,4'))
  no-error .
  return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') .
end.
else do :
  find first obj_clients no-lock where
            obj_clients.obj-type = loc-o-doc.obj-type
        and obj_clients.obj-code = loc-o-doc.obj-code no-error.
  if not available obj_clients then do:
    return ''.
  end.
  run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                    , input (buffer obj_clients:handle)
                                    , output v-obj-uniq-key-rec).
  for each buf_ext-classif no-lock
        where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
          and buf_ext-classif.classif-subject = 'clients':U
          and buf_ext-classif.classif-name    = 'exite-edi':U,
     first buf_ext-system no-lock
        where buf_ext-system.esys-id = buf_ext-classif.key#_one
          and buf_ext-system.db-num  = 0
          and buf_ext-system.esys-have-export = yes
          and buf_ext-system.esys-db-num-exp = v-obj-db-num,
     first buf2_ext-classif no-lock
              where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
                and buf2_ext-classif.classif-subject = 'clients':U
                and buf2_ext-classif.classif-name    = 'exite-edi':U
                and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , '14,12,?,14,?,?,10,?,?,?,?,4,10,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка') .
  end.
  return ''.
end.
return ''.
END FUNCTION.
FUNCTION status-is-edoc-nn RETURN logical ( input p-is-edoc-nn   as logical
                                             , input p-cli-type     as character
                                             , input p-cli-code     as integer
                                             , input p-obj-type     as character
                                             , input p-obj-code     as integer
                                             ) .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edoc-nn then do:
  return no.
end.
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
     where buf_ext-classif.uniq-key-rec    = v-uniq-key-rec
       and buf_ext-classif.classif-subject = 'clients':U
       and buf_ext-classif.classif-name    = 'clients-edoc-nn':U
       no-error.
if available buf_ext-classif then do :
  return yes .
end.
return no.
END FUNCTION.
FUNCTION status-is-edi RETURN logical ( input p-is-edi as logical
                                         , input p-cli-type as character
                                         , input p-cli-code as integer
                                         , input p-obj-type     as character
                                         , input p-obj-code     as integer
                                         , output p-dm-edi as integer
                                         ) .
define variable v-obj-db-num   as integer   no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients     for ub.clients .
define buffer obj_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf2_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edi then do:
  return no.
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
find first obj_clients no-lock where
          obj_clients.obj-type = p-obj-type
      and obj_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer obj_clients:handle)
                                  , output v-obj-uniq-key-rec).
for each buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'exite-edi':U,
    first buf_ext-system no-lock
      where buf_ext-system.esys-id = buf_ext-classif.key#_one
        and buf_ext-system.db-num  = 0
        and buf_ext-system.esys-have-export = yes
        and (buf_ext-system.esys-db-num-exp = v-obj-db-num
        or buf_ext-system.esys-db-num-exp = 0),
    first buf2_ext-classif no-lock
            where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
              and buf2_ext-classif.classif-subject = 'clients':U
              and buf2_ext-classif.classif-name    = 'exite-edi':U
              and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
  leave.
end.
if available buf_ext-classif then do :
  p-dm-edi = buf_ext-system.whole-send-news.
  return yes .
end.
return no .
END FUNCTION.
FUNCTION get-gln returns character ( input p-obj-type as character
                                    ,input p-obj-code as integer):
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_clients no-lock where
          buf_clients.obj-type = p-obj-type
      and buf_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return chr(63).
end.
run gen-key-rec  in this-procedure ( input 'clients':U
                                    ,input (buffer buf_clients:handle)
                                    ,output v-uniq-key-rec) no-error.
if error-status:error then do:
   return chr(63).
end.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.classif-name = 'GLN':U
      and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error .
if available buf_ext-classif then do:
  return buf_ext-classif.charkey_one.
end.
else do:
 return ''.
end.
END FUNCTION.
FUNCTION get-type-code-from-gln returns logical ( input  p-gln      as character
                                                    ,output p-obj-type as character
                                                    ,output p-obj-code as integer) :
define variable v-uniq-key-rec as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.classif-name = 'GLN':U
      and buf_ext-classif.charkey_one = p-gln no-error .
if available buf_ext-classif then do:
  assign v-uniq-key-rec = buf_ext-classif.uniq-key-rec.
end.
else do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
if v-uniq-key-rec <> '' then do:
    run gen-key-fv in this-procedure ( input  v-uniq-key-rec
                                      ,output v-field-list
                                      ,output v-value-list).
end.
assign
  p-obj-type = entry(lookup("obj-type":U
                          , v-field-list
                          , chr(3))
                          , v-value-list, chr(3))
  p-obj-code = integer(entry(lookup("obj-code":U
                                  , v-field-list
                                  , chr(3))
                                  , v-value-list, chr(3)))
no-error .
if error-status:error then do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
else do:
  return yes.
end.
END FUNCTION.
FUNCTION status-edoc-edi-light RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> 'ОП':U  then do:
  p-color = ?.
  return ''.
end.
case loc-o-doc.whole-send-news:
  when integer('1':U) then do:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , '14,12,?,10,10,?,?,?,?,?,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') .
  end.
  when integer('2':U) then do:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , '14,12,?,14,?,?,10,?,?,?,?,4,10,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка') .
  end .
  otherwise do:
    p-color = ?.
    return ''.
  end.
end case.
end function.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable p-g#host-name  as character no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable hard-flt-cli    as logical   no-undo init false .
define variable hard-flt-date   as logical   no-undo init false .
define variable doc-mode    as character no-undo .
define variable line-mode   as character no-undo .
define variable doc-rec     as recid no-undo .
define variable line-rec    as recid no-undo .
define variable gds-rec     as recid no-undo .
define variable prt-rec     as recid no-undo .
define variable prt-cli-name     as character no-undo format "x(40)".
define variable prt-out-cli-code as character no-undo format "x(40)".
define variable prt-sum-rubl     as decimal   no-undo .
define new shared variable next-prev    as logical   no-undo .
define variable v-glog      as logical   no-undo .
define variable  mark as character no-undo.
define variable  sss  as character no-undo.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
if store-type = ? or store-type = "" then do:
    define buffer buf_clients-name for ub.clients  .
    find first buf_clients-name no-lock where buf_clients-name.obj-code =  p-host-code and
                                              buf_clients-name.obj-type = 'орг':U no-error .
   p-g#host-name = buf_clients-name.obj-name.
end.
else do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output p-host-code
  ,output p-g#host-name
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  store-type
  ,input  store-code
  ,output to-day
  )  .
end.
define NEW SHARED  buffer  loc-doc-rcv   for ub.ord-doc-rcv.
define NEW SHARED  variable br-rcv-handle as handle no-undo   .
define NEW SHARED  variable x-make-avto   as integer no-undo .
define variable v-fo          as   character             no-undo.
define var sch-field as char no-undo.
define buffer t-d-b for ub.ord-cons.
define buffer buf_ord-cons for ub.ord-cons.
define buffer t-trn-line      for ub.doc-line     .
define buffer buf_ord-line-rcv  for ub.ord-line-rcv .
DEFINE  VARIABLE sch-fact AS date NO-UNDO.
define variable ll-rec as recid no-undo .
define variable v-status-edi as character no-undo .
define variable v-status-trn-edi as character no-undo .
define variable v-status-trn-edi1 as character no-undo .
define variable    par-is-edi as character no-undo .
define variable    par-is-edoc-nn as character no-undo .
define variable    par-type as character no-undo .
define variable    is-edi as logical   no-undo .
DEFINE VARIABLE v-color AS INTEGER NO-UNDO.
DEFINE VARIABLE is-edoc-nn AS LOGICAL NO-UNDO.
define variable filter-point as character no-undo init "Поставки " .
define variable sort-column-name as character no-undo .
FUNCTION sum-rubl returns decimal (buffer loc-t-doc for bufs_ord-doc-rcv) .
  define buffer buf_ord-line-rcv for ub.ord-line-rcv .
  define variable v-sum as decimal   no-undo .
  v-sum = 0.
  for each buf_ord-line-rcv no-lock where
          buf_ord-line-rcv.doc-code = loc-t-doc.doc-code and
          buf_ord-line-rcv.rcv-code = loc-t-doc.rcv-code
          :
      v-sum = v-sum  + buf_ord-line-rcv.cli-qnty * buf_ord-line-rcv.price-cli .
  end.
  return v-sum .
END FUNCTION.
FUNCTION cli-doc-out returns character (buffer loc-doc for ub.ord-doc-rcv) .
  return entry(1,loc-doc.sub-par,chr(4)) .
END FUNCTION.
FUNCTION cli-name returns character (buffer loc-t-doc for bufs_ord-doc-rcv) .
define buffer buf_clients for ub.clients  .
find first buf_clients no-lock where
           buf_clients.obj-type = loc-t-doc.cli-type and
           buf_clients.obj-code = loc-t-doc.cli-code no-error .
    if available buf_clients then return buf_clients.obj-name.
       else return loc-t-doc.obj-type + string(loc-t-doc.obj-code) .
END FUNCTION.
FUNCTION mark-string RETURNs CHAR (buffer loc-t-doc for bufs_ord-doc-rcv ).
  if can-do (del-list, string (recid (loc-t-doc))) then RETURN "*".
  else RETURN "".
END FUNCTION.
FUNCTION f-fo RETURNS CHARACTER
  ( buffer loc-t-doc for ub.ord-doc-rcv )  FORWARD.
FUNCTION status-edi-trn RETURNS CHARACTER
  ( buffer loc-t-doc for buf_trn-doc )  FORWARD.
DEFINE MENU m-exec
       MENU-ITEM m_gen-1        LABEL "Генерация ФО"
       MENU-ITEM m_lkp-fo       LABEL "Просмотр  ФО"
       MENU-ITEM m_gen-2        LABEL "Отказаться от генерации ФО"
       MENU-ITEM m_gen-3        LABEL "Снять признак - есть генерация ФО"
       MENU-ITEM m_gen-4        LABEL "Снять 'не опред'".
DEFINE MENU m-export
       MENU-ITEM m___Excel      LABEL "Экспорт в Excel"
       MENU-ITEM m_mobilscn     LABEL "Экспорт в Моб.сканер".
DEFINE MENU m-print
       MENU-ITEM m_print-list-rcv LABEL "Печать списка поставок"
       MENU-ITEM m_print-one    LABEL "Печать документа".
DEFINE MENU m-rep
       MENU-ITEM m_print_rep    LABEL "Отчет об исполнении поставок".
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 9 BY 1.
DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     SIZE 12 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 12 BY 1.
DEFINE BUTTON b-excecF
     LABEL "&Применить":L
     SIZE 10.38 BY 1 TOOLTIP "Найти записи по условию".
DEFINE BUTTON b-exec
     LABEL "&Генерация ФО":L
     SIZE 14 BY 1 TOOLTIP "Создание и просмотр ФО".
DEFINE BUTTON b-export
     LABEL "&Экспорт":L
     SIZE 12 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-history
     LABEL "&История":L
     SIZE 3 BY 1 TOOLTIP "История изменения поставки".
DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 12 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.
DEFINE BUTTON b-open
     LABEL "&Открыть":L
     SIZE 12 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 12 BY 1.
DEFINE BUTTON b-rep
     LABEL "О&тчеты":L
     SIZE 12 BY 1.
DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     SIZE 12 BY 1.
DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     SIZE 12 BY 1.
DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3 BY 1.
DEFINE VARIABLE r-cli-type AS CHARACTER INITIAL "орг"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "орг","чел","маг","скл"
     DROP-DOWN
     SIZE 6.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "          Поставщик и Дата доставки           "
      VIEW-AS TEXT
     SIZE 46.25 BY .67 TOOLTIP "Фильтр с кнопкой ПРИМЕНИТЬ"
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE r-cli-code AS INTEGER FORMAT ">>>>>>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Код Поставщика" NO-UNDO.
DEFINE VARIABLE r-cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(14)"
     LABEL "№ &заказа"
     VIEW-AS FILL-IN
     SIZE 13.25 BY 1 TOOLTIP "Поиск по № заказа" NO-UNDO.
DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999"
     LABEL "Д&ата док-та"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиск по дате док.поставки" NO-UNDO.
DEFINE VARIABLE sch-date-rcv AS DATE FORMAT "99/99/9999"
     LABEL "Д&ата факт"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиск по дате факт.поставки" NO-UNDO.
DEFINE VARIABLE sch-num AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Найдено"
      VIEW-AS TEXT
     SIZE 3 BY .67
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE sch-rcv AS CHARACTER FORMAT "X(14)"
     LABEL "№ &пост-ки"
     VIEW-AS FILL-IN
     SIZE 13.25 BY 1 TOOLTIP "Поиск по № Поставки" NO-UNDO.
DEFINE VARIABLE sch-ship AS DATE FORMAT "99/99/9999"
     LABEL "c"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиск по дате доставки С" NO-UNDO.
DEFINE VARIABLE sch-ship-2 AS DATE FORMAT "99/99/9999"
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиск по дате доставки ПО" NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 47.5 BY 3.25 TOOLTIP "Фильтр с кнопкой ПРИМЕНИТЬ".
DEFINE new shared QUERY br-docs FOR
      bufs_ord-doc-rcv,
      buf_ord-doc SCROLLING.
DEFINE QUERY BROWSE-34 FOR
      buf_ord-chain,
      buf_trn-doc SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      bufs_ord-doc-rcv SCROLLING.
DEFINE BROWSE br-docs
  QUERY br-docs NO-LOCK DISPLAY
      mark-string (buffer bufs_ord-doc-rcv) @ mark COLUMN-LABEL "*" FORMAT "x(1)"
if bufs_ord-doc-rcv.ord-int2 = integer('2':U) then "!" else "" column-label "!" FORMAT "x(1)" COLUMN-FGCOLOR 12
IF (bufs_ord-doc-rcv.doc-type = "out":U) THEN ("внешн") ELSE ("внутр") COLUMN-LABEL "Тип" FORMAT "x(5)"
IF (bufs_ord-doc-rcv.status_ = 'факт':U or bufs_ord-doc-rcv.status_ = 'закрыто':U)  THEN (bufs_ord-doc-rcv.status_ + string(bufs_ord-doc-rcv.flag_,"+/-"))  ELSE (bufs_ord-doc-rcv.status_)  COLUMN-LABEL "Статус"
bufs_ord-doc-rcv.rcv-code COLUMN-LABEL "Номер"
cli-doc-out (buffer bufs_ord-doc-rcv) @ prt-out-cli-code COLUMN-LABEL "№по пост-ку" FORMAT "x(14)"
bufs_ord-doc-rcv.doc-date FORMAT "99/99/99"
bufs_ord-doc-rcv.fact-date FORMAT "99/99/99"
cli-name (buffer bufs_ord-doc-rcv) @ prt-cli-name   COLUMN-LABEL "Поставщик" FORMAT "x(15)"
sum-rubl (buffer bufs_ord-doc-rcv) @ prt-sum-rubl COLUMN-LABEL "Сумма поставки" FORMAT ">>>>>>>>>>>>9.99"
bufs_ord-doc-rcv.ship-date COLUMN-LABEL "Доставка" FORMAT "99/99/99"
bufs_ord-doc-rcv.obj-type + " " + string(bufs_ord-doc-rcv.obj-code) COLUMN-LABEL "Объект" FORMAT "x(10)"
bufs_ord-doc-rcv.cli-type + " " + string(bufs_ord-doc-rcv.cli-code) COLUMN-LABEL "Контрагент" FORMAT "x(10)"
f-fo ( buffer bufs_ord-doc-rcv ) @ v-fo column-label "ФО" format "x(11)"
STRING(bufs_ord-doc-rcv.ship-time, "HH:MM")  FORMAT "x(6)" @ bufs_ord-doc-rcv.ship-time COLUMN-LABEL "Время"
STRING(bufs_ord-doc-rcv.fact-ship-time, "HH:MM")  FORMAT "x(6)" @ bufs_ord-doc-rcv.fact-ship-time COLUMN-LABEL "Факт"
bufs_ord-doc-rcv.cons-code COLUMN-LABEL "СЗФП"
bufs_ord-doc-rcv.doc-code COLUMN-LABEL "Заказ" LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
buf_ord-doc.cli-type + " " + string(buf_ord-doc.cli-code) COLUMN-LABEL "Поставщик" FORMAT "x(10)"
      LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
buf_ord-doc.doc-type COLUMN-LABEL "Тип" FORMAT "x(3)"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
IF (buf_ord-doc.status_ = 'факт':U or buf_ord-doc.status_ = 'закрыто':U)  THEN (buf_ord-doc.status_ + string(buf_ord-doc.flag_,"+/-"))  ELSE (buf_ord-doc.status_)
      COLUMN-LABEL "Статус"  FORMAT "x(8)"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
status-edoc-edi-light (buffer buf_ord-doc, input is-edoc-nn, input is-edi, output v-color) @ v-status-edi COLUMN-LABEL "Статус EDI" FORMAT "x(12)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.
DEFINE BROWSE BROWSE-34
  QUERY BROWSE-34 NO-LOCK DISPLAY
      buf_ord-chain.rel-doc-code COLUMN-LABEL "ПН" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      IF (buf_trn-doc.status_ = 'факт':U or buf_trn-doc.status_ = 'закрыто':U)  THEN (buf_trn-doc.status_ + string(buf_trn-doc.flag_,"+/-"))  ELSE (buf_trn-doc.status_)
      COLUMN-LABEL "Статус"  FORMAT "x(8)"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      buf_trn-doc.fact-qnty COLUMN-LABEL "Количество" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      buf_trn-doc.fact-rubl COLUMN-LABEL "Сумма РУБ" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      buf_trn-doc.doc-date COLUMN-LABEL "Дата док" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      buf_trn-doc.fact-date COLUMN-LABEL "Дата факт" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      STRING(buf_trn-doc.fact-time, "HH:MM") @ buf_trn-doc.fact-time COLUMN-LABEL "Время факт" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      buf_trn-doc.doc-type COLUMN-LABEL "Тип" FORMAT "x(3)"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      status-edi-trn ( buffer buf_trn-doc )  @ v-status-trn-edi COLUMN-LABEL "Статус EDI" FORMAT "x(12)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 5.21 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 13
     b-rep AT ROW 1 COL 25
     b-sch AT ROW 1 COL 37
     b-close AT ROW 1 COL 37
     b-exec AT ROW 1 COL 49
     b-open AT ROW 1 COL 63
     b-print AT ROW 1 COL 90.5
     b-history AT ROW 1 COL 93.5
     b-help AT ROW 1 COL 96.5
     b-mark AT ROW 2 COL 1
     b-chg AT ROW 2 COL 4
     b-lkp AT ROW 2 COL 13
     b-del AT ROW 2 COL 25
     b-export AT ROW 2 COL 37 WIDGET-ID 2
     r-cli-type AT ROW 3 COL 51.13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     r-cli-code AT ROW 3 COL 57.5 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     r-cli AT ROW 3 COL 73.75 WIDGET-ID 18
     sch-date-rcv AT ROW 3.04 COL 36.88 COLON-ALIGNED
     sch-rcv AT ROW 3.08 COL 10 COLON-ALIGNED
     b-excecF AT ROW 4 COL 88 WIDGET-ID 4
     sch-ship AT ROW 4.08 COL 54.75 COLON-ALIGNED WIDGET-ID 6
     sch-ship-2 AT ROW 4.08 COL 71.75 COLON-ALIGNED WIDGET-ID 8
     sch-code AT ROW 4.13 COL 10 COLON-ALIGNED
     sch-date AT ROW 4.13 COL 36.88 COLON-ALIGNED
     br-docs AT ROW 5.25 COL 1
     BROWSE-34 AT ROW 17.25 COL 1 WIDGET-ID 100
     sch-num AT ROW 1.17 COL 83.13 COLON-ALIGNED
     FILL-IN-1 AT ROW 2.17 COL 50.63 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     r-cli-name AT ROW 3.13 COL 75 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     RECT-1 AT ROW 2 COL 52 WIDGET-ID 10
     SPACE(0.00) SKIP(17.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Поставки под заказ"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-exec:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-exec:HANDLE.
ASSIGN
       b-export:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-export:HANDLE.
ASSIGN
       b-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-print:HANDLE.
ASSIGN
       b-rep:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-rep:HANDLE.
ASSIGN
       sch-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
if not available bufs_ord-doc-rcv then return .
define variable  v-line-mode  as character no-undo .
define variable  v-doc-mode   as character no-undo .
define variable  v-list-mode  as character no-undo .
 define variable g-log as logical   no-undo .
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ord-rcv_update':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
if buf_ord-doc.doc-type = 'ОО':U then return.
    if available bufs_ord-doc-rcv then do:
          if bufs_ord-doc-rcv.status_ = 'факт':U then do :
              message "Статус" caps(bufs_ord-doc-rcv.status_) "изменять нельзя! " view-as alert-box error .
              ll-rec = recid(bufs_ord-doc-rcv) .
              return no-apply .
          end.
          ll-rec = recid(bufs_ord-doc-rcv) .
        if bufs_ord-doc-rcv.status_ = 'поставка':U then  do:
              assign
                v-line-mode  = 'ПРОСМОТР':U
                v-doc-mode   = 'ПРОСМОТР':U
                v-list-mode  = 'поставка':U
               .
        end.
        else  do:
              assign
                v-line-mode = 'ИЗМЕНЕНИЕ':U
                v-doc-mode  = 'ИЗМЕНЕНИЕ':U
                .
        end.
        run cus/or-obj.w (
               input  parParentProc
             , input  p-host-code
             , input  recid(bufs_ord-doc-rcv)
             , input  3
             , input  v-list-mode
             , input  v-line-mode
             , input-output  v-doc-mode  ) .
        v-glog =  br-docs:refresh() .
    end.
apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_gen-1
DO:
run proc-m_gen-1 no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-2
DO:
run proc-m_gen-2 no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-3
DO:
run proc-m_gen-3 no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-4
DO:
run proc-m_gen-4 no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_lkp-fo
DO:
run proc-m_lkp-fo no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF b-close IN FRAME Dialog-Frame
DO:
    run cus/rcv-clos.p
      ( input parParentProc ,
        input bufs_ord-doc-rcv.rcv-code ,
        input yes ,
        input store-type ,
        input store-code ,
        input yes
        ) no-error .
    if error-status :error then do:
          message  return-value  view-as alert-box error .
          return no-apply .
    end.
  if p-g#stat = ? then  v-glog =  br-docs:refresh() .
                else OPEN QUERY br-docs FOR EACH bufs_ord-doc-rcv NO-LOCK where ( if list-mode = 'obj':U then ( bufs_ord-doc-rcv.obj-code = store-code and                                 bufs_ord-doc-rcv.obj-type = store-type)                           else (                                  if list-mode = 'cli':U then (bufs_ord-doc-rcv.cli-code = store-code and                                                               bufs_ord-doc-rcv.cli-type = store-type)                                                         else ( true = true )                                ) )    and bufs_ord-doc-rcv.host-code = p-host-code and (p-g#cons-code = ? or ( bufs_ord-doc-rcv.cons-code = p-g#cons-code)) and (p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type)) and (p-g#stat = ? or  (bufs_ord-doc-rcv.status_ = p-g#stat  )) and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 )) and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type)) ,        EACH buf_ord-doc WHERE buf_ord-doc.doc-code = bufs_ord-doc-rcv.doc-code OUTER-JOIN NO-LOCK by  bufs_ord-doc-rcv.doc-date desc by bufs_ord-doc-rcv.doc-code desc .
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
if not available bufs_ord-doc-rcv then return .
 define variable g-log as logical   no-undo .
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ord-rcv_deletion':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
  if buf_ord-doc.doc-type = 'ОО':U then return.
    if available bufs_ord-doc-rcv then do:
       find current bufs_ord-doc-rcv exclusive-lock no-error.
            if avail bufs_ord-doc-rcv then do:
              if bufs_ord-doc-rcv.status_ <> 'новый':U then do :
              message "Статус " bufs_ord-doc-rcv.status_  " удалять нельзя! " view-as alert-box error .
              return.
              end.
               message "Удалить поставку №"  bufs_ord-doc-rcv.rcv-code "?" view-as alert-box
                        question buttons yes-no title "Вопрос" update v-glog.
                    if v-glog then do:
                        delete  bufs_ord-doc-rcv .
                        OPEN QUERY br-docs FOR EACH bufs_ord-doc-rcv NO-LOCK where ( if list-mode = 'obj':U then ( bufs_ord-doc-rcv.obj-code = store-code and                                 bufs_ord-doc-rcv.obj-type = store-type)                           else (                                  if list-mode = 'cli':U then (bufs_ord-doc-rcv.cli-code = store-code and                                                               bufs_ord-doc-rcv.cli-type = store-type)                                                         else ( true = true )                                ) )    and bufs_ord-doc-rcv.host-code = p-host-code and (p-g#cons-code = ? or ( bufs_ord-doc-rcv.cons-code = p-g#cons-code)) and (p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type)) and (p-g#stat = ? or  (bufs_ord-doc-rcv.status_ = p-g#stat  )) and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 )) and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type)) ,        EACH buf_ord-doc WHERE buf_ord-doc.doc-code = bufs_ord-doc-rcv.doc-code OUTER-JOIN NO-LOCK by  bufs_ord-doc-rcv.doc-date desc by bufs_ord-doc-rcv.doc-code desc .
                    end.
               end.
  end.
END.
ON CHOOSE OF b-excecF IN FRAME Dialog-Frame
DO:
  run set-selection in this-procedure no-error .
  if error-status :error then return .
  run OpenBr in this-procedure .
END.
ON CHOOSE OF b-export IN FRAME Dialog-Frame
DO:
if not available bufs_ord-doc-rcv then return .
 define variable g-log as logical   no-undo .
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ord-rcv_lookup':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
if buf_ord-doc.doc-type = 'ОО':U then return.
ll-rec = recid(bufs_ord-doc-rcv) .
next-prev = no.
br-rcv-handle = br-docs:handle.
do while next-prev <> ?:
  if not available bufs_ord-doc-rcv then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
  ll-rec = recid(bufs_ord-doc-rcv) .
  run cus/lkp-rcv.w ( parParentProc,  input-output ll-rec ) .
  reposition br-docs to recid ll-rec no-error.
  apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
end.
 if br-rcv-handle = ? then reposition br-docs to recid ll-rec no-error.
END.
ON CHOOSE OF b-history IN FRAME Dialog-Frame
DO:
if not available bufs_ord-doc-rcv then return .
    run cus/ordcdoc.w (
    parParentProc,
    bufs_ord-doc-rcv.host-code,
    bufs_ord-doc-rcv.doc-code,
    bufs_ord-doc-rcv.rcv-code )
        .
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
if not available bufs_ord-doc-rcv then return .
 define variable g-log as logical   no-undo .
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ord-rcv_lookup':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
 if not g-log then  return .
if buf_ord-doc.doc-type = 'ОО':U then return.
ll-rec = recid(bufs_ord-doc-rcv) .
next-prev = no.
br-rcv-handle = br-docs:handle.
do while next-prev <> ?:
  if not available bufs_ord-doc-rcv then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
  ll-rec = recid(bufs_ord-doc-rcv) .
  run cus/lkp-rcv.w ( parParentProc,  input-output ll-rec ) .
  reposition br-docs to recid ll-rec no-error.
  apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
end.
 if br-rcv-handle = ? then reposition br-docs to recid ll-rec no-error.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
define variable g#log as logical   no-undo .
  run local-mark no-error .
  if error-status :error  then return .
  g#log = br-docs:select-next-row ().
  apply "entry" to br-docs in frame Dialog-Frame.
end.
ON CHOOSE OF b-open IN FRAME Dialog-Frame
DO:
  if buf_ord-doc.doc-type = 'ОО':U then return.
  if available bufs_ord-doc-rcv then do:
       find current bufs_ord-doc-rcv exclusive-lock no-error.
            if avail bufs_ord-doc-rcv then do:
               message "Открыть поставку "  bufs_ord-doc-rcv.rcv-code "?" view-as alert-box
                        question buttons yes-no title "Вопрос" update v-glog.
                    if v-glog then do:
                       ll-rec = recid(bufs_ord-doc-rcv) .
                          case bufs_ord-doc-rcv.status_:
                          when 'новый':U then do:
                             message "Поставка "  bufs_ord-doc-rcv.rcv-code " Уже открыта до НОВЫЙ" view-as alert-box .
                          end.
                          when 'поставка':U then do:
                            Assign
                              bufs_ord-doc-rcv.status_   = 'новый':U
                              .
                          end.
                          when 'факт':U then do:
                            Assign
                              bufs_ord-doc-rcv.fact-date = ?
                              bufs_ord-doc-rcv.status_   = 'поставка':U
                              .
                            end.
                          end case.
                    OPEN QUERY br-docs FOR EACH bufs_ord-doc-rcv NO-LOCK where ( if list-mode = 'obj':U then ( bufs_ord-doc-rcv.obj-code = store-code and                                 bufs_ord-doc-rcv.obj-type = store-type)                           else (                                  if list-mode = 'cli':U then (bufs_ord-doc-rcv.cli-code = store-code and                                                               bufs_ord-doc-rcv.cli-type = store-type)                                                         else ( true = true )                                ) )    and bufs_ord-doc-rcv.host-code = p-host-code and (p-g#cons-code = ? or ( bufs_ord-doc-rcv.cons-code = p-g#cons-code)) and (p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type)) and (p-g#stat = ? or  (bufs_ord-doc-rcv.status_ = p-g#stat  )) and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 )) and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type)) ,        EACH buf_ord-doc WHERE buf_ord-doc.doc-code = bufs_ord-doc-rcv.doc-code OUTER-JOIN NO-LOCK by  bufs_ord-doc-rcv.doc-date desc by bufs_ord-doc-rcv.doc-code desc .
                     reposition br-docs to recid ll-rec no-error .
                     apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
                    end.
            end.
  end.
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch no-error.
  if error-status:error then return no-apply.
END.
ON ANY-PRINTABLE OF br-docs IN FRAME Dialog-Frame
DO:
  apply "entry" to sch-code in frame Dialog-Frame.
END.
ON ROW-DISPLAY OF br-docs IN FRAME Dialog-Frame
DO:
define variable v-str as character no-undo .
define variable v-loc-color as integer no-undo .
    assign
v-str = status-edoc-edi-light(buffer buf_ord-doc, input is-edoc-nn, input is-edi, output v-loc-color)
no-error.
if error-status:error then do:
    assign
  v-status-edi:fgcolor in browse BR-DOCS = ?
    .
end.
else do:
  assign
  v-status-edi:fgcolor in browse BR-DOCS = v-loc-color
  .
end.
end.
ON VALUE-CHANGED OF br-docs IN FRAME Dialog-Frame
DO:
  OPEN QUERY BROWSE-34 FOR EACH buf_ord-chain NO-LOCK WHERE          buf_ord-chain.doc-code = bufs_ord-doc-rcv.rcv-code and          buf_ord-chain.doc-type = 'rcv' and          buf_ord-chain.rel-doc-type = 'trn' ,            EACH buf_trn-doc NO-LOCK where          buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code INDEXED-REPOSITION.
END.
ON CHOOSE OF MENU-ITEM m_mobilscn
DO:
  if not available bufs_ord-doc-rcv then return .
  run cus/z-tot2.p (input parparentproc , input "rcv" , input "" ,input   bufs_ord-doc-rcv.rcv-code ) .
END.
ON CHOOSE OF MENU-ITEM m_print-list-rcv
DO:
  run print-list in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m_print-one
DO:
  if not available bufs_ord-doc-rcv then return .
  run cus/torg-261.p ( input parParentProc, input recid (bufs_ord-doc-rcv)) .
END.
ON CHOOSE OF MENU-ITEM m_print_rep
DO:
  run cus/g-isp-po.p ( input parParentProc ) .
END.
ON CHOOSE OF MENU-ITEM m___Excel
DO:
  if not available bufs_ord-doc-rcv then return .
  run cus/z-tot3.p ( input parParentProc , input bufs_ord-doc-rcv.rcv-code , input bufs_ord-doc-rcv.doc-code ) .
END.
ON CHOOSE OF r-cli IN FRAME Dialog-Frame
DO:
define variable rid-list as character no-undo .
define buffer b#clients for ub.clients.
   run ref/cli-all.w ( parparentproc, input "b-sel", 'орг':U, ?, ?, ?, ?, ?, output  rid-list).
   find first b#clients where recid(b#clients) = integer(rid-list) no-lock no-error.
   if available  b#clients then do:
       r-cli-code = b#clients.obj-code.
       r-cli-type = b#clients.obj-type.
       r-cli-name = b#clients.obj-name.
   end.
   display
   r-cli-code
   r-cli-type
   r-cli-name
   with frame Dialog-Frame .
END.
ON LEAVE OF r-cli-code IN FRAME Dialog-Frame
OR  RETURN OF r-cli-code IN FRAME Dialog-Frame
DO:
  assign
    r-cli-code
    r-cli-type
  .
  define buffer b#clients for ub.clients.
  find first b#clients no-lock  where
             b#clients.obj-code = r-cli-code and
             b#clients.obj-type = r-cli-type
             no-error.
  if available b#clients
      then r-cli-name = b#clients.obj-name .
      else r-cli-name = "" .
  display r-cli-name with frame Dialog-Frame .
END.
ON MOUSE-SELECT-DBLCLICK OF sch-code IN FRAME Dialog-Frame
OR  RETURN OF sch-code IN FRAME Dialog-Frame
DO:
  if sch-code <> input frame Dialog-Frame sch-code or sch-field <> "doc-code" then do:
      sch-num = 0.
      hide sch-num in frame Dialog-Frame.
  end.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
 sch-field = "doc-code".
 assign sch-code = input frame Dialog-Frame sch-code.
 find first buf_ord-doc-rcv no-lock  where
            buf_ord-doc-rcv.doc-code  begins sch-code
        and buf_ord-doc-rcv.obj-code = v-cntxt-obj-code
        and buf_ord-doc-rcv.obj-type = v-cntxt-obj-type
        and buf_ord-doc-rcv.host-code = p-host-code
        and ( p-g#type = ? or  ( buf_ord-doc-rcv.doc-type = p-g#type))
        no-error .
        if available buf_ord-doc-rcv then doc-rec = recid (buf_ord-doc-rcv) .
                                     else doc-rec = ? .
  if doc-rec = ? then message "Документ не найден !"  .
  else do:
      reposition br-docs to recid doc-rec no-error.
      apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
  end.
return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK OF sch-date IN FRAME Dialog-Frame
OR  RETURN OF sch-date IN FRAME Dialog-Frame
DO:
  if sch-date <> input frame Dialog-Frame sch-date or sch-field <> "doc-date" then do:
  sch-num = 0.
  hide sch-num in frame Dialog-Frame.
end.
 sch-field = "doc-date".
 assign sch-date = input frame Dialog-Frame sch-date.
 find first ub.ord-doc-rcv no-lock  where ub.ord-doc-rcv.doc-date  = sch-date no-error .
        if available ub.ord-doc-rcv then doc-rec = recid(ub.ord-doc-rcv) .
            else doc-rec = ? .
  if doc-rec = ? then message "Документ не найден !"  .
  else do:
      reposition br-docs to recid doc-rec no-error.
      apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
  end.
return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK OF sch-date-rcv IN FRAME Dialog-Frame
OR  RETURN OF sch-date-rcv IN FRAME Dialog-Frame
DO:
  if sch-date-rcv <> input frame Dialog-Frame sch-date-rcv or sch-field <> "rcv-date" then do:
  sch-num = 0.
  hide sch-num in frame Dialog-Frame.
end.
 sch-field = "rcv-date".
 assign sch-date-rcv = input frame Dialog-Frame sch-date-rcv.
 find first ub.ord-doc-rcv no-lock  where ub.ord-doc-rcv.fact-date  = sch-date-rcv no-error .
        if available ub.ord-doc-rcv then doc-rec = recid( ub.ord-doc-rcv) .
            else doc-rec = ? .
  if doc-rec = ? then message "Документ не найден !"  .
  else do:
      reposition br-docs to recid doc-rec no-error.
      apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
  end.
return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK OF sch-rcv IN FRAME Dialog-Frame
OR  RETURN OF sch-rcv IN FRAME Dialog-Frame
DO:
  if sch-rcv <> input frame Dialog-Frame sch-code or sch-field <> "rcv-code" then do:
  sch-num = 0.
  hide sch-num in frame Dialog-Frame.
end.
 sch-field = "rcv-code".
 assign sch-rcv = input frame Dialog-Frame sch-rcv.
 find first ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.rcv-code  begins sch-rcv no-error .
        if available ord-doc-rcv then doc-rec = recid(ub.ord-doc-rcv) .
            else doc-rec = ? .
  if doc-rec = ? then message "Документ не найден !"  .
  else do:
    reposition br-docs to recid doc-rec no-error.
    apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
  end.
return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK OF sch-ship-2 IN FRAME Dialog-Frame
DO:
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-date in frame Dialog-Frame
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
on delete-character of sch-date in frame Dialog-Frame
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
on ctrl-d of sch-date in frame Dialog-Frame
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
on ctrl-b of sch-date in frame Dialog-Frame
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
on ctrl-e of sch-date in frame Dialog-Frame
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
on ctrl-f of sch-date in frame Dialog-Frame
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
  define MENU m-ed-date29
    MENU-ITEM m-ed-date29-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date29-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date29-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date29-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date29 :HANDLE
      sch-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle29 as handle no-undo .
  assign
    v-label-handle29 = sch-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle29)
  then do:
    if v-label-handle29 :tooltip = ""
    or v-label-handle29 :tooltip = ?
    then do:
      assign
        v-label-handle29 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date29-1 in menu m-ed-date29 DO:
    apply "ctrl-b":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date29-2 in menu m-ed-date29 DO:
    apply "ctrl-d":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date29-3 in menu m-ed-date29 DO:
    apply "ctrl-e":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date29-4 in menu m-ed-date29 DO:
    apply "ctrl-f":U to sch-date in frame Dialog-Frame .
  END.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-date-rcv in frame Dialog-Frame
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
on delete-character of sch-date-rcv in frame Dialog-Frame
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
on ctrl-d of sch-date-rcv in frame Dialog-Frame
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
on ctrl-b of sch-date-rcv in frame Dialog-Frame
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
on ctrl-e of sch-date-rcv in frame Dialog-Frame
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
on ctrl-f of sch-date-rcv in frame Dialog-Frame
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
  define MENU m-ed-date31
    MENU-ITEM m-ed-date31-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date31-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date31-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date31-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-date-rcv :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-date-rcv :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date31 :HANDLE
      sch-date-rcv :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle31 as handle no-undo .
  assign
    v-label-handle31 = sch-date-rcv :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle31)
  then do:
    if v-label-handle31 :tooltip = ""
    or v-label-handle31 :tooltip = ?
    then do:
      assign
        v-label-handle31 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date31-1 in menu m-ed-date31 DO:
    apply "ctrl-b":U to sch-date-rcv in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date31-2 in menu m-ed-date31 DO:
    apply "ctrl-d":U to sch-date-rcv in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date31-3 in menu m-ed-date31 DO:
    apply "ctrl-e":U to sch-date-rcv in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date31-4 in menu m-ed-date31 DO:
    apply "ctrl-f":U to sch-date-rcv in frame Dialog-Frame .
  END.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-ship in frame Dialog-Frame
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
on delete-character of sch-ship in frame Dialog-Frame
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
on ctrl-d of sch-ship in frame Dialog-Frame
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
on ctrl-b of sch-ship in frame Dialog-Frame
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
on ctrl-e of sch-ship in frame Dialog-Frame
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
on ctrl-f of sch-ship in frame Dialog-Frame
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
  define MENU m-ed-date33
    MENU-ITEM m-ed-date33-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date33-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date33-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date33-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-ship :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-ship :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date33 :HANDLE
      sch-ship :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle33 as handle no-undo .
  assign
    v-label-handle33 = sch-ship :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle33)
  then do:
    if v-label-handle33 :tooltip = ""
    or v-label-handle33 :tooltip = ?
    then do:
      assign
        v-label-handle33 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date33-1 in menu m-ed-date33 DO:
    apply "ctrl-b":U to sch-ship in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date33-2 in menu m-ed-date33 DO:
    apply "ctrl-d":U to sch-ship in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date33-3 in menu m-ed-date33 DO:
    apply "ctrl-e":U to sch-ship in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date33-4 in menu m-ed-date33 DO:
    apply "ctrl-f":U to sch-ship in frame Dialog-Frame .
  END.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-ship-2 in frame Dialog-Frame
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
on delete-character of sch-ship-2 in frame Dialog-Frame
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
on ctrl-d of sch-ship-2 in frame Dialog-Frame
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
on ctrl-b of sch-ship-2 in frame Dialog-Frame
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
on ctrl-e of sch-ship-2 in frame Dialog-Frame
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
on ctrl-f of sch-ship-2 in frame Dialog-Frame
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
  define MENU m-ed-date35
    MENU-ITEM m-ed-date35-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date35-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date35-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date35-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-ship-2 :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-ship-2 :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date35 :HANDLE
      sch-ship-2 :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle35 as handle no-undo .
  assign
    v-label-handle35 = sch-ship-2 :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle35)
  then do:
    if v-label-handle35 :tooltip = ""
    or v-label-handle35 :tooltip = ?
    then do:
      assign
        v-label-handle35 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date35-1 in menu m-ed-date35 DO:
    apply "ctrl-b":U to sch-ship-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date35-2 in menu m-ed-date35 DO:
    apply "ctrl-d":U to sch-ship-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date35-3 in menu m-ed-date35 DO:
    apply "ctrl-e":U to sch-ship-2 in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date35-4 in menu m-ed-date35 DO:
    apply "ctrl-f":U to sch-ship-2 in frame Dialog-Frame .
  END.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  run OpenBr in this-procedure .
    apply "VALUE-CHANGED" to br-docs.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  b-exec:POPUP-MENU IN FRAME Dialog-Frame = MENU m-exec:HANDLE.
  b-exec:MENU-MOUSE = 1.
  b-export:POPUP-MENU IN FRAME Dialog-Frame = MENU m-export:HANDLE.
  b-export:MENU-MOUSE = 1.
  b-rep:POPUP-MENU IN FRAME Dialog-Frame = MENU m-rep:HANDLE.
  b-rep:MENU-MOUSE = 1.
  b-print:POPUP-MENU IN FRAME Dialog-Frame = MENU m-print:HANDLE.
  b-print:MENU-MOUSE = 1.
if lookup (list-mode , "without-fo,whith-fo,firm-fin" ) > 0  then do:
    ASSIGN
      MENU-ITEM m_lkp-fo :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-1 :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-2 :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-3 :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-4 :SENSITIVE IN MENU m-exec = true
      .
end.
else do:
    ASSIGN
      MENU-ITEM m_lkp-fo :SENSITIVE IN MENU m-exec =  false
      MENU-ITEM m_gen-1  :SENSITIVE IN MENU m-exec =  false
      MENU-ITEM m_gen-2  :SENSITIVE IN MENU m-exec =  false
      MENU-ITEM m_gen-3  :SENSITIVE IN MENU m-exec =  false
      MENU-ITEM m_gen-4  :SENSITIVE IN MENU m-exec =  false
      .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-edi'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output par-is-edi
  ,output par-type
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'edoc-nn'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-edoc-nn
  ,output par-type
  ) no-error .
assign
is-edi = lookup(par-is-edi, "true,yes":U) > 0
.
assign
is-edoc-nn = lookup(par-is-edoc-nn, "true,yes":U) > 0
.
if not (is-edi and is-edoc-nn) then do:
    v-status-edi:VISIBLE IN BROWSE br-docs = FALSE.
    v-status-trn-edi:VISIBLE IN BROWSE browse-34 = FALSE.
end.
  RUN enable_UI.
  RUN init-p.
  run OpenBr in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH bufs_ord-doc-rcv NO-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY r-cli-type r-cli-code sch-date-rcv sch-rcv sch-ship sch-ship-2
          sch-code sch-date FILL-IN-1 r-cli-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit RECT-1 b-sel b-rep b-sch b-close b-exec b-print b-history
         b-help b-mark b-chg b-lkp b-del b-export r-cli-type r-cli-code r-cli
         sch-date-rcv sch-rcv b-excecF sch-ship sch-ship-2 sch-code sch-date
         br-docs BROWSE-34 FILL-IN-1 r-cli-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-docs FOR EACH bufs_ord-doc-rcv NO-LOCK where ( if list-mode = 'obj':U then ( bufs_ord-doc-rcv.obj-code = store-code and                                 bufs_ord-doc-rcv.obj-type = store-type)                           else (                                  if list-mode = 'cli':U then (bufs_ord-doc-rcv.cli-code = store-code and                                                               bufs_ord-doc-rcv.cli-type = store-type)                                                         else ( true = true )                                ) )    and bufs_ord-doc-rcv.host-code = p-host-code and (p-g#cons-code = ? or ( bufs_ord-doc-rcv.cons-code = p-g#cons-code)) and (p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type)) and (p-g#stat = ? or  (bufs_ord-doc-rcv.status_ = p-g#stat  )) and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 )) and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type)) ,        EACH buf_ord-doc WHERE buf_ord-doc.doc-code = bufs_ord-doc-rcv.doc-code OUTER-JOIN NO-LOCK by  bufs_ord-doc-rcv.doc-date desc by bufs_ord-doc-rcv.doc-code desc .    OPEN QUERY BROWSE-34 FOR EACH buf_ord-chain NO-LOCK WHERE          buf_ord-chain.doc-code = bufs_ord-doc-rcv.rcv-code and          buf_ord-chain.doc-type = 'rcv' and          buf_ord-chain.rel-doc-type = 'trn' ,            EACH buf_trn-doc NO-LOCK where          buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE init-p :
if list-mode = "firm":U  then
    assign
      sss = "ПОСТАВКИ под заказ   ФИРМА: " + p-g#host-name .
    else
    assign
      sss = "ПОСТАВКИ под заказ   ОБЪЕКТ: " + store-type + " " + string(store-code) .
if list-mode = "with-fo":U then do:
  sss = "ПОСТАВКИ под заказ  --  Есть ФО  --  ФИРМА: " + p-g#host-name .
  disable b-close b-chg b-del with frame Dialog-Frame .
end.
if list-mode = "without-fo":U then do:
  sss = "ПОСТАВКИ под заказ  --  Нет ФО  --  ФИРМА: " + p-g#host-name .
  disable b-close b-chg b-del with frame Dialog-Frame .
end.
if list-mode = "firm-fin":U then do:
  sss = "ПОСТАВКИ под заказ  ФИРМА: " + p-g#host-name .
  disable b-close b-chg b-del with frame Dialog-Frame .
end.
if list-mode = "cli":U then do:
    assign
      sss = "ПОСТАВКИ под заказ   ПОСТАВЩИК: " + store-type + " " + string(store-code) .
  disable b-close with frame Dialog-Frame .
end.
case p-g#type :
  when "in" then sss = sss + " , Тип: Внутренние".
  when "out" then  sss = sss + " , Тип: Внешние".
end case.
case p-g#stat :
  when 'новый':U then sss = sss + " , Статус: " +  p-g#stat.
  when 'поставка':U then sss = sss + " , Статус: " +  p-g#stat.
  when 'факт':U then  sss = sss + " , Статус: " +  p-g#stat.
end case.
if p-g#cons-code <> ? then  sss = sss + " , СЗФП № " +  p-g#cons-code.
frame Dialog-Frame:title = sss.
END PROCEDURE.
PROCEDURE openbr :
 do
 on error undo, return error return-value
 :
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Поставки ".
run waitfram-show("Ждите...").
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
do:
case list-mode :
when 'obj':U then do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-38  as logical   no-undo .
define variable  l-filter-open-38    as logical   .
define variable  flt-rec-38       as recid     no-undo .
define variable  filter-name-38      as character no-undo .
define variable  where-phrase-38     as character no-undo .
define variable  sort-phrase-38      as character no-undo .
define variable  where-phrase-rus-38 as character no-undo .
define variable  sort-phrase-rus-38  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-38
  ,output filter-name-38
  ,output where-phrase-38
  ,output sort-phrase-38
  ,output where-phrase-rus-38
  ,output sort-phrase-rus-38
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-38
      ) no-error .
  assign
    l-filter-open-38 = false
  .
  if flt-rec-38 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-38 as character no-undo .
    define variable  parameter-3-38 as character no-undo .
    define variable  parameter-4-38 as character no-undo .
    define variable  parameter-5-38 as character no-undo .
    define variable  parameter-6-38 as character no-undo .
    define variable  parameter-7-38 as character no-undo .
      assign
      parameter-3-38 =
                              "FOR EACH bufs_ord-doc-rcv"
      parameter-4-38 =
        (
          if (" bufs_ord-doc-rcv.obj-code = store-code   and bufs_ord-doc-rcv.obj-type = store-type   and bufs_ord-doc-rcv.host-code = p-host-code   and ( p-g#cons-code = ?                              or  ( bufs_ord-doc-rcv.cons-code = p-g#cons-code ))   and ( p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type ))   and ( p-g#stat = ? or  ( bufs_ord-doc-rcv.status_ = p-g#stat  ))   and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 ))   and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type))   " + " " + where-phrase-38) <> ""
          then  substitute('
  bufs_ord-doc-rcv.obj-code = &3 and
  bufs_ord-doc-rcv.obj-type = &1&4&1
      and bufs_ord-doc-rcv.host-code = &5
      and ( &1&6&1 = &1?&1
      or  ( bufs_ord-doc-rcv.cons-code = &1&6&1 ))
      and ( &1&7&1 = &1?&1 or  ( bufs_ord-doc-rcv.doc-type = &1&7&1 ))
      and ( &1&8&1 = &1?&1 or  ( bufs_ord-doc-rcv.status_ = &1&8&1  )) '
          , chr(34)
          , list-mode
          , store-code
          , store-type
          , p-host-code
          , p-g#cons-code
          , p-g#type
          , p-g#stat ) +
        substitute(' and (&2 = no or ( bufs_ord-doc-rcv.ship-date >= &4 and bufs_ord-doc-rcv.ship-date <= &5 ))
                     and (&3 = no or ( bufs_ord-doc-rcv.cli-code = &6 and bufs_ord-doc-rcv.cli-type = &1&7&1 ))'
          , chr(34)
          , hard-flt-date
          , hard-flt-cli
          , string(sch-ship,'99/99/9999')
          , string(sch-ship-2,'99/99/9999')
          , r-cli-code
          , r-cli-type
           ) + " " + where-phrase-38
          else "true"
        )
      parameter-5-38 = (" " + "" + " " + ",        EACH buf_ord-doc WHERE bufs_ord-doc-rcv.doc-code = buf_ord-doc.doc-code OUTER-JOIN NO-LOCK")
      parameter-6-38 = if sort-phrase-38 = ''
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
        " " + sort-phrase-38
        )
      parameter-7-38 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-38 =
          (" bufs_ord-doc-rcv.obj-code = store-code   and bufs_ord-doc-rcv.obj-type = store-type   and bufs_ord-doc-rcv.host-code = p-host-code   and ( p-g#cons-code = ?                              or  ( bufs_ord-doc-rcv.cons-code = p-g#cons-code ))   and ( p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type ))   and ( p-g#stat = ? or  ( bufs_ord-doc-rcv.status_ = p-g#stat  ))   and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 ))   and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type))   " + " " + where-phrase-38 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-38
                          ,input parameter-4-38
                          ,input parameter-5-38
                          ,input parameter-6-38
                          ,input parameter-7-38
                          )
      .
      assign
        l-filter-open-38 = true
      .
    end.
    if l-filter-open-38 = false then do:
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
  if l-filter-open-38 = false then do:
    OPEN QUERY br-docs FOR EACH bufs_ord-doc-rcv NO-LOCK
      where  bufs_ord-doc-rcv.obj-code = store-code   and bufs_ord-doc-rcv.obj-type = store-type   and bufs_ord-doc-rcv.host-code = p-host-code   and ( p-g#cons-code = ?                              or  ( bufs_ord-doc-rcv.cons-code = p-g#cons-code ))   and ( p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type ))   and ( p-g#stat = ? or  ( bufs_ord-doc-rcv.status_ = p-g#stat  ))   and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 ))   and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type))
    ,        EACH buf_ord-doc WHERE bufs_ord-doc-rcv.doc-code = buf_ord-doc.doc-code OUTER-JOIN NO-LOCK
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
when 'cli':U  then do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-40  as logical   no-undo .
define variable  l-filter-open-40    as logical   .
define variable  flt-rec-40       as recid     no-undo .
define variable  filter-name-40      as character no-undo .
define variable  where-phrase-40     as character no-undo .
define variable  sort-phrase-40      as character no-undo .
define variable  where-phrase-rus-40 as character no-undo .
define variable  sort-phrase-rus-40  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-40
  ,output filter-name-40
  ,output where-phrase-40
  ,output sort-phrase-40
  ,output where-phrase-rus-40
  ,output sort-phrase-rus-40
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-40
      ) no-error .
  assign
    l-filter-open-40 = false
  .
  if flt-rec-40 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-40 as character no-undo .
    define variable  parameter-3-40 as character no-undo .
    define variable  parameter-4-40 as character no-undo .
    define variable  parameter-5-40 as character no-undo .
    define variable  parameter-6-40 as character no-undo .
    define variable  parameter-7-40 as character no-undo .
      assign
      parameter-3-40 =
                              "FOR EACH bufs_ord-doc-rcv"
      parameter-4-40 =
        (
          if (" bufs_ord-doc-rcv.cli-code = store-code   and bufs_ord-doc-rcv.cli-type = store-type         and bufs_ord-doc-rcv.host-code = p-host-code       and ( p-g#cons-code = ?                            or  ( bufs_ord-doc-rcv.cons-code = p-g#cons-code ))   and ( p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type ))   and ( p-g#stat = ? or  ( bufs_ord-doc-rcv.status_ = p-g#stat  ))   and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 ))   and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type))   " + " " + where-phrase-40) <> ""
          then  substitute('
    bufs_ord-doc-rcv.cli-code = &3 and
    bufs_ord-doc-rcv.cli-type = &1&4&1 and
    bufs_ord-doc-rcv.host-code = &5
      and ( &1&6&1 = &1?&1
      or  ( bufs_ord-doc-rcv.cons-code = &1&6&1 ))
      and ( &1&7&1 = &1?&1 or  ( bufs_ord-doc-rcv.doc-type = &1&7&1 ))
      and ( &1&8&1 = &1?&1 or  ( bufs_ord-doc-rcv.status_ = &1&8&1  )) '
          , chr(34)
          , list-mode
          , store-code
          , store-type
          , p-host-code
          , p-g#cons-code
          , p-g#type
          , p-g#stat )  +
         substitute(' and (&2 = no or ( bufs_ord-doc-rcv.ship-date >= &4 and bufs_ord-doc-rcv.ship-date <= &5 ))
                     and (&3 = no or ( bufs_ord-doc-rcv.cli-code = &6 and bufs_ord-doc-rcv.cli-type = &1&7&1 ))'
          , chr(34)
          , hard-flt-date
          , hard-flt-cli
          , string(sch-ship,'99/99/9999')
          , string(sch-ship-2,'99/99/9999')
          , r-cli-code
          , r-cli-type
           ) + " " + where-phrase-40
          else "true"
        )
      parameter-5-40 = (" " + "" + " " + ",        EACH buf_ord-doc WHERE bufs_ord-doc-rcv.doc-code = buf_ord-doc.doc-code OUTER-JOIN NO-LOCK")
      parameter-6-40 = if sort-phrase-40 = ''
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
        " " + sort-phrase-40
        )
      parameter-7-40 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-40 =
          (" bufs_ord-doc-rcv.cli-code = store-code   and bufs_ord-doc-rcv.cli-type = store-type         and bufs_ord-doc-rcv.host-code = p-host-code       and ( p-g#cons-code = ?                            or  ( bufs_ord-doc-rcv.cons-code = p-g#cons-code ))   and ( p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type ))   and ( p-g#stat = ? or  ( bufs_ord-doc-rcv.status_ = p-g#stat  ))   and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 ))   and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type))   " + " " + where-phrase-40 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-40
                          ,input parameter-4-40
                          ,input parameter-5-40
                          ,input parameter-6-40
                          ,input parameter-7-40
                          )
      .
      assign
        l-filter-open-40 = true
      .
    end.
    if l-filter-open-40 = false then do:
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
  if l-filter-open-40 = false then do:
    OPEN QUERY br-docs FOR EACH bufs_ord-doc-rcv NO-LOCK
      where  bufs_ord-doc-rcv.cli-code = store-code   and bufs_ord-doc-rcv.cli-type = store-type         and bufs_ord-doc-rcv.host-code = p-host-code       and ( p-g#cons-code = ?                            or  ( bufs_ord-doc-rcv.cons-code = p-g#cons-code ))   and ( p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type ))   and ( p-g#stat = ? or  ( bufs_ord-doc-rcv.status_ = p-g#stat  ))   and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 ))   and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type))
    ,        EACH buf_ord-doc WHERE bufs_ord-doc-rcv.doc-code = buf_ord-doc.doc-code OUTER-JOIN NO-LOCK
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
otherwise do:
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-42  as logical   no-undo .
define variable  l-filter-open-42    as logical   .
define variable  flt-rec-42       as recid     no-undo .
define variable  filter-name-42      as character no-undo .
define variable  where-phrase-42     as character no-undo .
define variable  sort-phrase-42      as character no-undo .
define variable  where-phrase-rus-42 as character no-undo .
define variable  sort-phrase-rus-42  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-42
  ,output filter-name-42
  ,output where-phrase-42
  ,output sort-phrase-42
  ,output where-phrase-rus-42
  ,output sort-phrase-rus-42
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-42
      ) no-error .
  assign
    l-filter-open-42 = false
  .
  if flt-rec-42 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-42 as character no-undo .
    define variable  parameter-3-42 as character no-undo .
    define variable  parameter-4-42 as character no-undo .
    define variable  parameter-5-42 as character no-undo .
    define variable  parameter-6-42 as character no-undo .
    define variable  parameter-7-42 as character no-undo .
      assign
      parameter-3-42 =
                              "FOR EACH bufs_ord-doc-rcv"
      parameter-4-42 =
        (
          if (" bufs_ord-doc-rcv.host-code = p-host-code       and ( p-g#cons-code = ?                            or  ( bufs_ord-doc-rcv.cons-code = p-g#cons-code ))   and ( p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type ))   and ( p-g#stat = ? or  ( bufs_ord-doc-rcv.status_ = p-g#stat  ))   and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 ))   and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type))   " + " " + where-phrase-42) <> ""
          then substitute('             bufs_ord-doc-rcv.host-code = &2       and ( &1&3&1 = &1?&1  or  ( bufs_ord-doc-rcv.cons-code = &1&3&1 ))       and ( &1&4&1 = &1?&1 or  ( bufs_ord-doc-rcv.doc-type = &1&4&1 ))       and ( &1&5&1 = &1?&1 or  ( bufs_ord-doc-rcv.status_  = &1&5&1  )) '              , chr(34)                                    , p-host-code                                           , p-g#cons-code                                         , p-g#type                                              , p-g#stat )            +                     substitute(' and (&2 = no or ( bufs_ord-doc-rcv.ship-date >= &4 and bufs_ord-doc-rcv.ship-date <= &5 ))                       and (&3 = no or ( bufs_ord-doc-rcv.cli-code = &6 and bufs_ord-doc-rcv.cli-type = &1&7&1 ))'            , chr(34)                                                                                             , hard-flt-date                                                                                                 , hard-flt-cli                                                                                                  , string(sch-ship,'99/99/9999')                                                                                 , string(sch-ship-2,'99/99/9999')                                                                               , r-cli-code                                                                                                    , r-cli-type                                                                                                    )  + " " + where-phrase-42
          else "true"
        )
      parameter-5-42 = (" " + "" + " " + ",        EACH buf_ord-doc WHERE bufs_ord-doc-rcv.doc-code = buf_ord-doc.doc-code OUTER-JOIN NO-LOCK")
      parameter-6-42 = if sort-phrase-42 = ''
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
        " " + sort-phrase-42
        )
      parameter-7-42 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-42 =
          (" bufs_ord-doc-rcv.host-code = p-host-code       and ( p-g#cons-code = ?                            or  ( bufs_ord-doc-rcv.cons-code = p-g#cons-code ))   and ( p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type ))   and ( p-g#stat = ? or  ( bufs_ord-doc-rcv.status_ = p-g#stat  ))   and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 ))   and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type))   " + " " + where-phrase-42 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-docs:handle
                          ,input parameter-3-42
                          ,input parameter-4-42
                          ,input parameter-5-42
                          ,input parameter-6-42
                          ,input parameter-7-42
                          )
      .
      assign
        l-filter-open-42 = true
      .
    end.
    if l-filter-open-42 = false then do:
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
  if l-filter-open-42 = false then do:
    OPEN QUERY br-docs FOR EACH bufs_ord-doc-rcv NO-LOCK
      where  bufs_ord-doc-rcv.host-code = p-host-code       and ( p-g#cons-code = ?                            or  ( bufs_ord-doc-rcv.cons-code = p-g#cons-code ))   and ( p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type ))   and ( p-g#stat = ? or  ( bufs_ord-doc-rcv.status_ = p-g#stat  ))   and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 ))   and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type))
    ,        EACH buf_ord-doc WHERE bufs_ord-doc-rcv.doc-code = buf_ord-doc.doc-code OUTER-JOIN NO-LOCK
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
end case.
end.
filter-point =  "Поставки " .
run waitfram-hide.
apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE print-list :
define variable v-kol   as integer   no-undo .
define variable v-i-sum as decimal   no-undo .
define variable v-d as decimal   no-undo .
v-kol   = 0 .
v-i-sum = 0 .
v-d = 0 .
define variable sym1  as char format "X(1)" init ":".
define variable sym2  as char format "X(1)" init ":".
define variable sym3  as char format "X(1)" init ":".
define variable sym4  as char format "X(1)" init ":".
define variable sym5  as char format "X(1)" init ":".
define variable sym6  as char format "X(1)" init ":".
define variable sym7  as char format "X(1)" init ":".
define variable sym8  as char format "X(1)" init ":".
define variable sym9  as char format "X(1)" init ":".
define variable sym10 as char format "X(1)" init ":".
define variable sym11 as char format "X(1)" init ":".
define variable sym12 as char format "X(1)" init ":".
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable vv-val as character no-undo .
define variable v-i as integer   no-undo .
define variable p-delta as decimal format "->,>>>,>>>,>>>,>>9.99"  no-undo .
DEFINE FRAME prt-frame
bufs_ord-doc-rcv.doc-type  COLUMN-LABEL "Тип" FORMAT "x(5)"
bufs_ord-doc-rcv.status_   COLUMN-LABEL "Статус"
bufs_ord-doc-rcv.rcv-code  COLUMN-LABEL "Номер"
prt-out-cli-code COLUMN-LABEL "№по пост-ку" FORMAT "x(14)"
bufs_ord-doc-rcv.doc-date FORMAT "99/99/99"
bufs_ord-doc-rcv.fact-date FORMAT "99/99/99"
prt-cli-name   COLUMN-LABEL "Поставщик" FORMAT "x(15)"
prt-sum-rubl  COLUMN-LABEL "Сумма поставки" FORMAT ">>>>>>>>>>>>9.99"
bufs_ord-doc-rcv.ship-date COLUMN-LABEL "Доставка" FORMAT "99/99/99"
bufs_ord-doc-rcv.ship-time COLUMN-LABEL "Время"
bufs_ord-doc-rcv.fact-ship-time COLUMN-LABEL "Факт"
bufs_ord-doc-rcv.obj-type
bufs_ord-doc-rcv.obj-code COLUMN-LABEL "Объект"
bufs_ord-doc-rcv.cli-type
bufs_ord-doc-rcv.cli-code COLUMN-LABEL "Контрагент"
bufs_ord-doc-rcv.doc-code COLUMN-LABEL "Заказ"
v-fo column-label "ФО" format "x(11)"
        HEADER  date_string AT 5 format "X(35)"
                    string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
                    Line format "X(157)" AT 1
    with width 232 down stream-io use-text    .
    Line = fill("-", 157).
    date_string = cur-time-print() .
    run prn-lib-open-stream in this-procedure
    (  input parParentProc
      ,input 43
      ,input yes
      ,input no
      ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame Dialog-Frame:title )
    format "x(157)" SKIP(1) .
    FORM HEADER
            Line format "X(177)" AT 1 SKIP
            "Продолжение - на следующей странице" AT 30 SKIP
            with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .
    FORM with FRAME prt-frame  .
    run waitfram-show in this-procedure ("Ждите печатаю...").
    run OpenBR in this-procedure .
     DO WHILE available bufs_ord-doc-rcv :
       v-kol    = v-kol   + 1 .
        Display STREAM PrnLibStream
            if bufs_ord-doc-rcv.doc-type = 'out' then 'внешн' else 'внутр'  @ bufs_ord-doc-rcv.doc-type
            bufs_ord-doc-rcv.status_
            bufs_ord-doc-rcv.rcv-code
            cli-doc-out (buffer bufs_ord-doc-rcv) @ prt-out-cli-code
            bufs_ord-doc-rcv.doc-date
            bufs_ord-doc-rcv.fact-date
            cli-name (buffer bufs_ord-doc-rcv) @ prt-cli-name
            sum-rubl (buffer bufs_ord-doc-rcv) @ prt-sum-rubl
            bufs_ord-doc-rcv.ship-date
            bufs_ord-doc-rcv.obj-type
            bufs_ord-doc-rcv.obj-code
            bufs_ord-doc-rcv.cli-type
            bufs_ord-doc-rcv.cli-code
            f-fo ( buffer bufs_ord-doc-rcv ) @ v-fo
            string(bufs_ord-doc-rcv.ship-time,'hh:mm') @ bufs_ord-doc-rcv.ship-time
            string(bufs_ord-doc-rcv.fact-ship-time,'hh:mm')  @ bufs_ord-doc-rcv.fact-ship-time
            bufs_ord-doc-rcv.doc-code
            with FRAME prt-frame .
         DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
         GET next br-docs.
      END.
      underline  stream PrnLibStream
        bufs_ord-doc-rcv.doc-type
        bufs_ord-doc-rcv.status_
        bufs_ord-doc-rcv.rcv-code
      with FRAME prt-frame .
    if v-kol > 1 then do:
      Display STREAM PrnLibStream
      "Итого"    @    bufs_ord-doc-rcv.doc-type
      "док.шт."  @    bufs_ord-doc-rcv.status_
        v-kol    @    bufs_ord-doc-rcv.rcv-code
      with FRAME prt-frame .
    end.
     DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
        input parParentProc
       ,input 8
        ).
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'ord-doc-rcv'
  join-tbl = 'bufs_ord-doc-rcv'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('rcv-code', 'Номер поставки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-code', 'Номер заказа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cons-code', 'Номер СЗФП', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', 'Дата документа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', 'Дата закрытия документа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('ship-date', 'Дата доставки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('obj-type*obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure ('cli-type*cli-code', 'Поставщик', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-ship-time', 'Фактическое время доставки', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', 'Статус', 'order-status-all',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-type', 'Тип', 'rcv-type-all',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('PS', 'Комментарий', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('creid', 'Опер-р', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name', 'Правил', 'usr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('exch-code', 'Валюта','curr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  Filter-Block:
  DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
     ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
     ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
    run gbl/filter.w ( INPUT parParentProc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
    RUN OpenBr.
  END.
END PROCEDURE.
PROCEDURE proc-m_gen-1 :
do
  on error undo, return error return-value
  :
    if num-entries(del-list) = 0 then do:
      message "Не выделено ни одной поставки для генерации ФО !".
      return error .
    end.
    run str/gen-fl.w (
        input parparentproc,
        input p-host-code,
        input del-list,
        input "rcv"
        ) .
    assign del-list = "" .
    RUN OpenBr.
  end.
end procedure.
PROCEDURE proc-m_gen-2 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define buffer bf_ord-doc-rcv for ub.ord-doc-rcv.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
do on error undo, return error return-value
:
    if del-list = "" then do:
      if available bufs_ord-doc-rcv then assign del-list = string(recid(bufs_ord-doc-rcv)).
    end.
define variable v-num-entries-del-list as integer no-undo .
v-num-entries-del-list = num-entries (del-list) .
v-i-cycle:
  do v-i = 1 to v-num-entries-del-list :
    assign v-doc-code = integer(entry (v-i, del-list)).
    find first bf_ord-doc-rcv where recid(bf_ord-doc-rcv) = v-doc-code exclusive-lock.
    find first bf_ord-doc where bf_ord-doc.doc-code = bf_ord-doc-rcv.doc-code no-lock .
    if bf_ord-doc-rcv.status_ <> 'факт':U then do:
      message "Документ " bf_ord-doc-rcv.status_ " не в статусе " 'факт':U " . Пропускаем." view-as alert-box.
      next v-i-cycle.
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
      message "Главная БД для фирмы по документу с кодом " bf_ord-doc-rcv.rcv-code " не является текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "Главная БД фирмы: " bf_sysconf.firm-db-num
      view-as alert-box error.
      next v-i-cycle.
    end.
    if bf_ord-doc-rcv.cr-fo = yes then do:
      message "По документу " bf_ord-doc-rcv.rcv-code " уже создавался ФО от " bf_ord-doc-rcv.fo-date " числа." view-as alert-box.
      next v-i-cycle.
    end.
    else do:
      if bf_ord-doc-rcv.need-fo = 1 or bf_ord-doc-rcv.need-fo = 2 then assign  bf_ord-doc-rcv.need-fo = 0.
      else do:
        message "Данный документ не нуждался в генерации ФО." view-as alert-box.
        next v-i-cycle.
      end.
      reposition br-docs to recid recid(bf_ord-doc-rcv) no-error.
      if not error-status:error then do:
        apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
        display f-fo (buffer bf_ord-doc-rcv) @ v-fo with browse br-docs.
      end.
    end.
  end.
  assign del-list = "".
end.
end procedure.
PROCEDURE proc-m_gen-3 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define buffer bf_ord-doc-rcv for ub.ord-doc-rcv.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
define variable v-log as logical   no-undo .
do on error undo, return error return-value
:
  if del-list = "" then do:
    if available bufs_ord-doc-rcv then assign del-list = string(recid(bufs_ord-doc-rcv)).
  end.
define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list) .
v-i-cycle:
  do v-i = 1 to v-nn :
    assign v-doc-code = integer(entry (v-i, del-list)).
    find first bf_ord-doc-rcv where recid(bf_ord-doc-rcv) = v-doc-code exclusive-lock.
    find first bf_ord-doc where bf_ord-doc.doc-code = bf_ord-doc-rcv.doc-code no-lock.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.status_ <> 'факт':U then do:
      message "Документ " bf_ord-doc-rcv.status_ " не в статусе " 'факт':U " . Пропускаем." view-as alert-box.
      next v-i-cycle.
    end.
    if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
      message "Главная БД для фирмы по документу с кодом " bf_ord-doc-rcv.rcv-code " не является текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip   "Главная БД фирмы: " bf_sysconf.firm-db-num
      view-as alert-box error.
      next v-i-cycle.
    end.
    if bf_ord-doc-rcv.cr-fo = yes then do:
      assign
        v-log = no.
        message "По документу " bf_ord-doc-rcv.rcv-code " был создан ФО от " bf_ord-doc-rcv.fo-date " ." skip
                "Вы действительно хотите снять признак, чтобы по этому документу был ФО?"
        view-as alert-box question buttons yes-no update v-log.
       if v-log <> yes then  next v-i-cycle.
       assign
         bf_ord-doc-rcv.cr-fo   = no
         bf_ord-doc-rcv.fo-date = 01/01/1990
       .
       reposition br-docs to recid recid(bf_ord-doc-rcv) no-error.
      if not error-status:error then do:
        apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
        display f-fo (buffer bf_ord-doc-rcv) @ v-fo with browse br-docs.
      end.
    end.
    else do:
      message "По документу " bf_ord-doc-rcv.rcv-code " не было генерации."
      view-as alert-box.
   end.
 end.
 assign del-list = "".
end.
end procedure.
PROCEDURE proc-m_gen-4 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer bf_ord-doc for ub.ord-doc.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
define variable v-need-fo as logical no-undo.
define buffer bf_contract for ub.contract.
do on error undo, return error return-value
:
  if del-list = "" then do:
    if available bufs_ord-doc-rcv then assign del-list = string(recid(bufs_ord-doc-rcv)).
  end.
define variable  v-nn as integer   no-undo .
v-nn = num-entries (del-list) .
v-i-cycle:
  do v-i = 1 to v-nn:
    assign v-doc-code = integer(entry (v-i, del-list)) .
    find first bf_ord-doc-rcv where recid(bf_ord-doc-rcv) = v-doc-code exclusive-lock.
    find first bf_ord-doc where bf_ord-doc.doc-code = bf_ord-doc-rcv.doc-code no-lock .
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.status_ <> 'факт':U then do:
      message "Документ " bf_ord-doc.status_ " не в статусе " 'факт':U " . Пропускаем."  view-as alert-box.
      next.
    end.
    if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
      message "Главная БД для фирмы по документу с кодом " bf_ord-doc.doc-code " не является текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "Главная БД фирмы: " bf_sysconf.firm-db-num
      view-as alert-box error.
      return error.
    end.
    if bf_ord-doc-rcv.need-FO = 2 then do:
      if bf_ord-doc-rcv.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_ord-doc.host-code   and
                                     bf_contract.contract-code = bf_ord-doc.contract-code no-lock no-error.
        if available bf_contract then do:
          if  true  then do:
            assign bf_ord-doc-rcv.need-FO = 1  .
            reposition br-docs to recid recid(bf_ord-doc-rcv) no-error.
            if not error-status:error then do:
              apply "VALUE-CHANGED" to br-docs in frame Dialog-Frame.
              display f-FO (buffer bf_ord-doc-rcv) @ v-FO with browse br-docs.
            end.
          end.
          else message "По документу " bf_ord-doc-rcv.rcv-code " нет договоров для генерации ФО."  view-as alert-box.
        end.
      end.
    end.
    else do:
      message "Документ " bf_ord-doc-rcv.rcv-code "не имеет признака 'не опред' генерация ФО."
      view-as alert-box.
      next v-i-cycle.
    end.
  end.
  assign del-list = "" .
end.
end procedure.
procedure proc-m_lkp-fo :
  do
  on error undo, return error return-value
  :
  if available bufs_ord-doc-rcv then do:
    run str/fi-trns.w (
        input parparentproc,
        input bufs_ord-doc-rcv.host-code,
        input ?              ,
        input bufs_ord-doc-rcv.rcv-code ,
        input "rcv":U
        ) .
    end.
  end.
end procedure.
PROCEDURE local-mark:
  if not available bufs_ord-doc-rcv then do:
    message "Неправильный выбор строки.".
    return error.
  end.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid44 as character no-undo .
define variable v-num-entry44 as integer   no-undo .
assign
  v-str-recid44 = trim( string( recid( bufs_ord-doc-rcv ) , "->>>>>>>>>>>9":U ) )
  v-num-entry44 = lookup( v-str-recid44 , del-list )
.
if v-num-entry44 > 0 then do:
  assign
    entry( v-num-entry44, del-list ) = "":U
    del-list = trim( replace( del-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    del-list = del-list + ( if del-list = "":U then "":U else chr(44) ) + v-str-recid44
  .
end.
  if lookup(string( recid(bufs_ord-doc-rcv) ), del-list ) > 0
      then disp "*"  @ mark with browse  br-docs.
      else disp "" @ mark with browse  br-docs.
END PROCEDURE.
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title = sss + "   ФИЛЬТР: " + p-filter-name
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
        frame Dialog-Frame:title = sss
      .
    end.
  end.
END PROCEDURE.
PROCEDURE set-selection :
assign frame Dialog-Frame
sch-ship sch-ship-2  r-cli-type r-cli-code
.
hard-flt-date = false  .
hard-flt-cli  = false  .
if not( sch-ship = ? and sch-ship-2 = ? ) then do:
    if sch-ship = ? then sch-ship = 01/01/1900 .
    if sch-ship-2 = ? then sch-ship-2 = 01/01/2100 .
    if sch-ship > sch-ship-2 then do:
      message 'Не верно задан интервал дат для поиска поставок' view-as alert-box information .
      return error .
    end.
    hard-flt-date = true  .
end.
if r-cli-code <> 0 and r-cli-code <> ? then do:
define buffer buf_clients for ub.clients  .
find first buf_clients no-lock where
           buf_clients.obj-type = r-cli-type and
           buf_clients.obj-code = r-cli-code no-error .
  if not available buf_clients then do:
      message 'Не верно задан Поставщик для поиска поставок' view-as alert-box information .
      return error .
  end.
  hard-flt-cli  = true .
end.
END PROCEDURE.
FUNCTION f-fo RETURNS CHARACTER
  ( buffer loc-t-doc for ub.ord-doc-rcv ) :
 if loc-t-doc.cr-fo = yes then do:
   return string (loc-t-doc.fo-date, "99/99/99").
 end.
 else do:
   if loc-t-doc.need-fo = 0 then do:
     return "--------".
   end.
   if loc-t-doc.need-fo = 1 then do:
     return "".
   end.
   if loc-t-doc.need-fo = 2 then do:
     return "не опред".
   end.
 end.
END FUNCTION.
FUNCTION status-edi-trn RETURNS CHARACTER
  ( buffer loc-t-doc for buf_trn-doc ) :
define variable v-status as character no-undo .
define variable p-type     as character no-undo .
     if available loc-t-doc then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input loc-t-doc.doc-code ,
                        input 'edi':U ,
                       output v-status ,
                       output p-type ) no-error .
      if v-status = "" or v-status = "0"  or v-status = ?  then return "" .
      else
         return  entry (lookup (v-status, '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка')   .
    end.
  RETURN "".
END FUNCTION.
