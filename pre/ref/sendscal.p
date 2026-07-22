block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable rec-t-scales as recid no-undo .
define variable SendOption as Character NO-UNDO.
define variable send-rid-list as character no-undo .
define variable ObjectOption as CHaracter NO-UNDO.
DEFINE variable qnty-buf as integer NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendscal.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/sendscal.p $":U .
define variable vss-description as character no-undo init "Передача измененных товаров на все весы".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
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
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
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
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gdsolist no-undo like ub.goods
field qnty   as decimal
field to-del as logical
field order-num as integer
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index art  is primary unique artic prod-type prod-code obj-type obj-code
index code is         unique gds-code obj-type obj-code
index oi order-num
index iobj obj-type obj-code gds-code
.
define variable out-dir         as character no-undo.
define variable digi-out-dir   as character no-undo .
define variable tiger-out-dir   as character no-undo .
define variable tiger-spct2-out-dir   as character no-undo .
define variable tiger-spct1-out-dir   as character no-undo .
define variable tiger-spct2-install-dir  as character no-undo .
define variable tiger-spct1-install-dir  as character no-undo .
define variable scale-prog  as character no-undo.
define variable conf-attr as character no-undo.
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
define variable ini-types as character no-undo.
define variable ini-progs as character no-undo.
define variable rnd-znak as integer no-undo init 2.
define variable obj-list as logical no-undo.
define buffer b-scales for ub.scales .
define variable goods-lst as character no-undo .
define variable jj as integer no-undo .
define variable gds-amount as integer no-undo .
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type as character no-undo.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure scl-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'tare-weight':U then do:     assign     p-label = "Веса и коды тары"     p-type = 'C':U      p-format = "X(32)"     p-label = "Веса и коды тары"     p-user-can-edit  = yes     p-output-display = true     p-other = 'scl=TIGER,MIRA,TIGER2,TIGER-SPCT2/spr=scl-attr-tare-weight':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут весов" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure scl-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'tare-weight':U then do:     assign     p-tooltip = "Веса и коды тары"     p-label = "Веса и коды тары" .   end.
      otherwise do:
        undo, return error "неизвестный атрибут весов" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure scl-attr-value :
  do
  on error undo, return error
  :
    define input  parameter p-db-num   like ub.scales-attr.db-num        no-undo .
    define input  parameter p-scales-num like ub.scales-attr.scales-num      no-undo .
    define input  parameter p-code     like ub.scales-attr.attr-code      no-undo .
    define output parameter p-value    like ub.scales-attr.attr-value    no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_scales-attr for ub.scales-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run scl-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_scales-attr no-lock
      where buf_scales-attr.db-num    = p-db-num
        and buf_scales-attr.scales-num  = p-scales-num
        and buf_scales-attr.attr-code = p-code
      no-error .
    if avail buf_scales-attr then do:
      assign
        p-value =  buf_scales-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure scl-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.scales-attr.db-num     no-undo .
    define input parameter p-scales-num like ub.scales-attr.scales-num   no-undo .
    define input parameter p-code     like ub.scales-attr.attr-code  no-undo .
    define input parameter p-value    like ub.scales-attr.attr-value no-undo .
    define buffer buf_scales-attr for ub.scales-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run scl-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_scales-attr exclusive-lock
      where buf_scales-attr.db-num  = p-db-num
        and buf_scales-attr.scales-num  = p-scales-num
        and buf_scales-attr.attr-code = p-code
      no-error .
    if not available buf_scales-attr then do:
      create buf_scales-attr .
      assign
        buf_scales-attr.db-num    = p-db-num
        buf_scales-attr.scales-num  = p-scales-num
        buf_scales-attr.attr-code = p-code
      .
    end.
    assign
      buf_scales-attr.attr-value = p-value
    .
    release buf_scales-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure scl-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.scales-attr.db-num     no-undo .
    define input parameter p-scales-num like ub.scales-attr.scales-num   no-undo .
    define input parameter p-code     like ub.scales-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_scales-attr for ub.scales-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run scl-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_scales-attr exclusive-lock
      where buf_scales-attr.db-num  = p-db-num
        and buf_scales-attr.scales-num  = p-scales-num
        and buf_scales-attr.attr-code = p-code
      no-error .
    if  available buf_scales-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure scl-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.scales-attr.db-num     no-undo .
    define input parameter p-scales-num like ub.scales-attr.scales-num   no-undo .
    define input parameter p-code     like ub.scales-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_scales-attr for ub.scales-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run scl-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_scales-attr exclusive-lock
      where buf_scales-attr.db-num  = p-db-num
        and buf_scales-attr.scales-num  = p-scales-num
        and buf_scales-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_scales-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_scales-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure scl-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'tare-weight':U then do:     assign     p-news = yes.   end.
      otherwise do:
        p-news = no.
      end.
    end.
  end.
end procedure.
procedure scl-attr-hist :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-hist           as logical   no-undo .
    case p-code :
            when 'tare-weight':U then do:     assign     p-hist = yes.   end.
      otherwise do:
        p-hist = no.
      end.
    end.
  end.
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable glog as logical no-undo .
define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable g#news                       as logical        no-undo .
define variable g#auto                       as logical        no-undo .
define buffer buf_scales for ub.scales.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION scl-gds-ld returns integer ( input p-raw-dead-line as integer, input p-sclin-ld as integer):
define variable v-dead-line as integer no-undo .
define variable v-dead-line-date as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
if p-sclin-ld > 0 then do:
  run cur-time in this-procedure ( output v-today, output v-time).
  assign
  v-dead-line = p-raw-dead-line / 24  + 01/01/2000 - v-today
  v-dead-line = if v-dead-line < 0 then 0 else v-dead-line
  .
end.
else v-dead-line = p-raw-dead-line.
return v-dead-line .
end.
FUNCTION scl-gds-ld2 returns integer ( input p-deadline as integer
                                     , input p-deaddate as date
                                     , input p-deadflag as integer):
define variable v-dead-line as integer no-undo .
define variable v-dead-line-date as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
if p-deadflag > 0 then do:
  if p-deaddate = ? then return 0.
  run cur-time in this-procedure ( output v-today, output v-time).
  assign
  v-dead-line = p-deaddate - v-today + 1
  v-dead-line = if v-dead-line < 0 then 0 else v-dead-line
  .
end.
else v-dead-line = (if p-deadline = ? then 0 else p-deadline).
return v-dead-line .
end.
FUNCTION scl-gds-ld-date returns date ( input p-raw-dead-line as integer, input p-sclin-ld as integer):
define variable v-dead-line-date as date no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).
if p-sclin-ld > 0 then do:
  if p-raw-dead-line > 0 then do:
    assign
    v-dead-line-date = p-raw-dead-line / 24  + 01/01/2000 - 1
    .
  end.
  else  do:
    assign
    v-dead-line-date = ?
    .
  end.
end.
else do:
  if p-raw-dead-line > 0 then do:
    assign
    v-dead-line-date = p-raw-dead-line  + v-today - 1
    .
  end.
  else do:
    assign
    v-dead-line-date = ?
    .
  end.
end.
return v-dead-line-date.
end.
FUNCTION scl-gds-ld-parts returns integer ( buffer buf_scales-gds for ub.scales-gds, input sclin-ld as integer):
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_parts for ub.parts .
define buffer buf_goods for ub.goods.
define variable v-last-date as date no-undo.
find first buf_bar-code no-lock where
          buf_bar-code.b-code = buf_scales-gds.b-code no-error.
if not available buf_bar-code then return ?.
if sclin-ld > 0 then do:
  find first buf_gds-obj no-lock where
            buf_gds-obj.gds-code = buf_bar-code.gds-code
      and  buf_gds-obj.obj-type = buf_scales-gds.obj-type
      and  buf_gds-obj.obj-code = buf_scales-gds.obj-code no-error .
  if not available buf_gds-obj then return ?.
  _parts:
  for each buf_parts no-lock where
          buf_parts.obj-type  = buf_gds-obj.obj-type
      and buf_parts.obj-code  = buf_gds-obj.obj-code
      and buf_parts.artic     = buf_gds-obj.artic
      and buf_parts.prod-type = buf_gds-obj.prod-type
      and buf_parts.prod-code = buf_gds-obj.prod-code
      and buf_parts.out-code  = buf_gds-obj.in-code:
    if buf_parts.last-date = ? then next _parts.
    assign
    v-last-date = (if v-last-date = ?
                  or (v-last-date <> ?
                      and sclin-ld = 1
                      and v-last-date > buf_parts.last-date)
                  or (v-last-date <> ?
                      and sclin-ld = 2
                      and v-last-date < buf_parts.last-date)
                  then buf_parts.last-date
                  else v-last-date)
    .
  end.
  if v-last-date <> ? then do:
    return (v-last-date - 01/01/2000 + 1) * 24.
  end.
  else do:
    return 0.
  end.
end.
else do:
  find first buf_goods no-lock where
            buf_goods.gds-code = buf_bar-code.gds-code no-error.
  if available buf_goods then do:
    return buf_goods.deadline.
  end.
  else return 0.
end.
END FUNCTION.
FUNCTION scl-gds-ld-parts-date returns date ( buffer buf_scales-gds for ub.scales-gds, input sclin-ld as integer):
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_parts for ub.parts .
define buffer buf_goods for ub.goods.
define variable v-last-date as date no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
find first buf_bar-code no-lock where
          buf_bar-code.b-code = buf_scales-gds.b-code no-error.
if not available buf_bar-code then return ?.
if sclin-ld > 0 then do:
  find first buf_gds-obj no-lock where
            buf_gds-obj.gds-code = buf_bar-code.gds-code
      and  buf_gds-obj.obj-type = buf_scales-gds.obj-type
      and  buf_gds-obj.obj-code = buf_scales-gds.obj-code no-error .
  if not available buf_gds-obj then return ?.
  _parts:
  for each buf_parts no-lock where
          buf_parts.obj-type  = buf_gds-obj.obj-type
      and buf_parts.obj-code  = buf_gds-obj.obj-code
      and buf_parts.artic     = buf_gds-obj.artic
      and buf_parts.prod-type = buf_gds-obj.prod-type
      and buf_parts.prod-code = buf_gds-obj.prod-code
      and buf_parts.out-code  = buf_gds-obj.in-code:
    if buf_parts.last-date = ? then next _parts.
    assign
    v-last-date = (if v-last-date = ?
                  or (v-last-date <> ?
                      and sclin-ld = 1
                      and v-last-date > buf_parts.last-date)
                  or (v-last-date <> ?
                      and sclin-ld = 2
                      and v-last-date < buf_parts.last-date)
                  then buf_parts.last-date
                  else v-last-date)
    .
  end.
  if v-last-date <> ? then do:
    return v-last-date.
  end.
  else do:
    run cur-time in this-procedure ( output v-today, output v-time).
    return v-today.
  end.
end.
else do:
  run cur-time in this-procedure ( output v-today, output v-time).
  find first buf_goods no-lock where
            buf_goods.gds-code = buf_bar-code.gds-code no-error.
  if available buf_goods then do:
    return (v-today + buf_goods.deadline).
  end.
  else return v-today.
end.
END FUNCTION.
FUNCTION scl-gds-ld-to-raw returns integer ( input p-dead-line as integer, input p-sclin-ld as integer):
define variable v-dead-line as integer no-undo .
define variable v-dead-line-date as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).
if p-sclin-ld > 0 then do:
  run cur-time in this-procedure ( output v-today, output v-time).
  if p-dead-line = 0 then do:
    assign
    v-dead-line = 0
    .
  end.
  else do:
    assign
    v-dead-line = (v-today + p-dead-line - 01/01/2000) * 24
    .
  end.
end.
else v-dead-line = p-dead-line.
return v-dead-line.
end.
FUNCTION scl-gds-ld-to-date returns date ( input p-dead-line as integer):
define variable v-dead-line as integer no-undo .
define variable v-dead-line-date as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
run cur-time in this-procedure ( output v-today, output v-time).
return (v-today  + p-dead-line - 1).
end.
FUNCTION scl-gds-deadvalue returns character ( input p-deadline as integer
                                              ,input p-deaddate as date
                                              ,input p-deadflag as integer):
if p-deadflag = integer('0':U) then return string((if p-deadline = ? then 0 else p-deadline)).
else return string(p-deaddate, "99/99/9999").
end function.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function prepare-path returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, chr(92), chr(47))
v-prepared-path = right-trim(v-prepared-path, chr(47))
.
return v-prepared-path.
END FUNCTION.
function prepare-path2 returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, chr(47), chr(92))
v-prepared-path = right-trim(v-prepared-path, chr(92))
.
return v-prepared-path.
END FUNCTION.
function quote-spaces returns character ( input p-full-path as character):
define variable v-ii as integer no-undo .
define variable v-result as character no-undo .
do v-ii = 1 to num-entries(p-full-path, chr(92)):
  v-result = v-result + (if v-ii = 1 then '' else chr(92)) +
             (if index(entry(v-ii, p-full-path, chr(92)), chr(32)) > 0
             then  substitute("&1&2&1", chr(34), entry(v-ii, p-full-path, chr(92)))
             else entry(v-ii, p-full-path, chr(92))
             )
  .
end.
return v-result.
end function.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE SetCurrentDirectoryA EXTERNAL "KERNEL32.DLL":
    DEFINE INPUT PARAMETER chrCurDir AS CHARACTER.
    DEFINE RETURN PARAMETER SetCurrentDirectoryAResult AS LONG.
END PROCEDURE.
FUNCTION get-tara-string RETURNS CHARACTER (buffer loc-scales for ub.scales):
DEFINE VARIABLE var-tara-string as character no-undo .
DEFINE VARIABLE var-param-code as character no-undo .
DEFINE VARIABLE v-value as character no-undo .
DEFINE VARIABLE par-type as character no-undo .
  CASE loc-scales.scales-type:
    when "TIGER":U
    or
    when "MIRA":U
    or
    when "TIGER2"
    or
    when "TIGER-SPCT2"
    or
    when "TIGER-SPCT1"
    then do:
      run scl-attr-value  in this-procedure (
                                              input  loc-scales.db-num
                                              ,input  loc-scales.scales-num
                                              ,input  'tare-weight':U
                                              ,output v-value
                                              ,output par-type) no-error .
      IF not error-status:error then
      assign
      var-tara-string = v-value
      .
    end.
    otherwise do:
      assign
      var-tara-string = "":U
      .
    end.
  END CASE.
