DEFINE BUFFER locked_cash-desk FOR ub.cash-desk.
DEFINE BUFFER locked_cash-desk-attr FOR ub.cash-desk-attr.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-db-num as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
define input parameter p-upper-attr-code as character no-undo .
define input parameter p-attr-code as character no-undo .
define output parameter p-setted as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование настроек POS типа IBS TH".
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
define temp-table thbjattr___thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-tempwidg-index as integer no-undo .
DEFINE TEMP-TABLE temp-widget
FIELD NAME_ AS CHARACTER
FIELD LENGTH_ AS DECIMAL
FIELD index_ AS INTEGER
FIELD HANDLE_ AS HANDLE
FIELD format_ AS CHARACTER
FIELD width_ AS DECIMAL
field section_ as character
field visible_ as integer
field column_ as decimal
field row_ as decimal
field data-type_ as character
field character_ as character
field date_ as date
field decimal_ as decimal
field integer_ as decimal
field logical_ as logical
INDEX pi IS UNIQUE PRIMARY
NAME_
INDEX iindex
INDEX_
index isection
section_
.
procedure tempwidg_create-record :
define input parameter p-handle as widget-handle no-undo .
define buffer buf_temp-widget for temp-widget.
do
on error undo, return error
:
  find first buf_temp-widget where
            buf_temp-widget.name = p-handle:name no-error.
  if not available buf_temp-widget then do:
    create buf_temp-widget.
    assign
    buf_temp-widget.name = p-handle:name
    buf_temp-widget.index_ = v-tempwidg-index + 1
    buf_temp-widget.handle_ = p-handle
    v-tempwidg-index = v-tempwidg-index + 1
    .
  end.
end.
end procedure.
procedure tempwidg_write-character :
define input parameter p-name as character no-undo .
define input parameter p-character as character no-undo .
define buffer buf_temp-widget for temp-widget.
do
on error undo, return error
:
  find first buf_temp-widget where
            buf_temp-widget.name = p-name no-error.
  if available buf_temp-widget then do:
    assign
    buf_temp-widget.character_ = p-character
    buf_temp-widget.data-type_ = 'character':U
    .
  end.
end.
end procedure.
procedure tempwidg_write-logical :
define input parameter p-name as character no-undo .
define input parameter p-logical as logical no-undo .
define buffer buf_temp-widget for temp-widget.
do
on error undo, return error
:
  find first buf_temp-widget where
            buf_temp-widget.name = p-name no-error.
  if available buf_temp-widget then do:
    assign
    buf_temp-widget.logical_ = p-logical
    buf_temp-widget.data-type_ = 'logical':U
    .
  end.
end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE temp-cash-pay-list
FIELD cdpay-code AS INTEGER
FIELD curr-code AS INTEGER
FIELD frpay-code AS INTEGER
INDEX pi IS UNIQUE PRIMARY
cdpay-code curr-code
INDEX ifr frpay-code
    .
DEFINE TEMP-TABLE temp-pay-names
FIELD frpay-code AS INTEGER
FIELD frpay-name AS CHARACTER
INDEX pi IS UNIQUE PRIMARY frpay-code.
define variable p-obj-type as character no-undo init 'маг':U.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO EXTENT 5.
DEFINE VARIABLE v-labels AS CHARACTER NO-UNDO EXTENT 5.
DEFINE VARIABLE v-current-tab-order AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
DEFINE VARIABLE v-host-code AS INTEGER NO-UNDO.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
define variable v-tth_ as handle NO-UNDO .
define variable v-tth_main as handle NO-UNDO .
define variable v-tth_devices as handle NO-UNDO .
define variable v-tth_fisreg as handle NO-UNDO .
define variable v-tth_rec-print as handle NO-UNDO .
define variable v-tth_interface as handle NO-UNDO .
DEFINE VARIABLE v-frpay-name AS CHARACTER NO-UNDO.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle
v-tth_ = buffer thbjattr___thbj-attr:table-handle
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-cash-pay-list :
define input parameter p-cp-list as character no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-dop1 as character no-undo .
define variable v-fr-code as integer no-undo .
define variable v-cp-list as character no-undo .
define buffer buf_temp-cash-pay-list for temp-cash-pay-list.
do
on error undo, return error
:
  DO v-ii = 1 TO num-entries(p-cp-list, chr(4)):
    v-dop1 = ENTRY(v-ii, p-cp-list, chr(4)).
    ASSIGN
    v-fr-code = INTEGER(ENTRY(1, v-dop1, "="))
    v-cp-list = ENTRY(2, v-dop1, "=")
    NO-ERROR.
    IF v-fr-code >= 2
    AND v-fr-code <= 4 THEN DO:
      DO v-jj = 1 TO num-entries(v-cp-list, ";"):
        FIND FIRST buf_temp-cash-pay-list WHERE
                  buf_temp-cash-pay-list.cdpay-code = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
            AND buf_temp-cash-pay-list.curr-code = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), chr(58))) NO-ERROR.
        IF NOT AVAILABLE buf_temp-cash-pay-list THEN DO:
          CREATE buf_temp-cash-pay-list.
          ASSIGN
          buf_temp-cash-pay-list.cdpay-code = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
          buf_temp-cash-pay-list.curr-code = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
          buf_temp-cash-pay-list.frpay-code = v-fr-code
          .
        END.
      end.
    end.
  end.
END.
end procedure.
procedure get-pay-names :
define input parameter p-pay-names-list as character no-undo .
define variable v-ii as integer no-undo .
define variable v-fr-code as integer no-undo .
define variable v-name as character no-undo .
define buffer buf_temp-pay-names for temp-pay-names.
do
on error undo, return error
:
  DO v-ii = 1 TO num-entries(p-pay-names-list, chr(4)):
    ASSIGN
    v-fr-code = v-ii + 1
    v-name = ENTRY(v-ii, p-pay-names-list, chr(4))
    NO-ERROR.
    IF v-fr-code >= 2
    AND v-fr-code <= 4 THEN DO:
      FIND FIRST buf_temp-pay-names WHERE
                buf_temp-pay-names.frpay-code = v-fr-code NO-ERROR.
      IF NOT AVAILABLE buf_temp-pay-names THEN DO:
        CREATE buf_temp-pay-names.
        ASSIGN
        buf_temp-pay-names.frpay-code = v-fr-code
        buf_temp-pay-names.frpay-name = v-name
        .
      END.
    END.
  END.
end.
end procedure.
procedure set-cash-pay-list :
define output parameter p-cash-pay-list as character no-undo .
define buffer buf_temp-cash-pay-list for temp-cash-pay-list.
do
on error undo, return error
:
  FOR EACH buf_temp-cash-pay-list
  BREAK BY
  buf_temp-cash-pay-list.frpay-code:
    IF not(buf_temp-cash-pay-list.frpay-code  >= 2
         AND
         buf_temp-cash-pay-list.frpay-code  <= 4) THEN DO:
    undo, return error  substitute("Неверно заполнено соответствие для типа кассового платежа TH с кодом &1 и валютой &2"
               , buf_temp-cash-pay-list.cdpay-code
               , buf_temp-cash-pay-list.curr-code).
    END.
    IF FIRST-OF(buf_temp-cash-pay-list.frpay-code) THEN DO:
      ASSIGN
      p-cash-pay-list = substitute("&1&2&3="
                                  ,p-cash-pay-list
                                  ,chr(4)
                                    ,buf_temp-cash-pay-list.frpay-code) .
    END.
    ASSIGN
    p-cash-pay-list = substitute("&1&2:&3;"
                                ,p-cash-pay-list
                                  ,buf_temp-cash-pay-list.cdpay-code
                                  ,buf_temp-cash-pay-list.curr-code
                                  ) .
    IF last-OF(buf_temp-cash-pay-list.frpay-code) THEN DO:
      ASSIGN
      p-cash-pay-list = right-trim(p-cash-pay-list, ";").
    END.
  END.
  assign
  p-cash-pay-list = LEFT-TRIM(p-cash-pay-list, chr(4))
  p-cash-pay-list = right-TRIM(p-cash-pay-list, ";")
  .
end.
end procedure.
procedure set-pay-names :
define output parameter p-pay-names as character no-undo .
define buffer buf_temp-pay-names for temp-pay-names.
do
on error undo, return error
:
  FOR EACH buf_temp-pay-names
  BY buf_temp-pay-names.frpay-code
      :
    IF buf_temp-pay-names.frpay-code >= 2
    OR buf_temp-pay-names.frpay-code <= 2
    THEN
    ASSIGN
    p-pay-names = substitute("&1&2&3"
                                  ,p-pay-names
                                  ,chr(4)
                                  ,buf_temp-pay-names.frpay-name) .
  END.
  ASSIGN
  p-pay-names = left-trim(p-pay-names, chr(4))
  .
end.
end procedure.
FUNCTION get-frpay-name RETURNS CHARACTER
  ( INPUT p-frpay-code AS INTEGER )  FORWARD.
FUNCTION getcp-name RETURNS CHARACTER
  ( INPUT p-cdpay-code AS INTEGER , INPUT p-curr-code AS INTEGER)  FORWARD.
DEFINE BUTTON b-add-cash-pay
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .
DEFINE BUTTON b-del-cash-pay
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-devices
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.14.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-fisreg
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.14.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-interface
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.14.
DEFINE BUTTON b-keyboard-layout-id
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY .86.
DEFINE BUTTON B-main
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL "&1.Перемещ."
     SIZE 14 BY 1.14.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-rec-print
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.14.
DEFINE BUTTON b-screen-layout-id
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY .86.
DEFINE VARIABLE CB-cashless-system AS CHARACTER FORMAT "X(256)":U
     LABEL "Система безнал.платежей"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE CB-cctv-system AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип сис-мы видеонабл."
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE CB-customer-display-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип дисплея покупателя"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE CB-keyboard-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип клавиатуры"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE CB-screen-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип интерфейса"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE f-com-port AS CHARACTER FORMAT "X(4)":U
     LABEL "ФР подключен к"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "COM1","COM2","COM3","COM4"
     DROP-DOWN-LIST
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE f-advert-text AS CHARACTER FORMAT "X(255)":U
     LABEL "Рекламный текст"
     VIEW-AS FILL-IN NATIVE
     SIZE 62 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-advert-text1 AS CHARACTER FORMAT "X(40)":U
     LABEL "Рекламный текст1"
     VIEW-AS FILL-IN NATIVE
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-advert-text2 AS CHARACTER FORMAT "X(40)":U
     LABEL "Рекламный текст2"
     VIEW-AS FILL-IN NATIVE
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-advert-text3 AS CHARACTER FORMAT "X(40)":U
     LABEL "Рекламный текст3"
     VIEW-AS FILL-IN NATIVE
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-cash-drawer-limit AS DECIMAL FORMAT ">,>>>,>>9.99":U INITIAL 0
     LABEL "Предел наличности ДЯ"
     VIEW-AS FILL-IN NATIVE
     SIZE 13 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-cash-drawer-plug-imp AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Кол-во имп. включения ДЯ"
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-cash-drawer-plug-port AS INTEGER FORMAT "9":U INITIAL 0
     LABEL "Порт подключения ДЯ"
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-cctv-system-address AS CHARACTER FORMAT "X(256)":U
     LABEL "Адрес сис-мы видеонаблюд."
     VIEW-AS FILL-IN NATIVE
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-cliche-lines AS CHARACTER FORMAT "X(255)":U
     LABEL "Строки клише"
     VIEW-AS FILL-IN NATIVE
     SIZE 62 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-cliche-lines1 AS CHARACTER FORMAT "X(40)":U
     LABEL "Строки клише1"
     VIEW-AS FILL-IN NATIVE
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-cliche-lines2 AS CHARACTER FORMAT "X(40)":U
     LABEL "Строки клише2"
     VIEW-AS FILL-IN NATIVE
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-cliche-lines3 AS CHARACTER FORMAT "X(40)":U
     LABEL "Строки клише3"
     VIEW-AS FILL-IN NATIVE
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-cliche-lines4 AS CHARACTER FORMAT "X(40)":U
     LABEL "Строки клише4"
     VIEW-AS FILL-IN NATIVE
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-cliche-lines5 AS CHARACTER FORMAT "X(40)":U
     LABEL "Строки клише5"
     VIEW-AS FILL-IN NATIVE
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-cliche-lines6 AS CHARACTER FORMAT "X(40)":U
     LABEL "Строки клише6"
     VIEW-AS FILL-IN NATIVE
     SIZE 41 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-customer-display-adv AS CHARACTER FORMAT "X(41)":U
     LABEL "Текст рекл. на дисплее покупателя"
     VIEW-AS FILL-IN NATIVE
     SIZE 42 BY 1 NO-UNDO.
