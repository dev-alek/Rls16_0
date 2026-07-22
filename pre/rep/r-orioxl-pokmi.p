block-level on error undo, throw.
define input parameter p-parent-proc as widget-handle no-undo .
define input parameter p-rec-invent  as recid         no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 94114751b278, 3560, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/11/27 08:31:19 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-orioxl-pokmi.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-orioxl-pokmi.p $":U .
define variable vss-description as character no-undo initial "Инвентаризационная описись СУГ":U .
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
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character, input p-num as integer) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character, input p-num as integer):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    if p-data = ? then p-data = 0 .
    p-data = round(p-data, p-num).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
END FUNCTION.
function is-sug returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'lgas':U) no-error.
return result.
end function.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
define temp-table with-action no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
procedure c-place_get-attr :
  define input parameter attr-code as character no-undo .
  define input parameter obj-code as integer no-undo .
  define input parameter obj-type as character no-undo .
  define input parameter pl-code as integer no-undo .
  define input parameter endDate as date no-undo .
  define input parameter endTime as integer no-undo .
  define output parameter attr-value as character no-undo .
  define buffer bf_c-place-attr for ub.c-place-attr .
  define variable is-place-attr as logical no-undo .
  find last bf_c-place-attr no-lock where bf_c-place-attr.pl-code = pl-code and
    bf_c-place-attr.obj-code = obj-code and
    bf_c-place-attr.obj-type = obj-type and
    bf_c-place-attr.attr-code = attr-code and
    ((bf_c-place-attr.corr-date = endDate and
    bf_c-place-attr.corr-time < endTime) or
    bf_c-place-attr.corr-date < endDate) no-error .
  if available (bf_c-place-attr) then attr-value = bf_c-place-attr.attr-value .
  else attr-value = "true" .
end procedure.
FUNCTION get_max-qnty returns decimal (
  input obj-code as integer,
  input obj-type as character,
  input pl-code as integer,
  input endDate as date,
  input endTime as integer ):
  define buffer bf_c-place     for ub.c-place .
  define buffer buf_c-place    for ub.c-place .
  define buffer bf_place       for ub.place .
  define buffer curr_c-place   for c-place .
  define buffer buf_c-plc-hist for ub.c-plc-hist .
  define variable ii      as integer no-undo init 0.
  define variable is-max-qnty as logical no-undo .
  define variable is-true as logical no-undo .
  find last curr_c-place no-lock where curr_c-place.pl-code = pl-code and
    curr_c-place.obj-code = obj-code and
    curr_c-place.obj-type = obj-type and
    ((curr_c-place.corr-date = endDate and
    curr_c-place.corr-time < endTime) or
    curr_c-place.corr-date < endDate) no-error .
  if available (curr_c-place) then
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place"
      and buf_c-plc-hist.chip-num = curr_c-place.chip-num no-error .
    if available (buf_c-plc-hist) then
    do:
      define variable v-label-param as character no-undo .
      v-label-param =
        "max-qnty" + chr(4) + "Максимальное количество" + chr(4) + "" .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer('1':U)
        ,input buf_c-plc-hist.action = integer('99':U)
        ,input  buffer curr_c-place:handle
        ,input  'place':U
        ,input  "max-qnty"
        ,input  v-label-param).
    end.
  end.
  for each with-action:
    return decimal(with-action.v_new) .
  end.
  if available (curr_c-place) then
  do:
    return curr_c-place.max-qnty .
  end.
  find first bf_place no-lock where bf_place.pl-code = pl-code and
    bf_place.obj-code = obj-code and
    bf_place.obj-type = obj-type no-error .
  return bf_place.max-qnty .
end function.
FUNCTION get_meas returns logical (
  input obj-code as integer,
  input obj-type as character,
  input pl-code as integer,
  input endDate as date,
  input endTime as integer ):
  define buffer bf_c-place     for ub.c-place .
  define buffer buf_c-place    for ub.c-place .
  define buffer bf_place       for ub.place .
  define buffer curr_c-place   for c-place .
  define buffer buf_c-plc-hist for ub.c-plc-hist .
  define variable ii      as integer no-undo init 0.
  define variable is-meas as logical no-undo .
  define variable is-true as logical no-undo .
  find last curr_c-place no-lock where curr_c-place.pl-code = pl-code and
    curr_c-place.obj-code = obj-code and
    curr_c-place.obj-type = obj-type and
    ((curr_c-place.corr-date = endDate and
    curr_c-place.corr-time < endTime) or
    curr_c-place.corr-date < endDate) no-error .
  if available (curr_c-place) then
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place"
      and buf_c-plc-hist.chip-num = curr_c-place.chip-num no-error .
    if available (buf_c-plc-hist) then
    do:
      define variable v-label-param as character no-undo .
      v-label-param =
        "is-meas" + chr(4) + "Измеряется приборами" + chr(4) + "" .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer('1':U)
        ,input buf_c-plc-hist.action = integer('99':U)
        ,input  buffer curr_c-place:handle
        ,input  'place':U
        ,input  "is-meas"
        ,input  v-label-param).
    end.
  end.
  for each with-action:
    return logical (with-action.v_new) .
  end.
  find first bf_place no-lock where bf_place.pl-code = pl-code and
    bf_place.obj-code = obj-code and
    bf_place.obj-type = obj-type no-error .
  return bf_place.is-meas .
