using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.bge.mercury.*.
DEFINE INPUT        PARAMETER parparentproc AS WIDGET-HANDLE  NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-gds-code    AS integer        NO-UNDO.
DEFINE INPUT        PARAMETER p-mode        as character      NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Связать товары с Меркурием".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1)).
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
define temp-table tt-gds-merq no-undo
  field ID             as integer
  field merc-name      like ub.goods.gds-name label "Полное наименование" format "X(100)"
  field UUID           as character label "UUID"
  field GUID_          as character label "GUID"
  field units          as character label "Ед.измерения"
  field units_th       as character label "Ед.измерения в ТН"
  field status_        as integer   label "Статус"
  field crDate         as date      label "Дата создания" format "99.99.9999"
  field update_Date    as date      label "Дата изменени" format "99.99.9999"
  field prod-type      as integer   label "Тип продукции" format ">>>>9"
  field prod-type-name as character label "Тип продукции"
  field GUID-type      as character label "GUID-type"
  field GUID-subtype   as character label "GUID-subtype"
  index pi as primary
  ID
  index name_ as word-index
  merc-name
  index merq
  GUID_
  .
PROCEDURE checkguid :
  define INPUT-output parameter guid_ as CHARACTER NO-UNDO .
  define OUTPUT parameter Msg as CHARACTER  NO-UNDO .
  def var ii      as int       no-undo.
  def var err     as logical   no-undo.
  def var str     as character no-undo.
  def var numentr as integer   no-undo.
  numentr = num-entries (guid_, "-") no-error.
  if numentr = 8
    then
  do:
    do ii = 1 to numentr:
      if length (trim (entry (ii, guid_, "-"))) <> 4
        then err = true.
      str = str + trim (entry (ii, guid_, "-")).
      if ii = 2 or ii = 3 or ii = 4 or ii = 5
        then
      do:
        str = str + "-".
      end.
    end.
    guid_ = str.
  end.
  numentr = num-entries (guid_, "-") no-error.
  do ii = 1 to numentr:
    case ii:
      when 1 then
        do:
          if length (trim (entry (ii, guid_, "-"))) <> 8
            then err = true.
        end.
      when 2 or
      when 3 or
      when 4 then
        do:
          if length (entry (ii, guid_, "-")) <> 4
            then err = true.
        end.
      when 5 then
        do:
          if length (entry (ii, guid_, "-")) <> 12
            then err = true.
        end.
    end case.
  end.
  if ii <> 6
    then err = true.
  if err then Msg = "Неверный формат GUID".
END PROCEDURE.
DEFINE BUFFER buf_gds-mercury for ub.gds-mercury .
DEFINE BUFFER buf_goods       for ub.goods .
define variable v-login           as character no-undo .
define variable v-password        as character no-undo .
define variable v-server          as character no-undo .
define variable v-proxy-login     as character no-undo .
define variable v-proxy-pswd      as character no-undo .
define variable v-proxy-addres    as character no-undo .
define variable v-proxy-ssl       as logical   no-undo .
define variable par-type          as character no-undo.
define variable gdsMercsubsObj    as class     gdsmercsubs.
define variable gdsMercObj        as class     gdsmercsub.
define variable gdsmercstrObj     as class     gdsmercstr.
define variable parser            as class     ParserXMLGds.
define variable v-value-character as character no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-value-type      as character no-undo .
define variable v-value-date      as date      no-undo .
DEFINE BUTTON B-exit AUTO-GO
  LABEL "&Ввод"
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE BUTTON B-Help
  LABEL "Помо&щь"
  SIZE 3 BY 1
  BGCOLOR 8 .
DEFINE BUTTON B-prod-type
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL ""
  SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
  LABEL "&Отмена"
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE VARIABLE f-gds-name     AS CHARACTER FORMAT "X(256)":U
  LABEL "Наим. товара в ТН"
  VIEW-AS FILL-IN
  SIZE 45 BY 1 NO-UNDO.
DEFINE VARIABLE f-guid         AS CHARACTER FORMAT "X(256)":U
  LABEL "GUID"
  VIEW-AS FILL-IN
  SIZE 45 BY 1 NO-UNDO.
DEFINE VARIABLE f-guid-subtype AS CHARACTER FORMAT "X(256)":U
  LABEL "GUID подгруппы"
  VIEW-AS FILL-IN
  SIZE 45 BY 1 NO-UNDO.
