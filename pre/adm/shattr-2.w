DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.shop.obj-code NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'get-chk'".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
define variable v-tth as handle no-undo .
define variable v-t-shft as integer no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-cashier
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .
DEFINE VARIABLE E-comments AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 1.93
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE cashier-psn-code-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.
DEFINE VARIABLE F-shift AS CHARACTER FORMAT "X(256)":U INITIAL "Способ обработки виртуальных смен"
      VIEW-AS TEXT
     SIZE 49.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE l-loc-hour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.3 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение часа"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE l-loc-min AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.3 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение минут"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE l-loc-sec AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.3 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение секунд"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE l-t-shift AS CHARACTER FORMAT "X(256)":U INITIAL "Время начала пересменки в магазине"
      VIEW-AS TEXT
     SIZE 35 BY .67 NO-UNDO.
DEFINE VARIABLE zero-cashier AS INTEGER FORMAT "99999" INITIAL 0
     LABEL "<НУЛЕВОЙ> кассир"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1.07 NO-UNDO.
DEFINE VARIABLE RS-REJIM AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Нет вирт. смен", 0,
"Режим 1", 1,
"Режим 2", 2
     SIZE 18 BY 2.77 NO-UNDO.
DEFINE VARIABLE RS-v-shft AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Нет вирт. смен", 0,
"Запрос оператору", 1,
"Дата учета чека определяется по чекам закрытия кассовых смен", 2
     SIZE 70 BY 3
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE t-annu-check AS LOGICAL INITIAL no
     LABEL "принимать аннулированные чеки"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE t-card-by-mask AS LOGICAL INITIAL no
     LABEL "использовать маски ДК при приеме чеков с касс для персонифицированных карт"
     VIEW-AS TOGGLE-BOX
     SIZE 94 BY 1 NO-UNDO.
DEFINE VARIABLE t-cas-curs AS LOGICAL INITIAL no
     LABEL "брать курсы валют в чек из спула, а не из бэк-офиса"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.
DEFINE VARIABLE t-cas-shft AS LOGICAL INITIAL no
     LABEL "использовать смены на кассе"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.
DEFINE VARIABLE t-dc-mask AS LOGICAL INITIAL no
     LABEL "использовать маски ДК при приеме чеков с касс для неперсонифицированных карт"
     VIEW-AS TOGGLE-BOX
     SIZE 94 BY 1 NO-UNDO.
DEFINE VARIABLE t-hnum AS LOGICAL INITIAL no
     LABEL "при обработке спулов номер магазина для чеков брать из спулов"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.
DEFINE VARIABLE t-is-100-discnt AS LOGICAL INITIAL no
     LABEL "принимать чеки со 100% скидкой"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.
DEFINE VARIABLE T-next AS LOGICAL INITIAL no
     LABEL "Сдвиг вперед"
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE t-no-get-chk AS LOGICAL INITIAL no
     LABEL "НЕТ ПРИЕМА ЧЕКОВ В МАГАЗИНЕ"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.
DEFINE VARIABLE t-ptrl-check AS LOGICAL INITIAL no
     LABEL "принимать специф.чеки АЗК:сброс,перелив, перевод транз, техпролив"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.
