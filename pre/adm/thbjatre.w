DEFINE TEMP-TABLE section_thbj-attr NO-UNDO LIKE thbj-attr
       field upper-prop-name as character
       field global_ as logical
       field host_ as logical
       field shop_ as logical
       field store_ as logical
       field db_ as logical
       field region_ as logical
       .
DEFINE TEMP-TABLE X_thbj-attr LIKE thbj-attr
       field ind1 as char
       index pi ind1
       .
DEFINE BUFFER X_thbj-attr_2v FOR thbj-attr.
DEFINE BUFFER X_thbj-attr_v FOR thbj-attr.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "ДЕРЕВО параметров IBS TH".
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
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
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
procedure db-attr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
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
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
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
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
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
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-2value AS CHARACTER NO-UNDO.
define variable add-region as character no-undo .
define temp-table ttLoad
  field fName as character label "Параметр" format "X(50)"
  field fValue as character label "Значение" format "X(420)"
.
FUNCTION get-thbjattr-l-and-v RETURNS CHARACTER
  ( BUFFER buf_thbj-attr FOR ub.thbj-attr
   ,OUTPUT p-value AS CHARACTER
    )  FORWARD.
DEFINE MENU MENU-B-add
       MENU-ITEM m_region       LABEL "Регион"
       MENU-ITEM m_db           LABEL "БД"
       MENU-ITEM m_firm         LABEL "Фирма"
       MENU-ITEM m_shop         LABEL "Магазин"
       MENU-ITEM m_stock        LABEL "Склад"         .
DEFINE BUTTON B-1
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-copy
     LABEL "&Копия"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exp
     LABEL "Экспорт в формате пакета СПН"
     SIZE 40 BY 1.
DEFINE BUTTON b-load
     IMAGE-UP FILE "cmp/b-print.bmp":U
     IMAGE-DOWN FILE "cmp/b-print.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U  NO-CONVERT-3D-COLORS
     LABEL "Выгрузить"
     SIZE 3 BY 1 TOOLTIP "Выгрузить значения параметров в Excel".
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist1
     LABEL "&История"
     SIZE 4 BY 1.
DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE IMAGE I-tooltip
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.04.
DEFINE QUERY BR-2values FOR
      X_thbj-attr_2v SCROLLING.
DEFINE QUERY BR-section FOR
      section_thbj-attr SCROLLING.
DEFINE QUERY br-tree FOR
      X_thbj-attr SCROLLING.
DEFINE QUERY BR-values FOR
      X_thbj-attr_v SCROLLING.
DEFINE BROWSE BR-2values
  QUERY BR-2values NO-LOCK DISPLAY
      get-thbjattr-l-and-v( BUFFER X_thbj-attr_2v, OUTPUT v-2value) FORMAT "X(255)":U WIDTH 60 NO-LABEL
v-2value FORMAT "X(255)" WIDTH 40  NO-LABEL
    WITH NO-ROW-MARKERS SEPARATORS SIZE 88 BY 6.5 FIT-LAST-COLUMN.
DEFINE BROWSE BR-section
  QUERY BR-section NO-LOCK DISPLAY
      section_thbj-attr.upper-prop-name FORMAT "X(255)":U WIDTH 97 COLUMN-LABEL "Название секции"
SECTION_thbj-attr.GLOBAL_ FORMAT "+/" COLUMN-LABEL "Глоб"
SECTION_thbj-attr.region_ FORMAT "+/" COLUMN-LABEL "Рег"
SECTION_thbj-attr.host_ FORMAT "+/" COLUMN-LABEL "Фирма"
SECTION_thbj-attr.shop_ FORMAT "+/" COLUMN-LABEL "Маг"
SECTION_thbj-attr.store_ FORMAT "+/" COLUMN-LABEL "Скл"
SECTION_thbj-attr.db_ FORMAT "+/" COLUMN-LABEL "БД"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 123 BY 10.5
         TITLE "Все имеющиеся в системе секции параметров" ROW-HEIGHT-CHARS .63.
DEFINE BROWSE br-tree
  QUERY br-tree NO-LOCK DISPLAY
      get-objregion(X_thbj-attr.obj-type, X_thbj-attr.obj-code) FORMAT "X(20)" COLUMN-LABEL "Действует"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 35 BY 14.25 ROW-HEIGHT-CHARS .75 FIT-LAST-COLUMN.
DEFINE BROWSE BR-values
  QUERY BR-values NO-LOCK DISPLAY
      get-thbjattr-l-and-v( BUFFER X_thbj-attr_v, OUTPUT v-value) FORMAT "X(255)":U WIDTH 60 NO-LABEL