end function.
FUNCTION get_com-vessel returns logical (
  input obj-code as integer,
  input obj-type as character,
  input attr-code as character,
  input pl-code as integer,
  input openDate as date,
  input endDate as date,
  input openTime as integer,
  input endTime as integer ):
  define buffer current_c-place-attr for c-place-attr .
  define buffer buf_c-plc-hist       for ub.c-plc-hist .
  define variable ii      as integer   no-undo init 0.
  define variable is-meas as logical   no-undo .
  define variable is-true as logical   no-undo .
  define variable v-label as character no-undo .
  define variable p-ok    as logical   no-undo .
  find last current_c-place-attr no-lock where
    current_c-place-attr.obj-type = obj-type
    AND current_c-place-attr.obj-code = obj-code
    AND current_c-place-attr.pl-code = pl-code
    and current_c-place-attr.attr-code = attr-code
    and ((current_c-place-attr.corr-date = endDate
    and current_c-place-attr.corr-time < endTime) or
    current_c-place-attr.corr-date < endDate)
    no-error .
  if avail current_c-place-attr then
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place-attr"
      and buf_c-plc-hist.chip-num = current_c-place-attr.chip-num no-error .
    if available (buf_c-plc-hist) then
    do:
      define variable v-label-param as character no-undo .
      if current_c-place-attr.attr-code = "place-SI"
        or current_c-place-attr.attr-code = "place-SI-temp"
        or current_c-place-attr.attr-code = "place-SI-dens"
        or current_c-place-attr.attr-code = "place-SI-level"
        then
      do :
        v-label-param =
          "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getSIname" + chr(8)
          + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode"   .
      end .
      else
      do :
        v-label-param =
          "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getPlaceAttrValue" + chr(8)
          + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode" + chr(8)
          + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
          + "status_" + chr(4) + "Статус" + chr(4) + ""  .
      end .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer('1':U)
        ,input buf_c-plc-hist.action = integer('99':U)
        ,input  buffer current_c-place-attr:handle
        ,input  'place-attr':U
        ,input  "attr-code,attr-value,PS,status_"
        ,input  v-label-param).
    end.
  end.
  for each with-action:
    p-ok = logical (with-action.v_new) no-error .
    if error-status:error then p-ok = false .
    return   p-ok .
  end.
  return no .
end function.
FUNCTION get_com-tanks returns character (
  input obj-code as integer,
  input obj-type as character,
  input attr-code as character,
  input pl-code as integer,
  input openDate as date,
  input endDate as date,
  input openTime as integer,
  input endTime as integer ):
  define buffer current_c-place-attr for ub.c-place-attr .
    define buffer buf_c-plc-hist       for ub.c-plc-hist .
  define variable ii        as integer   no-undo init 0.
  define variable is-meas   as logical   no-undo .
  define variable is-true   as logical   no-undo .
  define variable v-label   as character no-undo .
  define variable p-ok as character no-undo .
  find last current_c-place-attr no-lock where
    current_c-place-attr.obj-type = obj-type
    AND current_c-place-attr.obj-code = obj-code
    AND current_c-place-attr.pl-code = pl-code
    and current_c-place-attr.attr-code = attr-code
    and ((current_c-place-attr.corr-date = endDate
    and current_c-place-attr.corr-time < endTime) or
    current_c-place-attr.corr-date < endDate)
    no-error .
  if avail current_c-place-attr then
  do:
    find first buf_c-plc-hist no-lock where
      buf_c-plc-hist.obj-type = obj-type
      AND buf_c-plc-hist.obj-code = obj-code
      AND buf_c-plc-hist.pl-code = pl-code
      AND buf_c-plc-hist.subject  = "place-attr"
      and buf_c-plc-hist.chip-num = current_c-place-attr.chip-num no-error .
    if available (buf_c-plc-hist) then
    do:
      define variable v-label-param as character no-undo .
      if current_c-place-attr.attr-code = "place-SI"
        or current_c-place-attr.attr-code = "place-SI-temp"
        or current_c-place-attr.attr-code = "place-SI-dens"
        or current_c-place-attr.attr-code = "place-SI-level"
        then
      do :
        v-label-param =
          "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getSIname" + chr(8)
          + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode"   .
      end .
      else
      do :
        v-label-param =
          "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getPlaceAttrValue" + chr(8)
          + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode" + chr(8)
          + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
          + "status_" + chr(4) + "Статус" + chr(4) + ""  .
      end .
      run proc-full-temp-changes in this-procedure (
        input buf_c-plc-hist.action = integer('1':U)
        ,input buf_c-plc-hist.action = integer('99':U)
        ,input  buffer current_c-place-attr:handle
        ,input  'place-attr':U
        ,input  "attr-code,attr-value,PS,status_"
        ,input  v-label-param).
    end.
  end.
  for each with-action:
     p-ok = with-action.v_new no-error .
     if error-status:error then p-ok = "" .
    return   p-ok .
  end.
  return "" .
end function.
function getSIname returns character (si-code as char) :
  for first sr-izmerenia no-lock where sr-izmerenia.node-code = integer(si-code) :
    return sr-izmerenia.sr-model .
  end .
end .
function  getPlaceAttrCode returns character (istr as char ):
  define variable OStr as character no-undo.
  if istr eq "disable-level-alarm"
    then
    OStr = "Сообщения о переполнении".
  else if istr eq "disable-water-alarm"
      then
      OStr = "Сообщения по воде".
    else if istr eq "place-need-RVD-rvs"
        then
        OStr = "Необходимо сделать сверку с РВД".
      else if istr eq "place-SI-level"
          then
          OStr = "Доп. средство измерения уровня".
        else if istr eq "place-SI-dens"
            then
            OStr = "Доп. средство измерения плотности".
          else if istr eq "place-SI-temp"
              then
              OStr = "Доп. средство измерения температуры".
            else if istr eq "place-SI"
                then
                OStr = "Основное средство измерения".
              else
                OStr = istr.
  return OStr.