DEFINE VARIABLE f-guid-type    AS CHARACTER FORMAT "X(256)":U
  LABEL "GUID группы"
  VIEW-AS FILL-IN
  SIZE 45 BY 1 NO-UNDO.
DEFINE VARIABLE f-merc-name    AS CHARACTER FORMAT "X(256)":U
  LABEL "Наим. товара"
  VIEW-AS FILL-IN
  SIZE 45 BY 1 NO-UNDO.
DEFINE VARIABLE f-prod-type    AS CHARACTER FORMAT "X(256)":U
  LABEL "Тип продукции"
  VIEW-AS FILL-IN
  SIZE 41.75 BY 1 NO-UNDO.
DEFINE VARIABLE f-uuid         AS CHARACTER FORMAT "X(256)":U
  LABEL "UUID"
  VIEW-AS FILL-IN
  SIZE 45 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
  B-exit AT ROW 1 COL 1
  b-quit AT ROW 1 COL 11
  B-Help AT ROW 1 COL 68
  f-gds-name AT ROW 2.29 COL 3 WIDGET-ID 24
  f-merc-name AT ROW 3.58 COL 8 WIDGET-ID 34
  f-guid AT ROW 4.92 COL 16 WIDGET-ID 14
  f-uuid AT ROW 6.13 COL 16 WIDGET-ID 22
  f-prod-type AT ROW 7.33 COL 7.13 WIDGET-ID 26
  B-prod-type AT ROW 7.33 COL 64.38 WIDGET-ID 32
  f-guid-type AT ROW 8.54 COL 9.13 WIDGET-ID 28
  f-guid-subtype AT ROW 9.75 COL 6.25 WIDGET-ID 30
  SPACE(4.37) SKIP(0.49)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Товары из Меркурия"
  DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
  DO:
    RUN proc-save IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:error THEN RETURN NO-APPLY.
  END.
ON CHOOSE OF B-prod-type IN FRAME Dialog-Frame
  DO:
    run bge/merq-ref-tnved.w (parparentproc, 'ПРОСМОТР':U, "") no-error.
    if RETURN-VALUE = "" then
    do:
      MESSAGE "Не выбран тип продукции"
        VIEW-AS ALERT-BOX.
      return no-apply.
    end.
    assign
      f-prod-type    = entry(1,RETURN-VALUE)
      f-guid-type    = entry(3,RETURN-VALUE)
      f-guid-subtype = entry(4,RETURN-VALUE)
      .
    DISPLAY
      f-guid-subtype
      f-guid-type
      f-prod-type
      with frame Dialog-Frame .
  END.
ON return, MOUSE-SELECT-DBLCLICK OF f-guid IN FRAME Dialog-Frame DO:
apply "leave" to f-guid in frame Dialog-Frame.
apply "choose" to B-exit in frame Dialog-Frame.
END.
ON LEAVE OF f-guid IN FRAME Dialog-Frame
  DO:
    define variable Msg as character no-undo .
    ASSIGN f-guid .
    run checkguid(INPUT-OUTPUT f-guid,OUTPUT Msg) no-error .
    if Msg <> "" then
    do:
      MESSAGE Msg
        VIEW-AS ALERT-BOX.
      return NO-APPLY .
    end.
  END.
ON LEAVE OF f-uuid IN FRAME Dialog-Frame
  DO:
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
  THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN Myenable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-gds-name f-merc-name f-guid f-uuid f-prod-type f-guid-type
    f-guid-subtype
    WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-uuid
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tt :
  define variable ii             as integer no-undo .
  define variable gdsMercsubsObj as class   gdsmercsubs.
  define variable gdsmercstrObj  as class   gdsmercstr.
  gdsMercsubsObj = new gdsmercsubs ().
  gdsmercstrObj = new gdsmercstr ().
  gdsMercsubsObj = gdsmercstrObj:getgdsmercs(p-gds-code).
  if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then
  do:
    do ii = 1 to gdsMercsubsObj:GetItem (ii):
      gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr.
      assign
        f-merc-name    = gdsMercObj:MercName
        f-uuid         = gdsMercObj:UUID
        f-guid         = gdsMercObj:GUID_
        f-prod-type    = gdsMercObj:ProdType
        f-guid-type    = gdsMercObj:GUIDType
        f-guid-subtype = gdsMercObj:GUIDSubType
        .
    end.
  end.
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if AVAILABLE (buf_goods) then
  do:
    ASSIGN
      f-gds-name = buf_goods.gds-name
      .
  end.