DEFINE VARIABLE f-customer-display-adv1 AS CHARACTER FORMAT "X(20)":U
     LABEL "Текст рекл. на дисплее покупателя1"
     VIEW-AS FILL-IN NATIVE
     SIZE 21 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-customer-display-adv2 AS CHARACTER FORMAT "X(20)":U
     LABEL "Теrст рекл. на дисплее покупателя2"
     VIEW-AS FILL-IN NATIVE
     SIZE 21 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE f-customer-display-port AS CHARACTER FORMAT "X(5)":U INITIAL "0"
     LABEL "Порт подключения  дисплея покупателя"
     VIEW-AS FILL-IN NATIVE
     SIZE 8 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-devices AS CHARACTER FORMAT "X(12)":U INITIAL "Устройства"
      VIEW-AS TEXT
     SIZE 11 BY .52
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-fisreg AS CHARACTER FORMAT "X(12)":U INITIAL "ФР"
      VIEW-AS TEXT
     SIZE 11 BY .52
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-interface AS CHARACTER FORMAT "X(12)":U INITIAL "Интерфейс"
      VIEW-AS TEXT
     SIZE 11 BY .52
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-keyboard-layout-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Раскладка"
     VIEW-AS FILL-IN NATIVE
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE f-keyboard-layout-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE f-main AS CHARACTER FORMAT "X(12)" INITIAL "Основные"
      VIEW-AS TEXT
     SIZE 11 BY .52
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-max-netto AS DECIMAL FORMAT ">,>>>,>>9.99":U INITIAL 0
     LABEL "Макс.сумма чека"
     VIEW-AS FILL-IN NATIVE
     SIZE 13 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-nalc AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Код валюты платежа при оплате НАЛИЧНЫМИ"
     VIEW-AS FILL-IN NATIVE
     SIZE 4.6 BY 1 TOOLTIP "код платежа = 1"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-rec-print AS CHARACTER FORMAT "X(12)":U INITIAL "Чеки"
      VIEW-AS TEXT
     SIZE 11 BY .52
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-rmethod-coeff AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 12.6 BY 1 NO-UNDO.
DEFINE VARIABLE f-screen-layout-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Раскладка"
     VIEW-AS FILL-IN NATIVE
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE f-screen-layout-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE for-curr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6.8 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE l-cash-drawer-level AS CHARACTER FORMAT "X(256)":U INITIAL "Логич.уровень датчика ДЯ"
      VIEW-AS TEXT
     SIZE 28 BY .67 NO-UNDO.
DEFINE VARIABLE l-cash-drawer-plug-type AS CHARACTER FORMAT "X(256)":U INITIAL "Тип подключения"
      VIEW-AS TEXT
     SIZE 16 BY .67 NO-UNDO.
DEFINE VARIABLE l-log-level AS CHARACTER FORMAT "X(256)":U INITIAL "Уровень логирования"
      VIEW-AS TEXT
     SIZE 20 BY .67 NO-UNDO.
DEFINE VARIABLE l-rmethod AS CHARACTER FORMAT "X(256)":U INITIAL "Тип и коэфф.округления суммы чека"
     VIEW-AS FILL-IN
     SIZE 40 BY .81 NO-UNDO.
DEFINE VARIABLE v-rmethod-coeff AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE RS-cash-drawer-level AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", 1,
"0", 0
     SIZE 12.6 BY 1 NO-UNDO.
DEFINE VARIABLE RS-cash-drawer-plug-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "ФР", 0,
"COM-порт", 1
     SIZE 22.6 BY 1 NO-UNDO.
DEFINE VARIABLE rs-log-level AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Item 0", 0,
"Item 1", 1,
"Item 2", 2,
"Item 3", 3
     SIZE 17.6 BY 3.48 NO-UNDO.
DEFINE VARIABLE rs-rmethod-coeff AS DECIMAL
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Item 1", 1,
"Item 2", 2,
"Item 3", 3,
"Item 4", 4
     SIZE 40 BY 3.05 NO-UNDO.
DEFINE VARIABLE rs-rmethod-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 39 BY 2 NO-UNDO.
DEFINE VARIABLE t-card-reader-plug AS LOGICAL INITIAL no
     LABEL "Подключать кардридер"
     VIEW-AS TOGGLE-BOX
     SIZE 22.6 BY 1 NO-UNDO.
DEFINE VARIABLE t-cash-drawer-open AS LOGICAL INITIAL no
     LABEL "Работа с открытым ДЯ"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY 1 NO-UNDO.
DEFINE VARIABLE t-cash-drawer-plug AS LOGICAL INITIAL no
     LABEL "Подключать ДЯ"
     VIEW-AS TOGGLE-BOX
     SIZE 20.6 BY 1 NO-UNDO.
DEFINE VARIABLE t-cash-shift AS LOGICAL INITIAL no
     LABEL "Работа со сменами"
     VIEW-AS TOGGLE-BOX
     SIZE 20.6 BY 1 NO-UNDO.
DEFINE VARIABLE t-clear-cash-counter AS LOGICAL INITIAL no
     LABEL "Обнулять счетчик наличн. при Z-отчете"
     VIEW-AS TOGGLE-BOX
     SIZE 40.6 BY 1 NO-UNDO.
DEFINE VARIABLE t-customer-display-plug AS LOGICAL INITIAL no
     LABEL "Подключать дисплей покупателя"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY 1 NO-UNDO.
DEFINE VARIABLE t-cutter AS LOGICAL INITIAL no
     LABEL "Отрезка чеков"
     VIEW-AS TOGGLE-BOX
     SIZE 22.6 BY 1 NO-UNDO.
DEFINE VARIABLE t-manual-discnt AS LOGICAL INITIAL no
     LABEL "Разрешена ручная скидка"
     VIEW-AS TOGGLE-BOX
     SIZE 27.6 BY 1 NO-UNDO.
DEFINE VARIABLE t-print-good-code AS LOGICAL INITIAL no
     LABEL "Печатать код товара"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY 1 NO-UNDO.
DEFINE VARIABLE t-qnty-change AS LOGICAL INITIAL no
     LABEL "Разрешена коррекция кол-ва"
     VIEW-AS TOGGLE-BOX
     SIZE 40.6 BY 1 NO-UNDO.
DEFINE VARIABLE t-rcpt-ord-alt-print AS LOGICAL INITIAL no
     LABEL "Печатать отлож.чек на доп принтере"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY 1 NO-UNDO.
DEFINE VARIABLE t-rcpt-ord-slip-print AS LOGICAL INITIAL no
     LABEL "Печатать слип отложенного чека"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY 1 NO-UNDO.
DEFINE VARIABLE t-salesman-mandatory AS LOGICAL INITIAL no
     LABEL "Обязателен продавец"
     VIEW-AS TOGGLE-BOX
     SIZE 21.6 BY 1 NO-UNDO.
DEFINE QUERY BR-cash-pay-list FOR
      temp-cash-pay-list SCROLLING.
DEFINE QUERY BR-pay-names FOR
      temp-pay-names SCROLLING.
DEFINE BROWSE BR-cash-pay-list
  QUERY BR-cash-pay-list DISPLAY
      temp-cash-pay-list.cdpay-code COLUMN-LABEL "Код TH"
temp-cash-pay-list.curr-code COLUMN-LABEL "Код вал"
getcp-name (INPUT temp-cash-pay-list.cdpay-code, INPUT temp-cash-pay-list.curr-code) COLUMN-LABEL "Название типа касс.платежа TH" FORMAT "X(40)"
temp-cash-pay-list.frpay-code COLUMN-LABEL "Код ФР"
 get-frpay-name( INPUT temp-cash-pay-list.frpay-code) @ v-frpay-name COLUMN-LABEL "Наим. кода оплаты на ФР" FORMAT "X(40)"
ENABLE
temp-cash-pay-list.frpay-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12
         TITLE "Типы кассовых платежей<->коды оплаты ФР" ROW-HEIGHT-CHARS .5 FIT-LAST-COLUMN.
DEFINE BROWSE BR-pay-names
  QUERY BR-pay-names DISPLAY
      temp-pay-names.frpay-code COLUMN-LABEL  "Код в ФР"   FORMAT "9"
