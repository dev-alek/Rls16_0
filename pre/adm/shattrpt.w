DEFINE BUFFER locked_thbj-attr FOR thbj-attr.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE       NO-UNDO.
DEFINE INPUT PARAMETER p-mode        AS CHARACTER           NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type  LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code  LIKE ub.shop.obj-code    NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision: 8482156d642d, 3444, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:33 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shattrpt.w $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/shattrpt.w $":U .
define variable vss-description as character no-undo init "Экран настроек работы с топливном".
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
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
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
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_twowin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    field selLeft       as logical
    field selRight      as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_twowin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-twowin6-itm-key    as integer      no-undo.
procedure twowin_clear :
    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    empty temp-table buf_temp_twowin_items.
end.
end procedure.
procedure twowin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
    define buffer buf_temp_twowin_items        for temp_twowin_items.
do
for buf_temp_twowin_items
on error undo, return error
:
    assign
        v-twowin6-itm-key = v-twowin6-itm-key + 1
    .
    create temp_twowin_items.
    assign
        temp_twowin_items.itm-key      = v-twowin6-itm-key
        temp_twowin_items.itmExtKey    = p-ext-key
        temp_twowin_items.itmName      = p-item-name
        temp_twowin_items.itmDesc      = p-item-desc
        temp_twowin_items.itmSelected  = p-selected
        temp_twowin_items.selLeft      = no
        temp_twowin_items.selRight     = no
    .
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure sys-time_get-sys :
  define output parameter p-year         as integer   no-undo .
  define output parameter p-month        as integer   no-undo .
  define output parameter p-day          as integer   no-undo .
  define output parameter p-hour         as integer   no-undo .
  define output parameter p-minute       as integer   no-undo .
  define output parameter p-second       as integer   no-undo .
  define output parameter p-milliseconds as integer   no-undo .
  define variable v-system-time-structure as memptr    no-undo.
  do
  on error undo, return error return-value
  :
    assign
      set-size(v-system-time-structure) = 16
    .
    run GetSystemTime
      (input  get-pointer-value(v-system-time-structure)
      ) .
    assign
      p-year         = get-short(v-system-time-structure,  1)
      p-month        = get-short(v-system-time-structure,  3)
      p-day          = get-short(v-system-time-structure,  7)
      p-hour         = get-short(v-system-time-structure,  9)
      p-minute       = get-short(v-system-time-structure, 11)
      p-second       = get-short(v-system-time-structure, 13)
      p-milliseconds = get-short(v-system-time-structure, 15)
    .
    assign
      set-size(v-system-time-structure) = 0
    .
  end.
end procedure.
procedure sys-time_get-comp-user-name :
  define output parameter p-computer-name as character no-undo .
  define output parameter p-user-name     as character no-undo .
  define output parameter p-process-pid   as integer   no-undo .
  define variable v-return-value  as integer   no-undo .
  define variable v-buffer-length as integer   no-undo .
  define variable v-buffer-memptr as memptr    no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-buffer-length = 1024
      set-size(v-buffer-memptr) = v-buffer-length + 4
    .
    assign
      put-long(v-buffer-memptr, 1) = v-buffer-length
    .
    run GetComputerNameA
      (input  get-pointer-value(v-buffer-memptr) + 4
      ,input  get-pointer-value(v-buffer-memptr)
      ,output v-return-value
      ) .
    if v-return-value <> 0
    then do:
      assign
        p-computer-name = get-string(v-buffer-memptr, 5)
      .
    end.
    assign
      put-long(v-buffer-memptr, 1) = v-buffer-length
    .
    run GetUserNameA
      (input  get-pointer-value(v-buffer-memptr) + 4
      ,input  get-pointer-value(v-buffer-memptr)
      ,output v-return-value
      ) .
    if v-return-value <> 0
    then do:
      assign
        p-user-name = get-string(v-buffer-memptr, 5)
      .
    end.
    run GetCurrentProcessId
      (output p-process-pid
      ) .
    assign
      set-size(v-buffer-memptr) = 0
    .
  end.
