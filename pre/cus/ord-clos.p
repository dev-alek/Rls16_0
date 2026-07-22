block-level on error undo, throw.
define input parameter  parParentProc  as widget-handle no-undo.
define input parameter  p-rec          as recid no-undo .
define input parameter  store-type     as character no-undo .
define input parameter  store-code     as integer   no-undo .
define input parameter  p-db-num       as integer   no-undo .
define input parameter  p-ask          as logical   no-undo .
define input parameter  p-param-list   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: e470dcf1e011, 295, rls $":u .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":u .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:38 2015 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: ord-clos.p $":u .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-clos.p $":u .
define variable vss-description as character no-undo init  "Переход по графу статусов" .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
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
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
procedure ver-qnty-rcv-from-ord :
define input  parameter p-ord-doc as character no-undo .
define output parameter p-is-lim as logical    no-undo .
define buffer buf_ord-doc     for ub.ord-doc      .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define variable v-kol as integer   no-undo .
define variable v-ver as logical   no-undo .
  do
  on error undo, return error return-value
  :
   p-is-lim = false .
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = p-ord-doc no-error .
  if buf_ord-doc.doc-type <> 'ОП':U then return .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_ord-doc.obj-type
  ,input buf_ord-doc.obj-code
  ,input 'ord-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'ord-11':U then v-ver = thbjattr_thbj-attr.property-value-logical .
  end.
v-kol = 0.
  if v-ver then do:
     for each buf_ord-doc-rcv no-lock where
              buf_ord-doc-rcv.doc-code = p-ord-doc :
       v-kol = v-kol + 1.
       leave.
     end.
   if v-kol > 0 then p-is-lim = true .
  end.
end.
end procedure.
procedure ver-qnty-trn-from-rcv :
define input  parameter p-rcv-code as character no-undo .
define output parameter p-is-lim as logical   no-undo .
define buffer buf_ord-doc for ub.ord-doc  .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_ord-chain for ub.ord-chain .
define buffer buf_trn-doc for ub.trn-doc  .
define variable v-kol as integer   no-undo .
define variable v-ver as logical   no-undo .
  do
  on error undo, return error return-value
  :
   p-is-lim = false .
  find first buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.rcv-code = p-rcv-code no-error .
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code no-error .
  if buf_ord-doc.doc-type <> 'ОП':U then return .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_ord-doc.obj-type
  ,input buf_ord-doc.obj-code
  ,input 'ord-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'ord-11':U then v-ver = thbjattr_thbj-attr.property-value-logical .
  end.
    if v-ver then do:
    v-kol = 0.
        for each buf_ord-chain no-lock where
                buf_ord-chain.doc-code = p-rcv-code and
                buf_ord-chain.doc-type = 'rcv' and
                buf_ord-chain.rel-doc-type = 'trn' ,
            first buf_trn-doc NO-LOCK where
                  buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
                  :
            v-kol = v-kol + 1.
            leave.
        end.
        if v-kol > 0 then p-is-lim = true .
    end.
  end.
end procedure.
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ver-clients-calc :
define input  parameter p-cli-type as character no-undo .
define input  parameter p-cli-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-method   as character no-undo .
define output parameter p-error    as logical   no-undo .
define variable v-not-corr-op as character no-undo .
define variable v-type as character no-undo .
  do
  on error undo, return error return-value
  :
 p-error = false .
 v-not-corr-op  = 'no' .
 run clntattr-value (
    input   p-obj-type
  , input   p-obj-code
  , input   'not-corr-op':U
  , output  v-not-corr-op
  , output  v-type
  ) no-error .
  if error-status :error then v-not-corr-op  = 'no' .
  if v-not-corr-op = 'yes' and  p-method = ""  then do:
    assign v-not-corr-op = 'no' .
    run clntattr-value (
    input   p-cli-type
  , input   p-cli-code
  , input   'not-corr-op':U
  , output  v-not-corr-op
  , output  v-type
  ) no-error .
  if error-status :error then v-not-corr-op  = 'no' .
  if v-not-corr-op = 'yes'  and  p-method = ""  then p-error = true .
  end.
  end.
end procedure.
procedure ver-ord-line :
define input parameter  p-doc-code like ub.ord-doc.doc-code no-undo .
define output parameter p-error    as logical               no-undo .
define variable v-longchar          as longchar  no-undo .
define variable v-err-ext           as logical   no-undo .
define variable var-ok-assort-pol   as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-event-code        as character no-undo .
define variable v-ok                as logical   no-undo .
define variable v-nabor             as logical   no-undo .
define buffer buf_ord-line for ub.ord-line.
define buffer buf_ord-doc  for ub.ord-doc.
v-err-ext  = false .
find first buf_ord-doc no-lock
  where buf_ord-doc.doc-code = p-doc-code no-error.
  if not available buf_ord-doc then do:
  end.
  else do:
for each buf_ord-line of buf_ord-doc
  break by buf_ord-line.cli-art :
    if buf_ord-doc.doc-type <> 'ПО':U  and
       buf_ord-doc.doc-type <> 'ФП':U  then do:
       var-ok-assort-pol = true .
       v-event-code = buf_ord-doc.doc-type + "-" .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_ord-line.gds-code
  ,input  buf_ord-doc.obj-type
  ,input  buf_ord-doc.obj-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
           if var-ok-assort-pol = false then do:
              v-err-ext  = true  .
              v-longchar = v-longchar + var-mess-assort-pol + chr(10) .
           end.
    end.
    if  buf_ord-doc.cli-type = 'маг':U or
           buf_ord-doc.cli-type = 'скл':U then do:
            var-ok-assort-pol = true .
            v-event-code = "cli_" + buf_ord-doc.doc-type + "-" .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_ord-line.gds-code
  ,input  buf_ord-doc.cli-type
  ,input  buf_ord-doc.cli-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
           if var-ok-assort-pol = false then do:
              v-err-ext  = true  .
              v-longchar = v-longchar + var-mess-assort-pol  + chr(10) .
           end.
       end.
    if buf_ord-doc.doc-type = 'ПО':U  then do:
        var-ok-assort-pol = true .
        v-event-code = buf_ord-doc.doc-type + "-" .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassmat in g#library2
  (input  buf_ord-line.gds-code
  ,input  buf_ord-doc.obj-type
  ,input  buf_ord-doc.obj-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  )  .
        if var-ok-assort-pol = false then do:
          v-err-ext  = true  .
          v-longchar = v-longchar + var-mess-assort-pol  + chr(10) .
        end.
    end.
  end.
  if v-err-ext = true  then do:
      run gbl/d-longchar.w (
              ?,
              'Editor_row=2\':u
            + 'title=Проверка строк заказа\':u
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
          v-longchar = '':U.
      define variable vq as logical   no-undo init true .
      return error .
    end.
  end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info18 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info18, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info18, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info18, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info18, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info18 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info18, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info18 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info18, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info18, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info18, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info18, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info18, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info18, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info18 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info18 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info18, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info18, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info18, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info18 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info18 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info18, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info18, v-inform, v-tbl-name ).
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table temp-err no-undo  LIKE ub.rep-line
  field str as character
  field gds-code as integer