temp-pay-names.frpay-name COLUMN-LABEL  "Наименование" FORMAT "X(40)"
ENABLE
temp-pay-names.frpay-name
    WITH NO-ROW-MARKERS SEPARATORS SIZE 33.6 BY 4.52
         TITLE "Наименования типов оплат ФР" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     t-cash-shift AT ROW 4 COL 18 WIDGET-ID 46
     t-cash-drawer-plug AT ROW 4 COL 18 WIDGET-ID 76
     RS-cash-drawer-level AT ROW 4 COL 32.6 NO-LABEL WIDGET-ID 96
     f-advert-text1 AT ROW 4 COL 36.6 COLON-ALIGNED WIDGET-ID 102
     rs-log-level AT ROW 4 COL 79.6 NO-LABEL WIDGET-ID 178
     BR-pay-names AT ROW 5 COL 1 WIDGET-ID 200
     t-salesman-mandatory AT ROW 5 COL 15 WIDGET-ID 156
     RS-cash-drawer-plug-type AT ROW 5 COL 17.6 NO-LABEL WIDGET-ID 78
     CB-screen-type AT ROW 5 COL 23 COLON-ALIGNED WIDGET-ID 166
     f-advert-text2 AT ROW 5 COL 36.6 COLON-ALIGNED WIDGET-ID 104
     t-cutter AT ROW 5 COL 55 WIDGET-ID 90
     f-cash-drawer-plug-port AT ROW 5 COL 58 COLON-ALIGNED WIDGET-ID 84
     t-manual-discnt AT ROW 6 COL 15 WIDGET-ID 158
     f-screen-layout-id AT ROW 6 COL 23 COLON-ALIGNED WIDGET-ID 174
     f-cash-drawer-plug-imp AT ROW 6 COL 27.8 COLON-ALIGNED WIDGET-ID 86
     f-advert-text3 AT ROW 6 COL 36.6 COLON-ALIGNED WIDGET-ID 106
     b-screen-layout-id AT ROW 6 COL 40 WIDGET-ID 168
     f-com-port AT ROW 6 COL 66 COLON-ALIGNED WIDGET-ID 4
     t-clear-cash-counter AT ROW 7 COL 15 WIDGET-ID 192
     f-cash-drawer-limit AT ROW 7 COL 24 COLON-ALIGNED WIDGET-ID 50
     t-qnty-change AT ROW 8 COL 15 WIDGET-ID 186
     t-cash-drawer-open AT ROW 8 COL 18 WIDGET-ID 48
     f-cliche-lines1 AT ROW 8 COL 36.6 COLON-ALIGNED WIDGET-ID 112
     f-cliche-lines2 AT ROW 9 COL 36.6 COLON-ALIGNED WIDGET-ID 114
     b-add-cash-pay AT ROW 9 COL 77 WIDGET-ID 128
     b-del-cash-pay AT ROW 9 COL 87 WIDGET-ID 130
     BR-cash-pay-list AT ROW 10 COL 1 WIDGET-ID 100
     t-customer-display-plug AT ROW 10 COL 18 WIDGET-ID 92
     f-cliche-lines3 AT ROW 10 COL 36.6 COLON-ALIGNED WIDGET-ID 116
     CB-customer-display-type AT ROW 11 COL 25.2 COLON-ALIGNED WIDGET-ID 188
     f-cliche-lines4 AT ROW 11 COL 36.6 COLON-ALIGNED WIDGET-ID 118
     f-cliche-lines5 AT ROW 12 COL 36.6 COLON-ALIGNED WIDGET-ID 120
     f-customer-display-port AT ROW 12 COL 43.6 COLON-ALIGNED WIDGET-ID 190
     f-cliche-lines6 AT ROW 13 COL 36.6 COLON-ALIGNED WIDGET-ID 124
     f-customer-display-adv1 AT ROW 13 COL 37.6 COLON-ALIGNED WIDGET-ID 52
     t-print-good-code AT ROW 14 COL 18 WIDGET-ID 126
     f-customer-display-adv2 AT ROW 14 COL 37 COLON-ALIGNED WIDGET-ID 54
     f-max-netto AT ROW 15 COL 18 COLON-ALIGNED WIDGET-ID 44
     l-rmethod AT ROW 16 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 150
     CB-keyboard-type AT ROW 16 COL 23 COLON-ALIGNED WIDGET-ID 160
     rs-rmethod-type AT ROW 17 COL 15.6 NO-LABEL WIDGET-ID 146
     f-keyboard-layout-id AT ROW 17 COL 23 COLON-ALIGNED WIDGET-ID 172
     f-customer-display-adv AT ROW 17 COL 36.4 COLON-ALIGNED WIDGET-ID 74
     b-keyboard-layout-id AT ROW 17 COL 40 WIDGET-ID 162
     b-curr AT ROW 17 COL 47 WIDGET-ID 134
     f-nalc AT ROW 17 COL 48.8 COLON-ALIGNED WIDGET-ID 132
     f-rmethod-coeff AT ROW 17 COL 52.6 COLON-ALIGNED NO-LABEL WIDGET-ID 152
     rs-rmethod-coeff AT ROW 17 COL 55 NO-LABEL WIDGET-ID 140
     v-rmethod-coeff AT ROW 18.19 COL 12 COLON-ALIGNED NO-LABEL WIDGET-ID 154
     CB-cashless-system AT ROW 19 COL 27.2 COLON-ALIGNED WIDGET-ID 176
     f-cliche-lines AT ROW 19.67 COL 32.6 COLON-ALIGNED WIDGET-ID 110
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     f-advert-text AT ROW 19.67 COL 32.6 COLON-ALIGNED WIDGET-ID 108
     t-rcpt-ord-slip-print AT ROW 20 COL 18 WIDGET-ID 198
     t-card-reader-plug AT ROW 20 COL 18 WIDGET-ID 88
     b-interface AT ROW 2.57 COL 57 WIDGET-ID 40
     t-rcpt-ord-alt-print AT ROW 21 COL 18 WIDGET-ID 200
     CB-cctv-system AT ROW 21 COL 24 COLON-ALIGNED WIDGET-ID 194
     f-cctv-system-address AT ROW 21 COL 73 COLON-ALIGNED WIDGET-ID 196
     B-devices AT ROW 2.57 COL 15 WIDGET-ID 16
     b-rec-print AT ROW 2.57 COL 43 WIDGET-ID 34
     B-main AT ROW 2.57 COL 1 WIDGET-ID 14
     b-fisreg AT ROW 2.57 COL 29 WIDGET-ID 28
     f-main AT ROW 2.95 COL 2.6 NO-LABEL WIDGET-ID 18
     F-devices AT ROW 2.95 COL 16.6 NO-LABEL WIDGET-ID 20
     f-fisreg AT ROW 2.95 COL 30.6 NO-LABEL WIDGET-ID 26
     f-rec-print AT ROW 2.95 COL 44.6 NO-LABEL WIDGET-ID 36
     f-interface AT ROW 2.95 COL 58.6 NO-LABEL WIDGET-ID 42
     l-cash-drawer-level AT ROW 4 COL 1 NO-LABEL WIDGET-ID 100
     l-log-level AT ROW 4 COL 56 COLON-ALIGNED NO-LABEL WIDGET-ID 182
     l-cash-drawer-plug-type AT ROW 5 COL 1 NO-LABEL WIDGET-ID 82
     f-screen-layout-name AT ROW 6 COL 55 COLON-ALIGNED NO-LABEL WIDGET-ID 170
     for-curr-name AT ROW 17 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 136
     f-keyboard-layout-name AT ROW 17 COL 55 COLON-ALIGNED NO-LABEL WIDGET-ID 164
     SPACE(13.39) SKIP(4.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки по умолчанию и опции работы POS IBS TH"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       f-advert-text:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-cliche-lines:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-customer-display-adv:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-rmethod-coeff:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       v-rmethod-coeff:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add-cash-pay IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid AS recid NO-UNDO.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_temp-cash-pay-list FOR temp-cash-pay-list.
  run ref/cashpays.w (
               input parparentproc
              ,input  "b-sel":U
              ,input 'все':U
              ,input (if p-obj-type = "" then 0 else v-host-code)
              ,input (if p-obj-type = '' then '':U else p-obj-type)
              ,input (if p-obj-type = '' then 0 else p-obj-code)
              ,OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR OR v-rid-list = "":U  THEN RETURN no-apply.
FIND FIRST buf_cash-pay NO-LOCK WHERE
        RECID(buf_cash-pay) = INTEGER(ENTRY(1, v-rid-list)) NO-ERROR.
IF NOT AVAILABLE buf_cash-pay  THEN RETURN NO-APPLY.
if buf_cash-pay.cdpay-code = 1 then do:
  message
  "Для платежа типа НАЛИЧНЫЕ (тип касс. платежа = 1) соответствие с типами оплат ФР определять НЕ НАДО!"
  view-as alert-box error .
  undo, return no-apply.
end.
FIND FIRST buf_temp-cash-pay-list WHERE
            buf_temp-cash-pay-list.cdpay-code = buf_cash-pay.cdpay-code
    AND     buf_temp-cash-pay-list.curr-code = buf_cash-pay.curr-code NO-ERROR.
IF AVAILABLE buf_temp-cash-pay-list THEN DO:
    MESSAGE
    SUBSTITUTE("Вы уже добавили соответствие между типом кассового платежа в IBS TH с кодом &1 и валютой &2"
              , buf_cash-pay.cdpay-code
              , buf_cash-pay.curr-code)
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
END.
CREATE buf_temp-cash-pay-list.
ASSIGN
buf_temp-cash-pay-list.cdpay-code = buf_cash-pay.cdpay-code
buf_temp-cash-pay-list.curr-code = buf_cash-pay.curr-code
buf_temp-cash-pay-list.frpay-code = 0
.
v-rid = RECID(buf_temp-cash-pay-list).
OPEN QUERY br-cash-pay-list FOR EACH temp-cash-pay-list.
REPOSITION br-cash-pay-list TO RECID v-rid NO-ERROR.
APPLY "ENTRY" TO br-cash-pay-list.
END.
ON CHOOSE OF b-curr IN FRAME Dialog-Frame
DO:
    define variable rr as recid no-undo.
    DEFINE BUFFER buf_currency FOR ub.currency.
    rr = ? .
    run ref/currency.w (
                    input parparentproc
                  , input "b-sel"
                  , input-output rr ).
    if rr <> ? then do:
      FIND FIRST buf_currency WHERE
                recid( buf_currency ) = rr NO-LOCK .
      DISPLAY
      buf_currency.curr-code @ f-nalc
      buf_currency.curr-abbr @ for-curr-name
      with frame Dialog-Frame .
    end.
END.
ON CHOOSE OF b-del-cash-pay IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
MESSAGE
"Вы действительно хотите удалить это соответствие?"
 VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
 IF NOT glog  THEN RETURN NO-APPLY.
  IF NOT AVAILABLE temp-cash-pay-list THEN RETURN NO-APPLY.
  DELETE temp-cash-pay-list.
  OPEN QUERY br-cash-pay-list FOR EACH temp-cash-pay-list.
  REPOSITION br-cash-pay-list TO ROW 1.
END.
ON CHOOSE OF B-devices IN FRAME Dialog-Frame
DO:
run proc-init-devices in this-procedure .
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  p-setted = yes.
END.
ON CHOOSE OF b-fisreg IN FRAME Dialog-Frame
DO:
run proc-init-fisreg in this-procedure .
END.
ON CHOOSE OF b-interface IN FRAME Dialog-Frame
DO:
run proc-init-interface in this-procedure .
END.
ON CHOOSE OF b-keyboard-layout-id IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_layout FOR ub.layout.
  IF f-keyboard-layout-id <> '' THEN DO:
      FIND FIRST buf_layout NO-LOCK WHERE
                buf_layout.layout-id = f-keyboard-layout-id NO-ERROR.
  END.
      run adm/layoutss.w (
                           INPUT parparentproc
                         ,input "b-sel"
                         ,INPUT "layout-type"
                          ,INPUT 'th-pos-keyboard':U
                          ,INPUT-OUTPUT v-rid-list) NO-ERROR.
    IF v-rid-list <> ''
    AND v-rid-list <> STRING(RECID(buf_layout)) THEN DO:
      FIND FIRST buf_layout NO-LOCK WHERE
                recid(buf_layout) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_layout THEN DO:
          ASSIGN
          f-keyboard-layout-id = ''
          f-keyboard-layout-name = ?
          .
      END.
      ELSE DO:
          ASSIGN
          f-keyboard-layout-id = buf_layout.layout-id
          f-keyboard-layout-name = buf_layout.layout-name
          .
      END.
      DISPLAY
      f-keyboard-layout-id
      f-keyboard-layout-name
      WITH FRAME Dialog-Frame.
    END.
END.
ON CHOOSE OF B-main IN FRAME Dialog-Frame
DO:
   run proc-init-main in this-procedure .
END.
ON CHOOSE OF b-rec-print IN FRAME Dialog-Frame
DO:
run proc-init-rec-print in this-procedure .
END.
ON CHOOSE OF b-screen-layout-id IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_layout FOR ub.layout.
  IF f-screen-layout-id <> '' THEN DO:
      FIND FIRST buf_layout NO-LOCK WHERE
                buf_layout.layout-id = f-screen-layout-id NO-ERROR.
  END.
      run adm/layoutss.w (
                           INPUT parparentproc
                         ,input "b-sel"
                         ,INPUT "layout-type"
                          ,INPUT 'th-pos-screen':U
                          ,INPUT-OUTPUT v-rid-list) NO-ERROR.
    IF v-rid-list <> ''
    AND v-rid-list <> STRING(RECID(buf_layout)) THEN DO:
      FIND FIRST buf_layout NO-LOCK WHERE
                recid(buf_layout) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_layout THEN DO:
          ASSIGN
          f-screen-layout-id = ''
          f-screen-layout-name = ?
          .
      END.
      ELSE DO:
          ASSIGN
          f-screen-layout-id = buf_layout.layout-id
          f-screen-layout-name = buf_layout.layout-name
          .
      END.
      DISPLAY
      f-screen-layout-id
      f-screen-layout-name
      WITH FRAME Dialog-Frame.
  END.
END.
ON VALUE-CHANGED OF CB-cashless-system IN FRAME Dialog-Frame
DO:
  ASSIGN
  cb-cashless-system.
END.
ON VALUE-CHANGED OF CB-cctv-system IN FRAME Dialog-Frame
DO:
  ASSIGN
  cb-cctv-system.
  case cb-cctv-system:
    when '' then do:
      f-cctv-system-address = ''.
      display
      f-cctv-system-address
      with frame Dialog-Frame .
      disable
      f-cctv-system-address
      with frame Dialog-Frame .
    end.
    otherwise do:
      if p-mode <> 'ПРОСМОТР':U then do:
        enable
        f-cctv-system-address
        with frame Dialog-Frame .
      end.
    end.
  end case.
END.
ON VALUE-CHANGED OF CB-keyboard-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  cb-keyboard-type.
  CASE cb-keyboard-type:
      WHEN '' THEN DO:
        ASSIGN
        f-keyboard-layout-id = ''
        f-keyboard-layout-name = ''
        .
        DISPLAY
        f-keyboard-layout-id
        f-keyboard-layout-name
        WITH FRAME Dialog-Frame.
        DISABLE
        b-keyboard-layout-id
        WITH FRAME Dialog-Frame.
      END.
      OTHERWISE DO:
          Enable
          b-keyboard-layout-id
          WITH FRAME Dialog-Frame.
         APPLY "CHOOSE" TO b-keyboard-layout-id .
      END.
  END CASE.
END.
ON VALUE-CHANGED OF CB-screen-type IN FRAME Dialog-Frame
DO:
    ASSIGN
  cb-screen-type.
  APPLY "CHOOSE" TO b-screen-layout-id .
END.
ON LEAVE OF f-advert-text1 IN FRAME Dialog-Frame
DO:
  ASSIGN
  f-advert-text1
  f-advert-text = f-advert-text1 + chr(4) +
                  f-advert-text2 + chr(4) +
                  f-advert-text3
  f-advert-text:screen-value = f-advert-text
  .
END.
ON LEAVE OF f-advert-text2 IN FRAME Dialog-Frame
DO:
  ASSIGN
  f-advert-text2
    f-advert-text = f-advert-text1 + chr(4) +
                  f-advert-text2 + chr(4) +
                  f-advert-text3
  f-advert-text:screen-value = f-advert-text
  .
END.
ON LEAVE OF f-advert-text3 IN FRAME Dialog-Frame
DO:
  ASSIGN
  f-advert-text3
    f-advert-text = f-advert-text1 + chr(4) +
                  f-advert-text2 + chr(4) +
                  f-advert-text3
 f-advert-text:SCREEN-VALUE = f-advert-text
  .
END.
ON LEAVE OF f-cliche-lines1 IN FRAME Dialog-Frame
DO:
  ASSIGN
  f-cliche-lines1
  f-cliche-lines = f-cliche-lines1 + chr(4) +
                   f-cliche-lines2 + chr(4) +
                   f-cliche-lines3 + chr(4) +
                   f-cliche-lines4 + chr(4) +
                   f-cliche-lines5 + chr(4) +
                   f-cliche-lines6
  f-cliche-lines:SCREEN-VALUE = f-cliche-lines
  .
END.
ON LEAVE OF f-cliche-lines2 IN FRAME Dialog-Frame
DO:
  ASSIGN
   f-cliche-lines2
  f-cliche-lines = f-cliche-lines1 + chr(4) +
                   f-cliche-lines2 + chr(4) +
                   f-cliche-lines3 + chr(4) +
                   f-cliche-lines4 + chr(4) +
                   f-cliche-lines5 + chr(4) +
                   f-cliche-lines6
f-cliche-lines:SCREEN-VALUE = f-cliche-lines
  .
END.
ON LEAVE OF f-cliche-lines3 IN FRAME Dialog-Frame
DO:
  ASSIGN
  f-cliche-lines3
  f-cliche-lines = f-cliche-lines1 + chr(4) +
                   f-cliche-lines2 + chr(4) +
                   f-cliche-lines3 + chr(4) +
                   f-cliche-lines4 + chr(4) +
                   f-cliche-lines5 + chr(4) +
                   f-cliche-lines6
f-cliche-lines:SCREEN-VALUE = f-cliche-lines
  .
END.
ON LEAVE OF f-cliche-lines4 IN FRAME Dialog-Frame
DO:
  ASSIGN
    f-cliche-lines4
  f-cliche-lines = f-cliche-lines1 + chr(4) +
                   f-cliche-lines2 + chr(4) +
                   f-cliche-lines3 + chr(4) +
                   f-cliche-lines4 + chr(4) +
                   f-cliche-lines5 + chr(4) +
                   f-cliche-lines6
f-cliche-lines:SCREEN-VALUE = f-cliche-lines
  .
END.
ON LEAVE OF f-cliche-lines5 IN FRAME Dialog-Frame
DO:
  ASSIGN
    f-cliche-lines5
  f-cliche-lines = f-cliche-lines1 + chr(4) +
                   f-cliche-lines2 + chr(4) +
                   f-cliche-lines3 + chr(4) +
                   f-cliche-lines4 + chr(4) +
                   f-cliche-lines5 + chr(4) +
                   f-cliche-lines6
f-cliche-lines:SCREEN-VALUE = f-cliche-lines
  .
END.
ON LEAVE OF f-cliche-lines6 IN FRAME Dialog-Frame
DO:
  ASSIGN
    f-cliche-lines6
  f-cliche-lines = f-cliche-lines1 + chr(4) +
                   f-cliche-lines2 + chr(4) +
                   f-cliche-lines3 + chr(4) +
                   f-cliche-lines4 + chr(4) +
                   f-cliche-lines5 + chr(4) +
                   f-cliche-lines6
f-cliche-lines:SCREEN-VALUE = f-cliche-lines
  .
END.
ON VALUE-CHANGED OF f-com-port IN FRAME Dialog-Frame
DO:
  assign f-com-port.
END.
ON LEAVE OF f-customer-display-adv1 IN FRAME Dialog-Frame
DO:
  ASSIGN
  f-customer-display-adv1
  f-customer-display-adv = f-customer-display-adv1 + chr(4) + f-customer-display-adv2
  f-customer-display-adv:SCREEN-VALUE in frame Dialog-Frame = f-customer-display-adv
  .
END.
ON LEAVE OF f-customer-display-adv2 IN FRAME Dialog-Frame
DO:
  ASSIGN
  f-customer-display-adv2
  f-customer-display-adv = f-customer-display-adv1 + chr(4)  + f-customer-display-adv2
  f-customer-display-adv:SCREEN-VALUE in frame Dialog-Frame = f-customer-display-adv
  .
END.
ON LEAVE OF f-rmethod-coeff IN FRAME Dialog-Frame
DO:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  IF rs-rmethod-type = "NO-COINS" THEN DO:
    ASSIGN
    f-rmethod-coeff
    v-rmethod-coeff = f-rmethod-coeff
    v-rmethod-coeff:screen-value = string(v-rmethod-coeff)
    .
  END.
END.
ON VALUE-CHANGED OF RS-cash-drawer-plug-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-cash-drawer-plug-type.
  CASE rs-cash-drawer-plug-type:
    WHEN 1 THEN DO:
       DISPLAY
       f-cash-drawer-plug-port
       WITH FRAME Dialog-Frame.
    END.
    WHEN 0 THEN DO:
        hide
        f-cash-drawer-plug-port
        IN FRAME Dialog-Frame.
    END.
  END CASE.
END.
ON VALUE-CHANGED OF rs-rmethod-coeff IN FRAME Dialog-Frame
DO:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    IF rs-rmethod-type = "MROUND" THEN DO:
    ASSIGN
    rs-rmethod-coeff
    v-rmethod-coeff = rs-rmethod-coeff
    v-rmethod-coeff:screen-value = string(v-rmethod-coeff)
    .
  END.
END.
ON VALUE-CHANGED OF rs-rmethod-type IN FRAME Dialog-Frame
DO:
 ASSIGN
 rs-rmethod-type
 .
 disable
 f-rmethod-coeff
 with frame Dialog-Frame .
 DISPLAY
 l-rmethod
 WITH FRAME Dialog-Frame.
 CASE rs-rmethod-type:
   WHEN "MROUND" THEN DO:
     ASSIGN
     rs-rmethod-coeff:VISIBLE IN FRAME Dialog-Frame = YES
     f-rmethod-coeff:VISIBLE IN FRAME Dialog-Frame = NO.
     .
   END.
   WHEN "NO-COINS" THEN DO:
       ASSIGN
       rs-rmethod-coeff:VISIBLE IN FRAME Dialog-Frame = NO
       f-rmethod-coeff:VISIBLE IN FRAME Dialog-Frame = YES
       f-rmethod-coeff:sensitive IN FRAME Dialog-Frame = (p-mode <> 'ПРОСМОТР':U)
       .
   END.
END CASE.
END.
ON VALUE-CHANGED OF t-cash-drawer-plug IN FRAME Dialog-Frame
DO:
  ASSIGN
  t-cash-drawer-plug.
  CASE t-cash-drawer-plug:
    WHEN no THEN DO:
      IF p-mode <> 'ПРОСМОТР':U THEN DO:
        ASSIGN
        t-cash-drawer-open = NO
        rs-cash-drawer-plug-type = 0
        f-cash-drawer-plug-imp = 1
        f-cash-drawer-plug-port = 0
        rs-cash-drawer-level = 1
        f-cash-drawer-limit = 1000000.00
        .
        DISPLAY
        rs-cash-drawer-plug-type
        f-cash-drawer-plug-port
        f-cash-drawer-plug-imp
        t-cash-drawer-open
        f-cash-drawer-limit
        WITH FRAME Dialog-Frame.
        disable
        f-cash-drawer-plug-imp
        f-cash-drawer-plug-port
        RS-cash-drawer-level
        rs-cash-drawer-plug-type
        t-cash-drawer-open
        f-cash-drawer-limit
        with FRAME Dialog-Frame.
      END.
    END.
    WHEN YES THEN DO:
        IF p-mode <> 'ПРОСМОТР':U THEN DO:
          enable
          f-cash-drawer-plug-imp
          f-cash-drawer-plug-port
          RS-cash-drawer-level
          t-cash-drawer-open
          f-cash-drawer-limit
          WITH FRAME Dialog-Frame.
        END.
        ASSIGN
        RS-cash-drawer-level:VISIBLE IN FRAME Dialog-Frame = NO
        t-cash-drawer-open:VISIBLE IN FRAME Dialog-Frame = YES
        .
    END.
  END CASE.
  APPLY "VALUE-CHANGED" TO rs-cash-drawer-plug-type.
END.
ON VALUE-CHANGED OF t-customer-display-plug IN FRAME Dialog-Frame
DO:
  ASSIGN
  t-customer-display-plug.
  CASE t-customer-display-plug:
    WHEN no THEN DO:
      IF p-mode <> 'ПРОСМОТР':U THEN DO:
        ASSIGN
        cb-customer-display-type = ''
        f-customer-display-port = ''
        f-customer-display-adv1 = fill('_', 20)
        f-customer-display-adv2 = fill('_', 20)
        .
        DISPLAY
        cb-customer-display-type
        f-customer-display-port
        f-customer-display-adv1
        f-customer-display-adv2
        WITH FRAME Dialog-Frame.
        disable
        f-customer-display-port
        CB-customer-display-type
        f-customer-display-adv1
        f-customer-display-adv2
        with FRAME Dialog-Frame.
      END.
    END.
    WHEN YES THEN DO:
        IF p-mode <> 'ПРОСМОТР':U THEN DO:
          enable
          cb-customer-display-type
          f-customer-display-adv1
          f-customer-display-adv2
          WITH FRAME Dialog-Frame.
        END.
        ASSIGN
        CB-customer-display-type:VISIBLE IN FRAME Dialog-Frame = yes
        f-customer-display-port:VISIBLE IN FRAME Dialog-Frame = yes
        f-customer-display-adv1:VISIBLE IN FRAME Dialog-Frame = yes
        f-customer-display-adv2:VISIBLE IN FRAME Dialog-Frame = yes
        .
    END.
  END CASE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        v-diasize-browse-handle     = browse BR-cash-pay-list :handle
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
ON LEAVE OF temp-cash-pay-list.frpay-code IN BROWSE br-cash-pay-list do:
define variable old-frpay-code    AS integer no-undo .
if not avail temp-cash-pay-list then return no-apply.
ASSIGN
OLD-frpay-code = temp-cash-pay-list.frpay-code
.
IF NOT (INTEGER(temp-cash-pay-list.frpay-code) >= 2
        OR
        INTEGER(temp-cash-pay-list.frpay-code) <= 4
        )
        THEN DO:
  MESSAGE
  "Неверный код вида оплаты ФР"
  VIEW-AS ALERT-BOX ERROR.
  ASSIGN
  temp-cash-pay-list.frpay-code = old-frpay-code
  .
  DISPLAY
  temp-cash-pay-list.frpay-code
  with BROWSE br-cash-pay-list.
  RETURN NO-APPLY.
END.
ASSIGN
temp-cash-pay-list.frpay-code = INTEGER(temp-cash-pay-list.frpay-code:SCREEN-VALUE IN BROWSE br-cash-pay-list)
.
DISPLAY
get-frpay-name (temp-cash-pay-list.frpay-code) @ v-frpay-name
WITH BROWSE br-cash-pay-list.
br-cash-pay-list:REFRESH() IN FRAME Dialog-Frame.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   :
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-current-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-current-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-current-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-current-tab-order)
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
if v-current-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-current-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-current-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-current-tab-order)
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-current-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-current-tab-order).
    if ii = num-entries(v-current-tab-order) then do:
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
    v-next-widget-name = entry(ii, v-current-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-current-tab-order)
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
  if v-current-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-current-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-current-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-current-tab-order)
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
          v-next-widget-name = entry(ii, v-current-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-current-tab-order)
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        "Нельзя менять параметры кассы в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
  end.
  hide
  frame Dialog-Frame.
  FIND FIRST locked_cash-desk no-LOCK WHERE
          locked_cash-desk.db-num = p-db-num
    AND   locked_cash-desk.obj-code = p-obj-code
    AND   locked_cash-desk.pos-type = p-pos-type
    AND   locked_cash-desk.cash-num = p-cash-num
    NO-ERROR.
  if not available locked_cash-desk then do:
    message
    substitute("Нет POS &1 на БД &2 &3&4 №&5"
               , p-pos-type
               , p-db-num
               , 'маг':U
               , p-obj-code
               , p-cash-num)
    view-as alert-box error.
    undo, return error .
  end.
  IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
    FIND FIRST locked_cash-desk-attr EXCLUSIVE-LOCK WHERE
              locked_cash-desk-attr.db-num = p-db-num
        AND   locked_cash-desk-attr.obj-code = p-obj-code
        AND   locked_cash-desk-attr.pos-type = p-pos-type
        AND   locked_cash-desk-attr.cash-num = p-cash-num
        AND   locked_cash-desk-attr.upper-attr-code = ''
        AND   locked_cash-desk-attr.attr-code = ''
        NO-WAIT NO-ERROR.
    if not available locked_cash-desk-attr
    and not locked locked_cash-desk-attr then do:
      create locked_cash-desk-attr.
      assign
      locked_cash-desk-attr.db-num = p-db-num
      locked_cash-desk-attr.obj-code = p-obj-code
      locked_cash-desk-attr.pos-type = p-pos-type
      locked_cash-desk-attr.cash-num = p-cash-num
      locked_cash-desk-attr.upper-attr-code = ''
      locked_cash-desk-attr.attr-code = ''
      .
     end.
     if locked locked_cash-desk-attr then do:
        FIND FIRST locked_cash-desk-attr EXCLUSIVE-LOCK WHERE
                  locked_cash-desk-attr.db-num = p-db-num
            AND   locked_cash-desk-attr.obj-code = p-obj-code
            AND   locked_cash-desk-attr.pos-type = p-pos-type
            AND   locked_cash-desk-attr.cash-num = p-cash-num
            AND   locked_cash-desk-attr.upper-attr-code = ''
            AND   locked_cash-desk-attr.attr-code = ''
             NO-ERROR.
      end.
  END.
  RUN FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY t-cash-shift t-cash-drawer-plug RS-cash-drawer-level f-advert-text1
          rs-log-level t-salesman-mandatory RS-cash-drawer-plug-type
          CB-screen-type f-advert-text2 t-cutter f-cash-drawer-plug-port
          t-manual-discnt f-screen-layout-id f-cash-drawer-plug-imp
          f-advert-text3 f-com-port t-clear-cash-counter f-cash-drawer-limit
          t-qnty-change t-cash-drawer-open f-cliche-lines1 f-cliche-lines2
          t-customer-display-plug f-cliche-lines3 CB-customer-display-type
          f-cliche-lines4 f-cliche-lines5 f-customer-display-port
          f-cliche-lines6 f-customer-display-adv1 t-print-good-code
          f-customer-display-adv2 f-max-netto l-rmethod CB-keyboard-type
          rs-rmethod-type f-keyboard-layout-id f-nalc rs-rmethod-coeff
          CB-cashless-system t-rcpt-ord-slip-print t-card-reader-plug
          t-rcpt-ord-alt-print CB-cctv-system f-cctv-system-address f-main
          F-devices f-fisreg f-rec-print f-interface l-log-level
          f-screen-layout-name for-curr-name f-keyboard-layout-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help t-cash-shift t-cash-drawer-plug
         RS-cash-drawer-level f-advert-text1 rs-log-level BR-pay-names
         t-salesman-mandatory RS-cash-drawer-plug-type CB-screen-type
         f-advert-text2 t-cutter f-cash-drawer-plug-port t-manual-discnt
         f-cash-drawer-plug-imp f-advert-text3 b-screen-layout-id f-com-port
         t-clear-cash-counter f-cash-drawer-limit t-qnty-change
         t-cash-drawer-open f-cliche-lines1 f-cliche-lines2 b-add-cash-pay
         b-del-cash-pay BR-cash-pay-list t-customer-display-plug
         f-cliche-lines3 CB-customer-display-type f-cliche-lines4
         f-cliche-lines5 f-customer-display-port f-cliche-lines6
         f-customer-display-adv1 t-print-good-code f-customer-display-adv2
         f-max-netto CB-keyboard-type rs-rmethod-type b-keyboard-layout-id
         b-curr f-nalc rs-rmethod-coeff CB-cashless-system
         t-rcpt-ord-slip-print t-card-reader-plug b-interface
         t-rcpt-ord-alt-print CB-cctv-system f-cctv-system-address B-devices
         b-rec-print B-main b-fisreg f-main F-devices f-fisreg f-rec-print
         f-interface l-cash-drawer-level l-cash-drawer-plug-type for-curr-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-cash-pay-list FOR EACH temp-cash-pay-list.    OPEN QUERY BR-pay-names FOR EACH temp-pay-names.