return var-tara-string.
END FUNCTION.
FUNCTION get-wt-cart RETURNS CHARACTER (input p-scales-type as character
                                      , INPUT par-wt-cart as decimal
                                      , INPUT par-db-num as integer
                                      , INPUT par-scales-num as integer
                                      , INPUT par-tara-string as character
                                      , INPUT p-dec-delim as character
                                      ):
DEFINE VARIABLE var-wt-cart-str as character no-undo .
DEFINE VARIABLE var-entry as character no-undo .
DEFINE VARIABLE var-dop-dec as decimal no-undo .
DEFINE VARIABLE ii as integer no-undo .
  CASE par-tara-string:
    when "":U then do:
      case p-scales-type:
        when "TIGER-SPCT2"
        or
        when "TIGER-SPCT1"
        then do:
          return '00':U.
        end.
        when "SHTRIH-M" then do:
          assign
          var-wt-cart-str = string(par-wt-cart , "->>>>9.999")
          .
          if p-dec-delim = chr(44) then do:
            var-wt-cart-str = replace(var-wt-cart-str, ".", chr(44)).
          end.
        end.
        when "CAS_LP-15v1.6" then do:
            if replace(ENTRY(LOOKUP("CAS_LP-15v1.6", ini-types), ini-progs), "\", "/") = "exe/CAScentre.exe" then
                assign
                var-wt-cart-str = trim(string(par-wt-cart)).
            else
                assign
                var-wt-cart-str = string(par-wt-cart * 1000, "->>,>>9.999").
        end.
        otherwise do:
          assign
          var-wt-cart-str = string(par-wt-cart * 1000, "->>,>>9.999")
          .
        end.
      end case.
    end.
    otherwise do:
      CASE p-scales-type:
        when "TIGER-SPCT2"
        or
        when "TIGER-SPCT1"
        then do:
          assign
          var-wt-cart-str = string(0, "99")
          .
        end.
        otherwise do:
          assign
          var-wt-cart-str = string(0)
          .
        end.
      end case.
      _ii:
      do ii = 1 to num-entries(par-tara-string, ";":U):
        assign
        var-entry = trim(entry(ii, par-tara-string, ";":U))
        var-dop-dec = decimal(trim(entry(2, var-entry, "=":U)))
        no-error
        .
        if error-status:error then do:
          message
          substitute("Неверное значение атрибута весов <ВЕСА и КОДЫ ТАРЫ>&1" +
                     "для весов &2"
                     ,chr(10)
                     ,par-scales-num)
          view-as alert-box error .
          NEXT _ii.
        end.
        if var-dop-dec = par-wt-cart then do:
          assign
          var-wt-cart-str = trim(entry(1, var-entry, "=":U))
          .
          LEAVE _ii.
        end.
      end.
    end.
  END CASE.
return var-wt-cart-str.
END FUNCTION.
FUNCTION get-struct returns character (  input p-gds-code as integer
                                        ,input p-plu as integer
                                        ,input p-struct as character
                                        ,input p-scales-type as character
                                        ,input p-db-num as integer
                                        ,input p-scales-num as integer
                                        ):
define variable ii as integer no-undo .
define variable v-rows as integer no-undo .
define variable v-struct as character no-undo .
define variable v-entry as character no-undo .
define variable v-rows-num as integer no-undo .
define variable v-line-length as integer no-undo .
define variable v-format as character no-undo .
define variable v-attr-code as character no-undo .
define variable v-dop as character no-undo .
define variable v-struct1 as character no-undo .
CASE p-scales-type:
  when "CAS_lp-16x" then do:
    assign
    v-struct = " 0    0  "
    v-rows-num = 8
    v-format = "X(50)"
    v-line-length = 50
    v-attr-code = '8x50':U
    .
  end.
  when "CAS_LP-15v1.6_new" then do:
      assign
      v-rows-num = 8
      v-format = "X(50)"
      v-line-length = 50
      v-attr-code = '8x50':U
      .
  end.
  when "DIGI-SM" then do:
    assign
    v-rows-num = 15
    v-format = "X(80)"
    v-line-length = 80
    v-attr-code = '15x80':U
    .
  end.
  when "TIGER-SPCT2"
  or
  when "TIGER-SPCT1"
  then do:
    assign
    v-rows-num = 1
    v-format = "X(199)"
    v-line-length = 199
    v-attr-code = '':U
    .
  end.
  when "CAS_CL5000J"
  or when "CAS_CL5000"
  then do:
    assign
    v-struct = " 0    0  "
    v-rows-num = 6
    v-format = "X(50)"
    v-line-length = 50
    v-attr-code = '6x50':U
    .
  end.
  when "SHTRIH-M" then do:
    assign
    v-struct = "|"
    v-rows-num = 8
    v-format = "X(50)"
    v-line-length = 50
    v-attr-code = '8x50':U
    .
  end.
END CASE.
if v-attr-code <> '':U
and p-gds-code > 0
then do:
  run gds-attr-value in this-procedure (
   input  p-gds-code
  ,input  v-attr-code
  ,output v-struct1
  ,output v-dop
  ) no-error.
  if error-status:error
  or (p-struct <> '':U
  and v-struct1 = '') then do:
     p-struct = replace(p-struct, chr(10), chr(32)).
     do ii = 1 to min(v-rows-num, length(p-struct)  modulo v-line-length):
       assign
       v-struct1 = v-struct1 + (if ii = 1 then '':U else chr(4)) + substring(p-struct
                                                                        , (ii - 1) * v-line-length + 1
                                                                        , v-line-length)
                                                                        .
     end.
     p-struct = v-struct1.
  end.
  else do:
    p-struct = v-struct1.
  end.
end.
if num-entries(p-struct, chr(4)) > v-rows-num
then v-rows = v-rows-num.
else v-rows = num-entries(p-struct, chr(4)) .
CASE p-scales-type:
  when 'DIGI-SM':U then do:
    do ii = 1 to min(v-rows-num, num-entries(p-struct, chr(4))):
      assign
      v-entry = replace(entry(ii, p-struct, chr(4)), chr(34), chr(32) )
      v-entry = replace(v-entry, chr(39), chr(32) )
      .
      assign
      v-struct = v-struct +  (if ii = 1
                              then (chr(10)  + 'I':U + '000000':U + string(p-plu, '999999999':U))
                              else chr(3)) +
                 trim(string(v-entry, v-format))
      .
    end.
    if p-struct <> '':U then do:
      assign
      v-struct = v-struct + chr(3).
    end.
  end.
  when 'CAS_lp-16x':U
  or
  when 'CAS_CL5000J':U
  or
  when 'CAS_CL5000':U
  then do:
    do ii = 1 to min(v-rows-num, num-entries(p-struct, chr(4))):
      assign
      v-entry = replace(entry(ii, p-struct, chr(4)), chr(34), chr(32) )
      v-entry = replace(v-entry, chr(39), chr(32) )
      v-entry = replace(v-entry, chr(10), chr(32) )
      .
      assign
      v-struct = v-struct +  chr(32) +  chr(34) +  string(v-entry, v-format) + "" + chr(34)
      .
    end.
    if v-rows < v-rows-num then do:
      do ii = 1  to (v-rows-num - v-rows):
        assign
        v-struct = v-struct + chr(32) + chr(34) + fill( chr(32) , v-line-length) + chr(34)
        .
      end.
    end.
  end.
  when 'TIGER-SPCT2':U
  or
  when 'TIGER-SPCT1':U
  then do:
    if p-struct <> '':U  then do:
      assign
      v-struct =  chr(10) +
                      '00020900000001' + string(p-scales-num, "99") +
                      string(p-plu, '9999') +
                      string(replace(replace(p-struct, chr(4), chr(32)), chr(10), chr(32)), "X(200)")
                      .
    end.
  end.
  when 'SHTRIH-M':U
  then do:
    do ii = 1 to min(v-rows-num, num-entries(p-struct, chr(4))):
      assign
      v-entry = replace(entry(ii, p-struct, chr(4)), chr(34), chr(32) )
      v-entry = replace(v-entry, chr(39), chr(32) )
      v-entry = replace(v-entry, chr(10), chr(32) )
      .
      assign
      v-struct = v-struct + string(v-entry, v-format) + "'".
      .
    end.
  end.
  when "CAS_LP-15v1.6_new"
  then do:
    if replace(ENTRY(LOOKUP("CAS_LP-15v1.6", ini-types), ini-progs), "\", "/") = "exe/CAScentre.exe" then do:
        do ii = 1 to min(v-rows-num, num-entries(p-struct, chr(4))):
          assign
          v-entry = trim(entry(ii, p-struct, chr(4)))
          v-entry = replace(v-entry, ";", chr(32) )
          v-entry = replace(v-entry, chr(10), chr(32) )
          .
          assign
          v-struct = v-struct + (if v-entry <> "" then " " else "") + v-entry.
          .
        end.
    end.
  end.
  otherwise do:
  end.
END CASE.
return v-struct.
END FUNCTION.
FUNCTION main-record-string returns character ( buffer buf_goods for ub.goods
                                               ,input p-mode as character
                                               ,input p-scales-db-num as integer
                                               ,input p-scales-type as character
                                               ,input p-scales-num as integer
                                               ,input p-plu-code  as integer
                                               ,input p-plu-type as integer
                                               ,input p-b-str as character
                                               ,input p-price-sale as decimal
                                               ,input p-deadline as integer
                                               ,input p-deaddate as date
                                               ,input p-deadflag as integer
                                               ,input p-wt-cart as decimal
                                               ,input p-tara-string as character
                                               ,input p-dec-delim as character
                                               ):
define variable v-main-string as character no-undo .
define variable name-buf1 as character no-undo .
define variable name-buf2 as character no-undo .
define variable v-row-length as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-struct as character no-undo.
if p-scales-type = "CAS_LP-15v1.6"  and replace(ENTRY(LOOKUP("CAS_LP-15v1.6", ini-types), ini-progs), "\", "/") = "exe/CAScentre.exe" and p-mode = 'ИЗМЕНЕНИЕ':U then p-scales-type = "CAS_LP-15v1.6_new".
CASE p-scales-type:
  when 'DIGI-SM' then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      run create-name-str in this-procedure ( buffer buf_goods, output name-buf1) .
      assign
      v-main-string = 'A':U +
                      entry(1, (if p-plu-type = integer('0':U)
                                then substring(varscales-pref, 1, 2)
                                else substring(varpgscales-pref, 1, 2))) +
                      string(p-b-str, "x(5)") + '00000':U +
                      '000000':U + string(p-plu-code, '999999999':U) +
                      '0000':U +
                      '0000':U +
                      (if p-plu-type = integer('0':U)
                      then '0':U
                      else '1':U)  +
                      '0':U +
                        string(p-price-sale, '99999.99') +
                        string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), "999") +
                        '0000':U +
                        string(name-buf1, "X(80)").
    end.
    if p-mode = 'удаление':U
    or p-mode = "purge"
    or p-mode = "purge-all"
    then do:
      assign
      v-main-string = 'A':U +
                      entry(1, (if p-plu-type = integer('0':U)
                                then substring(varscales-pref, 1, 2)
                                else substring(varpgscales-pref, 1, 2))) +
                      string(p-b-str, "x(5)")  + '00000':U +
                      '000000':U + string(p-plu-code, '999999999':U) +
                      '0000':U +
                      '0000':U +
                      '0':U +
                      '0':U +
                      string(0.01, '99999.99') +
                      string(0, "999") +
                      '0000':U +
                      string('':U, "X(80)").
    end.
  end.
  when "TIGER-SPCT2":U
  or
  when "TIGER-SPCT1":U
  then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      if p-scales-type = "TIGER-SPCT2" then do:
        run create-name-str-2 in this-procedure ( buffer buf_goods, input 30, output name-buf1, output name-buf2) .
      end.
      else do:
        run create-name-str in this-procedure ( buffer buf_goods, output name-buf1) .
      end.
      assign
      v-main-string = '00020700000001' + string(p-scales-num, "99") +
                      string(p-plu-code, '999999':U) +
                      (if p-plu-type = integer('0':U)
                      then (
                      entry(1, varscales-pref) + '000000':U + string(p-b-str, "x(5)")
                      )
                      else (
                      substring(entry(1, varpgscales-pref), 1, 2) + '000000':U + string(p-b-str, "x(5)")
                      )
                      )
                      +
                      (if p-scales-type = "TIGER-SPCT2"
                      then
                      (string( name-buf1, "x(30)" ) +
                      string( name-buf2, "x(30)" ))
                      else
                      string( name-buf1, "x(28)" )
                      )
                      +
                      chr(32)  +
                      replace(string(p-price-sale, '999999.99'), ".", "") +
                      '0' +
                      replace(get-wt-cart(p-scales-type, p-wt-cart, p-scales-db-num, p-scales-num, p-tara-string, p-dec-delim), ".", "") +
                      '0000':U +
                      '00000000000':U +
                      '0000':U +
                      (if p-plu-type = integer('0':U)
                      then '0020':U
                      else '0021':U)  +
                      string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), "999") +
                      string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), "999") +
                      (if buf_goods.struct <> '':U
                      then string(p-plu-code, '999')
                      else '000':U)
                      .
    end.
    if p-mode = 'удаление':U then do:
      assign
      v-main-string = '00020700000001' + string(p-scales-num, "99") +
                      string(p-plu-code, '999999':U) +
                      '0000000000000':U  +
                      (if p-scales-type = "TIGER-SPCT2"
                      then
                      (
                      fill( chr(32) , 30) +
                      fill( chr(32) , 30))
                      else
                      fill( chr(32) , 28))
                      +
                      chr(32)  +
                      replace(string(0.0, '999999.99'), ".", "") +
                      '0' +
                      '00' +
                      '0000':U +
                      '00000000000':U +
                      '0000':U +
                      '0020':U +
                      "000" +
                      "000" +
                      "000"
                      .
    end.
    if p-mode = "purge" then do:
      assign
      v-main-string = "D:":U + string(p-plu-code, ">>>9").
    end.
    if p-mode = "purge-all" then do:
      assign
      v-main-string = "D:A":U
      .
    end.
  end.
  when "SHTRIH-M" then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      run create-name-str-2 in this-procedure ( buffer buf_goods, input 56, output name-buf1, output name-buf2) .
      name-buf1 = trim(name-buf1).
      assign
      v-main-string = string(1) + "|" +
                      string(p-pLU-code) + "|"  +
                      string(p-b-str, "x(5)") + "|" +
                      string(replace(name-buf1, "|", " "), "x(56)" ) + "|" +
                       "" + "|" +
                      get-wt-cart(p-scales-type, p-wt-cart, p-scales-db-num, p-scales-num, p-tara-string, p-dec-delim) + "|" +
                      string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), ">>>>9") + "|" +
                      (if p-dec-delim = chr(44)
                      then replace(string(p-price-sale, ">>>>>>>>9.99"), ".", chr(44))
                      else string(p-price-sale, ">>>>>>>>9.99"))
                      .
    end.
    if p-mode = 'удаление':U
    or p-mode = "purge"
    or p-mode = "purge-all"
    then do:
      assign
      v-main-string = (if p-mode = "purge-all" then string(2) else string(0)) + "|" +
                      string(p-pLU-code) + "|"  +
                      string(p-b-str, "x(5)") + "|" +
                      string(replace(name-buf1, "|", " "), "x(29)" ) + "|" +
                       "" + "|" +
                      get-wt-cart(p-scales-type, p-wt-cart, p-scales-db-num, p-scales-num, p-tara-string, p-dec-delim) + "|" +
                      string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), ">>>>9") + "|" +
                      (if p-dec-delim = chr(44)
                      then replace(string(p-price-sale, ">>>>>>>>9.99"), ".", chr(44))
                      else string(p-price-sale, ">>>>>>>>9.99"))
                      .
    end.
  end.
  when "DIGI_AW-4600_FX":U then do:
    run cur-time in this-procedure ( output v-today, output v-time).
    if not (p-mode = 'удаление':U
            or p-mode = "purge"
            or p-mode = "purge-all") then do:
      run create-name-str in this-procedure ( buffer buf_goods, output name-buf1) .
    end.
    assign
    v-main-string = substitute('&1&2&3,,1,&4,&5,&6&7000000,&8,'
                               , string(year(v-today), "9999")
                               , string(month(v-today), "99")
                               , string(day(v-today), "99")
                               , p-plu-code
                               , (if p-mode = 'удаление':U
                                  or p-mode = "purge"
                                  or p-mode = "purge-all"
                                  then 1
                                  else 0)
                               , 21
                               , string(p-b-str, "x(5)")
                               , 25
                               ) +
                  substitute('&1,"&2”,0,,0,,0,,0,,0,&3,,'
                             , 19
                             , name-buf1
                             , 0
                             )
                    +  substitute("&1,0,0,0,0,0,0,,0,0,0,0,1,,1,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,,,,0,0,0,,,,0,,,,0,,,,,,,0,,,,,,,,,,,,,0,,,0,0,0,,,0,0,0,,0,,,,,,,,,0,0,,,,,,,,0,0,0,0,0,0,,,,,,,,,,0,0,0,0,,,,0,0,,,,,,,,,,,,,,,,0,0,0,0,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"
                                                  ,trim(string(p-price-sale * 100, ">>>>>9"), chr(32))
                              )
                 .
  end.
  when "CAS_LP-15v1.6_new" then do:
      run create-name-str-2 in this-procedure ( buffer buf_goods, input 28, output name-buf1, output name-buf2).
      v-struct = trim(get-struct(input buf_goods.gds-code, p-plu-code, buf_goods.struct, p-scales-type, p-scales-db-num, p-scales-num)).
      v-main-string = substitute("1;&1;1;&2;&3;;0;&8;0;&4;&5;0;0;&6;0;&1;&7;0;0;0;0;0;0;0;0;0;0;",
                                 p-plu-code, trim(name-buf1), trim(name-buf2), trim(string(p-price-sale * 100, ">>>>>>>>9")),
                                 trim(get-wt-cart("CAS_LP-15v1.6", p-wt-cart, p-scales-db-num, p-scales-num, p-tara-string, p-dec-delim)),
                                 trim(string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), ">>>>9") ),
                                 v-struct,
                                                                 p-b-str
                                ).
  end.
  otherwise do:
    case p-scales-type:
      when 'CAS_CL5000J'
      or
      when 'CAS_CL5000'
      then do:
        v-row-length = 0.
      end.
      otherwise do:
        v-row-length = 26.
      end.
    end case.
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      run create-name-str-2 in this-procedure ( buffer buf_goods, input (v-row-length - 1), output name-buf1, output name-buf2) .
      assign
      v-main-string = string(p-pLU-code, ">>>9") + chr(32)  +
                      (if p-scales-type = 'CAS_CL5000J' or p-scales-type = 'CAS_CL5000'
                      then  (string((if p-plu-type = integer('0':U) then "01" else "02"), "x(2)") + chr(32) )
                      else '')  +
                      string(p-b-str, "x(5)") + chr(32) +
                      string( "~"" + string( name-buf1 ) + "~"", substitute("x(&1)", length(name-buf1) + 2)) + chr(32) +
                      string( "~"" + string( name-buf2 ) + "~"", substitute("x(&1)", length(name-buf2) + 2)) + chr(32) +
                      string(p-price-sale * 100, ">>>>>>>>9") + chr(32) +
                      string(scl-gds-ld2(p-deadline, p-deaddate, p-deadflag), ">>>>9") + chr(32) +
                      get-wt-cart(p-scales-type, p-wt-cart, p-scales-db-num, p-scales-num, p-tara-string, p-dec-delim).
    end.
    if p-mode = 'удаление':U
    or p-mode = "purge"
    or p-mode = "purge-all"
    then do:
      assign
      v-main-string = string(p-plu-code, ">>>9") + chr(32) +
                      (if p-scales-type = 'CAS_CL5000J' or p-scales-type = 'CAS_CL5000'
                      then (string("00", "x(2)") + chr(32))
                      else '') +
                      string(0, "99999") + chr(32) +
                      string( chr(34) + fill(chr(32), v-row-length) + chr(34), substitute("x(&1)", v-row-length + 2)) + chr(32) +
                      string( chr(34) + fill(chr(32), v-row-length) + chr(34), substitute("x(&1)", v-row-length + 2)) + chr(32) +
                      string(0, ">>>>>>>>9") + chr(32) +
                      string(0, ">>>>9") + chr(32) +
                      string(0,">>>9").
    end.
  end.