v-value FORMAT "X(255)" WIDTH 40  NO-LABEL
    WITH NO-ROW-MARKERS SEPARATORS SIZE 88 BY 9
         TITLE "Значения параметров" ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exp AT ROW 1 COL 41 WIDGET-ID 96
     B-Help AT ROW 1 COL 95
     BR-section AT ROW 2 COL 1 WIDGET-ID 200
     b-copy AT ROW 12.75 COL 1 WIDGET-ID 96
     B-add AT ROW 12.75 COL 11 WIDGET-ID 98
     B-chg AT ROW 12.75 COL 21 WIDGET-ID 2
     B-del AT ROW 12.75 COL 31 WIDGET-ID 4
     B-lkp AT ROW 12.75 COL 41 WIDGET-ID 6
     b-load AT ROW 12.75 COL 108 WIDGET-ID 102
     B-1 AT ROW 12.75 COL 114 WIDGET-ID 94
     b-hist1 AT ROW 12.75 COL 120 WIDGET-ID 100
     br-tree AT ROW 14 COL 1 WIDGET-ID 300
     BR-values AT ROW 14 COL 36 WIDGET-ID 400
     BR-2values AT ROW 21.75 COL 36 WIDGET-ID 500
     I-tooltip AT ROW 12.75 COL 111 WIDGET-ID 10
     SPACE(10.37) SKIP(14.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = TRUE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-1 IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE X_thbj-attr_v THEN DO:
    bell.
  END.
  run gbl/v-taobj.w
      ( INPUT X_thbj-attr_v.upper-prop-code
       ,INPUT X_thbj-attr_v.prop-code
       ) NO-ERROR.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-add-obj-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-add-obj-code AS INTEGER NO-UNDO.
DEFINE BUFFER buf_thbj-attr FOR ub.thbj-attr.
IF NOT AVAILABLE section_thbj-attr THEN DO:
add-region = ''.
   RETURN NO-APPLY.
END.
if add-region = '':U then do:
   run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if add-region = '':U then return no-apply.
RUN proc-add IN THIS-PROCEDURE ( INPUT add-region
                                 ,INPUT section_thbj-attr.upper-prop-code
                                 ,OUTPUT v-add-obj-type
                                 ,OUTPUT v-add-obj-code) NO-ERROR.
 APPLY "VALUE-CHANGED" TO br-section.
 IF v-add-obj-code > 0  THEN DO:
    FIND FIRST buf_thbj-attr NO-LOCK WHERE
              buf_thbj-attr.upper-prop-code = section_thbj-attr.upper-prop-code
         AND  buf_thbj-attr.obj-type = v-add-obj-type
        AND  buf_thbj-attr.obj-code = v-add-obj-code NO-ERROR.
    IF AVAILABLE buf_thbj-attr THEN DO:
       REPOSITION br-tree TO RECID RECID(buf_thbj-attr) NO-ERROR.
       APPLY "entry" TO br-tree.
       APPLY "VALUE-CHANGED" TO br-tree.
    END.
 END.
 ELSE DO:
 END.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
  define variable var-rec-id as recid no-undo.
  IF AVAILABLE X_thbj-attr THEN do:
     var-rec-id = recid (X_thbj-attr).
     RUN proc-upd-lkp IN THIS-PROCEDURE ( INPUT 'ИЗМЕНЕНИЕ':U
                                         ,INPUT X_thbj-attr.upper-prop-code
                                         ,INPUT X_thbj-attr.obj-type
                                         ,INPUT X_thbj-attr.obj-code) NO-ERROR.
      APPLY "VALUE-CHANGED" TO br-section.
      REPOSITION br-tree TO RECID var-rec-id NO-ERROR.
      APPLY "entry" TO br-tree.
      APPLY "VALUE-CHANGED" TO br-tree.
  END.
END.
ON CHOOSE OF b-copy IN FRAME Dialog-Frame
DO:
if not available X_thbj-attr then return no-apply.
if X_thbj-attr.obj-type = ''
and X_thbj-attr.obj-code = 0 then do:
  message
  substitute("CКОПИРОВАТЬ ПАРАМЕТРЫ МОЖНО ТОЛЬКО С ОБЪЕКТА ТОГО ЖЕ ТИПА!!!&1&1&1" +
             "НЕОТКУДА КОПИРОВАТЬ ГЛОБАЛЬНЫЕ ПАРАМЕТРЫ!!!"
             , chr(10))
  view-as alert-box error .
  return no-apply.
end.
run proc-b-copy in this-procedure ( input X_thbj-attr.upper-prop-code
                                   ,input X_thbj-attr.obj-type
                                   ,input X_thbj-attr.obj-code ) no-error.
if error-status:error then do:
  apply "ENTRY" to br-tree.
  return no-apply.
end.
APPLY "VALUE-CHANGED" TO br-section.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF AVAILABLE X_thbj-attr THEN DO:
   IF X_thbj-attr.obj-type = '' THEN DO:
     MESSAGE
     "НЕЛЬЗЯ УДАЛИТЬ СЕКЦИЮ с областью действия ГЛОБАЛЬНО!"
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN NO-APPLY.
   END.
   MESSAGE
   substitute("Вы действительно хотите удалить ВСЮ СЕКЦИЮ данного параметра с областью действия &1"
               , get-objregion(X_thbj-attr.obj-type, X_thbj-attr.obj-code))
   VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
   IF NOT glog THEN RETURN NO-APPLY.
   RUN thbjattr_delete-section  IN THIS-PROCEDURE (
                                                    input  X_thbj-attr.obj-type
                                                   ,INPUT X_thbj-attr.obj-code
                                                   ,INPUT X_thbj-attr.upper-prop-code) NO-ERROR.
   APPLY "VALUE-CHANGED" TO br-section.
  END.
END.
ON CHOOSE OF B-exp IN FRAME Dialog-Frame
DO:
  run utl/thbjexp.p ( INPUT parparentproc).
END.
ON CHOOSE OF b-hist1 IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER no-undo.
  IF AVAILABLE X_thbj-attr THEN DO:
    run ref/cthbjatr.w (
                       input parparentproc
                      ,input v-cntxt-host-code-obj
                      ,input v-cntxt-obj-type
                      ,input v-cntxt-obj-code
                      ,input ''
                      ,input "section"
                      ,input X_thbj-attr.obj-type
                      ,input X_thbj-attr.obj-code
                      ,input X_thbj-attr.upper-prop-code
                      ,input X_thbj-attr.prop-code
                      ,input ?
                      ,input "":U
                      ,input "":U
                      ,input v-cntxt-db-num
                      ,input-output v-rid-list  ) no-error .
  END.
END.
ON CHOOSE OF b-load IN FRAME Dialog-Frame
DO:
  define variable vFile      as character  no-undo.
  define variable vCurRow    as integer no-undo.
  define variable vSelectRow as logical no-undo.
  define variable exlim      as class ibs.th.bge.execlimpexp no-undo.
  define variable vExcelApp  as component-handle no-undo.
  empty temp-table ttLoad.
  vCurRow = br-values:focused-row.
  if vCurRow = ? then
  do:
    message "Нет параметров для выгрузки." view-as alert-box.
    return no-apply.
  end.
  vSelectRow = br-values:select-row(1).
  do while vSelectRow:
    if br-values:get-browse-column(1):screen-value <> "" then
    do:
      create ttLoad.
      assign
        ttLoad.fName  = br-values:get-browse-column(1):screen-value
        ttLoad.fValue = br-values:get-browse-column(2):screen-value
      .
    end.
    vSelectRow = br-values:select-next-row().
  end.
  br-values:select-row(vCurRow).
  vFile = substitute(
    "sec_&1_&2&3.txt",
    section_thbj-attr.upper-prop-code,
    X_thbj-attr.obj-type,
    X_thbj-attr.obj-code
  ).
  output to value(vFile).
  output close.
  vFile = search(vFile).
  exlim = new ibs.th.bge.execlimpexp ().
  exlim:expToExcel(temp-table ttLoad:handle, vFile).
  os-delete vFile value(vFile).
  os-delete vFile value(search("last.dir")).
  vFile = replace(vFile, ".txt", ".xlsx").
  if search(vFile) <> ? then do:
    create "Excel.Application":U vExcelApp no-error.
    if error-status :error then do:
      message "Не удалось открыть выгруженный файл" vFile "." view-as alert-box.
    end.
    else do:
      vExcelApp:Workbooks:Open(vFile).
      vExcelApp:Visible = TRUE.
      release object vExcelApp.
    end.
  end.
  else
    message "Неизвестная ошибка при выгрузке." view-as alert-box.
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
    IF AVAILABLE X_thbj-attr THEN do:
     RUN proc-upd-lkp IN THIS-PROCEDURE ( INPUT 'ПРОСМОТР':U
                                         ,INPUT X_thbj-attr.upper-prop-code
                                         ,INPUT X_thbj-attr.obj-type
                                         ,INPUT X_thbj-attr.obj-code) NO-ERROR.
  END.
  else do:
     message
     "В БД секция параметров отсутствует!"
     view-as alert-box .
  end.
END.
ON VALUE-CHANGED OF BR-section IN FRAME Dialog-Frame
DO:
  IF AVAILABLE sectioN_thbj-attr THEN DO:
    RUN  Openbrtree IN THIS-PROCEDURE ( INPUT SECTION_thbj-attr.upper-prop-code).
  END.
  ELSE DO:
    RUN  Openbrtree IN THIS-PROCEDURE ( INPUT '').
  END.
END.
ON VALUE-CHANGED OF br-tree IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_thbj-attr THEN DO:
   RUN OpenBrValues IN THIS-PROCEDURE (
                                        INPUT X_thbj-attr.upper-prop-code
                                         ,INPUT X_thbj-attr.obj-type
                                         ,INPUT X_thbj-attr.obj-code) NO-ERROR.
  END.
  ELSE DO:
      RUN OpenBrValues IN THIS-PROCEDURE (
                                           INPUT ''
                                           ,INPUT ?
                                           ,INPUT ?) no-error.
  END.
END.
ON VALUE-CHANGED OF BR-values IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_thbj-attr_v
  AND X_thbj-attr_v.prop-value-type = 'void':U THEN DO:
   ASSIGN
   br-values:HEIGHT = 6.87.
   BR-values:SCROLL-TO-CURRENT-ROW().
   br-values:REFRESH().
   RUN OpenBr2Values IN THIS-PROCEDURE (
                                        INPUT X_thbj-attr_v.prop-code
                                         ,INPUT X_thbj-attr_v.obj-type
                                         ,INPUT X_thbj-attr_v.obj-code) NO-ERROR.
      br-2values:VISIBLE = TRUE.
      br-2values:REFRESH().
      br-2values:move-to-top().
  END.
  ELSE DO:
         ASSIGN
         br-values:HEIGHT-CHARS = FRAME Dialog-Frame:HEIGHT-CHARS - 15.
         br-values:move-to-top().
         br-2values:VISIBLE = FALSE.
         RUN OpenBr2Values IN THIS-PROCEDURE (
                                           INPUT ''
                                           ,INPUT ?
                                           ,INPUT ?) no-error.
  END.
END.
ON MOUSE-SELECT-CLICK OF I-tooltip IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-tooltip AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-tooltip-code AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE X_thbj-attr_v THEN DO:
    BELL.
  END.
  ELSE DO:
run thbjattr_tooltip in this-procedure (
             input   X_thbj-attr_v.upper-prop-code
            ,input  X_thbj-attr_v.prop-code
            ,output v-tooltip
            ,output v-label
            ,output v-tooltip-code
            ) no-error .
   MESSAGE
   v-tooltip SKIP
   v-tooltip-code
   VIEW-AS ALERT-BOX.
  END.
END.
ON CHOOSE OF MENU-ITEM m_db
DO:
  ASSIGN
  add-region = 'БД':U.
  APPLY "CHOOSE" to b-add  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_firm
DO:
  ASSIGN
  add-region = 'орг':U.
  APPLY "CHOOSE" to b-add  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_shop
DO:
  ASSIGN
  add-region = 'маг':U.
  APPLY "CHOOSE" to b-add  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_stock
DO:
  ASSIGN
  add-region = 'скл':U.
  APPLY "CHOOSE" to b-add  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_region
DO:
  ASSIGN
  add-region = 'регион':U.
  APPLY "CHOOSE" to b-add  in frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-values :handle
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
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BR-2values :handle
  ) .