index pi is primary unique  gds-code
.
procedure view-exept-gds :
define input  parameter p-str as character no-undo .
define variable loc-ok as logical   no-undo .
  do
  on error undo, return error return-value
  :
  message p-str
           view-as alert-box question
           buttons yes-no
           update loc-ok
            .
if loc-ok then
    run gbl/tt-view.w
    ( input table  temp-err ).
  end.
end procedure.
procedure creat-tt :
  do
  on error undo, return error return-value
  :
    define input  parameter p-gds-code as integer   no-undo .
    define input  parameter p-str as character no-undo .
    find first temp-err where
               temp-err.gds-code = p-gds-code no-error .
               if available temp-err then return .
    if p-str  <> "" then do:
       create temp-err.
       assign
         temp-err.gds-code = p-gds-code
         temp-err.str = p-str
     .
    end.
  end.
end procedure.
define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable v-log      as logical   no-undo .
define variable g#log as logical   no-undo .
define variable v-file-name as character no-undo .
define variable v-Ok as logical   no-undo .
define variable v-mess as character no-undo .
define variable v-is-limit as logical   no-undo .
define variable vv-unit-cli           like ub.ext-artic.unit-cli           no-undo .
define variable vv-cli-base-rate      like ub.ext-artic.cli-base-rate      no-undo .
define variable vv-unit-cli-ord       like ub.ext-artic.unit-cli-ord       no-undo .
define variable vv-cli-base-rate-ord  like ub.ext-artic.cli-base-rate-ord  no-undo .
define variable vv-unit-cli-rcv       like ub.ext-artic.unit-cli-rcv       no-undo .
define variable vv-cli-base-rate-rcv  like ub.ext-artic.cli-base-rate-rcv  no-undo .
define variable v-dm-edi    as integer   no-undo .
define variable v-longchar as longchar no-undo .
define variable doc-db-num as integer   no-undo .
define buffer bf2_goods for ub.goods  .
define buffer bf3_goods for ub.goods  .
define buffer bf_contract-specif for ub.contract-specif.
define buffer bf2_ext-artic for ub.ext-artic  .
run gbl/_tmpfile.p ("ord", ".txt", output v-file-name) .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
if g#esys then do:
  run get-db-num in parparentproc ( output v-cntxt-db-num).
  run get-userid in parparentproc ( output v-cntxt-userid).
end.
else do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
end.
define variable v-obj-active  as character no-undo .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  store-type
  ,input  store-code
  ,input  'active=request':u
  ,output v-obj-active
  )  .