END CASE.
return v-main-string.
END FUNCTION.
PROCEDURE general-send:
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE PARAMETER BUFFER t-scales for ub.scales.
DEFINE INPUT PARAMETER SendOption as Char NO-UNDO.
define input parameter send-rid-list as character no-undo .
DEFINE INPUT PARAMETER ObjectOption as CHar NO-UNDO.
define variable name-buf1 as char no-undo .
define variable name-buf2 as char no-undo .
define variable glog as logical no-undo .
DEFINE VARIABLE var-tara-string as character no-undo .
define variable g#report-num as integer no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable rep-rec as recid no-undo .
define variable res as integer no-undo.
define variable err-scl-num-list as character no-undo .
define variable err-codes-list as character no-undo .
define variable i-section as integer no-undo .
define variable i-key as integer no-undo .
define variable v-sections as character no-undo .
define variable v-section as character no-undo .
define variable v-keys as character no-undo .
define variable v-out-key as character no-undo .
define variable v-file-name as character no-undo .
define variable v-file-mask as character no-undo .
define variable v-file-mask-1 as character no-undo .
define variable v-file-mask-2 as character no-undo .
define variable v-out-dir as character no-undo .
define variable v-mode as character no-undo .
define variable v-stream as character no-undo .
define buffer buf_shop for ub.shop.
define buffer b-scales for ub.scales.
define buffer buf_goods for ub.goods.
define buffer buf_scales-gds for ub.scales-gds.
define buffer buf_gds-obj-attr for ub.gds-obj-attr .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_gdsolist for gdsolist.
scale-prog = ?.
if t-scales.sts = integer('1':U) then do:
  return error substitute("Весы &1 имеют статус &2&3Пересылка запрещена"
                       , t-scales.scales-name
                       , entry (lookup (STRING(t-scales.sts), '0,1,50,99':U), 'тек,удал,блок,удаление':U)
                       , chr(10)).
end.
assign
scale-prog = ENTRY(LOOKUP(t-scales.scales-type, ini-types), ini-progs) no-error.
if not (t-scales.scales-type = "DIGI-SM"
        or t-scales.scales-type = "TIGER-SPCT2"
        or t-scales.scales-type = "TIGER-SPCT1"
        or t-scales.scales-type = "DIGI_AW-4600_FX"
        )
then do:
  if scale-prog = ? then do:
    SendOption = "".
    return error substitute("Ошибка! Не удалось определить программу для работы с типом весов &1", string(" " + t-scales.scales-type)).
  end.
  scale-prog = SEARCH(scale-prog).
  if scale-prog = ? then do:
    SendOption = "".
    return error substitute("Не найден файл программы работы с весами &1", string(" N " + string(t-scales.scales-num) + " - " + t-scales.scales-name + " тип " + t-scales.scales-type)).
  end.