run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse BR-2values :handle
  ) .
run diasize_init in this-procedure .
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
  RUN fill-section IN THIS-PROCEDURE.
  RUN MYENABLE IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-quit B-exp B-Help I-tooltip BR-section b-copy B-add B-chg B-del
         B-lkp B-1 b-hist1 br-tree BR-values BR-2values b-load
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-section FOR EACH section_thbj-attr NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE fill-section :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-label as character no-undo .
define variable v-user-can-edit as logical no-undo .
define variable v-output-display as logical no-undo .
define variable v-other as char no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-global as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
DEFINE BUFFER buf_section FOR SECTION_thbj-attr.
FOR EACH buf_SECTION:
  DELETE buf_SECTION.
END.
DO v-ii = 1 TO NUM-ENTRIES('autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-maria,cd-type-autotank,arh-global,nakl-glob,nakl_par,contr-in,rt-trn-doc,overval,inv-global,inv-obj,rezerv-global,rezerv-obj,ord-global,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,prt-firm,prt-obj,report-glob,report-firm,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U):
   RUN thbjattr_code_reg IN THIS-PROCEDURE (
                                         input ENTRY(v-ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-maria,cd-type-autotank,arh-global,nakl-glob,nakl_par,contr-in,rt-trn-doc,overval,inv-global,inv-obj,rezerv-global,rezerv-obj,ord-global,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,prt-firm,prt-obj,report-glob,report-firm,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U)
                                        ,input ''
                                        ,OUTPUT v-label
                                        ,OUTPUT v-user-can-edit
                                        ,OUTPUT v-output-display
                                        ,OUTPUT v-other
                                        ,OUTPUT v-prop-list
                                        ,OUTPUT v-prop-type-list
                                        ,OUTPUT v-prop-label-list
                                        ,OUTPUT v-global
                                        ,OUTPUT v-host
                                        ,OUTPUT v-shop
                                        ,OUTPUT v-store
                                        ,OUTPUT v-db
                                        ,OUTPUT v-region
                                        ) NO-ERROR.
  IF v-user-can-edit
  and index(v-other, "spr-ext=") > 0 THEN DO:
      CREATE buf_SECTION.
      ASSIGN
      buf_SECTION.upper-prop-code = ENTRY(v-ii, 'autosale,get-chk,chk-view,cd-sending,cd-inf-send,scale-inf,cd-type-ibm,cd-type-ipc-servispl,cd-type-NCR-GM,cd-type-NCR-AS-R,cd-type-magia-xml,cd-type-omron,cd-type-omron-new,cd-type-IBM-XML,cd-type-IBS-TH,cd-type-IBS-TH-MOB,alias-tpsi,cd-type-r-keeper,cd-type-maria,cd-type-autotank,arh-global,nakl-glob,nakl_par,contr-in,rt-trn-doc,overval,inv-global,inv-obj,rezerv-global,rezerv-obj,ord-global,ord-obj,abc-sale-day,Ass-obj,fin-global,fin-plan,,gds-ref,gds-ref_obj,dc-ref,cli-all,cashpays,wthdoc,wthdoc_obj,attr-wthrep,rum,rum_obj,easyfuel,images,prt-glob,prt-firm,prt-obj,report-glob,report-firm,report-obj,code-range,bge-export,auto-task,wnd-size,obj-date,fbrattr,petrol,staff,srv-auth-ASU,egais,mercur,gisMT,marking':U)
      buf_SECTION.upper-prop-name = v-label
      buf_SECTION.GLOBAL_ = v-global
      buf_SECTION.host_ = v-host
      buf_SECTION.shop_ = v-shop
      buf_SECTION.store_ = v-store
      buf_SECTION.db_ = v-db
      buf_SECTION.region_ = v-region
      .
  END.
END.
END PROCEDURE.
PROCEDURE init-tt :
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-host-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-region-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-db-attr-type AS CHARACTER NO-UNDO.
define buffer buf_thbj-attr for ub.thbj-attr .
empty TEMP-TABLE  x_thbj-attr .
for each buf_thbj-attr no-lock where
         buf_thbj-attr.upper-prop-code = p-upper-prop-code
     AND (buf_thbj-attr.prop-code       = ''
          OR buf_thbj-attr.prop-value-type = 'void':U)
    :
  find first x_thbj-attr where
              x_thbj-attr.obj-type = buf_thbj-attr.obj-type and
              x_thbj-attr.obj-code = buf_thbj-attr.obj-code no-error .
  if not available x_thbj-attr then do:
    create  x_thbj-attr.
    BUFFER-COPY buf_thbj-attr TO X_thbj-attr.
  end.
  if buf_thbj-attr.obj-type  = "" THEN DO:
    assign
    x_thbj-attr.ind1 =  "0" + string( 0,"999999999") + "   " + string( 0 ,"999999999" )
    .
  END.
  else if buf_thbj-attr.obj-type  = 'орг':U THEN DO:
    assign
    x_thbj-attr.ind1 =  "0" + string(buf_thbj-attr.obj-code,"999999999") + "   " + string( 0 ,"999999999" )
    .
  END.
  else if buf_thbj-attr.obj-type  = 'регион':U THEN DO:
    assign
    x_thbj-attr.ind1 =  "0" + string(buf_thbj-attr.obj-code,"999999999") + "   " + string( 0 ,"999999999" )
    .
  END.
  ELSE IF buf_thbj-attr.obj-type = 'БД':U THEN DO:
      run db-attr-value in this-procedure (buf_thbj-attr.obj-code,
                                           "reg-code",
                                           output v-region-code,
                                           output v-db-attr-type) no-error.
      if v-region-code = ? then v-region-code = 0.
      x_thbj-attr.ind1 =  "0" + string(v-region-code,"999999999") + "region" + string(buf_thbj-attr.obj-code ,":999999999" ).
  END.
  else do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_thbj-attr.obj-type
  ,input  buf_thbj-attr.obj-code
  ,output v-host-code
  )  .
     x_thbj-attr.ind1 =  "0" + string(v-host-code,"999999999") + buf_thbj-attr.obj-type + string(buf_thbj-attr.obj-code ,"999999999" ).
   end.