define variable v-not-activ  as logical   no-undo .
if v-obj-active <> "yes" and p-db-num <> 0  then v-not-activ = true .
else v-not-activ = false .
define  buffer shar-buf_ord-doc    for ub.ord-doc.
define  buffer t-doc-rcv      for ub.ord-doc-rcv .
define  buffer t-ord-doc-rcv  for ub.ord-doc-rcv.
define  buffer t-doc-line     for ub.ord-line.
define  buffer t-doc-line-rcv for ub.ord-line-rcv.
define  buffer t-trn-line     for ub.doc-line.
define  buffer t-trn-doc      for ub.trn-doc.
define  buffer buf_ext-artic  for ub.ext-artic.
define temp-table temp-obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi obj-type obj-code
.
define variable  sum-ord like ub.ord-line.qnty no-undo .
define variable  sum-rcv like ub.ord-line.qnty no-undo .
define variable  sum-trn like ub.ord-line.qnty no-undo .
define variable  sum-trn1 like ub.ord-line.qnty no-undo .
define variable old-state like ub.ord-doc.status_ no-undo .
define variable old-flag like ub.ord-doc.flag_ no-undo .
define stream  errStream  .
define variable ord-op           as logical   no-undo .
define variable p-type           as character no-undo .
define variable c-ord-ofof       as logical   no-undo .
define variable v-tt-qnty        as logical   no-undo .
define variable ord-rcv1         as decimal   no-undo .
define variable v-ne             as logical   no-undo .
define variable g-log            as logical   no-undo .
define variable v-is-edi         as logical   no-undo .
define variable v-is-edoc-nn     as logical   no-undo .
define variable par-is-edi       as character no-undo .
define variable v-is-edi-doc     as logical   no-undo .
define variable v-is-edoc-nn-doc as logical   no-undo .
define variable v-erase          as logical   no-undo .
define buffer buf_1_ord-line for ub.ord-line  .
define buffer buf_1_ord-line-rcv for ub.ord-line-rcv .
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input 'ord-global':U
  ,input 'ord-op':U
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output ord-op
  ,output p-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input 'ord-global':U
  ,input 'ord-ofof':U
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output c-ord-ofof
  ,output p-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  store-type
  ,input  store-code
  ,output to-day
  )  .
 find first shar-buf_ord-doc where recid (shar-buf_ord-doc) = p-rec exclusive-lock no-error.
 assign
  old-state = shar-buf_ord-doc.status_
  old-flag  = shar-buf_ord-doc.flag_
  .
  for each ub.ord-line no-lock where
           ub.ord-line.doc-code = shar-buf_ord-doc.doc-code :
      if (round(ub.ord-line.cli-qnty * ub.ord-line.cli-base-rate, 3) <> ub.ord-line.qnty) then do:
         return error substitute (
            " Документ &1, По товару неправильное соотношение количеств в единицах поставщика &2 &8 (коэфф.&3)  и в базовых единицах измерения &4 ! Товар &5 &6&7",
            shar-buf_ord-doc.doc-code ,
            ub.ord-line.cli-qnty ,
            ub.ord-line.cli-base-rate ,
            ub.ord-line.qnty  ,
            ub.ord-line.artic ,
            ub.ord-line.prod-type ,
            ub.ord-line.prod-code ,
            ub.ord-line.unit-cli ) .
      end.
  end.
  if shar-buf_ord-doc.doc-type = 'ОО':U  then do:
    run cus/ordoocls.p
      (input parParentProc ,
       input p-rec ,
       input p-ask )
      no-error .
    return .
  end.
  if shar-buf_ord-doc.doc-type = 'ОР':U  then do:
    run cus/ordorcls.p ( parParentProc ,input p-rec, input p-ask ) no-error .
    if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "Ошибка при закрытии заказа"
         view-as alert-box error
       .
    end.
    return .
  end.
  if shar-buf_ord-doc.ship-date = ? then do:
     return error substitute(" Документ &1 , Не задана дата заказа !", shar-buf_ord-doc.doc-code) .
  end.
  define variable t-date  as date      no-undo .
  define variable t-time  as integer   no-undo .
  run cur-time (output  t-date , output  t-time ).
  if shar-buf_ord-doc.date-sale-1 = ? then do:
      return error substitute( " Документ &1 , Не задан интервал продаж ! Нет даты начала !", shar-buf_ord-doc.doc-code) .
  end.
  if shar-buf_ord-doc.date-sale-2 = ? then do:
      return error substitute( " Документ &1 , Не задан интервал продаж ! Нет даты конца !", shar-buf_ord-doc.doc-code) .
  end.
  if can-find
    ( first   t-doc-line no-lock where t-doc-line.doc-code  = shar-buf_ord-doc.doc-code    and
            ( t-doc-line.qnty  =  0 or t-doc-line.qnty  = ?)) then do:
      return error substitute( " Документ &1 , В заказе есть строки с количеством равным 0 или ? !", shar-buf_ord-doc.doc-code) .
  end.
  if shar-buf_ord-doc.doc-type = 'ФП':U  and  v-not-activ  then do:
      return error substitute( " Документ &1 , Закрыть заказ ФП можно только на активном объекте !", shar-buf_ord-doc.doc-code) .
  end.
  if p-param-list <> "yes" and shar-buf_ord-doc.doc-type <> 'ФП':U then do:
  if shar-buf_ord-doc.status_ =  'новый':U or
     shar-buf_ord-doc.status_ = 'согласование':U then do:
  for each ub.ord-line no-lock where
           ub.ord-line.doc-code = shar-buf_ord-doc.doc-code :
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  shar-buf_ord-doc.doc-type
  ,input  ub.ord-line.gds-code
  ,input  shar-buf_ord-doc.obj-type
  ,input  shar-buf_ord-doc.obj-code
  ,input  false
  ,output v-Ok
  ,output v-mess
  ) no-error.
        if v-Ok = false then do:
            run creat-tt (ub.ord-line.gds-code , v-mess ) .
            v-erase = true.
        end.
  end.
  if v-erase then do:
      run view-exept-gds ( substitute("В заказе есть некорректные линии !&1Просмотреть список ?", chr(10))) .
            return.
  end.
 end.