END PROCEDURE.
PROCEDURE enable_UI_fill :
  DISPLAY
    f-gds-name
    f-merc-name
    f-guid
    f-guid-subtype
    f-guid-type
    f-prod-type
    f-uuid
    with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
  if p-mode = 'ИЗМЕНЕНИЕ':U then
  do:
    enable
      f-guid
      B-prod-type
      B-exit b-quit B-Help
      with frame Dialog-Frame .
    SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ,input 'mercur':U
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
      case thbjattr_thbj-attr.prop-code :
        when "login" then
          v-login = thbjattr_thbj-attr.property-value-character .
        when "password" then
          v-password = thbjattr_thbj-attr.property-value-character .
        when "server" then
          do:
            case thbjattr_thbj-attr.property-value-integer :
              when 1 then
                do:
                  v-server = "https://api2.vetrf.ru:8002" .
                end.
              when 2 then
                do:
                  v-server = "https://api.vetrf.ru" .
                end.
            end case .
          end.
        when "proxy-addres" then
          v-proxy-addres = thbjattr_thbj-attr.property-value-character .
        when "proxy-login" then
          do:
            if thbjattr_thbj-attr.property-value-character <> ""
            then do :
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  thbjattr_thbj-attr.property-value-character
  ,output v-proxy-login
  ) no-error .
            end.
          end.
        when "proxy-pswd" then
          do:
            if thbjattr_thbj-attr.property-value-character <> ""
            then do :
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  thbjattr_thbj-attr.property-value-character
  ,output v-proxy-pswd
  ) no-error .
            end.
          end.
        when "proxy-ssl" then
          v-proxy-ssl = thbjattr_thbj-attr.property-value-logical .
      end case.
    end.
  end.
  else
  do:
    enable
      B-exit b-quit B-Help
      with frame Dialog-Frame .
  end.
  VIEW FRAME Dialog-Frame.
  run fill-tt .
  run enable_UI_fill .
