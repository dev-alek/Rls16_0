define input  parameter parparentproc        as widget-handle no-undo .
define input  parameter p-callback-handle    as handle    no-undo .
define input  parameter p-db-num             as integer   no-undo .
define input  parameter p-user-id            as character no-undo .
define input  parameter p-curr-host-code-obj as integer   no-undo .
define input  parameter p-curr-obj-type      as character no-undo .
define input  parameter p-curr-obj-code      as integer   no-undo .
DEFINE INPUT  PARAMETER p-bttns              AS CHARACTER NO-UNDO.
define output parameter p-user-select        as logical   no-undo .
define output parameter p-select-obj-type    as character no-undo .
define output parameter p-select-obj-code    as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор объекта или списка объектов из доступных пользователю объектов".
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
    assign
      p-vss-parameters = substitute('&1|&2':u,parparentproc,p-callback-handle,p-curr-obj-type,p-curr-obj-code,p-curr-host-code-obj,p-user-id)
    .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-colwidth-db-num          as integer   no-undo .
define variable v-colwidth-user-id         as character no-undo .
define variable v-colwidth-program-name    as character no-undo .
define variable v-colwidth-width-01        as decimal   no-undo .
define variable v-colwidth-width-02        as decimal   no-undo .
define variable v-colwidth-width-03        as decimal   no-undo .
define variable v-colwidth-width-04        as decimal   no-undo .
define variable v-colwidth-width-05        as decimal   no-undo .
define variable v-colwidth-width-06        as decimal   no-undo .
define variable v-colwidth-width-07        as decimal   no-undo .
define variable v-colwidth-width-08        as decimal   no-undo .
define variable v-colwidth-width-09        as decimal   no-undo .
define variable v-colwidth-width-10        as decimal   no-undo .
define variable v-colwidth-width-11        as decimal   no-undo .
define variable v-colwidth-width-12        as decimal   no-undo .
define variable v-colwidth-width-13        as decimal   no-undo .
define variable v-colwidth-width-14        as decimal   no-undo .
define variable v-colwidth-width-15        as decimal   no-undo .
define variable v-colwidth-width-16        as decimal   no-undo .
define variable v-colwidth-width-17        as decimal   no-undo .
define variable v-colwidth-width-18        as decimal   no-undo .
define variable v-colwidth-width-19        as decimal   no-undo .
define variable v-colwidth-width-20        as decimal   no-undo .
define variable v-colwidth-width-01-shadow as decimal   no-undo .
define variable v-colwidth-width-02-shadow as decimal   no-undo .
define variable v-colwidth-width-03-shadow as decimal   no-undo .
define variable v-colwidth-width-04-shadow as decimal   no-undo .
define variable v-colwidth-width-05-shadow as decimal   no-undo .
define variable v-colwidth-width-06-shadow as decimal   no-undo .
define variable v-colwidth-width-07-shadow as decimal   no-undo .
define variable v-colwidth-width-08-shadow as decimal   no-undo .
define variable v-colwidth-width-09-shadow as decimal   no-undo .
define variable v-colwidth-width-10-shadow as decimal   no-undo .
define variable v-colwidth-width-11-shadow as decimal   no-undo .
define variable v-colwidth-width-12-shadow as decimal   no-undo .
define variable v-colwidth-width-13-shadow as decimal   no-undo .
define variable v-colwidth-width-14-shadow as decimal   no-undo .
define variable v-colwidth-width-15-shadow as decimal   no-undo .
define variable v-colwidth-width-16-shadow as decimal   no-undo .
define variable v-colwidth-width-17-shadow as decimal   no-undo .
define variable v-colwidth-width-18-shadow as decimal   no-undo .
define variable v-colwidth-width-19-shadow as decimal   no-undo .
define variable v-colwidth-width-20-shadow as decimal   no-undo .
procedure colwidth-read :
  define input  parameter p-db-num       as integer   no-undo .
  define input  parameter p-user-id      as character no-undo .
  define input  parameter p-program-name as character no-undo .
  define output parameter p-data-exist   as logical   no-undo .
  define buffer buf_rpt-option for ubflt.rpt-option .
  do
  on error undo, return error return-value
  :
    assign
      v-colwidth-db-num       = p-db-num
      v-colwidth-user-id      = p-user-id
      v-colwidth-program-name = p-program-name
    .
    find first buf_rpt-option no-lock
      where buf_rpt-option.rpt-name    = p-program-name
        and buf_rpt-option.rpt-code    = 'column-width':U
        and buf_rpt-option.user-db-num = p-db-num
        and buf_rpt-option.user-id     = p-user-id
      no-error .
    if available buf_rpt-option
    then do:
      assign
        p-data-exist        = true
        v-colwidth-width-01 = buf_rpt-option.param-decimal-01-value
        v-colwidth-width-02 = buf_rpt-option.param-decimal-02-value
        v-colwidth-width-03 = buf_rpt-option.param-decimal-03-value
        v-colwidth-width-04 = buf_rpt-option.param-decimal-04-value
        v-colwidth-width-05 = buf_rpt-option.param-decimal-05-value
        v-colwidth-width-06 = buf_rpt-option.param-decimal-06-value
        v-colwidth-width-07 = buf_rpt-option.param-decimal-07-value
        v-colwidth-width-08 = buf_rpt-option.param-decimal-08-value
        v-colwidth-width-09 = buf_rpt-option.param-decimal-09-value
        v-colwidth-width-10 = buf_rpt-option.param-decimal-10-value
        v-colwidth-width-11 = buf_rpt-option.param-decimal-11-value
        v-colwidth-width-12 = buf_rpt-option.param-decimal-12-value
        v-colwidth-width-13 = buf_rpt-option.param-decimal-13-value
        v-colwidth-width-14 = buf_rpt-option.param-decimal-14-value
        v-colwidth-width-15 = buf_rpt-option.param-decimal-15-value
        v-colwidth-width-16 = buf_rpt-option.param-decimal-16-value
        v-colwidth-width-17 = buf_rpt-option.param-decimal-17-value
        v-colwidth-width-18 = buf_rpt-option.param-decimal-18-value
        v-colwidth-width-19 = buf_rpt-option.param-decimal-19-value
        v-colwidth-width-20 = buf_rpt-option.param-decimal-20-value
      .
    end.
    else do:
      assign
        p-data-exist        = false
        v-colwidth-width-01 = 0
        v-colwidth-width-02 = 0
        v-colwidth-width-03 = 0
        v-colwidth-width-04 = 0
        v-colwidth-width-05 = 0
        v-colwidth-width-06 = 0
        v-colwidth-width-07 = 0
        v-colwidth-width-08 = 0
        v-colwidth-width-09 = 0
        v-colwidth-width-10 = 0
        v-colwidth-width-11 = 0
        v-colwidth-width-12 = 0
        v-colwidth-width-13 = 0
        v-colwidth-width-14 = 0
        v-colwidth-width-15 = 0
        v-colwidth-width-16 = 0
        v-colwidth-width-17 = 0
        v-colwidth-width-18 = 0
        v-colwidth-width-19 = 0
        v-colwidth-width-20 = 0
      .
    end.
    assign
      v-colwidth-width-01-shadow = v-colwidth-width-01
      v-colwidth-width-02-shadow = v-colwidth-width-02
      v-colwidth-width-03-shadow = v-colwidth-width-03
      v-colwidth-width-04-shadow = v-colwidth-width-04
      v-colwidth-width-05-shadow = v-colwidth-width-05
      v-colwidth-width-06-shadow = v-colwidth-width-06
      v-colwidth-width-07-shadow = v-colwidth-width-07
      v-colwidth-width-08-shadow = v-colwidth-width-08
      v-colwidth-width-09-shadow = v-colwidth-width-09
      v-colwidth-width-10-shadow = v-colwidth-width-10
      v-colwidth-width-11-shadow = v-colwidth-width-11
      v-colwidth-width-12-shadow = v-colwidth-width-12
      v-colwidth-width-13-shadow = v-colwidth-width-13
      v-colwidth-width-14-shadow = v-colwidth-width-14
      v-colwidth-width-15-shadow = v-colwidth-width-15
      v-colwidth-width-16-shadow = v-colwidth-width-16
      v-colwidth-width-17-shadow = v-colwidth-width-17
      v-colwidth-width-18-shadow = v-colwidth-width-18
      v-colwidth-width-19-shadow = v-colwidth-width-19
      v-colwidth-width-20-shadow = v-colwidth-width-20
    .
  end.