end.
define buffer buf_contract for ub.contract.
define variable v-mastc           as logical   no-undo init false .
define variable varcontract       as character no-undo.
define variable varcontract-type  as character no-undo .
define variable v-ext-mode as character no-undo .
    run adm/shattri.p (
      input "get":U
      ,input shar-buf_ord-doc.obj-type
      ,input shar-buf_ord-doc.obj-code
      ,input 'contr-in':U
      ,input  "contr-in-income"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-mastc
      ,output varcontract-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .
  if (  shar-buf_ord-doc.doc-type = 'ФП':U  or
        shar-buf_ord-doc.doc-type = 'ОП':U )
      and
      ( shar-buf_ord-doc.contract-code = 0 or
        shar-buf_ord-doc.contract-code = ? )
      and
        shar-buf_ord-doc.order-type <> 4
      and
       v-mastc = true
  then do:
      return error "На фирме " + string(shar-buf_ord-doc.host-code) + " задание договора по заказу ОП и ФП обязательны ! " .
  end.
  if shar-buf_ord-doc.doc-type = 'ФП':U and shar-buf_ord-doc.contract-code > 0 and shar-buf_ord-doc.status_ =  'новый':U then do:
     find first bf_contract-specif where bf_contract-specif.host-code    = shar-buf_ord-doc.host-code     and
                                          bf_contract-specif.contract-num = shar-buf_ord-doc.contract-code no-lock no-error.
      if available bf_contract-specif then do:
         v-ok = true.
         for each ub.ord-line no-lock where
                  ub.ord-line.doc-code = shar-buf_ord-doc.doc-code :
            if not can-find (first bf_contract-specif no-lock where
                                   bf_contract-specif.host-code    = shar-buf_ord-doc.host-code and
                                   bf_contract-specif.contract-num = shar-buf_ord-doc.contract-code and
                                   bf_contract-specif.gds-code     = ub.ord-line.gds-code   ) then do:
                                      message
                                        "Выбран Договор со спецификацией !!!" skip
                                        "Несоответствие списка товаров заказа и спецификации " skip
                                        "Заказ      :" shar-buf_ord-doc.doc-code        skip
                                        "код товара :" ub.ord-line.gds-code skip
                                        "артикл     :" ub.ord-line.artic skip
                                        view-as alert-box error .
                                      v-ok = false.
                                   end.
         end.
          if not v-ok
              then return error substitute ("Документ &1, не может быть закрыт, т.к. есть товары несоответствующие спецификации", shar-buf_ord-doc.doc-code).
       end.
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-edi'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-edi
  ,output par-type
  ) no-error .
  if error-status :error then v-is-edi = false .
  assign
    v-is-edi = lookup(par-is-edi, "true,yes":U) > 0
  .
 case shar-buf_ord-doc.status_ :
      when 'отказ':U then do :
        return error substitute( " Документ &1  Тип &2 , Нельзя закрыть в статусе &3  ", shar-buf_ord-doc.doc-code ,  shar-buf_ord-doc.doc-type , shar-buf_ord-doc.status_ ) .
      end.
      when 'новый':U then do :
           if shar-buf_ord-doc.ship-date <= t-date then do:
              if p-ask then  do:
            message
            substitute(" Документ &1 , Дата заказа &2 меньше или равна текущей даты &3 ! ",
                              shar-buf_ord-doc.doc-code ,
                              string(shar-buf_ord-doc.ship-date, "99/99/9999" ) ,
                              string(t-date, "99/99/9999" ))
                  " Будем закрывать ? "
                    view-as alert-box question
                    buttons yes-no
                    title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " заявку " else " заказ " )
                    update g#log
                  .
              end.
              else g#log = false  .
          if not g#log
          and shar-buf_ord-doc.whole-send-news <> integer('2':U) THEN DO:
            return error substitute( " Документ &1 , Дата заказа меньше или равна текущей дате !  ", shar-buf_ord-doc.doc-code  ) +
                            string(shar-buf_ord-doc.ship-date, "99/99/9999" ) + " " +
                            string(t-date, "99/99/9999" )
                            .
          END.
        end.
          if shar-buf_ord-doc.doc-type = 'ОФ':U  and v-not-activ then do:
              if not (c-ord-ofof = true and p-db-num = 0 ) then do:
                  return error substitute( " Документ &1 , Закрыть заявку можно только на активном объекте ", shar-buf_ord-doc.doc-code  ) .
              end.
          end.
        if not can-find (first  t-doc-line where t-doc-line.doc-code  = shar-buf_ord-doc.doc-code ) then do:
                    if p-ask then  do:
                        message  (if shar-buf_ord-doc.doc-type  =  'ОФ':U then "Заявка "  else " Заказ")  shar-buf_ord-doc.doc-code  "  не содержит ни одной записи ! Будем закрывать ? "
                          view-as alert-box question
                          buttons yes-no
                          title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " заявку " else " заказ " )
                          update g#log
                        .
                    end.
                    else g#log = false  .
                    if not g#log then  return error substitute( " Документ &1 , не содержит ни одной записи ", shar-buf_ord-doc.doc-code  ) .
                    shar-buf_ord-doc.flag_ = false .
                 end.
              if shar-buf_ord-doc.doc-type  <>  'ОФ':U  then do:
                    find first  t-doc-line where
                          t-doc-line.doc-code  = shar-buf_ord-doc.doc-code and
                        ( t-doc-line.price-rubl  <= 0 or
                          t-doc-line.price-cli   <= 0 or
                          t-doc-line.price-rubl  = ? or
                          t-doc-line.price-cli   = ? )
                          no-lock no-error .
                    if available t-doc-line then do:
                        return error substitute( " Документ &1 , содержит товары с неопределенной ценой!  ", shar-buf_ord-doc.doc-code  ) .
                      end.
              end.
        find first ub.clients no-lock
             where ub.clients.obj-code  = shar-buf_ord-doc.cli-code
               and ub.clients.obj-type  = shar-buf_ord-doc.cli-type  no-error .
              if not available ub.clients then do:
                  return error substitute( " Документ &1 , Проверьте правильность заполнения поля Поставщик  !  ", shar-buf_ord-doc.doc-code  ) .
              end.
              if  available ub.clients then do:
                assign
                v-is-edi-doc = status-is-edi ( input v-is-edi
                                        , input ub.clients.obj-type
                                        , input ub.clients.obj-code
                                        , input shar-buf_ord-doc.obj-type
                                        , input shar-buf_ord-doc.obj-code
                                        , output v-dm-edi
                                        ) .
          if shar-buf_ord-doc.whole-send-news = integer('0':U) and v-is-edi-doc = yes then do :
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pmnt-ord-doc_send-bypass-EDI':U
    ,input  'object':U
    ,input  g#host-code
    ,input  store-type
    ,input  store-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
          if g-log = false then do:
            assign shar-buf_ord-doc.whole-send-news = integer('2':U) .
            return error substitute( " Документ &1 , у Вас нет прав на работу без EDI. Документ отправлен по EDI!  ", shar-buf_ord-doc.doc-code ) .
          end.
          end.
                  if not ( ub.clients.obj-type = 'чел':U or
                           ub.clients.obj-type = 'орг':U ) then do:
                            return error substitute( " Документ &1 , Поставщик может быть только &2 или  &3 !  ", shar-buf_ord-doc.doc-code  , 'чел':U , 'орг':U  ) .
                  end.
                  if shar-buf_ord-doc.doc-type = 'ФП':U and ( ub.clients.obj-code = shar-buf_ord-doc.host-code ) then do:
                            return error substitute( " Документ &1 , Поставщик не может быть текущей фирмой !  ", shar-buf_ord-doc.doc-code  ) .
                  end.
               end.
              define variable v_ok as logical no-undo .
              run verif_1 in this-procedure (output v_ok) no-error .
                  if not v_ok then do:
                      if p-ask then  do:
                          message "В "  (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " Заявке " else " Заказе" ) shar-buf_ord-doc.doc-code " есть  повторный заказ на товары в пути ! Закрывать такой документ ? "
                            view-as alert-box question
                            buttons yes-no
                            title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " заявку " else "заказ" )
                            update g#log
                          .
                      end.
        else do:
          g#log = true .
        end.
                      if not g#log then   return error substitute( " Документ &1 , есть  повторный заказ на товары в пути !  ", shar-buf_ord-doc.doc-code  ) .
                   end.
              if shar-buf_ord-doc.doc-type  =  'ОП':U then do:
      run ver-clients-calc (
            input shar-buf_ord-doc.cli-type
          , input shar-buf_ord-doc.cli-code
          , input shar-buf_ord-doc.obj-type
          , input shar-buf_ord-doc.obj-code
          , input shar-buf_ord-doc.e-method
          , output g#log
                            ) .
                 if g#log then do:
                    if p-ask then  do:
                       message 'Заказ не был раcсчитан !!!' view-as alert-box error .
                    end.
                    return error substitute ("Заказ не был раcсчитан !!! Поставщик &1&2" , shar-buf_ord-doc.cli-type , shar-buf_ord-doc.cli-code ) .
                 end.
              end.
                  run waitfram-show in this-procedure ("Ждите ! Идет проверка по строкам...") .
                  define variable v-err-ext as logical   no-undo .
                  v-err-ext = false .
                  for each t-doc-line  where t-doc-line.doc-code = shar-buf_ord-doc.doc-code no-lock :
                  if shar-buf_ord-doc.contract-code <> 0 and
                     shar-buf_ord-doc.doc-type  =  'ОП':U  then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_ckcntspc in g#lib-trn3