END.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
assign
b-add:menu-mouse in frame Dialog-Frame  = 1
section_thbj-attr.upper-prop-name:RESIZABLE IN BROWSE br-section = YES
    .
DO v-ii = 1 TO BROWSE br-values:NUM-COLUMNS:
  ASSIGN
  BROWSE br-values:GET-BROWSE-COLUMN(v-ii):RESIZABLE = YES.
END.
b-hist1:load-image("cmp/b-hist.bmp":u) .
b-hist1:TOOLTIP = "&История" .
DO v-ii = 1 TO BROWSE br-2values:NUM-COLUMNS:
  ASSIGN
  BROWSE br-2values:GET-BROWSE-COLUMN(v-ii):RESIZABLE = YES.
END.
br-values:height IN FRAME Dialog-Frame = 12.85.
ENABLE
b-quit
B-Help
BR-section
B-copy WHEN LOOKUP("b-chg", bttns) > 0 AND g#db-num = 0 AND NOT TRANSACTION
B-chg WHEN LOOKUP("b-chg", bttns) > 0 AND g#db-num = 0 AND NOT TRANSACTION
B-del WHEN LOOKUP("b-chg", bttns) > 0 AND g#db-num = 0 AND NOT TRANSACTION
b-add WHEN LOOKUP("b-chg", bttns) > 0 AND g#db-num = 0 AND NOT TRANSACTION
b-exp WHEN g#db-num = 0
b-lkp
b-1
b-hist1
BR-values
br-2values
br-tree
i-tooltip
b-load
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
OPEN QUERY BR-section FOR EACH section_thbj-attr NO-LOCK INDEXED-REPOSITION.
APPLY "ENTRY" TO br-section.
APPLY "VALUE-CHANGED" TO br-section.
END PROCEDURE.
PROCEDURE Openbr2values :
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS integer NO-UNDO.
IF p-upper-prop-code = '' THEN DO:
    OPEN QUERY br-2values
    FOR EACH X_thbj-attr_2v NO-LOCK WHERE  FALSE INDEXED-REPOSITION.