end procedure.
procedure colwidth-write :
  define buffer buf_rpt-option for ubflt.rpt-option .
  do
  on error undo, return error return-value
  :
    if v-colwidth-width-01-shadow <> v-colwidth-width-01
    or v-colwidth-width-02-shadow <> v-colwidth-width-02
    or v-colwidth-width-03-shadow <> v-colwidth-width-03
    or v-colwidth-width-04-shadow <> v-colwidth-width-04
    or v-colwidth-width-05-shadow <> v-colwidth-width-05
    or v-colwidth-width-06-shadow <> v-colwidth-width-06
    or v-colwidth-width-07-shadow <> v-colwidth-width-07
    or v-colwidth-width-08-shadow <> v-colwidth-width-08
    or v-colwidth-width-09-shadow <> v-colwidth-width-09
    or v-colwidth-width-10-shadow <> v-colwidth-width-10
    or v-colwidth-width-11-shadow <> v-colwidth-width-11
    or v-colwidth-width-12-shadow <> v-colwidth-width-12
    or v-colwidth-width-13-shadow <> v-colwidth-width-13
    or v-colwidth-width-14-shadow <> v-colwidth-width-14
    or v-colwidth-width-15-shadow <> v-colwidth-width-15
    or v-colwidth-width-16-shadow <> v-colwidth-width-16
    or v-colwidth-width-17-shadow <> v-colwidth-width-17
    or v-colwidth-width-18-shadow <> v-colwidth-width-18
    or v-colwidth-width-19-shadow <> v-colwidth-width-19
    or v-colwidth-width-20-shadow <> v-colwidth-width-20
    then do:
      do transaction
      on error undo, return error return-value
      :
        find first buf_rpt-option exclusive-lock
          where buf_rpt-option.rpt-name    = v-colwidth-program-name
            and buf_rpt-option.rpt-code    = 'column-width':U
            and buf_rpt-option.user-db-num = v-colwidth-db-num
            and buf_rpt-option.user-id     = v-colwidth-user-id
          no-error .
        if not available buf_rpt-option
        then do:
          create buf_rpt-option .
          assign
            buf_rpt-option.rpt-name    = v-colwidth-program-name
            buf_rpt-option.rpt-code    = 'column-width':U
            buf_rpt-option.user-db-num = v-colwidth-db-num
            buf_rpt-option.user-id     = v-colwidth-user-id
          .
        end.
        assign
          buf_rpt-option.param-decimal-01-value = v-colwidth-width-01
          buf_rpt-option.param-decimal-02-value = v-colwidth-width-02
          buf_rpt-option.param-decimal-03-value = v-colwidth-width-03
          buf_rpt-option.param-decimal-04-value = v-colwidth-width-04
          buf_rpt-option.param-decimal-05-value = v-colwidth-width-05
          buf_rpt-option.param-decimal-06-value = v-colwidth-width-06
          buf_rpt-option.param-decimal-07-value = v-colwidth-width-07
          buf_rpt-option.param-decimal-08-value = v-colwidth-width-08
          buf_rpt-option.param-decimal-09-value = v-colwidth-width-09
          buf_rpt-option.param-decimal-10-value = v-colwidth-width-10
          buf_rpt-option.param-decimal-11-value = v-colwidth-width-11
          buf_rpt-option.param-decimal-12-value = v-colwidth-width-12
          buf_rpt-option.param-decimal-13-value = v-colwidth-width-13
          buf_rpt-option.param-decimal-14-value = v-colwidth-width-14
          buf_rpt-option.param-decimal-15-value = v-colwidth-width-15
          buf_rpt-option.param-decimal-16-value = v-colwidth-width-16
          buf_rpt-option.param-decimal-17-value = v-colwidth-width-17
          buf_rpt-option.param-decimal-18-value = v-colwidth-width-18
          buf_rpt-option.param-decimal-19-value = v-colwidth-width-19
          buf_rpt-option.param-decimal-20-value = v-colwidth-width-20
        .
      end.
      assign
        v-colwidth-width-01-shadow = v-colwidth-width-01
        v-colwidth-width-02-shadow = v-colwidth-width-02
        v-colwidth-width-03-shadow = v-colwidth-width-03
        v-colwidth-width-04-shadow = v-colwidth-width-04
        v-colwidth-width-05-shadow = v-colwidth-width-05
        v-colwidth-width-06-shadow = v-colwidth-width-06
        v-colwidth-width-07-shadow = v-colwidth-width-07
        v-colwidth-width-08-shadow = v-colwidth-width-08
        v-colwidth-width-09-shadow = v-colwidth-width-09
        v-colwidth-width-10-shadow = v-colwidth-width-10
        v-colwidth-width-11-shadow = v-colwidth-width-11
        v-colwidth-width-12-shadow = v-colwidth-width-12
        v-colwidth-width-13-shadow = v-colwidth-width-13
        v-colwidth-width-14-shadow = v-colwidth-width-14
        v-colwidth-width-15-shadow = v-colwidth-width-15
        v-colwidth-width-16-shadow = v-colwidth-width-16
        v-colwidth-width-17-shadow = v-colwidth-width-17
        v-colwidth-width-18-shadow = v-colwidth-width-18
        v-colwidth-width-19-shadow = v-colwidth-width-19
        v-colwidth-width-20-shadow = v-colwidth-width-20
      .
    end.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrnickf returns character ( input p-user-id as character):
   define variable v-nick      as character    no-undo.
   if p-user-id = ?
   OR p-user-id = "":U
   then do:
      return '':U .
   end.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-list-option      as character no-undo .
define variable v-sort-column-name as character no-undo .
define variable v-brws-mark      as character no-undo COLUMN-LABEL "*"        FORMAT "X(1)":U  .
define variable v-brws-db-num    as character no-undo COLUMN-LABEL "БД"       FORMAT "X(5)":U  .
define variable v-brws-host-code as character no-undo COLUMN-LABEL "Фирма"    FORMAT "X(5)":U  .
define variable v-brws-host-name as character no-undo COLUMN-LABEL "Название" FORMAT "x(30)":U .
define variable v-total-select-num as integer   no-undo .
DEFINE VARIABLE g#log AS  LOGICAL NO-UNDO.
define temp-table temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
define NEW shared temp-table temp-obj-info no-undo   field obj-type       as character   field obj-code       as integer   field db-num         as integer   field brws-obj-name  as character   field brws-db-num    as character   field brws-host-code as character   field brws-host-name as character   field brws-curr-code as integer   index xpk is primary unique obj-type obj-code   index xie1 brws-obj-name obj-type obj-code   index xie2 brws-db-num obj-type obj-code   index xie3 brws-host-code obj-type obj-code   index xie4 brws-host-name obj-type obj-code   index xie5 brws-curr-code obj-type obj-code   .
DEFINE BUFFER buf_temp-obj-info FOR temp-obj-info .
define stream sout .
FUNCTION mark-string RETURNS CHARACTER
  ( p-obj-type as character, p-obj-code as integer )  FORWARD.
DEFINE MENU MENU-B-list
       MENU-ITEM m_list-export  LABEL "Сохранить"
       MENU-ITEM m_list-import  LABEL "Загрузить"     .
DEFINE BUTTON b-action
     LABEL "Права"
     SIZE 10 BY 1 TOOLTIP "Права, доступные пользователю на этом объекте".
DEFINE BUTTON b-add-all
     LABEL "Доб.&все"
     SIZE 10 BY 1.
DEFINE BUTTON b-add-sh
     LABEL "Доб.&маг."
     SIZE 10 BY 1.
DEFINE BUTTON b-add-st
     LABEL "Доб.&скл."
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-del-all
     LABEL "Удал. все"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-END-KEY DEFAULT
     LABEL "&Выход ":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 8.5 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-list
     LABEL "С&писок"
     SIZE 10 BY 1.
DEFINE BUTTON b-mark
     LABEL "*"
     SIZE 3 BY 1.
DEFINE BUTTON b-select-all
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Выбрать все".
DEFINE BUTTON b-deselect-all
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Отменить выбор".
DEFINE BUTTON b-menu
     LABEL "Меню"
     SIZE 10 BY 1 TOOLTIP "Группы меню, доступные пользователю на этом объекте".
DEFINE BUTTON b-sel AUTO-GO DEFAULT
     LABEL "Вы&бор ":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-show-host
     LABEL "&Фирма"
     SIZE 10 BY 1.
DEFINE BUTTON b-show-obj
     LABEL "&Объект"
     SIZE 10 BY 1.
DEFINE VARIABLE flt-code AS INTEGER FORMAT "99999":U INITIAL 0
     LABEL "Фильтр код"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE QUERY br-obj FOR
      buf_temp-obj-info SCROLLING.
DEFINE BROWSE br-obj
  QUERY br-obj NO-LOCK DISPLAY
      mark-string(buf_temp-obj-info.obj-type, buf_temp-obj-info.obj-code) @ v-brws-mark
      buf_temp-obj-info.obj-type       format 'X(3)':U  column-label "Тип"
      buf_temp-obj-info.obj-code       format '>>>>>>>>9':U column-label "Код"
      buf_temp-obj-info.brws-obj-name  format 'X(60)':U column-label "Название"
      buf_temp-obj-info.brws-db-num    format 'X(9)':U  column-label "БД"
      buf_temp-obj-info.brws-host-code format 'X(9)':U  column-label "Фирма"
      buf_temp-obj-info.brws-host-name format 'X(40)':U column-label "Название фирмы"
      buf_temp-obj-info.brws-curr-code format '>>>>9':U  column-label "Валюта"