( input shar-buf_ord-doc.host-code
 ,input shar-buf_ord-doc.contract-code
 ,input t-doc-line.gds-code
 ,input t-doc-line.price-cli
 ,input shar-buf_ord-doc.VAT-type
 ,input t-doc-line.VAT-pc
) no-error .
                      if error-status :error then do:
                        assign
                          v-err-ext = true
                          v-longchar = v-longchar + trim(return-value) + trim(error-status :get-message(1)) + chr(10)
                        .
                      end.
                  end.
                        find first ub.cli-gds where
                              ub.cli-gds.artic     = t-doc-line.artic     and
                              ub.cli-gds.cli-code  = shar-buf_ord-doc.cli-code       and
                              ub.cli-gds.cli-type  = shar-buf_ord-doc.cli-type       and
                              ub.cli-gds.host-code = g#host-code and
                              ub.cli-gds.prod-code = t-doc-line.prod-code and
                              ub.cli-gds.prod-type = t-doc-line.prod-type exclusive-lock no-error .
                      if available ub.cli-gds then  do:
                          if ub.cli-gds.cancel-date <> t-doc-line.cancel-date
                              then
                                 assign
                                   ub.cli-gds.cancel-date = t-doc-line.cancel-date
                                   .
                      end.
                  end.
                  if v-err-ext = true  then do:
                      run gbl/d-longchar.w
                          ( input ?
                           ,input   'Editor_row=2\':u
                                  + 'title=Проверка артикулов Поставщика\':u
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
                            "Ошибка"
                            view-as alert-box error
                          .
                          assign
                          v-longchar = '':U.
                     return error "Заказ не может быть закрыт ! Исправьте внешние артикулы Поставщика" .
        end.
                  if shar-buf_ord-doc.doc-type = 'ФП':U then do:
                      assign
                        shar-buf_ord-doc.status_ = 'поставка':U
                        .
                  end.
                  else do:
            if shar-buf_ord-doc.doc-type = 'ОП':U
            and (ord-op = no or shar-buf_ord-doc.whole-send-news = integer('2':U)) then do:
                          if v-dm-edi = integer('9':U)
              then do:
              assign
                shar-buf_ord-doc.ord-int1 = integer('6':U)
              .
              end.
              assign
              shar-buf_ord-doc.status_ = 'поставка':U
              .
            end.
            else do:
              assign
              shar-buf_ord-doc.status_ = 'согласование':U
              .
            end.
          end.
        if not (shar-buf_ord-doc.doc-type = 'ОП':U and ord-op = no )  then do:  run str/callnews.p     (input 'ord-doc':U      ,input (buffer shar-buf_ord-doc:handle)     ) no-error .        if error-status:error then do:     assign shar-buf_ord-doc.flag_ = old-flag  shar-buf_ord-doc.status_ = old-state .     return error substitute( " Документ &1 , Ошибка при передаче в новости &2 &3 &4 &5 &6", shar-buf_ord-doc.doc-code ,vss-workfile, vss-revision, vss-description, return-value , error-status:get-message(1)   ) .   end.                                                       end.
        run waitfram-hide in this-procedure .
       end.
       when 'согласование':U then do :
          if shar-buf_ord-doc.doc-type = 'ОФ':U   then do:
              return error substitute( " Документ &1 , Закрыть заявку можно автоматически в СЗФП!  ", shar-buf_ord-doc.doc-code  ) .
          end.
          if v-cntxt-db-num <> 0 then do:
            return error substitute( " Документ &1 , Закрыть Заказ в статусе СОГЛАСОВАНИЕ можно в ГБД !  ", shar-buf_ord-doc.doc-code  ) .
          end.
        if shar-buf_ord-doc.doc-type <> 'ОФ':U then do:
            assign
              shar-buf_ord-doc.status_ = 'поставка':U
              .
              run str/callnews.p     (input 'ord-doc':U      ,input (buffer shar-buf_ord-doc:handle)     ) no-error .        if error-status:error then do:     assign shar-buf_ord-doc.flag_ = old-flag  shar-buf_ord-doc.status_ = old-state .     return error substitute( " Документ &1 , Ошибка (факт) при передаче в новости &2 &3 &4 &5 &6", shar-buf_ord-doc.doc-code ,vss-workfile, vss-revision, vss-description, return-value , error-status:get-message(1)  ) .   end.
          end.
       end.
       when 'поставка':U then do :
            if shar-buf_ord-doc.doc-type = 'ОФ':U  then do:
            end.
            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code     = shar-buf_ord-doc.doc-code
                                               and NOT ( t-ord-doc-rcv.status_   = 'поставка':U
                                                   OR  t-ord-doc-rcv.status_   = 'факт':U ) no-lock :
                return error substitute( " Документ &1 , Поставка &2 имеет статус &3 , закрыть  Документ &1  до статуса ЗАКРЫТО невозможно ! Закройте поставку до статуса ПОСТАВКА ", shar-buf_ord-doc.doc-code , t-ord-doc-rcv.rcv-code , CAPS(t-ord-doc-rcv.status_) ) .
            end.
         assign
           sum-ord = 0
           sum-rcv = 0
          .
           for each t-doc-line     where t-doc-line.doc-code     = shar-buf_ord-doc.doc-code  no-lock :
               for each  t-doc-line-rcv where t-doc-line-rcv.doc-code = t-doc-line.doc-code and
                                         t-doc-line-rcv.artic    = t-doc-line.artic         and
                                         t-doc-line-rcv.prod-type  = t-doc-line.prod-type   and
                                         t-doc-line-rcv.prod-code  = t-doc-line.prod-code
                no-lock :
                  sum-rcv = sum-rcv + t-doc-line-rcv.qnty.
                end.
                sum-ord = sum-ord + t-doc-line.qnty.
           end.
            if  sum-rcv = 0  then do:
               if p-ask then  do:
                  message  (if shar-buf_ord-doc.doc-type  =  'ОФ':U then "Заявка "   + shar-buf_ord-doc.doc-code + " не имеет " else " Заказ"   + shar-buf_ord-doc.doc-code + "  не имеет "  )   "  поставок ! Закрыть в статус (ЗАКРЫТО-) ? "
                    view-as alert-box question
                    buttons yes-no
                    title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " заявку " else " заказ " )
                    update g#log
                  .
                end.
                else g#log = false .
                if not g#log then  return error substitute( " Документ &1 , Не имеет поставок ", shar-buf_ord-doc.doc-code  ) .
                shar-buf_ord-doc.flag_ = false .
            end.
            if  sum-ord > sum-rcv then do:
               if p-ask then  do:
                message  (if shar-buf_ord-doc.doc-type  =  'ОФ':U then "Заявка "   + shar-buf_ord-doc.doc-code + " не покрыта " else " Заказ"   + shar-buf_ord-doc.doc-code + "  не покрыт "  )   "  поставками полностью ! Закрыть в статус (ЗАКРЫТО-) ? "
                  skip
                  "по заказу =" sum-ord   skip
                  "по поставкам =" sum-rcv
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " заявку " else " заказ " )
                  update g#log
                .
               end.
               else do:
                      run ver-qnty-rcv-from-ord (input shar-buf_ord-doc.doc-code , output v-is-limit ) .
                      if v-is-limit then do:
                         g#log = true .
                      end.
                      else do:
                         g#log = false .
                      end.
               end.
                if not g#log then do:
                  return error substitute( " Документ &1 , не покрыт поставками полностью !  ", shar-buf_ord-doc.doc-code  ) .
                end.
                shar-buf_ord-doc.flag_ = false .
            end.
            if  sum-ord =  sum-rcv then do:
                shar-buf_ord-doc.flag_ = true  .
            end.
            if  sum-ord <  sum-rcv then do:
                ord-rcv1 = 0.
                v-ne = false  .
                for each buf_1_ord-line no-lock where buf_1_ord-line.doc-code = shar-buf_ord-doc.doc-code :
                    for each buf_1_ord-line-rcv no-lock where
                             buf_1_ord-line-rcv.doc-code  = shar-buf_ord-doc.doc-code and
                             buf_1_ord-line-rcv.artic     = buf_1_ord-line.artic      and
                             buf_1_ord-line-rcv.prod-type = buf_1_ord-line.prod-type  and
                             buf_1_ord-line-rcv.prod-code = buf_1_ord-line.prod-code
                             :
                             ord-rcv1 = ord-rcv1 + buf_1_ord-line-rcv.qnty.
                    end.
                    if buf_1_ord-line.qnty > ord-rcv1 then do:
                       v-ne = true .
                       leave.
                    end.
                end.
                shar-buf_ord-doc.flag_ = false  .
                if v-ne = false then do:
                    if p-ask then  do:
                        message "На "
                        if shar-buf_ord-doc.doc-type = 'ОФ':U then " Заявка " else "Заказ"
                        shar-buf_ord-doc.doc-code
                          " превышено количество по поставками  ! Закрыть в статус (ЗАКРЫТО+) ? " skip
                          "по заказу =" sum-ord   skip
                          "по поставкам =" sum-rcv
                          view-as alert-box question
                          buttons yes-no
                          title "Закрыть " + (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " заявку " else "заказ" )
                          update g#log
                        .
                    end.
                    else do:
                          run ver-qnty-rcv-from-ord (input shar-buf_ord-doc.doc-code , output v-is-limit ) .
                          if v-is-limit then do:
                            g#log = true .
                          end.
                          else do:
                            g#log = false .
                          end.
                    end.
                     .
                    if not g#log then  return error substitute( " Документ &1 , превышено количество по поставками !  ", shar-buf_ord-doc.doc-code  ) .
                    shar-buf_ord-doc.flag_ = true  .
                end.
            end.
            assign
              shar-buf_ord-doc.status_ = 'закрыто':U
              .
              run str/callnews.p     (input 'ord-doc':U      ,input (buffer shar-buf_ord-doc:handle)     ) no-error .        if error-status:error then do:     assign shar-buf_ord-doc.flag_ = old-flag  shar-buf_ord-doc.status_ = old-state .     return error substitute( " Документ &1 , Ошибка (факт) при передаче в новости &2 &3 &4 &5 &6", shar-buf_ord-doc.doc-code ,vss-workfile, vss-revision, vss-description, return-value , error-status:get-message(1)  ) .   end.
      end.
       when 'закрыто':U then do :
            if shar-buf_ord-doc.doc-type = 'ОФ':U  then do:
               return error substitute( " Документ &1 , Закрыть заявку можно только автоматически в АРМе 'ОФИС' !  ", shar-buf_ord-doc.doc-code  ) .
            end.
              define variable v-office      as character no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currdbat in g#library
  (input  'office=request':u
  ,output v-office
  )  .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  shar-buf_ord-doc.obj-type
  ,input  shar-buf_ord-doc.obj-code
  ,output doc-db-num
  )  .
              if  v-obj-active <> "yes" and doc-db-num = p-db-num then  v-obj-active = "yes" .
              if  v-obj-active <> "yes"  then do:
                  return error substitute( " Документ &1 , Закрыть до факта можно только на АКТИВНОМ объекте !  ", shar-buf_ord-doc.doc-code  ) .
              end.
            for each t-ord-doc-rcv where  t-ord-doc-rcv.doc-code     = shar-buf_ord-doc.doc-code no-lock :
                for each ub.ord-chain no-lock where
                          ub.ord-chain.doc-code = t-ord-doc-rcv.rcv-code and
                          ub.ord-chain.doc-type = 'rcv'                  and
                          ub.ord-chain.rel-doc-type = 'trn'
                          :
                 for each t-trn-doc no-lock where
                         (t-trn-doc.doc-type  = 'при':U     or
                          t-trn-doc.doc-type  = 'рас':U ) and
                          t-trn-doc.doc-code  = ub.ord-chain.rel-doc-code and
                          t-trn-doc.status_  <> 'факт':U  :
                  return error substitute( " Заказ &1 , закрыть до статуса ЗАКРЫТО невозможно ! Закройте ПН &2 до статуса ФАКТ ", shar-buf_ord-doc.doc-code , t-trn-doc.doc-code ) .
                 end.
                 end.
            end.
         assign
           sum-ord = 0
           sum-rcv = 0
           sum-trn = 0
           v-tt-qnty = false
           sum-trn1 = 0.
          .
        for each t-doc-line     where
                 t-doc-line.doc-code     = shar-buf_ord-doc.doc-code  no-lock :
            for each  t-doc-line-rcv where
                      t-doc-line-rcv.doc-code = t-doc-line.doc-code and
                      t-doc-line-rcv.artic    = t-doc-line.artic         and
                      t-doc-line-rcv.prod-type  = t-doc-line.prod-type   and
                      t-doc-line-rcv.prod-code  = t-doc-line.prod-code no-lock ,
              first t-doc-rcv where t-doc-line-rcv.doc-code = t-doc-rcv.doc-code  and
                                    t-doc-line-rcv.rcv-code = t-doc-rcv.rcv-code  no-lock :
              for each ub.ord-chain no-lock where
                        ub.ord-chain.doc-code = t-doc-rcv.rcv-code and
                        ub.ord-chain.doc-type = 'rcv'                  and
                        ub.ord-chain.rel-doc-type = 'trn'
                        :
                  for each  t-trn-line where
                            t-trn-line.doc-code  = ub.ord-chain.rel-doc-code    and
                            t-trn-line.artic      = t-doc-line-rcv.artic        and
                            t-trn-line.prod-type  = t-doc-line-rcv.prod-type    and
                            t-trn-line.prod-code  = t-doc-line-rcv.prod-code
                            no-lock :
                      sum-trn = sum-trn + t-trn-line.fact-qnty.
                      sum-trn1 = sum-trn1 + t-trn-line.fact-qnty.
                  end.
               end.
              sum-rcv = sum-rcv + t-doc-line-rcv.qnty.
            end.
            sum-ord = sum-ord + t-doc-line.qnty.
            if t-doc-line.qnty > sum-trn1 then v-tt-qnty = true .
            sum-trn1 = 0 .
        end.
            if  sum-trn = 0  then do:
                if p-ask then  do:
                message  (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " Заявка " else " Заказ" ) shar-buf_ord-doc.doc-code " не имеет ПН (или полностью ей не соответствует) ! Закрыть в статус (ФАКТ-) ? "
                  view-as alert-box question
                  buttons yes-no
                  title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " заявку " else "заказ" )
                  update g#log
                .
                end.
                else g#log = false .
                if not g#log then return error substitute( " Документ &1 , не имеет ПН (или полностью ей не соответствует)!  ", shar-buf_ord-doc.doc-code  ) .
                shar-buf_ord-doc.flag_ = false .
            end.
            if  sum-ord > sum-trn then do:
                if p-ask then  do:
                    message  (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " Заявка " else " Заказ" ) shar-buf_ord-doc.doc-code
                     " не покрыт ПН полностью ! Закрыть в статус (ФАКТ-) ? " skip
                      "по заказу =" sum-ord skip
                      "по накладным ="sum-trn
                      view-as alert-box question
                      buttons yes-no
                      title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " заявку " else "заказ" )
                      update g#log
                    .
                end.
                else do:
                      run ver-qnty-rcv-from-ord (input shar-buf_ord-doc.doc-code , output v-is-limit ) .
                      if v-is-limit then do:
                        g#log = true .
                      end.
                      else do:
                        g#log = false .
                      end.
                end.
                if not g#log then  return error substitute( " Документ &1 , не покрыт ПН полностью !  ", shar-buf_ord-doc.doc-code  ) .
                shar-buf_ord-doc.flag_ = false .
            end.
            if  sum-ord =  sum-trn then do:
                shar-buf_ord-doc.flag_ = true  .
                if v-tt-qnty = true then shar-buf_ord-doc.flag_ = false .
            end.
            if  sum-ord <  sum-trn then do:
                if p-ask then  do:
                  message "На "  (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " Заявка " else " Заказ" ) shar-buf_ord-doc.doc-code
                  ( if v-tt-qnty = true
                    then "Несоответствие количеств по ПН ! Закрыть в статус (ФАКТ-) ? "
                    else "Превышено количество по ПН ! Закрыть в статус (ФАКТ+) ? "
                   )
                   skip
                   "по заказу =" sum-ord skip
                   "по накладным =" sum-trn
                    view-as alert-box question
                    buttons yes-no
                    title "Закрыть "  + (if shar-buf_ord-doc.doc-type  =  'ОФ':U then " заявку " else "заказ" )
                    update g#log
                  .
                end.
                else do:
                      run ver-qnty-rcv-from-ord (input shar-buf_ord-doc.doc-code , output v-is-limit ) .
                      if v-is-limit then do:
                        g#log = true .
                      end.
                      else do:
                        g#log = false .
                      end.
                end.
                if not g#log then return error substitute( " Документ &1 , превышено количество по ПН !  ", shar-buf_ord-doc.doc-code  ) .
                shar-buf_ord-doc.flag_ = true  .
                if v-tt-qnty = true then shar-buf_ord-doc.flag_ = false .
            end.
            if shar-buf_ord-doc.contract-code <> 0 then do:
                find first buf_contract no-lock where
                           buf_contract.host-code = shar-buf_ord-doc.host-code and
                           buf_contract.contract-code = shar-buf_ord-doc.contract-code no-error .
                 if available buf_contract and
                     ( buf_contract.usl-opl = 'По заказу':U
                     or buf_contract.usl-opl = 'Отсрочка платежа по заказу':U) then do:
                    shar-buf_ord-doc.need-fo = 1 .
                    shar-buf_ord-doc.cr-fo = no .
                 end.
            end.
            for each t-ord-doc-rcv exclusive-lock where
                     t-ord-doc-rcv.doc-code = shar-buf_ord-doc.doc-code and
                     t-ord-doc-rcv.status_  <> 'факт':U
                     :
              assign
                  t-ord-doc-rcv.status_ = 'факт':U
                  t-ord-doc-rcv.flag_   = false
                  .
            end.
            assign
              shar-buf_ord-doc.status_   = 'факт':U
              shar-buf_ord-doc.fact-date = to-day
             .
             run str/callnews.p     (input 'ord-doc':U      ,input (buffer shar-buf_ord-doc:handle)     ) no-error .        if error-status:error then do:     assign shar-buf_ord-doc.flag_ = old-flag  shar-buf_ord-doc.status_ = old-state .     return error substitute( " Документ &1 , Ошибка (факт) при передаче в новости &2 &3 &4 &5 &6", shar-buf_ord-doc.doc-code ,vss-workfile, vss-revision, vss-description, return-value , error-status:get-message(1)  ) .   end.
      end.
 end case.