END PROCEDURE.
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
DEFINE VARIABLE v-dop1 AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-fr-code AS integer NO-UNDO.
DEFINE VARIABLE v-cp-list AS character NO-UNDO.
DEFINE VARIABLE v-name AS character NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
DEFINE VARIABLE v-jj AS integer NO-UNDO.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
DEFINE BUFFER buf_currency FOR ub.currency.
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
            , input 'cd-type-IBS-TH':U
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
and not available locked_cash-desk then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
for each buf_Cash-desk-attr no-lock where
        buf_cash-desk-attr.db-num = p-db-num
     and buf_cash-desk-attr.obj-code = p-obj-code
     and buf_cash-desk-attr.pos-type = p-pos-type
     and buf_cash-desk-attr.cash-num = p-cash-num
     :
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = 'маг':U
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code  = buf_cash-desk-attr.upper-attr-code
        and thbjattr_thbj-attr.prop-code  = buf_cash-desk-attr.attr-code no-error.
  if not available thbjattr_thbj-attr then do:
    create thbjattr_thbj-attr.
    assign
    thbjattr_thbj-attr.obj-type = 'маг':U
    thbjattr_thbj-attr.obj-code = p-obj-code
    thbjattr_thbj-attr.upper-prop-code  = buf_cash-desk-attr.upper-attr-code
    thbjattr_thbj-attr.prop-code  = buf_cash-desk-attr.attr-code
    .
  end.
  assign
  thbjattr_thbj-attr.property-value-character  = buf_cash-desk-attr.attr-value-character
  thbjattr_thbj-attr.property-value-date  = buf_cash-desk-attr.attr-value-date
  thbjattr_thbj-attr.property-value-decimal  = buf_cash-desk-attr.attr-value-decimal
  thbjattr_thbj-attr.property-value-integer  = buf_cash-desk-attr.attr-value-integer
  thbjattr_thbj-attr.property-value-logical  = buf_cash-desk-attr.attr-value-logical
  thbjattr_thbj-attr.prop-value-type  = buf_cash-desk-attr.attr-value-type
  .
