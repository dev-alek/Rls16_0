block-level on error undo, throw.
define input parameter p-parent-proc as widget-handle no-undo .
define input parameter p-rec-invent  as recid         no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 0ec5d11e52eb, 2015, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Wed Sep 18 21:05:06 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-orsvxl.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-orsvxl.p $":U .
define variable vss-description as character no-undo initial "Сличительная ведомость результатов инвентаризации нефтепродуктов (Орел)":U .
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
define new global shared variable g#lib-calc as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo .
define variable g#log         as logical no-undo .
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define variable vss-include-info5 as character no-undo format "x(65)":U
  initial "@(#)$Workfile$ $Revision$":U .
define stream excel-line .
define stream excel-cell .
define temp-table temp_cell-data no-undo
  field data-key   as character
  field data-value as character
  index pi         is primary   unique data-key
.
define temp-table temp_line-data no-undo
  field data-key   as character
  field xl-line-id as integer
  field Num        as integer
  field Name       as character
  field artic      as character
  field locate     as character
  field EdIzm      as character
  field Price      as character
  field ExtraQnty  as character
  field ExtraSum   as character
  field MissQnty   as character
  field MissSum    as character
  field LossQnty   as character
  field LossSum    as character
  field NormQnty   as character
  field NormSum    as character
  field XcalcQnty  as character
  field XcalcSum   as character
  field LcalcQnty  as character
  field LcalcSum   as character
  index pi         is primary   unique xl-line-id
.
define variable v-r-orsvxl-current-data-row as integer   no-undo .
define variable v-r-orsvxl-cell-file-name   as character no-undo .
define variable v-r-orsvxl-data-file-name   as character no-undo .
procedure r-orsvxl-init :
  define buffer buf_temp_cell-data for temp_cell-data .
  define buffer buf_usr-flt        for ubflt.usr-flt .
  do
  for buf_temp_cell-data
    , buf_usr-flt
  on error undo, return error
  :
    assign
      v-r-orsvxl-current-data-row = 0
    .
    run gbl/_tmpfile.p
      ( input "xd"
      , input ".txt"
      , output v-r-orsvxl-data-file-name
      ) .
    output stream excel-line to value( v-r-orsvxl-data-file-name ) .
    run gbl/_tmpfile.p
      ( input "xc"
      , input ".txt"
      , output v-r-orsvxl-cell-file-name
      ) .
    output stream excel-cell to value( v-r-orsvxl-cell-file-name ) .
    run r-orsvxl-write-cell-data in this-procedure
      ( input "valutCode":U
      , input "0":U
      ) .
    run r-orsvxl-write-cell-data in this-procedure
      ( input "columnList":U
      , input "Num,Name,artic,locate,EdIzm,Price,ExtraQnty,ExtraSum,MissQnty,MissSum,":U
      +       "LossQnty,LossSum,NormQnty,NormSum,XcalcQnty,XcalcSum,LcalcQnty,LcalcSum":U
      ) .
    run r-orsvxl-write-cell-data in this-procedure
      ( input "columnType":U
      , input "I,S,S,I,S,C,D,C,D,C,D,C,D,C,D,C,D,C":U
      ) .
    run r-orsvxl-write-cell-data in this-procedure
      ( input "columnAmount":U
      , input "18":U
      ) .
  end.
