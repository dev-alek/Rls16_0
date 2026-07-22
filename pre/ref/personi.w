DEFINE BUFFER locked_clients FOR ub.clients.
DEFINE BUFFER locked_person FOR ub.person.
DEFINE TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE tt-person NO-UNDO LIKE ub.person.
DEFINE TEMP-TABLE tt-staff NO-UNDO LIKE ub.staff.
DEFINE INPUT PARAMETER         parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter         p-mode        as       character                    no-undo.
define input parameter         p-code        like ub.person.psn-code no-undo .
define input parameter         p-grp-code    like ub.clients.grp-code no-undo.
define input parameter         p-CallPoint   as character  no-undo .
define input-output parameter  p-rid          as      recid   init ?          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования человека".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE request-proc-save-staff :
DEFINE INPUT PARAMETER p-child-handle AS HANDLE NO-UNDO.
define input parameter p-mode as character no-undo .
define input parameter p-callpoint as character no-undo .
define buffer buf_tt-staff for tt-staff.
IF p-mode <> 'ДОБАВЛЕНИЕ':U
OR LOOKUP(p-callpoint , 'C,S':U) = 0 THEN RETURN.
for each buf_tt-staff :
    RUN proc-save-staff IN p-child-handle (
                                           INPUT buf_tt-staff.role
                                          ,INPUT buf_tt-staff.staff-code
                                          ,INPUT buf_tt-staff.role-level
                                          ,INPUT buf_tt-staff.db-num
                                          ,INPUT buf_tt-staff.host-code
                                          ,INPUT buf_tt-staff.obj-type
                                          ,INPUT buf_tt-staff.obj-code
                                          ,INPUT buf_tt-staff.password
                                          ,input buf_tt-staff.date-start
                                          ,input buf_tt-staff.date-end
                                          ,input buf_tt-staff.work-place
                                            ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      UNDO, RETURN ERROR RETURN-VALUE.
    END.
END.
END PROCEDURE.
define variable v-db-num like ub.db.db-num no-undo .
define variable is-fin as logical no-undo .
define variable is-magia as logical no-undo .
define variable nocorinn as logical no-undo .
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
DEFINE MENU MENU-B-add
       MENU-ITEM m_cashier      LABEL "Кассир"
       MENU-ITEM m_seller       LABEL "Продавец"      .
DEFINE MENU MENU-psn-code
       MENU-ITEM m-choose       LABEL "Подобрать свободный код".
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-attr
     LABEL "&Атрибуты"
     SIZE 10 BY 1.
DEFINE BUTTON b-bank
     LABEL "&Банки"
     SIZE 10 BY 1.
DEFINE BUTTON b-dc
     LABEL "Диск.&карты"
     SIZE 12 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-org
     LABEL "&Список орг."
     SIZE 12 BY 1.
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
DEFINE BUTTON Docs
     LABEL "&Док-ты"
     SIZE 10 BY 1.
DEFINE VARIABLE jj_change-address AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "&Регистрации", 0,
"Поч&товый", 1
     SIZE 13.9 BY 2 NO-UNDO.
DEFINE VARIABLE Rs-gender AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "Yes"
     SIZE 27.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-check-inn AS LOGICAL INITIAL yes
     LABEL "Проверять"
     VIEW-AS TOGGLE-BOX
     SIZE 12 BY 1 NO-UNDO.
DEFINE QUERY BR-staff FOR
      tt-staff SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      ub.person,
      ub.clients,
      locked_person,
      tt-person,
      tt-clients SCROLLING.
DEFINE BROWSE BR-staff
  QUERY BR-staff NO-LOCK DISPLAY
      entry (lookup (tt-staff.role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)  COLUMN-LABEL "Роль" FORMAT "X(10)":U
tt-staff.staff-code  COLUMN-LABEL "Код" FORMAT ">>>>9":U
tt-staff.db-num COLUMN-LABEL "№ БД" FORMAT ">>>>9":U
tt-staff.date-start COLUMN-LABEL "С" FORMAT "99/99/9999":U
tt-staff.date-end COLUMN-LABEL "По" FORMAT "99/99/9999":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 48.5 BY 5
         TITLE "Роли" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-dc AT ROW 1 COL 21
     b-bank AT ROW 1 COL 33
     Docs AT ROW 1 COL 43
     b-org AT ROW 1 COL 53
     b-attr AT ROW 1 COL 65 WIDGET-ID 6
     b-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-person.psn-code AT ROW 3.03 COL 5.8 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 10.1 BY 1
          BGCOLOR 15
     tt-clients.obj-name AT ROW 3.03 COL 27.3 COLON-ALIGNED
          LABEL "Фамилия"
          VIEW-AS FILL-IN
          SIZE 41 BY 1
          BGCOLOR 15
     Rs-gender AT ROW 3.03 COL 70.5 NO-LABEL
     tt-person.date-birth AT ROW 4 COL 84.5 COLON-ALIGNED
          LABEL "Д.Р."
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-person.name1 AT ROW 4.13 COL 23.1 COLON-ALIGNED
          LABEL "Имя"
          VIEW-AS FILL-IN
          SIZE 20.1 BY 1
          BGCOLOR 15
     tt-person.name2 AT ROW 4.13 COL 54.5 COLON-ALIGNED
          LABEL "Отчество"
          VIEW-AS FILL-IN
          SIZE 21.8 BY 1
          BGCOLOR 15
     tt-clients.turnover-buyer AT ROW 5.27 COL 65
          LABEL "Расчитывать обороты по пок-лю"
          VIEW-AS TOGGLE-BOX
          SIZE 33 BY .83 TOOLTIP "Рассчитывать обороты по покупателю"
     tt-person.firm-name AT ROW 5.3 COL 10 COLON-ALIGNED
          LABEL "Орга-ция"
          VIEW-AS FILL-IN
          SIZE 52.5 BY 1
          BGCOLOR 15
     tt-clients.turnover-buyer-gds AT ROW 6 COL 68
          LABEL "в разрезе товаров"
          VIEW-AS TOGGLE-BOX
          SIZE 19.5 BY .83 TOOLTIP "Расcчитывать обороты покупателя в разрезе товаров"
     tt-person.position AT ROW 6.3 COL 10 COLON-ALIGNED
          LABEL "Должность"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          BGCOLOR 15
     tt-person.is-pboul AT ROW 7.5 COL 84
          LABEL "ПБОЮЛ"
          VIEW-AS TOGGLE-BOX
          SIZE 12 BY 1
     tt-person.inn AT ROW 7.63 COL 10 COLON-ALIGNED
          LABEL "inn"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          BGCOLOR 15
     tt-person.kpp AT ROW 7.63 COL 50 COLON-ALIGNED
          LABEL "kpp"
          VIEW-AS FILL-IN
          SIZE 23.3 BY 1.03
     T-check-inn AT ROW 7.77 COL 34
     tt-person.phone1 AT ROW 8.97 COL 10 COLON-ALIGNED
          LABEL "Телефон"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          BGCOLOR 15
     tt-person.phone1-note AT ROW 8.97 COL 41.8 COLON-ALIGNED
          LABEL "Прим."
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          BGCOLOR 15
     tt-person.fax AT ROW 10.17 COL 10 COLON-ALIGNED
          LABEL "Факс"
          VIEW-AS FILL-IN
          SIZE 21 BY 1
          BGCOLOR 15
     tt-person.e-mail AT ROW 10.17 COL 41.6 COLON-ALIGNED
          LABEL "E-mail" FORMAT "X(100)"
          VIEW-AS FILL-IN
          SIZE 49.4 BY 1
          BGCOLOR 15
     jj_change-address AT ROW 11.4 COL 1 NO-LABEL WIDGET-ID 8
     tt-person.city AT ROW 11.4 COL 21 COLON-ALIGNED
          LABEL "Город"
          VIEW-AS FILL-IN
          SIZE 31.9 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-person.post-city AT ROW 11.4 COL 21 COLON-ALIGNED WIDGET-ID 12
          LABEL "Город"
          VIEW-AS FILL-IN
          SIZE 31.9 BY 1
          BGCOLOR 15
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     tt-person.post-ind AT ROW 11.4 COL 72.1 COLON-ALIGNED WIDGET-ID 16
          LABEL "Индекс"
          VIEW-AS FILL-IN
          SIZE 7.8 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-person.ind AT ROW 11.4 COL 72.1 COLON-ALIGNED
          LABEL "Индекс"
          VIEW-AS FILL-IN
          SIZE 7.8 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-person.post-address AT ROW 12.57 COL 21 COLON-ALIGNED WIDGET-ID 14
          LABEL "Адрес"
          VIEW-AS FILL-IN
          SIZE 43.1 BY 1
          BGCOLOR 15
     tt-person.address AT ROW 12.57 COL 21 COLON-ALIGNED
          LABEL "Адрес"
          VIEW-AS FILL-IN
          SIZE 43.1 BY 1
          BGCOLOR 15
     tt-person.passp-ser AT ROW 13.77 COL 20.5 COLON-ALIGNED
          LABEL "Паспорт серия"
          VIEW-AS FILL-IN
          SIZE 13.5 BY 1
          BGCOLOR 15
     tt-person.passp-num AT ROW 13.77 COL 45.6 COLON-ALIGNED
          LABEL "номер" FORMAT "X(18)"
          VIEW-AS FILL-IN
          SIZE 19 BY 1
          BGCOLOR 15
     tt-person.post-box AT ROW 13.8 COL 69 COLON-ALIGNED
          LABEL "а/я"
          VIEW-AS FILL-IN
          SIZE 8.1 BY 1
          BGCOLOR 15
     tt-clients.reg-code AT ROW 13.8 COL 85.5 COLON-ALIGNED WIDGET-ID 4
          LABEL "Регион"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     b-region AT ROW 13.8 COL 91.5 WIDGET-ID 2
     tt-person.given-by AT ROW 14.97 COL 12.8 COLON-ALIGNED
          LABEL "Выдан"
          VIEW-AS FILL-IN
          SIZE 82 BY 1
          BGCOLOR 15 FORMAT "X(128)"
     B-add AT ROW 16 COL 49
     B-del AT ROW 16 COL 59
     tt-clients.lim-kr AT ROW 16.13 COL 1.1
          LABEL "Лимит кредита"
          VIEW-AS FILL-IN
          SIZE 19.9 BY 1
          BGCOLOR 15
     BR-staff AT ROW 17 COL 49
     tt-clients.PS AT ROW 18.5 COL 1.5 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
          SIZE 47 BY 3.5
          FONT 4
     "Примеч.:" VIEW-AS TEXT
          SIZE 12 BY 1 AT ROW 17.27 COL 2
     SPACE(84.00) SKIP(3.76)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ч Е Л О В Е К (физич. лицо)"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.
ASSIGN
       tt-clients.PS:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.
ASSIGN
       tt-person.psn-code:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-psn-code:HANDLE.
ON GO OF FRAME Dialog-Frame
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-option AS CHARACTER NO-UNDO.
IF add-option = '':U THEN DO:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
END.
if add-option = '':U then return no-apply.
v-option = add-option.
add-option = '':U.
run proc-b-add-staff in this-procedure ( input v-option) no-error.
if error-status:error then do:
   return no-apply.
end.
END.
ON CHOOSE OF b-attr IN FRAME Dialog-Frame
DO:
 define variable v-updated as logical no-undo .
 define variable v-is-error as logical no-undo .
 run ref/ca-attrr.p (
                    input parparentproc
                   ,input 'ПРОСМОТР':U
                   ,input 'чел':U
                   ,input tt-person.psn-code
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
if p-mode = 'ДОБАВЛЕНИЕ':U  then do:
  glog = no.
  message "Вы завершили ввод карточки клиента?"
  view-as alert-box QUESTION buttons YEs-No update glog.
  if not glog then return no-apply.
  if glog then do:
    run proc-save in this-procedure no-error .
    if error-status:error then undo, return no-apply.
    assign
    p-mode = 'ИЗМЕНЕНИЕ':U.
    run fill-table in this-procedure no-error .
    if error-status:error then do:
      undo, return no-apply .
    end.
    run Myenable in this-procedure .
  END.
end.
    run ref/finschts.w (
                      INPUT parParentProc
                     ,input v-cntxt-host-code-obj
                     ,input "b-add":U
                     ,input "cmp-host":U
                     ,input 'чел':U
                     ,input tt-person.psn-code
                     ,input ?
                     ,input v-cntxt-host-code-obj
                     ,input 0
                     ,input-output v-status_
                     ,input-output v-rid-list ).
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
               ,recid( locked_clients )
               ,output rid-list ).
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE tt-staff THEN RETURN NO-APPLY.
  DELETE tt-staff.
  OPEN QUERY br-staff FOR  EACH tt-staff INDEXED-REPOSITION.
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
                    , input 'чел':U
                    , input tt-person.psn-code
                    , input ?
                    , input ?
                    , input "":U
                    , input "":U
                    , input v-cntxt-db-num
                    , input-output v-rid-list  ) no-error .
END.
ON CHOOSE OF b-org IN FRAME Dialog-Frame
DO:
  run ref/rpsn-org.w ( INPUT parParentProc, INPUT tt-person.psn-code ).
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
ON LEAVE OF tt-person.inn IN FRAME Dialog-Frame
DO:
define variable v-correct-inn as logical no-undo .
END.
ON VALUE-CHANGED OF jj_change-address IN FRAME Dialog-Frame
DO:
ASSIGN jj_change-address.
CASE jj_change-address:
  when 0 THEN DO:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      ASSIGN
      tt-person.post-address
      tt-person.post-city
      tt-person.post-ind
      .
    end.
    DISABLE
    tt-person.post-address
    tt-person.post-city
    tt-person.post-ind
    WITH FRAME Dialog-Frame.
    HIDE
    tt-person.post-address
    tt-person.post-city
    tt-person.post-ind
    IN FRAME Dialog-Frame.
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      DISPLAY
      tt-person.address
      tt-person.city
      tt-person.ind
      WITH FRAME Dialog-Frame.
    end.
    else do:
      DISPLAY
      tt-person.address
      tt-person.city
      tt-person.ind
      WITH FRAME Dialog-Frame.
    end.
    if p-mode <> 'ПРОСМОТР':U then do:
      ENABLE
      tt-person.address
      tt-person.city
      tt-person.ind
      WITH FRAME Dialog-Frame.
    end.
  END.
  when 1 THEN DO:
    if p-mode = 'ИЗМЕНЕНИЕ':U then
    ASSIGN
    tt-person.address
    tt-person.city
    tt-person.ind
    .
    DISABLE
    tt-person.address
    tt-person.city
    tt-person.ind
    WITH FRAME Dialog-Frame.
    HIDE
    tt-person.address
    tt-person.city
    tt-person.ind
    IN FRAME Dialog-Frame.
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      DISPLAY
      tt-person.post-address
      tt-person.post-city
      tt-person.post-ind
      WITH FRAME Dialog-Frame.
    end.
    else do:
      DISPLAY
      tt-person.post-address
      tt-person.post-city
      tt-person.post-ind
      WITH FRAME Dialog-Frame.
    end.
    if p-mode <> 'ПРОСМОТР':U then do:
      ENABLE
      tt-person.post-address
      tt-person.post-city
      tt-person.post-ind
      WITH FRAME Dialog-Frame.
    end.
  END.
END CASE.
END.
ON LEAVE OF tt-person.kpp IN FRAME Dialog-Frame
DO:
define variable checked as decimal.
assign
checked = decimal(input frame Dialog-Frame tt-person.kpp) No-error.
if error-status:error or NOT (checked = truncate(checked,0)) then do:
    message "Нечисловой или неправильный КПП!" view-as alert-box.
    return no-apply.
end.
END.
ON CHOOSE OF MENU-ITEM m-choose
DO:
   DEFINE VARIABLE v-obj-code LIKE ub.clients.obj-code NO-UNDO.
  run ref/chs-code.w (
                   input 'чел':U
                 , input v-cntxt-db-num
                 , OUTPUT v-obj-code) no-error .
  if not error-status:error
  and v-obj-code <> ? then do:
    display
    v-obj-code @ tt-person.psn-code
    with frame Dialog-Frame .
  end.
END.
ON CHOOSE OF MENU-ITEM m_cashier
DO:
  ASSIGN
  add-option = 'C':U.
  APPLY "CHOOSE" TO b-add IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_seller
DO:
    ASSIGN
    add-option = 'S':U.
    APPLY "CHOOSE" TO b-add IN FRAME Dialog-Frame.
END.
ON LEAVE OF tt-person.passp-num IN FRAME Dialog-Frame
DO:
  IF trim(tt-person.passp-num:SCREEN-VALUE) = "":U THEN
      ASSIGN
      tt-person.passp-num:SCREEN-VALUE = ?.
END.
ON VALUE-CHANGED OF tt-clients.turnover-buyer IN FRAME Dialog-Frame
DO:
  ASSIGN tt-clients.turnover-buyer .
  IF tt-clients.turnover-buyer THEN ENABLE tt-clients.turnover-buyer-gds WITH FRAME Dialog-Frame.
      ELSE DISABLE tt-clients.turnover-buyer-gds WITH FRAME Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-staff :handle
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign
    tt-person.inn :label in frame Dialog-Frame = "ИНН"
    tt-person.kpp :label in frame Dialog-Frame = "КПП"
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
  if p-callpoint  <> 'C':U
  and p-callpoint <> 'S':U
  and p-callpoint <> "discards":U
  and p-callpoint <> "cli-all":U
  then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-callpoint"  p-callpoint
      view-as alert-box ERROR.
      undo, return error.
  end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run fill-table in this-procedure no-error.
  if error-status:error then return error.
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Rs-gender T-check-inn jj_change-address
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-clients THEN
    DISPLAY tt-clients.obj-name tt-clients.turnover-buyer
          tt-clients.turnover-buyer-gds tt-clients.reg-code tt-clients.lim-kr
          tt-clients.PS
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-person THEN
    DISPLAY tt-person.psn-code tt-person.date-birth tt-person.name1
          tt-person.name2 tt-person.firm-name tt-person.position
          tt-person.is-pboul tt-person.inn tt-person.kpp tt-person.phone1
          tt-person.phone1-note tt-person.fax tt-person.e-mail tt-person.city
          tt-person.post-city tt-person.post-ind tt-person.ind
          tt-person.post-address tt-person.address tt-person.passp-ser
          tt-person.passp-num tt-person.post-box tt-person.given-by
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-dc b-bank Docs b-org b-attr b-hist B-Help
         tt-person.psn-code tt-clients.obj-name Rs-gender tt-person.date-birth
         tt-person.name1 tt-person.name2 tt-clients.turnover-buyer
         tt-person.firm-name tt-clients.turnover-buyer-gds tt-person.position
         tt-person.is-pboul tt-person.inn tt-person.kpp T-check-inn
         tt-person.phone1 tt-person.phone1-note tt-person.fax tt-person.e-mail
         jj_change-address tt-person.city tt-person.post-city
         tt-person.post-ind tt-person.ind tt-person.post-address
         tt-person.address tt-person.passp-ser tt-person.passp-num
         tt-person.post-box tt-clients.reg-code b-region tt-person.given-by
         B-add B-del tt-clients.lim-kr BR-staff tt-clients.PS
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-staff FOR  EACH tt-staff INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE fill-table :
define variable v-type as character no-undo .
define variable v-exist as logical no-undo .
DEFINE BUFFER buf_tt-staff FOR tt-staff.
DEFINE BUFFER buf_staff FOR ub.staff.
 for each tt-clients :
    delete tt-clients.
  end.
  for each tt-person :
    delete tt-person.
  end.
  FOR EACH buf_tt-staff:
      DELETE buf_tt-staff.
  END.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
   if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      main-block:
      do
      on error  undo main-block, return error substitute( "&1 &2. &3&4&3&5"
                                                        , vss-workfile
                                                        , "Блокирование клиентма для редактирования"
                                                        , return-value
                                                        , chr(10)
                                                        , error-status :get-message (1)
                                                        )
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        find first locked_clients EXclusive-lock where
              recid(locked_clients) = p-rid .
                find first locked_person EXclusive-lock where
              locked_person.psn-code = locked_clients.obj-code .
      end.
    end.
    else do:
      find first locked_clients no-lock where
                       recid(locked_clients) = p-rid no-error .
      if not avail locked_clients then do:
        find first locked_clients where
                  locKed_clients.obj-type = 'чел':U
             AND locKed_clients.obj-code = p-code no-error .
      end.
      if not available locked_clients then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найдена запись КЛИЕНТ"
        view-as alert-box error .
        undo, return error.
      end.
      find first locked_person no-lock where
              locked_person.psn-code = locked_clients.obj-code no-error .
      if not available locked_person then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найдена запись ФИз.Лица"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    create tt-clients.
    buffer-copy locked_clients to tt-clients.
    create tt-person.
    buffer-copy locked_person to tt-person.
  end.
  else do:
    create tt-clients.
    create tt-person.
    assign
    tt-clients.obj-type = 'орг':U
    tt-clients.obj-code = 0
    tt-clients.grp-code = p-grp-code
    tt-person.psn-code = tt-clients.obj-code
    tt-clients.stts = 0
    .
 end.
 if p-mode <> 'ДОБАВЛЕНИЕ':U  then do:
  FOR EACH buf_staff NO-LOCK WHERE
          buf_staff.psn-code = tt-person.psn-code :
    CREATE buf_tt-staff.
    BUFFER-COPY buf_staff TO buf_tt-staff.
  END.
end.
END PROCEDURE.
PROCEDURE Myenable :
define variable log-res as logical no-undo .
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
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,output log-res
    )  .