end.
FOR EACH thbjattr_thbj-attr:
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  CASE thbjattr_thbj-attr.upper-prop-code :
    WHEN 'IBS-TH_main':U THEN DO:
      CASE v-entry:
        WHEN 'cash-shift':U THEN DO:
          ASSIGN
          t-cash-shift = logical(thbjattr_thbj-attr.property-value-integer)
          t-cash-shift:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
       WHEN 'nalc':U THEN DO:
          ASSIGN
          f-nalc = thbjattr_thbj-attr.property-value-integer
          f-nalc:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
          .
          FIND FIRST buf_currency NO-LOCK WHERE
                    buf_currency.curr-code = f-nalc NO-ERROR.
          IF AVAILABLE buf_currency THEN DO:
              ASSIGN
              for-curr-name = buf_currency.curr-abbr.
          END.
        END.
       WHEN 'salesman-mandatory':U THEN DO:
          ASSIGN
          t-salesman-mandatory = logical(thbjattr_thbj-attr.property-value-integer)
          t-salesman-mandatory:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
        WHEN 'manual-discnt':U THEN DO:
          ASSIGN
          t-manual-discnt = logical(thbjattr_thbj-attr.property-value-integer)
          t-manual-discnt:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
        WHEN 'log-level':U THEN DO:
          ASSIGN
          rs-log-level = thbjattr_thbj-attr.property-value-integer
          rs-log-level:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
        WHEN 'clear-cash-counter':U THEN DO:
          ASSIGN
          t-clear-cash-counter = logical(thbjattr_thbj-attr.property-value-integer)
          t-clear-cash-counter:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
        WHEN 'qnty-change':U THEN DO:
          ASSIGN
          t-qnty-change = logical(thbjattr_thbj-attr.property-value-integer)
          t-qnty-change:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
     END CASE.
   END.
   WHEN 'IBS-TH_devices':U THEN DO:
     CASE v-entry:
       WHEN 'cash-drawer-plug':U THEN DO:
         ASSIGN
         t-cash-drawer-plug = logical(thbjattr_thbj-attr.property-value-integer)
         t-cash-drawer-plug:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN 'cash-drawer-plug-type':U THEN DO:
         ASSIGN
         rs-cash-drawer-plug-type = thbjattr_thbj-attr.property-value-integer
         rs-cash-drawer-plug-type:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
           .
       END.
       WHEN 'cash-drawer-plug-port':U THEN DO:
         ASSIGN
         f-cash-drawer-plug-port = thbjattr_thbj-attr.property-value-integer
         f-cash-drawer-plug-port:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN 'cash-drawer-plug-imp':U THEN DO:
         ASSIGN
         f-cash-drawer-plug-imp = thbjattr_thbj-attr.property-value-integer
         f-cash-drawer-plug-imp:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN 'cash-drawer-open':U THEN DO:
        ASSIGN
        t-cash-drawer-open = logical(thbjattr_thbj-attr.property-value-integer)
        t-cash-drawer-open:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
        .
       END.
       WHEN 'cash-drawer-limit':U THEN DO:
         ASSIGN
         f-cash-drawer-limit = thbjattr_thbj-attr.property-value-decimal
         f-cash-drawer-limit:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN 'card-reader-plug':U THEN DO:
         ASSIGN
         t-card-reader-plug = logical(thbjattr_thbj-attr.property-value-integer)
         t-card-reader-plug:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN 'customer-display-plug':U THEN DO:
         ASSIGN
         t-customer-display-plug = logical(thbjattr_thbj-attr.property-value-integer)
         t-customer-display-plug:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
        WHEN 'customer-display-adv':U THEN DO:
          ASSIGN
          f-customer-display-adv = thbjattr_thbj-attr.property-value-character
          f-customer-display-adv1 = entry(1, thbjattr_thbj-attr.property-value-character, chr(4))
          f-customer-display-adv2 = entry(2, thbjattr_thbj-attr.property-value-character, chr(4))
          NO-ERROR
          .
          f-customer-display-adv:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr)).
        END.
       WHEN 'keyboard-type':U THEN DO:
         ASSIGN
         cb-keyboard-type = thbjattr_thbj-attr.property-value-character
         cb-keyboard-type:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN 'keyboard-layout-id':U THEN DO:
         ASSIGN
         f-keyboard-layout-id = thbjattr_thbj-attr.property-value-character
         f-keyboard-layout-id:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       end.
       WHEN 'cashless-system':U THEN DO:
         ASSIGN
         cb-cashless-system = thbjattr_thbj-attr.property-value-character
         cb-cashless-system:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       end.
       WHEN 'customer-display-type':U THEN DO:
         ASSIGN
         cb-customer-display-type = thbjattr_thbj-attr.property-value-character
         cb-customer-display-type:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN 'customer-display-port':U THEN DO:
         ASSIGN
         f-customer-display-port = thbjattr_thbj-attr.property-value-character
         f-customer-display-port:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
      WHEN 'cctv-system':U THEN DO:
         ASSIGN
         cb-cctv-system = thbjattr_thbj-attr.property-value-character
         cb-cctv-system:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN 'cctv-system-address':U THEN DO:
         ASSIGN
         f-cctv-system-address = thbjattr_thbj-attr.property-value-character
         f-cctv-system-address:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
      END CASE.
    END.
    WHEN 'IBS-TH_fisreg':U THEN DO:
      CASE v-entry:
        WHEN 'cash-drawer-level':U THEN DO:
         ASSIGN
         rs-cash-drawer-level = thbjattr_thbj-attr.property-value-integer
         rs-cash-drawer-level:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
           .
        END.
         WHEN 'cash-pay-list':U THEN DO:
          run get-cash-pay-list in this-procedure ( input thbjattr_thbj-attr.property-value-character).
         END.
         WHEN 'pay-names':U THEN DO:
           run get-pay-names in this-procedure ( input thbjattr_thbj-attr.property-value-character).
         end.
          WHEN 'cutter':U THEN DO:
            ASSIGN
            t-cutter = logical(thbjattr_thbj-attr.property-value-integer)
            t-cutter:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          END.
          WHEN 'com-port':U THEN DO:
            ASSIGN
            f-com-port = thbjattr_thbj-attr.property-value-character
            f-com-port:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          END.
      END case.
    END.
    WHEN 'IBS-TH_rec-print':U THEN DO:
      CASE v-entry:
        WHEN 'max-netto':U THEN DO:
          ASSIGN
          f-max-netto = thbjattr_thbj-attr.property-value-decimal
          f-max-netto:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
          .
        END.
        WHEN 'advert-text':U THEN DO:
         ASSIGN
         f-advert-text = thbjattr_thbj-attr.property-value-character
         f-advert-text:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         f-advert-text1 = ENTRY(1, f-advert-text, chr(4))
         f-advert-text2 = ENTRY(2, f-advert-text, chr(4))
         f-advert-text3 = ENTRY(3, f-advert-text, chr(4))
         .
        END.
        WHEN 'cliche-lines':U THEN DO:
          ASSIGN
          f-cliche-lines = thbjattr_thbj-attr.property-value-character
          f-cliche-lines:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
          f-cliche-lines1 = ENTRY(1, f-cliche-lines, chr(4))
          f-cliche-lines2 = ENTRY(2, f-cliche-lines, chr(4))
          f-cliche-lines3 = ENTRY(3, f-cliche-lines, chr(4))
          f-cliche-lines4 = ENTRY(4, f-cliche-lines, chr(4))
          f-cliche-lines5 = ENTRY(5, f-cliche-lines, chr(4))
          f-cliche-lines6 = ENTRY(6, f-cliche-lines, chr(4))
          .
        END.
        WHEN 'print-good-code':U THEN DO:
             ASSIGN
             t-print-good-code = logical(thbjattr_thbj-attr.property-value-integer)
             t-print-good-code:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
             .
        END.
        when 'rmethod-type':U then do:
         ASSIGN
         rs-rmethod-type = thbjattr_thbj-attr.property-value-character
         rs-rmethod-type:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
        end.
        when 'rmethod-coeff':U then do:
         ASSIGN
         v-rmethod-coeff = thbjattr_thbj-attr.property-value-decimal
         v-rmethod-coeff:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       end.
       when 'rcpt-ord-slip-print':U then do:
         ASSIGN
         t-rcpt-ord-slip-print = logical(thbjattr_thbj-attr.property-value-integer)
         t-rcpt-ord-slip-print:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       end.
       when 'rcpt-ord-alt-print':U then do:
         ASSIGN
         t-rcpt-ord-alt-print = logical(thbjattr_thbj-attr.property-value-integer)
         t-rcpt-ord-alt-print:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       end.
      END CASE.
    END.
    when 'IBS-TH_interface':U then do:
      case v-entry:
       WHEN 'screen-type':U THEN DO:
         ASSIGN
         cb-screen-type = thbjattr_thbj-attr.property-value-character
         cb-screen-type:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       END.
       WHEN 'screen-layout-id':U THEN DO:
         ASSIGN
         f-screen-layout-id = thbjattr_thbj-attr.property-value-character
         f-screen-layout-id:private-data in frame Dialog-Frame = "recid=" + string(recid(thbjattr_thbj-attr))
         .
       end.
      END CASE.
    end.
  END CASE.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