DEFINE VARIABLE t-z-check AS LOGICAL INITIAL no
     LABEL "принимать чеки z-отчета"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     t-no-get-chk AT ROW 2.13 COL 4
     t-cas-curs AT ROW 3.13 COL 4
     t-hnum AT ROW 4.13 COL 4
     t-cas-shft AT ROW 5.13 COL 4
     RS-REJIM AT ROW 7.37 COL 3 NO-LABEL
     RS-v-shft AT ROW 7.37 COL 23 NO-LABEL
     l-loc-hour AT ROW 10.87 COL 39 COLON-ALIGNED NO-LABEL
     l-loc-min AT ROW 10.87 COL 44 COLON-ALIGNED NO-LABEL
     l-loc-sec AT ROW 10.87 COL 49 COLON-ALIGNED NO-LABEL
     T-next AT ROW 10.87 COL 56.5
     E-comments AT ROW 12.13 COL 1 NO-LABEL
     t-dc-mask AT ROW 14.6 COL 3.5
     t-card-by-mask AT ROW 15.6 COL 3.5
     t-ptrl-check AT ROW 16.6 COL 3.5
     t-annu-check AT ROW 17.6 COL 3.5
     t-z-check AT ROW 17.6 COL 41 WIDGET-ID 12
     t-is-100-discnt AT ROW 18.6 COL 3.5 WIDGET-ID 2
     zero-cashier AT ROW 19.93 COL 18.5 COLON-ALIGNED WIDGET-ID 10
     cashier-psn-code-name AT ROW 20 COL 31.5 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     r-cashier AT ROW 20 COL 60 WIDGET-ID 6
     F-shift AT ROW 6.37 COL 1.5 COLON-ALIGNED NO-LABEL
     l-t-shift AT ROW 11.13 COL 2.5 NO-LABEL
     "(аннулированные заказы РЕСТОРАНА)" VIEW-AS TEXT
          SIZE 34 BY 1 AT ROW 20 COL 63.5 WIDGET-ID 8
          FGCOLOR 4
     SPACE(1.79) SKIP(0.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Опции закачки чеков"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       cashier-psn-code-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       l-loc-hour:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       l-loc-min:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       l-loc-sec:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       RS-v-shft:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-next:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       zero-cashier:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CURSOR-DOWN OF l-loc-hour IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour .
  l-loc-hour = l-loc-hour -  1.
  if l-loc-hour < 0 then return no-apply.
  display l-loc-hour with frame Dialog-Frame.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
END.
ON CURSOR-UP OF l-loc-hour IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour .
  l-loc-hour = l-loc-hour +  1.
  if l-loc-hour > 24 then return no-apply.
  display l-loc-hour with frame Dialog-Frame.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
END.
ON LEAVE OF l-loc-hour IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame l-loc-hour .
   if l-loc-hour > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
   if l-loc-hour < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.
   end.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
   RUN set-comments IN THIS-PROCEDURE.
END.
ON CURSOR-DOWN OF l-loc-min IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-min .
  l-loc-min = l-loc-min -  1.
  if l-loc-min < 0 then return no-apply.
  display l-loc-min with frame Dialog-Frame.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
END.
ON CURSOR-UP OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign  frame Dialog-Frame l-loc-min .
  l-loc-min = l-loc-min +  1.
  if l-loc-min > 59 then return no-apply.
  display l-loc-min with frame Dialog-Frame.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
END.
ON LEAVE OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign frame Dialog-Frame l-loc-min .
   if l-loc-min > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
RUN set-comments IN THIS-PROCEDURE.
END.
ON CURSOR-DOWN OF l-loc-sec IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-sec .
  l-loc-sec = l-loc-sec -  1.
  if l-loc-sec < 0 then return no-apply.
  display l-loc-sec with frame Dialog-Frame.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
END.
ON CURSOR-UP OF l-loc-sec IN FRAME Dialog-Frame
DO:
   assign  frame Dialog-Frame l-loc-sec .
  l-loc-sec = l-loc-sec +  1.
  if l-loc-sec > 59 then return no-apply.
  display l-loc-sec with frame Dialog-Frame.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
END.
ON LEAVE OF l-loc-sec IN FRAME Dialog-Frame
DO:
   assign frame Dialog-Frame l-loc-sec .
   if l-loc-sec > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
RUN set-comments IN THIS-PROCEDURE.
END.
ON CHOOSE OF r-cashier IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cashier-code AS integer NO-UNDO.
DEFINE BUFFER buf_staff FOR ub.staff.
run ref/staffs.w ( input parparentproc
                    , input "b-sel"
                    , input 'C':U
                    , input v-db-num
                    , input 0
                    , output v-rid-list ) .
IF v-rid-list <> '':U THEN DO:
   FIND FIRST buf_staff no-lock WHERE
      recid( buf_staff ) = integer( v-rid-list )  .
      v-cashier-code = buf_staff.staff-code .
  run get-cashier in this-procedure ( input buf_staff.staff-code).
END.
DISPLAY
zero-cashier
cashier-psn-code-name
WITH FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF RS-REJIM IN FRAME Dialog-Frame
DO:
  IF p-mode <> 'ПРОСМОТР':U  THEN
  ASSIGN
  rs-rejim.
  CASE rs-rejim:
    WHEN 0 THEN DO:
      rs-v-shft = 0.
      HIDE
      rs-v-shft
      IN FRAME Dialog-Frame.
      if v-t-shft = 0 then do:
         hide
        l-t-shift
        l-loc-hour
        l-loc-min
        l-loc-sec
        t-next
        IN FRAME Dialog-Frame.
       end.
    END.
    WHEN 1 THEN DO:
      rs-v-shft = 1.
      DISPLAY
      rs-v-shft
      WITH FRAME Dialog-Frame.
      HIDE
      l-t-shift
      l-loc-hour
      l-loc-min
      l-loc-sec
      t-next
      IN FRAME Dialog-Frame.
    END.
    WHEN 2 THEN DO:
      rs-v-shft = 2.
      t-next = YES.
      DISPLAY
      rs-v-shft
      l-t-shift
      l-loc-hour
      l-loc-min
      l-loc-sec
      t-next
      WITH FRAME Dialog-Frame.
    END.
  END CASE.
  RUN set-comments IN THIS-PROCEDURE.
END.
ON VALUE-CHANGED OF RS-v-shft IN FRAME Dialog-Frame
DO:
IF p-mode = 'ПРОСМОТР':U  THEN RETURN NO-APPLY.
IF rs-v-shft:VISIBLE IN FRAME Dialog-Frame THEN DO:
  ASSIGN rs-v-shft.
END.
ELSE DO:
    rs-v-shft = 0.
END.
CASE RS-v-shft:
    WHEN 2 THEN DO:
       DISPLAY
       l-loc-hour
       l-loc-min
       l-loc-sec
       WITH FRAME Dialog-Frame.
    END.
    WHEN 0 OR WHEN 1 THEN DO:
        ASSIGN
        l-loc-hour = 0
        l-loc-min = 0
        l-loc-sec = 0
        .
        hide
        l-loc-hour
        l-loc-min
        l-loc-sec
        l-t-shift
        IN  FRAME Dialog-Frame.
    END.
END CASE.
RUN set-comments IN THIS-PROCEDURE .
END.
ON VALUE-CHANGED OF t-cas-shft IN FRAME Dialog-Frame
DO:
define variable v-old-t-cas-shft as logical no-undo .
  IF p-mode = 'ПРОСМОТР':U  THEN RETURN NO-APPLY.
  ASSIGN
  v-old-t-cas-shft = t-cas-shft
  t-cas-shft.
  CASE t-cas-shft:
  WHEN yes THEN DO:
     ENABLE
     RS-rejim
     f-shift
     WITH FRAME Dialog-Frame.
     APPLY "VALUE-CHANGED" TO rs-v-shft.
  END.
  WHEN no THEN DO:
    if v-old-t-cas-shft <> t-cas-shft then do:
      ASSIGN
      RS-rejim = 0
      t-next = NO
      .
      disable
      RS-rejim
      t-next
      WITH FRAME Dialog-Frame.
      HIDE
      t-next
      rs-rejim
      f-shift
      rs-v-shft
      IN FRAME  Dialog-Frame.
    end.
    DISPLAY
    l-t-shift
    l-loc-hour
    l-loc-min
    l-loc-sec
    WITH FRAME Dialog-Frame.
    RUN set-comments IN THIS-PROCEDURE.
  END.
END CASE.
END.
ON VALUE-CHANGED OF T-next IN FRAME Dialog-Frame
DO:
  ASSIGN
  t-next.
  CASE t-next:
      WHEN NO THEN DO:
         IF T-CAS-SHFT THEN DO:
             ASSIGN
             RS-V-SHFT = 1
             .
             DISPLAY
             RS-V-SHFT
             WITH FRAME Dialog-Frame.
             DISABLE
             RS-V-SHFT
             WITH FRAME Dialog-Frame.
         END.
      END.
      WHEN YES  THEN DO:
          ASSIGN
          rs-v-shft = 1
          T-CAS-SHFT = YES
          .
          DISPLAY
          rs-v-shft
          T-CAS-SHFT
          WITH FRAME Dialog-Frame.
          DISABLE
          rs-v-shft
          T-CAS-SHFT
          WITH FRAME Dialog-Frame.
      END.
  END CASE.
  RUN set-comments IN THIS-PROCEDURE.
END.
ON VALUE-CHANGED OF t-no-get-chk IN FRAME Dialog-Frame
DO:
    ASSIGN
  t-no-get-chk.
  CASE t-no-get-chk:
      WHEN YES  THEN DO:
         rs-rejim = 0.
         APPLY "value-changed" TO t-cas-shft.
         APPLY "value-changed" TO rs-rejim.
         run set-comments in this-procedure .
         DISABLE
         RS-v-shft
         t-annu-check
         t-z-check
         t-card-by-mask
         t-cas-curs
         t-cas-shft
         t-dc-mask
         t-hnum
         T-next
         t-ptrl-check
         t-is-100-discnt
         WITH FRAME Dialog-Frame.
      END.
      WHEN NO  THEN DO:
         RUN myenable IN THIS-PROCEDURE.
      END.
  END CASE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame Dialog-Frame.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
  IF p-mode <> 'ПРОСМОТР':U
  and p-mode <> 'ИЗМЕНЕНИЕ':U THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-obj-type <> 'маг':U
  and p-obj-type <> 'орг':U
  and p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = 'маг':U then do:
    FIND FIRST X_shop NO-LOCK WHERE X_shop.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_shop THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  'маг':U
  ,input  p-obj-code
  ,output v-db-num
  )  .
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> 'ПРОСМОТР':U
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
  end.
  if p-obj-type = 'орг':U then do:
    FIND FIRST X_sysconf NO-LOCK WHERE X_sysconf.host-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_sysconf THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    if v-cntxt-db-num <> 0
    and p-mode <> 'ПРОСМОТР':U
    then do:
        MESSAGE
        "Нельзя менять параметры ФИРМЫ в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> 'ПРОСМОТР':U
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = 'get-chk':U
        and locked_thbj-attr.prop-code = '':U NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = 'get-chk':U
    and   locked_thbj-attr.prop-code = '':U NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                chr(10))
    view-as alert-box WARNING.
  end.
  RUN FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY t-no-get-chk t-cas-curs t-hnum t-cas-shft RS-REJIM RS-v-shft
          l-loc-hour l-loc-min l-loc-sec T-next E-comments t-dc-mask
          t-card-by-mask t-ptrl-check t-annu-check t-z-check t-is-100-discnt
          zero-cashier cashier-psn-code-name F-shift l-t-shift
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help t-no-get-chk t-cas-curs t-hnum t-cas-shft
         RS-REJIM l-loc-hour l-loc-min l-loc-sec t-dc-mask t-card-by-mask
         t-ptrl-check t-annu-check t-z-check t-is-100-discnt r-cashier F-shift
         l-t-shift
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dop-time AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input 'get-chk':U
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT TABLE-handle v-tth
            ) no-error .
