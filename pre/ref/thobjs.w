DEFINE BUFFER X_clients FOR ub.clients.
define input        parameter parparentproc     as widget-handle no-undo .
define input        parameter p-callback-handle as handle no-undo .
define input        parameter p-bttns             as character     no-undo .
DEFINE INPUT        PARAMETER p-list-mode       AS CHARACTER     NO-UNDO.
DEFINE INPUT        PARAMETER p-obj-type        AS character     NO-UNDO.
DEFINE INPUT        PARAMETER p-db-num          AS INTEGER       NO-UNDO.
DEFINE INPUT        PARAMETER p-host-code       AS INTEGER       NO-UNDO.
define input-output parameter p-rid-list        as character     no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список объектов ТН".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message (1)).
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-b-attr :
define input parameter p-mode as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable v-sts as integer no-undo .
define variable vattr-codes as character no-undo .
define variable vattr-labels as character no-undo .
define variable ii as integer no-undo .
define variable v-attr-code like ub.clients-attr.attr-code no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical   no-undo .
define variable attr-value as char no-undo .
define variable v-spr as character no-undo .
define variable v-title as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ok as integer no-undo .
define variable v-rid-list as character no-undo .
define variable v-rec as recid no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-firm-code as integer   no-undo .
define variable v-from-obj-code  as integer no-undo .
define variable v-found as decimal no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_db for ub.db.
do
on error undo, return error
:
assign
vattr-codes = "":U
vattr-labels = "":U
.
_II:
DO ii = 1 to num-entries('autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U):
  run thbjattr_code (
                       input entry(ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U)
                      ,input   '':U
                      ,output  attr-label
                      ,output  attr-user-can-edit
                      ,output  attr-output-display
                      ,output  attr-other
                      ,output v-prop-list
                      ,output v-prop-type-list
                      ,output v-prop-label-list
                      ,output v-global
                      ,output v-host
                      ,output v-shop
                      ,output v-store
                      ,output v-db
                    ) no-error.
    .
    if NOT error-status:error
    and attr-user-can-edit
    and index(attr-other, "spr-ext=") > 0
    anD (if p-obj-type = 'маг':U
         then v-shop
         else (if p-obj-type = 'скл':U
               then v-store
               else (if p-obj-type = 'орг':U
                     then v-host
                     else (if p-obj-type = 'БД':U
                          then v-db
                          else v-global)
                    )
               )
         ) then do:
      if entry(ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U) = 'alias-tpsi':U then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'tpsi'
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
        if error-status:error
        or (conf-par <> "yes") then next _ii.
      end.
      assign
      vattr-codes = vattr-codes + chr(44) + entry(ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-autotank,cd-type-maria,arh-global,nakl_par,contr-in,rt-trn-doc,overval,inv-obj,rezerv-obj,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,report-glob,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U)
      vattr-labels = vattr-labels + chr(44) + attr-label
      .
    end.
end.
CASE p-mode:
  when 'ПРОСМОТР':U then do:
    assign
    v-title = "Выберите типы параметров для просмотра".
  end.
  when 'ИЗМЕНЕНИЕ':U then do:
    assign
    v-title = "Выберите типы параметров для редактирования".
  end.
  when  'КОПИРОВАНИЕ':U then do:
    assign
    v-title = "Выберите типы параметров для копирования".
  end.
END CASE.
run gbl/d-list.w (
               INPUT (if p-mode = 'КОПИРОВАНИЕ':U then "b-sel,b-mark":U else "b-sel":U)
              ,INPUT v-title
              ,INPUT vattr-codes
              ,INPUT vattr-labels
              ,INPUT chr(44)
              ,INPUT "":U
              ,output v-attr-code).
IF v-attr-code = "":u THEN do:
  RETURN ''.
end.
if p-mode = 'ПРОСМОТР':U
or p-mode = 'ИЗМЕНЕНИЕ':U then do:
  run thbjattr_code  in this-procedure (
       input   v-attr-code
      ,input   '':U
      ,output  attr-label
      ,output  attr-user-can-edit
      ,output  attr-output-display
      ,output  attr-other
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
  ).
  do ii = 1 to num-entries(attr-other, chr(47)):
    if entry(ii, attr-other, chr(47)) begins "spr-ext=":U then do:
      assign
      v-spr = entry(2, entry(ii, attr-other, chr(47)), "=").
    end.
  end.
  run value(v-spr) (
                   input parparentproc
                  ,input p-mode
                  ,input p-obj-type
                  ,input p-obj-code
                  ).
end.
else do:
   if p-obj-type = 'маг':U then do:
    message
    "Выберите магазин для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
      run adm/shops.w ( input parparentproc
                       ,input "b-sel"
                       ,input-output v-rid-list
                       ,no ).
     if v-rid-list = "":U then return.
     find first buf_shop no-lock where
              recid(buf_shop) = integer(v-rid-list) .
     v-from-obj-code = buf_shop.obj-code.
   end.
   if p-obj-type = 'орг':U then do:
      message
      "Выберите ФИРМУ для копирования ПАРАМЕТРОВ"
      view-as alert-box WARNING.
      run adm/sconfs.w (
            input parParentProc
          , input "b-sel":U
          , input no
          , input 0
          , output v-firm-code
          , input-output v-rid-list
      ) no-error.
      if v-rid-list = "":U then return.
    find first buf_sysconf no-lock
                      where recid(buf_sysconf) = integer(entry(1, v-rid-list)).
    v-from-obj-code = buf_sysconf.host-code.
   end.
   if p-obj-type = 'скл':U then do:
    message
    "Выберите склад для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
      run adm/stores.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output v-rid-list
                        ,input no ).
     if v-rid-list = "":U then return.
     find first buf_store no-lock where
              recid(buf_store) = integer(v-rid-list) .
     v-from-obj-code = buf_store.obj-code.
   end.
   if p-obj-type = 'БД':U then do:
      message
      "Выберите БД для копирования ПАРАМЕТРОВ"
      view-as alert-box WARNING.
      run adm/dbs.w (
            input parParentProc
          , input 'ПРОСМОТР':U
          , output v-rec
      ) no-error.
      if v-rec = ? then return.
    find first buf_db no-lock
                      where recid(buf_db) = v-rec.
    v-from-obj-code = buf_db.db-num.
   end.
   if (p-obj-type = 'маг':U
   AND p-obj-code = buf_shop.obj-code )
   or (p-obj-type = 'скл':U
   AND p-obj-code = buf_store.obj-code )
   or (p-obj-type = 'орг':U
   AND p-obj-code = buf_sysconf.host-code )
   or (p-obj-type = 'БД':U
   AND p-obj-code = buf_db.db-num )
   or (p-obj-type = '':U
   AND p-obj-code = 0 )
   then do:
     message "Нельзя копировать ПАРАМЕТРЫ самих в себя"
     view-as alert-box error .
     return error .
   end.
   run waitfram-show in this-procedure ( input "Ждите..." ).
   DO ii = 1 to num-entries(v-attr-code):
      for each thbjattr_thbj-attr:
        delete thbjattr_thbj-attr.
      end.
      assign
      v-ii = v-ii + 1.
      run thbjattr_get-section  in this-procedure (
           input  p-obj-type
          ,input  v-from-obj-code
          ,input  entry(ii, v-attr-code)
          ,input '':U
          ,input-output table thbjattr_thbj-attr
          ,output v-found
                                              ) no-error .
      if not error-status:error then do:
        run thbjattr_set-section in this-procedure (
                                               input p-obj-type
                                              ,input p-obj-code
                                              ,input entry(ii, v-attr-code)
                                              ,input table thbjattr_thbj-attr ) no-error .
        if not error-status:error then
        assign
        v-ok = v-ok + 1
        .
      end.
   end.
   run waitfram-hide in this-procedure .
   if v-ii = v-ok then do:
      message
      substitute("Скопировано &1 параметров с &4&5 на &2&3"
                 , v-ok
                 , p-obj-type
                 , p-obj-code
                 , p-obj-type
                 , v-from-obj-code
                 )
      view-as alert-box .
   end.
   else do:
      message
      substitute("Из &1 параметров удалось скопировать &2 параметров с &3&4 на &5&6"
                 , v-ii
                 , v-ok
                 , p-obj-type
                 , p-obj-code
                 , p-obj-type
                 , v-from-obj-code
                 )
      view-as alert-box WARNING.
   end.
end.
end.
end procedure.
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
define temp-table x_obj-group no-undo like ub.clients  .
define temp-table x_grp-obj-price no-undo like ub.grp-obj-price .
procedure metod-gop-obj :
  do
  on error undo, return error return-value
  :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-gop-id       as integer   no-undo .
define input  parameter p-gop-db-num   as integer   no-undo .
define buffer buf1_clients for ub.clients  .
define buffer buf_db-grp-obj-price   for ub.db-grp-obj-price  .
define buffer buf_host-grp-obj-price for ub.host-grp-obj-price  .
define buffer buf_obj-grp-obj-price  for ub.obj-grp-obj-price  .
for each  x_obj-group : delete x_obj-group. end.
if p-gop-id = 0 or p-gop-id = ?  then do:
   if p-cntxt-db-num = 0  then do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  )
                and
                buf1_clients.db-num >= 0  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
   else do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  ) and
                 buf1_clients.db-num = p-cntxt-db-num  and
                 buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
