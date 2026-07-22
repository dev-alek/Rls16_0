DEFINE BUFFER locked_clients FOR ub.clients.
DEFINE BUFFER locked_firm FOR ub.firm.
DEFINE TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE tt-firm NO-UNDO LIKE ub.firm.
DEFINE INPUT PARAMETER         parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter         p-mode        as       character                    no-undo.
define input parameter         p-code        like ub.firm.firm-code no-undo .
define input parameter         p-grp-code    like ub.clients.grp-code no-undo.
define input parameter         p-CallPoint   as character  no-undo .
define input-output parameter  p-rid          as      recid   init ?          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования фирмы".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
define variable v-db-num like ub.db.db-num no-undo .
define variable is-fin as logical no-undo .
define variable nocorinn as logical no-undo .
define variable f3 like  ub.firm.addres1 no-undo.
define variable f4 like  ub.firm.addres2 no-undo.
define variable fp3 like ub.firm.post-addr1 no-undo.
define variable fp4 like ub.firm.post-addr1 no-undo.
define variable v-s-deploy as logical no-undo .
define buffer buf_clients for ub.clients.
DEFINE MENU MENU-firm-code
       MENU-ITEM m-choose       LABEL "Подобрать свободный код".
DEFINE BUTTON b-attr
     LABEL "&Атрибуты"
     SIZE 10 BY 1.
DEFINE BUTTON b-bank
     LABEL "&Банки"
     SIZE 10 BY 1.
DEFINE BUTTON b-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1.
DEFINE BUTTON b-cli-cl
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL "":L
     SIZE 3 BY 1.
DEFINE BUTTON b-dc
     LABEL "&Диск.карты"
     SIZE 12 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist
     LABEL "Истори&я":L
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-region
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1.
DEFINE BUTTON B-sysconf
     LABEL "Своя фирма"
     SIZE 20 BY 1.
DEFINE BUTTON Docs
     LABEL "&Док-ты"
     SIZE 10 BY 1.
DEFINE VARIABLE f1 AS CHARACTER FORMAT "X(50)":U
     VIEW-AS FILL-IN
     SIZE 52 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE f2 AS CHARACTER FORMAT "X(50)":U
     VIEW-AS FILL-IN
     SIZE 52 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE fcli AS CHARACTER FORMAT "X(256)":U
     LABEL "Торг.предст"
     VIEW-AS FILL-IN
     SIZE 39.8 BY 1 NO-UNDO.
DEFINE VARIABLE fp1 AS CHARACTER FORMAT "X(50)":U
     VIEW-AS FILL-IN
     SIZE 52 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE fp2 AS CHARACTER FORMAT "X(50)":U
     VIEW-AS FILL-IN
     SIZE 52 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE jj_change-address AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "&Юридический", 0,
"Поч&товый", 1
     SIZE 14 BY 2 NO-UNDO.