ENABLE
      buf_temp-obj-info.obj-type
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 15.25 ROW-HEIGHT-CHARS .67.
DEFINE FRAME DIALOG-1
     b-exit AT ROW 1 COL 1
     mark-num AT ROW 1 COL 9.5 COLON-ALIGNED NO-LABEL
     b-mark AT ROW 1 COL 18
     b-select-all AT ROW 1 COL 21
     b-deselect-all AT ROW 1 COL 24
     b-sel AT ROW 1 COL 27
     b-show-obj AT ROW 1 COL 37
     b-show-host AT ROW 1 COL 47
     B-list AT ROW 1 COL 57
     b-action AT ROW 1 COL 67 WIDGET-ID 4
     b-menu AT ROW 1 COL 77 WIDGET-ID 6
     b-help AT ROW 1 COL 91
     b-add-sh AT ROW 2.08 COL 31
     b-add-st AT ROW 2.08 COL 41
     b-add-all AT ROW 2.08 COL 51
     b-del AT ROW 2.08 COL 61
     b-del-all AT ROW 2.08 COL 71 WIDGET-ID 2
     flt-code AT ROW 2.5 COL 12 COLON-ALIGNED
     br-obj AT ROW 3.75 COL 2
     SPACE(0.99) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Объекты пользователя":L.
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.
ASSIGN
       B-list:POPUP-MENU IN FRAME DIALOG-1       = MENU MENU-B-list:HANDLE.
ASSIGN
       br-obj:NUM-LOCKED-COLUMNS IN FRAME DIALOG-1     = 3.
ON GO OF FRAME DIALOG-1
DO:
  run choose-select in this-procedure
    no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
END.
ON CHOOSE OF b-action IN FRAME DIALOG-1
DO:
   if available buf_temp-obj-info
   then do:
        run str/usractn1.w ( INPUT parparentproc
                           , INPUT p-user-id
                           , INPUT p-db-num
                           , INPUT buf_temp-obj-info.obj-type
                           , INPUT buf_temp-obj-info.obj-code
                           ) NO-ERROR.
        if error-status :error
        then do:
               message
                     vss-workfile vss-revision vss-description
                  skip(1)
                  skip "Ошибка при изменении прав пользователя на объекте"
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
               view-as alert-box error.
           return no-apply.
        end .
   end.
END.
ON CHOOSE OF b-add-all IN FRAME DIALOG-1
DO:
  define variable rid as recid no-undo.
  define buffer buf_user-obj     for ub.user-obj.
  define buffer buf_clients      for ub.clients.
  define variable lok as logical   no-undo .
    message
    substitute( "Добавить пользователю &1 все объекты?"
              , usrnickf( p-user-id )
              )
    view-as alert-box question
    buttons OK-Cancel update g#log.
    if not g#log then return no-apply.
    if p-db-num <> 0 then do:
       FOR EACH buf_clients
           where buf_clients.db-num = p-db-num
           and ( buf_clients.obj-type = 'маг':U
              OR buf_clients.obj-type = 'скл':U
               )
           NO-LOCK:
          IF CAN-FIND (buf_user-obj where buf_user-obj.obj-type = buf_clients.obj-type
                                  and buf_user-obj.obj-code     = buf_clients.obj-code
                                  and buf_user-obj.user-id      = p-user-id
                                  AND buf_user-obj.db-num       = p-db-num
                                no-lock)
                                then next.
          run enbl-obj (buf_clients.obj-type, buf_clients.obj-code).
       end.
    end.
    else do:
       FOR EACH buf_clients
           where
               ( buf_clients.obj-type = 'маг':U
              OR buf_clients.obj-type = 'скл':U
               )
           NO-LOCK:
          IF CAN-FIND (buf_user-obj where buf_user-obj.obj-type = buf_clients.obj-type
                                  and buf_user-obj.obj-code     = buf_clients.obj-code
                                  and buf_user-obj.user-id      = p-user-id
                                  AND buf_user-obj.db-num       = p-db-num
                                no-lock)
                                then next.
          run enbl-obj (buf_clients.obj-type, buf_clients.obj-code).
       end.
    end.
    run enable_UI.
    run post_enable_UI in this-procedure.
    message
    substitute( "Пользователю &1 добавлены все объекты"
              , usrnickf( p-user-id )
              )
    view-as alert-box.
END.
ON CHOOSE OF b-add-sh IN FRAME DIALOG-1
DO:
  run ass-obj ('маг':U).
  run enable_UI.
  run post_enable_UI in this-procedure.
END.
ON CHOOSE OF b-add-st IN FRAME DIALOG-1
DO:
   run ass-obj ('скл':U).
   run enable_UI.
   run post_enable_UI in this-procedure.
END.
ON CHOOSE OF b-del IN FRAME DIALOG-1
DO:
   define variable v-ok                    as logical      no-undo .
   define variable v-message-text          as character    no-undo .
   define variable v-object-is-current     as logical      no-undo.
   define variable v-cntxt-valid           as logical      no-undo .
   define variable v-cntxt-menu-code       as integer      no-undo .
   define variable v-cntxt-menu-group-code as integer      no-undo .
   define variable v-cntxt-level           as character    no-undo .
   define variable v-cntxt-host-code-obj   as integer      no-undo .
   define variable v-cntxt-obj-type        as character    no-undo .
   define variable v-cntxt-obj-code        as integer      no-undo .
   define buffer buf_user-menu-group      for ub.user-menu-group.
   if available buf_temp-obj-info
   then do:
      assign
         v-ok = no
      .
      run gbl/cntxtget.p (
           INPUT  p-db-num
         , INPUT  p-user-id
         , OUTPUT v-cntxt-valid
         , OUTPUT v-cntxt-menu-code
         , OUTPUT v-cntxt-menu-group-code
         , OUTPUT v-cntxt-level
         , OUTPUT v-cntxt-host-code-obj
         , OUTPUT v-cntxt-obj-type
         , OUTPUT v-cntxt-obj-code
      ).
      if  v-cntxt-obj-type = buf_temp-obj-info.obj-type
      and v-cntxt-obj-code = buf_temp-obj-info.obj-code
      then do:
         assign
               v-message-text = "Удаляемый объект - текущий для данного пользователя.~n".
               v-object-is-current = yes
         .
      end.
      else do:
         assign
               v-object-is-current = no
         .
      end.
      assign
         v-message-text = v-message-text + "Удалить объект (сделать его недоступным для данного пользователя) ?"
      .
      message
         v-message-text
      view-as alert-box question
      buttons ok-cancel
      update v-ok.
      if v-ok = yes
      then do:
         run delete-record in this-procedure (
                 input buf_temp-obj-info.db-num
               , input buf_temp-obj-info.obj-type
               , input buf_temp-obj-info.obj-code
         ) no-error.
         if error-status :error
         then do:
               message
                     vss-workfile vss-revision vss-description
                  skip(1)
                  skip "Ошибка удаления записи."
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
               view-as alert-box error.
               undo, return no-apply.
         end.
         run enable_UI.
         run post_enable_UI in this-procedure.
      end.
   end.
END.
ON CHOOSE OF b-del-all IN FRAME DIALOG-1
DO:
   define buffer buf_user-obj    for ub.user-obj.
   define variable v-ok                    as logical      no-undo .
   define variable v-message-text          as character    no-undo .
   define variable v-cntxt-valid           as logical      no-undo .
   define variable v-cntxt-menu-code       as integer      no-undo .
   define variable v-cntxt-menu-group-code as integer      no-undo .
   define variable v-cntxt-level           as character    no-undo .
   define variable v-cntxt-host-code-obj   as integer      no-undo .
   define variable v-cntxt-obj-type        as character    no-undo .
   define variable v-cntxt-obj-code        as integer      no-undo .
   assign
      v-message-text = v-message-text + "Удалить объект (сделать его недоступным для данного пользователя) ?"
   .
   message
      v-message-text
   view-as alert-box question
   buttons ok-cancel
   update v-ok.
   if v-ok = yes
   then do:
      for each  buf_user-obj
         where buf_user-obj.db-num = p-db-num
            and buf_user-obj.user-id = p-user-id
         no-lock
         :
         run delete-record in this-procedure (
               input buf_user-obj.db-num
               , input buf_user-obj.obj-type
               , input buf_user-obj.obj-code
         ) no-error.
         if error-status :error
         then do:
               message
                     vss-workfile vss-revision vss-description
                  skip(1)
                  skip "Ошибка удаления записи."
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
               view-as alert-box error.
               undo, return no-apply.
         end.
         run enable_UI.
         run post_enable_UI in this-procedure.
      end.
   end.
END.
ON CHOOSE OF b-exit IN FRAME DIALOG-1
DO:
  run check-selection in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply.
  end.