end.
else do:
      for each buf_db-grp-obj-price  where
              buf_db-grp-obj-price.gop-id     = p-gop-id and
              buf_db-grp-obj-price.gop-db-num = p-gop-db-num and
              buf_db-grp-obj-price.stts = 0  no-lock :
        for each buf1_clients no-lock where
               (buf1_clients.obj-type = 'маг':U  or
                buf1_clients.obj-type = 'скл':U  ) and
                buf1_clients.db-num = buf_db-grp-obj-price.dgo-db-num  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
      end.
    for each buf_host-grp-obj-price where
            buf_host-grp-obj-price.gop-id     = p-gop-id and
            buf_host-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_host-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
             (buf1_clients.obj-type = 'маг':U  or
              buf1_clients.obj-type = 'скл':U  ) and
              buf1_clients.host-code = buf_host-grp-obj-price.host-code and
              buf1_clients.stts = 0
              :
          find first x_obj-group no-lock  where
                    x_obj-group.obj-code   = buf1_clients.obj-code and
                    x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
    for each buf_obj-grp-obj-price where
            buf_obj-grp-obj-price.gop-id     = p-gop-id and
            buf_obj-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_obj-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
                buf1_clients.obj-type = buf_obj-grp-obj-price.obj-type and
                buf1_clients.obj-code = buf_obj-grp-obj-price.obj-code and
                buf1_clients.stts     = 0
                :
          find first  x_obj-group no-lock  where
                      x_obj-group.obj-code   = buf1_clients.obj-code and
                      x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
end.
end.
end procedure.
procedure metod-obj-in-gop :
define input  parameter p-curr-db-num as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer buf_grp-obj-price for ub.grp-obj-price  .
  do
  on error undo, return error return-value
  :
    empty temp-table x_grp-obj-price.
    for each buf_grp-obj-price where
             buf_grp-obj-price.stts = 0
             no-lock :
               run metod-gop-obj (p-curr-db-num , buf_grp-obj-price.gop-id ,buf_grp-obj-price.gop-db-num) .
               for each x_obj-group where
                        x_obj-group.obj-type = p-obj-type and
                        x_obj-group.obj-code = p-obj-code :
                    create  x_grp-obj-price.
                    buffer-copy buf_grp-obj-price to x_grp-obj-price .
               end.
    end.
  end.
end procedure.
procedure metod-delobj-usr :
define input  parameter p-pdf-id  as integer   no-undo .
define input  parameter p-pdf-db  as integer   no-undo .
define input  parameter p-plt-id  as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
for each buf_price-doc-forming-attr no-lock  where
         buf_price-doc-forming-attr.pdf-id =     p-pdf-id and
         buf_price-doc-forming-attr.pdf-db =     p-pdf-db and
         buf_price-doc-forming-attr.plt-id =     p-plt-id and
         buf_price-doc-forming-attr.plt-db-num = p-plt-db-num and
         buf_price-doc-forming-attr.attr-code begins "obj" :
   for each x_obj-group  where
            x_obj-group.obj-type = substring(buf_price-doc-forming-attr.attr-code,4,3) and
            x_obj-group.obj-code = int(substring(buf_price-doc-forming-attr.attr-code,7,20)) :
     delete x_obj-group.
   end.
end.
  if not can-find (first x_obj-group) then do:
     return "nullobj" .
  end.
end.
end procedure.
procedure metod-obj-pdf :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-pdf-id     like ub.price-doc-forming.pdf-id   no-undo .
define input  parameter p-pdf-db-num like ub.price-doc-forming.pdf-db   no-undo .
define input  parameter p-plt-id     like ub.price-doc-forming.plt-id   no-undo .
define input  parameter p-plt-db-num like ub.price-doc-forming.plt-db-num  no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
  do
  on error undo, return error return-value
  :
 for each  x_obj-group : delete x_obj-group. end.
 find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id = p-plt-id and
            buf_price-list-type.plt-db-num = p-plt-db-num no-error .
if error-status :error then return error return-value .
 find first buf_price-doc-forming no-lock where
            buf_price-doc-forming.plt-id     = p-plt-id and
            buf_price-doc-forming.plt-db-num = p-plt-db-num and
            buf_price-doc-forming.pdf-id     = p-pdf-id and
            buf_price-doc-forming.pdf-db     = p-pdf-db-num
            no-error .
if error-status :error then return error return-value .
  run metod-gop-obj in this-procedure (
      p-cntxt-db-num,
      buf_price-list-type.gop-id ,
      buf_price-list-type.gop-db-num
      ) no-error .
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) no-error .
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table x_obj-grp-obj-price no-undo like ub.obj-grp-obj-price .
procedure metod-gop-obj-all :
define input  parameter p-curr-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
 empty temp-table x_obj-group .
 empty temp-table x_obj-grp-obj-price .
 define buffer buf_grp-obj-price for ub.grp-obj-price  .
 for each buf_grp-obj-price no-lock where
          buf_grp-obj-price.stts = 0 :
      run metod-gop-obj in this-procedure (
          input  p-curr-db-num ,
          input  buf_grp-obj-price.gop-id       ,
          input  buf_grp-obj-price.gop-db-num   ).
          for each x_obj-group :
             create x_obj-grp-obj-price.
             buffer-copy buf_grp-obj-price to x_obj-grp-obj-price
             assign
                x_obj-grp-obj-price.obj-type = x_obj-group.obj-type
                x_obj-grp-obj-price.obj-code = x_obj-group.obj-code
             .
          end.
 end.
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION price-grp RETURNS CHARACTER
(buffer buf_clients for ub.clients):
define variable tt-grp-obj as character no-undo .
tt-grp-obj =  "" .
  for each x_obj-grp-obj-price  where
           x_obj-grp-obj-price.stts = 0 and
           x_obj-grp-obj-price.obj-type = buf_clients.obj-type and
           x_obj-grp-obj-price.obj-code = buf_clients.obj-code :
           tt-grp-obj = tt-grp-obj + string(x_obj-grp-obj-price.gop-id ) +
           ( if x_obj-grp-obj-price.gop-db-num = 0 then "" else
           "БД"  + string (x_obj-grp-obj-price.gop-db-num)) + "," .
  end.
return trim(tt-grp-obj, ",") .
END FUNCTION.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable attr-option as character no-undo .
define variable add-option as character no-undo .
define variable cli-attr-option as character no-undo .
define variable v-is-deploy as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-grp as character no-undo .
define variable v-exist-price-grp as logical   no-undo .
define variable sort-column-name as character no-undo.
define variable filter-point     as character NO-UNDO INIT "thobjs".
define variable filter-label     as character NO-UNDO INIT "Объекты TH".
define variable filter-point0     as character NO-UNDO INIT "thobjs".
define variable filter-label0     as character NO-UNDO INIT "Объекты TH".
define variable v-new-selection-flag as logical no-undo .
DEFINE VARIABLE v-list-mode AS CHARACTER NO-UNDO.
define variable v-shop as character no-undo .
define variable v-stock as character no-undo .
DEFINE VARIABLE v-all AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-list-option AS CHARACTER NO-UNDO.
define stream sout.
DEFINE BUFFER buf_db FOR ub.db.
DEFINE BUFFER buf_sysclients FOR ub.clients.
v-shop = 'маг':U.
v-stock = 'скл':U.
v-all = 'все':U.
FUNCTION get-host-name RETURNS CHARACTER
  ( INPUT p-host-code AS INTEGER )  FORWARD.
FUNCTION get-shift-on RETURNS LOGICAL
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS INTEGER )  FORWARD.
FUNCTION mark-string RETURNS CHARACTER
( input p-recid as recid, input mark-list as character  )  FORWARD.
DEFINE MENU MENU-B-add
       MENU-ITEM m_add-shop     LABEL "Магазин"
       MENU-ITEM m_add-store    LABEL "Склад"         .
DEFINE MENU MENU-B-attr
       MENU-ITEM m_lookup       LABEL "&Просмотр"
       MENU-ITEM m_update       LABEL "&Изменение"
       MENU-ITEM m_copy         LABEL "&Копирование"
       RULE
       MENU-ITEM m_price-grp    LABEL "Группа &ценообразования".
DEFINE MENU MENU-B-cli-attr
       MENU-ITEM m_lookup-cli   LABEL "&Просмотр"
       MENU-ITEM m_update-cli   LABEL "&Изменение"    .
DEFINE MENU MENU-B-list
       MENU-ITEM m_list-export  LABEL "Сохранить"
       MENU-ITEM m_list-import  LABEL "Загрузить"
       RULE
       MENU-ITEM m_list-export-db LABEL "Сохранить в хранимом списке"
       MENU-ITEM m_list-import-db LABEL "Загрузить из хранимого списка".
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-attr
     LABEL "&Параметры"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-cli-attr
     LABEL "&Атрибуты"
     SIZE 10 BY 1.
DEFINE BUTTON B-db
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-dis-rule
     LABEL "&Скидки"
     SIZE 10 BY 1.
DEFINE BUTTON B-grp
     LABEL "&Группа"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON B-host
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-list
     LABEL "С&писок"
     SIZE 10 BY 1.
DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-price
     LABEL "&Цены"
     SIZE 10 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-right
     LABEL "&Права"
     SIZE 10 BY 1.
DEFINE BUTTON b-sch
     LABEL "Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE VARIABLE f-db-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE f-db-num AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "БД"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE f-host-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Фирма"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE f-host-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sch-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE rs-cli-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1"
     SIZE 17 BY .8 NO-UNDO.
DEFINE QUERY br-objects FOR
      X_clients SCROLLING.
DEFINE BROWSE br-objects
  QUERY br-objects NO-LOCK DISPLAY
      mark-string(recid(X_clients), v-rid-list) Format "X(1)" COLUMN-LABEL '*'
