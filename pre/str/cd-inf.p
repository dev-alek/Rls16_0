block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-interface as logical no-undo.
define input parameter p-run as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информация по имеющимся отложенным заданиям отсылки на кассу".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-notes as character no-undo .
define variable v-gds-note as character no-undo .
define variable v-dcard-note as character no-undo .
define variable v-seller-note as character no-undo .
define variable v-cashier-note as character no-undo .
define variable v-fgrp-note as character no-undo .
define variable v-gds as logical no-undo .
define variable v-dcard as logical no-undo .
define variable v-seller as logical no-undo .
define variable v-cashier as logical no-undo .
define variable v-choice as integer no-undo .
define variable v-fgrp as logical no-undo .
define variable v-gds-date as date no-undo init 12/31/9999.
define variable v-gds-time as integer no-undo  init 86399.
define buffer buf_BatchProcess for ub.batchProcess .
define buffer buf_user-login for ub.user-login .
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
find first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = 'gds':U
        and buf_BatchProcess.bp_status     = 'N':U
        use-INDEX XPKN477 no-error .
if avail buf_BatchProcess then do:
    find first buf_user-login where buf_user-login.user-id = buf_BatchProcess.User_ID no-error.
  assign
  v-gds-note = "Самое старое задание на пересылку товара на кассу" + chr(10) +
               "от" + chr(32) +
               string(buf_BatchProcess.BP_SysDate, "99/99/9999":U) + chr(32) +
               buf_BatchProcess.BP_SysTime  + chr(10) +
               "Пользователь" + chr(32) +
               (if available buf_user-login then buf_user-login.User-login else "Логин удален с user-id = " + buf_BatchProcess.User_ID)
  v-gds-date = buf_BatchProcess.BP_SysDate
  v-gds-time = buf_BatchProcess.BP_SysTimeInt
  v-gds = yes
  .
end.
else do:
  assign
  v-gds-note = "Нет отложенных заданий на пересылку товара на кассу"
  .
end.
find first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = 'goa':U
        and buf_BatchProcess.bp_status     = 'N':U
        use-INDEX XPKN477 no-error .
if avail buf_BatchProcess then do:
  if buf_BatchProcess.BP_SysDate < v-gds-date
  OR (buf_BatchProcess.BP_SysDate = v-gds-date
  AND buf_BatchProcess.BP_SysTimeInt < v-gds-time) then do:
      find first buf_user-login where buf_user-login.user-id = buf_BatchProcess.User_ID no-error.
    assign
    v-gds-note = "Самое старое задание на пересылку товара на кассу" + chr(10) +
                "от" + chr(32) +
                string(buf_BatchProcess.BP_SysDate, "99/99/9999":U) + chr(32) +
                buf_BatchProcess.BP_SysTime  + chr(10) +
                "Пользователь" + chr(32) +
                (if available buf_user-login then buf_user-login.User-login else "Логин удален с user-id = " + buf_BatchProcess.User_ID)
    .
  end.
  assign
  v-gds = yes
  .
end.
find first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = 'dcard':U
        and buf_BatchProcess.bp_status     = 'N':U
        use-INDEX XPKN477 no-error .
if avail buf_BatchProcess then do:
        find first buf_user-login where buf_user-login.user-id = buf_BatchProcess.User_ID no-error.
  assign
  v-dcard-note = "Самое старое задание на пересылку информации о клиенте (карте) на кассу" + chr(10) +
               "от" + chr(32) +
               string(buf_BatchProcess.BP_SysDate, "99/99/9999":U) + chr(32) +
               buf_BatchProcess.BP_SysTime  + chr(10) +
               "Пользователь" + chr(32) +
               (if available buf_user-login then buf_user-login.User-login else "Логин удален с user-id = " + buf_BatchProcess.User_ID)
  v-dcard = yes
               .
end.
else do:
  assign
  v-dcard-note = "Нет отложенных заданий на пересылку клиентов (карт) на кассу"
  .
end.
find first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = 'slr':U
        and buf_BatchProcess.bp_status     = 'N':U
        use-INDEX XPKN477 no-error .