end.
function  getPlaceAttrValue returns character (istr as char ):
  define variable OStr  as character no-undo.
  define variable vFlag as logical   no-undo.
  if    entry(1,istr,chr(4)) eq "enable"
    then
    assign
      OStr  = "Включено"
      vFlag = yes
      .
  else if    entry(1,istr,chr(4)) eq "disable"
      then
      assign
        OStr  = "Выключено"
        vFlag = yes
        .
    else
      OStr = istr.
  if     vFlag
    and num-entries (istr,chr(4)) > 2
    then
    OStr = OStr + " для смены № " + entry(3,istr,chr(4)) + " Дата " + entry(2,istr,chr(4)).
  return OStr.
end.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-act-create as logical   no-undo .
  define input  parameter p-act-delete as logical   no-undo .
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields      as character no-undo.
  for each with-action:
    delete with-action.
  end.
  if not p-hst-handle:available then
  do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
    .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
      .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
    then
  do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
    .
  if v-idx-field-qnty < 2 then
  do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
    .
  do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
      .
    if fh:data-type ="character":U then
    do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
        .
    end.
    else
    do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
        .
    end.
    if v-delim-list = "":U then
    do:
      assign
        v-delim-list = ",":U
        .
    end.
    if v-word-link = "":U then
    do:
      assign
        v-word-link = "and":U
        .
    end.
  end.
  assign
    v-delim-list = "":U
    .
  do v-ind = 1 to h-main-buf:num-fields
    on error undo, return error
    :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
      .
    assign
      v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
    if v-delim-list = "":U then
    do:
      assign
        v-delim-list = ",":U
        .
    end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
    .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
      .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
    then
  do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
    .
  if v-idx-field-qnty < 2 then
  do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    .
  do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
      .
    if v-field-name = "chip-num":U then
    do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
        .
    end.
    else
    do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
        .
    end.
    if fh:data-type ="character":U then
    do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
        .
    end.
    else
    do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
        .
    end.
    if v-word-link = "":U then
    do:
      assign
        v-word-link = "and":U
        .
    end.
  end.
  if v-av-chip-num = false then
  do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then
  do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then
    do:
      assign
        h-for-comp = ?
        .
    end.
    else
    do:
      assign
        h-for-comp = h-main-buf
        .
    end.
  end.
  else
  do:
    assign
      h-for-comp = h-new-buf
      .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
    .
  do v-ind = 1 to v-num-entries
    on error undo, return error return-value
    :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
      .
    if ( trim( p-field-list ) <> "":U
      and lookup( v-field-name, p-field-list ) > 0
      )
      or trim( p-field-list ) = "":U
      then
    do:
      if h-for-comp <> ? then
      do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
          .
      end.
      else
      do:
        assign
          v-new-value = "":U
          .
      end.
      if p-act-create = true then
      do:
        assign
          v-old-value = "":U
          .
      end.
      if p-act-delete = true then
      do:
        assign
          v-new-value = "":U
          .
      end.
      if v-old-value <> v-new-value
        then
      do:
        create with-action.
        assign
          with-action.t_name     = p-main-table
          with-action.f_name     = v-field-name
          with-action.l_name     = replace( v-label, "&":U, "":U )
          with-action.v_old      = trim( v-old-value )
          with-action.v_new      = trim( v-new-value )
          with-action.num_       = 0
          with-action.fNotChange = v-old-value eq v-new-value
          .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
    .
  do v-ind = 1 to v-num-entries
    on error undo, return error return-value
    :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then
    do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        .
      find first with-action
        where with-action.f_name = v-field-name
        no-error .
      if available with-action then
      do:
        if trim( v-field-lvl ) <> "":U then
        do:
          assign
            with-action.l_name = v-field-lvl
            .
        end.
        if trim( v-field-form ) <> "":U then
        do:
          assign
            with-action.v_old = dynamic-function( v-field-form, with-action.v_old )
            .
          if h-for-comp <> ? then
          do:
            assign
              with-action.v_new = dynamic-function( v-field-form, with-action.v_new )
              .
          end.
        end.
      end.
    end.
    else
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
        ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        ,entry( v-ind, p-label-form, chr(8) )
        ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo initial yes .
define variable g#log         as logical no-undo .
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-host-name   as character no-undo .
define variable p-host-code   as integer   no-undo .
define variable v-doc-num     as character no-undo .
define variable dprice-sale   as decimal   no-undo .
define variable droad-tax     as decimal   no-undo .
define variable dexcise       as decimal   no-undo .
define variable dcurr-price   as decimal   no-undo .
define variable dWaterQnty    as decimal   no-undo .
define variable dWaterCliQnty as decimal   no-undo .
define variable dAddCliQnty   as decimal   no-undo .
define variable dOverCliQnty  as decimal   no-undo .
define variable dOverSum      as decimal   no-undo .
define variable dBookSum      as decimal   no-undo .
define variable dExtraQnty    as decimal   no-undo .
define variable dExtraSum     as decimal   no-undo .
define variable dMissQnty     as decimal   no-undo .
define variable dMissSum      as decimal   no-undo .
define variable t_inv-date    as date      no-undo .
define variable j_LineCount   as integer   no-undo .
define variable v-pl-code     as character no-undo .
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable v-value-character   as character no-undo .
define variable v-CriticalDifInLgas as decimal   no-undo .
define variable v-value-date        as date      no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-param-type        as character no-undo .
define variable v-tth               as handle    no-undo .
define variable delta-mass-qnty     as decimal   no-undo .
define variable CriticalDif         as decimal   no-undo .
define variable v-loc1              as character no-undo .
define variable pl-error-mass       as decimal   no-undo .
define temp-table tt-petrol
  field gds-code   as integer
  field gds-name   as character
  field pl-code    as integer
  field pl-code_   as character
  field pl-type    as character
  field level      as decimal
  field volue      as decimal
  field density    as decimal
  field temp       as decimal
  field qnty       as decimal
  field delta      as decimal
  field density1   as decimal
  field temp1      as decimal
  field qnty1      as decimal
  field delta1     as decimal
  field name-pl    as character
  field volue-pl   as decimal
  field log-pl     as character
  field place-num  as character
  field place-type as character
  field type_dan   as character
  index pi gds-code pl-code .