END.
ELSE DO:
    OPEN QUERY br-2values
    FOR EACH X_thbj-attr_2v NO-LOCK WHERE
           X_thbj-attr_2v.upper-prop-code = p-upper-prop-code
        AND X_thbj-attr_2v.obj-type = p-obj-type
        AND X_thbj-attr_2v.obj-code = p-obj-code
        AND X_thbj-attr_2v.prop-code > ''
        INDEXED-REPOSITION.
END.
END PROCEDURE.
PROCEDURE OpenBrtree :
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
define variable v-label as character no-undo .
define variable v-user-can-edit as logical no-undo .
define variable v-output-display as logical no-undo .
define variable v-other as char no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-global as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
RUN thbjattr_code_reg IN THIS-PROCEDURE (
                                      input p-upper-prop-code
                                    ,input ''
                                    ,OUTPUT v-label
                                    ,OUTPUT v-user-can-edit
                                    ,OUTPUT v-output-display
                                    ,OUTPUT v-other
                                    ,OUTPUT v-prop-list
                                    ,OUTPUT v-prop-type-list
                                    ,OUTPUT v-prop-label-list
                                    ,OUTPUT v-global
                                    ,OUTPUT v-host
                                    ,OUTPUT v-shop
                                    ,OUTPUT v-store
                                    ,output v-db
                                    ,output v-region
                                    ) NO-ERROR.