DEFINE VARIABLE T-check-inn AS LOGICAL INITIAL yes
     LABEL "Проверять"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-firm,
      tt-clients,
      locked_firm SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-dc AT ROW 1 COL 21
     b-bank AT ROW 1 COL 33
     Docs AT ROW 1 COL 43
     b-attr AT ROW 1 COL 53 WIDGET-ID 2
     B-sysconf AT ROW 1 COL 63 WIDGET-ID 8
     b-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-firm.firm-code AT ROW 2.43 COL 4.2 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          BGCOLOR 15
     tt-clients.obj-name AT ROW 2.43 COL 25 COLON-ALIGNED
          LABEL "Название" FORMAT "X(130)"
          VIEW-AS FILL-IN
          SIZE 72 BY 1
          BGCOLOR 15
     tt-firm.engl-name AT ROW 3.62 COL 25 COLON-ALIGNED
          LABEL "Англ./второе назв." FORMAT "X(130)"
          VIEW-AS FILL-IN
          SIZE 72 BY 1
          BGCOLOR 15
     tt-firm.is-pboul AT ROW 4.81 COL 87
          LABEL "ПБОЮЛ"
          VIEW-AS TOGGLE-BOX
          SIZE 10 BY 1
     tt-firm.inn AT ROW 4.81 COL 7.8 COLON-ALIGNED
          LABEL "INN"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
          BGCOLOR 15
     T-check-inn AT ROW 4.81 COL 26.4
     tt-firm.okpo AT ROW 4.81 COL 47 COLON-ALIGNED
          LABEL "ОКПО" FORMAT "X(10)"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          BGCOLOR 15
     tt-firm.kpp AT ROW 4.81 COL 66 COLON-ALIGNED
          LABEL "KPP"
          VIEW-AS FILL-IN
          SIZE 16.8 BY 1
     tt-firm.okonh AT ROW 6 COL 8 COLON-ALIGNED
          LABEL "OKONX"
          VIEW-AS FILL-IN
          SIZE 60 BY 1
          BGCOLOR 15
     tt-clients.reg-code AT ROW 6 COL 76 COLON-ALIGNED
          LABEL "Регион"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     b-region AT ROW 6 COL 82.6
     jj_change-address AT ROW 7.19 COL 2 NO-LABEL
     tt-firm.addres1 AT ROW 7.19 COL 24 COLON-ALIGNED NO-LABEL FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 52 BY 1
          BGCOLOR 15
     tt-firm.post-addr1 AT ROW 7.19 COL 45 COLON-ALIGNED
          LABEL "Адрес" FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 52 BY 1
          BGCOLOR 15
     tt-firm.addres2 AT ROW 8.38 COL 24 COLON-ALIGNED NO-LABEL FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 52 BY 1
          BGCOLOR 15
     tt-firm.post-addr2 AT ROW 8.38 COL 45 COLON-ALIGNED NO-LABEL FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 52 BY 1
          BGCOLOR 15
     f1 AT ROW 9.57 COL 24 COLON-ALIGNED NO-LABEL
     fp1 AT ROW 9.57 COL 45 COLON-ALIGNED NO-LABEL
     f2 AT ROW 10.76 COL 24 COLON-ALIGNED NO-LABEL
     fp2 AT ROW 10.76 COL 45 COLON-ALIGNED NO-LABEL
     tt-firm.city AT ROW 11.95 COL 15 COLON-ALIGNED
          LABEL "Страна, город"
          VIEW-AS FILL-IN
          SIZE 38 BY 1
          BGCOLOR 15
     tt-firm.ind AT ROW 11.95 COL 67.4 COLON-ALIGNED
          LABEL "Индекс"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
          BGCOLOR 15
     tt-firm.post-city AT ROW 11.97 COL 15.6 COLON-ALIGNED WIDGET-ID 4
          LABEL "Страна, город"
          VIEW-AS FILL-IN
          SIZE 38 BY 1
          BGCOLOR 15
     tt-firm.post-ind AT ROW 11.95 COL 67.4 COLON-ALIGNED WIDGET-ID 6
          LABEL "Индекс"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
          BGCOLOR 15
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     tt-firm.director AT ROW 13.14 COL 15 COLON-ALIGNED
          LABEL "Руководитель" FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 82 BY 1
          BGCOLOR 15
     tt-firm.contact-psn AT ROW 14.33 COL 15 COLON-ALIGNED
          LABEL "Контакт. лицо" FORMAT "X(50)"
          VIEW-AS FILL-IN
          SIZE 82 BY 1
          BGCOLOR 15
     tt-firm.phone AT ROW 15.52 COL 8.6 COLON-ALIGNED
          LABEL "Тел."
          VIEW-AS FILL-IN
          SIZE 13.8 BY 1
          BGCOLOR 15
     tt-firm.phone1-note AT ROW 15.52 COL 30.5 COLON-ALIGNED
          LABEL "Прим."
          VIEW-AS FILL-IN
          SIZE 17.4 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-firm.fax AT ROW 15.52 COL 55.4 COLON-ALIGNED
          LABEL "Факс"
          VIEW-AS FILL-IN
          SIZE 20.5 BY 1
          BGCOLOR 15
     tt-firm.telex AT ROW 16.71 COL 8.6 COLON-ALIGNED
          LABEL "Телекс"
          VIEW-AS FILL-IN
          SIZE 13.8 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-firm.e-mail AT ROW 16.71 COL 30.8 COLON-ALIGNED
          LABEL "e-mail" FORMAT "X(100)"
          VIEW-AS FILL-IN
          SIZE 66.4 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-firm.passp-ser AT ROW 17.9 COL 31 COLON-ALIGNED
          LABEL "Паспорт: серия"
          VIEW-AS FILL-IN
          SIZE 16.5 BY 1 TOOLTIP "Для ПБОЮЛ"
          BGCOLOR 15 FGCOLOR 0
     tt-firm.passp-num AT ROW 17.9 COL 55.5 COLON-ALIGNED
          LABEL "номер"
          VIEW-AS FILL-IN
          SIZE 20.4 BY 1 TOOLTIP "Для ПБОЮЛ"
          BGCOLOR 15 FGCOLOR 0
     tt-firm.given-by AT ROW 19.09 COL 15 COLON-ALIGNED
          LABEL "Выдан"
          VIEW-AS FILL-IN
          SIZE 82 BY 1 TOOLTIP "Для ПБОЮЛ"
          BGCOLOR 15 FGCOLOR 0 FORMAT "X(128)"
     fcli AT ROW 20.28 COL 14 COLON-ALIGNED
     b-cli AT ROW 20.28 COL 59
     b-cli-cl AT ROW 20.28 COL 62.5
     tt-firm.tobj-code AT ROW 20.28 COL 69.5 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          BGCOLOR 15
     tt-clients.PS AT ROW 21.47 COL 8.6 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
          SIZE 54.4 BY 2.67
          FONT 4
     tt-clients.lim-kr AT ROW 21.47 COL 77 COLON-ALIGNED
          LABEL "Лимит кредита"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
          BGCOLOR 15
     tt-clients.turnover-buyer AT ROW 22.66 COL 64.2
          LABEL "Расчитывать обороты по пок-лю"
          VIEW-AS TOGGLE-BOX
          SIZE 36.8 BY .81 TOOLTIP "Рассчитывать обороты по покупателю"
     tt-clients.turnover-buyer-gds AT ROW 23.50 COL 67
          LABEL "в разрезе товаров"
          VIEW-AS TOGGLE-BOX
          SIZE 23.85 BY .81 TOOLTIP "Расcчитывать обороты покупателя в разрезе товаров"
     "Прим.:" VIEW-AS TEXT
          SIZE 6.5 BY .95 AT ROW 21.47 COL 1.5
     SPACE(92) SKIP(2)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "О Р Г А Н И З А Ц И Я"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       tt-firm.addres1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-firm.addres2:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f2:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-firm.firm-code:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-firm-code:HANDLE.