define buffer bf_trn-doc         for ub.trn-doc  .
define buffer bf_rvs-doc         for ub.rvs-doc  .
define buffer bf_rvs-line        for ub.rvs-line .
define buffer bf_goods           for ub.goods    .
define buffer bf_object          for ub.clients  .
define buffer bf_place           for ub.place    .
define buffer bf_doc-line        for ub.doc-line.
define buffer bf_c-place-attr    for ub.c-place-attr .
define buffer after_c-place-attr for ub.c-place-attr .
define buffer befor_c-place-attr for ub.c-place-attr .
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
    then
  do:
    run waitfram-hide in this-procedure .
    message substitute( 'Не найден документ с идентификатором &1.'
      , p-rec-invent
      )
      view-as alert-box error .
    undo, return error .
  end.
  if bf_trn-doc.doc-type     <> 'инв':U or
    bf_trn-doc.ext-doc-type <> 'vt':U
    then
  do:
    run waitfram-hide in this-procedure .
    message
      'Данная форма только для печати инвентаризации.'
      view-as alert-box error .
    undo, return error .
  end.
  find first bf_rvs-doc no-lock where
    bf_rvs-doc.rvs-code = bf_trn-doc.out-code no-error .
  if not available bf_rvs-doc
    then
  do:
    run waitfram-hide in this-procedure .
    message substitute( 'Не найдена сверка к документу "&1".'
      , bf_trn-doc.doc-code
      )
      view-as alert-box error .
    undo, return error .
  end.
  if bf_rvs-doc.rvs-type <> 'контроль':U
    then
  do:
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
    then
  do:
    run waitfram-hide in this-procedure .
    message
      'Не могу определить текущую фирму.'
      view-as alert-box error .
    undo, return error .
  end.
  if bf_trn-doc.host-code <> p-host-code
    then
  do:
    run waitfram-hide in this-procedure .
    message
      'Ошибка определения текущей фирмы.'
      view-as alert-box error .
    undo, return error .
  end.
  assign
    t_inv-date = ( if bf_trn-doc.status_ = 'факт':U then bf_trn-doc.fact-date else bf_trn-doc.doc-date )
    .
  define variable v-prikaz-num  as character no-undo .
  define variable v-prikaz-date as character no-undo .
  define variable v-doc-date    as character no-undo .
  define variable p-type        as character no-undo .
  define variable v-pos-agent   as character no-undo .
  define variable v-fio-agent   as character no-undo .
  define variable v-pos-player1 as character no-undo .
  define variable v-fio-player1 as character no-undo .
  define variable v-pos-player2 as character no-undo .
  define variable v-fio-player2 as character no-undo .
  define variable v-pos-player3 as character no-undo .
  define variable v-fio-player3 as character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-inv-date':U ,
                       output v-doc-date ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-prikaz-number':U ,
                       output v-prikaz-num ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-prikaz-date':U ,
                       output v-prikaz-date ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-fio-agent':U ,
                       output v-fio-agent ,
                       output p-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-pos-agent':U ,
                       output v-pos-agent ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-fio-player1':U ,
                       output v-fio-player1 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-pos-player1':U ,
                       output v-pos-player1 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-fio-player2':U ,
                       output v-fio-player2 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-pos-player2':U ,
                       output v-pos-player2 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-fio-player3':U ,
                       output v-fio-player3 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-pos-player3':U ,
                       output v-pos-player3 ,
                       output p-type ) no-error .
  run get-report-num (output p-report-id).
  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".
  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    .