procedure verif_1 :
do
on error undo, return error return-value
:
define output parameter v-ret as logical no-undo .
 v-ret = true .
define buffer later-ord-doc  for  ub.ord-doc  .
define buffer later-ord-line for  ub.ord-line .
define buffer today-ord-line for  ub.ord-line .
define variable v-qnty as decimal no-undo .
define variable v-exis as logical no-undo .
define variable v-txt as character no-undo .
 output stream errStream to value( v-file-name )  .
v-exis = false .
for each  temp-obj-list :
  delete temp-obj-list .
end.
define variable str-pos as integer no-undo .
define variable str-pos2 as integer no-undo .
define variable str-1 as character no-undo .
define variable i  as integer no-undo .
define variable e1 as character no-undo .
define variable e2 as integer no-undo .
define variable k1 as integer no-undo .
define variable v-nn as integer   no-undo .
if shar-buf_ord-doc.doc-type = 'ФП':U then do:
    k1 = 0 .
    str-pos = index (  shar-buf_ord-doc.e-method , "&" ) .
    str-pos2 = length ( shar-buf_ord-doc.e-method ) - str-pos .
    str-1 = substring (shar-buf_ord-doc.e-method , str-pos + 1 , str-pos2 ).
    v-nn = num-entries (str-1) .
    do i = 1 to v-nn :
        assign
          e1 = entry(1, (entry( i , str-1, "," )) , " ")
          e2 = integer(entry(2, (entry( i , str-1, "," )), " " ))
          no-error .
          if error-status :error then next.
          k1 = k1 + 1.
          create temp-obj-list.
          assign
            temp-obj-list.obj-type = e1
            temp-obj-list.obj-code = e2
          .
    end .
    if k1 < 1 then do :
       run sss in this-procedure .
    end.
