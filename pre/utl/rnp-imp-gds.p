block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko$":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rnp-imp-gds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rnp-imp-gds.p $":U .
define variable vss-description as character no-undo init "Импорт товаров РН-Питер".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure ggoattr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
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
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
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
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
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
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
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
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
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
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-attr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
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
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
  define new shared temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
FIELD fact-date like ub.tax-rate-value.fact-date
FIELD fact-order like ub.tax-rate-value.fact-order
FIELD next-order like ub.tax-rate-value.fact-order
FIELD corr-user-name like ub.tax-rate-gds.corr-user-name
FIELD corr-user-db-num   like ub.tax-rate-gds.corr-user-db-num
FIELD corr-date like ub.tax-rate-gds.corr-date
FIELD corr-time like ub.tax-rate-gds.corr-time
index tax-code is unique primary tax-code fact-order descending rate-code.
define new shared buffer goods for goods.
define buffer first_gds-grp for ub.gds-grp.
define new shared stream gds-file.
define stream str-log .
define variable custvalue      as character no-undo.
define variable custtype       as character no-undo.
define variable tnvedimp as logical no-undo init no.
define variable f-name as char no-undo.
define variable impc as integer no-undo.
define variable impc-saved as integer no-undo.
define variable impc-Warn as integer no-undo.
define variable not-saved as character no-undo.
define new shared variable text-string as char no-undo.
define variable old-text-string as char no-undo init ?.
define variable p-artic     AS integer NO-UNDO init 1.
define variable p-name      AS integer NO-UNDO init 2.
define variable p-engl-name AS integer NO-UNDO.
define variable p-SLT-code  AS integer NO-UNDO.
define variable p-VAT-code  AS integer NO-UNDO.
define variable p-unit-base AS integer NO-UNDO.
define variable p-struct AS integer NO-UNDO.
define variable p-prod AS integer NO-UNDO.
define variable p-tnved as integer no-undo .
define variable p-attrib as integer no-undo .
define variable p-destin as integer no-undo .
define variable p-sert as integer no-undo .
define variable p-user-rule as integer no-undo .
define variable p-alpha1 as integer no-undo .
define variable p-grp-code as integer no-undo .
define variable p-service as integer no-undo .
define variable p-gds-code as integer no-undo .
define variable p-ppr as integer no-undo .
define variable i-artic as char no-undo.
define variable i-prod-type as character no-undo .
define variable i-prod-code as integer no-undo .
define variable i-gds-name as char no-undo.
define variable i-engl-name as char no-undo.
define variable i-SLT-code as integer no-undo.
define variable i-unit-base as char no-undo.
define variable i-VAT-code as integer no-undo.
define variable i-struct as character no-undo.
define variable i-tnved like ub.goods.tnved no-undo .
define variable i-attrib like ub.goods.attrib no-undo .
define variable i-destin like ub.goods.destin no-undo .
define variable i-sert like ub.goods.sert no-undo .
define variable i-user-rule like ub.goods.user-rule no-undo .
define variable i-alpha1 like ub.goods.alpha1 no-undo .
define variable i-grp-code like ub.goods.grp-code no-undo .
define variable i-service as logical no-undo .
define variable i-gds-code like ub.goods.gds-code no-undo .
define variable choice as integer no-undo.
define variable v-num-fields as integer no-undo .
define variable p-mark as integer no-undo .
define variable i-mark as integer  no-undo .
define variable p-nomcode as integer no-undo .
define variable i-nomcode as character  no-undo .
define variable i-ppr as integer no-undo .
define variable mnewrec as logical no-undo.
define variable v-host-code     as integer           no-undo.
define variable v-recid         as recid             no-undo.
define variable NDS like  tax-rate-value.rate-value  no-undo .
define variable NP like  tax-rate-value.rate-value  no-undo .
define variable j-gds-code like goods.gds-code NO-UNDO.
DEFINE VARIABLE mExcelApplication AS COMPONENT-HANDLE NO-UNDO.
DEFINE VARIABLE mWorkBook         AS COMPONENT-HANDLE NO-UNDO.
DEFINE VARIABLE mWorkSheet        AS COMPONENT-HANDLE NO-UNDO.
DEFINE VARIABLE mMaxNoLine        AS INTEGER          INITIAL 10 NO-UNDO.
DEFINE VARIABLE vLine   AS INTEGER   NO-UNDO.
DEFINE VARIABLE vChLine AS CHARACTER NO-UNDO.
DEFINE VARIABLE vCh     AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-prod  as character no-undo .
DEFINE VARIABLE vNoLine AS INTEGER   NO-UNDO.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable MarkType as ibs.th.str.marking.Types no-undo.
MarkType = ObjSrv:Env:Marking:Types.
define variable MarkTypeStr as character no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-custm'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output custvalue
  ,output custtype
  ) no-error .