X_clients.obj-type COLUMN-LABEL "Тип " FORMAT "X(3)"
X_clients.obj-code COLUMN-LABEL "Код " FORMAT ">>>>>>>>9"
X_clients.obj-name COLUMN-LABEL "Название " FORMAT "x(80)" width 25
X_clients.host-code COLUMN-LABEL "Код фирмы " FORMAT ">>>>>>>>9"
get-host-name(INPUT X_clients.host-code) COLUMN-LABEL 'Фирма' FORMAT "x(80)" width 25
(if X_clients.stts = 0 then ' ' else '+' ) format "x(1)" column-label 'Удал'
X_clients.db-num COLUMN-LABEL "БД"
get-shift-on ( INPUT X_clients.obj-type, INPUT X_clients.obj-code) COLUMN-LABEL "Смены":L format " + / - "
X_clients.grp-name COLUMN-LABEL "Группа" format "X(255)" width 25
price-grp ( buffer X_clients ) @ v-grp COLUMN-LABEL "Группа ценообразования" FORMAT "x(80)" width 25
ENABLE
X_clients.grp-name
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 19 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 16
     B-sel AT ROW 1 COL 14 WIDGET-ID 20
     B-add AT ROW 1 COL 24 WIDGET-ID 4
     B-lkp AT ROW 1 COL 34 WIDGET-ID 14
     B-chg AT ROW 1 COL 44 WIDGET-ID 6
     B-del AT ROW 1 COL 54 WIDGET-ID 8
     B-attr AT ROW 1 COL 64 WIDGET-ID 26
     B-right AT ROW 1 COL 74 WIDGET-ID 24
     b-sch AT ROW 1 COL 86 WIDGET-ID 40
     B-print AT ROW 1 COL 89 WIDGET-ID 18
     B-hist AT ROW 1 COL 92 WIDGET-ID 12
     B-Help AT ROW 1 COL 95
     B-list AT ROW 2 COL 14 WIDGET-ID 54
     sch-code AT ROW 2 COL 27.5 COLON-ALIGNED WIDGET-ID 36
     B-cli-attr AT ROW 2 COL 54 WIDGET-ID 32
     B-price AT ROW 2 COL 64 WIDGET-ID 30
     B-dis-rule AT ROW 2 COL 74 WIDGET-ID 28
     B-grp AT ROW 2 COL 84 WIDGET-ID 34
     rs-cli-type AT ROW 2.08 COL 36.5 NO-LABEL WIDGET-ID 38
     f-host-code AT ROW 3 COL 7 COLON-ALIGNED WIDGET-ID 46
     B-host AT ROW 3 COL 15.5 WIDGET-ID 48
     f-host-name AT ROW 3 COL 17 COLON-ALIGNED NO-LABEL WIDGET-ID 50
     f-db-num AT ROW 3 COL 51 COLON-ALIGNED WIDGET-ID 42
     B-db AT ROW 3 COL 59.5 WIDGET-ID 44
     f-db-name AT ROW 3 COL 63.5 COLON-ALIGNED NO-LABEL WIDGET-ID 52
     br-objects AT ROW 4 COL 1 WIDGET-ID 100
     mark-num AT ROW 2 COL 1.5 NO-LABEL WIDGET-ID 22
     SPACE(88.20) SKIP(20.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Объекты"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.
ASSIGN
       B-attr:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-attr:HANDLE.
ASSIGN
       B-cli-attr:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-cli-attr:HANDLE.
ASSIGN
       B-list:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-list:HANDLE.
ASSIGN
       f-db-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-db-num:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-host-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-host-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
if add-option = '':U then do:
   run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
IF add-option = '' THEN RETURN NO-APPLY.
RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    add-option = ''.
    RETURN no-apply.
END.
add-option = ''.
END.
ON CHOOSE OF B-attr IN FRAME Dialog-Frame
DO:
define variable v-param as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
if not available X_clients then return no-apply.
if attr-option = '':U then do:
   run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if attr-option = '':U then return no-apply.
if attr-option = 'ИЗМЕНЕНИЕ':U
or attr-option = 'КОПИРОВАНИЕ':U
then do:
  if v-cntxt-db-num <> 0
  then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  X_clients.obj-type
  ,input  X_clients.obj-code
  ,output v-db-num
  )  .
    if v-db-num <> v-cntxt-db-num then do:
      message
      "Нельзя менять ПАРАМЕТРЫ в чужой УБД"
      view-as alert-box error .
      return no-apply.
    end.
  end.
end.
run proc-b-attr in this-procedure (
                                    input attr-option
                                   ,input X_clients.obj-type
                                   ,input X_clients.obj-code) no-error .
if error-status:error then do:
  assign
  attr-option = "":u.
  return no-apply.
end.
attr-option = "":u.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
  define variable ri as recid no-undo.
  if available X_clients then do:
    CASE X_clients.obj-type:
      WHEN 'маг':U THEN DO:
          ri = recid (X_clients).
          run adm/shopi.w ( input parparentproc
                           ,input  X_clients.host-code
                           ,input X_clients.obj-code
                           ,INPUT 'ИЗМЕНЕНИЕ':U
                           ,input-output ri).
          display
          X_clients.obj-name
          X_clients.grp-name
          with browse br-objects.
      END.
      WHEN 'скл':U THEN DO:
      ri = recid (X_clients).
      run adm/storei.w ( input parparentproc
                        ,input v-cntxt-host-code-obj
                        ,input X_clients.obj-code
                        ,input 'ИЗМЕНЕНИЕ':U
                        ,input-output ri).
      display
      X_clients.obj-name
      X_clients.grp-name
      with browse br-objects.
      END.
    END CASE.
  end.