end.
else do:
   create temp-obj-list.
   assign
     temp-obj-list.obj-type = shar-buf_ord-doc.obj-type
     temp-obj-list.obj-code = shar-buf_ord-doc.obj-code
   .
end.
for each today-ord-line where today-ord-line.doc-code = shar-buf_ord-doc.doc-code and today-ord-line.qnty > 0 no-lock :
      v-qnty = 0.
      v-txt  = "" .
        for each later-ord-line where
                                later-ord-line.artic     = today-ord-line.artic     and
                                later-ord-line.prod-type = today-ord-line.prod-type and
                                later-ord-line.prod-code = today-ord-line.prod-code no-lock ,
            each  later-ord-doc where  later-ord-line.doc-code = later-ord-doc.doc-code and
                              ( later-ord-doc.status_ = 'согласование':U or
                                later-ord-doc.status_ = 'поставка':U or
                                later-ord-doc.status_ = 'закрыто':U
                                ) and
                                later-ord-doc.doc-code <> today-ord-line.doc-code and
                                ( if shar-buf_ord-doc.cons-code <> "" then
                                   later-ord-doc.cons-code <> shar-buf_ord-doc.cons-code
                                   else
                                   true = true )
                                 and
                                later-ord-doc.date-sale-1 <= shar-buf_ord-doc.date-sale-2  and
                                later-ord-doc.date-sale-2 >= shar-buf_ord-doc.date-sale-1   and
                                later-ord-doc.host-code = shar-buf_ord-doc.host-code   no-lock ,
             each temp-obj-list where temp-obj-list.obj-code = later-ord-doc.obj-code and
                                      temp-obj-list.obj-type = later-ord-doc.obj-type no-lock :
          v-qnty = v-qnty +  later-ord-line.qnty .
          v-txt  = v-txt  +  trim(later-ord-line.doc-code) + ";" .
        end.
        if v-qnty > 0 then do:
          find first ub.goods where
                today-ord-line.artic     = ub.goods.artic      and
                today-ord-line.prod-type = ub.goods.prod-type  and
                today-ord-line.prod-code = ub.goods.prod-code  no-lock no-error.
          Put  stream  errStream unformatted
          "По объекту :"  shar-buf_ord-doc.obj-type shar-buf_ord-doc.obj-code  skip
          "По товару :"  today-ord-line.artic       today-ord-line.prod-type       today-ord-line.prod-code skip
          ub.goods.gds-name skip
          "По документам :"    v-txt skip
          "Уже заказано (в пути) :" v-qnty    " "    ub.goods.unit-base   skip
          skip
          "По текущему документу № " shar-buf_ord-doc.doc-code  " кол-во заказа : " today-ord-line.qnty " " ub.goods.unit-base skip
          "Анализируемый период продаж с " shar-buf_ord-doc.date-sale-1 " по " shar-buf_ord-doc.date-sale-2 skip
          "Итого :"  ( v-qnty  + today-ord-line.qnty )   skip
          "--------------------------------------------------------------------"
          skip.
          v-exis = true.
        end.