define variable vss-include-info9 as character no-undo format "x(65)":U
  initial "@(#)$Workfile: r-orioxl-pokmi.i $ $Revision: b6b5ab1a3177, 3577, rls $":U .
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
procedure shapka-inv :
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
  put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '</tr>' skip
    .
  put stream OutStr-html unformatted
    '<TR><TD colspan="86"></TD></TR>' skip
    '<TR>' skip
    '<TD colspan="25" style="height: 14px; text-align: left;">Наименование организации</TD>' skip
    '<TD colspan="61" style="text-align: right;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="25" style="height: 14px; border-bottom: 1px solid black; text-align: left;">' + v-host-name + '</TD>' skip
    '<TD colspan="61" style="text-align: right;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="25" style="height: 14px; text-align: left;">' + bf_object.obj-name + '</TD>' skip
    '<TD colspan="61" style="text-align: right;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="25" style="height: 14px"></TD>' skip
    '<TD colspan="61" style="text-align: right;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="text-align: center;">ИНВЕНТАРИЗАЦИОННАЯ ОПИСЬ НЕФТЕПРОДУКТОВ</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="text-align: center;">' + "№ " + string(bf_trn-doc.doc-code) + " от " + string (day( t_inv-date )) + " " + string(MonthNameRusCase( month( t_inv-date ), 2 )) + " " + string(year( t_inv-date )) + "г. " + '</TD>' skip
    '</TR>'skip
    .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="text-align: center;">Расписка</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">К началу проведения инвентаризации все приходные и расходные документы и товарно-</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">материальные ценности включены в отчеты (реестры), сданы в бухгалтерию и все ценности,</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">поступившие на мою (нашу) ответственность, оприходованы, а выбывшие списаны в расход.</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="86" style="">Материально ответственные (ое) лица (лицо):</TD>' skip
    '</TR>'skip
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    .
    if v-prikaz-date <> "" then do:
       put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" colspan="86" style="">На основании распоряжения от ' + string (day( date(v-prikaz-date) )) + " " + string(MonthNameRusCase( month( date(v-prikaz-date) ), 2 )) + " " + string(year( date(v-prikaz-date) )) + "г. " + if v-prikaz-num = "" then "№ __________" + '</TD>' else '№ ' + string(v-prikaz-num) + '</TD>' skip
      '</TR>'skip
      .
    end.
    else do:
     put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">На основании распоряжения от "_____" _______________ 20____ г. № __________ </TD>' skip
    '</TR>'skip
    .
    end.
     put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">произведено снятие фактических остатков нефтепродуктов</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">по состоянию на "_____" _______________ 20____ г.</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    .
    if v-doc-date <> "" then do:
     put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: right;">Инвентаризация начата</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="54" style="">' + string (day( date(v-doc-date) )) + " " + string(MonthNameRusCase( month( date(v-doc-date) ), 2 )) + " " + string(year( date(v-doc-date) )) + "г. " 'в _____ час. _____ мин.</TD>' skip
    '</TR>'skip
    .
    end.
    else do:
     put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: right;">Инвентаризация начата</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="54" style="">' + string (day( date(bf_trn-doc.doc-date) )) + " " + string(MonthNameRusCase( month( date(bf_trn-doc.doc-date) ), 2 )) + " " + string(year( date(bf_trn-doc.doc-date) )) + "г. " 'в _____ час. _____ мин.</TD>' skip
    '</TR>'skip
    .
    end.
    if bf_trn-doc.fact-date <> ? then do:
    put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: right;">окончена</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="54" style="">' + string (day( bf_trn-doc.fact-date )) + " " + string(MonthNameRusCase( month( bf_trn-doc.fact-date ), 2 )) + " " + string(year( bf_trn-doc.fact-date )) + "г. " 'в _____ час. _____ мин.</TD>' skip
    '</TR>'skip
    .
    end.
    else do:
     put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: right;">окончена</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="54" style="">"_____" ______________ 20 _____ г. в _____ час. _____ мин.</TD>' skip
    '</TR>'skip
    .
    end.
  put stream OutStr-html unformatted
    '</thead>' skip
    .
end procedure.
procedure foot-inv :
  put stream OutStr-html unformatted
    '<tfoot>' skip
    .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '</tr>' skip
    .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="15" style="">Общие замечания</TD>' skip
    '<TD text_wrap="true" colspan="71" style="border-bottom: 1px solid black;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="height: 14px; border-bottom: 1px solid black;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="height: 14px; border-bottom: 1px solid black;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="height: 14px; border-bottom: 1px solid black;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="height: 14px; border-bottom: 1px solid black;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="height: 14px; border-bottom: 1px solid black;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    .
    if j_LineCount = 0 then do:
    put stream OutStr-html unformatted
    '<TD text_wrap="true" colspan="86" style="">Все ценности, поименованные в описи c №  ' + "0" + ' по № ' + string(j_LineCount) + ', комиссией проверены в натуре</TD>' skip
    .
    end.
    else do:
    put stream OutStr-html unformatted
    '<TD text_wrap="true" colspan="86" style="">Все ценности, поименованные в описи c №  ' + "1" + ' по № ' + string(j_LineCount) + ', комиссией проверены в натуре</TD>' skip
    .
    end.
     put stream OutStr-html unformatted
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style=""> в моем (нашем) присутствии и внесены в опись, в связи с чем претензий к инвентаризационной</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style=""> комиссии не имею (не имеем). Ценности, перечисленные в описи, находятся на моем (нашем)</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">ответственном хранении</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">Материально ответственные(ое) лица(лицо):</TD>' skip
    '</TR>'skip
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="20" style="">Председатель комиссии:</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-pos-agent + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-fio-agent + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="22" style="text-align: center;"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(расшифровка подписи)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="20" style="">Состав комиссии:</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-pos-player1 + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-fio-player1 + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="22" style="text-align: center;"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(расшифровка подписи)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="20" style=""></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-pos-player2 + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-fio-player2 + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="22" style="text-align: center;"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(расшифровка подписи)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="20" style=""></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-pos-player3 + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="border-bottom: 1px solid black;">' + v-fio-player3 + '</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="22" style="text-align: center;"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="13" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="24" style="text-align: center;">(расшифровка подписи)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">Снятие остатков нефтепродуктов, указанных в описи, произведено при нашем личном участии.</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">Все взятые документы и деньги во время проверки возвращены нам полностью в надлежащем</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">порядке и претензий к комиссии (проверяющему) не имеем. Настоящую опись читали и</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">один экземпляр описи получили (объяснение предоставляется вместе с описью).</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="height: 14px;"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="86" style="">Материально ответственные(ое) лица(лицо):</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR style="height:20px;">' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="border-bottom: 1px solid black;"></TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(должность)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="20" style="text-align: center;">(подпись)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '<TD text_wrap="true" colspan="30" style="text-align: center;">(фамилия имя отчество)</TD>' skip
    '<TD colspan="2" text_wrap="true"></TD>' skip
    '</TR>'skip
    '<tr><td text_wrap="true" colspan="86">* ** Указанное значение выводится для справки</td></tr>' skip
    .
  put stream OutStr-html unformatted
    '</tfoot>' skip
    .