end.
ASSIGN
rs-gender:RADIO-BUTTONS IN FRAME Dialog-Frame =  "Муж" + chr(44) + STRING(NO) + chr(44) +
                           "Жен" + chr(44) + STRING(yes) + chr(44) +
                           "?" + chr(44) + chr(63)
.
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
if can-find(first ub.cash-desk no-lock where
                ub.cash-desk.db-num = v-cntxt-db-num
             and ub.cash-desk.pos-type = 'MAGIA-XML':U) then do:
  assign
  is-magia = yes
  .
end.
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
rs-gender = string(tt-person.gender).
b-add:MENU-MOUSE in frame Dialog-Frame  = 1.
assign
tt-person.post-address:column = tt-person.address:column
tt-person.post-address:label = tt-person.address:label
tt-person.post-city:column = tt-person.city:column
tt-person.post-city:label = tt-person.city:label
tt-person.post-ind:column = tt-person.ind:column
tt-person.post-ind:label = tt-person.ind:label
jj_change-address = 0
.
IF AVAILABLE tt-clients THEN
  DISPLAY
  tt-clients.obj-name
  tt-clients.lim-kr
  tt-clients.PS
  tt-clients.turnover-buyer
  tt-clients.turnover-buyer-gds
  tt-clients.reg-code
  WITH FRAME Dialog-Frame.