if rs-rmethod-type = "MROUND" then do:
  ASSIGN
  rs-rmethod-coeff = v-rmethod-coeff
  f-rmethod-coeff = 0
  .
end.
else do:
  assign
  f-rmethod-coeff = v-rmethod-coeff
  rs-rmethod-coeff = 2
  .
end.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-h AS HANDLE NO-UNDO.
DEFINE VARIABLE v-h1 AS HANDLE NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
DEFINE VARIABLE v-jj AS integer NO-UNDO.
define variable v-list-items as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
DEFINE BUFFER buf_layout FOR ub.layout.
v-list-items = chr(44).
do v-ii = 1 to num-entries('IBM-VFD,Shtrih-M_v_A1.40,Posiflex-pd2800-320':U):
  v-list-items = v-list-items + chr(44) +
                 entry(v-ii, 'IBM VFD,Штрих-М v.A1.40,Posiflex-pd2800-320':U) + chr(44) + entry(v-ii, 'IBM-VFD,Shtrih-M_v_A1.40,Posiflex-pd2800-320':U)
  .
end.
assign
cb-customer-display-type:list-item-pairs in frame Dialog-Frame = v-list-items
.
v-list-items = ''.
do v-ii = 1 to num-entries('0,1,2,3':U):
  v-list-items = v-list-items + (if v-ii = 1 then '' else chr(44)) +
                 entry(v-ii, 'Нет логирования,Низкий,Средний,Высокий':U) + chr(44) + entry(v-ii, '0,1,2,3':U)
  .