END.
ON CHOOSE OF B-cli-attr IN FRAME Dialog-Frame
DO:
 define variable v-updated as logical no-undo .
 define variable v-is-error as logical no-undo .
 define variable v-db-num as integer no-undo .
 define variable ri as recid no-undo .
  if not available X_clients then do:
    return no-apply.
  end.
  ri = recid(X_clients).
  if cli-attr-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if cli-attr-option = "":U then do:
      return no-apply.
  end.
  if cli-attr-option = 'ИЗМЕНЕНИЕ':U
  or cli-attr-option = 'КОПИРОВАНИЕ':U then do:
    if v-cntxt-db-num > 0 then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  X_clients.obj-type
  ,input  X_clients.obj-code
  ,output v-db-num
  )  .
      if v-db-num <> v-cntxt-db-num then do:
        message
        "Нельзя менять АТРИБУТЫ в чужой УБД"
        view-as alert-box error .
        return no-apply.
      end.
    end.
  end.
  run ref/ca-attrr.p (
                    input parparentproc
                   ,input (if lookup("b-add", p-bttns) > 0
                          AND cli-attr-option = 'ИЗМЕНЕНИЕ':U
                          then 'ИЗМЕНЕНИЕ':U
                          else 'ПРОСМОТР':U)
                   ,input X_clients.obj-type
                   ,input X_clients.obj-code
                   ,input yes
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
    assign
    cli-attr-option = "":U
    .
    undo, return no-apply.
  end.
  cli-attr-option = "":U.
END.
ON CHOOSE OF B-db IN FRAME Dialog-Frame
DO:
  run proc-b-db IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_clients THEN RETURN NO-APPLY.
  run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-dis-rule IN FRAME Dialog-Frame
DO:
define variable v-sts as integer no-undo .
define variable v-loc-rid-list as character no-undo .
if not available X_clients then return no-apply.
assign
v-sts = integer('0':U).
run ref/dis-ruls.w (
              input parparentproc
            , input 0
            , input X_clients.obj-type
            , input X_clients.obj-code
            , input "b-add":U
            , input "cli-type"
            , input 0
            , input ?
            , input 0
            , input-output v-sts
            , input-output v-loc-rid-list ) no-error .
END.
ON CHOOSE OF B-grp IN FRAME Dialog-Frame
DO:
define variable lns-cnt as integer no-undo .
define variable g-grp as character no-undo .
define variable v-gds-rec as recid no-undo.
define variable ri as recid no-undo .
define variable glog as logical no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_cli-grp for ub.cli-grp.
if not available X_clients then return no-apply.
ri = recid(X_clients).
glog = yes.
message
"Выберите группу, в которую нужно" skip
"переместить объект(-ы)."
view-as alert-box question buttons OK-Cancel update glog.
if not glog then   do:
  apply "entry" to br-objects in frame Dialog-Frame.
  return no-apply.
end.
g-grp = "".
run ref/cli-grps.w (
                   input parparentproc
                 , input 'терм':U + ",b-sel"
                 , input-output g-grp ) .
if g-grp = "" then  do:
  apply "ENTRY" to br-objects.
  return no-apply.
end.
else do transaction:
    FIND buf_cli-grp where recid( buf_cli-grp ) = integer( g-grp ) .
    if v-rid-list = "" then
    v-rid-list = string( recid( X_clients) ) .
    lns-cnt = 1.
    DO WHILE lns-cnt <= num-entries( v-rid-list ) :
      v-gds-rec = integer( entry( lns-cnt, v-rid-list ) ) .
      if lns-cnt = 1 then ri = v-gds-rec.
       FOR FIRST buf_clients WHERE RECID(buf_clients) = v-gds-rec
      on error  undo , next
      on stop   undo , next
      on endkey undo , next
      :
        buf_clients.grp-code = buf_cli-grp.node-code.
        lns-cnt = lns-cnt + 1.
      end.
    END .
    if lns-cnt < num-entries(v-rid-list) + 1 then do:
      message
      substitute("Удалось сменить группу для &1 объектов", lns-cnt - 1)
      view-as alert-box error.
    end.
    v-rid-list = "".
    mark-num = 0.
    hide mark-num in frame Dialog-Frame.
end.
run Openbr in this-procedure ( input yes, input no, input '':U).
reposition br-objects to recid ri no-error.
apply "ENTRY" to br-objects.
apply "value-changed" to br-objects.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
   define variable v-loc-rid-list as character no-undo .
  if not available X_clients then return no-apply.
     run ref/cclihist.w (
                      input parparentproc
                    , input 0
                    , input "":U
                    , input 0
                    , input "":U
                    , input "one":U
                    , input X_clients.obj-type
                    , input X_clients.obj-code
                    , input ?
                    , input ?
                    , input "":U
                    , input "":U
                    , input v-cntxt-db-num
                    , input-output v-loc-rid-list  ) no-error .
END.
ON CHOOSE OF B-host IN FRAME Dialog-Frame
DO:
  run proc-b-host IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-list IN FRAME Dialog-Frame
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
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
if not available X_clients then return no-apply.
 run ref/showcli.p (
     input parParentProc
    ,input X_clients.obj-type
    ,input X_clients.obj-code
    ).
apply "entry" to br-objects in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo .
 if v-new-selection-flag then do:
    run choose-mark in this-procedure  no-error .
    if error-status :error
    then do:
      return no-apply .
    end.
  end.
  if available X_clients then do:
    if not v-new-selection-flag then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid15 as character no-undo .
define variable v-num-entry15 as integer   no-undo .
assign
  v-str-recid15 = trim( string( recid( X_clients ) , "->>>>>>>>>>>9":U ) )
  v-num-entry15 = lookup( v-str-recid15 , v-rid-list )
.
if v-num-entry15 > 0 then do:
  assign
    entry( v-num-entry15, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid15
  .
end.
    end.
    loc#log = br-objects:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-objects:select-next-row ().
        apply "VALUE-CHANGED" to br-objects in frame Dialog-Frame.
    end.
    if not v-new-selection-flag then do:
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  end.
  apply "entry" to br-objects in frame Dialog-Frame.
END.
ON CHOOSE OF B-price IN FRAME Dialog-Frame
DO:
  if not available X_clients then return no-apply.
  define variable v-rec-list as character no-undo .
  run str/pdfobj.w
        ( input parparentproc
         ,input "all"
         ,input X_clients.obj-type
         ,input X_clients.obj-code
         ,input ?
         ,input ?
         ,input "b-add,b-del,b-chg"
         ,input-output v-rec-list
          ) no-error.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  run rep/obj-prt.p ( input parparentproc) NO-ERROR.
  APPLY "ENTRY" to br-objects.
END.
ON CHOOSE OF B-right IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_clients THEN DO:
       run adm/obj-usr.w
      (input  parparentproc
      ,input  v-cntxt-db-num
      ,input  X_clients.obj-type
      ,input  X_clients.obj-code
      ).
  END.
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
  if ( available X_clients ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive in frame Dialog-Frame = no
    then
    v-rid-list = string( recid( X_clients ) ) .
    if v-new-selection-flag then do:
      run choose-select in this-procedure  no-error .
      if error-status :error
      then do:
        undo, return no-apply .
      end.
    end.
  end.
END.
ON RETURN OF br-objects IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK of br-objects in frame Dialog-Frame DO:
  if b-sel:sensitive then
    if b-mark:sensitive then apply "choose" to b-mark in frame Dialog-Frame.
    else apply "choose" to b-sel in frame Dialog-Frame.
  else if b-chg:sensitive then apply "choose" to b-chg in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_add-shop
DO:
  assign
  add-option = 'маг':U.
  APPLY "CHOOSE" to b-add  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_add-store
DO:
  assign
  add-option = 'скл':U.
  APPLY "CHOOSE" to b-add  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_copy
DO:
  assign
  attr-option = 'КОПИРОВАНИЕ':U.
  APPLY "CHOOSE" to b-attr  in frame Dialog-Frame.
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
ON CHOOSE OF MENU-ITEM m_list-export-db
DO:
  assign
    v-list-option = "save-clob":U
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
ON CHOOSE OF MENU-ITEM m_list-import-db
DO:
  assign
    v-list-option = "load-clob":U
  .
  run proc-b-list in this-procedure
    (input v-list-option
    ) no-error.
  if error-status :error
  then do:
    return no-apply.
  end.
END.
ON CHOOSE OF MENU-ITEM m_lookup
DO:
  assign
  attr-option = 'ПРОСМОТР':U.
  APPLY "CHOOSE" to b-attr  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_lookup-cli
DO:
  assign
  cli-attr-option = 'ПРОСМОТР':U.
  APPLY "CHOOSE" to b-cli-attr  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_price-grp
DO:
  run ref/c-tppr.p
   ( input parParentProc,
     input x_clients.obj-type ,
     input x_clients.obj-code ).
  v-exist-price-grp = true .
  run metod-gop-obj-all (input v-cntxt-db-num) .
  v-grp:visible in browse br-objects = true  .
  run enable_UI.
END.
ON CHOOSE OF MENU-ITEM m_update
DO:
  assign
  attr-option = 'ИЗМЕНЕНИЕ':U.
  APPLY "CHOOSE" to b-attr  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_update-cli
DO:
  assign
  cli-attr-option = 'ИЗМЕНЕНИЕ':U.
  APPLY "CHOOSE" to b-cli-attr  in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF rs-cli-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-cli-type.
  RUN Openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
    run proc-find-code in this-procedure ( input YES, input frame Dialog-Frame sch-code) no-error.
    if error-status:error then return no-apply.
END.
ON RETURN OF sch-code IN FRAME Dialog-Frame
DO:
run proc-find-code in this-procedure ( input no, input frame Dialog-Frame sch-code) no-error.
if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-objects :handle
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
define variable v-total-select-num as integer   no-undo .
define temp-table temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
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
PROCEDURE display-select-num :
  do
  on error undo, return error return-value
  :
    assign
      mark-num = v-total-select-num
    .
    display
      mark-num
      with frame Dialog-Frame.
    if v-total-select-num = 0
    then do:
      hide
        mark-num
        in frame Dialog-Frame.
    end.
    else do:
      display
        mark-num
        with frame Dialog-Frame.
    end.
  end.
END PROCEDURE.
PROCEDURE check-selection :
  define variable v-ok as logical   no-undo .
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
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
    if available X_clients
    then do:
      find first buf_temp-user-obj
        where buf_temp-user-obj.obj-type = X_clients.obj-type
          and buf_temp-user-obj.obj-code = X_clients.obj-code
        no-error .
      if available buf_temp-user-obj
      then do:
        run userobjs_delete in this-procedure
          (input  X_clients.obj-type
          ,input  X_clients.obj-code
          ) .
      end.
      else do:
        run userobjs_append in this-procedure
          (input  X_clients.obj-type
          ,input  X_clients.obj-code
          ) .
      end.
      if last-event :function <> "MOUSE-SELECT-DBLCLICK"
      then do:
      end.
      run display-select-num in this-procedure .
    end.
  end.
END PROCEDURE.
PROCEDURE choose-select :
  define buffer buf_temp-user-obj for temp-user-obj .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      if available X_clients
      then do:
        if NOT can-do (p-bttns, "b-mark")
        then do:
        end.
        else do:
          find first buf_temp-user-obj
            no-error .
          if not available buf_temp-user-obj
          then do:
            run userobjs_append in this-procedure
              (input  X_clients.obj-type
              ,input  X_clients.obj-code
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
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
   v-doc-rec = recid(X_clients).    run OpenBR in this-procedure ( input yes, input no, input '':U).   REPOSITION br-objects to recid v-doc-rec No-ERROR.   apply 'value-changed' to br-objects.
    apply "VALUE-CHANGED" to br-objects.
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-objects :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
def var sort-labelbr-objects   as character no-undo .
def var sort-clmnbr-objects    as handle    no-undo .
def var cur-clmnbr-objects     as handle    no-undo .
def var cur-clmn-locbr-objects as integer   no-undo .
def var re-querybr-objects     as logical   initial no no-undo .
on start-search, ctrl-o of br-objects in frame Dialog-Frame do:
   run sort-brbr-objects
     (input (if available X_clients
             then recid(X_clients)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-objects :
  define input parameter p-recid as recid no-undo .
  if re-querybr-objects = no then do:
    assign
       cur-clmnbr-objects = br-objects:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-objects <> ? then sort-clmnbr-objects:column-fgcolor = 0.
    if cur-clmnbr-objects = sort-clmnbr-objects then do:
      assign
         sort-labelbr-objects = ""
         sort-clmnbr-objects = ?
      .
     end.
     else do:
       assign
         sort-labelbr-objects = cur-clmnbr-objects:label
         sort-clmnbr-objects  = cur-clmnbr-objects
         sort-clmnbr-objects:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-objects = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-objects:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-objects then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-objects = cur-clmn-locbr-objects + 1
    .
  end.
  case sort-labelbr-objects:
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(X_clients), &1&2&1)', chr(34), v-rid-list)     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when X_clients.obj-type:label in browse br-objects then DO:    assign       sort-column-name = "X_clients.obj-type"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when X_clients.obj-code:label in browse br-objects then DO:    assign       sort-column-name = "X_clients.obj-code"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when X_clients.obj-name:label in browse br-objects then DO:    assign       sort-column-name = "X_clients.obj-name"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when X_clients.host-code:label in browse br-objects then DO:    assign       sort-column-name = "X_clients.host-code"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when 'Удал'  then DO:   assign       sort-column-name = substitute('(if X_clients.stts = 0 then &1&2&1 else &1&3&1)', chr(34), chr(32), '+')     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when X_clients.db-num:label in browse br-objects then DO:    assign       sort-column-name = "X_clients.db-num"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
        when X_clients.grp-name:label in browse br-objects then DO:    assign       sort-column-name = "X_clients.grp-name"     .     run OpenBr in this-procedure ( input yes, input no, input '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr in this-procedure ( input yes, input no, input '':U).
      if sort-labelbr-objects <> "" then do:
        assign
          cur-clmnbr-objects:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-objects = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-objects to recid p-recid no-error.
    apply "value-changed" to br-objects in frame Dialog-Frame.
  end.
  apply "entry" to br-objects in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-objects:
if cur-clmnbr-objects = ? then do:
   run OpenBr in this-procedure ( input yes, input no, input '':U).
end.
else do:
   assign re-querybr-objects = yes.
   run sort-brbr-objects
     (input (if available X_clients
             then recid(X_clients)
             else ?
            )
     ).
   assign re-querybr-objects = no.
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  IF LOOKUP(p-list-mode, 'все':U + chr(44) +
                         "db" + chr(44) +
                          'фирма':U + chr(44) +
                         "cli-type") = 0  THEN DO:
     MESSAGE
     SUBSTITUTE("Неверное значение параметра p-list-mode = &1", p-list-mode)
     VIEW-AS ALERT-BOX ERROR.
     undo, RETURN ERROR.
  END.
  IF p-list-mode = "db" THEN DO:
     FIND FIRST buf_db WHERE buf_db.db-num = p-db-num NO-ERROR.
     IF NOT AVAILABLE buf_db THEN DO:
         MESSAGE
         substitute("Неверное значение параметра p-db-num = &1", p-db-num)
         VIEW-AS ALERT-BOX ERROR.
       undo, RETURN ERROR.
     END.
  END.
  ELSE DO:
    p-db-num = ?.
  END.
  IF p-list-mode = 'фирма':U THEN DO:
     IF NOT CAN-FIND(FIRST ub.sysconf WHERE ub.sysconf.host-code = p-host-code) THEN DO:
         MESSAGE
         substitute("Неверное значение параметра p-host-code = &1", p-host-code)
         VIEW-AS ALERT-BOX ERROR.
              undo, RETURN ERROR.
     END.
     FIND FIRST buf_sysclients NO-LOCK WHERE
               buf_sysclients.obj-type = 'орг':U
        AND    buf_sysclients.obj-code = p-host-code.
  END.
  ELSE DO:
     p-host-code = ?.
  END.
  IF p-list-mode = "cli-type" THEN DO:
     IF NOT (p-obj-type = 'маг':U
             OR p-obj-type = 'скл':U ) THEN DO:
        MESSAGE
         substitute("Неверное значение параметра p-oj-type = &1", p-obj-type)
         VIEW-AS ALERT-BOX ERROR.
             undo, RETURN ERROR.
     END.
  END.
  ELSE DO:
    p-obj-type = 'все':U.
  END.
  if lookup('s-deploy', p-bttns) > 0 then do:
    assign
    v-is-deploy = yes.
  end.
  v-exist-price-grp = false  .
  v-rid-list = p-rid-list.
  v-list-mode = p-list-mode.
  f-host-code = p-host-code.
  f-db-num = p-db-num.
  RUN Myenable IN THIS-PROCEDURE.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-objects as INT EXTENT 11 no-undo.
DEF VAR varmvibr-objects       as INT no-undo.
DEF VAR varmvjbr-objects       as INT no-undo.
DEF VAR varmvkbr-objects       as INT no-undo.
DEF VAR varmvlbr-objects       as INT no-undo.
DEF VAR move-elementbr-objects as INT no-undo.
def var jjbr-objects           as int no-undo.
do varmvibr-objects = 1 to EXTENT(cur-clmn-numbr-objects):
  ASSIGN cur-clmn-numbr-objects[varmvibr-objects] = varmvibr-objects.
END.
RUN start-mv-clmnbr-objects.
PROCEDURE start-mv-clmnbr-objects:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
       IF  p-list-mode = 'все':U  THEN DO:
   DO jjbr-objects = NUM-ENTRIES('1,2,3,4,5,6,7,8,9,10,11') TO 1 BY -1:
     RUN re-move-clmnbr-objects ( cur-clmn-numbr-objects[INTEGER(ENTRY (jjbr-objects, '1,2,3,4,5,6,7,8,9,10,11'))] , 1).
   END.
       END.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-objects do:
  RUN re-move-clmnbr-objects ( 1, 11).
END.
ON ctrl-cursor-left OF BROWSE br-objects do:
  RUN re-move-clmnbr-objects (11, 1).
END.
PROCEDURE re-move-clmnbr-objects:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-objects = 1 TO EXTENT(cur-clmn-numbr-objects):
    if cur-clmn-numbr-objects[varmvibr-objects] = source-column THEN cur-clmn-numbr-objects[varmvibr-objects] = -1.
  END.
  if br-objects:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-objects = source-column - 1 to target-column BY -1:
    DO varmvibr-objects = 1 TO EXTENT(cur-clmn-numbr-objects):
        if cur-clmn-numbr-objects[varmvibr-objects] = varmvjbr-objects THEN DO:
          cur-clmn-numbr-objects[varmvibr-objects] = cur-clmn-numbr-objects[varmvibr-objects] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-objects = source-column + 1 to target-column:
    DO varmvibr-objects = 1 TO EXTENT(cur-clmn-numbr-objects):
      if cur-clmn-numbr-objects[varmvibr-objects] = varmvjbr-objects THEN DO:
        cur-clmn-numbr-objects[varmvibr-objects] = cur-clmn-numbr-objects[varmvibr-objects] - 1.
      END.
    END.
  END.
  DO varmvibr-objects = 1 TO EXTENT(cur-clmn-numbr-objects):
    if cur-clmn-numbr-objects[varmvibr-objects] = -1 THEN cur-clmn-numbr-objects[varmvibr-objects] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-objects:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 1 then do:
    return .
  end.
  DO varmvibr-objects = 1 TO EXTENT(cur-clmn-numbr-objects):
    if cur-clmn-numbr-objects[varmvibr-objects] = cur-clmn-loc THEN move-elementbr-objects = varmvibr-objects.
  END.
  RUN re-move-clmnbr-objects (cur-clmn-loc, 1).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-objects:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-objects = 1 to EXTENT(cur-clmn-numbr-objects):
    RUN re-move-clmnbr-objects (cur-clmn-numbr-objects[varmvlbr-objects], varmvlbr-objects).
  END.
  RUN start-mv-clmnbr-objects.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE cb_fill-lob-res-list :
define input  parameter p-full-path as character no-undo .
define buffer buf_temp-user-obj for temp-user-obj.
output stream sout to value (p-full-path).
for each buf_temp-user-obj
on error undo, return error return-value
:
  export stream sout
  buf_temp-user-obj.obj-type
  buf_temp-user-obj.obj-code
  .
end.
output stream sout close.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY sch-code rs-cli-type f-host-code f-host-name f-db-num f-db-name
          mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-lkp B-chg B-del B-attr B-right b-sch
         B-print B-hist B-Help B-list sch-code B-cli-attr B-price B-dis-rule
         B-grp rs-cli-type f-host-code B-host f-host-name f-db-num B-db
         f-db-name br-objects mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-objects FOR EACH X_clients NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-ch0 AS HANDLE NO-UNDO.
CASE p-list-mode:
  WHEN "db" THEN do:
    f-db-num = p-db-num.
    f-db-name = buf_db.db-name.
  END.
  WHEN 'фирма':U THEN do:
    f-host-code = p-host-code.
    f-host-name = buf_sysclients.obj-name.
  END.
  WHEN "cli-type" THEN DO:
    rs-cli-type = p-obj-type.
  END.
END CASE.
ASSIGN
v-ch0 = br-objects:FIRST-COLUMN IN FRAME Dialog-Frame.
REPEAT WHILE valid-handle(v-ch0):
  IF v-ch0:LABEL = 'Фирма' THEN DO:
    v-ch0:resizable = yes.
    leave.
  END.
  v-ch0 = v-ch0:NEXT-COLUMN.
END.
rs-cli-type:RADIO-BUTTONS IN FRAME Dialog-Frame = 'все':U + chr(44) + 'все':U + chr(44) +
                                                   'маг':U + chr(44) + 'маг':U + chr(44) +
                                                   'скл':U + chr(44) + 'скл':U.
rs-cli-type = 'все':U.
v-grp:VISIBLE IN BROWSe br-objects = v-exist-price-grp .
ASSIGN
B-attr:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-attr:HANDLE
b-attr:MENU-MOUSE in frame Dialog-Frame = 1
B-cli-attr:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-cli-attr:HANDLE
b-cli-attr:MENU-MOUSE in frame Dialog-Frame = 1
b-list:menu-mouse in frame Dialog-Frame = 1
X_clients.obj-name:resizable  in browse br-objects = true
X_clients.grp-name:resizable  in browse br-objects = true
X_clients.grp-name:read-only  in browse br-objects = true
v-grp:resizable  in browse br-objects = true
.
assign
menu-item m_update:sensitive in menu menu-b-attr = (v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION)
menu-item m_copy:sensitive in menu menu-b-attr = (v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION)
menu-item m_update-cli:sensitive in menu menu-b-cli-attr = (v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION)
.
DISPLAY
sch-code
rs-cli-type
mark-num
f-host-code
f-host-name
f-db-num
f-db-name
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark WHEN LOOKUP("b-mark", p-bttns) > 0
B-sel  WHEN LOOKUP("b-sel", p-bttns) > 0
b-add WHEN v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION
b-chg WHEN v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION
b-del WHEN v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION
b-grp WHEN v-cntxt-db-num = 0 and can-do (p-bttns, "b-add") AND NOT TRANSACTION
b-list when LOOKUP("b-mark", p-bttns) > 0
B-lkp
B-attr  when not v-is-deploy
B-right
B-print when not v-is-deploy
B-hist  when not v-is-deploy
B-Help
sch-code
b-cli-attr when not v-is-deploy
B-price
B-dis-rule  when not v-is-deploy
b-sch
rs-cli-type when p-list-mode <> "cli-type"
b-db WHEN p-list-mode <> "db"
b-host WHEN p-list-mode <> 'фирма':U
br-objects
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if (lookup("b-mark", p-bttns) > 0
or  lookup("b-mark-hidden", p-bttns) > 0)
and valid-handle(p-callback-handle)
and lookup( "userobjs_transfer", p-callback-handle:internal-entries ) > 0
then do:
  v-new-selection-flag = yes.
  run userobjs_transfer in p-callback-handle
    (input this-procedure :handle
    ) .
  run display-select-num in this-procedure .
end.
else do:
  hide mark-num in frame Dialog-Frame.
end.
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
END PROCEDURE.
PROCEDURE Openbr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo init "Объекты TH".
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
filter-point = filter-point0 + v-list-mode .
case v-list-mode:
  when 'все':U then do:
    ASSIGN
    frame Dialog-Frame:title = substitute("&1", title0)
    filter-label = SUBSTITUTE("&1"
                              , frame Dialog-Frame:title
                              )
    .
   end.
   when "db" then do:
    ASSIGN
    frame Dialog-Frame:title = substitute("&1 - БД &2", title0, p-db-num)
    filter-label = SUBSTITUTE("&1"
                              , frame Dialog-Frame:title
                              )
    .
   end.
   when 'фирма':U then do:
    ASSIGN
    frame Dialog-Frame:title = substitute("&1 - Фирма &2", title0, p-host-code)
    filter-label = SUBSTITUTE("&1"
                              , frame Dialog-Frame:title
                              )
    .
   end.
   when "cli-type" then do:
    ASSIGN
    frame Dialog-Frame:title = substitute("&1 - &2", title0, p-obj-type)
    filter-label = SUBSTITUTE("&1"
                              , frame Dialog-Frame:title
                              )
    .
   end.
end case.
if f-db-num = ? then do:
  if f-host-code = ? then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-33  as logical   no-undo .
define variable  l-filter-open-33    as logical   .
define variable  flt-rec-33       as recid     no-undo .
define variable  filter-name-33      as character no-undo .
define variable  where-phrase-33     as character no-undo .
define variable  sort-phrase-33      as character no-undo .
define variable  where-phrase-rus-33 as character no-undo .
define variable  sort-phrase-rus-33  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-33
  ,output filter-name-33
  ,output where-phrase-33
  ,output sort-phrase-33
  ,output where-phrase-rus-33
  ,output sort-phrase-rus-33
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-33
      ) no-error .
  assign
    l-filter-open-33 = false
  .
  if flt-rec-33 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-33 as character no-undo .
    define variable  parameter-3-33 as character no-undo .
    define variable  parameter-4-33 as character no-undo .
    define variable  parameter-5-33 as character no-undo .
    define variable  parameter-6-33 as character no-undo .
    define variable  parameter-7-33 as character no-undo .
      assign
      parameter-3-33 =
                              "FOR EACH X_clients no-lock"
      parameter-4-33 =
        (
          if ("((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) " + " " + where-phrase-33) <> ""
          then  substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) )                     OR X_clients.obj-type = &7&1&7)'                   , rs-cli-type , f-db-num, f-host-code, 'все':U, 'маг':U, 'скл':U, chr(34))  + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "")
      parameter-6-33 = if sort-phrase-33 = ''
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
        " " + sort-phrase-33
        )
      parameter-7-33 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-33 =
          ("((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) " + " " + where-phrase-33 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-objects:handle
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
                          )
      .
      assign
        l-filter-open-33 = true
      .
    end.
    output to kkk.txt .
    put unformatted
      "glog = QUERY br-objects:handle:query-prepare (" skip
      parameter-3-33
      "where"            skip
      parameter-4-33 skip
      parameter-5-33 skip
      parameter-6-33 skip
      parameter-7-33 skip
      ")"                skip
      .
    output close .
    if l-filter-open-33 = false then do:
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
  if l-filter-open-33 = false then do:
    OPEN QUERY br-objects FOR EACH X_clients no-lock
      where ((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type)
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-objects:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-4-33 =
        "where ":u +  substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) )                     OR X_clients.obj-type = &7&1&7)'                   , rs-cli-type , f-db-num, f-host-code, 'все':U, 'маг':U, 'скл':U, chr(34))  + " ":u + where-phrase-33 + " ":u + p-find-condition + " " + ""
      parameter-5-33 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-objects:handle
                          ,input rowid(X_clients)
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input (buffer X_clients:handle)
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-33 = (if p-find-next then "true":u else "false":u )
      parameter-3-33 =  "FOR EACH X_clients no-lock"
      parameter-4-33 =
        (
          if ("((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) " + " " + where-phrase-33) <> ""
          then  substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) )                     OR X_clients.obj-type = &7&1&7)'                   , rs-cli-type , f-db-num, f-host-code, 'все':U, 'маг':U, 'скл':U, chr(34))  + " " + where-phrase-33
          else "true"
        )
      parameter-5-33 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-33 = if sort-phrase-33 = ''
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
        " " + sort-phrase-33
        )
      parameter-7-33 =
        " INDEXED-REPOSITION  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-objects:handle
                          ,input logical(parameter-2-33)
                          ,input no-lock
                          ,input parameter-3-33
                          ,input parameter-4-33
                          ,input parameter-5-33
                          ,input parameter-6-33
                          ,input parameter-7-33
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  else do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-35  as logical   no-undo .
define variable  l-filter-open-35    as logical   .
define variable  flt-rec-35       as recid     no-undo .
define variable  filter-name-35      as character no-undo .
define variable  where-phrase-35     as character no-undo .
define variable  sort-phrase-35      as character no-undo .
define variable  where-phrase-rus-35 as character no-undo .
define variable  sort-phrase-rus-35  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-35
  ,output filter-name-35
  ,output where-phrase-35
  ,output sort-phrase-35
  ,output where-phrase-rus-35
  ,output sort-phrase-rus-35
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-35
      ) no-error .
  assign
    l-filter-open-35 = false
  .
  if flt-rec-35 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-35 as character no-undo .
    define variable  parameter-3-35 as character no-undo .
    define variable  parameter-4-35 as character no-undo .
    define variable  parameter-5-35 as character no-undo .
    define variable  parameter-6-35 as character no-undo .
    define variable  parameter-7-35 as character no-undo .
      assign
      parameter-3-35 =
                              "FOR EACH X_clients no-lock"
      parameter-4-35 =
        (
          if ("((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) and                     X_clients.host-code = f-host-code " + " " + where-phrase-35) <> ""
          then  substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) )                     OR X_clients.obj-type = &7&1&7) and                     X_clients.host-code = &3 '                  , rs-cli-type , f-db-num, f-host-code, 'все':U, 'маг':U, 'скл':U, chr(34))  + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "")
      parameter-6-35 = if sort-phrase-35 = ''
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
        " " + sort-phrase-35
        )
      parameter-7-35 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-35 =
          ("((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) and                     X_clients.host-code = f-host-code " + " " + where-phrase-35 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-objects:handle
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
                          )
      .
      assign
        l-filter-open-35 = true
      .
    end.
    output to kkk.txt .
    put unformatted
      "glog = QUERY br-objects:handle:query-prepare (" skip
      parameter-3-35
      "where"            skip
      parameter-4-35 skip
      parameter-5-35 skip
      parameter-6-35 skip
      parameter-7-35 skip
      ")"                skip
      .
    output close .
    if l-filter-open-35 = false then do:
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
  if l-filter-open-35 = false then do:
    OPEN QUERY br-objects FOR EACH X_clients no-lock
      where ((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) and                     X_clients.host-code = f-host-code
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-objects:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-4-35 =
        "where ":u +  substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) )                     OR X_clients.obj-type = &7&1&7) and                     X_clients.host-code = &3 '                  , rs-cli-type , f-db-num, f-host-code, 'все':U, 'маг':U, 'скл':U, chr(34))  + " ":u + where-phrase-35 + " ":u + p-find-condition + " " + ""
      parameter-5-35 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-objects:handle
                          ,input rowid(X_clients)
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input (buffer X_clients:handle)
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-35 = (if p-find-next then "true":u else "false":u )
      parameter-3-35 =  "FOR EACH X_clients no-lock"
      parameter-4-35 =
        (
          if ("((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) and                     X_clients.host-code = f-host-code " + " " + where-phrase-35) <> ""
          then  substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) )                     OR X_clients.obj-type = &7&1&7) and                     X_clients.host-code = &3 '                  , rs-cli-type , f-db-num, f-host-code, 'все':U, 'маг':U, 'скл':U, chr(34))  + " " + where-phrase-35
          else "true"
        )
      parameter-5-35 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-35 = if sort-phrase-35 = ''
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
        " " + sort-phrase-35
        )
      parameter-7-35 =
        " INDEXED-REPOSITION  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-objects:handle
                          ,input logical(parameter-2-35)
                          ,input no-lock
                          ,input parameter-3-35
                          ,input parameter-4-35
                          ,input parameter-5-35
                          ,input parameter-6-35
                          ,input parameter-7-35
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
end.
else do:
  if f-host-code = ? then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-37  as logical   no-undo .