IF AVAILABLE tt-person THEN
  DISPLAY
  tt-person.psn-code
  tt-person.date-birth
  rs-gender
  tt-person.name2
  tt-person.name1
  tt-person.firm-name
  tt-person.position
  tt-person.inn
  t-check-inn when p-mode <> 'ПРОСМОТР':U
  tt-person.is-pboul
  tt-person.kpp
  tt-person.phone1
  tt-person.phone1-note
  tt-person.fax
  tt-person.e-mail
  tt-person.city
  tt-person.ind
  tt-person.address
  tt-person.post-box
  tt-person.passp-ser
  tt-person.passp-num
  tt-person.given-by
  WITH FRAME Dialog-Frame.
assign
frame Dialog-Frame :title = "Ч Е Л О В Е К:физич. лицо" + chr(32) + p-mode
.
if p-mode <> 'ПРОСМОТР':U then do:
  ENABLE
  B-exit
  b-quit
  b-dc   when p-mode <> 'ДОБАВЛЕНИЕ':U and p-callpoint <> "discards":U
  b-bank
  Docs   when p-mode <> 'ДОБАВЛЕНИЕ':U and v-cntxt-level = 'object':U
  b-org  when p-mode <> 'ДОБАВЛЕНИЕ':U and v-cntxt-level = 'object':U
  b-add when p-mode = 'ДОБАВЛЕНИЕ':U and lookup(p-callpoint, 'C,S':U) > 0
  b-del when p-mode = 'ДОБАВЛЕНИЕ':U and lookup(p-callpoint, 'C,S':U) > 0
  b-hist when p-mode <> 'ДОБАВЛЕНИЕ':U
  B-Help
  b-region when p-mode <> 'ПРОСМОТР':U
  tt-person.psn-code  when p-mode = 'ДОБАВЛЕНИЕ':U
  tt-person.date-birth
  RS-gender
  tt-clients.obj-name
  tt-person.name2
  tt-person.name1
  tt-person.firm-name
  tt-person.position
  tt-person.inn
  t-check-inn when nocorinn
  tt-person.kpp
  tt-person.phone1
  tt-person.phone1-note
  tt-person.fax
  tt-person.e-mail
  tt-person.is-pboul
  tt-person.post-box
  tt-person.passp-ser
  tt-person.passp-num
  tt-person.given-by
  tt-clients.lim-kr when log-res
  tt-clients.PS
  br-staff
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
  b-dc   when p-callpoint <> "discards":U and  v-cntxt-level = 'object':U
  b-bank
  Docs when  v-cntxt-level = 'object':U
  b-org WHEN  v-cntxt-level = 'object':U
  b-hist
  B-Help
  br-staff
  tt-clients.PS
  b-attr
  jj_change-address
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
MENU-ITEM m-choose:SENSITIVE IN MENU MENU-psn-code = (p-mode = 'ДОБАВЛЕНИЕ':U) .
if p-mode <> 'ДОБАВЛЕНИЕ':U then DO:
  menu-item m_cashier:sensitive in menu menu-b-add = no.
  menu-item m_seller:sensitive in menu menu-b-add = no.
  HIDE
  b-add
  b-del
  IN FRAME Dialog-Frame.