end.
if v-exis = true then do:
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical no-undo .
    if p-ask then  do:
      message
       "При проверке товаров по периоду продаж были обнаружены повторы ! " skip
       "Вы можете просмотреть и распечатать их список . "
       skip "Документ" shar-buf_ord-doc.doc-code
       view-as alert-box error .
    end.
   Output stream errStream   close .
  if p-ask then do:
    run gbl/prnfilen.w
      (input  "Повторы, обнаруженные при проверке товаров по периоду продаж"
      ,input  0
      ,input  v-file-name
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
       if not ( lookup( ' экран':L, v-user-action ,";")  > 0 or
                lookup( ' принтер':L, v-user-action ,";")  > 0  ) then do:
        message "Внимание! Вы не просмотрели список повторных заказов ! "  .
       end.
  end.
      v-ret = false .
      return.
end.
v-ret = true .
return.
end.
end procedure.
procedure sss :
  define variable v-object-available as logical   no-undo .
  define buffer buf_clients for ub.clients .
  do
  on error undo, return error return-value
  :
    for each buf_clients no-lock
      where buf_clients.host-code = g#host-code
        and ( ( buf_clients.db-num = p-db-num ) or p-db-num = 0 )
    on error undo, return error return-value
    :
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-object-available
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры gbl/usobjava.i" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return no-apply .
      end.
      if v-object-available = true
      then do:
        create temp-obj-list.
        assign
          temp-obj-list.obj-type = buf_clients.obj-type
          temp-obj-list.obj-code = buf_clients.obj-code
        .
      end.
    end.
  end.
end procedure.