ASSIGN
       fp1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       fp2:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-firm.post-addr1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-firm.post-addr2:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-clients.PS:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
    run proc-save in this-procedure no-error.
    if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-attr IN FRAME Dialog-Frame
DO:
 define variable v-updated as logical no-undo .
 define variable v-is-error as logical no-undo .
 run ref/ca-attrr.p (
                    input parparentproc
                   ,input 'ПРОСМОТР':U
                   ,input 'орг':U
                   ,input tt-firm.firm-code
                   ,input YES
                   ,output v-updated
                   ,output v-is-error
                   ) no-error.
  if error-status:error
  or v-is-error then do:
    message
    "Ошибка при вызове списка атрибутов клиента" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box .
    undo, return no-apply.
  end.
END.
ON CHOOSE OF b-bank IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
define variable v-rid as recid no-undo .
define variable glog as logical no-undo .
define variable v-status_ like ub.fin-schet.status_ no-undo init 'все':U.
define buffer buf_sysconf for ub.sysconf.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  glog = no.
  message "Вы завершили ввод карточки клиента?"
  view-as alert-box QUESTION buttons YEs-No update glog.
  if not glog then return no-apply.
  if glog then do:
    run proc-save in this-procedure no-error .
    if error-status:error then return no-apply.
    assign
    p-mode = 'ИЗМЕНЕНИЕ':U.
    run fill-table in this-procedure no-error .
    if error-status:error then return no-apply.
    run Myenable in this-procedure .
  END.
end.
  if p-callpoint = 'sysconf':U then do:
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = tt-firm.firm-code no-error.
    if available buf_sysconf then do:
      run ref/finschts.w (
                        INPUT parParentProc
                        ,input (if v-cntxt-host-code-obj = 0
                                then tt-firm.firm-code
                                else v-cntxt-host-code-obj)
                        ,input (if v-cntxt-host-code-obj > 0
                                then "b-add":U
                                else '')
                        ,input "company-host":U
                        ,input 'орг':U
                        ,input tt-firm.firm-code
                        ,input ?
                        ,input (if v-cntxt-host-code-obj = 0
                               then tt-firm.firm-code
                               else v-cntxt-host-code-obj)
                        ,input 0
                        ,input-output v-status_
                        ,input-output v-rid-list ).
    end.
  end.
  else do:
    if v-cntxt-host-code-obj = 0 then do:
      message
      "Нельзя посмотреть счета, так как в настоящий момент не определена текущая фирма"
      view-as alert-box error.
      undo, return no-apply.
    end.
    else do:
      run ref/finschts.w (
                        INPUT parParentProc
                        ,input v-cntxt-host-code-obj
                        ,input "b-add":U
                        ,input "cmp-host":U
                        ,input 'орг':U
                        ,input tt-firm.firm-code
                        ,input ?
                        ,input v-cntxt-host-code-obj
                        ,input 0
                        ,input-output v-status_
                        ,input-output v-rid-list ).
    end.
  end.
END.
ON CHOOSE OF b-cli IN FRAME Dialog-Frame
DO:
    define variable ri-str as char init "" no-undo .
    run ref/cli-all.w (
                       input parParentProc
                      ,input "b-sel"
                      ,input 'чел':U
                      ,input 'все':U
                      ,input ?
                      ,input ?
                      ,input ",,,,,,NO"
                      ,input ?
                      ,output ri-str ) .
    apply "ENTRY" to b-exit.
    if ri-str <> "" then   do:
            find first buf_clients where recid ( buf_clients ) = integer( ri-str ) no-lock.
            if buf_clients.obj-type <> 'чел':U then  do:
                    message
                    "Нужно выбрать ЧЕЛОВЕКА (тип чел) !"
                    view-as alert-box WARNING.
                    return no-apply.
                end.
            fcli = buf_clients.obj-name.
            disp
            fcli
            buf_clients.obj-code @ tt-firm.tobj-code with frame Dialog-Frame.
        end.
END.
ON CHOOSE OF b-cli-cl IN FRAME Dialog-Frame
DO:
      assign fcli = "".
      if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
        assign
        tt-firm.tobj-code = 0.
        display
        tt-firm.tobj-code
        fcli with frame Dialog-Frame.
      end.
      else
      display
      0 @ tt-firm.tobj-code
      fcli with frame Dialog-Frame.