end procedure.
procedure r-orsvxl-close :
  do
  on error undo, return error
  :
    output stream excel-line close .
    output stream excel-cell close .
    output to value( string( session :temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append .
    export "exe/t33np_97.xlt":U .
    export "exe/t_97.bas":U .
    export v-r-orsvxl-cell-file-name .
    export v-r-orsvxl-data-file-name .
    output close .
  end.
end procedure.
procedure r-orsvxl-write-cell-data :
  define input parameter p-data-key   as character no-undo .
  define input parameter p-data-value as character no-undo .
  define buffer buf_temp_cell-data for temp_cell-data .
  do
  for buf_temp_cell-data
  on error undo, return error
  :
    find first buf_temp_cell-data where
               buf_temp_cell-data.data-key = p-data-key no-error.
    if not available buf_temp_cell-data
    then do:
      create buf_temp_cell-data .
      assign
        buf_temp_cell-data.data-key = p-data-key
      .
    end.
    assign
      buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
      buf_temp_cell-data.data-key   chr(9)
      buf_temp_cell-data.data-value chr(10)
    .
  end.
end procedure.
procedure r-orsvxl-write-line-data :
  define input parameter p-Num       as integer   no-undo .
  define input parameter p-Name      as character no-undo .
  define input parameter p-artic     as character no-undo .
  define input parameter p-locate    as character no-undo .
  define input parameter p-EdIzm     as character no-undo .
  define input parameter p-Price     as character no-undo .
  define input parameter p-ExtraQnty as character no-undo .
  define input parameter p-ExtraSum  as character no-undo .
  define input parameter p-MissQnty  as character no-undo .
  define input parameter p-MissSum   as character no-undo .
  define input parameter p-LossQnty  as character no-undo .
  define input parameter p-LossSum   as character no-undo .
  define input parameter p-NormQnty  as character no-undo .
  define input parameter p-NormSum   as character no-undo .
  define input parameter p-XcalcQnty as character no-undo .
  define input parameter p-XcalcSum  as character no-undo .
  define input parameter p-LcalcQnty as character no-undo .
  define input parameter p-LcalcSum  as character no-undo .
  define buffer buf_temp_line-data for temp_line-data .
  do
  for buf_temp_line-data
  on error undo, return error
  :
    for each buf_temp_line-data
    :
      delete buf_temp_line-data .
    end.
    create buf_temp_line-data .
    assign
      v-r-orsvxl-current-data-row = v-r-orsvxl-current-data-row + 1
    .
    assign
      buf_temp_line-data.data-key   = "LD":U
      buf_temp_line-data.xl-line-id = v-r-orsvxl-current-data-row
      buf_temp_line-data.Num        = p-Num
      buf_temp_line-data.Name       = p-Name
      buf_temp_line-data.artic      = p-artic
      buf_temp_line-data.locate     = p-locate
      buf_temp_line-data.EdIzm      = p-EdIzm
      buf_temp_line-data.Price      = p-Price
      buf_temp_line-data.ExtraQnty  = p-ExtraQnty
      buf_temp_line-data.ExtraSum   = p-ExtraSum
      buf_temp_line-data.MissQnty   = p-MissQnty
      buf_temp_line-data.MissSum    = p-MissSum
      buf_temp_line-data.LossQnty   = p-LossQnty
      buf_temp_line-data.LossSum    = p-LossSum
      buf_temp_line-data.NormQnty   = p-NormQnty
      buf_temp_line-data.NormSum    = p-NormSum
      buf_temp_line-data.XcalcQnty  = p-XcalcQnty
      buf_temp_line-data.XcalcSum   = p-XcalcSum
      buf_temp_line-data.LcalcQnty  = p-LcalcQnty
      buf_temp_line-data.LcalcSum   = p-LcalcSum
    .
    put stream excel-line unformatted
      buf_temp_line-data.data-key  chr(9)
      buf_temp_line-data.Num       chr(9)
      buf_temp_line-data.Name      chr(9)
      buf_temp_line-data.artic     chr(9)
      buf_temp_line-data.locate    chr(9)
      buf_temp_line-data.EdIzm     chr(9)
      buf_temp_line-data.Price     chr(9)
      buf_temp_line-data.ExtraQnty chr(9)
      buf_temp_line-data.ExtraSum  chr(9)
      buf_temp_line-data.MissQnty  chr(9)
      buf_temp_line-data.MissSum   chr(9)
      buf_temp_line-data.LossQnty  chr(9)
      buf_temp_line-data.LossSum   chr(9)
      buf_temp_line-data.NormQnty  chr(9)
      buf_temp_line-data.NormSum   chr(9)
      buf_temp_line-data.XcalcQnty chr(9)
      buf_temp_line-data.XcalcSum  chr(9)
      buf_temp_line-data.LcalcQnty chr(9)
      buf_temp_line-data.LcalcSum  chr(10)
    .
  end.
end procedure.
procedure r-orsvxl-run-excel :
  define input parameter p-header-filename as character no-undo .
  define input parameter p-data-filename   as character no-undo .
  define variable v-template-file-name as character no-undo .
  define variable v-vb-file-name       as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  for buf_temp-param
  on error undo, return error
  :
    create buf_temp-param.
    assign
      v-template-file-name = search( "exe/t33np_97.xlt" )
      v-vb-file-name       = search( "exe/t_97.bas" )
    .
    if v-template-file-name = ? or
       v-template-file-name = "":U
    then do:
      message
        "Ошибка имени файла шаблона."
      view-as alert-box error .
    end.
    if v-vb-file-name = ? or
       v-vb-file-name = "":U
    then do:
      message
        "Ошибка имени файла кода обработки."
      view-as alert-box error .
    end.
    run paramls-write in this-procedure
      ( input "template":U
      , input "template-file-name":U
      , input v-template-file-name
      ) .
    run paramls-write in this-procedure
      ( input "template":U
      , input "vb-file-name":U
      , input v-vb-file-name
      ) .
    run paramls-write in this-procedure
      ( input "data":U
      , input "data-header-filename":U
      , input p-header-filename
      ) .
    run paramls-write in this-procedure
      ( input "data":U
      , input "data-filename":U
      , input p-data-filename
      ) .
    run gbl/macroxlt.p
      ( input-output table buf_temp-param
      ) no-error .
    if error-status :error
    then do:
      message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
              "Ошибка создания файла Excel."  skip( 0 )
              return-value                    skip( 0 )
              trim( error-status :get-message( 1 ) )
              trim( error-status :get-message( 2 ) )
              trim( error-status :get-message( 3 ) )
      view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable ptrlprop-denstclc      as character no-undo initial 'shft_rvs-inc':U .
define variable ptrlprop-inpptrl       as character no-undo initial 'weight':U .
define variable ptrlprop-expptrl       as character no-undo initial 'volume':U .
define variable ptrlprop-autopump      as logical   no-undo initial false .
define variable ptrlprop-avtinvpm      as logical   no-undo initial false .
define variable ptrlprop-rvsnmter      as logical   no-undo initial false .
define variable ptrlprop-olddens       as logical   no-undo initial false .
define variable ptrlprop-invclipt      as integer   no-undo initial ? .
define variable ptrlprop-algrvspt      as integer   no-undo initial 1 .
define variable ptrlprop-temp-for-pomi as integer   no-undo initial 1 .
define variable ptrlprop-algoincome as integer no-undo init 0.
define variable ptrlprop-mand-choice-autocar as logical no-undo init false.
define variable ptrlprop-Delta-mass-horiz      as character no-undo .
define variable ptrlprop-Delta-mass-vert       as character no-undo .
define variable ptrlprop-calc-free-vol as logical no-undo init false.
define variable ptrlprop-calc-free-vol-sug as logical no-undo init false.
define variable ptrlprop-trn-reas-sug as logical no-undo init true.
define variable ptrlprop-rvd-own-nb as logical no-undo init false.
define variable ptrlprop-qr-scan-time as integer no-undo init 5000 .
define variable ptrlprop-block-nozzle as logical no-undo init false.
define variable ptrlprop-timeout-block-nozzle as integer no-undo init 5 .
define variable ptrlprop-autopump-skip-time as integer no-undo init 0 .
procedure get-ptrl-prop :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (get-ptrl-prop). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-ptrl-prop). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-ptrl-prop). endkey", vss-workfile )
  :
    define variable par-type          as character no-undo.
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    for each thbjattr_thbj-attr
    :
      delete thbjattr_thbj-attr .
    end.
    run adm/shattri.p
      ( input "get":U
      , input p-obj-type
      , input p-obj-code
      , input 'petrol':U
      , input  ""
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , input-output table thbjattr_thbj-attr
      ) no-error .
    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :
      case thbjattr_thbj-attr.prop-code :
        when 'denstclc':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'expptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'inpptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'autopump':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'rvsnmter':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'avtinvpm':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'invclipt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'olddens':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'algrvspt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'temp-for-pomi':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'algoincome':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'mand-choice-autocar':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-block-nozzle = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'timeout-block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-timeout-block-nozzle = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'Delta-mass-horiz':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'Delta-mass-vert':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'calc-free-vol':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'calc-free-vol-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'trn-reas-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-trn-reas-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
              when 'rvd-own-nb':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvd-own-nb = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'qr-scan-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-qr-scan-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'autopump-skip-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-autopump-skip-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
      end case.
      delete thbjattr_thbj-attr .
    end.
  end.
  return .