if error-status:error
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr:
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  IF v-entry = 'cas-curs':U THEN DO:
    ASSIGN
    t-cas-curs = thbjattr_thbj-attr.property-value-logical
    t-cas-curs:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = 'hnum':U THEN DO:
    ASSIGN
    t-hnum = thbjattr_thbj-attr.property-value-logical
    t-hnum:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = 'cas-shft':U THEN DO:
    ASSIGN
    t-cas-shft = thbjattr_thbj-attr.property-value-logical
    t-cas-shft:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = 'v-shft':U THEN DO:
    ASSIGN
    RS-v-shft = thbjattr_thbj-attr.property-value-integer
    rs-v-shft:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = 't-shft':U THEN DO:
    ASSIGN
    t-next  = thbjattr_thbj-attr.property-value-integer < 0
    v-t-shft = abs(thbjattr_thbj-attr.property-value-integer)
    v-dop-time = string(v-t-shft, "hh:mm:ss")
    l-loc-hour = integer(SUBSTRING(v-dop-time, 1, 2))
    l-loc-min = integer(SUBSTRING(v-dop-time, 4, 2))
    l-loc-sec = integer(SUBSTRING(v-dop-time, 7, 2))
    .
  END.
  IF v-entry = 'dc-mask':U THEN DO:
    ASSIGN
    t-dc-mask = thbjattr_thbj-attr.property-value-logical
    t-dc-mask:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = 'ptrl-check':U THEN DO:
    ASSIGN
    t-ptrl-check = thbjattr_thbj-attr.property-value-logical
    t-ptrl-check:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = 'card-by-mask':U THEN DO:
    ASSIGN
    t-card-by-mask = thbjattr_thbj-attr.property-value-logical
    t-card-by-mask:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = 'annu-check':U THEN DO:
    ASSIGN
    t-annu-check = thbjattr_thbj-attr.property-value-logical.
    t-annu-check:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = 'z-check':U THEN DO:
    ASSIGN
    t-z-check = thbjattr_thbj-attr.property-value-logical.
    t-z-check:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = 'no-get-chk':U THEN DO:
    ASSIGN
    t-no-get-chk = thbjattr_thbj-attr.property-value-logical
    t-no-get-chk:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = 'is-100-discnt':U THEN DO:
    ASSIGN
    t-is-100-discnt = thbjattr_thbj-attr.property-value-logical
    t-is-100-discnt:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = 'zero-cashier':U THEN DO:
    ASSIGN
    zero-cashier = thbjattr_thbj-attr.property-value-integer
    zero-cashier:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