function f-range returns character(input p-num as integer) :
    case p-num :
        when 1 then return "A":U .
        when 2 then return "B":U .
        when 3 then return "C":U .
        when 4 then return "D":U .
        when 5 then return "E":U .
        when 6 then return "F":U .
        when 7 then return "G":U .
        when 8 then return "H":U .
        when 9 then return "I":U .
        when 10 then return "J":U .
        when 11 then return "K":U .
        when 12 then return "L":U .
        when 13 then return "M":U .
        when 14 then return "N":U .
        when 15 then return "O":U .
        when 16 then return "P":U .
        when 17 then return "Q":U .
        when 18 then return "R":U .
        when 19 then return "S":U .
        when 20 then return "T":U .
    end case .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
for each thbjattr_thbj-attr  where
        thbjattr_thbj-attr.obj-type = '':U
    and thbjattr_thbj-attr.obj-code = 0
    and thbjattr_thbj-attr.upper-prop-code = 'gds-ref':U
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  case thbjattr_thbj-attr.prop-code:
    when 'tnvedimp':U then do:
      tnvedimp = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
run ref/strtimp.w (
                       input parparentproc
                      ,no
                      ,input integer('1':U)
                      ,input integer('2':U)
                      ,input custvalue
                      ,input tnvedimp
                      ,output f-name
                      ,output choice
                      ,output p-artic
                      ,output p-prod
                      ,OUTPUT p-name
                      ,OUTPUT p-engl-name
                      ,OUTPUT p-unit-base
                      ,OUTPUT p-VAT-code
                      ,OUTPUT p-SLT-code
                      ,OUTPUT p-struct
                      ,OUTPUT p-tnved
                      ,OUTPUT p-attrib
                      ,OUTPUT p-destin
                      ,OUTPUT p-sert
                      ,OUTPUT p-user-rule
                      ,OUTPUT p-alpha1
                      ,OUTPUT p-grp-code
                      ,OUTPUT p-service
                      ,OUTPUT p-gds-code
                      ,OUTPUT p-mark
                      ,output p-nomcode
                      ,output p-ppr
                      ) .
if  error-status:error or f-name = "" then return error.
CASE choice:
    WHEN 1 then do:
        input stream gds-file from value (f-name) convert source "1251".
    END.
    WHEN 2 then do:
        input stream gds-file from value (f-name) convert source "KOI8-R".
    END.
END CASE.
assign
    impc       = 0
    impc-saved = 0
    impc-Warn  = 0