end procedure.
define variable v-host-name      as character no-undo .
define variable p-host-code      as integer   no-undo .
define variable v-unit-name      as character no-undo .
define variable v-doc-num        as character no-undo .
define variable dprice-sale      as decimal   no-undo .
define variable droad-tax        as decimal   no-undo .
define variable dexcise          as decimal   no-undo .
define variable dcurr-price      as decimal   no-undo .
define variable dExtra-qnty      as decimal   no-undo .
define variable dExtra-sum       as decimal   no-undo .
define variable dMiss-qnty       as decimal   no-undo .
define variable dMiss-sum        as decimal   no-undo .
define variable dLoss-curr-qnty  as decimal   no-undo .
define variable dLoss-qnty       as decimal   no-undo .
define variable dLoss-sum        as decimal   no-undo .
define variable dNorm-qnty       as decimal   no-undo .
define variable dNorm-sum        as decimal   no-undo .
define variable dXcalc-qnty      as decimal   no-undo .
define variable dXcalc-sum       as decimal   no-undo .
define variable dLcalc-qnty      as decimal   no-undo .
define variable dLcalc-sum       as decimal   no-undo .
define variable tExtra-qnty      as decimal   no-undo .
define variable tExtra-sum       as decimal   no-undo .
define variable tMiss-qnty       as decimal   no-undo .
define variable tMiss-sum        as decimal   no-undo .
define variable tLoss-qnty       as decimal   no-undo .
define variable tLoss-sum        as decimal   no-undo .
define variable tNorm-qnty       as decimal   no-undo .
define variable tNorm-sum        as decimal   no-undo .
define variable tXcalc-qnty      as decimal   no-undo .
define variable tXcalc-sum       as decimal   no-undo .
define variable tLcalc-qnty      as decimal   no-undo .
define variable tLcalc-sum       as decimal   no-undo .
define variable xExtra-qnty      as decimal   no-undo .
define variable xExtra-sum       as decimal   no-undo .
define variable xMiss-qnty       as decimal   no-undo .
define variable xMiss-sum        as decimal   no-undo .
define variable xLoss-qnty       as decimal   no-undo .
define variable xLoss-sum        as decimal   no-undo .
define variable xNorm-qnty       as decimal   no-undo .
define variable xNorm-sum        as decimal   no-undo .
define variable xXcalc-qnty      as decimal   no-undo .
define variable xXcalc-sum       as decimal   no-undo .
define variable xLcalc-qnty      as decimal   no-undo .
define variable xLcalc-sum       as decimal   no-undo .
define variable d_FactRest       as decimal   no-undo .
define variable d_BookRest       as decimal   no-undo .
define variable d_pcnt           as decimal   no-undo .
define variable invent-fo        as decimal   no-undo .
define variable t_inv-date       as date      no-undo .
define variable j_LineCount      as integer   no-undo .
define variable prc-density      as decimal   no-undo .
define variable v-normal-wastage as decimal   no-undo .
define variable v-type           as character no-undo .
define buffer bf_trn-doc   for ub.trn-doc  .
define buffer bf_rvs-doc   for ub.rvs-doc  .
define buffer bf_rvs-line  for ub.rvs-line .
define buffer bf_goods     for ub.goods    .
define buffer bf_object    for ub.clients  .
define buffer bf_doc-line  for ub.doc-line .
define buffer bf_doc-pl    for ub.doc-pl   .
define buffer bf_inv-line  for ub.inv-line .
define buffer bf_place     for ub.place    .
define buffer buf_sale-doc for ub.sale-doc .
FUNCTION MonthNameRusCase RETURNS CHARACTER ( INPUT i-month AS INTEGER, INPUT i-case AS INTEGER ) :
  DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.
  RUN get-month-name-case IN THIS-PROCEDURE ( INPUT i-month, INPUT i-case, OUTPUT v-name ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE v-name ).
END FUNCTION.
PROCEDURE get-month-name-case :
  DEFINE  INPUT PARAMETER p-month AS INTEGER   NO-UNDO.
  DEFINE  INPUT PARAMETER p-case  AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-name  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-list AS CHARACTER NO-UNDO EXTENT 6 INITIAL
    [ "Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь",
      "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря",
      "Январю,Февралю,Марту,Апрелю,Маю,Июню,Июлю,Августу,Сентябрю,Октябрю,Ноябрю,Декабрю",
      "Январь,Февраль,Март,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь",
      "Январем,Февралем,Мартом,Апрелем,Маем,Июнем,Июлем,Августом,Сентябрем,Октябрем,Ноябрем,Декабрем",
      "Январе,Феврале,Марте,Апреле,Мае,Июне,Июле,Августе,Сентябре,Октябре,Ноябре,Декабре"              ].
  DO ON ERROR UNDO, RETURN ERROR :
    IF p-month < 1 OR p-month > 12 OR
       p-case  < 1 OR p-case  >  6 THEN DO:
      ASSIGN p-name = ?.
    END.                           ELSE DO:
      ASSIGN p-name = ENTRY( p-month, v-list[ p-case ] ).
    END.
  END.