end procedure.
  run shapka-inv .
  run data-print .
  run table-inv .
  run foot-inv .
  put stream OutStr-html unformatted
    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
  output stream OutStr-html close.
  run prn-lib-reportviewer-report-name in this-procedure (
    input this-procedure
    ,input v-file-name-rep-htm
    ) no-error .
  if error-status:error then
  do:
    message return-value view-as alert-box.
    return .
  end.
procedure data-print :
  next_:
  for each  bf_rvs-line no-lock where
    bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code  and
    bf_rvs-line.obj-type = bf_rvs-doc.obj-type  and
    bf_rvs-line.obj-code = bf_rvs-doc.obj-code
      , first bf_goods    no-lock where
      bf_goods.gds-code = bf_rvs-line.gds-code
      , first bf_doc-line no-lock where
      bf_trn-doc.doc-code = bf_doc-line.doc-code and
      bf_goods.prod-code = bf_doc-line.prod-code and
      bf_goods.prod-type = bf_doc-line.prod-type and
      bf_goods.artic =  bf_doc-line.artic
      break
      by bf_rvs-line.gds-code
      by bf_rvs-line.pl-code
      :
      if is-sug(bf_goods.gds-code) then
      do:
         next next_ .
      end.
      find first bf_place no-lock where
         bf_place.obj-type = bf_rvs-line.obj-type and
         bf_place.obj-code = bf_rvs-line.obj-code and
         bf_place.pl-code  = bf_rvs-line.pl-code  .
      find first tt-petrol where tt-petrol.gds-code = bf_goods.gds-code and tt-petrol.pl-code = bf_rvs-line.pl-code no-error .
      if not available (tt-petrol) then
      do:
      end.
      create tt-petrol .
      assign
         tt-petrol.gds-code = bf_goods.gds-code
         tt-petrol.gds-name = bf_goods.gds-name
         tt-petrol.pl-code  = bf_rvs-line.pl-code
         tt-petrol.level    = bf_rvs-line.state-level-total * 10
         tt-petrol.volue    = bf_rvs-line.state-measure-qnty * 0.001
         tt-petrol.density  = bf_rvs-line.state-density * 1000
         tt-petrol.temp     = bf_rvs-line.state-temperature
         tt-petrol.qnty     = round(bf_rvs-line.state-measure-cli-qnty,3)
         tt-petrol.volue-pl = bf_rvs-line.add-qnty * 0.001
         tt-petrol.qnty1    = round((tt-petrol.volue-pl * tt-petrol.density),3)
         tt-petrol.pl-type  = "трубопровод"
         .
    find first c-rvs-doc no-lock where c-rvs-doc.rvs-code = bf_rvs-doc.rvs-code and c-rvs-doc.obj-code = bf_rvs-doc.obj-code and
      c-rvs-doc.obj-type = bf_rvs-doc.obj-type and c-rvs-doc.status_ = 'разрешен':U .
      for each rvs-line-attr no-lock
         where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
         and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
         and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
         and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
         and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
         :
         case rvs-line-attr.attr-code :
            when "delta-mass-qnty" then
               do :
                  delta-mass-qnty = decimal(rvs-line-attr.attr-value) .
               end.
            when "CriticalDif" then
               do :
                  CriticalDif = decimal(rvs-line-attr.attr-value) .
               end.
            when "place-twice-code" then
               do :
                  v-loc1 = rvs-line-attr.attr-value .
               end.
         end case.
      end.
    define variable pl-rvd-dens as logical   no-undo .
    define variable pl-rvd-lvl  as logical   no-undo .
    define variable pl-rvd-temp as logical   no-undo .
      define variable v-value as character no-undo .
      define variable v-ok    as logical   no-undo .
      run placelib_get-attr  ( input "place-error-mass"
         ,input bf_rvs-line.obj-code
         ,input bf_rvs-line.obj-type
         ,input bf_rvs-line.pl-code
         ,output v-value
         ,output v-ok      ) no-error.
      if not v-ok then pl-error-mass = ?.
      else pl-error-mass = decimal(v-value) .
      tt-petrol.log-pl = if tt-petrol.volue-pl <> 0 then "заполнено" else "не заполнено" .
      tt-petrol.delta = bf_rvs-line.state-measure-cli-qnty * delta-mass-qnty / 100 .
      tt-petrol.delta1 = bf_rvs-line.state-add-qnty * bf_rvs-line.state-density * pl-error-mass / 100 .
      if v-loc1 <> "" then  tt-petrol.pl-code_ = string(bf_place.loc1) + "," + v-loc1 .
      else tt-petrol.pl-code_ = string(bf_place.loc1) .
    run placelib_get-attr  ( input "place-passp-num"
      ,input bf_place.obj-code
      ,input bf_place.obj-type
      ,input bf_place.pl-code
      ,output v-value
      ,output v-ok      ) no-error.
    tt-petrol.place-num = v-value .
    run placelib_get-attr  ( input "place-passp-type"
      ,input bf_place.obj-code
      ,input bf_place.obj-type
      ,input bf_place.pl-code
      ,output v-value
      ,output v-ok      ) no-error.
    tt-petrol.place-type = v-value .
    define variable corr-date as date no-undo .
    define variable corr-time as integer no-undo .
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = bf_rvs-line.rvs-code and
    ub.inv-doc-attr.attr-code = "create_date" no-error .
    if available (ub.inv-doc-attr) then corr-date = date(ub.inv-doc-attr.attr-value). else corr-date = c-rvs-doc.corr-date .
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = bf_rvs-line.rvs-code and
    ub.inv-doc-attr.attr-code = "create_time" no-error .
    if available (ub.inv-doc-attr) then corr-time = integer(ub.inv-doc-attr.attr-value). else corr-time = c-rvs-doc.corr-time .
    if not get_meas(bf_rvs-line.obj-code, bf_rvs-line.obj-type, bf_rvs-line.pl-code,corr-date, corr-time) then
      tt-petrol.type_dan = "PВД" .
    else
    do:
      run c-place_get-attr (input "place-rvd-lvl"
        ,input bf_rvs-line.obj-code
        ,input bf_rvs-line.obj-type
        ,input bf_rvs-line.pl-code
        ,input corr-date
        ,input corr-time
        ,output v-value ) no-error .
      if v-value = "" then pl-rvd-lvl = false .
      else pl-rvd-lvl = not logical(v-value) .
      run c-place_get-attr (input "place-rvd-tmp"
        ,input bf_rvs-line.obj-code
        ,input bf_rvs-line.obj-type
        ,input bf_rvs-line.pl-code
        ,input corr-date
        ,input corr-time
        ,output v-value ) no-error .
      if v-value = "" then pl-rvd-temp = false .
      else pl-rvd-temp = not logical(v-value) .
      run c-place_get-attr (input "place-rvd-dnsty"
        ,input bf_rvs-line.obj-code
        ,input bf_rvs-line.obj-type
        ,input bf_rvs-line.pl-code
        ,input corr-date
        ,input corr-time
        ,output v-value ) no-error .
      if v-value = "" then pl-rvd-dens = false .
      else pl-rvd-dens = not logical(v-value) .
      if pl-rvd-dens or pl-rvd-lvl or pl-rvd-temp then tt-petrol.type_dan = "PВД" .
      else tt-petrol.type_dan = "AВД" .
    end.
  end.