end.
assign
var-tara-string = "":U
var-tara-string = get-tara-string(buffer t-scales)
no-error
.
run get-report-num  in parParentProc(output g#report-num).
CASE t-scales.scales-type:
  when 'DIGI-SM' then do:
  v-sections = 'scales'.
  v-keys = 'out,digi-sm-out'.
end.
  when 'TIGER-SPCT2' then do:
    v-sections = 'scales'.
    v-keys = 'out,tiger-spct2-install-dir'.
  end.
  when 'TIGER-SPCT1' then do:
    v-sections = 'scales'.
    v-keys = 'out,tiger-spct1-install-dir'.
  end.
  otherwise do:
    v-sections = 'scales,kassa-ibm'.
    v-keys = 'out'.
  end.
end.
_i-section:
do i-section = 1 to num-entries(v-sections):
  _i-key:
  do i-key = 1 to num-entries(v-keys):
    RUN verify-ini-entry in this-procedure (
                           input entry(i-key, v-keys)
                          ,input entry(i-section, v-sections)
                          ,input  substitute("отсутствует путь к подкаталогу [&1]&2 для отсылки информации на весы&2"
                                          , entry(i-key, v-keys)
                                          , chr(10)
                                          )
                          ,input yes
                          ,output v-out-dir) no-error.
    if error-status:error or v-out-dir = ? then do:
      if i-section = 1
      and t-scales.scales-type <> 'DIGI-SM'
      and t-scales.scales-type <> 'TIGER-SPCT2'
      and t-scales.scales-type <> 'TIGER-SPCT1'
      then do:
        next _i-key.
      end.
      if (t-scales.scales-type = 'DIGI-SM'
      or t-scales.scales-type = 'TIGER-SPCT2'
      or t-scales.scales-type = 'TIGER-SPCT1'
      )
      or i-section = 2 then do:
        SendOption = "".
        return error return-value .
      end.
    end.
    run gbl/return_.p .
    v-out-dir = prepare-path ( input v-out-dir) + chr(47).
    RUN verify-file( input v-out-dir
                    ,input substitute("Не найден каталог &1 &2 -параметр &3, секция &4 ini-файла"
                                    , v-out-dir
                                    , chr(10)
                                    , entry(i-key, v-keys)
                                    , v-section)
                    ,input yes
                    ,output glog) no-error.
    if error-status:error or not glog then do:
      SendOption = "".
      return error return-value .
    end.
    run gbl/return_.p .
    if i-section = 1 and i-key = 1
    or not (t-scales.scales-type = 'DIGI-SM'
            or
            t-scales.scales-type = 'TIGER-SPCT2'
            or
            t-scales.scales-type = 'TIGER-SPCT1'
            )
    then do:
      assign
      out-dir = v-out-dir.
      if t-scales.scales-type <> 'DIGI-SM'
      and t-scales.scales-type <> 'TIGER-SPCT2'
      and t-scales.scales-type <> 'TIGER-SPCT1'
      and  out-dir <> '':U then leave _i-section.
    end.
    if t-scales.scales-type = 'DIGI-SM'
    and i-key = 2
    and i-section = 1
    then do:
      assign
      digi-out-dir = v-out-dir.
      leave  _i-section.
    end.
    if t-scales.scales-type = 'TIGER-SPCT2'
    and i-key = 2
    and i-section = 1
    then do:
      assign
      tiger-spct2-out-dir = v-out-dir.
      tiger-spct2-install-dir = v-out-dir.
    end.
    if t-scales.scales-type = 'TIGER-SPCT1'
    and i-key = 2
    and i-section = 1
    then do:
      assign
      tiger-spct1-out-dir = v-out-dir.
      tiger-spct1-install-dir = v-out-dir.
    end.
  end.
end.
CASE t-scales.scales-type:
  when 'DIGI-SM' then do:
    RUN verify-ini-entry in this-procedure (
                          input 'digi-sm-file-mask'
                          ,input 'scales'
                          ,input  substitute("отсутствует настройка маски файла для весов типа &1&2"+
                                            "-параметр &3, секция &4 ini-файла,&2по умолчанию подставляем smimp*.dat"
                                          , t-scales.scales-type
                                          , chr(10)
                                          , 'digi-sm-file-mask'
                                          , 'scales'
                                          )
                          ,input yes
                          ,output v-file-mask) no-error.
    if v-file-mask = '':U
    or v-file-mask = ?
    then do:
      v-file-mask = 'smimp*.dat':U.
    end.
    assign
    v-file-mask-1 = (if index(chr(63), v-file-mask) > index('*':U, v-file-mask)
                    or index(chr(63), v-file-mask) = 0
                  then entry(1, v-file-mask, '*')
                  else entry(1, v-file-mask, chr(63))
                    )
    v-file-mask-2 = (if index(chr(63), v-file-mask) > index('*':U, v-file-mask)
                    or index(chr(63), v-file-mask) = 0
                      then (if num-entries(v-file-mask, '*') > 1
                            then entry(2, v-file-mask, '*')
                            else '':U)
                      else  (if num-entries(v-file-mask, chr(63)) > 1
                              then entry(2, v-file-mask, chr(63))
                              else '':U)
                      )
    .
    assign
    v-file-name = v-file-mask-1 + entry(4, t-scales.address, '.') + v-file-mask-2
    .
  end.
  when 'TIGER-SPCT2':U
  or
  when 'TIGER-SPCT1':U
  then do:
    RUN verify-ini-entry in this-procedure (
                           input (if t-scales.scales-type = "TIGER-SPCT2"
                                  then 'tiger-spct2-file-mask'
                                  else 'tiger-spct1-file-mask')
                          ,input 'scales'
                          ,input  substitute("отсутствует настройка маски файла для весов типа &1&2"+
                                            "-параметр &3, секция &4 ini-файла,&2по умолчанию подставляем trf*.out"
                                          , t-scales.scales-type
                                          , chr(10)
                                          , (if t-scales.scales-type = "TIGER-SPCT2"
                                             then 'tiger-spct2-file-mask'
                                             else 'tiger-spct1-file-mask')
                                          , 'scales'
                                          )
                          ,input yes
                          ,output v-file-mask) no-error.
    if v-file-mask = '':U
    or v-file-mask = ?
    then do:
      v-file-mask = 'trf*.out':U.
    end.
    assign
    v-file-mask-1 = (if index(chr(63), v-file-mask) > index('*':U, v-file-mask)
                    or index(chr(63), v-file-mask) = 0
                  then entry(1, v-file-mask, '*')
                  else entry(1, v-file-mask, chr(63))
                    )
    v-file-mask-2 = (if index(chr(63), v-file-mask) > index('*':U, v-file-mask)
                    or index(chr(63), v-file-mask) = 0
                      then (if num-entries(v-file-mask, '*') > 1
                            then entry(2, v-file-mask, '*')
                            else '':U)
                      else  (if num-entries(v-file-mask, chr(63)) > 1
                              then entry(2, v-file-mask, chr(63))
                              else '':U)
                      )
    .
    assign
    v-file-name = v-file-mask-1 + string(t-scales.scales-num) + v-file-mask-2
    .
  end.
  otherwise do:
    assign
    v-file-name = "plu" + string( g#report-num ) + "." + string(t-scales.scales-num, "999").
  end.
END CASE.
if t-scales.scales-type = "SHTRIH-M" then do:
  define variable v-dec-delim as character no-undo .
  define variable v-tho-delim as character no-undo .
  define variable v-sdate as character no-undo initial "/":U.
  define variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
  run gbl/getlocal.p ( output v-dec-delim
                      , output v-tho-delim
                      , output v-sdate
                      , output v-shortdate ) no-error .
end.
if SendOption = "RESEND":U then do:
  if t-scales.scales-type ="DIGI-SM" then do:
    message
    substitute("Опция ПОВТОРНОЙ отправки для данного типа весов реализована внутри сервиса загрузки весов")
    view-as alert-box warning.
    sendoption = ''.
    return.
  end.
  if t-scales.scales-type ="TIGER-SPCT2"
  or t-scales.scales-type ="TIGER-SPCT1"
  then do:
    message
    substitute("Опция ПОВТОРНОЙ отправки для данного типа весов не может быть реализована")
    view-as alert-box warning.
    sendoption = ''.
    return.
  end.
  if t-scales.scales-type = 'DIGI_AW-4600_FX':U then do:
    scale-prog = SEARCH("exe/curl.exe").
    if scale-prog = ? then do:
      message
      substitute("Не найден файл программы работы с весами &1", "exe/curl.exe")
      view-as alert-box error .
      sendoption = ''.
      return.
    end.
  end.
  if search( out-dir + v-file-name  ) = ? then do:
    message
    "В данной сессии работы с БД Вы еще не отсылали товары на весы " skip
    string(" N " + string(t-scales.scales-num) + " - " + t-scales.scales-name) skip
    "ИЛИ файл данных для весов, соответствующий данной сессии уже УДАЛЕН!"
    view-as alert-box ERROR.
    SendOption = "".
    return .
  end.
  run gbl/return_.p .
  RUN b-msend-proc in this-procedure (
                    buffer t-scales
                   ,input scale-prog
                   ,input v-file-name
                   ,input 'ИЗМЕНЕНИЕ':U
                   ,input "ПОВТОРНО отправляются товары на весы "
                   ,output res
                   ,output err-scl-num-list
                   ,output err-codes-list
                   ) no-error.
  if error-status:error or res > 0
  then return error substitute("Ошибка при повторной передаче на весы &1 и/или подчиненные весы&2&3&2&4&2&5"
                                , string(" N " + string(t-scales.scales-num) + " - " + t-scales.scales-name)
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                                , (if not error-status:error and res > 0
                                   then substitute("!!!Программа передачи данных на весы &1 вернула ошибку(-и) с кодом(-ми) &2"
                                                   ,err-scl-num-list
                                                   ,err-codes-list
                                                   )
                                   else '':U)
                                ).
END.
ELSE DO:
  if NOT can-find( first buf_scales-gds where
                         buf_scales-gds.db-num = t-scales.db-num
                    AND buf_scales-gds.scales-num = t-scales.scales-num ) then do:
    SendOption = "".
    return error substitute("НЕТ товаров на весах с номером &1", t-scales.scales-num).
  end.
  FOR EACH gds-list :
    delete gds-list .
  END .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Пересылка на весы №&1 &2.....&3Подготовка данных..."
                         , t-scales.scales-num
                         , t-scales.scales-name
                         , chr(10)
                         )).
  case t-scales.scales-type:
    when "CAS_CL5000J"
    or
    when "CAS_CL5000"
    then do:
      v-stream = "WINDOWS-1251".
    end.
    when "CAS_LP-15v1.6" then do:
         if replace(ENTRY(LOOKUP("CAS_LP-15v1.6", ini-types), ini-progs), "\", "/") = "exe/CAScentre.exe" and
         (SendOption = "changed"
         or SendOption = "ALL"
         or SendOption = "CURRENT"
         or SendOption = "SELECTIVE")
         then do:
          v-stream = "WINDOWS-1251".
        end.
    end.
    otherwise do:
    end.
  end case.
  _zz:
  DO
  ON STOP UNDO, return error
  ON END-KEY UNDO, return error
  ON ERROR UNDO, LEAVE:
    CASE SendOption :
      when "changed":U then do:
        assign
        jj = 0
        v-mode = 'ИЗМЕНЕНИЕ':U
        .
        CASE ObjectOption:
          WHEN 'текущие':U then do:
            obj-list = yes.
          end.
          when 'все':U then do:
            obj-list = no.
          end.
        END CASE.
        case v-stream:
          when "WINdows-1251" then do:
            if t-scales.scales-type = "CAS_LP-15v1.6" then do:
                output to value( out-dir + v-file-name ).
                put "номер отдела;номер товара;тип товара;первая строка названия товара;вторая строка названия товара;строка, которая печатается под логотипом;групповой код;код товара;фиксированная цена товара, в копейках;цена товара, в копейках;вес тары, в граммах;дата упаковки, в днях;время упаковки, в часах;срок годности, в днях;срок годности, в часах;номер состава продукта прикрепленного к товару;текст состава продукта;номер этикетки для печати;номер штрих-кода для печати;дата создания продукта, в днях;номер текста рекламного сообщения;номер логотипа для печати на этикетки;номер единицы измерения количественного товара;кол-во для штучных и счетных товаров;номер страны-производителя;номер второго штриховой код для печати на этикетки;фиксированный вес продукта;"
                    skip.
                output close.
                output stream PrnLibStream to value( out-dir + v-file-name ) append.
            end.
            else do:
                output stream PrnLibStream to value( out-dir + v-file-name ).
            end.
          end.
          otherwise do:
            output stream PrnLibStream to value( out-dir + v-file-name )
            convert target "ibm866".
          end.
        end case.
        FOR EACH buf_scales-gds WHERE
        buf_scales-gds.db-num = t-scales.db-num AND
        buf_scales-gds.scales-num = t-scales.scales-num AND
        buf_scales-gds.to-send = TRUE AND
        (obj-list = no
                or (buf_scales-gds.obj-type  = p-obj-type
                   AND
                   buf_scales-gds.obj-code  = p-obj-code)),
          FIRST buf_bar-code WHERE
                buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
          FIRST buf_goods WHERE
                buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK ,
          FIRST buf_gds-obj-attr WHERE
                buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                buf_gds-obj-attr.attr-code = 'scales-code':U AND
                buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                No-LOCK,
          FIRST buf_prod-bc WHERE
                buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK
          on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
          on stop   undo, return error substitute( "&1. stop", vss-workfile )
          on endkey undo, return error substitute( "&1. endkey", vss-workfile )
          :
         jj = jj + 1.
          if ( jj modulo 10 = 0 ) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                            , jj
                                                            , t-scales.scales-num)).
          end.
          if buf_scales-gds.to-del = yes then NEXT.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
          if gp-price-sale = ? then do:
            next .
          end.
          define variable l-in-ov as logical no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'in-ov=request'
  ,output l-in-ov
  ) no-error .
          if error-status:error then do:
            SendOption = "".
            undo, return error substitute("&1 &2 &3&4Ошибка получения признака товара на объекте&4код товара &5&4&6&4&7"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        , chr(10)
                                        ,buf_goods.gds-code
                                        , error-status:get-message(1)
                                        , return-value ).
          end.
          find first buf_shop no-lock where
                    buf_shop.obj-code = buf_scales-gds.obj-code.
          if buf_shop.in-ov and l-in-ov then do:
           next .
          end.
          PUT stream PrnLibStream unformatted
          main-record-string  ( buffer buf_goods
                              ,input 'ИЗМЕНЕНИЕ':U
                              ,input t-scales.db-num
                              ,input t-scales.scales-type
                              ,input buf_scales-gds.scales-num
                              ,input buf_scales-gds.plu-code
                              ,input buf_scales-gds.plu-type
                              ,input buf_prod-bc.b-str
                              ,input gp-price-sale
                              ,input buf_scales-gds.deadline
                              ,input buf_scales-gds.deaddate
                              ,input buf_scales-gds.deadflag
                              ,input buf_scales-gds.wt-cart
                              ,input var-tara-string
                              ,input v-dec-delim
                              )
          (if t-scales.scales-type = "CAS_lp-16x"                     or t-scales.scales-type = "DIGI-SM"                      or t-scales.scales-type = "TIGER-SPCT2"                      or t-scales.scales-type = "TIGER-SPCT1"                      or t-scales.scales-type = "CAS_CL5000j"                      or t-scales.scales-type = "CAS_CL5000"                      or t-scales.scales-type = "SHTRIH-M"                then get-struct ( input buf_goods.gds-code                                      , input buf_scales-gds.plu-code                                  , input buf_goods.struct                                         , input t-scales.scales-type                                , input t-scales.db-num                                , input t-scales.scales-num                                )                   else '':U)
          skip .
          assign
          buf_scales-gds.to-send = FALSE no-error .
          run create-obj-record in this-procedure (buffer buf_goods
                                                    , buf_scales-gds.obj-type
                                                    , buf_scales-gds.obj-code).
        END.
        IF can-find(first buf_scales-gds where
                          buf_scales-gds.db-num = t-scales.db-num AND
                          buf_scales-gds.scales-num = t-scales.scales-num AND
                          buf_scales-gds.to-del = yes) then do:
          run add-del-gds in this-procedure (input-output jj
                                            ,input v-dec-delim
                                            ,buffer t-scales) .
        end.
        output stream PrnLibStream close.
        if jj = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Нет измененных товаров на весах &1", string(" N " + string(t-scales.scales-num) + " - " + t-scales.scales-name))
                                                    ).
          SendOption = "".
          return .
        end.
        run check-write-scales-status in this-procedure (input t-scales.scales-num, input t-scales.db-num, input recid(t-scales)).
      end.
      when "purge-all" then do:
        case v-stream:
          when "WINdows-1251" then do:
            output stream PrnLibStream to value( out-dir + v-file-name ) .
          end.
          otherwise do:
            output stream PrnLibStream to value( out-dir + v-file-name )
            convert target "ibm866".
          end.
        end case.
        assign
        jj = 0
        v-mode = 'удаление':U
        .
        case t-scales.scales-type :
          when "DIGI-SM" then do :
            FOR EACH buf_scales-gds WHERE
                          buf_scales-gds.scales-num = t-scales.scales-num
                      AND buf_scales-gds.db-num = t-scales.db-num
                      EXCLUSIVE-LOCK,
              FIRST buf_bar-code WHERE
                    buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK ,
              FIRST buf_goods WHERE
                    buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK ,
              FIRST buf_gds-obj-attr WHERE
                    buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                    buf_gds-obj-attr.attr-code = 'scales-code':U AND
                    buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                    buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                    No-LOCK,
              FIRST buf_prod-bc WHERE
                    buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK :
              jj = jj + 1.
              if ( jj modulo 10 = 0 ) then do:
                run show-counter in p-log-handle .
                run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                                , jj
                                                                , t-scales.scales-num)).
              end.
              PUT stream PrnLibStream unformatted
               main-record-string  ( buffer buf_goods
                                ,input "purge-all"
                                ,input t-scales.db-num
                                ,input t-scales.scales-type
                                ,input t-scales.scales-num
                                ,input buf_scales-gds.plu-code
                                ,input buf_scales-gds.whole-send-news
                                ,input buf_prod-bc.b-str
                                ,input 0.0
                                ,input 0
                                ,input ?
                                ,input 0
                                ,input 0.0
                                ,input '':U
                                ,input v-dec-delim
                                )
              (if t-scales.scales-type = "CAS_lp-16x"                        or t-scales.scales-type = "DIGI-SM"                          or t-scales.scales-type = "TIGER-SPCT2"                          or t-scales.scales-type = "TIGER-SPCT1"                          or t-scales.scales-type = "CAS_CL5000j"                          or t-scales.scales-type = "CAS_CL5000"                  then get-struct( input 0                                  , input 0                                  , input '':U                               , input t-scales.scales-type                               , input t-scales.db-num                               , input t-scales.scales-num                               )                   else '':U)
              skip .
              delete buf_scales-gds no-error.
              if error-status:error then do:
                return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
              end.
            END.
          end.
          otherwise do :
        DO jj = 1 TO   qnty-buf :
          if ( jj modulo 10 = 0 ) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                            , jj
                                                            , t-scales.scales-num)).
          end.
          if ((t-scales.scales-type <> "TIGER-SPCT2"
              and
              t-scales.scales-type <> "TIGER-SPCT1")
          or jj = 1 )
          and t-scales.scales-type <> "CAS_CL5000J"
          and t-scales.scales-type <> "CAS_CL5000"
          then do:
                        FOR EACH buf_scales-gds WHERE
                          buf_scales-gds.scales-num = t-scales.scales-num
                      AND buf_scales-gds.db-num = t-scales.db-num
                      EXCLUSIVE-LOCK,
              FIRST buf_bar-code WHERE
                    buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK ,
              FIRST buf_goods WHERE
                    buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK ,
              FIRST buf_gds-obj-attr WHERE
                    buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                    buf_gds-obj-attr.attr-code = 'scales-code':U AND
                    buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                    buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                    No-LOCK,
              FIRST buf_prod-bc WHERE
                    buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK :
              jj = jj + 1.
              if ( jj modulo 10 = 0 ) then do:
                run show-counter in p-log-handle .
                run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                                , jj
                                                                , t-scales.scales-num)).
              end.
            PUT stream PrnLibStream unformatted
            main-record-string  ( buffer buf_goods
                                ,input "purge-all"
                                ,input t-scales.db-num
                                ,input t-scales.scales-type
                                ,input t-scales.scales-num
                                ,input jj
                                ,input ?
                                ,input buf_prod-bc.b-str
                                ,input 0.0
                                ,input 0
                                ,input ?
                                ,input 0
                                ,input 0.0
                                ,input '':U
                                ,input v-dec-delim
                                )
            (if t-scales.scales-type = "CAS_lp-16x"                        or t-scales.scales-type = "DIGI-SM"                          or t-scales.scales-type = "TIGER-SPCT2"                          or t-scales.scales-type = "TIGER-SPCT1"                          or t-scales.scales-type = "CAS_CL5000j"                          or t-scales.scales-type = "CAS_CL5000"                  then get-struct( input 0                                  , input 0                                  , input '':U                               , input t-scales.scales-type                               , input t-scales.db-num                               , input t-scales.scales-num                               )                   else '':U)
            skip .
          end.
          end.
          FIND FIRST buf_scales-gds WHERE
                      buf_scales-gds.scales-num = t-scales.scales-num
                  AND buf_scales-gds.db-num = t-scales.db-num
                  AND buf_scales-gds.PLU-code = jj EXCLUSIVE NO-ERROR .
          if available buf_scales-gds then do:
            delete buf_scales-gds no-error.
            if error-status:error then do:
              return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
            end.
          end.
        END.
          end.
        end case.
        output stream PrnLibStream close.
      end.
      when "purge-selective" then do:
        gds-amount = num-entries( send-rid-list ) .
        case v-stream:
          when "WINdows-1251" then do:
                output stream PrnLibStream to value( out-dir + v-file-name ).
          end.
          otherwise do:
            output stream PrnLibStream to value( out-dir + v-file-name )
            convert target "ibm866".
          end.
        end case.
        assign
        v-mode = (if t-scales.scales-type = "CAS_CL5000J"
                  or t-scales.scales-type = "CAS_CL5000"
                  then 'ИЗМЕНЕНИЕ':U
                  else 'удаление':U).
        case t-scales.scales-type :
          when "DIGI-SM" then do :
            DO jj = 1 TO gds-amount :
              if ( jj modulo 10 = 0 ) then do:
                run show-counter in p-log-handle .
                run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                                , jj
                                                                , t-scales.scales-num)).
              end.
              FIND FIRST buf_scales-gds WHERE
                          recid( buf_scales-gds ) = integer( entry( jj, send-rid-list ) ).
              FIND FIRST buf_bar-code WHERE
                    buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK.
              FIND FIRST buf_goods WHERE
                    buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK .
              FIND FIRST buf_gds-obj-attr WHERE
                    buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                    buf_gds-obj-attr.attr-code = 'scales-code':U AND
                    buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                    buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                    No-LOCK.
              FIND FIRST buf_prod-bc WHERE
                    buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK.
              PUT stream PrnLibStream unformatted
                 main-record-string  ( buffer buf_goods
                              ,input "purge"
                              ,input t-scales.db-num
                              ,input t-scales.scales-type
                              ,input buf_scales-gds.scales-num
                              ,input buf_scales-gds.plu-code
                              ,input buf_scales-gds.plu-type
                              ,input buf_prod-bc.b-str
                              ,input 0.0
                              ,input 0
                              ,input ?
                              ,input 0
                              ,input 0.0
                              ,input '':U
                              ,input v-dec-delim
                              )
              (if t-scales.scales-type = "CAS_lp-16x"                        or t-scales.scales-type = "DIGI-SM"                          or t-scales.scales-type = "TIGER-SPCT2"                          or t-scales.scales-type = "TIGER-SPCT1"                          or t-scales.scales-type = "CAS_CL5000j"                          or t-scales.scales-type = "CAS_CL5000"                  then get-struct( input 0                                  , input 0                                  , input '':U                               , input t-scales.scales-type                               , input t-scales.db-num                               , input t-scales.scales-num                               )                   else '':U)
              skip .
              delete buf_scales-gds no-error .
              if error-status:error then do:
                return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
              end.
            end.
          end.
          otherwise do :
        DO jj = 1 TO gds-amount :
          if ( jj modulo 10 = 0 ) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                            , jj
                                                            , t-scales.scales-num)).
          end.
          FIND FIRST buf_scales-gds WHERE
                      recid( buf_scales-gds ) = integer( entry( jj, send-rid-list ) ) .
              FIND FIRST buf_bar-code WHERE
                    buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK.
              FIND FIRST buf_goods WHERE
                    buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK .
              FIND FIRST buf_gds-obj-attr WHERE
                    buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                    buf_gds-obj-attr.attr-code = 'scales-code':U AND
                    buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                    buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                    No-LOCK.
              FIND FIRST buf_prod-bc WHERE
                    buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK.
          PUT stream PrnLibStream unformatted
         main-record-string  ( buffer buf_goods
                              ,input "purge"
                              ,input t-scales.db-num
                              ,input t-scales.scales-type
                              ,input buf_scales-gds.scales-num
                              ,input buf_scales-gds.plu-code
                              ,input buf_scales-gds.plu-type
                              ,input buf_prod-bc.b-str
                              ,input 0.0
                              ,input 0
                              ,input ?
                              ,input 0
                              ,input 0.0
                              ,input '':U
                              ,input v-dec-delim
                              )
          (if t-scales.scales-type = "CAS_lp-16x"                        or t-scales.scales-type = "DIGI-SM"                          or t-scales.scales-type = "TIGER-SPCT2"                          or t-scales.scales-type = "TIGER-SPCT1"                          or t-scales.scales-type = "CAS_CL5000j"                          or t-scales.scales-type = "CAS_CL5000"                  then get-struct( input 0                                  , input 0                                  , input '':U                               , input t-scales.scales-type                               , input t-scales.db-num                               , input t-scales.scales-num                               )                   else '':U)
          skip .
          delete buf_scales-gds no-error .
          if error-status:error then do:
            return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
          end.
        end.
          end.
        end case.
        output stream PrnLibStream close.
      end.
      when "ALL":U then do:
        v-mode = 'ИЗМЕНЕНИЕ':U.
        CASE ObjectOption:
          WHEN 'текущие':U then do:
              obj-list = yes.
            end.
            when 'все':U then do:
              obj-list = no.
            end.
          END CASE.
          case v-stream:
            when "WINdows-1251" then do:
              if t-scales.scales-type = "CAS_LP-15v1.6" then do:
                  output to value( out-dir + v-file-name ).
                  put "номер отдела;номер товара;тип товара;первая строка названия товара;вторая строка названия товара;строка, которая печатается под логотипом;групповой код;код товара;фиксированная цена товара, в копейках;цена товара, в копейках;вес тары, в граммах;дата упаковки, в днях;время упаковки, в часах;срок годности, в днях;срок годности, в часах;номер состава продукта прикрепленного к товару;текст состава продукта;номер этикетки для печати;номер штрих-кода для печати;дата создания продукта, в днях;номер текста рекламного сообщения;номер логотипа для печати на этикетки;номер единицы измерения количественного товара;кол-во для штучных и счетных товаров;номер страны-производителя;номер второго штриховой код для печати на этикетки;фиксированный вес продукта;"
                      skip.
                  output close.
                  output stream PrnLibStream to value( out-dir + v-file-name ) append.
              end.
              else do:
                  output stream PrnLibStream to value( out-dir + v-file-name ).
              end.
            end.
            otherwise do:
              output stream PrnLibStream to value( out-dir + v-file-name )
              convert target "ibm866".
            end.
          end case.
          jj = 0.
          FOR EACH buf_scales-gds WHERE
                    buf_scales-gds.db-num = t-scales.db-num AND
                    buf_scales-gds.scales-num = t-scales.scales-num AND
                (obj-list = no
                or (buf_scales-gds.obj-type  = p-obj-type
                   AND
                   buf_scales-gds.obj-code  = p-obj-code)),
              FIRST buf_bar-code WHERE
                    buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
              FIRST buf_goods WHERE
                    buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK ,
              FIRST buf_gds-obj-attr WHERE
                    buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                    buf_gds-obj-attr.attr-code = 'scales-code':U AND
                    buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                    buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                    No-LOCK,
              FIRST buf_prod-bc WHERE
                    buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK
              on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
              on stop   undo, return error substitute( "&1. stop", vss-workfile )
              on endkey undo, return error substitute( "&1. endkey", vss-workfile )
              :
            jj = jj + 1.
            if ( jj modulo 10 = 0 ) then do:
              run show-counter in p-log-handle .
              run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                              , jj
                                                              , t-scales.scales-num)).
            end.
            if buf_scales-gds.to-del = yes then NEXT.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
            if gp-price-sale = ? then NEXT .
            PUT stream PrnLibStream unformatted
            main-record-string  ( buffer buf_goods
                                ,input 'ИЗМЕНЕНИЕ':U
                                ,input t-scales.db-num
                                ,input t-scales.scales-type
                                ,input buf_scales-gds.scales-num
                                ,input buf_scales-gds.PLU-code
                                ,input buf_scales-gds.plu-type
                                ,input buf_prod-bc.b-str
                                ,input gp-price-sale
                                ,input buf_scales-gds.deadline
                                ,input buf_scales-gds.deaddate
                                ,input buf_scales-gds.deadflag
                                ,input buf_scales-gds.wt-cart
                                ,input var-tara-string
                                ,input v-dec-delim
                                )
            (if t-scales.scales-type = "CAS_lp-16x"                     or t-scales.scales-type = "DIGI-SM"                      or t-scales.scales-type = "TIGER-SPCT2"                      or t-scales.scales-type = "TIGER-SPCT1"                      or t-scales.scales-type = "CAS_CL5000j"                      or t-scales.scales-type = "CAS_CL5000"                      or t-scales.scales-type = "SHTRIH-M"                then get-struct ( input buf_goods.gds-code                                      , input buf_scales-gds.plu-code                                  , input buf_goods.struct                                         , input t-scales.scales-type                                , input t-scales.db-num                                , input t-scales.scales-num                                )                   else '':U)
            skip .
            assign
            buf_scales-gds.to-send = FALSE no-error .
            run create-obj-record in this-procedure (buffer buf_goods
                                                  , buf_scales-gds.obj-type
                                                  , buf_scales-gds.obj-code).
          END.
          IF can-find(first buf_scales-gds where
                            buf_scales-gds.db-num = t-scales.db-num AND
                            buf_scales-gds.scales-num = t-scales.scales-num AND
                            buf_scales-gds.to-del = yes) then do:
            run add-del-gds in this-procedure ( input-output jj
                                               ,input v-dec-delim
                                               ,buffer t-scales) .
          end.
          output stream PrnLibStream close.
          run check-write-scales-status in this-procedure (input t-scales.scales-num, input t-scales.db-num, input recid(t-scales)).
      end.
      when "SELECTIVE":U
      or
      when "CURRENT" then do:
        goods-lst = "" .
        assign
        goods-lst = send-rid-list
      v-mode = 'ИЗМЕНЕНИЕ':U
        .
        if SendOption = "CURRENT" then do:
          assign
          goods-lst = send-rid-list
          SendOption = "selective":U
          .
        end.
        if goods-lst <> "" then do:
          gds-amount = num-entries( goods-lst ) .
          run show-counter in p-log-handle .
          run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                            , jj
                                                            , t-scales.scales-num)).
          case v-stream:
            when "WINdows-1251" then do:
              if t-scales.scales-type = "CAS_LP-15v1.6" then do:
                  output to value( out-dir + v-file-name ).
                  put "номер отдела;номер товара;тип товара;первая строка названия товара;вторая строка названия товара;строка, которая печатается под логотипом;групповой код;код товара;фиксированная цена товара, в копейках;цена товара, в копейках;вес тары, в граммах;дата упаковки, в днях;время упаковки, в часах;срок годности, в днях;срок годности, в часах;номер состава продукта прикрепленного к товару;текст состава продукта;номер этикетки для печати;номер штрих-кода для печати;дата создания продукта, в днях;номер текста рекламного сообщения;номер логотипа для печати на этикетки;номер единицы измерения количественного товара;кол-во для штучных и счетных товаров;номер страны-производителя;номер второго штриховой код для печати на этикетки;фиксированный вес продукта;"
                      skip.
                  output close.
                  output stream PrnLibStream to value( out-dir + v-file-name ) append.
              end.
              else do:
                  output stream PrnLibStream to value( out-dir + v-file-name ).
              end.
            end.
            otherwise do:
              output stream PrnLibStream to value( out-dir + v-file-name )
              convert target "ibm866".
            end.
          end case.
          DO jj = 1 TO gds-amount :
            FIND FIRST buf_scales-gds WHERE
                      recid( buf_scales-gds ) = integer( entry( jj, goods-lst ) ) .
            FIND FIRST buf_bar-code WHERE
                      buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK .
            FIND FIRST buf_goods WHERE
                      buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK.
            FIND FIRST buf_gds-obj-attr WHERE
                        buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                        buf_gds-obj-attr.attr-code = 'scales-code':U AND
                        buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                        buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                        No-LOCK.
            FIND FIRST buf_prod-bc WHERE
                        buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK.
            if ( jj modulo 10 = 0 ) then do:
              run show-counter in p-log-handle .
              run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                              , jj
                                                              , t-scales.scales-num)).
            end.
            if buf_scales-gds.to-del = yes then NEXT.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  buf_scales-gds.obj-type
  ,input  buf_scales-gds.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
            if gp-price-sale = ? then NEXT .
            PUT stream PrnLibStream unformatted
            main-record-string  ( buffer buf_goods
                                ,input 'ИЗМЕНЕНИЕ':U
                                ,input t-scales.db-num
                                ,input t-scales.scales-type
                                ,input buf_scales-gds.scales-num
                                ,input buf_scales-gds.PLU-code
                                ,input buf_scales-gds.plu-type
                                ,input buf_prod-bc.b-str
                                ,input gp-price-sale
                                ,input buf_scales-gds.deadline
                                ,input buf_scales-gds.deaddate
                                ,input buf_scales-gds.deadflag
                                ,input buf_scales-gds.wt-cart
                                ,input var-tara-string
                                ,input v-dec-delim)
            (if t-scales.scales-type = "CAS_lp-16x"                     or t-scales.scales-type = "DIGI-SM"                      or t-scales.scales-type = "TIGER-SPCT2"                      or t-scales.scales-type = "TIGER-SPCT1"                      or t-scales.scales-type = "CAS_CL5000j"                      or t-scales.scales-type = "CAS_CL5000"                      or t-scales.scales-type = "SHTRIH-M"                then get-struct ( input buf_goods.gds-code                                      , input buf_scales-gds.plu-code                                  , input buf_goods.struct                                         , input t-scales.scales-type                                , input t-scales.db-num                                , input t-scales.scales-num                                )                   else '':U)
            skip .
            assign
            buf_scales-gds.to-send = FALSE no-error .
            if error-status:error then do:
              return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
            end.
            run create-obj-record in this-procedure (buffer buf_goods
                                                  , buf_scales-gds.obj-type
                                                  , buf_scales-gds.obj-code).
        END.
          IF can-find(first buf_scales-gds where
                            buf_scales-gds.db-num = t-scales.db-num AND
                            buf_scales-gds.scales-num = t-scales.scales-num AND
                            buf_scales-gds.to-del = yes) then do:
               run add-del-gds in this-procedure ( input-output jj
                                                  ,input v-dec-delim
                                                  ,buffer t-scales) .
        end.
            output stream PrnLibStream close.
         run check-write-scales-status in this-procedure (input t-scales.scales-num, input t-scales.db-num, input recid(t-scales)).
        end.
        else do:
          output stream PrnLibStream close.
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не найдено товаров, выбранных для отсылки на весах &1", string(" N " + string(t-scales.scales-num) + " - " + t-scales.scales-name))).
            SendOption = "".
            return.
          end.
        end.
     END CASE.
    CASE t-scales.scales-type:
      when 'DIGI-SM':U then do:
      end.
      when 'TIGER-SPCT2':U then do:
      end.
      when 'TIGER-SPCT1':U then do:
      end.
      when 'DIGI_AW-4600_FX':U then do:
        scale-prog = SEARCH("exe/curl.exe").
        if scale-prog = ? then do:
          undo _zz, return error substitute("Не найден файл программы работы с весами &1", "exe/curl.exe").
        end.
      end.
      otherwise do:
       scale-prog = SEARCH(scale-prog).
       if scale-prog = ? then do:
         undo _zz, return error substitute("Не найден файл программы работы с весами &1", string(" N " + string(t-scales.scales-num) + " - " + t-scales.scales-name + " тип " + t-scales.scales-type)).
       end.
     end.
    end.
    if SendOption <> "selective":U then do:
      run gbl/return_.p .
      RUN b-msend-proc in this-procedure (
                       buffer t-scales
                      ,input scale-prog
                      ,input v-file-name
                      ,input v-mode
                      ,input (if sendoption begins "purge"
                              then "Очищаются весы "
                              else "Отправляются товары на весы ")
                      ,output res
                      ,output err-scl-num-list
                      ,output err-codes-list
                      ) no-error.
       if error-status:error or res > 0 then do:
         undo _zz, return error substitute("Ошибка при пересылке данных на весы &1 и/или подчиненные весы&2&3&2&4&2&5"
                                         , string(" N " + string(t-scales.scales-num) + " - " + t-scales.scales-name)
                                         , chr(10)
                                         , error-status:get-message(1)
                                         , return-value
                                        , (if not error-status:error and res > 0
                                          then substitute("!!!Программа передачи данных на весы &1 вернула ошибку(-и) с кодом(-ми) &2"
                                                          ,err-scl-num-list
                                                          ,err-codes-list
                                                          )
                                          else '':U)
                                         ).
      end.
    end.
    else do:
      if goods-lst <> "" then do:
        run gbl/return_.p .
        RUN b-msend-proc in this-procedure (
                         buffer t-scales
                        ,input scale-prog
                        ,input v-file-name
                        ,input v-mode
                        ,input "Отправляются товары на весы "
                        ,output res
                        ,output err-scl-num-list
                        ,output err-codes-list
                        ) no-error.
        if error-status:error or res > 0 then do:
          undo _zz, return error substitute("Ошибка при пересылке данных на весы &1 и/или подчиненные весы&2&3&2&4&2&5"
                                          , string(" N " + string(t-scales.scales-num) + " - " + t-scales.scales-name)
                                          , chr(10)
                                          , error-status:get-message(1)
                                          , return-value
                                          , (if not error-status:error and res > 0
                                            then substitute("!!!Программа передачи данных на весы &1 вернула ошибку(-и) с кодом(-ми) &2"
                                                            ,err-scl-num-list
                                                            ,err-codes-list
                                                            )
                                            else '':U)
                                          ).
        end.
     end.
    end.
    if sendoption begins "purge" then do:
      FIND b-scales WHERE recid( b-scales ) = recid( t-scales ) EXCLUSIVE.
      CASE sendOption:
        when "purge-ALL":U then do:
          assign
          b-scales.max-plu = 0
          b-scales.tot-gds = 0
          b-scales.to-send = FALSE
          .
        end.
        when "purge-selective":U then do:
          if NOT can-find( FIRST buf_scales-gds WHERE
                                  buf_scales-gds.scales-num = t-scales.scales-num AND
                                  buf_scales-gds.db-num = t-scales.db-num AND
                                  buf_scales-gds.to-send = TRUE ) then do:
              b-scales.to-send = FALSE.
          end.
          FIND LAST buf_scales-gds NO-LOCK WHERE
                    buf_scales-gds.scales-num = t-scales.scales-num
                and buf_scales-gds.db-num = t-scales.db-num
                    use-index pi no-error.
          if avail buf_scales-gds then
          assign
          b-scales.max-plu = buf_scales-gds.plu-code
          b-scales.tot-gds = b-scales.tot-gds - gds-amount
          .
          else
          assign
          b-scales.max-plu = 0
          b-scales.tot-gds = 0
          .
        end.
      END CASE.
    end.
  END.
  IF NOT Error-status:error
  and res = 0
  and not (sendoption begins "purge")
  then do:
    for each buf_gdsolist
    break
    by buf_gdsolist.obj-type
    by buf_gdsolist.obj-code:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = buf_gdsolist.prod-type
    and gds-list.prod-code = buf_gdsolist.prod-code
    and gds-list.artic     = buf_gdsolist.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last29 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last29 = gds-list.order-num .
  end.
  else do:
    v-last29 = 0 .
  end.
  create gds-list .
  buffer-copy buf_gdsolist to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last29 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
      assign
      gds-list.qnty = - 1.
      if last-of(buf_gdsolist.obj-code) then do:
        run write-counter in p-log-handle ('':U).
        run set-title in p-log-handle (
              input substitute("Отправка весовых товаров на кассы &1&2", buf_gdsolist.obj-type, buf_GDSOLIST.OBJ-CODE)
                                      ).
        run str/send-gds.p (
                        input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input (string(buf_gdsolist.obj-code) + chr(4) + "yes":U)
                      ) no-error .
        if error-status:error then
        return error substitute( "ошибка при отправке товаров на кассу по магазину &1&2&3&2&4"
                                , abs(buf_gdsolist.obj-code)
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                                ).
      end.
    end.
  end.
  if sendoption begins "purge" then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Очистка завершена."
                          )).
  end.