end procedure.
procedure sys-time_get-http :
  define output parameter p-http-time as character no-undo .
  define variable v-year         as integer   no-undo .
  define variable v-month        as integer   no-undo .
  define variable v-day-of-week  as integer   no-undo .
  define variable v-day          as integer   no-undo .
  define variable v-hour         as integer   no-undo .
  define variable v-minute       as integer   no-undo .
  define variable v-second       as integer   no-undo .
  define variable v-milliseconds as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run sys-time_get-sys in this-procedure
      (output v-year
      ,output v-month
      ,output v-day
      ,output v-hour
      ,output v-minute
      ,output v-second
      ,output v-milliseconds
      ) .
    assign
      v-day-of-week = weekday(date(v-month, v-day, v-year))
      p-http-time = entry(v-day-of-week, 'Sun,Mon,Tue,Wed,Thu,Fri,Sat')
                  + ', ':u
                  + string(v-day, '99':u)
                  + ' ':u
                  + entry(v-month, 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec':u)
                  + ' ':u
                  + string(v-year, '9999':u)
                  + ' ':u
                  + string(v-hour, '99':u)
                  + ':':u
                  + string(v-minute, '99':u)
                  + ':':u
                  + string(v-second, '99':u)
                  + ' ':u
                  + 'GMT':u
    .
  end.
end procedure.
procedure sys-time_set-sys :
  define input  parameter p-year         as integer   no-undo .
  define input  parameter p-month        as integer   no-undo .
  define input  parameter p-day          as integer   no-undo .
  define input  parameter p-hour         as integer   no-undo .
  define input  parameter p-minute       as integer   no-undo .
  define input  parameter p-second       as integer   no-undo .
  define input  parameter p-milliseconds as integer   no-undo .
  define variable v-system-time-structure as memptr    no-undo.
  define variable v-return-value as integer   no-undo .
  define variable v-day-of-week  as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-day-of-week = weekday(date(p-month, p-day, p-year))
    .
    assign
      set-size(v-system-time-structure) = 16
    .
    assign
      put-short(v-system-time-structure,  1) = p-year
      put-short(v-system-time-structure,  3) = p-month
      put-short(v-system-time-structure,  5) = v-day-of-week
      put-short(v-system-time-structure,  7) = p-day
      put-short(v-system-time-structure,  9) = p-hour
      put-short(v-system-time-structure, 11) = p-minute
      put-short(v-system-time-structure, 13) = p-second
      put-short(v-system-time-structure, 15) = p-milliseconds
    .
    run SetSystemTime
      (input  get-pointer-value(v-system-time-structure)
      ,output v-return-value
      ) .
    assign
      set-size(v-system-time-structure) = 0
    .
    if v-return-value = 0
    then do:
      undo, return error "sys-time_set-sys: Ошибка при установке даты" .
    end.
  end.
end procedure.
procedure sys-time_sys-to-mjd :
  define input  parameter p-year         as integer   no-undo .
  define input  parameter p-month        as integer   no-undo .
  define input  parameter p-day          as integer   no-undo .
  define input  parameter p-hour         as integer   no-undo .
  define input  parameter p-minute       as integer   no-undo .
  define input  parameter p-second       as integer   no-undo .
  define input  parameter p-milliseconds as integer   no-undo .
  define output parameter p-mjd          as decimal   no-undo .
  define variable v-year-correction as decimal   no-undo .
  define variable v-shift-year as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-year-correction = truncate((decimal(p-month) - 14.0) / 12, 0)
      v-shift-year      = decimal(p-year) + v-year-correction
      p-mjd = truncate( (1461.0 * (v-shift-year + 4800.0 ) ) / 4, 0)
            + truncate( (367.0 * (decimal(p-month) - 2.0 - v-year-correction * 12) ) / 12, 0)
            - truncate( (3 * truncate((v-shift-year + 4900 ) / 100,0) ) / 4, 0)
            + decimal(p-day) - 2432076.0
            + p-hour / 24.0
            + p-minute / 1440.0
            + p-second / 86400.0
            + p-milliseconds / 86400000.0
    .
  end.
end procedure.
procedure sys-time_sys-to-loc :
  define input  parameter p-sys-year         as integer   no-undo .
  define input  parameter p-sys-month        as integer   no-undo .
  define input  parameter p-sys-day          as integer   no-undo .
  define input  parameter p-sys-hour         as integer   no-undo .
  define input  parameter p-sys-minute       as integer   no-undo .
  define input  parameter p-sys-second       as integer   no-undo .
  define input  parameter p-sys-milliseconds as integer   no-undo .
  define output parameter p-loc-year         as integer   no-undo .
  define output parameter p-loc-month        as integer   no-undo .
  define output parameter p-loc-day          as integer   no-undo .
  define output parameter p-loc-hour         as integer   no-undo .
  define output parameter p-loc-minute       as integer   no-undo .
  define output parameter p-loc-second       as integer   no-undo .
  define output parameter p-loc-milliseconds as integer   no-undo .
  define variable v-system-time-structure as memptr    no-undo.
  define variable v-return-value          as integer   no-undo .
  define variable v-sys-day-of-week       as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-sys-day-of-week = weekday(date(p-sys-month, p-sys-day, p-sys-year))
    .
    assign
      set-size(v-system-time-structure) = 32
    .
    assign
      put-short(v-system-time-structure,  1) = p-sys-year
      put-short(v-system-time-structure,  3) = p-sys-month
      put-short(v-system-time-structure,  5) = v-sys-day-of-week
      put-short(v-system-time-structure,  7) = p-sys-day
      put-short(v-system-time-structure,  9) = p-sys-hour
      put-short(v-system-time-structure, 11) = p-sys-minute
      put-short(v-system-time-structure, 13) = p-sys-second
      put-short(v-system-time-structure, 15) = p-sys-milliseconds
    .
    run SystemTimeToTzSpecificLocalTime
      (input  0
      ,input  get-pointer-value(v-system-time-structure)
      ,input  get-pointer-value(v-system-time-structure) + 16
      ,output v-return-value
      ) .
    assign
      p-loc-year         = get-short(v-system-time-structure,  1 + 16)
      p-loc-month        = get-short(v-system-time-structure,  3 + 16)
      p-loc-day          = get-short(v-system-time-structure,  7 + 16)
      p-loc-hour         = get-short(v-system-time-structure,  9 + 16)
      p-loc-minute       = get-short(v-system-time-structure, 11 + 16)
      p-loc-second       = get-short(v-system-time-structure, 13 + 16)
      p-loc-milliseconds = get-short(v-system-time-structure, 15 + 16)
    .
    assign
      set-size(v-system-time-structure) = 0
    .
    if v-return-value = 0
    then do:
      undo, return error "sys-time_set-sys: Ошибка при установке даты" .
    end.
  end.
end procedure.
procedure sys-time_mjd-to-sys :
  define input  parameter p-mjd          as decimal   no-undo .
  define output parameter p-year         as integer   no-undo .
  define output parameter p-month        as integer   no-undo .
  define output parameter p-day          as integer   no-undo .
  define output parameter p-hour         as integer   no-undo .
  define output parameter p-minute       as integer   no-undo .
  define output parameter p-second       as integer   no-undo .
  define output parameter p-milliseconds as integer   no-undo .
  define variable v-year-correction as decimal   no-undo .
  define variable v-shift-year      as decimal   no-undo .
  define variable v-conv-date     as date      no-undo .
  define variable v-int-part      as integer   no-undo .
  define variable v-fraction-part as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-int-part      = integer(truncate(p-mjd, 0))
      v-fraction-part = p-mjd - v-int-part
      v-conv-date     = date(11, 17, 1858) + v-int-part
      p-year          = year(v-conv-date)
      p-month         = month(v-conv-date)
      p-day           = day(v-conv-date)
      v-fraction-part = v-fraction-part * 24.0
      p-hour          = integer(truncate(v-fraction-part, 0))
      v-fraction-part = (v-fraction-part - p-hour) * 60.0
      p-minute        = integer(truncate(v-fraction-part, 0))
      v-fraction-part = (v-fraction-part - p-minute) * 60.0
      p-second        = integer(truncate(v-fraction-part, 0))
      v-fraction-part = (v-fraction-part - p-second) * 1000.0
      p-milliseconds  = integer(v-fraction-part)
    .
  end.
end procedure.
procedure sys-time_mjd-to-loc :
  define input  parameter p-mjd              as decimal   no-undo .
  define output parameter p-loc-year         as integer   no-undo .
  define output parameter p-loc-month        as integer   no-undo .
  define output parameter p-loc-day          as integer   no-undo .
  define output parameter p-loc-hour         as integer   no-undo .
  define output parameter p-loc-minute       as integer   no-undo .
  define output parameter p-loc-second       as integer   no-undo .
  define output parameter p-loc-milliseconds as integer   no-undo .
  define variable v-sys-year         as integer   no-undo .
  define variable v-sys-month        as integer   no-undo .
  define variable v-sys-day          as integer   no-undo .
  define variable v-sys-hour         as integer   no-undo .
  define variable v-sys-minute       as integer   no-undo .
  define variable v-sys-second       as integer   no-undo .
  define variable v-sys-milliseconds as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run sys-time_mjd-to-sys
      (input  p-mjd
      ,output v-sys-year
      ,output v-sys-month
      ,output v-sys-day
      ,output v-sys-hour
      ,output v-sys-minute
      ,output v-sys-second
      ,output v-sys-milliseconds
      ) .
    run sys-time_sys-to-loc
      (input  v-sys-year
      ,input  v-sys-month
      ,input  v-sys-day
      ,input  v-sys-hour
      ,input  v-sys-minute
      ,input  v-sys-second
      ,input  v-sys-milliseconds
      ,output p-loc-year
      ,output p-loc-month
      ,output p-loc-day
      ,output p-loc-hour
      ,output p-loc-minute
      ,output p-loc-second
      ,output p-loc-milliseconds
      ) .
  end.
end procedure.
function sys-time_get-mjd-func returns decimal
:
  define variable v-year         as integer   no-undo .
  define variable v-month        as integer   no-undo .
  define variable v-day          as integer   no-undo .
  define variable v-hour         as integer   no-undo .
  define variable v-minute       as integer   no-undo .
  define variable v-second       as integer   no-undo .
  define variable v-milliseconds as integer   no-undo .
  define variable v-mjd          as decimal   no-undo .
  run sys-time_get-sys in this-procedure
    (output v-year
    ,output v-month
    ,output v-day
    ,output v-hour
    ,output v-minute
    ,output v-second
    ,output v-milliseconds
    ) .
  run sys-time_sys-to-mjd in this-procedure
    (input  v-year
    ,input  v-month
    ,input  v-day
    ,input  v-hour
    ,input  v-minute
    ,input  v-second
    ,input  v-milliseconds
    ,output v-mjd
    ) .
  return v-mjd .
end function .
function sys-time_get-sys-str-func returns character
:
  define variable v-utc-time as character no-undo .
  define variable v-year         as integer   no-undo .
  define variable v-month        as integer   no-undo .
  define variable v-day          as integer   no-undo .
  define variable v-hour         as integer   no-undo .
  define variable v-minute       as integer   no-undo .
  define variable v-second       as integer   no-undo .
  define variable v-milliseconds as integer   no-undo .
  run sys-time_get-sys in this-procedure
    (output v-year
    ,output v-month
    ,output v-day
    ,output v-hour
    ,output v-minute
    ,output v-second
    ,output v-milliseconds
    ) .
  assign
    v-utc-time  = 'UTC ':u
                + string(v-year,         '9999':u)
                + '/':u
                + string(v-month,        '99':u)
                + '/':u
                + string(v-day,          '99':u)
                + ' ':u
                + string(v-hour,         '99':u)
                + ':':u
                + string(v-minute,       '99':u)
                + ':':u
                + string(v-second,       '99':u)
                + ' ':u
                + string(v-milliseconds, '999':u)
  .
  return v-utc-time.
end function .
function sys-time_mjd-to-loc-str-func returns character
  (v-sys-mjd as decimal)
:
  define variable v-loc-str          as character no-undo .
  define variable v-loc-year         as integer   no-undo .
  define variable v-loc-month        as integer   no-undo .
  define variable v-loc-day          as integer   no-undo .
  define variable v-loc-hour         as integer   no-undo .
  define variable v-loc-minute       as integer   no-undo .
  define variable v-loc-second       as integer   no-undo .
  define variable v-loc-milliseconds as integer   no-undo .
  run sys-time_mjd-to-loc in this-procedure
    (input  v-sys-mjd
    ,output v-loc-year
    ,output v-loc-month
    ,output v-loc-day
    ,output v-loc-hour
    ,output v-loc-minute
    ,output v-loc-second
    ,output v-loc-milliseconds
    ) .
  assign
    v-loc-str = substitute('&1/&2/&3 &4:&5'
                          ,string(v-loc-day,    '99':U)
                          ,string(v-loc-month,  '99':U)
                          ,string(v-loc-year,   '9999':U)
                          ,string(v-loc-hour,   '99':U)
                          ,string(v-loc-minute, '99':U)
                          )
  .
  return v-loc-str .
end function .
PROCEDURE GetSystemTime EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpSystemTime AS LONG .
END PROCEDURE.
PROCEDURE SetSystemTime EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpSystemTime AS LONG .
  DEFINE RETURN PARAMETER ReturnValue  AS LONG .
END PROCEDURE.
PROCEDURE GetTimeZoneInformation EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpTimeZoneInformation AS LONG .
  DEFINE RETURN PARAMETER ReturnValue           AS LONG .
END PROCEDURE.
PROCEDURE SystemTimeToTzSpecificLocalTime EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpTimeZone      AS LONG .
  DEFINE INPUT  PARAMETER lpUniversalTime AS LONG .
  DEFINE INPUT  PARAMETER lpLocalTime     AS LONG .
  DEFINE RETURN PARAMETER ReturnValue     AS LONG .
END PROCEDURE.
PROCEDURE GetUserNameA EXTERNAL "advapi32.dll"
:
  DEFINE INPUT  PARAMETER lpBuffer    AS LONG .
  DEFINE INPUT  PARAMETER lpnSize     AS LONG .
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.
PROCEDURE GetComputerNameA EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpBuffer    AS LONG .
  DEFINE INPUT  PARAMETER lpnSize     AS LONG .
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.
PROCEDURE GetCurrentProcessId EXTERNAL "kernel32.dll"
:
  DEFINE RETURN PARAMETER RetVal          AS LONG.
END PROCEDURE.
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth           as   handle       no-undo .
define variable v-to-create     as   logical      no-undo .
DEFINE VARIABLE v-db-num        like ub.db.db-num no-undo.
define variable v-list-dop-info-full as character    no-undo.
define variable v-list-dop-info      as character    no-undo.
define temp-table temp_twowin_itemsSelected_col no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
      its-key
    index im
      itm-key
.
define variable v-list-sec-fields-full as character    no-undo.
define variable v-list-sec-fields      as character    no-undo.
define temp-table sect_twowin_itemsSelected_col no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
      its-key
    index im
      itm-key
.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-invclipt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY .92.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-set_dop-info
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 2.63 BY 1.08.
DEFINE BUTTON B-set_sec-fields
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL ""
     SIZE 2.63 BY 1.08.
DEFINE VARIABLE dop-info AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 28.5 BY 4.5 NO-UNDO.
DEFINE VARIABLE sec-fields AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 1 BY 1 NO-UNDO.
DEFINE VARIABLE Dev-paid-trans AS DECIMAL FORMAT "->9.99":U INITIAL 1
     VIEW-AS FILL-IN
     SIZE 6 BY 1
     NO-UNDO.
DEFINE VARIABLE f-invclipt LIKE clients.obj-code
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE f-invclipt-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 78 BY 1 NO-UNDO.
DEFINE VARIABLE mass-proc AS CHARACTER FORMAT "X(256)":U
     LABEL "Допустимый % расхождения массы в резервуаре"
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE mass-proc-in-lgas AS DECIMAL FORMAT ">9.99":U INITIAL 0
     LABEL "Допустимый % расхождения массы при приеме СУГ"
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE otkl-density AS CHARACTER FORMAT "9X999":U INITIAL "0.000"
     LABEL "Плотности"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE otkl-fact-volue AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Фактического объема"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE otkl-temp AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Температуры"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE otkl-water AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Воды"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE Prc-dev-mass AS DECIMAL FORMAT "->9.99":U INITIAL .65
     VIEW-AS FILL-IN
     SIZE 6 BY 1
     NO-UNDO.
DEFINE VARIABLE qr-scan-time AS INTEGER FORMAT ">>>>>9":U INITIAL 5000
     LABEL "Время на сканирование QR-кода (мс)"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE rvs-wt-email AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 90 BY .92 NO-UNDO.
DEFINE VARIABLE t-autopump-skip-time AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Время после приема НП (мин)"
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE timeout-block-nozzle AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 5
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-dop-info AS CHARACTER FORMAT "X(256)":U INITIAL "Обязательные поля доп.инфо. ПН по НП"
      VIEW-AS TEXT
     SIZE 37.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-sec-fields AS CHARACTER FORMAT "X(256)":U INITIAL "Обязательные поля в секциях ПН по НП"
      VIEW-AS TEXT
     SIZE 37.5 BY 1 NO-UNDO.
DEFINE VARIABLE r-algoincptrl AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "стандарт", 1,
"с комиссионным приемом", 2
     SIZE 37 BY 1 NO-UNDO.
DEFINE VARIABLE r-algrvspt AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Алгоритм N1", 1,
"Алгоритм N2", 2,
"Алгоритм N3", 3,
"Алгоритм N4", 4
     SIZE 92.5 BY .83 NO-UNDO.
DEFINE VARIABLE r-denstclc AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "среднее по сменной сверке и внеш.приходам (shft_rvs-inc)", "shft_rvs-inc",
"среднее по сверкам (avrg-rvs)", "avrg-rvs",
"среднеарифметическое значение окаймляющих сверок (avrg-chk)", "avrg-chk",
"среднее значение по расчетно-книжным данным (shft_sys-inc)", "shft_sys-inc",
"плотность, аппроксимирующая расчетно-книжные остатки к фактическим (fact-approx)", "fact-approx"
     SIZE 84.5 BY 2.5 NO-UNDO.
DEFINE VARIABLE r-expptrl AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Масса", "weight",
"Объем", "volume"
     SIZE 23.5 BY .83 NO-UNDO.
DEFINE VARIABLE r-inpptrl AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Масса+плотность", "weight",
"Объем+плотность", "volume",
"Масса+объем", "weight+",
"Объем+масса", "volume+"
     SIZE 66 BY .83 NO-UNDO.
DEFINE VARIABLE r-temp-for-pomi AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "15°С", 1,
"20°С", 2
     SIZE 17 BY .75 TOOLTIP "Используется только при передаче в ПО к МИ" NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 3.75.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 6.5.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 7.5.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 5.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 56.38 BY 2.5.
DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 40 BY 5.5.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 56.38 BY 3.
DEFINE VARIABLE t-autopump AS LOGICAL INITIAL no
     LABEL "Автоматические сверки создавать с чтением всех счетчиков ТРК"
     VIEW-AS TOGGLE-BOX
     SIZE 82.5 BY .83 NO-UNDO.
DEFINE VARIABLE t-autopump-izm AS LOGICAL INITIAL no
     LABEL "Автоматические сверки создавать только по измеряемым резервуарам"
     VIEW-AS TOGGLE-BOX
     SIZE 82.5 BY .83 NO-UNDO.
DEFINE VARIABLE t-avtinvpm AS LOGICAL INITIAL no
     LABEL "Автомат. создание инв. счетчиков ТРК при переполнении разрядности эл. счетчика"
     VIEW-AS TOGGLE-BOX
     SIZE 82.5 BY .83 TOOLTIP "если включено, то контроль и создание происходит при закрытии сверки" NO-UNDO.
DEFINE VARIABLE t-block-nozzle AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE t-calc-free-vol AS LOGICAL INITIAL no
     LABEL "Контроль свободного объема в резервуаре при приеме НП"
     VIEW-AS TOGGLE-BOX
     SIZE 60.5 BY .79 NO-UNDO.
DEFINE VARIABLE t-calc-free-vol-sug AS LOGICAL INITIAL no
     LABEL "Контроль свободного объема в резервуаре при приеме СУГ"
     VIEW-AS TOGGLE-BOX
     SIZE 60.5 BY .79 NO-UNDO.
DEFINE VARIABLE t-invclipt AS LOGICAL INITIAL no
     LABEL "Контрагент для списания ЕУ при инвентаризации топлива по сверке:"
     VIEW-AS TOGGLE-BOX
     SIZE 83 BY .83 NO-UNDO.
DEFINE VARIABLE t-mand-chioce-autocar AS LOGICAL INITIAL no
     LABEL "Обязательный выбор автотранспорта из справочника"
     VIEW-AS TOGGLE-BOX
     SIZE 60.5 BY .79 NO-UNDO.
DEFINE VARIABLE t-olddens AS LOGICAL INITIAL no
     LABEL "В документы по умолчанию ставится плотность и темп. из предыдущего документа"
     VIEW-AS TOGGLE-BOX
     SIZE 81.5 BY .83 NO-UNDO.
DEFINE VARIABLE t-rvd-own-nb AS LOGICAL INITIAL no
     LABEL "Разрешить ручное заполнение документа приёма НП при поставках с собственных НБ"
     VIEW-AS TOGGLE-BOX
     SIZE 83 BY .83 NO-UNDO.
DEFINE VARIABLE t-rvsnmter AS LOGICAL INITIAL no
     LABEL "Расхождение в инвентаризации по сверке делать без учета погрешности измерения"
     VIEW-AS TOGGLE-BOX
     SIZE 82.5 BY .83 NO-UNDO.
DEFINE VARIABLE t-trn-reas-sug AS LOGICAL INITIAL no
     LABEL "Обязательный выбор этапа для приема газовоза"
     VIEW-AS TOGGLE-BOX
     SIZE 60.5 BY .79 NO-UNDO.
DEFINE VARIABLE t-trnscanqr AS LOGICAL INITIAL no
     LABEL "Автозаполнение НП"
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY .83 NO-UNDO.
DEFINE FRAME shattrpt
     B-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11 WIDGET-ID 6
     B-Help AT ROW 1 COL 96 WIDGET-ID 4
     t-autopump-izm AT ROW 2 COL 3 WIDGET-ID 40
     t-autopump AT ROW 3 COL 3 WIDGET-ID 40
     t-avtinvpm AT ROW 4 COL 3 WIDGET-ID 42
     t-olddens AT ROW 5 COL 3 WIDGET-ID 76
     r-expptrl AT ROW 6.29 COL 70 NO-LABEL WIDGET-ID 50
     dop-info AT ROW 7 COL 69.5 NO-LABEL WIDGET-ID 492
     r-inpptrl AT ROW 8 COL 4 NO-LABEL WIDGET-ID 44
     sec-fields AT ROW 9.5 COL 69.5 NO-LABEL WIDGET-ID 592
     rvs-wt-email AT ROW 10.71 COL 3.5 NO-LABEL WIDGET-ID 90
     B-set_dop-info AT ROW 11.5 COL 41 WIDGET-ID 496
     B-set_sec-fields AT ROW 12.5 COL 41 WIDGET-ID 596
     r-algrvspt AT ROW 14.79 COL 3.5 NO-LABEL WIDGET-ID 80
     t-rvsnmter AT ROW 16 COL 3.5 WIDGET-ID 58
     t-invclipt AT ROW 17 COL 3.5 WIDGET-ID 74
     f-invclipt AT ROW 18 COL 3 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 60
     b-invclipt AT ROW 18 COL 15.5 WIDGET-ID 68
     r-temp-for-pomi AT ROW 19 COL 64 NO-LABEL WIDGET-ID 96
     r-denstclc AT ROW 20.79 COL 3.5 NO-LABEL WIDGET-ID 32
     mass-proc AT ROW 23.79 COL 46.5 COLON-ALIGNED WIDGET-ID 100
     mass-proc-in-lgas AT ROW 24.79 COL 3.5 WIDGET-ID 518
     r-algoincptrl AT ROW 26.08 COL 38.13 NO-LABEL WIDGET-ID 118
     t-mand-chioce-autocar AT ROW 27.21 COL 3.63 WIDGET-ID 106
     otkl-fact-volue AT ROW 29.5 COL 84.75 COLON-ALIGNED WIDGET-ID 506
     otkl-temp AT ROW 30.5 COL 84.75 COLON-ALIGNED WIDGET-ID 508
     Prc-dev-mass AT ROW 31.17 COL 54 RIGHT-ALIGNED NO-LABEL WIDGET-ID 616
     otkl-density AT ROW 31.5 COL 84.75 COLON-ALIGNED WIDGET-ID 510
     otkl-water AT ROW 32.5 COL 84.75 COLON-ALIGNED WIDGET-ID 512
     Dev-paid-trans AT ROW 32.58 COL 54 RIGHT-ALIGNED NO-LABEL WIDGET-ID 8
     t-calc-free-vol AT ROW 34 COL 2.5 WIDGET-ID 524
     t-calc-free-vol-sug AT ROW 35 COL 2.5 WIDGET-ID 524
     t-trn-reas-sug AT ROW 36 COL 2.5 WIDGET-ID 526
     t-trnscanqr AT ROW 37 COL 2.5 WIDGET-ID 128
     t-rvd-own-nb AT ROW 38 COL 2.5 WIDGET-ID 528
     qr-scan-time AT ROW 39 COL 36.5 COLON-ALIGNED WIDGET-ID 538
     t-autopump-skip-time AT ROW 39 COL 87 COLON-ALIGNED WIDGET-ID 250
     t-block-nozzle AT ROW 40.25 COL 2.5 WIDGET-ID 600
     timeout-block-nozzle AT ROW 41.13 COL 2.5 NO-LABEL WIDGET-ID 604
     v-dop-info AT ROW 11.5 COL 3.5 NO-LABEL WIDGET-ID 498
     v-sec-fields AT ROW 12.5 COL 1.5 COLON-ALIGNED NO-LABEL WIDGET-ID 598
     f-invclipt-name AT ROW 18 COL 17 COLON-ALIGNED NO-LABEL WIDGET-ID 72
     "Допустимое отклонение между объемом продаж" VIEW-AS TEXT
          SIZE 43 BY .63 AT ROW 32.58 COL 3.25 WIDGET-ID 620
     "топлива на кассе и объемом по счетчик" VIEW-AS TEXT
          SIZE 43.5 BY .58 AT ROW 33.29 COL 3.25 WIDGET-ID 618
     "до 200т. - ±0,65%     более 200т. - ±0,5%" VIEW-AS TEXT
          SIZE 42 BY .67 AT ROW 30.17 COL 3.5 WIDGET-ID 610
     "Тип ввода топлива в документах прихода внешнего :" VIEW-AS TEXT
          SIZE 49 BY .83 AT ROW 7 COL 3.5 WIDGET-ID 48
     "Максимально допустимые отклонения:" VIEW-AS TEXT
          SIZE 33.75 BY .79 AT ROW 28.58 COL 62 WIDGET-ID 504
     "Отправлять блокировку пистолетов при приемке" VIEW-AS TEXT
          SIZE 46.63 BY .67 AT ROW 40.25 COL 4.88 WIDGET-ID 602
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE  WIDGET-ID 100.
DEFINE FRAME shattrpt
     "Тип ввода топлива во всех документах кроме прихода внешнего :" VIEW-AS TEXT
          SIZE 63 BY .83 AT ROW 6.29 COL 3.5 WIDGET-ID 514
     "Настройки инвентаризации по сверке" VIEW-AS TEXT
          SIZE 35.5 BY .67 AT ROW 14 COL 3 WIDGET-ID 78
     "Timeout ожидания подтверждения блокировки пистолетов, с" VIEW-AS TEXT
          SIZE 57.5 BY .67 AT ROW 41.25 COL 11 WIDGET-ID 606
     "При приеме новостей, если в сверке вода, отправлять сообщения" VIEW-AS TEXT
          SIZE 64.5 BY .96 AT ROW 9 COL 3.5 WIDGET-ID 92
     "Алгоритм вычисления плотности топлива для продаж :" VIEW-AS TEXT
          SIZE 50.5 BY .63 AT ROW 20.08 COL 3.5 WIDGET-ID 36
     "на список почтовых адресов(разделять адреса запятыми):" VIEW-AS TEXT
          SIZE 62.5 BY .96 AT ROW 9.79 COL 3.5 WIDGET-ID 94
     "Относительная предельная погрешность" VIEW-AS TEXT
          SIZE 37 BY .67 AT ROW 28.58 COL 5.88 WIDGET-ID 112
     "Алгоритм принятия топлива к учету:" VIEW-AS TEXT
          SIZE 34.5 BY 1 AT ROW 26.08 COL 3.63 WIDGET-ID 116
     "Температура, к которой приводится плотность и объем °С :" VIEW-AS TEXT
          SIZE 58 BY .83 AT ROW 19 COL 3.5 WIDGET-ID 516
     "метода измерения массы в резервуаре" VIEW-AS TEXT
          SIZE 36 BY .67 AT ROW 29.42 COL 6.13 WIDGET-ID 608
     "топлива на конец смены" VIEW-AS TEXT
          SIZE 38.75 BY .58 AT ROW 31.88 COL 3.25 WIDGET-ID 626
     "Процент допустимого отклонения массы" VIEW-AS TEXT
          SIZE 38.25 BY .75 AT ROW 31.17 COL 3.25 WIDGET-ID 622
     "%" VIEW-AS TEXT
          SIZE 2.5 BY 1 AT ROW 31.17 COL 56 WIDGET-ID 624
     "л." VIEW-AS TEXT
          SIZE 2.5 BY 1 AT ROW 32.58 COL 56 WIDGET-ID 10
     RECT-1 AT ROW 20 COL 2.5 WIDGET-ID 38
     RECT-2 AT ROW 13.5 COL 2.5 WIDGET-ID 64
     RECT-3 AT ROW 6.08 COL 2.5 WIDGET-ID 66
     RECT-4 AT ROW 23.5 COL 2.5 WIDGET-ID 84
     RECT-5 AT ROW 28.5 COL 2.63 WIDGET-ID 500
     RECT-6 AT ROW 28.5 COL 59 WIDGET-ID 502
     RECT-7 AT ROW 31 COL 2.63 WIDGET-ID 612
     SPACE(40.86) SKIP(8.13)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки работы с ТОПЛИВНЫМ товаром" WIDGET-ID 100.
ASSIGN
       FRAME shattrpt:SCROLLABLE       = FALSE.
ASSIGN
       dop-info:HIDDEN IN FRAME shattrpt           = TRUE
       dop-info:READ-ONLY IN FRAME shattrpt        = TRUE.
ASSIGN
       f-invclipt-name:READ-ONLY IN FRAME shattrpt        = TRUE.
ASSIGN
       sec-fields:READ-ONLY IN FRAME shattrpt        = TRUE.
ON WINDOW-CLOSE OF FRAME shattrpt
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME shattrpt
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-invclipt IN FRAME shattrpt
DO:
  define variable rid-list as character no-undo .
  define buffer buf_clients for ub.clients.
    run ref/cli-all.w
      ( input parParentProc
      , input "b-sel"
      , input 'орг':U
      , input 'все':U
      , input 'текущие':U
      , input ?
      , input "yes,yes,yes,,,,ИЛИ"
      , input "lock-cli-type":U
      , output rid-list
      ) .
    find first buf_clients no-lock
      where recid(buf_clients) = integer( rid-list )
      no-error.
    if available buf_clients then do:
      assign
        f-invclipt      = buf_clients.obj-code
        f-invclipt-name = buf_clients.obj-name
      .
    end.
    else do:
      assign
        f-invclipt      = ?
        f-invclipt-name = "":U
      .
    end.
    display
      f-invclipt
      f-invclipt-name
      with frame shattrpt .
END.
ON CHOOSE OF B-set_dop-info IN FRAME shattrpt
DO:
  run select-dop-info in this-procedure.
END.
ON CHOOSE OF B-set_sec-fields IN FRAME shattrpt
DO:
  run select-sec-fields in this-procedure.
END.
ON LEAVE OF otkl-density IN FRAME shattrpt
DO:
  assign
  otkl-density no-error  .
  if error-status:error or decimal (otkl-density) > 1 then do:
    message "Формат поля должен быть: Больше единицы и три знака после запятой"
    view-as alert-box.
    RETURN NO-APPLY.
  end.
END.
ON LEAVE OF otkl-fact-volue IN FRAME shattrpt
DO:
  assign
  otkl-fact-volue
  .
END.
ON LEAVE OF otkl-temp IN FRAME shattrpt
DO:
  assign
  otkl-temp
  .
END.
ON LEAVE OF otkl-water IN FRAME shattrpt
DO:
  assign
  otkl-water
  .
END.
ON VALUE-CHANGED OF t-block-nozzle IN FRAME shattrpt
DO:
  assign t-block-nozzle .
END.
ON VALUE-CHANGED OF t-invclipt IN FRAME shattrpt
DO:
  assign
    t-invclipt
  .
  if t-invclipt = true then do:
    enable
      f-invclipt
      b-invclipt
      with frame shattrpt .
    display
      f-invclipt-name
      with frame shattrpt .
  end.
  else do:
    assign
      f-invclipt       = ?
      f-invclipt-name = "":U
    .
    display
      f-invclipt
      f-invclipt-name
      with frame shattrpt .
    hide
      f-invclipt
      b-invclipt
      f-invclipt
      in frame shattrpt .
  end.
END.
ON LEAVE OF timeout-block-nozzle IN FRAME shattrpt
DO:
  assign timeout-block-nozzle .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME shattrpt:PARENT eq ?
THEN FRAME shattrpt:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame shattrpt
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
on choose of b-help in frame shattrpt
do:
  apply "help":u to frame shattrpt .
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
                v-frame-width = frame shattrpt:width - 0.3
                fh            = frame shattrpt:first-child
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
  define buffer buf_shop    for ub.shop .
  define buffer buf_store   for ub.store .
  define buffer buf_sysconf for ub.sysconf .
  define buffer buf_clients for ub.clients .
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
  if p-mode <> 'ПРОСМОТР':U
    and p-mode <> 'ИЗМЕНЕНИЕ':U
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра p-mode" p-mode
    view-as alert-box error.
    undo, return error.
  end.
  if p-obj-type <> 'маг':U
    and p-obj-type <> 'скл':U
    and p-obj-type <> 'орг':U
    and p-obj-type <> '':U
  then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-type" p-obj-type
        view-as alert-box error.
      undo, return error.
  end.
  case p-obj-type :
    when 'маг':U then do:
      find first buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
        no-error.
      if not available buf_shop then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Неверное значение параметра p-obj-code" ) skip
          substitute( "Магазин с кодом &1 не найден", p-obj-code ) skip
          view-as alert-box error.
        undo, return error.
      end.
    end.
    when 'скл':U then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
        no-error.
      if not available buf_store then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Неверное значение параметра p-obj-code" ) skip
          substitute( "Склад с кодом &1 не найден", p-obj-code ) skip
          view-as alert-box error.
        undo, return error.
      end.
    end.
    when 'орг':U then do:
      find first buf_sysconf no-lock
        where buf_sysconf.host-code = p-obj-code
        no-error.
      if not available buf_sysconf then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Неверное значение параметра p-obj-code" ) skip
          substitute( "Фирма с кодом &1 не найдена", p-obj-code ) skip
          view-as alert-box error.
        undo, return error.
      end.
    end.
  end case.
  if p-mode <> 'ПРОСМОТР':U
    and v-cntxt-db-num <> 0
  then do:
    case trim( p-obj-type ) :
      when '':U then do:
        message
          "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" Skip
          view-as alert-box error.
        undo, return error.
      end.
      when 'маг':U
      or when 'скл':U
      then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-db-num
  )  .
        if v-db-num <> v-cntxt-db-num then do:
          message
            "Нельзя менять параметры объекта в чужой БД" skip
            "объект принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
            view-as alert-box error.
          undo, return error.
        end.
      end.
      when 'орг':U then do:
        message
          "Нельзя менять параметры ФИРМЫ в УБД" Skip
          view-as alert-box error.
        undo, return error.
      end.
    end case.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first locked_thbj-attr exclusive-lock
      where locked_thbj-attr.obj-type = p-obj-type
        and locked_thbj-attr.obj-code = p-obj-code
        and locked_thbj-attr.upper-prop-code = 'petrol':U
        and locked_thbj-attr.prop-code = "":u
    no-wait no-error.
    if locked locked_thbj-attr then do:
      message
        vss-workfile vss-revision vss-description skip
        "Запись ПАРАМЕТРЫ(АТРИБУТЫ) занята"
      view-as alert-box error .
      undo, return error.
    end.
  end.
  else do:
    find first locked_thbj-attr no-lock
      where locked_thbj-attr.obj-type = p-obj-type
        and locked_thbj-attr.obj-code = p-obj-code
        and locked_thbj-attr.upper-prop-code = 'petrol':U
        and locked_thbj-attr.prop-code = '':u
      no-error.
  end.
  if not available locked_thbj-attr then do:
    assign
      v-to-create  = yes
    .
    message
      substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ", chr(10) )
    view-as alert-box WARNING.
  end.
  assign
    v-tth = buffer thbjattr_thbj-attr:table-handle
  .
  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  find first buf_clients no-lock
    where buf_clients.obj-code = f-invclipt
      and buf_clients.obj-type = 'орг':U
    no-error.
  if available buf_clients then do:
    assign
      t-invclipt      = true
      f-invclipt-name = buf_clients.obj-name
    .
  end.
  else do:
    assign
      t-invclipt      = false
      f-invclipt-name = "":U
    .
  end.
  RUN proc-init-dop-info.
  RUN proc-init-sec-fields.
  RUN enable_UI.
  define variable v-obj-code as integer no-undo .
  define variable v-obj-type as character no-undo .
  if p-obj-code = 0 then do:
      assign
      v-obj-code = v-cntxt-obj-code
      v-obj-type = v-cntxt-obj-type
      .
  end.
  else do:
      assign
      v-obj-code = p-obj-code
      v-obj-type = p-obj-type
      .
  end.
    find last ub.shift-obj no-lock where ub.shift-obj.obj-code = v-obj-code and
        ub.shift-obj.obj-type = v-obj-type no-error .
    if available (ub.shift-obj) then
    do:
        find first ub.shift-param no-lock where ub.shift-param.obj-code = ub.shift-obj.obj-code and
            ub.shift-param.obj-type = ub.shift-obj.obj-type and
            ub.shift-param.shift-date = ub.shift-obj.shift-date and
            ub.shift-param.shift-name = ub.shift-obj.shift-name and
            ub.shift-param.shift-num = ub.shift-obj.shift-num no-error .
        if not available (ub.shift-param) then
        do:
            find first ub.shift-param no-lock where ub.shift-param.obj-code = 0 and
                ub.shift-param.obj-type = "" and
                ub.shift-param.shift-date = 01.01.1900 no-error .
            if available (ub.shift-param) then
                assign
                    dev-paid-trans = ub.shift-param.dev-paid-trans
                    prc-dev-mass   = ub.shift-param.prc-dev-mass
                    .
        end.
        else
        do:
            assign
                dev-paid-trans = ub.shift-param.dev-paid-trans
                prc-dev-mass   = ub.shift-param.prc-dev-mass
                .
        end.
    end.
    display dev-paid-trans prc-dev-mass with frame shattrpt .
  apply "value-changed" to t-invclipt in frame shattrpt .
  if p-mode = 'ПРОСМОТР':U then do:
    disable
      all
      with frame shattrpt .
    enable
      b-quit
      B-set_dop-info
      B-set_sec-fields
      with frame shattrpt .
  end.
  hide dop-info in frame shattrpt .
  hide sec-fields in frame shattrpt .
  WAIT-FOR GO OF FRAME shattrpt.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME shattrpt.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY t-autopump-izm t-autopump t-avtinvpm t-olddens r-expptrl dop-info
          r-inpptrl sec-fields rvs-wt-email r-algrvspt t-rvsnmter t-invclipt
          f-invclipt r-temp-for-pomi r-denstclc mass-proc mass-proc-in-lgas
          r-algoincptrl t-mand-chioce-autocar otkl-fact-volue otkl-temp
          Prc-dev-mass otkl-density otkl-water Dev-paid-trans t-calc-free-vol
          t-calc-free-vol-sug t-trn-reas-sug t-trnscanqr t-rvd-own-nb
          qr-scan-time t-autopump-skip-time t-block-nozzle timeout-block-nozzle
          v-dop-info v-sec-fields f-invclipt-name
      WITH FRAME shattrpt.
  ENABLE B-exit b-quit B-Help RECT-1 RECT-2 RECT-3 RECT-4 RECT-5 RECT-6 RECT-7
         t-autopump-izm t-autopump t-avtinvpm t-olddens r-expptrl r-inpptrl
         sec-fields rvs-wt-email B-set_dop-info B-set_sec-fields r-algrvspt
         t-rvsnmter t-invclipt f-invclipt b-invclipt r-temp-for-pomi r-denstclc
         mass-proc mass-proc-in-lgas r-algoincptrl t-mand-chioce-autocar
         otkl-fact-volue otkl-temp otkl-density otkl-water t-calc-free-vol
         t-calc-free-vol-sug t-trn-reas-sug t-trnscanqr t-rvd-own-nb
         qr-scan-time t-autopump-skip-time t-block-nozzle timeout-block-nozzle
         v-dop-info v-sec-fields
      WITH FRAME shattrpt.