END.
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
  define variable v-use-child as logical   no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if not ( v-use-grp-buy or v-use-oborot-buy ) then
   hide tt-clients.turnover-buyer tt-clients.turnover-buyer-gds in frame Dialog-Frame.
OPEN QUERY br-staff FOR  EACH tt-staff INDEXED-REPOSITION.
VIEW FRAME Dialog-Frame.
APPLY "VALUE-CHANGED":U TO jj_change-address IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-add-staff :
DEFINE INPUT PARAMETER p-role AS CHARACTER NO-UNDO.
run ref/rolei.p (
                input parparentproc
               ,input (IF p-mode = 'ДОБАВЛЕНИЕ':U
                       THEN ('ДОБАВЛЕНИЕ':U + chr(44) + 'temp':U)
                       ELSE p-mode)
               ,INPUT tt-clients.obj-code
               ,INPut p-role
               ,input 'db':U
               ,INPUT-OUTPUT p-rid
               ,input-output table tt-staff
               ) no-error.
IF error-status:ERROR  THEN do:
   message error-status:get-message(1) return-value
   view-as alert-box error .
   UNDO, RETURN .
 end.
OPEN QUERY br-staff FOR  EACH tt-staff INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE Proc-save :
define variable int-buf as integer no-undo .
define variable psw-buf as integer no-undo .
define variable glog as logical no-undo .
define variable v-no-check-inn as logical no-undo .
define variable ii as integer no-undo .
define variable v-return-value as character no-undo .
define variable v-staff-input as logical no-undo .
define buffer buf_tt-staff for tt-staff.
if p-mode = 'ДОБАВЛЕНИЕ':U  then
assign
frame Dialog-Frame
tt-person.psn-code
.
if p-mode = 'ДОБАВЛЕНИЕ':U
and lookup( p-callpoint, 'C,S':U)  > 0
then do:
  for each buf_tt-staff :
    if buf_tt-staff.role = p-callpoint then do:
      v-staff-input = yes.
      leave.
    end.
  end.
  if v-staff-input = no then do:
    message
    substitute("Вы находитесь в режиме ввода физических лиц <&2>&1" +
              "однако Вы пытаетесь ввести данные по физ. лицу, не вводя данные для роли <&2>"
              , chr(10)
              , entry (lookup (p-callpoint, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
              )
    view-as alert-box error .
    undo, return error .
  end.
end.
IF tt-person.address:VISIBLE IN FRAME Dialog-Frame then
ASSIGN tt-person.address.
IF tt-person.city:VISIBLE IN FRAME Dialog-Frame then
ASSIGN tt-person.city.
IF tt-person.ind:VISIBLE IN FRAME Dialog-Frame then
ASSIGN tt-person.ind.
IF tt-person.post-address:VISIBLE IN FRAME Dialog-Frame then
ASSIGN tt-person.post-address.
IF tt-person.post-city:VISIBLE IN FRAME Dialog-Frame then
ASSIGN tt-person.post-city.
IF tt-person.post-ind:VISIBLE IN FRAME Dialog-Frame then
ASSIGN tt-person.post-ind.
IF (tt-person.address <> ''
or tt-person.city <> ''
OR tt-person.ind <> 0)
AND (tt-person.post-city = ''
     AND
     tt-person.post-address = ''
     AND
    tt-person.post-ind = 0) THEN DO:
  message
  substitute("Вы заполнили (некоторые) поля адреса РЕГИСТРАЦИИ,&1" +
             "но не заполнили ни одного поля ПОЧТОВОГО адреса&1" +
             "Скопировать поля адреса РЕГИСТРАЦИИ в поля ПОЧТОВОГО адреса?"
             , chr(10))
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF glog THEN DO:
      ASSIGN
      tt-person.post-address = tt-person.address
      tt-person.post-city = tt-person.city
      tt-person.post-ind = tt-person.ind
      .
      DISPLAY
      tt-person.post-address
      tt-person.post-city
      tt-person.post-ind
      WITH FRAME Dialog-Frame.
  END.
END.
assign
tt-person.firm-name
rs-gender
tt-person.gender = IF rs-gender = chr(63) THEN ? ELSE LOGICAL(rs-gender)
tt-person.date-birth
tt-person.position
tt-person.phone1
tt-person.phone1-note
tt-person.e-mail
tt-person.fax
tt-person.post-box
tt-person.is-pboul
tt-person.given-by
tt-person.passp-num = IF tt-person.passp-num:SCREEN-VALUE = ? THEN "":U ELSE tt-person.passp-num:SCREEN-VALUE
tt-person.passp-num = trim(tt-person.passp-num)
tt-person.passp-ser
tt-clients.obj-name
tt-clients.PS
tt-clients.lim-kr
tt-person.inn
t-check-inn
tt-person.kpp
tt-person.name1
tt-person.name2
.
_ii:
do ii = 1 to (if nocorinn AND T-check-inn then 2 else 1):
  run ref/person1.p (
                input parparentproc
               ,input this-procedure:handle
              ,input-output p-rid
              ,input p-mode
              ,input p-callpoint
              ,input no
              ,input tt-person.psn-code
              ,input tt-clients.stts
              ,input tt-clients.obj-name
              ,input tt-clients.lim-kr
              ,input tt-clients.PS
              ,input tt-clients.grp-code
              ,input tt-person.address
              ,input tt-person.city
              ,input tt-person.date-birth
              ,input tt-person.e-mail
              ,input tt-person.fax
              ,input tt-person.firm-code
              ,input tt-person.firm-name
              ,input tt-person.gender
              ,input tt-person.given-by
              ,input tt-person.ind
              ,input tt-person.inn
              ,input (v-no-check-inn OR NOT t-check-inn)
              ,input tt-person.is-pboul
              ,input tt-person.kpp
              ,input tt-person.name1
              ,input tt-person.name2
              ,input tt-person.okonh
              ,input tt-person.okpo
              ,input tt-person.passp-num
              ,input tt-person.passp-ser
              ,input tt-person.phone1
              ,input tt-person.phone1-note
              ,input tt-person.position
              ,input tt-person.post-box
              ,input tt-person.post-address
              ,input tt-person.post-city
              ,input tt-person.post-ind
              ,input tt-clients.reg-code
              ,input tt-clients.turnover-buyer
              ,input tt-clients.turnover-buyer-gds
  ) no-error .
  if error-status:error then do:
    v-return-value = return-value.
    if v-return-value = "inn" and nocorinn then do:
      message
      "Введенный ИНН некорректен или не является ИНН для Вашей страны" skip
      "Подтверждаете ввод ТАКОГО ИНН?"
      view-as alert-box question buttons yes-no update v-no-check-inn.
      if not v-no-check-inn then undo, return error .
      next _ii.
    end.
    if v-return-value = 'inn-uniq' then do:
      v-return-value = 'inn'.
    end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    message
    v-return-value view-as alert-box error .
    undo, return error.
  end.
  ELSE LEAVE _ii.
end.
END PROCEDURE.