END.
END PROCEDURE.
PROCEDURE add-del-gds:
DEFINE INPUT-OUTPUT PARAMETER ii as integer no-undo.
define input parameter p-dec-delim as character no-undo .
DEFINE PARAMETER buffer loc-scales for ub.scales.
define buffer buf_scales-gds for ub.scales-gds.
define buffer buf_goods for ub.goods.
define buffer buf_gds-obj-attr for ub.gds-obj-attr .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  CASE loc-scales.scales-type :
    when "DIGI-SM" then do :
      FOR EACH buf_scales-gds WHERE
              buf_scales-gds.scales-num = loc-scales.scales-num AND
              buf_scales-gds.db-num = loc-scales.db-num AND
              buf_scales-gds.to-del = yes,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK ,
        FIRST buf_gds-obj-attr WHERE
              buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
              buf_gds-obj-attr.attr-code = 'scales-code':U AND
              buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
              buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
              No-LOCK,
        FIRST buf_prod-bc WHERE
              buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK
              :
        ii = ii + 1.
        if ( ii modulo 10 = 0) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                            , ii
                                                            , loc-scales.scales-num)).
        end.
        PUT stream PrnLibStream unformatted
           main-record-string  ( buffer buf_goods
                        ,input 'удаление':U
                        ,input loc-scales.db-num
                        ,input loc-scales.scales-type
                        ,input buf_scales-gds.scales-num
                        ,input buf_scales-gds.plu-code
                        ,input buf_scales-gds.plu-type
                        ,input buf_prod-bc.b-str
                        ,input 0.0
                        ,input 0
                        ,input ?
                        ,input 0
                        ,input 0.0
                        ,input '':U
                        ,input p-dec-delim
                        )
        (if loc-scales.scales-type = "CAS_lp-16x"                        or loc-scales.scales-type = "DIGI-SM"                          or loc-scales.scales-type = "CAS_CL5000j"                          or loc-scales.scales-type = "CAS_CL5000"                  then get-struct( input 0                                  , input 0                                   , input '':U                               , input loc-scales.scales-type                               , input loc-scales.db-num                               , input loc-scales.scales-num                               )                   else '':U)
        skip .
        delete buf_scales-gds no-error .
        if error-status:error then do:
          return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
        end.
        FIND FIRST b-scales WHERE
                    recid( b-scales ) = recid( loc-scales ) .
        assign
        b-scales.to-send = TRUE
        b-scales.tot-gds  = b-scales.tot-gds - 1
        .
      end.
    end.
    otherwise do :
  FOR EACH buf_scales-gds WHERE
           buf_scales-gds.scales-num = loc-scales.scales-num AND
           buf_scales-gds.db-num = loc-scales.db-num AND
           buf_scales-gds.to-del = yes:
                 FIND FIRST buf_bar-code WHERE
                      buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK .
            FIND FIRST buf_goods WHERE
                      buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK.
            FIND FIRST buf_gds-obj-attr WHERE
                        buf_gds-obj-attr.gds-code = buf_bar-code.gds-code AND
                        buf_gds-obj-attr.attr-code = 'scales-code':U AND
                        buf_gds-obj-attr.obj-type = buf_scales-gds.obj-type AND
                        buf_gds-obj-attr.obj-code = buf_scales-gds.obj-code
                        No-LOCK.
            FIND FIRST buf_prod-bc WHERE
                        buf_prod-bc.b-str = buf_gds-obj-attr.attr-value NO-LOCK.
    ii = ii + 1.
    if ( ii modulo 10 = 0) then do:
        run show-counter in p-log-handle .
        run write-counter in p-log-handle (substitute("Обработано: &1 товаров на весах № &2"
                                                        , ii
                                                        , loc-scales.scales-num)).
    end.
    PUT stream PrnLibStream unformatted
    main-record-string  ( buffer buf_goods
                        ,input 'удаление':U
                        ,input loc-scales.db-num
                        ,input loc-scales.scales-type
                        ,input buf_scales-gds.scales-num
                        ,input buf_scales-gds.plu-code
                        ,input buf_scales-gds.plu-type
                        ,input buf_prod-bc.b-str
                        ,input 0.0
                        ,input 0
                        ,input ?
                        ,input 0
                        ,input 0.0
                        ,input '':U
                        ,input p-dec-delim
                        )
    (if loc-scales.scales-type = "CAS_lp-16x"                        or loc-scales.scales-type = "DIGI-SM"                          or loc-scales.scales-type = "CAS_CL5000j"                          or loc-scales.scales-type = "CAS_CL5000"                  then get-struct( input 0                                  , input 0                                   , input '':U                               , input loc-scales.scales-type                               , input loc-scales.db-num                               , input loc-scales.scales-num                               )                   else '':U)
    skip .
    delete buf_scales-gds no-error .
    if error-status:error then do:
      return error substitute("&1&2&3", error-status:get-message(1) , return-value ).
    end.
    FIND FIRST b-scales WHERE
                recid( b-scales ) = recid( loc-scales ) .
    assign
    b-scales.to-send = TRUE
    b-scales.tot-gds  = b-scales.tot-gds - 1
    .
  end.
    end.
  end case.
 END.