END PROCEDURE.
FUNCTION Sparse RETURNS CHARACTER ( INPUT p-instring AS CHARACTER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.
  RUN get-sparsed-string IN THIS-PROCEDURE ( INPUT p-instring, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN p-instring ELSE v-outstring ).
END FUNCTION.
PROCEDURE get-sparsed-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.
  DEFINE VARIABLE jj AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    DO jj = 1 TO LENGTH( p-instring ) :
      ASSIGN p-outstring = p-outstring + ( IF p-outstring = "":U THEN "":U ELSE " ":U ) + SUBSTRING( p-instring, jj, 1 ).
    END.
    ASSIGN p-outstring = CAPS( TRIM( p-outstring ) ).
  END.
END PROCEDURE.
function OutDec returns character ( input p-sum  as decimal
                                  , input p-hide as logical ) :
  define variable v-sum as character no-undo .
  run dec2char in this-procedure
    (  input p-sum
    ,  input p-hide
    , output v-sum
    ) no-error.
  return ( if error-status :error then '':U else v-sum ) .
end function.
function CenterLine returns character ( input p-in-string as character
                                      , input p-rep-width as integer ) :
  define variable v-out-string as character no-undo .
  run get-center-line in this-procedure
    (  input p-in-string
    ,  input p-rep-width
    , output v-out-string
    ) no-error .
  return ( if error-status :error then '':U else v-out-string ) .
end function.
function OutQty returns character ( input p-qty  as decimal
                                  , input p-hide as logical ) :
  define variable v-qty as character no-undo .
  run get-dec-string in this-procedure
    (  input p-qty
    ,  input 3
    ,  input p-hide
    , output v-qty
    ) no-error.
  return ( if error-status :error then '':U else v-qty ) .
end function.
function OutSum returns character ( input p-sum  as decimal
                                  , input p-hide as logical ) :
  define variable v-sum as character no-undo .
  run get-dec-string in this-procedure
    (  input p-sum
    ,  input 2
    ,  input p-hide
    , output v-sum
    ) no-error.
  return ( if error-status :error then '':U else v-sum ) .
end function.
define stream s-out .
do
on error undo, return error return-value
:
  run WaitFram-Show in this-procedure
    ( input 'Идет формирование отчета, ждите...'
    ) .
  run get-report-num  in p-parent-proc
    (
      output g#report-num
    ) .
  run get-quest-print in p-parent-proc
    (
      output g#quest-print
    ) .
  find first bf_trn-doc no-lock where
      recid( bf_trn-doc ) = p-rec-invent no-error .
  if not available bf_trn-doc
  then do:
    run waitfram-hide in this-procedure .
    message substitute( 'Не найден документ с идентификатором &1.'
                      , p-rec-invent
                      )
    view-as alert-box error .
    undo, return error .
  end.
  if bf_trn-doc.doc-type     <> 'инв':U or
     bf_trn-doc.ext-doc-type <> 'vt':U
  then do:
    run waitfram-hide in this-procedure .
    message
      'Данная форма только для печати инвентаризации.'
    view-as alert-box error .
    undo, return error .
  end.
  find first bf_rvs-doc no-lock where
             bf_rvs-doc.rvs-code = bf_trn-doc.out-code no-error .
  if not available bf_rvs-doc
  then do:
    run waitfram-hide in this-procedure .
    message substitute( 'Не найдена сверка к документу "&1".'
                      , bf_trn-doc.doc-code
                      )
    view-as alert-box error .
    undo, return error .
  end.
  if bf_rvs-doc.rvs-type <> 'контроль':U
  then do:
    run waitfram-hide in this-procedure .
    message substitute( 'Сверка имеет тип "&1", а должен быть "&2".'
                      , bf_rvs-doc.rvs-type
                      , 'контроль':U
                      )
    view-as alert-box error .
    undo, return error .
  end.
  find first bf_object no-lock where
             bf_object.obj-type = bf_trn-doc.obj-type and
             bf_object.obj-code = bf_trn-doc.obj-code .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output p-host-code
  ,output v-host-name
  ) no-error .
  if error-status :error
  then do:
    run waitfram-hide in this-procedure .
    message
      'Не могу определить текущую фирму.'
    view-as alert-box error .
    undo, return error .
  end.
  if bf_trn-doc.host-code <> p-host-code
  then do:
    run waitfram-hide in this-procedure .
    message
      'Ошибка определения текущей фирмы.'
    view-as alert-box error .
    undo, return error .
  end.
  run clc-pcnt in this-procedure
    ( output d_pcnt
    ) no-error .
  if error-status :error
  then do:
    run waitfram-hide in this-procedure .
    undo, return error .
  end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input bf_trn-doc.obj-type
  , input bf_trn-doc.obj-code
  ) .
  assign
    t_inv-date = ( if bf_trn-doc.status_ = 'факт':U then bf_trn-doc.fact-date else bf_trn-doc.doc-date )
  .