define variable  l-filter-open-37    as logical   .
define variable  flt-rec-37       as recid     no-undo .
define variable  filter-name-37      as character no-undo .
define variable  where-phrase-37     as character no-undo .
define variable  sort-phrase-37      as character no-undo .
define variable  where-phrase-rus-37 as character no-undo .
define variable  sort-phrase-rus-37  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-37
  ,output filter-name-37
  ,output where-phrase-37
  ,output sort-phrase-37
  ,output where-phrase-rus-37
  ,output sort-phrase-rus-37
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-37
      ) no-error .
  assign
    l-filter-open-37 = false
  .
  if flt-rec-37 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-37 as character no-undo .
    define variable  parameter-3-37 as character no-undo .
    define variable  parameter-4-37 as character no-undo .
    define variable  parameter-5-37 as character no-undo .
    define variable  parameter-6-37 as character no-undo .
    define variable  parameter-7-37 as character no-undo .
      assign
      parameter-3-37 =
                              "FOR EACH X_clients no-lock"
      parameter-4-37 =
        (
          if ("((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) and                     X_clients.db-num = f-db-num " + " " + where-phrase-37) <> ""
          then  substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) )                     OR X_clients.obj-type = &7&1&7) and                     X_clients.db-num = &2'                   , rs-cli-type , f-db-num, f-host-code, 'все':U, 'маг':U, 'скл':U, chr(34))  + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + "")
      parameter-6-37 = if sort-phrase-37 = ''
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
        " " + sort-phrase-37
        )
      parameter-7-37 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-37 =
          ("((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) and                     X_clients.db-num = f-db-num " + " " + where-phrase-37 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-objects:handle
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
                          )
      .
      assign
        l-filter-open-37 = true
      .
    end.
    output to kkk.txt .
    put unformatted
      "glog = QUERY br-objects:handle:query-prepare (" skip
      parameter-3-37
      "where"            skip
      parameter-4-37 skip
      parameter-5-37 skip
      parameter-6-37 skip
      parameter-7-37 skip
      ")"                skip
      .
    output close .
    if l-filter-open-37 = false then do:
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
  if l-filter-open-37 = false then do:
    OPEN QUERY br-objects FOR EACH X_clients no-lock
      where ((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) and                     X_clients.db-num = f-db-num
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-objects:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-4-37 =
        "where ":u +  substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) )                     OR X_clients.obj-type = &7&1&7) and                     X_clients.db-num = &2'                   , rs-cli-type , f-db-num, f-host-code, 'все':U, 'маг':U, 'скл':U, chr(34))  + " ":u + where-phrase-37 + " ":u + p-find-condition + " " + ""
      parameter-5-37 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-objects:handle
                          ,input rowid(X_clients)
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input (buffer X_clients:handle)
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-37 = (if p-find-next then "true":u else "false":u )
      parameter-3-37 =  "FOR EACH X_clients no-lock"
      parameter-4-37 =
        (
          if ("((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) and                     X_clients.db-num = f-db-num " + " " + where-phrase-37) <> ""
          then  substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) )                     OR X_clients.obj-type = &7&1&7) and                     X_clients.db-num = &2'                   , rs-cli-type , f-db-num, f-host-code, 'все':U, 'маг':U, 'скл':U, chr(34))  + " " + where-phrase-37
          else "true"
        )
      parameter-5-37 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-37 = if sort-phrase-37 = ''
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
        " " + sort-phrase-37
        )
      parameter-7-37 =
        " INDEXED-REPOSITION  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-objects:handle
                          ,input logical(parameter-2-37)
                          ,input no-lock
                          ,input parameter-3-37
                          ,input parameter-4-37
                          ,input parameter-5-37
                          ,input parameter-6-37
                          ,input parameter-7-37
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
  else do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-39  as logical   no-undo .
