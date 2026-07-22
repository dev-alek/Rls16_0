block-level on error undo, throw.
define input  parameter parparentproc       as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sndusrnw.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/sndusrnw.p $":U .
define variable vss-description as character no-undo init "Отправить настройки пользователя - права, меню по новостям".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-ind as integer   no-undo .
define variable v-ok  as logical   no-undo .
define buffer buf_user-account           for ub.user-account .
define buffer buf_user-login             for ub.user-login .
define buffer buf_user-menu-group        for ub.user-menu-group .
define buffer buf_user-host              for ub.user-host .
define buffer buf_user-obj               for ub.user-obj .
define buffer buf_user-login-attr        for ub.user-login-attr .
define buffer buf_action-role            for ub.action-role .
define buffer buf_action-role-item       for ub.action-role-item .
define buffer buf_action-post            for ub.action-post .
define buffer buf_action-post-obj        for ub.action-post-obj .
define buffer buf_action-post-host       for ub.action-post-host .
define buffer buf_action-post-role       for ub.action-post-role .
define buffer buf_action-post-user-login for ub.action-post-user-login .
define buffer buf_user-login-action-role for ub.user-login-action-role .
define buffer buf_user-login-action-item for ub.user-login-action-item .
define buffer buf_action-post-menu-group for ub.action-post-menu-group .
do
on error undo, return error return-value
:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  message
    vss-description
    "Продолжить?"
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return .
  end.
  if v-cntxt-db-num = 0
  then do:
    for each buf_user-account exclusive-lock
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'user-account':U
        ,input (buffer buf_user-account :handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
  end.
  else do:
    for each buf_user-account exclusive-lock
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'user-account':U
        ,input (buffer buf_user-account :handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_user-login exclusive-lock
      where buf_user-login.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'user-login':U
        ,input (buffer buf_user-login:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_user-menu-group exclusive-lock
      where buf_user-menu-group.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'user-menu-group':U
        ,input (buffer buf_user-menu-group:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_user-host exclusive-lock
      where buf_user-host.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'user-host':U
        ,input (buffer buf_user-host:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_user-obj exclusive-lock
      where buf_user-obj.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'user-obj':U
        ,input (buffer buf_user-obj:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_user-login-attr exclusive-lock
      where buf_user-login-attr.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'user-login-attr':U
        ,input (buffer buf_user-login-attr:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_action-role exclusive-lock
      where buf_action-role.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'action-role':U
        ,input (buffer buf_action-role:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_action-role-item exclusive-lock
      where buf_action-role-item.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'action-role-item':U
        ,input (buffer buf_action-role-item:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_action-post exclusive-lock
      where buf_action-post.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'action-post':U
        ,input (buffer buf_action-post:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_action-post-obj exclusive-lock
      where buf_action-post-obj.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'action-post-obj':U
        ,input (buffer buf_action-post-obj:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_action-post-host exclusive-lock
      where buf_action-post-host.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'action-post-host':U
        ,input (buffer buf_action-post-host:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_action-post-role exclusive-lock
      where buf_action-post-role.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'action-post-role':U
        ,input (buffer buf_action-post-role:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_action-post-user-login exclusive-lock
      where buf_action-post-user-login.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'action-post-user-login':U
        ,input (buffer buf_action-post-user-login:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_user-login-action-role exclusive-lock
      where buf_user-login-action-role.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'user-login-action-role':U
        ,input (buffer buf_user-login-action-role:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_user-login-action-item exclusive-lock
      where buf_user-login-action-item.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'user-login-action-item':U
        ,input (buffer buf_user-login-action-item:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
    for each buf_action-post-menu-group exclusive-lock
      where buf_action-post-menu-group.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input 'action-post-menu-group':U
        ,input (buffer buf_action-post-menu-group:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
  end.
  run waitfram-hide in this-procedure .
  message
    vss-description skip
    "Утилита закончила работу" skip
    "Отправлено записей" v-ind skip
    view-as alert-box information .
end.