END PROCEDURE.
PROCEDURE proc-save :
  define variable ii              as integer   no-undo .
  define variable cmd             as character no-undo .
  define variable sw              as handle    no-undo .
  define variable v-file-gds      as character no-undo initial "getItemList_.xml".
  define variable Msg             as character no-undo .
  define variable choice          as logical   no-undo .
  define variable gdsMercsubsObj  as class     gdsmercsubs.
  define variable gdsmercstrObj   as class     gdsmercstr.
  define variable GuidMercsubsObj as class     gdsmercsubs.
  gdsMercsubsObj = new gdsmercsubs ().
  gdsmercstrObj = new gdsmercstr ().
  gdsMercsubsObj = gdsmercstrObj:getgdsmercs(p-gds-code).
  if p-mode = 'ИЗМЕНЕНИЕ':U then
  do:
    if f-guid <> "" then
    do:
      GuidMercsubsObj = gdsmercstrObj:getguidmercs(f-guid).
      if VALID-OBJECT (GuidMercsubsObj:GdsMercsubsCurr) then
      do:
      if GuidMercsubsObj:iCounter >= 1 then do:
        message
          "Товар с таким GUID уже есть"
          view-as alert-box.
          RETURN NO-APPLY .
        end.
      end.
      create sax-writer sw .
      sw:formatted = true.
      sw:set-output-destination ("file", v-file-gds).
      sw:encoding = "UTF-8".
      sw:start-document () .
      sw:start-element ("se:Envelope") .
      sw:insert-attribute ("xmlns:se", "http://schemas.xmlsoap.org/soap/envelope/") .
      sw:insert-attribute ("xmlns:ws", "http://api.vetrf.ru/schema/cdm/registry/ws-definitions/v2") .
      sw:insert-attribute ("xmlns:bs", "http://api.vetrf.ru/schema/cdm/base") .
      sw:insert-attribute ("xmlns:dt", "http://api.vetrf.ru/schema/cdm/dictionary/v2") .
      sw:start-element ("se:Body") .
      sw:start-element ("ws:getProductItemByGuidRequest") .
      sw:write-data-element ("bs:guid", f-guid) .
      sw:end-element ("ws:getProductItemByGuidRequest") .
      sw:end-element ("se:Body") .
      sw:end-element ("se:Envelope") .
      sw:end-document () .
      if trim(v-proxy-addres) <> "" and v-proxy-addres <> ?
      then do :
        if v-proxy-ssl
        then do :
          cmd = substitute ("&1 -k --proxy-negotiate -x &7 -U : -u &4:&5 -d @&2 &6/platform/services/2.1/ProductService >&3",
                          search ("exe/curl.exe"), search (v-file-gds), "ItemList_.xml", v-login, v-password, v-server, v-proxy-addres).
        end.
        else do :
          cmd = substitute ("&1 -x &7 -U &8:&9 -u &4:&5 -d @&2 &6/platform/services/2.1/ProductService >&3",
                          search ("exe/curl.exe"), search (v-file-gds), "ItemList_.xml", v-login, v-password, v-server, v-proxy-addres, v-proxy-login, v-proxy-pswd).
        end.
      end.
      else do :
        cmd = substitute ("&1 -u &4:&5 -d @&2 &6/platform/services/2.1/ProductService >&3", search ("exe/curl.exe"), search (v-file-gds), "ItemList_.xml", v-login, v-password, v-server).
      end.
      os-command silent value (cmd).
      parser = new parserXmlGDS().
      parser:ParseResponse
        (search("ItemList_.xml")
        ,input-output TABLE tt-gds-merq
        ,output Msg) no-error.
      if Msg <> "" then
      do:
        MESSAGE Msg
          VIEW-AS ALERT-BOX.
      end.
      if Msg = "" then
      do:
        find first tt-gds-merq no-lock no-error .
        if AVAILABLE (tt-gds-merq) then
        do:
          if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then
          do:
            do ii = 1 to gdsMercsubsObj:GetItem (ii):
              gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr.
              assign
                gdsMercObj:MercName    = tt-gds-merq.merc-name
                gdsMercObj:UUID        = tt-gds-merq.UUID
                gdsMercObj:GUID_       = tt-gds-merq.GUID_
                gdsMercObj:ProdType    = STRING (tt-gds-merq.prod-type)
                gdsMercObj:GUIDType    = tt-gds-merq.GUID-type
                gdsMercObj:GUIDSubType = tt-gds-merq.GUID-subtype
                .
            end.
            gdsmercstrObj:updateDB(gdsMercObj).
          end.
          else
          do:
            gdsMercObj = new gdsmercsub().
            assign
              gdsMercObj:GdsCode     = p-gds-code
              gdsMercObj:MercName    = tt-gds-merq.merc-name
              gdsMercObj:UUID        = tt-gds-merq.UUID
              gdsMercObj:GUID_       = tt-gds-merq.GUID_
              gdsMercObj:ProdType    = STRING (tt-gds-merq.prod-type)
              gdsMercObj:GUIDType    = tt-gds-merq.GUID-type
              gdsMercObj:GUIDSubType = tt-gds-merq.GUID-subtype
              .
            gdsmercstrObj:insertDB(gdsMercObj).
          end.
        end.
      end.
    end.
    if f-guid = "" or Msg <> "" then
    do:
      if VALID-OBJECT (gdsMercsubsObj:GdsMercsubsCurr) then
      do:
        do ii = 1 to gdsMercsubsObj:GetItem (ii):
          gdsMercObj = gdsMercsubsObj:GdsMercsubsCurr.
          assign
            gdsMercObj:MercName    = f-merc-name
            gdsMercObj:UUID        = f-uuid
            gdsMercObj:GUID_       = f-guid
            gdsMercObj:ProdType    = f-prod-type
            gdsMercObj:GUIDType    = f-guid-type
            gdsMercObj:GUIDSubType = f-guid-subtype
            .
        end.
        gdsmercstrObj:updateDB(gdsMercObj).
      end.
      else
      do:
        gdsMercObj = new gdsmercsub().
        assign
          gdsMercObj:GdsCode     = p-gds-code
          gdsMercObj:MercName    = f-merc-name
          gdsMercObj:UUID        = f-uuid
          gdsMercObj:GUID_       = f-guid
          gdsMercObj:ProdType    = f-prod-type
          gdsMercObj:GUIDType    = f-guid-type
          gdsMercObj:GUIDSubType = f-guid-subtype
          .
        gdsmercstrObj:insertDB(gdsMercObj).
      end.
    end.
  end.
  delete object gdsMercObj no-error .
  delete object gdsmercstrObj no-error .
  delete object gdsMercsubsObj no-error .
END PROCEDURE.