.
run waitfram-show in this-procedure ( "ЖДИТЕ...") .
output stream str-log to value("gds-imp.log") .
if substring(f-name, length(f-name) - 2) = "xls"
or substring(f-name, length(f-name) - 3) = "xlsx"
then do :
    CREATE "Excel.Application":U mExcelApplication.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
    ASSIGN
        mExcelApplication:DisplayAlerts = NO
        mWorkbook                       = mExcelApplication:WorkBooks:Add(f-name)
        mWorkSheet                      = mWorkbook:Sheets:Item(1)
    .
    loopbl:
    DO vLine = 1 TO 1000000:
        ASSIGN
            vChLine = STRING(vLine)
            i-artic = ?
            i-alpha1 = ?
            i-attrib = ?
            i-destin = ?
            i-engl-name = ?
            i-gds-name = ?
            i-grp-code = 0
            i-prod-code = ?
            i-prod-type = ?
            i-sert = ?
            i-service = ?
            i-gds-code = ?
            i-SLT-code = ?
            i-struct = ?
            i-tnved = ?
            i-unit-base = ?
            i-user-rule = ?
            i-VAT-code = 0
            i-mark = ?
            i-nomcode = ?
            i-ppr = ?
        .
        i-artic = mWorkSheet:Range(f-range(p-artic) + vChLine):VALUE NO-ERROR.
        if i-artic = ? then i-artic = mWorkSheet:Range(f-range(p-artic) + vChLine):FORMULA NO-ERROR.
        i-artic = entry(1, i-artic, ".") no-error .
        i-alpha1 = mWorkSheet:Range(f-range(p-alpha1) + vChLine):VALUE NO-ERROR.
        if i-alpha1 = ? then i-alpha1 = mWorkSheet:Range(f-range(p-alpha1) + vChLine):FORMULA NO-ERROR.
        i-attrib = mWorkSheet:Range(f-range(p-attrib) + vChLine):VALUE NO-ERROR.
        if i-attrib = ? then i-attrib = mWorkSheet:Range(f-range(p-attrib) + vChLine):FORMULA NO-ERROR.
        i-destin = mWorkSheet:Range(f-range(p-destin) + vChLine):VALUE NO-ERROR.
        if i-destin = ? then i-destin = mWorkSheet:Range(f-range(p-destin) + vChLine):FORMULA NO-ERROR.
        i-engl-name = mWorkSheet:Range(f-range(p-engl-name) + vChLine):VALUE NO-ERROR.
        if i-engl-name = ? then i-engl-name = mWorkSheet:Range(f-range(p-engl-name) + vChLine):FORMULA NO-ERROR.
        i-gds-name = mWorkSheet:Range(f-range(p-name) + vChLine):VALUE NO-ERROR.
        if i-gds-name = ? then i-gds-name = mWorkSheet:Range(f-range(p-name) + vChLine):FORMULA NO-ERROR.
        i-grp-code = integer(mWorkSheet:Range(f-range(p-grp-code) + vChLine):VALUE) NO-ERROR.
        if i-grp-code = ? then i-grp-code = integer(mWorkSheet:Range(f-range(p-grp-code) + vChLine):FORMULA) NO-ERROR.
        v-prod = mWorkSheet:Range(f-range(p-prod) + vChLine):VALUE NO-ERROR.
        if v-prod = ? then v-prod = mWorkSheet:Range(f-range(p-prod) + vChLine):FORMULA NO-ERROR.
        i-prod-code = integer(substring(v-prod, 4)) no-error .
        i-prod-type = substring(v-prod, 1, 3) .
        i-sert = mWorkSheet:Range(f-range(p-sert) + vChLine):VALUE NO-ERROR.
        if i-sert = ? then i-sert = mWorkSheet:Range(f-range(p-sert) + vChLine):FORMULA NO-ERROR.
        i-service = logical(mWorkSheet:Range(f-range(p-service) + vChLine):VALUE) NO-ERROR.
        if i-service = ? then i-service = logical(mWorkSheet:Range(f-range(p-service) + vChLine):FORMULA) NO-ERROR.
        i-gds-code = integer(mWorkSheet:Range(f-range(p-gds-code) + vChLine):VALUE) NO-ERROR.
        if i-gds-code = ? then i-gds-code = integer(mWorkSheet:Range(f-range(p-gds-code) + vChLine):FORMULA) NO-ERROR.
        i-SLT-code = integer(mWorkSheet:Range(f-range(p-SLT-code) + vChLine):VALUE) NO-ERROR.
        if i-SLT-code = ? then i-SLT-code = integer(mWorkSheet:Range(f-range(p-SLT-code) + vChLine):FORMULA) NO-ERROR.
        i-struct = mWorkSheet:Range(f-range(p-struct) + vChLine):VALUE NO-ERROR.
        if i-struct = ? then i-struct = mWorkSheet:Range(f-range(p-struct) + vChLine):FORMULA NO-ERROR.
        i-tnved = mWorkSheet:Range(f-range(p-tnved) + vChLine):VALUE NO-ERROR.
        if i-tnved = ? then i-tnved = mWorkSheet:Range(f-range(p-tnved) + vChLine):FORMULA NO-ERROR.
        i-unit-base = mWorkSheet:Range(f-range(p-unit-base) + vChLine):VALUE NO-ERROR.
        if i-unit-base = ? then i-unit-base = mWorkSheet:Range(f-range(p-unit-base) + vChLine):FORMULA NO-ERROR.
        i-user-rule = mWorkSheet:Range(f-range(p-user-rule) + vChLine):VALUE NO-ERROR.
        if i-user-rule = ? then i-user-rule = mWorkSheet:Range(f-range(p-user-rule) + vChLine):FORMULA NO-ERROR.
        i-VAT-code = integer(mWorkSheet:Range(f-range(p-VAT-code) + vChLine):VALUE) NO-ERROR.
        if i-VAT-code = ? then i-VAT-code = integer(mWorkSheet:Range(f-range(p-VAT-code) + vChLine):FORMULA) NO-ERROR.
        i-mark = integer (mWorkSheet:Range(f-range(p-mark) + vChLine):value) NO-ERROR.
        if i-mark = ? then i-mark = (mWorkSheet:Range(f-range(p-mark) + vChLine):FORMULA) NO-ERROR.
        i-nomcode = mWorkSheet:Range(f-range(p-nomcode) + vChLine):value NO-ERROR.
        if i-nomcode = ? then i-nomcode = (mWorkSheet:Range(f-range(p-nomcode) + vChLine):FORMULA) NO-ERROR.
        i-ppr = integer(mWorkSheet:Range(f-range(p-ppr) + vChLine):VALUE) NO-ERROR.
        if i-ppr = ? then i-ppr = integer(mWorkSheet:Range(f-range(p-ppr) + vChLine):FORMULA) NO-ERROR.
        if length(i-artic) > 0 or length(i-alpha1) > 0 or length(i-attrib) > 0
        or length(i-destin) > 0 or length(i-engl-name) > 0 or length(i-engl-name) > 0
        or length(i-gds-name) > 0 or i-grp-code > 0 or length(i-prod-type) > 0
        or i-prod-code > 0 or length(i-sert) > 0 or i-service <> ? or i-gds-code > 0 or length(i-struct) > 0
        or i-SLT-code > 0 or length(i-tnved) > 0 or length(i-unit-base) > 0
        or length(i-user-rule) > 0 or i-VAT-code > 0
        then vNoLine = 0 .
        else do :
            vNoLine = vNoLine + 1.
            IF vNoLine > mMaxNoLine THEN LEAVE loopbl.
            ELSE NEXT loopbl.
        end.
        if i-gds-code eq ?
           and (i-artic eq ?
               or  i-prod-type eq ?
               or  i-prod-code eq ?)
        then do:
            impc = impc + 1 .
            put stream str-log unformatted "В загрузке обязательно должен быть код товара или артикул и производитель. Строка" vLine skip .
            next.
        end.
        else do :
            if     i-gds-code ne ?
               and i-artic    ne ?
               and i-prod-type ne ?
               and i-prod-code ne ?
             and
             can-find(goods where goods.artic eq i-artic
                            and goods.prod-type eq i-prod-type
                            and goods.prod-code eq i-prod-code
                            and goods.gds-code  ne i-gds-code)
            then do:
                impc = impc + 1 .
                put stream str-log unformatted "Уже есть товар с артикулом " i-artic "  " i-prod-type " " string(i-prod-code) " Строка  " vLine skip .
                next.
            end.
        end.
        find first goods where goods.gds-code = i-gds-code no-lock no-error.
        if not available goods
        then
           find first goods where goods.artic     eq i-artic
                              and goods.prod-type eq i-prod-type
                              and goods.prod-code eq i-prod-code no-lock no-error.
        if available goods
           and i-unit-base ne ?
           and goods.unit-base ne i-unit-base
        then do:
            impc-Warn = impc-Warn + 1.
            i-unit-base =  goods.unit-base.
            put stream str-log unformatted "Внимание Артикул " goods.artic " .  Единицы измерения изменять нельзя. Единицы измерения проигнорировы.  Строка  " vLine  skip .
        end.
        assign
        impc = impc + 1 .
        do transaction:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
            find last tax-rate-value where
                        tax-rate-value.tax-code = 1 and
                        tax-rate-value.rate-code = i-vat-code no-lock no-error.
            IF available tax-rate-value then do:
                NDS = tax-rate-value.rate-code.
            END.
            find first gds-grp no-lock where gds-grp.node-code = i-grp-code no-error .
            find first first_gds-grp .
            if i-unit-base ne ?
            then do:
            run ref/dtaxgdss.p (
                  input yes
                , input   i-unit-base
                , input   (if available gds-grp
                              then gds-grp.node-code
                              else first_gds-grp.node-code)
                , input if available goods then recid(goods) else ?
                , input if available goods then recid(goods) else ?
                , input   v-host-code
                , input    v-cntxt-obj-type
                , input    v-cntxt-obj-code
            ) no-error.
            if error-status :error
            then do:
               put stream str-log unformatted "Артикул " i-artic " .   " replace (return-value,Chr(10)," ")  " Строка  " vLine skip .
               next loopbl.
            end.
            end.
            IF p-VAT-code > 0 THEN DO:
                find first tt-tax
                     where tt-tax.tax-code = integer( '1':U )
                no-error.
                if available tt-tax   then do:
                    assign
                        tt-tax.rate-code = NDS .
                end.
            END.
            v-recid = if available goods then recid(goods) else ?.
            mnewrec = not avail goods.
            run ref/goods01.p (
                  input parparentproc
                , input if available goods then 'АВТОИЗМЕНЕНИЕ':U else 'ДОБАВЛЕНИЕ':U
                , input no
                , input 0
                , input no
                , input yes
                , input no
                , input no
                , input yes
                , input v-host-code
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input (if i-service then no else yes)
                , input ?
                , input i-gds-code
                , input i-artic
                , input i-prod-type
                , input i-prod-code
                , input 1
                , input i-grp-code
                , input i-gds-name
                , input ""
                , input i-engl-name
                , input i-gds-name
                , input replace( replace( i-gds-name, chr( 39 ), "" ), chr( 34 ), "" )
                , input i-alpha1
                , input i-unit-base
                , input i-unit-base
                , input 0.0
                , input 0.0
                , input 1
                , input 1
                , input 0
                , input 0
                , input 0
                , input 0
                , input 'Группа':U
                , input 0
                , input no
                , input (if i-service then 1 else 0)
                , input (if i-service then 1 else 0)
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input 0
                , input 0
                , input ""
                , input 0.0
                , input 0
                , input 0
                , input ""
                , input ""
                , input ""
                , input 0
                , input ?
                , input ""
                , input no
                , input no
                , input no
                , input no
                , input "no"
                , input yes
                , input no
                , input no
                , input if i-gds-code > 0 then 2 else 0
                , input-output v-recid
                , output j-gds-code
            ) no-error .
            find first goods where recid( goods)  = v-recid    no-lock no-error.
            if error-status :error
               or not available goods
            then do:
                put stream str-log unformatted "Ошибка создания/изменении карточки товара. Артикул " i-artic " .   " return-value " Строка  " vLine  skip .
                next loopbl.
            end.
            else do :
                 def var v-value as char no-undo.
                def var v-type as char no-undo.
                if p-mark eq 0
                then do:
                   if mnewrec
                   then do:
                       define variable mflag as logical no-undo.
                       run gds-attr-exist in this-procedure (goods.gds-code,'mark-type':U,output mflag).
                       if not mflag
                       then do:
                          run ggoattr-value(
                            input i-grp-code,
                            input 0,
                            input "",
                            input 0,
                            input 'gg-mark-type':U,
                            output v-value,
                            output v-type
                          ) no-error.
                          if v-value > "" then do:
                              run gds-attr-write IN THIS-PROCEDURE(
                                 input goods.gds-code
                                ,INPUT 'mark-type':U
                                ,INPUT v-value ) NO-ERROR.
                              put stream str-log unformatted "Внимание Артикул " goods.artic " .  Признак маркировки установлен с группы Строка " vLine  skip .
                              impc-Warn = impc-Warn + 1.
                          end.
                      end.
                   end.
                end.
                else if i-mark eq ? or i-mark eq 0
                then do:
                   run gds-attr-delete IN THIS-PROCEDURE(input goods.gds-code
                      ,INPUT 'mark-type':U
                      ,output mflag).
                end.
                else do:
                   MarkTypeStr = MarkType:GetNameProp(i-mark).
                   if MarkTypeStr eq MarkType:Unknow:NameProp
                   then do:
                      impc-Warn = impc-Warn + 1.
                      put stream str-log unformatted "Внимание Артикул " goods.artic " .  Не известный тип маркировки  " i-mark " Строка " vLine  skip .
                   end.
                   else
                   run gds-attr-write IN THIS-PROCEDURE(
                    input goods.gds-code
                   ,INPUT 'mark-type':U
                   ,INPUT MarkTypeStr
                          ) NO-ERROR.
                end.
                if p-nomcode <> 0
                then do:
                if i-nomcode = ""
                then do:
                   run gds-attr-delete IN THIS-PROCEDURE(input goods.gds-code
                      ,INPUT 'gds-CommodityCode':U
                      ,output mflag).
                end.
                else do:
                   run gds-attr-write IN THIS-PROCEDURE(
                    input goods.gds-code
                   ,INPUT 'gds-CommodityCode':U
                   ,INPUT i-nomcode
                          ) NO-ERROR.
                end.
                end.
           if p-ppr <> ?
              then
           do:
              if i-ppr <> 0
                 then
              do:
                 entry(i-ppr,'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19':U) no-error .
                 if error-status:error then
                 do:
                    impc-Warn = impc-Warn + 1.
                    put stream str-log unformatted
                       "Внимание Артикул " goods.artic " .  Не известный признак предмета расчета  " i-ppr " Строка " vLine  skip .
                 end.
                 else
                 do:
                    run gds-attr-write IN THIS-PROCEDURE(
                       input goods.gds-code
                       ,INPUT 'item-matter-mark':U
                       ,INPUT i-ppr
                       ) NO-ERROR.
                 end.
              end.
           end.
                if  goods.artic ne i-artic
                then do:
                    impc-Warn = impc-Warn + 1.
                   put stream str-log unformatted "Внимание Артикул " goods.artic " . На товаре уже установлен другой Артикул. Строка  " vLine  skip .
                end.
                if         (i-prod-type ne ?
                       and goods.prod-type ne i-prod-type)
                   or  (    i-prod-code ne ?
                        and goods.prod-code ne i-prod-code)
                then do:
                    impc-Warn = impc-Warn + 1.
                   put stream str-log unformatted "Внимание Артикул " goods.artic " . На товаре уже установлен другой прозводитель. Строка  " vLine  skip .
                end.
                if i-service
                then do :
                    for each clients no-lock where clients.obj-type = 'маг' :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  clients.obj-type
  ,input  clients.obj-code
  ,input  i-artic
  ,input  i-prod-type
  ,input  i-prod-code
  ,input  1
  ,buffer ub.gds-obj
  ,buffer ub.prt-obj
  )  .
                        if avail gds-obj then do:
                          find current gds-obj exclusive-lock .
                          assign
                          gds-obj.price-base = 1
                          gds-obj.price-rubl = 1
                          .
                          run str/callnews.p
                            ( input "gds-obj"
                              ,input (buffer gds-obj:handle)
                            ).
                        end.
                    end.
                end.
                impc-saved = impc-saved + 1.
                if impc-saved modulo 10 = 0 then
                run waitfram-show in this-procedure (input substitute("Обработано товаров &1", impc-saved)) .
            end.
        end.
    end.