END PROCEDURE.
PROCEDURE fill-widgets :
define variable v-param-type      as character  no-undo .
define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-entry           as character  no-undo .
do
on error undo, return error return-value
:
  for each thbjattr_thbj-attr
  :
    delete thbjattr_thbj-attr .
  end.
  for each temp-thbj-attr
  :
    delete temp-thbj-attr .
  end.
  run adm/shattri.p
    ( input "init":U
    , input p-obj-type
    , input p-obj-code
    , input 'petrol':U
    , input "":U
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , input-output table-handle v-tth
    ) no-error .
  if error-status:error
    and not available locked_thbj-attr
  then do:
    message
    "Не удалось получить начальные значения настроек" skip
    error-status:get-message(1) return-value
    view-as alert-box error .
    undo, return error .
  end.
  for each thbjattr_thbj-attr:
    assign
      v-entry = thbjattr_thbj-attr.prop-code
    .
    case v-entry:
      when 'denstclc':U then do:
        assign
          r-denstclc = thbjattr_thbj-attr.property-value-character
          r-denstclc :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when 'autopump':U then do:
        assign
          t-autopump = thbjattr_thbj-attr.property-value-logical
          t-autopump :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
        when 'autopump-izm':U then do:
          assign t-autopump-izm =  thbjattr_thbj-attr.property-value-logical
             t-autopump-izm :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
          end.
      when 'autopump-skip-time':U then do:
          assign t-autopump-skip-time =  thbjattr_thbj-attr.property-value-integer
             t-autopump-skip-time :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when 'avtinvpm':U then do:
        assign
          t-avtinvpm = thbjattr_thbj-attr.property-value-logical
          t-avtinvpm :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when 'expptrl':U then do:
        assign
          r-expptrl = thbjattr_thbj-attr.property-value-character
          r-expptrl :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when 'inpptrl':U then do:
        assign
          r-inpptrl = thbjattr_thbj-attr.property-value-character
          r-inpptrl :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when 'rvsnmter':U then do:
        assign
          t-rvsnmter = thbjattr_thbj-attr.property-value-logical
          t-rvsnmter :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when 'invclipt':U then do:
        assign
          f-invclipt = thbjattr_thbj-attr.property-value-integer
          f-invclipt :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when 'olddens':U then do:
        assign
          t-olddens = thbjattr_thbj-attr.property-value-logical
          t-olddens :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when 'algrvspt':U then do:
        assign
          r-algrvspt = thbjattr_thbj-attr.property-value-integer
          r-algrvspt :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when 'temp-for-pomi':U then do:
        assign
          r-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
          r-temp-for-pomi :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when 'rvs-wt-email':U then do:
        assign
          rvs-wt-email = thbjattr_thbj-attr.property-value-character
          rvs-wt-email :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when 'CriticalDif':U then
          do:
            assign
              mass-proc = thbjattr_thbj-attr.property-value-character
              mass-proc :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          end.
      when 'algoincome':U then
          do:
            assign
              r-algoincptrl = thbjattr_thbj-attr.property-value-integer
              r-algoincptrl :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
              .
          end.
      when 'otkl-fact-volue':U then
          do:
            assign
              otkl-fact-volue = thbjattr_thbj-attr.property-value-decimal
              otkl-fact-volue :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
              .
          end.
      when 'otkl-temp':U then
          do:
            assign
              otkl-temp = thbjattr_thbj-attr.property-value-decimal
              otkl-temp :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
              .
          end.
      when 'otkl-density':U then
          do:
            assign
              otkl-density = thbjattr_thbj-attr.property-value-character
              otkl-density :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
              .
              if otkl-density = "" then otkl-density = "0.000" .
          end.
      when 'otkl-water':U then
          do:
            assign
              otkl-water = thbjattr_thbj-attr.property-value-decimal
              otkl-water :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
              .
          end.
      when 'mand-choice-autocar':U then
          do:
            assign
              t-mand-chioce-autocar = thbjattr_thbj-attr.property-value-logical
              t-mand-chioce-autocar :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          end.
      when 'block-nozzle':U then
          do:
            assign
              t-block-nozzle = thbjattr_thbj-attr.property-value-logical
              t-block-nozzle :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          end.
      when 'timeout-block-nozzle':U then
          do:
            assign
              timeout-block-nozzle = thbjattr_thbj-attr.property-value-integer
              timeout-block-nozzle :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          end.
        when 'dop-info':U then
          do:
            assign
              dop-info = thbjattr_thbj-attr.property-value-character
              dop-info :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          end.
        when 'sec-fields':U then
          do:
            assign
              sec-fields = thbjattr_thbj-attr.property-value-character
              sec-fields :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          end.
        when 'CriticalDifInLgas':U then
          do:
            assign
              mass-proc-in-lgas = thbjattr_thbj-attr.property-value-decimal
              mass-proc-in-lgas :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          end.
        when 'calc-free-vol':U then
          do:
            assign
              t-calc-free-vol = thbjattr_thbj-attr.property-value-logical
              t-calc-free-vol :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          end.
        when 'calc-free-vol-sug':U then
          do:
            assign
              t-calc-free-vol-sug = thbjattr_thbj-attr.property-value-logical
              t-calc-free-vol-sug :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          end.
        when 'trn-reas-sug':U then
          do:
            assign
              t-trn-reas-sug = thbjattr_thbj-attr.property-value-logical
              t-trn-reas-sug :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          end.
        when 'rvd-own-nb':U then
          do:
            assign
              t-rvd-own-nb = thbjattr_thbj-attr.property-value-logical
              t-rvd-own-nb :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          end.
        when 'qr-scan-time':U then
          do:
            assign
              qr-scan-time = thbjattr_thbj-attr.property-value-integer
              qr-scan-time :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
        end.
        when 'trnscanqr':U then
          do:
            assign
              t-trnscanqr = thbjattr_thbj-attr.property-value-logical
              t-trnscanqr :private-data in frame shattrpt = "recid=" + string(recid(thbjattr_thbj-attr))
            .
          end.
    end case.
    create temp-thbj-attr.
    buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
  end.