END.
PROCEDURE b-msend-proc:
DEFINE PARAMETER BUFFER p-scales for ub.scales.
DEFINE INPUT PARAMETER p-scale-prog as char no-undo.
define input parameter p-file-name as character no-undo .
define input parameter p-mode as character no-undo .
DEFINE INPUT PARAMETER p-message as char no-undo.
DEFINE OUTPUT PARAMETER p-res as integer no-undo.
define output parameter p-err-scl-num-list as character no-undo .
define output parameter p-err-codes-list as character no-undo .
define variable g#report-num as integer no-undo .
define variable v-cmd-line as character no-undo .
define variable r_e as character no-undo .
define variable com_ip as character no-undo .
define variable timeout_port as character no-undo .
define variable v-par as character no-undo.
run get-report-num  in parParentProc(output g#report-num).
DEFINE variable l-res as integer no-undo.
define variable chr-res as character no-undo .
DEFINE BUFFER slave_scales for ub.scales.
if p-scales.scales-type begins "BOLET"
then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1 &2 (№ &3)"
                        , p-message
                        , p-scales.scales-name
                        , p-scales.scales-num)
                                           ).
  run gbl/syn.p ( input p-scale-prog
            ,input (string(p-scales.scales-num)  +
                   out-dir + p-file-name
                   )
            ,input '':U
            ,output l-res) no-error.
  assign
  p-res = p-res + ABS(l-res ) + (IF error-status:error then 1 else 0)
  p-err-scl-num-list = p-err-scl-num-list + (if abs(l-res) <> 0 then string(p-scales.scales-num) else '':U) + chr(44)
  p-err-codes-list   =  p-err-codes-list  + (if abs(l-res) <> 0 then string(l-res) else '':U) + chr(44)
  .
  FOR EACH slave_scales WHERE
        slave_scales.master = p-scales.scales-num
    AND slave_scales.db-num = p-scales.db-num
        :
    if slave_scales.sts =  integer('0':U)  then do:
      run write-log-and-file in p-log-handle (
                                              input 1
                                            , input log-file-name
                                            , input 1
                                            , input substitute("&1 - Подчиненные весы &2 (№ &3)"
                                                              , p-message
                                                              , slave_scales.scales-name
                                                              , slave_scales.scales-num)
                                                                                ).
      run gbl/syn.p ( input p-scale-prog
                ,input (string(slave_scales.scales-num)  +
                        out-dir + p-file-name)
                ,input '':U
                ,output l-res) no-error.
      assign
      p-res = p-res + ABS(l-res ) + (IF error-status:error then 1 else 0)
      p-err-scl-num-list = p-err-scl-num-list + (if abs(l-res) <> 0 then string(slave_scales.scales-num) else '':U) + chr(44)
      p-err-codes-list   =  p-err-codes-list  + (if abs(l-res) <> 0 then string(l-res) else '':U) + chr(44)
      .
    end.
  END.