assign
menu-item m_firm:sensitive in menu menu-b-add = v-host
menu-item m_shop:sensitive in menu menu-b-add = v-shop
menu-item m_stock:sensitive in menu menu-b-add = v-store
menu-item m_db:sensitive in menu menu-b-add = v-db
menu-item m_region:sensitive in menu menu-b-add = v-region
.
RUN init-tt IN THIS-PROCEDURE ( INPUT p-upper-prop-code) NO-ERROR.
OPEN QUERY br-tree
FOR EACH X_thbj-attr NO-LOCK
WHERE X_thbj-attr.upper-prop-code = p-upper-prop-code
    AND (X_thbj-attr.prop-code = '' OR X_thbj-attr.prop-value-type = 'void':U)
INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" TO br-tree IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBrValues :
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS integer NO-UNDO.
IF p-upper-prop-code = '' THEN DO:
    OPEN QUERY br-values
    FOR EACH X_thbj-attr_v NO-LOCK WHERE  FALSE INDEXED-REPOSITION.
END.
ELSE DO:
    OPEN QUERY br-values
    FOR EACH X_thbj-attr_v NO-LOCK WHERE
           X_thbj-attr_v.upper-prop-code = p-upper-prop-code
        AND X_thbj-attr_v.obj-type = p-obj-type
        AND X_thbj-attr_v.obj-code = p-obj-code
        AND X_thbj-attr_v.prop-code > ''
        INDEXED-REPOSITION.
END.
APPLY "VALUE-CHANGED" TO br-values IN FRAME Dialog-Frame.
CLOSE QUERY BR-values.
OPEN QUERY BR-values
FOR EACH X_thbj-attr_v NO-LOCK WHERE
       X_thbj-attr_v.upper-prop-code = p-upper-prop-code
    AND X_thbj-attr_v.obj-type = p-obj-type
    AND X_thbj-attr_v.obj-code = p-obj-code
    AND X_thbj-attr_v.prop-code > ''
    INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" TO br-values IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-add :