end.
END PROCEDURE.
PROCEDURE proc-init-dop-info :
   assign
      v-list-dop-info      = 'car-num':U + "," + 'fio-driver':U + "," + 'time-income':U + "," + 'date-income':U + "," + 'time-pour':U + "," + 'date-pour':U + "," + 'inspection-cert':U + ","
      + 'date-cert':U + "," + 'date-pasport':U  + "," + 'num-pasport':U + "," + 'condition':U + "," + 'seals-condition':U + "," + 'acc-ship':U + "," + 'doc-not':U + "," + 'spisok-not-doc':U + "," + 'ptbobj':U +
      "," + 'ptb-item-pour':U + "," + 'autoent':U.
      v-list-dop-info-full = "Гос. № автоцистерны" + "," + "Ф.И.О. водителя-экспедитора" + "," + "Время прибытия на АЗС" + "," + "Дата прибытия на АЗС" + "," + "Время налива" + "," + "Дата налива" + "," + "Свидетельство о поверке" + ","
      + "Дата свидетельства о поверке" + "," + "Паспорт качества дата" + "," + "Паспорт качества номер" + "," + "Техническое состояние" + "," + "Пломбы и их состояние" + "," + "Допустимый % погрешности поставщика" + "," + "Документы НЕ предоставлены" + "," + "Список не предоставленных документов" +
       "," + "Нефтебаза/ГНС" + "," + "Примечание к нефтебазе" + "," + "Автопредприятие".