define variable  l-filter-open-39    as logical   .
define variable  flt-rec-39       as recid     no-undo .
define variable  filter-name-39      as character no-undo .
define variable  where-phrase-39     as character no-undo .
define variable  sort-phrase-39      as character no-undo .
define variable  where-phrase-rus-39 as character no-undo .
define variable  sort-phrase-rus-39  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-39
  ,output filter-name-39
  ,output where-phrase-39
  ,output sort-phrase-39
  ,output where-phrase-rus-39
  ,output sort-phrase-rus-39
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-39
      ) no-error .
  assign
    l-filter-open-39 = false
  .
  if flt-rec-39 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-39 as character no-undo .
    define variable  parameter-3-39 as character no-undo .
    define variable  parameter-4-39 as character no-undo .
    define variable  parameter-5-39 as character no-undo .
    define variable  parameter-6-39 as character no-undo .
    define variable  parameter-7-39 as character no-undo .
      assign
      parameter-3-39 =
                              "FOR EACH X_clients no-lock"
      parameter-4-39 =
        (
          if ("((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) and                     X_clients.db-num = f-db-num and                     X_clients.host-code = f-host-code " + " " + where-phrase-39) <> ""
          then  substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) )                     OR X_clients.obj-type = &7&1&7) and                     X_clients.db-num = &2 and                     X_clients.host-code = &3'                   , rs-cli-type , f-db-num, f-host-code, 'все':U, 'маг':U, 'скл':U, chr(34))  + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + "")
      parameter-6-39 = if sort-phrase-39 = ''
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
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-39 =
          ("((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) and                     X_clients.db-num = f-db-num and                     X_clients.host-code = f-host-code " + " " + where-phrase-39 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-objects:handle
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
                          )
      .
      assign
        l-filter-open-39 = true
      .
    end.
    output to kkk.txt .
    put unformatted
      "glog = QUERY br-objects:handle:query-prepare (" skip
      parameter-3-39
      "where"            skip
      parameter-4-39 skip
      parameter-5-39 skip
      parameter-6-39 skip
      parameter-7-39 skip
      ")"                skip
      .
    output close .
    if l-filter-open-39 = false then do:
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
  if l-filter-open-39 = false then do:
    OPEN QUERY br-objects FOR EACH X_clients no-lock
      where ((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) and                     X_clients.db-num = f-db-num and                     X_clients.host-code = f-host-code
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_clients )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-objects:handle:get-buffer-handle(1) = (buffer X_clients:handle) then do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-4-39 =
        "where ":u +  substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) )                     OR X_clients.obj-type = &7&1&7) and                     X_clients.db-num = &2 and                     X_clients.host-code = &3'                   , rs-cli-type , f-db-num, f-host-code, 'все':U, 'маг':U, 'скл':U, chr(34))  + " ":u + where-phrase-39 + " ":u + p-find-condition + " " + ""
      parameter-5-39 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-objects:handle
                          ,input rowid(X_clients)
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input (buffer X_clients:handle)
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-39 = (if p-find-next then "true":u else "false":u )
      parameter-3-39 =  "FOR EACH X_clients no-lock"
      parameter-4-39 =
        (
          if ("((rs-cli-type = 'все':U and (X_clients.obj-type = 'маг':U or X_clients.obj-type = 'скл':U) )                     OR X_clients.obj-type = rs-cli-type) and                     X_clients.db-num = f-db-num and                     X_clients.host-code = f-host-code " + " " + where-phrase-39) <> ""
          then  substitute(' ((&7&1&7 = &7&4&7 and (X_clients.obj-type = &7&5&7 or X_clients.obj-type = &7&6&7) )                     OR X_clients.obj-type = &7&1&7) and                     X_clients.db-num = &2 and                     X_clients.host-code = &3'                   , rs-cli-type , f-db-num, f-host-code, 'все':U, 'маг':U, 'скл':U, chr(34))  + " " + where-phrase-39
          else "true"
        )
      parameter-5-39 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-39 = if sort-phrase-39 = ''
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
        " " + sort-phrase-39
        )
      parameter-7-39 =
        " INDEXED-REPOSITION  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-objects:handle
                          ,input logical(parameter-2-39)
                          ,input no-lock
                          ,input parameter-3-39
                          ,input parameter-4-39
                          ,input parameter-5-39
                          ,input parameter-6-39
                          ,input parameter-7-39
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
  end.