output stream s-out to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  put stream s-out unformatted
    'Госкомнефтепродукт_________________________________                                                                                                                                                                                                                                                                             Форма № 33-НП' skip
    substring( string( v-host-name + fill( '_', 40 ), "x(40)":U ), 1, 40 ) +
                                            ' управление                                                                                                                                                                                                                                                      Утверждена Госкомнефтепродуктом СССР' skip
    '________________________________________ нефтебаза                                                                                                                                                                                                                                                          15 августа 1985 г. № 06/21-8  446' skip
    '  АЗС № ' + substring( trim( string( bf_trn-doc.obj-code, ">>>>>>>>9":U ) ) + fill( '_', 32 ), 1, 32 )                                                                                                                                                                                                                                         skip( 2 )
    CenterLine( Sparse( 'СЛИЧИТЕЛЬНАЯ ВЕДОМОСТЬ' ), 338 )                                                                                                                                                                                                                                                                                skip
    CenterLine( 'результатов инвентаризации нефтепродуктов', 338 )                                                                                                                                                                                                                                                                       skip
    CenterLine( substitute( 'на "&1" &2 &3 г.'
                          , day( t_inv-date )
                          , MonthNameRusCase( month( t_inv-date ), 2 )
                          , year( t_inv-date )
                          )
              , 338
              )                                                                                                                                                                                                                                                                                                                                     skip
    CenterLine( 'На основании распоряжения № ___ от "___"______________20__г. проведена инвентаризация фактического наличия,', 338 )                                                                                                                                                                                                     skip
    CenterLine( ' находящихся на ответственном хранении у _______________________________________________________________', 338 )                                                                                                                                                                                                        skip
    CenterLine( '                                          (должность)                                  (фамилия, и.,о.) ', 338 )                                                                                                                                                                                                        skip
    CenterLine( 'Снятие остатков: начато "____"____________20___г. и окончено "___"________20__г. При инвентаризации установлено следущее:', 338 )                                                                                                                                                                                       skip( 1 )
  .
  put stream s-out unformatted
    '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' skip
    '   :               :       :           :     :        :          Результаты инвентаризации           :                                      Пересортица                                      :      Отклонение с учетом пересортицы      :                    :     Учитывается     :                                      :                      ' skip
    '   :               :       :  Тип и №  : Ед. :  Цена  :---------------------:------------------------:-------------------------------------------:-------------------------------------------:---------------------:---------------------: Естественная убыль : недостача в пределах:       Приходуются окончательные      :     Окончательные    ' skip
    ' № :  Наименование :  Код  :   резер-  :изме-:   за   :       излишек       :        недостач        :   излишки, зачтенные в покрытии недостач  :      недостачи, покрытытые излишками      :       излишек       :       недостач      :                    :норм погр. изм. массы:                излишки               :       недостачи      ' skip
    'п/п: нефтепродукта :       :   вуара   :рения:  ед-цу :------------:--------:------------:-----------:------------:--------:---------------------:------------:--------:---------------------:------------:--------:------------:--------:------------:-------:------------:--------:------------:---------:---------------:------------:---------' skip
    '   :               :       :           :     :        : количество :  сумма : количество :   сумма   : количество :  сумма :пор.№ зачтен.недостач: количество :  сумма :пор.№ зачтен.недостач: количество :  сумма : количество :  сумма : количество : сумма : количество :  сумма : количество :  сумма  :на баланс счет№: количество :  сумма  ' skip
    '---:---------------:-------:-----------:-----:--------:------------:--------:------------:-----------:------------:--------:---------------------:------------:--------:---------------------:------------:--------:------------:--------:------------:-------:------------:--------:------------:---------:---------------:------------:---------' skip
    ' 1 :       2       :   3   :     4     :  5  :    6   :      7     :    8   :      9     :    10     :     11     :   12   :          13         :     14     :   15   :          16         :     17     :   18   :     19     :   20   :     21     :   22  :     23     :   24   :     25     :    26   :       27      :     28     :    29   ' skip
    '---:---------------:-------:-----------:-----:--------:------------:--------:------------:-----------:------------:--------:---------------------:------------:--------:---------------------:------------:--------:------------:--------:------------:-------:------------:--------:------------:---------:---------------:------------:---------' skip
  .
  run r-orsvxl-init            in this-procedure .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "h_OwnFirm":U
    , input ( trim( v-host-name ) + " ":U + "управление" )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "h_ObjCode":U
    , input trim( string( bf_trn-doc.obj-code, ">>>>>>>>9":U ) )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "h_FactDate":U
    , input substitute( 'на "&1" &2 &3 г.'
                      , day( t_inv-date )
                      , MonthNameRusCase( month( t_inv-date ), 2 )
                      , year( t_inv-date )
                      )
    ) .
  assign
    tExtra-qnty = 0.00
    tExtra-sum  = 0.00
    tMiss-qnty  = 0.00
    tMiss-sum   = 0.00
    tLoss-qnty  = 0.00
    tLoss-sum   = 0.00
    tNorm-qnty  = 0.00
    tNorm-sum   = 0.00
    tXcalc-qnty = 0.00
    tXcalc-sum  = 0.00
    tLcalc-qnty = 0.00
    tLcalc-sum  = 0.00
    j_LineCount = 0
  .
  for each  bf_rvs-line no-lock where
            bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code  and
            bf_rvs-line.obj-type = bf_rvs-doc.obj-type  and
            bf_rvs-line.obj-code = bf_rvs-doc.obj-code
    , first bf_goods    no-lock where
            bf_goods.gds-code    = bf_rvs-line.gds-code
   break by bf_rvs-line.gds-code
         by bf_rvs-line.pl-code
  :
    if first-of( bf_rvs-line.gds-code )
    then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_rvs-line.obj-type
  ,input  bf_rvs-line.obj-code
  ,input  bf_rvs-line.gds-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output v-doc-num
  ,output dprice-sale
  ,output droad-tax
  ,output dexcise
  ) no-error .
      if error-status :error
      then do:
        run waitfram-hide in this-procedure .
        message
          'Не могу определить текущие продажные цены.'
        view-as alert-box error .
        undo, return error .
      end.
    end.
    assign
      dLoss-qnty = 0.00
      invent-fo  = 0.00
    .
    run gdsoattr-value in this-procedure
                      ( input  'normal-wastage-o':U
                       ,input  bf_goods.gds-code
                       ,input  bf_rvs-doc.obj-type
                       ,input  bf_rvs-doc.obj-code
                       ,output v-normal-wastage
                       ,output v-type
                      ) no-error .
    if v-normal-wastage <> 0
      and v-normal-wastage <> ?
    then do:
      if bf_trn-doc.status_ = 'факт':U
      then do:
        find last bf_doc-line no-lock where
                  bf_doc-line.obj-type     = bf_rvs-line.obj-type  and
                  bf_doc-line.obj-code     = bf_rvs-line.obj-code  and
                  bf_doc-line.prod-type    = bf_goods.prod-type    and
                  bf_doc-line.prod-code    = bf_goods.prod-code    and
                  bf_doc-line.artic        = bf_goods.artic        and
                  bf_doc-line.ext-doc-type = 'vt':U          and
                  bf_doc-line.status_      = 'факт':U               and
                  bf_doc-line.fact-order   < bf_trn-doc.fact-order use-index dt-fo no-error .
      end.
      else do:
        find last bf_doc-line no-lock where
                  bf_doc-line.obj-type     = bf_rvs-line.obj-type  and
                  bf_doc-line.obj-code     = bf_rvs-line.obj-code  and
                  bf_doc-line.prod-type    = bf_goods.prod-type    and
                  bf_doc-line.prod-code    = bf_goods.prod-code    and
                  bf_doc-line.artic        = bf_goods.artic        and
                  bf_doc-line.ext-doc-type = 'vt':U          and
                  bf_doc-line.status_      = 'факт':U               use-index dt-fo no-error .
      end.
      if available bf_doc-line
      then do:
        assign
          invent-fo = bf_doc-line.fact-order
        .
      end.
      for each bf_doc-line no-lock
        where ( bf_doc-line.obj-type         = bf_rvs-line.obj-type
                and bf_doc-line.obj-code     = bf_rvs-line.obj-code
                and bf_doc-line.prod-type    = bf_goods.prod-type
                and bf_doc-line.prod-code    = bf_goods.prod-code
                and bf_doc-line.artic        = bf_goods.artic
                and bf_doc-line.ext-doc-type = 'ie':U
                and bf_doc-line.status_      = 'факт':U
                and bf_doc-line.fact-order   > invent-fo
                and (not can-find (first buf_sale-doc
                                   where buf_sale-doc.doc-code = bf_doc-line.doc-code
                                     and buf_sale-doc.doc-kind = 'itr':U))
              ) or
              ( bf_doc-line.obj-type         = bf_rvs-line.obj-type
                and bf_doc-line.obj-code     = bf_rvs-line.obj-code
                and bf_doc-line.prod-type    = bf_goods.prod-type
                and bf_doc-line.prod-code    = bf_goods.prod-code
                and bf_doc-line.artic        = bf_goods.artic
                and bf_doc-line.ext-doc-type = 'ep':U
                and bf_doc-line.status_      = 'факт':U
                and bf_doc-line.fact-order   > invent-fo
              )
      ,first bf_doc-pl no-lock
        where bf_doc-pl.obj-type  = bf_rvs-line.obj-type
          and bf_doc-pl.obj-code  = bf_rvs-line.obj-code
          and bf_doc-pl.pl-code   = bf_rvs-line.pl-code
          and bf_doc-pl.out-code  = bf_doc-line.doc-code
          and bf_doc-pl.gds-code  = bf_rvs-line.gds-code
        use-index pi
      on error undo, return error return-value
      :
        if bf_trn-doc.status_    = 'факт':U
          and bf_trn-doc.fact-order < bf_doc-line.fact-order
        then do:
          leave .
        end.
        if ptrlprop-expptrl = 'volume':U
        then do:
          assign
            dLoss-curr-qnty = bf_doc-pl.fact-qnty
          .
        end.
        else do:
          assign
            dLoss-curr-qnty = bf_doc-pl.cli-fact-qnty
          .
        end.
        assign
          dLoss-curr-qnty = dLoss-curr-qnty * v-normal-wastage * 0.001
        .
        if bf_doc-line.ext-doc-type = 'ie':U then do:
          assign
            dLoss-qnty = dLoss-qnty + dLoss-curr-qnty
          .
        end.
        else do:
          assign
            dLoss-qnty = dLoss-qnty - dLoss-curr-qnty
          .
        end.
      end.
    end.
    if ptrlprop-expptrl = 'volume':U
    then do:
      assign
        v-unit-name = trim( bf_goods.unit-base )
        dcurr-price = dprice-sale
        d_FactRest  = bf_rvs-line.state-measure-qnty + bf_rvs-line.state-add-qnty
        d_BookRest  = bf_rvs-line.system-qnty
      .
    end.
    else do:
      assign
        v-unit-name = trim( bf_goods.unit-cli )
        d_FactRest  = bf_rvs-line.state-measure-cli-qnty + bf_rvs-line.state-add-qnty * bf_rvs-line.state-density
        d_BookRest  = bf_rvs-line.system-cli-qnty
      .
      assign
        prc-density = bf_rvs-line.state-density
      .
      assign
        dcurr-price = dprice-sale / prc-density
      .
    end.
    assign
      dExtra-qnty = ( if d_FactRest > d_BookRest then ( d_FactRest - d_BookRest ) else 0.00 )
      dMiss-qnty  = ( if d_FactRest < d_BookRest then ( d_BookRest - d_FactRest ) else 0.00 )
      dNorm-qnty  = d_FactRest * d_pcnt
      dXcalc-qnty = ( if dExtra-qnty > dNorm-qnty then dExtra-qnty - dNorm-qnty else 0.00 )
      dLcalc-qnty = ( if dMiss-qnty  > dLoss-qnty + dNorm-qnty then dMiss-qnty - ( dLoss-qnty + dNorm-qnty ) else 0.00 )
    .
    if dLcalc-qnty < 0.001 then assign dNorm-qnty  = dNorm-qnty + dLcalc-qnty
                                       dLcalc-qnty = 0.
    assign
      dExtra-sum = dExtra-qnty * dcurr-price
      dMiss-sum  = dMiss-qnty  * dcurr-price
      dLoss-sum  = dLoss-qnty  * dcurr-price
      dNorm-sum  = dNorm-qnty  * dcurr-price
      dXcalc-sum = dXcalc-qnty * dcurr-price
      dLcalc-sum = dLcalc-qnty * dcurr-price
    .
    find first bf_place no-lock where
               bf_place.obj-type = bf_rvs-line.obj-type and
               bf_place.obj-code = bf_rvs-line.obj-code and
               bf_place.pl-code  = bf_rvs-line.pl-code  .
    assign
      j_LineCount = j_LineCount + 1
    .
    put stream s-out unformatted
      string( string( j_LineCount,         ">9":U ),        "x(3)":U  ) + ":" +
      string( bf_goods.gds-name,                            "x(15)":U ) + ":" +
      string( bf_goods.artic,                               "x(7)":U  ) + ":" +
      string( string( bf_rvs-line.pl-code, ">>>>>>>>>>9":U ), "x(11)":U  ) + ":" +
      string( ' ':U + v-unit-name + ' ':U,                  "x(5)":U  ) + ":" +
      string( OutSum( dcurr-price, no  ),                   "x(8)":U  ) + ":" +
      string( OutQty( dExtra-qnty, yes ),                   "x(12)":U ) + ":" +
      string( OutSum( dExtra-sum,  yes ),                   "x(8)":U  ) + ":" +
      string( OutQty( dMiss-qnty,  yes ),                   "x(12)":U ) + ":" +
      string( OutSum( dMiss-sum,   yes ),                   "x(11)":U  ) + ":" +
      '            :        :                     :            :        :                     :            :        :            :        :' +
      string( OutQty( dLoss-qnty,  no  ),                   "x(12)":U ) + ":" +
      string( OutSum( dLoss-sum,   no  ),                   "x(7)":U  ) + ":" +
      string( OutQty( dNorm-qnty,  no  ),                   "x(12)":U ) + ":" +
      string( OutSum( dNorm-sum,   no  ),                   "x(8)":U  ) + ":" +
      string( OutQty( dXcalc-qnty, yes ),                   "x(12)":U ) + ":" +
      string( OutSum( dXcalc-sum,  yes ),                   "x(9)":U  ) + ":" +
      '               :' +
      string( OutQty( dLcalc-qnty, yes ),                   "x(12)":U ) + ":" +
      string( OutSum( dLcalc-sum,  yes ),                   "x(9)":U  ) skip
    .
    run r-orsvxl-write-line-data in this-procedure
      (
        input j_LineCount
      , input bf_goods.gds-name
      , input bf_goods.artic
      , input trim( string( bf_rvs-line.pl-code, ">>>>>>>>>>>9":U ) )
      , input v-unit-name
      , input OutDec( dcurr-price, no  )
      , input OutDec( dExtra-qnty, yes )
      , input OutDec( dExtra-sum,  yes )
      , input OutDec( dMiss-qnty,  yes )
      , input OutDec( dMiss-sum,   yes )
      , input OutDec( dLoss-qnty,  no  )
      , input OutDec( dLoss-sum,   no  )
      , input OutDec( dNorm-qnty,  no  )
      , input OutDec( dNorm-sum,   no  )
      , input OutDec( dXcalc-qnty, yes )
      , input OutDec( dXcalc-sum,  yes )
      , input OutDec( dLcalc-qnty, yes )
      , input OutDec( dLcalc-sum,  yes )
    ) .
    assign
      tExtra-qnty = tExtra-qnty + dExtra-qnty
      tExtra-sum  = tExtra-sum  + dExtra-sum
      tMiss-qnty  = tMiss-qnty  + dMiss-qnty
      tMiss-sum   = tMiss-sum   + dMiss-sum
      tLoss-qnty  = tLoss-qnty  + dLoss-qnty
      tLoss-sum   = tLoss-sum   + dLoss-sum
      tNorm-qnty  = tNorm-qnty  + dNorm-qnty
      tNorm-sum   = tNorm-sum   + dNorm-sum
      tXcalc-qnty = tXcalc-qnty + dXcalc-qnty
      tXcalc-sum  = tXcalc-sum  + dXcalc-sum
      tLcalc-qnty = tLcalc-qnty + dLcalc-qnty
      tLcalc-sum  = tLcalc-sum  + dLcalc-sum
    .
    assign
      xExtra-qnty = xExtra-qnty + dExtra-qnty
      xExtra-sum  = xExtra-sum  + dExtra-sum
      xMiss-qnty  = xMiss-qnty  + dMiss-qnty
      xMiss-sum   = xMiss-sum   + dMiss-sum
      xLoss-qnty  = xLoss-qnty  + dLoss-qnty
      xLoss-sum   = xLoss-sum   + dLoss-sum
      xNorm-qnty  = xNorm-qnty  + dNorm-qnty
      xNorm-sum   = xNorm-sum   + dNorm-sum
      xXcalc-qnty = xXcalc-qnty + dXcalc-qnty
      xXcalc-sum  = xXcalc-sum  + dXcalc-sum
      xLcalc-qnty = xLcalc-qnty + dLcalc-qnty
      xLcalc-sum  = xLcalc-sum  + dLcalc-sum
    .
  end.
  put stream s-out unformatted
    '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' skip
    '   : ИТОГО:        :           :       :     :        :' +
    string( OutQty( xExtra-qnty, yes ), "x(12)":U ) + ":" +
    string( OutSum( xExtra-sum,  yes ), "x(8)":U  ) + ":" +
    string( OutQty( xMiss-qnty,  yes ), "x(12)":U ) + ":" +
    string( OutSum( xMiss-sum,   yes ), "x(11)":U  ) + ":" +
    '            :        :                     :            :        :                     :            :        :            :        :' +
    string( OutQty( xLoss-qnty,  no  ), "x(12)":U ) + ":" +
    string( OutSum( xLoss-sum,   no  ), "x(7)":U  ) + ":" +
    string( OutQty( xNorm-qnty,  no  ), "x(12)":U ) + ":" +
    string( OutSum( xNorm-sum,   no  ), "x(8)":U  ) + ":" +
    string( OutQty( xXcalc-qnty, yes ), "x(12)":U ) + ":" +
    string( OutSum( xXcalc-sum,  yes ), "x(9)":U  ) + ":" +
      '               :' +
    string( OutQty( xLcalc-qnty, yes ), "x(12)":U ) + ":" +
    string( OutSum( xLcalc-sum,  yes ), "x(9)":U  )                                                                                                                                                                                                                                                                                                 skip
    '--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' skip( 2 )
  .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "it_ExtraQnty":U
    , input OutDec( tExtra-qnty, yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "it_ExtraSum":U
    , input OutDec( tExtra-sum,  yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "it_MissQnty":U
    , input OutDec( tMiss-qnty,  yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "it_MissSum":U
    , input OutDec( tMiss-sum,   yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "it_LossQnty":U
    , input OutDec( tLoss-qnty,  no  )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "it_LossSum":U
    , input OutDec( tLoss-sum,   no  )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "it_NormQnty":U
    , input OutDec( tNorm-qnty,  no  )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "it_NormSum":U
    , input OutDec( tNorm-sum,   no  )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "it_XcalcQnty":U
    , input OutDec( tXcalc-qnty, yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "it_XcalcSum":U
    , input OutDec( tXcalc-sum,  yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "it_LcalcQnty":U
    , input OutDec( tLcalc-qnty, yes )
    ) .
  run r-orsvxl-write-cell-data in this-procedure
    ( input "it_LcalcSum":U
    , input OutDec( tLcalc-sum,  yes )
    ) .
  put stream s-out unformatted
    '                            '
    'Бухгалтер ______________________________'
    '                                                                                                                   '
    'С результатами сличения ознакомлен ___________________________________________________________' skip
    '                            '
    '           (подпись)                    '
    '                                                                                                                   '
    '                                    (подпись)'                                                  skip
  .
  run waitfram-hide  in this-procedure .
  run r-orsvxl-close in this-procedure .
  output stream s-out close .
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 2 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
end.
procedure clc-pcnt :
  define output parameter d-percent as decimal no-undo .
  define variable v-stfactpl  as character no-undo initial "":U .
  define variable v-data-type as character no-undo initial "":U .
  define variable v-update    as logical   no-undo initial yes  .
  define variable v-revision  as logical   no-undo initial no   .
  define variable v-percrev   as decimal   no-undo initial ?    .
  define variable v-auto-tank as logical   no-undo initial no   .
  define variable v-percauto  as decimal   no-undo initial ?    .
  define variable v-inv       as logical   no-undo initial no   .
  define variable v-percinv   as decimal   no-undo initial ?    .
  define variable v-inv-set   as logical   no-undo initial no   .
  do
  on error undo, return error return-value
  :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'stfactpl'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-stfactpl
  ,output v-data-type
  ) no-error .
    if error-status :error
    then do:
      message "Ошибка при чтении параметра stfactpl." skip( 0 )
              error-status :get-message( 1 ) skip( 0 )
              return-value
      view-as alert-box error .
      return error .
    end.
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_chkqtpl in g#lib-calc
  (  input v-stfactpl
  , output v-update
  , output v-revision
  , output v-percrev
  , output v-auto-tank
  , output v-percauto
  , output v-inv
  , output v-percinv
  , output v-inv-set
  ) no-error .
    if error-status :error
    then do:
      message "Ошибка при проверке параметра stfactpl." skip( 0 )
              error-status :get-message( 1 ) skip( 0 )
              return-value
      view-as alert-box error .
      return error .
    end.
    if v-revision = yes
    then do:
      assign
        d-percent = v-percrev * 0.01
      .
    end.
    else
    if v-auto-tank = yes
    then do:
      assign
        d-percent = v-percauto * 0.01
      .
    end.
    else
    if v-inv = yes
    then do:
      assign
        d-percent = v-percinv * 0.01
      .
    end.
    if d-percent < 0.00 or
       d-percent > 1.00
    then do:
      message "Ошибка при вычислении процента отклонения." skip( 0 )
              "stfactpl:" v-stfactpl skip( 0 )
              "процент:"  d-percent * 100
      view-as alert-box error .
      return error .
    end.
  end.
end procedure.
procedure dec2char :
  define  input parameter p-dec  as decimal   no-undo .
  define  input parameter p-hide as logical   no-undo .
  define output parameter p-char as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-dec  = ?
    then do:
      assign
        p-char = "":U
      .
    end.
    else
    if p-dec  = 0.00 and
       p-hide = yes
    then do:
      assign
        p-char = "":U
      .
    end.
    else do:
      assign
        p-char = trim( string( p-dec,  "->>>>>>>>>>>>>9.9<<<<<<<<<":U ) )
      .
    end.
  end.
end procedure.
procedure get-center-line :
  define  input parameter p-in-string  as character no-undo .
  define  input parameter p-rep-width  as integer   no-undo .
  define output parameter p-out-string as character no-undo .
  do
  on error undo, return error return-value
  :
    if length( p-in-string ) < p-rep-width
    then do:
      assign
        p-out-string = fill( ' ':U, integer( ( p-rep-width - length( p-in-string ) ) * 0.5 ) ) + p-in-string
      .
    end.
    else do:
      assign
        p-out-string = p-in-string
      .
    end.
  end.
end procedure.
procedure get-dec-string :
  define  input parameter p-dec  as decimal   no-undo .
  define  input parameter p-int  as integer   no-undo .
  define  input parameter p-hide as logical   no-undo .
  define output parameter p-char as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-dec  = ?
    then do:
      assign
        p-char = "":U
      .
    end.
    else
    if p-dec  = 0.00 and
       p-hide = yes
    then do:
      assign
        p-char = "":U
      .
    end.
    else do:
      if p-int = 3
      then do:
        assign
          p-char = trim( string( p-dec, "->>>>>>9.999":U ) )
          p-char = fill( ' ':U, 12 - length( p-char ) ) + p-char
        .
      end.
      else do:
        assign
          p-char = trim( string( p-dec, "->>>>>>9.99":U ) )
          p-char = fill( ' ':U,  8 - length( p-char ) ) + p-char
        .
      end.
    end.
  end.
end procedure.