END PROCEDURE.
PROCEDURE proc-init-sec-fields :
   assign
      v-list-sec-fields      = "section-name,cli-qnty,doc-dens,group-np,list-tank,"
                             + "ttn-temp,acc-ship,doc-dens-st,doc-qnty,doc-volume,"
                             + "shape,pour,num-passport,car-vol,pasp-dens,"
                             + "a-b-tarir,tank-density,tank-temp,dens-temp,"
                             + "place-si,place-si-temp,accessIDLowerLevel".
      v-list-sec-fields-full = "Номер секции,Масса по док.,Плотность по док. (при раб. темп.),Группа НП/Давление насыщенных паров,Резервуар,"
                             + "Температура по ТТН,Погр. изм. пост.,Плотность по док. (при станд. темп.),Кол-во по док.,Объем по док.,"
                             + "Форма горловины,Тип налива,Дата и номер паспорта качества,Объем по свидетельству о поверке,Плотность по паспорту,"
                             + "Отклонение от тарировочной планки,Плотность топлива,Температура замера объема,Температура замера плотности,"
                             + "Средство измерения плотности,Средство измерения температуры,Идентиф. доступа (ключ) «нижнего уровня»".
END PROCEDURE.
PROCEDURE proc-save :
define variable v-value-character as character      no-undo .
define variable v-value-date      as date           no-undo .
define variable v-value-decimal   as decimal        no-undo .
define variable v-value-integer   as integer        no-undo .
define variable v-value-logical   as logical        no-undo .
define variable v-sale-add        as character      no-undo .
define variable v-param-type      as character      no-undo .
define variable wh                as widget-handle  no-undo .
define variable fh                as widget-handle  no-undo .
define variable v-same            as logical        no-undo .
define variable v-change-temp     as logical        no-undo .
define variable v-change-volume   as logical        no-undo .
define variable v-change-density  as logical        no-undo .
define variable v-change-water    as logical        no-undo .
define variable v-change-param    as character      no-undo .
define variable v-vid-param       as longchar       no-undo .
define variable v-vid-action           as integer   no-undo .
define variable v-computer-name        as character no-undo .
define variable v-computer-tcp-name    as character no-undo .
define variable v-computer-ip-addr     as character no-undo .
define variable v-computer-login-name  as character no-undo .
define variable v-computer-process-pid as integer   no-undo .
define variable v-date                 as character no-undo .
define variable v-time                 as character no-undo .
do
on error undo, return error return-value
:
display dop-info sec-fields with frame shattrpt .
hide dop-info sec-fields in frame shattrpt .
  if p-mode = 'ПРОСМОТР':U then do:
    return error.
  end.
  define buffer buf_clients for ub.clients .
  assign
    frame shattrpt t-invclipt
    frame shattrpt f-invclipt
    fh = frame shattrpt:first-child
    wh = fh:first-child
  .
  if t-invclipt = true then do:
    find first buf_clients no-lock
      where buf_clients.obj-code = f-invclipt
        and buf_clients.obj-type = 'орг':U
      no-error.
    if not available buf_clients then do:
      message
        "Некорректное значение НАСТРОЙКИ"    skip
        t-invclipt:label                     skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
  do while valid-handle(wh):
    if wh:private-data begins "recid=" then do:
      find first thbjattr_thbj-attr
        where recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '='))
      .
      assign
        buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value
      .
    end.
    wh = wh:next-sibling.
  end.
  assign
    v-same = yes
  .
  for each thbjattr_thbj-attr,
      first temp-thbj-attr
        where temp-thbj-attr.obj-type         = thbjattr_thbj-attr.obj-type
          and temp-thbj-attr.obj-code         = thbjattr_thbj-attr.obj-code
          and temp-thbj-attr.upper-prop-code  = thbjattr_thbj-attr.upper-prop-code
          and temp-thbj-attr.prop-code        = thbjattr_thbj-attr.prop-code
  :
    buffer-compare thbjattr_thbj-attr to temp-thbj-attr save result in v-same.
    if v-same = false then do:
      leave.
    end.
  end.
  if v-same = true
    and v-to-create = false
  then do:
    return.
  end.
  run adm/shattri.p
    ( input "check":U
    , input p-obj-type
    , input p-obj-code
    , input 'petrol':U
    , INPUT '':U
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , input-output table-handle v-tth
    ) no-error .
  if error-status :error then do:
    message
      "Некорректное значение ПАРАМЕТРОВ"  skip
      error-status:get-message(1)         skip
      return-value
    view-as alert-box error .
    undo, return error .
  end.
    run thbjattr_set-section in this-procedure
    ( input p-obj-type
    , input p-obj-code
    , input 'petrol':U
    , input table thbjattr_thbj-attr
    ) no-error.
  if error-status:error then do:
    message
      error-status:get-message(1)  skip
      return-value
    view-as alert-box.
    undo, return error.
  end.
  for each temp-thbj-attr no-lock:
    v-change-param = "" .
    case temp-thbj-attr.prop-code:
      when 'otkl-fact-volue':U then
        do:
          if temp-thbj-attr.property-value-decimal <> otkl-fact-volue then
          do:
            v-change-param = "IDParam="  + "otkl-fact-volume" + chr(4) +
              "NameParam=" + "Макс.допустимое значение фактического объема" + chr(4) +
              "ParamBefore=" + string(temp-thbj-attr.property-value-decimal) + chr(4) +
              "ParamAfter=" + string(otkl-fact-volue) no-error.
          end.
        end.
      when 'otkl-temp':U then
        do:
          if temp-thbj-attr.property-value-decimal <> otkl-temp then
          do:
            v-change-param = "IDParam="  + "otkl-temp" + chr(4) +
              "NameParam=" + "Макс.допустимое значение температуры" + chr(4) +
              "ParamBefore=" + string(temp-thbj-attr.property-value-decimal) + chr(4) +
              "ParamAfter=" + string(otkl-temp) no-error.
          end.
        end.
      when 'otkl-density':U then
        do:
          if temp-thbj-attr.property-value-character <> otkl-density then
          do:
            v-change-param = "IDParam="  + "otkl-density" + chr(4) +
              "NameParam=" + "Макс.допустимое значение плотности" + chr(4) +
              "ParamBefore=" + string(temp-thbj-attr.property-value-character) + chr(4) +
              "ParamAfter=" + string(otkl-density) no-error.
          end.
        end.
      when 'otkl-water':U then
        do:
          if temp-thbj-attr.property-value-decimal <> otkl-water then
          do:
            v-change-param = "IDParam="  + "otkl-water" + chr(4) +
              "NameParam=" + "Макс.допустимое значение воды" + chr(4) +
              "ParamBefore=" + string(temp-thbj-attr.property-value-decimal) + chr(4) +
              "ParamAfter=" + string(otkl-water) no-error.
          end.
        end.
    end.
    if v-change-param <> "" then
    do:
      define variable v-time-hour    as integer   no-undo .
      define variable v-time-min     as integer   no-undo .
      define variable v-nik          as character no-undo .
      define variable v-name         as character no-undo .
      define variable v-cntxt-userid as character no-undo .
      run get-userid in parparentproc ( output v-cntxt-userid) .
      run get-userid in parparentproc ( output v-cntxt-userid) .
      find first ub.user-account no-lock where ub.user-account.user-id = v-cntxt-userid no-error .
      if available (ub.user-account) then
      do:
        assign
          v-nik  = ub.user-account.nik
          v-name = ub.user-account.last-name + " " + ub.user-account.first-name
          .
      end.
      run cur-time in this-procedure ( output v-date, output v-time).
      v-time-hour = truncate(integer(v-time) / 3600, 0).
      v-time-min  = (integer(v-time) - (v-time-hour * 3600)) / 60 .
      run sys-time_get-comp-user-name in this-procedure
        (output v-computer-name
        ,output v-computer-login-name
        ,output v-computer-process-pid
        ) .
      v-vid-action = 66 .