end procedure .
  run waitfram-hide  in this-procedure .
end.
procedure table-inv:
  put stream OutStr-html unformatted
    '<Thead>' skip
    '<TR><TD colspan="86" style="height: 14px;"></TD></TR>' skip
    '<TR><TD colspan="86">При инвентаризации в резервуарах АЗС/АЗК установлено следующее:</TD></TR>' skip
    '</Thead>' skip
    .
  put stream OutStr-html unformatted
    '<TR style="height: 55px">' skip
    '<TD text_wrap="true" colspan = "4" rowspan = "2" style="text-align: center; border: 1px solid black;">№</TD>' skip
    '<TD text_wrap="true" colspan = "14" style="text-align: center; border: 1px solid black;">Нефтепродукт</TD>' skip
    '<TD text_wrap="true" colspan = "9" rowspan = "2" style="text-align: center; border: 1px solid black;">Тип, номер резервуара</TD>' skip
    '<TD text_wrap="true" colspan = "6" rowspan = "2" style="text-align: center; border: 1px solid black;">Тип ввода данных</TD>' skip
    '<TD text_wrap="true" colspan = "9" rowspan = "2" style="text-align: center; border: 1px solid black;">Уровень наполнения резервуара, мм</TD>' skip
    '<TD text_wrap="true" colspan = "8" rowspan = "2" style="text-align: center; border: 1px solid black;">Объем нефтепродукта, м3</TD>' skip
    '<TD text_wrap="true" colspan = "9" rowspan = "2" style="text-align: center; border: 1px solid black;">Плотность нефтепродукта, кг/м3</TD>' skip
    '<TD text_wrap="true" colspan = "9" rowspan = "2" style="text-align: center; border: 1px solid black;">Температура нефтепродукта, °С</TD>' skip
    '<TD text_wrap="true" colspan = "9" rowspan = "2" style="text-align: center; border: 1px solid black;">Масса нефтепродукта, кг</TD>' skip
    '<TD text_wrap="true" colspan = "9" rowspan = "2" style="text-align: center; border: 1px solid black;">Погрешность измерения, кг*</TD>' skip
    '</TR>'skip
    '<TR style="height: 35px">' skip
    '<TD text_wrap="true" colspan = "9" style="text-align: center; border: 1px solid black;">наимен.</TD>' skip
    '<TD text_wrap="true" colspan = "5" style="text-align: center; border: 1px solid black;">код</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan = "4" style="text-align: center; border: 1px solid black;">1</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">2</TD>' skip
    '<TD colspan = "5" style="text-align: center; border: 1px solid black;">3</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">4</TD>' skip
    '<TD colspan = "6" style="text-align: center; border: 1px solid black;">5</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">6</TD>' skip
    '<TD colspan = "8" style="text-align: center; border: 1px solid black;">7</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">8</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">9</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">10</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">11</TD>' skip
    '</TR>'skip
    .
  assign
    j_LineCount = 0
    .
  for each tt-petrol:
    j_LineCount = j_LineCount + 1 .
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD colspan = "4" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(j_LineCount) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" style="text-align: center; border: 1px solid black;">' + tt-petrol.gds-name + '</TD>' skip
      '<TD colspan = "5" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(tt-petrol.gds-code) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(tt-petrol.place-type) + " " + string(tt-petrol.place-num) + '</TD>' skip
      '<TD colspan = "6" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(tt-petrol.type_dan) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(tt-petrol.level,"->>>>>>>>>>>9",0) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.level,"->>>>>>>>>>>9",0) + '</TD>' skip
      '<TD colspan = "8" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.volue,"->>>>>>>>>>>9.999",3) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.volue,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.density,"->>>>>>>>>>>9.9",1) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.density,"->>>>>>>>>>>9.9",1) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.temp,"->>>>>>>>>>>9.9",1) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.temp,"->>>>>>>>>>>9.9",1) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.qnty,"->>>>>>>>>>>9.999",3) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.qnty,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.delta,"->>>>>>>>>>>9.999",3) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.delta,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '</TR>'skip
      .
  end.
  put stream OutStr-html unformatted
    '<Thead>' skip
    '<TR><TD colspan="86" style="height: 14px;"></TD></TR>' skip
    '<TR><TD colspan="86">Наличие нефтепродуктов в технологических трубопроводах и оборудовании:</TD></TR>' skip
    '</Thead>' skip
    .
  put stream OutStr-html unformatted
    '<TR style="height: 65px">' skip
    '<TD text_wrap="true" colspan = "4" rowspan = "2" style="text-align: center; border: 1px solid black;">№</TD>' skip
    '<TD text_wrap="true" colspan = "14" style="text-align: center; border: 1px solid black;">Нефтепродукт</TD>' skip
    '<TD text_wrap="true" colspan = "8" rowspan = "2" style="text-align: center; border: 1px solid black;">Наим. участка техн. трубопровода (оборуд)</TD>' skip
    '<TD text_wrap="true" colspan = "10" rowspan = "2" style="text-align: center; border: 1px solid black;">Вместимость (объем) участка трубопровода (оборуд), м3</TD>' skip
    '<TD text_wrap="true" colspan = "10" rowspan = "2" style="text-align: center; border: 1px solid black;">Факт заполнения на момент инвентар (заполнено/ не заполнено)</TD>' skip
    '<TD text_wrap="true" colspan = "10" rowspan = "2" style="text-align: center; border: 1px solid black;">Плотность нефтепродукта, кг/м3</TD>' skip
    '<TD text_wrap="true" colspan = "10" rowspan = "2" style="text-align: center; border: 1px solid black;">Температура нефтепродукта, °С</TD>' skip
    '<TD text_wrap="true" colspan = "10" rowspan = "2" style="text-align: center; border: 1px solid black;">Масса нефтепродукта, кг</TD>' skip
    '<TD text_wrap="true" colspan = "10" rowspan = "2" style="text-align: center; border: 1px solid black;">Погрешность измерения, кг**</TD>' skip
    '</TR>'skip
    '<TR style="height: 65px">' skip
    '<TD text_wrap="true" colspan = "9" style="text-align: center; border: 1px solid black;">наимен.</TD>' skip
    '<TD text_wrap="true" colspan = "5" style="text-align: center; border: 1px solid black;">код</TD>' skip
    '</TR>'skip
    '<TR>' skip
    '<TD colspan = "4" style="text-align: center; border: 1px solid black;">1</TD>' skip
    '<TD colspan = "9" style="text-align: center; border: 1px solid black;">2</TD>' skip
    '<TD colspan = "5" style="text-align: center; border: 1px solid black;">3</TD>' skip
    '<TD colspan = "8" style="text-align: center; border: 1px solid black;">4</TD>' skip
    '<TD colspan = "10" style="text-align: center; border: 1px solid black;">5</TD>' skip
    '<TD colspan = "10" style="text-align: center; border: 1px solid black;">6</TD>' skip
    '<TD colspan = "10" style="text-align: center; border: 1px solid black;">7</TD>' skip
    '<TD colspan = "10" style="text-align: center; border: 1px solid black;">8</TD>' skip
    '<TD colspan = "10" style="text-align: center; border: 1px solid black;">9</TD>' skip
    '<TD colspan = "10" style="text-align: center; border: 1px solid black;">10</TD>' skip
    '</TR>'skip
    .
  assign
    j_LineCount = 0
    .
  for each tt-petrol:
    j_LineCount = j_LineCount + 1 .
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD colspan = "4" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(j_LineCount) + '</TD>' skip
      '<TD colspan = "9" text_wrap="true" style="text-align: center; border: 1px solid black;">' + tt-petrol.gds-name + '</TD>' skip
      '<TD colspan = "5" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(tt-petrol.gds-code) + '</TD>' skip
      '<TD colspan = "8" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(tt-petrol.pl-type) + '</TD>' skip
      '<TD colspan = "10" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.volue-pl,"->>>>>>>>>>>9.999",3) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.volue-pl,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD colspan = "10" text_wrap="true" style="text-align: center; border: 1px solid black;">' + string(tt-petrol.log-pl) + '</TD>' skip
      '<TD colspan = "10" text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.density,"->>>>>>>>>>>9.9",1) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.density,"->>>>>>>>>>>9.9",1) + '</TD>' skip
      '<TD colspan = "10" text_wrap="true" num="0.0" val="' + fnc-convert-dot-to-colon(tt-petrol.temp,"->>>>>>>>>>>9.9",1) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.temp,"->>>>>>>>>>>9.9",1) + '</TD>' skip
      '<TD colspan = "10" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.qnty1,"->>>>>>>>>>>9.999",3) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.qnty1,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '<TD colspan = "10" text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(tt-petrol.delta1,"->>>>>>>>>>>9.999",3) + '" style="text-align: center; border: 1px solid black;">' + fnc-convert-dot-to-colon(tt-petrol.delta1,"->>>>>>>>>>>9.999",3) + '</TD>' skip
      '</TR>'skip
      .
  end.
end procedure .
PROCEDURE get-report-num :
  define output parameter p-report-num as integer no-undo .
  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.
END PROCEDURE.