end.
else do:
  run write-log-and-file in p-log-handle (
                                          input 1
                                        , input log-file-name
                                        , input 1
                                        , input  substitute("&1 &2 (№ &3)"
                                                            ,p-message
                                                            ,p-scales.scales-name
                                                            ,p-scales.scales-num)
                                                                            ).
  CASE p-scales.scales-type:
    when 'DIGI-SM' then do:
    os-copy value(out-dir + p-file-name)
            value(digi-out-dir + p-file-name).
    assign
    p-res = p-res + ABS(os-error) + (IF os-error > 0 then 1 else 0)
    p-err-scl-num-list = p-err-scl-num-list + (if abs(os-error) <> 0 then string(p-scales.scales-num) else '':U) + chr(44)
    p-err-codes-list   =  p-err-codes-list  + (if abs(os-error) <> 0 then string(os-error) else '':U) + chr(44)
    .
    FOR EACH slave_scales WHERE slave_scales.master = p-scales.scales-num:
      run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input  substitute("&1 Подчиненные весы &2 (№ &3)"
                                                                  ,p-message
                                                                  ,slave_scales.scales-name
                                                                  ,slave_scales.scales-num)
                                                                                  ).
      os-copy value(out-dir + p-file-name)
              value(digi-out-dir + replace(p-file-name
                    ,entry(4, p-scales.address, '.')
                    ,entry(4, slave_scales.address, '.'))) .
      if os-error <> 0 then do:
        assign
        p-res = p-res + ABS(os-error) + (IF os-error > 0 then 1 else 0)
        p-err-scl-num-list = p-err-scl-num-list + (if abs(os-error) <> 0 then string(slave_scales.scales-num) else '':U) + chr(44)
        p-err-codes-list   =  p-err-codes-list  + (if abs(os-error) <> 0 then string(os-error) else '':U) + chr(44)
        .
      end.
    END.
  end.
  when 'TIGER-SPCT2'
  or
  when 'TIGER-SPCT1'
  then do:
      os-copy value(out-dir + p-file-name)
              value((if p-scales.scales-type = "TIGER-SPCT2"
                     then tiger-spct2-out-dir
                     else tiger-spct1-out-dir)
                     + p-file-name).
      assign
      p-res = p-res + ABS(os-error) + (IF os-error > 0 then 1 else 0)
      p-err-scl-num-list = p-err-scl-num-list + (if abs(os-error) <> 0 then string(p-scales.scales-num) else '':U) + chr(44)
      p-err-codes-list   =  p-err-codes-list  + (if abs(os-error) <> 0 then string(os-error) else '':U) + chr(44)
      .
      FOR EACH slave_scales WHERE
              slave_scales.db-num = p-scales.db-num
           and slave_scales.master = p-scales.scales-num:
        run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input  substitute("&1 Подчиненные весы &2 (№ &3)"
                                                                    ,p-message
                                                                    ,slave_scales.scales-name
                                                                    ,slave_scales.scales-num)
                                                                                    ).
        os-copy value(out-dir + p-file-name)
                value(digi-out-dir + replace(p-file-name
                      ,string(p-scales.scales-num)
                      ,string(slave_scales.scales-num))) .
        if os-error <> 0 then do:
          assign
          p-res = p-res + ABS(os-error) + (IF os-error > 0 then 1 else 0)
          p-err-scl-num-list = p-err-scl-num-list + (if abs(os-error) <> 0 then string(slave_scales.scales-num) else '':U) + chr(44)
          p-err-codes-list   =  p-err-codes-list  + (if abs(os-error) <> 0 then string(os-error) else '':U) + chr(44)
          .
        end.
      END.
      define variable v-current-dir as character no-undo .
      DEFINE VARIABLE SetCurrentDirectoryAResult AS INTEGER NO-UNDO.
      file-info:file-name = ".".
      v-current-dir = file-info:full-pathname.
      define variable v-install-dir as character no-undo .
      file-info:file-name = (if p-scales.scales-type = "TIGER-SPCT2"
                              then tiger-spct2-install-dir
                              else tiger-spct1-install-dir).
      v-install-dir = file-info:full-pathname.
      v-install-dir = (if index(v-install-dir, chr(32)) > 0
                       then substitute('"&1"', v-install-dir)
                       else v-install-dir)
                       .
      define variable v-file-name as character no-undo .
      file-info:file-name =  substitute("&1&2"
                                        ,  (if p-scales.scales-type = "TIGER-SPCT2"
                                            then tiger-spct2-install-dir
                                            else tiger-spct1-install-dir)
                                        , (if p-scales.scales-type = "TIGER-SPCT2"
                                          then (if p-mode = 'ИЗМЕНЕНИЕ':U
                                              then "tigeru-spct2.exe":U
                                              else "tigerd-spct2.exe")
                                          else (if p-mode = 'ИЗМЕНЕНИЕ':U
                                          then "tigeru-spct1.exe":U
                                          else "tigerd-spct1.exe")
                                          )
                                        ).
      v-file-name = file-info:full-pathname.
      v-file-name = (if index(v-file-name, chr(32)) > 0
                       then substitute('"&1"', v-file-name)
                       else v-file-name)
                       .
      tiger:
      do
      on error  undo tiger, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo tiger, return error substitute( "&1. stop", vss-workfile )
      on endkey undo tiger, return error substitute( "&1. endkey", vss-workfile )
      :
       run gbl/synd.p ( input v-install-dir
                      ,input v-file-name
                      ,input substitute("ibs&1.ini", p-scales.scales-num)
                      ,input '':U
                      ,output l-res
                                                                  ) no-error .
      end.
      if l-res > 0 then do:
        run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input  substitute("&1Ошибка при передаче на весы &2 (№ &3) и подчиненные&1&4&1&5"
                                                                    ,chr(10)
                                                                    ,p-scales.scales-name
                                                                    ,p-scales.scales-num
                                                                    ,error-status:get-message(1)
                                                                    ,return-value)
                                                                                    ).
      end.
      p-res = p-res + l-res.
    end.
    otherwise do:
      case p-scales.scales-type:
        when "SHTRIH-M" then do:
          assign
          r_e = (if p-scales.address begins "COM" then "R" else "E")
          com_ip = replace(entry(1, p-scales.address, ":"), "COM", "")
          timeout_port = entry(2, p-scales.address, ":")
          .
          v-cmd-line = substitute('&1 &2 &3 &4 "&5&6"'
                                  ,p-scale-prog
                                  ,r_e
                                  ,com_ip
                                  ,timeout_port
                                  ,out-dir
                                  ,p-file-name).
            run gbl/syn6.p
              (input v-cmd-line
              ,input out-dir + "log.txt"
              ,input "Ждите! Идет передача на весы..."
              ,output chr-res
              ) no-error .
            if error-status:error
            or chr-res > '':u then do:
              l-res = 1.
            end.
        end.
        when "CAS_LP-15v1.6" then do:
            if replace(ENTRY(LOOKUP("CAS_LP-15v1.6", ini-types), ini-progs), "\", "/") = "exe/CAScentre.exe" then do:
                if p-mode = 'ИЗМЕНЕНИЕ':U then do:
                    com_ip = entry(1, p-scales.address, ":").
                    timeout_port = entry(2, p-scales.address, ":").
                    v-cmd-line = com_ip + " " + timeout_port + " 1 0 " + out-dir + p-file-name.
                end.
                else do:
                    v-cmd-line = substitute(" -d &1 < &2&3"
                                  ,p-scales.address
                                  ,out-dir
                                  ,p-file-name).
                    p-scale-prog = ENTRY(LOOKUP("CAS_LP-15v1.6", 'CAS_LP-15,CAS_LP-6,HELMAC_net,HELMAC_model-Z,HELMAC_model-T,CAS_LP-485,BOLET_P-280,BZB-SC515,DIGI_SM-80,CAS_LP-15v1.6,TIGER,MIRA,TIGER2,CAS_LP-16x,DIGI-SM,TIGER-SPCT2,SHTRIH-M,CAS_LP-II,CAS_CL5000J,CAS_CL5000,DIGI_AW-4600_FX,TIGER-SPCT1':U), 'exe/lp15s.exe,exe/lp15s.exe,exe/hcns.exe,exe/hczs.exe,exe/hcts.exe,exe/lp485s.exe,exe/scalex.exe,exe/bzbs.exe,exe/digis.exe,exe/lp16s.exe,exe/metos.exe,exe/miras.exe,exe/meto2s.exe,exe/lp16xs.exe,,,exe/shtrih.exe,exe/lp16s.exe,exe/cl5000js.exe,exe/cl5000s.exe,,':U).
                    p-scale-prog = search(p-scale-prog).
                end.
                run gbl/syn.p ( input p-scale-prog
                    ,input v-cmd-line
                    ,input '':u
                    ,output l-res) no-error.
            end.
            else do:
                v-cmd-line = substitute(" -d &1 < &2&3"
                                  ,p-scales.address
                                  ,out-dir
                                  ,p-file-name).
                run gbl/syn.p ( input p-scale-prog
                    ,input v-cmd-line
                    ,input '':u
                    ,output l-res) no-error.
            end.
        end.
        when "DIGI_AW-4600_FX":U then do:
          os-copy value(out-dir + p-file-name)
                  value(out-dir + "plu0d001.csv").
          v-cmd-line = substitute(' -T "&1&2" ftp://anonymous:anonymous@&3'
                                  ,out-dir
                                  ,"plu0d001.csv"
                                  ,p-scales.address
                                  ).
          run gbl/syn.p ( input p-scale-prog
                    ,input v-cmd-line
                    ,input '':u
                    ,output l-res) no-error.
        end.
        otherwise do:
          case p-scales.scales-type:
            when "CAS_CL5000J"
            then do:
              if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
                p-scale-prog = replace(p-scale-prog, "cl5000js", "cl5000jd").
              end.
            end.
            when "CAS_CL5000"
            then do:
              if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
                p-scale-prog = replace(p-scale-prog, "cl5000s", "cl5000d").
              end.
            end.
          end case.
          v-cmd-line = substitute(" -d &1 < &2&3"
                                  ,p-scales.address
                                  ,out-dir
                                  ,p-file-name).
          run gbl/syn.p ( input p-scale-prog
                        ,input v-cmd-line
                          ,input '':u
                          ,output l-res) no-error.
        end.
      end case.
      assign
      p-res = p-res + ABS(l-res ) + (IF error-status:error then 1 else 0)
      p-err-scl-num-list = p-err-scl-num-list + (if abs(l-res) <> 0 then string(p-scales.scales-num) else '':U) + chr(44)
      p-err-codes-list   =  p-err-codes-list  + (if abs(l-res) <> 0 then string(l-res) else '':U) + chr(44)
      .
      FOR EACH slave_scales WHERE
              slave_scales.master = p-scales.scales-num
          AND slave_scales.db-num = p-scales.db-num
          and slave_scales.sts <> integer('1':U):
        run write-log-and-file in p-log-handle (
                                                  input 1
                                                , input log-file-name
                                                , input 1
                                                , input  substitute("&1 Подчиненные весы &2 (№ &3)"
                                                                    ,p-message
                                                                    ,slave_scales.scales-name
                                                                    ,slave_scales.scales-num)
                                                                                    ).
        case slave_scales.scales-type:
          when "SHTRIH-M" then do:
            assign
            r_e = (if slave_scales.address begins "COM" then "R" else "E")
            com_ip = replace(entry(1, slave_scales.address, ":"), "COM", "")
            timeout_port = entry(2, slave_scales.address, ":")
            .
            v-cmd-line = substitute('&1 &2 &3 &4 "&5&6"'
                                    ,p-scale-prog
                                    ,r_e
                                    ,com_ip
                                    ,timeout_port
                                    ,out-dir
                                    ,p-file-name).
            run gbl/syn6.p
              (input v-cmd-line
              ,input out-dir + "log.txt"
              ,input "Ждите! Идет передача на весы..."
              ,output chr-res
              ) no-error .
            if error-status:error
            or chr-res > '':u then do:
              l-res = 1.
            end.
          end.
          when "DIGI_AW-4600_FX":U then do:
            v-cmd-line = substitute(' -T "&1&2" ftp://anonymous:anonymous@&3'
                                    ,out-dir
                                    ,"plu0d001.csv"
                                    ,slave_scales.address
                                    ).
            run gbl/syn.p ( input p-scale-prog
                      ,input v-cmd-line
                      ,input '':u
                      ,output l-res) no-error.
          end.
        when "CAS_LP-15v1.6" then do:
            if replace(ENTRY(LOOKUP("CAS_LP-15v1.6", ini-types), ini-progs), "\", "/") = "exe/CAScentre.exe" then do:
                if p-mode = 'ИЗМЕНЕНИЕ':U then do:
                    com_ip = entry(1, slave_scales.address, ":").
                    timeout_port = entry(2, slave_scales.address, ":").
                    v-cmd-line = com_ip + " " + timeout_port + " 1 0 " + out-dir + p-file-name.
                end.
                else do:
                    v-cmd-line = substitute(" -d &1 < &2&3"
                                  ,slave_scales.address
                                  ,out-dir
                                  ,p-file-name).
                    p-scale-prog = ENTRY(LOOKUP("CAS_LP-15v1.6", 'CAS_LP-15,CAS_LP-6,HELMAC_net,HELMAC_model-Z,HELMAC_model-T,CAS_LP-485,BOLET_P-280,BZB-SC515,DIGI_SM-80,CAS_LP-15v1.6,TIGER,MIRA,TIGER2,CAS_LP-16x,DIGI-SM,TIGER-SPCT2,SHTRIH-M,CAS_LP-II,CAS_CL5000J,CAS_CL5000,DIGI_AW-4600_FX,TIGER-SPCT1':U), 'exe/lp15s.exe,exe/lp15s.exe,exe/hcns.exe,exe/hczs.exe,exe/hcts.exe,exe/lp485s.exe,exe/scalex.exe,exe/bzbs.exe,exe/digis.exe,exe/lp16s.exe,exe/metos.exe,exe/miras.exe,exe/meto2s.exe,exe/lp16xs.exe,,,exe/shtrih.exe,exe/lp16s.exe,exe/cl5000js.exe,exe/cl5000s.exe,,':U).
                    p-scale-prog = search(p-scale-prog).
                end.
                run gbl/syn.p ( input p-scale-prog
                    ,input v-cmd-line
                    ,input '':u
                    ,output l-res) no-error.
            end.
            else do:
                v-cmd-line = substitute(" -d &1 < &2&3"
                                  ,slave_scales.address
                                  ,out-dir
                                  ,p-file-name).
                run gbl/syn.p ( input p-scale-prog
                    ,input v-cmd-line
                    ,input '':u
                    ,output l-res) no-error.
            end.
        end.
          otherwise do:
            v-cmd-line = substitute(" -d &1 < &2&3"
                                    ,slave_scales.address
                                    ,out-dir
                                    ,p-file-name).
            run gbl/syn.p ( input p-scale-prog
                            ,input v-cmd-line
                            ,input '':u
                            ,output l-res) no-error.
          end.
        end case.
        assign
        p-res = p-res + ABS(l-res ) + (IF error-status:error then 1 else 0)
        p-err-scl-num-list = p-err-scl-num-list + (if abs(l-res) <> 0 then string(slave_scales.scales-num) else '':U) + chr(44)
        p-err-codes-list   =  p-err-codes-list  + (if abs(l-res) <> 0 then string(l-res) else '':U) + chr(44)
        .
      END.
    end.
  END CASE.
  if p-scales.scales-type = "DIGI_AW-4600_FX" then do:
    os-delete value(out-dir + "plu0d001.csv").
  end.
end.
END PROCEDURE.
PROCEDURE create-name-str:
define parameter buffer loc-goods for ub.goods.
define output parameter loc-name-buf1 as character no-undo .
define variable ff as integer no-undo .
define variable v-name as character no-undo .
define variable v-log as logical no-undo .
  loc-name-buf1 = "" .
  v-name = if loc-goods.label-name = "":U
           then  loc-goods.gds-name
           else loc-goods.label-name
           .
  DO ff = 1 TO num-entries( v-name, '"' ) :
      loc-name-buf1 = loc-name-buf1 + entry( ff, v-name, '"' ) .
  END .
END PROCEDURE.
PROCEDURE create-name-str-2:
define parameter buffer loc-goods for ub.goods.
define input parameter p-length as integer no-undo .
define output parameter loc-name-buf1 as character no-undo .
define output parameter loc-name-buf2 as character no-undo .
DEFINE VARIABLE loc-name-buf as character no-undo .
define variable ff as integer no-undo .
define variable v-name as character no-undo .
define variable v-log as logical no-undo .
  loc-name-buf = "" .
  loc-name-buf1 = "" .
  loc-name-buf2 = "" .
  v-name = if loc-goods.label-name = "":U
           then  loc-goods.gds-name
           else loc-goods.label-name
           .
  if p-length <= 0 then do:
    if length(v-name) >= 50 then p-length = length(v-name) / 2.
    else p-length = 30.
  end.
  DO ff = 1 TO num-entries( v-name, '"' ) :
      loc-name-buf = loc-name-buf + entry( ff, v-name, '"' ) .
  END .
  DO ff = 1 TO num-entries( loc-name-buf, ' ' ) :
      if length(loc-name-buf1) + length (entry( ff, loc-name-buf, ' ' ) ) <= p-length
      and not v-log
      then do:
        loc-name-buf1 = loc-name-buf1 + " " + entry( ff, loc-name-buf, ' ' ) .
      end.
      else  do:
       if ff = 1 then do:
          assign
          loc-name-buf1 = chr(32) + substring(loc-name-buf, 1, p-length)
          v-log = yes
          .
        end.
        else do:
          assign
          loc-name-buf2 = loc-name-buf2 + " " + entry( ff, loc-name-buf, ' ' )
          v-log = yes
          .
        end.
      end.
  END .
  if loc-name-buf1  = ""
  then do:
    if loc-name-buf2 = ""
    then
    loc-name-buf1 = chr(32) + substring(replace(loc-goods.gds-name, '"', '':U), 1, p-length) .
    else do:
      assign
      loc-name-buf1 = loc-name-buf2
      loc-name-buf2 = '':U.
    end.
  end.
END PROCEDURE.
procedure create-obj-record :
define parameter buffer buf_goods for ub.goods.
define input parameter p-obj-type like ub.scales-gds.obj-type no-undo .
define input parameter p-obj-code like ub.scales-gds.obj-code no-undo .
define buffer buf_gdsolist for gdsolist.
  do
  on error undo, return error
  :
    find first buf_gdsolist where
              buf_gdsolist.gds-code = buf_goods.gds-code
          AND buf_gdsolist.obj-type = p-obj-type
          and buf_gdsolist.obj-code = p-obj-code  no-error .
    if not avail buf_gdsolist then do:
      create buf_gdsolist.
      buffer-copy buf_goods to buf_gdsolist
      assign
      buf_gdsolist.to-del = no
      buf_gdsolist.obj-type = p-obj-type
      buf_gdsolist.obj-code = p-obj-CODE
      .
    end.
  end.
end procedure.
procedure check-write-scales-status :
define input parameter p-scales-num like ub.scales.scales-num no-undo .
define input parameter p-db-num     like ub.scales.db-num no-undo .
define input parameter p-recid-scales as recid no-undo .
define buffer buf_scales-gds for ub.scales-gds.
define buffer buf_scales for ub.scales.
do
on error undo, return error
:
  if NOT can-find( FIRST buf_scales-gds WHERE
                          buf_scales-gds.scales-num = p-scales-num AND
                          buf_scales-gds.db-num = p-db-num AND
                          buf_scales-gds.to-send = TRUE ) AND
      NOT can-find( FIRST buf_scales-gds WHERE
                          buf_scales-gds.scales-num = p-scales-num AND
                          buf_scales-gds.db-num = p-db-num AND
                          buf_scales-gds.to-del = TRUE ) then do:
    FIND FIRST buf_scales WHERE
                recid( buf_scales ) = p-recid-scales.
    assign
    buf_scales.to-send = FALSE
    .
  end.
end.
end procedure.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure iniscals :
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define output parameter ini-types as character no-undo .
define output parameter ini-progs as character no-undo .
define output parameter rnd-znak as integer no-undo init 2.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
v-tth = buffer thbjattr_thbj-attr:table-handle .
do
on error undo, return error return-value
:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type32 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type32
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type32 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type32
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
conf-par = ?.
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
    input "get":U
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  'scale-inf':U
  ,input  "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , INPUT-OUTPUT table-handle v-tth
  ) no-error .
IF error-status:error then do:
    message
    substitute("Ошибка при получении настроек, необъодимых для работы весов НА ОБЪЕКТЕ &1&2:&3&4 &5"
            , p-obj-type
            , p-obj-code
            , chr(10)
            , error-status:get-message(1)
            , return-value )
    view-as alert-box error .
    undo, return error .
end.
assign
ini-progs = ?
ini-types = ?
.
for each thbjattr_thbj-attr where
        thbjattr_thbj-attr.obj-type = p-obj-type
    and thbjattr_thbj-attr.obj-code = p-obj-code
    and thbjattr_thbj-attr.upper-prop-code = 'scale-inf':U
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  case thbjattr_thbj-attr.prop-code:
    when 'scales-type':U then do:
      ini-types = thbjattr_thbj-attr.property-value-character.
    end.
    when 'scales-pr':U then do:
      ini-progs = thbjattr_thbj-attr.property-value-character.
    end.
  end case.
end.
if ini-types = ? then do:
  run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибка! Не определены типы весов&1" +
                           "АРМ Администратор, Список фирм (Справочник магазинов), Измен. параметры, Параметры работы с весами"
                           , chr(10)
                          )
                                          ).
  assign
  v-view-log = yes.
  return error .