define variable v-initiator  as character no-undo.
case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.
      v-vid-param =
        "UniqueIdRecordARM=" + v-initiator + chr(4) +
        "UserName=" + v-name + chr(4) +
        "UserNik=" + v-nik + chr(4) +
        "NumShop=" + string(temp-thbj-attr.obj-code) + chr(4) + v-change-param
        no-error.
      run trg/userlog.p (
        input 'update':U
        , input 'thbj-attr':U
        , input ( buffer temp-thbj-attr :handle )
        , input v-vid-action
        , input v-vid-param
        ) no-error.
      if error-status :error
        then
      do:
        return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
          , chr(10)
          , vss-workfile
          , return-value
          , error-status :get-message ( 1 ) ).
      end.
    end.
  end.
end.
END PROCEDURE.
PROCEDURE select-dop-info :
define variable v-counter       as integer      no-undo.
define variable v-label         as character    no-undo.
define variable v-value         as character    no-undo.
define variable v-list          as character    no-undo.
define variable v-changed       as logical    no-undo.
define variable v-accepted      as logical    no-undo.
define variable v-mode          as integer    no-undo.
define variable V-EX as logical   no-undo .
do
with frame shattrpt
on error undo, return error
:
if p-mode = 'ПРОСМОТР':U then v-mode = 0 .
else v-mode = 1 .
    run twowin_clear in this-procedure.
    do v-counter = 1 to num-entries( v-list-dop-info-full )
    on error undo, return error
    :
        assign
            v-label = entry( v-counter, v-list-dop-info-full )
            v-value = entry( v-counter, v-list-dop-info )
            v-ex = false
        .
           if  lookup (v-value , dop-info ) > 0 then  v-ex = true .
           else v-ex = false .
        run twowin_add-item in this-procedure (
              input v-value
            , input v-label
            , input substitute( "Обязательные поля: &1", v-VALUE)
            , input  V-EX
        ).
    end.
    run gbl/twowin.w (
          input ?
        , input v-mode
        , input "Выбор обязательного поля доп.инфо ПН":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-changed
        , output v-accepted
    ).
    if v-changed then do:
        dop-info = "" .
        for each temp_twowin_itemsSelected_col :
        dop-info = dop-info +  temp_twowin_itemsSelected_col.itmExtKey + "," .
        end.
        dop-info = trim(dop-info, ",") .
        display dop-info with frame shattrpt .
                    hide dop-info in frame shattrpt .
    end.