end.
assign
rs-log-level:radio-buttons in frame Dialog-Frame = v-list-items
.
v-list-items = ''.
assign
cb-keyboard-type:list-items in frame Dialog-Frame  = chr(44) + 'IBM-50':U.
cb-screen-type:list-items in frame Dialog-Frame  =  'Screen,TouchScreen':U.
v-list-items = chr(44).
do v-ii = 1 to  num-entries('sberbank':U):
  assign
  v-list-items = v-list-items + chr(44) + entry (lookup (entry(v-ii, 'sberbank':U), 'sberbank':U) + 1, ',' + 'Сбербанк':U) + chr(44) + entry(v-ii, 'sberbank':U).
end.
assign
cb-cashless-system:list-item-pairs in frame Dialog-Frame =  v-list-items
.
v-list-items = chr(44).
do v-ii = 1 to  num-entries('Intellect,Prizma':U):
  assign
  v-list-items = v-list-items + chr(44) + entry (lookup (entry(v-ii, 'Intellect,Prizma':U), 'Intellect,Prizma':U) + 1, ',' + 'Интеллект,Призма':U) + chr(44) + entry(v-ii, 'Intellect,Prizma':U).
end.
assign
cb-cctv-system:list-item-pairs in frame Dialog-Frame =  v-list-items
.
assign
rs-rmethod-type:radio-buttons in frame Dialog-Frame = "Отсечение до n-знака после зап." + chr(44) + "MROUND" + chr(44) +
                                                        "Нет номиналов меньше чем" + chr(44) + "NO-COINS"
.
rs-rmethod-coeff:radio-buttons in frame Dialog-Frame = "Сотни" + chr(44) +  "-2" + chr(44) +
                                                        "Десятки" + chr(44) + "-1"  + chr(44) +
                                                        "Рубли" + chr(44) + "0" + chr(44)  +
                                                        "Десятки копеек" + chr(44) + "1"  + chr(44) +
                                                        "копейки" + chr(44) + "2".
ASSIGN
FRAME Dialog-Frame:TITLE = substitute("&1 &2&3"
                                       ,FRAME Dialog-Frame:TITLE
                                       ,(if p-obj-type = ""
                                         then ""
                                         else 'маг':U)
                                       ,(IF p-obj-type = "" THEN "" ELSE string(p-obj-code)))
v-tab-order[1] = "t-cash-shift,t-salesman-mandatory,t-manual-discnt,t-clear-cash-counter,t-qnty-change,b-curr,rs-log-level"
v-labels[1] = 'f-nalc,for-curr-name,l-log-level'
v-tab-order[2] = "t-cash-drawer-plug,rs-cash-drawer-plug-type,f-cash-drawer-plug-port,f-cash-drawer-plug-imp,f-cash-drawer-limit,t-cash-drawer-open," +
                 "t-customer-display-plug,cb-customer-display-type,f-customer-display-port,f-customer-display-adv1,f-customer-display-adv2," +
                 "cb-keyboard-type,b-keyboard-layout-id,cb-cashless-system,t-card-reader-plug,cb-cctv-system,f-cctv-system-address"
v-labels[2] = 'l-cash-drawer-plug-type,f-keyboard-layout-id,f-keyboard-layout-name'
v-tab-order[3] = "rs-cash-drawer-level,br-cash-pay-list,b-add-cash-pay,b-del-cash-pay,br-pay-names,t-cutter,f-com-port"
v-labels[3] = "l-cash-drawer-level"
v-tab-order[4] = "f-advert-text1,f-advert-text2,f-advert-text3," +
                  "f-cliche-lines1,f-cliche-lines2,f-cliche-lines3,f-cliche-lines4," +
                  "t-print-good-code,f-max-netto,rs-rmethod-type,rs-rmethod-coeff,f-rmethod-coeff,t-rcpt-ord-slip-print,t-rcpt-ord-alt-print"
v-labels[4] = "l-rmethod"
v-tab-order[5] = "cb-screen-type,b-screen-layout-id"
v-labels[5] = "f-screen-layout-id,f-screen-layout-name"
.
v-h = FRAME Dialog-Frame:FIRST-CHILD.
DO WHILE valid-handle(v-h).
  IF v-h:TYPE = "field-group"  THEN DO:
     v-h1 = v-h:FIRST-CHILD.
     DO WHILE valid-handle(v-h1).
      RUN tempwidg_create-record IN THIS-PROCEDURE ( INPUT v-h1).
      ASSIGN
      v-h1 = v-h1:NEXT-sibling.
    END.
  END.
  v-h = v-h:NEXT-SIBLING.
END.
DO v-ii = 1 TO 5:
  IF v-tab-order[v-ii] > '' THEN do:
    DO v-jj = 1 TO NUM-ENTRIES(v-tab-order[v-ii]):
     FIND FIRST temp-widget WHERE
                temp-widget.name_ = ENTRY(v-jj,v-tab-order[v-ii]) NO-ERROR.
     IF AVAILABLE temp-widget THEN DO:
         temp-widget.section_ = STRING(v-ii).
     END.
    END.
  END.
  IF v-labels[v-ii] > '' THEN do:
    DO v-jj = 1 TO NUM-ENTRIES(v-labels[v-ii]):
     FIND FIRST temp-widget WHERE
                temp-widget.name_ = ENTRY(v-jj,v-labels[v-ii]) NO-ERROR.
     IF AVAILABLE temp-widget THEN DO:
        temp-widget.section_ = STRING(v-ii).
      END.
    END.
  END.
END.
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-cliche-lines1", f-cliche-lines1).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-cliche-lines2", f-cliche-lines2).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-cliche-lines3", f-cliche-lines3).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-cliche-lines4", f-cliche-lines4).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-advert-text1", f-advert-text1).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-advert-text2", f-advert-text2).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-advert-text3", f-advert-text3).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-customer-display-adv1", f-customer-display-adv1).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-customer-display-adv2", f-customer-display-adv2).
RUN tempwidg_write-character IN THIS-PROCEDURE ( INPUT "f-rmethod-coeff", f-rmethod-coeff).
FIND FIRST buf_layout NO-LOCK WHERE
          buf_layout.layout-id = f-keyboard-layout-id NO-ERROR.
IF AVAILABLE buf_layout THEN DO:
    ASSIGN
    f-keyboard-layout-name = buf_layout.layout-name.
END.
ELSE DO:
    ASSIGN
    f-keyboard-layout-name = ?.
END.
FIND FIRST buf_layout NO-LOCK WHERE
          buf_layout.layout-id = f-screen-layout-id NO-ERROR.
IF AVAILABLE buf_layout THEN DO:
    ASSIGN
    f-screen-layout-name = buf_layout.layout-name.
END.
ELSE DO:
    ASSIGN
    f-screen-layout-name = ?.
END.
DISPLAY
f-main
f-devices
f-fisreg
f-rec-print
f-interface
for-curr-name
l-cash-drawer-plug-type
l-cash-drawer-level
f-keyboard-layout-name
f-screen-layout-name
l-log-level
t-clear-cash-counter
t-qnty-change
WITH FRAME Dialog-Frame.
assign
fh = frame Dialog-Frame:first-child
wh = fh:first-child
.
do while valid-handle(wh):
if wh:private-data begins "recid=" then do:
  find first thbjattr_thbj-attr where
            recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
  IF wh:DATA-TYPE = 'logical':U
  AND thbjattr_thbj-attr.prop-value-type = 'integer':U THEN DO:
     wh:screen-value = string(IF thbjattr_thbj-attr.property-value-integer = 1 THEN YES ELSE NO).
  END.
  ELSE DO:
    assign
    wh:screen-value = string(buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value).
  END.
end.
ELSE DO:
   FIND FIRST temp-widget NO-LOCK WHERE
             temp-widget.NAME_ = wh:NAME NO-ERROR.
   IF AVAILABLE temp-widget THEN DO:
      CASE temp-widget.DATA-TYPE_:
        WHEN 'character':U THEN DO:
            ASSIGN
            wh:SCREEN-VALUE = temp-widget.CHARACTER_.
        END.
      END CASE.
   END.
END.
wh = wh:next-sibling.
end.
ENABLE
B-exit WHEN p-mode = 'ИЗМЕНЕНИЕ':U
b-quit
B-Help
b-main
b-devices
b-fisreg
b-rec-print
b-interface
t-salesman-mandatory WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-manual-discnt WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-cash-drawer-open WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-cash-drawer-limit WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-customer-display-adv1 WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-customer-display-adv2 WHEN p-mode = 'ИЗМЕНЕНИЕ':U
b-curr WHEN p-mode = 'ИЗМЕНЕНИЕ':U
rs-rmethod-type WHEN p-mode = 'ИЗМЕНЕНИЕ':U
rs-rmethod-coeff WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-cash-drawer-plug WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-cash-drawer-plug-port WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-cash-drawer-plug-imp WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-cutter WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-com-port WHEN p-mode = 'ИЗМЕНЕНИЕ':U
t-customer-display-plug  WHEN p-mode = 'ИЗМЕНЕНИЕ':U
cb-keyboard-type WHEN p-mode = 'ИЗМЕНЕНИЕ':U
b-keyboard-layout-id WHEN p-mode = 'ИЗМЕНЕНИЕ':U
cb-cashless-system WHEN p-mode = 'ИЗМЕНЕНИЕ':U
cb-cctv-system WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-cctv-system-address WHEN p-mode = 'ИЗМЕНЕНИЕ':U
cb-customer-display-type WHEN p-mode = 'ИЗМЕНЕНИЕ':U
cb-screen-type WHEN p-mode = 'ИЗМЕНЕНИЕ':U
b-screen-layout-id WHEN p-mode = 'ИЗМЕНЕНИЕ':U
rs-cash-drawer-level WHEN p-mode = 'ИЗМЕНЕНИЕ':U
rs-log-level when p-mode = 'ИЗМЕНЕНИЕ':U
t-clear-cash-counter when p-mode = 'ИЗМЕНЕНИЕ':U
t-qnty-change when p-mode = 'ИЗМЕНЕНИЕ':U
br-cash-pay-list
br-pay-names
t-print-good-code WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-advert-text1 WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-advert-text2 WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-advert-text3 WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-cliche-lines1 WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-cliche-lines2 WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-cliche-lines3 WHEN p-mode = 'ИЗМЕНЕНИЕ':U
f-cliche-lines4 WHEN p-mode = 'ИЗМЕНЕНИЕ':U
b-add-cash-pay  WHEN p-mode = 'ИЗМЕНЕНИЕ':U
b-del-cash-pay WHEN p-mode = 'ИЗМЕНЕНИЕ':U
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
IF p-mode = 'ПРОСМОТР':U THEN DO:
    HIDE
    b-exit
    IN FRAME Dialog-Frame.
    ASSIGN
    b-quit:LABEL = "&Выход"
    b-quit:COLUMN = 1
    temp-cash-pay-list.frpay-code:read-only IN BROWSE br-cash-pay-list = YES
    .