END.
ON CHOOSE OF b-dc IN FRAME Dialog-Frame
DO:
define variable rid-list    as  char no-undo .
run ref/discards.w (
                 input parparentproc
                ,input ""
                ,input "client":U
                ,input v-cntxt-host-code-obj
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input '':U
                ,input recid( locked_clients )
                ,output rid-list ).
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
     run ref/cclihist.w (
                      input parparentproc
                    , input 0
                    , input "":U
                    , input 0
                    , input "":U
                    , input "one":U
                    , input 'орг':U
                    , input tt-firm.firm-code
                    , input ?
                    , input ?
                    , input "":U
                    , input "":U
                    , input v-cntxt-db-num
                    , input-output v-rid-list  ) no-error .
END.
ON CHOOSE OF b-region IN FRAME Dialog-Frame
DO:
  define buffer buf_regions for ub.regions.
  define variable v-reg-code like ub.regions.reg-code no-undo .
  run ref/regions.w ( input  parParentProc
                    , input  'выбор':U
                    , output v-reg-code
                    ).
  if v-reg-code <> ? then do :
    find first buf_regions no-lock
      where buf_regions.reg-code = v-reg-code
    no-error .
    if not available buf_regions then do:
      message
        "Неверный код региона " v-reg-code
      view-as alert-box error.
      return no-apply.
    end.
    else do:
      assign
        tt-clients.reg-code = buf_regions.reg-code
      .
      display
        tt-clients.reg-code
      with frame Dialog-Frame.
    end.
  end.
END.
ON CHOOSE OF B-sysconf IN FRAME Dialog-Frame
DO:
define variable v-ok as logical no-undo.
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_host-reference_lookup':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
    if v-ok <> true
    then do:
      return no-apply.
    end.
    run adm/config.w
      (input  parParentProc
      ,input  tt-firm.firm-code
      ,input  'ПРОСМОТР':U
      ,input  no
      ) no-error.
    if error-status :error
    then do:
      return no-apply.
    end.
END.
ON CHOOSE OF Docs IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-output as character no-undo.
define variable v-input-output as character no-undo .
run str/all-docs.w (
               input parparentproc
              ,input ?
              ,input ?
              ,input ?
              ,input 'Контрагент':U
              ,input ?
              ,input ?
              ,input ?
              ,input ?
              ,input '':U
              ,input '':U
              ,input ?
              ,input recid(locked_clients)
              ,output v-input-output
              ) no-error .
 apply "ENTRY" to b-exit.
END.
ON VALUE-CHANGED OF tt-firm.is-pboul IN FRAME Dialog-Frame
DO:
  ASSIGN
  tt-firm.is-pboul.
  CASE tt-firm.is-pboul:
      WHEN NO  THEN DO:
          IF p-mode <> 'ПРОСМОТР':U THEN DO:
            ASSIGN
            tt-firm.given-by  = "":U
            tt-firm.passp-num  = "":U
            tt-firm.passp-ser = "":U
            .
             DISPLAY
              tt-firm.given-by
              tt-firm.passp-num
              tt-firm.passp-ser
              WITH FRAME Dialog-Frame.
              disable
              tt-firm.given-by
              tt-firm.passp-num
              tt-firm.passp-ser
              WITH FRAME Dialog-Frame.
         END.
      END.
      WHEN yes  THEN DO:
        IF p-mode <> 'ПРОСМОТР':U THEN DO:
          ENABLE
          tt-firm.given-by
          tt-firm.passp-num
          tt-firm.passp-ser
          WITH FRAME Dialog-Frame.
        END.
      END.
END CASE.
END.
ON VALUE-CHANGED OF jj_change-address IN FRAME Dialog-Frame
DO:
ASSIGN jj_change-address.
CASE jj_change-address:
  when 0 THEN DO:
    ASSIGN
    fp3 = input tt-firm.post-addr1
    fp4 = input tt-firm.post-addr2
    fp1
    fp2
    .
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      ASSIGN
      tt-firm.post-addr1
      tt-firm.post-addr2
      tt-firm.post-city
      tt-firm.post-ind
      .
    end.
    DISABLE
    tt-firm.post-addr1
    tt-firm.post-addr2
    fp1
    fp2
    tt-firm.post-city
    tt-firm.post-ind
    WITH FRAME Dialog-Frame.
    HIDE
    tt-firm.post-addr1
    tt-firm.post-addr2
    fp1
    fp2
    tt-firm.post-city
    tt-firm.post-ind
    IN FRAME Dialog-Frame.
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      DISPLAY
      f3 @ tt-firm.addres1
      f4 @ tt-firm.addres2
      f1
      f2
      tt-firm.city
      tt-firm.ind
      WITH FRAME Dialog-Frame.
    end.
    else do:
      DISPLAY
      tt-firm.addres1
      tt-firm.addres2
      f1
      f2
       tt-firm.city
       tt-firm.ind
      WITH FRAME Dialog-Frame.
    end.
    if p-mode <> 'ПРОСМОТР':U then do:
      ENABLE
      tt-firm.addres1
      tt-firm.addres2
      f1
      f2
      tt-firm.city
      tt-firm.ind
      WITH FRAME Dialog-Frame.
    end.
  END.
  when 1 THEN DO:
    ASSIGN
    f3 = input tt-firm.addres1
    f4 = input tt-firm.addres2
    f1
    f2.
    if p-mode = 'ИЗМЕНЕНИЕ':U then
    ASSIGN
    tt-firm.addres1
    tt-firm.addres2
    tt-firm.city
    tt-firm.ind
    .
    DISABLE
    tt-firm.addres1
    tt-firm.addres2
    f1
    f2
    tt-firm.city
    tt-firm.ind
    WITH FRAME Dialog-Frame.
    HIDE
    tt-firm.addres1
    tt-firm.addres2
    f1
    f2
    tt-firm.city
    tt-firm.ind
    IN FRAME Dialog-Frame.
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      DISPLAY
      fp3 @ tt-firm.post-addr1
      fp4 @ tt-firm.post-addr2
      fp1
      fp2
      TT-FIRM.post-city
      tt-firm.post-ind
      WITH FRAME Dialog-Frame.
    end.
    else do:
      DISPLAY
      tt-firm.post-addr1
      tt-firm.post-addr2
      fp1
      fp2
      tt-firm.post-city
      tt-firm.post-ind
      WITH FRAME Dialog-Frame.
    end.
    if p-mode <> 'ПРОСМОТР':U then do:
      ENABLE
      tt-firm.post-addr1
      tt-firm.post-addr2
      fp1
      fp2
      tt-firm.post-city
      tt-firm.post-ind
      WITH FRAME Dialog-Frame.
    end.
  END.