end.
END PROCEDURE.
PROCEDURE select-sec-fields :
define variable v-counter       as integer      no-undo.
define variable v-label         as character    no-undo.
define variable v-value         as character    no-undo.
define variable v-list          as character    no-undo.
define variable v-changed       as logical    no-undo.
define variable v-accepted      as logical    no-undo.
define variable v-mode          as integer    no-undo.
define variable V-EX as logical   no-undo .
do
with frame shattrpt
on error undo, return error
:
if p-mode = 'ПРОСМОТР':U then v-mode = 0 .
else v-mode = 1 .
    run twowin_clear in this-procedure.
    do v-counter = 1 to num-entries( v-list-sec-fields-full )
    on error undo, return error
    :
        assign
            v-label = entry( v-counter, v-list-sec-fields-full )
            v-value = entry( v-counter, v-list-sec-fields )
            v-ex = false
        .
           if  lookup (v-value , sec-fields ) > 0 then  v-ex = true .
           else v-ex = false .
        run twowin_add-item in this-procedure (
              input v-value
            , input v-label
            , input substitute( "Обязательные поля: &1", v-VALUE)
            , input  V-EX
        ).
    end.
    run gbl/twowin.w (
          input ?
        , input v-mode
        , input "Выбор обязательного поля в секциях ПН":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table sect_twowin_itemsSelected_col
        , output v-changed
        , output v-accepted
    ).
    if v-changed then do:
        sec-fields = "" .
        for each sect_twowin_itemsSelected_col :
        sec-fields = sec-fields +  sect_twowin_itemsSelected_col.itmExtKey + "," .
        end.
        sec-fields = trim(sec-fields, ",") .
    end.
end.
END PROCEDURE.