END.
ON CHOOSE OF B-list IN FRAME DIALOG-1
DO:
  if v-list-option = ""
  then do:
    run gbl/pop-up.p (self:handle, no) no-error.
    if error-status:error then return no-apply.
  end.
  if v-list-option = ""
  then do:
    return no-apply.
  end.
  run proc-b-list in this-procedure
    (input v-list-option
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.
END.
ON CHOOSE OF b-mark IN FRAME DIALOG-1
DO:
  run choose-mark in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
END.
ON CHOOSE OF b-select-all IN FRAME DIALOG-1
DO:
  run choose-all in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
END.
ON CHOOSE OF b-deselect-all IN FRAME DIALOG-1
DO:
  run de-choose-all in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
END.
ON CHOOSE OF b-menu IN FRAME DIALOG-1
DO:
   if available buf_temp-obj-info
   then do:
        run str/usrmngr1.w ( INPUT parparentproc
                           , INPUT p-db-num
                           , INPUT p-user-id
                           , INPUT buf_temp-obj-info.obj-type
                           , INPUT buf_temp-obj-info.obj-code
                           ) NO-ERROR.
        if error-status :error
        then do:
               message
                     vss-workfile vss-revision vss-description
                  skip(1)
                  skip "Ошибка при изменении групп меню пользователя на объекте"
                  skip return-value
                  skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
               view-as alert-box error.
           return no-apply.
        end .
   end.
END.
ON CHOOSE OF b-show-host IN FRAME DIALOG-1
DO:
  define variable v-host-code as integer   no-undo .
  if available buf_temp-obj-info
  then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_temp-obj-info.obj-type
  ,input  buf_temp-obj-info.obj-code
  ,output v-host-code
  )  .
    run ref/showcli.p
      (input  parparentproc
      ,input  'орг':U
      ,input  v-host-code
      ) .
  end.
END.
ON CHOOSE OF b-show-obj IN FRAME DIALOG-1
DO:
  if available buf_temp-obj-info
  then do:
    run ref/showcli.p
      (input  parparentproc
      ,input  buf_temp-obj-info.obj-type
      ,input  buf_temp-obj-info.obj-code
      ) .
  end.
END.
ON VALUE-CHANGED OF br-obj IN FRAME DIALOG-1
DO:
  run update-br-obj-dependent in this-procedure .
END.
ON CTRL-J OF flt-code IN FRAME DIALOG-1
DO:
  define variable v-find-next as logical   no-undo .
  if flt-code <> input frame DIALOG-1 flt-code
  then do:
    assign
      v-find-next = false
    .
  end.
  else do:
    assign
      v-find-next = true
    .
  end.
  do with frame DIALOG-1:
    assign
      flt-code
    .
  end.
  run local-open-query in this-procedure
    (input false
    ,input v-find-next
    ,input substitute('and buf_temp-obj-info.obj-code = &1':U
                      ,flt-code
                      )
    ).
  apply "entry":u to self .
  return no-apply .
END.
ON RETURN OF flt-code IN FRAME DIALOG-1
DO:
  assign
    flt-code
  .
  run local-open-query in this-procedure
    (input false
    ,input false
    ,input substitute('and buf_temp-obj-info.obj-code = &1':U
                      ,flt-code
                      )
    ).
  apply "entry" to self .
  return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_list-export