END.
HIDE
f-cliche-lines5
f-cliche-lines6
IN FRAME Dialog-Frame.
OPEN QUERY br-cash-pay-list FOR EACH temp-cash-pay-list.
OPEN QUERY br-pay-names FOR EACH temp-pay-names.
APPLY "CHOOSE" TO b-main.
END PROCEDURE.
PROCEDURE proc-init-devices :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:
 b-devices:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame Dialog-Frame .
 f-devices:fgcolor = 1   .
 b-main:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-fisreg:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-rec-print:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-interface:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 ASSIGN
 f-main:fgcolor = ?
 f-fisreg:fgcolor = ?
 f-rec-print:fgcolor = ?
 f-interface:fgcolor = ?
 .
 FOR EACH temp-widget WHERE
        temp-widget.SECTION_ = "2":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = YES.
END.
FOR EACH temp-widget WHERE
        temp-widget.SECTION_ <> "2"
    AND temp-widget.SECTION_ <> "":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = no.
 END.
 .
 v-current-tab-order = v-tab-order[2].
 APPLY "VALUE-CHANGED" TO t-cash-drawer-plug.
 APPLY "VALUE-CHANGED" TO t-customer-display-plug.
 APPLY "VALUE-CHANGED" TO cb-cctv-system.
end.
END PROCEDURE.
PROCEDURE proc-init-fisreg :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:
 b-fisreg:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame Dialog-Frame .
 f-fisreg:fgcolor = 1   .
 b-devices:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-main:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-rec-print:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-interface:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 ASSIGN
 f-devices:fgcolor = ?
 f-main:fgcolor = ?
 f-rec-print:fgcolor = ?
 f-interface:fgcolor = ?
 .
 FOR EACH temp-widget WHERE
        temp-widget.SECTION_ = "3":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = YES.
   if temp-widget.name_ = 'f-com-port' and
      Locked_cash-desk.fr-type <> 'prim08tk':U then
   do:
     ASSIGN
       temp-widget.HANDLE_:VISIBLE = no .
   end.
 END.
FOR EACH temp-widget WHERE
        temp-widget.SECTION_ <> "3"
    AND temp-widget.SECTION_ <> "":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = no.
 END.
 .
 v-current-tab-order = v-tab-order[3].
end.
END PROCEDURE.
PROCEDURE proc-init-interface :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:
 b-interface:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame Dialog-Frame .
 f-interface:fgcolor = 1   .
 b-devices:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-fisreg:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-rec-print:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-main:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 ASSIGN
 f-devices:fgcolor = ?
 f-fisreg:fgcolor = ?
 f-rec-print:fgcolor = ?
 f-main:fgcolor = ?
 .
 FOR EACH temp-widget WHERE
        temp-widget.SECTION_ = "5":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = YES.
END.
FOR EACH temp-widget WHERE
        temp-widget.SECTION_ <> "5"
    AND temp-widget.SECTION_ <> "":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = no.
 END.
 .
 v-current-tab-order = v-tab-order[5].
end.
END PROCEDURE.
PROCEDURE proc-init-main :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:
 b-main:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame Dialog-Frame .
 f-main:fgcolor = 1   .
 b-devices:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-fisreg:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-rec-print:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-interface:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 ASSIGN
 f-devices:fgcolor = ?
 f-fisreg:fgcolor = ?
 f-rec-print:fgcolor = ?
 f-interface:fgcolor = ?
 .
 FOR EACH temp-widget WHERE
        temp-widget.SECTION_ = "1":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = YES.
END.
FOR EACH temp-widget WHERE
        temp-widget.SECTION_ <> "1"
    AND temp-widget.SECTION_ <> "":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = no.
 END.
 .
 v-current-tab-order = v-tab-order[1].
 APPLY "VALUD-CHANGED" TO rs-rmethod-type.
end.
END PROCEDURE.
PROCEDURE proc-init-rec-print :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:
 b-rec-print:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame Dialog-Frame .
 f-rec-print:fgcolor = 1   .
 b-devices:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-fisreg:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-main:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-interface:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 ASSIGN
 f-devices:fgcolor = ?
 f-fisreg:fgcolor = ?
 f-main:fgcolor = ?
 f-interface:fgcolor = ?
 .
 FOR EACH temp-widget WHERE
        temp-widget.SECTION_ = "4":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = YES.
END.
FOR EACH temp-widget WHERE
        temp-widget.SECTION_ <> "4"
    AND temp-widget.SECTION_ <> "":
   ASSIGN
    temp-widget.HANDLE_:VISIBLE = no.
 END.
 .
 v-current-tab-order = v-tab-order[4].
 APPLY "VALUE-CHANGED" TO rs-rmethod-type.
end.
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
define variable v-loc-same as logical no-undo .
define variable v-cash-pay-list as character no-undo .
define variable v-pay-names as character no-undo .
IF p-mode = 'ПРОСМОТР':U THEN RETURN ERROR.
run  set-cash-pay-list in this-procedure ( output v-cash-pay-list) no-error.
if error-status:error then do:
  message
  error-status:get-message(1)  skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
run set-pay-names in this-procedure ( output v-pay-names) no-error.
if error-status:error then do:
  message
  error-status:get-message(1)  skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
assign
fh = frame Dialog-Frame:first-child
wh = fh:first-child
.
  main-block:
  do transaction:
  do while valid-handle(wh):
    if wh:private-data begins "recid=" then do:
      find first thbjattr_thbj-attr where
                recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
      IF wh:DATA-TYPE = 'logical':U
      AND thbjattr_thbj-attr.prop-value-type = 'integer':U THEN DO:
        assign
        thbjattr_thbj-attr.property-value-integer = (IF wh:INPUT-VALUE = YES THEN 1 ELSE 0).
      END.
      ELSE DO:
        assign
        buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
      END.
    end.
    wh = wh:next-sibling.
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.upper-prop-code = 'IBS-TH_fisreg':U
        and thbjattr_thbj-attr.prop-code = 'cash-pay-list':U
        and thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code  .
  assign
  thbjattr_thbj-attr.property-value-character = v-cash-pay-list.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.upper-prop-code = 'IBS-TH_fisreg':U
        and thbjattr_thbj-attr.prop-code = 'pay-names':U
        and thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code  .
  assign
  thbjattr_thbj-attr.property-value-character = v-pay-names.
  for each thbjattr_thbj-attr
  break by thbjattr_thbj-attr.upper-prop-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if first-of(thbjattr_thbj-attr.upper-prop-code) then do:
      empty temp-table thbjattr___thbj-attr.
    end.
    create thbjattr___thbj-attr.
    buffer-copy
    thbjattr_thbj-attr
    to
    thbjattr___thbj-attr.
    if last-of(thbjattr_thbj-attr.upper-prop-code) then do:
      empty temp-table thbjattr___thbj-attr.
    end.
  end.
  v-same = yes.
  for each thbjattr_thbj-attr,
      first temp-thbj-attr where
            temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
        and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
        and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
        and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code
  break
  by thbjattr_thbj-attr.upper-prop-code :
    buffer-compare
    thbjattr_thbj-attr
    to temp-thbj-attr
    save result in v-loc-same.
    if v-loc-same = no then do:
      if  thbjattr_thbj-attr.upper-prop-code <> 'cd-type-IBS-TH':U
      then do:
        run update-cda in this-procedure ( buffer thbjattr_thbj-attr).
      end.
    end.
  end.
end.
v-same = no.
END PROCEDURE.
PROCEDURE update-cda :
DEFINE PARAMETER BUFFER buf_thbjattr_thbj-attr FOR thbjattr_thbj-attr.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
find first   buf_cash-desk-attr share-lock where
      buf_cash-desk-attr.db-num = locked_Cash-desk.db-num
  and buf_cash-desk-attr.obj-code = locked_Cash-desk.obj-code
  and buf_cash-desk-attr.pos-type = locked_Cash-desk.pos-type
  and buf_cash-desk-attr.cash-num = locked_cash-desk.cash-num
  and buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
and buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
no-error.
if not available buf_Cash-desk-attr then do:
  create buf_cash-desk-attr.
  assign
  buf_cash-desk-attr.db-num = locked_Cash-desk.db-num
  buf_cash-desk-attr.obj-code = locked_Cash-desk.obj-code
  buf_cash-desk-attr.pos-type = locked_Cash-desk.pos-type
  buf_cash-desk-attr.cash-num = locked_cash-desk.cash-num
  buf_cash-desk-attr.upper-attr-code = buf_thbjattr_thbj-attr.upper-prop-code
  buf_cash-desk-attr.attr-code = buf_thbjattr_thbj-attr.prop-code
  .
end.
assign
buf_cash-desk-attr.attr-value-character = buf_thbjattr_thbj-attr.property-value-character
buf_cash-desk-attr.attr-value-date = buf_thbjattr_thbj-attr.property-value-date
buf_cash-desk-attr.attr-value-decimal = buf_thbjattr_thbj-attr.property-value-decimal
buf_cash-desk-attr.attr-value-integer = buf_thbjattr_thbj-attr.property-value-integer
buf_cash-desk-attr.attr-value-logical = buf_thbjattr_thbj-attr.property-value-logical
buf_cash-desk-attr.attr-value-type = buf_thbjattr_thbj-attr.prop-value-type
.
END PROCEDURE.
FUNCTION get-frpay-name RETURNS CHARACTER
  ( INPUT p-frpay-code AS INTEGER ) :
DEFINE BUFFER buf_temp-pay-names FOR temp-pay-names.
FIND first buf_temp-pay-names WHERE
        buf_temp-pay-names.frpay-code = p-frpay-code NO-ERROR.
IF NOT AVAILABLE buf_temp-pay-names THEN RETURN "".
RETURN buf_temp-pay-names.frpay-name.
END FUNCTION.
FUNCTION getcp-name RETURNS CHARACTER
  ( INPUT p-cdpay-code AS INTEGER , INPUT p-curr-code AS INTEGER) :
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
FIND first buf_cash-pay NO-LOCK  WHERE
        buf_cash-pay.cdpay-code = p-cdpay-code
    AND buf_Cash-pay.curr-code = p-curr-code NO-ERROR.
IF NOT AVAILABLE buf_cash-pay THEN RETURN "!!!НЕИЗВЕСТНЫЙ ТИП КАСС.ПЛАТЕЖА".
RETURN buf_cash-pay.obj-name.
END FUNCTION.