END CASE.
END.
ON CHOOSE OF MENU-ITEM m-choose
DO:
  DEFINE VARIABLE v-obj-code LIKE ub.clients.obj-code NO-UNDO.
  run ref/chs-code.w ( input 'орг':U
                      ,input v-cntxt-db-num
                      ,OUTPUT v-obj-code) no-error .
  if not error-status:error
  and v-obj-code <> ? then do:
    display
    v-obj-code @ tt-firm.firm-code
    with frame Dialog-Frame .
  end.
END.
ON LEAVE OF tt-firm.passp-num IN FRAME Dialog-Frame
DO:
   IF trim(tt-firm.passp-num:SCREEN-VALUE) = "":U THEN
      ASSIGN
      tt-firm.passp-num:SCREEN-VALUE = ?.
END.
ON VALUE-CHANGED OF tt-clients.turnover-buyer IN FRAME Dialog-Frame
DO:
  ASSIGN tt-clients.turnover-buyer .
  IF tt-clients.turnover-buyer THEN ENABLE tt-clients.turnover-buyer-gds WITH FRAME Dialog-Frame.
      ELSE DISABLE tt-clients.turnover-buyer-gds WITH FRAME Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   :
assign
v-s-deploy = lookup("s-deploy":U, p-mode, ";") > 0
.
assign
p-mode = trim(replace(p-mode, "s-deploy":U, "":U), ";":U)
.
if p-mode  <> 'ДОБАВЛЕНИЕ':U
  and p-mode <> 'ИЗМЕНЕНИЕ':U
  and p-mode <> 'ПРОСМОТР':U
  then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode"  p-mode
      view-as alert-box ERROR.
      undo, return error.
  end.
  if p-callpoint  <> "":U
  and p-callpoint <> "discards":U
  and p-callpoint <> "cli-all":U
  and p-callpoint <> 'sysconf':U
  then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-callpoint"  p-callpoint
      view-as alert-box ERROR.
      undo, return error.
  end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
  if v-s-deploy then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  else do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run fill-table in this-procedure no-error.
  if error-status:error then return error.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY T-check-inn jj_change-address fcli
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-clients THEN
    DISPLAY tt-clients.obj-name tt-clients.reg-code tt-clients.PS
          tt-clients.lim-kr tt-clients.turnover-buyer tt-clients.turnover-buyer-gds
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-firm THEN
    DISPLAY tt-firm.firm-code tt-firm.engl-name tt-firm.is-pboul tt-firm.inn
          tt-firm.okpo tt-firm.kpp tt-firm.okonh tt-firm.city tt-firm.ind
          tt-firm.director tt-firm.contact-psn tt-firm.phone1-note tt-firm.phone
          tt-firm.fax tt-firm.telex tt-firm.e-mail tt-firm.passp-ser
          tt-firm.passp-num tt-firm.given-by tt-firm.tobj-code
          tt-firm.post-city
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-dc b-bank Docs b-attr B-sysconf b-hist B-Help
         tt-firm.firm-code tt-clients.obj-name tt-firm.engl-name
         tt-firm.is-pboul tt-firm.inn T-check-inn tt-firm.okpo tt-firm.kpp
         tt-firm.okonh tt-clients.reg-code b-region jj_change-address
         tt-firm.city tt-firm.ind tt-firm.director tt-firm.contact-psn
         tt-firm.phone1-note tt-firm.phone tt-firm.fax tt-firm.telex
         tt-firm.e-mail tt-firm.passp-ser tt-firm.passp-num tt-firm.given-by
         fcli b-cli tt-clients.PS tt-clients.lim-kr tt-clients.turnover-buyer
         tt-clients.turnover-buyer-gds tt-firm.post-city  tt-firm.post-ind
         tt-firm.contact-psn
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-table :
define variable v-type as character no-undo .
define variable v-exist as logical no-undo .
  for each tt-clients :
    delete tt-clients.
  end.
  for each tt-firm :
    delete tt-firm.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_clients EXclusive-lock where
            recid(locked_clients) = p-rid no-wait no-error.
      if locked locked_clients then do:
        find first locked_clients EXclusive-lock where
              recid(locked_clients) = p-rid no-error.
      end.
    end.
    else do:
      find first locked_clients no-lock where
                       recid(locked_clients) = p-rid no-error .
      if not avail locked_clients then do:
        find first locked_clients where
                  locKed_clients.obj-type = 'орг':U
             AND locKed_clients.obj-code = p-code no-error .
      end.
    end.
    if not available locked_clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись КЛИЕНТ"
      view-as alert-box error .
      undo, return error.
    end.
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_firm EXclusive-lock where
            locked_firm.firm-code = locked_clients.obj-code no-wait no-error.
      if locked locked_firm then do:
        find first locked_firm EXclusive-lock where
              locked_firm.firm-code = locked_clients.obj-code  no-error.
      end.
    end.
    else do:
      find first locked_firm no-lock where
              locked_firm.firm-code = locked_clients.obj-code no-error .
    end.
    if not available locked_firm then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ОРГАНИЗАЦИЯ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-clients.
    buffer-copy locked_clients to tt-clients.
    create tt-firm.
    buffer-copy locked_firm to tt-firm.
  end.
  else do:
    create tt-clients.
    create tt-firm.
    assign
    tt-clients.obj-type = 'орг':U
    tt-clients.obj-code = 0
    tt-clients.grp-code = p-grp-code
    tt-firm.firm-code = tt-clients.obj-code
    tt-clients.stts = 0
    .
  end.