end.
else do :
repeat :
    old-text-string = text-string .
    ASSIGN
        vChLine = STRING(vLine)
        i-artic = ?
        i-alpha1 = ?
        i-attrib = ?
        i-destin = ?
        i-engl-name = ?
        i-gds-name = ?
        i-grp-code = 0
        i-prod-code = ?
        i-prod-type = ?
        i-sert = ?
        i-service = ?
        i-gds-code = ?
        i-SLT-code = ?
        i-struct = ?
        i-tnved = ?
        i-unit-base = ?
        i-user-rule = ?
        i-VAT-code = 0
        i-mark = ?
        i-nomcode = ?
        i-ppr = ?
    .
    run ref/nxtgdsi.p (   input integer('1':U)
                         ,input integer('2':U)
                         ,input custvalue
                         ,input p-artic
                         ,input p-prod
                         ,input p-name
                         ,input p-engl-name
                         ,input p-unit-base
                         ,input p-VAT-code
                         ,input p-SLT-code
                         ,input p-struct
                         ,input p-tnved
                         ,input p-attrib
                         ,input p-destin
                         ,input p-sert
                         ,input p-user-rule
                         ,input p-alpha1
                         ,input p-grp-code
                         ,input p-service
                         ,input p-gds-code
                         ,input p-mark
                         ,input p-nomcode
                         ,input p-ppr
                         ,input (impc + 1)
                         ,input-output i-artic
                         ,input-output i-prod-type
                         ,input-output i-prod-code
                         ,input-output i-gds-name
                         ,input-output i-engl-name
                         ,input-output i-unit-base
                         ,input-output i-VAT-code
                         ,input-output i-SLT-code
                         ,input-output i-struct
                         ,input-output i-tnved
                         ,input-output i-attrib
                         ,input-output i-destin
                         ,input-output i-sert
                         ,input-output i-user-rule
                         ,input-output i-alpha1
                         ,input-output i-grp-code
                         ,input-output i-service
                         ,input-output i-gds-code
                         ,input-output i-mark
                         ,input-output i-nomcode
                         ,input-output i-ppr
                          ) no-error .
    if old-text-string = text-string then leave .
    if error-status :error
    then do :
        impc = impc + 1 .
        next.
    end.
    if            i-gds-code eq ?
             and (   i-artic eq ?
                  or i-prod-type eq ?
                  or  i-prod-code eq ?)
    then do:
       impc = impc + 1 .
       put stream str-log unformatted "В загрузке обязательно должен быть код товара или артикул и производитель. Строка" vLine skip .
       next.
    end.
    v-num-fields = maximum(p-alpha1, p-artic, p-attrib, p-destin, p-engl-name, p-gds-code, p-grp-code,
                           p-name, p-prod, p-sert, p-service, p-SLT-code, p-struct, p-tnved,
                           p-unit-base, p-user-rule, p-VAT-code,p-mark,p-nomcode,p-ppr) .
    if v-num-fields <> num-entries(text-string, ";")
    then do :
        impc = impc + 1 .
        put stream str-log unformatted "Неверное кол-во полей в строке " text-string " Строка  " impc  skip .
        next.
    end.
    if can-find(goods where goods.artic     eq i-artic
                            and goods.prod-type eq i-prod-type
                            and goods.prod-code eq i-prod-code
                            and goods.gds-code  ne i-gds-code)
    then do:
        impc = impc + 1 .
        put stream str-log unformatted "Уже есть товар с артикулом " i-artic "  " i-prod-type " " string(i-prod-code) " Строка  " vLine skip .
        next.
    end.
    find first goods where goods.gds-code = i-gds-code no-lock no-error.
    if not available goods
    then
       find first goods where goods.artic     eq i-artic
                          and goods.prod-type eq i-prod-type
                          and goods.prod-code eq i-prod-code no-lock no-error.
    assign
    impc = impc + 1 .
    do transaction:
        if available goods
           and goods.unit-base ne i-unit-base
        then do:
            impc-Warn = impc-Warn + 1.
            i-unit-base =  goods.unit-base.
            put stream str-log unformatted "Внимание Артикул " goods.artic " .  Единицы измерения изменять нельзя. Единицы измерения проигнорировы.  Строка  " vLine  skip .
        end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  )  .
        find last tax-rate-value where
                    tax-rate-value.tax-code = 1 and
                    tax-rate-value.rate-code = i-vat-code no-lock no-error.
        IF available tax-rate-value then do:
            NDS = tax-rate-value.rate-code.
        END.
        find first gds-grp no-lock where gds-grp.node-code = i-grp-code no-error .
        find first first_gds-grp .
        run ref/dtaxgdss.p (
              input yes
            , input   i-unit-base
            , input   (if available gds-grp
                          then gds-grp.node-code
                          else first_gds-grp.node-code)
            , input if available goods then recid(goods) else ?
            , input if available goods then recid(goods) else ?
            , input   v-host-code
            , input    v-cntxt-obj-type
            , input    v-cntxt-obj-code
        ) no-error.
        if error-status :error
        then do:
            put stream str-log unformatted "Артикул " i-artic " .   " replace (return-value,Chr(10)," ") " Строка  " impc  skip .
            next .
        end.
        IF p-VAT-code > 0 THEN DO:
            find first tt-tax
                 where tt-tax.tax-code = integer( '1':U )
            no-error.
            if available tt-tax   then do:
                assign
                    tt-tax.rate-code = NDS .
            end.
        END.
        v-recid = if available goods then recid(goods) else ?.
        mnewrec = not available goods.
        run ref/goods01.p (
              input parparentproc
            , input if available goods then 'АВТОИЗМЕНЕНИЕ':U else 'ДОБАВЛЕНИЕ':U
            , input no
            , input 0
            , input no
            , input yes
            , input no
            , input no
            , input yes
            , input v-host-code
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input (if i-service then no else yes)
            , input ?
            , input i-gds-code
            , input i-artic
            , input i-prod-type
            , input i-prod-code
            , input 1
            , input i-grp-code
            , input i-gds-name
            , input ""
            , input i-engl-name
            , input i-gds-name
            , input replace( replace( i-gds-name, chr( 39 ), "" ), chr( 34 ), "" )
            , input i-alpha1
            , input i-unit-base
            , input i-unit-base
            , input 0.0
            , input 0.0
            , input 1
            , input 1
            , input 0
            , input 0
            , input 0
            , input 0
            , input 'Группа':U
            , input 0
            , input no
            , input (if i-service then 1 else 0)
            , input (if i-service then 1 else 0)
            , input ""
            , input ""
            , input ""
            , input ""
            , input ""
            , input ""
            , input 0
            , input 0
            , input ""
            , input 0.0
            , input 0
            , input 0
            , input ""
            , input ""
            , input ""
            , input 0
            , input ?
            , input ""
            , input no
            , input no
            , input no
            , input no
            , input "no"
            , input yes
            , input no
            , input no
            , input if i-gds-code > 0 then 2 else 0
            , input-output v-recid
            , output j-gds-code
        ) no-error .
        find first goods where recid( goods)  = v-recid    no-lock no-error.
        if    error-status :error
           or not available goods
        then do:
            put stream str-log unformatted "Ошибка создания карточки товара. Артикул " i-artic " .   " return-value " Строка  " impc  skip .
            next.
        end.
        else do :
             if p-mark eq 0
             then do:
                 if mnewrec
                 then do:
                     run gds-attr-exist in this-procedure (goods.gds-code,'mark-type':U,output mflag).
                     if not mflag
                     then do:
                        run ggoattr-value(
                            input i-grp-code,
                            input 0,
                            input "",
                            input 0,
                            input 'gg-mark-type':U,
                            output v-value,
                            output v-type
                          ) no-error.
                        if v-value > "" then do:
                            run gds-attr-write IN THIS-PROCEDURE(
                                input goods.gds-code
                               ,INPUT 'mark-type':U
                               ,INPUT v-value ) NO-ERROR.
                           impc-Warn = impc-Warn + 1.
                 put stream str-log unformatted "Внимание Артикул " goods.artic " .  Признак маркировки установлен с группы Строка  " vLine  skip .
                        end.
                     end.
                 end.
             end.
             else if i-mark eq ? or i-mark eq 0
             then do:
                 run gds-attr-delete IN THIS-PROCEDURE(input goods.gds-code
                   ,INPUT 'mark-type':U
                   ,output mflag).
             end.
             else do:
                MarkTypeStr = MarkType:GetNameProp(i-mark).
                if MarkTypeStr eq MarkType:Unknow:NameProp
                then do:
                      impc-Warn = impc-Warn + 1.
                      put stream str-log unformatted "Внимание Артикул " goods.artic " .  Не известный тип маркировки  " i-mark " Строка " vLine  skip .
                   end.
                   else
                   run gds-attr-write IN THIS-PROCEDURE(
                    input goods.gds-code
                   ,INPUT 'mark-type':U
                   ,INPUT MarkTypeStr
                          ) NO-ERROR.
                end.
                if p-nomcode <> 0
                then do:
                if i-nomcode = ""
                then do:
                   run gds-attr-delete IN THIS-PROCEDURE(input goods.gds-code
                      ,INPUT 'gds-CommodityCode':U
                      ,output mflag).
                end.
                else do:
                   run gds-attr-write IN THIS-PROCEDURE(
                    input goods.gds-code
                   ,INPUT 'gds-CommodityCode':U
                   ,INPUT i-nomcode
                          ) NO-ERROR.
                end.
                end.
             find first goods where goods.gds-code = j-gds-code no-lock no-error.
             if available goods then do:
             if  goods.artic ne i-artic
             then do:
                put stream str-log unformatted "Внимание Артикул " goods.artic " . На товаре уже установлен другой Артикул. Строка  " vLine  skip .
                impc-Warn = impc-Warn + 1.
             end.
             if     (    i-prod-type ne ?
                     and goods.prod-type ne i-prod-type)
                or  (i-prod-code ne ?
                     and goods.prod-code ne i-prod-code)
             then do:
                 impc-Warn = impc-Warn + 1.
                 put stream str-log unformatted "Внимание Артикул " goods.artic " . На товаре уже установлен другой прозводитель. Строка  " vLine  skip .
             end.
            end.
           if p-ppr <> ?
              then
           do:
              if i-ppr <> 0
                 then
              do:
                 entry(i-ppr,'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19':U) no-error .
                 if error-status:error then
                 do:
                    impc-Warn = impc-Warn + 1.
                    put stream str-log unformatted
                       "Внимание Артикул " goods.artic " .  Не известный признак предмета расчета  " i-ppr " Строка " vLine  skip .
                 end.
                 else
                 do:
                    run gds-attr-write IN THIS-PROCEDURE(
                       input goods.gds-code
                       ,INPUT 'item-matter-mark':U
                       ,INPUT i-ppr
                       ) NO-ERROR.
                 end.
              end.
           end.
             find first goods where goods.gds-code = j-gds-code no-lock no-error.
             if available goods then do:
             if  goods.artic ne i-artic
             then do:
                put stream str-log unformatted "Внимание Артикул " goods.artic " . На товаре уже установлен другой Артикул. Строка  " vLine  skip .
                impc-Warn = impc-Warn + 1.
             end.
             if     (    i-prod-type ne ?
                     and goods.prod-type ne i-prod-type)
                or  (i-prod-code ne ?
                     and goods.prod-code ne i-prod-code)
             then do:
                 impc-Warn = impc-Warn + 1.
                 put stream str-log unformatted "Внимание Артикул " goods.artic " . На товаре уже установлен другой прозводитель. Строка  " vLine  skip .
             end.
            end.
            if i-service
            then do :
                for each clients no-lock where clients.obj-type = 'маг' :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  clients.obj-type
  ,input  clients.obj-code
  ,input  i-artic
  ,input  i-prod-type
  ,input  i-prod-code
  ,input  1
  ,buffer ub.gds-obj
  ,buffer ub.prt-obj
  )  .
                    if avail gds-obj then do:
                      find current gds-obj exclusive-lock .
                      assign
                      gds-obj.price-base = 1
                      gds-obj.price-rubl = 1
                      .
                      run str/callnews.p
                        ( input "gds-obj"
                          ,input (buffer gds-obj:handle)
                        ).
                    end.
                end.
            end.
            impc-saved = impc-saved + 1.
            if impc-saved modulo 10 = 0 then
            run waitfram-show in this-procedure (input substitute("Обработано товаров &1", impc-saved)) .
        end.
    end.
end.
end.
input stream gds-file close.
output stream str-log close.
run waitfram-hide in this-procedure .
message ("Импорт из файла " + f-name + " закончен" + chr(10) + "прочитано " + string(impc) +
         ",  сохранено " + string(impc-saved) + ", предупреждений " + string(impc-Warn) + chr(10) + chr(10) + "Информация по незагруженным товарам находится в файле gds-imp.log" )
view-as alert-box  INFORMATION.
release object mWorkSheet.
mExcelApplication:quit.
release object mExcelApplication.