end.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-objects to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-objects:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-objects in frame Dialog-Frame.
APPLY "ENTRY" TO br-objects.
END PROCEDURE.
PROCEDURE proc-b-add :
define variable ri as recid no-undo.
define buffer buf_clients for ub.clients.
CASE p-obj-type:
  WHEN 'маг':U THEN DO:
  run adm/shopi.w ( input parparentproc
                   ,input v-cntxt-host-code-obj
                   ,input 0
                   ,input 'ДОБАВЛЕНИЕ':U
                   ,input-output ri).
  if ri <> ? then do:
      find buf_clients where
           recid (buf_clients) = ri no-lock.
      ri = recid (buf_clients).
      run enable_UI.
      reposition br-objects to recid ri no-error.
      apply "ENTRY" to br-objects in frame Dialog-Frame .
  end.
  return no-apply.
  END.
  WHEN 'скл':U THEN DO:
      run adm/storei.w ( input parparentproc
                        ,input v-cntxt-host-code-obj
                        ,input 0
                        ,input 'ДОБАВЛЕНИЕ':U
                        ,input-output ri).
      if ri <> ? then do:
          find buf_clients where
             recid (buf_clients) = ri no-lock.
          ri = recid (buf_clients).
          run enable_UI.
          reposition br-objects to recid ri no-error.
          apply "ENTRY" to br-objects.
      end.
      return no-apply.
  END.