DEFINE INPUT PARAMETER p-region AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
define output parameter v-add-obj-type as character no-undo .
define output parameter v-add-obj-code as integer no-undo .
define variable v-recids as character no-undo .
define variable v-firm-code as integer no-undo .
define variable v-reg-code as integer no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_db      for ub.db.
define buffer buf_regions for ub.regions.
add-region = ''.
case p-region:
  when 'БД':U then do:
     run adm\dbs.w(  input parParentProc
                   , input "b-sel":U
                   , output v-recids
          ).
     if v-recids = '' then return.
     find first buf_db no-lock
                       where recid(buf_db) = integer(entry(1, v-recids)).
     if available buf_db then
     assign
        v-add-obj-type = 'БД':U
        v-add-obj-code = buf_db.db-num
     .
  end.
  when 'орг':U then do:
      run adm/sconfs.w (
            input parParentProc
          , input "b-sel":U
          , input no
          , input 0
          , output v-firm-code
          , input-output v-recids
      ) no-error.
    if v-recids = '' then return.
    find first buf_sysconf no-lock
                      where recid(buf_sysconf) = integer(entry(1, v-recids)).
    assign
    v-add-obj-type = 'орг':U
    v-add-obj-code = buf_sysconf.host-code
    .
  end.
  when 'маг':U then do:
    run ref/thobjs.w
        ( input parparentproc
        , input this-procedure:handle
        , input "b-sel"
        , input 'все':U
        , input 'маг':U
        , input ?
        , input ?
        , input-output v-recids ) no-error .
    if v-recids = '' then return.
    find first buf_clients no-lock
                      where recid(buf_clients) = integer(entry(1, v-recids)).
    assign
    v-add-obj-type = buf_clients.obj-type
    v-add-obj-code = buf_clients.obj-code
    .
  end.
  when 'скл':U then do:
    run ref/thobjs.w
        ( input parparentproc
        , input this-procedure:handle
        , input "b-sel"
        , input 'все':U
        , input 'скл':U
        , input ?
        , input ?
        , input-output v-recids ) no-error .
    if v-recids = '' then return.
    find first buf_clients no-lock
                      where recid(buf_clients) = integer(entry(1, v-recids)).
    assign
    v-add-obj-type = buf_clients.obj-type
    v-add-obj-code = buf_clients.obj-code
    .
  end.
  when 'регион':U then do:
     run ref/regions.w ( input  parparentproc
                        , input  'выбор':U
                        , output v-reg-code
                        ).
     if v-reg-code = ? then return.
     find first buf_regions no-lock
          where buf_regions.reg-code = v-reg-code
     no-error .
     if available buf_regions then
     assign
        v-add-obj-type = 'регион':U
        v-add-obj-code = buf_regions.reg-code
     .
  end.
end case.
run proc-upd-lkp in this-procedure (
                                     input 'ИЗМЕНЕНИЕ':U
                                    ,input p-upper-prop-code
                                    ,input v-add-obj-type
                                    ,input v-add-obj-code ) no-error.
END PROCEDURE.
PROCEDURE proc-b-copy :
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS INTEGER NO-UNDO.
define variable v-rid-list as character no-undo .
define variable v-firm-code  as integer no-undo .
define variable v-from-obj-code  as integer no-undo .
define variable v-found  as decimal no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_db for ub.db.
message
substitute("CКОПИРОВАТЬ ПАРАМЕТРЫ МОЖНО ТОЛЬКО С ОБЪЕКТА ТОГО ЖЕ ТИПА!!!&1&1&1" +
           "Выберите объект, С КОТОРОГО ХОТИТЕ СКОПИРОВАТЬ ПАРАМЕТРЫ В ТЕКУЩИЙ ОБЪЕКТ (&2&3)&1" +
           "Секция:&1&4"
           , chr(10)
           , p-obj-type
           , p-obj-code
           , section_thbj-attr.upper-prop-name
           )
view-as alert-box.
CASE p-obj-type:
  WHEN 'орг':U THEN DO:
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
  END.
  WHEN 'маг':U THEN DO:
    message
    "Выберите МАГАЗИН для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
    run adm/shops.w ( input parparentproc
                      ,input "b-sel"
                      ,input-output v-rid-list
                      ,no ).
    if v-rid-list = "":U then return.
    find first buf_shop no-lock where
            recid(buf_shop) = integer(v-rid-list) .
    v-from-obj-code = buf_shop.obj-code.
  END.
  WHEN 'скл':U THEN DO:
    message
    "Выберите СКЛАД для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
    run adm/stores.w ( input parparentproc
                      ,input "b-sel"
                      ,input-output v-rid-list
                      ,input no ).
    if v-rid-list = "":U then return.
    find first buf_store no-lock where
            recid(buf_store) = integer(v-rid-list) .
    v-from-obj-code = buf_store.obj-code.
  END.
  when 'БД':U then do:
    message
    "Выберите БД для копирования ПАРАМЕТРОВ"
    view-as alert-box WARNING.
    run adm/dbs.w ( input parparentproc
                      ,input "b-sel"
                      ,output v-rid-list
                       ).
    if v-rid-list = "":U then return.
    find first buf_db no-lock where
            recid(buf_db) = integer(v-rid-list) .
    v-from-obj-code = buf_db.db-num.
  end.