END PROCEDURE.
PROCEDURE MyEnable :
define variable for-code as integer no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define buffer last_person for ub.person.
tt-firm.okonh:label in frame Dialog-Frame = "ОКОНХ".
tt-firm.inn:label in frame Dialog-Frame = "ИНН".
tt-firm.kpp:label in frame Dialog-Frame = "КПП".
VIEW FRAME Dialog-Frame.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
IF not error-status:error then
assign
is-fin =  (if conf-par = "yes" then yes else no)
.
run adm/shattri.p (
      input "get":U
    ,input  '':U
    ,input  0
    ,input  'cli-all':U
    ,input  'nocorinn':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output nocorinn
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
delete object v-tth.
assign
fp1:column IN FRAME Dialog-Frame= f1:column IN FRAME Dialog-Frame
fp2:column = f2:column IN FRAME Dialog-Frame
tt-firm.post-addr1:column = tt-firm.addres1:column
tt-firm.post-addr1:label = tt-firm.addres1:label
tt-firm.post-addr2:column = tt-firm.addres2:column
jj_change-address = 0
f1 = substring( tt-firm.addres1, 51, 50 )
f2 = substring( tt-firm.addres1, 101, 50 )
fp1 = substring( tt-firm.post-addr1, 51, 50 )
fp2 = substring( tt-firm.post-addr1, 101, 50 )
.
IF AVAILABLE tt-clients THEN
  DISPLAY
  tt-clients.obj-name
  tt-clients.lim-kr
  tt-clients.PS
  tt-clients.reg-code
  WITH FRAME Dialog-Frame.
IF AVAILABLE tt-firm THEN
  DISPLAY
  tt-firm.contact-psn
  tt-firm.director
  tt-firm.e-mail
  tt-firm.engl-name
  tt-firm.fax
  tt-firm.firm-code
  tt-firm.given-by
  tt-firm.inn
  t-check-inn when p-mode <> 'ПРОСМОТР':U
  tt-firm.is-pboul
  tt-firm.kpp
  tt-firm.okonh
  tt-firm.okpo
  tt-firm.passp-num
  tt-firm.passp-ser
  tt-firm.phone
  tt-firm.phone1-note
  tt-firm.telex
  tt-firm.tobj-code
  tt-clients.turnover-buyer
  tt-clients.turnover-buyer-gds
  WITH FRAME Dialog-Frame.
if tt-firm.tobj-code <> 0 then do:
    find first buf_clients no-lock where buf_clients.obj-code = tt-firm.tobj-code and buf_clients.obj-type = 'чел':U no-error .
    if AVAILABLE buf_clients then fcli = buf_clients.obj-name .
    display
    fcli with frame Dialog-Frame.
end.
assign
frame Dialog-Frame :title = "О Р Г А Н И З А Ц И Я:" + chr(32) + p-mode
.
if p-mode <> 'ПРОСМОТР':U then do:
  define variable v-enable-lim-kr as logical no-undo .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-requisite_add-upd':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-enable-lim-kr
    )  .