END CASE.
END PROCEDURE.
PROCEDURE proc-b-db :
define variable v-ri as recid no-undo .
do
  on error undo, return error
  :
  run adm/dbs.w (
             input parparentproc
           , INPUT 'ПРОСМОТР':U
           , output v-ri).
  if v-ri <> ?
  then do:
    find buf_db where recid (buf_db) = v-ri .
    assign
    f-db-num = buf_db.db-num
    f-db-name = buf_db.db-name
    .
    DISPLAY
    f-db-num
    f-db-name
    WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
    ASSIGN
    f-db-num = ?
    f-db-name = ''
    .
    DISPLAY
    f-db-num
    f-db-name
    WITH FRAME Dialog-Frame.
  END.
  RUN Openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
end.
END PROCEDURE.
PROCEDURE proc-b-del :
define variable  ri as recid no-undo.
CASE X_clients.obj-type:
  WHEN 'маг':U THEN DO:
    run ref/clients2.p ( input parparentproc
                        ,input recid(X_clients)
                        ,input ?
                        ,input no
                        ,input yes
                        ,input '':U
                        ,input '':U
                        ,input '':U
                        ) no-error .
  END.
  WHEN 'скл':U THEN DO:
    run ref/clients2.p ( input parparentproc
                        ,input recid(X_clients)
                        ,input ?
                        ,input no
                        ,input yes
                        ,input '':U
                        ,input '':U
                        ,input '':U
                        ) no-error .
  END.
END CASE.
if error-status:error then do:
  return no-apply.
end.
run Openbr in this-procedure ( input yes, input no, input '':U).
reposition br-objects to recid ri no-error.
apply "ENTRY" to br-objects in frame Dialog-Frame .
apply "value-changed" to br-objects.
END PROCEDURE.
PROCEDURE proc-b-host :
define variable ref-list as char no-undo.
DEFINE VARIABLE new-host-code AS INTEGE no-undo.
  run adm/sconfs.w (
                 input parParentProc
                ,input "b-sel":U
                ,input no
                ,input v-cntxt-host-code-obj
                ,output new-host-code
                ,input-output ref-list ) .
  .
if new-host-code = ?
or new-host-code = 0
then do:
   ASSIGN
   f-host-code = ?
   f-host-name = ''
   .
END.
ELSE DO:
  find first buf_sysclients where
            buf_sysclients.obj-type = 'орг':U
        and buf_sysclients.obj-code = new-host-code no-lock.
    ASSIGN
    f-host-code = buf_sysclients.obj-code
    f-host-name = buf_sysclients.obj-name
    .
END.
DISPLAY
f-host-code
f-host-name
WITH FRAME Dialog-Frame.
RUN Openbr IN THIS-PROCEDURE ( input yes, input no, input '':U).
END PROCEDURE.
PROCEDURE PROC-B-LIST :
define input parameter loc-list-option as character no-undo.
define variable f-name as char init "default.cli" no-undo.
define variable imp-type like goods.prod-type no-undo.
define variable imp-code like goods.prod-code no-undo.
define variable v-ok as logical no-undo .
define buffer buf_temp-user-obj for temp-user-obj .
define buffer buf_clients for clients .
define buffer buf_clob-data for ub.clob-data.
define buffer buf_clob-bind for ub.clob-bind.
do
on error undo, return error return-value
:
  case loc-list-option:
    when "save":U
    or
    when "save-clob"
    then do:
      case loc-list-option:
        when "save" then do:
          assign
          v-ok = true
          .
          message
          "Сохранить все отмеченные объекты в файле списка" skip
          "Продолжить" skip
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
        when "save-clob" then do:
          run ref/clobbnds.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input 'b-add'
                              ,input "uniq-key-rec"
                              ,input 'ИЗМЕНЕНИЕ':U
                              ,input 'list':U
                              ,input 'cli-list'
                              ,input -1
                              ,input-output v-rid-list) no-error.
        end.
      end case.
    end.
    when "load":U
    or
    when "load-clob"
    then do:
      case loc-list-option:
        when "load" then do:
          assign
          v-ok = yes
          .
          message
          "Отметить все объекты из ранее сохраненного в файле списка" skip
          "Продолжить?" skip
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
          title "Выберите файл списка?"
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
        end.
        when "load-clob" then do:
          message
          "Отметить все объекты из хранимого списка" skip
          "Продолжить?" skip
          view-as alert-box question buttons ok-cancel update v-ok .
          if v-ok <> true
          then do:
            assign
            v-list-option = "":U
            .
            return.
          end.
          run ref/clobbnds.w ( input parparentproc
                              ,input this-procedure:handle
                              ,input 'b-sel'
                              ,input "uniq-key-rec"
                              ,input ""
                              ,input 'list':U
                              ,input 'cli-list'
                              ,input -1
                              ,input-output v-rid-list) no-error.
          if v-rid-list = ''
          then do:
            assign
            v-list-option = "":U
            .
            return.
          end.
          find first buf_clob-bind where
                  recid(buf_clob-bind) = integer(v-rid-list) no-error.
          if not available buf_clob-bind then do:
            message
            "Ошибка при пополучении хранимого файла"
            view-as alert-box error.
            assign
            v-list-option = "":U
            .
            return.
          end.
          else do:
            find first buf_clob-data no-lock where
                      buf_clob-data.db-num = buf_clob-bind.db-num
                  and buf_clob-data.int64-id = buf_clob-bind.int64-id no-error.
            if error-status :error then do:
              message
              "Ошибка при пополучении хранимого файла"
              view-as alert-box error.
              return error.
            end.
            run gbl/_tmpfile.p ( input ""
                          ,input "tmp"
                          ,output f-name) .
            copy-lob from object buf_clob-data.cdata
            to file f-name.
          end.
        end.
      end case.
      input stream sout from value (f-name).
      repeat
      :
        assign
        imp-type = '':U
        imp-code = 0
        .
        import stream sout imp-type imp-code .
        find first buf_clients no-lock
          where buf_clients.obj-type = imp-type
            and buf_clients.obj-code = imp-code
          no-error .
        if available buf_clients
        and (buf_clients.obj-type = 'маг':U
        or buf_clients.obj-type = 'скл':U)
        then do:
          run userobjs_append in this-procedure
            (input  buf_clients.obj-type
            ,input  buf_clients.obj-code
            ) .
        end.
      end.
      input stream sout close.
      run display-select-num in this-procedure .
      br-objects:refresh() in frame Dialog-Frame .
      apply "entry" to br-objects in frame Dialog-Frame.
    end.
    otherwise do:
    end.
  END CASE.
  loc-list-option = "":U.
end.
END PROCEDURE.
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo .
assign
v-ri = (if avail X_clients then recid(X_clients) else ?)
.
assign
tbl = 'clients':U
join-tbl = 'X_clients'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('obj-type', 'Тип клиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-code', 'Код клиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-name', 'Названиеклиента', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('db-num', 'БД', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Код фирмы', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
DO on stop undo, leave:
    run gbl/filter.w ( INPUT parparentproc
                 ,INPUT filter-point + chr(4) + filter-label
                 ,INPUT tbl
                 ,INPUT join-tbl
                 ,INPUT fld
                 ,INput lab
                 ,INPUT spr
                 ,INPUT  dim).
    run OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
    if v-ri <> ? then do:
      reposition br-objects to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-objects in frame Dialog-Frame .
    APPLY "VALUE-CHANGED" to br-objects.
end.
END PROCEDURE.
PROCEDURE proc-find-code :
define input parameter p-next as logical no-undo.
define input parameter p-code AS INTEGER no-undo.
DEFINE VARIABLE v-code AS CHARACTER NO-UNDO.
assign
v-code = string(p-code).
if rs-cli-type = 'все':U then do:
  run OpenBr in this-procedure
      (input false
      ,input p-next
      ,input substitute(" and X_clients.obj-code = &1 "
        , v-code
        , chr(34)
        , rs-cli-type
        )
      ).
end.
else do:
  run OpenBr in this-procedure
      (input false
      ,input p-next
      ,input substitute(" and X_clients.obj-code = &1 and X_clients.obj-type = &2&3&2"
        , v-code
        , chr(34)
        , rs-cli-type
        )
      ).
end.
apply "entry":u to sch-code in frame Dialog-Frame .
END PROCEDURE.
FUNCTION get-host-name RETURNS CHARACTER
  ( INPUT p-host-code AS INTEGER ) :
DEFINE BUFFER buf_sysclients FOR ub.clients.
FIND FIRST buf_sysclients NO-LOCK WHERE
            buf_sysclients.obj-type = 'орг':U
     AND buf_sysclients.obj-code  = p-host-code NO-ERROR.
IF AVAILABLE buf_sysclients THEN RETURN buf_sysclients.obj-name.
RETURN "!!!Неизвестная фирма".
END FUNCTION.
FUNCTION get-shift-on RETURNS LOGICAL
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS INTEGER ) :
DEFINE VARIABLE l-shift-on AS LOGICAL NO-UNDO.
l-shift-on = no.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
RETURN l-shift-on.
END FUNCTION.
FUNCTION mark-string RETURNS CHARACTER
( input p-recid as recid, input mark-list as character  ) :
define variable v-mark-string as character no-undo .
if v-new-selection-flag then do:
    run get-mark-string in this-procedure
      (input  X_clients.obj-type
      ,input  X_clients.obj-code
      ,output v-mark-string
      ) .
    return v-mark-string .
END.
ELSE DO:
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END.
END FUNCTION.