END CASE.
run waitfram-show in this-procedure ( input "Ждите..." ).
FOR each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run thbjattr_get-section  in this-procedure (
   input  p-obj-type
  ,input  v-from-obj-code
  ,input p-upper-prop-code
  ,input '':U
  ,input-output table thbjattr_thbj-attr
  ,output v-found
                                      ) no-error .
  if not error-status:error then do:
    run thbjattr_set-section in this-procedure (
                                           input p-obj-type
                                          ,input p-obj-code
                                          ,input p-upper-prop-code
                                          ,input table thbjattr_thbj-attr ) no-error .
    IF ERROR-STATUS:ERROR THEN DO:
      run waitfram-hide in this-procedure .
      MESSAGE
      SUBSTITUTE("Ошибка при записи параметров с объекта-источника:&1&2&1&3"
                  , chr(10)
                  ,  ERROR-STATUS:get-message(1)
                  , RETURN-VALUE)
      VIEW-AS ALERT-BOX ERROR.
      undo, RETURN ERROR.
   END.
  end.
  ELSE DO:
     run waitfram-hide in this-procedure .
     MESSAGE
     SUBSTITUTE("Ошибка при чтении параметров с объекта-источника:&1&2&1&3"
                , chr(10)
                ,  ERROR-STATUS:get-message(1)
                , RETURN-VALUE)
     VIEW-AS ALERT-BOX ERROR.
     undo, RETURN ERROR.
  END.
run waitfram-hide in this-procedure .
message
substitute("Скопирована секция&6&1&6 с &4&5 на &2&3"
            , section_thbj-attr.upper-prop-name
            , p-obj-type
            , p-obj-code
            , p-obj-type
            , v-from-obj-code
            , chr(10)
            )
view-as alert-box .
END PROCEDURE.
PROCEDURE proc-upd-lkp :
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-upper-prop-code AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS CHARACTER NO-UNDO.
define variable v-label as character no-undo .
define variable v-user-can-edit as logical no-undo .
define variable v-output-display as logical no-undo .
define variable v-other as char no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-spr as character no-undo .
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
  run thbjattr_code_reg  in this-procedure (
       input p-upper-prop-code
      ,input   '':U
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
      ,output v-region
  ).
  do ii = 1 to num-entries(v-other, chr(47)):
    if entry(ii, v-other, chr(47)) begins "spr-ext=":U then do:
      assign
      v-spr = entry(2, entry(ii, v-other, chr(47)), "=").
    end.
  end.
  run value(v-spr) (
                   input parparentproc
                  ,input p-mode
                  ,input p-obj-type
                  ,input p-obj-code
                  ) NO-ERROR.
END PROCEDURE.
FUNCTION get-thbjattr-l-and-v RETURNS CHARACTER
  ( BUFFER buf_thbj-attr FOR ub.thbj-attr
   ,OUTPUT p-value AS CHARACTER
    ) :
define variable v-label as character no-undo .
define variable v-user-can-edit as logical no-undo .
define variable v-output-display as logical no-undo .
define variable v-other as char no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-global as logical no-undo .
define variable v-db as logical no-undo .
define variable v-region as logical no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
RUN thbjattr_code_reg IN THIS-PROCEDURE (
                                    input buf_thbj-attr.upper-prop-code
                                   ,input buf_thbj-attr.prop-code
                                   ,OUTPUT v-label
                                   ,OUTPUT v-user-can-edit
                                   ,OUTPUT v-output-display
                                   ,OUTPUT v-other
                                   ,OUTPUT v-prop-list
                                   ,OUTPUT v-prop-type-list
                                   ,OUTPUT v-prop-label-list
                                   ,OUTPUT v-global
                                   ,OUTPUT v-host
                                   ,OUTPUT v-shop
                                   ,OUTPUT v-store
                                   ,output v-db
                                   ,OUTPUT v-region
                                          ) NO-ERROR.
IF lookup(buf_thbj-attr.prop-code,v-prop-list) > 0 THEN DO:
case entry(lookup(buf_thbj-attr.prop-code,v-prop-list) , v-prop-type-list):
  when 'character':U then do:
    p-value = buf_thbj-attr.property-value-character.
  end.
  when 'date':U then do:
    p-value = string(buf_thbj-attr.property-value-date, "99/99/9999").
  end.
  when 'decimal':U then do:
    p-value = string(buf_thbj-attr.property-value-decimal).
  end.
  when 'integer':U then do:
    p-value = string(buf_thbj-attr.property-value-integer).
  end.
  when 'logical':U then do:
    p-value =  string(buf_thbj-attr.property-value-logical).
  end.
   when 'void':U then do:
    p-value =  "...".
  end.
  OTHERWISE DO:
    p-value = "!!!ОШИБКА-НЕИЗВЕСТНЫЙ ТИП ЗНАЧЕНИЯ".
  END.
  END CASE.
  if buf_thbj-attr.upper-prop-code = "gisMT" and
    (buf_thbj-attr.prop-code = "proxyPswd" or
     buf_thbj-attr.prop-code = "OflinePswd" or
     buf_thbj-attr.prop-code = "MaxApiToken") and
     p-value > ""
  then p-value = fill("*",length(p-value)).
  RETURN entry(lookup(buf_thbj-attr.prop-code,v-prop-list),  v-prop-label-list).
END.
ELSE DO:
    p-value = "!!!ОШИБКА-НЕИЗВЕСТНЫЙ ПАРАМЕТР".
    RETURN buf_thbj-attr.prop-code.
END.
END FUNCTION.