if avail buf_BatchProcess then do:
        find first buf_user-login where buf_user-login.user-id = buf_BatchProcess.User_ID no-error.
  assign
  v-seller-note = "Самое старое задание на пересылку информации о продавце на кассу" + chr(10) +
               "от" + chr(32) +
               string(buf_BatchProcess.BP_SysDate, "99/99/9999":U) + chr(32) +
               buf_BatchProcess.BP_SysTime  + chr(10) +
               "Пользователь" + chr(32) +
               (if available buf_user-login then buf_user-login.User-login else "Логин удален с user-id = " + buf_BatchProcess.User_ID)
               .
  v-seller = yes
               .
end.
else do:
  assign
  v-seller-note = "Нет отложенных заданий на пересылку продавцов на кассу"
  .
end.
find first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = 'cshr':U
        and buf_BatchProcess.bp_status     = 'N':U
        use-INDEX XPKN477 no-error .
if avail buf_BatchProcess then do:
        find first buf_user-login where buf_user-login.user-id = buf_BatchProcess.User_ID no-error.
  assign
  v-cashier-note = "Самое старое задание на пересылку информации о кассире на кассу" + chr(10) +
               "от" + chr(32) +
               string(buf_BatchProcess.BP_SysDate, "99/99/9999":U) + chr(32) +
               buf_BatchProcess.BP_SysTime  + chr(10) +
               "Пользователь" + chr(32) +
               (if available buf_user-login then buf_user-login.User-login else "Логин удален с user-id =" + buf_BatchProcess.User_ID)
  v-cashier = yes
               .
end.
else do:
  assign
  v-cashier-note = "Нет отложенных заданий на пересылку продавцов на кассу"
  .
end.
find first  buf_BatchProcess no-lock
      where buf_BatchProcess.bp_type       = 'fgrp':U
        and buf_BatchProcess.bp_status     = 'N':U
        use-INDEX XPKN477 no-error .
if avail buf_BatchProcess then do:
        find first buf_user-login where buf_user-login.user-id = buf_BatchProcess.User_ID no-error.
  assign
  v-fgrp-note = "Самое старое задание на пересылку информации о группе блюд на кассу" + chr(10) +
               "от" + chr(32) +
               string(buf_BatchProcess.BP_SysDate, "99/99/9999":U) + chr(32) +
               buf_BatchProcess.BP_SysTime  + chr(10) +
               "Пользователь" + chr(32) +
               (if available buf_user-login then buf_user-login.User-login else "Логин удален с user-id =" + buf_BatchProcess.User_ID)
  v-fgrp = yes
               .
end.
else do:
  assign
  v-fgrp-note = "Нет отложенных заданий на пересылку групп блюд на кассу"
  .
end.
assign
v-notes = v-gds-note
v-notes = (if v-notes = "":U then "":U else (v-notes + chr(10) + chr(10))) + v-dcard-note
v-notes = (if v-notes = "":U then "":U else (v-notes + chr(10) + chr(10))) + v-seller-note
v-notes = (if v-notes = "":U then "":U else (v-notes + chr(10) + chr(10))) + v-cashier-note
v-notes = (if v-notes = "":U then "":U else (v-notes + chr(10) + chr(10))) + v-fgrp-note
.
if p-interface then
run gbl/showtext.p (
                 input "Отложенные задания пересылки на кассу"
                ,input 80
                ,input 15
                ,input v-notes
                ).
if not p-run then return.
run str/cd-askw.w (
               input parparentproc
              ,input v-cntxt-obj-type
              ,input v-cntxt-obj-code
              ,input-output v-gds
              ,input-output v-dcard
              ,input-output v-seller
              ,input-output v-cashier
              ,input-output v-fgrp
              ,input v-gds-note
              ,input v-dcard-note
              ,input v-seller-note
              ,input v-cashier-note
              ,input v-fgrp-note
              ) no-error .
if error-status:error
or return-value = "error":U
or not (v-gds or v-dcard or v-seller or v-cashier)
then return.
run str/diallog.w (   parparentproc
              , this-procedure
              , 'str/sendalcd.p':U
              , (string(v-gds) + chr(4) +
                 string(v-dcard) + chr(4) +
                 string(v-seller) + chr(4) +
                 string(v-cashier) + chr(4)  +
                 string(v-fgrp) + chr(4)
                   )
              , no
              , 'Прервать':U
              , 'Отправка информации на кассу') no-error .