end.
if ini-progs = ? then do:
  run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибка! Не определены программы для работы с весами&1" +
                           "АРМ Администратор, Список фирм (Справочник магазинов), Измен. параметры, Параметры работы с весами"
                           , chr(10)
                          )
                                          ).
  assign
  v-view-log = yes.
  return error .
end.
IF NUm-ENTRIES(ini-types) > NUm-ENTRIES(ini-progs) then do:
  run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибка! Не определены программы для работы с весами для некоторых типов весов&1" +
                           "АРМ Администратор, Список фирм (Справочник магазинов), Измен. параметры, Параметры работы с весами"
                           , chr(10)
                          )
                                          ).
  assign
  v-view-log = yes.
  return error .
end.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
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
      if thbjattr_thbj-attr.prop-code = 'rnd-znk':U then rnd-znak = thbjattr_thbj-attr.property-value-integer .
  end.
end.
end procedure.
assign
p-obj-type = entry(1, p-parameter, chr(4) )
p-obj-code = integer(entry(2, p-parameter, chr(4) ))
rec-t-scales = (if entry(3, p-parameter, chr(4) ) = chr(63) then ? else integer(entry(3, p-parameter, chr(4) )))
sendoption = entry(4, p-parameter, chr(4))
send-rid-list = entry(5, p-parameter, chr(4) )
ObjectOption = entry(6, p-parameter, chr(4) )
qnty-buf = integer(entry(7, p-parameter, chr(4) ))
no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При передаче информации на весы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action35   as character no-undo .
  define variable v-printed35       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При передаче информации на весы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'send-cd.txt')
    ,input  7
    ,output v-user-action35
    ,output v-printed35
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'send-cd.txt').
end.
                        return.
end.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_scales_sending':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
if NOT glog then do:
    return error.
end.
if v-cntxt-db-num <> v-cntxt-db-num-obj then do:
  message
  substitute("Невозможна Передача измененных товаров на все весы в чужой БД&1" +
              "БД текущего объекта &2, текущая БД &3"
              , chr(10)
              , v-cntxt-db-num-obj
              , v-cntxt-db-num)
 view-as alert-box error .
 return.
end.
run  iniscals  in this-procedure (
                                         input  p-obj-type
                                        ,input  p-obj-code
                                        ,output ini-types
                                        ,output ini-progs
                                        ,output rnd-znak
                                        ) no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при получении параметров работы с весами&1&2&1&3"
                        , chr(10)
                        , return-value
                        , error-status:get-message(1)
                        , chr(10)
                        , return-value
                        )
                                        ).
  assign
  v-view-log = yes.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При передаче информации на весы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action39   as character no-undo .
  define variable v-printed39       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При передаче информации на весы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'send-cd.txt')
    ,input  7
    ,output v-user-action39
    ,output v-printed39
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'send-cd.txt').
end.
                        return.
end.
CASE sendoption:
  when "changed":u then do:
    FOR EACH buf_scales WHERE
            buf_scales.db-num = v-cntxt-db-num
      AND buf_scales.to-send = yes
      AND buf_scales.master = 0
      by buf_scales.scales-num
   on error undo, next
   on stop undo, next :
      if rec-t-scales <> ? and rec-t-scales <> recid(buf_scales) then NEXT.
      if buf_scales.sts = integer('1':U) then do:
        if buf_scales.master = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Попытка пересылки товаров на весы №&1 &2,&4имеющие статус &3"
                                , buf_scales.scales-num
                                , buf_scales.scales-name
                                , entry (lookup (STRING(buf_scales.sts), '0,1,50,99':U), 'тек,удал,блок,удаление':U)
                                , chr(10)
                                )).
          assign
          v-view-log = yes
          .
        end.
        next.
      end.
      if rec-t-scales = ? then do:
        run set-title in p-log-handle (
              input substitute("Передача данных по измененным товарам (&1&2) на весы &3"
                              , p-obj-type
                              , p-obj-code
                              , buf_scales.scales-name)).
      end.
      RUN general-send in this-procedure (input parparentproc                                                                                     ,input p-parent-handle                                                                                  ,input p-log-handle                                                                                     ,input p-obj-type                                                                                       ,input p-obj-code                                                                                       ,buffer buf_scales                                                                                      ,input sendoption                                                                                       ,input send-rid-list                                                                                    ,input objectoption) no-error.                                      if error-status:error then do:                                                                            run write-log-and-file in p-log-handle (                                                                      input 1                                                                                               , input log-file-name                                                                                   , input 1                                                                                               , input substitute( "!!!Ошибки при передаче данных по измененным товарам (&1&2) на весы &3:&4&5&4&6"                             , p-obj-type                                                                                                   , p-obj-code                                                                                                   , buf_scales.scales-name                                                                                       , chr(10)                                                                                                , error-status:get-message(1)                                                                                  , return-value                                                                                                 )                                                                                                                              ).                                                                       assign                                                                                                         v-view-log = yes                                                                                               .                                                                                                            end.
    end.
  end.
  otherwise do:
    FOR EACH buf_scales WHERE
        buf_scales.master = 0
    AND buf_scales.db-num = v-cntxt-db-num
    by buf_scales.scales-num
    on error undo, next
    on stop undo, next :
      if rec-t-scales <> ? and rec-t-scales <> recid(buf_scales) then NEXT.
      if buf_scales.sts = integer('1':U) then do:
        if buf_scales.master = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Попытка пересылки товаров на весы №&1 &2,&4имеющие статус &3"
                                , buf_scales.scales-num
                                , buf_scales.scales-name
                                , entry (lookup (STRING(buf_scales.sts), '0,1,50,99':U), 'тек,удал,блок,удаление':U)
                                , chr(10)
                                )).
          assign
          v-view-log = yes
          .
        end.
        next.
      end.
      RUN general-send in this-procedure (input parparentproc                                                                                     ,input p-parent-handle                                                                                  ,input p-log-handle                                                                                     ,input p-obj-type                                                                                       ,input p-obj-code                                                                                       ,buffer buf_scales                                                                                      ,input sendoption                                                                                       ,input send-rid-list                                                                                    ,input objectoption) no-error.                                      if error-status:error then do:                                                                            run write-log-and-file in p-log-handle (                                                                      input 1                                                                                               , input log-file-name                                                                                   , input 1                                                                                               , input substitute( "!!!Ошибки при передаче данных по измененным товарам (&1&2) на весы &3:&4&5&4&6"                             , p-obj-type                                                                                                   , p-obj-code                                                                                                   , buf_scales.scales-name                                                                                       , chr(10)                                                                                                , error-status:get-message(1)                                                                                  , return-value                                                                                                 )                                                                                                                              ).                                                                       assign                                                                                                         v-view-log = yes                                                                                               .                                                                                                            end.
    end.
  end.
END CASE.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При передаче информации на весы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action41   as character no-undo .
  define variable v-printed41       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При передаче информации на весы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + 'send-cd.txt')
    ,input  7
    ,output v-user-action41
    ,output v-printed41
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
if not v-view-log and search("cdviewlg_do-not-delete-log-file.txt") = ? then do:
  OS-DELETE value(string("./":U) + 'send-cd.txt').
end.
                        return.