DO:
  assign
    v-list-option = "save":U
  .
  run proc-b-list
    (input v-list-option
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.
END.
ON CHOOSE OF MENU-ITEM m_list-import
DO:
  assign
    v-list-option = "load":U
  .
  run proc-b-list in this-procedure
    (input v-list-option
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DIALOG-1:PARENT eq ?
THEN FRAME DIALOG-1:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DIALOG-1
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
on choose of b-help in frame DIALOG-1
do:
  apply "help":u to frame DIALOG-1 .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DIALOG-1:width - 0.3
                fh            = frame DIALOG-1:first-child
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame DIALOG-1 :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame DIALOG-1 :height-chars)
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
    if frame DIALOG-1 :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame DIALOG-1 :height-chars)
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
            frame DIALOG-1 :height = v-frame-height
          .
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame DIALOG-1 :height = v-frame-height
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
      v-frame-height = frame DIALOG-1 :height
      v-frame-virtual-height = frame DIALOG-1 :virtual-height
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
      v-field-group-handle = frame DIALOG-1 :first-child
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
    do with frame DIALOG-1
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-height = frame DIALOG-1 :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame DIALOG-1 :height = frame DIALOG-1 :height + p-change-value
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
        frame DIALOG-1 :height = frame DIALOG-1 :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-height = frame DIALOG-1 :virtual-height + p-change-value
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
          ,input  string(frame DIALOG-1 :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame DIALOG-1 :height)
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
    if frame DIALOG-1 :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame DIALOG-1 :width
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
    if frame DIALOG-1 :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame DIALOG-1 :width
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
            frame DIALOG-1 :width = v-frame-width
          .
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame DIALOG-1 :width = v-frame-width
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
      v-frame-width = frame DIALOG-1 :width
      v-frame-virtual-width = frame DIALOG-1 :virtual-width
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
      v-field-group-handle = frame DIALOG-1 :first-child
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
    do with frame DIALOG-1
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-width = frame DIALOG-1 :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame DIALOG-1 :width = v-frame-width + p-change-value
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
        frame DIALOG-1 :width = frame DIALOG-1 :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-width = frame DIALOG-1 :virtual-width + p-change-value
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
          ,input  string(frame DIALOG-1 :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame DIALOG-1 :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame DIALOG-1
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame DIALOG-1 :height - v-diasize-resize-button :height
                  - 1
                  - (frame DIALOG-1 :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame DIALOG-1 :width - v-diasize-resize-button :width
                  - 1
                  - (frame DIALOG-1 :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame DIALOG-1
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
      v-row-delta = v-new-row - frame DIALOG-1 :height
      v-col-delta = v-new-col - frame DIALOG-1 :width
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
            - frame DIALOG-1 :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame DIALOG-1 :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame DIALOG-1 :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame DIALOG-1 :height-chars
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
      v-diasize-current-frame-width  = frame DIALOG-1 :width
      v-diasize-current-frame-height = frame DIALOG-1 :height
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
    do with frame DIALOG-1
    :
      assign
        v-diasize-orig-frame-height = frame DIALOG-1 :height
        v-diasize-orig-frame-width  = frame DIALOG-1 :width
        v-diasize-browse-handle     = browse br-obj :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame DIALOG-1 :first-child
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-obj :SET-REPOSITIONED-ROW(6, "CONDITIONAL") .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame DIALOG-1 anywhere
do:
  run local-open-query in this-procedure   (input true   ,       input true   ,       input '':U   ) .
    apply "VALUE-CHANGED" to br-obj.
end.
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame DIALOG-1 anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame DIALOG-1. END.
  return no-apply.
end.
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame DIALOG-1 anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame DIALOG-1. END.
  return no-apply.
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-obj as INT EXTENT 7 no-undo.
DEF VAR varmvibr-obj       as INT no-undo.
DEF VAR varmvjbr-obj       as INT no-undo.
DEF VAR varmvkbr-obj       as INT no-undo.
DEF VAR varmvlbr-obj       as INT no-undo.
DEF VAR move-elementbr-obj as INT no-undo.
def var jjbr-obj           as int no-undo.
do varmvibr-obj = 1 to EXTENT(cur-clmn-numbr-obj):
  ASSIGN cur-clmn-numbr-obj[varmvibr-obj] = varmvibr-obj.
END.
RUN start-mv-clmnbr-obj.
PROCEDURE start-mv-clmnbr-obj:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-obj do:
  RUN re-move-clmnbr-obj ( 4, 7).
END.
ON ctrl-cursor-left OF BROWSE br-obj do:
  RUN re-move-clmnbr-obj (7, 4).
END.
PROCEDURE re-move-clmnbr-obj:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-obj = 1 TO EXTENT(cur-clmn-numbr-obj):
    if cur-clmn-numbr-obj[varmvibr-obj] = source-column THEN cur-clmn-numbr-obj[varmvibr-obj] = -1.
  END.
  if br-obj:MOVE-COLUMN(source-column, target-column) IN FRAME DIALOG-1 then.
  if source-column > target-column THEN
  DO varmvjbr-obj = source-column - 1 to target-column BY -1:
    DO varmvibr-obj = 1 TO EXTENT(cur-clmn-numbr-obj):
        if cur-clmn-numbr-obj[varmvibr-obj] = varmvjbr-obj THEN DO:
          cur-clmn-numbr-obj[varmvibr-obj] = cur-clmn-numbr-obj[varmvibr-obj] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-obj = source-column + 1 to target-column:
    DO varmvibr-obj = 1 TO EXTENT(cur-clmn-numbr-obj):
      if cur-clmn-numbr-obj[varmvibr-obj] = varmvjbr-obj THEN DO:
        cur-clmn-numbr-obj[varmvibr-obj] = cur-clmn-numbr-obj[varmvibr-obj] - 1.
      END.
    END.
  END.
  DO varmvibr-obj = 1 TO EXTENT(cur-clmn-numbr-obj):
    if cur-clmn-numbr-obj[varmvibr-obj] = -1 THEN cur-clmn-numbr-obj[varmvibr-obj] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-obj:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmvibr-obj = 1 TO EXTENT(cur-clmn-numbr-obj):
    if cur-clmn-numbr-obj[varmvibr-obj] = cur-clmn-loc THEN move-elementbr-obj = varmvibr-obj.
  END.
  RUN re-move-clmnbr-obj (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-obj:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-obj = 4 to EXTENT(cur-clmn-numbr-obj):
    RUN re-move-clmnbr-obj (cur-clmn-numbr-obj[varmvlbr-obj], varmvlbr-obj).
  END.
  RUN start-mv-clmnbr-obj.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelbr-obj   as character no-undo .
def var sort-clmnbr-obj    as handle    no-undo .
def var cur-clmnbr-obj     as handle    no-undo .
def var cur-clmn-locbr-obj as integer   no-undo .
def var re-querybr-obj     as logical   initial no no-undo .
on start-search, ctrl-o of br-obj in frame DIALOG-1 do:
   run sort-brbr-obj
     (input (if available buf_temp-obj-info
             then recid(buf_temp-obj-info)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-obj :
  define input parameter p-recid as recid no-undo .
  if re-querybr-obj = no then do:
    assign
       cur-clmnbr-obj = br-obj:current-column in frame DIALOG-1
    .
    if sort-clmnbr-obj <> ? then sort-clmnbr-obj:column-fgcolor = 0.
    if cur-clmnbr-obj = sort-clmnbr-obj then do:
      assign
         sort-labelbr-obj = ""
         sort-clmnbr-obj = ?
      .
     end.
     else do:
       assign
         sort-labelbr-obj = cur-clmnbr-obj:label
         sort-clmnbr-obj  = cur-clmnbr-obj
         sort-clmnbr-obj:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-obj = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-obj:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-obj then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-obj = cur-clmn-locbr-obj + 1
    .
  end.
  case sort-labelbr-obj:
        when v-brws-mark:label in browse br-obj then DO:   assign       v-sort-column-name = v-brws-mark     .     run local-open-query in this-procedure   (input true   ,       input true   ,       input '':U   ) .   . END.
        when buf_temp-obj-info.brws-obj-name:label in browse br-obj then DO:    assign       v-sort-column-name = "buf_temp-obj-info.brws-obj-name"     .     run local-open-query in this-procedure   (input true   ,       input true   ,       input '':U   ) .   . END.
        when buf_temp-obj-info.brws-db-num:label in browse br-obj then DO:    assign       v-sort-column-name = "buf_temp-obj-info.brws-db-num"     .     run local-open-query in this-procedure   (input true   ,       input true   ,       input '':U   ) .   . END.
        when buf_temp-obj-info.brws-host-code:label in browse br-obj then DO:    assign       v-sort-column-name = "buf_temp-obj-info.brws-host-code"     .     run local-open-query in this-procedure   (input true   ,       input true   ,       input '':U   ) .   . END.
        when buf_temp-obj-info.brws-host-name:label in browse br-obj then DO:    assign       v-sort-column-name = "buf_temp-obj-info.brws-host-name"     .     run local-open-query in this-procedure   (input true   ,       input true   ,       input '':U   ) .   . END.
        when buf_temp-obj-info.brws-curr-code:label in browse br-obj then DO:    assign       v-sort-column-name = "buf_temp-obj-info.brws-curr-code"     .     run local-open-query in this-procedure   (input true   ,       input true   ,       input '':U   ) .   . END.
    otherwise do:
      assign
        v-sort-column-name = ""
      .
      run local-open-query in this-procedure   (input true   ,       input true   ,       input '':U   ) .
      if sort-labelbr-obj <> "" then do:
        assign
          cur-clmnbr-obj:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-obj = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-obj to recid p-recid no-error.
    apply "value-changed" to br-obj in frame DIALOG-1.
  end.
  apply "entry" to br-obj in frame DIALOG-1.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-obj:
if cur-clmnbr-obj = ? then do:
   run local-open-query in this-procedure   (input true   ,       input true   ,       input '':U   ) .
end.
else do:
   assign re-querybr-obj = yes.
   run sort-brbr-obj
     (input (if available buf_temp-obj-info
             then recid(buf_temp-obj-info)
             else ?
            )
     ).
   assign re-querybr-obj = no.
end.
end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
on any-printable of browse br-obj
do:
  define variable v-number as integer   no-undo .
  assign
    v-number =  lookup(string(lastkey), string(keycode("0"))
                      + chr(44) + string(keycode("1"))
                      + chr(44) + string(keycode("2"))
                      + chr(44) + string(keycode("3"))
                      + chr(44) + string(keycode("4"))
                      + chr(44) + string(keycode("5"))
                      + chr(44) + string(keycode("6"))
                      + chr(44) + string(keycode("7"))
                      + chr(44) + string(keycode("8"))
                      + chr(44) + string(keycode("9"))
                      ) - 1
  .
  if v-number >= 0
  then do:
    do with frame DIALOG-1
    :
      assign
        flt-code :screen-value = string(v-number)
      .
    end.
    apply "entry":u to flt-code .
    apply "end":u to flt-code .
  end.
end.
define variable v-ok as logical   no-undo .
assign
  v-ok = browse br-obj :set-repositioned-row(5, 'CONDITIONAL':U)
.
ON WINDOW-CLOSE OF FRAME DIALOG-1 APPLY "END-ERROR":U TO SELF.
on return, MOUSE-SELECT-DBLCLICK of br-obj in frame DIALOG-1
do:
  if b-mark:sensitive
  then do:
    apply "choose" to b-mark in frame DIALOG-1.
  end.
  else do:
     if b-sel:sensitive
     then do:
       apply "choose" to b-sel in frame DIALOG-1.
     end.
  end.
end.
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame DIALOG-1 anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame DIALOG-1. END.
  return no-apply.
end.
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame DIALOG-1 anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame DIALOG-1. END.
  return no-apply.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
   ASSIGN
      FRAME DIALOG-1:TITLE = SUBSTITUTE ( "Объекты пользователя &1", usrnickf( p-user-id ) )
   .
  assign
    buf_temp-obj-info.obj-type :read-only in browse br-obj = true
  .
  run check-input-parameters in this-procedure
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "База данных" p-db-num skip
      "Идентификатор пользователя" p-user-id skip
      "Код фирмы" p-curr-host-code-obj skip
      "Объект" p-curr-obj-type p-curr-obj-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-user-select = false
  .
  run fill-temp-table in this-procedure .
  assign
    buf_temp-obj-info.brws-obj-name  :resizable in browse br-obj = true
    buf_temp-obj-info.brws-host-name :resizable in browse br-obj = true
  .
  define variable v-colwidth-data-exist as logical   no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run colwidth-read in this-procedure
  (input  p-db-num
  ,input  p-user-id
  ,input  'gbl/userobjs.w':U
  ,output v-colwidth-data-exist
  )  .
  if v-colwidth-data-exist = true
  then do:
    assign
      buf_temp-obj-info.brws-obj-name  :width in browse br-obj = 30
      buf_temp-obj-info.brws-host-name :width in browse br-obj = 35
    .
  end.
  else do:
    assign
      buf_temp-obj-info.brws-obj-name  :width in browse br-obj = 30
      buf_temp-obj-info.brws-host-name :width in browse br-obj = 35
    .
  end.
  RUN enable_UI .
  run post_enable_UI in this-procedure.
  if can-do ( p-bttns, "b-mark")
  then do:
    run userobjs_transfer in p-callback-handle
      (input this-procedure :handle
      ) .
    run display-select-num in this-procedure .
  end.
  else do:
    hide mark-num in frame DIALOG-1.
  end.
  assign
    b-list:menu-mouse in frame DIALOG-1 = 1
  .
  if p-curr-obj-type = "":U
  or p-curr-obj-type = ?
  or p-curr-obj-code = 0
  or p-curr-obj-code = ?
  then do:
    reposition br-obj to row 1 no-error .
  end.
  else do:
    define buffer buf_select_temp-obj-info for temp-obj-info .
    find first buf_select_temp-obj-info no-lock
      where buf_select_temp-obj-info.obj-type = p-curr-obj-type
        and buf_select_temp-obj-info.obj-code = p-curr-obj-code
      no-error .
    if available buf_select_temp-obj-info
    then do:
      reposition br-obj to rowid rowid(buf_select_temp-obj-info) no-error .
      if error-status :error
      then do:
        reposition br-obj to row 1 no-error .
      end.
    end.
  end.
  run update-br-obj-dependent in this-procedure .
  apply "entry" to br-obj in frame DIALOG-1.
  wait-for go of frame DIALOG-1 focus br-obj.
END.
assign
  v-colwidth-width-01 = buf_temp-obj-info.brws-obj-name  :width in browse br-obj
  v-colwidth-width-02 = buf_temp-obj-info.brws-host-name :width in browse br-obj
.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run colwidth-write in this-procedure
  .
RUN disable_UI.
PROCEDURE ass-obj :
  define input param o-type like ub.clients.obj-type no-undo.
  define variable rid-list as char init "" no-undo.
  define variable rid as recid no-undo.
  define variable num-rec as integer init 0 no-undo.
  define variable lok as logical   no-undo .
  define buffer buf_clients      for ub.clients .
  define buffer buf_user-obj     for ub.user-obj .
  define buffer buf_shop      for ub.shop .
  define buffer buf_store     for ub.store .
  define variable v-first-ubd    as logical      no-undo.
DO
ON ERROR   UNDO, RETURN ERROR
:
  case o-type :
    when 'скл':U then run adm/stores.w ( parparentproc
                                       , "b-sel,b-mark"
                                       , input-output rid-list
                                       , (if v-cntxt-db-num = 0 then no else yes)
                                       ) .
    when 'маг':U then run adm/shops.w  ( parparentproc
                                       , "b-sel,b-mark"
                                       , input-output rid-list
                                       , (if v-cntxt-db-num = 0 then no else yes)).
  end case.
  if rid-list <> ""
  then do :
    _shop:
    do num-rec = 1 to num-entries (rid-list):
      if o-type = 'маг':U
      then do:
        find buf_shop where recid (buf_shop) = integer (entry (num-rec, rid-list)) no-lock.
        find first buf_clients
             where buf_clients.obj-type = 'маг':U
               and buf_clients.obj-code = buf_shop.obj-code
        no-lock
        no-error
        .
        IF NOT AVAILABLE buf_clients THEN DO:
           NEXT _shop.
        END.
        IF  p-db-num  <> 0
        AND  buf_clients.db-num <> p-db-num
        then do:
         IF NOT v-first-ubd
         then do:
               assign
                  v-first-ubd = TRUE
               .
               message
                  "Будут добавлены только объекты текущей БД."
                  skip "Объекты других БД возможно добавлять только в ГБД."
               view-as alert-box information.
         end.
         next _shop.
        end.
        IF CAN-FIND (buf_user-obj where buf_user-obj.obj-type = buf_clients.obj-type
                                 and buf_user-obj.obj-code     = buf_clients.obj-code
                                 and buf_user-obj.user-id      = p-user-id
                                 AND buf_user-obj.db-num       = p-db-num
                              no-lock)
                              then next _shop.
        run enbl-obj (o-type, buf_shop.obj-code).
      end.
      else do:
        find buf_store where recid (buf_store) = integer (entry (num-rec, rid-list)) no-lock.
        find first buf_clients
             where buf_clients.obj-type = 'скл':U
               and buf_clients.obj-code = buf_store.obj-code
        no-lock
        no-error
        .
        IF NOT AVAILABLE buf_clients THEN DO:
           NEXT _shop.
        END.
        IF  p-db-num  <> 0
        AND  buf_clients.db-num <> p-db-num
        then do:
         IF NOT v-first-ubd
         then do:
               assign
                  v-first-ubd = TRUE
               .
               message
                  "Будут добавлены только объекты текущей БД."
                  skip "Объекты других БД возможно добавлять только в ГБД."
               view-as alert-box information.
         end.
         next _shop.
        end.
        IF CAN-FIND (buf_user-obj where buf_user-obj.obj-type = buf_clients.obj-type
                                 and buf_user-obj.obj-code     = buf_clients.obj-code
                                 and buf_user-obj.user-id      = p-user-id
                                 AND buf_user-obj.db-num       = p-db-num
                              no-lock)
                              then next _shop.
        run enbl-obj (o-type, buf_store.obj-code).
      end.
    end.
  end.
END.
END PROCEDURE.
PROCEDURE check-input-parameters :
  define buffer buf_user-login for ub.user-login .
  do
  on error undo, return error return-value
  :
    if p-db-num = ?
    then do:
      undo, return error "Не задан номер базы данных" .
    end.
    if p-user-id = ?
    or p-user-id = ""
    then do:
      undo, return error "Не задан идентификтор пользователя" .
    end.
    find first buf_user-login no-lock
      where buf_user-login.db-num  = p-db-num
        and buf_user-login.user-id = p-user-id
      no-error .
    if not available buf_user-login
    then do:
      undo, return error substitute("Не найден логин пользователя &1 &2"
                                   ,p-db-num
                                   ,p-user-id
                                   ) .
    end.
  end.
END PROCEDURE.
PROCEDURE check-selection :
  define variable v-ok as logical   no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    do with frame DIALOG-1
    :
      if can-do (p-bttns, "b-mark")
      then do:
        find first buf_temp-user-obj
          no-error .
        if available buf_temp-user-obj
        then do:
          message
            "Информация о выбранных элементах будет потеряна" Skip
            "Продолжить?" Skip
            view-as alert-box question buttons yes-no update v-ok .
          if v-ok = true
          then do:
            for each buf_temp-user-obj
            on error undo, return error return-value
            :
              delete buf_temp-user-obj .
            end.
          end.
          else do:
            undo, return error return-value .
          end.
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE choose-mark :
  define variable v-log as logical no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    if available buf_temp-obj-info
    then do:
      find first buf_temp-user-obj
        where buf_temp-user-obj.obj-type = buf_temp-obj-info.obj-type
          and buf_temp-user-obj.obj-code = buf_temp-obj-info.obj-code
        no-error .
      if available buf_temp-user-obj
      then do:
        run userobjs_delete in this-procedure
          (input  buf_temp-obj-info.obj-type
          ,input  buf_temp-obj-info.obj-code
          ) .
      end.
      else do:
        run userobjs_append in this-procedure
          (input  buf_temp-obj-info.obj-type
          ,input  buf_temp-obj-info.obj-code
          ) .
      end.
      v-log = br-obj:refresh() in frame DIALOG-1.
      if last-event :function <> "MOUSE-SELECT-DBLCLICK"
      then do:
        v-log = br-obj:select-next-row ().
        apply "iteration-changed" to br-obj in frame DIALOG-1.
      end.
      run display-select-num in this-procedure .
      apply "entry" to br-obj in frame DIALOG-1.
    end.
  end.
END PROCEDURE.
PROCEDURE choose-all :
  define variable v-log as logical no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    if available buf_temp-obj-info
    then do:
      for each buf_temp-obj-info no-lock :
        find first buf_temp-user-obj
          where buf_temp-user-obj.obj-type = buf_temp-obj-info.obj-type
            and buf_temp-user-obj.obj-code = buf_temp-obj-info.obj-code
          no-error .
        if not available buf_temp-user-obj
        then do:
          run userobjs_append in this-procedure
            (input  buf_temp-obj-info.obj-type
            ,input  buf_temp-obj-info.obj-code
            ) .
        end.
      end.
        v-log = br-obj:refresh() in frame DIALOG-1.
        run display-select-num in this-procedure .
        apply "entry" to br-obj in frame DIALOG-1.
    end.
  end.
END PROCEDURE.
PROCEDURE de-choose-all :
  define variable v-log as logical no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    if available buf_temp-obj-info
    then do:
      for each buf_temp-obj-info no-lock :
        find first buf_temp-user-obj
          where buf_temp-user-obj.obj-type = buf_temp-obj-info.obj-type
            and buf_temp-user-obj.obj-code = buf_temp-obj-info.obj-code
          no-error .
        if available buf_temp-user-obj
        then do:
          run userobjs_delete in this-procedure
            (input  buf_temp-obj-info.obj-type
            ,input  buf_temp-obj-info.obj-code
            ) .
        end.
      end.
        v-log = br-obj:refresh() in frame DIALOG-1.
        run display-select-num in this-procedure .
        apply "entry" to br-obj in frame DIALOG-1.
    end.
  end.
END PROCEDURE.
PROCEDURE choose-select :
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    do with frame DIALOG-1
    :
      if available buf_temp-obj-info
      then do:
        if NOT can-do (p-bttns, "b-mark")
        then do:
          assign
            p-select-obj-type = buf_temp-obj-info.obj-type
            p-select-obj-code = buf_temp-obj-info.obj-code
          .
        end.
        else do:
          find first buf_temp-user-obj
            no-error .
          if not available buf_temp-user-obj
          then do:
            run userobjs_append in this-procedure
              (input  buf_temp-obj-info.obj-type
              ,input  buf_temp-obj-info.obj-code
              ) .
          end.
          run userobjs_clear in p-callback-handle .
          for each buf_temp-user-obj
          on error undo, return error return-value
          :
            run userobjs_append in p-callback-handle
              (input  buf_temp-user-obj.obj-type
              ,input  buf_temp-user-obj.obj-code
              ) .
          end.
        end.
      end.
    end.
    assign
      p-user-select = true
    .
  end.
END PROCEDURE.
PROCEDURE delete-record :
define input parameter p-db-num     as integer          no-undo.
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
    define buffer buf_user-obj      for ub.user-obj.
    define buffer buf_temp-obj-info for temp-obj-info.
do
for buf_user-obj
  , buf_temp-obj-info
on error undo, return error
:
   find first buf_user-obj exclusive-lock
         WHERE buf_user-obj.db-num   = p-db-num
         AND buf_user-obj.user-id  = p-user-id
         AND buf_user-obj.obj-type = p-obj-type
         AND buf_user-obj.obj-code = p-obj-code
   no-error.
   if available buf_user-obj
   then do:
      delete buf_user-obj.
      find first buf_temp-obj-info
            where buf_temp-obj-info.obj-type = p-obj-type
               and buf_temp-obj-info.obj-code = p-obj-code
      .
      delete buf_temp-obj-info.
   end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE display-select-num :
  do
  on error undo, return error return-value
  :
    assign
      mark-num = v-total-select-num
    .
    if v-total-select-num = 0
    then do:
      hide
        mark-num
        in frame DIALOG-1.
    end.
    else do:
      display
        mark-num
        with frame DIALOG-1.
    end.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY mark-num flt-code
      WITH FRAME DIALOG-1.
  ENABLE b-exit b-sel b-show-obj b-show-host B-list b-action b-menu b-help
         b-add-sh b-add-st b-add-all b-del b-del-all flt-code br-obj
      WITH FRAME DIALOG-1.
  run local-open-query in this-procedure   (input true   ,       input true   ,       input '':U   ) .
END PROCEDURE.
PROCEDURE enbl-obj :
define input param o-type   as char no-undo.
define input param o-code   as integer no-undo.
    define variable v-host-code    as integer      no-undo.
    define variable v-host-name    as character    no-undo.
    define variable v-base-code    as integer      no-undo.
    define buffer buf_user-obj      for ub.user-obj.
    define buffer buf_user-host     for ub.user-host.
    define buffer buf_clients       for ub.clients.
do
for buf_user-obj
  , buf_user-host
  , buf_clients
on error undo, return error
:
    find first buf_user-obj exclusive-lock
         where buf_user-obj.db-num    = p-db-num
           and buf_user-obj.user-id   = p-user-id
           and buf_user-obj.obj-type  = o-type
           and buf_user-obj.obj-code  = o-code
    no-error.
    if not available buf_user-obj
    then do:
        find first buf_clients no-lock
             where buf_clients.obj-type = o-type
               and buf_clients.obj-code = o-code
        .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  o-type
  ,input  o-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
        create buf_user-obj.
        assign
            buf_user-obj.db-num    = p-db-num
            buf_user-obj.user-id   = p-user-id
            buf_user-obj.obj-type  = o-type
            buf_user-obj.obj-code  = o-code
            buf_user-obj.host-code = v-host-code
        .
        create buf_temp-obj-info .
        assign
            buf_temp-obj-info.obj-type        = o-type
            buf_temp-obj-info.obj-code        = o-code
            buf_temp-obj-info.db-num          = p-db-num
            buf_temp-obj-info.brws-obj-name   = buf_clients.obj-name
            buf_temp-obj-info.brws-db-num     = string(buf_clients.db-num)
            buf_temp-obj-info.brws-host-code  = string(buf_clients.host-code)
            buf_temp-obj-info.brws-host-name  = v-host-name
            buf_temp-obj-info.brws-curr-code  = v-base-code
        .
        find first buf_user-host exclusive-lock
             where buf_user-host.db-num    = p-db-num
               and buf_user-host.user-id   = p-user-id
               and buf_user-host.host-code = v-host-code
        no-error.
        if not available buf_user-host
        then do:
            create buf_user-host.
            assign
                buf_user-host.db-num    = p-db-num
                buf_user-host.user-id   = p-user-id
                buf_user-host.host-code = v-host-code
            .
        end.
   end.
end.
END PROCEDURE.
PROCEDURE fill-temp-table :
  define buffer buf_user-obj               for ub.user-obj .
  define buffer buf_action-post            for ub.action-post .
  define buffer buf_action-post-obj        for ub.action-post-obj .
  define buffer buf_action-post-user-login for ub.action-post-user-login .
  define buffer buf_temp-obj-info          for temp-obj-info .
  define variable v-check-db-num        as integer   no-undo .
  define variable v-check-user-id       as character no-undo .
  define variable v-check-administrator as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usercred in g#library2
  (input  p-db-num
  ,input  p-user-id
  ,output v-check-db-num
  ,output v-check-user-id
  ,output v-check-administrator
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры gbl/usercred.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_user-obj no-lock
      where buf_user-obj.db-num  = v-check-db-num
        and buf_user-obj.user-id = p-user-id
    on error undo, return error return-value
    :
      run temp-obj-info-append in this-procedure
        ( input buf_user-obj.obj-type
        , input buf_user-obj.obj-code
        , input buf_user-obj.db-num
        ) .
    end.
    for each buf_action-post-user-login no-lock
      where buf_action-post-user-login.db-num           = v-check-db-num
        and buf_action-post-user-login.action-head-code = 0
        and buf_action-post-user-login.user-id          = p-user-id
    on error undo, return error return-value
    :
      for each buf_action-post-obj no-lock
        where buf_action-post-obj.db-num           = buf_action-post-user-login.db-num
          and buf_action-post-obj.action-head-code = buf_action-post-user-login.action-head-code
          and buf_action-post-obj.action-post-code = buf_action-post-user-login.action-post-code
      on error undo, return error return-value
      :
        run temp-obj-info-append in this-procedure
          ( input buf_user-obj.obj-type
          , input buf_user-obj.obj-code
          , input buf_user-obj.db-num
          ) .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE get-mark-string :
  define input  parameter p-obj-type    as character no-undo .
  define input  parameter p-obj-code    as integer   no-undo .
  define output parameter p-mark-string as character no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_temp-user-obj
      where buf_temp-user-obj.obj-type = p-obj-type
        and buf_temp-user-obj.obj-code = p-obj-code
      no-error .
    if available buf_temp-user-obj
    then do:
      assign
        p-mark-string = '*':U
      .
    end.
    else do:
      assign
        p-mark-string = '':U
      .
    end.
  end.
END PROCEDURE.
PROCEDURE local-open-query :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable v-restore-position   as logical   no-undo .
  define variable v-current-obj-type   as character no-undo .
  define variable v-current-obj-code   as integer   no-undo .
  define variable v-prt-rec            as recid     no-undo .
  define variable v-sort-column-phrase as character no-undo .
  define buffer buf_reposition_temp-obj-info for temp-obj-info .
  do
  on error undo, return error return-value
  :
    if available buf_temp-obj-info
    then do:
      assign
        v-restore-position = true
        v-current-obj-type = buf_temp-obj-info.obj-type
        v-current-obj-code = buf_temp-obj-info.obj-code
      .
    end.
    else do:
      assign
        v-restore-position = false
        v-current-obj-type = '':U
        v-current-obj-code = 0
      .
    end.
    if v-sort-column-name <> '':U
    then do:
      case v-sort-column-name
      :
        when 'v-brws-mark':U
        then do:
          assign
            v-sort-column-phrase = 'by mark-string(buf_temp-obj-info.obj-type, buf_temp-obj-info.obj-code) by buf_temp-obj-info.obj-type by buf_temp-obj-info.obj-code':U
          .
        end.
        when 'temp-obj-info.brws-obj-name':U
        then do:
          assign
            v-sort-column-phrase = 'by buf_temp-obj-info.brws-obj-name by buf_temp-obj-info.obj-type by buf_temp-obj-info.obj-code':U
          .
        end.
        when 'temp-obj-info.brws-db-num':U
        then do:
          assign
            v-sort-column-phrase = 'by buf_temp-obj-info.brws-db-num by buf_temp-obj-info.obj-type by buf_temp-obj-info.obj-code':U
          .
        end.
        when 'temp-obj-info.brws-host-code':U
        then do:
          assign
            v-sort-column-phrase = 'by buf_temp-obj-info.brws-host-code by buf_temp-obj-info.obj-type by buf_temp-obj-info.obj-code':U
          .
        end.
        when 'temp-obj-info.brws-host-name':U
        then do:
          assign
            v-sort-column-phrase = 'by buf_temp-obj-info.brws-host-name by buf_temp-obj-info.obj-type by buf_temp-obj-info.obj-code':U
          .
        end.
        otherwise do:
          assign
            v-sort-column-phrase = substitute('by &1':U
                                             ,v-sort-column-name
                                             )
          .
        end.
      end case.
    end.
    else do:
      assign
        v-sort-column-phrase = '':U
      .
    end.
    define variable v-query-was-opened as logical   no-undo .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-27  as logical   no-undo .
define variable  l-filter-open-27    as logical   .
define variable  flt-rec-27       as recid     no-undo .
define variable  filter-name-27      as character no-undo .
define variable  where-phrase-27     as character no-undo .
define variable  sort-phrase-27      as character no-undo .
define variable  where-phrase-rus-27 as character no-undo .
define variable  sort-phrase-rus-27  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input 'userobjs':U
  ,output flt-rec-27
  ,output filter-name-27
  ,output where-phrase-27
  ,output sort-phrase-27
  ,output where-phrase-rus-27
  ,output sort-phrase-rus-27
  ).
if p-open-query then do:
  assign
    l-filter-open-27 = false
  .
  if flt-rec-27 <> ?
    or v-sort-column-phrase > ""
  then do:
    define variable  parameter-2-27 as character no-undo .
    define variable  parameter-3-27 as character no-undo .
    define variable  parameter-4-27 as character no-undo .
    define variable  parameter-5-27 as character no-undo .
    define variable  parameter-6-27 as character no-undo .
    define variable  parameter-7-27 as character no-undo .
      assign
      parameter-3-27 =
                              "for each buf_temp-obj-info"
      parameter-4-27 =
        (
          if (" yes " + " " + where-phrase-27) <> ""
          then  Substitute('&1', yes )  + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + "")
      parameter-6-27 = if sort-phrase-27 = ''
                           then
        (
        " " + "  " +
          " " + v-sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + v-sort-column-phrase +
        " " + sort-phrase-27
        )
      parameter-7-27 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-27 =
          (" yes " + " " + where-phrase-27 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-obj:handle
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
                          )
      .
      assign
        l-filter-open-27 = true
      .
    end.
    if l-filter-open-27 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          v-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-27 = false then do:
    open query br-obj for each buf_temp-obj-info
      where  yes
      indexed-reposition
  .
      assign
        v-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-prt-rec = recid( buf_temp-obj-info )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-obj:handle:get-buffer-handle(1) = (buffer buf_temp-obj-info:handle) then do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-4-27 =
        "where ":u +  Substitute('&1', yes )  + " ":u + where-phrase-27 + " ":u + p-find-condition + " " + ""
      parameter-5-27 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-obj:handle
                          ,input rowid(buf_temp-obj-info)
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input (buffer buf_temp-obj-info:handle)
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ) no-error.
      .
      assign
        v-prt-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-27 = (if p-find-next then "true":u else "false":u )
      parameter-3-27 =  "for each buf_temp-obj-info"
      parameter-4-27 =
        (
          if (" yes " + " " + where-phrase-27) <> ""
          then  Substitute('&1', yes )  + " " + where-phrase-27
          else "true"
        )
      parameter-5-27 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-27 = if sort-phrase-27 = ''
                           then
        (
        " " + "  " +
          " " + v-sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + "  " +
          " " + v-sort-column-phrase +
        " " + sort-phrase-27
        )
      parameter-7-27 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-obj:handle
                          ,input logical(parameter-2-27)
                          ,input no-lock
                          ,input parameter-3-27
                          ,input parameter-4-27
                          ,input parameter-5-27
                          ,input parameter-6-27
                          ,input parameter-7-27
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-prt-rec = ?.
    end.
    assign
      v-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
    if p-open-query = true
    then do:
      if v-restore-position = true
      then do:
        find first buf_reposition_temp-obj-info
          where buf_reposition_temp-obj-info.obj-type = v-current-obj-type
            and buf_reposition_temp-obj-info.obj-code = v-current-obj-code
          no-error .
        if available buf_reposition_temp-obj-info
        then do:
          reposition br-obj to rowid rowid(buf_reposition_temp-obj-info) no-error .
          if error-status :error
          then do:
            reposition br-obj to row 1 no-error .
          end.
        end.
      end.
    end.
    else do:
      if v-prt-rec <> ?
      then do:
        reposition br-obj to recid v-prt-rec no-error .
        if error-status :error
        then do:
          reposition br-obj to row 1 no-error .
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE post_enable_ui :
do
on error undo, return error
:
  disable all
  with frame DIALOG-1.
  ENABLE
    b-exit
    b-help
    br-obj
    b-show-obj
    b-show-host
    b-action
    b-menu
    b-mark          when can-do (p-bttns, "b-mark")
    b-select-all    when can-do (p-bttns, "b-mark")
    b-deselect-all  when can-do (p-bttns, "b-mark")
    b-list          when can-do (p-bttns, "b-mark")
    mark-num        when can-do (p-bttns, "b-mark")
    b-add-sh        when can-do (p-bttns, "b-add")
    b-add-st        when can-do (p-bttns, "b-add")
    b-add-all       when can-do (p-bttns, "b-add")
    b-del           when can-do (p-bttns, "b-add")
    b-sel           when can-do (p-bttns, "b-sel")
    flt-code
    with frame DIALOG-1.
end.
END PROCEDURE.
PROCEDURE proc-b-list :
  define input parameter loc-list-option as character no-undo.
  define variable f-name as char init "default.cli" no-undo.
  define variable imp-type like ub.goods.prod-type no-undo.
  define variable imp-code like ub.goods.prod-code no-undo.
  define variable v-ok as logical no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  define buffer buf_temp-obj-info for temp-obj-info .
  do
  on error undo, return error return-value
  :
    case loc-list-option:
      when "save":U
      then do:
        assign
          v-ok = true
        .
        message
          "Сохранить все отмеченные объекты в файле списка" skip
          "Продолжить?" skip
          view-as alert-box question buttons OK-Cancel update v-ok .
        if v-ok <> true
        then do:
          assign
            v-list-option = "":U
          .
          return .
        end.
        assign
          f-name = "default.cli"
          v-ok   = true
        .
        system-dialog get-file f-name
          filters "Списки клиентов *.cli" "*.cli"
          ask-overwrite
          save-as
          use-filename
          update v-ok
          default-extension "cli".
        if v-ok <> true
        then do:
          assign
            v-list-option = "":U
          .
          return .
        end.
        output stream sout to value (f-name).
        for each buf_temp-user-obj
        on error undo, return error return-value
        :
          export stream sout
            buf_temp-user-obj.obj-type
            buf_temp-user-obj.obj-code
          .
        end.
        output stream sout close.
      end.
      when "load":U
      then do:
        assign
          v-ok = yes
        .
        message
          "Отметить все объекты из ранее сохраненного в файле списка." skip
          "Продложить?" skip
          view-as alert-box question buttons ok-cancel update v-ok .
        if v-ok <> true
        then do:
          assign
            v-list-option = "":U
          .
          return.
        end.
        system-dialog get-file f-name
          filters "Списки клиентов *.cli" "*.cli"
          title "Выберите файл списка"
          initial-dir "."
          return-to-start-dir
          must-exist
          update v-ok
          default-extension "cli".
        if v-ok <> true
        then do:
          assign
            v-list-option = "":U
          .
          return.
        end.
        input stream sout from value (f-name).
        repeat
        :
          assign
            imp-type = '':U
            imp-code = 0
          .
          import stream sout imp-type imp-code .
          find first buf_temp-obj-info no-lock
            where buf_temp-obj-info.obj-type = imp-type
              and buf_temp-obj-info.obj-code = imp-code
            no-error .
          if available buf_temp-obj-info
          then do:
            run userobjs_append in this-procedure
              (input  buf_temp-obj-info.obj-type
              ,input  buf_temp-obj-info.obj-code
              ) .
          end.
        end.
        input stream sout close.
        run display-select-num in this-procedure .
        apply "entry" to br-obj in frame DIALOG-1.
      end.
      otherwise do:
      end.
    END CASE.
    loc-list-option = "":U.
  end.
END PROCEDURE.
PROCEDURE temp-obj-info-append :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-db-num   as integer   no-undo .
  define buffer buf_temp-obj-info for temp-obj-info .
  define buffer buf_obj_clients   for ub.clients .
  do
  on error undo, return error return-value
  :
    find first buf_temp-obj-info
      where buf_temp-obj-info.obj-type = p-obj-type
        and buf_temp-obj-info.obj-code = p-obj-code
      no-error .
    if not available buf_temp-obj-info
    then do:
      find first buf_obj_clients no-lock
        where buf_obj_clients.obj-type = p-obj-type
          and buf_obj_clients.obj-code = p-obj-code
        .
      define variable v-host-code as integer   no-undo .
      define variable v-host-name as character no-undo .
      define variable v-base-code as integer no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
      create buf_temp-obj-info .
      assign
        buf_temp-obj-info.obj-type        = p-obj-type
        buf_temp-obj-info.obj-code        = p-obj-code
        buf_temp-obj-info.db-num          = p-db-num
        buf_temp-obj-info.brws-obj-name   = buf_obj_clients.obj-name
        buf_temp-obj-info.brws-db-num     = string(buf_obj_clients.db-num)
        buf_temp-obj-info.brws-host-code  = string(v-host-code)
        buf_temp-obj-info.brws-host-name  = v-host-name
        buf_temp-obj-info.brws-curr-code  = v-base-code
      .
    end.
  end.
END PROCEDURE.
PROCEDURE update-br-obj-dependent :
  do
  on error undo, return error return-value
  :
    do with frame DIALOG-1
    :
      if available buf_temp-obj-info
      then do:
        display
          buf_temp-obj-info.obj-code @ flt-code
          with frame DIALOG-1.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE userobjs_append :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_temp-user-obj
      where buf_temp-user-obj.obj-type = p-obj-type
        and buf_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_temp-user-obj
    then do:
      create buf_temp-user-obj .
      assign
        buf_temp-user-obj.obj-type = p-obj-type
        buf_temp-user-obj.obj-code = p-obj-code
      .
      assign
        v-total-select-num = v-total-select-num + 1
      .
    end.
  end.
END PROCEDURE.
PROCEDURE userobjs_delete :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_temp-user-obj
      where buf_temp-user-obj.obj-type = p-obj-type
        and buf_temp-user-obj.obj-code = p-obj-code
      no-error .
    if available buf_temp-user-obj
    then do:
      delete buf_temp-user-obj .
      assign
        v-total-select-num = v-total-select-num - 1
      .
    end.
  end.
END PROCEDURE.
FUNCTION mark-string RETURNS CHARACTER
  ( p-obj-type as character, p-obj-code as integer ) :
  define variable v-mark-string as character no-undo .
  run get-mark-string in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,output v-mark-string
    ) .
  return v-mark-string .
END FUNCTION.