assign
rs-rejim = (if t-cas-shft then rs-v-shft else 0).
END PROCEDURE.
PROCEDURE get-cashier :
DEFINE INPUT PARAMETER p-cashier-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-cashier-psn-code AS integer NO-UNDO.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_clients for ub.clients.
run cur-time in this-procedure ( output v-today, output v-time).
   assign
   v-cashier-psn-code = gbclcode-is-this-db-role( INPUT 'C':U
                                                 ,INPUT v-db-num
                                                 ,INPUT p-cashier-code
                                                 ,input v-today
                                                 ) NO-ERROR.
   IF NOT ERROR-STATUS:ERROR THEN DO:
     FIND FIRST buf_clients NO-LOCK WHERE
                buf_clients.obj-type = 'чел':U
            AND buf_clients.obj-code = v-cashier-psn-code NO-ERROR.
     IF AVAILABLE buf_clients THEN DO:
         ASSIGN
          cashier-psn-code-name = buf_Clients.obj-name
         zero-cashier = p-cashier-code
         .
     END.
     ELSE DO:
      if p-cashier-code > 0 then do:
      MESSAGE
      "Ошибка при определении кассира"
      VIEW-AS ALERT-BOX.
      end.
     END.
   END.
   ELSE DO:
    if p-cashier-code > 0 then do:
      MESSAGE
      "Ошибка при определении кассира"
      VIEW-AS ALERT-BOX.
    end.
  END.
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN
FRAME Dialog-Frame:TITLE = FRAME Dialog-Frame:TITLE + (if p-obj-type = 'орг':U then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "t-no-get-chk,t-cas-curs,t-hnum,t-cas-shft,RS-rejim,l-loc-hour,l-loc-min,l-loc-sec,t-split-check,t-dc-mask,t-card-by-mask,t-ptrl-check,t-annu-check,t-z-check,t-is-100-discnt,r-cashier"
.
RUN get-cashier in this-procedure ( input zero-cashier) .
DISPLAY
t-no-get-chk
rs-rejim
t-cas-curs
t-hnum
t-cas-shft
E-comments
t-dc-mask
t-card-by-mask
t-ptrl-check
t-annu-check
t-z-check
t-is-100-discnt
zero-cashier
cashier-psn-code-name
WITH FRAME Dialog-Frame.
ENABLE
B-exit WHEN p-mode = 'ИЗМЕНЕНИЕ':U
b-quit
B-Help
t-no-get-chk WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-cas-curs WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-hnum WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-cas-shft WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-dc-mask WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-card-by-mask WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-ptrl-check WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-annu-check WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-z-check WHEN p-mode = 'ИЗМЕНЕНИЕ':U
l-loc-hour WHEN p-mode = 'ИЗМЕНЕНИЕ':U
l-loc-sec WHEN p-mode = 'ИЗМЕНЕНИЕ':U
l-loc-min WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-next WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-is-100-discnt WHEN p-mode = 'ИЗМЕНЕНИЕ':U
r-cashier WHEN p-mode = 'ИЗМЕНЕНИЕ':U and p-obj-type = 'маг':U
WITH FRAME Dialog-Frame.
if rs-rejim = 0 then do:
  HIDE
  rs-v-shft
  in frame Dialog-Frame .
end.
if v-t-shft = 0 then do:
  hide
  l-loc-hour
  l-loc-sec
  l-loc-min
  t-next
  in FRAME Dialog-Frame.
end.
else do:
  display
  l-loc-hour
  l-loc-sec
  l-loc-min
  t-next
  with FRAME Dialog-Frame.
end.
VIEW FRAME Dialog-Frame.
IF p-mode = 'ПРОСМОТР':U THEN DO:
  HIDE
  b-exit
  IN FRAME Dialog-Frame.
  ASSIGN
  b-quit:LABEL = "&Выход"
  .
END.
APPLY "value-changed" TO t-cas-shft.
APPLY "value-changed" TO rs-rejim.
run set-comments in this-procedure .
IF t-no-get-chk = YES THEN DO:
  APPLY "value-changed" TO t-no-get-chk.
END .
END PROCEDURE.
PROCEDURE proc-save :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
DEFINE VARIABLE l-shift-on AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-t-shft AS integer NO-UNDO.
IF p-mode = 'ПРОСМОТР':U THEN RETURN ERROR.
ASSIGN
FRAME Dialog-Frame
t-no-get-chk
t-cas-curs
t-cas-shft
t-hnum
t-dc-mask
t-ptrl-check
t-card-by-mask
t-annu-check
t-z-check
t-is-100-discnt
zero-cashier
.
IF RS-v-shft:SENSITIVE THEN DO:
    ASSIGN
    rs-v-shft.
END.
IF l-loc-hour:SENSITIVE THEN DO:
    ASSIGN
    l-loc-hour l-loc-min l-loc-sec.
    v-t-shft = (l-loc-hour * 3600 + l-loc-min * 60 + l-loc-sec).
END.
IF p-obj-type = 'маг':U THEN DO:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  'маг':U
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  if l-shift-on and not t-cas-shft then do:
     message "На текущем объекте требуется использование смен" skip
     "а настройка СМЕНЫ НА КАССЕ выключена - это недопустимо." skip (2)
    view-as alert-box ERROR.
    undo, return ERROR.
  end.
  IF l-shift-on AND v-t-shft <> 0 THEN DO:
      message
      "На текущем объекте требуется использование смен,"
      "а настройка ВРЕМЯ ПЕРЕСМЕНКИ включена - это недопустимо." skip (2)
      view-as alert-box ERROR.
      undo, return ERROR.
  END.
END.
assign
fh = frame Dialog-Frame:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
    if wh:sensitive
    or wh:name = "zero-cashier"
    then do:
      assign
      buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.
  wh = wh:next-sibling.
end.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = 't-shft':U.
assign
thbjattr_thbj-attr.property-value-integer = (IF t-cas-shft THEN 1 ELSE (-1)) * v-t-shft
.
release thbjattr_thbj-attr.
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if v-same = no then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
run adm/shattri.p (
              input "check":U
             , input p-obj-type
             , input p-obj-code
             , input 'get-chk':U
             , INPUT '':U
             , output v-value-character
             , output v-value-date
             , output v-value-decimal
             , output v-value-integer
             , output v-value-logical
             , output v-param-type
             , input-output TABLE-handle v-tth
            ) no-error .
if error-status:error then do:
  message
  "Некорректное значение ПАРАМЕТРОВ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
RUN thbjattr_set-section IN THIS-PROCEDURE (
     input p-obj-type
    ,input p-obj-code
    ,input 'get-chk':U
    ,input table thbjattr_thbj-attr
) NO-ERROR.
IF ERROR-STATUS:error THEN do:
  MESSAGE ERROR-STATUS:get-message(1) SKIP
  RETURN-VALUE
  VIEW-AS ALERT-BOX.
  UNDO, RETURN ERROR.
END.
END PROCEDURE.
PROCEDURE set-comments :
DEFINE VARIABLE v-t-shft AS INTEGER NO-UNDO.
DEFINE VARIABLE v-str AS character NO-UNDO.
IF l-loc-hour:VISIBLE IN FRAME Dialog-Frame THEN DO:
    ASSIGN
    FRAME Dialog-Frame
    l-loc-hour l-loc-min l-loc-sec.
    ASSIGN
    v-t-shft = l-loc-hour * 3600 + l-loc-min * 60 + l-loc-sec.
    IF NOT t-next THEN DO:
       ASSIGN
       v-str = SUBSTITUTE("Чеки, пробитые до &1 будут учитываться ПРЕДЫДУЩИМ днем", STRING(v-t-shft, "hh:mm:ss"))
       .
    END.
    ELSE DO:
       ASSIGN
       v-str = SUBSTITUTE("Чеки, пробитые после &1 будут учитываться СЛЕДУЮЩИМ днем", STRING(v-t-shft, "hh:mm:ss"))
       .
   END.
END.
e-comments:SCREEN-VALUE = v-str.
END PROCEDURE.