end.
  ENABLE
  B-exit
  b-quit
  b-dc   when p-mode <> 'ДОБАВЛЕНИЕ':U and p-callpoint <> "discards":U
  b-bank when p-mode <> 'ДОБАВЛЕНИЕ':U
  Docs   when p-mode <> 'ДОБАВЛЕНИЕ':U and v-cntxt-level = 'object':U
  b-hist when p-mode <> 'ДОБАВЛЕНИЕ':U
  b-cli
  B-Help
  b-region
  b-sysconf
  tt-firm.firm-code  when p-mode = 'ДОБАВЛЕНИЕ':U
  tt-clients.obj-name
  tt-firm.contact-psn
  tt-firm.director
  tt-firm.e-mail
  tt-firm.engl-name
  tt-firm.fax
  tt-firm.given-by
  tt-firm.inn
  t-check-inn when nocorinn
  tt-firm.is-pboul
  tt-firm.kpp
  tt-firm.okonh
  tt-firm.okpo
  tt-firm.passp-num
  tt-firm.passp-ser
  tt-firm.phone
  tt-firm.phone1-note
  tt-firm.telex
  tt-firm.tobj-code
  tt-clients.lim-kr when v-enable-lim-kr
  tt-clients.PS
  tt-clients.turnover-buyer when v-cntxt-db-num =0
  tt-clients.turnover-buyer-gds when tt-clients.turnover-buyer = true and v-cntxt-db-num =0
  jj_change-address
  WITH FRAME Dialog-Frame.
  tt-clients.PS:read-only = no.
  HIDE
  b-attr IN FRAME Dialog-Frame.
end.
else do:
  ENABLE
  b-quit
  b-dc   when p-callpoint <> "discards":U and v-cntxt-level = 'object':U
  b-bank
  Docs when v-cntxt-level = 'object':U
  b-sysconf
  b-hist
  B-Help
  jj_change-address
  tt-clients.ps
  b-attr
  with frame Dialog-Frame .
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  tt-clients.PS:read-only = yes
  .
  hide
  b-exit
  t-check-inn
  in frame Dialog-Frame .
end.
if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
  MENU-ITEM m-choose:SENSITIVE IN MENU MENU-firm-code = NO .
end.
assign
b-sysconf:visible in frame Dialog-Frame = (p-mode <> 'ДОБАВЛЕНИЕ':U and can-find(first ub.sysconf where ub.sysconf.host-code = tt-clients.obj-code))
.
assign
  b-bank:label = "&Счета".
  define variable v-use-grp-buy           as logical   no-undo .
  define variable v-use-oborot-buy        as logical   no-undo .
  define variable v-use-qnty-group        as logical   no-undo .
  define variable v-use-sum-group         as logical   no-undo .
  define variable v-use-add-code          as logical   no-undo .
  define variable v-use-sys-date-time     as logical   no-undo .
  define variable v-use-shift-date-num    as logical   no-undo .
  define variable v-use-cassa             as logical   no-undo .
  define variable v-use-val               as logical   no-undo .
  define variable v-use-pay-type          as logical   no-undo .
  define variable v-use-cash-pay          as logical   no-undo .
  define variable v-use-child as logical
no-undo.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run glstall in g#library
(  output v-use-grp-buy
 , output v-use-oborot-buy
 , output v-use-qnty-group
 , output v-use-sum-group
 , output v-use-add-code
 , output v-use-sys-date-time
 , output v-use-shift-date-num
 , output v-use-cassa
 , output v-use-val
 , output v-use-pay-type
 , output v-use-cash-pay
 , output v-use-child
        ) no-error .
if not (v-use-grp-buy  or  v-use-oborot-buy) then
  do:
    hide
    tt-clients.turnover-buyer
    tt-clients.turnover-buyer-gds
    in frame Dialog-Frame.
  end.
VIEW FRAME Dialog-Frame.
APPLY "VALUE-CHANGED":U TO jj_change-address IN FRAME Dialog-Frame.
APPLY "VALUE-CHANGED":U TO tt-firm.is-pboul IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Proc-save :
define variable v-no-check-inn as logical no-undo .
define variable ii as integer no-undo .
define variable v-return-value as character no-undo .
define variable glog as logical no-undo .
if p-mode = 'ДОБАВЛЕНИЕ':U then
assign
frame Dialog-Frame
tt-firm.firm-code
.
assign
f3 = input frame Dialog-Frame tt-firm.addres1
f4 = input frame Dialog-Frame tt-firm.addres2
fp3 = input frame Dialog-Frame tt-firm.post-addr1
fp4 = input frame Dialog-Frame tt-firm.post-addr2
.
if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
  if tt-firm.addres1:visible     in frame Dialog-Frame
  then assign tt-firm.addres1.
  if tt-firm.addres2:visible     in frame Dialog-Frame
  then assign tt-firm.addres2.
  if tt-firm.post-addr1:visible in frame Dialog-Frame
  then assign tt-firm.post-addr1.
  if tt-firm.post-addr2:visible in frame Dialog-Frame
  then assign tt-firm.post-addr2.
  if tt-firm.post-city:visible in frame Dialog-Frame
  then assign tt-firm.post-city.
  if tt-firm.post-ind:visible in frame Dialog-Frame
  then assign tt-firm.post-ind.
  if tt-firm.city:visible in frame Dialog-Frame
  then assign tt-firm.city.
  if tt-firm.ind:visible in frame Dialog-Frame
  then assign tt-firm.ind.
end.
else do:
  assign
  tt-firm.post-addr1 = string(fp3, "X(50)")
  tt-firm.post-addr2 = string(fp4, "X(50)")
  tt-firm.addres1 = string(f3, "X(50)")
  tt-firm.addres2 = string(f4, "X(50)")
  .
end.
if f1:visible   in frame Dialog-Frame
then assign f1.
if f2:visible   in frame Dialog-Frame
then assign f2.
if fp1:visible  in frame Dialog-Frame
then assign fp1.
if fp2:visible  in frame Dialog-Frame
then assign fp2.
IF (tt-firm.addres1 <> ''
or tt-firm.addres2 <> ''
or tt-firm.city <> ''
OR tt-firm.ind <> 0)
AND (tt-firm.post-addr1 = ''
     AND
     tt-firm.post-addr2 = ''
     AND
     tt-firm.post-city = ''
     AND
    tt-firm.post-ind = 0) THEN DO:
  message
  substitute("Вы заполнили (некоторые) поля ЮРИДИЧЕСКОГО адреса,&1" +
             "но не заполнили ни одного поля ПОЧТОВОГО адреса&1" +
             "Скопировать поля ЮРИДИЧЕСКОГО адреса в поля ПОЧТОВОГО адреса?"
             , chr(10))
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF glog THEN DO:
    APPLY "VALUE-CHANGED" to jj_change-address.
    ASSIGN
    tt-firm.post-addr1 = tt-firm.addres1
    tt-firm.post-addr2 = tt-firm.addres2
    tt-firm.post-city = tt-firm.city
    tt-firm.post-ind = tt-firm.ind
    fp1 = f1
    fp2 = f2
    .
    DISPLAY
    tt-firm.post-addr1
    tt-firm.post-addr2
    tt-firm.post-city
    tt-firm.post-ind
    fp1
    fp2
    WITH FRAME Dialog-Frame.
  END.
END.
assign
tt-clients.obj-name
tt-clients.PS
tt-clients.lim-kr
tt-firm.contact-psn
tt-firm.director
tt-firm.e-mail
tt-firm.engl-name
tt-firm.fax
tt-firm.given-by
tt-firm.inn
t-check-inn
tt-firm.is-pboul
tt-firm.kpp
tt-firm.okonh
tt-firm.okpo
tt-firm.passp-num = IF tt-firm.passp-num:SCREEN-VALUE = ? THEN "":U ELSE tt-firm.passp-num:SCREEN-VALUE
tt-firm.passp-ser
tt-firm.phone
tt-firm.phone1-note
tt-firm.telex
tt-firm.tobj-code
tt-clients.turnover-buyer
tt-clients.turnover-buyer-gds
substring( tt-firm.addres1, 51, 50 ) = f1
substring( tt-firm.addres1, 101, 50 ) = f2
substring( tt-firm.post-addr1, 51, 50 ) = fp1
substring( tt-firm.post-addr1, 101, 50 ) = fp2
.
_ii:
do ii = 1 to (if nocorinn AND t-check-inn then 2 else 1):
  run ref/firm1.p (
                 input parparentproc
                ,input-output p-rid
                ,input p-mode
                ,input (if p-callpoint = 'sysconf':U then "cli-all" else p-callpoint)
                ,input no
                ,input tt-firm.firm-code
                ,input tt-clients.stts
                ,input tt-clients.obj-name
                ,input tt-clients.lim-kr
                ,input tt-clients.PS
                ,input tt-clients.grp-code
                ,input tt-firm.addres1
                ,input tt-firm.addres2
                ,input tt-firm.city
                ,input tt-firm.contact-psn
                ,input tt-firm.director
                ,input tt-firm.e-mail
                ,input tt-firm.engl-name
                ,input tt-firm.fax
                ,INPUT tt-firm.given-by
                ,input tt-firm.ind
                ,input tt-firm.inn
                ,INPUT (v-no-check-inn OR not t-check-inn)
                ,INPUT tt-firm.is-pboul
                ,input tt-firm.kpp
                ,input tt-firm.okonh
                ,input tt-firm.okpo
                ,INPUT tt-firm.passp-num
                ,INPUT tt-firm.passp-ser
                ,input tt-firm.phone
                ,input tt-firm.phone1-note
                ,input tt-firm.post-addr1
                ,input tt-firm.post-addr2
                ,input tt-firm.post-city
                ,input tt-firm.post-ind
                ,input tt-clients.reg-code
                ,input tt-firm.telex
                ,input tt-firm.tobj-code
                ,input tt-clients.turnover-buyer
                ,input tt-clients.turnover-buyer-gds
  ) no-error .
  if error-status:error then do:
    if return-value = "inn" and nocorinn then do:
      message
      "Введенный ИНН некорректен или не является ИНН для Вашей страны" skip
      "Подтверждаете ввод ТАКОГО ИНН?"
      view-as alert-box question buttons yes-no update v-no-check-inn.
      if not v-no-check-inn then undo, return error .
      next _ii.
    end.
    v-return-value = return-value .
    if v-return-value = 'inn-uniq' then do:
      v-return-value = 'inn'.
    end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, v-return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo  ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
    undo, return error.
  end.
  else leave _ii.
end.
END PROCEDURE.
